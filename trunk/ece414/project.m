% Plant transfer function (found through Simulink) - should be negatized

s = tf('s');
%Plant model for MOTOR 1
%G = tf((-3.348e4*s^2+3.164e-9*s-2.938e5)/(s^5+320.1*s^4+3.579e4*s^3));
%Plant model for MOTOR 3 (used)
Gz = [0+2.9624j 0-2.9624j];
Gp = [0 0 0 -451.8660 -81.5204];
GzPoly = poly(Gz);
GpPoly = poly(Gp);

G = zpk(Gz,Gp,1);     %ZPK of Plant
%C = tf(1);               %Compensator

Fn = 1;     %Specify these in vector form, 3s^2+2s+1 = [3 2 1]
Fd = s+1;
Hn = 1;
Hd = 1;
Cn = 1;
Cd = 1;


%F = tf(Fn/Fd);  %These lines should NOT be edited, edit above
%H = tf(Hn/Hd);
%C = tf(Cn/Cd);
%L = G*C*F;      %Forward path gain
%T = L/(1+G*H);  %CLTF


%Fz = zero(F);   %Use these normally, unless you have no zero/pole
%Fp = pole(F);
%Hz = zero(H);
%Hp = pole(H);
%Cz = zero(C);
%Cp = pole(C);

[No,Do] = stepshape(4,5,10,2);
T = zpk(-No,-Do,1);
stepinfo(T)
step(T,1,10000);