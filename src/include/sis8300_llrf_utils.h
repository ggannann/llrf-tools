#ifndef SIS8300_LLRF_UTILS_H_
#define SIS8300_LLRF_UTILS_H_

#include "sis8300drv.h"

/* LLRF COMMON FUNCTIONS */
void write_reg_cl(sis8300drv_usr *sisuser, unsigned reg_addr, unsigned reg_val);
void read_reg_cl(sis8300drv_usr *sisuser, unsigned reg_addr, unsigned *reg_val);
int print_state(unsigned reg_val);
void print_reg_cl(unsigned reg_addr, unsigned reg_val);


#endif /* SIS8300_LLRF_UTILS_H_ */
