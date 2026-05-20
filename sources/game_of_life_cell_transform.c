#include <game_of_life_cell_transform.h>

unsigned char game_of_life_cell_transform(
  unsigned char cell
) {
  return (
    (
      (
        cell %
        0x0a
      ) <
      0x08
    )
    ? 0x00
    : 0x01
  );
}
