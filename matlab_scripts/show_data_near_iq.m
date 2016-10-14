function show_data_near_iq(in_ch,memory,mem_type,sp_I,sp_Q,use_scaling,angle_offset,M,N,cav_inp_delay_enable,cav_inp_delay,pulse_start_cnt,pulse_active_cnt,pi_err_samples, debug_adc_ch)
% data: in_ch{1} .. in_ch{10}
plot_cmd{1} = 'o';
plot_cmd{2} = 'r+';
plot_cmd{3} = 'kd';
plot_cmd{4} = 'gd';
plot_cmd{5} = '*';
plot_cmd{6} = 'cp';
plot_cmd{7} = 'xg';
plot_cmd{8} = 'pr';
plot_cmd{9} = '<b';
plot_cmd{10} = '>k';
output_type{1} = 'PI-error';
output_type{2} = 'Cav IQ';
output_type{3} = 'Cav MA';
output_type{4} = 'Ref IQ';
output_type{5} = 'Ref Ang and Cav Ang';
output_type{6} = 'MA to pi-ctrl';
output_type{7} = 'VM-ctrl MA';
output_type{8} = 'VM-ctrl IQ';

disp(sprintf('****************************************************************************************'))

Fs=88.0525e6; % Sample frequency used for SNR calculations

%%%%%%%%%%%%%%%%
% Sample indexes
%%%%%%%%%%%%%%%%
[r,c]   = size(in_ch{1});
nbr_iq_samp_mem = floor(r*c/N);
if nbr_iq_samp_mem < pi_err_samples
    pi_err_samples = nbr_iq_samp_mem;
end    
pulse_ind = [1:pi_err_samples];
if pulse_start_cnt > pi_err_samples
  pulse_start_ind = [1:pi_err_samples];
  beam_ind = [pi_err_samples:pi_err_samples-8];
  disp(sprintf('NO BEAM RECORDED!!'))
else
  pulse_start_ind = [1:pulse_start_cnt];
  beam_ind = [pulse_start_cnt+1:pi_err_samples-8];
end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  IQ PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(5)
%hold on
ang = 0:0.01:2*pi;
magn = 2^15;
plot(magn*cos(ang),magn*sin(ang),'-k');
hold on
plot(magn*3/4*cos(ang),magn*3/4*sin(ang),'--k');
plot(magn/2*cos(ang),magn/2*sin(ang),'-.k');
plot(magn/4*cos(ang),magn/4*sin(ang),':k');

%%%%%%%%%%%%%%%%
% Set-point
%%%%%%%%%%%%%%%%
if sp_I > 32767
    sp_I = sp_I - 2^16;
end
if sp_Q > 32767
    sp_Q = sp_Q - 2^16;
end
iq = complex(sp_I,sp_Q);
plot(iq,plot_cmd{5});

near_iq = 2/N*[sin([0:N-1]*2*pi*M/N);cos([0:N-1]*2*pi*M/N)];
%%%%%%%%%%%%%%%%
% input channels
%%%%%%%%%%%%%%%%
disp(sprintf('* Input channels *'))
% cavity
% cavity input delay (to sync cav and ref before phase compansation)
%cav_delay = cav_inp_delay_enable*3 + cav_inp_delay_enable*cav_inp_delay;
%disp(sprintf('Cavity input delay: %d',cav_delay));

