#include <game_of_life_metal_acceleration_data_error.h>

#include <stdio.h>

const char* game_of_life_metal_acceleration_data_error_description[
  game_of_life_metal_acceleration_data_error_length
] = {
  "error:none",
  "error:create_metal_device",
  "error:create_library",
  "error:create_function_compute",
  "error:create_pipeline"
};

void game_of_life_metal_acceleration_data_error_print(
  enum game_of_life_metal_acceleration_data_error game_of_life_metal_acceleration_data_error
) {
  fprintf(
    stderr,
    "%s\n",
    game_of_life_metal_acceleration_data_error_description[
      game_of_life_metal_acceleration_data_error
    ]
  );
}
