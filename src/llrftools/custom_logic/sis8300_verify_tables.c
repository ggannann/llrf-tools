#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"
#include "sis8300_llrf_utils.h"

#include "sis8300_llrf_reg.h"

#define LED_ON  0x00000001
#define LED_OFF 0x00010000

int main(int argc, char **argv) {
    int status;
    sis8300drv_usr *sisuser;
    int i;
    unsigned offset_pi;
    unsigned offset_table;
    unsigned size_rampup;
    unsigned size_beam;
    unsigned size_pi_cnt;
    unsigned sp_mem_size;
    unsigned ff_mem_size;
    unsigned pi_mem_size;
    unsigned size_used_sp;
    unsigned size_used_ff;
    unsigned pulse_type;
    unsigned *readback_pi;
    unsigned *readback_table;
    unsigned reg_value_rb;
    unsigned data_size;
    unsigned error;
    unsigned start;
    unsigned end;
    signed i_table,q_table;
    signed i_val,q_val;
    unsigned SP_mode;

    if (argc < 3 || argc > 3) {
        printf("Usage: %s [device_node] SP_mode [0|1]\n", argv[0]);
        return -1;
    }

    // INPUTS
    sisuser       = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];
    SP_mode = (unsigned)strtoul(argv[2], NULL, 16);

    // Open device
    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }

    // Read used Pulse type
    read_reg_cl(sisuser, LLRF_GIP,&reg_value_rb);
    pulse_type    = (unsigned)reg_value_rb>>16;
    printf("Pulse_type: %d\n", pulse_type);

    // read sizes and pi_err_base_addr and sp_base_addr
    read_reg_cl(sisuser, LLRF_PI_ERR_MEM_SIZE,&reg_value_rb);
    pi_mem_size   = reg_value_rb*8;
    read_reg_cl(sisuser, LLRF_MEM_CTRL_4_PARAM,&reg_value_rb);
    offset_pi = reg_value_rb;

    if(SP_mode==1){
        read_reg_cl(sisuser, LLRF_PULSE_START_CNT,&reg_value_rb);
        size_rampup = reg_value_rb;
        size_beam   = 0;
        read_reg_cl(sisuser, LLRF_LUT_CTRL_2_PARAM,&reg_value_rb);
        size_used_sp   = reg_value_rb;
        read_reg_cl(sisuser, LLRF_MEM_CTRL_3_PARAM,&reg_value_rb);
        sp_mem_size = ((reg_value_rb&0xFFFF0000)>>16)*8;
        read_reg_cl(sisuser, LLRF_MEM_CTRL_2_PARAM,&reg_value_rb);
        offset_table = reg_value_rb + sp_mem_size*4*pulse_type;

        // limit nbr of samples to PI mem size and to size_used_sp
        printf("size_rampup %d, pi_mem_size %d, sp_mem_size %d, size_used_sp %d\n", size_rampup,pi_mem_size,sp_mem_size,size_used_sp);
        if(size_rampup > pi_mem_size){
            size_rampup = pi_mem_size;
        }
        if(size_rampup > size_used_sp){
            size_rampup = size_used_sp;
        }
        printf("size_rampup %d\n", size_rampup);
    }else{ // FF-mode LLRF_PI_ERR_CNT
        read_reg_cl(sisuser, LLRF_PI_ERR_CNT,&reg_value_rb);
        size_pi_cnt   = reg_value_rb;
        read_reg_cl(sisuser, LLRF_PULSE_START_CNT,&reg_value_rb);
        size_rampup   = reg_value_rb;
        read_reg_cl(sisuser, LLRF_PULSE_ACTIVE_CNT,&reg_value_rb);
        size_beam   = reg_value_rb;
        read_reg_cl(sisuser, LLRF_LUT_CTRL_1_PARAM,&reg_value_rb);
        size_used_ff   = 0x0003FFFF&reg_value_rb;
        read_reg_cl(sisuser, LLRF_MEM_CTRL_3_PARAM,&reg_value_rb);
        ff_mem_size = (0x0000FFFF&reg_value_rb)*8;
        read_reg_cl(sisuser, LLRF_MEM_CTRL_1_PARAM,&reg_value_rb);
        offset_table = reg_value_rb + ff_mem_size*4*pulse_type;

        // limit nbr of samples to PI mem size and to size_used_ff
        printf("size_rampup %d, size_beam %d, pi_mem_size %d, ff_mem_size %d, size_used_ff %d\n", size_rampup,size_beam,pi_mem_size,ff_mem_size,size_used_ff);
        if((size_rampup+size_beam) > pi_mem_size){
            size_beam = pi_mem_size - size_rampup;
        }
        if(size_beam > size_used_ff){
            size_beam = size_used_ff;
        }
        printf("size_rampup %d, size_beam %d, size_beam+size_rampup %d, size_pi_cnt %d\n", size_rampup,size_beam,size_rampup+size_beam,size_pi_cnt);
    }

    // Mem allocation
    data_size = sizeof(unsigned) * pi_mem_size;
//    printf("Data size: %d Bytes\n", data_size);
    if (data_size % 64 != 0){
        return -1;
    }
    readback_pi    = malloc(data_size);
    readback_table = malloc(data_size);

    // Read back PI-error
    printf("Read CMD PI: offset = 0x%08X, data_size = %d bytes\n", offset_pi, data_size);
    status = sis8300drv_read_ram(sisuser, offset_pi, data_size, readback_pi);
    if(status < 0){
       printf("readback error pi: %i\n", status);
       exit(-1);
    }

    // Read back SP or FF-table
    printf("Read CMD table: offset = 0x%08X, data_size = %d bytes\n", offset_table, data_size);
    status = sis8300drv_read_ram(sisuser, offset_table, data_size, readback_table);
    if(status < 0){
       printf("readback error table: %i\n", status);
       exit(-1);
    }

    if(SP_mode==1){
        start = 0;
        end   = size_rampup;
    }else{
        start = size_rampup;
        end   = size_beam-2;
    }
    // Verify debug //from 0 to size_rampup+size_beam
//    for(i = 0; i < pi_mem_size-size_rampup; i++){
    for(i = 0; i < 8; i++){
        i_val = ((signed)(readback_pi[i+start]&0xFFFF0000))>>16;
        q_val = ((signed)readback_pi[i+start]<<16)>>16;
        i_table = ((signed)(readback_table[i]&0xFFFF0000))>>16;
        q_table = ((signed)readback_table[i]<<16)>>16;
        printf("i: %d, i_val: %d, q_val: %d, i_table: %d, q_table: %d\n", i,i_val, q_val, i_table, q_table);
    }
//    printf("size_rampup %d, size_beam %d, size_beam+size_rampup %d\n", size_rampup,size_beam,size_rampup+size_beam);

    error = 0;
    // Verify
    for(i = 0; i < end; i++){
        i_val = ((signed)(readback_pi[i+start]&0xFFFF0000))>>16;
        q_val = ((signed)readback_pi[i+start]<<16)>>16;
        i_table = ((signed)(readback_table[i]&0xFFFF0000))>>16;
        q_table = ((signed)readback_table[i]<<16)>>16;
        error += abs(i_val-i_table) + abs(q_val-q_table);
    }
    printf("\tError: %d, Pulse_type: %d \n", error,pulse_type);


    sis8300drv_close_device(sisuser);

    return(error);
}




