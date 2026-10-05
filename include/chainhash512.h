/* ChainHash-512: a keyed 512-bit hash for long inputs with a proven collision bound.
 * Copyright 2026 Thomas Dybdahl Ahle. MIT license. C99 (GCC/Clang), this header plus
 * chainhash512_body.inc (same directory), no allocation.
 *
 * Key: 576 uniformly random bytes (CHAINHASH512_KEY_BYTES), chainhash512_key_from_bytes.
 * chainhash512_key_from_seed expands a 64-bit seed; it is for benchmarks and tests.
 * The expanded key (about 43 KiB of tables) is initialized in place, at any 8-byte-aligned address (static, stack,
 * malloc; the tables are aligned inside the key); a copy made with memcpy stays valid.
 * Hash: chainhash512(&key, data, len, out) writes 64 canonical little-endian bytes. Streaming:
 * chainhash512_init, chainhash512_update, chainhash512_final.
 * Backends (identical digests; chosen when the key is initialized): CH512_AVX512 (AVX-512 F/BW/DQ/VL
 * + VPCLMULQDQ), CH512_PCLMUL (PCLMULQDQ + SSE4.1), CH512_NEON (AArch64 PMULL; needs +crypto at
 * compile time), CH512_PORTABLE. x86: the kernels carry their own target attributes; no -march is needed.
 * Bound: for two distinct messages fixed independently of the key, each of at most 8L bytes,
 * Pr[collision] <= N(L)/2^512 with N(L) <= 2L (score 511); see docs/THEOREM-512.md.
 * The definition: docs/SPEC-512.md; the family: docs/FAMILY.md.
 * Proof status: paper proof and machine-checked certificates (test/512); not yet in Lean.
 * Define CHAINHASH512_PORTABLE to omit all hardware code. Development name: PH-512 v1.1 (the v1 function
 * with a short-input schedule: one-level key-side weights for n <= 64 bytes, one fold for one-block inputs).
 */
#ifndef CHAINHASH512_H
#define CHAINHASH512_H
#if defined(CHAINHASH512_PORTABLE) && !defined(PH512V1_PORTABLE_ONLY)
#define PH512V1_PORTABLE_ONLY 1
#endif
#include <stdint.h>
#include <stddef.h>
#include <string.h>

#define PH512V1_KEY_BYTES 576
#define PH1_CHUNK 1024
#define PH1_CPB 16
#define PH1_PAIRS 128
#define PH1_BLOCK (PH1_CHUNK*PH1_CPB)
#define PH1_R 8
enum { PH512V1_PORTABLE=0, PH512V1_PCLMUL=1, PH512V1_AVX512=2, PH512V1_NEON=3 };
static const char *const PH512V1_BACKEND_NAME[4]={"portable","pclmul-sse4.1","avx512-vpclmulqdq","neon-pmull"};

typedef struct { uint64_t lo,hi; } ph1_u128;

/* ============================ portable field =============================== */
static inline void ph1_clmul_bs(uint64_t a, uint64_t b, uint64_t *lo, uint64_t *hi){
    uint64_t l=0,h=0; for(int i=0;i<64;i++){ uint64_t m=0-((b>>i)&1); l^=(a<<i)&m; if(i) h^=(a>>(64-i))&m; } *lo=l; *hi=h; }
static inline void ph1_polymul(const uint64_t *a, const uint64_t *b, uint64_t *r){        /* schoolbook, 1024-bit */
    memset(r,0,128); for(int i=0;i<8;i++) for(int j=0;j<8;j++){ uint64_t lo,hi; ph1_clmul_bs(a[i],b[j],&lo,&hi); r[i+j]^=lo; r[i+j+1]^=hi; } }
static inline void ph1_reduce(uint64_t *r){                                                /* mod x^512+x^8+x^5+x^2+1 */
    for(int i=15;i>=8;i--){ uint64_t t=r[i]; r[i]=0; r[i-8]^=t^(t<<2)^(t<<5)^(t<<8); r[i-7]^=(t>>62)^(t>>59)^(t>>56); } }
static inline void ph1_mul(const uint64_t *a, const uint64_t *b, uint64_t *o){ uint64_t r[16]; ph1_polymul(a,b,r); ph1_reduce(r); memcpy(o,r,64); }
static inline void ph1_add512(uint64_t *a, const uint64_t *b){                              /* a += b mod 2^512 */
    unsigned c=0; for(int j=0;j<8;j++){ uint64_t s=a[j]+b[j]; unsigned c1=s<a[j]; uint64_t s2=s+c; c1|=s2<s; a[j]=s2; c=c1; } }
static inline uint64_t ph1_ld64(const uint8_t *p){ uint64_t r=0; for(int b=7;b>=0;b--) r=(r<<8)|p[b]; return r; }
/* Karatsuba^3 points (27) of an 8-limb operand, order: eval4(a0..3), eval4(a4..7), eval4(a_j^a_j+4) */
static inline void ph1_eval2(uint64_t a0, uint64_t a1, uint64_t *o){ o[0]=a0; o[1]=a1; o[2]=a0^a1; }
static inline void ph1_eval4(const uint64_t *a, uint64_t *o){ ph1_eval2(a[0],a[1],o); ph1_eval2(a[2],a[3],o+3); ph1_eval2(a[0]^a[2],a[1]^a[3],o+6); }
static inline void ph1_eval8(const uint64_t *a, uint64_t *o){ uint64_t m[4]; for(int j=0;j<4;j++) m[j]=a[j]^a[j+4]; ph1_eval4(a,o); ph1_eval4(a+4,o+9); ph1_eval4(m,o+18); }

/* ================================ layout =================================== *
 * Full 1 KiB chunk: limb-major (u limb j of pair i at 64j+8i, v at 512+64j+8i).
 * Final partial chunk: pair-major (pair i = bytes [128i,128i+128): u then v), zero padded.   */
static inline size_t ph1_npairs(size_t n){ size_t F=n/PH1_CHUNK, r=n-F*PH1_CHUNK; return 8*F+(r+127)/128; }
static inline size_t ph1_nblocks(size_t n){ size_t G=ph1_npairs(n); return G? (G+PH1_PAIRS-1)/PH1_PAIRS : 1; }
static inline uint64_t ph1_ldp(const uint8_t *p, size_t n, size_t off){ uint64_t r=0; for(int b=0;b<8;b++) if(off+b<n) r|=(uint64_t)p[off+b]<<(8*b); return r; }
static inline void ph1_pair(const uint8_t *p, size_t n, size_t g, uint64_t *u, uint64_t *v){
    size_t F=n/PH1_CHUNK, c=g/8, i=g%8;
    if(c<F){ size_t b=c*PH1_CHUNK; for(int j=0;j<8;j++){ u[j]=ph1_ld64(p+b+64*j+8*i); v[j]=ph1_ld64(p+b+512+64*j+8*i); } return; }
    size_t base=F*PH1_CHUNK+128*(g-8*F); for(int j=0;j<8;j++){ u[j]=ph1_ldp(p,n,base+8*j); v[j]=ph1_ldp(p,n,base+64+8*j); }
}

/* ================================== key ==================================== */
typedef struct {
    uint64_t s[8], y[8], tau[8], c[5][8], z[8];                  /* the 576-byte key (9 words)          */
    uint64_t yp[9][8];                                           /* y^0..y^8                            */
    uint64_t kz_u[PH1_CPB][8][8];   /* pair keys, limb-major (kernels)     */
    uint64_t kz_v[PH1_CPB][8][8];
    uint64_t km_u[PH1_CPB][4][8];   /* kz[j]^kz[j+4] (3-pass mix pass)     */
    uint64_t km_v[PH1_CPB][4][8];
    uint64_t kup[PH1_PAIRS][8];     /* pair keys, pair-major (tail pairs)  */
    uint64_t kvp[PH1_PAIRS][8];
    uint64_t ezv[3][5][2];          /* Karatsuba points of z, vector order */
    uint64_t pad_[2];
    /* v1.1 latency caches (derived from the key; no new key material) */
    uint64_t w0[8][8];              /* kv_0 x^(64i) mod P, i = 0..7          */
    uint64_t k00[8];                /* ku_0 kv_0 mod P                       */
    uint64_t w0s[8][8];             /* w0 with the two words of each 128-bit half swapped */
    uint64_t zs[8];                 /* z, halves swapped                     */
    int backend;
} ph512v1_key;
/* The expanded key has no alignment requirement beyond its uint64_t words (the kernels load it unaligned).  Its
 * 64-byte tables sit at multiples of 64 bytes from its start; chainhash512_key below places it at a 64-byte-aligned
 * address inside the key object. */
#define PH1_OFF64(f) (offsetof(ph512v1_key,f)%64==0)
typedef char ph1_key_layout_check[(PH1_OFF64(kz_u) && PH1_OFF64(kz_v) && PH1_OFF64(km_u) && PH1_OFF64(km_v) && PH1_OFF64(kup) && PH1_OFF64(kvp)
    && offsetof(ph512v1_key,ezv)%16==0 && PH1_OFF64(w0) && PH1_OFF64(k00) && PH1_OFF64(w0s) && PH1_OFF64(zs)) ? 1 : -1];
#undef PH1_OFF64
#define PH1_KU(k,q) ((k)->kup[q])
#define PH1_KV(k,q) ((k)->kvp[q])
/* vector order of the 27 points per 4-limb group g: X0=(p0,p1) X1=(p3,p4) S=(p6,p7) T=(p2,p5) U=(p8,-) */
static const int ph1_vord[5][2]={{0,1},{3,4},{6,7},{2,5},{8,-1}};

