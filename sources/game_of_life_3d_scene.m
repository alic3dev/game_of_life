#include <game_of_life_3d_scene.h>

#if with_metal == 1
#include <game_of_life_metal_acceleration.h>
#include <game_of_life_metal_acceleration_data.h>
#else
#include <game_of_life_cell_transform.h>
#endif

#include <clic3_bytes.h>
#include <clic3_vector.h>

#include <metil_audio/metil_audio_io_proc.h>
#include <metil_debug/log.h>
#include <metil_library.h>
#include <metil_mesh/mesh_box.h>
#include <metil_object.h>
#include <metil_rendering/metil_renderer_interface.h>
#include <metil_rendering/metil_renderer_data_object.h>
#include <metil_scenes/scene.h>

#include <rand_clean.h>
#include <rand_functions.h>
#include <rand_initialize.h>
#include <rand_mode.h>
#include <rand_parameters.h>
#include <rand_result.h>
#include <rand_source.h>
#include <rand_source_type.h>

#if with_metal == 1
#import <AppKit/NSApplication.h>
#endif

#include <stdlib.h>

void game_of_life_3d_scene_initialize(
  struct metil_scene* scene,
  struct metil_renderer_interface* metil_renderer_interface,
  struct game_of_life_parameters* game_of_life_parameters
) {
  metil_scene_initialize(
    scene,
    metil_renderer_interface
  );

  scene->poll = game_of_life_3d_scene_poll;
  scene->destroy = game_of_life_3d_scene_destroy;

  scene->data = malloc(
    sizeof(struct game_of_life_3d_scene_data)
  );

  struct game_of_life_3d_scene_data* game_of_life_3d_scene_data = (
    (struct game_of_life_3d_scene_data*) scene->data
  );

  game_of_life_3d_scene_data->frame = 0;
  game_of_life_3d_scene_data->index_audio = 0;
  game_of_life_3d_scene_data->game_of_life_parameters = game_of_life_parameters;

  game_of_life_3d_scene_data->length_cells = (
    game_of_life_3d_scene_data->game_of_life_parameters->size.x *
    game_of_life_3d_scene_data->game_of_life_parameters->size.y
  );

  rand_initialize(
    &game_of_life_3d_scene_data->rand_parameters,
    &game_of_life_3d_scene_data->rand_result,
    &game_of_life_3d_scene_data->rand_source,
    game_of_life_3d_scene_data->length_cells,
    rand_mode_bytes,
    rand_source_type_divisive
  );

  #if with_metal == 1
  game_of_life_3d_scene_data->game_of_life_metal_acceleration_data = malloc(
    sizeof(
      struct game_of_life_metal_acceleration_data
    )
  );
  
  game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->metal_device = scene->renderer_interface->metal_device;
  game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->library = metil_library.library;
  game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->function_compute = (void*)0;
  game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->pipeline_state_compute = (void*)0;
  game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->error = game_of_life_metal_acceleration_data_error_none;
  game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->rand_parameters = &game_of_life_3d_scene_data->rand_parameters;
  game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->rand_result = &game_of_life_3d_scene_data->rand_result;
  game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->rand_source = &game_of_life_3d_scene_data->rand_source;

  game_of_life_metal_acceleration_initialize(
    game_of_life_3d_scene_data->game_of_life_metal_acceleration_data,
    game_of_life_3d_scene_data->game_of_life_parameters
  );

  if (
    game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->error != game_of_life_metal_acceleration_data_error_none
  ) {
    game_of_life_metal_acceleration_data_error_print(
      game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->error
    );

    [[NSApplication sharedApplication] terminate: 0];
  }

  char* cells = game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->cells;
  char* living_neighbors = game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->living_neighbors;
  #else
  game_of_life_3d_scene_data->cells = malloc(
    sizeof(unsigned char*) *
    game_of_life_3d_scene_data->game_of_life_parameters->size.y
  );

  game_of_life_3d_scene_data->cells_next = malloc(
    sizeof(unsigned char*) *
    game_of_life_3d_scene_data->game_of_life_parameters->size.y
  );

  for (
    unsigned int index_y = 0;
    index_y < game_of_life_3d_scene_data->game_of_life_parameters->size.y;
    ++index_y
  ) {
    game_of_life_3d_scene_data->cells[index_y] = malloc(
      sizeof(unsigned char) *
      game_of_life_3d_scene_data->game_of_life_parameters->size.x
    );

    game_of_life_3d_scene_data->cells_next[index_y] = malloc(
      sizeof(unsigned char) *
      game_of_life_3d_scene_data->game_of_life_parameters->size.x
    );
  }

  game_of_life_generate_initial_generation(
    game_of_life_3d_scene_data
  );
  #endif

  scene->length_renderables = game_of_life_3d_scene_data->length_cells;

  scene->renderables = realloc(
    scene->renderables,
    sizeof(struct metil_renderable) *
    scene->length_renderables
  );

  for (
    unsigned int index_renderable = 0;
    index_renderable < scene->length_renderables;
    ++index_renderable
  ) {
    unsigned int index_x = (
      index_renderable % game_of_life_3d_scene_data->game_of_life_parameters->size.x
    );

    unsigned int index_y = (
      index_renderable / game_of_life_3d_scene_data->game_of_life_parameters->size.x
    );

    metil_renderable_initialize_at_index(
      scene->renderables,
      index_renderable,
      metil_renderable_type_object
    );

    struct metil_object* metil_object = (
      scene->renderables[
        index_renderable
      ].renderable
    );

    if (
      index_renderable == 0
    ) {
      metil_mesh_box_initialize(
        &metil_object->mesh,
        (struct clic3_vector3_float) {
          .x = 1,
          .y = 1,
          .z = 1
        }
      );

      metil_object->vertices = [
        scene->renderer_interface->metal_device
        newBufferWithBytes: (
          metil_object->mesh.vertices
        )
        length: (
          sizeof(struct clic3_vector4_float) *
          metil_object->mesh.length_vertices
        )
        options: MTLResourceStorageModeShared
      ];

      metil_object->indices = [
        scene->renderer_interface->metal_device
        newBufferWithBytes: (
          metil_object->mesh.indices
        )
        length: (
          sizeof(unsigned int) *
          metil_object->mesh.length_indices
        )
        options: MTLResourceStorageModeShared
      ];
    } else {
      metil_object->mesh = (
        ((struct metil_object*) scene->renderables[0].renderable)->mesh
      );

      metil_object->vertices = (
        ((struct metil_object*) scene->renderables[0].renderable)->vertices
      );

      metil_object->indices = (
        ((struct metil_object*) scene->renderables[0].renderable)->indices
      );
    }

    metil_object->data = [
      scene->renderer_interface->metal_device
      newBufferWithLength: (
        sizeof(struct metil_renderer_data_object)
      )
      options: MTLResourceStorageModeShared
    ];

    struct metil_renderer_data_object* data = (
      metil_object->data.contents
    );

    #if with_metal == 1
    if (
      cells[index_renderable] == 1
    ) {
      metil_object->position.z = 100.0f;

      data->color.x = (float) living_neighbors[index_renderable] / 3.0f;
      data->color.y = (float) living_neighbors[index_renderable] / 3.0f;
      data->color.z = (float) living_neighbors[index_renderable] / 3.0f;

      metil_object->position.z = 100.0f;
    } else {
      data->color.x = (float) living_neighbors[index_renderable] / 8.0f;
      data->color.y = (float) living_neighbors[index_renderable] / 16.0f;
      data->color.z = (float) living_neighbors[index_renderable] / 16.0f;

      metil_object->position.z = (
        101.0f + 8.0f - living_neighbors[index_renderable]
      );
    }
    #else
    data->color.x = game_of_life_3d_scene_data->cells[index_y][index_x];
    data->color.y = game_of_life_3d_scene_data->cells[index_y][index_x];
    data->color.z = game_of_life_3d_scene_data->cells[index_y][index_x];

    metil_object->position.z = (
      game_of_life_3d_scene_data->cells[index_y][index_x] == 1
      ? 100
      : 101.0f + 8.0f
    );
    #endif
    data->color.w = 1.0f;

    metil_object->position.x = (
      (float) index_x - (float) game_of_life_3d_scene_data->game_of_life_parameters->size.x / 2.0f
    );

    metil_object->position.y = (
      (float) index_y - (float) game_of_life_3d_scene_data->game_of_life_parameters->size.y / 2.0f
    );
  }

  #if rendering_mode == 3
  if (
    game_of_life_3d_scene_data->game_of_life_parameters->audio == 1
  ) {
    metil_audio_io_proc_add_with_data(
      game_of_life_3d_scene_io_proc,
      game_of_life_3d_scene_data
    );
  }
  #endif
}

