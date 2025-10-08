#include <game_of_life_output_vertex.h>

fragment float4 game_of_life_3d_fragment(
  game_of_life_output_vertex in [[stage_in]]
) {
  return in.color;
}
