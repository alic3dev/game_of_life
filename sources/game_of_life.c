#include <game_of_life.h>

#if rendering_mode == 3
#include <game_of_life_3d_initialize.h>
#endif
#if rendering_mode == 2
#if with_metal == 1
#include <game_of_life_metal_acceleration.h>
#include <game_of_life_metal_acceleration_data.h>
#else
#include <game_of_life_cell_transform.h>
#endif
#endif

#include <game_of_life_parameters.h>
#include <game_of_life_print_usage.h>
#include <game_of_life_poll.h>

#if rendering_mode == 2
#include <cexil.h>

#if with_metal == 1
#include <clic3_bytes.h>
#endif

#include <interrupt_handler.h>

#include <rand_clean.h>
#include <rand_functions.h>
#include <rand_initialize.h>
#include <rand_mode.h>
#include <rand_parameters.h>
#include <rand_result.h>
#include <rand_source.h>
#include <rand_source_type.h>
#endif

#include <stdlib.h>

#if rendering_mode == 3
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
    game_of_life_print_usage(
      parameters[0],
      1
    );

    return 1;
  }

  if (
    game_of_life_parameters.help == 1
  ) {
    game_of_life_print_usage(
      parameters[0],
      0
    );

    return 0;
  }

  return game_of_life_3d_initialize(
    length_parameters,
    parameters,
    game_of_life_parameters
  );
}

#elif rendering_mode == 2
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
    game_of_life_print_usage(
      parameters[0],
      1
    );

    return 1;
  }

  if (
    game_of_life_parameters.help == 1
  ) {
    game_of_life_print_usage(
      parameters[0],
      0
    );

    return 0;
  }

  interrupt_handler_initialize();

  struct cexil_renderer renderer;
  struct math_c_vector2_unsigned_int size_renderer = {
    .x = game_of_life_parameters.size.x,
    .y = game_of_life_parameters.size.y
  };

  cexil_renderer_initialize(
    &renderer,
    &size_renderer
  );

  cexil_renderer_target_frame_rate_set(
    &renderer,
    game_of_life_parameters.rate_frames
  );

  struct rand_parameters rand_parameters;
  struct rand_result rand_result;
  struct rand_source rand_source;

  rand_initialize(
    &rand_parameters,
    &rand_result,
    &rand_source, (
      game_of_life_parameters.size.y *
      game_of_life_parameters.size.x
    ),
    rand_mode_bytes,
    rand_source_type_divisive
  );

  #if with_metal == 1
  struct game_of_life_metal_acceleration_data game_of_life_metal_acceleration_data = {
    .metal_device = (void*)0,
    .library = (void*)0,
    .function_compute = (void*)0,
    .pipeline_state_compute = (void*)0,
    .error = game_of_life_metal_acceleration_data_error_none,
    .rand_parameters = &rand_parameters,
    .rand_result = &rand_result,
    .rand_source = &rand_source
  };

  game_of_life_metal_acceleration_initialize(
    &game_of_life_metal_acceleration_data,
    &game_of_life_parameters
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
      &game_of_life_metal_acceleration_data,
      &rand_result,
      &rand_source
    );
  }

  unsigned long int length_cells = (
    game_of_life_parameters.size.x *
    game_of_life_parameters.size.y
  );
  #else
  game_of_life_generate_initial_generation(
    &game_of_life_parameters,
    renderer.pixels,
    &rand_parameters,
    &rand_result,
    &rand_source
  );

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
  #endif

  unsigned int count_generations = (
    game_of_life_parameters.lock_to_generation
    ? game_of_life_parameters.lock_to_generation - 1
    : 1
  );
  unsigned char first_render = 1;

  while (interrupt_handler_interrupted == 0) {
    #if with_metal == 1
    for (
      unsigned long int index_cell = 0;
      index_cell < length_cells;
      index_cell = (
        index_cell +
        game_of_life_parameters.size.x
      )
    ) {
      clic3_bytes_copy(
        renderer.pixels[index_cell / game_of_life_parameters.size.x],
        game_of_life_metal_acceleration_data.cells + index_cell, (
          sizeof(unsigned char) *
          game_of_life_parameters.size.x
        )
      );
    }
    #endif

    if (
      game_of_life_parameters.lock_to_generation < 2 ||
      first_render == 0
    ) {
      cexil_renderer_render(
        &renderer
      );
    }

    if (
      game_of_life_parameters.lock_to_generation != 0
    ) {
      #if with_metal == 1
      game_of_life_generate_initial_generation(
        &game_of_life_metal_acceleration_data
      );
      #else
      game_of_life_generate_initial_generation(
        &game_of_life_parameters,
        renderer.pixels,
        &rand_parameters,
        &rand_result,
        &rand_source
      );
      #endif
    }

    #if with_metal == 1
    game_of_life_metal_acceleration_compute(
      &game_of_life_metal_acceleration_data,
      &game_of_life_parameters
    );

    #else
    for (
      unsigned int index_generated_generation = 0;
      index_generated_generation < count_generations;
      ++index_generated_generation
    ) {
      game_of_life_poll(
        &game_of_life_parameters,
        renderer.pixels,
        cells_next
      );
    }
    #endif

    first_render = 0;
  }

  game_of_life_destroy(
    &renderer,
    &game_of_life_parameters,
    #if with_metal == 1
    &game_of_life_metal_acceleration_data,
    #else
    cells_next,
    #endif
    &rand_result,
    &rand_source
  );

  return 0;
}

#if rendering_mode == 2
#if with_metal != 1
void game_of_life_generate_initial_generation(
  struct game_of_life_parameters* game_of_life_parameters,
  char** cells,
  struct rand_parameters* rand_parameters,
  struct rand_result* rand_result,
  struct rand_source* rand_source
) {
  rand_clean(
    rand_result,
    rand_source
  );

  rand_initialize(
    rand_parameters,
    rand_result,
    rand_source,
    (
      game_of_life_parameters->size.y *
      game_of_life_parameters->size.x
    ),
    rand_mode_bytes,
    rand_source_type_divisive
  );

  rand_get(
    rand_source,
    rand_result,
    rand_parameters
  );

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters->size.y;
    ++index_y
  ) {
    unsigned long int offset_y = (
      index_y *
      game_of_life_parameters->size.x
    );

    for (
      unsigned int index_x = 0;
      index_x < game_of_life_parameters->size.x;
      ++index_x
    ) {
      cells[
        index_y
      ][
        index_x
      ] = game_of_life_cell_transform(
        rand_result->bytes[
          offset_y +
          index_x
        ]
      );
    }
  }
}
#endif
#endif

void game_of_life_destroy(
  struct cexil_renderer* renderer,
  struct game_of_life_parameters* game_of_life_parameters,
  #if with_metal == 1
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data,
  #else
  char** cells_next,
  #endif
  struct rand_result* rand_result,
  struct rand_source* rand_source
) {
  cexil_renderer_destroy(
    renderer
  );

  #if with_metal == 1
  game_of_life_metal_acceleration_destroy(
    game_of_life_metal_acceleration_data
  );
  #else
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
  #endif

  rand_clean(
    rand_result,
    rand_source
  );
}

#endif
