function [T,pT] = Cauchy(stress,tX1,pX1,tX3,strike,dip)
%Given the stress tensor in a X1,X2,X3 coordinate system of any 
%orientation, Cauchy computes the X1,X2,X3 tractions on an arbitrarily
%oriented plane 
%
%   USE: [T,pT] = Cauchy(stress,tX1,pX1,tX3,strike,dip)
%
%   stress = Symmetric 3 x 3 stress tensor
%   tX1 = trend of X1
%   pX1 = plunge of X1
%   tX3 = trend of X3
%   strike = strike of plane
%   dip = dip of plane
%   T = 1 x 3 vector with tractions in X1, X2 and X3
%   pT = 1 x 3 vector with direction cosines of pole to plane transformed
%        to X1,X2,X3 coordinates
%
%   NOTE = Plane orientation follows the right hand rule 
%          Input/Output angles are in radians
%
%   Cauchy uses functions DirCosAxes and SphToCart
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Compute direction cosines of X1,X2,X3
dC = DirCosAxes(tX1,pX1,tX3);

%Calculate direction cosines of pole to plane
p = zeros(1,3);
[p(1),p(2),p(3)] = SphToCart(strike,dip,1);

%Transform pole to plane to stress coordinates X1,X2,X3
%The transformation matrix is just the direction cosines of X1,X2,X3
pT = zeros(1,3);
for i = 1:3
    for j = 1:3
        pT(i) = dC(i,j)*p(j) + pT(i);
    end
end

%Convert transformed pole to unit vector
r = sqrt(pT(1)*pT(1)+pT(2)*pT(2)+pT(3)*pT(3));
for i = 1:3
    pT(i) = pT(i)/r;
end

%Calculate the tractions in stress coordinates X1,X2,X3
T = zeros(1,3); %Initialize T
%Compute tractions using Cauchy's law (Eq. 6.7b)
for i = 1:3
    for j = 1:3
        T(i) = stress(i,j)*pT(j) + T(i);
    end
end

end