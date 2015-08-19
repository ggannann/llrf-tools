#ifndef SIS8300_LLRF_REG_H_
#define SIS8300_LLRF_REG_H_

/* STRUCK USER REGISTERS */
#define STRUCK_ADC_SAMPLE_CTRL  0x11

/* LLRF USER REGISTERS */
#define LLRF_FIRST_REG          0x400
#define LLRF_LAST_REG           0x438

#define LLRF_ID		    	0x400
#define LLRF_INST_ID		0x401
#define LLRF_GOP		0x402
#define LLRF_GIP		0x403
#define LLRF_GIP_S		0x404
#define LLRF_GIP_C		0x405
#define LLRF_PI_1_K		0x406
#define LLRF_PI_1_TS_DIV_TI	0x407
#define LLRF_PI_1_SAT_MAX	0x408
#define LLRF_PI_1_SAT_MIN	0x409
#define LLRF_PI_1_CTRL		0x40A
#define LLRF_PI_1_FIXED_SP	0x40B
#define LLRF_PI_1_FIXED_FF	0x40C
#define LLRF_PI_2_K		0x40D
#define LLRF_PI_2_TS_DIV_TI	0x40E
#define LLRF_PI_2_SAT_MAX       0x40F
#define LLRF_PI_2_SAT_MIN       0x410
#define LLRF_PI_2_CTRL		0x411
#define LLRF_PI_2_FIXED_SP	0x412
#define LLRF_PI_2_FIXED_FF	0x413
#define LLRF_IQ_CTRL		0x414
#define LLRF_IQ_ANGLE		0x415
#define LLRF_IQ_DC_OFFSET       0x416
#define LLRF_VM_CTRL		0x417
#define LLRF_VM_MAG_LIMIT	0x418
#define LLRF_SAMPLE_CNT         0x419
#define LLRF_PULSE_START_CNT	0x41A
#define LLRF_PULSE_ACTIVE_CNT	0x41B
#define LLRF_LUT_CTRL_1_PARAM	0x41C
#define LLRF_LUT_CTRL_2_PARAM   0x41D
#define LLRF_MEM_CTRL_1_PARAM	0x41E
#define LLRF_MEM_CTRL_2_PARAM	0x41F
#define LLRF_MEM_CTRL_3_PARAM	0x420
#define LLRF_MEM_CTRL_4_PARAM   0x421
#define LLRF_PI_ERR_MEM_SIZE    0x422
#define LLRF_PI_ERR_CNT         0x423
#define LLRF_BOARD_SETUP        0x424
#define LLRF_NEAR_IQ_1_PARAM    0x425
#define LLRF_NEAR_IQ_2_PARAM    0x426
#define LLRF_NEAR_IQ_DATA       0x427
#define LLRF_NEAR_IQ_ADDR       0x428
#define LLRF_FILTER_S           0x429
#define LLRF_FILTER_C           0x42A
#define LLRF_FILTER_A_CTRL      0x42B
#define LLRF_CAV_MA             0x42C
#define LLRF_REF_MA             0x42D
#define LLRF_MON_PARAM_1        0x42E
#define LLRF_MON_PARAM_2        0x42F
#define LLRF_MON_LIMIT_1        0x430
#define LLRF_MON_LIMIT_2        0x431
#define LLRF_MON_LIMIT_3        0x432
#define LLRF_MON_LIMIT_4        0x433
#define LLRF_MON_STATUS         0x434
#define LLRF_IQ_DEBUG1   	0x435
#define LLRF_IQ_DEBUG2   	0x436
#define LLRF_IQ_DEBUG3   	0x437
#define LLRF_IQ_DEBUG4   	0x438

/* LLRF USER REGISTERS */
#define LLRF_FIRST_REG_TEST     0x400
#define LLRF_LAST_REG_TEST      0x434

