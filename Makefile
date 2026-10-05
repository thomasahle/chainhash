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

TESTS = compile frozen schedule vectors guard key_alignment property schedule_knobs
TESTS_128 = compile frozen schedule arithmetic vectors edges guard short property schedule_knobs
BINS = $(addprefix build/64-,$(TESTS))
BINS_128 = $(addprefix build/128-,$(TESTS_128))
# family-wide key-placement test; defined before the first rule that lists it as a prerequisite
KEYALIGN = build/family-key_alignment build/family-key_alignment-portable

.PHONY: all test test-128 test-128v2 test-256 test-512 test-all cxx certs sanitize sanitize-128 vectors speed calibrate clean
all: build/64-compile build/64-cpp build/128-compile build/128-cpp build/speed build/family-compile build/family-cpp
build:
	mkdir -p build

# ChainHash (64-bit): each test is built natively and with CHAINHASH_PORTABLE.
build/64-%: test/%.c include/chainhash.h include/chainhash_calibrate.h test/property.c | build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) -pthread $< -o $@
build/64-%-portable: test/%.c include/chainhash.h include/chainhash_calibrate.h test/property.c | build
	$(CC) $(CPPFLAGS) $(CFLAGS) -DCHAINHASH_PORTABLE -pthread $< -o $@
build/64-cpp: test/compile.c include/chainhash.h include/chainhash128.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAGS) -x c++ $< -o $@
build/64-compile build/64-compile-portable: include/chainhash128.h
test: $(BINS) $(addsuffix -portable,$(BINS)) build/64-cpp $(KEYALIGN)
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
	./build/family-key_alignment 64
	./build/family-key_alignment-portable 64
	./build/64-property $(RANDOM_CASES) 123456789
	./build/64-property-portable $(RANDOM_CASES) 123456789
	./build/64-schedule_knobs $(RANDOM_CASES)
	./build/64-schedule_knobs-portable 2000
sanitize: | build
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) test/guard.c -o build/64-guard-sanitize
	./build/64-guard-sanitize
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) test/key_alignment.c -o build/64-key_alignment-sanitize
	./build/64-key_alignment-sanitize
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) -pthread test/property.c -o build/64-property-sanitize
	./build/64-property-sanitize 0 123456789
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) test/schedule_knobs.c -o build/64-schedule_knobs-sanitize
	./build/64-schedule_knobs-sanitize 1500

# ChainHash-128: each test is built natively and with CHAINHASH128_PORTABLE.
build/128-%: test/128/%.c include/chainhash128.h include/chainhash_calibrate.h test/128/oracle.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) -pthread $< -o $@
build/128-%-portable: test/128/%.c include/chainhash128.h include/chainhash_calibrate.h test/128/oracle.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) -DCHAINHASH128_PORTABLE -pthread $< -o $@
build/128-cpp: test/128/compile.c include/chainhash128.h include/chainhash.h | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAGS) -x c++ $< -o $@
build/128-compile build/128-compile-portable: include/chainhash.h
test-128: $(BINS_128) $(addsuffix -portable,$(BINS_128)) build/128-cpp $(KEYALIGN)
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
	./build/family-key_alignment 128
	./build/family-key_alignment-portable 128
	./build/128-short
	./build/128-short-portable
	./build/128-property $(RANDOM_CASES_128)
	./build/128-property-portable $(RANDOM_CASES_128)
	./build/128-schedule_knobs $(RANDOM_CASES_128)
	./build/128-schedule_knobs-portable 1000
sanitize-128: | build
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) test/128/guard.c -o build/128-guard-sanitize
	./build/128-guard-sanitize
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) test/128/short.c -o build/128-short-sanitize
	./build/128-short-sanitize
	$(CC) $(CPPFLAGS) -std=c99 $(SANITIZE) $(ARCH_FLAGS) -pthread test/128/property.c -o build/128-property-sanitize
	./build/128-property-sanitize 1000
	$(CC) $(CPPFLAGS) -std=c99 -Wno-overlength-strings $(SANITIZE) $(ARCH_FLAGS) test/128/schedule_knobs.c -o build/128-schedule_knobs-sanitize
	./build/128-schedule_knobs-sanitize 1500

