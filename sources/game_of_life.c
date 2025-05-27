#include <game_of_life.h>

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <cexil.h>
#include <interrupt_handler.h>

int main() {
  interrupt_handler_initialize();

  srand(time((void*)0));

  struct cexil_size size_bounding_area;

  cexil_size_set_to_terminal(
    &size_bounding_area
  );

  struct cexil_renderer renderer;

  cexil_renderer_initialize(
    &renderer,
    &size_bounding_area
  );

  cexil_renderer_target_frame_rate_set(
    &renderer,
    60.0f
  );

  for (
    unsigned int index_y = 0;
    index_y < renderer.size.height;
    ++index_y
  ) {
    for (
      unsigned int index_x = 0;
      index_x < renderer.size.width;
      ++index_x
    ) {
      renderer.pixels[index_y][index_x] = (
        rand() % 10 > 7 ? 1 : 0
      );
    }
  }

  char** pixels_next = malloc(
    sizeof(unsigned char*) *
    renderer.size.height
  );

  unsigned int size_y_malloc = (
    sizeof(unsigned char) *
    renderer.size.width
  );

  for (
    unsigned int index_y = 0;
    index_y < renderer.size.height;
    ++index_y
  ) {
    pixels_next[index_y] = malloc(size_y_malloc);
  }

  while (interrupt_handler_interrupted == 0) {
    cexil_renderer_render(&renderer);

    for (
      unsigned int index_y = 0;
      index_y < renderer.size.height;
      ++index_y
    ) {
      for (
        unsigned int index_x = 0;
        index_x < renderer.size.width;
        ++index_x
      ) {
        unsigned int living_neighbors = 0;
        
        for (
          unsigned int index_neighbour_y = index_y == 0 ? 1 : index_y - 1;
          index_neighbour_y < index_y + 2;
          ++index_neighbour_y
        ) {
          for (
            unsigned int index_neighbour_x = index_x == 0 ? 1 : index_x - 1;
            index_neighbour_x < index_x + 2;
            ++index_neighbour_x
          ) {
            if (
              (index_neighbour_y == index_y && index_neighbour_x == index_x) ||
              index_neighbour_y >= renderer.size.height ||
              index_neighbour_x >= renderer.size.width
            ) {
              continue;
            }

            if (renderer.pixels[index_neighbour_y][index_neighbour_x] == 1) {
              living_neighbors = (
                living_neighbors + 1
              );
            }
          }
        }

        if (
          (renderer.pixels[index_y][index_x] == 1 && living_neighbors == 2) || 
          living_neighbors == 3
        ) {
          pixels_next[index_y][index_x] = 1;
        } else {
          pixels_next[index_y][index_x] = 0;
        }
      }
    }

    for (
      unsigned int index_y = 0;
      index_y < renderer.size.height;
      ++index_y
    ) {
      memcpy(
        renderer.pixels[index_y],
        pixels_next[index_y],
        size_y_malloc
      );
    }
  }

  cexil_renderer_destroy(&renderer);

  return 0;
}
