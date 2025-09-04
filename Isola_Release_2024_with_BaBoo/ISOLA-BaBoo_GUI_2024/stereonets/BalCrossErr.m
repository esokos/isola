function [short,shortp,defa,inw] = BalCrossErr(strat,vert,kk)
%BalCrossErr computes the shortening error in area balanced cross sections.
%The algorithm was originally written by Phoebe A. Judge
%
%   USE: [short,shortp,defa,inw] = BalCrossErr(strat,vert,kk)
%
%   strat= 1 x 5 vector with east stratigraphic thickness (entry 1),
%          west strat. thickness (entry 2), error on east strat
%          thickness (entry 3), error on west strat thickness 
%          (entry 4), and error on final width (entry 5)
%   vert= number of vertices x 5 vector with x coordinates of vertices 
%         (column 1), y coords of vertices (column 2), errors in x
%         coords of vertices (column 3), errors in y coords of vertices 
%         (column 4), and vertices tags (column 5). The vertices tags are 
%         as follows: 1 = Vertex at decollement, 2 = Vertex at surface, 
%         3 = Vertex at subsurface, 4 = Vertex at eroded hanging-wall
%         cutoff
%   kk = A flag to indicate wether the program computes total errrors 
%        (kk = 0), errors due to stratigraphy only (kk = 1), errors due to
%        vertices at decollement only (kk = 2), errors due to vertices in
%        eroded hanging walls only (kk = 3), errors due to surface vertices
%        (kk = 4), or errors due to subsurface vertices (kk = 5)
%   short = Shortening magnitude and its gaussian and maximum errors
%   shortp = Shortening percentage and its gaussian and maximum errrors
%   defa = Deformed area and its gaussian and maximum errors
%   inw = Initial width and its gaussian and maximum errors
%   
%   NOTE: The user selects the length units of the problem. Typical length
%         units are kilometers
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Stratigraphic thicknesses
E1 = strat(1);  %E strat thickness
W1 = strat(2);  %W strat thickness
dE1 = strat(3);  %Uncertainty on E strat thickness
dW1 = strat(4);  %Uncertainty on W strat thickness
dx2 = strat(5);  %Uncertainty on the final width

%Vertices
X = vert(:,1); %x coordinate
Y = vert(:,2); %y coordinate
dX = vert(:,3); %Uncertainty in x
dY = vert(:,4); %Uncertainty in y
Loc = vert(:,5); %Vertex location
n = size(vert,1); %Number of vertices

%If only errors due to stratigraphy
if kk == 1
    dx2 = 0.0; %Make uncertainty on the final width zero
    dX = dX * 0.0; %Make errors in vertices locations zero
    dY = dY * 0.0;
%If only errors due to vertices
elseif kk > 1
    dE1 = 0.0; %Make errors in stratigraphy zero
    dW1 = 0.0;
    dx2 = 0.0; %Make error in final width zero
    for i=1:n
        %If only errors due to decollement vertices
        if kk == 2
            if Loc(i) ~= 1
                dX(i) = 0.0; %Make errors in other vertices zero
                dY(i) = 0.0;
            end
        %If only errors due to eroded hanging walls
        elseif kk == 3
            if Loc(i) ~= 4
                dX(i) = 0.0; %Make errors in other vertices zero
                dY(i) = 0.0;
            end
        %If only errors due to surface vertices
        elseif kk == 4
            if Loc(i) ~= 2
                dX(i) = 0.0; %Make errors in other vertices zero
                dY(i) = 0.0;
            end
        %If only errors due to subsurface vertices
        elseif kk == 5
            if Loc(i) ~= 3
                dX(i) = 0.0; %Make errors in other vertices zero
                dY(i) = 0.0;
            end
        end
    end
end

%Initialize output variables
short = zeros(1,3); shortp = zeros(1,3); 
defa = zeros(1,3); inw = zeros(1,3);

%Deformed area
%Calculate area of deformed state
aX = [X; X(1)];
aY = [Y; Y(1)];
XArea = 0.5*(aX(1:n).*aY(2:n+1) - aX(2:n+1).*aY(1:n));
defa(1) = (abs(sum(XArea)));
%Calculate gaussian uncertainty of deformed area
aX = [X(n); aX];
aY = [Y(n); aY];
dAx = 0.5*(aY(3:n+2) - aY(1:n));
dAy = 0.5*(aX(3:n+2)- aX(1:n));
delAx = (dAx.*dX).^2;
delAy = (dAy.*dY).^2;
%Sum the X and Y components
SdelAx = sum(delAx);  
SdelAy = sum(delAy); 
%take the square root of the sum of individual components 
defa(2) = sqrt(SdelAx+SdelAy);  
%Calculate maximum uncertainty of deformed area
dAxM = abs(dAx); dAyM = abs(dAy);
delAxM = dAxM.*dX;
delAyM = dAyM.*dY;
%sum the X and Y components
SdelAxM = sum(delAxM);  
SdelAyM = sum(delAyM);  
%Add everything together to get the maximum uncertainty in Area
defa(3) = SdelAxM+SdelAyM;

%Original width
%Calculate the original width assuming constant Area
inw(1) = defa(1)/(((E1)/2)+((W1)/2));
%Calculate final width from the imported polygon
x21 = max(X) - min(X);  
%Calculate gaussian uncertainty of the original width
ddA = 1/(((E1)/2)+((W1)/2));  %partial of x1 wrt Area
ddE1 = -(2*defa(1))/((E1)^2+(2*E1*W1)+(W1)^2);  %partial of x1 wrt E1
ddW1 = -(2*defa(1))/((E1)^2+(2*E1*W1)+(W1)^2);  %partial of x1 wrt W1
inw(2) = sqrt(((ddA*defa(2))^2)+((ddE1*dE1)^2)+((ddW1*dW1)^2)); 
%Calculate maximum uncertainty of the original width
inw(3) = ((abs(ddA*defa(3)))+(abs(ddE1*dE1))+(abs(ddW1*dW1))); 

%Shortening
%Calculate shortening
short(1) = inw(1)-x21;
%Calculate gaussian uncertainty in shortening
short(2) = sqrt((inw(2))^2+(dx2)^2); 
%Calculate maximum uncertainty in shortening
short(3) = (inw(3)+dx2) ;
%Calculate percent shortening
shortp(1) = (1-(x21/inw(1)))*100;   
%Calculate gaussian uncertainty of percent shortening
ddx1 = x21/((inw(1))^2);  %partial of S wrt x1
ddx2 = -1/inw(1);  %partial of S wrt x2
shortp(2) = sqrt(((ddx1*inw(2))^2)+((ddx2*dx2)^2))*100;
%Calculate maximum uncertainty in shortening
shortp(3) = (abs(ddx1*inw(3))+(abs(ddx2*dx2)))*100;

end