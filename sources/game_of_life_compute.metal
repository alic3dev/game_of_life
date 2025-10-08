kernel void game_of_life_compute(
  device const char* cells,
  device char* cells_next,
  uint index [[thread_position_in_grid]]
) {
  cells_next[index] = cells[index];
}
