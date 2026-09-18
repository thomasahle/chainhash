import Mathlib

noncomputable section
namespace ProvenHashes.GF64Certificate
open Polynomial
set_option maxHeartbeats 4000000
set_option maxRecDepth 4096
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false

/-- The implementation uses reduction constant 27 = 0b11011. -/
noncomputable def modulus : (ZMod 2)[X] := X ^ 64 + X ^ 4 + X ^ 3 + X + 1

theorem modulus_monic : modulus.Monic := by
  unfold modulus
  monicity <;> norm_num

theorem modulus_degree : modulus.degree = 64 := by
  unfold modulus
  compute_degree <;> norm_num <;> decide

theorem modulus_natDegree : modulus.natDegree = 64 := by
  exact natDegree_eq_of_degree_eq_some modulus_degree

noncomputable def r0 : (ZMod 2)[X] := (X)
noncomputable def r1 : (ZMod 2)[X] := (X ^ 2)
noncomputable def r2 : (ZMod 2)[X] := (X ^ 4)
noncomputable def r3 : (ZMod 2)[X] := (X ^ 8)
noncomputable def r4 : (ZMod 2)[X] := (X ^ 16)
noncomputable def r5 : (ZMod 2)[X] := (X ^ 32)
noncomputable def r6 : (ZMod 2)[X] := (X ^ 4 + X ^ 3 + X + 1)
noncomputable def r7 : (ZMod 2)[X] := (X ^ 8 + X ^ 6 + X ^ 2 + 1)
noncomputable def r8 : (ZMod 2)[X] := (X ^ 16 + X ^ 12 + X ^ 4 + 1)
noncomputable def r9 : (ZMod 2)[X] := (X ^ 32 + X ^ 24 + X ^ 8 + 1)
noncomputable def r10 : (ZMod 2)[X] := (X ^ 48 + X ^ 16 + X ^ 4 + X ^ 3 + X)
noncomputable def r11 : (ZMod 2)[X] := (X ^ 36 + X ^ 35 + X ^ 33 + X ^ 8 + X ^ 6 + X ^ 2)
noncomputable def r12 : (ZMod 2)[X] := (X ^ 16 + X ^ 11 + X ^ 10 + X ^ 8 + X ^ 7 + X ^ 5 + X ^ 4 + X ^ 3 + X ^ 2)
noncomputable def r13 : (ZMod 2)[X] := (X ^ 32 + X ^ 22 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 8 + X ^ 6 + X ^ 4)
noncomputable def r14 : (ZMod 2)[X] := (X ^ 44 + X ^ 40 + X ^ 32 + X ^ 28 + X ^ 20 + X ^ 16 + X ^ 12 + X ^ 8 + X ^ 4 + X ^ 3 + X + 1)
noncomputable def r15 : (ZMod 2)[X] := (X ^ 56 + X ^ 40 + X ^ 32 + X ^ 28 + X ^ 27 + X ^ 25 + X ^ 20 + X ^ 19 + X ^ 17 + X ^ 8 + X ^ 6 + X ^ 4 + X ^ 3 + X ^ 2 + X)
noncomputable def r16 : (ZMod 2)[X] := (X ^ 56 + X ^ 54 + X ^ 52 + X ^ 51 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 40 + X ^ 38 + X ^ 34 + X ^ 20 + X ^ 19 + X ^ 17 + X ^ 12 + X ^ 8 + X ^ 6 + X ^ 3 + X ^ 2 + X + 1)
noncomputable def r17 : (ZMod 2)[X] := (X ^ 52 + X ^ 51 + X ^ 49 + X ^ 47 + X ^ 45 + X ^ 43 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 33 + X ^ 32 + X ^ 24 + X ^ 20 + X ^ 19 + X ^ 17 + X ^ 16 + X ^ 15 + X ^ 13 + X ^ 8 + X ^ 7 + X ^ 6 + X ^ 5 + X ^ 2 + 1)
noncomputable def r18 : (ZMod 2)[X] := (X ^ 48 + X ^ 44 + X ^ 43 + X ^ 42 + X ^ 39 + X ^ 38 + X ^ 37 + X ^ 35 + X ^ 34 + X ^ 33 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 22 + X ^ 21 + X ^ 19 + X ^ 17 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 10 + X ^ 6 + X ^ 5 + X ^ 2 + X)
noncomputable def r19 : (ZMod 2)[X] := (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 44 + X ^ 42 + X ^ 38 + X ^ 36 + X ^ 35 + X ^ 34 + X ^ 33 + X ^ 30 + X ^ 27 + X ^ 22 + X ^ 21 + X ^ 18 + X ^ 17 + X ^ 16 + X ^ 11 + X ^ 10 + X ^ 9 + X ^ 8 + X ^ 4 + X + 1)
noncomputable def r20 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 60 + X ^ 59 + X ^ 57 + X ^ 55 + X ^ 54 + X ^ 53 + X ^ 52 + X ^ 48 + X ^ 47 + X ^ 45 + X ^ 44 + X ^ 43 + X ^ 42 + X ^ 41 + X ^ 39 + X ^ 37 + X ^ 36 + X ^ 35 + X ^ 34 + X ^ 33 + X ^ 28 + X ^ 27 + X ^ 25 + X ^ 23 + X ^ 22 + X ^ 21 + X ^ 18 + X ^ 15 + X ^ 13 + X ^ 11 + X ^ 10 + X ^ 8 + X)
noncomputable def r21 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 60 + X ^ 55 + X ^ 54 + X ^ 53 + X ^ 51 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 41 + X ^ 40 + X ^ 35 + X ^ 34 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 26 + X ^ 22 + X ^ 19 + X ^ 17 + X ^ 16 + X ^ 15 + X ^ 13 + X ^ 12 + X ^ 6 + X)
noncomputable def r22 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 57 + X ^ 52 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 43 + X ^ 41 + X ^ 40 + X ^ 38 + X ^ 33 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 22 + X ^ 21 + X ^ 20 + X ^ 18 + X ^ 17 + X ^ 16 + X ^ 12 + X ^ 10 + X ^ 9 + X ^ 8 + X ^ 5 + X ^ 4 + X ^ 2 + 1)
noncomputable def r23 : (ZMod 2)[X] := (X ^ 62 + X ^ 59 + X ^ 53 + X ^ 52 + X ^ 51 + X ^ 43 + X ^ 42 + X ^ 41 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 36 + X ^ 33 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 23 + X ^ 21 + X ^ 17 + X ^ 16 + X ^ 15 + X ^ 13 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 5 + X ^ 2 + X + 1)
noncomputable def r24 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 60 + X ^ 58 + X ^ 57 + X ^ 55 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 45 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 25 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 13 + X ^ 11 + X ^ 10 + X ^ 9 + X ^ 8 + X ^ 6 + X ^ 5 + X)
noncomputable def r25 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 58 + X ^ 57 + X ^ 55 + X ^ 54 + X ^ 52 + X ^ 51 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 46 + X ^ 45 + X ^ 43 + X ^ 41 + X ^ 40 + X ^ 39 + X ^ 37 + X ^ 35 + X ^ 33 + X ^ 30 + X ^ 29 + X ^ 25 + X ^ 23 + X ^ 22 + X ^ 21 + X ^ 20 + X ^ 19 + X ^ 16 + X ^ 14 + X ^ 13 + X ^ 10 + X ^ 8 + X ^ 7 + X ^ 6 + X ^ 5 + X ^ 4 + X ^ 2 + 1)
noncomputable def r26 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 60 + X ^ 59 + X ^ 56 + X ^ 55 + X ^ 54 + X ^ 52 + X ^ 51 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 45 + X ^ 44 + X ^ 43 + X ^ 40 + X ^ 38 + X ^ 34 + X ^ 33 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 23 + X ^ 21 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 12 + X ^ 11 + X ^ 10 + X ^ 9 + X ^ 8 + X ^ 7 + X ^ 6 + X ^ 5 + X ^ 2 + X + 1)
noncomputable def r27 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 56 + X ^ 55 + X ^ 51 + X ^ 45 + X ^ 43 + X ^ 34 + X ^ 33 + X ^ 32 + X ^ 29 + X ^ 26 + X ^ 23 + X ^ 19 + X ^ 18 + X ^ 17 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 10 + X ^ 8 + X ^ 7 + X ^ 3)
noncomputable def r28 : (ZMod 2)[X] := (X ^ 60 + X ^ 59 + X ^ 51 + X ^ 50 + X ^ 48 + X ^ 47 + X ^ 42 + X ^ 41 + X ^ 39 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 23 + X ^ 22 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 8 + X ^ 7 + X ^ 6 + X ^ 2 + X)
noncomputable def r29 : (ZMod 2)[X] := (X ^ 60 + X ^ 59 + X ^ 55 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 41 + X ^ 38 + X ^ 37 + X ^ 35 + X ^ 34 + X ^ 31 + X ^ 30 + X ^ 28 + X ^ 24 + X ^ 23 + X ^ 22 + X ^ 20 + X ^ 19 + X ^ 17 + X ^ 16 + X ^ 15 + X ^ 11 + X ^ 9 + X ^ 7 + X ^ 5 + X ^ 4 + X ^ 3 + X ^ 2 + X + 1)
noncomputable def r30 : (ZMod 2)[X] := (X ^ 62 + X ^ 59 + X ^ 58 + X ^ 55 + X ^ 54 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 47 + X ^ 43 + X ^ 41 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 37 + X ^ 36 + X ^ 34 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 27 + X ^ 25 + X ^ 23 + X ^ 20 + X ^ 19 + X ^ 16 + X ^ 15 + X ^ 12 + X ^ 11 + X ^ 10 + X ^ 9 + X ^ 5 + X ^ 2 + 1)
noncomputable def r31 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 57 + X ^ 56 + X ^ 53 + X ^ 52 + X ^ 49 + X ^ 48 + X ^ 45 + X ^ 44 + X ^ 39 + X ^ 31 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 23 + X ^ 22 + X ^ 21 + X ^ 18 + X ^ 9 + X ^ 7 + X ^ 5 + X ^ 4 + X ^ 3 + X)
noncomputable def r32 : (ZMod 2)[X] := (X ^ 62 + X ^ 60 + X ^ 59 + X ^ 58 + X ^ 54 + X ^ 53 + X ^ 49 + X ^ 45 + X ^ 41 + X ^ 40 + X ^ 38 + X ^ 37 + X ^ 34 + X ^ 33 + X ^ 32 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 17 + X ^ 15 + X ^ 10 + X ^ 8 + X ^ 2 + 1)
noncomputable def r33 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 60 + X ^ 59 + X ^ 56 + X ^ 54 + X ^ 53 + X ^ 50 + X ^ 47 + X ^ 46 + X ^ 44 + X ^ 43 + X ^ 42 + X ^ 38 + X ^ 37 + X ^ 35 + X ^ 29 + X ^ 27 + X ^ 26 + X ^ 22 + X ^ 21 + X ^ 18 + X ^ 17 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 12 + X ^ 11 + X ^ 10 + X ^ 8 + X ^ 7 + X ^ 6 + X ^ 3 + X ^ 2 + 1)
noncomputable def r34 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 55 + X ^ 51 + X ^ 49 + X ^ 47 + X ^ 46 + X ^ 43 + X ^ 40 + X ^ 39 + X ^ 37 + X ^ 33 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 26 + X ^ 24 + X ^ 21 + X ^ 15 + X ^ 11 + X ^ 9 + X ^ 7 + X ^ 6 + X ^ 3 + X + 1)
noncomputable def r35 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 60 + X ^ 57 + X ^ 56 + X ^ 55 + X ^ 54 + X ^ 53 + X ^ 52 + X ^ 51 + X ^ 50 + X ^ 47 + X ^ 46 + X ^ 41 + X ^ 39 + X ^ 37 + X ^ 35 + X ^ 33 + X ^ 32 + X ^ 29 + X ^ 28 + X ^ 26 + X ^ 25 + X ^ 23 + X ^ 20 + X ^ 19 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 12 + X ^ 11 + X ^ 10 + X ^ 6 + X ^ 5 + X ^ 4 + X + 1)
noncomputable def r36 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 60 + X ^ 57 + X ^ 54 + X ^ 53 + X ^ 50 + X ^ 46 + X ^ 40 + X ^ 37 + X ^ 36 + X ^ 34 + X ^ 33 + X ^ 29 + X ^ 26 + X ^ 24 + X ^ 21 + X ^ 20 + X ^ 19 + X ^ 17 + X ^ 15 + X ^ 13 + X ^ 12 + X ^ 11 + X ^ 10 + X ^ 9 + X ^ 8 + X ^ 7 + X ^ 6 + X ^ 5 + X ^ 3)
noncomputable def r37 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 60 + X ^ 57 + X ^ 56 + X ^ 54 + X ^ 53 + X ^ 52 + X ^ 51 + X ^ 50 + X ^ 47 + X ^ 46 + X ^ 44 + X ^ 43 + X ^ 39 + X ^ 38 + X ^ 37 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 26 + X ^ 24 + X ^ 22 + X ^ 19 + X ^ 18 + X ^ 17 + X ^ 13 + X ^ 9 + X ^ 7 + X ^ 6 + X ^ 2 + X)
noncomputable def r38 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 57 + X ^ 54 + X ^ 53 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 47 + X ^ 46 + X ^ 44 + X ^ 37 + X ^ 33 + X ^ 32 + X ^ 30 + X ^ 29 + X ^ 27 + X ^ 24 + X ^ 23 + X ^ 22 + X ^ 17 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 9 + X ^ 7 + X ^ 6 + X ^ 5 + X ^ 2 + 1)
noncomputable def r39 : (ZMod 2)[X] := (X ^ 59 + X ^ 53 + X ^ 51 + X ^ 50 + X ^ 47 + X ^ 43 + X ^ 42 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 25 + X ^ 20 + X ^ 18 + X ^ 13 + X ^ 12 + X ^ 11 + X ^ 5 + X ^ 2 + X + 1)
noncomputable def r40 : (ZMod 2)[X] := (X ^ 60 + X ^ 57 + X ^ 56 + X ^ 55 + X ^ 50 + X ^ 46 + X ^ 45 + X ^ 43 + X ^ 41 + X ^ 38 + X ^ 37 + X ^ 34 + X ^ 33 + X ^ 31 + X ^ 30 + X ^ 25 + X ^ 21 + X ^ 19 + X ^ 18 + X ^ 14 + X ^ 13 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 7 + X ^ 5 + X ^ 4 + X ^ 3 + X ^ 2 + X)
noncomputable def r41 : (ZMod 2)[X] := (X ^ 62 + X ^ 59 + X ^ 57 + X ^ 56 + X ^ 54 + X ^ 53 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 47 + X ^ 46 + X ^ 42 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 37 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 23 + X ^ 21 + X ^ 20 + X ^ 19 + X ^ 18 + X ^ 15 + X ^ 12 + X ^ 11 + X ^ 7 + X ^ 3)
noncomputable def r42 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 58 + X ^ 57 + X ^ 55 + X ^ 54 + X ^ 53 + X ^ 49 + X ^ 48 + X ^ 47 + X ^ 41 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 37 + X ^ 36 + X ^ 35 + X ^ 34 + X ^ 29 + X ^ 28 + X ^ 23 + X ^ 22 + X ^ 21 + X ^ 19 + X ^ 18 + X ^ 14 + X ^ 12 + X ^ 11 + X ^ 10 + X ^ 6)
noncomputable def r43 : (ZMod 2)[X] := (X ^ 60 + X ^ 59 + X ^ 55 + X ^ 54 + X ^ 52 + X ^ 51 + X ^ 49 + X ^ 48 + X ^ 46 + X ^ 43 + X ^ 37 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 28 + X ^ 24 + X ^ 21 + X ^ 12 + X ^ 5 + X ^ 4 + 1)
noncomputable def r44 : (ZMod 2)[X] := (X ^ 62 + X ^ 59 + X ^ 58 + X ^ 55 + X ^ 54 + X ^ 50 + X ^ 49 + X ^ 46 + X ^ 45 + X ^ 43 + X ^ 40 + X ^ 39 + X ^ 37 + X ^ 36 + X ^ 34 + X ^ 33 + X ^ 31 + X ^ 29 + X ^ 28 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 23 + X ^ 22 + X ^ 14 + X ^ 13 + X ^ 11 + X ^ 8 + X ^ 4 + X ^ 3 + X)
noncomputable def r45 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 60 + X ^ 57 + X ^ 54 + X ^ 53 + X ^ 49 + X ^ 45 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 36 + X ^ 35 + X ^ 34 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 23 + X ^ 20 + X ^ 19 + X ^ 18 + X ^ 15 + X ^ 13 + X ^ 12 + X ^ 10 + X ^ 9 + X ^ 8 + X ^ 7 + X + 1)
noncomputable def r46 : (ZMod 2)[X] := (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 57 + X ^ 56 + X ^ 53 + X ^ 52 + X ^ 51 + X ^ 48 + X ^ 47 + X ^ 44 + X ^ 43 + X ^ 42 + X ^ 40 + X ^ 37 + X ^ 36 + X ^ 35 + X ^ 34 + X ^ 29 + X ^ 27 + X ^ 24 + X ^ 19 + X ^ 16 + X ^ 13 + X ^ 11 + X ^ 10 + X ^ 5 + X ^ 3 + X ^ 2 + X + 1)
noncomputable def r47 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 59 + X ^ 58 + X ^ 57 + X ^ 55 + X ^ 50 + X ^ 49 + X ^ 46 + X ^ 45 + X ^ 44 + X ^ 40 + X ^ 39 + X ^ 36 + X ^ 35 + X ^ 34 + X ^ 31 + X ^ 30 + X ^ 28 + X ^ 27 + X ^ 21 + X ^ 20 + X ^ 19 + X ^ 17 + X ^ 16 + X ^ 14 + X ^ 13 + X ^ 12 + X ^ 10 + X ^ 5 + X ^ 4 + X ^ 3 + X ^ 2 + X)
noncomputable def r48 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 60 + X ^ 59 + X ^ 57 + X ^ 54 + X ^ 52 + X ^ 51 + X ^ 49 + X ^ 47 + X ^ 46 + X ^ 42 + X ^ 39 + X ^ 36 + X ^ 35 + X ^ 31 + X ^ 30 + X ^ 28 + X ^ 25 + X ^ 19 + X ^ 18 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 12 + X ^ 11 + X ^ 8 + X ^ 6 + X ^ 5 + X ^ 4 + X ^ 3 + X ^ 2 + X)
noncomputable def r49 : (ZMod 2)[X] := (X ^ 62 + X ^ 60 + X ^ 55 + X ^ 53 + X ^ 51 + X ^ 48 + X ^ 47 + X ^ 45 + X ^ 43 + X ^ 42 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 37 + X ^ 36 + X ^ 35 + X ^ 33 + X ^ 29 + X ^ 23 + X ^ 22 + X ^ 21 + X ^ 20 + X ^ 18 + X ^ 17 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 11 + X ^ 7 + X ^ 6 + X ^ 4 + X ^ 2 + 1)
noncomputable def r50 : (ZMod 2)[X] := (X ^ 63 + X ^ 61 + X ^ 59 + X ^ 58 + X ^ 57 + X ^ 56 + X ^ 50 + X ^ 49 + X ^ 47 + X ^ 46 + X ^ 45 + X ^ 44 + X ^ 43 + X ^ 42 + X ^ 41 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 35 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 25 + X ^ 24 + X ^ 21 + X ^ 19 + X ^ 18 + X ^ 14 + X ^ 12 + X ^ 7 + X ^ 5 + X ^ 2 + X)
noncomputable def r51 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 60 + X ^ 59 + X ^ 58 + X ^ 57 + X ^ 54 + X ^ 49 + X ^ 42 + X ^ 40 + X ^ 39 + X ^ 35 + X ^ 33 + X ^ 32 + X ^ 28 + X ^ 24 + X ^ 13 + X ^ 12 + X ^ 9 + X ^ 7 + X ^ 3 + X ^ 2 + X)
noncomputable def r52 : (ZMod 2)[X] := (X ^ 56 + X ^ 52 + X ^ 51 + X ^ 50 + X ^ 47 + X ^ 45 + X ^ 44 + X ^ 38 + X ^ 37 + X ^ 35 + X ^ 34 + X ^ 26 + X ^ 23 + X ^ 21 + X ^ 19 + X ^ 16 + X ^ 15 + X ^ 10 + X ^ 9 + X ^ 7 + X ^ 5 + X)
noncomputable def r53 : (ZMod 2)[X] := (X ^ 51 + X ^ 49 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 43 + X ^ 37 + X ^ 36 + X ^ 34 + X ^ 33 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 20 + X ^ 18 + X ^ 16 + X ^ 15 + X ^ 12 + X ^ 11 + X ^ 10 + X ^ 9 + X ^ 8 + X ^ 6 + X ^ 5 + X ^ 4 + X ^ 2)
noncomputable def r54 : (ZMod 2)[X] := (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 42 + X ^ 41 + X ^ 40 + X ^ 39 + X ^ 37 + X ^ 34 + X ^ 33 + X ^ 32 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 27 + X ^ 26 + X ^ 23 + X ^ 20 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 13 + X ^ 9 + X ^ 8 + X ^ 7 + X ^ 6 + X ^ 4 + X ^ 2 + X + 1)
noncomputable def r55 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 60 + X ^ 59 + X ^ 58 + X ^ 57 + X ^ 55 + X ^ 54 + X ^ 53 + X ^ 52 + X ^ 51 + X ^ 49 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 43 + X ^ 41 + X ^ 40 + X ^ 39 + X ^ 37 + X ^ 36 + X ^ 35 + X ^ 33 + X ^ 28 + X ^ 26 + X ^ 24 + X ^ 23 + X ^ 22 + X ^ 18 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 12 + X ^ 11 + X ^ 10 + X ^ 7 + X ^ 6 + X ^ 3 + 1)
noncomputable def r56 : (ZMod 2)[X] := (X ^ 56 + X ^ 51 + X ^ 49 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 39 + X ^ 37 + X ^ 34 + X ^ 33 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 23 + X ^ 22 + X ^ 21 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 8 + X ^ 7 + X ^ 5 + X ^ 3 + X ^ 2)
noncomputable def r57 : (ZMod 2)[X] := (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 51 + X ^ 49 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 41 + X ^ 39 + X ^ 37 + X ^ 35 + X ^ 34 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 20 + X ^ 19 + X ^ 18 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 11 + X ^ 8 + X ^ 7 + X ^ 3 + X ^ 2)
noncomputable def r58 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 60 + X ^ 59 + X ^ 58 + X ^ 57 + X ^ 56 + X ^ 55 + X ^ 54 + X ^ 53 + X ^ 52 + X ^ 51 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 47 + X ^ 45 + X ^ 43 + X ^ 42 + X ^ 39 + X ^ 38 + X ^ 37 + X ^ 34 + X ^ 33 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 21 + X ^ 19 + X ^ 17 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 11 + X ^ 9 + X ^ 8 + X ^ 5 + X ^ 4 + X ^ 3 + X + 1)
noncomputable def r59 : (ZMod 2)[X] := (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 42 + X ^ 38 + X ^ 34 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 21 + X ^ 20 + X ^ 17 + X ^ 12 + X ^ 11 + X ^ 7 + X ^ 6 + X ^ 4 + X ^ 3)
noncomputable def r60 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 60 + X ^ 59 + X ^ 58 + X ^ 57 + X ^ 56 + X ^ 55 + X ^ 54 + X ^ 53 + X ^ 52 + X ^ 51 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 47 + X ^ 45 + X ^ 43 + X ^ 42 + X ^ 41 + X ^ 40 + X ^ 39 + X ^ 37 + X ^ 35 + X ^ 34 + X ^ 33 + X ^ 32 + X ^ 23 + X ^ 22 + X ^ 21 + X ^ 20 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 7 + X ^ 6 + X ^ 5 + X ^ 3 + X + 1)
noncomputable def r61 : (ZMod 2)[X] := (X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 16 + X ^ 15 + X ^ 14 + X ^ 13 + X ^ 12 + X ^ 11 + X ^ 10 + X ^ 9 + X ^ 8 + X + 1)
noncomputable def r62 : (ZMod 2)[X] := (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 31 + X ^ 30 + X ^ 29 + X ^ 28 + X ^ 27 + X ^ 26 + X ^ 25 + X ^ 24 + X ^ 23 + X ^ 22 + X ^ 21 + X ^ 20 + X ^ 19 + X ^ 18 + X ^ 17 + X ^ 2 + 1)
noncomputable def r63 : (ZMod 2)[X] := (X ^ 63 + X ^ 62 + X ^ 61 + X ^ 60 + X ^ 59 + X ^ 58 + X ^ 57 + X ^ 56 + X ^ 55 + X ^ 54 + X ^ 53 + X ^ 52 + X ^ 51 + X ^ 50 + X ^ 49 + X ^ 48 + X ^ 47 + X ^ 46 + X ^ 45 + X ^ 44 + X ^ 43 + X ^ 42 + X ^ 41 + X ^ 40 + X ^ 39 + X ^ 38 + X ^ 37 + X ^ 36 + X ^ 35 + X ^ 34 + X ^ 33 + X ^ 32 + X ^ 3 + X)
noncomputable def r64 : (ZMod 2)[X] := (X)


end ProvenHashes.GF64Certificate
