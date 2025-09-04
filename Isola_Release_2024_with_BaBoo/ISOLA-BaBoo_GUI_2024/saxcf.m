function C = saxcf(varargin)
%
% MatLab function for determining the (cross-)covariance matrix by
% stationarized approximate (cross-)covariance function (SAXCF or SACF) (Hallo and Gallovic, 2016).
% Hallo, M., Gallovic, F. (2016): Fast and cheap approximation of Green functions
% uncertainty for waveform-based earthquake source inversions, Geophys. J. Int., 207 1012-1029.
%
% Authors: Miroslav Hallo and Frantisek Gallovic (1/2016)
% Charles University in Prague, Faculty of Mathematics and Physics
% Revision 1/2018: Corrected cosine taper to reduce influence of
%                  samples with large lag
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
% T - Dominant signal length [sec] (scalar)
% -------------------------------------------
%
% OUTPUT:
% C - stationarized (cross-)covariance matrix (2D matrix)
% -------------------------------------------
%
% EXAMPLES:
% saxcf(f,L1,dt,T) - Compute auto-covariance matrix of f
% saxcf(f,g,L1,L12,dt,T) - Compute cross-covariance matrix of f and g
% -------------------------------------------
%
% REQUIREMENTS:
% smooth (MatLab Curve Fitting Toolbox)
% filtfilt (MatLab Signal Processing Toolbox)
% -------------------------------------------
% -------------------------------------------

% Manage input arguments
if nargin == 6   % cross-covariance
    f = varargin{1};
    g = varargin{2};
    L1 = varargin{3};
    L12 = varargin{4};
    dt = varargin{5};
    T = varargin{6};
else  
    if nargin == 4   % auto-covariance
        f = varargin{1};
        g = f;
        L1 = varargin{2};
        L12 = 0;
        dt = varargin{3};
        T = varargin{4};
    else
        error('saxcf: Incorrect number of input arguments');
    end
end

% The number of samples in f
nsampl = length(f);

% Check the size of the final covariance matrix
if nsampl > 22360
    display('saxcf: The covariance matrix require more than 4GB of memory');
elseif nsampl > 11180
    display('saxcf: The covariance matrix require more than 1GB of memory');
elseif nsampl > 5590
    display('saxcf: The covariance matrix require more than 250MB of memory');
end

% Check the length and preallocate output C matrix
if nsampl ~= length(g)
    error('saxcf: Signals f ang g have to have the same length');
else
    C = zeros(nsampl);
end

% Check the triangle function base
L1s = round(L1/dt);
if L1s < 2
    L1s = 2;
    display(['saxcf: L1 changed to the minimum allowed value: ',num2str(L1s*dt),' [s]'])
end

% Cross-correlation of signals
RfgP = zeros(1,nsampl);
RfgN = zeros(1,nsampl);
for tshift=0:nsampl-1 % loop for time-lags
	RfgN(tshift+1) = sum(g(1:nsampl-tshift).*f(1+tshift:nsampl))*dt; % negative
    RfgP(tshift+1) = sum(f(1:nsampl-tshift).*g(1+tshift:nsampl))*dt; % positive
end
Rfg = [RfgN(nsampl:-1:2), RfgP(1:nsampl)];

% Convolution of triangle function (width 2*L1) and cross-correlation
b = ones(L1s,1)/L1s;
SCF = Rfg - filtfilt(b,1,Rfg);

% Smoothing by joint shift (width L12)
if ceil(L12/dt)>2
    SCF = smooth(SCF,ceil(L12/dt),'moving');
end

% Norm by the effective signal length
SCF = SCF/T;

% Taper of C matrix
taper = 0.666;
tw = tukeywin(length(SCF),taper);
tw = tw.^3;
SCF = SCF(:) .* tw(:);

% Fill the covariance matrix by SCF
for tshift=0:nsampl-1 % loop for rows
	C(tshift+1,:) = SCF(nsampl-tshift : 2*nsampl-tshift-1);
end

% Check if covariance matrix is symmetric (in case any numerical issues)
if isequal(f,g) % only auto-covariance
    issym = @(x) all(all(x==x.'));
    if ~issym(C)
        % Symmetrize it
        Cm = triu(ones(nsampl));
        C = C.*Cm;
        C = C + tril(C.',-1);
        %display('xscf: The covariance matrix was symmetrized')
    end
end

return