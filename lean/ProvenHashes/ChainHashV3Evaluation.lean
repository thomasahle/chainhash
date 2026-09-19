import ProvenHashes.ChainHashV3Model

noncomputable section
namespace ProvenHashes.ChainHash.V3
open Polynomial
open scoped BigOperators

/-- Input list is reverse chronological block order. This recursion is serial Horner. -/
def serialHorner {K : Type*} [CommSemiring K] (ell y : K) : List K → K
  | [] => ell
  | c :: cs => c + y * serialHorner ell y cs

/-- Physical lane `j` receives chronological blocks `j, j+k, ...`.
The input list is reverse chronological, so its index `i` is the final exponent.
Only actual coefficients enter the lane; unused lanes remain zero. -/
def laneState {K : Type*} [CommSemiring K] (k j : ℕ) (y : K) (cs : List K) : K :=
  ∑ i ∈ (Finset.range cs.length).filter (fun i => (cs.length-1-i) % k = j),
    cs[i]?.getD 0 * (y^k)^(i/k)

def scheduledHorner {K : Type*} [CommSemiring K] (k : ℕ) (ell y : K) (cs : List K) : K :=
  ell*y^cs.length + ∑ j ∈ Finset.range k, y^((cs.length-1-j)%k) * laneState k j y cs

theorem serialHorner_expansion {K : Type*} [CommSemiring K] (ell y : K) (cs : List K) :
    serialHorner ell y cs = ell*y^cs.length +
      ∑ i ∈ Finset.range cs.length, cs[i]?.getD 0 * y^i := by
  induction cs with
  | nil => simp [serialHorner]
  | cons c cs ih =>
    simp only [serialHorner, ih, List.length_cons, Finset.sum_range_succ']
    simp only [List.getElem?_cons_succ, List.getElem?_cons_zero, Option.getD_some,
      pow_zero, mul_one, pow_succ]
    rw [mul_add, Finset.mul_sum]
    have he : (∑ i ∈ Finset.range cs.length, cs[i]?.getD 0 * (y^i*y)) =
        ∑ i ∈ Finset.range cs.length, y * (cs[i]?.getD 0 * y^i) := by
      apply Finset.sum_congr rfl
      intro i hi
      ring
    rw [he]
    ring
-- checkpoint: serialHorner_expansion

theorem hornerValue_eq_serial {K : Type*} [CommRing K] {p : ℕ}
    (ell y : K) (c : Fin p → K) :
    hornerValue ell c y = serialHorner ell y (List.ofFn c) := by
  rw [hornerValue_expansion, serialHorner_expansion, List.length_ofFn]
  congr 1
  rw [← Fin.sum_univ_eq_sum_range]
  apply Finset.sum_congr rfl
  intro i hi
  simp [List.getElem?_ofFn, i.isLt]
-- checkpoint: hornerValue_eq_serial

theorem scheduledHorner_eq_serial {K : Type*} [CommSemiring K]
    (k : ℕ) (hk : 0 < k) : scheduledHorner (K := K) k = serialHorner := by
  funext ell y cs
  rw [serialHorner_expansion]
  unfold scheduledHorner laneState
  congr 1
  simp_rw [Finset.mul_sum]
  have he (j i : ℕ) (hi : i ∈ (Finset.range cs.length).filter (fun i => (cs.length-1-i)%k=j)) :
      y^((cs.length-1-j)%k) * (cs[i]?.getD 0 * (y^k)^(i/k)) = cs[i]?.getD 0 * y^i := by
    have hij : (cs.length-1-i)%k=j := (Finset.mem_filter.mp hi).2
    have hiL : i < cs.length := Finset.mem_range.mp (Finset.mem_filter.mp hi).1
    have hn : cs.length-1-i ≤ cs.length-1 := Nat.sub_le _ _
    have hjle : j ≤ cs.length-1-i := hij ▸ Nat.mod_le (cs.length-1-i) k
    have hjlt : j < k := hij ▸ Nat.mod_lt (cs.length-1-i) hk
    have hm : Nat.ModEq k (cs.length-1-i) j := by
      change (cs.length-1-i)%k=j%k
      rw [hij, Nat.mod_eq_of_lt hjlt]
    have ht := Nat.ModEq.sub_left hn (hjle.trans hn) hm
    have he : cs.length-1-(cs.length-1-i)=i := by omega
    rw [he] at ht
    change i%k=(cs.length-1-j)%k at ht
    rw [← ht, ← pow_mul]
    calc
      _ = cs[i]?.getD 0 * (y^(i%k) * y^(k*(i/k))) := by ring
      _ = _ := by rw [← pow_add, Nat.mod_add_div]
  simp_rw [Finset.sum_congr rfl (fun i hi => he _ i hi)]
  exact Finset.sum_fiberwise_of_maps_to
    (fun i _ => Finset.mem_range.mpr (Nat.mod_lt (cs.length-1-i) hk)) _
-- checkpoint: scheduledHorner_eq_serial

/-- Reduction commutes with arbitrary serial Horner evaluation. -/
theorem map_serialHorner {R K : Type*} [CommSemiring R] [CommSemiring K]
    (reduce : R →+* K) (ell y : R) (cs : List R) :
    reduce (serialHorner ell y cs) = serialHorner (reduce ell) (reduce y) (cs.map reduce) := by
  induction cs with
  | nil => rfl
  | cons c cs ih => simp only [serialHorner, List.map_cons, map_add, map_mul, ih]
-- checkpoint: map_serialHorner

/-- Serial, arbitrary-stride exact-count schedule, and unreduced polynomial state
have identical reductions. This statement is an equality of functions on raw lists. -/
theorem evaluation_independence (k : ℕ) (hk : 0 < k) (ell y : BitsPolynomial) :
    (fun cs => (AdjoinRoot.mk modulus) (serialHorner ell y cs)) =
      (fun cs => scheduledHorner k ((AdjoinRoot.mk modulus) ell)
        ((AdjoinRoot.mk modulus) y) (cs.map (AdjoinRoot.mk modulus))) := by
  funext cs
  rw [scheduledHorner_eq_serial k hk]
  exact map_serialHorner (AdjoinRoot.mk modulus) ell y cs
-- checkpoint: evaluation_independence

def scheduledHash (stride : ℕ) (k : IdealKey) (m : Message) : F :=
  chain5 k.2.2 (integerTwist fieldIntegerEquiv k.2.1
    (scheduledHorner stride (lengthField m.length) k.1.2 (List.ofFn (coefficients m k.1.1))))

theorem hash_evaluation_independence (stride : ℕ) (hstride : 0 < stride) :
    scheduledHash stride = hash := by
  funext k m
  simp only [scheduledHash, hash, scheduledHorner_eq_serial stride hstride,
    hornerValue_eq_serial]
-- checkpoint: hash_evaluation_independence

end ProvenHashes.ChainHash.V3
