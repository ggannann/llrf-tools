#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <assert.h>
#include <unistd.h>

#include "sis8300_reg.h"
#include "sis8300drv.h"

#include "sis8300_llrf_reg.h"
#include "sis8300_llrf_utils.h"

#define NBR_OF_SW_RST_TESTS 10000

int trigger_pms(sis8300drv_usr *sisuser){
  
    int status, state;
    unsigned reg_val;
    write_reg_cl(sisuser,LLRF_GIP_S,0x100);
    usleep(4000);
    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
    state = print_state(reg_val);
    if (state != 6){
        printf("Wrong state! Expected state: PMS\n");
        return -1;
    }
    return 0;
}


int main(int argc, char **argv) {
    int status,i,state;
    int default_error = 0;
    unsigned reg_data[68] = {
			     0x00000000,0xFFFFFFFF,0xAAAAAAAA, 0x55555555,
			     0x1,0x2,0x4,0x8,
			     0x10,0x20,0x40,0x80,
			     0x100,0x200,0x400,0x800,
			     0x1000,0x2000,0x4000,0x8000,
			     0x10000,0x20000,0x40000,0x80000,
			     0x100000,0x200000,0x400000,0x800000,
			     0x1000000,0x2000000,0x4000000,0x8000000,
			     0x1000000,0x2000000,0x4000000,0x8000000,
			     0xFFFFFFFFE,0xFFFFFFFD,0xFFFFFFFB,0xFFFFFFF7,
			     0xFFFFFFFEF,0xFFFFFFDF,0xFFFFFFBF,0xFFFFFF7F,
			     0xFFFFFFEFF,0xFFFFFDFF,0xFFFFFBFF,0xFFFFF7FF,
			     0xFFFFFEFFF,0xFFFFDFFF,0xFFFFBFFF,0xFFFF7FFF,
			     0xFFFFEFFFF,0xFFFDFFFF,0xFFFBFFFF,0xFFF7FFFF,
			     0xFFEFFFFF,0xFFDFFFFF,0xFFBFFFFF,0xFF7FFFFF,
			     0xFEFFFFFF,0xFDFFFFFF,0xFBFFFFFF,0xF7FFFFFF,
			     0xEFFFFFFF,0xDFFFFFFF,0xBFFFFFFF,0x7FFFFFFF
    };
    unsigned reg_value_rb, reg_val;
    unsigned reg_addr,mask;
    sis8300drv_usr *sisuser;

    /* Check nbr of arguments */    
    if (argc != 2) {
        printf("Usage: %s [device_node, e.g. /dev/sis8300-4]\n", argv[0]);
        return -1;
    }

    /* Open device */    
    sisuser = malloc(sizeof(sis8300drv_usr));
    sisuser->file = argv[1];
    status = sis8300drv_open_device(sisuser);
    if (status) {
        printf("sis8300drv_open_device error: %d\n", status);
        return -1;
    }
    
    
/****************************************************************
 *   Read registers default value
 ****************************************************************/
    printf("************************************************\n");
    printf("Reading registers default value from 0x%03X to 0x%03X\n",LLRF_FIRST_REG_TEST,LLRF_LAST_REG_TEST);
    printf("************************************************\n");
    for ( reg_addr=LLRF_FIRST_REG_TEST; reg_addr<=LLRF_LAST_REG_TEST; reg_addr++){
    	if( reg_attribute[reg_addr&0xFF][0] < 2 ){
    		read_reg_cl(sisuser, reg_addr,&reg_value_rb);
    		if( reg_value_rb !=  reg_attribute[reg_addr&0xFF][2]){
    			printf("EXPECTED:");
    			print_reg_cl(reg_addr,reg_attribute[reg_addr&0xFF][2]);    			
    			printf("READ    :");
    			print_reg_cl(reg_addr,reg_value_rb);    			
    			default_error = 1;
    		}
    	}
    }
    if( default_error == 0 ){
    	printf("\tAll default values matching!\n");
    }
    printf("************************************************\n\n");
    
	default_error = 0;
/****************************************************************
 *   Write/Read register test
 ****************************************************************/
    printf("************************************************\n");
    printf("Write/Read register test from 0x%03X to 0x%03X\n",LLRF_FIRST_REG_TEST,LLRF_LAST_REG_TEST);
    printf("************************************************\n");
    for ( reg_addr=LLRF_FIRST_REG_TEST; reg_addr<=LLRF_LAST_REG_TEST; reg_addr++){
    	if( reg_attribute[reg_addr&0xFF][0] == 0 ){
			mask = reg_attribute[reg_addr&0xFF][1];
    		for(i=0;i<68;i++){
    			write_reg_cl(sisuser,reg_addr,reg_data[i]);
    			read_reg_cl(sisuser, reg_addr,&reg_value_rb);
    			if( reg_value_rb !=  (reg_data[i]&mask)){
    				printf("EXPECTED:");
    				print_reg_cl(reg_addr,reg_data[i]&mask);    			
    				printf("READ    :");
    				print_reg_cl(reg_addr,reg_value_rb);    			
    				default_error = 1;
    			}
    		}
    	}
    }
    if( default_error == 0 ){
    	printf("\tAll write/read tests passed!\n");
    }
    printf("************************************************\n\n");
    

    
	default_error = 0;
/****************************************************************
 *   SW reset test
 ****************************************************************/
	printf("************************************************\n");
	printf("SW reset and default value test from 0x%03X to 0x%03X\n",LLRF_FIRST_REG_TEST,LLRF_LAST_REG_TEST);
	printf("************************************************\n");
	for(i=0;i<NBR_OF_SW_RST_TESTS;i++){
	    write_reg_cl(sisuser,LLRF_GIP_S,0x400);
	    for ( reg_addr=LLRF_FIRST_REG_TEST; reg_addr<=LLRF_LAST_REG_TEST; reg_addr++){
	        if( reg_attribute[reg_addr&0xFF][0] < 2 ){
	            read_reg_cl(sisuser, reg_addr,&reg_value_rb);
	            if( reg_value_rb !=  reg_attribute[reg_addr&0xFF][2]){
	                printf("EXPECTED:");
	                print_reg_cl(reg_addr,reg_attribute[reg_addr&0xFF][2]);
	                printf("READ    :");
	                print_reg_cl(reg_addr,reg_value_rb);
	                default_error = 1;
	            }
	        }
	    }
	}
	if( default_error == 0 ){
        printf("\tAll default values matching after SW reset!\n");
        printf("\t\t%d iterations done\n",NBR_OF_SW_RST_TESTS);
    }
	printf("************************************************\n\n");
    
	default_error = 0;
/****************************************************************
 *   Functional test
 ****************************************************************/
	printf("************************************************\n");
	printf("Functional register test\n");
	printf("************************************************\n");
	// setup signal monitor limits that will trigger alarm
    status = sis8300drv_reg_write(sisuser, LLRF_MON_LIMIT_1, 0x40004000);
    status = sis8300drv_reg_write(sisuser, LLRF_MON_LIMIT_2, 0x40004000);
    status = sis8300drv_reg_write(sisuser, LLRF_MON_LIMIT_3, 0x40004000);
    status = sis8300drv_reg_write(sisuser, LLRF_MON_LIMIT_4, 0x40004000);
    status = sis8300drv_reg_write(sisuser, LLRF_MON_PARAM_1, 0x10101010);
    status = sis8300drv_reg_write(sisuser, LLRF_MON_PARAM_2, 0x10101010);

	// execute main FSM through debug triggers
    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
    state = print_state(reg_val);
    if (state != 0){
        printf("Wrong state! Expected state: INIT\n");
        return -1;
    }
    status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x1);
    usleep(3000);
    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
    state = print_state(reg_val);
    if (state != 1){
        printf("Wrong state! Expected state: IDLE\n");
        return -1;
    }
    status = sis8300drv_reg_write(sisuser, 0x10, 0x2);
    status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x20);
    usleep(3000);
    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
    state = print_state(reg_val);
    if (state != 3){
        printf("Wrong state! Expected state: ACTIVE_NO_PULSE\n");
        return -1;
    }
    status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x40);
    usleep(3000);
    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
    state = print_state(reg_val);
    if (state != 4){
        printf("Wrong state! Expected state: ACTIVE_PULSE\n");
        return -1;
    }
    status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x80);
    usleep(3000);
    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
    state = print_state(reg_val);
    if (state != 1){
        printf("Wrong state! Expected state: IDLE\n");
        return -1;
    }
    printf("\tForce triggers and main FSM check PASSED\n");
	// Check read only regs for sign of life	
	for ( reg_addr=LLRF_FIRST_REG_TEST; reg_addr<=LLRF_LAST_REG_TEST; reg_addr++){
		if( reg_attribute[reg_addr&0xFF][0] == 3 ){
			read_reg_cl(sisuser, reg_addr,&reg_value_rb);
			if( reg_value_rb ==  reg_attribute[reg_addr&0xFF][2]){
				printf("EXPECTED: Value changed from default\n");
				print_reg_cl(reg_addr,reg_value_rb);
				default_error = 1;
        	}
        }
    }
	if( default_error == 0 ){
		printf("\n\tFunctional register sanity check PASSED!\n");
    }
	printf("************************************************\n\n");

	
	default_error = 0;
