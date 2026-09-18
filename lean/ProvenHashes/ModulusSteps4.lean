import ProvenHashes.ModulusResidues

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial
set_option maxHeartbeats 4000000
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false

theorem residue_step_32 : residue_32 ^ 2 = residue_33 + modulus * (sparse [2, 4, 10, 12, 16, 18, 26, 34, 42, 44, 52, 54, 56, 60]) := by
  unfold residue_32 residue_33 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_33 : residue_33 ^ 2 = residue_34 + modulus * (sparse [1, 2, 6, 10, 12, 20, 22, 24, 28, 30, 36, 42, 44, 48, 54, 56, 58, 62]) := by
  unfold residue_33 residue_34 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_34 : residue_34 ^ 2 = residue_35 + modulus * (sparse [1, 10, 14, 16, 22, 28, 30, 34, 38, 46, 48, 52, 56, 58, 62]) := by
  unfold residue_34 residue_35 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_35 : residue_35 ^ 2 = residue_36 + modulus * (sparse [0, 1, 6, 10, 14, 18, 28, 30, 36, 38, 40, 42, 44, 46, 48, 50, 56, 58, 62]) := by
  unfold residue_35 residue_36 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_36 : residue_36 ^ 2 = residue_37 + modulus * (sparse [1, 4, 8, 10, 16, 28, 36, 42, 44, 50, 56, 58, 62]) := by
  unfold residue_36 residue_37 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_37 : residue_37 ^ 2 = residue_38 + modulus * (sparse [0, 1, 2, 4, 8, 10, 12, 14, 22, 24, 28, 30, 36, 38, 40, 42, 44, 48, 50, 56, 58, 62]) := by
  unfold residue_37 residue_38 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_38 : residue_38 ^ 2 = residue_39 + modulus * (sparse [1, 10, 24, 28, 30, 32, 34, 36, 42, 44, 50, 58, 60, 62]) := by
  unfold residue_38 residue_39 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

theorem residue_step_39 : residue_39 ^ 2 = residue_40 + modulus * (sparse [0, 4, 12, 14, 16, 20, 22, 30, 36, 38, 42, 54]) := by
  unfold residue_39 residue_40 modulus
  simp only [sparse, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil, pow_zero, pow_one]
  try simp only [CharTwo.add_sq, ← pow_mul]
  ring_nf
  all_goals simp only [poly_num_2, poly_num_3, poly_num_4, poly_num_5, poly_num_6, poly_num_7, poly_num_8, poly_num_9, poly_num_10, poly_num_11, poly_num_12, poly_num_13, poly_num_14, poly_num_15, poly_num_16, poly_num_17, poly_num_18, poly_num_19, poly_num_20, poly_num_21, poly_num_22, poly_num_23, poly_num_24, poly_num_25, poly_num_26, poly_num_27, poly_num_28, poly_num_29, poly_num_30, poly_num_31, poly_num_32, poly_num_33, poly_num_34, poly_num_35, poly_num_36, poly_num_37, poly_num_38, poly_num_39, poly_num_40, poly_num_41, poly_num_42, poly_num_43, poly_num_44, poly_num_45, poly_num_46, poly_num_47, poly_num_48, poly_num_49, poly_num_50, poly_num_51, poly_num_52, poly_num_53, poly_num_54, poly_num_55, poly_num_56, poly_num_57, poly_num_58, poly_num_59, poly_num_60, poly_num_61, poly_num_62, poly_num_63, poly_num_64, mul_zero,
    mul_one, zero_add, add_zero]

end ProvenHashes.ChainHash