#if with_metal != 1
void game_of_life_generate_initial_generation(
  struct game_of_life_3d_scene_data* game_of_life_3d_scene_data
) {
  rand_get(
    &game_of_life_3d_scene_data->rand_source,
    &game_of_life_3d_scene_data->rand_result,
    &game_of_life_3d_scene_data->rand_parameters
  );
  
  for (
    unsigned int index_y = 0;
    index_y < game_of_life_3d_scene_data->game_of_life_parameters->size.y;
    ++index_y
  ) {
    unsigned long int offset_y = (
      index_y *
      game_of_life_3d_scene_data->game_of_life_parameters->size.x
    );

    for (
      unsigned int index_x = 0;
      index_x < game_of_life_3d_scene_data->game_of_life_parameters->size.x;
      ++index_x
    ) {
      game_of_life_3d_scene_data->cells[
        index_y
      ][
        index_x
      ] = game_of_life_cell_transform(
        game_of_life_3d_scene_data->rand_result.bytes[
          offset_y +
          index_x
        ]
      );
    }
  }
}
#endif

void game_of_life_3d_scene_poll(
  struct metil_scene* scene
) {
  struct game_of_life_3d_scene_data* game_of_life_3d_scene_data = (
    (struct game_of_life_3d_scene_data*) scene->data
  );

  struct game_of_life_parameters* game_of_life_parameters = (
    (struct game_of_life_parameters*) game_of_life_3d_scene_data->game_of_life_parameters
  );

  if (
    game_of_life_3d_scene_data->frame < game_of_life_parameters->rate_poll
  ) {
    game_of_life_3d_scene_data->frame = (
      game_of_life_3d_scene_data->frame + 1
    );

    return;
  }

  game_of_life_3d_scene_data->frame = 0;

  if (
    game_of_life_parameters->lock_to_generation != 0
  ) {
    #if with_metal == 1
    game_of_life_generate_initial_generation(
      game_of_life_3d_scene_data->game_of_life_metal_acceleration_data
    );
    #else
    game_of_life_generate_initial_generation(
      game_of_life_3d_scene_data
    );
    #endif
  }

  #if with_metal == 1
  game_of_life_metal_acceleration_compute(
    game_of_life_3d_scene_data->game_of_life_metal_acceleration_data,
    game_of_life_3d_scene_data->game_of_life_parameters
  );

  char* cells = game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->cells;
  char* living_neighbors = game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->living_neighbors;

  for (
    unsigned int index_renderable = 0;
    index_renderable < scene->length_renderables;
    ++index_renderable
  ) {
    struct metil_object* metil_object = (
      scene->renderables[
        index_renderable
      ].renderable
    );

    struct metil_renderer_data_object* data = (
      metil_object->data.contents
    );

    if (
      cells[index_renderable] == 1
    ) {
      metil_object->position.z = 100.0f;

      data->color.x = (float) living_neighbors[index_renderable] / 3.0f;
    } else {
      data->color.x = (float) living_neighbors[index_renderable] / 16.0f;

      metil_object->position.z = (
        101.0f + 8.0f - living_neighbors[index_renderable]
      );
    }

    data->color.y = data->color.x;
    data->color.z = data->color.x;
  }
  #else
  unsigned int count_generations = (
    game_of_life_parameters->lock_to_generation
    ? game_of_life_parameters->lock_to_generation - 1
    : 1
  );

  for (
    unsigned int index_generated_generation = 0;
    index_generated_generation < count_generations;
    ++index_generated_generation
  ) { 
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

        const unsigned int index_renderable = offset_y + index_x;

        struct metil_object* metil_object = (
          scene->renderables[
            index_renderable
          ].renderable
        );
        
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

        struct metil_renderer_data_object* data = (
          metil_object->data.contents
        );

        if (
          (game_of_life_3d_scene_data->cells[index_y][index_x] == 1 && living_neighbors == 2) || 
          living_neighbors == 3
        ) {
          game_of_life_3d_scene_data->cells_next[index_y][index_x] = 1;

          metil_object->position.z = 100.0f;

          data->color.x = (float) living_neighbors / 3.0f;
          data->color.y = (float) living_neighbors / 3.0f;
          data->color.z = (float) living_neighbors / 3.0f;
        } else {
          game_of_life_3d_scene_data->cells_next[index_y][index_x] = 0;

          data->color.x = (float) living_neighbors / 8.0f;
          data->color.y = (float) living_neighbors / 16.0f;
          data->color.z = (float) living_neighbors / 16.0f;

          metil_object->position.z = (
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
  #endif
}

void game_of_life_3d_scene_destroy(
  struct metil_scene* scene
) {
  struct game_of_life_3d_scene_data* game_of_life_3d_scene_data = (
    (struct game_of_life_3d_scene_data*) scene->data
  );

  #if rendering_mode == 3
  if (
    game_of_life_3d_scene_data->game_of_life_parameters->audio == 1
  ) {
    metil_audio_io_proc_remove(
      game_of_life_3d_scene_io_proc
    );
  }
  #endif

  struct metil_object* metil_object = (
    scene->renderables[
      0
    ].renderable
  );

  metil_mesh_destroy(&metil_object->mesh);

  [metil_object->indices release];
  [metil_object->vertices release];

  for (
    unsigned int index_renderable = 0;
    index_renderable < scene->length_renderables;
    ++index_renderable
  ) {
    metil_object = (
      scene->renderables[
        index_renderable
      ].renderable
    );

    [metil_object->data release];

    free(metil_object);
  }

  free(scene->renderables);
  free(scene->textures);

  scene->player.destroy(
    &scene->player
  );

  #if with_metal == 1
  game_of_life_metal_acceleration_destroy(
    game_of_life_3d_scene_data->game_of_life_metal_acceleration_data
  );
  #else
  for (
    unsigned int index_y = 0;
    index_y < game_of_life_3d_scene_data->game_of_life_parameters->size.y;
    ++index_y
  ) {
    free(game_of_life_3d_scene_data->cells[index_y]);
    free(game_of_life_3d_scene_data->cells_next[index_y]);
  }

  free(game_of_life_3d_scene_data->cells);
  free(game_of_life_3d_scene_data->cells_next);
  #endif

  free(scene->data);

  rand_clean(
    &game_of_life_3d_scene_data->rand_result,
    &game_of_life_3d_scene_data->rand_source
  );
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
  struct game_of_life_3d_scene_data* game_of_life_3d_scene_data = (
    (struct game_of_life_3d_scene_data*) data
  );

  #if with_metal == 1
  char* cells = game_of_life_3d_scene_data->game_of_life_metal_acceleration_data->cells;
  #else
  char** cells = game_of_life_3d_scene_data->cells;
  #endif

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
        #if with_metal == 1
        buffer_out[index_buffer_out] = (
          cells[
            game_of_life_3d_scene_data->index_audio % game_of_life_3d_scene_data->length_cells
          ]
        );
        #else
        buffer_out[index_buffer_out] = (
          cells[
            (game_of_life_3d_scene_data->index_audio / game_of_life_3d_scene_data->game_of_life_parameters->size.x) % game_of_life_3d_scene_data->game_of_life_parameters->size.y
          ][
            game_of_life_3d_scene_data->index_audio % game_of_life_3d_scene_data->game_of_life_parameters->size.x
          ]
        );
        #endif

        game_of_life_3d_scene_data->index_audio = (
          game_of_life_3d_scene_data->index_audio + 1
        );

        if (
          game_of_life_3d_scene_data->index_audio >= game_of_life_3d_scene_data->length_cells
        ) {
          game_of_life_3d_scene_data->index_audio = 0;
        }
      } else {
        buffer_out[index_buffer_out] = buffer_out[index_buffer_out - channel];
      }
    }
  }

  return 0;
}
