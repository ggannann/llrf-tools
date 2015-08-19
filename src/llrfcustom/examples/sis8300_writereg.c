#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"

#define LED_ON  0x00000001
#define LED_OFF 0x00010000

int main(int argc, char **argv) {
    int status;
    sis8300drv_usr *sisuser;
    unsigned reg_val;
    unsigned reg_addr;
    
    if (argc < 4) {
        printf("Usage: %s [device_node] [reg_addr] [value]\n", argv[0]);
        return -1;
    }

    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];
    reg_val = (unsigned)strtoul(argv[3], NULL, 16);
    reg_addr = (unsigned)strtoul(argv[2], NULL, 16);

    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }

    status = sis8300drv_reg_write(sisuser, reg_addr, reg_val);
    if(status < 0){
	printf("write error: %i\n", status);
	exit(-1);
    }
    printf("wrote: 0x%08x to: 0x%03x\n", reg_val, reg_addr);

    status = sis8300drv_reg_read(sisuser, reg_addr, &reg_val);
    if(status < 0){
	printf("read error: %i\n", status);
	exit(-1);
    }
    printf("readback val: 0x%08x, from address: 0x%08x\n", reg_val, reg_addr);

    sis8300drv_close_device(sisuser);

    return(0);
}
