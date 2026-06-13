#include <8051.h>
#include "preemptive.h"
#include "buttonlib.h"
#include "keylib.h"
#include "lcdlib.h"

/*
 * A 3-character queue is used again, but the names are not the same as the
 * old bounded-buffer example.  It is still the same idea: two input threads
 * feed one output thread.
 */
__data __at(0x20) char queueGate;
__data __at(0x21) char usedCells;
__data __at(0x22) char openCells;
__data __at(0x23) char inputQueue[3];
__data __at(0x26) char queueReadAt;
__data __at(0x27) char queueWriteAt;
__data __at(0x28) char buttonWasDown;
__data __at(0x29) char keypadWasDown;
__data __at(0x2A) char buttonPick;
__data __at(0x2B) char keypadPick;
__data __at(0x2C) char lcdCharOut;

void PushInputChar(char c)
{
    if (c == '\0') {
        return;
    }

    SemaphoreWait(openCells);
    SemaphoreWait(queueGate);

    if (queueWriteAt == 0) {
        inputQueue[0] = c;
    } else if (queueWriteAt == 1) {
        inputQueue[1] = c;
    } else {
        inputQueue[2] = c;
    }
    queueWriteAt++;
    if (queueWriteAt == 3) {
        queueWriteAt = 0;
    }

    SemaphoreSignal(queueGate);
    SemaphoreSignal(usedCells);
}

void ButtonPipeTask(void)
{
    buttonWasDown = 0;

    while (1) {
        if (AnyButtonPressed()) {
            if (!buttonWasDown) {
                buttonPick = ButtonToChar();
                PushInputChar(buttonPick);
                buttonWasDown = 1;
            }
        } else {
            buttonWasDown = 0;
        }
    }
}

void KeyPipeTask(void)
{
    keypadWasDown = 0;

    while (1) {
        if (AnyKeyPressed()) {
            if (!keypadWasDown) {
                keypadPick = KeyToChar();
                PushInputChar(keypadPick);
                keypadWasDown = 1;
            }
        } else {
            keypadWasDown = 0;
        }
    }
}

void LcdDrainTask(void)
{
    LCD_Init();
    while (!LCD_ready()) { }
    LCD_clearScreen();

    while (1) {
        SemaphoreWait(usedCells);
        SemaphoreWait(queueGate);

        lcdCharOut = inputQueue[queueReadAt];
        queueReadAt++;
        if (queueReadAt == 3) {
            queueReadAt = 0;
        }

        SemaphoreSignal(queueGate);
        SemaphoreSignal(openCells);

        while (!LCD_ready()) { }
        LCD_write_char(lcdCharOut);
    }
}

void main(void)
{
    queueReadAt = 0;
    queueWriteAt = 0;
    buttonWasDown = 0;
    keypadWasDown = 0;
    inputQueue[0] = 0;
    inputQueue[1] = 0;
    inputQueue[2] = 0;

    SemaphoreCreate(queueGate, 1);
    SemaphoreCreate(usedCells, 0);
    SemaphoreCreate(openCells, 3);

    Init_Keypad();

    ThreadCreate(ButtonPipeTask);
    ThreadCreate(KeyPipeTask);
    LcdDrainTask();
}

void _sdcc_gsinit_startup(void)
{
    __asm
        LJMP _Bootstrap
    __endasm;
}

void _mcs51_genRAMCLEAR(void) { }
void _mcs51_genXINIT(void) { }
void _mcs51_genXRAMCLEAR(void) { }

void timer0_ISR(void) __interrupt(1)
{
    __asm
        LJMP _myTimer0Handler
    __endasm;
}
