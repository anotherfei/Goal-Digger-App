                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ISO C Compiler
                                      3 ; Version 4.5.0 #15242 (MINGW64)
                                      4 ;--------------------------------------------------------
                                      5 	.module keylib
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
                                    107 	.globl _Init_Keypad
                                    108 	.globl _AnyKeyPressed
                                    109 	.globl _KeyToChar
                                    110 ;--------------------------------------------------------
                                    111 ; special function registers
                                    112 ;--------------------------------------------------------
                                    113 	.area RSEG    (ABS,DATA)
      000000                        114 	.org 0x0000
                           000080   115 _P0	=	0x0080
                           000081   116 _SP	=	0x0081
                           000082   117 _DPL	=	0x0082
                           000083   118 _DPH	=	0x0083
                           000087   119 _PCON	=	0x0087
                           000088   120 _TCON	=	0x0088
                           000089   121 _TMOD	=	0x0089
                           00008A   122 _TL0	=	0x008a
                           00008B   123 _TL1	=	0x008b
                           00008C   124 _TH0	=	0x008c
                           00008D   125 _TH1	=	0x008d
                           000090   126 _P1	=	0x0090
                           000098   127 _SCON	=	0x0098
                           000099   128 _SBUF	=	0x0099
                           0000A0   129 _P2	=	0x00a0
                           0000A8   130 _IE	=	0x00a8
                           0000B0   131 _P3	=	0x00b0
                           0000B8   132 _IP	=	0x00b8
                           0000D0   133 _PSW	=	0x00d0
                           0000E0   134 _ACC	=	0x00e0
                           0000F0   135 _B	=	0x00f0
                                    136 ;--------------------------------------------------------
                                    137 ; special function bits
                                    138 ;--------------------------------------------------------
                                    139 	.area RSEG    (ABS,DATA)
      000000                        140 	.org 0x0000
                           000080   141 _P0_0	=	0x0080
                           000081   142 _P0_1	=	0x0081
                           000082   143 _P0_2	=	0x0082
                           000083   144 _P0_3	=	0x0083
                           000084   145 _P0_4	=	0x0084
                           000085   146 _P0_5	=	0x0085
                           000086   147 _P0_6	=	0x0086
                           000087   148 _P0_7	=	0x0087
                           000088   149 _IT0	=	0x0088
                           000089   150 _IE0	=	0x0089
                           00008A   151 _IT1	=	0x008a
                           00008B   152 _IE1	=	0x008b
                           00008C   153 _TR0	=	0x008c
                           00008D   154 _TF0	=	0x008d
                           00008E   155 _TR1	=	0x008e
                           00008F   156 _TF1	=	0x008f
                           000090   157 _P1_0	=	0x0090
                           000091   158 _P1_1	=	0x0091
                           000092   159 _P1_2	=	0x0092
                           000093   160 _P1_3	=	0x0093
                           000094   161 _P1_4	=	0x0094
                           000095   162 _P1_5	=	0x0095
                           000096   163 _P1_6	=	0x0096
                           000097   164 _P1_7	=	0x0097
                           000098   165 _RI	=	0x0098
                           000099   166 _TI	=	0x0099
                           00009A   167 _RB8	=	0x009a
                           00009B   168 _TB8	=	0x009b
                           00009C   169 _REN	=	0x009c
                           00009D   170 _SM2	=	0x009d
                           00009E   171 _SM1	=	0x009e
                           00009F   172 _SM0	=	0x009f
                           0000A0   173 _P2_0	=	0x00a0
                           0000A1   174 _P2_1	=	0x00a1
                           0000A2   175 _P2_2	=	0x00a2
                           0000A3   176 _P2_3	=	0x00a3
                           0000A4   177 _P2_4	=	0x00a4
                           0000A5   178 _P2_5	=	0x00a5
                           0000A6   179 _P2_6	=	0x00a6
                           0000A7   180 _P2_7	=	0x00a7
                           0000A8   181 _EX0	=	0x00a8
                           0000A9   182 _ET0	=	0x00a9
                           0000AA   183 _EX1	=	0x00aa
                           0000AB   184 _ET1	=	0x00ab
                           0000AC   185 _ES	=	0x00ac
                           0000AF   186 _EA	=	0x00af
                           0000B0   187 _P3_0	=	0x00b0
                           0000B1   188 _P3_1	=	0x00b1
                           0000B2   189 _P3_2	=	0x00b2
                           0000B3   190 _P3_3	=	0x00b3
                           0000B4   191 _P3_4	=	0x00b4
                           0000B5   192 _P3_5	=	0x00b5
                           0000B6   193 _P3_6	=	0x00b6
                           0000B7   194 _P3_7	=	0x00b7
                           0000B0   195 _RXD	=	0x00b0
                           0000B1   196 _TXD	=	0x00b1
                           0000B2   197 _INT0	=	0x00b2
                           0000B3   198 _INT1	=	0x00b3
                           0000B4   199 _T0	=	0x00b4
                           0000B5   200 _T1	=	0x00b5
                           0000B6   201 _WR	=	0x00b6
                           0000B7   202 _RD	=	0x00b7
                           0000B8   203 _PX0	=	0x00b8
                           0000B9   204 _PT0	=	0x00b9
                           0000BA   205 _PX1	=	0x00ba
                           0000BB   206 _PT1	=	0x00bb
                           0000BC   207 _PS	=	0x00bc
                           0000D0   208 _P	=	0x00d0
                           0000D1   209 _F1	=	0x00d1
                           0000D2   210 _OV	=	0x00d2
                           0000D3   211 _RS0	=	0x00d3
                           0000D4   212 _RS1	=	0x00d4
                           0000D5   213 _F0	=	0x00d5
                           0000D6   214 _AC	=	0x00d6
                           0000D7   215 _CY	=	0x00d7
                                    216 ;--------------------------------------------------------
                                    217 ; overlayable register banks
                                    218 ;--------------------------------------------------------
                                    219 	.area REG_BANK_0	(REL,OVR,DATA)
      000000                        220 	.ds 8
                                    221 ;--------------------------------------------------------
                                    222 ; internal ram data
                                    223 ;--------------------------------------------------------
                                    224 	.area DSEG    (DATA)
                                    225 ;--------------------------------------------------------
                                    226 ; overlayable items in internal ram
                                    227 ;--------------------------------------------------------
                                    228 ;--------------------------------------------------------
                                    229 ; indirectly addressable internal ram data
                                    230 ;--------------------------------------------------------
                                    231 	.area ISEG    (DATA)
                                    232 ;--------------------------------------------------------
                                    233 ; absolute internal ram data
                                    234 ;--------------------------------------------------------
                                    235 	.area IABS    (ABS,DATA)
                                    236 	.area IABS    (ABS,DATA)
                                    237 ;--------------------------------------------------------
                                    238 ; bit data
                                    239 ;--------------------------------------------------------
                                    240 	.area BSEG    (BIT)
      000000                        241 _AnyKeyPressed_sloc0_1_0:
      000000                        242 	.ds 1
                                    243 ;--------------------------------------------------------
                                    244 ; paged external ram data
                                    245 ;--------------------------------------------------------
                                    246 	.area PSEG    (PAG,XDATA)
                                    247 ;--------------------------------------------------------
                                    248 ; uninitialized external ram data
                                    249 ;--------------------------------------------------------
                                    250 	.area XSEG    (XDATA)
                                    251 ;--------------------------------------------------------
                                    252 ; absolute external ram data
                                    253 ;--------------------------------------------------------
                                    254 	.area XABS    (ABS,XDATA)
                                    255 ;--------------------------------------------------------
                                    256 ; initialized external ram data
                                    257 ;--------------------------------------------------------
                                    258 	.area XISEG   (XDATA)
                                    259 	.area HOME    (CODE)
                                    260 	.area GSINIT0 (CODE)
                                    261 	.area GSINIT1 (CODE)
                                    262 	.area GSINIT2 (CODE)
                                    263 	.area GSINIT3 (CODE)
                                    264 	.area GSINIT4 (CODE)
                                    265 	.area GSINIT5 (CODE)
                                    266 	.area GSINIT  (CODE)
                                    267 	.area GSFINAL (CODE)
                                    268 	.area CSEG    (CODE)
                                    269 ;--------------------------------------------------------
                                    270 ; global & static initialisations
                                    271 ;--------------------------------------------------------
                                    272 	.area HOME    (CODE)
                                    273 	.area GSINIT  (CODE)
                                    274 	.area GSFINAL (CODE)
                                    275 	.area GSINIT  (CODE)
                                    276 ;--------------------------------------------------------
                                    277 ; Home
                                    278 ;--------------------------------------------------------
                                    279 	.area HOME    (CODE)
                                    280 	.area HOME    (CODE)
                                    281 ;--------------------------------------------------------
                                    282 ; code
                                    283 ;--------------------------------------------------------
                                    284 	.area CSEG    (CODE)
                                    285 ;------------------------------------------------------------
                                    286 ;Allocation info for local variables in function 'Init_Keypad'
                                    287 ;------------------------------------------------------------
                                    288 ;	keylib.c:11: void Init_Keypad(void)
                                    289 ;	-----------------------------------------
                                    290 ;	 function Init_Keypad
                                    291 ;	-----------------------------------------
      000B31                        292 _Init_Keypad:
                           000007   293 	ar7 = 0x07
                           000006   294 	ar6 = 0x06
                           000005   295 	ar5 = 0x05
                           000004   296 	ar4 = 0x04
                           000003   297 	ar3 = 0x03
                           000002   298 	ar2 = 0x02
                           000001   299 	ar1 = 0x01
                           000000   300 	ar0 = 0x00
                                    301 ;	keylib.c:13: P3_3 = 1;
                                    302 ;	assignBit
      000B31 D2 B3            [12]  303 	setb	_P3_3
                                    304 ;	keylib.c:14: P0 = 0xF0;
      000B33 75 80 F0         [24]  305 	mov	_P0,#0xf0
                                    306 ;	keylib.c:15: }
      000B36 22               [24]  307 	ret
                                    308 ;------------------------------------------------------------
                                    309 ;Allocation info for local variables in function 'AnyKeyPressed'
                                    310 ;------------------------------------------------------------
                                    311 ;	keylib.c:17: char AnyKeyPressed(void)
                                    312 ;	-----------------------------------------
                                    313 ;	 function AnyKeyPressed
                                    314 ;	-----------------------------------------
      000B37                        315 _AnyKeyPressed:
                                    316 ;	keylib.c:19: P0 = 0xF0;
      000B37 75 80 F0         [24]  317 	mov	_P0,#0xf0
                                    318 ;	keylib.c:20: return !P3_3;
      000B3A A2 B3            [12]  319 	mov	c,_P3_3
      000B3C B3               [12]  320 	cpl	c
      000B3D 92 00            [24]  321 	mov  _AnyKeyPressed_sloc0_1_0,c
      000B3F E4               [12]  322 	clr	a
      000B40 33               [12]  323 	rlc	a
      000B41 F5 82            [12]  324 	mov	dpl,a
                                    325 ;	keylib.c:21: }
      000B43 22               [24]  326 	ret
                                    327 ;------------------------------------------------------------
                                    328 ;Allocation info for local variables in function 'KeyToChar'
                                    329 ;------------------------------------------------------------
                                    330 ;	keylib.c:23: char KeyToChar(void)
                                    331 ;	-----------------------------------------
                                    332 ;	 function KeyToChar
                                    333 ;	-----------------------------------------
      000B44                        334 _KeyToChar:
                                    335 ;	keylib.c:25: P0 = 0xF7;
      000B44 75 80 F7         [24]  336 	mov	_P0,#0xf7
                                    337 ;	keylib.c:26: if (P0 == 0xB7) {
      000B47 74 B7            [12]  338 	mov	a,#0xb7
      000B49 B5 80 04         [24]  339 	cjne	a,_P0,00107$
                                    340 ;	keylib.c:27: return '1';
      000B4C 75 82 31         [24]  341 	mov	dpl, #0x31
      000B4F 22               [24]  342 	ret
      000B50                        343 00107$:
                                    344 ;	keylib.c:28: } else if (P0 == 0xD7) {
      000B50 74 D7            [12]  345 	mov	a,#0xd7
      000B52 B5 80 04         [24]  346 	cjne	a,_P0,00104$
                                    347 ;	keylib.c:29: return '2';
      000B55 75 82 32         [24]  348 	mov	dpl, #0x32
      000B58 22               [24]  349 	ret
      000B59                        350 00104$:
                                    351 ;	keylib.c:30: } else if (P0 == 0xE7) {
      000B59 74 E7            [12]  352 	mov	a,#0xe7
      000B5B B5 80 04         [24]  353 	cjne	a,_P0,00108$
                                    354 ;	keylib.c:31: return '3';
      000B5E 75 82 33         [24]  355 	mov	dpl, #0x33
      000B61 22               [24]  356 	ret
      000B62                        357 00108$:
                                    358 ;	keylib.c:34: P0 = 0xFB;
      000B62 75 80 FB         [24]  359 	mov	_P0,#0xfb
                                    360 ;	keylib.c:35: if (P0 == 0xBB) {
      000B65 74 BB            [12]  361 	mov	a,#0xbb
      000B67 B5 80 04         [24]  362 	cjne	a,_P0,00115$
                                    363 ;	keylib.c:36: return '4';
      000B6A 75 82 34         [24]  364 	mov	dpl, #0x34
      000B6D 22               [24]  365 	ret
      000B6E                        366 00115$:
                                    367 ;	keylib.c:37: } else if (P0 == 0xDB) {
      000B6E 74 DB            [12]  368 	mov	a,#0xdb
      000B70 B5 80 04         [24]  369 	cjne	a,_P0,00112$
                                    370 ;	keylib.c:38: return '5';
      000B73 75 82 35         [24]  371 	mov	dpl, #0x35
      000B76 22               [24]  372 	ret
      000B77                        373 00112$:
                                    374 ;	keylib.c:39: } else if (P0 == 0xEB) {
      000B77 74 EB            [12]  375 	mov	a,#0xeb
      000B79 B5 80 04         [24]  376 	cjne	a,_P0,00116$
                                    377 ;	keylib.c:40: return '6';
      000B7C 75 82 36         [24]  378 	mov	dpl, #0x36
      000B7F 22               [24]  379 	ret
      000B80                        380 00116$:
                                    381 ;	keylib.c:43: P0 = 0xFD;
      000B80 75 80 FD         [24]  382 	mov	_P0,#0xfd
                                    383 ;	keylib.c:44: if (P0 == 0xBD) {
      000B83 74 BD            [12]  384 	mov	a,#0xbd
      000B85 B5 80 04         [24]  385 	cjne	a,_P0,00123$
                                    386 ;	keylib.c:45: return '7';
      000B88 75 82 37         [24]  387 	mov	dpl, #0x37
      000B8B 22               [24]  388 	ret
      000B8C                        389 00123$:
                                    390 ;	keylib.c:46: } else if (P0 == 0xDD) {
      000B8C 74 DD            [12]  391 	mov	a,#0xdd
      000B8E B5 80 04         [24]  392 	cjne	a,_P0,00120$
                                    393 ;	keylib.c:47: return '8';
      000B91 75 82 38         [24]  394 	mov	dpl, #0x38
      000B94 22               [24]  395 	ret
      000B95                        396 00120$:
                                    397 ;	keylib.c:48: } else if (P0 == 0xED) {
      000B95 74 ED            [12]  398 	mov	a,#0xed
      000B97 B5 80 04         [24]  399 	cjne	a,_P0,00124$
                                    400 ;	keylib.c:49: return '9';
      000B9A 75 82 39         [24]  401 	mov	dpl, #0x39
      000B9D 22               [24]  402 	ret
      000B9E                        403 00124$:
                                    404 ;	keylib.c:52: P0 = 0xFE;
      000B9E 75 80 FE         [24]  405 	mov	_P0,#0xfe
                                    406 ;	keylib.c:53: if (P0 == 0xBE) {
      000BA1 74 BE            [12]  407 	mov	a,#0xbe
      000BA3 B5 80 04         [24]  408 	cjne	a,_P0,00131$
                                    409 ;	keylib.c:54: return '*';
      000BA6 75 82 2A         [24]  410 	mov	dpl, #0x2a
      000BA9 22               [24]  411 	ret
      000BAA                        412 00131$:
                                    413 ;	keylib.c:55: } else if (P0 == 0xDE) {
      000BAA 74 DE            [12]  414 	mov	a,#0xde
      000BAC B5 80 04         [24]  415 	cjne	a,_P0,00128$
                                    416 ;	keylib.c:56: return '0';
      000BAF 75 82 30         [24]  417 	mov	dpl, #0x30
      000BB2 22               [24]  418 	ret
      000BB3                        419 00128$:
                                    420 ;	keylib.c:57: } else if (P0 == 0xEE) {
      000BB3 74 EE            [12]  421 	mov	a,#0xee
      000BB5 B5 80 04         [24]  422 	cjne	a,_P0,00132$
                                    423 ;	keylib.c:58: return '#';
      000BB8 75 82 23         [24]  424 	mov	dpl, #0x23
      000BBB 22               [24]  425 	ret
      000BBC                        426 00132$:
                                    427 ;	keylib.c:61: return '\0';
      000BBC 75 82 00         [24]  428 	mov	dpl, #0x00
                                    429 ;	keylib.c:62: }
      000BBF 22               [24]  430 	ret
                                    431 	.area CSEG    (CODE)
                                    432 	.area CONST   (CODE)
                                    433 	.area XINIT   (CODE)
                                    434 	.area CABS    (ABS,CODE)