/****************************************************************
 *   Special register test
 ****************************************************************/
	printf("************************************************\n");
	printf("Special register test\n");
	printf("************************************************\n");
    // Monitor status reg
	// check that alarm is triggered
    read_reg_cl(sisuser, LLRF_MON_STATUS,&reg_value_rb);
    if( reg_value_rb == 0x0 ){
        printf("EXPECTED: LLRF_MON_STATUS - ALARM\n");
        printf("READ    :");
        print_reg_cl(LLRF_MON_STATUS,reg_value_rb);
    }else{
        printf("\tSignal monitor status - Alarm triggered: PASSED\n");
    }
    // clear alarm status from signals monitor
    write_reg_cl(sisuser,LLRF_MON_STATUS,0xDEADBEEF);
    read_reg_cl(sisuser, LLRF_MON_STATUS,&reg_value_rb);
    if( reg_value_rb != 0x0 ){
        printf("EXPECTED: LLRF_MON_STATUS - NO ALARMS!\n");
        printf("READ    :");
        print_reg_cl(LLRF_MON_STATUS,reg_value_rb);
    }else{
        printf("\tClear Alarm status from signal monitor: PASSED\n");
    }
	// Clear pulse count in GOP
	write_reg_cl(sisuser,LLRF_GIP_S,0x1000);
	read_reg_cl(sisuser, LLRF_GOP,&reg_value_rb);
	if( (reg_value_rb&0xFFFF0000) != 0 ){
		printf("EXPECTED: LLRF_GOP - PULSE_CNT = 0\n");
		printf("READ    :");
		print_reg_cl(reg_addr,reg_value_rb);    					
	}else{
		printf("\tClear PULSE_CNT PASSED\n");		
	}
	// write a read-only reg
	write_reg_cl(sisuser,LLRF_ID,0xDEADBEEF);
	read_reg_cl(sisuser, LLRF_GOP,&reg_value_rb);
	if( (reg_value_rb&0x10) != 0x10 ){
		printf("EXPECTED: LLRF_GOP - WRITE ERROR\n");
		printf("READ    :");
		print_reg_cl(LLRF_GOP,reg_value_rb);    					
	}else{
		printf("\tWrite error PASSED\n");		
	}
	// read a non-existing reg
	read_reg_cl(sisuser, LLRF_LAST_REG+1,&reg_value_rb);
	read_reg_cl(sisuser, LLRF_GOP,&reg_value_rb);
	if( (reg_value_rb&0x20) != 0x20 ){
		printf("EXPECTED: LLRF_GOP - READ ERROR\n");
		printf("READ    :");
		print_reg_cl(LLRF_GOP,reg_value_rb);    					
	}else{
		printf("\tRead error PASSED\n");		
	}
    // clear read/write error from GOP
	write_reg_cl(sisuser,LLRF_GOP,0xDEADBEEF);
	read_reg_cl(sisuser, LLRF_GOP,&reg_value_rb);
	if( (reg_value_rb&0x30) != 0 ){
		printf("EXPECTED: LLRF_GOP - NO READ or WRITE ERRORS\n");
		printf("READ    :");
		print_reg_cl(LLRF_GOP,reg_value_rb);    					
	}else{
		printf("\tClear read/write error PASSED\n");		
	}
	// test GIP-PULSE_TYPE and Mem storage select
	default_error = 0;
	reg_addr = LLRF_GIP;
	mask = reg_attribute[reg_addr&0xFF][1];
	for(i=0;i<4;i++){
		write_reg_cl(sisuser,reg_addr,reg_data[i]&mask);
		read_reg_cl(sisuser, reg_addr,&reg_value_rb);
		if( reg_value_rb !=  (reg_data[i]&mask)){
			printf("EXPECTED:");
			print_reg_cl(reg_addr,reg_data[i]&mask);    			
			printf("READ    :");
			print_reg_cl(reg_addr,reg_value_rb);    			
			default_error = 1;
		}
	}
	if(default_error==0){
		printf("\tW/R GIP-pulse_type and mem_select PASSED\n");		
	}
	// test force PMS trigger
	write_reg_cl(sisuser,LLRF_GIP_S,0x100);
    usleep(3000);
    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
    state = print_state(reg_val);
    if (state != 6){
        printf("Wrong state! Expected state: PMS\n");
        return -1;
    }
	printf("\tforce PMS trigger PASSED\n");		
	printf("************************************************\n\n");



	default_error = 0;
	/****************************************************************
	 *   PMS test
	 ****************************************************************/
	printf("************************************************\n");
	printf("PMS test\n");
	printf("************************************************\n");

    // execute main FSM through debug triggers
	for( i=0; i<5; i++ ){
	    write_reg_cl(sisuser,LLRF_GIP_S,0x400);
        usleep(30);
	    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
	    state = print_state(reg_val);
	    if (state != 0){
	        printf("Wrong state! Expected state: INIT\n");
	        return -1;
	    }
	    if(i==0){
	        status=trigger_pms(sisuser);
	        if (status == -1){
	            return -1;
	        }
	        continue;
	    }
	    status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x1);
	    usleep(3000);
	    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
	    state = print_state(reg_val);
	    if (state != 1){
	        printf("Wrong state! Expected state: IDLE\n");
	        return -1;
	    }
        if(i==1){
            status=trigger_pms(sisuser);
            if (status == -1){
                return -1;
            }
            continue;
        }
	    status = sis8300drv_reg_write(sisuser, 0x10, 0x2);
	    status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x20);
	    usleep(3000);
	    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
	    state = print_state(reg_val);
	    if (state != 3){
	        printf("Wrong state! Expected state: ACTIVE_NO_PULSE\n");
	        return -1;
	    }
        if(i==2){
            status=trigger_pms(sisuser);
            if (status == -1){
                return -1;
            }
            continue;
        }
	    status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x40);
	    usleep(3000);
	    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
	    state = print_state(reg_val);
	    if (state != 4){
	        printf("Wrong state! Expected state: ACTIVE_PULSE\n");
	        return -1;
	    }
        if(i==3){
            status=trigger_pms(sisuser);
            if (status == -1){
                return -1;
            }
            continue;
        }
	    status = sis8300drv_reg_write(sisuser, LLRF_GIP_S, 0x80);
	    usleep(3000);
	    status = sis8300drv_reg_read(sisuser, LLRF_GOP, &reg_val);
	    state = print_state(reg_val);
	    if (state != 1){
	        printf("Wrong state! Expected state: IDLE\n");
	        return -1;
	    }
	    printf("\tForce PMS check PASSED\n");
	    printf("************************************************\n\n");
	}



    // SW reset
    write_reg_cl(sisuser,LLRF_GIP_S,0x400);
    printf("Custom logic SW-reseted.\n");









/****************************************************************
 *   Register test end
 ****************************************************************/

    /* Close device */    
    sis8300drv_close_device(sisuser);

    return(0);
}
