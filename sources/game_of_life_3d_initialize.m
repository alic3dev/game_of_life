#include <game_of_life_3d_initialize.h>

#include <game_of_life_3d_on_initialize.h>
#include <game_of_life_parameters.h>

#include <metil_initialize.h>

int game_of_life_3d_initialize(
  int length_parameters,
  const char** parameters,
  struct game_of_life_parameters game_of_life_parameters
) {
  return metil_initialize_with_data(
    length_parameters,
    parameters,
    "game_of_life",
    game_of_life_3d_on_initialize,
    &game_of_life_parameters
  );
}
