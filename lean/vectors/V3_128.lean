import Std
/-! Independent executable bit-serial reference for ChainHash-128 v3 (B = 512), following
SPEC.md's three-level definition and index map. Field: GF(2)[X]/(X^128+X^7+X^2+X+1). -/
namespace ChainHash128V3Vectors

def mask : Nat := 2^128-1

def raw (a b : Nat) : Nat := Id.run do
  let mut r := 0
  for i in [:128] do
    if b.testBit i then r := r ^^^ (a <<< i)
  return r

def reduce (a : Nat) : Nat := Id.run do
  let mut r := a
  for j in [:128] do
    let i := 255-j
    if r.testBit i then r := r ^^^ (((2^128 : Nat) + 135) <<< (i-128))
  return r

def mul (a b : Nat) : Nat := reduce (raw a b)

def wordAt (m : Array Nat) (offset : Nat) : Nat := Id.run do
  let mut r := 0
  for i in [:16] do
    r := r + (m[offset+i]?.getD 0 <<< (8*i))
  return r

def blocks (n : Nat) : Nat :=
  if n=0 then 1 else 8*((n-1)/4096)+min 8 (((n-1)%4096)/16+1)

/-- Key order: kappa[0..31], y (32), c0..c4 (33..37), tau (38). -/
def hash (k m : Array Nat) : Nat := Id.run do
  let n := m.size
  let mut state := n
  for t in [:blocks n] do
    let mut acc := 0
    for c in [:16] do
      let i := 256*(t/8)+16*c+(t%8)
      if 16*i < n then
        acc := acc ^^^ raw (wordAt m (16*i) ^^^ k[2*c]!) (wordAt m (16*(i+8)) ^^^ k[2*c+1]!)
    state := mul k[32]! state ^^^ reduce acc
  let v := (state+k[38]!) &&& mask
  let q := mul v v
  let r := mul (q ^^^ k[33]!) (v ^^^ q ^^^ k[34]!)
  return mul (v ^^^ k[35]!) (r ^^^ k[36]!) ^^^ k[37]!

/-- Model A: s, y, c0..c4, tau; kappa[a] = s^(a+1). -/
def expand (k : Array Nat) : Array Nat := Id.run do
  let s := k[0]!
  let mut p := s
  let mut out := #[]
  for _ in [:32] do
    out := out.push p
    p := mul p s
  for i in [:7] do out := out.push k[i+1]!
  return out
end ChainHash128V3Vectors

def main (args : List String) : IO Unit := do
  let input ← IO.FS.readFile args[0]!
  let out ← IO.getStdout
  for line in input.splitOn "\n" do
    if line.isEmpty then continue
    let a := ((line.splitOn " ").map String.toNat!).toArray
    let count := if a[0]! = 1 then 8 else 39
    let mut key := #[]
    for i in [:count] do key := key.push (a[2+2*i]! + (a[3+2*i]! <<< 64))
    if a[0]! = 1 then key := ChainHash128V3Vectors.expand key
    let msg := a.extract (2+2*count) (2+2*count+a[1]!)
    let h := ChainHash128V3Vectors.hash key msg
    out.putStrLn s!"{h &&& (2^64-1)} {h >>> 64}"
