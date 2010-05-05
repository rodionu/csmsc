function [varargout]=lamdesign(varargin)
%Linear Algebraic Method Compensator Design.
%
% [B,A,No,Nu,Du]=LAMDESIGN(N,D,Do) computes the compensator coefficients
% for the Unity Feedback, Cascade Controller Configuration:
%
%           --------     --------
%     + _   | B(s) | u(t)| N(s) |        Y(s)   No(s)         B(s)N(s)
% r(t)-|_|--| ---- |-----| ---- |--y(t)  ---- = ----- = -------------------
%      -|   | A(s) |     | D(s) | |      R(s)   Do(s)   A(s)D(s) + B(s)N(s)
%       |   --------     -------- |
%       ---------------------------      U(s)   Nu(s)
%                                        ---- = ----- = Control Effort
%                                        R(s)   Du(s)
%
% Let k = length(D)-1 = number of poles in the plant.
% If Do contains 2*k - 1 roots (i.e. length(Do) = 2*k), A(s) is type 0.
% If Do contains 2*k roots (i.e. length(Do) = 2*k + 1), A(s) is type 1.
%
%
% [L,M,A,Nu,Du]=LAMDESIGN(N,D,No,Do,R) computes the compensator coefficients
% for the Two Parameter Controller Configuration:
%
%      --------          --------
%      | L(s) |  + _ u(t)| N(s) |         Y(s)   No(s)         N(s)L(s)
% r(t)-| ---- |---|_|----| ---- |---y(t)  ---- = ----- = -------------------
%      | A(s) |   -|     | D(s) | |       R(s)   Do(s)   A(s)D(s) + M(s)N(s)
%      --------    |     -------- |
%                  |     -------- |       U(s)   Nu(s)
%                  |     | M(s) | |       ---- = ---- = Control Effort
%                  ------| ---- |--       R(s)   Du(s)
%                        | A(s) |
%                        --------
%
% length(Do) >= length(D) required (typically they are equal)
%--------------------------------------------------------------------------
% General Notes:
% length(N) < length(D) required (plant must be strictly proper)
% length(No) < length(Do) required
% length(Do) - length(No) >= length(D) - length(N) required
%
% No and Do are the numerator and denominator polynomial coefficient
% vectors of the closed-loop system.
%
% N and D are the numerator and denominator polynomial coefficient vectors
% of the plant to be controlled.
%
% R is a vector of polynomial root locations that are chosen from in the
% two parameter design process on an as needed basis. These are "observer"
% poles that do not appear in No(s)/Do(s).
%
% B,L,M,A are the polynomial coefficient vectors of the compensators.
%
% Nu and Du are the polynomial coefficient vectors of the numerator and
% denominator of the Control Effort transfer function.
%
% References:
% C.T. Chen, Linear System Theory and Design, 3rd ed., Oxford University
% Press, 1999, ISBN 0-19-511777-8.
%
% C.T. Chen and B. Seo, "The Inward Approach in the Design of Control
% Systems," IEEE Trans. on Education, vol. 33, no. 3, Aug. 1990, pp. 270-8.
%
% C.T. Chen, "Introduction to the Linear Algebraic Method for Control
% System Design," IEEE Control Systems Magazine, Oct. 1987, pp. 36-42.

% D.C. Hanselman, University of Maine, Orono, ME 04469
% Mastering MATLAB 7
% 2005-03-17, 2006-04-20, 2006-05-04
% 2008-03-28, 2009-03-24

