#ifndef __game_of_life_h
#define __game_of_life_h

#if rendering_mode == 2
#include <game_of_life_parameters.h>

#include <cexil.h>

#if with_metal == 1
#include <game_of_life_metal_acceleration_data.h>
#endif
#endif

int main(
  int,
  const char**
);

#if rendering_mode == 2
void game_of_life_destroy(
  struct cexil_renderer*,
  struct game_of_life_parameters*,
  char**
  #if with_metal == 1
  ,
  struct game_of_life_metal_acceleration_data*
  #endif
);
#endif

#endif
