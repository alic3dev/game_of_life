#include <game_of_life_cell_transform.h>

unsigned char game_of_life_cell_transform(
  unsigned char cell
) {
  return (
    (cell % 10) < 8
    ? 0
    : 1
  );
}
