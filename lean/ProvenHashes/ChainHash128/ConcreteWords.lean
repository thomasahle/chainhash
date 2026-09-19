import ProvenHashes.ChainHash128.Modulus

noncomputable section
namespace ProvenHashes.ChainHash128
open ProvenHashes.ChainHash
open Polynomial


/-- The low 128 coefficients of a polynomial, as a word. -/
def lowWord (p : BitsPolynomial) : Word 128 := fun i => p.coeff i.val
/-- Coefficients 128 to 255 of a polynomial, as a word. -/
def highWord (p : BitsPolynomial) : Word 128 := fun i => p.coeff (i.val + 128)

/-- The 128-bit instance of the width-generic bound `clnh_natDegree_le_width`. -/
theorem clnh_natDegree_le {I : Type*} [DecidableEq I]
    (s : Finset I) (m k : I × Bool → Word 128) : (clnh s m k).natDegree ≤ 254 := by
  have h := clnh_natDegree_le_width (by omega : 1 ≤ 128) s m k
  omega

abbrev BinaryQuotient := AdjoinRoot modulus

theorem modulus_ne_one : modulus ≠ 1 := by
  intro h
  have he := congrArg Polynomial.natDegree h
  rw [modulus_degree, Polynomial.natDegree_one] at he
  omega

theorem quotient_remainder_degree (a : BinaryQuotient) :
    (AdjoinRoot.modByMonicHom modulus_monic a).natDegree < 128 := by
  induction a using AdjoinRoot.induction_on with
  | ih p =>
    rw [AdjoinRoot.modByMonicHom_mk]
    simpa only [modulus_degree] using
      Polynomial.natDegree_modByMonic_lt p modulus_monic modulus_ne_one

/-- The canonical polynomial-basis representation, with a concrete remainder decoder. -/
def fieldRepr : Word 128 ≃+ BinaryQuotient where
  toFun v := AdjoinRoot.mk modulus (pack 128 v)
  invFun a := lowWord (AdjoinRoot.modByMonicHom modulus_monic a)
  left_inv v := by
    have hd : (pack 128 v).degree < modulus.degree := by
      rw [degree_eq_natDegree modulus_monic.ne_zero, modulus_degree]
      exact Polynomial.ofFn_degree_lt v
    have hr : (pack 128 v) %ₘ modulus = pack 128 v := (Polynomial.modByMonic_eq_self_iff modulus_monic).mpr hd
    funext i
    simp only [AdjoinRoot.modByMonicHom_mk, hr, lowWord]
    exact Polynomial.ofFn_coeff_eq_val_of_lt v i.isLt
  right_inv a := by
    have hp : pack 128 (lowWord (AdjoinRoot.modByMonicHom modulus_monic a)) =
        AdjoinRoot.modByMonicHom modulus_monic a :=
      Polynomial.ofFn_comp_toFn_eq_id_of_natDegree_lt (quotient_remainder_degree a)
    dsimp only
    rw [hp]
    exact AdjoinRoot.mk_leftInverse modulus_monic a
  map_add' v w := by simp only [map_add]

instance : Fintype BinaryQuotient := Fintype.ofEquiv (Word 128) fieldRepr.toEquiv

/-- Multiplication is exactly unreduced carry-less multiplication followed by
remainder modulo X^128 + X^7 + X^2 + X + 1, read back as 128 bits. -/
theorem fieldRepr_mul (v w : Word 128) :
    fieldRepr.symm (fieldRepr v * fieldRepr w) =
      lowWord ((pack 128 v * pack 128 w) %ₘ modulus) := by
  change lowWord (AdjoinRoot.modByMonicHom modulus_monic
    (AdjoinRoot.mk modulus (pack 128 v) * AdjoinRoot.mk modulus (pack 128 w))) = _
  rw [← map_mul, AdjoinRoot.modByMonicHom_mk]


/-- Any type in additive bijection with `Word 128` has `2^128` elements. -/
theorem field_card {F : Type*} [AddGroup F] [Fintype F] (repr : Word 128 ≃+ F) :
    Fintype.card F = 2 ^ 128 :=
  (Fintype.card_congr repr.toEquiv).symm.trans (word_card 128)

end ProvenHashes.ChainHash128
