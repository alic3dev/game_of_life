#include <game_of_life_metal_acceleration.h>

#include <game_of_life_metal_acceleration_data.h>
#include <game_of_life_parameters.h>
#include <game_of_life_cell_transform.h>

#include <math_c_vector.h>

#include <rand_clean.h>
#include <rand_functions.h>
#include <rand_initialize.h>

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
    game_of_life_metal_acceleration_data->metal_device == 
    0x00
  ) {
    game_of_life_metal_acceleration_data->metal_device = (
      MTLCreateSystemDefaultDevice()
    );

    if (
      game_of_life_metal_acceleration_data->metal_device ==
      0x00
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_metal_device
      );

      return;
    }
  }

  if (
    game_of_life_metal_acceleration_data->library ==
    0x00
  ) {
    game_of_life_metal_acceleration_data->library = [
      (id<MTLDevice>)
      game_of_life_metal_acceleration_data->metal_device
      newDefaultLibrary
    ];

    if (
      game_of_life_metal_acceleration_data->library ==
      0x00
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_library
      );

      return;
    }
  }

  if (
    game_of_life_metal_acceleration_data->function_compute ==
    0x00
  ) {
    game_of_life_metal_acceleration_data->function_compute = [
      (id<MTLLibrary>)
      game_of_life_metal_acceleration_data->library
      newFunctionWithName: (
        @"game_of_life_compute"
      )
    ];

    if (
      game_of_life_metal_acceleration_data->function_compute ==
      0x00
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_function_compute
      );

      return;
    }
  }

  if (
    game_of_life_metal_acceleration_data->pipeline_state_compute ==
    0x00
  ) {
    NSError* error = (
      0x00
    );

    game_of_life_metal_acceleration_data->pipeline_state_compute = [
      (id<MTLDevice>)
      game_of_life_metal_acceleration_data->metal_device
      newComputePipelineStateWithFunction: (
        (id<MTLFunction>)
        game_of_life_metal_acceleration_data->function_compute
      )
      error: &(
        error
      )
    ];

    if (
      error !=
      0x00
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_pipeline
      );

      [
        error
        release
      ];

      return;
    }
  }
  if (
    game_of_life_metal_acceleration_data->command_queue ==
    0x00
  ) {
    game_of_life_metal_acceleration_data->command_queue = [
      (id<MTLDevice>)
      game_of_life_metal_acceleration_data->metal_device
      newCommandQueue
    ];

    if (
      game_of_life_metal_acceleration_data->command_queue ==
      0x00
    ) {
      game_of_life_metal_acceleration_data->error = (
        game_of_life_metal_acceleration_data_error_create_command_queue
      );

      return;
    }
  }

  game_of_life_metal_acceleration_data->buffer_cells = [
    (id<MTLDevice>)
    game_of_life_metal_acceleration_data->metal_device
    newBufferWithLength: (
      game_of_life_metal_acceleration_data->rand_result->length
    )
    options: (
      MTLResourceStorageModeShared
    )
  ];

  game_of_life_metal_acceleration_data->buffer_cells_next = [
    (id<MTLDevice>)
    game_of_life_metal_acceleration_data->metal_device
    newBufferWithLength: (
      game_of_life_metal_acceleration_data->rand_result->length
    )
    options: (
      MTLResourceStorageModeShared
    )
  ];

  game_of_life_metal_acceleration_data->buffer_living_neighbors = [
    (id<MTLDevice>)
    game_of_life_metal_acceleration_data->metal_device
    newBufferWithLength: (
      game_of_life_metal_acceleration_data->rand_result->length
    )
    options: (
      MTLResourceStorageModeShared
    )
  ];

  unsigned long int size[
    0x03
  ] = {
    game_of_life_parameters->size.x,
    game_of_life_parameters->size.y,
    (
      game_of_life_parameters->size.x *
      game_of_life_parameters->size.y
    )
  };

  game_of_life_metal_acceleration_data->buffer_size = [
    (id<MTLDevice>)
    game_of_life_metal_acceleration_data->metal_device
    newBufferWithBytes: (
      size
    )
    length: (
      sizeof(
        unsigned long int
      ) *
      0x03
    )
    options: (
      MTLResourceStorageModeShared
    )
  ];

  if (
    (
      game_of_life_metal_acceleration_data->buffer_cells ==
      0x00
    ) ||
    (
      game_of_life_metal_acceleration_data->buffer_cells_next ==
      0x00
    ) ||
    (
      game_of_life_metal_acceleration_data->buffer_living_neighbors ==
      0x00
    )
  ) {
    game_of_life_metal_acceleration_data->error = (
      game_of_life_metal_acceleration_data_error_create_buffer
    );

    return;
  }

  game_of_life_generate_initial_generation(
    game_of_life_metal_acceleration_data
  );

  game_of_life_metal_acceleration_data->cells = (
    (id<MTLBuffer>)
    game_of_life_metal_acceleration_data->buffer_cells
  ).contents;

  game_of_life_metal_acceleration_data->living_neighbors = (
    (id<MTLBuffer>)
    game_of_life_metal_acceleration_data->buffer_living_neighbors
  ).contents;
}

