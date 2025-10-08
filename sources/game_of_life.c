#include <game_of_life.h>

#include <game_of_life_parameters.h>
#include <game_of_life_poll.h>

#if rendering_mode == 3

#include <game_of_life_3d_initialize.h>

int main(
  int length_parameters,
  const char** parameters
) {
  struct game_of_life_parameters game_of_life_parameters;

  unsigned char status_game_of_life_parameters_parse = game_of_life_parameters_parse(
    &game_of_life_parameters,
    length_parameters,
    parameters
  );

  if (
    status_game_of_life_parameters_parse != 0
  ) {
    return 1;
  }

  return game_of_life_3d_initialize(
    length_parameters,
    parameters,
    game_of_life_parameters
  );
}

#elif rendering_mode == 2
#if with_metal == 1
#include <game_of_life_metal_acceleration.h>
#include <game_of_life_metal_acceleration_data.h>
#endif

#include <cexil.h>
#include <interrupt_handler.h>

#include <stdlib.h>
#include <time.h>

int main(
  int length_parameters,
  const char** parameters
) {
  struct game_of_life_parameters game_of_life_parameters;

  unsigned char status_game_of_life_parameters_parse = game_of_life_parameters_parse(
    &game_of_life_parameters,
    length_parameters,
    parameters
  );

  if (
    status_game_of_life_parameters_parse != 0
  ) {
    return 1;
  }

  interrupt_handler_initialize();

  srand(
    time(
      (void*)0
    )
  );

  struct cexil_renderer renderer;
  struct cexil_size size_renderer = {
    .width = game_of_life_parameters.size.x,
    .height = game_of_life_parameters.size.y
  };

  cexil_renderer_initialize(
    &renderer,
    &size_renderer
  );

  cexil_renderer_target_frame_rate_set(
    &renderer,
    game_of_life_parameters.rate_frames
  );

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters.size.y;
    ++index_y
  ) {
    for (
      unsigned int index_x = 0;
      index_x < game_of_life_parameters.size.x;
      ++index_x
    ) {
      renderer.pixels[
        index_y
      ][
        index_x
      ] = (
        rand() % 10 > 7 ? 1 : 0
      );
    }
  }

  char** cells_next = malloc(
    sizeof(unsigned char*) *
    game_of_life_parameters.size.y
  );

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters.size.y;
    ++index_y
  ) {
    cells_next[
      index_y
    ] = malloc(
      sizeof(unsigned char) *
      game_of_life_parameters.size.x
    );
  }

  #if with_metal == 1
  struct game_of_life_metal_acceleration_data game_of_life_metal_acceleration_data = {
    .metal_device = (void*)0,
    .library = (void*)0,
    .function_compute = (void*)0,
    .pipeline_state_compute = (void*)0,
    .error = game_of_life_metal_acceleration_data_error_none
  };

  game_of_life_metal_acceleration_initialize(
    &game_of_life_metal_acceleration_data
  );

  if (
    game_of_life_metal_acceleration_data.error != game_of_life_metal_acceleration_data_error_none
  ) {
    game_of_life_metal_acceleration_data_error_print(
      game_of_life_metal_acceleration_data.error
    );

    return game_of_life_metal_acceleration_data.error;

    game_of_life_destroy(
      &renderer,
      &game_of_life_parameters,
      cells_next,
      &game_of_life_metal_acceleration_data
    );
  }
  #endif

  while (interrupt_handler_interrupted == 0) {
    cexil_renderer_render(
      &renderer
    );

    game_of_life_poll(
      &game_of_life_parameters,
      renderer.pixels,
      cells_next
    );
  }

  game_of_life_destroy(
    &renderer,
    &game_of_life_parameters,
    cells_next
    #if with_metal == 1
    ,
    &game_of_life_metal_acceleration_data
    #endif
  );

  return 0;
}

void game_of_life_destroy(
  struct cexil_renderer* renderer,
  struct game_of_life_parameters* game_of_life_parameters,
  char** cells_next
  #if with_metal == 1
  ,
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data
  #endif
) {
  cexil_renderer_destroy(
    renderer
  );

  #if with_metal == 1
  game_of_life_metal_acceleration_destroy(
    game_of_life_metal_acceleration_data
  );
  #endif

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters->size.y;
    ++index_y
  ) {
    free(
      cells_next[
        index_y
      ]
    );
  }

  free(
    cells_next
  );
}

#endif
