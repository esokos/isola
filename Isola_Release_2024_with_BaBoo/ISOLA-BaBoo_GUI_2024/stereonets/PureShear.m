function [paths,pfs] = PureShear(pts,st1,ninc)
%PureShear computes and plots displacement paths and progressive finite
%strain history for pure shear with maximum stretching parallel to the 
%X1 axis
%
%   USE: [paths,pfs] = PureShear(pts,st1,ninc)
%
%   pts: npoints x 2 matrix with X1 and X3 locations of points
%   st1 = Maximum principal stretch
%   ninc = number of strain increments
%   paths = displacement paths of points
%   pfs = progressive finite strain history. column 1 = orientation of
%         maximum stretch with respect to X1 in degrees, column 2 = maximum
%         stretch magnitude
%
%   NOTE: Intermediate principal stretch is 1.0 (Plane strain)
%         Output orientations are in radians
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Compute minimum principal stretch and incremental stretches
st1inc=st1^(1.0/ninc);
st3=1.0/st1;
st3inc=st3^(1.0/ninc);

%Initialize displacement paths
npts = size(pts,1); %Number of points
paths = zeros(npts,2,ninc+1);
paths(:,:,1) = pts; %Initial points of paths are input points

%Calculate incremental deformation gradient tensor
F = [(st1inc) 0.0; 0.0 (st3inc)];

%Create a figure and hold
figure;
hold on;

%Compute displacement paths
for i=1:npts %for all points
    for j=2:ninc+1 %for all strain increments
        %Equations 10.2-10.5
        for k=1:2
            for L=1:2
                paths(i,k,j) = F(k,L)*paths(i,L,j-1) + paths(i,k,j);
            end
        end
    end
    %Plot displacement path of point. Use MATLAB function squeeze to reduce
    %the 3D matrix to one vector in X1 and another in X3
    xx = squeeze(paths(i,1,:));
    yy = squeeze(paths(i,2,:));
    plot(xx,yy,'k.-');
end

%Release plot and set axes
hold off;
axis equal;
xlabel('X1'); ylabel('X3');
grid on;

%Initalize progressive finite strain history
pfs = zeros(ninc+1,2);
pfs(1,:) = [0 1.0]; %Initial state

%Calculate progressive finite strain history
for i=1:ninc
    %First determine the finite deformation gradient tensor
   finF = F^i; 
   %Determine Green's deformation tensor
   G = finF*finF';
   %Stretch magnitude and orientation: Maximum eigenvalue and their
   %corresponding eigenvectors of Green's tensor. Use MATLAB function eig
   [V,D] = eig(G);
   pfs(i+1,1) = atan(V(2,2)/V(1,2));
   pfs(i+1,2) = sqrt(D(2,2));
end

%Plot progressive finite strain history
figure;
plot(pfs(:,1)*180/pi,pfs(:,2),'k.-');
xlabel('Theta finite deg');
ylabel('Maximum finite stretch');
axis([-90 90 1 max(pfs(:,2))+0.5]);
grid on;

end