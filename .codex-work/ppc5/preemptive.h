/*
 * file: preemptive.h
 *
 * this is the include file for the cooperative multithreading
 * package.  It is to be compiled by SDCC and targets the EdSim51 as
 * the target architecture.
 *
 * CS 3423 Fall 2018
 */

/*
 * preemptive.h
 * Small preemptive thread package for the 8051 / EdSim51 project.
 */

#ifndef __PREEMPTIVE_H__
#define __PREEMPTIVE_H__

#define MAXTHREADS 4

typedef char ThreadID;
typedef void (*FunctionPtr)(void);

ThreadID ThreadCreate(FunctionPtr fp);
void ThreadYield(void);
void ThreadExit(void);
void myTimer0Handler(void);

/*
 * Counting semaphore helpers.
 * These are intentionally simple busy-wait semaphores.  The short interrupt
 * disable section is there so the check-and-decrement cannot be interrupted.
 */
#define SemaphoreCreate(s, n) \
    do {                      \
        (s) = (n);            \
    } while (0)

#define SemaphoreWait(s)       \
    do {                       \
        while (1) {            \
            EA = 0;            \
            if ((s) > 0) {     \
                --(s);         \
                EA = 1;        \
                break;         \
            }                  \
            EA = 1;            \
        }                      \
    } while (0)

#define SemaphoreSignal(s) \
    do {                   \
        EA = 0;            \
        ++(s);             \
        EA = 1;            \
    } while (0)

#endif