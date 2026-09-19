#include "chainhash128.h"
#include "oracle.h"
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#define MAXCFG 80
typedef struct {int b,k,lazy,school;} config;
static config cfg[MAXCFG]; static unsigned nc;
static uint64_t rng=UINT64_C(0x66f012ec55172490);
static uint64_t random64(void) {rng^=rng<<13;rng^=rng>>7;rng^=rng<<17;return rng;}
static void check(ch128_word a,ch128_word b,unsigned trial,size_t n,int c,const char *what) {
 if(!ch128_equal(a,b)) {fprintf(stderr,"FAIL %s trial=%u n=%zu cfg=%d got=%016llx%016llx expected=%016llx%016llx\n",what,trial,n,c,(unsigned long long)a.hi,(unsigned long long)a.lo,(unsigned long long)b.hi,(unsigned long long)b.lo);exit(1);}
}
typedef struct {const chainhash128_key *key;const uint8_t *p;size_t n;ch128_word v[MAXCFG];uint64_t blocks[MAXCFG];} job;
static void *worker(void *arg) {job *j=(job *)arg;unsigned c;for(c=0;c<nc;c++){chainhash128_stream s;chainhash128_init(&s,j->key,cfg[c].k,cfg[c].lazy,cfg[c].b,cfg[c].school);if(j->n){chainhash128_update(&s,j->p,j->n);j->v[c]=chainhash128_partial(&s);j->blocks[c]=s.blocks;}else{j->v[c]=ch128_make(0,0);j->blocks[c]=0;}}return NULL;}
int main(int argc,char **argv) {
 unsigned count=argc>1?(unsigned)atoi(argv[1]):20000,trial,c;int b,k,l,z;uint8_t *mem=(uint8_t *)malloc(65536+64);uint64_t checksum=0;
 for(b=0;b<=4;b++)if(chainhash128_has_backend(b))for(k=1;k<=8;k*=2)for(l=0;l<2;l++)for(z=0;z<2;z++){config a={b,k,l,z};cfg[nc++]=a;}
 for(trial=0;trial<count;trial++) {
  size_t n=trial<=8192?trial:(size_t)(random64()%8193),i,off,split;uint8_t *p=mem+(trial%32);ch128_word expected;chainhash128_key key;uint8_t random_key[ORACLE_IDEAL_BYTES];job a,d;pthread_t t0,t1;
  if(trial>8192 && trial<8961) n=256*((trial-8193)/3+1)+(trial-8193)%3-1;
  else if(trial>8192 && trial%64==0)n=random64()%65537;
  for(i=0;i<n;i++)p[i]=(uint8_t)random64();
  for(i=0;i<sizeof(random_key);i++)random_key[i]=(uint8_t)random64();
  /* Exercise 39-word keys and byte keys, including exceptional seeds/slopes. */
  if(trial%17==0)memset(random_key,0,16);
  if(trial%19==0)memset(random_key+16,0,16);
  if(trial%23==0){memset(random_key+16,0,16);random_key[16]=1;}
  key=trial&1?oracle_ideal_key(random_key):chainhash128_key_from_bytes(random_key);
  if(trial%19==0 || trial%23==0){ch128_word w[CH128_W+7];memcpy(w,key.ph,sizeof(key.ph));w[CH128_W]=ch128_make(trial%23==0,0);for(i=0;i<5;i++)w[CH128_W+1+i]=key.c[i];w[CH128_W+6]=key.tau;key=chainhash128_key_from_words(w);}
  expected=oracle(&key,p,n);checksum^=expected.lo^expected.hi;
  check(chainhash128_portable(&key,p,n),expected,trial,n,-1,"reference");
  split=(size_t)(random64()%(n/CH128_REGION+1))*CH128_REGION;
  memset(&a,0,sizeof(a));memset(&d,0,sizeof(d));a.key=d.key=&key;a.p=p;a.n=split;d.p=p+split;d.n=n-split;
  assert(!pthread_create(&t0,NULL,worker,&a));assert(!pthread_create(&t1,NULL,worker,&d));
  for(c=0;c<nc;c++) {chainhash128_stream s;ch128_word v;config f=cfg[c];uint64_t chunks=(trial+1)*UINT64_C(0x9e3779b97f4a7c15)+c;
    check(chainhash128_evaluate(&key,p,n,f.k,f.lazy,f.b,f.school),expected,trial,n,c,"evaluate");
    chainhash128_init(&s,&key,f.k,f.lazy,f.b,f.school);off=0;chainhash128_update(&s,NULL,0);
    while(off<n){size_t step;chunks^=chunks<<13;chunks^=chunks>>7;chunks^=chunks<<17;step=1+(chunks%701);if(step>n-off)step=n-off;chainhash128_update(&s,p+off,step);off+=step;if(off%5==0)chainhash128_update(&s,NULL,0);}
    v=chainhash128_final(&s);check(v,expected,trial,n,c,"chunking");
    if(f.k==1 && !f.lazy)check(chainhash128_with_backend(&key,p,n,f.b,f.school),expected,trial,n,c,"bulk");
  }
  assert(!pthread_join(t0,NULL));assert(!pthread_join(t1,NULL));
  for(c=0;c<nc;c++){uint64_t blocks=a.blocks[c]+d.blocks[c];ch128_word v;if(!blocks)blocks=1;v=chainhash128_join(&key,a.v[c],d.v[c],d.blocks[c],cfg[c].b);v=ch128_xor(v,ch128_mul(ch128_make(n,0),ch128_pow(key.yp[1],blocks,cfg[c].b),cfg[c].b));check(ch128_finish(&key,v,cfg[c].b),expected,trial,n,c,"two_threads");}
  if(trial%1000==0){printf("checked=%u configs=%u block=%d checksum=%016llx\n",trial,nc,CHAINHASH128_BLOCK_BYTES,(unsigned long long)checksum);fflush(stdout);}
 }
 printf("PASS inputs=%u configs=%u block=%d oracle=bit_serial streaming=all two_threads=all checksum=%016llx\n",count,nc,CHAINHASH128_BLOCK_BYTES,(unsigned long long)checksum);free(mem);return 0;
}

#ifdef NDEBUG
#error "Tests must be compiled with assertions enabled"
#endif
