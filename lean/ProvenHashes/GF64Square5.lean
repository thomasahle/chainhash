import ProvenHashes.GF64CertificateData
noncomputable section
namespace ProvenHashes.GF64Certificate
open Polynomial
set_option maxHeartbeats 4000000
set_option maxRecDepth 4096
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false
theorem square_40 : r40 ^ 2 = r41 + modulus * (X ^ 56 + X ^ 50 + X ^ 48 + X ^ 46 + X ^ 36 + X ^ 28 + X ^ 26 + X ^ 22 + X ^ 18 + X ^ 12 + X ^ 10 + X ^ 4 + X ^ 2) := by
  dsimp [r40, r41, modulus]
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

theorem square_41 : r41 ^ 2 = r42 + modulus * (X ^ 60 + X ^ 54 + X ^ 50 + X ^ 48 + X ^ 44 + X ^ 42 + X ^ 40 + X ^ 36 + X ^ 32 + X ^ 30 + X ^ 28 + X ^ 20 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10) := by
  dsimp [r41, r42, modulus]
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

theorem square_42 : r42 ^ 2 = r43 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 44 + X ^ 42 + X ^ 34 + X ^ 32 + X ^ 30 + X ^ 18 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 10 + X ^ 8 + X ^ 6 + X ^ 4 + X ^ 2 + X + 1) := by
  dsimp [r42, r43, modulus]
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

theorem square_43 : r43 ^ 2 = r44 + modulus * (X ^ 56 + X ^ 54 + X ^ 46 + X ^ 44 + X ^ 40 + X ^ 38 + X ^ 34 + X ^ 32 + X ^ 28 + X ^ 22 + X ^ 10 + 1) := by
  dsimp [r43, r44, modulus]
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

theorem square_44 : r44 ^ 2 = r45 + modulus * (X ^ 60 + X ^ 54 + X ^ 52 + X ^ 46 + X ^ 44 + X ^ 36 + X ^ 34 + X ^ 28 + X ^ 26 + X ^ 22 + X ^ 16 + X ^ 14 + X ^ 10 + X ^ 8 + X ^ 4 + X ^ 2 + 1) := by
  dsimp [r44, r45, modulus]
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

theorem square_45 : r45 ^ 2 = r46 + modulus * (X ^ 62 + X ^ 60 + X ^ 58 + X ^ 56 + X ^ 50 + X ^ 44 + X ^ 42 + X ^ 34 + X ^ 26 + X ^ 16 + X ^ 14 + X ^ 12 + X ^ 8 + X ^ 6 + X ^ 4 + X ^ 2 + X) := by
  dsimp [r45, r46, modulus]
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

theorem square_46 : r46 ^ 2 = r47 + modulus * (X ^ 60 + X ^ 56 + X ^ 52 + X ^ 50 + X ^ 48 + X ^ 42 + X ^ 40 + X ^ 38 + X ^ 32 + X ^ 30 + X ^ 24 + X ^ 22 + X ^ 20 + X ^ 16 + X ^ 10 + X ^ 8 + X ^ 6 + X ^ 4 + 1) := by
  dsimp [r46, r47, modulus]
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

theorem square_47 : r47 ^ 2 = r48 + modulus * (X ^ 62 + X ^ 58 + X ^ 54 + X ^ 52 + X ^ 50 + X ^ 46 + X ^ 36 + X ^ 34 + X ^ 28 + X ^ 26 + X ^ 24 + X ^ 16 + X ^ 14 + X ^ 8 + X ^ 6 + X ^ 4 + X ^ 2 + X) := by
  dsimp [r47, r48, modulus]
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
