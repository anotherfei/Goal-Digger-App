;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler
; Version 4.5.0 #15242 (MINGW64)
;--------------------------------------------------------
	.module preemptive
	
	.optsdcc -mmcs51 --model-small
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _Bootstrap
	.globl _main
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
	.globl _oldStackTop
	.globl _pswSeed
	.globl _nextSlot
	.globl _savedStackPointers
	.globl _threadBitmap
	.globl _activeThreadID
	.globl _ThreadCreate
	.globl _ThreadYield
	.globl _ThreadExit
	.globl _myTimer0Handler
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
_activeThreadID	=	0x0033
_threadBitmap	=	0x0034
_savedStackPointers	=	0x0035
_nextSlot	=	0x003a
_pswSeed	=	0x003b
_oldStackTop	=	0x003c
;--------------------------------------------------------
; overlayable items in internal ram
;--------------------------------------------------------
	.area	OSEG    (OVR,DATA)
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
; global & static initialisations
;--------------------------------------------------------
	.area HOME    (CODE)
	.area GSINIT  (CODE)
	.area GSFINAL (CODE)
	.area GSINIT  (CODE)
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME    (CODE)
	.area HOME    (CODE)
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CSEG    (CODE)
;------------------------------------------------------------
;Allocation info for local variables in function 'Bootstrap'
;------------------------------------------------------------
;	preemptive.c:48: void Bootstrap(void)
;	-----------------------------------------
;	 function Bootstrap
;	-----------------------------------------
_Bootstrap:
	ar7 = 0x07
	ar6 = 0x06
	ar5 = 0x05
	ar4 = 0x04
	ar3 = 0x03
	ar2 = 0x02
	ar1 = 0x01
	ar0 = 0x00
;	preemptive.c:50: TMOD = 0;
	mov	_TMOD,#0x00
;	preemptive.c:51: IE = 0x82;
	mov	_IE,#0x82
;	preemptive.c:52: TR0 = 1;
;	assignBit
	setb	_TR0
;	preemptive.c:53: threadBitmap = 0;
	mov	_threadBitmap,#0x00
;	preemptive.c:55: activeThreadID = ThreadCreate(main);
	mov	dptr,#_main
	lcall	_ThreadCreate
	mov	_activeThreadID,dpl
;	preemptive.c:56: RESTORESTATE;
	MOV B, R0 
	MOV A, _activeThreadID 
	ADD A, #_savedStackPointers 
	MOV R0, A 
	MOV _SP, @R0 
	MOV R0, B 
	POP PSW 
	POP DPH 
	POP DPL 
	POP B 
	POP ACC 
;	preemptive.c:57: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'ThreadCreate'
;------------------------------------------------------------
;fp            Allocated to registers 
;------------------------------------------------------------
;	preemptive.c:59: ThreadID ThreadCreate(FunctionPtr fp)
;	-----------------------------------------
;	 function ThreadCreate
;	-----------------------------------------
_ThreadCreate:
;	preemptive.c:63: EA = 0;
;	assignBit
	clr	_EA
