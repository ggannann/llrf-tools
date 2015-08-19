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
    unsigned reg_data;
    unsigned reg_value_rb;
    unsigned reg_addr;
    sis8300drv_usr *sisuser;

    /* Check nbr of arguments */    
    if (argc == 4) {
          reg_addr = (unsigned)strtoul(argv[2], NULL, 16);
          reg_data = (unsigned)strtoul(argv[3], NULL, 16);
    }else{
        printf("Usage: %s [device_node, e.g. /dev/sis8300-4] [reg_addr] [reg_data]\n", argv[0]);
        printf("First possible reg address: 0x%03X\n",LLRF_FIRST_REG);
        printf("Last possible reg address: 0x%03X\n",LLRF_LAST_REG);
        return -1;
    }

    /* Check argument values */    
    if( (reg_addr < LLRF_FIRST_REG) || (reg_addr > LLRF_LAST_REG) ){
        printf("Usage: %s [device_node, e.g. /dev/sis8300-4] [reg_addr] [reg_data]\n", argv[0]);
        printf("First possible reg address: 0x%03X\n",LLRF_FIRST_REG);
        printf("Last possible reg address: 0x%03X\n",LLRF_LAST_REG);
        return -1;        
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
 *   Write registers
 ****************************************************************/
    write_reg_cl(sisuser,reg_addr,reg_data);
    read_reg_cl(sisuser,reg_addr,&reg_value_rb);
    printf("\nWriting 0x%08X to register 0x%03X\n",reg_data,reg_addr);
    printf("************************************************\n");
    printf("Reading register 0x%03X\n",reg_addr);
    printf("************************************************\n");
    print_reg_cl(reg_addr,reg_value_rb);

/****************************************************************
 *   Write registers End
 ****************************************************************/

    /* Close device */    
    sis8300drv_close_device(sisuser);

    return(0);
}
