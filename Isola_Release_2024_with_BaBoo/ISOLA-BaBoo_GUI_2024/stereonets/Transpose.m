function c = Transpose(a)
%Transpose calculates the transpose of a matrix
%
%   USE: c = Transpose(a)
%
%   The original matrix is a; the transpose of a is returned in c
%
%   NOTE: This function is only for illustration purposes. To get the
%   transpose of a matrix in MATLAB use the ' operator (e.g. c = a')
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Number of rows and columns in a
n = size(a,1);
m = size(a,2);
%Initialize c. Note the switch of number of rows and columns here
c = zeros(m,n);

for i = 1:n
    for j = 1:m
        c(j,i) = a(i,j); %Note the switch of indices, i & j here
    end
end

end