msgid='LAMDESIGN:error';
%--------------------------------------------------------------------------
if nargin==3                      % LAMDESIGN(N,D,Do) Unity Feedback Design
   N=local_ispoly(varargin{1});
   nn=length(N)-1;
   D=local_ispoly(varargin{2});
   nd=length(D)-1;
   Do=local_ispoly(varargin{3});
   ndo=length(Do)-1;
   if nn>=nd
      error(msgid,'The Plant Must be Strictly Proper, length(N) < length(D).')
   end
   if ndo==2*nd-1                % standard case, Type 0 A(s)
      S=local_silvester(N,D);
      p=S\Do';
      A=p(1:nd).';
      B=p(nd+1:end).';
   elseif ndo==2*nd              % make system Type 1 A(s)
      S=local_silvestor1(N,D);
      p=S\Do';
      A=[p(1:nd).' 0];
      B=p(nd+1:end).';
   elseif ndo<2*nd-1
      error(msgid,'Do must have at least %d more poles.',2*nd-1-ndo)
   elseif ndo>2*nd
      error(msgid,'Do must have at least %d fewer poles.',ndo-2*nd)      
   end
   No=conv(B,N);
   [Nu,Du]=local_minreal(conv(B,D),Do);
   [varargout{1:5}]=deal(B,A,No,Nu,Du);   
   
elseif nargin==5              % LAMDESIGN(N,D,No,Do,R) Two Parameter Design
   N=local_ispoly(varargin{1});
   nn=length(N)-1;
   D=local_ispoly(varargin{2});
   nd=length(D)-1;
   No=local_ispoly(varargin{3});
   nno=length(No)-1;
   Do=local_ispoly(varargin{4});
   ndo=length(Do)-1;
   if isnumeric(varargin{5}) && isreal(varargin{5})
      R=varargin{5}(:);
   else
      error(msgid,'R Must be a Vector of Real Root Locations.')
   end
   nr=length(R);
   if nn>=nd
      error(msgid,'The Plant Must be Strictly Proper, length(N) < length(D).')
   elseif ndo-nno < nd-nn
      error(msgid,'length(Do) - length(No) Must be at Least %d',nd-nn)
   end
   Ntmp=local_minreal(N,No); % check retainment of non-min-phase-zeros
   if any(real(roots(Ntmp))>0)
      error(msgid,'No Must Contain the Right Half Plane Zeros of N.')
   end   
   [Np,Dp]=local_minreal(No,conv(Do,N));
   p=length(Dp)-1;
   if p < 2*nd-1
      r=2*nd-1-p;
      if nr<r
         error(msgid,'%d More Roots Needed in R.',r-nr)
      end
      Dpb=poly(R(1:r));
   elseif p==2*nd-1
      Dpb=1;
   else
      error(msgid,'Do is too large or No does not contain enough roots of N.')
   end
   L=conv(Np,Dpb);
   S=local_silvester(N,D);
   F=conv(Dp,Dpb).';
   p=S\F;
   A=p(1:nd).';
   M=p(nd+1:end).';
   [Nu,Du]=local_minreal(conv(L,D),F');
   [varargout{1:5}]=deal(L,M,A,Nu,Du);   
else
   error(msgid,'Incorrect Number of Input Arguments.')
end
%--------------------------------------------------------------------------
function P=local_ispoly(arg)
msgid='LAMDESIGN:error';
if isnumeric(arg) && isreal(arg) && min(size(arg))==1
   P=arg(:).';
   idx=find(abs(P)>1e-12,1);  % trim leading zeros
   if isempty(idx)
      error(msgid,'Input Must be a Row Vector of Real-valued Polynomial Coefficients.')
   end
   P=P(idx:end);
else
   error(msgid,'Input Must be a Row Vector of Real-valued Polynomial Coefficients.')
end
%--------------------------------------------------------------------------
function S=local_silvester(N,D)
msgid='LAMDESIGN:error';
N=N(:);
nn=length(N);
D=D(:);
nd=length(D);
if nn<nd
   N=[zeros(nd-nn,1);N];
end
n=nd-1;
S=zeros(2*n);
for k=1:n
   S(k:k+n,k)=D;
   S(k:k+n,k+n)=N;
end
if condest(S)>1e13
   error(msgid,'Plant Must Not Have Any Uncanceled Equal Poles and Zeros.')
end
%--------------------------------------------------------------------------
function S=local_silvestor1(N,D)
msgid='LAMDESIGN:error';
N=N(:);
nn=length(N);
D=D(:);
nd=length(D);
if nn<nd
   N=[zeros(nd-nn,1);N];
end
n=nd-1;
S=zeros(2*nd-1);
for k=1:n
   S(k:k+n,k)=D;
   S(k:k+n,k+n)=N;
end
S(end-n:end,end)=N;
if condest(S)>1e10
   error(msgid,'Plant Must Not Have Any Uncanceled Equal Poles and Zeros.')
end
%--------------------------------------------------------------------------
function [nm,dm]=local_minreal(num,den)
tol=1e-5;
tol0=sqrt(eps);
z=roots(num);
p=roots(den);
nz=length(z);
zm=true(nz,1);
for i=1:nz
	if abs(z(i)>tol0)
		TOL=tol*abs(z(i));
	else
		TOL=tol;
	end
	match=find(abs(p-z(i))<=TOL);
	if ~isempty(match)
		p(match(1))=[]; % throw out matching pole
		zm(i)=false; % flag zero for elimination
	end
end
z=z(zm);
nm=real(num(1)*poly(z)/den(1));
dm=real(poly(p));