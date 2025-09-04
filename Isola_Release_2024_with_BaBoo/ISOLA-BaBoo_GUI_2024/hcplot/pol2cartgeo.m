function [xe,yn]=pol2cartgeo(azm,dist)

xe=sin(azm)*dist;
yn=cos(azm)*dist;