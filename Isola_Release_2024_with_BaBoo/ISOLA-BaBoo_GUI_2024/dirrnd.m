function r = dirrnd(a,varargin)
%DIRRND Random vectors from a Dirichlet distribution.
%   R = DIRRND(A) returns a random vector chosen from the Dirichlet 
%   distribution with a 1-by-K vector of hyperparameter A, where K is
%   the dimensionality of the pdf. R is a 1-by-K vector. If A < 0, R is a 
%   1-by-K vector of NaN values.
%
%   R = DIRRND(A,M) returns M random vectors chosen from the Dirichlet 
%   distribution with hyperparameter A. R is a M-by-K matrix. Each
%   row of R corresponds to one random vector.
%
%   Example:
%    Generate 10 random vectors with hyperparameter A
%    A=[2,3,4];
%    R=dirrnd(A,10);
%
%   See also DIRPDF, DIRSTAT.

%   DIRRND generates Dirichlet random vectors using samples from a gamma 
%   distribution (Gellman, page 585).

%   Reference:
%      [1]  A. Gelman, et. al., "Bayesian Data Analysis", CRC Press, 2013


narginchk(1, 2);

if ~isvector(a)
    error('Hyperparameters must be a vector.');
end

if iscolumn(a)
    a = transpose(a);
end

if ~isempty(varargin)
    m = varargin{:};
else
    m = 1;
end

% Generate gamma random values
if any(a <= 0)
    r = NaN(m, size(a, 2));
else
    g = randg(repmat(a, [m, 1]));
    r = exp(log(g) - log(sum(g, 2)));
    
    r = r./sum(r,2);
end