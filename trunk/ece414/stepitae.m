function varargout=stepitae(n,ts,sp,type)
%STEPITAE System Prototype for ITAE Optimum Step Response.
% STEPITAE(Np,Ts,SP,TYPE) returns a continuous time system that minimizes
%               /inf 
%           J = |( t*|r(t) - y(t)| ) dt
%               /0
% where r(t) is the unit step function system input and y(t) is the
% controlled system output.
% In addition,
% Np is the number of system poles. Np must be between 2 and 8.
% Ts is the desired settling time in seconds.
% SP is the settling time percentage. For example, if SP = 2, Ts specifies
% the 2% settling time. SP must be between 0.1 and 10. If SP is empty or
% not given, SP = 2 is assumed.
% TYPE = 'classic' or 'modern'. 'classic' uses classical ITAE parameters,
% 'modern' uses the greatly improved parameters as given by Y. Cao in
% File Exchange submission #18547. If TYPE is not given, 'modern' is used.
%
% Example: STEPITAE(7,5,1) returns a 7-th order modern ITAE system having a
% 5 second settling time to within 1% of the final value.
%
% [No,Do] = STEPITAE(...) returns the numerator polynomial vector No and
% denominator polynomial Do of the prototype system.
% [Z,P,K] = STEPITAE(...) returns the zeros Z, the poles P, and the gain K
% of the prototype system.
% [A,B,C,D] = STEPITAE(...) returns the state space matrices of the
% prototype system.
% SYS = STEPITAE(...) returns a Control System Toolbox system object SYS
% containing the prototype system.
%
% Algorithm: Given Np, normalized ITAE optimum step response poles are
% found then scaled to match the desired Ts. If Np is even, all poles are
% in complex conjugate pairs. If Np is odd, all poles except one are in
% complex conjugate pairs.
%
% See also TF2SS, TF2ZP, ZP2TF, ZP2SS, SS2TF, SS2ZP, LTITR, LTIVIEW

% References:
% C.T. Chen, Analog and Digital Control System Deisgn: Transfer
% Function, State Space, and Algebraic Methods, Saunders College
% Publishing, ISBN: 0-03-094070-2, 1993.
%
% Y. Cao, "Correcting the minimum ITAE standard forms of 
% zero-displaceemnt-error systems", Journal of Zhejiang University 
% (Natural Science) Vol. 23, N0o.4, pp. 550-559, 1989.

% D.C. Hanselman, University of Maine, Orono, ME 04469
% Mastering MATLAB 7
% 2007-02-26, 2008-02-01

if nargin<2
   error('Two or Three Input Arguments Required.')
elseif nargin==2
   sp=2;
   type='m';
elseif nargin==3
   if ischar(sp)
      type=sp;
      sp=2;
   else
      type='m';
   end
end
if ~isnumeric(n) || numel(n)>1 || fix(n)~=n || n<2 || n>8
   error('Np Must be a Scalar Integer Between 2 and 8.')
end
if ~isnumeric(ts) || numel(ts)>1 || ts<1e-6 || ts>1e6
   error('Ts Must be a Scalar Between 1e-6 and 1e6.')
end
if isempty(sp)
   sp=2;
end
if ~isnumeric(sp) || numel(sp)>1 || sp<0.1 || sp>10
   error('SP Must be a Scalar Between 0.1 and 10.')
end
if ~ischar(type) || ~(strncmpi(type,'m',1)||strncmpi(type,'c',1))
   error('TYPE must be either ''modern'' or ''classic''')
end
itaec={ [1 1.4 1], [1 1.75 2.15 1], [1 2.1 3.4 2.7 1],...
        [1 2.8 5.0 5.5 3.4 1], [1 3.25 6.60 8.60 7.45 3.95 1],...
        [1 4.475 10.42 15.08 15.54 10.64 4.58 1],...
        [1 5.2 12.8 21.6 25.75 22.2 13.3 5.15 1] };
itaem={ [1 1.5053 1], [1 1.7835 2.1719 1], [1 1.9534 3.347 2.6483 1],...
        [1 2.0681 4.4986 4.6745 3.2572 1],...
        [1 2.1518 5.6288 6.9337 6.7924 3.7397 1],...
        [1 2.2172 6.7447 9.3493 11.58 8.6799 4.3233 1],...
        [1 2.2748 7.8487 11.888 17.588 16.116 11.339 4.8153 1] };
if strncmpi(type,'c',1)
   itae=itaec; % classic coefficients
else
   itae=itaem; % modern coefficients
end
p=roots(itae{n-1});     % normalized roots for the chosen order
tsn=local_getts(p,sp);  % get normalized settling time
p=p*tsn/ts;             % scale poles to meet settling time
k=abs(real(prod(p)));
z=[];
% Now have solution in zero-pole-gain form
% convert to form requested and output
if nargout==1                    % SYS
   try
      varargout{1}=zpk(z,p,k);
   catch
      error('Control System Toolbox Required for SYS Output.')
   end
elseif nargout==2                % [N,D]
   [num,den]=zp2tf(z,p,k);
   varargout{1}=num;
   varargout{2}=den;
elseif nargout==3                % [Z,P,K];
   [varargout{1:3}]=deal(z,p,k);
elseif nargout==4                % [A,B,C,D]
   [a,b,c,d]=zp2ss(z,p,k);
   [varargout{1:4}]=deal(a,b,c,d);
end
%--------------------------------------------------------------------------
function ts=local_getts(p,sp)
% Given poles in p find unit step response and Ts spec.
% Since I have the poles and none are repeated, do this the old fashioned
% way, find the residues and simply evaluate the step response.
% From the step response get settling time.

n=length(p);
num=abs(real(prod(p))); % numerator
tend=2*log(sp/100)/max(real(p));      % estimate final time for computation
t=linspace(0,tend,250)';
modes=zeros(length(t),n);                % storage for modes evaluated at t
r=zeros(n,1);
nk=1:n;
for k=1:n
   r(k)=num./(p(k)*prod(p(k)-p(nk~=k)));                     % k-th residue
   modes(:,k)=exp(p(k)*t);             % k-th mode evaluated at time points
end
y=1+real(modes*r);                 % system output is matrix multiplication

idx1=find(abs(y-1)>abs(sp/100),1,'last');
if y(idx1)>1                     % settling time using linear interpolation
   alpha=(y(idx1)-(1+sp/100))/(y(idx1)-y(idx1+1));
   ts=t(idx1)+alpha*(t(idx1+1)-t(idx1));
else
   alpha=((1-sp/100)-y(idx1))/(y(idx1+1)-y(idx1));
   ts=t(idx1)+alpha*(t(idx1+1)-t(idx1));
end
%--------------------------------------------------------------------------