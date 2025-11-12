#ifndef __game_of_life_metal_acceleration_data_h
#define __game_of_life_metal_acceleration_data_h

#include <game_of_life_metal_acceleration_data_error.h>

#include <rand_parameters.h>
#include <rand_result.h>
#include <rand_source.h>

struct game_of_life_metal_acceleration_data {
  void* metal_device;
  void* library;
  void* function_compute;
  void* pipeline_state_compute;
  void* command_queue;
  void* buffer_cells;
  void* buffer_cells_next;
  void* buffer_living_neighbors;
  void* buffer_size;

  char* cells;
  char* living_neighbors;

  struct rand_parameters* rand_parameters;
  struct rand_result* rand_result;
  struct rand_source* rand_source;

  enum game_of_life_metal_acceleration_data_error error;
};

#endif
