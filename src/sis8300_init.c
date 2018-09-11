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
    sis8300drv_clk_src clksrc;
    sis8300drv_clk_div clkdiv;
    sis8300drv_trg_src trgsrc;

    unsigned nsamples, npretrig, channel_mask;

    npretrig = 0;
    clksrc = clk_src_sma;
    clkdiv = SIS8300DRV_CLKDIV_MIN;
    trgsrc = trg_src_external;

    if (argc < 4 || argc > 4) {
        printf("Usage: %s [device_node] [nbr_samples] [ch_mask]\n", argv[0]);
        return -1;
    }
    nsamples  = (unsigned)strtoul(argv[2], NULL, 16);
    channel_mask  = (unsigned)strtoul(argv[3], NULL, 16);

    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];

    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }

    status = sis8300drv_disarm_device(sisuser);
    if (status) {
        printf("sis8300drv_disarm_device: %d\n", status);
        return -1;
    }

    printf("nbr of input samples to store in DDR per channel: %d\n", nsamples);
    status = sis8300drv_set_nsamples(sisuser, nsamples);
    if (status) {
        printf("sis8300drv_set_nsamples: %d\n", status);
        return -1;
    }

    status = sis8300drv_set_npretrig(sisuser, npretrig);
    if (status) {
        printf("sis8300drv_set_npretrig error: %d\n", status);
        return -1;
    }

    status = sis8300drv_set_channel_mask(sisuser, channel_mask);
    if (status) {
        printf("sis8300drv_set_channel_mask error: %d\n", status);
        return -1;
    }

    status = sis8300drv_set_clock_source(sisuser, clksrc);
    if (status) {
        printf("sis8300drv_set_clock_source error: %d\n", status);
        return -1;
    }

    status = sis8300drv_set_clock_divider(sisuser, clkdiv);
    if (status) {
        printf("sis8300drv_set_clock_divider error: %d\n", status);
        return -1;
    }

    status = sis8300drv_set_trigger_source(sisuser, trgsrc);
    if (status) {
        printf("sis8300drv_set_trigger_source error: %d\n", status);
        return -1;
    }


    sis8300drv_arm_device(sisuser);


    return(0);
}
