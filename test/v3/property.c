#include "chainhash3.h"
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
/* Independent memo evaluator: eager field multiplication by repeated X,
 * iterate PRESENT message words, decode i, accumulate c_t, serial Horner.
 * No header arithmetic, index helpers, key expansion or finalizer used. */
static uint64_t imul(uint64_t a,uint64_t b) { uint64_t r=0; int bit; for(bit=0;bit<64;bit++) { if(b&1) r^=a; b>>=1; if(a>>63) a=(a<<1)^0x1b; else a<<=1; } return r; }
static uint64_t iw(const uint8_t *p,size_t n,size_t i) { uint64_t r=0; size_t j; for(j=0;j<8 && 8*i+j<n;j++) r|=(uint64_t)p[8*i+j]<<(8*j); return r; }
static uint64_t independent(const uint64_t key[39],const uint8_t *m,size_t n) {
    size_t words=n/8+(n%8!=0),i,blocks=1; uint64_t *c=(uint64_t *)calloc(4*(n/1024+1),8),v=n,q,r;
    for(i=0;i<words;i++) { size_t R=i/128,C=(i%128)/16,h=(i%16)/8,j=(i%8)/2,e=i%2,t=4*R+j,slot=2*C+e;
        if(h) continue;
        if(t+1>blocks) blocks=t+1;
        c[t]^=imul(iw(m,n,i)^key[2*slot],iw(m,n,i+8)^key[2*slot+1]);
    }
    for(i=0;i<blocks;i++) v=imul(v,key[32])^c[i]; free(c);
    v+=key[38]; q=imul(v,v); r=imul(q^key[33],v^q^key[34]); return imul(v^key[35],r^key[36])^key[37];
}
static uint64_t rnd(uint64_t *s) { *s^=*s<<13; *s^=*s>>7; *s^=*s<<17; return *s; }
static void check(uint64_t got,uint64_t want,size_t n,int b,int k,int l,const char *what) {
    if(got!=want) { fprintf(stderr,"FAIL %s n=%zu backend=%d k=%d lazy=%d got=%016llx want=%016llx\n",what,n,b,k,l,(unsigned long long)got,(unsigned long long)want); exit(1); }
}
typedef struct { const chainhash_v3_key *key; const uint8_t *m; size_t n; unsigned k; int l,b; uint64_t v,p; } work;
static void *worker(void *vp) { work *w=(work *)vp; chainhash_v3_stream s; if(!w->n) { w->v=w->p=0; return NULL; } chainhash_v3_init(&s,w->key,w->k,w->l,w->b); chainhash_v3_update(&s,w->m,w->n); w->v=chainhash_v3_partial(&s); w->p=s.blocks; return NULL; }
/* Persistent workers make EVERY matrix split concurrent without creating
 * 1.5 million threads. A generation barrier protects the per-case key. */
