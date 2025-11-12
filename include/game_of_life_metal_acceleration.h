#ifndef __game_of_life_metal_acceleration_h
#define __game_of_life_metal_acceleration_h

#include <game_of_life_metal_acceleration_data.h>
#include <game_of_life_parameters.h>

#include <rand_result.h>

void game_of_life_metal_acceleration_initialize(
  struct game_of_life_metal_acceleration_data*,
  struct game_of_life_parameters*
);

void game_of_life_generate_initial_generation(
  struct game_of_life_metal_acceleration_data*
);

void game_of_life_metal_acceleration_compute(
  struct game_of_life_metal_acceleration_data*,
  struct game_of_life_parameters*
);

void game_of_life_metal_acceleration_destroy(
  struct game_of_life_metal_acceleration_data*
);

#endif
