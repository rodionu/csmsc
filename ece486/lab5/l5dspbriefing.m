N = 8*1024;     
M = 91;         %filter order - THIS IS WHAT DETERMINES THE COST OF THE FILTER
alpha = 7;        %This variable can be any number, without sacrificing cost

f = (0:N-1)/N;    %Normalize all frequencies
f(N/2+1+1:end) = f(N/2+1+1:end)-1;  %Split function in half

Hd = ((abs(f)>0.069)&(abs(f)<0.17)).*(10.^(((-5/.08)*(abs(f)-.09)+15)/20)) + ...
     ((abs(f)>=0.17)&(abs(f)<0.24)).*(10.^(((5/.07)*(abs(f)-.17)+10)/20)) + ...
     ((abs(f)>=0.24)&(abs(f)<0.38)).*(10.^(((-5/.11)*(abs(f)-.24)+15)/20));
 
 Hd = Hd .* exp(-j*2*pi*f*(M-1)/2);
 
 %plot(f,(abs(Hd)),'.');
 %plot(f,20*log10((abs(Hd))),'.');
 
 hd = ifft(Hd);         %Inverse fast fourier transform
 %stem(0:N-1, hd, '.');  %Stem plot (discrete sequence plot)
 
 w = kaiser(M, alpha);  %Plot in a Kaiser window, 0-101
 h = (w').*hd(1:M);        %Actually runs the plot
 hold on;
 %stem(0:M-1, h, 'r.');  %Just adding red color
 
 %plot(hd);
 
 H = fft(h, N);
 figure(2); clf;
 patch([0 .04 .04 0], [-70 -70 -55 -55], .8*[1 1 1]);
 patch([.41 .5 .5 .41], [-70 -70 -55 -55], .8*[1 1 1]);
 patch([.09 .17 .24 .35 .35 .24 .17 .09], [14.5 9.5 14.5 9.5 10.5 15.5 10.5 15.5], .8*[1 1 1]);
 hold on;
 plot(abs(f), 20*log10(abs(H)));