function c = MultMatrix(a,b)
%MultMatrix multiplies two conformable matrices
%
%   USE: c = MultMatrix(a,b)
%
%   Matrix a premultiplies matrix b to produce matrix c, as in the equation
%   c = ab
%
%   NOTE: This function is only for illustration purposes. To multiply 
%   matrices in MATLAB use the * operator (e.g. c = a*b)
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

aRow = size(a,1); %Number of rows in a
aCol = size(a,2); %Number of columns in a
bRow = size(b,1); %Number of rows in b
bCol = size(b,2); %Number of columns in b

%If the multiplication is conformable
if aCol == bRow
    %Initialize c
    c = zeros(aRow,bCol);
    for i = 1:aRow
        for j = 1:bCol
            for k = 1:aCol
                c(i,j) = a(i,k)*b(k,j) + c(i,j);
            end
        end
    end
%Else report an error
else
    error('Error: Inner matrix dimensions must agree');
end

end