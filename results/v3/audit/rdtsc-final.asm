
bench/rdtsc:     file format elf64-x86-64


Disassembly of section .init:

0000000000401000 <_init>:
  401000:	f3 0f 1e fa          	endbr64 
  401004:	48 83 ec 08          	sub    rsp,0x8
  401008:	48 8b 05 e1 7f 00 00 	mov    rax,QWORD PTR [rip+0x7fe1]        # 408ff0 <__gmon_start__>
  40100f:	48 85 c0             	test   rax,rax
  401012:	74 02                	je     401016 <_init+0x16>
  401014:	ff d0                	call   rax
  401016:	48 83 c4 08          	add    rsp,0x8
  40101a:	c3                   	ret    

Disassembly of section .plt:

0000000000401020 <.plt>:
  401020:	ff 35 e2 7f 00 00    	push   QWORD PTR [rip+0x7fe2]        # 409008 <_GLOBAL_OFFSET_TABLE_+0x8>
  401026:	ff 25 e4 7f 00 00    	jmp    QWORD PTR [rip+0x7fe4]        # 409010 <_GLOBAL_OFFSET_TABLE_+0x10>
  40102c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401030 <free@plt>:
  401030:	ff 25 e2 7f 00 00    	jmp    QWORD PTR [rip+0x7fe2]        # 409018 <free@GLIBC_2.2.5>
  401036:	68 00 00 00 00       	push   0x0
  40103b:	e9 e0 ff ff ff       	jmp    401020 <.plt>

0000000000401040 <puts@plt>:
  401040:	ff 25 da 7f 00 00    	jmp    QWORD PTR [rip+0x7fda]        # 409020 <puts@GLIBC_2.2.5>
  401046:	68 01 00 00 00       	push   0x1
  40104b:	e9 d0 ff ff ff       	jmp    401020 <.plt>

0000000000401050 <printf@plt>:
  401050:	ff 25 d2 7f 00 00    	jmp    QWORD PTR [rip+0x7fd2]        # 409028 <printf@GLIBC_2.2.5>
  401056:	68 02 00 00 00       	push   0x2
  40105b:	e9 c0 ff ff ff       	jmp    401020 <.plt>

0000000000401060 <__assert_fail@plt>:
  401060:	ff 25 ca 7f 00 00    	jmp    QWORD PTR [rip+0x7fca]        # 409030 <__assert_fail@GLIBC_2.2.5>
  401066:	68 03 00 00 00       	push   0x3
  40106b:	e9 b0 ff ff ff       	jmp    401020 <.plt>

0000000000401070 <memcpy@plt>:
  401070:	ff 25 c2 7f 00 00    	jmp    QWORD PTR [rip+0x7fc2]        # 409038 <memcpy@GLIBC_2.14>
  401076:	68 04 00 00 00       	push   0x4
  40107b:	e9 a0 ff ff ff       	jmp    401020 <.plt>

0000000000401080 <malloc@plt>:
  401080:	ff 25 ba 7f 00 00    	jmp    QWORD PTR [rip+0x7fba]        # 409040 <malloc@GLIBC_2.2.5>
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
  40109f:	bb 28 70 40 00       	mov    ebx,0x407028
  4010a4:	48 81 ec b8 0a 00 00 	sub    rsp,0xab8
  4010ab:	e8 d0 ff ff ff       	call   401080 <malloc@plt>
  4010b0:	66 48 0f 6e c3       	movq   xmm0,rbx
  4010b5:	bb 3b 70 40 00       	mov    ebx,0x40703b
  4010ba:	48 c7 44 24 50 4e 70 	mov    QWORD PTR [rsp+0x50],0x40704e
  4010c1:	40 00 
  4010c3:	48 89 44 24 28       	mov    QWORD PTR [rsp+0x28],rax
  4010c8:	b8 2f 70 40 00       	mov    eax,0x40702f
  4010cd:	48 bf 2b 41 de 62 d4 	movabs rdi,0xb4dc9bd462de412b
  4010d4:	9b dc b4 
  4010d7:	4c 8d 9c 24 d0 00 00 	lea    r11,[rsp+0xd0]
  4010de:	00 
  4010df:	66 48 0f 3a 22 c0 01 	pinsrq xmm0,rax,0x1
  4010e6:	b8 47 70 40 00       	mov    eax,0x407047
  4010eb:	49 89 f9             	mov    r9,rdi
  4010ee:	48 c7 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],0x403e70
  4010f5:	00 70 3e 40 00 
  4010fa:	0f 29 44 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm0
  4010ff:	66 48 0f 6e c3       	movq   xmm0,rbx
  401104:	bb 60 4e 40 00       	mov    ebx,0x404e60
  401109:	41 ba 41 00 00 00    	mov    r10d,0x41
  40110f:	66 48 0f 3a 22 c0 01 	pinsrq xmm0,rax,0x1
  401116:	b8 00 36 40 00       	mov    eax,0x403600
  40111b:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
  401120:	66 48 0f 6e c3       	movq   xmm0,rbx
  401125:	bb a0 65 40 00       	mov    ebx,0x4065a0
  40112a:	66 48 0f 3a 22 c0 01 	pinsrq xmm0,rax,0x1
  401131:	b8 70 46 40 00       	mov    eax,0x404670
  401136:	0f 29 44 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm0
  40113b:	66 48 0f 6e c3       	movq   xmm0,rbx
  401140:	48 8d 9c 24 d0 01 00 	lea    rbx,[rsp+0x1d0]
  401147:	00 
  401148:	66 48 0f 3a 22 c0 01 	pinsrq xmm0,rax,0x1
  40114f:	48 8b 05 ea 60 00 00 	mov    rax,QWORD PTR [rip+0x60ea]        # 407240 <__PRETTY_FUNCTION__.6+0x150>
  401156:	0f 29 44 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm0
  40115b:	66 0f 6f 05 ed 5f 00 	movdqa xmm0,XMMWORD PTR [rip+0x5fed]        # 407150 <__PRETTY_FUNCTION__.6+0x60>
  401162:	00 
  401163:	48 89 84 24 c8 00 00 	mov    QWORD PTR [rsp+0xc8],rax
  40116a:	00 
  40116b:	0f 11 84 24 98 00 00 	movups XMMWORD PTR [rsp+0x98],xmm0
  401172:	00 
  401173:	66 0f 6f 05 e5 5f 00 	movdqa xmm0,XMMWORD PTR [rip+0x5fe5]        # 407160 <__PRETTY_FUNCTION__.6+0x70>
  40117a:	00 
  40117b:	0f 11 84 24 a8 00 00 	movups XMMWORD PTR [rsp+0xa8],xmm0
  401182:	00 
  401183:	66 0f 6f 05 e5 5f 00 	movdqa xmm0,XMMWORD PTR [rip+0x5fe5]        # 407170 <__PRETTY_FUNCTION__.6+0x80>
  40118a:	00 
  40118b:	0f 11 84 24 b8 00 00 	movups XMMWORD PTR [rsp+0xb8],xmm0
  401192:	00 
  401193:	49 89 3b             	mov    QWORD PTR [r11],rdi
  401196:	45 31 c0             	xor    r8d,r8d
  401199:	31 f6                	xor    esi,esi
  40119b:	31 c9                	xor    ecx,ecx
  40119d:	0f 1f 00             	nop    DWORD PTR [rax]
  4011a0:	4c 89 c8             	mov    rax,r9
  4011a3:	48 89 fa             	mov    rdx,rdi
  4011a6:	48 d3 e8             	shr    rax,cl
  4011a9:	48 d3 e2             	shl    rdx,cl
  4011ac:	83 e0 01             	and    eax,0x1
  4011af:	48 f7 d8             	neg    rax
  4011b2:	48 21 c2             	and    rdx,rax
  4011b5:	48 31 d6             	xor    rsi,rdx
  4011b8:	8d 51 01             	lea    edx,[rcx+0x1]
  4011bb:	85 c9                	test   ecx,ecx
  4011bd:	74 16                	je     4011d5 <main+0x145>
  4011bf:	44 89 d1             	mov    ecx,r10d
  4011c2:	49 89 ff             	mov    r15,rdi
  4011c5:	29 d1                	sub    ecx,edx
  4011c7:	49 d3 ef             	shr    r15,cl
  4011ca:	4c 21 f8             	and    rax,r15
  4011cd:	49 31 c0             	xor    r8,rax
  4011d0:	83 fa 40             	cmp    edx,0x40
  4011d3:	74 04                	je     4011d9 <main+0x149>
  4011d5:	89 d1                	mov    ecx,edx
  4011d7:	eb c7                	jmp    4011a0 <main+0x110>
  4011d9:	4c 89 c7             	mov    rdi,r8
  4011dc:	4c 89 c0             	mov    rax,r8
  4011df:	4b 8d 14 00          	lea    rdx,[r8+r8*1]
  4011e3:	49 83 c3 08          	add    r11,0x8
  4011e7:	48 c1 e8 3c          	shr    rax,0x3c
  4011eb:	48 c1 ef 3d          	shr    rdi,0x3d
  4011ef:	48 31 c7             	xor    rdi,rax
  4011f2:	48 89 f0             	mov    rax,rsi
  4011f5:	4c 31 c0             	xor    rax,r8
  4011f8:	48 31 d0             	xor    rax,rdx
  4011fb:	4a 8d 14 c5 00 00 00 	lea    rdx,[r8*8+0x0]
  401202:	00 
  401203:	49 c1 e0 04          	shl    r8,0x4
  401207:	48 31 d0             	xor    rax,rdx
  40120a:	48 8d 14 3f          	lea    rdx,[rdi+rdi*1]
  40120e:	4c 31 c0             	xor    rax,r8
  401211:	48 31 f8             	xor    rax,rdi
  401214:	48 31 d0             	xor    rax,rdx
  401217:	48 8d 14 fd 00 00 00 	lea    rdx,[rdi*8+0x0]
  40121e:	00 
  40121f:	48 c1 e7 04          	shl    rdi,0x4
  401223:	48 31 d0             	xor    rax,rdx
  401226:	48 31 c7             	xor    rdi,rax
  401229:	49 39 db             	cmp    r11,rbx
  40122c:	0f 85 61 ff ff ff    	jne    401193 <main+0x103>
  401232:	66 0f 6f 84 24 d0 00 	movdqa xmm0,XMMWORD PTR [rsp+0xd0]
  401239:	00 00 
  40123b:	bf 41 00 00 00       	mov    edi,0x41
  401240:	f3 0f 6f ac 24 98 00 	movdqu xmm5,XMMWORD PTR [rsp+0x98]
  401247:	00 00 
  401249:	4c 8d 8c 24 60 07 00 	lea    r9,[rsp+0x760]
  401250:	00 
  401251:	f3 0f 6f b4 24 a8 00 	movdqu xmm6,XMMWORD PTR [rsp+0xa8]
  401258:	00 00 
  40125a:	48 8b 84 24 c8 00 00 	mov    rax,QWORD PTR [rsp+0xc8]
  401261:	00 
  401262:	4c 8d 94 24 a0 07 00 	lea    r10,[rsp+0x7a0]
  401269:	00 
  40126a:	be 1b 00 00 00       	mov    esi,0x1b
  40126f:	66 0f 6f c8          	movdqa xmm1,xmm0
  401273:	4c 8b 84 24 98 00 00 	mov    r8,QWORD PTR [rsp+0x98]
  40127a:	00 
  40127b:	66 0f 6d 84 24 e0 00 	punpckhqdq xmm0,XMMWORD PTR [rsp+0xe0]
  401282:	00 00 
  401284:	0f 29 ac 24 d0 01 00 	movaps XMMWORD PTR [rsp+0x1d0],xmm5
  40128b:	00 
  40128c:	66 0f 6c 8c 24 e0 00 	punpcklqdq xmm1,XMMWORD PTR [rsp+0xe0]
  401293:	00 00 
  401295:	48 89 84 24 00 02 00 	mov    QWORD PTR [rsp+0x200],rax
  40129c:	00 
  40129d:	0f 29 84 24 70 06 00 	movaps XMMWORD PTR [rsp+0x670],xmm0
  4012a4:	00 
  4012a5:	66 0f 6f 84 24 f0 00 	movdqa xmm0,XMMWORD PTR [rsp+0xf0]
  4012ac:	00 00 
  4012ae:	f3 0f 6f bc 24 b8 00 	movdqu xmm7,XMMWORD PTR [rsp+0xb8]
  4012b5:	00 00 
  4012b7:	0f 29 8c 24 60 06 00 	movaps XMMWORD PTR [rsp+0x660],xmm1
  4012be:	00 
  4012bf:	66 0f 6f c8          	movdqa xmm1,xmm0
  4012c3:	0f 29 b4 24 e0 01 00 	movaps XMMWORD PTR [rsp+0x1e0],xmm6
  4012ca:	00 
  4012cb:	66 0f 6d 84 24 00 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x100]
  4012d2:	00 00 
  4012d4:	66 0f 6c 8c 24 00 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x100]
  4012db:	00 00 
  4012dd:	0f 29 bc 24 f0 01 00 	movaps XMMWORD PTR [rsp+0x1f0],xmm7
  4012e4:	00 
  4012e5:	0f 29 84 24 90 06 00 	movaps XMMWORD PTR [rsp+0x690],xmm0
  4012ec:	00 
  4012ed:	66 0f 6f 84 24 10 01 	movdqa xmm0,XMMWORD PTR [rsp+0x110]
  4012f4:	00 00 
  4012f6:	0f 29 8c 24 80 06 00 	movaps XMMWORD PTR [rsp+0x680],xmm1
  4012fd:	00 
  4012fe:	66 0f 6f c8          	movdqa xmm1,xmm0
  401302:	66 0f 6d 84 24 20 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x120]
  401309:	00 00 
  40130b:	66 0f 6c 8c 24 20 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x120]
  401312:	00 00 
  401314:	0f 29 84 24 b0 06 00 	movaps XMMWORD PTR [rsp+0x6b0],xmm0
  40131b:	00 
  40131c:	66 0f 6f 84 24 30 01 	movdqa xmm0,XMMWORD PTR [rsp+0x130]
  401323:	00 00 
  401325:	0f 29 8c 24 a0 06 00 	movaps XMMWORD PTR [rsp+0x6a0],xmm1
  40132c:	00 
  40132d:	66 0f 6f c8          	movdqa xmm1,xmm0
  401331:	66 0f 6d 84 24 40 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x140]
  401338:	00 00 
  40133a:	66 0f 6c 8c 24 40 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x140]
  401341:	00 00 
  401343:	0f 29 84 24 d0 06 00 	movaps XMMWORD PTR [rsp+0x6d0],xmm0
  40134a:	00 
  40134b:	66 0f 6f 84 24 50 01 	movdqa xmm0,XMMWORD PTR [rsp+0x150]
  401352:	00 00 
  401354:	0f 29 8c 24 c0 06 00 	movaps XMMWORD PTR [rsp+0x6c0],xmm1
  40135b:	00 
  40135c:	66 0f 6f c8          	movdqa xmm1,xmm0
  401360:	66 0f 6c 8c 24 60 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x160]
  401367:	00 00 
  401369:	0f 29 8c 24 e0 06 00 	movaps XMMWORD PTR [rsp+0x6e0],xmm1
  401370:	00 
  401371:	66 0f 6d 84 24 60 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x160]
  401378:	00 00 
  40137a:	48 c7 84 24 60 07 00 	mov    QWORD PTR [rsp+0x760],0x1
  401381:	00 01 00 00 00 
  401386:	0f 29 84 24 f0 06 00 	movaps XMMWORD PTR [rsp+0x6f0],xmm0
  40138d:	00 
  40138e:	66 0f 6f 84 24 70 01 	movdqa xmm0,XMMWORD PTR [rsp+0x170]
  401395:	00 00 
  401397:	48 c7 84 24 a8 07 00 	mov    QWORD PTR [rsp+0x7a8],0x1b
  40139e:	00 1b 00 00 00 
  4013a3:	66 0f 6f c8          	movdqa xmm1,xmm0
  4013a7:	66 0f 6d 84 24 80 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x180]
  4013ae:	00 00 
  4013b0:	66 0f 6c 8c 24 80 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x180]
  4013b7:	00 00 
  4013b9:	0f 29 84 24 10 07 00 	movaps XMMWORD PTR [rsp+0x710],xmm0
  4013c0:	00 
  4013c1:	66 0f 6f 84 24 90 01 	movdqa xmm0,XMMWORD PTR [rsp+0x190]
  4013c8:	00 00 
  4013ca:	0f 29 8c 24 00 07 00 	movaps XMMWORD PTR [rsp+0x700],xmm1
  4013d1:	00 
  4013d2:	66 0f 6f c8          	movdqa xmm1,xmm0
  4013d6:	66 0f 6d 84 24 a0 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x1a0]
  4013dd:	00 00 
  4013df:	66 0f 6c 8c 24 a0 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x1a0]
  4013e6:	00 00 
  4013e8:	0f 29 84 24 30 07 00 	movaps XMMWORD PTR [rsp+0x730],xmm0
  4013ef:	00 
  4013f0:	66 0f 6f 84 24 b0 01 	movdqa xmm0,XMMWORD PTR [rsp+0x1b0]
  4013f7:	00 00 
  4013f9:	0f 29 8c 24 20 07 00 	movaps XMMWORD PTR [rsp+0x720],xmm1
  401400:	00 
  401401:	66 0f 6f c8          	movdqa xmm1,xmm0
  401405:	66 0f 6d 84 24 c0 01 	punpckhqdq xmm0,XMMWORD PTR [rsp+0x1c0]
  40140c:	00 00 
  40140e:	66 0f 6c 8c 24 c0 01 	punpcklqdq xmm1,XMMWORD PTR [rsp+0x1c0]
  401415:	00 00 
  401417:	0f 29 84 24 50 07 00 	movaps XMMWORD PTR [rsp+0x750],xmm0
  40141e:	00 
  40141f:	0f 29 8c 24 40 07 00 	movaps XMMWORD PTR [rsp+0x740],xmm1
  401426:	00 
  401427:	49 8b 19             	mov    rbx,QWORD PTR [r9]
  40142a:	31 ed                	xor    ebp,ebp
  40142c:	45 31 db             	xor    r11d,r11d
  40142f:	31 c9                	xor    ecx,ecx
  401431:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  401438:	4c 89 c0             	mov    rax,r8
  40143b:	48 89 da             	mov    rdx,rbx
  40143e:	48 d3 e8             	shr    rax,cl
  401441:	48 d3 e2             	shl    rdx,cl
  401444:	83 e0 01             	and    eax,0x1
  401447:	48 f7 d8             	neg    rax
  40144a:	48 21 c2             	and    rdx,rax
  40144d:	49 31 d3             	xor    r11,rdx
  401450:	8d 51 01             	lea    edx,[rcx+0x1]
  401453:	85 c9                	test   ecx,ecx
  401455:	74 15                	je     40146c <main+0x3dc>
  401457:	89 f9                	mov    ecx,edi
  401459:	49 89 df             	mov    r15,rbx
  40145c:	29 d1                	sub    ecx,edx
  40145e:	49 d3 ef             	shr    r15,cl
  401461:	4c 21 f8             	and    rax,r15
  401464:	48 31 c5             	xor    rbp,rax
  401467:	83 fa 40             	cmp    edx,0x40
  40146a:	74 04                	je     401470 <main+0x3e0>
  40146c:	89 d1                	mov    ecx,edx
  40146e:	eb c8                	jmp    401438 <main+0x3a8>
  401470:	48 89 e8             	mov    rax,rbp
  401473:	48 89 ea             	mov    rdx,rbp
  401476:	49 31 eb             	xor    r11,rbp
  401479:	31 db                	xor    ebx,ebx
  40147b:	48 c1 ea 3c          	shr    rdx,0x3c
  40147f:	48 c1 e8 3d          	shr    rax,0x3d
  401483:	31 c9                	xor    ecx,ecx
  401485:	48 31 d0             	xor    rax,rdx
  401488:	48 8d 54 2d 00       	lea    rdx,[rbp+rbp*1+0x0]
  40148d:	49 31 d3             	xor    r11,rdx
  401490:	48 8d 14 ed 00 00 00 	lea    rdx,[rbp*8+0x0]
  401497:	00 
  401498:	48 c1 e5 04          	shl    rbp,0x4
  40149c:	49 31 d3             	xor    r11,rdx
  40149f:	48 8d 14 00          	lea    rdx,[rax+rax*1]
  4014a3:	49 31 eb             	xor    r11,rbp
  4014a6:	31 ed                	xor    ebp,ebp
  4014a8:	49 31 c3             	xor    r11,rax
  4014ab:	49 31 d3             	xor    r11,rdx
  4014ae:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
  4014b5:	00 
  4014b6:	48 c1 e0 04          	shl    rax,0x4
  4014ba:	49 31 d3             	xor    r11,rdx
  4014bd:	49 31 c3             	xor    r11,rax
  4014c0:	4d 89 59 08          	mov    QWORD PTR [r9+0x8],r11
  4014c4:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  4014c8:	4c 89 d8             	mov    rax,r11
  4014cb:	48 89 f2             	mov    rdx,rsi
  4014ce:	48 d3 e8             	shr    rax,cl
  4014d1:	48 d3 e2             	shl    rdx,cl
  4014d4:	83 e0 01             	and    eax,0x1
  4014d7:	48 f7 d8             	neg    rax
  4014da:	48 21 c2             	and    rdx,rax
  4014dd:	48 31 d3             	xor    rbx,rdx
  4014e0:	8d 51 01             	lea    edx,[rcx+0x1]
  4014e3:	85 c9                	test   ecx,ecx
  4014e5:	74 15                	je     4014fc <main+0x46c>
  4014e7:	89 f9                	mov    ecx,edi
  4014e9:	49 89 f7             	mov    r15,rsi
  4014ec:	29 d1                	sub    ecx,edx
  4014ee:	49 d3 ef             	shr    r15,cl
  4014f1:	4c 21 f8             	and    rax,r15
  4014f4:	48 31 c5             	xor    rbp,rax
  4014f7:	83 fa 40             	cmp    edx,0x40
  4014fa:	74 04                	je     401500 <main+0x470>
  4014fc:	89 d1                	mov    ecx,edx
  4014fe:	eb c8                	jmp    4014c8 <main+0x438>
  401500:	48 89 d8             	mov    rax,rbx
  401503:	48 8d 54 2d 00       	lea    rdx,[rbp+rbp*1+0x0]
  401508:	49 83 c1 08          	add    r9,0x8
  40150c:	48 31 e8             	xor    rax,rbp
  40150f:	48 31 d0             	xor    rax,rdx
  401512:	48 8d 14 ed 00 00 00 	lea    rdx,[rbp*8+0x0]
  401519:	00 
  40151a:	48 c1 e5 04          	shl    rbp,0x4
  40151e:	48 31 d0             	xor    rax,rdx
  401521:	48 31 e8             	xor    rax,rbp
  401524:	49 89 41 48          	mov    QWORD PTR [r9+0x48],rax
  401528:	4d 39 d1             	cmp    r9,r10
  40152b:	0f 85 f6 fe ff ff    	jne    401427 <main+0x397>
  401531:	48 8b 84 24 f8 01 00 	mov    rax,QWORD PTR [rsp+0x1f8]
  401538:	00 
  401539:	48 8d b4 24 60 06 00 	lea    rsi,[rsp+0x660]
  401540:	00 
  401541:	f3 0f 6f 9c 24 d8 01 	movdqu xmm3,XMMWORD PTR [rsp+0x1d8]
  401548:	00 00 
  40154a:	48 8d bc 24 10 02 00 	lea    rdi,[rsp+0x210]
  401551:	00 
  401552:	f3 0f 6f a4 24 e8 01 	movdqu xmm4,XMMWORD PTR [rsp+0x1e8]
  401559:	00 00 
  40155b:	48 89 74 24 20       	mov    QWORD PTR [rsp+0x20],rsi
  401560:	b9 38 00 00 00       	mov    ecx,0x38
  401565:	49 bb 15 7c 4a 7f b9 	movabs r11,0x9e3779b97f4a7c15
  40156c:	79 37 9e 
  40156f:	48 89 84 24 10 08 00 	mov    QWORD PTR [rsp+0x810],rax
  401576:	00 
  401577:	48 8b 84 24 00 02 00 	mov    rax,QWORD PTR [rsp+0x200]
  40157e:	00 
  40157f:	49 ba b9 e5 e4 1c 6d 	movabs r10,0xbf58476d1ce4e5b9
  401586:	47 58 bf 
  401589:	49 b9 eb 11 31 13 bb 	movabs r9,0x94d049bb133111eb
  401590:	49 d0 94 
  401593:	0f 29 9c 24 f0 07 00 	movaps XMMWORD PTR [rsp+0x7f0],xmm3
  40159a:	00 
  40159b:	49 b8 b8 67 dc 1e 45 	movabs r8,0xabb024451edc67b8
  4015a2:	24 b0 ab 
  4015a5:	48 89 84 24 18 08 00 	mov    QWORD PTR [rsp+0x818],rax
  4015ac:	00 
  4015ad:	0f 29 a4 24 00 08 00 	movaps XMMWORD PTR [rsp+0x800],xmm4
  4015b4:	00 
  4015b5:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  4015b8:	bf 60 96 40 00       	mov    edi,0x409660
  4015bd:	48 8d b4 24 10 02 00 	lea    rsi,[rsp+0x210]
  4015c4:	00 
  4015c5:	b9 38 00 00 00       	mov    ecx,0x38
  4015ca:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  4015cd:	48 8d b4 24 10 02 00 	lea    rsi,[rsp+0x210]
  4015d4:	00 
  4015d5:	b9 7b 00 00 00       	mov    ecx,0x7b
  4015da:	48 89 f7             	mov    rdi,rsi
  4015dd:	4c 01 d9             	add    rcx,r11
  4015e0:	48 83 c7 08          	add    rdi,0x8
  4015e4:	48 89 ca             	mov    rdx,rcx
  4015e7:	48 c1 ea 1e          	shr    rdx,0x1e
  4015eb:	48 31 ca             	xor    rdx,rcx
  4015ee:	49 0f af d2          	imul   rdx,r10
  4015f2:	48 89 d0             	mov    rax,rdx
  4015f5:	48 c1 e8 1b          	shr    rax,0x1b
  4015f9:	48 31 d0             	xor    rax,rdx
  4015fc:	49 0f af c1          	imul   rax,r9
  401600:	48 89 c2             	mov    rdx,rax
  401603:	48 c1 ea 1f          	shr    rdx,0x1f
  401607:	48 31 d0             	xor    rax,rdx
  40160a:	48 89 47 f8          	mov    QWORD PTR [rdi-0x8],rax
  40160e:	4c 39 c1             	cmp    rcx,r8
  401611:	75 ca                	jne    4015dd <main+0x54d>
  401613:	48 8b 7c 24 20       	mov    rdi,QWORD PTR [rsp+0x20]
  401618:	b9 89 00 00 00       	mov    ecx,0x89
  40161d:	49 bb 15 7c 4a 7f b9 	movabs r11,0x9e3779b97f4a7c15
  401624:	79 37 9e 
  401627:	49 ba b9 e5 e4 1c 6d 	movabs r10,0xbf58476d1ce4e5b9
  40162e:	47 58 bf 
  401631:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  401634:	bf 00 92 40 00       	mov    edi,0x409200
  401639:	48 8d b4 24 60 06 00 	lea    rsi,[rsp+0x660]
  401640:	00 
  401641:	b9 89 00 00 00       	mov    ecx,0x89
  401646:	49 b9 eb 11 31 13 bb 	movabs r9,0x94d049bb133111eb
  40164d:	49 d0 94 
  401650:	48 89 74 24 20       	mov    QWORD PTR [rsp+0x20],rsi
  401655:	49 b8 d8 df ed 62 b5 	movabs r8,0x56e27eb562eddfd8
  40165c:	7e e2 56 
  40165f:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  401662:	48 8d b4 24 10 02 00 	lea    rsi,[rsp+0x210]
  401669:	00 
  40166a:	b9 7b 00 00 00       	mov    ecx,0x7b
  40166f:	48 89 f7             	mov    rdi,rsi
  401672:	4c 01 d9             	add    rcx,r11
  401675:	48 83 c7 08          	add    rdi,0x8
  401679:	48 89 ca             	mov    rdx,rcx
  40167c:	48 c1 ea 1e          	shr    rdx,0x1e
  401680:	48 31 ca             	xor    rdx,rcx
  401683:	49 0f af d2          	imul   rdx,r10
  401687:	48 89 d0             	mov    rax,rdx
  40168a:	48 c1 e8 1b          	shr    rax,0x1b
  40168e:	48 31 d0             	xor    rax,rdx
  401691:	49 0f af c1          	imul   rax,r9
  401695:	48 89 c2             	mov    rdx,rax
  401698:	48 c1 ea 1f          	shr    rdx,0x1f
  40169c:	48 31 d0             	xor    rax,rdx
  40169f:	48 89 47 f8          	mov    QWORD PTR [rdi-0x8],rax
  4016a3:	4c 39 c1             	cmp    rcx,r8
  4016a6:	75 ca                	jne    401672 <main+0x5e2>
  4016a8:	48 8b 7c 24 20       	mov    rdi,QWORD PTR [rsp+0x20]
  4016ad:	b9 29 00 00 00       	mov    ecx,0x29
  4016b2:	48 8b 44 24 28       	mov    rax,QWORD PTR [rsp+0x28]
  4016b7:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  4016ba:	48 8d b4 24 60 06 00 	lea    rsi,[rsp+0x660]
  4016c1:	00 
  4016c2:	bf a0 90 40 00       	mov    edi,0x4090a0
  4016c7:	b9 29 00 00 00       	mov    ecx,0x29
  4016cc:	48 89 74 24 20       	mov    QWORD PTR [rsp+0x20],rsi
  4016d1:	66 0f 6f 1d 67 5a 00 	movdqa xmm3,XMMWORD PTR [rip+0x5a67]        # 407140 <__PRETTY_FUNCTION__.6+0x50>
  4016d8:	00 
  4016d9:	48 8d 90 40 00 04 00 	lea    rdx,[rax+0x40040]
  4016e0:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  4016e3:	66 0f 6f 3d a5 5a 00 	movdqa xmm7,XMMWORD PTR [rip+0x5aa5]        # 407190 <__PRETTY_FUNCTION__.6+0xa0>
  4016ea:	00 
  4016eb:	66 44 0f 6f 05 8c 5a 	movdqa xmm8,XMMWORD PTR [rip+0x5a8c]        # 407180 <__PRETTY_FUNCTION__.6+0x90>
  4016f2:	00 00 
  4016f4:	66 0f 6f 15 a4 5a 00 	movdqa xmm2,XMMWORD PTR [rip+0x5aa4]        # 4071a0 <__PRETTY_FUNCTION__.6+0xb0>
  4016fb:	00 
  4016fc:	66 0f 6f 35 ac 5a 00 	movdqa xmm6,XMMWORD PTR [rip+0x5aac]        # 4071b0 <__PRETTY_FUNCTION__.6+0xc0>
  401703:	00 
  401704:	66 0f 6f 2d b4 5a 00 	movdqa xmm5,XMMWORD PTR [rip+0x5ab4]        # 4071c0 <__PRETTY_FUNCTION__.6+0xd0>
  40170b:	00 
  40170c:	66 0f 6f 25 bc 5a 00 	movdqa xmm4,XMMWORD PTR [rip+0x5abc]        # 4071d0 <__PRETTY_FUNCTION__.6+0xe0>
  401713:	00 
  401714:	66 0f 6f c3          	movdqa xmm0,xmm3
  401718:	66 0f 6f ca          	movdqa xmm1,xmm2
  40171c:	48 83 c0 10          	add    rax,0x10
  401720:	66 44 0f 6f c8       	movdqa xmm9,xmm0
  401725:	66 0f db c8          	pand   xmm1,xmm0
  401729:	66 41 0f fe d8       	paddd  xmm3,xmm8
  40172e:	66 44 0f fe cf       	paddd  xmm9,xmm7
  401733:	66 44 0f db ca       	pand   xmm9,xmm2
  401738:	66 41 0f 38 2b c9    	packusdw xmm1,xmm9
  40173e:	66 44 0f 6f c8       	movdqa xmm9,xmm0
  401743:	66 0f fe c5          	paddd  xmm0,xmm5
  401747:	66 44 0f fe ce       	paddd  xmm9,xmm6
  40174c:	66 0f db c2          	pand   xmm0,xmm2
  401750:	66 0f db cc          	pand   xmm1,xmm4
  401754:	66 44 0f db ca       	pand   xmm9,xmm2
  401759:	66 44 0f 38 2b c8    	packusdw xmm9,xmm0
  40175f:	66 41 0f 6f c1       	movdqa xmm0,xmm9
  401764:	66 0f db c4          	pand   xmm0,xmm4
  401768:	66 0f 67 c8          	packuswb xmm1,xmm0
  40176c:	66 0f 6f c1          	movdqa xmm0,xmm1
  401770:	66 0f fc c1          	paddb  xmm0,xmm1
  401774:	66 0f fc c0          	paddb  xmm0,xmm0
  401778:	66 0f fc c0          	paddb  xmm0,xmm0
  40177c:	66 0f fc c0          	paddb  xmm0,xmm0
  401780:	66 0f fc c1          	paddb  xmm0,xmm1
  401784:	0f 11 40 f0          	movups XMMWORD PTR [rax-0x10],xmm0
  401788:	48 39 d0             	cmp    rax,rdx
  40178b:	75 87                	jne    401714 <main+0x684>
  40178d:	bf b0 70 40 00       	mov    edi,0x4070b0
  401792:	e8 a9 f8 ff ff       	call   401040 <puts@plt>
  401797:	48 c7 44 24 08 00 00 	mov    QWORD PTR [rsp+0x8],0x0
  40179e:	00 00 
  4017a0:	48 c7 44 24 10 00 00 	mov    QWORD PTR [rsp+0x10],0x0
  4017a7:	00 00 
  4017a9:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  4017ae:	4c 8b 6c 24 28       	mov    r13,QWORD PTR [rsp+0x28]
  4017b3:	4c 8b 74 24 20       	mov    r14,QWORD PTR [rsp+0x20]
  4017b8:	89 44 24 18          	mov    DWORD PTR [rsp+0x18],eax
  4017bc:	49 01 c5             	add    r13,rax
  4017bf:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
  4017c4:	bd 10 00 00 00       	mov    ebp,0x10
  4017c9:	31 db                	xor    ebx,ebx
  4017cb:	4c 8b 64 04 60       	mov    r12,QWORD PTR [rsp+rax*1+0x60]
  4017d0:	be 00 00 04 00       	mov    esi,0x40000
  4017d5:	4c 89 ef             	mov    rdi,r13
  4017d8:	41 ff d4             	call   r12
  4017db:	48 31 c3             	xor    rbx,rax
  4017de:	83 ed 01             	sub    ebp,0x1
  4017e1:	75 ed                	jne    4017d0 <main+0x740>
  4017e3:	0f ae e8             	lfence 
  4017e6:	0f 31                	rdtsc  
  4017e8:	bd 00 02 00 00       	mov    ebp,0x200
  4017ed:	49 89 c7             	mov    r15,rax
  4017f0:	48 c1 e2 20          	shl    rdx,0x20
  4017f4:	49 09 d7             	or     r15,rdx
  4017f7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  4017fe:	00 00 
  401800:	be 00 00 04 00       	mov    esi,0x40000
  401805:	4c 89 ef             	mov    rdi,r13
  401808:	41 ff d4             	call   r12
  40180b:	48 31 c3             	xor    rbx,rax
  40180e:	83 ed 01             	sub    ebp,0x1
  401811:	75 ed                	jne    401800 <main+0x770>
  401813:	0f ae e8             	lfence 
  401816:	0f 31                	rdtsc  
  401818:	48 c1 e2 20          	shl    rdx,0x20
  40181c:	48 89 1d 6d 78 00 00 	mov    QWORD PTR [rip+0x786d],rbx        # 409090 <sink>
  401823:	48 09 d0             	or     rax,rdx
  401826:	4c 29 f8             	sub    rax,r15
  401829:	0f 88 5b 02 00 00    	js     401a8a <main+0x9fa>
  40182f:	66 0f ef c0          	pxor   xmm0,xmm0
  401833:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
  401838:	f2 0f 59 05 08 5a 00 	mulsd  xmm0,QWORD PTR [rip+0x5a08]        # 407248 <__PRETTY_FUNCTION__.6+0x158>
  40183f:	00 
  401840:	49 83 c6 08          	add    r14,0x8
  401844:	48 8d 84 24 78 06 00 	lea    rax,[rsp+0x678]
  40184b:	00 
  40184c:	f2 41 0f 11 46 f8    	movsd  QWORD PTR [r14-0x8],xmm0
  401852:	4c 39 f0             	cmp    rax,r14
  401855:	0f 85 64 ff ff ff    	jne    4017bf <main+0x72f>
  40185b:	f2 0f 10 84 24 68 06 	movsd  xmm0,QWORD PTR [rsp+0x668]
  401862:	00 00 
  401864:	f2 0f 10 8c 24 60 06 	movsd  xmm1,QWORD PTR [rsp+0x660]
  40186b:	00 00 
  40186d:	f2 0f 10 94 24 70 06 	movsd  xmm2,QWORD PTR [rsp+0x670]
  401874:	00 00 
  401876:	66 0f 2f c8          	comisd xmm1,xmm0
  40187a:	0f 86 28 02 00 00    	jbe    401aa8 <main+0xa18>
  401880:	66 0f 2f c2          	comisd xmm0,xmm2
  401884:	77 08                	ja     40188e <main+0x7fe>
  401886:	f2 0f 5d d1          	minsd  xmm2,xmm1
  40188a:	66 0f 28 c2          	movapd xmm0,xmm2
  40188e:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
  401893:	8b 54 24 18          	mov    edx,DWORD PTR [rsp+0x18]
  401897:	bf 55 70 40 00       	mov    edi,0x407055
  40189c:	f2 0f 10 0d ac 59 00 	movsd  xmm1,QWORD PTR [rip+0x59ac]        # 407250 <__PRETTY_FUNCTION__.6+0x160>
  4018a3:	00 
  4018a4:	48 8b 74 04 30       	mov    rsi,QWORD PTR [rsp+rax*1+0x30]
  4018a9:	b8 02 00 00 00       	mov    eax,0x2
  4018ae:	f2 0f 5e c8          	divsd  xmm1,xmm0
  4018b2:	e8 99 f7 ff ff       	call   401050 <printf@plt>
  4018b7:	48 83 44 24 10 01    	add    QWORD PTR [rsp+0x10],0x1
  4018bd:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  4018c2:	48 83 f8 08          	cmp    rax,0x8
  4018c6:	0f 85 dd fe ff ff    	jne    4017a9 <main+0x719>
  4018cc:	48 83 44 24 08 08    	add    QWORD PTR [rsp+0x8],0x8
  4018d2:	48 8b 44 24 08       	mov    rax,QWORD PTR [rsp+0x8]
  4018d7:	48 83 f8 28          	cmp    rax,0x28
  4018db:	0f 85 bf fe ff ff    	jne    4017a0 <main+0x710>
  4018e1:	48 c7 44 24 10 00 00 	mov    QWORD PTR [rsp+0x10],0x0
  4018e8:	00 00 
  4018ea:	bd 01 00 00 00       	mov    ebp,0x1
  4018ef:	90                   	nop
  4018f0:	89 e8                	mov    eax,ebp
  4018f2:	89 6c 24 18          	mov    DWORD PTR [rsp+0x18],ebp
  4018f6:	4c 8b 7c 24 20       	mov    r15,QWORD PTR [rsp+0x20]
  4018fb:	83 e0 07             	and    eax,0x7
  4018fe:	89 44 24 1c          	mov    DWORD PTR [rsp+0x1c],eax
  401902:	41 89 c6             	mov    r14d,eax
  401905:	4c 03 74 24 28       	add    r14,QWORD PTR [rsp+0x28]
  40190a:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  40190f:	41 bc 10 00 00 00    	mov    r12d,0x10
  401915:	31 db                	xor    ebx,ebx
  401917:	4c 8b 6c 04 60       	mov    r13,QWORD PTR [rsp+rax*1+0x60]
  40191c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  401920:	48 89 ee             	mov    rsi,rbp
  401923:	4c 89 f7             	mov    rdi,r14
  401926:	41 ff d5             	call   r13
  401929:	48 31 c3             	xor    rbx,rax
  40192c:	41 83 ec 01          	sub    r12d,0x1
  401930:	75 ee                	jne    401920 <main+0x890>
  401932:	0f ae e8             	lfence 
  401935:	0f 31                	rdtsc  
  401937:	41 bc 00 08 00 00    	mov    r12d,0x800
  40193d:	48 c1 e2 20          	shl    rdx,0x20
  401941:	48 09 d0             	or     rax,rdx
  401944:	48 89 44 24 08       	mov    QWORD PTR [rsp+0x8],rax
  401949:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  401950:	48 89 ee             	mov    rsi,rbp
  401953:	4c 89 f7             	mov    rdi,r14
  401956:	41 ff d5             	call   r13
  401959:	48 31 c3             	xor    rbx,rax
  40195c:	41 83 ec 01          	sub    r12d,0x1
  401960:	75 ee                	jne    401950 <main+0x8c0>
  401962:	0f ae e8             	lfence 
  401965:	0f 31                	rdtsc  
  401967:	48 c1 e2 20          	shl    rdx,0x20
  40196b:	48 89 1d 1e 77 00 00 	mov    QWORD PTR [rip+0x771e],rbx        # 409090 <sink>
  401972:	48 09 d0             	or     rax,rdx
  401975:	48 2b 44 24 08       	sub    rax,QWORD PTR [rsp+0x8]
  40197a:	0f 88 d0 00 00 00    	js     401a50 <main+0x9c0>
  401980:	66 0f ef c0          	pxor   xmm0,xmm0
  401984:	f2 48 0f 2a c0       	cvtsi2sd xmm0,rax
  401989:	f2 0f 59 05 c7 58 00 	mulsd  xmm0,QWORD PTR [rip+0x58c7]        # 407258 <__PRETTY_FUNCTION__.6+0x168>
  401990:	00 
  401991:	49 83 c7 08          	add    r15,0x8
  401995:	48 8d 84 24 78 06 00 	lea    rax,[rsp+0x678]
  40199c:	00 
  40199d:	f2 41 0f 11 47 f8    	movsd  QWORD PTR [r15-0x8],xmm0
  4019a3:	4c 39 f8             	cmp    rax,r15
  4019a6:	0f 85 5e ff ff ff    	jne    40190a <main+0x87a>
  4019ac:	f2 0f 10 84 24 68 06 	movsd  xmm0,QWORD PTR [rsp+0x668]
  4019b3:	00 00 
  4019b5:	f2 0f 10 8c 24 60 06 	movsd  xmm1,QWORD PTR [rsp+0x660]
  4019bc:	00 00 
  4019be:	f2 0f 10 94 24 70 06 	movsd  xmm2,QWORD PTR [rsp+0x670]
  4019c5:	00 00 
  4019c7:	66 0f 2f c8          	comisd xmm1,xmm0
  4019cb:	0f 86 9d 00 00 00    	jbe    401a6e <main+0x9de>
  4019d1:	66 0f 2f c2          	comisd xmm0,xmm2
  4019d5:	77 08                	ja     4019df <main+0x94f>
  4019d7:	f2 0f 5d d1          	minsd  xmm2,xmm1
  4019db:	66 0f 28 c2          	movapd xmm0,xmm2
  4019df:	66 0f ef c9          	pxor   xmm1,xmm1
  4019e3:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  4019e8:	8b 4c 24 1c          	mov    ecx,DWORD PTR [rsp+0x1c]
  4019ec:	bf 6d 70 40 00       	mov    edi,0x40706d
  4019f1:	f2 0f 2a cd          	cvtsi2sd xmm1,ebp
  4019f5:	8b 54 24 18          	mov    edx,DWORD PTR [rsp+0x18]
  4019f9:	48 83 c5 01          	add    rbp,0x1
  4019fd:	48 8b 74 04 30       	mov    rsi,QWORD PTR [rsp+rax*1+0x30]
  401a02:	b8 02 00 00 00       	mov    eax,0x2
  401a07:	f2 0f 5e c8          	divsd  xmm1,xmm0
  401a0b:	e8 40 f6 ff ff       	call   401050 <printf@plt>
  401a10:	48 81 fd 01 01 00 00 	cmp    rbp,0x101
  401a17:	0f 85 d3 fe ff ff    	jne    4018f0 <main+0x860>
  401a1d:	48 83 44 24 10 08    	add    QWORD PTR [rsp+0x10],0x8
  401a23:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  401a28:	48 83 f8 18          	cmp    rax,0x18
  401a2c:	0f 85 b8 fe ff ff    	jne    4018ea <main+0x85a>
  401a32:	48 8b 7c 24 28       	mov    rdi,QWORD PTR [rsp+0x28]
  401a37:	e8 f4 f5 ff ff       	call   401030 <free@plt>
  401a3c:	48 81 c4 b8 0a 00 00 	add    rsp,0xab8
  401a43:	31 c0                	xor    eax,eax
  401a45:	5b                   	pop    rbx
  401a46:	5d                   	pop    rbp
  401a47:	41 5c                	pop    r12
  401a49:	41 5d                	pop    r13
  401a4b:	41 5e                	pop    r14
  401a4d:	41 5f                	pop    r15
  401a4f:	c3                   	ret    
  401a50:	48 89 c2             	mov    rdx,rax
  401a53:	83 e0 01             	and    eax,0x1
  401a56:	66 0f ef c0          	pxor   xmm0,xmm0
  401a5a:	48 d1 ea             	shr    rdx,1
  401a5d:	48 09 c2             	or     rdx,rax
  401a60:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
  401a65:	f2 0f 58 c0          	addsd  xmm0,xmm0
  401a69:	e9 1b ff ff ff       	jmp    401989 <main+0x8f9>
  401a6e:	66 0f 2f ca          	comisd xmm1,xmm2
  401a72:	77 0d                	ja     401a81 <main+0x9f1>
  401a74:	f2 0f 5d d0          	minsd  xmm2,xmm0
  401a78:	66 0f 28 c2          	movapd xmm0,xmm2
  401a7c:	e9 5e ff ff ff       	jmp    4019df <main+0x94f>
  401a81:	66 0f 28 c1          	movapd xmm0,xmm1
  401a85:	e9 55 ff ff ff       	jmp    4019df <main+0x94f>
  401a8a:	48 89 c2             	mov    rdx,rax
  401a8d:	83 e0 01             	and    eax,0x1
  401a90:	66 0f ef c0          	pxor   xmm0,xmm0
  401a94:	48 d1 ea             	shr    rdx,1
  401a97:	48 09 c2             	or     rdx,rax
  401a9a:	f2 48 0f 2a c2       	cvtsi2sd xmm0,rdx
  401a9f:	f2 0f 58 c0          	addsd  xmm0,xmm0
  401aa3:	e9 90 fd ff ff       	jmp    401838 <main+0x7a8>
  401aa8:	66 0f 2f ca          	comisd xmm1,xmm2
  401aac:	77 0d                	ja     401abb <main+0xa2b>
  401aae:	f2 0f 5d d0          	minsd  xmm2,xmm0
  401ab2:	66 0f 28 c2          	movapd xmm0,xmm2
  401ab6:	e9 d3 fd ff ff       	jmp    40188e <main+0x7fe>
  401abb:	66 0f 28 c1          	movapd xmm0,xmm1
  401abf:	e9 ca fd ff ff       	jmp    40188e <main+0x7fe>
  401ac4:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  401acb:	00 00 00 
  401ace:	66 90                	xchg   ax,ax

0000000000401ad0 <_start>:
  401ad0:	f3 0f 1e fa          	endbr64 
  401ad4:	31 ed                	xor    ebp,ebp
  401ad6:	49 89 d1             	mov    r9,rdx
  401ad9:	5e                   	pop    rsi
  401ada:	48 89 e2             	mov    rdx,rsp
  401add:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
  401ae1:	50                   	push   rax
  401ae2:	54                   	push   rsp
  401ae3:	45 31 c0             	xor    r8d,r8d
  401ae6:	31 c9                	xor    ecx,ecx
  401ae8:	48 c7 c7 90 10 40 00 	mov    rdi,0x401090
  401aef:	ff 15 eb 74 00 00    	call   QWORD PTR [rip+0x74eb]        # 408fe0 <__libc_start_main@GLIBC_2.34>
  401af5:	f4                   	hlt    
  401af6:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  401afd:	00 00 00 

0000000000401b00 <_dl_relocate_static_pie>:
  401b00:	f3 0f 1e fa          	endbr64 
  401b04:	c3                   	ret    
  401b05:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  401b0c:	00 00 00 
  401b0f:	90                   	nop

0000000000401b10 <deregister_tm_clones>:
  401b10:	48 8d 3d 39 75 00 00 	lea    rdi,[rip+0x7539]        # 409050 <__TMC_END__>
  401b17:	48 8d 05 32 75 00 00 	lea    rax,[rip+0x7532]        # 409050 <__TMC_END__>
  401b1e:	48 39 f8             	cmp    rax,rdi
  401b21:	74 15                	je     401b38 <deregister_tm_clones+0x28>
  401b23:	48 8b 05 be 74 00 00 	mov    rax,QWORD PTR [rip+0x74be]        # 408fe8 <_ITM_deregisterTMCloneTable>
  401b2a:	48 85 c0             	test   rax,rax
  401b2d:	74 09                	je     401b38 <deregister_tm_clones+0x28>
  401b2f:	ff e0                	jmp    rax
  401b31:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  401b38:	c3                   	ret    
  401b39:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000401b40 <register_tm_clones>:
  401b40:	48 8d 3d 09 75 00 00 	lea    rdi,[rip+0x7509]        # 409050 <__TMC_END__>
  401b47:	48 8d 35 02 75 00 00 	lea    rsi,[rip+0x7502]        # 409050 <__TMC_END__>
  401b4e:	48 29 fe             	sub    rsi,rdi
  401b51:	48 89 f0             	mov    rax,rsi
  401b54:	48 c1 ee 3f          	shr    rsi,0x3f
  401b58:	48 c1 f8 03          	sar    rax,0x3
  401b5c:	48 01 c6             	add    rsi,rax
  401b5f:	48 d1 fe             	sar    rsi,1
  401b62:	74 14                	je     401b78 <register_tm_clones+0x38>
  401b64:	48 8b 05 8d 74 00 00 	mov    rax,QWORD PTR [rip+0x748d]        # 408ff8 <_ITM_registerTMCloneTable>
  401b6b:	48 85 c0             	test   rax,rax
  401b6e:	74 08                	je     401b78 <register_tm_clones+0x38>
  401b70:	ff e0                	jmp    rax
  401b72:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  401b78:	c3                   	ret    
  401b79:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000401b80 <__do_global_dtors_aux>:
  401b80:	f3 0f 1e fa          	endbr64 
  401b84:	80 3d d5 74 00 00 00 	cmp    BYTE PTR [rip+0x74d5],0x0        # 409060 <completed.0>
  401b8b:	75 13                	jne    401ba0 <__do_global_dtors_aux+0x20>
  401b8d:	55                   	push   rbp
  401b8e:	48 89 e5             	mov    rbp,rsp
  401b91:	e8 7a ff ff ff       	call   401b10 <deregister_tm_clones>
  401b96:	c6 05 c3 74 00 00 01 	mov    BYTE PTR [rip+0x74c3],0x1        # 409060 <completed.0>
  401b9d:	5d                   	pop    rbp
  401b9e:	c3                   	ret    
  401b9f:	90                   	nop
  401ba0:	c3                   	ret    
  401ba1:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  401ba8:	00 00 00 00 
  401bac:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401bb0 <frame_dummy>:
  401bb0:	f3 0f 1e fa          	endbr64 
  401bb4:	eb 8a                	jmp    401b40 <register_tm_clones>
  401bb6:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  401bbd:	00 00 00 

0000000000401bc0 <chv3_hwprod>:
  401bc0:	c4 e1 f9 6e c7       	vmovq  xmm0,rdi
  401bc5:	c4 e1 f9 6e ce       	vmovq  xmm1,rsi
  401bca:	c4 e3 79 44 d1 00    	vpclmullqlqdq xmm2,xmm0,xmm1
  401bd0:	c5 f9 7f 54 24 e8    	vmovdqa XMMWORD PTR [rsp-0x18],xmm2
  401bd6:	48 8b 44 24 e8       	mov    rax,QWORD PTR [rsp-0x18]
  401bdb:	48 8b 54 24 f0       	mov    rdx,QWORD PTR [rsp-0x10]
  401be0:	c3                   	ret    
  401be1:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  401be8:	00 00 00 00 
  401bec:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401bf0 <chv3_fastfinish>:
  401bf0:	48 03 b7 b8 01 00 00 	add    rsi,QWORD PTR [rdi+0x1b8]
  401bf7:	c5 f9 6f 0d 11 55 00 	vmovdqa xmm1,XMMWORD PTR [rip+0x5511]        # 407110 <__PRETTY_FUNCTION__.6+0x20>
  401bfe:	00 
  401bff:	c4 e1 f9 6e c6       	vmovq  xmm0,rsi
  401c04:	c4 e3 79 44 d8 00    	vpclmullqlqdq xmm3,xmm0,xmm0
  401c0a:	c4 e3 61 44 d1 11    	vpclmulhqhqdq xmm2,xmm3,xmm1
  401c10:	c4 e3 69 44 e1 11    	vpclmulhqhqdq xmm4,xmm2,xmm1
  401c16:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  401c1a:	c5 fa 7e a7 98 01 00 	vmovq  xmm4,QWORD PTR [rdi+0x198]
  401c21:	00 
  401c22:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  401c26:	c5 fa 7e 9f 90 01 00 	vmovq  xmm3,QWORD PTR [rdi+0x190]
  401c2d:	00 
  401c2e:	c5 d9 ef e0          	vpxor  xmm4,xmm4,xmm0
  401c32:	c5 e1 ef da          	vpxor  xmm3,xmm3,xmm2
  401c36:	c5 d9 ef d2          	vpxor  xmm2,xmm4,xmm2
  401c3a:	c4 e3 61 44 da 00    	vpclmullqlqdq xmm3,xmm3,xmm2
  401c40:	c5 fa 7e 97 a0 01 00 	vmovq  xmm2,QWORD PTR [rdi+0x1a0]
  401c47:	00 
  401c48:	c4 e3 61 44 e1 11    	vpclmulhqhqdq xmm4,xmm3,xmm1
  401c4e:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  401c52:	c5 fa 7e 87 a8 01 00 	vmovq  xmm0,QWORD PTR [rdi+0x1a8]
  401c59:	00 
  401c5a:	c4 e3 59 44 e9 11    	vpclmulhqhqdq xmm5,xmm4,xmm1
  401c60:	c5 d9 ef e5          	vpxor  xmm4,xmm4,xmm5
  401c64:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  401c68:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
  401c6c:	c4 e3 69 44 d0 00    	vpclmullqlqdq xmm2,xmm2,xmm0
  401c72:	c4 e3 69 44 c1 11    	vpclmulhqhqdq xmm0,xmm2,xmm1
  401c78:	c4 e3 79 44 c9 11    	vpclmulhqhqdq xmm1,xmm0,xmm1
  401c7e:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  401c82:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  401c86:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  401c8b:	48 33 87 b0 01 00 00 	xor    rax,QWORD PTR [rdi+0x1b0]
  401c92:	c3                   	ret    
  401c93:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  401c9a:	00 00 00 00 
  401c9e:	66 90                	xchg   ax,ax

0000000000401ca0 <chv3_tail512.constprop.0>:
  401ca0:	55                   	push   rbp
  401ca1:	49 89 f9             	mov    r9,rdi
  401ca4:	49 89 f0             	mov    r8,rsi
  401ca7:	48 89 e5             	mov    rbp,rsp
  401caa:	41 55                	push   r13
  401cac:	49 89 d5             	mov    r13,rdx
  401caf:	41 54                	push   r12
  401cb1:	53                   	push   rbx
  401cb2:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  401cb6:	48 83 ec 08          	sub    rsp,0x8
  401cba:	48 83 fe 30          	cmp    rsi,0x30
  401cbe:	0f 87 b4 02 00 00    	ja     401f78 <chv3_tail512.constprop.0+0x2d8>
  401cc4:	48 85 f6             	test   rsi,rsi
  401cc7:	0f 84 c3 00 00 00    	je     401d90 <chv3_tail512.constprop.0+0xf0>
  401ccd:	4c 8d 5e ff          	lea    r11,[rsi-0x1]
  401cd1:	49 c1 eb 04          	shr    r11,0x4
  401cd5:	41 83 c3 01          	add    r11d,0x1
  401cd9:	45 31 d2             	xor    r10d,r10d
  401cdc:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  401ce0:	48 8d 5c 24 88       	lea    rbx,[rsp-0x78]
  401ce5:	41 bc 01 00 00 00    	mov    r12d,0x1
  401ceb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  401cf0:	b8 80 00 00 00       	mov    eax,0x80
  401cf5:	49 39 c0             	cmp    r8,rax
  401cf8:	49 0f 46 c0          	cmovbe rax,r8
  401cfc:	49 83 f8 7f          	cmp    r8,0x7f
  401d00:	0f 86 e2 01 00 00    	jbe    401ee8 <chv3_tail512.constprop.0+0x248>
  401d06:	62 d1 fe 48 6f 09    	vmovdqu64 zmm1,ZMMWORD PTR [r9]
  401d0c:	62 d1 fe 48 6f 59 01 	vmovdqu64 zmm3,ZMMWORD PTR [r9+0x40]
  401d13:	44 89 d2             	mov    edx,r10d
  401d16:	62 f2 7d 48 5a 04 d5 	vbroadcasti32x4 zmm0,XMMWORD PTR [rdx*8+0x409660]
  401d1d:	60 96 40 00 
  401d21:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
  401d27:	62 f2 7d 48 5a 0c d5 	vbroadcasti32x4 zmm1,XMMWORD PTR [rdx*8+0x409670]
  401d2e:	70 96 40 00 
  401d32:	62 f1 75 48 ef cb    	vpxord zmm1,zmm1,zmm3
  401d38:	49 83 f8 3f          	cmp    r8,0x3f
  401d3c:	0f 87 76 01 00 00    	ja     401eb8 <chv3_tail512.constprop.0+0x218>
  401d42:	48 8d 48 07          	lea    rcx,[rax+0x7]
  401d46:	44 89 e2             	mov    edx,r12d
  401d49:	49 01 c1             	add    r9,rax
  401d4c:	41 83 c2 04          	add    r10d,0x4
  401d50:	48 c1 e9 03          	shr    rcx,0x3
  401d54:	d3 e2                	shl    edx,cl
  401d56:	8d 72 ff             	lea    esi,[rdx-0x1]
  401d59:	c5 f8 92 ce          	kmovw  k1,esi
  401d5d:	62 f1 fd c9 6f d8    	vmovdqa64 zmm3{k1}{z},zmm0
  401d63:	62 f1 fd c9 6f c1    	vmovdqa64 zmm0{k1}{z},zmm1
  401d69:	62 f3 65 48 44 c8 11 	vpclmulhqhqdq zmm1,zmm3,zmm0
  401d70:	62 f3 65 48 44 d8 00 	vpclmullqlqdq zmm3,zmm3,zmm0
  401d77:	62 f3 e5 48 25 d1 96 	vpternlogq zmm2,zmm3,zmm1,0x96
  401d7e:	49 29 c0             	sub    r8,rax
  401d81:	0f 85 69 ff ff ff    	jne    401cf0 <chv3_tail512.constprop.0+0x50>
  401d87:	eb 11                	jmp    401d9a <chv3_tail512.constprop.0+0xfa>
  401d89:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  401d90:	41 bb 01 00 00 00    	mov    r11d,0x1
  401d96:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  401d9a:	31 d2                	xor    edx,edx
  401d9c:	41 8d 43 ff          	lea    eax,[r11-0x1]
  401da0:	45 85 db             	test   r11d,r11d
  401da3:	c4 a1 7a 7e 1c dd 60 	vmovq  xmm3,QWORD PTR [r11*8+0x409760]
  401daa:	97 40 00 
  401dad:	48 0f 44 c2          	cmove  rax,rdx
  401db1:	c5 fa 6f 24 c5 60 97 	vmovdqu xmm4,XMMWORD PTR [rax*8+0x409760]
  401db8:	40 00 
  401dba:	c5 d9 c6 04 c5 a0 97 	vshufpd xmm0,xmm4,XMMWORD PTR [rax*8+0x4097a0],0x2
  401dc1:	40 00 02 
  401dc4:	b8 02 00 00 00       	mov    eax,0x2
  401dc9:	c5 f9 7f 44 24 88    	vmovdqa XMMWORD PTR [rsp-0x78],xmm0
  401dcf:	41 39 c3             	cmp    r11d,eax
  401dd2:	41 0f 43 c3          	cmovae eax,r11d
  401dd6:	83 e8 02             	sub    eax,0x2
  401dd9:	c5 fa 6f 2c c5 60 97 	vmovdqu xmm5,XMMWORD PTR [rax*8+0x409760]
  401de0:	40 00 
  401de2:	c5 d1 c6 04 c5 a0 97 	vshufpd xmm0,xmm5,XMMWORD PTR [rax*8+0x4097a0],0x2
  401de9:	40 00 02 
  401dec:	b8 03 00 00 00       	mov    eax,0x3
  401df1:	c5 f9 7f 44 24 98    	vmovdqa XMMWORD PTR [rsp-0x68],xmm0
  401df7:	41 39 c3             	cmp    r11d,eax
  401dfa:	41 0f 43 c3          	cmovae eax,r11d
  401dfe:	83 e8 03             	sub    eax,0x3
  401e01:	c5 fa 6f 34 c5 60 97 	vmovdqu xmm6,XMMWORD PTR [rax*8+0x409760]
  401e08:	40 00 
  401e0a:	c5 c9 c6 04 c5 a0 97 	vshufpd xmm0,xmm6,XMMWORD PTR [rax*8+0x4097a0],0x2
  401e11:	40 00 02 
  401e14:	b8 04 00 00 00       	mov    eax,0x4
  401e19:	c5 f9 7f 44 24 a8    	vmovdqa XMMWORD PTR [rsp-0x58],xmm0
  401e1f:	41 39 c3             	cmp    r11d,eax
  401e22:	41 0f 43 c3          	cmovae eax,r11d
  401e26:	83 e8 04             	sub    eax,0x4
  401e29:	c5 fa 6f 3c c5 60 97 	vmovdqu xmm7,XMMWORD PTR [rax*8+0x409760]
  401e30:	40 00 
  401e32:	c5 c1 c6 04 c5 a0 97 	vshufpd xmm0,xmm7,XMMWORD PTR [rax*8+0x4097a0],0x2
  401e39:	40 00 02 
  401e3c:	c5 f9 7f 44 24 b8    	vmovdqa XMMWORD PTR [rsp-0x48],xmm0
  401e42:	62 f3 6d 48 44 84 24 	vpclmulhqhqdq zmm0,zmm2,ZMMWORD PTR [rsp-0x78]
  401e49:	88 ff ff ff 11 
  401e4e:	62 f3 6d 48 44 94 24 	vpclmullqlqdq zmm2,zmm2,ZMMWORD PTR [rsp-0x78]
  401e55:	88 ff ff ff 00 
  401e5a:	62 f1 6d 48 ef d0    	vpxord zmm2,zmm2,zmm0
  401e60:	62 f3 fd 48 3b d0 01 	vextracti64x4 ymm0,zmm2,0x1
  401e67:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
  401e6b:	c4 c1 f9 6e d5       	vmovq  xmm2,r13
  401e70:	c4 e3 7d 39 c1 01    	vextracti128 xmm1,ymm0,0x1
  401e76:	c4 e3 69 44 d3 00    	vpclmullqlqdq xmm2,xmm2,xmm3
  401e7c:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  401e80:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  401e84:	c5 fb 12 15 84 52 00 	vmovddup xmm2,QWORD PTR [rip+0x5284]        # 407110 <__PRETTY_FUNCTION__.6+0x20>
  401e8b:	00 
  401e8c:	c4 e3 71 44 c2 11    	vpclmulhqhqdq xmm0,xmm1,xmm2
  401e92:	c4 e3 79 44 d2 11    	vpclmulhqhqdq xmm2,xmm0,xmm2
  401e98:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  401e9c:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  401ea0:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  401ea5:	c5 f8 77             	vzeroupper 
  401ea8:	48 8d 65 e8          	lea    rsp,[rbp-0x18]
  401eac:	5b                   	pop    rbx
  401ead:	41 5c                	pop    r12
  401eaf:	41 5d                	pop    r13
  401eb1:	5d                   	pop    rbp
  401eb2:	c3                   	ret    
  401eb3:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  401eb8:	62 f3 7d 48 44 d9 11 	vpclmulhqhqdq zmm3,zmm0,zmm1
  401ebf:	49 01 c1             	add    r9,rax
  401ec2:	41 83 c2 04          	add    r10d,0x4
  401ec6:	62 f3 7d 48 44 c1 00 	vpclmullqlqdq zmm0,zmm0,zmm1
  401ecd:	62 f3 fd 48 25 d3 96 	vpternlogq zmm2,zmm0,zmm3,0x96
  401ed4:	49 29 c0             	sub    r8,rax
  401ed7:	0f 85 13 fe ff ff    	jne    401cf0 <chv3_tail512.constprop.0+0x50>
  401edd:	e9 b8 fe ff ff       	jmp    401d9a <chv3_tail512.constprop.0+0xfa>
  401ee2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  401ee8:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  401eec:	48 89 df             	mov    rdi,rbx
  401eef:	4c 89 ce             	mov    rsi,r9
  401ef2:	c5 f9 7f 44 24 88    	vmovdqa XMMWORD PTR [rsp-0x78],xmm0
  401ef8:	c5 f9 7f 44 24 98    	vmovdqa XMMWORD PTR [rsp-0x68],xmm0
  401efe:	c5 f9 7f 44 24 a8    	vmovdqa XMMWORD PTR [rsp-0x58],xmm0
  401f04:	c5 f9 7f 44 24 b8    	vmovdqa XMMWORD PTR [rsp-0x48],xmm0
  401f0a:	c5 f9 7f 44 24 c8    	vmovdqa XMMWORD PTR [rsp-0x38],xmm0
  401f10:	c5 f9 7f 44 24 d8    	vmovdqa XMMWORD PTR [rsp-0x28],xmm0
  401f16:	c5 f9 7f 44 24 e8    	vmovdqa XMMWORD PTR [rsp-0x18],xmm0
  401f1c:	c5 f9 7f 44 24 f8    	vmovdqa XMMWORD PTR [rsp-0x8],xmm0
  401f22:	83 f8 08             	cmp    eax,0x8
  401f25:	72 08                	jb     401f2f <chv3_tail512.constprop.0+0x28f>
  401f27:	89 c1                	mov    ecx,eax
  401f29:	c1 e9 03             	shr    ecx,0x3
  401f2c:	f3 48 a5             	rep movs QWORD PTR es:[rdi],QWORD PTR ds:[rsi]
  401f2f:	31 d2                	xor    edx,edx
  401f31:	a8 04                	test   al,0x4
  401f33:	74 09                	je     401f3e <chv3_tail512.constprop.0+0x29e>
  401f35:	8b 16                	mov    edx,DWORD PTR [rsi]
  401f37:	89 17                	mov    DWORD PTR [rdi],edx
  401f39:	ba 04 00 00 00       	mov    edx,0x4
  401f3e:	a8 02                	test   al,0x2
  401f40:	74 0c                	je     401f4e <chv3_tail512.constprop.0+0x2ae>
  401f42:	0f b7 0c 16          	movzx  ecx,WORD PTR [rsi+rdx*1]
  401f46:	66 89 0c 17          	mov    WORD PTR [rdi+rdx*1],cx
  401f4a:	48 83 c2 02          	add    rdx,0x2
  401f4e:	a8 01                	test   al,0x1
  401f50:	74 07                	je     401f59 <chv3_tail512.constprop.0+0x2b9>
  401f52:	0f b6 0c 16          	movzx  ecx,BYTE PTR [rsi+rdx*1]
  401f56:	88 0c 17             	mov    BYTE PTR [rdi+rdx*1],cl
  401f59:	62 f1 fd 48 6f 8c 24 	vmovdqa64 zmm1,ZMMWORD PTR [rsp-0x78]
  401f60:	88 ff ff ff 
  401f64:	62 f1 fd 48 6f 9c 24 	vmovdqa64 zmm3,ZMMWORD PTR [rsp-0x38]
  401f6b:	c8 ff ff ff 
  401f6f:	e9 9f fd ff ff       	jmp    401d13 <chv3_tail512.constprop.0+0x73>
  401f74:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  401f78:	41 bb 04 00 00 00    	mov    r11d,0x4
  401f7e:	e9 56 fd ff ff       	jmp    401cd9 <chv3_tail512.constprop.0+0x39>
  401f83:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  401f8a:	00 00 00 00 
  401f8e:	66 90                	xchg   ax,ax

0000000000401f90 <chv3_bulk256.constprop.0>:
  401f90:	c5 fa 7e 2d e8 77 00 	vmovq  xmm5,QWORD PTR [rip+0x77e8]        # 409780 <v3+0x120>
  401f97:	00 
  401f98:	c4 e1 f9 6e c2       	vmovq  xmm0,rdx
  401f9d:	c5 d9 ef e4          	vpxor  xmm4,xmm4,xmm4
  401fa1:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  401fa5:	c4 e3 d1 22 2d 19 78 	vpinsrq xmm5,xmm5,QWORD PTR [rip+0x7819],0x1        # 4097c8 <v3+0x168>
  401fac:	00 00 01 
  401faf:	c4 e3 5d 38 e0 01    	vinserti128 ymm4,ymm4,xmm0,0x1
  401fb5:	c4 e3 55 38 ed 01    	vinserti128 ymm5,ymm5,xmm5,0x1
  401fbb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  401fc0:	c4 e2 7d 5a 05 97 76 	vbroadcasti128 ymm0,XMMWORD PTR [rip+0x7697]        # 409660 <v3>
  401fc7:	00 00 
  401fc9:	c4 e2 7d 5a 15 9e 76 	vbroadcasti128 ymm2,XMMWORD PTR [rip+0x769e]        # 409670 <v3+0x10>
  401fd0:	00 00 
  401fd2:	c5 fd ef 0f          	vpxor  ymm1,ymm0,YMMWORD PTR [rdi]
  401fd6:	c5 ed ef 77 40       	vpxor  ymm6,ymm2,YMMWORD PTR [rdi+0x40]
  401fdb:	c5 fd ef 47 20       	vpxor  ymm0,ymm0,YMMWORD PTR [rdi+0x20]
  401fe0:	c4 63 75 44 c6 11    	vpclmulhqhqdq ymm8,ymm1,ymm6
  401fe6:	c4 e3 75 44 fe 00    	vpclmullqlqdq ymm7,ymm1,ymm6
  401fec:	c5 ed ef 4f 60       	vpxor  ymm1,ymm2,YMMWORD PTR [rdi+0x60]
  401ff1:	c4 e3 7d 44 d1 11    	vpclmulhqhqdq ymm2,ymm0,ymm1
  401ff7:	c4 e3 7d 44 c9 00    	vpclmullqlqdq ymm1,ymm0,ymm1
  401ffd:	c4 c1 45 ef f8       	vpxor  ymm7,ymm7,ymm8
  402002:	c5 f5 ef ca          	vpxor  ymm1,ymm1,ymm2
  402006:	c4 e2 7d 5a 15 71 76 	vbroadcasti128 ymm2,XMMWORD PTR [rip+0x7671]        # 409680 <v3+0x20>
  40200d:	00 00 
  40200f:	c4 62 7d 5a 05 78 76 	vbroadcasti128 ymm8,XMMWORD PTR [rip+0x7678]        # 409690 <v3+0x30>
  402016:	00 00 
  402018:	c5 ed ef 87 80 00 00 	vpxor  ymm0,ymm2,YMMWORD PTR [rdi+0x80]
  40201f:	00 
  402020:	c5 bd ef b7 c0 00 00 	vpxor  ymm6,ymm8,YMMWORD PTR [rdi+0xc0]
  402027:	00 
  402028:	c5 ed ef 97 a0 00 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rdi+0xa0]
  40202f:	00 
  402030:	c4 63 7d 44 ce 11    	vpclmulhqhqdq ymm9,ymm0,ymm6
  402036:	c4 e3 7d 44 f6 00    	vpclmullqlqdq ymm6,ymm0,ymm6
  40203c:	c5 bd ef 87 e0 00 00 	vpxor  ymm0,ymm8,YMMWORD PTR [rdi+0xe0]
  402043:	00 
  402044:	c4 c1 4d ef f1       	vpxor  ymm6,ymm6,ymm9
  402049:	c5 cd ef f7          	vpxor  ymm6,ymm6,ymm7
  40204d:	c4 e3 6d 44 f8 11    	vpclmulhqhqdq ymm7,ymm2,ymm0
  402053:	c4 e3 6d 44 c0 00    	vpclmullqlqdq ymm0,ymm2,ymm0
  402059:	c5 fd ef c7          	vpxor  ymm0,ymm0,ymm7
  40205d:	c5 fd ef c1          	vpxor  ymm0,ymm0,ymm1
  402061:	c4 e2 7d 5a 15 36 76 	vbroadcasti128 ymm2,XMMWORD PTR [rip+0x7636]        # 4096a0 <v3+0x40>
  402068:	00 00 
  40206a:	c4 62 7d 5a 05 3d 76 	vbroadcasti128 ymm8,XMMWORD PTR [rip+0x763d]        # 4096b0 <v3+0x50>
  402071:	00 00 
  402073:	c5 ed ef 8f 00 01 00 	vpxor  ymm1,ymm2,YMMWORD PTR [rdi+0x100]
  40207a:	00 
  40207b:	c5 bd ef bf 40 01 00 	vpxor  ymm7,ymm8,YMMWORD PTR [rdi+0x140]
  402082:	00 
  402083:	c5 ed ef 97 20 01 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rdi+0x120]
  40208a:	00 
  40208b:	c4 63 75 44 cf 11    	vpclmulhqhqdq ymm9,ymm1,ymm7
  402091:	c4 e3 75 44 ff 00    	vpclmullqlqdq ymm7,ymm1,ymm7
  402097:	c5 bd ef 8f 60 01 00 	vpxor  ymm1,ymm8,YMMWORD PTR [rdi+0x160]
  40209e:	00 
  40209f:	c4 c1 45 ef f9       	vpxor  ymm7,ymm7,ymm9
  4020a4:	c5 c5 ef fe          	vpxor  ymm7,ymm7,ymm6
  4020a8:	c4 e3 6d 44 f1 11    	vpclmulhqhqdq ymm6,ymm2,ymm1
  4020ae:	c4 e3 6d 44 c9 00    	vpclmullqlqdq ymm1,ymm2,ymm1
  4020b4:	c5 f5 ef ce          	vpxor  ymm1,ymm1,ymm6
  4020b8:	c5 f5 ef c8          	vpxor  ymm1,ymm1,ymm0
  4020bc:	c4 e2 7d 5a 15 fb 75 	vbroadcasti128 ymm2,XMMWORD PTR [rip+0x75fb]        # 4096c0 <v3+0x60>
  4020c3:	00 00 
  4020c5:	c4 62 7d 5a 05 02 76 	vbroadcasti128 ymm8,XMMWORD PTR [rip+0x7602]        # 4096d0 <v3+0x70>
  4020cc:	00 00 
  4020ce:	c5 ed ef 87 80 01 00 	vpxor  ymm0,ymm2,YMMWORD PTR [rdi+0x180]
  4020d5:	00 
  4020d6:	c5 bd ef b7 c0 01 00 	vpxor  ymm6,ymm8,YMMWORD PTR [rdi+0x1c0]
  4020dd:	00 
  4020de:	c5 ed ef 97 a0 01 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rdi+0x1a0]
  4020e5:	00 
  4020e6:	c4 63 7d 44 ce 11    	vpclmulhqhqdq ymm9,ymm0,ymm6
  4020ec:	c4 e3 7d 44 f6 00    	vpclmullqlqdq ymm6,ymm0,ymm6
  4020f2:	c5 bd ef 87 e0 01 00 	vpxor  ymm0,ymm8,YMMWORD PTR [rdi+0x1e0]
  4020f9:	00 
  4020fa:	c4 c1 4d ef f1       	vpxor  ymm6,ymm6,ymm9
  4020ff:	c5 cd ef f7          	vpxor  ymm6,ymm6,ymm7
  402103:	c4 e3 6d 44 f8 11    	vpclmulhqhqdq ymm7,ymm2,ymm0
  402109:	c4 e3 6d 44 c0 00    	vpclmullqlqdq ymm0,ymm2,ymm0
  40210f:	c5 fd ef c7          	vpxor  ymm0,ymm0,ymm7
  402113:	c5 fd ef c1          	vpxor  ymm0,ymm0,ymm1
  402117:	c4 e2 7d 5a 15 c0 75 	vbroadcasti128 ymm2,XMMWORD PTR [rip+0x75c0]        # 4096e0 <v3+0x80>
  40211e:	00 00 
  402120:	c4 62 7d 5a 05 c7 75 	vbroadcasti128 ymm8,XMMWORD PTR [rip+0x75c7]        # 4096f0 <v3+0x90>
  402127:	00 00 
  402129:	c5 ed ef 8f 00 02 00 	vpxor  ymm1,ymm2,YMMWORD PTR [rdi+0x200]
  402130:	00 
  402131:	c5 bd ef bf 40 02 00 	vpxor  ymm7,ymm8,YMMWORD PTR [rdi+0x240]
  402138:	00 
  402139:	c5 ed ef 97 20 02 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rdi+0x220]
  402140:	00 
  402141:	c4 63 75 44 cf 11    	vpclmulhqhqdq ymm9,ymm1,ymm7
  402147:	c4 e3 75 44 ff 00    	vpclmullqlqdq ymm7,ymm1,ymm7
  40214d:	c5 bd ef 8f 60 02 00 	vpxor  ymm1,ymm8,YMMWORD PTR [rdi+0x260]
  402154:	00 
  402155:	c4 c1 45 ef f9       	vpxor  ymm7,ymm7,ymm9
  40215a:	c5 c5 ef fe          	vpxor  ymm7,ymm7,ymm6
  40215e:	c4 e3 6d 44 f1 11    	vpclmulhqhqdq ymm6,ymm2,ymm1
  402164:	c4 e3 6d 44 c9 00    	vpclmullqlqdq ymm1,ymm2,ymm1
  40216a:	c5 f5 ef ce          	vpxor  ymm1,ymm1,ymm6
  40216e:	c5 f5 ef c8          	vpxor  ymm1,ymm1,ymm0
  402172:	c4 e2 7d 5a 15 85 75 	vbroadcasti128 ymm2,XMMWORD PTR [rip+0x7585]        # 409700 <v3+0xa0>
  402179:	00 00 
  40217b:	c4 62 7d 5a 05 8c 75 	vbroadcasti128 ymm8,XMMWORD PTR [rip+0x758c]        # 409710 <v3+0xb0>
  402182:	00 00 
  402184:	c5 ed ef 87 80 02 00 	vpxor  ymm0,ymm2,YMMWORD PTR [rdi+0x280]
  40218b:	00 
  40218c:	c5 bd ef b7 c0 02 00 	vpxor  ymm6,ymm8,YMMWORD PTR [rdi+0x2c0]
  402193:	00 
  402194:	c5 ed ef 97 a0 02 00 	vpxor  ymm2,ymm2,YMMWORD PTR [rdi+0x2a0]
  40219b:	00 
  40219c:	c4 63 7d 44 ce 11    	vpclmulhqhqdq ymm9,ymm0,ymm6
  4021a2:	c4 e3 7d 44 f6 00    	vpclmullqlqdq ymm6,ymm0,ymm6
  4021a8:	c5 bd ef 87 e0 02 00 	vpxor  ymm0,ymm8,YMMWORD PTR [rdi+0x2e0]
  4021af:	00 
  4021b0:	c4 c1 4d ef f1       	vpxor  ymm6,ymm6,ymm9
  4021b5:	c5 cd ef f7          	vpxor  ymm6,ymm6,ymm7
  4021b9:	c4 e3 6d 44 f8 11    	vpclmulhqhqdq ymm7,ymm2,ymm0
  4021bf:	c4 e3 6d 44 c0 00    	vpclmullqlqdq ymm0,ymm2,ymm0
  4021c5:	c5 fd ef c7          	vpxor  ymm0,ymm0,ymm7
  4021c9:	c5 fd ef c1          	vpxor  ymm0,ymm0,ymm1
  4021cd:	c4 e2 7d 5a 0d 4a 75 	vbroadcasti128 ymm1,XMMWORD PTR [rip+0x754a]        # 409720 <v3+0xc0>
  4021d4:	00 00 
  4021d6:	c4 62 7d 5a 05 51 75 	vbroadcasti128 ymm8,XMMWORD PTR [rip+0x7551]        # 409730 <v3+0xd0>
  4021dd:	00 00 
  4021df:	c5 f5 ef 97 00 03 00 	vpxor  ymm2,ymm1,YMMWORD PTR [rdi+0x300]
  4021e6:	00 
  4021e7:	c5 bd ef bf 40 03 00 	vpxor  ymm7,ymm8,YMMWORD PTR [rdi+0x340]
  4021ee:	00 
  4021ef:	c5 f5 ef 8f 20 03 00 	vpxor  ymm1,ymm1,YMMWORD PTR [rdi+0x320]
  4021f6:	00 
  4021f7:	c4 63 6d 44 cf 11    	vpclmulhqhqdq ymm9,ymm2,ymm7
  4021fd:	c4 e3 6d 44 ff 00    	vpclmullqlqdq ymm7,ymm2,ymm7
  402203:	c5 bd ef 97 60 03 00 	vpxor  ymm2,ymm8,YMMWORD PTR [rdi+0x360]
  40220a:	00 
  40220b:	c4 c1 45 ef f9       	vpxor  ymm7,ymm7,ymm9
  402210:	c5 c5 ef fe          	vpxor  ymm7,ymm7,ymm6
  402214:	c4 e3 75 44 f2 11    	vpclmulhqhqdq ymm6,ymm1,ymm2
  40221a:	c4 e3 75 44 d2 00    	vpclmullqlqdq ymm2,ymm1,ymm2
  402220:	c5 ed ef d6          	vpxor  ymm2,ymm2,ymm6
  402224:	c5 ed ef d0          	vpxor  ymm2,ymm2,ymm0
  402228:	c4 e2 7d 5a 0d 0f 75 	vbroadcasti128 ymm1,XMMWORD PTR [rip+0x750f]        # 409740 <v3+0xe0>
  40222f:	00 00 
  402231:	c4 62 7d 5a 05 16 75 	vbroadcasti128 ymm8,XMMWORD PTR [rip+0x7516]        # 409750 <v3+0xf0>
  402238:	00 00 
  40223a:	c5 f5 ef 87 80 03 00 	vpxor  ymm0,ymm1,YMMWORD PTR [rdi+0x380]
  402241:	00 
  402242:	c5 bd ef b7 c0 03 00 	vpxor  ymm6,ymm8,YMMWORD PTR [rdi+0x3c0]
  402249:	00 
  40224a:	48 81 c7 00 04 00 00 	add    rdi,0x400
  402251:	c5 f5 ef 4f a0       	vpxor  ymm1,ymm1,YMMWORD PTR [rdi-0x60]
  402256:	c4 63 7d 44 ce 11    	vpclmulhqhqdq ymm9,ymm0,ymm6
  40225c:	c4 e3 7d 44 f6 00    	vpclmullqlqdq ymm6,ymm0,ymm6
  402262:	c5 bd ef 47 e0       	vpxor  ymm0,ymm8,YMMWORD PTR [rdi-0x20]
  402267:	c4 c1 4d ef f1       	vpxor  ymm6,ymm6,ymm9
  40226c:	c5 cd ef f7          	vpxor  ymm6,ymm6,ymm7
  402270:	c4 e3 75 44 f8 11    	vpclmulhqhqdq ymm7,ymm1,ymm0
  402276:	c4 e3 75 44 c0 00    	vpclmullqlqdq ymm0,ymm1,ymm0
  40227c:	c4 e3 65 44 cd 11    	vpclmulhqhqdq ymm1,ymm3,ymm5
  402282:	c4 e3 65 44 dd 00    	vpclmullqlqdq ymm3,ymm3,ymm5
  402288:	c5 fd ef c7          	vpxor  ymm0,ymm0,ymm7
  40228c:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
  402290:	c5 e5 ef d9          	vpxor  ymm3,ymm3,ymm1
  402294:	c4 e3 5d 44 cd 11    	vpclmulhqhqdq ymm1,ymm4,ymm5
  40229a:	c5 e5 ef de          	vpxor  ymm3,ymm3,ymm6
  40229e:	c4 e3 5d 44 e5 00    	vpclmullqlqdq ymm4,ymm4,ymm5
  4022a4:	c5 dd ef e1          	vpxor  ymm4,ymm4,ymm1
  4022a8:	c5 dd ef e0          	vpxor  ymm4,ymm4,ymm0
  4022ac:	48 83 ee 01          	sub    rsi,0x1
  4022b0:	0f 85 0a fd ff ff    	jne    401fc0 <chv3_bulk256.constprop.0+0x30>
  4022b6:	c5 fa 7e 2d b2 74 00 	vmovq  xmm5,QWORD PTR [rip+0x74b2]        # 409770 <v3+0x110>
  4022bd:	00 
  4022be:	c5 fd 6f 3d da 74 00 	vmovdqa ymm7,YMMWORD PTR [rip+0x74da]        # 4097a0 <v3+0x140>
  4022c5:	00 
  4022c6:	c4 e3 d1 22 0d e8 74 	vpinsrq xmm1,xmm5,QWORD PTR [rip+0x74e8],0x1        # 4097b8 <v3+0x158>
  4022cd:	00 00 01 
  4022d0:	c5 fa 7e 2d a0 74 00 	vmovq  xmm5,QWORD PTR [rip+0x74a0]        # 409778 <v3+0x118>
  4022d7:	00 
  4022d8:	c4 e3 d1 22 05 de 74 	vpinsrq xmm0,xmm5,QWORD PTR [rip+0x74de],0x1        # 4097c0 <v3+0x160>
  4022df:	00 00 01 
  4022e2:	c5 fd 6f 15 76 74 00 	vmovdqa ymm2,YMMWORD PTR [rip+0x7476]        # 409760 <v3+0x100>
  4022e9:	00 
  4022ea:	c4 e2 6d 00 15 ed 4e 	vpshufb ymm2,ymm2,YMMWORD PTR [rip+0x4eed]        # 4071e0 <__PRETTY_FUNCTION__.6+0xf0>
  4022f1:	00 00 
  4022f3:	c4 e3 7d 38 c1 01    	vinserti128 ymm0,ymm0,xmm1,0x1
  4022f9:	c4 e2 45 00 0d fe 4e 	vpshufb ymm1,ymm7,YMMWORD PTR [rip+0x4efe]        # 407200 <__PRETTY_FUNCTION__.6+0x110>
  402300:	00 00 
  402302:	c5 fd 6f 3d 56 74 00 	vmovdqa ymm7,YMMWORD PTR [rip+0x7456]        # 409760 <v3+0x100>
  402309:	00 
  40230a:	c4 e3 65 44 e8 11    	vpclmulhqhqdq ymm5,ymm3,ymm0
  402310:	c4 e3 fd 00 d2 4e    	vpermq ymm2,ymm2,0x4e
  402316:	c4 e3 fd 00 c9 4e    	vpermq ymm1,ymm1,0x4e
  40231c:	c4 e3 65 44 d8 00    	vpclmullqlqdq ymm3,ymm3,ymm0
  402322:	c4 e2 45 00 05 f5 4e 	vpshufb ymm0,ymm7,YMMWORD PTR [rip+0x4ef5]        # 407220 <__PRETTY_FUNCTION__.6+0x130>
  402329:	00 00 
  40232b:	c5 fd eb c2          	vpor   ymm0,ymm0,ymm2
  40232f:	c5 f9 6f 15 d9 4d 00 	vmovdqa xmm2,XMMWORD PTR [rip+0x4dd9]        # 407110 <__PRETTY_FUNCTION__.6+0x20>
  402336:	00 
  402337:	c5 fd eb c1          	vpor   ymm0,ymm0,ymm1
  40233b:	c4 e3 5d 44 c8 11    	vpclmulhqhqdq ymm1,ymm4,ymm0
  402341:	c4 e3 5d 44 e0 00    	vpclmullqlqdq ymm4,ymm4,ymm0
  402347:	c5 e5 ef dd          	vpxor  ymm3,ymm3,ymm5
  40234b:	c5 dd ef e1          	vpxor  ymm4,ymm4,ymm1
  40234f:	c5 e5 ef dc          	vpxor  ymm3,ymm3,ymm4
  402353:	c4 e3 7d 39 d9 01    	vextracti128 xmm1,ymm3,0x1
  402359:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  40235d:	c4 e3 71 44 c2 11    	vpclmulhqhqdq xmm0,xmm1,xmm2
  402363:	c4 e3 79 44 d2 11    	vpclmulhqhqdq xmm2,xmm0,xmm2
  402369:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  40236d:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  402371:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  402376:	c5 f8 77             	vzeroupper 
  402379:	c3                   	ret    
  40237a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000402380 <chv3_bulk128.constprop.0>:
  402380:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  402384:	c5 79 6f 0d 14 74 00 	vmovdqa xmm9,XMMWORD PTR [rip+0x7414]        # 4097a0 <v3+0x140>
  40238b:	00 
  40238c:	c5 79 6f 05 1c 74 00 	vmovdqa xmm8,XMMWORD PTR [rip+0x741c]        # 4097b0 <v3+0x150>
  402393:	00 
  402394:	c4 e1 f9 6e ca       	vmovq  xmm1,rdx
  402399:	c5 f9 6f da          	vmovdqa xmm3,xmm2
  40239d:	c5 f9 6f e2          	vmovdqa xmm4,xmm2
  4023a1:	c5 f9 6f 3d d7 73 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x73d7]        # 409780 <v3+0x120>
  4023a8:	00 
  4023a9:	c5 c1 c6 3d 0e 74 00 	vshufpd xmm7,xmm7,XMMWORD PTR [rip+0x740e],0x2        # 4097c0 <v3+0x160>
  4023b0:	00 02 
  4023b2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  4023b8:	c5 fa 6f 05 a0 72 00 	vmovdqu xmm0,XMMWORD PTR [rip+0x72a0]        # 409660 <v3>
  4023bf:	00 
  4023c0:	c5 fa 6f 35 a8 72 00 	vmovdqu xmm6,XMMWORD PTR [rip+0x72a8]        # 409670 <v3+0x10>
  4023c7:	00 
  4023c8:	c5 79 ef 17          	vpxor  xmm10,xmm0,XMMWORD PTR [rdi]
  4023cc:	c5 c9 ef 6f 40       	vpxor  xmm5,xmm6,XMMWORD PTR [rdi+0x40]
  4023d1:	c4 63 29 44 dd 11    	vpclmulhqhqdq xmm11,xmm10,xmm5
  4023d7:	c4 e3 29 44 ed 00    	vpclmullqlqdq xmm5,xmm10,xmm5
  4023dd:	c5 79 ef 57 10       	vpxor  xmm10,xmm0,XMMWORD PTR [rdi+0x10]
  4023e2:	c4 c1 51 ef eb       	vpxor  xmm5,xmm5,xmm11
  4023e7:	c5 49 ef 5f 50       	vpxor  xmm11,xmm6,XMMWORD PTR [rdi+0x50]
  4023ec:	c4 43 29 44 eb 11    	vpclmulhqhqdq xmm13,xmm10,xmm11
  4023f2:	c4 43 29 44 e3 00    	vpclmullqlqdq xmm12,xmm10,xmm11
  4023f8:	c5 79 ef 57 20       	vpxor  xmm10,xmm0,XMMWORD PTR [rdi+0x20]
  4023fd:	c5 49 ef 5f 60       	vpxor  xmm11,xmm6,XMMWORD PTR [rdi+0x60]
  402402:	c5 f9 ef 47 30       	vpxor  xmm0,xmm0,XMMWORD PTR [rdi+0x30]
  402407:	c4 41 19 ef e5       	vpxor  xmm12,xmm12,xmm13
  40240c:	c5 c9 ef 77 70       	vpxor  xmm6,xmm6,XMMWORD PTR [rdi+0x70]
  402411:	c4 43 29 44 eb 11    	vpclmulhqhqdq xmm13,xmm10,xmm11
  402417:	c4 43 29 44 db 00    	vpclmullqlqdq xmm11,xmm10,xmm11
  40241d:	c4 63 79 44 d6 11    	vpclmulhqhqdq xmm10,xmm0,xmm6
  402423:	c4 e3 79 44 c6 00    	vpclmullqlqdq xmm0,xmm0,xmm6
  402429:	c4 41 21 ef dd       	vpxor  xmm11,xmm11,xmm13
  40242e:	c4 41 79 ef d2       	vpxor  xmm10,xmm0,xmm10
  402433:	c5 fa 6f 05 45 72 00 	vmovdqu xmm0,XMMWORD PTR [rip+0x7245]        # 409680 <v3+0x20>
  40243a:	00 
  40243b:	c5 7a 6f 2d 4d 72 00 	vmovdqu xmm13,XMMWORD PTR [rip+0x724d]        # 409690 <v3+0x30>
  402442:	00 
  402443:	c5 11 ef bf c0 00 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0xc0]
  40244a:	00 
  40244b:	c5 f9 ef b7 80 00 00 	vpxor  xmm6,xmm0,XMMWORD PTR [rdi+0x80]
  402452:	00 
  402453:	c4 43 49 44 f7 11    	vpclmulhqhqdq xmm14,xmm6,xmm15
  402459:	c4 c3 49 44 f7 00    	vpclmullqlqdq xmm6,xmm6,xmm15
  40245f:	c5 11 ef bf d0 00 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0xd0]
  402466:	00 
  402467:	c4 c1 49 ef f6       	vpxor  xmm6,xmm6,xmm14
  40246c:	c5 c9 ef f5          	vpxor  xmm6,xmm6,xmm5
  402470:	c5 f9 ef af 90 00 00 	vpxor  xmm5,xmm0,XMMWORD PTR [rdi+0x90]
  402477:	00 
  402478:	c4 43 51 44 f7 11    	vpclmulhqhqdq xmm14,xmm5,xmm15
  40247e:	c4 c3 51 44 ef 00    	vpclmullqlqdq xmm5,xmm5,xmm15
  402484:	c5 11 ef bf e0 00 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0xe0]
  40248b:	00 
  40248c:	c4 c1 51 ef ee       	vpxor  xmm5,xmm5,xmm14
  402491:	c5 11 ef af f0 00 00 	vpxor  xmm13,xmm13,XMMWORD PTR [rdi+0xf0]
  402498:	00 
  402499:	c4 c1 51 ef ec       	vpxor  xmm5,xmm5,xmm12
  40249e:	c5 79 ef a7 a0 00 00 	vpxor  xmm12,xmm0,XMMWORD PTR [rdi+0xa0]
  4024a5:	00 
  4024a6:	c5 f9 ef 87 b0 00 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rdi+0xb0]
  4024ad:	00 
  4024ae:	c4 43 19 44 f7 11    	vpclmulhqhqdq xmm14,xmm12,xmm15
  4024b4:	c4 43 19 44 e7 00    	vpclmullqlqdq xmm12,xmm12,xmm15
  4024ba:	c4 41 19 ef e6       	vpxor  xmm12,xmm12,xmm14
  4024bf:	c4 41 19 ef e3       	vpxor  xmm12,xmm12,xmm11
  4024c4:	c4 43 79 44 dd 11    	vpclmulhqhqdq xmm11,xmm0,xmm13
  4024ca:	c4 c3 79 44 c5 00    	vpclmullqlqdq xmm0,xmm0,xmm13
  4024d0:	c4 41 79 ef db       	vpxor  xmm11,xmm0,xmm11
  4024d5:	c4 41 21 ef da       	vpxor  xmm11,xmm11,xmm10
  4024da:	c5 fa 6f 05 be 71 00 	vmovdqu xmm0,XMMWORD PTR [rip+0x71be]        # 4096a0 <v3+0x40>
  4024e1:	00 
  4024e2:	c5 7a 6f 2d c6 71 00 	vmovdqu xmm13,XMMWORD PTR [rip+0x71c6]        # 4096b0 <v3+0x50>
  4024e9:	00 
  4024ea:	c5 11 ef bf 40 01 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x140]
  4024f1:	00 
  4024f2:	c5 79 ef 97 00 01 00 	vpxor  xmm10,xmm0,XMMWORD PTR [rdi+0x100]
  4024f9:	00 
  4024fa:	c4 43 29 44 f7 11    	vpclmulhqhqdq xmm14,xmm10,xmm15
  402500:	c4 43 29 44 d7 00    	vpclmullqlqdq xmm10,xmm10,xmm15
  402506:	c5 11 ef bf 50 01 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x150]
  40250d:	00 
  40250e:	c4 41 29 ef d6       	vpxor  xmm10,xmm10,xmm14
  402513:	c5 29 ef d6          	vpxor  xmm10,xmm10,xmm6
  402517:	c5 f9 ef b7 10 01 00 	vpxor  xmm6,xmm0,XMMWORD PTR [rdi+0x110]
  40251e:	00 
  40251f:	c4 43 49 44 f7 11    	vpclmulhqhqdq xmm14,xmm6,xmm15
  402525:	c4 c3 49 44 f7 00    	vpclmullqlqdq xmm6,xmm6,xmm15
  40252b:	c5 11 ef bf 60 01 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x160]
  402532:	00 
  402533:	c4 c1 49 ef f6       	vpxor  xmm6,xmm6,xmm14
  402538:	c5 11 ef af 70 01 00 	vpxor  xmm13,xmm13,XMMWORD PTR [rdi+0x170]
  40253f:	00 
  402540:	c5 c9 ef f5          	vpxor  xmm6,xmm6,xmm5
  402544:	c5 f9 ef af 20 01 00 	vpxor  xmm5,xmm0,XMMWORD PTR [rdi+0x120]
  40254b:	00 
  40254c:	c5 f9 ef 87 30 01 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rdi+0x130]
  402553:	00 
  402554:	c4 43 51 44 f7 11    	vpclmulhqhqdq xmm14,xmm5,xmm15
  40255a:	c4 c3 51 44 ef 00    	vpclmullqlqdq xmm5,xmm5,xmm15
  402560:	c4 c1 51 ef ee       	vpxor  xmm5,xmm5,xmm14
  402565:	c4 c1 51 ef ec       	vpxor  xmm5,xmm5,xmm12
  40256a:	c4 43 79 44 e5 11    	vpclmulhqhqdq xmm12,xmm0,xmm13
  402570:	c4 c3 79 44 c5 00    	vpclmullqlqdq xmm0,xmm0,xmm13
  402576:	c4 41 79 ef e4       	vpxor  xmm12,xmm0,xmm12
  40257b:	c4 41 19 ef e3       	vpxor  xmm12,xmm12,xmm11
  402580:	c5 fa 6f 05 38 71 00 	vmovdqu xmm0,XMMWORD PTR [rip+0x7138]        # 4096c0 <v3+0x60>
  402587:	00 
  402588:	c5 7a 6f 2d 40 71 00 	vmovdqu xmm13,XMMWORD PTR [rip+0x7140]        # 4096d0 <v3+0x70>
  40258f:	00 
  402590:	c5 11 ef bf c0 01 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x1c0]
  402597:	00 
  402598:	c5 79 ef 9f 80 01 00 	vpxor  xmm11,xmm0,XMMWORD PTR [rdi+0x180]
  40259f:	00 
  4025a0:	c4 43 21 44 f7 11    	vpclmulhqhqdq xmm14,xmm11,xmm15
  4025a6:	c4 43 21 44 df 00    	vpclmullqlqdq xmm11,xmm11,xmm15
  4025ac:	c5 11 ef bf d0 01 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x1d0]
  4025b3:	00 
  4025b4:	c4 41 21 ef de       	vpxor  xmm11,xmm11,xmm14
  4025b9:	c4 41 21 ef da       	vpxor  xmm11,xmm11,xmm10
  4025be:	c5 79 ef 97 90 01 00 	vpxor  xmm10,xmm0,XMMWORD PTR [rdi+0x190]
  4025c5:	00 
  4025c6:	c4 43 29 44 f7 11    	vpclmulhqhqdq xmm14,xmm10,xmm15
  4025cc:	c4 43 29 44 d7 00    	vpclmullqlqdq xmm10,xmm10,xmm15
  4025d2:	c5 11 ef bf e0 01 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x1e0]
  4025d9:	00 
  4025da:	c4 41 29 ef d6       	vpxor  xmm10,xmm10,xmm14
  4025df:	c5 11 ef af f0 01 00 	vpxor  xmm13,xmm13,XMMWORD PTR [rdi+0x1f0]
  4025e6:	00 
  4025e7:	c5 29 ef d6          	vpxor  xmm10,xmm10,xmm6
  4025eb:	c5 f9 ef b7 a0 01 00 	vpxor  xmm6,xmm0,XMMWORD PTR [rdi+0x1a0]
  4025f2:	00 
  4025f3:	c5 f9 ef 87 b0 01 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rdi+0x1b0]
  4025fa:	00 
  4025fb:	c4 43 49 44 f7 11    	vpclmulhqhqdq xmm14,xmm6,xmm15
  402601:	c4 c3 49 44 f7 00    	vpclmullqlqdq xmm6,xmm6,xmm15
  402607:	c4 c1 49 ef f6       	vpxor  xmm6,xmm6,xmm14
  40260c:	c5 c9 ef f5          	vpxor  xmm6,xmm6,xmm5
  402610:	c4 c3 79 44 ed 11    	vpclmulhqhqdq xmm5,xmm0,xmm13
  402616:	c4 c3 79 44 c5 00    	vpclmullqlqdq xmm0,xmm0,xmm13
  40261c:	c5 f9 ef ed          	vpxor  xmm5,xmm0,xmm5
  402620:	c4 c1 51 ef ec       	vpxor  xmm5,xmm5,xmm12
  402625:	c5 fa 6f 05 b3 70 00 	vmovdqu xmm0,XMMWORD PTR [rip+0x70b3]        # 4096e0 <v3+0x80>
  40262c:	00 
  40262d:	c5 7a 6f 2d bb 70 00 	vmovdqu xmm13,XMMWORD PTR [rip+0x70bb]        # 4096f0 <v3+0x90>
  402634:	00 
  402635:	c5 11 ef bf 40 02 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x240]
  40263c:	00 
  40263d:	c5 79 ef a7 00 02 00 	vpxor  xmm12,xmm0,XMMWORD PTR [rdi+0x200]
  402644:	00 
  402645:	c4 43 19 44 f7 11    	vpclmulhqhqdq xmm14,xmm12,xmm15
  40264b:	c4 43 19 44 e7 00    	vpclmullqlqdq xmm12,xmm12,xmm15
  402651:	c5 11 ef bf 50 02 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x250]
  402658:	00 
  402659:	c4 41 19 ef e6       	vpxor  xmm12,xmm12,xmm14
  40265e:	c4 41 19 ef e3       	vpxor  xmm12,xmm12,xmm11
  402663:	c5 79 ef 9f 10 02 00 	vpxor  xmm11,xmm0,XMMWORD PTR [rdi+0x210]
  40266a:	00 
  40266b:	c4 43 21 44 f7 11    	vpclmulhqhqdq xmm14,xmm11,xmm15
  402671:	c4 43 21 44 df 00    	vpclmullqlqdq xmm11,xmm11,xmm15
  402677:	c5 11 ef bf 60 02 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x260]
  40267e:	00 
  40267f:	c4 41 21 ef de       	vpxor  xmm11,xmm11,xmm14
  402684:	c5 11 ef af 70 02 00 	vpxor  xmm13,xmm13,XMMWORD PTR [rdi+0x270]
  40268b:	00 
  40268c:	c4 41 21 ef da       	vpxor  xmm11,xmm11,xmm10
  402691:	c5 79 ef 97 20 02 00 	vpxor  xmm10,xmm0,XMMWORD PTR [rdi+0x220]
  402698:	00 
  402699:	c5 f9 ef 87 30 02 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rdi+0x230]
  4026a0:	00 
  4026a1:	c4 43 29 44 f7 11    	vpclmulhqhqdq xmm14,xmm10,xmm15
  4026a7:	c4 43 29 44 d7 00    	vpclmullqlqdq xmm10,xmm10,xmm15
  4026ad:	c4 41 29 ef d6       	vpxor  xmm10,xmm10,xmm14
  4026b2:	c5 29 ef d6          	vpxor  xmm10,xmm10,xmm6
  4026b6:	c4 c3 79 44 f5 11    	vpclmulhqhqdq xmm6,xmm0,xmm13
  4026bc:	c4 c3 79 44 c5 00    	vpclmullqlqdq xmm0,xmm0,xmm13
  4026c2:	c5 f9 ef f6          	vpxor  xmm6,xmm0,xmm6
  4026c6:	c5 c9 ef f5          	vpxor  xmm6,xmm6,xmm5
  4026ca:	c5 fa 6f 05 2e 70 00 	vmovdqu xmm0,XMMWORD PTR [rip+0x702e]        # 409700 <v3+0xa0>
  4026d1:	00 
  4026d2:	c5 7a 6f 2d 36 70 00 	vmovdqu xmm13,XMMWORD PTR [rip+0x7036]        # 409710 <v3+0xb0>
  4026d9:	00 
  4026da:	c5 11 ef bf c0 02 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x2c0]
  4026e1:	00 
  4026e2:	c5 f9 ef af 80 02 00 	vpxor  xmm5,xmm0,XMMWORD PTR [rdi+0x280]
  4026e9:	00 
  4026ea:	c4 43 51 44 f7 11    	vpclmulhqhqdq xmm14,xmm5,xmm15
  4026f0:	c4 c3 51 44 ef 00    	vpclmullqlqdq xmm5,xmm5,xmm15
  4026f6:	c5 11 ef bf d0 02 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x2d0]
  4026fd:	00 
  4026fe:	c4 c1 51 ef ee       	vpxor  xmm5,xmm5,xmm14
  402703:	c4 c1 51 ef ec       	vpxor  xmm5,xmm5,xmm12
  402708:	c5 79 ef a7 90 02 00 	vpxor  xmm12,xmm0,XMMWORD PTR [rdi+0x290]
  40270f:	00 
  402710:	c4 43 19 44 f7 11    	vpclmulhqhqdq xmm14,xmm12,xmm15
  402716:	c4 43 19 44 e7 00    	vpclmullqlqdq xmm12,xmm12,xmm15
  40271c:	c5 11 ef bf e0 02 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x2e0]
  402723:	00 
  402724:	c4 41 19 ef e6       	vpxor  xmm12,xmm12,xmm14
  402729:	c5 11 ef af f0 02 00 	vpxor  xmm13,xmm13,XMMWORD PTR [rdi+0x2f0]
  402730:	00 
  402731:	c4 41 19 ef e3       	vpxor  xmm12,xmm12,xmm11
  402736:	c5 79 ef 9f a0 02 00 	vpxor  xmm11,xmm0,XMMWORD PTR [rdi+0x2a0]
  40273d:	00 
  40273e:	c5 f9 ef 87 b0 02 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rdi+0x2b0]
  402745:	00 
  402746:	c4 43 21 44 f7 11    	vpclmulhqhqdq xmm14,xmm11,xmm15
  40274c:	c4 43 21 44 df 00    	vpclmullqlqdq xmm11,xmm11,xmm15
  402752:	c4 41 21 ef de       	vpxor  xmm11,xmm11,xmm14
  402757:	c4 41 21 ef da       	vpxor  xmm11,xmm11,xmm10
  40275c:	c4 43 79 44 d5 11    	vpclmulhqhqdq xmm10,xmm0,xmm13
  402762:	c4 c3 79 44 c5 00    	vpclmullqlqdq xmm0,xmm0,xmm13
  402768:	c4 41 79 ef d2       	vpxor  xmm10,xmm0,xmm10
  40276d:	c5 29 ef d6          	vpxor  xmm10,xmm10,xmm6
  402771:	c5 fa 6f 05 a7 6f 00 	vmovdqu xmm0,XMMWORD PTR [rip+0x6fa7]        # 409720 <v3+0xc0>
  402778:	00 
  402779:	c5 7a 6f 2d af 6f 00 	vmovdqu xmm13,XMMWORD PTR [rip+0x6faf]        # 409730 <v3+0xd0>
  402780:	00 
  402781:	c5 11 ef bf 40 03 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x340]
  402788:	00 
  402789:	c5 f9 ef b7 00 03 00 	vpxor  xmm6,xmm0,XMMWORD PTR [rdi+0x300]
  402790:	00 
  402791:	c4 43 49 44 f7 11    	vpclmulhqhqdq xmm14,xmm6,xmm15
  402797:	c4 c3 49 44 f7 00    	vpclmullqlqdq xmm6,xmm6,xmm15
  40279d:	c5 11 ef bf 50 03 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x350]
  4027a4:	00 
  4027a5:	c4 c1 49 ef f6       	vpxor  xmm6,xmm6,xmm14
  4027aa:	c5 c9 ef f5          	vpxor  xmm6,xmm6,xmm5
  4027ae:	c5 f9 ef af 10 03 00 	vpxor  xmm5,xmm0,XMMWORD PTR [rdi+0x310]
  4027b5:	00 
  4027b6:	c4 43 51 44 f7 11    	vpclmulhqhqdq xmm14,xmm5,xmm15
  4027bc:	c4 c3 51 44 ef 00    	vpclmullqlqdq xmm5,xmm5,xmm15
  4027c2:	c5 11 ef bf 60 03 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x360]
  4027c9:	00 
  4027ca:	c4 c1 51 ef ee       	vpxor  xmm5,xmm5,xmm14
  4027cf:	c5 11 ef af 70 03 00 	vpxor  xmm13,xmm13,XMMWORD PTR [rdi+0x370]
  4027d6:	00 
  4027d7:	c4 c1 51 ef ec       	vpxor  xmm5,xmm5,xmm12
  4027dc:	c5 79 ef a7 20 03 00 	vpxor  xmm12,xmm0,XMMWORD PTR [rdi+0x320]
  4027e3:	00 
  4027e4:	c5 f9 ef 87 30 03 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rdi+0x330]
  4027eb:	00 
  4027ec:	c4 43 19 44 f7 11    	vpclmulhqhqdq xmm14,xmm12,xmm15
  4027f2:	c4 43 19 44 e7 00    	vpclmullqlqdq xmm12,xmm12,xmm15
  4027f8:	c4 41 19 ef e6       	vpxor  xmm12,xmm12,xmm14
  4027fd:	c4 41 19 ef e3       	vpxor  xmm12,xmm12,xmm11
  402802:	c4 43 79 44 dd 11    	vpclmulhqhqdq xmm11,xmm0,xmm13
  402808:	c4 c3 79 44 c5 00    	vpclmullqlqdq xmm0,xmm0,xmm13
  40280e:	c4 41 79 ef db       	vpxor  xmm11,xmm0,xmm11
  402813:	c4 41 21 ef da       	vpxor  xmm11,xmm11,xmm10
  402818:	c5 fa 6f 05 20 6f 00 	vmovdqu xmm0,XMMWORD PTR [rip+0x6f20]        # 409740 <v3+0xe0>
  40281f:	00 
  402820:	c5 7a 6f 2d 28 6f 00 	vmovdqu xmm13,XMMWORD PTR [rip+0x6f28]        # 409750 <v3+0xf0>
  402827:	00 
  402828:	c5 11 ef bf c0 03 00 	vpxor  xmm15,xmm13,XMMWORD PTR [rdi+0x3c0]
  40282f:	00 
  402830:	c5 79 ef 97 80 03 00 	vpxor  xmm10,xmm0,XMMWORD PTR [rdi+0x380]
  402837:	00 
  402838:	48 81 c7 00 04 00 00 	add    rdi,0x400
  40283f:	c4 43 29 44 f7 11    	vpclmulhqhqdq xmm14,xmm10,xmm15
  402845:	c4 43 29 44 d7 00    	vpclmullqlqdq xmm10,xmm10,xmm15
  40284b:	c5 11 ef 7f d0       	vpxor  xmm15,xmm13,XMMWORD PTR [rdi-0x30]
  402850:	c4 41 29 ef d6       	vpxor  xmm10,xmm10,xmm14
  402855:	c5 29 ef d6          	vpxor  xmm10,xmm10,xmm6
  402859:	c5 f9 ef 77 90       	vpxor  xmm6,xmm0,XMMWORD PTR [rdi-0x70]
  40285e:	c4 43 49 44 f7 11    	vpclmulhqhqdq xmm14,xmm6,xmm15
  402864:	c4 c3 49 44 f7 00    	vpclmullqlqdq xmm6,xmm6,xmm15
  40286a:	c5 11 ef 7f e0       	vpxor  xmm15,xmm13,XMMWORD PTR [rdi-0x20]
  40286f:	c4 c1 49 ef f6       	vpxor  xmm6,xmm6,xmm14
  402874:	c5 11 ef 6f f0       	vpxor  xmm13,xmm13,XMMWORD PTR [rdi-0x10]
  402879:	c5 c9 ef f5          	vpxor  xmm6,xmm6,xmm5
  40287d:	c5 f9 ef 6f a0       	vpxor  xmm5,xmm0,XMMWORD PTR [rdi-0x60]
  402882:	c5 f9 ef 47 b0       	vpxor  xmm0,xmm0,XMMWORD PTR [rdi-0x50]
  402887:	c4 43 51 44 f7 11    	vpclmulhqhqdq xmm14,xmm5,xmm15
  40288d:	c4 c3 51 44 ef 00    	vpclmullqlqdq xmm5,xmm5,xmm15
  402893:	c4 c1 51 ef ee       	vpxor  xmm5,xmm5,xmm14
  402898:	c4 c1 51 ef ec       	vpxor  xmm5,xmm5,xmm12
  40289d:	c4 43 79 44 e5 11    	vpclmulhqhqdq xmm12,xmm0,xmm13
  4028a3:	c4 c3 79 44 c5 00    	vpclmullqlqdq xmm0,xmm0,xmm13
  4028a9:	c4 c1 79 ef c4       	vpxor  xmm0,xmm0,xmm12
  4028ae:	c4 c1 79 ef c3       	vpxor  xmm0,xmm0,xmm11
  4028b3:	c4 63 59 44 df 11    	vpclmulhqhqdq xmm11,xmm4,xmm7
  4028b9:	c4 e3 59 44 e7 00    	vpclmullqlqdq xmm4,xmm4,xmm7
  4028bf:	c4 c1 59 ef e3       	vpxor  xmm4,xmm4,xmm11
  4028c4:	c4 c1 59 ef e2       	vpxor  xmm4,xmm4,xmm10
  4028c9:	c4 63 61 44 d7 11    	vpclmulhqhqdq xmm10,xmm3,xmm7
  4028cf:	c4 e3 61 44 df 00    	vpclmullqlqdq xmm3,xmm3,xmm7
  4028d5:	c4 c1 61 ef da       	vpxor  xmm3,xmm3,xmm10
  4028da:	c5 e1 ef de          	vpxor  xmm3,xmm3,xmm6
  4028de:	c4 e3 69 44 f7 11    	vpclmulhqhqdq xmm6,xmm2,xmm7
  4028e4:	c4 e3 69 44 d7 00    	vpclmullqlqdq xmm2,xmm2,xmm7
  4028ea:	c5 e9 ef d6          	vpxor  xmm2,xmm2,xmm6
  4028ee:	c5 e9 ef d5          	vpxor  xmm2,xmm2,xmm5
  4028f2:	c4 e3 71 44 ef 11    	vpclmulhqhqdq xmm5,xmm1,xmm7
  4028f8:	c4 e3 71 44 cf 00    	vpclmullqlqdq xmm1,xmm1,xmm7
  4028fe:	c5 f1 ef cd          	vpxor  xmm1,xmm1,xmm5
  402902:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  402906:	48 83 ee 01          	sub    rsi,0x1
  40290a:	0f 85 a8 fa ff ff    	jne    4023b8 <chv3_bulk128.constprop.0+0x38>
  402910:	c5 fa 7e 3d 60 6e 00 	vmovq  xmm7,QWORD PTR [rip+0x6e60]        # 409778 <v3+0x118>
  402917:	00 
  402918:	c4 e3 c1 22 05 9e 6e 	vpinsrq xmm0,xmm7,QWORD PTR [rip+0x6e9e],0x1        # 4097c0 <v3+0x160>
  40291f:	00 00 01 
  402922:	c5 f9 6f 3d 46 6e 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x6e46]        # 409770 <v3+0x110>
  402929:	00 
  40292a:	c4 e3 59 44 f0 11    	vpclmulhqhqdq xmm6,xmm4,xmm0
  402930:	c4 e3 59 44 c0 00    	vpclmullqlqdq xmm0,xmm4,xmm0
  402936:	c5 f9 6f 25 22 6e 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x6e22]        # 409760 <v3+0x100>
  40293d:	00 
  40293e:	c4 c1 41 c6 e8 02    	vshufpd xmm5,xmm7,xmm8,0x2
  402944:	c4 e3 61 44 fd 11    	vpclmulhqhqdq xmm7,xmm3,xmm5
  40294a:	c5 f9 ef c6          	vpxor  xmm0,xmm0,xmm6
  40294e:	c4 e3 61 44 dd 00    	vpclmullqlqdq xmm3,xmm3,xmm5
  402954:	c4 41 59 c6 c0 01    	vshufpd xmm8,xmm4,xmm8,0x1
  40295a:	c5 e1 ef df          	vpxor  xmm3,xmm3,xmm7
  40295e:	c4 c3 69 44 e8 11    	vpclmulhqhqdq xmm5,xmm2,xmm8
  402964:	c4 c3 69 44 d0 00    	vpclmullqlqdq xmm2,xmm2,xmm8
  40296a:	c5 e9 ef d5          	vpxor  xmm2,xmm2,xmm5
  40296e:	c4 c1 59 c6 e1 02    	vshufpd xmm4,xmm4,xmm9,0x2
  402974:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  402978:	c4 63 71 44 c4 11    	vpclmulhqhqdq xmm8,xmm1,xmm4
  40297e:	c4 e3 71 44 cc 00    	vpclmullqlqdq xmm1,xmm1,xmm4
  402984:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  402988:	c5 f9 6f 15 80 47 00 	vmovdqa xmm2,XMMWORD PTR [rip+0x4780]        # 407110 <__PRETTY_FUNCTION__.6+0x20>
  40298f:	00 
  402990:	c4 c1 71 ef c8       	vpxor  xmm1,xmm1,xmm8
  402995:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  402999:	c4 e3 79 44 ca 11    	vpclmulhqhqdq xmm1,xmm0,xmm2
  40299f:	c4 e3 71 44 d2 11    	vpclmulhqhqdq xmm2,xmm1,xmm2
  4029a5:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4029a9:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  4029ad:	c4 e1 f9 7e c8       	vmovq  rax,xmm1
  4029b2:	c3                   	ret    
  4029b3:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  4029ba:	00 00 00 00 
  4029be:	66 90                	xchg   ax,ax

00000000004029c0 <chainhash_x86_avx512.constprop.0>:
  4029c0:	55                   	push   rbp
  4029c1:	48 89 f1             	mov    rcx,rsi
  4029c4:	48 89 e5             	mov    rbp,rsp
  4029c7:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  4029cb:	48 83 ec 48          	sub    rsp,0x48
  4029cf:	c5 f9 6f 3d 29 6c 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x6c29]        # 409600 <oldx+0x400>
  4029d6:	00 
  4029d7:	48 8b 05 32 6c 00 00 	mov    rax,QWORD PTR [rip+0x6c32]        # 409610 <oldx+0x410>
  4029de:	48 33 05 1b 6c 00 00 	xor    rax,QWORD PTR [rip+0x6c1b]        # 409600 <oldx+0x400>
  4029e5:	c5 f9 7f 7c 24 f8    	vmovdqa XMMWORD PTR [rsp-0x8],xmm7
  4029eb:	c4 e1 f9 6e f8       	vmovq  xmm7,rax
  4029f0:	c5 f9 7f 7c 24 28    	vmovdqa XMMWORD PTR [rsp+0x28],xmm7
  4029f6:	48 81 fe 00 04 00 00 	cmp    rsi,0x400
  4029fd:	0f 86 0c 07 00 00    	jbe    40310f <chainhash_x86_avx512.constprop.0+0x74f>
  402a03:	c5 f9 6f 15 15 47 00 	vmovdqa xmm2,XMMWORD PTR [rip+0x4715]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  402a0a:	00 
  402a0b:	48 8d 96 ff fb ff ff 	lea    rdx,[rsi-0x401]
  402a12:	62 f1 7e 48 6f 25 a4 	vmovdqu32 zmm4,ZMMWORD PTR [rip+0x6ba4]        # 4095c0 <oldx+0x3c0>
  402a19:	6b 00 00 
  402a1c:	62 e1 7e 48 6f 1d da 	vmovdqu32 zmm19,ZMMWORD PTR [rip+0x67da]        # 409200 <oldx>
  402a23:	67 00 00 
  402a26:	48 c1 ea 0a          	shr    rdx,0xa
  402a2a:	62 e1 7e 48 6f 15 0c 	vmovdqu32 zmm18,ZMMWORD PTR [rip+0x680c]        # 409240 <oldx+0x40>
  402a31:	68 00 00 
  402a34:	48 8d 42 01          	lea    rax,[rdx+0x1]
  402a38:	c5 f9 7f 54 24 18    	vmovdqa XMMWORD PTR [rsp+0x18],xmm2
  402a3e:	c5 f9 6f 15 ea 46 00 	vmovdqa xmm2,XMMWORD PTR [rip+0x46ea]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  402a45:	00 
  402a46:	62 e1 7e 48 6f 0d 30 	vmovdqu32 zmm17,ZMMWORD PTR [rip+0x6830]        # 409280 <oldx+0x80>
  402a4d:	68 00 00 
  402a50:	48 c1 e0 0a          	shl    rax,0xa
  402a54:	62 e1 7e 48 6f 05 62 	vmovdqu32 zmm16,ZMMWORD PTR [rip+0x6862]        # 4092c0 <oldx+0xc0>
  402a5b:	68 00 00 
  402a5e:	62 71 7e 48 6f 3d 98 	vmovdqu32 zmm15,ZMMWORD PTR [rip+0x6898]        # 409300 <oldx+0x100>
  402a65:	68 00 00 
  402a68:	62 f1 7d 48 7f a4 24 	vmovdqa32 ZMMWORD PTR [rsp-0x78],zmm4
  402a6f:	88 ff ff ff 
  402a73:	62 71 7e 48 6f 35 c3 	vmovdqu32 zmm14,ZMMWORD PTR [rip+0x68c3]        # 409340 <oldx+0x140>
  402a7a:	68 00 00 
  402a7d:	48 01 f8             	add    rax,rdi
  402a80:	62 71 7e 48 6f 2d f6 	vmovdqu32 zmm13,ZMMWORD PTR [rip+0x68f6]        # 409380 <oldx+0x180>
  402a87:	68 00 00 
  402a8a:	c5 f9 7f 54 24 08    	vmovdqa XMMWORD PTR [rsp+0x8],xmm2
  402a90:	62 71 7e 48 6f 25 26 	vmovdqu32 zmm12,ZMMWORD PTR [rip+0x6926]        # 4093c0 <oldx+0x1c0>
  402a97:	69 00 00 
  402a9a:	62 71 7e 48 6f 1d 5c 	vmovdqu32 zmm11,ZMMWORD PTR [rip+0x695c]        # 409400 <oldx+0x200>
  402aa1:	69 00 00 
  402aa4:	62 71 7e 48 6f 15 92 	vmovdqu32 zmm10,ZMMWORD PTR [rip+0x6992]        # 409440 <oldx+0x240>
  402aab:	69 00 00 
  402aae:	62 71 7e 48 6f 0d c8 	vmovdqu32 zmm9,ZMMWORD PTR [rip+0x69c8]        # 409480 <oldx+0x280>
  402ab5:	69 00 00 
  402ab8:	62 71 7e 48 6f 05 fe 	vmovdqu32 zmm8,ZMMWORD PTR [rip+0x69fe]        # 4094c0 <oldx+0x2c0>
  402abf:	69 00 00 
  402ac2:	62 f1 7e 48 6f 3d 34 	vmovdqu32 zmm7,ZMMWORD PTR [rip+0x6a34]        # 409500 <oldx+0x300>
  402ac9:	6a 00 00 
  402acc:	62 f1 7e 48 6f 35 6a 	vmovdqu32 zmm6,ZMMWORD PTR [rip+0x6a6a]        # 409540 <oldx+0x340>
  402ad3:	6a 00 00 
  402ad6:	62 f1 7e 48 6f 2d a0 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x6aa0]        # 409580 <oldx+0x380>
  402add:	6a 00 00 
  402ae0:	62 f1 65 40 ef 07    	vpxord zmm0,zmm19,ZMMWORD PTR [rdi]
  402ae6:	62 61 6d 40 ef 7f 01 	vpxord zmm31,zmm18,ZMMWORD PTR [rdi+0x40]
  402aed:	48 81 c7 00 04 00 00 	add    rdi,0x400
  402af4:	62 e1 75 40 ef 6f f2 	vpxord zmm21,zmm17,ZMMWORD PTR [rdi-0x380]
  402afb:	62 61 7d 40 ef 77 f3 	vpxord zmm30,zmm16,ZMMWORD PTR [rdi-0x340]
  402b02:	62 f1 1d 48 ef 5f f7 	vpxord zmm3,zmm12,ZMMWORD PTR [rdi-0x240]
  402b09:	62 f1 35 48 ef 57 fa 	vpxord zmm2,zmm9,ZMMWORD PTR [rdi-0x180]
  402b10:	62 e1 05 48 ef 67 f4 	vpxord zmm20,zmm15,ZMMWORD PTR [rdi-0x300]
  402b17:	62 61 0d 48 ef 6f f5 	vpxord zmm29,zmm14,ZMMWORD PTR [rdi-0x2c0]
  402b1e:	62 61 15 48 ef 67 f6 	vpxord zmm28,zmm13,ZMMWORD PTR [rdi-0x280]
  402b25:	62 61 25 48 ef 5f f8 	vpxord zmm27,zmm11,ZMMWORD PTR [rdi-0x200]
  402b2c:	62 f3 7d 48 44 c0 10 	vpclmullqhqdq zmm0,zmm0,zmm0
  402b33:	62 f1 4d 48 ef 4f fd 	vpxord zmm1,zmm6,ZMMWORD PTR [rdi-0xc0]
  402b3a:	62 61 2d 48 ef 57 f9 	vpxord zmm26,zmm10,ZMMWORD PTR [rdi-0x1c0]
  402b41:	62 03 05 40 44 ff 10 	vpclmullqhqdq zmm31,zmm31,zmm31
  402b48:	62 e1 55 48 ef 7f fe 	vpxord zmm23,zmm5,ZMMWORD PTR [rdi-0x80]
  402b4f:	62 61 3d 48 ef 4f fb 	vpxord zmm25,zmm8,ZMMWORD PTR [rdi-0x140]
  402b56:	62 a3 55 40 44 ed 10 	vpclmullqhqdq zmm21,zmm21,zmm21
  402b5d:	62 f1 7d 48 6f a4 24 	vmovdqa32 zmm4,ZMMWORD PTR [rsp-0x78]
  402b64:	88 ff ff ff 
  402b68:	62 61 45 48 ef 47 fc 	vpxord zmm24,zmm7,ZMMWORD PTR [rdi-0x100]
  402b6f:	62 03 0d 40 44 f6 10 	vpclmullqhqdq zmm30,zmm30,zmm30
  402b76:	62 e1 5d 48 ef 77 ff 	vpxord zmm22,zmm4,ZMMWORD PTR [rdi-0x40]
  402b7d:	c5 f9 6f 64 24 08    	vmovdqa xmm4,XMMWORD PTR [rsp+0x8]
  402b83:	62 a3 5d 40 44 e4 10 	vpclmullqhqdq zmm20,zmm20,zmm20
  402b8a:	62 03 15 40 44 ed 10 	vpclmullqhqdq zmm29,zmm29,zmm29
  402b91:	62 03 1d 40 44 e4 10 	vpclmullqhqdq zmm28,zmm28,zmm28
  402b98:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402b9f:	62 91 7d 48 ef c7    	vpxord zmm0,zmm0,zmm31
  402ba5:	62 03 25 40 44 db 10 	vpclmullqhqdq zmm27,zmm27,zmm27
  402bac:	62 03 2d 40 44 d2 10 	vpclmullqhqdq zmm26,zmm26,zmm26
  402bb3:	62 81 55 40 ef ee    	vpxord zmm21,zmm21,zmm30
  402bb9:	62 f3 6d 48 44 d2 10 	vpclmullqhqdq zmm2,zmm2,zmm2
  402bc0:	62 b1 7d 48 ef c5    	vpxord zmm0,zmm0,zmm21
  402bc6:	62 03 35 40 44 c9 10 	vpclmullqhqdq zmm25,zmm25,zmm25
  402bcd:	62 81 5d 40 ef e5    	vpxord zmm20,zmm20,zmm29
  402bd3:	62 03 3d 40 44 c0 10 	vpclmullqhqdq zmm24,zmm24,zmm24
  402bda:	62 81 5d 40 ef e4    	vpxord zmm20,zmm20,zmm28
  402be0:	62 f3 75 48 44 c9 10 	vpclmullqhqdq zmm1,zmm1,zmm1
  402be7:	62 b1 7d 48 ef c4    	vpxord zmm0,zmm0,zmm20
  402bed:	62 a3 45 40 44 ff 10 	vpclmullqhqdq zmm23,zmm23,zmm23
  402bf4:	62 91 65 48 ef db    	vpxord zmm3,zmm3,zmm27
  402bfa:	62 a3 4d 40 44 f6 10 	vpclmullqhqdq zmm22,zmm22,zmm22
  402c01:	62 91 65 48 ef da    	vpxord zmm3,zmm3,zmm26
  402c07:	62 f1 7d 48 ef c3    	vpxord zmm0,zmm0,zmm3
  402c0d:	62 91 6d 48 ef d1    	vpxord zmm2,zmm2,zmm25
  402c13:	62 91 6d 48 ef d0    	vpxord zmm2,zmm2,zmm24
  402c19:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
  402c1f:	62 b1 75 48 ef cf    	vpxord zmm1,zmm1,zmm23
  402c25:	62 b1 75 48 ef ce    	vpxord zmm1,zmm1,zmm22
  402c2b:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
  402c31:	62 f3 fd 48 3b c1 01 	vextracti64x4 ymm1,zmm0,0x1
  402c38:	c5 f5 ef c0          	vpxor  ymm0,ymm1,ymm0
  402c3c:	c4 e3 7d 39 c1 01    	vextracti128 xmm1,ymm0,0x1
  402c42:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  402c46:	c5 f9 ef 44 24 f8    	vpxor  xmm0,xmm0,XMMWORD PTR [rsp-0x8]
  402c4c:	c4 e3 79 44 54 24 28 	vpclmulhqlqdq xmm2,xmm0,XMMWORD PTR [rsp+0x28]
  402c53:	01 
  402c54:	c4 e3 69 44 5c 24 18 	vpclmulhqlqdq xmm3,xmm2,XMMWORD PTR [rsp+0x18]
  402c5b:	01 
  402c5c:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  402c60:	c5 f1 73 db 08       	vpsrldq xmm1,xmm3,0x8
  402c65:	c4 e2 59 00 c9       	vpshufb xmm1,xmm4,xmm1
  402c6a:	c5 e1 ef c9          	vpxor  xmm1,xmm3,xmm1
  402c6e:	c5 f1 ef e0          	vpxor  xmm4,xmm1,xmm0
  402c72:	c5 f9 7f 64 24 28    	vmovdqa XMMWORD PTR [rsp+0x28],xmm4
  402c78:	48 39 c7             	cmp    rdi,rax
  402c7b:	0f 85 5f fe ff ff    	jne    402ae0 <chainhash_x86_avx512.constprop.0+0x120>
  402c81:	48 f7 da             	neg    rdx
  402c84:	48 c1 e2 0a          	shl    rdx,0xa
  402c88:	48 8d 94 11 00 fc ff 	lea    rdx,[rcx+rdx*1-0x400]
  402c8f:	ff 
  402c90:	48 81 fa ff 00 00 00 	cmp    rdx,0xff
  402c97:	0f 86 5d 04 00 00    	jbe    4030fa <chainhash_x86_avx512.constprop.0+0x73a>
  402c9d:	62 f1 7e 48 6f 2d 99 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x6599]        # 409240 <oldx+0x40>
  402ca4:	65 00 00 
  402ca7:	62 f1 55 48 ef 48 01 	vpxord zmm1,zmm5,ZMMWORD PTR [rax+0x40]
  402cae:	48 8d b2 00 ff ff ff 	lea    rsi,[rdx-0x100]
  402cb5:	62 f1 7e 48 6f 25 c1 	vmovdqu32 zmm4,ZMMWORD PTR [rip+0x65c1]        # 409280 <oldx+0x80>
  402cbc:	65 00 00 
  402cbf:	62 f1 7e 48 6f 3d 37 	vmovdqu32 zmm7,ZMMWORD PTR [rip+0x6537]        # 409200 <oldx>
  402cc6:	65 00 00 
  402cc9:	62 f3 75 48 44 e9 10 	vpclmullqhqdq zmm5,zmm1,zmm1
  402cd0:	62 f1 45 48 ef 38    	vpxord zmm7,zmm7,ZMMWORD PTR [rax]
  402cd6:	62 f1 5d 48 ef 48 02 	vpxord zmm1,zmm4,ZMMWORD PTR [rax+0x80]
  402cdd:	62 f1 7e 48 6f 15 d9 	vmovdqu32 zmm2,ZMMWORD PTR [rip+0x65d9]        # 4092c0 <oldx+0xc0>
  402ce4:	65 00 00 
  402ce7:	62 f1 6d 48 ef 50 03 	vpxord zmm2,zmm2,ZMMWORD PTR [rax+0xc0]
  402cee:	62 f3 45 48 44 ff 10 	vpclmullqhqdq zmm7,zmm7,zmm7
  402cf5:	62 f3 75 48 44 e1 10 	vpclmullqhqdq zmm4,zmm1,zmm1
  402cfc:	62 f3 6d 48 44 da 10 	vpclmullqhqdq zmm3,zmm2,zmm2
  402d03:	62 f1 7d 48 6f f5    	vmovdqa32 zmm6,zmm5
  402d09:	62 f1 7d 48 6f c7    	vmovdqa32 zmm0,zmm7
  402d0f:	62 f1 7d 48 6f cc    	vmovdqa32 zmm1,zmm4
  402d15:	62 f1 7d 48 6f d3    	vmovdqa32 zmm2,zmm3
  402d1b:	48 81 fe ff 00 00 00 	cmp    rsi,0xff
  402d22:	0f 86 97 01 00 00    	jbe    402ebf <chainhash_x86_avx512.constprop.0+0x4ff>
  402d28:	62 f1 7e 48 6f 35 ce 	vmovdqu32 zmm6,ZMMWORD PTR [rip+0x65ce]        # 409300 <oldx+0x100>
  402d2f:	65 00 00 
  402d32:	62 f1 4d 48 ef 40 04 	vpxord zmm0,zmm6,ZMMWORD PTR [rax+0x100]
  402d39:	48 8d ba 00 fe ff ff 	lea    rdi,[rdx-0x200]
  402d40:	62 f1 7e 48 6f 35 f6 	vmovdqu32 zmm6,ZMMWORD PTR [rip+0x65f6]        # 409340 <oldx+0x140>
  402d47:	65 00 00 
  402d4a:	62 f1 4d 48 ef 70 05 	vpxord zmm6,zmm6,ZMMWORD PTR [rax+0x140]
  402d51:	62 f3 7d 48 44 c0 10 	vpclmullqhqdq zmm0,zmm0,zmm0
  402d58:	62 f3 4d 48 44 f6 10 	vpclmullqhqdq zmm6,zmm6,zmm6
  402d5f:	62 f1 45 48 ef c0    	vpxord zmm0,zmm7,zmm0
  402d65:	62 f1 55 48 ef f6    	vpxord zmm6,zmm5,zmm6
  402d6b:	62 f1 fd 48 6f f8    	vmovdqa64 zmm7,zmm0
  402d71:	62 f1 7e 48 6f 2d 05 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x6605]        # 409380 <oldx+0x180>
  402d78:	66 00 00 
  402d7b:	62 f1 55 48 ef 48 06 	vpxord zmm1,zmm5,ZMMWORD PTR [rax+0x180]
  402d82:	62 f1 7e 48 6f 2d 34 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x6634]        # 4093c0 <oldx+0x1c0>
  402d89:	66 00 00 
  402d8c:	62 f1 55 48 ef 50 07 	vpxord zmm2,zmm5,ZMMWORD PTR [rax+0x1c0]
  402d93:	62 f3 75 48 44 c9 10 	vpclmullqhqdq zmm1,zmm1,zmm1
  402d9a:	62 f3 6d 48 44 d2 10 	vpclmullqhqdq zmm2,zmm2,zmm2
  402da1:	62 f1 5d 48 ef c9    	vpxord zmm1,zmm4,zmm1
  402da7:	62 f1 65 48 ef d2    	vpxord zmm2,zmm3,zmm2
  402dad:	48 81 ff ff 00 00 00 	cmp    rdi,0xff
  402db4:	0f 86 05 01 00 00    	jbe    402ebf <chainhash_x86_avx512.constprop.0+0x4ff>
  402dba:	62 f1 7e 48 6f 3d 3c 	vmovdqu32 zmm7,ZMMWORD PTR [rip+0x663c]        # 409400 <oldx+0x200>
  402dc1:	66 00 00 
  402dc4:	62 f1 45 48 ef 58 08 	vpxord zmm3,zmm7,ZMMWORD PTR [rax+0x200]
  402dcb:	62 f1 7e 48 6f 2d 6b 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x666b]        # 409440 <oldx+0x240>
  402dd2:	66 00 00 
  402dd5:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402ddc:	62 f1 7d 48 ef c3    	vpxord zmm0,zmm0,zmm3
  402de2:	62 f1 55 48 ef 58 09 	vpxord zmm3,zmm5,ZMMWORD PTR [rax+0x240]
  402de9:	62 f1 7e 48 6f 2d 8d 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x668d]        # 409480 <oldx+0x280>
  402df0:	66 00 00 
  402df3:	62 f1 fd 48 6f f8    	vmovdqa64 zmm7,zmm0
  402df9:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402e00:	62 f1 4d 48 ef f3    	vpxord zmm6,zmm6,zmm3
  402e06:	62 f1 55 48 ef 58 0a 	vpxord zmm3,zmm5,ZMMWORD PTR [rax+0x280]
  402e0d:	62 f1 7e 48 6f 2d a9 	vmovdqu32 zmm5,ZMMWORD PTR [rip+0x66a9]        # 4094c0 <oldx+0x2c0>
  402e14:	66 00 00 
  402e17:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402e1e:	62 f1 75 48 ef cb    	vpxord zmm1,zmm1,zmm3
  402e24:	62 f1 55 48 ef 58 0b 	vpxord zmm3,zmm5,ZMMWORD PTR [rax+0x2c0]
  402e2b:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402e32:	62 f1 6d 48 ef d3    	vpxord zmm2,zmm2,zmm3
  402e38:	48 81 fa 00 04 00 00 	cmp    rdx,0x400
  402e3f:	75 7e                	jne    402ebf <chainhash_x86_avx512.constprop.0+0x4ff>
  402e41:	62 f1 7e 48 6f 78 0c 	vmovdqu32 zmm7,ZMMWORD PTR [rax+0x300]
  402e48:	62 f1 45 48 ef 1d ae 	vpxord zmm3,zmm7,ZMMWORD PTR [rip+0x66ae]        # 409500 <oldx+0x300>
  402e4f:	66 00 00 
  402e52:	62 f1 7e 48 6f 68 0d 	vmovdqu32 zmm5,ZMMWORD PTR [rax+0x340]
  402e59:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402e60:	62 f1 7d 48 ef c3    	vpxord zmm0,zmm0,zmm3
  402e66:	62 f1 55 48 ef 1d d0 	vpxord zmm3,zmm5,ZMMWORD PTR [rip+0x66d0]        # 409540 <oldx+0x340>
  402e6d:	66 00 00 
  402e70:	62 f1 7e 48 6f 68 0e 	vmovdqu32 zmm5,ZMMWORD PTR [rax+0x380]
  402e77:	62 f1 fd 48 6f f8    	vmovdqa64 zmm7,zmm0
  402e7d:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402e84:	62 f1 4d 48 ef f3    	vpxord zmm6,zmm6,zmm3
  402e8a:	62 f1 55 48 ef 1d ec 	vpxord zmm3,zmm5,ZMMWORD PTR [rip+0x66ec]        # 409580 <oldx+0x380>
  402e91:	66 00 00 
  402e94:	62 f1 7e 48 6f 68 0f 	vmovdqu32 zmm5,ZMMWORD PTR [rax+0x3c0]
  402e9b:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402ea2:	62 f1 75 48 ef cb    	vpxord zmm1,zmm1,zmm3
  402ea8:	62 f1 55 48 ef 1d 0e 	vpxord zmm3,zmm5,ZMMWORD PTR [rip+0x670e]        # 4095c0 <oldx+0x3c0>
  402eaf:	67 00 00 
  402eb2:	62 f3 65 48 44 db 10 	vpclmullqhqdq zmm3,zmm3,zmm3
  402eb9:	62 f1 6d 48 ef d3    	vpxord zmm2,zmm2,zmm3
  402ebf:	40 30 f6             	xor    sil,sil
  402ec2:	62 f1 75 48 ef ca    	vpxord zmm1,zmm1,zmm2
  402ec8:	0f b6 d2             	movzx  edx,dl
  402ecb:	48 81 c6 00 01 00 00 	add    rsi,0x100
  402ed2:	62 f1 75 48 ef ce    	vpxord zmm1,zmm1,zmm6
  402ed8:	48 83 fa 3f          	cmp    rdx,0x3f
  402edc:	76 7f                	jbe    402f5d <chainhash_x86_avx512.constprop.0+0x59d>
  402ede:	62 f1 7e 48 6f ae 00 	vmovdqu32 zmm5,ZMMWORD PTR [rsi+0x409200]
  402ee5:	92 40 00 
  402ee8:	62 f1 55 48 ef 04 30 	vpxord zmm0,zmm5,ZMMWORD PTR [rax+rsi*1]
  402eef:	48 8d 7a c0          	lea    rdi,[rdx-0x40]
  402ef3:	4c 8d 46 40          	lea    r8,[rsi+0x40]
  402ef7:	62 f3 7d 48 44 c0 10 	vpclmullqhqdq zmm0,zmm0,zmm0
  402efe:	62 f1 7d 48 ef c7    	vpxord zmm0,zmm0,zmm7
  402f04:	48 83 ff 3f          	cmp    rdi,0x3f
  402f08:	76 48                	jbe    402f52 <chainhash_x86_avx512.constprop.0+0x592>
  402f0a:	62 f1 7e 48 6f be 40 	vmovdqu32 zmm7,ZMMWORD PTR [rsi+0x409240]
  402f11:	92 40 00 
  402f14:	62 f1 45 48 ef 54 30 	vpxord zmm2,zmm7,ZMMWORD PTR [rax+rsi*1+0x40]
  402f1b:	01 
  402f1c:	4c 8d 4a 80          	lea    r9,[rdx-0x80]
  402f20:	62 f3 6d 48 44 d2 10 	vpclmullqhqdq zmm2,zmm2,zmm2
  402f27:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
  402f2d:	49 83 f9 3f          	cmp    r9,0x3f
  402f31:	76 1f                	jbe    402f52 <chainhash_x86_avx512.constprop.0+0x592>
  402f33:	62 f1 7e 48 6f 7c 30 	vmovdqu32 zmm7,ZMMWORD PTR [rax+rsi*1+0x80]
  402f3a:	02 
  402f3b:	62 f1 45 48 ef 96 80 	vpxord zmm2,zmm7,ZMMWORD PTR [rsi+0x409280]
  402f42:	92 40 00 
  402f45:	62 f3 6d 48 44 d2 10 	vpclmullqhqdq zmm2,zmm2,zmm2
  402f4c:	62 f1 7d 48 ef c2    	vpxord zmm0,zmm0,zmm2
  402f52:	48 83 e7 c0          	and    rdi,0xffffffffffffffc0
  402f56:	83 e2 3f             	and    edx,0x3f
  402f59:	4a 8d 34 07          	lea    rsi,[rdi+r8*1]
  402f5d:	62 f1 75 48 ef c0    	vpxord zmm0,zmm1,zmm0
  402f63:	62 f3 fd 48 3b c1 01 	vextracti64x4 ymm1,zmm0,0x1
  402f6a:	c5 f5 ef c0          	vpxor  ymm0,ymm1,ymm0
  402f6e:	c4 e3 7d 39 c1 01    	vextracti128 xmm1,ymm0,0x1
  402f74:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  402f78:	48 85 d2             	test   rdx,rdx
  402f7b:	0f 85 01 01 00 00    	jne    403082 <chainhash_x86_avx512.constprop.0+0x6c2>
  402f81:	48 8b 05 80 66 00 00 	mov    rax,QWORD PTR [rip+0x6680]        # 409608 <oldx+0x408>
  402f88:	c4 e1 f9 6e f9       	vmovq  xmm7,rcx
  402f8d:	c5 f9 6f 6c 24 18    	vmovdqa xmm5,XMMWORD PTR [rsp+0x18]
  402f93:	c5 f9 6f 74 24 08    	vmovdqa xmm6,XMMWORD PTR [rsp+0x8]
  402f99:	48 31 c8             	xor    rax,rcx
  402f9c:	c4 e3 c1 22 c8 01    	vpinsrq xmm1,xmm7,rax,0x1
  402fa2:	48 8b 05 6f 66 00 00 	mov    rax,QWORD PTR [rip+0x666f]        # 409618 <oldx+0x418>
  402fa9:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  402fad:	c4 e3 71 44 44 24 28 	vpclmulhqlqdq xmm0,xmm1,XMMWORD PTR [rsp+0x28]
  402fb4:	01 
  402fb5:	c4 e3 79 44 d5 01    	vpclmulhqlqdq xmm2,xmm0,xmm5
  402fbb:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  402fc0:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  402fc4:	c5 fa 7e 0d 74 66 00 	vmovq  xmm1,QWORD PTR [rip+0x6674]        # 409640 <oldx+0x440>
  402fcb:	00 
  402fcc:	c4 e2 49 00 db       	vpshufb xmm3,xmm6,xmm3
  402fd1:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  402fd5:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  402fd9:	c5 f9 d4 c1          	vpaddq xmm0,xmm0,xmm1
  402fdd:	c4 e3 79 44 d0 00    	vpclmullqlqdq xmm2,xmm0,xmm0
  402fe3:	c4 e3 69 44 cd 01    	vpclmulhqlqdq xmm1,xmm2,xmm5
  402fe9:	c5 e1 73 d9 08       	vpsrldq xmm3,xmm1,0x8
  402fee:	c4 e2 49 00 db       	vpshufb xmm3,xmm6,xmm3
  402ff3:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  402ff7:	c4 e1 f9 6e d8       	vmovq  xmm3,rax
  402ffc:	48 33 05 1d 66 00 00 	xor    rax,QWORD PTR [rip+0x661d]        # 409620 <oldx+0x420>
  403003:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  403007:	c5 fa 7e 1d 19 66 00 	vmovq  xmm3,QWORD PTR [rip+0x6619]        # 409628 <oldx+0x428>
  40300e:	00 
  40300f:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  403013:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  403018:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  40301c:	c5 e1 ef d8          	vpxor  xmm3,xmm3,xmm0
  403020:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  403024:	c5 fa 7e 05 04 66 00 	vmovq  xmm0,QWORD PTR [rip+0x6604]        # 409630 <oldx+0x430>
  40302b:	00 
  40302c:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  403032:	c4 e3 71 44 d5 01    	vpclmulhqlqdq xmm2,xmm1,xmm5
  403038:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  40303c:	c5 d9 73 da 08       	vpsrldq xmm4,xmm2,0x8
  403041:	c4 e2 49 00 e4       	vpshufb xmm4,xmm6,xmm4
  403046:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  40304a:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  40304e:	c5 fa 7e 15 e2 65 00 	vmovq  xmm2,QWORD PTR [rip+0x65e2]        # 409638 <oldx+0x438>
  403055:	00 
  403056:	c4 e3 61 44 d8 00    	vpclmullqlqdq xmm3,xmm3,xmm0
  40305c:	c4 e3 61 44 c5 01    	vpclmulhqlqdq xmm0,xmm3,xmm5
  403062:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  403066:	c5 f1 73 d8 08       	vpsrldq xmm1,xmm0,0x8
  40306b:	c4 e2 49 00 c9       	vpshufb xmm1,xmm6,xmm1
  403070:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  403074:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  403078:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  40307d:	c5 f8 77             	vzeroupper 
  403080:	c9                   	leave  
  403081:	c3                   	ret    
  403082:	48 01 f0             	add    rax,rsi
  403085:	48 8d be 00 92 40 00 	lea    rdi,[rsi+0x409200]
  40308c:	48 83 fa 0f          	cmp    rdx,0xf
  403090:	0f 86 38 01 00 00    	jbe    4031ce <chainhash_x86_avx512.constprop.0+0x80e>
  403096:	c5 fa 6f 38          	vmovdqu xmm7,XMMWORD PTR [rax]
  40309a:	c5 c1 ef 8e 00 92 40 	vpxor  xmm1,xmm7,XMMWORD PTR [rsi+0x409200]
  4030a1:	00 
  4030a2:	48 8d 72 f0          	lea    rsi,[rdx-0x10]
  4030a6:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  4030ac:	48 83 fe 0f          	cmp    rsi,0xf
  4030b0:	76 32                	jbe    4030e4 <chainhash_x86_avx512.constprop.0+0x724>
  4030b2:	c5 fa 6f 78 10       	vmovdqu xmm7,XMMWORD PTR [rax+0x10]
  4030b7:	c5 c1 ef 57 10       	vpxor  xmm2,xmm7,XMMWORD PTR [rdi+0x10]
  4030bc:	4c 8d 42 e0          	lea    r8,[rdx-0x20]
  4030c0:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  4030c6:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4030ca:	49 83 f8 0f          	cmp    r8,0xf
  4030ce:	76 14                	jbe    4030e4 <chainhash_x86_avx512.constprop.0+0x724>
  4030d0:	c5 fa 6f 78 20       	vmovdqu xmm7,XMMWORD PTR [rax+0x20]
  4030d5:	c5 c1 ef 57 20       	vpxor  xmm2,xmm7,XMMWORD PTR [rdi+0x20]
  4030da:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  4030e0:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4030e4:	48 83 e6 f0          	and    rsi,0xfffffffffffffff0
  4030e8:	48 83 c6 10          	add    rsi,0x10
  4030ec:	83 e2 0f             	and    edx,0xf
  4030ef:	75 45                	jne    403136 <chainhash_x86_avx512.constprop.0+0x776>
  4030f1:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  4030f5:	e9 87 fe ff ff       	jmp    402f81 <chainhash_x86_avx512.constprop.0+0x5c1>
  4030fa:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  4030fe:	c5 c1 ef ff          	vpxor  xmm7,xmm7,xmm7
  403102:	31 f6                	xor    esi,esi
  403104:	62 f1 7d 48 6f c8    	vmovdqa32 zmm1,zmm0
  40310a:	e9 c9 fd ff ff       	jmp    402ed8 <chainhash_x86_avx512.constprop.0+0x518>
  40310f:	c5 f9 6f 3d 09 40 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x4009]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  403116:	00 
  403117:	48 89 f2             	mov    rdx,rsi
  40311a:	48 89 f8             	mov    rax,rdi
  40311d:	c5 f9 7f 7c 24 18    	vmovdqa XMMWORD PTR [rsp+0x18],xmm7
  403123:	c5 f9 6f 3d 05 40 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x4005]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  40312a:	00 
  40312b:	c5 f9 7f 7c 24 08    	vmovdqa XMMWORD PTR [rsp+0x8],xmm7
  403131:	e9 5a fb ff ff       	jmp    402c90 <chainhash_x86_avx512.constprop.0+0x2d0>
  403136:	48 01 f0             	add    rax,rsi
  403139:	48 01 f7             	add    rdi,rsi
  40313c:	c5 e9 ef d2          	vpxor  xmm2,xmm2,xmm2
  403140:	41 89 d1             	mov    r9d,edx
  403143:	4c 8d 44 24 38       	lea    r8,[rsp+0x38]
  403148:	48 89 c6             	mov    rsi,rax
  40314b:	c5 f9 7f 54 24 38    	vmovdqa XMMWORD PTR [rsp+0x38],xmm2
  403151:	83 fa 08             	cmp    edx,0x8
  403154:	73 52                	jae    4031a8 <chainhash_x86_avx512.constprop.0+0x7e8>
  403156:	31 c0                	xor    eax,eax
  403158:	41 f6 c1 04          	test   r9b,0x4
  40315c:	75 3e                	jne    40319c <chainhash_x86_avx512.constprop.0+0x7dc>
  40315e:	41 f6 c1 02          	test   r9b,0x2
  403162:	75 29                	jne    40318d <chainhash_x86_avx512.constprop.0+0x7cd>
  403164:	41 83 e1 01          	and    r9d,0x1
  403168:	75 19                	jne    403183 <chainhash_x86_avx512.constprop.0+0x7c3>
  40316a:	c5 f9 6f 7c 24 38    	vmovdqa xmm7,XMMWORD PTR [rsp+0x38]
  403170:	c5 c1 ef 17          	vpxor  xmm2,xmm7,XMMWORD PTR [rdi]
  403174:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  40317a:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  40317e:	e9 6e ff ff ff       	jmp    4030f1 <chainhash_x86_avx512.constprop.0+0x731>
  403183:	0f b6 14 06          	movzx  edx,BYTE PTR [rsi+rax*1]
  403187:	41 88 14 00          	mov    BYTE PTR [r8+rax*1],dl
  40318b:	eb dd                	jmp    40316a <chainhash_x86_avx512.constprop.0+0x7aa>
  40318d:	0f b7 14 06          	movzx  edx,WORD PTR [rsi+rax*1]
  403191:	66 41 89 14 00       	mov    WORD PTR [r8+rax*1],dx
  403196:	48 83 c0 02          	add    rax,0x2
  40319a:	eb c8                	jmp    403164 <chainhash_x86_avx512.constprop.0+0x7a4>
  40319c:	8b 06                	mov    eax,DWORD PTR [rsi]
  40319e:	41 89 00             	mov    DWORD PTR [r8],eax
  4031a1:	b8 04 00 00 00       	mov    eax,0x4
  4031a6:	eb b6                	jmp    40315e <chainhash_x86_avx512.constprop.0+0x79e>
  4031a8:	83 e2 f8             	and    edx,0xfffffff8
  4031ab:	31 f6                	xor    esi,esi
  4031ad:	41 89 f0             	mov    r8d,esi
  4031b0:	83 c6 08             	add    esi,0x8
  4031b3:	4e 8b 14 00          	mov    r10,QWORD PTR [rax+r8*1]
  4031b7:	4e 89 54 04 38       	mov    QWORD PTR [rsp+r8*1+0x38],r10
  4031bc:	39 d6                	cmp    esi,edx
  4031be:	72 ed                	jb     4031ad <chainhash_x86_avx512.constprop.0+0x7ed>
  4031c0:	48 8d 54 24 38       	lea    rdx,[rsp+0x38]
  4031c5:	4c 8d 04 32          	lea    r8,[rdx+rsi*1]
  4031c9:	48 01 c6             	add    rsi,rax
  4031cc:	eb 88                	jmp    403156 <chainhash_x86_avx512.constprop.0+0x796>
  4031ce:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
  4031d2:	e9 65 ff ff ff       	jmp    40313c <chainhash_x86_avx512.constprop.0+0x77c>
  4031d7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  4031de:	00 00 

00000000004031e0 <chainhash_x86_avx2.constprop.0>:
  4031e0:	55                   	push   rbp
  4031e1:	48 89 e5             	mov    rbp,rsp
  4031e4:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
  4031e8:	48 8b 05 21 64 00 00 	mov    rax,QWORD PTR [rip+0x6421]        # 409610 <oldx+0x410>
  4031ef:	48 33 05 0a 64 00 00 	xor    rax,QWORD PTR [rip+0x640a]        # 409600 <oldx+0x400>
  4031f6:	c5 79 6f 0d 02 64 00 	vmovdqa xmm9,XMMWORD PTR [rip+0x6402]        # 409600 <oldx+0x400>
  4031fd:	00 
  4031fe:	c4 e1 f9 6e f0       	vmovq  xmm6,rax
  403203:	48 81 fe 00 04 00 00 	cmp    rsi,0x400
  40320a:	0f 86 31 03 00 00    	jbe    403541 <chainhash_x86_avx2.constprop.0+0x361>
  403210:	48 8d 8e ff fb ff ff 	lea    rcx,[rsi-0x401]
  403217:	c5 f9 6f 3d 01 3f 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x3f01]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  40321e:	00 
  40321f:	c5 79 6f 05 09 3f 00 	vmovdqa xmm8,XMMWORD PTR [rip+0x3f09]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  403226:	00 
  403227:	48 c1 e9 0a          	shr    rcx,0xa
  40322b:	48 8d 51 01          	lea    rdx,[rcx+0x1]
  40322f:	48 c1 e2 0a          	shl    rdx,0xa
  403233:	48 01 fa             	add    rdx,rdi
  403236:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  40323d:	00 00 00 
  403240:	c4 41 29 ef d2       	vpxor  xmm10,xmm10,xmm10
  403245:	31 c0                	xor    eax,eax
  403247:	c5 79 7f d5          	vmovdqa xmm5,xmm10
  40324b:	c5 79 7f d4          	vmovdqa xmm4,xmm10
  40324f:	c5 79 7f d3          	vmovdqa xmm3,xmm10
  403253:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  403258:	c5 fe 6f 14 07       	vmovdqu ymm2,YMMWORD PTR [rdi+rax*1]
  40325d:	c5 ed ef 88 00 92 40 	vpxor  ymm1,ymm2,YMMWORD PTR [rax+0x409200]
  403264:	00 
  403265:	c5 fe 6f 54 07 20    	vmovdqu ymm2,YMMWORD PTR [rdi+rax*1+0x20]
  40326b:	c5 ed ef 80 20 92 40 	vpxor  ymm0,ymm2,YMMWORD PTR [rax+0x409220]
  403272:	00 
  403273:	48 83 c0 40          	add    rax,0x40
  403277:	c5 79 6f d9          	vmovdqa xmm11,xmm1
  40327b:	c4 e3 7d 39 c9 01    	vextracti128 xmm1,ymm1,0x1
  403281:	c5 f9 6f d0          	vmovdqa xmm2,xmm0
  403285:	c4 e3 7d 39 c0 01    	vextracti128 xmm0,ymm0,0x1
  40328b:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  403291:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  403297:	c4 43 21 44 db 10    	vpclmullqhqdq xmm11,xmm11,xmm11
  40329d:	c4 e3 79 44 c0 10    	vpclmullqhqdq xmm0,xmm0,xmm0
  4032a3:	c5 a9 ef c0          	vpxor  xmm0,xmm10,xmm0
  4032a7:	c4 c1 61 ef db       	vpxor  xmm3,xmm3,xmm11
  4032ac:	c5 d9 ef e1          	vpxor  xmm4,xmm4,xmm1
  4032b0:	c5 d1 ef ea          	vpxor  xmm5,xmm5,xmm2
  4032b4:	c5 e1 ef cc          	vpxor  xmm1,xmm3,xmm4
  4032b8:	c5 79 6f d0          	vmovdqa xmm10,xmm0
  4032bc:	c5 d1 ef d0          	vpxor  xmm2,xmm5,xmm0
  4032c0:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4032c4:	48 3d 00 04 00 00    	cmp    rax,0x400
  4032ca:	75 8c                	jne    403258 <chainhash_x86_avx2.constprop.0+0x78>
  4032cc:	c4 c1 71 ef c9       	vpxor  xmm1,xmm1,xmm9
  4032d1:	48 81 c7 00 04 00 00 	add    rdi,0x400
  4032d8:	c4 e3 71 44 f6 01    	vpclmulhqlqdq xmm6,xmm1,xmm6
  4032de:	c4 e3 49 44 c7 01    	vpclmulhqlqdq xmm0,xmm6,xmm7
  4032e4:	c5 c9 ef f1          	vpxor  xmm6,xmm6,xmm1
  4032e8:	c5 e9 73 d8 08       	vpsrldq xmm2,xmm0,0x8
  4032ed:	c4 e2 39 00 d2       	vpshufb xmm2,xmm8,xmm2
  4032f2:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  4032f6:	c5 f9 ef f6          	vpxor  xmm6,xmm0,xmm6
  4032fa:	48 39 d7             	cmp    rdi,rdx
  4032fd:	0f 85 3d ff ff ff    	jne    403240 <chainhash_x86_avx2.constprop.0+0x60>
  403303:	48 f7 d9             	neg    rcx
  403306:	48 c1 e1 0a          	shl    rcx,0xa
  40330a:	4c 8d 84 0e 00 fc ff 	lea    r8,[rsi+rcx*1-0x400]
  403311:	ff 
  403312:	49 83 f8 3f          	cmp    r8,0x3f
  403316:	0f 86 18 02 00 00    	jbe    403534 <chainhash_x86_avx2.constprop.0+0x354>
  40331c:	49 8d 78 c0          	lea    rdi,[r8-0x40]
  403320:	c4 41 31 ef c9       	vpxor  xmm9,xmm9,xmm9
  403325:	31 c0                	xor    eax,eax
  403327:	c5 79 7f cc          	vmovdqa xmm4,xmm9
  40332b:	c5 79 7f cd          	vmovdqa xmm5,xmm9
  40332f:	c5 79 7f cb          	vmovdqa xmm3,xmm9
  403333:	48 83 e7 c0          	and    rdi,0xffffffffffffffc0
  403337:	4c 8d 4f 40          	lea    r9,[rdi+0x40]
  40333b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  403340:	c5 fe 6f 14 02       	vmovdqu ymm2,YMMWORD PTR [rdx+rax*1]
  403345:	c5 ed ef 88 00 92 40 	vpxor  ymm1,ymm2,YMMWORD PTR [rax+0x409200]
  40334c:	00 
  40334d:	48 89 c1             	mov    rcx,rax
  403350:	c5 fe 6f 54 02 20    	vmovdqu ymm2,YMMWORD PTR [rdx+rax*1+0x20]
  403356:	c5 ed ef 80 20 92 40 	vpxor  ymm0,ymm2,YMMWORD PTR [rax+0x409220]
  40335d:	00 
  40335e:	48 83 c0 40          	add    rax,0x40
  403362:	c5 79 6f d1          	vmovdqa xmm10,xmm1
  403366:	c4 e3 7d 39 c9 01    	vextracti128 xmm1,ymm1,0x1
  40336c:	c5 f9 6f d0          	vmovdqa xmm2,xmm0
  403370:	c4 e3 7d 39 c0 01    	vextracti128 xmm0,ymm0,0x1
  403376:	c4 43 29 44 d2 10    	vpclmullqhqdq xmm10,xmm10,xmm10
  40337c:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  403382:	c4 e3 69 44 d2 10    	vpclmullqhqdq xmm2,xmm2,xmm2
  403388:	c4 e3 79 44 c0 10    	vpclmullqhqdq xmm0,xmm0,xmm0
  40338e:	c5 d1 ef c9          	vpxor  xmm1,xmm5,xmm1
  403392:	c5 b1 ef c0          	vpxor  xmm0,xmm9,xmm0
  403396:	c4 c1 61 ef da       	vpxor  xmm3,xmm3,xmm10
  40339b:	c5 d9 ef e2          	vpxor  xmm4,xmm4,xmm2
  40339f:	c5 61 ef d1          	vpxor  xmm10,xmm3,xmm1
  4033a3:	c5 f9 6f e9          	vmovdqa xmm5,xmm1
  4033a7:	c5 79 6f c8          	vmovdqa xmm9,xmm0
  4033ab:	c5 d9 ef c8          	vpxor  xmm1,xmm4,xmm0
  4033af:	48 39 f9             	cmp    rcx,rdi
  4033b2:	75 8c                	jne    403340 <chainhash_x86_avx2.constprop.0+0x160>
  4033b4:	41 83 e0 3f          	and    r8d,0x3f
  4033b8:	c5 29 ef d1          	vpxor  xmm10,xmm10,xmm1
  4033bc:	4d 85 c0             	test   r8,r8
  4033bf:	0f 85 f5 00 00 00    	jne    4034ba <chainhash_x86_avx2.constprop.0+0x2da>
  4033c5:	48 8b 05 3c 62 00 00 	mov    rax,QWORD PTR [rip+0x623c]        # 409608 <oldx+0x408>
  4033cc:	c4 e1 f9 6e ee       	vmovq  xmm5,rsi
  4033d1:	48 31 f0             	xor    rax,rsi
  4033d4:	c4 e3 d1 22 c8 01    	vpinsrq xmm1,xmm5,rax,0x1
  4033da:	48 8b 05 37 62 00 00 	mov    rax,QWORD PTR [rip+0x6237]        # 409618 <oldx+0x418>
  4033e1:	c4 c1 71 ef ca       	vpxor  xmm1,xmm1,xmm10
  4033e6:	c4 e3 71 44 f6 01    	vpclmulhqlqdq xmm6,xmm1,xmm6
  4033ec:	c4 e1 f9 6e e0       	vmovq  xmm4,rax
  4033f1:	48 33 05 28 62 00 00 	xor    rax,QWORD PTR [rip+0x6228]        # 409620 <oldx+0x420>
  4033f8:	c4 e3 49 44 d7 01    	vpclmulhqlqdq xmm2,xmm6,xmm7
  4033fe:	c5 f9 73 da 08       	vpsrldq xmm0,xmm2,0x8
  403403:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  403407:	c5 fa 7e 0d 31 62 00 	vmovq  xmm1,QWORD PTR [rip+0x6231]        # 409640 <oldx+0x440>
  40340e:	00 
  40340f:	c4 e2 39 00 c0       	vpshufb xmm0,xmm8,xmm0
  403414:	c5 c9 ef c0          	vpxor  xmm0,xmm6,xmm0
  403418:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  40341c:	c5 f9 d4 c1          	vpaddq xmm0,xmm0,xmm1
  403420:	c4 e3 79 44 c8 00    	vpclmullqlqdq xmm1,xmm0,xmm0
  403426:	c4 e3 71 44 d7 01    	vpclmulhqlqdq xmm2,xmm1,xmm7
  40342c:	c5 f1 ef cc          	vpxor  xmm1,xmm1,xmm4
  403430:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  403435:	c4 e2 39 00 db       	vpshufb xmm3,xmm8,xmm3
  40343a:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  40343e:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  403442:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  403447:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  40344b:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  40344f:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  403455:	c5 fa 7e 15 cb 61 00 	vmovq  xmm2,QWORD PTR [rip+0x61cb]        # 409628 <oldx+0x428>
  40345c:	00 
  40345d:	c4 e3 71 44 df 01    	vpclmulhqlqdq xmm3,xmm1,xmm7
  403463:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  403467:	c5 d9 73 db 08       	vpsrldq xmm4,xmm3,0x8
  40346c:	c5 fa 7e 15 bc 61 00 	vmovq  xmm2,QWORD PTR [rip+0x61bc]        # 409630 <oldx+0x430>
  403473:	00 
  403474:	c4 e2 39 00 e4       	vpshufb xmm4,xmm8,xmm4
  403479:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  40347d:	c5 e1 ef dc          	vpxor  xmm3,xmm3,xmm4
  403481:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  403485:	c4 e3 79 44 c9 00    	vpclmullqlqdq xmm1,xmm0,xmm1
  40348b:	c4 e3 71 44 ff 01    	vpclmulhqlqdq xmm7,xmm1,xmm7
  403491:	c5 f9 73 df 08       	vpsrldq xmm0,xmm7,0x8
  403496:	c4 62 39 00 c0       	vpshufb xmm8,xmm8,xmm0
  40349b:	c5 fa 7e 05 95 61 00 	vmovq  xmm0,QWORD PTR [rip+0x6195]        # 409638 <oldx+0x438>
  4034a2:	00 
  4034a3:	c4 c1 41 ef f8       	vpxor  xmm7,xmm7,xmm8
  4034a8:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  4034ac:	c5 f9 ef c7          	vpxor  xmm0,xmm0,xmm7
  4034b0:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  4034b5:	c5 f8 77             	vzeroupper 
  4034b8:	c9                   	leave  
  4034b9:	c3                   	ret    
  4034ba:	4c 01 ca             	add    rdx,r9
  4034bd:	49 8d 89 00 92 40 00 	lea    rcx,[r9+0x409200]
  4034c4:	49 83 f8 0f          	cmp    r8,0xf
  4034c8:	0f 86 23 01 00 00    	jbe    4035f1 <chainhash_x86_avx2.constprop.0+0x411>
  4034ce:	c5 fa 6f 2a          	vmovdqu xmm5,XMMWORD PTR [rdx]
  4034d2:	49 8d 40 f0          	lea    rax,[r8-0x10]
  4034d6:	c4 c1 51 ef 81 00 92 	vpxor  xmm0,xmm5,XMMWORD PTR [r9+0x409200]
  4034dd:	40 00 
  4034df:	c4 e3 79 44 c0 10    	vpclmullqhqdq xmm0,xmm0,xmm0
  4034e5:	48 83 f8 0f          	cmp    rax,0xf
  4034e9:	76 32                	jbe    40351d <chainhash_x86_avx2.constprop.0+0x33d>
  4034eb:	c5 fa 6f 6a 10       	vmovdqu xmm5,XMMWORD PTR [rdx+0x10]
  4034f0:	c5 d1 ef 49 10       	vpxor  xmm1,xmm5,XMMWORD PTR [rcx+0x10]
  4034f5:	49 8d 78 e0          	lea    rdi,[r8-0x20]
  4034f9:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  4034ff:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  403503:	48 83 ff 0f          	cmp    rdi,0xf
  403507:	76 14                	jbe    40351d <chainhash_x86_avx2.constprop.0+0x33d>
  403509:	c5 fa 6f 6a 20       	vmovdqu xmm5,XMMWORD PTR [rdx+0x20]
  40350e:	c5 d1 ef 49 20       	vpxor  xmm1,xmm5,XMMWORD PTR [rcx+0x20]
  403513:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  403519:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  40351d:	48 83 e0 f0          	and    rax,0xfffffffffffffff0
  403521:	48 83 c0 10          	add    rax,0x10
  403525:	41 83 e0 0f          	and    r8d,0xf
  403529:	75 31                	jne    40355c <chainhash_x86_avx2.constprop.0+0x37c>
  40352b:	c5 29 ef d0          	vpxor  xmm10,xmm10,xmm0
  40352f:	e9 91 fe ff ff       	jmp    4033c5 <chainhash_x86_avx2.constprop.0+0x1e5>
  403534:	c4 41 29 ef d2       	vpxor  xmm10,xmm10,xmm10
  403539:	45 31 c9             	xor    r9d,r9d
  40353c:	e9 7b fe ff ff       	jmp    4033bc <chainhash_x86_avx2.constprop.0+0x1dc>
  403541:	c5 f9 6f 3d d7 3b 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x3bd7]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  403548:	00 
  403549:	c5 79 6f 05 df 3b 00 	vmovdqa xmm8,XMMWORD PTR [rip+0x3bdf]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  403550:	00 
  403551:	49 89 f0             	mov    r8,rsi
  403554:	48 89 fa             	mov    rdx,rdi
  403557:	e9 b6 fd ff ff       	jmp    403312 <chainhash_x86_avx2.constprop.0+0x132>
  40355c:	48 01 c2             	add    rdx,rax
  40355f:	48 01 c1             	add    rcx,rax
  403562:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
  403566:	45 89 c1             	mov    r9d,r8d
  403569:	48 8d 7c 24 f0       	lea    rdi,[rsp-0x10]
  40356e:	48 89 d0             	mov    rax,rdx
  403571:	c5 f9 7f 4c 24 f0    	vmovdqa XMMWORD PTR [rsp-0x10],xmm1
  403577:	41 83 f8 08          	cmp    r8d,0x8
  40357b:	73 4e                	jae    4035cb <chainhash_x86_avx2.constprop.0+0x3eb>
  40357d:	31 d2                	xor    edx,edx
  40357f:	41 f6 c1 04          	test   r9b,0x4
  403583:	75 3b                	jne    4035c0 <chainhash_x86_avx2.constprop.0+0x3e0>
  403585:	41 f6 c1 02          	test   r9b,0x2
  403589:	75 25                	jne    4035b0 <chainhash_x86_avx2.constprop.0+0x3d0>
  40358b:	41 83 e1 01          	and    r9d,0x1
  40358f:	75 16                	jne    4035a7 <chainhash_x86_avx2.constprop.0+0x3c7>
  403591:	c5 f9 6f 6c 24 f0    	vmovdqa xmm5,XMMWORD PTR [rsp-0x10]
  403597:	c5 d1 ef 09          	vpxor  xmm1,xmm5,XMMWORD PTR [rcx]
  40359b:	c4 e3 71 44 c9 10    	vpclmullqhqdq xmm1,xmm1,xmm1
  4035a1:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  4035a5:	eb 84                	jmp    40352b <chainhash_x86_avx2.constprop.0+0x34b>
  4035a7:	0f b6 04 10          	movzx  eax,BYTE PTR [rax+rdx*1]
  4035ab:	88 04 17             	mov    BYTE PTR [rdi+rdx*1],al
  4035ae:	eb e1                	jmp    403591 <chainhash_x86_avx2.constprop.0+0x3b1>
  4035b0:	44 0f b7 04 10       	movzx  r8d,WORD PTR [rax+rdx*1]
  4035b5:	66 44 89 04 17       	mov    WORD PTR [rdi+rdx*1],r8w
  4035ba:	48 83 c2 02          	add    rdx,0x2
  4035be:	eb cb                	jmp    40358b <chainhash_x86_avx2.constprop.0+0x3ab>
  4035c0:	8b 10                	mov    edx,DWORD PTR [rax]
  4035c2:	89 17                	mov    DWORD PTR [rdi],edx
  4035c4:	ba 04 00 00 00       	mov    edx,0x4
  4035c9:	eb ba                	jmp    403585 <chainhash_x86_avx2.constprop.0+0x3a5>
  4035cb:	41 83 e0 f8          	and    r8d,0xfffffff8
  4035cf:	31 c0                	xor    eax,eax
  4035d1:	89 c7                	mov    edi,eax
  4035d3:	83 c0 08             	add    eax,0x8
  4035d6:	4c 8b 14 3a          	mov    r10,QWORD PTR [rdx+rdi*1]
  4035da:	4c 89 54 3c f0       	mov    QWORD PTR [rsp+rdi*1-0x10],r10
  4035df:	44 39 c0             	cmp    eax,r8d
  4035e2:	72 ed                	jb     4035d1 <chainhash_x86_avx2.constprop.0+0x3f1>
  4035e4:	48 8d 7c 24 f0       	lea    rdi,[rsp-0x10]
  4035e9:	48 01 c7             	add    rdi,rax
  4035ec:	48 01 d0             	add    rax,rdx
  4035ef:	eb 8c                	jmp    40357d <chainhash_x86_avx2.constprop.0+0x39d>
  4035f1:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  4035f5:	e9 68 ff ff ff       	jmp    403562 <chainhash_x86_avx2.constprop.0+0x382>
  4035fa:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000403600 <old>:
  403600:	41 57                	push   r15
  403602:	49 89 ff             	mov    r15,rdi
  403605:	41 56                	push   r14
  403607:	41 55                	push   r13
  403609:	41 54                	push   r12
  40360b:	55                   	push   rbp
  40360c:	53                   	push   rbx
  40360d:	48 89 74 24 d8       	mov    QWORD PTR [rsp-0x28],rsi
  403612:	8b 35 70 5a 00 00    	mov    esi,DWORD PTR [rip+0x5a70]        # 409088 <cached.2>
  403618:	85 f6                	test   esi,esi
  40361a:	0f 84 8a 04 00 00    	je     403aaa <old+0x4aa>
  403620:	8d 46 ff             	lea    eax,[rsi-0x1]
  403623:	83 fe 03             	cmp    esi,0x3
  403626:	0f 84 16 05 00 00    	je     403b42 <old+0x542>
  40362c:	83 f8 01             	cmp    eax,0x1
  40362f:	0f 84 d0 04 00 00    	je     403b05 <old+0x505>
  403635:	48 8b 05 d4 5f 00 00 	mov    rax,QWORD PTR [rip+0x5fd4]        # 409610 <oldx+0x410>
  40363c:	48 8b 6c 24 d8       	mov    rbp,QWORD PTR [rsp-0x28]
  403641:	48 89 44 24 e0       	mov    QWORD PTR [rsp-0x20],rax
  403646:	48 8b 05 b3 5f 00 00 	mov    rax,QWORD PTR [rip+0x5fb3]        # 409600 <oldx+0x400>
  40364d:	48 89 44 24 e8       	mov    QWORD PTR [rsp-0x18],rax
  403652:	48 8b 05 af 5f 00 00 	mov    rax,QWORD PTR [rip+0x5faf]        # 409608 <oldx+0x408>
  403659:	48 89 44 24 f0       	mov    QWORD PTR [rsp-0x10],rax
  40365e:	b8 00 04 00 00       	mov    eax,0x400
  403663:	48 39 c5             	cmp    rbp,rax
  403666:	48 0f 46 c5          	cmovbe rax,rbp
  40366a:	48 89 44 24 d0       	mov    QWORD PTR [rsp-0x30],rax
  40366f:	48 89 c3             	mov    rbx,rax
  403672:	48 83 fd 0f          	cmp    rbp,0xf
  403676:	0f 86 3b 03 00 00    	jbe    4039b7 <old+0x3b7>
  40367c:	4c 8d 73 f0          	lea    r14,[rbx-0x10]
  403680:	4c 89 f8             	mov    rax,r15
  403683:	45 31 c0             	xor    r8d,r8d
  403686:	45 31 e4             	xor    r12d,r12d
  403689:	49 83 e6 f0          	and    r14,0xfffffffffffffff0
  40368d:	45 31 d2             	xor    r10d,r10d
  403690:	4d 8d 6e 10          	lea    r13,[r14+0x10]
  403694:	eb 47                	jmp    4036dd <old+0xdd>
  403696:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  40369d:	00 00 00 
  4036a0:	b9 41 00 00 00       	mov    ecx,0x41
  4036a5:	48 89 f0             	mov    rax,rsi
  4036a8:	44 29 d9             	sub    ecx,r11d
  4036ab:	48 d3 e8             	shr    rax,cl
  4036ae:	48 21 c2             	and    rdx,rax
  4036b1:	48 31 d3             	xor    rbx,rdx
  4036b4:	41 83 fb 40          	cmp    r11d,0x40
  4036b8:	0f 85 fe 00 00 00    	jne    4037bc <old+0x1bc>
  4036be:	48 8b 44 24 c8       	mov    rax,QWORD PTR [rsp-0x38]
  4036c3:	4d 31 cc             	xor    r12,r9
  4036c6:	49 31 d8             	xor    r8,rbx
  4036c9:	49 8d 52 10          	lea    rdx,[r10+0x10]
  4036cd:	48 83 c0 10          	add    rax,0x10
  4036d1:	4d 39 f2             	cmp    r10,r14
  4036d4:	0f 84 e7 00 00 00    	je     4037c1 <old+0x1c1>
  4036da:	49 89 d2             	mov    r10,rdx
  4036dd:	0f b6 50 09          	movzx  edx,BYTE PTR [rax+0x9]
  4036e1:	0f b6 48 0a          	movzx  ecx,BYTE PTR [rax+0xa]
  4036e5:	48 89 44 24 c8       	mov    QWORD PTR [rsp-0x38],rax
  4036ea:	31 db                	xor    ebx,ebx
  4036ec:	0f b6 78 0f          	movzx  edi,BYTE PTR [rax+0xf]
  4036f0:	0f b6 70 07          	movzx  esi,BYTE PTR [rax+0x7]
  4036f4:	45 31 c9             	xor    r9d,r9d
  4036f7:	48 c1 e1 10          	shl    rcx,0x10
  4036fb:	48 c1 e2 08          	shl    rdx,0x8
  4036ff:	48 c1 e7 38          	shl    rdi,0x38
  403703:	48 09 ca             	or     rdx,rcx
  403706:	0f b6 48 08          	movzx  ecx,BYTE PTR [rax+0x8]
  40370a:	48 c1 e6 38          	shl    rsi,0x38
  40370e:	48 09 ca             	or     rdx,rcx
  403711:	0f b6 48 0b          	movzx  ecx,BYTE PTR [rax+0xb]
  403715:	48 c1 e1 18          	shl    rcx,0x18
  403719:	48 09 d1             	or     rcx,rdx
  40371c:	0f b6 50 0c          	movzx  edx,BYTE PTR [rax+0xc]
  403720:	48 c1 e2 20          	shl    rdx,0x20
  403724:	48 09 ca             	or     rdx,rcx
  403727:	0f b6 48 0d          	movzx  ecx,BYTE PTR [rax+0xd]
  40372b:	48 c1 e1 28          	shl    rcx,0x28
  40372f:	48 09 d1             	or     rcx,rdx
  403732:	0f b6 50 0e          	movzx  edx,BYTE PTR [rax+0xe]
  403736:	48 c1 e2 30          	shl    rdx,0x30
  40373a:	48 09 ca             	or     rdx,rcx
  40373d:	0f b6 48 02          	movzx  ecx,BYTE PTR [rax+0x2]
  403741:	48 09 d7             	or     rdi,rdx
  403744:	0f b6 50 01          	movzx  edx,BYTE PTR [rax+0x1]
  403748:	49 33 ba 08 92 40 00 	xor    rdi,QWORD PTR [r10+0x409208]
  40374f:	48 c1 e1 10          	shl    rcx,0x10
  403753:	48 c1 e2 08          	shl    rdx,0x8
  403757:	48 09 ca             	or     rdx,rcx
  40375a:	0f b6 08             	movzx  ecx,BYTE PTR [rax]
  40375d:	48 09 ca             	or     rdx,rcx
  403760:	0f b6 48 03          	movzx  ecx,BYTE PTR [rax+0x3]
  403764:	48 c1 e1 18          	shl    rcx,0x18
  403768:	48 09 d1             	or     rcx,rdx
  40376b:	0f b6 50 04          	movzx  edx,BYTE PTR [rax+0x4]
  40376f:	48 c1 e2 20          	shl    rdx,0x20
  403773:	48 09 ca             	or     rdx,rcx
  403776:	0f b6 48 05          	movzx  ecx,BYTE PTR [rax+0x5]
  40377a:	48 c1 e1 28          	shl    rcx,0x28
  40377e:	48 09 d1             	or     rcx,rdx
  403781:	0f b6 50 06          	movzx  edx,BYTE PTR [rax+0x6]
  403785:	48 c1 e2 30          	shl    rdx,0x30
  403789:	48 09 ca             	or     rdx,rcx
  40378c:	48 09 d6             	or     rsi,rdx
  40378f:	49 33 b2 00 92 40 00 	xor    rsi,QWORD PTR [r10+0x409200]
  403796:	31 c9                	xor    ecx,ecx
  403798:	48 89 fa             	mov    rdx,rdi
  40379b:	49 89 f3             	mov    r11,rsi
  40379e:	48 d3 ea             	shr    rdx,cl
  4037a1:	49 d3 e3             	shl    r11,cl
  4037a4:	83 e2 01             	and    edx,0x1
  4037a7:	48 f7 da             	neg    rdx
  4037aa:	49 21 d3             	and    r11,rdx
  4037ad:	4d 31 d9             	xor    r9,r11
  4037b0:	44 8d 59 01          	lea    r11d,[rcx+0x1]
  4037b4:	85 c9                	test   ecx,ecx
  4037b6:	0f 85 e4 fe ff ff    	jne    4036a0 <old+0xa0>
  4037bc:	44 89 d9             	mov    ecx,r11d
  4037bf:	eb d7                	jmp    403798 <old+0x198>
  4037c1:	48 8b 44 24 d0       	mov    rax,QWORD PTR [rsp-0x30]
  4037c6:	83 e0 0f             	and    eax,0xf
  4037c9:	48 85 c0             	test   rax,rax
  4037cc:	0f 84 6f 01 00 00    	je     403941 <old+0x341>
  4037d2:	43 0f b6 3c 2f       	movzx  edi,BYTE PTR [r15+r13*1]
  4037d7:	48 83 f8 01          	cmp    rax,0x1
  4037db:	74 7f                	je     40385c <old+0x25c>
  4037dd:	43 0f b6 54 2f 01    	movzx  edx,BYTE PTR [r15+r13*1+0x1]
  4037e3:	48 c1 e2 08          	shl    rdx,0x8
  4037e7:	48 09 d7             	or     rdi,rdx
  4037ea:	48 83 f8 02          	cmp    rax,0x2
  4037ee:	74 6c                	je     40385c <old+0x25c>
  4037f0:	43 0f b6 54 2f 02    	movzx  edx,BYTE PTR [r15+r13*1+0x2]
  4037f6:	48 c1 e2 10          	shl    rdx,0x10
  4037fa:	48 09 d7             	or     rdi,rdx
  4037fd:	48 83 f8 03          	cmp    rax,0x3
  403801:	74 59                	je     40385c <old+0x25c>
  403803:	43 0f b6 54 2f 03    	movzx  edx,BYTE PTR [r15+r13*1+0x3]
  403809:	48 c1 e2 18          	shl    rdx,0x18
  40380d:	48 09 d7             	or     rdi,rdx
  403810:	48 83 f8 04          	cmp    rax,0x4
  403814:	74 46                	je     40385c <old+0x25c>
  403816:	43 0f b6 54 2f 04    	movzx  edx,BYTE PTR [r15+r13*1+0x4]
  40381c:	48 c1 e2 20          	shl    rdx,0x20
  403820:	48 09 d7             	or     rdi,rdx
  403823:	48 83 f8 05          	cmp    rax,0x5
  403827:	74 33                	je     40385c <old+0x25c>
  403829:	43 0f b6 54 2f 05    	movzx  edx,BYTE PTR [r15+r13*1+0x5]
  40382f:	48 c1 e2 28          	shl    rdx,0x28
  403833:	48 09 d7             	or     rdi,rdx
  403836:	48 83 f8 06          	cmp    rax,0x6
  40383a:	74 20                	je     40385c <old+0x25c>
  40383c:	43 0f b6 54 2f 06    	movzx  edx,BYTE PTR [r15+r13*1+0x6]
  403842:	48 c1 e2 30          	shl    rdx,0x30
  403846:	48 09 d7             	or     rdi,rdx
  403849:	48 83 f8 07          	cmp    rax,0x7
  40384d:	76 0d                	jbe    40385c <old+0x25c>
  40384f:	43 0f b6 54 2f 07    	movzx  edx,BYTE PTR [r15+r13*1+0x7]
  403855:	48 c1 e2 38          	shl    rdx,0x38
  403859:	48 09 d7             	or     rdi,rdx
  40385c:	49 33 bd 00 92 40 00 	xor    rdi,QWORD PTR [r13+0x409200]
  403863:	49 8d 4d 08          	lea    rcx,[r13+0x8]
  403867:	45 31 c9             	xor    r9d,r9d
  40386a:	48 83 f8 08          	cmp    rax,0x8
  40386e:	76 7c                	jbe    4038ec <old+0x2ec>
  403870:	47 0f b6 4c 2f 08    	movzx  r9d,BYTE PTR [r15+r13*1+0x8]
  403876:	48 8d 50 f8          	lea    rdx,[rax-0x8]
  40387a:	48 83 f8 09          	cmp    rax,0x9
  40387e:	74 6c                	je     4038ec <old+0x2ec>
  403880:	43 0f b6 44 2f 09    	movzx  eax,BYTE PTR [r15+r13*1+0x9]
  403886:	48 c1 e0 08          	shl    rax,0x8
  40388a:	49 09 c1             	or     r9,rax
  40388d:	48 83 fa 02          	cmp    rdx,0x2
  403891:	74 59                	je     4038ec <old+0x2ec>
  403893:	43 0f b6 44 2f 0a    	movzx  eax,BYTE PTR [r15+r13*1+0xa]
  403899:	48 c1 e0 10          	shl    rax,0x10
  40389d:	49 09 c1             	or     r9,rax
  4038a0:	48 83 fa 03          	cmp    rdx,0x3
  4038a4:	74 46                	je     4038ec <old+0x2ec>
  4038a6:	43 0f b6 44 2f 0b    	movzx  eax,BYTE PTR [r15+r13*1+0xb]
  4038ac:	48 c1 e0 18          	shl    rax,0x18
  4038b0:	49 09 c1             	or     r9,rax
  4038b3:	48 83 fa 04          	cmp    rdx,0x4
  4038b7:	74 33                	je     4038ec <old+0x2ec>
  4038b9:	43 0f b6 44 2f 0c    	movzx  eax,BYTE PTR [r15+r13*1+0xc]
  4038bf:	48 c1 e0 20          	shl    rax,0x20
  4038c3:	49 09 c1             	or     r9,rax
  4038c6:	48 83 fa 05          	cmp    rdx,0x5
  4038ca:	74 20                	je     4038ec <old+0x2ec>
  4038cc:	43 0f b6 44 2f 0d    	movzx  eax,BYTE PTR [r15+r13*1+0xd]
  4038d2:	48 c1 e0 28          	shl    rax,0x28
  4038d6:	49 09 c1             	or     r9,rax
  4038d9:	48 83 fa 07          	cmp    rdx,0x7
  4038dd:	75 0d                	jne    4038ec <old+0x2ec>
  4038df:	43 0f b6 44 2f 0e    	movzx  eax,BYTE PTR [r15+r13*1+0xe]
  4038e5:	48 c1 e0 30          	shl    rax,0x30
  4038e9:	49 09 c1             	or     r9,rax
  4038ec:	4c 33 89 00 92 40 00 	xor    r9,QWORD PTR [rcx+0x409200]
  4038f3:	45 31 d2             	xor    r10d,r10d
  4038f6:	31 f6                	xor    esi,esi
  4038f8:	31 c9                	xor    ecx,ecx
  4038fa:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  403900:	4c 89 c8             	mov    rax,r9
  403903:	48 89 fa             	mov    rdx,rdi
  403906:	48 d3 e8             	shr    rax,cl
  403909:	48 d3 e2             	shl    rdx,cl
  40390c:	83 e0 01             	and    eax,0x1
  40390f:	48 f7 d8             	neg    rax
  403912:	48 21 c2             	and    rdx,rax
  403915:	48 31 d6             	xor    rsi,rdx
  403918:	8d 51 01             	lea    edx,[rcx+0x1]
  40391b:	85 c9                	test   ecx,ecx
  40391d:	0f 84 8d 00 00 00    	je     4039b0 <old+0x3b0>
  403923:	b9 41 00 00 00       	mov    ecx,0x41
  403928:	48 89 fb             	mov    rbx,rdi
  40392b:	29 d1                	sub    ecx,edx
  40392d:	48 d3 eb             	shr    rbx,cl
  403930:	48 21 d8             	and    rax,rbx
  403933:	49 31 c2             	xor    r10,rax
  403936:	83 fa 40             	cmp    edx,0x40
  403939:	75 75                	jne    4039b0 <old+0x3b0>
  40393b:	49 31 f4             	xor    r12,rsi
  40393e:	4d 31 d0             	xor    r8,r10
  403941:	48 2b 6c 24 d0       	sub    rbp,QWORD PTR [rsp-0x30]
  403946:	75 0b                	jne    403953 <old+0x353>
  403948:	48 8b 44 24 d8       	mov    rax,QWORD PTR [rsp-0x28]
  40394d:	49 31 c4             	xor    r12,rax
  403950:	49 31 c0             	xor    r8,rax
  403953:	48 8b 54 24 e0       	mov    rdx,QWORD PTR [rsp-0x20]
  403958:	4c 33 44 24 f0       	xor    r8,QWORD PTR [rsp-0x10]
  40395d:	b9 40 00 00 00       	mov    ecx,0x40
  403962:	31 f6                	xor    esi,esi
  403964:	48 33 54 24 e8       	xor    rdx,QWORD PTR [rsp-0x18]
  403969:	48 89 d0             	mov    rax,rdx
  40396c:	48 d1 ea             	shr    rdx,1
  40396f:	83 e0 01             	and    eax,0x1
  403972:	48 f7 d8             	neg    rax
  403975:	4c 21 c0             	and    rax,r8
  403978:	48 31 c6             	xor    rsi,rax
  40397b:	4b 8d 04 00          	lea    rax,[r8+r8*1]
  40397f:	49 c1 f8 3f          	sar    r8,0x3f
  403983:	41 83 e0 1b          	and    r8d,0x1b
  403987:	49 31 c0             	xor    r8,rax
  40398a:	83 e9 01             	sub    ecx,0x1
  40398d:	75 da                	jne    403969 <old+0x369>
  40398f:	4c 31 e6             	xor    rsi,r12
  403992:	48 89 74 24 e0       	mov    QWORD PTR [rsp-0x20],rsi
  403997:	48 85 ed             	test   rbp,rbp
  40399a:	74 29                	je     4039c5 <old+0x3c5>
  40399c:	4c 03 7c 24 d0       	add    r15,QWORD PTR [rsp-0x30]
  4039a1:	e9 b8 fc ff ff       	jmp    40365e <old+0x5e>
  4039a6:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  4039ad:	00 00 00 
  4039b0:	89 d1                	mov    ecx,edx
  4039b2:	e9 49 ff ff ff       	jmp    403900 <old+0x300>
  4039b7:	45 31 c0             	xor    r8d,r8d
  4039ba:	45 31 e4             	xor    r12d,r12d
  4039bd:	45 31 ed             	xor    r13d,r13d
  4039c0:	e9 04 fe ff ff       	jmp    4037c9 <old+0x1c9>
  4039c5:	48 8b 15 74 5c 00 00 	mov    rdx,QWORD PTR [rip+0x5c74]        # 409640 <oldx+0x440>
  4039cc:	31 c0                	xor    eax,eax
  4039ce:	bf 40 00 00 00       	mov    edi,0x40
  4039d3:	48 01 f2             	add    rdx,rsi
  4039d6:	48 89 d1             	mov    rcx,rdx
  4039d9:	49 89 d0             	mov    r8,rdx
  4039dc:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  4039e0:	4c 89 c6             	mov    rsi,r8
  4039e3:	49 d1 e8             	shr    r8,1
  4039e6:	83 e6 01             	and    esi,0x1
  4039e9:	48 f7 de             	neg    rsi
  4039ec:	48 21 ce             	and    rsi,rcx
  4039ef:	48 31 f0             	xor    rax,rsi
  4039f2:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
  4039f6:	48 c1 f9 3f          	sar    rcx,0x3f
  4039fa:	83 e1 1b             	and    ecx,0x1b
  4039fd:	48 31 f1             	xor    rcx,rsi
  403a00:	83 ef 01             	sub    edi,0x1
  403a03:	75 db                	jne    4039e0 <old+0x3e0>
  403a05:	48 8b 3d 14 5c 00 00 	mov    rdi,QWORD PTR [rip+0x5c14]        # 409620 <oldx+0x420>
  403a0c:	31 f6                	xor    esi,esi
  403a0e:	41 b8 40 00 00 00    	mov    r8d,0x40
  403a14:	48 31 d7             	xor    rdi,rdx
  403a17:	48 31 c7             	xor    rdi,rax
  403a1a:	48 33 05 f7 5b 00 00 	xor    rax,QWORD PTR [rip+0x5bf7]        # 409618 <oldx+0x418>
  403a21:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  403a28:	48 89 f9             	mov    rcx,rdi
  403a2b:	48 d1 ef             	shr    rdi,1
  403a2e:	83 e1 01             	and    ecx,0x1
  403a31:	48 f7 d9             	neg    rcx
  403a34:	48 21 c1             	and    rcx,rax
  403a37:	48 31 ce             	xor    rsi,rcx
  403a3a:	48 8d 0c 00          	lea    rcx,[rax+rax*1]
  403a3e:	48 c1 f8 3f          	sar    rax,0x3f
  403a42:	83 e0 1b             	and    eax,0x1b
  403a45:	48 31 c8             	xor    rax,rcx
  403a48:	41 83 e8 01          	sub    r8d,0x1
  403a4c:	75 da                	jne    403a28 <old+0x428>
  403a4e:	48 8b 05 d3 5b 00 00 	mov    rax,QWORD PTR [rip+0x5bd3]        # 409628 <oldx+0x428>
  403a55:	48 33 35 d4 5b 00 00 	xor    rsi,QWORD PTR [rip+0x5bd4]        # 409630 <oldx+0x430>
  403a5c:	48 89 f1             	mov    rcx,rsi
  403a5f:	be 40 00 00 00       	mov    esi,0x40
  403a64:	48 31 d0             	xor    rax,rdx
  403a67:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  403a6e:	00 00 
  403a70:	48 89 ca             	mov    rdx,rcx
  403a73:	48 d1 e9             	shr    rcx,1
  403a76:	83 e2 01             	and    edx,0x1
  403a79:	48 f7 da             	neg    rdx
  403a7c:	48 21 c2             	and    rdx,rax
  403a7f:	48 31 d5             	xor    rbp,rdx
  403a82:	48 8d 14 00          	lea    rdx,[rax+rax*1]
  403a86:	48 c1 f8 3f          	sar    rax,0x3f
  403a8a:	83 e0 1b             	and    eax,0x1b
  403a8d:	48 31 d0             	xor    rax,rdx
  403a90:	83 ee 01             	sub    esi,0x1
  403a93:	75 db                	jne    403a70 <old+0x470>
  403a95:	48 8b 05 9c 5b 00 00 	mov    rax,QWORD PTR [rip+0x5b9c]        # 409638 <oldx+0x438>
  403a9c:	5b                   	pop    rbx
  403a9d:	48 31 e8             	xor    rax,rbp
  403aa0:	5d                   	pop    rbp
  403aa1:	41 5c                	pop    r12
  403aa3:	41 5d                	pop    r13
  403aa5:	41 5e                	pop    r14
  403aa7:	41 5f                	pop    r15
  403aa9:	c3                   	ret    
  403aaa:	89 f0                	mov    eax,esi
  403aac:	0f a2                	cpuid  
  403aae:	85 c0                	test   eax,eax
  403ab0:	74 6a                	je     403b1c <old+0x51c>
  403ab2:	b8 01 00 00 00       	mov    eax,0x1
  403ab7:	0f a2                	cpuid  
  403ab9:	81 e1 02 02 00 18    	and    ecx,0x18000202
  403abf:	81 f9 02 02 00 18    	cmp    ecx,0x18000202
  403ac5:	75 55                	jne    403b1c <old+0x51c>
  403ac7:	89 f1                	mov    ecx,esi
  403ac9:	0f 01 d0             	xgetbv 
  403acc:	89 c7                	mov    edi,eax
  403ace:	83 e0 06             	and    eax,0x6
  403ad1:	83 f8 06             	cmp    eax,0x6
  403ad4:	75 46                	jne    403b1c <old+0x51c>
  403ad6:	89 f0                	mov    eax,esi
  403ad8:	0f a2                	cpuid  
  403ada:	83 f8 06             	cmp    eax,0x6
  403add:	76 3d                	jbe    403b1c <old+0x51c>
  403adf:	b8 07 00 00 00       	mov    eax,0x7
  403ae4:	89 f1                	mov    ecx,esi
  403ae6:	0f a2                	cpuid  
  403ae8:	f6 c3 20             	test   bl,0x20
  403aeb:	74 2f                	je     403b1c <old+0x51c>
  403aed:	81 e7 e6 00 00 00    	and    edi,0xe6
  403af3:	81 ff e6 00 00 00    	cmp    edi,0xe6
  403af9:	74 30                	je     403b2b <old+0x52b>
  403afb:	c7 05 83 55 00 00 02 	mov    DWORD PTR [rip+0x5583],0x2        # 409088 <cached.2>
  403b02:	00 00 00 
  403b05:	48 8b 74 24 d8       	mov    rsi,QWORD PTR [rsp-0x28]
  403b0a:	4c 89 ff             	mov    rdi,r15
  403b0d:	5b                   	pop    rbx
  403b0e:	5d                   	pop    rbp
  403b0f:	41 5c                	pop    r12
  403b11:	41 5d                	pop    r13
  403b13:	41 5e                	pop    r14
  403b15:	41 5f                	pop    r15
  403b17:	e9 c4 f6 ff ff       	jmp    4031e0 <chainhash_x86_avx2.constprop.0>
  403b1c:	c7 05 62 55 00 00 01 	mov    DWORD PTR [rip+0x5562],0x1        # 409088 <cached.2>
  403b23:	00 00 00 
  403b26:	e9 0a fb ff ff       	jmp    403635 <old+0x35>
  403b2b:	81 e3 00 00 01 00    	and    ebx,0x10000
  403b31:	74 c8                	je     403afb <old+0x4fb>
  403b33:	80 e5 04             	and    ch,0x4
  403b36:	74 c3                	je     403afb <old+0x4fb>
  403b38:	c7 05 46 55 00 00 03 	mov    DWORD PTR [rip+0x5546],0x3        # 409088 <cached.2>
  403b3f:	00 00 00 
  403b42:	48 8b 74 24 d8       	mov    rsi,QWORD PTR [rsp-0x28]
  403b47:	4c 89 ff             	mov    rdi,r15
  403b4a:	5b                   	pop    rbx
  403b4b:	5d                   	pop    rbp
  403b4c:	41 5c                	pop    r12
  403b4e:	41 5d                	pop    r13
  403b50:	41 5e                	pop    r14
  403b52:	41 5f                	pop    r15
  403b54:	e9 67 ee ff ff       	jmp    4029c0 <chainhash_x86_avx512.constprop.0>
  403b59:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000403b60 <chv3_bulk512.constprop.0>:
  403b60:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  403b64:	c4 e1 f9 6e ca       	vmovq  xmm1,rdx
  403b69:	c5 f9 6f 3d 0f 5c 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x5c0f]        # 409780 <v3+0x120>
  403b70:	00 
  403b71:	c5 d9 ef e4          	vpxor  xmm4,xmm4,xmm4
  403b75:	62 e2 7d 48 5a 35 e1 	vbroadcasti32x4 zmm22,XMMWORD PTR [rip+0x5ae1]        # 409660 <v3>
  403b7c:	5a 00 00 
  403b7f:	c4 e3 7d 38 c1 01    	vinserti128 ymm0,ymm0,xmm1,0x1
  403b85:	c5 c1 c6 35 32 5c 00 	vshufpd xmm6,xmm7,XMMWORD PTR [rip+0x5c32],0x2        # 4097c0 <v3+0x160>
  403b8c:	00 02 
  403b8e:	62 e2 7d 48 5a 2d d8 	vbroadcasti32x4 zmm21,XMMWORD PTR [rip+0x5ad8]        # 409670 <v3+0x10>
  403b95:	5a 00 00 
  403b98:	62 e2 7d 48 5a 25 de 	vbroadcasti32x4 zmm20,XMMWORD PTR [rip+0x5ade]        # 409680 <v3+0x20>
  403b9f:	5a 00 00 
  403ba2:	62 f3 4d 48 43 f6 00 	vshufi32x4 zmm6,zmm6,zmm6,0x0
  403ba9:	62 e2 7d 48 5a 1d dd 	vbroadcasti32x4 zmm19,XMMWORD PTR [rip+0x5add]        # 409690 <v3+0x30>
  403bb0:	5a 00 00 
  403bb3:	62 f3 dd 48 3a e0 01 	vinserti64x4 zmm4,zmm4,ymm0,0x1
  403bba:	62 e2 7d 48 5a 15 dc 	vbroadcasti32x4 zmm18,XMMWORD PTR [rip+0x5adc]        # 4096a0 <v3+0x40>
  403bc1:	5a 00 00 
  403bc4:	62 e2 7d 48 5a 0d e2 	vbroadcasti32x4 zmm17,XMMWORD PTR [rip+0x5ae2]        # 4096b0 <v3+0x50>
  403bcb:	5a 00 00 
  403bce:	62 e2 7d 48 5a 05 e8 	vbroadcasti32x4 zmm16,XMMWORD PTR [rip+0x5ae8]        # 4096c0 <v3+0x60>
  403bd5:	5a 00 00 
  403bd8:	62 72 7d 48 5a 3d ee 	vbroadcasti32x4 zmm15,XMMWORD PTR [rip+0x5aee]        # 4096d0 <v3+0x70>
  403bdf:	5a 00 00 
  403be2:	62 72 7d 48 5a 35 f4 	vbroadcasti32x4 zmm14,XMMWORD PTR [rip+0x5af4]        # 4096e0 <v3+0x80>
  403be9:	5a 00 00 
  403bec:	62 72 7d 48 5a 2d fa 	vbroadcasti32x4 zmm13,XMMWORD PTR [rip+0x5afa]        # 4096f0 <v3+0x90>
  403bf3:	5a 00 00 
  403bf6:	62 72 7d 48 5a 25 00 	vbroadcasti32x4 zmm12,XMMWORD PTR [rip+0x5b00]        # 409700 <v3+0xa0>
  403bfd:	5b 00 00 
  403c00:	62 72 7d 48 5a 1d 06 	vbroadcasti32x4 zmm11,XMMWORD PTR [rip+0x5b06]        # 409710 <v3+0xb0>
  403c07:	5b 00 00 
  403c0a:	62 72 7d 48 5a 15 0c 	vbroadcasti32x4 zmm10,XMMWORD PTR [rip+0x5b0c]        # 409720 <v3+0xc0>
  403c11:	5b 00 00 
  403c14:	62 72 7d 48 5a 0d 12 	vbroadcasti32x4 zmm9,XMMWORD PTR [rip+0x5b12]        # 409730 <v3+0xd0>
  403c1b:	5b 00 00 
  403c1e:	62 72 7d 48 5a 05 18 	vbroadcasti32x4 zmm8,XMMWORD PTR [rip+0x5b18]        # 409740 <v3+0xe0>
  403c25:	5b 00 00 
  403c28:	62 f2 7d 48 5a 3d 1e 	vbroadcasti32x4 zmm7,XMMWORD PTR [rip+0x5b1e]        # 409750 <v3+0xf0>
  403c2f:	5b 00 00 
  403c32:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  403c38:	62 f1 55 40 ef 4f 01 	vpxord zmm1,zmm21,ZMMWORD PTR [rdi+0x40]
  403c3f:	62 f1 4d 40 ef 07    	vpxord zmm0,zmm22,ZMMWORD PTR [rdi]
  403c45:	48 81 c7 00 04 00 00 	add    rdi,0x400
  403c4c:	62 f1 5d 40 ef 57 f2 	vpxord zmm2,zmm20,ZMMWORD PTR [rdi-0x380]
  403c53:	62 f1 6d 40 ef 5f f4 	vpxord zmm3,zmm18,ZMMWORD PTR [rdi-0x300]
  403c5a:	62 63 7d 48 44 d9 11 	vpclmulhqhqdq zmm27,zmm0,zmm1
  403c61:	62 f1 05 48 ef 6f f7 	vpxord zmm5,zmm15,ZMMWORD PTR [rdi-0x240]
  403c68:	62 61 15 48 ef 4f f9 	vpxord zmm25,zmm13,ZMMWORD PTR [rdi-0x1c0]
  403c6f:	62 f3 7d 48 44 c1 00 	vpclmullqlqdq zmm0,zmm0,zmm1
  403c76:	62 f1 65 40 ef 4f f3 	vpxord zmm1,zmm19,ZMMWORD PTR [rdi-0x340]
  403c7d:	62 63 6d 48 44 d1 11 	vpclmulhqhqdq zmm26,zmm2,zmm1
  403c84:	62 f3 6d 48 44 d1 00 	vpclmullqlqdq zmm2,zmm2,zmm1
  403c8b:	62 f1 75 40 ef 4f f5 	vpxord zmm1,zmm17,ZMMWORD PTR [rdi-0x2c0]
  403c92:	62 63 65 48 44 c1 11 	vpclmulhqhqdq zmm24,zmm3,zmm1
  403c99:	62 f3 65 48 44 d9 00 	vpclmullqlqdq zmm3,zmm3,zmm1
  403ca0:	62 91 7d 48 ef c3    	vpxord zmm0,zmm0,zmm27
  403ca6:	62 f1 7d 40 ef 4f f6 	vpxord zmm1,zmm16,ZMMWORD PTR [rdi-0x280]
  403cad:	62 e3 75 48 44 fd 11 	vpclmulhqhqdq zmm23,zmm1,zmm5
  403cb4:	62 f3 75 48 44 cd 00 	vpclmullqlqdq zmm1,zmm1,zmm5
  403cbb:	62 f1 0d 48 ef 6f f8 	vpxord zmm5,zmm14,ZMMWORD PTR [rdi-0x200]
  403cc2:	62 91 6d 48 ef d2    	vpxord zmm2,zmm2,zmm26
  403cc8:	62 03 55 48 44 e1 11 	vpclmulhqhqdq zmm28,zmm5,zmm25
  403ccf:	62 93 55 48 44 e9 00 	vpclmullqlqdq zmm5,zmm5,zmm25
  403cd6:	62 91 65 48 ef d8    	vpxord zmm3,zmm3,zmm24
  403cdc:	62 61 45 48 ef 47 ff 	vpxord zmm24,zmm7,ZMMWORD PTR [rdi-0x40]
  403ce3:	62 61 25 48 ef 4f fb 	vpxord zmm25,zmm11,ZMMWORD PTR [rdi-0x140]
  403cea:	62 b1 75 48 ef cf    	vpxord zmm1,zmm1,zmm23
  403cf0:	62 93 d5 48 25 c4 96 	vpternlogq zmm0,zmm5,zmm28,0x96
  403cf7:	62 f1 1d 48 ef 6f fa 	vpxord zmm5,zmm12,ZMMWORD PTR [rdi-0x180]
  403cfe:	62 03 55 48 44 d9 11 	vpclmulhqhqdq zmm27,zmm5,zmm25
  403d05:	62 93 55 48 44 e9 00 	vpclmullqlqdq zmm5,zmm5,zmm25
  403d0c:	62 61 35 48 ef 4f fd 	vpxord zmm25,zmm9,ZMMWORD PTR [rdi-0xc0]
  403d13:	62 93 d5 48 25 d3 96 	vpternlogq zmm2,zmm5,zmm27,0x96
  403d1a:	62 f1 2d 48 ef 6f fc 	vpxord zmm5,zmm10,ZMMWORD PTR [rdi-0x100]
  403d21:	62 03 55 48 44 d1 11 	vpclmulhqhqdq zmm26,zmm5,zmm25
  403d28:	62 93 55 48 44 e9 00 	vpclmullqlqdq zmm5,zmm5,zmm25
  403d2f:	62 93 d5 48 25 da 96 	vpternlogq zmm3,zmm5,zmm26,0x96
  403d36:	62 f1 3d 48 ef 6f fe 	vpxord zmm5,zmm8,ZMMWORD PTR [rdi-0x80]
  403d3d:	62 f3 ed 48 25 c3 96 	vpternlogq zmm0,zmm2,zmm3,0x96
  403d44:	62 03 55 48 44 c8 11 	vpclmulhqhqdq zmm25,zmm5,zmm24
  403d4b:	62 93 55 48 44 e8 00 	vpclmullqlqdq zmm5,zmm5,zmm24
  403d52:	62 f3 5d 48 44 d6 11 	vpclmulhqhqdq zmm2,zmm4,zmm6
  403d59:	62 f3 5d 48 44 e6 00 	vpclmullqlqdq zmm4,zmm4,zmm6
  403d60:	62 93 d5 48 25 c9 96 	vpternlogq zmm1,zmm5,zmm25,0x96
  403d67:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
  403d6d:	62 f3 ed 48 25 e0 96 	vpternlogq zmm4,zmm2,zmm0,0x96
  403d74:	48 83 ee 01          	sub    rsi,0x1
  403d78:	0f 85 ba fe ff ff    	jne    403c38 <chv3_bulk512.constprop.0+0xd8>
  403d7e:	c5 fa 7e 3d da 59 00 	vmovq  xmm7,QWORD PTR [rip+0x59da]        # 409760 <v3+0x100>
  403d85:	00 
  403d86:	c4 e3 c1 22 05 18 5a 	vpinsrq xmm0,xmm7,QWORD PTR [rip+0x5a18],0x1        # 4097a8 <v3+0x148>
  403d8d:	00 00 01 
  403d90:	c5 fa 7e 3d d0 59 00 	vmovq  xmm7,QWORD PTR [rip+0x59d0]        # 409768 <v3+0x108>
  403d97:	00 
  403d98:	c4 e3 c1 22 0d 0e 5a 	vpinsrq xmm1,xmm7,QWORD PTR [rip+0x5a0e],0x1        # 4097b0 <v3+0x150>
  403d9f:	00 00 01 
  403da2:	c5 fa 7e 3d c6 59 00 	vmovq  xmm7,QWORD PTR [rip+0x59c6]        # 409770 <v3+0x110>
  403da9:	00 
  403daa:	c4 e3 c1 22 15 04 5a 	vpinsrq xmm2,xmm7,QWORD PTR [rip+0x5a04],0x1        # 4097b8 <v3+0x158>
  403db1:	00 00 01 
  403db4:	c4 e3 75 38 c8 01    	vinserti128 ymm1,ymm1,xmm0,0x1
  403dba:	c5 fa 7e 3d b6 59 00 	vmovq  xmm7,QWORD PTR [rip+0x59b6]        # 409778 <v3+0x118>
  403dc1:	00 
  403dc2:	c4 e3 c1 22 05 f4 59 	vpinsrq xmm0,xmm7,QWORD PTR [rip+0x59f4],0x1        # 4097c0 <v3+0x160>
  403dc9:	00 00 01 
  403dcc:	c4 e3 7d 38 c2 01    	vinserti128 ymm0,ymm0,xmm2,0x1
  403dd2:	62 f3 fd 48 3a c1 01 	vinserti64x4 zmm0,zmm0,ymm1,0x1
  403dd9:	62 f3 5d 48 44 c8 11 	vpclmulhqhqdq zmm1,zmm4,zmm0
  403de0:	62 f3 5d 48 44 e0 00 	vpclmullqlqdq zmm4,zmm4,zmm0
  403de7:	62 f1 5d 48 ef e1    	vpxord zmm4,zmm4,zmm1
  403ded:	62 f3 fd 48 3b e1 01 	vextracti64x4 ymm1,zmm4,0x1
  403df4:	c5 f5 ef cc          	vpxor  ymm1,ymm1,ymm4
  403df8:	c4 e3 7d 39 c8 01    	vextracti128 xmm0,ymm1,0x1
  403dfe:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  403e02:	c4 e3 f9 16 c1 01    	vpextrq rcx,xmm0,0x1
  403e08:	48 89 ca             	mov    rdx,rcx
  403e0b:	48 89 c8             	mov    rax,rcx
  403e0e:	48 8d 34 09          	lea    rsi,[rcx+rcx*1]
  403e12:	48 c1 e8 3d          	shr    rax,0x3d
  403e16:	48 c1 ea 3f          	shr    rdx,0x3f
  403e1a:	48 31 c2             	xor    rdx,rax
  403e1d:	48 89 c8             	mov    rax,rcx
  403e20:	48 c1 e8 3c          	shr    rax,0x3c
  403e24:	48 31 c2             	xor    rdx,rax
  403e27:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  403e2c:	48 31 c8             	xor    rax,rcx
  403e2f:	48 31 f0             	xor    rax,rsi
  403e32:	48 8d 34 cd 00 00 00 	lea    rsi,[rcx*8+0x0]
  403e39:	00 
  403e3a:	48 c1 e1 04          	shl    rcx,0x4
  403e3e:	48 31 f0             	xor    rax,rsi
  403e41:	48 31 c8             	xor    rax,rcx
  403e44:	48 8d 0c 12          	lea    rcx,[rdx+rdx*1]
  403e48:	48 31 d0             	xor    rax,rdx
  403e4b:	48 31 c8             	xor    rax,rcx
  403e4e:	48 8d 0c d5 00 00 00 	lea    rcx,[rdx*8+0x0]
  403e55:	00 
  403e56:	48 c1 e2 04          	shl    rdx,0x4
  403e5a:	48 31 c8             	xor    rax,rcx
  403e5d:	48 31 d0             	xor    rax,rdx
  403e60:	c5 f8 77             	vzeroupper 
  403e63:	c3                   	ret    
  403e64:	66 66 2e 0f 1f 84 00 	data16 nop WORD PTR cs:[rax+rax*1+0x0]
  403e6b:	00 00 00 00 
  403e6f:	90                   	nop

0000000000403e70 <v3y>:
  403e70:	41 57                	push   r15
  403e72:	49 89 f9             	mov    r9,rdi
  403e75:	41 56                	push   r14
  403e77:	41 55                	push   r13
  403e79:	41 54                	push   r12
  403e7b:	55                   	push   rbp
  403e7c:	48 89 f5             	mov    rbp,rsi
  403e7f:	53                   	push   rbx
  403e80:	81 e5 ff 03 00 00    	and    ebp,0x3ff
  403e86:	48 83 ec 68          	sub    rsp,0x68
  403e8a:	48 89 74 24 10       	mov    QWORD PTR [rsp+0x10],rsi
  403e8f:	8b 05 b7 51 00 00    	mov    eax,DWORD PTR [rip+0x51b7]        # 40904c <cache.5>
  403e95:	85 c0                	test   eax,eax
  403e97:	0f 88 65 06 00 00    	js     404502 <v3y+0x692>
  403e9d:	83 f8 04             	cmp    eax,0x4
  403ea0:	0f 84 74 06 00 00    	je     40451a <v3y+0x6aa>
  403ea6:	83 f8 01             	cmp    eax,0x1
  403ea9:	0f 8e 6b 06 00 00    	jle    40451a <v3y+0x6aa>
  403eaf:	48 81 7c 24 10 ff 03 	cmp    QWORD PTR [rsp+0x10],0x3ff
  403eb6:	00 00 
  403eb8:	0f 87 c3 06 00 00    	ja     404581 <v3y+0x711>
  403ebe:	49 8d 04 29          	lea    rax,[r9+rbp*1]
  403ec2:	66 0f ef c0          	pxor   xmm0,xmm0
  403ec6:	4c 8d 7c 24 60       	lea    r15,[rsp+0x60]
  403ecb:	49 89 ee             	mov    r14,rbp
  403ece:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
  403ed3:	41 bd 60 96 40 00    	mov    r13d,0x409660
  403ed9:	0f 29 44 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm0
  403ede:	0f 29 44 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm0
  403ee3:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
  403ee8:	0f 29 44 24 50       	movaps XMMWORD PTR [rsp+0x50],xmm0
  403eed:	0f 1f 00             	nop    DWORD PTR [rax]
  403ef0:	48 8b 4c 24 18       	mov    rcx,QWORD PTR [rsp+0x18]
  403ef5:	49 89 e8             	mov    r8,rbp
  403ef8:	4c 8d 4c 24 20       	lea    r9,[rsp+0x20]
  403efd:	4d 89 f2             	mov    r10,r14
  403f00:	4d 29 f0             	sub    r8,r14
  403f03:	4d 8d 5e f8          	lea    r11,[r14-0x8]
  403f07:	4d 8d 66 b8          	lea    r12,[r14-0x48]
  403f0b:	4c 29 f1             	sub    rcx,r14
  403f0e:	49 8d 5e c0          	lea    rbx,[r14-0x40]
  403f12:	4c 39 c5             	cmp    rbp,r8
  403f15:	0f 86 1e 01 00 00    	jbe    404039 <v3y+0x1c9>
  403f1b:	49 8d 40 40          	lea    rax,[r8+0x40]
  403f1f:	48 39 c5             	cmp    rbp,rax
  403f22:	0f 86 20 06 00 00    	jbe    404548 <v3y+0x6d8>
  403f28:	48 83 fb 07          	cmp    rbx,0x7
  403f2c:	0f 87 46 06 00 00    	ja     404578 <v3y+0x708>
  403f32:	0f b6 41 40          	movzx  eax,BYTE PTR [rcx+0x40]
  403f36:	48 83 fb 01          	cmp    rbx,0x1
  403f3a:	76 60                	jbe    403f9c <v3y+0x12c>
  403f3c:	0f b6 51 41          	movzx  edx,BYTE PTR [rcx+0x41]
  403f40:	48 c1 e2 08          	shl    rdx,0x8
  403f44:	48 09 d0             	or     rax,rdx
  403f47:	48 83 fb 02          	cmp    rbx,0x2
  403f4b:	74 4f                	je     403f9c <v3y+0x12c>
  403f4d:	0f b6 51 42          	movzx  edx,BYTE PTR [rcx+0x42]
  403f51:	48 c1 e2 10          	shl    rdx,0x10
  403f55:	48 09 d0             	or     rax,rdx
  403f58:	48 83 fb 03          	cmp    rbx,0x3
  403f5c:	74 3e                	je     403f9c <v3y+0x12c>
  403f5e:	0f b6 51 43          	movzx  edx,BYTE PTR [rcx+0x43]
  403f62:	48 c1 e2 18          	shl    rdx,0x18
  403f66:	48 09 d0             	or     rax,rdx
  403f69:	48 83 fb 04          	cmp    rbx,0x4
  403f6d:	74 2d                	je     403f9c <v3y+0x12c>
  403f6f:	0f b6 51 44          	movzx  edx,BYTE PTR [rcx+0x44]
  403f73:	48 c1 e2 20          	shl    rdx,0x20
  403f77:	48 09 d0             	or     rax,rdx
  403f7a:	48 83 fb 05          	cmp    rbx,0x5
  403f7e:	74 1c                	je     403f9c <v3y+0x12c>
  403f80:	0f b6 51 45          	movzx  edx,BYTE PTR [rcx+0x45]
  403f84:	48 c1 e2 28          	shl    rdx,0x28
  403f88:	48 09 d0             	or     rax,rdx
  403f8b:	48 83 fb 07          	cmp    rbx,0x7
  403f8f:	75 0b                	jne    403f9c <v3y+0x12c>
  403f91:	0f b6 51 46          	movzx  edx,BYTE PTR [rcx+0x46]
  403f95:	48 c1 e2 30          	shl    rdx,0x30
  403f99:	48 09 d0             	or     rax,rdx
  403f9c:	49 33 45 10          	xor    rax,QWORD PTR [r13+0x10]
  403fa0:	48 89 c6             	mov    rsi,rax
  403fa3:	49 83 fa 07          	cmp    r10,0x7
  403fa7:	0f 87 ae 05 00 00    	ja     40455b <v3y+0x6eb>
  403fad:	0f b6 01             	movzx  eax,BYTE PTR [rcx]
  403fb0:	49 83 fa 01          	cmp    r10,0x1
  403fb4:	76 60                	jbe    404016 <v3y+0x1a6>
  403fb6:	0f b6 51 01          	movzx  edx,BYTE PTR [rcx+0x1]
  403fba:	48 c1 e2 08          	shl    rdx,0x8
  403fbe:	48 09 d0             	or     rax,rdx
  403fc1:	49 83 fa 02          	cmp    r10,0x2
  403fc5:	74 4f                	je     404016 <v3y+0x1a6>
  403fc7:	0f b6 51 02          	movzx  edx,BYTE PTR [rcx+0x2]
  403fcb:	48 c1 e2 10          	shl    rdx,0x10
  403fcf:	48 09 d0             	or     rax,rdx
  403fd2:	49 83 fa 03          	cmp    r10,0x3
  403fd6:	74 3e                	je     404016 <v3y+0x1a6>
  403fd8:	0f b6 51 03          	movzx  edx,BYTE PTR [rcx+0x3]
  403fdc:	48 c1 e2 18          	shl    rdx,0x18
  403fe0:	48 09 d0             	or     rax,rdx
  403fe3:	49 83 fa 04          	cmp    r10,0x4
  403fe7:	74 2d                	je     404016 <v3y+0x1a6>
  403fe9:	0f b6 51 04          	movzx  edx,BYTE PTR [rcx+0x4]
  403fed:	48 c1 e2 20          	shl    rdx,0x20
  403ff1:	48 09 d0             	or     rax,rdx
  403ff4:	49 83 fa 05          	cmp    r10,0x5
  403ff8:	74 1c                	je     404016 <v3y+0x1a6>
  403ffa:	0f b6 51 05          	movzx  edx,BYTE PTR [rcx+0x5]
  403ffe:	48 c1 e2 28          	shl    rdx,0x28
  404002:	48 09 d0             	or     rax,rdx
  404005:	49 83 fa 07          	cmp    r10,0x7
  404009:	75 0b                	jne    404016 <v3y+0x1a6>
  40400b:	0f b6 51 06          	movzx  edx,BYTE PTR [rcx+0x6]
  40400f:	48 c1 e2 30          	shl    rdx,0x30
  404013:	48 09 d0             	or     rax,rdx
  404016:	49 33 45 00          	xor    rax,QWORD PTR [r13+0x0]
  40401a:	48 89 c7             	mov    rdi,rax
  40401d:	e8 9e db ff ff       	call   401bc0 <chv3_hwprod>
  404022:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  404026:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  40402b:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  404030:	66 41 0f ef 01       	pxor   xmm0,XMMWORD PTR [r9]
  404035:	41 0f 29 01          	movaps XMMWORD PTR [r9],xmm0
  404039:	49 8d 40 08          	lea    rax,[r8+0x8]
  40403d:	48 39 c5             	cmp    rbp,rax
  404040:	0f 86 1d 01 00 00    	jbe    404163 <v3y+0x2f3>
  404046:	49 8d 50 48          	lea    rdx,[r8+0x48]
  40404a:	31 c0                	xor    eax,eax
  40404c:	48 39 d5             	cmp    rbp,rdx
  40404f:	76 77                	jbe    4040c8 <v3y+0x258>
  404051:	49 83 fc 07          	cmp    r12,0x7
  404055:	0f 87 0d 05 00 00    	ja     404568 <v3y+0x6f8>
  40405b:	0f b6 41 48          	movzx  eax,BYTE PTR [rcx+0x48]
  40405f:	49 83 fc 01          	cmp    r12,0x1
  404063:	76 63                	jbe    4040c8 <v3y+0x258>
  404065:	0f b6 51 49          	movzx  edx,BYTE PTR [rcx+0x49]
  404069:	48 c1 e2 08          	shl    rdx,0x8
  40406d:	48 09 d0             	or     rax,rdx
  404070:	49 83 fc 02          	cmp    r12,0x2
  404074:	74 52                	je     4040c8 <v3y+0x258>
  404076:	0f b6 51 4a          	movzx  edx,BYTE PTR [rcx+0x4a]
  40407a:	48 c1 e2 10          	shl    rdx,0x10
  40407e:	48 09 d0             	or     rax,rdx
  404081:	49 83 fc 03          	cmp    r12,0x3
  404085:	74 41                	je     4040c8 <v3y+0x258>
  404087:	0f b6 51 4b          	movzx  edx,BYTE PTR [rcx+0x4b]
  40408b:	48 c1 e2 18          	shl    rdx,0x18
  40408f:	48 09 d0             	or     rax,rdx
  404092:	49 83 fc 04          	cmp    r12,0x4
  404096:	74 30                	je     4040c8 <v3y+0x258>
  404098:	0f b6 51 4c          	movzx  edx,BYTE PTR [rcx+0x4c]
  40409c:	48 c1 e2 20          	shl    rdx,0x20
  4040a0:	48 09 d0             	or     rax,rdx
  4040a3:	49 83 fc 05          	cmp    r12,0x5
  4040a7:	74 1f                	je     4040c8 <v3y+0x258>
  4040a9:	0f b6 51 4d          	movzx  edx,BYTE PTR [rcx+0x4d]
  4040ad:	48 c1 e2 28          	shl    rdx,0x28
  4040b1:	48 09 d0             	or     rax,rdx
  4040b4:	49 83 fc 07          	cmp    r12,0x7
  4040b8:	75 0e                	jne    4040c8 <v3y+0x258>
  4040ba:	0f b6 51 4e          	movzx  edx,BYTE PTR [rcx+0x4e]
  4040be:	48 c1 e2 30          	shl    rdx,0x30
  4040c2:	48 09 d0             	or     rax,rdx
  4040c5:	0f 1f 00             	nop    DWORD PTR [rax]
  4040c8:	49 33 45 18          	xor    rax,QWORD PTR [r13+0x18]
  4040cc:	48 89 c6             	mov    rsi,rax
  4040cf:	49 83 fb 07          	cmp    r11,0x7
  4040d3:	0f 87 5f 04 00 00    	ja     404538 <v3y+0x6c8>
  4040d9:	0f b6 79 08          	movzx  edi,BYTE PTR [rcx+0x8]
  4040dd:	49 83 fb 01          	cmp    r11,0x1
  4040e1:	76 60                	jbe    404143 <v3y+0x2d3>
  4040e3:	0f b6 41 09          	movzx  eax,BYTE PTR [rcx+0x9]
  4040e7:	48 c1 e0 08          	shl    rax,0x8
  4040eb:	48 09 c7             	or     rdi,rax
  4040ee:	49 83 fb 02          	cmp    r11,0x2
  4040f2:	74 4f                	je     404143 <v3y+0x2d3>
  4040f4:	0f b6 41 0a          	movzx  eax,BYTE PTR [rcx+0xa]
  4040f8:	48 c1 e0 10          	shl    rax,0x10
  4040fc:	48 09 c7             	or     rdi,rax
  4040ff:	49 83 fb 03          	cmp    r11,0x3
  404103:	74 3e                	je     404143 <v3y+0x2d3>
  404105:	0f b6 41 0b          	movzx  eax,BYTE PTR [rcx+0xb]
  404109:	48 c1 e0 18          	shl    rax,0x18
  40410d:	48 09 c7             	or     rdi,rax
  404110:	49 83 fb 04          	cmp    r11,0x4
  404114:	74 2d                	je     404143 <v3y+0x2d3>
  404116:	0f b6 41 0c          	movzx  eax,BYTE PTR [rcx+0xc]
  40411a:	48 c1 e0 20          	shl    rax,0x20
  40411e:	48 09 c7             	or     rdi,rax
  404121:	49 83 fb 05          	cmp    r11,0x5
  404125:	74 1c                	je     404143 <v3y+0x2d3>
  404127:	0f b6 41 0d          	movzx  eax,BYTE PTR [rcx+0xd]
  40412b:	48 c1 e0 28          	shl    rax,0x28
  40412f:	48 09 c7             	or     rdi,rax
  404132:	49 83 fb 07          	cmp    r11,0x7
  404136:	75 0b                	jne    404143 <v3y+0x2d3>
  404138:	0f b6 41 0e          	movzx  eax,BYTE PTR [rcx+0xe]
  40413c:	48 c1 e0 30          	shl    rax,0x30
  404140:	48 09 c7             	or     rdi,rax
  404143:	49 33 7d 08          	xor    rdi,QWORD PTR [r13+0x8]
  404147:	e8 74 da ff ff       	call   401bc0 <chv3_hwprod>
  40414c:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  404150:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  404155:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  40415a:	66 41 0f ef 01       	pxor   xmm0,XMMWORD PTR [r9]
  40415f:	41 0f 29 01          	movaps XMMWORD PTR [r9],xmm0
  404163:	49 83 c1 10          	add    r9,0x10
  404167:	49 83 c0 10          	add    r8,0x10
  40416b:	49 83 eb 10          	sub    r11,0x10
  40416f:	49 83 ec 10          	sub    r12,0x10
  404173:	48 83 c1 10          	add    rcx,0x10
  404177:	49 83 ea 10          	sub    r10,0x10
  40417b:	48 83 eb 10          	sub    rbx,0x10
  40417f:	4d 39 cf             	cmp    r15,r9
  404182:	0f 85 8a fd ff ff    	jne    403f12 <v3y+0xa2>
  404188:	49 83 c5 20          	add    r13,0x20
  40418c:	49 83 c6 80          	add    r14,0xffffffffffffff80
  404190:	49 81 fd 60 97 40 00 	cmp    r13,0x409760
  404197:	0f 85 53 fd ff ff    	jne    403ef0 <v3y+0x80>
  40419d:	48 8d 4d ff          	lea    rcx,[rbp-0x1]
  4041a1:	48 c1 e9 04          	shr    rcx,0x4
  4041a5:	83 c1 01             	add    ecx,0x1
  4041a8:	48 83 fd 30          	cmp    rbp,0x30
  4041ac:	77 12                	ja     4041c0 <v3y+0x350>
  4041ae:	48 85 ed             	test   rbp,rbp
  4041b1:	74 0d                	je     4041c0 <v3y+0x350>
  4041b3:	4c 8b 44 24 10       	mov    r8,QWORD PTR [rsp+0x10]
  4041b8:	85 c9                	test   ecx,ecx
  4041ba:	0f 84 e1 03 00 00    	je     4045a1 <v3y+0x731>
  4041c0:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  4041c5:	48 8b 35 9c 55 00 00 	mov    rsi,QWORD PTR [rip+0x559c]        # 409768 <v3+0x108>
  4041cc:	e8 ef d9 ff ff       	call   401bc0 <chv3_hwprod>
  4041d1:	4c 8b 4c 24 28       	mov    r9,QWORD PTR [rsp+0x28]
  4041d6:	48 89 d7             	mov    rdi,rdx
  4041d9:	49 89 d2             	mov    r10,rdx
  4041dc:	48 c1 ea 3d          	shr    rdx,0x3d
  4041e0:	48 c1 ef 3f          	shr    rdi,0x3f
  4041e4:	4d 89 c8             	mov    r8,r9
  4041e7:	4c 31 d0             	xor    rax,r10
  4041ea:	48 31 d7             	xor    rdi,rdx
  4041ed:	4c 89 d2             	mov    rdx,r10
  4041f0:	49 c1 e8 3f          	shr    r8,0x3f
  4041f4:	48 c1 ea 3c          	shr    rdx,0x3c
  4041f8:	48 31 d7             	xor    rdi,rdx
  4041fb:	4c 89 ca             	mov    rdx,r9
  4041fe:	48 c1 ea 3d          	shr    rdx,0x3d
  404202:	4c 31 c2             	xor    rdx,r8
  404205:	4d 89 c8             	mov    r8,r9
  404208:	49 c1 e8 3c          	shr    r8,0x3c
  40420c:	4c 31 c2             	xor    rdx,r8
  40420f:	4c 8b 44 24 20       	mov    r8,QWORD PTR [rsp+0x20]
  404214:	49 31 c0             	xor    r8,rax
  404217:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  40421b:	4d 31 c8             	xor    r8,r9
  40421e:	49 31 c0             	xor    r8,rax
  404221:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  404228:	00 
  404229:	49 c1 e2 04          	shl    r10,0x4
  40422d:	49 31 c0             	xor    r8,rax
  404230:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  404234:	4d 31 d0             	xor    r8,r10
  404237:	49 31 c0             	xor    r8,rax
  40423a:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  404241:	00 
  404242:	49 c1 e1 04          	shl    r9,0x4
  404246:	49 31 c0             	xor    r8,rax
  404249:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  40424d:	4d 31 c8             	xor    r8,r9
  404250:	49 31 f8             	xor    r8,rdi
  404253:	49 31 d0             	xor    r8,rdx
  404256:	49 31 c0             	xor    r8,rax
  404259:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  404260:	00 
  404261:	48 c1 e7 04          	shl    rdi,0x4
  404265:	49 31 c0             	xor    r8,rax
  404268:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  40426c:	49 31 f8             	xor    r8,rdi
  40426f:	49 31 c0             	xor    r8,rax
  404272:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  404279:	00 
  40427a:	48 c1 e2 04          	shl    rdx,0x4
  40427e:	49 31 c0             	xor    r8,rax
  404281:	49 31 d0             	xor    r8,rdx
  404284:	48 83 fd 30          	cmp    rbp,0x30
  404288:	77 12                	ja     40429c <v3y+0x42c>
  40428a:	48 85 ed             	test   rbp,rbp
  40428d:	0f 84 0e 03 00 00    	je     4045a1 <v3y+0x731>
  404293:	83 f9 01             	cmp    ecx,0x1
  404296:	0f 86 05 03 00 00    	jbe    4045a1 <v3y+0x731>
  40429c:	4c 89 c7             	mov    rdi,r8
  40429f:	e8 1c d9 ff ff       	call   401bc0 <chv3_hwprod>
  4042a4:	4c 8b 4c 24 38       	mov    r9,QWORD PTR [rsp+0x38]
  4042a9:	48 89 d7             	mov    rdi,rdx
  4042ac:	49 89 d2             	mov    r10,rdx
  4042af:	48 c1 ea 3d          	shr    rdx,0x3d
  4042b3:	48 c1 ef 3f          	shr    rdi,0x3f
  4042b7:	4d 89 c8             	mov    r8,r9
  4042ba:	4c 31 d0             	xor    rax,r10
  4042bd:	48 31 d7             	xor    rdi,rdx
  4042c0:	4c 89 d2             	mov    rdx,r10
  4042c3:	49 c1 e8 3f          	shr    r8,0x3f
  4042c7:	48 c1 ea 3c          	shr    rdx,0x3c
  4042cb:	48 31 d7             	xor    rdi,rdx
  4042ce:	4c 89 ca             	mov    rdx,r9
  4042d1:	48 c1 ea 3d          	shr    rdx,0x3d
  4042d5:	4c 31 c2             	xor    rdx,r8
  4042d8:	4d 89 c8             	mov    r8,r9
  4042db:	49 c1 e8 3c          	shr    r8,0x3c
  4042df:	4c 31 c2             	xor    rdx,r8
  4042e2:	4c 8b 44 24 30       	mov    r8,QWORD PTR [rsp+0x30]
  4042e7:	49 31 c0             	xor    r8,rax
  4042ea:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  4042ee:	4d 31 c8             	xor    r8,r9
  4042f1:	49 31 c0             	xor    r8,rax
  4042f4:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  4042fb:	00 
  4042fc:	49 c1 e2 04          	shl    r10,0x4
  404300:	49 31 c0             	xor    r8,rax
  404303:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  404307:	4d 31 d0             	xor    r8,r10
  40430a:	49 31 c0             	xor    r8,rax
  40430d:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  404314:	00 
  404315:	49 c1 e1 04          	shl    r9,0x4
  404319:	49 31 c0             	xor    r8,rax
  40431c:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  404320:	4d 31 c8             	xor    r8,r9
  404323:	49 31 f8             	xor    r8,rdi
  404326:	49 31 d0             	xor    r8,rdx
  404329:	49 31 c0             	xor    r8,rax
  40432c:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  404333:	00 
  404334:	48 c1 e7 04          	shl    rdi,0x4
  404338:	49 31 c0             	xor    r8,rax
  40433b:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  40433f:	49 31 f8             	xor    r8,rdi
  404342:	49 31 c0             	xor    r8,rax
  404345:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  40434c:	00 
  40434d:	48 c1 e2 04          	shl    rdx,0x4
  404351:	49 31 c0             	xor    r8,rax
  404354:	49 31 d0             	xor    r8,rdx
  404357:	48 83 fd 30          	cmp    rbp,0x30
  40435b:	77 12                	ja     40436f <v3y+0x4ff>
  40435d:	48 85 ed             	test   rbp,rbp
  404360:	0f 84 3b 02 00 00    	je     4045a1 <v3y+0x731>
  404366:	83 f9 02             	cmp    ecx,0x2
  404369:	0f 86 32 02 00 00    	jbe    4045a1 <v3y+0x731>
  40436f:	4c 89 c7             	mov    rdi,r8
  404372:	e8 49 d8 ff ff       	call   401bc0 <chv3_hwprod>
  404377:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  40437c:	48 89 d7             	mov    rdi,rdx
  40437f:	49 89 d2             	mov    r10,rdx
  404382:	48 c1 ea 3f          	shr    rdx,0x3f
  404386:	48 c1 ef 3d          	shr    rdi,0x3d
  40438a:	4d 89 c8             	mov    r8,r9
  40438d:	4c 31 d0             	xor    rax,r10
  404390:	48 31 d7             	xor    rdi,rdx
  404393:	4c 89 d2             	mov    rdx,r10
  404396:	49 c1 e8 3f          	shr    r8,0x3f
  40439a:	48 c1 ea 3c          	shr    rdx,0x3c
  40439e:	48 31 d7             	xor    rdi,rdx
  4043a1:	4c 89 ca             	mov    rdx,r9
  4043a4:	48 c1 ea 3d          	shr    rdx,0x3d
  4043a8:	4c 31 c2             	xor    rdx,r8
  4043ab:	4d 89 c8             	mov    r8,r9
  4043ae:	49 c1 e8 3c          	shr    r8,0x3c
  4043b2:	4c 31 c2             	xor    rdx,r8
  4043b5:	4c 8b 44 24 40       	mov    r8,QWORD PTR [rsp+0x40]
  4043ba:	49 31 c0             	xor    r8,rax
  4043bd:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  4043c1:	4d 31 c8             	xor    r8,r9
  4043c4:	49 31 c0             	xor    r8,rax
  4043c7:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  4043ce:	00 
  4043cf:	49 c1 e2 04          	shl    r10,0x4
  4043d3:	49 31 c0             	xor    r8,rax
  4043d6:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  4043da:	4d 31 d0             	xor    r8,r10
  4043dd:	49 31 c0             	xor    r8,rax
  4043e0:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  4043e7:	00 
  4043e8:	49 c1 e1 04          	shl    r9,0x4
  4043ec:	49 31 c0             	xor    r8,rax
  4043ef:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  4043f3:	4d 31 c8             	xor    r8,r9
  4043f6:	49 31 f8             	xor    r8,rdi
  4043f9:	49 31 d0             	xor    r8,rdx
  4043fc:	49 31 c0             	xor    r8,rax
  4043ff:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  404406:	00 
  404407:	48 c1 e7 04          	shl    rdi,0x4
  40440b:	49 31 c0             	xor    r8,rax
  40440e:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  404412:	49 31 f8             	xor    r8,rdi
  404415:	49 31 c0             	xor    r8,rax
  404418:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  40441f:	00 
  404420:	48 c1 e2 04          	shl    rdx,0x4
  404424:	49 31 c0             	xor    r8,rax
  404427:	49 31 d0             	xor    r8,rdx
  40442a:	48 83 fd 30          	cmp    rbp,0x30
  40442e:	77 12                	ja     404442 <v3y+0x5d2>
  404430:	48 85 ed             	test   rbp,rbp
  404433:	0f 84 68 01 00 00    	je     4045a1 <v3y+0x731>
  404439:	83 f9 03             	cmp    ecx,0x3
  40443c:	0f 86 5f 01 00 00    	jbe    4045a1 <v3y+0x731>
  404442:	4c 89 c7             	mov    rdi,r8
  404445:	e8 76 d7 ff ff       	call   401bc0 <chv3_hwprod>
  40444a:	4c 8b 44 24 50       	mov    r8,QWORD PTR [rsp+0x50]
  40444f:	48 8b 74 24 58       	mov    rsi,QWORD PTR [rsp+0x58]
  404454:	49 89 d2             	mov    r10,rdx
  404457:	48 89 d1             	mov    rcx,rdx
  40445a:	48 c1 ea 3f          	shr    rdx,0x3f
  40445e:	4c 31 d0             	xor    rax,r10
  404461:	48 c1 e9 3d          	shr    rcx,0x3d
  404465:	48 89 f7             	mov    rdi,rsi
  404468:	49 31 c0             	xor    r8,rax
  40446b:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  40446f:	48 31 d1             	xor    rcx,rdx
  404472:	4c 89 d2             	mov    rdx,r10
  404475:	48 c1 ea 3c          	shr    rdx,0x3c
  404479:	49 31 f0             	xor    r8,rsi
  40447c:	48 c1 ef 3d          	shr    rdi,0x3d
  404480:	49 31 c0             	xor    r8,rax
  404483:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  40448a:	00 
  40448b:	49 c1 e2 04          	shl    r10,0x4
  40448f:	48 31 d1             	xor    rcx,rdx
  404492:	49 31 c0             	xor    r8,rax
  404495:	48 89 f2             	mov    rdx,rsi
  404498:	48 8d 04 36          	lea    rax,[rsi+rsi*1]
  40449c:	4d 31 d0             	xor    r8,r10
  40449f:	48 c1 ea 3f          	shr    rdx,0x3f
  4044a3:	49 31 c0             	xor    r8,rax
  4044a6:	48 8d 04 f5 00 00 00 	lea    rax,[rsi*8+0x0]
  4044ad:	00 
  4044ae:	48 31 fa             	xor    rdx,rdi
  4044b1:	48 89 f7             	mov    rdi,rsi
  4044b4:	48 c1 e6 04          	shl    rsi,0x4
  4044b8:	49 31 c0             	xor    r8,rax
  4044bb:	48 c1 ef 3c          	shr    rdi,0x3c
  4044bf:	48 8d 04 09          	lea    rax,[rcx+rcx*1]
  4044c3:	49 31 f0             	xor    r8,rsi
  4044c6:	48 31 fa             	xor    rdx,rdi
  4044c9:	49 31 c8             	xor    r8,rcx
  4044cc:	49 31 d0             	xor    r8,rdx
  4044cf:	49 31 c0             	xor    r8,rax
  4044d2:	48 8d 04 cd 00 00 00 	lea    rax,[rcx*8+0x0]
  4044d9:	00 
  4044da:	48 c1 e1 04          	shl    rcx,0x4
  4044de:	49 31 c0             	xor    r8,rax
  4044e1:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  4044e5:	49 31 c8             	xor    r8,rcx
  4044e8:	49 31 c0             	xor    r8,rax
  4044eb:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  4044f2:	00 
  4044f3:	48 c1 e2 04          	shl    rdx,0x4
  4044f7:	49 31 c0             	xor    r8,rax
  4044fa:	49 31 d0             	xor    r8,rdx
  4044fd:	e9 9f 00 00 00       	jmp    4045a1 <v3y+0x731>
  404502:	31 f6                	xor    esi,esi
  404504:	89 f0                	mov    eax,esi
  404506:	0f a2                	cpuid  
  404508:	85 c0                	test   eax,eax
  40450a:	0f 85 ac 00 00 00    	jne    4045bc <v3y+0x74c>
  404510:	c7 05 32 4b 00 00 00 	mov    DWORD PTR [rip+0x4b32],0x0        # 40904c <cache.5>
  404517:	00 00 00 
  40451a:	b9 f0 70 40 00       	mov    ecx,0x4070f0
  40451f:	ba 27 02 00 00       	mov    edx,0x227
  404524:	be 10 70 40 00       	mov    esi,0x407010
  404529:	bf 88 70 40 00       	mov    edi,0x407088
  40452e:	e8 2d cb ff ff       	call   401060 <__assert_fail@plt>
  404533:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  404538:	48 8b 79 08          	mov    rdi,QWORD PTR [rcx+0x8]
  40453c:	e9 02 fc ff ff       	jmp    404143 <v3y+0x2d3>
  404541:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  404548:	31 c0                	xor    eax,eax
  40454a:	49 33 45 10          	xor    rax,QWORD PTR [r13+0x10]
  40454e:	48 89 c6             	mov    rsi,rax
  404551:	49 83 fa 07          	cmp    r10,0x7
  404555:	0f 86 52 fa ff ff    	jbe    403fad <v3y+0x13d>
  40455b:	48 8b 01             	mov    rax,QWORD PTR [rcx]
  40455e:	e9 b3 fa ff ff       	jmp    404016 <v3y+0x1a6>
  404563:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  404568:	48 8b 41 48          	mov    rax,QWORD PTR [rcx+0x48]
  40456c:	e9 57 fb ff ff       	jmp    4040c8 <v3y+0x258>
  404571:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  404578:	48 8b 41 40          	mov    rax,QWORD PTR [rcx+0x40]
  40457c:	e9 1b fa ff ff       	jmp    403f9c <v3y+0x12c>
  404581:	48 8b 54 24 10       	mov    rdx,QWORD PTR [rsp+0x10]
  404586:	4c 89 cf             	mov    rdi,r9
  404589:	48 89 d6             	mov    rsi,rdx
  40458c:	48 c1 ee 0a          	shr    rsi,0xa
  404590:	e8 fb d9 ff ff       	call   401f90 <chv3_bulk256.constprop.0>
  404595:	49 89 c0             	mov    r8,rax
  404598:	48 85 ed             	test   rbp,rbp
  40459b:	0f 85 ad 00 00 00    	jne    40464e <v3y+0x7de>
  4045a1:	48 83 c4 68          	add    rsp,0x68
  4045a5:	4c 89 c6             	mov    rsi,r8
  4045a8:	bf 60 96 40 00       	mov    edi,0x409660
  4045ad:	5b                   	pop    rbx
  4045ae:	5d                   	pop    rbp
  4045af:	41 5c                	pop    r12
  4045b1:	41 5d                	pop    r13
  4045b3:	41 5e                	pop    r14
  4045b5:	41 5f                	pop    r15
  4045b7:	e9 34 d6 ff ff       	jmp    401bf0 <chv3_fastfinish>
  4045bc:	b8 01 00 00 00       	mov    eax,0x1
  4045c1:	0f a2                	cpuid  
  4045c3:	81 e1 02 00 00 18    	and    ecx,0x18000002
  4045c9:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
  4045cf:	0f 85 3b ff ff ff    	jne    404510 <v3y+0x6a0>
  4045d5:	89 f1                	mov    ecx,esi
  4045d7:	0f 01 d0             	xgetbv 
  4045da:	89 c7                	mov    edi,eax
  4045dc:	83 e0 06             	and    eax,0x6
  4045df:	83 f8 06             	cmp    eax,0x6
  4045e2:	0f 85 28 ff ff ff    	jne    404510 <v3y+0x6a0>
  4045e8:	89 f0                	mov    eax,esi
  4045ea:	0f a2                	cpuid  
  4045ec:	83 f8 06             	cmp    eax,0x6
  4045ef:	76 3f                	jbe    404630 <v3y+0x7c0>
  4045f1:	b8 07 00 00 00       	mov    eax,0x7
  4045f6:	89 f1                	mov    ecx,esi
  4045f8:	0f a2                	cpuid  
  4045fa:	f6 c3 20             	test   bl,0x20
  4045fd:	74 31                	je     404630 <v3y+0x7c0>
  4045ff:	80 e5 04             	and    ch,0x4
  404602:	74 2c                	je     404630 <v3y+0x7c0>
  404604:	81 e7 e6 00 00 00    	and    edi,0xe6
  40460a:	81 ff e6 00 00 00    	cmp    edi,0xe6
  404610:	75 2d                	jne    40463f <v3y+0x7cf>
  404612:	81 e3 00 00 01 00    	and    ebx,0x10000
  404618:	74 25                	je     40463f <v3y+0x7cf>
  40461a:	c7 05 28 4a 00 00 03 	mov    DWORD PTR [rip+0x4a28],0x3        # 40904c <cache.5>
  404621:	00 00 00 
  404624:	e9 86 f8 ff ff       	jmp    403eaf <v3y+0x3f>
  404629:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  404630:	c7 05 12 4a 00 00 01 	mov    DWORD PTR [rip+0x4a12],0x1        # 40904c <cache.5>
  404637:	00 00 00 
  40463a:	e9 db fe ff ff       	jmp    40451a <v3y+0x6aa>
  40463f:	c7 05 03 4a 00 00 02 	mov    DWORD PTR [rip+0x4a03],0x2        # 40904c <cache.5>
  404646:	00 00 00 
  404649:	e9 61 f8 ff ff       	jmp    403eaf <v3y+0x3f>
  40464e:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  404653:	4c 89 44 24 10       	mov    QWORD PTR [rsp+0x10],r8
  404658:	48 25 00 fc ff ff    	and    rax,0xfffffffffffffc00
  40465e:	49 01 c1             	add    r9,rax
  404661:	e9 58 f8 ff ff       	jmp    403ebe <v3y+0x4e>
  404666:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  40466d:	00 00 00 

0000000000404670 <v3x>:
  404670:	41 57                	push   r15
  404672:	49 89 f9             	mov    r9,rdi
  404675:	41 56                	push   r14
  404677:	41 55                	push   r13
  404679:	41 54                	push   r12
  40467b:	55                   	push   rbp
  40467c:	48 89 f5             	mov    rbp,rsi
  40467f:	53                   	push   rbx
  404680:	81 e5 ff 03 00 00    	and    ebp,0x3ff
  404686:	48 83 ec 68          	sub    rsp,0x68
  40468a:	48 89 74 24 10       	mov    QWORD PTR [rsp+0x10],rsi
  40468f:	8b 05 b7 49 00 00    	mov    eax,DWORD PTR [rip+0x49b7]        # 40904c <cache.5>
  404695:	85 c0                	test   eax,eax
  404697:	0f 88 95 06 00 00    	js     404d32 <v3x+0x6c2>
  40469d:	83 e0 fb             	and    eax,0xfffffffb
  4046a0:	0f 84 a0 06 00 00    	je     404d46 <v3x+0x6d6>
  4046a6:	48 81 7c 24 10 ff 03 	cmp    QWORD PTR [rsp+0x10],0x3ff
  4046ad:	00 00 
  4046af:	0f 87 42 06 00 00    	ja     404cf7 <v3x+0x687>
  4046b5:	49 8d 04 29          	lea    rax,[r9+rbp*1]
  4046b9:	66 0f ef c0          	pxor   xmm0,xmm0
  4046bd:	4c 8d 7c 24 60       	lea    r15,[rsp+0x60]
  4046c2:	49 89 ee             	mov    r14,rbp
  4046c5:	48 89 44 24 18       	mov    QWORD PTR [rsp+0x18],rax
  4046ca:	41 bd 60 96 40 00    	mov    r13d,0x409660
  4046d0:	0f 29 44 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm0
  4046d5:	0f 29 44 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm0
  4046da:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
  4046df:	0f 29 44 24 50       	movaps XMMWORD PTR [rsp+0x50],xmm0
  4046e4:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  4046e8:	48 8b 4c 24 18       	mov    rcx,QWORD PTR [rsp+0x18]
  4046ed:	49 89 e8             	mov    r8,rbp
  4046f0:	4c 8d 4c 24 20       	lea    r9,[rsp+0x20]
  4046f5:	4d 89 f2             	mov    r10,r14
  4046f8:	4d 29 f0             	sub    r8,r14
  4046fb:	4d 8d 5e f8          	lea    r11,[r14-0x8]
  4046ff:	4d 8d 66 b8          	lea    r12,[r14-0x48]
  404703:	4c 29 f1             	sub    rcx,r14
  404706:	49 8d 5e c0          	lea    rbx,[r14-0x40]
  40470a:	4c 39 c5             	cmp    rbp,r8
  40470d:	0f 86 1e 01 00 00    	jbe    404831 <v3x+0x1c1>
  404713:	49 8d 40 40          	lea    rax,[r8+0x40]
  404717:	48 39 c5             	cmp    rbp,rax
  40471a:	0f 86 50 06 00 00    	jbe    404d70 <v3x+0x700>
  404720:	48 83 fb 07          	cmp    rbx,0x7
  404724:	0f 87 76 06 00 00    	ja     404da0 <v3x+0x730>
  40472a:	0f b6 41 40          	movzx  eax,BYTE PTR [rcx+0x40]
  40472e:	48 83 fb 01          	cmp    rbx,0x1
  404732:	76 60                	jbe    404794 <v3x+0x124>
  404734:	0f b6 51 41          	movzx  edx,BYTE PTR [rcx+0x41]
  404738:	48 c1 e2 08          	shl    rdx,0x8
  40473c:	48 09 d0             	or     rax,rdx
  40473f:	48 83 fb 02          	cmp    rbx,0x2
  404743:	74 4f                	je     404794 <v3x+0x124>
  404745:	0f b6 51 42          	movzx  edx,BYTE PTR [rcx+0x42]
  404749:	48 c1 e2 10          	shl    rdx,0x10
  40474d:	48 09 d0             	or     rax,rdx
  404750:	48 83 fb 03          	cmp    rbx,0x3
  404754:	74 3e                	je     404794 <v3x+0x124>
  404756:	0f b6 51 43          	movzx  edx,BYTE PTR [rcx+0x43]
  40475a:	48 c1 e2 18          	shl    rdx,0x18
  40475e:	48 09 d0             	or     rax,rdx
  404761:	48 83 fb 04          	cmp    rbx,0x4
  404765:	74 2d                	je     404794 <v3x+0x124>
  404767:	0f b6 51 44          	movzx  edx,BYTE PTR [rcx+0x44]
  40476b:	48 c1 e2 20          	shl    rdx,0x20
  40476f:	48 09 d0             	or     rax,rdx
  404772:	48 83 fb 05          	cmp    rbx,0x5
  404776:	74 1c                	je     404794 <v3x+0x124>
  404778:	0f b6 51 45          	movzx  edx,BYTE PTR [rcx+0x45]
  40477c:	48 c1 e2 28          	shl    rdx,0x28
  404780:	48 09 d0             	or     rax,rdx
  404783:	48 83 fb 07          	cmp    rbx,0x7
  404787:	75 0b                	jne    404794 <v3x+0x124>
  404789:	0f b6 51 46          	movzx  edx,BYTE PTR [rcx+0x46]
  40478d:	48 c1 e2 30          	shl    rdx,0x30
  404791:	48 09 d0             	or     rax,rdx
  404794:	49 33 45 10          	xor    rax,QWORD PTR [r13+0x10]
  404798:	48 89 c6             	mov    rsi,rax
  40479b:	49 83 fa 07          	cmp    r10,0x7
  40479f:	0f 87 de 05 00 00    	ja     404d83 <v3x+0x713>
  4047a5:	0f b6 01             	movzx  eax,BYTE PTR [rcx]
  4047a8:	49 83 fa 01          	cmp    r10,0x1
  4047ac:	76 60                	jbe    40480e <v3x+0x19e>
  4047ae:	0f b6 51 01          	movzx  edx,BYTE PTR [rcx+0x1]
  4047b2:	48 c1 e2 08          	shl    rdx,0x8
  4047b6:	48 09 d0             	or     rax,rdx
  4047b9:	49 83 fa 02          	cmp    r10,0x2
  4047bd:	74 4f                	je     40480e <v3x+0x19e>
  4047bf:	0f b6 51 02          	movzx  edx,BYTE PTR [rcx+0x2]
  4047c3:	48 c1 e2 10          	shl    rdx,0x10
  4047c7:	48 09 d0             	or     rax,rdx
  4047ca:	49 83 fa 03          	cmp    r10,0x3
  4047ce:	74 3e                	je     40480e <v3x+0x19e>
  4047d0:	0f b6 51 03          	movzx  edx,BYTE PTR [rcx+0x3]
  4047d4:	48 c1 e2 18          	shl    rdx,0x18
  4047d8:	48 09 d0             	or     rax,rdx
  4047db:	49 83 fa 04          	cmp    r10,0x4
  4047df:	74 2d                	je     40480e <v3x+0x19e>
  4047e1:	0f b6 51 04          	movzx  edx,BYTE PTR [rcx+0x4]
  4047e5:	48 c1 e2 20          	shl    rdx,0x20
  4047e9:	48 09 d0             	or     rax,rdx
  4047ec:	49 83 fa 05          	cmp    r10,0x5
  4047f0:	74 1c                	je     40480e <v3x+0x19e>
  4047f2:	0f b6 51 05          	movzx  edx,BYTE PTR [rcx+0x5]
  4047f6:	48 c1 e2 28          	shl    rdx,0x28
  4047fa:	48 09 d0             	or     rax,rdx
  4047fd:	49 83 fa 07          	cmp    r10,0x7
  404801:	75 0b                	jne    40480e <v3x+0x19e>
  404803:	0f b6 51 06          	movzx  edx,BYTE PTR [rcx+0x6]
  404807:	48 c1 e2 30          	shl    rdx,0x30
  40480b:	48 09 d0             	or     rax,rdx
  40480e:	49 33 45 00          	xor    rax,QWORD PTR [r13+0x0]
  404812:	48 89 c7             	mov    rdi,rax
  404815:	e8 a6 d3 ff ff       	call   401bc0 <chv3_hwprod>
  40481a:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  40481e:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  404823:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  404828:	66 41 0f ef 01       	pxor   xmm0,XMMWORD PTR [r9]
  40482d:	41 0f 29 01          	movaps XMMWORD PTR [r9],xmm0
  404831:	49 8d 40 08          	lea    rax,[r8+0x8]
  404835:	48 39 c5             	cmp    rbp,rax
  404838:	0f 86 1d 01 00 00    	jbe    40495b <v3x+0x2eb>
  40483e:	49 8d 50 48          	lea    rdx,[r8+0x48]
  404842:	31 c0                	xor    eax,eax
  404844:	48 39 d5             	cmp    rbp,rdx
  404847:	76 77                	jbe    4048c0 <v3x+0x250>
  404849:	49 83 fc 07          	cmp    r12,0x7
  40484d:	0f 87 3d 05 00 00    	ja     404d90 <v3x+0x720>
  404853:	0f b6 41 48          	movzx  eax,BYTE PTR [rcx+0x48]
  404857:	49 83 fc 01          	cmp    r12,0x1
  40485b:	76 63                	jbe    4048c0 <v3x+0x250>
  40485d:	0f b6 51 49          	movzx  edx,BYTE PTR [rcx+0x49]
  404861:	48 c1 e2 08          	shl    rdx,0x8
  404865:	48 09 d0             	or     rax,rdx
  404868:	49 83 fc 02          	cmp    r12,0x2
  40486c:	74 52                	je     4048c0 <v3x+0x250>
  40486e:	0f b6 51 4a          	movzx  edx,BYTE PTR [rcx+0x4a]
  404872:	48 c1 e2 10          	shl    rdx,0x10
  404876:	48 09 d0             	or     rax,rdx
  404879:	49 83 fc 03          	cmp    r12,0x3
  40487d:	74 41                	je     4048c0 <v3x+0x250>
  40487f:	0f b6 51 4b          	movzx  edx,BYTE PTR [rcx+0x4b]
  404883:	48 c1 e2 18          	shl    rdx,0x18
  404887:	48 09 d0             	or     rax,rdx
  40488a:	49 83 fc 04          	cmp    r12,0x4
  40488e:	74 30                	je     4048c0 <v3x+0x250>
  404890:	0f b6 51 4c          	movzx  edx,BYTE PTR [rcx+0x4c]
  404894:	48 c1 e2 20          	shl    rdx,0x20
  404898:	48 09 d0             	or     rax,rdx
  40489b:	49 83 fc 05          	cmp    r12,0x5
  40489f:	74 1f                	je     4048c0 <v3x+0x250>
  4048a1:	0f b6 51 4d          	movzx  edx,BYTE PTR [rcx+0x4d]
  4048a5:	48 c1 e2 28          	shl    rdx,0x28
  4048a9:	48 09 d0             	or     rax,rdx
  4048ac:	49 83 fc 07          	cmp    r12,0x7
  4048b0:	75 0e                	jne    4048c0 <v3x+0x250>
  4048b2:	0f b6 51 4e          	movzx  edx,BYTE PTR [rcx+0x4e]
  4048b6:	48 c1 e2 30          	shl    rdx,0x30
  4048ba:	48 09 d0             	or     rax,rdx
  4048bd:	0f 1f 00             	nop    DWORD PTR [rax]
  4048c0:	49 33 45 18          	xor    rax,QWORD PTR [r13+0x18]
  4048c4:	48 89 c6             	mov    rsi,rax
  4048c7:	49 83 fb 07          	cmp    r11,0x7
  4048cb:	0f 87 8f 04 00 00    	ja     404d60 <v3x+0x6f0>
  4048d1:	0f b6 79 08          	movzx  edi,BYTE PTR [rcx+0x8]
  4048d5:	49 83 fb 01          	cmp    r11,0x1
  4048d9:	76 60                	jbe    40493b <v3x+0x2cb>
  4048db:	0f b6 41 09          	movzx  eax,BYTE PTR [rcx+0x9]
  4048df:	48 c1 e0 08          	shl    rax,0x8
  4048e3:	48 09 c7             	or     rdi,rax
  4048e6:	49 83 fb 02          	cmp    r11,0x2
  4048ea:	74 4f                	je     40493b <v3x+0x2cb>
  4048ec:	0f b6 41 0a          	movzx  eax,BYTE PTR [rcx+0xa]
  4048f0:	48 c1 e0 10          	shl    rax,0x10
  4048f4:	48 09 c7             	or     rdi,rax
  4048f7:	49 83 fb 03          	cmp    r11,0x3
  4048fb:	74 3e                	je     40493b <v3x+0x2cb>
  4048fd:	0f b6 41 0b          	movzx  eax,BYTE PTR [rcx+0xb]
  404901:	48 c1 e0 18          	shl    rax,0x18
  404905:	48 09 c7             	or     rdi,rax
  404908:	49 83 fb 04          	cmp    r11,0x4
  40490c:	74 2d                	je     40493b <v3x+0x2cb>
  40490e:	0f b6 41 0c          	movzx  eax,BYTE PTR [rcx+0xc]
  404912:	48 c1 e0 20          	shl    rax,0x20
  404916:	48 09 c7             	or     rdi,rax
  404919:	49 83 fb 05          	cmp    r11,0x5
  40491d:	74 1c                	je     40493b <v3x+0x2cb>
  40491f:	0f b6 41 0d          	movzx  eax,BYTE PTR [rcx+0xd]
  404923:	48 c1 e0 28          	shl    rax,0x28
  404927:	48 09 c7             	or     rdi,rax
  40492a:	49 83 fb 07          	cmp    r11,0x7
  40492e:	75 0b                	jne    40493b <v3x+0x2cb>
  404930:	0f b6 41 0e          	movzx  eax,BYTE PTR [rcx+0xe]
  404934:	48 c1 e0 30          	shl    rax,0x30
  404938:	48 09 c7             	or     rdi,rax
  40493b:	49 33 7d 08          	xor    rdi,QWORD PTR [r13+0x8]
  40493f:	e8 7c d2 ff ff       	call   401bc0 <chv3_hwprod>
  404944:	48 89 04 24          	mov    QWORD PTR [rsp],rax
  404948:	48 89 54 24 08       	mov    QWORD PTR [rsp+0x8],rdx
  40494d:	66 0f 6f 04 24       	movdqa xmm0,XMMWORD PTR [rsp]
  404952:	66 41 0f ef 01       	pxor   xmm0,XMMWORD PTR [r9]
  404957:	41 0f 29 01          	movaps XMMWORD PTR [r9],xmm0
  40495b:	49 83 c1 10          	add    r9,0x10
  40495f:	49 83 c0 10          	add    r8,0x10
  404963:	49 83 eb 10          	sub    r11,0x10
  404967:	49 83 ec 10          	sub    r12,0x10
  40496b:	48 83 c1 10          	add    rcx,0x10
  40496f:	49 83 ea 10          	sub    r10,0x10
  404973:	48 83 eb 10          	sub    rbx,0x10
  404977:	4d 39 cf             	cmp    r15,r9
  40497a:	0f 85 8a fd ff ff    	jne    40470a <v3x+0x9a>
  404980:	49 83 c5 20          	add    r13,0x20
  404984:	49 83 c6 80          	add    r14,0xffffffffffffff80
  404988:	49 81 fd 60 97 40 00 	cmp    r13,0x409760
  40498f:	0f 85 53 fd ff ff    	jne    4046e8 <v3x+0x78>
  404995:	48 8d 4d ff          	lea    rcx,[rbp-0x1]
  404999:	48 c1 e9 04          	shr    rcx,0x4
  40499d:	83 c1 01             	add    ecx,0x1
  4049a0:	48 83 fd 30          	cmp    rbp,0x30
  4049a4:	77 12                	ja     4049b8 <v3x+0x348>
  4049a6:	48 85 ed             	test   rbp,rbp
  4049a9:	74 0d                	je     4049b8 <v3x+0x348>
  4049ab:	4c 8b 44 24 10       	mov    r8,QWORD PTR [rsp+0x10]
  4049b0:	85 c9                	test   ecx,ecx
  4049b2:	0f 84 5f 03 00 00    	je     404d17 <v3x+0x6a7>
  4049b8:	48 8b 7c 24 10       	mov    rdi,QWORD PTR [rsp+0x10]
  4049bd:	48 8b 35 a4 4d 00 00 	mov    rsi,QWORD PTR [rip+0x4da4]        # 409768 <v3+0x108>
  4049c4:	e8 f7 d1 ff ff       	call   401bc0 <chv3_hwprod>
  4049c9:	4c 8b 4c 24 28       	mov    r9,QWORD PTR [rsp+0x28]
  4049ce:	48 89 d7             	mov    rdi,rdx
  4049d1:	49 89 d2             	mov    r10,rdx
  4049d4:	48 c1 ea 3d          	shr    rdx,0x3d
  4049d8:	48 c1 ef 3f          	shr    rdi,0x3f
  4049dc:	4d 89 c8             	mov    r8,r9
  4049df:	4c 31 d0             	xor    rax,r10
  4049e2:	48 31 d7             	xor    rdi,rdx
  4049e5:	4c 89 d2             	mov    rdx,r10
  4049e8:	49 c1 e8 3f          	shr    r8,0x3f
  4049ec:	48 c1 ea 3c          	shr    rdx,0x3c
  4049f0:	48 31 d7             	xor    rdi,rdx
  4049f3:	4c 89 ca             	mov    rdx,r9
  4049f6:	48 c1 ea 3d          	shr    rdx,0x3d
  4049fa:	4c 31 c2             	xor    rdx,r8
  4049fd:	4d 89 c8             	mov    r8,r9
  404a00:	49 c1 e8 3c          	shr    r8,0x3c
  404a04:	4c 31 c2             	xor    rdx,r8
  404a07:	4c 8b 44 24 20       	mov    r8,QWORD PTR [rsp+0x20]
  404a0c:	49 31 c0             	xor    r8,rax
  404a0f:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  404a13:	4d 31 c8             	xor    r8,r9
  404a16:	49 31 c0             	xor    r8,rax
  404a19:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  404a20:	00 
  404a21:	49 c1 e2 04          	shl    r10,0x4
  404a25:	49 31 c0             	xor    r8,rax
  404a28:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  404a2c:	4d 31 d0             	xor    r8,r10
  404a2f:	49 31 c0             	xor    r8,rax
  404a32:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  404a39:	00 
  404a3a:	49 c1 e1 04          	shl    r9,0x4
  404a3e:	49 31 c0             	xor    r8,rax
  404a41:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  404a45:	4d 31 c8             	xor    r8,r9
  404a48:	49 31 f8             	xor    r8,rdi
  404a4b:	49 31 d0             	xor    r8,rdx
  404a4e:	49 31 c0             	xor    r8,rax
  404a51:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  404a58:	00 
  404a59:	48 c1 e7 04          	shl    rdi,0x4
  404a5d:	49 31 c0             	xor    r8,rax
  404a60:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  404a64:	49 31 f8             	xor    r8,rdi
  404a67:	49 31 c0             	xor    r8,rax
  404a6a:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  404a71:	00 
  404a72:	48 c1 e2 04          	shl    rdx,0x4
  404a76:	49 31 c0             	xor    r8,rax
  404a79:	49 31 d0             	xor    r8,rdx
  404a7c:	48 83 fd 30          	cmp    rbp,0x30
  404a80:	77 12                	ja     404a94 <v3x+0x424>
  404a82:	48 85 ed             	test   rbp,rbp
  404a85:	0f 84 8c 02 00 00    	je     404d17 <v3x+0x6a7>
  404a8b:	83 f9 01             	cmp    ecx,0x1
  404a8e:	0f 86 83 02 00 00    	jbe    404d17 <v3x+0x6a7>
  404a94:	4c 89 c7             	mov    rdi,r8
  404a97:	e8 24 d1 ff ff       	call   401bc0 <chv3_hwprod>
  404a9c:	4c 8b 4c 24 38       	mov    r9,QWORD PTR [rsp+0x38]
  404aa1:	48 89 d7             	mov    rdi,rdx
  404aa4:	49 89 d2             	mov    r10,rdx
  404aa7:	48 c1 ea 3d          	shr    rdx,0x3d
  404aab:	48 c1 ef 3f          	shr    rdi,0x3f
  404aaf:	4d 89 c8             	mov    r8,r9
  404ab2:	4c 31 d0             	xor    rax,r10
  404ab5:	48 31 d7             	xor    rdi,rdx
  404ab8:	4c 89 d2             	mov    rdx,r10
  404abb:	49 c1 e8 3d          	shr    r8,0x3d
  404abf:	48 c1 ea 3c          	shr    rdx,0x3c
  404ac3:	48 31 d7             	xor    rdi,rdx
  404ac6:	4c 89 ca             	mov    rdx,r9
  404ac9:	48 c1 ea 3f          	shr    rdx,0x3f
  404acd:	4c 31 c2             	xor    rdx,r8
  404ad0:	4d 89 c8             	mov    r8,r9
  404ad3:	49 c1 e8 3c          	shr    r8,0x3c
  404ad7:	4c 31 c2             	xor    rdx,r8
  404ada:	4c 8b 44 24 30       	mov    r8,QWORD PTR [rsp+0x30]
  404adf:	49 31 c0             	xor    r8,rax
  404ae2:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  404ae6:	4d 31 c8             	xor    r8,r9
  404ae9:	49 31 c0             	xor    r8,rax
  404aec:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  404af3:	00 
  404af4:	49 c1 e2 04          	shl    r10,0x4
  404af8:	49 31 c0             	xor    r8,rax
  404afb:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  404aff:	4d 31 d0             	xor    r8,r10
  404b02:	49 31 c0             	xor    r8,rax
  404b05:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  404b0c:	00 
  404b0d:	49 c1 e1 04          	shl    r9,0x4
  404b11:	49 31 c0             	xor    r8,rax
  404b14:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  404b18:	4d 31 c8             	xor    r8,r9
  404b1b:	49 31 f8             	xor    r8,rdi
  404b1e:	49 31 d0             	xor    r8,rdx
  404b21:	49 31 c0             	xor    r8,rax
  404b24:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  404b2b:	00 
  404b2c:	48 c1 e7 04          	shl    rdi,0x4
  404b30:	49 31 c0             	xor    r8,rax
  404b33:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  404b37:	49 31 f8             	xor    r8,rdi
  404b3a:	49 31 c0             	xor    r8,rax
  404b3d:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  404b44:	00 
  404b45:	48 c1 e2 04          	shl    rdx,0x4
  404b49:	49 31 c0             	xor    r8,rax
  404b4c:	49 31 d0             	xor    r8,rdx
  404b4f:	48 83 fd 30          	cmp    rbp,0x30
  404b53:	77 12                	ja     404b67 <v3x+0x4f7>
  404b55:	48 85 ed             	test   rbp,rbp
  404b58:	0f 84 b9 01 00 00    	je     404d17 <v3x+0x6a7>
  404b5e:	83 f9 02             	cmp    ecx,0x2
  404b61:	0f 86 b0 01 00 00    	jbe    404d17 <v3x+0x6a7>
  404b67:	4c 89 c7             	mov    rdi,r8
  404b6a:	e8 51 d0 ff ff       	call   401bc0 <chv3_hwprod>
  404b6f:	4c 8b 4c 24 48       	mov    r9,QWORD PTR [rsp+0x48]
  404b74:	48 89 d7             	mov    rdi,rdx
  404b77:	49 89 d2             	mov    r10,rdx
  404b7a:	48 c1 ea 3f          	shr    rdx,0x3f
  404b7e:	48 c1 ef 3d          	shr    rdi,0x3d
  404b82:	4d 89 c8             	mov    r8,r9
  404b85:	4c 31 d0             	xor    rax,r10
  404b88:	48 31 d7             	xor    rdi,rdx
  404b8b:	4c 89 d2             	mov    rdx,r10
  404b8e:	49 c1 e8 3d          	shr    r8,0x3d
  404b92:	48 c1 ea 3c          	shr    rdx,0x3c
  404b96:	48 31 d7             	xor    rdi,rdx
  404b99:	4c 89 ca             	mov    rdx,r9
  404b9c:	48 c1 ea 3f          	shr    rdx,0x3f
  404ba0:	4c 31 c2             	xor    rdx,r8
  404ba3:	4d 89 c8             	mov    r8,r9
  404ba6:	49 c1 e8 3c          	shr    r8,0x3c
  404baa:	4c 31 c2             	xor    rdx,r8
  404bad:	4c 8b 44 24 40       	mov    r8,QWORD PTR [rsp+0x40]
  404bb2:	49 31 c0             	xor    r8,rax
  404bb5:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  404bb9:	4d 31 c8             	xor    r8,r9
  404bbc:	49 31 c0             	xor    r8,rax
  404bbf:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  404bc6:	00 
  404bc7:	49 c1 e2 04          	shl    r10,0x4
  404bcb:	49 31 c0             	xor    r8,rax
  404bce:	4b 8d 04 09          	lea    rax,[r9+r9*1]
  404bd2:	4d 31 d0             	xor    r8,r10
  404bd5:	49 31 c0             	xor    r8,rax
  404bd8:	4a 8d 04 cd 00 00 00 	lea    rax,[r9*8+0x0]
  404bdf:	00 
  404be0:	49 c1 e1 04          	shl    r9,0x4
  404be4:	49 31 c0             	xor    r8,rax
  404be7:	48 8d 04 3f          	lea    rax,[rdi+rdi*1]
  404beb:	4d 31 c8             	xor    r8,r9
  404bee:	49 31 f8             	xor    r8,rdi
  404bf1:	49 31 d0             	xor    r8,rdx
  404bf4:	49 31 c0             	xor    r8,rax
  404bf7:	48 8d 04 fd 00 00 00 	lea    rax,[rdi*8+0x0]
  404bfe:	00 
  404bff:	48 c1 e7 04          	shl    rdi,0x4
  404c03:	49 31 c0             	xor    r8,rax
  404c06:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  404c0a:	49 31 f8             	xor    r8,rdi
  404c0d:	49 31 c0             	xor    r8,rax
  404c10:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  404c17:	00 
  404c18:	48 c1 e2 04          	shl    rdx,0x4
  404c1c:	49 31 c0             	xor    r8,rax
  404c1f:	49 31 d0             	xor    r8,rdx
  404c22:	48 83 fd 30          	cmp    rbp,0x30
  404c26:	77 12                	ja     404c3a <v3x+0x5ca>
  404c28:	48 85 ed             	test   rbp,rbp
  404c2b:	0f 84 e6 00 00 00    	je     404d17 <v3x+0x6a7>
  404c31:	83 f9 03             	cmp    ecx,0x3
  404c34:	0f 86 dd 00 00 00    	jbe    404d17 <v3x+0x6a7>
  404c3a:	4c 89 c7             	mov    rdi,r8
  404c3d:	e8 7e cf ff ff       	call   401bc0 <chv3_hwprod>
  404c42:	4c 8b 44 24 50       	mov    r8,QWORD PTR [rsp+0x50]
  404c47:	48 8b 74 24 58       	mov    rsi,QWORD PTR [rsp+0x58]
  404c4c:	49 89 d2             	mov    r10,rdx
  404c4f:	48 89 d1             	mov    rcx,rdx
  404c52:	48 c1 ea 3f          	shr    rdx,0x3f
  404c56:	4c 31 d0             	xor    rax,r10
  404c59:	48 c1 e9 3d          	shr    rcx,0x3d
  404c5d:	48 89 f7             	mov    rdi,rsi
  404c60:	49 31 c0             	xor    r8,rax
  404c63:	4b 8d 04 12          	lea    rax,[r10+r10*1]
  404c67:	48 31 d1             	xor    rcx,rdx
  404c6a:	4c 89 d2             	mov    rdx,r10
  404c6d:	48 c1 ea 3c          	shr    rdx,0x3c
  404c71:	49 31 f0             	xor    r8,rsi
  404c74:	48 c1 ef 3d          	shr    rdi,0x3d
  404c78:	49 31 c0             	xor    r8,rax
  404c7b:	4a 8d 04 d5 00 00 00 	lea    rax,[r10*8+0x0]
  404c82:	00 
  404c83:	49 c1 e2 04          	shl    r10,0x4
  404c87:	48 31 d1             	xor    rcx,rdx
  404c8a:	49 31 c0             	xor    r8,rax
  404c8d:	48 89 f2             	mov    rdx,rsi
  404c90:	48 8d 04 36          	lea    rax,[rsi+rsi*1]
  404c94:	4d 31 d0             	xor    r8,r10
  404c97:	48 c1 ea 3f          	shr    rdx,0x3f
  404c9b:	49 31 c0             	xor    r8,rax
  404c9e:	48 8d 04 f5 00 00 00 	lea    rax,[rsi*8+0x0]
  404ca5:	00 
  404ca6:	48 31 fa             	xor    rdx,rdi
  404ca9:	48 89 f7             	mov    rdi,rsi
  404cac:	48 c1 e6 04          	shl    rsi,0x4
  404cb0:	49 31 c0             	xor    r8,rax
  404cb3:	48 c1 ef 3c          	shr    rdi,0x3c
  404cb7:	48 8d 04 09          	lea    rax,[rcx+rcx*1]
  404cbb:	49 31 f0             	xor    r8,rsi
  404cbe:	48 31 fa             	xor    rdx,rdi
  404cc1:	49 31 c8             	xor    r8,rcx
  404cc4:	49 31 d0             	xor    r8,rdx
  404cc7:	49 31 c0             	xor    r8,rax
  404cca:	48 8d 04 cd 00 00 00 	lea    rax,[rcx*8+0x0]
  404cd1:	00 
  404cd2:	48 c1 e1 04          	shl    rcx,0x4
  404cd6:	49 31 c0             	xor    r8,rax
  404cd9:	48 8d 04 12          	lea    rax,[rdx+rdx*1]
  404cdd:	49 31 c8             	xor    r8,rcx
  404ce0:	49 31 c0             	xor    r8,rax
  404ce3:	48 8d 04 d5 00 00 00 	lea    rax,[rdx*8+0x0]
  404cea:	00 
  404ceb:	48 c1 e2 04          	shl    rdx,0x4
  404cef:	49 31 c0             	xor    r8,rax
  404cf2:	49 31 d0             	xor    r8,rdx
  404cf5:	eb 20                	jmp    404d17 <v3x+0x6a7>
  404cf7:	48 8b 54 24 10       	mov    rdx,QWORD PTR [rsp+0x10]
  404cfc:	4c 89 cf             	mov    rdi,r9
  404cff:	48 89 d6             	mov    rsi,rdx
  404d02:	48 c1 ee 0a          	shr    rsi,0xa
  404d06:	e8 75 d6 ff ff       	call   402380 <chv3_bulk128.constprop.0>
  404d0b:	49 89 c0             	mov    r8,rax
  404d0e:	48 85 ed             	test   rbp,rbp
  404d11:	0f 85 27 01 00 00    	jne    404e3e <v3x+0x7ce>
  404d17:	48 83 c4 68          	add    rsp,0x68
  404d1b:	4c 89 c6             	mov    rsi,r8
  404d1e:	bf 60 96 40 00       	mov    edi,0x409660
  404d23:	5b                   	pop    rbx
  404d24:	5d                   	pop    rbp
  404d25:	41 5c                	pop    r12
  404d27:	41 5d                	pop    r13
  404d29:	41 5e                	pop    r14
  404d2b:	41 5f                	pop    r15
  404d2d:	e9 be ce ff ff       	jmp    401bf0 <chv3_fastfinish>
  404d32:	31 f6                	xor    esi,esi
  404d34:	89 f0                	mov    eax,esi
  404d36:	0f a2                	cpuid  
  404d38:	85 c0                	test   eax,eax
  404d3a:	75 6d                	jne    404da9 <v3x+0x739>
  404d3c:	c7 05 06 43 00 00 00 	mov    DWORD PTR [rip+0x4306],0x0        # 40904c <cache.5>
  404d43:	00 00 00 
  404d46:	b9 f0 70 40 00       	mov    ecx,0x4070f0
  404d4b:	ba 27 02 00 00       	mov    edx,0x227
  404d50:	be 10 70 40 00       	mov    esi,0x407010
  404d55:	bf 88 70 40 00       	mov    edi,0x407088
  404d5a:	e8 01 c3 ff ff       	call   401060 <__assert_fail@plt>
  404d5f:	90                   	nop
  404d60:	48 8b 79 08          	mov    rdi,QWORD PTR [rcx+0x8]
  404d64:	e9 d2 fb ff ff       	jmp    40493b <v3x+0x2cb>
  404d69:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  404d70:	31 c0                	xor    eax,eax
  404d72:	49 33 45 10          	xor    rax,QWORD PTR [r13+0x10]
  404d76:	48 89 c6             	mov    rsi,rax
  404d79:	49 83 fa 07          	cmp    r10,0x7
  404d7d:	0f 86 22 fa ff ff    	jbe    4047a5 <v3x+0x135>
  404d83:	48 8b 01             	mov    rax,QWORD PTR [rcx]
  404d86:	e9 83 fa ff ff       	jmp    40480e <v3x+0x19e>
  404d8b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  404d90:	48 8b 41 48          	mov    rax,QWORD PTR [rcx+0x48]
  404d94:	e9 27 fb ff ff       	jmp    4048c0 <v3x+0x250>
  404d99:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  404da0:	48 8b 41 40          	mov    rax,QWORD PTR [rcx+0x40]
  404da4:	e9 eb f9 ff ff       	jmp    404794 <v3x+0x124>
  404da9:	b8 01 00 00 00       	mov    eax,0x1
  404dae:	0f a2                	cpuid  
  404db0:	81 e1 02 00 00 18    	and    ecx,0x18000002
  404db6:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
  404dbc:	0f 85 7a ff ff ff    	jne    404d3c <v3x+0x6cc>
  404dc2:	89 f1                	mov    ecx,esi
  404dc4:	0f 01 d0             	xgetbv 
  404dc7:	89 c7                	mov    edi,eax
  404dc9:	83 e0 06             	and    eax,0x6
  404dcc:	83 f8 06             	cmp    eax,0x6
  404dcf:	0f 85 67 ff ff ff    	jne    404d3c <v3x+0x6cc>
  404dd5:	89 f0                	mov    eax,esi
  404dd7:	0f a2                	cpuid  
  404dd9:	83 f8 06             	cmp    eax,0x6
  404ddc:	76 42                	jbe    404e20 <v3x+0x7b0>
  404dde:	b8 07 00 00 00       	mov    eax,0x7
  404de3:	89 f1                	mov    ecx,esi
  404de5:	0f a2                	cpuid  
  404de7:	f6 c3 20             	test   bl,0x20
  404dea:	74 34                	je     404e20 <v3x+0x7b0>
  404dec:	80 e5 04             	and    ch,0x4
  404def:	74 2f                	je     404e20 <v3x+0x7b0>
  404df1:	81 e7 e6 00 00 00    	and    edi,0xe6
  404df7:	81 ff e6 00 00 00    	cmp    edi,0xe6
  404dfd:	75 30                	jne    404e2f <v3x+0x7bf>
  404dff:	81 e3 00 00 01 00    	and    ebx,0x10000
  404e05:	74 28                	je     404e2f <v3x+0x7bf>
  404e07:	c7 05 3b 42 00 00 03 	mov    DWORD PTR [rip+0x423b],0x3        # 40904c <cache.5>
  404e0e:	00 00 00 
  404e11:	e9 90 f8 ff ff       	jmp    4046a6 <v3x+0x36>
  404e16:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  404e1d:	00 00 00 
  404e20:	c7 05 22 42 00 00 01 	mov    DWORD PTR [rip+0x4222],0x1        # 40904c <cache.5>
  404e27:	00 00 00 
  404e2a:	e9 77 f8 ff ff       	jmp    4046a6 <v3x+0x36>
  404e2f:	c7 05 13 42 00 00 02 	mov    DWORD PTR [rip+0x4213],0x2        # 40904c <cache.5>
  404e36:	00 00 00 
  404e39:	e9 68 f8 ff ff       	jmp    4046a6 <v3x+0x36>
  404e3e:	48 8b 44 24 10       	mov    rax,QWORD PTR [rsp+0x10]
  404e43:	4c 89 44 24 10       	mov    QWORD PTR [rsp+0x10],r8
  404e48:	48 25 00 fc ff ff    	and    rax,0xfffffffffffffc00
  404e4e:	49 01 c1             	add    r9,rax
  404e51:	e9 5f f8 ff ff       	jmp    4046b5 <v3x+0x45>
  404e56:	66 2e 0f 1f 84 00 00 	nop    WORD PTR cs:[rax+rax*1+0x0]
  404e5d:	00 00 00 

0000000000404e60 <v3z>:
  404e60:	49 89 f0             	mov    r8,rsi
  404e63:	53                   	push   rbx
  404e64:	8b 05 e2 41 00 00    	mov    eax,DWORD PTR [rip+0x41e2]        # 40904c <cache.5>
  404e6a:	49 89 f9             	mov    r9,rdi
  404e6d:	4d 89 c2             	mov    r10,r8
  404e70:	48 c1 ee 0a          	shr    rsi,0xa
  404e74:	41 81 e2 ff 03 00 00 	and    r10d,0x3ff
  404e7b:	85 c0                	test   eax,eax
  404e7d:	78 2f                	js     404eae <v3z+0x4e>
  404e7f:	83 f8 04             	cmp    eax,0x4
  404e82:	74 3e                	je     404ec2 <v3z+0x62>
  404e84:	83 f8 02             	cmp    eax,0x2
  404e87:	7e 39                	jle    404ec2 <v3z+0x62>
  404e89:	49 81 f8 ff 03 00 00 	cmp    r8,0x3ff
  404e90:	77 4e                	ja     404ee0 <v3z+0x80>
  404e92:	4c 89 d6             	mov    rsi,r10
  404e95:	4c 89 cf             	mov    rdi,r9
  404e98:	4c 89 c2             	mov    rdx,r8
  404e9b:	e8 00 ce ff ff       	call   401ca0 <chv3_tail512.constprop.0>
  404ea0:	bf 60 96 40 00       	mov    edi,0x409660
  404ea5:	5b                   	pop    rbx
  404ea6:	48 89 c6             	mov    rsi,rax
  404ea9:	e9 42 cd ff ff       	jmp    401bf0 <chv3_fastfinish>
  404eae:	31 ff                	xor    edi,edi
  404eb0:	89 f8                	mov    eax,edi
  404eb2:	0f a2                	cpuid  
  404eb4:	85 c0                	test   eax,eax
  404eb6:	75 4a                	jne    404f02 <v3z+0xa2>
  404eb8:	c7 05 8a 41 00 00 00 	mov    DWORD PTR [rip+0x418a],0x0        # 40904c <cache.5>
  404ebf:	00 00 00 
  404ec2:	b9 f0 70 40 00       	mov    ecx,0x4070f0
  404ec7:	ba 27 02 00 00       	mov    edx,0x227
  404ecc:	be 10 70 40 00       	mov    esi,0x407010
  404ed1:	bf 88 70 40 00       	mov    edi,0x407088
  404ed6:	e8 85 c1 ff ff       	call   401060 <__assert_fail@plt>
  404edb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  404ee0:	4c 89 c2             	mov    rdx,r8
  404ee3:	4c 89 cf             	mov    rdi,r9
  404ee6:	e8 75 ec ff ff       	call   403b60 <chv3_bulk512.constprop.0>
  404eeb:	48 89 c6             	mov    rsi,rax
  404eee:	4d 85 d2             	test   r10,r10
  404ef1:	0f 85 97 00 00 00    	jne    404f8e <v3z+0x12e>
  404ef7:	bf 60 96 40 00       	mov    edi,0x409660
  404efc:	5b                   	pop    rbx
  404efd:	e9 ee cc ff ff       	jmp    401bf0 <chv3_fastfinish>
  404f02:	b8 01 00 00 00       	mov    eax,0x1
  404f07:	0f a2                	cpuid  
  404f09:	81 e1 02 00 00 18    	and    ecx,0x18000002
  404f0f:	81 f9 02 00 00 18    	cmp    ecx,0x18000002
  404f15:	75 a1                	jne    404eb8 <v3z+0x58>
  404f17:	89 f9                	mov    ecx,edi
  404f19:	0f 01 d0             	xgetbv 
  404f1c:	41 89 c3             	mov    r11d,eax
  404f1f:	83 e0 06             	and    eax,0x6
  404f22:	83 f8 06             	cmp    eax,0x6
  404f25:	75 91                	jne    404eb8 <v3z+0x58>
  404f27:	89 f8                	mov    eax,edi
  404f29:	0f a2                	cpuid  
  404f2b:	83 f8 06             	cmp    eax,0x6
  404f2e:	76 40                	jbe    404f70 <v3z+0x110>
  404f30:	b8 07 00 00 00       	mov    eax,0x7
  404f35:	89 f9                	mov    ecx,edi
  404f37:	0f a2                	cpuid  
  404f39:	f6 c3 20             	test   bl,0x20
  404f3c:	74 32                	je     404f70 <v3z+0x110>
  404f3e:	80 e5 04             	and    ch,0x4
  404f41:	74 2d                	je     404f70 <v3z+0x110>
  404f43:	41 81 e3 e6 00 00 00 	and    r11d,0xe6
  404f4a:	41 81 fb e6 00 00 00 	cmp    r11d,0xe6
  404f51:	75 2c                	jne    404f7f <v3z+0x11f>
  404f53:	81 e3 00 00 01 00    	and    ebx,0x10000
  404f59:	74 24                	je     404f7f <v3z+0x11f>
  404f5b:	c7 05 e7 40 00 00 03 	mov    DWORD PTR [rip+0x40e7],0x3        # 40904c <cache.5>
  404f62:	00 00 00 
  404f65:	e9 1f ff ff ff       	jmp    404e89 <v3z+0x29>
  404f6a:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  404f70:	c7 05 d2 40 00 00 01 	mov    DWORD PTR [rip+0x40d2],0x1        # 40904c <cache.5>
  404f77:	00 00 00 
  404f7a:	e9 43 ff ff ff       	jmp    404ec2 <v3z+0x62>
  404f7f:	c7 05 c3 40 00 00 02 	mov    DWORD PTR [rip+0x40c3],0x2        # 40904c <cache.5>
  404f86:	00 00 00 
  404f89:	e9 34 ff ff ff       	jmp    404ec2 <v3z+0x62>
  404f8e:	49 81 e0 00 fc ff ff 	and    r8,0xfffffffffffffc00
  404f95:	4d 01 c1             	add    r9,r8
  404f98:	49 89 c0             	mov    r8,rax
  404f9b:	e9 f2 fe ff ff       	jmp    404e92 <v3z+0x32>

0000000000404fa0 <chainhash_wide256.constprop.0>:
  404fa0:	55                   	push   rbp
  404fa1:	48 8d 56 ff          	lea    rdx,[rsi-0x1]
  404fa5:	49 89 d0             	mov    r8,rdx
  404fa8:	49 c1 e8 08          	shr    r8,0x8
  404fac:	48 89 e5             	mov    rbp,rsp
  404faf:	41 55                	push   r13
  404fb1:	41 54                	push   r12
  404fb3:	53                   	push   rbx
  404fb4:	48 89 f3             	mov    rbx,rsi
  404fb7:	48 83 e4 e0          	and    rsp,0xffffffffffffffe0
  404fbb:	48 81 ec c0 00 00 00 	sub    rsp,0xc0
  404fc2:	4c 8b 25 d7 41 00 00 	mov    r12,QWORD PTR [rip+0x41d7]        # 4091a0 <shipped+0x100>
  404fc9:	48 8b 05 e0 41 00 00 	mov    rax,QWORD PTR [rip+0x41e0]        # 4091b0 <shipped+0x110>
  404fd0:	c5 f9 6f 35 c8 41 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x41c8]        # 4091a0 <shipped+0x100>
  404fd7:	00 
  404fd8:	4c 31 e0             	xor    rax,r12
  404fdb:	c5 f9 7f b4 24 90 00 	vmovdqa XMMWORD PTR [rsp+0x90],xmm6
  404fe2:	00 00 
  404fe4:	c4 e1 f9 6e c8       	vmovq  xmm1,rax
  404fe9:	48 81 fa ff 00 00 00 	cmp    rdx,0xff
  404ff0:	0f 87 2a 01 00 00    	ja     405120 <chainhash_wide256.constprop.0+0x180>
  404ff6:	c5 f9 6f 25 22 21 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x2122]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  404ffd:	00 
  404ffe:	c5 f9 6f 35 2a 21 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x212a]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  405005:	00 
  405006:	30 d2                	xor    dl,dl
  405008:	48 89 de             	mov    rsi,rbx
  40500b:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  40500f:	c5 f9 7f a4 24 80 00 	vmovdqa XMMWORD PTR [rsp+0x80],xmm4
  405016:	00 00 
  405018:	c5 f9 7f 74 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm6
  40501e:	48 29 d6             	sub    rsi,rdx
  405021:	0f 84 95 03 00 00    	je     4053bc <chainhash_wide256.constprop.0+0x41c>
  405027:	49 c1 e0 08          	shl    r8,0x8
  40502b:	4a 8d 0c 07          	lea    rcx,[rdi+r8*1]
  40502f:	48 81 fe ff 00 00 00 	cmp    rsi,0xff
  405036:	0f 87 89 04 00 00    	ja     4054c5 <chainhash_wide256.constprop.0+0x525>
  40503c:	48 83 fe 3f          	cmp    rsi,0x3f
  405040:	0f 86 34 06 00 00    	jbe    40567a <chainhash_wide256.constprop.0+0x6da>
  405046:	c5 d1 ef ed          	vpxor  xmm5,xmm5,xmm5
  40504a:	b8 40 00 00 00       	mov    eax,0x40
  40504f:	c5 f9 6f e5          	vmovdqa xmm4,xmm5
  405053:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  405058:	c5 fa 6f 74 01 c0    	vmovdqu xmm6,XMMWORD PTR [rcx+rax*1-0x40]
  40505e:	c5 c9 ef 80 60 90 40 	vpxor  xmm0,xmm6,XMMWORD PTR [rax+0x409060]
  405065:	00 
  405066:	49 89 c5             	mov    r13,rax
  405069:	c5 fa 6f 74 01 d0    	vmovdqu xmm6,XMMWORD PTR [rcx+rax*1-0x30]
  40506f:	c5 c9 ef 90 70 90 40 	vpxor  xmm2,xmm6,XMMWORD PTR [rax+0x409070]
  405076:	00 
  405077:	c5 fa 6f 74 01 e0    	vmovdqu xmm6,XMMWORD PTR [rcx+rax*1-0x20]
  40507d:	c4 e3 79 44 da 11    	vpclmulhqhqdq xmm3,xmm0,xmm2
  405083:	c4 e3 79 44 d2 00    	vpclmullqlqdq xmm2,xmm0,xmm2
  405089:	c5 c9 ef 80 80 90 40 	vpxor  xmm0,xmm6,XMMWORD PTR [rax+0x409080]
  405090:	00 
  405091:	c5 fa 6f 74 01 f0    	vmovdqu xmm6,XMMWORD PTR [rcx+rax*1-0x10]
  405097:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  40509b:	c5 c9 ef 98 90 90 40 	vpxor  xmm3,xmm6,XMMWORD PTR [rax+0x409090]
  4050a2:	00 
  4050a3:	48 8d 40 40          	lea    rax,[rax+0x40]
  4050a7:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  4050ab:	c4 e3 79 44 f3 11    	vpclmulhqhqdq xmm6,xmm0,xmm3
  4050b1:	c4 e3 79 44 c3 00    	vpclmullqlqdq xmm0,xmm0,xmm3
  4050b7:	c5 f9 6f e2          	vmovdqa xmm4,xmm2
  4050bb:	c5 f9 ef c6          	vpxor  xmm0,xmm0,xmm6
  4050bf:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  4050c3:	c5 f9 6f e8          	vmovdqa xmm5,xmm0
  4050c7:	48 39 c6             	cmp    rsi,rax
  4050ca:	73 8c                	jae    405058 <chainhash_wide256.constprop.0+0xb8>
  4050cc:	49 8d 45 20          	lea    rax,[r13+0x20]
  4050d0:	48 39 c6             	cmp    rsi,rax
  4050d3:	72 36                	jb     40510b <chainhash_wide256.constprop.0+0x16b>
  4050d5:	4a 8d 14 29          	lea    rdx,[rcx+r13*1]
  4050d9:	c5 fa 6f 22          	vmovdqu xmm4,XMMWORD PTR [rdx]
  4050dd:	c4 c1 59 ef 9d a0 90 	vpxor  xmm3,xmm4,XMMWORD PTR [r13+0x4090a0]
  4050e4:	40 00 
  4050e6:	c5 fa 6f 62 10       	vmovdqu xmm4,XMMWORD PTR [rdx+0x10]
  4050eb:	c4 c1 59 ef a5 b0 90 	vpxor  xmm4,xmm4,XMMWORD PTR [r13+0x4090b0]
  4050f2:	40 00 
  4050f4:	49 89 c5             	mov    r13,rax
  4050f7:	c4 e3 61 44 ec 11    	vpclmulhqhqdq xmm5,xmm3,xmm4
  4050fd:	c4 e3 61 44 dc 00    	vpclmullqlqdq xmm3,xmm3,xmm4
  405103:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  405107:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  40510b:	4c 39 ee             	cmp    rsi,r13
  40510e:	0f 87 b3 04 00 00    	ja     4055c7 <chainhash_wide256.constprop.0+0x627>
  405114:	c5 f8 77             	vzeroupper 
  405117:	c5 e9 ef d8          	vpxor  xmm3,xmm2,xmm0
  40511b:	e9 9f 02 00 00       	jmp    4053bf <chainhash_wide256.constprop.0+0x41f>
  405120:	c5 7d 6f 35 78 3f 00 	vmovdqa ymm14,YMMWORD PTR [rip+0x3f78]        # 4090a0 <shipped>
  405127:	00 
  405128:	c5 7d 6f 2d 90 3f 00 	vmovdqa ymm13,YMMWORD PTR [rip+0x3f90]        # 4090c0 <shipped+0x20>
  40512f:	00 
  405130:	c5 8d ef 07          	vpxor  ymm0,ymm14,YMMWORD PTR [rdi]
  405134:	c5 95 ef 57 20       	vpxor  ymm2,ymm13,YMMWORD PTR [rdi+0x20]
  405139:	c5 7d 6f 25 9f 3f 00 	vmovdqa ymm12,YMMWORD PTR [rip+0x3f9f]        # 4090e0 <shipped+0x40>
  405140:	00 
  405141:	c5 7d 6f 1d b7 3f 00 	vmovdqa ymm11,YMMWORD PTR [rip+0x3fb7]        # 409100 <shipped+0x60>
  405148:	00 
  405149:	c4 e3 7d 46 e2 20    	vperm2i128 ymm4,ymm0,ymm2,0x20
  40514f:	c4 e3 7d 46 c2 31    	vperm2i128 ymm0,ymm0,ymm2,0x31
  405155:	c5 9d ef 57 40       	vpxor  ymm2,ymm12,YMMWORD PTR [rdi+0x40]
  40515a:	c5 fd 6f 3d de 3f 00 	vmovdqa ymm7,YMMWORD PTR [rip+0x3fde]        # 409140 <shipped+0xa0>
  405161:	00 
  405162:	c4 e3 5d 44 f0 11    	vpclmulhqhqdq ymm6,ymm4,ymm0
  405168:	c5 7d 6f 15 b0 3f 00 	vmovdqa ymm10,YMMWORD PTR [rip+0x3fb0]        # 409120 <shipped+0x80>
  40516f:	00 
  405170:	c4 e3 5d 44 e0 00    	vpclmullqlqdq ymm4,ymm4,ymm0
  405176:	c5 a5 ef 47 60       	vpxor  ymm0,ymm11,YMMWORD PTR [rdi+0x60]
  40517b:	c5 fd 7f 3c 24       	vmovdqa YMMWORD PTR [rsp],ymm7
  405180:	c5 c5 ef bf a0 00 00 	vpxor  ymm7,ymm7,YMMWORD PTR [rdi+0xa0]
  405187:	00 
  405188:	c4 e3 6d 46 e8 20    	vperm2i128 ymm5,ymm2,ymm0,0x20
  40518e:	c4 e3 6d 46 d0 31    	vperm2i128 ymm2,ymm2,ymm0,0x31
  405194:	c4 e3 55 44 c2 11    	vpclmulhqhqdq ymm0,ymm5,ymm2
  40519a:	c4 e3 55 44 ea 00    	vpclmullqlqdq ymm5,ymm5,ymm2
  4051a0:	c5 ad ef 97 80 00 00 	vpxor  ymm2,ymm10,YMMWORD PTR [rdi+0x80]
  4051a7:	00 
  4051a8:	c4 e3 6d 46 df 20    	vperm2i128 ymm3,ymm2,ymm7,0x20
  4051ae:	c4 e3 6d 46 d7 31    	vperm2i128 ymm2,ymm2,ymm7,0x31
  4051b4:	c5 fd 6f 3d a4 3f 00 	vmovdqa ymm7,YMMWORD PTR [rip+0x3fa4]        # 409160 <shipped+0xc0>
  4051bb:	00 
  4051bc:	c5 cd ef f4          	vpxor  ymm6,ymm6,ymm4
  4051c0:	c4 63 65 44 c2 11    	vpclmulhqhqdq ymm8,ymm3,ymm2
  4051c6:	c4 63 65 44 ca 00    	vpclmullqlqdq ymm9,ymm3,ymm2
  4051cc:	c5 fd 7f 7c 24 40    	vmovdqa YMMWORD PTR [rsp+0x40],ymm7
  4051d2:	c5 c5 ef 9f c0 00 00 	vpxor  ymm3,ymm7,YMMWORD PTR [rdi+0xc0]
  4051d9:	00 
  4051da:	c5 fd 6f 3d 9e 3f 00 	vmovdqa ymm7,YMMWORD PTR [rip+0x3f9e]        # 409180 <shipped+0xe0>
  4051e1:	00 
  4051e2:	c5 fd 7f 7c 24 20    	vmovdqa YMMWORD PTR [rsp+0x20],ymm7
  4051e8:	c5 c5 ef bf e0 00 00 	vpxor  ymm7,ymm7,YMMWORD PTR [rdi+0xe0]
  4051ef:	00 
  4051f0:	c5 fd ef c5          	vpxor  ymm0,ymm0,ymm5
  4051f4:	c5 fd ef c6          	vpxor  ymm0,ymm0,ymm6
  4051f8:	c4 e3 65 46 d7 20    	vperm2i128 ymm2,ymm3,ymm7,0x20
  4051fe:	c4 e3 65 46 df 31    	vperm2i128 ymm3,ymm3,ymm7,0x31
  405204:	c4 e3 6d 44 fb 11    	vpclmulhqhqdq ymm7,ymm2,ymm3
  40520a:	c4 e3 6d 44 d3 00    	vpclmullqlqdq ymm2,ymm2,ymm3
  405210:	c4 41 3d ef c1       	vpxor  ymm8,ymm8,ymm9
  405215:	c4 c1 7d ef c0       	vpxor  ymm0,ymm0,ymm8
  40521a:	c5 ed ef d7          	vpxor  ymm2,ymm2,ymm7
  40521e:	c5 fd ef d2          	vpxor  ymm2,ymm0,ymm2
  405222:	c4 e3 7d 39 d0 01    	vextracti128 xmm0,ymm2,0x1
  405228:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  40522c:	c5 f9 ef 84 24 90 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rsp+0x90]
  405233:	00 00 
  405235:	49 83 f8 01          	cmp    r8,0x1
  405239:	0f 86 17 04 00 00    	jbe    405656 <chainhash_wide256.constprop.0+0x6b6>
  40523f:	c5 f9 6f 35 d9 1e 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x1ed9]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  405246:	00 
  405247:	c5 f9 6f 25 e1 1e 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x1ee1]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  40524e:	00 
  40524f:	4c 89 c1             	mov    rcx,r8
  405252:	48 8d 87 00 01 00 00 	lea    rax,[rdi+0x100]
  405259:	48 c1 e1 08          	shl    rcx,0x8
  40525d:	48 01 f9             	add    rcx,rdi
  405260:	c5 f9 7f 64 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm4
  405266:	c5 f9 7f b4 24 80 00 	vmovdqa XMMWORD PTR [rsp+0x80],xmm6
  40526d:	00 00 
  40526f:	90                   	nop
  405270:	c5 95 ef 50 20       	vpxor  ymm2,ymm13,YMMWORD PTR [rax+0x20]
  405275:	c4 e3 79 44 c9 01    	vpclmulhqlqdq xmm1,xmm0,xmm1
  40527b:	c5 f9 6f f0          	vmovdqa xmm6,xmm0
  40527f:	c5 fd 6f 3c 24       	vmovdqa ymm7,YMMWORD PTR [rsp]
  405284:	c5 8d ef 00          	vpxor  ymm0,ymm14,YMMWORD PTR [rax]
  405288:	c5 a5 ef 58 60       	vpxor  ymm3,ymm11,YMMWORD PTR [rax+0x60]
  40528d:	48 05 00 01 00 00    	add    rax,0x100
  405293:	c5 c5 ef 68 a0       	vpxor  ymm5,ymm7,YMMWORD PTR [rax-0x60]
  405298:	c4 e3 7d 46 e2 20    	vperm2i128 ymm4,ymm0,ymm2,0x20
  40529e:	c4 e3 7d 46 c2 31    	vperm2i128 ymm0,ymm0,ymm2,0x31
  4052a4:	c4 63 5d 44 c0 11    	vpclmulhqhqdq ymm8,ymm4,ymm0
  4052aa:	c4 e3 5d 44 e0 00    	vpclmullqlqdq ymm4,ymm4,ymm0
  4052b0:	c5 9d ef 80 40 ff ff 	vpxor  ymm0,ymm12,YMMWORD PTR [rax-0xc0]
  4052b7:	ff 
  4052b8:	c4 e3 7d 46 d3 20    	vperm2i128 ymm2,ymm0,ymm3,0x20
  4052be:	c4 e3 7d 46 c3 31    	vperm2i128 ymm0,ymm0,ymm3,0x31
  4052c4:	c5 ad ef 58 80       	vpxor  ymm3,ymm10,YMMWORD PTR [rax-0x80]
  4052c9:	c4 63 6d 44 c8 11    	vpclmulhqhqdq ymm9,ymm2,ymm0
  4052cf:	c4 e3 6d 44 d0 00    	vpclmullqlqdq ymm2,ymm2,ymm0
  4052d5:	c4 e3 65 46 c5 20    	vperm2i128 ymm0,ymm3,ymm5,0x20
  4052db:	c4 e3 65 46 dd 31    	vperm2i128 ymm3,ymm3,ymm5,0x31
  4052e1:	c5 fd 6f 6c 24 40    	vmovdqa ymm5,YMMWORD PTR [rsp+0x40]
  4052e7:	c4 e3 7d 44 fb 11    	vpclmulhqhqdq ymm7,ymm0,ymm3
  4052ed:	c5 d5 ef 68 c0       	vpxor  ymm5,ymm5,YMMWORD PTR [rax-0x40]
  4052f2:	c4 e3 7d 44 c3 00    	vpclmullqlqdq ymm0,ymm0,ymm3
  4052f8:	c5 fd 6f 5c 24 20    	vmovdqa ymm3,YMMWORD PTR [rsp+0x20]
  4052fe:	c5 65 ef 78 e0       	vpxor  ymm15,ymm3,YMMWORD PTR [rax-0x20]
  405303:	c4 c1 5d ef e0       	vpxor  ymm4,ymm4,ymm8
  405308:	c4 c3 55 46 df 20    	vperm2i128 ymm3,ymm5,ymm15,0x20
  40530e:	c4 c3 55 46 ef 31    	vperm2i128 ymm5,ymm5,ymm15,0x31
  405314:	c4 63 65 44 fd 11    	vpclmulhqhqdq ymm15,ymm3,ymm5
  40531a:	c4 e3 65 44 dd 00    	vpclmullqlqdq ymm3,ymm3,ymm5
  405320:	c4 c1 6d ef d1       	vpxor  ymm2,ymm2,ymm9
  405325:	c5 ed ef d4          	vpxor  ymm2,ymm2,ymm4
  405329:	c5 fd ef c7          	vpxor  ymm0,ymm0,ymm7
  40532d:	c5 f9 6f 7c 24 70    	vmovdqa xmm7,XMMWORD PTR [rsp+0x70]
  405333:	c5 ed ef c0          	vpxor  ymm0,ymm2,ymm0
  405337:	c4 c1 65 ef df       	vpxor  ymm3,ymm3,ymm15
  40533c:	c5 fd ef c3          	vpxor  ymm0,ymm0,ymm3
  405340:	c4 e3 7d 39 c2 01    	vextracti128 xmm2,ymm0,0x1
  405346:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  40534a:	c4 e3 71 44 94 24 80 	vpclmulhqlqdq xmm2,xmm1,XMMWORD PTR [rsp+0x80]
  405351:	00 00 00 01 
  405355:	c5 f1 ef ce          	vpxor  xmm1,xmm1,xmm6
  405359:	c5 f9 ef 84 24 90 00 	vpxor  xmm0,xmm0,XMMWORD PTR [rsp+0x90]
  405360:	00 00 
  405362:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  405367:	c4 e2 41 00 db       	vpshufb xmm3,xmm7,xmm3
  40536c:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  405370:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  405374:	48 39 c1             	cmp    rcx,rax
  405377:	0f 85 f3 fe ff ff    	jne    405270 <chainhash_wide256.constprop.0+0x2d0>
  40537d:	c4 e3 79 44 c9 01    	vpclmulhqlqdq xmm1,xmm0,xmm1
  405383:	c5 f9 6f 64 24 70    	vmovdqa xmm4,XMMWORD PTR [rsp+0x70]
  405389:	30 d2                	xor    dl,dl
  40538b:	48 89 de             	mov    rsi,rbx
  40538e:	c4 e3 71 44 94 24 80 	vpclmulhqlqdq xmm2,xmm1,XMMWORD PTR [rsp+0x80]
  405395:	00 00 00 01 
  405399:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  40539d:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  4053a2:	c4 e2 59 00 db       	vpshufb xmm3,xmm4,xmm3
  4053a7:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  4053ab:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  4053af:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  4053b3:	48 29 d6             	sub    rsi,rdx
  4053b6:	0f 85 6b fc ff ff    	jne    405027 <chainhash_wide256.constprop.0+0x87>
  4053bc:	c5 f8 77             	vzeroupper 
  4053bf:	c4 e1 f9 6e f3       	vmovq  xmm6,rbx
  4053c4:	c4 c1 f9 6e d4       	vmovq  xmm2,r12
  4053c9:	c5 e9 ef 94 24 90 00 	vpxor  xmm2,xmm2,XMMWORD PTR [rsp+0x90]
  4053d0:	00 00 
  4053d2:	c5 f9 6f 7c 24 70    	vmovdqa xmm7,XMMWORD PTR [rsp+0x70]
  4053d8:	c5 c9 6c c6          	vpunpcklqdq xmm0,xmm6,xmm6
  4053dc:	48 8b 05 d5 3d 00 00 	mov    rax,QWORD PTR [rip+0x3dd5]        # 4091b8 <shipped+0x118>
  4053e3:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  4053e7:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  4053eb:	c4 e3 69 44 c9 01    	vpclmulhqlqdq xmm1,xmm2,xmm1
  4053f1:	c4 e3 71 44 84 24 80 	vpclmulhqlqdq xmm0,xmm1,XMMWORD PTR [rsp+0x80]
  4053f8:	00 00 00 01 
  4053fc:	c5 e1 73 d8 08       	vpsrldq xmm3,xmm0,0x8
  405401:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  405405:	c4 e2 41 00 db       	vpshufb xmm3,xmm7,xmm3
  40540a:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  40540e:	c5 f9 6f 1d fa 1c 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x1cfa]        # 407110 <__PRETTY_FUNCTION__.6+0x20>
  405415:	00 
  405416:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  40541a:	c5 fa 7e 0d be 3d 00 	vmovq  xmm1,QWORD PTR [rip+0x3dbe]        # 4091e0 <shipped+0x140>
  405421:	00 
  405422:	c5 f9 d4 c1          	vpaddq xmm0,xmm0,xmm1
  405426:	c4 e3 79 44 c8 00    	vpclmullqlqdq xmm1,xmm0,xmm0
  40542c:	c4 e3 71 44 d3 11    	vpclmulhqhqdq xmm2,xmm1,xmm3
  405432:	c4 e3 69 44 e3 11    	vpclmulhqhqdq xmm4,xmm2,xmm3
  405438:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  40543c:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  405441:	48 33 05 78 3d 00 00 	xor    rax,QWORD PTR [rip+0x3d78]        # 4091c0 <shipped+0x120>
  405448:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  40544c:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  405450:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  405455:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  405459:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  40545d:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  405463:	c5 fa 7e 15 5d 3d 00 	vmovq  xmm2,QWORD PTR [rip+0x3d5d]        # 4091c8 <shipped+0x128>
  40546a:	00 
  40546b:	c4 e3 71 44 e3 11    	vpclmulhqhqdq xmm4,xmm1,xmm3
  405471:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  405475:	c5 fa 7e 15 53 3d 00 	vmovq  xmm2,QWORD PTR [rip+0x3d53]        # 4091d0 <shipped+0x130>
  40547c:	00 
  40547d:	c4 e3 59 44 eb 11    	vpclmulhqhqdq xmm5,xmm4,xmm3
  405483:	c5 f1 ef cc          	vpxor  xmm1,xmm1,xmm4
  405487:	c5 e9 ef d5          	vpxor  xmm2,xmm2,xmm5
  40548b:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  40548f:	c5 fa 7e 15 41 3d 00 	vmovq  xmm2,QWORD PTR [rip+0x3d41]        # 4091d8 <shipped+0x138>
  405496:	00 
  405497:	48 8d 65 e8          	lea    rsp,[rbp-0x18]
  40549b:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
  4054a1:	5b                   	pop    rbx
  4054a2:	41 5c                	pop    r12
  4054a4:	c4 e3 79 44 e3 11    	vpclmulhqhqdq xmm4,xmm0,xmm3
  4054aa:	41 5d                	pop    r13
  4054ac:	5d                   	pop    rbp
  4054ad:	c4 e3 59 44 cb 11    	vpclmulhqhqdq xmm1,xmm4,xmm3
  4054b3:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
  4054b7:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  4054bb:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  4054bf:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  4054c4:	c3                   	ret    
  4054c5:	c5 fe 6f 31          	vmovdqu ymm6,YMMWORD PTR [rcx]
  4054c9:	c5 cd ef 15 cf 3b 00 	vpxor  ymm2,ymm6,YMMWORD PTR [rip+0x3bcf]        # 4090a0 <shipped>
  4054d0:	00 
  4054d1:	c5 fe 6f 71 20       	vmovdqu ymm6,YMMWORD PTR [rcx+0x20]
  4054d6:	c5 cd ef 1d e2 3b 00 	vpxor  ymm3,ymm6,YMMWORD PTR [rip+0x3be2]        # 4090c0 <shipped+0x20>
  4054dd:	00 
  4054de:	c5 fe 6f 71 40       	vmovdqu ymm6,YMMWORD PTR [rcx+0x40]
  4054e3:	c5 fe 6f b9 80 00 00 	vmovdqu ymm7,YMMWORD PTR [rcx+0x80]
  4054ea:	00 
  4054eb:	c4 e3 6d 46 c3 20    	vperm2i128 ymm0,ymm2,ymm3,0x20
  4054f1:	c4 e3 6d 46 d3 31    	vperm2i128 ymm2,ymm2,ymm3,0x31
  4054f7:	c4 e3 7d 44 e2 11    	vpclmulhqhqdq ymm4,ymm0,ymm2
  4054fd:	c4 e3 7d 44 c2 00    	vpclmullqlqdq ymm0,ymm0,ymm2
  405503:	c5 cd ef 15 d5 3b 00 	vpxor  ymm2,ymm6,YMMWORD PTR [rip+0x3bd5]        # 4090e0 <shipped+0x40>
  40550a:	00 
  40550b:	c5 fe 6f 71 60       	vmovdqu ymm6,YMMWORD PTR [rcx+0x60]
  405510:	c5 cd ef 1d e8 3b 00 	vpxor  ymm3,ymm6,YMMWORD PTR [rip+0x3be8]        # 409100 <shipped+0x60>
  405517:	00 
  405518:	c4 e3 6d 46 f3 20    	vperm2i128 ymm6,ymm2,ymm3,0x20
  40551e:	c4 e3 6d 46 d3 31    	vperm2i128 ymm2,ymm2,ymm3,0x31
  405524:	c4 e3 4d 44 ea 11    	vpclmulhqhqdq ymm5,ymm6,ymm2
  40552a:	c4 e3 4d 44 f2 00    	vpclmullqlqdq ymm6,ymm6,ymm2
  405530:	c5 c5 ef 15 e8 3b 00 	vpxor  ymm2,ymm7,YMMWORD PTR [rip+0x3be8]        # 409120 <shipped+0x80>
  405537:	00 
  405538:	c5 fe 6f b9 a0 00 00 	vmovdqu ymm7,YMMWORD PTR [rcx+0xa0]
  40553f:	00 
  405540:	c5 c5 ef 1d f8 3b 00 	vpxor  ymm3,ymm7,YMMWORD PTR [rip+0x3bf8]        # 409140 <shipped+0xa0>
  405547:	00 
  405548:	c5 fd ef c4          	vpxor  ymm0,ymm0,ymm4
  40554c:	c4 63 6d 46 c3 20    	vperm2i128 ymm8,ymm2,ymm3,0x20
  405552:	c4 e3 6d 46 d3 31    	vperm2i128 ymm2,ymm2,ymm3,0x31
  405558:	c5 fe 6f 99 c0 00 00 	vmovdqu ymm3,YMMWORD PTR [rcx+0xc0]
  40555f:	00 
  405560:	c4 e3 3d 44 fa 11    	vpclmulhqhqdq ymm7,ymm8,ymm2
  405566:	c4 63 3d 44 c2 00    	vpclmullqlqdq ymm8,ymm8,ymm2
  40556c:	c5 e5 ef 15 ec 3b 00 	vpxor  ymm2,ymm3,YMMWORD PTR [rip+0x3bec]        # 409160 <shipped+0xc0>
  405573:	00 
  405574:	c5 fe 6f 99 e0 00 00 	vmovdqu ymm3,YMMWORD PTR [rcx+0xe0]
  40557b:	00 
  40557c:	c5 e5 ef 1d fc 3b 00 	vpxor  ymm3,ymm3,YMMWORD PTR [rip+0x3bfc]        # 409180 <shipped+0xe0>
  405583:	00 
  405584:	c5 cd ef f5          	vpxor  ymm6,ymm6,ymm5
  405588:	c5 fd ef c6          	vpxor  ymm0,ymm0,ymm6
  40558c:	c4 63 6d 46 cb 20    	vperm2i128 ymm9,ymm2,ymm3,0x20
  405592:	c4 e3 6d 46 d3 31    	vperm2i128 ymm2,ymm2,ymm3,0x31
  405598:	c4 e3 35 44 da 11    	vpclmulhqhqdq ymm3,ymm9,ymm2
  40559e:	c4 e3 35 44 d2 00    	vpclmullqlqdq ymm2,ymm9,ymm2
  4055a4:	c5 3d ef c7          	vpxor  ymm8,ymm8,ymm7
  4055a8:	c4 c1 7d ef c0       	vpxor  ymm0,ymm0,ymm8
  4055ad:	c5 ed ef d3          	vpxor  ymm2,ymm2,ymm3
  4055b1:	c5 fd ef c2          	vpxor  ymm0,ymm0,ymm2
  4055b5:	c4 e3 7d 39 c2 01    	vextracti128 xmm2,ymm0,0x1
  4055bb:	c5 e9 ef d8          	vpxor  xmm3,xmm2,xmm0
  4055bf:	c5 f8 77             	vzeroupper 
  4055c2:	e9 f8 fd ff ff       	jmp    4053bf <chainhash_wide256.constprop.0+0x41f>
  4055c7:	48 89 f2             	mov    rdx,rsi
  4055ca:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  4055ce:	4a 8d 34 29          	lea    rsi,[rcx+r13*1]
  4055d2:	c5 f9 7f 04 24       	vmovdqa XMMWORD PTR [rsp],xmm0
  4055d7:	4c 29 ea             	sub    rdx,r13
  4055da:	48 8d bc 24 a0 00 00 	lea    rdi,[rsp+0xa0]
  4055e1:	00 
  4055e2:	c5 f9 7f 54 24 20    	vmovdqa XMMWORD PTR [rsp+0x20],xmm2
  4055e8:	c5 f9 7f 4c 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm1
  4055ee:	c5 f9 7f 9c 24 a0 00 	vmovdqa XMMWORD PTR [rsp+0xa0],xmm3
  4055f5:	00 00 
  4055f7:	c5 f9 7f 9c 24 b0 00 	vmovdqa XMMWORD PTR [rsp+0xb0],xmm3
  4055fe:	00 00 
  405600:	c5 f8 77             	vzeroupper 
  405603:	e8 68 ba ff ff       	call   401070 <memcpy@plt>
  405608:	c5 f9 6f 04 24       	vmovdqa xmm0,XMMWORD PTR [rsp]
  40560d:	c5 f9 6f a4 24 a0 00 	vmovdqa xmm4,XMMWORD PTR [rsp+0xa0]
  405614:	00 00 
  405616:	c4 c1 59 ef 9d a0 90 	vpxor  xmm3,xmm4,XMMWORD PTR [r13+0x4090a0]
  40561d:	40 00 
  40561f:	c5 f9 6f 54 24 20    	vmovdqa xmm2,XMMWORD PTR [rsp+0x20]
  405625:	c5 f9 6f a4 24 b0 00 	vmovdqa xmm4,XMMWORD PTR [rsp+0xb0]
  40562c:	00 00 
  40562e:	c5 f9 6f 4c 24 40    	vmovdqa xmm1,XMMWORD PTR [rsp+0x40]
  405634:	c4 c1 59 ef a5 b0 90 	vpxor  xmm4,xmm4,XMMWORD PTR [r13+0x4090b0]
  40563b:	40 00 
  40563d:	c4 e3 61 44 ec 11    	vpclmulhqhqdq xmm5,xmm3,xmm4
  405643:	c4 e3 61 44 dc 00    	vpclmullqlqdq xmm3,xmm3,xmm4
  405649:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  40564d:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  405651:	e9 c1 fa ff ff       	jmp    405117 <chainhash_wide256.constprop.0+0x177>
  405656:	c5 f9 6f 25 c2 1a 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x1ac2]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  40565d:	00 
  40565e:	c5 f9 6f 35 ca 1a 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x1aca]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  405665:	00 
  405666:	c5 f9 7f a4 24 80 00 	vmovdqa XMMWORD PTR [rsp+0x80],xmm4
  40566d:	00 00 
  40566f:	c5 f9 7f 74 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm6
  405675:	e9 03 fd ff ff       	jmp    40537d <chainhash_wide256.constprop.0+0x3dd>
  40567a:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  40567e:	b8 20 00 00 00       	mov    eax,0x20
  405683:	45 31 ed             	xor    r13d,r13d
  405686:	c5 f9 6f d0          	vmovdqa xmm2,xmm0
  40568a:	e9 41 fa ff ff       	jmp    4050d0 <chainhash_wide256.constprop.0+0x130>
  40568f:	90                   	nop

0000000000405690 <chainhash_wide512.constprop.0>:
  405690:	55                   	push   rbp
  405691:	48 8d 56 ff          	lea    rdx,[rsi-0x1]
  405695:	49 89 d0             	mov    r8,rdx
  405698:	49 c1 e8 08          	shr    r8,0x8
  40569c:	48 89 e5             	mov    rbp,rsp
  40569f:	41 55                	push   r13
  4056a1:	41 54                	push   r12
  4056a3:	53                   	push   rbx
  4056a4:	48 89 f3             	mov    rbx,rsi
  4056a7:	48 83 e4 c0          	and    rsp,0xffffffffffffffc0
  4056ab:	48 83 c4 80          	add    rsp,0xffffffffffffff80
  4056af:	4c 8b 25 ea 3a 00 00 	mov    r12,QWORD PTR [rip+0x3aea]        # 4091a0 <shipped+0x100>
  4056b6:	48 8b 05 f3 3a 00 00 	mov    rax,QWORD PTR [rip+0x3af3]        # 4091b0 <shipped+0x110>
  4056bd:	c5 f9 6f 35 db 3a 00 	vmovdqa xmm6,XMMWORD PTR [rip+0x3adb]        # 4091a0 <shipped+0x100>
  4056c4:	00 
  4056c5:	4c 31 e0             	xor    rax,r12
  4056c8:	c4 e1 f9 6e c0       	vmovq  xmm0,rax
  4056cd:	48 81 fa ff 00 00 00 	cmp    rdx,0xff
  4056d4:	0f 87 26 01 00 00    	ja     405800 <chainhash_wide512.constprop.0+0x170>
  4056da:	30 d2                	xor    dl,dl
  4056dc:	48 89 de             	mov    rsi,rbx
  4056df:	c5 f9 6f 25 39 1a 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x1a39]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  4056e6:	00 
  4056e7:	c5 f9 6f 2d 41 1a 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x1a41]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  4056ee:	00 
  4056ef:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  4056f3:	48 29 d6             	sub    rsi,rdx
  4056f6:	0f 84 db 02 00 00    	je     4059d7 <chainhash_wide512.constprop.0+0x347>
  4056fc:	49 c1 e0 08          	shl    r8,0x8
  405700:	4a 8d 0c 07          	lea    rcx,[rdi+r8*1]
  405704:	48 81 fe ff 00 00 00 	cmp    rsi,0xff
  40570b:	0f 87 bf 03 00 00    	ja     405ad0 <chainhash_wide512.constprop.0+0x440>
  405711:	48 83 fe 3f          	cmp    rsi,0x3f
  405715:	0f 86 19 05 00 00    	jbe    405c34 <chainhash_wide512.constprop.0+0x5a4>
  40571b:	c4 41 39 ef c0       	vpxor  xmm8,xmm8,xmm8
  405720:	b8 40 00 00 00       	mov    eax,0x40
  405725:	c5 79 7f c7          	vmovdqa xmm7,xmm8
  405729:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  405730:	c5 fa 6f 5c 01 c0    	vmovdqu xmm3,XMMWORD PTR [rcx+rax*1-0x40]
  405736:	c5 e1 ef 88 60 90 40 	vpxor  xmm1,xmm3,XMMWORD PTR [rax+0x409060]
  40573d:	00 
  40573e:	49 89 c5             	mov    r13,rax
  405741:	c5 fa 6f 5c 01 d0    	vmovdqu xmm3,XMMWORD PTR [rcx+rax*1-0x30]
  405747:	c5 e1 ef 90 70 90 40 	vpxor  xmm2,xmm3,XMMWORD PTR [rax+0x409070]
  40574e:	00 
  40574f:	c4 e3 71 44 da 11    	vpclmulhqhqdq xmm3,xmm1,xmm2
  405755:	c4 e3 71 44 d2 00    	vpclmullqlqdq xmm2,xmm1,xmm2
  40575b:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  40575f:	c5 fa 6f 5c 01 e0    	vmovdqu xmm3,XMMWORD PTR [rcx+rax*1-0x20]
  405765:	c5 e1 ef 88 80 90 40 	vpxor  xmm1,xmm3,XMMWORD PTR [rax+0x409080]
  40576c:	00 
  40576d:	c5 fa 6f 5c 01 f0    	vmovdqu xmm3,XMMWORD PTR [rcx+rax*1-0x10]
  405773:	c5 e9 ef d7          	vpxor  xmm2,xmm2,xmm7
  405777:	48 8d 40 40          	lea    rax,[rax+0x40]
  40577b:	c5 e1 ef 98 50 90 40 	vpxor  xmm3,xmm3,XMMWORD PTR [rax+0x409050]
  405782:	00 
  405783:	c5 f9 6f fa          	vmovdqa xmm7,xmm2
  405787:	c4 63 71 44 cb 11    	vpclmulhqhqdq xmm9,xmm1,xmm3
  40578d:	c4 e3 71 44 cb 00    	vpclmullqlqdq xmm1,xmm1,xmm3
  405793:	c4 c1 71 ef c9       	vpxor  xmm1,xmm1,xmm9
  405798:	c4 c1 71 ef c8       	vpxor  xmm1,xmm1,xmm8
  40579d:	c5 79 6f c1          	vmovdqa xmm8,xmm1
  4057a1:	48 39 c6             	cmp    rsi,rax
  4057a4:	73 8a                	jae    405730 <chainhash_wide512.constprop.0+0xa0>
  4057a6:	49 8d 45 20          	lea    rax,[r13+0x20]
  4057aa:	48 39 c6             	cmp    rsi,rax
  4057ad:	72 37                	jb     4057e6 <chainhash_wide512.constprop.0+0x156>
  4057af:	4a 8d 14 29          	lea    rdx,[rcx+r13*1]
  4057b3:	c5 fa 6f 3a          	vmovdqu xmm7,XMMWORD PTR [rdx]
  4057b7:	c4 c1 41 ef 9d a0 90 	vpxor  xmm3,xmm7,XMMWORD PTR [r13+0x4090a0]
  4057be:	40 00 
  4057c0:	c5 fa 6f 7a 10       	vmovdqu xmm7,XMMWORD PTR [rdx+0x10]
  4057c5:	c4 c1 41 ef bd b0 90 	vpxor  xmm7,xmm7,XMMWORD PTR [r13+0x4090b0]
  4057cc:	40 00 
  4057ce:	49 89 c5             	mov    r13,rax
  4057d1:	c4 63 61 44 c7 11    	vpclmulhqhqdq xmm8,xmm3,xmm7
  4057d7:	c4 e3 61 44 df 00    	vpclmullqlqdq xmm3,xmm3,xmm7
  4057dd:	c4 c1 61 ef d8       	vpxor  xmm3,xmm3,xmm8
  4057e2:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  4057e6:	4c 39 ee             	cmp    rsi,r13
  4057e9:	0f 87 8b 03 00 00    	ja     405b7a <chainhash_wide512.constprop.0+0x4ea>
  4057ef:	c5 f8 77             	vzeroupper 
  4057f2:	c5 e9 ef d9          	vpxor  xmm3,xmm2,xmm1
  4057f6:	e9 df 01 00 00       	jmp    4059da <chainhash_wide512.constprop.0+0x34a>
  4057fb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
  405800:	62 71 7e 48 6f 0d 96 	vmovdqu32 zmm9,ZMMWORD PTR [rip+0x3896]        # 4090a0 <shipped>
  405807:	38 00 00 
  40580a:	62 f1 7e 48 6f 2f    	vmovdqu32 zmm5,ZMMWORD PTR [rdi]
  405810:	62 71 7e 48 6f 15 c6 	vmovdqu32 zmm10,ZMMWORD PTR [rip+0x38c6]        # 4090e0 <shipped+0x40>
  405817:	38 00 00 
  40581a:	62 f1 7e 48 6f 67 02 	vmovdqu32 zmm4,ZMMWORD PTR [rdi+0x80]
  405821:	62 71 7e 48 6f 1d f5 	vmovdqu32 zmm11,ZMMWORD PTR [rip+0x38f5]        # 409120 <shipped+0x80>
  405828:	38 00 00 
  40582b:	62 d1 55 48 ef c9    	vpxord zmm1,zmm5,zmm9
  405831:	62 f1 7e 48 6f 6f 01 	vmovdqu32 zmm5,ZMMWORD PTR [rdi+0x40]
  405838:	62 71 7e 48 6f 25 1e 	vmovdqu32 zmm12,ZMMWORD PTR [rip+0x391e]        # 409160 <shipped+0xc0>
  40583f:	39 00 00 
  405842:	62 d1 55 48 ef da    	vpxord zmm3,zmm5,zmm10
  405848:	62 f3 f5 48 43 d3 88 	vshufi64x2 zmm2,zmm1,zmm3,0x88
  40584f:	62 f3 f5 48 43 cb dd 	vshufi64x2 zmm1,zmm1,zmm3,0xdd
  405856:	62 f3 6d 48 44 e9 11 	vpclmulhqhqdq zmm5,zmm2,zmm1
  40585d:	62 f3 6d 48 44 d9 00 	vpclmullqlqdq zmm3,zmm2,zmm1
  405864:	62 d1 5d 48 ef d3    	vpxord zmm2,zmm4,zmm11
  40586a:	62 f1 7e 48 6f 67 03 	vmovdqu32 zmm4,ZMMWORD PTR [rdi+0xc0]
  405871:	62 d1 5d 48 ef e4    	vpxord zmm4,zmm4,zmm12
  405877:	62 f3 ed 48 43 cc 88 	vshufi64x2 zmm1,zmm2,zmm4,0x88
  40587e:	62 f3 ed 48 43 d4 dd 	vshufi64x2 zmm2,zmm2,zmm4,0xdd
  405885:	62 f3 75 48 44 e2 11 	vpclmulhqhqdq zmm4,zmm1,zmm2
  40588c:	62 f3 75 48 44 ca 00 	vpclmullqlqdq zmm1,zmm1,zmm2
  405893:	62 f1 65 48 ef d5    	vpxord zmm2,zmm3,zmm5
  405899:	62 f1 75 48 ef cc    	vpxord zmm1,zmm1,zmm4
  40589f:	62 f1 75 48 ef ca    	vpxord zmm1,zmm1,zmm2
  4058a5:	62 f3 fd 48 3b ca 01 	vextracti64x4 ymm2,zmm1,0x1
  4058ac:	c5 ed ef c9          	vpxor  ymm1,ymm2,ymm1
  4058b0:	c4 e3 7d 39 cf 01    	vextracti128 xmm7,ymm1,0x1
  4058b6:	c5 c1 ef f9          	vpxor  xmm7,xmm7,xmm1
  4058ba:	c5 c1 ef fe          	vpxor  xmm7,xmm7,xmm6
  4058be:	49 83 f8 01          	cmp    r8,0x1
  4058c2:	0f 86 57 03 00 00    	jbe    405c1f <chainhash_wide512.constprop.0+0x58f>
  4058c8:	4c 89 c1             	mov    rcx,r8
  4058cb:	48 8d 87 00 01 00 00 	lea    rax,[rdi+0x100]
  4058d2:	c5 f9 6f 25 46 18 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x1846]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  4058d9:	00 
  4058da:	c5 f9 6f 2d 4e 18 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x184e]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  4058e1:	00 
  4058e2:	48 c1 e1 08          	shl    rcx,0x8
  4058e6:	48 01 f9             	add    rcx,rdi
  4058e9:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  4058f0:	c4 e3 41 44 d0 01    	vpclmulhqlqdq xmm2,xmm7,xmm0
  4058f6:	62 f1 35 48 ef 08    	vpxord zmm1,zmm9,ZMMWORD PTR [rax]
  4058fc:	c5 f9 6f df          	vmovdqa xmm3,xmm7
  405900:	48 05 00 01 00 00    	add    rax,0x100
  405906:	62 f1 2d 48 ef 78 fd 	vpxord zmm7,zmm10,ZMMWORD PTR [rax-0xc0]
  40590d:	62 71 1d 48 ef 40 ff 	vpxord zmm8,zmm12,ZMMWORD PTR [rax-0x40]
  405914:	62 f3 f5 48 43 c7 88 	vshufi64x2 zmm0,zmm1,zmm7,0x88
  40591b:	62 f3 f5 48 43 cf dd 	vshufi64x2 zmm1,zmm1,zmm7,0xdd
  405922:	62 f1 25 48 ef 78 fe 	vpxord zmm7,zmm11,ZMMWORD PTR [rax-0x80]
  405929:	62 73 7d 48 44 e9 11 	vpclmulhqhqdq zmm13,zmm0,zmm1
  405930:	62 f3 7d 48 44 c1 00 	vpclmullqlqdq zmm0,zmm0,zmm1
  405937:	62 d3 c5 48 43 c8 88 	vshufi64x2 zmm1,zmm7,zmm8,0x88
  40593e:	62 d3 c5 48 43 f8 dd 	vshufi64x2 zmm7,zmm7,zmm8,0xdd
  405945:	62 73 75 48 44 c7 11 	vpclmulhqhqdq zmm8,zmm1,zmm7
  40594c:	62 f3 75 48 44 cf 00 	vpclmullqlqdq zmm1,zmm1,zmm7
  405953:	62 d1 7d 48 ef c5    	vpxord zmm0,zmm0,zmm13
  405959:	62 d1 75 48 ef c8    	vpxord zmm1,zmm1,zmm8
  40595f:	62 f1 7d 48 ef c1    	vpxord zmm0,zmm0,zmm1
  405965:	62 f3 fd 48 3b c1 01 	vextracti64x4 ymm1,zmm0,0x1
  40596c:	c5 f5 ef c0          	vpxor  ymm0,ymm1,ymm0
  405970:	c4 e3 7d 39 c1 01    	vextracti128 xmm1,ymm0,0x1
  405976:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  40597a:	c5 f9 ef fe          	vpxor  xmm7,xmm0,xmm6
  40597e:	c4 e3 69 44 c4 01    	vpclmulhqlqdq xmm0,xmm2,xmm4
  405984:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  405988:	c5 f1 73 d8 08       	vpsrldq xmm1,xmm0,0x8
  40598d:	c4 e2 51 00 c9       	vpshufb xmm1,xmm5,xmm1
  405992:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  405996:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  40599a:	48 39 c1             	cmp    rcx,rax
  40599d:	0f 85 4d ff ff ff    	jne    4058f0 <chainhash_wide512.constprop.0+0x260>
  4059a3:	c4 e3 41 44 c0 01    	vpclmulhqlqdq xmm0,xmm7,xmm0
  4059a9:	30 d2                	xor    dl,dl
  4059ab:	48 89 de             	mov    rsi,rbx
  4059ae:	c4 e3 79 44 cc 01    	vpclmulhqlqdq xmm1,xmm0,xmm4
  4059b4:	c5 f9 ef c7          	vpxor  xmm0,xmm0,xmm7
  4059b8:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  4059bc:	c5 e9 73 d9 08       	vpsrldq xmm2,xmm1,0x8
  4059c1:	c4 e2 51 00 d2       	vpshufb xmm2,xmm5,xmm2
  4059c6:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4059ca:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  4059ce:	48 29 d6             	sub    rsi,rdx
  4059d1:	0f 85 25 fd ff ff    	jne    4056fc <chainhash_wide512.constprop.0+0x6c>
  4059d7:	c5 f8 77             	vzeroupper 
  4059da:	c4 c1 f9 6e cc       	vmovq  xmm1,r12
  4059df:	48 8b 05 d2 37 00 00 	mov    rax,QWORD PTR [rip+0x37d2]        # 4091b8 <shipped+0x118>
  4059e6:	c5 f1 ef ce          	vpxor  xmm1,xmm1,xmm6
  4059ea:	c4 e1 f9 6e f3       	vmovq  xmm6,rbx
  4059ef:	c5 c9 6c d6          	vpunpcklqdq xmm2,xmm6,xmm6
  4059f3:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  4059f7:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4059fb:	c4 e3 71 44 c0 01    	vpclmulhqlqdq xmm0,xmm1,xmm0
  405a01:	c4 e3 79 44 e4 01    	vpclmulhqlqdq xmm4,xmm0,xmm4
  405a07:	c5 e9 73 dc 08       	vpsrldq xmm2,xmm4,0x8
  405a0c:	c5 d9 ef e1          	vpxor  xmm4,xmm4,xmm1
  405a10:	c5 fa 7e 0d c8 37 00 	vmovq  xmm1,QWORD PTR [rip+0x37c8]        # 4091e0 <shipped+0x140>
  405a17:	00 
  405a18:	c4 e2 51 00 ea       	vpshufb xmm5,xmm5,xmm2
  405a1d:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  405a21:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
  405a25:	c5 fb 12 25 e3 16 00 	vmovddup xmm4,QWORD PTR [rip+0x16e3]        # 407110 <__PRETTY_FUNCTION__.6+0x20>
  405a2c:	00 
  405a2d:	c5 f9 d4 d9          	vpaddq xmm3,xmm0,xmm1
  405a31:	c4 e1 f9 6e c8       	vmovq  xmm1,rax
  405a36:	48 33 05 83 37 00 00 	xor    rax,QWORD PTR [rip+0x3783]        # 4091c0 <shipped+0x120>
  405a3d:	c4 e3 61 44 c3 00    	vpclmullqlqdq xmm0,xmm3,xmm3
  405a43:	c4 e3 79 44 d4 11    	vpclmulhqhqdq xmm2,xmm0,xmm4
  405a49:	c4 e3 69 44 ec 11    	vpclmulhqhqdq xmm5,xmm2,xmm4
  405a4f:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  405a53:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  405a58:	c5 f1 ef cd          	vpxor  xmm1,xmm1,xmm5
  405a5c:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  405a60:	c5 fa 7e 05 60 37 00 	vmovq  xmm0,QWORD PTR [rip+0x3760]        # 4091c8 <shipped+0x128>
  405a67:	00 
  405a68:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  405a6c:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  405a70:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  405a74:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  405a7a:	c5 fa 7e 15 4e 37 00 	vmovq  xmm2,QWORD PTR [rip+0x374e]        # 4091d0 <shipped+0x130>
  405a81:	00 
  405a82:	c4 e3 71 44 ec 11    	vpclmulhqhqdq xmm5,xmm1,xmm4
  405a88:	c4 e3 51 44 f4 11    	vpclmulhqhqdq xmm6,xmm5,xmm4
  405a8e:	c5 f1 ef cd          	vpxor  xmm1,xmm1,xmm5
  405a92:	c5 e9 ef d6          	vpxor  xmm2,xmm2,xmm6
  405a96:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  405a9a:	c5 fa 7e 15 36 37 00 	vmovq  xmm2,QWORD PTR [rip+0x3736]        # 4091d8 <shipped+0x138>
  405aa1:	00 
  405aa2:	48 8d 65 e8          	lea    rsp,[rbp-0x18]
  405aa6:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
  405aac:	5b                   	pop    rbx
  405aad:	41 5c                	pop    r12
  405aaf:	c4 e3 79 44 dc 11    	vpclmulhqhqdq xmm3,xmm0,xmm4
  405ab5:	41 5d                	pop    r13
  405ab7:	5d                   	pop    rbp
  405ab8:	c4 e3 61 44 cc 11    	vpclmulhqhqdq xmm1,xmm3,xmm4
  405abe:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  405ac2:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  405ac6:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  405aca:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  405acf:	c3                   	ret    
  405ad0:	62 f1 7e 48 6f 39    	vmovdqu32 zmm7,ZMMWORD PTR [rcx]
  405ad6:	62 f1 45 48 ef 15 c0 	vpxord zmm2,zmm7,ZMMWORD PTR [rip+0x35c0]        # 4090a0 <shipped>
  405add:	35 00 00 
  405ae0:	62 f1 7e 48 6f 79 01 	vmovdqu32 zmm7,ZMMWORD PTR [rcx+0x40]
  405ae7:	62 f1 45 48 ef 1d ef 	vpxord zmm3,zmm7,ZMMWORD PTR [rip+0x35ef]        # 4090e0 <shipped+0x40>
  405aee:	35 00 00 
  405af1:	62 f1 7e 48 6f 79 02 	vmovdqu32 zmm7,ZMMWORD PTR [rcx+0x80]
  405af8:	62 f3 ed 48 43 cb 88 	vshufi64x2 zmm1,zmm2,zmm3,0x88
  405aff:	62 f3 ed 48 43 d3 dd 	vshufi64x2 zmm2,zmm2,zmm3,0xdd
  405b06:	62 73 75 48 44 c2 11 	vpclmulhqhqdq zmm8,zmm1,zmm2
  405b0d:	62 f3 75 48 44 ca 00 	vpclmullqlqdq zmm1,zmm1,zmm2
  405b14:	62 f1 45 48 ef 15 02 	vpxord zmm2,zmm7,ZMMWORD PTR [rip+0x3602]        # 409120 <shipped+0x80>
  405b1b:	36 00 00 
  405b1e:	62 f1 7e 48 6f 79 03 	vmovdqu32 zmm7,ZMMWORD PTR [rcx+0xc0]
  405b25:	62 f1 45 48 ef 3d 31 	vpxord zmm7,zmm7,ZMMWORD PTR [rip+0x3631]        # 409160 <shipped+0xc0>
  405b2c:	36 00 00 
  405b2f:	62 f3 ed 48 43 df 88 	vshufi64x2 zmm3,zmm2,zmm7,0x88
  405b36:	62 f3 ed 48 43 d7 dd 	vshufi64x2 zmm2,zmm2,zmm7,0xdd
  405b3d:	62 f3 65 48 44 fa 11 	vpclmulhqhqdq zmm7,zmm3,zmm2
  405b44:	62 f3 65 48 44 da 00 	vpclmullqlqdq zmm3,zmm3,zmm2
  405b4b:	62 d1 75 48 ef c8    	vpxord zmm1,zmm1,zmm8
  405b51:	62 f1 65 48 ef df    	vpxord zmm3,zmm3,zmm7
  405b57:	62 f1 75 48 ef cb    	vpxord zmm1,zmm1,zmm3
  405b5d:	62 f3 fd 48 3b ca 01 	vextracti64x4 ymm2,zmm1,0x1
  405b64:	c5 ed ef c9          	vpxor  ymm1,ymm2,ymm1
  405b68:	c4 e3 7d 39 cb 01    	vextracti128 xmm3,ymm1,0x1
  405b6e:	c5 e1 ef d9          	vpxor  xmm3,xmm3,xmm1
  405b72:	c5 f8 77             	vzeroupper 
  405b75:	e9 60 fe ff ff       	jmp    4059da <chainhash_wide512.constprop.0+0x34a>
  405b7a:	48 89 f2             	mov    rdx,rsi
  405b7d:	48 8d 7c 24 60       	lea    rdi,[rsp+0x60]
  405b82:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  405b86:	c5 f9 7f 2c 24       	vmovdqa XMMWORD PTR [rsp],xmm5
  405b8b:	4c 29 ea             	sub    rdx,r13
  405b8e:	4a 8d 34 29          	lea    rsi,[rcx+r13*1]
  405b92:	c5 f9 7f 64 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm4
  405b98:	c5 f9 7f 74 24 20    	vmovdqa XMMWORD PTR [rsp+0x20],xmm6
  405b9e:	c5 f9 7f 4c 24 30    	vmovdqa XMMWORD PTR [rsp+0x30],xmm1
  405ba4:	c5 f9 7f 54 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm2
  405baa:	c5 f9 7f 44 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm0
  405bb0:	c5 f9 7f 5c 24 60    	vmovdqa XMMWORD PTR [rsp+0x60],xmm3
  405bb6:	c5 f9 7f 5c 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm3
  405bbc:	c5 f8 77             	vzeroupper 
  405bbf:	e8 ac b4 ff ff       	call   401070 <memcpy@plt>
  405bc4:	c5 f9 6f 74 24 60    	vmovdqa xmm6,XMMWORD PTR [rsp+0x60]
  405bca:	c4 c1 49 ef 9d a0 90 	vpxor  xmm3,xmm6,XMMWORD PTR [r13+0x4090a0]
  405bd1:	40 00 
  405bd3:	c5 f9 6f 74 24 70    	vmovdqa xmm6,XMMWORD PTR [rsp+0x70]
  405bd9:	c5 f9 6f 4c 24 30    	vmovdqa xmm1,XMMWORD PTR [rsp+0x30]
  405bdf:	c4 c1 49 ef bd b0 90 	vpxor  xmm7,xmm6,XMMWORD PTR [r13+0x4090b0]
  405be6:	40 00 
  405be8:	c5 f9 6f 2c 24       	vmovdqa xmm5,XMMWORD PTR [rsp]
  405bed:	c5 f9 6f 64 24 10    	vmovdqa xmm4,XMMWORD PTR [rsp+0x10]
  405bf3:	c5 f9 6f 74 24 20    	vmovdqa xmm6,XMMWORD PTR [rsp+0x20]
  405bf9:	c4 63 61 44 c7 11    	vpclmulhqhqdq xmm8,xmm3,xmm7
  405bff:	c4 e3 61 44 df 00    	vpclmullqlqdq xmm3,xmm3,xmm7
  405c05:	c5 f9 6f 54 24 40    	vmovdqa xmm2,XMMWORD PTR [rsp+0x40]
  405c0b:	c5 f9 6f 44 24 50    	vmovdqa xmm0,XMMWORD PTR [rsp+0x50]
  405c11:	c4 c1 61 ef d8       	vpxor  xmm3,xmm3,xmm8
  405c16:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  405c1a:	e9 d3 fb ff ff       	jmp    4057f2 <chainhash_wide512.constprop.0+0x162>
  405c1f:	c5 f9 6f 25 f9 14 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x14f9]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  405c26:	00 
  405c27:	c5 f9 6f 2d 01 15 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x1501]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  405c2e:	00 
  405c2f:	e9 6f fd ff ff       	jmp    4059a3 <chainhash_wide512.constprop.0+0x313>
  405c34:	c5 f1 ef c9          	vpxor  xmm1,xmm1,xmm1
  405c38:	b8 20 00 00 00       	mov    eax,0x20
  405c3d:	45 31 ed             	xor    r13d,r13d
  405c40:	c5 f9 6f d1          	vmovdqa xmm2,xmm1
  405c44:	e9 61 fb ff ff       	jmp    4057aa <chainhash_wide512.constprop.0+0x11a>
  405c49:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000405c50 <chainhash_narrow.constprop.0>:
  405c50:	41 54                	push   r12
  405c52:	48 8d 56 ff          	lea    rdx,[rsi-0x1]
  405c56:	55                   	push   rbp
  405c57:	49 89 d0             	mov    r8,rdx
  405c5a:	53                   	push   rbx
  405c5b:	49 c1 e8 08          	shr    r8,0x8
  405c5f:	48 89 f3             	mov    rbx,rsi
  405c62:	48 81 ec 80 01 00 00 	sub    rsp,0x180
  405c69:	48 8b 2d 30 35 00 00 	mov    rbp,QWORD PTR [rip+0x3530]        # 4091a0 <shipped+0x100>
  405c70:	48 8b 05 39 35 00 00 	mov    rax,QWORD PTR [rip+0x3539]        # 4091b0 <shipped+0x110>
  405c77:	c5 f9 6f 25 21 35 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3521]        # 4091a0 <shipped+0x100>
  405c7e:	00 
  405c7f:	48 31 e8             	xor    rax,rbp
  405c82:	c4 e1 f9 6e c8       	vmovq  xmm1,rax
  405c87:	c5 f9 7f 64 24 30    	vmovdqa XMMWORD PTR [rsp+0x30],xmm4
  405c8d:	48 81 fa ff 00 00 00 	cmp    rdx,0xff
  405c94:	0f 87 26 02 00 00    	ja     405ec0 <chainhash_narrow.constprop.0+0x270>
  405c9a:	c5 f9 6f 25 7e 14 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x147e]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  405ca1:	00 
  405ca2:	c5 f9 6f 2d 86 14 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x1486]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  405ca9:	00 
  405caa:	c5 f9 7f 64 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm4
  405cb0:	c5 f9 7f 6c 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm5
  405cb6:	30 d2                	xor    dl,dl
  405cb8:	48 89 de             	mov    rsi,rbx
  405cbb:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  405cbf:	48 29 d6             	sub    rsi,rdx
  405cc2:	0f 84 f3 00 00 00    	je     405dbb <chainhash_narrow.constprop.0+0x16b>
  405cc8:	49 c1 e0 08          	shl    r8,0x8
  405ccc:	4a 8d 0c 07          	lea    rcx,[rdi+r8*1]
  405cd0:	48 81 fe ff 00 00 00 	cmp    rsi,0xff
  405cd7:	0f 87 5c 06 00 00    	ja     406339 <chainhash_narrow.constprop.0+0x6e9>
  405cdd:	48 83 fe 3f          	cmp    rsi,0x3f
  405ce1:	0f 86 7c 08 00 00    	jbe    406563 <chainhash_narrow.constprop.0+0x913>
  405ce7:	c5 d1 ef ed          	vpxor  xmm5,xmm5,xmm5
  405ceb:	b8 40 00 00 00       	mov    eax,0x40
  405cf0:	c5 f9 6f e5          	vmovdqa xmm4,xmm5
  405cf4:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  405cf8:	c5 fa 6f 7c 01 c0    	vmovdqu xmm7,XMMWORD PTR [rcx+rax*1-0x40]
  405cfe:	c5 c1 ef 80 60 90 40 	vpxor  xmm0,xmm7,XMMWORD PTR [rax+0x409060]
  405d05:	00 
  405d06:	49 89 c4             	mov    r12,rax
  405d09:	c5 fa 6f 7c 01 d0    	vmovdqu xmm7,XMMWORD PTR [rcx+rax*1-0x30]
  405d0f:	c5 c1 ef 90 70 90 40 	vpxor  xmm2,xmm7,XMMWORD PTR [rax+0x409070]
  405d16:	00 
  405d17:	c5 fa 6f 7c 01 e0    	vmovdqu xmm7,XMMWORD PTR [rcx+rax*1-0x20]
  405d1d:	c4 e3 79 44 da 11    	vpclmulhqhqdq xmm3,xmm0,xmm2
  405d23:	c4 e3 79 44 d2 00    	vpclmullqlqdq xmm2,xmm0,xmm2
  405d29:	c5 c1 ef 80 80 90 40 	vpxor  xmm0,xmm7,XMMWORD PTR [rax+0x409080]
  405d30:	00 
  405d31:	c5 fa 6f 7c 01 f0    	vmovdqu xmm7,XMMWORD PTR [rcx+rax*1-0x10]
  405d37:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  405d3b:	c5 c1 ef 98 90 90 40 	vpxor  xmm3,xmm7,XMMWORD PTR [rax+0x409090]
  405d42:	00 
  405d43:	48 8d 40 40          	lea    rax,[rax+0x40]
  405d47:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  405d4b:	c4 e3 79 44 f3 11    	vpclmulhqhqdq xmm6,xmm0,xmm3
  405d51:	c4 e3 79 44 c3 00    	vpclmullqlqdq xmm0,xmm0,xmm3
  405d57:	c5 f9 6f e2          	vmovdqa xmm4,xmm2
  405d5b:	c5 f9 ef c6          	vpxor  xmm0,xmm0,xmm6
  405d5f:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  405d63:	c5 f9 6f e8          	vmovdqa xmm5,xmm0
  405d67:	48 39 c6             	cmp    rsi,rax
  405d6a:	73 8c                	jae    405cf8 <chainhash_narrow.constprop.0+0xa8>
  405d6c:	49 8d 44 24 20       	lea    rax,[r12+0x20]
  405d71:	48 39 c6             	cmp    rsi,rax
  405d74:	72 38                	jb     405dae <chainhash_narrow.constprop.0+0x15e>
  405d76:	4a 8d 14 21          	lea    rdx,[rcx+r12*1]
  405d7a:	c5 fa 6f 1a          	vmovdqu xmm3,XMMWORD PTR [rdx]
  405d7e:	c5 fa 6f 62 10       	vmovdqu xmm4,XMMWORD PTR [rdx+0x10]
  405d83:	c4 c1 61 ef 9c 24 a0 	vpxor  xmm3,xmm3,XMMWORD PTR [r12+0x4090a0]
  405d8a:	90 40 00 
  405d8d:	c4 c1 59 ef a4 24 b0 	vpxor  xmm4,xmm4,XMMWORD PTR [r12+0x4090b0]
  405d94:	90 40 00 
  405d97:	49 89 c4             	mov    r12,rax
  405d9a:	c4 e3 61 44 ec 11    	vpclmulhqhqdq xmm5,xmm3,xmm4
  405da0:	c4 e3 61 44 dc 00    	vpclmullqlqdq xmm3,xmm3,xmm4
  405da6:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  405daa:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  405dae:	4c 39 e6             	cmp    rsi,r12
  405db1:	0f 87 1e 07 00 00    	ja     4064d5 <chainhash_narrow.constprop.0+0x885>
  405db7:	c5 e9 ef d8          	vpxor  xmm3,xmm2,xmm0
  405dbb:	c4 e1 f9 6e e3       	vmovq  xmm4,rbx
  405dc0:	c4 e1 f9 6e d5       	vmovq  xmm2,rbp
  405dc5:	c5 e9 ef 54 24 30    	vpxor  xmm2,xmm2,XMMWORD PTR [rsp+0x30]
  405dcb:	c5 f9 6f 6c 24 50    	vmovdqa xmm5,XMMWORD PTR [rsp+0x50]
  405dd1:	c5 d9 6c c4          	vpunpcklqdq xmm0,xmm4,xmm4
  405dd5:	48 8b 05 dc 33 00 00 	mov    rax,QWORD PTR [rip+0x33dc]        # 4091b8 <shipped+0x118>
  405ddc:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  405de0:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  405de4:	c4 e3 69 44 c9 01    	vpclmulhqlqdq xmm1,xmm2,xmm1
  405dea:	c4 e3 71 44 44 24 40 	vpclmulhqlqdq xmm0,xmm1,XMMWORD PTR [rsp+0x40]
  405df1:	01 
  405df2:	c5 e1 73 d8 08       	vpsrldq xmm3,xmm0,0x8
  405df7:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  405dfb:	c4 e2 51 00 db       	vpshufb xmm3,xmm5,xmm3
  405e00:	c5 f1 ef cb          	vpxor  xmm1,xmm1,xmm3
  405e04:	c5 f9 6f 1d 04 13 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x1304]        # 407110 <__PRETTY_FUNCTION__.6+0x20>
  405e0b:	00 
  405e0c:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  405e10:	c5 fa 7e 0d c8 33 00 	vmovq  xmm1,QWORD PTR [rip+0x33c8]        # 4091e0 <shipped+0x140>
  405e17:	00 
  405e18:	c5 f9 d4 c1          	vpaddq xmm0,xmm0,xmm1
  405e1c:	c4 e3 79 44 c8 00    	vpclmullqlqdq xmm1,xmm0,xmm0
  405e22:	c4 e3 71 44 d3 11    	vpclmulhqhqdq xmm2,xmm1,xmm3
  405e28:	c4 e3 69 44 e3 11    	vpclmulhqhqdq xmm4,xmm2,xmm3
  405e2e:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  405e32:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  405e37:	48 33 05 82 33 00 00 	xor    rax,QWORD PTR [rip+0x3382]        # 4091c0 <shipped+0x120>
  405e3e:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  405e42:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  405e46:	c4 e1 f9 6e d0       	vmovq  xmm2,rax
  405e4b:	c5 e9 ef d1          	vpxor  xmm2,xmm2,xmm1
  405e4f:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  405e53:	c4 e3 71 44 ca 00    	vpclmullqlqdq xmm1,xmm1,xmm2
  405e59:	c5 fa 7e 15 67 33 00 	vmovq  xmm2,QWORD PTR [rip+0x3367]        # 4091c8 <shipped+0x128>
  405e60:	00 
  405e61:	c4 e3 71 44 e3 11    	vpclmulhqhqdq xmm4,xmm1,xmm3
  405e67:	c5 e9 ef c0          	vpxor  xmm0,xmm2,xmm0
  405e6b:	c5 fa 7e 15 5d 33 00 	vmovq  xmm2,QWORD PTR [rip+0x335d]        # 4091d0 <shipped+0x130>
  405e72:	00 
  405e73:	c4 e3 59 44 eb 11    	vpclmulhqhqdq xmm5,xmm4,xmm3
  405e79:	c5 f1 ef cc          	vpxor  xmm1,xmm1,xmm4
  405e7d:	c5 e9 ef d5          	vpxor  xmm2,xmm2,xmm5
  405e81:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  405e85:	c5 fa 7e 15 4b 33 00 	vmovq  xmm2,QWORD PTR [rip+0x334b]        # 4091d8 <shipped+0x138>
  405e8c:	00 
  405e8d:	48 81 c4 80 01 00 00 	add    rsp,0x180
  405e94:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
  405e9a:	5b                   	pop    rbx
  405e9b:	5d                   	pop    rbp
  405e9c:	c4 e3 79 44 e3 11    	vpclmulhqhqdq xmm4,xmm0,xmm3
  405ea2:	41 5c                	pop    r12
  405ea4:	c4 e3 59 44 cb 11    	vpclmulhqhqdq xmm1,xmm4,xmm3
  405eaa:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
  405eae:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  405eb2:	c5 f1 ef c0          	vpxor  xmm0,xmm1,xmm0
  405eb6:	c4 e1 f9 7e c0       	vmovq  rax,xmm0
  405ebb:	c3                   	ret    
  405ebc:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  405ec0:	c5 f9 6f 25 d8 31 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x31d8]        # 4090a0 <shipped>
  405ec7:	00 
  405ec8:	c5 f9 6f 2d e0 31 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x31e0]        # 4090b0 <shipped+0x10>
  405ecf:	00 
  405ed0:	c5 d9 ef 07          	vpxor  xmm0,xmm4,XMMWORD PTR [rdi]
  405ed4:	c5 d1 ef 57 10       	vpxor  xmm2,xmm5,XMMWORD PTR [rdi+0x10]
  405ed9:	c5 f9 7f a4 24 50 01 	vmovdqa XMMWORD PTR [rsp+0x150],xmm4
  405ee0:	00 00 
  405ee2:	c5 f9 6f 25 d6 31 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x31d6]        # 4090c0 <shipped+0x20>
  405ee9:	00 
  405eea:	c5 f9 6f 1d ee 31 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x31ee]        # 4090e0 <shipped+0x40>
  405ef1:	00 
  405ef2:	c4 63 79 44 da 11    	vpclmulhqhqdq xmm11,xmm0,xmm2
  405ef8:	c4 63 79 44 e2 00    	vpclmullqlqdq xmm12,xmm0,xmm2
  405efe:	c5 f9 7f ac 24 40 01 	vmovdqa XMMWORD PTR [rsp+0x140],xmm5
  405f05:	00 00 
  405f07:	c5 d9 ef 47 20       	vpxor  xmm0,xmm4,XMMWORD PTR [rdi+0x20]
  405f0c:	c5 f9 6f 2d bc 31 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x31bc]        # 4090d0 <shipped+0x30>
  405f13:	00 
  405f14:	c5 d1 ef 57 30       	vpxor  xmm2,xmm5,XMMWORD PTR [rdi+0x30]
  405f19:	c5 f9 7f a4 24 30 01 	vmovdqa XMMWORD PTR [rsp+0x130],xmm4
  405f20:	00 00 
  405f22:	c5 f9 6f 25 c6 31 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x31c6]        # 4090f0 <shipped+0x50>
  405f29:	00 
  405f2a:	c5 f9 7f 9c 24 10 01 	vmovdqa XMMWORD PTR [rsp+0x110],xmm3
  405f31:	00 00 
  405f33:	c4 e3 79 44 fa 11    	vpclmulhqhqdq xmm7,xmm0,xmm2
  405f39:	c4 e3 79 44 f2 00    	vpclmullqlqdq xmm6,xmm0,xmm2
  405f3f:	c5 f9 7f ac 24 20 01 	vmovdqa XMMWORD PTR [rsp+0x120],xmm5
  405f46:	00 00 
  405f48:	c5 e1 ef 47 40       	vpxor  xmm0,xmm3,XMMWORD PTR [rdi+0x40]
  405f4d:	c5 d9 ef 57 50       	vpxor  xmm2,xmm4,XMMWORD PTR [rdi+0x50]
  405f52:	c5 f9 7f 74 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm6
  405f58:	c5 f9 6f 2d a0 31 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x31a0]        # 409100 <shipped+0x60>
  405f5f:	00 
  405f60:	c5 f9 6f 1d a8 31 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x31a8]        # 409110 <shipped+0x70>
  405f67:	00 
  405f68:	c5 f9 7f 3c 24       	vmovdqa XMMWORD PTR [rsp],xmm7
  405f6d:	c4 e3 79 44 f2 11    	vpclmulhqhqdq xmm6,xmm0,xmm2
  405f73:	c4 63 79 44 d2 00    	vpclmullqlqdq xmm10,xmm0,xmm2
  405f79:	c5 f9 7f a4 24 00 01 	vmovdqa XMMWORD PTR [rsp+0x100],xmm4
  405f80:	00 00 
  405f82:	c5 d1 ef 47 60       	vpxor  xmm0,xmm5,XMMWORD PTR [rdi+0x60]
  405f87:	c5 e1 ef 57 70       	vpxor  xmm2,xmm3,XMMWORD PTR [rdi+0x70]
  405f8c:	c4 c1 49 ef f2       	vpxor  xmm6,xmm6,xmm10
  405f91:	c5 f9 6f 25 87 31 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3187]        # 409120 <shipped+0x80>
  405f98:	00 
  405f99:	c5 f9 7f ac 24 f0 00 	vmovdqa XMMWORD PTR [rsp+0xf0],xmm5
  405fa0:	00 00 
  405fa2:	c5 f9 6f 2d 86 31 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x3186]        # 409130 <shipped+0x90>
  405fa9:	00 
  405faa:	c5 f9 7f 9c 24 e0 00 	vmovdqa XMMWORD PTR [rsp+0xe0],xmm3
  405fb1:	00 00 
  405fb3:	c4 63 79 44 ea 11    	vpclmulhqhqdq xmm13,xmm0,xmm2
  405fb9:	c4 63 79 44 f2 00    	vpclmullqlqdq xmm14,xmm0,xmm2
  405fbf:	c5 f9 7f a4 24 d0 00 	vmovdqa XMMWORD PTR [rsp+0xd0],xmm4
  405fc6:	00 00 
  405fc8:	c5 d9 ef 87 80 00 00 	vpxor  xmm0,xmm4,XMMWORD PTR [rdi+0x80]
  405fcf:	00 
  405fd0:	c5 d1 ef 97 90 00 00 	vpxor  xmm2,xmm5,XMMWORD PTR [rdi+0x90]
  405fd7:	00 
  405fd8:	c5 f9 7f ac 24 c0 00 	vmovdqa XMMWORD PTR [rsp+0xc0],xmm5
  405fdf:	00 00 
  405fe1:	c5 f9 6f 1d 57 31 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x3157]        # 409140 <shipped+0xa0>
  405fe8:	00 
  405fe9:	c5 f9 6f 25 5f 31 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x315f]        # 409150 <shipped+0xb0>
  405ff0:	00 
  405ff1:	c5 f9 6f 2d 67 31 00 	vmovdqa xmm5,XMMWORD PTR [rip+0x3167]        # 409160 <shipped+0xc0>
  405ff8:	00 
  405ff9:	c4 e3 79 44 fa 11    	vpclmulhqhqdq xmm7,xmm0,xmm2
  405fff:	c4 63 79 44 c2 00    	vpclmullqlqdq xmm8,xmm0,xmm2
  406005:	c5 e1 ef 87 a0 00 00 	vpxor  xmm0,xmm3,XMMWORD PTR [rdi+0xa0]
  40600c:	00 
  40600d:	c5 f9 7f 9c 24 b0 00 	vmovdqa XMMWORD PTR [rsp+0xb0],xmm3
  406014:	00 00 
  406016:	c5 d9 ef 97 b0 00 00 	vpxor  xmm2,xmm4,XMMWORD PTR [rdi+0xb0]
  40601d:	00 
  40601e:	c5 d1 ef 9f c0 00 00 	vpxor  xmm3,xmm5,XMMWORD PTR [rdi+0xc0]
  406025:	00 
  406026:	c5 f9 7f a4 24 a0 00 	vmovdqa XMMWORD PTR [rsp+0xa0],xmm4
  40602d:	00 00 
  40602f:	c5 f9 6f 25 39 31 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3139]        # 409170 <shipped+0xd0>
  406036:	00 
  406037:	c5 f9 7f 6c 24 60    	vmovdqa XMMWORD PTR [rsp+0x60],xmm5
  40603d:	c4 63 79 44 fa 11    	vpclmulhqhqdq xmm15,xmm0,xmm2
  406043:	c4 63 79 44 ca 00    	vpclmullqlqdq xmm9,xmm0,xmm2
  406049:	c5 d9 ef 87 d0 00 00 	vpxor  xmm0,xmm4,XMMWORD PTR [rdi+0xd0]
  406050:	00 
  406051:	c5 f9 7f 64 24 70    	vmovdqa XMMWORD PTR [rsp+0x70],xmm4
  406057:	c5 f9 6f 25 21 31 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3121]        # 409180 <shipped+0xe0>
  40605e:	00 
  40605f:	c5 d9 ef 97 e0 00 00 	vpxor  xmm2,xmm4,XMMWORD PTR [rdi+0xe0]
  406066:	00 
  406067:	c4 e3 61 44 e8 11    	vpclmulhqhqdq xmm5,xmm3,xmm0
  40606d:	c4 e3 61 44 d8 00    	vpclmullqlqdq xmm3,xmm3,xmm0
  406073:	c5 f9 7f a4 24 80 00 	vmovdqa XMMWORD PTR [rsp+0x80],xmm4
  40607a:	00 00 
  40607c:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  406080:	c5 f9 6f 25 08 31 00 	vmovdqa xmm4,XMMWORD PTR [rip+0x3108]        # 409190 <shipped+0xf0>
  406087:	00 
  406088:	c5 d9 ef 87 f0 00 00 	vpxor  xmm0,xmm4,XMMWORD PTR [rdi+0xf0]
  40608f:	00 
  406090:	c4 c1 11 ef ee       	vpxor  xmm5,xmm13,xmm14
  406095:	c5 f9 7f a4 24 90 00 	vmovdqa XMMWORD PTR [rsp+0x90],xmm4
  40609c:	00 00 
  40609e:	c4 e3 69 44 e0 11    	vpclmulhqhqdq xmm4,xmm2,xmm0
  4060a4:	c4 e3 69 44 d0 00    	vpclmullqlqdq xmm2,xmm2,xmm0
  4060aa:	c4 c1 21 ef c4       	vpxor  xmm0,xmm11,xmm12
  4060af:	c5 c9 ef c0          	vpxor  xmm0,xmm6,xmm0
  4060b3:	c4 c1 41 ef f0       	vpxor  xmm6,xmm7,xmm8
  4060b8:	c5 e9 ef d4          	vpxor  xmm2,xmm2,xmm4
  4060bc:	c5 f9 ef c6          	vpxor  xmm0,xmm0,xmm6
  4060c0:	c5 f9 6f 74 24 10    	vmovdqa xmm6,XMMWORD PTR [rsp+0x10]
  4060c6:	c5 f9 ef db          	vpxor  xmm3,xmm0,xmm3
  4060ca:	c5 c9 ef 04 24       	vpxor  xmm0,xmm6,XMMWORD PTR [rsp]
  4060cf:	c5 d1 ef c0          	vpxor  xmm0,xmm5,xmm0
  4060d3:	c4 c1 01 ef e9       	vpxor  xmm5,xmm15,xmm9
  4060d8:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  4060dc:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  4060e0:	c5 e1 ef c0          	vpxor  xmm0,xmm3,xmm0
  4060e4:	c5 f9 ef 44 24 30    	vpxor  xmm0,xmm0,XMMWORD PTR [rsp+0x30]
  4060ea:	49 83 f8 01          	cmp    r8,0x1
  4060ee:	0f 86 84 04 00 00    	jbe    406578 <chainhash_narrow.constprop.0+0x928>
  4060f4:	c5 f9 6f 1d 24 10 00 	vmovdqa xmm3,XMMWORD PTR [rip+0x1024]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  4060fb:	00 
  4060fc:	c5 f9 6f 3d 2c 10 00 	vmovdqa xmm7,XMMWORD PTR [rip+0x102c]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  406103:	00 
  406104:	4c 89 c1             	mov    rcx,r8
  406107:	48 8d 87 00 01 00 00 	lea    rax,[rdi+0x100]
  40610e:	48 c1 e1 08          	shl    rcx,0x8
  406112:	48 01 f9             	add    rcx,rdi
  406115:	c5 f9 7f 5c 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm3
  40611b:	c5 f9 7f 7c 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm7
  406121:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  406128:	c4 63 79 44 d9 01    	vpclmulhqlqdq xmm11,xmm0,xmm1
  40612e:	c5 f9 7f 04 24       	vmovdqa XMMWORD PTR [rsp],xmm0
  406133:	c5 f9 6f bc 24 50 01 	vmovdqa xmm7,XMMWORD PTR [rsp+0x150]
  40613a:	00 00 
  40613c:	c5 c1 ef 20          	vpxor  xmm4,xmm7,XMMWORD PTR [rax]
  406140:	c5 f9 6f bc 24 40 01 	vmovdqa xmm7,XMMWORD PTR [rsp+0x140]
  406147:	00 00 
  406149:	c5 c1 ef 40 10       	vpxor  xmm0,xmm7,XMMWORD PTR [rax+0x10]
  40614e:	48 05 00 01 00 00    	add    rax,0x100
  406154:	c5 f9 6f ac 24 30 01 	vmovdqa xmm5,XMMWORD PTR [rsp+0x130]
  40615b:	00 00 
  40615d:	c5 f9 6f b4 24 20 01 	vmovdqa xmm6,XMMWORD PTR [rsp+0x120]
  406164:	00 00 
  406166:	c4 e3 59 44 f8 11    	vpclmulhqhqdq xmm7,xmm4,xmm0
  40616c:	c5 c9 ef 88 30 ff ff 	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0xd0]
  406173:	ff 
  406174:	c4 e3 59 44 e0 00    	vpclmullqlqdq xmm4,xmm4,xmm0
  40617a:	c5 f9 6f b4 24 00 01 	vmovdqa xmm6,XMMWORD PTR [rsp+0x100]
  406181:	00 00 
  406183:	c5 d1 ef 80 20 ff ff 	vpxor  xmm0,xmm5,XMMWORD PTR [rax-0xe0]
  40618a:	ff 
  40618b:	c5 f9 7f 7c 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm7
  406191:	c5 f9 6f ac 24 10 01 	vmovdqa xmm5,XMMWORD PTR [rsp+0x110]
  406198:	00 00 
  40619a:	c5 d1 ef 98 40 ff ff 	vpxor  xmm3,xmm5,XMMWORD PTR [rax-0xc0]
  4061a1:	ff 
  4061a2:	c5 f9 6f ac 24 f0 00 	vmovdqa xmm5,XMMWORD PTR [rsp+0xf0]
  4061a9:	00 00 
  4061ab:	c4 63 79 44 f9 11    	vpclmulhqhqdq xmm15,xmm0,xmm1
  4061b1:	c4 e3 79 44 c1 00    	vpclmullqlqdq xmm0,xmm0,xmm1
  4061b7:	c5 c9 ef 88 50 ff ff 	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0xb0]
  4061be:	ff 
  4061bf:	c5 f9 6f b4 24 e0 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0xe0]
  4061c6:	00 00 
  4061c8:	c5 d1 ef 90 60 ff ff 	vpxor  xmm2,xmm5,XMMWORD PTR [rax-0xa0]
  4061cf:	ff 
  4061d0:	c4 c1 79 ef c7       	vpxor  xmm0,xmm0,xmm15
  4061d5:	c5 f9 6f ac 24 d0 00 	vmovdqa xmm5,XMMWORD PTR [rsp+0xd0]
  4061dc:	00 00 
  4061de:	c4 63 61 44 f1 11    	vpclmulhqhqdq xmm14,xmm3,xmm1
  4061e4:	c4 e3 61 44 d9 00    	vpclmullqlqdq xmm3,xmm3,xmm1
  4061ea:	c5 51 ef 40 80       	vpxor  xmm8,xmm5,XMMWORD PTR [rax-0x80]
  4061ef:	c5 c9 ef 88 70 ff ff 	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0x90]
  4061f6:	ff 
  4061f7:	c4 c1 61 ef de       	vpxor  xmm3,xmm3,xmm14
  4061fc:	c5 f9 6f b4 24 c0 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0xc0]
  406203:	00 00 
  406205:	c4 63 69 44 e9 11    	vpclmulhqhqdq xmm13,xmm2,xmm1
  40620b:	c4 e3 69 44 d1 00    	vpclmullqlqdq xmm2,xmm2,xmm1
  406211:	c5 c9 ef 48 90       	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0x70]
  406216:	c5 f9 6f b4 24 b0 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0xb0]
  40621d:	00 00 
  40621f:	c5 c9 ef 78 a0       	vpxor  xmm7,xmm6,XMMWORD PTR [rax-0x60]
  406224:	c4 c1 69 ef d5       	vpxor  xmm2,xmm2,xmm13
  406229:	c5 f9 6f b4 24 a0 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0xa0]
  406230:	00 00 
  406232:	c4 e3 39 44 e9 11    	vpclmulhqhqdq xmm5,xmm8,xmm1
  406238:	c4 63 39 44 c1 00    	vpclmullqlqdq xmm8,xmm8,xmm1
  40623e:	c5 c9 ef 48 b0       	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0x50]
  406243:	c5 f9 6f 74 24 60    	vmovdqa xmm6,XMMWORD PTR [rsp+0x60]
  406249:	c4 c1 69 ef d0       	vpxor  xmm2,xmm2,xmm8
  40624e:	c4 63 41 44 e1 11    	vpclmulhqhqdq xmm12,xmm7,xmm1
  406254:	c4 e3 41 44 f9 00    	vpclmullqlqdq xmm7,xmm7,xmm1
  40625a:	c5 c9 ef 48 c0       	vpxor  xmm1,xmm6,XMMWORD PTR [rax-0x40]
  40625f:	c5 f9 6f 74 24 70    	vmovdqa xmm6,XMMWORD PTR [rsp+0x70]
  406265:	c5 c9 ef 70 d0       	vpxor  xmm6,xmm6,XMMWORD PTR [rax-0x30]
  40626a:	c5 d1 ef ef          	vpxor  xmm5,xmm5,xmm7
  40626e:	c4 c1 51 ef ec       	vpxor  xmm5,xmm5,xmm12
  406273:	c4 63 71 44 ce 11    	vpclmulhqhqdq xmm9,xmm1,xmm6
  406279:	c4 e3 71 44 ce 00    	vpclmullqlqdq xmm1,xmm1,xmm6
  40627f:	c5 f9 6f b4 24 80 00 	vmovdqa xmm6,XMMWORD PTR [rsp+0x80]
  406286:	00 00 
  406288:	c5 79 7f 4c 24 20    	vmovdqa XMMWORD PTR [rsp+0x20],xmm9
  40628e:	c5 c9 ef 70 e0       	vpxor  xmm6,xmm6,XMMWORD PTR [rax-0x20]
  406293:	c5 d9 ef 64 24 10    	vpxor  xmm4,xmm4,XMMWORD PTR [rsp+0x10]
  406299:	c5 e1 ef 5c 24 30    	vpxor  xmm3,xmm3,XMMWORD PTR [rsp+0x30]
  40629f:	c5 f1 ef 4c 24 20    	vpxor  xmm1,xmm1,XMMWORD PTR [rsp+0x20]
  4062a5:	c5 79 6f 8c 24 90 00 	vmovdqa xmm9,XMMWORD PTR [rsp+0x90]
  4062ac:	00 00 
  4062ae:	c5 f9 ef c4          	vpxor  xmm0,xmm0,xmm4
  4062b2:	c5 31 ef 48 f0       	vpxor  xmm9,xmm9,XMMWORD PTR [rax-0x10]
  4062b7:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  4062bb:	c5 f9 6f 7c 24 50    	vmovdqa xmm7,XMMWORD PTR [rsp+0x50]
  4062c1:	c4 43 49 44 d1 11    	vpclmulhqhqdq xmm10,xmm6,xmm9
  4062c7:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  4062cb:	c4 c3 49 44 f1 00    	vpclmullqlqdq xmm6,xmm6,xmm9
  4062d1:	c5 f1 ef ce          	vpxor  xmm1,xmm1,xmm6
  4062d5:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  4062d9:	c5 f9 ef c1          	vpxor  xmm0,xmm0,xmm1
  4062dd:	c4 e3 21 44 4c 24 40 	vpclmulhqlqdq xmm1,xmm11,XMMWORD PTR [rsp+0x40]
  4062e4:	01 
  4062e5:	c5 e9 73 d9 08       	vpsrldq xmm2,xmm1,0x8
  4062ea:	c4 c1 79 ef c2       	vpxor  xmm0,xmm0,xmm10
  4062ef:	c4 e2 41 00 d2       	vpshufb xmm2,xmm7,xmm2
  4062f4:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  4062f8:	c5 a1 ef 14 24       	vpxor  xmm2,xmm11,XMMWORD PTR [rsp]
  4062fd:	c5 f1 ef ca          	vpxor  xmm1,xmm1,xmm2
  406301:	48 39 c1             	cmp    rcx,rax
  406304:	0f 85 1e fe ff ff    	jne    406128 <chainhash_narrow.constprop.0+0x4d8>
  40630a:	c4 e3 79 44 c9 01    	vpclmulhqlqdq xmm1,xmm0,xmm1
  406310:	c5 f9 6f 7c 24 50    	vmovdqa xmm7,XMMWORD PTR [rsp+0x50]
  406316:	c4 e3 71 44 54 24 40 	vpclmulhqlqdq xmm2,xmm1,XMMWORD PTR [rsp+0x40]
  40631d:	01 
  40631e:	c5 f1 ef c8          	vpxor  xmm1,xmm1,xmm0
  406322:	c5 e1 73 da 08       	vpsrldq xmm3,xmm2,0x8
  406327:	c4 e2 41 00 db       	vpshufb xmm3,xmm7,xmm3
  40632c:	c5 e9 ef d3          	vpxor  xmm2,xmm2,xmm3
  406330:	c5 e9 ef c9          	vpxor  xmm1,xmm2,xmm1
  406334:	e9 7d f9 ff ff       	jmp    405cb6 <chainhash_narrow.constprop.0+0x66>
  406339:	c5 fa 6f 19          	vmovdqu xmm3,XMMWORD PTR [rcx]
  40633d:	c5 fa 6f 79 10       	vmovdqu xmm7,XMMWORD PTR [rcx+0x10]
  406342:	c5 e1 ef 05 56 2d 00 	vpxor  xmm0,xmm3,XMMWORD PTR [rip+0x2d56]        # 4090a0 <shipped>
  406349:	00 
  40634a:	c5 c1 ef 15 5e 2d 00 	vpxor  xmm2,xmm7,XMMWORD PTR [rip+0x2d5e]        # 4090b0 <shipped+0x10>
  406351:	00 
  406352:	c5 fa 6f 59 20       	vmovdqu xmm3,XMMWORD PTR [rcx+0x20]
  406357:	c5 fa 6f 79 30       	vmovdqu xmm7,XMMWORD PTR [rcx+0x30]
  40635c:	c5 e1 ef 1d 5c 2d 00 	vpxor  xmm3,xmm3,XMMWORD PTR [rip+0x2d5c]        # 4090c0 <shipped+0x20>
  406363:	00 
  406364:	c4 63 79 44 e2 11    	vpclmulhqhqdq xmm12,xmm0,xmm2
  40636a:	c5 fa 6f 69 40       	vmovdqu xmm5,XMMWORD PTR [rcx+0x40]
  40636f:	c4 e3 79 44 c2 00    	vpclmullqlqdq xmm0,xmm0,xmm2
  406375:	c5 c1 ef 15 53 2d 00 	vpxor  xmm2,xmm7,XMMWORD PTR [rip+0x2d53]        # 4090d0 <shipped+0x30>
  40637c:	00 
  40637d:	c5 fa 6f 79 50       	vmovdqu xmm7,XMMWORD PTR [rcx+0x50]
  406382:	c4 c1 79 ef c4       	vpxor  xmm0,xmm0,xmm12
  406387:	c5 c1 ef 25 61 2d 00 	vpxor  xmm4,xmm7,XMMWORD PTR [rip+0x2d61]        # 4090f0 <shipped+0x50>
  40638e:	00 
  40638f:	c5 fa 6f 79 70       	vmovdqu xmm7,XMMWORD PTR [rcx+0x70]
  406394:	c4 63 61 44 da 11    	vpclmulhqhqdq xmm11,xmm3,xmm2
  40639a:	c4 e3 61 44 da 00    	vpclmullqlqdq xmm3,xmm3,xmm2
  4063a0:	c5 d1 ef 15 38 2d 00 	vpxor  xmm2,xmm5,XMMWORD PTR [rip+0x2d38]        # 4090e0 <shipped+0x40>
  4063a7:	00 
  4063a8:	c5 fa 6f 69 60       	vmovdqu xmm5,XMMWORD PTR [rcx+0x60]
  4063ad:	c5 d1 ef 35 4b 2d 00 	vpxor  xmm6,xmm5,XMMWORD PTR [rip+0x2d4b]        # 409100 <shipped+0x60>
  4063b4:	00 
  4063b5:	c5 fa 6f a9 80 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0x80]
  4063bc:	00 
  4063bd:	c4 c1 61 ef db       	vpxor  xmm3,xmm3,xmm11
  4063c2:	c4 63 69 44 d4 11    	vpclmulhqhqdq xmm10,xmm2,xmm4
  4063c8:	c4 e3 69 44 d4 00    	vpclmullqlqdq xmm2,xmm2,xmm4
  4063ce:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  4063d2:	c5 c1 ef 25 36 2d 00 	vpxor  xmm4,xmm7,XMMWORD PTR [rip+0x2d36]        # 409110 <shipped+0x70>
  4063d9:	00 
  4063da:	c4 c1 69 ef d2       	vpxor  xmm2,xmm2,xmm10
  4063df:	c4 e3 49 44 fc 11    	vpclmulhqhqdq xmm7,xmm6,xmm4
  4063e5:	c4 e3 49 44 f4 00    	vpclmullqlqdq xmm6,xmm6,xmm4
  4063eb:	c5 d1 ef 25 2d 2d 00 	vpxor  xmm4,xmm5,XMMWORD PTR [rip+0x2d2d]        # 409120 <shipped+0x80>
  4063f2:	00 
  4063f3:	c5 fa 6f a9 90 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0x90]
  4063fa:	00 
  4063fb:	c5 d1 ef 2d 2d 2d 00 	vpxor  xmm5,xmm5,XMMWORD PTR [rip+0x2d2d]        # 409130 <shipped+0x90>
  406402:	00 
  406403:	c5 e9 ef d6          	vpxor  xmm2,xmm2,xmm6
  406407:	c5 f9 ef c2          	vpxor  xmm0,xmm0,xmm2
  40640b:	c4 63 59 44 f5 11    	vpclmulhqhqdq xmm14,xmm4,xmm5
  406411:	c4 63 59 44 ed 00    	vpclmullqlqdq xmm13,xmm4,xmm5
  406417:	c5 fa 6f a9 a0 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0xa0]
  40641e:	00 
  40641f:	c5 d1 ef 25 19 2d 00 	vpxor  xmm4,xmm5,XMMWORD PTR [rip+0x2d19]        # 409140 <shipped+0xa0>
  406426:	00 
  406427:	c5 fa 6f a9 b0 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0xb0]
  40642e:	00 
  40642f:	c5 d1 ef 2d 19 2d 00 	vpxor  xmm5,xmm5,XMMWORD PTR [rip+0x2d19]        # 409150 <shipped+0xb0>
  406436:	00 
  406437:	c4 c1 41 ef d5       	vpxor  xmm2,xmm7,xmm13
  40643c:	c4 c1 69 ef d6       	vpxor  xmm2,xmm2,xmm14
  406441:	c4 63 59 44 fd 11    	vpclmulhqhqdq xmm15,xmm4,xmm5
  406447:	c5 f9 ef d2          	vpxor  xmm2,xmm0,xmm2
  40644b:	c5 79 7f 3c 24       	vmovdqa XMMWORD PTR [rsp],xmm15
  406450:	c4 63 59 44 fd 00    	vpclmullqlqdq xmm15,xmm4,xmm5
  406456:	c5 fa 6f a9 c0 00 00 	vmovdqu xmm5,XMMWORD PTR [rcx+0xc0]
  40645d:	00 
  40645e:	c5 fa 6f a1 d0 00 00 	vmovdqu xmm4,XMMWORD PTR [rcx+0xd0]
  406465:	00 
  406466:	c5 d1 ef 2d f2 2c 00 	vpxor  xmm5,xmm5,XMMWORD PTR [rip+0x2cf2]        # 409160 <shipped+0xc0>
  40646d:	00 
  40646e:	c5 d9 ef 25 fa 2c 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rip+0x2cfa]        # 409170 <shipped+0xd0>
  406475:	00 
  406476:	c4 63 51 44 c4 11    	vpclmulhqhqdq xmm8,xmm5,xmm4
  40647c:	c4 e3 51 44 ec 00    	vpclmullqlqdq xmm5,xmm5,xmm4
  406482:	c5 fa 6f a1 e0 00 00 	vmovdqu xmm4,XMMWORD PTR [rcx+0xe0]
  406489:	00 
  40648a:	c5 d9 ef 25 ee 2c 00 	vpxor  xmm4,xmm4,XMMWORD PTR [rip+0x2cee]        # 409180 <shipped+0xe0>
  406491:	00 
  406492:	c5 79 7f 44 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm8
  406498:	c5 7a 6f 81 f0 00 00 	vmovdqu xmm8,XMMWORD PTR [rcx+0xf0]
  40649f:	00 
  4064a0:	c5 81 ef 04 24       	vpxor  xmm0,xmm15,XMMWORD PTR [rsp]
  4064a5:	c5 39 ef 05 e3 2c 00 	vpxor  xmm8,xmm8,XMMWORD PTR [rip+0x2ce3]        # 409190 <shipped+0xf0>
  4064ac:	00 
  4064ad:	c5 f9 ef c5          	vpxor  xmm0,xmm0,xmm5
  4064b1:	c4 43 59 44 c8 11    	vpclmulhqhqdq xmm9,xmm4,xmm8
  4064b7:	c5 e9 ef d0          	vpxor  xmm2,xmm2,xmm0
  4064bb:	c4 c3 59 44 e0 00    	vpclmullqlqdq xmm4,xmm4,xmm8
  4064c1:	c5 d9 ef 44 24 10    	vpxor  xmm0,xmm4,XMMWORD PTR [rsp+0x10]
  4064c7:	c4 c1 79 ef c1       	vpxor  xmm0,xmm0,xmm9
  4064cc:	c5 e9 ef d8          	vpxor  xmm3,xmm2,xmm0
  4064d0:	e9 e6 f8 ff ff       	jmp    405dbb <chainhash_narrow.constprop.0+0x16b>
  4064d5:	48 89 f2             	mov    rdx,rsi
  4064d8:	c5 e1 ef db          	vpxor  xmm3,xmm3,xmm3
  4064dc:	4a 8d 34 21          	lea    rsi,[rcx+r12*1]
  4064e0:	c5 f9 7f 44 24 20    	vmovdqa XMMWORD PTR [rsp+0x20],xmm0
  4064e6:	4c 29 e2             	sub    rdx,r12
  4064e9:	48 8d bc 24 60 01 00 	lea    rdi,[rsp+0x160]
  4064f0:	00 
  4064f1:	c5 f9 7f 54 24 10    	vmovdqa XMMWORD PTR [rsp+0x10],xmm2
  4064f7:	c5 f9 7f 0c 24       	vmovdqa XMMWORD PTR [rsp],xmm1
  4064fc:	c5 f9 7f 9c 24 60 01 	vmovdqa XMMWORD PTR [rsp+0x160],xmm3
  406503:	00 00 
  406505:	c5 f9 7f 9c 24 70 01 	vmovdqa XMMWORD PTR [rsp+0x170],xmm3
  40650c:	00 00 
  40650e:	e8 5d ab ff ff       	call   401070 <memcpy@plt>
  406513:	c5 f9 6f 44 24 20    	vmovdqa xmm0,XMMWORD PTR [rsp+0x20]
  406519:	c5 f9 6f 54 24 10    	vmovdqa xmm2,XMMWORD PTR [rsp+0x10]
  40651f:	c5 f9 6f 9c 24 60 01 	vmovdqa xmm3,XMMWORD PTR [rsp+0x160]
  406526:	00 00 
  406528:	c5 f9 6f 0c 24       	vmovdqa xmm1,XMMWORD PTR [rsp]
  40652d:	c4 c1 61 ef 9c 24 a0 	vpxor  xmm3,xmm3,XMMWORD PTR [r12+0x4090a0]
  406534:	90 40 00 
  406537:	c5 f9 6f bc 24 70 01 	vmovdqa xmm7,XMMWORD PTR [rsp+0x170]
  40653e:	00 00 
  406540:	c4 c1 41 ef a4 24 b0 	vpxor  xmm4,xmm7,XMMWORD PTR [r12+0x4090b0]
  406547:	90 40 00 
  40654a:	c4 e3 61 44 ec 11    	vpclmulhqhqdq xmm5,xmm3,xmm4
  406550:	c4 e3 61 44 dc 00    	vpclmullqlqdq xmm3,xmm3,xmm4
  406556:	c5 e1 ef dd          	vpxor  xmm3,xmm3,xmm5
  40655a:	c5 f9 ef c3          	vpxor  xmm0,xmm0,xmm3
  40655e:	e9 54 f8 ff ff       	jmp    405db7 <chainhash_narrow.constprop.0+0x167>
  406563:	c5 f9 ef c0          	vpxor  xmm0,xmm0,xmm0
  406567:	b8 20 00 00 00       	mov    eax,0x20
  40656c:	45 31 e4             	xor    r12d,r12d
  40656f:	c5 f9 6f d0          	vmovdqa xmm2,xmm0
  406573:	e9 f9 f7 ff ff       	jmp    405d71 <chainhash_narrow.constprop.0+0x121>
  406578:	c5 f9 6f 1d a0 0b 00 	vmovdqa xmm3,XMMWORD PTR [rip+0xba0]        # 407120 <__PRETTY_FUNCTION__.6+0x30>
  40657f:	00 
  406580:	c5 f9 7f 5c 24 40    	vmovdqa XMMWORD PTR [rsp+0x40],xmm3
  406586:	c5 f9 6f 1d a2 0b 00 	vmovdqa xmm3,XMMWORD PTR [rip+0xba2]        # 407130 <__PRETTY_FUNCTION__.6+0x40>
  40658d:	00 
  40658e:	c5 f9 7f 5c 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm3
  406594:	e9 71 fd ff ff       	jmp    40630a <chainhash_narrow.constprop.0+0x6ba>
  406599:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

00000000004065a0 <ship>:
  4065a0:	55                   	push   rbp
  4065a1:	53                   	push   rbx
  4065a2:	48 81 ec 68 01 00 00 	sub    rsp,0x168
  4065a9:	48 81 fe 00 01 00 00 	cmp    rsi,0x100
  4065b0:	0f 87 ec 02 00 00    	ja     4068a2 <ship+0x302>
  4065b6:	48 8b 2d e3 2b 00 00 	mov    rbp,QWORD PTR [rip+0x2be3]        # 4091a0 <shipped+0x100>
  4065bd:	48 89 f2             	mov    rdx,rsi
  4065c0:	48 89 f9             	mov    rcx,rdi
  4065c3:	48 8b 05 e6 2b 00 00 	mov    rax,QWORD PTR [rip+0x2be6]        # 4091b0 <shipped+0x110>
  4065ca:	66 0f 6f 3d ce 2b 00 	movdqa xmm7,XMMWORD PTR [rip+0x2bce]        # 4091a0 <shipped+0x100>
  4065d1:	00 
  4065d2:	66 44 0f 6f 15 35 0b 	movdqa xmm10,XMMWORD PTR [rip+0xb35]        # 407110 <__PRETTY_FUNCTION__.6+0x20>
  4065d9:	00 00 
  4065db:	48 31 e8             	xor    rax,rbp
  4065de:	66 4c 0f 6e d8       	movq   xmm11,rax
  4065e3:	0f 29 7c 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm7
  4065e8:	0f 1f 84 00 00 00 00 	nop    DWORD PTR [rax+rax*1+0x0]
  4065ef:	00 
  4065f0:	66 48 0f 6e ee       	movq   xmm5,rsi
  4065f5:	66 0f 6c ed          	punpcklqdq xmm5,xmm5
  4065f9:	48 83 fa 3f          	cmp    rdx,0x3f
  4065fd:	0f 86 e8 06 00 00    	jbe    406ceb <ship+0x74b>
  406603:	66 0f ef e4          	pxor   xmm4,xmm4
  406607:	b8 40 00 00 00       	mov    eax,0x40
  40660c:	66 0f 6f dc          	movdqa xmm3,xmm4
  406610:	f3 0f 6f 44 01 c0    	movdqu xmm0,XMMWORD PTR [rcx+rax*1-0x40]
  406616:	f3 0f 6f 54 01 d0    	movdqu xmm2,XMMWORD PTR [rcx+rax*1-0x30]
  40661c:	48 89 c3             	mov    rbx,rax
  40661f:	66 0f ef 90 70 90 40 	pxor   xmm2,XMMWORD PTR [rax+0x409070]
  406626:	00 
  406627:	66 0f ef 80 60 90 40 	pxor   xmm0,XMMWORD PTR [rax+0x409060]
  40662e:	00 
  40662f:	66 0f 6f f0          	movdqa xmm6,xmm0
  406633:	66 0f 3a 44 c2 00    	pclmullqlqdq xmm0,xmm2
  406639:	66 0f 6f c8          	movdqa xmm1,xmm0
  40663d:	f3 0f 6f 44 01 e0    	movdqu xmm0,XMMWORD PTR [rcx+rax*1-0x20]
  406643:	66 0f 3a 44 f2 11    	pclmulhqhqdq xmm6,xmm2
  406649:	66 0f ef 80 80 90 40 	pxor   xmm0,XMMWORD PTR [rax+0x409080]
  406650:	00 
  406651:	f3 0f 6f 54 01 f0    	movdqu xmm2,XMMWORD PTR [rcx+rax*1-0x10]
  406657:	66 0f ef ce          	pxor   xmm1,xmm6
  40665b:	48 8d 40 40          	lea    rax,[rax+0x40]
  40665f:	66 0f ef 90 50 90 40 	pxor   xmm2,XMMWORD PTR [rax+0x409050]
  406666:	00 
  406667:	66 0f 6f f0          	movdqa xmm6,xmm0
  40666b:	66 0f ef cb          	pxor   xmm1,xmm3
  40666f:	66 0f 3a 44 f2 11    	pclmulhqhqdq xmm6,xmm2
  406675:	66 0f 3a 44 c2 00    	pclmullqlqdq xmm0,xmm2
  40667b:	66 0f 6f d9          	movdqa xmm3,xmm1
  40667f:	66 0f ef c6          	pxor   xmm0,xmm6
  406683:	66 0f ef c4          	pxor   xmm0,xmm4
  406687:	66 0f 6f e0          	movdqa xmm4,xmm0
  40668b:	48 39 c2             	cmp    rdx,rax
  40668e:	73 80                	jae    406610 <ship+0x70>
  406690:	48 8d 43 20          	lea    rax,[rbx+0x20]
  406694:	48 39 c2             	cmp    rdx,rax
  406697:	0f 83 24 01 00 00    	jae    4067c1 <ship+0x221>
  40669d:	48 39 da             	cmp    rdx,rbx
  4066a0:	0f 87 5c 01 00 00    	ja     406802 <ship+0x262>
  4066a6:	66 48 0f 6e d5       	movq   xmm2,rbp
  4066ab:	66 0f ef 6c 24 30    	pxor   xmm5,XMMWORD PTR [rsp+0x30]
  4066b1:	48 8b 05 00 2b 00 00 	mov    rax,QWORD PTR [rip+0x2b00]        # 4091b8 <shipped+0x118>
  4066b8:	66 0f ef ca          	pxor   xmm1,xmm2
  4066bc:	66 0f ef e9          	pxor   xmm5,xmm1
  4066c0:	66 0f ef e8          	pxor   xmm5,xmm0
  4066c4:	66 0f 6f cd          	movdqa xmm1,xmm5
  4066c8:	66 41 0f 3a 44 cb 01 	pclmulhqlqdq xmm1,xmm11
  4066cf:	66 0f 6f c1          	movdqa xmm0,xmm1
  4066d3:	66 0f ef cd          	pxor   xmm1,xmm5
  4066d7:	66 41 0f 3a 44 c2 11 	pclmulhqhqdq xmm0,xmm10
  4066de:	66 0f 6f d0          	movdqa xmm2,xmm0
  4066e2:	66 41 0f 3a 44 d2 11 	pclmulhqhqdq xmm2,xmm10
  4066e9:	66 0f ef c2          	pxor   xmm0,xmm2
  4066ed:	66 0f ef c8          	pxor   xmm1,xmm0
  4066f1:	f3 0f 7e 05 e7 2a 00 	movq   xmm0,QWORD PTR [rip+0x2ae7]        # 4091e0 <shipped+0x140>
  4066f8:	00 
  4066f9:	66 0f d4 c8          	paddq  xmm1,xmm0
  4066fd:	66 0f 6f c1          	movdqa xmm0,xmm1
  406701:	66 0f 3a 44 c1 00    	pclmullqlqdq xmm0,xmm1
  406707:	66 0f 6f d0          	movdqa xmm2,xmm0
  40670b:	66 41 0f 3a 44 d2 11 	pclmulhqhqdq xmm2,xmm10
  406712:	66 0f 6f da          	movdqa xmm3,xmm2
  406716:	66 0f ef c2          	pxor   xmm0,xmm2
  40671a:	66 48 0f 6e d0       	movq   xmm2,rax
  40671f:	48 33 05 9a 2a 00 00 	xor    rax,QWORD PTR [rip+0x2a9a]        # 4091c0 <shipped+0x120>
  406726:	66 41 0f 3a 44 da 11 	pclmulhqhqdq xmm3,xmm10
  40672d:	66 0f ef d3          	pxor   xmm2,xmm3
  406731:	66 0f ef c2          	pxor   xmm0,xmm2
  406735:	66 48 0f 6e d0       	movq   xmm2,rax
  40673a:	66 0f ef d0          	pxor   xmm2,xmm0
  40673e:	66 0f ef d1          	pxor   xmm2,xmm1
  406742:	66 0f 3a 44 c2 00    	pclmullqlqdq xmm0,xmm2
  406748:	f3 0f 7e 15 78 2a 00 	movq   xmm2,QWORD PTR [rip+0x2a78]        # 4091c8 <shipped+0x128>
  40674f:	00 
  406750:	66 0f 6f d8          	movdqa xmm3,xmm0
  406754:	66 41 0f 3a 44 da 11 	pclmulhqhqdq xmm3,xmm10
  40675b:	66 0f ef ca          	pxor   xmm1,xmm2
  40675f:	f3 0f 7e 15 69 2a 00 	movq   xmm2,QWORD PTR [rip+0x2a69]        # 4091d0 <shipped+0x130>
  406766:	00 
  406767:	66 0f 6f e3          	movdqa xmm4,xmm3
  40676b:	66 0f ef c3          	pxor   xmm0,xmm3
  40676f:	66 41 0f 3a 44 e2 11 	pclmulhqhqdq xmm4,xmm10
  406776:	66 0f ef d4          	pxor   xmm2,xmm4
  40677a:	66 0f ef d0          	pxor   xmm2,xmm0
  40677e:	66 0f 3a 44 ca 00    	pclmullqlqdq xmm1,xmm2
  406784:	66 0f 6f d1          	movdqa xmm2,xmm1
  406788:	66 0f 6f c1          	movdqa xmm0,xmm1
  40678c:	f3 0f 7e 0d 44 2a 00 	movq   xmm1,QWORD PTR [rip+0x2a44]        # 4091d8 <shipped+0x138>
  406793:	00 
  406794:	48 81 c4 68 01 00 00 	add    rsp,0x168
  40679b:	66 41 0f 3a 44 d2 11 	pclmulhqhqdq xmm2,xmm10
  4067a2:	5b                   	pop    rbx
  4067a3:	5d                   	pop    rbp
  4067a4:	66 0f 6f da          	movdqa xmm3,xmm2
  4067a8:	66 0f ef c2          	pxor   xmm0,xmm2
  4067ac:	66 41 0f 3a 44 da 11 	pclmulhqhqdq xmm3,xmm10
  4067b3:	66 0f ef cb          	pxor   xmm1,xmm3
  4067b7:	66 0f ef c1          	pxor   xmm0,xmm1
  4067bb:	66 48 0f 7e c0       	movq   rax,xmm0
  4067c0:	c3                   	ret    
  4067c1:	48 8d 34 19          	lea    rsi,[rcx+rbx*1]
  4067c5:	f3 0f 6f 16          	movdqu xmm2,XMMWORD PTR [rsi]
  4067c9:	66 0f ef 93 a0 90 40 	pxor   xmm2,XMMWORD PTR [rbx+0x4090a0]
  4067d0:	00 
  4067d1:	f3 0f 6f 5e 10       	movdqu xmm3,XMMWORD PTR [rsi+0x10]
  4067d6:	66 0f ef 9b b0 90 40 	pxor   xmm3,XMMWORD PTR [rbx+0x4090b0]
  4067dd:	00 
  4067de:	48 89 c3             	mov    rbx,rax
  4067e1:	66 0f 6f e2          	movdqa xmm4,xmm2
  4067e5:	66 0f 3a 44 e3 11    	pclmulhqhqdq xmm4,xmm3
  4067eb:	66 0f 3a 44 d3 00    	pclmullqlqdq xmm2,xmm3
  4067f1:	66 0f ef d4          	pxor   xmm2,xmm4
  4067f5:	66 0f ef ca          	pxor   xmm1,xmm2
  4067f9:	48 39 da             	cmp    rdx,rbx
  4067fc:	0f 86 a4 fe ff ff    	jbe    4066a6 <ship+0x106>
  406802:	66 0f ef d2          	pxor   xmm2,xmm2
  406806:	48 29 da             	sub    rdx,rbx
  406809:	48 8d 34 19          	lea    rsi,[rcx+rbx*1]
  40680d:	0f 29 44 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm0
  406812:	48 8d bc 24 40 01 00 	lea    rdi,[rsp+0x140]
  406819:	00 
  40681a:	44 0f 29 54 24 50    	movaps XMMWORD PTR [rsp+0x50],xmm10
  406820:	0f 29 4c 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm1
  406825:	0f 29 6c 24 10       	movaps XMMWORD PTR [rsp+0x10],xmm5
  40682a:	44 0f 29 1c 24       	movaps XMMWORD PTR [rsp],xmm11
  40682f:	0f 29 94 24 40 01 00 	movaps XMMWORD PTR [rsp+0x140],xmm2
  406836:	00 
  406837:	0f 29 94 24 50 01 00 	movaps XMMWORD PTR [rsp+0x150],xmm2
  40683e:	00 
  40683f:	e8 2c a8 ff ff       	call   401070 <memcpy@plt>
  406844:	66 0f 6f 44 24 40    	movdqa xmm0,XMMWORD PTR [rsp+0x40]
  40684a:	66 0f 6f 94 24 40 01 	movdqa xmm2,XMMWORD PTR [rsp+0x140]
  406851:	00 00 
  406853:	66 0f ef 93 a0 90 40 	pxor   xmm2,XMMWORD PTR [rbx+0x4090a0]
  40685a:	00 
  40685b:	66 44 0f 6f 54 24 50 	movdqa xmm10,XMMWORD PTR [rsp+0x50]
  406862:	66 0f 6f 9c 24 50 01 	movdqa xmm3,XMMWORD PTR [rsp+0x150]
  406869:	00 00 
  40686b:	66 0f ef 9b b0 90 40 	pxor   xmm3,XMMWORD PTR [rbx+0x4090b0]
  406872:	00 
  406873:	66 0f 6f e2          	movdqa xmm4,xmm2
  406877:	66 0f 6f 4c 24 20    	movdqa xmm1,XMMWORD PTR [rsp+0x20]
  40687d:	66 0f 6f 6c 24 10    	movdqa xmm5,XMMWORD PTR [rsp+0x10]
  406883:	66 0f 3a 44 e3 11    	pclmulhqhqdq xmm4,xmm3
  406889:	66 0f 3a 44 d3 00    	pclmullqlqdq xmm2,xmm3
  40688f:	66 44 0f 6f 1c 24    	movdqa xmm11,XMMWORD PTR [rsp]
  406895:	66 0f ef d4          	pxor   xmm2,xmm4
  406899:	66 0f ef c2          	pxor   xmm0,xmm2
  40689d:	e9 04 fe ff ff       	jmp    4066a6 <ship+0x106>
  4068a2:	44 8b 05 db 27 00 00 	mov    r8d,DWORD PTR [rip+0x27db]        # 409084 <cached.1>
  4068a9:	45 85 c0             	test   r8d,r8d
  4068ac:	0f 84 79 03 00 00    	je     406c2b <ship+0x68b>
  4068b2:	41 83 e8 01          	sub    r8d,0x1
  4068b6:	0f 85 e8 03 00 00    	jne    406ca4 <ship+0x704>
  4068bc:	66 0f 6f 3d dc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27dc]        # 4090a0 <shipped>
  4068c3:	00 
  4068c4:	48 8b 2d d5 28 00 00 	mov    rbp,QWORD PTR [rip+0x28d5]        # 4091a0 <shipped+0x100>
  4068cb:	48 8b 05 de 28 00 00 	mov    rax,QWORD PTR [rip+0x28de]        # 4091b0 <shipped+0x110>
  4068d2:	0f 29 7c 24 40       	movaps XMMWORD PTR [rsp+0x40],xmm7
  4068d7:	66 0f 6f 3d d1 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27d1]        # 4090b0 <shipped+0x10>
  4068de:	00 
  4068df:	48 31 e8             	xor    rax,rbp
  4068e2:	0f 29 7c 24 50       	movaps XMMWORD PTR [rsp+0x50],xmm7
  4068e7:	66 0f 6f 3d d1 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27d1]        # 4090c0 <shipped+0x20>
  4068ee:	00 
  4068ef:	66 4c 0f 6e d8       	movq   xmm11,rax
  4068f4:	48 8d 86 ff fe ff ff 	lea    rax,[rsi-0x101]
  4068fb:	48 c1 e8 08          	shr    rax,0x8
  4068ff:	0f 29 7c 24 60       	movaps XMMWORD PTR [rsp+0x60],xmm7
  406904:	66 0f 6f 3d c4 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27c4]        # 4090d0 <shipped+0x30>
  40690b:	00 
  40690c:	48 8d 48 01          	lea    rcx,[rax+0x1]
  406910:	48 c1 e1 08          	shl    rcx,0x8
  406914:	0f 29 7c 24 70       	movaps XMMWORD PTR [rsp+0x70],xmm7
  406919:	66 0f 6f 3d bf 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bf]        # 4090e0 <shipped+0x40>
  406920:	00 
  406921:	48 01 f9             	add    rcx,rdi
  406924:	0f 29 bc 24 80 00 00 	movaps XMMWORD PTR [rsp+0x80],xmm7
  40692b:	00 
  40692c:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 4090f0 <shipped+0x50>
  406933:	00 
  406934:	0f 29 bc 24 90 00 00 	movaps XMMWORD PTR [rsp+0x90],xmm7
  40693b:	00 
  40693c:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409100 <shipped+0x60>
  406943:	00 
  406944:	0f 29 bc 24 a0 00 00 	movaps XMMWORD PTR [rsp+0xa0],xmm7
  40694b:	00 
  40694c:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409110 <shipped+0x70>
  406953:	00 
  406954:	0f 29 bc 24 b0 00 00 	movaps XMMWORD PTR [rsp+0xb0],xmm7
  40695b:	00 
  40695c:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409120 <shipped+0x80>
  406963:	00 
  406964:	0f 29 bc 24 c0 00 00 	movaps XMMWORD PTR [rsp+0xc0],xmm7
  40696b:	00 
  40696c:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409130 <shipped+0x90>
  406973:	00 
  406974:	0f 29 bc 24 d0 00 00 	movaps XMMWORD PTR [rsp+0xd0],xmm7
  40697b:	00 
  40697c:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409140 <shipped+0xa0>
  406983:	00 
  406984:	0f 29 bc 24 e0 00 00 	movaps XMMWORD PTR [rsp+0xe0],xmm7
  40698b:	00 
  40698c:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409150 <shipped+0xb0>
  406993:	00 
  406994:	0f 29 bc 24 f0 00 00 	movaps XMMWORD PTR [rsp+0xf0],xmm7
  40699b:	00 
  40699c:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409160 <shipped+0xc0>
  4069a3:	00 
  4069a4:	0f 29 bc 24 00 01 00 	movaps XMMWORD PTR [rsp+0x100],xmm7
  4069ab:	00 
  4069ac:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409170 <shipped+0xd0>
  4069b3:	00 
  4069b4:	0f 29 bc 24 10 01 00 	movaps XMMWORD PTR [rsp+0x110],xmm7
  4069bb:	00 
  4069bc:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409180 <shipped+0xe0>
  4069c3:	00 
  4069c4:	0f 29 bc 24 20 01 00 	movaps XMMWORD PTR [rsp+0x120],xmm7
  4069cb:	00 
  4069cc:	66 0f 6f 3d bc 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27bc]        # 409190 <shipped+0xf0>
  4069d3:	00 
  4069d4:	66 44 0f 6f 15 33 07 	movdqa xmm10,XMMWORD PTR [rip+0x733]        # 407110 <__PRETTY_FUNCTION__.6+0x20>
  4069db:	00 00 
  4069dd:	0f 29 bc 24 30 01 00 	movaps XMMWORD PTR [rsp+0x130],xmm7
  4069e4:	00 
  4069e5:	66 0f 6f 3d b3 27 00 	movdqa xmm7,XMMWORD PTR [rip+0x27b3]        # 4091a0 <shipped+0x100>
  4069ec:	00 
  4069ed:	0f 29 7c 24 30       	movaps XMMWORD PTR [rsp+0x30],xmm7
  4069f2:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  4069f8:	f3 0f 6f 0f          	movdqu xmm1,XMMWORD PTR [rdi]
  4069fc:	66 0f ef 4c 24 40    	pxor   xmm1,XMMWORD PTR [rsp+0x40]
  406a02:	48 81 c7 00 01 00 00 	add    rdi,0x100
  406a09:	f3 0f 6f 87 10 ff ff 	movdqu xmm0,XMMWORD PTR [rdi-0xf0]
  406a10:	ff 
  406a11:	66 0f ef 44 24 50    	pxor   xmm0,XMMWORD PTR [rsp+0x50]
  406a17:	66 0f 6f f9          	movdqa xmm7,xmm1
  406a1b:	f3 0f 6f af 30 ff ff 	movdqu xmm5,XMMWORD PTR [rdi-0xd0]
  406a22:	ff 
  406a23:	66 0f ef 6c 24 70    	pxor   xmm5,XMMWORD PTR [rsp+0x70]
  406a29:	66 0f 3a 44 f8 11    	pclmulhqhqdq xmm7,xmm0
  406a2f:	66 0f 3a 44 c8 00    	pclmullqlqdq xmm1,xmm0
  406a35:	f3 0f 6f 87 20 ff ff 	movdqu xmm0,XMMWORD PTR [rdi-0xe0]
  406a3c:	ff 
  406a3d:	66 0f ef 44 24 60    	pxor   xmm0,XMMWORD PTR [rsp+0x60]
  406a43:	f3 0f 6f 9f 40 ff ff 	movdqu xmm3,XMMWORD PTR [rdi-0xc0]
  406a4a:	ff 
  406a4b:	f3 0f 6f 97 60 ff ff 	movdqu xmm2,XMMWORD PTR [rdi-0xa0]
  406a52:	ff 
  406a53:	0f 29 3c 24          	movaps XMMWORD PTR [rsp],xmm7
  406a57:	66 0f ef 9c 24 80 00 	pxor   xmm3,XMMWORD PTR [rsp+0x80]
  406a5e:	00 00 
  406a60:	66 0f 6f f0          	movdqa xmm6,xmm0
  406a64:	66 0f 3a 44 c5 00    	pclmullqlqdq xmm0,xmm5
  406a6a:	f3 0f 6f a7 70 ff ff 	movdqu xmm4,XMMWORD PTR [rdi-0x90]
  406a71:	ff 
  406a72:	66 0f 3a 44 f5 11    	pclmulhqhqdq xmm6,xmm5
  406a78:	f3 0f 6f af 50 ff ff 	movdqu xmm5,XMMWORD PTR [rdi-0xb0]
  406a7f:	ff 
  406a80:	0f 29 4c 24 10       	movaps XMMWORD PTR [rsp+0x10],xmm1
  406a85:	66 0f ef ac 24 90 00 	pxor   xmm5,XMMWORD PTR [rsp+0x90]
  406a8c:	00 00 
  406a8e:	0f 29 74 24 20       	movaps XMMWORD PTR [rsp+0x20],xmm6
  406a93:	66 44 0f 6f fb       	movdqa xmm15,xmm3
  406a98:	f3 0f 6f 77 80       	movdqu xmm6,XMMWORD PTR [rdi-0x80]
  406a9d:	66 0f ef b4 24 c0 00 	pxor   xmm6,XMMWORD PTR [rsp+0xc0]
  406aa4:	00 00 
  406aa6:	66 0f ef 94 24 a0 00 	pxor   xmm2,XMMWORD PTR [rsp+0xa0]
  406aad:	00 00 
  406aaf:	66 44 0f 3a 44 fd 11 	pclmulhqhqdq xmm15,xmm5
  406ab6:	66 0f 3a 44 dd 00    	pclmullqlqdq xmm3,xmm5
  406abc:	f3 0f 6f 6f 90       	movdqu xmm5,XMMWORD PTR [rdi-0x70]
  406ac1:	66 0f ef ac 24 d0 00 	pxor   xmm5,XMMWORD PTR [rsp+0xd0]
  406ac8:	00 00 
  406aca:	66 0f 6f fe          	movdqa xmm7,xmm6
  406ace:	66 41 0f ef df       	pxor   xmm3,xmm15
  406ad3:	66 0f ef a4 24 b0 00 	pxor   xmm4,XMMWORD PTR [rsp+0xb0]
  406ada:	00 00 
  406adc:	66 44 0f 6f f2       	movdqa xmm14,xmm2
  406ae1:	66 0f 3a 44 fd 11    	pclmulhqhqdq xmm7,xmm5
  406ae7:	66 0f 3a 44 f5 00    	pclmullqlqdq xmm6,xmm5
  406aed:	f3 0f 6f 6f a0       	movdqu xmm5,XMMWORD PTR [rdi-0x60]
  406af2:	66 0f ef ac 24 e0 00 	pxor   xmm5,XMMWORD PTR [rsp+0xe0]
  406af9:	00 00 
  406afb:	66 44 0f 3a 44 f4 11 	pclmulhqhqdq xmm14,xmm4
  406b02:	66 0f 3a 44 d4 00    	pclmullqlqdq xmm2,xmm4
  406b08:	f3 0f 6f 67 b0       	movdqu xmm4,XMMWORD PTR [rdi-0x50]
  406b0d:	66 0f ef a4 24 f0 00 	pxor   xmm4,XMMWORD PTR [rsp+0xf0]
  406b14:	00 00 
  406b16:	66 44 0f 6f ed       	movdqa xmm13,xmm5
  406b1b:	66 41 0f ef d6       	pxor   xmm2,xmm14
  406b20:	66 44 0f 3a 44 ec 11 	pclmulhqhqdq xmm13,xmm4
  406b27:	66 0f 3a 44 ec 00    	pclmullqlqdq xmm5,xmm4
  406b2d:	f3 0f 6f 67 c0       	movdqu xmm4,XMMWORD PTR [rdi-0x40]
  406b32:	66 0f ef a4 24 00 01 	pxor   xmm4,XMMWORD PTR [rsp+0x100]
  406b39:	00 00 
  406b3b:	66 0f ef d6          	pxor   xmm2,xmm6
  406b3f:	66 0f ef fd          	pxor   xmm7,xmm5
  406b43:	66 0f 6f cc          	movdqa xmm1,xmm4
  406b47:	f3 0f 6f 67 d0       	movdqu xmm4,XMMWORD PTR [rdi-0x30]
  406b4c:	66 41 0f ef fd       	pxor   xmm7,xmm13
  406b51:	66 0f ef a4 24 10 01 	pxor   xmm4,XMMWORD PTR [rsp+0x110]
  406b58:	00 00 
  406b5a:	66 44 0f 6f e1       	movdqa xmm12,xmm1
  406b5f:	66 44 0f 3a 44 e4 11 	pclmulhqhqdq xmm12,xmm4
  406b66:	66 0f 3a 44 cc 00    	pclmullqlqdq xmm1,xmm4
  406b6c:	f3 0f 6f 67 e0       	movdqu xmm4,XMMWORD PTR [rdi-0x20]
  406b71:	66 0f ef a4 24 20 01 	pxor   xmm4,XMMWORD PTR [rsp+0x120]
  406b78:	00 00 
  406b7a:	f3 44 0f 6f 4f f0    	movdqu xmm9,XMMWORD PTR [rdi-0x10]
  406b80:	66 0f ef 44 24 20    	pxor   xmm0,XMMWORD PTR [rsp+0x20]
  406b86:	66 41 0f ef cc       	pxor   xmm1,xmm12
  406b8b:	66 44 0f ef 8c 24 30 	pxor   xmm9,XMMWORD PTR [rsp+0x130]
  406b92:	01 00 00 
  406b95:	66 0f ef 5c 24 30    	pxor   xmm3,XMMWORD PTR [rsp+0x30]
  406b9b:	66 45 0f 6f c1       	movdqa xmm8,xmm9
  406ba0:	66 44 0f 6f cc       	movdqa xmm9,xmm4
  406ba5:	66 45 0f 3a 44 c8 11 	pclmulhqhqdq xmm9,xmm8
  406bac:	66 41 0f 3a 44 e0 00 	pclmullqlqdq xmm4,xmm8
  406bb3:	66 44 0f 6f 44 24 10 	movdqa xmm8,XMMWORD PTR [rsp+0x10]
  406bba:	66 44 0f ef 04 24    	pxor   xmm8,XMMWORD PTR [rsp]
  406bc0:	66 0f ef cc          	pxor   xmm1,xmm4
  406bc4:	66 41 0f ef c0       	pxor   xmm0,xmm8
  406bc9:	66 0f ef c3          	pxor   xmm0,xmm3
  406bcd:	66 0f ef c2          	pxor   xmm0,xmm2
  406bd1:	66 0f ef c7          	pxor   xmm0,xmm7
  406bd5:	66 0f ef c1          	pxor   xmm0,xmm1
  406bd9:	66 41 0f ef c1       	pxor   xmm0,xmm9
  406bde:	66 0f 6f c8          	movdqa xmm1,xmm0
  406be2:	66 41 0f 3a 44 cb 01 	pclmulhqlqdq xmm1,xmm11
  406be9:	66 0f 6f d1          	movdqa xmm2,xmm1
  406bed:	66 41 0f 3a 44 d2 11 	pclmulhqhqdq xmm2,xmm10
  406bf4:	66 44 0f 6f da       	movdqa xmm11,xmm2
  406bf9:	66 0f ef ca          	pxor   xmm1,xmm2
  406bfd:	66 45 0f 3a 44 da 11 	pclmulhqhqdq xmm11,xmm10
  406c04:	66 44 0f ef d8       	pxor   xmm11,xmm0
  406c09:	66 44 0f ef d9       	pxor   xmm11,xmm1
  406c0e:	48 39 cf             	cmp    rdi,rcx
  406c11:	0f 85 e1 fd ff ff    	jne    4069f8 <ship+0x458>
  406c17:	48 f7 d8             	neg    rax
  406c1a:	48 c1 e0 08          	shl    rax,0x8
  406c1e:	48 8d 94 06 00 ff ff 	lea    rdx,[rsi+rax*1-0x100]
  406c25:	ff 
  406c26:	e9 c5 f9 ff ff       	jmp    4065f0 <ship+0x50>
  406c2b:	44 89 c0             	mov    eax,r8d
  406c2e:	0f a2                	cpuid  
  406c30:	85 c0                	test   eax,eax
  406c32:	0f 84 a4 00 00 00    	je     406cdc <ship+0x73c>
  406c38:	b8 01 00 00 00       	mov    eax,0x1
  406c3d:	0f a2                	cpuid  
  406c3f:	81 e1 00 00 00 18    	and    ecx,0x18000000
  406c45:	81 f9 00 00 00 18    	cmp    ecx,0x18000000
  406c4b:	0f 85 8b 00 00 00    	jne    406cdc <ship+0x73c>
  406c51:	44 89 c1             	mov    ecx,r8d
  406c54:	0f 01 d0             	xgetbv 
  406c57:	41 89 c1             	mov    r9d,eax
  406c5a:	83 e0 06             	and    eax,0x6
  406c5d:	83 f8 06             	cmp    eax,0x6
  406c60:	75 7a                	jne    406cdc <ship+0x73c>
  406c62:	44 89 c0             	mov    eax,r8d
  406c65:	0f a2                	cpuid  
  406c67:	83 f8 06             	cmp    eax,0x6
  406c6a:	76 70                	jbe    406cdc <ship+0x73c>
  406c6c:	b8 07 00 00 00       	mov    eax,0x7
  406c71:	44 89 c1             	mov    ecx,r8d
  406c74:	0f a2                	cpuid  
  406c76:	80 e5 04             	and    ch,0x4
  406c79:	74 61                	je     406cdc <ship+0x73c>
  406c7b:	f6 c3 20             	test   bl,0x20
  406c7e:	74 5c                	je     406cdc <ship+0x73c>
  406c80:	41 81 e1 e6 00 00 00 	and    r9d,0xe6
  406c87:	41 81 f9 e6 00 00 00 	cmp    r9d,0xe6
  406c8e:	0f 84 17 01 00 00    	je     406dab <ship+0x80b>
  406c94:	c7 05 e6 23 00 00 02 	mov    DWORD PTR [rip+0x23e6],0x2        # 409084 <cached.1>
  406c9b:	00 00 00 
  406c9e:	41 b8 01 00 00 00    	mov    r8d,0x1
  406ca4:	44 8b 0d d5 23 00 00 	mov    r9d,DWORD PTR [rip+0x23d5]        # 409080 <cached.0>
  406cab:	45 85 c9             	test   r9d,r9d
  406cae:	74 4f                	je     406cff <ship+0x75f>
  406cb0:	41 83 f9 01          	cmp    r9d,0x1
  406cb4:	0f 85 e3 00 00 00    	jne    406d9d <ship+0x7fd>
  406cba:	41 83 f8 02          	cmp    r8d,0x2
  406cbe:	0f 84 cb 00 00 00    	je     406d8f <ship+0x7ef>
  406cc4:	41 83 f8 01          	cmp    r8d,0x1
  406cc8:	0f 85 ee fb ff ff    	jne    4068bc <ship+0x31c>
  406cce:	48 81 c4 68 01 00 00 	add    rsp,0x168
  406cd5:	5b                   	pop    rbx
  406cd6:	5d                   	pop    rbp
  406cd7:	e9 c4 e2 ff ff       	jmp    404fa0 <chainhash_wide256.constprop.0>
  406cdc:	c7 05 9e 23 00 00 01 	mov    DWORD PTR [rip+0x239e],0x1        # 409084 <cached.1>
  406ce3:	00 00 00 
  406ce6:	e9 d1 fb ff ff       	jmp    4068bc <ship+0x31c>
  406ceb:	66 0f ef c0          	pxor   xmm0,xmm0
  406cef:	b8 20 00 00 00       	mov    eax,0x20
  406cf4:	31 db                	xor    ebx,ebx
  406cf6:	66 0f 6f c8          	movdqa xmm1,xmm0
  406cfa:	e9 95 f9 ff ff       	jmp    406694 <ship+0xf4>
  406cff:	44 89 c8             	mov    eax,r9d
  406d02:	0f a2                	cpuid  
  406d04:	85 c0                	test   eax,eax
  406d06:	74 78                	je     406d80 <ship+0x7e0>
  406d08:	44 89 c8             	mov    eax,r9d
  406d0b:	0f a2                	cpuid  
  406d0d:	81 fa 69 6e 65 49    	cmp    edx,0x49656e69
  406d13:	0f 95 c0             	setne  al
  406d16:	81 fb 47 65 6e 75    	cmp    ebx,0x756e6547
  406d1c:	0f 95 c2             	setne  dl
  406d1f:	08 d0                	or     al,dl
  406d21:	75 5d                	jne    406d80 <ship+0x7e0>
  406d23:	81 f9 6e 74 65 6c    	cmp    ecx,0x6c65746e
  406d29:	75 55                	jne    406d80 <ship+0x7e0>
  406d2b:	44 89 c8             	mov    eax,r9d
  406d2e:	0f a2                	cpuid  
  406d30:	85 c0                	test   eax,eax
  406d32:	74 4c                	je     406d80 <ship+0x7e0>
  406d34:	b8 01 00 00 00       	mov    eax,0x1
  406d39:	0f a2                	cpuid  
  406d3b:	89 c2                	mov    edx,eax
  406d3d:	89 c1                	mov    ecx,eax
  406d3f:	c1 ea 04             	shr    edx,0x4
  406d42:	c1 e9 0c             	shr    ecx,0xc
  406d45:	83 e2 0f             	and    edx,0xf
  406d48:	81 e1 f0 00 00 00    	and    ecx,0xf0
  406d4e:	09 ca                	or     edx,ecx
  406d50:	83 fa 6a             	cmp    edx,0x6a
  406d53:	0f 94 c2             	sete   dl
  406d56:	c1 e8 08             	shr    eax,0x8
  406d59:	45 31 c9             	xor    r9d,r9d
  406d5c:	83 e0 0f             	and    eax,0xf
  406d5f:	83 f8 06             	cmp    eax,0x6
  406d62:	41 0f 94 c1          	sete   r9b
  406d66:	41 21 d1             	and    r9d,edx
  406d69:	41 83 c1 01          	add    r9d,0x1
  406d6d:	44 89 0d 0c 23 00 00 	mov    DWORD PTR [rip+0x230c],r9d        # 409080 <cached.0>
  406d74:	e9 37 ff ff ff       	jmp    406cb0 <ship+0x710>
  406d79:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
  406d80:	c7 05 f6 22 00 00 01 	mov    DWORD PTR [rip+0x22f6],0x1        # 409080 <cached.0>
  406d87:	00 00 00 
  406d8a:	e9 2b ff ff ff       	jmp    406cba <ship+0x71a>
  406d8f:	48 81 c4 68 01 00 00 	add    rsp,0x168
  406d96:	5b                   	pop    rbx
  406d97:	5d                   	pop    rbp
  406d98:	e9 f3 e8 ff ff       	jmp    405690 <chainhash_wide512.constprop.0>
  406d9d:	48 81 c4 68 01 00 00 	add    rsp,0x168
  406da4:	5b                   	pop    rbx
  406da5:	5d                   	pop    rbp
  406da6:	e9 a5 ee ff ff       	jmp    405c50 <chainhash_narrow.constprop.0>
  406dab:	81 e3 00 00 01 00    	and    ebx,0x10000
  406db1:	0f 84 dd fe ff ff    	je     406c94 <ship+0x6f4>
  406db7:	c7 05 c3 22 00 00 03 	mov    DWORD PTR [rip+0x22c3],0x3        # 409084 <cached.1>
  406dbe:	00 00 00 
  406dc1:	41 b8 02 00 00 00    	mov    r8d,0x2
  406dc7:	e9 d8 fe ff ff       	jmp    406ca4 <ship+0x704>

Disassembly of section .fini:

0000000000406dcc <_fini>:
  406dcc:	f3 0f 1e fa          	endbr64 
  406dd0:	48 83 ec 08          	sub    rsp,0x8
  406dd4:	48 83 c4 08          	add    rsp,0x8
  406dd8:	c3                   	ret    
