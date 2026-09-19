
bench/rdtsc:     file format elf64-x86-64


Disassembly of section .init:

0000000000401000 <_init>:
  401000:	f3 0f 1e fa          	endbr64 
  401004:	48 83 ec 08          	sub    rsp,0x8
  401008:	48 8b 05 e1 9f 00 00 	mov    rax,QWORD PTR [rip+0x9fe1]        # 40aff0 <__gmon_start__>
  40100f:	48 85 c0             	test   rax,rax
  401012:	74 02                	je     401016 <_init+0x16>
  401014:	ff d0                	call   rax
  401016:	48 83 c4 08          	add    rsp,0x8
  40101a:	c3                   	ret    

Disassembly of section .plt:

0000000000401020 <.plt>:
  401020:	ff 35 e2 9f 00 00    	push   QWORD PTR [rip+0x9fe2]        # 40b008 <_GLOBAL_OFFSET_TABLE_+0x8>
  401026:	ff 25 e4 9f 00 00    	jmp    QWORD PTR [rip+0x9fe4]        # 40b010 <_GLOBAL_OFFSET_TABLE_+0x10>
  40102c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401030 <free@plt>:
  401030:	ff 25 e2 9f 00 00    	jmp    QWORD PTR [rip+0x9fe2]        # 40b018 <free@GLIBC_2.2.5>
  401036:	68 00 00 00 00       	push   0x0
  40103b:	e9 e0 ff ff ff       	jmp    401020 <.plt>

0000000000401040 <puts@plt>:
  401040:	ff 25 da 9f 00 00    	jmp    QWORD PTR [rip+0x9fda]        # 40b020 <puts@GLIBC_2.2.5>
  401046:	68 01 00 00 00       	push   0x1
  40104b:	e9 d0 ff ff ff       	jmp    401020 <.plt>

0000000000401050 <printf@plt>:
  401050:	ff 25 d2 9f 00 00    	jmp    QWORD PTR [rip+0x9fd2]        # 40b028 <printf@GLIBC_2.2.5>
  401056:	68 02 00 00 00       	push   0x2
  40105b:	e9 c0 ff ff ff       	jmp    401020 <.plt>

0000000000401060 <__assert_fail@plt>:
  401060:	ff 25 ca 9f 00 00    	jmp    QWORD PTR [rip+0x9fca]        # 40b030 <__assert_fail@GLIBC_2.2.5>
  401066:	68 03 00 00 00       	push   0x3
  40106b:	e9 b0 ff ff ff       	jmp    401020 <.plt>

0000000000401070 <memcpy@plt>:
  401070:	ff 25 c2 9f 00 00    	jmp    QWORD PTR [rip+0x9fc2]        # 40b038 <memcpy@GLIBC_2.14>
  401076:	68 04 00 00 00       	push   0x4
  40107b:	e9 a0 ff ff ff       	jmp    401020 <.plt>

0000000000401080 <malloc@plt>:
  401080:	ff 25 ba 9f 00 00    	jmp    QWORD PTR [rip+0x9fba]        # 40b040 <malloc@GLIBC_2.2.5>
  401086:	68 05 00 00 00       	push   0x5
  40108b:	e9 90 ff ff ff       	jmp    401020 <.plt>

Disassembly of section .text:

0000000000401090 <main>:
  401090:	41 57                	push   r15
  401092:	bf 40 00 04 00       	mov    edi,0x40040
  401097:	41 56                	push   r14
  401099:	41 55                	push   r13
  40109b:	41 54                	push   r12
  40109d:	55                   	push   rbp
  40109e:	53                   	push   rbx
  40109f:	bb 28 90 40 00       	mov    ebx,0x409028
  4010a4:	48 81 ec 78 0a 00 00 	sub    rsp,0xa78
  4010ab:	e8 d0 ff ff ff       	call   401080 <malloc@plt>
  4010b0:	66 48 0f 6e c3       	movq   xmm0,rbx
  4010b5:	bb 3b 90 40 00       	mov    ebx,0x40903b
  4010ba:	48 c7 44 24 50 4e 90 	mov    QWORD PTR [rsp+0x50],0x40904e
  4010c1:	40 00 
  4010c3:	48 89 44 24 28       	mov    QWORD PTR [rsp+0x28],rax
  4010c8:	b8 2f 90 40 00       	mov    eax,0x40902f
  4010cd:	48 bf 2b 41 de 62 d4 	movabs rdi,0xb4dc9bd462de412b
  4010d4:	9b dc b4 
  4010d7:	4c 8d 9c 24 90 00 00 	lea    r11,[rsp+0x90]
  4010de:	00 
  4010df:	66 48 0f 3a 22 c0 01 	pinsrq xmm0,rax,0x1
  4010e6:	b8 47 90 40 00       	mov    eax,0x409047
  4010eb:	49 89 f9             	mov    r9,rdi
  4010ee:	48 c7 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],0x405ea0
  4010f5:	00 a0 5e 40 00 
  4010fa:	0f 29 44 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm0
  4010ff:	66 48 0f 6e c3       	movq   xmm0,rbx
  401104:	bb 80 37 40 00       	mov    ebx,0x403780
  401109:	41 ba 41 00 00 00    	mov    r10d,0x41
  40110f:	66 48 0f 3a 22 c0 01 	pinsrq xmm0,rax,0x1
  401116:	b8 b0 2e 40 00       	mov    eax,0x402eb0
  40111b:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
  401120:	66 48 0f 6e c3       	movq   xmm0,rbx
  401125:	bb a0 7d 40 00       	mov    ebx,0x407da0
  40112a:	66 48 0f 3a 22 c0 01 	pinsrq xmm0,rax,0x1
  401131:	b8 b0 55 40 00       	mov    eax,0x4055b0
  401136:	0f 29 44 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm0
  40113b:	66 48 0f 6e c3       	movq   xmm0,rbx
  401140:	48 8d 9c 24 90 01 00 	lea    rbx,[rsp+0x190]
  401147:	00 
  401148:	66 48 0f 3a 22 c0 01 	pinsrq xmm0,rax,0x1
  40114f:	0f 29 44 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm0
  401154:	49 89 3b             	mov    QWORD PTR [r11],rdi
  401157:	45 31 c0             	xor    r8d,r8d
  40115a:	31 f6                	xor    esi,esi
  40115c:	31 c9                	xor    ecx,ecx
  40115e:	66 90                	xchg   ax,ax
  401160:	4c 89 c8             	mov    rax,r9
  401163:	48 89 fa             	mov    rdx,rdi
  401166:	48 d3 e8             	shr    rax,cl
  401169:	48 d3 e2             	shl    rdx,cl
  40116c:	83 e0 01             	and    eax,0x1
  40116f:	48 f7 d8             	neg    rax
  401172:	48 21 c2             	and    rdx,rax
  401175:	48 31 d6             	xor    rsi,rdx
  401178:	8d 51 01             	lea    edx,[rcx+0x1]
  40117b:	85 c9                	test   ecx,ecx
  40117d:	74 16                	je     401195 <main+0x105>
  40117f:	44 89 d1             	mov    ecx,r10d
  401182:	49 89 ff             	mov    r15,rdi
  401185:	29 d1                	sub    ecx,edx
  401187:	49 d3 ef             	shr    r15,cl
  40118a:	4c 21 f8             	and    rax,r15
  40118d:	49 31 c0             	xor    r8,rax
  401190:	83 fa 40             	cmp    edx,0x40
  401193:	74 04                	je     401199 <main+0x109>
  401195:	89 d1                	mov    ecx,edx
  401197:	eb c7                	jmp    401160 <main+0xd0>
  401199:	4c 89 c7             	mov    rdi,r8
  40119c:	4c 89 c0             	mov    rax,r8
  40119f:	4b 8d 14 00          	lea    rdx,[r8+r8*1]
  4011a3:	49 83 c3 08          	add    r11,0x8
  4011a7:	48 c1 e8 3c          	shr    rax,0x3c
  4011ab:	48 c1 ef 3d          	shr    rdi,0x3d
  4011af:	48 31 c7             	xor    rdi,rax
  4011b2:	48 89 f0             	mov    rax,rsi
  4011b5:	4c 31 c0             	xor    rax,r8
  4011b8:	48 31 d0             	xor    rax,rdx
  4011bb:	4a 8d 14 c5 00 00 00 	lea    rdx,[r8*8+0x0]
  4011c2:	00 
  4011c3:	49 c1 e0 04          	shl    r8,0x4
  4011c7:	48 31 d0             	xor    rax,rdx
  4011ca:	48 8d 14 3f          	lea    rdx,[rdi+rdi*1]
  4011ce:	4c 31 c0             	xor    rax,r8
  4011d1:	48 31 f8             	xor    rax,rdi
  4011d4:	48 31 d0             	xor    rax,rdx
  4011d7:	48 8d 14 fd 00 00 00 	lea    rdx,[rdi*8+0x0]
  4011de:	00 
  4011df:	48 c1 e7 04          	shl    rdi,0x4
  4011e3:	48 31 d0             	xor    rax,rdx
  4011e6:	48 31 c7             	xor    rdi,rax
  4011e9:	4c 39 db             	cmp    rbx,r11
  4011ec:	0f 85 62 ff ff ff    	jne    401154 <main+0xc4>
  4011f2:	66 0f 6f 05 b6 7f 00 	movdqa xmm0,XMMWORD PTR [rip+0x7fb6]        # 4091b0 <__PRETTY_FUNCTION__.6+0x60>
  4011f9:	00 
  4011fa:	4c 8d 8c 24 20 07 00 	lea    r9,[rsp+0x720]
  401201:	00 
  401202:	48 b8 1e cd 58 8a e2 	movabs rax,0xfffc0ae28a58cd1e
  401209:	0a fc ff 
  40120c:	4c 8d 94 24 60 07 00 	lea    r10,[rsp+0x760]
  401213:	00 
  401214:	48 89 84 24 b8 01 00 	mov    QWORD PTR [rsp+0x1b8],rax
  40121b:	00 
  40121c:	bf 41 00 00 00       	mov    edi,0x41
  401221:	be 1b 00 00 00       	mov    esi,0x1b
  401226:	49 b8 7c b7 6f f0 e9 	movabs r8,0xfa023ce9f06fb77c
  40122d:	3c 02 fa 
  401230:	0f 11 84 24 98 01 00 	movups XMMWORD PTR [rsp+0x198],xmm0
  401237:	00 
  401238:	66 0f 6f 05 80 7f 00 	movdqa xmm0,XMMWORD PTR [rip+0x7f80]        # 4091c0 <__PRETTY_FUNCTION__.6+0x70>
  40123f:	00 
  401240:	0f 11 84 24 a8 01 00 	movups XMMWORD PTR [rsp+0x1a8],xmm0
  401247:	00 
  401248:	66 0f 6f 84 24 90 00 	movdqa xmm0,XMMWORD PTR [rsp+0x90]
  40124f:	00 00 
  401251:	66 0f 6f c8          	movdqa xmm1,xmm0
  401255:	66 0f 6d 84 24 a0 00 	punpckhqdq xmm0,XMMWORD PTR [rsp+0xa0]
  40125c:	00 00 
  40125e:	66 0f 6c 8c 24 a0 00 	punpcklqdq xmm1,XMMWORD PTR [rsp+0xa0]
  401265:	00 00 
  401267:	0f 29 84 24 30 06 00 	movaps XMMWORD PTR [rsp+0x630],xmm0
  40126e:	00 
  40126f:	66 0f 6f 84 24 b0 00 	movdqa xmm0,XMMWORD PTR [rsp+0xb0]
  401276:	00 00 
  401278:	0f 29 8c 24 20 06 00 	movaps XMMWORD PTR [rsp+0x620],xmm1
  40127f:	00 
  401280:	66 0f 6f c8          	movdqa xmm1,xmm0
  401284:	66 0f 6d 84 24 c0 00 	punpckhqdq xmm0,XMMWORD PTR [rsp+0xc0]
  40128b:	00 00 
  40128d:	66 0f 6c 8c 24 c0 00 	punpcklqdq xmm1,XMMWORD PTR [rsp+0xc0]
  401294:	00 00 
  401296:	0f 29 84 24 50 06 00 	movaps XMMWORD PTR [rsp+0x650],xmm0
  40129d:	00 
  40129e:	66 0f 6f 84 24 d0 00 	movdqa xmm0,XMMWORD PTR [rsp+0xd0]
  4012a5:	00 00 
  4012a7:	0f 29 8c 24 40 06 00 	movaps XMMWORD PTR [rsp+0x640],xmm1
  4012ae:	00 
  4012af:	66 0f 6f c8          	movdqa xmm1,xmm0
  4012b3:	66 0f 6d 84 24 e0 00 	punpckhqdq xmm0,XMMWORD PTR [rsp+0xe0]
  4012ba:	00 00 
  4012bc:	66 0f 6c 8c 24 e0 00 	punpcklqdq xmm1,XMMWORD PTR [rsp+0xe0]
  4012c3:	00 00 
  4012c5:	0f 29 84 24 70 06 00 	movaps XMMWORD PTR [rsp+0x670],xmm0
  4012cc:	00 
  4012cd:	66 0f 6f 84 24 f0 00 	movdqa xmm0,XMMWORD PTR [rsp+0xf0]
  4012d4:	00 00 
  4012d6:	0f 29 8c 24 60 06 00 	movaps XMMWORD PTR [rsp+0x660],xmm1
  4012dd:	00 
  4012de:	66 0f 6f c8          	movdqa xmm1,xmm0
  4012e2:	66 0f 6d 84 24 00 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x100]
  4012e9:	00 00 
  4012eb:	66 0f 6c 8c 24 00 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x100]
  4012f2:	00 00 
  4012f4:	0f 29 84 24 90 06 00 	movaps XMMWORD PTR [rsp+0x690],xmm0
  4012fb:	00 
  4012fc:	66 0f 6f 84 24 10 01 	movdqa xmm0,XMMWORD PTR [rsp+0x110]
  401303:	00 00 
  401305:	0f 29 8c 24 80 06 00 	movaps XMMWORD PTR [rsp+0x680],xmm1
  40130c:	00 
  40130d:	66 0f 6f c8          	movdqa xmm1,xmm0
  401311:	66 0f 6d 84 24 20 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x120]
  401318:	00 00 
  40131a:	66 0f 6c 8c 24 20 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x120]
  401321:	00 00 
  401323:	0f 29 84 24 b0 06 00 	movaps XMMWORD PTR [rsp+0x6b0],xmm0
  40132a:	00 
  40132b:	66 0f 6f 84 24 30 01 	movdqa xmm0,XMMWORD PTR [rsp+0x130]
  401332:	00 00 
  401334:	0f 29 8c 24 a0 06 00 	movaps XMMWORD PTR [rsp+0x6a0],xmm1
  40133b:	00 
  40133c:	66 0f 6f c8          	movdqa xmm1,xmm0
  401340:	66 0f 6c 8c 24 40 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x140]
  401347:	00 00 
  401349:	0f 29 8c 24 c0 06 00 	movaps XMMWORD PTR [rsp+0x6c0],xmm1
  401350:	00 
  401351:	66 0f 6d 84 24 40 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x140]
  401358:	00 00 
  40135a:	48 c7 84 24 20 07 00 	mov    QWORD PTR [rsp+0x720],0x1
  401361:	00 01 00 00 00 
  401366:	0f 29 84 24 d0 06 00 	movaps XMMWORD PTR [rsp+0x6d0],xmm0
  40136d:	00 
  40136e:	66 0f 6f 84 24 50 01 	movdqa xmm0,XMMWORD PTR [rsp+0x150]
  401375:	00 00 
  401377:	48 c7 84 24 68 07 00 	mov    QWORD PTR [rsp+0x768],0x1b
  40137e:	00 1b 00 00 00 
  401383:	66 0f 6f c8          	movdqa xmm1,xmm0
  401387:	66 0f 6d 84 24 60 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x160]
  40138e:	00 00 
  401390:	66 0f 6c 8c 24 60 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x160]
  401397:	00 00 
  401399:	0f 29 84 24 f0 06 00 	movaps XMMWORD PTR [rsp+0x6f0],xmm0
  4013a0:	00 
  4013a1:	66 0f 6f 84 24 70 01 	movdqa xmm0,XMMWORD PTR [rsp+0x170]
  4013a8:	00 00 
  4013aa:	0f 29 8c 24 e0 06 00 	movaps XMMWORD PTR [rsp+0x6e0],xmm1
  4013b1:	00 
  4013b2:	66 0f 6f c8          	movdqa xmm1,xmm0
  4013b6:	66 0f 6d 84 24 80 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x180]
  4013bd:	00 00 
  4013bf:	66 0f 6c 8c 24 80 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x180]
  4013c6:	00 00 
  4013c8:	0f 29 84 24 10 07 00 	movaps XMMWORD PTR [rsp+0x710],xmm0
  4013cf:	00 
  4013d0:	0f 29 8c 24 00 07 00 	movaps XMMWORD PTR [rsp+0x700],xmm1
  4013d7:	00 
  4013d8:	49 8b 19             	mov    rbx,QWORD PTR [r9]
  4013db:	31 ed                	xor    ebp,ebp
  4013dd:	45 31 db             	xor    r11d,r11d
  4013e0:	31 c9                	xor    ecx,ecx
  4013e2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  4013e8:	4c 89 c0             	mov    rax,r8
  4013eb:	48 89 da             	mov    rdx,rbx
  4013ee:	48 d3 e8             	shr    rax,cl
  4013f1:	48 d3 e2             	shl    rdx,cl
  4013f4:	83 e0 01             	and    eax,0x1
  4013f7:	48 f7 d8             	neg    rax
  4013fa:	48 21 c2             	and    rdx,rax
  4013fd:	49 31 d3             	xor    r11,rdx
  401400:	8d 51 01             	lea    edx,[rcx+0x1]
  401403:	85 c9                	test   ecx,ecx
  401405:	74 15                	je     40141c <main+0x38c>
  401407:	89 f9                	mov    ecx,edi
  401409:	49 89 df             	mov    r15,rbx
  40140c:	29 d1                	sub    ecx,edx
  40140e:	49 d3 ef             	shr    r15,cl
  401411:	4c 21 f8             	and    rax,r15
  401414:	48 31 c5             	xor    rbp,rax
  401417:	83 fa 40             	cmp    edx,0x40
  40141a:	74 04                	je     401420 <main+0x390>
  40141c:	89 d1                	mov    ecx,edx
  40141e:	eb c8                	jmp    4013e8 <main+0x358>
  401420:	48 89 e8             	mov    rax,rbp
  401423:	48 89 ea             	mov    rdx,rbp
  401426:	49 31 eb             	xor    r11,rbp
  401429:	31 db                	xor    ebx,ebx
  40142b:	48 c1 ea 3c          	shr    rdx,0x3c
  40142f:	48 c1 e8 3d          	shr    rax,0x3d
  401433:	31 c9                	xor    ecx,ecx
  401435:	48 31 d0             	xor    rax,rdx
  401438:	48 8d 54 2d 00       	lea    rdx,[rbp+rbp*1+0x0]
  40143d:	49 31 d3             	xor    r11,rdx
  401440:	48 8d 14 ed 00 00 00 	lea    rdx,[rbp*8+0x0]
  401447:	00 
  401448:	48 c1 e5 04          	shl    rbp,0x4
  40144c:	49 31 d3             	xor    r11,rdx
  40144f:	48 8d 14 00          	lea    rdx,[rax+rax*1]
  401453:	49 31 eb             	xor    r11,rbp
  401456:	31 ed                	xor    ebp,ebp
  401458:	49 31 c3             	xor    r11,rax
  40145b:	49 31 d3             	xor    r11,rdx
  40145e:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
  401465:	00 
  401466:	48 c1 e0 04          	shl    rax,0x4
  40146a:	49 31 d3             	xor    r11,rdx
  40146d:	49 31 c3             	xor    r11,rax
  401470:	4d 89 59 08          	mov    QWORD PTR [r9+0x8],r11
  401474:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  401478:	4c 89 d8             	mov    rax,r11
  40147b:	48 89 f2             	mov    rdx,rsi
  40147e:	48 d3 e8             	shr    rax,cl
  401481:	48 d3 e2             	shl    rdx,cl
  401484:	83 e0 01             	and    eax,0x1
  401487:	48 f7 d8             	neg    rax
  40148a:	48 21 c2             	and    rdx,rax
  40148d:	48 31 d3             	xor    rbx,rdx
  401490:	8d 51 01             	lea    edx,[rcx+0x1]
  401493:	85 c9                	test   ecx,ecx
  401495:	74 15                	je     4014ac <main+0x41c>
  401497:	89 f9                	mov    ecx,edi
  401499:	49 89 f7             	mov    r15,rsi
  40149c:	29 d1                	sub    ecx,edx
  40149e:	49 d3 ef             	shr    r15,cl
  4014a1:	4c 21 f8             	and    rax,r15
  4014a4:	48 31 c5             	xor    rbp,rax
  4014a7:	83 fa 40             	cmp    edx,0x40
  4014aa:	74 04                	je     4014b0 <main+0x420>
  4014ac:	89 d1                	mov    ecx,edx
  4014ae:	eb c8                	jmp    401478 <main+0x3e8>
  4014b0:	48 89 d8             	mov    rax,rbx
  4014b3:	48 8d 54 2d 00       	lea    rdx,[rbp+rbp*1+0x0]
  4014b8:	49 83 c1 08          	add    r9,0x8
  4014bc:	48 31 e8             	xor    rax,rbp
  4014bf:	48 31 d0             	xor    rax,rdx
  4014c2:	48 8d 14 ed 00 00 00 	lea    rdx,[rbp*8+0x0]
  4014c9:	00 
  4014ca:	48 c1 e5 04          	shl    rbp,0x4
  4014ce:	48 31 d0             	xor    rax,rdx
  4014d1:	48 31 e8             	xor    rax,rbp
  4014d4:	49 89 41 48          	mov    QWORD PTR [r9+0x48],rax
  4014d8:	4d 39 ca             	cmp    r10,r9
  4014db:	0f 85 f7 fe ff ff    	jne    4013d8 <main+0x348>
  4014e1:	48 8b 84 24 b8 01 00 	mov    rax,QWORD PTR [rsp+0x1b8]
  4014e8:	00 
  4014e9:	48 8d b4 24 20 06 00 	lea    rsi,[rsp+0x620]
  4014f0:	00 
  4014f1:	f3 0f 6f ac 24 98 01 	movdqu xmm5,XMMWORD PTR [rsp+0x198]
  4014f8:	00 00 
  4014fa:	48 8d bc 24 d0 01 00 	lea    rdi,[rsp+0x1d0]
  401501:	00 
  401502:	f3 0f 6f b4 24 a8 01 	movdqu xmm6,XMMWORD PTR [rsp+0x1a8]
  401509:	00 00 
  40150b:	48 89 74 24 20       	mov    QWORD PTR [rsp+0x20],rsi
  401510:	b9 38 00 00 00       	mov    ecx,0x38
  401515:	49 bb 15 7c 4a 7f b9 	movabs r11,0x9e3779b97f4a7c15
  40151c:	79 37 9e 
  40151f:	48 89 84 24 d0 07 00 	mov    QWORD PTR [rsp+0x7d0],rax
  401526:	00 
  401527:	48 b8 b1 df 91 4d 86 	movabs rax,0x7b7bbe864d91dfb1
  40152e:	be 7b 7b 
  401531:	49 ba b9 e5 e4 1c 6d 	movabs r10,0xbf58476d1ce4e5b9
  401538:	47 58 bf 
  40153b:	49 b9 eb 11 31 13 bb 	movabs r9,0x94d049bb133111eb
  401542:	49 d0 94 
  401545:	48 89 84 24 d8 07 00 	mov    QWORD PTR [rsp+0x7d8],rax
  40154c:	00 
  40154d:	49 b8 b8 67 dc 1e 45 	movabs r8,0xabb024451edc67b8
  401554:	24 b0 ab 
  401557:	0f 29 ac 24 b0 07 00 	movaps XMMWORD PTR [rsp+0x7b0],xmm5
  40155e:	00 
  40155f:	0f 29 b4 24 c0 07 00 	movaps XMMWORD PTR [rsp+0x7c0],xmm6
  401566:	00 
  401567:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  40156a:	bf 60 b6 40 00       	mov    edi,0x40b660
  40156f:	48 8d b4 24 d0 01 00 	lea    rsi,[rsp+0x1d0]
  401576:	00 
  401577:	b9 38 00 00 00       	mov    ecx,0x38
  40157c:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  40157f:	48 8d b4 24 d0 01 00 	lea    rsi,[rsp+0x1d0]
  401586:	00 
  401587:	b9 7b 00 00 00       	mov    ecx,0x7b
  40158c:	48 89 f7             	mov    rdi,rsi
  40158f:	4c 01 d9             	add    rcx,r11
  401592:	48 83 c7 08          	add    rdi,0x8
  401596:	48 89 ca             	mov    rdx,rcx
  401599:	48 c1 ea 1e          	shr    rdx,0x1e
  40159d:	48 31 ca             	xor    rdx,rcx
  4015a0:	49 0f af d2          	imul   rdx,r10
  4015a4:	48 89 d0             	mov    rax,rdx
  4015a7:	48 c1 e8 1b          	shr    rax,0x1b
  4015ab:	48 31 d0             	xor    rax,rdx
  4015ae:	49 0f af c1          	imul   rax,r9
  4015b2:	48 89 c2             	mov    rdx,rax
  4015b5:	48 c1 ea 1f          	shr    rdx,0x1f
  4015b9:	48 31 d0             	xor    rax,rdx
  4015bc:	48 89 47 f8          	mov    QWORD PTR [rdi-0x8],rax
  4015c0:	4c 39 c1             	cmp    rcx,r8
  4015c3:	75 ca                	jne    40158f <main+0x4ff>
  4015c5:	48 8b 7c 24 20       	mov    rdi,QWORD PTR [rsp+0x20]
  4015ca:	b9 89 00 00 00       	mov    ecx,0x89
  4015cf:	49 bb 15 7c 4a 7f b9 	movabs r11,0x9e3779b97f4a7c15
  4015d6:	79 37 9e 
  4015d9:	49 ba b9 e5 e4 1c 6d 	movabs r10,0xbf58476d1ce4e5b9
  4015e0:	47 58 bf 
  4015e3:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  4015e6:	bf 00 b2 40 00       	mov    edi,0x40b200
  4015eb:	48 8d b4 24 20 06 00 	lea    rsi,[rsp+0x620]
  4015f2:	00 
  4015f3:	b9 89 00 00 00       	mov    ecx,0x89
  4015f8:	49 b9 eb 11 31 13 bb 	movabs r9,0x94d049bb133111eb
  4015ff:	49 d0 94 
  401602:	48 89 74 24 20       	mov    QWORD PTR [rsp+0x20],rsi
  401607:	49 b8 d8 df ed 62 b5 	movabs r8,0x56e27eb562eddfd8
  40160e:	7e e2 56 
  401611:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  401614:	48 8d b4 24 d0 01 00 	lea    rsi,[rsp+0x1d0]
  40161b:	00 
  40161c:	b9 7b 00 00 00       	mov    ecx,0x7b
  401621:	48 89 f7             	mov    rdi,rsi
  401624:	4c 01 d9             	add    rcx,r11
  401627:	48 83 c7 08          	add    rdi,0x8
  40162b:	48 89 ca             	mov    rdx,rcx
  40162e:	48 c1 ea 1e          	shr    rdx,0x1e
  401632:	48 31 ca             	xor    rdx,rcx
  401635:	49 0f af d2          	imul   rdx,r10
  401639:	48 89 d0             	mov    rax,rdx
  40163c:	48 c1 e8 1b          	shr    rax,0x1b
  401640:	48 31 d0             	xor    rax,rdx
  401643:	49 0f af c1          	imul   rax,r9
  401647:	48 89 c2             	mov    rdx,rax
  40164a:	48 c1 ea 1f          	shr    rdx,0x1f
  40164e:	48 31 d0             	xor    rax,rdx
  401651:	48 89 47 f8          	mov    QWORD PTR [rdi-0x8],rax
  401655:	4c 39 c1             	cmp    rcx,r8
  401658:	75 ca                	jne    401624 <main+0x594>
  40165a:	48 8b 7c 24 20       	mov    rdi,QWORD PTR [rsp+0x20]
  40165f:	b9 29 00 00 00       	mov    ecx,0x29
  401664:	48 8b 44 24 28       	mov    rax,QWORD PTR [rsp+0x28]
  401669:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  40166c:	48 8d b4 24 20 06 00 	lea    rsi,[rsp+0x620]
  401673:	00 
  401674:	bf a0 b0 40 00       	mov    edi,0x40b0a0
  401679:	b9 29 00 00 00       	mov    ecx,0x29
  40167e:	48 89 74 24 20       	mov    QWORD PTR [rsp+0x20],rsi
  401683:	66 0f 6f 1d 15 7b 00 	movdqa xmm3,XMMWORD PTR [rip+0x7b15]        # 4091a0 <__PRETTY_FUNCTION__.6+0x50>
  40168a:	00 
  40168b:	48 8d 90 40 00 04 00 	lea    rdx,[rax+0x40040]
  401692:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  401695:	66 0f 6f 3d 43 7b 00 	movdqa xmm7,XMMWORD PTR [rip+0x7b43]        # 4091e0 <__PRETTY_FUNCTION__.6+0x90>
  40169c:	00 
  40169d:	66 44 0f 6f 05 2a 7b 	movdqa xmm8,XMMWORD PTR [rip+0x7b2a]        # 4091d0 <__PRETTY_FUNCTION__.6+0x80>
  4016a4:	00 00 
  4016a6:	66 0f 6f 15 42 7b 00 	movdqa xmm2,XMMWORD PTR [rip+0x7b42]        # 4091f0 <__PRETTY_FUNCTION__.6+0xa0>
  4016ad:	00 
  4016ae:	66 0f 6f 35 4a 7b 00 	movdqa xmm6,XMMWORD PTR [rip+0x7b4a]        # 409200 <__PRETTY_FUNCTION__.6+0xb0>
  4016b5:	00 
  4016b6:	66 0f 6f 2d 52 7b 00 	movdqa xmm5,XMMWORD PTR [rip+0x7b52]        # 409210 <__PRETTY_FUNCTION__.6+0xc0>
  4016bd:	00 
  4016be:	66 0f 6f 25 5a 7b 00 	movdqa xmm4,XMMWORD PTR [rip+0x7b5a]        # 409220 <__PRETTY_FUNCTION__.6+0xd0>
  4016c5:	00 
  4016c6:	66 0f 6f c3          	movdqa xmm0,xmm3
  4016ca:	66 0f 6f ca          	movdqa xmm1,xmm2
  4016ce:	48 83 c0 10          	add    rax,0x10
  4016d2:	66 44 0f 6f c8       	movdqa xmm9,xmm0
  4016d7:	66 0f db c8          	pand   xmm1,xmm0
  4016db:	66 41 0f fe d8       	paddd  xmm3,xmm8
  4016e0:	66 44 0f fe cf       	paddd  xmm9,xmm7
  4016e5:	66 44 0f db ca       	pand   xmm9,xmm2
  4016ea:	66 41 0f 38 2b c9    	packusdw xmm1,xmm9
  4016f0:	66 44 0f 6f c8       	movdqa xmm9,xmm0
  4016f5:	66 0f fe c5          	paddd  xmm0,xmm5
  4016f9:	66 44 0f fe ce       	paddd  xmm9,xmm6
  4016fe:	66 0f db c2          	pand   xmm0,xmm2
  401702:	66 0f db cc          	pand   xmm1,xmm4
  401706:	66 44 0f db ca       	pand   xmm9,xmm2
  40170b:	66 44 0f 38 2b c8    	packusdw xmm9,xmm0
  401711:	66 41 0f 6f c1       	movdqa xmm0,xmm9
  401716:	66 0f db c4          	pand   xmm0,xmm4
  40171a:	66 0f 67 c8          	packuswb xmm1,xmm0
  40171e:	66 0f 6f c1          	movdqa xmm0,xmm1
  401722:	66 0f fc c1          	paddb  xmm0,xmm1
  401726:	66 0f fc c0          	paddb  xmm0,xmm0
  40172a:	66 0f fc c0          	paddb  xmm0,xmm0
  40172e:	66 0f fc c0          	paddb  xmm0,xmm0
  401732:	66 0f fc c1          	paddb  xmm0,xmm1
  401736:	0f 11 40 f0          	movups XMMWORD PTR [rax-0x10],xmm0
  40173a:	48 39 d0             	cmp    rax,rdx
  40173d:	75 87                	jne    4016c6 <main+0x636>
  40173f:	bf f0 90 40 00       	mov    edi,0x4090f0
  401744:	e8 f7 f8 ff ff       	call   401040 <puts@plt>
  401749:	48 c7 44 24 08 00 00 	mov    QWORD PTR [rsp+0x8],0x0
  401750:	00 00 
  401752:	48 c7 44 24 10 00 00 	mov    QWORD PTR [rsp+0x10],0x0
  401759:	00 00 
  40175b:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  401760:	4c 8b 6c 24 28       	mov    r13,QWORD PTR [rsp+0x28]
  401765:	4c 8b 74 24 20       	mov    r14,QWORD PTR [rsp+0x20]
  40176a:	89 44 24 18          	mov    DWORD PTR [rsp+0x18],eax
  40176e:	49 01 c5             	add    r13,rax
  401771:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
  401776:	bd 10 00 00 00       	mov    ebp,0x10
  40177b:	31 db                	xor    ebx,ebx
  40177d:	4c 8b 64 04 60       	mov    r12,QWORD PTR [rsp+rax*1+0x60]
  401782:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  401788:	be 00 00 04 00       	mov    esi,0x40000
  40178d:	4c 89 ef             	mov    rdi,r13
  401790:	41 ff d4             	call   r12
  401793:	48 31 c3             	xor    rbx,rax
  401796:	83 ed 01             	sub    ebp,0x1
  401799:	75 ed                	jne    401788 <main+0x6f8>
  40179b:	0f ae e8             	lfence 
  40179e:	0f 31                	rdtsc  
  4017a0:	bd 00 02 00 00       	mov    ebp,0x200
  4017a5:	49 89 c7             	mov    r15,rax
  4017a8:	48 c1 e2 20          	shl    rdx,0x20
  4017ac:	49 09 d7             	or     r15,rdx
  4017af:	90                   	nop
  4017b0:	be 00 00 04 00       	mov    esi,0x40000
  4017b5:	4c 89 ef             	mov    rdi,r13
  4017b8:	41 ff d4             	call   r12
  4017bb:	48 31 c3             	xor    rbx,rax
  4017be:	83 ed 01             	sub    ebp,0x1
  4017c1:	75 ed                	jne    4017b0 <main+0x720>
  4017c3:	0f ae e8             	lfence 
  4017c6:	0f 31                	rdtsc  
  4017c8:	48 c1 e2 20          	shl    rdx,0x20
  4017cc:	48 89 1d bd 98 00 00 	mov    QWORD PTR [rip+0x98bd],rbx        # 40b090 <sink>
  4017d3:	48 09 d0             	or     rax,rdx
  4017d6:	4c 29 f8             	sub    rax,r15
  4017d9:	0f 88 5b 02 00 00    	js     401a3a <main+0x9aa>
  4017df:	66 0f ef c0          	pxor   xmm0,xmm0
  4017e3:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
  4017e8:	f2 0f 59 05 40 7a 00 	mulsd  xmm0,QWORD PTR [rip+0x7a40]        # 409230 <__PRETTY_FUNCTION__.6+0xe0>
  4017ef:	00 
  4017f0:	49 83 c6 08          	add    r14,0x8
  4017f4:	48 8d 84 24 38 06 00 	lea    rax,[rsp+0x638]
  4017fb:	00 
  4017fc:	f2 41 0f 11 46 f8    	movsd  QWORD PTR [r14-0x8],xmm0
  401802:	4c 39 f0             	cmp    rax,r14
  401805:	0f 85 66 ff ff ff    	jne    401771 <main+0x6e1>
  40180b:	f2 0f 10 84 24 28 06 	movsd  xmm0,QWORD PTR [rsp+0x628]
  401812:	00 00 
  401814:	f2 0f 10 8c 24 20 06 	movsd  xmm1,QWORD PTR [rsp+0x620]
  40181b:	00 00 
  40181d:	f2 0f 10 94 24 30 06 	movsd  xmm2,QWORD PTR [rsp+0x630]
  401824:	00 00 
  401826:	66 0f 2f c8          	comisd xmm1,xmm0
  40182a:	0f 86 28 02 00 00    	jbe    401a58 <main+0x9c8>
  401830:	66 0f 2f c2          	comisd xmm0,xmm2
  401834:	77 08                	ja     40183e <main+0x7ae>
  401836:	f2 0f 5d d1          	minsd  xmm2,xmm1
  40183a:	66 0f 28 c2          	movapd xmm0,xmm2
  40183e:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
  401843:	8b 54 24 18          	mov    edx,DWORD PTR [rsp+0x18]
  401847:	bf 55 90 40 00       	mov    edi,0x409055
  40184c:	f2 0f 10 0d e4 79 00 	movsd  xmm1,QWORD PTR [rip+0x79e4]        # 409238 <__PRETTY_FUNCTION__.6+0xe8>
  401853:	00 
  401854:	48 8b 74 04 30       	mov    rsi,QWORD PTR [rsp+rax*1+0x30]
  401859:	b8 02 00 00 00       	mov    eax,0x2
  40185e:	f2 0f 5e c8          	divsd  xmm1,xmm0
  401862:	e8 e9 f7 ff ff       	call   401050 <printf@plt>
  401867:	48 83 44 24 10 01    	add    QWORD PTR [rsp+0x10],0x1
  40186d:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  401872:	48 83 f8 08          	cmp    rax,0x8
  401876:	0f 85 df fe ff ff    	jne    40175b <main+0x6cb>
  40187c:	48 83 44 24 08 08    	add    QWORD PTR [rsp+0x8],0x8
  401882:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
  401887:	48 83 f8 28          	cmp    rax,0x28
  40188b:	0f 85 c1 fe ff ff    	jne    401752 <main+0x6c2>
  401891:	48 c7 44 24 10 00 00 	mov    QWORD PTR [rsp+0x10],0x0
  401898:	00 00 
  40189a:	bd 01 00 00 00       	mov    ebp,0x1
  40189f:	90                   	nop
  4018a0:	89 e8                	mov    eax,ebp
  4018a2:	89 6c 24 18          	mov    DWORD PTR [rsp+0x18],ebp
  4018a6:	4c 8b 7c 24 20       	mov    r15,QWORD PTR [rsp+0x20]
  4018ab:	83 e0 07             	and    eax,0x7
  4018ae:	89 44 24 1c          	mov    DWORD PTR [rsp+0x1c],eax
  4018b2:	41 89 c6             	mov    r14d,eax
  4018b5:	4c 03 74 24 28       	add    r14,QWORD PTR [rsp+0x28]
  4018ba:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  4018bf:	41 bc 10 00 00 00    	mov    r12d,0x10
  4018c5:	31 db                	xor    ebx,ebx
  4018c7:	4c 8b 6c 04 60       	mov    r13,QWORD PTR [rsp+rax*1+0x60]
  4018cc:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  4018d0:	48 89 ee             	mov    rsi,rbp
  4018d3:	4c 89 f7             	mov    rdi,r14
  4018d6:	41 ff d5             	call   r13
  4018d9:	48 31 c3             	xor    rbx,rax
  4018dc:	41 83 ec 01          	sub    r12d,0x1
  4018e0:	75 ee                	jne    4018d0 <main+0x840>
  4018e2:	0f ae e8             	lfence 
  4018e5:	0f 31                	rdtsc  
  4018e7:	41 bc 00 08 00 00    	mov    r12d,0x800
  4018ed:	48 c1 e2 20          	shl    rdx,0x20
  4018f1:	48 09 d0             	or     rax,rdx
  4018f4:	48 89 44 24 08       	mov    QWORD PTR [rsp+0x8],rax
  4018f9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  401900:	48 89 ee             	mov    rsi,rbp
  401903:	4c 89 f7             	mov    rdi,r14
  401906:	41 ff d5             	call   r13
  401909:	48 31 c3             	xor    rbx,rax
  40190c:	41 83 ec 01          	sub    r12d,0x1
  401910:	75 ee                	jne    401900 <main+0x870>
  401912:	0f ae e8             	lfence 
  401915:	0f 31                	rdtsc  
  401917:	48 c1 e2 20          	shl    rdx,0x20
  40191b:	48 89 1d 6e 97 00 00 	mov    QWORD PTR [rip+0x976e],rbx        # 40b090 <sink>
  401922:	48 09 d0             	or     rax,rdx
  401925:	48 2b 44 24 08       	sub    rax,QWORD PTR [rsp+0x8]
  40192a:	0f 88 d0 00 00 00    	js     401a00 <main+0x970>
  401930:	66 0f ef c0          	pxor   xmm0,xmm0
  401934:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
  401939:	f2 0f 59 05 ff 78 00 	mulsd  xmm0,QWORD PTR [rip+0x78ff]        # 409240 <__PRETTY_FUNCTION__.6+0xf0>
  401940:	00 
  401941:	49 83 c7 08          	add    r15,0x8
  401945:	48 8d 84 24 38 06 00 	lea    rax,[rsp+0x638]
  40194c:	00 
  40194d:	f2 41 0f 11 47 f8    	movsd  QWORD PTR [r15-0x8],xmm0
  401953:	49 39 c7             	cmp    r15,rax
  401956:	0f 85 5e ff ff ff    	jne    4018ba <main+0x82a>
  40195c:	f2 0f 10 84 24 28 06 	movsd  xmm0,QWORD PTR [rsp+0x628]
  401963:	00 00 
  401965:	f2 0f 10 8c 24 20 06 	movsd  xmm1,QWORD PTR [rsp+0x620]
  40196c:	00 00 
  40196e:	f2 0f 10 94 24 30 06 	movsd  xmm2,QWORD PTR [rsp+0x630]
  401975:	00 00 
  401977:	66 0f 2f c8          	comisd xmm1,xmm0
  40197b:	0f 86 9d 00 00 00    	jbe    401a1e <main+0x98e>
  401981:	66 0f 2f c2          	comisd xmm0,xmm2
  401985:	77 08                	ja     40198f <main+0x8ff>
  401987:	f2 0f 5d d1          	minsd  xmm2,xmm1
  40198b:	66 0f 28 c2          	movapd xmm0,xmm2
  40198f:	66 0f ef c9          	pxor   xmm1,xmm1
  401993:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  401998:	8b 4c 24 1c          	mov    ecx,DWORD PTR [rsp+0x1c]
  40199c:	bf 6d 90 40 00       	mov    edi,0x40906d
  4019a1:	f2 0f 2a cd          	cvtsi2sd xmm1,ebp
  4019a5:	8b 54 24 18          	mov    edx,DWORD PTR [rsp+0x18]
  4019a9:	48 83 c5 01          	add    rbp,0x1
  4019ad:	48 8b 74 04 30       	mov    rsi,QWORD PTR [rsp+rax*1+0x30]
  4019b2:	b8 02 00 00 00       	mov    eax,0x2
  4019b7:	f2 0f 5e c8          	divsd  xmm1,xmm0
  4019bb:	e8 90 f6 ff ff       	call   401050 <printf@plt>
  4019c0:	48 81 fd 01 01 00 00 	cmp    rbp,0x101
  4019c7:	0f 85 d3 fe ff ff    	jne    4018a0 <main+0x810>
  4019cd:	48 83 44 24 10 08    	add    QWORD PTR [rsp+0x10],0x8
  4019d3:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  4019d8:	48 83 f8 18          	cmp    rax,0x18
  4019dc:	0f 85 b8 fe ff ff    	jne    40189a <main+0x80a>
  4019e2:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
  4019e7:	e8 44 f6 ff ff       	call   401030 <free@plt>
  4019ec:	48 81 c4 78 0a 00 00 	add    rsp,0xa78
  4019f3:	31 c0                	xor    eax,eax
  4019f5:	5b                   	pop    rbx
  4019f6:	5d                   	pop    rbp
  4019f7:	41 5c                	pop    r12
  4019f9:	41 5d                	pop    r13
  4019fb:	41 5e                	pop    r14
  4019fd:	41 5f                	pop    r15
  4019ff:	c3                   	ret    
  401a00:	48 89 c2             	mov    rdx,rax
  401a03:	83 e0 01             	and    eax,0x1
  401a06:	66 0f ef c0          	pxor   xmm0,xmm0
  401a0a:	48 d1 ea             	shr    rdx,1
  401a0d:	48 09 c2             	or     rdx,rax
  401a10:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
  401a15:	f2 0f 58 c0          	addsd  xmm0,xmm0
  401a19:	e9 1b ff ff ff       	jmp    401939 <main+0x8a9>
  401a1e:	66 0f 2f ca          	comisd xmm1,xmm2
  401a22:	77 0d                	ja     401a31 <main+0x9a1>
  401a24:	f2 0f 5d d0          	minsd  xmm2,xmm0
  401a28:	66 0f 28 c2          	movapd xmm0,xmm2
  401a2c:	e9 5e ff ff ff       	jmp    40198f <main+0x8ff>
  401a31:	66 0f 28 c1          	movapd xmm0,xmm1
  401a35:	e9 55 ff ff ff       	jmp    40198f <main+0x8ff>
  401a3a:	48 89 c2             	mov    rdx,rax
  401a3d:	83 e0 01             	and    eax,0x1
  401a40:	66 0f ef c0          	pxor   xmm0,xmm0
  401a44:	48 d1 ea             	shr    rdx,1
  401a47:	48 09 c2             	or     rdx,rax
  401a4a:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
  401a4f:	f2 0f 58 c0          	addsd  xmm0,xmm0
  401a53:	e9 90 fd ff ff       	jmp    4017e8 <main+0x758>
  401a58:	66 0f 2f ca          	comisd xmm1,xmm2
  401a5c:	77 0d                	ja     401a6b <main+0x9db>
  401a5e:	f2 0f 5d d0          	minsd  xmm2,xmm0
  401a62:	66 0f 28 c2          	movapd xmm0,xmm2
  401a66:	e9 d3 fd ff ff       	jmp    40183e <main+0x7ae>
  401a6b:	66 0f 28 c1          	movapd xmm0,xmm1
  401a6f:	e9 ca fd ff ff       	jmp    40183e <main+0x7ae>
  401a74:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  401a7b:	00 00 00 
  401a7e:	66 90                	xchg   ax,ax

0000000000401a80 <_start>:
  401a80:	f3 0f 1e fa          	endbr64 
  401a84:	31 ed                	xor    ebp,ebp
  401a86:	49 89 d1             	mov    r9,rdx
  401a89:	5e                   	pop    rsi
  401a8a:	48 89 e2             	mov    rdx,rsp
  401a8d:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
  401a91:	50                   	push   rax
  401a92:	54                   	push   rsp
  401a93:	45 31 c0             	xor    r8d,r8d
  401a96:	31 c9                	xor    ecx,ecx
  401a98:	48 c7 c7 90 10 40 00 	mov    rdi,0x401090
  401a9f:	ff 15 3b 95 00 00    	call   QWORD PTR [rip+0x953b]        # 40afe0 <__libc_start_main@GLIBC_2.34>
  401aa5:	f4                   	hlt    
  401aa6:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  401aad:	00 00 00 

0000000000401ab0 <_dl_relocate_static_pie>:
  401ab0:	f3 0f 1e fa          	endbr64 
  401ab4:	c3                   	ret    
  401ab5:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  401abc:	00 00 00 
  401abf:	90                   	nop

0000000000401ac0 <deregister_tm_clones>:
  401ac0:	48 8d 3d 89 95 00 00 	lea    rdi,[rip+0x9589]        # 40b050 <__TMC_END__>
  401ac7:	48 8d 05 82 95 00 00 	lea    rax,[rip+0x9582]        # 40b050 <__TMC_END__>
  401ace:	48 39 f8             	cmp    rax,rdi
  401ad1:	74 15                	je     401ae8 <deregister_tm_clones+0x28>
  401ad3:	48 8b 05 0e 95 00 00 	mov    rax,QWORD PTR [rip+0x950e]        # 40afe8 <_ITM_deregisterTMCloneTable>
  401ada:	48 85 c0             	test   rax,rax
  401add:	74 09                	je     401ae8 <deregister_tm_clones+0x28>
  401adf:	ff e0                	jmp    rax
  401ae1:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  401ae8:	c3                   	ret    
  401ae9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000401af0 <register_tm_clones>:
  401af0:	48 8d 3d 59 95 00 00 	lea    rdi,[rip+0x9559]        # 40b050 <__TMC_END__>
  401af7:	48 8d 35 52 95 00 00 	lea    rsi,[rip+0x9552]        # 40b050 <__TMC_END__>
  401afe:	48 29 fe             	sub    rsi,rdi
  401b01:	48 89 f0             	mov    rax,rsi
  401b04:	48 c1 ee 3f          	shr    rsi,0x3f
  401b08:	48 c1 f8 03          	sar    rax,0x3
  401b0c:	48 01 c6             	add    rsi,rax
  401b0f:	48 d1 fe             	sar    rsi,1
  401b12:	74 14                	je     401b28 <register_tm_clones+0x38>
  401b14:	48 8b 05 dd 94 00 00 	mov    rax,QWORD PTR [rip+0x94dd]        # 40aff8 <_ITM_registerTMCloneTable>
  401b1b:	48 85 c0             	test   rax,rax
  401b1e:	74 08                	je     401b28 <register_tm_clones+0x38>
  401b20:	ff e0                	jmp    rax
  401b22:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  401b28:	c3                   	ret    
  401b29:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000401b30 <__do_global_dtors_aux>:
  401b30:	f3 0f 1e fa          	endbr64 
  401b34:	80 3d 25 95 00 00 00 	cmp    BYTE PTR [rip+0x9525],0x0        # 40b060 <completed.0>
  401b3b:	75 13                	jne    401b50 <__do_global_dtors_aux+0x20>
  401b3d:	55                   	push   rbp
  401b3e:	48 89 e5             	mov    rbp,rsp
  401b41:	e8 7a ff ff ff       	call   401ac0 <deregister_tm_clones>
  401b46:	c6 05 13 95 00 00 01 	mov    BYTE PTR [rip+0x9513],0x1        # 40b060 <completed.0>
  401b4d:	5d                   	pop    rbp
  401b4e:	c3                   	ret    
  401b4f:	90                   	nop
  401b50:	c3                   	ret    
  401b51:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  401b58:	00 00 00 00 
  401b5c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401b60 <frame_dummy>:
  401b60:	f3 0f 1e fa          	endbr64 
  401b64:	eb 8a                	jmp    401af0 <register_tm_clones>
  401b66:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  401b6d:	00 00 00 

0000000000401b70 <chv3_region512>:
  401b70:	62 f2 7d 48 5a 07    	vbroadcasti32x4 zmm0,XMMWORD PTR [rdi]
  401b76:	62 f2 7d 48 5a 4f 01 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x10]
  401b7d:	62 f1 7d 48 ef 06    	vpxord zmm0,zmm0,ZMMWORD PTR [rsi]
  401b83:	62 f1 75 48 ef 4e 01 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x40]
  401b8a:	62 f2 7d 48 5a 7f 02 	vbroadcasti32x4 zmm7,XMMWORD PTR [rdi+0x20]
  401b91:	62 f1 45 48 ef 7e 02 	vpxord zmm7,zmm7,ZMMWORD PTR [rsi+0x80]
  401b98:	62 73 7d 48 44 f9 11 	vpclmulhqhqdq zmm15,zmm0,zmm1
  401b9f:	62 f2 7d 48 5a 67 04 	vbroadcasti32x4 zmm4,XMMWORD PTR [rdi+0x40]
  401ba6:	62 f1 5d 48 ef 66 04 	vpxord zmm4,zmm4,ZMMWORD PTR [rsi+0x100]
  401bad:	62 f3 7d 48 44 c1 00 	vpclmullqlqdq zmm0,zmm0,zmm1
  401bb4:	62 f2 7d 48 5a 4f 03 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x30]
  401bbb:	62 f1 75 48 ef 4e 03 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0xc0]
  401bc2:	62 72 7d 48 5a 57 06 	vbroadcasti32x4 zmm10,XMMWORD PTR [rdi+0x60]
  401bc9:	62 71 2d 48 ef 56 06 	vpxord zmm10,zmm10,ZMMWORD PTR [rsi+0x180]
  401bd0:	62 73 45 48 44 f1 11 	vpclmulhqhqdq zmm14,zmm7,zmm1
  401bd7:	62 f2 7d 48 5a 57 09 	vbroadcasti32x4 zmm2,XMMWORD PTR [rdi+0x90]
  401bde:	62 f1 6d 48 ef 56 09 	vpxord zmm2,zmm2,ZMMWORD PTR [rsi+0x240]
  401be5:	62 f3 45 48 44 f9 00 	vpclmullqlqdq zmm7,zmm7,zmm1
  401bec:	62 f2 7d 48 5a 4f 05 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x50]
  401bf3:	62 f1 75 48 ef 4e 05 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x140]
  401bfa:	62 f2 7d 48 5a 6f 0c 	vbroadcasti32x4 zmm5,XMMWORD PTR [rdi+0xc0]
  401c01:	62 f2 7d 48 5a 77 0d 	vbroadcasti32x4 zmm6,XMMWORD PTR [rdi+0xd0]
  401c08:	62 73 5d 48 44 e9 11 	vpclmulhqhqdq zmm13,zmm4,zmm1
  401c0f:	62 f1 55 48 ef 6e 0c 	vpxord zmm5,zmm5,ZMMWORD PTR [rsi+0x300]
  401c16:	62 f1 4d 48 ef 76 0d 	vpxord zmm6,zmm6,ZMMWORD PTR [rsi+0x340]
  401c1d:	62 f3 5d 48 44 e1 00 	vpclmullqlqdq zmm4,zmm4,zmm1
  401c24:	62 f2 7d 48 5a 4f 07 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x70]
  401c2b:	62 d1 7d 48 ef c7    	vpxord zmm0,zmm0,zmm15
  401c31:	62 f1 75 48 ef 4e 07 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x1c0]
  401c38:	62 73 55 48 44 c6 11 	vpclmulhqhqdq zmm8,zmm5,zmm6
  401c3f:	62 f3 2d 48 44 d9 11 	vpclmulhqhqdq zmm3,zmm10,zmm1
  401c46:	62 73 2d 48 44 d1 00 	vpclmullqlqdq zmm10,zmm10,zmm1
  401c4d:	62 d1 45 48 ef fe    	vpxord zmm7,zmm7,zmm14
  401c53:	62 f2 7d 48 5a 4f 08 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0x80]
  401c5a:	62 f1 75 48 ef 4e 08 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x200]
  401c61:	62 f3 55 48 44 f6 00 	vpclmullqlqdq zmm6,zmm5,zmm6
  401c68:	62 f1 7d 48 ef c7    	vpxord zmm0,zmm0,zmm7
  401c6e:	62 f2 7d 48 5a 6f 0f 	vbroadcasti32x4 zmm5,XMMWORD PTR [rdi+0xf0]
  401c75:	62 f1 55 48 ef 6e 0f 	vpxord zmm5,zmm5,ZMMWORD PTR [rsi+0x3c0]
  401c7c:	62 73 75 48 44 da 11 	vpclmulhqhqdq zmm11,zmm1,zmm2
  401c83:	62 73 75 48 44 ca 00 	vpclmullqlqdq zmm9,zmm1,zmm2
  401c8a:	62 d1 5d 48 ef e5    	vpxord zmm4,zmm4,zmm13
  401c90:	62 f2 7d 48 5a 57 0a 	vbroadcasti32x4 zmm2,XMMWORD PTR [rdi+0xa0]
  401c97:	62 f1 6d 48 ef 56 0a 	vpxord zmm2,zmm2,ZMMWORD PTR [rsi+0x280]
  401c9e:	62 f2 7d 48 5a 4f 0b 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0xb0]
  401ca5:	62 f1 75 48 ef 4e 0b 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x2c0]
  401cac:	62 73 6d 48 44 e1 11 	vpclmulhqhqdq zmm12,zmm2,zmm1
  401cb3:	62 d1 5d 48 ef e2    	vpxord zmm4,zmm4,zmm10
  401cb9:	62 f3 6d 48 44 d1 00 	vpclmullqlqdq zmm2,zmm2,zmm1
  401cc0:	62 f1 7d 48 ef c4    	vpxord zmm0,zmm0,zmm4
  401cc6:	62 f2 7d 48 5a 4f 0e 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdi+0xe0]
  401ccd:	62 f1 75 48 ef 4e 0e 	vpxord zmm1,zmm1,ZMMWORD PTR [rsi+0x380]
  401cd4:	62 e3 75 48 44 c5 11 	vpclmulhqhqdq zmm16,zmm1,zmm5
  401cdb:	62 d1 65 48 ef d9    	vpxord zmm3,zmm3,zmm9
  401ce1:	62 f3 75 48 44 cd 00 	vpclmullqlqdq zmm1,zmm1,zmm5
  401ce8:	62 d1 65 48 ef db    	vpxord zmm3,zmm3,zmm11
  401cee:	62 f1 7d 48 ef c3    	vpxord zmm0,zmm0,zmm3
  401cf4:	62 d1 6d 48 ef d4    	vpxord zmm2,zmm2,zmm12
  401cfa:	62 f1 6d 48 ef d6    	vpxord zmm2,zmm2,zmm6
  401d00:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
  401d06:	62 f1 3d 48 ef c9    	vpxord zmm1,zmm8,zmm1
  401d0c:	62 b1 75 48 ef c8    	vpxord zmm1,zmm1,zmm16
  401d12:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
  401d18:	62 f1 fe 48 7f 02    	vmovdqu64 ZMMWORD PTR [rdx],zmm0
  401d1e:	c5 f8 77             	vzeroupper 
  401d21:	c3                   	ret    
  401d22:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  401d29:	00 00 00 00 
  401d2d:	0f 1f 00             	nop    DWORD PTR [rax]

0000000000401d30 <chv3_region256>:
  401d30:	55                   	push   rbp
  401d31:	48 89 e5             	mov    rbp,rsp
  401d34:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
  401d38:	c4 e2 7d 5a 3f       	vbroadcasti128 ymm7,XMMWORD PTR [rdi]
  401d3d:	c4 e2 7d 5a 47 10    	vbroadcasti128 ymm0,XMMWORD PTR [rdi+0x10]
  401d43:	c5 c5 ef 3e          	vpxor  ymm7,ymm7,YMMWORD PTR [rsi]
  401d47:	c5 fd ef 46 40       	vpxor  ymm0,ymm0,YMMWORD PTR [rsi+0x40]
  401d4c:	c4 62 7d 5a 47 20    	vbroadcasti128 ymm8,XMMWORD PTR [rdi+0x20]
  401d52:	c4 e2 7d 5a 4f 30    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x30]
  401d58:	c4 63 45 44 e0 11    	vpclmulhqhqdq ymm12,ymm7,ymm0
  401d5e:	c5 f5 ef 8e c0 00 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0xc0]
  401d65:	00 
  401d66:	c5 3d ef 86 80 00 00 	vpxor  ymm8,ymm8,YMMWORD PTR [rsi+0x80]
  401d6d:	00 
  401d6e:	c4 e3 45 44 f8 00    	vpclmullqlqdq ymm7,ymm7,ymm0
  401d74:	c4 e2 7d 5a 77 40    	vbroadcasti128 ymm6,XMMWORD PTR [rdi+0x40]
  401d7a:	c5 cd ef b6 00 01 00 	vpxor  ymm6,ymm6,YMMWORD PTR [rsi+0x100]
  401d81:	00 
  401d82:	c4 e3 3d 44 c1 11    	vpclmulhqhqdq ymm0,ymm8,ymm1
  401d88:	c4 e2 7d 5a 6f 60    	vbroadcasti128 ymm5,XMMWORD PTR [rdi+0x60]
  401d8e:	c5 d5 ef ae 80 01 00 	vpxor  ymm5,ymm5,YMMWORD PTR [rsi+0x180]
  401d95:	00 
  401d96:	c4 63 3d 44 c1 00    	vpclmullqlqdq ymm8,ymm8,ymm1
  401d9c:	c4 e2 7d 5a 4f 50    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x50]
  401da2:	c5 f5 ef 8e 40 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x140]
  401da9:	00 
  401daa:	c4 e2 7d 5a 97 80 00 	vbroadcasti128 ymm2,XMMWORD PTR [rdi+0x80]
  401db1:	00 00 
  401db3:	c5 ed ef 96 00 02 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rsi+0x200]
  401dba:	00 
  401dbb:	c4 63 4d 44 d1 11    	vpclmulhqhqdq ymm10,ymm6,ymm1
  401dc1:	c4 e3 4d 44 f1 00    	vpclmullqlqdq ymm6,ymm6,ymm1
  401dc7:	c4 e2 7d 5a 4f 70    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x70]
  401dcd:	c5 f5 ef 8e c0 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x1c0]
  401dd4:	00 
  401dd5:	c5 1d ef e7          	vpxor  ymm12,ymm12,ymm7
  401dd9:	c4 63 55 44 f9 11    	vpclmulhqhqdq ymm15,ymm5,ymm1
  401ddf:	c5 fd 7f 44 24 e0    	vmovdqa YMMWORD PTR [rsp-0x20],ymm0
  401de5:	c4 e3 55 44 e9 00    	vpclmullqlqdq ymm5,ymm5,ymm1
  401deb:	c4 e2 7d 5a 8f 90 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x90]
  401df2:	00 00 
  401df4:	c5 f5 ef 8e 40 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x240]
  401dfb:	00 
  401dfc:	c4 e2 7d 5a a7 a0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xa0]
  401e03:	00 00 
  401e05:	c5 dd ef a6 80 02 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x280]
  401e0c:	00 
  401e0d:	c4 63 6d 44 f1 11    	vpclmulhqhqdq ymm14,ymm2,ymm1
  401e13:	c4 e2 7d 5a 9f c0 00 	vbroadcasti128 ymm3,XMMWORD PTR [rdi+0xc0]
  401e1a:	00 00 
  401e1c:	c5 e5 ef 9e 00 03 00 	vpxor  ymm3,ymm3,YMMWORD PTR [rsi+0x300]
  401e23:	00 
  401e24:	c4 e3 6d 44 d1 00    	vpclmullqlqdq ymm2,ymm2,ymm1
  401e2a:	c5 2d ef d6          	vpxor  ymm10,ymm10,ymm6
  401e2e:	c4 e2 7d 5a 8f b0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xb0]
  401e35:	00 00 
  401e37:	c5 f5 ef 8e c0 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x2c0]
  401e3e:	00 
  401e3f:	c4 62 7d 5a 9f e0 00 	vbroadcasti128 ymm11,XMMWORD PTR [rdi+0xe0]
  401e46:	00 00 
  401e48:	c5 25 ef 9e 80 03 00 	vpxor  ymm11,ymm11,YMMWORD PTR [rsi+0x380]
  401e4f:	00 
  401e50:	c4 63 5d 44 c9 11    	vpclmulhqhqdq ymm9,ymm4,ymm1
  401e56:	c4 e3 5d 44 e1 00    	vpclmullqlqdq ymm4,ymm4,ymm1
  401e5c:	c5 2d ef d5          	vpxor  ymm10,ymm10,ymm5
  401e60:	c4 e2 7d 5a 8f d0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xd0]
  401e67:	00 00 
  401e69:	c5 f5 ef 8e 40 03 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x340]
  401e70:	00 
  401e71:	c4 63 65 44 e9 11    	vpclmulhqhqdq ymm13,ymm3,ymm1
  401e77:	c4 e3 65 44 d9 00    	vpclmullqlqdq ymm3,ymm3,ymm1
  401e7d:	c4 c1 6d ef d7       	vpxor  ymm2,ymm2,ymm15
  401e82:	c4 e2 7d 5a 8f f0 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0xf0]
  401e89:	00 00 
  401e8b:	c5 f5 ef 8e c0 03 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x3c0]
  401e92:	00 
  401e93:	c4 c1 6d ef d6       	vpxor  ymm2,ymm2,ymm14
  401e98:	c4 e3 25 44 c1 11    	vpclmulhqhqdq ymm0,ymm11,ymm1
  401e9e:	c4 e3 25 44 c9 00    	vpclmullqlqdq ymm1,ymm11,ymm1
  401ea4:	c5 35 ef cc          	vpxor  ymm9,ymm9,ymm4
  401ea8:	c5 35 ef cb          	vpxor  ymm9,ymm9,ymm3
  401eac:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
  401eb2:	c5 bd ef 44 24 e0    	vpxor  ymm0,ymm8,YMMWORD PTR [rsp-0x20]
  401eb8:	c4 c1 75 ef cd       	vpxor  ymm1,ymm1,ymm13
  401ebd:	c5 f5 ef 4c 24 c0    	vpxor  ymm1,ymm1,YMMWORD PTR [rsp-0x40]
  401ec3:	c4 c1 7d ef c4       	vpxor  ymm0,ymm0,ymm12
  401ec8:	c4 c1 7d ef c2       	vpxor  ymm0,ymm0,ymm10
  401ecd:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
  401ed1:	c4 c1 7d ef c1       	vpxor  ymm0,ymm0,ymm9
  401ed6:	c5 fd ef c1          	vpxor  ymm0,ymm0,ymm1
  401eda:	c5 fe 7f 02          	vmovdqu YMMWORD PTR [rdx],ymm0
  401ede:	c4 e2 7d 5a 1f       	vbroadcasti128 ymm3,XMMWORD PTR [rdi]
  401ee3:	c4 e2 7d 5a 47 10    	vbroadcasti128 ymm0,XMMWORD PTR [rdi+0x10]
  401ee9:	c5 e5 ef 5e 20       	vpxor  ymm3,ymm3,YMMWORD PTR [rsi+0x20]
  401eee:	c5 fd ef 46 60       	vpxor  ymm0,ymm0,YMMWORD PTR [rsi+0x60]
  401ef3:	c4 63 65 44 f0 11    	vpclmulhqhqdq ymm14,ymm3,ymm0
  401ef9:	c4 e3 65 44 d8 00    	vpclmullqlqdq ymm3,ymm3,ymm0
  401eff:	c4 e2 7d 5a 47 20    	vbroadcasti128 ymm0,XMMWORD PTR [rdi+0x20]
  401f05:	c5 fd ef 86 a0 00 00 	vpxor  ymm0,ymm0,YMMWORD PTR [rsi+0xa0]
  401f0c:	00 
  401f0d:	c4 e2 7d 5a 4f 30    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x30]
  401f13:	c4 e2 7d 5a 57 40    	vbroadcasti128 ymm2,XMMWORD PTR [rdi+0x40]
  401f19:	c5 f5 ef 8e e0 00 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0xe0]
  401f20:	00 
  401f21:	c4 e2 7d 5a 7f 60    	vbroadcasti128 ymm7,XMMWORD PTR [rdi+0x60]
  401f27:	c5 ed ef 96 20 01 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rsi+0x120]
  401f2e:	00 
  401f2f:	c5 c5 ef be a0 01 00 	vpxor  ymm7,ymm7,YMMWORD PTR [rsi+0x1a0]
  401f36:	00 
  401f37:	c4 63 7d 44 f9 11    	vpclmulhqhqdq ymm15,ymm0,ymm1
  401f3d:	c4 e2 7d 5a a7 90 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0x90]
  401f44:	00 00 
  401f46:	c5 dd ef a6 60 02 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x260]
  401f4d:	00 
  401f4e:	c4 e3 7d 44 c1 00    	vpclmullqlqdq ymm0,ymm0,ymm1
  401f54:	c4 e2 7d 5a 4f 50    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x50]
  401f5a:	c5 f5 ef 8e 60 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x160]
  401f61:	00 
  401f62:	c4 e2 7d 5a b7 a0 00 	vbroadcasti128 ymm6,XMMWORD PTR [rdi+0xa0]
  401f69:	00 00 
  401f6b:	c5 cd ef b6 a0 02 00 	vpxor  ymm6,ymm6,YMMWORD PTR [rsi+0x2a0]
  401f72:	00 
  401f73:	c4 c1 65 ef de       	vpxor  ymm3,ymm3,ymm14
  401f78:	c4 63 6d 44 e9 11    	vpclmulhqhqdq ymm13,ymm2,ymm1
  401f7e:	c4 e2 7d 5a af c0 00 	vbroadcasti128 ymm5,XMMWORD PTR [rdi+0xc0]
  401f85:	00 00 
  401f87:	c5 d5 ef ae 20 03 00 	vpxor  ymm5,ymm5,YMMWORD PTR [rsi+0x320]
  401f8e:	00 
  401f8f:	c4 e3 6d 44 d1 00    	vpclmullqlqdq ymm2,ymm2,ymm1
  401f95:	c4 e2 7d 5a 4f 70    	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x70]
  401f9b:	c5 f5 ef 8e e0 01 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x1e0]
  401fa2:	00 
  401fa3:	c4 63 45 44 e1 11    	vpclmulhqhqdq ymm12,ymm7,ymm1
  401fa9:	c4 e3 45 44 f9 00    	vpclmullqlqdq ymm7,ymm7,ymm1
  401faf:	c5 fd 7f 44 24 e0    	vmovdqa YMMWORD PTR [rsp-0x20],ymm0
  401fb5:	c4 e2 7d 5a 8f 80 00 	vbroadcasti128 ymm1,XMMWORD PTR [rdi+0x80]
  401fbc:	00 00 
  401fbe:	c5 f5 ef 8e 20 02 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rsi+0x220]
  401fc5:	00 
  401fc6:	c4 63 75 44 dc 11    	vpclmulhqhqdq ymm11,ymm1,ymm4
  401fcc:	c4 e3 75 44 cc 00    	vpclmullqlqdq ymm1,ymm1,ymm4
  401fd2:	c4 c1 6d ef d5       	vpxor  ymm2,ymm2,ymm13
  401fd7:	c4 e2 7d 5a a7 b0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xb0]
  401fde:	00 00 
  401fe0:	c5 dd ef a6 e0 02 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x2e0]
  401fe7:	00 
  401fe8:	c4 63 4d 44 cc 11    	vpclmulhqhqdq ymm9,ymm6,ymm4
  401fee:	c4 e3 4d 44 f4 00    	vpclmullqlqdq ymm6,ymm6,ymm4
  401ff4:	c5 ed ef d7          	vpxor  ymm2,ymm2,ymm7
  401ff8:	c4 e2 7d 5a a7 d0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xd0]
  401fff:	00 00 
  402001:	c5 dd ef a6 60 03 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x360]
  402008:	00 
  402009:	c4 62 7d 5a 97 e0 00 	vbroadcasti128 ymm10,XMMWORD PTR [rdi+0xe0]
  402010:	00 00 
  402012:	c5 2d ef 96 a0 03 00 	vpxor  ymm10,ymm10,YMMWORD PTR [rsi+0x3a0]
  402019:	00 
  40201a:	c4 63 55 44 c4 11    	vpclmulhqhqdq ymm8,ymm5,ymm4
  402020:	c4 e3 55 44 ec 00    	vpclmullqlqdq ymm5,ymm5,ymm4
  402026:	c4 c1 75 ef cc       	vpxor  ymm1,ymm1,ymm12
  40202b:	c4 e2 7d 5a a7 f0 00 	vbroadcasti128 ymm4,XMMWORD PTR [rdi+0xf0]
  402032:	00 00 
  402034:	c5 dd ef a6 e0 03 00 	vpxor  ymm4,ymm4,YMMWORD PTR [rsi+0x3e0]
  40203b:	00 
  40203c:	c4 c1 75 ef cb       	vpxor  ymm1,ymm1,ymm11
  402041:	c4 e3 2d 44 c4 11    	vpclmulhqhqdq ymm0,ymm10,ymm4
  402047:	c4 e3 2d 44 e4 00    	vpclmullqlqdq ymm4,ymm10,ymm4
  40204d:	c5 35 ef ce          	vpxor  ymm9,ymm9,ymm6
  402051:	c5 35 ef cd          	vpxor  ymm9,ymm9,ymm5
  402055:	c5 fd 7f 44 24 c0    	vmovdqa YMMWORD PTR [rsp-0x40],ymm0
  40205b:	c5 85 ef 44 24 e0    	vpxor  ymm0,ymm15,YMMWORD PTR [rsp-0x20]
  402061:	c5 3d ef c4          	vpxor  ymm8,ymm8,ymm4
  402065:	c5 3d ef 44 24 c0    	vpxor  ymm8,ymm8,YMMWORD PTR [rsp-0x40]
  40206b:	c5 fd ef c3          	vpxor  ymm0,ymm0,ymm3
  40206f:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
  402073:	c5 fd ef c1          	vpxor  ymm0,ymm0,ymm1
  402077:	c4 c1 7d ef c1       	vpxor  ymm0,ymm0,ymm9
  40207c:	c4 c1 7d ef c0       	vpxor  ymm0,ymm0,ymm8
  402081:	c5 fe 7f 42 20       	vmovdqu YMMWORD PTR [rdx+0x20],ymm0
  402086:	c5 f8 77             	vzeroupper 
  402089:	c9                   	leave  
  40208a:	c3                   	ret    
  40208b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000402090 <chv3_hwprod>:
  402090:	c4 e1 f9 6e c7       	vmovq  xmm0,rdi
  402095:	c4 e1 f9 6e ce       	vmovq  xmm1,rsi
  40209a:	c4 e3 79 44 d1 00    	vpclmullqlqdq xmm2,xmm0,xmm1
  4020a0:	c5 f9 7f 54 24 e8    	vmovdqa XMMWORD PTR [rsp-0x18],xmm2
  4020a6:	48 8b 44 24 e8       	mov    rax,QWORD PTR [rsp-0x18]
  4020ab:	48 8b 54 24 f0       	mov    rdx,QWORD PTR [rsp-0x10]
  4020b0:	c3                   	ret    
  4020b1:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  4020b8:	00 00 00 00 
  4020bc:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

00000000004020c0 <chv3_region128>:
  4020c0:	48 8d 46 40          	lea    rax,[rsi+0x40]
  4020c4:	c5 fa 6f 2e          	vmovdqu xmm5,XMMWORD PTR [rsi]
  4020c8:	c5 d1 ef 07          	vpxor  xmm0,xmm5,XMMWORD PTR [rdi]
  4020cc:	48 83 c6 10          	add    rsi,0x10
  4020d0:	48 83 c2 10          	add    rdx,0x10
  4020d4:	c5 fa 6f 76 30       	vmovdqu xmm6,XMMWORD PTR [rsi+0x30]
  4020d9:	c5 c9 ef 4f 10       	vpxor  xmm1,xmm6,XMMWORD PTR [rdi+0x10]
  4020de:	c5 fa 6f 7e 70       	vmovdqu xmm7,XMMWORD PTR [rsi+0x70]
  4020e3:	c5 fa 6f ae b0 00 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0xb0]
  4020ea:	00 
  4020eb:	c5 c1 ef 5f 20       	vpxor  xmm3,xmm7,XMMWORD PTR [rdi+0x20]
  4020f0:	c4 63 79 44 f9 11    	vpclmulhqhqdq xmm15,xmm0,xmm1
  4020f6:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
  4020fc:	c5 fa 6f b6 f0 00 00 	vmovdqu xmm6,XMMWORD PTR [rsi+0xf0]
  402103:	00 
  402104:	c5 d1 ef 4f 30       	vpxor  xmm1,xmm5,XMMWORD PTR [rdi+0x30]
  402109:	c5 c9 ef 57 40       	vpxor  xmm2,xmm6,XMMWORD PTR [rdi+0x40]
  40210e:	c5 f9 7f 44 24 d8    	vmovdqa XMMWORD PTR [rsp-0x28],xmm0
  402114:	c5 fa 6f be 30 01 00 	vmovdqu xmm7,XMMWORD PTR [rsi+0x130]
  40211b:	00 
  40211c:	c5 fa 6f ae 70 01 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0x170]
  402123:	00 
  402124:	c4 63 61 44 f1 11    	vpclmulhqhqdq xmm14,xmm3,xmm1
  40212a:	c4 e3 61 44 d9 00    	vpclmullqlqdq xmm3,xmm3,xmm1
  402130:	c5 c1 ef 4f 50       	vpxor  xmm1,xmm7,XMMWORD PTR [rdi+0x50]
  402135:	c5 fa 6f b6 b0 01 00 	vmovdqu xmm6,XMMWORD PTR [rsi+0x1b0]
  40213c:	00 
  40213d:	c5 d1 ef 7f 60       	vpxor  xmm7,xmm5,XMMWORD PTR [rdi+0x60]
  402142:	c5 fa 6f ae f0 01 00 	vmovdqu xmm5,XMMWORD PTR [rsi+0x1f0]
  402149:	00 
  40214a:	c4 c1 61 ef de       	vpxor  xmm3,xmm3,xmm14
  40214f:	c4 63 69 44 e9 11    	vpclmulhqhqdq xmm13,xmm2,xmm1
  402155:	c4 e3 69 44 d1 00    	vpclmullqlqdq xmm2,xmm2,xmm1
  40215b:	c5 c9 ef 4f 70       	vpxor  xmm1,xmm6,XMMWORD PTR [rdi+0x70]
  402160:	c5 fa 6f b7 90 00 00 	vmovdqu xmm6,XMMWORD PTR [rdi+0x90]
  402167:	00 
  402168:	c5 c9 ef a6 30 02 00 	vpxor  xmm4,xmm6,XMMWORD PTR [rsi+0x230]
  40216f:	00 
  402170:	c4 c1 69 ef d5       	vpxor  xmm2,xmm2,xmm13
  402175:	c4 63 41 44 e1 11    	vpclmulhqhqdq xmm12,xmm7,xmm1
  40217b:	c4 e3 41 44 f9 00    	vpclmullqlqdq xmm7,xmm7,xmm1
  402181:	c5 d1 ef 8f 80 00 00 	vpxor  xmm1,xmm5,XMMWORD PTR [rdi+0x80]
  402188:	00 
  402189:	c5 fa 6f af a0 00 00 	vmovdqu xmm5,XMMWORD PTR [rdi+0xa0]
  402190:	00 
  402191:	c5 d1 ef b6 70 02 00 	vpxor  xmm6,xmm5,XMMWORD PTR [rsi+0x270]
  402198:	00 
  402199:	c5 fa 6f af c0 00 00 	vmovdqu xmm5,XMMWORD PTR [rdi+0xc0]
  4021a0:	00 
  4021a1:	c5 e9 ef d7          	vpxor  xmm2,xmm2,xmm7
  4021a5:	c4 63 71 44 dc 11    	vpclmulhqhqdq xmm11,xmm1,xmm4
  4021ab:	c4 e3 71 44 cc 00    	vpclmullqlqdq xmm1,xmm1,xmm4
  4021b1:	c5 fa 6f a7 b0 00 00 	vmovdqu xmm4,XMMWORD PTR [rdi+0xb0]
  4021b8:	00 
  4021b9:	c5 d9 ef a6 b0 02 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rsi+0x2b0]
  4021c0:	00 
  4021c1:	c5 d1 ef ae f0 02 00 	vpxor  xmm5,xmm5,XMMWORD PTR [rsi+0x2f0]
  4021c8:	00 
  4021c9:	c4 c1 71 ef cc       	vpxor  xmm1,xmm1,xmm12
  4021ce:	c4 63 49 44 cc 11    	vpclmulhqhqdq xmm9,xmm6,xmm4
  4021d4:	c4 e3 49 44 f4 00    	vpclmullqlqdq xmm6,xmm6,xmm4
  4021da:	c4 c1 71 ef cb       	vpxor  xmm1,xmm1,xmm11
  4021df:	c5 fa 6f a7 d0 00 00 	vmovdqu xmm4,XMMWORD PTR [rdi+0xd0]
  4021e6:	00 
  4021e7:	c5 d9 ef a6 30 03 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rsi+0x330]
  4021ee:	00 
  4021ef:	c5 31 ef ce          	vpxor  xmm9,xmm9,xmm6
  4021f3:	c4 63 51 44 c4 11    	vpclmulhqhqdq xmm8,xmm5,xmm4
  4021f9:	c4 e3 51 44 ec 00    	vpclmullqlqdq xmm5,xmm5,xmm4
  4021ff:	c5 fa 6f a7 e0 00 00 	vmovdqu xmm4,XMMWORD PTR [rdi+0xe0]
  402206:	00 
  402207:	c5 59 ef 96 70 03 00 	vpxor  xmm10,xmm4,XMMWORD PTR [rsi+0x370]
  40220e:	00 
  40220f:	c5 fa 6f a7 f0 00 00 	vmovdqu xmm4,XMMWORD PTR [rdi+0xf0]
  402216:	00 
  402217:	c5 d9 ef a6 b0 03 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rsi+0x3b0]
  40221e:	00 
  40221f:	c5 31 ef cd          	vpxor  xmm9,xmm9,xmm5
  402223:	c4 e3 29 44 c4 11    	vpclmulhqhqdq xmm0,xmm10,xmm4
  402229:	c4 e3 29 44 e4 00    	vpclmullqlqdq xmm4,xmm10,xmm4
  40222f:	c5 f9 7f 44 24 e8    	vmovdqa XMMWORD PTR [rsp-0x18],xmm0
  402235:	c5 81 ef 44 24 d8    	vpxor  xmm0,xmm15,XMMWORD PTR [rsp-0x28]
  40223b:	c5 39 ef c4          	vpxor  xmm8,xmm8,xmm4
  40223f:	c5 39 ef 44 24 e8    	vpxor  xmm8,xmm8,XMMWORD PTR [rsp-0x18]
  402245:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  402249:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  40224d:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  402251:	c4 c1 79 ef c1       	vpxor  xmm0,xmm0,xmm9
  402256:	c4 c1 79 ef c0       	vpxor  xmm0,xmm0,xmm8
  40225b:	c5 fa 7f 42 f0       	vmovdqu XMMWORD PTR [rdx-0x10],xmm0
  402260:	48 39 f0             	cmp    rax,rsi
  402263:	0f 85 5b fe ff ff    	jne    4020c4 <chv3_region128+0x4>
  402269:	c3                   	ret    
  40226a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000402270 <chainhash_x86_avx512.constprop.0>:
  402270:	55                   	push   rbp
  402271:	48 89 f1             	mov    rcx,rsi
  402274:	48 89 e5             	mov    rbp,rsp
  402277:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  40227b:	48 83 ec 48          	sub    rsp,0x48
  40227f:	c5 f9 6f 3d 79 93 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x9379]        # 40b600 <oldx+0x400>
  402286:	00 
  402287:	48 8b 05 82 93 00 00 	mov    rax,QWORD PTR [rip+0x9382]        # 40b610 <oldx+0x410>
  40228e:	48 33 05 6b 93 00 00 	xor    rax,QWORD PTR [rip+0x936b]        # 40b600 <oldx+0x400>
  402295:	c5 f9 7f 7c 24 f8    	vmovdqa XMMWORD PTR [rsp-0x8],xmm7
  40229b:	c4 e1 f9 6e f8       	vmovq  xmm7,rax
  4022a0:	c5 f9 7f 7c 24 28    	vmovdqa XMMWORD PTR [rsp+0x28],xmm7
  4022a6:	48 81 fe 00 04 00 00 	cmp    rsi,0x400
  4022ad:	0f 86 0c 07 00 00    	jbe    4029bf <chainhash_x86_avx512.constprop.0+0x74f>
  4022b3:	c5 f9 6f 15 b5 6e 00 	vmovdqa xmm2,XMMWORD PTR [rip+0x6eb5]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  4022ba:	00 
  4022bb:	48 8d 96 ff fb ff ff 	lea    rdx,[rsi-0x401]
  4022c2:	62 f1 7e 48 6f 25 f4 	vmovdqu32 zmm4,ZMMWORD PTR [rip+0x92f4]        # 40b5c0 <oldx+0x3c0>
  4022c9:	92 00 00 
  4022cc:	62 e1 7e 48 6f 1d 2a 	vmovdqu32 zmm19,ZMMWORD PTR [rip+0x8f2a]        # 40b200 <oldx>
  4022d3:	8f 00 00 
  4022d6:	48 c1 ea 0a          	shr    rdx,0xa
  4022da:	62 e1 7e 48 6f 15 5c 	vmovdqu32 zmm18,ZMMWORD PTR [rip+0x8f5c]        # 40b240 <oldx+0x40>
  4022e1:	8f 00 00 
  4022e4:	48 8d 42 01          	lea    rax,[rdx+0x1]
  4022e8:	c5 f9 7f 54 24 18    	vmovdqa XMMWORD PTR [rsp+0x18],xmm2
  4022ee:	c5 f9 6f 15 8a 6e 00 	vmovdqa xmm2,XMMWORD PTR [rip+0x6e8a]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  4022f5:	00 
  4022f6:	62 e1 7e 48 6f 0d 80 	vmovdqu32 zmm17,ZMMWORD PTR [rip+0x8f80]        # 40b280 <oldx+0x80>
  4022fd:	8f 00 00 
  402300:	48 c1 e0 0a          	shl    rax,0xa
  402304:	62 e1 7e 48 6f 05 b2 	vmovdqu32 zmm16,ZMMWORD PTR [rip+0x8fb2]        # 40b2c0 <oldx+0xc0>
  40230b:	8f 00 00 
  40230e:	62 71 7e 48 6f 3d e8 	vmovdqu32 zmm15,ZMMWORD PTR [rip+0x8fe8]        # 40b300 <oldx+0x100>
  402315:	8f 00 00 
  402318:	62 f1 7d 48 7f a4 24 	vmovdqa32 ZMMWORD PTR [rsp-0x78],zmm4
  40231f:	88 ff ff ff 
  402323:	62 71 7e 48 6f 35 13 	vmovdqu32 zmm14,ZMMWORD PTR [rip+0x9013]        # 40b340 <oldx+0x140>
  40232a:	90 00 00 
  40232d:	48 01 f8             	add    rax,rdi
  402330:	62 71 7e 48 6f 2d 46 	vmovdqu32 zmm13,ZMMWORD PTR [rip+0x9046]        # 40b380 <oldx+0x180>
  402337:	90 00 00 
  40233a:	c5 f9 7f 54 24 08    	vmovdqa XMMWORD PTR [rsp+0x8],xmm2
  402340:	62 71 7e 48 6f 25 76 	vmovdqu32 zmm12,ZMMWORD PTR [rip+0x9076]        # 40b3c0 <oldx+0x1c0>
  402347:	90 00 00 
  40234a:	62 71 7e 48 6f 1d ac 	vmovdqu32 zmm11,ZMMWORD PTR [rip+0x90ac]        # 40b400 <oldx+0x200>
  402351:	90 00 00 
  402354:	62 71 7e 48 6f 15 e2 	vmovdqu32 zmm10,ZMMWORD PTR [rip+0x90e2]        # 40b440 <oldx+0x240>
  40235b:	90 00 00 
  40235e:	62 71 7e 48 6f 0d 18 	vmovdqu32 zmm9,ZMMWORD PTR [rip+0x9118]        # 40b480 <oldx+0x280>
  402365:	91 00 00 
  402368:	62 71 7e 48 6f 05 4e 	vmovdqu32 zmm8,ZMMWORD PTR [rip+0x914e]        # 40b4c0 <oldx+0x2c0>
  40236f:	91 00 00 
  402372:	62 f1 7e 48 6f 3d 84 	vmovdqu32 zmm7,ZMMWORD PTR [rip+0x9184]        # 40b500 <oldx+0x300>
  402379:	91 00 00 
  40237c:	62 f1 7e 48 6f 35 ba 	vmovdqu32 zmm6,ZMMWORD PTR [rip+0x91ba]        # 40b540 <oldx+0x340>
  402383:	91 00 00 
  402386:	62 f1 7e 48 6f 2d f0 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x91f0]        # 40b580 <oldx+0x380>
  40238d:	91 00 00 
  402390:	62 f1 65 40 ef 07    	vpxord zmm0,zmm19,ZMMWORD PTR [rdi]
  402396:	62 61 6d 40 ef 7f 01 	vpxord zmm31,zmm18,ZMMWORD PTR [rdi+0x40]
  40239d:	48 81 c7 00 04 00 00 	add    rdi,0x400
  4023a4:	62 e1 75 40 ef 6f f2 	vpxord zmm21,zmm17,ZMMWORD PTR [rdi-0x380]
  4023ab:	62 61 7d 40 ef 77 f3 	vpxord zmm30,zmm16,ZMMWORD PTR [rdi-0x340]
  4023b2:	62 f1 1d 48 ef 5f f7 	vpxord zmm3,zmm12,ZMMWORD PTR [rdi-0x240]
  4023b9:	62 f1 35 48 ef 57 fa 	vpxord zmm2,zmm9,ZMMWORD PTR [rdi-0x180]
  4023c0:	62 e1 05 48 ef 67 f4 	vpxord zmm20,zmm15,ZMMWORD PTR [rdi-0x300]
  4023c7:	62 61 0d 48 ef 6f f5 	vpxord zmm29,zmm14,ZMMWORD PTR [rdi-0x2c0]
  4023ce:	62 61 15 48 ef 67 f6 	vpxord zmm28,zmm13,ZMMWORD PTR [rdi-0x280]
  4023d5:	62 61 25 48 ef 5f f8 	vpxord zmm27,zmm11,ZMMWORD PTR [rdi-0x200]
  4023dc:	62 f3 7d 48 44 c0 10 	vpclmullqhqdq zmm0,zmm0,zmm0
  4023e3:	62 f1 4d 48 ef 4f fd 	vpxord zmm1,zmm6,ZMMWORD PTR [rdi-0xc0]
  4023ea:	62 61 2d 48 ef 57 f9 	vpxord zmm26,zmm10,ZMMWORD PTR [rdi-0x1c0]
  4023f1:	62 03 05 40 44 ff 10 	vpclmullqhqdq zmm31,zmm31,zmm31
  4023f8:	62 e1 55 48 ef 7f fe 	vpxord zmm23,zmm5,ZMMWORD PTR [rdi-0x80]
  4023ff:	62 61 3d 48 ef 4f fb 	vpxord zmm25,zmm8,ZMMWORD PTR [rdi-0x140]
  402406:	62 a3 55 40 44 ed 10 	vpclmullqhqdq zmm21,zmm21,zmm21
  40240d:	62 f1 7d 48 6f a4 24 	vmovdqa32 zmm4,ZMMWORD PTR [rsp-0x78]
  402414:	88 ff ff ff 
  402418:	62 61 45 48 ef 47 fc 	vpxord zmm24,zmm7,ZMMWORD PTR [rdi-0x100]
  40241f:	62 03 0d 40 44 f6 10 	vpclmullqhqdq zmm30,zmm30,zmm30
  402426:	62 e1 5d 48 ef 77 ff 	vpxord zmm22,zmm4,ZMMWORD PTR [rdi-0x40]
  40242d:	c5 f9 6f 64 24 08    	vmovdqa xmm4,XMMWORD PTR [rsp+0x8]
  402433:	62 a3 5d 40 44 e4 10 	vpclmullqhqdq zmm20,zmm20,zmm20
  40243a:	62 03 15 40 44 ed 10 	vpclmullqhqdq zmm29,zmm29,zmm29
  402441:	62 03 1d 40 44 e4 10 	vpclmullqhqdq zmm28,zmm28,zmm28
  402448:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  40244f:	62 91 7d 48 ef c7    	vpxord zmm0,zmm0,zmm31
  402455:	62 03 25 40 44 db 10 	vpclmullqhqdq zmm27,zmm27,zmm27
  40245c:	62 03 2d 40 44 d2 10 	vpclmullqhqdq zmm26,zmm26,zmm26
  402463:	62 81 55 40 ef ee    	vpxord zmm21,zmm21,zmm30
  402469:	62 f3 6d 48 44 d2 10 	vpclmullqhqdq zmm2,zmm2,zmm2
  402470:	62 b1 7d 48 ef c5    	vpxord zmm0,zmm0,zmm21
  402476:	62 03 35 40 44 c9 10 	vpclmullqhqdq zmm25,zmm25,zmm25
  40247d:	62 81 5d 40 ef e5    	vpxord zmm20,zmm20,zmm29
  402483:	62 03 3d 40 44 c0 10 	vpclmullqhqdq zmm24,zmm24,zmm24
  40248a:	62 81 5d 40 ef e4    	vpxord zmm20,zmm20,zmm28
  402490:	62 f3 75 48 44 c9 10 	vpclmullqhqdq zmm1,zmm1,zmm1
  402497:	62 b1 7d 48 ef c4    	vpxord zmm0,zmm0,zmm20
  40249d:	62 a3 45 40 44 ff 10 	vpclmullqhqdq zmm23,zmm23,zmm23
  4024a4:	62 91 65 48 ef db    	vpxord zmm3,zmm3,zmm27
  4024aa:	62 a3 4d 40 44 f6 10 	vpclmullqhqdq zmm22,zmm22,zmm22
  4024b1:	62 91 65 48 ef da    	vpxord zmm3,zmm3,zmm26
  4024b7:	62 f1 7d 48 ef c3    	vpxord zmm0,zmm0,zmm3
  4024bd:	62 91 6d 48 ef d1    	vpxord zmm2,zmm2,zmm25
  4024c3:	62 91 6d 48 ef d0    	vpxord zmm2,zmm2,zmm24
  4024c9:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
  4024cf:	62 b1 75 48 ef cf    	vpxord zmm1,zmm1,zmm23
  4024d5:	62 b1 75 48 ef ce    	vpxord zmm1,zmm1,zmm22
  4024db:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
  4024e1:	62 f3 fd 48 3b c1 01 	vextracti64x4 ymm1,zmm0,0x1
  4024e8:	c5 f5 ef c0          	vpxor  ymm0,ymm1,ymm0
  4024ec:	c4 e3 7d 39 c1 01    	vextracti128 xmm1,ymm0,0x1
  4024f2:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  4024f6:	c5 f9 ef 44 24 f8    	vpxor  xmm0,xmm0,XMMWORD PTR [rsp-0x8]
  4024fc:	c4 e3 79 44 54 24 28 	vpclmulhqlqdq xmm2,xmm0,XMMWORD PTR [rsp+0x28]
  402503:	01 
  402504:	c4 e3 69 44 5c 24 18 	vpclmulhqlqdq xmm3,xmm2,XMMWORD PTR [rsp+0x18]
  40250b:	01 
  40250c:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  402510:	c5 f1 73 db 08       	vpsrldq xmm1,xmm3,0x8
  402515:	c4 e2 59 00 c9       	vpshufb xmm1,xmm4,xmm1
  40251a:	c5 e1 ef c9          	vpxor  xmm1,xmm3,xmm1
  40251e:	c5 f1 ef e0          	vpxor  xmm4,xmm1,xmm0
  402522:	c5 f9 7f 64 24 28    	vmovdqa XMMWORD PTR [rsp+0x28],xmm4
  402528:	48 39 c7             	cmp    rdi,rax
  40252b:	0f 85 5f fe ff ff    	jne    402390 <chainhash_x86_avx512.constprop.0+0x120>
  402531:	48 f7 da             	neg    rdx
  402534:	48 c1 e2 0a          	shl    rdx,0xa
  402538:	48 8d 94 11 00 fc ff 	lea    rdx,[rcx+rdx*1-0x400]
  40253f:	ff 
  402540:	48 81 fa ff 00 00 00 	cmp    rdx,0xff
  402547:	0f 86 5d 04 00 00    	jbe    4029aa <chainhash_x86_avx512.constprop.0+0x73a>
  40254d:	62 f1 7e 48 6f 2d e9 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x8ce9]        # 40b240 <oldx+0x40>
  402554:	8c 00 00 
  402557:	62 f1 55 48 ef 48 01 	vpxord zmm1,zmm5,ZMMWORD PTR [rax+0x40]
  40255e:	48 8d b2 00 ff ff ff 	lea    rsi,[rdx-0x100]
  402565:	62 f1 7e 48 6f 25 11 	vmovdqu32 zmm4,ZMMWORD PTR [rip+0x8d11]        # 40b280 <oldx+0x80>
  40256c:	8d 00 00 
  40256f:	62 f1 7e 48 6f 3d 87 	vmovdqu32 zmm7,ZMMWORD PTR [rip+0x8c87]        # 40b200 <oldx>
  402576:	8c 00 00 
  402579:	62 f3 75 48 44 e9 10 	vpclmullqhqdq zmm5,zmm1,zmm1
  402580:	62 f1 45 48 ef 38    	vpxord zmm7,zmm7,ZMMWORD PTR [rax]
  402586:	62 f1 5d 48 ef 48 02 	vpxord zmm1,zmm4,ZMMWORD PTR [rax+0x80]
  40258d:	62 f1 7e 48 6f 15 29 	vmovdqu32 zmm2,ZMMWORD PTR [rip+0x8d29]        # 40b2c0 <oldx+0xc0>
  402594:	8d 00 00 
  402597:	62 f1 6d 48 ef 50 03 	vpxord zmm2,zmm2,ZMMWORD PTR [rax+0xc0]
  40259e:	62 f3 45 48 44 ff 10 	vpclmullqhqdq zmm7,zmm7,zmm7
  4025a5:	62 f3 75 48 44 e1 10 	vpclmullqhqdq zmm4,zmm1,zmm1
  4025ac:	62 f3 6d 48 44 da 10 	vpclmullqhqdq zmm3,zmm2,zmm2
  4025b3:	62 f1 7d 48 6f f5    	vmovdqa32 zmm6,zmm5
  4025b9:	62 f1 7d 48 6f c7    	vmovdqa32 zmm0,zmm7
  4025bf:	62 f1 7d 48 6f cc    	vmovdqa32 zmm1,zmm4
  4025c5:	62 f1 7d 48 6f d3    	vmovdqa32 zmm2,zmm3
  4025cb:	48 81 fe ff 00 00 00 	cmp    rsi,0xff
  4025d2:	0f 86 97 01 00 00    	jbe    40276f <chainhash_x86_avx512.constprop.0+0x4ff>
  4025d8:	62 f1 7e 48 6f 35 1e 	vmovdqu32 zmm6,ZMMWORD PTR [rip+0x8d1e]        # 40b300 <oldx+0x100>
  4025df:	8d 00 00 
  4025e2:	62 f1 4d 48 ef 40 04 	vpxord zmm0,zmm6,ZMMWORD PTR [rax+0x100]
  4025e9:	48 8d ba 00 fe ff ff 	lea    rdi,[rdx-0x200]
  4025f0:	62 f1 7e 48 6f 35 46 	vmovdqu32 zmm6,ZMMWORD PTR [rip+0x8d46]        # 40b340 <oldx+0x140>
  4025f7:	8d 00 00 
  4025fa:	62 f1 4d 48 ef 70 05 	vpxord zmm6,zmm6,ZMMWORD PTR [rax+0x140]
  402601:	62 f3 7d 48 44 c0 10 	vpclmullqhqdq zmm0,zmm0,zmm0
  402608:	62 f3 4d 48 44 f6 10 	vpclmullqhqdq zmm6,zmm6,zmm6
  40260f:	62 f1 45 48 ef c0    	vpxord zmm0,zmm7,zmm0
  402615:	62 f1 55 48 ef f6    	vpxord zmm6,zmm5,zmm6
  40261b:	62 f1 fd 48 6f f8    	vmovdqa64 zmm7,zmm0
  402621:	62 f1 7e 48 6f 2d 55 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x8d55]        # 40b380 <oldx+0x180>
  402628:	8d 00 00 
  40262b:	62 f1 55 48 ef 48 06 	vpxord zmm1,zmm5,ZMMWORD PTR [rax+0x180]
  402632:	62 f1 7e 48 6f 2d 84 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x8d84]        # 40b3c0 <oldx+0x1c0>
  402639:	8d 00 00 
  40263c:	62 f1 55 48 ef 50 07 	vpxord zmm2,zmm5,ZMMWORD PTR [rax+0x1c0]
  402643:	62 f3 75 48 44 c9 10 	vpclmullqhqdq zmm1,zmm1,zmm1
  40264a:	62 f3 6d 48 44 d2 10 	vpclmullqhqdq zmm2,zmm2,zmm2
  402651:	62 f1 5d 48 ef c9    	vpxord zmm1,zmm4,zmm1
  402657:	62 f1 65 48 ef d2    	vpxord zmm2,zmm3,zmm2
  40265d:	48 81 ff ff 00 00 00 	cmp    rdi,0xff
  402664:	0f 86 05 01 00 00    	jbe    40276f <chainhash_x86_avx512.constprop.0+0x4ff>
  40266a:	62 f1 7e 48 6f 3d 8c 	vmovdqu32 zmm7,ZMMWORD PTR [rip+0x8d8c]        # 40b400 <oldx+0x200>
  402671:	8d 00 00 
  402674:	62 f1 45 48 ef 58 08 	vpxord zmm3,zmm7,ZMMWORD PTR [rax+0x200]
  40267b:	62 f1 7e 48 6f 2d bb 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x8dbb]        # 40b440 <oldx+0x240>
  402682:	8d 00 00 
  402685:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  40268c:	62 f1 7d 48 ef c3    	vpxord zmm0,zmm0,zmm3
  402692:	62 f1 55 48 ef 58 09 	vpxord zmm3,zmm5,ZMMWORD PTR [rax+0x240]
  402699:	62 f1 7e 48 6f 2d dd 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x8ddd]        # 40b480 <oldx+0x280>
  4026a0:	8d 00 00 
  4026a3:	62 f1 fd 48 6f f8    	vmovdqa64 zmm7,zmm0
  4026a9:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  4026b0:	62 f1 4d 48 ef f3    	vpxord zmm6,zmm6,zmm3
  4026b6:	62 f1 55 48 ef 58 0a 	vpxord zmm3,zmm5,ZMMWORD PTR [rax+0x280]
  4026bd:	62 f1 7e 48 6f 2d f9 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x8df9]        # 40b4c0 <oldx+0x2c0>
  4026c4:	8d 00 00 
  4026c7:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  4026ce:	62 f1 75 48 ef cb    	vpxord zmm1,zmm1,zmm3
  4026d4:	62 f1 55 48 ef 58 0b 	vpxord zmm3,zmm5,ZMMWORD PTR [rax+0x2c0]
  4026db:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  4026e2:	62 f1 6d 48 ef d3    	vpxord zmm2,zmm2,zmm3
  4026e8:	48 81 fa 00 04 00 00 	cmp    rdx,0x400
  4026ef:	75 7e                	jne    40276f <chainhash_x86_avx512.constprop.0+0x4ff>
  4026f1:	62 f1 7e 48 6f 78 0c 	vmovdqu32 zmm7,ZMMWORD PTR [rax+0x300]
  4026f8:	62 f1 45 48 ef 1d fe 	vpxord zmm3,zmm7,ZMMWORD PTR [rip+0x8dfe]        # 40b500 <oldx+0x300>
  4026ff:	8d 00 00 
  402702:	62 f1 7e 48 6f 68 0d 	vmovdqu32 zmm5,ZMMWORD PTR [rax+0x340]
  402709:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402710:	62 f1 7d 48 ef c3    	vpxord zmm0,zmm0,zmm3
  402716:	62 f1 55 48 ef 1d 20 	vpxord zmm3,zmm5,ZMMWORD PTR [rip+0x8e20]        # 40b540 <oldx+0x340>
  40271d:	8e 00 00 
  402720:	62 f1 7e 48 6f 68 0e 	vmovdqu32 zmm5,ZMMWORD PTR [rax+0x380]
  402727:	62 f1 fd 48 6f f8    	vmovdqa64 zmm7,zmm0
  40272d:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402734:	62 f1 4d 48 ef f3    	vpxord zmm6,zmm6,zmm3
  40273a:	62 f1 55 48 ef 1d 3c 	vpxord zmm3,zmm5,ZMMWORD PTR [rip+0x8e3c]        # 40b580 <oldx+0x380>
  402741:	8e 00 00 
  402744:	62 f1 7e 48 6f 68 0f 	vmovdqu32 zmm5,ZMMWORD PTR [rax+0x3c0]
  40274b:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402752:	62 f1 75 48 ef cb    	vpxord zmm1,zmm1,zmm3
  402758:	62 f1 55 48 ef 1d 5e 	vpxord zmm3,zmm5,ZMMWORD PTR [rip+0x8e5e]        # 40b5c0 <oldx+0x3c0>
  40275f:	8e 00 00 
  402762:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402769:	62 f1 6d 48 ef d3    	vpxord zmm2,zmm2,zmm3
  40276f:	40 30 f6             	xor    sil,sil
  402772:	62 f1 75 48 ef ca    	vpxord zmm1,zmm1,zmm2
  402778:	0f b6 d2             	movzx  edx,dl
  40277b:	48 81 c6 00 01 00 00 	add    rsi,0x100
  402782:	62 f1 75 48 ef ce    	vpxord zmm1,zmm1,zmm6
  402788:	48 83 fa 3f          	cmp    rdx,0x3f
  40278c:	76 7f                	jbe    40280d <chainhash_x86_avx512.constprop.0+0x59d>
  40278e:	62 f1 7e 48 6f ae 00 	vmovdqu32 zmm5,ZMMWORD PTR [rsi+0x40b200]
  402795:	b2 40 00 
  402798:	62 f1 55 48 ef 04 30 	vpxord zmm0,zmm5,ZMMWORD PTR [rax+rsi*1]
  40279f:	48 8d 7a c0          	lea    rdi,[rdx-0x40]
  4027a3:	4c 8d 46 40          	lea    r8,[rsi+0x40]
  4027a7:	62 f3 7d 48 44 c0 10 	vpclmullqhqdq zmm0,zmm0,zmm0
  4027ae:	62 f1 7d 48 ef c7    	vpxord zmm0,zmm0,zmm7
  4027b4:	48 83 ff 3f          	cmp    rdi,0x3f
  4027b8:	76 48                	jbe    402802 <chainhash_x86_avx512.constprop.0+0x592>
  4027ba:	62 f1 7e 48 6f be 40 	vmovdqu32 zmm7,ZMMWORD PTR [rsi+0x40b240]
  4027c1:	b2 40 00 
  4027c4:	62 f1 45 48 ef 54 30 	vpxord zmm2,zmm7,ZMMWORD PTR [rax+rsi*1+0x40]
  4027cb:	01 
  4027cc:	4c 8d 4a 80          	lea    r9,[rdx-0x80]
  4027d0:	62 f3 6d 48 44 d2 10 	vpclmullqhqdq zmm2,zmm2,zmm2
  4027d7:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
  4027dd:	49 83 f9 3f          	cmp    r9,0x3f
  4027e1:	76 1f                	jbe    402802 <chainhash_x86_avx512.constprop.0+0x592>
  4027e3:	62 f1 7e 48 6f 7c 30 	vmovdqu32 zmm7,ZMMWORD PTR [rax+rsi*1+0x80]
  4027ea:	02 
  4027eb:	62 f1 45 48 ef 96 80 	vpxord zmm2,zmm7,ZMMWORD PTR [rsi+0x40b280]
  4027f2:	b2 40 00 
  4027f5:	62 f3 6d 48 44 d2 10 	vpclmullqhqdq zmm2,zmm2,zmm2
  4027fc:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
  402802:	48 83 e7 c0          	and    rdi,0xffffffffffffffc0
  402806:	83 e2 3f             	and    edx,0x3f
  402809:	4a 8d 34 07          	lea    rsi,[rdi+r8*1]
  40280d:	62 f1 75 48 ef c0    	vpxord zmm0,zmm1,zmm0
  402813:	62 f3 fd 48 3b c1 01 	vextracti64x4 ymm1,zmm0,0x1
  40281a:	c5 f5 ef c0          	vpxor  ymm0,ymm1,ymm0
  40281e:	c4 e3 7d 39 c1 01    	vextracti128 xmm1,ymm0,0x1
  402824:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  402828:	48 85 d2             	test   rdx,rdx
  40282b:	0f 85 01 01 00 00    	jne    402932 <chainhash_x86_avx512.constprop.0+0x6c2>
  402831:	48 8b 05 d0 8d 00 00 	mov    rax,QWORD PTR [rip+0x8dd0]        # 40b608 <oldx+0x408>
  402838:	c4 e1 f9 6e f9       	vmovq  xmm7,rcx
  40283d:	c5 f9 6f 6c 24 18    	vmovdqa xmm5,XMMWORD PTR [rsp+0x18]
  402843:	c5 f9 6f 74 24 08    	vmovdqa xmm6,XMMWORD PTR [rsp+0x8]
  402849:	48 31 c8             	xor    rax,rcx
  40284c:	c4 e3 c1 22 c8 01    	vpinsrq xmm1,xmm7,rax,0x1
  402852:	48 8b 05 bf 8d 00 00 	mov    rax,QWORD PTR [rip+0x8dbf]        # 40b618 <oldx+0x418>
  402859:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  40285d:	c4 e3 71 44 44 24 28 	vpclmulhqlqdq xmm0,xmm1,XMMWORD PTR [rsp+0x28]
  402864:	01 
  402865:	c4 e3 79 44 d5 01    	vpclmulhqlqdq xmm2,xmm0,xmm5
  40286b:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  402870:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  402874:	c5 fa 7e 0d c4 8d 00 	vmovq  xmm1,QWORD PTR [rip+0x8dc4]        # 40b640 <oldx+0x440>
  40287b:	00 
  40287c:	c4 e2 49 00 db       	vpshufb xmm3,xmm6,xmm3
  402881:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  402885:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  402889:	c5 f9 d4 c1          	vpaddq xmm0,xmm0,xmm1
  40288d:	c4 e3 79 44 d0 00    	vpclmullqlqdq xmm2,xmm0,xmm0
  402893:	c4 e3 69 44 cd 01    	vpclmulhqlqdq xmm1,xmm2,xmm5
  402899:	c5 e1 73 d9 08       	vpsrldq xmm3,xmm1,0x8
  40289e:	c4 e2 49 00 db       	vpshufb xmm3,xmm6,xmm3
  4028a3:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  4028a7:	c4 e1 f9 6e d8       	vmovq  xmm3,rax
  4028ac:	48 33 05 6d 8d 00 00 	xor    rax,QWORD PTR [rip+0x8d6d]        # 40b620 <oldx+0x420>
  4028b3:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  4028b7:	c5 fa 7e 1d 69 8d 00 	vmovq  xmm3,QWORD PTR [rip+0x8d69]        # 40b628 <oldx+0x428>
  4028be:	00 
  4028bf:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4028c3:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  4028c8:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  4028cc:	c5 e1 ef d8          	vpxor  xmm3,xmm3,xmm0
  4028d0:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  4028d4:	c5 fa 7e 05 54 8d 00 	vmovq  xmm0,QWORD PTR [rip+0x8d54]        # 40b630 <oldx+0x430>
  4028db:	00 
  4028dc:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  4028e2:	c4 e3 71 44 d5 01    	vpclmulhqlqdq xmm2,xmm1,xmm5
  4028e8:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  4028ec:	c5 d9 73 da 08       	vpsrldq xmm4,xmm2,0x8
  4028f1:	c4 e2 49 00 e4       	vpshufb xmm4,xmm6,xmm4
  4028f6:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  4028fa:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  4028fe:	c5 fa 7e 15 32 8d 00 	vmovq  xmm2,QWORD PTR [rip+0x8d32]        # 40b638 <oldx+0x438>
  402905:	00 
  402906:	c4 e3 61 44 d8 00    	vpclmullqlqdq xmm3,xmm3,xmm0
  40290c:	c4 e3 61 44 c5 01    	vpclmulhqlqdq xmm0,xmm3,xmm5
  402912:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  402916:	c5 f1 73 d8 08       	vpsrldq xmm1,xmm0,0x8
  40291b:	c4 e2 49 00 c9       	vpshufb xmm1,xmm6,xmm1
  402920:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  402924:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  402928:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  40292d:	c5 f8 77             	vzeroupper 
  402930:	c9                   	leave  
  402931:	c3                   	ret    
  402932:	48 01 f0             	add    rax,rsi
  402935:	48 8d be 00 b2 40 00 	lea    rdi,[rsi+0x40b200]
  40293c:	48 83 fa 0f          	cmp    rdx,0xf
  402940:	0f 86 38 01 00 00    	jbe    402a7e <chainhash_x86_avx512.constprop.0+0x80e>
  402946:	c5 fa 6f 38          	vmovdqu xmm7,XMMWORD PTR [rax]
  40294a:	c5 c1 ef 8e 00 b2 40 	vpxor  xmm1,xmm7,XMMWORD PTR [rsi+0x40b200]
  402951:	00 
  402952:	48 8d 72 f0          	lea    rsi,[rdx-0x10]
  402956:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  40295c:	48 83 fe 0f          	cmp    rsi,0xf
  402960:	76 32                	jbe    402994 <chainhash_x86_avx512.constprop.0+0x724>
  402962:	c5 fa 6f 78 10       	vmovdqu xmm7,XMMWORD PTR [rax+0x10]
  402967:	c5 c1 ef 57 10       	vpxor  xmm2,xmm7,XMMWORD PTR [rdi+0x10]
  40296c:	4c 8d 42 e0          	lea    r8,[rdx-0x20]
  402970:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  402976:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  40297a:	49 83 f8 0f          	cmp    r8,0xf
  40297e:	76 14                	jbe    402994 <chainhash_x86_avx512.constprop.0+0x724>
  402980:	c5 fa 6f 78 20       	vmovdqu xmm7,XMMWORD PTR [rax+0x20]
  402985:	c5 c1 ef 57 20       	vpxor  xmm2,xmm7,XMMWORD PTR [rdi+0x20]
  40298a:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  402990:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  402994:	48 83 e6 f0          	and    rsi,0xfffffffffffffff0
  402998:	48 83 c6 10          	add    rsi,0x10
  40299c:	83 e2 0f             	and    edx,0xf
  40299f:	75 45                	jne    4029e6 <chainhash_x86_avx512.constprop.0+0x776>
  4029a1:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  4029a5:	e9 87 fe ff ff       	jmp    402831 <chainhash_x86_avx512.constprop.0+0x5c1>
  4029aa:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  4029ae:	c5 c1 ef ff          	vpxor  xmm7,xmm7,xmm7
  4029b2:	31 f6                	xor    esi,esi
  4029b4:	62 f1 7d 48 6f c8    	vmovdqa32 zmm1,zmm0
  4029ba:	e9 c9 fd ff ff       	jmp    402788 <chainhash_x86_avx512.constprop.0+0x518>
  4029bf:	c5 f9 6f 3d a9 67 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x67a9]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  4029c6:	00 
  4029c7:	48 89 f2             	mov    rdx,rsi
  4029ca:	48 89 f8             	mov    rax,rdi
  4029cd:	c5 f9 7f 7c 24 18    	vmovdqa XMMWORD PTR [rsp+0x18],xmm7
  4029d3:	c5 f9 6f 3d a5 67 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x67a5]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  4029da:	00 
  4029db:	c5 f9 7f 7c 24 08    	vmovdqa XMMWORD PTR [rsp+0x8],xmm7
  4029e1:	e9 5a fb ff ff       	jmp    402540 <chainhash_x86_avx512.constprop.0+0x2d0>
  4029e6:	48 01 f0             	add    rax,rsi
  4029e9:	48 01 f7             	add    rdi,rsi
  4029ec:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  4029f0:	41 89 d1             	mov    r9d,edx
  4029f3:	4c 8d 44 24 38       	lea    r8,[rsp+0x38]
  4029f8:	48 89 c6             	mov    rsi,rax
  4029fb:	c5 f9 7f 54 24 38    	vmovdqa XMMWORD PTR [rsp+0x38],xmm2
  402a01:	83 fa 08             	cmp    edx,0x8
  402a04:	73 52                	jae    402a58 <chainhash_x86_avx512.constprop.0+0x7e8>
  402a06:	31 c0                	xor    eax,eax
  402a08:	41 f6 c1 04          	test   r9b,0x4
  402a0c:	75 3e                	jne    402a4c <chainhash_x86_avx512.constprop.0+0x7dc>
  402a0e:	41 f6 c1 02          	test   r9b,0x2
  402a12:	75 29                	jne    402a3d <chainhash_x86_avx512.constprop.0+0x7cd>
  402a14:	41 83 e1 01          	and    r9d,0x1
  402a18:	75 19                	jne    402a33 <chainhash_x86_avx512.constprop.0+0x7c3>
  402a1a:	c5 f9 6f 7c 24 38    	vmovdqa xmm7,XMMWORD PTR [rsp+0x38]
  402a20:	c5 c1 ef 17          	vpxor  xmm2,xmm7,XMMWORD PTR [rdi]
  402a24:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  402a2a:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  402a2e:	e9 6e ff ff ff       	jmp    4029a1 <chainhash_x86_avx512.constprop.0+0x731>
  402a33:	0f b6 14 06          	movzx  edx,BYTE PTR [rsi+rax*1]
  402a37:	41 88 14 00          	mov    BYTE PTR [r8+rax*1],dl
  402a3b:	eb dd                	jmp    402a1a <chainhash_x86_avx512.constprop.0+0x7aa>
  402a3d:	0f b7 14 06          	movzx  edx,WORD PTR [rsi+rax*1]
  402a41:	66 41 89 14 00       	mov    WORD PTR [r8+rax*1],dx
  402a46:	48 83 c0 02          	add    rax,0x2
  402a4a:	eb c8                	jmp    402a14 <chainhash_x86_avx512.constprop.0+0x7a4>
  402a4c:	8b 06                	mov    eax,DWORD PTR [rsi]
  402a4e:	41 89 00             	mov    DWORD PTR [r8],eax
  402a51:	b8 04 00 00 00       	mov    eax,0x4
  402a56:	eb b6                	jmp    402a0e <chainhash_x86_avx512.constprop.0+0x79e>
  402a58:	83 e2 f8             	and    edx,0xfffffff8
  402a5b:	31 f6                	xor    esi,esi
  402a5d:	41 89 f0             	mov    r8d,esi
  402a60:	83 c6 08             	add    esi,0x8
  402a63:	4e 8b 14 00          	mov    r10,QWORD PTR [rax+r8*1]
  402a67:	4e 89 54 04 38       	mov    QWORD PTR [rsp+r8*1+0x38],r10
  402a6c:	39 d6                	cmp    esi,edx
  402a6e:	72 ed                	jb     402a5d <chainhash_x86_avx512.constprop.0+0x7ed>
  402a70:	48 8d 54 24 38       	lea    rdx,[rsp+0x38]
  402a75:	4c 8d 04 32          	lea    r8,[rdx+rsi*1]
  402a79:	48 01 c6             	add    rsi,rax
  402a7c:	eb 88                	jmp    402a06 <chainhash_x86_avx512.constprop.0+0x796>
  402a7e:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
  402a82:	e9 65 ff ff ff       	jmp    4029ec <chainhash_x86_avx512.constprop.0+0x77c>
  402a87:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  402a8e:	00 00 

0000000000402a90 <chainhash_x86_avx2.constprop.0>:
  402a90:	55                   	push   rbp
  402a91:	48 89 e5             	mov    rbp,rsp
  402a94:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
  402a98:	48 8b 05 71 8b 00 00 	mov    rax,QWORD PTR [rip+0x8b71]        # 40b610 <oldx+0x410>
  402a9f:	48 33 05 5a 8b 00 00 	xor    rax,QWORD PTR [rip+0x8b5a]        # 40b600 <oldx+0x400>
  402aa6:	c5 79 6f 0d 52 8b 00 	vmovdqa xmm9,XMMWORD PTR [rip+0x8b52]        # 40b600 <oldx+0x400>
  402aad:	00 
  402aae:	c4 e1 f9 6e f0       	vmovq  xmm6,rax
  402ab3:	48 81 fe 00 04 00 00 	cmp    rsi,0x400
  402aba:	0f 86 31 03 00 00    	jbe    402df1 <chainhash_x86_avx2.constprop.0+0x361>
  402ac0:	48 8d 8e ff fb ff ff 	lea    rcx,[rsi-0x401]
  402ac7:	c5 f9 6f 3d a1 66 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x66a1]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  402ace:	00 
  402acf:	c5 79 6f 05 a9 66 00 	vmovdqa xmm8,XMMWORD PTR [rip+0x66a9]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  402ad6:	00 
  402ad7:	48 c1 e9 0a          	shr    rcx,0xa
  402adb:	48 8d 51 01          	lea    rdx,[rcx+0x1]
  402adf:	48 c1 e2 0a          	shl    rdx,0xa
  402ae3:	48 01 fa             	add    rdx,rdi
  402ae6:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  402aed:	00 00 00 
  402af0:	c4 41 29 ef d2       	vpxor  xmm10,xmm10,xmm10
  402af5:	31 c0                	xor    eax,eax
  402af7:	c5 79 7f d5          	vmovdqa xmm5,xmm10
  402afb:	c5 79 7f d4          	vmovdqa xmm4,xmm10
  402aff:	c5 79 7f d3          	vmovdqa xmm3,xmm10
  402b03:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  402b08:	c5 fe 6f 14 07       	vmovdqu ymm2,YMMWORD PTR [rdi+rax*1]
  402b0d:	c5 ed ef 88 00 b2 40 	vpxor  ymm1,ymm2,YMMWORD PTR [rax+0x40b200]
  402b14:	00 
  402b15:	c5 fe 6f 54 07 20    	vmovdqu ymm2,YMMWORD PTR [rdi+rax*1+0x20]
  402b1b:	c5 ed ef 80 20 b2 40 	vpxor  ymm0,ymm2,YMMWORD PTR [rax+0x40b220]
  402b22:	00 
  402b23:	48 83 c0 40          	add    rax,0x40
  402b27:	c5 79 6f d9          	vmovdqa xmm11,xmm1
  402b2b:	c4 e3 7d 39 c9 01    	vextracti128 xmm1,ymm1,0x1
  402b31:	c5 f9 6f d0          	vmovdqa xmm2,xmm0
  402b35:	c4 e3 7d 39 c0 01    	vextracti128 xmm0,ymm0,0x1
  402b3b:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  402b41:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  402b47:	c4 43 21 44 db 10    	vpclmullqhqdq xmm11,xmm11,xmm11
  402b4d:	c4 e3 79 44 c0 10    	vpclmullqhqdq xmm0,xmm0,xmm0
  402b53:	c5 a9 ef c0          	vpxor  xmm0,xmm10,xmm0
  402b57:	c4 c1 61 ef db       	vpxor  xmm3,xmm3,xmm11
  402b5c:	c5 d9 ef e1          	vpxor  xmm4,xmm4,xmm1
  402b60:	c5 d1 ef ea          	vpxor  xmm5,xmm5,xmm2
  402b64:	c5 e1 ef cc          	vpxor  xmm1,xmm3,xmm4
  402b68:	c5 79 6f d0          	vmovdqa xmm10,xmm0
  402b6c:	c5 d1 ef d0          	vpxor  xmm2,xmm5,xmm0
  402b70:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  402b74:	48 3d 00 04 00 00    	cmp    rax,0x400
  402b7a:	75 8c                	jne    402b08 <chainhash_x86_avx2.constprop.0+0x78>
  402b7c:	c4 c1 71 ef c9       	vpxor  xmm1,xmm1,xmm9
  402b81:	48 81 c7 00 04 00 00 	add    rdi,0x400
  402b88:	c4 e3 71 44 f6 01    	vpclmulhqlqdq xmm6,xmm1,xmm6
  402b8e:	c4 e3 49 44 c7 01    	vpclmulhqlqdq xmm0,xmm6,xmm7
  402b94:	c5 c9 ef f1          	vpxor  xmm6,xmm6,xmm1
  402b98:	c5 e9 73 d8 08       	vpsrldq xmm2,xmm0,0x8
  402b9d:	c4 e2 39 00 d2       	vpshufb xmm2,xmm8,xmm2
  402ba2:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  402ba6:	c5 f9 ef f6          	vpxor  xmm6,xmm0,xmm6
  402baa:	48 39 d7             	cmp    rdi,rdx
  402bad:	0f 85 3d ff ff ff    	jne    402af0 <chainhash_x86_avx2.constprop.0+0x60>
  402bb3:	48 f7 d9             	neg    rcx
  402bb6:	48 c1 e1 0a          	shl    rcx,0xa
  402bba:	4c 8d 84 0e 00 fc ff 	lea    r8,[rsi+rcx*1-0x400]
  402bc1:	ff 
  402bc2:	49 83 f8 3f          	cmp    r8,0x3f
  402bc6:	0f 86 18 02 00 00    	jbe    402de4 <chainhash_x86_avx2.constprop.0+0x354>
  402bcc:	49 8d 78 c0          	lea    rdi,[r8-0x40]
  402bd0:	c4 41 31 ef c9       	vpxor  xmm9,xmm9,xmm9
  402bd5:	31 c0                	xor    eax,eax
  402bd7:	c5 79 7f cc          	vmovdqa xmm4,xmm9
  402bdb:	c5 79 7f cd          	vmovdqa xmm5,xmm9
  402bdf:	c5 79 7f cb          	vmovdqa xmm3,xmm9
  402be3:	48 83 e7 c0          	and    rdi,0xffffffffffffffc0
  402be7:	4c 8d 4f 40          	lea    r9,[rdi+0x40]
  402beb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  402bf0:	c5 fe 6f 14 02       	vmovdqu ymm2,YMMWORD PTR [rdx+rax*1]
  402bf5:	c5 ed ef 88 00 b2 40 	vpxor  ymm1,ymm2,YMMWORD PTR [rax+0x40b200]
  402bfc:	00 
  402bfd:	48 89 c1             	mov    rcx,rax
  402c00:	c5 fe 6f 54 02 20    	vmovdqu ymm2,YMMWORD PTR [rdx+rax*1+0x20]
  402c06:	c5 ed ef 80 20 b2 40 	vpxor  ymm0,ymm2,YMMWORD PTR [rax+0x40b220]
  402c0d:	00 
  402c0e:	48 83 c0 40          	add    rax,0x40
  402c12:	c5 79 6f d1          	vmovdqa xmm10,xmm1
  402c16:	c4 e3 7d 39 c9 01    	vextracti128 xmm1,ymm1,0x1
  402c1c:	c5 f9 6f d0          	vmovdqa xmm2,xmm0
  402c20:	c4 e3 7d 39 c0 01    	vextracti128 xmm0,ymm0,0x1
  402c26:	c4 43 29 44 d2 10    	vpclmullqhqdq xmm10,xmm10,xmm10
  402c2c:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  402c32:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  402c38:	c4 e3 79 44 c0 10    	vpclmullqhqdq xmm0,xmm0,xmm0
  402c3e:	c5 d1 ef c9          	vpxor  xmm1,xmm5,xmm1
  402c42:	c5 b1 ef c0          	vpxor  xmm0,xmm9,xmm0
  402c46:	c4 c1 61 ef da       	vpxor  xmm3,xmm3,xmm10
  402c4b:	c5 d9 ef e2          	vpxor  xmm4,xmm4,xmm2
  402c4f:	c5 61 ef d1          	vpxor  xmm10,xmm3,xmm1
  402c53:	c5 f9 6f e9          	vmovdqa xmm5,xmm1
  402c57:	c5 79 6f c8          	vmovdqa xmm9,xmm0
  402c5b:	c5 d9 ef c8          	vpxor  xmm1,xmm4,xmm0
  402c5f:	48 39 f9             	cmp    rcx,rdi
  402c62:	75 8c                	jne    402bf0 <chainhash_x86_avx2.constprop.0+0x160>
  402c64:	41 83 e0 3f          	and    r8d,0x3f
  402c68:	c5 29 ef d1          	vpxor  xmm10,xmm10,xmm1
  402c6c:	4d 85 c0             	test   r8,r8
  402c6f:	0f 85 f5 00 00 00    	jne    402d6a <chainhash_x86_avx2.constprop.0+0x2da>
  402c75:	48 8b 05 8c 89 00 00 	mov    rax,QWORD PTR [rip+0x898c]        # 40b608 <oldx+0x408>
  402c7c:	c4 e1 f9 6e ee       	vmovq  xmm5,rsi
  402c81:	48 31 f0             	xor    rax,rsi
  402c84:	c4 e3 d1 22 c8 01    	vpinsrq xmm1,xmm5,rax,0x1
  402c8a:	48 8b 05 87 89 00 00 	mov    rax,QWORD PTR [rip+0x8987]        # 40b618 <oldx+0x418>
  402c91:	c4 c1 71 ef ca       	vpxor  xmm1,xmm1,xmm10
  402c96:	c4 e3 71 44 f6 01    	vpclmulhqlqdq xmm6,xmm1,xmm6
  402c9c:	c4 e1 f9 6e e0       	vmovq  xmm4,rax
  402ca1:	48 33 05 78 89 00 00 	xor    rax,QWORD PTR [rip+0x8978]        # 40b620 <oldx+0x420>
  402ca8:	c4 e3 49 44 d7 01    	vpclmulhqlqdq xmm2,xmm6,xmm7
  402cae:	c5 f9 73 da 08       	vpsrldq xmm0,xmm2,0x8
  402cb3:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  402cb7:	c5 fa 7e 0d 81 89 00 	vmovq  xmm1,QWORD PTR [rip+0x8981]        # 40b640 <oldx+0x440>
  402cbe:	00 
  402cbf:	c4 e2 39 00 c0       	vpshufb xmm0,xmm8,xmm0
  402cc4:	c5 c9 ef c0          	vpxor  xmm0,xmm6,xmm0
  402cc8:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  402ccc:	c5 f9 d4 c1          	vpaddq xmm0,xmm0,xmm1
  402cd0:	c4 e3 79 44 c8 00    	vpclmullqlqdq xmm1,xmm0,xmm0
  402cd6:	c4 e3 71 44 d7 01    	vpclmulhqlqdq xmm2,xmm1,xmm7
  402cdc:	c5 f1 ef cc          	vpxor  xmm1,xmm1,xmm4
  402ce0:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  402ce5:	c4 e2 39 00 db       	vpshufb xmm3,xmm8,xmm3
  402cea:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  402cee:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  402cf2:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  402cf7:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  402cfb:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  402cff:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  402d05:	c5 fa 7e 15 1b 89 00 	vmovq  xmm2,QWORD PTR [rip+0x891b]        # 40b628 <oldx+0x428>
  402d0c:	00 
  402d0d:	c4 e3 71 44 df 01    	vpclmulhqlqdq xmm3,xmm1,xmm7
  402d13:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  402d17:	c5 d9 73 db 08       	vpsrldq xmm4,xmm3,0x8
  402d1c:	c5 fa 7e 15 0c 89 00 	vmovq  xmm2,QWORD PTR [rip+0x890c]        # 40b630 <oldx+0x430>
  402d23:	00 
  402d24:	c4 e2 39 00 e4       	vpshufb xmm4,xmm8,xmm4
  402d29:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  402d2d:	c5 e1 ef dc          	vpxor  xmm3,xmm3,xmm4
  402d31:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  402d35:	c4 e3 79 44 c9 00    	vpclmullqlqdq xmm1,xmm0,xmm1
  402d3b:	c4 e3 71 44 ff 01    	vpclmulhqlqdq xmm7,xmm1,xmm7
  402d41:	c5 f9 73 df 08       	vpsrldq xmm0,xmm7,0x8
  402d46:	c4 62 39 00 c0       	vpshufb xmm8,xmm8,xmm0
  402d4b:	c5 fa 7e 05 e5 88 00 	vmovq  xmm0,QWORD PTR [rip+0x88e5]        # 40b638 <oldx+0x438>
  402d52:	00 
  402d53:	c4 c1 41 ef f8       	vpxor  xmm7,xmm7,xmm8
  402d58:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  402d5c:	c5 f9 ef c7          	vpxor  xmm0,xmm0,xmm7
  402d60:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  402d65:	c5 f8 77             	vzeroupper 
  402d68:	c9                   	leave  
  402d69:	c3                   	ret    
  402d6a:	4c 01 ca             	add    rdx,r9
  402d6d:	49 8d 89 00 b2 40 00 	lea    rcx,[r9+0x40b200]
  402d74:	49 83 f8 0f          	cmp    r8,0xf
  402d78:	0f 86 23 01 00 00    	jbe    402ea1 <chainhash_x86_avx2.constprop.0+0x411>
  402d7e:	c5 fa 6f 2a          	vmovdqu xmm5,XMMWORD PTR [rdx]
  402d82:	49 8d 40 f0          	lea    rax,[r8-0x10]
  402d86:	c4 c1 51 ef 81 00 b2 	vpxor  xmm0,xmm5,XMMWORD PTR [r9+0x40b200]
  402d8d:	40 00 
  402d8f:	c4 e3 79 44 c0 10    	vpclmullqhqdq xmm0,xmm0,xmm0
  402d95:	48 83 f8 0f          	cmp    rax,0xf
  402d99:	76 32                	jbe    402dcd <chainhash_x86_avx2.constprop.0+0x33d>
  402d9b:	c5 fa 6f 6a 10       	vmovdqu xmm5,XMMWORD PTR [rdx+0x10]
  402da0:	c5 d1 ef 49 10       	vpxor  xmm1,xmm5,XMMWORD PTR [rcx+0x10]
  402da5:	49 8d 78 e0          	lea    rdi,[r8-0x20]
  402da9:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  402daf:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  402db3:	48 83 ff 0f          	cmp    rdi,0xf
  402db7:	76 14                	jbe    402dcd <chainhash_x86_avx2.constprop.0+0x33d>
  402db9:	c5 fa 6f 6a 20       	vmovdqu xmm5,XMMWORD PTR [rdx+0x20]
  402dbe:	c5 d1 ef 49 20       	vpxor  xmm1,xmm5,XMMWORD PTR [rcx+0x20]
  402dc3:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  402dc9:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  402dcd:	48 83 e0 f0          	and    rax,0xfffffffffffffff0
  402dd1:	48 83 c0 10          	add    rax,0x10
  402dd5:	41 83 e0 0f          	and    r8d,0xf
  402dd9:	75 31                	jne    402e0c <chainhash_x86_avx2.constprop.0+0x37c>
  402ddb:	c5 29 ef d0          	vpxor  xmm10,xmm10,xmm0
  402ddf:	e9 91 fe ff ff       	jmp    402c75 <chainhash_x86_avx2.constprop.0+0x1e5>
  402de4:	c4 41 29 ef d2       	vpxor  xmm10,xmm10,xmm10
  402de9:	45 31 c9             	xor    r9d,r9d
  402dec:	e9 7b fe ff ff       	jmp    402c6c <chainhash_x86_avx2.constprop.0+0x1dc>
  402df1:	c5 f9 6f 3d 77 63 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x6377]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  402df8:	00 
  402df9:	c5 79 6f 05 7f 63 00 	vmovdqa xmm8,XMMWORD PTR [rip+0x637f]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  402e00:	00 
  402e01:	49 89 f0             	mov    r8,rsi
  402e04:	48 89 fa             	mov    rdx,rdi
  402e07:	e9 b6 fd ff ff       	jmp    402bc2 <chainhash_x86_avx2.constprop.0+0x132>
  402e0c:	48 01 c2             	add    rdx,rax
  402e0f:	48 01 c1             	add    rcx,rax
  402e12:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
  402e16:	45 89 c1             	mov    r9d,r8d
  402e19:	48 8d 7c 24 f0       	lea    rdi,[rsp-0x10]
  402e1e:	48 89 d0             	mov    rax,rdx
  402e21:	c5 f9 7f 4c 24 f0    	vmovdqa XMMWORD PTR [rsp-0x10],xmm1
  402e27:	41 83 f8 08          	cmp    r8d,0x8
  402e2b:	73 4e                	jae    402e7b <chainhash_x86_avx2.constprop.0+0x3eb>
  402e2d:	31 d2                	xor    edx,edx
  402e2f:	41 f6 c1 04          	test   r9b,0x4
  402e33:	75 3b                	jne    402e70 <chainhash_x86_avx2.constprop.0+0x3e0>
  402e35:	41 f6 c1 02          	test   r9b,0x2
  402e39:	75 25                	jne    402e60 <chainhash_x86_avx2.constprop.0+0x3d0>
  402e3b:	41 83 e1 01          	and    r9d,0x1
  402e3f:	75 16                	jne    402e57 <chainhash_x86_avx2.constprop.0+0x3c7>
  402e41:	c5 f9 6f 6c 24 f0    	vmovdqa xmm5,XMMWORD PTR [rsp-0x10]
  402e47:	c5 d1 ef 09          	vpxor  xmm1,xmm5,XMMWORD PTR [rcx]
  402e4b:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  402e51:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  402e55:	eb 84                	jmp    402ddb <chainhash_x86_avx2.constprop.0+0x34b>
  402e57:	0f b6 04 10          	movzx  eax,BYTE PTR [rax+rdx*1]
  402e5b:	88 04 17             	mov    BYTE PTR [rdi+rdx*1],al
  402e5e:	eb e1                	jmp    402e41 <chainhash_x86_avx2.constprop.0+0x3b1>
  402e60:	44 0f b7 04 10       	movzx  r8d,WORD PTR [rax+rdx*1]
  402e65:	66 44 89 04 17       	mov    WORD PTR [rdi+rdx*1],r8w
  402e6a:	48 83 c2 02          	add    rdx,0x2
  402e6e:	eb cb                	jmp    402e3b <chainhash_x86_avx2.constprop.0+0x3ab>
  402e70:	8b 10                	mov    edx,DWORD PTR [rax]
  402e72:	89 17                	mov    DWORD PTR [rdi],edx
  402e74:	ba 04 00 00 00       	mov    edx,0x4
  402e79:	eb ba                	jmp    402e35 <chainhash_x86_avx2.constprop.0+0x3a5>
  402e7b:	41 83 e0 f8          	and    r8d,0xfffffff8
  402e7f:	31 c0                	xor    eax,eax
  402e81:	89 c7                	mov    edi,eax
  402e83:	83 c0 08             	add    eax,0x8
  402e86:	4c 8b 14 3a          	mov    r10,QWORD PTR [rdx+rdi*1]
  402e8a:	4c 89 54 3c f0       	mov    QWORD PTR [rsp+rdi*1-0x10],r10
  402e8f:	44 39 c0             	cmp    eax,r8d
  402e92:	72 ed                	jb     402e81 <chainhash_x86_avx2.constprop.0+0x3f1>
  402e94:	48 8d 7c 24 f0       	lea    rdi,[rsp-0x10]
  402e99:	48 01 c7             	add    rdi,rax
  402e9c:	48 01 d0             	add    rax,rdx
  402e9f:	eb 8c                	jmp    402e2d <chainhash_x86_avx2.constprop.0+0x39d>
  402ea1:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  402ea5:	e9 68 ff ff ff       	jmp    402e12 <chainhash_x86_avx2.constprop.0+0x382>
  402eaa:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000402eb0 <old>:
  402eb0:	41 57                	push   r15
  402eb2:	49 89 ff             	mov    r15,rdi
  402eb5:	41 56                	push   r14
  402eb7:	41 55                	push   r13
  402eb9:	41 54                	push   r12
  402ebb:	55                   	push   rbp
  402ebc:	53                   	push   rbx
  402ebd:	48 89 74 24 d8       	mov    QWORD PTR [rsp-0x28],rsi
  402ec2:	8b 35 c0 81 00 00    	mov    esi,DWORD PTR [rip+0x81c0]        # 40b088 <cached.2>
  402ec8:	85 f6                	test   esi,esi
  402eca:	0f 84 8a 04 00 00    	je     40335a <old+0x4aa>
  402ed0:	8d 46 ff             	lea    eax,[rsi-0x1]
  402ed3:	83 fe 03             	cmp    esi,0x3
  402ed6:	0f 84 16 05 00 00    	je     4033f2 <old+0x542>
  402edc:	83 f8 01             	cmp    eax,0x1
  402edf:	0f 84 d0 04 00 00    	je     4033b5 <old+0x505>
  402ee5:	48 8b 05 24 87 00 00 	mov    rax,QWORD PTR [rip+0x8724]        # 40b610 <oldx+0x410>
  402eec:	48 8b 6c 24 d8       	mov    rbp,QWORD PTR [rsp-0x28]
  402ef1:	48 89 44 24 e0       	mov    QWORD PTR [rsp-0x20],rax
  402ef6:	48 8b 05 03 87 00 00 	mov    rax,QWORD PTR [rip+0x8703]        # 40b600 <oldx+0x400>
  402efd:	48 89 44 24 e8       	mov    QWORD PTR [rsp-0x18],rax
  402f02:	48 8b 05 ff 86 00 00 	mov    rax,QWORD PTR [rip+0x86ff]        # 40b608 <oldx+0x408>
  402f09:	48 89 44 24 f0       	mov    QWORD PTR [rsp-0x10],rax
  402f0e:	b8 00 04 00 00       	mov    eax,0x400
  402f13:	48 39 c5             	cmp    rbp,rax
  402f16:	48 0f 46 c5          	cmovbe rax,rbp
  402f1a:	48 89 44 24 d0       	mov    QWORD PTR [rsp-0x30],rax
  402f1f:	48 89 c3             	mov    rbx,rax
  402f22:	48 83 fd 0f          	cmp    rbp,0xf
  402f26:	0f 86 3b 03 00 00    	jbe    403267 <old+0x3b7>
  402f2c:	4c 8d 73 f0          	lea    r14,[rbx-0x10]
  402f30:	4c 89 f8             	mov    rax,r15
  402f33:	45 31 c0             	xor    r8d,r8d
  402f36:	45 31 e4             	xor    r12d,r12d
  402f39:	49 83 e6 f0          	and    r14,0xfffffffffffffff0
  402f3d:	45 31 d2             	xor    r10d,r10d
  402f40:	4d 8d 6e 10          	lea    r13,[r14+0x10]
  402f44:	eb 47                	jmp    402f8d <old+0xdd>
  402f46:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  402f4d:	00 00 00 
  402f50:	b9 41 00 00 00       	mov    ecx,0x41
  402f55:	48 89 f0             	mov    rax,rsi
  402f58:	44 29 d9             	sub    ecx,r11d
  402f5b:	48 d3 e8             	shr    rax,cl
  402f5e:	48 21 c2             	and    rdx,rax
  402f61:	48 31 d3             	xor    rbx,rdx
  402f64:	41 83 fb 40          	cmp    r11d,0x40
  402f68:	0f 85 fe 00 00 00    	jne    40306c <old+0x1bc>
  402f6e:	48 8b 44 24 c8       	mov    rax,QWORD PTR [rsp-0x38]
  402f73:	4d 31 cc             	xor    r12,r9
  402f76:	49 31 d8             	xor    r8,rbx
  402f79:	49 8d 52 10          	lea    rdx,[r10+0x10]
  402f7d:	48 83 c0 10          	add    rax,0x10
  402f81:	4d 39 f2             	cmp    r10,r14
  402f84:	0f 84 e7 00 00 00    	je     403071 <old+0x1c1>
  402f8a:	49 89 d2             	mov    r10,rdx
  402f8d:	0f b6 50 09          	movzx  edx,BYTE PTR [rax+0x9]
  402f91:	0f b6 48 0a          	movzx  ecx,BYTE PTR [rax+0xa]
  402f95:	48 89 44 24 c8       	mov    QWORD PTR [rsp-0x38],rax
  402f9a:	31 db                	xor    ebx,ebx
  402f9c:	0f b6 78 0f          	movzx  edi,BYTE PTR [rax+0xf]
  402fa0:	0f b6 70 07          	movzx  esi,BYTE PTR [rax+0x7]
  402fa4:	45 31 c9             	xor    r9d,r9d
  402fa7:	48 c1 e1 10          	shl    rcx,0x10
  402fab:	48 c1 e2 08          	shl    rdx,0x8
  402faf:	48 c1 e7 38          	shl    rdi,0x38
  402fb3:	48 09 ca             	or     rdx,rcx
  402fb6:	0f b6 48 08          	movzx  ecx,BYTE PTR [rax+0x8]
  402fba:	48 c1 e6 38          	shl    rsi,0x38
  402fbe:	48 09 ca             	or     rdx,rcx
  402fc1:	0f b6 48 0b          	movzx  ecx,BYTE PTR [rax+0xb]
  402fc5:	48 c1 e1 18          	shl    rcx,0x18
  402fc9:	48 09 d1             	or     rcx,rdx
  402fcc:	0f b6 50 0c          	movzx  edx,BYTE PTR [rax+0xc]
  402fd0:	48 c1 e2 20          	shl    rdx,0x20
  402fd4:	48 09 ca             	or     rdx,rcx
  402fd7:	0f b6 48 0d          	movzx  ecx,BYTE PTR [rax+0xd]
  402fdb:	48 c1 e1 28          	shl    rcx,0x28
  402fdf:	48 09 d1             	or     rcx,rdx
  402fe2:	0f b6 50 0e          	movzx  edx,BYTE PTR [rax+0xe]
  402fe6:	48 c1 e2 30          	shl    rdx,0x30
  402fea:	48 09 ca             	or     rdx,rcx
  402fed:	0f b6 48 02          	movzx  ecx,BYTE PTR [rax+0x2]
  402ff1:	48 09 d7             	or     rdi,rdx
  402ff4:	0f b6 50 01          	movzx  edx,BYTE PTR [rax+0x1]
  402ff8:	49 33 ba 08 b2 40 00 	xor    rdi,QWORD PTR [r10+0x40b208]
  402fff:	48 c1 e1 10          	shl    rcx,0x10
  403003:	48 c1 e2 08          	shl    rdx,0x8
  403007:	48 09 ca             	or     rdx,rcx
  40300a:	0f b6 08             	movzx  ecx,BYTE PTR [rax]
  40300d:	48 09 ca             	or     rdx,rcx
  403010:	0f b6 48 03          	movzx  ecx,BYTE PTR [rax+0x3]
  403014:	48 c1 e1 18          	shl    rcx,0x18
  403018:	48 09 d1             	or     rcx,rdx
  40301b:	0f b6 50 04          	movzx  edx,BYTE PTR [rax+0x4]
  40301f:	48 c1 e2 20          	shl    rdx,0x20
  403023:	48 09 ca             	or     rdx,rcx
  403026:	0f b6 48 05          	movzx  ecx,BYTE PTR [rax+0x5]
  40302a:	48 c1 e1 28          	shl    rcx,0x28
  40302e:	48 09 d1             	or     rcx,rdx
  403031:	0f b6 50 06          	movzx  edx,BYTE PTR [rax+0x6]
  403035:	48 c1 e2 30          	shl    rdx,0x30
  403039:	48 09 ca             	or     rdx,rcx
  40303c:	48 09 d6             	or     rsi,rdx
  40303f:	49 33 b2 00 b2 40 00 	xor    rsi,QWORD PTR [r10+0x40b200]
  403046:	31 c9                	xor    ecx,ecx
  403048:	48 89 fa             	mov    rdx,rdi
  40304b:	49 89 f3             	mov    r11,rsi
  40304e:	48 d3 ea             	shr    rdx,cl
  403051:	49 d3 e3             	shl    r11,cl
  403054:	83 e2 01             	and    edx,0x1
  403057:	48 f7 da             	neg    rdx
  40305a:	49 21 d3             	and    r11,rdx
  40305d:	4d 31 d9             	xor    r9,r11
  403060:	44 8d 59 01          	lea    r11d,[rcx+0x1]
  403064:	85 c9                	test   ecx,ecx
  403066:	0f 85 e4 fe ff ff    	jne    402f50 <old+0xa0>
  40306c:	44 89 d9             	mov    ecx,r11d
  40306f:	eb d7                	jmp    403048 <old+0x198>
  403071:	48 8b 44 24 d0       	mov    rax,QWORD PTR [rsp-0x30]
  403076:	83 e0 0f             	and    eax,0xf
  403079:	48 85 c0             	test   rax,rax
  40307c:	0f 84 6f 01 00 00    	je     4031f1 <old+0x341>
  403082:	43 0f b6 3c 2f       	movzx  edi,BYTE PTR [r15+r13*1]
  403087:	48 83 f8 01          	cmp    rax,0x1
  40308b:	74 7f                	je     40310c <old+0x25c>
  40308d:	43 0f b6 54 2f 01    	movzx  edx,BYTE PTR [r15+r13*1+0x1]
  403093:	48 c1 e2 08          	shl    rdx,0x8
  403097:	48 09 d7             	or     rdi,rdx
  40309a:	48 83 f8 02          	cmp    rax,0x2
  40309e:	74 6c                	je     40310c <old+0x25c>
  4030a0:	43 0f b6 54 2f 02    	movzx  edx,BYTE PTR [r15+r13*1+0x2]
  4030a6:	48 c1 e2 10          	shl    rdx,0x10
  4030aa:	48 09 d7             	or     rdi,rdx
  4030ad:	48 83 f8 03          	cmp    rax,0x3
  4030b1:	74 59                	je     40310c <old+0x25c>
  4030b3:	43 0f b6 54 2f 03    	movzx  edx,BYTE PTR [r15+r13*1+0x3]
  4030b9:	48 c1 e2 18          	shl    rdx,0x18
  4030bd:	48 09 d7             	or     rdi,rdx
  4030c0:	48 83 f8 04          	cmp    rax,0x4
  4030c4:	74 46                	je     40310c <old+0x25c>
  4030c6:	43 0f b6 54 2f 04    	movzx  edx,BYTE PTR [r15+r13*1+0x4]
  4030cc:	48 c1 e2 20          	shl    rdx,0x20
  4030d0:	48 09 d7             	or     rdi,rdx
  4030d3:	48 83 f8 05          	cmp    rax,0x5
  4030d7:	74 33                	je     40310c <old+0x25c>
  4030d9:	43 0f b6 54 2f 05    	movzx  edx,BYTE PTR [r15+r13*1+0x5]
  4030df:	48 c1 e2 28          	shl    rdx,0x28
  4030e3:	48 09 d7             	or     rdi,rdx
  4030e6:	48 83 f8 06          	cmp    rax,0x6
  4030ea:	74 20                	je     40310c <old+0x25c>
  4030ec:	43 0f b6 54 2f 06    	movzx  edx,BYTE PTR [r15+r13*1+0x6]
  4030f2:	48 c1 e2 30          	shl    rdx,0x30
  4030f6:	48 09 d7             	or     rdi,rdx
  4030f9:	48 83 f8 07          	cmp    rax,0x7
  4030fd:	76 0d                	jbe    40310c <old+0x25c>
  4030ff:	43 0f b6 54 2f 07    	movzx  edx,BYTE PTR [r15+r13*1+0x7]
  403105:	48 c1 e2 38          	shl    rdx,0x38
  403109:	48 09 d7             	or     rdi,rdx
  40310c:	49 33 bd 00 b2 40 00 	xor    rdi,QWORD PTR [r13+0x40b200]
  403113:	49 8d 4d 08          	lea    rcx,[r13+0x8]
  403117:	45 31 c9             	xor    r9d,r9d
  40311a:	48 83 f8 08          	cmp    rax,0x8
  40311e:	76 7c                	jbe    40319c <old+0x2ec>
  403120:	47 0f b6 4c 2f 08    	movzx  r9d,BYTE PTR [r15+r13*1+0x8]
  403126:	48 8d 50 f8          	lea    rdx,[rax-0x8]
  40312a:	48 83 f8 09          	cmp    rax,0x9
  40312e:	74 6c                	je     40319c <old+0x2ec>
  403130:	43 0f b6 44 2f 09    	movzx  eax,BYTE PTR [r15+r13*1+0x9]
  403136:	48 c1 e0 08          	shl    rax,0x8
  40313a:	49 09 c1             	or     r9,rax
  40313d:	48 83 fa 02          	cmp    rdx,0x2
  403141:	74 59                	je     40319c <old+0x2ec>
  403143:	43 0f b6 44 2f 0a    	movzx  eax,BYTE PTR [r15+r13*1+0xa]
  403149:	48 c1 e0 10          	shl    rax,0x10
  40314d:	49 09 c1             	or     r9,rax
  403150:	48 83 fa 03          	cmp    rdx,0x3
  403154:	74 46                	je     40319c <old+0x2ec>
  403156:	43 0f b6 44 2f 0b    	movzx  eax,BYTE PTR [r15+r13*1+0xb]
  40315c:	48 c1 e0 18          	shl    rax,0x18
  403160:	49 09 c1             	or     r9,rax
  403163:	48 83 fa 04          	cmp    rdx,0x4
  403167:	74 33                	je     40319c <old+0x2ec>
  403169:	43 0f b6 44 2f 0c    	movzx  eax,BYTE PTR [r15+r13*1+0xc]
  40316f:	48 c1 e0 20          	shl    rax,0x20
  403173:	49 09 c1             	or     r9,rax
  403176:	48 83 fa 05          	cmp    rdx,0x5
  40317a:	74 20                	je     40319c <old+0x2ec>
  40317c:	43 0f b6 44 2f 0d    	movzx  eax,BYTE PTR [r15+r13*1+0xd]
  403182:	48 c1 e0 28          	shl    rax,0x28
  403186:	49 09 c1             	or     r9,rax
  403189:	48 83 fa 07          	cmp    rdx,0x7
  40318d:	75 0d                	jne    40319c <old+0x2ec>
  40318f:	43 0f b6 44 2f 0e    	movzx  eax,BYTE PTR [r15+r13*1+0xe]
  403195:	48 c1 e0 30          	shl    rax,0x30
  403199:	49 09 c1             	or     r9,rax
  40319c:	4c 33 89 00 b2 40 00 	xor    r9,QWORD PTR [rcx+0x40b200]
  4031a3:	45 31 d2             	xor    r10d,r10d
  4031a6:	31 f6                	xor    esi,esi
  4031a8:	31 c9                	xor    ecx,ecx
  4031aa:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  4031b0:	4c 89 c8             	mov    rax,r9
  4031b3:	48 89 fa             	mov    rdx,rdi
  4031b6:	48 d3 e8             	shr    rax,cl
  4031b9:	48 d3 e2             	shl    rdx,cl
  4031bc:	83 e0 01             	and    eax,0x1
  4031bf:	48 f7 d8             	neg    rax
  4031c2:	48 21 c2             	and    rdx,rax
  4031c5:	48 31 d6             	xor    rsi,rdx
  4031c8:	8d 51 01             	lea    edx,[rcx+0x1]
  4031cb:	85 c9                	test   ecx,ecx
  4031cd:	0f 84 8d 00 00 00    	je     403260 <old+0x3b0>
  4031d3:	b9 41 00 00 00       	mov    ecx,0x41
  4031d8:	48 89 fb             	mov    rbx,rdi
  4031db:	29 d1                	sub    ecx,edx
  4031dd:	48 d3 eb             	shr    rbx,cl
  4031e0:	48 21 d8             	and    rax,rbx
  4031e3:	49 31 c2             	xor    r10,rax
  4031e6:	83 fa 40             	cmp    edx,0x40
  4031e9:	75 75                	jne    403260 <old+0x3b0>
  4031eb:	49 31 f4             	xor    r12,rsi
  4031ee:	4d 31 d0             	xor    r8,r10
  4031f1:	48 2b 6c 24 d0       	sub    rbp,QWORD PTR [rsp-0x30]
  4031f6:	75 0b                	jne    403203 <old+0x353>
  4031f8:	48 8b 44 24 d8       	mov    rax,QWORD PTR [rsp-0x28]
  4031fd:	49 31 c4             	xor    r12,rax
  403200:	49 31 c0             	xor    r8,rax
  403203:	48 8b 54 24 e0       	mov    rdx,QWORD PTR [rsp-0x20]
  403208:	4c 33 44 24 f0       	xor    r8,QWORD PTR [rsp-0x10]
  40320d:	b9 40 00 00 00       	mov    ecx,0x40
  403212:	31 f6                	xor    esi,esi
  403214:	48 33 54 24 e8       	xor    rdx,QWORD PTR [rsp-0x18]
  403219:	48 89 d0             	mov    rax,rdx
  40321c:	48 d1 ea             	shr    rdx,1
  40321f:	83 e0 01             	and    eax,0x1
  403222:	48 f7 d8             	neg    rax
  403225:	4c 21 c0             	and    rax,r8
  403228:	48 31 c6             	xor    rsi,rax
  40322b:	4b 8d 04 00          	lea    rax,[r8+r8*1]
  40322f:	49 c1 f8 3f          	sar    r8,0x3f
  403233:	41 83 e0 1b          	and    r8d,0x1b
  403237:	49 31 c0             	xor    r8,rax
  40323a:	83 e9 01             	sub    ecx,0x1
  40323d:	75 da                	jne    403219 <old+0x369>
  40323f:	4c 31 e6             	xor    rsi,r12
  403242:	48 89 74 24 e0       	mov    QWORD PTR [rsp-0x20],rsi
  403247:	48 85 ed             	test   rbp,rbp
  40324a:	74 29                	je     403275 <old+0x3c5>
  40324c:	4c 03 7c 24 d0       	add    r15,QWORD PTR [rsp-0x30]
  403251:	e9 b8 fc ff ff       	jmp    402f0e <old+0x5e>
  403256:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  40325d:	00 00 00 
  403260:	89 d1                	mov    ecx,edx
  403262:	e9 49 ff ff ff       	jmp    4031b0 <old+0x300>
  403267:	45 31 c0             	xor    r8d,r8d
  40326a:	45 31 e4             	xor    r12d,r12d
  40326d:	45 31 ed             	xor    r13d,r13d
  403270:	e9 04 fe ff ff       	jmp    403079 <old+0x1c9>
  403275:	48 8b 15 c4 83 00 00 	mov    rdx,QWORD PTR [rip+0x83c4]        # 40b640 <oldx+0x440>
  40327c:	31 c0                	xor    eax,eax
  40327e:	bf 40 00 00 00       	mov    edi,0x40
  403283:	48 01 f2             	add    rdx,rsi
  403286:	48 89 d1             	mov    rcx,rdx
  403289:	49 89 d0             	mov    r8,rdx
  40328c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  403290:	4c 89 c6             	mov    rsi,r8
  403293:	49 d1 e8             	shr    r8,1
  403296:	83 e6 01             	and    esi,0x1
  403299:	48 f7 de             	neg    rsi
  40329c:	48 21 ce             	and    rsi,rcx
  40329f:	48 31 f0             	xor    rax,rsi
  4032a2:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
  4032a6:	48 c1 f9 3f          	sar    rcx,0x3f
  4032aa:	83 e1 1b             	and    ecx,0x1b
  4032ad:	48 31 f1             	xor    rcx,rsi
  4032b0:	83 ef 01             	sub    edi,0x1
  4032b3:	75 db                	jne    403290 <old+0x3e0>
  4032b5:	48 8b 3d 64 83 00 00 	mov    rdi,QWORD PTR [rip+0x8364]        # 40b620 <oldx+0x420>
  4032bc:	31 f6                	xor    esi,esi
  4032be:	41 b8 40 00 00 00    	mov    r8d,0x40
  4032c4:	48 31 d7             	xor    rdi,rdx
  4032c7:	48 31 c7             	xor    rdi,rax
  4032ca:	48 33 05 47 83 00 00 	xor    rax,QWORD PTR [rip+0x8347]        # 40b618 <oldx+0x418>
  4032d1:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  4032d8:	48 89 f9             	mov    rcx,rdi
  4032db:	48 d1 ef             	shr    rdi,1
  4032de:	83 e1 01             	and    ecx,0x1
  4032e1:	48 f7 d9             	neg    rcx
  4032e4:	48 21 c1             	and    rcx,rax
  4032e7:	48 31 ce             	xor    rsi,rcx
  4032ea:	48 8d 0c 00          	lea    rcx,[rax+rax*1]
  4032ee:	48 c1 f8 3f          	sar    rax,0x3f
  4032f2:	83 e0 1b             	and    eax,0x1b
  4032f5:	48 31 c8             	xor    rax,rcx
  4032f8:	41 83 e8 01          	sub    r8d,0x1
  4032fc:	75 da                	jne    4032d8 <old+0x428>
  4032fe:	48 8b 05 23 83 00 00 	mov    rax,QWORD PTR [rip+0x8323]        # 40b628 <oldx+0x428>
  403305:	48 33 35 24 83 00 00 	xor    rsi,QWORD PTR [rip+0x8324]        # 40b630 <oldx+0x430>
  40330c:	48 89 f1             	mov    rcx,rsi
  40330f:	be 40 00 00 00       	mov    esi,0x40
  403314:	48 31 d0             	xor    rax,rdx
  403317:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  40331e:	00 00 
  403320:	48 89 ca             	mov    rdx,rcx
  403323:	48 d1 e9             	shr    rcx,1
  403326:	83 e2 01             	and    edx,0x1
  403329:	48 f7 da             	neg    rdx
  40332c:	48 21 c2             	and    rdx,rax
  40332f:	48 31 d5             	xor    rbp,rdx
  403332:	48 8d 14 00          	lea    rdx,[rax+rax*1]
  403336:	48 c1 f8 3f          	sar    rax,0x3f
  40333a:	83 e0 1b             	and    eax,0x1b
  40333d:	48 31 d0             	xor    rax,rdx
  403340:	83 ee 01             	sub    esi,0x1
  403343:	75 db                	jne    403320 <old+0x470>
  403345:	48 8b 05 ec 82 00 00 	mov    rax,QWORD PTR [rip+0x82ec]        # 40b638 <oldx+0x438>
  40334c:	5b                   	pop    rbx
  40334d:	48 31 e8             	xor    rax,rbp
  403350:	5d                   	pop    rbp
  403351:	41 5c                	pop    r12
  403353:	41 5d                	pop    r13
  403355:	41 5e                	pop    r14
  403357:	41 5f                	pop    r15
  403359:	c3                   	ret    
  40335a:	89 f0                	mov    eax,esi
  40335c:	0f a2                	cpuid  
  40335e:	85 c0                	test   eax,eax
  403360:	74 6a                	je     4033cc <old+0x51c>
  403362:	b8 01 00 00 00       	mov    eax,0x1
  403367:	0f a2                	cpuid  
  403369:	81 e1 02 02 00 18    	and    ecx,0x18000202
  40336f:	81 f9 02 02 00 18    	cmp    ecx,0x18000202
  403375:	75 55                	jne    4033cc <old+0x51c>
  403377:	89 f1                	mov    ecx,esi
  403379:	0f 01 d0             	xgetbv 
  40337c:	89 c7                	mov    edi,eax
  40337e:	83 e0 06             	and    eax,0x6
  403381:	83 f8 06             	cmp    eax,0x6
  403384:	75 46                	jne    4033cc <old+0x51c>
  403386:	89 f0                	mov    eax,esi
  403388:	0f a2                	cpuid  
  40338a:	83 f8 06             	cmp    eax,0x6
  40338d:	76 3d                	jbe    4033cc <old+0x51c>
  40338f:	b8 07 00 00 00       	mov    eax,0x7
  403394:	89 f1                	mov    ecx,esi
  403396:	0f a2                	cpuid  
  403398:	f6 c3 20             	test   bl,0x20
  40339b:	74 2f                	je     4033cc <old+0x51c>
  40339d:	81 e7 e6 00 00 00    	and    edi,0xe6
  4033a3:	81 ff e6 00 00 00    	cmp    edi,0xe6
  4033a9:	74 30                	je     4033db <old+0x52b>
  4033ab:	c7 05 d3 7c 00 00 02 	mov    DWORD PTR [rip+0x7cd3],0x2        # 40b088 <cached.2>
  4033b2:	00 00 00 
  4033b5:	48 8b 74 24 d8       	mov    rsi,QWORD PTR [rsp-0x28]
  4033ba:	4c 89 ff             	mov    rdi,r15
  4033bd:	5b                   	pop    rbx
  4033be:	5d                   	pop    rbp
  4033bf:	41 5c                	pop    r12
  4033c1:	41 5d                	pop    r13
  4033c3:	41 5e                	pop    r14
  4033c5:	41 5f                	pop    r15
  4033c7:	e9 c4 f6 ff ff       	jmp    402a90 <chainhash_x86_avx2.constprop.0>
  4033cc:	c7 05 b2 7c 00 00 01 	mov    DWORD PTR [rip+0x7cb2],0x1        # 40b088 <cached.2>
  4033d3:	00 00 00 
  4033d6:	e9 0a fb ff ff       	jmp    402ee5 <old+0x35>
  4033db:	81 e3 00 00 01 00    	and    ebx,0x10000
  4033e1:	74 c8                	je     4033ab <old+0x4fb>
  4033e3:	80 e5 04             	and    ch,0x4
  4033e6:	74 c3                	je     4033ab <old+0x4fb>
  4033e8:	c7 05 96 7c 00 00 03 	mov    DWORD PTR [rip+0x7c96],0x3        # 40b088 <cached.2>
  4033ef:	00 00 00 
  4033f2:	48 8b 74 24 d8       	mov    rsi,QWORD PTR [rsp-0x28]
  4033f7:	4c 89 ff             	mov    rdi,r15
  4033fa:	5b                   	pop    rbx
  4033fb:	5d                   	pop    rbp
  4033fc:	41 5c                	pop    r12
  4033fe:	41 5d                	pop    r13
  403400:	41 5e                	pop    r14
  403402:	41 5f                	pop    r15
  403404:	e9 67 ee ff ff       	jmp    402270 <chainhash_x86_avx512.constprop.0>
  403409:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000403410 <chv3_bulk512.constprop.0>:
  403410:	55                   	push   rbp
  403411:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  403415:	c4 e1 f9 6e ca       	vmovq  xmm1,rdx
  40341a:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  40341e:	c4 e3 7d 38 c1 01    	vinserti128 ymm0,ymm0,xmm1,0x1
  403424:	62 f3 e5 48 3a d8 01 	vinserti64x4 zmm3,zmm3,ymm0,0x1
  40342b:	48 89 e5             	mov    rbp,rsp
  40342e:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  403432:	48 83 ec 48          	sub    rsp,0x48
  403436:	62 f2 7d 48 5a 25 f0 	vbroadcasti32x4 zmm4,XMMWORD PTR [rip+0x82f0]        # 40b730 <v3+0xd0>
  40343d:	82 00 00 
  403440:	c5 f9 6f 35 38 83 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x8338]        # 40b780 <v3+0x120>
  403447:	00 
  403448:	c5 49 c6 1d 6f 83 00 	vshufpd xmm11,xmm6,XMMWORD PTR [rip+0x836f],0x2        # 40b7c0 <v3+0x160>
  40344f:	00 02 
  403451:	62 53 25 48 43 db 00 	vshufi32x4 zmm11,zmm11,zmm11,0x0
  403458:	62 f2 7d 48 5a 35 de 	vbroadcasti32x4 zmm6,XMMWORD PTR [rip+0x82de]        # 40b740 <v3+0xe0>
  40345f:	82 00 00 
  403462:	62 62 7d 48 5a 3d f4 	vbroadcasti32x4 zmm31,XMMWORD PTR [rip+0x81f4]        # 40b660 <v3>
  403469:	81 00 00 
  40346c:	62 f1 7d 48 7f a4 24 	vmovdqa32 ZMMWORD PTR [rsp+0x8],zmm4
  403473:	08 00 00 00 
  403477:	62 f2 7d 48 5a 25 cf 	vbroadcasti32x4 zmm4,XMMWORD PTR [rip+0x82cf]        # 40b750 <v3+0xf0>
  40347e:	82 00 00 
  403481:	62 62 7d 48 5a 35 e5 	vbroadcasti32x4 zmm30,XMMWORD PTR [rip+0x81e5]        # 40b670 <v3+0x10>
  403488:	81 00 00 
  40348b:	62 62 7d 48 5a 2d eb 	vbroadcasti32x4 zmm29,XMMWORD PTR [rip+0x81eb]        # 40b680 <v3+0x20>
  403492:	81 00 00 
  403495:	62 62 7d 48 5a 25 f1 	vbroadcasti32x4 zmm28,XMMWORD PTR [rip+0x81f1]        # 40b690 <v3+0x30>
  40349c:	81 00 00 
  40349f:	62 f1 7d 48 7f b4 24 	vmovdqa32 ZMMWORD PTR [rsp-0x38],zmm6
  4034a6:	c8 ff ff ff 
  4034aa:	62 62 7d 48 5a 1d ec 	vbroadcasti32x4 zmm27,XMMWORD PTR [rip+0x81ec]        # 40b6a0 <v3+0x40>
  4034b1:	81 00 00 
  4034b4:	62 62 7d 48 5a 15 f2 	vbroadcasti32x4 zmm26,XMMWORD PTR [rip+0x81f2]        # 40b6b0 <v3+0x50>
  4034bb:	81 00 00 
  4034be:	62 f1 7d 48 7f a4 24 	vmovdqa32 ZMMWORD PTR [rsp-0x78],zmm4
  4034c5:	88 ff ff ff 
  4034c9:	62 62 7d 48 5a 0d ed 	vbroadcasti32x4 zmm25,XMMWORD PTR [rip+0x81ed]        # 40b6c0 <v3+0x60>
  4034d0:	81 00 00 
  4034d3:	62 62 7d 48 5a 05 f3 	vbroadcasti32x4 zmm24,XMMWORD PTR [rip+0x81f3]        # 40b6d0 <v3+0x70>
  4034da:	81 00 00 
  4034dd:	62 e2 7d 48 5a 3d f9 	vbroadcasti32x4 zmm23,XMMWORD PTR [rip+0x81f9]        # 40b6e0 <v3+0x80>
  4034e4:	81 00 00 
  4034e7:	62 e2 7d 48 5a 35 ff 	vbroadcasti32x4 zmm22,XMMWORD PTR [rip+0x81ff]        # 40b6f0 <v3+0x90>
  4034ee:	81 00 00 
  4034f1:	62 e2 7d 48 5a 2d 05 	vbroadcasti32x4 zmm21,XMMWORD PTR [rip+0x8205]        # 40b700 <v3+0xa0>
  4034f8:	82 00 00 
  4034fb:	62 e2 7d 48 5a 25 0b 	vbroadcasti32x4 zmm20,XMMWORD PTR [rip+0x820b]        # 40b710 <v3+0xb0>
  403502:	82 00 00 
  403505:	62 e2 7d 48 5a 1d 11 	vbroadcasti32x4 zmm19,XMMWORD PTR [rip+0x8211]        # 40b720 <v3+0xc0>
  40350c:	82 00 00 
  40350f:	90                   	nop
  403510:	62 f1 0d 40 ef 4f 01 	vpxord zmm1,zmm30,ZMMWORD PTR [rdi+0x40]
  403517:	62 f1 05 40 ef 07    	vpxord zmm0,zmm31,ZMMWORD PTR [rdi]
  40351d:	48 81 c7 00 04 00 00 	add    rdi,0x400
  403524:	62 f1 15 40 ef 67 f2 	vpxord zmm4,zmm29,ZMMWORD PTR [rdi-0x380]
  40352b:	62 f1 25 40 ef 57 f4 	vpxord zmm2,zmm27,ZMMWORD PTR [rdi-0x300]
  403532:	62 e3 7d 48 44 c9 11 	vpclmulhqhqdq zmm17,zmm0,zmm1
  403539:	62 71 35 40 ef 57 f6 	vpxord zmm10,zmm25,ZMMWORD PTR [rdi-0x280]
  403540:	62 71 45 40 ef 4f f8 	vpxord zmm9,zmm23,ZMMWORD PTR [rdi-0x200]
  403547:	62 f3 7d 48 44 c1 00 	vpclmullqlqdq zmm0,zmm0,zmm1
  40354e:	62 f1 7d 48 6f bc 24 	vmovdqa32 zmm7,ZMMWORD PTR [rsp+0x8]
  403555:	08 00 00 00 
  403559:	62 f1 1d 40 ef 4f f3 	vpxord zmm1,zmm28,ZMMWORD PTR [rdi-0x340]
  403560:	62 f1 45 48 ef 7f fd 	vpxord zmm7,zmm7,ZMMWORD PTR [rdi-0xc0]
  403567:	62 71 7d 48 6f ac 24 	vmovdqa32 zmm13,ZMMWORD PTR [rsp-0x78]
  40356e:	88 ff ff ff 
  403572:	62 e3 5d 48 44 d1 11 	vpclmulhqhqdq zmm18,zmm4,zmm1
  403579:	62 71 15 48 ef 67 ff 	vpxord zmm12,zmm13,ZMMWORD PTR [rdi-0x40]
  403580:	62 f1 5d 40 ef 6f fb 	vpxord zmm5,zmm20,ZMMWORD PTR [rdi-0x140]
  403587:	62 f3 5d 48 44 e1 00 	vpclmullqlqdq zmm4,zmm4,zmm1
  40358e:	62 f1 2d 40 ef 4f f5 	vpxord zmm1,zmm26,ZMMWORD PTR [rdi-0x2c0]
  403595:	62 71 65 40 ef 47 fc 	vpxord zmm8,zmm19,ZMMWORD PTR [rdi-0x100]
  40359c:	62 e3 6d 48 44 c1 11 	vpclmulhqhqdq zmm16,zmm2,zmm1
  4035a3:	62 f3 6d 48 44 d1 00 	vpclmullqlqdq zmm2,zmm2,zmm1
  4035aa:	62 b1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm17
  4035b0:	62 f1 3d 40 ef 4f f7 	vpxord zmm1,zmm24,ZMMWORD PTR [rdi-0x240]
  4035b7:	62 f3 2d 48 44 f1 11 	vpclmulhqhqdq zmm6,zmm10,zmm1
  4035be:	62 73 2d 48 44 d1 00 	vpclmullqlqdq zmm10,zmm10,zmm1
  4035c5:	62 b1 5d 48 ef e2    	vpxord zmm4,zmm4,zmm18
  4035cb:	62 f1 4d 40 ef 4f f9 	vpxord zmm1,zmm22,ZMMWORD PTR [rdi-0x1c0]
  4035d2:	62 f1 5d 48 ef c0    	vpxord zmm0,zmm4,zmm0
  4035d8:	62 73 35 48 44 f9 11 	vpclmulhqhqdq zmm15,zmm9,zmm1
  4035df:	62 73 35 48 44 c9 00 	vpclmullqlqdq zmm9,zmm9,zmm1
  4035e6:	62 b1 6d 48 ef d0    	vpxord zmm2,zmm2,zmm16
  4035ec:	62 f1 55 40 ef 4f fa 	vpxord zmm1,zmm21,ZMMWORD PTR [rdi-0x180]
  4035f3:	62 73 75 48 44 f5 11 	vpclmulhqhqdq zmm14,zmm1,zmm5
  4035fa:	62 f3 75 48 44 cd 00 	vpclmullqlqdq zmm1,zmm1,zmm5
  403601:	62 d1 6d 48 ef d2    	vpxord zmm2,zmm2,zmm10
  403607:	62 f3 3d 48 44 ef 11 	vpclmulhqhqdq zmm5,zmm8,zmm7
  40360e:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
  403614:	62 73 3d 48 44 c7 00 	vpclmullqlqdq zmm8,zmm8,zmm7
  40361b:	62 f1 7d 48 6f bc 24 	vmovdqa32 zmm7,ZMMWORD PTR [rsp-0x38]
  403622:	c8 ff ff ff 
  403626:	62 f1 45 48 ef 7f fe 	vpxord zmm7,zmm7,ZMMWORD PTR [rdi-0x80]
  40362d:	62 d1 4d 48 ef f1    	vpxord zmm6,zmm6,zmm9
  403633:	62 53 45 48 44 ec 11 	vpclmulhqhqdq zmm13,zmm7,zmm12
  40363a:	62 d1 4d 48 ef f7    	vpxord zmm6,zmm6,zmm15
  403640:	62 d3 45 48 44 fc 00 	vpclmullqlqdq zmm7,zmm7,zmm12
  403647:	62 f1 7d 48 ef c6    	vpxord zmm0,zmm0,zmm6
  40364d:	62 53 65 48 44 e3 11 	vpclmulhqhqdq zmm12,zmm3,zmm11
  403654:	62 d1 75 48 ef ce    	vpxord zmm1,zmm1,zmm14
  40365a:	62 d3 65 48 44 db 00 	vpclmullqlqdq zmm3,zmm3,zmm11
  403661:	62 d1 75 48 ef c8    	vpxord zmm1,zmm1,zmm8
  403667:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
  40366d:	62 f1 55 48 ef ef    	vpxord zmm5,zmm5,zmm7
  403673:	62 d1 55 48 ef ed    	vpxord zmm5,zmm5,zmm13
  403679:	62 f1 7d 48 ef c5    	vpxord zmm0,zmm0,zmm5
  40367f:	62 d1 65 48 ef dc    	vpxord zmm3,zmm3,zmm12
  403685:	62 f1 7d 48 ef db    	vpxord zmm3,zmm0,zmm3
  40368b:	48 83 ee 01          	sub    rsi,0x1
  40368f:	0f 85 7b fe ff ff    	jne    403510 <chv3_bulk512.constprop.0+0x100>
  403695:	c5 fa 7e 35 c3 80 00 	vmovq  xmm6,QWORD PTR [rip+0x80c3]        # 40b760 <v3+0x100>
  40369c:	00 
  40369d:	c4 e3 c9 22 05 01 81 	vpinsrq xmm0,xmm6,QWORD PTR [rip+0x8101],0x1        # 40b7a8 <v3+0x148>
  4036a4:	00 00 01 
  4036a7:	c5 fa 7e 35 b9 80 00 	vmovq  xmm6,QWORD PTR [rip+0x80b9]        # 40b768 <v3+0x108>
  4036ae:	00 
  4036af:	c4 e3 c9 22 0d f7 80 	vpinsrq xmm1,xmm6,QWORD PTR [rip+0x80f7],0x1        # 40b7b0 <v3+0x150>
  4036b6:	00 00 01 
  4036b9:	c5 fa 7e 35 af 80 00 	vmovq  xmm6,QWORD PTR [rip+0x80af]        # 40b770 <v3+0x110>
  4036c0:	00 
  4036c1:	c4 e3 c9 22 15 ed 80 	vpinsrq xmm2,xmm6,QWORD PTR [rip+0x80ed],0x1        # 40b7b8 <v3+0x158>
  4036c8:	00 00 01 
  4036cb:	c4 e3 75 38 c8 01    	vinserti128 ymm1,ymm1,xmm0,0x1
  4036d1:	c5 fa 7e 35 9f 80 00 	vmovq  xmm6,QWORD PTR [rip+0x809f]        # 40b778 <v3+0x118>
  4036d8:	00 
  4036d9:	c4 e3 c9 22 05 dd 80 	vpinsrq xmm0,xmm6,QWORD PTR [rip+0x80dd],0x1        # 40b7c0 <v3+0x160>
  4036e0:	00 00 01 
  4036e3:	c4 e3 7d 38 c2 01    	vinserti128 ymm0,ymm0,xmm2,0x1
  4036e9:	62 f3 fd 48 3a c1 01 	vinserti64x4 zmm0,zmm0,ymm1,0x1
  4036f0:	62 f3 65 48 44 c8 11 	vpclmulhqhqdq zmm1,zmm3,zmm0
  4036f7:	62 f3 65 48 44 d8 00 	vpclmullqlqdq zmm3,zmm3,zmm0
  4036fe:	62 f1 65 48 ef d9    	vpxord zmm3,zmm3,zmm1
  403704:	62 f3 fd 48 3b d9 01 	vextracti64x4 ymm1,zmm3,0x1
  40370b:	c5 f5 ef cb          	vpxor  ymm1,ymm1,ymm3
  40370f:	c4 e3 7d 39 c8 01    	vextracti128 xmm0,ymm1,0x1
  403715:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  403719:	c4 e3 f9 16 c1 01    	vpextrq rcx,xmm0,0x1
  40371f:	48 89 ca             	mov    rdx,rcx
  403722:	48 89 c8             	mov    rax,rcx
  403725:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
  403729:	48 c1 e8 3d          	shr    rax,0x3d
  40372d:	48 c1 ea 3f          	shr    rdx,0x3f
  403731:	48 31 c2             	xor    rdx,rax
  403734:	48 89 c8             	mov    rax,rcx
  403737:	48 c1 e8 3c          	shr    rax,0x3c
  40373b:	48 31 c2             	xor    rdx,rax
  40373e:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  403743:	48 31 c8             	xor    rax,rcx
  403746:	48 31 f0             	xor    rax,rsi
  403749:	48 8d 34 cd 00 00 00 	lea    rsi,[rcx*8+0x0]
  403750:	00 
  403751:	48 c1 e1 04          	shl    rcx,0x4
  403755:	48 31 f0             	xor    rax,rsi
  403758:	48 31 c8             	xor    rax,rcx
  40375b:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
  40375f:	48 31 d0             	xor    rax,rdx
  403762:	48 31 c8             	xor    rax,rcx
  403765:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
  40376c:	00 
  40376d:	48 c1 e2 04          	shl    rdx,0x4
  403771:	48 31 c8             	xor    rax,rcx
  403774:	48 31 d0             	xor    rax,rdx
  403777:	c5 f8 77             	vzeroupper 
  40377a:	c9                   	leave  
  40377b:	c3                   	ret    
  40377c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000403780 <v3z>:
  403780:	41 57                	push   r15
  403782:	49 89 f8             	mov    r8,rdi
  403785:	41 56                	push   r14
  403787:	41 55                	push   r13
  403789:	41 54                	push   r12
  40378b:	49 89 f4             	mov    r12,rsi
  40378e:	55                   	push   rbp
  40378f:	41 81 e4 ff 03 00 00 	and    r12d,0x3ff
  403796:	53                   	push   rbx
  403797:	48 83 ec 68          	sub    rsp,0x68
  40379b:	48 89 74 24 10       	mov    QWORD PTR [rsp+0x10],rsi
  4037a0:	8b 05 a6 78 00 00    	mov    eax,DWORD PTR [rip+0x78a6]        # 40b04c <cache.5>
  4037a6:	85 c0                	test   eax,eax
  4037a8:	0f 88 83 06 00 00    	js     403e31 <v3z+0x6b1>
  4037ae:	83 f8 04             	cmp    eax,0x4
  4037b1:	0f 84 92 06 00 00    	je     403e49 <v3z+0x6c9>
  4037b7:	83 f8 02             	cmp    eax,0x2
  4037ba:	0f 8e 89 06 00 00    	jle    403e49 <v3z+0x6c9>
  4037c0:	48 81 7c 24 10 ff 03 	cmp    QWORD PTR [rsp+0x10],0x3ff
  4037c7:	00 00 
  4037c9:	0f 87 a0 06 00 00    	ja     403e6f <v3z+0x6ef>
  4037cf:	4b 8d 04 20          	lea    rax,[r8+r12*1]
  4037d3:	66 0f ef c0          	pxor   xmm0,xmm0
  4037d7:	4c 8d 7c 24 60       	lea    r15,[rsp+0x60]
  4037dc:	4d 89 e6             	mov    r14,r12
  4037df:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
  4037e4:	41 bd 60 b6 40 00    	mov    r13d,0x40b660
  4037ea:	0f 29 44 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm0
  4037ef:	0f 29 44 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm0
  4037f4:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
  4037f9:	0f 29 44 24 50       	movaps XMMWORD PTR [rsp+0x50],xmm0
  4037fe:	66 90                	xchg   ax,ax
  403800:	48 8b 4c 24 18       	mov    rcx,QWORD PTR [rsp+0x18]
  403805:	4d 89 e1             	mov    r9,r12
  403808:	4c 8d 44 24 20       	lea    r8,[rsp+0x20]
  40380d:	4d 89 f2             	mov    r10,r14
  403810:	4d 29 f1             	sub    r9,r14
  403813:	4d 8d 5e f8          	lea    r11,[r14-0x8]
  403817:	49 8d 6e b8          	lea    rbp,[r14-0x48]
  40381b:	4c 29 f1             	sub    rcx,r14
  40381e:	49 8d 5e c0          	lea    rbx,[r14-0x40]
  403822:	4d 39 cc             	cmp    r12,r9
  403825:	0f 86 2c 01 00 00    	jbe    403957 <v3z+0x1d7>
  40382b:	49 8d 41 40          	lea    rax,[r9+0x40]
  40382f:	49 39 c4             	cmp    r12,rax
  403832:	0f 86 30 06 00 00    	jbe    403e68 <v3z+0x6e8>
  403838:	0f b6 41 40          	movzx  eax,BYTE PTR [rcx+0x40]
  40383c:	48 83 fb 01          	cmp    rbx,0x1
  403840:	74 71                	je     4038b3 <v3z+0x133>
  403842:	0f b6 51 41          	movzx  edx,BYTE PTR [rcx+0x41]
  403846:	48 c1 e2 08          	shl    rdx,0x8
  40384a:	48 09 d0             	or     rax,rdx
  40384d:	48 83 fb 02          	cmp    rbx,0x2
  403851:	74 60                	je     4038b3 <v3z+0x133>
  403853:	0f b6 51 42          	movzx  edx,BYTE PTR [rcx+0x42]
  403857:	48 c1 e2 10          	shl    rdx,0x10
  40385b:	48 09 d0             	or     rax,rdx
  40385e:	48 83 fb 03          	cmp    rbx,0x3
  403862:	74 4f                	je     4038b3 <v3z+0x133>
  403864:	0f b6 51 43          	movzx  edx,BYTE PTR [rcx+0x43]
  403868:	48 c1 e2 18          	shl    rdx,0x18
  40386c:	48 09 d0             	or     rax,rdx
  40386f:	48 83 fb 04          	cmp    rbx,0x4
  403873:	74 3e                	je     4038b3 <v3z+0x133>
  403875:	0f b6 51 44          	movzx  edx,BYTE PTR [rcx+0x44]
  403879:	48 c1 e2 20          	shl    rdx,0x20
  40387d:	48 09 d0             	or     rax,rdx
  403880:	48 83 fb 05          	cmp    rbx,0x5
  403884:	74 2d                	je     4038b3 <v3z+0x133>
  403886:	0f b6 51 45          	movzx  edx,BYTE PTR [rcx+0x45]
  40388a:	48 c1 e2 28          	shl    rdx,0x28
  40388e:	48 09 d0             	or     rax,rdx
  403891:	48 83 fb 06          	cmp    rbx,0x6
  403895:	74 1c                	je     4038b3 <v3z+0x133>
  403897:	0f b6 51 46          	movzx  edx,BYTE PTR [rcx+0x46]
  40389b:	48 c1 e2 30          	shl    rdx,0x30
  40389f:	48 09 d0             	or     rax,rdx
  4038a2:	48 83 fb 07          	cmp    rbx,0x7
  4038a6:	74 0b                	je     4038b3 <v3z+0x133>
  4038a8:	0f b6 51 47          	movzx  edx,BYTE PTR [rcx+0x47]
  4038ac:	48 c1 e2 38          	shl    rdx,0x38
  4038b0:	48 09 d0             	or     rax,rdx
  4038b3:	49 33 45 10          	xor    rax,QWORD PTR [r13+0x10]
  4038b7:	48 89 c6             	mov    rsi,rax
  4038ba:	0f b6 01             	movzx  eax,BYTE PTR [rcx]
  4038bd:	49 83 fa 01          	cmp    r10,0x1
  4038c1:	74 71                	je     403934 <v3z+0x1b4>
  4038c3:	0f b6 51 01          	movzx  edx,BYTE PTR [rcx+0x1]
  4038c7:	48 c1 e2 08          	shl    rdx,0x8
  4038cb:	48 09 d0             	or     rax,rdx
  4038ce:	49 83 fa 02          	cmp    r10,0x2
  4038d2:	74 60                	je     403934 <v3z+0x1b4>
  4038d4:	0f b6 51 02          	movzx  edx,BYTE PTR [rcx+0x2]
  4038d8:	48 c1 e2 10          	shl    rdx,0x10
  4038dc:	48 09 d0             	or     rax,rdx
  4038df:	49 83 fa 03          	cmp    r10,0x3
  4038e3:	74 4f                	je     403934 <v3z+0x1b4>
  4038e5:	0f b6 51 03          	movzx  edx,BYTE PTR [rcx+0x3]
  4038e9:	48 c1 e2 18          	shl    rdx,0x18
  4038ed:	48 09 d0             	or     rax,rdx
  4038f0:	49 83 fa 04          	cmp    r10,0x4
  4038f4:	74 3e                	je     403934 <v3z+0x1b4>
  4038f6:	0f b6 51 04          	movzx  edx,BYTE PTR [rcx+0x4]
  4038fa:	48 c1 e2 20          	shl    rdx,0x20
  4038fe:	48 09 d0             	or     rax,rdx
  403901:	49 83 fa 05          	cmp    r10,0x5
  403905:	74 2d                	je     403934 <v3z+0x1b4>
  403907:	0f b6 51 05          	movzx  edx,BYTE PTR [rcx+0x5]
  40390b:	48 c1 e2 28          	shl    rdx,0x28
  40390f:	48 09 d0             	or     rax,rdx
  403912:	49 83 fa 06          	cmp    r10,0x6
  403916:	74 1c                	je     403934 <v3z+0x1b4>
  403918:	0f b6 51 06          	movzx  edx,BYTE PTR [rcx+0x6]
  40391c:	48 c1 e2 30          	shl    rdx,0x30
  403920:	48 09 d0             	or     rax,rdx
  403923:	49 83 fa 07          	cmp    r10,0x7
  403927:	74 0b                	je     403934 <v3z+0x1b4>
  403929:	0f b6 51 07          	movzx  edx,BYTE PTR [rcx+0x7]
  40392d:	48 c1 e2 38          	shl    rdx,0x38
  403931:	48 09 d0             	or     rax,rdx
  403934:	49 33 45 00          	xor    rax,QWORD PTR [r13+0x0]
  403938:	48 89 c7             	mov    rdi,rax
  40393b:	e8 50 e7 ff ff       	call   402090 <chv3_hwprod>
  403940:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  403944:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  403949:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  40394e:	66 41 0f ef 00       	pxor   xmm0,XMMWORD PTR [r8]
  403953:	41 0f 29 00          	movaps XMMWORD PTR [r8],xmm0
  403957:	49 8d 41 08          	lea    rax,[r9+0x8]
  40395b:	49 39 c4             	cmp    r12,rax
  40395e:	0f 86 2b 01 00 00    	jbe    403a8f <v3z+0x30f>
  403964:	49 8d 51 48          	lea    rdx,[r9+0x48]
  403968:	31 c0                	xor    eax,eax
  40396a:	49 39 d4             	cmp    r12,rdx
  40396d:	76 7b                	jbe    4039ea <v3z+0x26a>
  40396f:	0f b6 41 48          	movzx  eax,BYTE PTR [rcx+0x48]
  403973:	48 83 fd 01          	cmp    rbp,0x1
  403977:	74 71                	je     4039ea <v3z+0x26a>
  403979:	0f b6 51 49          	movzx  edx,BYTE PTR [rcx+0x49]
  40397d:	48 c1 e2 08          	shl    rdx,0x8
  403981:	48 09 d0             	or     rax,rdx
  403984:	48 83 fd 02          	cmp    rbp,0x2
  403988:	74 60                	je     4039ea <v3z+0x26a>
  40398a:	0f b6 51 4a          	movzx  edx,BYTE PTR [rcx+0x4a]
  40398e:	48 c1 e2 10          	shl    rdx,0x10
  403992:	48 09 d0             	or     rax,rdx
  403995:	48 83 fd 03          	cmp    rbp,0x3
  403999:	74 4f                	je     4039ea <v3z+0x26a>
  40399b:	0f b6 51 4b          	movzx  edx,BYTE PTR [rcx+0x4b]
  40399f:	48 c1 e2 18          	shl    rdx,0x18
  4039a3:	48 09 d0             	or     rax,rdx
  4039a6:	48 83 fd 04          	cmp    rbp,0x4
  4039aa:	74 3e                	je     4039ea <v3z+0x26a>
  4039ac:	0f b6 51 4c          	movzx  edx,BYTE PTR [rcx+0x4c]
  4039b0:	48 c1 e2 20          	shl    rdx,0x20
  4039b4:	48 09 d0             	or     rax,rdx
  4039b7:	48 83 fd 05          	cmp    rbp,0x5
  4039bb:	74 2d                	je     4039ea <v3z+0x26a>
  4039bd:	0f b6 51 4d          	movzx  edx,BYTE PTR [rcx+0x4d]
  4039c1:	48 c1 e2 28          	shl    rdx,0x28
  4039c5:	48 09 d0             	or     rax,rdx
  4039c8:	48 83 fd 06          	cmp    rbp,0x6
  4039cc:	74 1c                	je     4039ea <v3z+0x26a>
  4039ce:	0f b6 51 4e          	movzx  edx,BYTE PTR [rcx+0x4e]
  4039d2:	48 c1 e2 30          	shl    rdx,0x30
  4039d6:	48 09 d0             	or     rax,rdx
  4039d9:	48 83 fd 07          	cmp    rbp,0x7
  4039dd:	74 0b                	je     4039ea <v3z+0x26a>
  4039df:	0f b6 51 4f          	movzx  edx,BYTE PTR [rcx+0x4f]
  4039e3:	48 c1 e2 38          	shl    rdx,0x38
  4039e7:	48 09 d0             	or     rax,rdx
  4039ea:	49 33 45 18          	xor    rax,QWORD PTR [r13+0x18]
  4039ee:	48 89 c6             	mov    rsi,rax
  4039f1:	0f b6 41 08          	movzx  eax,BYTE PTR [rcx+0x8]
  4039f5:	49 83 fb 01          	cmp    r11,0x1
  4039f9:	74 71                	je     403a6c <v3z+0x2ec>
  4039fb:	0f b6 51 09          	movzx  edx,BYTE PTR [rcx+0x9]
  4039ff:	48 c1 e2 08          	shl    rdx,0x8
  403a03:	48 09 d0             	or     rax,rdx
  403a06:	49 83 fb 02          	cmp    r11,0x2
  403a0a:	74 60                	je     403a6c <v3z+0x2ec>
  403a0c:	0f b6 51 0a          	movzx  edx,BYTE PTR [rcx+0xa]
  403a10:	48 c1 e2 10          	shl    rdx,0x10
  403a14:	48 09 d0             	or     rax,rdx
  403a17:	49 83 fb 03          	cmp    r11,0x3
  403a1b:	74 4f                	je     403a6c <v3z+0x2ec>
  403a1d:	0f b6 51 0b          	movzx  edx,BYTE PTR [rcx+0xb]
  403a21:	48 c1 e2 18          	shl    rdx,0x18
  403a25:	48 09 d0             	or     rax,rdx
  403a28:	49 83 fb 04          	cmp    r11,0x4
  403a2c:	74 3e                	je     403a6c <v3z+0x2ec>
  403a2e:	0f b6 51 0c          	movzx  edx,BYTE PTR [rcx+0xc]
  403a32:	48 c1 e2 20          	shl    rdx,0x20
  403a36:	48 09 d0             	or     rax,rdx
  403a39:	49 83 fb 05          	cmp    r11,0x5
  403a3d:	74 2d                	je     403a6c <v3z+0x2ec>
  403a3f:	0f b6 51 0d          	movzx  edx,BYTE PTR [rcx+0xd]
  403a43:	48 c1 e2 28          	shl    rdx,0x28
  403a47:	48 09 d0             	or     rax,rdx
  403a4a:	49 83 fb 06          	cmp    r11,0x6
  403a4e:	74 1c                	je     403a6c <v3z+0x2ec>
  403a50:	0f b6 51 0e          	movzx  edx,BYTE PTR [rcx+0xe]
  403a54:	48 c1 e2 30          	shl    rdx,0x30
  403a58:	48 09 d0             	or     rax,rdx
  403a5b:	49 83 fb 07          	cmp    r11,0x7
  403a5f:	74 0b                	je     403a6c <v3z+0x2ec>
  403a61:	0f b6 51 0f          	movzx  edx,BYTE PTR [rcx+0xf]
  403a65:	48 c1 e2 38          	shl    rdx,0x38
  403a69:	48 09 d0             	or     rax,rdx
  403a6c:	49 33 45 08          	xor    rax,QWORD PTR [r13+0x8]
  403a70:	48 89 c7             	mov    rdi,rax
  403a73:	e8 18 e6 ff ff       	call   402090 <chv3_hwprod>
  403a78:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  403a7c:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  403a81:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  403a86:	66 41 0f ef 00       	pxor   xmm0,XMMWORD PTR [r8]
  403a8b:	41 0f 29 00          	movaps XMMWORD PTR [r8],xmm0
  403a8f:	49 83 c0 10          	add    r8,0x10
  403a93:	49 83 c1 10          	add    r9,0x10
  403a97:	49 83 eb 10          	sub    r11,0x10
  403a9b:	48 83 ed 10          	sub    rbp,0x10
  403a9f:	48 83 c1 10          	add    rcx,0x10
  403aa3:	49 83 ea 10          	sub    r10,0x10
  403aa7:	48 83 eb 10          	sub    rbx,0x10
  403aab:	4d 39 c7             	cmp    r15,r8
  403aae:	0f 85 6e fd ff ff    	jne    403822 <v3z+0xa2>
  403ab4:	49 83 c5 20          	add    r13,0x20
  403ab8:	49 83 c6 80          	add    r14,0xffffffffffffff80
  403abc:	49 81 fd 60 b7 40 00 	cmp    r13,0x40b760
  403ac3:	0f 85 37 fd ff ff    	jne    403800 <v3z+0x80>
  403ac9:	4d 8d 44 24 ff       	lea    r8,[r12-0x1]
  403ace:	49 c1 e8 04          	shr    r8,0x4
  403ad2:	41 83 c0 01          	add    r8d,0x1
  403ad6:	49 83 fc 30          	cmp    r12,0x30
  403ada:	77 13                	ja     403aef <v3z+0x36f>
  403adc:	4d 85 e4             	test   r12,r12
  403adf:	74 0e                	je     403aef <v3z+0x36f>
  403ae1:	48 8b 4c 24 10       	mov    rcx,QWORD PTR [rsp+0x10]
  403ae6:	45 85 c0             	test   r8d,r8d
  403ae9:	0f 84 a0 03 00 00    	je     403e8f <v3z+0x70f>
  403aef:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  403af4:	48 8b 35 6d 7c 00 00 	mov    rsi,QWORD PTR [rip+0x7c6d]        # 40b768 <v3+0x108>
  403afb:	e8 90 e5 ff ff       	call   402090 <chv3_hwprod>
  403b00:	4c 8b 4c 24 28       	mov    r9,QWORD PTR [rsp+0x28]
  403b05:	48 89 d7             	mov    rdi,rdx
  403b08:	49 89 d2             	mov    r10,rdx
  403b0b:	48 c1 ea 3f          	shr    rdx,0x3f
  403b0f:	48 c1 ef 3d          	shr    rdi,0x3d
  403b13:	4c 89 c9             	mov    rcx,r9
  403b16:	4c 31 d0             	xor    rax,r10
  403b19:	48 31 d7             	xor    rdi,rdx
  403b1c:	4c 89 d2             	mov    rdx,r10
  403b1f:	48 c1 e9 3f          	shr    rcx,0x3f
  403b23:	48 c1 ea 3c          	shr    rdx,0x3c
  403b27:	48 31 d7             	xor    rdi,rdx
  403b2a:	4c 89 ca             	mov    rdx,r9
  403b2d:	48 c1 ea 3d          	shr    rdx,0x3d
  403b31:	48 31 ca             	xor    rdx,rcx
  403b34:	4c 89 c9             	mov    rcx,r9
  403b37:	48 c1 e9 3c          	shr    rcx,0x3c
  403b3b:	48 31 ca             	xor    rdx,rcx
  403b3e:	48 8b 4c 24 20       	mov    rcx,QWORD PTR [rsp+0x20]
  403b43:	48 31 c1             	xor    rcx,rax
  403b46:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  403b4a:	4c 31 c9             	xor    rcx,r9
  403b4d:	48 31 c1             	xor    rcx,rax
  403b50:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  403b57:	00 
  403b58:	49 c1 e2 04          	shl    r10,0x4
  403b5c:	48 31 c1             	xor    rcx,rax
  403b5f:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  403b63:	4c 31 d1             	xor    rcx,r10
  403b66:	48 31 c1             	xor    rcx,rax
  403b69:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  403b70:	00 
  403b71:	49 c1 e1 04          	shl    r9,0x4
  403b75:	48 31 c1             	xor    rcx,rax
  403b78:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  403b7c:	4c 31 c9             	xor    rcx,r9
  403b7f:	48 31 f9             	xor    rcx,rdi
  403b82:	48 31 d1             	xor    rcx,rdx
  403b85:	48 31 c1             	xor    rcx,rax
  403b88:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  403b8f:	00 
  403b90:	48 c1 e7 04          	shl    rdi,0x4
  403b94:	48 31 c1             	xor    rcx,rax
  403b97:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  403b9b:	48 31 f9             	xor    rcx,rdi
  403b9e:	48 31 c1             	xor    rcx,rax
  403ba1:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  403ba8:	00 
  403ba9:	48 c1 e2 04          	shl    rdx,0x4
  403bad:	48 31 c1             	xor    rcx,rax
  403bb0:	48 31 d1             	xor    rcx,rdx
  403bb3:	49 83 fc 30          	cmp    r12,0x30
  403bb7:	77 13                	ja     403bcc <v3z+0x44c>
  403bb9:	4d 85 e4             	test   r12,r12
  403bbc:	0f 84 cd 02 00 00    	je     403e8f <v3z+0x70f>
  403bc2:	41 83 f8 01          	cmp    r8d,0x1
  403bc6:	0f 86 c3 02 00 00    	jbe    403e8f <v3z+0x70f>
  403bcc:	48 89 cf             	mov    rdi,rcx
  403bcf:	e8 bc e4 ff ff       	call   402090 <chv3_hwprod>
  403bd4:	4c 8b 4c 24 38       	mov    r9,QWORD PTR [rsp+0x38]
  403bd9:	48 89 d7             	mov    rdi,rdx
  403bdc:	49 89 d2             	mov    r10,rdx
  403bdf:	48 c1 ea 3f          	shr    rdx,0x3f
  403be3:	48 c1 ef 3d          	shr    rdi,0x3d
  403be7:	4c 89 c9             	mov    rcx,r9
  403bea:	4c 31 d0             	xor    rax,r10
  403bed:	48 31 d7             	xor    rdi,rdx
  403bf0:	4c 89 d2             	mov    rdx,r10
  403bf3:	48 c1 e9 3f          	shr    rcx,0x3f
  403bf7:	48 c1 ea 3c          	shr    rdx,0x3c
  403bfb:	48 31 d7             	xor    rdi,rdx
  403bfe:	4c 89 ca             	mov    rdx,r9
  403c01:	48 c1 ea 3d          	shr    rdx,0x3d
  403c05:	48 31 ca             	xor    rdx,rcx
  403c08:	4c 89 c9             	mov    rcx,r9
  403c0b:	48 c1 e9 3c          	shr    rcx,0x3c
  403c0f:	48 31 ca             	xor    rdx,rcx
  403c12:	48 8b 4c 24 30       	mov    rcx,QWORD PTR [rsp+0x30]
  403c17:	48 31 c1             	xor    rcx,rax
  403c1a:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  403c1e:	4c 31 c9             	xor    rcx,r9
  403c21:	48 31 c1             	xor    rcx,rax
  403c24:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  403c2b:	00 
  403c2c:	49 c1 e2 04          	shl    r10,0x4
  403c30:	48 31 c1             	xor    rcx,rax
  403c33:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  403c37:	4c 31 d1             	xor    rcx,r10
  403c3a:	48 31 c1             	xor    rcx,rax
  403c3d:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  403c44:	00 
  403c45:	49 c1 e1 04          	shl    r9,0x4
  403c49:	48 31 c1             	xor    rcx,rax
  403c4c:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  403c50:	4c 31 c9             	xor    rcx,r9
  403c53:	48 31 f9             	xor    rcx,rdi
  403c56:	48 31 d1             	xor    rcx,rdx
  403c59:	48 31 c1             	xor    rcx,rax
  403c5c:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  403c63:	00 
  403c64:	48 c1 e7 04          	shl    rdi,0x4
  403c68:	48 31 c1             	xor    rcx,rax
  403c6b:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  403c6f:	48 31 f9             	xor    rcx,rdi
  403c72:	48 31 c1             	xor    rcx,rax
  403c75:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  403c7c:	00 
  403c7d:	48 c1 e2 04          	shl    rdx,0x4
  403c81:	48 31 c1             	xor    rcx,rax
  403c84:	48 31 d1             	xor    rcx,rdx
  403c87:	49 83 fc 30          	cmp    r12,0x30
  403c8b:	77 13                	ja     403ca0 <v3z+0x520>
  403c8d:	4d 85 e4             	test   r12,r12
  403c90:	0f 84 f9 01 00 00    	je     403e8f <v3z+0x70f>
  403c96:	41 83 f8 02          	cmp    r8d,0x2
  403c9a:	0f 86 ef 01 00 00    	jbe    403e8f <v3z+0x70f>
  403ca0:	48 89 cf             	mov    rdi,rcx
  403ca3:	e8 e8 e3 ff ff       	call   402090 <chv3_hwprod>
  403ca8:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  403cad:	48 89 d7             	mov    rdi,rdx
  403cb0:	49 89 d2             	mov    r10,rdx
  403cb3:	48 c1 ea 3f          	shr    rdx,0x3f
  403cb7:	48 c1 ef 3d          	shr    rdi,0x3d
  403cbb:	4c 89 c9             	mov    rcx,r9
  403cbe:	4c 31 d0             	xor    rax,r10
  403cc1:	48 31 d7             	xor    rdi,rdx
  403cc4:	4c 89 d2             	mov    rdx,r10
  403cc7:	48 c1 e9 3f          	shr    rcx,0x3f
  403ccb:	48 c1 ea 3c          	shr    rdx,0x3c
  403ccf:	48 31 d7             	xor    rdi,rdx
  403cd2:	4c 89 ca             	mov    rdx,r9
  403cd5:	48 c1 ea 3d          	shr    rdx,0x3d
  403cd9:	48 31 ca             	xor    rdx,rcx
  403cdc:	4c 89 c9             	mov    rcx,r9
  403cdf:	48 c1 e9 3c          	shr    rcx,0x3c
  403ce3:	48 31 ca             	xor    rdx,rcx
  403ce6:	48 8b 4c 24 40       	mov    rcx,QWORD PTR [rsp+0x40]
  403ceb:	48 31 c1             	xor    rcx,rax
  403cee:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  403cf2:	4c 31 c9             	xor    rcx,r9
  403cf5:	48 31 c1             	xor    rcx,rax
  403cf8:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  403cff:	00 
  403d00:	49 c1 e2 04          	shl    r10,0x4
  403d04:	48 31 c1             	xor    rcx,rax
  403d07:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  403d0b:	4c 31 d1             	xor    rcx,r10
  403d0e:	48 31 c1             	xor    rcx,rax
  403d11:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  403d18:	00 
  403d19:	49 c1 e1 04          	shl    r9,0x4
  403d1d:	48 31 c1             	xor    rcx,rax
  403d20:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  403d24:	4c 31 c9             	xor    rcx,r9
  403d27:	48 31 f9             	xor    rcx,rdi
  403d2a:	48 31 d1             	xor    rcx,rdx
  403d2d:	48 31 c1             	xor    rcx,rax
  403d30:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  403d37:	00 
  403d38:	48 c1 e7 04          	shl    rdi,0x4
  403d3c:	48 31 c1             	xor    rcx,rax
  403d3f:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  403d43:	48 31 f9             	xor    rcx,rdi
  403d46:	48 31 c1             	xor    rcx,rax
  403d49:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  403d50:	00 
  403d51:	48 c1 e2 04          	shl    rdx,0x4
  403d55:	48 31 c1             	xor    rcx,rax
  403d58:	48 31 d1             	xor    rcx,rdx
  403d5b:	49 83 fc 30          	cmp    r12,0x30
  403d5f:	77 13                	ja     403d74 <v3z+0x5f4>
  403d61:	4d 85 e4             	test   r12,r12
  403d64:	0f 84 25 01 00 00    	je     403e8f <v3z+0x70f>
  403d6a:	41 83 f8 03          	cmp    r8d,0x3
  403d6e:	0f 86 1b 01 00 00    	jbe    403e8f <v3z+0x70f>
  403d74:	48 89 cf             	mov    rdi,rcx
  403d77:	e8 14 e3 ff ff       	call   402090 <chv3_hwprod>
  403d7c:	48 8b 7c 24 58       	mov    rdi,QWORD PTR [rsp+0x58]
  403d81:	48 89 d6             	mov    rsi,rdx
  403d84:	49 89 d2             	mov    r10,rdx
  403d87:	48 c1 ea 3d          	shr    rdx,0x3d
  403d8b:	48 c1 ee 3f          	shr    rsi,0x3f
  403d8f:	48 89 f9             	mov    rcx,rdi
  403d92:	4c 31 d0             	xor    rax,r10
  403d95:	48 31 d6             	xor    rsi,rdx
  403d98:	4c 89 d2             	mov    rdx,r10
  403d9b:	48 c1 e9 3d          	shr    rcx,0x3d
  403d9f:	48 c1 ea 3c          	shr    rdx,0x3c
  403da3:	48 31 d6             	xor    rsi,rdx
  403da6:	48 89 fa             	mov    rdx,rdi
  403da9:	48 c1 ea 3f          	shr    rdx,0x3f
  403dad:	48 31 ca             	xor    rdx,rcx
  403db0:	48 89 f9             	mov    rcx,rdi
  403db3:	48 c1 e9 3c          	shr    rcx,0x3c
  403db7:	48 31 ca             	xor    rdx,rcx
  403dba:	48 8b 4c 24 50       	mov    rcx,QWORD PTR [rsp+0x50]
  403dbf:	48 31 c1             	xor    rcx,rax
  403dc2:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  403dc6:	48 31 f9             	xor    rcx,rdi
  403dc9:	48 31 c1             	xor    rcx,rax
  403dcc:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  403dd3:	00 
  403dd4:	49 c1 e2 04          	shl    r10,0x4
  403dd8:	48 31 c1             	xor    rcx,rax
  403ddb:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  403ddf:	4c 31 d1             	xor    rcx,r10
  403de2:	48 31 c1             	xor    rcx,rax
  403de5:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  403dec:	00 
  403ded:	48 c1 e7 04          	shl    rdi,0x4
  403df1:	48 31 c1             	xor    rcx,rax
  403df4:	48 8d 04 36          	lea    rax,[rsi+rsi*1]
  403df8:	48 31 f9             	xor    rcx,rdi
  403dfb:	48 31 f1             	xor    rcx,rsi
  403dfe:	48 31 d1             	xor    rcx,rdx
  403e01:	48 31 c1             	xor    rcx,rax
  403e04:	48 8d 04 f5 00 00 00 	lea    rax,[rsi*8+0x0]
  403e0b:	00 
  403e0c:	48 c1 e6 04          	shl    rsi,0x4
  403e10:	48 31 c1             	xor    rcx,rax
  403e13:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  403e17:	48 31 f1             	xor    rcx,rsi
  403e1a:	48 31 c1             	xor    rcx,rax
  403e1d:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  403e24:	00 
  403e25:	48 c1 e2 04          	shl    rdx,0x4
  403e29:	48 31 c1             	xor    rcx,rax
  403e2c:	48 31 d1             	xor    rcx,rdx
  403e2f:	eb 5e                	jmp    403e8f <v3z+0x70f>
  403e31:	31 f6                	xor    esi,esi
  403e33:	89 f0                	mov    eax,esi
  403e35:	0f a2                	cpuid  
  403e37:	85 c0                	test   eax,eax
  403e39:	0f 85 a6 01 00 00    	jne    403fe5 <v3z+0x865>
  403e3f:	c7 05 03 72 00 00 00 	mov    DWORD PTR [rip+0x7203],0x0        # 40b04c <cache.5>
  403e46:	00 00 00 
  403e49:	b9 50 91 40 00       	mov    ecx,0x409150
  403e4e:	ba 61 01 00 00       	mov    edx,0x161
  403e53:	be 10 90 40 00       	mov    esi,0x409010
  403e58:	bf 88 90 40 00       	mov    edi,0x409088
  403e5d:	e8 fe d1 ff ff       	call   401060 <__assert_fail@plt>
  403e62:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  403e68:	31 c0                	xor    eax,eax
  403e6a:	e9 44 fa ff ff       	jmp    4038b3 <v3z+0x133>
  403e6f:	48 8b 54 24 10       	mov    rdx,QWORD PTR [rsp+0x10]
  403e74:	4c 89 c7             	mov    rdi,r8
  403e77:	48 89 d6             	mov    rsi,rdx
  403e7a:	48 c1 ee 0a          	shr    rsi,0xa
  403e7e:	e8 8d f5 ff ff       	call   403410 <chv3_bulk512.constprop.0>
  403e83:	48 89 c1             	mov    rcx,rax
  403e86:	4d 85 e4             	test   r12,r12
  403e89:	0f 85 e7 01 00 00    	jne    404076 <v3z+0x8f6>
  403e8f:	48 03 0d 82 79 00 00 	add    rcx,QWORD PTR [rip+0x7982]        # 40b818 <v3+0x1b8>
  403e96:	48 89 ce             	mov    rsi,rcx
  403e99:	48 89 cf             	mov    rdi,rcx
  403e9c:	e8 ef e1 ff ff       	call   402090 <chv3_hwprod>
  403ea1:	48 89 d6             	mov    rsi,rdx
  403ea4:	48 89 d7             	mov    rdi,rdx
  403ea7:	48 31 d0             	xor    rax,rdx
  403eaa:	48 c1 ef 3d          	shr    rdi,0x3d
  403eae:	48 c1 ee 3f          	shr    rsi,0x3f
  403eb2:	48 31 fe             	xor    rsi,rdi
  403eb5:	48 89 d7             	mov    rdi,rdx
  403eb8:	48 c1 ef 3c          	shr    rdi,0x3c
  403ebc:	48 31 fe             	xor    rsi,rdi
  403ebf:	48 89 c7             	mov    rdi,rax
  403ec2:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  403ec6:	48 31 c7             	xor    rdi,rax
  403ec9:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  403ed0:	00 
  403ed1:	48 c1 e2 04          	shl    rdx,0x4
  403ed5:	48 31 c7             	xor    rdi,rax
  403ed8:	48 8d 04 36          	lea    rax,[rsi+rsi*1]
  403edc:	48 31 d7             	xor    rdi,rdx
  403edf:	48 31 f7             	xor    rdi,rsi
  403ee2:	48 31 c7             	xor    rdi,rax
  403ee5:	48 8d 04 f5 00 00 00 	lea    rax,[rsi*8+0x0]
  403eec:	00 
  403eed:	48 c1 e6 04          	shl    rsi,0x4
  403ef1:	48 31 c7             	xor    rdi,rax
  403ef4:	48 31 f7             	xor    rdi,rsi
  403ef7:	48 8b 35 fa 78 00 00 	mov    rsi,QWORD PTR [rip+0x78fa]        # 40b7f8 <v3+0x198>
  403efe:	48 31 fe             	xor    rsi,rdi
  403f01:	48 33 3d e8 78 00 00 	xor    rdi,QWORD PTR [rip+0x78e8]        # 40b7f0 <v3+0x190>
  403f08:	48 31 ce             	xor    rsi,rcx
  403f0b:	e8 80 e1 ff ff       	call   402090 <chv3_hwprod>
  403f10:	48 89 d7             	mov    rdi,rdx
  403f13:	48 89 d6             	mov    rsi,rdx
  403f16:	48 31 d0             	xor    rax,rdx
  403f19:	48 c1 ee 3d          	shr    rsi,0x3d
  403f1d:	48 c1 ef 3f          	shr    rdi,0x3f
  403f21:	48 31 f7             	xor    rdi,rsi
  403f24:	48 89 d6             	mov    rsi,rdx
  403f27:	48 c1 ee 3c          	shr    rsi,0x3c
  403f2b:	48 31 f7             	xor    rdi,rsi
  403f2e:	48 8b 35 d3 78 00 00 	mov    rsi,QWORD PTR [rip+0x78d3]        # 40b808 <v3+0x1a8>
  403f35:	48 31 c6             	xor    rsi,rax
  403f38:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  403f3c:	48 31 c6             	xor    rsi,rax
  403f3f:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  403f46:	00 
  403f47:	48 c1 e2 04          	shl    rdx,0x4
  403f4b:	48 31 c6             	xor    rsi,rax
  403f4e:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  403f52:	48 31 d6             	xor    rsi,rdx
  403f55:	48 31 fe             	xor    rsi,rdi
  403f58:	48 31 c6             	xor    rsi,rax
  403f5b:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  403f62:	00 
  403f63:	48 c1 e7 04          	shl    rdi,0x4
  403f67:	48 31 c6             	xor    rsi,rax
  403f6a:	48 31 fe             	xor    rsi,rdi
  403f6d:	48 8b 3d 8c 78 00 00 	mov    rdi,QWORD PTR [rip+0x788c]        # 40b800 <v3+0x1a0>
  403f74:	48 31 cf             	xor    rdi,rcx
  403f77:	e8 14 e1 ff ff       	call   402090 <chv3_hwprod>
  403f7c:	48 89 d1             	mov    rcx,rdx
  403f7f:	48 89 d6             	mov    rsi,rdx
  403f82:	48 31 d0             	xor    rax,rdx
  403f85:	48 33 05 84 78 00 00 	xor    rax,QWORD PTR [rip+0x7884]        # 40b810 <v3+0x1b0>
  403f8c:	48 c1 ee 3d          	shr    rsi,0x3d
  403f90:	48 c1 e9 3f          	shr    rcx,0x3f
  403f94:	48 83 c4 68          	add    rsp,0x68
  403f98:	48 31 f1             	xor    rcx,rsi
  403f9b:	48 89 d6             	mov    rsi,rdx
  403f9e:	5b                   	pop    rbx
  403f9f:	5d                   	pop    rbp
  403fa0:	48 c1 ee 3c          	shr    rsi,0x3c
  403fa4:	41 5c                	pop    r12
  403fa6:	41 5d                	pop    r13
  403fa8:	48 31 f1             	xor    rcx,rsi
  403fab:	48 8d 34 12          	lea    rsi,[rdx+rdx*1]
  403faf:	41 5e                	pop    r14
  403fb1:	41 5f                	pop    r15
  403fb3:	48 31 f0             	xor    rax,rsi
  403fb6:	48 8d 34 d5 00 00 00 	lea    rsi,[rdx*8+0x0]
  403fbd:	00 
  403fbe:	48 c1 e2 04          	shl    rdx,0x4
  403fc2:	48 31 f0             	xor    rax,rsi
  403fc5:	48 31 d0             	xor    rax,rdx
  403fc8:	48 8d 14 09          	lea    rdx,[rcx+rcx*1]
  403fcc:	48 31 c8             	xor    rax,rcx
  403fcf:	48 31 d0             	xor    rax,rdx
  403fd2:	48 8d 14 cd 00 00 00 	lea    rdx,[rcx*8+0x0]
  403fd9:	00 
  403fda:	48 c1 e1 04          	shl    rcx,0x4
  403fde:	48 31 d0             	xor    rax,rdx
  403fe1:	48 31 c8             	xor    rax,rcx
  403fe4:	c3                   	ret    
  403fe5:	b8 01 00 00 00       	mov    eax,0x1
  403fea:	0f a2                	cpuid  
  403fec:	81 e1 02 00 00 18    	and    ecx,0x18000002
  403ff2:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
  403ff8:	0f 85 41 fe ff ff    	jne    403e3f <v3z+0x6bf>
  403ffe:	89 f1                	mov    ecx,esi
  404000:	0f 01 d0             	xgetbv 
  404003:	89 c7                	mov    edi,eax
  404005:	83 e0 06             	and    eax,0x6
  404008:	83 f8 06             	cmp    eax,0x6
  40400b:	0f 85 2e fe ff ff    	jne    403e3f <v3z+0x6bf>
  404011:	89 f0                	mov    eax,esi
  404013:	0f a2                	cpuid  
  404015:	83 f8 06             	cmp    eax,0x6
  404018:	76 3e                	jbe    404058 <v3z+0x8d8>
  40401a:	b8 07 00 00 00       	mov    eax,0x7
  40401f:	89 f1                	mov    ecx,esi
  404021:	0f a2                	cpuid  
  404023:	f6 c3 20             	test   bl,0x20
  404026:	74 30                	je     404058 <v3z+0x8d8>
  404028:	80 e5 04             	and    ch,0x4
  40402b:	74 2b                	je     404058 <v3z+0x8d8>
  40402d:	81 e7 e6 00 00 00    	and    edi,0xe6
  404033:	81 ff e6 00 00 00    	cmp    edi,0xe6
  404039:	75 2c                	jne    404067 <v3z+0x8e7>
  40403b:	81 e3 00 00 01 00    	and    ebx,0x10000
  404041:	74 24                	je     404067 <v3z+0x8e7>
  404043:	c7 05 ff 6f 00 00 03 	mov    DWORD PTR [rip+0x6fff],0x3        # 40b04c <cache.5>
  40404a:	00 00 00 
  40404d:	e9 6e f7 ff ff       	jmp    4037c0 <v3z+0x40>
  404052:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  404058:	c7 05 ea 6f 00 00 01 	mov    DWORD PTR [rip+0x6fea],0x1        # 40b04c <cache.5>
  40405f:	00 00 00 
  404062:	e9 e2 fd ff ff       	jmp    403e49 <v3z+0x6c9>
  404067:	c7 05 db 6f 00 00 02 	mov    DWORD PTR [rip+0x6fdb],0x2        # 40b04c <cache.5>
  40406e:	00 00 00 
  404071:	e9 d3 fd ff ff       	jmp    403e49 <v3z+0x6c9>
  404076:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  40407b:	48 89 4c 24 10       	mov    QWORD PTR [rsp+0x10],rcx
  404080:	48 25 00 fc ff ff    	and    rax,0xfffffffffffffc00
  404086:	49 01 c0             	add    r8,rax
  404089:	e9 41 f7 ff ff       	jmp    4037cf <v3z+0x4f>
  40408e:	66 90                	xchg   ax,ax

0000000000404090 <chainhash_v3_evaluate.constprop.0>:
  404090:	41 57                	push   r15
  404092:	41 56                	push   r14
  404094:	41 55                	push   r13
  404096:	41 54                	push   r12
  404098:	55                   	push   rbp
  404099:	53                   	push   rbx
  40409a:	48 81 ec 68 05 00 00 	sub    rsp,0x568
  4040a1:	48 89 7c 24 28       	mov    QWORD PTR [rsp+0x28],rdi
  4040a6:	48 89 74 24 20       	mov    QWORD PTR [rsp+0x20],rsi
  4040ab:	89 54 24 10          	mov    DWORD PTR [rsp+0x10],edx
  4040af:	8b 05 97 6f 00 00    	mov    eax,DWORD PTR [rip+0x6f97]        # 40b04c <cache.5>
  4040b5:	85 c0                	test   eax,eax
  4040b7:	0f 88 77 02 00 00    	js     404334 <chainhash_v3_evaluate.constprop.0+0x2a4>
  4040bd:	83 f8 04             	cmp    eax,0x4
  4040c0:	0f 84 04 03 00 00    	je     4043ca <chainhash_v3_evaluate.constprop.0+0x33a>
  4040c6:	39 44 24 10          	cmp    DWORD PTR [rsp+0x10],eax
  4040ca:	0f 8f fa 02 00 00    	jg     4043ca <chainhash_v3_evaluate.constprop.0+0x33a>
  4040d0:	48 8d bc 24 b0 00 00 	lea    rdi,[rsp+0xb0]
  4040d7:	00 
  4040d8:	31 c0                	xor    eax,eax
  4040da:	b9 96 00 00 00       	mov    ecx,0x96
  4040df:	48 89 7c 24 30       	mov    QWORD PTR [rsp+0x30],rdi
  4040e4:	f3 48 ab             	rep stos QWORD PTR es:[rdi],rax
  4040e7:	48 b8 04 00 00 00 01 	movabs rax,0x100000004
  4040ee:	00 00 00 
  4040f1:	48 c7 84 24 b0 00 00 	mov    QWORD PTR [rsp+0xb0],0x40b660
  4040f8:	00 60 b6 40 00 
  4040fd:	48 89 84 24 48 01 00 	mov    QWORD PTR [rsp+0x148],rax
  404104:	00 
  404105:	8b 44 24 10          	mov    eax,DWORD PTR [rsp+0x10]
  404109:	89 84 24 50 01 00 00 	mov    DWORD PTR [rsp+0x150],eax
  404110:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
  404115:	48 89 84 24 38 01 00 	mov    QWORD PTR [rsp+0x138],rax
  40411c:	00 
  40411d:	48 3d ff 03 00 00    	cmp    rax,0x3ff
  404123:	0f 86 8c 12 00 00    	jbe    4053b5 <chainhash_v3_evaluate.constprop.0+0x1325>
  404129:	48 8b 5c 24 28       	mov    rbx,QWORD PTR [rsp+0x28]
  40412e:	48 2d 00 04 00 00    	sub    rax,0x400
  404134:	41 bd 60 b6 40 00    	mov    r13d,0x40b660
  40413a:	48 25 00 fc ff ff    	and    rax,0xfffffffffffffc00
  404140:	48 8d 84 03 00 04 00 	lea    rax,[rbx+rax*1+0x400]
  404147:	00 
  404148:	48 89 44 24 50       	mov    QWORD PTR [rsp+0x50],rax
  40414d:	48 8d 44 24 70       	lea    rax,[rsp+0x70]
  404152:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
  404157:	83 7c 24 10 03       	cmp    DWORD PTR [rsp+0x10],0x3
  40415c:	0f 84 96 02 00 00    	je     4043f8 <chainhash_v3_evaluate.constprop.0+0x368>
  404162:	83 7c 24 10 02       	cmp    DWORD PTR [rsp+0x10],0x2
  404167:	0f 84 01 12 00 00    	je     40536e <chainhash_v3_evaluate.constprop.0+0x12de>
  40416d:	83 7c 24 10 01       	cmp    DWORD PTR [rsp+0x10],0x1
  404172:	0f 84 d4 11 00 00    	je     40534c <chainhash_v3_evaluate.constprop.0+0x12bc>
  404178:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
  40417d:	66 0f ef c0          	pxor   xmm0,xmm0
  404181:	45 31 e4             	xor    r12d,r12d
  404184:	31 db                	xor    ebx,ebx
  404186:	45 31 db             	xor    r11d,r11d
  404189:	0f 29 00             	movaps XMMWORD PTR [rax],xmm0
  40418c:	0f 29 40 10          	movaps XMMWORD PTR [rax+0x10],xmm0
  404190:	0f 29 40 20          	movaps XMMWORD PTR [rax+0x20],xmm0
  404194:	0f 29 40 30          	movaps XMMWORD PTR [rax+0x30],xmm0
  404198:	eb 6f                	jmp    404209 <chainhash_v3_evaluate.constprop.0+0x179>
  40419a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  4041a0:	b9 41 00 00 00       	mov    ecx,0x41
  4041a5:	49 89 f8             	mov    r8,rdi
  4041a8:	44 29 f9             	sub    ecx,r15d
  4041ab:	49 d3 e8             	shr    r8,cl
  4041ae:	4c 21 c0             	and    rax,r8
  4041b1:	49 31 c6             	xor    r14,rax
  4041b4:	41 83 ff 40          	cmp    r15d,0x40
  4041b8:	0f 85 71 01 00 00    	jne    40432f <chainhash_v3_evaluate.constprop.0+0x29f>
  4041be:	4c 8b 44 24 08       	mov    r8,QWORD PTR [rsp+0x8]
  4041c3:	49 31 d3             	xor    r11,rdx
  4041c6:	4c 31 f3             	xor    rbx,r14
  4041c9:	49 83 c0 08          	add    r8,0x8
  4041cd:	41 83 c1 01          	add    r9d,0x1
  4041d1:	4d 89 1a             	mov    QWORD PTR [r10],r11
  4041d4:	49 89 5a 08          	mov    QWORD PTR [r10+0x8],rbx
  4041d8:	44 3b 4c 24 14       	cmp    r9d,DWORD PTR [rsp+0x14]
  4041dd:	75 50                	jne    40422f <chainhash_v3_evaluate.constprop.0+0x19f>
  4041df:	49 83 c2 10          	add    r10,0x10
  4041e3:	83 c5 02             	add    ebp,0x2
  4041e6:	4c 3b 54 24 30       	cmp    r10,QWORD PTR [rsp+0x30]
  4041eb:	0f 85 6f 09 00 00    	jne    404b60 <chainhash_v3_evaluate.constprop.0+0xad0>
  4041f1:	41 83 c4 04          	add    r12d,0x4
  4041f5:	4c 8b 5c 24 70       	mov    r11,QWORD PTR [rsp+0x70]
  4041fa:	48 8b 5c 24 78       	mov    rbx,QWORD PTR [rsp+0x78]
  4041ff:	41 83 fc 20          	cmp    r12d,0x20
  404203:	0f 84 01 02 00 00    	je     40440a <chainhash_v3_evaluate.constprop.0+0x37a>
  404209:	41 8d 44 24 02       	lea    eax,[r12+0x2]
  40420e:	4c 8b 54 24 18       	mov    r10,QWORD PTR [rsp+0x18]
  404213:	42 8d 2c a5 00 00 00 	lea    ebp,[r12*4+0x0]
  40421a:	00 
  40421b:	89 44 24 14          	mov    DWORD PTR [rsp+0x14],eax
  40421f:	44 8d 04 ed 00 00 00 	lea    r8d,[rbp*8+0x0]
  404226:	00 
  404227:	45 89 e1             	mov    r9d,r12d
  40422a:	4c 03 44 24 28       	add    r8,QWORD PTR [rsp+0x28]
  40422f:	41 0f b6 40 41       	movzx  eax,BYTE PTR [r8+0x41]
  404234:	41 0f b6 50 42       	movzx  edx,BYTE PTR [r8+0x42]
  404239:	41 0f b6 70 47       	movzx  esi,BYTE PTR [r8+0x47]
  40423e:	41 0f b6 78 07       	movzx  edi,BYTE PTR [r8+0x7]
  404243:	48 c1 e2 10          	shl    rdx,0x10
  404247:	48 c1 e0 08          	shl    rax,0x8
  40424b:	44 8b 74 24 10       	mov    r14d,DWORD PTR [rsp+0x10]
  404250:	48 c1 e6 38          	shl    rsi,0x38
  404254:	48 09 d0             	or     rax,rdx
  404257:	41 0f b6 50 40       	movzx  edx,BYTE PTR [r8+0x40]
  40425c:	48 c1 e7 38          	shl    rdi,0x38
  404260:	48 09 d0             	or     rax,rdx
  404263:	41 0f b6 50 43       	movzx  edx,BYTE PTR [r8+0x43]
  404268:	48 c1 e2 18          	shl    rdx,0x18
  40426c:	48 09 c2             	or     rdx,rax
  40426f:	41 0f b6 40 44       	movzx  eax,BYTE PTR [r8+0x44]
  404274:	48 c1 e0 20          	shl    rax,0x20
  404278:	48 09 d0             	or     rax,rdx
  40427b:	41 0f b6 50 45       	movzx  edx,BYTE PTR [r8+0x45]
  404280:	48 c1 e2 28          	shl    rdx,0x28
  404284:	48 09 c2             	or     rdx,rax
  404287:	41 0f b6 40 46       	movzx  eax,BYTE PTR [r8+0x46]
  40428c:	48 c1 e0 30          	shl    rax,0x30
  404290:	48 09 d0             	or     rax,rdx
  404293:	41 0f b6 50 02       	movzx  edx,BYTE PTR [r8+0x2]
  404298:	48 09 c6             	or     rsi,rax
  40429b:	41 8d 41 02          	lea    eax,[r9+0x2]
  40429f:	49 33 74 c5 00       	xor    rsi,QWORD PTR [r13+rax*8+0x0]
  4042a4:	41 0f b6 40 01       	movzx  eax,BYTE PTR [r8+0x1]
  4042a9:	48 c1 e2 10          	shl    rdx,0x10
  4042ad:	48 c1 e0 08          	shl    rax,0x8
  4042b1:	48 09 d0             	or     rax,rdx
  4042b4:	41 0f b6 10          	movzx  edx,BYTE PTR [r8]
  4042b8:	48 09 d0             	or     rax,rdx
  4042bb:	41 0f b6 50 03       	movzx  edx,BYTE PTR [r8+0x3]
  4042c0:	48 c1 e2 18          	shl    rdx,0x18
  4042c4:	48 09 c2             	or     rdx,rax
  4042c7:	41 0f b6 40 04       	movzx  eax,BYTE PTR [r8+0x4]
  4042cc:	48 c1 e0 20          	shl    rax,0x20
  4042d0:	48 09 d0             	or     rax,rdx
  4042d3:	41 0f b6 50 05       	movzx  edx,BYTE PTR [r8+0x5]
  4042d8:	48 c1 e2 28          	shl    rdx,0x28
  4042dc:	48 09 c2             	or     rdx,rax
  4042df:	41 0f b6 40 06       	movzx  eax,BYTE PTR [r8+0x6]
  4042e4:	48 c1 e0 30          	shl    rax,0x30
  4042e8:	48 09 d0             	or     rax,rdx
  4042eb:	48 09 c7             	or     rdi,rax
  4042ee:	44 89 c8             	mov    eax,r9d
  4042f1:	49 33 7c c5 00       	xor    rdi,QWORD PTR [r13+rax*8+0x0]
  4042f6:	45 85 f6             	test   r14d,r14d
  4042f9:	0f 85 e9 00 00 00    	jne    4043e8 <chainhash_v3_evaluate.constprop.0+0x358>
  4042ff:	4c 89 44 24 08       	mov    QWORD PTR [rsp+0x8],r8
  404304:	45 31 f6             	xor    r14d,r14d
  404307:	31 d2                	xor    edx,edx
  404309:	31 c9                	xor    ecx,ecx
  40430b:	48 89 f0             	mov    rax,rsi
  40430e:	49 89 ff             	mov    r15,rdi
  404311:	48 d3 e8             	shr    rax,cl
  404314:	49 d3 e7             	shl    r15,cl
  404317:	83 e0 01             	and    eax,0x1
  40431a:	48 f7 d8             	neg    rax
  40431d:	49 21 c7             	and    r15,rax
  404320:	4c 31 fa             	xor    rdx,r15
  404323:	44 8d 79 01          	lea    r15d,[rcx+0x1]
  404327:	85 c9                	test   ecx,ecx
  404329:	0f 85 71 fe ff ff    	jne    4041a0 <chainhash_v3_evaluate.constprop.0+0x110>
  40432f:	44 89 f9             	mov    ecx,r15d
  404332:	eb d7                	jmp    40430b <chainhash_v3_evaluate.constprop.0+0x27b>
  404334:	31 f6                	xor    esi,esi
  404336:	89 f0                	mov    eax,esi
  404338:	0f a2                	cpuid  
  40433a:	85 c0                	test   eax,eax
  40433c:	0f 84 7e 00 00 00    	je     4043c0 <chainhash_v3_evaluate.constprop.0+0x330>
  404342:	b8 01 00 00 00       	mov    eax,0x1
  404347:	0f a2                	cpuid  
  404349:	81 e1 02 00 00 18    	and    ecx,0x18000002
  40434f:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
  404355:	75 69                	jne    4043c0 <chainhash_v3_evaluate.constprop.0+0x330>
  404357:	89 f1                	mov    ecx,esi
  404359:	0f 01 d0             	xgetbv 
  40435c:	89 c7                	mov    edi,eax
  40435e:	83 e0 06             	and    eax,0x6
  404361:	83 f8 06             	cmp    eax,0x6
  404364:	75 5a                	jne    4043c0 <chainhash_v3_evaluate.constprop.0+0x330>
  404366:	89 f0                	mov    eax,esi
  404368:	0f a2                	cpuid  
  40436a:	83 f8 06             	cmp    eax,0x6
  40436d:	0f 86 c5 11 00 00    	jbe    405538 <chainhash_v3_evaluate.constprop.0+0x14a8>
  404373:	b8 07 00 00 00       	mov    eax,0x7
  404378:	89 f1                	mov    ecx,esi
  40437a:	0f a2                	cpuid  
  40437c:	f6 c3 20             	test   bl,0x20
  40437f:	0f 84 b3 11 00 00    	je     405538 <chainhash_v3_evaluate.constprop.0+0x14a8>
  404385:	80 e5 04             	and    ch,0x4
  404388:	0f 84 aa 11 00 00    	je     405538 <chainhash_v3_evaluate.constprop.0+0x14a8>
  40438e:	81 e7 e6 00 00 00    	and    edi,0xe6
  404394:	81 ff e6 00 00 00    	cmp    edi,0xe6
  40439a:	0f 85 84 11 00 00    	jne    405524 <chainhash_v3_evaluate.constprop.0+0x1494>
  4043a0:	81 e3 00 00 01 00    	and    ebx,0x10000
  4043a6:	0f 84 78 11 00 00    	je     405524 <chainhash_v3_evaluate.constprop.0+0x1494>
  4043ac:	c7 05 96 6c 00 00 03 	mov    DWORD PTR [rip+0x6c96],0x3        # 40b04c <cache.5>
  4043b3:	00 00 00 
  4043b6:	e9 15 fd ff ff       	jmp    4040d0 <chainhash_v3_evaluate.constprop.0+0x40>
  4043bb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  4043c0:	c7 05 82 6c 00 00 00 	mov    DWORD PTR [rip+0x6c82],0x0        # 40b04c <cache.5>
  4043c7:	00 00 00 
  4043ca:	b9 30 91 40 00       	mov    ecx,0x409130
  4043cf:	ba 2c 01 00 00       	mov    edx,0x12c
  4043d4:	be 10 90 40 00       	mov    esi,0x409010
  4043d9:	bf b0 90 40 00       	mov    edi,0x4090b0
  4043de:	e8 7d cc ff ff       	call   401060 <__assert_fail@plt>
  4043e3:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  4043e8:	e8 a3 dc ff ff       	call   402090 <chv3_hwprod>
  4043ed:	49 89 d6             	mov    r14,rdx
  4043f0:	48 89 c2             	mov    rdx,rax
  4043f3:	e9 cb fd ff ff       	jmp    4041c3 <chainhash_v3_evaluate.constprop.0+0x133>
  4043f8:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
  4043fd:	48 8b 74 24 28       	mov    rsi,QWORD PTR [rsp+0x28]
  404402:	4c 89 ef             	mov    rdi,r13
  404405:	e8 66 d7 ff ff       	call   401b70 <chv3_region512>
  40440a:	44 8b bc 24 48 01 00 	mov    r15d,DWORD PTR [rsp+0x148]
  404411:	00 
  404412:	8b 84 24 4c 01 00 00 	mov    eax,DWORD PTR [rsp+0x14c]
  404419:	4c 8b 8c 24 40 01 00 	mov    r9,QWORD PTR [rsp+0x140]
  404420:	00 
  404421:	4c 8b 54 24 18       	mov    r10,QWORD PTR [rsp+0x18]
  404426:	89 44 24 14          	mov    DWORD PTR [rsp+0x14],eax
  40442a:	49 8d 47 28          	lea    rax,[r15+0x28]
  40442e:	4f 8b a4 fd 00 01 00 	mov    r12,QWORD PTR [r13+r15*8+0x100]
  404435:	00 
  404436:	4c 89 4c 24 48       	mov    QWORD PTR [rsp+0x48],r9
  40443b:	44 89 7c 24 08       	mov    DWORD PTR [rsp+0x8],r15d
  404440:	4c 89 7c 24 40       	mov    QWORD PTR [rsp+0x40],r15
  404445:	48 89 44 24 38       	mov    QWORD PTR [rsp+0x38],rax
  40444a:	4c 89 c8             	mov    rax,r9
  40444d:	31 d2                	xor    edx,edx
  40444f:	44 8b 5c 24 14       	mov    r11d,DWORD PTR [rsp+0x14]
  404454:	49 f7 f7             	div    r15
  404457:	48 89 d0             	mov    rax,rdx
  40445a:	49 89 d0             	mov    r8,rdx
  40445d:	48 c1 e0 04          	shl    rax,0x4
  404461:	48 8b 94 04 b8 00 00 	mov    rdx,QWORD PTR [rsp+rax*1+0xb8]
  404468:	00 
  404469:	45 85 db             	test   r11d,r11d
  40446c:	0f 84 b5 05 00 00    	je     404a27 <chainhash_v3_evaluate.constprop.0+0x997>
  404472:	48 8b 5c 24 38       	mov    rbx,QWORD PTR [rsp+0x38]
  404477:	8b 7c 24 10          	mov    edi,DWORD PTR [rsp+0x10]
  40447b:	48 8b ac 04 c0 00 00 	mov    rbp,QWORD PTR [rsp+rax*1+0xc0]
  404482:	00 
  404483:	4d 8b 74 dd 08       	mov    r14,QWORD PTR [r13+rbx*8+0x8]
  404488:	85 ff                	test   edi,edi
  40448a:	0f 85 dc 06 00 00    	jne    404b6c <chainhash_v3_evaluate.constprop.0+0xadc>
  404490:	45 31 db             	xor    r11d,r11d
  404493:	31 db                	xor    ebx,ebx
  404495:	31 c9                	xor    ecx,ecx
  404497:	4c 89 e0             	mov    rax,r12
  40449a:	48 89 d6             	mov    rsi,rdx
  40449d:	48 d3 e8             	shr    rax,cl
  4044a0:	48 d3 e6             	shl    rsi,cl
  4044a3:	83 e0 01             	and    eax,0x1
  4044a6:	48 f7 d8             	neg    rax
  4044a9:	48 21 c6             	and    rsi,rax
  4044ac:	48 31 f3             	xor    rbx,rsi
  4044af:	8d 71 01             	lea    esi,[rcx+0x1]
  4044b2:	85 c9                	test   ecx,ecx
  4044b4:	0f 84 66 05 00 00    	je     404a20 <chainhash_v3_evaluate.constprop.0+0x990>
  4044ba:	b9 41 00 00 00       	mov    ecx,0x41
  4044bf:	48 89 d7             	mov    rdi,rdx
  4044c2:	29 f1                	sub    ecx,esi
  4044c4:	48 d3 ef             	shr    rdi,cl
  4044c7:	48 21 f8             	and    rax,rdi
  4044ca:	49 31 c3             	xor    r11,rax
  4044cd:	83 fe 40             	cmp    esi,0x40
  4044d0:	0f 85 4a 05 00 00    	jne    404a20 <chainhash_v3_evaluate.constprop.0+0x990>
  4044d6:	4c 89 44 24 58       	mov    QWORD PTR [rsp+0x58],r8
  4044db:	31 ff                	xor    edi,edi
  4044dd:	31 d2                	xor    edx,edx
  4044df:	31 c9                	xor    ecx,ecx
  4044e1:	4c 89 f0             	mov    rax,r14
  4044e4:	48 89 ee             	mov    rsi,rbp
  4044e7:	48 d3 e8             	shr    rax,cl
  4044ea:	48 d3 e6             	shl    rsi,cl
  4044ed:	83 e0 01             	and    eax,0x1
  4044f0:	48 f7 d8             	neg    rax
  4044f3:	48 21 c6             	and    rsi,rax
  4044f6:	48 31 f2             	xor    rdx,rsi
  4044f9:	8d 71 01             	lea    esi,[rcx+0x1]
  4044fc:	85 c9                	test   ecx,ecx
  4044fe:	0f 84 0c 05 00 00    	je     404a10 <chainhash_v3_evaluate.constprop.0+0x980>
  404504:	b9 41 00 00 00       	mov    ecx,0x41
  404509:	49 89 e8             	mov    r8,rbp
  40450c:	29 f1                	sub    ecx,esi
  40450e:	49 d3 e8             	shr    r8,cl
  404511:	4c 21 c0             	and    rax,r8
  404514:	48 31 c7             	xor    rdi,rax
  404517:	83 fe 40             	cmp    esi,0x40
  40451a:	0f 85 f0 04 00 00    	jne    404a10 <chainhash_v3_evaluate.constprop.0+0x980>
  404520:	4c 8b 44 24 58       	mov    r8,QWORD PTR [rsp+0x58]
  404525:	4c 89 c0             	mov    rax,r8
  404528:	48 31 da             	xor    rdx,rbx
  40452b:	49 33 12             	xor    rdx,QWORD PTR [r10]
  40452e:	49 31 fb             	xor    r11,rdi
  404531:	48 c1 e0 04          	shl    rax,0x4
  404535:	4d 33 5a 08          	xor    r11,QWORD PTR [r10+0x8]
  404539:	48 89 94 04 b8 00 00 	mov    QWORD PTR [rsp+rax*1+0xb8],rdx
  404540:	00 
  404541:	49 c1 e0 04          	shl    r8,0x4
  404545:	49 83 c1 01          	add    r9,0x1
  404549:	49 83 c2 10          	add    r10,0x10
  40454d:	4e 89 9c 04 c0 00 00 	mov    QWORD PTR [rsp+r8*1+0xc0],r11
  404554:	00 
  404555:	4c 89 8c 24 40 01 00 	mov    QWORD PTR [rsp+0x140],r9
  40455c:	00 
  40455d:	4c 3b 54 24 30       	cmp    r10,QWORD PTR [rsp+0x30]
  404562:	0f 85 e2 fe ff ff    	jne    40444a <chainhash_v3_evaluate.constprop.0+0x3ba>
  404568:	4c 8b 64 24 48       	mov    r12,QWORD PTR [rsp+0x48]
  40456d:	4c 8b ac 24 b0 00 00 	mov    r13,QWORD PTR [rsp+0xb0]
  404574:	00 
  404575:	48 81 44 24 28 00 04 	add    QWORD PTR [rsp+0x28],0x400
  40457c:	00 00 
  40457e:	48 8b 44 24 28       	mov    rax,QWORD PTR [rsp+0x28]
  404583:	49 83 c4 04          	add    r12,0x4
  404587:	48 3b 44 24 50       	cmp    rax,QWORD PTR [rsp+0x50]
  40458c:	0f 85 c5 fb ff ff    	jne    404157 <chainhash_v3_evaluate.constprop.0+0xc7>
  404592:	48 81 64 24 20 ff 03 	and    QWORD PTR [rsp+0x20],0x3ff
  404599:	00 00 
  40459b:	48 83 7c 24 20 00    	cmp    QWORD PTR [rsp+0x20],0x0
  4045a1:	0f 85 3c 0e 00 00    	jne    4053e3 <chainhash_v3_evaluate.constprop.0+0x1353>
  4045a7:	48 8b 84 24 58 01 00 	mov    rax,QWORD PTR [rsp+0x158]
  4045ae:	00 
  4045af:	48 89 44 24 20       	mov    QWORD PTR [rsp+0x20],rax
  4045b4:	48 85 c0             	test   rax,rax
  4045b7:	0f 85 de 0e 00 00    	jne    40549b <chainhash_v3_evaluate.constprop.0+0x140b>
  4045bd:	4d 85 e4             	test   r12,r12
  4045c0:	0f 85 97 0e 00 00    	jne    40545d <chainhash_v3_evaluate.constprop.0+0x13cd>
  4045c6:	c7 44 24 28 01 00 00 	mov    DWORD PTR [rsp+0x28],0x1
  4045cd:	00 
  4045ce:	48 8b 6c 24 20       	mov    rbp,QWORD PTR [rsp+0x20]
  4045d3:	48 8d 44 24 70       	lea    rax,[rsp+0x70]
  4045d8:	c7 44 24 38 04 00 00 	mov    DWORD PTR [rsp+0x38],0x4
  4045df:	00 
  4045e0:	66 0f ef c0          	pxor   xmm0,xmm0
  4045e4:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
  4045e9:	48 8d 45 c0          	lea    rax,[rbp-0x40]
  4045ed:	4c 89 64 24 60       	mov    QWORD PTR [rsp+0x60],r12
  4045f2:	48 c7 44 24 48 00 00 	mov    QWORD PTR [rsp+0x48],0x0
  4045f9:	00 00 
  4045fb:	48 89 44 24 58       	mov    QWORD PTR [rsp+0x58],rax
  404600:	0f 29 44 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm0
  404605:	0f 29 84 24 80 00 00 	movaps XMMWORD PTR [rsp+0x80],xmm0
  40460c:	00 
  40460d:	0f 29 84 24 90 00 00 	movaps XMMWORD PTR [rsp+0x90],xmm0
  404614:	00 
  404615:	0f 29 84 24 a0 00 00 	movaps XMMWORD PTR [rsp+0xa0],xmm0
  40461c:	00 
  40461d:	48 8b 5c 24 48       	mov    rbx,QWORD PTR [rsp+0x48]
  404622:	48 89 d8             	mov    rax,rbx
  404625:	41 89 dc             	mov    r12d,ebx
  404628:	48 8b 5c 24 18       	mov    rbx,QWORD PTR [rsp+0x18]
  40462d:	48 c1 e0 07          	shl    rax,0x7
  404631:	48 03 44 24 30       	add    rax,QWORD PTR [rsp+0x30]
  404636:	41 c1 e4 04          	shl    r12d,0x4
  40463a:	48 89 44 24 20       	mov    QWORD PTR [rsp+0x20],rax
  40463f:	48 8d 84 24 b0 00 00 	lea    rax,[rsp+0xb0]
  404646:	00 
  404647:	48 89 44 24 30       	mov    QWORD PTR [rsp+0x30],rax
  40464c:	8b 44 24 38          	mov    eax,DWORD PTR [rsp+0x38]
  404650:	83 e8 02             	sub    eax,0x2
  404653:	89 44 24 50          	mov    DWORD PTR [rsp+0x50],eax
  404657:	4c 8b 5c 24 58       	mov    r11,QWORD PTR [rsp+0x58]
  40465c:	42 8d 04 e5 00 00 00 	lea    eax,[r12*8+0x0]
  404663:	00 
  404664:	49 89 e9             	mov    r9,rbp
  404667:	44 8b 54 24 50       	mov    r10d,DWORD PTR [rsp+0x50]
  40466c:	4c 8b 44 24 20       	mov    r8,QWORD PTR [rsp+0x20]
  404671:	49 29 c1             	sub    r9,rax
  404674:	49 29 c3             	sub    r11,rax
  404677:	48 89 e8             	mov    rax,rbp
  40467a:	4c 29 c8             	sub    rax,r9
  40467d:	48 39 c5             	cmp    rbp,rax
  404680:	0f 86 c8 01 00 00    	jbe    40484e <chainhash_v3_evaluate.constprop.0+0x7be>
  404686:	48 89 e8             	mov    rax,rbp
  404689:	31 f6                	xor    esi,esi
  40468b:	4c 29 d8             	sub    rax,r11
  40468e:	48 39 c5             	cmp    rbp,rax
  404691:	0f 86 9f 00 00 00    	jbe    404736 <chainhash_v3_evaluate.constprop.0+0x6a6>
  404697:	41 0f b6 b0 f0 00 00 	movzx  esi,BYTE PTR [r8+0xf0]
  40469e:	00 
  40469f:	49 83 fb 01          	cmp    r11,0x1
  4046a3:	0f 84 8d 00 00 00    	je     404736 <chainhash_v3_evaluate.constprop.0+0x6a6>
  4046a9:	41 0f b6 80 f1 00 00 	movzx  eax,BYTE PTR [r8+0xf1]
  4046b0:	00 
  4046b1:	48 c1 e0 08          	shl    rax,0x8
  4046b5:	48 09 c6             	or     rsi,rax
  4046b8:	49 83 fb 02          	cmp    r11,0x2
  4046bc:	74 78                	je     404736 <chainhash_v3_evaluate.constprop.0+0x6a6>
  4046be:	41 0f b6 80 f2 00 00 	movzx  eax,BYTE PTR [r8+0xf2]
  4046c5:	00 
  4046c6:	48 c1 e0 10          	shl    rax,0x10
  4046ca:	48 09 c6             	or     rsi,rax
  4046cd:	49 83 fb 03          	cmp    r11,0x3
  4046d1:	74 63                	je     404736 <chainhash_v3_evaluate.constprop.0+0x6a6>
  4046d3:	41 0f b6 80 f3 00 00 	movzx  eax,BYTE PTR [r8+0xf3]
  4046da:	00 
  4046db:	48 c1 e0 18          	shl    rax,0x18
  4046df:	48 09 c6             	or     rsi,rax
  4046e2:	49 83 fb 04          	cmp    r11,0x4
  4046e6:	74 4e                	je     404736 <chainhash_v3_evaluate.constprop.0+0x6a6>
  4046e8:	41 0f b6 80 f4 00 00 	movzx  eax,BYTE PTR [r8+0xf4]
  4046ef:	00 
  4046f0:	48 c1 e0 20          	shl    rax,0x20
  4046f4:	48 09 c6             	or     rsi,rax
  4046f7:	49 83 fb 05          	cmp    r11,0x5
  4046fb:	74 39                	je     404736 <chainhash_v3_evaluate.constprop.0+0x6a6>
  4046fd:	41 0f b6 80 f5 00 00 	movzx  eax,BYTE PTR [r8+0xf5]
  404704:	00 
  404705:	48 c1 e0 28          	shl    rax,0x28
  404709:	48 09 c6             	or     rsi,rax
  40470c:	49 83 fb 06          	cmp    r11,0x6
  404710:	74 24                	je     404736 <chainhash_v3_evaluate.constprop.0+0x6a6>
  404712:	41 0f b6 80 f6 00 00 	movzx  eax,BYTE PTR [r8+0xf6]
  404719:	00 
  40471a:	48 c1 e0 30          	shl    rax,0x30
  40471e:	48 09 c6             	or     rsi,rax
  404721:	49 83 fb 07          	cmp    r11,0x7
  404725:	74 0f                	je     404736 <chainhash_v3_evaluate.constprop.0+0x6a6>
  404727:	41 0f b6 80 f7 00 00 	movzx  eax,BYTE PTR [r8+0xf7]
  40472e:	00 
  40472f:	48 c1 e0 38          	shl    rax,0x38
  404733:	48 09 c6             	or     rsi,rax
  404736:	44 89 d2             	mov    edx,r10d
  404739:	41 0f b6 b8 b0 00 00 	movzx  edi,BYTE PTR [r8+0xb0]
  404740:	00 
  404741:	41 8d 42 fe          	lea    eax,[r10-0x2]
  404745:	49 33 74 d5 00       	xor    rsi,QWORD PTR [r13+rdx*8+0x0]
  40474a:	49 83 f9 01          	cmp    r9,0x1
  40474e:	0f 84 8d 00 00 00    	je     4047e1 <chainhash_v3_evaluate.constprop.0+0x751>
  404754:	41 0f b6 90 b1 00 00 	movzx  edx,BYTE PTR [r8+0xb1]
  40475b:	00 
  40475c:	48 c1 e2 08          	shl    rdx,0x8
  404760:	48 09 d7             	or     rdi,rdx
  404763:	49 83 f9 02          	cmp    r9,0x2
  404767:	74 78                	je     4047e1 <chainhash_v3_evaluate.constprop.0+0x751>
  404769:	41 0f b6 90 b2 00 00 	movzx  edx,BYTE PTR [r8+0xb2]
  404770:	00 
  404771:	48 c1 e2 10          	shl    rdx,0x10
  404775:	48 09 d7             	or     rdi,rdx
  404778:	49 83 f9 03          	cmp    r9,0x3
  40477c:	74 63                	je     4047e1 <chainhash_v3_evaluate.constprop.0+0x751>
  40477e:	41 0f b6 90 b3 00 00 	movzx  edx,BYTE PTR [r8+0xb3]
  404785:	00 
  404786:	48 c1 e2 18          	shl    rdx,0x18
  40478a:	48 09 d7             	or     rdi,rdx
  40478d:	49 83 f9 04          	cmp    r9,0x4
  404791:	74 4e                	je     4047e1 <chainhash_v3_evaluate.constprop.0+0x751>
  404793:	41 0f b6 90 b4 00 00 	movzx  edx,BYTE PTR [r8+0xb4]
  40479a:	00 
  40479b:	48 c1 e2 20          	shl    rdx,0x20
  40479f:	48 09 d7             	or     rdi,rdx
  4047a2:	49 83 f9 05          	cmp    r9,0x5
  4047a6:	74 39                	je     4047e1 <chainhash_v3_evaluate.constprop.0+0x751>
  4047a8:	41 0f b6 90 b5 00 00 	movzx  edx,BYTE PTR [r8+0xb5]
  4047af:	00 
  4047b0:	48 c1 e2 28          	shl    rdx,0x28
  4047b4:	48 09 d7             	or     rdi,rdx
  4047b7:	49 83 f9 06          	cmp    r9,0x6
  4047bb:	74 24                	je     4047e1 <chainhash_v3_evaluate.constprop.0+0x751>
  4047bd:	41 0f b6 90 b6 00 00 	movzx  edx,BYTE PTR [r8+0xb6]
  4047c4:	00 
  4047c5:	48 c1 e2 30          	shl    rdx,0x30
  4047c9:	48 09 d7             	or     rdi,rdx
  4047cc:	49 83 f9 07          	cmp    r9,0x7
  4047d0:	74 0f                	je     4047e1 <chainhash_v3_evaluate.constprop.0+0x751>
  4047d2:	41 0f b6 90 b7 00 00 	movzx  edx,BYTE PTR [r8+0xb7]
  4047d9:	00 
  4047da:	48 c1 e2 38          	shl    rdx,0x38
  4047de:	48 09 d7             	or     rdi,rdx
  4047e1:	8b 4c 24 10          	mov    ecx,DWORD PTR [rsp+0x10]
  4047e5:	49 33 7c c5 00       	xor    rdi,QWORD PTR [r13+rax*8+0x0]
  4047ea:	85 c9                	test   ecx,ecx
  4047ec:	0f 85 5e 03 00 00    	jne    404b50 <chainhash_v3_evaluate.constprop.0+0xac0>
  4047f2:	4c 89 44 24 68       	mov    QWORD PTR [rsp+0x68],r8
  4047f7:	45 31 ff             	xor    r15d,r15d
  4047fa:	31 d2                	xor    edx,edx
  4047fc:	31 c9                	xor    ecx,ecx
  4047fe:	66 90                	xchg   ax,ax
  404800:	48 89 f0             	mov    rax,rsi
  404803:	49 89 fe             	mov    r14,rdi
  404806:	48 d3 e8             	shr    rax,cl
  404809:	49 d3 e6             	shl    r14,cl
  40480c:	83 e0 01             	and    eax,0x1
  40480f:	48 f7 d8             	neg    rax
  404812:	49 21 c6             	and    r14,rax
  404815:	4c 31 f2             	xor    rdx,r14
  404818:	44 8d 71 01          	lea    r14d,[rcx+0x1]
  40481c:	85 c9                	test   ecx,ecx
  40481e:	0f 84 dc 01 00 00    	je     404a00 <chainhash_v3_evaluate.constprop.0+0x970>
  404824:	b9 41 00 00 00       	mov    ecx,0x41
  404829:	49 89 f8             	mov    r8,rdi
  40482c:	44 29 f1             	sub    ecx,r14d
  40482f:	49 d3 e8             	shr    r8,cl
  404832:	4c 21 c0             	and    rax,r8
  404835:	49 31 c7             	xor    r15,rax
  404838:	41 83 fe 40          	cmp    r14d,0x40
  40483c:	0f 85 be 01 00 00    	jne    404a00 <chainhash_v3_evaluate.constprop.0+0x970>
  404842:	4c 8b 44 24 68       	mov    r8,QWORD PTR [rsp+0x68]
  404847:	48 31 13             	xor    QWORD PTR [rbx],rdx
  40484a:	4c 31 7b 08          	xor    QWORD PTR [rbx+0x8],r15
  40484e:	49 83 c0 08          	add    r8,0x8
  404852:	49 83 e9 08          	sub    r9,0x8
  404856:	41 83 c2 01          	add    r10d,0x1
  40485a:	49 83 eb 08          	sub    r11,0x8
  40485e:	44 3b 54 24 38       	cmp    r10d,DWORD PTR [rsp+0x38]
  404863:	0f 85 0e fe ff ff    	jne    404677 <chainhash_v3_evaluate.constprop.0+0x5e7>
  404869:	48 83 c3 10          	add    rbx,0x10
  40486d:	48 8d 84 24 b0 00 00 	lea    rax,[rsp+0xb0]
  404874:	00 
  404875:	48 83 44 24 20 10    	add    QWORD PTR [rsp+0x20],0x10
  40487b:	41 83 c4 02          	add    r12d,0x2
  40487f:	48 39 c3             	cmp    rbx,rax
  404882:	0f 85 cf fd ff ff    	jne    404657 <chainhash_v3_evaluate.constprop.0+0x5c7>
  404888:	48 83 44 24 48 01    	add    QWORD PTR [rsp+0x48],0x1
  40488e:	48 8b 44 24 48       	mov    rax,QWORD PTR [rsp+0x48]
  404893:	41 8d 5a 04          	lea    ebx,[r10+0x4]
  404897:	89 5c 24 38          	mov    DWORD PTR [rsp+0x38],ebx
  40489b:	48 83 f8 08          	cmp    rax,0x8
  40489f:	0f 85 78 fd ff ff    	jne    40461d <chainhash_v3_evaluate.constprop.0+0x58d>
  4048a5:	4c 8b 64 24 60       	mov    r12,QWORD PTR [rsp+0x60]
  4048aa:	8b 44 24 08          	mov    eax,DWORD PTR [rsp+0x8]
  4048ae:	8b 5c 24 28          	mov    ebx,DWORD PTR [rsp+0x28]
  4048b2:	4d 8d 7c 24 01       	lea    r15,[r12+0x1]
  4048b7:	4c 8b 74 24 18       	mov    r14,QWORD PTR [rsp+0x18]
  4048bc:	41 bb 41 00 00 00    	mov    r11d,0x41
  4048c2:	4d 8b 94 c5 00 01 00 	mov    r10,QWORD PTR [r13+rax*8+0x100]
  4048c9:	00 
  4048ca:	48 83 c0 28          	add    rax,0x28
  4048ce:	8d 53 ff             	lea    edx,[rbx-0x1]
  4048d1:	48 89 44 24 20       	mov    QWORD PTR [rsp+0x20],rax
  4048d6:	4c 89 e0             	mov    rax,r12
  4048d9:	4a 8d 1c 3a          	lea    rbx,[rdx+r15*1]
  4048dd:	48 89 5c 24 18       	mov    QWORD PTR [rsp+0x18],rbx
  4048e2:	31 d2                	xor    edx,edx
  4048e4:	48 f7 74 24 40       	div    QWORD PTR [rsp+0x40]
  4048e9:	48 89 d0             	mov    rax,rdx
  4048ec:	48 89 d3             	mov    rbx,rdx
  4048ef:	8b 54 24 14          	mov    edx,DWORD PTR [rsp+0x14]
  4048f3:	48 c1 e0 04          	shl    rax,0x4
  4048f7:	48 8b bc 04 b8 00 00 	mov    rdi,QWORD PTR [rsp+rax*1+0xb8]
  4048fe:	00 
  4048ff:	85 d2                	test   edx,edx
  404901:	0f 84 a2 02 00 00    	je     404ba9 <chainhash_v3_evaluate.constprop.0+0xb19>
  404907:	48 8b 74 24 20       	mov    rsi,QWORD PTR [rsp+0x20]
  40490c:	48 8b ac 04 c0 00 00 	mov    rbp,QWORD PTR [rsp+rax*1+0xc0]
  404913:	00 
  404914:	8b 44 24 10          	mov    eax,DWORD PTR [rsp+0x10]
  404918:	4d 8b 64 f5 08       	mov    r12,QWORD PTR [r13+rsi*8+0x8]
  40491d:	85 c0                	test   eax,eax
  40491f:	0f 85 60 0a 00 00    	jne    405385 <chainhash_v3_evaluate.constprop.0+0x12f5>
  404925:	45 31 c9             	xor    r9d,r9d
  404928:	45 31 c0             	xor    r8d,r8d
  40492b:	31 c9                	xor    ecx,ecx
  40492d:	4c 89 d0             	mov    rax,r10
  404930:	48 89 fa             	mov    rdx,rdi
  404933:	48 d3 e8             	shr    rax,cl
  404936:	48 d3 e2             	shl    rdx,cl
  404939:	83 e0 01             	and    eax,0x1
  40493c:	48 f7 d8             	neg    rax
  40493f:	48 21 c2             	and    rdx,rax
  404942:	49 31 d0             	xor    r8,rdx
  404945:	8d 51 01             	lea    edx,[rcx+0x1]
  404948:	85 c9                	test   ecx,ecx
  40494a:	74 16                	je     404962 <chainhash_v3_evaluate.constprop.0+0x8d2>
  40494c:	44 89 d9             	mov    ecx,r11d
  40494f:	48 89 fe             	mov    rsi,rdi
  404952:	29 d1                	sub    ecx,edx
  404954:	48 d3 ee             	shr    rsi,cl
  404957:	48 21 f0             	and    rax,rsi
  40495a:	49 31 c1             	xor    r9,rax
  40495d:	83 fa 40             	cmp    edx,0x40
  404960:	74 04                	je     404966 <chainhash_v3_evaluate.constprop.0+0x8d6>
  404962:	89 d1                	mov    ecx,edx
  404964:	eb c7                	jmp    40492d <chainhash_v3_evaluate.constprop.0+0x89d>
  404966:	4c 89 44 24 28       	mov    QWORD PTR [rsp+0x28],r8
  40496b:	31 ff                	xor    edi,edi
  40496d:	31 d2                	xor    edx,edx
  40496f:	31 c9                	xor    ecx,ecx
  404971:	4c 89 e0             	mov    rax,r12
  404974:	48 89 ee             	mov    rsi,rbp
  404977:	48 d3 e8             	shr    rax,cl
  40497a:	48 d3 e6             	shl    rsi,cl
  40497d:	83 e0 01             	and    eax,0x1
  404980:	48 f7 d8             	neg    rax
  404983:	48 21 c6             	and    rsi,rax
  404986:	48 31 f2             	xor    rdx,rsi
  404989:	8d 71 01             	lea    esi,[rcx+0x1]
  40498c:	85 c9                	test   ecx,ecx
  40498e:	74 16                	je     4049a6 <chainhash_v3_evaluate.constprop.0+0x916>
  404990:	44 89 d9             	mov    ecx,r11d
  404993:	49 89 e8             	mov    r8,rbp
  404996:	29 f1                	sub    ecx,esi
  404998:	49 d3 e8             	shr    r8,cl
  40499b:	4c 21 c0             	and    rax,r8
  40499e:	48 31 c7             	xor    rdi,rax
  4049a1:	83 fe 40             	cmp    esi,0x40
  4049a4:	74 04                	je     4049aa <chainhash_v3_evaluate.constprop.0+0x91a>
  4049a6:	89 f1                	mov    ecx,esi
  4049a8:	eb c7                	jmp    404971 <chainhash_v3_evaluate.constprop.0+0x8e1>
  4049aa:	4c 8b 44 24 28       	mov    r8,QWORD PTR [rsp+0x28]
  4049af:	48 89 d9             	mov    rcx,rbx
  4049b2:	48 89 d0             	mov    rax,rdx
  4049b5:	48 c1 e1 04          	shl    rcx,0x4
  4049b9:	4c 31 c0             	xor    rax,r8
  4049bc:	49 33 06             	xor    rax,QWORD PTR [r14]
  4049bf:	48 89 84 0c b8 00 00 	mov    QWORD PTR [rsp+rcx*1+0xb8],rax
  4049c6:	00 
  4049c7:	4c 89 c8             	mov    rax,r9
  4049ca:	48 31 f8             	xor    rax,rdi
  4049cd:	49 33 46 08          	xor    rax,QWORD PTR [r14+0x8]
  4049d1:	48 c1 e3 04          	shl    rbx,0x4
  4049d5:	4c 89 bc 24 40 01 00 	mov    QWORD PTR [rsp+0x140],r15
  4049dc:	00 
  4049dd:	49 83 c6 10          	add    r14,0x10
  4049e1:	48 89 84 1c c0 00 00 	mov    QWORD PTR [rsp+rbx*1+0xc0],rax
  4049e8:	00 
  4049e9:	4c 89 f8             	mov    rax,r15
  4049ec:	4c 3b 7c 24 18       	cmp    r15,QWORD PTR [rsp+0x18]
  4049f1:	0f 84 ce 02 00 00    	je     404cc5 <chainhash_v3_evaluate.constprop.0+0xc35>
  4049f7:	49 83 c7 01          	add    r15,0x1
  4049fb:	e9 e2 fe ff ff       	jmp    4048e2 <chainhash_v3_evaluate.constprop.0+0x852>
  404a00:	44 89 f1             	mov    ecx,r14d
  404a03:	e9 f8 fd ff ff       	jmp    404800 <chainhash_v3_evaluate.constprop.0+0x770>
  404a08:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
  404a0f:	00 
  404a10:	89 f1                	mov    ecx,esi
  404a12:	e9 ca fa ff ff       	jmp    4044e1 <chainhash_v3_evaluate.constprop.0+0x451>
  404a17:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  404a1e:	00 00 
  404a20:	89 f1                	mov    ecx,esi
  404a22:	e9 70 fa ff ff       	jmp    404497 <chainhash_v3_evaluate.constprop.0+0x407>
  404a27:	8b 74 24 10          	mov    esi,DWORD PTR [rsp+0x10]
  404a2b:	85 f6                	test   esi,esi
  404a2d:	0f 85 60 01 00 00    	jne    404b93 <chainhash_v3_evaluate.constprop.0+0xb03>
  404a33:	31 c0                	xor    eax,eax
  404a35:	31 ff                	xor    edi,edi
  404a37:	31 c9                	xor    ecx,ecx
  404a39:	4c 89 e6             	mov    rsi,r12
  404a3c:	49 89 d3             	mov    r11,rdx
  404a3f:	48 d3 ee             	shr    rsi,cl
  404a42:	49 d3 e3             	shl    r11,cl
  404a45:	83 e6 01             	and    esi,0x1
  404a48:	48 f7 de             	neg    rsi
  404a4b:	49 21 f3             	and    r11,rsi
  404a4e:	4c 31 df             	xor    rdi,r11
  404a51:	44 8d 59 01          	lea    r11d,[rcx+0x1]
  404a55:	85 c9                	test   ecx,ecx
  404a57:	0f 84 eb 00 00 00    	je     404b48 <chainhash_v3_evaluate.constprop.0+0xab8>
  404a5d:	b9 41 00 00 00       	mov    ecx,0x41
  404a62:	48 89 d3             	mov    rbx,rdx
  404a65:	44 29 d9             	sub    ecx,r11d
  404a68:	48 d3 eb             	shr    rbx,cl
  404a6b:	48 89 d9             	mov    rcx,rbx
  404a6e:	48 21 f1             	and    rcx,rsi
  404a71:	48 31 c8             	xor    rax,rcx
  404a74:	41 83 fb 40          	cmp    r11d,0x40
  404a78:	0f 85 ca 00 00 00    	jne    404b48 <chainhash_v3_evaluate.constprop.0+0xab8>
  404a7e:	48 89 c2             	mov    rdx,rax
  404a81:	48 89 c1             	mov    rcx,rax
  404a84:	49 8b 72 08          	mov    rsi,QWORD PTR [r10+0x8]
  404a88:	4c 89 c5             	mov    rbp,r8
  404a8b:	48 c1 e9 3d          	shr    rcx,0x3d
  404a8f:	48 c1 ea 3f          	shr    rdx,0x3f
  404a93:	48 31 ca             	xor    rdx,rcx
  404a96:	48 89 c1             	mov    rcx,rax
  404a99:	49 89 f3             	mov    r11,rsi
  404a9c:	48 c1 e5 04          	shl    rbp,0x4
  404aa0:	48 c1 e9 3c          	shr    rcx,0x3c
  404aa4:	49 c1 eb 3f          	shr    r11,0x3f
  404aa8:	48 8d 1c 36          	lea    rbx,[rsi+rsi*1]
  404aac:	48 31 ca             	xor    rdx,rcx
  404aaf:	48 89 f1             	mov    rcx,rsi
  404ab2:	48 c1 e9 3d          	shr    rcx,0x3d
  404ab6:	4c 31 d9             	xor    rcx,r11
  404ab9:	49 89 f3             	mov    r11,rsi
  404abc:	49 c1 eb 3c          	shr    r11,0x3c
  404ac0:	4c 31 d9             	xor    rcx,r11
  404ac3:	4d 8b 1a             	mov    r11,QWORD PTR [r10]
  404ac6:	49 31 f3             	xor    r11,rsi
  404ac9:	4c 31 db             	xor    rbx,r11
  404acc:	4c 8d 1c f5 00 00 00 	lea    r11,[rsi*8+0x0]
  404ad3:	00 
  404ad4:	48 c1 e6 04          	shl    rsi,0x4
  404ad8:	49 31 db             	xor    r11,rbx
  404adb:	49 31 f3             	xor    r11,rsi
  404ade:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
  404ae2:	49 31 cb             	xor    r11,rcx
  404ae5:	49 31 f3             	xor    r11,rsi
  404ae8:	48 8d 34 cd 00 00 00 	lea    rsi,[rcx*8+0x0]
  404aef:	00 
  404af0:	48 c1 e1 04          	shl    rcx,0x4
  404af4:	4c 31 de             	xor    rsi,r11
  404af7:	48 31 f1             	xor    rcx,rsi
  404afa:	48 8d 34 00          	lea    rsi,[rax+rax*1]
  404afe:	48 31 f9             	xor    rcx,rdi
  404b01:	48 31 c1             	xor    rcx,rax
  404b04:	48 31 f1             	xor    rcx,rsi
  404b07:	48 8d 34 c5 00 00 00 	lea    rsi,[rax*8+0x0]
  404b0e:	00 
  404b0f:	48 c1 e0 04          	shl    rax,0x4
  404b13:	48 31 f1             	xor    rcx,rsi
  404b16:	48 31 c8             	xor    rax,rcx
  404b19:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
  404b1d:	48 31 d0             	xor    rax,rdx
  404b20:	48 31 c8             	xor    rax,rcx
  404b23:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
  404b2a:	00 
  404b2b:	48 c1 e2 04          	shl    rdx,0x4
  404b2f:	48 31 c8             	xor    rax,rcx
  404b32:	48 31 d0             	xor    rax,rdx
  404b35:	45 31 db             	xor    r11d,r11d
  404b38:	48 89 84 2c b8 00 00 	mov    QWORD PTR [rsp+rbp*1+0xb8],rax
  404b3f:	00 
  404b40:	e9 fc f9 ff ff       	jmp    404541 <chainhash_v3_evaluate.constprop.0+0x4b1>
  404b45:	0f 1f 00             	nop    DWORD PTR [rax]
  404b48:	44 89 d9             	mov    ecx,r11d
  404b4b:	e9 e9 fe ff ff       	jmp    404a39 <chainhash_v3_evaluate.constprop.0+0x9a9>
  404b50:	e8 3b d5 ff ff       	call   402090 <chv3_hwprod>
  404b55:	49 89 d7             	mov    r15,rdx
  404b58:	48 89 c2             	mov    rdx,rax
  404b5b:	e9 e7 fc ff ff       	jmp    404847 <chainhash_v3_evaluate.constprop.0+0x7b7>
  404b60:	4d 8b 1a             	mov    r11,QWORD PTR [r10]
  404b63:	49 8b 5a 08          	mov    rbx,QWORD PTR [r10+0x8]
  404b67:	e9 b3 f6 ff ff       	jmp    40421f <chainhash_v3_evaluate.constprop.0+0x18f>
  404b6c:	4c 89 e6             	mov    rsi,r12
  404b6f:	48 89 d7             	mov    rdi,rdx
  404b72:	e8 19 d5 ff ff       	call   402090 <chv3_hwprod>
  404b77:	48 89 ef             	mov    rdi,rbp
  404b7a:	4c 89 f6             	mov    rsi,r14
  404b7d:	48 89 c3             	mov    rbx,rax
  404b80:	49 89 d3             	mov    r11,rdx
  404b83:	e8 08 d5 ff ff       	call   402090 <chv3_hwprod>
  404b88:	48 89 d7             	mov    rdi,rdx
  404b8b:	48 89 c2             	mov    rdx,rax
  404b8e:	e9 92 f9 ff ff       	jmp    404525 <chainhash_v3_evaluate.constprop.0+0x495>
  404b93:	48 89 d7             	mov    rdi,rdx
  404b96:	4c 89 e6             	mov    rsi,r12
  404b99:	e8 f2 d4 ff ff       	call   402090 <chv3_hwprod>
  404b9e:	48 89 c7             	mov    rdi,rax
  404ba1:	48 89 d0             	mov    rax,rdx
  404ba4:	e9 d5 fe ff ff       	jmp    404a7e <chainhash_v3_evaluate.constprop.0+0x9ee>
  404ba9:	8b 44 24 10          	mov    eax,DWORD PTR [rsp+0x10]
  404bad:	85 c0                	test   eax,eax
  404baf:	75 40                	jne    404bf1 <chainhash_v3_evaluate.constprop.0+0xb61>
  404bb1:	31 f6                	xor    esi,esi
  404bb3:	45 31 c0             	xor    r8d,r8d
  404bb6:	31 c9                	xor    ecx,ecx
  404bb8:	4c 89 d0             	mov    rax,r10
  404bbb:	48 89 fa             	mov    rdx,rdi
  404bbe:	48 d3 e8             	shr    rax,cl
  404bc1:	48 d3 e2             	shl    rdx,cl
  404bc4:	83 e0 01             	and    eax,0x1
  404bc7:	48 f7 d8             	neg    rax
  404bca:	48 21 c2             	and    rdx,rax
  404bcd:	49 31 d0             	xor    r8,rdx
  404bd0:	8d 51 01             	lea    edx,[rcx+0x1]
  404bd3:	85 c9                	test   ecx,ecx
  404bd5:	74 16                	je     404bed <chainhash_v3_evaluate.constprop.0+0xb5d>
  404bd7:	44 89 d9             	mov    ecx,r11d
  404bda:	49 89 f9             	mov    r9,rdi
  404bdd:	29 d1                	sub    ecx,edx
  404bdf:	49 d3 e9             	shr    r9,cl
  404be2:	4c 21 c8             	and    rax,r9
  404be5:	48 31 c6             	xor    rsi,rax
  404be8:	83 fa 40             	cmp    edx,0x40
  404beb:	74 12                	je     404bff <chainhash_v3_evaluate.constprop.0+0xb6f>
  404bed:	89 d1                	mov    ecx,edx
  404bef:	eb c7                	jmp    404bb8 <chainhash_v3_evaluate.constprop.0+0xb28>
  404bf1:	4c 89 d6             	mov    rsi,r10
  404bf4:	e8 97 d4 ff ff       	call   402090 <chv3_hwprod>
  404bf9:	49 89 c0             	mov    r8,rax
  404bfc:	48 89 d6             	mov    rsi,rdx
  404bff:	48 89 f1             	mov    rcx,rsi
  404c02:	48 89 f0             	mov    rax,rsi
  404c05:	4d 8b 4e 08          	mov    r9,QWORD PTR [r14+0x8]
  404c09:	48 89 da             	mov    rdx,rbx
  404c0c:	48 c1 e8 3d          	shr    rax,0x3d
  404c10:	48 c1 e9 3f          	shr    rcx,0x3f
  404c14:	48 31 c1             	xor    rcx,rax
  404c17:	48 89 f0             	mov    rax,rsi
  404c1a:	4c 89 cf             	mov    rdi,r9
  404c1d:	48 c1 e2 04          	shl    rdx,0x4
  404c21:	48 c1 e8 3c          	shr    rax,0x3c
  404c25:	48 c1 ef 3f          	shr    rdi,0x3f
  404c29:	4b 8d 2c 09          	lea    rbp,[r9+r9*1]
  404c2d:	48 31 c1             	xor    rcx,rax
  404c30:	4c 89 c8             	mov    rax,r9
  404c33:	48 c1 e8 3d          	shr    rax,0x3d
  404c37:	48 31 c7             	xor    rdi,rax
  404c3a:	4c 89 c8             	mov    rax,r9
  404c3d:	48 c1 e8 3c          	shr    rax,0x3c
  404c41:	48 31 c7             	xor    rdi,rax
  404c44:	49 8b 06             	mov    rax,QWORD PTR [r14]
  404c47:	4c 31 c8             	xor    rax,r9
  404c4a:	48 31 e8             	xor    rax,rbp
  404c4d:	4a 8d 2c cd 00 00 00 	lea    rbp,[r9*8+0x0]
  404c54:	00 
  404c55:	49 c1 e1 04          	shl    r9,0x4
  404c59:	48 31 e8             	xor    rax,rbp
  404c5c:	4c 31 c8             	xor    rax,r9
  404c5f:	4c 8d 0c 3f          	lea    r9,[rdi+rdi*1]
  404c63:	48 31 f8             	xor    rax,rdi
  404c66:	4c 31 c8             	xor    rax,r9
  404c69:	4c 8d 0c fd 00 00 00 	lea    r9,[rdi*8+0x0]
  404c70:	00 
  404c71:	48 c1 e7 04          	shl    rdi,0x4
  404c75:	4c 31 c8             	xor    rax,r9
  404c78:	48 31 f8             	xor    rax,rdi
  404c7b:	48 8d 3c 36          	lea    rdi,[rsi+rsi*1]
  404c7f:	48 31 f0             	xor    rax,rsi
  404c82:	4c 31 c0             	xor    rax,r8
  404c85:	48 31 f8             	xor    rax,rdi
  404c88:	48 8d 3c f5 00 00 00 	lea    rdi,[rsi*8+0x0]
  404c8f:	00 
  404c90:	48 c1 e6 04          	shl    rsi,0x4
  404c94:	48 31 f8             	xor    rax,rdi
  404c97:	48 31 f0             	xor    rax,rsi
  404c9a:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
  404c9e:	48 31 c8             	xor    rax,rcx
  404ca1:	48 31 f0             	xor    rax,rsi
  404ca4:	48 8d 34 cd 00 00 00 	lea    rsi,[rcx*8+0x0]
  404cab:	00 
  404cac:	48 c1 e1 04          	shl    rcx,0x4
  404cb0:	48 31 f0             	xor    rax,rsi
  404cb3:	48 31 c8             	xor    rax,rcx
  404cb6:	48 89 84 14 b8 00 00 	mov    QWORD PTR [rsp+rdx*1+0xb8],rax
  404cbd:	00 
  404cbe:	31 c0                	xor    eax,eax
  404cc0:	e9 0c fd ff ff       	jmp    4049d1 <chainhash_v3_evaluate.constprop.0+0x941>
  404cc5:	44 8b 64 24 08       	mov    r12d,DWORD PTR [rsp+0x8]
  404cca:	4c 8b ac 24 b0 00 00 	mov    r13,QWORD PTR [rsp+0xb0]
  404cd1:	00 
  404cd2:	48 c7 84 24 58 01 00 	mov    QWORD PTR [rsp+0x158],0x0
  404cd9:	00 00 00 00 00 
  404cde:	45 85 e4             	test   r12d,r12d
  404ce1:	0f 84 8e 01 00 00    	je     404e75 <chainhash_v3_evaluate.constprop.0+0xde5>
  404ce7:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
  404cec:	41 b8 01 00 00 00    	mov    r8d,0x1
  404cf2:	bb 41 00 00 00       	mov    ebx,0x41
  404cf7:	48 c7 44 24 20 00 00 	mov    QWORD PTR [rsp+0x20],0x0
  404cfe:	00 00 
  404d00:	4c 8d 58 01          	lea    r11,[rax+0x1]
  404d04:	e9 92 00 00 00       	jmp    404d9b <chainhash_v3_evaluate.constprop.0+0xd0b>
  404d09:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  404d10:	89 d9                	mov    ecx,ebx
  404d12:	4d 89 cf             	mov    r15,r9
  404d15:	29 d1                	sub    ecx,edx
  404d17:	49 d3 ef             	shr    r15,cl
  404d1a:	4c 21 f8             	and    rax,r15
  404d1d:	48 31 c7             	xor    rdi,rax
  404d20:	83 fa 40             	cmp    edx,0x40
  404d23:	0f 85 32 01 00 00    	jne    404e5b <chainhash_v3_evaluate.constprop.0+0xdcb>
  404d29:	48 89 fa             	mov    rdx,rdi
  404d2c:	48 89 f8             	mov    rax,rdi
  404d2f:	48 8d 0c 3f          	lea    rcx,[rdi+rdi*1]
  404d33:	49 83 c0 01          	add    r8,0x1
  404d37:	48 c1 e8 3d          	shr    rax,0x3d
  404d3b:	48 c1 ea 3f          	shr    rdx,0x3f
  404d3f:	48 31 c2             	xor    rdx,rax
  404d42:	48 89 f8             	mov    rax,rdi
  404d45:	48 c1 e8 3c          	shr    rax,0x3c
  404d49:	48 31 c2             	xor    rdx,rax
  404d4c:	48 89 f0             	mov    rax,rsi
  404d4f:	48 31 f8             	xor    rax,rdi
  404d52:	48 33 44 24 20       	xor    rax,QWORD PTR [rsp+0x20]
  404d57:	48 31 c8             	xor    rax,rcx
  404d5a:	48 8d 0c fd 00 00 00 	lea    rcx,[rdi*8+0x0]
  404d61:	00 
  404d62:	48 c1 e7 04          	shl    rdi,0x4
  404d66:	48 31 c8             	xor    rax,rcx
  404d69:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
  404d6d:	48 31 f8             	xor    rax,rdi
  404d70:	48 31 d0             	xor    rax,rdx
  404d73:	48 31 c8             	xor    rax,rcx
  404d76:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
  404d7d:	00 
  404d7e:	48 c1 e2 04          	shl    rdx,0x4
  404d82:	48 31 c8             	xor    rax,rcx
  404d85:	48 31 c2             	xor    rdx,rax
  404d88:	41 8d 40 ff          	lea    eax,[r8-0x1]
  404d8c:	48 89 54 24 20       	mov    QWORD PTR [rsp+0x20],rdx
  404d91:	39 44 24 08          	cmp    DWORD PTR [rsp+0x8],eax
  404d95:	0f 86 0e 06 00 00    	jbe    4053a9 <chainhash_v3_evaluate.constprop.0+0x1319>
  404d9b:	4d 39 d8             	cmp    r8,r11
  404d9e:	0f 84 da 00 00 00    	je     404e7e <chainhash_v3_evaluate.constprop.0+0xdee>
  404da4:	48 8b 44 24 18       	mov    rax,QWORD PTR [rsp+0x18]
  404da9:	31 d2                	xor    edx,edx
  404dab:	4c 89 c1             	mov    rcx,r8
  404dae:	8b 6c 24 10          	mov    ebp,DWORD PTR [rsp+0x10]
  404db2:	48 c1 e1 04          	shl    rcx,0x4
  404db6:	4c 29 c0             	sub    rax,r8
  404db9:	4c 8b 8c 0c a8 00 00 	mov    r9,QWORD PTR [rsp+rcx*1+0xa8]
  404dc0:	00 
  404dc1:	48 f7 74 24 40       	div    QWORD PTR [rsp+0x40]
  404dc6:	48 8b 44 24 30       	mov    rax,QWORD PTR [rsp+0x30]
  404dcb:	4d 8b 94 d5 00 01 00 	mov    r10,QWORD PTR [r13+rdx*8+0x100]
  404dd2:	00 
  404dd3:	48 8b 14 08          	mov    rdx,QWORD PTR [rax+rcx*1]
  404dd7:	48 89 d0             	mov    rax,rdx
  404dda:	48 89 d6             	mov    rsi,rdx
  404ddd:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
  404de1:	49 31 d1             	xor    r9,rdx
  404de4:	48 c1 ee 3d          	shr    rsi,0x3d
  404de8:	48 c1 e8 3f          	shr    rax,0x3f
  404dec:	49 31 c9             	xor    r9,rcx
  404def:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
  404df6:	00 
  404df7:	48 31 f0             	xor    rax,rsi
  404dfa:	48 89 d6             	mov    rsi,rdx
  404dfd:	49 31 c9             	xor    r9,rcx
  404e00:	48 c1 e2 04          	shl    rdx,0x4
  404e04:	48 c1 ee 3c          	shr    rsi,0x3c
  404e08:	49 31 d1             	xor    r9,rdx
  404e0b:	48 31 f0             	xor    rax,rsi
  404e0e:	48 8d 14 00          	lea    rdx,[rax+rax*1]
  404e12:	49 31 c1             	xor    r9,rax
  404e15:	49 31 d1             	xor    r9,rdx
  404e18:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
  404e1f:	00 
  404e20:	48 c1 e0 04          	shl    rax,0x4
  404e24:	49 31 d1             	xor    r9,rdx
  404e27:	49 31 c1             	xor    r9,rax
  404e2a:	85 ed                	test   ebp,ebp
  404e2c:	75 31                	jne    404e5f <chainhash_v3_evaluate.constprop.0+0xdcf>
  404e2e:	31 ff                	xor    edi,edi
  404e30:	31 f6                	xor    esi,esi
  404e32:	31 c9                	xor    ecx,ecx
  404e34:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  404e38:	4c 89 d0             	mov    rax,r10
  404e3b:	4c 89 ca             	mov    rdx,r9
  404e3e:	48 d3 e8             	shr    rax,cl
  404e41:	48 d3 e2             	shl    rdx,cl
  404e44:	83 e0 01             	and    eax,0x1
  404e47:	48 f7 d8             	neg    rax
  404e4a:	48 21 c2             	and    rdx,rax
  404e4d:	48 31 d6             	xor    rsi,rdx
  404e50:	8d 51 01             	lea    edx,[rcx+0x1]
  404e53:	85 c9                	test   ecx,ecx
  404e55:	0f 85 b5 fe ff ff    	jne    404d10 <chainhash_v3_evaluate.constprop.0+0xc80>
  404e5b:	89 d1                	mov    ecx,edx
  404e5d:	eb d9                	jmp    404e38 <chainhash_v3_evaluate.constprop.0+0xda8>
  404e5f:	4c 89 d6             	mov    rsi,r10
  404e62:	4c 89 cf             	mov    rdi,r9
  404e65:	e8 26 d2 ff ff       	call   402090 <chv3_hwprod>
  404e6a:	48 89 c6             	mov    rsi,rax
  404e6d:	48 89 d7             	mov    rdi,rdx
  404e70:	e9 b4 fe ff ff       	jmp    404d29 <chainhash_v3_evaluate.constprop.0+0xc99>
  404e75:	48 c7 44 24 20 00 00 	mov    QWORD PTR [rsp+0x20],0x0
  404e7c:	00 00 
  404e7e:	48 83 7c 24 18 00    	cmp    QWORD PTR [rsp+0x18],0x0
  404e84:	4d 8b 8d 08 01 00 00 	mov    r9,QWORD PTR [r13+0x108]
  404e8b:	0f 84 ff 05 00 00    	je     405490 <chainhash_v3_evaluate.constprop.0+0x1400>
  404e91:	4c 8b 5c 24 18       	mov    r11,QWORD PTR [rsp+0x18]
  404e96:	8b 5c 24 10          	mov    ebx,DWORD PTR [rsp+0x10]
  404e9a:	41 b8 01 00 00 00    	mov    r8d,0x1
  404ea0:	41 ba 41 00 00 00    	mov    r10d,0x41
  404ea6:	41 f6 c3 01          	test   r11b,0x1
  404eaa:	0f 84 a4 00 00 00    	je     404f54 <chainhash_v3_evaluate.constprop.0+0xec4>
  404eb0:	85 db                	test   ebx,ebx
  404eb2:	0f 85 7e 04 00 00    	jne    405336 <chainhash_v3_evaluate.constprop.0+0x12a6>
  404eb8:	31 f6                	xor    esi,esi
  404eba:	31 ff                	xor    edi,edi
  404ebc:	31 c9                	xor    ecx,ecx
  404ebe:	4c 89 c8             	mov    rax,r9
  404ec1:	4c 89 c2             	mov    rdx,r8
  404ec4:	48 d3 e8             	shr    rax,cl
  404ec7:	48 d3 e2             	shl    rdx,cl
  404eca:	83 e0 01             	and    eax,0x1
  404ecd:	48 f7 d8             	neg    rax
  404ed0:	48 21 c2             	and    rdx,rax
  404ed3:	48 31 d7             	xor    rdi,rdx
  404ed6:	8d 51 01             	lea    edx,[rcx+0x1]
  404ed9:	85 c9                	test   ecx,ecx
  404edb:	0f 84 93 03 00 00    	je     405274 <chainhash_v3_evaluate.constprop.0+0x11e4>
  404ee1:	44 89 d1             	mov    ecx,r10d
  404ee4:	4d 89 c7             	mov    r15,r8
  404ee7:	29 d1                	sub    ecx,edx
  404ee9:	49 d3 ef             	shr    r15,cl
  404eec:	4c 21 f8             	and    rax,r15
  404eef:	48 31 c6             	xor    rsi,rax
  404ef2:	83 fa 40             	cmp    edx,0x40
  404ef5:	0f 85 79 03 00 00    	jne    405274 <chainhash_v3_evaluate.constprop.0+0x11e4>
  404efb:	48 89 f2             	mov    rdx,rsi
  404efe:	48 89 f0             	mov    rax,rsi
  404f01:	48 8d 0c 36          	lea    rcx,[rsi+rsi*1]
  404f05:	48 c1 e8 3d          	shr    rax,0x3d
  404f09:	48 c1 ea 3f          	shr    rdx,0x3f
  404f0d:	48 31 c2             	xor    rdx,rax
  404f10:	48 89 f0             	mov    rax,rsi
  404f13:	48 c1 e8 3c          	shr    rax,0x3c
  404f17:	48 31 c2             	xor    rdx,rax
  404f1a:	48 89 f8             	mov    rax,rdi
  404f1d:	48 31 f0             	xor    rax,rsi
  404f20:	48 31 c8             	xor    rax,rcx
  404f23:	48 8d 0c f5 00 00 00 	lea    rcx,[rsi*8+0x0]
  404f2a:	00 
  404f2b:	48 c1 e6 04          	shl    rsi,0x4
  404f2f:	48 31 c8             	xor    rax,rcx
  404f32:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
  404f36:	48 31 f0             	xor    rax,rsi
  404f39:	48 31 d0             	xor    rax,rdx
  404f3c:	48 31 c8             	xor    rax,rcx
  404f3f:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
  404f46:	00 
  404f47:	48 c1 e2 04          	shl    rdx,0x4
  404f4b:	48 31 c8             	xor    rax,rcx
  404f4e:	48 31 d0             	xor    rax,rdx
  404f51:	49 89 c0             	mov    r8,rax
  404f54:	49 d1 eb             	shr    r11,1
  404f57:	0f 85 1e 03 00 00    	jne    40527b <chainhash_v3_evaluate.constprop.0+0x11eb>
  404f5d:	8b 7c 24 10          	mov    edi,DWORD PTR [rsp+0x10]
  404f61:	4c 8b 8c 24 38 01 00 	mov    r9,QWORD PTR [rsp+0x138]
  404f68:	00 
  404f69:	85 ff                	test   edi,edi
  404f6b:	75 45                	jne    404fb2 <chainhash_v3_evaluate.constprop.0+0xf22>
  404f6d:	31 ff                	xor    edi,edi
  404f6f:	31 d2                	xor    edx,edx
  404f71:	31 c9                	xor    ecx,ecx
  404f73:	41 ba 41 00 00 00    	mov    r10d,0x41
  404f79:	4c 89 c0             	mov    rax,r8
  404f7c:	4c 89 ce             	mov    rsi,r9
  404f7f:	48 d3 e8             	shr    rax,cl
  404f82:	48 d3 e6             	shl    rsi,cl
  404f85:	83 e0 01             	and    eax,0x1
  404f88:	48 f7 d8             	neg    rax
  404f8b:	48 21 c6             	and    rsi,rax
  404f8e:	48 31 f2             	xor    rdx,rsi
  404f91:	8d 71 01             	lea    esi,[rcx+0x1]
  404f94:	85 c9                	test   ecx,ecx
  404f96:	74 16                	je     404fae <chainhash_v3_evaluate.constprop.0+0xf1e>
  404f98:	44 89 d1             	mov    ecx,r10d
  404f9b:	4c 89 cb             	mov    rbx,r9
  404f9e:	29 f1                	sub    ecx,esi
  404fa0:	48 d3 eb             	shr    rbx,cl
  404fa3:	48 21 d8             	and    rax,rbx
  404fa6:	48 31 c7             	xor    rdi,rax
  404fa9:	83 fe 40             	cmp    esi,0x40
  404fac:	74 15                	je     404fc3 <chainhash_v3_evaluate.constprop.0+0xf33>
  404fae:	89 f1                	mov    ecx,esi
  404fb0:	eb c7                	jmp    404f79 <chainhash_v3_evaluate.constprop.0+0xee9>
  404fb2:	4c 89 cf             	mov    rdi,r9
  404fb5:	4c 89 c6             	mov    rsi,r8
  404fb8:	e8 d3 d0 ff ff       	call   402090 <chv3_hwprod>
  404fbd:	48 89 d7             	mov    rdi,rdx
  404fc0:	48 89 c2             	mov    rdx,rax
  404fc3:	4c 8b 44 24 20       	mov    r8,QWORD PTR [rsp+0x20]
  404fc8:	48 31 fa             	xor    rdx,rdi
  404fcb:	48 89 f8             	mov    rax,rdi
  404fce:	48 89 f9             	mov    rcx,rdi
  404fd1:	48 c1 e9 3d          	shr    rcx,0x3d
  404fd5:	48 c1 e8 3f          	shr    rax,0x3f
  404fd9:	8b 74 24 10          	mov    esi,DWORD PTR [rsp+0x10]
  404fdd:	49 31 d0             	xor    r8,rdx
  404fe0:	48 8d 14 3f          	lea    rdx,[rdi+rdi*1]
  404fe4:	48 31 c8             	xor    rax,rcx
  404fe7:	48 89 f9             	mov    rcx,rdi
  404fea:	49 31 d0             	xor    r8,rdx
  404fed:	48 8d 14 fd 00 00 00 	lea    rdx,[rdi*8+0x0]
  404ff4:	00 
  404ff5:	48 c1 e9 3c          	shr    rcx,0x3c
  404ff9:	49 31 d0             	xor    r8,rdx
  404ffc:	48 c1 e7 04          	shl    rdi,0x4
  405000:	48 31 c8             	xor    rax,rcx
  405003:	49 31 f8             	xor    r8,rdi
  405006:	48 8d 14 00          	lea    rdx,[rax+rax*1]
  40500a:	49 31 c0             	xor    r8,rax
  40500d:	49 31 d0             	xor    r8,rdx
  405010:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
  405017:	00 
  405018:	48 c1 e0 04          	shl    rax,0x4
  40501c:	49 31 d0             	xor    r8,rdx
  40501f:	49 31 c0             	xor    r8,rax
  405022:	4d 03 85 b8 01 00 00 	add    r8,QWORD PTR [r13+0x1b8]
  405029:	85 f6                	test   esi,esi
  40502b:	75 45                	jne    405072 <chainhash_v3_evaluate.constprop.0+0xfe2>
  40502d:	31 ff                	xor    edi,edi
  40502f:	31 f6                	xor    esi,esi
  405031:	31 c9                	xor    ecx,ecx
  405033:	41 b9 41 00 00 00    	mov    r9d,0x41
  405039:	4c 89 c0             	mov    rax,r8
  40503c:	4c 89 c2             	mov    rdx,r8
  40503f:	48 d3 e8             	shr    rax,cl
  405042:	48 d3 e2             	shl    rdx,cl
  405045:	83 e0 01             	and    eax,0x1
  405048:	48 f7 d8             	neg    rax
  40504b:	48 21 c2             	and    rdx,rax
  40504e:	48 31 d6             	xor    rsi,rdx
  405051:	8d 51 01             	lea    edx,[rcx+0x1]
  405054:	85 c9                	test   ecx,ecx
  405056:	74 16                	je     40506e <chainhash_v3_evaluate.constprop.0+0xfde>
  405058:	44 89 c9             	mov    ecx,r9d
  40505b:	4c 89 c3             	mov    rbx,r8
  40505e:	29 d1                	sub    ecx,edx
  405060:	48 d3 eb             	shr    rbx,cl
  405063:	48 21 d8             	and    rax,rbx
  405066:	48 31 c7             	xor    rdi,rax
  405069:	83 fa 40             	cmp    edx,0x40
  40506c:	74 15                	je     405083 <chainhash_v3_evaluate.constprop.0+0xff3>
  40506e:	89 d1                	mov    ecx,edx
  405070:	eb c7                	jmp    405039 <chainhash_v3_evaluate.constprop.0+0xfa9>
  405072:	4c 89 c6             	mov    rsi,r8
  405075:	4c 89 c7             	mov    rdi,r8
  405078:	e8 13 d0 ff ff       	call   402090 <chv3_hwprod>
  40507d:	48 89 c6             	mov    rsi,rax
  405080:	48 89 d7             	mov    rdi,rdx
  405083:	48 89 fa             	mov    rdx,rdi
  405086:	48 89 f8             	mov    rax,rdi
  405089:	48 8d 0c 3f          	lea    rcx,[rdi+rdi*1]
  40508d:	4d 8b 95 98 01 00 00 	mov    r10,QWORD PTR [r13+0x198]
  405094:	48 c1 e8 3d          	shr    rax,0x3d
  405098:	48 c1 ea 3f          	shr    rdx,0x3f
  40509c:	48 31 c2             	xor    rdx,rax
  40509f:	48 89 f8             	mov    rax,rdi
  4050a2:	4d 31 c2             	xor    r10,r8
  4050a5:	48 c1 e8 3c          	shr    rax,0x3c
  4050a9:	48 31 c2             	xor    rdx,rax
  4050ac:	48 89 f0             	mov    rax,rsi
  4050af:	48 31 f8             	xor    rax,rdi
  4050b2:	48 31 c8             	xor    rax,rcx
  4050b5:	48 8d 0c fd 00 00 00 	lea    rcx,[rdi*8+0x0]
  4050bc:	00 
  4050bd:	48 c1 e7 04          	shl    rdi,0x4
  4050c1:	48 31 c8             	xor    rax,rcx
  4050c4:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
  4050c8:	48 31 f8             	xor    rax,rdi
  4050cb:	48 31 d0             	xor    rax,rdx
  4050ce:	48 31 c8             	xor    rax,rcx
  4050d1:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
  4050d8:	00 
  4050d9:	48 c1 e2 04          	shl    rdx,0x4
  4050dd:	48 31 c8             	xor    rax,rcx
  4050e0:	8b 4c 24 10          	mov    ecx,DWORD PTR [rsp+0x10]
  4050e4:	48 31 d0             	xor    rax,rdx
  4050e7:	49 31 c2             	xor    r10,rax
  4050ea:	49 33 85 90 01 00 00 	xor    rax,QWORD PTR [r13+0x190]
  4050f1:	49 89 c1             	mov    r9,rax
  4050f4:	85 c9                	test   ecx,ecx
  4050f6:	75 45                	jne    40513d <chainhash_v3_evaluate.constprop.0+0x10ad>
  4050f8:	31 ff                	xor    edi,edi
  4050fa:	31 c0                	xor    eax,eax
  4050fc:	31 c9                	xor    ecx,ecx
  4050fe:	41 bb 41 00 00 00    	mov    r11d,0x41
  405104:	4c 89 d2             	mov    rdx,r10
  405107:	4c 89 ce             	mov    rsi,r9
  40510a:	48 d3 ea             	shr    rdx,cl
  40510d:	48 d3 e6             	shl    rsi,cl
  405110:	83 e2 01             	and    edx,0x1
  405113:	48 f7 da             	neg    rdx
  405116:	48 21 d6             	and    rsi,rdx
  405119:	48 31 f0             	xor    rax,rsi
  40511c:	8d 71 01             	lea    esi,[rcx+0x1]
  40511f:	85 c9                	test   ecx,ecx
  405121:	74 16                	je     405139 <chainhash_v3_evaluate.constprop.0+0x10a9>
  405123:	44 89 d9             	mov    ecx,r11d
  405126:	4c 89 cb             	mov    rbx,r9
  405129:	29 f1                	sub    ecx,esi
  40512b:	48 d3 eb             	shr    rbx,cl
  40512e:	48 21 da             	and    rdx,rbx
  405131:	48 31 d7             	xor    rdi,rdx
  405134:	83 fe 40             	cmp    esi,0x40
  405137:	74 12                	je     40514b <chainhash_v3_evaluate.constprop.0+0x10bb>
  405139:	89 f1                	mov    ecx,esi
  40513b:	eb c7                	jmp    405104 <chainhash_v3_evaluate.constprop.0+0x1074>
  40513d:	48 89 c7             	mov    rdi,rax
  405140:	4c 89 d6             	mov    rsi,r10
  405143:	e8 48 cf ff ff       	call   402090 <chv3_hwprod>
  405148:	48 89 d7             	mov    rdi,rdx
  40514b:	49 8b b5 a8 01 00 00 	mov    rsi,QWORD PTR [r13+0x1a8]
  405152:	48 31 f8             	xor    rax,rdi
  405155:	48 89 fa             	mov    rdx,rdi
  405158:	48 89 f9             	mov    rcx,rdi
  40515b:	48 c1 e9 3d          	shr    rcx,0x3d
  40515f:	48 c1 ea 3f          	shr    rdx,0x3f
  405163:	4d 33 85 a0 01 00 00 	xor    r8,QWORD PTR [r13+0x1a0]
  40516a:	48 31 c6             	xor    rsi,rax
  40516d:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  405171:	48 31 ca             	xor    rdx,rcx
  405174:	48 89 f9             	mov    rcx,rdi
  405177:	48 31 c6             	xor    rsi,rax
  40517a:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  405181:	00 
  405182:	48 c1 e9 3c          	shr    rcx,0x3c
  405186:	48 31 c6             	xor    rsi,rax
  405189:	48 c1 e7 04          	shl    rdi,0x4
  40518d:	48 31 ca             	xor    rdx,rcx
  405190:	48 31 fe             	xor    rsi,rdi
  405193:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  405197:	48 31 d6             	xor    rsi,rdx
  40519a:	48 31 c6             	xor    rsi,rax
  40519d:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  4051a4:	00 
  4051a5:	48 c1 e2 04          	shl    rdx,0x4
  4051a9:	48 31 c6             	xor    rsi,rax
  4051ac:	48 31 d6             	xor    rsi,rdx
  4051af:	8b 54 24 10          	mov    edx,DWORD PTR [rsp+0x10]
  4051b3:	85 d2                	test   edx,edx
  4051b5:	75 46                	jne    4051fd <chainhash_v3_evaluate.constprop.0+0x116d>
  4051b7:	45 31 c9             	xor    r9d,r9d
  4051ba:	31 c0                	xor    eax,eax
  4051bc:	31 c9                	xor    ecx,ecx
  4051be:	41 ba 41 00 00 00    	mov    r10d,0x41
  4051c4:	48 89 f2             	mov    rdx,rsi
  4051c7:	4c 89 c7             	mov    rdi,r8
  4051ca:	48 d3 ea             	shr    rdx,cl
  4051cd:	48 d3 e7             	shl    rdi,cl
  4051d0:	83 e2 01             	and    edx,0x1
  4051d3:	48 f7 da             	neg    rdx
  4051d6:	48 21 d7             	and    rdi,rdx
  4051d9:	48 31 f8             	xor    rax,rdi
  4051dc:	8d 79 01             	lea    edi,[rcx+0x1]
  4051df:	85 c9                	test   ecx,ecx
  4051e1:	74 16                	je     4051f9 <chainhash_v3_evaluate.constprop.0+0x1169>
  4051e3:	44 89 d1             	mov    ecx,r10d
  4051e6:	4c 89 c3             	mov    rbx,r8
  4051e9:	29 f9                	sub    ecx,edi
  4051eb:	48 d3 eb             	shr    rbx,cl
  4051ee:	48 21 da             	and    rdx,rbx
  4051f1:	49 31 d1             	xor    r9,rdx
  4051f4:	83 ff 40             	cmp    edi,0x40
  4051f7:	74 0f                	je     405208 <chainhash_v3_evaluate.constprop.0+0x1178>
  4051f9:	89 f9                	mov    ecx,edi
  4051fb:	eb c7                	jmp    4051c4 <chainhash_v3_evaluate.constprop.0+0x1134>
  4051fd:	4c 89 c7             	mov    rdi,r8
  405200:	e8 8b ce ff ff       	call   402090 <chv3_hwprod>
  405205:	49 89 d1             	mov    r9,rdx
  405208:	4c 89 ca             	mov    rdx,r9
  40520b:	4c 89 c9             	mov    rcx,r9
  40520e:	4c 31 c8             	xor    rax,r9
  405211:	49 33 85 b0 01 00 00 	xor    rax,QWORD PTR [r13+0x1b0]
  405218:	48 c1 e9 3d          	shr    rcx,0x3d
  40521c:	48 c1 ea 3f          	shr    rdx,0x3f
  405220:	48 81 c4 68 05 00 00 	add    rsp,0x568
  405227:	48 31 ca             	xor    rdx,rcx
  40522a:	4c 89 c9             	mov    rcx,r9
  40522d:	5b                   	pop    rbx
  40522e:	5d                   	pop    rbp
  40522f:	48 c1 e9 3c          	shr    rcx,0x3c
  405233:	41 5c                	pop    r12
  405235:	41 5d                	pop    r13
  405237:	48 31 ca             	xor    rdx,rcx
  40523a:	4b 8d 0c 09          	lea    rcx,[r9+r9*1]
  40523e:	41 5e                	pop    r14
  405240:	41 5f                	pop    r15
  405242:	48 31 c8             	xor    rax,rcx
  405245:	4a 8d 0c cd 00 00 00 	lea    rcx,[r9*8+0x0]
  40524c:	00 
  40524d:	49 c1 e1 04          	shl    r9,0x4
  405251:	48 31 c8             	xor    rax,rcx
  405254:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
  405258:	4c 31 c8             	xor    rax,r9
  40525b:	48 31 d0             	xor    rax,rdx
  40525e:	48 31 c8             	xor    rax,rcx
  405261:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
  405268:	00 
  405269:	48 c1 e2 04          	shl    rdx,0x4
  40526d:	48 31 c8             	xor    rax,rcx
  405270:	48 31 d0             	xor    rax,rdx
  405273:	c3                   	ret    
  405274:	89 d1                	mov    ecx,edx
  405276:	e9 43 fc ff ff       	jmp    404ebe <chainhash_v3_evaluate.constprop.0+0xe2e>
  40527b:	85 db                	test   ebx,ebx
  40527d:	0f 85 a0 00 00 00    	jne    405323 <chainhash_v3_evaluate.constprop.0+0x1293>
  405283:	31 f6                	xor    esi,esi
  405285:	31 ff                	xor    edi,edi
  405287:	31 c9                	xor    ecx,ecx
  405289:	4c 89 c8             	mov    rax,r9
  40528c:	4c 89 ca             	mov    rdx,r9
  40528f:	48 d3 e8             	shr    rax,cl
  405292:	48 d3 e2             	shl    rdx,cl
  405295:	83 e0 01             	and    eax,0x1
  405298:	48 f7 d8             	neg    rax
  40529b:	48 21 c2             	and    rdx,rax
  40529e:	48 31 d7             	xor    rdi,rdx
  4052a1:	8d 51 01             	lea    edx,[rcx+0x1]
  4052a4:	85 c9                	test   ecx,ecx
  4052a6:	74 74                	je     40531c <chainhash_v3_evaluate.constprop.0+0x128c>
  4052a8:	44 89 d1             	mov    ecx,r10d
  4052ab:	4d 89 cf             	mov    r15,r9
  4052ae:	29 d1                	sub    ecx,edx
  4052b0:	49 d3 ef             	shr    r15,cl
  4052b3:	4c 21 f8             	and    rax,r15
  4052b6:	48 31 c6             	xor    rsi,rax
  4052b9:	83 fa 40             	cmp    edx,0x40
  4052bc:	75 5e                	jne    40531c <chainhash_v3_evaluate.constprop.0+0x128c>
  4052be:	48 89 f2             	mov    rdx,rsi
  4052c1:	48 89 f0             	mov    rax,rsi
  4052c4:	48 8d 0c 36          	lea    rcx,[rsi+rsi*1]
  4052c8:	48 c1 e8 3d          	shr    rax,0x3d
  4052cc:	48 c1 ea 3f          	shr    rdx,0x3f
  4052d0:	48 31 c2             	xor    rdx,rax
  4052d3:	48 89 f0             	mov    rax,rsi
  4052d6:	48 c1 e8 3c          	shr    rax,0x3c
  4052da:	48 31 c2             	xor    rdx,rax
  4052dd:	48 89 f8             	mov    rax,rdi
  4052e0:	48 31 f0             	xor    rax,rsi
  4052e3:	48 31 c8             	xor    rax,rcx
  4052e6:	48 8d 0c f5 00 00 00 	lea    rcx,[rsi*8+0x0]
  4052ed:	00 
  4052ee:	48 c1 e6 04          	shl    rsi,0x4
  4052f2:	48 31 c8             	xor    rax,rcx
  4052f5:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
  4052f9:	48 31 f0             	xor    rax,rsi
  4052fc:	48 31 d0             	xor    rax,rdx
  4052ff:	48 31 c8             	xor    rax,rcx
  405302:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
  405309:	00 
  40530a:	48 c1 e2 04          	shl    rdx,0x4
  40530e:	48 31 c8             	xor    rax,rcx
  405311:	48 31 d0             	xor    rax,rdx
  405314:	49 89 c1             	mov    r9,rax
  405317:	e9 8a fb ff ff       	jmp    404ea6 <chainhash_v3_evaluate.constprop.0+0xe16>
  40531c:	89 d1                	mov    ecx,edx
  40531e:	e9 66 ff ff ff       	jmp    405289 <chainhash_v3_evaluate.constprop.0+0x11f9>
  405323:	4c 89 ce             	mov    rsi,r9
  405326:	4c 89 cf             	mov    rdi,r9
  405329:	e8 62 cd ff ff       	call   402090 <chv3_hwprod>
  40532e:	48 89 c7             	mov    rdi,rax
  405331:	48 89 d6             	mov    rsi,rdx
  405334:	eb 88                	jmp    4052be <chainhash_v3_evaluate.constprop.0+0x122e>
  405336:	4c 89 ce             	mov    rsi,r9
  405339:	4c 89 c7             	mov    rdi,r8
  40533c:	e8 4f cd ff ff       	call   402090 <chv3_hwprod>
  405341:	48 89 c7             	mov    rdi,rax
  405344:	48 89 d6             	mov    rsi,rdx
  405347:	e9 af fb ff ff       	jmp    404efb <chainhash_v3_evaluate.constprop.0+0xe6b>
  40534c:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
  405351:	48 8b 74 24 28       	mov    rsi,QWORD PTR [rsp+0x28]
  405356:	4c 89 ef             	mov    rdi,r13
  405359:	e8 62 cd ff ff       	call   4020c0 <chv3_region128>
  40535e:	8b 84 24 50 01 00 00 	mov    eax,DWORD PTR [rsp+0x150]
  405365:	89 44 24 10          	mov    DWORD PTR [rsp+0x10],eax
  405369:	e9 9c f0 ff ff       	jmp    40440a <chainhash_v3_evaluate.constprop.0+0x37a>
  40536e:	48 8b 54 24 18       	mov    rdx,QWORD PTR [rsp+0x18]
  405373:	48 8b 74 24 28       	mov    rsi,QWORD PTR [rsp+0x28]
  405378:	4c 89 ef             	mov    rdi,r13
  40537b:	e8 b0 c9 ff ff       	call   401d30 <chv3_region256>
  405380:	e9 85 f0 ff ff       	jmp    40440a <chainhash_v3_evaluate.constprop.0+0x37a>
  405385:	4c 89 d6             	mov    rsi,r10
  405388:	e8 03 cd ff ff       	call   402090 <chv3_hwprod>
  40538d:	48 89 ef             	mov    rdi,rbp
  405390:	4c 89 e6             	mov    rsi,r12
  405393:	49 89 c0             	mov    r8,rax
  405396:	49 89 d1             	mov    r9,rdx
  405399:	e8 f2 cc ff ff       	call   402090 <chv3_hwprod>
  40539e:	48 89 d7             	mov    rdi,rdx
  4053a1:	48 89 c2             	mov    rdx,rax
  4053a4:	e9 06 f6 ff ff       	jmp    4049af <chainhash_v3_evaluate.constprop.0+0x91f>
  4053a9:	4d 8b 8d 08 01 00 00 	mov    r9,QWORD PTR [r13+0x108]
  4053b0:	e9 dc fa ff ff       	jmp    404e91 <chainhash_v3_evaluate.constprop.0+0xe01>
  4053b5:	45 31 e4             	xor    r12d,r12d
  4053b8:	48 83 7c 24 20 00    	cmp    QWORD PTR [rsp+0x20],0x0
  4053be:	c7 44 24 14 01 00 00 	mov    DWORD PTR [rsp+0x14],0x1
  4053c5:	00 
  4053c6:	41 bd 60 b6 40 00    	mov    r13d,0x40b660
  4053cc:	48 c7 44 24 40 04 00 	mov    QWORD PTR [rsp+0x40],0x4
  4053d3:	00 00 
  4053d5:	c7 44 24 08 04 00 00 	mov    DWORD PTR [rsp+0x8],0x4
  4053dc:	00 
  4053dd:	0f 84 c4 f1 ff ff    	je     4045a7 <chainhash_v3_evaluate.constprop.0+0x517>
  4053e3:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
  4053e8:	48 8b 74 24 28       	mov    rsi,QWORD PTR [rsp+0x28]
  4053ed:	48 8d bc 24 60 01 00 	lea    rdi,[rsp+0x160]
  4053f4:	00 
  4053f5:	89 c2                	mov    edx,eax
  4053f7:	83 f8 08             	cmp    eax,0x8
  4053fa:	72 08                	jb     405404 <chainhash_v3_evaluate.constprop.0+0x1374>
  4053fc:	89 c1                	mov    ecx,eax
  4053fe:	c1 e9 03             	shr    ecx,0x3
  405401:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  405404:	31 c0                	xor    eax,eax
  405406:	f6 c2 04             	test   dl,0x4
  405409:	74 09                	je     405414 <chainhash_v3_evaluate.constprop.0+0x1384>
  40540b:	8b 06                	mov    eax,DWORD PTR [rsi]
  40540d:	89 07                	mov    DWORD PTR [rdi],eax
  40540f:	b8 04 00 00 00       	mov    eax,0x4
  405414:	f6 c2 02             	test   dl,0x2
  405417:	74 0c                	je     405425 <chainhash_v3_evaluate.constprop.0+0x1395>
  405419:	0f b7 0c 06          	movzx  ecx,WORD PTR [rsi+rax*1]
  40541d:	66 89 0c 07          	mov    WORD PTR [rdi+rax*1],cx
  405421:	48 83 c0 02          	add    rax,0x2
  405425:	83 e2 01             	and    edx,0x1
  405428:	74 07                	je     405431 <chainhash_v3_evaluate.constprop.0+0x13a1>
  40542a:	0f b6 14 06          	movzx  edx,BYTE PTR [rsi+rax*1]
  40542e:	88 14 07             	mov    BYTE PTR [rdi+rax*1],dl
  405431:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
  405436:	48 89 84 24 58 01 00 	mov    QWORD PTR [rsp+0x158],rax
  40543d:	00 
  40543e:	48 83 f8 30          	cmp    rax,0x30
  405442:	77 36                	ja     40547a <chainhash_v3_evaluate.constprop.0+0x13ea>
  405444:	48 8b 44 24 20       	mov    rax,QWORD PTR [rsp+0x20]
  405449:	48 83 e8 01          	sub    rax,0x1
  40544d:	48 c1 e8 04          	shr    rax,0x4
  405451:	83 c0 01             	add    eax,0x1
  405454:	89 44 24 28          	mov    DWORD PTR [rsp+0x28],eax
  405458:	e9 71 f1 ff ff       	jmp    4045ce <chainhash_v3_evaluate.constprop.0+0x53e>
  40545d:	8b 44 24 08          	mov    eax,DWORD PTR [rsp+0x8]
  405461:	4d 8b 8d 08 01 00 00 	mov    r9,QWORD PTR [r13+0x108]
  405468:	4c 89 64 24 18       	mov    QWORD PTR [rsp+0x18],r12
  40546d:	85 c0                	test   eax,eax
  40546f:	0f 85 72 f8 ff ff    	jne    404ce7 <chainhash_v3_evaluate.constprop.0+0xc57>
  405475:	e9 17 fa ff ff       	jmp    404e91 <chainhash_v3_evaluate.constprop.0+0xe01>
  40547a:	c7 44 24 28 04 00 00 	mov    DWORD PTR [rsp+0x28],0x4
  405481:	00 
  405482:	e9 47 f1 ff ff       	jmp    4045ce <chainhash_v3_evaluate.constprop.0+0x53e>
  405487:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  40548e:	00 00 
  405490:	41 b8 01 00 00 00    	mov    r8d,0x1
  405496:	e9 c2 fa ff ff       	jmp    404f5d <chainhash_v3_evaluate.constprop.0+0xecd>
  40549b:	48 83 7c 24 20 30    	cmp    QWORD PTR [rsp+0x20],0x30
  4054a1:	76 a1                	jbe    405444 <chainhash_v3_evaluate.constprop.0+0x13b4>
  4054a3:	48 81 7c 24 20 00 04 	cmp    QWORD PTR [rsp+0x20],0x400
  4054aa:	00 00 
  4054ac:	75 cc                	jne    40547a <chainhash_v3_evaluate.constprop.0+0x13ea>
  4054ae:	83 7c 24 10 03       	cmp    DWORD PTR [rsp+0x10],0x3
  4054b3:	0f 84 be 00 00 00    	je     405577 <chainhash_v3_evaluate.constprop.0+0x14e7>
  4054b9:	83 7c 24 10 02       	cmp    DWORD PTR [rsp+0x10],0x2
  4054be:	0f 84 88 00 00 00    	je     40554c <chainhash_v3_evaluate.constprop.0+0x14bc>
  4054c4:	83 7c 24 10 01       	cmp    DWORD PTR [rsp+0x10],0x1
  4054c9:	c7 44 24 28 04 00 00 	mov    DWORD PTR [rsp+0x28],0x4
  4054d0:	00 
  4054d1:	0f 85 f7 f0 ff ff    	jne    4045ce <chainhash_v3_evaluate.constprop.0+0x53e>
  4054d7:	48 8d 54 24 70       	lea    rdx,[rsp+0x70]
  4054dc:	48 8d b4 24 60 01 00 	lea    rsi,[rsp+0x160]
  4054e3:	00 
  4054e4:	4c 89 ef             	mov    rdi,r13
  4054e7:	48 89 54 24 18       	mov    QWORD PTR [rsp+0x18],rdx
  4054ec:	e8 cf cb ff ff       	call   4020c0 <chv3_region128>
  4054f1:	8b 9c 24 4c 01 00 00 	mov    ebx,DWORD PTR [rsp+0x14c]
  4054f8:	8b 84 24 48 01 00 00 	mov    eax,DWORD PTR [rsp+0x148]
  4054ff:	4c 8b a4 24 40 01 00 	mov    r12,QWORD PTR [rsp+0x140]
  405506:	00 
  405507:	89 5c 24 14          	mov    DWORD PTR [rsp+0x14],ebx
  40550b:	8b 9c 24 50 01 00 00 	mov    ebx,DWORD PTR [rsp+0x150]
  405512:	89 44 24 08          	mov    DWORD PTR [rsp+0x8],eax
  405516:	48 89 44 24 40       	mov    QWORD PTR [rsp+0x40],rax
  40551b:	89 5c 24 10          	mov    DWORD PTR [rsp+0x10],ebx
  40551f:	e9 8a f3 ff ff       	jmp    4048ae <chainhash_v3_evaluate.constprop.0+0x81e>
  405524:	c7 05 1e 5b 00 00 02 	mov    DWORD PTR [rip+0x5b1e],0x2        # 40b04c <cache.5>
  40552b:	00 00 00 
  40552e:	b8 02 00 00 00       	mov    eax,0x2
  405533:	e9 8e eb ff ff       	jmp    4040c6 <chainhash_v3_evaluate.constprop.0+0x36>
  405538:	c7 05 0a 5b 00 00 01 	mov    DWORD PTR [rip+0x5b0a],0x1        # 40b04c <cache.5>
  40553f:	00 00 00 
  405542:	b8 01 00 00 00       	mov    eax,0x1
  405547:	e9 7a eb ff ff       	jmp    4040c6 <chainhash_v3_evaluate.constprop.0+0x36>
  40554c:	48 8d 54 24 70       	lea    rdx,[rsp+0x70]
  405551:	48 8d b4 24 60 01 00 	lea    rsi,[rsp+0x160]
  405558:	00 
  405559:	4c 89 ef             	mov    rdi,r13
  40555c:	48 89 54 24 18       	mov    QWORD PTR [rsp+0x18],rdx
  405561:	e8 ca c7 ff ff       	call   401d30 <chv3_region256>
  405566:	c7 44 24 28 04 00 00 	mov    DWORD PTR [rsp+0x28],0x4
  40556d:	00 
  40556e:	8b 44 24 08          	mov    eax,DWORD PTR [rsp+0x8]
  405572:	e9 37 f3 ff ff       	jmp    4048ae <chainhash_v3_evaluate.constprop.0+0x81e>
  405577:	48 8d 54 24 70       	lea    rdx,[rsp+0x70]
  40557c:	48 8d b4 24 60 01 00 	lea    rsi,[rsp+0x160]
  405583:	00 
  405584:	4c 89 ef             	mov    rdi,r13
  405587:	48 89 54 24 18       	mov    QWORD PTR [rsp+0x18],rdx
  40558c:	e8 df c5 ff ff       	call   401b70 <chv3_region512>
  405591:	c7 44 24 28 04 00 00 	mov    DWORD PTR [rsp+0x28],0x4
  405598:	00 
  405599:	8b 44 24 08          	mov    eax,DWORD PTR [rsp+0x8]
  40559d:	e9 0c f3 ff ff       	jmp    4048ae <chainhash_v3_evaluate.constprop.0+0x81e>
  4055a2:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  4055a9:	00 00 00 00 
  4055ad:	0f 1f 00             	nop    DWORD PTR [rax]

00000000004055b0 <v3x>:
  4055b0:	41 57                	push   r15
  4055b2:	41 56                	push   r14
  4055b4:	41 55                	push   r13
  4055b6:	41 54                	push   r12
  4055b8:	55                   	push   rbp
  4055b9:	48 89 f5             	mov    rbp,rsi
  4055bc:	53                   	push   rbx
  4055bd:	48 83 ec 68          	sub    rsp,0x68
  4055c1:	8b 05 85 5a 00 00    	mov    eax,DWORD PTR [rip+0x5a85]        # 40b04c <cache.5>
  4055c7:	85 c0                	test   eax,eax
  4055c9:	0f 88 8f 04 00 00    	js     405a5e <v3x+0x4ae>
  4055cf:	83 e0 fb             	and    eax,0xfffffffb
  4055d2:	0f 84 9a 04 00 00    	je     405a72 <v3x+0x4c2>
  4055d8:	48 81 fd ff 03 00 00 	cmp    rbp,0x3ff
  4055df:	0f 87 ab 04 00 00    	ja     405a90 <v3x+0x4e0>
  4055e5:	48 8d 04 2f          	lea    rax,[rdi+rbp*1]
  4055e9:	66 0f ef c0          	pxor   xmm0,xmm0
  4055ed:	4c 8d 7c 24 60       	lea    r15,[rsp+0x60]
  4055f2:	49 89 ee             	mov    r14,rbp
  4055f5:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
  4055fa:	41 bd 60 b6 40 00    	mov    r13d,0x40b660
  405600:	0f 29 44 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm0
  405605:	0f 29 44 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm0
  40560a:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
  40560f:	0f 29 44 24 50       	movaps XMMWORD PTR [rsp+0x50],xmm0
  405614:	48 8b 4c 24 18       	mov    rcx,QWORD PTR [rsp+0x18]
  405619:	49 89 e9             	mov    r9,rbp
  40561c:	4c 8d 44 24 20       	lea    r8,[rsp+0x20]
  405621:	4d 89 f2             	mov    r10,r14
  405624:	4d 29 f1             	sub    r9,r14
  405627:	4d 8d 5e f8          	lea    r11,[r14-0x8]
  40562b:	4d 8d 66 b8          	lea    r12,[r14-0x48]
  40562f:	4c 29 f1             	sub    rcx,r14
  405632:	49 8d 5e c0          	lea    rbx,[r14-0x40]
  405636:	4c 39 cd             	cmp    rbp,r9
  405639:	0f 86 2c 01 00 00    	jbe    40576b <v3x+0x1bb>
  40563f:	49 8d 41 40          	lea    rax,[r9+0x40]
  405643:	48 39 c5             	cmp    rbp,rax
  405646:	0f 86 64 04 00 00    	jbe    405ab0 <v3x+0x500>
  40564c:	0f b6 41 40          	movzx  eax,BYTE PTR [rcx+0x40]
  405650:	48 83 fb 01          	cmp    rbx,0x1
  405654:	74 71                	je     4056c7 <v3x+0x117>
  405656:	0f b6 51 41          	movzx  edx,BYTE PTR [rcx+0x41]
  40565a:	48 c1 e2 08          	shl    rdx,0x8
  40565e:	48 09 d0             	or     rax,rdx
  405661:	48 83 fb 02          	cmp    rbx,0x2
  405665:	74 60                	je     4056c7 <v3x+0x117>
  405667:	0f b6 51 42          	movzx  edx,BYTE PTR [rcx+0x42]
  40566b:	48 c1 e2 10          	shl    rdx,0x10
  40566f:	48 09 d0             	or     rax,rdx
  405672:	48 83 fb 03          	cmp    rbx,0x3
  405676:	74 4f                	je     4056c7 <v3x+0x117>
  405678:	0f b6 51 43          	movzx  edx,BYTE PTR [rcx+0x43]
  40567c:	48 c1 e2 18          	shl    rdx,0x18
  405680:	48 09 d0             	or     rax,rdx
  405683:	48 83 fb 04          	cmp    rbx,0x4
  405687:	74 3e                	je     4056c7 <v3x+0x117>
  405689:	0f b6 51 44          	movzx  edx,BYTE PTR [rcx+0x44]
  40568d:	48 c1 e2 20          	shl    rdx,0x20
  405691:	48 09 d0             	or     rax,rdx
  405694:	48 83 fb 05          	cmp    rbx,0x5
  405698:	74 2d                	je     4056c7 <v3x+0x117>
  40569a:	0f b6 51 45          	movzx  edx,BYTE PTR [rcx+0x45]
  40569e:	48 c1 e2 28          	shl    rdx,0x28
  4056a2:	48 09 d0             	or     rax,rdx
  4056a5:	48 83 fb 06          	cmp    rbx,0x6
  4056a9:	74 1c                	je     4056c7 <v3x+0x117>
  4056ab:	0f b6 51 46          	movzx  edx,BYTE PTR [rcx+0x46]
  4056af:	48 c1 e2 30          	shl    rdx,0x30
  4056b3:	48 09 d0             	or     rax,rdx
  4056b6:	48 83 fb 07          	cmp    rbx,0x7
  4056ba:	74 0b                	je     4056c7 <v3x+0x117>
  4056bc:	0f b6 51 47          	movzx  edx,BYTE PTR [rcx+0x47]
  4056c0:	48 c1 e2 38          	shl    rdx,0x38
  4056c4:	48 09 d0             	or     rax,rdx
  4056c7:	49 33 45 10          	xor    rax,QWORD PTR [r13+0x10]
  4056cb:	48 89 c6             	mov    rsi,rax
  4056ce:	0f b6 01             	movzx  eax,BYTE PTR [rcx]
  4056d1:	49 83 fa 01          	cmp    r10,0x1
  4056d5:	74 71                	je     405748 <v3x+0x198>
  4056d7:	0f b6 51 01          	movzx  edx,BYTE PTR [rcx+0x1]
  4056db:	48 c1 e2 08          	shl    rdx,0x8
  4056df:	48 09 d0             	or     rax,rdx
  4056e2:	49 83 fa 02          	cmp    r10,0x2
  4056e6:	74 60                	je     405748 <v3x+0x198>
  4056e8:	0f b6 51 02          	movzx  edx,BYTE PTR [rcx+0x2]
  4056ec:	48 c1 e2 10          	shl    rdx,0x10
  4056f0:	48 09 d0             	or     rax,rdx
  4056f3:	49 83 fa 03          	cmp    r10,0x3
  4056f7:	74 4f                	je     405748 <v3x+0x198>
  4056f9:	0f b6 51 03          	movzx  edx,BYTE PTR [rcx+0x3]
  4056fd:	48 c1 e2 18          	shl    rdx,0x18
  405701:	48 09 d0             	or     rax,rdx
  405704:	49 83 fa 04          	cmp    r10,0x4
  405708:	74 3e                	je     405748 <v3x+0x198>
  40570a:	0f b6 51 04          	movzx  edx,BYTE PTR [rcx+0x4]
  40570e:	48 c1 e2 20          	shl    rdx,0x20
  405712:	48 09 d0             	or     rax,rdx
  405715:	49 83 fa 05          	cmp    r10,0x5
  405719:	74 2d                	je     405748 <v3x+0x198>
  40571b:	0f b6 51 05          	movzx  edx,BYTE PTR [rcx+0x5]
  40571f:	48 c1 e2 28          	shl    rdx,0x28
  405723:	48 09 d0             	or     rax,rdx
  405726:	49 83 fa 06          	cmp    r10,0x6
  40572a:	74 1c                	je     405748 <v3x+0x198>
  40572c:	0f b6 51 06          	movzx  edx,BYTE PTR [rcx+0x6]
  405730:	48 c1 e2 30          	shl    rdx,0x30
  405734:	48 09 d0             	or     rax,rdx
  405737:	49 83 fa 07          	cmp    r10,0x7
  40573b:	74 0b                	je     405748 <v3x+0x198>
  40573d:	0f b6 51 07          	movzx  edx,BYTE PTR [rcx+0x7]
  405741:	48 c1 e2 38          	shl    rdx,0x38
  405745:	48 09 d0             	or     rax,rdx
  405748:	49 33 45 00          	xor    rax,QWORD PTR [r13+0x0]
  40574c:	48 89 c7             	mov    rdi,rax
  40574f:	e8 3c c9 ff ff       	call   402090 <chv3_hwprod>
  405754:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  405758:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  40575d:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  405762:	66 41 0f ef 00       	pxor   xmm0,XMMWORD PTR [r8]
  405767:	41 0f 29 00          	movaps XMMWORD PTR [r8],xmm0
  40576b:	49 8d 41 08          	lea    rax,[r9+0x8]
  40576f:	48 39 c5             	cmp    rbp,rax
  405772:	0f 86 2b 01 00 00    	jbe    4058a3 <v3x+0x2f3>
  405778:	49 8d 51 48          	lea    rdx,[r9+0x48]
  40577c:	31 c0                	xor    eax,eax
  40577e:	48 39 d5             	cmp    rbp,rdx
  405781:	76 7b                	jbe    4057fe <v3x+0x24e>
  405783:	0f b6 41 48          	movzx  eax,BYTE PTR [rcx+0x48]
  405787:	49 83 fc 01          	cmp    r12,0x1
  40578b:	74 71                	je     4057fe <v3x+0x24e>
  40578d:	0f b6 51 49          	movzx  edx,BYTE PTR [rcx+0x49]
  405791:	48 c1 e2 08          	shl    rdx,0x8
  405795:	48 09 d0             	or     rax,rdx
  405798:	49 83 fc 02          	cmp    r12,0x2
  40579c:	74 60                	je     4057fe <v3x+0x24e>
  40579e:	0f b6 51 4a          	movzx  edx,BYTE PTR [rcx+0x4a]
  4057a2:	48 c1 e2 10          	shl    rdx,0x10
  4057a6:	48 09 d0             	or     rax,rdx
  4057a9:	49 83 fc 03          	cmp    r12,0x3
  4057ad:	74 4f                	je     4057fe <v3x+0x24e>
  4057af:	0f b6 51 4b          	movzx  edx,BYTE PTR [rcx+0x4b]
  4057b3:	48 c1 e2 18          	shl    rdx,0x18
  4057b7:	48 09 d0             	or     rax,rdx
  4057ba:	49 83 fc 04          	cmp    r12,0x4
  4057be:	74 3e                	je     4057fe <v3x+0x24e>
  4057c0:	0f b6 51 4c          	movzx  edx,BYTE PTR [rcx+0x4c]
  4057c4:	48 c1 e2 20          	shl    rdx,0x20
  4057c8:	48 09 d0             	or     rax,rdx
  4057cb:	49 83 fc 05          	cmp    r12,0x5
  4057cf:	74 2d                	je     4057fe <v3x+0x24e>
  4057d1:	0f b6 51 4d          	movzx  edx,BYTE PTR [rcx+0x4d]
  4057d5:	48 c1 e2 28          	shl    rdx,0x28
  4057d9:	48 09 d0             	or     rax,rdx
  4057dc:	49 83 fc 06          	cmp    r12,0x6
  4057e0:	74 1c                	je     4057fe <v3x+0x24e>
  4057e2:	0f b6 51 4e          	movzx  edx,BYTE PTR [rcx+0x4e]
  4057e6:	48 c1 e2 30          	shl    rdx,0x30
  4057ea:	48 09 d0             	or     rax,rdx
  4057ed:	49 83 fc 07          	cmp    r12,0x7
  4057f1:	74 0b                	je     4057fe <v3x+0x24e>
  4057f3:	0f b6 51 4f          	movzx  edx,BYTE PTR [rcx+0x4f]
  4057f7:	48 c1 e2 38          	shl    rdx,0x38
  4057fb:	48 09 d0             	or     rax,rdx
  4057fe:	49 33 45 18          	xor    rax,QWORD PTR [r13+0x18]
  405802:	48 89 c6             	mov    rsi,rax
  405805:	0f b6 41 08          	movzx  eax,BYTE PTR [rcx+0x8]
  405809:	49 83 fb 01          	cmp    r11,0x1
  40580d:	74 71                	je     405880 <v3x+0x2d0>
  40580f:	0f b6 51 09          	movzx  edx,BYTE PTR [rcx+0x9]
  405813:	48 c1 e2 08          	shl    rdx,0x8
  405817:	48 09 d0             	or     rax,rdx
  40581a:	49 83 fb 02          	cmp    r11,0x2
  40581e:	74 60                	je     405880 <v3x+0x2d0>
  405820:	0f b6 51 0a          	movzx  edx,BYTE PTR [rcx+0xa]
  405824:	48 c1 e2 10          	shl    rdx,0x10
  405828:	48 09 d0             	or     rax,rdx
  40582b:	49 83 fb 03          	cmp    r11,0x3
  40582f:	74 4f                	je     405880 <v3x+0x2d0>
  405831:	0f b6 51 0b          	movzx  edx,BYTE PTR [rcx+0xb]
  405835:	48 c1 e2 18          	shl    rdx,0x18
  405839:	48 09 d0             	or     rax,rdx
  40583c:	49 83 fb 04          	cmp    r11,0x4
  405840:	74 3e                	je     405880 <v3x+0x2d0>
  405842:	0f b6 51 0c          	movzx  edx,BYTE PTR [rcx+0xc]
  405846:	48 c1 e2 20          	shl    rdx,0x20
  40584a:	48 09 d0             	or     rax,rdx
  40584d:	49 83 fb 05          	cmp    r11,0x5
  405851:	74 2d                	je     405880 <v3x+0x2d0>
  405853:	0f b6 51 0d          	movzx  edx,BYTE PTR [rcx+0xd]
  405857:	48 c1 e2 28          	shl    rdx,0x28
  40585b:	48 09 d0             	or     rax,rdx
  40585e:	49 83 fb 06          	cmp    r11,0x6
  405862:	74 1c                	je     405880 <v3x+0x2d0>
  405864:	0f b6 51 0e          	movzx  edx,BYTE PTR [rcx+0xe]
  405868:	48 c1 e2 30          	shl    rdx,0x30
  40586c:	48 09 d0             	or     rax,rdx
  40586f:	49 83 fb 07          	cmp    r11,0x7
  405873:	74 0b                	je     405880 <v3x+0x2d0>
  405875:	0f b6 51 0f          	movzx  edx,BYTE PTR [rcx+0xf]
  405879:	48 c1 e2 38          	shl    rdx,0x38
  40587d:	48 09 d0             	or     rax,rdx
  405880:	49 33 45 08          	xor    rax,QWORD PTR [r13+0x8]
  405884:	48 89 c7             	mov    rdi,rax
  405887:	e8 04 c8 ff ff       	call   402090 <chv3_hwprod>
  40588c:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  405890:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  405895:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  40589a:	66 41 0f ef 00       	pxor   xmm0,XMMWORD PTR [r8]
  40589f:	41 0f 29 00          	movaps XMMWORD PTR [r8],xmm0
  4058a3:	49 83 c0 10          	add    r8,0x10
  4058a7:	49 83 c1 10          	add    r9,0x10
  4058ab:	49 83 eb 10          	sub    r11,0x10
  4058af:	49 83 ec 10          	sub    r12,0x10
  4058b3:	48 83 c1 10          	add    rcx,0x10
  4058b7:	49 83 ea 10          	sub    r10,0x10
  4058bb:	48 83 eb 10          	sub    rbx,0x10
  4058bf:	4d 39 c7             	cmp    r15,r8
  4058c2:	0f 85 6e fd ff ff    	jne    405636 <v3x+0x86>
  4058c8:	49 83 c5 20          	add    r13,0x20
  4058cc:	49 83 c6 80          	add    r14,0xffffffffffffff80
  4058d0:	49 81 fd 60 b7 40 00 	cmp    r13,0x40b760
  4058d7:	0f 85 37 fd ff ff    	jne    405614 <v3x+0x64>
  4058dd:	4c 8d 45 ff          	lea    r8,[rbp-0x1]
  4058e1:	49 c1 e8 04          	shr    r8,0x4
  4058e5:	41 83 c0 01          	add    r8d,0x1
  4058e9:	48 83 fd 30          	cmp    rbp,0x30
  4058ed:	0f 87 45 02 00 00    	ja     405b38 <v3x+0x588>
  4058f3:	48 85 ed             	test   rbp,rbp
  4058f6:	0f 84 3c 02 00 00    	je     405b38 <v3x+0x588>
  4058fc:	48 89 e9             	mov    rcx,rbp
  4058ff:	45 85 c0             	test   r8d,r8d
  405902:	0f 85 30 02 00 00    	jne    405b38 <v3x+0x588>
  405908:	48 03 0d 09 5f 00 00 	add    rcx,QWORD PTR [rip+0x5f09]        # 40b818 <v3+0x1b8>
  40590f:	48 89 ce             	mov    rsi,rcx
  405912:	48 89 cf             	mov    rdi,rcx
  405915:	e8 76 c7 ff ff       	call   402090 <chv3_hwprod>
  40591a:	48 89 d6             	mov    rsi,rdx
  40591d:	48 89 d7             	mov    rdi,rdx
  405920:	48 31 d0             	xor    rax,rdx
  405923:	48 c1 ef 3d          	shr    rdi,0x3d
  405927:	48 c1 ee 3f          	shr    rsi,0x3f
  40592b:	48 31 fe             	xor    rsi,rdi
  40592e:	48 89 d7             	mov    rdi,rdx
  405931:	48 c1 ef 3c          	shr    rdi,0x3c
  405935:	48 31 fe             	xor    rsi,rdi
  405938:	48 89 c7             	mov    rdi,rax
  40593b:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  40593f:	48 31 c7             	xor    rdi,rax
  405942:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  405949:	00 
  40594a:	48 c1 e2 04          	shl    rdx,0x4
  40594e:	48 31 c7             	xor    rdi,rax
  405951:	48 8d 04 36          	lea    rax,[rsi+rsi*1]
  405955:	48 31 d7             	xor    rdi,rdx
  405958:	48 31 f7             	xor    rdi,rsi
  40595b:	48 31 c7             	xor    rdi,rax
  40595e:	48 8d 04 f5 00 00 00 	lea    rax,[rsi*8+0x0]
  405965:	00 
  405966:	48 c1 e6 04          	shl    rsi,0x4
  40596a:	48 31 c7             	xor    rdi,rax
  40596d:	48 31 f7             	xor    rdi,rsi
  405970:	48 8b 35 81 5e 00 00 	mov    rsi,QWORD PTR [rip+0x5e81]        # 40b7f8 <v3+0x198>
  405977:	48 31 fe             	xor    rsi,rdi
  40597a:	48 33 3d 6f 5e 00 00 	xor    rdi,QWORD PTR [rip+0x5e6f]        # 40b7f0 <v3+0x190>
  405981:	48 31 ce             	xor    rsi,rcx
  405984:	e8 07 c7 ff ff       	call   402090 <chv3_hwprod>
  405989:	48 89 d7             	mov    rdi,rdx
  40598c:	48 89 d6             	mov    rsi,rdx
  40598f:	48 31 d0             	xor    rax,rdx
  405992:	48 c1 ee 3d          	shr    rsi,0x3d
  405996:	48 c1 ef 3f          	shr    rdi,0x3f
  40599a:	48 31 f7             	xor    rdi,rsi
  40599d:	48 89 d6             	mov    rsi,rdx
  4059a0:	48 c1 ee 3c          	shr    rsi,0x3c
  4059a4:	48 31 f7             	xor    rdi,rsi
  4059a7:	48 8b 35 5a 5e 00 00 	mov    rsi,QWORD PTR [rip+0x5e5a]        # 40b808 <v3+0x1a8>
  4059ae:	48 31 c6             	xor    rsi,rax
  4059b1:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  4059b5:	48 31 c6             	xor    rsi,rax
  4059b8:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  4059bf:	00 
  4059c0:	48 c1 e2 04          	shl    rdx,0x4
  4059c4:	48 31 c6             	xor    rsi,rax
  4059c7:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  4059cb:	48 31 d6             	xor    rsi,rdx
  4059ce:	48 31 fe             	xor    rsi,rdi
  4059d1:	48 31 c6             	xor    rsi,rax
  4059d4:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  4059db:	00 
  4059dc:	48 c1 e7 04          	shl    rdi,0x4
  4059e0:	48 31 c6             	xor    rsi,rax
  4059e3:	48 31 fe             	xor    rsi,rdi
  4059e6:	48 8b 3d 13 5e 00 00 	mov    rdi,QWORD PTR [rip+0x5e13]        # 40b800 <v3+0x1a0>
  4059ed:	48 31 cf             	xor    rdi,rcx
  4059f0:	e8 9b c6 ff ff       	call   402090 <chv3_hwprod>
  4059f5:	48 89 d1             	mov    rcx,rdx
  4059f8:	48 89 d6             	mov    rsi,rdx
  4059fb:	48 31 d0             	xor    rax,rdx
  4059fe:	48 33 05 0b 5e 00 00 	xor    rax,QWORD PTR [rip+0x5e0b]        # 40b810 <v3+0x1b0>
  405a05:	48 c1 ee 3d          	shr    rsi,0x3d
  405a09:	48 c1 e9 3f          	shr    rcx,0x3f
  405a0d:	48 83 c4 68          	add    rsp,0x68
  405a11:	48 31 f1             	xor    rcx,rsi
  405a14:	48 89 d6             	mov    rsi,rdx
  405a17:	5b                   	pop    rbx
  405a18:	5d                   	pop    rbp
  405a19:	48 c1 ee 3c          	shr    rsi,0x3c
  405a1d:	41 5c                	pop    r12
  405a1f:	41 5d                	pop    r13
  405a21:	48 31 f1             	xor    rcx,rsi
  405a24:	48 8d 34 12          	lea    rsi,[rdx+rdx*1]
  405a28:	41 5e                	pop    r14
  405a2a:	41 5f                	pop    r15
  405a2c:	48 31 f0             	xor    rax,rsi
  405a2f:	48 8d 34 d5 00 00 00 	lea    rsi,[rdx*8+0x0]
  405a36:	00 
  405a37:	48 c1 e2 04          	shl    rdx,0x4
  405a3b:	48 31 f0             	xor    rax,rsi
  405a3e:	48 31 d0             	xor    rax,rdx
  405a41:	48 8d 14 09          	lea    rdx,[rcx+rcx*1]
  405a45:	48 31 c8             	xor    rax,rcx
  405a48:	48 31 d0             	xor    rax,rdx
  405a4b:	48 8d 14 cd 00 00 00 	lea    rdx,[rcx*8+0x0]
  405a52:	00 
  405a53:	48 c1 e1 04          	shl    rcx,0x4
  405a57:	48 31 d0             	xor    rax,rdx
  405a5a:	48 31 c8             	xor    rax,rcx
  405a5d:	c3                   	ret    
  405a5e:	31 f6                	xor    esi,esi
  405a60:	89 f0                	mov    eax,esi
  405a62:	0f a2                	cpuid  
  405a64:	85 c0                	test   eax,eax
  405a66:	75 4f                	jne    405ab7 <v3x+0x507>
  405a68:	c7 05 da 55 00 00 00 	mov    DWORD PTR [rip+0x55da],0x0        # 40b04c <cache.5>
  405a6f:	00 00 00 
  405a72:	b9 50 91 40 00       	mov    ecx,0x409150
  405a77:	ba 61 01 00 00       	mov    edx,0x161
  405a7c:	be 10 90 40 00       	mov    esi,0x409010
  405a81:	bf 88 90 40 00       	mov    edi,0x409088
  405a86:	e8 d5 b5 ff ff       	call   401060 <__assert_fail@plt>
  405a8b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  405a90:	48 83 c4 68          	add    rsp,0x68
  405a94:	48 89 ee             	mov    rsi,rbp
  405a97:	ba 01 00 00 00       	mov    edx,0x1
  405a9c:	5b                   	pop    rbx
  405a9d:	5d                   	pop    rbp
  405a9e:	41 5c                	pop    r12
  405aa0:	41 5d                	pop    r13
  405aa2:	41 5e                	pop    r14
  405aa4:	41 5f                	pop    r15
  405aa6:	e9 e5 e5 ff ff       	jmp    404090 <chainhash_v3_evaluate.constprop.0>
  405aab:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  405ab0:	31 c0                	xor    eax,eax
  405ab2:	e9 10 fc ff ff       	jmp    4056c7 <v3x+0x117>
  405ab7:	b8 01 00 00 00       	mov    eax,0x1
  405abc:	0f a2                	cpuid  
  405abe:	81 e1 02 00 00 18    	and    ecx,0x18000002
  405ac4:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
  405aca:	75 9c                	jne    405a68 <v3x+0x4b8>
  405acc:	89 f1                	mov    ecx,esi
  405ace:	0f 01 d0             	xgetbv 
  405ad1:	41 89 c0             	mov    r8d,eax
  405ad4:	83 e0 06             	and    eax,0x6
  405ad7:	83 f8 06             	cmp    eax,0x6
  405ada:	75 8c                	jne    405a68 <v3x+0x4b8>
  405adc:	89 f0                	mov    eax,esi
  405ade:	0f a2                	cpuid  
  405ae0:	83 f8 06             	cmp    eax,0x6
  405ae3:	0f 86 92 03 00 00    	jbe    405e7b <v3x+0x8cb>
  405ae9:	b8 07 00 00 00       	mov    eax,0x7
  405aee:	89 f1                	mov    ecx,esi
  405af0:	0f a2                	cpuid  
  405af2:	f6 c3 20             	test   bl,0x20
  405af5:	0f 84 80 03 00 00    	je     405e7b <v3x+0x8cb>
  405afb:	80 e5 04             	and    ch,0x4
  405afe:	0f 84 77 03 00 00    	je     405e7b <v3x+0x8cb>
  405b04:	41 81 e0 e6 00 00 00 	and    r8d,0xe6
  405b0b:	41 81 f8 e6 00 00 00 	cmp    r8d,0xe6
  405b12:	0f 85 72 03 00 00    	jne    405e8a <v3x+0x8da>
  405b18:	81 e3 00 00 01 00    	and    ebx,0x10000
  405b1e:	0f 84 66 03 00 00    	je     405e8a <v3x+0x8da>
  405b24:	c7 05 1e 55 00 00 03 	mov    DWORD PTR [rip+0x551e],0x3        # 40b04c <cache.5>
  405b2b:	00 00 00 
  405b2e:	e9 a5 fa ff ff       	jmp    4055d8 <v3x+0x28>
  405b33:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  405b38:	48 8b 35 29 5c 00 00 	mov    rsi,QWORD PTR [rip+0x5c29]        # 40b768 <v3+0x108>
  405b3f:	48 89 ef             	mov    rdi,rbp
  405b42:	e8 49 c5 ff ff       	call   402090 <chv3_hwprod>
  405b47:	4c 8b 4c 24 28       	mov    r9,QWORD PTR [rsp+0x28]
  405b4c:	48 89 d7             	mov    rdi,rdx
  405b4f:	49 89 d2             	mov    r10,rdx
  405b52:	48 c1 ea 3f          	shr    rdx,0x3f
  405b56:	48 c1 ef 3d          	shr    rdi,0x3d
  405b5a:	4c 89 c9             	mov    rcx,r9
  405b5d:	4c 31 d0             	xor    rax,r10
  405b60:	48 31 d7             	xor    rdi,rdx
  405b63:	4c 89 d2             	mov    rdx,r10
  405b66:	48 c1 e9 3f          	shr    rcx,0x3f
  405b6a:	48 c1 ea 3c          	shr    rdx,0x3c
  405b6e:	48 31 d7             	xor    rdi,rdx
  405b71:	4c 89 ca             	mov    rdx,r9
  405b74:	48 c1 ea 3d          	shr    rdx,0x3d
  405b78:	48 31 ca             	xor    rdx,rcx
  405b7b:	4c 89 c9             	mov    rcx,r9
  405b7e:	48 c1 e9 3c          	shr    rcx,0x3c
  405b82:	48 31 ca             	xor    rdx,rcx
  405b85:	48 8b 4c 24 20       	mov    rcx,QWORD PTR [rsp+0x20]
  405b8a:	48 31 c1             	xor    rcx,rax
  405b8d:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  405b91:	4c 31 c9             	xor    rcx,r9
  405b94:	48 31 c1             	xor    rcx,rax
  405b97:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  405b9e:	00 
  405b9f:	49 c1 e2 04          	shl    r10,0x4
  405ba3:	48 31 c1             	xor    rcx,rax
  405ba6:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  405baa:	4c 31 d1             	xor    rcx,r10
  405bad:	48 31 c1             	xor    rcx,rax
  405bb0:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  405bb7:	00 
  405bb8:	49 c1 e1 04          	shl    r9,0x4
  405bbc:	48 31 c1             	xor    rcx,rax
  405bbf:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  405bc3:	4c 31 c9             	xor    rcx,r9
  405bc6:	48 31 f9             	xor    rcx,rdi
  405bc9:	48 31 d1             	xor    rcx,rdx
  405bcc:	48 31 c1             	xor    rcx,rax
  405bcf:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  405bd6:	00 
  405bd7:	48 c1 e7 04          	shl    rdi,0x4
  405bdb:	48 31 c1             	xor    rcx,rax
  405bde:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  405be2:	48 31 f9             	xor    rcx,rdi
  405be5:	48 31 c1             	xor    rcx,rax
  405be8:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  405bef:	00 
  405bf0:	48 c1 e2 04          	shl    rdx,0x4
  405bf4:	48 31 c1             	xor    rcx,rax
  405bf7:	48 31 d1             	xor    rcx,rdx
  405bfa:	48 83 fd 30          	cmp    rbp,0x30
  405bfe:	77 13                	ja     405c13 <v3x+0x663>
  405c00:	48 85 ed             	test   rbp,rbp
  405c03:	0f 84 ff fc ff ff    	je     405908 <v3x+0x358>
  405c09:	41 83 f8 01          	cmp    r8d,0x1
  405c0d:	0f 86 f5 fc ff ff    	jbe    405908 <v3x+0x358>
  405c13:	48 89 cf             	mov    rdi,rcx
  405c16:	e8 75 c4 ff ff       	call   402090 <chv3_hwprod>
  405c1b:	4c 8b 4c 24 38       	mov    r9,QWORD PTR [rsp+0x38]
  405c20:	48 89 d7             	mov    rdi,rdx
  405c23:	49 89 d2             	mov    r10,rdx
  405c26:	48 c1 ea 3f          	shr    rdx,0x3f
  405c2a:	48 c1 ef 3d          	shr    rdi,0x3d
  405c2e:	4c 89 c9             	mov    rcx,r9
  405c31:	4c 31 d0             	xor    rax,r10
  405c34:	48 31 d7             	xor    rdi,rdx
  405c37:	4c 89 d2             	mov    rdx,r10
  405c3a:	48 c1 e9 3f          	shr    rcx,0x3f
  405c3e:	48 c1 ea 3c          	shr    rdx,0x3c
  405c42:	48 31 d7             	xor    rdi,rdx
  405c45:	4c 89 ca             	mov    rdx,r9
  405c48:	48 c1 ea 3d          	shr    rdx,0x3d
  405c4c:	48 31 ca             	xor    rdx,rcx
  405c4f:	4c 89 c9             	mov    rcx,r9
  405c52:	48 c1 e9 3c          	shr    rcx,0x3c
  405c56:	48 31 ca             	xor    rdx,rcx
  405c59:	48 8b 4c 24 30       	mov    rcx,QWORD PTR [rsp+0x30]
  405c5e:	48 31 c1             	xor    rcx,rax
  405c61:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  405c65:	4c 31 c9             	xor    rcx,r9
  405c68:	48 31 c1             	xor    rcx,rax
  405c6b:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  405c72:	00 
  405c73:	49 c1 e2 04          	shl    r10,0x4
  405c77:	48 31 c1             	xor    rcx,rax
  405c7a:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  405c7e:	4c 31 d1             	xor    rcx,r10
  405c81:	48 31 c1             	xor    rcx,rax
  405c84:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  405c8b:	00 
  405c8c:	49 c1 e1 04          	shl    r9,0x4
  405c90:	48 31 c1             	xor    rcx,rax
  405c93:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  405c97:	4c 31 c9             	xor    rcx,r9
  405c9a:	48 31 f9             	xor    rcx,rdi
  405c9d:	48 31 d1             	xor    rcx,rdx
  405ca0:	48 31 c1             	xor    rcx,rax
  405ca3:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  405caa:	00 
  405cab:	48 c1 e7 04          	shl    rdi,0x4
  405caf:	48 31 c1             	xor    rcx,rax
  405cb2:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  405cb6:	48 31 f9             	xor    rcx,rdi
  405cb9:	48 31 c1             	xor    rcx,rax
  405cbc:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  405cc3:	00 
  405cc4:	48 c1 e2 04          	shl    rdx,0x4
  405cc8:	48 31 c1             	xor    rcx,rax
  405ccb:	48 31 d1             	xor    rcx,rdx
  405cce:	48 83 fd 30          	cmp    rbp,0x30
  405cd2:	77 13                	ja     405ce7 <v3x+0x737>
  405cd4:	48 85 ed             	test   rbp,rbp
  405cd7:	0f 84 2b fc ff ff    	je     405908 <v3x+0x358>
  405cdd:	41 83 f8 02          	cmp    r8d,0x2
  405ce1:	0f 86 21 fc ff ff    	jbe    405908 <v3x+0x358>
  405ce7:	48 89 cf             	mov    rdi,rcx
  405cea:	e8 a1 c3 ff ff       	call   402090 <chv3_hwprod>
  405cef:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  405cf4:	48 89 d7             	mov    rdi,rdx
  405cf7:	49 89 d2             	mov    r10,rdx
  405cfa:	48 c1 ea 3f          	shr    rdx,0x3f
  405cfe:	48 c1 ef 3d          	shr    rdi,0x3d
  405d02:	4c 89 c9             	mov    rcx,r9
  405d05:	4c 31 d0             	xor    rax,r10
  405d08:	48 31 d7             	xor    rdi,rdx
  405d0b:	4c 89 d2             	mov    rdx,r10
  405d0e:	48 c1 e9 3d          	shr    rcx,0x3d
  405d12:	48 c1 ea 3c          	shr    rdx,0x3c
  405d16:	48 31 d7             	xor    rdi,rdx
  405d19:	4c 89 ca             	mov    rdx,r9
  405d1c:	48 c1 ea 3f          	shr    rdx,0x3f
  405d20:	48 31 ca             	xor    rdx,rcx
  405d23:	4c 89 c9             	mov    rcx,r9
  405d26:	48 c1 e9 3c          	shr    rcx,0x3c
  405d2a:	48 31 ca             	xor    rdx,rcx
  405d2d:	48 8b 4c 24 40       	mov    rcx,QWORD PTR [rsp+0x40]
  405d32:	48 31 c1             	xor    rcx,rax
  405d35:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  405d39:	4c 31 c9             	xor    rcx,r9
  405d3c:	48 31 c1             	xor    rcx,rax
  405d3f:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  405d46:	00 
  405d47:	49 c1 e2 04          	shl    r10,0x4
  405d4b:	48 31 c1             	xor    rcx,rax
  405d4e:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  405d52:	4c 31 d1             	xor    rcx,r10
  405d55:	48 31 c1             	xor    rcx,rax
  405d58:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  405d5f:	00 
  405d60:	49 c1 e1 04          	shl    r9,0x4
  405d64:	48 31 c1             	xor    rcx,rax
  405d67:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  405d6b:	4c 31 c9             	xor    rcx,r9
  405d6e:	48 31 f9             	xor    rcx,rdi
  405d71:	48 31 d1             	xor    rcx,rdx
  405d74:	48 31 c1             	xor    rcx,rax
  405d77:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  405d7e:	00 
  405d7f:	48 c1 e7 04          	shl    rdi,0x4
  405d83:	48 31 c1             	xor    rcx,rax
  405d86:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  405d8a:	48 31 f9             	xor    rcx,rdi
  405d8d:	48 31 c1             	xor    rcx,rax
  405d90:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  405d97:	00 
  405d98:	48 c1 e2 04          	shl    rdx,0x4
  405d9c:	48 31 c1             	xor    rcx,rax
  405d9f:	48 31 d1             	xor    rcx,rdx
  405da2:	48 83 fd 30          	cmp    rbp,0x30
  405da6:	77 13                	ja     405dbb <v3x+0x80b>
  405da8:	48 85 ed             	test   rbp,rbp
  405dab:	0f 84 57 fb ff ff    	je     405908 <v3x+0x358>
  405db1:	41 83 f8 03          	cmp    r8d,0x3
  405db5:	0f 86 4d fb ff ff    	jbe    405908 <v3x+0x358>
  405dbb:	48 89 cf             	mov    rdi,rcx
  405dbe:	e8 cd c2 ff ff       	call   402090 <chv3_hwprod>
  405dc3:	48 8b 7c 24 58       	mov    rdi,QWORD PTR [rsp+0x58]
  405dc8:	48 89 d6             	mov    rsi,rdx
  405dcb:	49 89 d2             	mov    r10,rdx
  405dce:	48 c1 ea 3d          	shr    rdx,0x3d
  405dd2:	48 c1 ee 3f          	shr    rsi,0x3f
  405dd6:	48 89 f9             	mov    rcx,rdi
  405dd9:	4c 31 d0             	xor    rax,r10
  405ddc:	48 31 d6             	xor    rsi,rdx
  405ddf:	4c 89 d2             	mov    rdx,r10
  405de2:	48 c1 e9 3d          	shr    rcx,0x3d
  405de6:	48 c1 ea 3c          	shr    rdx,0x3c
  405dea:	48 31 d6             	xor    rsi,rdx
  405ded:	48 89 fa             	mov    rdx,rdi
  405df0:	48 c1 ea 3f          	shr    rdx,0x3f
  405df4:	48 31 ca             	xor    rdx,rcx
  405df7:	48 89 f9             	mov    rcx,rdi
  405dfa:	48 c1 e9 3c          	shr    rcx,0x3c
  405dfe:	48 31 ca             	xor    rdx,rcx
  405e01:	48 8b 4c 24 50       	mov    rcx,QWORD PTR [rsp+0x50]
  405e06:	48 31 c1             	xor    rcx,rax
  405e09:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  405e0d:	48 31 f9             	xor    rcx,rdi
  405e10:	48 31 c1             	xor    rcx,rax
  405e13:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  405e1a:	00 
  405e1b:	49 c1 e2 04          	shl    r10,0x4
  405e1f:	48 31 c1             	xor    rcx,rax
  405e22:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  405e26:	4c 31 d1             	xor    rcx,r10
  405e29:	48 31 c1             	xor    rcx,rax
  405e2c:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  405e33:	00 
  405e34:	48 c1 e7 04          	shl    rdi,0x4
  405e38:	48 31 c1             	xor    rcx,rax
  405e3b:	48 8d 04 36          	lea    rax,[rsi+rsi*1]
  405e3f:	48 31 f9             	xor    rcx,rdi
  405e42:	48 31 f1             	xor    rcx,rsi
  405e45:	48 31 d1             	xor    rcx,rdx
  405e48:	48 31 c1             	xor    rcx,rax
  405e4b:	48 8d 04 f5 00 00 00 	lea    rax,[rsi*8+0x0]
  405e52:	00 
  405e53:	48 c1 e6 04          	shl    rsi,0x4
  405e57:	48 31 c1             	xor    rcx,rax
  405e5a:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  405e5e:	48 31 f1             	xor    rcx,rsi
  405e61:	48 31 c1             	xor    rcx,rax
  405e64:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  405e6b:	00 
  405e6c:	48 c1 e2 04          	shl    rdx,0x4
  405e70:	48 31 c1             	xor    rcx,rax
  405e73:	48 31 d1             	xor    rcx,rdx
  405e76:	e9 8d fa ff ff       	jmp    405908 <v3x+0x358>
  405e7b:	c7 05 c7 51 00 00 01 	mov    DWORD PTR [rip+0x51c7],0x1        # 40b04c <cache.5>
  405e82:	00 00 00 
  405e85:	e9 4e f7 ff ff       	jmp    4055d8 <v3x+0x28>
  405e8a:	c7 05 b8 51 00 00 02 	mov    DWORD PTR [rip+0x51b8],0x2        # 40b04c <cache.5>
  405e91:	00 00 00 
  405e94:	e9 3f f7 ff ff       	jmp    4055d8 <v3x+0x28>
  405e99:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000405ea0 <v3y>:
  405ea0:	41 57                	push   r15
  405ea2:	41 56                	push   r14
  405ea4:	41 55                	push   r13
  405ea6:	41 54                	push   r12
  405ea8:	55                   	push   rbp
  405ea9:	48 89 f5             	mov    rbp,rsi
  405eac:	53                   	push   rbx
  405ead:	48 83 ec 68          	sub    rsp,0x68
  405eb1:	8b 05 95 51 00 00    	mov    eax,DWORD PTR [rip+0x5195]        # 40b04c <cache.5>
  405eb7:	85 c0                	test   eax,eax
  405eb9:	78 2e                	js     405ee9 <v3y+0x49>
  405ebb:	83 f8 04             	cmp    eax,0x4
  405ebe:	74 41                	je     405f01 <v3y+0x61>
  405ec0:	83 f8 01             	cmp    eax,0x1
  405ec3:	7e 3c                	jle    405f01 <v3y+0x61>
  405ec5:	48 81 fd ff 03 00 00 	cmp    rbp,0x3ff
  405ecc:	76 52                	jbe    405f20 <v3y+0x80>
  405ece:	48 83 c4 68          	add    rsp,0x68
  405ed2:	48 89 ee             	mov    rsi,rbp
  405ed5:	ba 02 00 00 00       	mov    edx,0x2
  405eda:	5b                   	pop    rbx
  405edb:	5d                   	pop    rbp
  405edc:	41 5c                	pop    r12
  405ede:	41 5d                	pop    r13
  405ee0:	41 5e                	pop    r14
  405ee2:	41 5f                	pop    r15
  405ee4:	e9 a7 e1 ff ff       	jmp    404090 <chainhash_v3_evaluate.constprop.0>
  405ee9:	31 f6                	xor    esi,esi
  405eeb:	89 f0                	mov    eax,esi
  405eed:	0f a2                	cpuid  
  405eef:	85 c0                	test   eax,eax
  405ef1:	0f 85 b0 04 00 00    	jne    4063a7 <v3y+0x507>
  405ef7:	c7 05 4b 51 00 00 00 	mov    DWORD PTR [rip+0x514b],0x0        # 40b04c <cache.5>
  405efe:	00 00 00 
  405f01:	b9 50 91 40 00       	mov    ecx,0x409150
  405f06:	ba 61 01 00 00       	mov    edx,0x161
  405f0b:	be 10 90 40 00       	mov    esi,0x409010
  405f10:	bf 88 90 40 00       	mov    edi,0x409088
  405f15:	e8 46 b1 ff ff       	call   401060 <__assert_fail@plt>
  405f1a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  405f20:	48 8d 04 2f          	lea    rax,[rdi+rbp*1]
  405f24:	66 0f ef c0          	pxor   xmm0,xmm0
  405f28:	4c 8d 7c 24 60       	lea    r15,[rsp+0x60]
  405f2d:	49 89 ee             	mov    r14,rbp
  405f30:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
  405f35:	41 bd 60 b6 40 00    	mov    r13d,0x40b660
  405f3b:	0f 29 44 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm0
  405f40:	0f 29 44 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm0
  405f45:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
  405f4a:	0f 29 44 24 50       	movaps XMMWORD PTR [rsp+0x50],xmm0
  405f4f:	48 8b 4c 24 18       	mov    rcx,QWORD PTR [rsp+0x18]
  405f54:	49 89 e9             	mov    r9,rbp
  405f57:	4c 8d 44 24 20       	lea    r8,[rsp+0x20]
  405f5c:	4d 89 f2             	mov    r10,r14
  405f5f:	4d 29 f1             	sub    r9,r14
  405f62:	4d 8d 5e f8          	lea    r11,[r14-0x8]
  405f66:	4d 8d 66 b8          	lea    r12,[r14-0x48]
  405f6a:	4c 29 f1             	sub    rcx,r14
  405f6d:	49 8d 5e c0          	lea    rbx,[r14-0x40]
  405f71:	4c 39 cd             	cmp    rbp,r9
  405f74:	0f 86 2c 01 00 00    	jbe    4060a6 <v3y+0x206>
  405f7a:	49 8d 41 40          	lea    rax,[r9+0x40]
  405f7e:	48 39 c5             	cmp    rbp,rax
  405f81:	0f 86 19 04 00 00    	jbe    4063a0 <v3y+0x500>
  405f87:	0f b6 41 40          	movzx  eax,BYTE PTR [rcx+0x40]
  405f8b:	48 83 fb 01          	cmp    rbx,0x1
  405f8f:	74 71                	je     406002 <v3y+0x162>
  405f91:	0f b6 51 41          	movzx  edx,BYTE PTR [rcx+0x41]
  405f95:	48 c1 e2 08          	shl    rdx,0x8
  405f99:	48 09 d0             	or     rax,rdx
  405f9c:	48 83 fb 02          	cmp    rbx,0x2
  405fa0:	74 60                	je     406002 <v3y+0x162>
  405fa2:	0f b6 51 42          	movzx  edx,BYTE PTR [rcx+0x42]
  405fa6:	48 c1 e2 10          	shl    rdx,0x10
  405faa:	48 09 d0             	or     rax,rdx
  405fad:	48 83 fb 03          	cmp    rbx,0x3
  405fb1:	74 4f                	je     406002 <v3y+0x162>
  405fb3:	0f b6 51 43          	movzx  edx,BYTE PTR [rcx+0x43]
  405fb7:	48 c1 e2 18          	shl    rdx,0x18
  405fbb:	48 09 d0             	or     rax,rdx
  405fbe:	48 83 fb 04          	cmp    rbx,0x4
  405fc2:	74 3e                	je     406002 <v3y+0x162>
  405fc4:	0f b6 51 44          	movzx  edx,BYTE PTR [rcx+0x44]
  405fc8:	48 c1 e2 20          	shl    rdx,0x20
  405fcc:	48 09 d0             	or     rax,rdx
  405fcf:	48 83 fb 05          	cmp    rbx,0x5
  405fd3:	74 2d                	je     406002 <v3y+0x162>
  405fd5:	0f b6 51 45          	movzx  edx,BYTE PTR [rcx+0x45]
  405fd9:	48 c1 e2 28          	shl    rdx,0x28
  405fdd:	48 09 d0             	or     rax,rdx
  405fe0:	48 83 fb 06          	cmp    rbx,0x6
  405fe4:	74 1c                	je     406002 <v3y+0x162>
  405fe6:	0f b6 51 46          	movzx  edx,BYTE PTR [rcx+0x46]
  405fea:	48 c1 e2 30          	shl    rdx,0x30
  405fee:	48 09 d0             	or     rax,rdx
  405ff1:	48 83 fb 07          	cmp    rbx,0x7
  405ff5:	74 0b                	je     406002 <v3y+0x162>
  405ff7:	0f b6 51 47          	movzx  edx,BYTE PTR [rcx+0x47]
  405ffb:	48 c1 e2 38          	shl    rdx,0x38
  405fff:	48 09 d0             	or     rax,rdx
  406002:	49 33 45 10          	xor    rax,QWORD PTR [r13+0x10]
  406006:	48 89 c6             	mov    rsi,rax
  406009:	0f b6 01             	movzx  eax,BYTE PTR [rcx]
  40600c:	49 83 fa 01          	cmp    r10,0x1
  406010:	74 71                	je     406083 <v3y+0x1e3>
  406012:	0f b6 51 01          	movzx  edx,BYTE PTR [rcx+0x1]
  406016:	48 c1 e2 08          	shl    rdx,0x8
  40601a:	48 09 d0             	or     rax,rdx
  40601d:	49 83 fa 02          	cmp    r10,0x2
  406021:	74 60                	je     406083 <v3y+0x1e3>
  406023:	0f b6 51 02          	movzx  edx,BYTE PTR [rcx+0x2]
  406027:	48 c1 e2 10          	shl    rdx,0x10
  40602b:	48 09 d0             	or     rax,rdx
  40602e:	49 83 fa 03          	cmp    r10,0x3
  406032:	74 4f                	je     406083 <v3y+0x1e3>
  406034:	0f b6 51 03          	movzx  edx,BYTE PTR [rcx+0x3]
  406038:	48 c1 e2 18          	shl    rdx,0x18
  40603c:	48 09 d0             	or     rax,rdx
  40603f:	49 83 fa 04          	cmp    r10,0x4
  406043:	74 3e                	je     406083 <v3y+0x1e3>
  406045:	0f b6 51 04          	movzx  edx,BYTE PTR [rcx+0x4]
  406049:	48 c1 e2 20          	shl    rdx,0x20
  40604d:	48 09 d0             	or     rax,rdx
  406050:	49 83 fa 05          	cmp    r10,0x5
  406054:	74 2d                	je     406083 <v3y+0x1e3>
  406056:	0f b6 51 05          	movzx  edx,BYTE PTR [rcx+0x5]
  40605a:	48 c1 e2 28          	shl    rdx,0x28
  40605e:	48 09 d0             	or     rax,rdx
  406061:	49 83 fa 06          	cmp    r10,0x6
  406065:	74 1c                	je     406083 <v3y+0x1e3>
  406067:	0f b6 51 06          	movzx  edx,BYTE PTR [rcx+0x6]
  40606b:	48 c1 e2 30          	shl    rdx,0x30
  40606f:	48 09 d0             	or     rax,rdx
  406072:	49 83 fa 07          	cmp    r10,0x7
  406076:	74 0b                	je     406083 <v3y+0x1e3>
  406078:	0f b6 51 07          	movzx  edx,BYTE PTR [rcx+0x7]
  40607c:	48 c1 e2 38          	shl    rdx,0x38
  406080:	48 09 d0             	or     rax,rdx
  406083:	49 33 45 00          	xor    rax,QWORD PTR [r13+0x0]
  406087:	48 89 c7             	mov    rdi,rax
  40608a:	e8 01 c0 ff ff       	call   402090 <chv3_hwprod>
  40608f:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  406093:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  406098:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  40609d:	66 41 0f ef 00       	pxor   xmm0,XMMWORD PTR [r8]
  4060a2:	41 0f 29 00          	movaps XMMWORD PTR [r8],xmm0
  4060a6:	49 8d 41 08          	lea    rax,[r9+0x8]
  4060aa:	48 39 c5             	cmp    rbp,rax
  4060ad:	0f 86 2b 01 00 00    	jbe    4061de <v3y+0x33e>
  4060b3:	49 8d 51 48          	lea    rdx,[r9+0x48]
  4060b7:	31 c0                	xor    eax,eax
  4060b9:	48 39 d5             	cmp    rbp,rdx
  4060bc:	76 7b                	jbe    406139 <v3y+0x299>
  4060be:	0f b6 41 48          	movzx  eax,BYTE PTR [rcx+0x48]
  4060c2:	49 83 fc 01          	cmp    r12,0x1
  4060c6:	74 71                	je     406139 <v3y+0x299>
  4060c8:	0f b6 51 49          	movzx  edx,BYTE PTR [rcx+0x49]
  4060cc:	48 c1 e2 08          	shl    rdx,0x8
  4060d0:	48 09 d0             	or     rax,rdx
  4060d3:	49 83 fc 02          	cmp    r12,0x2
  4060d7:	74 60                	je     406139 <v3y+0x299>
  4060d9:	0f b6 51 4a          	movzx  edx,BYTE PTR [rcx+0x4a]
  4060dd:	48 c1 e2 10          	shl    rdx,0x10
  4060e1:	48 09 d0             	or     rax,rdx
  4060e4:	49 83 fc 03          	cmp    r12,0x3
  4060e8:	74 4f                	je     406139 <v3y+0x299>
  4060ea:	0f b6 51 4b          	movzx  edx,BYTE PTR [rcx+0x4b]
  4060ee:	48 c1 e2 18          	shl    rdx,0x18
  4060f2:	48 09 d0             	or     rax,rdx
  4060f5:	49 83 fc 04          	cmp    r12,0x4
  4060f9:	74 3e                	je     406139 <v3y+0x299>
  4060fb:	0f b6 51 4c          	movzx  edx,BYTE PTR [rcx+0x4c]
  4060ff:	48 c1 e2 20          	shl    rdx,0x20
  406103:	48 09 d0             	or     rax,rdx
  406106:	49 83 fc 05          	cmp    r12,0x5
  40610a:	74 2d                	je     406139 <v3y+0x299>
  40610c:	0f b6 51 4d          	movzx  edx,BYTE PTR [rcx+0x4d]
  406110:	48 c1 e2 28          	shl    rdx,0x28
  406114:	48 09 d0             	or     rax,rdx
  406117:	49 83 fc 06          	cmp    r12,0x6
  40611b:	74 1c                	je     406139 <v3y+0x299>
  40611d:	0f b6 51 4e          	movzx  edx,BYTE PTR [rcx+0x4e]
  406121:	48 c1 e2 30          	shl    rdx,0x30
  406125:	48 09 d0             	or     rax,rdx
  406128:	49 83 fc 07          	cmp    r12,0x7
  40612c:	74 0b                	je     406139 <v3y+0x299>
  40612e:	0f b6 51 4f          	movzx  edx,BYTE PTR [rcx+0x4f]
  406132:	48 c1 e2 38          	shl    rdx,0x38
  406136:	48 09 d0             	or     rax,rdx
  406139:	49 33 45 18          	xor    rax,QWORD PTR [r13+0x18]
  40613d:	48 89 c6             	mov    rsi,rax
  406140:	0f b6 41 08          	movzx  eax,BYTE PTR [rcx+0x8]
  406144:	49 83 fb 01          	cmp    r11,0x1
  406148:	74 71                	je     4061bb <v3y+0x31b>
  40614a:	0f b6 51 09          	movzx  edx,BYTE PTR [rcx+0x9]
  40614e:	48 c1 e2 08          	shl    rdx,0x8
  406152:	48 09 d0             	or     rax,rdx
  406155:	49 83 fb 02          	cmp    r11,0x2
  406159:	74 60                	je     4061bb <v3y+0x31b>
  40615b:	0f b6 51 0a          	movzx  edx,BYTE PTR [rcx+0xa]
  40615f:	48 c1 e2 10          	shl    rdx,0x10
  406163:	48 09 d0             	or     rax,rdx
  406166:	49 83 fb 03          	cmp    r11,0x3
  40616a:	74 4f                	je     4061bb <v3y+0x31b>
  40616c:	0f b6 51 0b          	movzx  edx,BYTE PTR [rcx+0xb]
  406170:	48 c1 e2 18          	shl    rdx,0x18
  406174:	48 09 d0             	or     rax,rdx
  406177:	49 83 fb 04          	cmp    r11,0x4
  40617b:	74 3e                	je     4061bb <v3y+0x31b>
  40617d:	0f b6 51 0c          	movzx  edx,BYTE PTR [rcx+0xc]
  406181:	48 c1 e2 20          	shl    rdx,0x20
  406185:	48 09 d0             	or     rax,rdx
  406188:	49 83 fb 05          	cmp    r11,0x5
  40618c:	74 2d                	je     4061bb <v3y+0x31b>
  40618e:	0f b6 51 0d          	movzx  edx,BYTE PTR [rcx+0xd]
  406192:	48 c1 e2 28          	shl    rdx,0x28
  406196:	48 09 d0             	or     rax,rdx
  406199:	49 83 fb 06          	cmp    r11,0x6
  40619d:	74 1c                	je     4061bb <v3y+0x31b>
  40619f:	0f b6 51 0e          	movzx  edx,BYTE PTR [rcx+0xe]
  4061a3:	48 c1 e2 30          	shl    rdx,0x30
  4061a7:	48 09 d0             	or     rax,rdx
  4061aa:	49 83 fb 07          	cmp    r11,0x7
  4061ae:	74 0b                	je     4061bb <v3y+0x31b>
  4061b0:	0f b6 51 0f          	movzx  edx,BYTE PTR [rcx+0xf]
  4061b4:	48 c1 e2 38          	shl    rdx,0x38
  4061b8:	48 09 d0             	or     rax,rdx
  4061bb:	49 33 45 08          	xor    rax,QWORD PTR [r13+0x8]
  4061bf:	48 89 c7             	mov    rdi,rax
  4061c2:	e8 c9 be ff ff       	call   402090 <chv3_hwprod>
  4061c7:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  4061cb:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  4061d0:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  4061d5:	66 41 0f ef 00       	pxor   xmm0,XMMWORD PTR [r8]
  4061da:	41 0f 29 00          	movaps XMMWORD PTR [r8],xmm0
  4061de:	49 83 c0 10          	add    r8,0x10
  4061e2:	49 83 c1 10          	add    r9,0x10
  4061e6:	49 83 eb 10          	sub    r11,0x10
  4061ea:	49 83 ec 10          	sub    r12,0x10
  4061ee:	48 83 c1 10          	add    rcx,0x10
  4061f2:	49 83 ea 10          	sub    r10,0x10
  4061f6:	48 83 eb 10          	sub    rbx,0x10
  4061fa:	4d 39 c7             	cmp    r15,r8
  4061fd:	0f 85 6e fd ff ff    	jne    405f71 <v3y+0xd1>
  406203:	49 83 c5 20          	add    r13,0x20
  406207:	49 83 c6 80          	add    r14,0xffffffffffffff80
  40620b:	49 81 fd 60 b7 40 00 	cmp    r13,0x40b760
  406212:	0f 85 37 fd ff ff    	jne    405f4f <v3y+0xaf>
  406218:	4c 8d 45 ff          	lea    r8,[rbp-0x1]
  40621c:	49 c1 e8 04          	shr    r8,0x4
  406220:	41 83 c0 01          	add    r8d,0x1
  406224:	48 83 fd 30          	cmp    rbp,0x30
  406228:	0f 87 02 02 00 00    	ja     406430 <v3y+0x590>
  40622e:	48 85 ed             	test   rbp,rbp
  406231:	0f 84 f9 01 00 00    	je     406430 <v3y+0x590>
  406237:	48 89 e9             	mov    rcx,rbp
  40623a:	45 85 c0             	test   r8d,r8d
  40623d:	0f 85 ed 01 00 00    	jne    406430 <v3y+0x590>
  406243:	48 03 0d ce 55 00 00 	add    rcx,QWORD PTR [rip+0x55ce]        # 40b818 <v3+0x1b8>
  40624a:	48 89 ce             	mov    rsi,rcx
  40624d:	48 89 cf             	mov    rdi,rcx
  406250:	e8 3b be ff ff       	call   402090 <chv3_hwprod>
  406255:	48 89 d6             	mov    rsi,rdx
  406258:	48 89 d7             	mov    rdi,rdx
  40625b:	48 31 d0             	xor    rax,rdx
  40625e:	48 c1 ef 3d          	shr    rdi,0x3d
  406262:	48 c1 ee 3f          	shr    rsi,0x3f
  406266:	48 31 fe             	xor    rsi,rdi
  406269:	48 89 d7             	mov    rdi,rdx
  40626c:	48 c1 ef 3c          	shr    rdi,0x3c
  406270:	48 31 fe             	xor    rsi,rdi
  406273:	48 89 c7             	mov    rdi,rax
  406276:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  40627a:	48 31 c7             	xor    rdi,rax
  40627d:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  406284:	00 
  406285:	48 c1 e2 04          	shl    rdx,0x4
  406289:	48 31 c7             	xor    rdi,rax
  40628c:	48 8d 04 36          	lea    rax,[rsi+rsi*1]
  406290:	48 31 d7             	xor    rdi,rdx
  406293:	48 31 f7             	xor    rdi,rsi
  406296:	48 31 c7             	xor    rdi,rax
  406299:	48 8d 04 f5 00 00 00 	lea    rax,[rsi*8+0x0]
  4062a0:	00 
  4062a1:	48 c1 e6 04          	shl    rsi,0x4
  4062a5:	48 31 c7             	xor    rdi,rax
  4062a8:	48 31 f7             	xor    rdi,rsi
  4062ab:	48 8b 35 46 55 00 00 	mov    rsi,QWORD PTR [rip+0x5546]        # 40b7f8 <v3+0x198>
  4062b2:	48 31 fe             	xor    rsi,rdi
  4062b5:	48 33 3d 34 55 00 00 	xor    rdi,QWORD PTR [rip+0x5534]        # 40b7f0 <v3+0x190>
  4062bc:	48 31 ce             	xor    rsi,rcx
  4062bf:	e8 cc bd ff ff       	call   402090 <chv3_hwprod>
  4062c4:	48 89 d7             	mov    rdi,rdx
  4062c7:	48 89 d6             	mov    rsi,rdx
  4062ca:	48 31 d0             	xor    rax,rdx
  4062cd:	48 c1 ee 3d          	shr    rsi,0x3d
  4062d1:	48 c1 ef 3f          	shr    rdi,0x3f
  4062d5:	48 31 f7             	xor    rdi,rsi
  4062d8:	48 89 d6             	mov    rsi,rdx
  4062db:	48 c1 ee 3c          	shr    rsi,0x3c
  4062df:	48 31 f7             	xor    rdi,rsi
  4062e2:	48 8b 35 1f 55 00 00 	mov    rsi,QWORD PTR [rip+0x551f]        # 40b808 <v3+0x1a8>
  4062e9:	48 31 c6             	xor    rsi,rax
  4062ec:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  4062f0:	48 31 c6             	xor    rsi,rax
  4062f3:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  4062fa:	00 
  4062fb:	48 c1 e2 04          	shl    rdx,0x4
  4062ff:	48 31 c6             	xor    rsi,rax
  406302:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  406306:	48 31 d6             	xor    rsi,rdx
  406309:	48 31 fe             	xor    rsi,rdi
  40630c:	48 31 c6             	xor    rsi,rax
  40630f:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  406316:	00 
  406317:	48 c1 e7 04          	shl    rdi,0x4
  40631b:	48 31 c6             	xor    rsi,rax
  40631e:	48 31 fe             	xor    rsi,rdi
  406321:	48 8b 3d d8 54 00 00 	mov    rdi,QWORD PTR [rip+0x54d8]        # 40b800 <v3+0x1a0>
  406328:	48 31 cf             	xor    rdi,rcx
  40632b:	e8 60 bd ff ff       	call   402090 <chv3_hwprod>
  406330:	48 89 d1             	mov    rcx,rdx
  406333:	48 89 d6             	mov    rsi,rdx
  406336:	48 31 d0             	xor    rax,rdx
  406339:	48 33 05 d0 54 00 00 	xor    rax,QWORD PTR [rip+0x54d0]        # 40b810 <v3+0x1b0>
  406340:	48 c1 ee 3d          	shr    rsi,0x3d
  406344:	48 c1 e9 3f          	shr    rcx,0x3f
  406348:	48 83 c4 68          	add    rsp,0x68
  40634c:	48 31 f1             	xor    rcx,rsi
  40634f:	48 89 d6             	mov    rsi,rdx
  406352:	5b                   	pop    rbx
  406353:	5d                   	pop    rbp
  406354:	48 c1 ee 3c          	shr    rsi,0x3c
  406358:	41 5c                	pop    r12
  40635a:	41 5d                	pop    r13
  40635c:	48 31 f1             	xor    rcx,rsi
  40635f:	48 8d 34 12          	lea    rsi,[rdx+rdx*1]
  406363:	41 5e                	pop    r14
  406365:	41 5f                	pop    r15
  406367:	48 31 f0             	xor    rax,rsi
  40636a:	48 8d 34 d5 00 00 00 	lea    rsi,[rdx*8+0x0]
  406371:	00 
  406372:	48 c1 e2 04          	shl    rdx,0x4
  406376:	48 31 f0             	xor    rax,rsi
  406379:	48 31 d0             	xor    rax,rdx
  40637c:	48 8d 14 09          	lea    rdx,[rcx+rcx*1]
  406380:	48 31 c8             	xor    rax,rcx
  406383:	48 31 d0             	xor    rax,rdx
  406386:	48 8d 14 cd 00 00 00 	lea    rdx,[rcx*8+0x0]
  40638d:	00 
  40638e:	48 c1 e1 04          	shl    rcx,0x4
  406392:	48 31 d0             	xor    rax,rdx
  406395:	48 31 c8             	xor    rax,rcx
  406398:	c3                   	ret    
  406399:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  4063a0:	31 c0                	xor    eax,eax
  4063a2:	e9 5b fc ff ff       	jmp    406002 <v3y+0x162>
  4063a7:	b8 01 00 00 00       	mov    eax,0x1
  4063ac:	0f a2                	cpuid  
  4063ae:	81 e1 02 00 00 18    	and    ecx,0x18000002
  4063b4:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
  4063ba:	0f 85 37 fb ff ff    	jne    405ef7 <v3y+0x57>
  4063c0:	89 f1                	mov    ecx,esi
  4063c2:	0f 01 d0             	xgetbv 
  4063c5:	41 89 c0             	mov    r8d,eax
  4063c8:	83 e0 06             	and    eax,0x6
  4063cb:	83 f8 06             	cmp    eax,0x6
  4063ce:	0f 85 23 fb ff ff    	jne    405ef7 <v3y+0x57>
  4063d4:	89 f0                	mov    eax,esi
  4063d6:	0f a2                	cpuid  
  4063d8:	83 f8 06             	cmp    eax,0x6
  4063db:	0f 86 92 03 00 00    	jbe    406773 <v3y+0x8d3>
  4063e1:	b8 07 00 00 00       	mov    eax,0x7
  4063e6:	89 f1                	mov    ecx,esi
  4063e8:	0f a2                	cpuid  
  4063ea:	f6 c3 20             	test   bl,0x20
  4063ed:	0f 84 80 03 00 00    	je     406773 <v3y+0x8d3>
  4063f3:	80 e5 04             	and    ch,0x4
  4063f6:	0f 84 77 03 00 00    	je     406773 <v3y+0x8d3>
  4063fc:	41 81 e0 e6 00 00 00 	and    r8d,0xe6
  406403:	41 81 f8 e6 00 00 00 	cmp    r8d,0xe6
  40640a:	0f 85 72 03 00 00    	jne    406782 <v3y+0x8e2>
  406410:	81 e3 00 00 01 00    	and    ebx,0x10000
  406416:	0f 84 66 03 00 00    	je     406782 <v3y+0x8e2>
  40641c:	c7 05 26 4c 00 00 03 	mov    DWORD PTR [rip+0x4c26],0x3        # 40b04c <cache.5>
  406423:	00 00 00 
  406426:	e9 9a fa ff ff       	jmp    405ec5 <v3y+0x25>
  40642b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  406430:	48 8b 35 31 53 00 00 	mov    rsi,QWORD PTR [rip+0x5331]        # 40b768 <v3+0x108>
  406437:	48 89 ef             	mov    rdi,rbp
  40643a:	e8 51 bc ff ff       	call   402090 <chv3_hwprod>
  40643f:	4c 8b 4c 24 28       	mov    r9,QWORD PTR [rsp+0x28]
  406444:	48 89 d7             	mov    rdi,rdx
  406447:	49 89 d2             	mov    r10,rdx
  40644a:	48 c1 ea 3f          	shr    rdx,0x3f
  40644e:	48 c1 ef 3d          	shr    rdi,0x3d
  406452:	4c 89 c9             	mov    rcx,r9
  406455:	4c 31 d0             	xor    rax,r10
  406458:	48 31 d7             	xor    rdi,rdx
  40645b:	4c 89 d2             	mov    rdx,r10
  40645e:	48 c1 e9 3f          	shr    rcx,0x3f
  406462:	48 c1 ea 3c          	shr    rdx,0x3c
  406466:	48 31 d7             	xor    rdi,rdx
  406469:	4c 89 ca             	mov    rdx,r9
  40646c:	48 c1 ea 3d          	shr    rdx,0x3d
  406470:	48 31 ca             	xor    rdx,rcx
  406473:	4c 89 c9             	mov    rcx,r9
  406476:	48 c1 e9 3c          	shr    rcx,0x3c
  40647a:	48 31 ca             	xor    rdx,rcx
  40647d:	48 8b 4c 24 20       	mov    rcx,QWORD PTR [rsp+0x20]
  406482:	48 31 c1             	xor    rcx,rax
  406485:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  406489:	4c 31 c9             	xor    rcx,r9
  40648c:	48 31 c1             	xor    rcx,rax
  40648f:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  406496:	00 
  406497:	49 c1 e2 04          	shl    r10,0x4
  40649b:	48 31 c1             	xor    rcx,rax
  40649e:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  4064a2:	4c 31 d1             	xor    rcx,r10
  4064a5:	48 31 c1             	xor    rcx,rax
  4064a8:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  4064af:	00 
  4064b0:	49 c1 e1 04          	shl    r9,0x4
  4064b4:	48 31 c1             	xor    rcx,rax
  4064b7:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  4064bb:	4c 31 c9             	xor    rcx,r9
  4064be:	48 31 f9             	xor    rcx,rdi
  4064c1:	48 31 d1             	xor    rcx,rdx
  4064c4:	48 31 c1             	xor    rcx,rax
  4064c7:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  4064ce:	00 
  4064cf:	48 c1 e7 04          	shl    rdi,0x4
  4064d3:	48 31 c1             	xor    rcx,rax
  4064d6:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  4064da:	48 31 f9             	xor    rcx,rdi
  4064dd:	48 31 c1             	xor    rcx,rax
  4064e0:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  4064e7:	00 
  4064e8:	48 c1 e2 04          	shl    rdx,0x4
  4064ec:	48 31 c1             	xor    rcx,rax
  4064ef:	48 31 d1             	xor    rcx,rdx
  4064f2:	48 83 fd 30          	cmp    rbp,0x30
  4064f6:	77 13                	ja     40650b <v3y+0x66b>
  4064f8:	48 85 ed             	test   rbp,rbp
  4064fb:	0f 84 42 fd ff ff    	je     406243 <v3y+0x3a3>
  406501:	41 83 f8 01          	cmp    r8d,0x1
  406505:	0f 86 38 fd ff ff    	jbe    406243 <v3y+0x3a3>
  40650b:	48 89 cf             	mov    rdi,rcx
  40650e:	e8 7d bb ff ff       	call   402090 <chv3_hwprod>
  406513:	4c 8b 4c 24 38       	mov    r9,QWORD PTR [rsp+0x38]
  406518:	48 89 d7             	mov    rdi,rdx
  40651b:	49 89 d2             	mov    r10,rdx
  40651e:	48 c1 ea 3f          	shr    rdx,0x3f
  406522:	48 c1 ef 3d          	shr    rdi,0x3d
  406526:	4c 89 c9             	mov    rcx,r9
  406529:	4c 31 d0             	xor    rax,r10
  40652c:	48 31 d7             	xor    rdi,rdx
  40652f:	4c 89 d2             	mov    rdx,r10
  406532:	48 c1 e9 3f          	shr    rcx,0x3f
  406536:	48 c1 ea 3c          	shr    rdx,0x3c
  40653a:	48 31 d7             	xor    rdi,rdx
  40653d:	4c 89 ca             	mov    rdx,r9
  406540:	48 c1 ea 3d          	shr    rdx,0x3d
  406544:	48 31 ca             	xor    rdx,rcx
  406547:	4c 89 c9             	mov    rcx,r9
  40654a:	48 c1 e9 3c          	shr    rcx,0x3c
  40654e:	48 31 ca             	xor    rdx,rcx
  406551:	48 8b 4c 24 30       	mov    rcx,QWORD PTR [rsp+0x30]
  406556:	48 31 c1             	xor    rcx,rax
  406559:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  40655d:	4c 31 c9             	xor    rcx,r9
  406560:	48 31 c1             	xor    rcx,rax
  406563:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  40656a:	00 
  40656b:	49 c1 e2 04          	shl    r10,0x4
  40656f:	48 31 c1             	xor    rcx,rax
  406572:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  406576:	4c 31 d1             	xor    rcx,r10
  406579:	48 31 c1             	xor    rcx,rax
  40657c:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  406583:	00 
  406584:	49 c1 e1 04          	shl    r9,0x4
  406588:	48 31 c1             	xor    rcx,rax
  40658b:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  40658f:	4c 31 c9             	xor    rcx,r9
  406592:	48 31 f9             	xor    rcx,rdi
  406595:	48 31 d1             	xor    rcx,rdx
  406598:	48 31 c1             	xor    rcx,rax
  40659b:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  4065a2:	00 
  4065a3:	48 c1 e7 04          	shl    rdi,0x4
  4065a7:	48 31 c1             	xor    rcx,rax
  4065aa:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  4065ae:	48 31 f9             	xor    rcx,rdi
  4065b1:	48 31 c1             	xor    rcx,rax
  4065b4:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  4065bb:	00 
  4065bc:	48 c1 e2 04          	shl    rdx,0x4
  4065c0:	48 31 c1             	xor    rcx,rax
  4065c3:	48 31 d1             	xor    rcx,rdx
  4065c6:	48 83 fd 30          	cmp    rbp,0x30
  4065ca:	77 13                	ja     4065df <v3y+0x73f>
  4065cc:	48 85 ed             	test   rbp,rbp
  4065cf:	0f 84 6e fc ff ff    	je     406243 <v3y+0x3a3>
  4065d5:	41 83 f8 02          	cmp    r8d,0x2
  4065d9:	0f 86 64 fc ff ff    	jbe    406243 <v3y+0x3a3>
  4065df:	48 89 cf             	mov    rdi,rcx
  4065e2:	e8 a9 ba ff ff       	call   402090 <chv3_hwprod>
  4065e7:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  4065ec:	48 89 d7             	mov    rdi,rdx
  4065ef:	49 89 d2             	mov    r10,rdx
  4065f2:	48 c1 ea 3f          	shr    rdx,0x3f
  4065f6:	48 c1 ef 3d          	shr    rdi,0x3d
  4065fa:	4c 89 c9             	mov    rcx,r9
  4065fd:	4c 31 d0             	xor    rax,r10
  406600:	48 31 d7             	xor    rdi,rdx
  406603:	4c 89 d2             	mov    rdx,r10
  406606:	48 c1 e9 3d          	shr    rcx,0x3d
  40660a:	48 c1 ea 3c          	shr    rdx,0x3c
  40660e:	48 31 d7             	xor    rdi,rdx
  406611:	4c 89 ca             	mov    rdx,r9
  406614:	48 c1 ea 3f          	shr    rdx,0x3f
  406618:	48 31 ca             	xor    rdx,rcx
  40661b:	4c 89 c9             	mov    rcx,r9
  40661e:	48 c1 e9 3c          	shr    rcx,0x3c
  406622:	48 31 ca             	xor    rdx,rcx
  406625:	48 8b 4c 24 40       	mov    rcx,QWORD PTR [rsp+0x40]
  40662a:	48 31 c1             	xor    rcx,rax
  40662d:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  406631:	4c 31 c9             	xor    rcx,r9
  406634:	48 31 c1             	xor    rcx,rax
  406637:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  40663e:	00 
  40663f:	49 c1 e2 04          	shl    r10,0x4
  406643:	48 31 c1             	xor    rcx,rax
  406646:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  40664a:	4c 31 d1             	xor    rcx,r10
  40664d:	48 31 c1             	xor    rcx,rax
  406650:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  406657:	00 
  406658:	49 c1 e1 04          	shl    r9,0x4
  40665c:	48 31 c1             	xor    rcx,rax
  40665f:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  406663:	4c 31 c9             	xor    rcx,r9
  406666:	48 31 f9             	xor    rcx,rdi
  406669:	48 31 d1             	xor    rcx,rdx
  40666c:	48 31 c1             	xor    rcx,rax
  40666f:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  406676:	00 
  406677:	48 c1 e7 04          	shl    rdi,0x4
  40667b:	48 31 c1             	xor    rcx,rax
  40667e:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  406682:	48 31 f9             	xor    rcx,rdi
  406685:	48 31 c1             	xor    rcx,rax
  406688:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  40668f:	00 
  406690:	48 c1 e2 04          	shl    rdx,0x4
  406694:	48 31 c1             	xor    rcx,rax
  406697:	48 31 d1             	xor    rcx,rdx
  40669a:	48 83 fd 30          	cmp    rbp,0x30
  40669e:	77 13                	ja     4066b3 <v3y+0x813>
  4066a0:	48 85 ed             	test   rbp,rbp
  4066a3:	0f 84 9a fb ff ff    	je     406243 <v3y+0x3a3>
  4066a9:	41 83 f8 03          	cmp    r8d,0x3
  4066ad:	0f 86 90 fb ff ff    	jbe    406243 <v3y+0x3a3>
  4066b3:	48 89 cf             	mov    rdi,rcx
  4066b6:	e8 d5 b9 ff ff       	call   402090 <chv3_hwprod>
  4066bb:	48 8b 7c 24 58       	mov    rdi,QWORD PTR [rsp+0x58]
  4066c0:	48 89 d6             	mov    rsi,rdx
  4066c3:	49 89 d2             	mov    r10,rdx
  4066c6:	48 c1 ea 3d          	shr    rdx,0x3d
  4066ca:	48 c1 ee 3f          	shr    rsi,0x3f
  4066ce:	48 89 f9             	mov    rcx,rdi
  4066d1:	4c 31 d0             	xor    rax,r10
  4066d4:	48 31 d6             	xor    rsi,rdx
  4066d7:	4c 89 d2             	mov    rdx,r10
  4066da:	48 c1 e9 3d          	shr    rcx,0x3d
  4066de:	48 c1 ea 3c          	shr    rdx,0x3c
  4066e2:	48 31 d6             	xor    rsi,rdx
  4066e5:	48 89 fa             	mov    rdx,rdi
  4066e8:	48 c1 ea 3f          	shr    rdx,0x3f
  4066ec:	48 31 ca             	xor    rdx,rcx
  4066ef:	48 89 f9             	mov    rcx,rdi
  4066f2:	48 c1 e9 3c          	shr    rcx,0x3c
  4066f6:	48 31 ca             	xor    rdx,rcx
  4066f9:	48 8b 4c 24 50       	mov    rcx,QWORD PTR [rsp+0x50]
  4066fe:	48 31 c1             	xor    rcx,rax
  406701:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  406705:	48 31 f9             	xor    rcx,rdi
  406708:	48 31 c1             	xor    rcx,rax
  40670b:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  406712:	00 
  406713:	49 c1 e2 04          	shl    r10,0x4
  406717:	48 31 c1             	xor    rcx,rax
  40671a:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  40671e:	4c 31 d1             	xor    rcx,r10
  406721:	48 31 c1             	xor    rcx,rax
  406724:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  40672b:	00 
  40672c:	48 c1 e7 04          	shl    rdi,0x4
  406730:	48 31 c1             	xor    rcx,rax
  406733:	48 8d 04 36          	lea    rax,[rsi+rsi*1]
  406737:	48 31 f9             	xor    rcx,rdi
  40673a:	48 31 f1             	xor    rcx,rsi
  40673d:	48 31 d1             	xor    rcx,rdx
  406740:	48 31 c1             	xor    rcx,rax
  406743:	48 8d 04 f5 00 00 00 	lea    rax,[rsi*8+0x0]
  40674a:	00 
  40674b:	48 c1 e6 04          	shl    rsi,0x4
  40674f:	48 31 c1             	xor    rcx,rax
  406752:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  406756:	48 31 f1             	xor    rcx,rsi
  406759:	48 31 c1             	xor    rcx,rax
  40675c:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  406763:	00 
  406764:	48 c1 e2 04          	shl    rdx,0x4
  406768:	48 31 c1             	xor    rcx,rax
  40676b:	48 31 d1             	xor    rcx,rdx
  40676e:	e9 d0 fa ff ff       	jmp    406243 <v3y+0x3a3>
  406773:	c7 05 cf 48 00 00 01 	mov    DWORD PTR [rip+0x48cf],0x1        # 40b04c <cache.5>
  40677a:	00 00 00 
  40677d:	e9 7f f7 ff ff       	jmp    405f01 <v3y+0x61>
  406782:	c7 05 c0 48 00 00 02 	mov    DWORD PTR [rip+0x48c0],0x2        # 40b04c <cache.5>
  406789:	00 00 00 
  40678c:	e9 34 f7 ff ff       	jmp    405ec5 <v3y+0x25>
  406791:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  406798:	00 00 00 00 
  40679c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

00000000004067a0 <chainhash_wide256.constprop.0>:
  4067a0:	55                   	push   rbp
  4067a1:	48 8d 56 ff          	lea    rdx,[rsi-0x1]
  4067a5:	49 89 d0             	mov    r8,rdx
  4067a8:	49 c1 e8 08          	shr    r8,0x8
  4067ac:	48 89 e5             	mov    rbp,rsp
  4067af:	41 55                	push   r13
  4067b1:	41 54                	push   r12
  4067b3:	53                   	push   rbx
  4067b4:	48 89 f3             	mov    rbx,rsi
  4067b7:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
  4067bb:	48 81 ec c0 00 00 00 	sub    rsp,0xc0
  4067c2:	4c 8b 25 d7 49 00 00 	mov    r12,QWORD PTR [rip+0x49d7]        # 40b1a0 <shipped+0x100>
  4067c9:	48 8b 05 e0 49 00 00 	mov    rax,QWORD PTR [rip+0x49e0]        # 40b1b0 <shipped+0x110>
  4067d0:	c5 f9 6f 35 c8 49 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x49c8]        # 40b1a0 <shipped+0x100>
  4067d7:	00 
  4067d8:	4c 31 e0             	xor    rax,r12
  4067db:	c5 f9 7f b4 24 90 00 	vmovdqa XMMWORD PTR [rsp+0x90],xmm6
  4067e2:	00 00 
  4067e4:	c4 e1 f9 6e c8       	vmovq  xmm1,rax
  4067e9:	48 81 fa ff 00 00 00 	cmp    rdx,0xff
  4067f0:	0f 87 2a 01 00 00    	ja     406920 <chainhash_wide256.constprop.0+0x180>
  4067f6:	c5 f9 6f 25 72 29 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x2972]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  4067fd:	00 
  4067fe:	c5 f9 6f 35 7a 29 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x297a]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  406805:	00 
  406806:	30 d2                	xor    dl,dl
  406808:	48 89 de             	mov    rsi,rbx
  40680b:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  40680f:	c5 f9 7f a4 24 80 00 	vmovdqa XMMWORD PTR [rsp+0x80],xmm4
  406816:	00 00 
  406818:	c5 f9 7f 74 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm6
  40681e:	48 29 d6             	sub    rsi,rdx
  406821:	0f 84 95 03 00 00    	je     406bbc <chainhash_wide256.constprop.0+0x41c>
  406827:	49 c1 e0 08          	shl    r8,0x8
  40682b:	4a 8d 0c 07          	lea    rcx,[rdi+r8*1]
  40682f:	48 81 fe ff 00 00 00 	cmp    rsi,0xff
  406836:	0f 87 89 04 00 00    	ja     406cc5 <chainhash_wide256.constprop.0+0x525>
  40683c:	48 83 fe 3f          	cmp    rsi,0x3f
  406840:	0f 86 34 06 00 00    	jbe    406e7a <chainhash_wide256.constprop.0+0x6da>
  406846:	c5 d1 ef ed          	vpxor  xmm5,xmm5,xmm5
  40684a:	b8 40 00 00 00       	mov    eax,0x40
  40684f:	c5 f9 6f e5          	vmovdqa xmm4,xmm5
  406853:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  406858:	c5 fa 6f 74 01 c0    	vmovdqu xmm6,XMMWORD PTR [rcx+rax*1-0x40]
  40685e:	c5 c9 ef 80 60 b0 40 	vpxor  xmm0,xmm6,XMMWORD PTR [rax+0x40b060]
  406865:	00 
  406866:	49 89 c5             	mov    r13,rax
  406869:	c5 fa 6f 74 01 d0    	vmovdqu xmm6,XMMWORD PTR [rcx+rax*1-0x30]
  40686f:	c5 c9 ef 90 70 b0 40 	vpxor  xmm2,xmm6,XMMWORD PTR [rax+0x40b070]
  406876:	00 
  406877:	c5 fa 6f 74 01 e0    	vmovdqu xmm6,XMMWORD PTR [rcx+rax*1-0x20]
  40687d:	c4 e3 79 44 da 11    	vpclmulhqhqdq xmm3,xmm0,xmm2
  406883:	c4 e3 79 44 d2 00    	vpclmullqlqdq xmm2,xmm0,xmm2
  406889:	c5 c9 ef 80 80 b0 40 	vpxor  xmm0,xmm6,XMMWORD PTR [rax+0x40b080]
  406890:	00 
  406891:	c5 fa 6f 74 01 f0    	vmovdqu xmm6,XMMWORD PTR [rcx+rax*1-0x10]
  406897:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  40689b:	c5 c9 ef 98 90 b0 40 	vpxor  xmm3,xmm6,XMMWORD PTR [rax+0x40b090]
  4068a2:	00 
  4068a3:	48 8d 40 40          	lea    rax,[rax+0x40]
  4068a7:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  4068ab:	c4 e3 79 44 f3 11    	vpclmulhqhqdq xmm6,xmm0,xmm3
  4068b1:	c4 e3 79 44 c3 00    	vpclmullqlqdq xmm0,xmm0,xmm3
  4068b7:	c5 f9 6f e2          	vmovdqa xmm4,xmm2
  4068bb:	c5 f9 ef c6          	vpxor  xmm0,xmm0,xmm6
  4068bf:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  4068c3:	c5 f9 6f e8          	vmovdqa xmm5,xmm0
  4068c7:	48 39 c6             	cmp    rsi,rax
  4068ca:	73 8c                	jae    406858 <chainhash_wide256.constprop.0+0xb8>
  4068cc:	49 8d 45 20          	lea    rax,[r13+0x20]
  4068d0:	48 39 c6             	cmp    rsi,rax
  4068d3:	72 36                	jb     40690b <chainhash_wide256.constprop.0+0x16b>
  4068d5:	4a 8d 14 29          	lea    rdx,[rcx+r13*1]
  4068d9:	c5 fa 6f 22          	vmovdqu xmm4,XMMWORD PTR [rdx]
  4068dd:	c4 c1 59 ef 9d a0 b0 	vpxor  xmm3,xmm4,XMMWORD PTR [r13+0x40b0a0]
  4068e4:	40 00 
  4068e6:	c5 fa 6f 62 10       	vmovdqu xmm4,XMMWORD PTR [rdx+0x10]
  4068eb:	c4 c1 59 ef a5 b0 b0 	vpxor  xmm4,xmm4,XMMWORD PTR [r13+0x40b0b0]
  4068f2:	40 00 
  4068f4:	49 89 c5             	mov    r13,rax
  4068f7:	c4 e3 61 44 ec 11    	vpclmulhqhqdq xmm5,xmm3,xmm4
  4068fd:	c4 e3 61 44 dc 00    	vpclmullqlqdq xmm3,xmm3,xmm4
  406903:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  406907:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  40690b:	4c 39 ee             	cmp    rsi,r13
  40690e:	0f 87 b3 04 00 00    	ja     406dc7 <chainhash_wide256.constprop.0+0x627>
  406914:	c5 f8 77             	vzeroupper 
  406917:	c5 e9 ef d8          	vpxor  xmm3,xmm2,xmm0
  40691b:	e9 9f 02 00 00       	jmp    406bbf <chainhash_wide256.constprop.0+0x41f>
  406920:	c5 7d 6f 35 78 47 00 	vmovdqa ymm14,YMMWORD PTR [rip+0x4778]        # 40b0a0 <shipped>
  406927:	00 
  406928:	c5 7d 6f 2d 90 47 00 	vmovdqa ymm13,YMMWORD PTR [rip+0x4790]        # 40b0c0 <shipped+0x20>
  40692f:	00 
  406930:	c5 8d ef 07          	vpxor  ymm0,ymm14,YMMWORD PTR [rdi]
  406934:	c5 95 ef 57 20       	vpxor  ymm2,ymm13,YMMWORD PTR [rdi+0x20]
  406939:	c5 7d 6f 25 9f 47 00 	vmovdqa ymm12,YMMWORD PTR [rip+0x479f]        # 40b0e0 <shipped+0x40>
  406940:	00 
  406941:	c5 7d 6f 1d b7 47 00 	vmovdqa ymm11,YMMWORD PTR [rip+0x47b7]        # 40b100 <shipped+0x60>
  406948:	00 
  406949:	c4 e3 7d 46 e2 20    	vperm2i128 ymm4,ymm0,ymm2,0x20
  40694f:	c4 e3 7d 46 c2 31    	vperm2i128 ymm0,ymm0,ymm2,0x31
  406955:	c5 9d ef 57 40       	vpxor  ymm2,ymm12,YMMWORD PTR [rdi+0x40]
  40695a:	c5 fd 6f 3d de 47 00 	vmovdqa ymm7,YMMWORD PTR [rip+0x47de]        # 40b140 <shipped+0xa0>
  406961:	00 
  406962:	c4 e3 5d 44 f0 11    	vpclmulhqhqdq ymm6,ymm4,ymm0
  406968:	c5 7d 6f 15 b0 47 00 	vmovdqa ymm10,YMMWORD PTR [rip+0x47b0]        # 40b120 <shipped+0x80>
  40696f:	00 
  406970:	c4 e3 5d 44 e0 00    	vpclmullqlqdq ymm4,ymm4,ymm0
  406976:	c5 a5 ef 47 60       	vpxor  ymm0,ymm11,YMMWORD PTR [rdi+0x60]
  40697b:	c5 fd 7f 3c 24       	vmovdqa YMMWORD PTR [rsp],ymm7
  406980:	c5 c5 ef bf a0 00 00 	vpxor  ymm7,ymm7,YMMWORD PTR [rdi+0xa0]
  406987:	00 
  406988:	c4 e3 6d 46 e8 20    	vperm2i128 ymm5,ymm2,ymm0,0x20
  40698e:	c4 e3 6d 46 d0 31    	vperm2i128 ymm2,ymm2,ymm0,0x31
  406994:	c4 e3 55 44 c2 11    	vpclmulhqhqdq ymm0,ymm5,ymm2
  40699a:	c4 e3 55 44 ea 00    	vpclmullqlqdq ymm5,ymm5,ymm2
  4069a0:	c5 ad ef 97 80 00 00 	vpxor  ymm2,ymm10,YMMWORD PTR [rdi+0x80]
  4069a7:	00 
  4069a8:	c4 e3 6d 46 df 20    	vperm2i128 ymm3,ymm2,ymm7,0x20
  4069ae:	c4 e3 6d 46 d7 31    	vperm2i128 ymm2,ymm2,ymm7,0x31
  4069b4:	c5 fd 6f 3d a4 47 00 	vmovdqa ymm7,YMMWORD PTR [rip+0x47a4]        # 40b160 <shipped+0xc0>
  4069bb:	00 
  4069bc:	c5 cd ef f4          	vpxor  ymm6,ymm6,ymm4
  4069c0:	c4 63 65 44 c2 11    	vpclmulhqhqdq ymm8,ymm3,ymm2
  4069c6:	c4 63 65 44 ca 00    	vpclmullqlqdq ymm9,ymm3,ymm2
  4069cc:	c5 fd 7f 7c 24 40    	vmovdqa YMMWORD PTR [rsp+0x40],ymm7
  4069d2:	c5 c5 ef 9f c0 00 00 	vpxor  ymm3,ymm7,YMMWORD PTR [rdi+0xc0]
  4069d9:	00 
  4069da:	c5 fd 6f 3d 9e 47 00 	vmovdqa ymm7,YMMWORD PTR [rip+0x479e]        # 40b180 <shipped+0xe0>
  4069e1:	00 
  4069e2:	c5 fd 7f 7c 24 20    	vmovdqa YMMWORD PTR [rsp+0x20],ymm7
  4069e8:	c5 c5 ef bf e0 00 00 	vpxor  ymm7,ymm7,YMMWORD PTR [rdi+0xe0]
  4069ef:	00 
  4069f0:	c5 fd ef c5          	vpxor  ymm0,ymm0,ymm5
  4069f4:	c5 fd ef c6          	vpxor  ymm0,ymm0,ymm6
  4069f8:	c4 e3 65 46 d7 20    	vperm2i128 ymm2,ymm3,ymm7,0x20
  4069fe:	c4 e3 65 46 df 31    	vperm2i128 ymm3,ymm3,ymm7,0x31
  406a04:	c4 e3 6d 44 fb 11    	vpclmulhqhqdq ymm7,ymm2,ymm3
  406a0a:	c4 e3 6d 44 d3 00    	vpclmullqlqdq ymm2,ymm2,ymm3
  406a10:	c4 41 3d ef c1       	vpxor  ymm8,ymm8,ymm9
  406a15:	c4 c1 7d ef c0       	vpxor  ymm0,ymm0,ymm8
  406a1a:	c5 ed ef d7          	vpxor  ymm2,ymm2,ymm7
  406a1e:	c5 fd ef d2          	vpxor  ymm2,ymm0,ymm2
  406a22:	c4 e3 7d 39 d0 01    	vextracti128 xmm0,ymm2,0x1
  406a28:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  406a2c:	c5 f9 ef 84 24 90 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rsp+0x90]
  406a33:	00 00 
  406a35:	49 83 f8 01          	cmp    r8,0x1
  406a39:	0f 86 17 04 00 00    	jbe    406e56 <chainhash_wide256.constprop.0+0x6b6>
  406a3f:	c5 f9 6f 35 29 27 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x2729]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  406a46:	00 
  406a47:	c5 f9 6f 25 31 27 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x2731]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  406a4e:	00 
  406a4f:	4c 89 c1             	mov    rcx,r8
  406a52:	48 8d 87 00 01 00 00 	lea    rax,[rdi+0x100]
  406a59:	48 c1 e1 08          	shl    rcx,0x8
  406a5d:	48 01 f9             	add    rcx,rdi
  406a60:	c5 f9 7f 64 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm4
  406a66:	c5 f9 7f b4 24 80 00 	vmovdqa XMMWORD PTR [rsp+0x80],xmm6
  406a6d:	00 00 
  406a6f:	90                   	nop
  406a70:	c5 95 ef 50 20       	vpxor  ymm2,ymm13,YMMWORD PTR [rax+0x20]
  406a75:	c4 e3 79 44 c9 01    	vpclmulhqlqdq xmm1,xmm0,xmm1
  406a7b:	c5 f9 6f f0          	vmovdqa xmm6,xmm0
  406a7f:	c5 fd 6f 3c 24       	vmovdqa ymm7,YMMWORD PTR [rsp]
  406a84:	c5 8d ef 00          	vpxor  ymm0,ymm14,YMMWORD PTR [rax]
  406a88:	c5 a5 ef 58 60       	vpxor  ymm3,ymm11,YMMWORD PTR [rax+0x60]
  406a8d:	48 05 00 01 00 00    	add    rax,0x100
  406a93:	c5 c5 ef 68 a0       	vpxor  ymm5,ymm7,YMMWORD PTR [rax-0x60]
  406a98:	c4 e3 7d 46 e2 20    	vperm2i128 ymm4,ymm0,ymm2,0x20
  406a9e:	c4 e3 7d 46 c2 31    	vperm2i128 ymm0,ymm0,ymm2,0x31
  406aa4:	c4 63 5d 44 c0 11    	vpclmulhqhqdq ymm8,ymm4,ymm0
  406aaa:	c4 e3 5d 44 e0 00    	vpclmullqlqdq ymm4,ymm4,ymm0
  406ab0:	c5 9d ef 80 40 ff ff 	vpxor  ymm0,ymm12,YMMWORD PTR [rax-0xc0]
  406ab7:	ff 
  406ab8:	c4 e3 7d 46 d3 20    	vperm2i128 ymm2,ymm0,ymm3,0x20
  406abe:	c4 e3 7d 46 c3 31    	vperm2i128 ymm0,ymm0,ymm3,0x31
  406ac4:	c5 ad ef 58 80       	vpxor  ymm3,ymm10,YMMWORD PTR [rax-0x80]
  406ac9:	c4 63 6d 44 c8 11    	vpclmulhqhqdq ymm9,ymm2,ymm0
  406acf:	c4 e3 6d 44 d0 00    	vpclmullqlqdq ymm2,ymm2,ymm0
  406ad5:	c4 e3 65 46 c5 20    	vperm2i128 ymm0,ymm3,ymm5,0x20
  406adb:	c4 e3 65 46 dd 31    	vperm2i128 ymm3,ymm3,ymm5,0x31
  406ae1:	c5 fd 6f 6c 24 40    	vmovdqa ymm5,YMMWORD PTR [rsp+0x40]
  406ae7:	c4 e3 7d 44 fb 11    	vpclmulhqhqdq ymm7,ymm0,ymm3
  406aed:	c5 d5 ef 68 c0       	vpxor  ymm5,ymm5,YMMWORD PTR [rax-0x40]
  406af2:	c4 e3 7d 44 c3 00    	vpclmullqlqdq ymm0,ymm0,ymm3
  406af8:	c5 fd 6f 5c 24 20    	vmovdqa ymm3,YMMWORD PTR [rsp+0x20]
  406afe:	c5 65 ef 78 e0       	vpxor  ymm15,ymm3,YMMWORD PTR [rax-0x20]
  406b03:	c4 c1 5d ef e0       	vpxor  ymm4,ymm4,ymm8
  406b08:	c4 c3 55 46 df 20    	vperm2i128 ymm3,ymm5,ymm15,0x20
  406b0e:	c4 c3 55 46 ef 31    	vperm2i128 ymm5,ymm5,ymm15,0x31
  406b14:	c4 63 65 44 fd 11    	vpclmulhqhqdq ymm15,ymm3,ymm5
  406b1a:	c4 e3 65 44 dd 00    	vpclmullqlqdq ymm3,ymm3,ymm5
  406b20:	c4 c1 6d ef d1       	vpxor  ymm2,ymm2,ymm9
  406b25:	c5 ed ef d4          	vpxor  ymm2,ymm2,ymm4
  406b29:	c5 fd ef c7          	vpxor  ymm0,ymm0,ymm7
  406b2d:	c5 f9 6f 7c 24 70    	vmovdqa xmm7,XMMWORD PTR [rsp+0x70]
  406b33:	c5 ed ef c0          	vpxor  ymm0,ymm2,ymm0
  406b37:	c4 c1 65 ef df       	vpxor  ymm3,ymm3,ymm15
  406b3c:	c5 fd ef c3          	vpxor  ymm0,ymm0,ymm3
  406b40:	c4 e3 7d 39 c2 01    	vextracti128 xmm2,ymm0,0x1
  406b46:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  406b4a:	c4 e3 71 44 94 24 80 	vpclmulhqlqdq xmm2,xmm1,XMMWORD PTR [rsp+0x80]
  406b51:	00 00 00 01 
  406b55:	c5 f1 ef ce          	vpxor  xmm1,xmm1,xmm6
  406b59:	c5 f9 ef 84 24 90 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rsp+0x90]
  406b60:	00 00 
  406b62:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  406b67:	c4 e2 41 00 db       	vpshufb xmm3,xmm7,xmm3
  406b6c:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  406b70:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  406b74:	48 39 c1             	cmp    rcx,rax
  406b77:	0f 85 f3 fe ff ff    	jne    406a70 <chainhash_wide256.constprop.0+0x2d0>
  406b7d:	c4 e3 79 44 c9 01    	vpclmulhqlqdq xmm1,xmm0,xmm1
  406b83:	c5 f9 6f 64 24 70    	vmovdqa xmm4,XMMWORD PTR [rsp+0x70]
  406b89:	30 d2                	xor    dl,dl
  406b8b:	48 89 de             	mov    rsi,rbx
  406b8e:	c4 e3 71 44 94 24 80 	vpclmulhqlqdq xmm2,xmm1,XMMWORD PTR [rsp+0x80]
  406b95:	00 00 00 01 
  406b99:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  406b9d:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  406ba2:	c4 e2 59 00 db       	vpshufb xmm3,xmm4,xmm3
  406ba7:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  406bab:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  406baf:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  406bb3:	48 29 d6             	sub    rsi,rdx
  406bb6:	0f 85 6b fc ff ff    	jne    406827 <chainhash_wide256.constprop.0+0x87>
  406bbc:	c5 f8 77             	vzeroupper 
  406bbf:	c4 e1 f9 6e f3       	vmovq  xmm6,rbx
  406bc4:	c4 c1 f9 6e d4       	vmovq  xmm2,r12
  406bc9:	c5 e9 ef 94 24 90 00 	vpxor  xmm2,xmm2,XMMWORD PTR [rsp+0x90]
  406bd0:	00 00 
  406bd2:	c5 f9 6f 7c 24 70    	vmovdqa xmm7,XMMWORD PTR [rsp+0x70]
  406bd8:	c5 c9 6c c6          	vpunpcklqdq xmm0,xmm6,xmm6
  406bdc:	48 8b 05 d5 45 00 00 	mov    rax,QWORD PTR [rip+0x45d5]        # 40b1b8 <shipped+0x118>
  406be3:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  406be7:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  406beb:	c4 e3 69 44 c9 01    	vpclmulhqlqdq xmm1,xmm2,xmm1
  406bf1:	c4 e3 71 44 84 24 80 	vpclmulhqlqdq xmm0,xmm1,XMMWORD PTR [rsp+0x80]
  406bf8:	00 00 00 01 
  406bfc:	c5 e1 73 d8 08       	vpsrldq xmm3,xmm0,0x8
  406c01:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  406c05:	c4 e2 41 00 db       	vpshufb xmm3,xmm7,xmm3
  406c0a:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  406c0e:	c5 f9 6f 1d 7a 25 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x257a]        # 409190 <__PRETTY_FUNCTION__.6+0x40>
  406c15:	00 
  406c16:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  406c1a:	c5 fa 7e 0d be 45 00 	vmovq  xmm1,QWORD PTR [rip+0x45be]        # 40b1e0 <shipped+0x140>
  406c21:	00 
  406c22:	c5 f9 d4 c1          	vpaddq xmm0,xmm0,xmm1
  406c26:	c4 e3 79 44 c8 00    	vpclmullqlqdq xmm1,xmm0,xmm0
  406c2c:	c4 e3 71 44 d3 11    	vpclmulhqhqdq xmm2,xmm1,xmm3
  406c32:	c4 e3 69 44 e3 11    	vpclmulhqhqdq xmm4,xmm2,xmm3
  406c38:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  406c3c:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  406c41:	48 33 05 78 45 00 00 	xor    rax,QWORD PTR [rip+0x4578]        # 40b1c0 <shipped+0x120>
  406c48:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  406c4c:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  406c50:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  406c55:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  406c59:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  406c5d:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  406c63:	c5 fa 7e 15 5d 45 00 	vmovq  xmm2,QWORD PTR [rip+0x455d]        # 40b1c8 <shipped+0x128>
  406c6a:	00 
  406c6b:	c4 e3 71 44 e3 11    	vpclmulhqhqdq xmm4,xmm1,xmm3
  406c71:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  406c75:	c5 fa 7e 15 53 45 00 	vmovq  xmm2,QWORD PTR [rip+0x4553]        # 40b1d0 <shipped+0x130>
  406c7c:	00 
  406c7d:	c4 e3 59 44 eb 11    	vpclmulhqhqdq xmm5,xmm4,xmm3
  406c83:	c5 f1 ef cc          	vpxor  xmm1,xmm1,xmm4
  406c87:	c5 e9 ef d5          	vpxor  xmm2,xmm2,xmm5
  406c8b:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  406c8f:	c5 fa 7e 15 41 45 00 	vmovq  xmm2,QWORD PTR [rip+0x4541]        # 40b1d8 <shipped+0x138>
  406c96:	00 
  406c97:	48 8d 65 e8          	lea    rsp,[rbp-0x18]
  406c9b:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
  406ca1:	5b                   	pop    rbx
  406ca2:	41 5c                	pop    r12
  406ca4:	c4 e3 79 44 e3 11    	vpclmulhqhqdq xmm4,xmm0,xmm3
  406caa:	41 5d                	pop    r13
  406cac:	5d                   	pop    rbp
  406cad:	c4 e3 59 44 cb 11    	vpclmulhqhqdq xmm1,xmm4,xmm3
  406cb3:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
  406cb7:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  406cbb:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  406cbf:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  406cc4:	c3                   	ret    
  406cc5:	c5 fe 6f 31          	vmovdqu ymm6,YMMWORD PTR [rcx]
  406cc9:	c5 cd ef 15 cf 43 00 	vpxor  ymm2,ymm6,YMMWORD PTR [rip+0x43cf]        # 40b0a0 <shipped>
  406cd0:	00 
  406cd1:	c5 fe 6f 71 20       	vmovdqu ymm6,YMMWORD PTR [rcx+0x20]
  406cd6:	c5 cd ef 1d e2 43 00 	vpxor  ymm3,ymm6,YMMWORD PTR [rip+0x43e2]        # 40b0c0 <shipped+0x20>
  406cdd:	00 
  406cde:	c5 fe 6f 71 40       	vmovdqu ymm6,YMMWORD PTR [rcx+0x40]
  406ce3:	c5 fe 6f b9 80 00 00 	vmovdqu ymm7,YMMWORD PTR [rcx+0x80]
  406cea:	00 
  406ceb:	c4 e3 6d 46 c3 20    	vperm2i128 ymm0,ymm2,ymm3,0x20
  406cf1:	c4 e3 6d 46 d3 31    	vperm2i128 ymm2,ymm2,ymm3,0x31
  406cf7:	c4 e3 7d 44 e2 11    	vpclmulhqhqdq ymm4,ymm0,ymm2
  406cfd:	c4 e3 7d 44 c2 00    	vpclmullqlqdq ymm0,ymm0,ymm2
  406d03:	c5 cd ef 15 d5 43 00 	vpxor  ymm2,ymm6,YMMWORD PTR [rip+0x43d5]        # 40b0e0 <shipped+0x40>
  406d0a:	00 
  406d0b:	c5 fe 6f 71 60       	vmovdqu ymm6,YMMWORD PTR [rcx+0x60]
  406d10:	c5 cd ef 1d e8 43 00 	vpxor  ymm3,ymm6,YMMWORD PTR [rip+0x43e8]        # 40b100 <shipped+0x60>
  406d17:	00 
  406d18:	c4 e3 6d 46 f3 20    	vperm2i128 ymm6,ymm2,ymm3,0x20
  406d1e:	c4 e3 6d 46 d3 31    	vperm2i128 ymm2,ymm2,ymm3,0x31
  406d24:	c4 e3 4d 44 ea 11    	vpclmulhqhqdq ymm5,ymm6,ymm2
  406d2a:	c4 e3 4d 44 f2 00    	vpclmullqlqdq ymm6,ymm6,ymm2
  406d30:	c5 c5 ef 15 e8 43 00 	vpxor  ymm2,ymm7,YMMWORD PTR [rip+0x43e8]        # 40b120 <shipped+0x80>
  406d37:	00 
  406d38:	c5 fe 6f b9 a0 00 00 	vmovdqu ymm7,YMMWORD PTR [rcx+0xa0]
  406d3f:	00 
  406d40:	c5 c5 ef 1d f8 43 00 	vpxor  ymm3,ymm7,YMMWORD PTR [rip+0x43f8]        # 40b140 <shipped+0xa0>
  406d47:	00 
  406d48:	c5 fd ef c4          	vpxor  ymm0,ymm0,ymm4
  406d4c:	c4 63 6d 46 c3 20    	vperm2i128 ymm8,ymm2,ymm3,0x20
  406d52:	c4 e3 6d 46 d3 31    	vperm2i128 ymm2,ymm2,ymm3,0x31
  406d58:	c5 fe 6f 99 c0 00 00 	vmovdqu ymm3,YMMWORD PTR [rcx+0xc0]
  406d5f:	00 
  406d60:	c4 e3 3d 44 fa 11    	vpclmulhqhqdq ymm7,ymm8,ymm2
  406d66:	c4 63 3d 44 c2 00    	vpclmullqlqdq ymm8,ymm8,ymm2
  406d6c:	c5 e5 ef 15 ec 43 00 	vpxor  ymm2,ymm3,YMMWORD PTR [rip+0x43ec]        # 40b160 <shipped+0xc0>
  406d73:	00 
  406d74:	c5 fe 6f 99 e0 00 00 	vmovdqu ymm3,YMMWORD PTR [rcx+0xe0]
  406d7b:	00 
  406d7c:	c5 e5 ef 1d fc 43 00 	vpxor  ymm3,ymm3,YMMWORD PTR [rip+0x43fc]        # 40b180 <shipped+0xe0>
  406d83:	00 
  406d84:	c5 cd ef f5          	vpxor  ymm6,ymm6,ymm5
  406d88:	c5 fd ef c6          	vpxor  ymm0,ymm0,ymm6
  406d8c:	c4 63 6d 46 cb 20    	vperm2i128 ymm9,ymm2,ymm3,0x20
  406d92:	c4 e3 6d 46 d3 31    	vperm2i128 ymm2,ymm2,ymm3,0x31
  406d98:	c4 e3 35 44 da 11    	vpclmulhqhqdq ymm3,ymm9,ymm2
  406d9e:	c4 e3 35 44 d2 00    	vpclmullqlqdq ymm2,ymm9,ymm2
  406da4:	c5 3d ef c7          	vpxor  ymm8,ymm8,ymm7
  406da8:	c4 c1 7d ef c0       	vpxor  ymm0,ymm0,ymm8
  406dad:	c5 ed ef d3          	vpxor  ymm2,ymm2,ymm3
  406db1:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
  406db5:	c4 e3 7d 39 c2 01    	vextracti128 xmm2,ymm0,0x1
  406dbb:	c5 e9 ef d8          	vpxor  xmm3,xmm2,xmm0
  406dbf:	c5 f8 77             	vzeroupper 
  406dc2:	e9 f8 fd ff ff       	jmp    406bbf <chainhash_wide256.constprop.0+0x41f>
  406dc7:	48 89 f2             	mov    rdx,rsi
  406dca:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  406dce:	4a 8d 34 29          	lea    rsi,[rcx+r13*1]
  406dd2:	c5 f9 7f 04 24       	vmovdqa XMMWORD PTR [rsp],xmm0
  406dd7:	4c 29 ea             	sub    rdx,r13
  406dda:	48 8d bc 24 a0 00 00 	lea    rdi,[rsp+0xa0]
  406de1:	00 
  406de2:	c5 f9 7f 54 24 20    	vmovdqa XMMWORD PTR [rsp+0x20],xmm2
  406de8:	c5 f9 7f 4c 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm1
  406dee:	c5 f9 7f 9c 24 a0 00 	vmovdqa XMMWORD PTR [rsp+0xa0],xmm3
  406df5:	00 00 
  406df7:	c5 f9 7f 9c 24 b0 00 	vmovdqa XMMWORD PTR [rsp+0xb0],xmm3
  406dfe:	00 00 
  406e00:	c5 f8 77             	vzeroupper 
  406e03:	e8 68 a2 ff ff       	call   401070 <memcpy@plt>
  406e08:	c5 f9 6f 04 24       	vmovdqa xmm0,XMMWORD PTR [rsp]
  406e0d:	c5 f9 6f a4 24 a0 00 	vmovdqa xmm4,XMMWORD PTR [rsp+0xa0]
  406e14:	00 00 
  406e16:	c4 c1 59 ef 9d a0 b0 	vpxor  xmm3,xmm4,XMMWORD PTR [r13+0x40b0a0]
  406e1d:	40 00 
  406e1f:	c5 f9 6f 54 24 20    	vmovdqa xmm2,XMMWORD PTR [rsp+0x20]
  406e25:	c5 f9 6f a4 24 b0 00 	vmovdqa xmm4,XMMWORD PTR [rsp+0xb0]
  406e2c:	00 00 
  406e2e:	c5 f9 6f 4c 24 40    	vmovdqa xmm1,XMMWORD PTR [rsp+0x40]
  406e34:	c4 c1 59 ef a5 b0 b0 	vpxor  xmm4,xmm4,XMMWORD PTR [r13+0x40b0b0]
  406e3b:	40 00 
  406e3d:	c4 e3 61 44 ec 11    	vpclmulhqhqdq xmm5,xmm3,xmm4
  406e43:	c4 e3 61 44 dc 00    	vpclmullqlqdq xmm3,xmm3,xmm4
  406e49:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  406e4d:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  406e51:	e9 c1 fa ff ff       	jmp    406917 <chainhash_wide256.constprop.0+0x177>
  406e56:	c5 f9 6f 25 12 23 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x2312]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  406e5d:	00 
  406e5e:	c5 f9 6f 35 1a 23 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x231a]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  406e65:	00 
  406e66:	c5 f9 7f a4 24 80 00 	vmovdqa XMMWORD PTR [rsp+0x80],xmm4
  406e6d:	00 00 
  406e6f:	c5 f9 7f 74 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm6
  406e75:	e9 03 fd ff ff       	jmp    406b7d <chainhash_wide256.constprop.0+0x3dd>
  406e7a:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  406e7e:	b8 20 00 00 00       	mov    eax,0x20
  406e83:	45 31 ed             	xor    r13d,r13d
  406e86:	c5 f9 6f d0          	vmovdqa xmm2,xmm0
  406e8a:	e9 41 fa ff ff       	jmp    4068d0 <chainhash_wide256.constprop.0+0x130>
  406e8f:	90                   	nop

0000000000406e90 <chainhash_wide512.constprop.0>:
  406e90:	55                   	push   rbp
  406e91:	48 8d 56 ff          	lea    rdx,[rsi-0x1]
  406e95:	49 89 d0             	mov    r8,rdx
  406e98:	49 c1 e8 08          	shr    r8,0x8
  406e9c:	48 89 e5             	mov    rbp,rsp
  406e9f:	41 55                	push   r13
  406ea1:	41 54                	push   r12
  406ea3:	53                   	push   rbx
  406ea4:	48 89 f3             	mov    rbx,rsi
  406ea7:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  406eab:	48 83 c4 80          	add    rsp,0xffffffffffffff80
  406eaf:	4c 8b 25 ea 42 00 00 	mov    r12,QWORD PTR [rip+0x42ea]        # 40b1a0 <shipped+0x100>
  406eb6:	48 8b 05 f3 42 00 00 	mov    rax,QWORD PTR [rip+0x42f3]        # 40b1b0 <shipped+0x110>
  406ebd:	c5 f9 6f 35 db 42 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x42db]        # 40b1a0 <shipped+0x100>
  406ec4:	00 
  406ec5:	4c 31 e0             	xor    rax,r12
  406ec8:	c4 e1 f9 6e c0       	vmovq  xmm0,rax
  406ecd:	48 81 fa ff 00 00 00 	cmp    rdx,0xff
  406ed4:	0f 87 26 01 00 00    	ja     407000 <chainhash_wide512.constprop.0+0x170>
  406eda:	30 d2                	xor    dl,dl
  406edc:	48 89 de             	mov    rsi,rbx
  406edf:	c5 f9 6f 25 89 22 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x2289]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  406ee6:	00 
  406ee7:	c5 f9 6f 2d 91 22 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x2291]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  406eee:	00 
  406eef:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  406ef3:	48 29 d6             	sub    rsi,rdx
  406ef6:	0f 84 db 02 00 00    	je     4071d7 <chainhash_wide512.constprop.0+0x347>
  406efc:	49 c1 e0 08          	shl    r8,0x8
  406f00:	4a 8d 0c 07          	lea    rcx,[rdi+r8*1]
  406f04:	48 81 fe ff 00 00 00 	cmp    rsi,0xff
  406f0b:	0f 87 bf 03 00 00    	ja     4072d0 <chainhash_wide512.constprop.0+0x440>
  406f11:	48 83 fe 3f          	cmp    rsi,0x3f
  406f15:	0f 86 19 05 00 00    	jbe    407434 <chainhash_wide512.constprop.0+0x5a4>
  406f1b:	c4 41 39 ef c0       	vpxor  xmm8,xmm8,xmm8
  406f20:	b8 40 00 00 00       	mov    eax,0x40
  406f25:	c5 79 7f c7          	vmovdqa xmm7,xmm8
  406f29:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  406f30:	c5 fa 6f 5c 01 c0    	vmovdqu xmm3,XMMWORD PTR [rcx+rax*1-0x40]
  406f36:	c5 e1 ef 88 60 b0 40 	vpxor  xmm1,xmm3,XMMWORD PTR [rax+0x40b060]
  406f3d:	00 
  406f3e:	49 89 c5             	mov    r13,rax
  406f41:	c5 fa 6f 5c 01 d0    	vmovdqu xmm3,XMMWORD PTR [rcx+rax*1-0x30]
  406f47:	c5 e1 ef 90 70 b0 40 	vpxor  xmm2,xmm3,XMMWORD PTR [rax+0x40b070]
  406f4e:	00 
  406f4f:	c4 e3 71 44 da 11    	vpclmulhqhqdq xmm3,xmm1,xmm2
  406f55:	c4 e3 71 44 d2 00    	vpclmullqlqdq xmm2,xmm1,xmm2
  406f5b:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  406f5f:	c5 fa 6f 5c 01 e0    	vmovdqu xmm3,XMMWORD PTR [rcx+rax*1-0x20]
  406f65:	c5 e1 ef 88 80 b0 40 	vpxor  xmm1,xmm3,XMMWORD PTR [rax+0x40b080]
  406f6c:	00 
  406f6d:	c5 fa 6f 5c 01 f0    	vmovdqu xmm3,XMMWORD PTR [rcx+rax*1-0x10]
  406f73:	c5 e9 ef d7          	vpxor  xmm2,xmm2,xmm7
  406f77:	48 8d 40 40          	lea    rax,[rax+0x40]
  406f7b:	c5 e1 ef 98 50 b0 40 	vpxor  xmm3,xmm3,XMMWORD PTR [rax+0x40b050]
  406f82:	00 
  406f83:	c5 f9 6f fa          	vmovdqa xmm7,xmm2
  406f87:	c4 63 71 44 cb 11    	vpclmulhqhqdq xmm9,xmm1,xmm3
  406f8d:	c4 e3 71 44 cb 00    	vpclmullqlqdq xmm1,xmm1,xmm3
  406f93:	c4 c1 71 ef c9       	vpxor  xmm1,xmm1,xmm9
  406f98:	c4 c1 71 ef c8       	vpxor  xmm1,xmm1,xmm8
  406f9d:	c5 79 6f c1          	vmovdqa xmm8,xmm1
  406fa1:	48 39 c6             	cmp    rsi,rax
  406fa4:	73 8a                	jae    406f30 <chainhash_wide512.constprop.0+0xa0>
  406fa6:	49 8d 45 20          	lea    rax,[r13+0x20]
  406faa:	48 39 c6             	cmp    rsi,rax
  406fad:	72 37                	jb     406fe6 <chainhash_wide512.constprop.0+0x156>
  406faf:	4a 8d 14 29          	lea    rdx,[rcx+r13*1]
  406fb3:	c5 fa 6f 3a          	vmovdqu xmm7,XMMWORD PTR [rdx]
  406fb7:	c4 c1 41 ef 9d a0 b0 	vpxor  xmm3,xmm7,XMMWORD PTR [r13+0x40b0a0]
  406fbe:	40 00 
  406fc0:	c5 fa 6f 7a 10       	vmovdqu xmm7,XMMWORD PTR [rdx+0x10]
  406fc5:	c4 c1 41 ef bd b0 b0 	vpxor  xmm7,xmm7,XMMWORD PTR [r13+0x40b0b0]
  406fcc:	40 00 
  406fce:	49 89 c5             	mov    r13,rax
  406fd1:	c4 63 61 44 c7 11    	vpclmulhqhqdq xmm8,xmm3,xmm7
  406fd7:	c4 e3 61 44 df 00    	vpclmullqlqdq xmm3,xmm3,xmm7
  406fdd:	c4 c1 61 ef d8       	vpxor  xmm3,xmm3,xmm8
  406fe2:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  406fe6:	4c 39 ee             	cmp    rsi,r13
  406fe9:	0f 87 8b 03 00 00    	ja     40737a <chainhash_wide512.constprop.0+0x4ea>
  406fef:	c5 f8 77             	vzeroupper 
  406ff2:	c5 e9 ef d9          	vpxor  xmm3,xmm2,xmm1
  406ff6:	e9 df 01 00 00       	jmp    4071da <chainhash_wide512.constprop.0+0x34a>
  406ffb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  407000:	62 71 7e 48 6f 0d 96 	vmovdqu32 zmm9,ZMMWORD PTR [rip+0x4096]        # 40b0a0 <shipped>
  407007:	40 00 00 
  40700a:	62 f1 7e 48 6f 2f    	vmovdqu32 zmm5,ZMMWORD PTR [rdi]
  407010:	62 71 7e 48 6f 15 c6 	vmovdqu32 zmm10,ZMMWORD PTR [rip+0x40c6]        # 40b0e0 <shipped+0x40>
  407017:	40 00 00 
  40701a:	62 f1 7e 48 6f 67 02 	vmovdqu32 zmm4,ZMMWORD PTR [rdi+0x80]
  407021:	62 71 7e 48 6f 1d f5 	vmovdqu32 zmm11,ZMMWORD PTR [rip+0x40f5]        # 40b120 <shipped+0x80>
  407028:	40 00 00 
  40702b:	62 d1 55 48 ef c9    	vpxord zmm1,zmm5,zmm9
  407031:	62 f1 7e 48 6f 6f 01 	vmovdqu32 zmm5,ZMMWORD PTR [rdi+0x40]
  407038:	62 71 7e 48 6f 25 1e 	vmovdqu32 zmm12,ZMMWORD PTR [rip+0x411e]        # 40b160 <shipped+0xc0>
  40703f:	41 00 00 
  407042:	62 d1 55 48 ef da    	vpxord zmm3,zmm5,zmm10
  407048:	62 f3 f5 48 43 d3 88 	vshufi64x2 zmm2,zmm1,zmm3,0x88
  40704f:	62 f3 f5 48 43 cb dd 	vshufi64x2 zmm1,zmm1,zmm3,0xdd
  407056:	62 f3 6d 48 44 e9 11 	vpclmulhqhqdq zmm5,zmm2,zmm1
  40705d:	62 f3 6d 48 44 d9 00 	vpclmullqlqdq zmm3,zmm2,zmm1
  407064:	62 d1 5d 48 ef d3    	vpxord zmm2,zmm4,zmm11
  40706a:	62 f1 7e 48 6f 67 03 	vmovdqu32 zmm4,ZMMWORD PTR [rdi+0xc0]
  407071:	62 d1 5d 48 ef e4    	vpxord zmm4,zmm4,zmm12
  407077:	62 f3 ed 48 43 cc 88 	vshufi64x2 zmm1,zmm2,zmm4,0x88
  40707e:	62 f3 ed 48 43 d4 dd 	vshufi64x2 zmm2,zmm2,zmm4,0xdd
  407085:	62 f3 75 48 44 e2 11 	vpclmulhqhqdq zmm4,zmm1,zmm2
  40708c:	62 f3 75 48 44 ca 00 	vpclmullqlqdq zmm1,zmm1,zmm2
  407093:	62 f1 65 48 ef d5    	vpxord zmm2,zmm3,zmm5
  407099:	62 f1 75 48 ef cc    	vpxord zmm1,zmm1,zmm4
  40709f:	62 f1 75 48 ef ca    	vpxord zmm1,zmm1,zmm2
  4070a5:	62 f3 fd 48 3b ca 01 	vextracti64x4 ymm2,zmm1,0x1
  4070ac:	c5 ed ef c9          	vpxor  ymm1,ymm2,ymm1
  4070b0:	c4 e3 7d 39 cf 01    	vextracti128 xmm7,ymm1,0x1
  4070b6:	c5 c1 ef f9          	vpxor  xmm7,xmm7,xmm1
  4070ba:	c5 c1 ef fe          	vpxor  xmm7,xmm7,xmm6
  4070be:	49 83 f8 01          	cmp    r8,0x1
  4070c2:	0f 86 57 03 00 00    	jbe    40741f <chainhash_wide512.constprop.0+0x58f>
  4070c8:	4c 89 c1             	mov    rcx,r8
  4070cb:	48 8d 87 00 01 00 00 	lea    rax,[rdi+0x100]
  4070d2:	c5 f9 6f 25 96 20 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x2096]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  4070d9:	00 
  4070da:	c5 f9 6f 2d 9e 20 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x209e]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  4070e1:	00 
  4070e2:	48 c1 e1 08          	shl    rcx,0x8
  4070e6:	48 01 f9             	add    rcx,rdi
  4070e9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  4070f0:	c4 e3 41 44 d0 01    	vpclmulhqlqdq xmm2,xmm7,xmm0
  4070f6:	62 f1 35 48 ef 08    	vpxord zmm1,zmm9,ZMMWORD PTR [rax]
  4070fc:	c5 f9 6f df          	vmovdqa xmm3,xmm7
  407100:	48 05 00 01 00 00    	add    rax,0x100
  407106:	62 f1 2d 48 ef 78 fd 	vpxord zmm7,zmm10,ZMMWORD PTR [rax-0xc0]
  40710d:	62 71 1d 48 ef 40 ff 	vpxord zmm8,zmm12,ZMMWORD PTR [rax-0x40]
  407114:	62 f3 f5 48 43 c7 88 	vshufi64x2 zmm0,zmm1,zmm7,0x88
  40711b:	62 f3 f5 48 43 cf dd 	vshufi64x2 zmm1,zmm1,zmm7,0xdd
  407122:	62 f1 25 48 ef 78 fe 	vpxord zmm7,zmm11,ZMMWORD PTR [rax-0x80]
  407129:	62 73 7d 48 44 e9 11 	vpclmulhqhqdq zmm13,zmm0,zmm1
  407130:	62 f3 7d 48 44 c1 00 	vpclmullqlqdq zmm0,zmm0,zmm1
  407137:	62 d3 c5 48 43 c8 88 	vshufi64x2 zmm1,zmm7,zmm8,0x88
  40713e:	62 d3 c5 48 43 f8 dd 	vshufi64x2 zmm7,zmm7,zmm8,0xdd
  407145:	62 73 75 48 44 c7 11 	vpclmulhqhqdq zmm8,zmm1,zmm7
  40714c:	62 f3 75 48 44 cf 00 	vpclmullqlqdq zmm1,zmm1,zmm7
  407153:	62 d1 7d 48 ef c5    	vpxord zmm0,zmm0,zmm13
  407159:	62 d1 75 48 ef c8    	vpxord zmm1,zmm1,zmm8
  40715f:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
  407165:	62 f3 fd 48 3b c1 01 	vextracti64x4 ymm1,zmm0,0x1
  40716c:	c5 f5 ef c0          	vpxor  ymm0,ymm1,ymm0
  407170:	c4 e3 7d 39 c1 01    	vextracti128 xmm1,ymm0,0x1
  407176:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  40717a:	c5 f9 ef fe          	vpxor  xmm7,xmm0,xmm6
  40717e:	c4 e3 69 44 c4 01    	vpclmulhqlqdq xmm0,xmm2,xmm4
  407184:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  407188:	c5 f1 73 d8 08       	vpsrldq xmm1,xmm0,0x8
  40718d:	c4 e2 51 00 c9       	vpshufb xmm1,xmm5,xmm1
  407192:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  407196:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  40719a:	48 39 c1             	cmp    rcx,rax
  40719d:	0f 85 4d ff ff ff    	jne    4070f0 <chainhash_wide512.constprop.0+0x260>
  4071a3:	c4 e3 41 44 c0 01    	vpclmulhqlqdq xmm0,xmm7,xmm0
  4071a9:	30 d2                	xor    dl,dl
  4071ab:	48 89 de             	mov    rsi,rbx
  4071ae:	c4 e3 79 44 cc 01    	vpclmulhqlqdq xmm1,xmm0,xmm4
  4071b4:	c5 f9 ef c7          	vpxor  xmm0,xmm0,xmm7
  4071b8:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  4071bc:	c5 e9 73 d9 08       	vpsrldq xmm2,xmm1,0x8
  4071c1:	c4 e2 51 00 d2       	vpshufb xmm2,xmm5,xmm2
  4071c6:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4071ca:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  4071ce:	48 29 d6             	sub    rsi,rdx
  4071d1:	0f 85 25 fd ff ff    	jne    406efc <chainhash_wide512.constprop.0+0x6c>
  4071d7:	c5 f8 77             	vzeroupper 
  4071da:	c4 c1 f9 6e cc       	vmovq  xmm1,r12
  4071df:	48 8b 05 d2 3f 00 00 	mov    rax,QWORD PTR [rip+0x3fd2]        # 40b1b8 <shipped+0x118>
  4071e6:	c5 f1 ef ce          	vpxor  xmm1,xmm1,xmm6
  4071ea:	c4 e1 f9 6e f3       	vmovq  xmm6,rbx
  4071ef:	c5 c9 6c d6          	vpunpcklqdq xmm2,xmm6,xmm6
  4071f3:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  4071f7:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4071fb:	c4 e3 71 44 c0 01    	vpclmulhqlqdq xmm0,xmm1,xmm0
  407201:	c4 e3 79 44 e4 01    	vpclmulhqlqdq xmm4,xmm0,xmm4
  407207:	c5 e9 73 dc 08       	vpsrldq xmm2,xmm4,0x8
  40720c:	c5 d9 ef e1          	vpxor  xmm4,xmm4,xmm1
  407210:	c5 fa 7e 0d c8 3f 00 	vmovq  xmm1,QWORD PTR [rip+0x3fc8]        # 40b1e0 <shipped+0x140>
  407217:	00 
  407218:	c4 e2 51 00 ea       	vpshufb xmm5,xmm5,xmm2
  40721d:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  407221:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
  407225:	c5 fb 12 25 43 1f 00 	vmovddup xmm4,QWORD PTR [rip+0x1f43]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  40722c:	00 
  40722d:	c5 f9 d4 d9          	vpaddq xmm3,xmm0,xmm1
  407231:	c4 e1 f9 6e c8       	vmovq  xmm1,rax
  407236:	48 33 05 83 3f 00 00 	xor    rax,QWORD PTR [rip+0x3f83]        # 40b1c0 <shipped+0x120>
  40723d:	c4 e3 61 44 c3 00    	vpclmullqlqdq xmm0,xmm3,xmm3
  407243:	c4 e3 79 44 d4 11    	vpclmulhqhqdq xmm2,xmm0,xmm4
  407249:	c4 e3 69 44 ec 11    	vpclmulhqhqdq xmm5,xmm2,xmm4
  40724f:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  407253:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  407258:	c5 f1 ef cd          	vpxor  xmm1,xmm1,xmm5
  40725c:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  407260:	c5 fa 7e 05 60 3f 00 	vmovq  xmm0,QWORD PTR [rip+0x3f60]        # 40b1c8 <shipped+0x128>
  407267:	00 
  407268:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  40726c:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  407270:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  407274:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  40727a:	c5 fa 7e 15 4e 3f 00 	vmovq  xmm2,QWORD PTR [rip+0x3f4e]        # 40b1d0 <shipped+0x130>
  407281:	00 
  407282:	c4 e3 71 44 ec 11    	vpclmulhqhqdq xmm5,xmm1,xmm4
  407288:	c4 e3 51 44 f4 11    	vpclmulhqhqdq xmm6,xmm5,xmm4
  40728e:	c5 f1 ef cd          	vpxor  xmm1,xmm1,xmm5
  407292:	c5 e9 ef d6          	vpxor  xmm2,xmm2,xmm6
  407296:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  40729a:	c5 fa 7e 15 36 3f 00 	vmovq  xmm2,QWORD PTR [rip+0x3f36]        # 40b1d8 <shipped+0x138>
  4072a1:	00 
  4072a2:	48 8d 65 e8          	lea    rsp,[rbp-0x18]
  4072a6:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
  4072ac:	5b                   	pop    rbx
  4072ad:	41 5c                	pop    r12
  4072af:	c4 e3 79 44 dc 11    	vpclmulhqhqdq xmm3,xmm0,xmm4
  4072b5:	41 5d                	pop    r13
  4072b7:	5d                   	pop    rbp
  4072b8:	c4 e3 61 44 cc 11    	vpclmulhqhqdq xmm1,xmm3,xmm4
  4072be:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  4072c2:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  4072c6:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  4072ca:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  4072cf:	c3                   	ret    
  4072d0:	62 f1 7e 48 6f 39    	vmovdqu32 zmm7,ZMMWORD PTR [rcx]
  4072d6:	62 f1 45 48 ef 15 c0 	vpxord zmm2,zmm7,ZMMWORD PTR [rip+0x3dc0]        # 40b0a0 <shipped>
  4072dd:	3d 00 00 
  4072e0:	62 f1 7e 48 6f 79 01 	vmovdqu32 zmm7,ZMMWORD PTR [rcx+0x40]
  4072e7:	62 f1 45 48 ef 1d ef 	vpxord zmm3,zmm7,ZMMWORD PTR [rip+0x3def]        # 40b0e0 <shipped+0x40>
  4072ee:	3d 00 00 
  4072f1:	62 f1 7e 48 6f 79 02 	vmovdqu32 zmm7,ZMMWORD PTR [rcx+0x80]
  4072f8:	62 f3 ed 48 43 cb 88 	vshufi64x2 zmm1,zmm2,zmm3,0x88
  4072ff:	62 f3 ed 48 43 d3 dd 	vshufi64x2 zmm2,zmm2,zmm3,0xdd
  407306:	62 73 75 48 44 c2 11 	vpclmulhqhqdq zmm8,zmm1,zmm2
  40730d:	62 f3 75 48 44 ca 00 	vpclmullqlqdq zmm1,zmm1,zmm2
  407314:	62 f1 45 48 ef 15 02 	vpxord zmm2,zmm7,ZMMWORD PTR [rip+0x3e02]        # 40b120 <shipped+0x80>
  40731b:	3e 00 00 
  40731e:	62 f1 7e 48 6f 79 03 	vmovdqu32 zmm7,ZMMWORD PTR [rcx+0xc0]
  407325:	62 f1 45 48 ef 3d 31 	vpxord zmm7,zmm7,ZMMWORD PTR [rip+0x3e31]        # 40b160 <shipped+0xc0>
  40732c:	3e 00 00 
  40732f:	62 f3 ed 48 43 df 88 	vshufi64x2 zmm3,zmm2,zmm7,0x88
  407336:	62 f3 ed 48 43 d7 dd 	vshufi64x2 zmm2,zmm2,zmm7,0xdd
  40733d:	62 f3 65 48 44 fa 11 	vpclmulhqhqdq zmm7,zmm3,zmm2
  407344:	62 f3 65 48 44 da 00 	vpclmullqlqdq zmm3,zmm3,zmm2
  40734b:	62 d1 75 48 ef c8    	vpxord zmm1,zmm1,zmm8
  407351:	62 f1 65 48 ef df    	vpxord zmm3,zmm3,zmm7
  407357:	62 f1 75 48 ef cb    	vpxord zmm1,zmm1,zmm3
  40735d:	62 f3 fd 48 3b ca 01 	vextracti64x4 ymm2,zmm1,0x1
  407364:	c5 ed ef c9          	vpxor  ymm1,ymm2,ymm1
  407368:	c4 e3 7d 39 cb 01    	vextracti128 xmm3,ymm1,0x1
  40736e:	c5 e1 ef d9          	vpxor  xmm3,xmm3,xmm1
  407372:	c5 f8 77             	vzeroupper 
  407375:	e9 60 fe ff ff       	jmp    4071da <chainhash_wide512.constprop.0+0x34a>
  40737a:	48 89 f2             	mov    rdx,rsi
  40737d:	48 8d 7c 24 60       	lea    rdi,[rsp+0x60]
  407382:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  407386:	c5 f9 7f 24 24       	vmovdqa XMMWORD PTR [rsp],xmm4
  40738b:	4c 29 ea             	sub    rdx,r13
  40738e:	4a 8d 34 29          	lea    rsi,[rcx+r13*1]
  407392:	c5 f9 7f 6c 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm5
  407398:	c5 f9 7f 74 24 20    	vmovdqa XMMWORD PTR [rsp+0x20],xmm6
  40739e:	c5 f9 7f 4c 24 30    	vmovdqa XMMWORD PTR [rsp+0x30],xmm1
  4073a4:	c5 f9 7f 54 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm2
  4073aa:	c5 f9 7f 44 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm0
  4073b0:	c5 f9 7f 5c 24 60    	vmovdqa XMMWORD PTR [rsp+0x60],xmm3
  4073b6:	c5 f9 7f 5c 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm3
  4073bc:	c5 f8 77             	vzeroupper 
  4073bf:	e8 ac 9c ff ff       	call   401070 <memcpy@plt>
  4073c4:	c5 f9 6f 74 24 60    	vmovdqa xmm6,XMMWORD PTR [rsp+0x60]
  4073ca:	c4 c1 49 ef 9d a0 b0 	vpxor  xmm3,xmm6,XMMWORD PTR [r13+0x40b0a0]
  4073d1:	40 00 
  4073d3:	c5 f9 6f 74 24 70    	vmovdqa xmm6,XMMWORD PTR [rsp+0x70]
  4073d9:	c5 f9 6f 4c 24 30    	vmovdqa xmm1,XMMWORD PTR [rsp+0x30]
  4073df:	c4 c1 49 ef bd b0 b0 	vpxor  xmm7,xmm6,XMMWORD PTR [r13+0x40b0b0]
  4073e6:	40 00 
  4073e8:	c5 f9 6f 24 24       	vmovdqa xmm4,XMMWORD PTR [rsp]
  4073ed:	c5 f9 6f 6c 24 10    	vmovdqa xmm5,XMMWORD PTR [rsp+0x10]
  4073f3:	c5 f9 6f 74 24 20    	vmovdqa xmm6,XMMWORD PTR [rsp+0x20]
  4073f9:	c4 63 61 44 c7 11    	vpclmulhqhqdq xmm8,xmm3,xmm7
  4073ff:	c4 e3 61 44 df 00    	vpclmullqlqdq xmm3,xmm3,xmm7
  407405:	c5 f9 6f 54 24 40    	vmovdqa xmm2,XMMWORD PTR [rsp+0x40]
  40740b:	c5 f9 6f 44 24 50    	vmovdqa xmm0,XMMWORD PTR [rsp+0x50]
  407411:	c4 c1 61 ef d8       	vpxor  xmm3,xmm3,xmm8
  407416:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  40741a:	e9 d3 fb ff ff       	jmp    406ff2 <chainhash_wide512.constprop.0+0x162>
  40741f:	c5 f9 6f 25 49 1d 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x1d49]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  407426:	00 
  407427:	c5 f9 6f 2d 51 1d 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x1d51]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  40742e:	00 
  40742f:	e9 6f fd ff ff       	jmp    4071a3 <chainhash_wide512.constprop.0+0x313>
  407434:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
  407438:	b8 20 00 00 00       	mov    eax,0x20
  40743d:	45 31 ed             	xor    r13d,r13d
  407440:	c5 f9 6f d1          	vmovdqa xmm2,xmm1
  407444:	e9 61 fb ff ff       	jmp    406faa <chainhash_wide512.constprop.0+0x11a>
  407449:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000407450 <chainhash_narrow.constprop.0>:
  407450:	41 54                	push   r12
  407452:	48 8d 56 ff          	lea    rdx,[rsi-0x1]
  407456:	55                   	push   rbp
  407457:	49 89 d0             	mov    r8,rdx
  40745a:	53                   	push   rbx
  40745b:	49 c1 e8 08          	shr    r8,0x8
  40745f:	48 89 f3             	mov    rbx,rsi
  407462:	48 81 ec 80 01 00 00 	sub    rsp,0x180
  407469:	48 8b 2d 30 3d 00 00 	mov    rbp,QWORD PTR [rip+0x3d30]        # 40b1a0 <shipped+0x100>
  407470:	48 8b 05 39 3d 00 00 	mov    rax,QWORD PTR [rip+0x3d39]        # 40b1b0 <shipped+0x110>
  407477:	c5 f9 6f 25 21 3d 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3d21]        # 40b1a0 <shipped+0x100>
  40747e:	00 
  40747f:	48 31 e8             	xor    rax,rbp
  407482:	c4 e1 f9 6e c8       	vmovq  xmm1,rax
  407487:	c5 f9 7f 64 24 30    	vmovdqa XMMWORD PTR [rsp+0x30],xmm4
  40748d:	48 81 fa ff 00 00 00 	cmp    rdx,0xff
  407494:	0f 87 26 02 00 00    	ja     4076c0 <chainhash_narrow.constprop.0+0x270>
  40749a:	c5 f9 6f 25 ce 1c 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x1cce]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  4074a1:	00 
  4074a2:	c5 f9 6f 2d d6 1c 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x1cd6]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  4074a9:	00 
  4074aa:	c5 f9 7f 64 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm4
  4074b0:	c5 f9 7f 6c 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm5
  4074b6:	30 d2                	xor    dl,dl
  4074b8:	48 89 de             	mov    rsi,rbx
  4074bb:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  4074bf:	48 29 d6             	sub    rsi,rdx
  4074c2:	0f 84 f3 00 00 00    	je     4075bb <chainhash_narrow.constprop.0+0x16b>
  4074c8:	49 c1 e0 08          	shl    r8,0x8
  4074cc:	4a 8d 0c 07          	lea    rcx,[rdi+r8*1]
  4074d0:	48 81 fe ff 00 00 00 	cmp    rsi,0xff
  4074d7:	0f 87 5c 06 00 00    	ja     407b39 <chainhash_narrow.constprop.0+0x6e9>
  4074dd:	48 83 fe 3f          	cmp    rsi,0x3f
  4074e1:	0f 86 7c 08 00 00    	jbe    407d63 <chainhash_narrow.constprop.0+0x913>
  4074e7:	c5 d1 ef ed          	vpxor  xmm5,xmm5,xmm5
  4074eb:	b8 40 00 00 00       	mov    eax,0x40
  4074f0:	c5 f9 6f e5          	vmovdqa xmm4,xmm5
  4074f4:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  4074f8:	c5 fa 6f 7c 01 c0    	vmovdqu xmm7,XMMWORD PTR [rcx+rax*1-0x40]
  4074fe:	c5 c1 ef 80 60 b0 40 	vpxor  xmm0,xmm7,XMMWORD PTR [rax+0x40b060]
  407505:	00 
  407506:	49 89 c4             	mov    r12,rax
  407509:	c5 fa 6f 7c 01 d0    	vmovdqu xmm7,XMMWORD PTR [rcx+rax*1-0x30]
  40750f:	c5 c1 ef 90 70 b0 40 	vpxor  xmm2,xmm7,XMMWORD PTR [rax+0x40b070]
  407516:	00 
  407517:	c5 fa 6f 7c 01 e0    	vmovdqu xmm7,XMMWORD PTR [rcx+rax*1-0x20]
  40751d:	c4 e3 79 44 da 11    	vpclmulhqhqdq xmm3,xmm0,xmm2
  407523:	c4 e3 79 44 d2 00    	vpclmullqlqdq xmm2,xmm0,xmm2
  407529:	c5 c1 ef 80 80 b0 40 	vpxor  xmm0,xmm7,XMMWORD PTR [rax+0x40b080]
  407530:	00 
  407531:	c5 fa 6f 7c 01 f0    	vmovdqu xmm7,XMMWORD PTR [rcx+rax*1-0x10]
  407537:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  40753b:	c5 c1 ef 98 90 b0 40 	vpxor  xmm3,xmm7,XMMWORD PTR [rax+0x40b090]
  407542:	00 
  407543:	48 8d 40 40          	lea    rax,[rax+0x40]
  407547:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  40754b:	c4 e3 79 44 f3 11    	vpclmulhqhqdq xmm6,xmm0,xmm3
  407551:	c4 e3 79 44 c3 00    	vpclmullqlqdq xmm0,xmm0,xmm3
  407557:	c5 f9 6f e2          	vmovdqa xmm4,xmm2
  40755b:	c5 f9 ef c6          	vpxor  xmm0,xmm0,xmm6
  40755f:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  407563:	c5 f9 6f e8          	vmovdqa xmm5,xmm0
  407567:	48 39 c6             	cmp    rsi,rax
  40756a:	73 8c                	jae    4074f8 <chainhash_narrow.constprop.0+0xa8>
  40756c:	49 8d 44 24 20       	lea    rax,[r12+0x20]
  407571:	48 39 c6             	cmp    rsi,rax
  407574:	72 38                	jb     4075ae <chainhash_narrow.constprop.0+0x15e>
  407576:	4a 8d 14 21          	lea    rdx,[rcx+r12*1]
  40757a:	c5 fa 6f 1a          	vmovdqu xmm3,XMMWORD PTR [rdx]
  40757e:	c5 fa 6f 62 10       	vmovdqu xmm4,XMMWORD PTR [rdx+0x10]
  407583:	c4 c1 61 ef 9c 24 a0 	vpxor  xmm3,xmm3,XMMWORD PTR [r12+0x40b0a0]
  40758a:	b0 40 00 
  40758d:	c4 c1 59 ef a4 24 b0 	vpxor  xmm4,xmm4,XMMWORD PTR [r12+0x40b0b0]
  407594:	b0 40 00 
  407597:	49 89 c4             	mov    r12,rax
  40759a:	c4 e3 61 44 ec 11    	vpclmulhqhqdq xmm5,xmm3,xmm4
  4075a0:	c4 e3 61 44 dc 00    	vpclmullqlqdq xmm3,xmm3,xmm4
  4075a6:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  4075aa:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  4075ae:	4c 39 e6             	cmp    rsi,r12
  4075b1:	0f 87 1e 07 00 00    	ja     407cd5 <chainhash_narrow.constprop.0+0x885>
  4075b7:	c5 e9 ef d8          	vpxor  xmm3,xmm2,xmm0
  4075bb:	c4 e1 f9 6e e3       	vmovq  xmm4,rbx
  4075c0:	c4 e1 f9 6e d5       	vmovq  xmm2,rbp
  4075c5:	c5 e9 ef 54 24 30    	vpxor  xmm2,xmm2,XMMWORD PTR [rsp+0x30]
  4075cb:	c5 f9 6f 6c 24 50    	vmovdqa xmm5,XMMWORD PTR [rsp+0x50]
  4075d1:	c5 d9 6c c4          	vpunpcklqdq xmm0,xmm4,xmm4
  4075d5:	48 8b 05 dc 3b 00 00 	mov    rax,QWORD PTR [rip+0x3bdc]        # 40b1b8 <shipped+0x118>
  4075dc:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  4075e0:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  4075e4:	c4 e3 69 44 c9 01    	vpclmulhqlqdq xmm1,xmm2,xmm1
  4075ea:	c4 e3 71 44 44 24 40 	vpclmulhqlqdq xmm0,xmm1,XMMWORD PTR [rsp+0x40]
  4075f1:	01 
  4075f2:	c5 e1 73 d8 08       	vpsrldq xmm3,xmm0,0x8
  4075f7:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  4075fb:	c4 e2 51 00 db       	vpshufb xmm3,xmm5,xmm3
  407600:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  407604:	c5 f9 6f 1d 84 1b 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x1b84]        # 409190 <__PRETTY_FUNCTION__.6+0x40>
  40760b:	00 
  40760c:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  407610:	c5 fa 7e 0d c8 3b 00 	vmovq  xmm1,QWORD PTR [rip+0x3bc8]        # 40b1e0 <shipped+0x140>
  407617:	00 
  407618:	c5 f9 d4 c1          	vpaddq xmm0,xmm0,xmm1
  40761c:	c4 e3 79 44 c8 00    	vpclmullqlqdq xmm1,xmm0,xmm0
  407622:	c4 e3 71 44 d3 11    	vpclmulhqhqdq xmm2,xmm1,xmm3
  407628:	c4 e3 69 44 e3 11    	vpclmulhqhqdq xmm4,xmm2,xmm3
  40762e:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  407632:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  407637:	48 33 05 82 3b 00 00 	xor    rax,QWORD PTR [rip+0x3b82]        # 40b1c0 <shipped+0x120>
  40763e:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  407642:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  407646:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  40764b:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  40764f:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  407653:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  407659:	c5 fa 7e 15 67 3b 00 	vmovq  xmm2,QWORD PTR [rip+0x3b67]        # 40b1c8 <shipped+0x128>
  407660:	00 
  407661:	c4 e3 71 44 e3 11    	vpclmulhqhqdq xmm4,xmm1,xmm3
  407667:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  40766b:	c5 fa 7e 15 5d 3b 00 	vmovq  xmm2,QWORD PTR [rip+0x3b5d]        # 40b1d0 <shipped+0x130>
  407672:	00 
  407673:	c4 e3 59 44 eb 11    	vpclmulhqhqdq xmm5,xmm4,xmm3
  407679:	c5 f1 ef cc          	vpxor  xmm1,xmm1,xmm4
  40767d:	c5 e9 ef d5          	vpxor  xmm2,xmm2,xmm5
  407681:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  407685:	c5 fa 7e 15 4b 3b 00 	vmovq  xmm2,QWORD PTR [rip+0x3b4b]        # 40b1d8 <shipped+0x138>
  40768c:	00 
  40768d:	48 81 c4 80 01 00 00 	add    rsp,0x180
  407694:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
  40769a:	5b                   	pop    rbx
  40769b:	5d                   	pop    rbp
  40769c:	c4 e3 79 44 e3 11    	vpclmulhqhqdq xmm4,xmm0,xmm3
  4076a2:	41 5c                	pop    r12
  4076a4:	c4 e3 59 44 cb 11    	vpclmulhqhqdq xmm1,xmm4,xmm3
  4076aa:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
  4076ae:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  4076b2:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  4076b6:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  4076bb:	c3                   	ret    
  4076bc:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  4076c0:	c5 f9 6f 25 d8 39 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x39d8]        # 40b0a0 <shipped>
  4076c7:	00 
  4076c8:	c5 f9 6f 2d e0 39 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x39e0]        # 40b0b0 <shipped+0x10>
  4076cf:	00 
  4076d0:	c5 d9 ef 07          	vpxor  xmm0,xmm4,XMMWORD PTR [rdi]
  4076d4:	c5 d1 ef 57 10       	vpxor  xmm2,xmm5,XMMWORD PTR [rdi+0x10]
  4076d9:	c5 f9 7f a4 24 50 01 	vmovdqa XMMWORD PTR [rsp+0x150],xmm4
  4076e0:	00 00 
  4076e2:	c5 f9 6f 25 d6 39 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x39d6]        # 40b0c0 <shipped+0x20>
  4076e9:	00 
  4076ea:	c5 f9 6f 1d ee 39 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x39ee]        # 40b0e0 <shipped+0x40>
  4076f1:	00 
  4076f2:	c4 63 79 44 da 11    	vpclmulhqhqdq xmm11,xmm0,xmm2
  4076f8:	c4 63 79 44 e2 00    	vpclmullqlqdq xmm12,xmm0,xmm2
  4076fe:	c5 f9 7f ac 24 40 01 	vmovdqa XMMWORD PTR [rsp+0x140],xmm5
  407705:	00 00 
  407707:	c5 d9 ef 47 20       	vpxor  xmm0,xmm4,XMMWORD PTR [rdi+0x20]
  40770c:	c5 f9 6f 2d bc 39 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x39bc]        # 40b0d0 <shipped+0x30>
  407713:	00 
  407714:	c5 d1 ef 57 30       	vpxor  xmm2,xmm5,XMMWORD PTR [rdi+0x30]
  407719:	c5 f9 7f a4 24 30 01 	vmovdqa XMMWORD PTR [rsp+0x130],xmm4
  407720:	00 00 
  407722:	c5 f9 6f 25 c6 39 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x39c6]        # 40b0f0 <shipped+0x50>
  407729:	00 
  40772a:	c5 f9 7f 9c 24 10 01 	vmovdqa XMMWORD PTR [rsp+0x110],xmm3
  407731:	00 00 
  407733:	c4 e3 79 44 fa 11    	vpclmulhqhqdq xmm7,xmm0,xmm2
  407739:	c4 e3 79 44 f2 00    	vpclmullqlqdq xmm6,xmm0,xmm2
  40773f:	c5 f9 7f ac 24 20 01 	vmovdqa XMMWORD PTR [rsp+0x120],xmm5
  407746:	00 00 
  407748:	c5 e1 ef 47 40       	vpxor  xmm0,xmm3,XMMWORD PTR [rdi+0x40]
  40774d:	c5 d9 ef 57 50       	vpxor  xmm2,xmm4,XMMWORD PTR [rdi+0x50]
  407752:	c5 f9 7f 74 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm6
  407758:	c5 f9 6f 2d a0 39 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x39a0]        # 40b100 <shipped+0x60>
  40775f:	00 
  407760:	c5 f9 6f 1d a8 39 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x39a8]        # 40b110 <shipped+0x70>
  407767:	00 
  407768:	c5 f9 7f 3c 24       	vmovdqa XMMWORD PTR [rsp],xmm7
  40776d:	c4 e3 79 44 f2 11    	vpclmulhqhqdq xmm6,xmm0,xmm2
  407773:	c4 63 79 44 d2 00    	vpclmullqlqdq xmm10,xmm0,xmm2
  407779:	c5 f9 7f a4 24 00 01 	vmovdqa XMMWORD PTR [rsp+0x100],xmm4
  407780:	00 00 
  407782:	c5 d1 ef 47 60       	vpxor  xmm0,xmm5,XMMWORD PTR [rdi+0x60]
  407787:	c5 e1 ef 57 70       	vpxor  xmm2,xmm3,XMMWORD PTR [rdi+0x70]
  40778c:	c4 c1 49 ef f2       	vpxor  xmm6,xmm6,xmm10
  407791:	c5 f9 6f 25 87 39 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3987]        # 40b120 <shipped+0x80>
  407798:	00 
  407799:	c5 f9 7f ac 24 f0 00 	vmovdqa XMMWORD PTR [rsp+0xf0],xmm5
  4077a0:	00 00 
  4077a2:	c5 f9 6f 2d 86 39 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x3986]        # 40b130 <shipped+0x90>
  4077a9:	00 
  4077aa:	c5 f9 7f 9c 24 e0 00 	vmovdqa XMMWORD PTR [rsp+0xe0],xmm3
  4077b1:	00 00 
  4077b3:	c4 63 79 44 ea 11    	vpclmulhqhqdq xmm13,xmm0,xmm2
  4077b9:	c4 63 79 44 f2 00    	vpclmullqlqdq xmm14,xmm0,xmm2
  4077bf:	c5 f9 7f a4 24 d0 00 	vmovdqa XMMWORD PTR [rsp+0xd0],xmm4
  4077c6:	00 00 
  4077c8:	c5 d9 ef 87 80 00 00 	vpxor  xmm0,xmm4,XMMWORD PTR [rdi+0x80]
  4077cf:	00 
  4077d0:	c5 d1 ef 97 90 00 00 	vpxor  xmm2,xmm5,XMMWORD PTR [rdi+0x90]
  4077d7:	00 
  4077d8:	c5 f9 7f ac 24 c0 00 	vmovdqa XMMWORD PTR [rsp+0xc0],xmm5
  4077df:	00 00 
  4077e1:	c5 f9 6f 1d 57 39 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x3957]        # 40b140 <shipped+0xa0>
  4077e8:	00 
  4077e9:	c5 f9 6f 25 5f 39 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x395f]        # 40b150 <shipped+0xb0>
  4077f0:	00 
  4077f1:	c5 f9 6f 2d 67 39 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x3967]        # 40b160 <shipped+0xc0>
  4077f8:	00 
  4077f9:	c4 e3 79 44 fa 11    	vpclmulhqhqdq xmm7,xmm0,xmm2
  4077ff:	c4 63 79 44 c2 00    	vpclmullqlqdq xmm8,xmm0,xmm2
  407805:	c5 e1 ef 87 a0 00 00 	vpxor  xmm0,xmm3,XMMWORD PTR [rdi+0xa0]
  40780c:	00 
  40780d:	c5 f9 7f 9c 24 b0 00 	vmovdqa XMMWORD PTR [rsp+0xb0],xmm3
  407814:	00 00 
  407816:	c5 d9 ef 97 b0 00 00 	vpxor  xmm2,xmm4,XMMWORD PTR [rdi+0xb0]
  40781d:	00 
  40781e:	c5 d1 ef 9f c0 00 00 	vpxor  xmm3,xmm5,XMMWORD PTR [rdi+0xc0]
  407825:	00 
  407826:	c5 f9 7f a4 24 a0 00 	vmovdqa XMMWORD PTR [rsp+0xa0],xmm4
  40782d:	00 00 
  40782f:	c5 f9 6f 25 39 39 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3939]        # 40b170 <shipped+0xd0>
  407836:	00 
  407837:	c5 f9 7f 6c 24 60    	vmovdqa XMMWORD PTR [rsp+0x60],xmm5
  40783d:	c4 63 79 44 fa 11    	vpclmulhqhqdq xmm15,xmm0,xmm2
  407843:	c4 63 79 44 ca 00    	vpclmullqlqdq xmm9,xmm0,xmm2
  407849:	c5 d9 ef 87 d0 00 00 	vpxor  xmm0,xmm4,XMMWORD PTR [rdi+0xd0]
  407850:	00 
  407851:	c5 f9 7f 64 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm4
  407857:	c5 f9 6f 25 21 39 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3921]        # 40b180 <shipped+0xe0>
  40785e:	00 
  40785f:	c5 d9 ef 97 e0 00 00 	vpxor  xmm2,xmm4,XMMWORD PTR [rdi+0xe0]
  407866:	00 
  407867:	c4 e3 61 44 e8 11    	vpclmulhqhqdq xmm5,xmm3,xmm0
  40786d:	c4 e3 61 44 d8 00    	vpclmullqlqdq xmm3,xmm3,xmm0
  407873:	c5 f9 7f a4 24 80 00 	vmovdqa XMMWORD PTR [rsp+0x80],xmm4
  40787a:	00 00 
  40787c:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  407880:	c5 f9 6f 25 08 39 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3908]        # 40b190 <shipped+0xf0>
  407887:	00 
  407888:	c5 d9 ef 87 f0 00 00 	vpxor  xmm0,xmm4,XMMWORD PTR [rdi+0xf0]
  40788f:	00 
  407890:	c4 c1 11 ef ee       	vpxor  xmm5,xmm13,xmm14
  407895:	c5 f9 7f a4 24 90 00 	vmovdqa XMMWORD PTR [rsp+0x90],xmm4
  40789c:	00 00 
  40789e:	c4 e3 69 44 e0 11    	vpclmulhqhqdq xmm4,xmm2,xmm0
  4078a4:	c4 e3 69 44 d0 00    	vpclmullqlqdq xmm2,xmm2,xmm0
  4078aa:	c4 c1 21 ef c4       	vpxor  xmm0,xmm11,xmm12
  4078af:	c5 c9 ef c0          	vpxor  xmm0,xmm6,xmm0
  4078b3:	c4 c1 41 ef f0       	vpxor  xmm6,xmm7,xmm8
  4078b8:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  4078bc:	c5 f9 ef c6          	vpxor  xmm0,xmm0,xmm6
  4078c0:	c5 f9 6f 74 24 10    	vmovdqa xmm6,XMMWORD PTR [rsp+0x10]
  4078c6:	c5 f9 ef db          	vpxor  xmm3,xmm0,xmm3
  4078ca:	c5 c9 ef 04 24       	vpxor  xmm0,xmm6,XMMWORD PTR [rsp]
  4078cf:	c5 d1 ef c0          	vpxor  xmm0,xmm5,xmm0
  4078d3:	c4 c1 01 ef e9       	vpxor  xmm5,xmm15,xmm9
  4078d8:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  4078dc:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  4078e0:	c5 e1 ef c0          	vpxor  xmm0,xmm3,xmm0
  4078e4:	c5 f9 ef 44 24 30    	vpxor  xmm0,xmm0,XMMWORD PTR [rsp+0x30]
  4078ea:	49 83 f8 01          	cmp    r8,0x1
  4078ee:	0f 86 84 04 00 00    	jbe    407d78 <chainhash_narrow.constprop.0+0x928>
  4078f4:	c5 f9 6f 1d 74 18 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x1874]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  4078fb:	00 
  4078fc:	c5 f9 6f 3d 7c 18 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x187c]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  407903:	00 
  407904:	4c 89 c1             	mov    rcx,r8
  407907:	48 8d 87 00 01 00 00 	lea    rax,[rdi+0x100]
  40790e:	48 c1 e1 08          	shl    rcx,0x8
  407912:	48 01 f9             	add    rcx,rdi
  407915:	c5 f9 7f 5c 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm3
  40791b:	c5 f9 7f 7c 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm7
  407921:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  407928:	c4 63 79 44 d9 01    	vpclmulhqlqdq xmm11,xmm0,xmm1
  40792e:	c5 f9 7f 04 24       	vmovdqa XMMWORD PTR [rsp],xmm0
  407933:	c5 f9 6f bc 24 50 01 	vmovdqa xmm7,XMMWORD PTR [rsp+0x150]
  40793a:	00 00 
  40793c:	c5 c1 ef 20          	vpxor  xmm4,xmm7,XMMWORD PTR [rax]
  407940:	c5 f9 6f bc 24 40 01 	vmovdqa xmm7,XMMWORD PTR [rsp+0x140]
  407947:	00 00 
  407949:	c5 c1 ef 40 10       	vpxor  xmm0,xmm7,XMMWORD PTR [rax+0x10]
  40794e:	48 05 00 01 00 00    	add    rax,0x100
  407954:	c5 f9 6f ac 24 30 01 	vmovdqa xmm5,XMMWORD PTR [rsp+0x130]
  40795b:	00 00 
  40795d:	c5 f9 6f b4 24 20 01 	vmovdqa xmm6,XMMWORD PTR [rsp+0x120]
  407964:	00 00 
  407966:	c4 e3 59 44 f8 11    	vpclmulhqhqdq xmm7,xmm4,xmm0
  40796c:	c5 c9 ef 88 30 ff ff 	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0xd0]
  407973:	ff 
  407974:	c4 e3 59 44 e0 00    	vpclmullqlqdq xmm4,xmm4,xmm0
  40797a:	c5 f9 6f b4 24 00 01 	vmovdqa xmm6,XMMWORD PTR [rsp+0x100]
  407981:	00 00 
  407983:	c5 d1 ef 80 20 ff ff 	vpxor  xmm0,xmm5,XMMWORD PTR [rax-0xe0]
  40798a:	ff 
  40798b:	c5 f9 7f 7c 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm7
  407991:	c5 f9 6f ac 24 10 01 	vmovdqa xmm5,XMMWORD PTR [rsp+0x110]
  407998:	00 00 
  40799a:	c5 d1 ef 98 40 ff ff 	vpxor  xmm3,xmm5,XMMWORD PTR [rax-0xc0]
  4079a1:	ff 
  4079a2:	c5 f9 6f ac 24 f0 00 	vmovdqa xmm5,XMMWORD PTR [rsp+0xf0]
  4079a9:	00 00 
  4079ab:	c4 63 79 44 f9 11    	vpclmulhqhqdq xmm15,xmm0,xmm1
  4079b1:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
  4079b7:	c5 c9 ef 88 50 ff ff 	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0xb0]
  4079be:	ff 
  4079bf:	c5 f9 6f b4 24 e0 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0xe0]
  4079c6:	00 00 
  4079c8:	c5 d1 ef 90 60 ff ff 	vpxor  xmm2,xmm5,XMMWORD PTR [rax-0xa0]
  4079cf:	ff 
  4079d0:	c4 c1 79 ef c7       	vpxor  xmm0,xmm0,xmm15
  4079d5:	c5 f9 6f ac 24 d0 00 	vmovdqa xmm5,XMMWORD PTR [rsp+0xd0]
  4079dc:	00 00 
  4079de:	c4 63 61 44 f1 11    	vpclmulhqhqdq xmm14,xmm3,xmm1
  4079e4:	c4 e3 61 44 d9 00    	vpclmullqlqdq xmm3,xmm3,xmm1
  4079ea:	c5 51 ef 40 80       	vpxor  xmm8,xmm5,XMMWORD PTR [rax-0x80]
  4079ef:	c5 c9 ef 88 70 ff ff 	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0x90]
  4079f6:	ff 
  4079f7:	c4 c1 61 ef de       	vpxor  xmm3,xmm3,xmm14
  4079fc:	c5 f9 6f b4 24 c0 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0xc0]
  407a03:	00 00 
  407a05:	c4 63 69 44 e9 11    	vpclmulhqhqdq xmm13,xmm2,xmm1
  407a0b:	c4 e3 69 44 d1 00    	vpclmullqlqdq xmm2,xmm2,xmm1
  407a11:	c5 c9 ef 48 90       	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0x70]
  407a16:	c5 f9 6f b4 24 b0 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0xb0]
  407a1d:	00 00 
  407a1f:	c5 c9 ef 78 a0       	vpxor  xmm7,xmm6,XMMWORD PTR [rax-0x60]
  407a24:	c4 c1 69 ef d5       	vpxor  xmm2,xmm2,xmm13
  407a29:	c5 f9 6f b4 24 a0 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0xa0]
  407a30:	00 00 
  407a32:	c4 e3 39 44 e9 11    	vpclmulhqhqdq xmm5,xmm8,xmm1
  407a38:	c4 63 39 44 c1 00    	vpclmullqlqdq xmm8,xmm8,xmm1
  407a3e:	c5 c9 ef 48 b0       	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0x50]
  407a43:	c5 f9 6f 74 24 60    	vmovdqa xmm6,XMMWORD PTR [rsp+0x60]
  407a49:	c4 c1 69 ef d0       	vpxor  xmm2,xmm2,xmm8
  407a4e:	c4 63 41 44 e1 11    	vpclmulhqhqdq xmm12,xmm7,xmm1
  407a54:	c4 e3 41 44 f9 00    	vpclmullqlqdq xmm7,xmm7,xmm1
  407a5a:	c5 c9 ef 48 c0       	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0x40]
  407a5f:	c5 f9 6f 74 24 70    	vmovdqa xmm6,XMMWORD PTR [rsp+0x70]
  407a65:	c5 c9 ef 70 d0       	vpxor  xmm6,xmm6,XMMWORD PTR [rax-0x30]
  407a6a:	c5 d1 ef ef          	vpxor  xmm5,xmm5,xmm7
  407a6e:	c4 c1 51 ef ec       	vpxor  xmm5,xmm5,xmm12
  407a73:	c4 63 71 44 ce 11    	vpclmulhqhqdq xmm9,xmm1,xmm6
  407a79:	c4 e3 71 44 ce 00    	vpclmullqlqdq xmm1,xmm1,xmm6
  407a7f:	c5 f9 6f b4 24 80 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0x80]
  407a86:	00 00 
  407a88:	c5 79 7f 4c 24 20    	vmovdqa XMMWORD PTR [rsp+0x20],xmm9
  407a8e:	c5 c9 ef 70 e0       	vpxor  xmm6,xmm6,XMMWORD PTR [rax-0x20]
  407a93:	c5 d9 ef 64 24 10    	vpxor  xmm4,xmm4,XMMWORD PTR [rsp+0x10]
  407a99:	c5 e1 ef 5c 24 30    	vpxor  xmm3,xmm3,XMMWORD PTR [rsp+0x30]
  407a9f:	c5 f1 ef 4c 24 20    	vpxor  xmm1,xmm1,XMMWORD PTR [rsp+0x20]
  407aa5:	c5 79 6f 8c 24 90 00 	vmovdqa xmm9,XMMWORD PTR [rsp+0x90]
  407aac:	00 00 
  407aae:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
  407ab2:	c5 31 ef 48 f0       	vpxor  xmm9,xmm9,XMMWORD PTR [rax-0x10]
  407ab7:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  407abb:	c5 f9 6f 7c 24 50    	vmovdqa xmm7,XMMWORD PTR [rsp+0x50]
  407ac1:	c4 43 49 44 d1 11    	vpclmulhqhqdq xmm10,xmm6,xmm9
  407ac7:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  407acb:	c4 c3 49 44 f1 00    	vpclmullqlqdq xmm6,xmm6,xmm9
  407ad1:	c5 f1 ef ce          	vpxor  xmm1,xmm1,xmm6
  407ad5:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  407ad9:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  407add:	c4 e3 21 44 4c 24 40 	vpclmulhqlqdq xmm1,xmm11,XMMWORD PTR [rsp+0x40]
  407ae4:	01 
  407ae5:	c5 e9 73 d9 08       	vpsrldq xmm2,xmm1,0x8
  407aea:	c4 c1 79 ef c2       	vpxor  xmm0,xmm0,xmm10
  407aef:	c4 e2 41 00 d2       	vpshufb xmm2,xmm7,xmm2
  407af4:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  407af8:	c5 a1 ef 14 24       	vpxor  xmm2,xmm11,XMMWORD PTR [rsp]
  407afd:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  407b01:	48 39 c1             	cmp    rcx,rax
  407b04:	0f 85 1e fe ff ff    	jne    407928 <chainhash_narrow.constprop.0+0x4d8>
  407b0a:	c4 e3 79 44 c9 01    	vpclmulhqlqdq xmm1,xmm0,xmm1
  407b10:	c5 f9 6f 7c 24 50    	vmovdqa xmm7,XMMWORD PTR [rsp+0x50]
  407b16:	c4 e3 71 44 54 24 40 	vpclmulhqlqdq xmm2,xmm1,XMMWORD PTR [rsp+0x40]
  407b1d:	01 
  407b1e:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  407b22:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  407b27:	c4 e2 41 00 db       	vpshufb xmm3,xmm7,xmm3
  407b2c:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  407b30:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  407b34:	e9 7d f9 ff ff       	jmp    4074b6 <chainhash_narrow.constprop.0+0x66>
  407b39:	c5 fa 6f 19          	vmovdqu xmm3,XMMWORD PTR [rcx]
  407b3d:	c5 fa 6f 79 10       	vmovdqu xmm7,XMMWORD PTR [rcx+0x10]
  407b42:	c5 e1 ef 05 56 35 00 	vpxor  xmm0,xmm3,XMMWORD PTR [rip+0x3556]        # 40b0a0 <shipped>
  407b49:	00 
  407b4a:	c5 c1 ef 15 5e 35 00 	vpxor  xmm2,xmm7,XMMWORD PTR [rip+0x355e]        # 40b0b0 <shipped+0x10>
  407b51:	00 
  407b52:	c5 fa 6f 59 20       	vmovdqu xmm3,XMMWORD PTR [rcx+0x20]
  407b57:	c5 fa 6f 79 30       	vmovdqu xmm7,XMMWORD PTR [rcx+0x30]
  407b5c:	c5 e1 ef 1d 5c 35 00 	vpxor  xmm3,xmm3,XMMWORD PTR [rip+0x355c]        # 40b0c0 <shipped+0x20>
  407b63:	00 
  407b64:	c4 63 79 44 e2 11    	vpclmulhqhqdq xmm12,xmm0,xmm2
  407b6a:	c5 fa 6f 69 40       	vmovdqu xmm5,XMMWORD PTR [rcx+0x40]
  407b6f:	c4 e3 79 44 c2 00    	vpclmullqlqdq xmm0,xmm0,xmm2
  407b75:	c5 c1 ef 15 53 35 00 	vpxor  xmm2,xmm7,XMMWORD PTR [rip+0x3553]        # 40b0d0 <shipped+0x30>
  407b7c:	00 
  407b7d:	c5 fa 6f 79 50       	vmovdqu xmm7,XMMWORD PTR [rcx+0x50]
  407b82:	c4 c1 79 ef c4       	vpxor  xmm0,xmm0,xmm12
  407b87:	c5 c1 ef 25 61 35 00 	vpxor  xmm4,xmm7,XMMWORD PTR [rip+0x3561]        # 40b0f0 <shipped+0x50>
  407b8e:	00 
  407b8f:	c5 fa 6f 79 70       	vmovdqu xmm7,XMMWORD PTR [rcx+0x70]
  407b94:	c4 63 61 44 da 11    	vpclmulhqhqdq xmm11,xmm3,xmm2
  407b9a:	c4 e3 61 44 da 00    	vpclmullqlqdq xmm3,xmm3,xmm2
  407ba0:	c5 d1 ef 15 38 35 00 	vpxor  xmm2,xmm5,XMMWORD PTR [rip+0x3538]        # 40b0e0 <shipped+0x40>
  407ba7:	00 
  407ba8:	c5 fa 6f 69 60       	vmovdqu xmm5,XMMWORD PTR [rcx+0x60]
  407bad:	c5 d1 ef 35 4b 35 00 	vpxor  xmm6,xmm5,XMMWORD PTR [rip+0x354b]        # 40b100 <shipped+0x60>
  407bb4:	00 
  407bb5:	c5 fa 6f a9 80 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0x80]
  407bbc:	00 
  407bbd:	c4 c1 61 ef db       	vpxor  xmm3,xmm3,xmm11
  407bc2:	c4 63 69 44 d4 11    	vpclmulhqhqdq xmm10,xmm2,xmm4
  407bc8:	c4 e3 69 44 d4 00    	vpclmullqlqdq xmm2,xmm2,xmm4
  407bce:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  407bd2:	c5 c1 ef 25 36 35 00 	vpxor  xmm4,xmm7,XMMWORD PTR [rip+0x3536]        # 40b110 <shipped+0x70>
  407bd9:	00 
  407bda:	c4 c1 69 ef d2       	vpxor  xmm2,xmm2,xmm10
  407bdf:	c4 e3 49 44 fc 11    	vpclmulhqhqdq xmm7,xmm6,xmm4
  407be5:	c4 e3 49 44 f4 00    	vpclmullqlqdq xmm6,xmm6,xmm4
  407beb:	c5 d1 ef 25 2d 35 00 	vpxor  xmm4,xmm5,XMMWORD PTR [rip+0x352d]        # 40b120 <shipped+0x80>
  407bf2:	00 
  407bf3:	c5 fa 6f a9 90 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0x90]
  407bfa:	00 
  407bfb:	c5 d1 ef 2d 2d 35 00 	vpxor  xmm5,xmm5,XMMWORD PTR [rip+0x352d]        # 40b130 <shipped+0x90>
  407c02:	00 
  407c03:	c5 e9 ef d6          	vpxor  xmm2,xmm2,xmm6
  407c07:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  407c0b:	c4 63 59 44 f5 11    	vpclmulhqhqdq xmm14,xmm4,xmm5
  407c11:	c4 63 59 44 ed 00    	vpclmullqlqdq xmm13,xmm4,xmm5
  407c17:	c5 fa 6f a9 a0 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0xa0]
  407c1e:	00 
  407c1f:	c5 d1 ef 25 19 35 00 	vpxor  xmm4,xmm5,XMMWORD PTR [rip+0x3519]        # 40b140 <shipped+0xa0>
  407c26:	00 
  407c27:	c5 fa 6f a9 b0 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0xb0]
  407c2e:	00 
  407c2f:	c5 d1 ef 2d 19 35 00 	vpxor  xmm5,xmm5,XMMWORD PTR [rip+0x3519]        # 40b150 <shipped+0xb0>
  407c36:	00 
  407c37:	c4 c1 41 ef d5       	vpxor  xmm2,xmm7,xmm13
  407c3c:	c4 c1 69 ef d6       	vpxor  xmm2,xmm2,xmm14
  407c41:	c4 63 59 44 fd 11    	vpclmulhqhqdq xmm15,xmm4,xmm5
  407c47:	c5 f9 ef d2          	vpxor  xmm2,xmm0,xmm2
  407c4b:	c5 79 7f 3c 24       	vmovdqa XMMWORD PTR [rsp],xmm15
  407c50:	c4 63 59 44 fd 00    	vpclmullqlqdq xmm15,xmm4,xmm5
  407c56:	c5 fa 6f a9 c0 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0xc0]
  407c5d:	00 
  407c5e:	c5 fa 6f a1 d0 00 00 	vmovdqu xmm4,XMMWORD PTR [rcx+0xd0]
  407c65:	00 
  407c66:	c5 d1 ef 2d f2 34 00 	vpxor  xmm5,xmm5,XMMWORD PTR [rip+0x34f2]        # 40b160 <shipped+0xc0>
  407c6d:	00 
  407c6e:	c5 d9 ef 25 fa 34 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rip+0x34fa]        # 40b170 <shipped+0xd0>
  407c75:	00 
  407c76:	c4 63 51 44 c4 11    	vpclmulhqhqdq xmm8,xmm5,xmm4
  407c7c:	c4 e3 51 44 ec 00    	vpclmullqlqdq xmm5,xmm5,xmm4
  407c82:	c5 fa 6f a1 e0 00 00 	vmovdqu xmm4,XMMWORD PTR [rcx+0xe0]
  407c89:	00 
  407c8a:	c5 d9 ef 25 ee 34 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rip+0x34ee]        # 40b180 <shipped+0xe0>
  407c91:	00 
  407c92:	c5 79 7f 44 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm8
  407c98:	c5 7a 6f 81 f0 00 00 	vmovdqu xmm8,XMMWORD PTR [rcx+0xf0]
  407c9f:	00 
  407ca0:	c5 81 ef 04 24       	vpxor  xmm0,xmm15,XMMWORD PTR [rsp]
  407ca5:	c5 39 ef 05 e3 34 00 	vpxor  xmm8,xmm8,XMMWORD PTR [rip+0x34e3]        # 40b190 <shipped+0xf0>
  407cac:	00 
  407cad:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  407cb1:	c4 43 59 44 c8 11    	vpclmulhqhqdq xmm9,xmm4,xmm8
  407cb7:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  407cbb:	c4 c3 59 44 e0 00    	vpclmullqlqdq xmm4,xmm4,xmm8
  407cc1:	c5 d9 ef 44 24 10    	vpxor  xmm0,xmm4,XMMWORD PTR [rsp+0x10]
  407cc7:	c4 c1 79 ef c1       	vpxor  xmm0,xmm0,xmm9
  407ccc:	c5 e9 ef d8          	vpxor  xmm3,xmm2,xmm0
  407cd0:	e9 e6 f8 ff ff       	jmp    4075bb <chainhash_narrow.constprop.0+0x16b>
  407cd5:	48 89 f2             	mov    rdx,rsi
  407cd8:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  407cdc:	4a 8d 34 21          	lea    rsi,[rcx+r12*1]
  407ce0:	c5 f9 7f 44 24 20    	vmovdqa XMMWORD PTR [rsp+0x20],xmm0
  407ce6:	4c 29 e2             	sub    rdx,r12
  407ce9:	48 8d bc 24 60 01 00 	lea    rdi,[rsp+0x160]
  407cf0:	00 
  407cf1:	c5 f9 7f 54 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm2
  407cf7:	c5 f9 7f 0c 24       	vmovdqa XMMWORD PTR [rsp],xmm1
  407cfc:	c5 f9 7f 9c 24 60 01 	vmovdqa XMMWORD PTR [rsp+0x160],xmm3
  407d03:	00 00 
  407d05:	c5 f9 7f 9c 24 70 01 	vmovdqa XMMWORD PTR [rsp+0x170],xmm3
  407d0c:	00 00 
  407d0e:	e8 5d 93 ff ff       	call   401070 <memcpy@plt>
  407d13:	c5 f9 6f 44 24 20    	vmovdqa xmm0,XMMWORD PTR [rsp+0x20]
  407d19:	c5 f9 6f 54 24 10    	vmovdqa xmm2,XMMWORD PTR [rsp+0x10]
  407d1f:	c5 f9 6f 9c 24 60 01 	vmovdqa xmm3,XMMWORD PTR [rsp+0x160]
  407d26:	00 00 
  407d28:	c5 f9 6f 0c 24       	vmovdqa xmm1,XMMWORD PTR [rsp]
  407d2d:	c4 c1 61 ef 9c 24 a0 	vpxor  xmm3,xmm3,XMMWORD PTR [r12+0x40b0a0]
  407d34:	b0 40 00 
  407d37:	c5 f9 6f bc 24 70 01 	vmovdqa xmm7,XMMWORD PTR [rsp+0x170]
  407d3e:	00 00 
  407d40:	c4 c1 41 ef a4 24 b0 	vpxor  xmm4,xmm7,XMMWORD PTR [r12+0x40b0b0]
  407d47:	b0 40 00 
  407d4a:	c4 e3 61 44 ec 11    	vpclmulhqhqdq xmm5,xmm3,xmm4
  407d50:	c4 e3 61 44 dc 00    	vpclmullqlqdq xmm3,xmm3,xmm4
  407d56:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  407d5a:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  407d5e:	e9 54 f8 ff ff       	jmp    4075b7 <chainhash_narrow.constprop.0+0x167>
  407d63:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  407d67:	b8 20 00 00 00       	mov    eax,0x20
  407d6c:	45 31 e4             	xor    r12d,r12d
  407d6f:	c5 f9 6f d0          	vmovdqa xmm2,xmm0
  407d73:	e9 f9 f7 ff ff       	jmp    407571 <chainhash_narrow.constprop.0+0x121>
  407d78:	c5 f9 6f 1d f0 13 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x13f0]        # 409170 <__PRETTY_FUNCTION__.6+0x20>
  407d7f:	00 
  407d80:	c5 f9 7f 5c 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm3
  407d86:	c5 f9 6f 1d f2 13 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x13f2]        # 409180 <__PRETTY_FUNCTION__.6+0x30>
  407d8d:	00 
  407d8e:	c5 f9 7f 5c 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm3
  407d94:	e9 71 fd ff ff       	jmp    407b0a <chainhash_narrow.constprop.0+0x6ba>
  407d99:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000407da0 <ship>:
  407da0:	55                   	push   rbp
  407da1:	53                   	push   rbx
  407da2:	48 81 ec 68 01 00 00 	sub    rsp,0x168
  407da9:	48 81 fe 00 01 00 00 	cmp    rsi,0x100
  407db0:	0f 87 ec 02 00 00    	ja     4080a2 <ship+0x302>
  407db6:	48 8b 2d e3 33 00 00 	mov    rbp,QWORD PTR [rip+0x33e3]        # 40b1a0 <shipped+0x100>
  407dbd:	48 89 f2             	mov    rdx,rsi
  407dc0:	48 89 f9             	mov    rcx,rdi
  407dc3:	48 8b 05 e6 33 00 00 	mov    rax,QWORD PTR [rip+0x33e6]        # 40b1b0 <shipped+0x110>
  407dca:	66 0f 6f 3d ce 33 00 	movdqa xmm7,XMMWORD PTR [rip+0x33ce]        # 40b1a0 <shipped+0x100>
  407dd1:	00 
  407dd2:	66 44 0f 6f 15 b5 13 	movdqa xmm10,XMMWORD PTR [rip+0x13b5]        # 409190 <__PRETTY_FUNCTION__.6+0x40>
  407dd9:	00 00 
  407ddb:	48 31 e8             	xor    rax,rbp
  407dde:	66 4c 0f 6e d8       	movq   xmm11,rax
  407de3:	0f 29 7c 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm7
  407de8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
  407def:	00 
  407df0:	66 48 0f 6e ee       	movq   xmm5,rsi
  407df5:	66 0f 6c ed          	punpcklqdq xmm5,xmm5
  407df9:	48 83 fa 3f          	cmp    rdx,0x3f
  407dfd:	0f 86 e8 06 00 00    	jbe    4084eb <ship+0x74b>
  407e03:	66 0f ef e4          	pxor   xmm4,xmm4
  407e07:	b8 40 00 00 00       	mov    eax,0x40
  407e0c:	66 0f 6f dc          	movdqa xmm3,xmm4
  407e10:	f3 0f 6f 44 01 c0    	movdqu xmm0,XMMWORD PTR [rcx+rax*1-0x40]
  407e16:	f3 0f 6f 54 01 d0    	movdqu xmm2,XMMWORD PTR [rcx+rax*1-0x30]
  407e1c:	48 89 c3             	mov    rbx,rax
  407e1f:	66 0f ef 90 70 b0 40 	pxor   xmm2,XMMWORD PTR [rax+0x40b070]
  407e26:	00 
  407e27:	66 0f ef 80 60 b0 40 	pxor   xmm0,XMMWORD PTR [rax+0x40b060]
  407e2e:	00 
  407e2f:	66 0f 6f f0          	movdqa xmm6,xmm0
  407e33:	66 0f 3a 44 c2 00    	pclmullqlqdq xmm0,xmm2
  407e39:	66 0f 6f c8          	movdqa xmm1,xmm0
  407e3d:	f3 0f 6f 44 01 e0    	movdqu xmm0,XMMWORD PTR [rcx+rax*1-0x20]
  407e43:	66 0f 3a 44 f2 11    	pclmulhqhqdq xmm6,xmm2
  407e49:	66 0f ef 80 80 b0 40 	pxor   xmm0,XMMWORD PTR [rax+0x40b080]
  407e50:	00 
  407e51:	f3 0f 6f 54 01 f0    	movdqu xmm2,XMMWORD PTR [rcx+rax*1-0x10]
  407e57:	66 0f ef ce          	pxor   xmm1,xmm6
  407e5b:	48 8d 40 40          	lea    rax,[rax+0x40]
  407e5f:	66 0f ef 90 50 b0 40 	pxor   xmm2,XMMWORD PTR [rax+0x40b050]
  407e66:	00 
  407e67:	66 0f 6f f0          	movdqa xmm6,xmm0
  407e6b:	66 0f ef cb          	pxor   xmm1,xmm3
  407e6f:	66 0f 3a 44 f2 11    	pclmulhqhqdq xmm6,xmm2
  407e75:	66 0f 3a 44 c2 00    	pclmullqlqdq xmm0,xmm2
  407e7b:	66 0f 6f d9          	movdqa xmm3,xmm1
  407e7f:	66 0f ef c6          	pxor   xmm0,xmm6
  407e83:	66 0f ef c4          	pxor   xmm0,xmm4
  407e87:	66 0f 6f e0          	movdqa xmm4,xmm0
  407e8b:	48 39 c2             	cmp    rdx,rax
  407e8e:	73 80                	jae    407e10 <ship+0x70>
  407e90:	48 8d 43 20          	lea    rax,[rbx+0x20]
  407e94:	48 39 c2             	cmp    rdx,rax
  407e97:	0f 83 24 01 00 00    	jae    407fc1 <ship+0x221>
  407e9d:	48 39 da             	cmp    rdx,rbx
  407ea0:	0f 87 5c 01 00 00    	ja     408002 <ship+0x262>
  407ea6:	66 48 0f 6e d5       	movq   xmm2,rbp
  407eab:	66 0f ef 6c 24 30    	pxor   xmm5,XMMWORD PTR [rsp+0x30]
  407eb1:	48 8b 05 00 33 00 00 	mov    rax,QWORD PTR [rip+0x3300]        # 40b1b8 <shipped+0x118>
  407eb8:	66 0f ef ca          	pxor   xmm1,xmm2
  407ebc:	66 0f ef e9          	pxor   xmm5,xmm1
  407ec0:	66 0f ef e8          	pxor   xmm5,xmm0
  407ec4:	66 0f 6f cd          	movdqa xmm1,xmm5
  407ec8:	66 41 0f 3a 44 cb 01 	pclmulhqlqdq xmm1,xmm11
  407ecf:	66 0f 6f c1          	movdqa xmm0,xmm1
  407ed3:	66 0f ef cd          	pxor   xmm1,xmm5
  407ed7:	66 41 0f 3a 44 c2 11 	pclmulhqhqdq xmm0,xmm10
  407ede:	66 0f 6f d0          	movdqa xmm2,xmm0
  407ee2:	66 41 0f 3a 44 d2 11 	pclmulhqhqdq xmm2,xmm10
  407ee9:	66 0f ef c2          	pxor   xmm0,xmm2
  407eed:	66 0f ef c8          	pxor   xmm1,xmm0
  407ef1:	f3 0f 7e 05 e7 32 00 	movq   xmm0,QWORD PTR [rip+0x32e7]        # 40b1e0 <shipped+0x140>
  407ef8:	00 
  407ef9:	66 0f d4 c8          	paddq  xmm1,xmm0
  407efd:	66 0f 6f c1          	movdqa xmm0,xmm1
  407f01:	66 0f 3a 44 c1 00    	pclmullqlqdq xmm0,xmm1
  407f07:	66 0f 6f d0          	movdqa xmm2,xmm0
  407f0b:	66 41 0f 3a 44 d2 11 	pclmulhqhqdq xmm2,xmm10
  407f12:	66 0f 6f da          	movdqa xmm3,xmm2
  407f16:	66 0f ef c2          	pxor   xmm0,xmm2
  407f1a:	66 48 0f 6e d0       	movq   xmm2,rax
  407f1f:	48 33 05 9a 32 00 00 	xor    rax,QWORD PTR [rip+0x329a]        # 40b1c0 <shipped+0x120>
  407f26:	66 41 0f 3a 44 da 11 	pclmulhqhqdq xmm3,xmm10
  407f2d:	66 0f ef d3          	pxor   xmm2,xmm3
  407f31:	66 0f ef c2          	pxor   xmm0,xmm2
  407f35:	66 48 0f 6e d0       	movq   xmm2,rax
  407f3a:	66 0f ef d0          	pxor   xmm2,xmm0
  407f3e:	66 0f ef d1          	pxor   xmm2,xmm1
  407f42:	66 0f 3a 44 c2 00    	pclmullqlqdq xmm0,xmm2
  407f48:	f3 0f 7e 15 78 32 00 	movq   xmm2,QWORD PTR [rip+0x3278]        # 40b1c8 <shipped+0x128>
  407f4f:	00 
  407f50:	66 0f 6f d8          	movdqa xmm3,xmm0
  407f54:	66 41 0f 3a 44 da 11 	pclmulhqhqdq xmm3,xmm10
  407f5b:	66 0f ef ca          	pxor   xmm1,xmm2
  407f5f:	f3 0f 7e 15 69 32 00 	movq   xmm2,QWORD PTR [rip+0x3269]        # 40b1d0 <shipped+0x130>
  407f66:	00 
  407f67:	66 0f 6f e3          	movdqa xmm4,xmm3
  407f6b:	66 0f ef c3          	pxor   xmm0,xmm3
  407f6f:	66 41 0f 3a 44 e2 11 	pclmulhqhqdq xmm4,xmm10
  407f76:	66 0f ef d4          	pxor   xmm2,xmm4
  407f7a:	66 0f ef d0          	pxor   xmm2,xmm0
  407f7e:	66 0f 3a 44 ca 00    	pclmullqlqdq xmm1,xmm2
  407f84:	66 0f 6f d1          	movdqa xmm2,xmm1
  407f88:	66 0f 6f c1          	movdqa xmm0,xmm1
  407f8c:	f3 0f 7e 0d 44 32 00 	movq   xmm1,QWORD PTR [rip+0x3244]        # 40b1d8 <shipped+0x138>
  407f93:	00 
  407f94:	48 81 c4 68 01 00 00 	add    rsp,0x168
  407f9b:	66 41 0f 3a 44 d2 11 	pclmulhqhqdq xmm2,xmm10
  407fa2:	5b                   	pop    rbx
  407fa3:	5d                   	pop    rbp
  407fa4:	66 0f 6f da          	movdqa xmm3,xmm2
  407fa8:	66 0f ef c2          	pxor   xmm0,xmm2
  407fac:	66 41 0f 3a 44 da 11 	pclmulhqhqdq xmm3,xmm10
  407fb3:	66 0f ef cb          	pxor   xmm1,xmm3
  407fb7:	66 0f ef c1          	pxor   xmm0,xmm1
  407fbb:	66 48 0f 7e c0       	movq   rax,xmm0
  407fc0:	c3                   	ret    
  407fc1:	48 8d 34 19          	lea    rsi,[rcx+rbx*1]
  407fc5:	f3 0f 6f 16          	movdqu xmm2,XMMWORD PTR [rsi]
  407fc9:	66 0f ef 93 a0 b0 40 	pxor   xmm2,XMMWORD PTR [rbx+0x40b0a0]
  407fd0:	00 
  407fd1:	f3 0f 6f 5e 10       	movdqu xmm3,XMMWORD PTR [rsi+0x10]
  407fd6:	66 0f ef 9b b0 b0 40 	pxor   xmm3,XMMWORD PTR [rbx+0x40b0b0]
  407fdd:	00 
  407fde:	48 89 c3             	mov    rbx,rax
  407fe1:	66 0f 6f e2          	movdqa xmm4,xmm2
  407fe5:	66 0f 3a 44 e3 11    	pclmulhqhqdq xmm4,xmm3
  407feb:	66 0f 3a 44 d3 00    	pclmullqlqdq xmm2,xmm3
  407ff1:	66 0f ef d4          	pxor   xmm2,xmm4
  407ff5:	66 0f ef ca          	pxor   xmm1,xmm2
  407ff9:	48 39 da             	cmp    rdx,rbx
  407ffc:	0f 86 a4 fe ff ff    	jbe    407ea6 <ship+0x106>
  408002:	66 0f ef d2          	pxor   xmm2,xmm2
  408006:	48 29 da             	sub    rdx,rbx
  408009:	48 8d 34 19          	lea    rsi,[rcx+rbx*1]
  40800d:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
  408012:	48 8d bc 24 40 01 00 	lea    rdi,[rsp+0x140]
  408019:	00 
  40801a:	44 0f 29 54 24 50    	movaps XMMWORD PTR [rsp+0x50],xmm10
  408020:	0f 29 4c 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm1
  408025:	0f 29 6c 24 10       	movaps XMMWORD PTR [rsp+0x10],xmm5
  40802a:	44 0f 29 1c 24       	movaps XMMWORD PTR [rsp],xmm11
  40802f:	0f 29 94 24 40 01 00 	movaps XMMWORD PTR [rsp+0x140],xmm2
  408036:	00 
  408037:	0f 29 94 24 50 01 00 	movaps XMMWORD PTR [rsp+0x150],xmm2
  40803e:	00 
  40803f:	e8 2c 90 ff ff       	call   401070 <memcpy@plt>
  408044:	66 0f 6f 44 24 40    	movdqa xmm0,XMMWORD PTR [rsp+0x40]
  40804a:	66 0f 6f 94 24 40 01 	movdqa xmm2,XMMWORD PTR [rsp+0x140]
  408051:	00 00 
  408053:	66 0f ef 93 a0 b0 40 	pxor   xmm2,XMMWORD PTR [rbx+0x40b0a0]
  40805a:	00 
  40805b:	66 44 0f 6f 54 24 50 	movdqa xmm10,XMMWORD PTR [rsp+0x50]
  408062:	66 0f 6f 9c 24 50 01 	movdqa xmm3,XMMWORD PTR [rsp+0x150]
  408069:	00 00 
  40806b:	66 0f ef 9b b0 b0 40 	pxor   xmm3,XMMWORD PTR [rbx+0x40b0b0]
  408072:	00 
  408073:	66 0f 6f e2          	movdqa xmm4,xmm2
  408077:	66 0f 6f 4c 24 20    	movdqa xmm1,XMMWORD PTR [rsp+0x20]
  40807d:	66 0f 6f 6c 24 10    	movdqa xmm5,XMMWORD PTR [rsp+0x10]
  408083:	66 0f 3a 44 e3 11    	pclmulhqhqdq xmm4,xmm3
  408089:	66 0f 3a 44 d3 00    	pclmullqlqdq xmm2,xmm3
  40808f:	66 44 0f 6f 1c 24    	movdqa xmm11,XMMWORD PTR [rsp]
  408095:	66 0f ef d4          	pxor   xmm2,xmm4
  408099:	66 0f ef c2          	pxor   xmm0,xmm2
  40809d:	e9 04 fe ff ff       	jmp    407ea6 <ship+0x106>
  4080a2:	44 8b 05 db 2f 00 00 	mov    r8d,DWORD PTR [rip+0x2fdb]        # 40b084 <cached.1>
  4080a9:	45 85 c0             	test   r8d,r8d
  4080ac:	0f 84 79 03 00 00    	je     40842b <ship+0x68b>
  4080b2:	41 83 e8 01          	sub    r8d,0x1
  4080b6:	0f 85 e8 03 00 00    	jne    4084a4 <ship+0x704>
  4080bc:	66 0f 6f 3d dc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fdc]        # 40b0a0 <shipped>
  4080c3:	00 
  4080c4:	48 8b 2d d5 30 00 00 	mov    rbp,QWORD PTR [rip+0x30d5]        # 40b1a0 <shipped+0x100>
  4080cb:	48 8b 05 de 30 00 00 	mov    rax,QWORD PTR [rip+0x30de]        # 40b1b0 <shipped+0x110>
  4080d2:	0f 29 7c 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm7
  4080d7:	66 0f 6f 3d d1 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fd1]        # 40b0b0 <shipped+0x10>
  4080de:	00 
  4080df:	48 31 e8             	xor    rax,rbp
  4080e2:	0f 29 7c 24 50       	movaps XMMWORD PTR [rsp+0x50],xmm7
  4080e7:	66 0f 6f 3d d1 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fd1]        # 40b0c0 <shipped+0x20>
  4080ee:	00 
  4080ef:	66 4c 0f 6e d8       	movq   xmm11,rax
  4080f4:	48 8d 86 ff fe ff ff 	lea    rax,[rsi-0x101]
  4080fb:	48 c1 e8 08          	shr    rax,0x8
  4080ff:	0f 29 7c 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm7
  408104:	66 0f 6f 3d c4 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fc4]        # 40b0d0 <shipped+0x30>
  40810b:	00 
  40810c:	48 8d 48 01          	lea    rcx,[rax+0x1]
  408110:	48 c1 e1 08          	shl    rcx,0x8
  408114:	0f 29 7c 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm7
  408119:	66 0f 6f 3d bf 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbf]        # 40b0e0 <shipped+0x40>
  408120:	00 
  408121:	48 01 f9             	add    rcx,rdi
  408124:	0f 29 bc 24 80 00 00 	movaps XMMWORD PTR [rsp+0x80],xmm7
  40812b:	00 
  40812c:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b0f0 <shipped+0x50>
  408133:	00 
  408134:	0f 29 bc 24 90 00 00 	movaps XMMWORD PTR [rsp+0x90],xmm7
  40813b:	00 
  40813c:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b100 <shipped+0x60>
  408143:	00 
  408144:	0f 29 bc 24 a0 00 00 	movaps XMMWORD PTR [rsp+0xa0],xmm7
  40814b:	00 
  40814c:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b110 <shipped+0x70>
  408153:	00 
  408154:	0f 29 bc 24 b0 00 00 	movaps XMMWORD PTR [rsp+0xb0],xmm7
  40815b:	00 
  40815c:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b120 <shipped+0x80>
  408163:	00 
  408164:	0f 29 bc 24 c0 00 00 	movaps XMMWORD PTR [rsp+0xc0],xmm7
  40816b:	00 
  40816c:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b130 <shipped+0x90>
  408173:	00 
  408174:	0f 29 bc 24 d0 00 00 	movaps XMMWORD PTR [rsp+0xd0],xmm7
  40817b:	00 
  40817c:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b140 <shipped+0xa0>
  408183:	00 
  408184:	0f 29 bc 24 e0 00 00 	movaps XMMWORD PTR [rsp+0xe0],xmm7
  40818b:	00 
  40818c:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b150 <shipped+0xb0>
  408193:	00 
  408194:	0f 29 bc 24 f0 00 00 	movaps XMMWORD PTR [rsp+0xf0],xmm7
  40819b:	00 
  40819c:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b160 <shipped+0xc0>
  4081a3:	00 
  4081a4:	0f 29 bc 24 00 01 00 	movaps XMMWORD PTR [rsp+0x100],xmm7
  4081ab:	00 
  4081ac:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b170 <shipped+0xd0>
  4081b3:	00 
  4081b4:	0f 29 bc 24 10 01 00 	movaps XMMWORD PTR [rsp+0x110],xmm7
  4081bb:	00 
  4081bc:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b180 <shipped+0xe0>
  4081c3:	00 
  4081c4:	0f 29 bc 24 20 01 00 	movaps XMMWORD PTR [rsp+0x120],xmm7
  4081cb:	00 
  4081cc:	66 0f 6f 3d bc 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fbc]        # 40b190 <shipped+0xf0>
  4081d3:	00 
  4081d4:	66 44 0f 6f 15 b3 0f 	movdqa xmm10,XMMWORD PTR [rip+0xfb3]        # 409190 <__PRETTY_FUNCTION__.6+0x40>
  4081db:	00 00 
  4081dd:	0f 29 bc 24 30 01 00 	movaps XMMWORD PTR [rsp+0x130],xmm7
  4081e4:	00 
  4081e5:	66 0f 6f 3d b3 2f 00 	movdqa xmm7,XMMWORD PTR [rip+0x2fb3]        # 40b1a0 <shipped+0x100>
  4081ec:	00 
  4081ed:	0f 29 7c 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm7
  4081f2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  4081f8:	f3 0f 6f 0f          	movdqu xmm1,XMMWORD PTR [rdi]
  4081fc:	66 0f ef 4c 24 40    	pxor   xmm1,XMMWORD PTR [rsp+0x40]
  408202:	48 81 c7 00 01 00 00 	add    rdi,0x100
  408209:	f3 0f 6f 87 10 ff ff 	movdqu xmm0,XMMWORD PTR [rdi-0xf0]
  408210:	ff 
  408211:	66 0f ef 44 24 50    	pxor   xmm0,XMMWORD PTR [rsp+0x50]
  408217:	66 0f 6f f9          	movdqa xmm7,xmm1
  40821b:	f3 0f 6f af 30 ff ff 	movdqu xmm5,XMMWORD PTR [rdi-0xd0]
  408222:	ff 
  408223:	66 0f ef 6c 24 70    	pxor   xmm5,XMMWORD PTR [rsp+0x70]
  408229:	66 0f 3a 44 f8 11    	pclmulhqhqdq xmm7,xmm0
  40822f:	66 0f 3a 44 c8 00    	pclmullqlqdq xmm1,xmm0
  408235:	f3 0f 6f 87 20 ff ff 	movdqu xmm0,XMMWORD PTR [rdi-0xe0]
  40823c:	ff 
  40823d:	66 0f ef 44 24 60    	pxor   xmm0,XMMWORD PTR [rsp+0x60]
  408243:	f3 0f 6f 9f 40 ff ff 	movdqu xmm3,XMMWORD PTR [rdi-0xc0]
  40824a:	ff 
  40824b:	f3 0f 6f 97 60 ff ff 	movdqu xmm2,XMMWORD PTR [rdi-0xa0]
  408252:	ff 
  408253:	0f 29 3c 24          	movaps XMMWORD PTR [rsp],xmm7
  408257:	66 0f ef 9c 24 80 00 	pxor   xmm3,XMMWORD PTR [rsp+0x80]
  40825e:	00 00 
  408260:	66 0f 6f f0          	movdqa xmm6,xmm0
  408264:	66 0f 3a 44 c5 00    	pclmullqlqdq xmm0,xmm5
  40826a:	f3 0f 6f a7 70 ff ff 	movdqu xmm4,XMMWORD PTR [rdi-0x90]
  408271:	ff 
  408272:	66 0f 3a 44 f5 11    	pclmulhqhqdq xmm6,xmm5
  408278:	f3 0f 6f af 50 ff ff 	movdqu xmm5,XMMWORD PTR [rdi-0xb0]
  40827f:	ff 
  408280:	0f 29 4c 24 10       	movaps XMMWORD PTR [rsp+0x10],xmm1
  408285:	66 0f ef ac 24 90 00 	pxor   xmm5,XMMWORD PTR [rsp+0x90]
  40828c:	00 00 
  40828e:	0f 29 74 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm6
  408293:	66 44 0f 6f fb       	movdqa xmm15,xmm3
  408298:	f3 0f 6f 77 80       	movdqu xmm6,XMMWORD PTR [rdi-0x80]
  40829d:	66 0f ef b4 24 c0 00 	pxor   xmm6,XMMWORD PTR [rsp+0xc0]
  4082a4:	00 00 
  4082a6:	66 0f ef 94 24 a0 00 	pxor   xmm2,XMMWORD PTR [rsp+0xa0]
  4082ad:	00 00 
  4082af:	66 44 0f 3a 44 fd 11 	pclmulhqhqdq xmm15,xmm5
  4082b6:	66 0f 3a 44 dd 00    	pclmullqlqdq xmm3,xmm5
  4082bc:	f3 0f 6f 6f 90       	movdqu xmm5,XMMWORD PTR [rdi-0x70]
  4082c1:	66 0f ef ac 24 d0 00 	pxor   xmm5,XMMWORD PTR [rsp+0xd0]
  4082c8:	00 00 
  4082ca:	66 0f 6f fe          	movdqa xmm7,xmm6
  4082ce:	66 41 0f ef df       	pxor   xmm3,xmm15
  4082d3:	66 0f ef a4 24 b0 00 	pxor   xmm4,XMMWORD PTR [rsp+0xb0]
  4082da:	00 00 
  4082dc:	66 44 0f 6f f2       	movdqa xmm14,xmm2
  4082e1:	66 0f 3a 44 fd 11    	pclmulhqhqdq xmm7,xmm5
  4082e7:	66 0f 3a 44 f5 00    	pclmullqlqdq xmm6,xmm5
  4082ed:	f3 0f 6f 6f a0       	movdqu xmm5,XMMWORD PTR [rdi-0x60]
  4082f2:	66 0f ef ac 24 e0 00 	pxor   xmm5,XMMWORD PTR [rsp+0xe0]
  4082f9:	00 00 
  4082fb:	66 44 0f 3a 44 f4 11 	pclmulhqhqdq xmm14,xmm4
  408302:	66 0f 3a 44 d4 00    	pclmullqlqdq xmm2,xmm4
  408308:	f3 0f 6f 67 b0       	movdqu xmm4,XMMWORD PTR [rdi-0x50]
  40830d:	66 0f ef a4 24 f0 00 	pxor   xmm4,XMMWORD PTR [rsp+0xf0]
  408314:	00 00 
  408316:	66 44 0f 6f ed       	movdqa xmm13,xmm5
  40831b:	66 41 0f ef d6       	pxor   xmm2,xmm14
  408320:	66 44 0f 3a 44 ec 11 	pclmulhqhqdq xmm13,xmm4
  408327:	66 0f 3a 44 ec 00    	pclmullqlqdq xmm5,xmm4
  40832d:	f3 0f 6f 67 c0       	movdqu xmm4,XMMWORD PTR [rdi-0x40]
  408332:	66 0f ef a4 24 00 01 	pxor   xmm4,XMMWORD PTR [rsp+0x100]
  408339:	00 00 
  40833b:	66 0f ef d6          	pxor   xmm2,xmm6
  40833f:	66 0f ef fd          	pxor   xmm7,xmm5
  408343:	66 0f 6f cc          	movdqa xmm1,xmm4
  408347:	f3 0f 6f 67 d0       	movdqu xmm4,XMMWORD PTR [rdi-0x30]
  40834c:	66 41 0f ef fd       	pxor   xmm7,xmm13
  408351:	66 0f ef a4 24 10 01 	pxor   xmm4,XMMWORD PTR [rsp+0x110]
  408358:	00 00 
  40835a:	66 44 0f 6f e1       	movdqa xmm12,xmm1
  40835f:	66 44 0f 3a 44 e4 11 	pclmulhqhqdq xmm12,xmm4
  408366:	66 0f 3a 44 cc 00    	pclmullqlqdq xmm1,xmm4
  40836c:	f3 0f 6f 67 e0       	movdqu xmm4,XMMWORD PTR [rdi-0x20]
  408371:	66 0f ef a4 24 20 01 	pxor   xmm4,XMMWORD PTR [rsp+0x120]
  408378:	00 00 
  40837a:	f3 44 0f 6f 4f f0    	movdqu xmm9,XMMWORD PTR [rdi-0x10]
  408380:	66 0f ef 44 24 20    	pxor   xmm0,XMMWORD PTR [rsp+0x20]
  408386:	66 41 0f ef cc       	pxor   xmm1,xmm12
  40838b:	66 44 0f ef 8c 24 30 	pxor   xmm9,XMMWORD PTR [rsp+0x130]
  408392:	01 00 00 
  408395:	66 0f ef 5c 24 30    	pxor   xmm3,XMMWORD PTR [rsp+0x30]
  40839b:	66 45 0f 6f c1       	movdqa xmm8,xmm9
  4083a0:	66 44 0f 6f cc       	movdqa xmm9,xmm4
  4083a5:	66 45 0f 3a 44 c8 11 	pclmulhqhqdq xmm9,xmm8
  4083ac:	66 41 0f 3a 44 e0 00 	pclmullqlqdq xmm4,xmm8
  4083b3:	66 44 0f 6f 44 24 10 	movdqa xmm8,XMMWORD PTR [rsp+0x10]
  4083ba:	66 44 0f ef 04 24    	pxor   xmm8,XMMWORD PTR [rsp]
  4083c0:	66 0f ef cc          	pxor   xmm1,xmm4
  4083c4:	66 41 0f ef c0       	pxor   xmm0,xmm8
  4083c9:	66 0f ef c3          	pxor   xmm0,xmm3
  4083cd:	66 0f ef c2          	pxor   xmm0,xmm2
  4083d1:	66 0f ef c7          	pxor   xmm0,xmm7
  4083d5:	66 0f ef c1          	pxor   xmm0,xmm1
  4083d9:	66 41 0f ef c1       	pxor   xmm0,xmm9
  4083de:	66 0f 6f c8          	movdqa xmm1,xmm0
  4083e2:	66 41 0f 3a 44 cb 01 	pclmulhqlqdq xmm1,xmm11
  4083e9:	66 0f 6f d1          	movdqa xmm2,xmm1
  4083ed:	66 41 0f 3a 44 d2 11 	pclmulhqhqdq xmm2,xmm10
  4083f4:	66 44 0f 6f da       	movdqa xmm11,xmm2
  4083f9:	66 0f ef ca          	pxor   xmm1,xmm2
  4083fd:	66 45 0f 3a 44 da 11 	pclmulhqhqdq xmm11,xmm10
  408404:	66 44 0f ef d8       	pxor   xmm11,xmm0
  408409:	66 44 0f ef d9       	pxor   xmm11,xmm1
  40840e:	48 39 cf             	cmp    rdi,rcx
  408411:	0f 85 e1 fd ff ff    	jne    4081f8 <ship+0x458>
  408417:	48 f7 d8             	neg    rax
  40841a:	48 c1 e0 08          	shl    rax,0x8
  40841e:	48 8d 94 06 00 ff ff 	lea    rdx,[rsi+rax*1-0x100]
  408425:	ff 
  408426:	e9 c5 f9 ff ff       	jmp    407df0 <ship+0x50>
  40842b:	44 89 c0             	mov    eax,r8d
  40842e:	0f a2                	cpuid  
  408430:	85 c0                	test   eax,eax
  408432:	0f 84 a4 00 00 00    	je     4084dc <ship+0x73c>
  408438:	b8 01 00 00 00       	mov    eax,0x1
  40843d:	0f a2                	cpuid  
  40843f:	81 e1 00 00 00 18    	and    ecx,0x18000000
  408445:	81 f9 00 00 00 18    	cmp    ecx,0x18000000
  40844b:	0f 85 8b 00 00 00    	jne    4084dc <ship+0x73c>
  408451:	44 89 c1             	mov    ecx,r8d
  408454:	0f 01 d0             	xgetbv 
  408457:	41 89 c1             	mov    r9d,eax
  40845a:	83 e0 06             	and    eax,0x6
  40845d:	83 f8 06             	cmp    eax,0x6
  408460:	75 7a                	jne    4084dc <ship+0x73c>
  408462:	44 89 c0             	mov    eax,r8d
  408465:	0f a2                	cpuid  
  408467:	83 f8 06             	cmp    eax,0x6
  40846a:	76 70                	jbe    4084dc <ship+0x73c>
  40846c:	b8 07 00 00 00       	mov    eax,0x7
  408471:	44 89 c1             	mov    ecx,r8d
  408474:	0f a2                	cpuid  
  408476:	80 e5 04             	and    ch,0x4
  408479:	74 61                	je     4084dc <ship+0x73c>
  40847b:	f6 c3 20             	test   bl,0x20
  40847e:	74 5c                	je     4084dc <ship+0x73c>
  408480:	41 81 e1 e6 00 00 00 	and    r9d,0xe6
  408487:	41 81 f9 e6 00 00 00 	cmp    r9d,0xe6
  40848e:	0f 84 17 01 00 00    	je     4085ab <ship+0x80b>
  408494:	c7 05 e6 2b 00 00 02 	mov    DWORD PTR [rip+0x2be6],0x2        # 40b084 <cached.1>
  40849b:	00 00 00 
  40849e:	41 b8 01 00 00 00    	mov    r8d,0x1
  4084a4:	44 8b 0d d5 2b 00 00 	mov    r9d,DWORD PTR [rip+0x2bd5]        # 40b080 <cached.0>
  4084ab:	45 85 c9             	test   r9d,r9d
  4084ae:	74 4f                	je     4084ff <ship+0x75f>
  4084b0:	41 83 f9 01          	cmp    r9d,0x1
  4084b4:	0f 85 e3 00 00 00    	jne    40859d <ship+0x7fd>
  4084ba:	41 83 f8 02          	cmp    r8d,0x2
  4084be:	0f 84 cb 00 00 00    	je     40858f <ship+0x7ef>
  4084c4:	41 83 f8 01          	cmp    r8d,0x1
  4084c8:	0f 85 ee fb ff ff    	jne    4080bc <ship+0x31c>
  4084ce:	48 81 c4 68 01 00 00 	add    rsp,0x168
  4084d5:	5b                   	pop    rbx
  4084d6:	5d                   	pop    rbp
  4084d7:	e9 c4 e2 ff ff       	jmp    4067a0 <chainhash_wide256.constprop.0>
  4084dc:	c7 05 9e 2b 00 00 01 	mov    DWORD PTR [rip+0x2b9e],0x1        # 40b084 <cached.1>
  4084e3:	00 00 00 
  4084e6:	e9 d1 fb ff ff       	jmp    4080bc <ship+0x31c>
  4084eb:	66 0f ef c0          	pxor   xmm0,xmm0
  4084ef:	b8 20 00 00 00       	mov    eax,0x20
  4084f4:	31 db                	xor    ebx,ebx
  4084f6:	66 0f 6f c8          	movdqa xmm1,xmm0
  4084fa:	e9 95 f9 ff ff       	jmp    407e94 <ship+0xf4>
  4084ff:	44 89 c8             	mov    eax,r9d
  408502:	0f a2                	cpuid  
  408504:	85 c0                	test   eax,eax
  408506:	74 78                	je     408580 <ship+0x7e0>
  408508:	44 89 c8             	mov    eax,r9d
  40850b:	0f a2                	cpuid  
  40850d:	81 fa 69 6e 65 49    	cmp    edx,0x49656e69
  408513:	0f 95 c0             	setne  al
  408516:	81 fb 47 65 6e 75    	cmp    ebx,0x756e6547
  40851c:	0f 95 c2             	setne  dl
  40851f:	08 d0                	or     al,dl
  408521:	75 5d                	jne    408580 <ship+0x7e0>
  408523:	81 f9 6e 74 65 6c    	cmp    ecx,0x6c65746e
  408529:	75 55                	jne    408580 <ship+0x7e0>
  40852b:	44 89 c8             	mov    eax,r9d
  40852e:	0f a2                	cpuid  
  408530:	85 c0                	test   eax,eax
  408532:	74 4c                	je     408580 <ship+0x7e0>
  408534:	b8 01 00 00 00       	mov    eax,0x1
  408539:	0f a2                	cpuid  
  40853b:	89 c2                	mov    edx,eax
  40853d:	89 c1                	mov    ecx,eax
  40853f:	c1 ea 04             	shr    edx,0x4
  408542:	c1 e9 0c             	shr    ecx,0xc
  408545:	83 e2 0f             	and    edx,0xf
  408548:	81 e1 f0 00 00 00    	and    ecx,0xf0
  40854e:	09 ca                	or     edx,ecx
  408550:	83 fa 6a             	cmp    edx,0x6a
  408553:	0f 94 c2             	sete   dl
  408556:	c1 e8 08             	shr    eax,0x8
  408559:	45 31 c9             	xor    r9d,r9d
  40855c:	83 e0 0f             	and    eax,0xf
  40855f:	83 f8 06             	cmp    eax,0x6
  408562:	41 0f 94 c1          	sete   r9b
  408566:	41 21 d1             	and    r9d,edx
  408569:	41 83 c1 01          	add    r9d,0x1
  40856d:	44 89 0d 0c 2b 00 00 	mov    DWORD PTR [rip+0x2b0c],r9d        # 40b080 <cached.0>
  408574:	e9 37 ff ff ff       	jmp    4084b0 <ship+0x710>
  408579:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  408580:	c7 05 f6 2a 00 00 01 	mov    DWORD PTR [rip+0x2af6],0x1        # 40b080 <cached.0>
  408587:	00 00 00 
  40858a:	e9 2b ff ff ff       	jmp    4084ba <ship+0x71a>
  40858f:	48 81 c4 68 01 00 00 	add    rsp,0x168
  408596:	5b                   	pop    rbx
  408597:	5d                   	pop    rbp
  408598:	e9 f3 e8 ff ff       	jmp    406e90 <chainhash_wide512.constprop.0>
  40859d:	48 81 c4 68 01 00 00 	add    rsp,0x168
  4085a4:	5b                   	pop    rbx
  4085a5:	5d                   	pop    rbp
  4085a6:	e9 a5 ee ff ff       	jmp    407450 <chainhash_narrow.constprop.0>
  4085ab:	81 e3 00 00 01 00    	and    ebx,0x10000
  4085b1:	0f 84 dd fe ff ff    	je     408494 <ship+0x6f4>
  4085b7:	c7 05 c3 2a 00 00 03 	mov    DWORD PTR [rip+0x2ac3],0x3        # 40b084 <cached.1>
  4085be:	00 00 00 
  4085c1:	41 b8 02 00 00 00    	mov    r8d,0x2
  4085c7:	e9 d8 fe ff ff       	jmp    4084a4 <ship+0x704>

Disassembly of section .fini:

00000000004085cc <_fini>:
  4085cc:	f3 0f 1e fa          	endbr64 
  4085d0:	48 83 ec 08          	sub    rsp,0x8
  4085d4:	48 83 c4 08          	add    rsp,0x8
  4085d8:	c3                   	ret    
