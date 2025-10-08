#include <game_of_life_3d_on_initialize.h>

#include <game_of_life_3d_scene.h>
#include <game_of_life_parameters.h>

#include <metil_library.h>
#include <metil_rendering/rendering_properties.h>
#include <metil_scenes/scene_controller.h>

#include <Metal/MTLDevice.h>

void game_of_life_3d_on_initialize(
  id<MTLDevice> metal_kit_device,
  struct metil_rendering_properties* metil_rendering_properties,
  void* data
) {
  struct game_of_life_parameters* game_of_life_parameters = (
    (struct game_of_life_parameters*) data
  );

  metil_library.library = [metal_kit_device newDefaultLibrary];

  metil_library.function_vertex = [
    metil_library.library
    newFunctionWithName: @"game_of_life_3d_vertex"
  ];

  metil_library.function_fragment = [
    metil_library.library
    newFunctionWithName: @"game_of_life_3d_fragment"
  ];

  metil_library.library_fps_display = [metal_kit_device newDefaultLibrary];

  metil_library.function_vertex_fps_display = [
    metil_library.library
    newFunctionWithName: @"metil_fps_display_vertex"
  ];

  metil_library.function_fragment_fps_display = [
    metil_library.library
    newFunctionWithName: @"metil_fps_display_fragment"
  ];

  metil_rendering_properties->color_clear.x = 0.0;
  metil_rendering_properties->color_clear.y = 0.0f;
  metil_rendering_properties->color_clear.z = 0.0f;
  metil_rendering_properties->color_clear.w = 1.0f;

  metil_rendering_properties->camera.height = 0.0f;

  game_of_life_3d_scene_initialize(
    &metil_scene_controller.scene,
    metal_kit_device,
    game_of_life_parameters
  );
}
