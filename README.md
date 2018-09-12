llrf-tools
===

Decouple the subystem specific application (llrf-tools) from e3 as a standalone applications.


## Warnings

The current implementation is to focus "compiling", one should verify these changes are valid for the current LLRF system at all. 


## Procedure

```
$ make
--------------------------------------- 
Available targets
--------------------------------------- 
init            Clone sis8300drv, switch to MODULE_TAG revision
build           Build all applications in bin directory
clean           Remove bin path, and all objects
distclean       Remove source path
env             Print interesting VARIABLES
vars            Print interesting VARIABLES
```



```
$ make init
$ make build
```

One can see the folliwng files in bin directory :
```
$ tree bin/
bin/
├── [jhlee     62K]  sis8300_arm_and_wait_trigg_4.2.0
├── [jhlee     63K]  sis8300_init_4.2.0
├── [jhlee     64K]  sis8300_mem_test_4.2.0
├── [jhlee     63K]  sis8300_read_custom_regs_4.2.0
├── [jhlee     64K]  sis8300_read_ddr_mem_4.2.0
├── [jhlee     68K]  sis8300_reg_test_4.2.0
├── [jhlee     63K]  sis8300_rst_test_4.2.0
├── [jhlee     63K]  sis8300_set_custom_sw_triggers_4.2.0
├── [jhlee     63K]  sis8300_setup_near_iq_4.2.0
├── [jhlee     64K]  sis8300_trigger_fsm_4.2.0
├── [jhlee     63K]  sis8300_trigger_fsm_unarmed_4.2.0
├── [jhlee     64K]  sis8300_verify_tables_4.2.0
├── [jhlee     63K]  sis8300_wait_irq_4.2.0
├── [jhlee     63K]  sis8300_write_custom_regs_4.2.0
└── [jhlee     67K]  sis8300_write_ddr_mem_4.2.0

```

Clean up others :

```
$ make clean
$ make distclean
```




