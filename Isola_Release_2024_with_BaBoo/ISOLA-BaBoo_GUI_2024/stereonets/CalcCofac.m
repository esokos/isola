function cofac = CalcCofac(a)
%CalcCofac calculates all of the cofactor elements for a 3 x 3 matrix
%
%   USE: cofac = CalcCofac(a)
%
%   a is the matrix and cofac are the cofactor elements
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Number of rows and columns in a
n = size(a,1);
m = size(a,2);

%If matrix is 3 x 3
if n == 3 && m == 3
    %Initialize cofactor
    cofac = zeros(3,3); 
    %Calculate cofactor. When i+j is odd, the cofactor is negative
    cofac(1,1) = a(2,2)*a(3,3) - a(2,3)*a(3,2);
    cofac(1,2) = -(a(2,1)*a(3,3) - a(2,3)*a(3,1));
    cofac(1,3) = a(2,1)*a(3,2) - a(2,2)*a(3,1);
    
    cofac(2,1) = -(a(1,2)*a(3,3) - a(1,3)*a(3,2));
    cofac(2,2) = a(1,1)*a(3,3) - a(1,3)*a(3,1);
    cofac(2,3) = -(a(1,1)*a(3,2) - a(1,2)*a(3,1));
    
    cofac(3,1) = a(1,2)*a(2,3) - a(1,3)*a(2,2);
    cofac(3,2) = -(a(1,1)*a(2,3) - a(1,3)*a(2,1));
    cofac(3,3) = a(1,1)*a(2,2) - a(1,2)*a(2,1);
    
    
else
    error('Matrix is not 3 x 3');
end

end