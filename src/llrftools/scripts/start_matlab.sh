#!/bin/bash

#screen -S matlabSession1
#matlab -nodesktop -nosplash

gnome-terminal --tab -e "/bin/bash -c 'screen -S matlabSession1; exec /bin/bash -i'"
