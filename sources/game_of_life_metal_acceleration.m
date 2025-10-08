#include <game_of_life_metal_acceleration.h>

#include <game_of_life_metal_acceleration_data.h>
#include <game_of_life_parameters.h>

#include <clic3_vector.h>

#include <Metal/MTLBuffer.h>
#include <Metal/MTLCommandBuffer.h>
#include <Metal/MTLCommandQueue.h>
#include <Metal/MTLComputeCommandEncoder.h>
#include <Metal/MTLDevice.h>
#include <Metal/MTLLibrary.h>

void game_of_life_metal_acceleration_initialize(
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data,
  struct game_of_life_parameters* game_of_life_parameters
) {
  game_of_life_metal_acceleration_data->error = (
    game_of_life_metal_acceleration_data_error_none
  );

  if (
    game_of_life_metal_acceleration_data->metal_device == (void*)0
  ) {
    game_of_life_metal_acceleration_data->metal_device = MTLCreateSystemDefaultDevice();

    if (
      game_of_life_metal_acceleration_data->metal_device == (void*)0
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_metal_device
      );

      return;
    }
  }

  if (
    game_of_life_metal_acceleration_data->library == (void*)0
  ) {
    game_of_life_metal_acceleration_data->library = [
      (id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device newDefaultLibrary
    ];

    if (
      game_of_life_metal_acceleration_data->library == (void*)0
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_library
      );

      return;
    }
  }

  if (
    game_of_life_metal_acceleration_data->function_compute == (void*)0
  ) {
    game_of_life_metal_acceleration_data->function_compute = [
      (id<MTLLibrary>) game_of_life_metal_acceleration_data->library 
      newFunctionWithName: @"game_of_life_compute"
    ];

    if (
      game_of_life_metal_acceleration_data->function_compute == (void*)0
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_function_compute
      );

      return;
    }
  }

  if (
    game_of_life_metal_acceleration_data->pipeline_state_compute == (void*)0
  ) {
    NSError* error = (void*)0;

    game_of_life_metal_acceleration_data->pipeline_state_compute = [
      (id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device
      newComputePipelineStateWithFunction: (id<MTLFunction>) game_of_life_metal_acceleration_data->function_compute
      error: &error
    ];

    if (error != (void*)0) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_pipeline
      );

      [error release];

      return;
    }

    [error release];
  }

  if (
    game_of_life_metal_acceleration_data->command_queue == (void*)0
  ) {
    game_of_life_metal_acceleration_data->command_queue = [
      (id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device
      newCommandQueue
    ];

    if (
      game_of_life_metal_acceleration_data->command_queue == (void*)0
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_command_queue
      );

      return;
    }
  }

  unsigned int length_buffer = (
    game_of_life_parameters->size.x *
    game_of_life_parameters->size.y
  );

  game_of_life_metal_acceleration_data->buffer_cells = [
    (id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device
    newBufferWithLength: length_buffer
    options: MTLResourceStorageModeShared
  ];

  game_of_life_metal_acceleration_data->buffer_cells_next = [
    (id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device
    newBufferWithLength: length_buffer
    options: MTLResourceStorageModeShared
  ];

  game_of_life_metal_acceleration_data->buffer_living_neighbors = [
    (id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device
    newBufferWithLength: length_buffer
    options: MTLResourceStorageModeShared
  ];

  unsigned long int size[3] = {
    game_of_life_parameters->size.x,
    game_of_life_parameters->size.y,
    game_of_life_parameters->size.x * game_of_life_parameters->size.y
  };

  game_of_life_metal_acceleration_data->buffer_size = [
    (id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device
    newBufferWithBytes: size
    length: sizeof(unsigned long int) * 3
    options: MTLResourceStorageModePrivate
  ];

  if (
    game_of_life_metal_acceleration_data->buffer_cells == (void*)0 ||
    game_of_life_metal_acceleration_data->buffer_cells_next == (void*)0 ||
    game_of_life_metal_acceleration_data->buffer_living_neighbors == (void*)0
  ) {
    game_of_life_metal_acceleration_data->error = (
      game_of_life_metal_acceleration_data_error_create_buffer
    );

    return;
  }

  char* cells = (
    (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_cells
  ).contents;

  for (
    unsigned int index_cell = 0;
    index_cell < length_buffer;
    ++index_cell
  ) {
    cells[
      index_cell
    ] = rand() % 2;
  }

  char* living_neighbors = (
    (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_living_neighbors
  ).contents;

  for (
    unsigned int index_cell = 0;
    index_cell < length_buffer;
    ++index_cell
  ) {
    unsigned long int index_x = index_cell % size[0];
    unsigned long int index_y = index_cell / size[0];

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
          index_neighbour_y >= size[1] ||
          index_neighbour_x >= size[0]
        ) {
          continue;
        }

        unsigned long int index_neighbour = (
          index_neighbour_y * size[0] +
          index_neighbour_x
        );

        if (cells[index_neighbour] != 0) {
          living_neighbors[index_cell] = (
            living_neighbors[index_cell] + 1
          );
        }
      }
    }
  }

  game_of_life_metal_acceleration_data->cells = cells;
  game_of_life_metal_acceleration_data->living_neighbors = living_neighbors;
}

void game_of_life_metal_acceleration_compute(
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data,
  struct game_of_life_parameters* game_of_life_parameters
) {
  id<MTLCommandBuffer> buffer_command = [
    (id<MTLCommandQueue>) game_of_life_metal_acceleration_data->command_queue
    commandBuffer
  ];

  id<MTLComputeCommandEncoder> encoder_command_compute = [
    buffer_command computeCommandEncoder
  ];

  [encoder_command_compute
    setComputePipelineState: (
      (id<MTLComputePipelineState>) (
        game_of_life_metal_acceleration_data->pipeline_state_compute
      )
    )
  ];

  [encoder_command_compute
    setBuffer: (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_cells
    offset: 0
    atIndex: 0
  ];

  [encoder_command_compute
    setBuffer: (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_cells_next
    offset: 0
    atIndex: 1
  ];

  [encoder_command_compute
    setBuffer: (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_living_neighbors
    offset: 0
    atIndex: 2
  ];

  [encoder_command_compute
    setBuffer: (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_size
    offset: 0
    atIndex: 3
  ];

  unsigned long int length_buffer = (
    (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_cells
  ).length;

  MTLSize size_grid = MTLSizeMake(
    length_buffer,
    1,
    1
  );

  unsigned long int length_group_thread = (
    (id<MTLComputePipelineState>) (
      game_of_life_metal_acceleration_data->pipeline_state_compute
    )
  ).maxTotalThreadsPerThreadgroup;

  if (
    length_buffer < length_group_thread
  ) {
    length_group_thread = length_buffer;
  }

  MTLSize size_group_thread = MTLSizeMake(
    length_group_thread,
    1,
    1
  );

  [encoder_command_compute
    dispatchThreads: size_grid
    threadsPerThreadgroup: size_group_thread
  ];

  [encoder_command_compute endEncoding];
  [buffer_command commit];
  [buffer_command waitUntilCompleted];

  char* cells = (
    (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_cells
  ).contents;

  char* cells_next = (
    (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_cells_next
  ).contents;

  for (
    unsigned int index_cell = 0;
    index_cell < length_buffer;
    ++index_cell
  ) {
    cells[
      index_cell
    ] = cells_next[
      index_cell
    ];
  }

  char* living_neighbors = (
    (id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_living_neighbors
  ).contents;

  game_of_life_metal_acceleration_data->cells = cells;
  game_of_life_metal_acceleration_data->living_neighbors = living_neighbors;
}

void game_of_life_metal_acceleration_destroy(
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data
) {
  #if rendering_mode == 2
  if (
    game_of_life_metal_acceleration_data->buffer_cells != (void*)0
  ) {
    [(id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_cells release];
  }

  if (
    game_of_life_metal_acceleration_data->buffer_cells_next != (void*)0
  ) {
    [(id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_cells_next release];
  }

  if (
    game_of_life_metal_acceleration_data->buffer_living_neighbors != (void*)0
  ) {
    [(id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_living_neighbors release];
  }

  if (
    game_of_life_metal_acceleration_data->buffer_size != (void*)0
  ) {
    [(id<MTLBuffer>) game_of_life_metal_acceleration_data->buffer_size release];
  }

  if (
    game_of_life_metal_acceleration_data->function_compute != (void*)0
  ) {
    [(id<MTLFunction>) game_of_life_metal_acceleration_data->function_compute release];
  }

  if (
    game_of_life_metal_acceleration_data->library != (void*)0
  ) {
    [(id<MTLLibrary>) game_of_life_metal_acceleration_data->library release];
  }

  if (
    game_of_life_metal_acceleration_data->metal_device != (void*)0
  ) {
    [(id<MTLDevice>) game_of_life_metal_acceleration_data->metal_device release];
  }
  #endif
}
