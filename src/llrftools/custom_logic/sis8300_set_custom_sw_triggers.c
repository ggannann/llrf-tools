#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"

#include "sis8300_llrf_reg.h"
#include "sis8300_llrf_utils.h"

#define LED_ON  0x00000001
#define LED_OFF 0x00010000


#define LLRF_GIP_S			0x404

static sis8300drv_usr *sisuser;

int main(int argc, char **argv) {
    int status;
    unsigned reg_data;
    unsigned trigger;

    /* Check nbr of arguments */
    if ( argc == 3 ) {
        trigger = (unsigned)strtoul(argv[2], NULL, 16) -1;
    }else{
        printf("Usage: %s [device_node, e.g. /dev/sis8300-4] [trigger nbr]\n", argv[0]);
        printf("Set one of 11 possible SW triggers.\n");
        printf("Possible triggers:\n\tirq_clear (D)\n\tforce_lut (C)\n\tSW_reset (B)\n\tforce_get_param (A)\n\tforce_pms (9)\n\tforce_pulse_end (8)\n\tforce_pulse_start (7)\n\tforce_pulse_comming (6)\n\tupdate_sp (5)\n\tupdate_ff (4)\n\tnew_pulse_type (3)\n\tupdate_parameters (2)\n\tinit_done (1)\n");
        printf("Examples: 0 no triggers, 1 init done, 9 force_pms\n");
        return -1;
    }

    /* Check argument values */    
    if( (trigger < 0) || (trigger > 13) ){
        printf("NON SUPPORTED TRIGGER NUMBER!\n");
        printf("Usage: %s [device_node, e.g. /dev/sis8300-4] [trigger nbr]\n", argv[0]);
        printf("Set one of 10 possible SW triggers.\n");
        printf("Possible triggers:\n\tirq_clear (D)\n\tforce_lut (C)\n\tSW_reset (B)\n\tforce_get_param (A)\n\tforce_pms (9)\n\tforce_pulse_end (8)\n\tforce_pulse_start (7)\n\tforce_pulse_comming (6)\n\tupdate_sp (5)\n\tupdate_ff (4)\n\tnew_pulse_type (3)\n\tupdate_parameters (2)\n\tinit_done (1)\n");
        printf("Examples: 0 no triggers, 1 init done, 9 force_pms\n");
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
 *   Set register
 ****************************************************************/
    reg_data = 0;
    reg_data |= (0x1)<<trigger;

    write_reg_cl(sisuser,LLRF_GIP_S,reg_data);
    printf("\nWrote trigger data 0x%02X to register: 0x%03X\n",reg_data,LLRF_GIP_S);
    printf("************************************************\n");
    printf("Triggers:\n\tirq_clear: 0x%01X\n\tforce_lut: 0x%01X\n\tSW_reset: 0x%01X\n\tforce_get_param: 0x%01X\n\tforce_pms: 0x%01X\n\tforce_pulse_end: 0x%01X\n\tforce_pulse_start: 0x%01X\n\tforce_pulse_comming: 0x%01X\n\tupdate_sp: 0x%01X\n\tupdate_ff: 0x%01X\n\tnew_pulse_type: 0x%01X\n\tupdate_parameters: 0x%01X\n\tinit_done: 0x%01X\n",(reg_data&0x1000)>>12,(reg_data&0x800)>>11,(reg_data&0x400)>>10,(reg_data&0x200)>>9,(reg_data&0x100)>>8,(reg_data&0x80)>>7,(reg_data&0x40)>>6,(reg_data&0x20)>>5,(reg_data&0x10)>>4,(reg_data&0x8)>>3,(reg_data&0x4)>>2,(reg_data&0x2)>>1,(reg_data&0x1));
    printf("************************************************\n");

/****************************************************************
 *   Set register End
 ****************************************************************/

    /* Close device */    
    sis8300drv_close_device(sisuser);

    return(0);
}
