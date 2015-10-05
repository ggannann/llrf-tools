
####################################
# SETUP
####################################
# Device ID, change this if the struck card is moved to a new slot
DEV_SIS="/dev/sis8300-4"

# TOP DIRECTORY
TOP=$LLRF_CL_PATH

# CUSTOM LOGIC FUNCTIONS
CNIQ_CMD="requireExec llrftools,eit_ess -- sis8300_setup_near_iq $DEV_SIS"
CIRQ_CMD="requireExec llrftools,eit_ess -- sis8300_wait_irq $DEV_SIS"
CFSM_CMD="requireExec llrftools,eit_ess -- sis8300_trigger_fsm $DEV_SIS"
CINIT_CMD="requireExec llrftools,eit_ess -- sis8300_init $DEV_SIS"
CWR_CMD="requireExec llrftools,eit_ess -- sis8300_write_custom_regs $DEV_SIS"
CRD_CMD="requireExec llrftools,eit_ess -- sis8300_read_custom_regs $DEV_SIS"
CS_CMD="requireExec llrftools,eit_ess -- sis8300_set_custom_sw_triggers $DEV_SIS"
CWR_MEM="requireExec llrftools,eit_ess -- sis8300_write_ddr_mem $DEV_SIS"
CRD_MEM="requireExec llrftools,eit_ess -- sis8300_read_ddr_mem $DEV_SIS"
# TEST FUNCTIONS
CRT_CMD="requireExec llrftools,eit_ess -- sis8300_reg_test $DEV_SIS"
CMT_CMD="requireExec llrftools,eit_ess -- sis8300_mem_test $DEV_SIS"
CTT_CMD="requireExec llrftools,eit_ess -- sis8300_verify_tables $DEV_SIS"
# BASIC FUNCTIONS
WR_CMD="requireExec sis8300drv -- sis8300drv_reg $DEV_SIS"
RD_CMD="requireExec sis8300drv -- sis8300drv_reg $DEV_SIS"
# RTM functions
WR_RTM_ATT_CMD="requireExec sis8300drv -- sis8300drv_i2c_rtm $DEV_SIS"
RTM_SIS8900=0 
RTM_DWC8VM1=1 
RTM_DS8WM1=2 

#all the files that get created are located here
DATADIR=$LLRF_HOME/matlab

####################################
# VARIABLES
####################################
OPTIONS="SANITY_TESTS SETUP RUN DAC IQ_SAMPLING MOD_FILTER VM_CTRL PI_CTRL MEM_CTRL SIGNAL_GENERATOR Custom_output Trigger_FSM SW_reset HELP Quit"
OPTIONS_TEST="BACK REG_TEST MEM_SIZE_TEST SP_TABLE_TEST FF_TABLE_TEST"
OPTIONS_SG="BACK GEN_IQ_ang0 GEN_IQ_ang90 GEN_MA_ang0 GEN_MA_ang90 DECREASE_FF_TBL_SPEED USE_CIRCULAR_FF"
OPTIONS_SETUP="BACK SETUP_CARD SETUP_CARD_352_RTM SETUP_CARD_704_RTM SETUP_CUSTOM_LOGIC_PI_CTRL_IQ_352_MHZ SETUP_CUSTOM_LOGIC_PI_CTRL_IQ_704_MHZ SETUP_CUSTOM_LOGIC_SELF_EXCITING_MODE"
OPTIONS_RUN="BACK RUN_SEMI_AUTOMATIC RUN_AUTOMATIC RUN_AUTO_ROTATE"
OPTIONS_DAC="BACK MAX_MIN SAW INPUT_CH1_CH2 CUSTOM"
OPTIONS_IQ="BACK SET_IQ_OUTPUT_ZERO SET_IQ_OUTPUT_NORM TOGGLE_FREQ_OFFSET_MODE TOGGLE_PHASE_REF_ZERO TOGGLE_USE_ADDITIONAL_ROTATION TOGGLE_CAVITY_INPUT_DELAY_ENABLE SETUP_ADDITIONAL_ROT_ANG ADJUST_ANGLE SET_NEAR_IQ SET_CAVITY_INPUT_DELAY COMMIT_CHANGES COMMIT_CHANGES_IMMEDIATE_USE CURRENT_SETTINGS"
OPTIONS_FILTER="BACK SET_PI_OUTPUT_TO_INPUT SET_PI_OUTPUT_TO_NORM TOGGLE_FREQ_OFFSET_MODE TOGGLE_PHASE_REF_ZERO TOGGLE_PHASE_COMP ADJUST_ANGLE SETUP_S SETUP_C SETUP_A TOGGLE_START TOGGLE_STOP TOGGLE_FILTER_I_ON TOGGLE_FILTER_Q_ON COMMIT_CHANGES COMMIT_CHANGES_IMMEDIATE_USE CURRENT_SETTINGS"
OPTIONS_VM="BACK TOGGLE_SWAP_IQ TOGGLE_FORCE_ANGLE TOGGLE_FORCE_MAG TOGGLE_USE_MAG_LIMIT TOGGLE_INVERSE_OUTPUT_I_part TOGGLE_INVERSE_OUTPUT_Q_part SETUP_MAG_LIMIT COMMIT_CHANGES COMMIT_CHANGES_IMMEDIATE_USE CURRENT_SETTINGS"
OPTIONS_PI="BACK DECREASE_FF_TBL_SPEED USE_CIRCULAR_FF TOGGLE_FF_SOURCE TOGGLE_SP_SOURCE SETUP_PI CURRENT_SETTINGS_PI_1 CURRENT_SETTINGS_PI_2"
OPTIONS_PI_SETUP="BACK SETUP_PI_1 SETUP_PI_2 COMMIT_CHANGES COMMIT_CHANGES_IMMEDIATE_USE CURRENT_SETTINGS_PI_1 CURRENT_SETTINGS_PI_2"
OPTIONS_Custom_output="BACK DEBUG_VALUE NORM IQ:RAW IQ:ref_iq IQ:cav_iq IQ:ref_phase_rot_phase IQ:cav_and_rot_cav_i IQ:cav_and_rot_cav_q PI:SP_Val PI:FF_Val PI:SP_FF_Val PI:PI_ERROR CURRENT_SETTINGS"
OPTIONS_FSM="BACK PULSE_COMMING PULSE_START PULSE_END PMS UPDATE_SP UPDATE_FF NEW_PULSE_TYPE IRQ_CLEAR CURRENT_SETTINGS SW_RESET"
OPTIONS_MEM="BACK WRITE_MEM READ_MEM SETUP_FF_SP_MEM_LOC SETUP_LUT SETUP_MEM_STORE NEW_PULSE_TYPE_SETUP SETUP_SP_FF_OUTPUT PULSE_LUT CURRENT_SETTINGS SETUP_PI_ERROR COMMIT_CHANGES_IMMEDIATE_USE"

