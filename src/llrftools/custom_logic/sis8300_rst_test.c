#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300_reg.h"
#include "sis8300drv.h"

#include "sis8300_llrf_reg.h"
#include "sis8300_llrf_utils.h"

int main(int argc, char **argv) {
    int status,i;
    unsigned reg_value_rb;
    sis8300drv_usr *sisuser;

    /* Check nbr of arguments */    
    if (argc != 2) {
        printf("Usage: %s [device_node, e.g. /dev/sis8300-4]\n", argv[0]);
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
 *   SW reset test
 ****************************************************************/
    //sw reset
    write_reg_cl(sisuser,LLRF_GIP_S,0x400);

	printf("************************************************\n");
	printf("SW reset and default value test from 0x%03X to 0x%03X\n",LLRF_MEM_CTRL_3_PARAM,LLRF_MEM_CTRL_3_PARAM);
	printf("************************************************\n");
	for ( i=0; i<100000; i++){
	    // check FSM state
        status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_value_rb);
        if ((reg_value_rb&0x7) != 0){
            print_state(reg_value_rb);
            printf("Wrong state! Expected state: INIT\n");
            return -1;
        }
        // check MEM_CTRL_3
	    read_reg_cl(sisuser, 0x420,&reg_value_rb);
	    if( reg_value_rb !=  0x2004000){
            printf("ERROR!\n");
	        printf("READ    :");
	        print_reg_cl(0x420,reg_value_rb);
	        return -1;
	    }
	    // go to IDLE
	    status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x1);
	    usleep(200);
	    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_value_rb);
	    if ((reg_value_rb&0x7) != 1){
	        print_state(reg_value_rb);
	        printf("Wrong state! Expected state: IDLE\n");
	        return -1;
	    }
        write_reg_cl(sisuser,LLRF_MEM_CTRL_3_PARAM,0x12345678);
        read_reg_cl(sisuser, 0x420,&reg_value_rb);
        //sw reset
        write_reg_cl(sisuser,LLRF_GIP_S,0x400);
    }
	printf("PASS!\n");
	printf("************************************************\n\n");
    

    /* Close device */    
    sis8300drv_close_device(sisuser);

    return(0);
}
