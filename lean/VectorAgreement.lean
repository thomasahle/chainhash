import ProvenHashes.WordRepresentation

/- Executable differential-test transcription. It uses the proof's byte reads,
   active pairs, pair positions, and block count directly. Nat bit operations
   evaluate the raw products and field reduction. This test is evidence, not
   a compiler/SIMD refinement theorem for the noncomputable referenceHash. -/
open ProvenHashes.ChainHash

namespace VectorAgreement

def clmul (a b : Nat) : Nat :=
  (List.range 64).foldl (fun r i => if b.testBit i then r ^^^ (a <<< i) else r) 0

def reduce (p : Nat) : Nat :=
  (List.range 64).reverse.foldl
    (fun r i => if r.testBit (64 + i) then r ^^^ (((1 <<< 64) + 27) <<< i) else r) p

def mul (a b : Nat) : Nat := reduce (clmul a b)

def wordValue (v : Word 64) : Nat := (bitVecOfBits v).toNat

def hash (k : Array Nat) (n : Nat) : Nat := Id.run do
  let m : Message := (List.range n).map fun i => bitsOfBitVec (BitVec.ofNat 8 (131*i+17))
  let mut p := k[34]!
  for t in List.range (blockCount m) do
    let mut raw := 0
    for j in List.finRange 16 do
      if j ∈ activePairs m t then
        let a := wordValue (blockData m t (j, false)) ^^^ k[(pairPosition (j, false)).val]!
        let b := wordValue (blockData m t (j, true)) ^^^ k[(pairPosition (j, true)).val]!
        raw := raw ^^^ clmul a b
    let len := if t + 1 = blockCount m then n else 0
    let lo := (raw % (2^64)) ^^^ len
    let hi := (raw >>> 64) ^^^ len
    p := lo ^^^ mul (hi ^^^ k[33]!) (p ^^^ k[32]!)
  let v := (p + k[40]!) % (2^64)
  let y := mul v v
  let z := mul (y ^^^ k[35]!) (v ^^^ y ^^^ k[36]!)
  return mul (v ^^^ k[37]!) (z ^^^ k[38]!) ^^^ k[39]!

end VectorAgreement

def main (args : List String) : IO Unit := do
  let path := args.headD "../build/lean-vectors.txt"
  let lines := (← IO.FS.readFile path).splitOn "\n"
  let mut count := 0
  for line in lines do
    if line.isEmpty then continue
    let fields := line.splitOn " "
    let nums ← fields.mapM fun s =>
      match s.toNat? with
      | some n => pure n
      | none => throw (IO.userError s!"invalid number: {s}")
    let row := nums.toArray
    unless row.size == 43 do throw (IO.userError "expected length, hash, and 41 key words")
    let n := row[0]!
    let expected := row[1]!
    let actual := VectorAgreement.hash (row.extract 2 43) n
    unless actual == expected do
      throw (IO.userError s!"vector {count}, length {n}: Lean {actual}, C++ {expected}")
    count := count + 1
  unless count > 0 do throw (IO.userError "no vectors")
  IO.println s!"PASS: {count} C++ reference/header vs Lean encoding/evaluator vectors"
