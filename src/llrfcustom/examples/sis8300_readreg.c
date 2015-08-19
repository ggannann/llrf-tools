#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"


int main(int argc, char **argv) {
    int status;
    sis8300drv_usr *sisuser;
    unsigned reg_val;
    //unsigned readback;
    unsigned reg_addr;
    //unsigned reg_addr = SIS8300_USER_CONTROL_STATUS_REG;
    if (argc < 3) {
        printf("Usage: %s [device_node] [reg_addr]\n", argv[0]);
        return -1;
    }

    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];
    reg_addr = (unsigned)strtoul(argv[2], NULL, 16);

    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }

    status = sis8300drv_reg_read(sisuser, reg_addr, &reg_val);
    if(status < 0){
	printf("error: %i\n", status);
	exit(-1);
    }
    printf("reg val: 0x%08x, for reg: 0x%03x\n", reg_val, reg_addr);

    sis8300drv_close_device(sisuser);

    return(0);
}
