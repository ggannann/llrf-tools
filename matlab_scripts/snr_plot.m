function [SNR]=snr_plot(x,Fs,pl,iq_p,N_iq);


if iq_p==0
    SNR = snr(x,Fs);
else
    SNR = -9999;
end
if pl==1
    N = floor(length(x)/N_iq)*N_iq;
    xdft = fft(x,N);
    xdft = xdft(1:floor(N/2)+1);
    psdx = (1/(Fs*N)) * abs(xdft).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);
    freq = 0:Fs/N:Fs/2;
    psdx_log=10*log10(psdx);
    plot(freq/1000000,psdx_log,'b')
    F_s = freq(find(psdx_log==max(psdx_log)));
    xlabel('f [MHz]')
    ylabel('power [dB]')
end

% hold on
% ps=20*log10(abs(fft(x,N)));
% ps=ps-mean(ps);
% f=[0:Fs/N:Fs*(N-1)/N];
% plot(f(1:N/2),ps(1:N/2),'--');
% SNR2 = max(ps(1:N/2))
% F_S = f(find(ps(1:N/2)==max(ps(1:N/2))))
