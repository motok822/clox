# Compiler settings
CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -g -I.
LDFLAGS =

# Directories
SRC_DIR = src
INCLUDE_DIR = include
BUILD_DIR = build

# Target executable
TARGET = clox

# Source files
SRCS = $(SRC_DIR)/main.c \
       $(INCLUDE_DIR)/chunk.c \
       $(INCLUDE_DIR)/memory.c \
       $(INCLUDE_DIR)/value.c \
	   $(INCLUDE_DIR)/scanner.c \
	   $(INCLUDE_DIR)/compiler.c \
	   $(INCLUDE_DIR)/object.c \
	   $(INCLUDE_DIR)/vm.c \
       $(INCLUDE_DIR)/debug.c

# Object files
OBJS = $(BUILD_DIR)/main.o \
       $(BUILD_DIR)/chunk.o \
       $(BUILD_DIR)/memory.o \
       $(BUILD_DIR)/value.o \
	   $(BUILD_DIR)/object.o \
	   $(BUILD_DIR)/vm.o \
       $(BUILD_DIR)/scanner.o \
       $(BUILD_DIR)/compiler.o \
       $(BUILD_DIR)/debug.o \

# Default target
all: $(TARGET)

# Create build directory if it doesn't exist
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Link object files to create executable
$(TARGET): $(BUILD_DIR) $(OBJS)
	$(CC) $(OBJS) -o $(TARGET) $(LDFLAGS)

# Compile main.c
$(BUILD_DIR)/main.o: $(SRC_DIR)/main.c
	$(CC) $(CFLAGS) -c $< -o $@

# Compile files from include directory
$(BUILD_DIR)/chunk.o: $(INCLUDE_DIR)/chunk.c $(INCLUDE_DIR)/chunk.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/memory.o: $(INCLUDE_DIR)/memory.c $(INCLUDE_DIR)/memory.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/value.o: $(INCLUDE_DIR)/value.c $(INCLUDE_DIR)/value.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/debug.o: $(INCLUDE_DIR)/debug.c $(INCLUDE_DIR)/debug.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/compiler.o: $(INCLUDE_DIR)/compiler.c $(INCLUDE_DIR)/compiler.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/object.o: $(INCLUDE_DIR)/object.c $(INCLUDE_DIR)/object.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/scanner.o: $(INCLUDE_DIR)/scanner.c $(INCLUDE_DIR)/scanner.h
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/vm.o: $(INCLUDE_DIR)/vm.c $(INCLUDE_DIR)/vm.h
	$(CC) $(CFLAGS) -c $< -o $@

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR) $(TARGET)

# Rebuild everything
rebuild: clean all

# Run the program
run: $(TARGET)
	./$(TARGET)

.PHONY: all clean rebuild run
