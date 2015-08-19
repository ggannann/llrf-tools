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
    int status,nbr_of_irqs,i;
    sis8300drv_usr *sisuser;

    if (argc == 3) {
        sisuser = malloc(sizeof(sis8300drv_usr));
        sisuser->file = argv[1];
        nbr_of_irqs = (int)strtoul(argv[2], NULL, 16);
    }else{
        printf("Usage: %s [device_node], [nbr of IRQs to wait for]\n", argv[0]);
        return -1;
    }

    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }

    for(i=0; i<nbr_of_irqs; i++){
        status = sis8300drv_wait_irq(sisuser,irq_type_usr,0);
        if (status == 0){
            printf("Pulse done received. IRQ count: %d\n",i+1);
        }else if (status == 4){
            printf("IRQ TIMEOUT!. IRQ count: %d\n",i+1);
            return -1;
        }else{
            printf("Wait for IRQ ERROR: %d\n", status);
            return -1;
        }
    }
    printf("All IRQs received. IRQ count: %d\n",i);

    return(0);
}
