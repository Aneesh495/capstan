# Capstan Native Library Makefile
# Builds libcapstan shared library and native test runner.

CC ?= gcc
CFLAGS ?= -O3 -Wall -Wextra -pedantic -std=c99 -fPIC -I./c_src

# Architecture and platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    DYLIB_EXT := dylib
    SHFLAGS := -dynamiclib
else
    DYLIB_EXT := so
    SHFLAGS := -shared
endif

SRCS := c_src/merkle_simd.c c_src/ring_buffer.c c_src/framing.c
OBJS := $(SRCS:.c=.o)
TARGET := build/libcapstan.$(DYLIB_EXT)
TEST_BIN := build/capstan_test

.PHONY: all clean test

all: $(TARGET) $(TEST_BIN)

build:
	mkdir -p build

c_src/%.o: c_src/%.c c_src/capstan.h | build
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJS) | build
	$(CC) $(SHFLAGS) -o $@ $(OBJS)

$(TEST_BIN): c_src/test_main.c $(OBJS) | build
	$(CC) $(CFLAGS) -o $@ c_src/test_main.c $(OBJS)

test: $(TEST_BIN)
	@./$(TEST_BIN)

clean:
	rm -rf build c_src/*.o
