                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ISO C Compiler
                                      3 ; Version 4.5.0 #15242 (MINGW64)
                                      4 ;--------------------------------------------------------
                                      5 	.module buttonlib
                                      6 	
                                      7 	.optsdcc -mmcs51 --model-small
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _CY
                                     12 	.globl _AC
                                     13 	.globl _F0
                                     14 	.globl _RS1
                                     15 	.globl _RS0
                                     16 	.globl _OV
                                     17 	.globl _F1
                                     18 	.globl _P
                                     19 	.globl _PS
                                     20 	.globl _PT1
                                     21 	.globl _PX1
                                     22 	.globl _PT0
                                     23 	.globl _PX0
                                     24 	.globl _RD
                                     25 	.globl _WR
                                     26 	.globl _T1
                                     27 	.globl _T0
                                     28 	.globl _INT1
                                     29 	.globl _INT0
                                     30 	.globl _TXD
                                     31 	.globl _RXD
                                     32 	.globl _P3_7
                                     33 	.globl _P3_6
                                     34 	.globl _P3_5
                                     35 	.globl _P3_4
                                     36 	.globl _P3_3
                                     37 	.globl _P3_2
                                     38 	.globl _P3_1
                                     39 	.globl _P3_0
                                     40 	.globl _EA
                                     41 	.globl _ES
                                     42 	.globl _ET1
                                     43 	.globl _EX1
                                     44 	.globl _ET0
                                     45 	.globl _EX0
                                     46 	.globl _P2_7
                                     47 	.globl _P2_6
                                     48 	.globl _P2_5
                                     49 	.globl _P2_4
                                     50 	.globl _P2_3
                                     51 	.globl _P2_2
                                     52 	.globl _P2_1
                                     53 	.globl _P2_0
                                     54 	.globl _SM0
                                     55 	.globl _SM1
                                     56 	.globl _SM2
                                     57 	.globl _REN
                                     58 	.globl _TB8
                                     59 	.globl _RB8
                                     60 	.globl _TI
                                     61 	.globl _RI
                                     62 	.globl _P1_7
                                     63 	.globl _P1_6
                                     64 	.globl _P1_5
                                     65 	.globl _P1_4
                                     66 	.globl _P1_3
                                     67 	.globl _P1_2
                                     68 	.globl _P1_1
                                     69 	.globl _P1_0
                                     70 	.globl _TF1
                                     71 	.globl _TR1
                                     72 	.globl _TF0
                                     73 	.globl _TR0
                                     74 	.globl _IE1
                                     75 	.globl _IT1
                                     76 	.globl _IE0
                                     77 	.globl _IT0
                                     78 	.globl _P0_7
                                     79 	.globl _P0_6
                                     80 	.globl _P0_5
                                     81 	.globl _P0_4
                                     82 	.globl _P0_3
                                     83 	.globl _P0_2
                                     84 	.globl _P0_1
                                     85 	.globl _P0_0
                                     86 	.globl _B
                                     87 	.globl _ACC
                                     88 	.globl _PSW
                                     89 	.globl _IP
                                     90 	.globl _P3
                                     91 	.globl _IE
                                     92 	.globl _P2
                                     93 	.globl _SBUF
                                     94 	.globl _SCON
                                     95 	.globl _P1
                                     96 	.globl _TH1
                                     97 	.globl _TH0
                                     98 	.globl _TL1
                                     99 	.globl _TL0
                                    100 	.globl _TMOD
                                    101 	.globl _TCON
                                    102 	.globl _PCON
                                    103 	.globl _DPH
                                    104 	.globl _DPL
                                    105 	.globl _SP
                                    106 	.globl _P0
                                    107 	.globl _AnyButtonPressed
                                    108 	.globl _ButtonToChar
                                    109 ;--------------------------------------------------------
                                    110 ; special function registers
                                    111 ;--------------------------------------------------------
                                    112 	.area RSEG    (ABS,DATA)
      000000                        113 	.org 0x0000
                           000080   114 _P0	=	0x0080
                           000081   115 _SP	=	0x0081
                           000082   116 _DPL	=	0x0082
                           000083   117 _DPH	=	0x0083
                           000087   118 _PCON	=	0x0087
                           000088   119 _TCON	=	0x0088
                           000089   120 _TMOD	=	0x0089
                           00008A   121 _TL0	=	0x008a
                           00008B   122 _TL1	=	0x008b
                           00008C   123 _TH0	=	0x008c
                           00008D   124 _TH1	=	0x008d
                           000090   125 _P1	=	0x0090
                           000098   126 _SCON	=	0x0098
                           000099   127 _SBUF	=	0x0099
                           0000A0   128 _P2	=	0x00a0
                           0000A8   129 _IE	=	0x00a8
                           0000B0   130 _P3	=	0x00b0
                           0000B8   131 _IP	=	0x00b8
                           0000D0   132 _PSW	=	0x00d0
                           0000E0   133 _ACC	=	0x00e0
                           0000F0   134 _B	=	0x00f0
                                    135 ;--------------------------------------------------------
                                    136 ; special function bits
                                    137 ;--------------------------------------------------------
                                    138 	.area RSEG    (ABS,DATA)
      000000                        139 	.org 0x0000
                           000080   140 _P0_0	=	0x0080
                           000081   141 _P0_1	=	0x0081
                           000082   142 _P0_2	=	0x0082
                           000083   143 _P0_3	=	0x0083
                           000084   144 _P0_4	=	0x0084
                           000085   145 _P0_5	=	0x0085
                           000086   146 _P0_6	=	0x0086
                           000087   147 _P0_7	=	0x0087
                           000088   148 _IT0	=	0x0088
                           000089   149 _IE0	=	0x0089
                           00008A   150 _IT1	=	0x008a
                           00008B   151 _IE1	=	0x008b
                           00008C   152 _TR0	=	0x008c
                           00008D   153 _TF0	=	0x008d
                           00008E   154 _TR1	=	0x008e
                           00008F   155 _TF1	=	0x008f
                           000090   156 _P1_0	=	0x0090
                           000091   157 _P1_1	=	0x0091
                           000092   158 _P1_2	=	0x0092
                           000093   159 _P1_3	=	0x0093
                           000094   160 _P1_4	=	0x0094
                           000095   161 _P1_5	=	0x0095
                           000096   162 _P1_6	=	0x0096
                           000097   163 _P1_7	=	0x0097
                           000098   164 _RI	=	0x0098
                           000099   165 _TI	=	0x0099
                           00009A   166 _RB8	=	0x009a
                           00009B   167 _TB8	=	0x009b
                           00009C   168 _REN	=	0x009c
                           00009D   169 _SM2	=	0x009d
                           00009E   170 _SM1	=	0x009e
                           00009F   171 _SM0	=	0x009f
                           0000A0   172 _P2_0	=	0x00a0
                           0000A1   173 _P2_1	=	0x00a1
                           0000A2   174 _P2_2	=	0x00a2
                           0000A3   175 _P2_3	=	0x00a3
                           0000A4   176 _P2_4	=	0x00a4
                           0000A5   177 _P2_5	=	0x00a5
                           0000A6   178 _P2_6	=	0x00a6
                           0000A7   179 _P2_7	=	0x00a7
                           0000A8   180 _EX0	=	0x00a8
                           0000A9   181 _ET0	=	0x00a9
                           0000AA   182 _EX1	=	0x00aa
                           0000AB   183 _ET1	=	0x00ab
                           0000AC   184 _ES	=	0x00ac
                           0000AF   185 _EA	=	0x00af
                           0000B0   186 _P3_0	=	0x00b0
                           0000B1   187 _P3_1	=	0x00b1
                           0000B2   188 _P3_2	=	0x00b2
                           0000B3   189 _P3_3	=	0x00b3
                           0000B4   190 _P3_4	=	0x00b4
                           0000B5   191 _P3_5	=	0x00b5
                           0000B6   192 _P3_6	=	0x00b6
                           0000B7   193 _P3_7	=	0x00b7
                           0000B0   194 _RXD	=	0x00b0
                           0000B1   195 _TXD	=	0x00b1
                           0000B2   196 _INT0	=	0x00b2
                           0000B3   197 _INT1	=	0x00b3
                           0000B4   198 _T0	=	0x00b4
                           0000B5   199 _T1	=	0x00b5
                           0000B6   200 _WR	=	0x00b6
                           0000B7   201 _RD	=	0x00b7
                           0000B8   202 _PX0	=	0x00b8
                           0000B9   203 _PT0	=	0x00b9
                           0000BA   204 _PX1	=	0x00ba
                           0000BB   205 _PT1	=	0x00bb
                           0000BC   206 _PS	=	0x00bc
                           0000D0   207 _P	=	0x00d0
                           0000D1   208 _F1	=	0x00d1
                           0000D2   209 _OV	=	0x00d2
                           0000D3   210 _RS0	=	0x00d3
                           0000D4   211 _RS1	=	0x00d4
                           0000D5   212 _F0	=	0x00d5
                           0000D6   213 _AC	=	0x00d6
                           0000D7   214 _CY	=	0x00d7
                                    215 ;--------------------------------------------------------
                                    216 ; overlayable register banks
                                    217 ;--------------------------------------------------------
                                    218 	.area REG_BANK_0	(REL,OVR,DATA)
      000000                        219 	.ds 8
                                    220 ;--------------------------------------------------------
                                    221 ; internal ram data
                                    222 ;--------------------------------------------------------
                                    223 	.area DSEG    (DATA)
                                    224 ;--------------------------------------------------------
                                    225 ; overlayable items in internal ram
                                    226 ;--------------------------------------------------------
                                    227 ;--------------------------------------------------------
                                    228 ; indirectly addressable internal ram data
                                    229 ;--------------------------------------------------------
                                    230 	.area ISEG    (DATA)
                                    231 ;--------------------------------------------------------
                                    232 ; absolute internal ram data
                                    233 ;--------------------------------------------------------
                                    234 	.area IABS    (ABS,DATA)
                                    235 	.area IABS    (ABS,DATA)
                                    236 ;--------------------------------------------------------
                                    237 ; bit data
                                    238 ;--------------------------------------------------------
                                    239 	.area BSEG    (BIT)
      000000                        240 _AnyButtonPressed_sloc0_1_0:
      000000                        241 	.ds 1
                                    242 ;--------------------------------------------------------
                                    243 ; paged external ram data
                                    244 ;--------------------------------------------------------
                                    245 	.area PSEG    (PAG,XDATA)
                                    246 ;--------------------------------------------------------
                                    247 ; uninitialized external ram data
                                    248 ;--------------------------------------------------------
                                    249 	.area XSEG    (XDATA)
                                    250 ;--------------------------------------------------------
                                    251 ; absolute external ram data
                                    252 ;--------------------------------------------------------
                                    253 	.area XABS    (ABS,XDATA)
                                    254 ;--------------------------------------------------------
                                    255 ; initialized external ram data
                                    256 ;--------------------------------------------------------
                                    257 	.area XISEG   (XDATA)
                                    258 	.area HOME    (CODE)
                                    259 	.area GSINIT0 (CODE)
                                    260 	.area GSINIT1 (CODE)
                                    261 	.area GSINIT2 (CODE)
                                    262 	.area GSINIT3 (CODE)
                                    263 	.area GSINIT4 (CODE)
                                    264 	.area GSINIT5 (CODE)
                                    265 	.area GSINIT  (CODE)
                                    266 	.area GSFINAL (CODE)
                                    267 	.area CSEG    (CODE)
                                    268 ;--------------------------------------------------------
                                    269 ; global & static initialisations
                                    270 ;--------------------------------------------------------
                                    271 	.area HOME    (CODE)
                                    272 	.area GSINIT  (CODE)
                                    273 	.area GSFINAL (CODE)
                                    274 	.area GSINIT  (CODE)
                                    275 ;--------------------------------------------------------
                                    276 ; Home
                                    277 ;--------------------------------------------------------
                                    278 	.area HOME    (CODE)
                                    279 	.area HOME    (CODE)
                                    280 ;--------------------------------------------------------
                                    281 ; code
                                    282 ;--------------------------------------------------------
                                    283 	.area CSEG    (CODE)
                                    284 ;------------------------------------------------------------
                                    285 ;Allocation info for local variables in function 'AnyButtonPressed'
                                    286 ;------------------------------------------------------------
                                    287 ;	buttonlib.c:12: char AnyButtonPressed(void)
                                    288 ;	-----------------------------------------
                                    289 ;	 function AnyButtonPressed
                                    290 ;	-----------------------------------------
      000419                        291 _AnyButtonPressed:
                           000007   292 	ar7 = 0x07
                           000006   293 	ar6 = 0x06
                           000005   294 	ar5 = 0x05
                           000004   295 	ar4 = 0x04
                           000003   296 	ar3 = 0x03
                           000002   297 	ar2 = 0x02
                           000001   298 	ar1 = 0x01
                           000000   299 	ar0 = 0x00
                                    300 ;	buttonlib.c:14: return (P2 != 0xFF);
      000419 74 FF            [12]  301 	mov	a,#0xff
      00041B B5 A0 03         [24]  302 	cjne	a,_P2,00103$
      00041E D3               [12]  303 	setb	c
      00041F 80 01            [24]  304 	sjmp	00104$
      000421                        305 00103$:
      000421 C3               [12]  306 	clr	c
      000422                        307 00104$:
      000422 B3               [12]  308 	cpl	c
      000423 92 00            [24]  309 	mov	_AnyButtonPressed_sloc0_1_0,c
      000425 E4               [12]  310 	clr	a
      000426 33               [12]  311 	rlc	a
      000427 F5 82            [12]  312 	mov	dpl,a
                                    313 ;	buttonlib.c:15: }
      000429 22               [24]  314 	ret
                                    315 ;------------------------------------------------------------
                                    316 ;Allocation info for local variables in function 'ButtonToChar'
                                    317 ;------------------------------------------------------------
                                    318 ;	buttonlib.c:21: char ButtonToChar(void)
                                    319 ;	-----------------------------------------
                                    320 ;	 function ButtonToChar
                                    321 ;	-----------------------------------------
      00042A                        322 _ButtonToChar:
                                    323 ;	buttonlib.c:23: if ((~P2) & 0x80) {
      00042A AE A0            [24]  324 	mov	r6,_P2
      00042C 7F 00            [12]  325 	mov	r7,#0x00
      00042E EE               [12]  326 	mov	a,r6
      00042F F4               [12]  327 	cpl	a
      000430 FE               [12]  328 	mov	r6,a
      000431 EF               [12]  329 	mov	a,r7
      000432 F4               [12]  330 	cpl	a
      000433 EE               [12]  331 	mov	a,r6
      000434 30 E7 04         [24]  332 	jnb	acc.7,00122$
                                    333 ;	buttonlib.c:24: return '7';
      000437 75 82 37         [24]  334 	mov	dpl, #0x37
      00043A 22               [24]  335 	ret
      00043B                        336 00122$:
                                    337 ;	buttonlib.c:25: } else if ((~P2) & 0x40) {
      00043B AE A0            [24]  338 	mov	r6,_P2
      00043D 7F 00            [12]  339 	mov	r7,#0x00
      00043F EE               [12]  340 	mov	a,r6
      000440 F4               [12]  341 	cpl	a
      000441 FE               [12]  342 	mov	r6,a
      000442 EF               [12]  343 	mov	a,r7
      000443 F4               [12]  344 	cpl	a
      000444 EE               [12]  345 	mov	a,r6
      000445 30 E6 04         [24]  346 	jnb	acc.6,00119$
                                    347 ;	buttonlib.c:26: return '6';
      000448 75 82 36         [24]  348 	mov	dpl, #0x36
      00044B 22               [24]  349 	ret
      00044C                        350 00119$:
                                    351 ;	buttonlib.c:27: } else if ((~P2) & 0x20) {
      00044C AE A0            [24]  352 	mov	r6,_P2
      00044E 7F 00            [12]  353 	mov	r7,#0x00
      000450 EE               [12]  354 	mov	a,r6
      000451 F4               [12]  355 	cpl	a
      000452 FE               [12]  356 	mov	r6,a
      000453 EF               [12]  357 	mov	a,r7
      000454 F4               [12]  358 	cpl	a
      000455 EE               [12]  359 	mov	a,r6
      000456 30 E5 04         [24]  360 	jnb	acc.5,00116$
                                    361 ;	buttonlib.c:28: return '5';
      000459 75 82 35         [24]  362 	mov	dpl, #0x35
      00045C 22               [24]  363 	ret
      00045D                        364 00116$:
                                    365 ;	buttonlib.c:29: } else if ((~P2) & 0x10) {
      00045D AE A0            [24]  366 	mov	r6,_P2
      00045F 7F 00            [12]  367 	mov	r7,#0x00
      000461 EE               [12]  368 	mov	a,r6
      000462 F4               [12]  369 	cpl	a
      000463 FE               [12]  370 	mov	r6,a
      000464 EF               [12]  371 	mov	a,r7
      000465 F4               [12]  372 	cpl	a
      000466 EE               [12]  373 	mov	a,r6
      000467 30 E4 04         [24]  374 	jnb	acc.4,00113$
                                    375 ;	buttonlib.c:30: return '4';
      00046A 75 82 34         [24]  376 	mov	dpl, #0x34
      00046D 22               [24]  377 	ret
      00046E                        378 00113$:
                                    379 ;	buttonlib.c:31: } else if ((~P2) & 0x08) {
      00046E AE A0            [24]  380 	mov	r6,_P2
      000470 7F 00            [12]  381 	mov	r7,#0x00
      000472 EE               [12]  382 	mov	a,r6
      000473 F4               [12]  383 	cpl	a
      000474 FE               [12]  384 	mov	r6,a
      000475 EF               [12]  385 	mov	a,r7
      000476 F4               [12]  386 	cpl	a
      000477 EE               [12]  387 	mov	a,r6
      000478 30 E3 04         [24]  388 	jnb	acc.3,00110$
                                    389 ;	buttonlib.c:32: return '3';
      00047B 75 82 33         [24]  390 	mov	dpl, #0x33
      00047E 22               [24]  391 	ret
      00047F                        392 00110$:
                                    393 ;	buttonlib.c:33: } else if ((~P2) & 0x04) {
      00047F AE A0            [24]  394 	mov	r6,_P2
      000481 7F 00            [12]  395 	mov	r7,#0x00
      000483 EE               [12]  396 	mov	a,r6
      000484 F4               [12]  397 	cpl	a
      000485 FE               [12]  398 	mov	r6,a
      000486 EF               [12]  399 	mov	a,r7
      000487 F4               [12]  400 	cpl	a
      000488 EE               [12]  401 	mov	a,r6
      000489 30 E2 04         [24]  402 	jnb	acc.2,00107$
                                    403 ;	buttonlib.c:34: return '2';
      00048C 75 82 32         [24]  404 	mov	dpl, #0x32
      00048F 22               [24]  405 	ret
      000490                        406 00107$:
                                    407 ;	buttonlib.c:35: } else if ((~P2) & 0x02) {
      000490 AE A0            [24]  408 	mov	r6,_P2
      000492 7F 00            [12]  409 	mov	r7,#0x00
      000494 EE               [12]  410 	mov	a,r6
      000495 F4               [12]  411 	cpl	a
      000496 FE               [12]  412 	mov	r6,a
      000497 EF               [12]  413 	mov	a,r7
      000498 F4               [12]  414 	cpl	a
      000499 EE               [12]  415 	mov	a,r6
      00049A 30 E1 04         [24]  416 	jnb	acc.1,00104$
                                    417 ;	buttonlib.c:36: return '1';
      00049D 75 82 31         [24]  418 	mov	dpl, #0x31
      0004A0 22               [24]  419 	ret
      0004A1                        420 00104$:
                                    421 ;	buttonlib.c:37: } else if ((~P2) & 0x01) {
      0004A1 AE A0            [24]  422 	mov	r6,_P2
      0004A3 7F 00            [12]  423 	mov	r7,#0x00
      0004A5 EE               [12]  424 	mov	a,r6
      0004A6 F4               [12]  425 	cpl	a
      0004A7 FE               [12]  426 	mov	r6,a
      0004A8 EF               [12]  427 	mov	a,r7
      0004A9 F4               [12]  428 	cpl	a
      0004AA EE               [12]  429 	mov	a,r6
      0004AB 30 E0 04         [24]  430 	jnb	acc.0,00108$
                                    431 ;	buttonlib.c:38: return '0';
      0004AE 75 82 30         [24]  432 	mov	dpl, #0x30
      0004B1 22               [24]  433 	ret
      0004B2                        434 00108$:
                                    435 ;	buttonlib.c:40: return '\0';
      0004B2 75 82 00         [24]  436 	mov	dpl, #0x00
                                    437 ;	buttonlib.c:41: }
      0004B5 22               [24]  438 	ret
                                    439 	.area CSEG    (CODE)
                                    440 	.area CONST   (CODE)
                                    441 	.area XINIT   (CODE)
                                    442 	.area CABS    (ABS,CODE)
