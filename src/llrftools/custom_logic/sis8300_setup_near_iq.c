
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>
#define __USE_BSD
#include <math.h>

#include "sis8300_reg.h"
#include "sis8300drv.h"

#include "sis8300_llrf_reg.h"
#include "sis8300_llrf_utils.h"

#define LED_ON  0x00000001
#define LED_OFF 0x00010000

int main(int argc, char **argv) {
    int status;
    unsigned M;
    unsigned N;
    sis8300drv_usr *sisuser;
    int i,fix_p_fact, read_mem, write_mem;
    unsigned rb_data;
    double const_fact;
    double fact;

    /* Check nbr of arguments */
    if (argc == 5) {
        M = (unsigned)strtoul(argv[2], NULL, 10);
        N = (unsigned)strtoul(argv[3], NULL, 10);
        write_mem = (unsigned)strtoul(argv[4], NULL, 10);
        read_mem = 0;
    }else if (argc == 6) {
        M = (unsigned)strtoul(argv[2], NULL, 10);
        N = (unsigned)strtoul(argv[3], NULL, 10);
        write_mem = (unsigned)strtoul(argv[4], NULL, 10);
        read_mem = (unsigned)strtoul(argv[5], NULL, 10);
    }else{
        printf("Usage: %s [device_node, e.g. /dev/sis8300-4], M, N, write_mem(0|1), read_mem(0|1) \n", argv[0]);
        return -1;
    }

    /* Check argument values */
    if( (M > 255) || (N>255) ) {
        printf("Max M and N is 255!\n");
    }

    /* Open device */
    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];
    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }

/****************************************************************
 *   Write Near IQ
 ****************************************************************/
    if(write_mem == 1){
        /* Write M and N */
        fix_p_fact = (N<<16) + M;
        write_reg_cl(sisuser,LLRF_NEAR_IQ_1_PARAM,fix_p_fact);
        /* Write 2/N */
        fact = (double)2/N;
        fix_p_fact = (int)(fact*(2<<29));
        write_reg_cl(sisuser,LLRF_NEAR_IQ_2_PARAM,fix_p_fact);
        /* Read back */
        read_reg_cl(sisuser,LLRF_NEAR_IQ_1_PARAM,&rb_data);
        print_reg_cl(LLRF_NEAR_IQ_1_PARAM,rb_data);
        read_reg_cl(sisuser,LLRF_NEAR_IQ_2_PARAM,&rb_data);
        print_reg_cl(LLRF_NEAR_IQ_2_PARAM,rb_data);
        /* Set addr to 0 */
        write_reg_cl(sisuser,LLRF_NEAR_IQ_ADDR,0);
        printf("#################################\n");
        printf("# Writing to Near-IQ const memory\n");
        printf("#################################\n");

        /* Calc Sin/cos values and write them */
        const_fact = 2*M_PI*M/N;
        for(i=0;i<N;i++){
            fact = sin(i*const_fact);
            fix_p_fact = (int)(fact*(2<<29));
            printf("sin for i=%d:  %f, %8X\n",i,fact,fix_p_fact);
            write_reg_cl(sisuser,LLRF_NEAR_IQ_DATA,fix_p_fact);
            fact = cos(i*const_fact);
            fix_p_fact = (int)(fact*(2<<29));
            printf("cos for i=%d:  %f, %8X\n",i,fact,fix_p_fact);
            write_reg_cl(sisuser,LLRF_NEAR_IQ_DATA,fix_p_fact);
        }
        printf("#################################\n");
    }

/****************************************************************
 *  Read Near IQ
 ****************************************************************/
    if(read_mem == 1){
        /* Read back */
        read_reg_cl(sisuser,LLRF_NEAR_IQ_1_PARAM,&rb_data);
        print_reg_cl(LLRF_NEAR_IQ_1_PARAM,rb_data);
        read_reg_cl(sisuser,LLRF_NEAR_IQ_2_PARAM,&rb_data);
        print_reg_cl(LLRF_NEAR_IQ_2_PARAM,rb_data);
        /* Set addr to 0 */
        write_reg_cl(sisuser,LLRF_NEAR_IQ_ADDR,0);
        printf("#################################\n");
        printf("# Reading from Near-IQ const memory\n");
        printf("#################################\n");

        for(i=0;i<N;i++){
            read_reg_cl(sisuser,LLRF_NEAR_IQ_DATA,&rb_data);
            fact = ((double)((signed)rb_data))/(2<<29);
            printf("sin for i=%d:  %f, %8X\n",i,fact,rb_data);
            write_reg_cl(sisuser,LLRF_NEAR_IQ_ADDR,2*i+1);
            read_reg_cl(sisuser,LLRF_NEAR_IQ_DATA,&rb_data);
            fact = ((double)((signed)rb_data))/(2<<29);
            printf("cos for i=%d:  %f, %8X\n",i,fact,rb_data);
            write_reg_cl(sisuser,LLRF_NEAR_IQ_ADDR,2*i+2);
        }
        printf("#################################\n");
    }

    /* Close device */
    sis8300drv_close_device(sisuser);

    return(0);
}


