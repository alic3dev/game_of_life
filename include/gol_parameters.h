#ifndef __gol_parameters_h
#define __gol_parameters_h

#include <cexil.h>

struct gol_parameters {
  struct cexil_size size_renderer;
  struct cexil_size size_offset;
  float rate_frames;
};

unsigned char gol_parameters_parse(
  struct gol_parameters*,
  int,
  char**
);

#endif