[r,c]   = size(in_ch{1});
samp    = reshape(in_ch{1}(:,[2 1])',r*c,1);
[r,c]   = size(samp);
%if cav_delay > 0
%    samp = [zeros(cav_delay,1); samp];
%end
figure(10)
subplot(2,1,1)
[SNR_cav_samp]=snr_plot(samp(N*pulse_start_cnt:N*pi_err_samples-10),Fs,1,0,N);
title('PSD - Cavity signal')
grid on
figure(5)
%samp_iq = reshape(samp(1:floor((r+cav_delay)/N)*N),N,floor((r+cav_delay)/N));
samp_iq = reshape(samp(1:floor(r/N)*N),N,floor(r/N));
i_q     = near_iq*samp_iq;
iq_cav  = complex(i_q(1,:),i_q(2,:));
figure(14)
subplot(3,1,1)
snr_plot(iq_cav(beam_ind),Fs/N,1,1,N);
title('PSD - IQ Cavity signal')
grid on
figure(5)
plot(iq_cav(pulse_ind),plot_cmd{1});
mag(1)   = mean(abs(iq_cav));
phase(1) = mean(angle(iq_cav))/(2*pi)*360;

% ref_line
samp    = reshape(in_ch{2}(:,[2 1])',r*c,1);
figure(10)
subplot(2,1,2)
[SNR_ref_samp]=snr_plot(samp(N*(pulse_start_cnt+10):N*(pi_err_samples-10)),Fs,1,0,N);
title('PSD - reference signal')
grid on
figure(5)
samp_iq = reshape(samp(1:floor(r/N)*N),N,floor(r/N));
i_q     = near_iq*samp_iq;
iq_ref  = complex(i_q(1,:),i_q(2,:));
figure(14)
subplot(3,1,2)
grid on
snr_plot(iq_ref(beam_ind),Fs/N,1,1,N);
title('PSD - IQ reference signal')
figure(5)
plot(iq_ref(pulse_ind),plot_cmd{2});
mag(2)   = mean(abs(iq_ref));
phase(2) = mean(angle(iq_ref))/(2*pi)*360;
var_phase = var(angle(iq_ref(20:end))/(2*pi)*360);
ref_phase = mean(angle(iq_ref));

%make cav and ref equally long
iq_cav = iq_cav(1:length(iq_ref));

%output    
disp(sprintf('in channel 2 (ref): Magnitude = %0.1f, Phase = %0.2f degrees, Variance = %0.3f',mag(2),phase(2),var_phase))
%%%%%%%%%%%%%%%%
% ADC channels 3-10
% plotted as IQ
%%%%%%%%%%%%%%%%
figure(3)
ang = 0:0.01:2*pi;
magn = 2^15;
plot(magn*cos(ang),magn*sin(ang),'-k');
hold on
plot(magn*3/4*cos(ang),magn*3/4*sin(ang),'--k');
plot(magn/2*cos(ang),magn/2*sin(ang),'-.k');
plot(magn/4*cos(ang),magn/4*sin(ang),':k');
plot(iq_ref(pulse_ind),plot_cmd{2});
legend_info{1}='Max Mag';
legend_info{2}='Mag 0.75';
legend_info{3}='Mag 0.5';
legend_info{4}='Mag 0.25';
legend_info{5}='in ch 2 (Reference)';
debug_channels=[0 0 3*bitand(debug_adc_ch,1) 4*bitand(debug_adc_ch,1) 5*bitand(debug_adc_ch,2)/2 6*bitand(debug_adc_ch,2)/2 7*bitand(debug_adc_ch,4)/4 8*bitand(debug_adc_ch,4)/4 9*bitand(debug_adc_ch,8)/8 10*bitand(debug_adc_ch,8)/8];
i=1;
for g=3:10
    if debug_channels(g)==0
        samp    = reshape(in_ch{g}(:,[2 1])',r*c,1);
        samp_iq = reshape(samp(1:floor(r/N)*N),N,floor(r/N));
        i_q     = near_iq*samp_iq;
        iq = complex(i_q(1,:),i_q(2,:));
        plot(iq(pulse_ind),plot_cmd{g});
        str_adc=sprintf('ADC %d',g);
        legend_info{5+i}=str_adc;
        i=i+1;
    end
end
hold off
legend(legend_info)
title('Additional ADC input channels')
grid on
axis equal
ylabel('Q')
xlabel('I')
figure(5)

%%%%%%%%%%%%%%%%
% input cavity plus dc-offset, minus ref phase
% input ref plus dc-offset
%%%%%%%%%%%%%%%%
if use_scaling == 0
    angle_offset = 0;
end
cav_mag = abs(iq_cav);
cav_phase = angle(iq_cav) - angle(iq_ref) + angle_offset;
[icav,qcav] = pol2cart(cav_phase,cav_mag);
iq_cav_comp = complex(icav,qcav);
plot(iq_cav_comp(pulse_ind),plot_cmd{6});

figure(14)
subplot(3,1,3)
snr_plot(iq_cav_comp(beam_ind),Fs/N,1,1,N);
grid on
title('PSD - IQ cav comp durring beam')

figure(38)
subplot(2,1,1)
snr_plot(abs(iq_cav_comp(beam_ind)),Fs/N,1,1,N);
title('PSD - IQ cav comp MAG')
grid on
subplot(2,1,2)
snr_plot(angle(iq_cav_comp(beam_ind)),Fs/N,1,1,N);
title('PSD - IQ cav comp PHASE')
grid on

figure(5)


s=iq_cav(beam_ind);
n=iq_cav(beam_ind)-mean(iq_cav(beam_ind));
snr_cav=20*log10(abs(mean(s))/abs(std(n)));
s=iq_ref(beam_ind);
n=iq_ref(beam_ind)-mean(iq_ref(beam_ind));
snr_ref=20*log10(abs(mean(s))/abs(std(n)));
s=iq_cav_comp(beam_ind);
n=iq_cav_comp(beam_ind)-mean(iq_cav_comp(beam_ind));
snr_cav_comp=20*log10(abs(mean(s))/abs(std(n)));
disp(sprintf('* SNR values, base on raw samples*'))
disp(sprintf('  Reference input SNR_ref_samp: %0.1f',SNR_ref_samp))
disp(sprintf('  Reference input SNR_ref_IQ  : %0.1f,\t Improvement: %0.1f',snr_ref,snr_ref-SNR_ref_samp))
disp(sprintf('  Reference input SNR_cav_samp: %0.1f',SNR_cav_samp))
disp(sprintf('  Reference input SNR_cav_IQ  : %0.1f,\t Improvement: %0.1f',snr_cav,snr_cav-SNR_cav_samp))
disp(sprintf('  Reference input SNR_cav_comp: %0.1f,\t Improvement: %0.1f',snr_cav_comp, snr_cav_comp-snr_cav))
disp(sprintf('*********************************************'))


ref_mag = abs(iq_ref);
ref_phase = angle(iq_ref);
figure(4)
subplot(2,1,1)
plot(cav_mag)
hold on
plot(ref_mag,'r')
plot(pulse_start_cnt,[16384],'g*')
hold off
legend('Cav comp','Ref','Beam start')
title('Magitude')
ylabel('16-bit value')
xlabel('sample')
subplot(2,1,2)
cav_phase=cav_phase/(2*pi)*360;
cav_phase(cav_phase>=180)=cav_phase(cav_phase>=180) - 360;
cav_phase(cav_phase<-181)=cav_phase(cav_phase<-181) + 360;
plot(cav_phase)
hold on
plot(ref_phase/(2*pi)*360,'r')
plot(pulse_start_cnt,[0],'g*')
hold off
legend('Cav comp','Ref','Beam start')
title('Phase')
ylabel('[degrees]')
xlabel('sample')
figure(5)


%%%%%%%%%%%%%%%%
% cav and ref compensated and stable
%%%%%%%%%%%%%%%%
[r,c] = size(iq_cav_comp);
mag(1)   = mean(abs(iq_cav_comp(:,beam_ind)));
phase(1) = mean(angle(iq_cav_comp(:,beam_ind)))/(2*pi)*360;
disp(sprintf('PI input during beam: Mag = %0f, Phase = %0.2f degrees',mag(1),phase(1)))
mag(2)   = mean(abs(iq_ref(:,beam_ind)));
phase(2) = mean(angle(iq_ref(:,beam_ind)))/(2*pi)*360;


%%%%%%%%%%%%%%%%
% output data
%%%%%%%%%%%%%%%%
disp(sprintf('******************'))
disp(sprintf('* Output data *'))
disp(sprintf('******************'))
if mem_type==0
    % IQ ERROR
    Q = memory(1:end,2)';
    I = memory(1:end,1)';
    iq = complex(I,Q);
    plot(iq(pulse_ind),plot_cmd{3});
    legend('Max Mag','0.75 Mag','0.5 Mag','0.25 Mag','Fixed Set-Point','in ch 1 (Cavity)','in ch 2 (Reference)','in ch 1 (Compensated)',output_type{mem_type+1})
    disp(output_type{mem_type+1})
    iq = complex(I+sp_I,Q+sp_Q);
    sp_mag = abs(sp_I+j*sp_Q);
    mag_err = (abs(iq)-sp_mag)./2^15*100;
    % move ang to setpoint
    iq = complex(I+sp_I,Q+sp_Q);
    ang_err = angle(iq)*360/(2*pi) - angle(complex(sp_I,sp_Q))*360/(2*pi);
    disp(sprintf('  Magnitude error(%%): Mean = %0.4f, Var = %0.4f, Std = %0.4f, RMS = %0.4f',mean(mag_err(beam_ind)),var(mag_err(beam_ind)),std(mag_err(beam_ind)),rms(mag_err(beam_ind))))
    disp(sprintf('  Phase error (deg) : Mean = %0.4f, Var = %0.4f, Std = %0.4f, RMS = %0.4f',mean(ang_err(beam_ind)),var(ang_err(beam_ind)),std(ang_err(beam_ind)),rms(ang_err(beam_ind))))
end
hold off
grid on
axis equal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  TIME PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[r,c]=size(memory);
d1=memory(:,1)';
d2=memory(:,2)';
if mem_type == 0
    % Normalized I and Q to +-100 %
    d1 = d1./2^15*100;
    d2 = d2./2^15*100;
    output_type_t{1} = 'PI-error I [%]';
    output_type_t{2} = 'PI-error Q [%]';
end

figure(6)
subplot(2,1,1)
plot(d1,'')
xlabel('sample');
ylabel('value')
legend(output_type_t{1})
subplot(2,1,2)
plot(d2,'')
xlabel('sample');
ylabel('value')
legend(output_type_t{2})

disp(sprintf('****************************************************************************************'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DEBUG PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sum(debug_channels)>0
  plot_internal_signals(in_ch,N,angle_offset,sp_I,sp_Q,beam_ind,debug_channels)
end
