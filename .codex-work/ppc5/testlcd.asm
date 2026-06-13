;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler
; Version 4.5.0 #15242 (MINGW64)
;--------------------------------------------------------
	.module testlcd
	
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
	.globl _LcdDrainTask
	.globl _KeyPipeTask
	.globl _ButtonPipeTask
	.globl _PushInputChar
	.globl _LCD_ready
	.globl _LCD_write_char
	.globl _LCD_IRWrite
	.globl _LCD_Init
	.globl _AnyKeyPressed
	.globl _KeyToChar
	.globl _Init_Keypad
	.globl _ButtonToChar
	.globl _AnyButtonPressed
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
	.globl _lcdCharOut
	.globl _keypadPick
	.globl _buttonPick
	.globl _keypadWasDown
	.globl _buttonWasDown
	.globl _queueWriteAt
	.globl _queueReadAt
	.globl _inputQueue
	.globl _openCells
	.globl _usedCells
	.globl _queueGate
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
_queueGate	=	0x0020
_usedCells	=	0x0021
_openCells	=	0x0022
_inputQueue	=	0x0023
_queueReadAt	=	0x0026
_queueWriteAt	=	0x0027
_buttonWasDown	=	0x0028
_keypadWasDown	=	0x0029
_buttonPick	=	0x002a
_keypadPick	=	0x002b
_lcdCharOut	=	0x002c
;--------------------------------------------------------
; overlayable items in internal ram
;--------------------------------------------------------
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
;Allocation info for local variables in function 'PushInputChar'
;------------------------------------------------------------
;c             Allocated to registers r7 
;------------------------------------------------------------
;	testlcd.c:24: void PushInputChar(char c)
;	-----------------------------------------
;	 function PushInputChar
;	-----------------------------------------
_PushInputChar:
	ar7 = 0x07
	ar6 = 0x06
	ar5 = 0x05
	ar4 = 0x04
	ar3 = 0x03
	ar2 = 0x02
	ar1 = 0x01
	ar0 = 0x00