LLRF_FIRST_REG=0x400
LLRF_LAST_REG=0x433

STRUCK_ADC_SAMPLE_CTRL=0x11

LLRF_ID=0x400
LLRF_INST_ID=0x401
LLRF_GOP=0x402
LLRF_GIP=0x403
LLRF_GIP_S=0x404
LLRF_GIP_C=0x405
LLRF_PI_1_K=0x406
LLRF_PI_1_TS_DIV_TI=0x407
LLRF_PI_1_SAT_MAX=0x408
LLRF_PI_1_SAT_MIN=0x409
LLRF_PI_1_CTRL=0x40A
LLRF_PI_1_FIXED_SP=0x40B
LLRF_PI_1_FIXED_FF=0x40C
LLRF_PI_2_K=0x40D
LLRF_PI_2_TS_DIV_TI=0x40E
LLRF_PI_2_SAT_MAX=0x40F
LLRF_PI_2_SAT_MIN=0x410
LLRF_PI_2_CTRL=0x411
LLRF_PI_2_FIXED_SP=0x412
LLRF_PI_2_FIXED_FF=0x413
LLRF_IQ_CTRL=0x414
LLRF_IQ_ANGLE=0x415
LLRF_IQ_DC_OFFSET=0x416
LLRF_VM_CTRL=0x417
LLRF_VM_MAG_LIMIT=0x418
LLRF_SAMPLE_CNT=0x419
LLRF_PULSE_START_CNT=0x41A
LLRF_PULSE_ACTIVE_CNT=0x41B
LLRF_LUT_CTRL_1_PARAM=0x41C
LLRF_LUT_CTRL_2_PARAM=0x41D
LLRF_MEM_CTRL_1_PARAM=0x41E
LLRF_MEM_CTRL_2_PARAM=0x41F
LLRF_MEM_CTRL_3_PARAM=0x420
LLRF_MEM_CTRL_4_PARAM=0x421
LLRF_PI_ERR_MEM_SIZE=0x422
LLRF_PI_ERR_CNT=0x423
LLRF_ARB_CTRL_PARAM=0x424
LLRF_NEAR_IQ_1_PARAM=0x425
LLRF_NEAR_IQ_2_PARAM=0x426
LLRF_NEAR_IQ_DATA=0x427
LLRF_NEAR_IQ_ADDR=0x429
LLRF_FILTER_S=0x429
LLRF_FILTER_C=0x42A
LLRF_FILTER_A_CTRL=0x42B
LLRF_MON_STATUS_MAG_1=0x42C
LLRF_MON_STATUS_MAG_1=0x42D
LLRF_MON_STATUS_MAG_1=0x42E
LLRF_MON_STATUS_MAG_1=0x42F
LLRF_IQ_DEBUG1=0x430
LLRF_IQ_DEBUG2=0x431
LLRF_IQ_DEBUG3=0x432
LLRF_IQ_DEBUG4=0x433

MEM_SIZE=1
MEM_ADDR=0
DT_MAG=0
DT_ANG=0

