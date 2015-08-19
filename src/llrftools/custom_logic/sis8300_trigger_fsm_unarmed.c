/*
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <limits.h>

#define __USE_BSD
#include <unistd.h>
#include <time.h>
*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <limits.h>
#include <time.h>
#include <math.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"

#include "sis8300_llrf_utils.h"
#include "sis8300_llrf_reg.h"

int print_state(unsigned reg_val){
    int state;

    state=(int)reg_val&0x00000007;
/*    if(state == 0){
        printf("\tFSM state: INIT\n");
    }else if(state == 1){
        printf("\tFSM state: IDLE\n");
    }else if(state == 2){
        printf("\tFSM state: PULSE_SETUP\n");
    }else if(state == 3){
        printf("\tFSM state: ACTIVE_NO_PULSE\n");
    }else if(state == 4){
        printf("\tFSM state: ACTIVE_PULSE\n");
    }else if(state == 5){
        printf("\tFSM state: PULSE_END\n");
    }else if(state == 6){
        printf("\tFSM state: PMS\n");
    }
*/    return state;
}

double time_msec() {
    struct timespec ts;
    
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec * 1.0e3 + ts.tv_nsec / 1.0e6;
}


int main(int argc, char **argv) {
    int status,nbr_of_pulses,i;
    sis8300drv_usr *sisuser;
    unsigned reg_val, max_time_nsamples, min_time_nsamples, average_nsamples;
    int state;

    double start, stop, max_time, min_time, time, average_time;
    max_time = average_time = 0;
    average_nsamples = 0;
    min_time = 1000000000000;

    if (argc == 3) {
        sisuser = malloc(sizeof(sis8300drv_usr));
        sisuser->file = argv[1];
        nbr_of_pulses = (int)strtoul(argv[2], NULL, 16);
    }else{
        printf("Usage: %s [device_node], [nbr of pulses]\n", argv[0]);
        return -1;
    }

    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }


    for(i=0; i<nbr_of_pulses; i++) {
        //status = sis8300drv_reg_write(sisuser, 0x10, 0x2);
	start = time_msec();
        
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
	stop = time_msec();        
	usleep(68000);
        status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
        state = print_state(reg_val);
        if (state != 1){
            printf("Wrong state! Expected state: IDLE\n");
            return -1;
        }
        time = stop - start;
        status = sis8300drv_reg_read(sisuser, LLRF_SAMPLE_CNT, &reg_val);
        
        if (time > max_time) { max_time = time; max_time_nsamples = reg_val;}
        if (time < min_time) { min_time = time; min_time_nsamples = reg_val;}

        printf("Pulse %d done, time %f, ADC nsamples %u\n",i+1, time, reg_val);
    }

    printf("All pulses received. Pulse count: %d,\n max_time: %f, max_time_nsamples %u,\n min_time %f, min_time_nsamples %u\n",
        i, max_time, max_time_nsamples, min_time, min_time_nsamples);
/*
    
    for(i=0; i<nbr_of_pulses; i++) {
        status = sis8300drv_reg_write(sisuser, 0x10, 0x2);
        start = time_msec();
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
	// write pulse done, start waiting for trigger and mesure how long it takes for us to get it
        status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x80);
	status = sis8300drv_wait_irq(sisuser, irq_type_usr, 0);
	stop = time_msec();
        usleep(68000);
        status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
        state = print_state(reg_val);
        if (state != 1){
            printf("Wrong state! Expected state: IDLE\n");
            return -1;
        }
	

        time = stop - start;
        average_time += time;
        status = sis8300drv_reg_read(sisuser, LLRF_SAMPLE_CNT, &reg_val);
        
	average_nsamples += reg_val;
        if (time > max_time) { max_time = time; max_time_nsamples = reg_val;}
        if (time < min_time) { min_time = time; min_time_nsamples = reg_val;}

        printf("Pulse %d done, time %f, ADC nsamples %u\n",i+1, time, reg_val);
    }

    printf("All pulses received. Pulse count: %d,\n time statistics for waiting on luse done (after arming untill a PULSE_DONE IS RECIVED:\n max_time: %f, max_time_nsamples %u,\n min_time %f, min_time_nsamples %u,\n, average_time %f, average_nsamples %u\n",
        i, max_time, max_time_nsamples, min_time, min_time_nsamples, average_time/(double)i, average_nsamples/i);

*/
    return(0);
}
