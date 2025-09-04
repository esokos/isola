% Example of MatLab code using the functions axcf.m and saxcf.m. The code
% creates two signals and then compute their covariance and
% cross-covariance matrices from AXCF and SAXCF (Hallo and Gallovic, 2016).
% Hallo, M., Gallovic, F. (2016): Fast and cheap approximation of Green functions
% uncertainty for waveform-based earthquake source inversions, Geophys. J. Int., 207 1012-1029.
%
% Authors: Miroslav Hallo and Frantisek Gallovic (1/2016)
% Charles University in Prague, Faculty of Mathematics and Physics
% Revision 1/2018: Corrected for real signals
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
% Requirements:
% smooth (MatLab Curve Fitting Toolbox)
% filtfilt (MatLab Signal Processing Toolbox)
% -------------------------------------------

clear all;
close all;

% Input settings
N = 200; % Length of data [samples]
dt = 0.1; % Sample interval [sec]
freq1 = 0.3; % Frequency of cosine [Hz]
T = 10; % Duration of the signal [sec]
gShift = 2.0; % Time shift of the g relatively to f (to generate signal g)[sec]
L1 = 2.0; % Width of joint uniform distribution of time-shifts [sec]
L12 = 1.0; % Width of relative uniform distribution of time-shifts [sec]

% Prepare the input signals
t = (0 : N-1)*dt;
tau = t - t(round(N/2));
f = cos(tau*freq1*2*pi) .* exp(-tau.^2/T);
g = circshift(f',round(gShift/dt))';

% Covariance matrix by ACF
Caa = axcf(f,L1,dt);

% Cross-covariance matrix by AXCF
Cxa = axcf(f,g,L1,L12,dt);

% Covariance matrix by SACF
Cas = saxcf(f,L1,dt,T);

% Cross-covariance matrix by SAXCF
Cxs = saxcf(f,g,L1,L12,dt,T);

% Plot f signal
figure('Units','normalized','Position',[0.3 0.1 0.4 0.8])
subplot(3,2,1)
plot(t,f)
xlabel('Time [s]')
title('Signal f')

% Plot f and g signals
subplot(3,2,2)
plot(t,f,t,g)
xlabel('Time [s]')
title('Signals f and g')

% Plot covariance matrix by ACF
subplot(3,2,3)
surfc(t,t,Caa);
axis equal;
shading flat;
view(0,90);
set(gca,'ydir','reverse');
colorbar;
xlabel('Time [s]'); ylabel('Time [s]')
title('Covariance matrix by ACF')

% Plot cross-covariance matrix by AXCF
subplot(3,2,4)
surfc(t,t,Cxa);
axis equal;
shading flat;
view(0,90);
set(gca,'ydir','reverse');
colorbar;
xlabel('Time [s]'); ylabel('Time [s]')
title('Cross-covariance matrix by AXCF')

% Plot covariance matrix by SACF
subplot(3,2,5)
surfc(t,t,Cas);
axis equal;
shading flat;
view(0,90);
set(gca,'ydir','reverse');
colorbar;
xlabel('Time [s]'); ylabel('Time [s]')
title('Covariance matrix by SACF')

% Plot covariance matrix by SAXCF
subplot(3,2,6)
surfc(t,t,Cxs);
axis equal;
shading flat;
view(0,90);
set(gca,'ydir','reverse');
colorbar;
xlabel('Time [s]'); ylabel('Time [s]')
title('Cross-covariance matrix by SAXCF')