static inline int ph512v1_detect(void);
static inline void ph512v1_init_backend(ph512v1_key *k, const uint8_t raw[PH512V1_KEY_BYTES], int backend){
    uint64_t w[9][8]; for(int e=0;e<9;e++) for(int j=0;j<8;j++) w[e][j]=ph1_ld64(raw+64*e+8*j);
    memcpy(k->s,w[0],64); memcpy(k->y,w[1],64); memcpy(k->tau,w[2],64); for(int t=0;t<5;t++) memcpy(k->c[t],w[3+t],64); memcpy(k->z,w[8],64);
    uint64_t pw[8]; memcpy(pw,k->s,64);
    for(int q=0;q<PH1_PAIRS;q++){ memcpy(k->kup[q],pw,64); ph1_mul(pw,k->s,pw); memcpy(k->kvp[q],pw,64); ph1_mul(pw,k->s,pw); }
    for(int c=0;c<PH1_CPB;c++) for(int j=0;j<8;j++) for(int i=0;i<8;i++){ k->kz_u[c][j][i]=k->kup[8*c+i][j]; k->kz_v[c][j][i]=k->kvp[8*c+i][j]; }
    for(int c=0;c<PH1_CPB;c++) for(int j=0;j<4;j++) for(int i=0;i<8;i++){ k->km_u[c][j][i]=k->kz_u[c][j][i]^k->kz_u[c][j+4][i]; k->km_v[c][j][i]=k->kz_v[c][j][i]^k->kz_v[c][j+4][i]; }
    memset(k->yp[0],0,64); k->yp[0][0]=1; for(int e=1;e<=8;e++) ph1_mul(k->yp[e-1],k->y,k->yp[e]);
    for(int i=0;i<8;i++){ uint64_t e[8]={0}; e[i]=1; ph1_mul(k->kvp[0],e,k->w0[i]); }
    ph1_mul(k->kup[0],k->kvp[0],k->k00);
    for(int i=0;i<8;i++) for(int j=0;j<8;j++) k->w0s[i][j]=k->w0[i][j^1];
    for(int j=0;j<8;j++) k->zs[j]=k->z[j^1];
    uint64_t ez[27]; ph1_eval8(k->z,ez);
    for(int g=0;g<3;g++) for(int e=0;e<5;e++) for(int h=0;h<2;h++) k->ezv[g][e][h]= ph1_vord[e][h]<0 ? 0 : ez[9*g+ph1_vord[e][h]];
    k->backend = backend>=0 ? backend : ph512v1_detect();
}
static inline void ph512v1_init(ph512v1_key *k, const uint8_t raw[PH512V1_KEY_BYTES]){ ph512v1_init_backend(k,raw,-1); }

/* ====================== reference (the definition, literal) ================= */
static inline void ph1_block_ref(const ph512v1_key *k, const uint8_t *p, size_t n, size_t t, uint64_t *b){
    size_t G=ph1_npairs(n); uint64_t acc[16]={0};
    for(size_t q=0;q<PH1_PAIRS;q++){ size_t g=t*PH1_PAIRS+q; if(g>=G) break; uint64_t u[8],v[8],r[16];
        ph1_pair(p,n,g,u,v); for(int j=0;j<8;j++){ u[j]^=k->kup[q][j]; v[j]^=k->kvp[q][j]; }
        ph1_polymul(u,v,r); for(int j=0;j<16;j++) acc[j]^=r[j]; }
    ph1_reduce(acc); memcpy(b,acc,64);
}
static inline void ph1_region_ref(const ph512v1_key *k, uint64_t *V, uint64_t b[][8], int q){      /* V <- V z + c(b) */
    uint64_t t[8], c[8]={0}; int h=(q+1)/2, f=q/2;
    for(int i=1;i<=f;i++){ uint64_t x[8],w[8],pr[8]; for(int j=0;j<8;j++){ x[j]=b[i-1][j]^k->yp[2*i-1][j]; w[j]=b[h+i-1][j]^k->yp[2*i][j]; }
        ph1_mul(x,w,pr); for(int j=0;j<8;j++) c[j]^=pr[j]; }
    if(q&1) for(int j=0;j<8;j++) c[j]^=b[h-1][j];
    ph1_mul(V,k->z,t); for(int j=0;j<8;j++) V[j]=t[j]^c[j];
}
static inline void ph1_final_ref(const ph512v1_key *k, const uint64_t *V, uint8_t *out){
    uint64_t v[8],q[8],t1[8],t2[8],r[8],h[8]; memcpy(v,V,64); ph1_add512(v,k->tau); ph1_mul(v,v,q);
    for(int j=0;j<8;j++){ t1[j]=q[j]^k->c[0][j]; t2[j]=v[j]^q[j]^k->c[1][j]; } ph1_mul(t1,t2,r);
    for(int j=0;j<8;j++){ t1[j]=v[j]^k->c[2][j]; t2[j]=r[j]^k->c[3][j]; } ph1_mul(t1,t2,h);
    for(int j=0;j<8;j++){ h[j]^=k->c[4][j]; for(int b=0;b<8;b++) out[8*j+b]=(uint8_t)(h[j]>>(8*b)); }
}
static inline void ph512v1_ref(const ph512v1_key *k, const void *data, size_t n, uint8_t out[64]){
    const uint8_t *p=(const uint8_t*)data; size_t m=ph1_nblocks(n), mr=(m+PH1_R-1)/PH1_R;
    uint64_t V[8]={0}; V[0]=(uint64_t)n;
    for(size_t r=0;r<mr;r++){ int q = r+1<mr ? PH1_R : (int)(m-PH1_R*(mr-1)); uint64_t b[PH1_R][8];
        for(int j=0;j<q;j++) ph1_block_ref(k,p,n,PH1_R*r+j,b[j]);
        ph1_region_ref(k,V,b,q); }
    ph1_final_ref(k,V,out);
}
/* portable backend primitives used by streaming */
static inline void ph1_blockval_portable(const ph512v1_key *k, const uint8_t *p, size_t n, uint64_t *b){ ph1_block_ref(k,p,n,0,b); }

/* ============================== x86 backends ================================ */
#if !defined(PH512V1_PORTABLE_ONLY) && defined(__x86_64__) && (defined(__GNUC__)||defined(__clang__))
#define PH1_X86 1
#include <immintrin.h>
static inline void ph1_cpuid(unsigned leaf, unsigned sub, unsigned r[4]){
    __asm__ __volatile__("cpuid":"=a"(r[0]),"=b"(r[1]),"=c"(r[2]),"=d"(r[3]):"a"(leaf),"c"(sub)); }
static inline int ph512v1_detect(void){
    unsigned r[4],c,maxleaf; ph1_cpuid(0,0,r); maxleaf=r[0]; if(maxleaf<1) return PH512V1_PORTABLE;
    ph1_cpuid(1,0,r); c=r[2];
    int pclmul=(c>>1)&1, sse41=(c>>19)&1, osx=(c>>27)&1; if(!(pclmul&&sse41)) return PH512V1_PORTABLE;
    if(!osx) return PH512V1_PCLMUL;
    unsigned lo,hi; __asm__ volatile("xgetbv":"=a"(lo),"=d"(hi):"c"(0)); (void)hi;
    if(maxleaf<7) return PH512V1_PCLMUL;
    unsigned b7,c7; ph1_cpuid(7,0,r); b7=r[1]; c7=r[2];
    int avx512 = ((b7>>16)&1) && ((b7>>17)&1) && ((b7>>30)&1) && ((b7>>31)&1) && ((c7>>10)&1) && ((lo&0xe6)==0xe6);
    return avx512 ? PH512V1_AVX512 : PH512V1_PCLMUL;   /* F, DQ, BW, VL, VPCLMULQDQ; OS-enabled zmm/k state */
}
#define PH1_TZ __attribute__((target("avx512f,avx512bw,avx512vl,vpclmulqdq,pclmul,sse4.1")))
#define PH1_TX __attribute__((target("pclmul,sse4.1")))

/* ---- AVX-512 3-pass kernel: nch full chunks -> 27 point sums (fresh store into P[28]) ---- */
#define Z1X(a,b) _mm512_xor_si512(a,b)
#define Z1ACC(A,a,b) A=_mm512_ternarylogic_epi64(A,_mm512_clmulepi64_epi128(a,b,0x00),_mm512_clmulepi64_epi128(a,b,0x11),0x96)
#define Z1P2(A,i,a0,a1,b0,b1) do{ Z1ACC(A[i],a0,b0); Z1ACC(A[i+1],a1,b1); Z1ACC(A[i+2],Z1X(a0,a1),Z1X(b0,b1)); }while(0)
#define Z1P4(A,a0,a1,a2,a3,b0,b1,b2,b3) do{ Z1P2(A,0,a0,a1,b0,b1); Z1P2(A,3,a2,a3,b2,b3); Z1P2(A,6,Z1X(a0,a2),Z1X(a1,a3),Z1X(b0,b2),Z1X(b1,b3)); }while(0)
#define Z1L(o,kk) Z1X(_mm512_loadu_si512(q+(o)),_mm512_loadu_si512(kk))
#define Z1M(o,kk) _mm512_ternarylogic_epi64(_mm512_loadu_si512(q+(o)),_mm512_loadu_si512(q+(o)+256),_mm512_loadu_si512(kk),0x96)
PH1_TZ __attribute__((always_inline)) static inline void ph1z_pass(const ph512v1_key *k, const uint8_t *p, int c0, int c1, int which, __m512i *Aout){
    __m512i A[9]; for(int i=0;i<9;i++) A[i]=Aout[i];
    for(int c=c0;c<c1;c++){ const uint8_t *q=p+(size_t)c*PH1_CHUNK; __m512i a0,a1,a2,a3,b0,b1,b2,b3;
        if(which<2){ const char *nx=(const char*)q+4*PH1_CHUNK+512*which; for(int l=0;l<512;l+=64) _mm_prefetch(nx+l,_MM_HINT_T0); }
        if(which==0){ a0=Z1L(0,k->kz_u[c][0]); a1=Z1L(64,k->kz_u[c][1]); a2=Z1L(128,k->kz_u[c][2]); a3=Z1L(192,k->kz_u[c][3]);
                      b0=Z1L(512,k->kz_v[c][0]); b1=Z1L(576,k->kz_v[c][1]); b2=Z1L(640,k->kz_v[c][2]); b3=Z1L(704,k->kz_v[c][3]); }
        else if(which==1){ a0=Z1L(256,k->kz_u[c][4]); a1=Z1L(320,k->kz_u[c][5]); a2=Z1L(384,k->kz_u[c][6]); a3=Z1L(448,k->kz_u[c][7]);
                      b0=Z1L(768,k->kz_v[c][4]); b1=Z1L(832,k->kz_v[c][5]); b2=Z1L(896,k->kz_v[c][6]); b3=Z1L(960,k->kz_v[c][7]); }
        else { a0=Z1M(0,k->km_u[c][0]); a1=Z1M(64,k->km_u[c][1]); a2=Z1M(128,k->km_u[c][2]); a3=Z1M(192,k->km_u[c][3]);
               b0=Z1M(512,k->km_v[c][0]); b1=Z1M(576,k->km_v[c][1]); b2=Z1M(640,k->km_v[c][2]); b3=Z1M(704,k->km_v[c][3]); }
        Z1P4(A,a0,a1,a2,a3,b0,b1,b2,b3); }
    for(int i=0;i<9;i++) Aout[i]=A[i];
}
PH1_TZ __attribute__((noinline)) static void ph1z_points(const ph512v1_key *k, const uint8_t *p, int nch, ph1_u128 *P){
    __m512i A[28]; for(int i=0;i<28;i++) A[i]=_mm512_setzero_si512();
    for(int s=0;s<nch;s+=4){ int e=s+4<nch?s+4:nch; ph1z_pass(k,p,s,e,2,A+18); ph1z_pass(k,p,s,e,0,A); ph1z_pass(k,p,s,e,1,A+9); }
    for(int g=0;g<28;g+=4){ __m512i a=A[g],b=A[g+1],c=A[g+2],d=A[g+3];
        __m512i x=Z1X(_mm512_shuffle_i64x2(a,b,0x44),_mm512_shuffle_i64x2(a,b,0xEE));
        __m512i y=Z1X(_mm512_shuffle_i64x2(c,d,0x44),_mm512_shuffle_i64x2(c,d,0xEE));
        _mm512_storeu_si512((void*)&P[g],Z1X(_mm512_shuffle_i64x2(x,y,0x88),_mm512_shuffle_i64x2(x,y,0xDD))); }
}
/* ---- SSE4.1/PCLMUL 3-pass kernel: xmm = limb j of 2 pairs ----
 * nch full chunks -> 27 point sums, three passes per group of 8 chunks (pass 2 first: it reads the whole chunk;
 * passes 0/1 prefetch the next group).
 * Each step (chunk c, pair-pair d) forms the 8 operands a_j, b_j (limb 4w+j of pairs 2d, 2d+1 plus the key; pass 2:
 * limb j + limb j+4 with the km key) and adds the 9 Karatsuba products of (a0..a3) x (b0..b3) to the pass's 9
 * accumulators.  The schedule keeps the live set at 16 registers: A0..A6 in registers, A7/A8 in memory (VEX asm step),
 * or nine register accumulators with the group-1 operands folded into the group-2 sums after they are loaded (C step). */
