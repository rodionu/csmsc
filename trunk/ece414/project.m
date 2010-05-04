% Plant transfer function (found through Simulink) - should be negatized

s = tf('s');
%Plant model for MOTOR 1
%G = tf((-3.348e4*s^2+3.164e-9*s-2.938e5)/(s^5+320.1*s^4+3.579e4*s^3));
%Plant model for MOTOR 3 (used)
gze = [0+2.9624*j 0-2.9624*j];
gdp = [0 0 0 -451.8660 -81.5204];

G = zpk(gze,gdp,1);
C = ;               %Compensator

F = tf(1/(s+1));
H = tf(1);
L = G*C*F;      %Forward path gain
T = L/(1+G*H);  %CLTF