;	preemptive.c:64: if (threadBitmap == 0x0F) {
	mov	a,#0x0f
	cjne	a,_threadBitmap,00102$
;	preemptive.c:65: EA = 1;
;	assignBit
	setb	_EA
;	preemptive.c:66: return -1;
	mov	dpl, #0xff
	ret
00102$:
;	preemptive.c:69: for (nextSlot = 0; nextSlot < MAXTHREADS; nextSlot++) {
	mov	_nextSlot,#0x00
00107$:
	mov	a,#0x100 - 0x04
	add	a,_nextSlot
	jc	00105$
;	preemptive.c:70: if ((threadBitmap & (1 << nextSlot)) == 0) {
	mov	b,_nextSlot
	inc	b
	mov	r6,#0x01
	mov	r7,#0x00
	sjmp	00139$
00138$:
	mov	a,r6
	add	a,r6
	mov	r6,a
	mov	a,r7
	rlc	a
	mov	r7,a
00139$:
	djnz	b,00138$
	mov	r4,_threadBitmap
	mov	r5,#0x00
	mov	a,r4
	anl	ar6,a
	mov	a,r5
	anl	ar7,a
	mov	a,r6
	orl	a,r7
	jz	00105$
;	preemptive.c:69: for (nextSlot = 0; nextSlot < MAXTHREADS; nextSlot++) {
	mov	a,_nextSlot
	inc	a
	mov	_nextSlot,a
	sjmp	00107$
00105$:
;	preemptive.c:75: threadBitmap |= (1 << nextSlot);
	mov	b,_nextSlot
	inc	b
	mov	a,#0x01
	sjmp	00142$
00141$:
	add	a,acc
00142$:
	djnz	b,00141$
	orl	_threadBitmap,a
;	preemptive.c:77: oldStackTop = SP;
	mov	_oldStackTop,_SP
;	preemptive.c:78: SP = 0x3F + (nextSlot * 0x10);
	mov	a,_nextSlot
	swap	a
	anl	a,#0xf0
	mov	r7,a
	add	a,#0x3f
	mov	_SP,a
;	preemptive.c:83: __endasm;
	PUSH	DPL
	PUSH	DPH
;	preemptive.c:91: __endasm;
	MOV	A, #0
	PUSH	ACC
	PUSH	ACC
	PUSH	ACC
	PUSH	ACC
;	preemptive.c:93: pswSeed = nextSlot << 3;
	mov	a,_nextSlot
	swap	a
	rr	a
	anl	a,#0xf8
	mov	_pswSeed,a
;	preemptive.c:96: __endasm;
	PUSH	_pswSeed
;	preemptive.c:98: savedStackPointers[nextSlot] = SP;
	mov	a,_nextSlot
	add	a, #_savedStackPointers
	mov	r0,a
	mov	@r0,_SP
;	preemptive.c:99: SP = oldStackTop;
	mov	_SP,_oldStackTop
;	preemptive.c:101: EA = 1;
;	assignBit
	setb	_EA
;	preemptive.c:102: return nextSlot;
	mov	dpl, _nextSlot
;	preemptive.c:103: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'ThreadYield'
;------------------------------------------------------------
;	preemptive.c:105: void ThreadYield(void)
;	-----------------------------------------
;	 function ThreadYield
;	-----------------------------------------
_ThreadYield:
;	preemptive.c:107: EA = 0;
;	assignBit
	clr	_EA
;	preemptive.c:108: SAVESTATE;
	PUSH ACC 
	PUSH B 
	PUSH DPL 
	PUSH DPH 
	PUSH PSW 
	MOV B, R0 
	MOV A, _activeThreadID 
	ADD A, #_savedStackPointers 
	MOV R0, A 
	MOV @R0, _SP 
	MOV R0, B 
;	preemptive.c:128: __endasm;
thread_yield_select:
	MOV	A, _activeThreadID
	INC	A
	ANL	A, #0x03
	MOV	_activeThreadID, A
	MOV	B, A
	INC	B
	MOV	A, #0x01
thread_yield_mask:
	DJNZ	B, thread_yield_shift
	SJMP	thread_yield_test
thread_yield_shift:
	ADD	A, ACC
	SJMP	thread_yield_mask
thread_yield_test:
	ANL	A, _threadBitmap
	JZ	thread_yield_select
;	preemptive.c:130: RESTORESTATE;
	MOV B, R0 
	MOV A, _activeThreadID 
	ADD A, #_savedStackPointers 
	MOV R0, A 
	MOV _SP, @R0 
	MOV R0, B 
	POP PSW 
	POP DPH 
	POP DPL 
	POP B 
	POP ACC 
;	preemptive.c:131: EA = 1;
;	assignBit
	setb	_EA
;	preemptive.c:132: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'ThreadExit'
;------------------------------------------------------------
;	preemptive.c:134: void ThreadExit(void)
;	-----------------------------------------
;	 function ThreadExit
;	-----------------------------------------
_ThreadExit:
;	preemptive.c:136: EA = 0;
;	assignBit
	clr	_EA
;	preemptive.c:137: threadBitmap &= ~(1 << activeThreadID);
	mov	b,_activeThreadID
	inc	b
	mov	a,#0x01
	sjmp	00104$
00103$:
	add	a,acc
00104$:
	djnz	b,00103$
	cpl	a
	mov	r7,a
	anl	_threadBitmap,a
;	preemptive.c:157: __endasm;
thread_exit_select:
	MOV	A, _activeThreadID
	INC	A
	ANL	A, #0x03
	MOV	_activeThreadID, A
	MOV	B, A
	INC	B
	MOV	A, #0x01
thread_exit_mask:
	DJNZ	B, thread_exit_shift
	SJMP	thread_exit_test
thread_exit_shift:
	ADD	A, ACC
	SJMP	thread_exit_mask
thread_exit_test:
	ANL	A, _threadBitmap
	JZ	thread_exit_select
;	preemptive.c:159: RESTORESTATE;
	MOV B, R0 
	MOV A, _activeThreadID 
	ADD A, #_savedStackPointers 
	MOV R0, A 
	MOV _SP, @R0 
	MOV R0, B 
	POP PSW 
	POP DPH 
	POP DPL 
	POP B 
	POP ACC 
;	preemptive.c:160: EA = 1;
;	assignBit
	setb	_EA
;	preemptive.c:161: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'myTimer0Handler'
;------------------------------------------------------------
;	preemptive.c:163: void myTimer0Handler(void)
;	-----------------------------------------
;	 function myTimer0Handler
;	-----------------------------------------
_myTimer0Handler:
;	preemptive.c:165: EA = 0;
;	assignBit
	clr	_EA
;	preemptive.c:166: SAVESTATE;
	PUSH ACC 
	PUSH B 
	PUSH DPL 
	PUSH DPH 
	PUSH PSW 
	MOV B, R0 
	MOV A, _activeThreadID 
	ADD A, #_savedStackPointers 
	MOV R0, A 
	MOV @R0, _SP 
	MOV R0, B 
;	preemptive.c:186: __endasm;
timer_select:
	MOV	A, _activeThreadID
	INC	A
	ANL	A, #0x03
	MOV	_activeThreadID, A
	MOV	B, A
	INC	B
	MOV	A, #0x01
timer_mask:
	DJNZ	B, timer_shift
	SJMP	timer_test
timer_shift:
	ADD	A, ACC
	SJMP	timer_mask
timer_test:
	ANL	A, _threadBitmap
	JZ	timer_select
;	preemptive.c:188: RESTORESTATE;
	MOV B, R0 
	MOV A, _activeThreadID 
	ADD A, #_savedStackPointers 
	MOV R0, A 
	MOV _SP, @R0 
	MOV R0, B 
	POP PSW 
	POP DPH 
	POP DPL 
	POP B 
	POP ACC 
;	preemptive.c:189: EA = 1;
;	assignBit
	setb	_EA
;	preemptive.c:193: __endasm;
	RETI
;	preemptive.c:194: }
	ret
	.area CSEG    (CODE)
	.area CONST   (CODE)
	.area XINIT   (CODE)
	.area CABS    (ABS,CODE)
