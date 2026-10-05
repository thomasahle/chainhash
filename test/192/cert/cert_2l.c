/* cert_2l.c -- the two-level outer stage of ChainHash-192, certified on the AS-BUILT reference (the header's
 * c192_region_ref / c192_outer_ref / c192_hash_ref; adapted from the ChainHash-256 certificate test/256/cert_2l.c):
 *  (A) region polynomial: for every q = 1..8 and random region values a, the as-built c192_region_ref(a, q, y) is
 *      interpolated as a polynomial in y (4f+1 nodes, checked at 8 more) and must equal Lemma A's expansion exactly:
 *        c = D(a) + sum_{i<=f} (a_i y^(2i) + a_{h+i} y^(2i-1)) + kappa_q(y),  D = sum a_i a_{h+i} + [q odd] a_h,
 *        kappa_q = sum_{i<=f} y^(4i-1)
 *      (so distinct values sit at distinct linear exponents 1..2f and all data x data terms at y^0);
 *      adversarial differences: single value j (all j), only the bare a_h (odd q), pair with a zero partner,
 *      both members of a pair, dense -- the difference polynomial must be nonzero with the predicted top term;
 *  (B) outer polynomial: for several block counts m (m' = 1 and m' >= 2, odd last q), V(n, b; y, z) interpolated in z
 *      must be n z^{m'} + sum_rho c_rho z^{m'-rho} with c_rho = the as-built region values;
 *  (C) the <= 1-block path: for n <= BLOCK the full as-built hash equals finish(n z + b_1) (b_1 = the block value),
 *      and n = 0 gives finish(0).
 * Exit 0 iff all pass. */
#include <stdio.h>
#include "chainhash192.h"
#ifdef NEG   /* negative control: a broken region function (both operands masked with y^(2i): exponents collide) */
static inline c192_el c192_region_bad(const c192_el*a,int q,const c192_el*Y){
    int h=(q+1)/2, f=q/2; c192_el c={{0,0,0}}, yp[9]; yp[0]=(c192_el){{1,0,0}}; for(int e=1;e<=8;e++) yp[e]=c192_mul(yp[e-1],*Y);
    for(int i=1;i<=f;i++) c=c192_xor(c,c192_mul(c192_xor(a[i-1],yp[2*i]),c192_xor(a[h+i-1],yp[2*i])));
    if(q&1) c=c192_xor(c,a[h-1]); return c; }
#define c192_region_ref c192_region_bad
#endif
static uint64_t rs=2025; static uint64_t rnd(void){ return c192_splitmix(&rs); }
static c192_el rel(void){ c192_el e; for(int i=0;i<3;i++) e.w[i]=rnd(); return e; }
static int eq(c192_el a,c192_el b){ return !memcmp(&a,&b,sizeof a); }
static int iszero(c192_el a){ return c192_iszero(a); }
static c192_el inv(c192_el a){ c192_el r={{1,0,0}}, b=a; for(int i=1;i<192;i++){ b=c192_mul(b,b); r=c192_mul(r,b); } return r; }   /* a^(2^192-2) */
/* coefficients of the polynomial of degree < n through (x_i, v_i): Newton divided differences -> monomial form */
static void interp(const c192_el*x,const c192_el*v,int n,c192_el*c){
    c192_el d[40]; for(int i=0;i<n;i++) d[i]=v[i];
    for(int j=1;j<n;j++) for(int i=n-1;i>=j;i--) d[i]=c192_mul(c192_xor(d[i],d[i-1]),inv(c192_xor(x[i],x[i-j])));
    for(int i=0;i<n;i++) c[i]=(c192_el){{0,0,0}};
    for(int j=n-1;j>=0;j--){ /* c <- c * (X - x_j) + d_j */
        c192_el t[40]; for(int i=0;i<n;i++) t[i]=(c192_el){{0,0,0}};
        for(int i=0;i<n-1;i++){ t[i+1]=c192_xor(t[i+1],c[i]); t[i]=c192_xor(t[i],c192_mul(c[i],x[j])); }
        t[0]=c192_xor(t[0],d[j]); for(int i=0;i<n;i++) c[i]=t[i]; } }
