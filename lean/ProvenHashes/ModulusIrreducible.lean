import ProvenHashes.ModulusCertificate

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial

 theorem residue_power_step (i : ℕ) (r s q : BitsPolynomial)
    (hs : r ^ 2 = s + modulus * q)
    (hr : AdjoinRoot.root modulus ^ (2 ^ i) = AdjoinRoot.mk modulus r) :
    AdjoinRoot.root modulus ^ (2 ^ (i + 1)) = AdjoinRoot.mk modulus s := by
  have hp : (2 ^ (i + 1) : ℕ) = 2 ^ i * 2 := pow_succ _ _
  rw [hp, pow_mul, hr, ← map_pow, hs, map_add, map_mul,
    AdjoinRoot.mk_self, zero_mul, add_zero]

theorem modulus_frobenius_certificates :
    modulus ∣ X ^ (2 ^ 64) - X ∧ modulus ∣ X ^ (2 ^ 32) - residue_32 := by
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
  constructor
  · apply AdjoinRoot.mk_eq_zero.mp
    rw [map_sub, map_pow, AdjoinRoot.mk_X, h64]
    simp [residue_64, sparse, AdjoinRoot.mk_X]
  · apply AdjoinRoot.mk_eq_zero.mp
    rw [map_sub, map_pow, AdjoinRoot.mk_X, h32, sub_self]

theorem modulus_irreducible : Irreducible modulus := by
  obtain ⟨h64, h32⟩ := modulus_frobenius_certificates
  apply binary_rabin64 modulus modulus_monic modulus_degree h64
  obtain ⟨q, hq⟩ := h32
  let a : BitsPolynomial := sparse [2, 3, 5, 7, 11, 12, 15, 17, 18, 20, 21, 22, 25, 26, 32, 35, 37, 38, 41, 46, 48, 57, 60]
  let b : BitsPolynomial := sparse [0, 1, 2, 6, 7, 8, 11, 15, 17, 19, 20, 22, 24, 25, 26, 27, 28, 29, 31, 32, 37, 38, 40, 44, 46, 47, 49, 51, 54, 55, 56, 57, 60, 62]
  refine ⟨a - b * q, b, ?_⟩
  have hx : X ^ (2 ^ 32) = modulus * q + residue_32 := sub_eq_iff_eq_add.mp hq
  rw [hx]
  calc
    _ = modulus * a + (residue_32 - X) * b := by ring
    _ = 1 := residue_bezout

end ProvenHashes.ChainHash
