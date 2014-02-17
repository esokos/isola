function [d]=bandpass(c,flp,fhi,npts,delt) 
% 
% [d]=bandpass(c,flp) 
% 
% bandpass a time series with a 4th order butterworth filter 
% 
% c = input time series 
% flp = lowpass corner frequency of filter 
% fhi = hipass corner frequency 
% npts = samples in data 
% delt = sampling interval of data 
% 
n=2;      % 4th order butterworth filter 
fnq=1/(2*delt);  % Nyquist frequency 
Wn=[flp/fnq fhi/fnq];    % butterworth bandpass non-dimensional frequency 
[b,a]=butter(n,Wn); % construct the filter 
d=filtfilt(b,a,c); % zero phase filter the data 
return;
