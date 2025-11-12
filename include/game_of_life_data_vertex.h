#include <clic3_vector.h>

struct game_of_life_data_vertex {
  float4 position [[position]];
  float brightness;
  struct clic3_vector4_float color;
  float rotation_color;
};
