import ProvenHashes.ChainHash128.ModulusCertificate

noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash
open Polynomial
set_option maxRecDepth 4096

 theorem residue_power_step (i : ℕ) (r s q : BitsPolynomial)
    (hs : r ^ 2 = s + modulus * q)
    (hr : AdjoinRoot.root modulus ^ (2 ^ i) = AdjoinRoot.mk modulus r) :
    AdjoinRoot.root modulus ^ (2 ^ (i + 1)) = AdjoinRoot.mk modulus s := by
  have hp : (2 ^ (i + 1) : ℕ) = 2 ^ i * 2 := pow_succ _ _
  rw [hp, pow_mul, hr, ← map_pow, hs, map_add, map_mul,
    AdjoinRoot.mk_self, zero_mul, add_zero]

theorem modulus_frobenius_certificates :
    modulus ∣ X ^ (2 ^ 128) - X ∧ modulus ∣ X ^ (2 ^ 64) - residue_64 := by
  have h0 : AdjoinRoot.root modulus ^ (2 ^ 0) = AdjoinRoot.mk modulus residue_0 := by
    simp [residue_0, sparse, AdjoinRoot.mk_X]
  have h1 := residue_power_step 0 _ _ _ residue_step_0 h0
  have h2 := residue_power_step 1 _ _ _ residue_step_1 h1
  have h3 := residue_power_step 2 _ _ _ residue_step_2 h2
  have h4 := residue_power_step 3 _ _ _ residue_step_3 h3
  have h5 := residue_power_step 4 _ _ _ residue_step_4 h4
  have h6 := residue_power_step 5 _ _ _ residue_step_5 h5
  have h7 := residue_power_step 6 _ _ _ residue_step_6 h6
  have h8 := residue_power_step 7 _ _ _ residue_step_7 h7
  have h9 := residue_power_step 8 _ _ _ residue_step_8 h8
  have h10 := residue_power_step 9 _ _ _ residue_step_9 h9
  have h11 := residue_power_step 10 _ _ _ residue_step_10 h10
  have h12 := residue_power_step 11 _ _ _ residue_step_11 h11
  have h13 := residue_power_step 12 _ _ _ residue_step_12 h12
  have h14 := residue_power_step 13 _ _ _ residue_step_13 h13
  have h15 := residue_power_step 14 _ _ _ residue_step_14 h14
  have h16 := residue_power_step 15 _ _ _ residue_step_15 h15
  have h17 := residue_power_step 16 _ _ _ residue_step_16 h16
  have h18 := residue_power_step 17 _ _ _ residue_step_17 h17
  have h19 := residue_power_step 18 _ _ _ residue_step_18 h18
  have h20 := residue_power_step 19 _ _ _ residue_step_19 h19
  have h21 := residue_power_step 20 _ _ _ residue_step_20 h20
  have h22 := residue_power_step 21 _ _ _ residue_step_21 h21
  have h23 := residue_power_step 22 _ _ _ residue_step_22 h22
  have h24 := residue_power_step 23 _ _ _ residue_step_23 h23
  have h25 := residue_power_step 24 _ _ _ residue_step_24 h24
  have h26 := residue_power_step 25 _ _ _ residue_step_25 h25
  have h27 := residue_power_step 26 _ _ _ residue_step_26 h26
  have h28 := residue_power_step 27 _ _ _ residue_step_27 h27
  have h29 := residue_power_step 28 _ _ _ residue_step_28 h28
  have h30 := residue_power_step 29 _ _ _ residue_step_29 h29
  have h31 := residue_power_step 30 _ _ _ residue_step_30 h30
  have h32 := residue_power_step 31 _ _ _ residue_step_31 h31
  have h33 := residue_power_step 32 _ _ _ residue_step_32 h32
  have h34 := residue_power_step 33 _ _ _ residue_step_33 h33
  have h35 := residue_power_step 34 _ _ _ residue_step_34 h34
  have h36 := residue_power_step 35 _ _ _ residue_step_35 h35
  have h37 := residue_power_step 36 _ _ _ residue_step_36 h36
  have h38 := residue_power_step 37 _ _ _ residue_step_37 h37
  have h39 := residue_power_step 38 _ _ _ residue_step_38 h38
  have h40 := residue_power_step 39 _ _ _ residue_step_39 h39
  have h41 := residue_power_step 40 _ _ _ residue_step_40 h40
  have h42 := residue_power_step 41 _ _ _ residue_step_41 h41
  have h43 := residue_power_step 42 _ _ _ residue_step_42 h42
  have h44 := residue_power_step 43 _ _ _ residue_step_43 h43
  have h45 := residue_power_step 44 _ _ _ residue_step_44 h44
  have h46 := residue_power_step 45 _ _ _ residue_step_45 h45
  have h47 := residue_power_step 46 _ _ _ residue_step_46 h46
  have h48 := residue_power_step 47 _ _ _ residue_step_47 h47
  have h49 := residue_power_step 48 _ _ _ residue_step_48 h48
  have h50 := residue_power_step 49 _ _ _ residue_step_49 h49
  have h51 := residue_power_step 50 _ _ _ residue_step_50 h50
  have h52 := residue_power_step 51 _ _ _ residue_step_51 h51
  have h53 := residue_power_step 52 _ _ _ residue_step_52 h52
  have h54 := residue_power_step 53 _ _ _ residue_step_53 h53
  have h55 := residue_power_step 54 _ _ _ residue_step_54 h54
  have h56 := residue_power_step 55 _ _ _ residue_step_55 h55
  have h57 := residue_power_step 56 _ _ _ residue_step_56 h56
  have h58 := residue_power_step 57 _ _ _ residue_step_57 h57
  have h59 := residue_power_step 58 _ _ _ residue_step_58 h58
  have h60 := residue_power_step 59 _ _ _ residue_step_59 h59
  have h61 := residue_power_step 60 _ _ _ residue_step_60 h60
  have h62 := residue_power_step 61 _ _ _ residue_step_61 h61
  have h63 := residue_power_step 62 _ _ _ residue_step_62 h62
  have h64 := residue_power_step 63 _ _ _ residue_step_63 h63
  have h65 := residue_power_step 64 _ _ _ residue_step_64 h64
  have h66 := residue_power_step 65 _ _ _ residue_step_65 h65
  have h67 := residue_power_step 66 _ _ _ residue_step_66 h66
  have h68 := residue_power_step 67 _ _ _ residue_step_67 h67
  have h69 := residue_power_step 68 _ _ _ residue_step_68 h68
  have h70 := residue_power_step 69 _ _ _ residue_step_69 h69
  have h71 := residue_power_step 70 _ _ _ residue_step_70 h70
  have h72 := residue_power_step 71 _ _ _ residue_step_71 h71
  have h73 := residue_power_step 72 _ _ _ residue_step_72 h72
  have h74 := residue_power_step 73 _ _ _ residue_step_73 h73
  have h75 := residue_power_step 74 _ _ _ residue_step_74 h74
  have h76 := residue_power_step 75 _ _ _ residue_step_75 h75
  have h77 := residue_power_step 76 _ _ _ residue_step_76 h76
  have h78 := residue_power_step 77 _ _ _ residue_step_77 h77
  have h79 := residue_power_step 78 _ _ _ residue_step_78 h78
  have h80 := residue_power_step 79 _ _ _ residue_step_79 h79
  have h81 := residue_power_step 80 _ _ _ residue_step_80 h80
  have h82 := residue_power_step 81 _ _ _ residue_step_81 h81
  have h83 := residue_power_step 82 _ _ _ residue_step_82 h82
  have h84 := residue_power_step 83 _ _ _ residue_step_83 h83
  have h85 := residue_power_step 84 _ _ _ residue_step_84 h84
  have h86 := residue_power_step 85 _ _ _ residue_step_85 h85
  have h87 := residue_power_step 86 _ _ _ residue_step_86 h86
  have h88 := residue_power_step 87 _ _ _ residue_step_87 h87
  have h89 := residue_power_step 88 _ _ _ residue_step_88 h88
  have h90 := residue_power_step 89 _ _ _ residue_step_89 h89
  have h91 := residue_power_step 90 _ _ _ residue_step_90 h90
  have h92 := residue_power_step 91 _ _ _ residue_step_91 h91
  have h93 := residue_power_step 92 _ _ _ residue_step_92 h92
  have h94 := residue_power_step 93 _ _ _ residue_step_93 h93
  have h95 := residue_power_step 94 _ _ _ residue_step_94 h94
  have h96 := residue_power_step 95 _ _ _ residue_step_95 h95
  have h97 := residue_power_step 96 _ _ _ residue_step_96 h96
  have h98 := residue_power_step 97 _ _ _ residue_step_97 h97
  have h99 := residue_power_step 98 _ _ _ residue_step_98 h98
  have h100 := residue_power_step 99 _ _ _ residue_step_99 h99
  have h101 := residue_power_step 100 _ _ _ residue_step_100 h100
  have h102 := residue_power_step 101 _ _ _ residue_step_101 h101
  have h103 := residue_power_step 102 _ _ _ residue_step_102 h102
  have h104 := residue_power_step 103 _ _ _ residue_step_103 h103
  have h105 := residue_power_step 104 _ _ _ residue_step_104 h104
  have h106 := residue_power_step 105 _ _ _ residue_step_105 h105
  have h107 := residue_power_step 106 _ _ _ residue_step_106 h106
  have h108 := residue_power_step 107 _ _ _ residue_step_107 h107
  have h109 := residue_power_step 108 _ _ _ residue_step_108 h108
  have h110 := residue_power_step 109 _ _ _ residue_step_109 h109
  have h111 := residue_power_step 110 _ _ _ residue_step_110 h110
  have h112 := residue_power_step 111 _ _ _ residue_step_111 h111
  have h113 := residue_power_step 112 _ _ _ residue_step_112 h112
  have h114 := residue_power_step 113 _ _ _ residue_step_113 h113
  have h115 := residue_power_step 114 _ _ _ residue_step_114 h114
  have h116 := residue_power_step 115 _ _ _ residue_step_115 h115
  have h117 := residue_power_step 116 _ _ _ residue_step_116 h116
  have h118 := residue_power_step 117 _ _ _ residue_step_117 h117
  have h119 := residue_power_step 118 _ _ _ residue_step_118 h118
  have h120 := residue_power_step 119 _ _ _ residue_step_119 h119
  have h121 := residue_power_step 120 _ _ _ residue_step_120 h120
  have h122 := residue_power_step 121 _ _ _ residue_step_121 h121
  have h123 := residue_power_step 122 _ _ _ residue_step_122 h122
  have h124 := residue_power_step 123 _ _ _ residue_step_123 h123
  have h125 := residue_power_step 124 _ _ _ residue_step_124 h124
  have h126 := residue_power_step 125 _ _ _ residue_step_125 h125
  have h127 := residue_power_step 126 _ _ _ residue_step_126 h126
  have h128 := residue_power_step 127 _ _ _ residue_step_127 h127
  constructor
  · apply AdjoinRoot.mk_eq_zero.mp
    rw [map_sub, map_pow, AdjoinRoot.mk_X, h128]
    simp [residue_128, sparse, AdjoinRoot.mk_X]
  · apply AdjoinRoot.mk_eq_zero.mp
    rw [map_sub, map_pow, AdjoinRoot.mk_X, h64, sub_self]

