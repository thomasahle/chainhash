import ProvenHashes.GF64CertificateData
noncomputable section
namespace ProvenHashes.GF64Certificate
open Polynomial
set_option maxHeartbeats 4000000
set_option maxRecDepth 4096
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false
theorem square_0 : r0 ^ 2 = r1 + modulus * 0 := by
  dsimp [r0, r1, modulus]
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

theorem square_1 : r1 ^ 2 = r2 + modulus * 0 := by
  dsimp [r1, r2, modulus]
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

theorem square_2 : r2 ^ 2 = r3 + modulus * 0 := by
  dsimp [r2, r3, modulus]
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

theorem square_3 : r3 ^ 2 = r4 + modulus * 0 := by
  dsimp [r3, r4, modulus]
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

theorem square_4 : r4 ^ 2 = r5 + modulus * 0 := by
  dsimp [r4, r5, modulus]
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

theorem square_5 : r5 ^ 2 = r6 + modulus * (1) := by
  dsimp [r5, r6, modulus]
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

theorem square_6 : r6 ^ 2 = r7 + modulus * 0 := by
  dsimp [r6, r7, modulus]
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

theorem square_7 : r7 ^ 2 = r8 + modulus * 0 := by
  dsimp [r7, r8, modulus]
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
