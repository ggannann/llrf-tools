####################################
# CONSTANTS - SETUP
####################################
# Device ID, change this if the struck card is moved to a new slot
DEV_SIS="/dev/sis8300-4"
#system names
MTCA=LLRF-MTCA
TR_MTCA=TR-MTCA
mtca=mtca
LION=LLRF-LION
TR_LION=TR-LION
lion=lion

#OPMODES
OPM_Norm=NORMAL
OPM_SPout=OutputSP

#Device state
DS_reset=RESET
DS_init=INIT
DS_on=ON

#Default values
DEFAULT_CONF_FILE=mtca_1p0.conf
DEFAULT_NBR_PULSES=20
DEFAULT_SETUP_FILE=mtca-snaphot.txt
DEFAULT_PARAM_FILE=log_RMS.conf
DEFAULT_PV="PI-I-GAINK"
DEFAULT_STEP_SIZE=0.1
DEFAULT_START_VALUE=0.1
DEFAULT_STOP_VALUE=1.0
DEFAULT_PV_PI=0
DEFAULT_BREAK=1
DEFAULT_CAV_ATT_START=-9
DEFAULT_CAV_ATT_STOP=-5
DEFAULT_VM_ATT_START=-6
DEFAULT_VM_ATT_STOP=-4
DEFAULT_SP_DELTA_ANG=1
DEFAULT_SP_MAG=0.75
DEFAULT_LOOP_STATE=1
#Measurement metric RMS: 0=average, 1=MAX
DEFAULT_METRIC=0

####################################
# PATHS
####################################
CONF="/home/eit_ess/git/llrf-bucket/LTH/conf"
LOG_DIR="/home/eit_ess/logs"


####################################
# FILES
####################################
BEFORE_AFTER_LOG="values_test_before_after.log"

####################################
# VARIABLES
####################################
OPTIONS="SETUP STATUS RUN RESET HELP QUIT"
OPTIONS_SETUP="BACK SETUP_DEFAULT SETUP_TABLES"
OPTIONS_TABLE="BACK DUMMY_TABLE IMPORT_TABLE"
OPTIONS_RUN="BACK RUN_SINGLE_TEST RUN_PARAMETER_UPDOWN_TEST RUN_PARAMETER_SWEEP_TEST RUN_SWEEP_TEST_PI RUN_SWEEP_TEST_CAV_DELAY RUN_TEST_NO_CAV_DELAY RUN_TEST_LOOP_ATTENUATION RUN_TEST_CIRCULAR_SP LIST_PARAMETERS_IN_USE"

####################################
# EXTERNAL FUNCTIONS
####################################
GET="caget -t"
PUT="caput -t"
SETUP_DEFAULT="requireExec sis8300llrf -- sis8300llrf-setupDefaults.py"
IMPORT_TABLE="requireExec sis8300llrf -- sis8300llrf-importTableFromFile.py"
RUN_FIXED="requireExec sis8300llrf -- sis8300llrf-test-runFixedPulses.py"
GET_ERROR_METRIC="requireExec llrftools,eit_ess -- get_error_metric.pl"

####################################
# SUB FUNCTIONS
####################################
function get_status {
  bad=0
  val=$($GET $LLRF_SYS:PMS)
  if [ $val != "NONE" ] ; then
    bad=$(($bad+1))
    echo "  PMS ACTIVE!"
  fi
  val=$($GET $LLRF_SYS:PI-I-OVRFLW)
  if [ $val != "None" ] ; then
    bad=$(($bad+1))
    echo "  OVERFLOW I-part!"
  fi
  val=$($GET $LLRF_SYS:PI-Q-OVRFLW)
  if [ $val != "None" ] ; then
    bad=$(($bad+1))
    echo "  OVERFLOW Q-part!"
  fi
  val=$($GET $LLRF_SYS:VM-MAGLIMSTAT)
  if [ $val != "None" ] ; then
    bad=$(($bad+1))
    echo "  VM LIMIT ACTIVE!"
  fi
  val=$($GET $LLRF_SYS:SMON-ILOCKSTATUS)
  if [ $val -gt 0 ] ; then
    bad=$(($bad+1))
    echo "  Signal monitor Interlock $val ACTIVE!"
  fi
  val=$($GET $LLRF_SYS:SMON-PMSSTATUS)
  if [ $val -gt 0 ] ; then
    bad=$(($bad+1))
    echo "  Signal monitor PMS $val ACTIVE!"
  fi
  return $bad
}

