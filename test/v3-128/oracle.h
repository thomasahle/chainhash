/* Independent polynomial arrays: no production arithmetic, reducer, map helper
 * or finalizer. A bit-serial evaluator of SPEC.md. */
static inline ch128v3_word oracle_xor(ch128v3_word a,ch128v3_word b) { ch128v3_word r={a.lo^b.lo,a.hi^b.hi}; return r; }
static inline ch128v3_word oracle_mul(ch128v3_word a,ch128v3_word b) {
    uint64_t r[4]={0},x[2]={a.lo,a.hi},y[2]={b.lo,b.hi}; int i,j;
    for(i=0;i<128;i++) if((y[i/64]>>(i%64))&1) for(j=0;j<128;j++) if((x[j/64]>>(j%64))&1) r[(i+j)/64]^=UINT64_C(1)<<((i+j)%64);
    for(i=254;i>=128;i--) if((r[i/64]>>(i%64))&1) { static const int term[5]={128,7,2,1,0}; for(j=0;j<5;j++) {int k=i-128+term[j];r[k/64]^=UINT64_C(1)<<(k%64);} }
    {ch128v3_word z={r[0],r[1]};return z;}
}
static inline ch128v3_word oracle_load(const uint8_t *p,size_t n,size_t off) {
    ch128v3_word r={0,0}; size_t j; for(j=0;j<16 && off<n && j<n-off;j++) { if(j<8)r.lo|=(uint64_t)p[off+j]<<(8*j);else r.hi|=(uint64_t)p[off+j]<<(8*(j-8));}return r;
}
static inline ch128v3_word oracle(const chainhash128_v3_key *key,const uint8_t *p,size_t n) {
    ch128v3_word v={(uint64_t)n,0},q,r; size_t region,regions=n/CH128V3_REGION+(n%CH128V3_REGION!=0); if(!regions)regions=1;
    for(region=0;region<regions;region++) { size_t base=region*CH128V3_REGION,rem=n-base; unsigned lane,lanes=rem>=128?8:rem?(unsigned)((rem+15)/16):1;
      for(lane=0;lane<lanes;lane++) { ch128v3_word b={0,0}; unsigned pair;
        for(pair=0;pair<CH128V3_W/2;pair++) {size_t off=base+pair*256+lane*16;
          if(off<n) b=oracle_xor(b,oracle_mul(oracle_xor(oracle_load(p,n,off),key->ph[2*pair]),oracle_xor(oracle_load(p,n,off+128),key->ph[2*pair+1])));
        }v=oracle_xor(oracle_mul(v,key->yp[1]),b);
      }
    }
    {uint64_t old=v.lo;v.lo+=key->tau.lo;v.hi+=key->tau.hi+(v.lo<old);}
    q=oracle_mul(v,v);r=oracle_mul(oracle_xor(q,key->c[0]),oracle_xor(oracle_xor(v,q),key->c[1]));
    return oracle_xor(oracle_mul(oracle_xor(v,key->c[2]),oracle_xor(r,key->c[3])),key->c[4]);
}
