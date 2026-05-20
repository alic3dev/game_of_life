#include <game_of_life_parameters.h>

#if rendering_mode == 2
#include <cexil.h>
#endif

#include <clic3.h>

#include <math_c_vector.h>

#include <stdio.h>

const char message_parameter_already_set[] = "parameter->{%s}.already_set\n";

unsigned char game_of_life_parameters_parse(
  struct game_of_life_parameters* game_of_life_parameters,
  int length_parameters,
  const char** parameters
) {
  game_of_life_parameters->lock_to_generation = (
    0x00
  );
  
  game_of_life_parameters->help = (
    0x00
  );

  #if rendering_mode == 2
  struct math_c_vector2_unsigned_int size_renderer;

  cexil_size_set_to_terminal(
    &size_renderer
  );

  game_of_life_parameters->size.x = (
    size_renderer.x
  );
  
  game_of_life_parameters->size.y = (
    size_renderer.y
  );
  #else
  game_of_life_parameters->size.x = (
    0x012c
  );
  
  game_of_life_parameters->size.y = (
    0xc8
  );
  #endif

  game_of_life_parameters->offset.x = (
    0x00
  );
  
  game_of_life_parameters->offset.y = (
    0x00
  );

  #if rendering_mode == 2
  game_of_life_parameters->rate_frames = (
    0x3c
  );
  #elif rendering_mode == 3
  game_of_life_parameters->audio = (
    0x00
  );
  
  game_of_life_parameters->fps_display = (
    0x00
  );
  
  game_of_life_parameters->rate_poll = (
    0x00
  );
  #endif

  unsigned char has_set_lock_to_generation = (
    0x00
  );
  
  unsigned char has_set_size_x = (
    0x00
  );
  
  unsigned char has_set_size_y = (
    0x00
  );

  #if rendering_mode == 2
  unsigned char has_set_frame_rate = (
    0x00
  );
  #elif rendering_mode == 3
  unsigned char has_set_rate_poll = (
    0x00
  );
  #endif

  for (
    unsigned int index_parameter = (
      0x01
    );
    (
      index_parameter <
      length_parameters
    );
    ++index_parameter
  ) {
    int index_parameter_supplied = (
      clic3_char_arrays_within(
        (
          (char*)
          parameters[
            index_parameter
          ]
        ),
        #if rendering_mode == 2
        0x05,
        #elif rendering_mode == 3
        0x07,
        #endif
        "--size-x",
        "--size-y",
        "--help",
        "--lock-to-generation",
        #if rendering_mode == 2
        "--frame-rate"
        #elif rendering_mode == 3
        "--audio",
        "--fps-display",
        "--rate-poll"
        #endif
      )
    );

    if (
      (
        index_parameter_supplied !=
        -0x01
      ) &&
      (
        index_parameter_supplied !=
        0x02
      ) &&
      #if rendering_mode == 3
      (
        index_parameter_supplied !=
        0x04
      ) &&
      (
        index_parameter_supplied !=
        0x05
      ) &&
      #endif
      (
        (
          index_parameter +
          0x01
        ) >=
        length_parameters
      )
    ) {
      fprintf(
        stderr,
        "parameter[%s]->requires_value\n",
         parameters[
           index_parameter
         ]
      );

      return (
        0x01
      );
    }

    switch (
      index_parameter_supplied
    ) {
      case 0x00: {
        if (
          has_set_size_x ==
          0x01
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[
              index_parameter
            ]
          );
          
          return (
            0x01
          );
        }

        index_parameter = (
          index_parameter +
          0x01
        );

        unsigned char status_int_conversion = (
          clic3_char_array_to_unsigned_int(
            (
              (char*)
              parameters[
                index_parameter
              ]
            ),
            &game_of_life_parameters->size.x
          )
        );

        if (
          status_int_conversion !=
          0x00
        ) {
          fprintf(
            stderr,
            "invalid_size_x->{%s}\n",
            parameters[index_parameter]
          );

          return (
            0x01
          );
        }

        has_set_size_x = (
          0x01
        );

        break;
      }
      case 1: {
        if (
          has_set_size_y ==
          0x01
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[
              index_parameter
            ]
          );
          
          return (
            0x01
          );
        }

        index_parameter = (
          index_parameter +
          0x01
        );

        unsigned char status_int_conversion = (
          clic3_char_array_to_unsigned_int(
            (
              (char*)
              parameters[
                index_parameter
              ]
            ),
            &game_of_life_parameters->size.y
          )
        );

        if (
          status_int_conversion !=
          0x00
        ) {
          fprintf(
            stderr,
            "invalid_size_y->{%s}\n",
            parameters[
              index_parameter
            ]
          );
          
          return (
            0x01
          );
        }

        #if rendering_mode == 2
        game_of_life_parameters->size.y = (
          game_of_life_parameters->size.y -
          (
            game_of_life_parameters->size.y %
            0x04
          )
        );
        #endif

        has_set_size_y = (
          0x01
        );

        break;
      }
      case 2: {
        game_of_life_parameters->help = (
          0x01
        );

        return (
          0x00
        );
      }
      case 0x03: {
        if (
          has_set_lock_to_generation ==
          0x01
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[
              index_parameter
            ]
          );
          
          return (
            0x01
          );
        }

        index_parameter = (
          index_parameter +
          0x01
        );

        unsigned char status_int_conversion = (
          clic3_char_array_to_unsigned_int(
            (
              (char*)
              parameters[
                index_parameter
              ]
            ),
            &game_of_life_parameters->lock_to_generation
          )
        );

        if (
          (
            status_int_conversion !=
            0x00
          ) ||
          (
            game_of_life_parameters->lock_to_generation <
            0x01
          )
        ) {
          fprintf(
            stderr,
            "invalid_lock_to_generation->{%s}\n",
            parameters[
              index_parameter
            ]
          );

          return (
            0x01
          );
        }

        has_set_lock_to_generation = (
          0x01
        );
        
        break;
      }
      #if rendering_mode == 2
      case 0x04: {
        if (
          has_set_frame_rate ==
          0x01
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[
              index_parameter
            ]
          );

          return (
            0x01
          );
        }

        index_parameter = (
          index_parameter +
          0x01
        );

        unsigned char status_float_conversion = (
          clic3_char_array_to_float(
            (
              (char*)
              parameters[
                index_parameter
              ]
            ),
            &game_of_life_parameters->rate_frames
          )        );

        if (
          status_float_conversion !=
          0x00
        ) {
          fprintf(
            stderr,
            "invalid_frame_rate->{%s}\n",
            parameters[
              index_parameter
            ]
          );

          return (
            0x01
          );
        }

        has_set_frame_rate = (
          0x01
        );

        break;
      }
      #elif rendering_mode == 3
      case 0x04: {
        if (
          game_of_life_parameters->audio ==
          0x01
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[
              index_parameter
            ]
          );

          return (
            0x01
          );
        }

        game_of_life_parameters->audio = (
          0x01
        );
        
        break;
      }
      case 0x05: {
        if (
          game_of_life_parameters->fps_display ==
          0x01
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[
              index_parameter
            ]
          );

          return (
            0x01
          );
        }

        game_of_life_parameters->fps_display = (
          0x01
        );
        
        break;
      }
      case 0x06: {
        if (
          has_set_rate_poll ==
          0x01
        ) {
          fprintf(
            stderr,
            message_parameter_already_set,
            parameters[
              index_parameter
            ]
          );

          return (
            0x01
          );
        }

        index_parameter = (
          index_parameter +
          0x01
        );

        unsigned char status_unsigned_int_conversion = (
          clic3_char_array_to_unsigned_int(
            (
              (char*)
              parameters[
                index_parameter
              ]
            ),
            &game_of_life_parameters->rate_poll
          )
        );

        if (
          status_unsigned_int_conversion !=
          0x00
        ) {
          fprintf(
            stderr,
            "invalid_rate_poll->{%s}\n",
            parameters[
              index_parameter
            ]
          );

          return (
            0x01
          );
        }

        has_set_rate_poll = (
          0x01
        );

        break;
      }
      #endif
      default: {
        fprintf(
          stderr,
          "unknown_parameter->{%s}\n",
          parameters[
            index_parameter
          ]
        );

        return (
          0x01
        );
      }
    }
  }

  return (
    0x00
  );
}
