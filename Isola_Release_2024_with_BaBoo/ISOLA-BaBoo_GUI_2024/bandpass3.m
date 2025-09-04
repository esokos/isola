function [d]=bandpass3(c,flp,fhi,npts,delt,n) 
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
%n=2;      % 4th order butterworth filter, since band pass doubles order
fnq=1/(2*delt);  % Nyquist frequency 
Wn=[flp/fnq fhi/fnq];    % butterworth bandpass non-dimensional frequency 
[b,a]=butter(n,Wn,'bandpass'); % construct the filter 
d=filter(b,a,c); % single pass = causal filter

%freqz(b,a,1024,1/delt);
% fs=1/delt;
% [h2,f2]=freqz(b,a,2048,'whole',fs);
% figure
% loglog(f2,abs(h2),'o-')
% grid on
return;
