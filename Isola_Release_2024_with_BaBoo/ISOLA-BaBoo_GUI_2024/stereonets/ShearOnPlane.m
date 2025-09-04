function [TT,dCTT,R] = ShearOnPlane(stress,tX1,pX1,tX3,strike,dip)
%ShearOnPlane calculates the direction and magnitudes of the normal
%and shear tractions on an arbitrarily oriented plane
%
%   USE: [TT,dCTT,R] = ShearOnPlane(stress,tX1,pX1,tX3,strike,dip)
%
%   stress = 3 x 3 stress tensor
%   tX1 = trend of X1
%   pX1 = plunge of X1
%   tX3 = trend of X3
%   strike = strike of plane
%   dip = dip of plane
%   TT = 3 x 3 matrix with the magnitude (column 1), trend (column 2) and 
%       plunge (column 3) of: normal traction on the plane (row 1), 
%       minimum shear traction (row 2), and maximum shear traction (row 3)
%   dCTT = 3 x 3 matrix with the direction cosines of unit vectors parallel
%         to: normal traction on the plane (row 1), minimum shear traction
%         (row 2), and maximum shear traction (row 3)
%   R = Stress ratio
%
%   NOTE = Input stress tensor does not need to be along principal stress
%          directions
%          Plane orientation follows the right hand rule 
%          Input/Output angles are in radians
%
%   ShearOnPlane uses functions PrincipalStress, Cauchy and CartToSph
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Initialize TT and dCTT
TT = zeros(3,3);
dCTT = zeros(3,3);

%Compute principal stresses and principal stress directions
[pstress,dCp] = PrincipalStress(stress,tX1,pX1,tX3);

%Update stress vector so that it is along principal stress directions
stress = zeros(3,3);
for i = 1:3
    stress(i,i) = pstress(i,1);
end

%Compute tractions on plane in principal stress direction (Eqs. 6.24-6.26)
[T,pT] = Cauchy(stress,pstress(1,2),pstress(1,3),pstress(3,2),strike,dip);

%Find the B axis by the cross product of T cross pT and convert to
%direction cosines (Eq 6.27)
B = zeros(1,3);
B(1) = T(2)*pT(3) - T(3)*pT(2);
B(2) = T(3)*pT(1) - T(1)*pT(3);
B(3) = T(1)*pT(2) - T(2)*pT(1);

%Find the shear direction by the cross product of pT cross B. This will
%give S in right handed coordinates (Eq. 6.27)
S = zeros(1,3);
S(1) = pT(2)*B(3) - pT(3)*B(2);
S(2) = pT(3)*B(1) - pT(1)*B(3);
S(3) = pT(1)*B(2) - pT(2)*B(1);

%Convert T, B and S to unit vectors
rT = sqrt(T(1)*T(1)+T(2)*T(2)+T(3)*T(3));
rB = sqrt(B(1)*B(1)+B(2)*B(2)+B(3)*B(3));
rS = sqrt(S(1)*S(1)+S(2)*S(2)+S(3)*S(3));
for i = 1:3
    T(i) = T(i)/rT;
    B(i) = B(i)/rB;
    S(i) = S(i)/rS;
end

%Now we can write the transformation matrix from principal stress
%coordinates to plane coordinates (Eq. 6.28)
a = zeros(3,3);
a(1,:) = [pT(1),pT(2),pT(3)];
a(2,:) = [B(1),B(2),B(3)];
a(3,:) = [S(1),S(2),S(3)];

%Calculate stress ratio (Eq. 6.32)
R = (stress(2,2) - stress(1,1))/(stress(3,3)-stress(1,1));

%Calculate magnitude of normal and shear tractions (Eq. 6.31)
for i = 1:3
    TT(i,1) = stress(1,1)*a(1,1)*a(i,1) + stress(2,2)*a(1,2)*a(i,2) +...
    stress(3,3)*a(1,3)*a(i,3);
end

%To get the orientation of the tractions in North-East-Down coordinates, we
%need to do a vector transformation between principal stress and
%North-East-Down coordinates. The transformation matrix are just the
%direction cosines of the principal stresses in North-East-Down coordinates
%(Eq. 6.29)
for i = 1:3
    for j = 1:3
        dCTT(1,i) = dCp(j,i)*pT(j) + dCTT(1,i);
        dCTT(2,i) = dCp(j,i)*B(j) + dCTT(2,i);
        dCTT(3,i) = dCp(j,i)*S(j) + dCTT(3,i);
    end
end

%Trend and plunge of traction on plane
[TT(1,2),TT(1,3)] = CartToSph(dCTT(1,1),dCTT(1,2),dCTT(1,3));
%Trend and plunge of minimum shear direction
[TT(2,2),TT(2,3)] = CartToSph(dCTT(2,1),dCTT(2,2),dCTT(2,3));
%Trend and plunge of maximum shear direction
[TT(3,2),TT(3,3)] = CartToSph(dCTT(3,1),dCTT(3,2),dCTT(3,3));

end