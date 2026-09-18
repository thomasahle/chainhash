import ProvenHashes.Modulus
import ProvenHashes.FieldStream

noncomputable section
namespace ProvenHashes.ChainHash
open Polynomial

abbrev BinaryQuotient := AdjoinRoot modulus

theorem modulus_ne_one : modulus ≠ 1 := by
  intro h
  have he := congrArg Polynomial.natDegree h
  rw [modulus_degree, Polynomial.natDegree_one] at he
  omega

theorem quotient_remainder_degree (a : BinaryQuotient) :
    (AdjoinRoot.modByMonicHom modulus_monic a).natDegree < 64 := by
  induction a using AdjoinRoot.induction_on with
  | ih p =>
    rw [AdjoinRoot.modByMonicHom_mk]
    simpa only [modulus_degree] using
      Polynomial.natDegree_modByMonic_lt p modulus_monic modulus_ne_one

/-- The canonical polynomial-basis representation, with a concrete remainder decoder. -/
def fieldRepr : Word 64 ≃+ BinaryQuotient where
  toFun v := AdjoinRoot.mk modulus (pack 64 v)
  invFun a := lowWord (AdjoinRoot.modByMonicHom modulus_monic a)
  left_inv v := by
    have hd : (pack 64 v).degree < modulus.degree := by
      rw [degree_eq_natDegree modulus_monic.ne_zero, modulus_degree]
      exact Polynomial.ofFn_degree_lt v
    have hr : (pack 64 v) %ₘ modulus = pack 64 v := (Polynomial.modByMonic_eq_self_iff modulus_monic).mpr hd
    funext i
    simp only [AdjoinRoot.modByMonicHom_mk, hr, lowWord]
    exact Polynomial.ofFn_coeff_eq_val_of_lt v i.isLt
  right_inv a := by
    have hp : pack 64 (lowWord (AdjoinRoot.modByMonicHom modulus_monic a)) =
        AdjoinRoot.modByMonicHom modulus_monic a :=
      Polynomial.ofFn_comp_toFn_eq_id_of_natDegree_lt (quotient_remainder_degree a)
    dsimp only
    rw [hp]
    exact AdjoinRoot.mk_leftInverse modulus_monic a
  map_add' v w := by simp only [map_add]

instance : Fintype BinaryQuotient := Fintype.ofEquiv (Word 64) fieldRepr.toEquiv

/-- Multiplication is exactly unreduced carry-less multiplication followed by
remainder modulo X^64 + X^4 + X^3 + X + 1, read back as 64 bits. -/
theorem fieldRepr_mul (v w : Word 64) :
    fieldRepr.symm (fieldRepr v * fieldRepr w) =
      lowWord ((pack 64 v * pack 64 w) %ₘ modulus) := by
  change lowWord (AdjoinRoot.modByMonicHom modulus_monic
    (AdjoinRoot.mk modulus (pack 64 v) * AdjoinRoot.mk modulus (pack 64 w))) = _
  rw [← map_mul, AdjoinRoot.modByMonicHom_mk]

end ProvenHashes.ChainHash