function run_fixed_test {
  echo "Load threshold conf file."
  echo "Pick one of these (Default is $DEFAULT_CONF_FILE):"
  ls "$CONF" | grep -i "$sys".*conf$
  echo -e "Enter file name: \c "
  read file_name
  export conf_file=${file_name:-$DEFAULT_CONF_FILE}
  echo -e "Enter number of pulses to run (Default $DEFAULT_NBR_PULSES): \c "
  read pulse_nbr
  export nbr_pulses=${pulse_nbr:-$DEFAULT_NBR_PULSES}
  echo -e "Break on warning [0|1] (Default $DEFAULT_BREAK): \c "
  read break_on_warn
  export warning_break=${break_on_warn:-$DEFAULT_BREAK}
  echo -e "RMS measurement metric [0=avg|1=max] (Default $DEFAULT_METRIC): \c "
  read rms_metric
  export METRIC=${rms_metric:-$DEFAULT_METRIC}
  echo "Running $nbr_pulses-pulses using thresholds from $conf_file, logging the result in $LOG_DIR/$sys"
  $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses | grep -i "Pulse count"
  rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
  echo "rms $rms"
}

function run_test_loop_attenuation {
  echo -e "##########################################################"
  echo -e "Cavity input Attenuation test span from low to high value."
  echo -e "Granularity of 0.5."
  echo -e "Max -31.5 dB and min 0 dB."
  echo -e "##########################################################"
  echo -e "Enter Cav input attenuation start (Default $DEFAULT_CAV_ATT_START): \c "
  read val
  export cav_start=${val:-$DEFAULT_CAV_ATT_START}
  echo -e "Enter Cav input attenuation stop (Default $DEFAULT_CAV_ATT_STOP): \c "
  read val1
  export cav_stop=${val1:-$DEFAULT_CAV_ATT_STOP}
  cav_step=0.5
  echo -e "##########################################################"
  echo -e "VM output Attenuation test span from low to high value."
  echo -e "Granularity of 0.25."
  echo -e "Max -15.75 dB and min 0 dB."
  echo -e "##########################################################"
  echo -e "Enter VM output attenuation start (Default $DEFAULT_VM_ATT_START): \c "
  read val2
  export vm_start=${val2:-$DEFAULT_VM_ATT_START}
  echo -e "Enter VM output attenuation stop (Default $DEFAULT_VM_ATT_STOP): \c "
  read val3
  export vm_stop=${val3:-$DEFAULT_VM_ATT_STOP}
  vm_step=0.25
  echo "#############################################################"
  echo "Cav input attenuation spans $cav_start to $cav_stop in steps of $cav_step"
  echo "VM output attenuation spans $vm_start to $vm_stop in steps of $vm_step"
  echo "#############################################################"
  org_cav=$($GET $LLRF_SYS:AI0-ATT)
  org_vm=$($GET $LLRF_SYS:AI8-ATT)
  $PUT $LLRF_SYS:AI0-ATT $cav_start > tmp.txt
  $PUT $LLRF_SYS:AI8-ATT $vm_start > tmp.txt
  cav_val=$cav_start
  vm_val=$vm_start
  best_rms=1.0;
  #sweep
  while [ $(echo "$cav_val <= $cav_stop" | bc -l) -eq 1 ]; do
    while [ $(echo "$vm_val <= $vm_stop" | bc -l) -eq 1 ]; do
      $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
      rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
      if [ $(echo "$rms <= $best_rms" | bc -l) -eq 1 ] ; then
        best_rms=$rms
        best_vm=$vm_val
        best_cav=$cav_val
      fi
      echo "$LLRF_SYS:AI0-ATT $cav_val $LLRF_SYS:AI8-ATT $vm_val, rms $rms"
      get_status
      if [ $? -gt 0 ] && [ $warning_break -eq 1 ] ; then
        break
      fi
      vm_val=$(echo "$vm_val+$vm_step" | bc -l)
      $PUT $LLRF_SYS:AI8-ATT $vm_val > tmp.txt
    done
    vm_val=$vm_start
    cav_val=$(echo "$cav_val+$cav_step" | bc -l)     
    $PUT $LLRF_SYS:AI0-ATT $cav_val > tmp.txt
  done 
  $PUT $LLRF_SYS:AI0-ATT $org_cav > tmp.txt
  $PUT $LLRF_SYS:AI8-ATT $org_vm > tmp.txt
  echo "Test end, best RMS ($best_rms) with $LLRF_SYS:AI0-ATT $best_cav and $LLRF_SYS:AI8-ATT $best_vm"
}

