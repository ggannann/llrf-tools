PROJECT=llrftools

include ${EPICS_ENV_PATH}/module.Makefile

EXCLUDE_ARCHS += eldk
SOURCES=$(wildcard lib/*.c)
HEADERS=$(wildcard include/*.h)

#EXECUTABLES = $(patsubst %.c, %, $(wildcard custom_logic/*.c))
#XECUTABLES += $(patsubst %.c, %, $(wildcard src/llrfcustom/examples/*.c))

EXECUTABLES =   sis8300_arm_and_wait_trigg      \
                sis8300_read_custom_regs        \
                sis8300_rst_test                \
                sis8300_trigger_fsm             \
                sis8300_wait_irq                \
                sis8300_init                    \
                sis8300_read_ddr_mem            \
                sis8300_set_custom_sw_triggers  \
                sis8300_trigger_fsm_unarmed     \
                sis8300_write_custom_regs       \
                sis8300_mem_test                \
                sis8300_reg_test                \
                sis8300_setup_near_iq           \
                sis8300_verify_tables           \
                sis8300_write_ddr_mem  


vpath %.c ../../custom_logic/

#EXECUTABLES=${LLRFTOOLS_OBJS}

USR_DEPENDENCIES += sis8300drv
USR_DEPENDENCIES += llrftools
USR_DEPENDENCIES += udev

SIS8300DRV_LIB = -L ${EPICS_MODULES_PATH}/sis8300drv/2.0.0/${EPICSVERSION}/lib/${T_A} -lsis8300drv
LLRFTOOLS_LIB  = ${SIS8300DRV_LIB} -L . -ludev -lllrftools


#$(LLRFTOOLS_OBJS): %.o
#	$(CCC) -o $@ ${SIS8300DRV_LIB} ${LLRFUTILS_LIB} $^

sis8300_arm_and_wait_trigg: sis8300_arm_and_wait_trigg.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_read_custom_regs: sis8300_read_custom_regs.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_rst_test: sis8300_rst_test.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_trigger_fsm: sis8300_trigger_fsm.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_wait_irq: sis8300_wait_irq.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_init: sis8300_init.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_read_ddr_mem: sis8300_read_ddr_mem.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_set_custom_sw_triggers: sis8300_set_custom_sw_triggers.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_trigger_fsm_unarmed: sis8300_trigger_fsm_unarmed.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_write_custom_regs: sis8300_write_custom_regs.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_mem_test: sis8300_mem_test.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_reg_test: sis8300_reg_test.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_setup_near_iq: sis8300_setup_near_iq.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_verify_tables: sis8300_verify_tables.o
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^
	
sis8300_write_ddr_mem: sis8300_write_ddr_mem.o  
	$(CCC) -o $@ ${LLRFTOOLS_LIB} $^


EXECUTABLES += $(wildcard matlab_scripts/*.m)
EXECUTABLES += $(wildcard scripts/*.sh)
