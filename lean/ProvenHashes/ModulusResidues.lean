import ProvenHashes.Modulus

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial
set_option maxHeartbeats 4000000
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false

def sparse (l : List ℕ) : BitsPolynomial := (l.map fun i => X ^ i).sum

theorem poly_num_2 : (2 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 2
theorem poly_num_3 : (3 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 3
theorem poly_num_4 : (4 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 4
theorem poly_num_5 : (5 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 5
theorem poly_num_6 : (6 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 6
theorem poly_num_7 : (7 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 7
theorem poly_num_8 : (8 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 8
theorem poly_num_9 : (9 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 9
theorem poly_num_10 : (10 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 10
theorem poly_num_11 : (11 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 11
theorem poly_num_12 : (12 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 12
theorem poly_num_13 : (13 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 13
theorem poly_num_14 : (14 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 14
theorem poly_num_15 : (15 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 15
theorem poly_num_16 : (16 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 16
theorem poly_num_17 : (17 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 17
theorem poly_num_18 : (18 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 18
theorem poly_num_19 : (19 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 19
theorem poly_num_20 : (20 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 20
theorem poly_num_21 : (21 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 21
theorem poly_num_22 : (22 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 22
theorem poly_num_23 : (23 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 23
theorem poly_num_24 : (24 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 24
theorem poly_num_25 : (25 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 25
theorem poly_num_26 : (26 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 26
theorem poly_num_27 : (27 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 27
theorem poly_num_28 : (28 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 28
theorem poly_num_29 : (29 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 29
theorem poly_num_30 : (30 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 30
theorem poly_num_31 : (31 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 31
theorem poly_num_32 : (32 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 32
theorem poly_num_33 : (33 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 33
theorem poly_num_34 : (34 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 34
theorem poly_num_35 : (35 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 35
theorem poly_num_36 : (36 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 36
theorem poly_num_37 : (37 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 37
theorem poly_num_38 : (38 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 38
theorem poly_num_39 : (39 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 39
theorem poly_num_40 : (40 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 40
theorem poly_num_41 : (41 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 41
theorem poly_num_42 : (42 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 42
theorem poly_num_43 : (43 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 43
theorem poly_num_44 : (44 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 44
theorem poly_num_45 : (45 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 45
theorem poly_num_46 : (46 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 46
theorem poly_num_47 : (47 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 47
theorem poly_num_48 : (48 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 48
theorem poly_num_49 : (49 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 49
theorem poly_num_50 : (50 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 50
theorem poly_num_51 : (51 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 51
theorem poly_num_52 : (52 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 52
theorem poly_num_53 : (53 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 53
theorem poly_num_54 : (54 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 54
theorem poly_num_55 : (55 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 55
theorem poly_num_56 : (56 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 56
theorem poly_num_57 : (57 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 57
theorem poly_num_58 : (58 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 58
theorem poly_num_59 : (59 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 59
theorem poly_num_60 : (60 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 60
theorem poly_num_61 : (61 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 61
theorem poly_num_62 : (62 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 62
theorem poly_num_63 : (63 : BitsPolynomial) = 1 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 63
theorem poly_num_64 : (64 : BitsPolynomial) = 0 := by
  simpa using CharP.natCast_eq_natCast_mod BitsPolynomial 2 64
def residue_0 : BitsPolynomial := sparse [1]
def residue_1 : BitsPolynomial := sparse [2]
def residue_2 : BitsPolynomial := sparse [4]
def residue_3 : BitsPolynomial := sparse [8]
def residue_4 : BitsPolynomial := sparse [16]
def residue_5 : BitsPolynomial := sparse [32]
def residue_6 : BitsPolynomial := sparse [0, 1, 3, 4]
def residue_7 : BitsPolynomial := sparse [0, 2, 6, 8]
def residue_8 : BitsPolynomial := sparse [0, 4, 12, 16]
def residue_9 : BitsPolynomial := sparse [0, 8, 24, 32]
def residue_10 : BitsPolynomial := sparse [1, 3, 4, 16, 48]
def residue_11 : BitsPolynomial := sparse [2, 6, 8, 33, 35, 36]
def residue_12 : BitsPolynomial := sparse [2, 3, 4, 5, 7, 8, 10, 11, 16]
def residue_13 : BitsPolynomial := sparse [4, 6, 8, 10, 14, 16, 20, 22, 32]
def residue_14 : BitsPolynomial := sparse [0, 1, 3, 4, 8, 12, 16, 20, 28, 32, 40, 44]
def residue_15 : BitsPolynomial := sparse [1, 2, 3, 4, 6, 8, 17, 19, 20, 25, 27, 28, 32, 40, 56]
def residue_16 : BitsPolynomial := sparse [0, 1, 2, 3, 6, 8, 12, 17, 19, 20, 34, 38, 40, 48, 49, 50, 51, 52, 54, 56]
def residue_17 : BitsPolynomial := sparse [0, 2, 5, 6, 7, 8, 13, 15, 16, 17, 19, 20, 24, 32, 33, 38, 40, 42, 43, 45, 47, 49, 51, 52]
def residue_18 : BitsPolynomial := sparse [1, 2, 5, 6, 10, 13, 14, 15, 16, 17, 19, 21, 22, 24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 37, 38, 39, 42, 43, 44, 48]
def residue_19 : BitsPolynomial := sparse [0, 1, 4, 8, 9, 10, 11, 16, 17, 18, 21, 22, 27, 30, 33, 34, 35, 36, 38, 42, 44, 48, 50, 52, 54, 58, 60, 62]
def residue_20 : BitsPolynomial := sparse [1, 8, 10, 11, 13, 15, 18, 21, 22, 23, 25, 27, 28, 33, 34, 35, 36, 37, 39, 41, 42, 43, 44, 45, 47, 48, 52, 53, 54, 55, 57, 59, 60, 61, 63]
def residue_21 : BitsPolynomial := sparse [1, 6, 12, 13, 15, 16, 17, 19, 22, 26, 28, 29, 30, 31, 32, 34, 35, 40, 41, 44, 46, 48, 49, 50, 51, 53, 54, 55, 60, 61, 63]
def residue_22 : BitsPolynomial := sparse [0, 2, 4, 5, 8, 9, 10, 12, 16, 17, 18, 20, 21, 22, 25, 26, 27, 29, 30, 31, 32, 33, 38, 40, 41, 43, 48, 49, 50, 52, 57, 61, 62, 63]
def residue_23 : BitsPolynomial := sparse [0, 1, 2, 5, 8, 10, 12, 13, 15, 16, 17, 21, 23, 24, 25, 26, 33, 36, 38, 39, 40, 41, 42, 43, 51, 52, 53, 59, 62]
def residue_24 : BitsPolynomial := sparse [1, 5, 6, 8, 9, 10, 11, 13, 14, 16, 20, 25, 30, 32, 34, 38, 39, 40, 42, 44, 45, 48, 50, 52, 54, 55, 57, 58, 60, 61, 63]
def residue_25 : BitsPolynomial := sparse [0, 2, 4, 5, 6, 7, 8, 10, 13, 14, 16, 19, 20, 21, 22, 23, 25, 29, 30, 33, 35, 37, 39, 40, 41, 43, 45, 46, 48, 49, 50, 51, 52, 54, 55, 57, 58, 61, 63]
def residue_26 : BitsPolynomial := sparse [0, 1, 2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 21, 23, 25, 26, 27, 30, 31, 32, 33, 34, 38, 40, 43, 44, 45, 48, 49, 50, 51, 52, 54, 55, 56, 59, 60, 61, 63]
def residue_27 : BitsPolynomial := sparse [3, 7, 8, 10, 13, 14, 15, 16, 17, 18, 19, 23, 26, 29, 32, 33, 34, 43, 45, 51, 55, 56, 61, 62, 63]
def residue_28 : BitsPolynomial := sparse [1, 2, 6, 7, 8, 14, 16, 20, 22, 23, 25, 26, 27, 28, 29, 32, 34, 36, 39, 41, 42, 47, 48, 50, 51, 59, 60]
def residue_29 : BitsPolynomial := sparse [0, 1, 2, 3, 4, 5, 7, 9, 11, 15, 16, 17, 19, 20, 22, 23, 24, 28, 30, 31, 34, 35, 37, 38, 41, 42, 44, 46, 50, 52, 55, 59, 60]
def residue_30 : BitsPolynomial := sparse [0, 2, 5, 9, 10, 11, 12, 15, 16, 19, 20, 23, 25, 27, 29, 30, 31, 34, 36, 37, 38, 39, 40, 41, 43, 47, 48, 49, 50, 54, 55, 58, 59, 62]
def residue_31 : BitsPolynomial := sparse [1, 3, 4, 5, 7, 9, 18, 21, 22, 23, 24, 25, 26, 31, 39, 44, 45, 48, 49, 52, 53, 56, 57, 61, 62, 63]
def residue_32 : BitsPolynomial := sparse [0, 2, 8, 10, 15, 17, 24, 25, 26, 28, 29, 30, 32, 33, 34, 37, 38, 40, 41, 45, 49, 53, 54, 58, 59, 60, 62]
def residue_33 : BitsPolynomial := sparse [0, 2, 3, 6, 7, 8, 10, 11, 12, 14, 15, 16, 17, 18, 21, 22, 26, 27, 29, 35, 37, 38, 42, 43, 44, 46, 47, 50, 53, 54, 56, 59, 60, 61, 63]
def residue_34 : BitsPolynomial := sparse [0, 1, 3, 6, 7, 9, 11, 15, 21, 24, 26, 27, 28, 29, 33, 37, 39, 40, 43, 46, 47, 49, 51, 55, 56, 58, 60, 61, 63]
def residue_35 : BitsPolynomial := sparse [0, 1, 4, 5, 6, 10, 11, 12, 13, 14, 15, 16, 19, 20, 23, 25, 26, 28, 29, 32, 33, 35, 37, 39, 41, 46, 47, 50, 51, 52, 53, 54, 55, 56, 57, 60, 61, 63]
def residue_36 : BitsPolynomial := sparse [3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 17, 19, 20, 21, 24, 26, 29, 33, 34, 36, 37, 40, 46, 50, 53, 54, 57, 60, 61, 63]
def residue_37 : BitsPolynomial := sparse [1, 2, 6, 7, 9, 13, 17, 18, 19, 22, 24, 26, 28, 29, 30, 31, 32, 34, 36, 37, 38, 39, 43, 44, 46, 47, 50, 51, 52, 53, 54, 56, 57, 60, 61, 63]
def residue_38 : BitsPolynomial := sparse [0, 2, 5, 6, 7, 9, 10, 12, 14, 16, 17, 22, 23, 24, 27, 29, 30, 32, 33, 37, 44, 46, 47, 48, 49, 50, 53, 54, 57, 61, 62, 63]
def residue_39 : BitsPolynomial := sparse [0, 1, 2, 5, 11, 12, 13, 18, 20, 25, 27, 28, 29, 30, 32, 34, 38, 39, 40, 42, 43, 47, 50, 51, 53, 59]
def residue_40 : BitsPolynomial := sparse [1, 2, 3, 4, 5, 7, 8, 10, 12, 13, 14, 18, 19, 21, 25, 30, 31, 33, 34, 37, 38, 41, 43, 45, 46, 50, 55, 56, 57, 60]
def residue_41 : BitsPolynomial := sparse [3, 7, 11, 12, 15, 18, 19, 20, 21, 23, 24, 25, 26, 27, 30, 31, 32, 37, 38, 39, 40, 42, 46, 47, 48, 50, 52, 53, 54, 56, 57, 59, 62]
def residue_42 : BitsPolynomial := sparse [6, 10, 11, 12, 14, 18, 19, 21, 22, 23, 28, 29, 34, 35, 36, 37, 38, 39, 40, 41, 47, 48, 49, 53, 54, 55, 57, 58, 61, 62, 63]
def residue_43 : BitsPolynomial := sparse [0, 4, 5, 12, 21, 24, 28, 30, 31, 32, 37, 43, 46, 48, 49, 51, 52, 54, 55, 59, 60]
def residue_44 : BitsPolynomial := sparse [1, 3, 4, 8, 11, 13, 14, 22, 23, 24, 25, 26, 28, 29, 31, 33, 34, 36, 37, 39, 40, 43, 45, 46, 49, 50, 54, 55, 58, 59, 62]
def residue_45 : BitsPolynomial := sparse [0, 1, 7, 8, 9, 10, 12, 13, 15, 18, 19, 20, 23, 25, 26, 27, 30, 31, 32, 34, 35, 36, 38, 39, 40, 45, 49, 53, 54, 57, 60, 61, 62, 63]
def residue_46 : BitsPolynomial := sparse [0, 1, 2, 3, 5, 10, 11, 13, 16, 19, 24, 27, 29, 34, 35, 36, 37, 40, 42, 43, 44, 47, 48, 51, 52, 53, 56, 57, 58, 60, 62]
def residue_47 : BitsPolynomial := sparse [1, 2, 3, 4, 5, 10, 12, 13, 14, 16, 17, 19, 20, 21, 27, 28, 30, 31, 34, 35, 36, 39, 40, 44, 45, 46, 49, 50, 55, 57, 58, 59, 61, 63]
def residue_48 : BitsPolynomial := sparse [1, 2, 3, 4, 5, 6, 8, 11, 12, 14, 15, 16, 18, 19, 25, 28, 30, 31, 35, 36, 39, 42, 46, 47, 49, 51, 52, 54, 57, 59, 60, 61, 62, 63]
def residue_49 : BitsPolynomial := sparse [0, 2, 4, 6, 7, 11, 14, 15, 16, 17, 18, 20, 21, 22, 23, 29, 33, 35, 36, 37, 38, 39, 40, 42, 43, 45, 47, 48, 51, 53, 55, 60, 62]
def residue_50 : BitsPolynomial := sparse [1, 2, 5, 7, 12, 14, 18, 19, 21, 24, 25, 27, 28, 29, 30, 31, 35, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 49, 50, 56, 57, 58, 59, 61, 63]
def residue_51 : BitsPolynomial := sparse [1, 2, 3, 7, 9, 12, 13, 24, 28, 32, 33, 35, 39, 40, 42, 49, 54, 57, 58, 59, 60, 61, 62, 63]
def residue_52 : BitsPolynomial := sparse [1, 5, 7, 9, 10, 15, 16, 19, 21, 23, 26, 34, 35, 37, 38, 44, 45, 47, 50, 51, 52, 56]
def residue_53 : BitsPolynomial := sparse [2, 4, 5, 6, 8, 9, 10, 11, 12, 15, 16, 18, 20, 24, 25, 26, 28, 29, 30, 31, 32, 33, 34, 36, 37, 43, 44, 46, 48, 49, 51]
def residue_54 : BitsPolynomial := sparse [0, 1, 2, 4, 6, 7, 8, 9, 13, 14, 16, 18, 20, 23, 26, 27, 29, 30, 31, 32, 33, 34, 37, 39, 40, 41, 42, 48, 50, 52, 56, 58, 60, 62]
def residue_55 : BitsPolynomial := sparse [0, 3, 6, 7, 10, 11, 12, 13, 14, 15, 18, 22, 23, 24, 26, 28, 33, 35, 36, 37, 39, 40, 41, 43, 44, 46, 48, 49, 51, 52, 53, 54, 55, 57, 58, 59, 60, 61, 62, 63]
def residue_56 : BitsPolynomial := sparse [2, 3, 5, 7, 8, 13, 14, 15, 16, 21, 22, 23, 27, 28, 29, 30, 31, 33, 34, 37, 39, 40, 44, 46, 49, 51, 56]
def residue_57 : BitsPolynomial := sparse [2, 3, 7, 8, 11, 13, 14, 15, 18, 19, 20, 24, 25, 26, 27, 28, 29, 30, 31, 34, 35, 37, 39, 41, 44, 46, 48, 49, 51, 52, 54, 56, 58, 60, 62]
def residue_58 : BitsPolynomial := sparse [0, 1, 3, 4, 5, 8, 9, 11, 13, 14, 15, 16, 17, 19, 21, 24, 25, 26, 27, 28, 29, 30, 31, 33, 34, 37, 38, 39, 42, 43, 45, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
def residue_59 : BitsPolynomial := sparse [3, 4, 6, 7, 11, 12, 17, 20, 21, 24, 25, 26, 27, 28, 29, 30, 31, 34, 38, 42, 48, 50, 52, 54, 56, 58, 60, 62]
def residue_60 : BitsPolynomial := sparse [0, 1, 3, 5, 6, 7, 13, 14, 15, 16, 20, 21, 22, 23, 32, 33, 34, 35, 37, 39, 40, 41, 42, 43, 45, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
def residue_61 : BitsPolynomial := sparse [0, 1, 8, 9, 10, 11, 12, 13, 14, 15, 16, 24, 25, 26, 27, 28, 29, 30, 31, 40, 42, 44, 46]
def residue_62 : BitsPolynomial := sparse [0, 2, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 48, 50, 52, 54, 56, 58, 60, 62]
def residue_63 : BitsPolynomial := sparse [1, 3, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
def residue_64 : BitsPolynomial := sparse [1]

end ProvenHashes.ChainHash
