function [V,L]=eigsort(CM)
% this function calculates eigenvalues and egenvectors 
% using Matlab's eig function, but returns the output 
% ordered in decending order. 
% D.R.B.  24 Nov 2012 
% 
% USAGE 
%[V,L]=eigsort(CM)
% 
% INPUT
% CM is the covariance (or correlation matrix) 
% OUTPUT 
% V are the eigenvectors with the 1st in column 1 
% L are the eigenvalues with the 1st in L(1,1) 


[V, L]=eig(CM);                  % calc e-vectors (V) & e-values (L) 
[L, iL]=sort(diag(L),'descend'); % sort L in descending
L=diag(L);                       % reform eigenvalue matrix
V=V(:,iL);                       % reorder eigenvectors