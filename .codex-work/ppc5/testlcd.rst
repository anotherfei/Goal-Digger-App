                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ISO C Compiler
                                      3 ; Version 4.5.0 #15242 (MINGW64)
                                      4 ;--------------------------------------------------------
                                      5 	.module testlcd
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
                                     17 	.globl _LcdDrainTask
                                     18 	.globl _KeyPipeTask
                                     19 	.globl _ButtonPipeTask
                                     20 	.globl _PushInputChar
                                     21 	.globl _LCD_ready
                                     22 	.globl _LCD_write_char
                                     23 	.globl _LCD_IRWrite
                                     24 	.globl _LCD_Init
                                     25 	.globl _AnyKeyPressed
                                     26 	.globl _KeyToChar
                                     27 	.globl _Init_Keypad
                                     28 	.globl _ButtonToChar
                                     29 	.globl _AnyButtonPressed
                                     30 	.globl _ThreadCreate
                                     31 	.globl _CY
                                     32 	.globl _AC
                                     33 	.globl _F0
                                     34 	.globl _RS1
                                     35 	.globl _RS0
                                     36 	.globl _OV
                                     37 	.globl _F1
                                     38 	.globl _P
                                     39 	.globl _PS
                                     40 	.globl _PT1
                                     41 	.globl _PX1
                                     42 	.globl _PT0
                                     43 	.globl _PX0
                                     44 	.globl _RD
                                     45 	.globl _WR
                                     46 	.globl _T1
                                     47 	.globl _T0
                                     48 	.globl _INT1
                                     49 	.globl _INT0
                                     50 	.globl _TXD
                                     51 	.globl _RXD
                                     52 	.globl _P3_7
                                     53 	.globl _P3_6
                                     54 	.globl _P3_5
                                     55 	.globl _P3_4
                                     56 	.globl _P3_3
                                     57 	.globl _P3_2
                                     58 	.globl _P3_1
                                     59 	.globl _P3_0
                                     60 	.globl _EA
                                     61 	.globl _ES
                                     62 	.globl _ET1
                                     63 	.globl _EX1
                                     64 	.globl _ET0
                                     65 	.globl _EX0
                                     66 	.globl _P2_7
                                     67 	.globl _P2_6
                                     68 	.globl _P2_5
                                     69 	.globl _P2_4
                                     70 	.globl _P2_3
                                     71 	.globl _P2_2
                                     72 	.globl _P2_1
                                     73 	.globl _P2_0
                                     74 	.globl _SM0
                                     75 	.globl _SM1
                                     76 	.globl _SM2
                                     77 	.globl _REN
                                     78 	.globl _TB8
                                     79 	.globl _RB8
                                     80 	.globl _TI
                                     81 	.globl _RI
                                     82 	.globl _P1_7
                                     83 	.globl _P1_6
                                     84 	.globl _P1_5
                                     85 	.globl _P1_4
                                     86 	.globl _P1_3
                                     87 	.globl _P1_2
                                     88 	.globl _P1_1
                                     89 	.globl _P1_0
                                     90 	.globl _TF1
                                     91 	.globl _TR1
                                     92 	.globl _TF0
                                     93 	.globl _TR0
                                     94 	.globl _IE1
                                     95 	.globl _IT1
                                     96 	.globl _IE0
                                     97 	.globl _IT0
                                     98 	.globl _P0_7
                                     99 	.globl _P0_6
                                    100 	.globl _P0_5
                                    101 	.globl _P0_4
                                    102 	.globl _P0_3
                                    103 	.globl _P0_2
                                    104 	.globl _P0_1
                                    105 	.globl _P0_0
                                    106 	.globl _B
                                    107 	.globl _ACC
                                    108 	.globl _PSW
                                    109 	.globl _IP
                                    110 	.globl _P3
                                    111 	.globl _IE
                                    112 	.globl _P2
                                    113 	.globl _SBUF
                                    114 	.globl _SCON
                                    115 	.globl _P1
                                    116 	.globl _TH1
                                    117 	.globl _TH0
                                    118 	.globl _TL1
                                    119 	.globl _TL0
                                    120 	.globl _TMOD
                                    121 	.globl _TCON
                                    122 	.globl _PCON
                                    123 	.globl _DPH
                                    124 	.globl _DPL
                                    125 	.globl _SP
                                    126 	.globl _P0
                                    127 	.globl _lcdCharOut
                                    128 	.globl _keypadPick
                                    129 	.globl _buttonPick
                                    130 	.globl _keypadWasDown
                                    131 	.globl _buttonWasDown
                                    132 	.globl _queueWriteAt
                                    133 	.globl _queueReadAt
                                    134 	.globl _inputQueue
                                    135 	.globl _openCells
                                    136 	.globl _usedCells
                                    137 	.globl _queueGate
                                    138 ;--------------------------------------------------------
                                    139 ; special function registers
                                    140 ;--------------------------------------------------------
                                    141 	.area RSEG    (ABS,DATA)
      000000                        142 	.org 0x0000
                           000080   143 _P0	=	0x0080
                           000081   144 _SP	=	0x0081
                           000082   145 _DPL	=	0x0082
                           000083   146 _DPH	=	0x0083
                           000087   147 _PCON	=	0x0087
                           000088   148 _TCON	=	0x0088
                           000089   149 _TMOD	=	0x0089
                           00008A   150 _TL0	=	0x008a
                           00008B   151 _TL1	=	0x008b
                           00008C   152 _TH0	=	0x008c
                           00008D   153 _TH1	=	0x008d
                           000090   154 _P1	=	0x0090
                           000098   155 _SCON	=	0x0098
                           000099   156 _SBUF	=	0x0099
                           0000A0   157 _P2	=	0x00a0
                           0000A8   158 _IE	=	0x00a8
                           0000B0   159 _P3	=	0x00b0
                           0000B8   160 _IP	=	0x00b8
                           0000D0   161 _PSW	=	0x00d0
                           0000E0   162 _ACC	=	0x00e0
                           0000F0   163 _B	=	0x00f0
                                    164 ;--------------------------------------------------------
                                    165 ; special function bits
                                    166 ;--------------------------------------------------------
                                    167 	.area RSEG    (ABS,DATA)
      000000                        168 	.org 0x0000
                           000080   169 _P0_0	=	0x0080
                           000081   170 _P0_1	=	0x0081
                           000082   171 _P0_2	=	0x0082
                           000083   172 _P0_3	=	0x0083
                           000084   173 _P0_4	=	0x0084
                           000085   174 _P0_5	=	0x0085
                           000086   175 _P0_6	=	0x0086
                           000087   176 _P0_7	=	0x0087
                           000088   177 _IT0	=	0x0088
                           000089   178 _IE0	=	0x0089
                           00008A   179 _IT1	=	0x008a
                           00008B   180 _IE1	=	0x008b
                           00008C   181 _TR0	=	0x008c
                           00008D   182 _TF0	=	0x008d
                           00008E   183 _TR1	=	0x008e
                           00008F   184 _TF1	=	0x008f
                           000090   185 _P1_0	=	0x0090
                           000091   186 _P1_1	=	0x0091
                           000092   187 _P1_2	=	0x0092
                           000093   188 _P1_3	=	0x0093
                           000094   189 _P1_4	=	0x0094
                           000095   190 _P1_5	=	0x0095
                           000096   191 _P1_6	=	0x0096
                           000097   192 _P1_7	=	0x0097
                           000098   193 _RI	=	0x0098
                           000099   194 _TI	=	0x0099
                           00009A   195 _RB8	=	0x009a
                           00009B   196 _TB8	=	0x009b
                           00009C   197 _REN	=	0x009c
                           00009D   198 _SM2	=	0x009d
                           00009E   199 _SM1	=	0x009e
                           00009F   200 _SM0	=	0x009f
                           0000A0   201 _P2_0	=	0x00a0
                           0000A1   202 _P2_1	=	0x00a1
                           0000A2   203 _P2_2	=	0x00a2
                           0000A3   204 _P2_3	=	0x00a3
                           0000A4   205 _P2_4	=	0x00a4
                           0000A5   206 _P2_5	=	0x00a5
                           0000A6   207 _P2_6	=	0x00a6
                           0000A7   208 _P2_7	=	0x00a7
                           0000A8   209 _EX0	=	0x00a8
                           0000A9   210 _ET0	=	0x00a9
                           0000AA   211 _EX1	=	0x00aa
                           0000AB   212 _ET1	=	0x00ab
                           0000AC   213 _ES	=	0x00ac
                           0000AF   214 _EA	=	0x00af
                           0000B0   215 _P3_0	=	0x00b0
                           0000B1   216 _P3_1	=	0x00b1
                           0000B2   217 _P3_2	=	0x00b2
                           0000B3   218 _P3_3	=	0x00b3
                           0000B4   219 _P3_4	=	0x00b4
                           0000B5   220 _P3_5	=	0x00b5
                           0000B6   221 _P3_6	=	0x00b6
                           0000B7   222 _P3_7	=	0x00b7
                           0000B0   223 _RXD	=	0x00b0
                           0000B1   224 _TXD	=	0x00b1
                           0000B2   225 _INT0	=	0x00b2
                           0000B3   226 _INT1	=	0x00b3
                           0000B4   227 _T0	=	0x00b4
                           0000B5   228 _T1	=	0x00b5
                           0000B6   229 _WR	=	0x00b6
                           0000B7   230 _RD	=	0x00b7
                           0000B8   231 _PX0	=	0x00b8
                           0000B9   232 _PT0	=	0x00b9
                           0000BA   233 _PX1	=	0x00ba
                           0000BB   234 _PT1	=	0x00bb
                           0000BC   235 _PS	=	0x00bc
                           0000D0   236 _P	=	0x00d0
                           0000D1   237 _F1	=	0x00d1
                           0000D2   238 _OV	=	0x00d2
                           0000D3   239 _RS0	=	0x00d3
                           0000D4   240 _RS1	=	0x00d4
                           0000D5   241 _F0	=	0x00d5
                           0000D6   242 _AC	=	0x00d6
                           0000D7   243 _CY	=	0x00d7
                                    244 ;--------------------------------------------------------
                                    245 ; overlayable register banks
                                    246 ;--------------------------------------------------------
                                    247 	.area REG_BANK_0	(REL,OVR,DATA)
      000000                        248 	.ds 8
                                    249 ;--------------------------------------------------------
                                    250 ; internal ram data
                                    251 ;--------------------------------------------------------
                                    252 	.area DSEG    (DATA)
                           000020   253 _queueGate	=	0x0020
                           000021   254 _usedCells	=	0x0021
                           000022   255 _openCells	=	0x0022
                           000023   256 _inputQueue	=	0x0023
                           000026   257 _queueReadAt	=	0x0026
                           000027   258 _queueWriteAt	=	0x0027
                           000028   259 _buttonWasDown	=	0x0028
                           000029   260 _keypadWasDown	=	0x0029
                           00002A   261 _buttonPick	=	0x002a
                           00002B   262 _keypadPick	=	0x002b
                           00002C   263 _lcdCharOut	=	0x002c
                                    264 ;--------------------------------------------------------
                                    265 ; overlayable items in internal ram
                                    266 ;--------------------------------------------------------
                                    267 	.area	OSEG    (OVR,DATA)
                                    268 ;--------------------------------------------------------
                                    269 ; Stack segment in internal ram
                                    270 ;--------------------------------------------------------
                                    271 	.area SSEG
      000021                        272 __start__stack:
      000021                        273 	.ds	1
                                    274 
                                    275 ;--------------------------------------------------------
                                    276 ; indirectly addressable internal ram data
                                    277 ;--------------------------------------------------------
                                    278 	.area ISEG    (DATA)
                                    279 ;--------------------------------------------------------
                                    280 ; absolute internal ram data
                                    281 ;--------------------------------------------------------
                                    282 	.area IABS    (ABS,DATA)
                                    283 	.area IABS    (ABS,DATA)
                                    284 ;--------------------------------------------------------
                                    285 ; bit data
                                    286 ;--------------------------------------------------------
                                    287 	.area BSEG    (BIT)
                                    288 ;--------------------------------------------------------
                                    289 ; paged external ram data
                                    290 ;--------------------------------------------------------
                                    291 	.area PSEG    (PAG,XDATA)
                                    292 ;--------------------------------------------------------
                                    293 ; uninitialized external ram data
                                    294 ;--------------------------------------------------------
                                    295 	.area XSEG    (XDATA)
                                    296 ;--------------------------------------------------------
                                    297 ; absolute external ram data
                                    298 ;--------------------------------------------------------
                                    299 	.area XABS    (ABS,XDATA)
                                    300 ;--------------------------------------------------------
                                    301 ; initialized external ram data
                                    302 ;--------------------------------------------------------
                                    303 	.area XISEG   (XDATA)
                                    304 	.area HOME    (CODE)
                                    305 	.area GSINIT0 (CODE)
                                    306 	.area GSINIT1 (CODE)
                                    307 	.area GSINIT2 (CODE)
                                    308 	.area GSINIT3 (CODE)
                                    309 	.area GSINIT4 (CODE)
                                    310 	.area GSINIT5 (CODE)
                                    311 	.area GSINIT  (CODE)
                                    312 	.area GSFINAL (CODE)
                                    313 	.area CSEG    (CODE)
                                    314 ;--------------------------------------------------------
                                    315 ; interrupt vector
                                    316 ;--------------------------------------------------------
                                    317 	.area HOME    (CODE)
      000000                        318 __interrupt_vect:
      000000 02 01 AB         [24]  319 	ljmp	__sdcc_gsinit_startup
      000003 32               [24]  320 	reti
      000004                        321 	.ds	7
      00000B 02 01 B2         [24]  322 	ljmp	_timer0_ISR
                                    323 ; restartable atomic support routines
      00000E                        324 	.ds	2
      000010                        325 sdcc_atomic_exchange_rollback_start::
      000010 00               [12]  326 	nop
      000011 00               [12]  327 	nop
      000012                        328 sdcc_atomic_exchange_pdata_impl:
      000012 E2               [24]  329 	movx	a, @r0
      000013 FB               [12]  330 	mov	r3, a
      000014 EA               [12]  331 	mov	a, r2
      000015 F2               [24]  332 	movx	@r0, a
      000016 80 2C            [24]  333 	sjmp	sdcc_atomic_exchange_exit
      000018 00               [12]  334 	nop
      000019 00               [12]  335 	nop
      00001A                        336 sdcc_atomic_exchange_xdata_impl:
      00001A E0               [24]  337 	movx	a, @dptr
      00001B FB               [12]  338 	mov	r3, a
      00001C EA               [12]  339 	mov	a, r2
      00001D F0               [24]  340 	movx	@dptr, a
      00001E 80 24            [24]  341 	sjmp	sdcc_atomic_exchange_exit
      000020                        342 sdcc_atomic_compare_exchange_idata_impl:
      000020 E6               [12]  343 	mov	a, @r0
      000021 B5 02 02         [24]  344 	cjne	a, ar2, .+#5
      000024 EB               [12]  345 	mov	a, r3
      000025 F6               [12]  346 	mov	@r0, a
      000026 22               [24]  347 	ret
      000027 00               [12]  348 	nop
      000028                        349 sdcc_atomic_compare_exchange_pdata_impl:
      000028 E2               [24]  350 	movx	a, @r0
      000029 B5 02 02         [24]  351 	cjne	a, ar2, .+#5
      00002C EB               [12]  352 	mov	a, r3
      00002D F2               [24]  353 	movx	@r0, a
      00002E 22               [24]  354 	ret
      00002F 00               [12]  355 	nop
      000030                        356 sdcc_atomic_compare_exchange_xdata_impl:
      000030 E0               [24]  357 	movx	a, @dptr
      000031 B5 02 02         [24]  358 	cjne	a, ar2, .+#5
      000034 EB               [12]  359 	mov	a, r3
      000035 F0               [24]  360 	movx	@dptr, a
      000036 22               [24]  361 	ret
      000037                        362 sdcc_atomic_exchange_rollback_end::
                                    363 
      000037                        364 sdcc_atomic_exchange_gptr_impl::
      000037 30 F6 E0         [24]  365 	jnb	b.6, sdcc_atomic_exchange_xdata_impl
      00003A A8 82            [24]  366 	mov	r0, dpl
      00003C 20 F5 D3         [24]  367 	jb	b.5, sdcc_atomic_exchange_pdata_impl
      00003F                        368 sdcc_atomic_exchange_idata_impl:
      00003F EA               [12]  369 	mov	a, r2
      000040 C6               [12]  370 	xch	a, @r0
      000041 F5 82            [12]  371 	mov	dpl, a
      000043 22               [24]  372 	ret
      000044                        373 sdcc_atomic_exchange_exit:
      000044 8B 82            [24]  374 	mov	dpl, r3
      000046 22               [24]  375 	ret
      000047                        376 sdcc_atomic_compare_exchange_gptr_impl::
      000047 30 F6 E6         [24]  377 	jnb	b.6, sdcc_atomic_compare_exchange_xdata_impl
      00004A A8 82            [24]  378 	mov	r0, dpl
      00004C 20 F5 D9         [24]  379 	jb	b.5, sdcc_atomic_compare_exchange_pdata_impl
      00004F 80 CF            [24]  380 	sjmp	sdcc_atomic_compare_exchange_idata_impl
                                    381 ;--------------------------------------------------------
                                    382 ; global & static initialisations
                                    383 ;--------------------------------------------------------
                                    384 	.area HOME    (CODE)
                                    385 	.area GSINIT  (CODE)
                                    386 	.area GSFINAL (CODE)
                                    387 	.area GSINIT  (CODE)
                                    388 	.globl __sdcc_gsinit_startup
                                    389 	.globl __sdcc_program_startup
                                    390 	.globl __start__stack
                                    391 	.globl __mcs51_genXINIT
                                    392 	.globl __mcs51_genXRAMCLEAR
                                    393 	.globl __mcs51_genRAMCLEAR
                                    394 	.area GSFINAL (CODE)
      00007E 02 00 51         [24]  395 	ljmp	__sdcc_program_startup
                                    396 ;--------------------------------------------------------
                                    397 ; Home
                                    398 ;--------------------------------------------------------
                                    399 	.area HOME    (CODE)
                                    400 	.area HOME    (CODE)
      000051                        401 __sdcc_program_startup:
      000051 02 01 7B         [24]  402 	ljmp	_main
                                    403 ;	return from main will return to caller
                                    404 ;--------------------------------------------------------
                                    405 ; code
                                    406 ;--------------------------------------------------------
                                    407 	.area CSEG    (CODE)
                                    408 ;------------------------------------------------------------
                                    409 ;Allocation info for local variables in function 'PushInputChar'
                                    410 ;------------------------------------------------------------
                                    411 ;c             Allocated to registers r7 
                                    412 ;------------------------------------------------------------
                                    413 ;	testlcd.c:24: void PushInputChar(char c)
                                    414 ;	-----------------------------------------
                                    415 ;	 function PushInputChar
                                    416 ;	-----------------------------------------
      000081                        417 _PushInputChar:
                           000007   418 	ar7 = 0x07
                           000006   419 	ar6 = 0x06
                           000005   420 	ar5 = 0x05
                           000004   421 	ar4 = 0x04
                           000003   422 	ar3 = 0x03
                           000002   423 	ar2 = 0x02
                           000001   424 	ar1 = 0x01
                           000000   425 	ar0 = 0x00
                                    426 ;	testlcd.c:26: if (c == '\0') {
      000081 E5 82            [12]  427 	mov	a,dpl
      000083 FF               [12]  428 	mov	r7,a
      000084 70 01            [24]  429 	jnz	00106$
                                    430 ;	testlcd.c:27: return;
                                    431 ;	testlcd.c:30: SemaphoreWait(openCells);
      000086 22               [24]  432 	ret
      000087                        433 00106$:
                                    434 ;	assignBit
      000087 C2 AF            [12]  435 	clr	_EA
      000089 E5 22            [12]  436 	mov	a,_openCells
      00008B 60 06            [24]  437 	jz	00104$
      00008D 15 22            [12]  438 	dec	_openCells
                                    439 ;	assignBit
      00008F D2 AF            [12]  440 	setb	_EA
      000091 80 04            [24]  441 	sjmp	00114$
      000093                        442 00104$:
                                    443 ;	assignBit
      000093 D2 AF            [12]  444 	setb	_EA
                                    445 ;	testlcd.c:31: SemaphoreWait(queueGate);
      000095 80 F0            [24]  446 	sjmp	00106$
      000097                        447 00114$:
                                    448 ;	assignBit
      000097 C2 AF            [12]  449 	clr	_EA
      000099 E5 20            [12]  450 	mov	a,_queueGate
      00009B 60 06            [24]  451 	jz	00112$
      00009D 15 20            [12]  452 	dec	_queueGate
                                    453 ;	assignBit
      00009F D2 AF            [12]  454 	setb	_EA
      0000A1 80 04            [24]  455 	sjmp	00117$
      0000A3                        456 00112$:
                                    457 ;	assignBit
      0000A3 D2 AF            [12]  458 	setb	_EA
      0000A5 80 F0            [24]  459 	sjmp	00114$
      0000A7                        460 00117$:
                                    461 ;	testlcd.c:33: if (queueWriteAt == 0) {
      0000A7 E5 27            [12]  462 	mov	a,_queueWriteAt
      0000A9 70 04            [24]  463 	jnz	00123$
                                    464 ;	testlcd.c:34: inputQueue[0] = c;
      0000AB 8F 23            [24]  465 	mov	_inputQueue,r7
      0000AD 80 0B            [24]  466 	sjmp	00124$
      0000AF                        467 00123$:
                                    468 ;	testlcd.c:35: } else if (queueWriteAt == 1) {
      0000AF 74 01            [12]  469 	mov	a,#0x01
      0000B1 B5 27 04         [24]  470 	cjne	a,_queueWriteAt,00120$
                                    471 ;	testlcd.c:36: inputQueue[1] = c;
      0000B4 8F 24            [24]  472 	mov	(_inputQueue + 0x0001),r7
      0000B6 80 02            [24]  473 	sjmp	00124$
      0000B8                        474 00120$:
                                    475 ;	testlcd.c:38: inputQueue[2] = c;
      0000B8 8F 25            [24]  476 	mov	(_inputQueue + 0x0002),r7
      0000BA                        477 00124$:
                                    478 ;	testlcd.c:40: queueWriteAt++;
      0000BA E5 27            [12]  479 	mov	a,_queueWriteAt
      0000BC 04               [12]  480 	inc	a
      0000BD F5 27            [12]  481 	mov	_queueWriteAt,a
                                    482 ;	testlcd.c:41: if (queueWriteAt == 3) {
      0000BF 74 03            [12]  483 	mov	a,#0x03
      0000C1 B5 27 03         [24]  484 	cjne	a,_queueWriteAt,00127$
                                    485 ;	testlcd.c:42: queueWriteAt = 0;
      0000C4 75 27 00         [24]  486 	mov	_queueWriteAt,#0x00
                                    487 ;	testlcd.c:45: SemaphoreSignal(queueGate);
      0000C7                        488 00127$:
                                    489 ;	assignBit
      0000C7 C2 AF            [12]  490 	clr	_EA
      0000C9 05 20            [12]  491 	inc	_queueGate
                                    492 ;	assignBit
      0000CB D2 AF            [12]  493 	setb	_EA
                                    494 ;	testlcd.c:46: SemaphoreSignal(usedCells);
                                    495 ;	assignBit
      0000CD C2 AF            [12]  496 	clr	_EA
      0000CF 05 21            [12]  497 	inc	_usedCells
                                    498 ;	assignBit
      0000D1 D2 AF            [12]  499 	setb	_EA
                                    500 ;	testlcd.c:47: }
      0000D3 22               [24]  501 	ret
                                    502 ;------------------------------------------------------------
                                    503 ;Allocation info for local variables in function 'ButtonPipeTask'
                                    504 ;------------------------------------------------------------
                                    505 ;	testlcd.c:49: void ButtonPipeTask(void)
                                    506 ;	-----------------------------------------
                                    507 ;	 function ButtonPipeTask
                                    508 ;	-----------------------------------------
      0000D4                        509 _ButtonPipeTask:
                                    510 ;	testlcd.c:51: buttonWasDown = 0;
      0000D4 75 28 00         [24]  511 	mov	_buttonWasDown,#0x00
                                    512 ;	testlcd.c:53: while (1) {
      0000D7                        513 00107$:
                                    514 ;	testlcd.c:54: if (AnyButtonPressed()) {
      0000D7 12 04 19         [24]  515 	lcall	_AnyButtonPressed
      0000DA E5 82            [12]  516 	mov	a, dpl
      0000DC 60 15            [24]  517 	jz	00104$
                                    518 ;	testlcd.c:55: if (!buttonWasDown) {
      0000DE E5 28            [12]  519 	mov	a,_buttonWasDown
      0000E0 70 F5            [24]  520 	jnz	00107$
                                    521 ;	testlcd.c:56: buttonPick = ButtonToChar();
      0000E2 12 04 2A         [24]  522 	lcall	_ButtonToChar
      0000E5 85 82 2A         [24]  523 	mov	_buttonPick,dpl
                                    524 ;	testlcd.c:57: PushInputChar(buttonPick);
      0000E8 85 2A 82         [24]  525 	mov	dpl, _buttonPick
      0000EB 12 00 81         [24]  526 	lcall	_PushInputChar
                                    527 ;	testlcd.c:58: buttonWasDown = 1;
      0000EE 75 28 01         [24]  528 	mov	_buttonWasDown,#0x01
      0000F1 80 E4            [24]  529 	sjmp	00107$
      0000F3                        530 00104$:
                                    531 ;	testlcd.c:61: buttonWasDown = 0;
      0000F3 75 28 00         [24]  532 	mov	_buttonWasDown,#0x00
                                    533 ;	testlcd.c:64: }
      0000F6 80 DF            [24]  534 	sjmp	00107$
                                    535 ;------------------------------------------------------------
                                    536 ;Allocation info for local variables in function 'KeyPipeTask'
                                    537 ;------------------------------------------------------------
                                    538 ;	testlcd.c:66: void KeyPipeTask(void)
                                    539 ;	-----------------------------------------
                                    540 ;	 function KeyPipeTask
                                    541 ;	-----------------------------------------
      0000F8                        542 _KeyPipeTask:
                                    543 ;	testlcd.c:68: keypadWasDown = 0;
      0000F8 75 29 00         [24]  544 	mov	_keypadWasDown,#0x00
                                    545 ;	testlcd.c:70: while (1) {
      0000FB                        546 00107$:
                                    547 ;	testlcd.c:71: if (AnyKeyPressed()) {
      0000FB 12 04 BC         [24]  548 	lcall	_AnyKeyPressed
      0000FE E5 82            [12]  549 	mov	a, dpl
      000100 60 15            [24]  550 	jz	00104$
                                    551 ;	testlcd.c:72: if (!keypadWasDown) {
      000102 E5 29            [12]  552 	mov	a,_keypadWasDown
      000104 70 F5            [24]  553 	jnz	00107$
                                    554 ;	testlcd.c:73: keypadPick = KeyToChar();
      000106 12 04 C9         [24]  555 	lcall	_KeyToChar
      000109 85 82 2B         [24]  556 	mov	_keypadPick,dpl
                                    557 ;	testlcd.c:74: PushInputChar(keypadPick);
      00010C 85 2B 82         [24]  558 	mov	dpl, _keypadPick
      00010F 12 00 81         [24]  559 	lcall	_PushInputChar
                                    560 ;	testlcd.c:75: keypadWasDown = 1;
      000112 75 29 01         [24]  561 	mov	_keypadWasDown,#0x01
      000115 80 E4            [24]  562 	sjmp	00107$
      000117                        563 00104$:
                                    564 ;	testlcd.c:78: keypadWasDown = 0;
      000117 75 29 00         [24]  565 	mov	_keypadWasDown,#0x00
                                    566 ;	testlcd.c:81: }
      00011A 80 DF            [24]  567 	sjmp	00107$
                                    568 ;------------------------------------------------------------
                                    569 ;Allocation info for local variables in function 'LcdDrainTask'
                                    570 ;------------------------------------------------------------
                                    571 ;	testlcd.c:83: void LcdDrainTask(void)
                                    572 ;	-----------------------------------------
                                    573 ;	 function LcdDrainTask
                                    574 ;	-----------------------------------------
      00011C                        575 _LcdDrainTask:
                                    576 ;	testlcd.c:85: LCD_Init();
      00011C 12 03 43         [24]  577 	lcall	_LCD_Init
                                    578 ;	testlcd.c:86: while (!LCD_ready()) { }
      00011F                        579 00101$:
      00011F 12 03 3F         [24]  580 	lcall	_LCD_ready
      000122 E5 82            [12]  581 	mov	a, dpl
      000124 60 F9            [24]  582 	jz	00101$
                                    583 ;	testlcd.c:87: LCD_clearScreen();
      000126 75 82 01         [24]  584 	mov	dpl, #0x01
      000129 12 03 56         [24]  585 	lcall	_LCD_IRWrite
                                    586 ;	testlcd.c:90: SemaphoreWait(usedCells);
      00012C                        587 00107$:
                                    588 ;	assignBit
      00012C C2 AF            [12]  589 	clr	_EA
      00012E E5 21            [12]  590 	mov	a,_usedCells
      000130 60 06            [24]  591 	jz	00105$
      000132 15 21            [12]  592 	dec	_usedCells
                                    593 ;	assignBit
      000134 D2 AF            [12]  594 	setb	_EA
      000136 80 04            [24]  595 	sjmp	00115$
      000138                        596 00105$:
                                    597 ;	assignBit
      000138 D2 AF            [12]  598 	setb	_EA
                                    599 ;	testlcd.c:91: SemaphoreWait(queueGate);
      00013A 80 F0            [24]  600 	sjmp	00107$
      00013C                        601 00115$:
                                    602 ;	assignBit
      00013C C2 AF            [12]  603 	clr	_EA
      00013E E5 20            [12]  604 	mov	a,_queueGate
      000140 60 06            [24]  605 	jz	00113$
      000142 15 20            [12]  606 	dec	_queueGate
                                    607 ;	assignBit
      000144 D2 AF            [12]  608 	setb	_EA
      000146 80 04            [24]  609 	sjmp	00118$
      000148                        610 00113$:
                                    611 ;	assignBit
      000148 D2 AF            [12]  612 	setb	_EA
      00014A 80 F0            [24]  613 	sjmp	00115$
      00014C                        614 00118$:
                                    615 ;	testlcd.c:93: lcdCharOut = inputQueue[queueReadAt];
      00014C E5 26            [12]  616 	mov	a,_queueReadAt
      00014E 24 23            [12]  617 	add	a, #_inputQueue
      000150 F9               [12]  618 	mov	r1,a
      000151 87 2C            [24]  619 	mov	_lcdCharOut,@r1
                                    620 ;	testlcd.c:94: queueReadAt++;
      000153 E5 26            [12]  621 	mov	a,_queueReadAt
      000155 04               [12]  622 	inc	a
      000156 F5 26            [12]  623 	mov	_queueReadAt,a
                                    624 ;	testlcd.c:95: if (queueReadAt == 3) {
      000158 74 03            [12]  625 	mov	a,#0x03
      00015A B5 26 03         [24]  626 	cjne	a,_queueReadAt,00122$
                                    627 ;	testlcd.c:96: queueReadAt = 0;
      00015D 75 26 00         [24]  628 	mov	_queueReadAt,#0x00
                                    629 ;	testlcd.c:99: SemaphoreSignal(queueGate);
      000160                        630 00122$:
                                    631 ;	assignBit
      000160 C2 AF            [12]  632 	clr	_EA
      000162 05 20            [12]  633 	inc	_queueGate
                                    634 ;	assignBit
      000164 D2 AF            [12]  635 	setb	_EA
                                    636 ;	testlcd.c:100: SemaphoreSignal(openCells);
                                    637 ;	assignBit
      000166 C2 AF            [12]  638 	clr	_EA
      000168 05 22            [12]  639 	inc	_openCells
                                    640 ;	assignBit
      00016A D2 AF            [12]  641 	setb	_EA
                                    642 ;	testlcd.c:102: while (!LCD_ready()) { }
      00016C                        643 00128$:
      00016C 12 03 3F         [24]  644 	lcall	_LCD_ready
      00016F E5 82            [12]  645 	mov	a, dpl
      000171 60 F9            [24]  646 	jz	00128$
                                    647 ;	testlcd.c:103: LCD_write_char(lcdCharOut);
      000173 85 2C 82         [24]  648 	mov	dpl, _lcdCharOut
      000176 12 03 C0         [24]  649 	lcall	_LCD_write_char
                                    650 ;	testlcd.c:105: }
      000179 80 B1            [24]  651 	sjmp	00107$
                                    652 ;------------------------------------------------------------
                                    653 ;Allocation info for local variables in function 'main'
                                    654 ;------------------------------------------------------------
                                    655 ;	testlcd.c:107: void main(void)
                                    656 ;	-----------------------------------------
                                    657 ;	 function main
                                    658 ;	-----------------------------------------
      00017B                        659 _main:
                                    660 ;	testlcd.c:109: queueReadAt = 0;
      00017B 75 26 00         [24]  661 	mov	_queueReadAt,#0x00
                                    662 ;	testlcd.c:110: queueWriteAt = 0;
      00017E 75 27 00         [24]  663 	mov	_queueWriteAt,#0x00
                                    664 ;	testlcd.c:111: buttonWasDown = 0;
      000181 75 28 00         [24]  665 	mov	_buttonWasDown,#0x00
                                    666 ;	testlcd.c:112: keypadWasDown = 0;
      000184 75 29 00         [24]  667 	mov	_keypadWasDown,#0x00
                                    668 ;	testlcd.c:113: inputQueue[0] = 0;
      000187 75 23 00         [24]  669 	mov	_inputQueue,#0x00
                                    670 ;	testlcd.c:114: inputQueue[1] = 0;
      00018A 75 24 00         [24]  671 	mov	(_inputQueue + 0x0001),#0x00
                                    672 ;	testlcd.c:115: inputQueue[2] = 0;
      00018D 75 25 00         [24]  673 	mov	(_inputQueue + 0x0002),#0x00
                                    674 ;	testlcd.c:117: SemaphoreCreate(queueGate, 1);
      000190 75 20 01         [24]  675 	mov	_queueGate,#0x01
                                    676 ;	testlcd.c:118: SemaphoreCreate(usedCells, 0);
      000193 75 21 00         [24]  677 	mov	_usedCells,#0x00
                                    678 ;	testlcd.c:119: SemaphoreCreate(openCells, 3);
      000196 75 22 03         [24]  679 	mov	_openCells,#0x03
                                    680 ;	testlcd.c:121: Init_Keypad();
      000199 12 04 B6         [24]  681 	lcall	_Init_Keypad
                                    682 ;	testlcd.c:123: ThreadCreate(ButtonPipeTask);
      00019C 90 00 D4         [24]  683 	mov	dptr,#_ButtonPipeTask
      00019F 12 01 E2         [24]  684 	lcall	_ThreadCreate
                                    685 ;	testlcd.c:124: ThreadCreate(KeyPipeTask);
      0001A2 90 00 F8         [24]  686 	mov	dptr,#_KeyPipeTask
      0001A5 12 01 E2         [24]  687 	lcall	_ThreadCreate
                                    688 ;	testlcd.c:125: LcdDrainTask();
                                    689 ;	testlcd.c:126: }
      0001A8 02 01 1C         [24]  690 	ljmp	_LcdDrainTask
                                    691 ;------------------------------------------------------------
                                    692 ;Allocation info for local variables in function '_sdcc_gsinit_startup'
                                    693 ;------------------------------------------------------------
                                    694 ;	testlcd.c:128: void _sdcc_gsinit_startup(void)
                                    695 ;	-----------------------------------------
                                    696 ;	 function _sdcc_gsinit_startup
                                    697 ;	-----------------------------------------
      0001AB                        698 __sdcc_gsinit_startup:
                                    699 ;	testlcd.c:132: __endasm;
      0001AB 02 01 B8         [24]  700 	LJMP	_Bootstrap
                                    701 ;	testlcd.c:133: }
      0001AE 22               [24]  702 	ret
                                    703 ;------------------------------------------------------------
                                    704 ;Allocation info for local variables in function '_mcs51_genRAMCLEAR'
                                    705 ;------------------------------------------------------------
                                    706 ;	testlcd.c:135: void _mcs51_genRAMCLEAR(void) { }
                                    707 ;	-----------------------------------------
                                    708 ;	 function _mcs51_genRAMCLEAR
                                    709 ;	-----------------------------------------
      0001AF                        710 __mcs51_genRAMCLEAR:
      0001AF 22               [24]  711 	ret
                                    712 ;------------------------------------------------------------
                                    713 ;Allocation info for local variables in function '_mcs51_genXINIT'
                                    714 ;------------------------------------------------------------
                                    715 ;	testlcd.c:136: void _mcs51_genXINIT(void) { }
                                    716 ;	-----------------------------------------
                                    717 ;	 function _mcs51_genXINIT
                                    718 ;	-----------------------------------------
      0001B0                        719 __mcs51_genXINIT:
      0001B0 22               [24]  720 	ret
                                    721 ;------------------------------------------------------------
                                    722 ;Allocation info for local variables in function '_mcs51_genXRAMCLEAR'
                                    723 ;------------------------------------------------------------
                                    724 ;	testlcd.c:137: void _mcs51_genXRAMCLEAR(void) { }
                                    725 ;	-----------------------------------------
                                    726 ;	 function _mcs51_genXRAMCLEAR
                                    727 ;	-----------------------------------------
      0001B1                        728 __mcs51_genXRAMCLEAR:
      0001B1 22               [24]  729 	ret
                                    730 ;------------------------------------------------------------
                                    731 ;Allocation info for local variables in function 'timer0_ISR'
                                    732 ;------------------------------------------------------------
                                    733 ;	testlcd.c:139: void timer0_ISR(void) __interrupt(1)
                                    734 ;	-----------------------------------------
                                    735 ;	 function timer0_ISR
                                    736 ;	-----------------------------------------
      0001B2                        737 _timer0_ISR:
                                    738 ;	testlcd.c:143: __endasm;
      0001B2 02 02 F5         [24]  739 	LJMP	_myTimer0Handler
                                    740 ;	testlcd.c:144: }
      0001B5 02 00 54         [24]  741 	ljmp	sdcc_atomic_maybe_rollback
                                    742 ;	eliminated unneeded mov psw,# (no regs used in bank)
                                    743 ;	eliminated unneeded push/pop not_psw
                                    744 ;	eliminated unneeded push/pop dpl
                                    745 ;	eliminated unneeded push/pop dph
                                    746 ;	eliminated unneeded push/pop b
                                    747 ;	eliminated unneeded push/pop acc
                                    748 	.area CSEG    (CODE)
                                    749 	.area CONST   (CODE)
                                    750 	.area XINIT   (CODE)
                                    751 	.area CABS    (ABS,CODE)
