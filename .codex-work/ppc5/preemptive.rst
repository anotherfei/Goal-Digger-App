                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ISO C Compiler
                                      3 ; Version 4.5.0 #15242 (MINGW64)
                                      4 ;--------------------------------------------------------
                                      5 	.module preemptive
                                      6 	
                                      7 	.optsdcc -mmcs51 --model-small
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _Bootstrap
                                     12 	.globl _main
                                     13 	.globl _CY
                                     14 	.globl _AC
                                     15 	.globl _F0
                                     16 	.globl _RS1
                                     17 	.globl _RS0
                                     18 	.globl _OV
                                     19 	.globl _F1
                                     20 	.globl _P
                                     21 	.globl _PS
                                     22 	.globl _PT1
                                     23 	.globl _PX1
                                     24 	.globl _PT0
                                     25 	.globl _PX0
                                     26 	.globl _RD
                                     27 	.globl _WR
                                     28 	.globl _T1
                                     29 	.globl _T0
                                     30 	.globl _INT1
                                     31 	.globl _INT0
                                     32 	.globl _TXD
                                     33 	.globl _RXD
                                     34 	.globl _P3_7
                                     35 	.globl _P3_6
                                     36 	.globl _P3_5
                                     37 	.globl _P3_4
                                     38 	.globl _P3_3
                                     39 	.globl _P3_2
                                     40 	.globl _P3_1
                                     41 	.globl _P3_0
                                     42 	.globl _EA
                                     43 	.globl _ES
                                     44 	.globl _ET1
                                     45 	.globl _EX1
                                     46 	.globl _ET0
                                     47 	.globl _EX0
                                     48 	.globl _P2_7
                                     49 	.globl _P2_6
                                     50 	.globl _P2_5
                                     51 	.globl _P2_4
                                     52 	.globl _P2_3
                                     53 	.globl _P2_2
                                     54 	.globl _P2_1
                                     55 	.globl _P2_0
                                     56 	.globl _SM0
                                     57 	.globl _SM1
                                     58 	.globl _SM2
                                     59 	.globl _REN
                                     60 	.globl _TB8
                                     61 	.globl _RB8
                                     62 	.globl _TI
                                     63 	.globl _RI
                                     64 	.globl _P1_7
                                     65 	.globl _P1_6
                                     66 	.globl _P1_5
                                     67 	.globl _P1_4
                                     68 	.globl _P1_3
                                     69 	.globl _P1_2
                                     70 	.globl _P1_1
                                     71 	.globl _P1_0
                                     72 	.globl _TF1
                                     73 	.globl _TR1
                                     74 	.globl _TF0
                                     75 	.globl _TR0
                                     76 	.globl _IE1
                                     77 	.globl _IT1
                                     78 	.globl _IE0
                                     79 	.globl _IT0
                                     80 	.globl _P0_7
                                     81 	.globl _P0_6
                                     82 	.globl _P0_5
                                     83 	.globl _P0_4
                                     84 	.globl _P0_3
                                     85 	.globl _P0_2
                                     86 	.globl _P0_1
                                     87 	.globl _P0_0
                                     88 	.globl _B
                                     89 	.globl _ACC
                                     90 	.globl _PSW
                                     91 	.globl _IP
                                     92 	.globl _P3
                                     93 	.globl _IE
                                     94 	.globl _P2
                                     95 	.globl _SBUF
                                     96 	.globl _SCON
                                     97 	.globl _P1
                                     98 	.globl _TH1
                                     99 	.globl _TH0
                                    100 	.globl _TL1
                                    101 	.globl _TL0
                                    102 	.globl _TMOD
                                    103 	.globl _TCON
                                    104 	.globl _PCON
                                    105 	.globl _DPH
                                    106 	.globl _DPL
                                    107 	.globl _SP
                                    108 	.globl _P0
                                    109 	.globl _oldStackTop
                                    110 	.globl _pswSeed
                                    111 	.globl _nextSlot
                                    112 	.globl _savedStackPointers
                                    113 	.globl _threadBitmap
                                    114 	.globl _activeThreadID
                                    115 	.globl _ThreadCreate
                                    116 	.globl _ThreadYield
                                    117 	.globl _ThreadExit
                                    118 	.globl _myTimer0Handler
                                    119 ;--------------------------------------------------------
                                    120 ; special function registers
                                    121 ;--------------------------------------------------------
                                    122 	.area RSEG    (ABS,DATA)
      000000                        123 	.org 0x0000
                           000080   124 _P0	=	0x0080
                           000081   125 _SP	=	0x0081
                           000082   126 _DPL	=	0x0082
                           000083   127 _DPH	=	0x0083
                           000087   128 _PCON	=	0x0087
                           000088   129 _TCON	=	0x0088
                           000089   130 _TMOD	=	0x0089
                           00008A   131 _TL0	=	0x008a
                           00008B   132 _TL1	=	0x008b
                           00008C   133 _TH0	=	0x008c
                           00008D   134 _TH1	=	0x008d
                           000090   135 _P1	=	0x0090
                           000098   136 _SCON	=	0x0098
                           000099   137 _SBUF	=	0x0099
                           0000A0   138 _P2	=	0x00a0
                           0000A8   139 _IE	=	0x00a8
                           0000B0   140 _P3	=	0x00b0
                           0000B8   141 _IP	=	0x00b8
                           0000D0   142 _PSW	=	0x00d0
                           0000E0   143 _ACC	=	0x00e0
                           0000F0   144 _B	=	0x00f0
                                    145 ;--------------------------------------------------------
                                    146 ; special function bits
                                    147 ;--------------------------------------------------------
                                    148 	.area RSEG    (ABS,DATA)
      000000                        149 	.org 0x0000
                           000080   150 _P0_0	=	0x0080
                           000081   151 _P0_1	=	0x0081
                           000082   152 _P0_2	=	0x0082
                           000083   153 _P0_3	=	0x0083
                           000084   154 _P0_4	=	0x0084
                           000085   155 _P0_5	=	0x0085
                           000086   156 _P0_6	=	0x0086
                           000087   157 _P0_7	=	0x0087
                           000088   158 _IT0	=	0x0088
                           000089   159 _IE0	=	0x0089
                           00008A   160 _IT1	=	0x008a
                           00008B   161 _IE1	=	0x008b
                           00008C   162 _TR0	=	0x008c
                           00008D   163 _TF0	=	0x008d
                           00008E   164 _TR1	=	0x008e
                           00008F   165 _TF1	=	0x008f
                           000090   166 _P1_0	=	0x0090
                           000091   167 _P1_1	=	0x0091
                           000092   168 _P1_2	=	0x0092
                           000093   169 _P1_3	=	0x0093
                           000094   170 _P1_4	=	0x0094
                           000095   171 _P1_5	=	0x0095
                           000096   172 _P1_6	=	0x0096
                           000097   173 _P1_7	=	0x0097
                           000098   174 _RI	=	0x0098
                           000099   175 _TI	=	0x0099
                           00009A   176 _RB8	=	0x009a
                           00009B   177 _TB8	=	0x009b
                           00009C   178 _REN	=	0x009c
                           00009D   179 _SM2	=	0x009d
                           00009E   180 _SM1	=	0x009e
                           00009F   181 _SM0	=	0x009f
                           0000A0   182 _P2_0	=	0x00a0
                           0000A1   183 _P2_1	=	0x00a1
                           0000A2   184 _P2_2	=	0x00a2
                           0000A3   185 _P2_3	=	0x00a3
                           0000A4   186 _P2_4	=	0x00a4
                           0000A5   187 _P2_5	=	0x00a5
                           0000A6   188 _P2_6	=	0x00a6
                           0000A7   189 _P2_7	=	0x00a7
                           0000A8   190 _EX0	=	0x00a8
                           0000A9   191 _ET0	=	0x00a9
                           0000AA   192 _EX1	=	0x00aa
                           0000AB   193 _ET1	=	0x00ab
                           0000AC   194 _ES	=	0x00ac
                           0000AF   195 _EA	=	0x00af
                           0000B0   196 _P3_0	=	0x00b0
                           0000B1   197 _P3_1	=	0x00b1
                           0000B2   198 _P3_2	=	0x00b2
                           0000B3   199 _P3_3	=	0x00b3
                           0000B4   200 _P3_4	=	0x00b4
                           0000B5   201 _P3_5	=	0x00b5
                           0000B6   202 _P3_6	=	0x00b6
                           0000B7   203 _P3_7	=	0x00b7
                           0000B0   204 _RXD	=	0x00b0
                           0000B1   205 _TXD	=	0x00b1
                           0000B2   206 _INT0	=	0x00b2
                           0000B3   207 _INT1	=	0x00b3
                           0000B4   208 _T0	=	0x00b4
                           0000B5   209 _T1	=	0x00b5
                           0000B6   210 _WR	=	0x00b6
                           0000B7   211 _RD	=	0x00b7
                           0000B8   212 _PX0	=	0x00b8
                           0000B9   213 _PT0	=	0x00b9
                           0000BA   214 _PX1	=	0x00ba
                           0000BB   215 _PT1	=	0x00bb
                           0000BC   216 _PS	=	0x00bc
                           0000D0   217 _P	=	0x00d0
                           0000D1   218 _F1	=	0x00d1
                           0000D2   219 _OV	=	0x00d2
                           0000D3   220 _RS0	=	0x00d3
                           0000D4   221 _RS1	=	0x00d4
                           0000D5   222 _F0	=	0x00d5
                           0000D6   223 _AC	=	0x00d6
                           0000D7   224 _CY	=	0x00d7
                                    225 ;--------------------------------------------------------
                                    226 ; overlayable register banks
                                    227 ;--------------------------------------------------------
                                    228 	.area REG_BANK_0	(REL,OVR,DATA)
      000000                        229 	.ds 8
                                    230 ;--------------------------------------------------------
                                    231 ; internal ram data
                                    232 ;--------------------------------------------------------
                                    233 	.area DSEG    (DATA)
                           000033   234 _activeThreadID	=	0x0033
                           000034   235 _threadBitmap	=	0x0034
                           000035   236 _savedStackPointers	=	0x0035
                           00003A   237 _nextSlot	=	0x003a
                           00003B   238 _pswSeed	=	0x003b
                           00003C   239 _oldStackTop	=	0x003c
                                    240 ;--------------------------------------------------------
                                    241 ; overlayable items in internal ram
                                    242 ;--------------------------------------------------------
                                    243 	.area	OSEG    (OVR,DATA)
                                    244 ;--------------------------------------------------------
                                    245 ; indirectly addressable internal ram data
                                    246 ;--------------------------------------------------------
                                    247 	.area ISEG    (DATA)
                                    248 ;--------------------------------------------------------
                                    249 ; absolute internal ram data
                                    250 ;--------------------------------------------------------
                                    251 	.area IABS    (ABS,DATA)
                                    252 	.area IABS    (ABS,DATA)
                                    253 ;--------------------------------------------------------
                                    254 ; bit data
                                    255 ;--------------------------------------------------------
                                    256 	.area BSEG    (BIT)
                                    257 ;--------------------------------------------------------
                                    258 ; paged external ram data
                                    259 ;--------------------------------------------------------
                                    260 	.area PSEG    (PAG,XDATA)
                                    261 ;--------------------------------------------------------
                                    262 ; uninitialized external ram data
                                    263 ;--------------------------------------------------------
                                    264 	.area XSEG    (XDATA)
                                    265 ;--------------------------------------------------------
                                    266 ; absolute external ram data
                                    267 ;--------------------------------------------------------
                                    268 	.area XABS    (ABS,XDATA)
                                    269 ;--------------------------------------------------------
                                    270 ; initialized external ram data
                                    271 ;--------------------------------------------------------
                                    272 	.area XISEG   (XDATA)
                                    273 	.area HOME    (CODE)
                                    274 	.area GSINIT0 (CODE)
                                    275 	.area GSINIT1 (CODE)
                                    276 	.area GSINIT2 (CODE)
                                    277 	.area GSINIT3 (CODE)
                                    278 	.area GSINIT4 (CODE)
                                    279 	.area GSINIT5 (CODE)
                                    280 	.area GSINIT  (CODE)
                                    281 	.area GSFINAL (CODE)
                                    282 	.area CSEG    (CODE)
                                    283 ;--------------------------------------------------------
                                    284 ; global & static initialisations
                                    285 ;--------------------------------------------------------
                                    286 	.area HOME    (CODE)
                                    287 	.area GSINIT  (CODE)
                                    288 	.area GSFINAL (CODE)
                                    289 	.area GSINIT  (CODE)
                                    290 ;--------------------------------------------------------
                                    291 ; Home
                                    292 ;--------------------------------------------------------
                                    293 	.area HOME    (CODE)
                                    294 	.area HOME    (CODE)
                                    295 ;--------------------------------------------------------
                                    296 ; code
                                    297 ;--------------------------------------------------------
                                    298 	.area CSEG    (CODE)
                                    299 ;------------------------------------------------------------
                                    300 ;Allocation info for local variables in function 'Bootstrap'
                                    301 ;------------------------------------------------------------
                                    302 ;	preemptive.c:48: void Bootstrap(void)
                                    303 ;	-----------------------------------------
                                    304 ;	 function Bootstrap
                                    305 ;	-----------------------------------------
      0008D0                        306 _Bootstrap:
                           000007   307 	ar7 = 0x07
                           000006   308 	ar6 = 0x06
                           000005   309 	ar5 = 0x05
                           000004   310 	ar4 = 0x04
                           000003   311 	ar3 = 0x03
                           000002   312 	ar2 = 0x02
                           000001   313 	ar1 = 0x01
                           000000   314 	ar0 = 0x00
                                    315 ;	preemptive.c:50: TMOD = 0;
      0008D0 75 89 00         [24]  316 	mov	_TMOD,#0x00
                                    317 ;	preemptive.c:51: IE = 0x82;
      0008D3 75 A8 82         [24]  318 	mov	_IE,#0x82
                                    319 ;	preemptive.c:52: TR0 = 1;
                                    320 ;	assignBit
      0008D6 D2 8C            [12]  321 	setb	_TR0
                                    322 ;	preemptive.c:53: threadBitmap = 0;
      0008D8 75 34 00         [24]  323 	mov	_threadBitmap,#0x00
                                    324 ;	preemptive.c:55: activeThreadID = ThreadCreate(main);
      0008DB 90 08 7A         [24]  325 	mov	dptr,#_main
      0008DE 12 08 FA         [24]  326 	lcall	_ThreadCreate
      0008E1 85 82 33         [24]  327 	mov	_activeThreadID,dpl
                                    328 ;	preemptive.c:56: RESTORESTATE;
      0008E4 88 F0            [24]  329 	MOV B, R0 
      0008E6 E5 33            [12]  330 	MOV A, _activeThreadID 
      0008E8 24 35            [12]  331 	ADD A, #_savedStackPointers 
      0008EA F8               [12]  332 	MOV R0, A 
      0008EB 86 81            [24]  333 	MOV _SP, @R0 
      0008ED A8 F0            [24]  334 	MOV R0, B 
      0008EF D0 D0            [24]  335 	POP PSW 
      0008F1 D0 83            [24]  336 	POP DPH 
      0008F3 D0 82            [24]  337 	POP DPL 
      0008F5 D0 F0            [24]  338 	POP B 
      0008F7 D0 E0            [24]  339 	POP ACC 
                                    340 ;	preemptive.c:57: }
      0008F9 22               [24]  341 	ret
                                    342 ;------------------------------------------------------------
                                    343 ;Allocation info for local variables in function 'ThreadCreate'
                                    344 ;------------------------------------------------------------
                                    345 ;fp            Allocated to registers 
                                    346 ;------------------------------------------------------------
                                    347 ;	preemptive.c:59: ThreadID ThreadCreate(FunctionPtr fp)
                                    348 ;	-----------------------------------------
                                    349 ;	 function ThreadCreate
                                    350 ;	-----------------------------------------
      0008FA                        351 _ThreadCreate:
                                    352 ;	preemptive.c:63: EA = 0;
                                    353 ;	assignBit
      0008FA C2 AF            [12]  354 	clr	_EA
                                    355 ;	preemptive.c:64: if (threadBitmap == 0x0F) {
      0008FC 74 0F            [12]  356 	mov	a,#0x0f
      0008FE B5 34 06         [24]  357 	cjne	a,_threadBitmap,00102$
                                    358 ;	preemptive.c:65: EA = 1;
                                    359 ;	assignBit
      000901 D2 AF            [12]  360 	setb	_EA
                                    361 ;	preemptive.c:66: return -1;
      000903 75 82 FF         [24]  362 	mov	dpl, #0xff
      000906 22               [24]  363 	ret
      000907                        364 00102$:
                                    365 ;	preemptive.c:69: for (nextSlot = 0; nextSlot < MAXTHREADS; nextSlot++) {
      000907 75 3A 00         [24]  366 	mov	_nextSlot,#0x00
      00090A                        367 00107$:
      00090A 74 FC            [12]  368 	mov	a,#0x100 - 0x04
      00090C 25 3A            [12]  369 	add	a,_nextSlot
      00090E 40 29            [24]  370 	jc	00105$
                                    371 ;	preemptive.c:70: if ((threadBitmap & (1 << nextSlot)) == 0) {
      000910 85 3A F0         [24]  372 	mov	b,_nextSlot
      000913 05 F0            [12]  373 	inc	b
      000915 7E 01            [12]  374 	mov	r6,#0x01
      000917 7F 00            [12]  375 	mov	r7,#0x00
      000919 80 06            [24]  376 	sjmp	00139$
      00091B                        377 00138$:
      00091B EE               [12]  378 	mov	a,r6
      00091C 2E               [12]  379 	add	a,r6
      00091D FE               [12]  380 	mov	r6,a
      00091E EF               [12]  381 	mov	a,r7
      00091F 33               [12]  382 	rlc	a
      000920 FF               [12]  383 	mov	r7,a
      000921                        384 00139$:
      000921 D5 F0 F7         [24]  385 	djnz	b,00138$
      000924 AC 34            [24]  386 	mov	r4,_threadBitmap
      000926 7D 00            [12]  387 	mov	r5,#0x00
      000928 EC               [12]  388 	mov	a,r4
      000929 52 06            [12]  389 	anl	ar6,a
      00092B ED               [12]  390 	mov	a,r5
      00092C 52 07            [12]  391 	anl	ar7,a
      00092E EE               [12]  392 	mov	a,r6
      00092F 4F               [12]  393 	orl	a,r7
      000930 60 07            [24]  394 	jz	00105$
                                    395 ;	preemptive.c:69: for (nextSlot = 0; nextSlot < MAXTHREADS; nextSlot++) {
      000932 E5 3A            [12]  396 	mov	a,_nextSlot
      000934 04               [12]  397 	inc	a
      000935 F5 3A            [12]  398 	mov	_nextSlot,a
      000937 80 D1            [24]  399 	sjmp	00107$
      000939                        400 00105$:
                                    401 ;	preemptive.c:75: threadBitmap |= (1 << nextSlot);
      000939 85 3A F0         [24]  402 	mov	b,_nextSlot
      00093C 05 F0            [12]  403 	inc	b
      00093E 74 01            [12]  404 	mov	a,#0x01
      000940 80 02            [24]  405 	sjmp	00142$
      000942                        406 00141$:
      000942 25 E0            [12]  407 	add	a,acc
      000944                        408 00142$:
      000944 D5 F0 FB         [24]  409 	djnz	b,00141$
      000947 42 34            [12]  410 	orl	_threadBitmap,a
                                    411 ;	preemptive.c:77: oldStackTop = SP;
      000949 85 81 3C         [24]  412 	mov	_oldStackTop,_SP
                                    413 ;	preemptive.c:78: SP = 0x3F + (nextSlot * 0x10);
      00094C E5 3A            [12]  414 	mov	a,_nextSlot
      00094E C4               [12]  415 	swap	a
      00094F 54 F0            [12]  416 	anl	a,#0xf0
      000951 FF               [12]  417 	mov	r7,a
      000952 24 3F            [12]  418 	add	a,#0x3f
      000954 F5 81            [12]  419 	mov	_SP,a
                                    420 ;	preemptive.c:83: __endasm;
      000956 C0 82            [24]  421 	PUSH	DPL
      000958 C0 83            [24]  422 	PUSH	DPH
                                    423 ;	preemptive.c:91: __endasm;
      00095A 74 00            [12]  424 	MOV	A, #0
      00095C C0 E0            [24]  425 	PUSH	ACC
      00095E C0 E0            [24]  426 	PUSH	ACC
      000960 C0 E0            [24]  427 	PUSH	ACC
      000962 C0 E0            [24]  428 	PUSH	ACC
                                    429 ;	preemptive.c:93: pswSeed = nextSlot << 3;
      000964 E5 3A            [12]  430 	mov	a,_nextSlot
      000966 C4               [12]  431 	swap	a
      000967 03               [12]  432 	rr	a
      000968 54 F8            [12]  433 	anl	a,#0xf8
      00096A F5 3B            [12]  434 	mov	_pswSeed,a
                                    435 ;	preemptive.c:96: __endasm;
      00096C C0 3B            [24]  436 	PUSH	_pswSeed
                                    437 ;	preemptive.c:98: savedStackPointers[nextSlot] = SP;
      00096E E5 3A            [12]  438 	mov	a,_nextSlot
      000970 24 35            [12]  439 	add	a, #_savedStackPointers
      000972 F8               [12]  440 	mov	r0,a
      000973 A6 81            [24]  441 	mov	@r0,_SP
                                    442 ;	preemptive.c:99: SP = oldStackTop;
      000975 85 3C 81         [24]  443 	mov	_SP,_oldStackTop
                                    444 ;	preemptive.c:101: EA = 1;
                                    445 ;	assignBit
      000978 D2 AF            [12]  446 	setb	_EA
                                    447 ;	preemptive.c:102: return nextSlot;
      00097A 85 3A 82         [24]  448 	mov	dpl, _nextSlot
                                    449 ;	preemptive.c:103: }
      00097D 22               [24]  450 	ret
                                    451 ;------------------------------------------------------------
                                    452 ;Allocation info for local variables in function 'ThreadYield'
                                    453 ;------------------------------------------------------------
                                    454 ;	preemptive.c:105: void ThreadYield(void)
                                    455 ;	-----------------------------------------
                                    456 ;	 function ThreadYield
                                    457 ;	-----------------------------------------
      00097E                        458 _ThreadYield:
                                    459 ;	preemptive.c:107: EA = 0;
                                    460 ;	assignBit
      00097E C2 AF            [12]  461 	clr	_EA
                                    462 ;	preemptive.c:108: SAVESTATE;
      000980 C0 E0            [24]  463 	PUSH ACC 
      000982 C0 F0            [24]  464 	PUSH B 
      000984 C0 82            [24]  465 	PUSH DPL 
      000986 C0 83            [24]  466 	PUSH DPH 
      000988 C0 D0            [24]  467 	PUSH PSW 
      00098A 88 F0            [24]  468 	MOV B, R0 
      00098C E5 33            [12]  469 	MOV A, _activeThreadID 
      00098E 24 35            [12]  470 	ADD A, #_savedStackPointers 
      000990 F8               [12]  471 	MOV R0, A 
      000991 A6 81            [24]  472 	MOV @R0, _SP 
      000993 A8 F0            [24]  473 	MOV R0, B 
                                    474 ;	preemptive.c:128: __endasm;
      000995                        475 thread_yield_select:
      000995 E5 33            [12]  476 	MOV	A, _activeThreadID
      000997 04               [12]  477 	INC	A
      000998 54 03            [12]  478 	ANL	A, #0x03
      00099A F5 33            [12]  479 	MOV	_activeThreadID, A
      00099C F5 F0            [12]  480 	MOV	B, A
      00099E 05 F0            [12]  481 	INC	B
      0009A0 74 01            [12]  482 	MOV	A, #0x01
      0009A2                        483 thread_yield_mask:
      0009A2 D5 F0 02         [24]  484 	DJNZ	B, thread_yield_shift
      0009A5 80 04            [24]  485 	SJMP	thread_yield_test
      0009A7                        486 thread_yield_shift:
      0009A7 25 E0            [12]  487 	ADD	A, ACC
      0009A9 80 F7            [24]  488 	SJMP	thread_yield_mask
      0009AB                        489 thread_yield_test:
      0009AB 55 34            [12]  490 	ANL	A, _threadBitmap
      0009AD 60 E6            [24]  491 	JZ	thread_yield_select
                                    492 ;	preemptive.c:130: RESTORESTATE;
      0009AF 88 F0            [24]  493 	MOV B, R0 
      0009B1 E5 33            [12]  494 	MOV A, _activeThreadID 
      0009B3 24 35            [12]  495 	ADD A, #_savedStackPointers 
      0009B5 F8               [12]  496 	MOV R0, A 
      0009B6 86 81            [24]  497 	MOV _SP, @R0 
      0009B8 A8 F0            [24]  498 	MOV R0, B 
      0009BA D0 D0            [24]  499 	POP PSW 
      0009BC D0 83            [24]  500 	POP DPH 
      0009BE D0 82            [24]  501 	POP DPL 
      0009C0 D0 F0            [24]  502 	POP B 
      0009C2 D0 E0            [24]  503 	POP ACC 
                                    504 ;	preemptive.c:131: EA = 1;
                                    505 ;	assignBit
      0009C4 D2 AF            [12]  506 	setb	_EA
                                    507 ;	preemptive.c:132: }
      0009C6 22               [24]  508 	ret
                                    509 ;------------------------------------------------------------
                                    510 ;Allocation info for local variables in function 'ThreadExit'
                                    511 ;------------------------------------------------------------
                                    512 ;	preemptive.c:134: void ThreadExit(void)
                                    513 ;	-----------------------------------------
                                    514 ;	 function ThreadExit
                                    515 ;	-----------------------------------------
      0009C7                        516 _ThreadExit:
                                    517 ;	preemptive.c:136: EA = 0;
                                    518 ;	assignBit
      0009C7 C2 AF            [12]  519 	clr	_EA
                                    520 ;	preemptive.c:137: threadBitmap &= ~(1 << activeThreadID);
      0009C9 85 33 F0         [24]  521 	mov	b,_activeThreadID
      0009CC 05 F0            [12]  522 	inc	b
      0009CE 74 01            [12]  523 	mov	a,#0x01
      0009D0 80 02            [24]  524 	sjmp	00104$
      0009D2                        525 00103$:
      0009D2 25 E0            [12]  526 	add	a,acc
      0009D4                        527 00104$:
      0009D4 D5 F0 FB         [24]  528 	djnz	b,00103$
      0009D7 F4               [12]  529 	cpl	a
      0009D8 FF               [12]  530 	mov	r7,a
      0009D9 52 34            [12]  531 	anl	_threadBitmap,a
                                    532 ;	preemptive.c:157: __endasm;
      0009DB                        533 thread_exit_select:
      0009DB E5 33            [12]  534 	MOV	A, _activeThreadID
      0009DD 04               [12]  535 	INC	A
      0009DE 54 03            [12]  536 	ANL	A, #0x03
      0009E0 F5 33            [12]  537 	MOV	_activeThreadID, A
      0009E2 F5 F0            [12]  538 	MOV	B, A
      0009E4 05 F0            [12]  539 	INC	B
      0009E6 74 01            [12]  540 	MOV	A, #0x01
      0009E8                        541 thread_exit_mask:
      0009E8 D5 F0 02         [24]  542 	DJNZ	B, thread_exit_shift
      0009EB 80 04            [24]  543 	SJMP	thread_exit_test
      0009ED                        544 thread_exit_shift:
      0009ED 25 E0            [12]  545 	ADD	A, ACC
      0009EF 80 F7            [24]  546 	SJMP	thread_exit_mask
      0009F1                        547 thread_exit_test:
      0009F1 55 34            [12]  548 	ANL	A, _threadBitmap
      0009F3 60 E6            [24]  549 	JZ	thread_exit_select
                                    550 ;	preemptive.c:159: RESTORESTATE;
      0009F5 88 F0            [24]  551 	MOV B, R0 
      0009F7 E5 33            [12]  552 	MOV A, _activeThreadID 
      0009F9 24 35            [12]  553 	ADD A, #_savedStackPointers 
      0009FB F8               [12]  554 	MOV R0, A 
      0009FC 86 81            [24]  555 	MOV _SP, @R0 
      0009FE A8 F0            [24]  556 	MOV R0, B 
      000A00 D0 D0            [24]  557 	POP PSW 
      000A02 D0 83            [24]  558 	POP DPH 
      000A04 D0 82            [24]  559 	POP DPL 
      000A06 D0 F0            [24]  560 	POP B 
      000A08 D0 E0            [24]  561 	POP ACC 
                                    562 ;	preemptive.c:160: EA = 1;
                                    563 ;	assignBit
      000A0A D2 AF            [12]  564 	setb	_EA
                                    565 ;	preemptive.c:161: }
      000A0C 22               [24]  566 	ret
                                    567 ;------------------------------------------------------------
                                    568 ;Allocation info for local variables in function 'myTimer0Handler'
                                    569 ;------------------------------------------------------------
                                    570 ;	preemptive.c:163: void myTimer0Handler(void)
                                    571 ;	-----------------------------------------
                                    572 ;	 function myTimer0Handler
                                    573 ;	-----------------------------------------
      000A0D                        574 _myTimer0Handler:
                                    575 ;	preemptive.c:165: EA = 0;
                                    576 ;	assignBit
      000A0D C2 AF            [12]  577 	clr	_EA
                                    578 ;	preemptive.c:166: SAVESTATE;
      000A0F C0 E0            [24]  579 	PUSH ACC 
      000A11 C0 F0            [24]  580 	PUSH B 
      000A13 C0 82            [24]  581 	PUSH DPL 
      000A15 C0 83            [24]  582 	PUSH DPH 
      000A17 C0 D0            [24]  583 	PUSH PSW 
      000A19 88 F0            [24]  584 	MOV B, R0 
      000A1B E5 33            [12]  585 	MOV A, _activeThreadID 
      000A1D 24 35            [12]  586 	ADD A, #_savedStackPointers 
      000A1F F8               [12]  587 	MOV R0, A 
      000A20 A6 81            [24]  588 	MOV @R0, _SP 
      000A22 A8 F0            [24]  589 	MOV R0, B 
                                    590 ;	preemptive.c:186: __endasm;
      000A24                        591 timer_select:
      000A24 E5 33            [12]  592 	MOV	A, _activeThreadID
      000A26 04               [12]  593 	INC	A
      000A27 54 03            [12]  594 	ANL	A, #0x03
      000A29 F5 33            [12]  595 	MOV	_activeThreadID, A
      000A2B F5 F0            [12]  596 	MOV	B, A
      000A2D 05 F0            [12]  597 	INC	B
      000A2F 74 01            [12]  598 	MOV	A, #0x01
      000A31                        599 timer_mask:
      000A31 D5 F0 02         [24]  600 	DJNZ	B, timer_shift
      000A34 80 04            [24]  601 	SJMP	timer_test
      000A36                        602 timer_shift:
      000A36 25 E0            [12]  603 	ADD	A, ACC
      000A38 80 F7            [24]  604 	SJMP	timer_mask
      000A3A                        605 timer_test:
      000A3A 55 34            [12]  606 	ANL	A, _threadBitmap
      000A3C 60 E6            [24]  607 	JZ	timer_select
                                    608 ;	preemptive.c:188: RESTORESTATE;
      000A3E 88 F0            [24]  609 	MOV B, R0 
      000A40 E5 33            [12]  610 	MOV A, _activeThreadID 
      000A42 24 35            [12]  611 	ADD A, #_savedStackPointers 
      000A44 F8               [12]  612 	MOV R0, A 
      000A45 86 81            [24]  613 	MOV _SP, @R0 
      000A47 A8 F0            [24]  614 	MOV R0, B 
      000A49 D0 D0            [24]  615 	POP PSW 
      000A4B D0 83            [24]  616 	POP DPH 
      000A4D D0 82            [24]  617 	POP DPL 
      000A4F D0 F0            [24]  618 	POP B 
      000A51 D0 E0            [24]  619 	POP ACC 
                                    620 ;	preemptive.c:189: EA = 1;
                                    621 ;	assignBit
      000A53 D2 AF            [12]  622 	setb	_EA
                                    623 ;	preemptive.c:193: __endasm;
      000A55 32               [24]  624 	RETI
                                    625 ;	preemptive.c:194: }
      000A56 22               [24]  626 	ret
                                    627 	.area CSEG    (CODE)
                                    628 	.area CONST   (CODE)
                                    629 	.area XINIT   (CODE)
                                    630 	.area CABS    (ABS,CODE)