#define X1X(a,b) _mm_xor_si128(a,b)
#define X1C(A,a,b) do{ A=X1X(A,_mm_clmulepi64_si128(a,b,0x00)); A=X1X(A,_mm_clmulepi64_si128(a,b,0x11)); }while(0)
#define X1LD(o) _mm_loadu_si128((const __m128i*)(q+(o)))
/* al = 1: the key is 16-byte aligned (in place; the usual case), so legacy-SSE xors take key rows as memory operands;
 * al = 0: a relocated key (unaligned loads) */
#define X1K(kk) (al ? _mm_load_si128((const __m128i*)(kk)) : _mm_loadu_si128((const __m128i*)(kk)))
#define X1A(j) (w<2 ? X1X(X1LD(256*w+64*(j)+16*d),X1K(&k->kz_u[c][4*w+(j)][2*d])) : X1X(X1X(X1LD(64*(j)+16*d),X1LD(256+64*(j)+16*d)),X1K(&k->km_u[c][j][2*d])))
#define X1B(j) (w<2 ? X1X(X1LD(512+256*w+64*(j)+16*d),X1K(&k->kz_v[c][4*w+(j)][2*d])) : X1X(X1X(X1LD(512+64*(j)+16*d),X1LD(768+64*(j)+16*d)),X1K(&k->km_v[c][j][2*d])))
#if defined(__AVX__) && !defined(__AVX512VL__)
/* The step as one asm block (AT&T, VEX): %[t0..t8] scratch, %[A0..A6] accumulators, %[M7] %[M8] memory accumulators,
 * %[qa] the u data of the step (v at +512, limb j at +64 j, pass 2 adds limb j+4 at +256), %[ku] the u key (v at +8192
 * for kz, +4096 for km).  With 16 registers and the compilers' own schedules gcc 9/11 spill 4-9 accumulators per step
 * and clang 4; this order never spills.  EVEX builds (32 registers, vpternlog) do better with the C step below. */
#define X1ASM_LD2(t,o) "vmovdqu " #o "(%[qa]),%[" #t "]\n\tvpxor " #o "(%[ku]),%[" #t "],%[" #t "]\n\t"
#define X1ASM_LD2B(t,o) "vmovdqu 512+" #o "(%[qa]),%[" #t "]\n\tvpxor 8192+" #o "(%[ku]),%[" #t "],%[" #t "]\n\t"
#define X1ASM_LD3(t,o) "vmovdqu " #o "(%[qa]),%[" #t "]\n\tvpxor " #o "+256(%[qa]),%[" #t "],%[" #t "]\n\tvpxor " #o "(%[ku]),%[" #t "],%[" #t "]\n\t"
#define X1ASM_LD3B(t,o) "vmovdqu 512+" #o "(%[qa]),%[" #t "]\n\tvpxor 768+" #o "(%[qa]),%[" #t "],%[" #t "]\n\tvpxor 4096+" #o "(%[ku]),%[" #t "],%[" #t "]\n\t"
#define X1ASM_X(a,b,d) "vpxor %[" #a "],%[" #b "],%[" #d "]\n\t"
/* A += a b: lo and hi products into t8 and x, one dependent xor into A (x: a free scratch register) */
#define X1ASM_MAC(A,a,b,x) "vpclmulqdq $0,%[" #b "],%[" #a "],%[t8]\n\tvpclmulqdq $17,%[" #b "],%[" #a "],%[" #x "]\n\tvpxor %[" #x "],%[t8],%[t8]\n\tvpxor %[t8],%[" #A "],%[" #A "]\n\t"
/* the same with only t8 free (all eight operands live) */
#define X1ASM_MAC1(A,a,b) "vpclmulqdq $0,%[" #b "],%[" #a "],%[t8]\n\tvpxor %[t8],%[" #A "],%[" #A "]\n\tvpclmulqdq $17,%[" #b "],%[" #a "],%[t8]\n\tvpxor %[t8],%[" #A "],%[" #A "]\n\t"
/* memory accumulator M += a b */
#define X1ASM_MACM(M,a,b,x) "vpclmulqdq $0,%[" #b "],%[" #a "],%[t8]\n\tvpclmulqdq $17,%[" #b "],%[" #a "],%[" #x "]\n\tvpxor %[" #x "],%[t8],%[t8]\n\tvpxor %[" #M "],%[t8],%[t8]\n\tvmovdqu %[t8],%[" #M "]\n\t"
#define X1ASM_STEP(LD) \
    LD(t0,0) LD##B(t1,0) X1ASM_MAC(A0,t0,t1,t2) \
    LD(t2,64) LD##B(t3,64) X1ASM_MAC(A1,t2,t3,t4) \
    X1ASM_X(t2,t0,t4) X1ASM_X(t3,t1,t5) X1ASM_MAC(A2,t4,t5,t6) \
    LD(t6,128) LD##B(t7,128) X1ASM_X(t6,t0,t0) X1ASM_X(t7,t1,t1) X1ASM_MAC(A3,t6,t7,t4) \
    LD(t4,192) LD##B(t5,192) X1ASM_X(t4,t2,t2) X1ASM_X(t5,t3,t3) X1ASM_MAC1(A4,t4,t5) \
    X1ASM_X(t4,t6,t6) X1ASM_X(t5,t7,t7) X1ASM_MAC(A5,t6,t7,t4) \
    X1ASM_MAC(A6,t0,t1,t4) X1ASM_MACM(M7,t2,t3,t4) \
    X1ASM_X(t2,t0,t0) X1ASM_X(t3,t1,t1) X1ASM_MACM(M8,t0,t1,t4)
#define X1ASM_OUT [A0]"+x"(A0),[A1]"+x"(A1),[A2]"+x"(A2),[A3]"+x"(A3),[A4]"+x"(A4),[A5]"+x"(A5),[A6]"+x"(A6),[M7]"+m"(M[7]),[M8]"+m"(M[8]), \
    [t0]"=&x"(t0),[t1]"=&x"(t1),[t2]"=&x"(t2),[t3]"=&x"(t3),[t4]"=&x"(t4),[t5]"=&x"(t5),[t6]"=&x"(t6),[t7]"=&x"(t7),[t8]"=&x"(t8)
#define X1ASM_IN [qa]"r"(qa),[ku]"r"(ku) : "memory"
typedef char ph1x_asm_layout_check[(offsetof(ph512v1_key,kz_v)==offsetof(ph512v1_key,kz_u)+8192 && offsetof(ph512v1_key,km_v)==offsetof(ph512v1_key,km_u)+4096) ? 1 : -1];
#endif
/* one pass (w = 0, 1, 2) over chunks c0..c1: Aio[0..8] += the pass's 9 point sums; pf: the next group's data to prefetch */
PH1_TX __attribute__((always_inline)) static inline void ph1x_pass(const ph512v1_key *k, const uint8_t *p, int c0, int c1, const int w, __m128i *Aio, const uint8_t *pf, const int al){
    __m128i A0=Aio[0],A1=Aio[1],A2=Aio[2],A3=Aio[3],A4=Aio[4],A5=Aio[5],A6=Aio[6],A7=Aio[7],A8=Aio[8];
#if defined(__AVX__) && !defined(__AVX512VL__)
    __m128i M[9]; M[7]=A7; M[8]=A8; (void)al;
#endif
    for(int c=c0;c<c1;c++){ const uint8_t *q=p+(size_t)c*PH1_CHUNK;
        if(w<2 && pf){ const char *nx=(const char*)pf+(size_t)(c-c0)*PH1_CHUNK+512*w; for(int l=0;l<512;l+=64) _mm_prefetch(nx+l,_MM_HINT_T0); }
        for(int d=0;d<4;d++){
#if defined(__AVX__) && !defined(__AVX512VL__)
            const uint8_t *qa = w<2 ? q+256*w+16*d : q+16*d;
            const uint64_t *ku = w<2 ? &k->kz_u[c][4*w][2*d] : &k->km_u[c][0][2*d];
            __m128i t0,t1,t2,t3,t4,t5,t6,t7,t8;
            if(w<2) __asm__(X1ASM_STEP(X1ASM_LD2) : X1ASM_OUT : X1ASM_IN);
            else    __asm__(X1ASM_STEP(X1ASM_LD3) : X1ASM_OUT : X1ASM_IN);
#else
            __m128i a0=X1A(0), b0=X1B(0); X1C(A0,a0,b0);
            __m128i a1=X1A(1), b1=X1B(1); X1C(A1,a1,b1);
            { __m128i s=X1X(a0,a1), t=X1X(b0,b1); X1C(A2,s,t); }
            __m128i a2=X1A(2), a3=X1A(3), b2=X1B(2), b3=X1B(3);
            a0=X1X(a0,a2); a1=X1X(a1,a3); b0=X1X(b0,b2); b1=X1X(b1,b3);
            X1C(A3,a2,b2); X1C(A4,a3,b3); a2=X1X(a2,a3); b2=X1X(b2,b3); X1C(A5,a2,b2);
            X1C(A6,a0,b0); X1C(A7,a1,b1); a0=X1X(a0,a1); b0=X1X(b0,b1); X1C(A8,a0,b0);
#endif
        } }
#if defined(__AVX__) && !defined(__AVX512VL__)
    A7=M[7]; A8=M[8];
#endif
    Aio[0]=A0; Aio[1]=A1; Aio[2]=A2; Aio[3]=A3; Aio[4]=A4; Aio[5]=A5; Aio[6]=A6; Aio[7]=A7; Aio[8]=A8;
}
PH1_TX __attribute__((always_inline)) static inline void ph1x_points_t(const ph512v1_key *k, const uint8_t *p, int nch, ph1_u128 *P, const int al){
    __m128i A[27]; for(int i=0;i<27;i++) A[i]=_mm_setzero_si128();
    for(int s=0;s<nch;s+=8){ int e=s+8<nch?s+8:nch; const uint8_t *pf = e<nch ? p+(size_t)e*PH1_CHUNK : 0;
        ph1x_pass(k,p,s,e,2,A+18,pf,al); ph1x_pass(k,p,s,e,0,A,pf,al); ph1x_pass(k,p,s,e,1,A+9,pf,al); }
    for(int i=0;i<27;i++) _mm_storeu_si128((__m128i*)&P[i],A[i]);
}
PH1_TX __attribute__((noinline)) static void ph1x_points_a(const ph512v1_key *k, const uint8_t *p, int nch, ph1_u128 *P){ ph1x_points_t(k,p,nch,P,1); }
PH1_TX __attribute__((noinline)) static void ph1x_points_u(const ph512v1_key *k, const uint8_t *p, int nch, ph1_u128 *P){ ph1x_points_t(k,p,nch,P,0); }
static inline void ph1x_points(const ph512v1_key *k, const uint8_t *p, int nch, ph1_u128 *P){
    if(((uintptr_t)k&15)==0) ph1x_points_a(k,p,nch,P); else ph1x_points_u(k,p,nch,P); }
