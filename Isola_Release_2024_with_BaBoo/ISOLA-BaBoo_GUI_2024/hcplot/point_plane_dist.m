function [pl_dist]=point_plane_dist(strike,dip,hx,hy,hz,cx,cy,cz)

v=norm_plane(strike,dip);

xdif=hx-cx;
ydif=hy-cy;
zdif=hz-cz;

% w=[xdif;ydif;zdif];

% pl_dist=abs(v*w)/abs(sqrt(v*v'));

sproduct=v(1)*xdif+v(2)*ydif+v(3)*zdif;	%! scalar produc = normal * vector distance
pl_dist=abs(sproduct)



