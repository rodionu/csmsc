% Plant transfer function (found through Simulink) - should be negatized

s = tf('s');
%Plant model for MOTOR 1
%G = tf((-3.348e4*s^2+3.164e-9*s-2.938e5)/(s^5+320.1*s^4+3.579e4*s^3));
%Plant model for MOTOR 3 (used)
G = tf((3.1e4*s^2-1.012e-9*s-2.72e5)/(s^5+533.4*s^4+3.684e4*s^3));
F = tf((s+10)/((s+20+5j)*(s+20-5j)));          %Prefilter
H = tf((s+1)/(s*(s+1)));           %Feedback amp
L = G*F;        %Forward path gain
T = L/(1+G*H);  %CLTF

[num,den] = tfdata(L,'v');
rlocus(num,den,0:.1:1000);