const int reg_attribute[LLRF_LAST_REG_TEST-LLRF_FIRST_REG_TEST + 1][4] = {
     // {Reg type (0=r/w 1=read only const,2=special,3=read only), Size, Default value, REG_ID}
        { 1, 0xFFFFFFFF, 0xB00B0203, LLRF_ID},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_INST_ID},
        { 3, 0xFFFF0000, 0x00000000, LLRF_GOP},
        { 2, 0xFFFFE000, 0x00000000, LLRF_GIP},
        { 2, 0xFFFF0000, 0x00000000, LLRF_GIP_S},
        { 2, 0xFFFF0000, 0x00000000, LLRF_GIP_C},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_PI_1_K},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_PI_1_TS_DIV_TI},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_PI_1_SAT_MAX},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_PI_1_SAT_MIN},
        { 0, 0x000003FF, 0x00000000, LLRF_PI_1_CTRL},
        { 0, 0x0000FFFF, 0x00000000, LLRF_PI_1_FIXED_SP},
        { 0, 0x0000FFFF, 0x00000000, LLRF_PI_1_FIXED_FF},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_PI_2_K},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_PI_2_TS_DIV_TI},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_PI_2_SAT_MAX},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_PI_2_SAT_MIN},
        { 0, 0x0000003F, 0x00000000, LLRF_PI_2_CTRL},
        { 0, 0x0000FFFF, 0x00000000, LLRF_PI_2_FIXED_SP},
        { 0, 0x0000FFFF, 0x00000000, LLRF_PI_2_FIXED_FF},
        { 0, 0x00001FFF, 0x00000000, LLRF_IQ_CTRL},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_IQ_ANGLE},
        { 2, 0x00000000, 0x00000000, LLRF_IQ_DC_OFFSET},
        { 0, 0x0000003F, 0x00000000, LLRF_VM_CTRL},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_VM_MAG_LIMIT},
        { 3, 0xFFFFFFFF, 0x00000000, LLRF_SAMPLE_CNT},
        { 3, 0xFFFFFFFF, 0x00000000, LLRF_PULSE_START_CNT},
        { 3, 0xFFFFFFFF, 0x00000000, LLRF_PULSE_ACTIVE_CNT},
        { 0, 0x000FFFFF, 0x00020000, LLRF_LUT_CTRL_1_PARAM},
        { 0, 0x0007FFFF, 0x00001000, LLRF_LUT_CTRL_2_PARAM},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_MEM_CTRL_1_PARAM},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_MEM_CTRL_2_PARAM},
        { 0, 0xFFFFFFFF, 0x02004000, LLRF_MEM_CTRL_3_PARAM},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_MEM_CTRL_4_PARAM},
        { 1, 0x0000FFFF, 0x00001000, LLRF_PI_ERR_MEM_SIZE},
        { 3, 0x0000FFFF, 0x00000000, LLRF_PI_ERR_CNT},
        { 0, 0x0000FFFF, 0x00000000, LLRF_BOARD_SETUP},
        { 0, 0x00FF00FF, 0x00000000, LLRF_NEAR_IQ_1_PARAM},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_NEAR_IQ_2_PARAM},
        { 2, 0xFFFFFFFF, 0x00000000, LLRF_NEAR_IQ_DATA},
        { 0, 0x000001FF, 0x00000000, LLRF_NEAR_IQ_ADDR},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_FILTER_S},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_FILTER_C},
        { 0, 0xFFFF000F, 0x00000030, LLRF_FILTER_A_CTRL},
        { 3, 0xFFFFFFFF, 0x00000000, LLRF_CAV_MA},
        { 3, 0xFFFFFFFF, 0x00000000, LLRF_REF_MA},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_MON_PARAM_1},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_MON_PARAM_2},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_MON_LIMIT_1},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_MON_LIMIT_2},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_MON_LIMIT_3},
        { 0, 0xFFFFFFFF, 0x00000000, LLRF_MON_LIMIT_4},
        { 2, 0xFFFFFFFF, 0x00000000, LLRF_MON_STATUS},
};

#endif /* SIS8300_LLRF_REG_H_ */