# Version 2 family: ChainHash-128 v2, ChainHash-256, ChainHash-512 (docs/FAMILY.md).
# Each is built natively, with no ISA flags (run-time dispatch only) and portable-only.
# The 256- and 512-bit headers use GNU C (statement expressions, __int128): no -Wpedantic.
CFLAGS_V2 = $(filter-out -Wpedantic,$(CFLAGS))
RANDOM_CASES_V2 ?= 20000
ifeq ($(ARCH),x86_64)
X86_TESTS_128V2 = build/128v2-test-karatsuba build/128v2-test-schoolbook build/128v2-test-noavx2 build/128v2-test-prebc build/128v2-test-noprebc
X86_TESTS_256 = build/256-test-zen0 build/256-test-zen1
# the 256-bit reference's 64x64 carry-less product by PCLMULQDQ (same arithmetic; speed only)
REF256 = -msse4.1 -DCH256_HW_CLMUL
else
REF256 = -DCH256_HW_CLMUL
endif
H128V2 = include/chainhash128v2.h include/chainhash128.h
H256 = include/chainhash256.h
H512 = include/chainhash512.h include/chainhash512_body.inc
build/family-compile: test/family/compile.c include/chainhash.h $(H128V2) $(H256) $(H512) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) -Wno-overlength-strings $(ARCH_FLAGS) $< -o $@
build/family-compile-portable: test/family/compile.c include/chainhash.h $(H128V2) $(H256) $(H512) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) -DCHAINHASH_PORTABLE -DCHAINHASH128_PORTABLE -DCHAINHASH256_PORTABLE -DCHAINHASH512_PORTABLE $< -o $@
build/family-cpp: test/family/compile.c include/chainhash.h $(H128V2) $(H256) $(H512) | build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(ARCH_FLAGS) -x c++ $< -o $@
# inputs flush against unmapped pages on both sides (the short-input paths use masked/overlapping loads)
build/family-page: test/family/page.c $(H128V2) $(H256) $(H512) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) $(ARCH_FLAGS) $< -o $@
# every header's key (and stream) in place at 64k+0..56 and at plain malloc, and relocated by memcpy, every backend;
# run per width by each suite (argument: 64, 128, 128v2, 256, 512)
build/family-key_alignment: test/family/key_alignment.c include/chainhash.h $(H128V2) $(H256) $(H512) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) -Wno-overlength-strings $(ARCH_FLAGS) $< -o $@
build/family-key_alignment-portable: test/family/key_alignment.c include/chainhash.h $(H128V2) $(H256) $(H512) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) -DCHAINHASH_PORTABLE -DCHAINHASH128_PORTABLE -DCHAINHASH256_PORTABLE -DCHAINHASH512_PORTABLE $< -o $@
build/128v2-test: test/128v2/test.c $(H128V2) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) $< -o $@
build/128v2-test-noarch: test/128v2/test.c $(H128V2) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $< -o $@
build/128v2-test-portable: test/128v2/test.c $(H128V2) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) -DCHAINHASH128_PORTABLE $< -o $@
build/128v2-test-karatsuba: test/128v2/test.c $(H128V2) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) -DCH128P_XSCHOOL=0 $< -o $@
build/128v2-test-schoolbook: test/128v2/test.c $(H128V2) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) -DCH128P_XSCHOOL=1 $< -o $@
build/128v2-test-noavx2: test/128v2/test.c $(H128V2) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) -DCH128P_NO_AVX2 $< -o $@
# schedule knobs (same digest): the pre-broadcast mask table on every CPU / never; no NEON next-region prefetch
build/128v2-test-prebc: test/128v2/test.c $(H128V2) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) -DCHAINHASH128V2_PREBC=1 $< -o $@
build/128v2-test-noprebc: test/128v2/test.c $(H128V2) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) -DCHAINHASH128V2_NO_PREBC $< -o $@
build/128v2-test-nonpf: test/128v2/test.c $(H128V2) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) -DCHAINHASH128V2_NO_NPF $< -o $@
test-128v2: build/128v2-test build/128v2-test-noarch build/128v2-test-portable build/128v2-test-nonpf $(X86_TESTS_128V2) build/family-compile build/family-compile-portable build/family-cpp build/family-page $(KEYALIGN)
	./build/family-compile
	./build/family-compile-portable
	./build/family-cpp
	./build/family-page
	./build/family-key_alignment 128v2
	./build/family-key_alignment-portable 128v2
	./build/128v2-test $(RANDOM_CASES_V2)
	./build/128v2-test-noarch 3000
	./build/128v2-test-portable 3000
	./build/128v2-test-nonpf 3000
	for t in $(X86_TESTS_128V2); do ./$$t 3000 || exit 1; done
	python3 test/128v2/check_vectors.py
