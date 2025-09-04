function aInv = Invert(a)
%Invert calculates the inverse of a 3 x 3 matrix
%
%   USE: aInv = Invert(a)
%
%   a is the matrix, and aInv is the inverse matrix
%
%   Invert uses function Determinant
%
%   NOTE: This function is only for illustration purposes. To get the 
%   inverse of a square matrix of any size use the MATLAB function inv 
%   (e.g. aInv = inv(a))
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Calculate the cofactors and determinant of a
[detA,cofac] = Determinant(a);

%Calculate the inverse matrix following equation 4.32
aInv = zeros(3,3); %Initialize aInv
for i = 1:3
    for j = 1:3
        aInv(i,j) = cofac(j,i)/detA; %Note the switch of i & j in cofac
    end
end

end