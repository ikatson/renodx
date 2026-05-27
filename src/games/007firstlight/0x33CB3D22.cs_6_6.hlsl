// 0x33CB3D22 - PostChainMergeHDR_T3_CS
// Minimal live replacement for debugging the HDR path.
//
// This intentionally bypasses the game's post-chain merge, LUT/color
// correction, vignette, and fade. It applies a small debug exposure plus a
// simple soft shoulder so the image is viewable while still proving that this
// stage can output unclamped HDR.
//
// Tweak DEBUG_EXPOSURE first. If highlights dominate, lower SHOULDER_STRENGTH
// or MAX_OUTPUT. This does not use display peak yet; it is only a control/proof
// shader.

Texture2D<float4> mapLinearLightTexture : register(t0);
RWTexture2D<float4> uavOutput1 : register(u0);

static const float DEBUG_EXPOSURE = 2.0f;
static const float SHOULDER_START = 1.0f;
static const float SHOULDER_STRENGTH = 0.35f;
static const float MAX_OUTPUT = 4.0f;

float3 ApplyDebugShoulder(float3 color) {
  float peak = max(max(color.r, color.g), color.b);
  if (peak <= SHOULDER_START) {
    return color;
  }

  float compressed_peak = SHOULDER_START + ((peak - SHOULDER_START) / (1.0f + ((peak - SHOULDER_START) * SHOULDER_STRENGTH)));
  compressed_peak = min(compressed_peak, MAX_OUTPUT);

  return color * (compressed_peak / max(peak, 1e-6f));
}

[numthreads(8, 8, 1)]
void main(uint3 dispatch_thread_id : SV_DispatchThreadID) {
  uint2 pixel = dispatch_thread_id.xy;

  float4 scene_color = mapLinearLightTexture.Load(int3(pixel, 0));
  float3 debug_color = max(scene_color.rgb * DEBUG_EXPOSURE, 0.0f);
  debug_color = ApplyDebugShoulder(debug_color);

  uavOutput1[pixel] = float4(debug_color, 1.0f);
}
