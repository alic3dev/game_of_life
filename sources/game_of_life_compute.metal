kernel void game_of_life_compute(
  device const char* cells,
  device char* cells_next,
  device char* cells_living_neighbors,
  constant unsigned long int size[3],
  uint index [[thread_position_in_grid]]
) {
  unsigned long int index_x = index % size[0];
  unsigned long int index_y = index / size[0];

  unsigned char living_neighbors = 0;
  
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
        index_neighbour_y >= size[1] ||
        index_neighbour_x >= size[0]
      ) {
        continue;
      }

      unsigned long int index_neighbour = (
        index_neighbour_y * size[0] +
        index_neighbour_x
      );

      if (cells[index_neighbour] != 0) {
        living_neighbors = (
          living_neighbors + 1
        );
      }
    }
  }

  if (
    (cells[index] == 1 && living_neighbors == 2) || 
    living_neighbors == 3
  ) {
    cells_next[index] = 1;
  } else {
    cells_next[index] = 0;
  }

  cells_living_neighbors[index] = living_neighbors;
}
