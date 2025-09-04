function nstress = TransformStress(stress,tX1,pX1,tX3,ntX1,npX1,ntX3)
%TransformStress transforms a stress tensor from old X1,X2,X3 to new X1'
%,X2',X3' coordinates
%
%   USE: nstress = TransformStress(stress,tX1,pX1,tX3,ntX1,npX1,ntX3)
%
%   stress = 3 x 3 stress tensor
%   tX1 = trend of X1 
%   pX1 = plunge of X1 
%   tX3 = trend of X3
%   ntX1 = trend of X1'
%   npX1 = plunge of X1'
%   ntX3 = trend of X3'
%	nstress = 3 x 3 stress tensor in new coordinate system
%
%   NOTE: All input angles should be in radians
%
%   TransformStress uses function DirCosAxes
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Direction cosines of axes of old coordinate system
odC = DirCosAxes(tX1,pX1,tX3);

%Direction cosines of axes of new coordinate system
ndC = DirCosAxes(ntX1,npX1,ntX3);

%Transformation matrix between old and new coordinate system
a = zeros(3,3);
for i = 1:3
    for j = 1:3
        %Use dot product
        a(i,j) = ndC(i,1)*odC(j,1) + ndC(i,2)*odC(j,2) + ndC(i,3)*odC(j,3);
    end
end

%Transform stress tensor from old to new coordinate system (Eq. 5.12)
nstress = zeros(3,3);
for i = 1:3	
	for j = 1:3	
		for k = 1:3	
			for L = 1:3	
				nstress(i,j) = a(i,k)*a(j,L)*stress(k,L)+nstress(i,j);
			end
		end
	end
end

end