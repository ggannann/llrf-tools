#!/bin/bash
. LLRF_ioc_func_const.sh

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
   echo "Testing on system: $LLRF_SYS"
else
   echo "Usage: ./LLRF_ioc_test.sh <LLRF_SYSTEM_NBR>"
   echo "   1: MTCA"
   echo "   2: LION"
fi

###########
# MAIN
###########
select opt in $OPTIONS; do
  if [ "$opt" = "QUIT" ]; then
    echo "Thank you for this time! I hope to see you again soon!"
    exit
  elif [ "$opt" = "RESET" ]; then
    echo "RESET"
  elif [ "$opt" = "SETUP" ]; then
    select opt in $OPTIONS_SETUP; do
      if [ "$opt" = "BACK" ]; then
	break
      elif [ "$opt" = "SETUP_DEFAULT" ]; then
        setup $sys
      elif [ "$opt" = "SETUP_TABLES" ]; then
        select opt in $OPTIONS_TABLE; do
          if [ "$opt" = "BACK" ]; then
	    break
          elif [ "$opt" = "DUMMY_TABLE" ]; then
            caput -a $LLRF_SYS:FF-PT0:I 2 0 0.3 0.3 > tmp.txt
            caput -a $LLRF_SYS:SP-PT0:I 2 0 0.3 0.3 > tmp.txt
            caput $LLRF_SYS:PT 0
          elif [ "$opt" = "IMPORT_TABLE" ]; then
            setup_table
            caput LLRF-LION:PT 0
          else
            echo bad option
          fi
        done
      else
        echo bad option
      fi
    done
  elif [ "$opt" = "STATUS" ]; then
    get_status
  elif [ "$opt" = "RUN" ]; then
    run_fixed_test
  elif [ "$opt" = "HELP" ]; then
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

