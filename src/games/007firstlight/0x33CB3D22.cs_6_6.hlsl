// 0x33CB3D22 - PostChainMergeHDR_T3_CS
// Minimal live replacement for debugging raw scene-referred HDR.
//
// This intentionally bypasses the game's full post-chain merge, LUT/color
// correction, vignette, fade, bloom/glare, and RenoDX tonemapping.
//
// It writes scene color through a simple Neutwo-style soft clip. The game's
// final PQ resolve still runs afterwards.

Texture2D<float4> mapLinearLightTexture : register(t0);
RWTexture2D<float4> uavOutput1 : register(u0);

static const float RAW_SCALE = 1.0f;   // Temporary exposure gain for raw scene-referred testing.
static const float NEUTWO_PEAK = 8.85f;  // Tuned from 12.0 -> 2982 nits; targets ~2200 nits after final resolve.

float3 NeutwoTonemap(float3 x, float peak) {
  return (peak * x) * rsqrt((x * x) + (peak * peak));
}

[numthreads(8, 8, 1)]
void main(uint3 dispatch_thread_id : SV_DispatchThreadID) {
  uint2 pixel = dispatch_thread_id.xy;

  float4 scene_color = mapLinearLightTexture.Load(int3(pixel, 0));
  float3 exposed_color = max(scene_color.rgb * RAW_SCALE, 0.0f);
  float3 output_color = NeutwoTonemap(exposed_color, NEUTWO_PEAK);

  uavOutput1[pixel] = float4(output_color, 1.0f);
}
