import ProvenHashes.BinaryRabin

noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash
open Polynomial

/-- The reduction polynomial in both shipped implementations (low constant 135). -/
def modulus : BitsPolynomial := X ^ 128 + (X ^ 7 + X ^ 2 + X + 1)

theorem modulus_tail_degree : (X ^ 7 + X ^ 2 + X + 1 : BitsPolynomial).degree < 128 := by
  apply lt_of_le_of_lt (degree_add_le _ _)
  apply max_lt
  · apply lt_of_le_of_lt (degree_add_le _ _)
    apply max_lt
    · apply lt_of_le_of_lt (degree_add_le _ _)
      norm_num
    · simp
  · simp

theorem modulus_monic : modulus.Monic := monic_X_pow_add modulus_tail_degree

theorem modulus_degree : modulus.natDegree = 128 := by
  unfold modulus
  rw [natDegree_eq_of_degree_eq (degree_add_eq_left_of_degree_lt (by
    simpa using modulus_tail_degree))]
  simp

theorem square_test : ((X + 1 : BitsPolynomial) ^ 2) = X ^ 2 + 1 := by
  ring_nf
  have htwo : (2 : BitsPolynomial) = 0 := CharP.cast_eq_zero _ 2
  simp [htwo]

end ProvenHashes.ChainHash128
