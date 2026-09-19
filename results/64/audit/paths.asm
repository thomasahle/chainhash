
audit/paths.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <chv3_hwprod>:
       0:	c4 e1 f9 6e c7       	vmovq  xmm0,rdi
       5:	c4 e1 f9 6e ce       	vmovq  xmm1,rsi
       a:	c4 e3 79 44 d1 00    	vpclmullqlqdq xmm2,xmm0,xmm1
      10:	c5 f9 7f 54 24 e8    	vmovdqa XMMWORD PTR [rsp-0x18],xmm2
      16:	48 8b 44 24 e8       	mov    rax,QWORD PTR [rsp-0x18]
      1b:	48 8b 54 24 f0       	mov    rdx,QWORD PTR [rsp-0x10]
      20:	c3                   	ret    
      21:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
      28:	00 00 00 00 
      2c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000000030 <chv3_fastfinish>:
      30:	48 03 b7 b8 01 00 00 	add    rsi,QWORD PTR [rdi+0x1b8]
      37:	c5 f9 6f 0d 00 00 00 	vmovdqa xmm1,XMMWORD PTR [rip+0x0]        # 3f <chv3_fastfinish+0xf>
      3e:	00 
      3f:	c4 e1 f9 6e c6       	vmovq  xmm0,rsi
      44:	c4 e3 79 44 d8 00    	vpclmullqlqdq xmm3,xmm0,xmm0
      4a:	c4 e3 61 44 d1 11    	vpclmulhqhqdq xmm2,xmm3,xmm1
      50:	c4 e3 69 44 e1 11    	vpclmulhqhqdq xmm4,xmm2,xmm1
      56:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
      5a:	c5 fa 7e a7 98 01 00 	vmovq  xmm4,QWORD PTR [rdi+0x198]
      61:	00 
      62:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
      66:	c5 fa 7e 9f 90 01 00 	vmovq  xmm3,QWORD PTR [rdi+0x190]
      6d:	00 
      6e:	c5 d9 ef e0          	vpxor  xmm4,xmm4,xmm0
      72:	c5 e1 ef da          	vpxor  xmm3,xmm3,xmm2
      76:	c5 d9 ef d2          	vpxor  xmm2,xmm4,xmm2
      7a:	c4 e3 61 44 da 00    	vpclmullqlqdq xmm3,xmm3,xmm2
      80:	c5 fa 7e 97 a0 01 00 	vmovq  xmm2,QWORD PTR [rdi+0x1a0]
      87:	00 
      88:	c4 e3 61 44 e1 11    	vpclmulhqhqdq xmm4,xmm3,xmm1
      8e:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
      92:	c5 fa 7e 87 a8 01 00 	vmovq  xmm0,QWORD PTR [rdi+0x1a8]
      99:	00 
      9a:	c4 e3 59 44 e9 11    	vpclmulhqhqdq xmm5,xmm4,xmm1
      a0:	c5 d9 ef e5          	vpxor  xmm4,xmm4,xmm5
      a4:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
      a8:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
      ac:	c4 e3 69 44 d0 00    	vpclmullqlqdq xmm2,xmm2,xmm0
      b2:	c4 e3 69 44 c1 11    	vpclmulhqhqdq xmm0,xmm2,xmm1
      b8:	c4 e3 79 44 c9 11    	vpclmulhqhqdq xmm1,xmm0,xmm1
      be:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
      c2:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
      c6:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
      cb:	48 33 87 b0 01 00 00 	xor    rax,QWORD PTR [rdi+0x1b0]
      d2:	c3                   	ret    
      d3:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
      da:	00 00 00 00 
      de:	66 90                	xchg   ax,ax

00000000000000e0 <chv3_region128>:
      e0:	48 8d 46 40          	lea    rax,[rsi+0x40]
      e4:	c5 fa 6f 2e          	vmovdqu xmm5,XMMWORD PTR [rsi]
      e8:	c5 d1 ef 07          	vpxor  xmm0,xmm5,XMMWORD PTR [rdi]
      ec:	48 83 c6 10          	add    rsi,0x10
      f0:	48 83 c2 10          	add    rdx,0x10
      f4:	c5 fa 6f 76 30       	vmovdqu xmm6,XMMWORD PTR [rsi+0x30]
      f9:	c5 c9 ef 4f 10       	vpxor  xmm1,xmm6,XMMWORD PTR [rdi+0x10]
      fe:	c5 fa 6f 7e 70       	vmovdqu xmm7,XMMWORD PTR [rsi+0x70]
     103:	c5 fa 6f ae b0 00 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0xb0]
     10a:	00 
     10b:	c5 c1 ef 5f 20       	vpxor  xmm3,xmm7,XMMWORD PTR [rdi+0x20]
     110:	c4 63 79 44 f9 11    	vpclmulhqhqdq xmm15,xmm0,xmm1
     116:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
     11c:	c5 fa 6f b6 f0 00 00 	vmovdqu xmm6,XMMWORD PTR [rsi+0xf0]
     123:	00 
     124:	c5 d1 ef 4f 30       	vpxor  xmm1,xmm5,XMMWORD PTR [rdi+0x30]
     129:	c5 c9 ef 57 40       	vpxor  xmm2,xmm6,XMMWORD PTR [rdi+0x40]
     12e:	c5 f9 7f 44 24 d8    	vmovdqa XMMWORD PTR [rsp-0x28],xmm0
     134:	c5 fa 6f be 30 01 00 	vmovdqu xmm7,XMMWORD PTR [rsi+0x130]
     13b:	00 
     13c:	c5 fa 6f ae 70 01 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0x170]
     143:	00 
     144:	c4 63 61 44 f1 11    	vpclmulhqhqdq xmm14,xmm3,xmm1
     14a:	c4 e3 61 44 d9 00    	vpclmullqlqdq xmm3,xmm3,xmm1
     150:	c5 c1 ef 4f 50       	vpxor  xmm1,xmm7,XMMWORD PTR [rdi+0x50]
     155:	c5 fa 6f b6 b0 01 00 	vmovdqu xmm6,XMMWORD PTR [rsi+0x1b0]
     15c:	00 
     15d:	c5 d1 ef 7f 60       	vpxor  xmm7,xmm5,XMMWORD PTR [rdi+0x60]
     162:	c5 fa 6f ae f0 01 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0x1f0]
     169:	00 
     16a:	c4 c1 61 ef de       	vpxor  xmm3,xmm3,xmm14
     16f:	c4 63 69 44 e9 11    	vpclmulhqhqdq xmm13,xmm2,xmm1
     175:	c4 e3 69 44 d1 00    	vpclmullqlqdq xmm2,xmm2,xmm1
     17b:	c5 c9 ef 4f 70       	vpxor  xmm1,xmm6,XMMWORD PTR [rdi+0x70]
     180:	c5 fa 6f b7 90 00 00 	vmovdqu xmm6,XMMWORD PTR [rdi+0x90]
     187:	00 
     188:	c5 c9 ef a6 30 02 00 	vpxor  xmm4,xmm6,XMMWORD PTR [rsi+0x230]
     18f:	00 
     190:	c4 c1 69 ef d5       	vpxor  xmm2,xmm2,xmm13
     195:	c4 63 41 44 e1 11    	vpclmulhqhqdq xmm12,xmm7,xmm1
     19b:	c4 e3 41 44 f9 00    	vpclmullqlqdq xmm7,xmm7,xmm1
     1a1:	c5 d1 ef 8f 80 00 00 	vpxor  xmm1,xmm5,XMMWORD PTR [rdi+0x80]
     1a8:	00 
     1a9:	c5 fa 6f af a0 00 00 	vmovdqu xmm5,XMMWORD PTR [rdi+0xa0]
     1b0:	00 
     1b1:	c5 d1 ef b6 70 02 00 	vpxor  xmm6,xmm5,XMMWORD PTR [rsi+0x270]
     1b8:	00 
     1b9:	c5 fa 6f af c0 00 00 	vmovdqu xmm5,XMMWORD PTR [rdi+0xc0]
     1c0:	00 
     1c1:	c5 e9 ef d7          	vpxor  xmm2,xmm2,xmm7
     1c5:	c4 63 71 44 dc 11    	vpclmulhqhqdq xmm11,xmm1,xmm4
     1cb:	c4 e3 71 44 cc 00    	vpclmullqlqdq xmm1,xmm1,xmm4
     1d1:	c5 fa 6f a7 b0 00 00 	vmovdqu xmm4,XMMWORD PTR [rdi+0xb0]
     1d8:	00 
     1d9:	c5 d9 ef a6 b0 02 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rsi+0x2b0]
     1e0:	00 
     1e1:	c5 d1 ef ae f0 02 00 	vpxor  xmm5,xmm5,XMMWORD PTR [rsi+0x2f0]
     1e8:	00 
     1e9:	c4 c1 71 ef cc       	vpxor  xmm1,xmm1,xmm12
     1ee:	c4 63 49 44 cc 11    	vpclmulhqhqdq xmm9,xmm6,xmm4
     1f4:	c4 e3 49 44 f4 00    	vpclmullqlqdq xmm6,xmm6,xmm4
     1fa:	c4 c1 71 ef cb       	vpxor  xmm1,xmm1,xmm11
     1ff:	c5 fa 6f a7 d0 00 00 	vmovdqu xmm4,XMMWORD PTR [rdi+0xd0]
     206:	00 
     207:	c5 d9 ef a6 30 03 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rsi+0x330]
     20e:	00 
     20f:	c5 31 ef ce          	vpxor  xmm9,xmm9,xmm6
     213:	c4 63 51 44 c4 11    	vpclmulhqhqdq xmm8,xmm5,xmm4
     219:	c4 e3 51 44 ec 00    	vpclmullqlqdq xmm5,xmm5,xmm4
     21f:	c5 fa 6f a7 e0 00 00 	vmovdqu xmm4,XMMWORD PTR [rdi+0xe0]
     226:	00 
     227:	c5 59 ef 96 70 03 00 	vpxor  xmm10,xmm4,XMMWORD PTR [rsi+0x370]
     22e:	00 
     22f:	c5 fa 6f a7 f0 00 00 	vmovdqu xmm4,XMMWORD PTR [rdi+0xf0]
     236:	00 
     237:	c5 d9 ef a6 b0 03 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rsi+0x3b0]
     23e:	00 
     23f:	c5 31 ef cd          	vpxor  xmm9,xmm9,xmm5
     243:	c4 e3 29 44 c4 11    	vpclmulhqhqdq xmm0,xmm10,xmm4
     249:	c4 e3 29 44 e4 00    	vpclmullqlqdq xmm4,xmm10,xmm4
     24f:	c5 f9 7f 44 24 e8    	vmovdqa XMMWORD PTR [rsp-0x18],xmm0
     255:	c5 81 ef 44 24 d8    	vpxor  xmm0,xmm15,XMMWORD PTR [rsp-0x28]
     25b:	c5 39 ef c4          	vpxor  xmm8,xmm8,xmm4
     25f:	c5 39 ef 44 24 e8    	vpxor  xmm8,xmm8,XMMWORD PTR [rsp-0x18]
     265:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
     269:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
     26d:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
     271:	c4 c1 79 ef c1       	vpxor  xmm0,xmm0,xmm9
     276:	c4 c1 79 ef c0       	vpxor  xmm0,xmm0,xmm8
     27b:	c5 fa 7f 42 f0       	vmovdqu XMMWORD PTR [rdx-0x10],xmm0
     280:	48 39 f0             	cmp    rax,rsi
     283:	0f 85 5b fe ff ff    	jne    e4 <chv3_region128+0x4>
     289:	c3                   	ret    
     28a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000000290 <chv3_region256>:
     290:	55                   	push   rbp
     291:	48 89 e5             	mov    rbp,rsp
     294:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
     298:	c4 e2 7d 5a 3f       	vbroadcasti128 ymm7,XMMWORD PTR [rdi]
     29d:	c4 e2 7d 5a 47 10    	vbroadcasti128 ymm0,XMMWORD PTR [rdi+0x10]
     2a3:	c5 c5 ef 3e          	vpxor  ymm7,ymm7,YMMWORD PTR [rsi]
     2a7:	c5 fd ef 46 40       	vpxor  ymm0,ymm0,YMMWORD PTR [rsi+0x40]
     2ac:	c4 62 7d 5a 47 20    	vbroadcasti128 ymm8,XMMWORD PTR [rdi+0x20]
     2b2:	c4 e2 7d 5a 4f 30    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x30]
     2b8:	c4 63 45 44 e0 11    	vpclmulhqhqdq ymm12,ymm7,ymm0
     2be:	c5 f5 ef 8e c0 00 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0xc0]
     2c5:	00 
     2c6:	c5 3d ef 86 80 00 00 	vpxor  ymm8,ymm8,YMMWORD PTR [rsi+0x80]
     2cd:	00 
     2ce:	c4 e3 45 44 f8 00    	vpclmullqlqdq ymm7,ymm7,ymm0
     2d4:	c4 e2 7d 5a 77 40    	vbroadcasti128 ymm6,XMMWORD PTR [rdi+0x40]
     2da:	c5 cd ef b6 00 01 00 	vpxor  ymm6,ymm6,YMMWORD PTR [rsi+0x100]
     2e1:	00 
     2e2:	c4 e3 3d 44 c1 11    	vpclmulhqhqdq ymm0,ymm8,ymm1
     2e8:	c4 e2 7d 5a 6f 60    	vbroadcasti128 ymm5,XMMWORD PTR [rdi+0x60]
     2ee:	c5 d5 ef ae 80 01 00 	vpxor  ymm5,ymm5,YMMWORD PTR [rsi+0x180]
     2f5:	00 
     2f6:	c4 63 3d 44 c1 00    	vpclmullqlqdq ymm8,ymm8,ymm1
     2fc:	c4 e2 7d 5a 4f 50    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x50]
     302:	c5 f5 ef 8e 40 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x140]
     309:	00 
     30a:	c4 e2 7d 5a 97 80 00 	vbroadcasti128 ymm2,XMMWORD PTR [rdi+0x80]
     311:	00 00 
     313:	c5 ed ef 96 00 02 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rsi+0x200]
     31a:	00 
     31b:	c4 63 4d 44 d1 11    	vpclmulhqhqdq ymm10,ymm6,ymm1
     321:	c4 e3 4d 44 f1 00    	vpclmullqlqdq ymm6,ymm6,ymm1
     327:	c4 e2 7d 5a 4f 70    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x70]
     32d:	c5 f5 ef 8e c0 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x1c0]
     334:	00 
     335:	c5 1d ef e7          	vpxor  ymm12,ymm12,ymm7
     339:	c4 63 55 44 f9 11    	vpclmulhqhqdq ymm15,ymm5,ymm1
     33f:	c5 fd 7f 44 24 e0    	vmovdqa YMMWORD PTR [rsp-0x20],ymm0
     345:	c4 e3 55 44 e9 00    	vpclmullqlqdq ymm5,ymm5,ymm1
     34b:	c4 e2 7d 5a 8f 90 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x90]
     352:	00 00 
     354:	c5 f5 ef 8e 40 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x240]
     35b:	00 
     35c:	c4 e2 7d 5a a7 a0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xa0]
     363:	00 00 
     365:	c5 dd ef a6 80 02 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x280]
     36c:	00 
     36d:	c4 63 6d 44 f1 11    	vpclmulhqhqdq ymm14,ymm2,ymm1
     373:	c4 e2 7d 5a 9f c0 00 	vbroadcasti128 ymm3,XMMWORD PTR [rdi+0xc0]
     37a:	00 00 
     37c:	c5 e5 ef 9e 00 03 00 	vpxor  ymm3,ymm3,YMMWORD PTR [rsi+0x300]
     383:	00 
     384:	c4 e3 6d 44 d1 00    	vpclmullqlqdq ymm2,ymm2,ymm1
     38a:	c5 2d ef d6          	vpxor  ymm10,ymm10,ymm6
     38e:	c4 e2 7d 5a 8f b0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xb0]
     395:	00 00 
     397:	c5 f5 ef 8e c0 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x2c0]
     39e:	00 
     39f:	c4 62 7d 5a 9f e0 00 	vbroadcasti128 ymm11,XMMWORD PTR [rdi+0xe0]
     3a6:	00 00 
     3a8:	c5 25 ef 9e 80 03 00 	vpxor  ymm11,ymm11,YMMWORD PTR [rsi+0x380]
     3af:	00 
     3b0:	c4 63 5d 44 c9 11    	vpclmulhqhqdq ymm9,ymm4,ymm1
     3b6:	c4 e3 5d 44 e1 00    	vpclmullqlqdq ymm4,ymm4,ymm1
     3bc:	c5 2d ef d5          	vpxor  ymm10,ymm10,ymm5
     3c0:	c4 e2 7d 5a 8f d0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xd0]
     3c7:	00 00 
     3c9:	c5 f5 ef 8e 40 03 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x340]
     3d0:	00 
     3d1:	c4 63 65 44 e9 11    	vpclmulhqhqdq ymm13,ymm3,ymm1
     3d7:	c4 e3 65 44 d9 00    	vpclmullqlqdq ymm3,ymm3,ymm1
     3dd:	c4 c1 6d ef d7       	vpxor  ymm2,ymm2,ymm15
     3e2:	c4 e2 7d 5a 8f f0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xf0]
     3e9:	00 00 
     3eb:	c5 f5 ef 8e c0 03 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x3c0]
     3f2:	00 
     3f3:	c4 c1 6d ef d6       	vpxor  ymm2,ymm2,ymm14
     3f8:	c4 e3 25 44 c1 11    	vpclmulhqhqdq ymm0,ymm11,ymm1
     3fe:	c4 e3 25 44 c9 00    	vpclmullqlqdq ymm1,ymm11,ymm1
     404:	c5 35 ef cc          	vpxor  ymm9,ymm9,ymm4
     408:	c5 35 ef cb          	vpxor  ymm9,ymm9,ymm3
     40c:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
     412:	c5 bd ef 44 24 e0    	vpxor  ymm0,ymm8,YMMWORD PTR [rsp-0x20]
     418:	c4 c1 75 ef cd       	vpxor  ymm1,ymm1,ymm13
     41d:	c5 f5 ef 4c 24 c0    	vpxor  ymm1,ymm1,YMMWORD PTR [rsp-0x40]
     423:	c4 c1 7d ef c4       	vpxor  ymm0,ymm0,ymm12
     428:	c4 c1 7d ef c2       	vpxor  ymm0,ymm0,ymm10
     42d:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
     431:	c4 c1 7d ef c1       	vpxor  ymm0,ymm0,ymm9
     436:	c5 fd ef c1          	vpxor  ymm0,ymm0,ymm1
     43a:	c5 fe 7f 02          	vmovdqu YMMWORD PTR [rdx],ymm0
     43e:	c4 e2 7d 5a 1f       	vbroadcasti128 ymm3,XMMWORD PTR [rdi]
     443:	c4 e2 7d 5a 47 10    	vbroadcasti128 ymm0,XMMWORD PTR [rdi+0x10]
     449:	c5 e5 ef 5e 20       	vpxor  ymm3,ymm3,YMMWORD PTR [rsi+0x20]
     44e:	c5 fd ef 46 60       	vpxor  ymm0,ymm0,YMMWORD PTR [rsi+0x60]
     453:	c4 63 65 44 f0 11    	vpclmulhqhqdq ymm14,ymm3,ymm0
     459:	c4 e3 65 44 d8 00    	vpclmullqlqdq ymm3,ymm3,ymm0
     45f:	c4 e2 7d 5a 47 20    	vbroadcasti128 ymm0,XMMWORD PTR [rdi+0x20]
     465:	c5 fd ef 86 a0 00 00 	vpxor  ymm0,ymm0,YMMWORD PTR [rsi+0xa0]
     46c:	00 
     46d:	c4 e2 7d 5a 4f 30    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x30]
     473:	c4 e2 7d 5a 57 40    	vbroadcasti128 ymm2,XMMWORD PTR [rdi+0x40]
     479:	c5 f5 ef 8e e0 00 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0xe0]
     480:	00 
     481:	c4 e2 7d 5a 7f 60    	vbroadcasti128 ymm7,XMMWORD PTR [rdi+0x60]
     487:	c5 ed ef 96 20 01 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rsi+0x120]
     48e:	00 
     48f:	c5 c5 ef be a0 01 00 	vpxor  ymm7,ymm7,YMMWORD PTR [rsi+0x1a0]
     496:	00 
     497:	c4 63 7d 44 f9 11    	vpclmulhqhqdq ymm15,ymm0,ymm1
     49d:	c4 e2 7d 5a a7 90 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0x90]
     4a4:	00 00 
     4a6:	c5 dd ef a6 60 02 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x260]
     4ad:	00 
     4ae:	c4 e3 7d 44 c1 00    	vpclmullqlqdq ymm0,ymm0,ymm1
     4b4:	c4 e2 7d 5a 4f 50    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x50]
     4ba:	c5 f5 ef 8e 60 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x160]
     4c1:	00 
     4c2:	c4 e2 7d 5a b7 a0 00 	vbroadcasti128 ymm6,XMMWORD PTR [rdi+0xa0]
     4c9:	00 00 
     4cb:	c5 cd ef b6 a0 02 00 	vpxor  ymm6,ymm6,YMMWORD PTR [rsi+0x2a0]
     4d2:	00 
     4d3:	c4 c1 65 ef de       	vpxor  ymm3,ymm3,ymm14
     4d8:	c4 63 6d 44 e9 11    	vpclmulhqhqdq ymm13,ymm2,ymm1
     4de:	c4 e2 7d 5a af c0 00 	vbroadcasti128 ymm5,XMMWORD PTR [rdi+0xc0]
     4e5:	00 00 
     4e7:	c5 d5 ef ae 20 03 00 	vpxor  ymm5,ymm5,YMMWORD PTR [rsi+0x320]
     4ee:	00 
     4ef:	c4 e3 6d 44 d1 00    	vpclmullqlqdq ymm2,ymm2,ymm1
     4f5:	c4 e2 7d 5a 4f 70    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x70]
     4fb:	c5 f5 ef 8e e0 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x1e0]
     502:	00 
     503:	c4 63 45 44 e1 11    	vpclmulhqhqdq ymm12,ymm7,ymm1
     509:	c4 e3 45 44 f9 00    	vpclmullqlqdq ymm7,ymm7,ymm1
     50f:	c5 fd 7f 44 24 e0    	vmovdqa YMMWORD PTR [rsp-0x20],ymm0
     515:	c4 e2 7d 5a 8f 80 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x80]
     51c:	00 00 
     51e:	c5 f5 ef 8e 20 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x220]
     525:	00 
     526:	c4 63 75 44 dc 11    	vpclmulhqhqdq ymm11,ymm1,ymm4
     52c:	c4 e3 75 44 cc 00    	vpclmullqlqdq ymm1,ymm1,ymm4
     532:	c4 c1 6d ef d5       	vpxor  ymm2,ymm2,ymm13
     537:	c4 e2 7d 5a a7 b0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xb0]
     53e:	00 00 
     540:	c5 dd ef a6 e0 02 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x2e0]
     547:	00 
     548:	c4 63 4d 44 cc 11    	vpclmulhqhqdq ymm9,ymm6,ymm4
     54e:	c4 e3 4d 44 f4 00    	vpclmullqlqdq ymm6,ymm6,ymm4
     554:	c5 ed ef d7          	vpxor  ymm2,ymm2,ymm7
     558:	c4 e2 7d 5a a7 d0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xd0]
     55f:	00 00 
     561:	c5 dd ef a6 60 03 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x360]
     568:	00 
     569:	c4 62 7d 5a 97 e0 00 	vbroadcasti128 ymm10,XMMWORD PTR [rdi+0xe0]
     570:	00 00 
     572:	c5 2d ef 96 a0 03 00 	vpxor  ymm10,ymm10,YMMWORD PTR [rsi+0x3a0]
     579:	00 
     57a:	c4 63 55 44 c4 11    	vpclmulhqhqdq ymm8,ymm5,ymm4
     580:	c4 e3 55 44 ec 00    	vpclmullqlqdq ymm5,ymm5,ymm4
     586:	c4 c1 75 ef cc       	vpxor  ymm1,ymm1,ymm12
     58b:	c4 e2 7d 5a a7 f0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xf0]
     592:	00 00 
     594:	c5 dd ef a6 e0 03 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x3e0]
     59b:	00 
     59c:	c4 c1 75 ef cb       	vpxor  ymm1,ymm1,ymm11
     5a1:	c4 e3 2d 44 c4 11    	vpclmulhqhqdq ymm0,ymm10,ymm4
     5a7:	c4 e3 2d 44 e4 00    	vpclmullqlqdq ymm4,ymm10,ymm4
     5ad:	c5 35 ef ce          	vpxor  ymm9,ymm9,ymm6
     5b1:	c5 35 ef cd          	vpxor  ymm9,ymm9,ymm5
     5b5:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
     5bb:	c5 85 ef 44 24 e0    	vpxor  ymm0,ymm15,YMMWORD PTR [rsp-0x20]
     5c1:	c5 3d ef c4          	vpxor  ymm8,ymm8,ymm4
     5c5:	c5 3d ef 44 24 c0    	vpxor  ymm8,ymm8,YMMWORD PTR [rsp-0x40]
     5cb:	c5 fd ef c3          	vpxor  ymm0,ymm0,ymm3
     5cf:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
     5d3:	c5 fd ef c1          	vpxor  ymm0,ymm0,ymm1
     5d7:	c4 c1 7d ef c1       	vpxor  ymm0,ymm0,ymm9
     5dc:	c4 c1 7d ef c0       	vpxor  ymm0,ymm0,ymm8
     5e1:	c5 fe 7f 42 20       	vmovdqu YMMWORD PTR [rdx+0x20],ymm0
     5e6:	c5 f8 77             	vzeroupper 
     5e9:	c9                   	leave  
     5ea:	c3                   	ret    
     5eb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