build/256-test: test/256/test.c $(H256) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) $(ARCH_FLAGS) $(REF256) $< -o $@
build/256-test-noarch: test/256/test.c $(H256) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) $< -o $@
build/256-test-portable: test/256/test.c $(H256) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) -DCHAINHASH256_PORTABLE $< -o $@
build/256-test-zen%: test/256/test.c $(H256) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) $(ARCH_FLAGS) $(REF256) -DPHX_ZEN=$* $< -o $@
# the fast finalizers on crafted twist-carry patterns; random raw keys with edge limbs, one-shot and streaming
build/256-ftest: test/256/ftest.c $(H256) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) $(ARCH_FLAGS) $(REF256) $< -o $@
build/256-xcheck: test/256/xcheck.c $(H256) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) $(ARCH_FLAGS) $(REF256) $< -o $@
test-256: build/256-test build/256-test-noarch build/256-test-portable build/256-ftest build/256-xcheck $(X86_TESTS_256) $(KEYALIGN)
	./build/256-test $(RANDOM_CASES_V2)
	./build/256-test-noarch 200 50 300
	./build/256-test-portable
	./build/256-ftest
	./build/256-xcheck
	./build/family-key_alignment 256
	./build/family-key_alignment-portable 256
	for t in $(X86_TESTS_256); do ./$$t 3000 500 || exit 1; done
	python3 test/256/pyref.py test/256/vectors.txt 300000
build/512-test: test/512/test.c $(H512) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) $(ARCH_FLAGS) $< -o $@
build/512-test-noarch: test/512/test.c $(H512) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) $< -o $@
build/512-test-portable: test/512/test.c $(H512) | build
	$(CC) $(CPPFLAGS) $(CFLAGS_V2) -DCHAINHASH512_PORTABLE $< -o $@
test-512: build/512-test build/512-test-noarch build/512-test-portable $(KEYALIGN)
	./build/512-test 16000 100000
	./build/512-test-noarch 3000 100000
	./build/512-test-portable 200 60000
	./build/family-key_alignment 512
	./build/family-key_alignment-portable 512
	python3 test/512/pyref512.py | cmp - test/512/vectors.txt && echo "PASS Python oracle reproduces test/512/vectors.txt"
# Every header as C++11 and C++17 (SMHasher harnesses are C++), alone and all together, with warnings as errors.
CXX_HEADERS = chainhash.h chainhash128.h chainhash128v2.h chainhash256.h chainhash512.h
CXX_STDS = c++11 c++17
CXX_WERROR ?= -Werror
cxx: test/family/cxx.c include/chainhash.h $(H128V2) $(H256) $(H512) | build
	for std in $(CXX_STDS); do \
	  for h in $(CXX_HEADERS); do \
	    $(CXX) $(CPPFLAGS) -std=$$std -O2 -Wall -Wextra $(CXX_WERROR) $(ARCH_FLAGS) -x c++ -include $$h -c $< -o build/cxx.o || exit 1; \
	  done; \
	  $(CXX) $(CPPFLAGS) -std=$$std -O2 -Wall -Wextra $(CXX_WERROR) $(ARCH_FLAGS) -DCHAINHASH_ALL -x c++ -c $< -o build/cxx.o || exit 1; \
	  $(CXX) $(CPPFLAGS) -std=$$std -O2 -Wall -Wextra $(CXX_WERROR) -DCHAINHASH_PORTABLE -DCHAINHASH128_PORTABLE -DCHAINHASH256_PORTABLE -DCHAINHASH512_PORTABLE -DCHAINHASH_ALL -x c++ -c $< -o build/cxx.o || exit 1; \
	  echo "PASS C++ ($$std, $(CXX)): each header alone, all five together, native and portable"; \
	done
test-all: test test-128 cxx test-128v2 test-256 test-512
# Machine-checked certificates behind docs/THEOREM-128v2.md, THEOREM-256.md and THEOREM-512.md.
certs:
	python3 test/128v2/cert128p.py
	CC="$(CC)" sh test/256/certs.sh
	python3 test/512/cert512.py

# Regenerate the frozen vectors with the independent evaluators and compare them
# with the archives. The archives are never overwritten.
vectors: build/64-vectors build/64-vectors-portable build/128-vectors build/128-vectors-portable
	python3 test/check_vectors.py
	python3 test/128/check_vectors.py
	python3 test/128v2/check_vectors.py --full
	python3 test/256/pyref.py test/256/vectors.txt 300000
	python3 test/512/pyref512.py | cmp - test/512/vectors.txt && echo "PASS Python oracle reproduces test/512/vectors.txt"

# Print this CPU's calibrated schedules as C initializers (include/chainhash_calibrate.h).
build/calibrate: test/calibrate.c include/chainhash_calibrate.h include/chainhash.h include/chainhash128.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) $< -o $@
calibrate: build/calibrate
	./build/calibrate
build/speed: test/speed.c include/chainhash.h include/chainhash128.h | build
	$(CC) $(CPPFLAGS) $(CFLAGS_128) $(ARCH_FLAGS) $< -o $@
speed: build/speed
	./build/speed
clean:
	rm -rf build
