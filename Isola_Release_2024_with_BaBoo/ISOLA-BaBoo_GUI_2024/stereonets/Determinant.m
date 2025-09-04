function [detA,cofac] = Determinant(a)
%Determinant calculates the determinant and cofactors for a 3 x 3 matrix
%
%   USE: [detA,cofac] = Determinant(a)
%
%   a is the matrix, detA is the determinant, and cofac are the cofactor
%   elements
%
%   Determinant uses function CalcCofac
%
%   NOTE: This function is only for illustration purposes. To get the 
%   determinant of a square matrix of any size use the MATLAB function det 
%   (e.g. detA = det(a))
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Number of rows and columns in a
n = size(a,1);
m = size(a,2);

%If matrix is 3 x 3
if n == 3 && m == 3
    %Calculate the array of cofactors for a. Note that this is not the most
    %efficient way of doing this because you will calculate six more
    %cofactors than you need. The time loss, however, is negligible
    cofac = CalcCofac(a);
    %Calculate the determinant of a as in equation 4.27, remembering that
    %the cofactor 1,2 from CalcCofac will already be negative
    detA = 0.0;
    for i = 1:3
        detA = a(1,i)*cofac(1,i) + detA;
    end
    
else
    error('Matrix is not 3 x 3');
end

end