#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>
#include <math.h>
#include <time.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"

#include "sis8300_llrf_utils.h"
#include "sis8300_llrf_reg.h"


int main(int argc, char **argv) {
    int status,nbr_of_pulses,i;
    sis8300drv_usr *sisuser;
    unsigned reg_val;
    int state;
    int rotating_phase;
    signed i_val,q_val;
    double phase,mag;
    unsigned reg_value_rb;

    if (argc == 4) {
        sisuser = malloc(sizeof(sis8300drv_usr));
        sisuser->file = argv[1];
        nbr_of_pulses = (int)strtoul(argv[2], NULL, 16);
        rotating_phase = (int)strtoul(argv[3], NULL, 16);
    }else{
        printf("Usage: %s [device_node], [nbr of pulses], [rotating phase (0|1)]\n", argv[0]);
        return -1;
    }

    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }


    for(i=0; i<nbr_of_pulses; i++){
        status = sis8300drv_reg_write(sisuser, 0x10, 0x2);
        status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x20);
        usleep(300);
        status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
        state = print_state(reg_val);
        if (state != 3){
            printf("Wrong state! Expected state: ACTIVE_NO_PULSE\n");
            return -1;
        }
        status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x40);
        usleep(2800);
        status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
        state = print_state(reg_val);
        if (state != 4){
            printf("Wrong state! Expected state: ACTIVE_PULSE\n");
            return -1;
        }
        status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x80);
        usleep(68000);
        status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
        state = print_state(reg_val);
        if (state != 1){
            printf("Wrong state! Expected state: IDLE\n");
            return -1;
        }
        printf("Pulse %d done\n",i+1);
        if ((rotating_phase == 1) && (i < (nbr_of_pulses-1))){ //Don't update after last pulse
            read_reg_cl(sisuser, LLRF_PI_1_FIXED_SP,&reg_value_rb);
            i_val = ((signed)reg_value_rb<<16)>>16;
            read_reg_cl(sisuser, LLRF_PI_2_FIXED_SP,&reg_value_rb);
            q_val = ((signed)reg_value_rb<<16)>>16;
            if (i_val<0 && q_val<0) {
                phase = atan((double)q_val/(double)i_val)-M_PI;
            }else if (i_val<0){
                phase = atan((double)q_val/(double)i_val)+M_PI;
            }else{
                phase = atan((double)q_val/(double)i_val);
            }
            mag = sqrt(i_val*i_val+q_val*q_val);
            printf("Phase: %0.3f, Mag: %0.3f\n",phase * 360 / (2*M_PI),mag);
            phase+=M_PI/180;
//            if (phase>M_PI){
//                phase=+2*M_PI;
//            }
            printf("Phase: %0.3f, Mag: %0.3f\n",phase * 360 / (2*M_PI),mag);
            i_val = (signed)(cos(phase)*mag);
            q_val = (signed)(sin(phase)*mag);
            printf("I_val: %d, Q_val: %d\n",i_val,q_val);
            write_reg_cl(sisuser, LLRF_PI_1_FIXED_SP,i_val);
            write_reg_cl(sisuser, LLRF_PI_2_FIXED_SP,q_val);
            write_reg_cl(sisuser, LLRF_GIP_S, 0x2);
        }
    }

    printf("All pulses received. Pulse count: %d\n",i);


    return(0);
}
