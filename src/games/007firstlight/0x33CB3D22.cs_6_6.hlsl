// 0x33CB3D22 - PostChainMergeHDR_T3_CS
// Minimal live replacement for debugging the HDR path with RenoDX tonemapping.
//
// This intentionally bypasses the game's full post-chain merge, LUT/color
// correction, vignette, and fade. It uses RenoDX's standard tonemap config on
// the raw HDR scene color, then lets the game's final PQ resolve encode it.
//
// Display target is hardcoded for the current TV: 2200 nits.

#include "./shared.h"

Texture2D<float4> mapLinearLightTexture : register(t0);
RWTexture2D<float4> uavOutput1 : register(u0);

static const float TARGET_PEAK_NITS = 2200.0f;

float3 ApplyRenoToneMap(float3 color) {
  renodx::tonemap::Config config = renodx::tonemap::config::Create();
  config.type = renodx::tonemap::config::type::RENODRT;
  config.peak_nits = TARGET_PEAK_NITS;
  config.game_nits = RENODX_DIFFUSE_WHITE_NITS;
  config.gamma_correction = 0.0f;
  config.exposure = RENODX_TONE_MAP_EXPOSURE;
  config.highlights = RENODX_TONE_MAP_HIGHLIGHTS;
  config.shadows = RENODX_TONE_MAP_SHADOWS;
  config.contrast = RENODX_TONE_MAP_CONTRAST;
  config.saturation = RENODX_TONE_MAP_SATURATION;
  config.mid_gray_value = 0.18f;
  config.mid_gray_nits = 18.0f;
  config.reno_drt_dechroma = RENODX_TONE_MAP_BLOWOUT;
  config.reno_drt_flare = 0.10f * pow(RENODX_TONE_MAP_FLARE, 10.0f);
  config.reno_drt_hue_correction_method = (uint)RENODX_TONE_MAP_HUE_PROCESSOR;
  config.reno_drt_tone_map_method = renodx::tonemap::renodrt::config::tone_map_method::HERMITE_SPLINE;
  config.reno_drt_working_color_space = (uint)RENODX_TONE_MAP_WORKING_COLOR_SPACE;
  config.reno_drt_per_channel = RENODX_TONE_MAP_PER_CHANNEL != 0.0f;
  config.reno_drt_blowout = RENODX_TONE_MAP_BLOWOUT;
  config.reno_drt_clamp_color_space = RENODX_TONE_MAP_CLAMP_COLOR_SPACE;
  config.reno_drt_clamp_peak = RENODX_TONE_MAP_CLAMP_PEAK;
  config.reno_drt_white_clip = TARGET_PEAK_NITS / RENODX_DIFFUSE_WHITE_NITS;

  return renodx::tonemap::config::Apply(max(color, 0.0f), config);
}

[numthreads(8, 8, 1)]
void main(uint3 dispatch_thread_id : SV_DispatchThreadID) {
  uint2 pixel = dispatch_thread_id.xy;

  float4 scene_color = mapLinearLightTexture.Load(int3(pixel, 0));
  float3 output_color = ApplyRenoToneMap(scene_color.rgb);

  uavOutput1[pixel] = float4(output_color, 1.0f);
}
