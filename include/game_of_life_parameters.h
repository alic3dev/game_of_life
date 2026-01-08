#ifndef __game_of_life_parameters_h
#define __game_of_life_parameters_h

#include <math_c_vector.h>

struct game_of_life_parameters {
  unsigned int lock_to_generation;

  struct math_c_vector2_unsigned_int size;
  struct math_c_vector2_unsigned_int offset;

  unsigned char help;

  #if rendering_mode == 2
  float rate_frames;
  #elif rendering_mode == 3
  unsigned char audio;
  unsigned char fps_display;
  unsigned int rate_poll;
  #endif
};

unsigned char game_of_life_parameters_parse(
  struct game_of_life_parameters*,
  int,
  const char**
);

#endif
