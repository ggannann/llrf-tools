#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>
#include <math.h>

#include <time.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"

#include "sis8300_llrf_reg.h"
#include "sis8300_llrf_utils.h"

#define MEM_SIZE_BYTES 2147483648
//#define MEM_SIZE_BYTES 1048576

// call to start timer
struct timespec timer_start(){
    struct timespec start_time;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &start_time);
    return start_time;
}

// call when you want time diff in nano sec
long timer_end(struct timespec start_time){
    struct timespec end_time;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &end_time);
    long diffInNanos = end_time.tv_nsec - start_time.tv_nsec;
    return diffInNanos;
}

int main(int argc, char **argv) {
    int status;
    sis8300drv_usr *sisuser;
    int i,nbr_of_mem_blocks,value,itr,j,fun;
    //    unsigned blocksize = 8; // rd/wr mem must be in 256 bit blocks, i.e. 8  4-byte words
    unsigned offset;
    unsigned size_bytes,size_words;
    //    unsigned size_blocks;
    unsigned *data;
    unsigned *readback;
    unsigned *offsets;

    unsigned long long time_result;

    //    clock_t x;
    clock_t y;

    j=0;
    /* Check nbr of arguments */
    if (argc != 2) {
        printf("Usage: %s [device_node, e.g. /dev/sis8300-4]\n", argv[0]);
        return -1;
    }

    // INPUTS
    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file     = argv[1];
    nbr_of_mem_blocks = 1024;
    size_bytes        = MEM_SIZE_BYTES/nbr_of_mem_blocks;
    size_words        = size_bytes/4;
    //   size_blocks       = size_bytes/blocksize;

    // Create data
    printf("Data block size used: %d Bytes\n", size_bytes);
    if (size_bytes % 32 != 0){
        return -1;
    }
    data      = malloc(size_bytes);
    readback  = malloc(size_bytes);

    // Open device
    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }
    printf("Memory test: start...\n");

    /*
    // Write DDR
    offset = 0;
    value  = 0x00000000;

    for(itr = 0; itr < nbr_of_mem_blocks; itr++){
        // create data values
        for(i = 0; i < size_words; i++){
            data[i] = value;
            value++;
        }
        // write'em to memory
        printf("Write CMD: offset = 0x%08X, data_size = %d bytes\n", offset, size_bytes);
        x = clock();
        status = sis8300drv_write_ram(sisuser, offset, size_bytes, data);
        y = y + clock() - x;
        if(status < 0){
            printf("write error: %i\n", status);
            exit(-1);
        }
        offset+=size_bytes;
    }
    time_result = (unsigned long long)(y*1000 / CLOCKS_PER_SEC);
    printf("Memory test: All values written... \n");
    printf("Write done in %llu s and %llu ms", time_result/1000, time_result%1000);
    */

    offsets     = malloc(size_bytes);
    // Read back

    offset = 0;
    value  = 0x00000000;
    for(fun = 0; fun < 10; fun++){
    	y = 0;
	//    	x = 0;
		for(itr = 0; itr < nbr_of_mem_blocks; itr++){
			// create data values
			for(i = 0; i < size_words; i++){
				data[i] = value;
				value++;
			}
				// read back data from memory
				printf("Read CMD: offset = 0x%08X, data_size = %d bytes\n", offset, size_bytes);

				//x = clock();

				struct timespec vartime = timer_start();  // begin a timer called 'vartime'

				status = sis8300drv_read_ram(sisuser, offset, size_bytes, readback);

				long time_elapsed_nanos = timer_end(vartime);

				printf("2 MB read in (nanoseconds): %ld\n", time_elapsed_nanos);
				//y = y + clock() - x;
				if(status < 0){
					printf("readback error: %i\n", status);
					exit(-1);
				}
				// compare
				for(i = 0; i < size_words; i++){
					if(readback[i]!=data[i]){
						offsets[fun] = offset;
						printf("Memory Error in: offset = 0x%08X, i = %d, i = 0x%08X\n", offset,i,i);
						printf("i= %d,RB = %d, data = %d,  RB = 0x%08X, data = 0x%08X\n",j,readback[i],data[i],readback[i],data[i]);
						goto breakpoint;
					}else{
						offsets[fun] = 0xFFFFFFFF;
					}
				}
			//}
			offset+=size_bytes;

		}
		time_result = (unsigned long long)(y*1000 / CLOCKS_PER_SEC);
		printf("Write done in %Lf s and %llu ms", (long double) y, time_result);

		breakpoint:
		value  = 0x00000000;
		offset = 0;

    }

    sis8300drv_close_device(sisuser);

    printf("Memory test PASS!\n");
    return(0);
}



