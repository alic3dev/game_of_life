#include <game_of_life_print_usage.h>

#include <clic3_memory.h>

#include <stdio.h>

void game_of_life_print_usage(
  const char* name,
  unsigned char to_error_stream
) {
  FILE* stream_output = (
    (
      to_error_stream !=
      0x00
    )
    ? stderr
    : stdout
  );

  char* basename = (
    0x00
  );

  unsigned int length_basename = (
    0x00
  );
  
  unsigned int index_basename = (
    0x00
  );

  while (
    name[
      length_basename
    ] !=
    '\0'
  ) {
    length_basename = (
      length_basename +
      0x01
    );
  }

  index_basename = (
    length_basename
  );

  while (
    (
      name[
        index_basename
      ] !=
      '/'
    ) &&
    (
      index_basename !=
      0x00
    )
  ) {
    index_basename = (
      index_basename -
      0x01
    );
  }

  if (
    name[
      index_basename
    ] ==
    '/'
  ) {
    index_basename = (
      index_basename +
      0x01
    );
  }

  length_basename = (
    length_basename -
    index_basename +
    0x01
  );

  basename = (
    clic3_memory_allocate_raw(
      length_basename
    )
  );

  for (
    unsigned int index_character_basename = (
      0x00
    );
    (
      index_character_basename <
      length_basename
    );
    ++index_character_basename
  ) {
    basename[
      index_character_basename
    ] = (
      name[
        index_basename +
        index_character_basename
      ]
    );
  }

  fprintf(
    stream_output,
    "usage: %s\n"
    "  --help                          : prints this usage information\n"
    "  --lock-to-generation [#integer] : regenerates and displays only a single generation\n"
    "  --size-x [#integer]             : sets the cell grid width\n"
    "  --size-y [#integer]             : sets the cell grid height\n"
    #if rendering_mode == 2
    "  --frame-rate [#integer]         : sets the frame rate\n"
    #elif rendering_mode == 3
    "  --audio                         : enables audio output from buffered cell grid\n"
    "  --fps-display                   : enables the frames per second display\n"
    "  --rate-poll [#integer]          : sets the rate in frames at which the cell grid is polled\n"
    #endif
    ,
    basename
  );

  clic3_memory_free_raw(
    basename
  );
}
