// 0xAE3A804E - ComputeLuminancesAndWeights_CS
// Exposure-analysis helper. This samples the current HDR color, multiplies it
// by the adaptation exposure and vHDRScale.x, then writes three metered luma
// values plus weights for shadow/midtone/highlight exposure decisions.
// Important: the three luma probes are clamped to 5.0 before normalization.
// This is analysis/debug data, not the final tonemap or PQ encode.

struct S_cbSharedPerViewData {
  float4 mProjection[4][1];
  float4 mProjectionPrev[4][1];
  float4 mViewToViewport[4][1];
  float4 mViewToWorld[3][1];
  float4 mViewToWorldPrev[3][1];
  float4 mWorldToView[3];
  float4 mWorldToViewPrev[3];
  float4 mProjToWorld[4];
  float4 mFxWorldToSampleSpace[4];
  float4 mViewToGlobalShadowVSPT[4];
  float4 vViewRemap;
  float4 vViewDepthRemap[1];
  float4 vEyeVectorUL[1];
  float4 vEyeVectorLR[1];
  float4 vEyeVectorDelta[1];
  float4 vPixelToEyeVectorScaleBias[1];
  float4 vViewSpaceUpVector;
  float4 vViewportSize;
  float4 vEngineTime;
  uint nFrameCounter;
  float fShaderLodFactorRcp;
  float fMipLODBias;
  float fScaledMipLODBias;
  float4 vShaderColor0;
  float4 vShaderColor1;
  float4 vShaderColor2;
  float4 vShaderColor3;
  float4 vClipPlane0;
  float4 vClipPlane1;
  float4 vClipPlane2;
  float4 vClipPlane3;
  float4 vClipPlane4;
  float4 vClipPlane5;
  float4 vClusteredLightingParams;
  uint4 viClusteredLightingClusterParams;
  float4 vMippedDepthRemap;
  float4 vSpecularOcclusionSettings;
  float4 vSaturatedAmbientOcclusionSettings;
  float4 vHDRScale;
  float4 vTweakableShaderParams;
  float4 vAtmosphericScatteringParameters;
  float4 vAtmosphericScatteringParameters2;
  float4 vAtmosphericScatteringParameters3;
  float3 vAtmosphericScatteringMieBeta;
  uint _pad_0;
  float3 vAtmosphericScatteringRayleighBeta;
  uint _pad_1;
  float3 vAtmosphericScatteringShadowedMieBeta;
  uint _pad_2;
  float3 vAtmosphericScatteringShadowedRayleighBeta;
  uint _pad_3;
  float3 vAttenuatedSunColor;
  uint _pad_4;
  float3 vSunDirectionVS;
  uint _pad_5;
  float3 vSunDirectionWS;
  float fSunScatteringIntensity;
  float4 vWindDirectionAndStrength;
  float4 vWindDirectionAndStrengthPrev;
  float4 vWindInitialDirectionAndStrength;
  float4 vFxFadeParameters;
  float2 vFxSize;
  int nNumCSMCascades;
  float fCSMFadeAdd;
  int nEnableClothBias;
  int nEnableCloth;
  int nClothInstanceDataOffset;
  uint _pad_6;
  int2 viNumTiles;
  int nLightTileDebugFlags;
  int nSelectedBoxReflectionId;
  int nEnableAtmosphericScatteringBackdrop;
  int nFallbackRoomMask;
  int nInspectorId;
  uint _pad_7;
  float4 vClearColor;
  float4 vShadowAtlasSize;
  float fShadowPoissonScaleInPixels;
  int nShadowSpotKernel;
  int nShadowCSMKernel;
  uint _pad_8;
  float4 vPixelJitter;
  float2 vUnjitter;
  float fMaxReactiveMask;
  float fReactiveMaskMotionThreshold;
  float2 vGlobalShadowSize;
  float fGlobalShadowMapConstantBias;
  float fGlobalShadowMapLinearBias;
  float fGlobalShadowMapNormalOffsetBias;
  float2 vGlobalCascadeOffset;
  uint _pad_9;
  float2 vGlobalCascadeScale;
  float2 vGlobalCascadeFadeOffset;
  float2 vGlobalCascadeFadeScale;
  float fGlobalCascadeFadeAmount;
  uint nGlobalCascadeBindlessID;
  float fVTSMConstantDepthBias;
  float fVTSMLinearDepthBias;
  float fVTSMConstantNormalBias;
  float fVTSMLinearNormalBias;
  int nHashedAlphaPeriod;
  int nIsRenderingOffscreen;
  int nMirrorsDisabled;
  int nScatterMode;
  int nSrvObjectIndicesOffset;
  int nCameraDistanceDitherEnable;
  float fPixelAngleFootprintApprox;
  int nSSROnTransparent;
  int nSSRHalfRes;
  uint nMaxViewDistance;
  int nVolumetricLightingApplyEnable;
  float fVolumetricLightingApplyZBias;
  float fVolumetricLightingEndDistance;
  float3 vVolumetricLightingViewToFroxelWParams;
  float2 vVolumetricLightingPixelCoordToFroxel;
  uint _pad_10;
  uint _pad_11;
  float3 vVolumetricLightingGridSize;
  float fGlobalHeightFogFalloffScale;
  float fGlobalHeightFogFalloffHeight;
  uint _pad_12;
  uint _pad_13;
  uint _pad_14;
  float4 vGlobalHeightFogAlbedoAndExtinction;
  float3 vVolumetricLightingAmbientEmissive;
  float fGlobalHeightFogFalloffHeightScaled;
  float3 vVolumetricLightingHeightFogEmissive;
  uint nOutsideBoxReflectionFallbackId;
  float3 vGIProbesUVWScale;
  uint nGIProbesNumGrids;
  float3 vGIProbesUVWBias;
  uint nLightingFeatureFlags;
  uint nAccessibilityFlags;
  uint _pad_15;
  uint _pad_16;
  uint _pad_17;
  float4 vAccessibilityColorOpaque;
  float4 vAccessibilityColorOpaqueCrowd;
  float4 vAccessibilityColorEmissive;
  float4 vAccessibilityColorTransparent;
  float4 vAccessibilityColorParticles;
  int nEnableContactShadows;
  int nEnableContactShadowsDebugColor;
  uint _pad_18;
  uint _pad_19;
  uint4 nGIProbesRoomBitsToIds[8];
  uint4 viGIProbesCMResolution;
  float4 vGIProbesVoxelSize;
  float4 vGIProbesCMRegionMinWS[4];
  float4 vGIProbesCMRegionMaxWS[4];
  float4 vGIProbesCMBlendSizeWS[4];
  float4 vGIProbesCMCoordToUVWScaleXY;
  float4 vGIProbesCMCoordToUVWScaleZ;
  float4 vGIProbesCMWorldToCoordScale;
  float4 vGIProbesCoordToCMWorldScale;
  float4 vGIProbesCMWorldToCoordBias[4];
  float4 vGIProbesSampleParams;
  uint nGIProbesFlags;
  uint nGIProbesForceLevel;
  uint _pad_20;
  uint _pad_21;
  float4 vWireBackCol;
  float fWireThickness;
  float fWireSmoothness;
  float fWireThicknessFar;
  float fWireSmoothnessFar;
  float fWireFadeStart;
  float fWireFadeEnd;
  float fWireAlphaFadeStart;
  float fWireAlphaFadeEnd;
  float fWireAlphaFade;
  uint nIsRenderingShadow;
  uint nWireMode;
  uint nSSGIEnabled;
  uint nBentNormalsEnabled;
  uint nPathTracingIsEnabled;
  uint _pad_22;
  uint _pad_23;
  float3 vOutsideBoxReflectionFallbackModifier;
  float fLogNearPlane;
  float fInvLogPlaneDifference;
  uint _pad_24;
  uint _pad_25;
  uint _pad_26;
  float4 vMomentsSize;
  float4 vWrappingZoneParameters;
  float fOverestimation;
  float fMomentBias;
  uint2 oitDebugPixel;
  float4 vTerrainRGNParams[8];
  uint2 viTerrainSectorNearCam;
  float fTerrainVTOneOverPageAtlasSizeXY;
  uint nTerrainVTFlags;
  uint nLightingShadowFeatures;
  float2 vVolumetricReferenceTransmittanceDepthToUVScaleBias;
  uint nSmolderCSMSplit;
  float waterMaxtessellationFactor;
  uint nSmolderCSMBindlessID;
  float fSmolderCSMDepthOffset;
  uint nDebugLightblocker;
  uint4 vVoxelCount[4];
  float4 vVoxelSize[4];
  float4 vGridOrigins[8];
  uint vortexTextureAtlasWidth;
  uint vortexTextureAtlasHeight;
  uint vortexTextureAtlasDepth;
  uint collisionTextureAtlasWidth;
  uint collisionTextureAtlasHeight;
  uint collisionTextureAtlasDepth;
  uint _pad_27;
  uint _pad_28;
  float4 mCinematicVolumeWorldToObject[3];
  float3 vCinematicVolumeBoxHalfSize;
  uint nCinematicVolumeEnabled;
  float3 vCinematicVolumeBoxFadeNeg;
  uint nCinematicVolumeRemoveCSM;
  float3 vCinematicVolumeBoxFadePos;
  uint nPadCinematicVolume1;
};

