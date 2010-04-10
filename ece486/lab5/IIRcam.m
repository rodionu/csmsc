%ECE 486 Lab 5
%Group Members: Dylan Godwin, Mark Hebert, Joel Castro, Cameron McGary
%4/7/2010
%Description: This MATLAB script is used to design IIR filter 

clf

%% Filter Design Section
%Uncomment different design types to switch between

%Define filter order, frequency, stopbands
Fs = 50e3;
N = 8*1024;
n = 7;                               %Filter order
Wn = [12.295e3/(Fs/2) 15.005e3/(Fs/2)]; %Passband is wn1 < passband < wn2

% %Butterworth
% [b, a] = butter(n, Wn);

%Elliptical
%[b,a] = ellip(n,Rp,Rs,Wp,'ftype')
%N = filter order, Filter order will be 2N if band-pass
%Rp = passband ripple (peak to peak, dB)
%Rs = Minimum stopband attenuation (dB)
%Wp = band-limiter, if Wp is 2 element, will create a pass/stopband filter

[b, a] = ellip(n, .2, 70.2, Wn);


% %Chebyshev 1
% %[b,a] = cheby1(n,R,Wp,'ftype') %R = ripple in passband (dB)
% [b,a] = cheby1(n, .2, Wn);

% %Chebyshev 2
% %[b,a] = cheby2(n,R,Wp,'ftype') %R = stopband ripple (dB)
% [b,a] = cheby2(n, 70.05, Wn);


f = (0:N-1)/N;
f(N/2+1+1:end) = f(N/2+1+1:end)-1;  %Split function in half
H = fft(b,N)./fft(a,N); %Creates the transfer function




%% Plots Section

%%Patch in desired response gain 
figure(1)
%Patch in PASSBANDS
patch([12.3e3/Fs 12.3e3/Fs 15e3/Fs 15e3/Fs], [-.2 .2 .2 -.2], 'g');
hold on

%Patch in STOPBANDS
patch([0 0 11.5e3/Fs 11.5e3/Fs], [-80 -70 -70 -80], 'r');
patch([16e3/Fs 16e3/Fs .5 .5], [-80 -70 -70 -80], 'r');
hold on
% Plot Frequency Response
plot(f, 20*log10(abs(H)));
xlabel('Normalized Frequency')
ylabel('H(f) (dB)')
title('Frequency Response')
grid on;
axis([0 .5 -80 10])

%Plot Impulse Response
figure(2)
subplot(1,2,1)
impz(b,a)

%Plot Poles/Zeros
subplot(1,2,2)
zplane(b,a)





