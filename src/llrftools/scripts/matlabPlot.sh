source /home/eit_ess/development/sis8300_development/custom_logic/LLRF_test_func_const.sh
echo "hello"
screen -S matlabSession1 -X stuff $'matlab -nodesktop -nosplash\n'
print_state
save_input_to_file
matlab_plot
exit