00000000000005f0 <chv3_region512>:
     5f0:	62 f2 7d 48 5a 07    	vbroadcasti32x4 zmm0,XMMWORD PTR [rdi]
     5f6:	62 f2 7d 48 5a 4f 01 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x10]
     5fd:	62 f1 7d 48 ef 06    	vpxord zmm0,zmm0,ZMMWORD PTR [rsi]
     603:	62 f1 75 48 ef 4e 01 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x40]
     60a:	62 f2 7d 48 5a 7f 02 	vbroadcasti32x4 zmm7,XMMWORD PTR [rdi+0x20]
     611:	62 f1 45 48 ef 7e 02 	vpxord zmm7,zmm7,ZMMWORD PTR [rsi+0x80]
     618:	62 73 7d 48 44 f9 11 	vpclmulhqhqdq zmm15,zmm0,zmm1
     61f:	62 f2 7d 48 5a 67 04 	vbroadcasti32x4 zmm4,XMMWORD PTR [rdi+0x40]
     626:	62 f1 5d 48 ef 66 04 	vpxord zmm4,zmm4,ZMMWORD PTR [rsi+0x100]
     62d:	62 f3 7d 48 44 c1 00 	vpclmullqlqdq zmm0,zmm0,zmm1
     634:	62 f2 7d 48 5a 4f 03 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x30]
     63b:	62 f1 75 48 ef 4e 03 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0xc0]
     642:	62 72 7d 48 5a 57 06 	vbroadcasti32x4 zmm10,XMMWORD PTR [rdi+0x60]
     649:	62 71 2d 48 ef 56 06 	vpxord zmm10,zmm10,ZMMWORD PTR [rsi+0x180]
     650:	62 73 45 48 44 f1 11 	vpclmulhqhqdq zmm14,zmm7,zmm1
     657:	62 f2 7d 48 5a 57 09 	vbroadcasti32x4 zmm2,XMMWORD PTR [rdi+0x90]
     65e:	62 f1 6d 48 ef 56 09 	vpxord zmm2,zmm2,ZMMWORD PTR [rsi+0x240]
     665:	62 f3 45 48 44 f9 00 	vpclmullqlqdq zmm7,zmm7,zmm1
     66c:	62 f2 7d 48 5a 4f 05 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x50]
     673:	62 f1 75 48 ef 4e 05 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x140]
     67a:	62 f2 7d 48 5a 6f 0c 	vbroadcasti32x4 zmm5,XMMWORD PTR [rdi+0xc0]
     681:	62 f2 7d 48 5a 77 0d 	vbroadcasti32x4 zmm6,XMMWORD PTR [rdi+0xd0]
     688:	62 73 5d 48 44 e9 11 	vpclmulhqhqdq zmm13,zmm4,zmm1
     68f:	62 f1 55 48 ef 6e 0c 	vpxord zmm5,zmm5,ZMMWORD PTR [rsi+0x300]
     696:	62 f1 4d 48 ef 76 0d 	vpxord zmm6,zmm6,ZMMWORD PTR [rsi+0x340]
     69d:	62 f3 5d 48 44 e1 00 	vpclmullqlqdq zmm4,zmm4,zmm1
     6a4:	62 f2 7d 48 5a 4f 07 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x70]
     6ab:	62 d1 7d 48 ef c7    	vpxord zmm0,zmm0,zmm15
     6b1:	62 f1 75 48 ef 4e 07 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x1c0]
     6b8:	62 73 55 48 44 c6 11 	vpclmulhqhqdq zmm8,zmm5,zmm6
     6bf:	62 f3 2d 48 44 d9 11 	vpclmulhqhqdq zmm3,zmm10,zmm1
     6c6:	62 73 2d 48 44 d1 00 	vpclmullqlqdq zmm10,zmm10,zmm1
     6cd:	62 d1 45 48 ef fe    	vpxord zmm7,zmm7,zmm14
     6d3:	62 f2 7d 48 5a 4f 08 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x80]
     6da:	62 f1 75 48 ef 4e 08 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x200]
     6e1:	62 f3 55 48 44 f6 00 	vpclmullqlqdq zmm6,zmm5,zmm6
     6e8:	62 f1 7d 48 ef c7    	vpxord zmm0,zmm0,zmm7
     6ee:	62 f2 7d 48 5a 6f 0f 	vbroadcasti32x4 zmm5,XMMWORD PTR [rdi+0xf0]
     6f5:	62 f1 55 48 ef 6e 0f 	vpxord zmm5,zmm5,ZMMWORD PTR [rsi+0x3c0]
     6fc:	62 73 75 48 44 da 11 	vpclmulhqhqdq zmm11,zmm1,zmm2
     703:	62 73 75 48 44 ca 00 	vpclmullqlqdq zmm9,zmm1,zmm2
     70a:	62 d1 5d 48 ef e5    	vpxord zmm4,zmm4,zmm13
     710:	62 f2 7d 48 5a 57 0a 	vbroadcasti32x4 zmm2,XMMWORD PTR [rdi+0xa0]
     717:	62 f1 6d 48 ef 56 0a 	vpxord zmm2,zmm2,ZMMWORD PTR [rsi+0x280]
     71e:	62 f2 7d 48 5a 4f 0b 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0xb0]
     725:	62 f1 75 48 ef 4e 0b 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x2c0]
     72c:	62 73 6d 48 44 e1 11 	vpclmulhqhqdq zmm12,zmm2,zmm1
     733:	62 d1 5d 48 ef e2    	vpxord zmm4,zmm4,zmm10
     739:	62 f3 6d 48 44 d1 00 	vpclmullqlqdq zmm2,zmm2,zmm1
     740:	62 f1 7d 48 ef c4    	vpxord zmm0,zmm0,zmm4
     746:	62 f2 7d 48 5a 4f 0e 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0xe0]
     74d:	62 f1 75 48 ef 4e 0e 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x380]
     754:	62 e3 75 48 44 c5 11 	vpclmulhqhqdq zmm16,zmm1,zmm5
     75b:	62 d1 65 48 ef d9    	vpxord zmm3,zmm3,zmm9
     761:	62 f3 75 48 44 cd 00 	vpclmullqlqdq zmm1,zmm1,zmm5
     768:	62 d1 65 48 ef db    	vpxord zmm3,zmm3,zmm11
     76e:	62 f1 7d 48 ef c3    	vpxord zmm0,zmm0,zmm3
     774:	62 d1 6d 48 ef d4    	vpxord zmm2,zmm2,zmm12
     77a:	62 f1 6d 48 ef d6    	vpxord zmm2,zmm2,zmm6
     780:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
     786:	62 f1 3d 48 ef c9    	vpxord zmm1,zmm8,zmm1
     78c:	62 b1 75 48 ef c8    	vpxord zmm1,zmm1,zmm16
     792:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
     798:	62 f1 fe 48 7f 02    	vmovdqu64 ZMMWORD PTR [rdx],zmm0
     79e:	c5 f8 77             	vzeroupper 
     7a1:	c3                   	ret    
     7a2:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
     7a9:	00 00 00 00 
     7ad:	0f 1f 00             	nop    DWORD PTR [rax]

00000000000007b0 <chv3_tail512>:
     7b0:	55                   	push   rbp
     7b1:	49 89 fb             	mov    r11,rdi
     7b4:	49 89 f1             	mov    r9,rsi
     7b7:	49 89 d0             	mov    r8,rdx
     7ba:	48 89 e5             	mov    rbp,rsp
     7bd:	41 56                	push   r14
     7bf:	49 89 ce             	mov    r14,rcx
     7c2:	41 55                	push   r13
     7c4:	41 54                	push   r12
     7c6:	53                   	push   rbx
     7c7:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
     7cb:	48 83 ec 08          	sub    rsp,0x8
     7cf:	48 83 fa 30          	cmp    rdx,0x30
     7d3:	0f 87 97 02 00 00    	ja     a70 <chv3_tail512+0x2c0>
     7d9:	48 85 d2             	test   rdx,rdx
     7dc:	0f 84 b6 00 00 00    	je     898 <chv3_tail512+0xe8>
     7e2:	48 8d 5a ff          	lea    rbx,[rdx-0x1]
     7e6:	48 c1 eb 04          	shr    rbx,0x4
     7ea:	83 c3 01             	add    ebx,0x1
     7ed:	45 31 d2             	xor    r10d,r10d
     7f0:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
     7f4:	4c 8d 64 24 88       	lea    r12,[rsp-0x78]
     7f9:	41 bd 01 00 00 00    	mov    r13d,0x1
     7ff:	90                   	nop
     800:	b8 80 00 00 00       	mov    eax,0x80
     805:	49 39 c0             	cmp    r8,rax
     808:	49 0f 46 c0          	cmovbe rax,r8
     80c:	49 83 f8 7f          	cmp    r8,0x7f
     810:	0f 86 ca 01 00 00    	jbe    9e0 <chv3_tail512+0x230>
     816:	62 d1 fe 48 6f 09    	vmovdqu64 zmm1,ZMMWORD PTR [r9]
     81c:	62 d1 fe 48 6f 59 01 	vmovdqu64 zmm3,ZMMWORD PTR [r9+0x40]
     823:	44 89 d2             	mov    edx,r10d
     826:	62 d2 7d 48 5a 04 d3 	vbroadcasti32x4 zmm0,XMMWORD PTR [r11+rdx*8]
     82d:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
     833:	62 d2 7d 48 5a 4c d3 	vbroadcasti32x4 zmm1,XMMWORD PTR [r11+rdx*8+0x10]
     83a:	01 
     83b:	62 f1 75 48 ef cb    	vpxord zmm1,zmm1,zmm3
     841:	49 83 f8 3f          	cmp    r8,0x3f
     845:	0f 87 65 01 00 00    	ja     9b0 <chv3_tail512+0x200>
     84b:	48 8d 48 07          	lea    rcx,[rax+0x7]
     84f:	44 89 ea             	mov    edx,r13d
     852:	49 01 c1             	add    r9,rax
     855:	41 83 c2 04          	add    r10d,0x4
     859:	48 c1 e9 03          	shr    rcx,0x3
     85d:	d3 e2                	shl    edx,cl
     85f:	8d 72 ff             	lea    esi,[rdx-0x1]
     862:	c5 f8 92 ce          	kmovw  k1,esi
     866:	62 f1 fd c9 6f d8    	vmovdqa64 zmm3{k1}{z},zmm0
     86c:	62 f1 fd c9 6f c1    	vmovdqa64 zmm0{k1}{z},zmm1
     872:	62 f3 65 48 44 c8 11 	vpclmulhqhqdq zmm1,zmm3,zmm0
     879:	62 f3 65 48 44 d8 00 	vpclmullqlqdq zmm3,zmm3,zmm0
     880:	62 f3 e5 48 25 d1 96 	vpternlogq zmm2,zmm3,zmm1,0x96
     887:	49 29 c0             	sub    r8,rax
     88a:	0f 85 70 ff ff ff    	jne    800 <chv3_tail512+0x50>
     890:	eb 0f                	jmp    8a1 <chv3_tail512+0xf1>
     892:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
     898:	bb 01 00 00 00       	mov    ebx,0x1
     89d:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
     8a1:	c4 c1 7a 7e 9c db 00 	vmovq  xmm3,QWORD PTR [r11+rbx*8+0x100]
     8a8:	01 00 00 
     8ab:	31 d2                	xor    edx,edx
     8ad:	8d 43 ff             	lea    eax,[rbx-0x1]
     8b0:	85 db                	test   ebx,ebx
     8b2:	48 0f 44 c2          	cmove  rax,rdx
     8b6:	49 8d 84 c3 00 01 00 	lea    rax,[r11+rax*8+0x100]
     8bd:	00 
     8be:	c5 fa 6f 20          	vmovdqu xmm4,XMMWORD PTR [rax]
     8c2:	c5 d9 c6 40 40 02    	vshufpd xmm0,xmm4,XMMWORD PTR [rax+0x40],0x2
     8c8:	b8 02 00 00 00       	mov    eax,0x2
     8cd:	c5 f9 7f 44 24 88    	vmovdqa XMMWORD PTR [rsp-0x78],xmm0
     8d3:	39 c3                	cmp    ebx,eax
     8d5:	0f 43 c3             	cmovae eax,ebx
     8d8:	83 e8 02             	sub    eax,0x2
     8db:	49 8d 84 c3 00 01 00 	lea    rax,[r11+rax*8+0x100]
     8e2:	00 
     8e3:	c5 fa 6f 28          	vmovdqu xmm5,XMMWORD PTR [rax]
     8e7:	c5 d1 c6 40 40 02    	vshufpd xmm0,xmm5,XMMWORD PTR [rax+0x40],0x2
     8ed:	b8 03 00 00 00       	mov    eax,0x3
     8f2:	c5 f9 7f 44 24 98    	vmovdqa XMMWORD PTR [rsp-0x68],xmm0
     8f8:	39 c3                	cmp    ebx,eax
     8fa:	0f 43 c3             	cmovae eax,ebx
     8fd:	83 e8 03             	sub    eax,0x3
     900:	49 8d 84 c3 00 01 00 	lea    rax,[r11+rax*8+0x100]
     907:	00 
     908:	c5 fa 6f 30          	vmovdqu xmm6,XMMWORD PTR [rax]
     90c:	c5 c9 c6 40 40 02    	vshufpd xmm0,xmm6,XMMWORD PTR [rax+0x40],0x2
     912:	b8 04 00 00 00       	mov    eax,0x4
     917:	c5 f9 7f 44 24 a8    	vmovdqa XMMWORD PTR [rsp-0x58],xmm0
     91d:	39 c3                	cmp    ebx,eax
     91f:	0f 43 c3             	cmovae eax,ebx
     922:	83 e8 04             	sub    eax,0x4
     925:	49 8d 84 c3 00 01 00 	lea    rax,[r11+rax*8+0x100]
     92c:	00 
     92d:	c5 fa 6f 38          	vmovdqu xmm7,XMMWORD PTR [rax]
     931:	c5 c1 c6 40 40 02    	vshufpd xmm0,xmm7,XMMWORD PTR [rax+0x40],0x2
     937:	c5 f9 7f 44 24 b8    	vmovdqa XMMWORD PTR [rsp-0x48],xmm0
     93d:	62 f3 6d 48 44 84 24 	vpclmulhqhqdq zmm0,zmm2,ZMMWORD PTR [rsp-0x78]
     944:	88 ff ff ff 11 
     949:	62 f3 6d 48 44 94 24 	vpclmullqlqdq zmm2,zmm2,ZMMWORD PTR [rsp-0x78]
     950:	88 ff ff ff 00 
     955:	62 f1 6d 48 ef d0    	vpxord zmm2,zmm2,zmm0
     95b:	62 f3 fd 48 3b d0 01 	vextracti64x4 ymm0,zmm2,0x1
     962:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
     966:	c4 c1 f9 6e d6       	vmovq  xmm2,r14
     96b:	c4 e3 7d 39 c1 01    	vextracti128 xmm1,ymm0,0x1
     971:	c4 e3 69 44 d3 00    	vpclmullqlqdq xmm2,xmm2,xmm3
     977:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
     97b:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
     97f:	c5 fb 12 15 00 00 00 	vmovddup xmm2,QWORD PTR [rip+0x0]        # 987 <chv3_tail512+0x1d7>
     986:	00 
     987:	c4 e3 71 44 c2 11    	vpclmulhqhqdq xmm0,xmm1,xmm2
     98d:	c4 e3 79 44 d2 11    	vpclmulhqhqdq xmm2,xmm0,xmm2
     993:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
     997:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
     99b:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
     9a0:	c5 f8 77             	vzeroupper 
     9a3:	48 8d 65 e0          	lea    rsp,[rbp-0x20]
     9a7:	5b                   	pop    rbx
     9a8:	41 5c                	pop    r12
     9aa:	41 5d                	pop    r13
     9ac:	41 5e                	pop    r14
     9ae:	5d                   	pop    rbp
     9af:	c3                   	ret    
     9b0:	62 f3 7d 48 44 d9 11 	vpclmulhqhqdq zmm3,zmm0,zmm1
     9b7:	49 01 c1             	add    r9,rax
     9ba:	41 83 c2 04          	add    r10d,0x4
     9be:	62 f3 7d 48 44 c1 00 	vpclmullqlqdq zmm0,zmm0,zmm1
     9c5:	62 f3 fd 48 25 d3 96 	vpternlogq zmm2,zmm0,zmm3,0x96
     9cc:	49 29 c0             	sub    r8,rax
     9cf:	0f 85 2b fe ff ff    	jne    800 <chv3_tail512+0x50>
     9d5:	e9 c7 fe ff ff       	jmp    8a1 <chv3_tail512+0xf1>
     9da:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
     9e0:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
     9e4:	4c 89 e7             	mov    rdi,r12
     9e7:	4c 89 ce             	mov    rsi,r9
     9ea:	c5 f9 7f 44 24 88    	vmovdqa XMMWORD PTR [rsp-0x78],xmm0
     9f0:	c5 f9 7f 44 24 98    	vmovdqa XMMWORD PTR [rsp-0x68],xmm0
     9f6:	c5 f9 7f 44 24 a8    	vmovdqa XMMWORD PTR [rsp-0x58],xmm0
     9fc:	c5 f9 7f 44 24 b8    	vmovdqa XMMWORD PTR [rsp-0x48],xmm0
     a02:	c5 f9 7f 44 24 c8    	vmovdqa XMMWORD PTR [rsp-0x38],xmm0
     a08:	c5 f9 7f 44 24 d8    	vmovdqa XMMWORD PTR [rsp-0x28],xmm0
     a0e:	c5 f9 7f 44 24 e8    	vmovdqa XMMWORD PTR [rsp-0x18],xmm0
     a14:	c5 f9 7f 44 24 f8    	vmovdqa XMMWORD PTR [rsp-0x8],xmm0
     a1a:	83 f8 08             	cmp    eax,0x8
     a1d:	72 08                	jb     a27 <chv3_tail512+0x277>
     a1f:	89 c1                	mov    ecx,eax
     a21:	c1 e9 03             	shr    ecx,0x3
     a24:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
     a27:	31 d2                	xor    edx,edx
     a29:	a8 04                	test   al,0x4
     a2b:	74 09                	je     a36 <chv3_tail512+0x286>
     a2d:	8b 16                	mov    edx,DWORD PTR [rsi]
     a2f:	89 17                	mov    DWORD PTR [rdi],edx
     a31:	ba 04 00 00 00       	mov    edx,0x4
     a36:	a8 02                	test   al,0x2
     a38:	74 0c                	je     a46 <chv3_tail512+0x296>
     a3a:	0f b7 0c 16          	movzx  ecx,WORD PTR [rsi+rdx*1]
     a3e:	66 89 0c 17          	mov    WORD PTR [rdi+rdx*1],cx
     a42:	48 83 c2 02          	add    rdx,0x2
     a46:	a8 01                	test   al,0x1
     a48:	74 07                	je     a51 <chv3_tail512+0x2a1>
     a4a:	0f b6 0c 16          	movzx  ecx,BYTE PTR [rsi+rdx*1]
     a4e:	88 0c 17             	mov    BYTE PTR [rdi+rdx*1],cl
     a51:	62 f1 fd 48 6f 8c 24 	vmovdqa64 zmm1,ZMMWORD PTR [rsp-0x78]
     a58:	88 ff ff ff 
     a5c:	62 f1 fd 48 6f 9c 24 	vmovdqa64 zmm3,ZMMWORD PTR [rsp-0x38]
     a63:	c8 ff ff ff 
     a67:	e9 b7 fd ff ff       	jmp    823 <chv3_tail512+0x73>
     a6c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
     a70:	bb 04 00 00 00       	mov    ebx,0x4
     a75:	e9 73 fd ff ff       	jmp    7ed <chv3_tail512+0x3d>
     a7a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000000a80 <chv3_bulk512>:
     a80:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
     a84:	c4 e1 f9 6e c9       	vmovq  xmm1,rcx
     a89:	c5 fa 6f bf 20 01 00 	vmovdqu xmm7,XMMWORD PTR [rdi+0x120]
     a90:	00 
     a91:	c5 d9 ef e4          	vpxor  xmm4,xmm4,xmm4
     a95:	c4 e3 7d 38 c1 01    	vinserti128 ymm0,ymm0,xmm1,0x1
     a9b:	62 e2 7d 48 5a 37    	vbroadcasti32x4 zmm22,XMMWORD PTR [rdi]
     aa1:	c5 c1 c6 b7 60 01 00 	vshufpd xmm6,xmm7,XMMWORD PTR [rdi+0x160],0x2
     aa8:	00 02 
     aaa:	62 e2 7d 48 5a 6f 01 	vbroadcasti32x4 zmm21,XMMWORD PTR [rdi+0x10]
     ab1:	62 e2 7d 48 5a 67 02 	vbroadcasti32x4 zmm20,XMMWORD PTR [rdi+0x20]
     ab8:	62 e2 7d 48 5a 5f 03 	vbroadcasti32x4 zmm19,XMMWORD PTR [rdi+0x30]
     abf:	62 f3 dd 48 3a e0 01 	vinserti64x4 zmm4,zmm4,ymm0,0x1
     ac6:	62 f3 4d 48 43 f6 00 	vshufi32x4 zmm6,zmm6,zmm6,0x0
     acd:	62 e2 7d 48 5a 57 04 	vbroadcasti32x4 zmm18,XMMWORD PTR [rdi+0x40]
     ad4:	62 e2 7d 48 5a 4f 05 	vbroadcasti32x4 zmm17,XMMWORD PTR [rdi+0x50]
     adb:	62 e2 7d 48 5a 47 06 	vbroadcasti32x4 zmm16,XMMWORD PTR [rdi+0x60]
     ae2:	62 72 7d 48 5a 7f 07 	vbroadcasti32x4 zmm15,XMMWORD PTR [rdi+0x70]
     ae9:	62 72 7d 48 5a 77 08 	vbroadcasti32x4 zmm14,XMMWORD PTR [rdi+0x80]
     af0:	62 72 7d 48 5a 6f 09 	vbroadcasti32x4 zmm13,XMMWORD PTR [rdi+0x90]
     af7:	62 72 7d 48 5a 67 0a 	vbroadcasti32x4 zmm12,XMMWORD PTR [rdi+0xa0]
     afe:	62 72 7d 48 5a 5f 0b 	vbroadcasti32x4 zmm11,XMMWORD PTR [rdi+0xb0]
     b05:	62 72 7d 48 5a 57 0c 	vbroadcasti32x4 zmm10,XMMWORD PTR [rdi+0xc0]
     b0c:	62 72 7d 48 5a 4f 0d 	vbroadcasti32x4 zmm9,XMMWORD PTR [rdi+0xd0]
     b13:	62 72 7d 48 5a 47 0e 	vbroadcasti32x4 zmm8,XMMWORD PTR [rdi+0xe0]
     b1a:	62 f2 7d 48 5a 7f 0f 	vbroadcasti32x4 zmm7,XMMWORD PTR [rdi+0xf0]
     b21:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
     b28:	62 f1 55 40 ef 46 01 	vpxord zmm0,zmm21,ZMMWORD PTR [rsi+0x40]
     b2f:	62 f1 4d 40 ef 0e    	vpxord zmm1,zmm22,ZMMWORD PTR [rsi]
     b35:	48 81 c6 00 04 00 00 	add    rsi,0x400
     b3c:	62 f1 65 40 ef 56 f3 	vpxord zmm2,zmm19,ZMMWORD PTR [rsi-0x340]
     b43:	62 f1 0d 48 ef 6e f8 	vpxord zmm5,zmm14,ZMMWORD PTR [rsi-0x200]
     b4a:	62 63 75 48 44 e0 11 	vpclmulhqhqdq zmm28,zmm1,zmm0
     b51:	62 f1 6d 40 ef 5e f4 	vpxord zmm3,zmm18,ZMMWORD PTR [rsi-0x300]
     b58:	62 f3 75 48 44 c8 00 	vpclmullqlqdq zmm1,zmm1,zmm0
     b5f:	62 f1 5d 40 ef 46 f2 	vpxord zmm0,zmm20,ZMMWORD PTR [rsi-0x380]
     b66:	62 63 7d 48 44 d2 11 	vpclmulhqhqdq zmm26,zmm0,zmm2
     b6d:	62 63 7d 48 44 c2 00 	vpclmullqlqdq zmm24,zmm0,zmm2
     b74:	62 f1 75 40 ef 46 f5 	vpxord zmm0,zmm17,ZMMWORD PTR [rsi-0x2c0]
     b7b:	62 f1 7d 40 ef 56 f6 	vpxord zmm2,zmm16,ZMMWORD PTR [rsi-0x280]
     b82:	62 63 65 48 44 c8 11 	vpclmulhqhqdq zmm25,zmm3,zmm0
     b89:	62 f3 65 48 44 d8 00 	vpclmullqlqdq zmm3,zmm3,zmm0
     b90:	62 f1 05 48 ef 46 f7 	vpxord zmm0,zmm15,ZMMWORD PTR [rsi-0x240]
     b97:	62 91 75 48 ef cc    	vpxord zmm1,zmm1,zmm28
     b9d:	62 e3 6d 48 44 f8 11 	vpclmulhqhqdq zmm23,zmm2,zmm0
     ba4:	62 f3 6d 48 44 d0 00 	vpclmullqlqdq zmm2,zmm2,zmm0
     bab:	62 f1 15 48 ef 46 f9 	vpxord zmm0,zmm13,ZMMWORD PTR [rsi-0x1c0]
     bb2:	62 63 55 48 44 d8 11 	vpclmulhqhqdq zmm27,zmm5,zmm0
     bb9:	62 f3 55 48 44 e8 00 	vpclmullqlqdq zmm5,zmm5,zmm0
     bc0:	62 f1 25 48 ef 46 fb 	vpxord zmm0,zmm11,ZMMWORD PTR [rsi-0x140]
     bc7:	62 91 65 48 ef d9    	vpxord zmm3,zmm3,zmm25
     bcd:	62 b1 6d 48 ef d7    	vpxord zmm2,zmm2,zmm23
     bd3:	62 93 d5 48 25 cb 96 	vpternlogq zmm1,zmm5,zmm27,0x96
     bda:	62 f1 1d 48 ef 6e fa 	vpxord zmm5,zmm12,ZMMWORD PTR [rsi-0x180]
     be1:	62 63 55 48 44 d8 11 	vpclmulhqhqdq zmm27,zmm5,zmm0
     be8:	62 f3 55 48 44 e8 00 	vpclmullqlqdq zmm5,zmm5,zmm0
     bef:	62 91 3d 40 ef c2    	vpxord zmm0,zmm24,zmm26
     bf5:	62 61 35 48 ef 46 fd 	vpxord zmm24,zmm9,ZMMWORD PTR [rsi-0xc0]
     bfc:	62 93 d5 48 25 c3 96 	vpternlogq zmm0,zmm5,zmm27,0x96
     c03:	62 f1 2d 48 ef 6e fc 	vpxord zmm5,zmm10,ZMMWORD PTR [rsi-0x100]
     c0a:	62 03 55 48 44 d0 11 	vpclmulhqhqdq zmm26,zmm5,zmm24
     c11:	62 93 55 48 44 e8 00 	vpclmullqlqdq zmm5,zmm5,zmm24
     c18:	62 61 45 48 ef 46 ff 	vpxord zmm24,zmm7,ZMMWORD PTR [rsi-0x40]
     c1f:	62 93 d5 48 25 da 96 	vpternlogq zmm3,zmm5,zmm26,0x96
     c26:	62 f1 3d 48 ef 6e fe 	vpxord zmm5,zmm8,ZMMWORD PTR [rsi-0x80]
     c2d:	62 f3 fd 48 25 cb 96 	vpternlogq zmm1,zmm0,zmm3,0x96
     c34:	62 03 55 48 44 c8 11 	vpclmulhqhqdq zmm25,zmm5,zmm24
     c3b:	62 93 55 48 44 e8 00 	vpclmullqlqdq zmm5,zmm5,zmm24
     c42:	62 f3 5d 48 44 de 11 	vpclmulhqhqdq zmm3,zmm4,zmm6
     c49:	62 f3 5d 48 44 e6 00 	vpclmullqlqdq zmm4,zmm4,zmm6
     c50:	62 93 d5 48 25 d1 96 	vpternlogq zmm2,zmm5,zmm25,0x96
     c57:	62 f1 75 48 ef c2    	vpxord zmm0,zmm1,zmm2
     c5d:	62 f3 e5 48 25 e0 96 	vpternlogq zmm4,zmm3,zmm0,0x96
     c64:	48 83 ea 01          	sub    rdx,0x1
     c68:	0f 85 ba fe ff ff    	jne    b28 <chv3_bulk512+0xa8>
     c6e:	c5 fa 7e bf 00 01 00 	vmovq  xmm7,QWORD PTR [rdi+0x100]
     c75:	00 
     c76:	c4 e3 c1 22 87 48 01 	vpinsrq xmm0,xmm7,QWORD PTR [rdi+0x148],0x1
     c7d:	00 00 01 
     c80:	c5 fa 7e bf 08 01 00 	vmovq  xmm7,QWORD PTR [rdi+0x108]
     c87:	00 
     c88:	c4 e3 c1 22 8f 50 01 	vpinsrq xmm1,xmm7,QWORD PTR [rdi+0x150],0x1
     c8f:	00 00 01 
     c92:	c5 fa 7e bf 10 01 00 	vmovq  xmm7,QWORD PTR [rdi+0x110]
     c99:	00 
     c9a:	c4 e3 c1 22 97 58 01 	vpinsrq xmm2,xmm7,QWORD PTR [rdi+0x158],0x1
     ca1:	00 00 01 
     ca4:	c4 e3 75 38 c8 01    	vinserti128 ymm1,ymm1,xmm0,0x1
     caa:	c5 fa 7e bf 18 01 00 	vmovq  xmm7,QWORD PTR [rdi+0x118]
     cb1:	00 
     cb2:	c4 e3 c1 22 87 60 01 	vpinsrq xmm0,xmm7,QWORD PTR [rdi+0x160],0x1
     cb9:	00 00 01 
     cbc:	c4 e3 7d 38 c2 01    	vinserti128 ymm0,ymm0,xmm2,0x1
     cc2:	62 f3 fd 48 3a c1 01 	vinserti64x4 zmm0,zmm0,ymm1,0x1
     cc9:	62 f3 5d 48 44 c8 11 	vpclmulhqhqdq zmm1,zmm4,zmm0
     cd0:	62 f3 5d 48 44 e0 00 	vpclmullqlqdq zmm4,zmm4,zmm0
     cd7:	62 f1 5d 48 ef e1    	vpxord zmm4,zmm4,zmm1
     cdd:	62 f3 fd 48 3b e1 01 	vextracti64x4 ymm1,zmm4,0x1
     ce4:	c5 f5 ef cc          	vpxor  ymm1,ymm1,ymm4
     ce8:	c4 e3 7d 39 c8 01    	vextracti128 xmm0,ymm1,0x1
     cee:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
     cf2:	c4 e3 f9 16 c1 01    	vpextrq rcx,xmm0,0x1
     cf8:	48 89 ca             	mov    rdx,rcx
     cfb:	48 89 c8             	mov    rax,rcx
     cfe:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
     d02:	48 c1 e8 3d          	shr    rax,0x3d
     d06:	48 c1 ea 3f          	shr    rdx,0x3f
     d0a:	48 31 c2             	xor    rdx,rax
     d0d:	48 89 c8             	mov    rax,rcx
     d10:	48 c1 e8 3c          	shr    rax,0x3c
     d14:	48 31 c2             	xor    rdx,rax
     d17:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
     d1c:	48 31 c8             	xor    rax,rcx
     d1f:	48 31 f0             	xor    rax,rsi
     d22:	48 8d 34 cd 00 00 00 	lea    rsi,[rcx*8+0x0]
     d29:	00 
     d2a:	48 c1 e1 04          	shl    rcx,0x4
     d2e:	48 31 f0             	xor    rax,rsi
     d31:	48 31 c8             	xor    rax,rcx
     d34:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
     d38:	48 31 d0             	xor    rax,rdx
     d3b:	48 31 c8             	xor    rax,rcx
     d3e:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
     d45:	00 
     d46:	48 c1 e2 04          	shl    rdx,0x4
     d4a:	48 31 c8             	xor    rax,rcx
     d4d:	48 31 d0             	xor    rax,rdx
     d50:	c5 f8 77             	vzeroupper 
     d53:	c3                   	ret    
     d54:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
     d5b:	00 00 00 00 
     d5f:	90                   	nop

