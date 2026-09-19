"""Check the integer envelopes and print the analytically attained scores."""
import math,json
result={}
for B in (256,512):
 W=B//16
 def p(ell):
  Q,r=divmod(ell,8*B)
  return 1 if not ell else 8*Q+(min(8,(r+15)//16) if r else 0)
 lengths=list(range(1,131073))+[2**i+j for i in range(18,62) for j in (-33,-32,-31,-1,0,1,15,16,17) if 1<=2**i+j<=2**61-1]
 for L in lengths:
  d=1 if L<=16 else min(W,2*((L+31)//32))
  assert p(8*L)<=L and d<=L
  assert p(8*L)+1<=2*L and p(8*L)+d<=2*L
 result[str(B)]={'paper_score_bits':127,'model_A_refined_score_bits':127,'model_A_coarse_score_bits':128-math.log2(W+1),'at_1MiB':{'p':p(1048576),'paper_numerator':p(1048576)+1,'model_A_numerator':p(1048576)+W},'integer_envelope_checks':len(lengths)}
print(json.dumps(result,indent=2))
