// 0x994EDE88 - ResolveHistogramCS
// HDR adaptation pass. This reads the scattered/atomic histogram from the
// previous pass and packs it into 16 float4 bins normalized by viewport area.
// It does not tonemap scene color; it prepares exposure statistics.

Texture2D<uint> srvScatteredHistogramInput : register(t0);

RWTexture2D<float4> uavHistogramOutput : register(u0);

cbuffer _cbHDRAdaptationSample : register(b5) {
  struct S_cbHDRAdaptationSample {
    float2 vExposureMeteringSize;
    uint2 viViewportSize;
    float2 invViewportSize;
    uint _pad_0;
    uint _pad_1;
  } cbHDRAdaptationSample : packoffset(c000.x);
};

[numthreads(64, 1, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  float _9 = cbHDRAdaptationSample.invViewportSize.x * cbHDRAdaptationSample.invViewportSize.y;
  bool _10 = ((uint)(uint)(SV_GroupThreadID.x) < (uint)16);
  if (_10) {
    uint _13 = (uint)(SV_GroupThreadID.x) << 3;
    uint _15 = srvScatteredHistogramInput.Load(int3(_13, 0, 0));
    int _17 = _13 | 2;
    uint _18 = srvScatteredHistogramInput.Load(int3(_17, 0, 0));
    int _20 = _13 | 4;
    uint _21 = srvScatteredHistogramInput.Load(int3(_20, 0, 0));
    int _23 = _13 | 6;
    uint _24 = srvScatteredHistogramInput.Load(int3(_23, 0, 0));
    int _26 = _13 | 1;
    uint _27 = srvScatteredHistogramInput.Load(int3(_26, 0, 0));
    int _29 = _13 | 3;
    uint _30 = srvScatteredHistogramInput.Load(int3(_29, 0, 0));
    int _32 = _13 | 5;
    uint _33 = srvScatteredHistogramInput.Load(int3(_32, 0, 0));
    int _35 = _13 | 7;
    uint _36 = srvScatteredHistogramInput.Load(int3(_35, 0, 0));
    float _38 = float((uint)(int)(_15.x));
    float _39 = _38 * 1.9073486328125e-06f;
    float _40 = float((uint)(int)(_27.x));
    float _41 = _40 * 8192.0f;
    float _42 = _41 + _39;
    float _43 = float((uint)(int)(_18.x));
    float _44 = _43 * 1.9073486328125e-06f;
    float _45 = float((uint)(int)(_30.x));
    float _46 = _45 * 8192.0f;
    float _47 = _46 + _44;
    float _48 = float((uint)(int)(_21.x));
    float _49 = _48 * 1.9073486328125e-06f;
    float _50 = float((uint)(int)(_33.x));
    float _51 = _50 * 8192.0f;
    float _52 = _51 + _49;
    float _53 = float((uint)(int)(_24.x));
    float _54 = _53 * 1.9073486328125e-06f;
    float _55 = float((uint)(int)(_36.x));
    float _56 = _55 * 8192.0f;
    float _57 = _56 + _54;
    float _58 = _42 * _9;
    float _59 = _47 * _9;
    float _60 = _52 * _9;
    float _61 = _57 * _9;
    uavHistogramOutput[int2((uint)(SV_GroupThreadID.x), 0)] = float4(_58, _59, _60, _61);
  }
}
