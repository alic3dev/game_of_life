# game_of_life

implementation.of->{`game_of_life`}.utilizing->{[`cexil`](https://github.com/alic3dev/cexil)};

### 2d

<img width="1377" alt="game_of_life:2d" src="https://github.com/user-attachments/assets/29e4873d-3a05-4bb6-8392-3f92534531cb" />

### 3d

<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 21 36 44" src="https://github.com/user-attachments/assets/d0b991e4-ce04-4b24-8fc0-d3eba055fdf2" />

<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 21 37 56" src="https://github.com/user-attachments/assets/9564b18d-c014-4e2a-91e6-2dea4814df3e" />

<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 21 36 32" src="https://github.com/user-attachments/assets/4dff77ac-ab8a-4ed2-9e31-87516328b82b" />
  
<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 21 35 49" src="https://github.com/user-attachments/assets/d68be008-b50a-4434-9d23-cc4e3f151530" />
  
<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 21 36 13" src="https://github.com/user-attachments/assets/1f40fa41-0d40-4726-a84f-0207ceb93f74" />

<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 21 35 05" src="https://github.com/user-attachments/assets/ac1f2762-9775-41d6-a2cc-83321e6f8019" />

<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 21 35 30" src="https://github.com/user-attachments/assets/03a498f5-f791-4731-9fa5-956c91d3bbb9" />

<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 21 35 38" src="https://github.com/user-attachments/assets/abd6a5fa-d8bf-4fa2-b214-a6c0e4d68b64" />

## running

### 2d

```sh
./output/release/2d/game_of_life
```

```sh
make run rendering_mode=2d
```

#### metal_accelerated

```sh
./output/release/2d_metal_accelerated/game_of_life_2d_metal_accelerated
```

```sh
make run rendering_mode=2d with_metal=1
```

### 3d

```sh
./output/release/3d/game_of_life_3d.app/Contents/MacOS/game_of_life_3d
```

```sh
make run rendering_mode=3d
```

#### metal_accelerated

```sh
./output/release/3d_metal_accelerated/game_of_life_3d_metal_accelerated.app/Contents/MacOS/game_of_life_3d_metal_accelerated
```

```sh
make run rendering_mode=3d with_metal=1
```

### parameters

#### \[2d|3d\]

- `--help` : prints usage information
- `--size-x` : sets the cell grid width
- `--size-y` : sets the cell grid height
- `--rate-poll` : sets the rate in frames at which the cell grid is polled

#### 2d

- `--frame-rate` : sets the frame rate

#### 3d

- `--audio` : enables audio output from buffered cell grid
- `--fps-display` : enables the frames per second display

## development

### requirements:2d

- [`alic3`](https://github.com/alic3dev)
- - [`cexil`](https://github.com/alic3dev/cexil)
- - [`clic3`](https://github.com/alic3dev/clic3)
- - [`interrupt_handler`](https://github.com/alic3dev/interrupt_handler)

### requirements:3d

- os->{`macos`}
- - version.minimum->{`15.0`};
- - - defaults:to->{`26.0`};
- - - override_with:`target_macos_version`
- - with->{`metal`}.support();

- [`alic3`](https://github.com/alic3dev):libraries
- - [`cer0`](https://github.com/alic3dev/cer0)
- - [`clic3`](https://github.com/alic3dev/clic3)
- - [`interrupt_handler`](https://github.com/alic3dev/interrupt_handler)
- - [`math_c`](https://github.com/alic3dev/math_c)
- - [`metil`](https://github.com/alic3dev/metil)

#### frameworks

- `metal`
- `metalkit`
- `gamecontroller`
- `coreaudio`
- `coregraphics`
- `coretext`

#### environment_variables:2d

- `directory_cexil`
- `directory_clic3`
- `directory_interrupt_handler`

#### environment_variables:3d

- `directory_cer0`
- `directory_clic3`
- `directory_interrupt_handler`
- `directory_math_c`
- `directory_metil`

### building

```sh
make
```

#### compilation_options

- `debug=1`:adds->{`debugging_symbols`}:disables->{`optimizations`};
- `rendering_mode`: default->{`2d`};
- - `2d`: renders in `2d` using [`cexil`](https://github.com/alic3dev/cexil)
- - `3d`: renders in `3d` using [`metil`](https://github.com/alic3dev/metil)
- `with_metal`: default->{`0`};
- - `0`: disables metal acceleration for computation
- - `1`: enables metal acceleration for computation

##### example

```sh
make with_metal=0 rendering_mode=3d; : renders in 3d without metal acceleration
make with_metal=1 rendering_mode=2d; : renders in 2d with metal acceleration
make rendering_mode=3d;              : renders in 3d without metal acceleration
make with_metal=1;                   : renders in 2d with metal acceleration
```

### cleaning

```sh
make clean
```

## copyright|copyleft

> © [copyleft|copyright]->{alic3dev(2025)}:[all_rights_reserved|all_lefts_reserved]
