#include "Platform.h"
#include "Timing.h"
#include "chainhash.h"
#include <cstdio>
double cycle_timer_mult=1;
static volatile uint64_t sink;
#define STATES uint64x2_t a0={1,2},a1={3,4},a2={5,6},a3={7,8},a4={9,10},a5={11,12},a6={13,14},a7={15,16},y={123456789,987654321},z={147258369,963852741}
#define KEEP sink=vgetq_lane_u64(veorq_u64(veorq_u64(a0,a1),veorq_u64(veorq_u64(a2,a3),veorq_u64(veorq_u64(a4,a5),veorq_u64(a6,a7)))),0)
#define PM(a) __asm__ volatile("pmull %0.1q, %0.1d, %1.1d" : "+w"(a):"w"(y))
#define EO(a) __asm__ volatile("eor3 %0.16b, %0.16b, %1.16b, %2.16b" : "+w"(a):"w"(y),"w"(z))
#define EE(a) __asm__ volatile("eor %0.16b, %0.16b, %1.16b" : "+w"(a):"w"(y))
__attribute__((noinline)) static void pmull(size_t n) { STATES; do { PM(a0);PM(a1);PM(a2);PM(a3);PM(a4);PM(a5);PM(a6);PM(a7); } while(--n);KEEP; }
__attribute__((noinline)) static void eor3(size_t n) { STATES; do { EO(a0);EO(a1);EO(a2);EO(a3);EO(a4);EO(a5);EO(a6);EO(a7); } while(--n);KEEP; }
__attribute__((noinline)) static void eor(size_t n) { STATES; do { EE(a0);EE(a1);EE(a2);EE(a3);EE(a4);EE(a5);EE(a6);EE(a7); } while(--n);KEEP; }
int main(void) {cycle_timer_init();printf("# calibrated_cycles_per_ns=%.9f\n",cycle_timer_mult);puts("operation,run,cycles_per_instruction");const char *names[]={"pmull","eor3","eor"};void (*fn[])(size_t)={pmull,eor3,eor};for(unsigned j=0;j<3;j++)for(unsigned r=0;r<3;r++){uint64_t t=cycle_timer_start();fn[j](2000000);t=cycle_timer_end()-t;printf("%s,%u,%.9f\n",names[j],r+1,t/16000000.0);}}
