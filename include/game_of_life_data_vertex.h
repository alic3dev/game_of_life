#include <math_c_vector.h>

struct game_of_life_data_vertex {
  float4 position [[position]];
  float brightness;
  struct math_c_vector4_float color;
  float rotation_color;
};