function run_test_sweep_test {
  echo -e "Enter PV name (Default $DEFAULT_PV): \c "
  read pv_name
  export sweep_pv=${pv_name:-$DEFAULT_PV}
  echo -e "Enter start value (Default $DEFAULT_START_VALUE): \c "
  read start
  export start_value=${start:-$DEFAULT_START_VALUE}
  echo -e "Enter stop value (Default $DEFAULT_STOP_VALUE): \c "
  read stop
  export stop_value=${stop:-$DEFAULT_STOP_VALUE}
  echo -e "Enter step size (Default $DEFAULT_STEP_SIZE): \c "
  read size
  export step_size=${size:-$DEFAULT_STEP_SIZE}
  echo "########################################"
  echo "Start value of $LLRF_SYS:$sweep_pv $start_value"
  echo "Stop value of $LLRF_SYS:$sweep_pv $stop_value"
  echo "Step size: $step_size"
  echo "########################################"
  pv_val=$start_value;
  best_pv_val=$pv_val;
  $PUT $LLRF_SYS:$sweep_pv $pv_val > tmp.txt
  best_rms=1.0;
  #sweep
  while [ $(echo "$pv_val <= $stop_value" | bc -l) -eq 1 ]; do
    $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
    rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
    if [ $(echo "$rms <= $best_rms" | bc -l) -eq 1 ] ; then
      best_rms=$rms
      best_pv_val=$pv_val
    fi
    echo "$sweep_pv $pv_val, rms $rms"
    get_status
    if [ $? -gt 0 ] && [ $warning_break -eq 1 ] ; then
      break
    fi
    pv_val=$(echo "$pv_val+$step_size" | bc -l)
    $PUT $LLRF_SYS:$sweep_pv $pv_val > tmp.txt
  done 
  $PUT $LLRF_SYS:$sweep_pv $best_pv_val > tmp.txt
  echo "Test end, best RMS with $LLRF_SYS:$sweep_pv $best_pv_val"
}


