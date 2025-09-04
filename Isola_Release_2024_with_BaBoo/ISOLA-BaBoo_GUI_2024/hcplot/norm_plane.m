function [n]=norm_plane(strike,dip)

deg2rad=pi/180.;

strike=strike*deg2rad;
dip=dip*deg2rad;

n(1)=-sin(dip)*sin(strike);   % north
n(2)= sin(dip)*cos(strike);   % east
n(3)=-cos(dip);               % updown