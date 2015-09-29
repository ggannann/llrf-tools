#!/bin/bash

#cd /home/eit_ess/development/sis8300_development/custom_logic
#matlab -desktop &
#cd $LLRF_CL_SOURCES/matlab_scripts
mkdir $LLRF_HOME/matlab
cd $LLRF_HOME/matlab
cp $LLRF_CL_PATH/*.m .
gnome-terminal --tab -e "/bin/bash -c 'screen -S matlabSession1; exec /bin/bash -i'"
gnome-terminal --window-with-profile=Test_LLRF -e LLRF_test_mag_ang.sh

