#include <stdbool.h>
#include <stdlib.h>
#include "kernel.h"
#include "kernel_id.h"
#include "ecrobot_interface.h"

/* You can define the ports used here */
#define BTN_PORT NXT_PORT_S1
#define SNR_PORT NXT_PORT_S2
#define LMOTOR_PORT NXT_PORT_C
#define RMOTOR_PORT NXT_PORT_A

DeclareCounter(SysTimerCnt);
DeclareEvent(SonarOnEvent);
DeclareEvent(SonarOffEvent);
DeclareEvent(TouchOnEvent);
DeclareEvent(TouchOffEvent);
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

TASK(EventDispatcherTask) {
    int sonar_old;
    int sonar;
    static U8 TouchSensorStatus_old = 0;
    U8 TouchSensorStatus;

    while(1) {
        sonar = ecrobot_get_sonar_sensor(SNR_PORT);
        TouchSensorStatus = ecrobot_get_touch_sensor(BTN_PORT);
        if (TouchSensorStatus == 1 && TouchSensorStatus_old == 0) {
            // Send a Touch Sensor ON Event to the Handler
            SetEvent(MotorControlTask, TouchOnEvent);
        }
        else if (TouchSensorStatus == 0 && TouchSensorStatus_old == 1) {
            // Send a Touch Sensor OFF Event to the Handler
            SetEvent(MotorControlTask, TouchOffEvent);
        }
        sonar_old = sonar;
        TouchSensorStatus_old = TouchSensorStatus;

        systick_wait_ms(10);
    }
}

TASK(MotorControlTask) {
    bool atEdge = false;
    EventMaskType eventmask = 0;

    while(!atEdge) {
        WaitEvent(SonarOffEvent | TouchOnEvent | TouchOffEvent);
        GetEvent(MotorControlTask, &eventmask);
        if(eventmask & SonarOffEvent) {
            ClearEvent(SonarOffEvent);
            //Turn motors off
            ecrobot_set_motor_speed(LMOTOR_PORT, 0);
            ecrobot_set_motor_speed(RMOTOR_PORT, 0);

            //Break out of while loop (redundancy)
            atEdge = true;
        }
        else if(eventmask & TouchOnEvent) {
            ClearEvent(TouchOnEvent);
            //Turn motors on
            ecrobot_set_motor_speed(LMOTOR_PORT, 25);
            ecrobot_set_motor_speed(RMOTOR_PORT, 25); //25 is quarter speed.
        }
        else if(eventmask & TouchOffEvent) {
            ClearEvent(TouchOffEvent);
            //Turn motors off
            ecrobot_set_motor_speed(LMOTOR_PORT, 0);
            ecrobot_set_motor_speed(RMOTOR_PORT, 0);
        }
    }
}
