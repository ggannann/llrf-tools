#!/bin/bash
. LLRF_test_func_const.sh

####################################
# MAIN PROGRAM
####################################
screen -S matlabSession1 -X stuff $'matlab -nodesktop -nosplash\n'
echo "####################################################"
echo "How to use the test script:"
echo " - Choose one of the numbered options by"
echo "   pressing that number followed by return."
echo " - List options again by only pressing return."
echo " - Pressing 1 followed by return in a submeny will bring you back one level."
echo " - Normal operation, do:"
echo "     1. SETUP - and follow the instructions"
echo "     2. RUN   - and follow the instructions"
echo "####################################################"
select opt in $OPTIONS; do
  if [ "$opt" = "Quit" ]; then
    echo "Thank you for this time! I hope to see you again soon!"
    screen -S matlabSession1 -X stuff $'exit\n'
    screen -S matlabSession1 -X stuff $'screen -X -S matlabSession1 quit\n'
    exit
  elif [ "$opt" = "SW_reset" ]; then
    $CS_CMD $DEV_SIS B
    $CRD_CMD $DEV_SIS 
    $CRD_CMD $DEV_SIS $LLRF_GOP
    echo "SW reseted, all registers should have default values."
  elif [ "$opt" = "SANITY_TESTS" ]; then
    echo "####################################################"
    echo "Available tests:"
    echo "  REG_TEST     : basic sanity check of register interface"
    echo "  MEM_SIZE_TEST: Test that you have access to 2GB of memory"
    echo "                 (Takes a long time)"
    echo "####################################################"
    select opt in $OPTIONS_TEST; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "REG_TEST" ]; then
        $CRT_CMD $DEV_SIS
      elif [ "$opt" = "MEM_SIZE_TEST" ]; then
        $CMT_CMD $DEV_SIS
      elif [ "$opt" = "SP_TABLE_TEST" ]; then
        test_sp_tables
      elif [ "$opt" = "FF_TABLE_TEST" ]; then
        test_ff_tables
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "SETUP" ]; then
    echo "####################################################"
    echo "To initialize card run:"
    echo "  1. SETUP_CARD"
    echo "  2. SETUP_CUSTOM_LOGIC:"
    echo "   - PI_CTRL or"
    echo "   - SELF_EXCITING_MODE"
    echo "####################################################"
    select opt in $OPTIONS_SETUP; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "SETUP_CARD" ]; then
        nsamples=0x60000
        ch_mask=0x3FF
        $CINIT_CMD $DEV_SIS $nsamples $ch_mask
        for i in `seq 1 10`;
        do
          if [ "$(($ch_mask & 0x1))" -eq "1" ]; then
            echo "Channel $i enabled"
          fi
          ch_mask=$(($ch_mask >> 1))
	done
        # Adjust ADC input tap delay on ADC 1/2
        $WR_CMD $DEV_SIS 0x49 0x106
      elif [ "$opt" = "SETUP_CARD_352_RTM" ]; then
        nsamples=0x60000
        ch_mask=0x3FF
        $CINIT_CMD $DEV_SIS $nsamples $ch_mask
        for i in `seq 1 10`;
        do
            if [ "$(($ch_mask & 0x1))" -eq "1" ]; then
		echo "Channel $i enabled"
            fi
            ch_mask=$(($ch_mask >> 1))
	done
	#Enable RTM RF output
        $WR_CMD $DEV_SIS 0x12F 0x700
	#Set attenuations on RTM
	cd /home/eit_ess/development/RTM_sw/tests/rtm_i2c_test_DS8VM1_switched_clk_data
        # Attenuation cav in 0.0 dBm
	$WR_RTM_ATT_CMD $DEV_NBR 0 63
        # Attenuation ref in 0 dBm
	$WR_RTM_ATT_CMD $DEV_NBR 1 63
        # Attenuation VM out 0 dBm
	$WR_RTM_ATT_CMD $DEV_NBR 8 63
	cd $LLRF_CUSTOM_LOGIC_PATH
        # Adjust ADC input tap delay on ADC 1/2
        $WR_CMD $DEV_SIS 0x49 0x106
      elif [ "$opt" = "SETUP_CARD_704_RTM" ]; then
        nsamples=0x60000
        ch_mask=0x3FF
        $CINIT_CMD $DEV_SIS $nsamples $ch_mask
        for i in `seq 1 10`;
        do
            if [ "$(($ch_mask & 0x1))" -eq "1" ]; then
		echo "Channel $i enabled"
            fi
            ch_mask=$(($ch_mask >> 1))
	done
	#Enable RTM RF output
        $WR_CMD $DEV_SIS 0x12F 0x700
	#Set attenuations on RTM
	cd /home/eit_ess/development/RTM_sw/tests/rtm_i2c_test
        # Attenuation cav in 0 dBm
	$WR_RTM_ATT_CMD $DEV_NBR 0 45
        # Attenuation ref in 0 dBm
	$WR_RTM_ATT_CMD $DEV_NBR 1 63
        # Attenuation VM out 0 dBm
	$WR_RTM_ATT_CMD $DEV_NBR 8 63
        # Common mode voltage VM 1.7 V
	$WR_RTM_ATT_CMD $DEV_NBR 9 0
	cd $LLRF_CUSTOM_LOGIC_PATH
        # Adjust ADC input tap delay on ADC 1/2
        $WR_CMD $DEV_SIS 0x49 0x106
      elif [ "$opt" = "SETUP_CUSTOM_LOGIC_PI_CTRL_IQ_352_MHZ" ]; then
        ##################################################
        $WR_CMD  $DEV_SIS 0x45 0x33
        echo "DAC OUTPUT: custom logic" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_PI_1_K 0x00333333
        $CWR_CMD $DEV_SIS $LLRF_PI_1_TS_DIV_TI 0x00028F5C
        $CWR_CMD $DEV_SIS $LLRF_PI_1_SAT_MAX 0x0000FFFF
        $CWR_CMD $DEV_SIS $LLRF_PI_1_SAT_MIN 0xFFFF0000
        $CWR_CMD $DEV_SIS $LLRF_PI_1_CTRL 0x03C3 
        $CWR_CMD $DEV_SIS $LLRF_PI_1_FIXED_SP 0x00005999
        $CWR_CMD $DEV_SIS $LLRF_PI_1_FIXED_FF 0x00000000
        echo "PI I: k=0.1, Ti=0.005, Sat_Max=0.99999, Sat_Min=-1, SP=16384 (0.75), FF=0, FF_TBL_SPEED = PI_SMPL_SPEED" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_PI_2_K 0x00333333 
        $CWR_CMD $DEV_SIS $LLRF_PI_2_TS_DIV_TI 0x00028F5C
        $CWR_CMD $DEV_SIS $LLRF_PI_2_SAT_MAX 0x0000FFFF
        $CWR_CMD $DEV_SIS $LLRF_PI_2_SAT_MIN 0xFFFF0000
        $CWR_CMD $DEV_SIS $LLRF_PI_2_CTRL 0x03 
        $CWR_CMD $DEV_SIS $LLRF_PI_2_FIXED_SP 0x00005999
        $CWR_CMD $DEV_SIS $LLRF_PI_2_FIXED_FF 0x00000000
        echo "PI Q: k=0.1, Ti=0.005, Sat_Max=0.99999, Sat_Min=-1, SP=0 (0.0), FF=0" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_IQ_ANGLE 0xFFFDE7CD
        $CWR_CMD $DEV_SIS $LLRF_IQ_CTRL 0x00000703
        echo "IQ_SAMPLING : IQ_ANGLE = -120 deg, Cav input delay enabled, delay 14+3" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_FILTER_S 0x0134D397
        $CWR_CMD $DEV_SIS $LLRF_FILTER_C 0x7FFE8B6F
        $CWR_CMD $DEV_SIS $LLRF_FILTER_A_CTRL 0x33330024
        echo "MOD_RIP_FILTER : S = 0.009425, C = 0.999956, A = 0.199997, START = PULSE_START, STOP = PULSE_END, ACTIVE = 00 " 
        ##################################################
	$CNIQ_CMD $DEV_SIS 4 11 1 1
        echo "NEAR-IQ SAMPLING : M = 4, N = 11" 
        ##################################################
        SP_size=0x0200
        SP_base_addr=0x7FF38000
        FF_size=0x2000
        FF_base_addr=0x7FF40000
        $CWR_CMD $DEV_SIS $LLRF_GIP              0x00000000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_1_PARAM 0x00020000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_2_PARAM 0x00001000 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_1_PARAM $FF_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_2_PARAM $SP_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_3_PARAM $(printf "0x%04x%04x\n" $SP_size $FF_size)
        echo "PULSE_TYPE = 0, NBR_FF = 32768, NBR_SP = 1024, FF_BASE_ADDR = 0x7DF60000, FF_SIZE = 4096, SP_BASE_ADDR = 0x7DE5C000, SP_SIZE = 512"
        $CWR_MEM $DEV_SIS $FF_base_addr $FF_size 8 0 
        $CWR_MEM $DEV_SIS $SP_base_addr $SP_size 9 1 
        $CWR_MEM $DEV_SIS $FF_base_addr 0x1 0 0 
        $CWR_MEM $DEV_SIS $SP_base_addr 0x1 0 0 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_4_PARAM 0x7FFC0000
        echo "PI_ERR_BASE_ADDR = 0x7FFE0000"
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_VM_CTRL 0x07 
        $CWR_CMD $DEV_SIS $LLRF_VM_MAG_LIMIT 0x0000FF00 
        echo "VM_CTRL: I and Q Output inversed, to compensate for struck DAC invertion"
        echo "VM_CTRL: Magnitude limit: ON, Mag_limit = 0x0000FF00 (0.996)"
        ##################################################
        $CS_CMD $DEV_SIS 1
        $CRD_CMD $DEV_SIS 
        $CRD_CMD $DEV_SIS $LLRF_GOP
        ##################################################
        echo "####################################################"
        echo "LLRF is setup as:"
        echo "####################################################"
        echo "DAC OUTPUT       : custom logic" 
        echo "IQ_SAMPLING      : IQ_ANGLE = -120 deg, Cav input delay enabled, delay 14+3" 
        echo "NEAR-IQ SAMPLING : M = 4, N = 11" 
        echo "PI I             : k=0.1, Ti=0.005, Sat_Max=0.99999, Sat_Min=-1, SP=16384 (0.75), FF=0, FF_TBL_SPEED = PI_SMPL_SPEED" 
        echo "PI Q             : k=0.1, Ti=0.005, Sat_Max=0.99999, Sat_Min=-1, SP=0     (0.0), FF=0" 
        echo "PULSE_TYPE = 0, NBR_FF = 32768, NBR_SP = 1024, FF_BASE_ADDR = 0x7DF60000, FF_SIZE = 4096, SP_BASE_ADDR = 0x7DE5C000, SP_SIZE = 512"
        echo "PI_ERR           : PI_ERR_BASE_ADDR = 0x0C000000"
        echo "VM_CTRL          : Scaling off, Mag limiter on (0.996), Output inversed(to compensate for struck DAC invertion)"
        echo "####################################################"
        echo "SETUP DONE"
        echo "####################################################"
      elif [ "$opt" = "SETUP_CUSTOM_LOGIC_PI_CTRL_IQ_704_MHZ" ]; then
        ##################################################
        $WR_CMD  $DEV_SIS 0x45 0x33
        echo "DAC OUTPUT: custom logic" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_PI_1_K 0x00199999 
        $CWR_CMD $DEV_SIS $LLRF_PI_1_TS_DIV_TI 0x00014700
        $CWR_CMD $DEV_SIS $LLRF_PI_1_SAT_MAX 0x0000FFFF
        $CWR_CMD $DEV_SIS $LLRF_PI_1_SAT_MIN 0xFFFF0000
        $CWR_CMD $DEV_SIS $LLRF_PI_1_CTRL 0x03C3 
        $CWR_CMD $DEV_SIS $LLRF_PI_1_FIXED_SP 0x00006000
        $CWR_CMD $DEV_SIS $LLRF_PI_1_FIXED_FF 0x00000000
        echo "PI I: k=0.1, Ti=0.005, Sat_Max=0.99999, Sat_Min=-1, SP=16384 (0.75), FF=0, FF_TBL_SPEED = PI_SMPL_SPEED" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_PI_2_K 0x00199999 
        $CWR_CMD $DEV_SIS $LLRF_PI_2_TS_DIV_TI 0x00014700
        $CWR_CMD $DEV_SIS $LLRF_PI_2_SAT_MAX 0x0000FFFF
        $CWR_CMD $DEV_SIS $LLRF_PI_2_SAT_MIN 0xFFFF0000
        $CWR_CMD $DEV_SIS $LLRF_PI_2_CTRL 0x03 
        $CWR_CMD $DEV_SIS $LLRF_PI_2_FIXED_SP 0x00000000
        $CWR_CMD $DEV_SIS $LLRF_PI_2_FIXED_FF 0x00000000
        echo "PI Q: k=0.1, Ti=0.005, Sat_Max=0.99999, Sat_Min=-1, SP=0 (0.0), FF=0" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_IQ_ANGLE 0xFFFDE7CD
        $CWR_CMD $DEV_SIS $LLRF_IQ_CTRL 0x00000703
        echo "IQ_SAMPLING : IQ_ANGLE = -120 deg, Cav input delay enabled, delay 14+3" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_FILTER_S 0x0134D397
        $CWR_CMD $DEV_SIS $LLRF_FILTER_C 0x7FFE8B6F
        $CWR_CMD $DEV_SIS $LLRF_FILTER_A_CTRL 0x33330024
        echo "MOD_RIP_FILTER : S = 0.009425, C = 0.999956, A = 0.199997, START = PULSE_START, STOP = PULSE_END, ACTIVE = 00 " 
        ##################################################
	$CNIQ_CMD $DEV_SIS 4 11 1 1
        echo "NEAR-IQ SAMPLING : M = 4, N = 11" 
        ##################################################
        SP_size=0x0200
        SP_base_addr=0x7FF38000
        FF_size=0x2000
        FF_base_addr=0x7FF40000
        $CWR_CMD $DEV_SIS $LLRF_GIP              0x00000000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_1_PARAM 0x00020000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_2_PARAM 0x00001000 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_1_PARAM $FF_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_2_PARAM $SP_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_3_PARAM $(printf "0x%04x%04x\n" $SP_size $FF_size)
        echo "PULSE_TYPE = 0, NBR_FF = 32768, NBR_SP = 1024, FF_BASE_ADDR = 0x7DF60000, FF_SIZE = 4096, SP_BASE_ADDR = 0x7DE5C000, SP_SIZE = 512"
        $CWR_MEM $DEV_SIS $FF_base_addr $FF_size 8 0 
        $CWR_MEM $DEV_SIS $SP_base_addr $SP_size 9 1 
        $CWR_MEM $DEV_SIS $FF_base_addr 0x1 0 0 
        $CWR_MEM $DEV_SIS $SP_base_addr 0x1 0 0 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_4_PARAM 0x7FFC0000
        echo "PI_ERR_BASE_ADDR = 0x7FFE0000"
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_VM_CTRL 0x07 
        $CWR_CMD $DEV_SIS $LLRF_VM_MAG_LIMIT 0x0000FF00 
        echo "VM_CTRL: I and Q Output inversed, to compensate for struck DAC invertion"
        echo "VM_CTRL: Magnitude limit: ON, Mag_limit = 0x0000FF00 (0.996)"
        ##################################################
        $CS_CMD $DEV_SIS 1
        $CRD_CMD $DEV_SIS 
        $CRD_CMD $DEV_SIS $LLRF_GOP
        ##################################################
        echo "####################################################"
        echo "LLRF is setup as:"
        echo "####################################################"
        echo "DAC OUTPUT       : custom logic" 
        echo "IQ_SAMPLING      : IQ_ANGLE = -0.3 deg, Cav input delay enabled, delay 14+3" 
        echo "NEAR-IQ SAMPLING : M = 4, N = 11" 
        echo "PI I: k=0.1, Ti=0.005, Sat_Max=0.99999, Sat_Min=-1, SP=16384 (0.75), FF=0, FF_TBL_SPEED = PI_SMPL_SPEED" 
        echo "PI Q: k=0.1, Ti=0.005, Sat_Max=0.99999, Sat_Min=-1, SP=0     (0.0), FF=0" 
        echo "PULSE_TYPE = 0, NBR_FF = 32768, NBR_SP = 1024, FF_BASE_ADDR = 0x7DF60000, FF_SIZE = 4096, SP_BASE_ADDR = 0x7DE5C000, SP_SIZE = 512"
        echo "PI_ERR           : PI_ERR_BASE_ADDR = 0x0C000000"
        echo "VM_CTRL          : Scaling off, Mag limiter on (0.996), Output inversed(to compensate for struck DAC invertion)"
        echo "####################################################"
        echo "SETUP DONE"
        echo "####################################################"
      elif [ "$opt" = "SETUP_CUSTOM_LOGIC_SELF_EXCITING_MODE" ]; then
        ##################################################
        $WR_CMD  $DEV_SIS 0x45 0x33
        echo "DAC OUTPUT: custom logic" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_PI_1_CTRL 0x0004 
        echo "PI Magnitude: Bypassed, output is input" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_PI_2_CTRL 0x00004 
        echo "PI Angle: Bypassed, input is output" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_IQ_MAG_FACT 0x00010000
        $CWR_CMD $DEV_SIS $LLRF_IQ_ANGLE 0x0000751F
        $CWR_CMD $DEV_SIS $LLRF_IQ_CTRL 0x0021
        echo "IQ_SAMPLING : IQ_MAG_FACT = 1, IQ_ANGLE = 26.2 deg" 
        echo "IQ_SAMPLING : Phase rotation on, ref phase zero" 
        ##################################################
	$CNIQ_CMD $DEV_SIS 4 11 1 1
        echo "NEAR-IQ SAMPLING : M = 4, N = 11" 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_GIP              0x00000000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_1_PARAM 0x00000800 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_2_PARAM 0x00000400 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_1_PARAM 0x00080000 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_2_PARAM 0x00010000 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_3_PARAM 0x01000100 
        echo "PULSE_TYPE = 0, NBR_FF = 2048, NBR_SP = 1024, FF_BASE_ADDR = 0x00080000, FF_SIZE = 2048, SP_BASE_ADDR = 0x00010000, SP_SIZE = 2048"
        $CWR_MEM $DEV_SIS 0x00080000 0x100 2 2 
        $CWR_MEM $DEV_SIS 0x00010000 0x100 2 2 
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_4_PARAM 0x0C000000 
        echo "PI_ERR_BASE_ADDR = 0x0C00000"
        ##################################################
        $CWR_CMD $DEV_SIS $LLRF_VM_CTRL 0x17 
        $CWR_CMD $DEV_SIS $LLRF_VM_MAG_LIMIT 0x00008000 
        echo "VM_CTRL: I and Q Output inversed, to compensate for struck DAC invertion"
        echo "VM_CTRL: Magnitude limit: ON, Mag_limit = 0x00008000 (0.5), force mag limit"
        ##################################################
        $CS_CMD $DEV_SIS 1
        $CRD_CMD $DEV_SIS 
        $CRD_CMD $DEV_SIS $LLRF_GOP
	set_bits_no_commit $STRUCK_ADC_SAMPLE_CTRL 0x800  > tmp.txt
        $WR_CMD  $DEV_SIS 0x10 0x2  > tmp.txt
        $CS_CMD   $DEV_SIS 6 > tmp.txt
        print_state
        ##################################################
        echo "####################################################"
        echo "Self-Excited Loop (SEL) is setup as:"
        echo "####################################################"
        echo "DAC OUTPUT       : custom logic" 
        echo "IQ_SAMPLING      : IQ_MAG_FACT = 1, IQ_ANGLE = 0 (0 deg)" 
        echo "IQ_SAMPLING      : Phase rotation on, Force ref to zero" 
        echo "NEAR-IQ SAMPLING : M = 4, N = 11" 
        echo "PI Magnitude     : Bypassed, input is output" 
        echo "PI Angle         : Bypassed, input is output" 
        echo "FF tables        : PULSE_TYPE = 0, NBR_FF = 2048, FF_BASE_ADDR = 0x00080000, FF_SIZE = 2048"
        echo "SP tables        : PULSE_TYPE = 0, NBR_SP = 1024, SP_BASE_ADDR = 0x00010000, SP_SIZE = 2048"
        echo "PI_ERR           : PI_ERR_BASE_ADDR = 0x0C000000"
        echo "VM_CTRL          : Scaling off, force mag limit, Mag limiter on (0.5), Output inversed(to compensate for struck DAC invertion)"
        echo ""
        echo "####################################################"
        echo "SETUP DONE"
        echo "  Loop should be running now:"
        echo "  - Please adjust angle offset until loop is stable:"
        echo "####################################################"
        echo ""
        angle_offset_adjust
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "RUN" ]; then
    echo "#######################################################################"
    echo "Will loop the FSM through:"
    echo "  IDLE -> ACTIVE NO-PULSE -> ACTIVE PULSE -> PULSE END -> IDLE"
    echo " - Semi automatic requires a press of return between each state change."
    echo " - Automatic will run a configurable nbr of iterations."
    echo "#######################################################################"
    select opt in $OPTIONS_RUN; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "RUN_SEMI_AUTOMATIC" ]; then
	print_state
        run_semi 
      elif [ "$opt" = "RUN_AUTOMATIC" ]; then
	print_state
        run_auto 0
      elif [ "$opt" = "RUN_AUTO_ROTATE" ]; then
	print_state
        run_auto 1
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "DAC" ]; then
    ################################
    # DAC
    ################################
    select opt in $OPTIONS_DAC; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "MAX_MIN" ]; then
        $WR_CMD  $DEV_SIS 0x46 0x0000FFFF
        $WR_CMD  $DEV_SIS 0x45 0x30
        echo "DAC OUTPUT: max and min values" 
      elif [ "$opt" = "SAW" ]; then
        $WR_CMD  $DEV_SIS 0x45 0x31
        echo "DAC OUTPUT: Saw curve" 
      elif [ "$opt" = "INPUT_CH1_CH2" ]; then
        $WR_CMD  $DEV_SIS 0x45 0x32
        echo "DAC OUTPUT : Input from ch1 and ch2" 
      elif [ "$opt" = "CUSTOM" ]; then
        $WR_CMD  $DEV_SIS 0x45 0x33
        echo "DAC OUTPUT: Custom logic output" 
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "IQ_SAMPLING" ]; then
    ################################
    # IQ_SAMPLING
    ################################
    select opt in $OPTIONS_IQ; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "SET_IQ_OUTPUT_ZERO" ]; then
        set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0x1C
      elif [ "$opt" = "SET_IQ_OUTPUT_NORM" ]; then
        set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0x0
      elif [ "$opt" = "TOGGLE_FREQ_OFFSET_MODE" ]; then
        toggle_bit $LLRF_IQ_CTRL 0x40
      elif [ "$opt" = "TOGGLE_PHASE_REF_ZERO" ]; then
        toggle_bit $LLRF_IQ_CTRL 0x20
      elif [ "$opt" = "TOGGLE_USE_ADDITIONAL_ROTATION" ]; then
        toggle_bit $LLRF_IQ_CTRL 0x1
      elif [ "$opt" = "TOGGLE_CAVITY_INPUT_DELAY_ENABLE" ]; then
        toggle_bit $LLRF_IQ_CTRL 0x2
      elif [ "$opt" = "SETUP_ADDITIONAL_ROT_ANG" ]; then
        echo "ANGLE is in the range -pi to pi"
        set_value_no_commit $LLRF_IQ_ANGLE 65536 IQ_ANGLE
      elif [ "$opt" = "ADJUST_ANGLE" ]; then
        angle_offset_adjust
      elif [ "$opt" = "SET_NEAR_IQ" ]; then
        setup_niq
      elif [ "$opt" = "SET_CAVITY_INPUT_DELAY" ]; then
        setup_cav_inp_delay
      elif [ "$opt" = "COMMIT_CHANGES" ]; then
        $CS_CMD   $DEV_SIS 2 > tmp.txt
        echo "New register values available to custom logic but not taken into use"
      elif [ "$opt" = "COMMIT_CHANGES_IMMEDIATE_USE" ]; then
        $CS_CMD   $DEV_SIS 2 > tmp.txt
        $CS_CMD   $DEV_SIS A > tmp.txt
        echo "New register values taken into use"
      elif [ "$opt" = "CURRENT_SETTINGS" ]; then
        $CRD_CMD $DEV_SIS $LLRF_IQ_CTRL $LLRF_IQ_ANGLE
  	reg_val=$($CRD_CMD $DEV_SIS $LLRF_NEAR_IQ_1_PARAM | grep -m1 -Po 0x[0123456789abcdefABCDEF]{8})
  	N=$((($reg_val & 0xFFFF0000)>>16))
  	M=$((($reg_val & 0xFFFF)))
	$CNIQ_CMD $DEV_SIS $M $N 0 1
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "MOD_FILTER" ]; then
    ################################
    # MOD_RIPPLE_FILTER
    ################################
    select opt in $OPTIONS_FILTER; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "SET_PI_OUTPUT_TO_INPUT" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x04
      elif [ "$opt" = "SET_PI_OUTPUT_TO_NORM" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x0
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x0
      elif [ "$opt" = "TOGGLE_FREQ_OFFSET_MODE" ]; then
        toggle_bit $LLRF_IQ_CTRL 0x40
      elif [ "$opt" = "TOGGLE_PHASE_REF_ZERO" ]; then
        toggle_bit $LLRF_IQ_CTRL 0x20
      elif [ "$opt" = "TOGGLE_PHASE_COMP" ]; then
        toggle_bit $LLRF_IQ_CTRL 0x2
      elif [ "$opt" = "TOGGLE_USE_ADDITIONAL_ROTATION" ]; then
        toggle_bit $LLRF_IQ_CTRL 0x1
      elif [ "$opt" = "ADJUST_ANGLE" ]; then
        angle_offset_adjust
      elif [ "$opt" = "SETUP_S" ]; then
        echo "S is in the range -1 to 0.9999"
	set_value_no_commit $LLRF_FILTER_S 2147483648 FILTER_S
      elif [ "$opt" = "SETUP_C" ]; then
        echo "C is in the range -1 to 0.9999"
	set_value_no_commit $LLRF_FILTER_C 2147483648 FILTER_C
      elif [ "$opt" = "SETUP_A" ]; then
        echo "A is in the range 0 to 0.999"
	read reg_val
	reg_val=$(echo "$reg_val*65536" | bc -l)
    	reg_val=$(echo "$reg_val/1" | bc)
	reg_val=$(echo "$reg_val*65536" | bc -l)
        set_bits $LLRF_FILTER_A_CTRL 0x0000FFFF $reg_val
      elif [ "$opt" = "TOGGLE_START" ]; then
        toggle_bit $LLRF_FILTER_A_CTRL 0x4
      elif [ "$opt" = "TOGGLE_STOP" ]; then
        toggle_bit $LLRF_FILTER_A_CTRL 0x8
      elif [ "$opt" = "TOGGLE_FILTER_I_ON" ]; then
        toggle_bit $LLRF_FILTER_A_CTRL 0x1
      elif [ "$opt" = "TOGGLE_FILTER_Q_ON" ]; then
        toggle_bit $LLRF_FILTER_A_CTRL 0x2
      elif [ "$opt" = "COMMIT_CHANGES" ]; then
        $CS_CMD   $DEV_SIS 2 > tmp.txt
        echo "New register values available to custom logic but not taken into use"
      elif [ "$opt" = "COMMIT_CHANGES_IMMEDIATE_USE" ]; then
        $CS_CMD   $DEV_SIS 2 > tmp.txt
        $CS_CMD   $DEV_SIS A > tmp.txt
        echo "New register values taken into use"
      elif [ "$opt" = "CURRENT_SETTINGS" ]; then
        $CRD_CMD $DEV_SIS $LLRF_IQ_CTRL
        $CRD_CMD $DEV_SIS $LLRF_PI_1_CTRL
        $CRD_CMD $DEV_SIS $LLRF_PI_2_CTRL
        $CRD_CMD $DEV_SIS $LLRF_FILTER_S $LLRF_FILTER_A_CTRL 
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "VM_CTRL" ]; then
    ################################
    # VM_CTRL
    ################################
    select opt in $OPTIONS_VM; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "TOGGLE_FORCE_ANGLE" ]; then
        toggle_bit $LLRF_VM_CTRL 0x20
      elif [ "$opt" = "TOGGLE_FORCE_MAG" ]; then
        toggle_bit $LLRF_VM_CTRL 0x10
      elif [ "$opt" = "TOGGLE_SWAP_IQ" ]; then
        toggle_bit $LLRF_VM_CTRL 0x8
      elif [ "$opt" = "TOGGLE_USE_MAG_LIMIT" ]; then
        toggle_bit $LLRF_VM_CTRL 0x4
      elif [ "$opt" = "TOGGLE_INVERSE_OUTPUT_I_part" ]; then
        toggle_bit $LLRF_VM_CTRL 0x2
      elif [ "$opt" = "TOGGLE_INVERSE_OUTPUT_Q_part" ]; then
        toggle_bit $LLRF_VM_CTRL 0x1
      elif [ "$opt" = "SETUP_MAG_LIMIT" ]; then
        set_value_no_commit $LLRF_VM_MAG_LIMIT 65536 IQ_MAG_LIMIT
      elif [ "$opt" = "COMMIT_CHANGES" ]; then
        $CS_CMD   $DEV_SIS 2 > tmp.txt
        echo "New register values available to custom logic but not taken into use"
      elif [ "$opt" = "COMMIT_CHANGES_IMMEDIATE_USE" ]; then
        $CS_CMD   $DEV_SIS 2 > tmp.txt
        $CS_CMD   $DEV_SIS A > tmp.txt
        echo "New register values taken into use"
      elif [ "$opt" = "CURRENT_SETTINGS" ]; then
        $CRD_CMD $DEV_SIS $LLRF_VM_CTRL $LLRF_VM_MAG_LIMIT
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "PI_CTRL" ]; then
    ################################
    # PI_CTRL
    ################################
    select opt in $OPTIONS_PI; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "DECREASE_FF_TBL_SPEED" ]; then
        dec_ff_tbl_speed $LLRF_PI_1_CTRL
      elif [ "$opt" = "USE_CIRCULAR_FF" ]; then
        toggle_bit $LLRF_LUT_CTRL_1_PARAM 0x80000
      elif [ "$opt" = "TOGGLE_FF_SOURCE" ]; then
        toggle_bit $LLRF_PI_1_CTRL 0x2
        toggle_bit $LLRF_PI_2_CTRL 0x2
      elif [ "$opt" = "TOGGLE_SP_SOURCE" ]; then
        toggle_bit $LLRF_PI_1_CTRL 0x1
        toggle_bit $LLRF_PI_2_CTRL 0x1
      elif [ "$opt" = "SETUP_PI" ]; then
      ################################
      # PI_CTRL_SETUP
      ################################
      select opt in $OPTIONS_PI_SETUP; do
        if [ "$opt" = "BACK" ]; then
	  break
        elif [ "$opt" = "SETUP_PI_1" ]; then
          echo "K and TS_DIV_TI are in the range -256 to 255.9999"
          echo "SAT_MAX, SAT_MIN and SET_POINT are in the range 0.000 to 0.9999"
          echo "FIXED_FF is in the range -1.000 to 0.9999"
          set_value_no_commit $LLRF_PI_1_K 16777216 K
          set_value_no_commit $LLRF_PI_1_TS_DIV_TI 16777216 TS_DIV_TI
          set_value_no_commit $LLRF_PI_1_SAT_MAX 65536 SAT_MAX
          set_value_no_commit $LLRF_PI_1_SAT_MIN 65536 SAT_MIN
          set_value_no_commit $LLRF_PI_1_FIXED_SP 32768 FIXED_SP
          set_value_no_commit $LLRF_PI_1_FIXED_FF 32768 FIXED_FF
          echo "New register values written but not available to custom logic"
        elif [ "$opt" = "SETUP_PI_2" ]; then
          echo "K and TS_DIV_TI are in the range -256 to 255.9999"
          echo "SAT_MAX, SAT_MIN and SET_POINT are in the range 0.000 to 0.9999"
          echo "FIXED_FF is in the range -1.000 to 0.9999"
          set_value_no_commit $LLRF_PI_2_K 16777216 K
          set_value_no_commit $LLRF_PI_2_TS_DIV_TI 16777216 TS_DIV_TI
          set_value_no_commit $LLRF_PI_2_SAT_MAX 65536 SAT_MAX
          set_value_no_commit $LLRF_PI_2_SAT_MIN 65536 SAT_MIN
          set_value_no_commit $LLRF_PI_2_FIXED_SP 32768 FIXED_SP
          set_value_no_commit $LLRF_PI_2_FIXED_FF 32768 FIXED_FF
          echo "New register values written but not available to custom logic"
        elif [ "$opt" = "COMMIT_CHANGES" ]; then
          $CS_CMD   $DEV_SIS 2 > tmp.txt
          echo "New register values available to custom logic but not taken into use"
        elif [ "$opt" = "COMMIT_CHANGES_IMMEDIATE_USE" ]; then
          $CS_CMD   $DEV_SIS 2 > tmp.txt
          $CS_CMD   $DEV_SIS A > tmp.txt
          echo "New register values taken into use"
        elif [ "$opt" = "CURRENT_SETTINGS_PI_1" ]; then
          $CRD_CMD $DEV_SIS $LLRF_PI_1_K $LLRF_PI_1_FIXED_FF
        elif [ "$opt" = "CURRENT_SETTINGS_PI_2" ]; then
          $CRD_CMD $DEV_SIS $LLRF_PI_2_K $LLRF_PI_2_FIXED_FF
        else
          echo bad option
        fi
      done
      ###################################
      elif [ "$opt" = "CURRENT_SETTINGS_PI_1" ]; then
        $CRD_CMD $DEV_SIS $LLRF_PI_1_K $LLRF_PI_1_FIXED_FF
      elif [ "$opt" = "CURRENT_SETTINGS_PI_2" ]; then
        $CRD_CMD $DEV_SIS $LLRF_PI_2_K $LLRF_PI_2_FIXED_FF
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "SIGNAL_GENERATOR" ]; then
    ################################
    # SIGNAL GENERATOR
    ################################
    select opt in $OPTIONS_SG; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "GEN_MA_ang0" ]; then
        SP_size=0x0200
        SP_base_addr=0x00C00000
        FF_size=0x4000
        FF_base_addr=0x00800000
        $CWR_CMD $DEV_SIS $LLRF_GIP              0x00000000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_1_PARAM 0x00020000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_2_PARAM 0x00000600 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_1_PARAM $FF_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_2_PARAM $SP_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_3_PARAM $(printf "0x%04x%04x\n" $SP_size $FF_size)
	# sinusoid on mag
        $CWR_MEM $DEV_SIS $FF_base_addr $FF_size 8 0 
	# stair on mag
        $CWR_MEM $DEV_SIS $SP_base_addr $SP_size 9 0 
	# first value zero
        $CWR_MEM $DEV_SIS $FF_base_addr 0x1 0 0 
        $CWR_MEM $DEV_SIS $SP_base_addr 0x1 0 0 
	# setup MA out
	set_bits $LLRF_VM_CTRL 0xFFFFFFCF 0x30
	# use values
        $CS_CMD  $DEV_SIS 2 > tmp.txt
        $CS_CMD  $DEV_SIS A > tmp.txt
      elif [ "$opt" = "GEN_MA_ang90" ]; then
        SP_size=0x0200
        SP_base_addr=0x00C00000
        FF_size=0x4000
        FF_base_addr=0x00800000
        $CWR_CMD $DEV_SIS $LLRF_GIP              0x00000000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_1_PARAM 0x00020000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_2_PARAM 0x00000600 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_1_PARAM $FF_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_2_PARAM $SP_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_3_PARAM $(printf "0x%04x%04x\n" $SP_size $FF_size)
	# sinusoid on mag
        $CWR_MEM $DEV_SIS $FF_base_addr $FF_size 8 0 
	# MAG:stair, ANG:PI/2
        $CWR_MEM $DEV_SIS $SP_base_addr $SP_size 9 A 
	# first value zero
        $CWR_MEM $DEV_SIS $FF_base_addr 0x1 0 0 
        $CWR_MEM $DEV_SIS $SP_base_addr 0x1 0 0 
	# setup MA out
	set_bits $LLRF_VM_CTRL 0xFFFFFFCF 0x30
	# use values
        $CS_CMD  $DEV_SIS 2 > tmp.txt
        $CS_CMD  $DEV_SIS A > tmp.txt
        $CS_CMD  $DEV_SIS 3 > tmp.txt
      elif [ "$opt" = "GEN_IQ_ang0" ]; then
        SP_size=0x0200
        SP_base_addr=0x00C00000
        FF_size=0x4000
        FF_base_addr=0x00800000
        $CWR_CMD $DEV_SIS $LLRF_GIP              0x00000000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_1_PARAM 0x00020000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_2_PARAM 0x00000600 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_1_PARAM $FF_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_2_PARAM $SP_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_3_PARAM $(printf "0x%04x%04x\n" $SP_size $FF_size)
	# sinusoid on I
        $CWR_MEM $DEV_SIS $FF_base_addr $FF_size 8 0 
	# stair on I
        $CWR_MEM $DEV_SIS $SP_base_addr $SP_size 9 0 
	# first value zero
        $CWR_MEM $DEV_SIS $FF_base_addr 0x1 0 0 
        $CWR_MEM $DEV_SIS $SP_base_addr 0x1 0 0 
	# setup IQ out
	set_bits $LLRF_VM_CTRL 0xFFFFFFCF 0x00
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFFC 0x0
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFFC 0x0
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x18
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x18
	# use values
        $CS_CMD  $DEV_SIS 2 > tmp.txt
        $CS_CMD  $DEV_SIS A > tmp.txt
        $CS_CMD  $DEV_SIS 3 > tmp.txt
      elif [ "$opt" = "GEN_IQ_ang90" ]; then
        SP_size=0x0200
        SP_base_addr=0x00C00000
        FF_size=0x4000
        FF_base_addr=0x00800000
        $CWR_CMD $DEV_SIS $LLRF_GIP              0x00000000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_1_PARAM 0x00020000 
        $CWR_CMD $DEV_SIS $LLRF_LUT_CTRL_2_PARAM 0x00000600 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_1_PARAM $FF_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_2_PARAM $SP_base_addr 
        $CWR_CMD $DEV_SIS $LLRF_MEM_CTRL_3_PARAM $(printf "0x%04x%04x\n" $SP_size $FF_size)
	# sinusoid on Q
        $CWR_MEM $DEV_SIS $FF_base_addr $FF_size 0 8 
	# stair on Q
        $CWR_MEM $DEV_SIS $SP_base_addr $SP_size 0 9 
	# first value zero
        $CWR_MEM $DEV_SIS $FF_base_addr 0x1 0 0 
        $CWR_MEM $DEV_SIS $SP_base_addr 0x1 0 0 
	# setup IQ out
	set_bits $LLRF_VM_CTRL 0xFFFFFFCF 0x00
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFFC 0x0
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFFC 0x0
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x18
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x18
	# use values
        $CS_CMD  $DEV_SIS 2 > tmp.txt
        $CS_CMD  $DEV_SIS A > tmp.txt
        $CS_CMD  $DEV_SIS 3 > tmp.txt
      elif [ "$opt" = "DECREASE_FF_TBL_SPEED" ]; then
        dec_ff_tbl_speed $LLRF_PI_1_CTRL
	# use values
        $CS_CMD  $DEV_SIS 2 > tmp.txt
        $CS_CMD  $DEV_SIS A > tmp.txt
        $CS_CMD  $DEV_SIS 3 > tmp.txt
      elif [ "$opt" = "USE_CIRCULAR_FF" ]; then
        toggle_bit $LLRF_LUT_CTRL_1_PARAM 0x80000
      else
        echo bad option
      fi
    done  elif [ "$opt" = "MEM_CTRL" ]; then
    ################################
    # MEMORY CTRL
    ################################
    select opt in $OPTIONS_MEM; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "WRITE_MEM" ]; then
        write_mem
      elif [ "$opt" = "READ_MEM" ]; then
        read_mem
      elif [ "$opt" = "SETUP_FF_SP_MEM_LOC" ]; then
        setup_mem_ff_sp
      elif [ "$opt" = "SETUP_LUT" ]; then
        setup_lut
      elif [ "$opt" = "SETUP_MEM_STORE" ]; then
        setup_mem_store
      elif [ "$opt" = "NEW_PULSE_TYPE_SETUP" ]; then
        $CS_CMD   $DEV_SIS 3 > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "SETUP_SP_FF_OUTPUT" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC0 0x18
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC0 0x18
        echo "CUSTOM OUTPUT: PI_CTRL: Set point value(s) followed by feed forward value(s)" 
      elif [ "$opt" = "SETUP_PI_ERROR" ]; then
        setup_mem_pi_err
      elif [ "$opt" = "COMMIT_CHANGES_IMMEDIATE_USE" ]; then
        $CS_CMD   $DEV_SIS 2 > tmp.txt
        $CS_CMD   $DEV_SIS A > tmp.txt
        echo "New register values taken into use"
      elif [ "$opt" = "PULSE_LUT" ]; then
        $CS_CMD   $DEV_SIS C > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_IQ_DEBUG1 $LLRF_IQ_DEBUG2
      elif [ "$opt" = "CURRENT_SETTINGS" ]; then
        $CRD_CMD $DEV_SIS $LLRF_LUT_CTRL_1_PARAM $LLRF_PI_ERR_MEM_SIZE
        $CRD_CMD $DEV_SIS $LLRF_IQ_DEBUG_1 $LLRF_IQ_DEBUG_4
        $CRD_CMD $DEV_SIS $LLRF_GIP $LLRF_GIP
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "Custom_output" ]; then
    ################################
    # Custom_output
    ################################
    select opt in $OPTIONS_Custom_output; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "NORM" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x00
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x00
        set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0x00
        echo "CUSTOM OUTPUT: normal operation" 
      elif [ "$opt" = "IQ:RAW" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0x4
        echo "CUSTOM OUTPUT: IQ_SAMPLING: RAW ref and cavity input" 
      elif [ "$opt" = "IQ:ref_iq" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0x8
        echo "CUSTOM OUTPUT: IQ_SAMPLING: average: ref IQ" 
      elif [ "$opt" = "IQ:cav_iq" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0xC
        echo "CUSTOM OUTPUT: IQ_SAMPLING: average: cav IQ" 
      elif [ "$opt" = "IQ:ref_phase_rot_phase" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0x10
        echo "CUSTOM OUTPUT: IQ_SAMPLING: ref-phase and phase used to rotate" 
      elif [ "$opt" = "IQ:cav_and_rot_cav_i" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0x14
        echo "CUSTOM OUTPUT: IQ_SAMPLING: cav and rotated cav I" 
      elif [ "$opt" = "IQ:cav_and_rot_cav_q" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x04
        set_bits $LLRF_IQ_CTRL 0xFFFFFFE3 0x18
        echo "CUSTOM OUTPUT: IQ_SAMPLING: cav and rotated cav Q" 
      elif [ "$opt" = "PI:SP_Val" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x08
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x08
        echo "CUSTOM OUTPUT: PI_CTRL: Set point value(s)" 
      elif [ "$opt" = "PI:FF_Val" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x10
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x10
        echo "CUSTOM OUTPUT: PI_CTRL: Feed forward value(s)" 
      elif [ "$opt" = "PI:SP_FF_Val" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x18
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x18
        echo "CUSTOM OUTPUT: PI_CTRL: Set point value(s) followed by feed forward value(s)" 
      elif [ "$opt" = "PI:PI_ERROR" ]; then
        set_bits $LLRF_PI_1_CTRL 0xFFFFFFC3 0x20
        set_bits $LLRF_PI_2_CTRL 0xFFFFFFC3 0x20
        echo "CUSTOM OUTPUT: PI_CTRL: PI error values" 
      elif [ "$opt" = "DEBUG_VALUE" ]; then
        $CRD_CMD $DEV_SIS $LLRF_IQ_DEBUG1
      elif [ "$opt" = "CURRENT_SETTINGS" ]; then
        $CRD_CMD $DEV_SIS $LLRF_PI_1_CTRL
        $CRD_CMD $DEV_SIS $LLRF_PI_2_CTRL
        $CRD_CMD $DEV_SIS $LLRF_IQ_CTRL
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "Trigger_FSM" ]; then
    ################################
    # Trigger FSM
    ################################
    $CRD_CMD $DEV_SIS $LLRF_GOP
    select opt in $OPTIONS_FSM; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "PULSE_COMMING" ]; then
        set_bits_no_commit $STRUCK_ADC_SAMPLE_CTRL 0x800
        $WR_CMD  $DEV_SIS 0x10 0x2
        $CS_CMD   $DEV_SIS 6 > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "PULSE_START" ]; then
        $CS_CMD   $DEV_SIS 7 > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "PULSE_END" ]; then
        $CS_CMD   $DEV_SIS 8 > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "PMS" ]; then
        $CS_CMD   $DEV_SIS 9 > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "UPDATE_SP" ]; then
        $CS_CMD   $DEV_SIS 5 > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "UPDATE_FF" ]; then
        $CS_CMD   $DEV_SIS 4 > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "NEW_PULSE_TYPE" ]; then
        $CS_CMD   $DEV_SIS 3 > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "IRQ_CLEAR" ]; then
        $CS_CMD   $DEV_SIS D > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "CURRENT_SETTINGS" ]; then
        $CRD_CMD $DEV_SIS $LLRF_GOP
      elif [ "$opt" = "SW_RESET" ]; then
        $CS_CMD   $DEV_SIS B > tmp.txt
        $CRD_CMD $DEV_SIS $LLRF_GOP
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "HELP" ]; then
    ################################
    # Trigger FSM
    ################################
echo "####################################################"
echo "How to use the test script:"
echo " - Choose one of the numbered options by"
echo "   pressing that number followed by return."
echo " - List options again by only pressing return."
echo " - Pressing 1 followed by return in a submeny will bring you back one level."
echo " - Normal operation, do:"
echo "     1. SETUP - and follow the instructions"
echo "     2. RUN   - and follow the instructions"
echo "####################################################"
  else
    clear
    echo bad option
  fi
done

#    read answer
#    case $answer in
#        [Yy]* ) ;;
#        [Nn]* ) echo "Try again when you have done as told. Bye Bye"; exit;;
#    esac

