function chisq = BackTrishear(xp,yp,tparam,sinc) 
%BackTrishear retrodeforms bed for the given trishear parameters and return
%sum of square of residuals (chisq)
%
%   USE: chisq = BackTrishear(xp,yp,tparam,sinc)
%
%   xp = column vector with x locations of points along bed
%   yp = column vector with y locations of points along bed  
%   tparam = A 1 x 7 vector with the x and y coordinates of the fault tip 
%           (entries 1 and 2), the ramp angle (entry 3), the P/S (entry 4), 
%           the trishear angle (entry 5), the fault slip (entry 6), and the
%           concentration factor (entry 7)
%   sinc = slip increment
%   chisq = sum of square of residuals (objective function)
%
%   NOTE: Input ramp and trishear angles should be in radians
%         For reverse faults use positive slip and slip increment
%         For normal faults use negative slip and slip increment
%         The MATLAB Statistics Toolbox is needed to run this function
%
%   BackTrishear uses function VelTrishear
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

% Model parameters

xtf = tparam(1); %x current fault tip
ytf = tparam(2); %y current fault tip
ramp = tparam(3);%Ramp angle
psr = tparam(4)*-1.0; %P/S: Multiply by -1 because we are restoring bed
tra = tparam(5); %Trishear angle
m = tan(tra/2); %Tangent of half trishear angle
slip = tparam(6); %Fault slip
c = tparam(7); %Concentration factor
ninc=round(slip/sinc); %Number of slip increments
sincr = slip/ninc*-1.0; %Slip increment: Multiply by -1 (restoring bed)

%Transformation matrix from geographic to fault coordinates
a11=cos(ramp);
a12=cos(pi/2-ramp);
a21=cos(pi/2+ramp);
a22=a11;

% Transform to coordinates parallel and perpendicular to the fault, and
% with origin at current fault tip
fx=(xp-xtf)*a11+(yp-ytf)*a12;
fy=(xp-xtf)*a21+(yp-ytf)*a22;

% Restore
for i=1:ninc
   	for j=1:size(fx,1)
         % Solve trishear in a coordinate system attached to current 
         % fault tip. Note: First retrodeform and then move tip back
         xx=fx(j)-(psr*(i-1)*abs(sincr));
         yy=fy(j);
         % compute velocity
         [vx,vy]=VelTrishear(xx,yy,sincr,m,c);
         % UPDATE fx, fy coordinates
         fx(j)=fx(j)+vx;
         fy(j)=fy(j)+vy;
    end
end

%Fit straight line to restored bed. Use MATLAB function regress (MATLAB
%Statistics Toolbox) to compute linear regression. b(1) is the intercept 
%and b(2) the slope of the line
XX = [ones(size(fx)) fx];
YY = fy;
b = regress(YY,XX);

%Compute chisq (objective function) = Sum of square of residuals between 
%straight line and restored bed
chisq = sum((fy-b(1)-b(2)*fx).^2.);

end
