#include <game_of_life_parameters.h>

#if rendering_mode == 2
#include <cexil.h>
#endif

#include <clic3.h>

#include <stdio.h>

const char message_parameter_already_set[] = "parameter->{%s}.already_set\n";

unsigned char game_of_life_parameters_parse(
  struct game_of_life_parameters* game_of_life_parameters,
  int length_parameters,
  const char** parameters
) {
  #if rendering_mode == 2
  struct cexil_size size_renderer;
  
  cexil_size_set_to_terminal(
    &size_renderer
  );

  game_of_life_parameters->size.x = size_renderer.width;
  game_of_life_parameters->size.y = size_renderer.height;
  #else
  game_of_life_parameters->size.x = 300;
  game_of_life_parameters->size.y = 200;
  #endif

  game_of_life_parameters->offset.x = 0;
  game_of_life_parameters->offset.y = 0;

  #if rendering_mode == 2
  game_of_life_parameters->rate_frames = 60.0f;
  #elif rendering_mode == 3
  game_of_life_parameters->audio = 0;
  game_of_life_parameters->fps_display = 0;
  game_of_life_parameters->rate_poll = 0;
  #endif

  unsigned char has_set_size_x = 0;
  unsigned char has_set_size_y = 0;

  #if rendering_mode == 2
  unsigned char has_set_frame_rate = 0;
  #elif rendering_mode == 3
  unsigned char has_set_rate_poll = 0;
  #endif

  for (
    unsigned int index_parameter = 1;
    index_parameter < length_parameters;
    ++index_parameter
  ) {
    int index_parameter_supplied = clic3_char_arrays_within(
      (char*) parameters[index_parameter],
      #if rendering_mode == 2
      5,
      #elif rendering_mode == 3
      6,
      #endif
      "--size-x",
      "--size-y",
      "--help"
      #if rendering_mode == 2
      ,
      "--frame-rate"
      #elif rendering_mode == 3
      ,
      "--audio",
      "--fps-display",
      "--rate-poll"
      #endif
    );

    if (
      index_parameter_supplied != -1 &&
      index_parameter_supplied != 2 &&
      #if rendering_mode == 3
      index_parameter_supplied != 3 &&
      index_parameter_supplied != 4 &&
      #endif
      (index_parameter + 1) >= length_parameters
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
          (char*) parameters[index_parameter],
          &game_of_life_parameters->size.x
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
          (char*) parameters[index_parameter],
          &game_of_life_parameters->size.y
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

        #if rendering_mode == 2
        game_of_life_parameters->size.y = (
          game_of_life_parameters->size.y - (
            game_of_life_parameters->size.y % 4
          )
        );
        #endif
        break;
      }
      case 2: {
        game_of_life_parameters->help = 1;

        return 0;
      }
      #if rendering_mode == 2
      case 3: {
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
          (char*) parameters[index_parameter],
          &game_of_life_parameters->rate_frames
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
      #elif rendering_mode == 3
      case 3: {
        if (
          game_of_life_parameters->audio == 1
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[index_parameter]
          );

          return 1;
        }

        game_of_life_parameters->audio = 1;
        break;
      }
      case 4: {
        if (
          game_of_life_parameters->fps_display == 1
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[index_parameter]
          );

          return 1;
        }

        game_of_life_parameters->fps_display = 1;
        break;
      }
      case 5: {
        if (
          has_set_rate_poll == 1
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
 
        unsigned char status_unsigned_int_conversion = clic3_char_array_to_unsigned_int(
          (char*) parameters[index_parameter],
          &game_of_life_parameters->rate_poll
        );

        if (
          status_unsigned_int_conversion != 0
        ) {
          fprintf(
            stderr,
            "invalid_rate_poll->{%s}\n",
            parameters[index_parameter]
          );

          return 1;
        }
        break;
      }
      #endif
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
