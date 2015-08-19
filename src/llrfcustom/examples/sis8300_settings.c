#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>

#include "sis8300drv.h"
#include "sis8300_reg.h"


struct sis8300drv_settigns {
    unsigned            nsamples;
    unsigned            npretrig;
    unsigned            channel_mask;
    sis8300drv_clk_src  clksrc;
    sis8300drv_clk_div  clkdiv;
};

static struct sis8300drv_settigns settings_tests[] = {
    {0x1000,    0,      0x155,  clk_src_internal,       clk_div_1},
    {0x1000000, 100,    0x155,  clk_src_rtm2,           clk_div_2},
    {0x1000,    1000,   0x3c3,  clk_src_sma,            clk_div_4},
    {0x1000000, 2000,   0x3c3,  clk_src_harlink,        clk_div_6},
    {0x2000000, 0,      0x3c7,  clk_src_backplane_a,    clk_div_8},
    {0x2000000, 2046,   0x3fc,  clk_src_backplane_b,    clk_div_10},
    {0x1000000, 2046,   0x3ff,  clk_src_internal,       clk_div_12}
};


int main(int argc, char **argv) {
    int iter, ntests;
    unsigned  unsigned_rbv;
    sis8300drv_clk_src clksrc_rbv;
    sis8300drv_usr *sisuser;

    if (argc < 2) {
        printf("Usage: %s [device_node] \n", argv[0]);
        return -1;
    }

    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];

    assert(sis8300drv_open_device(sisuser) == status_success);

    ntests = sizeof(settings_tests)/sizeof(settings_tests[0]);
    for (iter = 0; iter < ntests; iter++) {
        unsigned_rbv = 0;
        assert(sis8300drv_set_nsamples(sisuser, settings_tests[iter].nsamples) == status_success);
        assert(sis8300drv_get_nsamples(sisuser, &unsigned_rbv) == status_success);
        assert(settings_tests[iter].nsamples ==  unsigned_rbv);

        unsigned_rbv = 0;
        assert(sis8300drv_set_npretrig(sisuser, settings_tests[iter].npretrig) == status_success);
        assert(sis8300drv_get_npretrig(sisuser, &unsigned_rbv) == status_success);
        assert(settings_tests[iter].npretrig ==  unsigned_rbv);

        unsigned_rbv = 0;
        assert(sis8300drv_set_channel_mask(sisuser, settings_tests[iter].channel_mask) == status_success);
        assert(sis8300drv_get_channel_mask(sisuser, &unsigned_rbv) == status_success);
        assert(settings_tests[iter].channel_mask == unsigned_rbv);
        assert(sis8300drv_reg_read(sisuser, SIS8300_SAMPLE_CONTROL_REG, &unsigned_rbv) == status_success);
        assert((unsigned_rbv & SAMPLE_CONTROL_CH_DIS) == (~settings_tests[iter].channel_mask & SAMPLE_CONTROL_CH_DIS));

        clksrc_rbv = -1;
        assert(sis8300drv_set_clock_source(sisuser, settings_tests[iter].clksrc) == status_success);
        assert(sis8300drv_get_clock_source(sisuser, &clksrc_rbv) == status_success);
        assert(settings_tests[iter].npretrig ==  clksrc_rbv);
        assert(sis8300drv_set_clock_divider(sisuser, settings_tests[iter].clkdiv) == status_success);

        printf("PASS test #%d\n", iter);
    }

    sis8300drv_close_device(sisuser);

    return(0);
}
