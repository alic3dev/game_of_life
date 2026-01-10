#include <game_of_life_data_vertex.h>

#include <metal_stdlib>

fragment float4 game_of_life_3d_fragment(
  game_of_life_data_vertex game_of_life_data_vertex [[stage_in]]
) {
  return float4(
    metal::fmax(
      0.1, (
        1.0f - metal::fmod(
          metal::fabs(
            game_of_life_data_vertex.rotation_color
          ),
          1.0f
        )
      ) *
      game_of_life_data_vertex.color.x
    ) * (
      game_of_life_data_vertex.brightness
    ),
    metal::fmax(
      0.1, (
        1.0f - metal::fmod(
          metal::fabs(
            game_of_life_data_vertex.rotation_color -
            5.0f
          ),
          1.0f
        )
      ) *
      game_of_life_data_vertex.color.y
    ) * (
      game_of_life_data_vertex.brightness
    ),
    metal::fmax(
      0.1, (
        1.0f - metal::fmod(
          metal::fabs(
            game_of_life_data_vertex.rotation_color -
            10.0f
          ), 
          1.0f
        )
      ) *
      game_of_life_data_vertex.color.z
    ) * (
      game_of_life_data_vertex.brightness
    ),
    game_of_life_data_vertex.color.w
  );
}
