function dC = DirCosAxes(tX1,pX1,tX3)
%DirCosAxes calculates the direction cosines of a right handed, orthogonal
%X1,X2,X3 cartesian coordinate system of any orientation with respect to 
%North-East-Down
%
%   USE: dC = DirCosAxes(tX1,pX1,tX3)
%
%   tX1 = trend of X1
%   pX1 = plunge of X1
%   tX3 = trend of X3
%   dC = 3 x 3 matrix containing the direction cosines of X1 (row 1),
%        X2 (row 2), and X3 (row 3)
%
%   Note: Input angles should be in radians
%
%   DirCosAxes uses function SphToCart
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Some constants
east = pi/2.0;
west = 1.5*pi;

%Initialize matrix of direction cosines
dC = zeros(3,3);

%Direction cosines of X1
[dC(1,1),dC(1,2),dC(1,3)] = SphToCart(tX1,pX1,0);

%Calculate plunge of axis 3
%If axis 1 is horizontal
if pX1 == 0.0
    if abs(tX1-tX3) == east || abs(tX1-tX3) == west
        pX3 = 0.0;
    else
        pX3 = east;
    end
%Else
else
    %From Equation 2.14 and with theta equal to 90 degrees
    pX3 = atan(-(dC(1,1)*cos(tX3)+dC(1,2)*sin(tX3))/dC(1,3));
end

%Direction cosines of X3
[dC(3,1),dC(3,2),dC(3,3)] = SphToCart(tX3,pX3,0);

%Compute direction cosines of X2 by the cross product of X3 and X1
dC(2,1) = dC(3,2)*dC(1,3) - dC(3,3)*dC(1,2);
dC(2,2) = dC(3,3)*dC(1,1) - dC(3,1)*dC(1,3);
dC(2,3) = dC(3,1)*dC(1,2) - dC(3,2)*dC(1,1);
% Convert X2 to a unit vector
r = sqrt(dC(2,1)*dC(2,1)+dC(2,2)*dC(2,2)+dC(2,3)*dC(2,3));
for i = 1:3
    dC(2,i) = dC(2,i)/r;
end

end