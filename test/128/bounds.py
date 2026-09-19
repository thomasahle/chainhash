"""Check the integer envelope inequalities behind the 127-bit score and print the scores."""
import math,json
B=512; W=B//16
def p(ell):
 Q,r=divmod(ell,8*B)
 return 1 if not ell else 8*Q+(min(8,(r+15)//16) if r else 0)
def d(L): return 1 if L<=16 else min(W,2*((L+31)//32))
lengths=list(range(1,131073))+[2**i+j for i in range(18,62) for j in (-33,-32,-31,-1,0,1,15,16,17) if 1<=2**i+j<=2**61-1]
for L in lengths:
 assert p(8*L)<=L and d(L)<=L
 assert p(8*L)+d(L)<=2*L and d(L)<=W
result={'block_bytes':B,'score_bits':127,'coarse_envelope_score_bits':128-math.log2(W+1),'at_1MiB':{'p':p(1048576),'d':d(131072),'numerator':p(1048576)+d(131072)},'integer_envelope_checks':len(lengths)}
print(json.dumps(result,indent=2))
