struct S_cbHDRResolve {
  float4 vParams;
  float4 mContentToMonitor[3];
};

Texture2D<float4> mapTPC0 : register(t0);

cbuffer _cbHDRResolve : register(b5) {
  S_cbHDRResolve cbHDRResolve : packoffset(c000.x);
};

struct OutputSignature {
  float4 SV_Target : SV_Target;
  float4 SV_Target_1 : SV_Target1;
};

OutputSignature main(
    noperspective float4 SV_Position : SV_Position
) {
  float4 SV_Target;
  float4 SV_Target_1;

  float4 _9 = mapTPC0.Load(int3((uint)(uint(SV_Position.x)), (uint)(uint(SV_Position.y)), 0));
  float _24 = cbHDRResolve.vParams.z * (pow(_9.x, 2.200000047683716f));
  float _25 = cbHDRResolve.vParams.z * (pow(_9.y, 2.200000047683716f));
  float _26 = cbHDRResolve.vParams.z * (pow(_9.z, 2.200000047683716f));

  float _49 = exp2(log2(abs(cbHDRResolve.vParams.y * mad(0.04331306740641594f, _26, mad(0.3292830288410187f, _25, (_24 * 0.6274039149284363f))))) * 0.1593017578125f);
  float _50 = exp2(log2(abs(cbHDRResolve.vParams.y * mad(0.011362316086888313f, _26, mad(0.9195404052734375f, _25, (_24 * 0.06909728795289993f))))) * 0.1593017578125f);
  float _51 = exp2(log2(abs(cbHDRResolve.vParams.y * mad(0.8955952525138855f, _26, mad(0.08801330626010895f, _25, (_24 * 0.016391439363360405f))))) * 0.1593017578125f);

  float _73 = exp2(log2(((_49 * 18.8515625f) + 0.8359375f) / ((_49 * 18.6875f) + 1.0f)) * 78.84375f);
  float _74 = exp2(log2(((_50 * 18.8515625f) + 0.8359375f) / ((_50 * 18.6875f) + 1.0f)) * 78.84375f);
  float _75 = exp2(log2(((_51 * 18.8515625f) + 0.8359375f) / ((_51 * 18.6875f) + 1.0f)) * 78.84375f);

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