/* ---- 128-bit primitives (SSE) for the body ---- */
#define PHV __m128i
#define PVX(a,b) _mm_xor_si128(a,b)
#define PVSL(v,n) _mm_slli_epi64(v,n)
#define PVSR(v,n) _mm_srli_epi64(v,n)
#define PVUP(v) _mm_slli_si128(v,8)
#define PVDN(v) _mm_srli_si128(v,8)
#define PVLD(p) _mm_loadu_si128((const __m128i*)(p))
#define PVST(p,v) _mm_storeu_si128((__m128i*)(p),v)
#define PVZ() _mm_setzero_si128()
#define PVMK(lo,hi) _mm_set_epi64x((long long)(hi),(long long)(lo))
#define PVULO(a,b) _mm_unpacklo_epi64(a,b)
#define PVUHI(a,b) _mm_unpackhi_epi64(a,b)
#define PVHSW(a) _mm_unpackhi_epi64(a,a)
#define PVSWAP(a) _mm_shuffle_epi32(a,0x4e)
#define PVC00(a,b) _mm_clmulepi64_si128(a,b,0x00)
#define PVC11(a,b) _mm_clmulepi64_si128(a,b,0x11)
#define PVM00 PVC00
#define PVM11 PVC11
#define PB(n) n##_z
#define PBT PH1_TZ
#define PB_POINTS(k,p,nch,P) ph1z_points(k,p,nch,P)
#include "chainhash512_body.inc"
/* ---- v1.1: AVX-512 latency path (one element = one zmm, qword i = limb i) ----
 * Same function; only the schedule differs from ph1_hash_z / ph1_final_z. */
typedef __m512i ph1Z;
#define PH1_TZD __attribute__((target("avx512f,avx512bw,avx512vl,avx512dq,vpclmulqdq,pclmul,sse4.1")))
#define ZI PH1_TZD static inline __attribute__((always_inline))
#define ZX(a,b) _mm512_xor_si512(a,b)
#define ZX3(a,b,c) _mm512_ternarylogic_epi64(a,b,c,0x96)
#define ZCL(a,b,i) _mm512_clmulepi64_epi128(a,b,i)
#define ZLD(p) _mm512_loadu_si512((const void*)(p))
#define ZUP(x,q) _mm512_alignr_epi64(x,_mm512_setzero_si512(),8-(q))
#define ZDN(x,q) _mm512_alignr_epi64(_mm512_setzero_si512(),x,8-(q))
/* one zmm lane broadcast, pinned to VSHUFI64X2 (compilers like to split it into two port-5 ops) */
#define PH1ZBC(m) ZI ph1Z ph1z_bc##m(ph1Z B){ ph1Z r; __asm__("vshufi64x2 $" #m "*0x55, %1, %1, %0" : "=v"(r) : "v"(B)); return r; }
PH1ZBC(0) PH1ZBC(1) PH1ZBC(2) PH1ZBC(3)
#undef PH1ZBC
#define ZROT(x,d) _mm512_alignr_epi64(x,x,8-(d))
/* PH1ZM[d]: qwords i < d all-ones (masks as data: ternary-logic operands from L1, no mask-register setup) */
static const uint64_t PH1ZM[8][8] __attribute__((aligned(64)))={
    {0},{~0ull},{~0ull,~0ull},{~0ull,~0ull,~0ull},{~0ull,~0ull,~0ull,~0ull},{~0ull,~0ull,~0ull,~0ull,~0ull},
    {~0ull,~0ull,~0ull,~0ull,~0ull,~0ull},{~0ull,~0ull,~0ull,~0ull,~0ull,~0ull,~0ull}};
#define ZM(d) ZLD(PH1ZM[d])
#define ZXAND(x,r,m) _mm512_ternarylogic_epi64(x,r,m,0x78)       /* x ^ (r & m) */
/* sum_d T[d] x^(64 d) mod P, T[d] of 512 bits (d = 0..8), plus inj.  Rotating T[d] by d qwords gives
 * lo+hi of its shifted value in ONE shuffle; hi = T8 + sum_d (R_d & [qwords < d]); x^512 = x^8+x^5+x^2+1 is
 * folded with shifts, the carry of hi's top word (= T8[7], known early) separately.                        */
ZI ph1Z ph1z_fold9(const ph1Z *T, ph1Z inj){
    ph1Z R1=ZROT(T[1],1),R2=ZROT(T[2],2),R3=ZROT(T[3],3),R4=ZROT(T[4],4),R5=ZROT(T[5],5),R6=ZROT(T[6],6),R7=ZROT(T[7],7);
    ph1Z X=ZX3(ZX3(T[0],T[8],inj),ZX3(R1,R2,R3),ZX3(R4,R5,ZX(R6,R7)));                      /* lo + hi      */
    ph1Z h3=ZXAND(_mm512_and_si512(R2,ZM(2)),R3,ZM(3)), h5=ZXAND(_mm512_and_si512(R4,ZM(4)),R5,ZM(5)), h7=ZXAND(_mm512_and_si512(R6,ZM(6)),R7,ZM(7));
    ph1Z hi=ZX3(ZXAND(T[8],R1,ZM(1)),h3,ZX(h5,h7));
    ph1Z t7=_mm512_alignr_epi64(T[8],T[8],7);                                                  /* word 0 = T8[7], early */
    ph1Z c7=ZX3(_mm512_srli_epi64(t7,62),_mm512_srli_epi64(t7,59),_mm512_srli_epi64(t7,56));
    ph1Z w=_mm512_and_si512(ZX3(_mm512_slli_epi64(c7,2),_mm512_slli_epi64(c7,5),_mm512_slli_epi64(c7,8)),ZM(1));
    ph1Z R=_mm512_alignr_epi64(hi,hi,7);
    ph1Z c=ZX3(_mm512_srli_epi64(R,62),_mm512_srli_epi64(R,59),_mm512_srli_epi64(R,56));     /* word 0 = carry of T8[7] */
    return ZX3(ZX3(X,_mm512_slli_epi64(hi,2),_mm512_slli_epi64(hi,5)),ZX3(_mm512_slli_epi64(hi,8),c,w),_mm512_setzero_si512());
}
/* broadcast lanes through memory: VBROADCASTI64X2 from a stack copy is a load, not a port-5 shuffle */
#define PH1ZBL(r,buf,m) __asm__("vbroadcasti64x2 %1, %0" : "=v"(r) : "m"(*(const __m128i*)((buf)+16*(m))))
ZI void ph1z_bkm(ph1Z B, ph1Z *Bm, ph1Z *Bk){
    uint8_t buf[128] __attribute__((aligned(64))); _mm512_store_si512((void*)buf,B); _mm512_store_si512((void*)(buf+64),ZX(B,_mm512_shuffle_epi32(B,(_MM_PERM_ENUM)0x4e)));
    PH1ZBL(Bm[0],buf,0); PH1ZBL(Bm[1],buf,1); PH1ZBL(Bm[2],buf,2); PH1ZBL(Bm[3],buf,3); PH1ZBL(Bk[0],buf,4); PH1ZBL(Bk[1],buf,5); PH1ZBL(Bk[2],buf,6); PH1ZBL(Bk[3],buf,7);
}
ZI void ph1z_bk(ph1Z B, ph1Z *Bm, ph1Z *Bk){            /* broadcast lanes of B and of B + swap64(B) */
    ph1Z Bs=ZX(B,_mm512_shuffle_epi32(B,(_MM_PERM_ENUM)0x4e));
    Bm[0]=ph1z_bc0(B); Bm[1]=ph1z_bc1(B); Bm[2]=ph1z_bc2(B); Bm[3]=ph1z_bc3(B); Bk[0]=ph1z_bc0(Bs); Bk[1]=ph1z_bc1(Bs); Bk[2]=ph1z_bc2(Bs); Bk[3]=ph1z_bc3(Bs); }