struct SHDRAdaptationState {
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


Texture2D<float4> ComputeLuminancesAndWeights_InputSRV : register(t0);

StructuredBuffer<SHDRAdaptationState> ComputeLuminancesAndWeights_HDRAdaptationSRV : register(t1);

RWTexture2D<float4> ComputeLuminancesAndWeights_LuminancesUAV : register(u0);

RWTexture2D<float4> ComputeLuminancesAndWeights_WeightsUAV : register(u1);

cbuffer _cbSharedPerViewData : register(b2) {
  S_cbSharedPerViewData cbSharedPerViewData : packoffset(c000.x);
};

cbuffer _cbComputeLuminancesAndWeights : register(b3) {
  struct S_cbComputeLuminancesAndWeights {
    uint nTargetWidth;
    uint nTargetHeight;
    float fHighlightExposure;
    float fShadowExposure;
    uint nType;
    float fShadowsLerpStart;
    float fShadowsLerpEnd;
    float fHighlightsLerpStart;
    float fHighlightsLerpEnd;
    float fMidgrayTarget;
    float fMidgrayWidth;
    float fWeightScale;
  } cbComputeLuminancesAndWeights : packoffset(c000.x);
};

[numthreads(8, 8, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  float _12 = float((uint)(int)(cbComputeLuminancesAndWeights.nTargetWidth));
  float _14 = float((uint)(int)(cbComputeLuminancesAndWeights.nTargetHeight));
  float _15 = float((uint)SV_DispatchThreadID.x);
  float _16 = float((uint)SV_DispatchThreadID.y);
  bool _17 = (_15 >= _12);
  bool _18 = (_16 >= _14);
  bool _19 = _17 || _18;
  float _127;
  float _137;
  float _189;
  float _190;
  float _191;
  if (!_19) {
    // Current auto-exposure value from the HDR adaptation buffer.
    float _24 = ComputeLuminancesAndWeights_HDRAdaptationSRV[0].m_fAdaptedExposure;
    float4 _26 = ComputeLuminancesAndWeights_InputSRV.Load(int3((uint)(SV_DispatchThreadID.x), (uint)(SV_DispatchThreadID.y), 0));
    float _32 = _26.x * _24;
    // Scene RGB is scaled by the view HDR scale before luma metering.
    float _33 = _32 * cbSharedPerViewData.vHDRScale.x;
    float _34 = _26.y * _24;
    float _35 = _34 * cbSharedPerViewData.vHDRScale.x;
    float _36 = _26.z * _24;
    float _37 = _36 * cbSharedPerViewData.vHDRScale.x;
    float _40 = _33 * cbComputeLuminancesAndWeights.fShadowExposure;
    float _41 = _35 * cbComputeLuminancesAndWeights.fShadowExposure;
    float _42 = _37 * cbComputeLuminancesAndWeights.fShadowExposure;
    float _44 = _33 * cbComputeLuminancesAndWeights.fHighlightExposure;
    float _45 = _35 * cbComputeLuminancesAndWeights.fHighlightExposure;
    float _46 = _37 * cbComputeLuminancesAndWeights.fHighlightExposure;
    float _47 = dot(float3(_40, _41, _42), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    // Shadow, mid, and highlight metering luma are capped at 5.0 here.
    float _48 = min(_47, 5.0f);
    float _49 = max(_48, _48);
    float _50 = max(0.0f, _48);
    float _51 = max(_50, _49);
    float _52 = _51 + 1.0f;
    float _53 = _48 / _52;
    float _54 = dot(float3(_33, _35, _37), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    float _55 = min(_54, 5.0f);
    float _56 = max(_55, _55);
    float _57 = max(0.0f, _55);
    float _58 = max(_57, _56);
    float _59 = _58 + 1.0f;
    float _60 = _55 / _59;
    float _61 = dot(float3(_44, _45, _46), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    float _62 = min(_61, 5.0f);
    float _63 = max(_62, _62);
    float _64 = max(0.0f, _62);
    float _65 = max(_64, _63);
    float _66 = _65 + 1.0f;
    float _67 = _62 / _66;
    bool _68 = (_53 > 0.0031308000907301903f);
    float _69 = float((bool)_68);
    float _70 = abs(_53);
    float _71 = log2(_70);
    float _72 = _71 * 0.4166666567325592f;
    float _73 = exp2(_72);
    float _74 = _73 * 1.0549999475479126f;
    float _75 = _53 * 12.920000076293945f;
    float _76 = -0.054999999701976776f - _75;
    float _77 = _76 + _74;
    float _78 = _77 * _69;
    float _79 = _78 + _75;
    bool _80 = (_60 > 0.0031308000907301903f);
    float _81 = float((bool)_80);
    float _82 = abs(_60);
    float _83 = log2(_82);
    float _84 = _83 * 0.4166666567325592f;
    float _85 = exp2(_84);
    float _86 = _85 * 1.0549999475479126f;
    float _87 = _60 * 12.920000076293945f;
    float _88 = -0.054999999701976776f - _87;
    float _89 = _88 + _86;
    float _90 = _89 * _81;
    float _91 = _90 + _87;
    bool _92 = (_67 > 0.0031308000907301903f);
    float _93 = float((bool)_92);
    float _94 = abs(_67);
    float _95 = log2(_94);
    float _96 = _95 * 0.4166666567325592f;
    float _97 = exp2(_96);
    float _98 = _97 * 1.0549999475479126f;
    float _99 = _67 * 12.920000076293945f;
    float _100 = -0.054999999701976776f - _99;
    float _101 = _100 + _98;
    float _102 = _101 * _93;
    float _103 = _102 + _99;
    // Output is three encoded metering values: shadow, normal, highlight.
    ComputeLuminancesAndWeights_LuminancesUAV[int2((uint)(SV_DispatchThreadID.x), (uint)(SV_DispatchThreadID.y))] = float4(_79, _91, _103, 1.0f);
    bool _107 = (cbComputeLuminancesAndWeights.nType == 0);
    [branch]
    if (_107) {
      float _113 = cbComputeLuminancesAndWeights.fShadowsLerpEnd - cbComputeLuminancesAndWeights.fShadowsLerpStart;
      float _116 = cbComputeLuminancesAndWeights.fHighlightsLerpEnd - cbComputeLuminancesAndWeights.fHighlightsLerpStart;
      bool _117 = (_91 < cbComputeLuminancesAndWeights.fShadowsLerpStart);
      if (!_117) {
        bool _119 = (_91 < cbComputeLuminancesAndWeights.fShadowsLerpEnd);
        if (_119) {
          float _121 = _91 - cbComputeLuminancesAndWeights.fShadowsLerpStart;
          float _122 = 1.0f / _113;
          float _123 = _122 * _121;
          float _124 = 1.0f - _123;
          float _125 = saturate(_124);
          _127 = _125;
        } else {
          _127 = 0.0f;
        }
      } else {
        _127 = 1.0f;
      }
      bool _128 = (_91 > cbComputeLuminancesAndWeights.fHighlightsLerpEnd);
      if (!_128) {
        bool _130 = (_91 > cbComputeLuminancesAndWeights.fHighlightsLerpStart);
        if (_130) {
          float _132 = _91 - cbComputeLuminancesAndWeights.fHighlightsLerpStart;
          float _133 = 1.0f / _116;
          float _134 = _133 * _132;
          float _135 = saturate(_134);
          _137 = _135;
        } else {
          _137 = 0.0f;
        }
      } else {
        _137 = 1.0f;
      }
      float _138 = 1.0f - _127;
      float _139 = _138 - _137;
      _189 = _127;
      _190 = _139;
      _191 = _137;
    } else {
      bool _141 = (cbComputeLuminancesAndWeights.nType == 1);
      float _143 = _79 - cbComputeLuminancesAndWeights.fMidgrayTarget;
      float _144 = _91 - cbComputeLuminancesAndWeights.fMidgrayTarget;
      float _145 = _103 - cbComputeLuminancesAndWeights.fMidgrayTarget;
      if (_141) {
        float _148 = _143 * _143;
        float _149 = _148 * -0.7213475108146667f;
        float _150 = _149 * cbComputeLuminancesAndWeights.fWeightScale;
        float _151 = _144 * _144;
        float _152 = _151 * -0.7213475108146667f;
        float _153 = _152 * cbComputeLuminancesAndWeights.fWeightScale;
        float _154 = _145 * _145;
        float _155 = _154 * -0.7213475108146667f;
        float _156 = _155 * cbComputeLuminancesAndWeights.fWeightScale;
        float _157 = exp2(_150);
        float _158 = exp2(_153);
        float _159 = exp2(_156);
        _189 = _157;
        _190 = _158;
        _191 = _159;
      } else {
        float _162 = _143 + cbComputeLuminancesAndWeights.fMidgrayWidth;
        float _163 = cbComputeLuminancesAndWeights.fMidgrayTarget + -9.999999974752427e-07f;
        float _164 = min(_163, cbComputeLuminancesAndWeights.fMidgrayWidth);
        float _165 = cbComputeLuminancesAndWeights.fMidgrayTarget - _164;
        float _166 = _162 / _165;
        float _167 = max(0.0f, _166);
        float _168 = abs(_144);
        float _169 = _145 - cbComputeLuminancesAndWeights.fMidgrayWidth;
        float _170 = 1.0f - cbComputeLuminancesAndWeights.fMidgrayTarget;
        float _171 = 0.9999989867210388f - cbComputeLuminancesAndWeights.fMidgrayTarget;
        float _172 = min(_171, cbComputeLuminancesAndWeights.fMidgrayWidth);
        float _173 = _170 - _172;
        float _174 = _169 / _173;
        float _175 = min(0.0f, _174);
        float _176 = _167 * _167;
        float _177 = _176 * -0.7213475108146667f;
        float _178 = _177 * cbComputeLuminancesAndWeights.fWeightScale;
        float _179 = _168 * _168;
        float _180 = _179 * -0.7213475108146667f;
        float _181 = _180 * cbComputeLuminancesAndWeights.fWeightScale;
        float _182 = _175 * _175;
        float _183 = _182 * -0.7213475108146667f;
        float _184 = _183 * cbComputeLuminancesAndWeights.fWeightScale;
        float _185 = exp2(_178);
        float _186 = exp2(_181);
        float _187 = exp2(_184);
        _189 = _185;
        _190 = _186;
        _191 = _187;
      }
    }
    float _192 = dot(float3(_189, _190, _191), float3(1.0f, 1.0f, 1.0f));
    float _193 = _192 + 9.999999747378752e-06f;
    float _194 = _189 / _193;
    float _195 = _190 / _193;
    float _196 = _191 / _193;
    // These normalized weights tell the exposure debug/composite path how much
    // each shadow/midtone/highlight bucket should contribute for this pixel.
    ComputeLuminancesAndWeights_WeightsUAV[int2((uint)(SV_DispatchThreadID.x), (uint)(SV_DispatchThreadID.y))] = float4(_194, _195, _196, 1.0f);
  }
}
