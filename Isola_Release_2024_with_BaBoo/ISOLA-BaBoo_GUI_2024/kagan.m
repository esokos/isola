function [rotangle,theta,phi]=kagan(mechOld,mechNew)
%
% TO CALCULATE KAGAN angle BETWEEN TWO SOLUTIONS ONLY
%

%  usage:
%   [rotangle,theta,phi]=kagan([strikeOld,dipOld,rakeOld],[strikeNew,dipNew,rakeNew])
%  all angles are given in [degree]

%
%  Provides minimum rotation between two DC mechanisms
%  minimum rotation ROTANGLE along axis given by THETA and PHI
%
%  After Kagan, Y. Y. (1991). 3-D rotation of double-couple
%  earthquake sources, Geophys. J. Int., 106(3), 709-716.

%  almost "literary" translated from original Fortran code by P. Kolar
%  (kolar@ig.cas.cz)     18/01/2019
%
%  cf. eg. : 
%  http://moho.ess.ucla.edu/~kagan/doc_index.html
%  http://peterbird.name/oldFTP/2003107-esupp/
%


str1old=mechOld(1);
dip1old=mechOld(2);
rake1old=mechOld(3);

str1new=mechNew(1);
dip1new=mechNew(2);
rake1new=mechNew(3);


Q1=quatFps(str1old,dip1old,rake1old);
Q2=quatFps(str1new,dip1new,rake1new);

maxval=180. ;

for i=1:4
    Qdum=f4r1(Q1,Q2,i);
    rotangle=sphcoor(Qdum);
    
    if(rotangle < maxval)
        maxval=rotangle;
        Q=Qdum;
    end
    
end

[rotangle,theta,phi]=sphcoor(Q);

end
%----------------------------------------------------------
function QUAT=quatFps(DD,DA,SA)
%  calculates rotation quaternion corresponding to given focal mechanism
%
%      input: strike (DD), dip (DA), rake (SA)
%      output: QUAT

ERR=1.e-15;
IC=1;
ICOD=0;
CDD=cosd(DD);
SDD=sind(DD);
CDA=cosd(DA);
SDA=sind(DA);
CSA=cosd(SA);
SSA=sind(SA);

S1=CSA*SDD-SSA*CDA*CDD;
S2=-CSA*CDD-SSA*CDA*SDD;
S3=-SSA*SDA;

V1=SDA*CDD;
V2=SDA*SDD;
V3=-CDA;

AN1=S2*V3-V2*S3;
AN2=V1*S3-S1*V3;
AN3=S1*V2-V1*S2;


D2=1./sqrt(2.);
T1=(V1+S1)*D2;
T2=(V2+S2)*D2;
T3=(V3+S3)*D2;
P1=(V1-S1)*D2;
P2=(V2-S2)*D2;
P3=(V3-S3)*D2;

U0=( T1+P2+AN3+1.)/4.;
U1=( T1-P2-AN3+1.)/4.;
U2=(-T1+P2-AN3+1.)/4.;
U3=(-T1-P2+AN3+1.)/4.;

UM=max([U0,U1,U2,U3]);

switch UM
    case U0
        ICOD=1*IC;
        U0=sqrt(U0);
        U3=(T2-P1)/(4.*U0);
        U2=(AN1-T3)/(4.*U0);
        U1=(P3-AN2)/(4.*U0);
        
    case U1
        ICOD=2*IC;
        U1=sqrt(U1);
        U2=(T2+P1)/(4.*U1);
        U3=(AN1+T3)/(4.*U1);
        U0=(P3-AN2)/(4*U1);
        
    case U2
        ICOD=3*IC;
        U2=sqrt(U2);
        U1=(T2+P1)/(4.*U2);
        U0=(AN1-T3)/(4.*U2);
        U3=(P3+AN2)/(4.*U2);
        
    case U3
        ICOD=4*IC;
        U3=sqrt(U3);
        U0=(T2-P1)/(4.*U3);
        U1=(AN1+T3)/(4.*U3);
        U2=(P3+AN2)/(4.*U3);
        
    otherwise
        error(['INTERNAL ERROR 1 -',num2str(ICOD)]);
