#include <gol_parameters.h>

#include <clic3.h>

#include <stdio.h>

const char message_parameter_already_set[] = "parameter->{%s}.already_set\n";

unsigned char gol_parameters_parse(
  struct gol_parameters* gol_parameters,
  int length_parameters,
  char** parameters
) {
  cexil_size_set_to_terminal(
    &gol_parameters->size_renderer
  );

  gol_parameters->size_offset.width = 0;
  gol_parameters->size_offset.height = 0;
  gol_parameters->rate_frames = 60.0f;

  unsigned char has_set_size_x = 0;
  unsigned char has_set_size_y = 0;
  unsigned char has_set_frame_rate = 0;

  for (
    unsigned int index_parameter = 1;
    index_parameter < length_parameters;
    ++index_parameter
  ) {
    int index_parameter_supplied = clic3_char_arrays_within(
      parameters[index_parameter],
      3,
      "--size-x",
      "--size-y",
      "--frame-rate"
    );

    if (
      index_parameter_supplied != -1 &&
      index_parameter + 1 >=
      length_parameters
    ) {
      fprintf(
        stderr,
        "parameter[%s]->requires_value\n",
         parameters[index_parameter]
      );

      return 1;
    }

    switch (index_parameter_supplied) {
      case 0: {
        if (
          has_set_size_x == 1
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[index_parameter]
          );
          return 1;
        }

        index_parameter = (
          index_parameter + 1
        );

        unsigned char status_int_conversion = clic3_char_array_to_unsigned_int(
          parameters[index_parameter],
          &gol_parameters->size_renderer.width
        );

        if (
          status_int_conversion != 0
        ) {
          fprintf(
            stderr,
            "invalid_size_x->{%s}\n",
            parameters[index_parameter]
          );

          return 1;
        }
        break;
      }
      case 1: {
        if (
          has_set_size_y == 1
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[index_parameter]
          );
          return 1;
        }

        index_parameter = (
          index_parameter + 1
        );

        unsigned char status_int_conversion = clic3_char_array_to_unsigned_int(
          parameters[index_parameter],
          &gol_parameters->size_renderer.height
        );

        if (
          status_int_conversion != 0
        ) {
          fprintf(
            stderr,
            "invalid_size_y->{%s}\n",
            parameters[index_parameter]
          );
          return 1;
        }
        break;
      }
      case 2: {
        if (
          has_set_frame_rate == 1
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[index_parameter]
          );

          return 1;
        }
        
        index_parameter = (
          index_parameter + 1
        );
 
        unsigned char status_float_conversion = clic3_char_array_to_float(
          parameters[index_parameter],
          &gol_parameters->rate_frames
        );

        if (
          status_float_conversion != 0
        ) {
          fprintf(
            stderr,
            "invalid_frame_rate->{%s}\n",
            parameters[index_parameter]
          );

          return 1;
        }
        break;
      }
      default: 
        fprintf(
          stderr,
          "unknown_parameter->{%s}\n",
          parameters[index_parameter]
        );

        return 1;
        break;
    }
  }

  return 0;
}

