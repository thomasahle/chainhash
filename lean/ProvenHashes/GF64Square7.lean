import ProvenHashes.GF64CertificateData
noncomputable section
namespace ProvenHashes.GF64Certificate
open Polynomial
set_option maxHeartbeats 4000000
set_option maxRecDepth 4096
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false
theorem square_56 : r56 ^ 2 = r57 + modulus * (X ^ 48 + X ^ 38 + X ^ 34 + X ^ 28 + X ^ 24 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 4 + X ^ 2) := by
  dsimp [r56, r57, modulus]
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

theorem square_57 : r57 ^ 2 = r58 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 48 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 34 + X ^ 32 + X ^ 28 + X ^ 24 + X ^ 18 + X ^ 14 + X ^ 10 + X ^ 6 + X ^ 4 + 1) := by
  dsimp [r57, r58, modulus]
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

theorem square_58 : r58 ^ 2 = r59 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 26 + X ^ 22 + X ^ 20 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 4 + X + 1) := by
  dsimp [r58, r59, modulus]
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

theorem square_59 : r59 ^ 2 = r60 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 48 + X ^ 44 + X ^ 40 + X ^ 36 + X ^ 32 + X ^ 20 + X ^ 12 + X ^ 4 + 1) := by
  dsimp [r59, r60, modulus]
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

theorem square_60 : r60 ^ 2 = r61 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 26 + X ^ 22 + X ^ 20 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 6 + X ^ 4 + X) := by
  dsimp [r60, r61, modulus]
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

theorem square_61 : r61 ^ 2 = r62 + modulus * (X ^ 28 + X ^ 24 + X ^ 20 + X ^ 16) := by
  dsimp [r61, r62, modulus]
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

theorem square_62 : r62 ^ 2 = r63 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 48 + X ^ 44 + X ^ 40 + X ^ 36 + X ^ 32 + 1) := by
  dsimp [r62, r63, modulus]
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

theorem square_63 : r63 ^ 2 = r64 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 36 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 28 + X ^ 26 + X ^ 24 + X ^ 22 + X ^ 20 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 6 + X ^ 4 + X) := by
  dsimp [r63, r64, modulus]
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