end



TEMP=U0*U0+U1*U1+U2*U2+U3*U3;
if abs(TEMP-1.) > ERR
    error('INTERNAL ERROR 2');
end


QUAT(1)=U1;
QUAT(2)=U2;
QUAT(3)=U3;
QUAT(4)=U0;

end
%----------------------------------------------------------
function [ ANGL, THETA, PHI]=sphcoor(QUAT)
%
%    returns rotation angle (ANGL) of a counterclockwise rotation
%     and spherical coordinates (colatitude THETA and azimuth PHI) of the
%     rotation pole. THETA=0 corresponds to vector pointing down.


if QUAT(4)<0., QUAT=-QUAT; end
Q4N=sqrt(1.d0-QUAT(4)^2);
COSTH=1.;
if abs(Q4N) > 1.e-10, COSTH=QUAT(3)/Q4N; end
if abs(COSTH)>1., COSTH=0; end   % COSTH=IDINT(COSTH)
THETA=acosd(COSTH);
ANGL=2.*acosd(QUAT(4));
PHI=0.;
if  abs(QUAT(1))>1.e-10 || abs(QUAT(2))>1.e-10
    PHI=atan2d(QUAT(2),QUAT(1));
end
if PHI<0., PHI=PHI+360.; end

end
%----------------------------------------------------------
function Q3=QUATP(Q1,Q2)
%
%     calculates quaternion product Q3=Q2*Q1
%

Q3(1)= Q1(4)*Q2(1)+Q1(3)*Q2(2)-Q1(2)*Q2(3)+Q1(1)*Q2(4);
Q3(2)=-Q1(3)*Q2(1)+Q1(4)*Q2(2)+Q1(1)*Q2(3)+Q1(2)*Q2(4);
Q3(3)= Q1(2)*Q2(1)-Q1(1)*Q2(2)+Q1(4)*Q2(3)+Q1(3)*Q2(4);
Q3(4)=-Q1(1)*Q2(1)-Q1(2)*Q2(2)-Q1(3)*Q2(3)+Q1(4)*Q2(4);

end
%----------------------------------------------------------
function Q3=QUATD(Q1,Q2)
%
%     quaternion division Q3=Q2*Q1^-1
%

QC1(1:3)=-Q1(1:3);
QC1(4)=Q1(4);
Q3=QUATP(QC1,Q2);

end
%-----------------------------------------------------------

function [Q2,QM]=BOXTEST(Q1,ICODE)
%
%     if ICODE==0 finds minimal rotation quaternion
%
%     if ICODE==N finds rotation quaternion Q2=Q1*(i,j,k,1) for N=(1,2,3,4)
%

QUAT=[1, 0, 0; ...
    0, 1, 0; ...
    0, 0, 1; ...
    0, 0, 0];



if ICODE==0
    ICODE=1;
    QM=abs(Q1(1));
    
    for IXC=2:4
        if abs(Q1(IXC)) > QM
            QM=abs(Q1(IXC));
            ICODE=IXC;
        end  % endif
    end  % endfor
end % endif


if ICODE==4
    Q2=Q1;
else
    QUATT(:)=QUAT(:,ICODE);
    Q2=QUATP(QUATT,Q1);
end

if Q2(4)<0., Q2=-Q2; end

QM=Q2(4);

end
%----------------------------------------------------------
function Q=f4r1(Q1,Q2,ICODE)
% 
%      Q=Q2*(Q1*(i,j,k,1))^-1 for N=(1,2,3,4)
% 
%      if N=0, then it finds it of the minimum
%

      QR1=BOXTEST(Q1,ICODE);

      Q= QUATD(QR1,Q2);

end
%=====================eof==================================
