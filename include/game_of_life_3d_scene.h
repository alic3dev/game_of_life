#ifndef __game_of_life_3d_scene_h
#define __game_of_life_3d_scene_h

#if with_metal == 1
#include <game_of_life_metal_acceleration_data.h>
#endif
#include <game_of_life_parameters.h>

#include <metil.h>
#include <metil_scenes/metil_scene.h>

#include <rand_result.h>
#include <rand_source.h>

#include <CoreAudio/CoreAudio.h>
#include <Metal/MTLDevice.h>

struct game_of_life_3d_scene_data {
  #if with_metal == 1
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data;
  #else
  char** cells;
  char** cells_next;
  #endif

  unsigned int length_cells;

  unsigned long int frame;

  unsigned int index_audio;

  struct game_of_life_parameters* game_of_life_parameters;

  struct rand_parameters rand_parameters;
  struct rand_result rand_result;
  struct rand_source rand_source;
};

void game_of_life_3d_scene_initialize(
  struct metil*,
  struct metil_scene*,
  struct game_of_life_parameters*
);

#if with_metal != 1
void game_of_life_generate_initial_generation(
  struct game_of_life_3d_scene_data*
);
#endif

void game_of_life_3d_scene_poll(
  struct metil*,
  struct metil_scene*
);

void game_of_life_3d_scene_destroy(
  struct metil*,
  struct metil_scene*
);

OSStatus game_of_life_3d_scene_io_proc(
  AudioObjectID,
  const AudioTimeStamp*,
  const AudioBufferList*,
  const AudioTimeStamp*,
  AudioBufferList*,
  const AudioTimeStamp*,
  void*
);

#endif
