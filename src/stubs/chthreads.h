#pragma once
#include "chtime.h"

typedef int sysinterval_t;

static inline void chThdSleep(sysinterval_t ms) {
    // Stubbed sleep: no-op
    (void)ms;
}

#define chThdSleepMilliseconds(msec) chThdSleep(TIME_MS2I(msec))