function run_circular_sp_test {
  echo "Run open-loop or closed-loop?"
  echo "In open-loop PI-ctrl output SP and ignore input"
  echo -e "Set loop value: 0=open 1=closed (Default $DEFAULT_LOOP_STATE): \c "
  read loop
  export loop_state=${loop:-$DEFAULT_LOOP_STATE}
  echo -e "Enter SP magnitude (Default $DEFAULT_SP_MAG): \c "
  read sp_mag
  export mag=${sp_mag:-$DEFAULT_SP_MAG}
  echo -e "Enter degrees between SPs (Default $DEFAULT_SP_DELTA_ANG): \c "
  read sp_ang_delta
  export ang_delta=${sp_ang_delta:-$DEFAULT_SP_DELTA_ANG}
  echo "########################################"
  echo "Start value of $LLRF_SYS:PI-I-FIXEDSPVAL -$mag"
  echo "Start value of $LLRF_SYS:PI-Q-FIXEDSPVAL 0"
  echo "Step size: $ang_delta" degrees
  echo "########################################"
  org_opmode=$($GET $LLRF_SYS:OPMODE)
  echo "org_opmode: $org_opmode"
  if [ $loop_state -eq 0 ] ; then
    $PUT $LLRF_SYS:SMSGS $DS_reset > tmp.txt    
    $PUT $LLRF_SYS:SMSGS $DS_init > tmp.txt    
    $PUT $LLRF_SYS:OPMODE $OPM_SPout > tmp.txt    
    $PUT $LLRF_SYS:SMSGS $DS_on > tmp.txt    
    echo "Operation Mode: OutputSP"
  fi
  unset cav_mag
  unset cav_ang
  unset ref_ang
  org_i=$($GET $LLRF_SYS:PI-I-FIXEDSPVAL)
  org_q=$($GET $LLRF_SYS:PI-Q-FIXEDSPVAL)
  i_val=-$mag;
  q_val=0;
  ang=-3.14159
  ang_stop=3.14159
  ang_delta=$( echo "2*3.14159/360*$ang_delta" | bc -l)
  worst_rms=0.0
  best_rms=1.0
  $PUT $LLRF_SYS:PI-I-FIXEDSPVAL $i_val > tmp.txt
  $PUT $LLRF_SYS:PI-Q-FIXEDSPVAL $q_val > tmp.txt
  #sweep
  i=0
  while [ $(echo "$ang <= $ang_stop" | bc -l) -eq 1 ]; do
    $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
    rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
    if [ $(echo "$rms <= $best_rms" | bc -l) -eq 1 ] ; then
      best_rms=$rms
      best_ang_val=$ang
    fi
    if [ $(echo "$rms > $worst_rms" | bc -l) -eq 1 ] ; then
      worst_rms=$rms
      worst_ang_val=$ang
    fi
    echo "Mag: $mag, Ang:$ang, RMS: $rms"
    get_status
    if [ $? -gt 0 ] && [ $warning_break -eq 1 ] ; then
      break
    fi
    ang=$(echo "$ang+$ang_delta" | bc -l)
    i_val=$(echo "c($ang)*$mag" | bc -l)
    q_val=$(echo "s($ang)*$mag" | bc -l)
#    echo "I: $i_val, Q: $q_val"
#    echo -e "Wait for press of anykey \c "
#    read nothing
    $PUT $LLRF_SYS:PI-I-FIXEDSPVAL $i_val > tmp.txt
    $PUT $LLRF_SYS:PI-Q-FIXEDSPVAL $q_val > tmp.txt
    cav_mag[$i]=$($GET $LLRF_SYS:AI0-MAG)
    cav_ang[$i]=$($GET $LLRF_SYS:AI0-ANG)
    ref_ang[$i]=$($GET $LLRF_SYS:AI1-ANG)
    i=$(($i+1))
  done 
  if [ $loop_state -eq 0 ] ; then
    $PUT $LLRF_SYS:SMSGS $DS_reset > tmp.txt    
    $PUT $LLRF_SYS:SMSGS $DS_init > tmp.txt    
    $PUT $LLRF_SYS:OPMODE $org_opmode > tmp.txt
    $PUT $LLRF_SYS:SMSGS $DS_on > tmp.txt    
  fi
  $PUT $LLRF_SYS:PI-I-FIXEDSPVAL $org_i > tmp.txt
  $PUT $LLRF_SYS:PI-Q-FIXEDSPVAL $org_q > tmp.txt
  echo "Test end, best RMS ($best_rms) at angle $best_ang_val, worst RMS ($worst_rms) at angle $worst_ang_val"
  echo "cav_mag=[ ${cav_mag[*]} ];"
  echo "cav_ang=[ ${cav_ang[*]} ];"
  echo "ref_ang=[ ${ref_ang[*]} ];"
  echo "mag=$mag;"
}


