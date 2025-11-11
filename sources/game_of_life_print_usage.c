#include <game_of_life_print_usage.h>

#include <stdio.h>
#include <stdlib.h>

void game_of_life_print_usage(
  const char* name,
  unsigned char to_error_stream
) {
  FILE* stream_output = (
    to_error_stream
    ? stderr
    : stdout
  );

  char* basename = (
    (void*)0
  );

  unsigned int length_basename = 0;
  unsigned int index_basename = 0;

  while (
    name[
      length_basename
    ] != '\0'
  ) {
    length_basename = (
      length_basename + 1
    );
  }

  index_basename = length_basename;

  while (
    name[
      index_basename
    ] != '/' &&
    index_basename != 0
  ) {
    index_basename = (
      index_basename - 1
    );
  }

  if (
    name[
      index_basename
    ] == '/'
  ) {
    index_basename = (
      index_basename +
      1
    );
  }

  length_basename = (
    length_basename -
    index_basename +
    1
  );

  basename = malloc(
    sizeof(char) *
    length_basename
  );

  for (
    unsigned int index_character_basename = 0;
    index_character_basename < length_basename;
    ++index_character_basename
  ) {
    basename[
      index_character_basename
    ] = name[
      index_basename +
      index_character_basename
    ];
  }

  fprintf(
    stream_output,
    "usage: %s\n"
    "  --help                  : prints this usage information\n"
    "  --size-x [#integer]     : sets the cell grid width\n"
    "  --size-y [#integer]     : sets the cell grid height\n"
    #if rendering_mode == 2
    "  --frame-rate [#integer] : sets the frame rate\n"
    #elif rendering_mode == 3
    "  --audio                 : enables audio output from buffered cell grid\n"
    "  --fps-display           : enables the frames per second display\n"
    "  --rate-poll [#integer]  : sets the rate in frames at which the cell grid is polled\n"
    #endif
    ,
    basename
  );

  free(basename);
}
