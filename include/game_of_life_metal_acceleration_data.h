#ifndef __game_of_life_metal_acceleration_data_h
#define __game_of_life_metal_acceleration_data_h

#include <game_of_life_metal_acceleration_data_error.h>

struct game_of_life_metal_acceleration_data {
  void* metal_device;
  void* library;
  void* function_compute;
  void* pipeline_state_compute;
  enum game_of_life_metal_acceleration_data_error error;
};

#endif
