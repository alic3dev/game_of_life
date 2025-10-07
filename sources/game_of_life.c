#include <game_of_life.h>

#include <game_of_life_parameters.h>

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

  srand(time((void*)0));

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
      renderer.pixels[index_y][index_x] = (
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
    cells_next[index_y] = malloc(
      sizeof(unsigned char) *
      game_of_life_parameters.size.x
    );
  }

  while (interrupt_handler_interrupted == 0) {
    cexil_renderer_render(&renderer);

    game_of_life_poll(
      &game_of_life_parameters,
      renderer.pixels,
      cells_next
    );
  }

  cexil_renderer_destroy(&renderer);

  return 0;
}
