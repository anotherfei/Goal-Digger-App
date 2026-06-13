#include <8051.h>
#include "preemptive.h"
#include "keylib.h"
#include "lcdlib.h"

#define DINO_SYMBOL   1
#define CACTUS_SYMBOL 2
#define LEFT_EDGE     0x0001
#define RIGHT_EDGE    0x8000

/* keypad queue */
__data __at(0x20) char keyGate;
__data __at(0x21) char keyUsed;
__data __at(0x22) char keyRoom;
__data __at(0x23) char keyQueue[3];
__data __at(0x26) char keyTakeAt;
__data __at(0x27) char keyPutAt;
__data __at(0x28) char keyStillDown;

/* game state */
__data __at(0x29) char sceneGate;
__data __at(0x2A) char dinoRow;
__data __at(0x2B) char playMode;
__data __at(0x2C) unsigned int cactusRow0;
__data __at(0x2E) unsigned int cactusRow1;
__data __at(0x30) unsigned int scoreCount;
__data __at(0x32) char difficultyDigit;
__data __at(0x3E) char cactusGap;

void PutKey(char c)
{
    if (c == '\0') {
        return;
    }

    SemaphoreWait(keyRoom);
    SemaphoreWait(keyGate);

    if (keyPutAt == 0) {
        keyQueue[0] = c;
    } else if (keyPutAt == 1) {
        keyQueue[1] = c;
    } else {
        keyQueue[2] = c;
    }
    keyPutAt++;
    if (keyPutAt == 3) {
        keyPutAt = 0;
    }

    SemaphoreSignal(keyGate);
    SemaphoreSignal(keyUsed);
}

char TakeKeyBlocking(void)
{
    char c;

    SemaphoreWait(keyUsed);
    SemaphoreWait(keyGate);

    c = keyQueue[keyTakeAt];
    keyTakeAt++;
    if (keyTakeAt == 3) {
        keyTakeAt = 0;
    }

    SemaphoreSignal(keyGate);
    SemaphoreSignal(keyRoom);
    return c;
}

char TakeKeyIfReady(void)
{
    char c;

    c = '\0';
    EA = 0;
    if (keyUsed > 0) {
        keyUsed--;
        EA = 1;

        SemaphoreWait(keyGate);
        c = keyQueue[keyTakeAt];
        keyTakeAt++;
        if (keyTakeAt == 3) {
            keyTakeAt = 0;
        }
        SemaphoreSignal(keyGate);
        SemaphoreSignal(keyRoom);
    } else {
        EA = 1;
    }
    return c;
}

void KeypadCtrlTask(void)
{
    char nowKey;

    keyStillDown = 0;
    while (1) {
        if (AnyKeyPressed()) {
            if (!keyStillDown) {
                nowKey = KeyToChar();
                PutKey(nowKey);
                keyStillDown = 1;
            }
        } else {
            keyStillDown = 0;
        }
    }
}

void WritePromptText(void)
{
    LCD_cursorGoTo(0, 0);
    LCD_write_char('L'); LCD_write_char('e'); LCD_write_char('v'); LCD_write_char('e');
    LCD_write_char('l'); LCD_write_char('?'); LCD_write_char(' '); LCD_write_char('0');
    LCD_write_char('-'); LCD_write_char('9'); LCD_write_char(' '); LCD_write_char('t');
    LCD_write_char('h'); LCD_write_char('e'); LCD_write_char('n'); LCD_write_char('#');

    LCD_cursorGoTo(1, 0);
    LCD_write_char('2'); LCD_write_char('='); LCD_write_char('u'); LCD_write_char('p');
    LCD_write_char(' '); LCD_write_char('8'); LCD_write_char('='); LCD_write_char('d');
    LCD_write_char('o'); LCD_write_char('w'); LCD_write_char('n'); LCD_write_char(' ');
    LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' ');
}

