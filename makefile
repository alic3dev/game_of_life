name=game_of_life

directory_cexil:=${directory_cexil}
directory_cexil_include=${directory_cexil}/include
directory_cexil_library=${directory_cexil}/library

directory_clic3:=${directory_clic3}
directory_clic3_include=${directory_clic3}/include
directory_clic3_library=${directory_clic3}/library

directory_interrupt_handler:=${directory_interrupt_handler}
directory_interrupt_handler_include=${directory_interrupt_handler}/include
directory_interrupt_handler_library=${directory_interrupt_handler}/library

directory_include=include
directory_objects=objects
directory_output=output
directory_sources=sources

file_library_cexil=${directory_cexil_library}/*.o
file_library_clic3=${directory_clic3_library}/clic3.o
file_library_interrupt_handler=${directory_interrupt_handler_library}/*.o

file_output=${directory_output}/${name}

files_libraries=${file_library_cexil} ${file_library_clic3} ${file_library_interrupt_handler}

files_sources=${wildcard ${directory_sources}/*.c}
files_objects=${patsubst ${directory_sources}/%.c,${directory_objects}/%.o,${files_sources}}

cc=gcc
c_flags=-O3 -I${directory_include} -I${directory_cexil_include} -I${directory_clic3_include} -I${directory_interrupt_handler_include}

strip=strip
strip_flags=-x

all: ${file_output}

name: ${file_output}

${file_output}: ${files_objects} ${directory_output}
	${cc} ${c_flags} ${files_libraries} ${files_objects} -o ${file_output}
	${strip} ${strip_flags} ${file_output}

${directory_objects}/%.o: ${directory_sources}/%.c ${directory_objects}
	${cc} ${c_flags} -c $< -o $@

directories: ${directory_objects} ${directory_output}

${directory_objects}:
	mkdir -p ${directory_objects}

${directory_output}:
	mkdir -p ${directory_output}

run: ${file_output}
	@${file_output}

clean: clean_all

clean_all: clean_objects clean_output

clean_objects:
	-rm -rf ${directory_objects}

clean_output:
	-rm -rf ${directory_output}
