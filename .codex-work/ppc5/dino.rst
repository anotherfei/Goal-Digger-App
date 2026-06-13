                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ISO C Compiler
                                      3 ; Version 4.5.0 #15242 (MINGW64)
                                      4 ;--------------------------------------------------------
                                      5 	.module dino
                                      6 	
                                      7 	.optsdcc -mmcs51 --model-small
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _timer0_ISR
                                     12 	.globl __mcs51_genXRAMCLEAR
                                     13 	.globl __mcs51_genXINIT
                                     14 	.globl __mcs51_genRAMCLEAR
                                     15 	.globl __sdcc_gsinit_startup
                                     16 	.globl _main
                                     17 	.globl _GameCtrlTask
                                     18 	.globl _UpdateGameMap
                                     19 	.globl _MaybeAddCactus
                                     20 	.globl _MoveDinoFromKey
                                     21 	.globl _FrameDelay
                                     22 	.globl _SmallDelay
                                     23 	.globl _RenderTask
                                     24 	.globl _DrawGameRows
                                     25 	.globl _LoadDinoSymbols
                                     26 	.globl _LCDWriteUint
                                     27 	.globl _WriteGameOverText
                                     28 	.globl _WritePromptText
                                     29 	.globl _KeypadCtrlTask
                                     30 	.globl _TakeKeyIfReady
                                     31 	.globl _TakeKeyBlocking
                                     32 	.globl _PutKey
                                     33 	.globl _LCD_ready
                                     34 	.globl _LCD_write_char
                                     35 	.globl _LCD_IRWrite
                                     36 	.globl _LCD_Init
                                     37 	.globl _AnyKeyPressed
                                     38 	.globl _KeyToChar
                                     39 	.globl _Init_Keypad
                                     40 	.globl _ThreadExit
                                     41 	.globl _ThreadYield
                                     42 	.globl _ThreadCreate
                                     43 	.globl _CY
                                     44 	.globl _AC
                                     45 	.globl _F0
                                     46 	.globl _RS1
                                     47 	.globl _RS0
                                     48 	.globl _OV
                                     49 	.globl _F1
                                     50 	.globl _P
                                     51 	.globl _PS
                                     52 	.globl _PT1
                                     53 	.globl _PX1
                                     54 	.globl _PT0
                                     55 	.globl _PX0
                                     56 	.globl _RD
                                     57 	.globl _WR
                                     58 	.globl _T1
                                     59 	.globl _T0
                                     60 	.globl _INT1
                                     61 	.globl _INT0
                                     62 	.globl _TXD
                                     63 	.globl _RXD
                                     64 	.globl _P3_7
                                     65 	.globl _P3_6
                                     66 	.globl _P3_5
                                     67 	.globl _P3_4
                                     68 	.globl _P3_3
                                     69 	.globl _P3_2
                                     70 	.globl _P3_1
                                     71 	.globl _P3_0
                                     72 	.globl _EA
                                     73 	.globl _ES
                                     74 	.globl _ET1
                                     75 	.globl _EX1
                                     76 	.globl _ET0
                                     77 	.globl _EX0
                                     78 	.globl _P2_7
                                     79 	.globl _P2_6
                                     80 	.globl _P2_5
                                     81 	.globl _P2_4
                                     82 	.globl _P2_3
                                     83 	.globl _P2_2
                                     84 	.globl _P2_1
                                     85 	.globl _P2_0
                                     86 	.globl _SM0
                                     87 	.globl _SM1
                                     88 	.globl _SM2
                                     89 	.globl _REN
                                     90 	.globl _TB8
                                     91 	.globl _RB8
                                     92 	.globl _TI
                                     93 	.globl _RI
                                     94 	.globl _P1_7
                                     95 	.globl _P1_6
                                     96 	.globl _P1_5
                                     97 	.globl _P1_4
                                     98 	.globl _P1_3
                                     99 	.globl _P1_2
                                    100 	.globl _P1_1
                                    101 	.globl _P1_0
                                    102 	.globl _TF1
                                    103 	.globl _TR1
                                    104 	.globl _TF0
                                    105 	.globl _TR0
                                    106 	.globl _IE1
                                    107 	.globl _IT1
                                    108 	.globl _IE0
                                    109 	.globl _IT0
                                    110 	.globl _P0_7
                                    111 	.globl _P0_6
                                    112 	.globl _P0_5
                                    113 	.globl _P0_4
                                    114 	.globl _P0_3
                                    115 	.globl _P0_2
                                    116 	.globl _P0_1
                                    117 	.globl _P0_0
                                    118 	.globl _B
                                    119 	.globl _ACC
                                    120 	.globl _PSW
                                    121 	.globl _IP
                                    122 	.globl _P3
                                    123 	.globl _IE
                                    124 	.globl _P2
                                    125 	.globl _SBUF
                                    126 	.globl _SCON
                                    127 	.globl _P1
                                    128 	.globl _TH1
                                    129 	.globl _TH0
                                    130 	.globl _TL1
                                    131 	.globl _TL0
                                    132 	.globl _TMOD
                                    133 	.globl _TCON
                                    134 	.globl _PCON
                                    135 	.globl _DPH
                                    136 	.globl _DPL
                                    137 	.globl _SP
                                    138 	.globl _P0
                                    139 	.globl _cactusGap
                                    140 	.globl _difficultyDigit
                                    141 	.globl _scoreCount
                                    142 	.globl _cactusRow1
                                    143 	.globl _cactusRow0
                                    144 	.globl _playMode
                                    145 	.globl _dinoRow
                                    146 	.globl _sceneGate
                                    147 	.globl _keyStillDown
                                    148 	.globl _keyPutAt
                                    149 	.globl _keyTakeAt
                                    150 	.globl _keyQueue
                                    151 	.globl _keyRoom
                                    152 	.globl _keyUsed
                                    153 	.globl _keyGate
                                    154 ;--------------------------------------------------------
                                    155 ; special function registers
                                    156 ;--------------------------------------------------------
                                    157 	.area RSEG    (ABS,DATA)
      000000                        158 	.org 0x0000
                           000080   159 _P0	=	0x0080
                           000081   160 _SP	=	0x0081
                           000082   161 _DPL	=	0x0082
                           000083   162 _DPH	=	0x0083
                           000087   163 _PCON	=	0x0087
                           000088   164 _TCON	=	0x0088
                           000089   165 _TMOD	=	0x0089
                           00008A   166 _TL0	=	0x008a
                           00008B   167 _TL1	=	0x008b
                           00008C   168 _TH0	=	0x008c
                           00008D   169 _TH1	=	0x008d
                           000090   170 _P1	=	0x0090
                           000098   171 _SCON	=	0x0098
                           000099   172 _SBUF	=	0x0099
                           0000A0   173 _P2	=	0x00a0
                           0000A8   174 _IE	=	0x00a8
                           0000B0   175 _P3	=	0x00b0
                           0000B8   176 _IP	=	0x00b8
                           0000D0   177 _PSW	=	0x00d0
                           0000E0   178 _ACC	=	0x00e0
                           0000F0   179 _B	=	0x00f0
                                    180 ;--------------------------------------------------------
                                    181 ; special function bits
                                    182 ;--------------------------------------------------------
                                    183 	.area RSEG    (ABS,DATA)
      000000                        184 	.org 0x0000
                           000080   185 _P0_0	=	0x0080
                           000081   186 _P0_1	=	0x0081
                           000082   187 _P0_2	=	0x0082
                           000083   188 _P0_3	=	0x0083
                           000084   189 _P0_4	=	0x0084
                           000085   190 _P0_5	=	0x0085
                           000086   191 _P0_6	=	0x0086
                           000087   192 _P0_7	=	0x0087
                           000088   193 _IT0	=	0x0088
                           000089   194 _IE0	=	0x0089
                           00008A   195 _IT1	=	0x008a
                           00008B   196 _IE1	=	0x008b
                           00008C   197 _TR0	=	0x008c
                           00008D   198 _TF0	=	0x008d
                           00008E   199 _TR1	=	0x008e
                           00008F   200 _TF1	=	0x008f
                           000090   201 _P1_0	=	0x0090
                           000091   202 _P1_1	=	0x0091
                           000092   203 _P1_2	=	0x0092
                           000093   204 _P1_3	=	0x0093
                           000094   205 _P1_4	=	0x0094
                           000095   206 _P1_5	=	0x0095
                           000096   207 _P1_6	=	0x0096
                           000097   208 _P1_7	=	0x0097
                           000098   209 _RI	=	0x0098
                           000099   210 _TI	=	0x0099
                           00009A   211 _RB8	=	0x009a
                           00009B   212 _TB8	=	0x009b
                           00009C   213 _REN	=	0x009c
                           00009D   214 _SM2	=	0x009d
                           00009E   215 _SM1	=	0x009e
                           00009F   216 _SM0	=	0x009f
                           0000A0   217 _P2_0	=	0x00a0
                           0000A1   218 _P2_1	=	0x00a1
                           0000A2   219 _P2_2	=	0x00a2
                           0000A3   220 _P2_3	=	0x00a3
                           0000A4   221 _P2_4	=	0x00a4
                           0000A5   222 _P2_5	=	0x00a5
                           0000A6   223 _P2_6	=	0x00a6
                           0000A7   224 _P2_7	=	0x00a7
                           0000A8   225 _EX0	=	0x00a8
                           0000A9   226 _ET0	=	0x00a9
                           0000AA   227 _EX1	=	0x00aa
                           0000AB   228 _ET1	=	0x00ab
                           0000AC   229 _ES	=	0x00ac
                           0000AF   230 _EA	=	0x00af
                           0000B0   231 _P3_0	=	0x00b0
                           0000B1   232 _P3_1	=	0x00b1
                           0000B2   233 _P3_2	=	0x00b2
                           0000B3   234 _P3_3	=	0x00b3
                           0000B4   235 _P3_4	=	0x00b4
                           0000B5   236 _P3_5	=	0x00b5
                           0000B6   237 _P3_6	=	0x00b6
                           0000B7   238 _P3_7	=	0x00b7
                           0000B0   239 _RXD	=	0x00b0
                           0000B1   240 _TXD	=	0x00b1
                           0000B2   241 _INT0	=	0x00b2
                           0000B3   242 _INT1	=	0x00b3
                           0000B4   243 _T0	=	0x00b4
                           0000B5   244 _T1	=	0x00b5
                           0000B6   245 _WR	=	0x00b6
                           0000B7   246 _RD	=	0x00b7
                           0000B8   247 _PX0	=	0x00b8
                           0000B9   248 _PT0	=	0x00b9
                           0000BA   249 _PX1	=	0x00ba
                           0000BB   250 _PT1	=	0x00bb
                           0000BC   251 _PS	=	0x00bc
                           0000D0   252 _P	=	0x00d0
                           0000D1   253 _F1	=	0x00d1
                           0000D2   254 _OV	=	0x00d2
                           0000D3   255 _RS0	=	0x00d3
                           0000D4   256 _RS1	=	0x00d4
                           0000D5   257 _F0	=	0x00d5
                           0000D6   258 _AC	=	0x00d6
                           0000D7   259 _CY	=	0x00d7
                                    260 ;--------------------------------------------------------
                                    261 ; overlayable register banks
                                    262 ;--------------------------------------------------------
                                    263 	.area REG_BANK_0	(REL,OVR,DATA)
      000000                        264 	.ds 8
                                    265 ;--------------------------------------------------------
                                    266 ; internal ram data
                                    267 ;--------------------------------------------------------
                                    268 	.area DSEG    (DATA)
                           000020   269 _keyGate	=	0x0020
                           000021   270 _keyUsed	=	0x0021
                           000022   271 _keyRoom	=	0x0022
                           000023   272 _keyQueue	=	0x0023
                           000026   273 _keyTakeAt	=	0x0026
                           000027   274 _keyPutAt	=	0x0027
                           000028   275 _keyStillDown	=	0x0028
                           000029   276 _sceneGate	=	0x0029
                           00002A   277 _dinoRow	=	0x002a
                           00002B   278 _playMode	=	0x002b
                           00002C   279 _cactusRow0	=	0x002c
                           00002E   280 _cactusRow1	=	0x002e
                           000030   281 _scoreCount	=	0x0030
                           000032   282 _difficultyDigit	=	0x0032
                           00003E   283 _cactusGap	=	0x003e
                                    284 ;--------------------------------------------------------
                                    285 ; overlayable items in internal ram
                                    286 ;--------------------------------------------------------
                                    287 	.area	OSEG    (OVR,DATA)
                                    288 	.area	OSEG    (OVR,DATA)
                                    289 	.area	OSEG    (OVR,DATA)
                                    290 	.area	OSEG    (OVR,DATA)
                                    291 	.area	OSEG    (OVR,DATA)
                                    292 ;--------------------------------------------------------
                                    293 ; Stack segment in internal ram
                                    294 ;--------------------------------------------------------
                                    295 	.area SSEG
      000021                        296 __start__stack:
      000021                        297 	.ds	1
                                    298 
                                    299 ;--------------------------------------------------------
                                    300 ; indirectly addressable internal ram data
                                    301 ;--------------------------------------------------------
                                    302 	.area ISEG    (DATA)
                                    303 ;--------------------------------------------------------
                                    304 ; absolute internal ram data
                                    305 ;--------------------------------------------------------
                                    306 	.area IABS    (ABS,DATA)
                                    307 	.area IABS    (ABS,DATA)
                                    308 ;--------------------------------------------------------
                                    309 ; bit data
                                    310 ;--------------------------------------------------------
                                    311 	.area BSEG    (BIT)
                                    312 ;--------------------------------------------------------
                                    313 ; paged external ram data
                                    314 ;--------------------------------------------------------
                                    315 	.area PSEG    (PAG,XDATA)
                                    316 ;--------------------------------------------------------
                                    317 ; uninitialized external ram data
                                    318 ;--------------------------------------------------------
                                    319 	.area XSEG    (XDATA)
                                    320 ;--------------------------------------------------------
                                    321 ; absolute external ram data
                                    322 ;--------------------------------------------------------
                                    323 	.area XABS    (ABS,XDATA)
                                    324 ;--------------------------------------------------------
                                    325 ; initialized external ram data
                                    326 ;--------------------------------------------------------
                                    327 	.area XISEG   (XDATA)
                                    328 	.area HOME    (CODE)
                                    329 	.area GSINIT0 (CODE)
                                    330 	.area GSINIT1 (CODE)
                                    331 	.area GSINIT2 (CODE)
                                    332 	.area GSINIT3 (CODE)
                                    333 	.area GSINIT4 (CODE)
                                    334 	.area GSINIT5 (CODE)
                                    335 	.area GSINIT  (CODE)
                                    336 	.area GSFINAL (CODE)
                                    337 	.area CSEG    (CODE)
                                    338 ;--------------------------------------------------------
                                    339 ; interrupt vector
                                    340 ;--------------------------------------------------------
                                    341 	.area HOME    (CODE)
      000000                        342 __interrupt_vect:
      000000 02 08 C3         [24]  343 	ljmp	__sdcc_gsinit_startup
      000003 32               [24]  344 	reti
      000004                        345 	.ds	7
      00000B 02 08 CA         [24]  346 	ljmp	_timer0_ISR
                                    347 ; restartable atomic support routines
      00000E                        348 	.ds	2
      000010                        349 sdcc_atomic_exchange_rollback_start::
      000010 00               [12]  350 	nop
      000011 00               [12]  351 	nop
      000012                        352 sdcc_atomic_exchange_pdata_impl:
      000012 E2               [24]  353 	movx	a, @r0
      000013 FB               [12]  354 	mov	r3, a
      000014 EA               [12]  355 	mov	a, r2
      000015 F2               [24]  356 	movx	@r0, a
      000016 80 2C            [24]  357 	sjmp	sdcc_atomic_exchange_exit
      000018 00               [12]  358 	nop
      000019 00               [12]  359 	nop
      00001A                        360 sdcc_atomic_exchange_xdata_impl:
      00001A E0               [24]  361 	movx	a, @dptr
      00001B FB               [12]  362 	mov	r3, a
      00001C EA               [12]  363 	mov	a, r2
      00001D F0               [24]  364 	movx	@dptr, a
      00001E 80 24            [24]  365 	sjmp	sdcc_atomic_exchange_exit
      000020                        366 sdcc_atomic_compare_exchange_idata_impl:
      000020 E6               [12]  367 	mov	a, @r0
      000021 B5 02 02         [24]  368 	cjne	a, ar2, .+#5
      000024 EB               [12]  369 	mov	a, r3
      000025 F6               [12]  370 	mov	@r0, a
      000026 22               [24]  371 	ret
      000027 00               [12]  372 	nop
      000028                        373 sdcc_atomic_compare_exchange_pdata_impl:
      000028 E2               [24]  374 	movx	a, @r0
      000029 B5 02 02         [24]  375 	cjne	a, ar2, .+#5
      00002C EB               [12]  376 	mov	a, r3
      00002D F2               [24]  377 	movx	@r0, a
      00002E 22               [24]  378 	ret
      00002F 00               [12]  379 	nop
      000030                        380 sdcc_atomic_compare_exchange_xdata_impl:
      000030 E0               [24]  381 	movx	a, @dptr
      000031 B5 02 02         [24]  382 	cjne	a, ar2, .+#5
      000034 EB               [12]  383 	mov	a, r3
      000035 F0               [24]  384 	movx	@dptr, a
      000036 22               [24]  385 	ret
      000037                        386 sdcc_atomic_exchange_rollback_end::
                                    387 
      000037                        388 sdcc_atomic_exchange_gptr_impl::
      000037 30 F6 E0         [24]  389 	jnb	b.6, sdcc_atomic_exchange_xdata_impl
      00003A A8 82            [24]  390 	mov	r0, dpl
      00003C 20 F5 D3         [24]  391 	jb	b.5, sdcc_atomic_exchange_pdata_impl
      00003F                        392 sdcc_atomic_exchange_idata_impl:
      00003F EA               [12]  393 	mov	a, r2
      000040 C6               [12]  394 	xch	a, @r0
      000041 F5 82            [12]  395 	mov	dpl, a
      000043 22               [24]  396 	ret
      000044                        397 sdcc_atomic_exchange_exit:
      000044 8B 82            [24]  398 	mov	dpl, r3
      000046 22               [24]  399 	ret
      000047                        400 sdcc_atomic_compare_exchange_gptr_impl::
      000047 30 F6 E6         [24]  401 	jnb	b.6, sdcc_atomic_compare_exchange_xdata_impl
      00004A A8 82            [24]  402 	mov	r0, dpl
      00004C 20 F5 D9         [24]  403 	jb	b.5, sdcc_atomic_compare_exchange_pdata_impl
      00004F 80 CF            [24]  404 	sjmp	sdcc_atomic_compare_exchange_idata_impl
                                    405 ;--------------------------------------------------------
                                    406 ; global & static initialisations
                                    407 ;--------------------------------------------------------
                                    408 	.area HOME    (CODE)
                                    409 	.area GSINIT  (CODE)
                                    410 	.area GSFINAL (CODE)
                                    411 	.area GSINIT  (CODE)
                                    412 	.globl __sdcc_gsinit_startup
                                    413 	.globl __sdcc_program_startup
                                    414 	.globl __start__stack
                                    415 	.globl __mcs51_genXINIT
                                    416 	.globl __mcs51_genXRAMCLEAR
                                    417 	.globl __mcs51_genRAMCLEAR
                                    418 	.area GSFINAL (CODE)
      00007E 02 00 51         [24]  419 	ljmp	__sdcc_program_startup
                                    420 ;--------------------------------------------------------
                                    421 ; Home
                                    422 ;--------------------------------------------------------
                                    423 	.area HOME    (CODE)
                                    424 	.area HOME    (CODE)
      000051                        425 __sdcc_program_startup:
      000051 02 08 7A         [24]  426 	ljmp	_main
                                    427 ;	return from main will return to caller
                                    428 ;--------------------------------------------------------
                                    429 ; code
                                    430 ;--------------------------------------------------------
                                    431 	.area CSEG    (CODE)
                                    432 ;------------------------------------------------------------
                                    433 ;Allocation info for local variables in function 'PutKey'
                                    434 ;------------------------------------------------------------
                                    435 ;c             Allocated to registers r7 
                                    436 ;------------------------------------------------------------
                                    437 ;	dino.c:30: void PutKey(char c)
                                    438 ;	-----------------------------------------
                                    439 ;	 function PutKey
                                    440 ;	-----------------------------------------
      000081                        441 _PutKey:
                           000007   442 	ar7 = 0x07
                           000006   443 	ar6 = 0x06
                           000005   444 	ar5 = 0x05
                           000004   445 	ar4 = 0x04
                           000003   446 	ar3 = 0x03
                           000002   447 	ar2 = 0x02
                           000001   448 	ar1 = 0x01
                           000000   449 	ar0 = 0x00
                                    450 ;	dino.c:32: if (c == '\0') {
      000081 E5 82            [12]  451 	mov	a,dpl
      000083 FF               [12]  452 	mov	r7,a
      000084 70 01            [24]  453 	jnz	00106$
                                    454 ;	dino.c:33: return;
                                    455 ;	dino.c:36: SemaphoreWait(keyRoom);
      000086 22               [24]  456 	ret
      000087                        457 00106$:
                                    458 ;	assignBit
      000087 C2 AF            [12]  459 	clr	_EA
      000089 E5 22            [12]  460 	mov	a,_keyRoom
      00008B 60 06            [24]  461 	jz	00104$
      00008D 15 22            [12]  462 	dec	_keyRoom
                                    463 ;	assignBit
      00008F D2 AF            [12]  464 	setb	_EA
      000091 80 04            [24]  465 	sjmp	00114$
      000093                        466 00104$:
                                    467 ;	assignBit
      000093 D2 AF            [12]  468 	setb	_EA
                                    469 ;	dino.c:37: SemaphoreWait(keyGate);
      000095 80 F0            [24]  470 	sjmp	00106$
      000097                        471 00114$:
                                    472 ;	assignBit
      000097 C2 AF            [12]  473 	clr	_EA
      000099 E5 20            [12]  474 	mov	a,_keyGate
      00009B 60 06            [24]  475 	jz	00112$
      00009D 15 20            [12]  476 	dec	_keyGate
                                    477 ;	assignBit
      00009F D2 AF            [12]  478 	setb	_EA
      0000A1 80 04            [24]  479 	sjmp	00117$
      0000A3                        480 00112$:
                                    481 ;	assignBit
      0000A3 D2 AF            [12]  482 	setb	_EA
      0000A5 80 F0            [24]  483 	sjmp	00114$
      0000A7                        484 00117$:
                                    485 ;	dino.c:39: if (keyPutAt == 0) {
      0000A7 E5 27            [12]  486 	mov	a,_keyPutAt
      0000A9 70 04            [24]  487 	jnz	00123$
                                    488 ;	dino.c:40: keyQueue[0] = c;
      0000AB 8F 23            [24]  489 	mov	_keyQueue,r7
      0000AD 80 0B            [24]  490 	sjmp	00124$
      0000AF                        491 00123$:
                                    492 ;	dino.c:41: } else if (keyPutAt == 1) {
      0000AF 74 01            [12]  493 	mov	a,#0x01
      0000B1 B5 27 04         [24]  494 	cjne	a,_keyPutAt,00120$
                                    495 ;	dino.c:42: keyQueue[1] = c;
      0000B4 8F 24            [24]  496 	mov	(_keyQueue + 0x0001),r7
      0000B6 80 02            [24]  497 	sjmp	00124$
      0000B8                        498 00120$:
                                    499 ;	dino.c:44: keyQueue[2] = c;
      0000B8 8F 25            [24]  500 	mov	(_keyQueue + 0x0002),r7
      0000BA                        501 00124$:
                                    502 ;	dino.c:46: keyPutAt++;
      0000BA E5 27            [12]  503 	mov	a,_keyPutAt
      0000BC 04               [12]  504 	inc	a
      0000BD F5 27            [12]  505 	mov	_keyPutAt,a
                                    506 ;	dino.c:47: if (keyPutAt == 3) {
      0000BF 74 03            [12]  507 	mov	a,#0x03
      0000C1 B5 27 03         [24]  508 	cjne	a,_keyPutAt,00127$
                                    509 ;	dino.c:48: keyPutAt = 0;
      0000C4 75 27 00         [24]  510 	mov	_keyPutAt,#0x00
                                    511 ;	dino.c:51: SemaphoreSignal(keyGate);
      0000C7                        512 00127$:
                                    513 ;	assignBit
      0000C7 C2 AF            [12]  514 	clr	_EA
      0000C9 05 20            [12]  515 	inc	_keyGate
                                    516 ;	assignBit
      0000CB D2 AF            [12]  517 	setb	_EA
                                    518 ;	dino.c:52: SemaphoreSignal(keyUsed);
                                    519 ;	assignBit
      0000CD C2 AF            [12]  520 	clr	_EA
      0000CF 05 21            [12]  521 	inc	_keyUsed
                                    522 ;	assignBit
      0000D1 D2 AF            [12]  523 	setb	_EA
                                    524 ;	dino.c:53: }
      0000D3 22               [24]  525 	ret
                                    526 ;------------------------------------------------------------
                                    527 ;Allocation info for local variables in function 'TakeKeyBlocking'
                                    528 ;------------------------------------------------------------
                                    529 ;c             Allocated to registers r7 
                                    530 ;------------------------------------------------------------
                                    531 ;	dino.c:55: char TakeKeyBlocking(void)
                                    532 ;	-----------------------------------------
                                    533 ;	 function TakeKeyBlocking
                                    534 ;	-----------------------------------------
      0000D4                        535 _TakeKeyBlocking:
                                    536 ;	dino.c:59: SemaphoreWait(keyUsed);
      0000D4                        537 00104$:
                                    538 ;	assignBit
      0000D4 C2 AF            [12]  539 	clr	_EA
      0000D6 E5 21            [12]  540 	mov	a,_keyUsed
      0000D8 60 06            [24]  541 	jz	00102$
      0000DA 15 21            [12]  542 	dec	_keyUsed
                                    543 ;	assignBit
      0000DC D2 AF            [12]  544 	setb	_EA
      0000DE 80 04            [24]  545 	sjmp	00112$
      0000E0                        546 00102$:
                                    547 ;	assignBit
      0000E0 D2 AF            [12]  548 	setb	_EA
                                    549 ;	dino.c:60: SemaphoreWait(keyGate);
      0000E2 80 F0            [24]  550 	sjmp	00104$
      0000E4                        551 00112$:
                                    552 ;	assignBit
      0000E4 C2 AF            [12]  553 	clr	_EA
      0000E6 E5 20            [12]  554 	mov	a,_keyGate
      0000E8 60 06            [24]  555 	jz	00110$
      0000EA 15 20            [12]  556 	dec	_keyGate
                                    557 ;	assignBit
      0000EC D2 AF            [12]  558 	setb	_EA
      0000EE 80 04            [24]  559 	sjmp	00115$
      0000F0                        560 00110$:
                                    561 ;	assignBit
      0000F0 D2 AF            [12]  562 	setb	_EA
      0000F2 80 F0            [24]  563 	sjmp	00112$
      0000F4                        564 00115$:
                                    565 ;	dino.c:62: c = keyQueue[keyTakeAt];
      0000F4 E5 26            [12]  566 	mov	a,_keyTakeAt
      0000F6 24 23            [12]  567 	add	a, #_keyQueue
      0000F8 F9               [12]  568 	mov	r1,a
      0000F9 87 07            [24]  569 	mov	ar7,@r1
                                    570 ;	dino.c:63: keyTakeAt++;
      0000FB E5 26            [12]  571 	mov	a,_keyTakeAt
      0000FD 04               [12]  572 	inc	a
      0000FE F5 26            [12]  573 	mov	_keyTakeAt,a
                                    574 ;	dino.c:64: if (keyTakeAt == 3) {
      000100 74 03            [12]  575 	mov	a,#0x03
      000102 B5 26 03         [24]  576 	cjne	a,_keyTakeAt,00119$
                                    577 ;	dino.c:65: keyTakeAt = 0;
      000105 75 26 00         [24]  578 	mov	_keyTakeAt,#0x00
                                    579 ;	dino.c:68: SemaphoreSignal(keyGate);
      000108                        580 00119$:
                                    581 ;	assignBit
      000108 C2 AF            [12]  582 	clr	_EA
      00010A 05 20            [12]  583 	inc	_keyGate
                                    584 ;	assignBit
      00010C D2 AF            [12]  585 	setb	_EA
                                    586 ;	dino.c:69: SemaphoreSignal(keyRoom);
                                    587 ;	assignBit
      00010E C2 AF            [12]  588 	clr	_EA
      000110 05 22            [12]  589 	inc	_keyRoom
                                    590 ;	assignBit
      000112 D2 AF            [12]  591 	setb	_EA
                                    592 ;	dino.c:70: return c;
      000114 8F 82            [24]  593 	mov	dpl, r7
                                    594 ;	dino.c:71: }
      000116 22               [24]  595 	ret
                                    596 ;------------------------------------------------------------
                                    597 ;Allocation info for local variables in function 'TakeKeyIfReady'
                                    598 ;------------------------------------------------------------
                                    599 ;c             Allocated to registers r7 
                                    600 ;------------------------------------------------------------
                                    601 ;	dino.c:73: char TakeKeyIfReady(void)
                                    602 ;	-----------------------------------------
                                    603 ;	 function TakeKeyIfReady
                                    604 ;	-----------------------------------------
      000117                        605 _TakeKeyIfReady:
                                    606 ;	dino.c:77: c = '\0';
      000117 7F 00            [12]  607 	mov	r7,#0x00
                                    608 ;	dino.c:78: EA = 0;
                                    609 ;	assignBit
      000119 C2 AF            [12]  610 	clr	_EA
                                    611 ;	dino.c:79: if (keyUsed > 0) {
      00011B E5 21            [12]  612 	mov	a,_keyUsed
      00011D 60 39            [24]  613 	jz	00118$
                                    614 ;	dino.c:80: keyUsed--;
      00011F E5 21            [12]  615 	mov	a,_keyUsed
      000121 14               [12]  616 	dec	a
      000122 F5 21            [12]  617 	mov	_keyUsed,a
                                    618 ;	dino.c:81: EA = 1;
                                    619 ;	assignBit
      000124 D2 AF            [12]  620 	setb	_EA
                                    621 ;	dino.c:83: SemaphoreWait(keyGate);
      000126                        622 00104$:
                                    623 ;	assignBit
      000126 C2 AF            [12]  624 	clr	_EA
      000128 E5 20            [12]  625 	mov	a,_keyGate
      00012A 60 06            [24]  626 	jz	00102$
      00012C 15 20            [12]  627 	dec	_keyGate
                                    628 ;	assignBit
      00012E D2 AF            [12]  629 	setb	_EA
      000130 80 04            [24]  630 	sjmp	00107$
      000132                        631 00102$:
                                    632 ;	assignBit
      000132 D2 AF            [12]  633 	setb	_EA
      000134 80 F0            [24]  634 	sjmp	00104$
      000136                        635 00107$:
                                    636 ;	dino.c:84: c = keyQueue[keyTakeAt];
      000136 E5 26            [12]  637 	mov	a,_keyTakeAt
      000138 24 23            [12]  638 	add	a, #_keyQueue
      00013A F9               [12]  639 	mov	r1,a
      00013B 87 07            [24]  640 	mov	ar7,@r1
                                    641 ;	dino.c:85: keyTakeAt++;
      00013D E5 26            [12]  642 	mov	a,_keyTakeAt
      00013F 04               [12]  643 	inc	a
      000140 F5 26            [12]  644 	mov	_keyTakeAt,a
                                    645 ;	dino.c:86: if (keyTakeAt == 3) {
      000142 74 03            [12]  646 	mov	a,#0x03
      000144 B5 26 03         [24]  647 	cjne	a,_keyTakeAt,00111$
                                    648 ;	dino.c:87: keyTakeAt = 0;
      000147 75 26 00         [24]  649 	mov	_keyTakeAt,#0x00
                                    650 ;	dino.c:89: SemaphoreSignal(keyGate);
      00014A                        651 00111$:
                                    652 ;	assignBit
      00014A C2 AF            [12]  653 	clr	_EA
      00014C 05 20            [12]  654 	inc	_keyGate
                                    655 ;	assignBit
      00014E D2 AF            [12]  656 	setb	_EA
                                    657 ;	dino.c:90: SemaphoreSignal(keyRoom);
                                    658 ;	assignBit
      000150 C2 AF            [12]  659 	clr	_EA
      000152 05 22            [12]  660 	inc	_keyRoom
                                    661 ;	assignBit
      000154 D2 AF            [12]  662 	setb	_EA
      000156 80 02            [24]  663 	sjmp	00119$
      000158                        664 00118$:
                                    665 ;	dino.c:92: EA = 1;
                                    666 ;	assignBit
      000158 D2 AF            [12]  667 	setb	_EA
      00015A                        668 00119$:
                                    669 ;	dino.c:94: return c;
      00015A 8F 82            [24]  670 	mov	dpl, r7
                                    671 ;	dino.c:95: }
      00015C 22               [24]  672 	ret
                                    673 ;------------------------------------------------------------
                                    674 ;Allocation info for local variables in function 'KeypadCtrlTask'
                                    675 ;------------------------------------------------------------
                                    676 ;nowKey        Allocated to registers 
                                    677 ;------------------------------------------------------------
                                    678 ;	dino.c:97: void KeypadCtrlTask(void)
                                    679 ;	-----------------------------------------
                                    680 ;	 function KeypadCtrlTask
                                    681 ;	-----------------------------------------
      00015D                        682 _KeypadCtrlTask:
                                    683 ;	dino.c:101: keyStillDown = 0;
      00015D 75 28 00         [24]  684 	mov	_keyStillDown,#0x00
                                    685 ;	dino.c:102: while (1) {
      000160                        686 00107$:
                                    687 ;	dino.c:103: if (AnyKeyPressed()) {
      000160 12 0B 37         [24]  688 	lcall	_AnyKeyPressed
      000163 E5 82            [12]  689 	mov	a, dpl
      000165 60 0F            [24]  690 	jz	00104$
                                    691 ;	dino.c:104: if (!keyStillDown) {
      000167 E5 28            [12]  692 	mov	a,_keyStillDown
      000169 70 F5            [24]  693 	jnz	00107$
                                    694 ;	dino.c:105: nowKey = KeyToChar();
      00016B 12 0B 44         [24]  695 	lcall	_KeyToChar
                                    696 ;	dino.c:106: PutKey(nowKey);
      00016E 12 00 81         [24]  697 	lcall	_PutKey
                                    698 ;	dino.c:107: keyStillDown = 1;
      000171 75 28 01         [24]  699 	mov	_keyStillDown,#0x01
      000174 80 EA            [24]  700 	sjmp	00107$
      000176                        701 00104$:
                                    702 ;	dino.c:110: keyStillDown = 0;
      000176 75 28 00         [24]  703 	mov	_keyStillDown,#0x00
                                    704 ;	dino.c:113: }
      000179 80 E5            [24]  705 	sjmp	00107$
                                    706 ;------------------------------------------------------------
                                    707 ;Allocation info for local variables in function 'WritePromptText'
                                    708 ;------------------------------------------------------------
                                    709 ;	dino.c:115: void WritePromptText(void)
                                    710 ;	-----------------------------------------
                                    711 ;	 function WritePromptText
                                    712 ;	-----------------------------------------
      00017B                        713 _WritePromptText:
                                    714 ;	dino.c:117: LCD_cursorGoTo(0, 0);
      00017B 75 82 80         [24]  715 	mov	dpl, #0x80
      00017E 12 0A 6E         [24]  716 	lcall	_LCD_IRWrite
                                    717 ;	dino.c:118: LCD_write_char('L'); LCD_write_char('e'); LCD_write_char('v'); LCD_write_char('e');
      000181 75 82 4C         [24]  718 	mov	dpl, #0x4c
      000184 12 0A D8         [24]  719 	lcall	_LCD_write_char
      000187 75 82 65         [24]  720 	mov	dpl, #0x65
      00018A 12 0A D8         [24]  721 	lcall	_LCD_write_char
      00018D 75 82 76         [24]  722 	mov	dpl, #0x76
      000190 12 0A D8         [24]  723 	lcall	_LCD_write_char
      000193 75 82 65         [24]  724 	mov	dpl, #0x65
      000196 12 0A D8         [24]  725 	lcall	_LCD_write_char
                                    726 ;	dino.c:119: LCD_write_char('l'); LCD_write_char('?'); LCD_write_char(' '); LCD_write_char('0');
      000199 75 82 6C         [24]  727 	mov	dpl, #0x6c
      00019C 12 0A D8         [24]  728 	lcall	_LCD_write_char
      00019F 75 82 3F         [24]  729 	mov	dpl, #0x3f
      0001A2 12 0A D8         [24]  730 	lcall	_LCD_write_char
      0001A5 75 82 20         [24]  731 	mov	dpl, #0x20
      0001A8 12 0A D8         [24]  732 	lcall	_LCD_write_char
      0001AB 75 82 30         [24]  733 	mov	dpl, #0x30
      0001AE 12 0A D8         [24]  734 	lcall	_LCD_write_char
                                    735 ;	dino.c:120: LCD_write_char('-'); LCD_write_char('9'); LCD_write_char(' '); LCD_write_char('t');
      0001B1 75 82 2D         [24]  736 	mov	dpl, #0x2d
      0001B4 12 0A D8         [24]  737 	lcall	_LCD_write_char
      0001B7 75 82 39         [24]  738 	mov	dpl, #0x39
      0001BA 12 0A D8         [24]  739 	lcall	_LCD_write_char
      0001BD 75 82 20         [24]  740 	mov	dpl, #0x20
      0001C0 12 0A D8         [24]  741 	lcall	_LCD_write_char
      0001C3 75 82 74         [24]  742 	mov	dpl, #0x74
      0001C6 12 0A D8         [24]  743 	lcall	_LCD_write_char
                                    744 ;	dino.c:121: LCD_write_char('h'); LCD_write_char('e'); LCD_write_char('n'); LCD_write_char('#');
      0001C9 75 82 68         [24]  745 	mov	dpl, #0x68
      0001CC 12 0A D8         [24]  746 	lcall	_LCD_write_char
      0001CF 75 82 65         [24]  747 	mov	dpl, #0x65
      0001D2 12 0A D8         [24]  748 	lcall	_LCD_write_char
      0001D5 75 82 6E         [24]  749 	mov	dpl, #0x6e
      0001D8 12 0A D8         [24]  750 	lcall	_LCD_write_char
      0001DB 75 82 23         [24]  751 	mov	dpl, #0x23
      0001DE 12 0A D8         [24]  752 	lcall	_LCD_write_char
                                    753 ;	dino.c:123: LCD_cursorGoTo(1, 0);
      0001E1 75 82 C0         [24]  754 	mov	dpl, #0xc0
      0001E4 12 0A 6E         [24]  755 	lcall	_LCD_IRWrite
                                    756 ;	dino.c:124: LCD_write_char('2'); LCD_write_char('='); LCD_write_char('u'); LCD_write_char('p');
      0001E7 75 82 32         [24]  757 	mov	dpl, #0x32
      0001EA 12 0A D8         [24]  758 	lcall	_LCD_write_char
      0001ED 75 82 3D         [24]  759 	mov	dpl, #0x3d
      0001F0 12 0A D8         [24]  760 	lcall	_LCD_write_char
      0001F3 75 82 75         [24]  761 	mov	dpl, #0x75
      0001F6 12 0A D8         [24]  762 	lcall	_LCD_write_char
      0001F9 75 82 70         [24]  763 	mov	dpl, #0x70
      0001FC 12 0A D8         [24]  764 	lcall	_LCD_write_char
                                    765 ;	dino.c:125: LCD_write_char(' '); LCD_write_char('8'); LCD_write_char('='); LCD_write_char('d');
      0001FF 75 82 20         [24]  766 	mov	dpl, #0x20
      000202 12 0A D8         [24]  767 	lcall	_LCD_write_char
      000205 75 82 38         [24]  768 	mov	dpl, #0x38
      000208 12 0A D8         [24]  769 	lcall	_LCD_write_char
      00020B 75 82 3D         [24]  770 	mov	dpl, #0x3d
      00020E 12 0A D8         [24]  771 	lcall	_LCD_write_char
      000211 75 82 64         [24]  772 	mov	dpl, #0x64
      000214 12 0A D8         [24]  773 	lcall	_LCD_write_char
                                    774 ;	dino.c:126: LCD_write_char('o'); LCD_write_char('w'); LCD_write_char('n'); LCD_write_char(' ');
      000217 75 82 6F         [24]  775 	mov	dpl, #0x6f
      00021A 12 0A D8         [24]  776 	lcall	_LCD_write_char
      00021D 75 82 77         [24]  777 	mov	dpl, #0x77
      000220 12 0A D8         [24]  778 	lcall	_LCD_write_char
      000223 75 82 6E         [24]  779 	mov	dpl, #0x6e
      000226 12 0A D8         [24]  780 	lcall	_LCD_write_char
      000229 75 82 20         [24]  781 	mov	dpl, #0x20
      00022C 12 0A D8         [24]  782 	lcall	_LCD_write_char
                                    783 ;	dino.c:127: LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' ');
      00022F 75 82 20         [24]  784 	mov	dpl, #0x20
      000232 12 0A D8         [24]  785 	lcall	_LCD_write_char
      000235 75 82 20         [24]  786 	mov	dpl, #0x20
      000238 12 0A D8         [24]  787 	lcall	_LCD_write_char
      00023B 75 82 20         [24]  788 	mov	dpl, #0x20
      00023E 12 0A D8         [24]  789 	lcall	_LCD_write_char
      000241 75 82 20         [24]  790 	mov	dpl, #0x20
                                    791 ;	dino.c:128: }
      000244 02 0A D8         [24]  792 	ljmp	_LCD_write_char
                                    793 ;------------------------------------------------------------
                                    794 ;Allocation info for local variables in function 'WriteGameOverText'
                                    795 ;------------------------------------------------------------
                                    796 ;	dino.c:130: void WriteGameOverText(void)
                                    797 ;	-----------------------------------------
                                    798 ;	 function WriteGameOverText
                                    799 ;	-----------------------------------------
      000247                        800 _WriteGameOverText:
                                    801 ;	dino.c:132: LCD_cursorGoTo(0, 0);
      000247 75 82 80         [24]  802 	mov	dpl, #0x80
      00024A 12 0A 6E         [24]  803 	lcall	_LCD_IRWrite
                                    804 ;	dino.c:133: LCD_write_char('G'); LCD_write_char('a'); LCD_write_char('m'); LCD_write_char('e');
      00024D 75 82 47         [24]  805 	mov	dpl, #0x47
      000250 12 0A D8         [24]  806 	lcall	_LCD_write_char
      000253 75 82 61         [24]  807 	mov	dpl, #0x61
      000256 12 0A D8         [24]  808 	lcall	_LCD_write_char
      000259 75 82 6D         [24]  809 	mov	dpl, #0x6d
      00025C 12 0A D8         [24]  810 	lcall	_LCD_write_char
      00025F 75 82 65         [24]  811 	mov	dpl, #0x65
      000262 12 0A D8         [24]  812 	lcall	_LCD_write_char
                                    813 ;	dino.c:134: LCD_write_char(' '); LCD_write_char('o'); LCD_write_char('v'); LCD_write_char('e');
      000265 75 82 20         [24]  814 	mov	dpl, #0x20
      000268 12 0A D8         [24]  815 	lcall	_LCD_write_char
      00026B 75 82 6F         [24]  816 	mov	dpl, #0x6f
      00026E 12 0A D8         [24]  817 	lcall	_LCD_write_char
      000271 75 82 76         [24]  818 	mov	dpl, #0x76
      000274 12 0A D8         [24]  819 	lcall	_LCD_write_char
      000277 75 82 65         [24]  820 	mov	dpl, #0x65
      00027A 12 0A D8         [24]  821 	lcall	_LCD_write_char
                                    822 ;	dino.c:135: LCD_write_char('r'); LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' ');
      00027D 75 82 72         [24]  823 	mov	dpl, #0x72
      000280 12 0A D8         [24]  824 	lcall	_LCD_write_char
      000283 75 82 20         [24]  825 	mov	dpl, #0x20
      000286 12 0A D8         [24]  826 	lcall	_LCD_write_char
      000289 75 82 20         [24]  827 	mov	dpl, #0x20
      00028C 12 0A D8         [24]  828 	lcall	_LCD_write_char
      00028F 75 82 20         [24]  829 	mov	dpl, #0x20
      000292 12 0A D8         [24]  830 	lcall	_LCD_write_char
                                    831 ;	dino.c:136: LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' ');
      000295 75 82 20         [24]  832 	mov	dpl, #0x20
      000298 12 0A D8         [24]  833 	lcall	_LCD_write_char
      00029B 75 82 20         [24]  834 	mov	dpl, #0x20
      00029E 12 0A D8         [24]  835 	lcall	_LCD_write_char
      0002A1 75 82 20         [24]  836 	mov	dpl, #0x20
      0002A4 12 0A D8         [24]  837 	lcall	_LCD_write_char
      0002A7 75 82 20         [24]  838 	mov	dpl, #0x20
      0002AA 12 0A D8         [24]  839 	lcall	_LCD_write_char
                                    840 ;	dino.c:138: LCD_cursorGoTo(1, 0);
      0002AD 75 82 C0         [24]  841 	mov	dpl, #0xc0
      0002B0 12 0A 6E         [24]  842 	lcall	_LCD_IRWrite
                                    843 ;	dino.c:139: LCD_write_char('S'); LCD_write_char('c'); LCD_write_char('o'); LCD_write_char('r');
      0002B3 75 82 53         [24]  844 	mov	dpl, #0x53
      0002B6 12 0A D8         [24]  845 	lcall	_LCD_write_char
      0002B9 75 82 63         [24]  846 	mov	dpl, #0x63
      0002BC 12 0A D8         [24]  847 	lcall	_LCD_write_char
      0002BF 75 82 6F         [24]  848 	mov	dpl, #0x6f
      0002C2 12 0A D8         [24]  849 	lcall	_LCD_write_char
      0002C5 75 82 72         [24]  850 	mov	dpl, #0x72
      0002C8 12 0A D8         [24]  851 	lcall	_LCD_write_char
                                    852 ;	dino.c:140: LCD_write_char('e'); LCD_write_char(':'); LCD_write_char(' ');
      0002CB 75 82 65         [24]  853 	mov	dpl, #0x65
      0002CE 12 0A D8         [24]  854 	lcall	_LCD_write_char
      0002D1 75 82 3A         [24]  855 	mov	dpl, #0x3a
      0002D4 12 0A D8         [24]  856 	lcall	_LCD_write_char
      0002D7 75 82 20         [24]  857 	mov	dpl, #0x20
                                    858 ;	dino.c:141: }
      0002DA 02 0A D8         [24]  859 	ljmp	_LCD_write_char
                                    860 ;------------------------------------------------------------
                                    861 ;Allocation info for local variables in function 'LCDWriteUint'
                                    862 ;------------------------------------------------------------
                                    863 ;value         Allocated to registers r6 r7 
                                    864 ;started       Allocated to registers r5 
                                    865 ;------------------------------------------------------------
                                    866 ;	dino.c:143: void LCDWriteUint(unsigned int value)
                                    867 ;	-----------------------------------------
                                    868 ;	 function LCDWriteUint
                                    869 ;	-----------------------------------------
      0002DD                        870 _LCDWriteUint:
      0002DD AE 82            [24]  871 	mov	r6, dpl
      0002DF AF 83            [24]  872 	mov	r7, dph
                                    873 ;	dino.c:147: started = 0;
      0002E1 7D 00            [12]  874 	mov	r5,#0x00
                                    875 ;	dino.c:148: if (value >= 10000) {
      0002E3 C3               [12]  876 	clr	c
      0002E4 EE               [12]  877 	mov	a,r6
      0002E5 94 10            [12]  878 	subb	a,#0x10
      0002E7 EF               [12]  879 	mov	a,r7
      0002E8 94 27            [12]  880 	subb	a,#0x27
      0002EA 40 32            [24]  881 	jc	00102$
                                    882 ;	dino.c:149: LCD_write_char('0' + (value / 10000));
      0002EC 75 08 10         [24]  883 	mov	__divuint_PARM_2,#0x10
      0002EF 75 09 27         [24]  884 	mov	(__divuint_PARM_2 + 1),#0x27
      0002F2 8E 82            [24]  885 	mov	dpl, r6
      0002F4 8F 83            [24]  886 	mov	dph, r7
      0002F6 C0 07            [24]  887 	push	ar7
      0002F8 C0 06            [24]  888 	push	ar6
      0002FA 12 0B C0         [24]  889 	lcall	__divuint
      0002FD AB 82            [24]  890 	mov	r3, dpl
      0002FF 74 30            [12]  891 	mov	a,#0x30
      000301 2B               [12]  892 	add	a, r3
      000302 F5 82            [12]  893 	mov	dpl,a
      000304 12 0A D8         [24]  894 	lcall	_LCD_write_char
      000307 D0 06            [24]  895 	pop	ar6
      000309 D0 07            [24]  896 	pop	ar7
                                    897 ;	dino.c:150: value = value % 10000;
      00030B 75 08 10         [24]  898 	mov	__moduint_PARM_2,#0x10
      00030E 75 09 27         [24]  899 	mov	(__moduint_PARM_2 + 1),#0x27
                                    900 ;	dino.c:151: started = 1;
      000311 8E 82            [24]  901 	mov	dpl, r6
      000313 8F 83            [24]  902 	mov	dph, r7
      000315 12 0B E9         [24]  903 	lcall	__moduint
      000318 AE 82            [24]  904 	mov	r6, dpl
      00031A AF 83            [24]  905 	mov	r7, dph
      00031C 7D 01            [12]  906 	mov	r5,#0x01
      00031E                        907 00102$:
                                    908 ;	dino.c:153: if (started || value >= 1000) {
      00031E ED               [12]  909 	mov	a,r5
      00031F 70 09            [24]  910 	jnz	00103$
      000321 C3               [12]  911 	clr	c
      000322 EE               [12]  912 	mov	a,r6
      000323 94 E8            [12]  913 	subb	a,#0xe8
      000325 EF               [12]  914 	mov	a,r7
      000326 94 03            [12]  915 	subb	a,#0x03
      000328 40 32            [24]  916 	jc	00104$
      00032A                        917 00103$:
                                    918 ;	dino.c:154: LCD_write_char('0' + (value / 1000));
      00032A 75 08 E8         [24]  919 	mov	__divuint_PARM_2,#0xe8
      00032D 75 09 03         [24]  920 	mov	(__divuint_PARM_2 + 1),#0x03
      000330 8E 82            [24]  921 	mov	dpl, r6
      000332 8F 83            [24]  922 	mov	dph, r7
      000334 C0 07            [24]  923 	push	ar7
      000336 C0 06            [24]  924 	push	ar6
      000338 12 0B C0         [24]  925 	lcall	__divuint
      00033B AB 82            [24]  926 	mov	r3, dpl
      00033D 74 30            [12]  927 	mov	a,#0x30
      00033F 2B               [12]  928 	add	a, r3
      000340 F5 82            [12]  929 	mov	dpl,a
      000342 12 0A D8         [24]  930 	lcall	_LCD_write_char
      000345 D0 06            [24]  931 	pop	ar6
      000347 D0 07            [24]  932 	pop	ar7
                                    933 ;	dino.c:155: value = value % 1000;
      000349 75 08 E8         [24]  934 	mov	__moduint_PARM_2,#0xe8
      00034C 75 09 03         [24]  935 	mov	(__moduint_PARM_2 + 1),#0x03
                                    936 ;	dino.c:156: started = 1;
      00034F 8E 82            [24]  937 	mov	dpl, r6
      000351 8F 83            [24]  938 	mov	dph, r7
      000353 12 0B E9         [24]  939 	lcall	__moduint
      000356 AE 82            [24]  940 	mov	r6, dpl
      000358 AF 83            [24]  941 	mov	r7, dph
      00035A 7D 01            [12]  942 	mov	r5,#0x01
      00035C                        943 00104$:
                                    944 ;	dino.c:158: if (started || value >= 100) {
      00035C ED               [12]  945 	mov	a,r5
      00035D 70 09            [24]  946 	jnz	00106$
      00035F C3               [12]  947 	clr	c
      000360 EE               [12]  948 	mov	a,r6
      000361 94 64            [12]  949 	subb	a,#0x64
      000363 EF               [12]  950 	mov	a,r7
      000364 94 00            [12]  951 	subb	a,#0x00
      000366 40 32            [24]  952 	jc	00107$
      000368                        953 00106$:
                                    954 ;	dino.c:159: LCD_write_char('0' + (value / 100));
      000368 75 08 64         [24]  955 	mov	__divuint_PARM_2,#0x64
      00036B 75 09 00         [24]  956 	mov	(__divuint_PARM_2 + 1),#0x00
      00036E 8E 82            [24]  957 	mov	dpl, r6
      000370 8F 83            [24]  958 	mov	dph, r7
      000372 C0 07            [24]  959 	push	ar7
      000374 C0 06            [24]  960 	push	ar6
      000376 12 0B C0         [24]  961 	lcall	__divuint
      000379 AB 82            [24]  962 	mov	r3, dpl
      00037B 74 30            [12]  963 	mov	a,#0x30
      00037D 2B               [12]  964 	add	a, r3
      00037E F5 82            [12]  965 	mov	dpl,a
      000380 12 0A D8         [24]  966 	lcall	_LCD_write_char
      000383 D0 06            [24]  967 	pop	ar6
      000385 D0 07            [24]  968 	pop	ar7
                                    969 ;	dino.c:160: value = value % 100;
      000387 75 08 64         [24]  970 	mov	__moduint_PARM_2,#0x64
      00038A 75 09 00         [24]  971 	mov	(__moduint_PARM_2 + 1),#0x00
                                    972 ;	dino.c:161: started = 1;
      00038D 8E 82            [24]  973 	mov	dpl, r6
      00038F 8F 83            [24]  974 	mov	dph, r7
      000391 12 0B E9         [24]  975 	lcall	__moduint
      000394 AE 82            [24]  976 	mov	r6, dpl
      000396 AF 83            [24]  977 	mov	r7, dph
      000398 7D 01            [12]  978 	mov	r5,#0x01
      00039A                        979 00107$:
                                    980 ;	dino.c:163: if (started || value >= 10) {
      00039A ED               [12]  981 	mov	a,r5
      00039B 70 09            [24]  982 	jnz	00109$
      00039D C3               [12]  983 	clr	c
      00039E EE               [12]  984 	mov	a,r6
      00039F 94 0A            [12]  985 	subb	a,#0x0a
      0003A1 EF               [12]  986 	mov	a,r7
      0003A2 94 00            [12]  987 	subb	a,#0x00
      0003A4 40 21            [24]  988 	jc	00110$
      0003A6                        989 00109$:
                                    990 ;	dino.c:164: LCD_write_char('0' + (value / 10));
      0003A6 8E 05            [24]  991 	mov	ar5,r6
      0003A8 75 F0 0A         [24]  992 	mov	b,#0x0a
      0003AB ED               [12]  993 	mov	a,r5
      0003AC 84               [48]  994 	div	ab
      0003AD 24 30            [12]  995 	add	a,#0x30
      0003AF F5 82            [12]  996 	mov	dpl,a
      0003B1 C0 07            [24]  997 	push	ar7
      0003B3 C0 06            [24]  998 	push	ar6
      0003B5 12 0A D8         [24]  999 	lcall	_LCD_write_char
      0003B8 D0 06            [24] 1000 	pop	ar6
      0003BA D0 07            [24] 1001 	pop	ar7
                                   1002 ;	dino.c:165: value = value % 10;
      0003BC 8E 05            [24] 1003 	mov	ar5,r6
      0003BE 75 F0 0A         [24] 1004 	mov	b,#0x0a
      0003C1 ED               [12] 1005 	mov	a,r5
      0003C2 84               [48] 1006 	div	ab
      0003C3 AD F0            [24] 1007 	mov	r5,b
      0003C5 8D 06            [24] 1008 	mov	ar6,r5
      0003C7                       1009 00110$:
                                   1010 ;	dino.c:167: LCD_write_char('0' + value);
      0003C7 74 30            [12] 1011 	mov	a,#0x30
      0003C9 2E               [12] 1012 	add	a, r6
      0003CA F5 82            [12] 1013 	mov	dpl,a
                                   1014 ;	dino.c:168: }
      0003CC 02 0A D8         [24] 1015 	ljmp	_LCD_write_char
                                   1016 ;------------------------------------------------------------
                                   1017 ;Allocation info for local variables in function 'LoadDinoSymbols'
                                   1018 ;------------------------------------------------------------
                                   1019 ;	dino.c:170: void LoadDinoSymbols(void)
                                   1020 ;	-----------------------------------------
                                   1021 ;	 function LoadDinoSymbols
                                   1022 ;	-----------------------------------------
      0003CF                       1023 _LoadDinoSymbols:
                                   1024 ;	dino.c:172: LCD_setCgRamAddress(0x08);
      0003CF 75 82 48         [24] 1025 	mov	dpl, #0x48
      0003D2 12 0A 6E         [24] 1026 	lcall	_LCD_IRWrite
                                   1027 ;	dino.c:173: LCD_write_char(0x07); LCD_write_char(0x05); LCD_write_char(0x06); LCD_write_char(0x07);
      0003D5 75 82 07         [24] 1028 	mov	dpl, #0x07
      0003D8 12 0A D8         [24] 1029 	lcall	_LCD_write_char
      0003DB 75 82 05         [24] 1030 	mov	dpl, #0x05
      0003DE 12 0A D8         [24] 1031 	lcall	_LCD_write_char
      0003E1 75 82 06         [24] 1032 	mov	dpl, #0x06
      0003E4 12 0A D8         [24] 1033 	lcall	_LCD_write_char
      0003E7 75 82 07         [24] 1034 	mov	dpl, #0x07
      0003EA 12 0A D8         [24] 1035 	lcall	_LCD_write_char
                                   1036 ;	dino.c:174: LCD_write_char(0x14); LCD_write_char(0x17); LCD_write_char(0x0E); LCD_write_char(0x0A);
      0003ED 75 82 14         [24] 1037 	mov	dpl, #0x14
      0003F0 12 0A D8         [24] 1038 	lcall	_LCD_write_char
      0003F3 75 82 17         [24] 1039 	mov	dpl, #0x17
      0003F6 12 0A D8         [24] 1040 	lcall	_LCD_write_char
      0003F9 75 82 0E         [24] 1041 	mov	dpl, #0x0e
      0003FC 12 0A D8         [24] 1042 	lcall	_LCD_write_char
      0003FF 75 82 0A         [24] 1043 	mov	dpl, #0x0a
      000402 12 0A D8         [24] 1044 	lcall	_LCD_write_char
                                   1045 ;	dino.c:176: LCD_setCgRamAddress(0x10);
      000405 75 82 50         [24] 1046 	mov	dpl, #0x50
      000408 12 0A 6E         [24] 1047 	lcall	_LCD_IRWrite
                                   1048 ;	dino.c:177: LCD_write_char(0x04); LCD_write_char(0x05); LCD_write_char(0x15); LCD_write_char(0x15);
      00040B 75 82 04         [24] 1049 	mov	dpl, #0x04
      00040E 12 0A D8         [24] 1050 	lcall	_LCD_write_char
      000411 75 82 05         [24] 1051 	mov	dpl, #0x05
      000414 12 0A D8         [24] 1052 	lcall	_LCD_write_char
      000417 75 82 15         [24] 1053 	mov	dpl, #0x15
      00041A 12 0A D8         [24] 1054 	lcall	_LCD_write_char
      00041D 75 82 15         [24] 1055 	mov	dpl, #0x15
      000420 12 0A D8         [24] 1056 	lcall	_LCD_write_char
                                   1057 ;	dino.c:178: LCD_write_char(0x16); LCD_write_char(0x0C); LCD_write_char(0x04); LCD_write_char(0x04);
      000423 75 82 16         [24] 1058 	mov	dpl, #0x16
      000426 12 0A D8         [24] 1059 	lcall	_LCD_write_char
      000429 75 82 0C         [24] 1060 	mov	dpl, #0x0c
      00042C 12 0A D8         [24] 1061 	lcall	_LCD_write_char
      00042F 75 82 04         [24] 1062 	mov	dpl, #0x04
      000432 12 0A D8         [24] 1063 	lcall	_LCD_write_char
      000435 75 82 04         [24] 1064 	mov	dpl, #0x04
                                   1065 ;	dino.c:179: }
      000438 02 0A D8         [24] 1066 	ljmp	_LCD_write_char
                                   1067 ;------------------------------------------------------------
                                   1068 ;Allocation info for local variables in function 'DrawGameRows'
                                   1069 ;------------------------------------------------------------
                                   1070 ;	dino.c:190: void DrawGameRows(void)
                                   1071 ;	-----------------------------------------
                                   1072 ;	 function DrawGameRows
                                   1073 ;	-----------------------------------------
      00043B                       1074 _DrawGameRows:
                                   1075 ;	dino.c:192: LCD_cursorGoTo(0, 0);
      00043B 75 82 80         [24] 1076 	mov	dpl, #0x80
      00043E 12 0A 6E         [24] 1077 	lcall	_LCD_IRWrite
                                   1078 ;	dino.c:193: if (dinoRow == 0) {
      000441 E5 2A            [12] 1079 	mov	a,_dinoRow
      000443 70 08            [24] 1080 	jnz	00104$
                                   1081 ;	dino.c:194: LCD_write_char(DINO_SYMBOL);
      000445 75 82 01         [24] 1082 	mov	dpl, #0x01
      000448 12 0A D8         [24] 1083 	lcall	_LCD_write_char
                                   1084 ;	dino.c:196: DrawCactusCell(cactusRow0, 0x0001);
      00044B 80 13            [24] 1085 	sjmp	00113$
      00044D                       1086 00104$:
      00044D E5 2C            [12] 1087 	mov	a,_cactusRow0
      00044F 30 E0 08         [24] 1088 	jnb	acc.0,00102$
      000452 75 82 02         [24] 1089 	mov	dpl, #0x02
      000455 12 0A D8         [24] 1090 	lcall	_LCD_write_char
      000458 80 06            [24] 1091 	sjmp	00113$
      00045A                       1092 00102$:
      00045A 75 82 20         [24] 1093 	mov	dpl, #0x20
      00045D 12 0A D8         [24] 1094 	lcall	_LCD_write_char
                                   1095 ;	dino.c:198: DrawCactusCell(cactusRow0, 0x0002);
      000460                       1096 00113$:
      000460 E5 2C            [12] 1097 	mov	a,_cactusRow0
      000462 30 E1 08         [24] 1098 	jnb	acc.1,00111$
      000465 75 82 02         [24] 1099 	mov	dpl, #0x02
      000468 12 0A D8         [24] 1100 	lcall	_LCD_write_char
      00046B 80 06            [24] 1101 	sjmp	00114$
      00046D                       1102 00111$:
      00046D 75 82 20         [24] 1103 	mov	dpl, #0x20
      000470 12 0A D8         [24] 1104 	lcall	_LCD_write_char
      000473                       1105 00114$:
                                   1106 ;	dino.c:199: DrawCactusCell(cactusRow0, 0x0004);
      000473 E5 2C            [12] 1107 	mov	a,_cactusRow0
      000475 30 E2 08         [24] 1108 	jnb	acc.2,00117$
      000478 75 82 02         [24] 1109 	mov	dpl, #0x02
      00047B 12 0A D8         [24] 1110 	lcall	_LCD_write_char
      00047E 80 06            [24] 1111 	sjmp	00120$
      000480                       1112 00117$:
      000480 75 82 20         [24] 1113 	mov	dpl, #0x20
      000483 12 0A D8         [24] 1114 	lcall	_LCD_write_char
      000486                       1115 00120$:
                                   1116 ;	dino.c:200: DrawCactusCell(cactusRow0, 0x0008);
      000486 E5 2C            [12] 1117 	mov	a,_cactusRow0
      000488 30 E3 08         [24] 1118 	jnb	acc.3,00123$
      00048B 75 82 02         [24] 1119 	mov	dpl, #0x02
      00048E 12 0A D8         [24] 1120 	lcall	_LCD_write_char
      000491 80 06            [24] 1121 	sjmp	00126$
      000493                       1122 00123$:
      000493 75 82 20         [24] 1123 	mov	dpl, #0x20
      000496 12 0A D8         [24] 1124 	lcall	_LCD_write_char
      000499                       1125 00126$:
                                   1126 ;	dino.c:201: DrawCactusCell(cactusRow0, 0x0010);
      000499 E5 2C            [12] 1127 	mov	a,_cactusRow0
      00049B 30 E4 08         [24] 1128 	jnb	acc.4,00129$
      00049E 75 82 02         [24] 1129 	mov	dpl, #0x02
      0004A1 12 0A D8         [24] 1130 	lcall	_LCD_write_char
      0004A4 80 06            [24] 1131 	sjmp	00132$
      0004A6                       1132 00129$:
      0004A6 75 82 20         [24] 1133 	mov	dpl, #0x20
      0004A9 12 0A D8         [24] 1134 	lcall	_LCD_write_char
      0004AC                       1135 00132$:
                                   1136 ;	dino.c:202: DrawCactusCell(cactusRow0, 0x0020);
      0004AC E5 2C            [12] 1137 	mov	a,_cactusRow0
      0004AE 30 E5 08         [24] 1138 	jnb	acc.5,00135$
      0004B1 75 82 02         [24] 1139 	mov	dpl, #0x02
      0004B4 12 0A D8         [24] 1140 	lcall	_LCD_write_char
      0004B7 80 06            [24] 1141 	sjmp	00138$
      0004B9                       1142 00135$:
      0004B9 75 82 20         [24] 1143 	mov	dpl, #0x20
      0004BC 12 0A D8         [24] 1144 	lcall	_LCD_write_char
      0004BF                       1145 00138$:
                                   1146 ;	dino.c:203: DrawCactusCell(cactusRow0, 0x0040);
      0004BF E5 2C            [12] 1147 	mov	a,_cactusRow0
      0004C1 30 E6 08         [24] 1148 	jnb	acc.6,00141$
      0004C4 75 82 02         [24] 1149 	mov	dpl, #0x02
      0004C7 12 0A D8         [24] 1150 	lcall	_LCD_write_char
      0004CA 80 06            [24] 1151 	sjmp	00144$
      0004CC                       1152 00141$:
      0004CC 75 82 20         [24] 1153 	mov	dpl, #0x20
      0004CF 12 0A D8         [24] 1154 	lcall	_LCD_write_char
      0004D2                       1155 00144$:
                                   1156 ;	dino.c:204: DrawCactusCell(cactusRow0, 0x0080);
      0004D2 E5 2C            [12] 1157 	mov	a,_cactusRow0
      0004D4 30 E7 08         [24] 1158 	jnb	acc.7,00147$
      0004D7 75 82 02         [24] 1159 	mov	dpl, #0x02
      0004DA 12 0A D8         [24] 1160 	lcall	_LCD_write_char
      0004DD 80 06            [24] 1161 	sjmp	00150$
      0004DF                       1162 00147$:
      0004DF 75 82 20         [24] 1163 	mov	dpl, #0x20
      0004E2 12 0A D8         [24] 1164 	lcall	_LCD_write_char
      0004E5                       1165 00150$:
                                   1166 ;	dino.c:205: DrawCactusCell(cactusRow0, 0x0100);
      0004E5 E5 2D            [12] 1167 	mov	a,(_cactusRow0 + 1)
      0004E7 30 E0 08         [24] 1168 	jnb	acc.0,00153$
      0004EA 75 82 02         [24] 1169 	mov	dpl, #0x02
      0004ED 12 0A D8         [24] 1170 	lcall	_LCD_write_char
      0004F0 80 06            [24] 1171 	sjmp	00156$
      0004F2                       1172 00153$:
      0004F2 75 82 20         [24] 1173 	mov	dpl, #0x20
      0004F5 12 0A D8         [24] 1174 	lcall	_LCD_write_char
      0004F8                       1175 00156$:
                                   1176 ;	dino.c:206: DrawCactusCell(cactusRow0, 0x0200);
      0004F8 E5 2D            [12] 1177 	mov	a,(_cactusRow0 + 1)
      0004FA 30 E1 08         [24] 1178 	jnb	acc.1,00159$
      0004FD 75 82 02         [24] 1179 	mov	dpl, #0x02
      000500 12 0A D8         [24] 1180 	lcall	_LCD_write_char
      000503 80 06            [24] 1181 	sjmp	00162$
      000505                       1182 00159$:
      000505 75 82 20         [24] 1183 	mov	dpl, #0x20
      000508 12 0A D8         [24] 1184 	lcall	_LCD_write_char
      00050B                       1185 00162$:
                                   1186 ;	dino.c:207: DrawCactusCell(cactusRow0, 0x0400);
      00050B E5 2D            [12] 1187 	mov	a,(_cactusRow0 + 1)
      00050D 30 E2 08         [24] 1188 	jnb	acc.2,00165$
      000510 75 82 02         [24] 1189 	mov	dpl, #0x02
      000513 12 0A D8         [24] 1190 	lcall	_LCD_write_char
      000516 80 06            [24] 1191 	sjmp	00168$
      000518                       1192 00165$:
      000518 75 82 20         [24] 1193 	mov	dpl, #0x20
      00051B 12 0A D8         [24] 1194 	lcall	_LCD_write_char
      00051E                       1195 00168$:
                                   1196 ;	dino.c:208: DrawCactusCell(cactusRow0, 0x0800);
      00051E E5 2D            [12] 1197 	mov	a,(_cactusRow0 + 1)
      000520 30 E3 08         [24] 1198 	jnb	acc.3,00171$
      000523 75 82 02         [24] 1199 	mov	dpl, #0x02
      000526 12 0A D8         [24] 1200 	lcall	_LCD_write_char
      000529 80 06            [24] 1201 	sjmp	00174$
      00052B                       1202 00171$:
      00052B 75 82 20         [24] 1203 	mov	dpl, #0x20
      00052E 12 0A D8         [24] 1204 	lcall	_LCD_write_char
      000531                       1205 00174$:
                                   1206 ;	dino.c:209: DrawCactusCell(cactusRow0, 0x1000);
      000531 E5 2D            [12] 1207 	mov	a,(_cactusRow0 + 1)
      000533 30 E4 08         [24] 1208 	jnb	acc.4,00177$
      000536 75 82 02         [24] 1209 	mov	dpl, #0x02
      000539 12 0A D8         [24] 1210 	lcall	_LCD_write_char
      00053C 80 06            [24] 1211 	sjmp	00180$
      00053E                       1212 00177$:
      00053E 75 82 20         [24] 1213 	mov	dpl, #0x20
      000541 12 0A D8         [24] 1214 	lcall	_LCD_write_char
      000544                       1215 00180$:
                                   1216 ;	dino.c:210: DrawCactusCell(cactusRow0, 0x2000);
      000544 E5 2D            [12] 1217 	mov	a,(_cactusRow0 + 1)
      000546 30 E5 08         [24] 1218 	jnb	acc.5,00183$
      000549 75 82 02         [24] 1219 	mov	dpl, #0x02
      00054C 12 0A D8         [24] 1220 	lcall	_LCD_write_char
      00054F 80 06            [24] 1221 	sjmp	00186$
      000551                       1222 00183$:
      000551 75 82 20         [24] 1223 	mov	dpl, #0x20
      000554 12 0A D8         [24] 1224 	lcall	_LCD_write_char
      000557                       1225 00186$:
                                   1226 ;	dino.c:211: DrawCactusCell(cactusRow0, 0x4000);
      000557 E5 2D            [12] 1227 	mov	a,(_cactusRow0 + 1)
      000559 30 E6 08         [24] 1228 	jnb	acc.6,00189$
      00055C 75 82 02         [24] 1229 	mov	dpl, #0x02
      00055F 12 0A D8         [24] 1230 	lcall	_LCD_write_char
      000562 80 06            [24] 1231 	sjmp	00192$
      000564                       1232 00189$:
      000564 75 82 20         [24] 1233 	mov	dpl, #0x20
      000567 12 0A D8         [24] 1234 	lcall	_LCD_write_char
      00056A                       1235 00192$:
                                   1236 ;	dino.c:212: DrawCactusCell(cactusRow0, 0x8000);
      00056A E5 2D            [12] 1237 	mov	a,(_cactusRow0 + 1)
      00056C 30 E7 08         [24] 1238 	jnb	acc.7,00195$
      00056F 75 82 02         [24] 1239 	mov	dpl, #0x02
      000572 12 0A D8         [24] 1240 	lcall	_LCD_write_char
      000575 80 06            [24] 1241 	sjmp	00198$
      000577                       1242 00195$:
      000577 75 82 20         [24] 1243 	mov	dpl, #0x20
      00057A 12 0A D8         [24] 1244 	lcall	_LCD_write_char
      00057D                       1245 00198$:
                                   1246 ;	dino.c:214: LCD_cursorGoTo(1, 0);
      00057D 75 82 C0         [24] 1247 	mov	dpl, #0xc0
      000580 12 0A 6E         [24] 1248 	lcall	_LCD_IRWrite
                                   1249 ;	dino.c:215: if (dinoRow == 1) {
      000583 74 01            [12] 1250 	mov	a,#0x01
      000585 B5 2A 08         [24] 1251 	cjne	a,_dinoRow,00203$
                                   1252 ;	dino.c:216: LCD_write_char(DINO_SYMBOL);
      000588 75 82 01         [24] 1253 	mov	dpl, #0x01
      00058B 12 0A D8         [24] 1254 	lcall	_LCD_write_char
                                   1255 ;	dino.c:218: DrawCactusCell(cactusRow1, 0x0001);
      00058E 80 13            [24] 1256 	sjmp	00212$
      000590                       1257 00203$:
      000590 E5 2E            [12] 1258 	mov	a,_cactusRow1
      000592 30 E0 08         [24] 1259 	jnb	acc.0,00201$
      000595 75 82 02         [24] 1260 	mov	dpl, #0x02
      000598 12 0A D8         [24] 1261 	lcall	_LCD_write_char
      00059B 80 06            [24] 1262 	sjmp	00212$
      00059D                       1263 00201$:
      00059D 75 82 20         [24] 1264 	mov	dpl, #0x20
      0005A0 12 0A D8         [24] 1265 	lcall	_LCD_write_char
                                   1266 ;	dino.c:220: DrawCactusCell(cactusRow1, 0x0002);
      0005A3                       1267 00212$:
      0005A3 E5 2E            [12] 1268 	mov	a,_cactusRow1
      0005A5 30 E1 08         [24] 1269 	jnb	acc.1,00210$
      0005A8 75 82 02         [24] 1270 	mov	dpl, #0x02
      0005AB 12 0A D8         [24] 1271 	lcall	_LCD_write_char
      0005AE 80 06            [24] 1272 	sjmp	00213$
      0005B0                       1273 00210$:
      0005B0 75 82 20         [24] 1274 	mov	dpl, #0x20
      0005B3 12 0A D8         [24] 1275 	lcall	_LCD_write_char
      0005B6                       1276 00213$:
                                   1277 ;	dino.c:221: DrawCactusCell(cactusRow1, 0x0004);
      0005B6 E5 2E            [12] 1278 	mov	a,_cactusRow1
      0005B8 30 E2 08         [24] 1279 	jnb	acc.2,00216$
      0005BB 75 82 02         [24] 1280 	mov	dpl, #0x02
      0005BE 12 0A D8         [24] 1281 	lcall	_LCD_write_char
      0005C1 80 06            [24] 1282 	sjmp	00219$
      0005C3                       1283 00216$:
      0005C3 75 82 20         [24] 1284 	mov	dpl, #0x20
      0005C6 12 0A D8         [24] 1285 	lcall	_LCD_write_char
      0005C9                       1286 00219$:
                                   1287 ;	dino.c:222: DrawCactusCell(cactusRow1, 0x0008);
      0005C9 E5 2E            [12] 1288 	mov	a,_cactusRow1
      0005CB 30 E3 08         [24] 1289 	jnb	acc.3,00222$
      0005CE 75 82 02         [24] 1290 	mov	dpl, #0x02
      0005D1 12 0A D8         [24] 1291 	lcall	_LCD_write_char
      0005D4 80 06            [24] 1292 	sjmp	00225$
      0005D6                       1293 00222$:
      0005D6 75 82 20         [24] 1294 	mov	dpl, #0x20
      0005D9 12 0A D8         [24] 1295 	lcall	_LCD_write_char
      0005DC                       1296 00225$:
                                   1297 ;	dino.c:223: DrawCactusCell(cactusRow1, 0x0010);
      0005DC E5 2E            [12] 1298 	mov	a,_cactusRow1
      0005DE 30 E4 08         [24] 1299 	jnb	acc.4,00228$
      0005E1 75 82 02         [24] 1300 	mov	dpl, #0x02
      0005E4 12 0A D8         [24] 1301 	lcall	_LCD_write_char
      0005E7 80 06            [24] 1302 	sjmp	00231$
      0005E9                       1303 00228$:
      0005E9 75 82 20         [24] 1304 	mov	dpl, #0x20
      0005EC 12 0A D8         [24] 1305 	lcall	_LCD_write_char
      0005EF                       1306 00231$:
                                   1307 ;	dino.c:224: DrawCactusCell(cactusRow1, 0x0020);
      0005EF E5 2E            [12] 1308 	mov	a,_cactusRow1
      0005F1 30 E5 08         [24] 1309 	jnb	acc.5,00234$
      0005F4 75 82 02         [24] 1310 	mov	dpl, #0x02
      0005F7 12 0A D8         [24] 1311 	lcall	_LCD_write_char
      0005FA 80 06            [24] 1312 	sjmp	00237$
      0005FC                       1313 00234$:
      0005FC 75 82 20         [24] 1314 	mov	dpl, #0x20
      0005FF 12 0A D8         [24] 1315 	lcall	_LCD_write_char
      000602                       1316 00237$:
                                   1317 ;	dino.c:225: DrawCactusCell(cactusRow1, 0x0040);
      000602 E5 2E            [12] 1318 	mov	a,_cactusRow1
      000604 30 E6 08         [24] 1319 	jnb	acc.6,00240$
      000607 75 82 02         [24] 1320 	mov	dpl, #0x02
      00060A 12 0A D8         [24] 1321 	lcall	_LCD_write_char
      00060D 80 06            [24] 1322 	sjmp	00243$
      00060F                       1323 00240$:
      00060F 75 82 20         [24] 1324 	mov	dpl, #0x20
      000612 12 0A D8         [24] 1325 	lcall	_LCD_write_char
      000615                       1326 00243$:
                                   1327 ;	dino.c:226: DrawCactusCell(cactusRow1, 0x0080);
      000615 E5 2E            [12] 1328 	mov	a,_cactusRow1
      000617 30 E7 08         [24] 1329 	jnb	acc.7,00246$
      00061A 75 82 02         [24] 1330 	mov	dpl, #0x02
      00061D 12 0A D8         [24] 1331 	lcall	_LCD_write_char
      000620 80 06            [24] 1332 	sjmp	00249$
      000622                       1333 00246$:
      000622 75 82 20         [24] 1334 	mov	dpl, #0x20
      000625 12 0A D8         [24] 1335 	lcall	_LCD_write_char
      000628                       1336 00249$:
                                   1337 ;	dino.c:227: DrawCactusCell(cactusRow1, 0x0100);
      000628 E5 2F            [12] 1338 	mov	a,(_cactusRow1 + 1)
      00062A 30 E0 08         [24] 1339 	jnb	acc.0,00252$
      00062D 75 82 02         [24] 1340 	mov	dpl, #0x02
      000630 12 0A D8         [24] 1341 	lcall	_LCD_write_char
      000633 80 06            [24] 1342 	sjmp	00255$
      000635                       1343 00252$:
      000635 75 82 20         [24] 1344 	mov	dpl, #0x20
      000638 12 0A D8         [24] 1345 	lcall	_LCD_write_char
      00063B                       1346 00255$:
                                   1347 ;	dino.c:228: DrawCactusCell(cactusRow1, 0x0200);
      00063B E5 2F            [12] 1348 	mov	a,(_cactusRow1 + 1)
      00063D 30 E1 08         [24] 1349 	jnb	acc.1,00258$
      000640 75 82 02         [24] 1350 	mov	dpl, #0x02
      000643 12 0A D8         [24] 1351 	lcall	_LCD_write_char
      000646 80 06            [24] 1352 	sjmp	00261$
      000648                       1353 00258$:
      000648 75 82 20         [24] 1354 	mov	dpl, #0x20
      00064B 12 0A D8         [24] 1355 	lcall	_LCD_write_char
      00064E                       1356 00261$:
                                   1357 ;	dino.c:229: DrawCactusCell(cactusRow1, 0x0400);
      00064E E5 2F            [12] 1358 	mov	a,(_cactusRow1 + 1)
      000650 30 E2 08         [24] 1359 	jnb	acc.2,00264$
      000653 75 82 02         [24] 1360 	mov	dpl, #0x02
      000656 12 0A D8         [24] 1361 	lcall	_LCD_write_char
      000659 80 06            [24] 1362 	sjmp	00267$
      00065B                       1363 00264$:
      00065B 75 82 20         [24] 1364 	mov	dpl, #0x20
      00065E 12 0A D8         [24] 1365 	lcall	_LCD_write_char
      000661                       1366 00267$:
                                   1367 ;	dino.c:230: DrawCactusCell(cactusRow1, 0x0800);
      000661 E5 2F            [12] 1368 	mov	a,(_cactusRow1 + 1)
      000663 30 E3 08         [24] 1369 	jnb	acc.3,00270$
      000666 75 82 02         [24] 1370 	mov	dpl, #0x02
      000669 12 0A D8         [24] 1371 	lcall	_LCD_write_char
      00066C 80 06            [24] 1372 	sjmp	00273$
      00066E                       1373 00270$:
      00066E 75 82 20         [24] 1374 	mov	dpl, #0x20
      000671 12 0A D8         [24] 1375 	lcall	_LCD_write_char
      000674                       1376 00273$:
                                   1377 ;	dino.c:231: DrawCactusCell(cactusRow1, 0x1000);
      000674 E5 2F            [12] 1378 	mov	a,(_cactusRow1 + 1)
      000676 30 E4 08         [24] 1379 	jnb	acc.4,00276$
      000679 75 82 02         [24] 1380 	mov	dpl, #0x02
      00067C 12 0A D8         [24] 1381 	lcall	_LCD_write_char
      00067F 80 06            [24] 1382 	sjmp	00279$
      000681                       1383 00276$:
      000681 75 82 20         [24] 1384 	mov	dpl, #0x20
      000684 12 0A D8         [24] 1385 	lcall	_LCD_write_char
      000687                       1386 00279$:
                                   1387 ;	dino.c:232: DrawCactusCell(cactusRow1, 0x2000);
      000687 E5 2F            [12] 1388 	mov	a,(_cactusRow1 + 1)
      000689 30 E5 08         [24] 1389 	jnb	acc.5,00282$
      00068C 75 82 02         [24] 1390 	mov	dpl, #0x02
      00068F 12 0A D8         [24] 1391 	lcall	_LCD_write_char
      000692 80 06            [24] 1392 	sjmp	00285$
      000694                       1393 00282$:
      000694 75 82 20         [24] 1394 	mov	dpl, #0x20
      000697 12 0A D8         [24] 1395 	lcall	_LCD_write_char
      00069A                       1396 00285$:
                                   1397 ;	dino.c:233: DrawCactusCell(cactusRow1, 0x4000);
      00069A E5 2F            [12] 1398 	mov	a,(_cactusRow1 + 1)
      00069C 30 E6 08         [24] 1399 	jnb	acc.6,00288$
      00069F 75 82 02         [24] 1400 	mov	dpl, #0x02
      0006A2 12 0A D8         [24] 1401 	lcall	_LCD_write_char
      0006A5 80 06            [24] 1402 	sjmp	00291$
      0006A7                       1403 00288$:
      0006A7 75 82 20         [24] 1404 	mov	dpl, #0x20
      0006AA 12 0A D8         [24] 1405 	lcall	_LCD_write_char
      0006AD                       1406 00291$:
                                   1407 ;	dino.c:234: DrawCactusCell(cactusRow1, 0x8000);
      0006AD E5 2F            [12] 1408 	mov	a,(_cactusRow1 + 1)
      0006AF 30 E7 06         [24] 1409 	jnb	acc.7,00294$
      0006B2 75 82 02         [24] 1410 	mov	dpl, #0x02
      0006B5 02 0A D8         [24] 1411 	ljmp	_LCD_write_char
      0006B8                       1412 00294$:
      0006B8 75 82 20         [24] 1413 	mov	dpl, #0x20
                                   1414 ;	dino.c:235: }
      0006BB 02 0A D8         [24] 1415 	ljmp	_LCD_write_char
                                   1416 ;------------------------------------------------------------
                                   1417 ;Allocation info for local variables in function 'RenderTask'
                                   1418 ;------------------------------------------------------------
                                   1419 ;lastMode      Allocated to registers r7 
                                   1420 ;------------------------------------------------------------
                                   1421 ;	dino.c:237: void RenderTask(void)
                                   1422 ;	-----------------------------------------
                                   1423 ;	 function RenderTask
                                   1424 ;	-----------------------------------------
      0006BE                       1425 _RenderTask:
                                   1426 ;	dino.c:241: LCD_Init();
      0006BE 12 0A 5B         [24] 1427 	lcall	_LCD_Init
                                   1428 ;	dino.c:242: while (!LCD_ready()) { }
      0006C1                       1429 00101$:
      0006C1 12 0A 57         [24] 1430 	lcall	_LCD_ready
      0006C4 E5 82            [12] 1431 	mov	a, dpl
      0006C6 60 F9            [24] 1432 	jz	00101$
                                   1433 ;	dino.c:243: LoadDinoSymbols();
      0006C8 12 03 CF         [24] 1434 	lcall	_LoadDinoSymbols
                                   1435 ;	dino.c:244: LCD_clearScreen();
      0006CB 75 82 01         [24] 1436 	mov	dpl, #0x01
      0006CE 12 0A 6E         [24] 1437 	lcall	_LCD_IRWrite
                                   1438 ;	dino.c:245: lastMode = 3;
      0006D1 7F 03            [12] 1439 	mov	r7,#0x03
                                   1440 ;	dino.c:247: while (1) {
      0006D3                       1441 00124$:
                                   1442 ;	dino.c:248: if (playMode == 2) {
      0006D3 74 02            [12] 1443 	mov	a,#0x02
      0006D5 B5 2B 19         [24] 1444 	cjne	a,_playMode,00121$
                                   1445 ;	dino.c:249: if (lastMode != 2) {
      0006D8 BF 02 02         [24] 1446 	cjne	r7,#0x02,00173$
      0006DB 80 0B            [24] 1447 	sjmp	00105$
      0006DD                       1448 00173$:
                                   1449 ;	dino.c:250: LCD_clearScreen();
      0006DD 75 82 01         [24] 1450 	mov	dpl, #0x01
      0006E0 12 0A 6E         [24] 1451 	lcall	_LCD_IRWrite
                                   1452 ;	dino.c:251: WritePromptText();
      0006E3 12 01 7B         [24] 1453 	lcall	_WritePromptText
                                   1454 ;	dino.c:252: lastMode = 2;
      0006E6 7F 02            [12] 1455 	mov	r7,#0x02
      0006E8                       1456 00105$:
                                   1457 ;	dino.c:254: ThreadYield();
      0006E8 C0 07            [24] 1458 	push	ar7
      0006EA 12 09 7E         [24] 1459 	lcall	_ThreadYield
      0006ED D0 07            [24] 1460 	pop	ar7
      0006EF 80 E2            [24] 1461 	sjmp	00124$
      0006F1                       1462 00121$:
                                   1463 ;	dino.c:255: } else if (playMode == 1) {
      0006F1 74 01            [12] 1464 	mov	a,#0x01
      0006F3 B5 2B 24         [24] 1465 	cjne	a,_playMode,00118$
                                   1466 ;	dino.c:256: SemaphoreWait(sceneGate);
      0006F6                       1467 00109$:
                                   1468 ;	assignBit
      0006F6 C2 AF            [12] 1469 	clr	_EA
      0006F8 E5 29            [12] 1470 	mov	a,_sceneGate
      0006FA 60 06            [24] 1471 	jz	00107$
      0006FC 15 29            [12] 1472 	dec	_sceneGate
                                   1473 ;	assignBit
      0006FE D2 AF            [12] 1474 	setb	_EA
      000700 80 04            [24] 1475 	sjmp	00112$
      000702                       1476 00107$:
                                   1477 ;	assignBit
      000702 D2 AF            [12] 1478 	setb	_EA
      000704 80 F0            [24] 1479 	sjmp	00109$
      000706                       1480 00112$:
                                   1481 ;	dino.c:257: DrawGameRows();
      000706 12 04 3B         [24] 1482 	lcall	_DrawGameRows
                                   1483 ;	dino.c:258: SemaphoreSignal(sceneGate);
                                   1484 ;	assignBit
      000709 C2 AF            [12] 1485 	clr	_EA
      00070B 05 29            [12] 1486 	inc	_sceneGate
                                   1487 ;	assignBit
      00070D D2 AF            [12] 1488 	setb	_EA
                                   1489 ;	dino.c:259: lastMode = 1;
      00070F 7F 01            [12] 1490 	mov	r7,#0x01
                                   1491 ;	dino.c:260: ThreadYield();
      000711 C0 07            [24] 1492 	push	ar7
      000713 12 09 7E         [24] 1493 	lcall	_ThreadYield
      000716 D0 07            [24] 1494 	pop	ar7
      000718 80 B9            [24] 1495 	sjmp	00124$
      00071A                       1496 00118$:
                                   1497 ;	dino.c:262: lastMode = 0;
      00071A 7F 00            [12] 1498 	mov	r7,#0x00
                                   1499 ;	dino.c:263: ThreadYield();
      00071C C0 07            [24] 1500 	push	ar7
      00071E 12 09 7E         [24] 1501 	lcall	_ThreadYield
      000721 D0 07            [24] 1502 	pop	ar7
                                   1503 ;	dino.c:266: }
      000723 80 AE            [24] 1504 	sjmp	00124$
                                   1505 ;------------------------------------------------------------
                                   1506 ;Allocation info for local variables in function 'SmallDelay'
                                   1507 ;------------------------------------------------------------
                                   1508 ;count         Allocated to registers 
                                   1509 ;------------------------------------------------------------
                                   1510 ;	dino.c:268: void SmallDelay(unsigned char count)
                                   1511 ;	-----------------------------------------
                                   1512 ;	 function SmallDelay
                                   1513 ;	-----------------------------------------
      000725                       1514 _SmallDelay:
                                   1515 ;	dino.c:274: __endasm;
      000725                       1516 dino_wait_loop:
      000725 D5 82 FD         [24] 1517 	djnz	dpl, dino_wait_loop
                                   1518 ;	dino.c:275: }
      000728 22               [24] 1519 	ret
                                   1520 ;------------------------------------------------------------
                                   1521 ;Allocation info for local variables in function 'FrameDelay'
                                   1522 ;------------------------------------------------------------
                                   1523 ;rounds        Allocated to registers 
                                   1524 ;------------------------------------------------------------
                                   1525 ;	dino.c:277: void FrameDelay(void)
                                   1526 ;	-----------------------------------------
                                   1527 ;	 function FrameDelay
                                   1528 ;	-----------------------------------------
      000729                       1529 _FrameDelay:
                                   1530 ;	dino.c:281: rounds = 18 - difficultyDigit;
      000729 AF 32            [24] 1531 	mov	r7,_difficultyDigit
      00072B 74 12            [12] 1532 	mov	a,#0x12
      00072D C3               [12] 1533 	clr	c
      00072E 9F               [12] 1534 	subb	a,r7
      00072F FF               [12] 1535 	mov	r7,a
                                   1536 ;	dino.c:282: while (rounds > 0) {
      000730                       1537 00101$:
      000730 EF               [12] 1538 	mov	a,r7
      000731 60 0D            [24] 1539 	jz	00104$
                                   1540 ;	dino.c:283: SmallDelay(255);
      000733 75 82 FF         [24] 1541 	mov	dpl, #0xff
      000736 C0 07            [24] 1542 	push	ar7
      000738 12 07 25         [24] 1543 	lcall	_SmallDelay
      00073B D0 07            [24] 1544 	pop	ar7
                                   1545 ;	dino.c:284: rounds--;
      00073D 1F               [12] 1546 	dec	r7
      00073E 80 F0            [24] 1547 	sjmp	00101$
      000740                       1548 00104$:
                                   1549 ;	dino.c:286: }
      000740 22               [24] 1550 	ret
                                   1551 ;------------------------------------------------------------
                                   1552 ;Allocation info for local variables in function 'MoveDinoFromKey'
                                   1553 ;------------------------------------------------------------
                                   1554 ;c             Allocated to registers r7 
                                   1555 ;------------------------------------------------------------
                                   1556 ;	dino.c:288: void MoveDinoFromKey(char c)
                                   1557 ;	-----------------------------------------
                                   1558 ;	 function MoveDinoFromKey
                                   1559 ;	-----------------------------------------
      000741                       1560 _MoveDinoFromKey:
      000741 AF 82            [24] 1561 	mov	r7, dpl
                                   1562 ;	dino.c:290: if (c == '2') {
      000743 BF 32 04         [24] 1563 	cjne	r7,#0x32,00104$
                                   1564 ;	dino.c:291: dinoRow = 0;
      000746 75 2A 00         [24] 1565 	mov	_dinoRow,#0x00
      000749 22               [24] 1566 	ret
      00074A                       1567 00104$:
                                   1568 ;	dino.c:292: } else if (c == '8') {
      00074A BF 38 03         [24] 1569 	cjne	r7,#0x38,00106$
                                   1570 ;	dino.c:293: dinoRow = 1;
      00074D 75 2A 01         [24] 1571 	mov	_dinoRow,#0x01
      000750                       1572 00106$:
                                   1573 ;	dino.c:295: }
      000750 22               [24] 1574 	ret
                                   1575 ;------------------------------------------------------------
                                   1576 ;Allocation info for local variables in function 'MaybeAddCactus'
                                   1577 ;------------------------------------------------------------
                                   1578 ;	dino.c:297: void MaybeAddCactus(void)
                                   1579 ;	-----------------------------------------
                                   1580 ;	 function MaybeAddCactus
                                   1581 ;	-----------------------------------------
      000751                       1582 _MaybeAddCactus:
                                   1583 ;	dino.c:299: if (cactusGap < 4) {
      000751 74 FC            [12] 1584 	mov	a,#0x100 - 0x04
      000753 25 3E            [12] 1585 	add	a,_cactusGap
      000755 40 06            [24] 1586 	jc	00102$
                                   1587 ;	dino.c:300: cactusGap++;
      000757 E5 3E            [12] 1588 	mov	a,_cactusGap
      000759 04               [12] 1589 	inc	a
      00075A F5 3E            [12] 1590 	mov	_cactusGap,a
                                   1591 ;	dino.c:301: return;
      00075C 22               [24] 1592 	ret
      00075D                       1593 00102$:
                                   1594 ;	dino.c:304: if (((cactusRow0 | cactusRow1) & 0xC000) != 0) {
      00075D E5 2E            [12] 1595 	mov	a,_cactusRow1
      00075F 45 2C            [12] 1596 	orl	a,_cactusRow0
      000761 E5 2F            [12] 1597 	mov	a,(_cactusRow1 + 1)
      000763 45 2D            [12] 1598 	orl	a,(_cactusRow0 + 1)
      000765 54 C0            [12] 1599 	anl	a,#0xc0
      000767 60 01            [24] 1600 	jz	00104$
                                   1601 ;	dino.c:305: return;
      000769 22               [24] 1602 	ret
      00076A                       1603 00104$:
                                   1604 ;	dino.c:308: if ((scoreCount + difficultyDigit) & 1) {
      00076A AF 32            [24] 1605 	mov	r7,_difficultyDigit
      00076C 7E 00            [12] 1606 	mov	r6,#0x00
      00076E EF               [12] 1607 	mov	a,r7
      00076F 25 30            [12] 1608 	add	a, _scoreCount
      000771 FF               [12] 1609 	mov	r7,a
      000772 EE               [12] 1610 	mov	a,r6
      000773 35 31            [12] 1611 	addc	a, (_scoreCount + 1)
      000775 EF               [12] 1612 	mov	a,r7
      000776 30 E0 07         [24] 1613 	jnb	acc.0,00106$
                                   1614 ;	dino.c:309: cactusRow0 |= RIGHT_EDGE;
      000779 E5 2C            [12] 1615 	mov	a,_cactusRow0
      00077B 43 2D 80         [24] 1616 	orl	(_cactusRow0 + 1),#0x80
      00077E 80 05            [24] 1617 	sjmp	00107$
      000780                       1618 00106$:
                                   1619 ;	dino.c:311: cactusRow1 |= RIGHT_EDGE;
      000780 E5 2E            [12] 1620 	mov	a,_cactusRow1
      000782 43 2F 80         [24] 1621 	orl	(_cactusRow1 + 1),#0x80
      000785                       1622 00107$:
                                   1623 ;	dino.c:313: cactusGap = 0;
      000785 75 3E 00         [24] 1624 	mov	_cactusGap,#0x00
                                   1625 ;	dino.c:314: }
      000788 22               [24] 1626 	ret
                                   1627 ;------------------------------------------------------------
                                   1628 ;Allocation info for local variables in function 'UpdateGameMap'
                                   1629 ;------------------------------------------------------------
                                   1630 ;	dino.c:316: void UpdateGameMap(void)
                                   1631 ;	-----------------------------------------
                                   1632 ;	 function UpdateGameMap
                                   1633 ;	-----------------------------------------
      000789                       1634 _UpdateGameMap:
                                   1635 ;	dino.c:318: if ((dinoRow == 0) && (cactusRow0 & LEFT_EDGE)) {
      000789 E5 2A            [12] 1636 	mov	a,_dinoRow
      00078B 70 09            [24] 1637 	jnz	00102$
      00078D E5 2C            [12] 1638 	mov	a,_cactusRow0
      00078F 30 E0 04         [24] 1639 	jnb	acc.0,00102$
                                   1640 ;	dino.c:319: playMode = 0;
      000792 75 2B 00         [24] 1641 	mov	_playMode,#0x00
                                   1642 ;	dino.c:320: return;
      000795 22               [24] 1643 	ret
      000796                       1644 00102$:
                                   1645 ;	dino.c:322: if ((dinoRow == 1) && (cactusRow1 & LEFT_EDGE)) {
      000796 74 01            [12] 1646 	mov	a,#0x01
      000798 B5 2A 09         [24] 1647 	cjne	a,_dinoRow,00105$
      00079B E5 2E            [12] 1648 	mov	a,_cactusRow1
      00079D 30 E0 04         [24] 1649 	jnb	acc.0,00105$
                                   1650 ;	dino.c:323: playMode = 0;
      0007A0 75 2B 00         [24] 1651 	mov	_playMode,#0x00
                                   1652 ;	dino.c:324: return;
      0007A3 22               [24] 1653 	ret
      0007A4                       1654 00105$:
                                   1655 ;	dino.c:327: if ((cactusRow0 | cactusRow1) & LEFT_EDGE) {
      0007A4 E5 2E            [12] 1656 	mov	a,_cactusRow1
      0007A6 45 2C            [12] 1657 	orl	a,_cactusRow0
      0007A8 FE               [12] 1658 	mov	r6,a
      0007A9 E5 2F            [12] 1659 	mov	a,(_cactusRow1 + 1)
      0007AB 45 2D            [12] 1660 	orl	a,(_cactusRow0 + 1)
      0007AD EE               [12] 1661 	mov	a,r6
      0007AE 30 E0 0D         [24] 1662 	jnb	acc.0,00108$
                                   1663 ;	dino.c:328: scoreCount++;
      0007B1 AE 30            [24] 1664 	mov	r6,_scoreCount
      0007B3 AF 31            [24] 1665 	mov	r7,(_scoreCount + 1)
      0007B5 74 01            [12] 1666 	mov	a,#0x01
      0007B7 2E               [12] 1667 	add	a, r6
      0007B8 F5 30            [12] 1668 	mov	_scoreCount,a
      0007BA E4               [12] 1669 	clr	a
      0007BB 3F               [12] 1670 	addc	a, r7
      0007BC F5 31            [12] 1671 	mov	(_scoreCount + 1),a
      0007BE                       1672 00108$:
                                   1673 ;	dino.c:331: cactusRow0 = cactusRow0 >> 1;
      0007BE E5 2D            [12] 1674 	mov	a,(_cactusRow0 + 1)
      0007C0 C3               [12] 1675 	clr	c
      0007C1 13               [12] 1676 	rrc	a
      0007C2 C5 2C            [12] 1677 	xch	a,_cactusRow0
      0007C4 13               [12] 1678 	rrc	a
      0007C5 C5 2C            [12] 1679 	xch	a,_cactusRow0
      0007C7 F5 2D            [12] 1680 	mov	(_cactusRow0 + 1),a
                                   1681 ;	dino.c:332: cactusRow1 = cactusRow1 >> 1;
      0007C9 E5 2F            [12] 1682 	mov	a,(_cactusRow1 + 1)
      0007CB C3               [12] 1683 	clr	c
      0007CC 13               [12] 1684 	rrc	a
      0007CD C5 2E            [12] 1685 	xch	a,_cactusRow1
      0007CF 13               [12] 1686 	rrc	a
      0007D0 C5 2E            [12] 1687 	xch	a,_cactusRow1
      0007D2 F5 2F            [12] 1688 	mov	(_cactusRow1 + 1),a
                                   1689 ;	dino.c:333: MaybeAddCactus();
                                   1690 ;	dino.c:334: }
      0007D4 02 07 51         [24] 1691 	ljmp	_MaybeAddCactus
                                   1692 ;------------------------------------------------------------
                                   1693 ;Allocation info for local variables in function 'GameCtrlTask'
                                   1694 ;------------------------------------------------------------
                                   1695 ;c             Allocated to registers r7 
                                   1696 ;------------------------------------------------------------
                                   1697 ;	dino.c:336: void GameCtrlTask(void)
                                   1698 ;	-----------------------------------------
                                   1699 ;	 function GameCtrlTask
                                   1700 ;	-----------------------------------------
      0007D7                       1701 _GameCtrlTask:
                                   1702 ;	dino.c:340: difficultyDigit = 0;
      0007D7 75 32 00         [24] 1703 	mov	_difficultyDigit,#0x00
                                   1704 ;	dino.c:341: playMode = 2;
      0007DA 75 2B 02         [24] 1705 	mov	_playMode,#0x02
                                   1706 ;	dino.c:343: while (1) {
      0007DD                       1707 00108$:
                                   1708 ;	dino.c:344: c = TakeKeyBlocking();
      0007DD 12 00 D4         [24] 1709 	lcall	_TakeKeyBlocking
      0007E0 AF 82            [24] 1710 	mov	r7, dpl
                                   1711 ;	dino.c:345: if ((c >= '0') && (c <= '9')) {
      0007E2 BF 30 00         [24] 1712 	cjne	r7,#0x30,00225$
      0007E5                       1713 00225$:
      0007E5 40 0E            [24] 1714 	jc	00104$
      0007E7 EF               [12] 1715 	mov	a,r7
      0007E8 24 C6            [12] 1716 	add	a,#0xff - 0x39
      0007EA 40 09            [24] 1717 	jc	00104$
                                   1718 ;	dino.c:346: difficultyDigit = c - '0';
      0007EC 8F 06            [24] 1719 	mov	ar6,r7
      0007EE EE               [12] 1720 	mov	a,r6
      0007EF 24 D0            [12] 1721 	add	a,#0xd0
      0007F1 F5 32            [12] 1722 	mov	_difficultyDigit,a
      0007F3 80 E8            [24] 1723 	sjmp	00108$
      0007F5                       1724 00104$:
                                   1725 ;	dino.c:347: } else if (c == '#') {
      0007F5 BF 23 E5         [24] 1726 	cjne	r7,#0x23,00108$
                                   1727 ;	dino.c:352: SemaphoreWait(sceneGate);
      0007F8                       1728 00113$:
                                   1729 ;	assignBit
      0007F8 C2 AF            [12] 1730 	clr	_EA
      0007FA E5 29            [12] 1731 	mov	a,_sceneGate
      0007FC 60 06            [24] 1732 	jz	00111$
      0007FE 15 29            [12] 1733 	dec	_sceneGate
                                   1734 ;	assignBit
      000800 D2 AF            [12] 1735 	setb	_EA
      000802 80 04            [24] 1736 	sjmp	00116$
      000804                       1737 00111$:
                                   1738 ;	assignBit
      000804 D2 AF            [12] 1739 	setb	_EA
      000806 80 F0            [24] 1740 	sjmp	00113$
      000808                       1741 00116$:
                                   1742 ;	dino.c:353: dinoRow = 1;
      000808 75 2A 01         [24] 1743 	mov	_dinoRow,#0x01
                                   1744 ;	dino.c:354: cactusRow0 = 0;
      00080B E4               [12] 1745 	clr	a
      00080C F5 2C            [12] 1746 	mov	_cactusRow0,a
      00080E F5 2D            [12] 1747 	mov	(_cactusRow0 + 1),a
                                   1748 ;	dino.c:355: cactusRow1 = 0;
      000810 F5 2E            [12] 1749 	mov	_cactusRow1,a
      000812 F5 2F            [12] 1750 	mov	(_cactusRow1 + 1),a
                                   1751 ;	dino.c:356: scoreCount = 0;
      000814 F5 30            [12] 1752 	mov	_scoreCount,a
      000816 F5 31            [12] 1753 	mov	(_scoreCount + 1),a
                                   1754 ;	dino.c:357: cactusGap = 4;
      000818 75 3E 04         [24] 1755 	mov	_cactusGap,#0x04
                                   1756 ;	dino.c:358: playMode = 1;
      00081B 75 2B 01         [24] 1757 	mov	_playMode,#0x01
                                   1758 ;	dino.c:359: SemaphoreSignal(sceneGate);
                                   1759 ;	assignBit
      00081E C2 AF            [12] 1760 	clr	_EA
      000820 05 29            [12] 1761 	inc	_sceneGate
                                   1762 ;	assignBit
      000822 D2 AF            [12] 1763 	setb	_EA
                                   1764 ;	dino.c:361: while (playMode == 1) {
      000824                       1765 00132$:
      000824 74 01            [12] 1766 	mov	a,#0x01
      000826 B5 2B 28         [24] 1767 	cjne	a,_playMode,00138$
                                   1768 ;	dino.c:362: c = TakeKeyIfReady();
      000829 12 01 17         [24] 1769 	lcall	_TakeKeyIfReady
      00082C AF 82            [24] 1770 	mov	r7, dpl
                                   1771 ;	dino.c:363: SemaphoreWait(sceneGate);
      00082E                       1772 00124$:
                                   1773 ;	assignBit
      00082E C2 AF            [12] 1774 	clr	_EA
      000830 E5 29            [12] 1775 	mov	a,_sceneGate
      000832 60 06            [24] 1776 	jz	00122$
      000834 15 29            [12] 1777 	dec	_sceneGate
                                   1778 ;	assignBit
      000836 D2 AF            [12] 1779 	setb	_EA
      000838 80 04            [24] 1780 	sjmp	00127$
      00083A                       1781 00122$:
                                   1782 ;	assignBit
      00083A D2 AF            [12] 1783 	setb	_EA
      00083C 80 F0            [24] 1784 	sjmp	00124$
      00083E                       1785 00127$:
                                   1786 ;	dino.c:364: MoveDinoFromKey(c);
      00083E 8F 82            [24] 1787 	mov	dpl, r7
      000840 12 07 41         [24] 1788 	lcall	_MoveDinoFromKey
                                   1789 ;	dino.c:365: UpdateGameMap();
      000843 12 07 89         [24] 1790 	lcall	_UpdateGameMap
                                   1791 ;	dino.c:366: SemaphoreSignal(sceneGate);
                                   1792 ;	assignBit
      000846 C2 AF            [12] 1793 	clr	_EA
      000848 05 29            [12] 1794 	inc	_sceneGate
                                   1795 ;	assignBit
      00084A D2 AF            [12] 1796 	setb	_EA
                                   1797 ;	dino.c:367: FrameDelay();
      00084C 12 07 29         [24] 1798 	lcall	_FrameDelay
                                   1799 ;	dino.c:370: SemaphoreWait(sceneGate);
      00084F 80 D3            [24] 1800 	sjmp	00132$
      000851                       1801 00138$:
                                   1802 ;	assignBit
      000851 C2 AF            [12] 1803 	clr	_EA
      000853 E5 29            [12] 1804 	mov	a,_sceneGate
      000855 60 06            [24] 1805 	jz	00136$
      000857 15 29            [12] 1806 	dec	_sceneGate
                                   1807 ;	assignBit
      000859 D2 AF            [12] 1808 	setb	_EA
      00085B 80 04            [24] 1809 	sjmp	00141$
      00085D                       1810 00136$:
                                   1811 ;	assignBit
      00085D D2 AF            [12] 1812 	setb	_EA
      00085F 80 F0            [24] 1813 	sjmp	00138$
      000861                       1814 00141$:
                                   1815 ;	dino.c:371: LCD_clearScreen();
      000861 75 82 01         [24] 1816 	mov	dpl, #0x01
      000864 12 0A 6E         [24] 1817 	lcall	_LCD_IRWrite
                                   1818 ;	dino.c:372: WriteGameOverText();
      000867 12 02 47         [24] 1819 	lcall	_WriteGameOverText
                                   1820 ;	dino.c:373: LCDWriteUint(scoreCount);
      00086A 85 30 82         [24] 1821 	mov	dpl, _scoreCount
      00086D 85 31 83         [24] 1822 	mov	dph, (_scoreCount + 1)
      000870 12 02 DD         [24] 1823 	lcall	_LCDWriteUint
                                   1824 ;	dino.c:374: SemaphoreSignal(sceneGate);
                                   1825 ;	assignBit
      000873 C2 AF            [12] 1826 	clr	_EA
      000875 05 29            [12] 1827 	inc	_sceneGate
                                   1828 ;	assignBit
      000877 D2 AF            [12] 1829 	setb	_EA
                                   1830 ;	dino.c:375: }
      000879 22               [24] 1831 	ret
                                   1832 ;------------------------------------------------------------
                                   1833 ;Allocation info for local variables in function 'main'
                                   1834 ;------------------------------------------------------------
                                   1835 ;	dino.c:377: void main(void)
                                   1836 ;	-----------------------------------------
                                   1837 ;	 function main
                                   1838 ;	-----------------------------------------
      00087A                       1839 _main:
                                   1840 ;	dino.c:379: keyTakeAt = 0;
      00087A 75 26 00         [24] 1841 	mov	_keyTakeAt,#0x00
                                   1842 ;	dino.c:380: keyPutAt = 0;
      00087D 75 27 00         [24] 1843 	mov	_keyPutAt,#0x00
                                   1844 ;	dino.c:381: keyQueue[0] = 0;
      000880 75 23 00         [24] 1845 	mov	_keyQueue,#0x00
                                   1846 ;	dino.c:382: keyQueue[1] = 0;
      000883 75 24 00         [24] 1847 	mov	(_keyQueue + 0x0001),#0x00
                                   1848 ;	dino.c:383: keyQueue[2] = 0;
      000886 75 25 00         [24] 1849 	mov	(_keyQueue + 0x0002),#0x00
                                   1850 ;	dino.c:384: keyStillDown = 0;
      000889 75 28 00         [24] 1851 	mov	_keyStillDown,#0x00
                                   1852 ;	dino.c:386: dinoRow = 1;
      00088C 75 2A 01         [24] 1853 	mov	_dinoRow,#0x01
                                   1854 ;	dino.c:387: playMode = 2;
      00088F 75 2B 02         [24] 1855 	mov	_playMode,#0x02
                                   1856 ;	dino.c:388: cactusRow0 = 0;
      000892 E4               [12] 1857 	clr	a
      000893 F5 2C            [12] 1858 	mov	_cactusRow0,a
      000895 F5 2D            [12] 1859 	mov	(_cactusRow0 + 1),a
                                   1860 ;	dino.c:389: cactusRow1 = 0;
      000897 F5 2E            [12] 1861 	mov	_cactusRow1,a
      000899 F5 2F            [12] 1862 	mov	(_cactusRow1 + 1),a
                                   1863 ;	dino.c:390: scoreCount = 0;
      00089B F5 30            [12] 1864 	mov	_scoreCount,a
      00089D F5 31            [12] 1865 	mov	(_scoreCount + 1),a
                                   1866 ;	dino.c:391: difficultyDigit = 0;
      00089F F5 32            [12] 1867 	mov	_difficultyDigit,a
                                   1868 ;	dino.c:392: cactusGap = 0;
      0008A1 F5 3E            [12] 1869 	mov	_cactusGap,a
                                   1870 ;	dino.c:394: SemaphoreCreate(keyGate, 1);
      0008A3 75 20 01         [24] 1871 	mov	_keyGate,#0x01
                                   1872 ;	dino.c:395: SemaphoreCreate(keyUsed, 0);
      0008A6 F5 21            [12] 1873 	mov	_keyUsed,a
                                   1874 ;	dino.c:396: SemaphoreCreate(keyRoom, 3);
      0008A8 75 22 03         [24] 1875 	mov	_keyRoom,#0x03
                                   1876 ;	dino.c:397: SemaphoreCreate(sceneGate, 1);
      0008AB 75 29 01         [24] 1877 	mov	_sceneGate,#0x01
                                   1878 ;	dino.c:399: Init_Keypad();
      0008AE 12 0B 31         [24] 1879 	lcall	_Init_Keypad
                                   1880 ;	dino.c:401: ThreadCreate(KeypadCtrlTask);
      0008B1 90 01 5D         [24] 1881 	mov	dptr,#_KeypadCtrlTask
      0008B4 12 08 FA         [24] 1882 	lcall	_ThreadCreate
                                   1883 ;	dino.c:402: ThreadCreate(RenderTask);
      0008B7 90 06 BE         [24] 1884 	mov	dptr,#_RenderTask
      0008BA 12 08 FA         [24] 1885 	lcall	_ThreadCreate
                                   1886 ;	dino.c:403: GameCtrlTask();
      0008BD 12 07 D7         [24] 1887 	lcall	_GameCtrlTask
                                   1888 ;	dino.c:404: ThreadExit();
                                   1889 ;	dino.c:405: }
      0008C0 02 09 C7         [24] 1890 	ljmp	_ThreadExit
                                   1891 ;------------------------------------------------------------
                                   1892 ;Allocation info for local variables in function '_sdcc_gsinit_startup'
                                   1893 ;------------------------------------------------------------
                                   1894 ;	dino.c:407: void _sdcc_gsinit_startup(void)
                                   1895 ;	-----------------------------------------
                                   1896 ;	 function _sdcc_gsinit_startup
                                   1897 ;	-----------------------------------------
      0008C3                       1898 __sdcc_gsinit_startup:
                                   1899 ;	dino.c:411: __endasm;
      0008C3 02 08 D0         [24] 1900 	LJMP	_Bootstrap
                                   1901 ;	dino.c:412: }
      0008C6 22               [24] 1902 	ret
                                   1903 ;------------------------------------------------------------
                                   1904 ;Allocation info for local variables in function '_mcs51_genRAMCLEAR'
                                   1905 ;------------------------------------------------------------
                                   1906 ;	dino.c:414: void _mcs51_genRAMCLEAR(void) { }
                                   1907 ;	-----------------------------------------
                                   1908 ;	 function _mcs51_genRAMCLEAR
                                   1909 ;	-----------------------------------------
      0008C7                       1910 __mcs51_genRAMCLEAR:
      0008C7 22               [24] 1911 	ret
                                   1912 ;------------------------------------------------------------
                                   1913 ;Allocation info for local variables in function '_mcs51_genXINIT'
                                   1914 ;------------------------------------------------------------
                                   1915 ;	dino.c:415: void _mcs51_genXINIT(void) { }
                                   1916 ;	-----------------------------------------
                                   1917 ;	 function _mcs51_genXINIT
                                   1918 ;	-----------------------------------------
      0008C8                       1919 __mcs51_genXINIT:
      0008C8 22               [24] 1920 	ret
                                   1921 ;------------------------------------------------------------
                                   1922 ;Allocation info for local variables in function '_mcs51_genXRAMCLEAR'
                                   1923 ;------------------------------------------------------------
                                   1924 ;	dino.c:416: void _mcs51_genXRAMCLEAR(void) { }
                                   1925 ;	-----------------------------------------
                                   1926 ;	 function _mcs51_genXRAMCLEAR
                                   1927 ;	-----------------------------------------
      0008C9                       1928 __mcs51_genXRAMCLEAR:
      0008C9 22               [24] 1929 	ret
                                   1930 ;------------------------------------------------------------
                                   1931 ;Allocation info for local variables in function 'timer0_ISR'
                                   1932 ;------------------------------------------------------------
                                   1933 ;	dino.c:418: void timer0_ISR(void) __interrupt(1)
                                   1934 ;	-----------------------------------------
                                   1935 ;	 function timer0_ISR
                                   1936 ;	-----------------------------------------
      0008CA                       1937 _timer0_ISR:
                                   1938 ;	dino.c:422: __endasm;
      0008CA 02 0A 0D         [24] 1939 	LJMP	_myTimer0Handler
                                   1940 ;	dino.c:423: }
      0008CD 02 00 54         [24] 1941 	ljmp	sdcc_atomic_maybe_rollback
                                   1942 ;	eliminated unneeded mov psw,# (no regs used in bank)
                                   1943 ;	eliminated unneeded push/pop not_psw
                                   1944 ;	eliminated unneeded push/pop dpl
                                   1945 ;	eliminated unneeded push/pop dph
                                   1946 ;	eliminated unneeded push/pop b
                                   1947 ;	eliminated unneeded push/pop acc
                                   1948 	.area CSEG    (CODE)
                                   1949 	.area CONST   (CODE)
                                   1950 	.area XINIT   (CODE)
                                   1951 	.area CABS    (ABS,CODE)
