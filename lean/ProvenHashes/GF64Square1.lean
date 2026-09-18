import ProvenHashes.GF64CertificateData
noncomputable section
namespace ProvenHashes.GF64Certificate
open Polynomial
set_option maxHeartbeats 4000000
set_option maxRecDepth 4096
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false
theorem square_8 : r8 ^ 2 = r9 + modulus * 0 := by
  dsimp [r8, r9, modulus]
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

theorem square_9 : r9 ^ 2 = r10 + modulus * (1) := by
  dsimp [r9, r10, modulus]
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

theorem square_10 : r10 ^ 2 = r11 + modulus * (X ^ 32) := by
  dsimp [r10, r11, modulus]
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

theorem square_11 : r11 ^ 2 = r12 + modulus * (X ^ 8 + X ^ 6 + X ^ 2) := by
  dsimp [r11, r12, modulus]
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

theorem square_12 : r12 ^ 2 = r13 + modulus * 0 := by
  dsimp [r12, r13, modulus]
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

theorem square_13 : r13 ^ 2 = r14 + modulus * (1) := by
  dsimp [r13, r14, modulus]
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

theorem square_14 : r14 ^ 2 = r15 + modulus * (X ^ 24 + X ^ 16 + 1) := by
  dsimp [r14, r15, modulus]
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

theorem square_15 : r15 ^ 2 = r16 + modulus * (X ^ 48 + X ^ 16 + 1) := by
  dsimp [r15, r16, modulus]
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
