// ==============================================================================
// 0x33CB3D22 - PostChainMergeHDR_T3_CS
// Reconstructed HLSL
// ==============================================================================

// --- Structs ---
struct SHDRAdaptationState
{
    float m_fLuminanceGeometricMean;
    float m_fAdaptedMiddleGray;
    float m_fAdaptedBloomPoint;
    float m_fAdaptedBloomPointThreshold;
    float m_fAdaptedBloomPointClamp;
    float m_fAdaptedLuminance;
    float m_fAdaptedExposure;
    float m_fAdaptedBrightPassThreshold;
    float m_fAdaptedBrightPassClamp;
};

// --- Resources ---
SamplerState samplerLinearClampNode : register(s4);

Texture2D<float4>   mapLinearLightTexture    : register(t0);
Texture2D<float4>   mapGlareTexture          : register(t1);
Texture3D<float4>   srvColorCorrectionVolume : register(t2);
Texture2D<float4>   mapGridTexture           : register(t3);
StructuredBuffer<SHDRAdaptationState> srvHDRAdaptationState : register(t6);
Texture2D<float>    srvExposures             : register(t14);

RWTexture2D<float4> uavOutput1               : register(u0);

// --- Constant Buffer ---
cbuffer _cbPostChainMerge : register(b5)
{
    float2 vPixelSize;                          // Offset: 0
    uint   _pad_0[2];                           // Offset: 8
    float4 vUVToGridUV;                         // Offset: 16
    float4 vParams2;                            // Offset: 32
    float4 vVignetteParams;                     // Offset: 48
    float4 vVignetteParams2;                    // Offset: 64
    float3 vColorTint;                          // Offset: 80
    float  fOptionalGammaAdjust;                // Offset: 92
    float4 vHDRParams;                          // Offset: 96
    float  fGlareStrength;                      // Offset: 112
    float  fTonemapScale;                       // Offset: 116
    float  fWhitePoint;                         // Offset: 120
    float  fRcpMappedWhitePoint;                // Offset: 124
    float  fMaxUVDistortion;                    // Offset: 128
    float  fFadeValue;                          // Offset: 132
    float  fAlphaMaskFromDepthCutoff;           // Offset: 136
    float  fFilmSlope;                          // Offset: 140
    float  fFilmToe;                            // Offset: 144
    float  fFilmShoulder;                       // Offset: 148
    float  fFilmBlackClip;                      // Offset: 152
    float  fFilmWhiteClip;                      // Offset: 156
    float  fFilmToeLinearInterp;                // Offset: 160
    int    iToneMapType;                        // Offset: 164
    uint   nApplyExposure;                      // Offset: 168
    int    bTonemapDebugMainViewBlackDetection; // Offset: 172
    int    bTonemapDebugExposureOverride;       // Offset: 176
    int    bTonemapDebugCompareToAces;          // Offset: 180
    float  fTonemapDebugExposureValue;          // Offset: 184
    uint   _pad_2;                              // Offset: 188
};

// Helper function: Parameterized Log/Exp Filmic Tonemapper
// This condenses the heavy DXIL block (instructions %125 to %304) into its intended mathematical curve.
float3 ApplyFilmicCurve(float3 color)
{
    // The shader uses the fFilm* parameters to evaluate a curve similar to Hable/Frostbite.
    // It shifts values into a log space, applies the toe, shoulder, and clipping constraints,
    // and exponentiates back. This remaps the peak luminance (e.g., clipping bounds defined by fFilmWhiteClip)
    // so it doesn't hard-clip before the final PQ ST.2084 encode.

    // (Approximated representation of the dense DXIL math unroll)
    float3 logColor = log(color);
    float3 toe = exp(logColor * fFilmSlope + fFilmToe);
    float3 shoulder = exp(logColor * fFilmSlope - fFilmShoulder);

    // Interlaced lerps and saturates based on black/white clip bounds and linear interpolation thresholds
    float3 mapped = saturate(toe / (shoulder + 1.0f));

    // Linear toe blending if fFilmToeLinearInterp > 0
    if (fFilmToeLinearInterp > 0.0f)
    {
        float3 linearToe = color / fFilmToeLinearInterp;
        mapped = lerp(mapped, linearToe, saturate(linearToe));
    }

    return mapped;
}

[numthreads(8, 8, 1)]
void PostChainMergeHDR_T3_CS(uint3 DTid : SV_DispatchThreadID)
{
    // 1. Generate core UVs using the dispatch thread ID
    float2 uv = (DTid.xy + 0.5f) * vPixelSize;

    // Map standard UV to Grid UV for distortion/vignette maps
    float2 gridUV = uv * vUVToGridUV.xy + vUVToGridUV.zw;

    // 2. Fetch the grid map which stores UV distortion offsets (xy) and vignette multipliers (z)
    float4 grid = mapGridTexture.SampleLevel(samplerLinearClampNode, gridUV, 0);

    // Apply distortion (used for lens effects like chromatic aberration or barrel distortion)
    float2 distortedUV = uv + (fMaxUVDistortion * grid.xy);

    // Calculate vignette mask
    float3 vignetteMultiplier = (vVignetteParams.xyz - 1.0f) * grid.z + 1.0f;

    // 3. Sample the primary buffers
    float3 sceneColor = mapLinearLightTexture.SampleLevel(samplerLinearClampNode, distortedUV, 0).rgb;
    float3 glareColor = mapGlareTexture.SampleLevel(samplerLinearClampNode, distortedUV, 0).rgb;

    // 4. Dynamically fetch Auto-Exposure (Eye Adaptation)
    float exposure = 1.0f;
    float adaptedExposure = 1.0f;

    if (nApplyExposure != 0)
    {
        exposure = srvExposures.SampleLevel(samplerLinearClampNode, uv, 0);
        adaptedExposure = srvHDRAdaptationState[0].m_fAdaptedExposure;
    }

    // 5. Apply Tint, Exposure, and merge the Glare/Bloom buffer
    float3 tintedScene = sceneColor * vColorTint * exposure;
    float3 tintedGlare = glareColor * fGlareStrength * vColorTint * adaptedExposure;

    float3 mergedScene = tintedScene + tintedGlare;

    // 6. Apply the primary Filmic Tonemapping Curve
    float3 tonemapped = ApplyFilmicCurve(mergedScene);

    // Combine vignette with the tonemapped output
    tonemapped *= vignetteMultiplier;

    // 7. 3D Color Correction LUT Lookup
    // The shader scales the tonemapped output by 0.9375 (30/32) and adds 0.03125 (1/32).
    // This perfectly centers the coordinates for a 32x32x32 3D LUT to avoid boundary interpolation errors.
    float3 lutCoords = saturate(tonemapped) * 0.9375f + 0.03125f;
    float3 gradedColor = srvColorCorrectionVolume.SampleLevel(samplerLinearClampNode, lutCoords, 0).rgb;

    // 8. Re-apply HDR scale/gamma adjustments
    // Post-LUT, the color is exponentiated/scaled based on HDR params before passing to the PQ encoder.
    float3 finalColor = gradedColor * exp(vHDRParams.y * 0.693147f);

    // Apply master fade value (usually used during cutscene transitions or death screens)
    finalColor *= fFadeValue;

    // 9. Output to UAV
    // Writes to an R16G16B16A16_FLOAT buffer. The 4th component (alpha) is explicitly set to 0.0.
    // This buffer acts as the normalized scene light source for the final display mapping pass.
    uavOutput1[DTid.xy] = float4(finalColor, 0.0f);
}
