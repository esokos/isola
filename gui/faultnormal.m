function [n,k] = faultnormal(strike,dip)

phi=deg2rad(strike);
delta=deg2rad(dip);

n(1)=-sin(delta)*sin(phi);
n(2)= sin(delta)*cos(phi);
n(3)=-cos(delta);

k=rad2deg(n);


