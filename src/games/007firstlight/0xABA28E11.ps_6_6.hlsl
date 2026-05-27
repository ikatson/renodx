struct S_cbHDRResolve {
  // x is unused here. y and z are scale factors used before PQ encoding.
  // The game feeds these through the HDR resolve constant buffer.
  float4 vParams;
  // Present in the original constant buffer layout, but this decompile does
  // not use it directly. The color conversion matrix below is inlined.
  float4 mContentToMonitor[3];
};

// Full-resolution HDR scene/color buffer. In the captured draw this was an
// r16g16b16a16_float texture, sampled with integer pixel coordinates.
Texture2D<float4> mapTPC0 : register(t0);

cbuffer _cbHDRResolve : register(b5) {
  S_cbHDRResolve cbHDRResolve : packoffset(c000.x);
};

// The draw writes two outputs:
//   SV_Target   -> r10g10b10a2_unorm fake swapchain buffer
//   SV_Target_1 -> r16g16b16a16_float side/output target
struct OutputSignature {
  float4 SV_Target : SV_Target;
  float4 SV_Target_1 : SV_Target1;
};

OutputSignature main(
    noperspective float4 SV_Position : SV_Position
) {
  float4 SV_Target;
  float4 SV_Target_1;

  // Load the HDR input at the current output pixel. This is a fullscreen pass,
  // so SV_Position.xy maps directly to texel coordinates.
  float4 _9 = mapTPC0.Load(int3((uint)(uint(SV_Position.x)), (uint)(uint(SV_Position.y)), 0));

  // Apply the game's final exposure/range scale. The upstream replacement now
  // writes linear HDR values, so do not apply the original 2.2 decode here.
  float _24 = cbHDRResolve.vParams.z * _9.x;
  float _25 = cbHDRResolve.vParams.z * _9.y;
  float _26 = cbHDRResolve.vParams.z * _9.z;

  // Convert linear RGB into a monitor/output color space before PQ encoding.
  // These coefficients match the shape of a BT.2020/PQ output transform:
  //   R' = 0.6274 R + 0.3293 G + 0.0433 B
  //   G' = 0.0691 R + 0.9195 G + 0.0114 B
  //   B' = 0.0164 R + 0.0880 G + 0.8956 B
  //
  // The exponent 0.1593017578125 is ST.2084/PQ m1. Keep this pass as a
  // pure PQ encoder: floor invalid negative values, but do not hard-cap the
  // top end. Highlight limiting should come from the upstream tonemap shader.
  float pq_input_r = max(cbHDRResolve.vParams.y * mad(0.04331306740641594f, _26, mad(0.3292830288410187f, _25, (_24 * 0.6274039149284363f))), 0.0f);
  float pq_input_g = max(cbHDRResolve.vParams.y * mad(0.011362316086888313f, _26, mad(0.9195404052734375f, _25, (_24 * 0.06909728795289993f))), 0.0f);
  float pq_input_b = max(cbHDRResolve.vParams.y * mad(0.8955952525138855f, _26, mad(0.08801330626010895f, _25, (_24 * 0.016391439363360405f))), 0.0f);

  float _49 = exp2(log2(pq_input_r) * 0.1593017578125f);
  float _50 = exp2(log2(pq_input_g) * 0.1593017578125f);
  float _51 = exp2(log2(pq_input_b) * 0.1593017578125f);

  // Finish ST.2084/PQ encoding:
  //   ((c1 + c2 * L^m1) / (1 + c3 * L^m1)) ^ m2
  //
  // Constants:
  //   c1 = 0.8359375
  //   c2 = 18.8515625
  //   c3 = 18.6875
  //   m2 = 78.84375
  //
  // The result is PQ-encoded RGB for HDR10-style output.
  float _73 = exp2(log2(((_49 * 18.8515625f) + 0.8359375f) / ((_49 * 18.6875f) + 1.0f)) * 78.84375f);
  float _74 = exp2(log2(((_50 * 18.8515625f) + 0.8359375f) / ((_50 * 18.6875f) + 1.0f)) * 78.84375f);
  float _75 = exp2(log2(((_51 * 18.8515625f) + 0.8359375f) / ((_51 * 18.6875f) + 1.0f)) * 78.84375f);

  // Write the same PQ color to both render targets.
  SV_Target.x = _73;
  SV_Target.y = _74;
  SV_Target.z = _75;
  SV_Target.w = 1.0f;

  SV_Target_1.x = _73;
  SV_Target_1.y = _74;
  SV_Target_1.z = _75;
  SV_Target_1.w = 1.0f;

  OutputSignature output_signature = {SV_Target, SV_Target_1};
  return output_signature;
}
