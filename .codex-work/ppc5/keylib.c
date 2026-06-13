#include <8051.h>
#include "keylib.h"

/*
 * keylib.c
 * This is the library that works with the keypad.
 * It provides functions to initialize the keypad, check whether any key is
 * pressed, and read one pressed key as an ASCII character.
 */

void Init_Keypad(void)
{
    P3_3 = 1;
    P0 = 0xF0;
}

char AnyKeyPressed(void)
{
    P0 = 0xF0;
    return !P3_3;
}

char KeyToChar(void)
{
    P0 = 0xF7;
    if (P0 == 0xB7) {
        return '1';
    } else if (P0 == 0xD7) {
        return '2';
    } else if (P0 == 0xE7) {
        return '3';
    }

    P0 = 0xFB;
    if (P0 == 0xBB) {
        return '4';
    } else if (P0 == 0xDB) {
        return '5';
    } else if (P0 == 0xEB) {
        return '6';
    }

    P0 = 0xFD;
    if (P0 == 0xBD) {
        return '7';
    } else if (P0 == 0xDD) {
        return '8';
    } else if (P0 == 0xED) {
        return '9';
    }

    P0 = 0xFE;
    if (P0 == 0xBE) {
        return '*';
    } else if (P0 == 0xDE) {
        return '0';
    } else if (P0 == 0xEE) {
        return '#';
    }

    return '\0';
}
