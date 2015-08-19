#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"

#define MIN_BYTES 32


/*
 * writeram and readback example. it assumes the data samples are of 1 byte.
 * IMPORTAINT: read and write should be done in 32 byte chunks or they do
 * not work as they should */
int main(int argc, char **argv) {
    int status, iter;
    unsigned nsamples = 256 * 2;
    unsigned offset = 4;
    uint8_t wdata[nsamples];
    uint8_t rdata[nsamples];
    
    memset(rdata, 0, nsamples*sizeof(uint8_t));    
    // this will set to 10 byte by byte
    memset(wdata, 10, nsamples*sizeof(uint8_t));
    
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
    
    sis8300drv_write_ram(sisuser, offset, nsamples*sizeof(uint8_t), wdata);
    sis8300drv_read_ram(sisuser, offset, nsamples*sizeof(uint8_t), rdata);
    
    for (iter = 0; iter < nsamples; iter++) {
        if (iter < 256) {
            if (!(iter % 16)) {
                printf("\n");
            }
            printf("%u ", rdata[iter]);
        }
    }
    printf("\n");
    
    return(0);
}
