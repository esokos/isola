function r = CorrSpher(xp,yp,laj)
%CorrSpher calculates the correlation matrix for a spherical variogram
%
%   USE: r=CorrSpher(xp,yp,laj)
%
%   xp = vector with x locations of points along bed
%   yp = vector with y locations of points along bed
%   laj = correlation length
%   r = correlation matrix
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Number of points along bed
nj = max(size(xp));

%Initialize correlation matrix
r = zeros(nj,nj);

%Compute correlation matrix
for i=1:nj
    for j=1:nj
        %Find distance v between points i and j along bed
        v = 0.0;
        minind = min(i,j); %minimum index
        maxind = max(i,j); %maximum index
        for k = minind:1:maxind-1
            v = v + sqrt((xp(k)-xp(k+1))^2 + (yp(k)-yp(k+1))^2);
        end
        %Compute variogram entry
        h = v/laj;
        %If within correlation length
        if h < 1.0
            r(i,j)=1.0+0.5*(-3*h + h^3);
        end
    end
end

end