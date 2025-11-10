#include "ch.h"
#include "hal.h"

THD_WORKING_AREA(waMotorThread, 256);

static THD_FUNCTION(MotorThread, arg) {
    (void)arg;
    chRegSetThreadName("Motor");
    while (true) {
        chThdSleepMilliseconds(1000);
    }
}

int main(void) {
    halInit();
    chSysInit();

    chThdCreateStatic(waMotorThread, sizeof(waMotorThread),
                      NORMALPRIO, MotorThread, NULL);

    while (true) {
        chThdSleepMilliseconds(500);
    }
}
