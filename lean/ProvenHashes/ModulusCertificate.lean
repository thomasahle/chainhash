import ProvenHashes.ModulusSteps0
import ProvenHashes.ModulusSteps1
import ProvenHashes.ModulusSteps2
import ProvenHashes.ModulusSteps3
import ProvenHashes.ModulusSteps4
import ProvenHashes.ModulusSteps5
import ProvenHashes.ModulusSteps6
import ProvenHashes.ModulusSteps7

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial
set_option maxHeartbeats 8000000
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false

theorem residue_bezout : modulus * (sparse [2, 3, 5, 7, 11, 12, 15, 17, 18, 20, 21, 22, 25, 26, 32, 35, 37, 38, 41, 46, 48, 57, 60]) + (residue_32 - X) * (sparse [0, 1, 2, 6, 7, 8, 11, 15, 17, 19, 20, 22, 24, 25, 26, 27, 28, 29, 31, 32, 37, 38, 40, 44, 46, 47, 49, 51, 54, 55, 56, 57, 60, 62]) = 1 := by
  unfold modulus residue_32
  rw [CharTwo.sub_eq_add]
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

end ProvenHashes.ChainHash
