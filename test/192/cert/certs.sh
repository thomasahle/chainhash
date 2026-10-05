#!/bin/sh
# ChainHash-192 certificate suite (on the as-built header):
#   field   : Rabin irreducibility of x^192 + x^7 + x^2 + x + 1 with negative controls (field.py); the C field product
#             against an independent Python product (cert_pk -DDUMP | oracle.py);
#   level 1 : cert_pk.c -- the as-built block value (C192_DERIVE + c192_block_ref on bytes) as a polynomial in s equals
#             the exponent-class expansion; adversarial differences; d(1) = 1; negative control (colliding exponents) rejected;
#   level 2 : cert_2l.c -- region polynomial = Lemma A for q = 1..8, outer = length-leading Horner in z, <= 1-block path;
#             negative control rejected;
#   bound   : bounds.py -- N(L) <= 2L, equality only at L = 1, score 191.
# usage: test/192/cert/certs.sh (CC=... to choose the compiler; CERTDIR=... keeps the build products).  Exit status 0 iff everything passes.
set -u
here=$(cd "$(dirname "$0")" && pwd); CC=${CC:-cc}; fail=0
if [ -n "${CERTDIR:-}" ]; then out=$CERTDIR; mkdir -p "$out"; else out=$(mktemp -d "${TMPDIR:-/tmp}/ch192cert.XXXXXX"); trap 'rm -rf "$out"' EXIT; fi
case $(uname -m) in x86_64|amd64) HW="-mpclmul -msse4.1 -DCH192_HW_CLMUL";; *) HW="-DCH192_HW_CLMUL";; esac
build() { $CC -O2 $HW -I"$here/../../../include" "$@"; }
check() { n=$1; shift; "$@" > "$out/last.txt" 2>&1; rc=$?; tail -n "$n" "$out/last.txt"; [ $rc = 0 ] || { echo "FAIL (exit $rc): $*"; fail=1; }; }
verdict() { grep -q "$1" "$out/last.txt" && ! grep -qE 'CERT [A-Z0-9]* FAIL|ACCEPTED' "$out/last.txt" || { echo "FAIL: no '$1' verdict"; fail=1; }; }
check 8 python3 "$here/field.py"; verdict "FIELD CERT PASS"
if build -DDUMP "$here/cert_pk.c" -o "$out/dump" && "$out/dump" > "$out/dump.txt"; then check 1 python3 "$here/oracle.py" "$out/dump.txt"; verdict "mismatches -> PASS"
else echo "FAIL building or running the field product dump"; fail=1; fi
build "$here/cert_pk.c" -o "$out/cpk" && check 5 "$out/cpk" || fail=1; verdict "CERT PK PASS"
build -DNEG "$here/cert_pk.c" -o "$out/cpk_neg" || fail=1
if "$out/cpk_neg" > /dev/null; then echo "FAIL PK negative control: a derivation with colliding exponents passed"; fail=1
else echo "PASS PK negative control: a derivation with colliding exponents is rejected"; fi
build "$here/cert_2l.c" -o "$out/c2l" && check 2 "$out/c2l" || fail=1; verdict "CERT 2L PASS"
build -DNEG "$here/cert_2l.c" -o "$out/c2l_neg" || fail=1
if "$out/c2l_neg" > /dev/null; then echo "FAIL 2L negative control: a region function with colliding exponents passed"; fail=1
else echo "PASS 2L negative control: a region function with colliding exponents is rejected"; fi
check 1 python3 "$here/bounds.py"; verdict "score 191): PASS"
[ $fail = 0 ] && echo "ChainHash-192 certificates: ALL PASS" || { echo "ChainHash-192 certificates: FAIL"; exit 1; }
