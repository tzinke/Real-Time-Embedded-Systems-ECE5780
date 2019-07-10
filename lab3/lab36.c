#include <stdlib.h>
#include "kernel.h"
#include "kernel_id.h"
#include "ecrobot_interface.h"

/* You can define the ports used here */
#define COLOR_PORT_ID NXT_PORT_S1

DeclareCounter(SysTimerCnt);
DeclareTask(Task_ColorSensor);

// nxtOSEK hooks
void ecrobot_device_initialize() {
    ecrobot_init_nxtcolorsensor(COLOR_PORT_ID, NXT_LIGHTSENSOR_WHITE);
}
void ecrobot_device_terminate() {
    ecrobot_term_nxtcolorsensor(COLOR_PORT_ID);
}
void user_1ms_isr_type2() {
    SignalCounter(SysTimerCnt);
}

// Helper functions
void UpdateDisplay(int count, int avg) {
    display_clear(0);
    display_goto_xy(0, 0);
    display_string("Welcome to My");
    display_goto_xy(0, 1);
    display_string("World!");
    display_goto_xy(0, 2);
    display_string("Names:");
    display_goto_xy(0, 3);
    display_string("Jarrett & Taylor");
    display_goto_xy(0, 4);
    display_string("Light Sensor: ");
    display_goto_xy(3, 5);
    display_int(avg, 0);
    display_goto_xy(0, 7);
    display_string("Count: ");
    display_int(count, 0);
    display_update();
}

int avg;
int count;
// This task gets a light value on a 100ms period.
TASK(Task_ColorSensor) {
    int light = 0;
    light = ecrobot_get_nxtcolorsensor_light(COLOR_PORT_ID);

	//Update the average with the new reading
    avg = (avg + light) / 2;

    // Update the display after 5 updates of the light value on a 500ms period.
    if(++count % 5 == 0) {
        UpdateDisplay(count, avg);
        avg = 0;
    }

    TerminateTask();
}

// This is modeled from the color sensor examples included with the Lego
// Package zip. This task needs to continuously run in the background to
// read from the color sensor.
TASK(Task_BgColorSensor) {
    while(1) {
        ecrobot_process_bg_nxtcolorsensor();
    }
}
