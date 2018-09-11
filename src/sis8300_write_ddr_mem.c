#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>
#define __USE_BSD
#include <math.h>

#include <time.h>
#include "sis8300drv.h"
#include "sis8300_reg.h"

#include "sis8300_llrf_reg.h"
#include "sis8300_llrf_utils.h"

#define LED_ON  0x00000001
#define LED_OFF 0x00010000

int create_data(unsigned* data, unsigned size, unsigned data_type, unsigned shift) {
    int i;
    int value;
    float f,t,a,s,dt;
    if ( data_type == 0 ){
        for(i = 0; i < size; i++){
            data[i] = 0 | data[i];
        }
    }else if ( data_type == 1) {
        for(i = 0; i < size; i++){
            data[i] = (0xFFFF<<shift) | data[i];
        }
    }else if ( data_type == 2) {
        value = 0x0001;
        for(i = 0; i < size; i++){
            data[i] = (value<<shift) | data[i];
            value+=1;
        }
    }else if ( data_type == 3) {
        value = 0xFFFF;
        for(i = 0; i < size; i++){
            data[i] = (value<<shift) | data[i];
            value-=1;
        }
    }else if ( data_type == 4) {
        value = 0x7FFF;
        for(i = 0; i < size; i++){
            data[i] = (value<<shift) | data[i];
        }
    }else if ( data_type == 5) {
        value = 0x8001;
        for(i = 0; i < size; i++){
            data[i] = (value<<shift) | data[i];
        }
    }else if ( data_type == 6) {
        value = 0x00000000;
        for(i = 0; i < size; i++){
            data[i] = value;
            value++;
        }
    }else if ( data_type == 7) {
        value = 0x8001;
        // Do nothing, use with 6
    }else if ( data_type == 8) {
        dt=0.0005;
        t=0;
        a=4000;
        f=1;
        for(i = 0; i < size; i++){
            s=a*sin(2*M_PI*f*t);
            value=(int)s;
            data[i] = ((0xFFFF<<shift)&(value<<shift)) | data[i];
            t+=dt;
        }
    }else if ( data_type == 9) {
        value = 0x0000;
        for(i = 0; i < size; i++){
            data[i] = (value<<shift) | data[i];
            if (i % 8 == 0) {
                value+=128;
            }
        }
    }else if ( data_type == 10) {
        value = 0x3244; // PI/2
        for(i = 0; i < size; i++){
            data[i] = (value<<shift) | data[i];
        }
    }else if ( data_type == 99 ){
        for(i = 0; i < size; i++){
            data[i] = 0;
        }
    }else{
        printf("Data_type error: %d is not supported\n", data_type);
        return -1;
    }
    return 0;
}

// call to start timer
struct timespec timer_start(){
    struct timespec start_time;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &start_time);
    return start_time;
}

// call when you want time diff in nano sec
long timer_end(struct timespec start_time){
    struct timespec end_time;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &end_time);
    long diffInNanos = end_time.tv_nsec - start_time.tv_nsec;
    return diffInNanos;
}

int main(int argc, char **argv) {
    int status;
    sis8300drv_usr *sisuser;
    int i;
    unsigned blocksize = 8; // rd/wr mem must be in 256 bit blocks, i.e. 8 IQ-points
    unsigned offset;
    unsigned size;
    unsigned *data;
    unsigned *readback;
    unsigned data_size;
    unsigned data_type_i;
    unsigned data_type_q;
    unsigned validate;
    clock_t x;
    clock_t y;

    if (argc < 6 || argc > 7) {
        printf("Usage: %s [device_node], [memory offset], [size (in number of blocks of 8-IQ points(8*2*16=256 bits))], [data_type_i data_type_q], opt:{validate (0|1)}\n", argv[0]);
        printf("data_type: 0 -> all zeros\n");
        printf("data_type: 1 -> all ones\n");
        printf("data_type: 2 -> increasing, start value 1\n");
        printf("data_type: 3 -> decreasing, start value 0xFFFF\n");
        printf("data_type: 4 -> Max, 0x7FFF\n");
        printf("data_type: 5 -> Min, 0x8001\n");
        printf("data_type: 6 -> increasing, 32-bit value\n");
        printf("data_type: 7 -> Do nothing, use with 6\n");
        printf("data_type: 8 -> Sinus\n");
        printf("data_type: 9 -> stair, every 8 step inc with 128, start 0x0\n");
        printf("data_type:10 -> PI\n");
        return -1;
    } else if (argc == 6) {
        validate  = 0;
    } else if (argc == 7) {
        validate  = (unsigned)strtoul(argv[6], NULL, 16);
    }

    // INPUTS
    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];
    offset      = (unsigned)strtoul(argv[2], NULL, 16);
    size        = blocksize * (unsigned)strtoul(argv[3], NULL, 16);
    data_type_i = (unsigned)strtoul(argv[4], NULL, 16);
    data_type_q = (unsigned)strtoul(argv[5], NULL, 16);
    
    // Check offset
    if (offset % 32 != 0){
        printf("Address NOT 32 byte aligned!\n");
        return -1;
    }

    // Create data
    data_size = sizeof(unsigned) * size;
    printf("Data size: %d Bytes\n", data_size);
    if (data_size % 32 != 0){
        return -1;
    }
    data      = malloc(data_size);
    readback  = malloc(data_size);

    create_data(data,size,99,0); // zero data
    create_data(data,size,data_type_q,0); // set Q part
    create_data(data,size,data_type_i,16); // set I part

    // DEBUG
    printf("Data that will be written:\n");
    for(i = 0; i < size; i++){
        printf("Data 0x%04X: 0x%08X\n", i,data[i]);
    }


    // Open device
    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }

    // Write DDR
    printf("Write CMD: offset = 0x%08X, data_size = %d bytes\n", offset, data_size);

//    struct timespec vartime = timer_start();  // begin a timer called 'vartime'
    status = sis8300drv_write_ram(sisuser, offset, data_size, data);
//    long time_elapsed_nanos = timer_end(vartime);
//    printf("2 MB written in (nanoseconds): %ld\n", time_elapsed_nanos);
    if(status < 0){
	printf("write error: %i\n", status);
	exit(-1);
    }
     
    // Read back
    if(validate){
        status = sis8300drv_read_ram(sisuser, offset, data_size, readback);
        if(status < 0){
	    printf("readback error: %i\n", status);
	    exit(-1);
        }

        printf("readback:\n");
        for(i = 0; i < size; i++){
            printf("Data 0x%04X: 0x%08X\n", i,readback[i]);
        }
    }

    sis8300drv_close_device(sisuser);

    return(0);
}



