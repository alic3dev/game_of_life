#include <game_of_life_output_vertex.h>

#include <metil_shader_types.h>

vertex game_of_life_output_vertex game_of_life_3d_vertex(
  const device simd_float4* positions [[buffer(metil_kit_vertex_input_index_positions)]],
  constant metil_kit_data_frame& data_frame [[buffer(metil_kit_vertex_input_index_frame_data)]],
  constant metil_kit_data_frame_object& data [[buffer(metil_kit_vertex_input_index_data)]],
  unsigned int id_vertex [[vertex_id]]
) {
  game_of_life_output_vertex out;

  out.position = data.view_model_matrix_projection * positions[id_vertex];

  out.color = float4(
    data.color.x,
    data.color.y,
    data.color.z,
    data.color.w
  );

  return out;
}
