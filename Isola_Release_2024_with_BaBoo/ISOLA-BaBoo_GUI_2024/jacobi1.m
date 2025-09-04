function [V,D] = jacobi1(A,epsilon,show)
%---------------------------------------------------------------------------
%JACOBI1   The original Jacobi`s method of iteration is used
%          to compute the eigenpairs of a symmetric matrix.
% Sample call
%   [V,D] = jacobi1(A,epsilon,show)
% Inputs
%   A         matrix
%   epsilon   convergence tolerance
% Return
%   V         solution: matrix of eigenvectors
%   D         solution: diagonal matrix of eigenvalues
%
% NUMERICAL METHODS: MATLAB Programs, (c) John H. Mathews 1995
% To accompany the text:
% NUMERICAL METHODS for Mathematics, Science and Engineering, 2nd Ed, 1992
% Prentice Hall, Englewood Cliffs, New Jersey, 07632, U.S.A.
% Prentice Hall, Inc.; USA, Canada, Mexico ISBN 0-13-624990-6
% Prentice Hall, International Editions:   ISBN 0-13-625047-5
% This free software is compliments of the author.
% E-mail address:      in%"mathews@fullerton.edu"
%
% Algorithm 11.3 (Jacobi Iteration for Eigenvalues and Eigenvectors).
% Section	11.3, Jacobi's Method, Page 571
%---------------------------------------------------------------------------

if nargin==2, show = 0; end
D = A;
[n,n] = size(A);
V = eye(n);
done = 0;
working = 1;
stat = working;
cntr = 0;
[m1 p] = max(abs(D-diag(diag(D)))); % Select element
[m2 q] = max(m1);                   % element of largest
p = p(q);                           % magnitude.
while (stat==working),
  t = D(p,q)/(D(q,q) - D(p,p));
  c = 1/sqrt(t*t+1);
  s = c*t;
  R = [c s; -s c];
  D([p q],:) = R'*D([p q],:);
  D(:,[p q]) = D(:,[p q])*R;
  V(:,[p q]) = V(:,[p q])*R;
  cntr = cntr+1;
  if show==1,
    home; if cntr==1, clc; end; 
    disp(['Jacobi iteration No. ',int2str(cntr)]),disp(''),...
    disp(['Zeroed out the element  D(',num2str(p),',',num2str(q),') = ']),...
  	 disp(D(p,q)),disp('New transformed matrix  D = '),disp(D)
  end
  [m1 p] = max(abs(D-diag(diag(D))));
  [m2 q] = max(m1);
  p = p(q);
  if (abs(D(p,q))<epsilon*sqrt(sum(diag(D).^2)/n)), stat = done; end
end
D = diag(diag(D));