function run_sweep_test_delay {
  sweep_pv0=IQSMPL-CAVINDELAYVAL
  sweep_pv1=IQSMPL-ANGOFFSETVAL
  echo -e "Enter start value (Default 0): \c "
  read start
  export start_del=${start:-0}
  echo -e "Enter stop value (Default 63): \c "
  read stop
  export stop_del=${stop:-63}
  step_size=1
  N=$($GET $LLRF_SYS:IQSMPL-NEARIQN)
  M=$($GET $LLRF_SYS:IQSMPL-NEARIQM)
  Angle=$($GET $LLRF_SYS:IQSMPL-ANGOFFSETVAL)
  Delay=$($GET $LLRF_SYS:IQSMPL-CAVINDELAYVAL)
  org_del=$Delay
  D_en=$($GET -n $LLRF_SYS:IQSMPL-CAVINDELAYEN)
  if [ $D_en -eq 0 ] ; then
    $PUT $LLRF_SYS:IQSMPL-CAVINDELAYEN 1 > tmp.txt
    Delay=3
  fi
  ang_per_delay=$(echo "$M*2*3.14159/$N" | bc -l)
  start_ang=$(echo "$Angle-($Delay-($start_del))*$ang_per_delay" | bc -l)
  while [ $(echo "$start_ang <= -3.14159" | bc -l) -eq 1 ]; do
   start_ang=$(echo "$start_ang+2*3.14159" | bc -l)
  done
  while [ $(echo "$start_ang > 3.14159" | bc -l) -eq 1 ]; do
   start_ang=$(echo "$start_ang-2*3.14159" | bc -l)
  done
  echo "########################################"
  echo "Start value of $LLRF_SYS:$sweep_pv0 set to $start_del"
  echo "Stop value of  $LLRF_SYS:$sweep_pv0 set to $stop_del"
  echo "Step size: $step_size"
  echo "########################################"
  ang_val=$start_ang
  del_val=$start_del
  best_ang_val=$ang_val
  best_del_val=$del_val
  $PUT $LLRF_SYS:$sweep_pv0 $del_val > tmp.txt
  $PUT $LLRF_SYS:$sweep_pv1 $ang_val > tmp.txt
  if [ $(echo "$del_val == -3" | bc -l) -eq 1 ] ; then
    $PUT $LLRF_SYS:IQSMPL-CAVINDELAYEN 0 > tmp.txt
  fi
  best_rms=1.0
  #sweep
  while [ $(echo "$del_val <= $stop_del" | bc -l) -eq 1 ]; do
    $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
    rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
    if [ $(echo "$rms < $best_rms" | bc -l) -eq 1 ] ; then
      best_rms=$rms
      best_ang_val=$ang_val
      best_del_val=$del_val
    fi
    echo -e "$sweep_pv $del_val, rms $rms \t total-delay $(($del_val+3)), ang_offset $ang_val"
    get_status
    if [ $? -gt 0 ] && [ $warning_break -eq 1 ] ; then
      break
    fi
    del_val=$(echo "$del_val+$step_size" | bc -l)
    ang_val=$(echo "$ang_val+$ang_per_delay" | bc -l)
    if [ $(echo "$ang_val > 3.14159" | bc -l) -eq 1  ] ; then
      ang_val=$(echo "$ang_val-2*3.14159" | bc -l)      
    fi
    $PUT $LLRF_SYS:$sweep_pv0 $del_val > tmp.txt
    $PUT $LLRF_SYS:$sweep_pv1 $ang_val > tmp.txt
  done 
  $PUT $LLRF_SYS:IQSMPL-CAVINDELAYEN $D_en > tmp.txt
  $PUT $LLRF_SYS:$sweep_pv0 $org_del > tmp.txt
  $PUT $LLRF_SYS:$sweep_pv1 $Angle > tmp.txt
  echo "Test end, best RMS ($best_rms) with $LLRF_SYS:$sweep_pv0 set to $best_del_val ($LLRF_SYS:$sweep_pv1 $best_ang_val)"
}

