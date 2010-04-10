%ECE 486 Lab 5
%Group Members: Dylan Godwin, Mark Hebert, Joel Castro, Cameron McGary
%4/7/2010
%Description: This MATLAB script is used to design FIR filter using either
%               a Chebychev window or Kasier window. 

clf
figure(1);
subplot(2,1,1)

%%Patch in desired response gain 

%Patch in PASSBANDS
patch([0 0 .07 .07], [-.1 .1 .1 -.1],'g'); %x,y, clockwise around shape
hold on

%Patch in STOPBANDS
patch([.13 .13 .5 .5], [-90 -80 -80 -90], 'r');
hold on

%FIR Filter order and number of samples
N = 8*1024;     
M = 72;     %filter order - THIS IS WHAT DETERMINES THE COST OF THE FILTER

f = (0:N-1)/N;    %Normalize all frequencies

f(N/2+1+1:end) = f(N/2+1+1:end)-1;  %Split function in half

%Set Ideal Transfer Function
Hd = (abs(f) < .0939) .* 10.^(.093/20);

     
%Make Hd function causal -(split to make the linear phase filter)
Hd = Hd .* exp(-j*2*pi*f*(M-1)/2);
 
%Inverse FFT to get impulse response
hd = ifft(Hd);          %Inverse fast fourier transform

%Window Function Choice (Kaiser or Chebychev)

% %Kaiser
% alpha = 8; %Variable for Kaiser
% h = hd(1:M).*Kaiser(M,alpha)';

%Chebychev
R = 68;    %Variable for Chebwin
h = hd(1:M).*chebwin(M,R)';

%Plot impulse response with window
subplot(2,1,2)
stem(h)
xlabel('Sample Number')
ylabel('h')
title('Impulse Response with Window')

%Plot magnitude of response (discrete time with FFT)
H = fft(h,N);
subplot(2,1,1)
plot(f,20*log10((abs(H))));
title('Frequency Response')
xlabel('Discrete Frequency')
ylabel('H(f)')
axis([0 .5 -90 10])

