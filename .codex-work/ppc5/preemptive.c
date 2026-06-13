#include <8051.h>
#include "preemptive.h"

__data __at(0x33) ThreadID activeThreadID;
__data __at(0x34) char threadBitmap;
__data __at(0x35) char savedStackPointers[MAXTHREADS];

__data __at(0x3A) ThreadID nextSlot;
__data __at(0x3B) char pswSeed;
__data __at(0x3C) char oldStackTop;

#define SAVESTATE                          \
    {                                      \
        __asm                              \
        PUSH ACC                           \
        PUSH B                             \
        PUSH DPL                           \
        PUSH DPH                           \
        PUSH PSW                           \
        MOV B, R0                          \
        MOV A, _activeThreadID             \
        ADD A, #_savedStackPointers        \
        MOV R0, A                          \
        MOV @R0, _SP                       \
        MOV R0, B                          \
        __endasm;                          \
    }

#define RESTORESTATE                       \
    {                                      \
        __asm                              \
        MOV B, R0                          \
        MOV A, _activeThreadID             \
        ADD A, #_savedStackPointers        \
        MOV R0, A                          \
        MOV _SP, @R0                       \
        MOV R0, B                          \
        POP PSW                            \
        POP DPH                            \
        POP DPL                            \
        POP B                              \
        POP ACC                            \
        __endasm;                          \
    }

extern void main(void);

void Bootstrap(void)
{
    TMOD = 0;
    IE = 0x82;
    TR0 = 1;
    threadBitmap = 0;

    activeThreadID = ThreadCreate(main);
    RESTORESTATE;
}

ThreadID ThreadCreate(FunctionPtr fp)
{
    (void)fp;

    EA = 0;
    if (threadBitmap == 0x0F) {
        EA = 1;
        return -1;
    }

    for (nextSlot = 0; nextSlot < MAXTHREADS; nextSlot++) {
        if ((threadBitmap & (1 << nextSlot)) == 0) {
            break;
        }
    }

    threadBitmap |= (1 << nextSlot);

    oldStackTop = SP;
    SP = 0x3F + (nextSlot * 0x10);

    __asm
        PUSH DPL
        PUSH DPH
    __endasm;

    __asm
        MOV A, #0
        PUSH ACC
        PUSH ACC
        PUSH ACC
        PUSH ACC
    __endasm;

    pswSeed = nextSlot << 3;
    __asm
        PUSH _pswSeed
    __endasm;

    savedStackPointers[nextSlot] = SP;
    SP = oldStackTop;

    EA = 1;
    return nextSlot;
}

void ThreadYield(void)
{
    EA = 0;
    SAVESTATE;

    __asm
    thread_yield_select:
        MOV A, _activeThreadID
        INC A
        ANL A, #0x03
        MOV _activeThreadID, A
        MOV B, A
        INC B
        MOV A, #0x01
    thread_yield_mask:
        DJNZ B, thread_yield_shift
        SJMP thread_yield_test
    thread_yield_shift:
        ADD A, ACC
        SJMP thread_yield_mask
    thread_yield_test:
        ANL A, _threadBitmap
        JZ thread_yield_select
    __endasm;

    RESTORESTATE;
    EA = 1;
}

void ThreadExit(void)
{
    EA = 0;
    threadBitmap &= ~(1 << activeThreadID);

    __asm
    thread_exit_select:
        MOV A, _activeThreadID
        INC A
        ANL A, #0x03
        MOV _activeThreadID, A
        MOV B, A
        INC B
        MOV A, #0x01
    thread_exit_mask:
        DJNZ B, thread_exit_shift
        SJMP thread_exit_test
    thread_exit_shift:
        ADD A, ACC
        SJMP thread_exit_mask
    thread_exit_test:
        ANL A, _threadBitmap
        JZ thread_exit_select
    __endasm;

    RESTORESTATE;
    EA = 1;
}

void myTimer0Handler(void)
{
    EA = 0;
    SAVESTATE;

    __asm
    timer_select:
        MOV A, _activeThreadID
        INC A
        ANL A, #0x03
        MOV _activeThreadID, A
        MOV B, A
        INC B
        MOV A, #0x01
    timer_mask:
        DJNZ B, timer_shift
        SJMP timer_test
    timer_shift:
        ADD A, ACC
        SJMP timer_mask
    timer_test:
        ANL A, _threadBitmap
        JZ timer_select
    __endasm;

    RESTORESTATE;
    EA = 1;

    __asm
        RETI
    __endasm;
}
