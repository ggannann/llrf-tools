#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"


int main(int argc, char **argv) {
	int status, ch;
	uint32_t reg_val;
	sis8300drv_usr *sisuser;

    if (argc < 2) {
        printf("Usage: %s [device_node] \n", argv[0]);
        return -1;
    }

    sisuser = malloc(sizeof(sis8300drv_usr));
	sisuser->file = argv[1];

	status = sis8300drv_open_device(sisuser);
	if (status) {
		printf("sis8300drv_open_device error: %d\n", status);
		return -1;
	}

	do {
	    if (!sisuser->device) {
	        status = sis8300drv_open_device(sisuser);
	        if (status) {
	            printf("sis8300drv_open_device error: %d\n", status);
	        }
	    } else {
            status = sis8300drv_reg_read(sisuser,
                    SIS8300_IDENTIFIER_VERSION_REG, &reg_val);
            printf("reg_val=%x\n", reg_val);
            if (status < 0) {
                printf("sis8300drv_reg_read error: %d, closing device.\n", status);
                sis8300drv_close_device(sisuser);
            }
	    }
		fflush(stdin);
		ch = getchar();
	} while (ch == 10);

	sis8300drv_close_device(sisuser);

	return(0);
}