theorem modulus_irreducible : Irreducible modulus := by
  obtain ⟨h128, h64⟩ := modulus_frobenius_certificates
  apply binary_rabin128 modulus modulus_monic modulus_degree h128
  obtain ⟨q, hq⟩ := h64
  let a : BitsPolynomial := sparse [0, 1, 3, 4, 5, 6, 10, 12, 14, 16, 17, 21, 22, 23, 24, 25, 28, 29, 30, 32, 33, 34, 35, 36, 40, 42, 46, 47, 49, 50, 51, 54, 56, 61, 65, 66, 68, 69, 75, 76, 78, 83, 85, 86, 88, 89, 91, 92, 93, 94, 95, 96, 98, 101, 103, 104, 107, 108, 112, 113, 116, 117, 118, 119, 122, 124, 125]
  let b : BitsPolynomial := sparse [3, 4, 12, 13, 15, 16, 18, 20, 23, 26, 27, 29, 32, 34, 35, 36, 37, 38, 39, 41, 43, 46, 47, 51, 53, 55, 56, 62, 65, 67, 71, 72, 73, 79, 82, 83, 84, 85, 87, 88, 90, 91, 92, 94, 95, 99, 101, 104, 107, 108, 109, 110, 111, 113, 115, 118, 121, 122, 123, 124, 127]
  refine ⟨a - b * q, b, ?_⟩
  have hx : X ^ (2 ^ 64) = modulus * q + residue_64 := sub_eq_iff_eq_add.mp hq
  rw [hx]
  calc
    _ = modulus * a + (residue_64 - X) * b := by ring
    _ = 1 := residue_bezout

end ProvenHashes.ChainHash128
