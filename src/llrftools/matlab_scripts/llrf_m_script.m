% Fri Aug 14 10:37:42 CEST 2015 

 in_ch_enable=1023;

 sp_I=24576;

 sp_Q=0;

 N=11;

 M=4;

 use_scaling=1;

 angle_offset=-2.094528;

 cav_inp_delay_enable=1;

 cav_inp_delay=14;

 filter_s=0.009425;

 filter_c=0.999956;

 filter_a=0.199997;

 Filter_start=1;

 Filter_stop=0;

 Filter_on=0;

 pulse_start_cnt=3680;

 pulse_active_cnt=25524;

 pi_err_samples=29204;

 mem_type=0;

 [in_ch,memory]=load_data(in_ch_enable);

 show_data_near_iq(in_ch,memory,mem_type,sp_I,sp_Q,use_scaling,angle_offset,M,N,cav_inp_delay_enable,cav_inp_delay,pulse_start_cnt,pulse_active_cnt,pi_err_samples)
