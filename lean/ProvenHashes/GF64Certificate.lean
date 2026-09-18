import ProvenHashes.GF64Square0
import ProvenHashes.GF64Square1
import ProvenHashes.GF64Square2
import ProvenHashes.GF64Square3
import ProvenHashes.GF64Square4
import ProvenHashes.GF64Square5
import ProvenHashes.GF64Square6
import ProvenHashes.GF64Square7
import ProvenHashes.GF64Bezout
noncomputable section
namespace ProvenHashes.GF64Certificate
open Polynomial
set_option maxHeartbeats 4000000
set_option maxRecDepth 4096
set_option linter.unusedSimpArgs false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false
lemma square_eval {A : Type*} [CommRing A] [Algebra (ZMod 2) A]
    (x : A) (hx : aeval x modulus = 0) {p q s : (ZMod 2)[X]}
    (h : p ^ 2 = q + modulus * s) : (aeval x p) ^ 2 = aeval x q := by
  have hh := congrArg (aeval x) h
  simpa only [map_pow, map_add, map_mul, hx, zero_mul, add_zero] using hh

theorem root_pow32 {A : Type*} [CommRing A] [Algebra (ZMod 2) A]
    (x : A) (hx : aeval x modulus = 0) :
    x ^ (2 ^ 32) = aeval x r32 := by
  have h0 : x ^ (2 ^ 0) = aeval x r0 := by simp [r0]
  have h1 : x ^ (2 ^ 1) = aeval x r1 := by
    calc
      _ = (x ^ (2 ^ 0)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r0) ^ 2 := congrArg (fun v => v ^ 2) h0
      _ = _ := square_eval x hx square_0
  have h2 : x ^ (2 ^ 2) = aeval x r2 := by
    calc
      _ = (x ^ (2 ^ 1)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r1) ^ 2 := congrArg (fun v => v ^ 2) h1
      _ = _ := square_eval x hx square_1
  have h3 : x ^ (2 ^ 3) = aeval x r3 := by
    calc
      _ = (x ^ (2 ^ 2)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r2) ^ 2 := congrArg (fun v => v ^ 2) h2
      _ = _ := square_eval x hx square_2
  have h4 : x ^ (2 ^ 4) = aeval x r4 := by
    calc
      _ = (x ^ (2 ^ 3)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r3) ^ 2 := congrArg (fun v => v ^ 2) h3
      _ = _ := square_eval x hx square_3
  have h5 : x ^ (2 ^ 5) = aeval x r5 := by
    calc
      _ = (x ^ (2 ^ 4)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r4) ^ 2 := congrArg (fun v => v ^ 2) h4
      _ = _ := square_eval x hx square_4
  have h6 : x ^ (2 ^ 6) = aeval x r6 := by
    calc
      _ = (x ^ (2 ^ 5)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r5) ^ 2 := congrArg (fun v => v ^ 2) h5
      _ = _ := square_eval x hx square_5
  have h7 : x ^ (2 ^ 7) = aeval x r7 := by
    calc
      _ = (x ^ (2 ^ 6)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r6) ^ 2 := congrArg (fun v => v ^ 2) h6
      _ = _ := square_eval x hx square_6
  have h8 : x ^ (2 ^ 8) = aeval x r8 := by
    calc
      _ = (x ^ (2 ^ 7)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r7) ^ 2 := congrArg (fun v => v ^ 2) h7
      _ = _ := square_eval x hx square_7
  have h9 : x ^ (2 ^ 9) = aeval x r9 := by
    calc
      _ = (x ^ (2 ^ 8)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r8) ^ 2 := congrArg (fun v => v ^ 2) h8
      _ = _ := square_eval x hx square_8
  have h10 : x ^ (2 ^ 10) = aeval x r10 := by
    calc
      _ = (x ^ (2 ^ 9)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r9) ^ 2 := congrArg (fun v => v ^ 2) h9
      _ = _ := square_eval x hx square_9
  have h11 : x ^ (2 ^ 11) = aeval x r11 := by
    calc
      _ = (x ^ (2 ^ 10)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r10) ^ 2 := congrArg (fun v => v ^ 2) h10
      _ = _ := square_eval x hx square_10
  have h12 : x ^ (2 ^ 12) = aeval x r12 := by
    calc
      _ = (x ^ (2 ^ 11)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r11) ^ 2 := congrArg (fun v => v ^ 2) h11
      _ = _ := square_eval x hx square_11
  have h13 : x ^ (2 ^ 13) = aeval x r13 := by
    calc
      _ = (x ^ (2 ^ 12)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r12) ^ 2 := congrArg (fun v => v ^ 2) h12
      _ = _ := square_eval x hx square_12
  have h14 : x ^ (2 ^ 14) = aeval x r14 := by
    calc
      _ = (x ^ (2 ^ 13)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r13) ^ 2 := congrArg (fun v => v ^ 2) h13
      _ = _ := square_eval x hx square_13
  have h15 : x ^ (2 ^ 15) = aeval x r15 := by
    calc
      _ = (x ^ (2 ^ 14)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r14) ^ 2 := congrArg (fun v => v ^ 2) h14
      _ = _ := square_eval x hx square_14
  have h16 : x ^ (2 ^ 16) = aeval x r16 := by
    calc
      _ = (x ^ (2 ^ 15)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r15) ^ 2 := congrArg (fun v => v ^ 2) h15
      _ = _ := square_eval x hx square_15
  have h17 : x ^ (2 ^ 17) = aeval x r17 := by
    calc
      _ = (x ^ (2 ^ 16)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r16) ^ 2 := congrArg (fun v => v ^ 2) h16
      _ = _ := square_eval x hx square_16
  have h18 : x ^ (2 ^ 18) = aeval x r18 := by
    calc
      _ = (x ^ (2 ^ 17)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r17) ^ 2 := congrArg (fun v => v ^ 2) h17
      _ = _ := square_eval x hx square_17
  have h19 : x ^ (2 ^ 19) = aeval x r19 := by
    calc
      _ = (x ^ (2 ^ 18)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r18) ^ 2 := congrArg (fun v => v ^ 2) h18
      _ = _ := square_eval x hx square_18
  have h20 : x ^ (2 ^ 20) = aeval x r20 := by
    calc
      _ = (x ^ (2 ^ 19)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r19) ^ 2 := congrArg (fun v => v ^ 2) h19
      _ = _ := square_eval x hx square_19
  have h21 : x ^ (2 ^ 21) = aeval x r21 := by
    calc
      _ = (x ^ (2 ^ 20)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r20) ^ 2 := congrArg (fun v => v ^ 2) h20
      _ = _ := square_eval x hx square_20
  have h22 : x ^ (2 ^ 22) = aeval x r22 := by
    calc
      _ = (x ^ (2 ^ 21)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r21) ^ 2 := congrArg (fun v => v ^ 2) h21
      _ = _ := square_eval x hx square_21
  have h23 : x ^ (2 ^ 23) = aeval x r23 := by
    calc
      _ = (x ^ (2 ^ 22)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r22) ^ 2 := congrArg (fun v => v ^ 2) h22
      _ = _ := square_eval x hx square_22
  have h24 : x ^ (2 ^ 24) = aeval x r24 := by
    calc
      _ = (x ^ (2 ^ 23)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r23) ^ 2 := congrArg (fun v => v ^ 2) h23
      _ = _ := square_eval x hx square_23
  have h25 : x ^ (2 ^ 25) = aeval x r25 := by
    calc
      _ = (x ^ (2 ^ 24)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r24) ^ 2 := congrArg (fun v => v ^ 2) h24
      _ = _ := square_eval x hx square_24
  have h26 : x ^ (2 ^ 26) = aeval x r26 := by
    calc
      _ = (x ^ (2 ^ 25)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r25) ^ 2 := congrArg (fun v => v ^ 2) h25
      _ = _ := square_eval x hx square_25
  have h27 : x ^ (2 ^ 27) = aeval x r27 := by
    calc
      _ = (x ^ (2 ^ 26)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r26) ^ 2 := congrArg (fun v => v ^ 2) h26
      _ = _ := square_eval x hx square_26
  have h28 : x ^ (2 ^ 28) = aeval x r28 := by
    calc
      _ = (x ^ (2 ^ 27)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r27) ^ 2 := congrArg (fun v => v ^ 2) h27
      _ = _ := square_eval x hx square_27
  have h29 : x ^ (2 ^ 29) = aeval x r29 := by
    calc
      _ = (x ^ (2 ^ 28)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r28) ^ 2 := congrArg (fun v => v ^ 2) h28
      _ = _ := square_eval x hx square_28
  have h30 : x ^ (2 ^ 30) = aeval x r30 := by
    calc
      _ = (x ^ (2 ^ 29)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r29) ^ 2 := congrArg (fun v => v ^ 2) h29
      _ = _ := square_eval x hx square_29
  have h31 : x ^ (2 ^ 31) = aeval x r31 := by
    calc
      _ = (x ^ (2 ^ 30)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r30) ^ 2 := congrArg (fun v => v ^ 2) h30
      _ = _ := square_eval x hx square_30
  have h32 : x ^ (2 ^ 32) = aeval x r32 := by
    calc
      _ = (x ^ (2 ^ 31)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r31) ^ 2 := congrArg (fun v => v ^ 2) h31
      _ = _ := square_eval x hx square_31
  exact h32

