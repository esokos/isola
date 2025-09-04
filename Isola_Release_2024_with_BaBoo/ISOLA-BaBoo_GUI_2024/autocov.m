function acov=autocov(x,N)
%acov=autocov(x,N)
%x is the input vector in 1-D, N is the desired maximum autocovariance lag.
%The output acov is the NxN autocovariance matrix.

    lx=length(x);
    y=xcov(x,x);
    l=length(y);

    acov_tmp=toeplitz(y(lx:l));
    acov=acov_tmp(1:N,1:N)./lx;

