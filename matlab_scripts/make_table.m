function [table_I_sp_int,table_Q_sp_int,table_I_ff_int,table_Q_ff_int]=make_table(pulse_type,plot_table)

% FW constants
pi_error_length = 32768; %hex2dec('1000')*8;
sp_length = 4096; %hex2dec('0200')*8;
ff_length = 131072; %hex2dec('4000')*8;

k = (1-2*mod(pulse_type,2));
% Input tables SP
table_I_sp = -k *(0:8:8*sp_length-1) + k * (16000+pulse_type*1000);
table_Q_sp = k *(0:8:8*sp_length-1) - k * (16000+pulse_type*1000);
table_id_sp_I = sprintf('table_I_sp_%d.txt',pulse_type);
table_id_sp_Q = sprintf('table_Q_sp_%d.txt',pulse_type);
table_I_sp = table_I_sp/32768;
table_Q_sp = table_Q_sp/32768;
% Input tables FF
table_I_ff = -k * (0:1:pi_error_length-1) + k * (16000+pulse_type*1000);
table_Q_ff = k * (0:1:pi_error_length-1) - k * (16000+pulse_type*1000);
table_id_ff_I = sprintf('table_I_ff_%d.txt',pulse_type);
table_id_ff_Q = sprintf('table_Q_ff_%d.txt',pulse_type);
table_I_ff = table_I_ff/32768;
table_Q_ff = table_Q_ff/32768;

fileID = fopen(table_id_sp_I,'w');
fprintf(fileID,'%d ',table_I_sp);
fclose(fileID);
fileID = fopen(table_id_sp_Q,'w');
fprintf(fileID,'%d ',table_Q_sp);
fclose(fileID);
fileID = fopen(table_id_ff_I,'w');
fprintf(fileID,'%d ',table_I_ff);
fclose(fileID);
fileID = fopen(table_id_ff_Q,'w');
fprintf(fileID,'%d ',table_Q_ff);
fclose(fileID);

table_I_sp_int =floor(table_I_sp*2^15);
table_Q_sp_int =floor(table_Q_sp*2^15);
table_I_ff_int =floor(table_I_ff*2^15);
table_Q_ff_int =floor(table_Q_ff*2^15);

if(plot_table == 1)
    figure(1)
    plot(table_I_sp_int)
    hold on
    plot(table_Q_sp_int,'--g')
    plot(table_I_ff_int,'r')
    plot(table_Q_ff_int,'--')
    hold off
    legend('sp_I','sp_Q','ff_I','ff_Q')
end