/* A*B as T[0..8] (unreduced, by qword shift), 128-bit-lane Karatsuba (12 clmul) against pre-broadcast B */
ZI void ph1z_mulT(ph1Z A, const ph1Z *Bm, const ph1Z *Bk, ph1Z *T){
    ph1Z As=ZX(A,_mm512_shuffle_epi32(A,(_MM_PERM_ENUM)0x4e)), L[4],H[4],K[4];
    for(int m=0;m<4;m++){ L[m]=ZCL(A,Bm[m],0x00); H[m]=ZCL(A,Bm[m],0x11); K[m]=ZCL(As,Bk[m],0x00); }
    T[0]=L[0]; T[1]=ZX3(K[0],L[0],H[0]); T[2]=ZX(H[0],L[1]); T[3]=ZX3(K[1],L[1],H[1]); T[4]=ZX(H[1],L[2]);
    T[5]=ZX3(K[2],L[2],H[2]); T[6]=ZX(H[2],L[3]); T[7]=ZX3(K[3],L[3],H[3]); T[8]=H[3];
}
/* pair product accumulation (schoolbook, 16 clmul) into T[0..8]: A = u + ku, Bv = v + kv */
ZI void ph1z_pairacc(ph1Z A, ph1Z Bv, ph1Z *T){
    ph1Z B0=ph1z_bc0(Bv),B1=ph1z_bc1(Bv),B2=ph1z_bc2(Bv),B3=ph1z_bc3(Bv);
#define PH1ZACC(m,Bm) T[2*m]=ZX(T[2*m],ZCL(A,Bm,0x00)); T[2*m+2]=ZX(T[2*m+2],ZCL(A,Bm,0x11)); T[2*m+1]=ZX3(T[2*m+1],ZCL(A,Bm,0x01),ZCL(A,Bm,0x10));
    PH1ZACC(0,B0) PH1ZACC(1,B1) PH1ZACC(2,B2) PH1ZACC(3,B3)
#undef PH1ZACC
}
/* lo + x^512 hi mod P */
ZI ph1Z ph1z_red(ph1Z lo, ph1Z hi){
    ph1Z R=_mm512_alignr_epi64(hi,hi,7), c=ZX3(_mm512_srli_epi64(R,62),_mm512_srli_epi64(R,59),_mm512_srli_epi64(R,56));
    ph1Z e=_mm512_and_si512(ZX3(_mm512_slli_epi64(c,2),_mm512_slli_epi64(c,5),_mm512_slli_epi64(c,8)),ZM(1));
    return ZX3(ZX3(lo,hi,_mm512_slli_epi64(hi,2)),ZX3(_mm512_slli_epi64(hi,5),_mm512_slli_epi64(hi,8),c),e);
}
/* E + x^64 O mod P for 512-bit E, O (the top qword of O wraps through x^512) */
ZI ph1Z ph1z_eo(ph1Z E, ph1Z O){
    ph1Z r=_mm512_alignr_epi64(O,O,7), s=_mm512_alignr_epi64(O,O,6);
    ph1Z a=_mm512_and_si512(ZX3(_mm512_slli_epi64(r,2),_mm512_slli_epi64(r,5),_mm512_slli_epi64(r,8)),ZM(1));
    ph1Z b=_mm512_and_si512(ZX3(_mm512_srli_epi64(s,62),_mm512_srli_epi64(s,59),_mm512_srli_epi64(s,56)),ZX(ZM(2),ZM(1)));
    return ZX3(ZX(E,r),a,b);
}
/* a + b mod 2^512: limbwise add, carry lookahead in mask registers */
ZI ph1Z ph1z_add512(ph1Z a, ph1Z b){
    ph1Z s=_mm512_add_epi64(a,b), ones=_mm512_set1_epi64(-1);
    __mmask8 g=_mm512_cmplt_epu64_mask(s,b), p=_mm512_cmpeq_epi64_mask(s,ones);
    __mmask8 inc=_kxor_mask8(_kadd_mask8(_kshiftli_mask8(g,1),p),p);
    return _mm512_mask_sub_epi64(s,inc,s,ones);
}
#ifndef PH1Z_BK1
#define PH1Z_BK1 ph1z_bkm
#endif
#ifndef PH1Z_BK2
#define PH1Z_BK2 ph1z_bkm
#endif
/* H = (v+c2)((v^2+c0)(v+v^2+c1)+c3)+c4 with v = V + tau.
 * With t1 = v^2 + c0 and u = v + c0 + c1 (known early): (v^2+c0)(v+v^2+c1) = t1 u + t1^2, so the first
 * product's broadcast operand u is off the chain and t1^2 (linear: two self-products) rides along. */
ZI void ph1z_final(const ph512v1_key *k, ph1Z V, uint8_t *out){
    const ph1Z perm=_mm512_set_epi64(7,3,6,2,5,1,4,0);                            /* lane l = (x_l, x_{l+4}) */
    ph1Z v=ph1z_add512(V,ZLD(k->tau)), T[9];
    ph1Z w=_mm512_permutexvar_epi64(perm,v);
    ph1Z qlo=ZCL(w,w,0x00), qhi=ZCL(w,w,0x11);
    ph1Z Um[4],Uk[4],Bm[4],Bk[4];
    PH1Z_BK1(ZX3(v,ZLD(k->c[0]),ZLD(k->c[1])),Um,Uk);                            /* u = v + c0 + c1    */
    PH1Z_BK2(ZX(v,ZLD(k->c[2])),Bm,Bk);                                           /* v + c2             */
    ph1Z t1=ph1z_red(ZX(qlo,ZLD(k->c[0])),qhi);                                   /* t1 = v^2 + c0      */
    ph1z_mulT(t1,Um,Uk,T);
    ph1Z w1=_mm512_permutexvar_epi64(perm,t1);
    T[0]=ZX(T[0],ZCL(w1,w1,0x00)); T[8]=ZX(T[8],ZCL(w1,w1,0x11));                  /* + t1^2             */
    ph1Z r=ph1z_fold9(T,ZLD(k->c[3]));                                            /* r + c3             */
    ph1z_mulT(r,Bm,Bk,T);
    _mm512_storeu_si512((void*)out,ph1z_fold9(T,ZLD(k->c[4])));
}
PH1_TZD static void ph1z_finalu(const ph512v1_key *k, const uint64_t *V, uint8_t *out){ ph1z_final(k,ZLD(V),out); }
static inline uint64_t ph1z_bmask(size_t r){ return r>=64 ? ~0ull : (1ull<<r)-1; }   /* r in 0..64 bytes */
/* V for n <= 64: V = n z + ku0 kv0 + sum_i u_i (kv0 x^(64i) mod P)  (one pair, v half empty) */
ZI ph1Z ph1z_v64(const ph512v1_key *k, const uint8_t *p, size_t n){
    ph1Z U=_mm512_maskz_loadu_epi8((__mmask64)ph1z_bmask(n),p), nb=_mm512_set1_epi64((long long)n), z=ZLD(k->z);
    ph1Z E=ZX(ZCL(nb,z,0x00),ZLD(k->k00)), O=ZCL(nb,z,0x10), U0=ph1z_bc0(U);
    E=ZX3(E,ZCL(U0,ZLD(k->w0[0]),0x00),ZCL(U0,ZLD(k->w0[1]),0x01)); O=ZX3(O,ZCL(U0,ZLD(k->w0[0]),0x10),ZCL(U0,ZLD(k->w0[1]),0x11));
    if(n>16){ ph1Z U1=ph1z_bc1(U); E=ZX3(E,ZCL(U1,ZLD(k->w0[2]),0x00),ZCL(U1,ZLD(k->w0[3]),0x01)); O=ZX3(O,ZCL(U1,ZLD(k->w0[2]),0x10),ZCL(U1,ZLD(k->w0[3]),0x11));
        if(n>32){ ph1Z U2=ph1z_bc2(U), U3=ph1z_bc3(U);
            E=ZX3(E,ZCL(U2,ZLD(k->w0[4]),0x00),ZCL(U2,ZLD(k->w0[5]),0x01)); O=ZX3(O,ZCL(U2,ZLD(k->w0[4]),0x10),ZCL(U2,ZLD(k->w0[5]),0x11));
            E=ZX3(E,ZCL(U3,ZLD(k->w0[6]),0x00),ZCL(U3,ZLD(k->w0[7]),0x01)); O=ZX3(O,ZCL(U3,ZLD(k->w0[6]),0x10),ZCL(U3,ZLD(k->w0[7]),0x11)); } }
    return ph1z_eo(E,O);
}
/* tail pairs (pair-major, the final partial chunk) at pair index q0.., plus n z, accumulated as T[0..8] */
ZI void ph1z_tail(const ph512v1_key *k, const uint8_t *b, size_t rem, size_t q0, size_t n, ph1Z *T){
    ph1Z nb=_mm512_set1_epi64((long long)n), z=ZLD(k->z);
    T[0]=ZCL(nb,z,0x00); T[1]=ZCL(nb,z,0x10); for(int d=2;d<9;d++) T[d]=_mm512_setzero_si512();
    size_t i=0;
    for(;128*i+128<=rem;i++){ const uint8_t *s=b+128*i;
        ph1z_pairacc(ZX(ZLD(s),ZLD(k->kup[q0+i])),ZX(ZLD(s+64),ZLD(k->kvp[q0+i])),T); }
    if(128*i<rem){ size_t r=rem-128*i; const uint8_t *s=b+128*i;
        ph1Z A=ZX(_mm512_maskz_loadu_epi8((__mmask64)ph1z_bmask(r),s),ZLD(k->kup[q0+i]));
        ph1Z Bv=ZX(_mm512_maskz_loadu_epi8((__mmask64)ph1z_bmask(r>64?r-64:0),s+64),ZLD(k->kvp[q0+i]));
        ph1z_pairacc(A,Bv,T); }
}
/* point sums of nch <= 16 full chunks for the one-block path: same sums as ph1z_points, pass-major so that only
 * nine accumulators are live (no zero-filled 28-register array on the stack) */
PH1_TZ __attribute__((noinline)) static void ph1z_points1(const ph512v1_key *k, const uint8_t *p, int nch, ph1_u128 *P){
    static const int wh[3]={0,1,2};
    for(int w=0;w<3;w++){ __m512i A[9]; for(int i=0;i<9;i++) A[i]=_mm512_setzero_si512();
        ph1z_pass(k,p,0,nch,wh[w],A);
        for(int g=0;g<8;g+=4){ __m512i a=A[g],b=A[g+1],c=A[g+2],d=A[g+3];
            __m512i x=ZX(_mm512_shuffle_i64x2(a,b,0x44),_mm512_shuffle_i64x2(a,b,0xEE));
            __m512i y=ZX(_mm512_shuffle_i64x2(c,d,0x44),_mm512_shuffle_i64x2(c,d,0xEE));
            _mm512_storeu_si512((void*)&P[9*w+g],ZX(_mm512_shuffle_i64x2(x,y,0x88),_mm512_shuffle_i64x2(x,y,0xDD))); }
        __m256i h=_mm256_xor_si256(_mm512_castsi512_si256(A[8]),_mm512_extracti64x4_epi64(A[8],1));
        _mm_storeu_si128((__m128i*)&P[9*w+8],_mm_xor_si128(_mm256_castsi256_si128(h),_mm256_extracti128_si256(h,1))); }
}
/* > 1 block: the v1 region code, compiled with the v1 target set (keeps its code generation unchanged) */
PH1_TZ __attribute__((noinline)) static void ph1z_bulkV(const ph512v1_key *k, const uint8_t *p, size_t n, uint64_t *w){
    PHV W[4]; ph1_hashV_z(k,p,n,W); for(int i=0;i<4;i++) PVST(w+2*i,W[i]); }
