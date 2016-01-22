#!/bin/bash
. /home/eit_ess/git/m-llrf-tools/scripts/LLRF_ioc_func_const.sh

############
#INPUT
############
if [ $# -eq 1 ] ; then
  if [ $1 -eq 0 ] ; then
    LLRF_SYS=$MTCA
    LLRF_TR=$TR_MTCA
    sys=$mtca
  elif [ $1 -eq 1 ] ; then
    LLRF_SYS=$LION
    LLRF_TR=$TR_LION
    sys=$lion
  else
    LLRF_SYS=UNDIFINED_SYSTEM
  fi
  echo "####################################################"
  echo "# Testing on system: $LLRF_SYS"
  echo "####################################################"
else
  echo "Usage: ./LLRF_ioc_test.sh <LLRF_SYSTEM_NBR>"
  echo "   0: MTCA"
  echo "   1: LION"
  exit
fi

###########
# MAIN
###########
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
  ####################################################
  if [ "$opt" = "QUIT" ]; then
  ####################################################
    echo "Thank you for this time! I hope to see you again soon!"
    exit
  ####################################################
  elif [ "$opt" = "RESET" ]; then
  ####################################################
    caput $LLRF_SYS 7
    caput $LLRF_SYS 3
    echo "STATE SEQUENCE: RESET -> INIT"
  ####################################################
  elif [ "$opt" = "SETUP" ]; then
  ####################################################
    echo "####################################################"
    echo " Do:"
    echo "   1. SETUP_DEFAULT - sets all registers"
    echo "   2. SETUP_TABLES  - sets up SP and FF tables"
    echo "                      and set pulse type to 0"
    echo "####################################################"
    select opt in $OPTIONS_SETUP; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "SETUP_DEFAULT" ]; then
        setup $sys
      elif [ "$opt" = "SETUP_TABLES" ]; then
        echo "ONLY Pulsetype 0 is supported"
        select opt in $OPTIONS_TABLE; do
          if [ "$opt" = "BACK" ]; then
	    break
          elif [ "$opt" = "DUMMY_TABLE" ]; then
            echo "SP and FF tables filled for PT0 and SM"
            caput -a $LLRF_SYS:FF-PT0-I 2 0 0.3 0.3 > tmp.txt
            caput -a $LLRF_SYS:SP-PT0-I 2 0 0.3 0.3 > tmp.txt
            caput $LLRF_SYS:PT 0
            caput -a $LLRF_SYS:FF-SM-I 2 0 0.3 0.3 > tmp.txt
            caput -a $LLRF_SYS:SP-SM-I 2 0 0.3 0.3 > tmp.txt
          elif [ "$opt" = "IMPORT_TABLE" ]; then
            setup_table
            caput $LLRF_SYS:PT 0
          else
            echo bad option
          fi
        done
      else
        echo bad option
      fi
    done
  ####################################################
  elif [ "$opt" = "STATUS" ]; then
  ####################################################
    echo "SYSTEM: $LLRF_SYS"
    get_status
    echo "SYSTEM WARNINGS: $?"
    val=$($GET $LLRF_SYS)
    echo "SYSTEM STATE:    $val"
    val=$($GET $LLRF_SYS:OPMODE)
    echo "SYSTEM MODE:     $val"
  ####################################################
  elif [ "$opt" = "RUN" ]; then
  ####################################################
    echo "####################################################"
    echo " To do a sweep/updaown test:"
    echo "  1. RUN_SINGLE_TEST, to setup test and verify"
    echo "  2. Either do a:"
    echo "    - RUN_PARAMETER_UPDOWN_TEST, over desired parameter, or"
    echo "    - RUN_PARAMETER_SWEEP_TEST,  over desired parameter (Single parameter), or."
    echo "    - RUN_SWEEP_TEST_PI,         over desired parameters (Paired PI-parameters), or"
    echo "    - RUN_SWEEP_TEST_CAV_DELAY,  over Cav input delay, or"
    echo "    - RUN_TEST_NO_CAV_DELAY,     with NO Cav input delay."
    echo "    - RUN_TEST_LOOP_ATTENUATION, over Cav input and VM attenuation."
    echo "    - RUN_TEST_CIRCULAR_SP,      SP around the circle."
    echo "####################################################"
    select opt in $OPTIONS_RUN; do
      if [ "$opt" = "BACK" ]; then
        break
      elif [ "$opt" = "RUN_SINGLE_TEST" ]; then
        run_fixed_test
        get_status
      elif [ "$opt" = "RUN_PARAMETER_UPDOWN_TEST" ]; then
        run_updown_test
      elif [ "$opt" = "RUN_PARAMETER_SWEEP_TEST" ]; then
        run_sweep_test
      elif [ "$opt" = "RUN_SWEEP_TEST_PI" ]; then
        run_sweep_test_pi
      elif [ "$opt" = "RUN_SWEEP_TEST_CAV_DELAY" ]; then
        echo " ASUMES A TUNED LOOP! "
        run_sweep_test_delay
      elif [ "$opt" = "RUN_TEST_NO_CAV_DELAY" ]; then
        echo " ASUMES A TUNED LOOP! "
        run_test_no_cav_delay
      elif [ "$opt" = "RUN_TEST_LOOP_ATTENUATION" ]; then
        echo " RUN WITH NO BREAK ON WARNINGS! "
        run_test_loop_attenuation
      elif [ "$opt" = "RUN_TEST_CIRCULAR_SP" ]; then
        run_circular_sp_test
      elif [ "$opt" = "LIST_PARAMETERS_IN_USE" ]; then
        temp=${conf_file-NOT_SETUP_RUN_SINGLE_TEST_FIRST}
        echo "Threshold file        : $CONF/$temp"
        echo "Parameter file        : $CONF/$DEFAULT_PARAM_FILE"
        echo "Log-file DIR          : $LOG_DIR/$sys"
        echo "Nbr of pulses per test: ${nbr_pulses-NOT_SETUP_RUN_SINGLE_TEST_FIRST}"
        echo "Break on warnings     : ${warning_break-NOT_SETUP_RUN_SINGLE_TEST_FIRST}"
        echo "RMS measurement metric: ${METRIC-NOT_SETUP_RUN_SINGLE_TEST_FIRST}"
      else
        echo bad option
      fi
    done
  ####################################################
  elif [ "$opt" = "HELP" ]; then
  ####################################################
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
  ####################################################
  else
  ####################################################
    clear
    echo bad option
  fi
done

