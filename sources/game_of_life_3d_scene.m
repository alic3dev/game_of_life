#include <game_of_life_3d_scene.h>

#include <clic3_bytes.h>
#include <clic3_vector.h>

#include <metil_audio/audio.h>
#include <metil_debug/log.h>
#include <metil_mesh/mesh_box.h>
#include <metil_object.h>
#include <metil_scenes/scene.h>
#include <metil_shader_types.h>

#include <stdlib.h>

void game_of_life_3d_scene_initialize(
  struct metil_scene* scene,
  id<MTLDevice> metal_kit_device,
  struct game_of_life_parameters* game_of_life_parameters
) {
  metil_audio_io_proc_add(
    game_of_life_3d_scene_io_proc
  );

  metil_scene_initialize(
    scene,
    metal_kit_device
  );

  scene->type = metil_scene_type_game;
  scene->id = 0;

  scene->poll = game_of_life_3d_scene_poll;
  scene->destroy = game_of_life_3d_scene_destroy;

  scene->length_objects = (
    game_of_life_parameters->size.x *
    game_of_life_parameters->size.y
  );
  scene->objects = realloc(
    scene->objects,
    sizeof(struct metil_object*) *
    scene->length_objects
  );

  scene->data = malloc(
    sizeof(struct game_of_life_3d_scene_data)
  );

  struct game_of_life_3d_scene_data* game_of_life_3d_scene_data = (
    (struct game_of_life_3d_scene_data*) scene->data
  );

  game_of_life_3d_scene_data->cells = malloc(
    sizeof(unsigned char*) *
    game_of_life_parameters->size.y
  );

  game_of_life_3d_scene_data->cells_next = malloc(
    sizeof(unsigned char*) *
    game_of_life_parameters->size.y
  );

  game_of_life_3d_scene_data->game_of_life_parameters = game_of_life_parameters;

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters->size.y;
    ++index_y
  ) {
    game_of_life_3d_scene_data->cells[index_y] = malloc(
      sizeof(unsigned char) *
      game_of_life_parameters->size.x
    );

    game_of_life_3d_scene_data->cells_next[index_y] = malloc(
      sizeof(unsigned char) *
      game_of_life_parameters->size.x
    );
  }

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters->size.y;
    ++index_y
  ) {
    for (
      unsigned int index_x = 0;
      index_x < game_of_life_parameters->size.x;
      ++index_x
    ) {
      game_of_life_3d_scene_data->cells[index_y][index_x] = (
        rand() % 10 > 7 ? 1 : 0
      );
    }
  }

  for (
    unsigned int index_object = 0;
    index_object < scene->length_objects;
    ++index_object
  ) {
    unsigned int index_x = index_object % game_of_life_parameters->size.x;
    unsigned int index_y = index_object / game_of_life_parameters->size.x;

    scene->objects[index_object] = malloc(
      sizeof(struct metil_object)
    );
    
    metil_object_initialize(
      scene->objects[index_object]
    );

    if (
      index_object == 0
    ) {
      metil_mesh_box_initialize(
        &scene->objects[index_object]->mesh,
        (struct clic3_vector3_float) {
          .x = 1,
          .y = 1,
          .z = 1
        }
      );

      scene->objects[index_object]->vertices = [metal_kit_device
        newBufferWithBytes: scene->objects[index_object]->mesh.vertices
        length: scene->objects[index_object]->mesh.length_vertices * sizeof(struct clic3_vector4_float)
        options: MTLResourceStorageModeShared
      ];

      scene->objects[index_object]->indices = [metal_kit_device
        newBufferWithBytes: scene->objects[index_object]->mesh.indices
        length: scene->objects[index_object]->mesh.length_indices * sizeof(unsigned int)
        options: MTLResourceStorageModeShared
      ];
    } else {
      scene->objects[index_object]->mesh = scene->objects[0]->mesh;
      scene->objects[index_object]->vertices = scene->objects[0]->vertices;
      scene->objects[index_object]->indices = scene->objects[0]->indices;
    }

    scene->objects[index_object]->data = [metal_kit_device
      newBufferWithLength: sizeof(metil_kit_data_frame_object)
      options: MTLResourceStorageModeShared
    ];

    metil_kit_data_frame_object* data = scene->objects[
      index_object
    ]->data.contents;
    data->id = index_object;

    data->color.x = game_of_life_3d_scene_data->cells[index_y][index_x];
    data->color.y = game_of_life_3d_scene_data->cells[index_y][index_x];
    data->color.z = game_of_life_3d_scene_data->cells[index_y][index_x];
    data->color.w = 1.0f;

    scene->objects[index_object]->position.x = (float) index_x - (float) game_of_life_parameters->size.x / 2.0f;
    scene->objects[index_object]->position.y = (float) index_y - (float) game_of_life_parameters->size.y / 2.0f;
    scene->objects[index_object]->position.z = 10;
  }
}

