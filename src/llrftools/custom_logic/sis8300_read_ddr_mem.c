#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"
#include "sis8300_llrf_utils.h"

#include "sis8300_llrf_reg.h"

#define LED_ON  0x00000001
#define LED_OFF 0x00010000

int main(int argc, char **argv) {
    int status;
    sis8300drv_usr *sisuser;
    int i;
    unsigned blocksize = 8; // rd/wr mem must be in 256 bit blocks, i.e. 8 IQ-points
    unsigned offset;
    unsigned size;
    unsigned *readback;
    unsigned data_size;
    unsigned matlab = 0;
    int conv_2c = 0;


    if (argc < 4 || argc > 6) {
        printf("Usage: %s [device_node], [memory offset], [size (in number of blocks of 8-IQ points(8*2*16=256 bits))], [optional: matlab format pair or seq (0|1|2)], [ optional conv_2c (0|1)]", argv[0]);
        return -1;
    }

    // INPUTS
    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];
    offset      = (unsigned)strtoul(argv[2], NULL, 16);
    size        = blocksize * (unsigned)strtoul(argv[3], NULL, 16);
    if (argc == 6 ) {
        matlab = (unsigned)strtoul(argv[4], NULL, 16);
        conv_2c = (int)strtoul(argv[5], NULL, 16);
    } else if (argc == 5 ) {
        matlab = (unsigned)strtoul(argv[4], NULL, 16);
    }

    // Mem allocation
    data_size = sizeof(unsigned) * size;
    if (matlab == 0){
        printf("Data size: %d Bytes\n", data_size);
    }
    if (data_size % 32 != 0){
        return -1;
    }
    readback  = malloc(data_size);

    // Check offset
    if (offset % 32 != 0){
        printf("Address NOT 32 byte aligned!\n");
        return -1;
    }

    // Open device
    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }

    // Read back
    if (matlab == 0){
        printf("Read CMD: offset = 0x%08X, data_size = %d bytes\n", offset, data_size);
    }
    status = sis8300drv_read_ram(sisuser, offset, data_size, readback);
    if(status < 0){
       printf("readback error: %i\n", status);
       exit(-1);
    }

    if (matlab == 1){ // i,q format
        if(conv_2c){
            // convert from binary offset to two's complement
            // when reading input data
            for(i = 0; i < size; i++){
                readback[i] = readback[i] ^ 0x80008000;
            }
        }
        for(i = 0; i < size; i++){
            printf("%d, %d\n", ((signed)(readback[i]&0xFFFF0000))>>16,((signed)readback[i]<<16)>>16);
        }
    }else if (matlab == 2){ // sequential format
        for(i = 0; i < size; i++){
            printf("%d\n", ((signed)readback[i]<<16)>>16);
            printf("%d\n", ((signed)(readback[i]&0xFFFF0000))>>16);
        }
    }else{
        printf("readback:\n");
        for(i = 0; i < size; i++){
            printf("Data 0x%04X: 0x%08X\n", i,readback[i]);
        }
    }

    sis8300drv_close_device(sisuser);

    return(0);
}




