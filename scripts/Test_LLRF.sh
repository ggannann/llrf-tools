#!/bin/bash

mkdir $LLRF_HOME/matlab
cd $LLRF_HOME/matlab
cp $LLRF_MATLAB_SCRIPTS_PATH/*.m .
gnome-terminal --tab -e "/bin/bash -c 'screen -S matlabSession1; exec /bin/bash -i'"
gnome-terminal --window-with-profile=Test_LLRF -e 'requireExec llrftools,eit_ess -- LLRF_test_mag_ang.sh'

