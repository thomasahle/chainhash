import Std
namespace ChainHashVectors

def raw (a b : Nat) : Nat := Id.run do
  let mut r := 0
  for i in [:64] do
    if b.testBit i then r := r ^^^ (a <<< i)
  return r

def reduce (a : Nat) : Nat := Id.run do
  let mut r := a
  for j in [:64] do
    let i := 127-j
    if r.testBit i then r := r ^^^ (((2^64 : Nat) + 27) <<< (i-64))
  return r

def mul (a b : Nat) : Nat := reduce (raw a b)

def wordAt (m : Array Nat) (offset : Nat) : Nat := Id.run do
  let mut r := 0
  for i in [:8] do
    r := r + (m[offset+i]?.getD 0 <<< (8*i))
  return r

def blocks (n : Nat) : Nat :=
  if n=0 then 1 else 4*((n-1)/1024)+min 4 (((n-1)%1024)/16+1)

def hash (k m : Array Nat) : Nat := Id.run do
  let mut state := m.size
  for t in [:blocks m.size] do
    let mut acc := 0
    for c in [:8] do
      for e in [:2] do
        let i := 128*(t/4)+16*c+2*(t%4)+e
        if 8*i < m.size then
          acc := acc ^^^ mul (wordAt m (8*i) ^^^ k[4*c+2*e]!)
            (wordAt m (8*(i+8)) ^^^ k[4*c+2*e+1]!)
    state := mul k[32]! state ^^^ acc
  let v := (state+k[38]!) % 2^64
  let q := mul v v
  let r := mul (q ^^^ k[33]!) (v ^^^ q ^^^ k[34]!)
  return mul (v ^^^ k[35]!) (r ^^^ k[36]!) ^^^ k[37]!

def expand (k : Array Nat) : Array Nat := Id.run do
  let mut p := k[0]!
  let mut out := #[]
  for _ in [:32] do
    out := out.push p
    p := mul p k[0]!
  for i in [:7] do out := out.push k[i+1]!
  return out
end ChainHashVectors

def main (args : List String) : IO Unit := do
  let input ← IO.FS.readFile args[0]!
  let out ← IO.getStdout
  for line in input.splitOn "\n" do
    if line.isEmpty then continue
    let a := ((line.splitOn " ").map String.toNat!).toArray
    let count := if a[0]! = 1 then 8 else 39
    let mut key := a.extract 2 (2+count)
    if a[0]! = 1 then key := ChainHashVectors.expand key
    let msg := a.extract (2+count) (2+count+a[1]!)
    out.putStrLn s!"{ChainHashVectors.hash key msg}"
