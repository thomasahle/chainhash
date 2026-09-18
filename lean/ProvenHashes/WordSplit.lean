import ProvenHashes.Subblocks

noncomputable section
namespace ProvenHashes.ChainEncoding
open Carryless Polynomial

/-- The low and high 64-bit halves of the unreduced accumulator. -/
def unpack : (ZMod 2)[X] →+ (Word 64 × Word 64) where
  toFun p := (fun i => p.coeff i.val, fun i => p.coeff (i.val + 64))
  map_zero' := by ext i <;> simp
  map_add' p q := by ext i <;> simp

def pack : (Word 64 × Word 64) →+ (ZMod 2)[X] where
  toFun v := toPoly v.1 + toPoly v.2 * X ^ 64
  map_zero' := by simp [toPoly]
  map_add' v w := by simp [toPoly, add_mul]; ring

theorem unpack_pack (v : Word 64 × Word 64) : unpack (pack v) = v := by
  apply Prod.ext
  · funext i
    have hi := i.isLt
    simp [pack, unpack, toPoly, Polynomial.coeff_mul_X_pow', Nat.not_le_of_lt hi]
  · funext i
    have hi := i.isLt
    simp [pack, unpack, toPoly]

theorem pack_injective : Function.Injective pack :=
  Function.LeftInverse.injective unpack_pack

/-- Splitting loses no information because the accumulator has degree <128. -/
theorem pack_unpack (p : (ZMod 2)[X]) (hp : p.degree < 128) : pack (unpack p) = p := by
  ext i
  by_cases hi : i < 64
  · simp [pack, unpack, toPoly, Polynomial.coeff_mul_X_pow', hi, Nat.not_le_of_lt hi]
  · have hi' : 64 ≤ i := by omega
    by_cases hi128 : i < 128
    · have hm : i - 64 < 64 := by omega
      have he : i - 64 + 64 = i := by omega
      simp [pack, unpack, toPoly, Polynomial.coeff_mul_X_pow', hi',
        Polynomial.ofFn_coeff_eq_zero_of_ge _ hi', hm, he]
    · have h128 : 128 ≤ i := by omega
      have hz := (Polynomial.degree_lt_iff_coeff_zero p 128).mp hp i h128
      simp [pack, unpack, toPoly, Polynomial.coeff_mul_X_pow', hi',
        Polynomial.ofFn_coeff_eq_zero_of_ge _ hi',
        Polynomial.ofFn_coeff_eq_zero_of_ge _ (by omega : 64 ≤ i - 64), hz]

def lengthTag (n : ℕ) : Word 64 × Word 64 := (lengthWord n, lengthWord n)

/-- Different representable byte lengths supply the nonzero target needed
by the unequal-count CLNH theorem. Both halves contain the same XOR. -/
theorem length_target_ne_zero {n m : ℕ}
    (hn : n < 2 ^ 64) (hm : m < 2 ^ 64) (hne : n ≠ m) :
    pack (lengthTag n + lengthTag m) ≠ 0 := by
  intro h
  have hz : lengthTag n + lengthTag m = 0 := pack_injective (by simpa using h)
  have hl : lengthWord n + lengthWord m = 0 := congrArg Prod.fst hz
  have he : lengthWord n = lengthWord m := by
    simpa only [← sub_eq_add_neg, CharTwo.neg_eq] using (sub_eq_zero.mp
      (show lengthWord n - lengthWord m = 0 by simpa only [sub_eq_add_neg, CharTwo.neg_eq] using hl))
  exact hne (lengthWord_injective_below hn hm he)

theorem tagged_equality_target (p q : (ZMod 2)[X]) (hp : p.degree < 128) (hq : q.degree < 128)
    (n m : ℕ) (h : unpack p + lengthTag n = unpack q + lengthTag m) :
    p + q = pack (lengthTag n + lengthTag m) := by
  have hh := congrArg pack h
  simp only [map_add, pack_unpack p hp, pack_unpack q hq] at hh
  have he : p - q = pack (lengthTag m) - pack (lengthTag n) :=
    sub_eq_sub_iff_add_eq_add.mpr (hh.trans (add_comm _ _))
  simpa only [sub_eq_add_neg, CharTwo.neg_eq, map_add, add_comm] using he

end ProvenHashes.ChainEncoding