void WriteGameOverText(void)
{
    LCD_cursorGoTo(0, 0);
    LCD_write_char('G'); LCD_write_char('a'); LCD_write_char('m'); LCD_write_char('e');
    LCD_write_char(' '); LCD_write_char('o'); LCD_write_char('v'); LCD_write_char('e');
    LCD_write_char('r'); LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' ');
    LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' '); LCD_write_char(' ');

    LCD_cursorGoTo(1, 0);
    LCD_write_char('S'); LCD_write_char('c'); LCD_write_char('o'); LCD_write_char('r');
    LCD_write_char('e'); LCD_write_char(':'); LCD_write_char(' ');
}

void LCDWriteUint(unsigned int value)
{
    char started;

    started = 0;
    if (value >= 10000) {
        LCD_write_char('0' + (value / 10000));
        value = value % 10000;
        started = 1;
    }
    if (started || value >= 1000) {
        LCD_write_char('0' + (value / 1000));
        value = value % 1000;
        started = 1;
    }
    if (started || value >= 100) {
        LCD_write_char('0' + (value / 100));
        value = value % 100;
        started = 1;
    }
    if (started || value >= 10) {
        LCD_write_char('0' + (value / 10));
        value = value % 10;
    }
    LCD_write_char('0' + value);
}

void LoadDinoSymbols(void)
{
    LCD_setCgRamAddress(0x08);
    LCD_write_char(0x07); LCD_write_char(0x05); LCD_write_char(0x06); LCD_write_char(0x07);
    LCD_write_char(0x14); LCD_write_char(0x17); LCD_write_char(0x0E); LCD_write_char(0x0A);

    LCD_setCgRamAddress(0x10);
    LCD_write_char(0x04); LCD_write_char(0x05); LCD_write_char(0x15); LCD_write_char(0x15);
    LCD_write_char(0x16); LCD_write_char(0x0C); LCD_write_char(0x04); LCD_write_char(0x04);
}

#define DrawCactusCell(rowMap, bitMask)        \
    do {                                       \
        if ((rowMap) & (bitMask)) {            \
            LCD_write_char(CACTUS_SYMBOL);     \
        } else {                               \
            LCD_write_char(' ');               \
        }                                      \
    } while (0)

void DrawGameRows(void)
{
    LCD_cursorGoTo(0, 0);
    if (dinoRow == 0) {
        LCD_write_char(DINO_SYMBOL);
    } else {
        DrawCactusCell(cactusRow0, 0x0001);
    }
    DrawCactusCell(cactusRow0, 0x0002);
    DrawCactusCell(cactusRow0, 0x0004);
    DrawCactusCell(cactusRow0, 0x0008);
    DrawCactusCell(cactusRow0, 0x0010);
    DrawCactusCell(cactusRow0, 0x0020);
    DrawCactusCell(cactusRow0, 0x0040);
    DrawCactusCell(cactusRow0, 0x0080);
    DrawCactusCell(cactusRow0, 0x0100);
    DrawCactusCell(cactusRow0, 0x0200);
    DrawCactusCell(cactusRow0, 0x0400);
    DrawCactusCell(cactusRow0, 0x0800);
    DrawCactusCell(cactusRow0, 0x1000);
    DrawCactusCell(cactusRow0, 0x2000);
    DrawCactusCell(cactusRow0, 0x4000);
    DrawCactusCell(cactusRow0, 0x8000);

    LCD_cursorGoTo(1, 0);
    if (dinoRow == 1) {
        LCD_write_char(DINO_SYMBOL);
    } else {
        DrawCactusCell(cactusRow1, 0x0001);
    }
    DrawCactusCell(cactusRow1, 0x0002);
    DrawCactusCell(cactusRow1, 0x0004);
    DrawCactusCell(cactusRow1, 0x0008);
    DrawCactusCell(cactusRow1, 0x0010);
    DrawCactusCell(cactusRow1, 0x0020);
    DrawCactusCell(cactusRow1, 0x0040);
    DrawCactusCell(cactusRow1, 0x0080);
    DrawCactusCell(cactusRow1, 0x0100);
    DrawCactusCell(cactusRow1, 0x0200);
    DrawCactusCell(cactusRow1, 0x0400);
    DrawCactusCell(cactusRow1, 0x0800);
    DrawCactusCell(cactusRow1, 0x1000);
    DrawCactusCell(cactusRow1, 0x2000);
    DrawCactusCell(cactusRow1, 0x4000);
    DrawCactusCell(cactusRow1, 0x8000);
}

