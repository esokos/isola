function [vX,vY]=maketriangle(x,y,dur)

% calculate coordinates of triangle edges based on x,y of base center

halfdur=dur/2;

vX(1)=x-halfdur;
vY(1)=0;

vX(2)=x;
vY(2)=y;

vX(3)=x+halfdur;
vY(3)=0;



