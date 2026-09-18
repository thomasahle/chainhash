CC = cc
CXX = c++
CPPFLAGS += -Iinclude
CFLAGS ?= -O3 -std=c99 -Wall -Wextra -Wpedantic
CXXFLAGS ?= -O3 -std=c++11 -Wall -Wextra
# Explicit overrides: make ARCH_FLAGS=-mpclmul, or ARCH_FLAGS= for portable.
ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
ARCH_FLAGS ?= -march=native+crypto
else ifeq ($(ARCH),aarch64)
ARCH_FLAGS ?= -march=armv8-a+crypto
else ifeq ($(ARCH),x86_64)
ARCH_FLAGS ?= -mpclmul
endif
.PHONY: all test speed sanitize clean vectors
all: build/selftest build/c99 build/speed
build:
	mkdir -p build
build/selftest: test/selftest.cpp test/vectors.h test/vendor/chainhash_ref.h include/chainhash.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAGS) $< -o $@
build/c99: test/c99.c include/chainhash.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) $< -o $@
build/portable: test/selftest.cpp test/vectors.h test/vendor/chainhash_ref.h include/chainhash.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -DCHAINHASH_FORCE_PORTABLE $< -o $@
build/c99-portable: test/c99.c include/chainhash.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS) -DCHAINHASH_FORCE_PORTABLE $< -o $@
build/speed: test/speed.c include/chainhash.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) $< -o $@
test: build/selftest build/portable build/c99 build/c99-portable
	./build/selftest
	./build/portable
	./build/c99
	./build/c99-portable
speed: build/speed
	./build/speed
sanitize: | build
	$(CXX) $(CPPFLAGS) -std=c++11 -O1 -g $(ARCH_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer test/selftest.cpp -o build/sanitize
	./build/sanitize
vectors: | build
	$(CXX) -O2 -std=c++11 test/generate_vectors.cpp -o build/generate_vectors
	./build/generate_vectors > test/vectors.h
clean:
	rm -rf build
