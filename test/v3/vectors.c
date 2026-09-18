#define main property_main
#include "property.c"
#undef main
int main(void) {
    uint64_t seed=123,w[39],r[8]; uint8_t m[2048]; unsigned i; size_t lengths[]={0,1,17,64,256,1024,2048};
    for(i=0;i<8;i++) { uint64_t z=(seed+=UINT64_C(0x9e3779b97f4a7c15));z=(z^(z>>30))*UINT64_C(0xbf58476d1ce4e5b9);z=(z^(z>>27))*UINT64_C(0x94d049bb133111eb);r[i]=z^(z>>31); }
    w[0]=r[0];for(i=1;i<32;i++)w[i]=imul(w[i-1],r[0]);for(i=0;i<7;i++)w[32+i]=r[i+1];for(i=0;i<2048;i++)m[i]=(uint8_t)i;
    puts("{\"seed\":123,\"message\":\"byte i = i mod 256\",\"digests\":{");
    for(i=0;i<7;i++)printf("\"%zu\":\"%016llx\"%s\n",lengths[i],(unsigned long long)independent(w,m,lengths[i]),i==6?"":",");puts("}}");return 0;
}
