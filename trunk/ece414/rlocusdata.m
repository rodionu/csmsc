function s=rlocusdata(bz,ap)
%RLOCUSDATA Compute Academic Root Locus Data.
% S = RLOCUSDATA(B,A) computes K > 0 root locus data of interest in control
% system classes. If A and B are ROW vectors, they are assumed to be
% polynomials such that the system characteristic equation is
% Delta(s) = A(s) + K*B(s) = 0 or 1 + K*B(s)/A(s) = 0.
%
% S = RLOCUSDATA(Z,P) where Z and P are COLUMN vectors assumes that Z and P
% are polynomial roots such that the system characteristic equation is
% Delta(s)= poly(P) + K*poly(Z) = 0 or Delta(s)= 1 + K*poly(Z)/poly(P) = 0.
% In other words poly(P) = A and poly(Z) = B. If B is a constant, Z = [].
%
% Combinations of the above inputs are accepted, e.g., RLOCUSDATA(B,P) and
% RLOCUSDATA(Z,A). Note that if B is a scalar value, it is assumed to be a
% root. Use B = [0 K] if B is equal to the scalar K.
%
% RLOCUSDATA(TF) uses the Control Toolbox transfer function object TF.
% RLOCUSDATA(ZPK) uses the Control Toolbox zero-pole-gain object ZPK.
%
% The output S is a structure containing fieldnames that describe the
% computed results.
%
% S.zeros = Z roots of B
% S.poles = P roots of A
% S.num = B polynomial
% S.den = A polynomial
%
% S.asymangle = vector containing asymptote angles if they exist.
% S.asymsigma = vector containing asymptote real axis intersections.
%
% S.breaks = vector containing real axis breakaway and break in points.
% S.breakk = vector containing K values for corresponding S.breaks values.
%
% S.jwcross = frequency where root locus crosses the jw axis.
% S.jwcrossk = value of K corresponding to S.jwcross.
%
% S.depangle = vector containing departure angles from complex roots in P.
% S.deproot = vector of roots associated with S.depangle values.
% S.arrangle = vector containing arrival angles to complex roots in Z.
% S.arrroot =  vector of roots associated with S.arrangle values.
%
% S.chareqn = function handle that computes roots of the characteristic
% equation for a single value of K,e.g., S.chareqn(k) finds the roots for K.
%
% This function is for academic use. It finds at most one jw axis crossing
% and the breakaway or break in points may not be complete or may
% occasionally contain spurious results. This function assumes that K > 0.

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2006-03-08, 2006-05-05, 2007-02-16, 2008-02-26

ta={180,[-90 90],[-60 60 180],[-135 -45 45 135],...
   [-108 -36 36 108 180], [-120 -90 -30 30 90 120]};
s=struct('zeros',[],'poles',[],'num',[],'den',[],...
   'asymangle',[],'asymsigma',[],'breaks',[],'breakk',[],...
   'jwcross',[],'jwcrossk',[],'depangle',[],'deproot',[],...
   'arrangle',[],'arrroot',[],'chareqn',[]);

if nargin==1 && (isa(bz,'tf') || isa(bz,'zpk'))  % LTI object input
   [num,den]=tfdata(bz);
   bz=num{1};
   idx=find(bz~=0);
   bz=bz(idx(1):end);
   ap=den{1};
elseif nargin~=2
   error('Two Input Arguments Required.')
end
sap=size(ap);
sbz=size(bz);
if sap(2)>1 && sap(1)==1 % polynmial row vector for A
   s.den=ap;
   s.poles=roots(ap);
else % roots for A
   s.poles=ap;
   s.den=poly(ap);
end
if sbz(2)>1 && sbz(1)==1 % polynomial row vector for B
   s.num=bz;
   s.zeros=roots(bz);
   if isempty(s.zeros)
      s.num=s.num(end);
   end
else % roots for B
   s.zeros=bz;
   s.num=poly(bz);
end
if sign(s.num(find(s.num~=0,1))) ~= sign(s.den(find(s.den~=0,1)))
   error('K < 0 Root Locus Not Supported.')
end
nn=length(s.num)-1;
nd=length(s.den)-1;
pze=nd-nn; % pole zero excess
s.num=[zeros(1,pze) s.num]; % padd numerator so polynomial addition works.

if pze<0
   error('Denominator must contain at least as many roots as numerator.')
end

% find asymptotes if they exist
if pze>6
   warning('rlocusdata:NA',...
      'Not equiped to compute asymptotes for this problem.')
elseif pze>0
   s.asymangle=ta{pze};
   s.asymsigma=real(sum(s.poles)-sum(s.zeros))/pze;
end

% find breakaway points and breakin points if they exist
[q,tmp]=polyder(-s.den,s.num); %#ok
tmp=roots(q);
s.breaks=tmp(abs(imag(tmp))<1e-6); % only real roots can be breakaway pts.
s.breaks=real(s.breaks);
s.breakk=polyval(-s.den,s.breaks)./polyval(s.num,s.breaks);
s.breaks=s.breaks(s.breakk>0);
s.breakk=s.breakk(s.breakk>0);

% find out if root locus goes into RHP, if so, find crossing
if any(real(s.zeros)>=0) || any(real(s.poles)>=0) ||...
   (~isempty(s.asymsigma)&&s.asymsigma>0) ||...
   length(s.asymangle)>2
   k=10.^(-3:0.25:5);
   km=k(1);
   kp=k(end);
   lrhp=false(1,2);
   for n=1:length(k) % find k values that jump from lhp to rhp
      r=real(roots(s.den+k(n)*s.num));
      if all(r<0)
         km=max(k(n),km);
         lrhp(1)=true;
      elseif any(r>0)
         kp=min(k(n),kp);
         lrhp(2)=true;
      end
   end
   if all(lrhp)      % iterate using bisection to get to jw-axis crossing
      for n=1:1000   % don't let this get in an infinite loop
         k=(km+kp)/2;
         r=real(roots(s.den+k*s.num));
         if all(r<0)
            km=k;
         elseif any(r>1e-6)
            kp=k;
         elseif any(abs(r)<1e-6)
            s.jwcrossk=k;
            r=roots(s.den+k*s.num);
            s.jwcross=imag(max(r(abs(real(r))<1e-6)));
            break
         end
      end
   end
end
% find angles of departure and arrival if they exist
if any(imag(s.poles)>1e-5) % angle of departure exists
   s.deproot=s.poles(imag(s.poles)>1e-5);
   for k=1:length(s.deproot)
      cr=s.deproot(k);
      dd=deconv(s.den,[1 -cr]);
      a=-180+180/pi*(angle(polyval(s.num,cr))-angle(polyval(dd,cr)));
      s.depangle(k)=mod(a+180,360)-180;
   end
end
if any(imag(s.zeros)>1e-5) % angle of arrival exists
   s.arrroot=s.zeros(imag(s.zeros)>1e-5);
   for k=1:length(s.arrroot)
      cr=s.arrroot(k);
      dd=deconv(s.num,[1 -cr]);
      a=180+180/pi*(angle(polyval(s.den,cr))-angle(polyval(dd,cr)));
      s.arrangle(k)=mod(a+180,360)-180;
   end

end
% create function handle to characteristic equation
A=s.den;
B=s.num;
s.chareqn=@(K) roots(A+K(1)*B); % simple function for finding roots given k
