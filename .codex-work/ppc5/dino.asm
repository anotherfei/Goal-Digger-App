;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler
; Version 4.5.0 #15242 (MINGW64)
;--------------------------------------------------------
	.module dino
	
	.optsdcc -mmcs51 --model-small
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _timer0_ISR
	.globl __mcs51_genXRAMCLEAR
	.globl __mcs51_genXINIT
	.globl __mcs51_genRAMCLEAR
	.globl __sdcc_gsinit_startup
	.globl _main
	.globl _GameCtrlTask
	.globl _UpdateGameMap
	.globl _MaybeAddCactus
	.globl _MoveDinoFromKey
	.globl _FrameDelay
	.globl _SmallDelay
	.globl _RenderTask
	.globl _DrawGameRows
	.globl _LoadDinoSymbols
	.globl _LCDWriteUint
	.globl _WriteGameOverText
	.globl _WritePromptText
	.globl _KeypadCtrlTask
	.globl _TakeKeyIfReady
	.globl _TakeKeyBlocking
	.globl _PutKey
	.globl _LCD_ready
	.globl _LCD_write_char
	.globl _LCD_IRWrite
	.globl _LCD_Init
	.globl _AnyKeyPressed
	.globl _KeyToChar
	.globl _Init_Keypad
	.globl _ThreadExit
	.globl _ThreadYield
	.globl _ThreadCreate
	.globl _CY
	.globl _AC
	.globl _F0
	.globl _RS1
	.globl _RS0
	.globl _OV
	.globl _F1
	.globl _P
	.globl _PS
	.globl _PT1
	.globl _PX1
	.globl _PT0
	.globl _PX0
	.globl _RD
	.globl _WR
	.globl _T1
	.globl _T0
	.globl _INT1
	.globl _INT0
	.globl _TXD
	.globl _RXD
	.globl _P3_7
	.globl _P3_6
	.globl _P3_5
	.globl _P3_4
	.globl _P3_3
	.globl _P3_2
	.globl _P3_1
	.globl _P3_0
	.globl _EA
	.globl _ES
	.globl _ET1
	.globl _EX1
	.globl _ET0
	.globl _EX0
	.globl _P2_7
	.globl _P2_6
	.globl _P2_5
	.globl _P2_4
	.globl _P2_3
	.globl _P2_2
	.globl _P2_1
	.globl _P2_0
	.globl _SM0
	.globl _SM1
	.globl _SM2
	.globl _REN
	.globl _TB8
	.globl _RB8
	.globl _TI
	.globl _RI
	.globl _P1_7
	.globl _P1_6
	.globl _P1_5
	.globl _P1_4
	.globl _P1_3
	.globl _P1_2
	.globl _P1_1
	.globl _P1_0
	.globl _TF1
	.globl _TR1
	.globl _TF0
	.globl _TR0
	.globl _IE1
	.globl _IT1
	.globl _IE0
	.globl _IT0
	.globl _P0_7
	.globl _P0_6
	.globl _P0_5
	.globl _P0_4
	.globl _P0_3
	.globl _P0_2
	.globl _P0_1
	.globl _P0_0
	.globl _B
	.globl _ACC
	.globl _PSW
	.globl _IP
	.globl _P3
	.globl _IE
	.globl _P2
	.globl _SBUF
	.globl _SCON
	.globl _P1
	.globl _TH1
	.globl _TH0
	.globl _TL1
	.globl _TL0
	.globl _TMOD
	.globl _TCON
	.globl _PCON
	.globl _DPH
	.globl _DPL
	.globl _SP
	.globl _P0
	.globl _cactusGap
	.globl _difficultyDigit
	.globl _scoreCount
	.globl _cactusRow1
	.globl _cactusRow0
	.globl _playMode
	.globl _dinoRow
	.globl _sceneGate
	.globl _keyStillDown
	.globl _keyPutAt
	.globl _keyTakeAt
	.globl _keyQueue
	.globl _keyRoom
	.globl _keyUsed
	.globl _keyGate
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
	.area RSEG    (ABS,DATA)
	.org 0x0000
_P0	=	0x0080
_SP	=	0x0081
_DPL	=	0x0082
_DPH	=	0x0083
_PCON	=	0x0087
_TCON	=	0x0088
_TMOD	=	0x0089
_TL0	=	0x008a
_TL1	=	0x008b
_TH0	=	0x008c
_TH1	=	0x008d
_P1	=	0x0090
_SCON	=	0x0098
_SBUF	=	0x0099
_P2	=	0x00a0
_IE	=	0x00a8
_P3	=	0x00b0
_IP	=	0x00b8
_PSW	=	0x00d0
_ACC	=	0x00e0
_B	=	0x00f0
;--------------------------------------------------------
; special function bits
;--------------------------------------------------------
	.area RSEG    (ABS,DATA)
	.org 0x0000
_P0_0	=	0x0080
_P0_1	=	0x0081
_P0_2	=	0x0082
_P0_3	=	0x0083
_P0_4	=	0x0084
_P0_5	=	0x0085
_P0_6	=	0x0086
_P0_7	=	0x0087
_IT0	=	0x0088
_IE0	=	0x0089
_IT1	=	0x008a
_IE1	=	0x008b
_TR0	=	0x008c
_TF0	=	0x008d
_TR1	=	0x008e
_TF1	=	0x008f
_P1_0	=	0x0090
_P1_1	=	0x0091
_P1_2	=	0x0092
_P1_3	=	0x0093
_P1_4	=	0x0094
_P1_5	=	0x0095
_P1_6	=	0x0096
_P1_7	=	0x0097
_RI	=	0x0098
_TI	=	0x0099
_RB8	=	0x009a
_TB8	=	0x009b
_REN	=	0x009c
_SM2	=	0x009d
_SM1	=	0x009e
_SM0	=	0x009f
_P2_0	=	0x00a0
_P2_1	=	0x00a1
_P2_2	=	0x00a2
_P2_3	=	0x00a3
_P2_4	=	0x00a4
_P2_5	=	0x00a5
_P2_6	=	0x00a6
_P2_7	=	0x00a7
_EX0	=	0x00a8
_ET0	=	0x00a9
_EX1	=	0x00aa
_ET1	=	0x00ab
_ES	=	0x00ac
_EA	=	0x00af
_P3_0	=	0x00b0
_P3_1	=	0x00b1
_P3_2	=	0x00b2
_P3_3	=	0x00b3
_P3_4	=	0x00b4
_P3_5	=	0x00b5
_P3_6	=	0x00b6
_P3_7	=	0x00b7
_RXD	=	0x00b0
_TXD	=	0x00b1
_INT0	=	0x00b2
_INT1	=	0x00b3
_T0	=	0x00b4
_T1	=	0x00b5
_WR	=	0x00b6
_RD	=	0x00b7
_PX0	=	0x00b8
_PT0	=	0x00b9
_PX1	=	0x00ba
_PT1	=	0x00bb
_PS	=	0x00bc
_P	=	0x00d0
_F1	=	0x00d1
_OV	=	0x00d2
_RS0	=	0x00d3
_RS1	=	0x00d4
_F0	=	0x00d5
_AC	=	0x00d6
_CY	=	0x00d7
;--------------------------------------------------------
; overlayable register banks
;--------------------------------------------------------
	.area REG_BANK_0	(REL,OVR,DATA)
	.ds 8