function run_test_no_cav_delay {
  N=$($GET $LLRF_SYS:IQSMPL-NEARIQN)
  M=$($GET $LLRF_SYS:IQSMPL-NEARIQM)
  Angle=$($GET $LLRF_SYS:IQSMPL-ANGOFFSETVAL)
  Delay=$($GET $LLRF_SYS:IQSMPL-CAVINDELAYVAL)
  D_en=$($GET -n $LLRF_SYS:IQSMPL-CAVINDELAYEN)
  if [ $D_en -eq 0 ] ; then
    $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
    rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
    echo -e "No delay, rms $rms"
    break
  fi
  ang_per_delay=$(echo "$M*2*3.14159/$N" | bc -l)
  start_ang=$(echo "$Angle-($Delay+3)*$ang_per_delay" | bc -l)
  while [ $(echo "$start_ang <= -3.14159" | bc -l) -eq 1 ]; do
   start_ang=$(echo "$start_ang+2*3.14159" | bc -l)
  done
  $PUT $LLRF_SYS:IQSMPL-ANGOFFSETVAL $start_ang > tmp.txt
  $PUT $LLRF_SYS:IQSMPL-CAVINDELAYEN 0 > tmp.txt
  $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
  rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
  get_status
  $PUT $LLRF_SYS:IQSMPL-CAVINDELAYEN $D_en > tmp.txt
  $PUT $LLRF_SYS:IQSMPL-ANGOFFSETVAL $Angle > tmp.txt
  echo -e "No delay rms $rms (ang_offset $start_ang)"
}


function run_sweep_test_pi {
  echo -e "Which setting, 0=K 1=TS/TI (Default $DEFAULT_PV_PI): \c "
  read nbr
  export pv_nbr=${nbr:-$DEFAULT_PV_PI}
  sweep_pv0=PI-I-GAINTSDIVTI
  sweep_pv1=PI-Q-GAINTSDIVTI
  if [ $pv_nbr -eq 0 ] ; then
    sweep_pv0=PI-I-GAINK
    sweep_pv1=PI-Q-GAINK
  fi
  echo -e "Enter start value (Default $DEFAULT_START_VALUE): \c "
  read start
  export start_value=${start:-$DEFAULT_START_VALUE}
  echo -e "Enter stop value (Default $DEFAULT_STOP_VALUE): \c "
  read stop
  export stop_value=${stop:-$DEFAULT_STOP_VALUE}
  echo -e "Enter step size (Default $DEFAULT_STEP_SIZE): \c "
  read size
  export step_size=${size:-$DEFAULT_STEP_SIZE}
  echo "########################################"
  echo "Start value of $LLRF_SYS:$sweep_pv0 and $LLRF_SYS:$sweep_pv1 set to $start_value"
  echo "Stop value of  $LLRF_SYS:$sweep_pv0 and $LLRF_SYS:$sweep_pv1 set to $stop_value"
  echo "Step size: $step_size"
  echo "########################################"
  pv_val=$start_value
  best_pv_val=$pv_val
  $PUT $LLRF_SYS:$sweep_pv0 $pv_val > tmp.txt
  $PUT $LLRF_SYS:$sweep_pv1 $pv_val > tmp.txt
  best_rms=1.0
  #sweep
  while [ $(echo "$pv_val <= $stop_value" | bc -l) -eq 1 ]; do
    $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
    rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
    if [ $(echo "$rms <= $best_rms" | bc -l) -eq 1 ] ; then
      best_rms=$rms
      best_pv_val=$pv_val
    fi
    echo "$sweep_pv $pv_val, rms $rms"
    get_status
    if [ $? -gt 0 ] && [ $warning_break -eq 1 ] ; then
      break
    fi
    pv_val=$(echo "$pv_val+$step_size" | bc -l)
    $PUT $LLRF_SYS:$sweep_pv0 $pv_val > tmp.txt
    $PUT $LLRF_SYS:$sweep_pv1 $pv_val > tmp.txt
  done 
  $PUT $LLRF_SYS:$sweep_pv0 $best_pv_val > tmp.txt
  $PUT $LLRF_SYS:$sweep_pv1 $best_pv_val > tmp.txt
  echo "Test end, best RMS with $LLRF_SYS:$sweep_pv0 and $LLRF_SYS:$sweep_pv1 set to $best_pv_val"
}


