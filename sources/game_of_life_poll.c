#include <game_of_life_poll.h>

#include <clic3_bytes.h>

void game_of_life_poll(
  struct game_of_life_parameters* game_of_life_parameters,
  char** cells,
  char** cells_next
) {
  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters->size.y;
    ++index_y
  ) {
    for (
      unsigned int index_x = 0;
      index_x < game_of_life_parameters->size.x;
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
            index_neighbour_y >= game_of_life_parameters->size.y ||
            index_neighbour_x >= game_of_life_parameters->size.x
          ) {
            continue;
          }

          if (
            cells[index_neighbour_y][index_neighbour_x] == 1
          ) {
            living_neighbors = (
              living_neighbors + 1
            );
          }
        }
      }

      if (
        (cells[index_y][index_x] == 1 && living_neighbors == 2) ||
        living_neighbors == 3
      ) {
        cells_next[index_y][index_x] = 1;
      } else {
        cells_next[index_y][index_x] = 0;
      }
    }
  }

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters->size.y;
    ++index_y
  ) {
    clic3_bytes_copy(
      cells[index_y],
      cells_next[index_y], (
        sizeof(unsigned char) *
        game_of_life_parameters->size.x
      )
    );
  }
}