0000000000000d60 <chainhash_v3_evaluate.constprop.0>:
     d60:	41 57                	push   r15
     d62:	41 56                	push   r14
     d64:	41 55                	push   r13
     d66:	49 89 fd             	mov    r13,rdi
     d69:	41 54                	push   r12
     d6b:	55                   	push   rbp
     d6c:	53                   	push   rbx
     d6d:	48 81 ec 68 05 00 00 	sub    rsp,0x568
     d74:	48 89 74 24 20       	mov    QWORD PTR [rsp+0x20],rsi
     d79:	48 89 54 24 18       	mov    QWORD PTR [rsp+0x18],rdx
     d7e:	89 4c 24 30          	mov    DWORD PTR [rsp+0x30],ecx
     d82:	8b 15 00 00 00 00    	mov    edx,DWORD PTR [rip+0x0]        # d88 <chainhash_v3_evaluate.constprop.0+0x28>
     d88:	85 d2                	test   edx,edx
     d8a:	0f 88 ec 08 00 00    	js     167c <chainhash_v3_evaluate.constprop.0+0x91c>
     d90:	85 c9                	test   ecx,ecx
     d92:	0f 85 55 12 00 00    	jne    1fed <chainhash_v3_evaluate.constprop.0+0x128d>
     d98:	48 8d bc 24 b0 00 00 	lea    rdi,[rsp+0xb0]
     d9f:	00 
     da0:	31 c0                	xor    eax,eax
     da2:	b9 96 00 00 00       	mov    ecx,0x96
     da7:	48 89 7c 24 28       	mov    QWORD PTR [rsp+0x28],rdi
     dac:	f3 48 ab             	rep stos QWORD PTR es:[rdi],rax
     daf:	4c 89 ac 24 b0 00 00 	mov    QWORD PTR [rsp+0xb0],r13
     db6:	00 
     db7:	48 b8 04 00 00 00 01 	movabs rax,0x100000004
     dbe:	00 00 00 
     dc1:	48 89 84 24 48 01 00 	mov    QWORD PTR [rsp+0x148],rax
     dc8:	00 
     dc9:	8b 44 24 30          	mov    eax,DWORD PTR [rsp+0x30]
     dcd:	89 84 24 50 01 00 00 	mov    DWORD PTR [rsp+0x150],eax
     dd4:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
     dd9:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
     de0:	00 
     de1:	48 3d ff 03 00 00    	cmp    rax,0x3ff
     de7:	0f 86 b0 12 00 00    	jbe    209d <chainhash_v3_evaluate.constprop.0+0x133d>
     ded:	48 8b 5c 24 20       	mov    rbx,QWORD PTR [rsp+0x20]
     df2:	48 2d 00 04 00 00    	sub    rax,0x400
     df8:	48 25 00 fc ff ff    	and    rax,0xfffffffffffffc00
     dfe:	48 8d 84 03 00 04 00 	lea    rax,[rbx+rax*1+0x400]
     e05:	00 
     e06:	48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
     e0b:	48 8d 44 24 70       	lea    rax,[rsp+0x70]
     e10:	48 89 44 24 10       	mov    QWORD PTR [rsp+0x10],rax
     e15:	83 7c 24 30 03       	cmp    DWORD PTR [rsp+0x30],0x3
     e1a:	0f 84 33 01 00 00    	je     f53 <chainhash_v3_evaluate.constprop.0+0x1f3>
     e20:	83 7c 24 30 02       	cmp    DWORD PTR [rsp+0x30],0x2
     e25:	0f 84 3a 08 00 00    	je     1665 <chainhash_v3_evaluate.constprop.0+0x905>
     e2b:	83 7c 24 30 01       	cmp    DWORD PTR [rsp+0x30],0x1
     e30:	0f 84 0d 08 00 00    	je     1643 <chainhash_v3_evaluate.constprop.0+0x8e3>
     e36:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
     e3b:	66 0f ef c0          	pxor   xmm0,xmm0
     e3f:	bd 04 00 00 00       	mov    ebp,0x4
     e44:	31 db                	xor    ebx,ebx
     e46:	45 31 db             	xor    r11d,r11d
     e49:	0f 29 00             	movaps XMMWORD PTR [rax],xmm0
     e4c:	0f 29 40 10          	movaps XMMWORD PTR [rax+0x10],xmm0
     e50:	0f 29 40 20          	movaps XMMWORD PTR [rax+0x20],xmm0
     e54:	0f 29 40 30          	movaps XMMWORD PTR [rax+0x30],xmm0
     e58:	eb 6c                	jmp    ec6 <chainhash_v3_evaluate.constprop.0+0x166>
     e5a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
     e60:	b9 41 00 00 00       	mov    ecx,0x41
     e65:	49 89 f8             	mov    r8,rdi
     e68:	44 29 f9             	sub    ecx,r15d
     e6b:	49 d3 e8             	shr    r8,cl
     e6e:	4c 21 c0             	and    rax,r8
     e71:	48 31 c6             	xor    rsi,rax
     e74:	41 83 ff 40          	cmp    r15d,0x40
     e78:	0f 85 bb 00 00 00    	jne    f39 <chainhash_v3_evaluate.constprop.0+0x1d9>
     e7e:	4c 8b 44 24 08       	mov    r8,QWORD PTR [rsp+0x8]
     e83:	49 31 d3             	xor    r11,rdx
     e86:	48 31 f3             	xor    rbx,rsi
     e89:	41 83 c1 01          	add    r9d,0x1
     e8d:	49 83 c0 08          	add    r8,0x8
     e91:	4d 89 1a             	mov    QWORD PTR [r10],r11
     e94:	49 89 5a 08          	mov    QWORD PTR [r10+0x8],rbx
     e98:	41 39 e9             	cmp    r9d,ebp
     e9b:	75 4d                	jne    eea <chainhash_v3_evaluate.constprop.0+0x18a>
     e9d:	49 83 c2 10          	add    r10,0x10
     ea1:	41 83 c4 02          	add    r12d,0x2
     ea5:	4c 3b 54 24 28       	cmp    r10,QWORD PTR [rsp+0x28]
     eaa:	0f 85 48 07 00 00    	jne    15f8 <chainhash_v3_evaluate.constprop.0+0x898>
     eb0:	83 c5 04             	add    ebp,0x4
     eb3:	4c 8b 5c 24 70       	mov    r11,QWORD PTR [rsp+0x70]
     eb8:	48 8b 5c 24 78       	mov    rbx,QWORD PTR [rsp+0x78]
     ebd:	83 fd 24             	cmp    ebp,0x24
     ec0:	0f 84 9f 00 00 00    	je     f65 <chainhash_v3_evaluate.constprop.0+0x205>
     ec6:	8d 45 fe             	lea    eax,[rbp-0x2]
     ec9:	4c 8b 54 24 10       	mov    r10,QWORD PTR [rsp+0x10]
     ece:	44 8d 24 ad f0 ff ff 	lea    r12d,[rbp*4-0x10]
     ed5:	ff 
     ed6:	89 44 24 34          	mov    DWORD PTR [rsp+0x34],eax
     eda:	41 89 c1             	mov    r9d,eax
     edd:	46 8d 04 e5 00 00 00 	lea    r8d,[r12*8+0x0]
     ee4:	00 
     ee5:	4c 03 44 24 20       	add    r8,QWORD PTR [rsp+0x20]
     eea:	44 89 c8             	mov    eax,r9d
     eed:	8b 74 24 30          	mov    esi,DWORD PTR [rsp+0x30]
     ef1:	4d 8b 74 c5 00       	mov    r14,QWORD PTR [r13+rax*8+0x0]
     ef6:	41 8d 41 fe          	lea    eax,[r9-0x2]
     efa:	4d 33 70 40          	xor    r14,QWORD PTR [r8+0x40]
     efe:	49 8b 7c c5 00       	mov    rdi,QWORD PTR [r13+rax*8+0x0]
     f03:	49 33 38             	xor    rdi,QWORD PTR [r8]
     f06:	85 f6                	test   esi,esi
     f08:	75 36                	jne    f40 <chainhash_v3_evaluate.constprop.0+0x1e0>
     f0a:	4c 89 44 24 08       	mov    QWORD PTR [rsp+0x8],r8
     f0f:	31 f6                	xor    esi,esi
     f11:	31 d2                	xor    edx,edx
     f13:	31 c9                	xor    ecx,ecx
     f15:	4c 89 f0             	mov    rax,r14
     f18:	49 89 ff             	mov    r15,rdi
     f1b:	48 d3 e8             	shr    rax,cl
     f1e:	49 d3 e7             	shl    r15,cl
     f21:	83 e0 01             	and    eax,0x1
     f24:	48 f7 d8             	neg    rax
     f27:	49 21 c7             	and    r15,rax
     f2a:	4c 31 fa             	xor    rdx,r15
     f2d:	44 8d 79 01          	lea    r15d,[rcx+0x1]
     f31:	85 c9                	test   ecx,ecx
     f33:	0f 85 27 ff ff ff    	jne    e60 <chainhash_v3_evaluate.constprop.0+0x100>
     f39:	44 89 f9             	mov    ecx,r15d
     f3c:	eb d7                	jmp    f15 <chainhash_v3_evaluate.constprop.0+0x1b5>
     f3e:	66 90                	xchg   ax,ax
     f40:	4c 89 f6             	mov    rsi,r14
     f43:	e8 b8 f0 ff ff       	call   0 <chv3_hwprod>
     f48:	48 89 d6             	mov    rsi,rdx
     f4b:	48 89 c2             	mov    rdx,rax
     f4e:	e9 30 ff ff ff       	jmp    e83 <chainhash_v3_evaluate.constprop.0+0x123>
     f53:	48 8b 54 24 10       	mov    rdx,QWORD PTR [rsp+0x10]
     f58:	48 8b 74 24 20       	mov    rsi,QWORD PTR [rsp+0x20]
     f5d:	4c 89 ef             	mov    rdi,r13
     f60:	e8 8b f6 ff ff       	call   5f0 <chv3_region512>
     f65:	44 8b b4 24 48 01 00 	mov    r14d,DWORD PTR [rsp+0x148]
     f6c:	00 
     f6d:	8b 84 24 4c 01 00 00 	mov    eax,DWORD PTR [rsp+0x14c]
     f74:	4c 8b 8c 24 40 01 00 	mov    r9,QWORD PTR [rsp+0x140]
     f7b:	00 
     f7c:	4c 8b 54 24 10       	mov    r10,QWORD PTR [rsp+0x10]
     f81:	89 44 24 34          	mov    DWORD PTR [rsp+0x34],eax
     f85:	49 8d 46 28          	lea    rax,[r14+0x28]
     f89:	4b 8b 9c f5 00 01 00 	mov    rbx,QWORD PTR [r13+r14*8+0x100]
     f90:	00 
     f91:	4c 89 4c 24 50       	mov    QWORD PTR [rsp+0x50],r9
     f96:	44 89 74 24 08       	mov    DWORD PTR [rsp+0x8],r14d
     f9b:	4c 89 74 24 40       	mov    QWORD PTR [rsp+0x40],r14
     fa0:	48 89 44 24 38       	mov    QWORD PTR [rsp+0x38],rax
     fa5:	4c 89 c8             	mov    rax,r9
     fa8:	31 d2                	xor    edx,edx
     faa:	8b 4c 24 34          	mov    ecx,DWORD PTR [rsp+0x34]
     fae:	49 f7 f6             	div    r14
     fb1:	48 89 d0             	mov    rax,rdx
     fb4:	49 89 d0             	mov    r8,rdx
     fb7:	48 c1 e0 04          	shl    rax,0x4
     fbb:	48 8b 94 04 b8 00 00 	mov    rdx,QWORD PTR [rsp+rax*1+0xb8]
     fc2:	00 
     fc3:	85 c9                	test   ecx,ecx
     fc5:	0f 84 fc 04 00 00    	je     14c7 <chainhash_v3_evaluate.constprop.0+0x767>
     fcb:	48 8b ac 04 c0 00 00 	mov    rbp,QWORD PTR [rsp+rax*1+0xc0]
     fd2:	00 
     fd3:	48 8b 44 24 38       	mov    rax,QWORD PTR [rsp+0x38]
     fd8:	4d 8b 7c c5 08       	mov    r15,QWORD PTR [r13+rax*8+0x8]
     fdd:	8b 44 24 30          	mov    eax,DWORD PTR [rsp+0x30]
     fe1:	85 c0                	test   eax,eax
     fe3:	0f 85 36 06 00 00    	jne    161f <chainhash_v3_evaluate.constprop.0+0x8bf>
     fe9:	45 31 e4             	xor    r12d,r12d
     fec:	45 31 db             	xor    r11d,r11d
     fef:	31 c9                	xor    ecx,ecx
     ff1:	48 89 d8             	mov    rax,rbx
     ff4:	48 89 d6             	mov    rsi,rdx
     ff7:	48 d3 e8             	shr    rax,cl
     ffa:	48 d3 e6             	shl    rsi,cl
     ffd:	83 e0 01             	and    eax,0x1
    1000:	48 f7 d8             	neg    rax
    1003:	48 21 c6             	and    rsi,rax
    1006:	49 31 f3             	xor    r11,rsi
    1009:	8d 71 01             	lea    esi,[rcx+0x1]
    100c:	85 c9                	test   ecx,ecx
    100e:	0f 84 ac 04 00 00    	je     14c0 <chainhash_v3_evaluate.constprop.0+0x760>
    1014:	b9 41 00 00 00       	mov    ecx,0x41
    1019:	48 89 d7             	mov    rdi,rdx
    101c:	29 f1                	sub    ecx,esi
    101e:	48 d3 ef             	shr    rdi,cl
    1021:	48 21 f8             	and    rax,rdi
    1024:	49 31 c4             	xor    r12,rax
    1027:	83 fe 40             	cmp    esi,0x40
    102a:	0f 85 90 04 00 00    	jne    14c0 <chainhash_v3_evaluate.constprop.0+0x760>
    1030:	4c 89 44 24 58       	mov    QWORD PTR [rsp+0x58],r8
    1035:	31 d2                	xor    edx,edx
    1037:	31 f6                	xor    esi,esi
    1039:	31 c9                	xor    ecx,ecx
    103b:	4c 89 f8             	mov    rax,r15
    103e:	48 89 ef             	mov    rdi,rbp
    1041:	48 d3 e8             	shr    rax,cl
    1044:	48 d3 e7             	shl    rdi,cl
    1047:	83 e0 01             	and    eax,0x1
    104a:	48 f7 d8             	neg    rax
    104d:	48 21 c7             	and    rdi,rax
    1050:	48 31 fe             	xor    rsi,rdi
    1053:	8d 79 01             	lea    edi,[rcx+0x1]
    1056:	85 c9                	test   ecx,ecx
    1058:	0f 84 52 04 00 00    	je     14b0 <chainhash_v3_evaluate.constprop.0+0x750>
    105e:	b9 41 00 00 00       	mov    ecx,0x41
    1063:	49 89 e8             	mov    r8,rbp
    1066:	29 f9                	sub    ecx,edi
    1068:	49 d3 e8             	shr    r8,cl
    106b:	4c 21 c0             	and    rax,r8
    106e:	48 31 c2             	xor    rdx,rax
    1071:	83 ff 40             	cmp    edi,0x40
    1074:	0f 85 36 04 00 00    	jne    14b0 <chainhash_v3_evaluate.constprop.0+0x750>
    107a:	4c 8b 44 24 58       	mov    r8,QWORD PTR [rsp+0x58]
    107f:	4c 89 c0             	mov    rax,r8
    1082:	4c 31 de             	xor    rsi,r11
    1085:	49 33 32             	xor    rsi,QWORD PTR [r10]
    1088:	4c 31 e2             	xor    rdx,r12
    108b:	48 c1 e0 04          	shl    rax,0x4
    108f:	49 33 52 08          	xor    rdx,QWORD PTR [r10+0x8]
    1093:	48 89 b4 04 b8 00 00 	mov    QWORD PTR [rsp+rax*1+0xb8],rsi
    109a:	00 
    109b:	49 c1 e0 04          	shl    r8,0x4
    109f:	49 83 c1 01          	add    r9,0x1
    10a3:	49 83 c2 10          	add    r10,0x10
    10a7:	4a 89 94 04 c0 00 00 	mov    QWORD PTR [rsp+r8*1+0xc0],rdx
    10ae:	00 
    10af:	4c 89 8c 24 40 01 00 	mov    QWORD PTR [rsp+0x140],r9
    10b6:	00 
    10b7:	4c 3b 54 24 28       	cmp    r10,QWORD PTR [rsp+0x28]
    10bc:	0f 85 e3 fe ff ff    	jne    fa5 <chainhash_v3_evaluate.constprop.0+0x245>
    10c2:	4c 8b 64 24 50       	mov    r12,QWORD PTR [rsp+0x50]
    10c7:	4c 8b ac 24 b0 00 00 	mov    r13,QWORD PTR [rsp+0xb0]
    10ce:	00 
    10cf:	48 81 44 24 20 00 04 	add    QWORD PTR [rsp+0x20],0x400
    10d6:	00 00 
    10d8:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
    10dd:	49 83 c4 04          	add    r12,0x4
    10e1:	48 3b 44 24 48       	cmp    rax,QWORD PTR [rsp+0x48]
    10e6:	0f 85 29 fd ff ff    	jne    e15 <chainhash_v3_evaluate.constprop.0+0xb5>
    10ec:	48 81 64 24 18 ff 03 	and    QWORD PTR [rsp+0x18],0x3ff
    10f3:	00 00 
    10f5:	48 83 7c 24 18 00    	cmp    QWORD PTR [rsp+0x18],0x0
    10fb:	0f 85 05 0f 00 00    	jne    2006 <chainhash_v3_evaluate.constprop.0+0x12a6>
    1101:	48 8b 84 24 58 01 00 	mov    rax,QWORD PTR [rsp+0x158]
    1108:	00 
    1109:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    110e:	48 85 c0             	test   rax,rax
    1111:	0f 85 b2 0f 00 00    	jne    20c9 <chainhash_v3_evaluate.constprop.0+0x1369>
    1117:	4d 85 e4             	test   r12,r12
    111a:	0f 85 20 06 00 00    	jne    1740 <chainhash_v3_evaluate.constprop.0+0x9e0>
    1120:	c7 44 24 20 01 00 00 	mov    DWORD PTR [rsp+0x20],0x1
    1127:	00 
    1128:	48 8b 6c 24 18       	mov    rbp,QWORD PTR [rsp+0x18]
    112d:	48 8d 44 24 70       	lea    rax,[rsp+0x70]
    1132:	c7 44 24 38 04 00 00 	mov    DWORD PTR [rsp+0x38],0x4
    1139:	00 
    113a:	66 0f ef c0          	pxor   xmm0,xmm0
    113e:	48 89 44 24 10       	mov    QWORD PTR [rsp+0x10],rax
    1143:	48 8d 45 c0          	lea    rax,[rbp-0x40]
    1147:	4c 89 64 24 60       	mov    QWORD PTR [rsp+0x60],r12
    114c:	48 c7 44 24 48 00 00 	mov    QWORD PTR [rsp+0x48],0x0
    1153:	00 00 
    1155:	48 89 44 24 50       	mov    QWORD PTR [rsp+0x50],rax
    115a:	0f 29 44 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm0
    115f:	0f 29 84 24 80 00 00 	movaps XMMWORD PTR [rsp+0x80],xmm0
    1166:	00 
    1167:	0f 29 84 24 90 00 00 	movaps XMMWORD PTR [rsp+0x90],xmm0
    116e:	00 
    116f:	0f 29 84 24 a0 00 00 	movaps XMMWORD PTR [rsp+0xa0],xmm0
    1176:	00 
    1177:	48 8b 5c 24 48       	mov    rbx,QWORD PTR [rsp+0x48]
    117c:	48 89 d8             	mov    rax,rbx
    117f:	41 89 dc             	mov    r12d,ebx
    1182:	48 8b 5c 24 10       	mov    rbx,QWORD PTR [rsp+0x10]
    1187:	48 c1 e0 07          	shl    rax,0x7
    118b:	48 03 44 24 28       	add    rax,QWORD PTR [rsp+0x28]
    1190:	41 c1 e4 04          	shl    r12d,0x4
    1194:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    1199:	48 8d 84 24 b0 00 00 	lea    rax,[rsp+0xb0]
    11a0:	00 
    11a1:	48 89 44 24 28       	mov    QWORD PTR [rsp+0x28],rax
    11a6:	8b 44 24 38          	mov    eax,DWORD PTR [rsp+0x38]
    11aa:	83 e8 02             	sub    eax,0x2
    11ad:	89 44 24 58          	mov    DWORD PTR [rsp+0x58],eax
    11b1:	4c 8b 5c 24 50       	mov    r11,QWORD PTR [rsp+0x50]
    11b6:	42 8d 04 e5 00 00 00 	lea    eax,[r12*8+0x0]
    11bd:	00 
    11be:	49 89 e9             	mov    r9,rbp
    11c1:	44 8b 54 24 58       	mov    r10d,DWORD PTR [rsp+0x58]
    11c6:	4c 8b 44 24 18       	mov    r8,QWORD PTR [rsp+0x18]
    11cb:	49 29 c1             	sub    r9,rax
    11ce:	49 29 c3             	sub    r11,rax
    11d1:	48 89 e8             	mov    rax,rbp
    11d4:	4c 29 c8             	sub    rax,r9
    11d7:	48 39 c5             	cmp    rbp,rax
    11da:	0f 86 ae 01 00 00    	jbe    138e <chainhash_v3_evaluate.constprop.0+0x62e>
    11e0:	48 89 e8             	mov    rax,rbp
    11e3:	31 f6                	xor    esi,esi
    11e5:	4c 29 d8             	sub    rax,r11
    11e8:	48 39 c5             	cmp    rbp,rax
    11eb:	0f 86 90 00 00 00    	jbe    1281 <chainhash_v3_evaluate.constprop.0+0x521>
    11f1:	49 83 fb 07          	cmp    r11,0x7
    11f5:	0f 87 87 0c 00 00    	ja     1e82 <chainhash_v3_evaluate.constprop.0+0x1122>
    11fb:	41 0f b6 b0 f0 00 00 	movzx  esi,BYTE PTR [r8+0xf0]
    1202:	00 
    1203:	49 83 fb 01          	cmp    r11,0x1
    1207:	76 78                	jbe    1281 <chainhash_v3_evaluate.constprop.0+0x521>
    1209:	41 0f b6 80 f1 00 00 	movzx  eax,BYTE PTR [r8+0xf1]
    1210:	00 
    1211:	48 c1 e0 08          	shl    rax,0x8
    1215:	48 09 c6             	or     rsi,rax
    1218:	49 83 fb 02          	cmp    r11,0x2
    121c:	74 63                	je     1281 <chainhash_v3_evaluate.constprop.0+0x521>
    121e:	41 0f b6 80 f2 00 00 	movzx  eax,BYTE PTR [r8+0xf2]
    1225:	00 
    1226:	48 c1 e0 10          	shl    rax,0x10
    122a:	48 09 c6             	or     rsi,rax
    122d:	49 83 fb 03          	cmp    r11,0x3
    1231:	74 4e                	je     1281 <chainhash_v3_evaluate.constprop.0+0x521>
    1233:	41 0f b6 80 f3 00 00 	movzx  eax,BYTE PTR [r8+0xf3]
    123a:	00 
    123b:	48 c1 e0 18          	shl    rax,0x18
    123f:	48 09 c6             	or     rsi,rax
    1242:	49 83 fb 04          	cmp    r11,0x4
    1246:	74 39                	je     1281 <chainhash_v3_evaluate.constprop.0+0x521>
    1248:	41 0f b6 80 f4 00 00 	movzx  eax,BYTE PTR [r8+0xf4]
    124f:	00 
    1250:	48 c1 e0 20          	shl    rax,0x20
    1254:	48 09 c6             	or     rsi,rax
    1257:	49 83 fb 05          	cmp    r11,0x5
    125b:	74 24                	je     1281 <chainhash_v3_evaluate.constprop.0+0x521>
    125d:	41 0f b6 80 f5 00 00 	movzx  eax,BYTE PTR [r8+0xf5]
    1264:	00 
    1265:	48 c1 e0 28          	shl    rax,0x28
    1269:	48 09 c6             	or     rsi,rax
    126c:	49 83 fb 07          	cmp    r11,0x7
    1270:	75 0f                	jne    1281 <chainhash_v3_evaluate.constprop.0+0x521>
    1272:	41 0f b6 80 f6 00 00 	movzx  eax,BYTE PTR [r8+0xf6]
    1279:	00 
    127a:	48 c1 e0 30          	shl    rax,0x30
    127e:	48 09 c6             	or     rsi,rax
    1281:	44 89 d2             	mov    edx,r10d
    1284:	41 8d 42 fe          	lea    eax,[r10-0x2]
    1288:	49 33 74 d5 00       	xor    rsi,QWORD PTR [r13+rdx*8+0x0]
    128d:	49 83 f9 07          	cmp    r9,0x7
    1291:	0f 87 c1 0b 00 00    	ja     1e58 <chainhash_v3_evaluate.constprop.0+0x10f8>
    1297:	41 0f b6 b8 b0 00 00 	movzx  edi,BYTE PTR [r8+0xb0]
    129e:	00 
    129f:	49 83 f9 01          	cmp    r9,0x1
    12a3:	76 78                	jbe    131d <chainhash_v3_evaluate.constprop.0+0x5bd>
    12a5:	41 0f b6 90 b1 00 00 	movzx  edx,BYTE PTR [r8+0xb1]
    12ac:	00 
    12ad:	48 c1 e2 08          	shl    rdx,0x8
    12b1:	48 09 d7             	or     rdi,rdx
    12b4:	49 83 f9 02          	cmp    r9,0x2
    12b8:	74 63                	je     131d <chainhash_v3_evaluate.constprop.0+0x5bd>
    12ba:	41 0f b6 90 b2 00 00 	movzx  edx,BYTE PTR [r8+0xb2]
    12c1:	00 
    12c2:	48 c1 e2 10          	shl    rdx,0x10
    12c6:	48 09 d7             	or     rdi,rdx
    12c9:	49 83 f9 03          	cmp    r9,0x3
    12cd:	74 4e                	je     131d <chainhash_v3_evaluate.constprop.0+0x5bd>
    12cf:	41 0f b6 90 b3 00 00 	movzx  edx,BYTE PTR [r8+0xb3]
    12d6:	00 
    12d7:	48 c1 e2 18          	shl    rdx,0x18
    12db:	48 09 d7             	or     rdi,rdx
    12de:	49 83 f9 04          	cmp    r9,0x4
    12e2:	74 39                	je     131d <chainhash_v3_evaluate.constprop.0+0x5bd>
    12e4:	41 0f b6 90 b4 00 00 	movzx  edx,BYTE PTR [r8+0xb4]
    12eb:	00 
    12ec:	48 c1 e2 20          	shl    rdx,0x20
    12f0:	48 09 d7             	or     rdi,rdx
    12f3:	49 83 f9 05          	cmp    r9,0x5
    12f7:	74 24                	je     131d <chainhash_v3_evaluate.constprop.0+0x5bd>
    12f9:	41 0f b6 90 b5 00 00 	movzx  edx,BYTE PTR [r8+0xb5]
    1300:	00 
    1301:	48 c1 e2 28          	shl    rdx,0x28
    1305:	48 09 d7             	or     rdi,rdx
    1308:	49 83 f9 07          	cmp    r9,0x7
    130c:	75 0f                	jne    131d <chainhash_v3_evaluate.constprop.0+0x5bd>
    130e:	41 0f b6 90 b6 00 00 	movzx  edx,BYTE PTR [r8+0xb6]
    1315:	00 
    1316:	48 c1 e2 30          	shl    rdx,0x30
    131a:	48 09 d7             	or     rdi,rdx
    131d:	44 8b 74 24 30       	mov    r14d,DWORD PTR [rsp+0x30]
    1322:	49 33 7c c5 00       	xor    rdi,QWORD PTR [r13+rax*8+0x0]
    1327:	45 85 f6             	test   r14d,r14d
    132a:	0f 85 42 0b 00 00    	jne    1e72 <chainhash_v3_evaluate.constprop.0+0x1112>
    1330:	4c 89 44 24 68       	mov    QWORD PTR [rsp+0x68],r8
    1335:	45 31 ff             	xor    r15d,r15d
    1338:	31 d2                	xor    edx,edx
    133a:	31 c9                	xor    ecx,ecx
    133c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    1340:	48 89 f0             	mov    rax,rsi
    1343:	49 89 fe             	mov    r14,rdi
    1346:	48 d3 e8             	shr    rax,cl
    1349:	49 d3 e6             	shl    r14,cl
    134c:	83 e0 01             	and    eax,0x1
    134f:	48 f7 d8             	neg    rax
    1352:	49 21 c6             	and    r14,rax
    1355:	4c 31 f2             	xor    rdx,r14
    1358:	44 8d 71 01          	lea    r14d,[rcx+0x1]
    135c:	85 c9                	test   ecx,ecx
    135e:	0f 84 ec 0a 00 00    	je     1e50 <chainhash_v3_evaluate.constprop.0+0x10f0>
    1364:	b9 41 00 00 00       	mov    ecx,0x41
    1369:	49 89 f8             	mov    r8,rdi
    136c:	44 29 f1             	sub    ecx,r14d
    136f:	49 d3 e8             	shr    r8,cl
    1372:	4c 21 c0             	and    rax,r8
    1375:	49 31 c7             	xor    r15,rax
    1378:	41 83 fe 40          	cmp    r14d,0x40
    137c:	0f 85 ce 0a 00 00    	jne    1e50 <chainhash_v3_evaluate.constprop.0+0x10f0>
    1382:	4c 8b 44 24 68       	mov    r8,QWORD PTR [rsp+0x68]
    1387:	48 31 13             	xor    QWORD PTR [rbx],rdx
    138a:	4c 31 7b 08          	xor    QWORD PTR [rbx+0x8],r15
    138e:	49 83 c0 08          	add    r8,0x8
    1392:	49 83 e9 08          	sub    r9,0x8
    1396:	41 83 c2 01          	add    r10d,0x1
    139a:	49 83 eb 08          	sub    r11,0x8
    139e:	44 3b 54 24 38       	cmp    r10d,DWORD PTR [rsp+0x38]
    13a3:	0f 85 28 fe ff ff    	jne    11d1 <chainhash_v3_evaluate.constprop.0+0x471>
    13a9:	48 83 c3 10          	add    rbx,0x10
    13ad:	48 8d 84 24 b0 00 00 	lea    rax,[rsp+0xb0]
    13b4:	00 
    13b5:	48 83 44 24 18 10    	add    QWORD PTR [rsp+0x18],0x10
    13bb:	41 83 c4 02          	add    r12d,0x2
    13bf:	48 39 c3             	cmp    rbx,rax
    13c2:	0f 85 e9 fd ff ff    	jne    11b1 <chainhash_v3_evaluate.constprop.0+0x451>
    13c8:	48 83 44 24 48 01    	add    QWORD PTR [rsp+0x48],0x1
    13ce:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
    13d3:	41 8d 5a 04          	lea    ebx,[r10+0x4]
    13d7:	89 5c 24 38          	mov    DWORD PTR [rsp+0x38],ebx
    13db:	48 83 f8 08          	cmp    rax,0x8
    13df:	0f 85 92 fd ff ff    	jne    1177 <chainhash_v3_evaluate.constprop.0+0x417>
    13e5:	4c 8b 64 24 60       	mov    r12,QWORD PTR [rsp+0x60]
    13ea:	8b 44 24 08          	mov    eax,DWORD PTR [rsp+0x8]
    13ee:	8b 5c 24 20          	mov    ebx,DWORD PTR [rsp+0x20]
    13f2:	4d 8d 7c 24 01       	lea    r15,[r12+0x1]
    13f7:	4c 8b 74 24 10       	mov    r14,QWORD PTR [rsp+0x10]
    13fc:	41 bb 41 00 00 00    	mov    r11d,0x41
    1402:	4d 8b 94 c5 00 01 00 	mov    r10,QWORD PTR [r13+rax*8+0x100]
    1409:	00 
    140a:	48 83 c0 28          	add    rax,0x28
    140e:	8d 53 ff             	lea    edx,[rbx-0x1]
    1411:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
    1416:	4c 89 e0             	mov    rax,r12
    1419:	4a 8d 1c 3a          	lea    rbx,[rdx+r15*1]
    141d:	48 89 5c 24 10       	mov    QWORD PTR [rsp+0x10],rbx
    1422:	31 d2                	xor    edx,edx
    1424:	8b 6c 24 34          	mov    ebp,DWORD PTR [rsp+0x34]
    1428:	48 f7 74 24 40       	div    QWORD PTR [rsp+0x40]
    142d:	48 89 d0             	mov    rax,rdx
    1430:	48 89 d3             	mov    rbx,rdx
    1433:	48 c1 e0 04          	shl    rax,0x4
    1437:	48 8b bc 04 b8 00 00 	mov    rdi,QWORD PTR [rsp+rax*1+0xb8]
    143e:	00 
    143f:	85 ed                	test   ebp,ebp
    1441:	0f 84 47 0a 00 00    	je     1e8e <chainhash_v3_evaluate.constprop.0+0x112e>
    1447:	48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
    144c:	44 8b 4c 24 30       	mov    r9d,DWORD PTR [rsp+0x30]
    1451:	48 8b ac 04 c0 00 00 	mov    rbp,QWORD PTR [rsp+rax*1+0xc0]
    1458:	00 
    1459:	4d 8b 64 f5 08       	mov    r12,QWORD PTR [r13+rsi*8+0x8]
    145e:	45 85 c9             	test   r9d,r9d
    1461:	0f 85 45 0b 00 00    	jne    1fac <chainhash_v3_evaluate.constprop.0+0x124c>
    1467:	45 31 c9             	xor    r9d,r9d
    146a:	45 31 c0             	xor    r8d,r8d
    146d:	31 c9                	xor    ecx,ecx
    146f:	4c 89 d0             	mov    rax,r10
    1472:	48 89 fa             	mov    rdx,rdi
    1475:	48 d3 e8             	shr    rax,cl
    1478:	48 d3 e2             	shl    rdx,cl
    147b:	83 e0 01             	and    eax,0x1
    147e:	48 f7 d8             	neg    rax
    1481:	48 21 c2             	and    rdx,rax
    1484:	49 31 d0             	xor    r8,rdx
    1487:	8d 51 01             	lea    edx,[rcx+0x1]
    148a:	85 c9                	test   ecx,ecx
    148c:	74 1a                	je     14a8 <chainhash_v3_evaluate.constprop.0+0x748>
    148e:	44 89 d9             	mov    ecx,r11d
    1491:	48 89 fe             	mov    rsi,rdi
    1494:	29 d1                	sub    ecx,edx
    1496:	48 d3 ee             	shr    rsi,cl
    1499:	48 21 f0             	and    rax,rsi
    149c:	49 31 c1             	xor    r9,rax
    149f:	83 fa 40             	cmp    edx,0x40
    14a2:	0f 84 08 09 00 00    	je     1db0 <chainhash_v3_evaluate.constprop.0+0x1050>
    14a8:	89 d1                	mov    ecx,edx
    14aa:	eb c3                	jmp    146f <chainhash_v3_evaluate.constprop.0+0x70f>
    14ac:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    14b0:	89 f9                	mov    ecx,edi
    14b2:	e9 84 fb ff ff       	jmp    103b <chainhash_v3_evaluate.constprop.0+0x2db>
    14b7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
    14be:	00 00 
    14c0:	89 f1                	mov    ecx,esi
    14c2:	e9 2a fb ff ff       	jmp    ff1 <chainhash_v3_evaluate.constprop.0+0x291>
    14c7:	44 8b 7c 24 30       	mov    r15d,DWORD PTR [rsp+0x30]
    14cc:	45 85 ff             	test   r15d,r15d
    14cf:	0f 85 34 01 00 00    	jne    1609 <chainhash_v3_evaluate.constprop.0+0x8a9>
    14d5:	31 c0                	xor    eax,eax
    14d7:	31 ff                	xor    edi,edi
    14d9:	31 c9                	xor    ecx,ecx
    14db:	48 89 de             	mov    rsi,rbx
    14de:	49 89 d3             	mov    r11,rdx
    14e1:	48 d3 ee             	shr    rsi,cl
    14e4:	49 d3 e3             	shl    r11,cl
    14e7:	83 e6 01             	and    esi,0x1
    14ea:	48 f7 de             	neg    rsi
    14ed:	49 21 f3             	and    r11,rsi
    14f0:	4c 31 df             	xor    rdi,r11
    14f3:	44 8d 59 01          	lea    r11d,[rcx+0x1]
    14f7:	85 c9                	test   ecx,ecx
    14f9:	0f 84 f1 00 00 00    	je     15f0 <chainhash_v3_evaluate.constprop.0+0x890>
    14ff:	b9 41 00 00 00       	mov    ecx,0x41
    1504:	49 89 d7             	mov    r15,rdx
    1507:	44 29 d9             	sub    ecx,r11d
    150a:	49 d3 ef             	shr    r15,cl
    150d:	4c 89 f9             	mov    rcx,r15
    1510:	48 21 f1             	and    rcx,rsi
    1513:	48 31 c8             	xor    rax,rcx
    1516:	41 83 fb 40          	cmp    r11d,0x40
    151a:	0f 85 d0 00 00 00    	jne    15f0 <chainhash_v3_evaluate.constprop.0+0x890>
    1520:	48 89 c2             	mov    rdx,rax
    1523:	48 89 c1             	mov    rcx,rax
    1526:	49 8b 72 08          	mov    rsi,QWORD PTR [r10+0x8]
    152a:	4d 89 c4             	mov    r12,r8
    152d:	48 c1 e9 3d          	shr    rcx,0x3d
    1531:	48 c1 ea 3f          	shr    rdx,0x3f
    1535:	48 31 ca             	xor    rdx,rcx
    1538:	48 89 c1             	mov    rcx,rax
    153b:	49 89 f3             	mov    r11,rsi
    153e:	49 c1 e4 04          	shl    r12,0x4
    1542:	48 c1 e9 3c          	shr    rcx,0x3c
    1546:	49 c1 eb 3f          	shr    r11,0x3f
    154a:	48 8d 2c 36          	lea    rbp,[rsi+rsi*1]
    154e:	48 31 ca             	xor    rdx,rcx
    1551:	48 89 f1             	mov    rcx,rsi
    1554:	48 c1 e9 3d          	shr    rcx,0x3d
    1558:	4c 31 d9             	xor    rcx,r11
    155b:	49 89 f3             	mov    r11,rsi
    155e:	49 c1 eb 3c          	shr    r11,0x3c
    1562:	4c 31 d9             	xor    rcx,r11
    1565:	4d 8b 1a             	mov    r11,QWORD PTR [r10]
    1568:	49 31 f3             	xor    r11,rsi
    156b:	4c 31 dd             	xor    rbp,r11
    156e:	4c 8d 1c f5 00 00 00 	lea    r11,[rsi*8+0x0]
    1575:	00 
    1576:	48 c1 e6 04          	shl    rsi,0x4
    157a:	49 31 eb             	xor    r11,rbp
    157d:	49 31 f3             	xor    r11,rsi
    1580:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
    1584:	49 31 cb             	xor    r11,rcx
    1587:	49 31 f3             	xor    r11,rsi
    158a:	48 8d 34 cd 00 00 00 	lea    rsi,[rcx*8+0x0]
    1591:	00 
    1592:	48 c1 e1 04          	shl    rcx,0x4
    1596:	4c 31 de             	xor    rsi,r11
    1599:	48 31 f1             	xor    rcx,rsi
    159c:	48 8d 34 00          	lea    rsi,[rax+rax*1]
    15a0:	48 31 f9             	xor    rcx,rdi
    15a3:	48 31 c1             	xor    rcx,rax
    15a6:	48 31 f1             	xor    rcx,rsi
    15a9:	48 8d 34 c5 00 00 00 	lea    rsi,[rax*8+0x0]
    15b0:	00 
    15b1:	48 c1 e0 04          	shl    rax,0x4
    15b5:	48 31 f1             	xor    rcx,rsi
    15b8:	48 31 c8             	xor    rax,rcx
    15bb:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
    15bf:	48 31 d0             	xor    rax,rdx
    15c2:	48 31 c8             	xor    rax,rcx
    15c5:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
    15cc:	00 
    15cd:	48 c1 e2 04          	shl    rdx,0x4
    15d1:	48 31 c8             	xor    rax,rcx
    15d4:	48 31 d0             	xor    rax,rdx
    15d7:	31 d2                	xor    edx,edx
    15d9:	4a 89 84 24 b8 00 00 	mov    QWORD PTR [rsp+r12*1+0xb8],rax
    15e0:	00 
    15e1:	e9 b5 fa ff ff       	jmp    109b <chainhash_v3_evaluate.constprop.0+0x33b>
    15e6:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
    15ed:	00 00 00 
    15f0:	44 89 d9             	mov    ecx,r11d
    15f3:	e9 e3 fe ff ff       	jmp    14db <chainhash_v3_evaluate.constprop.0+0x77b>
    15f8:	4d 8b 1a             	mov    r11,QWORD PTR [r10]
    15fb:	49 8b 5a 08          	mov    rbx,QWORD PTR [r10+0x8]
    15ff:	44 8b 4c 24 34       	mov    r9d,DWORD PTR [rsp+0x34]
    1604:	e9 d4 f8 ff ff       	jmp    edd <chainhash_v3_evaluate.constprop.0+0x17d>
    1609:	48 89 d7             	mov    rdi,rdx
    160c:	48 89 de             	mov    rsi,rbx
    160f:	e8 ec e9 ff ff       	call   0 <chv3_hwprod>
    1614:	48 89 c7             	mov    rdi,rax
    1617:	48 89 d0             	mov    rax,rdx
    161a:	e9 01 ff ff ff       	jmp    1520 <chainhash_v3_evaluate.constprop.0+0x7c0>
    161f:	48 89 de             	mov    rsi,rbx
    1622:	48 89 d7             	mov    rdi,rdx
    1625:	e8 d6 e9 ff ff       	call   0 <chv3_hwprod>
    162a:	4c 89 fe             	mov    rsi,r15
    162d:	48 89 ef             	mov    rdi,rbp
    1630:	49 89 c3             	mov    r11,rax
    1633:	49 89 d4             	mov    r12,rdx
    1636:	e8 c5 e9 ff ff       	call   0 <chv3_hwprod>
    163b:	48 89 c6             	mov    rsi,rax
    163e:	e9 3c fa ff ff       	jmp    107f <chainhash_v3_evaluate.constprop.0+0x31f>
    1643:	48 8b 54 24 10       	mov    rdx,QWORD PTR [rsp+0x10]
    1648:	48 8b 74 24 20       	mov    rsi,QWORD PTR [rsp+0x20]
    164d:	4c 89 ef             	mov    rdi,r13
    1650:	e8 8b ea ff ff       	call   e0 <chv3_region128>
    1655:	8b 84 24 50 01 00 00 	mov    eax,DWORD PTR [rsp+0x150]
    165c:	89 44 24 30          	mov    DWORD PTR [rsp+0x30],eax
    1660:	e9 00 f9 ff ff       	jmp    f65 <chainhash_v3_evaluate.constprop.0+0x205>
    1665:	48 8b 54 24 10       	mov    rdx,QWORD PTR [rsp+0x10]
    166a:	48 8b 74 24 20       	mov    rsi,QWORD PTR [rsp+0x20]
    166f:	4c 89 ef             	mov    rdi,r13
    1672:	e8 19 ec ff ff       	call   290 <chv3_region256>
    1677:	e9 e9 f8 ff ff       	jmp    f65 <chainhash_v3_evaluate.constprop.0+0x205>
    167c:	31 f6                	xor    esi,esi
    167e:	89 f0                	mov    eax,esi
    1680:	0f a2                	cpuid  
    1682:	85 c0                	test   eax,eax
    1684:	0f 84 46 09 00 00    	je     1fd0 <chainhash_v3_evaluate.constprop.0+0x1270>
    168a:	b8 01 00 00 00       	mov    eax,0x1
    168f:	0f a2                	cpuid  
    1691:	81 e1 02 00 00 18    	and    ecx,0x18000002
    1697:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
    169d:	0f 85 2d 09 00 00    	jne    1fd0 <chainhash_v3_evaluate.constprop.0+0x1270>
    16a3:	89 f1                	mov    ecx,esi
    16a5:	0f 01 d0             	xgetbv 
    16a8:	89 c7                	mov    edi,eax
    16aa:	83 e0 06             	and    eax,0x6
    16ad:	83 f8 06             	cmp    eax,0x6
    16b0:	0f 85 1a 09 00 00    	jne    1fd0 <chainhash_v3_evaluate.constprop.0+0x1270>
    16b6:	89 f0                	mov    eax,esi
    16b8:	0f a2                	cpuid  
    16ba:	83 f8 06             	cmp    eax,0x6
    16bd:	0f 86 15 0b 00 00    	jbe    21d8 <chainhash_v3_evaluate.constprop.0+0x1478>
    16c3:	b8 07 00 00 00       	mov    eax,0x7
    16c8:	89 f1                	mov    ecx,esi
    16ca:	0f a2                	cpuid  
    16cc:	f6 c3 20             	test   bl,0x20
    16cf:	0f 84 03 0b 00 00    	je     21d8 <chainhash_v3_evaluate.constprop.0+0x1478>
    16d5:	80 e5 04             	and    ch,0x4
    16d8:	0f 84 fa 0a 00 00    	je     21d8 <chainhash_v3_evaluate.constprop.0+0x1478>
    16de:	81 e7 e6 00 00 00    	and    edi,0xe6
    16e4:	81 ff e6 00 00 00    	cmp    edi,0xe6
    16ea:	0f 85 c6 0a 00 00    	jne    21b6 <chainhash_v3_evaluate.constprop.0+0x1456>
    16f0:	81 e3 00 00 01 00    	and    ebx,0x10000
    16f6:	0f 84 ba 0a 00 00    	je     21b6 <chainhash_v3_evaluate.constprop.0+0x1456>
    16fc:	c7 05 00 00 00 00 03 	mov    DWORD PTR [rip+0x0],0x3        # 1706 <chainhash_v3_evaluate.constprop.0+0x9a6>
    1703:	00 00 00 
    1706:	b8 03 00 00 00       	mov    eax,0x3
    170b:	8b 7c 24 30          	mov    edi,DWORD PTR [rsp+0x30]
    170f:	85 ff                	test   edi,edi
    1711:	0f 84 81 f6 ff ff    	je     d98 <chainhash_v3_evaluate.constprop.0+0x38>
    1717:	8b 5c 24 30          	mov    ebx,DWORD PTR [rsp+0x30]
    171b:	85 db                	test   ebx,ebx
    171d:	7e 08                	jle    1727 <chainhash_v3_evaluate.constprop.0+0x9c7>
    171f:	39 c3                	cmp    ebx,eax
    1721:	0f 8e 71 f6 ff ff    	jle    d98 <chainhash_v3_evaluate.constprop.0+0x38>
    1727:	b9 00 00 00 00       	mov    ecx,0x0
    172c:	ba 63 01 00 00       	mov    edx,0x163
    1731:	be 00 00 00 00       	mov    esi,0x0
    1736:	bf 00 00 00 00       	mov    edi,0x0
    173b:	e8 00 00 00 00       	call   1740 <chainhash_v3_evaluate.constprop.0+0x9e0>
    1740:	8b 44 24 08          	mov    eax,DWORD PTR [rsp+0x8]
    1744:	4d 8b 8d 08 01 00 00 	mov    r9,QWORD PTR [r13+0x108]
    174b:	4c 89 64 24 10       	mov    QWORD PTR [rsp+0x10],r12
    1750:	85 c0                	test   eax,eax
    1752:	0f 84 c9 01 00 00    	je     1921 <chainhash_v3_evaluate.constprop.0+0xbc1>
    1758:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
    175d:	41 b8 01 00 00 00    	mov    r8d,0x1
    1763:	bb 41 00 00 00       	mov    ebx,0x41
    1768:	48 c7 44 24 18 00 00 	mov    QWORD PTR [rsp+0x18],0x0
    176f:	00 00 
    1771:	4c 8d 58 01          	lea    r11,[rax+0x1]
    1775:	e9 91 00 00 00       	jmp    180b <chainhash_v3_evaluate.constprop.0+0xaab>
    177a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    1780:	89 d9                	mov    ecx,ebx
    1782:	4d 89 cf             	mov    r15,r9
    1785:	29 d1                	sub    ecx,edx
    1787:	49 d3 ef             	shr    r15,cl
    178a:	4c 21 f8             	and    rax,r15
    178d:	48 31 c7             	xor    rdi,rax
    1790:	83 fa 40             	cmp    edx,0x40
    1793:	0f 85 32 01 00 00    	jne    18cb <chainhash_v3_evaluate.constprop.0+0xb6b>
    1799:	48 89 fa             	mov    rdx,rdi
    179c:	48 89 f8             	mov    rax,rdi
    179f:	48 8d 0c 3f          	lea    rcx,[rdi+rdi*1]
    17a3:	49 83 c0 01          	add    r8,0x1
    17a7:	48 c1 e8 3d          	shr    rax,0x3d
    17ab:	48 c1 ea 3f          	shr    rdx,0x3f
    17af:	48 31 c2             	xor    rdx,rax
    17b2:	48 89 f8             	mov    rax,rdi
    17b5:	48 c1 e8 3c          	shr    rax,0x3c
    17b9:	48 31 c2             	xor    rdx,rax
    17bc:	48 89 f0             	mov    rax,rsi
    17bf:	48 31 f8             	xor    rax,rdi
    17c2:	48 33 44 24 18       	xor    rax,QWORD PTR [rsp+0x18]
    17c7:	48 31 c8             	xor    rax,rcx
    17ca:	48 8d 0c fd 00 00 00 	lea    rcx,[rdi*8+0x0]
    17d1:	00 
    17d2:	48 c1 e7 04          	shl    rdi,0x4
    17d6:	48 31 c8             	xor    rax,rcx
    17d9:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
    17dd:	48 31 f8             	xor    rax,rdi
    17e0:	48 31 d0             	xor    rax,rdx
    17e3:	48 31 c8             	xor    rax,rcx
    17e6:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
    17ed:	00 
    17ee:	48 c1 e2 04          	shl    rdx,0x4
    17f2:	48 31 c8             	xor    rax,rcx
    17f5:	48 31 c2             	xor    rdx,rax
    17f8:	41 8d 40 ff          	lea    eax,[r8-0x1]
    17fc:	48 89 54 24 18       	mov    QWORD PTR [rsp+0x18],rdx
    1801:	39 44 24 08          	cmp    DWORD PTR [rsp+0x8],eax
    1805:	0f 86 8c 05 00 00    	jbe    1d97 <chainhash_v3_evaluate.constprop.0+0x1037>
    180b:	4d 39 d8             	cmp    r8,r11
    180e:	0f 84 fa 00 00 00    	je     190e <chainhash_v3_evaluate.constprop.0+0xbae>
    1814:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
    1819:	31 d2                	xor    edx,edx
    181b:	4c 89 c1             	mov    rcx,r8
    181e:	48 c1 e1 04          	shl    rcx,0x4
    1822:	4c 29 c0             	sub    rax,r8
    1825:	4c 8b 8c 0c a8 00 00 	mov    r9,QWORD PTR [rsp+rcx*1+0xa8]
    182c:	00 
    182d:	48 f7 74 24 40       	div    QWORD PTR [rsp+0x40]
    1832:	48 8b 44 24 28       	mov    rax,QWORD PTR [rsp+0x28]
    1837:	4d 8b 94 d5 00 01 00 	mov    r10,QWORD PTR [r13+rdx*8+0x100]
    183e:	00 
    183f:	48 8b 14 08          	mov    rdx,QWORD PTR [rax+rcx*1]
    1843:	48 89 d0             	mov    rax,rdx
    1846:	48 89 d6             	mov    rsi,rdx
    1849:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
    184d:	49 31 d1             	xor    r9,rdx
    1850:	48 c1 ee 3d          	shr    rsi,0x3d
    1854:	48 c1 e8 3f          	shr    rax,0x3f
    1858:	49 31 c9             	xor    r9,rcx
    185b:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
    1862:	00 
    1863:	48 31 f0             	xor    rax,rsi
    1866:	48 89 d6             	mov    rsi,rdx
    1869:	49 31 c9             	xor    r9,rcx
    186c:	48 c1 e2 04          	shl    rdx,0x4
    1870:	48 c1 ee 3c          	shr    rsi,0x3c
    1874:	49 31 d1             	xor    r9,rdx
    1877:	48 31 f0             	xor    rax,rsi
    187a:	8b 74 24 30          	mov    esi,DWORD PTR [rsp+0x30]
    187e:	48 8d 14 00          	lea    rdx,[rax+rax*1]
    1882:	49 31 c1             	xor    r9,rax
    1885:	49 31 d1             	xor    r9,rdx
    1888:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
    188f:	00 
    1890:	48 c1 e0 04          	shl    rax,0x4
    1894:	49 31 d1             	xor    r9,rdx
    1897:	49 31 c1             	xor    r9,rax
    189a:	85 f6                	test   esi,esi
    189c:	75 31                	jne    18cf <chainhash_v3_evaluate.constprop.0+0xb6f>
    189e:	31 ff                	xor    edi,edi
    18a0:	31 f6                	xor    esi,esi
    18a2:	31 c9                	xor    ecx,ecx
    18a4:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    18a8:	4c 89 d0             	mov    rax,r10
    18ab:	4c 89 ca             	mov    rdx,r9
    18ae:	48 d3 e8             	shr    rax,cl
    18b1:	48 d3 e2             	shl    rdx,cl
    18b4:	83 e0 01             	and    eax,0x1
    18b7:	48 f7 d8             	neg    rax
    18ba:	48 21 c2             	and    rdx,rax
    18bd:	48 31 d6             	xor    rsi,rdx
    18c0:	8d 51 01             	lea    edx,[rcx+0x1]
    18c3:	85 c9                	test   ecx,ecx
    18c5:	0f 85 b5 fe ff ff    	jne    1780 <chainhash_v3_evaluate.constprop.0+0xa20>
    18cb:	89 d1                	mov    ecx,edx
    18cd:	eb d9                	jmp    18a8 <chainhash_v3_evaluate.constprop.0+0xb48>
    18cf:	4c 89 d6             	mov    rsi,r10
    18d2:	4c 89 cf             	mov    rdi,r9
    18d5:	e8 26 e7 ff ff       	call   0 <chv3_hwprod>
    18da:	48 89 c6             	mov    rsi,rax
    18dd:	48 89 d7             	mov    rdi,rdx
    18e0:	e9 b4 fe ff ff       	jmp    1799 <chainhash_v3_evaluate.constprop.0+0xa39>
    18e5:	8b 7c 24 08          	mov    edi,DWORD PTR [rsp+0x8]
    18e9:	4c 8b ac 24 b0 00 00 	mov    r13,QWORD PTR [rsp+0xb0]
    18f0:	00 
    18f1:	48 c7 84 24 58 01 00 	mov    QWORD PTR [rsp+0x158],0x0
    18f8:	00 00 00 00 00 
    18fd:	85 ff                	test   edi,edi
    18ff:	0f 85 53 fe ff ff    	jne    1758 <chainhash_v3_evaluate.constprop.0+0x9f8>
    1905:	48 c7 44 24 18 00 00 	mov    QWORD PTR [rsp+0x18],0x0
    190c:	00 00 
    190e:	48 83 7c 24 10 00    	cmp    QWORD PTR [rsp+0x10],0x0
    1914:	4d 8b 8d 08 01 00 00 	mov    r9,QWORD PTR [r13+0x108]
    191b:	0f 84 9d 07 00 00    	je     20be <chainhash_v3_evaluate.constprop.0+0x135e>
    1921:	4c 8b 5c 24 10       	mov    r11,QWORD PTR [rsp+0x10]
    1926:	8b 5c 24 30          	mov    ebx,DWORD PTR [rsp+0x30]
    192a:	41 b8 01 00 00 00    	mov    r8d,0x1
    1930:	41 ba 41 00 00 00    	mov    r10d,0x41
    1936:	41 f6 c3 01          	test   r11b,0x1
    193a:	0f 84 a4 00 00 00    	je     19e4 <chainhash_v3_evaluate.constprop.0+0xc84>
    1940:	85 db                	test   ebx,ebx
    1942:	0f 85 39 04 00 00    	jne    1d81 <chainhash_v3_evaluate.constprop.0+0x1021>
    1948:	31 f6                	xor    esi,esi
    194a:	31 ff                	xor    edi,edi
    194c:	31 c9                	xor    ecx,ecx
    194e:	4c 89 c8             	mov    rax,r9
    1951:	4c 89 c2             	mov    rdx,r8
    1954:	48 d3 e8             	shr    rax,cl
    1957:	48 d3 e2             	shl    rdx,cl
    195a:	83 e0 01             	and    eax,0x1
    195d:	48 f7 d8             	neg    rax
    1960:	48 21 c2             	and    rdx,rax
    1963:	48 31 d7             	xor    rdi,rdx
    1966:	8d 51 01             	lea    edx,[rcx+0x1]
    1969:	85 c9                	test   ecx,ecx
    196b:	0f 84 4e 03 00 00    	je     1cbf <chainhash_v3_evaluate.constprop.0+0xf5f>
    1971:	44 89 d1             	mov    ecx,r10d
    1974:	4d 89 c7             	mov    r15,r8
    1977:	29 d1                	sub    ecx,edx
    1979:	49 d3 ef             	shr    r15,cl
    197c:	4c 21 f8             	and    rax,r15
    197f:	48 31 c6             	xor    rsi,rax
    1982:	83 fa 40             	cmp    edx,0x40
    1985:	0f 85 34 03 00 00    	jne    1cbf <chainhash_v3_evaluate.constprop.0+0xf5f>
    198b:	48 89 f2             	mov    rdx,rsi
    198e:	48 89 f0             	mov    rax,rsi
    1991:	48 8d 0c 36          	lea    rcx,[rsi+rsi*1]
    1995:	48 c1 e8 3d          	shr    rax,0x3d
    1999:	48 c1 ea 3f          	shr    rdx,0x3f
    199d:	48 31 c2             	xor    rdx,rax
    19a0:	48 89 f0             	mov    rax,rsi
    19a3:	48 c1 e8 3c          	shr    rax,0x3c
    19a7:	48 31 c2             	xor    rdx,rax
    19aa:	48 89 f8             	mov    rax,rdi
    19ad:	48 31 f0             	xor    rax,rsi
    19b0:	48 31 c8             	xor    rax,rcx
    19b3:	48 8d 0c f5 00 00 00 	lea    rcx,[rsi*8+0x0]
    19ba:	00 
    19bb:	48 c1 e6 04          	shl    rsi,0x4
    19bf:	48 31 c8             	xor    rax,rcx
    19c2:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
    19c6:	48 31 f0             	xor    rax,rsi
    19c9:	48 31 d0             	xor    rax,rdx
    19cc:	48 31 c8             	xor    rax,rcx
    19cf:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
    19d6:	00 
    19d7:	48 c1 e2 04          	shl    rdx,0x4
    19db:	48 31 c8             	xor    rax,rcx
    19de:	48 31 d0             	xor    rax,rdx
    19e1:	49 89 c0             	mov    r8,rax
    19e4:	49 d1 eb             	shr    r11,1
    19e7:	0f 85 d9 02 00 00    	jne    1cc6 <chainhash_v3_evaluate.constprop.0+0xf66>
    19ed:	8b 4c 24 30          	mov    ecx,DWORD PTR [rsp+0x30]
    19f1:	4c 8b 8c 24 38 01 00 	mov    r9,QWORD PTR [rsp+0x138]
    19f8:	00 
    19f9:	85 c9                	test   ecx,ecx
    19fb:	75 45                	jne    1a42 <chainhash_v3_evaluate.constprop.0+0xce2>
    19fd:	31 f6                	xor    esi,esi
    19ff:	31 ff                	xor    edi,edi
    1a01:	31 c9                	xor    ecx,ecx
    1a03:	41 ba 41 00 00 00    	mov    r10d,0x41
    1a09:	4c 89 c0             	mov    rax,r8
    1a0c:	4c 89 ca             	mov    rdx,r9
    1a0f:	48 d3 e8             	shr    rax,cl
    1a12:	48 d3 e2             	shl    rdx,cl
    1a15:	83 e0 01             	and    eax,0x1
    1a18:	48 f7 d8             	neg    rax
    1a1b:	48 21 c2             	and    rdx,rax
    1a1e:	48 31 d7             	xor    rdi,rdx
    1a21:	8d 51 01             	lea    edx,[rcx+0x1]
    1a24:	85 c9                	test   ecx,ecx
    1a26:	74 16                	je     1a3e <chainhash_v3_evaluate.constprop.0+0xcde>
    1a28:	44 89 d1             	mov    ecx,r10d
    1a2b:	4c 89 cb             	mov    rbx,r9
    1a2e:	29 d1                	sub    ecx,edx
    1a30:	48 d3 eb             	shr    rbx,cl
    1a33:	48 21 d8             	and    rax,rbx
    1a36:	48 31 c6             	xor    rsi,rax
    1a39:	83 fa 40             	cmp    edx,0x40
    1a3c:	74 15                	je     1a53 <chainhash_v3_evaluate.constprop.0+0xcf3>
    1a3e:	89 d1                	mov    ecx,edx
    1a40:	eb c7                	jmp    1a09 <chainhash_v3_evaluate.constprop.0+0xca9>
    1a42:	4c 89 c6             	mov    rsi,r8
    1a45:	4c 89 cf             	mov    rdi,r9
    1a48:	e8 b3 e5 ff ff       	call   0 <chv3_hwprod>
    1a4d:	48 89 c7             	mov    rdi,rax
    1a50:	48 89 d6             	mov    rsi,rdx
    1a53:	48 89 f2             	mov    rdx,rsi
    1a56:	48 89 f0             	mov    rax,rsi
    1a59:	48 8d 0c 36          	lea    rcx,[rsi+rsi*1]
    1a5d:	48 c1 e8 3d          	shr    rax,0x3d
    1a61:	48 c1 ea 3f          	shr    rdx,0x3f
    1a65:	48 31 c2             	xor    rdx,rax
    1a68:	48 89 f0             	mov    rax,rsi
    1a6b:	48 c1 e8 3c          	shr    rax,0x3c
    1a6f:	48 31 c2             	xor    rdx,rax
    1a72:	48 89 f8             	mov    rax,rdi
    1a75:	48 31 f0             	xor    rax,rsi
    1a78:	48 33 44 24 18       	xor    rax,QWORD PTR [rsp+0x18]
    1a7d:	48 31 c8             	xor    rax,rcx
    1a80:	48 8d 0c f5 00 00 00 	lea    rcx,[rsi*8+0x0]
    1a87:	00 
    1a88:	48 c1 e6 04          	shl    rsi,0x4
    1a8c:	48 31 c8             	xor    rax,rcx
    1a8f:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
    1a93:	48 31 f0             	xor    rax,rsi
    1a96:	48 31 d0             	xor    rax,rdx
    1a99:	48 31 c8             	xor    rax,rcx
    1a9c:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
    1aa3:	00 
    1aa4:	48 c1 e2 04          	shl    rdx,0x4
    1aa8:	48 31 c8             	xor    rax,rcx
    1aab:	48 31 d0             	xor    rax,rdx
    1aae:	8b 54 24 30          	mov    edx,DWORD PTR [rsp+0x30]
    1ab2:	48 89 c6             	mov    rsi,rax
    1ab5:	85 d2                	test   edx,edx
    1ab7:	0f 85 e6 02 00 00    	jne    1da3 <chainhash_v3_evaluate.constprop.0+0x1043>
    1abd:	49 8b 85 b8 01 00 00 	mov    rax,QWORD PTR [r13+0x1b8]
    1ac4:	45 31 c0             	xor    r8d,r8d
    1ac7:	31 ff                	xor    edi,edi
    1ac9:	31 c9                	xor    ecx,ecx
    1acb:	41 b9 41 00 00 00    	mov    r9d,0x41
    1ad1:	48 01 f0             	add    rax,rsi
    1ad4:	48 89 c2             	mov    rdx,rax
    1ad7:	48 89 c6             	mov    rsi,rax
    1ada:	48 d3 ea             	shr    rdx,cl
    1add:	48 d3 e6             	shl    rsi,cl
    1ae0:	83 e2 01             	and    edx,0x1
    1ae3:	48 f7 da             	neg    rdx
    1ae6:	48 21 d6             	and    rsi,rdx
    1ae9:	48 31 f7             	xor    rdi,rsi
    1aec:	8d 71 01             	lea    esi,[rcx+0x1]
    1aef:	85 c9                	test   ecx,ecx
    1af1:	74 16                	je     1b09 <chainhash_v3_evaluate.constprop.0+0xda9>
    1af3:	44 89 c9             	mov    ecx,r9d
    1af6:	48 89 c3             	mov    rbx,rax
    1af9:	29 f1                	sub    ecx,esi
    1afb:	48 d3 eb             	shr    rbx,cl
    1afe:	48 21 da             	and    rdx,rbx
    1b01:	49 31 d0             	xor    r8,rdx
    1b04:	83 fe 40             	cmp    esi,0x40
    1b07:	74 04                	je     1b0d <chainhash_v3_evaluate.constprop.0+0xdad>
    1b09:	89 f1                	mov    ecx,esi
    1b0b:	eb c7                	jmp    1ad4 <chainhash_v3_evaluate.constprop.0+0xd74>
    1b0d:	4c 89 c1             	mov    rcx,r8
    1b10:	4c 89 c2             	mov    rdx,r8
    1b13:	4c 31 c7             	xor    rdi,r8
    1b16:	4d 8b 95 98 01 00 00 	mov    r10,QWORD PTR [r13+0x198]
    1b1d:	48 c1 ea 3c          	shr    rdx,0x3c
    1b21:	48 c1 e9 3d          	shr    rcx,0x3d
    1b25:	4b 8d 34 00          	lea    rsi,[r8+r8*1]
    1b29:	45 31 c9             	xor    r9d,r9d
    1b2c:	48 31 d1             	xor    rcx,rdx
    1b2f:	48 89 fa             	mov    rdx,rdi
    1b32:	49 8b bd 90 01 00 00 	mov    rdi,QWORD PTR [r13+0x190]
    1b39:	49 31 c2             	xor    r10,rax
    1b3c:	48 31 f2             	xor    rdx,rsi
    1b3f:	4a 8d 34 c5 00 00 00 	lea    rsi,[r8*8+0x0]
    1b46:	00 
    1b47:	49 c1 e0 04          	shl    r8,0x4
    1b4b:	41 bb 41 00 00 00    	mov    r11d,0x41
    1b51:	48 31 f2             	xor    rdx,rsi
    1b54:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
    1b58:	4c 31 c2             	xor    rdx,r8
    1b5b:	45 31 c0             	xor    r8d,r8d
    1b5e:	48 31 ca             	xor    rdx,rcx
    1b61:	48 31 f2             	xor    rdx,rsi
    1b64:	48 8d 34 cd 00 00 00 	lea    rsi,[rcx*8+0x0]
    1b6b:	00 
    1b6c:	48 c1 e1 04          	shl    rcx,0x4
    1b70:	48 31 f2             	xor    rdx,rsi
    1b73:	48 31 ca             	xor    rdx,rcx
    1b76:	31 c9                	xor    ecx,ecx
    1b78:	49 31 d2             	xor    r10,rdx
    1b7b:	48 31 d7             	xor    rdi,rdx
    1b7e:	4c 89 d2             	mov    rdx,r10
    1b81:	48 89 fe             	mov    rsi,rdi
    1b84:	48 d3 ea             	shr    rdx,cl
    1b87:	48 d3 e6             	shl    rsi,cl
    1b8a:	83 e2 01             	and    edx,0x1
    1b8d:	48 f7 da             	neg    rdx
    1b90:	48 21 d6             	and    rsi,rdx
    1b93:	49 31 f1             	xor    r9,rsi
    1b96:	8d 71 01             	lea    esi,[rcx+0x1]
    1b99:	85 c9                	test   ecx,ecx
    1b9b:	74 16                	je     1bb3 <chainhash_v3_evaluate.constprop.0+0xe53>
    1b9d:	44 89 d9             	mov    ecx,r11d
    1ba0:	48 89 fb             	mov    rbx,rdi
    1ba3:	29 f1                	sub    ecx,esi
    1ba5:	48 d3 eb             	shr    rbx,cl
    1ba8:	48 21 da             	and    rdx,rbx
    1bab:	49 31 d0             	xor    r8,rdx
    1bae:	83 fe 40             	cmp    esi,0x40
    1bb1:	74 04                	je     1bb7 <chainhash_v3_evaluate.constprop.0+0xe57>
    1bb3:	89 f1                	mov    ecx,esi
    1bb5:	eb c7                	jmp    1b7e <chainhash_v3_evaluate.constprop.0+0xe1e>
    1bb7:	4c 89 c1             	mov    rcx,r8
    1bba:	4c 89 c2             	mov    rdx,r8
    1bbd:	4b 8d 34 00          	lea    rsi,[r8+r8*1]
    1bc1:	41 ba 41 00 00 00    	mov    r10d,0x41
    1bc7:	48 c1 ea 3c          	shr    rdx,0x3c
    1bcb:	48 c1 e9 3d          	shr    rcx,0x3d
    1bcf:	49 33 85 a0 01 00 00 	xor    rax,QWORD PTR [r13+0x1a0]
    1bd6:	48 31 d1             	xor    rcx,rdx
    1bd9:	49 8b 95 a8 01 00 00 	mov    rdx,QWORD PTR [r13+0x1a8]
    1be0:	4c 31 ca             	xor    rdx,r9
    1be3:	49 89 c1             	mov    r9,rax
    1be6:	31 c0                	xor    eax,eax
    1be8:	4c 31 c2             	xor    rdx,r8
    1beb:	48 31 f2             	xor    rdx,rsi
    1bee:	4a 8d 34 c5 00 00 00 	lea    rsi,[r8*8+0x0]
    1bf5:	00 
    1bf6:	49 c1 e0 04          	shl    r8,0x4
    1bfa:	48 31 f2             	xor    rdx,rsi
    1bfd:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
    1c01:	4c 31 c2             	xor    rdx,r8
    1c04:	45 31 c0             	xor    r8d,r8d
    1c07:	48 31 ca             	xor    rdx,rcx
    1c0a:	48 31 f2             	xor    rdx,rsi
    1c0d:	48 8d 34 cd 00 00 00 	lea    rsi,[rcx*8+0x0]
    1c14:	00 
    1c15:	48 c1 e1 04          	shl    rcx,0x4
    1c19:	48 31 f2             	xor    rdx,rsi
    1c1c:	48 89 d7             	mov    rdi,rdx
    1c1f:	48 31 cf             	xor    rdi,rcx
    1c22:	31 c9                	xor    ecx,ecx
    1c24:	48 89 fa             	mov    rdx,rdi
    1c27:	4c 89 ce             	mov    rsi,r9
    1c2a:	48 d3 ea             	shr    rdx,cl
    1c2d:	48 d3 e6             	shl    rsi,cl
    1c30:	83 e2 01             	and    edx,0x1
    1c33:	48 f7 da             	neg    rdx
    1c36:	48 21 d6             	and    rsi,rdx
    1c39:	48 31 f0             	xor    rax,rsi
    1c3c:	8d 71 01             	lea    esi,[rcx+0x1]
    1c3f:	85 c9                	test   ecx,ecx
    1c41:	74 16                	je     1c59 <chainhash_v3_evaluate.constprop.0+0xef9>
    1c43:	44 89 d1             	mov    ecx,r10d
    1c46:	4c 89 cb             	mov    rbx,r9
    1c49:	29 f1                	sub    ecx,esi
    1c4b:	48 d3 eb             	shr    rbx,cl
    1c4e:	48 21 da             	and    rdx,rbx
    1c51:	49 31 d0             	xor    r8,rdx
    1c54:	83 fe 40             	cmp    esi,0x40
    1c57:	74 04                	je     1c5d <chainhash_v3_evaluate.constprop.0+0xefd>
    1c59:	89 f1                	mov    ecx,esi
    1c5b:	eb c7                	jmp    1c24 <chainhash_v3_evaluate.constprop.0+0xec4>
    1c5d:	4c 89 c2             	mov    rdx,r8
    1c60:	4c 89 c1             	mov    rcx,r8
    1c63:	49 33 85 b0 01 00 00 	xor    rax,QWORD PTR [r13+0x1b0]
    1c6a:	48 c1 e9 3c          	shr    rcx,0x3c
    1c6e:	48 c1 ea 3d          	shr    rdx,0x3d
    1c72:	4c 31 c0             	xor    rax,r8
    1c75:	48 31 ca             	xor    rdx,rcx
    1c78:	4b 8d 0c 00          	lea    rcx,[r8+r8*1]
    1c7c:	48 31 c8             	xor    rax,rcx
    1c7f:	4a 8d 0c c5 00 00 00 	lea    rcx,[r8*8+0x0]
    1c86:	00 
    1c87:	49 c1 e0 04          	shl    r8,0x4
    1c8b:	48 31 c8             	xor    rax,rcx
    1c8e:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
    1c92:	4c 31 c0             	xor    rax,r8
    1c95:	48 31 d0             	xor    rax,rdx
    1c98:	48 31 c8             	xor    rax,rcx
    1c9b:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
    1ca2:	00 
    1ca3:	48 c1 e2 04          	shl    rdx,0x4
    1ca7:	48 31 c8             	xor    rax,rcx
    1caa:	48 31 d0             	xor    rax,rdx
    1cad:	48 81 c4 68 05 00 00 	add    rsp,0x568
    1cb4:	5b                   	pop    rbx
    1cb5:	5d                   	pop    rbp
    1cb6:	41 5c                	pop    r12
    1cb8:	41 5d                	pop    r13
    1cba:	41 5e                	pop    r14
    1cbc:	41 5f                	pop    r15
    1cbe:	c3                   	ret    
    1cbf:	89 d1                	mov    ecx,edx
    1cc1:	e9 88 fc ff ff       	jmp    194e <chainhash_v3_evaluate.constprop.0+0xbee>
    1cc6:	85 db                	test   ebx,ebx
    1cc8:	0f 85 a0 00 00 00    	jne    1d6e <chainhash_v3_evaluate.constprop.0+0x100e>
    1cce:	31 f6                	xor    esi,esi
    1cd0:	31 ff                	xor    edi,edi
    1cd2:	31 c9                	xor    ecx,ecx
    1cd4:	4c 89 c8             	mov    rax,r9
    1cd7:	4c 89 ca             	mov    rdx,r9
    1cda:	48 d3 e8             	shr    rax,cl
    1cdd:	48 d3 e2             	shl    rdx,cl
    1ce0:	83 e0 01             	and    eax,0x1
    1ce3:	48 f7 d8             	neg    rax
    1ce6:	48 21 c2             	and    rdx,rax
    1ce9:	48 31 d7             	xor    rdi,rdx
    1cec:	8d 51 01             	lea    edx,[rcx+0x1]
    1cef:	85 c9                	test   ecx,ecx
    1cf1:	74 74                	je     1d67 <chainhash_v3_evaluate.constprop.0+0x1007>
    1cf3:	44 89 d1             	mov    ecx,r10d
    1cf6:	4d 89 cf             	mov    r15,r9
    1cf9:	29 d1                	sub    ecx,edx
    1cfb:	49 d3 ef             	shr    r15,cl
    1cfe:	4c 21 f8             	and    rax,r15
    1d01:	48 31 c6             	xor    rsi,rax
    1d04:	83 fa 40             	cmp    edx,0x40
    1d07:	75 5e                	jne    1d67 <chainhash_v3_evaluate.constprop.0+0x1007>
    1d09:	48 89 f2             	mov    rdx,rsi
    1d0c:	48 89 f0             	mov    rax,rsi
    1d0f:	48 8d 0c 36          	lea    rcx,[rsi+rsi*1]
    1d13:	48 c1 e8 3d          	shr    rax,0x3d
    1d17:	48 c1 ea 3f          	shr    rdx,0x3f
    1d1b:	48 31 c2             	xor    rdx,rax
    1d1e:	48 89 f0             	mov    rax,rsi
    1d21:	48 c1 e8 3c          	shr    rax,0x3c
    1d25:	48 31 c2             	xor    rdx,rax
    1d28:	48 89 f8             	mov    rax,rdi
    1d2b:	48 31 f0             	xor    rax,rsi
    1d2e:	48 31 c8             	xor    rax,rcx
    1d31:	48 8d 0c f5 00 00 00 	lea    rcx,[rsi*8+0x0]
    1d38:	00 
    1d39:	48 c1 e6 04          	shl    rsi,0x4
    1d3d:	48 31 c8             	xor    rax,rcx
    1d40:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
    1d44:	48 31 f0             	xor    rax,rsi
    1d47:	48 31 d0             	xor    rax,rdx
    1d4a:	48 31 c8             	xor    rax,rcx
    1d4d:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
    1d54:	00 
    1d55:	48 c1 e2 04          	shl    rdx,0x4
    1d59:	48 31 c8             	xor    rax,rcx
    1d5c:	48 31 d0             	xor    rax,rdx
    1d5f:	49 89 c1             	mov    r9,rax
    1d62:	e9 cf fb ff ff       	jmp    1936 <chainhash_v3_evaluate.constprop.0+0xbd6>
    1d67:	89 d1                	mov    ecx,edx
    1d69:	e9 66 ff ff ff       	jmp    1cd4 <chainhash_v3_evaluate.constprop.0+0xf74>
    1d6e:	4c 89 ce             	mov    rsi,r9
    1d71:	4c 89 cf             	mov    rdi,r9
    1d74:	e8 87 e2 ff ff       	call   0 <chv3_hwprod>
    1d79:	48 89 c7             	mov    rdi,rax
    1d7c:	48 89 d6             	mov    rsi,rdx
    1d7f:	eb 88                	jmp    1d09 <chainhash_v3_evaluate.constprop.0+0xfa9>
    1d81:	4c 89 ce             	mov    rsi,r9
    1d84:	4c 89 c7             	mov    rdi,r8
    1d87:	e8 74 e2 ff ff       	call   0 <chv3_hwprod>
    1d8c:	48 89 c7             	mov    rdi,rax
    1d8f:	48 89 d6             	mov    rsi,rdx
    1d92:	e9 f4 fb ff ff       	jmp    198b <chainhash_v3_evaluate.constprop.0+0xc2b>
    1d97:	4d 8b 8d 08 01 00 00 	mov    r9,QWORD PTR [r13+0x108]
    1d9e:	e9 7e fb ff ff       	jmp    1921 <chainhash_v3_evaluate.constprop.0+0xbc1>
    1da3:	4c 89 ef             	mov    rdi,r13
    1da6:	e8 85 e2 ff ff       	call   30 <chv3_fastfinish>
    1dab:	e9 fd fe ff ff       	jmp    1cad <chainhash_v3_evaluate.constprop.0+0xf4d>
    1db0:	4c 89 44 24 20       	mov    QWORD PTR [rsp+0x20],r8
    1db5:	31 ff                	xor    edi,edi
    1db7:	31 d2                	xor    edx,edx
    1db9:	31 c9                	xor    ecx,ecx
    1dbb:	4c 89 e0             	mov    rax,r12
    1dbe:	48 89 ee             	mov    rsi,rbp
    1dc1:	48 d3 e8             	shr    rax,cl
    1dc4:	48 d3 e6             	shl    rsi,cl
    1dc7:	83 e0 01             	and    eax,0x1
    1dca:	48 f7 d8             	neg    rax
    1dcd:	48 21 c6             	and    rsi,rax
    1dd0:	48 31 f2             	xor    rdx,rsi
    1dd3:	8d 71 01             	lea    esi,[rcx+0x1]
    1dd6:	85 c9                	test   ecx,ecx
    1dd8:	74 16                	je     1df0 <chainhash_v3_evaluate.constprop.0+0x1090>
    1dda:	44 89 d9             	mov    ecx,r11d
    1ddd:	49 89 e8             	mov    r8,rbp
    1de0:	29 f1                	sub    ecx,esi
    1de2:	49 d3 e8             	shr    r8,cl
    1de5:	4c 21 c0             	and    rax,r8
    1de8:	48 31 c7             	xor    rdi,rax
    1deb:	83 fe 40             	cmp    esi,0x40
    1dee:	74 04                	je     1df4 <chainhash_v3_evaluate.constprop.0+0x1094>
    1df0:	89 f1                	mov    ecx,esi
    1df2:	eb c7                	jmp    1dbb <chainhash_v3_evaluate.constprop.0+0x105b>
    1df4:	4c 8b 44 24 20       	mov    r8,QWORD PTR [rsp+0x20]
    1df9:	48 89 d9             	mov    rcx,rbx
    1dfc:	48 89 d0             	mov    rax,rdx
    1dff:	48 c1 e1 04          	shl    rcx,0x4
    1e03:	4c 31 c0             	xor    rax,r8
    1e06:	49 33 06             	xor    rax,QWORD PTR [r14]
    1e09:	48 89 84 0c b8 00 00 	mov    QWORD PTR [rsp+rcx*1+0xb8],rax
    1e10:	00 
    1e11:	4c 89 c8             	mov    rax,r9
    1e14:	48 31 f8             	xor    rax,rdi
    1e17:	49 33 46 08          	xor    rax,QWORD PTR [r14+0x8]
    1e1b:	48 c1 e3 04          	shl    rbx,0x4
    1e1f:	4c 89 bc 24 40 01 00 	mov    QWORD PTR [rsp+0x140],r15
    1e26:	00 
    1e27:	49 83 c6 10          	add    r14,0x10
    1e2b:	48 89 84 1c c0 00 00 	mov    QWORD PTR [rsp+rbx*1+0xc0],rax
    1e32:	00 
    1e33:	4c 89 f8             	mov    rax,r15
    1e36:	4c 3b 7c 24 10       	cmp    r15,QWORD PTR [rsp+0x10]
    1e3b:	0f 84 a4 fa ff ff    	je     18e5 <chainhash_v3_evaluate.constprop.0+0xb85>
    1e41:	49 83 c7 01          	add    r15,0x1
    1e45:	e9 d8 f5 ff ff       	jmp    1422 <chainhash_v3_evaluate.constprop.0+0x6c2>
    1e4a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    1e50:	44 89 f1             	mov    ecx,r14d
    1e53:	e9 e8 f4 ff ff       	jmp    1340 <chainhash_v3_evaluate.constprop.0+0x5e0>
    1e58:	44 8b 74 24 30       	mov    r14d,DWORD PTR [rsp+0x30]
    1e5d:	49 8b b8 b0 00 00 00 	mov    rdi,QWORD PTR [r8+0xb0]
    1e64:	49 33 7c c5 00       	xor    rdi,QWORD PTR [r13+rax*8+0x0]
    1e69:	45 85 f6             	test   r14d,r14d
    1e6c:	0f 84 be f4 ff ff    	je     1330 <chainhash_v3_evaluate.constprop.0+0x5d0>
    1e72:	e8 89 e1 ff ff       	call   0 <chv3_hwprod>
    1e77:	49 89 d7             	mov    r15,rdx
    1e7a:	48 89 c2             	mov    rdx,rax
    1e7d:	e9 05 f5 ff ff       	jmp    1387 <chainhash_v3_evaluate.constprop.0+0x627>
    1e82:	49 8b b0 f0 00 00 00 	mov    rsi,QWORD PTR [r8+0xf0]
    1e89:	e9 f3 f3 ff ff       	jmp    1281 <chainhash_v3_evaluate.constprop.0+0x521>
    1e8e:	44 8b 44 24 30       	mov    r8d,DWORD PTR [rsp+0x30]
    1e93:	45 85 c0             	test   r8d,r8d
    1e96:	75 40                	jne    1ed8 <chainhash_v3_evaluate.constprop.0+0x1178>
    1e98:	31 f6                	xor    esi,esi
    1e9a:	45 31 c0             	xor    r8d,r8d
    1e9d:	31 c9                	xor    ecx,ecx
    1e9f:	4c 89 d0             	mov    rax,r10
    1ea2:	48 89 fa             	mov    rdx,rdi
    1ea5:	48 d3 e8             	shr    rax,cl
    1ea8:	48 d3 e2             	shl    rdx,cl
    1eab:	83 e0 01             	and    eax,0x1
    1eae:	48 f7 d8             	neg    rax
    1eb1:	48 21 c2             	and    rdx,rax
    1eb4:	49 31 d0             	xor    r8,rdx
    1eb7:	8d 51 01             	lea    edx,[rcx+0x1]
    1eba:	85 c9                	test   ecx,ecx
    1ebc:	74 16                	je     1ed4 <chainhash_v3_evaluate.constprop.0+0x1174>
    1ebe:	44 89 d9             	mov    ecx,r11d
    1ec1:	49 89 f9             	mov    r9,rdi
    1ec4:	29 d1                	sub    ecx,edx
    1ec6:	49 d3 e9             	shr    r9,cl
    1ec9:	4c 21 c8             	and    rax,r9
    1ecc:	48 31 c6             	xor    rsi,rax
    1ecf:	83 fa 40             	cmp    edx,0x40
    1ed2:	74 12                	je     1ee6 <chainhash_v3_evaluate.constprop.0+0x1186>
    1ed4:	89 d1                	mov    ecx,edx
    1ed6:	eb c7                	jmp    1e9f <chainhash_v3_evaluate.constprop.0+0x113f>
    1ed8:	4c 89 d6             	mov    rsi,r10
    1edb:	e8 20 e1 ff ff       	call   0 <chv3_hwprod>
    1ee0:	49 89 c0             	mov    r8,rax
    1ee3:	48 89 d6             	mov    rsi,rdx
    1ee6:	48 89 f1             	mov    rcx,rsi
    1ee9:	48 89 f0             	mov    rax,rsi
    1eec:	4d 8b 4e 08          	mov    r9,QWORD PTR [r14+0x8]
    1ef0:	48 89 da             	mov    rdx,rbx
    1ef3:	48 c1 e8 3d          	shr    rax,0x3d
    1ef7:	48 c1 e9 3f          	shr    rcx,0x3f
    1efb:	48 31 c1             	xor    rcx,rax
    1efe:	48 89 f0             	mov    rax,rsi
    1f01:	4c 89 cf             	mov    rdi,r9
    1f04:	48 c1 e2 04          	shl    rdx,0x4
    1f08:	48 c1 e8 3c          	shr    rax,0x3c
    1f0c:	48 c1 ef 3f          	shr    rdi,0x3f
    1f10:	4b 8d 2c 09          	lea    rbp,[r9+r9*1]
    1f14:	48 31 c1             	xor    rcx,rax
    1f17:	4c 89 c8             	mov    rax,r9
    1f1a:	48 c1 e8 3d          	shr    rax,0x3d
    1f1e:	48 31 c7             	xor    rdi,rax
    1f21:	4c 89 c8             	mov    rax,r9
    1f24:	48 c1 e8 3c          	shr    rax,0x3c
    1f28:	48 31 c7             	xor    rdi,rax
    1f2b:	49 8b 06             	mov    rax,QWORD PTR [r14]
    1f2e:	4c 31 c8             	xor    rax,r9
    1f31:	48 31 e8             	xor    rax,rbp
    1f34:	4a 8d 2c cd 00 00 00 	lea    rbp,[r9*8+0x0]
    1f3b:	00 
    1f3c:	49 c1 e1 04          	shl    r9,0x4
    1f40:	48 31 e8             	xor    rax,rbp
    1f43:	4c 31 c8             	xor    rax,r9
    1f46:	4c 8d 0c 3f          	lea    r9,[rdi+rdi*1]
    1f4a:	48 31 f8             	xor    rax,rdi
    1f4d:	4c 31 c8             	xor    rax,r9
    1f50:	4c 8d 0c fd 00 00 00 	lea    r9,[rdi*8+0x0]
    1f57:	00 
    1f58:	48 c1 e7 04          	shl    rdi,0x4
    1f5c:	4c 31 c8             	xor    rax,r9
    1f5f:	48 31 f8             	xor    rax,rdi
    1f62:	48 8d 3c 36          	lea    rdi,[rsi+rsi*1]
    1f66:	4c 31 c0             	xor    rax,r8
    1f69:	48 31 f0             	xor    rax,rsi
    1f6c:	48 31 f8             	xor    rax,rdi
    1f6f:	48 8d 3c f5 00 00 00 	lea    rdi,[rsi*8+0x0]
    1f76:	00 
    1f77:	48 c1 e6 04          	shl    rsi,0x4
    1f7b:	48 31 f8             	xor    rax,rdi
    1f7e:	48 31 f0             	xor    rax,rsi
    1f81:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
    1f85:	48 31 c8             	xor    rax,rcx
    1f88:	48 31 f0             	xor    rax,rsi
    1f8b:	48 8d 34 cd 00 00 00 	lea    rsi,[rcx*8+0x0]
    1f92:	00 
    1f93:	48 c1 e1 04          	shl    rcx,0x4
    1f97:	48 31 f0             	xor    rax,rsi
    1f9a:	48 31 c8             	xor    rax,rcx
    1f9d:	48 89 84 14 b8 00 00 	mov    QWORD PTR [rsp+rdx*1+0xb8],rax
    1fa4:	00 
    1fa5:	31 c0                	xor    eax,eax
    1fa7:	e9 6f fe ff ff       	jmp    1e1b <chainhash_v3_evaluate.constprop.0+0x10bb>
    1fac:	4c 89 d6             	mov    rsi,r10
    1faf:	e8 4c e0 ff ff       	call   0 <chv3_hwprod>
    1fb4:	48 89 ef             	mov    rdi,rbp
    1fb7:	4c 89 e6             	mov    rsi,r12
    1fba:	49 89 c0             	mov    r8,rax
    1fbd:	49 89 d1             	mov    r9,rdx
    1fc0:	e8 3b e0 ff ff       	call   0 <chv3_hwprod>
    1fc5:	48 89 d7             	mov    rdi,rdx
    1fc8:	48 89 c2             	mov    rdx,rax
    1fcb:	e9 29 fe ff ff       	jmp    1df9 <chainhash_v3_evaluate.constprop.0+0x1099>
    1fd0:	c7 05 00 00 00 00 00 	mov    DWORD PTR [rip+0x0],0x0        # 1fda <chainhash_v3_evaluate.constprop.0+0x127a>
    1fd7:	00 00 00 
    1fda:	44 8b 54 24 30       	mov    r10d,DWORD PTR [rsp+0x30]
    1fdf:	45 85 d2             	test   r10d,r10d
    1fe2:	0f 85 3f f7 ff ff    	jne    1727 <chainhash_v3_evaluate.constprop.0+0x9c7>
    1fe8:	e9 ab ed ff ff       	jmp    d98 <chainhash_v3_evaluate.constprop.0+0x38>
    1fed:	89 d0                	mov    eax,edx
    1fef:	83 fa 04             	cmp    edx,0x4
    1ff2:	0f 85 1f f7 ff ff    	jne    1717 <chainhash_v3_evaluate.constprop.0+0x9b7>
    1ff8:	83 f9 04             	cmp    ecx,0x4
    1ffb:	0f 85 26 f7 ff ff    	jne    1727 <chainhash_v3_evaluate.constprop.0+0x9c7>
    2001:	e9 92 ed ff ff       	jmp    d98 <chainhash_v3_evaluate.constprop.0+0x38>
    2006:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
    200b:	48 8b 74 24 20       	mov    rsi,QWORD PTR [rsp+0x20]
    2010:	48 8d bc 24 60 01 00 	lea    rdi,[rsp+0x160]
    2017:	00 
    2018:	89 c2                	mov    edx,eax
    201a:	83 f8 08             	cmp    eax,0x8
    201d:	73 6d                	jae    208c <chainhash_v3_evaluate.constprop.0+0x132c>
    201f:	31 c0                	xor    eax,eax
    2021:	f6 c2 04             	test   dl,0x4
    2024:	75 56                	jne    207c <chainhash_v3_evaluate.constprop.0+0x131c>
    2026:	f6 c2 02             	test   dl,0x2
    2029:	75 3e                	jne    2069 <chainhash_v3_evaluate.constprop.0+0x1309>
    202b:	83 e2 01             	and    edx,0x1
    202e:	75 30                	jne    2060 <chainhash_v3_evaluate.constprop.0+0x1300>
    2030:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
    2035:	48 89 84 24 58 01 00 	mov    QWORD PTR [rsp+0x158],rax
    203c:	00 
    203d:	48 83 f8 30          	cmp    rax,0x30
    2041:	0f 87 0b 01 00 00    	ja     2152 <chainhash_v3_evaluate.constprop.0+0x13f2>
    2047:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
    204c:	48 83 e8 01          	sub    rax,0x1
    2050:	48 c1 e8 04          	shr    rax,0x4
    2054:	83 c0 01             	add    eax,0x1
    2057:	89 44 24 20          	mov    DWORD PTR [rsp+0x20],eax
    205b:	e9 c8 f0 ff ff       	jmp    1128 <chainhash_v3_evaluate.constprop.0+0x3c8>
    2060:	0f b6 14 06          	movzx  edx,BYTE PTR [rsi+rax*1]
    2064:	88 14 07             	mov    BYTE PTR [rdi+rax*1],dl
    2067:	eb c7                	jmp    2030 <chainhash_v3_evaluate.constprop.0+0x12d0>
    2069:	0f b7 0c 06          	movzx  ecx,WORD PTR [rsi+rax*1]
    206d:	66 89 0c 07          	mov    WORD PTR [rdi+rax*1],cx
    2071:	48 83 c0 02          	add    rax,0x2
    2075:	83 e2 01             	and    edx,0x1
    2078:	74 b6                	je     2030 <chainhash_v3_evaluate.constprop.0+0x12d0>
    207a:	eb e4                	jmp    2060 <chainhash_v3_evaluate.constprop.0+0x1300>
    207c:	8b 06                	mov    eax,DWORD PTR [rsi]
    207e:	89 07                	mov    DWORD PTR [rdi],eax
    2080:	b8 04 00 00 00       	mov    eax,0x4
    2085:	f6 c2 02             	test   dl,0x2
    2088:	74 a1                	je     202b <chainhash_v3_evaluate.constprop.0+0x12cb>
    208a:	eb dd                	jmp    2069 <chainhash_v3_evaluate.constprop.0+0x1309>
    208c:	89 c1                	mov    ecx,eax
    208e:	31 c0                	xor    eax,eax
    2090:	c1 e9 03             	shr    ecx,0x3
    2093:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
    2096:	f6 c2 04             	test   dl,0x4
    2099:	74 8b                	je     2026 <chainhash_v3_evaluate.constprop.0+0x12c6>
    209b:	eb df                	jmp    207c <chainhash_v3_evaluate.constprop.0+0x131c>
    209d:	c7 44 24 34 01 00 00 	mov    DWORD PTR [rsp+0x34],0x1
    20a4:	00 
    20a5:	45 31 e4             	xor    r12d,r12d
    20a8:	48 c7 44 24 40 04 00 	mov    QWORD PTR [rsp+0x40],0x4
    20af:	00 00 
    20b1:	c7 44 24 08 04 00 00 	mov    DWORD PTR [rsp+0x8],0x4
    20b8:	00 
    20b9:	e9 37 f0 ff ff       	jmp    10f5 <chainhash_v3_evaluate.constprop.0+0x395>
    20be:	41 b8 01 00 00 00    	mov    r8d,0x1
    20c4:	e9 24 f9 ff ff       	jmp    19ed <chainhash_v3_evaluate.constprop.0+0xc8d>
    20c9:	48 83 7c 24 18 30    	cmp    QWORD PTR [rsp+0x18],0x30
    20cf:	0f 86 72 ff ff ff    	jbe    2047 <chainhash_v3_evaluate.constprop.0+0x12e7>
    20d5:	48 81 7c 24 18 00 04 	cmp    QWORD PTR [rsp+0x18],0x400
    20dc:	00 00 
    20de:	75 72                	jne    2152 <chainhash_v3_evaluate.constprop.0+0x13f2>
    20e0:	83 7c 24 30 03       	cmp    DWORD PTR [rsp+0x30],0x3
    20e5:	0f 84 a0 00 00 00    	je     218b <chainhash_v3_evaluate.constprop.0+0x142b>
    20eb:	83 7c 24 30 02       	cmp    DWORD PTR [rsp+0x30],0x2
    20f0:	74 6e                	je     2160 <chainhash_v3_evaluate.constprop.0+0x1400>
    20f2:	83 7c 24 30 01       	cmp    DWORD PTR [rsp+0x30],0x1
    20f7:	c7 44 24 20 04 00 00 	mov    DWORD PTR [rsp+0x20],0x4
    20fe:	00 
    20ff:	0f 85 23 f0 ff ff    	jne    1128 <chainhash_v3_evaluate.constprop.0+0x3c8>
    2105:	48 8d 54 24 70       	lea    rdx,[rsp+0x70]
    210a:	48 8d b4 24 60 01 00 	lea    rsi,[rsp+0x160]
    2111:	00 
    2112:	4c 89 ef             	mov    rdi,r13
    2115:	48 89 54 24 10       	mov    QWORD PTR [rsp+0x10],rdx
    211a:	e8 c1 df ff ff       	call   e0 <chv3_region128>
    211f:	8b 9c 24 4c 01 00 00 	mov    ebx,DWORD PTR [rsp+0x14c]
    2126:	8b 84 24 48 01 00 00 	mov    eax,DWORD PTR [rsp+0x148]
    212d:	4c 8b a4 24 40 01 00 	mov    r12,QWORD PTR [rsp+0x140]
    2134:	00 
    2135:	89 5c 24 34          	mov    DWORD PTR [rsp+0x34],ebx
    2139:	8b 9c 24 50 01 00 00 	mov    ebx,DWORD PTR [rsp+0x150]
    2140:	89 44 24 08          	mov    DWORD PTR [rsp+0x8],eax
    2144:	48 89 44 24 40       	mov    QWORD PTR [rsp+0x40],rax
    2149:	89 5c 24 30          	mov    DWORD PTR [rsp+0x30],ebx
    214d:	e9 9c f2 ff ff       	jmp    13ee <chainhash_v3_evaluate.constprop.0+0x68e>
    2152:	c7 44 24 20 04 00 00 	mov    DWORD PTR [rsp+0x20],0x4
    2159:	00 
    215a:	e9 c9 ef ff ff       	jmp    1128 <chainhash_v3_evaluate.constprop.0+0x3c8>
    215f:	90                   	nop
    2160:	48 8d 54 24 70       	lea    rdx,[rsp+0x70]
    2165:	48 8d b4 24 60 01 00 	lea    rsi,[rsp+0x160]
    216c:	00 
    216d:	4c 89 ef             	mov    rdi,r13
    2170:	48 89 54 24 10       	mov    QWORD PTR [rsp+0x10],rdx
    2175:	e8 16 e1 ff ff       	call   290 <chv3_region256>
    217a:	c7 44 24 20 04 00 00 	mov    DWORD PTR [rsp+0x20],0x4
    2181:	00 
    2182:	8b 44 24 08          	mov    eax,DWORD PTR [rsp+0x8]
    2186:	e9 63 f2 ff ff       	jmp    13ee <chainhash_v3_evaluate.constprop.0+0x68e>
    218b:	48 8d 54 24 70       	lea    rdx,[rsp+0x70]
    2190:	48 8d b4 24 60 01 00 	lea    rsi,[rsp+0x160]
    2197:	00 
    2198:	4c 89 ef             	mov    rdi,r13
    219b:	48 89 54 24 10       	mov    QWORD PTR [rsp+0x10],rdx
    21a0:	e8 4b e4 ff ff       	call   5f0 <chv3_region512>
    21a5:	c7 44 24 20 04 00 00 	mov    DWORD PTR [rsp+0x20],0x4
    21ac:	00 
    21ad:	8b 44 24 08          	mov    eax,DWORD PTR [rsp+0x8]
    21b1:	e9 38 f2 ff ff       	jmp    13ee <chainhash_v3_evaluate.constprop.0+0x68e>
    21b6:	c7 05 00 00 00 00 02 	mov    DWORD PTR [rip+0x0],0x2        # 21c0 <chainhash_v3_evaluate.constprop.0+0x1460>
    21bd:	00 00 00 
    21c0:	b8 02 00 00 00       	mov    eax,0x2
    21c5:	44 8b 44 24 30       	mov    r8d,DWORD PTR [rsp+0x30]
    21ca:	45 85 c0             	test   r8d,r8d
    21cd:	0f 85 44 f5 ff ff    	jne    1717 <chainhash_v3_evaluate.constprop.0+0x9b7>
    21d3:	e9 c0 eb ff ff       	jmp    d98 <chainhash_v3_evaluate.constprop.0+0x38>
    21d8:	c7 05 00 00 00 00 01 	mov    DWORD PTR [rip+0x0],0x1        # 21e2 <chainhash_v3_evaluate.constprop.0+0x1482>
    21df:	00 00 00 
    21e2:	b8 01 00 00 00       	mov    eax,0x1
    21e7:	44 8b 4c 24 30       	mov    r9d,DWORD PTR [rsp+0x30]
    21ec:	45 85 c9             	test   r9d,r9d
    21ef:	0f 85 22 f5 ff ff    	jne    1717 <chainhash_v3_evaluate.constprop.0+0x9b7>
    21f5:	e9 9e eb ff ff       	jmp    d98 <chainhash_v3_evaluate.constprop.0+0x38>
    21fa:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000002200 <audit_xmm>:
    2200:	48 8d 46 40          	lea    rax,[rsi+0x40]
    2204:	c5 fa 6f 2e          	vmovdqu xmm5,XMMWORD PTR [rsi]
    2208:	c5 d1 ef 07          	vpxor  xmm0,xmm5,XMMWORD PTR [rdi]
    220c:	48 83 c6 10          	add    rsi,0x10
    2210:	48 83 c2 10          	add    rdx,0x10
    2214:	c5 fa 6f 76 30       	vmovdqu xmm6,XMMWORD PTR [rsi+0x30]
    2219:	c5 c9 ef 4f 10       	vpxor  xmm1,xmm6,XMMWORD PTR [rdi+0x10]
    221e:	c5 fa 6f 7e 70       	vmovdqu xmm7,XMMWORD PTR [rsi+0x70]
    2223:	c5 fa 6f ae b0 00 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0xb0]
    222a:	00 
    222b:	c5 c1 ef 5f 20       	vpxor  xmm3,xmm7,XMMWORD PTR [rdi+0x20]
    2230:	c4 63 79 44 f9 11    	vpclmulhqhqdq xmm15,xmm0,xmm1
    2236:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
    223c:	c5 fa 6f b6 f0 00 00 	vmovdqu xmm6,XMMWORD PTR [rsi+0xf0]
    2243:	00 
    2244:	c5 d1 ef 4f 30       	vpxor  xmm1,xmm5,XMMWORD PTR [rdi+0x30]
    2249:	c5 c9 ef 57 40       	vpxor  xmm2,xmm6,XMMWORD PTR [rdi+0x40]
    224e:	c5 f9 7f 44 24 d8    	vmovdqa XMMWORD PTR [rsp-0x28],xmm0
    2254:	c5 fa 6f be 30 01 00 	vmovdqu xmm7,XMMWORD PTR [rsi+0x130]
    225b:	00 
    225c:	c5 fa 6f ae 70 01 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0x170]
    2263:	00 
    2264:	c4 63 61 44 f1 11    	vpclmulhqhqdq xmm14,xmm3,xmm1
    226a:	c4 e3 61 44 d9 00    	vpclmullqlqdq xmm3,xmm3,xmm1
    2270:	c5 c1 ef 4f 50       	vpxor  xmm1,xmm7,XMMWORD PTR [rdi+0x50]
    2275:	c5 fa 6f b6 b0 01 00 	vmovdqu xmm6,XMMWORD PTR [rsi+0x1b0]
    227c:	00 
    227d:	c5 d1 ef 7f 60       	vpxor  xmm7,xmm5,XMMWORD PTR [rdi+0x60]
    2282:	c5 fa 6f a6 f0 01 00 	vmovdqu xmm4,XMMWORD PTR [rsi+0x1f0]
    2289:	00 
    228a:	c4 c1 61 ef de       	vpxor  xmm3,xmm3,xmm14
    228f:	c4 63 69 44 e9 11    	vpclmulhqhqdq xmm13,xmm2,xmm1
    2295:	c4 e3 69 44 d1 00    	vpclmullqlqdq xmm2,xmm2,xmm1
    229b:	c5 c9 ef 4f 70       	vpxor  xmm1,xmm6,XMMWORD PTR [rdi+0x70]
    22a0:	c5 fa 6f ae 30 02 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0x230]
    22a7:	00 
    22a8:	c5 d9 ef b7 80 00 00 	vpxor  xmm6,xmm4,XMMWORD PTR [rdi+0x80]
    22af:	00 
    22b0:	c5 fa 6f a6 70 02 00 	vmovdqu xmm4,XMMWORD PTR [rsi+0x270]
    22b7:	00 
    22b8:	c4 c1 69 ef d5       	vpxor  xmm2,xmm2,xmm13
    22bd:	c4 63 41 44 c9 11    	vpclmulhqhqdq xmm9,xmm7,xmm1
    22c3:	c4 e3 41 44 f9 00    	vpclmullqlqdq xmm7,xmm7,xmm1
    22c9:	c5 d1 ef 8f 90 00 00 	vpxor  xmm1,xmm5,XMMWORD PTR [rdi+0x90]
    22d0:	00 
    22d1:	c5 fa 6f ae b0 02 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0x2b0]
    22d8:	00 
    22d9:	c5 e9 ef d7          	vpxor  xmm2,xmm2,xmm7
    22dd:	c4 63 49 44 e1 11    	vpclmulhqhqdq xmm12,xmm6,xmm1
    22e3:	c4 e3 49 44 f1 00    	vpclmullqlqdq xmm6,xmm6,xmm1
    22e9:	c5 d9 ef 8f a0 00 00 	vpxor  xmm1,xmm4,XMMWORD PTR [rdi+0xa0]
    22f0:	00 
    22f1:	c5 d1 ef a7 b0 00 00 	vpxor  xmm4,xmm5,XMMWORD PTR [rdi+0xb0]
    22f8:	00 
    22f9:	c5 31 ef ce          	vpxor  xmm9,xmm9,xmm6
    22fd:	c4 41 31 ef cc       	vpxor  xmm9,xmm9,xmm12
    2302:	c4 63 71 44 dc 11    	vpclmulhqhqdq xmm11,xmm1,xmm4
    2308:	c4 e3 71 44 cc 00    	vpclmullqlqdq xmm1,xmm1,xmm4
    230e:	c5 fa 6f a6 f0 02 00 	vmovdqu xmm4,XMMWORD PTR [rsi+0x2f0]
    2315:	00 
    2316:	c5 d9 ef af c0 00 00 	vpxor  xmm5,xmm4,XMMWORD PTR [rdi+0xc0]
    231d:	00 
    231e:	c5 fa 6f a6 30 03 00 	vmovdqu xmm4,XMMWORD PTR [rsi+0x330]
    2325:	00 
    2326:	c5 d9 ef a7 d0 00 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rdi+0xd0]
    232d:	00 
    232e:	c4 c1 71 ef cb       	vpxor  xmm1,xmm1,xmm11
    2333:	c4 63 51 44 c4 11    	vpclmulhqhqdq xmm8,xmm5,xmm4
    2339:	c4 e3 51 44 ec 00    	vpclmullqlqdq xmm5,xmm5,xmm4
    233f:	c5 fa 6f a6 70 03 00 	vmovdqu xmm4,XMMWORD PTR [rsi+0x370]
    2346:	00 
    2347:	c5 59 ef 97 e0 00 00 	vpxor  xmm10,xmm4,XMMWORD PTR [rdi+0xe0]
    234e:	00 
    234f:	c5 fa 6f a6 b0 03 00 	vmovdqu xmm4,XMMWORD PTR [rsi+0x3b0]
    2356:	00 
    2357:	c5 d9 ef a7 f0 00 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rdi+0xf0]
    235e:	00 
    235f:	c5 f1 ef cd          	vpxor  xmm1,xmm1,xmm5
    2363:	c4 e3 29 44 c4 11    	vpclmulhqhqdq xmm0,xmm10,xmm4
    2369:	c4 e3 29 44 e4 00    	vpclmullqlqdq xmm4,xmm10,xmm4
    236f:	c5 f9 7f 44 24 e8    	vmovdqa XMMWORD PTR [rsp-0x18],xmm0
    2375:	c5 81 ef 44 24 d8    	vpxor  xmm0,xmm15,XMMWORD PTR [rsp-0x28]
    237b:	c5 39 ef c4          	vpxor  xmm8,xmm8,xmm4
    237f:	c5 39 ef 44 24 e8    	vpxor  xmm8,xmm8,XMMWORD PTR [rsp-0x18]
    2385:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
    2389:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
    238d:	c4 c1 79 ef c1       	vpxor  xmm0,xmm0,xmm9
    2392:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
    2396:	c4 c1 79 ef c0       	vpxor  xmm0,xmm0,xmm8
    239b:	c5 fa 7f 42 f0       	vmovdqu XMMWORD PTR [rdx-0x10],xmm0
    23a0:	48 39 f0             	cmp    rax,rsi
    23a3:	0f 85 5b fe ff ff    	jne    2204 <audit_xmm+0x4>
    23a9:	c3                   	ret    
    23aa:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

