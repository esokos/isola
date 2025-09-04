function [P,T] = PTAxes(fault,slip)
%PTAxes computes the P and T axes from the orientation of several fault 
%planes and their slip vectors. Results are plotted in an equal area 
%stereonet
%
%   USE: [P,T] = PTAxes(fault,slip)
%
%   fault = nfaults x 2 vector with strikes and dips of faults
%   slip = nfaults x 2 vector with trends and plunges of slip vectors
%   P = nfaults x 2 vector with trends and plunges of the P axes
%   T = nfaults x 2 vector with trends and plunges of the T axes
%
%   NOTE: Input/Output angles are in radians
%
%   PTAxes uses functions SphToCart, CartToSph, Stereonet, GreatCircle and
%   StCoordLine
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Initialize some vectors
n = zeros(1,3);
u = zeros(1,3);
eps = zeros(3,3);
P = zeros(size(fault,1),2);
T = zeros(size(fault,1),2);

%For all faults
for i=1:size(fault,1)
    %Direction cosines of pole to fault and slip vector
    [n(1),n(2),n(3)] = SphToCart(fault(i,1),fault(i,2),1);
    [u(1),u(2),u(3)] = SphToCart(slip(i,1),slip(i,2),0);
    %Compute u(i)*n(j) + u(j)*n(i) (Eq. 8.32)
    for j=1:3
        for k=1:3
            eps(j,k)=(u(j)*n(k)+u(k)*n(j));
        end
    end
    %Compute orientations of principal axes of strain. Here we use the 
    %MATLAB function eig
    [V,D] = eig(eps);
    %P orientation
    [P(i,1),P(i,2)] = CartToSph(V(1,3),V(2,3),V(3,3));
    %T orientation
    [T(i,1),T(i,2)] = CartToSph(V(1,1),V(2,1),V(3,1)); 
end

%Plot stereonet
Stereonet(0,90*pi/180,10*pi/180,1);
hold on;
%Plot other elements
for i=1:size(fault,1)
    %Plot fault
    [path] = GreatCircle(fault(i,1),fault(i,2),1);
    plot(path(:,1),path(:,2),'r');
    %Plot Slip vector (red square)
    [xp,yp] = StCoordLine(slip(i,1),slip(i,2),1);
    plot(xp,yp,'rs');
    %Plot P axis (black, filled circle)
    [xp,yp] = StCoordLine(P(i,1),P(i,2),1);
    plot(xp,yp,'ko','MarkerFaceColor','k');
    %Plot T axis (black circle)
    [xp,yp] = StCoordLine(T(i,1),T(i,2),1);
    plot(xp,yp,'ko');
end

%Release plot
hold off;

end