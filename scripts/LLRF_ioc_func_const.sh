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

DEFAULT_CONF_FILE=mtca_03.conf
DEFAULT_NBR_PULSES=100
####################################
# PATHS
####################################
CONF="/home/eit_ess/git/llrf-bucket/LTH/conf/"
LOG_DIR="/home/eit_ess/logs/"

####################################
# VARIABLES
####################################
OPTIONS="SETUP STATUS RUN RESET HELP QUIT"
OPTIONS_SETUP="BACK SETUP_DEFAULT SETUP_TABLES"
OPTIONS_TABLE="BACK DUMMY_TABLE IMPORT_TABLE"

####################################
# EXTERNAL FUNCTIONS
####################################
GET="caget -t"
PUT="caput -t"
SETUP_DEFAULT="sis8300llrf-setupDefaults.py"
IMPORT_TABLE="sis8300llrf-importTableFromFile.py"
RUN_FIXED="sis8300llrf-test-runFixedPulses.py"

####################################
# SUB FUNCTIONS
####################################
function get_status {
  bad=0
  val=$($GET $LLRF_SYS:PMS_ACT)
  if [ $val != "NONE" ] ; then
    bad=$(($bad+1))
    echo "PMS ACTIVE!"
  fi
  val=$($GET $LLRF_SYS:PI-I:OVRFLW)
  if [ $val != "None" ] ; then
    bad=$(($bad+1))
    echo "OVERFLOW I-part!"
  fi
  val=$($GET $LLRF_SYS:PI-Q:OVRFLW)
  if [ $val != "None" ] ; then
    bad=$(($bad+1))
    echo "OVERFLOW Q-part!"
  fi
  val=$($GET $LLRF_SYS:VM-CTRL:MAGLIMSTAT)
  if [ $val != "None" ] ; then
    bad=$(($bad+1))
    echo "VM LIMIT ACTIVE!"
  fi
  val=$($GET $LLRF_SYS:SIGMON-STATUS-ILOCK)
  if [ $val -gt 0 ] ; then
    bad=$(($bad+1))
    echo "Signal monito Interlock $val ACTIVE!"
  fi
  val=$($GET $LLRF_SYS:SIGMON-STATUS-PMS)
  if [ $val -gt 0 ] ; then
    bad=$(($bad+1))
    echo "Signal monitor PMS $val ACTIVE!"
  fi
  echo "SYSTEM WARNINGS: $bad"
  val=$($GET $LLRF_SYS)
  echo "SYSTEM STATE:    $val"
  val=$($GET $LLRF_SYS:OPMODE)
  echo "SYSTEM MODE:     $val"
}

function run_fixed_test {
  export SIS8300LLRF_PREFIX=$LLRF_SYS
  export TRLLRF_PREFIX=$LLRF_TR
  echo "Load threshold conf file. Pick one of these:"
  ls "$CONF" | grep -i "$sys".*conf$
  echo -e "Enter file name: \c "
  read file_name
  export conf_file=${file_name:-$DEFAULT_CONF_FILE}
  echo -e "Enter number of pulses to run: \c "
  read pulse_nbr
  export nbr_pulses=${pulse_nbr:-$DEFAULT_NBR_PULSES}
  echo "Running $nbr_pulses-pulses using thresholds from $conf_file, logging the result in $LOG_DIR/$sys"
  $RUN_FIXED $CONF/$conf_file $CONF/log_RMS.conf $LOG_DIR/$sys $nbr_pulses | grep -i "Pulse Count"
}

function setup {
  echo "Load a setup file. Pick one of these:"
  ls $LLRF_SHARES | grep -i "$sys".*txt$
  echo -e "Enter file name: \c "
  read file_name
  $SETUP_DEFAULT $LLRF_SHARES/$file_name 2
}

function setup_table {
  echo "Load a SP:I file. Pick one of these:"
  ls $LLRF_SHARES | grep -i "$sys".*SP.*I.*txt$
  echo -e "Enter file name: \c "
  read file_name
  $IMPORT_TABLE $LLRF-SYS:SP-PT0:I $LLRF_SHARES/$file_name
  echo "Load a SP:Q file. Pick one of these:"
  ls $LLRF_SHARES | grep -i "$sys".*SP.*Q.*txt$
  echo -e "Enter file name: \c "
  read file_name
  $IMPORT_TABLE $LLRF-SYS:SP-PT0:Q $LLRF_SHARES/$file_name
  echo "Load a FF:I file. Pick one of these:"
  ls $LLRF_SHARES | grep -i "$sys".*FF.*I.*txt$
  echo -e "Enter file name: \c "
  read file_name
  $IMPORT_TABLE $LLRF-SYS:FF-PT0:I $LLRF_SHARES/$file_name
  echo "Load a FF:Q file. Pick one of these:"
  ls $LLRF_SHARES | grep -i "$sys".*FF.*Q.*txt$
  echo -e "Enter file name: \c "
  read file_name
  $IMPORT_TABLE $LLRF-SYS:FF-PT0:Q $LLRF_SHARES/$file_name
}