00000000000023b0 <audit_ymm>:
    23b0:	55                   	push   rbp
    23b1:	48 89 e5             	mov    rbp,rsp
    23b4:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    23b8:	c4 e2 7d 5a 3f       	vbroadcasti128 ymm7,XMMWORD PTR [rdi]
    23bd:	c4 e2 7d 5a 47 10    	vbroadcasti128 ymm0,XMMWORD PTR [rdi+0x10]
    23c3:	c5 c5 ef 3e          	vpxor  ymm7,ymm7,YMMWORD PTR [rsi]
    23c7:	c5 fd ef 46 40       	vpxor  ymm0,ymm0,YMMWORD PTR [rsi+0x40]
    23cc:	c4 62 7d 5a 47 20    	vbroadcasti128 ymm8,XMMWORD PTR [rdi+0x20]
    23d2:	c4 e2 7d 5a 4f 30    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x30]
    23d8:	c4 63 45 44 e0 11    	vpclmulhqhqdq ymm12,ymm7,ymm0
    23de:	c5 f5 ef 8e c0 00 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0xc0]
    23e5:	00 
    23e6:	c5 3d ef 86 80 00 00 	vpxor  ymm8,ymm8,YMMWORD PTR [rsi+0x80]
    23ed:	00 
    23ee:	c4 e3 45 44 f8 00    	vpclmullqlqdq ymm7,ymm7,ymm0
    23f4:	c4 e2 7d 5a 77 40    	vbroadcasti128 ymm6,XMMWORD PTR [rdi+0x40]
    23fa:	c5 cd ef b6 00 01 00 	vpxor  ymm6,ymm6,YMMWORD PTR [rsi+0x100]
    2401:	00 
    2402:	c4 e3 3d 44 c1 11    	vpclmulhqhqdq ymm0,ymm8,ymm1
    2408:	c4 e2 7d 5a 6f 60    	vbroadcasti128 ymm5,XMMWORD PTR [rdi+0x60]
    240e:	c5 d5 ef ae 80 01 00 	vpxor  ymm5,ymm5,YMMWORD PTR [rsi+0x180]
    2415:	00 
    2416:	c4 63 3d 44 c1 00    	vpclmullqlqdq ymm8,ymm8,ymm1
    241c:	c4 e2 7d 5a 4f 50    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x50]
    2422:	c5 f5 ef 8e 40 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x140]
    2429:	00 
    242a:	c4 e2 7d 5a 97 80 00 	vbroadcasti128 ymm2,XMMWORD PTR [rdi+0x80]
    2431:	00 00 
    2433:	c5 ed ef 96 00 02 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rsi+0x200]
    243a:	00 
    243b:	c4 63 4d 44 d1 11    	vpclmulhqhqdq ymm10,ymm6,ymm1
    2441:	c4 e3 4d 44 f1 00    	vpclmullqlqdq ymm6,ymm6,ymm1
    2447:	c4 e2 7d 5a 4f 70    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x70]
    244d:	c5 f5 ef 8e c0 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x1c0]
    2454:	00 
    2455:	c5 1d ef e7          	vpxor  ymm12,ymm12,ymm7
    2459:	c4 63 55 44 f9 11    	vpclmulhqhqdq ymm15,ymm5,ymm1
    245f:	c5 fd 7f 44 24 e0    	vmovdqa YMMWORD PTR [rsp-0x20],ymm0
    2465:	c4 e3 55 44 e9 00    	vpclmullqlqdq ymm5,ymm5,ymm1
    246b:	c4 e2 7d 5a 8f 90 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x90]
    2472:	00 00 
    2474:	c5 f5 ef 8e 40 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x240]
    247b:	00 
    247c:	c4 e2 7d 5a a7 a0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xa0]
    2483:	00 00 
    2485:	c5 dd ef a6 80 02 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x280]
    248c:	00 
    248d:	c4 63 6d 44 f1 11    	vpclmulhqhqdq ymm14,ymm2,ymm1
    2493:	c4 e2 7d 5a 9f c0 00 	vbroadcasti128 ymm3,XMMWORD PTR [rdi+0xc0]
    249a:	00 00 
    249c:	c5 e5 ef 9e 00 03 00 	vpxor  ymm3,ymm3,YMMWORD PTR [rsi+0x300]
    24a3:	00 
    24a4:	c4 e3 6d 44 d1 00    	vpclmullqlqdq ymm2,ymm2,ymm1
    24aa:	c5 2d ef d6          	vpxor  ymm10,ymm10,ymm6
    24ae:	c4 e2 7d 5a 8f b0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xb0]
    24b5:	00 00 
    24b7:	c5 f5 ef 8e c0 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x2c0]
    24be:	00 
    24bf:	c4 62 7d 5a 9f e0 00 	vbroadcasti128 ymm11,XMMWORD PTR [rdi+0xe0]
    24c6:	00 00 
    24c8:	c5 25 ef 9e 80 03 00 	vpxor  ymm11,ymm11,YMMWORD PTR [rsi+0x380]
    24cf:	00 
    24d0:	c4 63 5d 44 c9 11    	vpclmulhqhqdq ymm9,ymm4,ymm1
    24d6:	c4 e3 5d 44 e1 00    	vpclmullqlqdq ymm4,ymm4,ymm1
    24dc:	c5 2d ef d5          	vpxor  ymm10,ymm10,ymm5
    24e0:	c4 e2 7d 5a 8f d0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xd0]
    24e7:	00 00 
    24e9:	c5 f5 ef 8e 40 03 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x340]
    24f0:	00 
    24f1:	c4 63 65 44 e9 11    	vpclmulhqhqdq ymm13,ymm3,ymm1
    24f7:	c4 e3 65 44 d9 00    	vpclmullqlqdq ymm3,ymm3,ymm1
    24fd:	c4 c1 6d ef d7       	vpxor  ymm2,ymm2,ymm15
    2502:	c4 e2 7d 5a 8f f0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xf0]
    2509:	00 00 
    250b:	c5 f5 ef 8e c0 03 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x3c0]
    2512:	00 
    2513:	c4 c1 6d ef d6       	vpxor  ymm2,ymm2,ymm14
    2518:	c4 e3 25 44 c1 11    	vpclmulhqhqdq ymm0,ymm11,ymm1
    251e:	c4 e3 25 44 c9 00    	vpclmullqlqdq ymm1,ymm11,ymm1
    2524:	c5 35 ef cc          	vpxor  ymm9,ymm9,ymm4
    2528:	c5 35 ef cb          	vpxor  ymm9,ymm9,ymm3
    252c:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    2532:	c5 bd ef 44 24 e0    	vpxor  ymm0,ymm8,YMMWORD PTR [rsp-0x20]
    2538:	c4 c1 75 ef cd       	vpxor  ymm1,ymm1,ymm13
    253d:	c5 f5 ef 4c 24 c0    	vpxor  ymm1,ymm1,YMMWORD PTR [rsp-0x40]
    2543:	c4 c1 7d ef c4       	vpxor  ymm0,ymm0,ymm12
    2548:	c4 c1 7d ef c2       	vpxor  ymm0,ymm0,ymm10
    254d:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
    2551:	c4 c1 7d ef c1       	vpxor  ymm0,ymm0,ymm9
    2556:	c5 fd ef c1          	vpxor  ymm0,ymm0,ymm1
    255a:	c5 fe 7f 02          	vmovdqu YMMWORD PTR [rdx],ymm0
    255e:	c4 e2 7d 5a 1f       	vbroadcasti128 ymm3,XMMWORD PTR [rdi]
    2563:	c4 e2 7d 5a 47 10    	vbroadcasti128 ymm0,XMMWORD PTR [rdi+0x10]
    2569:	c5 e5 ef 5e 20       	vpxor  ymm3,ymm3,YMMWORD PTR [rsi+0x20]
    256e:	c5 fd ef 46 60       	vpxor  ymm0,ymm0,YMMWORD PTR [rsi+0x60]
    2573:	c4 63 65 44 f0 11    	vpclmulhqhqdq ymm14,ymm3,ymm0
    2579:	c4 e3 65 44 d8 00    	vpclmullqlqdq ymm3,ymm3,ymm0
    257f:	c4 e2 7d 5a 47 20    	vbroadcasti128 ymm0,XMMWORD PTR [rdi+0x20]
    2585:	c5 fd ef 86 a0 00 00 	vpxor  ymm0,ymm0,YMMWORD PTR [rsi+0xa0]
    258c:	00 
    258d:	c4 e2 7d 5a 4f 30    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x30]
    2593:	c4 e2 7d 5a 57 40    	vbroadcasti128 ymm2,XMMWORD PTR [rdi+0x40]
    2599:	c5 f5 ef 8e e0 00 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0xe0]
    25a0:	00 
    25a1:	c4 e2 7d 5a 7f 60    	vbroadcasti128 ymm7,XMMWORD PTR [rdi+0x60]
    25a7:	c5 ed ef 96 20 01 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rsi+0x120]
    25ae:	00 
    25af:	c5 c5 ef be a0 01 00 	vpxor  ymm7,ymm7,YMMWORD PTR [rsi+0x1a0]
    25b6:	00 
    25b7:	c4 63 7d 44 f9 11    	vpclmulhqhqdq ymm15,ymm0,ymm1
    25bd:	c4 e2 7d 5a b7 80 00 	vbroadcasti128 ymm6,XMMWORD PTR [rdi+0x80]
    25c4:	00 00 
    25c6:	c5 cd ef b6 20 02 00 	vpxor  ymm6,ymm6,YMMWORD PTR [rsi+0x220]
    25cd:	00 
    25ce:	c4 e3 7d 44 c1 00    	vpclmullqlqdq ymm0,ymm0,ymm1
    25d4:	c4 e2 7d 5a 4f 50    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x50]
    25da:	c5 f5 ef 8e 60 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x160]
    25e1:	00 
    25e2:	c4 e2 7d 5a a7 b0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xb0]
    25e9:	00 00 
    25eb:	c5 dd ef a6 e0 02 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x2e0]
    25f2:	00 
    25f3:	c4 c1 65 ef de       	vpxor  ymm3,ymm3,ymm14
    25f8:	c4 63 6d 44 e9 11    	vpclmulhqhqdq ymm13,ymm2,ymm1
    25fe:	c4 e2 7d 5a af c0 00 	vbroadcasti128 ymm5,XMMWORD PTR [rdi+0xc0]
    2605:	00 00 
    2607:	c5 d5 ef ae 20 03 00 	vpxor  ymm5,ymm5,YMMWORD PTR [rsi+0x320]
    260e:	00 
    260f:	c4 e3 6d 44 d1 00    	vpclmullqlqdq ymm2,ymm2,ymm1
    2615:	c4 e2 7d 5a 4f 70    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x70]
    261b:	c5 f5 ef 8e e0 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x1e0]
    2622:	00 
    2623:	c4 63 45 44 c9 11    	vpclmulhqhqdq ymm9,ymm7,ymm1
    2629:	c4 e3 45 44 f9 00    	vpclmullqlqdq ymm7,ymm7,ymm1
    262f:	c5 fd 7f 44 24 e0    	vmovdqa YMMWORD PTR [rsp-0x20],ymm0
    2635:	c4 e2 7d 5a 8f 90 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x90]
    263c:	00 00 
    263e:	c5 f5 ef 8e 60 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x260]
    2645:	00 
    2646:	c4 63 4d 44 e1 11    	vpclmulhqhqdq ymm12,ymm6,ymm1
    264c:	c4 e3 4d 44 f1 00    	vpclmullqlqdq ymm6,ymm6,ymm1
    2652:	c4 c1 6d ef d5       	vpxor  ymm2,ymm2,ymm13
    2657:	c4 e2 7d 5a 8f a0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xa0]
    265e:	00 00 
    2660:	c5 f5 ef 8e a0 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x2a0]
    2667:	00 
    2668:	c4 63 75 44 dc 11    	vpclmulhqhqdq ymm11,ymm1,ymm4
    266e:	c4 e3 75 44 cc 00    	vpclmullqlqdq ymm1,ymm1,ymm4
    2674:	c5 ed ef d7          	vpxor  ymm2,ymm2,ymm7
    2678:	c4 e2 7d 5a a7 d0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xd0]
    267f:	00 00 
    2681:	c5 dd ef a6 60 03 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x360]
    2688:	00 
    2689:	c4 62 7d 5a 97 e0 00 	vbroadcasti128 ymm10,XMMWORD PTR [rdi+0xe0]
    2690:	00 00 
    2692:	c5 2d ef 96 a0 03 00 	vpxor  ymm10,ymm10,YMMWORD PTR [rsi+0x3a0]
    2699:	00 
    269a:	c4 63 55 44 c4 11    	vpclmulhqhqdq ymm8,ymm5,ymm4
    26a0:	c4 e3 55 44 ec 00    	vpclmullqlqdq ymm5,ymm5,ymm4
    26a6:	c5 35 ef ce          	vpxor  ymm9,ymm9,ymm6
    26aa:	c4 e2 7d 5a a7 f0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xf0]
    26b1:	00 00 
    26b3:	c5 dd ef a6 e0 03 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x3e0]
    26ba:	00 
    26bb:	c4 41 35 ef cc       	vpxor  ymm9,ymm9,ymm12
    26c0:	c4 e3 2d 44 c4 11    	vpclmulhqhqdq ymm0,ymm10,ymm4
    26c6:	c4 e3 2d 44 e4 00    	vpclmullqlqdq ymm4,ymm10,ymm4
    26cc:	c4 c1 75 ef cb       	vpxor  ymm1,ymm1,ymm11
    26d1:	c5 f5 ef cd          	vpxor  ymm1,ymm1,ymm5
    26d5:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
    26db:	c5 85 ef 44 24 e0    	vpxor  ymm0,ymm15,YMMWORD PTR [rsp-0x20]
    26e1:	c5 3d ef c4          	vpxor  ymm8,ymm8,ymm4
    26e5:	c5 3d ef 44 24 c0    	vpxor  ymm8,ymm8,YMMWORD PTR [rsp-0x40]
    26eb:	c5 fd ef c3          	vpxor  ymm0,ymm0,ymm3
    26ef:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
    26f3:	c4 c1 7d ef c1       	vpxor  ymm0,ymm0,ymm9
    26f8:	c5 fd ef c1          	vpxor  ymm0,ymm0,ymm1
    26fc:	c4 c1 7d ef c0       	vpxor  ymm0,ymm0,ymm8
    2701:	c5 fe 7f 42 20       	vmovdqu YMMWORD PTR [rdx+0x20],ymm0
    2706:	c5 f8 77             	vzeroupper 
    2709:	c9                   	leave  
    270a:	c3                   	ret    
    270b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000002710 <audit_zmm>:
    2710:	62 f2 7d 48 5a 07    	vbroadcasti32x4 zmm0,XMMWORD PTR [rdi]
    2716:	62 f2 7d 48 5a 4f 01 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x10]
    271d:	62 f1 7d 48 ef 06    	vpxord zmm0,zmm0,ZMMWORD PTR [rsi]
    2723:	62 f1 75 48 ef 4e 01 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x40]
    272a:	62 f2 7d 48 5a 7f 02 	vbroadcasti32x4 zmm7,XMMWORD PTR [rdi+0x20]
    2731:	62 f1 45 48 ef 7e 02 	vpxord zmm7,zmm7,ZMMWORD PTR [rsi+0x80]
    2738:	62 73 7d 48 44 f9 11 	vpclmulhqhqdq zmm15,zmm0,zmm1
    273f:	62 f2 7d 48 5a 67 04 	vbroadcasti32x4 zmm4,XMMWORD PTR [rdi+0x40]
    2746:	62 f1 5d 48 ef 66 04 	vpxord zmm4,zmm4,ZMMWORD PTR [rsi+0x100]
    274d:	62 f3 7d 48 44 c1 00 	vpclmullqlqdq zmm0,zmm0,zmm1
    2754:	62 f2 7d 48 5a 4f 03 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x30]
    275b:	62 f1 75 48 ef 4e 03 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0xc0]
    2762:	62 72 7d 48 5a 57 06 	vbroadcasti32x4 zmm10,XMMWORD PTR [rdi+0x60]
    2769:	62 71 2d 48 ef 56 06 	vpxord zmm10,zmm10,ZMMWORD PTR [rsi+0x180]
    2770:	62 73 45 48 44 f1 11 	vpclmulhqhqdq zmm14,zmm7,zmm1
    2777:	62 f2 7d 48 5a 57 09 	vbroadcasti32x4 zmm2,XMMWORD PTR [rdi+0x90]
    277e:	62 f1 6d 48 ef 56 09 	vpxord zmm2,zmm2,ZMMWORD PTR [rsi+0x240]
    2785:	62 f3 45 48 44 f9 00 	vpclmullqlqdq zmm7,zmm7,zmm1
    278c:	62 f2 7d 48 5a 4f 05 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x50]
    2793:	62 f1 75 48 ef 4e 05 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x140]
    279a:	62 f2 7d 48 5a 6f 0c 	vbroadcasti32x4 zmm5,XMMWORD PTR [rdi+0xc0]
    27a1:	62 f2 7d 48 5a 77 0d 	vbroadcasti32x4 zmm6,XMMWORD PTR [rdi+0xd0]
    27a8:	62 73 5d 48 44 e9 11 	vpclmulhqhqdq zmm13,zmm4,zmm1
    27af:	62 f1 55 48 ef 6e 0c 	vpxord zmm5,zmm5,ZMMWORD PTR [rsi+0x300]
    27b6:	62 f1 4d 48 ef 76 0d 	vpxord zmm6,zmm6,ZMMWORD PTR [rsi+0x340]
    27bd:	62 f3 5d 48 44 e1 00 	vpclmullqlqdq zmm4,zmm4,zmm1
    27c4:	62 f2 7d 48 5a 4f 07 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x70]
    27cb:	62 d1 7d 48 ef c7    	vpxord zmm0,zmm0,zmm15
    27d1:	62 f1 75 48 ef 4e 07 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x1c0]
    27d8:	62 73 55 48 44 c6 11 	vpclmulhqhqdq zmm8,zmm5,zmm6
    27df:	62 f3 2d 48 44 d9 11 	vpclmulhqhqdq zmm3,zmm10,zmm1
    27e6:	62 73 2d 48 44 d1 00 	vpclmullqlqdq zmm10,zmm10,zmm1
    27ed:	62 d1 45 48 ef fe    	vpxord zmm7,zmm7,zmm14
    27f3:	62 f2 7d 48 5a 4f 08 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x80]
    27fa:	62 f1 75 48 ef 4e 08 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x200]
    2801:	62 f3 55 48 44 f6 00 	vpclmullqlqdq zmm6,zmm5,zmm6
    2808:	62 f1 7d 48 ef c7    	vpxord zmm0,zmm0,zmm7
    280e:	62 f2 7d 48 5a 6f 0f 	vbroadcasti32x4 zmm5,XMMWORD PTR [rdi+0xf0]
    2815:	62 f1 55 48 ef 6e 0f 	vpxord zmm5,zmm5,ZMMWORD PTR [rsi+0x3c0]
    281c:	62 73 75 48 44 da 11 	vpclmulhqhqdq zmm11,zmm1,zmm2
    2823:	62 73 75 48 44 ca 00 	vpclmullqlqdq zmm9,zmm1,zmm2
    282a:	62 d1 5d 48 ef e5    	vpxord zmm4,zmm4,zmm13
    2830:	62 f2 7d 48 5a 57 0a 	vbroadcasti32x4 zmm2,XMMWORD PTR [rdi+0xa0]
    2837:	62 f1 6d 48 ef 56 0a 	vpxord zmm2,zmm2,ZMMWORD PTR [rsi+0x280]
    283e:	62 f2 7d 48 5a 4f 0b 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0xb0]
    2845:	62 f1 75 48 ef 4e 0b 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x2c0]
    284c:	62 73 6d 48 44 e1 11 	vpclmulhqhqdq zmm12,zmm2,zmm1
    2853:	62 d1 5d 48 ef e2    	vpxord zmm4,zmm4,zmm10
    2859:	62 f3 6d 48 44 d1 00 	vpclmullqlqdq zmm2,zmm2,zmm1
    2860:	62 f1 7d 48 ef c4    	vpxord zmm0,zmm0,zmm4
    2866:	62 f2 7d 48 5a 4f 0e 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0xe0]
    286d:	62 f1 75 48 ef 4e 0e 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x380]
    2874:	62 e3 75 48 44 c5 11 	vpclmulhqhqdq zmm16,zmm1,zmm5
    287b:	62 d1 65 48 ef d9    	vpxord zmm3,zmm3,zmm9
    2881:	62 f3 75 48 44 cd 00 	vpclmullqlqdq zmm1,zmm1,zmm5
    2888:	62 d1 65 48 ef db    	vpxord zmm3,zmm3,zmm11
    288e:	62 f1 7d 48 ef c3    	vpxord zmm0,zmm0,zmm3
    2894:	62 d1 6d 48 ef d4    	vpxord zmm2,zmm2,zmm12
    289a:	62 f1 6d 48 ef d6    	vpxord zmm2,zmm2,zmm6
    28a0:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
    28a6:	62 f1 3d 48 ef c9    	vpxord zmm1,zmm8,zmm1
    28ac:	62 b1 75 48 ef c8    	vpxord zmm1,zmm1,zmm16
    28b2:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
    28b8:	62 f1 fe 48 7f 02    	vmovdqu64 ZMMWORD PTR [rdx],zmm0
    28be:	c5 f8 77             	vzeroupper 
    28c1:	c3                   	ret    
    28c2:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
    28c9:	00 00 00 00 
    28cd:	0f 1f 00             	nop    DWORD PTR [rax]

