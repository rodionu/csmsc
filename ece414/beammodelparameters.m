% beammodel parameters

% these variables are in the dialog boxes for various blocks
% SIMULINK looks to MATLAB for variables it doesn't know,
% so if this m-file is run before a simulation the data goes to the right
% places.

% change and add to these parameters as needed

% physical constants
g= 9.8; % gravity
R = 0.5; % ball radius in cm
r = 0.3; % rolling radius of ball in cm

% typical motor parameters
Jm = 5e-5;
Bm = 3e-6;
Kt = 0.125;
Rm = 4;
Lm = 7.5e-3;

% other parameters
Jg = 5.2e-6;
Js = 1.4e-6;
Gv = 4;
Vlim = 50; % voltage limit on power amplifier output
Ks = 10; % position sensor volts per meter
Xquant = 0.01; % (0.1v/cm)*(1cm/10mm) = 0.01v/mm position quantization volts
Tquant = 2*pi/1024; % theta quantization

% gear box ratio
N = 100; % between 10 and 500

% add other things you need to add?

% initial conditions
theta_o = 0.1; % initial track tilt in radians
x_o = 0.25; % initial ball position on track

% computed parameters
K = (2/5)*(R/r)^2; % factor multiplying angular acceleration
M = 1 + (2/5)*(R/r)^2; % factor multiplying linear acceleration

Jeff= Jm + Jg + Js; % effective inertia (add ball and track here)

s = tf('s');
Gnum = ((-4*Kt*g)/(Lm*s*Jeff*s*s*N*M*s*s));
Gden = (1+((1/Lm)*(Rm/s)+Bm/(Jeff*s)+(Kt*Kt)/(Lm*s*Jeff*s))+(R*Bm)/(Lm*s^2*Jeff));
G = tf(Gnum/Gden);
G = minreal(G);

ck = -100;
C = zpk([-1 -1 -1],[-3 -3 -3],1);
Cn = zero(C)';
Cd = pole(C)';


