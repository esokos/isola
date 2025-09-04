function C = axcf(varargin)
%
% Matlab function for determining the (cross-)covariance matrix by
% approximate (cross-)covariance function (AXCF or ACF) (Hallo and Gallovic, 2016).
% Hallo, M., Gallovic, F. (2016): Fast and cheap approximation of Green functions
% uncertainty for waveform-based earthquake source inversions, Geophys. J. Int., 207, 1012-1029.
%
% Authors: Miroslav Hallo and Frantisek Gallovic (1/2016)
% Charles University in Prague, Faculty of Mathematics and Physics
% Revision 1/2018: Corrected inserting ("zero") values before and
%                  after signal for real signals
%
% Copyright (C) 2016,2018  Miroslav Hallo and Franti??ek Gallovi??
%
% This program is published under the GNU General Public License (GNU GPL).
%
% This program is free software: you can modify it and/or redistribute it
% or any derivative version under the terms of the GNU General Public
% License as published by the Free Software Foundation, either version 3
% of the License, or (at your option) any later version.
%
% This code is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY. We would like to kindly ask you to acknowledge the authors
% and don't remove their names from the code.
%
% You should have received copy of the GNU General Public License along
% with this program. If not, see <http://www.gnu.org/licenses/>.
%
% -------------------------------------------
%
% INPUT:
% f - First input signal (vector)
% g - Second input signal (vector)
% L1 - Width of the joint uniform distribution of time-shifts [sec] (scalar)
% L12 - Width of the relative uniform distribution of time-shifts [sec] (scalar)
% dt - Signal sampling [sec] (scalar)
% -------------------------------------------
%
% OUTPUT:
% C - (cross-)covariance matrix (2D matrix)
% -------------------------------------------
%
% EXAMPLES:
% axcf(f,L1,dt) - Compute auto-covariance matrix of f
% axcf(f,g,L1,L12,dt) - Compute cross-covariance matrix of f and g
% -------------------------------------------
%
% REQUIREMENTS:
% smooth (MatLab Curve Fitting Toolbox)
% -------------------------------------------
% -------------------------------------------

% Manage input arguments
if nargin == 5   % cross-covariance
    f = varargin{1};
    g = varargin{2};
    L1 = varargin{3};
    L12 = varargin{4};
    dt = varargin{5};
else  
    if nargin == 3   % auto-covariance
        f = varargin{1};
        g = f;
        L1 = varargin{2};
        L12 = 0;
        dt = varargin{3};
    else
        error('axcf: Incorrect number of input arguments');
    end
end

% The number of samples in f
nsampl = length(f);

% Check the size of the final covariance matrix
if nsampl > 22360
    display('axcf: The covariance matrix require more than 4GB of memory');
elseif nsampl > 11180
    display('axcf: The covariance matrix require more than 1GB of memory');
elseif nsampl > 5590
    display('axcf: The covariance matrix require more than 250MB of memory');
end

% Check the length and preallocate output C matrix
if nsampl ~= length(g)
    error('axcf: Signals f ang g have to have the same length');
else
    C = zeros(nsampl);
end

% Prepare smoothing windovs
L1s = ceil(L1/dt);
if L1s < 3
    L1s = 3;
    display(['axcf: L1 changed to the minimum allowed value: ',num2str(L1s*dt),' [s]'])
end
L12s = max(ceil(L12/dt),1);

% Put zeros (values) before and after the signal
Lzeros = max(L1s,L12s);
f = [zeros(Lzeros,1)+f(1); f(:); zeros(Lzeros,1)+f(end)];
g = [zeros(Lzeros,1)+g(1); g(:); zeros(Lzeros,1)+g(end)];

% New number of samples
nsamplN = nsampl + 2*Lzeros;

% Smooth f and g signals
fSmooth = smooth(f,L1s,'moving');
gSmooth = smooth(g,L12s,'moving');

% Compute ACF for time-lags
ACF = zeros(nsamplN,nsamplN*2);
for tshift = 1 : nsamplN*2 % loop for time-lags (nsamplN+1 is zero time-lag)
    gShift = circshift(gSmooth,tshift-(nsamplN+1));
    ACF(:,tshift) = smooth( f.*gShift, L1s, 'moving' ) ...
        - (fSmooth.*smooth( gShift, L1s, 'moving' )  );
end

% Fill the covariance matrix by ACF
for i=1:nsampl % loop for rows
    for j=1:nsampl % loop for columns
        C(i,j) = ACF(i+Lzeros,nsamplN+1-(j-i));
    end
end

% Check if covariance matrix is symmetric (in case any numerical issues)
if isequal(f,g) % only auto-covariance
    issym = @(x) all(all(x==x.'));
    if ~issym(C)
        % Symmetrize it
        Cm = triu(ones(nsampl));
        C = C.*Cm;
        C = C + tril(C.',-1);
        %display('xacf: The covariance matrix was symmetrized')
    end
end

return