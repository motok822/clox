#ifndef clox_compiler_h
#define clox_compiler_h
#include "vm.h"

ObjFunction *compile(const char *source, Chunk *chunk);
void markCompilerRoots();

#endif