#!/bin/bash

if [ ! -d "${LLRF_HOME}/matlab" ]; then
    mkdir $LLRF_HOME/matlab
fi

cd $LLRF_HOME/matlab
cp -f $LLRF_MATLAB_SCRIPTS_PATH/*.m .
gnome-terminal --tab -e "/bin/bash -c 'screen -S matlabSession1; exec /bin/bash -i'"
gnome-terminal --window-with-profile=Test_LLRF -e 'requireExec llrftools,eit_ess -- LLRF_test_mag_ang.sh'

