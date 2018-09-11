#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300_reg.h"



#include "sis8300drv.h"

#include "sis8300_llrf_reg.h"
#include "sis8300_llrf_utils.h"

#define LED_ON  0x00000001
#define LED_OFF 0x00010000

int main(int argc, char **argv) {
    int status;
    unsigned reg_start;
    unsigned reg_end;
    unsigned reg_value_rb;
    unsigned reg_addr;
    sis8300drv_usr *sisuser;

    /* Check nbr of arguments */    
    if (argc == 2) {
          reg_start = LLRF_FIRST_REG;
          reg_end = LLRF_LAST_REG;
    }else if (argc == 3) {
          reg_start = (unsigned)strtoul(argv[2], NULL, 16);
          reg_end = (unsigned)strtoul(argv[2], NULL, 16);
    }else if (argc == 4) {
          reg_start = (unsigned)strtoul(argv[2], NULL, 16);
          reg_end = (unsigned)strtoul(argv[3], NULL, 16);
    }else{
        printf("Usage: %s [device_node, e.g. /dev/sis8300-4] [optional: start_addr] [optional: end_addr]\n", argv[0]);
        printf("With no address inputs, all registers are read\n");
        printf("First possible reg address: 0x%03X\n",LLRF_FIRST_REG);
        printf("Last possible reg address: 0x%03X\n",LLRF_LAST_REG);
        return -1;
    }

    /* Check argument values */    
    if( reg_start != STRUCK_ADC_SAMPLE_CTRL ) {
        if( (reg_start < LLRF_FIRST_REG) || (reg_start > LLRF_LAST_REG) ||
            (reg_end < LLRF_FIRST_REG) || (reg_end > LLRF_LAST_REG) || (reg_end < reg_start) ){
            printf("Usage: %s [device_node] [optional: start_addr] [optional: end_addr]\n", argv[0]);
            printf("With no address inputs, all registers are read\n");
            printf("First address: 0x%03X\n",LLRF_FIRST_REG);
            printf("Last address: 0x%03X\n",LLRF_LAST_REG);
            return -1;
        }
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
 *   Read registers
 ****************************************************************/
    printf("************************************************\n");
    printf("Reading all user registers from 0x%03X to 0x%03X\n",reg_start,reg_end);
    printf("************************************************\n");
    for ( reg_addr=reg_start; reg_addr<=reg_end; reg_addr++){
	read_reg_cl(sisuser, reg_addr,&reg_value_rb);
        print_reg_cl(reg_addr,reg_value_rb);
    }

/****************************************************************
 *  Read registers End
 ****************************************************************/

    /* Close device */    
    sis8300drv_close_device(sisuser);

    return(0);
}


