import ProvenHashes.GF64CertificateData
noncomputable section
namespace ProvenHashes.GF64Certificate
open Polynomial
set_option maxHeartbeats 4000000
set_option maxRecDepth 4096
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false
theorem square_24 : r24 ^ 2 = r25 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 36 + X ^ 32 + X ^ 26 + X ^ 24 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 4 + X ^ 2 + X + 1) := by
  dsimp [r24, r25, modulus]
  simp only [CharTwo.add_sq]
  ring_nf
  all_goals simp only [show (2 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 2).trans (by norm_num),
    show (3 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 3).trans (by norm_num),
    show (4 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 4).trans (by norm_num),
    show (5 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 5).trans (by norm_num),
    show (6 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 6).trans (by norm_num),
    mul_zero,
    mul_one,
    add_zero,
    zero_add]

theorem square_25 : r25 ^ 2 = r26 + modulus * (X ^ 62 + X ^ 58 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 28 + X ^ 26 + X ^ 22 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 6 + X) := by
  dsimp [r25, r26, modulus]
  simp only [CharTwo.add_sq]
  ring_nf
  all_goals simp only [show (2 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 2).trans (by norm_num),
    show (3 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 3).trans (by norm_num),
    show (4 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 4).trans (by norm_num),
    show (5 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 5).trans (by norm_num),
    show (6 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 6).trans (by norm_num),
    mul_zero,
    mul_one,
    add_zero,
    zero_add]

theorem square_26 : r26 ^ 2 = r27 + modulus * (X ^ 62 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 26 + X ^ 24 + X ^ 22 + X ^ 16 + X ^ 12 + X ^ 4 + X + 1) := by
  dsimp [r26, r27, modulus]
  simp only [CharTwo.add_sq]
  ring_nf
  all_goals simp only [show (2 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 2).trans (by norm_num),
    show (3 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 3).trans (by norm_num),
    show (4 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 4).trans (by norm_num),
    show (5 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 5).trans (by norm_num),
    show (6 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 6).trans (by norm_num),
    mul_zero,
    mul_one,
    add_zero,
    zero_add]

theorem square_27 : r27 ^ 2 = r28 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 48 + X ^ 46 + X ^ 38 + X ^ 26 + X ^ 22 + X ^ 4 + X) := by
  dsimp [r27, r28, modulus]
  simp only [CharTwo.add_sq]
  ring_nf
  all_goals simp only [show (2 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 2).trans (by norm_num),
    show (3 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 3).trans (by norm_num),
    show (4 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 4).trans (by norm_num),
    show (5 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 5).trans (by norm_num),
    show (6 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 6).trans (by norm_num),
    mul_zero,
    mul_one,
    add_zero,
    zero_add]

theorem square_28 : r28 ^ 2 = r29 + modulus * (X ^ 56 + X ^ 54 + X ^ 38 + X ^ 36 + X ^ 32 + X ^ 30 + X ^ 20 + X ^ 18 + X ^ 14 + X ^ 8 + X ^ 4 + 1) := by
  dsimp [r28, r29, modulus]
  simp only [CharTwo.add_sq]
  ring_nf
  all_goals simp only [show (2 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 2).trans (by norm_num),
    show (3 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 3).trans (by norm_num),
    show (4 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 4).trans (by norm_num),
    show (5 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 5).trans (by norm_num),
    show (6 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 6).trans (by norm_num),
    mul_zero,
    mul_one,
    add_zero,
    zero_add]

theorem square_29 : r29 ^ 2 = r30 + modulus * (X ^ 56 + X ^ 54 + X ^ 46 + X ^ 40 + X ^ 36 + X ^ 28 + X ^ 24 + X ^ 20 + X ^ 18 + X ^ 12 + X ^ 10 + X ^ 6 + X ^ 4) := by
  dsimp [r29, r30, modulus]
  simp only [CharTwo.add_sq]
  ring_nf
  all_goals simp only [show (2 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 2).trans (by norm_num),
    show (3 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 3).trans (by norm_num),
    show (4 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 4).trans (by norm_num),
    show (5 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 5).trans (by norm_num),
    show (6 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 6).trans (by norm_num),
    mul_zero,
    mul_one,
    add_zero,
    zero_add]

theorem square_30 : r30 ^ 2 = r31 + modulus * (X ^ 60 + X ^ 54 + X ^ 52 + X ^ 46 + X ^ 44 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 22 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 4 + 1) := by
  dsimp [r30, r31, modulus]
  simp only [CharTwo.add_sq]
  ring_nf
  all_goals simp only [show (2 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 2).trans (by norm_num),
    show (3 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 3).trans (by norm_num),
    show (4 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 4).trans (by norm_num),
    show (5 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 5).trans (by norm_num),
    show (6 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 6).trans (by norm_num),
    mul_zero,
    mul_one,
    add_zero,
    zero_add]

theorem square_31 : r31 ^ 2 = r32 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 50 + X ^ 48 + X ^ 42 + X ^ 40 + X ^ 34 + X ^ 32 + X ^ 26 + X ^ 24 + X ^ 14 + X ^ 2 + X + 1) := by
  dsimp [r31, r32, modulus]
  simp only [CharTwo.add_sq]
  ring_nf
  all_goals simp only [show (2 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 2).trans (by norm_num),
    show (3 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 3).trans (by norm_num),
    show (4 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 4).trans (by norm_num),
    show (5 : (ZMod 2)[X]) = 1 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 5).trans (by norm_num),
    show (6 : (ZMod 2)[X]) = 0 from (CharP.cast_eq_mod ((ZMod 2)[X]) 2 6).trans (by norm_num),
    mul_zero,
    mul_one,
    add_zero,
    zero_add]


end ProvenHashes.GF64Certificate
