%*****************************************************************************************
%*                                                                                       *
%*   angles.m                                                                            *
%*                                                                                       *
%*   function calculates a fault normal and slip from the moment tensor                  *
%*                                                                                       *
%*****************************************************************************************
function a = angles(m)

%----------------------------------------------------------------------------------------
% eigenvalues and eigenvectors of a moment tensor
%----------------------------------------------------------------------------------------
[vector,diag_m]=eig(m);	
values_total = eig(m);
%----------------------------------------------------------------------------------------
% isotropic part of the moment tensor
%----------------------------------------------------------------------------------------
volumetric = 1./3.*trace(diag_m);
m_volumetric = volumetric*eye(3); 
%----------------------------------------------------------------------------------------
% deviatoric part of the moment tensor
%----------------------------------------------------------------------------------------
m_deviatoric = diag_m - m_volumetric; 
%----------------------------------------------------------------------------------------
% eigenvalues of the deviatoric part of the moment tensor
%----------------------------------------------------------------------------------------
value_dev = eig(m_deviatoric);
%----------------------------------------------------------------------------------------
% calculation of a fault normal and slip from the moment tensor
%----------------------------------------------------------------------------------------
[values,j]=sort(value_dev);

n1 = vector(:,j(3))+vector(:,j(1));
n1 = n1/norm(n1);
	
if (n1(3)>0) n1 = -n1; end;             % vertical component is always negative!
        
u1 = vector(:,j(3))-vector(:,j(1));
u1 = u1/norm(u1);

if ((n1'*m*u1+u1'*m*n1) < 0) u1 = -u1; end;    

n2 = u1;
u2 = n1;
    
if (n2(3)>0) n2 = -n2; u2 = -u2; end;   % vertical component is always negative!
%----------------------------------------------------------------------------------------
% 1st solution
%----------------------------------------------------------------------------------------
dip    = acos(-n1(3))*180/pi;
strike = asin(-n1(1)/sqrt(n1(1)^2+n1(2)^2))*180/pi;

% determination of a quadrant
if (n1(2)<0) strike=180-strike; end;

rake = asin(-u1(3)/sin(dip*pi/180))*180/pi;

% determination of a quadrant
cos_rake = u1(1)*cos(strike*pi/180)+u1(2)*sin(strike*pi/180);
if (cos_rake<0) rake=180-rake; end;

if (strike<0   ) strike = strike+360; end;
if (rake  <-180) rake   = rake  +360; end;
if (rake  > 180) rake   = rake  -360; end;  % rake is in the interval -180<rake<180
    
angles1 = [strike dip rake];

%----------------------------------------------------------------------------------------
% 2nd solution
%----------------------------------------------------------------------------------------
dip    = acos(-n2(3))*180/pi;
strike = asin(-n2(1)/sqrt(n2(1)^2+n2(2)^2))*180/pi;

% determination of a quadrant
if (n2(2)<0) strike=180-strike; end;

rake = asin(-u2(3)/sin(dip*pi/180))*180/pi;

% determination of a quadrant
cos_rake = u2(1)*cos(strike*pi/180)+u2(2)*sin(strike*pi/180);
if (cos_rake<0) rake=180-rake; end;

if (strike<0   ) strike = strike+360; end;
if (rake  <-180) rake   = rake  +360; end;
if (rake  > 180) rake   = rake  -360; end;  
    
angles2 = [strike dip rake];
%----------------------------------------------------------------------------------------
a = [angles1 angles2];


