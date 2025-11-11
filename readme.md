# game_of_life

implementation.of->{`game_of_life`}.utilizing->{[`cexil`](https://github.com/alic3dev/cexil)};

### 2d

<img width="1920" height="1204" alt="Screenshot 2025-11-10 at 23 21 52" src="https://github.com/user-attachments/assets/14491023-88b1-45ef-b0a4-110148c871df" />
<img width="1920" height="1204" alt="Screenshot 2025-11-10 at 23 17 37" src="https://github.com/user-attachments/assets/d97db256-0783-4198-86bc-5afb61103c86" />

### 3d

<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 23 18 36" src="https://github.com/user-attachments/assets/974e183d-8c00-41ad-ba82-31ec9f436153" />
<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 23 18 57" src="https://github.com/user-attachments/assets/196c8b9f-c316-42a2-8d84-53fb4cf7062c" />
<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 23 19 07" src="https://github.com/user-attachments/assets/e59e0154-0fd4-4a09-9d3f-bbabad19b27a" />
<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 23 19 17" src="https://github.com/user-attachments/assets/ac6ee319-f2f3-44ef-9d86-f2fb097913e2" />
<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 23 19 32" src="https://github.com/user-attachments/assets/fa987f54-ccc5-4e7a-850f-c18e7c5c79b1" />
<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 23 19 42" src="https://github.com/user-attachments/assets/6660df4d-5d58-4218-96b6-71529c6e205f" />
<img width="1966" height="1250" alt="Screenshot 2025-11-10 at 23 19 57" src="https://github.com/user-attachments/assets/a191b32a-a6fc-4b46-b581-b8447ecc1074" />

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
- - [`rand`](https://github.com/alic3dev/rand)

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
- - [`rand`](https://github.com/alic3dev/rand)

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
- `directory_rand`

#### environment_variables:3d

- `directory_cer0`
- `directory_clic3`
- `directory_interrupt_handler`
- `directory_math_c`
- `directory_metil`
- `directory_rand`

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