function run_updown_test {
  echo -e "Enter PV name (Default $DEFAULT_PV): \c "
  read pv_name
  export updown_pv=${pv_name:-$DEFAULT_PV}
  echo -e "Enter step size (Default $DEFAULT_STEP_SIZE): \c "
  read size
  export step_size=${size:-$DEFAULT_STEP_SIZE}
  pv_val=$($GET $LLRF_SYS:$updown_pv)
  start_pv_val=$pv_val
  echo "-$RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses"
  $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
  rms_best_val=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
  echo "########################################"
  echo "Start value of $LLRF_SYS:$updown_pv $pv_val"
  echo "Start value of average RMS $rms_best_val"
  echo "Step size: $step_size"
  echo "########################################"
  echo "INCREASING:"
  new_rms=$rms_best_val;
  #try increasing
  while [ $(echo "$new_rms <= $rms_best_val" | bc -l) -eq 1 ]; do
    rms_best_val=$new_rms
    pv_val=$($GET $LLRF_SYS:$updown_pv)
    pv_val=$(echo "$pv_val+$step_size" | bc -l)
    $PUT $LLRF_SYS:$updown_pv $pv_val > tmp.txt
    $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
    new_rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
    echo "$updown_pv $pv_val, new_rms $new_rms, best_rms $rms_best_val"
    get_status
    if [ $? -gt 0 ] && [ $warning_break -eq 1 ] ; then
      break
    fi
  done 
  #try decreasing
  echo "DECREASING:"
  $PUT $LLRF_SYS:$updown_pv $start_pv_val > tmp.txt
  new_rms=$rms_best_val;
  while [ $(echo "$new_rms <= $rms_best_val" | bc -l) -eq 1 ]; do
    rms_best_val=$new_rms
    pv_val=$($GET $LLRF_SYS:$updown_pv)
    pv_val=$(echo "$pv_val-$step_size" | bc -l)
    $PUT $LLRF_SYS:$updown_pv $pv_val > tmp.txt
    $RUN_FIXED $CONF/$conf_file $CONF/$DEFAULT_PARAM_FILE $LOG_DIR/$sys $LLRF_SYS $LLRF_TR $nbr_pulses > tmp.txt
    new_rms=$($GET_ERROR_METRIC $LOG_DIR/$sys/$BEFORE_AFTER_LOG 1 $METRIC)
    echo "$updown_pv $pv_val, new_rms $new_rms, best_rms $rms_best_val"
    get_status
    if [ $? -gt 0 ] && [ $warning_break -eq 1 ] ; then
      break
    fi
  done 
  $PUT $LLRF_SYS:$updown_pv $start_pv_val > tmp.txt
  echo "Test end"
}

function setup {
  echo "Load a setup file. Pick one of these:"
  ls "$CONF" | grep -i "$sys".*txt$
  echo -e "Enter file name (Default is mtca-snaphot.txt): \c "
  read file_name
  export setup_file=${file_name:-$DEFAULT_SETUP_FILE}
  $SETUP_DEFAULT $CONF/$setup_file 2
}

function setup_table {
  echo "Load a SP:I file. Pick one of these:"
  ls $CONF | grep -i "$sys".*SP.*I.*txt$
  echo -e "Enter file name: \c "
  read file_name
  $IMPORT_TABLE $LLRF-SYS:SP-PT0-I $CONF/$file_name
  echo "Load a SP:Q file. Pick one of these:"
  ls $CONF | grep -i "$sys".*SP.*Q.*txt$
  echo -e "Enter file name: \c "
  read file_name
  $IMPORT_TABLE $LLRF-SYS:SP-PT0-Q $CONF/$file_name
  echo "Load a FF:I file. Pick one of these:"
  ls $CONF | grep -i "$sys".*FF.*I.*txt$
  echo -e "Enter file name: \c "
  read file_name
  $IMPORT_TABLE $LLRF-SYS:FF-PT0-I $CONF/$file_name
  echo "Load a FF:Q file. Pick one of these:"
  ls $CONF | grep -i "$sys".*FF.*Q.*txt$
  echo -e "Enter file name: \c "
  read file_name
  $IMPORT_TABLE $LLRF-SYS:FF-PT0-Q $CONF/$file_name
}