static pthread_mutex_t split_mutex=PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t split_ready=PTHREAD_COND_INITIALIZER,split_done=PTHREAD_COND_INITIALIZER;
static unsigned split_generation=0,split_completed=0; static int split_stop=0;
static work split_job[2]; static pthread_t split_threads[2];
static void *split_loop(void *arg) {
    unsigned seen=0,id=(unsigned)(uintptr_t)arg;
    pthread_mutex_lock(&split_mutex);
    for(;;) {
        while(seen==split_generation && !split_stop) pthread_cond_wait(&split_ready,&split_mutex);
        if(split_stop) break;
        seen=split_generation; pthread_mutex_unlock(&split_mutex);
        worker(&split_job[id]);
        pthread_mutex_lock(&split_mutex); ++split_completed; pthread_cond_signal(&split_done);
    }
    pthread_mutex_unlock(&split_mutex); return NULL;
}
static void concurrent_split(work *a,work *b) {
    pthread_mutex_lock(&split_mutex); split_job[0]=*a; split_job[1]=*b;
    split_completed=0; ++split_generation; pthread_cond_broadcast(&split_ready);
    while(split_completed<2) pthread_cond_wait(&split_done,&split_mutex);
    *a=split_job[0]; *b=split_job[1]; pthread_mutex_unlock(&split_mutex);
}
int main(int argc,char **argv) {
    unsigned count=argc>1?(unsigned)atoi(argv[1]):20000,iteration; uint64_t rng=argc>2?strtoull(argv[2],0,0):123456789,checksum=0; size_t capacity=2097152+4096;
    uint64_t seedbase=rng;
    uint8_t *allocation=(uint8_t *)malloc(capacity+64); unsigned ks[]={1,2,4,8};
    if(!chainhash_v3_selftest()) return 2;
    if(pthread_create(&split_threads[0],NULL,split_loop,(void *)(uintptr_t)0) || pthread_create(&split_threads[1],NULL,split_loop,(void *)(uintptr_t)1)) abort();
    { unsigned trial,i,j; for(trial=0;trial<100;trial++) {
        uint8_t bytes[312]; uint64_t w[39],h; chainhash_v3_key kb,kw;
        for(i=0;i<312;i++) bytes[i]=(uint8_t)rnd(&rng);
        for(i=0;i<39;i++) { w[i]=0; for(j=0;j<8;j++) w[i]|=(uint64_t)bytes[8*i+j]<<(8*j); }
        kb=chainhash_v3_key_from_ideal_bytes(bytes); kw=chainhash_v3_key_from_words(w);
        if(memcmp(&kb,&kw,sizeof(kb))) abort();
        kb=chainhash_v3_key_from_bytes(bytes);
        for(i=0;i<7;i++) w[32+i]=iw(bytes,64,i+1);
        w[0]=iw(bytes,64,0); for(i=1;i<32;i++) w[i]=imul(w[i-1],w[0]);
        kw=chainhash_v3_key_from_words(w); if(memcmp(&kb,&kw,sizeof(kb))) abort();
        h=independent(w,bytes,312); check(chainhash_v3(&kb,bytes,312),h,312,chainhash_v3_backend(),4,1,"model-A-constructor");
    } }
    for(iteration=0;iteration<count+4120;iteration++) {
        size_t n; uint64_t key[39]; chainhash_v3_key k; uint64_t want; unsigned i,ki; int b,l; uint8_t *m=allocation+(iteration%64);
        rng=seedbase+UINT64_C(0x9e3779b97f4a7c15)*(iteration+1);
        if(iteration<count) n=rnd(&rng)%4097;
        else if(iteration<count+4097) n=iteration-count;
        else { unsigned q=iteration-count-4097; n=q<18 ? (size_t)(1+q/3)*2048+q%3-1 : 65536+(q-18)*262144; }
        for(i=0;i<39;i++) key[i]=rnd(&rng);
        if(iteration%2==0) { uint64_t s=key[0]; for(i=1;i<32;i++) key[i]=imul(key[i-1],s); }
        if(iteration%257==0) key[32]=0; if(iteration%263==0) key[32]=1;
        if(iteration%269==0) memset(key,0,sizeof(key));
        for(i=0;i<n;i++) m[i]=(uint8_t)rnd(&rng);
        k=chainhash_v3_key_from_words(key); want=independent(key,m,n);
        check(chainhash_v3_portable(&k,m,n),want,n,0,1,0,"reference");
        check(chainhash_v3(&k,m,n),want,n,chainhash_v3_backend(),4,1,"dispatch");
        for(b=0;b<=4;b++) if(chainhash_v3_has_backend(b)) {
            check(chainhash_v3_with_backend(&k,m,n,b),want,n,b,4,1,"specialized");
            for(ki=0;ki<4;ki++) for(l=0;l<2;l++) {
                chainhash_v3_stream st; size_t off=0; unsigned stride=ks[ki];
                check(chainhash_v3_evaluate(&k,m,n,stride,l,b),want,n,b,stride,l,"one-shot");
                chainhash_v3_init(&st,&k,stride,l,b); chainhash_v3_update(&st,NULL,0);
                while(off<n) { size_t take=1+rnd(&rng)%1500; if(take>n-off) take=n-off; chainhash_v3_update(&st,m+off,take); off+=take; }
                check(chainhash_v3_final(&st),want,n,b,stride,l,"stream");
                /* Same full matrix also checks the split identity. */
                { size_t cut=(n/2048)*1024; work a={&k,m,cut,stride,l,b,0,0},z={&k,m+cut,n-cut,stride,l,b,0,0}; uint64_t v,p;
                  concurrent_split(&a,&z); p=a.p+z.p; if(!p) p=1; v=chainhash_v3_join(&k,a.v,z.v,z.p,b)^chv3_fmul(n,chv3_pow(k.yp[1],p,b),b);
                  check(chv3_finish(&k,v,b),want,n,b,stride,l,"split-matrix"); }
            }
        }
        checksum^=want;
        if(iteration%1000==0) { printf("progress %u n=%zu\n",iteration,n); fflush(stdout); }
    }
    pthread_mutex_lock(&split_mutex); split_stop=1; pthread_cond_broadcast(&split_ready); pthread_mutex_unlock(&split_mutex);
    pthread_join(split_threads[0],NULL); pthread_join(split_threads[1],NULL);
    printf("PASS random=%u exhaustive=4097 long/boundary=23 backend=%d checksum=%016llx\n",count,chainhash_v3_backend(),(unsigned long long)checksum); free(allocation); return 0;
}