####################################
# FUNCTIONS
####################################
function test_ff_tables {
  COUNTER=0
  echo "MUST BE IN IDLE TO RUN"
  echo "MUST HAVE THE sis8300llrf-demo-ioc STARTED"
  echo "DON'T START THE GUI!"
  echo "Setup sequence: 1) start ioc, 2) run serup_card, 3) run setup_pi_ctrl, 4) run this test, 5) SW reset before next test"
  echo "- Will write SP and FF tables to mem."
  echo "- Will execute and check that correct FF table was used."
  echo "- Will do this for pulse_type 0 to X."
  echo "Last pulse_type (X) to check? (in hex)"
  read answer  
  case $answer in
      [0-9abcdefABCDEF]* ) echo "Pulse_type 0 to 0x$answer will be tested"; ;;
      * ) echo "Only numbers expected"; break;;
  esac
  LAST_PULSE=$((16#$answer))
  echo "Press return to start"
  read answer
  for i in `seq 0 $LAST_PULSE`;
  do
      matlab_table $i
  done
  echo "All pulse_type tables generated"
  for i in `seq 0 $LAST_PULSE`;
  do
      pv=$(printf "LLRF:FF-PT%d:Q table_Q_ff_%d.txt" $i $i)
#      echo $pv
      sis8300llrf-demo-importTableFromFile.py $pv 
      pv=$(printf "LLRF:FF-PT%d:I table_I_ff_%d.txt" $i $i)
#      echo $pv
      sis8300llrf-demo-importTableFromFile.py $pv 
      pv=$(printf "LLRF:SP-PT%d:Q table_Q_sp_%d.txt" $i $i)
#      echo $pv
      sis8300llrf-demo-importTableFromFile.py $pv 
      pv=$(printf "LLRF:SP-PT%d:I table_I_sp_%d.txt" $i $i)
#      echo $pv
      sis8300llrf-demo-importTableFromFile.py $pv 
  done
  echo "All pulse_type tables loaded"
  # output FF values from PI-ctrl
  set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x10 > $DATADIR/tmp.txt
  set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x10 > $DATADIR/tmp.txt
  # Use FF table
  set_bits $LLRF_PI_1_CTRL 0xFFFFFFFD 0x0 > $DATADIR/tmp.txt
  set_bits $LLRF_PI_2_CTRL 0xFFFFFFFD 0x0 > $DATADIR/tmp.txt
  # Store VM-input in PI-error mem
  reg_val=$(echo "5*8192" | bc -l)
  reg_val=$(printf "%x\n" $reg_val)
  $CWR_CMD $LLRF_GIP_C E000 > $DATADIR/tmp.txt
  $CWR_CMD $LLRF_GIP_S $reg_val
  $CS_CMD   2 > $DATADIR/tmp.txt
  echo "Checking that pulse_type tables are loaded correct:"
  for j in `seq 0 $LAST_PULSE`;
  do
     #set pulse type
     pulse_type=$(($j*65536))
     set_bits $LLRF_GIP 0x0000FFFF $pulse_type > $DATADIR/tmp.txt
     # update tables
     $CS_CMD   3 > $DATADIR/tmp.txt
     # run 1 itteration
     $CFSM_CMD 1 0 > $DATADIR/tmp.txt
     # verify pi_error mem against sp_table
     $CTT_CMD 0
  done
  echo "TEST DONE"
#  save_input_to_file > $DATADIR/tmp.txt
#  matlab_plot
  echo "Last pulse plotted in matlab"
}

function test_sp_tables {
  COUNTER=0
  echo "MUST BE IN IDLE TO RUN"
  echo "MUST HAVE THE sis8300llrf-demo-ioc STARTED"
  echo "DON'T START THE GUI!"
  echo "Setup sequence: 1) start ioc, 2) run serup_card, 3) run setup_pi_ctrl, 4) run this test, 5) SW reset before next test"
  echo "- Will write SP and FF tables to mem."
  echo "- Will execute and check that correct SP tables was used."
  echo "- Will do this for pulse_type 0 to X."
  echo "Last pulse_type (X) to check? (in hex)"
  read answer  
  case $answer in
      [0-9abcdefABCDEF]* ) echo "Pulse_type 0 to 0x$answer will be tested"; ;;
      * ) echo "Only numbers expected"; break;;
  esac
  LAST_PULSE=$((16#$answer))
  echo "Press return to start"
  read answer
  for i in `seq 0 $LAST_PULSE`;
  do
      matlab_table $i
  done
  echo "All pulse_type tables generated"
  for i in `seq 0 $LAST_PULSE`;
  do
      pv=$(printf "LLRF:FF-PT%d:Q table_Q_ff_%d.txt" $i $i)
#      echo $pv
      sis8300llrf-demo-importTableFromFile.py $pv 
      pv=$(printf "LLRF:FF-PT%d:I table_I_ff_%d.txt" $i $i)
#      echo $pv
      sis8300llrf-demo-importTableFromFile.py $pv 
      pv=$(printf "LLRF:SP-PT%d:Q table_Q_sp_%d.txt" $i $i)
#      echo $pv
      sis8300llrf-demo-importTableFromFile.py $pv 
      pv=$(printf "LLRF:SP-PT%d:I table_I_sp_%d.txt" $i $i)
#      echo $pv
      sis8300llrf-demo-importTableFromFile.py $pv 
  done
  echo "All pulse_type tables loaded"
  # zero input to PI-ctrl
  set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0x1C > $DATADIR/tmp.txt
  # Use SP table
  set_bits $LLRF_PI_1_CTRL 0xFFFFFFFE 0x0 > $DATADIR/tmp.txt
  set_bits $LLRF_PI_2_CTRL 0xFFFFFFFE 0x0 > $DATADIR/tmp.txt
  echo "Checking that pulse_type tables are loaded correct:"
  for j in `seq 0 $LAST_PULSE`;
  do
     #set pulse type
     pulse_type=$(($j*65536))
     set_bits $LLRF_GIP 0x0000FFFF $pulse_type > $DATADIR/tmp.txt
     # update tables
     $CS_CMD   3 > $DATADIR/tmp.txt
     # run 1 itteration
     $CFSM_CMD 1 0 > $DATADIR/tmp.txt
     # verify pi_error mem against sp_table
     $CTT_CMD 1
  done
  echo "TEST DONE"
#  save_input_to_file > $DATADIR/tmp.txt
#  matlab_plot
#  echo "Last pulse plotted in matlab"
}

function run_auto {
  COUNTER=0
  echo "MUST BE IN IDLE TO RUN"
  echo "Will run a fixed nbr of iterations of the FSM loop before ending."
  echo "How many iterations (HEX)?"
  read answer  
  case $answer in
      [0-9abcdefABCDEF]* ) echo "0x$answer iterations will be executed"; ;;
      * ) echo "Only numbers expected"; break;;
  esac
  NBR_ITER=$answer
  echo "Press return to start"
  read answer
  STARTTIME=$(date +%s)
  $CIRQ_CMD $NBR_ITER &
  $CFSM_CMD $NBR_ITER $1
  ENDTIME=$(date +%s)
  NBR_ITER_dec=$((0x$NBR_ITER/1))
  echo "It took $(($ENDTIME - $STARTTIME)) seconds to complete this task."
  echo "  Average time between two pulses: $((($ENDTIME - $STARTTIME)*1000/$NBR_ITER_dec)) ms."
  save_input_to_file
  matlab_plot
  echo ""
  echo "Last pulse plotted in matlab"
}
function change_v {
  reg_val=$($CRD_CMD $2 | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
  reg_val=$(($reg_val/1))
#  echo raw $reg_val
  reg_val=$(($reg_val + $1))
#  echo new $reg_val
  reg_val=$(printf "%x\n" $reg_val)
#  echo hex $reg_val
  $CWR_CMD  $2 $reg_val
  $CS_CMD   2 > $DATADIR/tmp.txt
  $CS_CMD   A > $DATADIR/tmp.txt
}
function set_v {
  reg_val=$(printf "%x\n" $1)
  $CWR_CMD  $2 $reg_val
  $CS_CMD   2 > $DATADIR/tmp.txt
  $CS_CMD   A > $DATADIR/tmp.txt
}
function angle_offset_adjust {
  COUNTER=0
  echo "Press RETURN to add 1 degree to angle offset."
  echo "Type BREAK, END or QUIT to end angle offset adjustment."
  echo "Type + or - to add/sub angle by 0.01 degrees."
  echo "Type ++ or -- to add/sub angle by 0.1 degrees."
  echo "Type +++ or --- to add/sub angle by 1 degrees."
  echo "Type ++++ or ---- to add/sub angle by 5 degrees."
  echo "Type a0, a90, a180 or a270 to change angle to 0, 90, 180 or 270."
  echo "Type help to see this text"
  while [  $COUNTER -lt 10 ]; do
    read answer
    case $answer in
        [BbEeQq]* ) echo "End SEL angle offset adjustment"; break;;
        ++++ ) change_v  5719 $LLRF_IQ_ANGLE;;
        +++  ) change_v  1144 $LLRF_IQ_ANGLE;;
        ++   ) change_v   114 $LLRF_IQ_ANGLE;;
        +    ) change_v    11 $LLRF_IQ_ANGLE;;
        ---- ) change_v -5719 $LLRF_IQ_ANGLE;;
        ---  ) change_v -1144 $LLRF_IQ_ANGLE;;
        --   ) change_v  -114 $LLRF_IQ_ANGLE;;
        -    ) change_v   -11 $LLRF_IQ_ANGLE;;
        a0   ) set_v        0 $LLRF_IQ_ANGLE;;
        a90  ) set_v   102944 $LLRF_IQ_ANGLE;;
        a180 ) set_v   205887 $LLRF_IQ_ANGLE;;
        a270 ) set_v   308831 $LLRF_IQ_ANGLE;;
        m0   ) set_v        0 $LLRF_VM_MAG_LIMIT;;
        m100  ) set_v   65535 $LLRF_VM_MAG_LIMIT;;
        m10   ) set_v    6554 $LLRF_VM_MAG_LIMIT;;
        m20   ) set_v   13207 $LLRF_VM_MAG_LIMIT;;
        m30   ) set_v   19661 $LLRF_VM_MAG_LIMIT;;
        m40   ) set_v   26214 $LLRF_VM_MAG_LIMIT;;
        m50   ) set_v   32678 $LLRF_VM_MAG_LIMIT;;
        m60   ) set_v   39321 $LLRF_VM_MAG_LIMIT;;
        m70   ) set_v   45874 $LLRF_VM_MAG_LIMIT;;
        m80   ) set_v   52428 $LLRF_VM_MAG_LIMIT;;
        m90   ) set_v   58982 $LLRF_VM_MAG_LIMIT;;
        [hH]* )   echo "Press RETURN to add 1 degree to angle offset.";
                  echo "Type BREAK, END or QUIT to end angle offset adjustment.";
                  echo "Type + or - to add/sub angle by 0.01 degrees.";
                  echo "Type ++ or -- to add/sub angle by 0.1 degrees.";
                  echo "Type +++ or --- to add/sub angle by 1 degrees.";
                  echo "Type ++++ or ---- to add/sub angle by 5 degrees.";
                  echo "Type a0, a90, a180 or a270 to change angle to 0, 90, 180 or 270.";
                  echo "Type help to see this text";;
        * ) change_v  1144 $LLRF_IQ_ANGLE;;
    esac
  done
}
function run_semi {
  COUNTER=0
  echo "Press RETURN to step to next state. Type BREAK, END or QUIT to stop semi automatic run mode."
  echo "Type i++ or i-- to immediatly change set-point I with +-512."
  echo "Type q++ or q-- to immediatly change set-point Q with +-512."
#  echo "Type m++ or m-- to immediatly change set-point mag by 0.1 (mag between 0-1)."
#  echo "Type a++ or a-- to immediatly change set-point ang by 5 degrees (ang between -180 - +180)."
  while [  $COUNTER -lt 10 ]; do
    read answer
    case $answer in
        [BbEeQ]* ) echo "Ending Semi automatic run mode"; break;;
        q++ ) change_v   512 $LLRF_PI_2_FIXED_SP;;
        q+  ) change_v   256 $LLRF_PI_2_FIXED_SP;;
        q-- ) change_v  -512 $LLRF_PI_2_FIXED_SP;;
        q-  ) change_v  -256 $LLRF_PI_2_FIXED_SP;;
        i++ ) change_v   512 $LLRF_PI_1_FIXED_SP;;
        i+  ) change_v   256 $LLRF_PI_1_FIXED_SP;;
        i-- ) change_v  -512 $LLRF_PI_1_FIXED_SP;;
        i-  ) change_v  -256 $LLRF_PI_1_FIXED_SP;;
        i0  ) set_v        0 $LLRF_PI_1_FIXED_SP;;
        i25 ) set_v     8192 $LLRF_PI_1_FIXED_SP;;
        i50 ) set_v    16384 $LLRF_PI_1_FIXED_SP;;
        i75 ) set_v    24576 $LLRF_PI_1_FIXED_SP;;
        i100) set_v    32767 $LLRF_PI_1_FIXED_SP;;
        q0  ) set_v        0 $LLRF_PI_2_FIXED_SP;;
        q25 ) set_v     8192 $LLRF_PI_2_FIXED_SP;;
        q50 ) set_v    16384 $LLRF_PI_2_FIXED_SP;;
        q75 ) set_v    24576 $LLRF_PI_2_FIXED_SP;;
        q100) set_v    32767 $LLRF_PI_2_FIXED_SP;;
        i25- ) set_v     -8192 $LLRF_PI_1_FIXED_SP;;
        i50- ) set_v    -16384 $LLRF_PI_1_FIXED_SP;;
        i75- ) set_v    -24576 $LLRF_PI_1_FIXED_SP;;
        i100-) set_v    -32767 $LLRF_PI_1_FIXED_SP;;
        q25- ) set_v     -8192 $LLRF_PI_2_FIXED_SP;;
        q50- ) set_v    -16384 $LLRF_PI_2_FIXED_SP;;
        q75- ) set_v    -24576 $LLRF_PI_2_FIXED_SP;;
        q100-) set_v    -32767 $LLRF_PI_2_FIXED_SP;;
