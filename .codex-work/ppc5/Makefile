#
# makefile for testing cooperative multithreading
#
# This assumes you have SDCC installed and this targets EdSim51.
# The generated .hex file should be one that can be loaded and run
# directly.
#
# Author: Pai Chou
# CS 3423 Fall 2018
#

CC = sdcc
CFLAGS = -c --model-small
LDFLAGS =

ifeq ($(OS),Windows_NT)
RM = cmd /C del /Q
else
RM = rm -f
endif

TESTLCD_OBJ = testlcd.rel preemptive.rel lcdlib.rel buttonlib.rel keylib.rel
DINO_OBJ = dino.rel preemptive.rel lcdlib.rel keylib.rel

all: testlcd.hex dino.hex

testlcd.hex: $(TESTLCD_OBJ)
	$(CC) $(LDFLAGS) -o testlcd.hex $(TESTLCD_OBJ)

dino.hex: $(DINO_OBJ)
	$(CC) $(LDFLAGS) -o dino.hex $(DINO_OBJ)

preemptive.rel: preemptive.c preemptive.h Makefile
	$(CC) $(CFLAGS) preemptive.c

lcdlib.rel: lcdlib.c lcdlib.h Makefile
	$(CC) $(CFLAGS) lcdlib.c

buttonlib.rel: buttonlib.c buttonlib.h Makefile
	$(CC) $(CFLAGS) buttonlib.c

keylib.rel: keylib.c keylib.h Makefile
	$(CC) $(CFLAGS) keylib.c

testlcd.rel: testlcd.c preemptive.h buttonlib.h keylib.h lcdlib.h Makefile
	$(CC) $(CFLAGS) testlcd.c

dino.rel: dino.c preemptive.h keylib.h lcdlib.h Makefile
	$(CC) $(CFLAGS) dino.c

clean:
	$(RM) *.hex *.ihx *.lnk *.lst *.map *.mem *.rel *.rst *.sym *.asm *.lk