void RenderTask(void)
{
    char lastMode;

    LCD_Init();
    while (!LCD_ready()) { }
    LoadDinoSymbols();
    LCD_clearScreen();
    lastMode = 3;

    while (1) {
        if (playMode == 2) {
            if (lastMode != 2) {
                LCD_clearScreen();
                WritePromptText();
                lastMode = 2;
            }
            ThreadYield();
        } else if (playMode == 1) {
            SemaphoreWait(sceneGate);
            DrawGameRows();
            SemaphoreSignal(sceneGate);
            lastMode = 1;
            ThreadYield();
        } else {
            lastMode = 0;
            ThreadYield();
        }
    }
}

void SmallDelay(unsigned char count)
{
    count;
    __asm
    dino_wait_loop:
        djnz dpl, dino_wait_loop
    __endasm;
}

void FrameDelay(void)
{
    char rounds;

    rounds = 18 - difficultyDigit;
    while (rounds > 0) {
        SmallDelay(255);
        rounds--;
    }
}

void MoveDinoFromKey(char c)
{
    if (c == '2') {
        dinoRow = 0;
    } else if (c == '8') {
        dinoRow = 1;
    }
}

void MaybeAddCactus(void)
{
    if (cactusGap < 4) {
        cactusGap++;
        return;
    }

    if (((cactusRow0 | cactusRow1) & 0xC000) != 0) {
        return;
    }

    if ((scoreCount + difficultyDigit) & 1) {
        cactusRow0 |= RIGHT_EDGE;
    } else {
        cactusRow1 |= RIGHT_EDGE;
    }
    cactusGap = 0;
}

void UpdateGameMap(void)
{
    if ((dinoRow == 0) && (cactusRow0 & LEFT_EDGE)) {
        playMode = 0;
        return;
    }
    if ((dinoRow == 1) && (cactusRow1 & LEFT_EDGE)) {
        playMode = 0;
        return;
    }

    if ((cactusRow0 | cactusRow1) & LEFT_EDGE) {
        scoreCount++;
    }

    cactusRow0 = cactusRow0 >> 1;
    cactusRow1 = cactusRow1 >> 1;
    MaybeAddCactus();
}

void GameCtrlTask(void)
{
    char c;

    difficultyDigit = 0;
    playMode = 2;

    while (1) {
        c = TakeKeyBlocking();
        if ((c >= '0') && (c <= '9')) {
            difficultyDigit = c - '0';
        } else if (c == '#') {
            break;
        }
    }

    SemaphoreWait(sceneGate);
    dinoRow = 1;
    cactusRow0 = 0;
    cactusRow1 = 0;
    scoreCount = 0;
    cactusGap = 4;
    playMode = 1;
    SemaphoreSignal(sceneGate);

    while (playMode == 1) {
        c = TakeKeyIfReady();
        SemaphoreWait(sceneGate);
        MoveDinoFromKey(c);
        UpdateGameMap();
        SemaphoreSignal(sceneGate);
        FrameDelay();
    }

    SemaphoreWait(sceneGate);
    LCD_clearScreen();
    WriteGameOverText();
    LCDWriteUint(scoreCount);
    SemaphoreSignal(sceneGate);
}

void main(void)
{
    keyTakeAt = 0;
    keyPutAt = 0;
    keyQueue[0] = 0;
    keyQueue[1] = 0;
    keyQueue[2] = 0;
    keyStillDown = 0;

    dinoRow = 1;
    playMode = 2;
    cactusRow0 = 0;
    cactusRow1 = 0;
    scoreCount = 0;
    difficultyDigit = 0;
    cactusGap = 0;

    SemaphoreCreate(keyGate, 1);
    SemaphoreCreate(keyUsed, 0);
    SemaphoreCreate(keyRoom, 3);
    SemaphoreCreate(sceneGate, 1);

    Init_Keypad();

    ThreadCreate(KeypadCtrlTask);
    ThreadCreate(RenderTask);
    GameCtrlTask();
    ThreadExit();
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