PH1_TZD static void ph1z_hash(const ph512v1_key *k, const uint8_t *p, size_t n, uint8_t *out){
    ph1Z V;
    if(n<=64){ V = n ? ph1z_v64(k,p,n) : _mm512_setzero_si512(); }
    else if(n<=PH1_BLOCK){                              /* one block: V = n z + b_1 */
        size_t F=n/PH1_CHUNK, rem=n-F*PH1_CHUNK; ph1Z T[9];
        ph1z_tail(k,p+F*PH1_CHUNK,rem,8*F,n,T); V=ph1z_fold9(T,_mm512_setzero_si512());   /* independent of the chunks */
        if(F){ ph1_u128 P[28]; PHV Pv[27],O[4]; if(F<=4) ph1z_points1(k,p,(int)F,P); else ph1z_points(k,p,(int)F,P); for(int i=0;i<27;i++) Pv[i]=PVLD(&P[i]); ph1_finish_z(Pv,O);
            V=ZX(V,_mm512_inserti64x4(_mm512_castsi256_si512(_mm256_set_m128i(O[1],O[0])),_mm256_set_m128i(O[3],O[2]),1)); }
    } else { uint64_t w[8] __attribute__((aligned(64))); ph1z_bulkV(k,p,n,w); V=ZLD(w); }
    ph1z_final(k,V,out);
}
#undef PB
#undef PBT
#undef PB_POINTS
#define PB(n) n##_x
#define PBT PH1_TX
#define PB_POINTS(k,p,nch,P) ph1x_points(k,p,nch,P)
#include "chainhash512_body.inc"
#undef PB
#undef PBT
#undef PB_POINTS

/* ============================== NEON backend ================================ */
#elif !defined(PH512V1_PORTABLE_ONLY) && defined(__aarch64__) && !defined(__AARCH64EB__) && (defined(__ARM_FEATURE_AES) || defined(__ARM_FEATURE_CRYPTO))
#define PH1_ARM 1
#include <arm_neon.h>
static inline int ph512v1_detect(void){ return PH512V1_NEON; }
static inline __attribute__((always_inline)) uint64x2_t ph1_pm0(uint64x2_t a, uint64x2_t b){ uint64x2_t r; __asm__("pmull %0.1q, %1.1d, %2.1d":"=w"(r):"w"(a),"w"(b)); return r; }
static inline __attribute__((always_inline)) uint64x2_t ph1_pm1(uint64x2_t a, uint64x2_t b){ uint64x2_t r; __asm__("pmull2 %0.1q, %1.2d, %2.2d":"=w"(r):"w"(a),"w"(b)); return r; }
/* Apple-fused multiply-accumulate: pmull vT; eor vT,vT,vAcc */
static inline __attribute__((always_inline)) uint64x2_t ph1_nf0(uint64x2_t acc, uint64x2_t a, uint64x2_t b){
    uint64x2_t t; __asm__("pmull %0.1q, %1.1d, %2.1d\n\teor %0.16b, %0.16b, %3.16b" : "=&w"(t) : "w"(a), "w"(b), "w"(acc)); return t; }
static inline __attribute__((always_inline)) uint64x2_t ph1_nf1(uint64x2_t acc, uint64x2_t a, uint64x2_t b){
    uint64x2_t t; __asm__("pmull2 %0.1q, %1.2d, %2.2d\n\teor %0.16b, %0.16b, %3.16b" : "=&w"(t) : "w"(a), "w"(b), "w"(acc)); return t; }
static inline __attribute__((always_inline)) uint64x2_t ph1_nx(uint64x2_t a, uint64x2_t b){ uint64x2_t r; __asm__("eor %0.16b, %1.16b, %2.16b" : "=w"(r) : "w"(a), "w"(b)); return r; }
#if defined(__ARM_FEATURE_SHA3)
#define N1E3(a,b,c) veor3q_u64(a,b,c)
#else
#define N1E3(a,b,c) veorq_u64(a,veorq_u64(b,c))
#endif
#define N1ACC(A,a,b) A=ph1_nf1(ph1_nf0(A,a,b),a,b)
#define N1P2(A,i,a0,a1,b0,b1) do{ N1ACC(A[i],a0,b0); N1ACC(A[i+1],a1,b1); N1ACC(A[i+2],ph1_nx(a0,a1),ph1_nx(b0,b1)); }while(0)
#define N1P4(A,a0,a1,a2,a3,b0,b1,b2,b3) do{ N1P2(A,0,a0,a1,b0,b1); N1P2(A,3,a2,a3,b2,b3); N1P2(A,6,ph1_nx(a0,a2),ph1_nx(a1,a3),ph1_nx(b0,b2),ph1_nx(b1,b3)); }while(0)
#define N1LD(o) vreinterpretq_u64_u8(vld1q_u8(q+(o)))
#define N1L(o,kk) ph1_nx(N1LD(o),vld1q_u64(kk))
#define N1M(o,kk) N1E3(N1LD(o),N1LD((o)+256),vld1q_u64(kk))
static inline __attribute__((always_inline)) void ph1n_pass(const ph512v1_key *k, const uint8_t *p, int c0, int c1, int which, uint64x2_t *Aout){
    uint64x2_t A[9]; for(int i=0;i<9;i++) A[i]=Aout[i];
    for(int c=c0;c<c1;c++) for(int d=0;d<4;d++){ const uint8_t *q=p+(size_t)c*PH1_CHUNK+16*d; int o=2*d; uint64x2_t a0,a1,a2,a3,b0,b1,b2,b3;
        if(which==0){ a0=N1L(0,&k->kz_u[c][0][o]); a1=N1L(64,&k->kz_u[c][1][o]); a2=N1L(128,&k->kz_u[c][2][o]); a3=N1L(192,&k->kz_u[c][3][o]);
                      b0=N1L(512,&k->kz_v[c][0][o]); b1=N1L(576,&k->kz_v[c][1][o]); b2=N1L(640,&k->kz_v[c][2][o]); b3=N1L(704,&k->kz_v[c][3][o]); }
        else if(which==1){ a0=N1L(256,&k->kz_u[c][4][o]); a1=N1L(320,&k->kz_u[c][5][o]); a2=N1L(384,&k->kz_u[c][6][o]); a3=N1L(448,&k->kz_u[c][7][o]);
                      b0=N1L(768,&k->kz_v[c][4][o]); b1=N1L(832,&k->kz_v[c][5][o]); b2=N1L(896,&k->kz_v[c][6][o]); b3=N1L(960,&k->kz_v[c][7][o]); }
        else { a0=N1M(0,&k->km_u[c][0][o]); a1=N1M(64,&k->km_u[c][1][o]); a2=N1M(128,&k->km_u[c][2][o]); a3=N1M(192,&k->km_u[c][3][o]);
               b0=N1M(512,&k->km_v[c][0][o]); b1=N1M(576,&k->km_v[c][1][o]); b2=N1M(640,&k->km_v[c][2][o]); b3=N1M(704,&k->km_v[c][3][o]); }
        N1P4(A,a0,a1,a2,a3,b0,b1,b2,b3); }
    for(int i=0;i<9;i++) Aout[i]=A[i];
}
__attribute__((noinline)) static void ph1n_points(const ph512v1_key *k, const uint8_t *p, int nch, ph1_u128 *P){
    uint64x2_t A[27]; for(int i=0;i<27;i++) A[i]=vdupq_n_u64(0);
    for(int s=0;s<nch;s+=4){ int e=s+4<nch?s+4:nch; ph1n_pass(k,p,s,e,0,A); ph1n_pass(k,p,s,e,1,A+9); ph1n_pass(k,p,s,e,2,A+18); }
    for(int i=0;i<27;i++) vst1q_u64(&P[i].lo,A[i]);
}
#define PHV uint64x2_t
#define PVX(a,b) veorq_u64(a,b)
#define PVSL(v,n) vshlq_n_u64(v,n)
#define PVSR(v,n) vshrq_n_u64(v,n)
#define PVUP(v) vextq_u64(vdupq_n_u64(0),v,1)
#define PVDN(v) vextq_u64(v,vdupq_n_u64(0),1)
#define PVLD(p) vld1q_u64((const uint64_t*)(p))
#define PVST(p,v) vst1q_u64((uint64_t*)(p),v)
#define PVZ() vdupq_n_u64(0)
#define PVMK(lo,hi) vcombine_u64(vcreate_u64(lo),vcreate_u64(hi))
#define PVULO(a,b) vzip1q_u64(a,b)
#define PVUHI(a,b) vzip2q_u64(a,b)
#define PVHSW(a) vextq_u64(a,a,1)
#define PVSWAP(a) vextq_u64(a,a,1)
#define PVC00(a,b) ph1_pm0(a,b)
#define PVC11(a,b) ph1_pm1(a,b)
/* the latency-bound multiply uses the intrinsic forms (measured faster on M2 than asm-pinned PMULL) */
#define PVM00(a,b) vreinterpretq_u64_p128(vmull_p64(vgetq_lane_u64(a,0),vgetq_lane_u64(b,0)))
#define PVM11(a,b) vreinterpretq_u64_p128(vmull_high_p64(vreinterpretq_p64_u64(a),vreinterpretq_p64_u64(b)))
#define PB(n) n##_n
#define PBT
#define PB_POINTS(k,p,nch,P) ph1n_points(k,p,nch,P)
#include "chainhash512_body.inc"
#undef PB
#undef PBT
#undef PB_POINTS
/* ---- v1.1: NEON latency path (element = 4 x uint64x2, vector k = limbs 2k, 2k+1) ----
 * Same function; only the schedule differs from ph1_hash_n / ph1_final_n.  Products are schoolbook
 * (64 PMULL, accumulated by position: E even / M odd qword offsets); reductions multiply the high half
 * by x^8+x^5+x^2+1 = 0x125 with PMULL. */
