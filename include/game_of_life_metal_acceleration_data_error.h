#ifndef __game_of_life_metal_acceleration_data_error_h
#define __game_of_life_metal_acceleration_data_error_h

#define game_of_life_metal_acceleration_data_error_length 0x05

enum game_of_life_metal_acceleration_data_error {
  game_of_life_metal_acceleration_data_error_none                    = 0x00,
  game_of_life_metal_acceleration_data_error_create_metal_device     = 0x01,
  game_of_life_metal_acceleration_data_error_create_library          = 0x02,
  game_of_life_metal_acceleration_data_error_create_function_compute = 0x03,
  game_of_life_metal_acceleration_data_error_create_pipeline         = 0x04,
  game_of_life_metal_acceleration_data_error_create_command_queue    = 0x05,
  game_of_life_metal_acceleration_data_error_create_buffer           = 0x06
};

extern const char* game_of_life_metal_acceleration_data_error_description[
  game_of_life_metal_acceleration_data_error_length
];

void game_of_life_metal_acceleration_data_error_print(
  enum game_of_life_metal_acceleration_data_error
);

#endif
