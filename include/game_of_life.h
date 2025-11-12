#ifndef __game_of_life_h
#define __game_of_life_h

#if rendering_mode == 2
#include <game_of_life_parameters.h>

#if with_metal == 1
#include <game_of_life_metal_acceleration_data.h>
#endif

#include <cexil.h>

#include <rand_result.h>
#include <rand_source.h>
#endif

int main(
  int,
  const char**
);

#if rendering_mode == 2
#if with_metal != 1
void game_of_life_generate_initial_generation(
  struct game_of_life_parameters*,
  char**,
  struct rand_parameters*,
  struct rand_result*,
  struct rand_source*
);
#endif

void game_of_life_destroy(
  struct cexil_renderer*,
  struct game_of_life_parameters*,
  #if with_metal == 1
  struct game_of_life_metal_acceleration_data*,
  #else
  char**,
  #endif
  struct rand_result*,
  struct rand_source*
);
#endif

#endif
