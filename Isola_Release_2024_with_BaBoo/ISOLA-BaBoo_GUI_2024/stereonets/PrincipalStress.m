function [pstress,dCp] = PrincipalStress(stress,tX1,pX1,tX3)
%Given the stress tensor in a X1,X2,X3 coordinate system of any 
%orientation, PrincipalStress calculates the principal stresses and their
%orientations (trend and plunge) 
%
%   USE: [pstress,dCp] = PrincipalStress(stress,tX1,pX1,tX3)
%
%   stress = Symmetric 3 x 3 stress tensor
%   tX1 = trend of X1
%   pX1 = plunge of X1
%   tX3 = trend of X3
%   pstress = 3 x 3 matrix containing the magnitude (column 1), trend
%             (column 2), and plunge (column 3) of the maximum (row 1),
%             intermediate (row 2), and minimum (row 3) principal stresses
%   dCp = 3 x 3 matrix with direction cosines of the principal stress
%         directions: Max. (row 1), Int. (row 2), and Min. (row 3)
%
%   NOTE: Input/Output angles are in radians
%
%   PrincipalStress uses functions DirCosAxes and CartToSph
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Compute direction cosines of X1,X2,X3
dC = DirCosAxes(tX1,pX1,tX3);

%Initialize pstress
pstress = zeros(3,3);

%Calculate the eigenvalues and eigenvectors of the stress tensor. Use
%MATLAB function eig. D is a diagonal matrix of eigenvalues
%(i.e. principal stress magnitudes), and V is a full matrix whose columns
%are the corresponding eigenvectors (i.e. principal stress directions)
[V,D] = eig(stress);

%Fill principal stress magnitudes
pstress(1,1) = D(3,3); %Maximum principal stress
pstress(2,1) = D(2,2); %Intermediate principal stress
pstress(3,1) = D(1,1); %Minimum principal stress

%The direction cosines of the principal stress tensor are given with
%respect to X1,X2,X3 stress coordinate system, so they need to be
%transformed to the North-East-Down coordinate system (e.g. Eq. 3.9)
tV = zeros(3,3);
for i = 1:3
    for j = 1:3
        for k = 1:3
            tV(j,i) = dC(k,j)*V(k,i) + tV(j,i);
        end
    end
end

%Initialize dCp
dCp = zeros(3,3);

%Trend and plunge of maximum principal stress direction
dCp(1,:) = [tV(1,3),tV(2,3),tV(3,3)];
[pstress(1,2),pstress(1,3)] = CartToSph(tV(1,3),tV(2,3),tV(3,3));

%Trend and plunge of intermediate principal stress direction
dCp(2,:) = [tV(1,2),tV(2,2),tV(3,2)];
[pstress(2,2),pstress(2,3)] = CartToSph(tV(1,2),tV(2,2),tV(3,2));

%Trend and plunge of minimum principal stress direction
dCp(3,:) = [tV(1,1),tV(2,1),tV(3,1)];
[pstress(3,2),pstress(3,3)] = CartToSph(tV(1,1),tV(2,1),tV(3,1));

end