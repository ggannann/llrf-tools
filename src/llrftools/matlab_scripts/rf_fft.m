function [max_signal_power, at_freq]=rf_fft(channel)

[in_ch,memory]=load_data(1023); %all channels enabled
[r,c]   = size(in_ch{channel});
samp    = reshape(in_ch{channel}(:,[2 1])',r*c,1);
figure(12)
plot(samp)
figure(13)
signal_power=20*log10(abs(fft(samp)));
freq=[1:length(samp)]*96.25e6/length(samp);
plot(freq,signal_power);
[max_signal_power,ind] = max(signal_power);
at_freq = freq(ind);



