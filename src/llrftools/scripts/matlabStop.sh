screen -S matlabSession1 -X stuff $'exit\n'
screen -S matlabSession1 -X stuff $'screen -X -S matlabSession1 quit\n'
exit