typedef uint64x2_t ph1N;
#define NI static inline __attribute__((always_inline))
#define NX(a,b) veorq_u64(a,b)
#define NX3(a,b,c) N1E3(a,b,c)
#define NZ vdupq_n_u64(0)
#define NSW(a) vextq_u64(a,a,1)
#define NLO(m) vextq_u64(NZ,m,1)          /* (0, m.lo)  = m.lo x^64 */
#define NHI(m) vextq_u64(m,NZ,1)          /* (m.hi, 0)  = m.hi x^-64 */
#define NP0(a,b) PVM00(a,b)
#define NP1(a,b) PVM11(a,b)
#define NLD(p) vld1q_u64((const uint64_t*)(p))
/* R[0..7] (1024-bit, vector k = limbs 2k,2k+1) of A*B; Bs = swap64(B) */
NI void ph1n_mulraw(const ph1N *A, const ph1N *B, const ph1N *Bs, ph1N *R){
    ph1N E[8],M[7];
    for(int k=0;k<8;k++) E[k]=NZ; for(int k=0;k<7;k++) M[k]=NZ;
    for(int i=0;i<4;i++) for(int j=0;j<4;j++){
        E[i+j]=NX(E[i+j],NP0(A[i],B[j])); E[i+j+1]=NX(E[i+j+1],NP1(A[i],B[j]));
        M[i+j]=NX3(M[i+j],NP0(A[i],Bs[j]),NP1(A[i],Bs[j])); }
    R[0]=NX(E[0],NLO(M[0]));
    for(int k=1;k<7;k++) R[k]=NX3(E[k],NLO(M[k]),NHI(M[k-1]));
    R[7]=NX(E[7],NHI(M[6]));
}
/* O = R[0..3] + x^512 R[4..7] mod P, + inj (O may alias nothing) */
NI void ph1n_red(const ph1N *R, const ph1N *inj, ph1N *O){
    const ph1N K=vdupq_n_u64(0x125); ph1N P1[4];
    for(int k=0;k<4;k++) P1[k]=NP1(R[4+k],K);
    ph1N w=NP0(NHI(P1[3]),K);                                  /* x^512 overflow of the top word, folded again */
    O[0]=NX3(NX3(R[0],inj[0],NP0(R[4],K)),NLO(P1[0]),w);
    for(int k=1;k<4;k++) O[k]=NX3(NX3(R[k],inj[k],NP0(R[4+k],K)),NLO(P1[k]),NHI(P1[k-1]));
}
/* a + b mod 2^512 through the general registers */
NI void ph1n_add512(const ph1N *a, const uint64_t *b, ph1N *o){
    uint64_t x[8],c=0; for(int i=0;i<4;i++){ x[2*i]=vgetq_lane_u64(a[i],0); x[2*i+1]=vgetq_lane_u64(a[i],1); }
    for(int j=0;j<8;j++){ unsigned long long cc; x[j]=__builtin_addcll(x[j],b[j],c,&cc); c=cc; }
    for(int i=0;i<4;i++) o[i]=vcombine_u64(vcreate_u64(x[2*i]),vcreate_u64(x[2*i+1]));
}
NI void ph1n_final(const ph512v1_key *k, const ph1N *V, uint8_t *out){
    ph1N v[4], R[8], I[4], t1[4], t2[4], B[4], Bs[4], X[4], Xs[4];
    ph1n_add512(V,k->tau,v);
    for(int i=0;i<4;i++){ B[i]=NX(v[i],NLD(k->c[2]+2*i)); Bs[i]=NSW(B[i]); }        /* v + c2, off the chain */
    for(int i=0;i<4;i++){ R[2*i]=NP0(v[i],v[i]); R[2*i+1]=NP1(v[i],v[i]); }
    for(int i=0;i<4;i++) I[i]=NLD(k->c[0]+2*i);
    ph1n_red(R,I,t1);                                                               /* v^2 + c0 */
    for(int i=0;i<4;i++){ ph1N d=NX3(v[i],NLD(k->c[0]+2*i),NLD(k->c[1]+2*i)); t2[i]=NX(t1[i],d); Xs[i]=NSW(t2[i]); }
    ph1n_mulraw(t1,t2,Xs,R);
    for(int i=0;i<4;i++) I[i]=NLD(k->c[3]+2*i);
    ph1n_red(R,I,X);                                                                /* r + c3 */
    ph1n_mulraw(X,B,Bs,R);
    for(int i=0;i<4;i++) I[i]=NLD(k->c[4]+2*i);
    ph1n_red(R,I,X);
    for(int i=0;i<4;i++) vst1q_u64((uint64_t*)(out+16*i),X[i]);
}
static void ph1n_finalu(const ph512v1_key *k, const uint64_t *W, uint8_t *out){ ph1N V[4]; for(int i=0;i<4;i++) V[i]=NLD(W+2*i); ph1n_final(k,V,out); }
/* r (1..16) bytes at p, zero padded; `back` = bytes readable before p (>= 16 - r when the load must go backwards) */
NI ph1N ph1n_ld16(const uint8_t *p, size_t r, int front){
    static const uint8_t iota[16]={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
    uint8x16_t io=vld1q_u8(iota);
    if(front) return vreinterpretq_u64_u8(vandq_u8(vld1q_u8(p),vcltq_u8(io,vdupq_n_u8((uint8_t)r))));
    return vreinterpretq_u64_u8(vqtbl1q_u8(vld1q_u8(p+r-16),vaddq_u8(io,vdupq_n_u8((uint8_t)(16-r)))));
}
/* V for n <= 64: V = n z + ku0 kv0 + sum_i u_i (kv0 x^(64i) mod P) */
NI void ph1n_v64(const ph512v1_key *k, const uint8_t *p, size_t n, ph1N *V){
    ph1N E[4],O[4],U[4]; size_t nw=(n+15)/16;
    if(n<16){ int front=((uintptr_t)p&4095)<=4096-16; U[0]=ph1n_ld16(p,n,front); }
    else { for(size_t j=0;j+1<nw;j++) U[j]=NLD(p+16*j); U[nw-1]=ph1n_ld16(p+16*(nw-1),n-16*(nw-1),0); }
    ph1N nv=vcombine_u64(vcreate_u64((uint64_t)n),vcreate_u64(0));
    for(int q=0;q<4;q++){ E[q]=NX(NP0(nv,NLD(k->z+2*q)),NLD(k->k00+2*q)); O[q]=NP0(nv,NLD(k->zs+2*q)); }
    for(size_t j=0;j<nw;j++) for(int q=0;q<4;q++){
        E[q]=NX3(E[q],NP0(U[j],NLD(k->w0[2*j]+2*q)),NP1(U[j],NLD(k->w0s[2*j+1]+2*q)));
        O[q]=NX3(O[q],NP0(U[j],NLD(k->w0s[2*j]+2*q)),NP1(U[j],NLD(k->w0[2*j+1]+2*q))); }
    const ph1N K=vdupq_n_u64(0x125);
    V[0]=NX3(E[0],NLO(O[0]),NP0(NHI(O[3]),K));
    for(int q=1;q<4;q++) V[q]=NX3(E[q],NLO(O[q]),NHI(O[q-1]));
}
/* tail pairs (pair-major) at pair index q0.. plus n z, accumulated as R[0..7] (1024-bit) */
NI void ph1n_tail(const ph512v1_key *k, const uint8_t *b, size_t rem, size_t q0, size_t n, ph1N *R){
    ph1N E[8],M[7]; for(int q=0;q<8;q++) E[q]=NZ; for(int q=0;q<7;q++) M[q]=NZ;
    ph1N nv=vcombine_u64(vcreate_u64((uint64_t)n),vcreate_u64(0));
    for(int q=0;q<4;q++){ E[q]=NP0(nv,NLD(k->z+2*q)); M[q]=NP0(nv,NLD(k->zs+2*q)); }
    for(size_t i=0;128*i<rem;i++){ size_t r=rem-128*i; const uint8_t *s=b+128*i; ph1N A[4],B[4],Bs[4];
        if(r>=128){ for(int j=0;j<4;j++){ A[j]=NX(NLD(s+16*j),NLD(k->kup[q0+i]+2*j)); B[j]=NX(NLD(s+64+16*j),NLD(k->kvp[q0+i]+2*j)); } }
        else { uint8_t buf[128]; memset(buf,0,128); memcpy(buf,s,r);
            for(int j=0;j<4;j++){ A[j]=NX(NLD(buf+16*j),NLD(k->kup[q0+i]+2*j)); B[j]=NX(NLD(buf+64+16*j),NLD(k->kvp[q0+i]+2*j)); } }
        for(int j=0;j<4;j++) Bs[j]=NSW(B[j]);
        for(int a=0;a<4;a++) for(int c=0;c<4;c++){
            E[a+c]=NX(E[a+c],NP0(A[a],B[c])); E[a+c+1]=NX(E[a+c+1],NP1(A[a],B[c]));
            M[a+c]=NX3(M[a+c],NP0(A[a],Bs[c]),NP1(A[a],Bs[c])); } }
    R[0]=NX(E[0],NLO(M[0]));
    for(int q=1;q<7;q++) R[q]=NX3(E[q],NLO(M[q]),NHI(M[q-1]));
    R[7]=NX(E[7],NHI(M[6]));
}
static void ph1n_hash(const ph512v1_key *k, const uint8_t *p, size_t n, uint8_t *out){
    ph1N V[4];
    if(n<=64){ if(n) ph1n_v64(k,p,n,V); else V[0]=V[1]=V[2]=V[3]=NZ; }
    else if(n<=PH1_BLOCK){
        size_t F=n/PH1_CHUNK, rem=n-F*PH1_CHUNK; ph1N R[8], I[4]={NZ,NZ,NZ,NZ};
        ph1n_tail(k,p+F*PH1_CHUNK,rem,8*F,n,R); ph1n_red(R,I,V);                        /* independent of the chunks */
        if(F){ ph1_u128 P[28]; PHV Pv[27],O[4]; ph1n_points(k,p,(int)F,P); for(int i=0;i<27;i++) Pv[i]=PVLD(&P[i]); ph1_finish_n(Pv,O);
            for(int i=0;i<4;i++) V[i]=NX(V[i],O[i]); }
    } else ph1_hashV_n(k,p,n,V);
    ph1n_final(k,V,out);
}

#else
static inline int ph512v1_detect(void){ return PH512V1_PORTABLE; }
#endif

/* ================================ dispatch ================================= */
static inline void ph512v1(const ph512v1_key *k, const void *data, size_t n, uint8_t out[64]){
    switch(k->backend){
#if defined(PH1_X86)
    case PH512V1_AVX512: ph1z_hash(k,(const uint8_t*)data,n,out); return;
    case PH512V1_PCLMUL: ph1_hash_x(k,(const uint8_t*)data,n,out); return;
#elif defined(PH1_ARM)
    case PH512V1_NEON:   ph1n_hash(k,(const uint8_t*)data,n,out); return;
#endif
    default: ph512v1_ref(k,data,n,out); return; }
}
/* backend-neutral u64 interfaces for streaming */
static inline void ph1_blockval(const ph512v1_key *k, const uint8_t *p, size_t n, uint64_t *b){
    switch(k->backend){
#if defined(PH1_X86)
    case PH512V1_AVX512: ph1_blockval_z(k,p,n,b); return;
    case PH512V1_PCLMUL: ph1_blockval_x(k,p,n,b); return;
#elif defined(PH1_ARM)
    case PH512V1_NEON:   ph1_blockval_n(k,p,n,b); return;
#endif
    default: ph1_blockval_portable(k,p,n,b); return; }
}
static inline void ph1_regionval(const ph512v1_key *k, uint64_t *W, uint64_t b[][8], int q){
    switch(k->backend){
#if defined(PH1_X86)
    case PH512V1_AVX512: ph1_regionval_z(k,W,b,q); return;
    case PH512V1_PCLMUL: ph1_regionval_x(k,W,b,q); return;
#elif defined(PH1_ARM)
    case PH512V1_NEON:   ph1_regionval_n(k,W,b,q); return;
#endif
    default: ph1_region_ref(k,W,b,q); return; }
}
static inline void ph1_finalu(const ph512v1_key *k, const uint64_t *V, uint8_t *out){
    switch(k->backend){
#if defined(PH1_X86)
    case PH512V1_AVX512: ph1z_finalu(k,V,out); return;
    case PH512V1_PCLMUL: ph1_finalu_x(k,V,out); return;
#elif defined(PH1_ARM)
    case PH512V1_NEON:   ph1n_finalu(k,V,out); return;
#endif
    default: ph1_final_ref(k,V,out); return; }
}

static inline void ph1_mulx(const ph512v1_key *k, const uint64_t *a, const uint64_t *b, uint64_t *o){
    switch(k->backend){
#if defined(PH1_X86)
    case PH512V1_AVX512: ph1_mulu_z(a,b,o); return;
    case PH512V1_PCLMUL: ph1_mulu_x(a,b,o); return;
#elif defined(PH1_ARM)
    case PH512V1_NEON:   ph1_mulu_n(a,b,o); return;
#endif
    default: ph1_mul(a,b,o); return; }
}
/* ================================ streaming ================================= *
 * One-shot V = l z^m' + sum c_r z^(m'-r).  The stream runs Horner from 0 (W) over regions as they
 * complete and adds l*z^m' at the end.  A full 16 KiB block has the same value whether or not it is
 * the last one, and a full region the same c, so both are folded as soon as they are complete.     */
typedef struct {
    const ph512v1_key *k; uint64_t W[8]; uint64_t b[PH1_R][8]; int nb; uint64_t nreg, n; size_t fill, boff;
    uint8_t bstore[PH1_BLOCK+64];   /* the block buffer at bstore + boff, 64-byte aligned where the stream was initialized */
} ph512v1_stream;
#define PH1_SBUF(st) ((st)->bstore+(st)->boff)
static inline void ph512v1_stream_init(ph512v1_stream *st, const ph512v1_key *k){ st->k=k; memset(st->W,0,64); st->nb=0; st->nreg=0; st->n=0; st->fill=0;
    st->boff=(64-((uintptr_t)st->bstore&63))&63; }
static inline void ph1_stream_block(ph512v1_stream *st, const uint8_t *blk, size_t len){
    ph1_blockval(st->k,blk,len,st->b[st->nb++]);
    if(st->nb==PH1_R){ ph1_regionval(st->k,st->W,st->b,PH1_R); st->nb=0; st->nreg++; } }
static inline void ph512v1_stream_update(ph512v1_stream *st, const void *data, size_t len){
    const uint8_t *p=(const uint8_t*)data; st->n+=len;
    if(st->fill){ size_t m=PH1_BLOCK-st->fill; if(m>len) m=len; memcpy(PH1_SBUF(st)+st->fill,p,m); st->fill+=m; p+=m; len-=m;
        if(st->fill==PH1_BLOCK){ ph1_stream_block(st,PH1_SBUF(st),PH1_BLOCK); st->fill=0; } }
    while(len>=PH1_BLOCK){ ph1_stream_block(st,p,PH1_BLOCK); p+=PH1_BLOCK; len-=PH1_BLOCK; }
    if(len){ memcpy(PH1_SBUF(st),p,len); st->fill=len; }
}
static inline void ph512v1_stream_final(ph512v1_stream *st, uint8_t out[64]){
    const ph512v1_key *k=st->k;
    if(st->nreg==0 && st->nb==0){ ph512v1(k,PH1_SBUF(st),st->fill,out); return; }    /* whole message still buffered */
    if(st->fill) ph1_blockval(k,PH1_SBUF(st),st->fill,st->b[st->nb++]);  /* last (partial or empty) block */
    if(st->nb){ ph1_regionval(k,st->W,st->b,st->nb); st->nreg++; }
    uint64_t R[8]={1,0,0,0,0,0,0,0}, Z[8], N[8]={0}, T[8]; memcpy(Z,k->z,64); N[0]=st->n;       /* z^m' by square-and-multiply */
    for(uint64_t e=st->nreg;e;e>>=1){ if(e&1) ph1_mulx(k,R,Z,R); if(e>1) ph1_mulx(k,Z,Z,Z); }
    ph1_mulx(k,N,R,T); for(int j=0;j<8;j++) T[j]^=st->W[j];
    ph1_finalu(k,T,out);
}

/* ================= public API ================= */
#define CHAINHASH512_KEY_BYTES PH512V1_KEY_BYTES   /* 576 */
#define CHAINHASH512_KEY_WORDS (CHAINHASH512_KEY_BYTES/8)
enum { CH512_PORTABLE=PH512V1_PORTABLE, CH512_PCLMUL=PH512V1_PCLMUL, CH512_AVX512=PH512V1_AVX512, CH512_NEON=PH512V1_NEON };
/* The key object: the expanded key at store + off, 64-byte aligned at the address where the key was initialized, so
 * a key in place at any 8-byte-aligned address (malloc, new, the stack, static storage) has aligned tables.  A copy
 * (memcpy) keeps off and computes the same digests; its tables may then be unaligned (slower on some backends). */
typedef struct { uint64_t off; unsigned char store[sizeof(ph512v1_key) + 64]; } ph512v1_akey;
static inline ph512v1_key *ph512v1_place(ph512v1_akey *k){ k->off = (64 - ((uintptr_t)k->store & 63)) & 63; return (ph512v1_key *)(void *)(k->store + k->off); }
static inline const ph512v1_key *ph512v1_in(const ph512v1_akey *k){ return (const ph512v1_key *)(const void *)(k->store + k->off); }
typedef ph512v1_akey chainhash512_key;
typedef ph512v1_stream chainhash512_stream;
static inline int chainhash512_backend(void) { return ph512v1_detect(); }
static inline int chainhash512_has_backend(int b) { int h=ph512v1_detect(); return b==PH512V1_PORTABLE || b==h || (h==PH512V1_AVX512 && b==PH512V1_PCLMUL); }
/* key = s || y || tau || c0..c4 || z, 64 bytes each, little endian (docs/SPEC-512.md section 1).
 * No key is rejected. The backend is fixed here (-1 or an unavailable backend: the best one available). */
static inline void chainhash512_key_from_bytes_with_backend(chainhash512_key *k, const uint8_t p[CHAINHASH512_KEY_BYTES], int b) {
    ph512v1_init_backend(ph512v1_place(k), p, (b >= 0 && chainhash512_has_backend(b)) ? b : ph512v1_detect());
}
static inline void chainhash512_key_from_bytes(chainhash512_key *k, const uint8_t p[CHAINHASH512_KEY_BYTES]) { chainhash512_key_from_bytes_with_backend(k, p, -1); }
/* the same 576 bytes as 72 little-endian 64-bit words */
static inline void chainhash512_key_from_words_with_backend(chainhash512_key *k, const uint64_t w[CHAINHASH512_KEY_WORDS], int b) {
    uint8_t p[CHAINHASH512_KEY_BYTES]; int i, j;
    for (i = 0; i < CHAINHASH512_KEY_WORDS; i++) for (j = 0; j < 8; j++) p[8*i+j] = (uint8_t)(w[i] >> (8*j));
    chainhash512_key_from_bytes_with_backend(k, p, b);
}
static inline void chainhash512_key_from_words(chainhash512_key *k, const uint64_t w[CHAINHASH512_KEY_WORDS]) { chainhash512_key_from_words_with_backend(k, w, -1); }
/* SplitMix64 expansion of a seed into the 576 key bytes: for benchmarks and tests, not covered by the bound */
static inline void chainhash512_key_from_seed_with_backend(chainhash512_key *k, uint64_t seed, int b) {
    uint8_t p[CHAINHASH512_KEY_BYTES]; int i, j;
    for (i = 0; i < CHAINHASH512_KEY_WORDS; i++) {
        uint64_t z = (seed += UINT64_C(0x9e3779b97f4a7c15));
        z = (z ^ (z >> 30)) * UINT64_C(0xbf58476d1ce4e5b9); z = (z ^ (z >> 27)) * UINT64_C(0x94d049bb133111eb); z ^= z >> 31;
        for (j = 0; j < 8; j++) p[8*i+j] = (uint8_t)(z >> (8*j));
    }
    chainhash512_key_from_bytes_with_backend(k, p, b);
}
static inline void chainhash512_key_from_seed(chainhash512_key *k, uint64_t seed) { chainhash512_key_from_seed_with_backend(k, seed, -1); }
static inline int chainhash512_key_backend(const chainhash512_key *k) { return ph512v1_in(k)->backend; }
static inline void chainhash512(const chainhash512_key *k, const void *data, size_t len, uint8_t out[64]) { ph512v1(ph512v1_in(k), data, len, out); }
/* the definition, literally (bit-serial); for tests */
static inline void chainhash512_reference(const chainhash512_key *k, const void *data, size_t len, uint8_t out[64]) { ph512v1_ref(ph512v1_in(k), data, len, out); }
static inline void chainhash512_init(chainhash512_stream *s, const chainhash512_key *k) { ph512v1_stream_init(s, ph512v1_in(k)); }
static inline void chainhash512_update(chainhash512_stream *s, const void *data, size_t len) { ph512v1_stream_update(s, data, len); }
static inline void chainhash512_final(chainhash512_stream *s, uint8_t out[64]) { ph512v1_stream_final(s, out); }

#endif /* CHAINHASH512_H */