00000000000028d0 <audit_hash>:
    28d0:	41 57                	push   r15
    28d2:	49 89 d0             	mov    r8,rdx
    28d5:	41 56                	push   r14
    28d7:	41 55                	push   r13
    28d9:	41 54                	push   r12
    28db:	55                   	push   rbp
    28dc:	53                   	push   rbx
    28dd:	48 81 ec 88 00 00 00 	sub    rsp,0x88
    28e4:	48 89 7c 24 08       	mov    QWORD PTR [rsp+0x8],rdi
    28e9:	48 89 74 24 20       	mov    QWORD PTR [rsp+0x20],rsi
    28ee:	8b 05 00 00 00 00    	mov    eax,DWORD PTR [rip+0x0]        # 28f4 <audit_hash+0x24>
    28f4:	89 44 24 14          	mov    DWORD PTR [rsp+0x14],eax
    28f8:	85 c0                	test   eax,eax
    28fa:	0f 88 a0 07 00 00    	js     30a0 <audit_hash+0x7d0>
    2900:	8b 05 00 00 00 00    	mov    eax,DWORD PTR [rip+0x0]        # 2906 <audit_hash+0x36>
    2906:	4d 89 c5             	mov    r13,r8
    2909:	41 81 e5 ff 03 00 00 	and    r13d,0x3ff
    2910:	89 c2                	mov    edx,eax
    2912:	85 c0                	test   eax,eax
    2914:	0f 88 c1 06 00 00    	js     2fdb <audit_hash+0x70b>
    291a:	8b 5c 24 14          	mov    ebx,DWORD PTR [rsp+0x14]
    291e:	85 db                	test   ebx,ebx
    2920:	0f 85 f7 02 00 00    	jne    2c1d <audit_hash+0x34d>
    2926:	49 81 f8 ff 03 00 00 	cmp    r8,0x3ff
    292d:	0f 87 fa 07 00 00    	ja     312d <audit_hash+0x85d>
    2933:	49 8d 45 c0          	lea    rax,[r13-0x40]
    2937:	c7 44 24 34 00 00 00 	mov    DWORD PTR [rsp+0x34],0x0
    293e:	00 
    293f:	66 0f ef c0          	pxor   xmm0,xmm0
    2943:	41 bc 04 00 00 00    	mov    r12d,0x4
    2949:	48 89 44 24 28       	mov    QWORD PTR [rsp+0x28],rax
    294e:	4c 89 44 24 38       	mov    QWORD PTR [rsp+0x38],r8
    2953:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
    2958:	0f 29 44 24 50       	movaps XMMWORD PTR [rsp+0x50],xmm0
    295d:	0f 29 44 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm0
    2962:	0f 29 44 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm0
    2967:	8b 44 24 34          	mov    eax,DWORD PTR [rsp+0x34]
    296b:	48 8d 5c 24 40       	lea    rbx,[rsp+0x40]
    2970:	8d 2c 00             	lea    ebp,[rax+rax*1]
    2973:	41 8d 44 24 fe       	lea    eax,[r12-0x2]
    2978:	89 44 24 30          	mov    DWORD PTR [rsp+0x30],eax
    297c:	48 8b 7c 24 20       	mov    rdi,QWORD PTR [rsp+0x20]
    2981:	4c 8b 5c 24 28       	mov    r11,QWORD PTR [rsp+0x28]
    2986:	8d 04 ed 00 00 00 00 	lea    eax,[rbp*8+0x0]
    298d:	4d 89 e8             	mov    r8,r13
    2990:	44 8b 54 24 30       	mov    r10d,DWORD PTR [rsp+0x30]
    2995:	49 29 c0             	sub    r8,rax
    2998:	4c 8d 0c 07          	lea    r9,[rdi+rax*1]
    299c:	49 29 c3             	sub    r11,rax
    299f:	4c 89 e8             	mov    rax,r13
    29a2:	4c 29 c0             	sub    rax,r8
    29a5:	49 39 c5             	cmp    r13,rax
    29a8:	0f 86 8d 01 00 00    	jbe    2b3b <audit_hash+0x26b>
    29ae:	4c 89 e8             	mov    rax,r13
    29b1:	45 31 f6             	xor    r14d,r14d
    29b4:	4c 29 d8             	sub    rax,r11
    29b7:	49 39 c5             	cmp    r13,rax
    29ba:	0f 86 80 00 00 00    	jbe    2a40 <audit_hash+0x170>
    29c0:	49 83 fb 07          	cmp    r11,0x7
    29c4:	0f 87 e8 03 00 00    	ja     2db2 <audit_hash+0x4e2>
    29ca:	45 0f b6 71 40       	movzx  r14d,BYTE PTR [r9+0x40]
    29cf:	49 83 fb 01          	cmp    r11,0x1
    29d3:	76 6b                	jbe    2a40 <audit_hash+0x170>
    29d5:	41 0f b6 41 41       	movzx  eax,BYTE PTR [r9+0x41]
    29da:	48 c1 e0 08          	shl    rax,0x8
    29de:	49 09 c6             	or     r14,rax
    29e1:	49 83 fb 02          	cmp    r11,0x2
    29e5:	74 59                	je     2a40 <audit_hash+0x170>
    29e7:	41 0f b6 41 42       	movzx  eax,BYTE PTR [r9+0x42]
    29ec:	48 c1 e0 10          	shl    rax,0x10
    29f0:	49 09 c6             	or     r14,rax
    29f3:	49 83 fb 03          	cmp    r11,0x3
    29f7:	74 47                	je     2a40 <audit_hash+0x170>
    29f9:	41 0f b6 41 43       	movzx  eax,BYTE PTR [r9+0x43]
    29fe:	48 c1 e0 18          	shl    rax,0x18
    2a02:	49 09 c6             	or     r14,rax
    2a05:	49 83 fb 04          	cmp    r11,0x4
    2a09:	74 35                	je     2a40 <audit_hash+0x170>
    2a0b:	41 0f b6 41 44       	movzx  eax,BYTE PTR [r9+0x44]
    2a10:	48 c1 e0 20          	shl    rax,0x20
    2a14:	49 09 c6             	or     r14,rax
    2a17:	49 83 fb 05          	cmp    r11,0x5
    2a1b:	74 23                	je     2a40 <audit_hash+0x170>
    2a1d:	41 0f b6 41 45       	movzx  eax,BYTE PTR [r9+0x45]
    2a22:	48 c1 e0 28          	shl    rax,0x28
    2a26:	49 09 c6             	or     r14,rax
    2a29:	49 83 fb 07          	cmp    r11,0x7
    2a2d:	75 11                	jne    2a40 <audit_hash+0x170>
    2a2f:	41 0f b6 41 46       	movzx  eax,BYTE PTR [r9+0x46]
    2a34:	48 c1 e0 30          	shl    rax,0x30
    2a38:	49 09 c6             	or     r14,rax
    2a3b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    2a40:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
    2a45:	44 89 d2             	mov    edx,r10d
    2a48:	41 8d 42 fe          	lea    eax,[r10-0x2]
    2a4c:	4c 33 34 d7          	xor    r14,QWORD PTR [rdi+rdx*8]
    2a50:	49 83 f8 07          	cmp    r8,0x7
    2a54:	0f 87 50 03 00 00    	ja     2daa <audit_hash+0x4da>
    2a5a:	41 0f b6 39          	movzx  edi,BYTE PTR [r9]
    2a5e:	49 83 f8 01          	cmp    r8,0x1
    2a62:	76 66                	jbe    2aca <audit_hash+0x1fa>
    2a64:	41 0f b6 51 01       	movzx  edx,BYTE PTR [r9+0x1]
    2a69:	48 c1 e2 08          	shl    rdx,0x8
    2a6d:	48 09 d7             	or     rdi,rdx
    2a70:	49 83 f8 02          	cmp    r8,0x2
    2a74:	74 54                	je     2aca <audit_hash+0x1fa>
    2a76:	41 0f b6 51 02       	movzx  edx,BYTE PTR [r9+0x2]
    2a7b:	48 c1 e2 10          	shl    rdx,0x10
    2a7f:	48 09 d7             	or     rdi,rdx
    2a82:	49 83 f8 03          	cmp    r8,0x3
    2a86:	74 42                	je     2aca <audit_hash+0x1fa>
    2a88:	41 0f b6 51 03       	movzx  edx,BYTE PTR [r9+0x3]
    2a8d:	48 c1 e2 18          	shl    rdx,0x18
    2a91:	48 09 d7             	or     rdi,rdx
    2a94:	49 83 f8 04          	cmp    r8,0x4
    2a98:	74 30                	je     2aca <audit_hash+0x1fa>
    2a9a:	41 0f b6 51 04       	movzx  edx,BYTE PTR [r9+0x4]
    2a9f:	48 c1 e2 20          	shl    rdx,0x20
    2aa3:	48 09 d7             	or     rdi,rdx
    2aa6:	49 83 f8 05          	cmp    r8,0x5
    2aaa:	74 1e                	je     2aca <audit_hash+0x1fa>
    2aac:	41 0f b6 51 05       	movzx  edx,BYTE PTR [r9+0x5]
    2ab1:	48 c1 e2 28          	shl    rdx,0x28
    2ab5:	48 09 d7             	or     rdi,rdx
    2ab8:	49 83 f8 07          	cmp    r8,0x7
    2abc:	75 0c                	jne    2aca <audit_hash+0x1fa>
    2abe:	41 0f b6 51 06       	movzx  edx,BYTE PTR [r9+0x6]
    2ac3:	48 c1 e2 30          	shl    rdx,0x30
    2ac7:	48 09 d7             	or     rdi,rdx
    2aca:	48 8b 74 24 08       	mov    rsi,QWORD PTR [rsp+0x8]
    2acf:	8b 54 24 14          	mov    edx,DWORD PTR [rsp+0x14]
    2ad3:	48 33 3c c6          	xor    rdi,QWORD PTR [rsi+rax*8]
    2ad7:	85 d2                	test   edx,edx
    2ad9:	0f 85 b8 02 00 00    	jne    2d97 <audit_hash+0x4c7>
    2adf:	4c 89 44 24 18       	mov    QWORD PTR [rsp+0x18],r8
    2ae4:	45 31 ff             	xor    r15d,r15d
    2ae7:	31 d2                	xor    edx,edx
    2ae9:	31 c9                	xor    ecx,ecx
    2aeb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    2af0:	4c 89 f0             	mov    rax,r14
    2af3:	48 89 fe             	mov    rsi,rdi
    2af6:	48 d3 e8             	shr    rax,cl
    2af9:	48 d3 e6             	shl    rsi,cl
    2afc:	83 e0 01             	and    eax,0x1
    2aff:	48 f7 d8             	neg    rax
    2b02:	48 21 c6             	and    rsi,rax
    2b05:	48 31 f2             	xor    rdx,rsi
    2b08:	8d 71 01             	lea    esi,[rcx+0x1]
    2b0b:	85 c9                	test   ecx,ecx
    2b0d:	0f 84 7d 02 00 00    	je     2d90 <audit_hash+0x4c0>
    2b13:	b9 41 00 00 00       	mov    ecx,0x41
    2b18:	49 89 f8             	mov    r8,rdi
    2b1b:	29 f1                	sub    ecx,esi
    2b1d:	49 d3 e8             	shr    r8,cl
    2b20:	4c 21 c0             	and    rax,r8
    2b23:	49 31 c7             	xor    r15,rax
    2b26:	83 fe 40             	cmp    esi,0x40
    2b29:	0f 85 61 02 00 00    	jne    2d90 <audit_hash+0x4c0>
    2b2f:	4c 8b 44 24 18       	mov    r8,QWORD PTR [rsp+0x18]
    2b34:	48 31 13             	xor    QWORD PTR [rbx],rdx
    2b37:	4c 31 7b 08          	xor    QWORD PTR [rbx+0x8],r15
    2b3b:	41 83 c2 01          	add    r10d,0x1
    2b3f:	49 83 c1 08          	add    r9,0x8
    2b43:	49 83 e8 08          	sub    r8,0x8
    2b47:	49 83 eb 08          	sub    r11,0x8
    2b4b:	45 39 e2             	cmp    r10d,r12d
    2b4e:	0f 85 4b fe ff ff    	jne    299f <audit_hash+0xcf>
    2b54:	48 83 c3 10          	add    rbx,0x10
    2b58:	48 8d 84 24 80 00 00 	lea    rax,[rsp+0x80]
    2b5f:	00 
    2b60:	83 c5 02             	add    ebp,0x2
    2b63:	48 39 c3             	cmp    rbx,rax
    2b66:	0f 85 10 fe ff ff    	jne    297c <audit_hash+0xac>
    2b6c:	83 44 24 34 08       	add    DWORD PTR [rsp+0x34],0x8
    2b71:	45 8d 62 04          	lea    r12d,[r10+0x4]
    2b75:	41 83 fa 20          	cmp    r10d,0x20
    2b79:	0f 85 e8 fd ff ff    	jne    2967 <audit_hash+0x97>
    2b7f:	4d 8d 5d ff          	lea    r11,[r13-0x1]
    2b83:	4c 8b 44 24 38       	mov    r8,QWORD PTR [rsp+0x38]
    2b88:	8b 6c 24 14          	mov    ebp,DWORD PTR [rsp+0x14]
    2b8c:	45 31 d2             	xor    r10d,r10d
    2b8f:	49 c1 eb 04          	shr    r11,0x4
    2b93:	4c 8b 64 24 08       	mov    r12,QWORD PTR [rsp+0x8]
    2b98:	bb 01 00 00 00       	mov    ebx,0x1
    2b9d:	41 b9 41 00 00 00    	mov    r9d,0x41
    2ba3:	41 83 c3 01          	add    r11d,0x1
    2ba7:	b8 04 00 00 00       	mov    eax,0x4
    2bac:	49 83 fd 30          	cmp    r13,0x30
    2bb0:	77 09                	ja     2bbb <audit_hash+0x2eb>
    2bb2:	4d 85 ed             	test   r13,r13
    2bb5:	89 d8                	mov    eax,ebx
    2bb7:	41 0f 45 c3          	cmovne eax,r11d
    2bbb:	44 39 d0             	cmp    eax,r10d
    2bbe:	0f 86 f7 01 00 00    	jbe    2dbb <audit_hash+0x4eb>
    2bc4:	4d 8b b4 24 08 01 00 	mov    r14,QWORD PTR [r12+0x108]
    2bcb:	00 
    2bcc:	85 ed                	test   ebp,ebp
    2bce:	0f 85 bf 00 00 00    	jne    2c93 <audit_hash+0x3c3>
    2bd4:	31 ff                	xor    edi,edi
    2bd6:	31 f6                	xor    esi,esi
    2bd8:	31 c9                	xor    ecx,ecx
    2bda:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
    2be0:	4c 89 f0             	mov    rax,r14
    2be3:	4c 89 c2             	mov    rdx,r8
    2be6:	48 d3 e8             	shr    rax,cl
    2be9:	48 d3 e2             	shl    rdx,cl
    2bec:	83 e0 01             	and    eax,0x1
    2bef:	48 f7 d8             	neg    rax
    2bf2:	48 21 c2             	and    rdx,rax
    2bf5:	48 31 d6             	xor    rsi,rdx
    2bf8:	8d 51 01             	lea    edx,[rcx+0x1]
    2bfb:	85 c9                	test   ecx,ecx
    2bfd:	74 1a                	je     2c19 <audit_hash+0x349>
    2bff:	44 89 c9             	mov    ecx,r9d
    2c02:	4d 89 c7             	mov    r15,r8
    2c05:	29 d1                	sub    ecx,edx
    2c07:	49 d3 ef             	shr    r15,cl
    2c0a:	4c 21 f8             	and    rax,r15
    2c0d:	48 31 c7             	xor    rdi,rax
    2c10:	83 fa 40             	cmp    edx,0x40
    2c13:	0f 84 8b 00 00 00    	je     2ca4 <audit_hash+0x3d4>
    2c19:	89 d1                	mov    ecx,edx
    2c1b:	eb c3                	jmp    2be0 <audit_hash+0x310>
    2c1d:	83 f8 04             	cmp    eax,0x4
    2c20:	0f 84 44 01 00 00    	je     2d6a <audit_hash+0x49a>
    2c26:	8b 44 24 14          	mov    eax,DWORD PTR [rsp+0x14]
    2c2a:	85 c0                	test   eax,eax
    2c2c:	0f 8e 41 01 00 00    	jle    2d73 <audit_hash+0x4a3>
    2c32:	39 d0                	cmp    eax,edx
    2c34:	0f 8f 39 01 00 00    	jg     2d73 <audit_hash+0x4a3>
    2c3a:	49 81 f8 ff 03 00 00 	cmp    r8,0x3ff
    2c41:	0f 86 0d 05 00 00    	jbe    3154 <audit_hash+0x884>
    2c47:	83 f8 03             	cmp    eax,0x3
    2c4a:	0f 85 dd 04 00 00    	jne    312d <audit_hash+0x85d>
    2c50:	48 8b 74 24 20       	mov    rsi,QWORD PTR [rsp+0x20]
    2c55:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
    2c5a:	4c 89 c2             	mov    rdx,r8
    2c5d:	4c 89 c1             	mov    rcx,r8
    2c60:	48 c1 ea 0a          	shr    rdx,0xa
    2c64:	e8 17 de ff ff       	call   a80 <chv3_bulk512>
    2c69:	48 89 c1             	mov    rcx,rax
    2c6c:	4d 85 ed             	test   r13,r13
    2c6f:	0f 85 fb 04 00 00    	jne    3170 <audit_hash+0x8a0>
    2c75:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
    2c7a:	48 89 ce             	mov    rsi,rcx
    2c7d:	48 81 c4 88 00 00 00 	add    rsp,0x88
    2c84:	5b                   	pop    rbx
    2c85:	5d                   	pop    rbp
    2c86:	41 5c                	pop    r12
    2c88:	41 5d                	pop    r13
    2c8a:	41 5e                	pop    r14
    2c8c:	41 5f                	pop    r15
    2c8e:	e9 9d d3 ff ff       	jmp    30 <chv3_fastfinish>
    2c93:	4c 89 f6             	mov    rsi,r14
    2c96:	4c 89 c7             	mov    rdi,r8
    2c99:	e8 62 d3 ff ff       	call   0 <chv3_hwprod>
    2c9e:	48 89 c6             	mov    rsi,rax
    2ca1:	48 89 d7             	mov    rdi,rdx
    2ca4:	48 89 f8             	mov    rax,rdi
    2ca7:	48 89 fa             	mov    rdx,rdi
    2caa:	4d 89 d0             	mov    r8,r10
    2cad:	49 c1 e0 04          	shl    r8,0x4
    2cb1:	48 c1 ea 3d          	shr    rdx,0x3d
    2cb5:	48 c1 e8 3f          	shr    rax,0x3f
    2cb9:	4a 8b 4c 04 48       	mov    rcx,QWORD PTR [rsp+r8*1+0x48]
    2cbe:	4e 8b 7c 04 40       	mov    r15,QWORD PTR [rsp+r8*1+0x40]
    2cc3:	48 31 d0             	xor    rax,rdx
    2cc6:	48 89 fa             	mov    rdx,rdi
    2cc9:	48 c1 ea 3c          	shr    rdx,0x3c
    2ccd:	49 89 ce             	mov    r14,rcx
    2cd0:	49 31 cf             	xor    r15,rcx
    2cd3:	48 31 d0             	xor    rax,rdx
    2cd6:	48 89 ca             	mov    rdx,rcx
    2cd9:	49 c1 ee 3d          	shr    r14,0x3d
    2cdd:	4d 89 f8             	mov    r8,r15
    2ce0:	48 c1 ea 3f          	shr    rdx,0x3f
    2ce4:	4c 31 f2             	xor    rdx,r14
    2ce7:	49 89 ce             	mov    r14,rcx
    2cea:	49 c1 ee 3c          	shr    r14,0x3c
    2cee:	4c 31 f2             	xor    rdx,r14
    2cf1:	4c 8d 34 09          	lea    r14,[rcx+rcx*1]
    2cf5:	4d 31 f0             	xor    r8,r14
    2cf8:	4c 8d 34 cd 00 00 00 	lea    r14,[rcx*8+0x0]
    2cff:	00 
    2d00:	48 c1 e1 04          	shl    rcx,0x4
    2d04:	4d 31 f0             	xor    r8,r14
    2d07:	49 31 c8             	xor    r8,rcx
    2d0a:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
    2d0e:	49 31 d0             	xor    r8,rdx
    2d11:	49 31 c8             	xor    r8,rcx
    2d14:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
    2d1b:	00 
    2d1c:	48 c1 e2 04          	shl    rdx,0x4
    2d20:	49 31 c8             	xor    r8,rcx
    2d23:	49 31 d0             	xor    r8,rdx
    2d26:	48 8d 14 3f          	lea    rdx,[rdi+rdi*1]
    2d2a:	49 31 f0             	xor    r8,rsi
    2d2d:	49 31 f8             	xor    r8,rdi
    2d30:	49 31 d0             	xor    r8,rdx
    2d33:	48 8d 14 fd 00 00 00 	lea    rdx,[rdi*8+0x0]
    2d3a:	00 
    2d3b:	48 c1 e7 04          	shl    rdi,0x4
    2d3f:	49 31 d0             	xor    r8,rdx
    2d42:	48 8d 14 00          	lea    rdx,[rax+rax*1]
    2d46:	49 31 f8             	xor    r8,rdi
    2d49:	49 31 c0             	xor    r8,rax
    2d4c:	49 31 d0             	xor    r8,rdx
    2d4f:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
    2d56:	00 
    2d57:	48 c1 e0 04          	shl    rax,0x4
    2d5b:	49 31 d0             	xor    r8,rdx
    2d5e:	49 31 c0             	xor    r8,rax
    2d61:	49 83 c2 01          	add    r10,0x1
    2d65:	e9 3d fe ff ff       	jmp    2ba7 <audit_hash+0x2d7>
    2d6a:	83 fb 04             	cmp    ebx,0x4
    2d6d:	0f 84 b3 fb ff ff    	je     2926 <audit_hash+0x56>
    2d73:	b9 00 00 00 00       	mov    ecx,0x0
    2d78:	ba 98 01 00 00       	mov    edx,0x198
    2d7d:	be 00 00 00 00       	mov    esi,0x0
    2d82:	bf 00 00 00 00       	mov    edi,0x0
    2d87:	e8 00 00 00 00       	call   2d8c <audit_hash+0x4bc>
    2d8c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    2d90:	89 f1                	mov    ecx,esi
    2d92:	e9 59 fd ff ff       	jmp    2af0 <audit_hash+0x220>
    2d97:	4c 89 f6             	mov    rsi,r14
    2d9a:	e8 61 d2 ff ff       	call   0 <chv3_hwprod>
    2d9f:	49 89 d7             	mov    r15,rdx
    2da2:	48 89 c2             	mov    rdx,rax
    2da5:	e9 8a fd ff ff       	jmp    2b34 <audit_hash+0x264>
    2daa:	49 8b 39             	mov    rdi,QWORD PTR [r9]
    2dad:	e9 18 fd ff ff       	jmp    2aca <audit_hash+0x1fa>
    2db2:	4d 8b 71 40          	mov    r14,QWORD PTR [r9+0x40]
    2db6:	e9 85 fc ff ff       	jmp    2a40 <audit_hash+0x170>
    2dbb:	8b 44 24 14          	mov    eax,DWORD PTR [rsp+0x14]
    2dbf:	85 c0                	test   eax,eax
    2dc1:	0f 85 39 04 00 00    	jne    3200 <audit_hash+0x930>
    2dc7:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
    2dcc:	31 ff                	xor    edi,edi
    2dce:	31 f6                	xor    esi,esi
    2dd0:	31 c9                	xor    ecx,ecx
    2dd2:	41 b9 41 00 00 00    	mov    r9d,0x41
    2dd8:	4c 03 80 b8 01 00 00 	add    r8,QWORD PTR [rax+0x1b8]
    2ddf:	90                   	nop
    2de0:	4c 89 c0             	mov    rax,r8
    2de3:	4c 89 c2             	mov    rdx,r8
    2de6:	48 d3 e8             	shr    rax,cl
    2de9:	48 d3 e2             	shl    rdx,cl
    2dec:	83 e0 01             	and    eax,0x1
    2def:	48 f7 d8             	neg    rax
    2df2:	48 21 c2             	and    rdx,rax
    2df5:	48 31 d6             	xor    rsi,rdx
    2df8:	8d 51 01             	lea    edx,[rcx+0x1]
    2dfb:	85 c9                	test   ecx,ecx
    2dfd:	74 16                	je     2e15 <audit_hash+0x545>
    2dff:	44 89 c9             	mov    ecx,r9d
    2e02:	4c 89 c3             	mov    rbx,r8
    2e05:	29 d1                	sub    ecx,edx
    2e07:	48 d3 eb             	shr    rbx,cl
    2e0a:	48 21 d8             	and    rax,rbx
    2e0d:	48 31 c7             	xor    rdi,rax
    2e10:	83 fa 40             	cmp    edx,0x40
    2e13:	74 04                	je     2e19 <audit_hash+0x549>
    2e15:	89 d1                	mov    ecx,edx
    2e17:	eb c7                	jmp    2de0 <audit_hash+0x510>
    2e19:	48 89 f8             	mov    rax,rdi
    2e1c:	48 89 fa             	mov    rdx,rdi
    2e1f:	48 31 fe             	xor    rsi,rdi
    2e22:	45 31 c9             	xor    r9d,r9d
    2e25:	48 c1 ea 3c          	shr    rdx,0x3c
    2e29:	48 c1 e8 3d          	shr    rax,0x3d
    2e2d:	31 c9                	xor    ecx,ecx
    2e2f:	41 bb 41 00 00 00    	mov    r11d,0x41
    2e35:	48 31 d0             	xor    rax,rdx
    2e38:	48 8d 14 3f          	lea    rdx,[rdi+rdi*1]
    2e3c:	48 31 d6             	xor    rsi,rdx
    2e3f:	48 8d 14 fd 00 00 00 	lea    rdx,[rdi*8+0x0]
    2e46:	00 
    2e47:	48 c1 e7 04          	shl    rdi,0x4
    2e4b:	48 31 d6             	xor    rsi,rdx
    2e4e:	48 8d 14 00          	lea    rdx,[rax+rax*1]
    2e52:	48 31 fe             	xor    rsi,rdi
    2e55:	31 ff                	xor    edi,edi
    2e57:	48 31 c6             	xor    rsi,rax
    2e5a:	48 31 d6             	xor    rsi,rdx
    2e5d:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
    2e64:	00 
    2e65:	48 c1 e0 04          	shl    rax,0x4
    2e69:	48 31 d6             	xor    rsi,rdx
    2e6c:	48 31 c6             	xor    rsi,rax
    2e6f:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
    2e74:	4c 8b 90 98 01 00 00 	mov    r10,QWORD PTR [rax+0x198]
    2e7b:	4d 31 c2             	xor    r10,r8
    2e7e:	49 31 f2             	xor    r10,rsi
    2e81:	48 33 b0 90 01 00 00 	xor    rsi,QWORD PTR [rax+0x190]
    2e88:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
    2e8f:	00 
    2e90:	4c 89 d0             	mov    rax,r10
    2e93:	48 89 f2             	mov    rdx,rsi
    2e96:	48 d3 e8             	shr    rax,cl
    2e99:	48 d3 e2             	shl    rdx,cl
    2e9c:	83 e0 01             	and    eax,0x1
    2e9f:	48 f7 d8             	neg    rax
    2ea2:	48 21 c2             	and    rdx,rax
    2ea5:	48 31 d7             	xor    rdi,rdx
    2ea8:	8d 51 01             	lea    edx,[rcx+0x1]
    2eab:	85 c9                	test   ecx,ecx
    2ead:	74 16                	je     2ec5 <audit_hash+0x5f5>
    2eaf:	44 89 d9             	mov    ecx,r11d
    2eb2:	48 89 f3             	mov    rbx,rsi
    2eb5:	29 d1                	sub    ecx,edx
    2eb7:	48 d3 eb             	shr    rbx,cl
    2eba:	48 21 d8             	and    rax,rbx
    2ebd:	49 31 c1             	xor    r9,rax
    2ec0:	83 fa 40             	cmp    edx,0x40
    2ec3:	74 04                	je     2ec9 <audit_hash+0x5f9>
    2ec5:	89 d1                	mov    ecx,edx
    2ec7:	eb c7                	jmp    2e90 <audit_hash+0x5c0>
    2ec9:	48 8b 5c 24 08       	mov    rbx,QWORD PTR [rsp+0x8]
    2ece:	4c 89 c8             	mov    rax,r9
    2ed1:	4c 89 ca             	mov    rdx,r9
    2ed4:	31 c9                	xor    ecx,ecx
    2ed6:	48 c1 ea 3c          	shr    rdx,0x3c
    2eda:	48 c1 e8 3d          	shr    rax,0x3d
    2ede:	41 ba 41 00 00 00    	mov    r10d,0x41
    2ee4:	48 33 bb a8 01 00 00 	xor    rdi,QWORD PTR [rbx+0x1a8]
    2eeb:	48 31 d0             	xor    rax,rdx
    2eee:	4b 8d 14 09          	lea    rdx,[r9+r9*1]
    2ef2:	4c 33 83 a0 01 00 00 	xor    r8,QWORD PTR [rbx+0x1a0]
    2ef9:	48 89 fe             	mov    rsi,rdi
    2efc:	31 ff                	xor    edi,edi
    2efe:	4c 31 ce             	xor    rsi,r9
    2f01:	48 31 d6             	xor    rsi,rdx
    2f04:	4a 8d 14 cd 00 00 00 	lea    rdx,[r9*8+0x0]
    2f0b:	00 
    2f0c:	49 c1 e1 04          	shl    r9,0x4
    2f10:	48 31 d6             	xor    rsi,rdx
    2f13:	48 8d 14 00          	lea    rdx,[rax+rax*1]
    2f17:	4c 31 ce             	xor    rsi,r9
    2f1a:	45 31 c9             	xor    r9d,r9d
    2f1d:	48 31 c6             	xor    rsi,rax
    2f20:	48 31 d6             	xor    rsi,rdx
    2f23:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
    2f2a:	00 
    2f2b:	48 c1 e0 04          	shl    rax,0x4
    2f2f:	48 31 d6             	xor    rsi,rdx
    2f32:	48 31 c6             	xor    rsi,rax
    2f35:	0f 1f 00             	nop    DWORD PTR [rax]
    2f38:	48 89 f0             	mov    rax,rsi
    2f3b:	4c 89 c2             	mov    rdx,r8
    2f3e:	48 d3 e8             	shr    rax,cl
    2f41:	48 d3 e2             	shl    rdx,cl
    2f44:	83 e0 01             	and    eax,0x1
    2f47:	48 f7 d8             	neg    rax
    2f4a:	48 21 c2             	and    rdx,rax
    2f4d:	48 31 d7             	xor    rdi,rdx
    2f50:	8d 51 01             	lea    edx,[rcx+0x1]
    2f53:	85 c9                	test   ecx,ecx
    2f55:	74 16                	je     2f6d <audit_hash+0x69d>
    2f57:	44 89 d1             	mov    ecx,r10d
    2f5a:	4c 89 c3             	mov    rbx,r8
    2f5d:	29 d1                	sub    ecx,edx
    2f5f:	48 d3 eb             	shr    rbx,cl
    2f62:	48 21 d8             	and    rax,rbx
    2f65:	49 31 c1             	xor    r9,rax
    2f68:	83 fa 40             	cmp    edx,0x40
    2f6b:	74 04                	je     2f71 <audit_hash+0x6a1>
    2f6d:	89 d1                	mov    ecx,edx
    2f6f:	eb c7                	jmp    2f38 <audit_hash+0x668>
    2f71:	48 8b 5c 24 08       	mov    rbx,QWORD PTR [rsp+0x8]
    2f76:	4c 89 ca             	mov    rdx,r9
    2f79:	4c 89 c8             	mov    rax,r9
    2f7c:	4b 8d 0c 09          	lea    rcx,[r9+r9*1]
    2f80:	48 c1 e8 3c          	shr    rax,0x3c
    2f84:	48 c1 ea 3d          	shr    rdx,0x3d
    2f88:	48 31 c2             	xor    rdx,rax
    2f8b:	48 8b 83 b0 01 00 00 	mov    rax,QWORD PTR [rbx+0x1b0]
    2f92:	48 81 c4 88 00 00 00 	add    rsp,0x88
    2f99:	5b                   	pop    rbx
    2f9a:	5d                   	pop    rbp
    2f9b:	48 31 f8             	xor    rax,rdi
    2f9e:	41 5c                	pop    r12
    2fa0:	41 5d                	pop    r13
    2fa2:	4c 31 c8             	xor    rax,r9
    2fa5:	41 5e                	pop    r14
    2fa7:	41 5f                	pop    r15
    2fa9:	48 31 c8             	xor    rax,rcx
    2fac:	4a 8d 0c cd 00 00 00 	lea    rcx,[r9*8+0x0]
    2fb3:	00 
    2fb4:	49 c1 e1 04          	shl    r9,0x4
    2fb8:	48 31 c8             	xor    rax,rcx
    2fbb:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
    2fbf:	4c 31 c8             	xor    rax,r9
    2fc2:	48 31 d0             	xor    rax,rdx
    2fc5:	48 31 c8             	xor    rax,rcx
    2fc8:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
    2fcf:	00 
    2fd0:	48 c1 e2 04          	shl    rdx,0x4
    2fd4:	48 31 c8             	xor    rax,rcx
    2fd7:	48 31 d0             	xor    rax,rdx
    2fda:	c3                   	ret    
    2fdb:	31 f6                	xor    esi,esi
    2fdd:	89 f0                	mov    eax,esi
    2fdf:	0f a2                	cpuid  
    2fe1:	85 c0                	test   eax,eax
    2fe3:	0f 84 8f 00 00 00    	je     3078 <audit_hash+0x7a8>
    2fe9:	b8 01 00 00 00       	mov    eax,0x1
    2fee:	0f a2                	cpuid  
    2ff0:	81 e1 02 00 00 18    	and    ecx,0x18000002
    2ff6:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
    2ffc:	75 7a                	jne    3078 <audit_hash+0x7a8>
    2ffe:	89 f1                	mov    ecx,esi
    3000:	0f 01 d0             	xgetbv 
    3003:	89 c7                	mov    edi,eax
    3005:	83 e0 06             	and    eax,0x6
    3008:	83 f8 06             	cmp    eax,0x6
    300b:	75 6b                	jne    3078 <audit_hash+0x7a8>
    300d:	89 f0                	mov    eax,esi
    300f:	0f a2                	cpuid  
    3011:	83 f8 06             	cmp    eax,0x6
    3014:	0f 86 80 01 00 00    	jbe    319a <audit_hash+0x8ca>
    301a:	b8 07 00 00 00       	mov    eax,0x7
    301f:	89 f1                	mov    ecx,esi
    3021:	0f a2                	cpuid  
    3023:	f6 c3 20             	test   bl,0x20
    3026:	0f 84 6e 01 00 00    	je     319a <audit_hash+0x8ca>
    302c:	80 e5 04             	and    ch,0x4
    302f:	0f 84 65 01 00 00    	je     319a <audit_hash+0x8ca>
    3035:	81 e7 e6 00 00 00    	and    edi,0xe6
    303b:	81 ff e6 00 00 00    	cmp    edi,0xe6
    3041:	0f 85 85 01 00 00    	jne    31cc <audit_hash+0x8fc>
    3047:	81 e3 00 00 01 00    	and    ebx,0x10000
    304d:	0f 84 79 01 00 00    	je     31cc <audit_hash+0x8fc>
    3053:	c7 05 00 00 00 00 03 	mov    DWORD PTR [rip+0x0],0x3        # 305d <audit_hash+0x78d>
    305a:	00 00 00 
    305d:	ba 03 00 00 00       	mov    edx,0x3
    3062:	8b 7c 24 14          	mov    edi,DWORD PTR [rsp+0x14]
    3066:	85 ff                	test   edi,edi
    3068:	0f 85 b8 fb ff ff    	jne    2c26 <audit_hash+0x356>
    306e:	e9 b3 f8 ff ff       	jmp    2926 <audit_hash+0x56>
    3073:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    3078:	c7 05 00 00 00 00 00 	mov    DWORD PTR [rip+0x0],0x0        # 3082 <audit_hash+0x7b2>
    307f:	00 00 00 
    3082:	8b 4c 24 14          	mov    ecx,DWORD PTR [rsp+0x14]
    3086:	85 c9                	test   ecx,ecx
    3088:	0f 85 e5 fc ff ff    	jne    2d73 <audit_hash+0x4a3>
    308e:	49 81 f8 ff 03 00 00 	cmp    r8,0x3ff
    3095:	0f 86 98 f8 ff ff    	jbe    2933 <audit_hash+0x63>
    309b:	e9 8d 00 00 00       	jmp    312d <audit_hash+0x85d>
    30a0:	31 c0                	xor    eax,eax
    30a2:	0f a2                	cpuid  
    30a4:	31 ff                	xor    edi,edi
    30a6:	89 7c 24 14          	mov    DWORD PTR [rsp+0x14],edi
    30aa:	85 c0                	test   eax,eax
    30ac:	74 74                	je     3122 <audit_hash+0x852>
    30ae:	b8 01 00 00 00       	mov    eax,0x1
    30b3:	0f a2                	cpuid  
    30b5:	81 e1 02 00 00 18    	and    ecx,0x18000002
    30bb:	31 c0                	xor    eax,eax
    30bd:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
    30c3:	75 5d                	jne    3122 <audit_hash+0x852>
    30c5:	89 f9                	mov    ecx,edi
    30c7:	0f 01 d0             	xgetbv 
    30ca:	89 c2                	mov    edx,eax
    30cc:	89 c6                	mov    esi,eax
    30ce:	31 c0                	xor    eax,eax
    30d0:	83 e2 06             	and    edx,0x6
    30d3:	83 fa 06             	cmp    edx,0x6
    30d6:	75 4a                	jne    3122 <audit_hash+0x852>
    30d8:	0f a2                	cpuid  
    30da:	83 f8 06             	cmp    eax,0x6
    30dd:	0f 86 d7 00 00 00    	jbe    31ba <audit_hash+0x8ea>
    30e3:	b8 07 00 00 00       	mov    eax,0x7
    30e8:	89 f9                	mov    ecx,edi
    30ea:	0f a2                	cpuid  
    30ec:	f6 c3 20             	test   bl,0x20
    30ef:	0f 84 c5 00 00 00    	je     31ba <audit_hash+0x8ea>
    30f5:	80 e5 04             	and    ch,0x4
    30f8:	0f 84 bc 00 00 00    	je     31ba <audit_hash+0x8ea>
    30fe:	81 e6 e6 00 00 00    	and    esi,0xe6
    3104:	81 fe e6 00 00 00    	cmp    esi,0xe6
    310a:	0f 85 de 00 00 00    	jne    31ee <audit_hash+0x91e>
    3110:	81 e3 00 00 01 00    	and    ebx,0x10000
    3116:	83 fb 01             	cmp    ebx,0x1
    3119:	19 c0                	sbb    eax,eax
    311b:	83 c0 03             	add    eax,0x3
    311e:	89 44 24 14          	mov    DWORD PTR [rsp+0x14],eax
    3122:	89 05 00 00 00 00    	mov    DWORD PTR [rip+0x0],eax        # 3128 <audit_hash+0x858>
    3128:	e9 d3 f7 ff ff       	jmp    2900 <audit_hash+0x30>
    312d:	8b 4c 24 14          	mov    ecx,DWORD PTR [rsp+0x14]
    3131:	48 8b 74 24 20       	mov    rsi,QWORD PTR [rsp+0x20]
    3136:	4c 89 c2             	mov    rdx,r8
    3139:	48 8b 7c 24 08       	mov    rdi,QWORD PTR [rsp+0x8]
    313e:	48 81 c4 88 00 00 00 	add    rsp,0x88
    3145:	5b                   	pop    rbx
    3146:	5d                   	pop    rbp
    3147:	41 5c                	pop    r12
    3149:	41 5d                	pop    r13
    314b:	41 5e                	pop    r14
    314d:	41 5f                	pop    r15
    314f:	e9 0c dc ff ff       	jmp    d60 <chainhash_v3_evaluate.constprop.0>
    3154:	83 7c 24 14 03       	cmp    DWORD PTR [rsp+0x14],0x3
    3159:	0f 85 d4 f7 ff ff    	jne    2933 <audit_hash+0x63>
    315f:	48 8b 5c 24 08       	mov    rbx,QWORD PTR [rsp+0x8]
    3164:	4c 89 c1             	mov    rcx,r8
    3167:	eb 16                	jmp    317f <audit_hash+0x8af>
    3169:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    3170:	49 81 e0 00 fc ff ff 	and    r8,0xfffffffffffffc00
    3177:	4c 01 44 24 20       	add    QWORD PTR [rsp+0x20],r8
    317c:	48 89 fb             	mov    rbx,rdi
    317f:	48 8b 74 24 20       	mov    rsi,QWORD PTR [rsp+0x20]
    3184:	48 89 df             	mov    rdi,rbx
    3187:	4c 89 ea             	mov    rdx,r13
    318a:	e8 21 d6 ff ff       	call   7b0 <chv3_tail512>
    318f:	48 89 df             	mov    rdi,rbx
    3192:	48 89 c6             	mov    rsi,rax
    3195:	e9 e3 fa ff ff       	jmp    2c7d <audit_hash+0x3ad>
    319a:	c7 05 00 00 00 00 01 	mov    DWORD PTR [rip+0x0],0x1        # 31a4 <audit_hash+0x8d4>
    31a1:	00 00 00 
    31a4:	8b 74 24 14          	mov    esi,DWORD PTR [rsp+0x14]
    31a8:	85 f6                	test   esi,esi
    31aa:	0f 84 76 f7 ff ff    	je     2926 <audit_hash+0x56>
    31b0:	ba 01 00 00 00       	mov    edx,0x1
    31b5:	e9 6c fa ff ff       	jmp    2c26 <audit_hash+0x356>
    31ba:	c7 44 24 14 01 00 00 	mov    DWORD PTR [rsp+0x14],0x1
    31c1:	00 
    31c2:	b8 01 00 00 00       	mov    eax,0x1
    31c7:	e9 56 ff ff ff       	jmp    3122 <audit_hash+0x852>
    31cc:	c7 05 00 00 00 00 02 	mov    DWORD PTR [rip+0x0],0x2        # 31d6 <audit_hash+0x906>
    31d3:	00 00 00 
    31d6:	ba 02 00 00 00       	mov    edx,0x2
    31db:	44 8b 4c 24 14       	mov    r9d,DWORD PTR [rsp+0x14]
    31e0:	45 85 c9             	test   r9d,r9d
    31e3:	0f 85 3d fa ff ff    	jne    2c26 <audit_hash+0x356>
    31e9:	e9 38 f7 ff ff       	jmp    2926 <audit_hash+0x56>
    31ee:	c7 44 24 14 02 00 00 	mov    DWORD PTR [rsp+0x14],0x2
    31f5:	00 
    31f6:	b8 02 00 00 00       	mov    eax,0x2
    31fb:	e9 22 ff ff ff       	jmp    3122 <audit_hash+0x852>
    3200:	4c 89 c1             	mov    rcx,r8
    3203:	e9 6d fa ff ff       	jmp    2c75 <audit_hash+0x3a5>
