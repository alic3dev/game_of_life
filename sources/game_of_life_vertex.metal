#include <game_of_life_data_vertex.h>

#include <math_c_absolute.h>
#include <math_c_maximum.h>
#include <math_c_modulus.h>

#include <metil_rendering/metil_renderer_data_frame.h>
#include <metil_rendering/metil_renderer_data_object.h>
#include <metil_rendering/metil_renderer_vertex_index_parameter.h>

vertex game_of_life_data_vertex game_of_life_3d_vertex(
  const device simd_float4* vertices [[
    buffer(
      metil_renderer_vertex_index_parameter_vertices
    )
  ]],
  constant struct metil_renderer_data_frame& data_frame [[
    buffer(
      metil_renderer_vertex_index_parameter_data_frame
    )
  ]],
  constant struct metil_renderer_data_object& data_object [[
    buffer(
      metil_renderer_vertex_index_parameter_data_object
    )
  ]],
  unsigned int index_vertex [[
    vertex_id
  ]]
) {
  game_of_life_data_vertex game_of_life_data_vertex;

  game_of_life_data_vertex.position = (
    data_object.view_model_matrix_projection *
    vertices[
      index_vertex
    ]
  );

  game_of_life_data_vertex.brightness = (
    (
      (float)
      (
        (
          index_vertex +
          0x01
        ) %
        0x08
      )
    ) /
    0x0a +
    0.3f
  );

  game_of_life_data_vertex.rotation_colour = (
    math_c_modulus_float(
      (
        (
          math_c_absolute_float(
            data_object.position.x +
            0x01
          ) *
          math_c_absolute_float(
            data_object.position.y +
            0x01
          ) *
          (float)
          data_frame.frame /
          0x0a
        ) +
        0xc8
      ),
      0x64
    ) /
    0xa
  );

  game_of_life_data_vertex.colour.x = (
    math_c_modulus_float(
      data_object.position.x,
      0x01
    )
  );

  game_of_life_data_vertex.colour.y = (
    math_c_modulus_float(
      math_c_absolute_float(
        data_frame.frame +
        data_object.position.x +
        data_object.position.y
      ),
      0x64
    ) /
    0x64
  );

  game_of_life_data_vertex.colour.z = (
    math_c_modulus_float(
      (
        data_object.position.x *
        data_object.position.x
      ),
      0x01
    )
  );

  game_of_life_data_vertex.colour.w = (
    0x01 -
    (
      (
        data_object.position.z -
        0x64
      ) /
      13.5f
    )
  );

  return (
    game_of_life_data_vertex
  );
}
