#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#include "sis8300drv.h"
#include "sis8300_defs.h"

int main(int argc, char **argv) {
	int             status, iter;
	//uint32_t        reg_val;
	//int ch;
	uint16_t        *data;
	uint16_t        *map;
	sis8300drv_usr  *sisuser;

	int size = 0x1000;

    if (argc < 2) {
        printf("Usage: %s [device_node] \n", argv[0]);
        return -1;
    }

    sisuser = malloc(sizeof(sis8300drv_usr));
	sisuser->file = argv[1];

	assert(sis8300drv_open_device(sisuser) == status_success);

    data = (uint16_t *)malloc(size);
    for(iter = 0; iter < size/2; iter++) {
        data[iter] = (uint16_t)iter;
    }
    assert(sis8300drv_write_ram(sisuser, 0, size, (uint8_t *)data) == status_success);
    free(data);

    map = (uint16_t *)mmap(NULL, size, PROT_READ, MAP_SHARED, sisuser->handle, 0);
    if (map == MAP_FAILED) {
        printf("mmap failed\n");
        sis8300drv_close_device(sisuser);
    }

    sis8300_range range;
    range.offset = 0;
    range.size = size;
    status = ioctl(sisuser->handle, SIS8300_WAIT_MMAP_UPDATE, &range);

    for(iter = 0; iter < size/2; iter++) {
        if (!(iter % 16)) {
            printf("\n%4d  ", iter/16);
        }
        printf("%6u ", map[iter]);
    }
    printf("\n");

    munmap((void *)map, size);

	sis8300drv_close_device(sisuser);

	return(0);
}
