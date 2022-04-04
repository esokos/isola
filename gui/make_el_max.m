function C=make_el_max(A,B)

[nRowsA,nCols] = size(A);
nRowsB = size(B,1);

AB = zeros(nRowsA+nRowsB,nCols);
AB2 = zeros(nRowsA+nRowsB,nCols);

Z=zeros(nRowsA+nRowsB,4);

AB(1:2:end,:) = A;
AB(2:2:end,:) = B;

AB2(1:2:end,:) = B;
AB2(2:2:end,:) = A;

C=[Z AB AB2];