static c192_el peval(const c192_el*c,int n,c192_el x){ c192_el r={{0,0,0}}; for(int i=n-1;i>=0;i--) r=c192_xor(c192_mul(r,x),c[i]); return r; }
static int fails=0, checks=0;
#define CHECK(cond,...) do{ checks++; if(!(cond)){ fails++; printf("  FAIL: " __VA_ARGS__); printf("\n"); } }while(0)
/* interpolate y -> c192_region_ref(a,q,y) (degree <= 4f-1 < 16) */
static void region_poly(const c192_el*a,int q,c192_el*c,int n){
    c192_el xs[24],vs[24]; for(int i=0;i<n+8;i++){ xs[i]=rel(); vs[i]=c192_region_ref(a,q,&xs[i]); }
    interp(xs,vs,n,c);
    for(int i=n;i<n+8;i++) CHECK(eq(peval(c,n,xs[i]),vs[i]),"q=%d region polynomial degree > %d",q,n-1); }
int main(void){
    printf("[ChainHash-192] outer-stage certificate on the as-built reference (c192_region_ref / c192_outer_ref / c192_hash_ref)\n");
    /* (A) expansion, every q */
    for(int q=1;q<=8;q++){ int h=(q+1)/2, f=q/2, n=(f? 4*f : 1); int base=checks;
        for(int t=0;t<3;t++){ c192_el a[8]; for(int i=0;i<q;i++) a[i]=rel(); c192_el c[24]; region_poly(a,q,c,n);
            c192_el D={{0,0,0}}; for(int i=1;i<=f;i++) D=c192_xor(D,c192_mul(a[i-1],a[h+i-1])); if(q&1) D=c192_xor(D,a[h-1]);
            c192_el want[24]; for(int i=0;i<n;i++) want[i]=(c192_el){{0,0,0}}; want[0]=D;
            for(int i=1;i<=f;i++){ want[2*i]=c192_xor(want[2*i],a[i-1]); want[2*i-1]=c192_xor(want[2*i-1],a[h+i-1]); want[4*i-1].w[0]^=1; }
            for(int e=0;e<n;e++) CHECK(eq(c[e],want[e]),"q=%d coefficient of y^%d differs from Lemma A",q,e); }
        /* adversarial differences */
        c192_el a[8],b[8],ca[24],cb[24];
        for(int j=0;j<q;j++){ for(int i=0;i<q;i++) a[i]=b[i]=rel(); b[j]=c192_xor(b[j],rel());
            region_poly(a,q,ca,n); region_poly(b,q,cb,n); int nz=0; for(int e=0;e<n;e++) if(!eq(ca[e],cb[e])) nz=1;
            CHECK(nz,"q=%d single value %d: difference polynomial is zero",q,j);
            int e_j = (q&1 && j==h-1)? 0 : (j<h? 2*(j+1) : 2*(j-h+1)-1);          /* exponent of a_j's linear term (0: bare) */
            CHECK(eq(c192_xor(ca[e_j],cb[e_j]),c192_xor(a[j],b[j])),"q=%d value %d: coefficient at y^%d",q,j,e_j);
            for(int e=2*f+1;e<n;e++) CHECK(eq(ca[e],cb[e]),"q=%d: difference has a term above y^%d",q,2*f); }
        if(f){ for(int i=0;i<q;i++) a[i]=b[i]=rel(); a[h]=b[h]=(c192_el){{0,0,0}}; b[0]=c192_xor(b[0],rel());          /* zero partner */
            region_poly(a,q,ca,n); region_poly(b,q,cb,n); CHECK(!eq(ca[2],cb[2]),"q=%d pair 1 with a zero partner: y^2 term cancels",q);
            for(int i=0;i<q;i++) a[i]=b[i]=rel(); b[0]=c192_xor(b[0],rel()); b[h]=c192_xor(b[h],rel());                     /* both members */
            region_poly(a,q,ca,n); region_poly(b,q,cb,n); CHECK(!eq(ca[2],cb[2]) && !eq(ca[1],cb[1]),"q=%d both members of pair 1",q); }
        for(int i=0;i<q;i++){ a[i]=rel(); b[i]=rel(); } region_poly(a,q,ca,n); region_poly(b,q,cb,n);
        { int nz=0; for(int e=0;e<n;e++) if(!eq(ca[e],cb[e])) nz=1; CHECK(nz,"q=%d dense difference is zero",q); }
        printf("  (A) q=%d: region polynomial = Lemma A expansion; adversarial differences nonzero with the predicted terms  [%d checks]\n",q,checks-base); }
    /* (B) outer polynomial in z */
    { size_t ms[]={1,2,3,7,8,9,13,16,17,24,31}; c192_el Y=rel();
      for(size_t t=0;t<sizeof ms/sizeof ms[0];t++){ size_t m=ms[t], mp=(m+7)/8; c192_el b[32]; for(size_t i=0;i<m;i++) b[i]=rel(); uint64_t n=rnd()>>20; int base=checks;
        c192_el xs[48],vs[48],c[48]; int N=(int)mp+1; for(int i=0;i<N+6;i++){ xs[i]=rel(); vs[i]=c192_outer_ref(b,m,n,&Y,&xs[i]); }
        interp(xs,vs,N,c); for(int i=N;i<N+6;i++) CHECK(eq(peval(c,N,xs[i]),vs[i]),"m=%zu outer degree > m'",m);
        CHECK(eq(c[mp],(c192_el){{n,0,0}}),"m=%zu: z^{m'} coefficient is not the length",m);
        for(size_t r=0;r<mp;r++){ int q=(int)((m-8*r)<8? m-8*r : 8); CHECK(eq(c[mp-1-r],c192_region_ref(b+8*r,q,&Y)),"m=%zu region %zu coefficient",m,r); }
        printf("  (B) m=%-2zu (m'=%zu, last q=%zu): V = n z^%zu + sum c_rho z^(m'-rho) exactly  [%d checks]\n",m,mp,m-8*(mp-1),mp,checks-base); } }
    /* (C) the <= 1-block path through the full hash */
    { static c192_key K; c192_raw RR; c192_raw_from_seed(&RR,31337); c192_derive(&RR,&K); static uint8_t msg[C192_BLOCK+8]; for(size_t i=0;i<sizeof msg;i++) msg[i]=(uint8_t)rnd(); int base=checks;
      size_t ns[]={0,1,7,8,63,64,191,192,193,383,384,385,3839,3840,3841,C192_BLOCK/2,C192_BLOCK-1,C192_BLOCK};
      for(size_t t=0;t<sizeof ns/sizeof ns[0];t++){ size_t n=ns[t]; uint8_t o[24],w[24]; c192_hash_ref(&K,msg,n,o);
          c192_el V={{0,0,0}};
          if(n){ uint8_t blk[C192_BLOCK]; memcpy(blk,msg,n); memset(blk+n,0,C192_BLOCK-n);
                 V=c192_xor(c192_mul((c192_el){{(uint64_t)n,0,0}},K.z),c192_block_ref(&K,blk)); }
          c192_store(c192_finish_ref(V,&K),w); CHECK(!memcmp(o,w,24),"n=%zu: hash != finish(n z + b_1)",n); }
      printf("  (C) <=1-block path: hash(n) = finish(n z + b_1) for n in {0..%d} samples (n=0: V=0)  [%d checks]\n",C192_BLOCK,checks-base); }
    printf("checks %d, failures %d\n%s\n",checks,fails,fails? "CERT 2L FAIL" : "CERT 2L PASS: region polynomial = Lemma A, outer = length-leading Horner in z, <=1-block path, odd counts");
    return fails!=0; }
