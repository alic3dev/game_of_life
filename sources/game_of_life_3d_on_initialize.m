#include <game_of_life_3d_on_initialize.h>

#include <game_of_life_3d_scene.h>
#include <game_of_life_parameters.h>

#include <metil_library.h>
#include <metil_rendering/rendering_properties.h>
#include <metil_scenes/scene_controller.h>

#include <Metal/MTLDevice.h>

void game_of_life_3d_on_initialize(
  struct metil_renderer_interface* metil_renderer_interface,
  void* data
) {
  struct game_of_life_parameters* game_of_life_parameters = (
    (struct game_of_life_parameters*) data
  );

  metil_library_initialize(
    metil_renderer_interface->metal_device,
    @"game_of_life_3d_fragment",
    @"game_of_life_3d_vertex"
  );

  metil_renderer_interface->rendering_properties->camera.height = 0.0f;

  game_of_life_3d_scene_initialize(
    &metil_scene_controller.scene,
    metil_renderer_interface->metal_device,
    game_of_life_parameters
  );
}
