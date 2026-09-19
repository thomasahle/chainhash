#include "chainhash128_v3.h"
#include "oracle.h"
#include <stdio.h>
static uint64_t state=1234567;
static uint64_t rnd(void){state^=state<<13;state^=state>>7;state^=state<<17;return state;}
int main(void){unsigned i;int b,z;for(i=0;i<10000;i++){ch128v3_word a=ch128v3_make(rnd(),rnd()),c=ch128v3_make(rnd(),rnd());ch128v3_raw ref=ch128v3_clmul_ref(a,c);assert(ch128v3_equal(ch128v3_reduce(ref),oracle_mul(a,c)));for(b=0;b<=4;b++)if(chainhash128_v3_has_backend(b))for(z=0;z<2;z++){ch128v3_raw v=ch128v3_prod(a,c,b,z);assert(ch128v3_equal(v.lo,ref.lo)&&ch128v3_equal(v.hi,ref.hi));}}
 {ch128v3_word x=ch128v3_addint(ch128v3_make(UINT64_MAX,UINT64_MAX),ch128v3_make(1,0));assert(!x.lo&&!x.hi);}puts("PASS 10000 raw products, field division, integer carry");return 0;}

#ifdef NDEBUG
#error "Tests must be compiled with assertions enabled"
#endif
