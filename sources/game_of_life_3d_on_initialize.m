#include <game_of_life_3d_on_initialize.h>

#include <game_of_life_3d_scene.h>
#include <game_of_life_parameters.h>

#include <metil_library.h>
#include <metil_scenes/metil_scene_controller.h>

#include <Metal/MTLDevice.h>

void game_of_life_3d_on_initialize(
  struct metil* metil,
  void* data
) {
  struct game_of_life_parameters* game_of_life_parameters = (
    (struct game_of_life_parameters*) data
  );

  metil_library_initialize(
    &metil->library,
    metil->renderer_interface.metal_device,
    @"game_of_life_3d_fragment",
    @"game_of_life_3d_vertex"
  );

  metil->rendering_properties.fps_display = (
    game_of_life_parameters->fps_display
  );

  metil->rendering_properties.camera.height = 0.0f;

  struct metil_scene_controller* scene_controller = (
    metil->scene_controller
  );

  game_of_life_3d_scene_initialize(
    metil,
    &scene_controller->scene,
    game_of_life_parameters
  );
}
