#include <game_of_life_data_vertex.h>

#include <math_c_absolute.h>
#include <math_c_maximum.h>
#include <math_c_modulus.h>

fragment float4 game_of_life_3d_fragment(
  game_of_life_data_vertex game_of_life_data_vertex [[
    stage_in
  ]]
) {
  return float4(
    (
      math_c_maximum_float(
        0.1f,
        (
          (
            0x01 -
            math_c_modulus_float(
              math_c_absolute_float(
                game_of_life_data_vertex.rotation_colour
              ),
              0x01
            )
          ) *
          game_of_life_data_vertex.colour.x
        )
      ) *
      game_of_life_data_vertex.brightness
    ),
    (
      math_c_maximum_float(
        0.1,
        (
          0x01 -
          math_c_modulus_float(
            math_c_absolute_float(
              game_of_life_data_vertex.rotation_colour -
              0x05
            ),
            0x01
          )
        ) *
        game_of_life_data_vertex.colour.y
      ) *
      game_of_life_data_vertex.brightness
    ),
    (
      math_c_maximum_float(
        0.1f,
        (
          0x01 -
          math_c_modulus_float(
            math_c_absolute_float(
              game_of_life_data_vertex.rotation_colour -
              0x0a
            ),
            0x01
          )
        ) *
        game_of_life_data_vertex.colour.z
      ) *
      game_of_life_data_vertex.brightness
    ),
    game_of_life_data_vertex.colour.w
  );
}
