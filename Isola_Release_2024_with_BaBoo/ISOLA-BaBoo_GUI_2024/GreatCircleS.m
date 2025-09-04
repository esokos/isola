function path = GreatCircle(strike,dip,sttype)
%GreatCircle computes the great circle path of a plane in an equal angle
%or equal area stereonet of unit radius
%
%   USE: path = GreatCircle(strike,dip,sttype)
%
%   strike = strike of plane
%   dip = dip of plane
%   sttype = type of stereonet. 0 for equal angle and 1 for equal area
%   path = vector with x and y coordinates of points in great circle path
%
%   NOTE: strike and dip should be entered in radians. 
%
%   GreatCircle uses functions StCoordLine, Pole and Rotate
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Compute the pole to the plane. This will be the axis of rotation to make
%the great circle
[trda,plga] = Pole(strike,dip,1);

%Now pick a line at the intersection of the great circle with the primitive
%of the stereonet
trd = strike;
plg = 0.0;

%To make the great circle, rotate the line 180 degrees in increments
%of 1 degree
rot=(0:1:180)*pi/180;  % change 1 to 30 to be faster
path = zeros(size(rot,2),2);
for i=1:size(rot,2)
    %Avoid joining ends of path
    if rot(i) == pi
        rot(i) = rot(i)*0.9999;
    end
    %Rotate line
    [rtrd,rplg] = Rotate(trda,plga,rot(i),trd,plg,'a');
    %Calculate stereonet coordinates of rotated line and add to great
    %circle path
    [path(i,1),path(i,2)] = StCoordLine(rtrd,rplg,sttype);
end

end