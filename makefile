name=game_of_life

allow_all_variations=0

ifndef debug
ifndef rendering_mode
ifndef with_metal
allow_all_variations=1
endif
endif
endif

target_device=mac

ifndef target_device_version
target_device_version=26.1
endif

ifndef target_metal_standard
target_metal_standard=metal4.0
endif

target_platform=arm64-apple-macos${target_device_version}
target_platform_metal=air64-apple-macos${target_device_version_metal}

directory_macos_sdk=${shell xcrun --sdk macosx${target_device_version} --show-sdk-path}

c_flags_platform=-target ${target_platform} -isysroot ${directory_macos_sdk}

directory_objects_base=objects
directory_output_base=output

directory_objects=${directory_objects_base}/release

ifndef directory_math_c
directory_math_c=../math_c
endif

directory_math_c_include=${directory_math_c}/include
directory_math_c_library=${directory_math_c}/library/macos/release

ifndef rendering_mode
rendering_mode=2d
else
ifneq (${rendering_mode},2d)
ifneq (${rendering_mode},3d)
${error invalid_rendering_mode->{${rendering_mode}}}
endif
endif
endif

ifndef debug
debug=0
endif

ifndef with_metal
with_metal=0
endif

name:=${name}_${rendering_mode}

ifeq (${debug}, 1)
name:=${name}_debug
directory_objects=${directory_objects_base}/debug
directory_output=${directory_output_base}/debug
else
directory_output=${directory_output_base}/release
endif

directory_objects:=${directory_objects}/${rendering_mode}
directory_output:=${directory_output}/${rendering_mode}

ifeq (${with_metal},1)
name:=${name}_metal_accelerated

directory_objects:=${directory_objects}_metal_accelerated
directory_output:=${directory_output}_metal_accelerated
endif

directory_objects_c=${directory_objects}/c
directory_objects_objective_c=${directory_objects}/objective_c

directory_air_base=air
directory_air=${directory_air_base}/${rendering_mode}

ifeq (${debug},1)
directory_air:=${directory_air}/debug
else
directory_air:=${directory_air}/release
endif

directory_include=include
directory_metalar=metalar
directory_sources=sources

ifndef directory_clic3
directory_clic3=../clic3
endif

directory_clic3_include=${directory_clic3}/include
directory_clic3_library=${directory_clic3}/library/macos/release

ifndef directory_interrupt_handler
directory_interrupt_handler=../interrupt_handler
endif

directory_interrupt_handler_include=${directory_interrupt_handler}/include
directory_interrupt_handler_library=${directory_interrupt_handler}/library/macos/release

ifndef directory_rand
directory_rand=../rand
endif

directory_rand_include=${directory_rand}/include
directory_rand_library=${directory_rand}/library/macos/release

version_target_cer0=0
version_target_cexil=0
version_target_clic3=0
version_target_interrupt_handler=0
version_target_math_c=0
version_target_metil=3
version_target_rand=0

file_clic3_library=${directory_clic3_library}/clic3.${version_target_clic3}.dylib
file_interrupt_handler_library=${directory_interrupt_handler_library}/interrupt_handler.${version_target_interrupt_handler}.dylib
file_rand_library=${directory_rand_library}/rand.${version_target_rand}.dylib

file_metalar=${directory_metalar}/${name}.metalar
file_output_metal=${directory_output}/default.metallib

files_libraries=${file_clic3_library} ${file_interrupt_handler_library} ${file_rand_library}