void game_of_life_3d_scene_poll(
  struct metil_scene* scene
) {
  struct game_of_life_3d_scene_data* game_of_life_3d_scene_data = (
    (struct game_of_life_3d_scene_data*) scene->data
  );

  struct game_of_life_parameters* game_of_life_parameters = (
    (struct game_of_life_parameters*) game_of_life_3d_scene_data->game_of_life_parameters
  );

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters->size.y;
    ++index_y
  ) {
    unsigned int offset_y = index_y * game_of_life_parameters->size.x;

    for (
      unsigned int index_x = 0;
      index_x < game_of_life_parameters->size.x;
      ++index_x
    ) {
      unsigned int living_neighbors = 0;

      const unsigned int index_object = offset_y + index_x;
      
      for (
        unsigned int index_neighbour_y = index_y == 0 ? 1 : index_y - 1;
        index_neighbour_y < index_y + 2;
        ++index_neighbour_y
      ) {
        for (
          unsigned int index_neighbour_x = index_x == 0 ? 1 : index_x - 1;
          index_neighbour_x < index_x + 2;
          ++index_neighbour_x
        ) {
          if (
            (index_neighbour_y == index_y && index_neighbour_x == index_x) ||
            index_neighbour_y >= game_of_life_parameters->size.y ||
            index_neighbour_x >= game_of_life_parameters->size.x
          ) {
            continue;
          }

          if (
            game_of_life_3d_scene_data->cells[index_neighbour_y][index_neighbour_x] == 1
          ) {
            living_neighbors = (
              living_neighbors + 1
            );
          }
        }
      }

      metil_kit_data_frame_object* data = scene->objects[
        index_object
      ]->data.contents;

      if (
        (game_of_life_3d_scene_data->cells[index_y][index_x] == 1 && living_neighbors == 2) || 
        living_neighbors == 3
      ) {
        game_of_life_3d_scene_data->cells_next[index_y][index_x] = 1;

        scene->objects[
          index_object
        ]->position.z = 100.0f;

        data->color.x = (float) living_neighbors / 3.0f;
        data->color.y = (float) living_neighbors / 3.0f;
        data->color.z = (float) living_neighbors / 3.0f;
        data->color.w = 1.0f;
      } else {
        game_of_life_3d_scene_data->cells_next[index_y][index_x] = 0;

        data->color.x = (float) living_neighbors / 8.0f;
        data->color.y = (float) living_neighbors / 16.0f;
        data->color.z = (float) living_neighbors / 16.0f;

        scene->objects[
          index_object
        ]->position.z = (
          101.0f + 8.0f - living_neighbors
        );
      }
    }
  }

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_parameters->size.y;
    ++index_y
  ) {
    clic3_bytes_copy(
      game_of_life_3d_scene_data->cells[index_y],
      game_of_life_3d_scene_data->cells_next[index_y], (
        sizeof(unsigned char) *
        game_of_life_parameters->size.x
      )
    );
  }
}

void game_of_life_3d_scene_destroy(
  struct metil_scene* scene
) {
  metil_audio_io_proc_remove(
    game_of_life_3d_scene_io_proc
  );

  metil_mesh_destroy(&scene->objects[0]->mesh);

  [scene->objects[0]->indices release];
  [scene->objects[0]->vertices release];

  for (
    unsigned int index_object = 0;
    index_object < scene->length_objects;
    ++index_object
  ) {
    [scene->objects[index_object]->data release];
  }

  for (
    unsigned int index_object = 0;
    index_object < scene->length_objects;
    ++index_object
  ) {

    free(scene->objects[index_object]);
  }

  free(scene->objects);
  free(scene->textures);

  scene->player.destroy(
    &scene->player
  );

  free(scene->data);
}

OSStatus game_of_life_3d_scene_io_proc(
  AudioObjectID id_audio_object,
  const AudioTimeStamp* time_stamp_audio,
  const AudioBufferList* list_buffer_audio_in,
  const AudioTimeStamp* time_stamp_audio_in,
  AudioBufferList* list_buffer_audio_out,
  const AudioTimeStamp* time_stamp_audio_out,
  void* data
) {
  for (
    unsigned long int index_buffer = 0;
    index_buffer < list_buffer_audio_out->mNumberBuffers;
    ++index_buffer
  ) {
    AudioBuffer audio_buffer_current = list_buffer_audio_out->mBuffers[index_buffer];

    float* buffer_out = audio_buffer_current.mData;
    unsigned long int size_buffer_out = audio_buffer_current.mDataByteSize / sizeof(float);
    unsigned long int count_channel_out = audio_buffer_current.mNumberChannels;
    
    for (
      unsigned long int index_buffer_out = 0;
      index_buffer_out < size_buffer_out;
      ++index_buffer_out
    ) {
      unsigned long int channel = index_buffer_out % count_channel_out;

      if (channel == 0) {
        buffer_out[index_buffer_out] = 0.0f;
      } else {
        buffer_out[index_buffer_out] = buffer_out[index_buffer_out - channel];
      }
    }
  }

  return 0;
}
