#ifndef __game_of_life_3d_scene_h
#define __game_of_life_3d_scene_h

#include <game_of_life_parameters.h>

#include <metil_scenes/scene.h>

#include <CoreAudio/CoreAudio.h>
#include <Metal/MTLDevice.h>

struct game_of_life_3d_scene_data {
  char** cells;
  char** cells_next;

  struct game_of_life_parameters* game_of_life_parameters;
};

void game_of_life_3d_scene_initialize(
  struct metil_scene*,
  id<MTLDevice>,
  struct game_of_life_parameters*
);

void game_of_life_3d_scene_poll(
  struct metil_scene*
);

void game_of_life_3d_scene_destroy(
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
