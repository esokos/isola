function x = taper(n,f);
%   taper         make hanning taper
% usage: x = taper(n,f);
% construct an n point taper going to 1 at a fractional distance
% of f.  This is a hanning window if f=0.5 
% Try plot (taper(100,.1)) to see the taper
% Input parameters are scalars, output is a column vector of length n

m=round(n*f+.49999);
x=(0:2*m-1)'/(2*m-1);
y = .5*(1 - cos(2*pi*x));             % 2*m point hanning window
x=[y(1:m); ones(n-2*m,1); y(m+1:2*m)];