void game_of_life_generate_initial_generation(
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data
) {
  unsigned long int* size = (
    (id<MTLBuffer>)
    game_of_life_metal_acceleration_data->buffer_size
  ).contents;

  rand_clean(
    game_of_life_metal_acceleration_data->rand_result,
    game_of_life_metal_acceleration_data->rand_source
  );

  rand_initialize(
    game_of_life_metal_acceleration_data->rand_parameters,
    game_of_life_metal_acceleration_data->rand_result,
    game_of_life_metal_acceleration_data->rand_source,
    size[
      0x02
    ],
    rand_mode_bytes,
    rand_source_type_divisive
  );

  rand_get(
    game_of_life_metal_acceleration_data->rand_source,
    game_of_life_metal_acceleration_data->rand_result,
    game_of_life_metal_acceleration_data->rand_parameters
  );

  char* cells = (
    (id<MTLBuffer>)
    game_of_life_metal_acceleration_data->buffer_cells
  ).contents;

  char* living_neighbors = (
    (id<MTLBuffer>)
    game_of_life_metal_acceleration_data->buffer_living_neighbors
  ).contents;

  for (
    unsigned int index_cell = (
      0x00
    );
    (
      index_cell <
      game_of_life_metal_acceleration_data->rand_result->length
    );
    ++index_cell
  ) {
    cells[
      index_cell
    ] = game_of_life_cell_transform(
      game_of_life_metal_acceleration_data->rand_result->bytes[
        index_cell
      ]
    );

    living_neighbors[
      index_cell
    ] = (
      0x00
    );
  }

  for (
    unsigned int index_cell = (
      0x00
    );
    (
      index_cell <
      game_of_life_metal_acceleration_data->rand_result->length
    );
    ++index_cell
  ) {
    unsigned long int index_x = (
      index_cell %
      size[
        0x00
      ]
    );
    
    unsigned long int index_y = (
      index_cell /
      size[
        0x00
      ]
    );

    for (
      unsigned int index_neighbour_y = (
        (
          index_y ==
          0x00
        )
        ? 0x01
        : (
          index_y -
          0x01
        )
      );
      (
        index_neighbour_y <
        (
          index_y +
          0x02
        )
      );
      ++index_neighbour_y
    ) {
      for (
        unsigned int index_neighbour_x = (
          (
            index_x ==
            0x00
          )
          ? 0x01
          : (
            index_x -
            0x01
          )
        );
        (
          index_neighbour_x <
          (
            index_x +
            0x02
          )
        );
        ++index_neighbour_x
      ) {
        if (
          (
            index_neighbour_y ==
            index_y
          ) &&
          (
            index_neighbour_x ==
            index_x
          ) ||
          (
            index_neighbour_y >=
            size[
              0x01
            ]
          ) ||
          (
            index_neighbour_x >=
            size[
              0x00
            ]
          )
        ) {
          continue;
        }

        unsigned long int index_neighbour = (
          index_neighbour_y *
          size[
            0x00
          ] +
          index_neighbour_x
        );

        if (
          cells[
            index_neighbour
          ] !=
          0x00
        ) {
          living_neighbors[
            index_cell
          ] = (
            living_neighbors[
              index_cell
            ] +
            0x01
          );
        }
      }
    }
  }
}