;--------------------------------------------------------
; internal ram data
;--------------------------------------------------------
	.area DSEG    (DATA)
_keyGate	=	0x0020
_keyUsed	=	0x0021
_keyRoom	=	0x0022
_keyQueue	=	0x0023
_keyTakeAt	=	0x0026
_keyPutAt	=	0x0027
_keyStillDown	=	0x0028
_sceneGate	=	0x0029
_dinoRow	=	0x002a
_playMode	=	0x002b
_cactusRow0	=	0x002c
_cactusRow1	=	0x002e
_scoreCount	=	0x0030
_difficultyDigit	=	0x0032
_cactusGap	=	0x003e
;--------------------------------------------------------
; overlayable items in internal ram
;--------------------------------------------------------
	.area	OSEG    (OVR,DATA)
	.area	OSEG    (OVR,DATA)
	.area	OSEG    (OVR,DATA)
	.area	OSEG    (OVR,DATA)
	.area	OSEG    (OVR,DATA)
;--------------------------------------------------------
; Stack segment in internal ram
;--------------------------------------------------------
	.area SSEG
__start__stack:
	.ds	1

;--------------------------------------------------------
; indirectly addressable internal ram data
;--------------------------------------------------------
	.area ISEG    (DATA)
;--------------------------------------------------------
; absolute internal ram data
;--------------------------------------------------------
	.area IABS    (ABS,DATA)
	.area IABS    (ABS,DATA)
;--------------------------------------------------------
; bit data
;--------------------------------------------------------
	.area BSEG    (BIT)
;--------------------------------------------------------
; paged external ram data
;--------------------------------------------------------
	.area PSEG    (PAG,XDATA)
;--------------------------------------------------------
; uninitialized external ram data
;--------------------------------------------------------
	.area XSEG    (XDATA)
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area XABS    (ABS,XDATA)
;--------------------------------------------------------
; initialized external ram data
;--------------------------------------------------------
	.area XISEG   (XDATA)
	.area HOME    (CODE)
	.area GSINIT0 (CODE)
	.area GSINIT1 (CODE)
	.area GSINIT2 (CODE)
	.area GSINIT3 (CODE)
	.area GSINIT4 (CODE)
	.area GSINIT5 (CODE)
	.area GSINIT  (CODE)
	.area GSFINAL (CODE)
	.area CSEG    (CODE)
;--------------------------------------------------------
; interrupt vector
;--------------------------------------------------------
	.area HOME    (CODE)
__interrupt_vect:
	ljmp	__sdcc_gsinit_startup
	reti
	.ds	7
	ljmp	_timer0_ISR
; restartable atomic support routines
	.ds	2
sdcc_atomic_exchange_rollback_start::
	nop
	nop
sdcc_atomic_exchange_pdata_impl:
	movx	a, @r0
	mov	r3, a
	mov	a, r2
	movx	@r0, a
	sjmp	sdcc_atomic_exchange_exit
	nop
	nop
sdcc_atomic_exchange_xdata_impl:
	movx	a, @dptr
	mov	r3, a
	mov	a, r2
	movx	@dptr, a
	sjmp	sdcc_atomic_exchange_exit
sdcc_atomic_compare_exchange_idata_impl:
	mov	a, @r0
	cjne	a, ar2, .+#5
	mov	a, r3
	mov	@r0, a
	ret
	nop
sdcc_atomic_compare_exchange_pdata_impl:
	movx	a, @r0
	cjne	a, ar2, .+#5
	mov	a, r3
	movx	@r0, a
	ret
	nop
sdcc_atomic_compare_exchange_xdata_impl:
	movx	a, @dptr
	cjne	a, ar2, .+#5
	mov	a, r3
	movx	@dptr, a
	ret
sdcc_atomic_exchange_rollback_end::

sdcc_atomic_exchange_gptr_impl::
	jnb	b.6, sdcc_atomic_exchange_xdata_impl
	mov	r0, dpl
	jb	b.5, sdcc_atomic_exchange_pdata_impl
sdcc_atomic_exchange_idata_impl:
	mov	a, r2
	xch	a, @r0
	mov	dpl, a
	ret
sdcc_atomic_exchange_exit:
	mov	dpl, r3
	ret
sdcc_atomic_compare_exchange_gptr_impl::
	jnb	b.6, sdcc_atomic_compare_exchange_xdata_impl
	mov	r0, dpl
	jb	b.5, sdcc_atomic_compare_exchange_pdata_impl
	sjmp	sdcc_atomic_compare_exchange_idata_impl
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area HOME    (CODE)
	.area GSINIT  (CODE)
	.area GSFINAL (CODE)
	.area GSINIT  (CODE)
	.globl __sdcc_gsinit_startup
	.globl __sdcc_program_startup
	.globl __start__stack
	.globl __mcs51_genXINIT
	.globl __mcs51_genXRAMCLEAR
	.globl __mcs51_genRAMCLEAR
	.area GSFINAL (CODE)
	ljmp	__sdcc_program_startup
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME    (CODE)
	.area HOME    (CODE)
__sdcc_program_startup:
	ljmp	_main
;	return from main will return to caller
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CSEG    (CODE)
;------------------------------------------------------------
;Allocation info for local variables in function 'PutKey'
;------------------------------------------------------------
;c             Allocated to registers r7 
;------------------------------------------------------------
;	dino.c:30: void PutKey(char c)
;	-----------------------------------------
;	 function PutKey
;	-----------------------------------------
_PutKey:
	ar7 = 0x07
	ar6 = 0x06
	ar5 = 0x05
	ar4 = 0x04
	ar3 = 0x03
	ar2 = 0x02
	ar1 = 0x01
	ar0 = 0x00
