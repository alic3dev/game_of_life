#ifndef __game_of_life_parameters_h
#define __game_of_life_parameters_h

#include <cexil.h>

struct game_of_life_parameters {
  struct cexil_size size_renderer;
  struct cexil_size size_offset;
  float rate_frames;
};

unsigned char game_of_life_parameters_parse(
  struct game_of_life_parameters*,
  int,
  char**
);

#endif
