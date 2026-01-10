#include <math_c_vector.h>

struct game_of_life_data_vertex {
  float4 position [[position]];
  float brightness;
  float4 color;
  float rotation_color;
};
