#include <stdbool.h>
#include <stdlib.h>
#include "kernel.h"
#include "kernel_id.h"
#include "ecrobot_interface.h"

//TODO In MotorControlTask, if ColorWhiteEvent{ if LastFoundLeft{ LastFoundLeft = lookLeft} else{ LastFoundLeft = !lookRight }}

/* You can define the ports used here */
#define BTN_PORT NXT_PORT_S1
#define SNR_PORT NXT_PORT_S4
// Motor speed range: [-100, 100]
#define LMOTOR_PORT NXT_PORT_C
#define RMOTOR_PORT NXT_PORT_A

DeclareCounter(SysTimerCnt);
DeclareEvent(SonarOnEvent);
DeclareEvent(SonarOffEvent);
DeclareTask(EventDispatcherTask);
DeclareTask(MotorControlTask);

// nxtOSEK hooks
void ecrobot_device_initialize() {
    ecrobot_init_sonar_sensor(SNR_PORT);
}
void ecrobot_device_terminate() {
    ecrobot_term_sonar_sensor(SNR_PORT);
}
void user_1ms_isr_type2() {
    SignalCounter(SysTimerCnt);
}
bool lookLeft() {
    //Return true if the line was found
}
bool lookRight() {
    //Return true if the line was found
}

int count;
TASK(EventDispatcherTask) {
    int sonar_old = 255;
    int sonar = ecrobot_get_sonar_sensor(SNR_PORT);
    static U8 TouchSensorStatus_old = 0;
    U8 TouchSensorStatus;

    while(1) {
        if(++count % 5 == 0) {
            sonar = ecrobot_get_sonar_sensor(SNR_PORT);
        }
        TouchSensorStatus = ecrobot_get_touch_sensor(BTN_PORT);
        // display_clear(0);
        // display_goto_xy(0, 0);
        // display_string("Sonar val: ");
        // display_int(sonar, 0);
        // display_update();

        if(TouchSensorStatus == 1 && TouchSensorStatus_old == 0) {
            // Send a Touch Sensor ON Event to the Handler
            SetEvent(MotorControlTask, TouchOnEvent);
        }
        else if(TouchSensorStatus == 0 && TouchSensorStatus_old == 1) {
            // Send a Touch Sensor OFF Event to the Handler
            SetEvent(MotorControlTask, TouchOffEvent);
        }

        int threshold = 25;
        if(sonar < threshold && sonar_old > threshold) {
            // Send a Sonar Sensor ON Event (ON the table) to the Handler
            SetEvent(MotorControlTask, SonarOnEvent);
        }
        else if(sonar > threshold && sonar_old < threshold) {
            // Send a Sonar Sensor OFF Event (OFF the table) to the Handler
            SetEvent(MotorControlTask, SonarOffEvent);
        }

        sonar_old = sonar;
        TouchSensorStatus_old = TouchSensorStatus;
        systick_wait_ms(10);
    }
    TerminateTask();
}

TASK(MotorControlTask) {
    bool atEdge = false;
    EventMaskType eventmask = 0;

    while(1) {
        WaitEvent(SonarOnEvent | SonarOffEvent | TouchOnEvent | TouchOffEvent);
        GetEvent(MotorControlTask, &eventmask);
        if(eventmask & SonarOnEvent) {
            ClearEvent(SonarOnEvent);
            atEdge = false;
        }
        else if(eventmask & SonarOffEvent) {
            ClearEvent(SonarOffEvent);
            //Turn motors off
            ecrobot_set_motor_speed(LMOTOR_PORT, 0);
            ecrobot_set_motor_speed(RMOTOR_PORT, 0);
            atEdge = true;
        }
        else if(eventmask & TouchOnEvent) {
            ClearEvent(TouchOnEvent);
            if(!atEdge) {
                //Turn motors on
                ecrobot_set_motor_speed(LMOTOR_PORT, 100);
                ecrobot_set_motor_speed(RMOTOR_PORT, 100);
            }
        }

        else if(eventmask & TouchOffEvent) {
            ClearEvent(TouchOffEvent);
            //Turn motors off
            ecrobot_set_motor_speed(LMOTOR_PORT, 0);
            ecrobot_set_motor_speed(RMOTOR_PORT, 0);
        }
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
