function plot_internal_signals(in_ch,N,angle_offset,sp_I,sp_Q,beam_ind)

plot_cmd{3} = 'r';
plot_cmd{4} = '-';
plot_cmd{5} = 'r-.';
plot_cmd{6} = 'g-.';
plot_cmd{7} = 'k';
plot_cmd{8} = '*c';
plot_cmd{9} = 'c';
plot_cmd{10} = 'm';
% IQ plots
plot_cmd{13} = 'kc';
plot_cmd{14} = 'kd';
plot_cmd{15} = 'r+';
plot_cmd{16} = '';
plot_cmd{17} = 'kd';
plot_cmd{18} = '*';
plot_cmd{19} = '*c';
plot_cmd{20} = '*m';

signal_type{7} = 'Cav IQ';
signal_type{8} = 'PI input';
signal_type{9} = 'VM input';
signal_type{10} = 'VM output';


start_ind=(min(find(in_ch{3}(1:200)~=0)));
offset{3} = start_ind;		%51+N;
start_ind=(min(find(in_ch{4}(1:200)~=0)));
offset{4} = start_ind;	%49+N;
start_ind=(min(find(in_ch{5}(1:200)~=0)));
offset{5} = start_ind;	%49+N;
start_ind=(min(find(in_ch{6}(1:200)~=0)));
offset{6} = start_ind;	%49+N;
start_ind=(min(find(in_ch{7}(1:200)~=0)));
offset{7} = start_ind;	%49+N;
start_ind=(min(find(in_ch{8}(1:200)~=0)));
offset{8} = start_ind;	%50+N;
start_ind=(min(find(in_ch{9}(1:200)~=0)));
offset{9} = start_ind;		%82+N;
start_ind=(min(find(in_ch{10}(1:200)~=0)));
offset{10} =start_ind;		%82+N;

disp(sprintf('* Internal signals:'))
disp(sprintf('****************************************************************************************'))


%%%%%%%%%%%%%%%%
% Set-point
%%%%%%%%%%%%%%%%

nbr_of_samples = floor(length(in_ch{7})/N);

% MA
figure(7)
subplot(2,1,1)
sp_ang = angle(sp_I+j*sp_Q)/(2*pi)*360;
sp_mag = abs(sp_I+j*sp_Q);
plot(sp_mag*ones(1,nbr_of_samples),'g')
hold on

%Magnitude
for i=3:10
    if i==7 || i==8 || i==9  || i==10
        I = in_ch{i}(offset{i}:N:end-N)';
        Q = in_ch{i}(offset{i}+1:N:end-N+1)';
        mag = abs(complex(I,Q));
        plot(mag,plot_cmd{i});
    end
end
%ang = in_ch{i}(offset{i}+1:N:end)'./2^13/(2*pi)*360;
hold off;
legend('set-point','cavity','to\_pi\_ctrl','to\_VM\_ctrl','to\_DAC')
title('Magitude')
ylabel('16-bit value')
xlabel('sample')

%Angle
subplot(2,1,2)
plot(sp_ang*ones(1,nbr_of_samples),'g')
hold on
plot(angle_offset/(2*pi)*360*ones(1,nbr_of_samples),'--')
for i=4:10
    if i==7 || i==8 || i==9 || i==10
        I = in_ch{i}(offset{i}:N:end-N)';
        Q = in_ch{i}(offset{i}+1:N:end-N+1)';
        ang = angle(complex(I,Q))/(2*pi)*360;
        ang(find(ang>=180)) = ang(find(ang>=180)) - 360;
        ang(find(ang<-181)) = ang(find(ang<-181)) + 360;
        plot(ang,plot_cmd{i});
    end
end
hold off;
legend('set-point','Angle-offset','cavity','to\_pi\_ctrl','to\_VM\_ctrl','to\_DAC')
title('Angle')
xlabel('sample')
ylabel('[deg]')


% IQ
figure(8)
ang = 0:0.01:2*pi;
magn = 2^15;
plot(magn*cos(ang),magn*sin(ang),'-k');
hold on
plot(magn*3/4*cos(ang),magn*3/4*sin(ang),'--k');
plot(magn/2*cos(ang),magn/2*sin(ang),'-.k');
plot(magn/4*cos(ang),magn/4*sin(ang),':k');
plot(complex(sp_I,sp_Q),'g*')
title('IQ')
disp(sprintf('SNR values:'))
bm=beam_ind(1:end-10);
for i=[7,8,9,10]
    re = in_ch{i}(offset{i}:N:end-N)';
    im = in_ch{i}(offset{i}+1:N:end-N+1)';
    iq = complex(re,im);
    plot(iq,plot_cmd{i+10});
    s=iq(bm);
    n=iq(bm)-mean(iq(bm));
    snr_v(i)=20*log10(abs(mean(s))/abs(std(n)));
end
disp(sprintf(' %s,\tSNR: %0.1f',signal_type{7},snr_v(7)))
disp(sprintf(' %s,\tSNR: %0.1f,\timprovement: %0.1f',signal_type{8},snr_v(8),snr_v(8)-snr_v(7)))
disp(sprintf(' %s,\tSNR: %0.1f',signal_type{9},snr_v(9)))
disp(sprintf(' %s,\tSNR: %0.1f',signal_type{10},snr_v(10)))
disp(sprintf('**********************************'))

legend('Max Mag','0.75 Mag','0.5 Mag','0.25 Mag','set-point','Cavity','PI\_input','VM\_ctrl\_input','VM\_ctrl\_output')
hold off
grid on
axis equal


% Ref angle distribution
figure(9)
x = [-1:0.005:1];

% PI error distribution
% Error (PI_in - SP) in procent and degrees durring beam
I = in_ch{8}(offset{8}:N:end-N)';
Q = in_ch{8}(offset{8}+1:N:end-N+1)';
mag = abs(complex(I,Q)) - sp_mag;
ang = angle(complex(I,Q))/(2*pi)*360 - sp_ang;
beam_ind = beam_ind(1:end-8);
mag_err = mag(beam_ind)/2^15*100;
%mag_err = mag_err(1:end-8);
ang_err = ang(beam_ind);
%ang_err = ang_err(1:end-8);
ang_err(find(ang_err<-181))=ang_err(find(ang_err<-181))+360;
ang_err(find(ang_err>=180))=ang_err(find(ang_err>=180))-360;

% PI error Mag %
subplot(2,1,1)
disp(sprintf('PI Error Mag: Mean = %0.4f, Variance = %0.4f, Std_dev = %0.4f, RMS = %0.4f',mean(mag_err),var(mag_err),std(mag_err),rms(mag_err)))
[xo,no] = histnorm(mag_err, x, 'plot');
hold on
plot (no, normpdf(no, mean(mag_err), rms(mag_err)), 'r');
hold off
axis([-1,1,0,max(xo)])
title('PI-error Mag (during beam)')
xlabel('[deg]')
ylabel('Normalized hist')
% PI error Ang %
subplot(2,1,2)
disp(sprintf('PI Error Ang: Mean = %0.4f, Variance = %0.4f, Std_dev = %0.4f, RMS = %0.4f',mean(ang_err),var(ang_err),std(ang_err),rms(ang_err)))
[xo,no] = histnorm(ang_err, x, 'plot');
hold on
plot (no, normpdf(no, mean(ang_err), rms(ang_err)), 'r');
hold off
axis([-1,1,0,max(xo)])
title('PI-error Ang (during beam)')
xlabel('[%]')
ylabel('Normalized hist')


