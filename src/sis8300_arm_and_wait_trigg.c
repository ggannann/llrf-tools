#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"

#include "sis8300_llrf_utils.h"
#include "sis8300_llrf_reg.h"


int main(int argc, char **argv) {
    int status;
    sis8300drv_usr *sisuser;

    if (argc < 2 || argc > 2) {
        printf("Usage: %s [device_node]\n", argv[0]);
        return -1;
    }

    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];
    status = sis8300drv_open_device(sisuser);
    
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }

    status = sis8300drv_reg_write(sisuser, 0x10, 0x2);
    if (status) {
		printf("Arm device failed %i\n", status);
    } 
    else {
		printf("Armed, waiting...\n");
    }

    status = sis8300drv_wait_irq(sisuser, irq_type_usr, 0);
    printf("Wait IRQ return %i\n", status);

    return 0;
}