theorem root_pow64 {A : Type*} [CommRing A] [Algebra (ZMod 2) A]
    (x : A) (hx : aeval x modulus = 0) :
    x ^ (2 ^ 64) = aeval x r64 := by
  have h32 := root_pow32 x hx
  have h33 : x ^ (2 ^ 33) = aeval x r33 := by
    calc
      _ = (x ^ (2 ^ 32)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r32) ^ 2 := congrArg (fun v => v ^ 2) h32
      _ = _ := square_eval x hx square_32
  have h34 : x ^ (2 ^ 34) = aeval x r34 := by
    calc
      _ = (x ^ (2 ^ 33)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r33) ^ 2 := congrArg (fun v => v ^ 2) h33
      _ = _ := square_eval x hx square_33
  have h35 : x ^ (2 ^ 35) = aeval x r35 := by
    calc
      _ = (x ^ (2 ^ 34)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r34) ^ 2 := congrArg (fun v => v ^ 2) h34
      _ = _ := square_eval x hx square_34
  have h36 : x ^ (2 ^ 36) = aeval x r36 := by
    calc
      _ = (x ^ (2 ^ 35)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r35) ^ 2 := congrArg (fun v => v ^ 2) h35
      _ = _ := square_eval x hx square_35
  have h37 : x ^ (2 ^ 37) = aeval x r37 := by
    calc
      _ = (x ^ (2 ^ 36)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r36) ^ 2 := congrArg (fun v => v ^ 2) h36
      _ = _ := square_eval x hx square_36
  have h38 : x ^ (2 ^ 38) = aeval x r38 := by
    calc
      _ = (x ^ (2 ^ 37)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r37) ^ 2 := congrArg (fun v => v ^ 2) h37
      _ = _ := square_eval x hx square_37
  have h39 : x ^ (2 ^ 39) = aeval x r39 := by
    calc
      _ = (x ^ (2 ^ 38)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r38) ^ 2 := congrArg (fun v => v ^ 2) h38
      _ = _ := square_eval x hx square_38
  have h40 : x ^ (2 ^ 40) = aeval x r40 := by
    calc
      _ = (x ^ (2 ^ 39)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r39) ^ 2 := congrArg (fun v => v ^ 2) h39
      _ = _ := square_eval x hx square_39
  have h41 : x ^ (2 ^ 41) = aeval x r41 := by
    calc
      _ = (x ^ (2 ^ 40)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r40) ^ 2 := congrArg (fun v => v ^ 2) h40
      _ = _ := square_eval x hx square_40
  have h42 : x ^ (2 ^ 42) = aeval x r42 := by
    calc
      _ = (x ^ (2 ^ 41)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r41) ^ 2 := congrArg (fun v => v ^ 2) h41
      _ = _ := square_eval x hx square_41
  have h43 : x ^ (2 ^ 43) = aeval x r43 := by
    calc
      _ = (x ^ (2 ^ 42)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r42) ^ 2 := congrArg (fun v => v ^ 2) h42
      _ = _ := square_eval x hx square_42
  have h44 : x ^ (2 ^ 44) = aeval x r44 := by
    calc
      _ = (x ^ (2 ^ 43)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r43) ^ 2 := congrArg (fun v => v ^ 2) h43
      _ = _ := square_eval x hx square_43
  have h45 : x ^ (2 ^ 45) = aeval x r45 := by
    calc
      _ = (x ^ (2 ^ 44)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r44) ^ 2 := congrArg (fun v => v ^ 2) h44
      _ = _ := square_eval x hx square_44
  have h46 : x ^ (2 ^ 46) = aeval x r46 := by
    calc
      _ = (x ^ (2 ^ 45)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r45) ^ 2 := congrArg (fun v => v ^ 2) h45
      _ = _ := square_eval x hx square_45
  have h47 : x ^ (2 ^ 47) = aeval x r47 := by
    calc
      _ = (x ^ (2 ^ 46)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r46) ^ 2 := congrArg (fun v => v ^ 2) h46
      _ = _ := square_eval x hx square_46
  have h48 : x ^ (2 ^ 48) = aeval x r48 := by
    calc
      _ = (x ^ (2 ^ 47)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r47) ^ 2 := congrArg (fun v => v ^ 2) h47
      _ = _ := square_eval x hx square_47
  have h49 : x ^ (2 ^ 49) = aeval x r49 := by
    calc
      _ = (x ^ (2 ^ 48)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r48) ^ 2 := congrArg (fun v => v ^ 2) h48
      _ = _ := square_eval x hx square_48
  have h50 : x ^ (2 ^ 50) = aeval x r50 := by
    calc
      _ = (x ^ (2 ^ 49)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r49) ^ 2 := congrArg (fun v => v ^ 2) h49
      _ = _ := square_eval x hx square_49
  have h51 : x ^ (2 ^ 51) = aeval x r51 := by
    calc
      _ = (x ^ (2 ^ 50)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r50) ^ 2 := congrArg (fun v => v ^ 2) h50
      _ = _ := square_eval x hx square_50
  have h52 : x ^ (2 ^ 52) = aeval x r52 := by
    calc
      _ = (x ^ (2 ^ 51)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r51) ^ 2 := congrArg (fun v => v ^ 2) h51
      _ = _ := square_eval x hx square_51
  have h53 : x ^ (2 ^ 53) = aeval x r53 := by
    calc
      _ = (x ^ (2 ^ 52)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r52) ^ 2 := congrArg (fun v => v ^ 2) h52
      _ = _ := square_eval x hx square_52
  have h54 : x ^ (2 ^ 54) = aeval x r54 := by
    calc
      _ = (x ^ (2 ^ 53)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r53) ^ 2 := congrArg (fun v => v ^ 2) h53
      _ = _ := square_eval x hx square_53
  have h55 : x ^ (2 ^ 55) = aeval x r55 := by
    calc
      _ = (x ^ (2 ^ 54)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r54) ^ 2 := congrArg (fun v => v ^ 2) h54
      _ = _ := square_eval x hx square_54
  have h56 : x ^ (2 ^ 56) = aeval x r56 := by
    calc
      _ = (x ^ (2 ^ 55)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r55) ^ 2 := congrArg (fun v => v ^ 2) h55
      _ = _ := square_eval x hx square_55
  have h57 : x ^ (2 ^ 57) = aeval x r57 := by
    calc
      _ = (x ^ (2 ^ 56)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r56) ^ 2 := congrArg (fun v => v ^ 2) h56
      _ = _ := square_eval x hx square_56
  have h58 : x ^ (2 ^ 58) = aeval x r58 := by
    calc
      _ = (x ^ (2 ^ 57)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r57) ^ 2 := congrArg (fun v => v ^ 2) h57
      _ = _ := square_eval x hx square_57
  have h59 : x ^ (2 ^ 59) = aeval x r59 := by
    calc
      _ = (x ^ (2 ^ 58)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r58) ^ 2 := congrArg (fun v => v ^ 2) h58
      _ = _ := square_eval x hx square_58
  have h60 : x ^ (2 ^ 60) = aeval x r60 := by
    calc
      _ = (x ^ (2 ^ 59)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r59) ^ 2 := congrArg (fun v => v ^ 2) h59
      _ = _ := square_eval x hx square_59
  have h61 : x ^ (2 ^ 61) = aeval x r61 := by
    calc
      _ = (x ^ (2 ^ 60)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r60) ^ 2 := congrArg (fun v => v ^ 2) h60
      _ = _ := square_eval x hx square_60
  have h62 : x ^ (2 ^ 62) = aeval x r62 := by
    calc
      _ = (x ^ (2 ^ 61)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r61) ^ 2 := congrArg (fun v => v ^ 2) h61
      _ = _ := square_eval x hx square_61
  have h63 : x ^ (2 ^ 63) = aeval x r63 := by
    calc
      _ = (x ^ (2 ^ 62)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r62) ^ 2 := congrArg (fun v => v ^ 2) h62
      _ = _ := square_eval x hx square_62
  have h64 : x ^ (2 ^ 64) = aeval x r64 := by
    calc
      _ = (x ^ (2 ^ 63)) ^ 2 := by rw [← pow_mul]; congr 1
      _ = (aeval x r63) ^ 2 := congrArg (fun v => v ^ 2) h63
      _ = _ := square_eval x hx square_63
  exact h64

theorem root_frobenius64 {A : Type*} [CommRing A] [Algebra (ZMod 2) A]
    (x : A) (hx : aeval x modulus = 0) : x ^ (2 ^ 64) = x := by
  simpa only [r64, aeval_X] using root_pow64 x hx

theorem root_not_frobenius32 {A : Type*} [CommRing A] [Nontrivial A]
    [Algebra (ZMod 2) A] [CharP A 2]
    (x : A) (hx : aeval x modulus = 0) : x ^ (2 ^ 32) ≠ x := by
  intro h
  have hr : aeval x r32 = x := (root_pow32 x hx).symm.trans h
  have hb := congrArg (aeval x) bezout32
  simp only [map_add, map_mul, map_one, aeval_X, hx, hr,
    CharTwo.add_self_eq_zero, mul_zero, zero_add] at hb
  exact zero_ne_one hb

end ProvenHashes.GF64Certificate