;	testlcd.c:26: if (c == '\0') {
	mov	a,dpl
	mov	r7,a
	jnz	00106$
;	testlcd.c:27: return;
;	testlcd.c:30: SemaphoreWait(openCells);
	ret
00106$:
;	assignBit
	clr	_EA
	mov	a,_openCells
	jz	00104$
	dec	_openCells
;	assignBit
	setb	_EA
	sjmp	00114$
00104$:
;	assignBit
	setb	_EA
;	testlcd.c:31: SemaphoreWait(queueGate);
	sjmp	00106$
00114$:
;	assignBit
	clr	_EA
	mov	a,_queueGate
	jz	00112$
	dec	_queueGate
;	assignBit
	setb	_EA
	sjmp	00117$
00112$:
;	assignBit
	setb	_EA
	sjmp	00114$
00117$:
;	testlcd.c:33: if (queueWriteAt == 0) {
	mov	a,_queueWriteAt
	jnz	00123$
;	testlcd.c:34: inputQueue[0] = c;
	mov	_inputQueue,r7
	sjmp	00124$
00123$:
;	testlcd.c:35: } else if (queueWriteAt == 1) {
	mov	a,#0x01
	cjne	a,_queueWriteAt,00120$
;	testlcd.c:36: inputQueue[1] = c;
	mov	(_inputQueue + 0x0001),r7
	sjmp	00124$
00120$:
;	testlcd.c:38: inputQueue[2] = c;
	mov	(_inputQueue + 0x0002),r7
00124$:
;	testlcd.c:40: queueWriteAt++;
	mov	a,_queueWriteAt
	inc	a
	mov	_queueWriteAt,a
;	testlcd.c:41: if (queueWriteAt == 3) {
	mov	a,#0x03
	cjne	a,_queueWriteAt,00127$
;	testlcd.c:42: queueWriteAt = 0;
	mov	_queueWriteAt,#0x00
;	testlcd.c:45: SemaphoreSignal(queueGate);
00127$:
;	assignBit
	clr	_EA
	inc	_queueGate
;	assignBit
	setb	_EA
;	testlcd.c:46: SemaphoreSignal(usedCells);
;	assignBit
	clr	_EA
	inc	_usedCells
;	assignBit
	setb	_EA
;	testlcd.c:47: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'ButtonPipeTask'
;------------------------------------------------------------
;	testlcd.c:49: void ButtonPipeTask(void)
;	-----------------------------------------
;	 function ButtonPipeTask
;	-----------------------------------------
_ButtonPipeTask:
;	testlcd.c:51: buttonWasDown = 0;
	mov	_buttonWasDown,#0x00
;	testlcd.c:53: while (1) {
00107$:
;	testlcd.c:54: if (AnyButtonPressed()) {
	lcall	_AnyButtonPressed
	mov	a, dpl
	jz	00104$
;	testlcd.c:55: if (!buttonWasDown) {
	mov	a,_buttonWasDown
	jnz	00107$
;	testlcd.c:56: buttonPick = ButtonToChar();
	lcall	_ButtonToChar
	mov	_buttonPick,dpl
;	testlcd.c:57: PushInputChar(buttonPick);
	mov	dpl, _buttonPick
	lcall	_PushInputChar
;	testlcd.c:58: buttonWasDown = 1;
	mov	_buttonWasDown,#0x01
	sjmp	00107$
00104$:
;	testlcd.c:61: buttonWasDown = 0;
	mov	_buttonWasDown,#0x00
;	testlcd.c:64: }
	sjmp	00107$
;------------------------------------------------------------
;Allocation info for local variables in function 'KeyPipeTask'
;------------------------------------------------------------
;	testlcd.c:66: void KeyPipeTask(void)
;	-----------------------------------------
;	 function KeyPipeTask
;	-----------------------------------------
_KeyPipeTask:
;	testlcd.c:68: keypadWasDown = 0;
	mov	_keypadWasDown,#0x00
;	testlcd.c:70: while (1) {
00107$:
;	testlcd.c:71: if (AnyKeyPressed()) {
	lcall	_AnyKeyPressed
	mov	a, dpl
	jz	00104$
;	testlcd.c:72: if (!keypadWasDown) {
	mov	a,_keypadWasDown
	jnz	00107$
;	testlcd.c:73: keypadPick = KeyToChar();
	lcall	_KeyToChar
	mov	_keypadPick,dpl
;	testlcd.c:74: PushInputChar(keypadPick);
	mov	dpl, _keypadPick
	lcall	_PushInputChar
;	testlcd.c:75: keypadWasDown = 1;
	mov	_keypadWasDown,#0x01
	sjmp	00107$
00104$:
;	testlcd.c:78: keypadWasDown = 0;
	mov	_keypadWasDown,#0x00
;	testlcd.c:81: }
	sjmp	00107$
;------------------------------------------------------------
;Allocation info for local variables in function 'LcdDrainTask'
;------------------------------------------------------------
;	testlcd.c:83: void LcdDrainTask(void)
;	-----------------------------------------
;	 function LcdDrainTask
;	-----------------------------------------
_LcdDrainTask:
;	testlcd.c:85: LCD_Init();
	lcall	_LCD_Init
;	testlcd.c:86: while (!LCD_ready()) { }
00101$:
	lcall	_LCD_ready
	mov	a, dpl
	jz	00101$
;	testlcd.c:87: LCD_clearScreen();
	mov	dpl, #0x01
	lcall	_LCD_IRWrite
;	testlcd.c:90: SemaphoreWait(usedCells);
00107$:
;	assignBit
	clr	_EA
	mov	a,_usedCells
	jz	00105$
	dec	_usedCells
;	assignBit
	setb	_EA
	sjmp	00115$
00105$:
;	assignBit
	setb	_EA
;	testlcd.c:91: SemaphoreWait(queueGate);
	sjmp	00107$
00115$:
;	assignBit
	clr	_EA
	mov	a,_queueGate
	jz	00113$
	dec	_queueGate
;	assignBit
	setb	_EA
	sjmp	00118$
00113$:
;	assignBit
	setb	_EA
	sjmp	00115$
00118$:
;	testlcd.c:93: lcdCharOut = inputQueue[queueReadAt];
	mov	a,_queueReadAt
	add	a, #_inputQueue
	mov	r1,a
	mov	_lcdCharOut,@r1
;	testlcd.c:94: queueReadAt++;
	mov	a,_queueReadAt
	inc	a
	mov	_queueReadAt,a
;	testlcd.c:95: if (queueReadAt == 3) {
	mov	a,#0x03
	cjne	a,_queueReadAt,00122$
;	testlcd.c:96: queueReadAt = 0;
	mov	_queueReadAt,#0x00
;	testlcd.c:99: SemaphoreSignal(queueGate);
00122$:
;	assignBit
	clr	_EA
	inc	_queueGate
;	assignBit
	setb	_EA
;	testlcd.c:100: SemaphoreSignal(openCells);
;	assignBit
	clr	_EA
	inc	_openCells
;	assignBit
	setb	_EA
;	testlcd.c:102: while (!LCD_ready()) { }
00128$:
	lcall	_LCD_ready
	mov	a, dpl
	jz	00128$
;	testlcd.c:103: LCD_write_char(lcdCharOut);
	mov	dpl, _lcdCharOut
	lcall	_LCD_write_char
;	testlcd.c:105: }
	sjmp	00107$
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;	testlcd.c:107: void main(void)
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	testlcd.c:109: queueReadAt = 0;
	mov	_queueReadAt,#0x00
;	testlcd.c:110: queueWriteAt = 0;
	mov	_queueWriteAt,#0x00
;	testlcd.c:111: buttonWasDown = 0;
	mov	_buttonWasDown,#0x00
;	testlcd.c:112: keypadWasDown = 0;
	mov	_keypadWasDown,#0x00
;	testlcd.c:113: inputQueue[0] = 0;
	mov	_inputQueue,#0x00
;	testlcd.c:114: inputQueue[1] = 0;
	mov	(_inputQueue + 0x0001),#0x00
;	testlcd.c:115: inputQueue[2] = 0;
	mov	(_inputQueue + 0x0002),#0x00
;	testlcd.c:117: SemaphoreCreate(queueGate, 1);
	mov	_queueGate,#0x01
;	testlcd.c:118: SemaphoreCreate(usedCells, 0);
	mov	_usedCells,#0x00
;	testlcd.c:119: SemaphoreCreate(openCells, 3);
	mov	_openCells,#0x03
;	testlcd.c:121: Init_Keypad();
	lcall	_Init_Keypad
;	testlcd.c:123: ThreadCreate(ButtonPipeTask);
	mov	dptr,#_ButtonPipeTask
	lcall	_ThreadCreate
;	testlcd.c:124: ThreadCreate(KeyPipeTask);
	mov	dptr,#_KeyPipeTask
	lcall	_ThreadCreate
;	testlcd.c:125: LcdDrainTask();
;	testlcd.c:126: }
	ljmp	_LcdDrainTask
;------------------------------------------------------------
;Allocation info for local variables in function '_sdcc_gsinit_startup'
;------------------------------------------------------------
;	testlcd.c:128: void _sdcc_gsinit_startup(void)
;	-----------------------------------------
;	 function _sdcc_gsinit_startup
;	-----------------------------------------
__sdcc_gsinit_startup:
;	testlcd.c:132: __endasm;
	LJMP	_Bootstrap
;	testlcd.c:133: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_mcs51_genRAMCLEAR'
;------------------------------------------------------------
;	testlcd.c:135: void _mcs51_genRAMCLEAR(void) { }
;	-----------------------------------------
;	 function _mcs51_genRAMCLEAR
;	-----------------------------------------
__mcs51_genRAMCLEAR:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_mcs51_genXINIT'
;------------------------------------------------------------
;	testlcd.c:136: void _mcs51_genXINIT(void) { }
;	-----------------------------------------
;	 function _mcs51_genXINIT
;	-----------------------------------------
__mcs51_genXINIT:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_mcs51_genXRAMCLEAR'
;------------------------------------------------------------
;	testlcd.c:137: void _mcs51_genXRAMCLEAR(void) { }
;	-----------------------------------------
;	 function _mcs51_genXRAMCLEAR
;	-----------------------------------------
__mcs51_genXRAMCLEAR:
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'timer0_ISR'
;------------------------------------------------------------
;	testlcd.c:139: void timer0_ISR(void) __interrupt(1)
;	-----------------------------------------
;	 function timer0_ISR
;	-----------------------------------------
_timer0_ISR:
;	testlcd.c:143: __endasm;
	LJMP	_myTimer0Handler
;	testlcd.c:144: }
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
