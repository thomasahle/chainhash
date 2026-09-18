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
all: build/selftest build/c99 build/speed build/v3-compile build/v3-cpp
build:
	mkdir -p build
build/selftest: test/selftest.cpp test/vectors.h test/vendor/chainhash_ref.h test/fixtures.h include/chainhash.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAGS) $< -o $@
build/c99: test/c99.c include/chainhash.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) $< -o $@
build/portable: test/selftest.cpp test/vectors.h test/vendor/chainhash_ref.h test/fixtures.h include/chainhash.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -DCHAINHASH_FORCE_PORTABLE $< -o $@
build/c99-portable: test/c99.c include/chainhash.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS) -DCHAINHASH_FORCE_PORTABLE $< -o $@
build/speed: test/speed.c test/fixtures.h include/chainhash.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) $< -o $@
test: build/selftest build/portable build/c99 build/c99-portable build/key-schedule build/key-schedule-portable build/key-schedule-c99 build/key-schedule-c99-portable
	./build/selftest
	./build/portable
	./build/c99
	./build/c99-portable
	./build/key-schedule vectors > build/key-schedule-vectors.txt
	python3 test/check_key_vectors.py
	./build/key-schedule-portable
	./build/key-schedule-c99
	./build/key-schedule-c99-portable
speed: build/speed
	./build/speed
sanitize: | build
	$(CXX) $(CPPFLAGS) -std=c++11 -O1 -g $(ARCH_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer test/selftest.cpp -o build/sanitize
	./build/sanitize
	$(CXX) $(CPPFLAGS) -std=c++11 -O1 -g $(ARCH_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer test/key_schedule.cpp -o build/key-schedule-sanitize
	./build/key-schedule-sanitize
vectors: | build
	$(CXX) -O2 -std=c++11 test/generate_vectors.cpp -o build/generate_vectors
	./build/generate_vectors > test/vectors.h
clean:
	rm -rf build

build/key-schedule: test/key_schedule.cpp test/fixtures.h include/chainhash.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAGS) $< -o $@
build/key-schedule-portable: test/key_schedule.cpp test/fixtures.h include/chainhash.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -DCHAINHASH_FORCE_PORTABLE $< -o $@
build/key-schedule-c99: test/key_schedule_c99.c include/chainhash.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) $< -o $@
build/key-schedule-c99-portable: test/key_schedule_c99.c include/chainhash.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS) -DCHAINHASH_FORCE_PORTABLE $< -o $@

# v3 is a separate digest family; retain all v1 targets above.
V3_TESTS = property guard key_alignment compile vectors frozen schedule
V3_BINS = $(addprefix build/v3-,$(V3_TESTS))
V3_PORTABLE_BINS = $(addsuffix -portable,$(V3_BINS))
V3_RANDOM_CASES ?= 20000
.PHONY: test-v3 sanitize-v3
test: test-v3
build/v3-%: test/v3/%.c include/chainhash3.h test/v3/property.c | build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) -pthread $< -o $@
build/v3-%-portable: test/v3/%.c include/chainhash3.h test/v3/property.c | build
	$(CC) $(CPPFLAGS) $(CFLAGS) -DCHAINHASH_V3_PORTABLE -pthread $< -o $@
build/v3-cpp: test/v3/compile.c include/chainhash3.h include/chainhash.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAGS) -x c++ $< -o $@
build/v3-compile build/v3-compile-portable: include/chainhash.h
test-v3: $(V3_BINS) $(V3_PORTABLE_BINS) build/v3-cpp
	./build/v3-compile
	./build/v3-compile-portable
	./build/v3-cpp
	./build/v3-frozen
	./build/v3-frozen-portable
	./build/v3-schedule
	./build/v3-schedule-portable
	python3 test/v3/check_vectors.py
	./build/v3-guard
	./build/v3-guard-portable
	./build/v3-key_alignment
	./build/v3-key_alignment-portable
	./build/v3-property $(V3_RANDOM_CASES) 123456789
	./build/v3-property-portable $(V3_RANDOM_CASES) 123456789
sanitize: sanitize-v3
sanitize-v3: | build
	$(CC) $(CPPFLAGS) -std=c99 -O1 -g $(ARCH_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer test/v3/guard.c -o build/v3-guard-sanitize
	./build/v3-guard-sanitize
	$(CC) $(CPPFLAGS) -std=c99 -O1 -g $(ARCH_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer test/v3/key_alignment.c -o build/v3-key-alignment-sanitize
	./build/v3-key-alignment-sanitize
	$(CC) $(CPPFLAGS) -std=c99 -O1 -g $(ARCH_FLAGS) -fsanitize=address,undefined -fno-omit-frame-pointer -pthread test/v3/property.c -o build/v3-property-sanitize
	./build/v3-property-sanitize 0 123456789
