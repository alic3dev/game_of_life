kernel void game_of_life_compute(
  device const char* cells,
  device char* cells_next,
  device char* cells_living_neighbors,
  constant unsigned long int size[
    0x03
  ],
  uint index [[
    thread_position_in_grid
  ]]
) {
  unsigned long int index_x = (
    index %
    size[
      0x00
    ]
  );
  unsigned long int index_y = (
    index /
    size[
      0x00
    ]
  );

  unsigned char living_neighbors = (
    0x00
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
        living_neighbors = (
          living_neighbors +
          0x01
        );
      }
    }
  }

  if (
    (
      cells[
        index
      ] ==
      0x01
    ) &&
    (
      living_neighbors ==
      0x02
    ) ||
    (
      living_neighbors ==
      0x03
    )
  ) {
    cells_next[
      index
    ] = (
      0x01
    );
  } else {
    cells_next[
      index
    ] = (
      0x00
    );
  }

  cells_living_neighbors[
    index
  ] = (
    living_neighbors
  );
}
