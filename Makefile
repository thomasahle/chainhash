CC = cc
CXX = c++
CPPFLAGS += -Iinclude
CFLAGS ?= -O3 -std=c99 -Wall -Wextra -Wpedantic
CXXFLAGS ?= -O3 -std=c++11 -Wall -Wextra
# Explicit overrides: make ARCH_FLAGS=-mpclmul, or ARCH_FLAGS= for a build with no ISA flags.
ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
ARCH_FLAGS ?= -march=native+crypto
else ifeq ($(ARCH),aarch64)
ARCH_FLAGS ?= -march=armv8-a+crypto
else ifeq ($(ARCH),x86_64)
ARCH_FLAGS ?= -mpclmul
endif
# The pinned NEON kernels in chainhash128.h are single inline-assembly strings
# longer than the ISO C99 minimum limit.
CFLAGS_128 = $(CFLAGS) -Wno-overlength-strings
SANITIZE = -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer
RANDOM_CASES ?= 20000
RANDOM_CASES_128 ?= 20000

TESTS = compile frozen schedule vectors guard key_alignment property
TESTS_128 = compile frozen schedule arithmetic vectors edges guard short property
BINS = $(addprefix build/64-,$(TESTS))
BINS_128 = $(addprefix build/128-,$(TESTS_128))

.PHONY: all test test-128 sanitize sanitize-128 vectors speed clean
all: build/64-compile build/64-cpp build/128-compile build/128-cpp build/speed
build:
	mkdir -p build

# ChainHash (64-bit): each test is built natively and with CHAINHASH_PORTABLE.
build/64-%: test/%.c include/chainhash.h test/property.c | build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) -pthread $< -o $@
build/64-%-portable: test/%.c include/chainhash.h test/property.c | build
	$(CC) $(CPPFLAGS) $(CFLAGS) -DCHAINHASH_PORTABLE -pthread $< -o $@
build/64-cpp: test/compile.c include/chainhash.h include/chainhash128.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAGS) -x c++ $< -o $@
build/64-compile build/64-compile-portable: include/chainhash128.h
test: $(BINS) $(addsuffix -portable,$(BINS)) build/64-cpp
	./build/64-compile
	./build/64-compile-portable
	./build/64-cpp
	./build/64-frozen
	./build/64-frozen-portable
	./build/64-schedule
	./build/64-schedule-portable
	python3 test/check_vectors.py
	./build/64-guard
	./build/64-guard-portable
	./build/64-key_alignment
	./build/64-key_alignment-portable
	./build/64-property $(RANDOM_CASES) 123456789
	./build/64-property-portable $(RANDOM_CASES) 123456789
sanitize: | build
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) test/guard.c -o build/64-guard-sanitize
	./build/64-guard-sanitize
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) test/key_alignment.c -o build/64-key_alignment-sanitize
	./build/64-key_alignment-sanitize
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) -pthread test/property.c -o build/64-property-sanitize
	./build/64-property-sanitize 0 123456789

# ChainHash-128: each test is built natively and with CHAINHASH128_PORTABLE.
build/128-%: test/128/%.c include/chainhash128.h test/128/oracle.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) -pthread $< -o $@
build/128-%-portable: test/128/%.c include/chainhash128.h test/128/oracle.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) -DCHAINHASH128_PORTABLE -pthread $< -o $@
build/128-cpp: test/128/compile.c include/chainhash128.h include/chainhash.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAGS) -x c++ $< -o $@
build/128-compile build/128-compile-portable: include/chainhash.h
test-128: $(BINS_128) $(addsuffix -portable,$(BINS_128)) build/128-cpp
	./build/128-compile
	./build/128-compile-portable
	./build/128-cpp
	./build/128-frozen
	./build/128-frozen-portable
	./build/128-schedule
	./build/128-schedule-portable
	./build/128-arithmetic
	./build/128-arithmetic-portable
	python3 test/128/check_vectors.py
	python3 test/128/bounds.py
	./build/128-edges
	./build/128-edges-portable
	./build/128-guard
	./build/128-guard-portable
	./build/128-short
	./build/128-short-portable
	./build/128-property $(RANDOM_CASES_128)
	./build/128-property-portable $(RANDOM_CASES_128)
sanitize-128: | build
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) test/128/guard.c -o build/128-guard-sanitize
	./build/128-guard-sanitize
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) test/128/short.c -o build/128-short-sanitize
	./build/128-short-sanitize
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) -pthread test/128/property.c -o build/128-property-sanitize
	./build/128-property-sanitize 1000

# Regenerate the frozen vectors with the independent evaluators and compare them
# with the archives. The archives are never overwritten.
vectors: build/64-vectors build/64-vectors-portable build/128-vectors build/128-vectors-portable
	python3 test/check_vectors.py
	python3 test/128/check_vectors.py

build/speed: test/speed.c include/chainhash.h include/chainhash128.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) $< -o $@
speed: build/speed
	./build/speed
clean:
	rm -rf build
