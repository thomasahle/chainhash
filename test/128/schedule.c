#include "chainhash128.h"
#include <stdio.h>
/* Exact coefficient-index lookahead, independently counted. */
int main(void) {
 unsigned p,k,j,i,seed;ch128_word a[258];
 for(seed=0;seed<5;seed++) {ch128_word y=ch128_make(seed,seed>1?91:0),pow[9];pow[0]=ch128_make(1,0);for(i=1;i<=8;i++)pow[i]=ch128_mul_ref(pow[i-1],y);
  for(p=1;p<=257;p++){ch128_word serial;for(i=0;i<=p;i++)a[i]=ch128_make(17+i*31,p+i*139);serial=a[0];for(i=1;i<=p;i++)serial=ch128_xor(ch128_mul_ref(serial,y),a[i]);
   for(k=1;k<=8;k*=2){unsigned m=k<p+1?k:p+1,count=0;ch128_word sum={0,0};
    for(j=0;j<m;j++){ch128_word lane=a[j];unsigned e; i=j;while(i+k<p+1){lane=ch128_xor(ch128_mul_ref(lane,pow[k]),a[i+k]);i+=k;count++;}e=(p-j)%k;if(e){lane=ch128_mul_ref(lane,pow[e]);count++;}sum=ch128_xor(sum,lane);}
    assert(count==p);assert(ch128_equal(sum,serial));
   }
  }
 }
 puts("PASS exact-count schedule: 5140 cases, all residues, p<k, y=0/1");return 0;
}

#ifdef NDEBUG
#error "Tests must be compiled with assertions enabled"
#endif
