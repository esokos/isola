function ang=ang(a,b)

%real function ang (a,b)
 
fac=180./3.14159;
 
aa=sqrt(a(1)*a(1)+a(2)*a(2)+a(3)*a(3));
bb=sqrt(b(1)*b(1)+b(2)*b(2)+b(3)*b(3));
cab=(a(1)*b(1)+a(2)*b(2)+a(3)*b(3))/aa/bb;
sab=sqrt(abs(1.-cab*cab));

 if cab~=0 
    ang=atan(sab/cab)*fac;
 else
    ang=90.;
 end
