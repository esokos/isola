function [eigVec,confCone,bestFit] = Bingham(T,P)
%Bingham calculates and plots a cylindrical best fit to a pole distribution
%to find fold axes from poles to bedding or the orientation of a plane from
%two apparent dips. The statistical routine is based on algorithms in
%Fisher et al. (1988)
%
%   USE: [eigVec,confCone,bestFit] = Bingham(T,P)
%
%   T and P = Vectors of lines trends and plunges respectively
%
%   eigVec= 3 x 3 matrix with eigenvalues (column 1), and trends (column 2)
%   and plunges (column 3) of the eigenvectors. Maximum eigenvalue and 
%   corresponding eigenvector are in row 1, intermediate in row 2, 
%   and minimum in row 3.
%
%   confCone = 2 x 2 matrix with the maximum (column 1) and minimum 
%   (column 2) radius of the 95% elliptical confidence cone around the 
%   eigenvector corresponding to the largest (row 1), and lowest (row 2) 
%   eigenvalue
%
%   besFit = 1 x 2 vector containing the strike and dip (right hand rule) 
%   of the best fit great circle to the distribution of lines
%
%   NOTE: Input/Output trends and plunges, as well as confidence
%   cones are in radians. Bingham plots the input lines, eigenvectors and
%   best fit great circle in an equal area stereonet.
%   
%   Bingham uses functions ZeroTwoPi, SphToCart, CartToSph, Stereonet, 
%   StCoordLine and GreatCircle
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Some constants
east = pi/2.0;
twopi = pi*2.0;

%Number of lines
nlines = max(size(T));

%Initialize the orientation matrix
a=zeros(3,3);

%Fill the orientation matrix with the sums of the squares (for the 
%principal diagonal) and the products of the direction cosines of each
%line. cn, ce and cd are the north, east and down direction cosines
for i = 1:nlines
    [cn,ce,cd] = SphToCart(T(i),P(i),0);
    a(1,1) = a(1,1) + cn*cn;
    a(1,2) = a(1,2) + cn*ce;
    a(1,3) = a(1,3) + cn*cd;
    a(2,2) = a(2,2) + ce*ce;
    a(2,3) = a(2,3) + ce*cd;
    a(3,3) = a(3,3) + cd*cd;
end

%The orientation matrix is symmetric so the off-diagonal components can be
%equated
a(2,1) = a(1,2);
a(3,1) = a(1,3);
a(3,2) = a(2,3);

%Calculate the eigenvalues and eigenvectors of the orientation matrix using
%MATLAB function eig. D is a diagonal matrix of eigenvalues and V is a 
%full matrix whose columns are the corresponding eigenvectors
[V,D] = eig(a);

%Normalize the eigenvalues by the number of lines and convert the
%corresponding eigenvectors to the lower hemisphere
for i = 1:3
    D(i,i) = D(i,i)/nlines;
    if V(3,i) < 0.0
        V(1,i) = -V(1,i);
        V(2,i) = -V(2,i);
        V(3,i) = -V(3,i);
    end
end

%Initialize eigVec
eigVec = zeros(3,3);
%Fill eigVec
eigVec(1,1) = D(3,3); %Maximum eigenvalue
eigVec(2,1) = D(2,2); %Intermediate eigenvalue
eigVec(3,1) = D(1,1); %Minimum eigenvalue
%Trend and plunge of largest eigenvalue: column 3 of V
[eigVec(1,2),eigVec(1,3)] = CartToSph(V(1,3),V(2,3),V(3,3));
%Trend and plunge of intermediate eigenvalue: column 2 of V
[eigVec(2,2),eigVec(2,3)] = CartToSph(V(1,2),V(2,2),V(3,2));
%Trend and plunge of minimum eigenvalue: column 1 of V
[eigVec(3,2),eigVec(3,3)] = CartToSph(V(1,1),V(2,1),V(3,1));

