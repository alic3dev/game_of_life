#ifndef __game_of_life_3d_on_initialize_h
#define __game_of_life_3d_on_initialize_h

#include <metil_rendering/rendering_properties.h>

#include <Metal/MTLDevice.h>

void game_of_life_3d_on_initialize(
  id<MTLDevice> metil_metal_kit_device,
  struct metil_rendering_properties* metil_rendering_properties,
  void*
);

#endif
