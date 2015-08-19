source $(LLRF_CUSTOM_LOGIC_PATH)/LLRF_test_func_const.sh
echo "hello"
screen -S matlabSession1 -X stuff $'matlab -nodesktop -nosplash\n'
print_state
save_input_to_file
matlab_plot
exit
