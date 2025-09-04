function [eps,ome,pstrains,rotc,rot] = InfStrain(e)
%InfStrain computes infinitesimal strain from an input displacement
%gradient tensor
%
%   USE: [eps,ome,pstrains,rotc,rot] = InfStrain(e)
%
%   e = 3 x 3 displacement gradient tensor
%   eps = 3 x 3 strain tensor
%   ome = 3 x 3 rotation tensor
%   pstrains = 3 x 3 matrix with magnitude (column 1), trend (column 2) and
%              plunge (column 3) of maximum (row 1), intermediate (row 2),
%              and minimum (row 3) principal strains
%   rotc = 1 x 3 vector with rotation components
%   rot = 1 x 3 vector with rotation magnitude and trend and plunge of
%          rotation axis
%
%   NOTE: Output trends and plunges of principal strains and rotation axes
%   are in radians
%
%   InfStrain uses function CartToSph and ZeroTwoPi
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Initialize variables
eps = zeros(3,3);
ome = zeros(3,3);
pstrains = zeros(3,3);
rotc = zeros(1,3);
rot = zeros(1,3);

%Compute strain and rotation tensors (Eq. 8.2)
for i=1:3
    for j=1:3
        eps(i,j)=0.5*(e(i,j)+e(j,i));
        ome(i,j)=0.5*(e(i,j)-e(j,i));
    end
end

%Compute principal strains and orientations. Here we use the MATLAB
%function eig. D is a diagonal matrix of eigenvalues (i.e. principal 
%strains), and V is a full matrix whose columns are the corresponding 
%eigenvectors (i.e. principal strain directions)
[V,D] = eig(eps);

%Maximum principal strain
pstrains(1,1) = D(3,3);
[pstrains(1,2),pstrains(1,3)] = CartToSph(V(1,3),V(2,3),V(3,3));
%Intermediate principal strain
pstrains(2,1) = D(2,2); 
[pstrains(2,2),pstrains(2,3)] = CartToSph(V(1,2),V(2,2),V(3,2));
%Minimum principal strain
pstrains(3,1) = D(1,1); 
[pstrains(3,2),pstrains(3,3)] = CartToSph(V(1,1),V(2,1),V(3,1));

%Calculate rotation components (Eq. 8.4)
rotc(1)=(ome(2,3)-ome(3,2))*-0.5;
rotc(2)=(-ome(1,3)+ome(3,1))*-0.5;
rotc(3)=(ome(1,2)-ome(2,1))*-0.5;

%Compute rotation magnitude (Eq. 8.5)
rot(1) = sqrt(rotc(1)^2+rotc(2)^2+rotc(3)^2);
%Compute trend and plunge of rotation axis
[rot(2),rot(3)] = CartToSph(rotc(1)/rot(1),rotc(2)/rot(1),rotc(3)/rot(1));
%If plunge is negative
if rot(3) < 0.0
    rot(2) = ZeroTwoPi(rot(2)+pi);
    rot(3) = -rot(3);
    rot(1) = -rot(1);
end

end