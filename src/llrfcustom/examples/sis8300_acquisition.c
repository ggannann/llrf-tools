#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"


int main(int argc, char **argv) {
    int status, iter;
    unsigned channel, average, min, max;
    uint16_t *data[SIS8300DRV_NUM_AI_CHANNELS];
    sis8300drv_usr *sisuser;
    sis8300drv_clk_src clksrc;
    sis8300drv_clk_div clkdiv;
    sis8300drv_trg_src trgsrc;

    unsigned nsamples, npretrig, channel_mask;

    nsamples = 0x100;
    npretrig = 0;
//    channel_mask = 0x2;
    channel_mask = 0xFFF;
    clksrc = clk_src_internal;
    clkdiv = clk_div_2;
    trgsrc = trg_src_soft;

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

    /*unsigned ui32_reg_val = 0;
    sis8300drv_reg_write(sisuser, SIS8300_SAMPLE_START_ADDRESS_CH1_REG, 0x0);
    usleep(100);
    sis8300drv_reg_read(sisuser, SIS8300_SAMPLE_START_ADDRESS_CH1_REG, &ui32_reg_val);
    printf("ui32_reg_val=%X\n", ui32_reg_val);*/

    sis8300drv_arm_device(sisuser);

    sis8300drv_wait_acq_end(sisuser);

    /*printf("\n");
    int raw_length = nsamples*SIS8300DRV_NUM_CHANNELS;
    uint16_t *raw = (uint16_t *)calloc(raw_length, sizeof(uint16_t));
    lseek(sisuser->handle, 0, SEEK_SET);
    read(sisuser->handle, raw, raw_length*sizeof(uint16_t));
    for (iter = 0; iter < raw_length; iter++) {
        if (!(iter % nsamples)) {
            printf("\n=== channel %d ===", iter/nsamples);
        }
        if (!(iter % 16)) {
            printf("\n%d  ", iter/16);
        }
        printf("%u ", raw[iter]);
    }*/

    for (channel = 0; channel < SIS8300DRV_NUM_AI_CHANNELS; channel++) {
        data[channel] = (uint16_t *)calloc(nsamples, sizeof(uint16_t));
        if (!(channel_mask & (1 << channel))) {
	    printf("Channel %u skipped\n", channel);
            continue;
        }
        status = sis8300drv_read_ai(sisuser, channel, data[channel]);
        if (status) {
            printf("sis8300drv_read_ai for channel %u error: %d\n", channel, status);
            return -1;
        }
        average = 0;
        min = UINT16_MAX;
        max = 0;
        for (iter = 0; iter < nsamples; iter++) {
            average += data[channel][iter];
            if (data[channel][iter] < min) {
                min = data[channel][iter];
            }
            if (data[channel][iter] > max) {
                max = data[channel][iter];
            }
            if (iter < 256) {
                if (!(iter % 16)) {
                    printf("\n");
                }
                printf("%u ", data[channel][iter]);
            }
        }
        average /= nsamples;
        printf("\nChannel %u: average=%u min=%u max=%u\n", channel, average, min, max);
    }

    sis8300drv_close_device(sisuser);

    return(0);
}
