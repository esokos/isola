function d1=taperd(d,f);
%   taperd        apply hanning taper to a vector
% usage: d1=taperd(d,f)
% taper the columns of data array d with an f% cosine taper
% eg. taperd(d,.05) tapers 5% from the beginning and end of
% the time series.

[m,n]=size(d);
% for ii=1:m
%       d1(:,ii)=d(:,ii).*taper(n,f);
% end;
x=taper(m,f);
d1=d.*x;
% whos x d d1