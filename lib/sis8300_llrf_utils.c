#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300_reg.h"
#include "sis8300drv.h"
#include "sis8300drv_utils.h"

#include "sis8300_llrf_reg.h"
#include "sis8300_llrf_utils.h"

void write_reg_cl(sis8300drv_usr *sisuser, unsigned reg_addr, unsigned reg_val){
    int status;

    status = sis8300drv_reg_write(sisuser, reg_addr, reg_val);
    if(status < 0){
        printf("write error: %i\n", status);
        printf("wrote: 0x%08X to: 0x%03x\n", reg_val, reg_addr);
        exit(-1);
    }
}

void read_reg_cl(sis8300drv_usr *sisuser, unsigned reg_addr, unsigned *reg_val){
    int status;

    status = sis8300drv_reg_read(sisuser, reg_addr, reg_val);
    if(status < 0){
        printf("read error: %i\n", status);
        exit(-1);
        printf("readback val: 0x%08X, from reg: 0x%08X\n", *reg_val, reg_addr);
    }
}

int print_state(unsigned reg_val){
    int state;

    state=(int)reg_val&0x00000007;
    if(state == 0){
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
    return state;
}


void print_reg_cl(unsigned reg_addr, unsigned reg_val){
    signed value;
    unsigned val_u;
    float value_f;
    float value_deg;
    int i;

    switch (reg_addr){
        case LLRF_ID:
            printf("LLRF_ID: 0x%08X\n", reg_val);
            printf("\tHW ID: 0x%04X\n", reg_val>>16);
            printf("\tFW MAJOR: 0x%02X\n", (reg_val&0x0000FF00)>>8);
            printf("\tFW MINOR: 0x%02X\n", (reg_val&0x000000FF));
            break;
        case LLRF_INST_ID:
            printf("LLRF_INST_ID: 0x%08X\n", reg_val);
            break;
        case LLRF_GOP:
            printf("LLRF_GOP: 0x%08X\n", reg_val);
            printf("\tPulse_done_IRQ count: 0x%01X\n", (reg_val&0xFFFF0000)>>16);
            printf("\tVM-Magnitude limit active: 0x%01X\n", (reg_val&0x00000100)>>8);
            printf("\tOverflow PI-ctrl I-part: 0x%01X\n", (reg_val&0x00000080)>>7);
            printf("\tOverflow PI-ctrl Q-part: 0x%01X\n", (reg_val&0x00000040)>>6);
            printf("\tRead error: 0x%01X\n", (reg_val&0x00000020)>>5);
            printf("\tWrite error: 0x%01X\n", (reg_val&0x00000010)>>4);
            printf("\tPMS active: 0x%01X\n", (reg_val&0x00000008)>>3);
            printf("\tFSM State: 0x%01X\n", (reg_val&0x00000007));
            break;
        case LLRF_GIP:
            printf("LLRF_GIP: 0x%08X\n", reg_val);
            printf("\tPulse type: 0x%04X\n", reg_val>>16);
            printf("\tMem storage select: 0x%01X\n", (reg_val&0x0000E000)>>13);
            break;
        case LLRF_GIP_S:
            printf("LLRF_GIP_S: 0x%08X\n", reg_val);
            printf("\tPulse type: 0x%04X\n", reg_val>>16);
            printf("\tMem storage select: 0x%01X\n", (reg_val&0x0000E000)>>13);
            break;
        case LLRF_GIP_C:
            printf("LLRF_GIP_C: 0x%08X\n", reg_val);
            printf("\tPulse type: 0x%04X\n", reg_val>>16);
            printf("\tMem storage select: 0x%01X\n", (reg_val&0x0000E000)>>13);
            break;
        case LLRF_PI_1_K:
            printf("LLRF_PI_1_K: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<23);
            printf("\tK: %f\n", value_f);
            break;
        case LLRF_PI_1_TS_DIV_TI:
            printf("LLRF_PI_1_TS_DIV_TI: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<23);
            printf("\tTS_DIV_TI: %f\n", value_f);
            break;
        case LLRF_PI_1_SAT_MAX:
            printf("LLRF_PI_1_SAT_MAX: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<15);
            printf("\tSAT_MAX: %f\n", value_f);
            break;
        case LLRF_PI_1_SAT_MIN:
            printf("LLRF_PI_1_SAT_MIN: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<15);
            printf("\tSAT_MIN: %f\n", value_f);
            break;
        case LLRF_PI_1_CTRL:
            printf("LLRF_PI_1_CTRL : 0x%08X\n", reg_val);
            printf("\tFF_TBL_SPEED : 0x%01X\n", (reg_val&0x000003C0)>>6);
            printf("\tOUTPUT SOURCE: 0x%01X\n", (reg_val&0x0000003C)>>2);
            printf("\tUse Fixed_FF : 0x%01X\n", (reg_val&0x00000002)>>1);
            printf("\tUse Fixed_SP : 0x%01X\n", (reg_val&0x00000001));
            break;
        case LLRF_PI_1_FIXED_SP:
            printf("LLRF_PI_1_FIXED_SP: 0x%08X\n", reg_val);
            value = (signed)(reg_val<<16)>>16;
            value_f = (float)value / (2<<14);
            printf("\tFIXED_SP:  %d\n", value);
            printf("\tFIXED_SP: %f\n", value_f);
            break;
        case LLRF_PI_1_FIXED_FF:
            printf("LLRF_PI_1_FIXED_FF: 0x%08X\n", reg_val);
            value = (signed)reg_val<<16;
            value = value>>16;
            value_f = (float)value / (2<<14);
            printf("\tFIXED_FF: %f\n", value_f);
            break;
        case LLRF_PI_2_K:
            printf("LLRF_PI_2_K: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<23);
            printf("\tK: %f\n", value_f);
            break;
        case LLRF_PI_2_TS_DIV_TI:
            printf("LLRF_PI_2_TS_DIV_TI: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<23);
            printf("\tTS_DIV_TI: %f\n", value_f);
            break;
        case LLRF_PI_2_SAT_MAX:
            printf("LLRF_PI_1_SAT_MAX: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<15);
            printf("\tSAT_MAX: %f\n", value_f);
            break;
        case LLRF_PI_2_SAT_MIN:
            printf("LLRF_PI_1_SAT_MIN: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<15);
            printf("\tSAT_MIN: %f\n", value_f);
            break;
        case LLRF_PI_2_CTRL:
            printf("LLRF_PI_2_CTRL: 0x%08X\n", reg_val);
            printf("\tOUTPUT SOURCE: 0x%01X\n", (reg_val&0x0000003C)>>2);
            printf("\tUse Fixed_FF: 0x%01X\n", (reg_val&0x00000002)>>1);
            printf("\tUse Fixed_SP: 0x%01X\n", (reg_val&0x00000001));
            break;
        case LLRF_PI_2_FIXED_SP:
            printf("LLRF_PI_2_FIXED_SP: 0x%08X\n", reg_val);
            value = (signed)(reg_val<<16)>>16;
            value_f = (float)value / (2<<14);
            printf("\tFIXED_SP:  %d\n", value);
            printf("\tFIXED_SP: %f\n", value_f);
            break;
        case LLRF_PI_2_FIXED_FF:
            printf("LLRF_PI_2_FIXED_FF: 0x%08X\n", reg_val);
            value = (signed)reg_val<<16;
            value = value>>16;
            value_f = (float)value / (2<<14);
            printf("\tFIXED_FF: %f\n", value_f);
            break;
        case LLRF_IQ_CTRL:
            printf("LLRF_IQ_CTRL: 0x%08X\n", reg_val);
            printf("\tCavity input delay: %d\n",(reg_val&0x00001F80)>>7);
            printf("\tFreq offset mode: 0x%01X\n",(reg_val&0x00000040)>>6);
            printf("\tForce ref to zero: 0x%01X\n",(reg_val&0x00000020)>>5);
            printf("\tOutput Select: 0x%01X\n",(reg_val&0x0000001C)>>2);
            printf("\tCavity input delay ENABLE: 0x%01X\n", (reg_val&0x00000002)>>1);
            printf("\tUse rotation matrix: 0x%01X\n", (reg_val&0x00000001)>>0);
            break;
        case LLRF_IQ_ANGLE:
            printf("LLRF_IQ_ANGLE: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<15);
            value_deg = value_f*360/6.283185307179586;
            printf("\tAngle offset: %f (%f degrees)\n", value_f,value_deg);
            break;
        case LLRF_IQ_DC_OFFSET:
            printf("NOT USED AT THE MOMENT\n", reg_val);
//            value = (signed)(reg_val&0xFFFF0000)>>16;
//            value_f = (float)value/(2<<14);
//            printf("\tDC-offset Cavity: %d\n",(reg_val&0xFFFF0000)>>16);
//            printf("\tDC-offset Cavity (norm): %f\n", value_f);
//            value = (signed)(reg_val<<16)>>16;
//            value_f = (float)value/(2<<14);
//            printf("\tDC-offset Reference: %d\n", (signed)(reg_val<<16)>>16);
//            printf("\tDC-offset Reference (norm): %f\n", value_f);
            break;
        case LLRF_VM_CTRL:
            printf("LLRF_VM_CTRL: 0x%08X\n", reg_val);
            printf("\tUse VM predistortion: 0x%01X\n", (reg_val&0x00000040)>>6);
            printf("\tForced Angle: 0x%01X\n", (reg_val&0x00000020)>>5);
            printf("\tForced Magnitude: 0x%01X\n", (reg_val&0x00000010)>>4);
            printf("\tSWAP IQ: 0x%01X\n", (reg_val&0x00000008)>>3);
            printf("\tUse magnitude limit: 0x%01X\n", (reg_val&0x00000004)>>2);
            printf("\tInverse output I-part: 0x%01X\n", (reg_val&0x00000002)>>1);
            printf("\tInverse output Q-part: 0x%01X\n", (reg_val&0x00000001)>>0);
            break;
        case LLRF_VM_MAG_LIMIT:
            printf("LLRF_VM_MAG_LIMIT: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<15);
            printf("\tMagnitude limit: %f\n", value_f);
            break;
        case LLRF_SAMPLE_CNT:
            printf("LLRF_SAMPLE_CNT: 0x%08X\n", reg_val);
            printf("\tNbr of stored samples: %d\n", reg_val);
            break;
        case LLRF_PULSE_START_CNT:
            printf("LLRF_PULSE_START_CNT: 0x%08X\n", reg_val);
            printf("\tNbr of pi errors until pulse start: %d\n", reg_val);
            break;
        case LLRF_PULSE_ACTIVE_CNT:
            printf("LLRF_PULSE_ACTIVE_CNT: 0x%08X\n", reg_val);
            printf("\tNbr of pi errors during beam: %d\n", reg_val);
            break;
        case LLRF_LUT_CTRL_1_PARAM:
            printf("LLRF_LUT_CTRL_1_PARAM: 0x%08X\n", reg_val);
            printf("\tCircular buffer on: 0x%01X\n", (reg_val&0x00080000)>>19);
            printf("\tUsed FF LUT size: %d\n", (reg_val&0x0003FFFF));
            break;
        case LLRF_LUT_CTRL_2_PARAM:
            printf("LLRF_LUT_CTRL_2_PARAM: 0x%08X\n", reg_val);
            printf("\tUsed SP LUT size: %d\n", (reg_val&0x0003FFFF));
            break;
        case LLRF_MEM_CTRL_1_PARAM:
            printf("LLRF_MEM_CTRL_1_PARAM: 0x%08X\n", reg_val);
            printf("\tFeed-Forward base address in DDR: 0x%08X\n", reg_val);
            break;
        case LLRF_MEM_CTRL_2_PARAM:
            printf("LLRF_MEM_CTRL_2_PARAM: 0x%08X\n", reg_val);
            printf("\tSet-Point base address in DDR: 0x%08X\n", reg_val);
            break;
        case LLRF_MEM_CTRL_3_PARAM:
            printf("LLRF_MEM_CTRL_3_PARAM: 0x%08X\n", reg_val);
            printf("\tSP LUT table size, in 32-byte blocks: %d\n", (reg_val&0xFFFF0000)>>16);
            printf("\tFF LUT table size, in 32-byte blocks: %d\n", (reg_val&0xFFFF));
            break;
        case LLRF_MEM_CTRL_4_PARAM:
            printf("LLRF_MEM_CTRL_4_PARAM: 0x%08X\n", reg_val);
            printf("\tPI-error base address in DDR: 0x%08X\n", reg_val);
            break;
        case LLRF_PI_ERR_MEM_SIZE:
            printf("LLRF_PI_ERR_MEM_SIZE: 0x%08X\n", reg_val);
            printf("\tPI Error size in DDR, in 32-byte blocks: %d\n", reg_val&0xFFFF);
            break;
        case LLRF_PI_ERR_CNT:
            printf("LLRF_PI_ERR_CNT: 0x%08X\n", reg_val);
            printf("\tNbr of pi-errors stored in DDR: %d\n", reg_val);
            break;
        case LLRF_BOARD_SETUP:
            printf("LLRF_BOARD_SETUP: 0x%08X\n", reg_val);
            printf("\tDebug2mem: 0x%01X\n", (reg_val&0x000F0000)>>16);
            val_u = (unsigned)(reg_val&0x00010000)>>16;
            if(val_u == 1){printf("\t\tADC2MEM: signal 3 and 4 are used for internal debug signals\n");}
            val_u = (unsigned)(reg_val&0x00020000)>>17;
            if(val_u == 1){printf("\t\tADC2MEM: signal 5 and 6 are used for internal debug signals\n");}
            val_u = (unsigned)(reg_val&0x00040000)>>18;
            if(val_u == 1){printf("\t\tADC2MEM: signal 7 and 8 are used for internal debug signals\n");}
            val_u = (unsigned)(reg_val&0x00080000)>>19;
            if(val_u == 1){printf("\t\tADC2MEM: signal 9 and 10 are used for internal debug signals\n");}
            printf("\tHARLINK level low: 0x%01X\n", (reg_val&0x0000F000)>>12);
            printf("\tHARLINK level enabled: 0x%01X\n", (reg_val&0x00000F00)>>8);
            printf("\tForce HARLINK out: 0x%01X\n", (reg_val&0x000000F0)>>4);
            printf("\tARB ctrl: 0x%01X\n", (reg_val&0x0000000C)>>3);
            printf("\tTrigger setup: %d\n", (reg_val&0x3));
            break;
        case LLRF_NEAR_IQ_1_PARAM:
            printf("LLRF_NEAR_IQ_1_PARAM: 0x%08X\n", reg_val);
            printf("\tN: %d\n", (reg_val&0xFFFF0000)>>16);
            printf("\tM: %d\n", (reg_val&0xFFFF));
            break;
        case LLRF_NEAR_IQ_2_PARAM:
            printf("LLRF_NEAR_IQ_2_PARAM: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<29);
            printf("\ttwo_div_N: %f\n", value_f);
            break;
        case LLRF_NEAR_IQ_DATA:
            printf("LLRF_NEAR_IQ_DATA: 0x%08X\n", reg_val);
            printf("\tsin/cos fact: %d\n", ((signed)(reg_val))>>30);
            break;
        case LLRF_NEAR_IQ_ADDR:
            printf("LLRF_NEAR_IQ_ADDR: 0x%08X\n", reg_val);
            printf("\tAddr: %d\n", (reg_val&0x1FF));
            break;
        case LLRF_FILTER_S:
            printf("LLRF_FILTER_S: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<29);
            printf("\tS: %0.9f\n", (value_f/2));
            break;
        case LLRF_FILTER_C:
            printf("LLRF_FILTER_C: 0x%08X\n", reg_val);
            value = (signed)reg_val;
            value_f = (float)value / (2<<29);
            printf("\tC: %0.9f\n", (value_f/2));
            break;
        case LLRF_FILTER_A_CTRL:
            printf("LLRF_FILTER_A_CTRL: 0x%08X\n", reg_val);
            val_u = (unsigned)reg_val>>16;
            value_f = (float)val_u / (2<<15);
            printf("\tAlpha: %f\n", (value_f));
            printf("\tFilter_stop = %d\n", (reg_val&0x08)>>3);
            printf("\tFilter_start = %d\n", (reg_val&0x04)>>2);
            printf("\tFilter_on = %d\n", (reg_val&0x3));
            break;
        case LLRF_CAV_MA:
            printf("LLRF_CAV_MA: 0x%08X\n", reg_val);
            val_u = ((unsigned)(0xFFFF0000&reg_val))>>16;
            value_f = (float)val_u / (2<<14);
            printf("\tCav Magnitude: %f \n", value_f);
            value = ((signed)((0x0000FFFF&reg_val)<<16))>>16;
            value_f = (float)value / (2<<12);
            value_deg = value_f*360/6.283185307179586;
            printf("\tCav Angle: %f (%f degrees)\n", value_f,value_deg);
            break;
        case LLRF_REF_MA:
            printf("LLRF_REF_MA: 0x%08X\n", reg_val);
            val_u = ((unsigned)(0xFFFF0000&reg_val))>>16;
            value_f = (float)val_u / (2<<14);
            printf("\tRef Magnitude: %f \n", value_f);
            value = ((signed)((0x0000FFFF&reg_val)<<16))>>16;
            value_f = (float)value / (2<<12);
            value_deg = value_f*360/6.283185307179586;
            printf("\tRef Angle: %f (%f degrees)\n", value_f,value_deg);
            break;
        case LLRF_MON_PARAM_1:
            printf("LLRF_MON_PARAM_1: 0x%08X\n", reg_val);
            for(i=0;i<4;i++){
                printf("Input Channel %d:\n",i+3);
                printf("\tDC-signal: 0x%01X\n", (reg_val&0x00000080)>>7);
                printf("\tTrigger interlock: 0x%01X\n", (reg_val&0x00000040)>>6);
                printf("\tTrigger PMS: 0x%01X\n", (reg_val&0x00000020)>>5);
                printf("\tLess-then: 0x%01X\n", (reg_val&0x00000010)>>4);
                printf("\tStop: 0x%01X\n", (reg_val&0x0000000C)>>2);
                printf("\tStart: 0x%01X\n", (reg_val&0x00000003)>>0);
                reg_val = reg_val>>8;
            }
            break;
        case LLRF_MON_PARAM_2:
            printf("LLRF_MON_PARAM_2: 0x%08X\n", reg_val);
            for(i=0;i<4;i++){
                printf("Input Channel %d:\n",i+7);
                printf("\tDC-signal: 0x%01X\n", (reg_val&0x00000080)>>7);
                printf("\tTrigger interlock: 0x%01X\n", (reg_val&0x00000040)>>6);
                printf("\tTrigger PMS: 0x%01X\n", (reg_val&0x00000020)>>5);
                printf("\tLess-then: 0x%01X\n", (reg_val&0x00000010)>>4);
                printf("\tStop: 0x%01X\n", (reg_val&0x0000000C)>>2);
                printf("\tStart: 0x%01X\n", (reg_val&0x00000003)>>0);
                reg_val = reg_val>>8;
            }
            break;
        case LLRF_MON_LIMIT_1:
            printf("LLRF_MON_LIMIT_1: 0x%08X\n", reg_val);
            val_u = (unsigned)((reg_val&0x0000FFFF)>>0);
            value_f = (float)val_u / (2<<15);
            printf("\tLimit inp_ch 3: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0xFFFF0000)>>16);
            value_f = (float)val_u / (2<<15);
            printf("\tLimit inp_ch 4: 0x%01X (%f)\n", val_u,value_f);
            break;
        case LLRF_MON_LIMIT_2:
            printf("LLRF_MON_LIMIT_2: 0x%08X\n", reg_val);
            val_u = (unsigned)((reg_val&0x0000FFFF)>>0);
            value_f = (float)val_u / (2<<15);
            printf("\tLimit inp_ch 5: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0xFFFF0000)>>16);
            value_f = (float)val_u / (2<<15);
            printf("\tLimit inp_ch 6: 0x%01X (%f)\n", val_u,value_f);
            break;
        case LLRF_MON_LIMIT_3:
            printf("LLRF_MON_LIMIT_3: 0x%08X\n", reg_val);
            val_u = (unsigned)((reg_val&0x0000FFFF)>>0);
            value_f = (float)val_u / (2<<15);
            printf("\tLimit inp_ch 7: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0xFFFF0000)>>16);
            value_f = (float)val_u / (2<<15);
            printf("\tLimit inp_ch 8: 0x%01X (%f)\n", val_u,value_f);
            break;
        case LLRF_MON_LIMIT_4:
            printf("LLRF_MON_LIMIT_4: 0x%08X\n", reg_val);
            val_u = (unsigned)((reg_val&0x0000FFFF)>>0);
            value_f = (float)val_u / (2<<15);
            printf("\tLimit inp_ch 9 : 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0xFFFF0000)>>16);
            value_f = (float)val_u / (2<<15);
            printf("\tLimit inp_ch 10: 0x%01X (%f)\n", val_u,value_f);
            break;
        case LLRF_MON_STATUS:
            printf("LLRF_MON_STATUS: 0x%08X\n", reg_val);
            printf("\t       \t    Current   \t    Latched\t     Latched  \t     Latched\n");
            printf("\tInp_ch \t  Alarm Status\t   Interlock\t       PMS   \t      Alarm \n");
            for(i=0;i<8;i++){
                printf("\t  %d\t\t%d\t\t%d\t\t%d\t\t%d\n", i+3,(reg_val&0x01000000)>>24,(reg_val&0x00010000)>>16,(reg_val&0x00000100)>>8,reg_val&0x00000001);
                reg_val = reg_val >> 1;
            }
            break;
        case LLRF_MON_STATUS_MAG_1:
            printf("LLRF_MON_STATUS_MAG_1: 0x%08X\n", reg_val);
            val_u = (unsigned)((reg_val&0x000000FF)>>0);
            value_f = (float)val_u / (2<<7);
            printf("\tCurrent Mag ch-3: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0x0000FF00)>>8);
            value_f = (float)val_u / (2<<7);
            printf("\tMax-Min Mag ch-3: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0x00FF0000)>>16);
            value_f = (float)val_u / (2<<7);
            printf("\tCurrent Mag ch-4: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0xFF000000)>>24);
            value_f = (float)val_u / (2<<7);
            printf("\tMax-Min Mag ch-4: 0x%01X (%f)\n", val_u,value_f);
            break;
        case LLRF_MON_STATUS_MAG_2:
            printf("LLRF_MON_STATUS_MAG_2: 0x%08X\n", reg_val);
            val_u = (unsigned)((reg_val&0x000000FF)>>0);
            value_f = (float)val_u / (2<<7);
            printf("\tCurrent Mag ch-5: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0x0000FF00)>>8);
            value_f = (float)val_u / (2<<7);
            printf("\tMax-Min Mag ch-5: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0x00FF0000)>>16);
            value_f = (float)val_u / (2<<7);
            printf("\tCurrent Mag ch-6: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0xFF000000)>>24);
            value_f = (float)val_u / (2<<7);
            printf("\tMax-Min Mag ch-6: 0x%01X (%f)\n", val_u,value_f);
            break;
        case LLRF_MON_STATUS_MAG_3:
            printf("LLRF_MON_STATUS_MAG_3: 0x%08X\n", reg_val);
            val_u = (unsigned)((reg_val&0x000000FF)>>0);
            value_f = (float)val_u / (2<<7);
            printf("\tCurrent Mag ch-7: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0x0000FF00)>>8);
            value_f = (float)val_u / (2<<7);
            printf("\tMax-Min Mag ch-7: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0x00FF0000)>>16);
            value_f = (float)val_u / (2<<7);
            printf("\tCurrent Mag ch-8: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0xFF000000)>>24);
            value_f = (float)val_u / (2<<7);
            printf("\tMax-Min Mag ch-8: 0x%01X (%f)\n", val_u,value_f);
            break;
        case LLRF_MON_STATUS_MAG_4:
            printf("LLRF_MON_STATUS_MAG_4: 0x%08X\n", reg_val);
            val_u = (unsigned)((reg_val&0x000000FF)>>0);
            value_f = (float)val_u / (2<<7);
            printf("\tCurrent Mag ch-9: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0x0000FF00)>>8);
            value_f = (float)val_u / (2<<7);
            printf("\tMax-Min Mag ch-9: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0x00FF0000)>>16);
            value_f = (float)val_u / (2<<7);
            printf("\tCurrent Mag ch-10: 0x%01X (%f)\n", val_u,value_f);
            val_u = (unsigned)((reg_val&0xFF000000)>>24);
            value_f = (float)val_u / (2<<7);
            printf("\tMax-Min Mag ch-10: 0x%01X (%f)\n", val_u,value_f);
            break;
        case LLRF_VM_PREDIST_R0:
            printf("LLRF_VM_PREDIST_R0: 0x%08X\n", reg_val);
            value = (signed)(reg_val)>>16;
            value_f = (float)value / (2<<13);
            printf("\tR00:  %d (%f)\n", value,value_f);
            value = (signed)(reg_val<<16)>>16;
            value_f = (float)value / (2<<13);
            printf("\tR01:  %d (%f)\n", value,value_f);
            break;
        case LLRF_VM_PREDIST_R1:
            printf("LLRF_VM_PREDIST_R1: 0x%08X\n", reg_val);
            value = (signed)(reg_val)>>16;
            value_f = (float)value / (2<<13);
            printf("\tR10:  %d (%f)\n", value,value_f);
            value = (signed)(reg_val<<16)>>16;
            value_f = (float)value / (2<<13);
            printf("\tR11:  %d (%f)\n", value,value_f);
            break;
        case LLRF_VM_PREDIST_DC:
            printf("LLRF_VM_PREDIST_DC: 0x%08X\n", reg_val);
            value = (signed)(reg_val)>>16;
            value_f = (float)value / (2<<14);
            printf("\tDC_I:  %d (%f)\n", value,value_f);
            value = (signed)(reg_val<<16)>>16;
            value_f = (float)value / (2<<14);
            printf("\tDC_Q:  %d (%f)\n", value,value_f);
            break;
        case LLRF_IQ_DEBUG1:
            printf("LLRF_IQ_DEBUG1: 0x%08X\n", reg_val);
//            printf("\tI: %d\n", ((signed)(reg_val&0xFFFF0000))>>16);
//            value = (signed)reg_val<<16;
//            value = value>>16;
//            printf("\tQ: %d\n", value);
            printf("\twr_fifo_empty: %d\n", (reg_val&0x20000)>>17);
            printf("\twr_cmd_accept: %d\n", (reg_val&0x10000)>>16);
            printf("\tRESP state: %d\n", (reg_val&0x0FF00)>>8);
            printf("\tACC state: %d\n", (reg_val&0x000FF));
            break;
        case LLRF_IQ_DEBUG2:
            printf("LLRF_IQ_DEBUG2: 0x%08X\n", reg_val);
            printf("\tResp_cnt: %d\n", (reg_val&0xFFFF0000)>>16);
            printf("\tAcc_cnt:  %d\n", (reg_val&0x0000FFFF));
//            value = (signed)reg_val;
//            value_f = (float)value / (2<<26) / 6.2832 * 360;
//            printf("\tpi_error_ang_r (degrees): %f\n", value_f);
            break;
        case LLRF_IQ_DEBUG3:
            printf("LLRF_IQ_DEBUG3: 0x%08X\n", reg_val);
            printf("\tnbr_store_pi_done_r: %d\n", (reg_val&0x0000FFFF));
            printf("\tpi_rd_cnt_r: %d\n", (reg_val&0xFFFF0000)>>16);
//            value = (signed)reg_val;
//            value_f = (float)value / (2<<26) / 6.2832 * 360;
//            printf("\tv (degrees): %f\n", value_f);
            break;
        case LLRF_IQ_DEBUG4:
            printf("LLRF_IQ_DEBUG4: 0x%08X\n", reg_val);
            printf("\twr_data_cnt        : %d\n", (reg_val&0x0FFC0000)>>18);
            printf("\twr_addr_cnt        : %d\n", (reg_val&0x0003FF00)>>8);
            printf("\tcl_wr_granted      : %d\n", (reg_val&0x8)>>3);
            printf("\tcl_wr_granted_sync : %d\n", (reg_val&0x4)>>2);
            printf("\twr_fifo_empty      : %d\n", (reg_val&0x2)>>1);
            printf("\twr_fifo_full       : %d\n", (reg_val&0x1));
//            printf("LLRF_IQ_DEBUG4: 0x%08X\n", reg_val);
//            printf("\tpi_base_addr: %d\n", reg_val);
//            value = (signed)reg_val;
//            value_f = (float)value / (2<<26) / 6.2832 * 360;
//            printf("\tu_r (degrees): %f\n", value_f);
            break;
        case STRUCK_ADC_SAMPLE_CTRL:
            printf("STRUCK_ADC_SAMPLE_CTRL: 0x%08X\n", reg_val);
            break;
    }
}