#        a++ ) change_v   715 $LLRF_PI_2_FIXED_SP;;
#        a+  ) change_v   143 $LLRF_PI_2_FIXED_SP;;
#        a-- ) change_v  -715 $LLRF_PI_2_FIXED_SP;;
#        a-  ) change_v  -143 $LLRF_PI_2_FIXED_SP;;
#        m++ ) change_v  6554 $LLRF_PI_1_FIXED_SP;;
#        m+  ) change_v   655 $LLRF_PI_1_FIXED_SP;;
#        m-- ) change_v -6554 $LLRF_PI_1_FIXED_SP;;
#        m-  ) change_v  -655 $LLRF_PI_1_FIXED_SP;;
#        m0  ) set_v        0 $LLRF_PI_1_FIXED_SP;;
#        m25 ) set_v    16384 $LLRF_PI_1_FIXED_SP;;
#        m50 ) set_v    32768 $LLRF_PI_1_FIXED_SP;;
#        m75 ) set_v    49152 $LLRF_PI_1_FIXED_SP;;
#        m100) set_v    65535 $LLRF_PI_1_FIXED_SP;;
        * ) change_state;;
    esac
  done
}
function change_state {
    reg_val=$($CRD_CMD $LLRF_GOP | grep -m1 -Po 'FSM State: 0x[0-9]' | grep -m1 -Po '0x[0-9]')
    reg_val=$(($reg_val))
    if [ "$reg_val" -eq "1" ]; then
      set_bits_no_commit $STRUCK_ADC_SAMPLE_CTRL 0x800  > $DATADIR/tmp.txt
      $WR_CMD  0x10 -w 0x2  > $DATADIR/tmp.txt
      $CS_CMD   6 > $DATADIR/tmp.txt
      print_state
      reg_val=$($CRD_CMD $LLRF_PI_1_FIXED_SP | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
      reg_val=$(($reg_val/1))
      reg_val=$(echo "$reg_val/32768" | bc -l)
      printf '  Fixed Set-Point I: %f\n' $reg_val
      reg_val=$($CRD_CMD $LLRF_PI_2_FIXED_SP | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
      reg_val=$(($reg_val/1))
      reg_val=$(echo "$reg_val/32768" | bc -l)
      printf '  Fixed Set-Point Q: %f\n' $reg_val
    elif [ "$reg_val" -eq "3" ]; then
      $CS_CMD   7 > $DATADIR/tmp.txt
      print_state
    elif [ "$reg_val" -eq "4" ]; then
      $CS_CMD   8 > $DATADIR/tmp.txt
      print_state
      save_input_to_file
      matlab_plot
    else
      print_state
      echo "unexpected state, breaking loop."
      break
    fi
    echo "####################################################"
}
function print_state {
    reg_val=$($CRD_CMD $LLRF_GOP | grep -m1 -Po 'FSM State: 0x[0-9]' | grep -m1 -Po '0x[0-9]')
    reg_val=$(($reg_val))
    if [ "$reg_val" -eq "0" ]; then
      echo "Current State: INIT"
    elif [ "$reg_val" -eq "1" ]; then
      echo "Current State: IDLE"
    elif [ "$reg_val" -eq "2" ]; then
      echo "Current State: PULSE SETUP"
    elif [ "$reg_val" -eq "3" ]; then
      echo "Current State: ACTIVE NO-PULSE"
    elif [ "$reg_val" -eq "4" ]; then
      echo "Current State: ACTIVE PULSE"
    elif [ "$reg_val" -eq "5" ]; then
      echo "Current State: PULSE END"
    elif [ "$reg_val" -eq "6" ]; then
      echo "Current State: PMS"
    else
      echo "ERROR"
    fi
}
function save_input_to_file {
  cd $DATADIR
  printf "%% " > llrf_m_script.m
  printf "%s " $(date) >> llrf_m_script.m
  printf "\n" >> llrf_m_script.m
  #printf "addpath($LLRF_CL_PATH)" >> llrf_m_script.m
  # Struck sample_length
  reg_val=$($RD_CMD 0x12A | grep -m1 -Po 0x[0123456789abcdefABCDEF]{1\,8})
  reg_val=$(($reg_val+1))
  mem_size_inp_dec=$reg_val
  mem_size_inp=$(printf "%x\n" $reg_val)
  echo "  Mem size 0x$mem_size_inp in 256-bit blocks."
  reg_val=$($RD_CMD 0x11 | grep -m1 -Po 0x[0123456789abcdefABCDEF]{1\,8})
  reg_val=$(( ($reg_val ^ 1023 ) & 1023))
  printf "\n in_ch_enable=%d;\n" $reg_val >> llrf_m_script.m
  in_ch_enable=$(printf "0x%x\n" $reg_val)
  #Reading memory, asuming that ch_i is located at address i*mem_size
  for i in `seq 1 10`;
  do
    if [ "$(($in_ch_enable & 0x1))" -eq "1" ]; then
      printf "" > in_ch_data_$i.dat
      addr=$(($mem_size_inp_dec*($i-1)*32))
      base_addr=$(printf "%x\n" $addr)
      echo "  Writing in_ch_$i from base addr 0x$base_addr to file in_ch_data_$i.dat"
      binoffset_to_2c=$(($i<7))
      matlab_format=$((2-$binoffset_to_2c))
      $CRD_MEM $base_addr $mem_size_inp $matlab_format $binoffset_to_2c >> in_ch_data_$i.dat
    fi
    in_ch_enable=$(($in_ch_enable >> 1))
  done
  # PI settings
  reg_val=$($CRD_CMD $LLRF_PI_1_FIXED_SP | grep -Po \\s\\s\\-?[0123456789]*)
  printf "\n sp_I=%d;\n" $reg_val >> llrf_m_script.m
  reg_val=$($CRD_CMD $LLRF_PI_2_FIXED_SP | grep -Po \\s\\s\\-?[0123456789]*)
  printf "\n sp_Q=%d;\n" $reg_val >> llrf_m_script.m
  # IQ sampling settings
  # Near IQ
  reg_val=$($CRD_CMD $LLRF_NEAR_IQ_1_PARAM | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
  N=$((($reg_val & 0xFFFF0000)>>16))
  M=$((($reg_val & 0xFFFF)))
  printf "\n N=%d;\n" $N >> llrf_m_script.m
  printf "\n M=%d;\n" $M >> llrf_m_script.m
  # Use scaling
  reg_val=$($CRD_CMD $LLRF_IQ_CTRL | grep -Po -m7 0x[0123456789] | tail -n1)
  reg_val=$(($reg_val/1))
  printf "\n use_scaling=%d;\n" $reg_val >> llrf_m_script.m
  # Angle
  reg_val=$($CRD_CMD $LLRF_IQ_ANGLE | grep -Po -m1 \\\s-?[\\d]\\.[\\d]*)
#  echo "angle reg_val $reg_val"
  printf "\n angle_offset=%f;\n" $reg_val >> llrf_m_script.m
  # cavity delay
  reg_val=$($CRD_CMD $LLRF_IQ_CTRL | grep -Po -m1 0x[0123456789abcdefABCDEF]{8})
  delay_enable=$((($reg_val & 0x00000002)>>1))
  printf "\n cav_inp_delay_enable=%d;\n" $delay_enable >> llrf_m_script.m
  delay=$((($reg_val & 0x00003F80)>>7))
  printf "\n cav_inp_delay=%d;\n" $delay >> llrf_m_script.m
  # FILTER values
  reg_val=$($CRD_CMD $LLRF_FILTER_S | grep -Po [01]\\.[0123456789]{1\,8})
  printf "\n filter_s=%f;\n" $reg_val >> llrf_m_script.m
  reg_val=$($CRD_CMD $LLRF_FILTER_C | grep -Po [01]\\.[0123456789]{1\,8})
  printf "\n filter_c=%f;\n" $reg_val >> llrf_m_script.m
  reg_val=$($CRD_CMD $LLRF_FILTER_A_CTRL | grep -Po [01]\\.[0123456789]{1\,8})
  printf "\n filter_a=%f;\n" $reg_val >> llrf_m_script.m
  reg_val=$($CRD_CMD $LLRF_FILTER_A_CTRL | grep -Po Filter_start.*\\d)
  printf "\n %s%s%s;\n" $reg_val >> llrf_m_script.m
  reg_val=$($CRD_CMD $LLRF_FILTER_A_CTRL | grep -Po Filter_stop.*\\d)
  printf "\n %s%s%s;\n" $reg_val >> llrf_m_script.m
  reg_val=$($CRD_CMD $LLRF_FILTER_A_CTRL | grep -Po Filter_on.*\\d)
  printf "\n %s%s%s;\n" $reg_val >> llrf_m_script.m
  # CL memory region
  # PI_err_start_cnt
  reg_val=$($CRD_CMD $LLRF_PULSE_START_CNT | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
  reg_val=$(($reg_val/1))
  echo "PULSE START_CNT: $reg_val"
  printf "\n pulse_start_cnt=%d;\n" $reg_val >> llrf_m_script.m
  # PI_err_active_cnt
  reg_val=$($CRD_CMD $LLRF_PULSE_ACTIVE_CNT | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
  reg_val=$(($reg_val/1))
  echo "PULSE ACTIVE CNT: $reg_val"
  printf "\n pulse_active_cnt=%d;\n" $reg_val >> llrf_m_script.m
  # PI_err_samples
  reg_val=$($CRD_CMD $LLRF_PI_ERR_CNT | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
  reg_val=$(($reg_val/1))
  printf "\n pi_err_samples=%d;\n" $reg_val >> llrf_m_script.m
  echo "PI_ERROR COUNT: $reg_val"
  reg_val=$((($reg_val+7)/8))
  echo "PI_ERROR MEM SIZE: $reg_val"
  mem_size_outp=$(printf "0x%x\n" $reg_val)
  reg_val=$($CRD_CMD $LLRF_GIP | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
  mem_type=$((($reg_val & 0xE000)>>13))
  echo "  Writing custom logic stored data of type $mem_type to file stored_custom_data.dat"
  reg_val=$($CRD_CMD $LLRF_MEM_CTRL_4_PARAM | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
  base_addr=$(printf "0x%x\n" $reg_val)
  printf "\n mem_type=%d;\n" $mem_type >> llrf_m_script.m
  printf "" > stored_custom_data.dat
  $CRD_MEM $base_addr $mem_size_outp 1 >> stored_custom_data.dat
  printf "\n [in_ch,memory]=load_data(in_ch_enable);\n" >> llrf_m_script.m
  printf "\n show_data_near_iq(in_ch,memory,mem_type,sp_I,sp_Q,use_scaling,angle_offset,M,N,cav_inp_delay_enable,cav_inp_delay,pulse_start_cnt,pulse_active_cnt,pi_err_samples)\n" >> llrf_m_script.m
}
function matlab_plot {
  screen -S matlabSession1 -X stuff $'llrf_m_script\n'
}
function matlab_table {
  cmd=$(printf "make_table(%d,0);" $1)
#  echo $cmd
  screen -S matlabSession1 -X stuff $cmd
  screen -S matlabSession1 -X stuff $'\n'
}
function setup_mem_store {
  echo "Please enter signal to be stored in memory: "
  echo "   0: PI-error"
  echo "   1: CAV IQ"
  echo "   2: CAV MA"
  echo "   3: Ref IQ"
  echo "   4: Ref Ang and Cav Ang"
  echo "   5: MA-samples to PI-ctrl"
  echo "   6: VM MA-samples scaled"
  echo "   7: VM IQ-samples"
  read SIGNAL
  reg_val=$(echo "$SIGNAL*8192" | bc -l)
  reg_val=$(printf "%x\n" $reg_val)
  $CWR_CMD $LLRF_GIP_C E000
  $CWR_CMD $LLRF_GIP_S $reg_val
  $CS_CMD   2 > $DATADIR/tmp.txt
}
function setup_mem_pi_err {
  echo "Please enter PI-error base addr (Hex): "
  read PI_BASE
  $CWR_CMD $LLRF_MEM_CTRL_4_PARAM $PI_BASE  > $DATADIR/tmp.txt
  $CRD_CMD $LLRF_MEM_CTRL_4_PARAM $LLRF_PI_ERR_MEM_SIZE
  $CS_CMD   2 > $DATADIR/tmp.txt
}
function setup_lut {
  echo "Please enter USED SP size in nbr of MA points (Dec): "
  read SP_POINTS
  reg_val=$(printf "%x\n" $SP_POINTS)
  $CWR_CMD $LLRF_LUT_CTRL_2_PARAM   $reg_val  > $DATADIR/tmp.txt
  echo "Please enter USED FF size in nbr of MA points (Dec): "
  read FF_POINTS
  reg_val=$(printf "%x\n" $FF_POINTS)
  $CWR_CMD $LLRF_LUT_CTRL_1_PARAM   $reg_val  > $DATADIR/tmp.txt
}
function setup_mem_ff_sp {
  echo "Please enter SP base-address (Hex): "
  read SP_BASE
  echo "Please enter SP LUT size in 32-byte blocks (Hex): "
  read SP_SIZE
  echo "Please enter FF base-address (Hex): "
  read FF_BASE
  echo "Please enter FF LUT size in 32-byte blocks (Hex): "
  read FF_SIZE
  echo "Please enter Pulse-type nbr (Dec): "
  read PULSE_TYPE
  echo "Please enter USED SP size in nbr of MA points (Dec): "
  read SP_POINTS
  echo "Please enter USED FF size in nbr of MA points (Dec): "
  read FF_POINTS
  reg_val=$(echo "$PULSE_TYPE*65536" | bc -l)
  reg_val=$(printf "%x\n" $reg_val)
  $CWR_CMD $LLRF_GIP              $reg_val  > $DATADIR/tmp.txt
  reg_val=$(printf "%x\n" $SP_POINTS)
  $CWR_CMD $LLRF_LUT_CTRL_2_PARAM   $reg_val  > $DATADIR/tmp.txt
  reg_val=$(printf "%x\n" $FF_POINTS)
  $CWR_CMD $LLRF_LUT_CTRL_1_PARAM   $reg_val  > $DATADIR/tmp.txt
  $CWR_CMD $LLRF_MEM_CTRL_1_PARAM $FF_BASE  > $DATADIR/tmp.txt
  $CWR_CMD $LLRF_MEM_CTRL_2_PARAM $SP_BASE  > $DATADIR/tmp.txt
  reg_val=$(echo "$SP_SIZE*65536+$FF_SIZE" | bc -l)
  reg_val=$(printf "%x\n" $reg_val)
  $CWR_CMD $LLRF_MEM_CTRL_3_PARAM $reg_val  > $DATADIR/tmp.txt
  $CRD_CMD $LLRF_LUT_CTRL_1_PARAM $LLRF_MEM_CTRL_3_PARAM
  $CRD_CMD $LLRF_GIP $LLRF_GIP
}
function read_mem {
  echo "Please enter address in hex: "
  read input
  if [ $input ]; then
    MEM_ADDR=$input
  fi
  echo "Please enter size in blocks of 8 MA-points: "
  read input
  if [ $input ]; then
    MEM_SIZE=$input
  fi
  $CRD_MEM $MEM_ADDR $MEM_SIZE
  echo "Read 0x$MEM_SIZE * 8 MA-points from address 0x$MEM_ADDR"
}
function write_mem {
  echo "Please enter address in hex: "
  read input
  if [ $input ]; then
    MEM_ADDR=$input
  fi
  echo "Please enter size in blocks of 8 MA-points: "
  read input
  if [ $input ]; then
    MEM_SIZE=$input
  fi
  echo "Please enter Magnitude data type (0-All zeros, 1-All ones, 2-Incr, 3-Decl, 4-Max, 5-Min ): "
  read input
  if [ $input ]; then
    DT_MAG=$input
  fi
  echo "Please enter Angle part data type (0-All zeros, 1-All ones, 2-Incr, 3-Decl, 4-Max, 5-Min ): "
  read input
  if [ $input ]; then
    DT_ANG=$input
  fi
  echo "Write 0x$MEM_SIZE * 8 MA-points to address 0x$MEM_ADDR with DT_Mag = $DT_MAG and DT_Ang = $DT_ANG"
  echo "Correct? Yes or no."
  read answer
  case $answer in
      [Yy]* ) $CWR_MEM $MEM_ADDR $MEM_SIZE $DT_MAG $DT_ANG;;
      [Nn]* ) echo "No memory write was performed.";;
  esac
}
function toggle_bit {
  reg_val=$($CRD_CMD $1 | grep -Po 0x[0123456789abcdefABCDEF]{8})
  reg_val=$(($reg_val ^ $2))
  reg_val=$(printf "%x\n" $reg_val)
  $CWR_CMD  $1 $reg_val
  $CS_CMD   2 > $DATADIR/tmp.txt
  $CS_CMD   A > $DATADIR/tmp.txt
}
function dec_ff_tbl_speed {
  reg_val=$($CRD_CMD $1 | grep -Po 0x[0123456789abcdefABCDEF]{8})
  reg_val=$((($reg_val + 64) & 0x000003FF))
  reg_val=$(printf "%x\n" $reg_val)
  $CWR_CMD  $1 $reg_val
  $CS_CMD   2 > $DATADIR/tmp.txt
}
function set_bits {
  reg_val=$($CRD_CMD $1 | grep -Po 0x[0123456789abcdefABCDEF]{8})
  reg_val=$(($reg_val & $2))
  reg_val=$(($reg_val | $3))
  reg_val=$(printf "%x\n" $reg_val)
  $CWR_CMD  $1 $reg_val
  $CS_CMD   2 > $DATADIR/tmp.txt
  $CS_CMD   A > $DATADIR/tmp.txt
}
function set_bits_no_commit {
  reg_val=$($CRD_CMD $1 | grep -Po 0x[0123456789abcdefABCDEF]{8})
  reg_val=$(($reg_val | $2))
  reg_val=$(printf "%x\n" $reg_val)
  $WR_CMD $1 -w $reg_val
}
function set_value_no_commit {
  echo "Please enter decimal input for $3: "
  read reg_val
#  printf "0x%x\n" $reg_val
#  echo $reg_val
  if [ $reg_val ]; then
    reg_val=$(echo "$reg_val*$2" | bc -l)
    reg_val=$(echo "$reg_val/1" | bc)
    reg_val=$(echo "if ($reg_val < 0) {$reg_val+4294967296} else {$reg_val}" | bc)
    reg_val=$(printf "%x\n" $reg_val)
    $CWR_CMD  $1 $reg_val
  fi
}
function set_value_commit {
  echo "Please enter decimal input for $3: "
  read reg_val
  if [ $reg_val ]; then
    reg_val=$(echo "$reg_val*$2" | bc -l)
    reg_val=$(echo "$reg_val/1" | bc)
    reg_val=$(echo "if ($reg_val < 0) {$reg_val+4294967296} else {$reg_val}" | bc)
    reg_val=$(printf "%x\n" $reg_val)
    $CWR_CMD  $1 $reg_val
    $CS_CMD   2 > $DATADIR/tmp.txt
    $CS_CMD   A > $DATADIR/tmp.txt
  fi
}
function setup_dc {
  echo "Please enter decimal input for Cavity DC-offset (0.99 to -1.0): "
  read reg_val1
  echo "Please enter decimal input for Cavity DC-offset (0.99 to -1.0): "
  read reg_val2
  reg_val1=$(echo "$reg_val1*32768" | bc )
  reg_val1=$(echo "if ($reg_val1 < 0) {$reg_val1+65536} else {$reg_val1}" | bc)
  reg_val1=$(echo "$reg_val1/1" | bc)
  reg_val2=$(echo "$reg_val2*32768" | bc)
  reg_val2=$(echo "if ($reg_val2 < 0) {$reg_val2+65536} else {$reg_val2}" | bc)
  reg_val2=$(echo "$reg_val2/1" | bc)
  reg_val=$(printf "0x%04x%04x\n" $reg_val1 $reg_val2)
  $CWR_CMD  $LLRF_IQ_DC_OFFSET $reg_val
  $CS_CMD   2 > $DATADIR/tmp.txt
#  $CS_CMD   A > $DATADIR/tmp.txt
}
function setup_niq {
  echo "Please enter value for M: "
  read reg_val1
  echo "Please enter value for N: "
  read reg_val2
  $CNIQ_CMD $reg_val1 $reg_val2 1 1
}
function setup_cav_inp_delay {
  echo "Please enter value for delay (N): "
  echo "   (Total delay will be N+3) "
  read reg_val
  reg_val=$(echo "$reg_val*128" | bc )
  set_bits $LLRF_IQ_CTRL 0xFFFFE07F $reg_val 
}
function copy_reg {
  reg_val=$($CRD_CMD $1 | grep -Po 0x[0123456789abcdefABCDEF]{8})
  reg_val=$(printf "%x\n" $reg_val)
  $CWR_CMD  $2 $reg_val
}

