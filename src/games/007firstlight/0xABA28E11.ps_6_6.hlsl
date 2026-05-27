// ==============================================================================
// HDR Resolve & PQ Encode
// Refactored HLSL
// ==============================================================================

struct S_cbHDRResolve {
    float4 vParams;
    // vParams.z = Linear exposure or scene peak multiplier.
    // vParams.y = PQ normalization scale (typically 1.0 / 10000.0, as PQ tracks up to 10k nits).

    float4 mContentToMonitor[3]; // Unused in this specific pass.
};

Texture2D<float4> mapTPC0 : register(t0);

cbuffer _cbHDRResolve : register(b5) {
    S_cbHDRResolve cbHDRResolve : packoffset(c000.x);
};

struct OutputSignature {
    float4 SV_Target0 : SV_Target0;
    float4 SV_Target1 : SV_Target1;
};

// Rec.709 (sRGB primaries) to Rec.2020 Color Space Conversion Matrix
static const float3x3 REC709_TO_REC2020 = float3x3(
    0.6274039f, 0.3292830f, 0.0433130f,
    0.0690972f, 0.9195404f, 0.0113623f,
    0.0163914f, 0.0880133f, 0.8955952f
);

// SMPTE ST.2084 (PQ) Constants
static const float PQ_m1 = 0.1593017578125f; // 2610 / 16384
static const float PQ_m2 = 78.84375f;        // 2523 / 32
static const float PQ_c1 = 0.8359375f;       // 3424 / 4096
static const float PQ_c2 = 18.8515625f;      // 2413 / 128
static const float PQ_c3 = 18.6875f;         // 2392 / 128

// Applies the ST.2084 PQ OETF
float3 EncodePQ(float3 linearColor) {
    // pow(x, y) compiles down to the exp2(log2(x) * y) instructions seen in the dump.
    float3 L_m1 = pow(abs(linearColor), PQ_m1);

    float3 numerator = (L_m1 * PQ_c2) + PQ_c1;
    float3 denominator = (L_m1 * PQ_c3) + 1.0f;

    return pow(numerator / denominator, PQ_m2);
}

OutputSignature main(noperspective float4 SV_Position : SV_Position) {
    // 1. Fetch input scene pixel (ignoring sub-pixel interpolation via uint cast)
    int3 texCoord = int3((uint)SV_Position.x, (uint)SV_Position.y, 0);
    float3 sceneColor = mapTPC0.Load(texCoord).rgb;

    // 2. Decode Gamma 2.2 to Linear and apply the exposure/scale multiplier
    float3 linearColor = cbHDRResolve.vParams.z * pow(sceneColor, 2.2f);

    // 3. Convert color space from Rec.709 to Rec.2020
    float3 rec2020Color = mul(REC709_TO_REC2020, linearColor);

    // 4. Normalize to the 10,000 nit PQ container bounds
    float3 normalizedForPQ = rec2020Color * cbHDRResolve.vParams.y;

    // 5. Apply the ST.2084 PQ perceptual quantizer curve
    float3 pqColor = EncodePQ(normalizedForPQ);

    // 6. Write out to MRT (Multiple Render Targets)
    OutputSignature output;
    output.SV_Target0 = float4(pqColor, 1.0f);
    output.SV_Target1 = float4(pqColor, 1.0f); // Likely a mirrored target for a UI/composite pass

    return output;
}
