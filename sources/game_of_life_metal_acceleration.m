#include <game_of_life_metal_acceleration.h>

#include <game_of_life_metal_acceleration_data.h>

#include <Metal/MTLDevice.h>
// #include <Metal/MTLFunction.h>
#include <Metal/MTLLibrary.h>

void game_of_life_metal_acceleration_initialize(
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data
) {
  game_of_life_metal_acceleration_data->error = (
    game_of_life_metal_acceleration_data_error_none
  );

  if (
    game_of_life_metal_acceleration_data->metal_device == (void*)0
  ) {
    game_of_life_metal_acceleration_data->metal_device = MTLCreateSystemDefaultDevice();

    if (
      game_of_life_metal_acceleration_data->metal_device == (void*)0
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_metal_device
      );

      return;
    }
  }

  if (
    game_of_life_metal_acceleration_data->library == (void*)0
  ) {
    game_of_life_metal_acceleration_data->library = [
      (id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device newDefaultLibrary
    ];

    if (
      game_of_life_metal_acceleration_data->library == (void*)0
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_library
      );

      return;
    }
  }

  if (
    game_of_life_metal_acceleration_data->function_compute == (void*)0
  ) {
    game_of_life_metal_acceleration_data->function_compute = [
      (id<MTLLibrary>) game_of_life_metal_acceleration_data->library 
      newFunctionWithName: @"game_of_life_compute"
    ];

    if (
      game_of_life_metal_acceleration_data->function_compute == (void*)0
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_function_compute
      );

      return;
    }
  }

  if (
    game_of_life_metal_acceleration_data->pipeline_state_compute == (void*)0
  ) {
    NSError* error = (void*)0;

    game_of_life_metal_acceleration_data->pipeline_state_compute = [
      (id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device
      newComputePipelineStateWithFunction: (id<MTLFunction>) game_of_life_metal_acceleration_data->function_compute
      error: &error
    ];

    if (error != (void*)0) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_pipeline
      );
    }

    [error release];
  }
}

void game_of_life_metal_acceleration_destroy(
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data
) {
  #if rendering_mode == 2
  if (game_of_life_metal_acceleration_data->function_compute != (void*)0) {
    [(id<MTLFunction>) game_of_life_metal_acceleration_data->function_compute release];
  }

  if (game_of_life_metal_acceleration_data->library != (void*)0) {
    [(id<MTLLibrary>) game_of_life_metal_acceleration_data->library release];
  }

  if (game_of_life_metal_acceleration_data->metal_device != (void*)0) {
    [(id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device release];
  }
  #endif
}
