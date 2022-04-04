function [p,f]=myfft(x,dt)

% Taper fixed 
taperv=20;
x=taperd(x,taperv/100);

%%fft
fs=1/dt;
m = length(x);            % Window length
n = pow2(nextpow2(m));    % Transform length
y = fft(detrend(x),n);    % DFT of signal
f = (0:n-1)*(fs/n);       % Frequency range
p = abs(y)*dt;            % Fourier amplitude

f=f(1:floor(n/2));
p=p(1:floor(n/2));



