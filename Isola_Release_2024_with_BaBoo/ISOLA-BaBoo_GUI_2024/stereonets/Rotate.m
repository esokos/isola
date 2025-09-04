function [rtrd,rplg] = Rotate(raz,rdip,rot,trd,plg,ans0)
%Rotate rotates a line by performing a coordinate transformation on
%vectors. The algorithm was originally written by Randall A. Marrett
%
%   USE: [rtrd,rplg] = Rotate(raz,rdip,rot,trd,plg,ans0)
%
%   raz = trend of rotation axis
%   rdip = plunge of rotation axis
%   rot = magnitude of rotation
%   trd = trend of the vector to be rotated
%   plg = plunge of the vector to be rotated
%   ans0 = A character indicating whether the line to be rotated is an axis
%   (ans0 = 'a') or a vector (ans0 = 'v')
%
%   NOTE: All angles are in radians
%
%   Rotate uses functions SphToCart and CartToSph
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Allocate some arrays
a = zeros(3,3); %Transformation matrix
pole = zeros(1,3); %Direction cosines of rotation axis
plotr = zeros(1,3); %Direction cosines of rotated vector
temp = zeros(1,3);  %Direction cosines of unrotated vector

%Convert rotation axis to direction cosines. Note that the convention here
%is X1 = North, X2 = East, X3 = Down
[pole(1) pole(2) pole(3)] = SphToCart(raz,rdip,0);

% Calculate the transformation matrix
x = 1.0 - cos(rot);
sinRot = sin(rot);  %Just reduces the number of calculations
cosRot = cos(rot);
a(1,1) = cosRot + pole(1)*pole(1)*x;
a(1,2) = -pole(3)*sinRot + pole(1)*pole(2)*x;
a(1,3) = pole(2)*sinRot + pole(1)*pole(3)*x;
a(2,1) = pole(3)*sinRot + pole(2)*pole(1)*x;
a(2,2) = cosRot + pole(2)*pole(2)*x;
a(2,3) = -pole(1)*sinRot + pole(2)*pole(3)*x;
a(3,1) = -pole(2)*sinRot + pole(3)*pole(1)*x;
a(3,2) = pole(1)*sinRot + pole(3)*pole(2)*x;
a(3,3) = cosRot + pole(3)*pole(3)*x;

%Convert trend and plunge of vector to be rotated into direction cosines
[temp(1) temp(2) temp(3)] = SphToCart(trd,plg,0);

%The following nested loops perform the coordinate transformation
for i=1:3
    plotr(i) = 0.0;
    for j=1:3
        plotr(i) = a(i,j)*temp(j) + plotr(i);
    end
end

%Convert to lower hemisphere projection if data are axes (ans0 = 'a')
if plotr(3) < 0.0 && ans0 == 'a'
    plotr(1) = -plotr(1);
    plotr(2) = -plotr(2);
    plotr(3) = -plotr(3);
end

%Convert from direction cosines back to trend and plunge
[rtrd,rplg]=CartToSph(plotr(1),plotr(2),plotr(3));

end