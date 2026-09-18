import ProvenHashes.ModulusResidues

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial
set_option maxHeartbeats 4000000
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false

theorem residue_step_16 : residue_16 ^ 2 = residue_17 + modulus * (sparse [4, 12, 16, 32, 34, 36, 38, 40, 44, 48]) := by
  unfold residue_16 residue_17 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_17 : residue_17 ^ 2 = residue_18 + modulus * (sparse [0, 2, 12, 16, 20, 22, 26, 30, 34, 38, 40]) := by
  unfold residue_17 residue_18 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_18 : residue_18 ^ 2 = residue_19 + modulus * (sparse [0, 2, 4, 6, 10, 12, 14, 20, 22, 24, 32]) := by
  unfold residue_18 residue_19 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_19 : residue_19 ^ 2 = residue_20 + modulus * (sparse [0, 2, 4, 6, 8, 12, 20, 24, 32, 36, 40, 44, 52, 56, 60]) := by
  unfold residue_19 residue_20 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_20 : residue_20 ^ 2 = residue_21 + modulus * (sparse [1, 4, 6, 8, 10, 14, 18, 20, 22, 24, 26, 30, 32, 40, 42, 44, 46, 50, 54, 56, 58, 62]) := by
  unfold residue_20 residue_21 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_21 : residue_21 ^ 2 = residue_22 + modulus * (sparse [0, 1, 2, 4, 6, 16, 18, 24, 28, 32, 34, 36, 38, 42, 44, 46, 56, 58, 62]) := by
  unfold residue_21 residue_22 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_22 : residue_22 ^ 2 = residue_23 + modulus * (sparse [1, 12, 16, 18, 22, 32, 34, 36, 40, 50, 58, 60, 62]) := by
  unfold residue_22 residue_23 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_23 : residue_23 ^ 2 = residue_24 + modulus * (sparse [0, 2, 8, 12, 14, 16, 18, 20, 22, 38, 40, 42, 54, 60]) := by
  unfold residue_23 residue_24 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

end ProvenHashes.ChainHash
