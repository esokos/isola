function A = hrv2alpha(hrv)
%hrv= rr tt pp rt rp  tp           % t=è
%     rr èè öö rè rö  èö           % p=ö

% Ìrr Mrè Mrö
% Mrè Ìèè Ìèö
% Ìrö Ìèö Ìöö

% Mrr Mrt Mrp
% Mrt Mtt Mtp
% Mrp Mtp Mpp

%[Mxx Mxy Mxz] [ -a4+a6      a1        a2    ]
%|Myx Myy Myz|=|   a1      -a5+a6     -a3    |
%[Mzx Mzy Mzz] [   a2       -a3     a4+a5+a6 ]

% Mxx= -a4+a6    Mxy=  a1       Mxz=  a2
% Myx=  a1       Myy= -a5+a6    Myz= -a3
% Mzx=  a2       Mzy= -a3       Mzz=  a4+a5+a6

% Mxx =  Mèè   = -a4   +a6 = Mèè 
% Myy =  Möö   =    -a5+a6 = Möö  
% Ìzz =  Mrr   =  a4+a5+a6 = Mrr 
% Mxy = -Mèö   =  a1
% Ìxz =  Mèr   =  a2
% Myz = -Mör   = -a3

%  1  2  3  4  5  6
% rr tt pp rt rp tp
% rr èè öö rè rö èö 
%%  order in inv3.dat is rr, tt, pp, rt, rp, tp 
% equations to compute a's directly from hrv components 
%    a(1) =   -xtp = - hrv(6)
%    a(2) =    xrt =   hrv(4)
%    a(3) =    xrp =   hrv(5)
%    a(4) =  (-2*xtt + xpp   + xrr)/3 = (-2*hrv(2)+hrv(3)+hrv(1))/3
%    a(5) =  (xtt - 2*xpp + xrr) /3   = (hrv(2)-2*hrv(3)+hrv(1))/3
%    a(6) = (xtt + xpp +xrr) /3      =(hrv(2)+hrv(3)+hrv(1))/3

%% another approach in calculating As
%a(1)=-hrv(6);a(2)=hrv(4);a(3)=hrv(5);
%a(4) =(-2*hrv(2)+hrv(3)+hrv(1))/3;a(5) = (hrv(2)-2*hrv(3)+hrv(1))/3; a(6) =(hrv(2)+hrv(3)+hrv(1))/3;

%%
% for older versions
%hrv2=mat2cell(hrv,1,6)
%
if iscell(hrv)
   hrv=cell2mat(hrv);
else
   disp('hrv not cell')
end

A(1)=-hrv(6); A(2)= hrv(4); A(3)= hrv(5);

% solve the system of equations
C=[-1 0 1;0 -1 1; 1 1 1]; b=[hrv(2);hrv(3);hrv(1)];
s=C\b;
A(4)=s(1); A(5)=s(2); A(6)=s(3);

end