%Initialize confCone
confCone = zeros(2,2);
%If there are more than 25 lines, calculate confidence cones at the 95%
%confidence level. The algorithm is explained in Fisher et al. (1998)
if nlines >= 25
    e11 = 0.0;
    e22 = 0.0;
	e12 = 0.0;
	d11 = 0.0;
	d22 = 0.0;
	d12 = 0.0;
	en11 = 1.0/(nlines*(eigVec(3,1) - eigVec(1,1))^2);
    en22 = 1.0/(nlines*(eigVec(2,1) - eigVec(1,1))^2);
    en12 = 1.0/(nlines*(eigVec(3,1) - eigVec(1,1))*(eigVec(2,1)...
        - eigVec(1,1)));
	dn11 = en11;
	dn22 = 1.0/(nlines*(eigVec(3,1) - eigVec(2,1))^2);
	dn12 = 1.0/(nlines*(eigVec(3,1) - eigVec(2,1))*(eigVec(3,1)...
        - eigVec(1,1)));
    vec = zeros(3,3);
    for i = 1:3
        vec(i,1) = sin(eigVec(i,3) + east)*cos(twopi - eigVec(i,2));
        vec(i,2) = sin(eigVec(i,3) + east)*sin(twopi - eigVec(i,2));
        vec(i,3) = cos(eigVec(i,3) + east);
    end
    for i = 1:nlines
        c1 = sin(P(i)+east)*cos(twopi-T(i));
		c2 = sin(P(i)+east)*sin(twopi-T(i));
		c3 = cos(P(i)+east);
		u1x = vec(3,1)*c1 + vec(3,2)*c2 + vec(3,3)*c3;
		u2x = vec(2,1)*c1 + vec(2,2)*c2 + vec(2,3)*c3;
		u3x = vec(1,1)*c1 + vec(1,2)*c2 + vec(1,3)*c3;
		e11 = u1x*u1x * u3x*u3x + e11;
		e22 = u2x*u2x * u3x*u3x + e22;
		e12 = u1x *u2x * u3x*u3x + e12;
		d11 = e11;
		d22 = u1x*u1x * u2x*u2x + d22;
		d12 = u2x * u3x * u1x*u1x + d12;
    end
    e22 = en22*e22;
	e11 = en11*e11;
	e12 = en12*e12;
	d22 = dn22*d22;
	d11 = dn11*d11;
	d12 = dn12*d12;
	d = -2.0*log(.05)/nlines;
    % initialize f
    f = zeros(2,2);
    if abs(e11*e22-e12*e12) >= 0.000001 
        f(1,1) = (1/(e11*e22-e12*e12)) * e22;
		f(2,2) = (1/(e11*e22-e12*e12)) * e11;
		f(1,2) = -(1/(e11*e22-e12*e12)) * e12;
		f(2,1) = f(1,2);
        %Calculate the eigenvalues and eigenvectors of the matrix f using
        %MATLAB function eig. The next lines follow steps 1-4 outlined on 
        %pp. 34-35 of Fisher et al. (1988)
        DD = eig(f);
        if DD(1) > 0.0 && DD(2) > 0.0
            if d/DD(1) <= 1.0 && d/DD(2) <= 1.0
                confCone(1,2) = asin(sqrt(d/DD(2)));
                confCone(1,1) = asin(sqrt(d/DD(1)));
            end
        end
    end
    % Repeat the process for the eigenvector corresponding to the smallest
    % eigenvalue
    if abs(d11*d22-d12*d12) >= 0.000001
        f(1,1) = (1/(d11*d22-d12*d12)) * d22;
        f(2,2) = (1/(d11*d22-d12*d12)) * d11;
        f(1,2) = -(1/(d11*d22-d12*d12)) * d12;
        f(2,1) = f(1,2);
        DD = eig(f);
        if DD(1) > 0.0 && DD(2) > 0.0
            if d/DD(1) <= 1.0 && d/DD(2) <= 1.0
                confCone(2,2) = asin(sqrt(d/DD(2)));
                confCone(2,1) = asin(sqrt(d/DD(1)));
            end
        end
    end
end

%Calculate the best fit great circle to the distribution of points
bestFit=zeros(1,2);
bestFit(1) = ZeroTwoPi(eigVec(3,2) + east);
bestFit(2) = east - eigVec(3,3);

%Plot stereonet
Stereonet(0,90*pi/180,10*pi/180,1);

%Plot lines
hold on;
for i = 1:nlines
    [xp,yp] = StCoordLine(T(i),P(i),1);
    plot(xp,yp,'k.');
end

%Plot eigenvectors
for i = 1:3
    [xp,yp] = StCoordLine(eigVec(i,2),eigVec(i,3),1);
    plot(xp,yp,'rs');
end

%Plot best fit great circle
[path] = GreatCircle(bestFit(1),bestFit(2),1);
plot(path(:,1),path(:,2),'r');

%release plot
hold off;

end