void game_of_life_metal_acceleration_compute(
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data,
  struct game_of_life_parameters* game_of_life_parameters
) {
  unsigned int length_generations = (
    (
      game_of_life_parameters->lock_to_generation ==
      0x00
    )
    ? 0x01
    : (
      game_of_life_parameters->lock_to_generation -
      0x01
    )
  );

  for (
    unsigned int index_generated_generations = (
      0x00
    );
    (
      index_generated_generations <
      length_generations
    );
    ++index_generated_generations
  ) {
    id<MTLCommandBuffer> buffer_command = [
      (id<MTLCommandQueue>)
      game_of_life_metal_acceleration_data->command_queue
      commandBuffer
    ];

    id<MTLComputeCommandEncoder> encoder_command_compute = [
      buffer_command
      computeCommandEncoder
    ];

    [
      encoder_command_compute
      setComputePipelineState: (
        (id<MTLComputePipelineState>)
        game_of_life_metal_acceleration_data->pipeline_state_compute
      )
    ];

    [
      encoder_command_compute
      setBuffer: (
        (id<MTLBuffer>)
        game_of_life_metal_acceleration_data->buffer_cells
      )
      offset: (
        0x00
      )
      atIndex: (
        0x00
      )
    ];

    [
      encoder_command_compute
      setBuffer: (
        (id<MTLBuffer>)
        game_of_life_metal_acceleration_data->buffer_cells_next
      )
      offset: (
        0x00
      )
      atIndex: (
        0x01
      )
    ];

    [
      encoder_command_compute
      setBuffer: (
        (id<MTLBuffer>)
        game_of_life_metal_acceleration_data->buffer_living_neighbors
      )
      offset: (
        0x00
      )
      atIndex: (
        0x02
      )
    ];

    [
      encoder_command_compute
      setBuffer: (
        (id<MTLBuffer>)
        game_of_life_metal_acceleration_data->buffer_size
      )
      offset: (
        0x00
      )
      atIndex: (
        0x03

      )    ];

    unsigned long int length_buffer = (
      (
        (id<MTLBuffer>)
        game_of_life_metal_acceleration_data->buffer_cells
      ).length
    );

    MTLSize size_grid = (
      MTLSizeMake(
        length_buffer,
        0x01,
        0x01
      )
    );

    unsigned long int length_group_thread = (
      (
        (id<MTLComputePipelineState>)
        game_of_life_metal_acceleration_data->pipeline_state_compute
      ).maxTotalThreadsPerThreadgroup
    );
    if (
      length_buffer <
      length_group_thread
    ) {
      length_group_thread = (
        length_buffer
      );
    }

    MTLSize size_group_thread = (
      MTLSizeMake(
        length_group_thread,
        0x01,
        0x01
      )
    );

    [
      encoder_command_compute
      dispatchThreads: (
        size_grid
      )
      threadsPerThreadgroup: (
        size_group_thread
      )
    ];

    [
      encoder_command_compute
      endEncoding
    ];
    
    [
      buffer_command
      commit
    ];
    
    [
      buffer_command
      waitUntilCompleted
    ];

    char* cells = (
      (
        (id<MTLBuffer>)
        game_of_life_metal_acceleration_data->buffer_cells
      ).contents
    );

    char* cells_next = (
      (
        (id<MTLBuffer>)
        game_of_life_metal_acceleration_data->buffer_cells_next
      ).contents
    );

    for (
      unsigned int index_cell = (
        0x00
      );
      (
        index_cell <
        length_buffer
      );
      ++index_cell
    ) {
      cells[
        index_cell
      ] = (
        cells_next[
          index_cell
        ]
      );
    }
  }

  char* cells = (
    (
      (id<MTLBuffer>)
      game_of_life_metal_acceleration_data->buffer_cells
    ).contents
  );

  char* living_neighbors = (
    (
      (id<MTLBuffer>)
      game_of_life_metal_acceleration_data->buffer_living_neighbors
    ).contents
  );

  game_of_life_metal_acceleration_data->cells = (
    cells
  );
  
  game_of_life_metal_acceleration_data->living_neighbors = (
    living_neighbors
  );
}

void game_of_life_metal_acceleration_destroy(
  struct game_of_life_metal_acceleration_data* game_of_life_metal_acceleration_data
) {
  #if rendering_mode == 2
  if (
    game_of_life_metal_acceleration_data->buffer_cells !=
    0x00
  ) {
    [
      (id<MTLBuffer>)
      game_of_life_metal_acceleration_data->buffer_cells
      release
    ];
  }

  if (
    game_of_life_metal_acceleration_data->buffer_cells_next !=
    0x00
  ) {
    [
      (id<MTLBuffer>)
      game_of_life_metal_acceleration_data->buffer_cells_next
      release
    ];
  }

  if (
    game_of_life_metal_acceleration_data->buffer_living_neighbors !=
    0x00
  ) {
    [
      (id<MTLBuffer>)
      game_of_life_metal_acceleration_data->buffer_living_neighbors
      release
    ];
  }

  if (
    game_of_life_metal_acceleration_data->buffer_size !=
    0x00
  ) {
    [
      (id<MTLBuffer>)
      game_of_life_metal_acceleration_data->buffer_size
      release
    ];
  }

  if (
    game_of_life_metal_acceleration_data->function_compute !=
    0x00
  ) {
    [
      (id<MTLFunction>)
      game_of_life_metal_acceleration_data->function_compute
      release
    ];
  }

  if (
    game_of_life_metal_acceleration_data->library !=
    0x00
  ) {
    [
      (id<MTLLibrary>)
      game_of_life_metal_acceleration_data->library
      release
    ];
  }

  if (
    game_of_life_metal_acceleration_data->metal_device !=
    0x00
  ) {
    [
      (id<MTLDevice>)
      game_of_life_metal_acceleration_data->metal_device
      release
    ];
  }
  #endif
}