ifeq (${rendering_mode},2d)
files_metal=${wildcard ${directory_sources}/*_compute.metal}
else
files_metal=${wildcard ${directory_sources}/*.metal}

ifeq (${with_metal},0)
files_metal:=${filter-out ${directory_sources}/%_compute.metal,${files_metal}}
endif
endif

files_air=${patsubst ${directory_sources}/%.metal,${directory_air}/%.air,${files_metal}}

files_sources_c=${wildcard ${directory_sources}/*.c}
files_sources_objective_c=${wildcard ${directory_sources}/*.m}

ifeq (${rendering_mode},2d)
files_sources_objective_c:=${filter-out ${directory_sources}/game_of_life_3d%.m,${files_sources_objective_c}}
else
files_sources_c:=${filter-out ${directory_sources}/game_of_life_poll.c,${files_sources_c}}
endif

ifeq (${with_metal},1)
files_sources_c:=${filter-out ${directory_sources}/game_of_life_poll.c,${files_sources_c}}
else
files_sources_c:=${filter-out ${directory_sources}/game_of_life_metal_acceleration%,${files_sources_c}}
files_sources_objective_c:=${filter-out ${directory_sources}/game_of_life_metal_acceleration%,${files_sources_objective_c}}
endif

files_objects_c=${patsubst ${directory_sources}/%.c,${directory_objects_c}/%.o,${files_sources_c}}
files_objects_objective_c=${patsubst ${directory_sources}/%.m,${directory_objects_objective_c}/%.o,${files_sources_objective_c}}

c_flags_includes=-I${directory_include} -I${directory_clic3_include} -I${directory_interrupt_handler_include} -I${directory_math_c_include} -I${directory_rand_include}

ifeq (${rendering_mode},2d)
file_output=${directory_output}/${name}

ifndef directory_cexil
directory_cexil=../cexil
endif

directory_cexil_include=${directory_cexil}/include
directory_cexil_library=${directory_cexil}/library/macos/release

file_library_cexil=${directory_cexil_library}/cexil.${version_target_cexil}.dylib

files_libraries:=${files_libraries} ${file_library_cexil}

c_flags_includes:=${c_flags_includes} -I${directory_cexil_include}
endif

ifndef directory_metil
directory_metil=../metil
endif

directory_metil_include=${directory_metil}/include
directory_metil_library=${directory_metil}/library/macos

ifeq (${debug}, 1)
directory_metil_library:=${directory_metil_library}/debug
file_metil_library=${directory_metil_library}/metil_debug.o
else
directory_metil_library:=${directory_metil_library}/release
file_metil_library=${directory_metil_library}/metil.${version_target_metil}.dylib
endif

ifeq (${rendering_mode},3d)
directory_app=${directory_output}/${name}.app
directory_app_contents=${directory_app}/Contents
directory_app_contents_macos=${directory_app_contents}/MacOS
directory_app_contents_resources=${directory_app_contents}/Resources
directory_app_contents_resources_textures=${directory_app_contents_resources}/textures

file_info_plist=${directory_metil_library}/Info.plist
file_output=${directory_app_contents_macos}/${name}
file_output_info_plist=${directory_app_contents}/Info.plist
file_output_metal=${directory_app_contents_resources}/default.metallib
file_output_storyboard=${directory_app_contents_resources}/metil.storyboardc

file_metil_metalar_fps_display=${directory_metil_library}/metil_fps_display.metalar
endif

uses_metal=0

ifeq (${with_metal},1)
uses_metal=1
endif

ifeq (${rendering_mode},3d)
uses_metal=1
endif

cc=clang

ifeq (${uses_metal},1)

ifndef directory_cer0
directory_cer0=../cer0
endif

directory_cer0_include=${directory_cer0}/include

directory_cer0_library=${directory_cer0}/library/macos/release

file_metil_metallib=${directory_metil_library}/metil.metallib
file_metil_storyboard=${directory_metil_library}/metil.storyboardc
file_cer0_library=${directory_cer0_library}/cer0.${version_target_cer0}.dylib
file_math_c_library=${directory_math_c_library}/math_c.${version_target_math_c}.dylib

files_libraries:=${files_libraries} ${file_cer0_library} ${file_math_c_library} ${file_metil_library}

frameworks=Metal MetalKit GameController CoreAudio CoreGraphics CoreText

c_flags_includes:=${c_flags_includes} -I${directory_metil_include} -I${directory_cer0_include} -I${directory_math_c_include}
c_flags_c:=${c_flags_c} ${c_flags_platform}
c_flags_objective_c=${c_flags_platform} ${c_flags_includes} -x objective-c -fmodules -fconstant-cfstrings -DTARGET_MACOS
c_flags_frameworks=${addprefix -framework ,${frameworks}}
c_flags_output=${c_flags_platform} ${c_flags_frameworks}

metal=xcrun -sdk macosx metal
metal_ar=xcrun -sdk macosx metal-ar
metallib=xcrun -sdk macosx metallib
metal_flags_common=-target ${target_platform_metal} -std=${target_metal_standard}
metal_flags=${metal_flags_common} -I${directory_include} -I${directory_math_c_include} -I${directory_metil_include} -isysroot ${directory_macos_sdk}

ifneq (${disable_metal_fast_options}, 1)
metal_flags:=${metal_flags} -fmetal-math-mode\=fast -fmetal-math-fp32-functions\=fast
endif

metal_flags_output=
endif

c_flags_debug_objective_c=-O0 -g -v
c_flags_debug=${c_flags_debug_objective_c}

c_flags_c:=${c_flags_c} ${c_flags_includes}

ifeq (${rendering_mode},2d)
c_flags_c:=${c_flags_c} -Drendering_mode=2
c_flags_objective_c:=${c_flags_objective_c} -Drendering_mode=2
else
c_flags_c:=${c_flags_c} -Drendering_mode=3
c_flags_objective_c:=${c_flags_objective_c} -Drendering_mode=3
endif

ifeq (${debug}, 1)
c_flags_c:=${c_flags_c} ${c_flags_debug}
c_flags_objective_c:=${c_flags_objective_c} ${c_flags_debug_objective_c}

c_flags_output:=${c_flags_output} ${c_flags_debug_objective_c}
else
c_flags_c:=${c_flags_c} -O3
c_flags_objective_c:=${c_flags_objective_c} -O3

c_flags_output:=${c_flags_output} -O3
endif

ifeq (${with_metal},1)
c_flags_c:=${c_flags_c} -Dwith_metal=1
c_flags_objective_c:=${c_flags_objective_c} -Dwith_metal=1
endif

ifdef rate_poll
c_flags_c:=${c_flags_c} -Drate_poll=${rate_poll}
c_flags_objective_c:=${c_flags_objective_c} -Drate_poll=${rate_poll}
endif

strip=strip
strip_flags=-x

all: ${file_output}

ifeq (${allow_all_variations},1)
all_variations:
	make debug=0 rendering_mode=2d with_metal=0
	make debug=0 rendering_mode=2d with_metal=1
	make debug=1 rendering_mode=2d with_metal=0
	make debug=1 rendering_mode=2d with_metal=1
	make debug=0 rendering_mode=3d with_metal=0
	make debug=0 rendering_mode=3d with_metal=1
	make debug=1 rendering_mode=3d with_metal=0
	make debug=1 rendering_mode=3d with_metal=1
endif

name: ${file_output}

ifeq (${rendering_mode},2d)
ifeq (${uses_metal},1)
file_output_metal=${directory_output}/default.metallib

${file_output}: ${files_objects_c} ${files_objects_objective_c} ${file_output_metal}
	mkdir -p ${dir ${file_output}}
	${cc} ${c_flags_output} ${files_objects_c} ${files_objects_objective_c} ${files_libraries} -o ${file_output}
	${strip} ${strip_flags} ${file_output}
else
${file_output}: ${files_objects_c}
	mkdir -p ${dir ${file_output}}
	${cc} ${c_flags_output} ${files_objects_c} ${files_libraries} -o ${file_output}
	${strip} ${strip_flags} ${file_output}
endif
else
${file_output}: ${files_objects_c} ${files_objects_objective_c} ${file_output_metal} ${file_output_info_plist} ${file_output_storyboard}
	mkdir -p ${dir ${file_output}}
	${cc} ${c_flags_output} ${files_objects_c} ${files_objects_objective_c} ${files_libraries} -o ${file_output}
	${strip} ${strip_flags} ${file_output}

${file_output_storyboard}: ${file_metil_storyboard}
	mkdir -p ${directory_app_contents_resources}
	cp -r ${file_metil_storyboard} ${file_output_storyboard}

${file_output_info_plist}: ${file_info_plist}
	mkdir -p ${dir ${file_output_info_plist}}
	cp ${file_info_plist} ${file_output_info_plist}
endif

ifeq (${rendering_mode},2d)
${file_output_metal}: ${file_metalar}
	mkdir -p ${dir ${file_output_metal}}
	${metallib} ${metal_flags_output} ${file_metalar} -o ${file_output_metal}

${file_metalar}: ${directory_air}/game_of_life_compute.air
	mkdir -p ${directory_metalar}
	if [[ -f ${file_metalar} ]]; then rm ${file_metalar}; fi
	${metal_ar} -rc ${file_metalar} ${directory_air}/game_of_life_compute.air
else
${file_output_metal}: ${file_metalar}
	mkdir -p ${dir ${file_output_metal}}
	${metallib} ${metal_flags_output} ${file_metalar} ${file_metil_metalar_fps_display} -o ${file_output_metal}

${file_metalar}: ${files_air}
	mkdir -p ${directory_metalar}
	if [[ -f ${file_metalar} ]]; then rm ${file_metalar}; fi
	${metal_ar} -rc ${file_metalar} ${files_air}
endif

${directory_air}/%.air: ${directory_sources}/%.metal
	mkdir -p ${directory_air}
	${metal} ${metal_flags} -c $< -o $@

${directory_objects_c}/%.o: ${directory_sources}/%.c
	mkdir -p ${directory_objects_c}
	${cc} ${c_flags_c} -c $< -o $@

${directory_objects_objective_c}/%.o: ${directory_sources}/%.m
	mkdir -p ${directory_objects_objective_c}
	${cc} ${c_flags_objective_c} -c $< -o $@

run: ${file_output}
	./${file_output}

clean: clean_all

clean_all: clean_air clean_metalar clean_objects clean_output

clean_air:
	-rm -rf ${directory_air_base}

clean_metalar:
	-rm -rf ${directory_metalar}

clean_objects:
	-rm -rf ${directory_objects_base}

clean_output:
	-rm -rf ${directory_output_base}
