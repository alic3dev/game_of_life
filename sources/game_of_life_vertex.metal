#include <game_of_life_data_vertex.h>

#include <metil_rendering/metil_renderer_data_frame.h>
#include <metil_rendering/metil_renderer_data_object.h>
#include <metil_rendering/metil_renderer_vertex_index_parameter.h>

#include <metal_stdlib>

vertex game_of_life_data_vertex game_of_life_3d_vertex(
  const device simd_float4* vertices [[buffer(
    metil_renderer_vertex_index_parameter_vertices
  )]],
  constant struct metil_renderer_data_frame& data_frame [[buffer(
    metil_renderer_vertex_index_parameter_data_frame
  )]],
  constant struct metil_renderer_data_object& data_object [[buffer(
    metil_renderer_vertex_index_parameter_data_object
  )]],
  unsigned int id_vertex [[vertex_id]]
) {
  game_of_life_data_vertex game_of_life_data_vertex;

  game_of_life_data_vertex.position = (
    data_object.view_model_matrix_projection *
    vertices[
      id_vertex
    ]
  );

  game_of_life_data_vertex.brightness = (
    ((float) (
      (id_vertex + 1) % 8
    )) /
    10.0f +
    0.3f
  );

  game_of_life_data_vertex.rotation_color = (
    metal::fmod(
      (
        (
          metal::fabs(
            data_object.position.x +
            1.0f
          ) *
          metal::fabs(
            data_object.position.y + 
            1.0f
          ) *
          (float) data_frame.frame /
          10.0f
        ) + 
        200.0f
      ),
      100.0f
    )
    / 10.0f
  );

  game_of_life_data_vertex.color.r = (
    metal::fmod(
      data_object.position.x,
      1.0f
    )
  );

  game_of_life_data_vertex.color.g = (
    metal::fmod(
      metal::fabs(
        data_frame.frame +
        data_object.position.x +
        data_object.position.y
      ),
      100.0f
    ) / 100.0f
  );

  game_of_life_data_vertex.color.b = (
    metal::fmod(
      (
        data_object.position.x *
        data_object.position.x
      ),
      1.0f
    )
  );

  game_of_life_data_vertex.color.a = (
    1.0f -
    (
      (
        data_object.position.z -
        100.0f
      ) /
      13.5f
    )
  );

  return game_of_life_data_vertex;
}