;	dino.c:32: if (c == '\0') {
	mov	a,dpl
	mov	r7,a
	jnz	00106$
;	dino.c:33: return;
;	dino.c:36: SemaphoreWait(keyRoom);
	ret
00106$:
;	assignBit
	clr	_EA
	mov	a,_keyRoom
	jz	00104$
	dec	_keyRoom
;	assignBit
	setb	_EA
	sjmp	00114$
00104$:
;	assignBit
	setb	_EA
;	dino.c:37: SemaphoreWait(keyGate);
	sjmp	00106$
00114$:
;	assignBit
	clr	_EA
	mov	a,_keyGate
	jz	00112$
	dec	_keyGate
;	assignBit
	setb	_EA
	sjmp	00117$
00112$:
;	assignBit
	setb	_EA
	sjmp	00114$
00117$:
;	dino.c:39: if (keyPutAt == 0) {
	mov	a,_keyPutAt
	jnz	00123$
;	dino.c:40: keyQueue[0] = c;
	mov	_keyQueue,r7
	sjmp	00124$
00123$:
;	dino.c:41: } else if (keyPutAt == 1) {
	mov	a,#0x01
	cjne	a,_keyPutAt,00120$
;	dino.c:42: keyQueue[1] = c;
	mov	(_keyQueue + 0x0001),r7
	sjmp	00124$
00120$:
;	dino.c:44: keyQueue[2] = c;
	mov	(_keyQueue + 0x0002),r7
00124$:
;	dino.c:46: keyPutAt++;
	mov	a,_keyPutAt
	inc	a
	mov	_keyPutAt,a
;	dino.c:47: if (keyPutAt == 3) {
	mov	a,#0x03
	cjne	a,_keyPutAt,00127$
;	dino.c:48: keyPutAt = 0;
	mov	_keyPutAt,#0x00
;	dino.c:51: SemaphoreSignal(keyGate);
00127$:
;	assignBit
	clr	_EA
	inc	_keyGate
;	assignBit
	setb	_EA
;	dino.c:52: SemaphoreSignal(keyUsed);
;	assignBit
	clr	_EA
	inc	_keyUsed
;	assignBit
	setb	_EA
;	dino.c:53: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'TakeKeyBlocking'
;------------------------------------------------------------
;c             Allocated to registers r7 
;------------------------------------------------------------
;	dino.c:55: char TakeKeyBlocking(void)
;	-----------------------------------------
;	 function TakeKeyBlocking
;	-----------------------------------------
_TakeKeyBlocking:
;	dino.c:59: SemaphoreWait(keyUsed);
00104$:
;	assignBit
	clr	_EA
	mov	a,_keyUsed
	jz	00102$
	dec	_keyUsed
;	assignBit
	setb	_EA
	sjmp	00112$
00102$:
;	assignBit
	setb	_EA
;	dino.c:60: SemaphoreWait(keyGate);
	sjmp	00104$
00112$:
;	assignBit
	clr	_EA
	mov	a,_keyGate
	jz	00110$
	dec	_keyGate
;	assignBit
	setb	_EA
	sjmp	00115$
00110$:
;	assignBit
	setb	_EA
	sjmp	00112$
00115$:
;	dino.c:62: c = keyQueue[keyTakeAt];
	mov	a,_keyTakeAt
	add	a, #_keyQueue
	mov	r1,a
	mov	ar7,@r1
;	dino.c:63: keyTakeAt++;
	mov	a,_keyTakeAt
	inc	a
	mov	_keyTakeAt,a
;	dino.c:64: if (keyTakeAt == 3) {
	mov	a,#0x03
	cjne	a,_keyTakeAt,00119$
;	dino.c:65: keyTakeAt = 0;
	mov	_keyTakeAt,#0x00
;	dino.c:68: SemaphoreSignal(keyGate);
00119$:
;	assignBit
	clr	_EA
	inc	_keyGate
;	assignBit
	setb	_EA
;	dino.c:69: SemaphoreSignal(keyRoom);
;	assignBit
	clr	_EA
	inc	_keyRoom
;	assignBit
	setb	_EA
;	dino.c:70: return c;
	mov	dpl, r7
;	dino.c:71: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'TakeKeyIfReady'
;------------------------------------------------------------
;c             Allocated to registers r7 
;------------------------------------------------------------
;	dino.c:73: char TakeKeyIfReady(void)
;	-----------------------------------------
;	 function TakeKeyIfReady
;	-----------------------------------------
_TakeKeyIfReady:
;	dino.c:77: c = '\0';
	mov	r7,#0x00
;	dino.c:78: EA = 0;
;	assignBit
	clr	_EA
;	dino.c:79: if (keyUsed > 0) {
	mov	a,_keyUsed
	jz	00118$
;	dino.c:80: keyUsed--;
	mov	a,_keyUsed
	dec	a
	mov	_keyUsed,a
;	dino.c:81: EA = 1;
;	assignBit
	setb	_EA
;	dino.c:83: SemaphoreWait(keyGate);
00104$:
;	assignBit
	clr	_EA
	mov	a,_keyGate
	jz	00102$
	dec	_keyGate
;	assignBit
	setb	_EA
	sjmp	00107$
00102$:
;	assignBit
	setb	_EA
	sjmp	00104$
00107$:
;	dino.c:84: c = keyQueue[keyTakeAt];
	mov	a,_keyTakeAt
	add	a, #_keyQueue
	mov	r1,a
	mov	ar7,@r1
;	dino.c:85: keyTakeAt++;
	mov	a,_keyTakeAt
	inc	a
	mov	_keyTakeAt,a
;	dino.c:86: if (keyTakeAt == 3) {
	mov	a,#0x03
	cjne	a,_keyTakeAt,00111$
;	dino.c:87: keyTakeAt = 0;
	mov	_keyTakeAt,#0x00
;	dino.c:89: SemaphoreSignal(keyGate);
00111$:
;	assignBit
	clr	_EA
	inc	_keyGate
;	assignBit
	setb	_EA
;	dino.c:90: SemaphoreSignal(keyRoom);
;	assignBit
	clr	_EA
	inc	_keyRoom
;	assignBit
	setb	_EA
	sjmp	00119$
00118$:
;	dino.c:92: EA = 1;
;	assignBit
	setb	_EA
00119$:
;	dino.c:94: return c;
	mov	dpl, r7
;	dino.c:95: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'KeypadCtrlTask'
;------------------------------------------------------------
;nowKey        Allocated to registers 
;------------------------------------------------------------
;	dino.c:97: void KeypadCtrlTask(void)
;	-----------------------------------------
;	 function KeypadCtrlTask
;	-----------------------------------------
_KeypadCtrlTask:
;	dino.c:101: keyStillDown = 0;
	mov	_keyStillDown,#0x00
;	dino.c:102: while (1) {
00107$:
;	dino.c:103: if (AnyKeyPressed()) {
	lcall	_AnyKeyPressed
	mov	a, dpl
	jz	00104$
;	dino.c:104: if (!keyStillDown) {
	mov	a,_keyStillDown
	jnz	00107$
;	dino.c:105: nowKey = KeyToChar();
	lcall	_KeyToChar
;	dino.c:106: PutKey(nowKey);
	lcall	_PutKey
;	dino.c:107: keyStillDown = 1;
	mov	_keyStillDown,#0x01
	sjmp	00107$
00104$:
;	dino.c:110: keyStillDown = 0;
	mov	_keyStillDown,#0x00
;	dino.c:113: }
	sjmp	00107$
;------------------------------------------------------------
;Allocation info for local variables in function 'WritePromptText'
;------------------------------------------------------------
;	dino.c:115: void WritePromptText(void)
;	-----------------------------------------
;	 function WritePromptText
;	-----------------------------------------
_WritePromptText:
;	dino.c:117: LCD_cursorGoTo(0, 0);
	mov	dpl, #0x80
	lcall	_LCD_IRWrite
;	dino.c:118: LCD_write_char('L'); LCD_write_char('e'); LCD_write_char('v'); LCD_write_char('e');
	mov	dpl, #0x4c
	lcall	_LCD_write_char
	mov	dpl, #0x65
	lcall	_LCD_write_char
	mov	dpl, #0x76
	lcall	_LCD_write_char
	mov	dpl, #0x65
	lcall	_LCD_write_char
;	dino.c:119: LCD_write_char('l'); LCD_write_char('?'); LCD_write_char(' '); LCD_write_char('0');
	mov	dpl, #0x6c
	lcall	_LCD_write_char
	mov	dpl, #0x3f
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x30
	lcall	_LCD_write_char
;	dino.c:120: LCD_write_char('-'); LCD_write_char('9'); LCD_write_char(' '); LCD_write_char('t');
	mov	dpl, #0x2d
	lcall	_LCD_write_char
	mov	dpl, #0x39
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x74
	lcall	_LCD_write_char
;	dino.c:121: LCD_write_char('h'); LCD_write_char('e'); LCD_write_char('n'); LCD_write_char('#');
	mov	dpl, #0x68
	lcall	_LCD_write_char
	mov	dpl, #0x65
	lcall	_LCD_write_char
	mov	dpl, #0x6e
	lcall	_LCD_write_char
	mov	dpl, #0x23
	lcall	_LCD_write_char
;	dino.c:123: LCD_cursorGoTo(1, 0);
	mov	dpl, #0xc0
	lcall	_LCD_IRWrite
;	dino.c:124: LCD_write_char('2'); LCD_write_char('='); LCD_write_char('u'); LCD_write_char('p');
	mov	dpl, #0x32
	lcall	_LCD_write_char
	mov	dpl, #0x3d
	lcall	_LCD_write_char
	mov	dpl, #0x75
	lcall	_LCD_write_char
	mov	dpl, #0x70
	lcall	_LCD_write_char
;	dino.c:125: LCD_write_char(' '); LCD_write_char('8'); LCD_write_char('='); LCD_write_char('d');
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x38
	lcall	_LCD_write_char
	mov	dpl, #0x3d
	lcall	_LCD_write_char
	mov	dpl, #0x64
	lcall	_LCD_write_char
;	dino.c:126: LCD_write_char('o'); LCD_write_char('w'); LCD_write_char('n'); LCD_write_char(' ');
	mov	dpl, #0x6f
	lcall	_LCD_write_char
	mov	dpl, #0x77
	lcall	_LCD_write_char
	mov	dpl, #0x6e
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
;	dino.c:127: LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' ');
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x20
;	dino.c:128: }
	ljmp	_LCD_write_char
;------------------------------------------------------------
;Allocation info for local variables in function 'WriteGameOverText'
;------------------------------------------------------------
;	dino.c:130: void WriteGameOverText(void)
;	-----------------------------------------
;	 function WriteGameOverText
;	-----------------------------------------
_WriteGameOverText:
;	dino.c:132: LCD_cursorGoTo(0, 0);
	mov	dpl, #0x80
	lcall	_LCD_IRWrite
;	dino.c:133: LCD_write_char('G'); LCD_write_char('a'); LCD_write_char('m'); LCD_write_char('e');
	mov	dpl, #0x47
	lcall	_LCD_write_char
	mov	dpl, #0x61
	lcall	_LCD_write_char
	mov	dpl, #0x6d
	lcall	_LCD_write_char
	mov	dpl, #0x65
	lcall	_LCD_write_char
;	dino.c:134: LCD_write_char(' '); LCD_write_char('o'); LCD_write_char('v'); LCD_write_char('e');
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x6f
	lcall	_LCD_write_char
	mov	dpl, #0x76
	lcall	_LCD_write_char
	mov	dpl, #0x65
	lcall	_LCD_write_char
;	dino.c:135: LCD_write_char('r'); LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' ');
	mov	dpl, #0x72
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
;	dino.c:136: LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' ');
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
	mov	dpl, #0x20
	lcall	_LCD_write_char
;	dino.c:138: LCD_cursorGoTo(1, 0);
	mov	dpl, #0xc0
	lcall	_LCD_IRWrite
;	dino.c:139: LCD_write_char('S'); LCD_write_char('c'); LCD_write_char('o'); LCD_write_char('r');
	mov	dpl, #0x53
	lcall	_LCD_write_char
	mov	dpl, #0x63
	lcall	_LCD_write_char
	mov	dpl, #0x6f
	lcall	_LCD_write_char
	mov	dpl, #0x72
	lcall	_LCD_write_char
;	dino.c:140: LCD_write_char('e'); LCD_write_char(':'); LCD_write_char(' ');
	mov	dpl, #0x65
	lcall	_LCD_write_char
	mov	dpl, #0x3a
	lcall	_LCD_write_char
	mov	dpl, #0x20
;	dino.c:141: }
	ljmp	_LCD_write_char
;------------------------------------------------------------
;Allocation info for local variables in function 'LCDWriteUint'
;------------------------------------------------------------
;value         Allocated to registers r6 r7 
;started       Allocated to registers r5 
;------------------------------------------------------------
;	dino.c:143: void LCDWriteUint(unsigned int value)
;	-----------------------------------------
;	 function LCDWriteUint
;	-----------------------------------------
_LCDWriteUint:
	mov	r6, dpl
	mov	r7, dph
;	dino.c:147: started = 0;
	mov	r5,#0x00
;	dino.c:148: if (value >= 10000) {
	clr	c
	mov	a,r6
	subb	a,#0x10
	mov	a,r7
	subb	a,#0x27
	jc	00102$
;	dino.c:149: LCD_write_char('0' + (value / 10000));
	mov	__divuint_PARM_2,#0x10
	mov	(__divuint_PARM_2 + 1),#0x27
	mov	dpl, r6
	mov	dph, r7
	push	ar7
	push	ar6
	lcall	__divuint
	mov	r3, dpl
	mov	a,#0x30
	add	a, r3
	mov	dpl,a
	lcall	_LCD_write_char
	pop	ar6
	pop	ar7
;	dino.c:150: value = value % 10000;
	mov	__moduint_PARM_2,#0x10
	mov	(__moduint_PARM_2 + 1),#0x27
;	dino.c:151: started = 1;
	mov	dpl, r6
	mov	dph, r7
	lcall	__moduint
	mov	r6, dpl
	mov	r7, dph
	mov	r5,#0x01
00102$:
;	dino.c:153: if (started || value >= 1000) {
	mov	a,r5
	jnz	00103$
	clr	c
	mov	a,r6
	subb	a,#0xe8
	mov	a,r7
	subb	a,#0x03
	jc	00104$
00103$:
;	dino.c:154: LCD_write_char('0' + (value / 1000));
	mov	__divuint_PARM_2,#0xe8
	mov	(__divuint_PARM_2 + 1),#0x03
	mov	dpl, r6
	mov	dph, r7
	push	ar7
	push	ar6
	lcall	__divuint
	mov	r3, dpl
	mov	a,#0x30
	add	a, r3
	mov	dpl,a
	lcall	_LCD_write_char
	pop	ar6
	pop	ar7
;	dino.c:155: value = value % 1000;
	mov	__moduint_PARM_2,#0xe8
	mov	(__moduint_PARM_2 + 1),#0x03
;	dino.c:156: started = 1;
	mov	dpl, r6
	mov	dph, r7
	lcall	__moduint
	mov	r6, dpl
	mov	r7, dph
	mov	r5,#0x01
00104$:
;	dino.c:158: if (started || value >= 100) {
	mov	a,r5
	jnz	00106$
	clr	c
	mov	a,r6
	subb	a,#0x64
	mov	a,r7
	subb	a,#0x00
	jc	00107$
00106$:
;	dino.c:159: LCD_write_char('0' + (value / 100));
	mov	__divuint_PARM_2,#0x64
	mov	(__divuint_PARM_2 + 1),#0x00
	mov	dpl, r6
	mov	dph, r7
	push	ar7
	push	ar6
	lcall	__divuint
	mov	r3, dpl
	mov	a,#0x30
	add	a, r3
	mov	dpl,a
	lcall	_LCD_write_char
	pop	ar6
	pop	ar7
;	dino.c:160: value = value % 100;
	mov	__moduint_PARM_2,#0x64
	mov	(__moduint_PARM_2 + 1),#0x00
;	dino.c:161: started = 1;
	mov	dpl, r6
	mov	dph, r7
	lcall	__moduint
	mov	r6, dpl
	mov	r7, dph
	mov	r5,#0x01
00107$:
;	dino.c:163: if (started || value >= 10) {
	mov	a,r5
	jnz	00109$
	clr	c
	mov	a,r6
	subb	a,#0x0a
	mov	a,r7
	subb	a,#0x00
	jc	00110$
00109$:
;	dino.c:164: LCD_write_char('0' + (value / 10));
	mov	ar5,r6
	mov	b,#0x0a
	mov	a,r5
	div	ab
	add	a,#0x30
	mov	dpl,a
	push	ar7
	push	ar6
	lcall	_LCD_write_char
	pop	ar6
	pop	ar7
;	dino.c:165: value = value % 10;
	mov	ar5,r6
	mov	b,#0x0a
	mov	a,r5
	div	ab
	mov	r5,b
	mov	ar6,r5
00110$:
;	dino.c:167: LCD_write_char('0' + value);
	mov	a,#0x30
	add	a, r6
	mov	dpl,a
;	dino.c:168: }
	ljmp	_LCD_write_char
;------------------------------------------------------------
;Allocation info for local variables in function 'LoadDinoSymbols'
;------------------------------------------------------------
;	dino.c:170: void LoadDinoSymbols(void)
;	-----------------------------------------
;	 function LoadDinoSymbols
;	-----------------------------------------
_LoadDinoSymbols:
;	dino.c:172: LCD_setCgRamAddress(0x08);
	mov	dpl, #0x48
	lcall	_LCD_IRWrite
;	dino.c:173: LCD_write_char(0x07); LCD_write_char(0x05); LCD_write_char(0x06); LCD_write_char(0x07);
	mov	dpl, #0x07
	lcall	_LCD_write_char
	mov	dpl, #0x05
	lcall	_LCD_write_char
	mov	dpl, #0x06
	lcall	_LCD_write_char
	mov	dpl, #0x07
	lcall	_LCD_write_char
;	dino.c:174: LCD_write_char(0x14); LCD_write_char(0x17); LCD_write_char(0x0E); LCD_write_char(0x0A);
	mov	dpl, #0x14
	lcall	_LCD_write_char
	mov	dpl, #0x17
	lcall	_LCD_write_char
	mov	dpl, #0x0e
	lcall	_LCD_write_char
	mov	dpl, #0x0a
	lcall	_LCD_write_char
;	dino.c:176: LCD_setCgRamAddress(0x10);
	mov	dpl, #0x50
	lcall	_LCD_IRWrite
;	dino.c:177: LCD_write_char(0x04); LCD_write_char(0x05); LCD_write_char(0x15); LCD_write_char(0x15);
	mov	dpl, #0x04
	lcall	_LCD_write_char
	mov	dpl, #0x05
	lcall	_LCD_write_char
	mov	dpl, #0x15
	lcall	_LCD_write_char
	mov	dpl, #0x15
	lcall	_LCD_write_char
;	dino.c:178: LCD_write_char(0x16); LCD_write_char(0x0C); LCD_write_char(0x04); LCD_write_char(0x04);
	mov	dpl, #0x16
	lcall	_LCD_write_char
	mov	dpl, #0x0c
	lcall	_LCD_write_char
	mov	dpl, #0x04
	lcall	_LCD_write_char
	mov	dpl, #0x04
;	dino.c:179: }
	ljmp	_LCD_write_char
;------------------------------------------------------------
;Allocation info for local variables in function 'DrawGameRows'
;------------------------------------------------------------
;	dino.c:190: void DrawGameRows(void)
;	-----------------------------------------
;	 function DrawGameRows
;	-----------------------------------------
_DrawGameRows:
;	dino.c:192: LCD_cursorGoTo(0, 0);
	mov	dpl, #0x80
	lcall	_LCD_IRWrite
;	dino.c:193: if (dinoRow == 0) {
	mov	a,_dinoRow
	jnz	00104$
;	dino.c:194: LCD_write_char(DINO_SYMBOL);
	mov	dpl, #0x01
	lcall	_LCD_write_char
;	dino.c:196: DrawCactusCell(cactusRow0, 0x0001);
	sjmp	00113$
00104$:
	mov	a,_cactusRow0
	jnb	acc.0,00102$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00113$
00102$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
;	dino.c:198: DrawCactusCell(cactusRow0, 0x0002);
00113$:
	mov	a,_cactusRow0
	jnb	acc.1,00111$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00114$
00111$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00114$:
;	dino.c:199: DrawCactusCell(cactusRow0, 0x0004);
	mov	a,_cactusRow0
	jnb	acc.2,00117$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00120$
00117$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00120$:
;	dino.c:200: DrawCactusCell(cactusRow0, 0x0008);
	mov	a,_cactusRow0
	jnb	acc.3,00123$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00126$
00123$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00126$:
;	dino.c:201: DrawCactusCell(cactusRow0, 0x0010);
	mov	a,_cactusRow0
	jnb	acc.4,00129$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00132$
00129$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00132$:
;	dino.c:202: DrawCactusCell(cactusRow0, 0x0020);
	mov	a,_cactusRow0
	jnb	acc.5,00135$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00138$
00135$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00138$:
;	dino.c:203: DrawCactusCell(cactusRow0, 0x0040);
	mov	a,_cactusRow0
	jnb	acc.6,00141$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00144$
00141$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00144$:
;	dino.c:204: DrawCactusCell(cactusRow0, 0x0080);
	mov	a,_cactusRow0
	jnb	acc.7,00147$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00150$
00147$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00150$:
;	dino.c:205: DrawCactusCell(cactusRow0, 0x0100);
	mov	a,(_cactusRow0 + 1)
	jnb	acc.0,00153$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00156$
00153$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00156$:
;	dino.c:206: DrawCactusCell(cactusRow0, 0x0200);
	mov	a,(_cactusRow0 + 1)
	jnb	acc.1,00159$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00162$
00159$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00162$:
;	dino.c:207: DrawCactusCell(cactusRow0, 0x0400);
	mov	a,(_cactusRow0 + 1)
	jnb	acc.2,00165$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00168$
00165$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00168$:
;	dino.c:208: DrawCactusCell(cactusRow0, 0x0800);
	mov	a,(_cactusRow0 + 1)
	jnb	acc.3,00171$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00174$
00171$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00174$:
;	dino.c:209: DrawCactusCell(cactusRow0, 0x1000);
	mov	a,(_cactusRow0 + 1)
	jnb	acc.4,00177$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00180$
00177$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00180$:
;	dino.c:210: DrawCactusCell(cactusRow0, 0x2000);
	mov	a,(_cactusRow0 + 1)
	jnb	acc.5,00183$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00186$
00183$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00186$:
;	dino.c:211: DrawCactusCell(cactusRow0, 0x4000);
	mov	a,(_cactusRow0 + 1)
	jnb	acc.6,00189$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00192$
00189$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00192$:
;	dino.c:212: DrawCactusCell(cactusRow0, 0x8000);
	mov	a,(_cactusRow0 + 1)
	jnb	acc.7,00195$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00198$
00195$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00198$:
;	dino.c:214: LCD_cursorGoTo(1, 0);
	mov	dpl, #0xc0
	lcall	_LCD_IRWrite
;	dino.c:215: if (dinoRow == 1) {
	mov	a,#0x01
	cjne	a,_dinoRow,00203$
;	dino.c:216: LCD_write_char(DINO_SYMBOL);
	mov	dpl, #0x01
	lcall	_LCD_write_char
;	dino.c:218: DrawCactusCell(cactusRow1, 0x0001);
	sjmp	00212$
00203$:
	mov	a,_cactusRow1
	jnb	acc.0,00201$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00212$
00201$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
;	dino.c:220: DrawCactusCell(cactusRow1, 0x0002);
00212$:
	mov	a,_cactusRow1
	jnb	acc.1,00210$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00213$
00210$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00213$:
;	dino.c:221: DrawCactusCell(cactusRow1, 0x0004);
	mov	a,_cactusRow1
	jnb	acc.2,00216$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00219$
00216$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00219$:
;	dino.c:222: DrawCactusCell(cactusRow1, 0x0008);
	mov	a,_cactusRow1
	jnb	acc.3,00222$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00225$
00222$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00225$:
;	dino.c:223: DrawCactusCell(cactusRow1, 0x0010);
	mov	a,_cactusRow1
	jnb	acc.4,00228$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00231$
00228$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00231$:
;	dino.c:224: DrawCactusCell(cactusRow1, 0x0020);
	mov	a,_cactusRow1
	jnb	acc.5,00234$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00237$
00234$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00237$:
;	dino.c:225: DrawCactusCell(cactusRow1, 0x0040);
	mov	a,_cactusRow1
	jnb	acc.6,00240$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00243$
00240$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00243$:
;	dino.c:226: DrawCactusCell(cactusRow1, 0x0080);
	mov	a,_cactusRow1
	jnb	acc.7,00246$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00249$
00246$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00249$:
;	dino.c:227: DrawCactusCell(cactusRow1, 0x0100);
	mov	a,(_cactusRow1 + 1)
	jnb	acc.0,00252$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00255$
00252$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00255$:
;	dino.c:228: DrawCactusCell(cactusRow1, 0x0200);
	mov	a,(_cactusRow1 + 1)
	jnb	acc.1,00258$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00261$
00258$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00261$:
;	dino.c:229: DrawCactusCell(cactusRow1, 0x0400);
	mov	a,(_cactusRow1 + 1)
	jnb	acc.2,00264$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00267$
00264$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00267$:
;	dino.c:230: DrawCactusCell(cactusRow1, 0x0800);
	mov	a,(_cactusRow1 + 1)
	jnb	acc.3,00270$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00273$
00270$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00273$:
;	dino.c:231: DrawCactusCell(cactusRow1, 0x1000);
	mov	a,(_cactusRow1 + 1)
	jnb	acc.4,00276$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00279$
00276$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00279$:
;	dino.c:232: DrawCactusCell(cactusRow1, 0x2000);
	mov	a,(_cactusRow1 + 1)
	jnb	acc.5,00282$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00285$
00282$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00285$:
;	dino.c:233: DrawCactusCell(cactusRow1, 0x4000);
	mov	a,(_cactusRow1 + 1)
	jnb	acc.6,00288$
	mov	dpl, #0x02
	lcall	_LCD_write_char
	sjmp	00291$
00288$:
	mov	dpl, #0x20
	lcall	_LCD_write_char
00291$:
;	dino.c:234: DrawCactusCell(cactusRow1, 0x8000);
	mov	a,(_cactusRow1 + 1)
	jnb	acc.7,00294$
	mov	dpl, #0x02
	ljmp	_LCD_write_char
00294$:
	mov	dpl, #0x20
;	dino.c:235: }
	ljmp	_LCD_write_char
;------------------------------------------------------------
;Allocation info for local variables in function 'RenderTask'
;------------------------------------------------------------
;lastMode      Allocated to registers r7 
;------------------------------------------------------------
;	dino.c:237: void RenderTask(void)
;	-----------------------------------------
;	 function RenderTask
;	-----------------------------------------
_RenderTask:
;	dino.c:241: LCD_Init();
	lcall	_LCD_Init
;	dino.c:242: while (!LCD_ready()) { }
00101$:
	lcall	_LCD_ready
	mov	a, dpl
	jz	00101$
;	dino.c:243: LoadDinoSymbols();
	lcall	_LoadDinoSymbols
;	dino.c:244: LCD_clearScreen();
	mov	dpl, #0x01
	lcall	_LCD_IRWrite
;	dino.c:245: lastMode = 3;
	mov	r7,#0x03
;	dino.c:247: while (1) {
00124$:
;	dino.c:248: if (playMode == 2) {
	mov	a,#0x02
	cjne	a,_playMode,00121$
;	dino.c:249: if (lastMode != 2) {
	cjne	r7,#0x02,00173$
	sjmp	00105$
00173$:
;	dino.c:250: LCD_clearScreen();
	mov	dpl, #0x01
	lcall	_LCD_IRWrite
;	dino.c:251: WritePromptText();
	lcall	_WritePromptText
;	dino.c:252: lastMode = 2;
	mov	r7,#0x02
00105$:
;	dino.c:254: ThreadYield();
	push	ar7
	lcall	_ThreadYield
	pop	ar7
	sjmp	00124$
00121$:
;	dino.c:255: } else if (playMode == 1) {
	mov	a,#0x01
	cjne	a,_playMode,00118$
;	dino.c:256: SemaphoreWait(sceneGate);
00109$:
;	assignBit
	clr	_EA
	mov	a,_sceneGate
	jz	00107$
	dec	_sceneGate
;	assignBit
	setb	_EA
	sjmp	00112$
00107$:
;	assignBit
	setb	_EA
	sjmp	00109$
00112$:
;	dino.c:257: DrawGameRows();
	lcall	_DrawGameRows
;	dino.c:258: SemaphoreSignal(sceneGate);
;	assignBit
	clr	_EA
	inc	_sceneGate
;	assignBit
	setb	_EA
;	dino.c:259: lastMode = 1;
	mov	r7,#0x01
;	dino.c:260: ThreadYield();
	push	ar7
	lcall	_ThreadYield
	pop	ar7
	sjmp	00124$
00118$:
;	dino.c:262: lastMode = 0;
	mov	r7,#0x00
;	dino.c:263: ThreadYield();
	push	ar7
	lcall	_ThreadYield
	pop	ar7
;	dino.c:266: }
	sjmp	00124$
;------------------------------------------------------------
;Allocation info for local variables in function 'SmallDelay'
;------------------------------------------------------------
;count         Allocated to registers 
;------------------------------------------------------------
;	dino.c:268: void SmallDelay(unsigned char count)
;	-----------------------------------------
;	 function SmallDelay
;	-----------------------------------------
_SmallDelay:
;	dino.c:274: __endasm;
dino_wait_loop:
	djnz	dpl, dino_wait_loop
;	dino.c:275: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'FrameDelay'
;------------------------------------------------------------
;rounds        Allocated to registers 
;------------------------------------------------------------
;	dino.c:277: void FrameDelay(void)
;	-----------------------------------------
;	 function FrameDelay
;	-----------------------------------------
_FrameDelay:
;	dino.c:281: rounds = 18 - difficultyDigit;
	mov	r7,_difficultyDigit
	mov	a,#0x12
	clr	c
	subb	a,r7
	mov	r7,a
;	dino.c:282: while (rounds > 0) {
00101$:
	mov	a,r7
	jz	00104$
;	dino.c:283: SmallDelay(255);
	mov	dpl, #0xff
	push	ar7
	lcall	_SmallDelay
	pop	ar7
;	dino.c:284: rounds--;
	dec	r7
	sjmp	00101$
00104$:
;	dino.c:286: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'MoveDinoFromKey'
;------------------------------------------------------------
;c             Allocated to registers r7 
;------------------------------------------------------------
;	dino.c:288: void MoveDinoFromKey(char c)
;	-----------------------------------------
;	 function MoveDinoFromKey
;	-----------------------------------------
_MoveDinoFromKey:
	mov	r7, dpl
;	dino.c:290: if (c == '2') {
	cjne	r7,#0x32,00104$
;	dino.c:291: dinoRow = 0;
	mov	_dinoRow,#0x00
	ret
00104$:
;	dino.c:292: } else if (c == '8') {
	cjne	r7,#0x38,00106$
;	dino.c:293: dinoRow = 1;
	mov	_dinoRow,#0x01
00106$:
;	dino.c:295: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'MaybeAddCactus'
;------------------------------------------------------------
;	dino.c:297: void MaybeAddCactus(void)
;	-----------------------------------------
;	 function MaybeAddCactus
;	-----------------------------------------
_MaybeAddCactus:
;	dino.c:299: if (cactusGap < 4) {
	mov	a,#0x100 - 0x04
	add	a,_cactusGap
	jc	00102$
;	dino.c:300: cactusGap++;
	mov	a,_cactusGap
	inc	a
	mov	_cactusGap,a
;	dino.c:301: return;
	ret
00102$:
;	dino.c:304: if (((cactusRow0 | cactusRow1) & 0xC000) != 0) {
	mov	a,_cactusRow1
	orl	a,_cactusRow0
	mov	a,(_cactusRow1 + 1)
	orl	a,(_cactusRow0 + 1)
	anl	a,#0xc0
	jz	00104$
;	dino.c:305: return;
	ret
00104$:
;	dino.c:308: if ((scoreCount + difficultyDigit) & 1) {
	mov	r7,_difficultyDigit
	mov	r6,#0x00
	mov	a,r7
	add	a, _scoreCount
	mov	r7,a
	mov	a,r6
	addc	a, (_scoreCount + 1)
	mov	a,r7
	jnb	acc.0,00106$
;	dino.c:309: cactusRow0 |= RIGHT_EDGE;
	mov	a,_cactusRow0
	orl	(_cactusRow0 + 1),#0x80
	sjmp	00107$
00106$:
;	dino.c:311: cactusRow1 |= RIGHT_EDGE;
	mov	a,_cactusRow1
	orl	(_cactusRow1 + 1),#0x80
00107$:
;	dino.c:313: cactusGap = 0;
	mov	_cactusGap,#0x00
;	dino.c:314: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'UpdateGameMap'
;------------------------------------------------------------
;	dino.c:316: void UpdateGameMap(void)
;	-----------------------------------------
;	 function UpdateGameMap
;	-----------------------------------------
_UpdateGameMap:
;	dino.c:318: if ((dinoRow == 0) && (cactusRow0 & LEFT_EDGE)) {
	mov	a,_dinoRow
	jnz	00102$
	mov	a,_cactusRow0
	jnb	acc.0,00102$
;	dino.c:319: playMode = 0;
	mov	_playMode,#0x00
;	dino.c:320: return;
	ret
00102$:
;	dino.c:322: if ((dinoRow == 1) && (cactusRow1 & LEFT_EDGE)) {
	mov	a,#0x01
	cjne	a,_dinoRow,00105$
	mov	a,_cactusRow1
	jnb	acc.0,00105$
;	dino.c:323: playMode = 0;
	mov	_playMode,#0x00
;	dino.c:324: return;
	ret
00105$:
;	dino.c:327: if ((cactusRow0 | cactusRow1) & LEFT_EDGE) {
	mov	a,_cactusRow1
	orl	a,_cactusRow0
	mov	r6,a
	mov	a,(_cactusRow1 + 1)
	orl	a,(_cactusRow0 + 1)
	mov	a,r6
	jnb	acc.0,00108$
;	dino.c:328: scoreCount++;
	mov	r6,_scoreCount
	mov	r7,(_scoreCount + 1)
	mov	a,#0x01
	add	a, r6
	mov	_scoreCount,a
	clr	a
	addc	a, r7
	mov	(_scoreCount + 1),a
00108$:
;	dino.c:331: cactusRow0 = cactusRow0 >> 1;
	mov	a,(_cactusRow0 + 1)
	clr	c
	rrc	a
	xch	a,_cactusRow0
	rrc	a
	xch	a,_cactusRow0
	mov	(_cactusRow0 + 1),a
;	dino.c:332: cactusRow1 = cactusRow1 >> 1;
	mov	a,(_cactusRow1 + 1)
	clr	c
	rrc	a
	xch	a,_cactusRow1
	rrc	a
	xch	a,_cactusRow1
	mov	(_cactusRow1 + 1),a
;	dino.c:333: MaybeAddCactus();
;	dino.c:334: }
	ljmp	_MaybeAddCactus
;------------------------------------------------------------
;Allocation info for local variables in function 'GameCtrlTask'
;------------------------------------------------------------
;c             Allocated to registers r7 
;------------------------------------------------------------
;	dino.c:336: void GameCtrlTask(void)
;	-----------------------------------------
;	 function GameCtrlTask
;	-----------------------------------------
_GameCtrlTask:
;	dino.c:340: difficultyDigit = 0;
	mov	_difficultyDigit,#0x00
;	dino.c:341: playMode = 2;
	mov	_playMode,#0x02
;	dino.c:343: while (1) {
00108$:
;	dino.c:344: c = TakeKeyBlocking();
	lcall	_TakeKeyBlocking
	mov	r7, dpl
;	dino.c:345: if ((c >= '0') && (c <= '9')) {
	cjne	r7,#0x30,00225$
00225$:
	jc	00104$
	mov	a,r7
	add	a,#0xff - 0x39
	jc	00104$
;	dino.c:346: difficultyDigit = c - '0';
	mov	ar6,r7
	mov	a,r6
	add	a,#0xd0
	mov	_difficultyDigit,a
	sjmp	00108$
00104$:
;	dino.c:347: } else if (c == '#') {
	cjne	r7,#0x23,00108$
;	dino.c:352: SemaphoreWait(sceneGate);
00113$:
;	assignBit
	clr	_EA
	mov	a,_sceneGate
	jz	00111$
	dec	_sceneGate
;	assignBit
	setb	_EA
	sjmp	00116$
00111$:
;	assignBit
	setb	_EA
	sjmp	00113$
00116$:
;	dino.c:353: dinoRow = 1;
	mov	_dinoRow,#0x01
;	dino.c:354: cactusRow0 = 0;
	clr	a
	mov	_cactusRow0,a
	mov	(_cactusRow0 + 1),a
;	dino.c:355: cactusRow1 = 0;
	mov	_cactusRow1,a
	mov	(_cactusRow1 + 1),a
;	dino.c:356: scoreCount = 0;
	mov	_scoreCount,a
	mov	(_scoreCount + 1),a
;	dino.c:357: cactusGap = 4;
	mov	_cactusGap,#0x04
;	dino.c:358: playMode = 1;
	mov	_playMode,#0x01
;	dino.c:359: SemaphoreSignal(sceneGate);
;	assignBit
	clr	_EA
	inc	_sceneGate
;	assignBit
	setb	_EA
;	dino.c:361: while (playMode == 1) {
00132$:
	mov	a,#0x01
	cjne	a,_playMode,00138$
;	dino.c:362: c = TakeKeyIfReady();
	lcall	_TakeKeyIfReady
	mov	r7, dpl
;	dino.c:363: SemaphoreWait(sceneGate);
00124$:
;	assignBit
	clr	_EA
	mov	a,_sceneGate
	jz	00122$
	dec	_sceneGate
;	assignBit
	setb	_EA
	sjmp	00127$
00122$:
;	assignBit
	setb	_EA
	sjmp	00124$
00127$:
;	dino.c:364: MoveDinoFromKey(c);
	mov	dpl, r7
	lcall	_MoveDinoFromKey
;	dino.c:365: UpdateGameMap();
	lcall	_UpdateGameMap
;	dino.c:366: SemaphoreSignal(sceneGate);
;	assignBit
	clr	_EA
	inc	_sceneGate
;	assignBit
	setb	_EA
;	dino.c:367: FrameDelay();
	lcall	_FrameDelay
;	dino.c:370: SemaphoreWait(sceneGate);
	sjmp	00132$
00138$:
;	assignBit
	clr	_EA
	mov	a,_sceneGate
	jz	00136$
	dec	_sceneGate
;	assignBit
	setb	_EA
	sjmp	00141$
00136$:
;	assignBit
	setb	_EA
	sjmp	00138$
00141$:
;	dino.c:371: LCD_clearScreen();
	mov	dpl, #0x01
	lcall	_LCD_IRWrite
;	dino.c:372: WriteGameOverText();
	lcall	_WriteGameOverText
;	dino.c:373: LCDWriteUint(scoreCount);
	mov	dpl, _scoreCount
	mov	dph, (_scoreCount + 1)
	lcall	_LCDWriteUint
;	dino.c:374: SemaphoreSignal(sceneGate);
;	assignBit
	clr	_EA
	inc	_sceneGate
;	assignBit
	setb	_EA
;	dino.c:375: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;	dino.c:377: void main(void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	dino.c:379: keyTakeAt = 0;
	mov	_keyTakeAt,#0x00
;	dino.c:380: keyPutAt = 0;
	mov	_keyPutAt,#0x00
;	dino.c:381: keyQueue[0] = 0;
	mov	_keyQueue,#0x00
;	dino.c:382: keyQueue[1] = 0;
	mov	(_keyQueue + 0x0001),#0x00
;	dino.c:383: keyQueue[2] = 0;
	mov	(_keyQueue + 0x0002),#0x00
;	dino.c:384: keyStillDown = 0;
	mov	_keyStillDown,#0x00
;	dino.c:386: dinoRow = 1;
	mov	_dinoRow,#0x01
;	dino.c:387: playMode = 2;
	mov	_playMode,#0x02
;	dino.c:388: cactusRow0 = 0;
	clr	a
	mov	_cactusRow0,a
	mov	(_cactusRow0 + 1),a
;	dino.c:389: cactusRow1 = 0;
	mov	_cactusRow1,a
	mov	(_cactusRow1 + 1),a
;	dino.c:390: scoreCount = 0;
	mov	_scoreCount,a
	mov	(_scoreCount + 1),a
;	dino.c:391: difficultyDigit = 0;
	mov	_difficultyDigit,a
;	dino.c:392: cactusGap = 0;
	mov	_cactusGap,a
;	dino.c:394: SemaphoreCreate(keyGate, 1);
	mov	_keyGate,#0x01
;	dino.c:395: SemaphoreCreate(keyUsed, 0);
	mov	_keyUsed,a
;	dino.c:396: SemaphoreCreate(keyRoom, 3);
	mov	_keyRoom,#0x03
;	dino.c:397: SemaphoreCreate(sceneGate, 1);
	mov	_sceneGate,#0x01
;	dino.c:399: Init_Keypad();
	lcall	_Init_Keypad
;	dino.c:401: ThreadCreate(KeypadCtrlTask);
	mov	dptr,#_KeypadCtrlTask
	lcall	_ThreadCreate
;	dino.c:402: ThreadCreate(RenderTask);
	mov	dptr,#_RenderTask
	lcall	_ThreadCreate
;	dino.c:403: GameCtrlTask();
	lcall	_GameCtrlTask
;	dino.c:404: ThreadExit();
;	dino.c:405: }
	ljmp	_ThreadExit
;------------------------------------------------------------
;Allocation info for local variables in function '_sdcc_gsinit_startup'
;------------------------------------------------------------
;	dino.c:407: void _sdcc_gsinit_startup(void)
;	-----------------------------------------
;	 function _sdcc_gsinit_startup
;	-----------------------------------------
__sdcc_gsinit_startup:
;	dino.c:411: __endasm;
	LJMP	_Bootstrap
;	dino.c:412: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_mcs51_genRAMCLEAR'
;------------------------------------------------------------
;	dino.c:414: void _mcs51_genRAMCLEAR(void) { }
;	-----------------------------------------
;	 function _mcs51_genRAMCLEAR
;	-----------------------------------------
__mcs51_genRAMCLEAR:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_mcs51_genXINIT'
;------------------------------------------------------------
;	dino.c:415: void _mcs51_genXINIT(void) { }
;	-----------------------------------------
;	 function _mcs51_genXINIT
;	-----------------------------------------
__mcs51_genXINIT:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_mcs51_genXRAMCLEAR'
;------------------------------------------------------------
;	dino.c:416: void _mcs51_genXRAMCLEAR(void) { }
;	-----------------------------------------
;	 function _mcs51_genXRAMCLEAR
;	-----------------------------------------
__mcs51_genXRAMCLEAR:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'timer0_ISR'
;------------------------------------------------------------
;	dino.c:418: void timer0_ISR(void) __interrupt(1)
;	-----------------------------------------
;	 function timer0_ISR
;	-----------------------------------------
_timer0_ISR:
;	dino.c:422: __endasm;
	LJMP	_myTimer0Handler
;	dino.c:423: }
	ljmp	sdcc_atomic_maybe_rollback
;	eliminated unneeded mov psw,# (no regs used in bank)
;	eliminated unneeded push/pop not_psw
;	eliminated unneeded push/pop dpl
;	eliminated unneeded push/pop dph
;	eliminated unneeded push/pop b
;	eliminated unneeded push/pop acc
	.area CSEG    (CODE)
	.area CONST   (CODE)
	.area XINIT   (CODE)
	.area CABS    (ABS,CODE)
