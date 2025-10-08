#include <game_of_life_output_vertex.h>

#include <metil_shader_types.h>

#include <metal_stdlib>

vertex game_of_life_output_vertex game_of_life_3d_vertex(
  const device simd_float4* positions [[buffer(metil_kit_vertex_input_index_positions)]],
  constant metil_kit_data_frame& data_frame [[buffer(metil_kit_vertex_input_index_frame_data)]],
  constant metil_kit_data_frame_object& data [[buffer(metil_kit_vertex_input_index_data)]],
  unsigned int id_vertex [[vertex_id]]
) {
  game_of_life_output_vertex out;

  out.position = data.view_model_matrix_projection * positions[id_vertex];

  float brightness = (
    (((float) ((id_vertex + 1) % 8)) / 10.0f) + 
    0.3f
  );

  float position = metal::fmod(data.position.x + data.position.y + ((float) data_frame.frame / 10.0f) + 200.0f, 100.0f) / 10.0f;

  out.color = float4(
    metal::fmax(0.1, (1.0f - metal::fmod(metal::fabs(position - 0.0f), 1.0f))) * data.color.x * brightness,
    metal::fmax(0.1, (1.0f - metal::fmod(metal::fabs(position - 5.0f), 1.0f))) * data.color.y * brightness,
    metal::fmax(0.1, (1.0f - metal::fmod(metal::fabs(position - 10.0f), 1.0f))) * data.color.z * brightness,
    data.color.w
  );

  return out;
}
