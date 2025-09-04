function [path1,path2,np1,np2] = SmallCircle(trda,plga,coneAngle,sttype)
%SmallCircle computes the paths of a small circle defined by its axis and
%cone angle, for an equal angle or equal area stereonet of unit radius
%
%   USE: [path1,path2,np1,np2] = SmallCircle(trda,plga,coneAngle,sttype)
%
%   trda = trend of axis
%   plga = plunge of axis
%   coneAngle = cone angle
%   sttype = type of stereonet. 0 for equal angle and 1 for equal area
%   path1 and path2 = vectors with the x and y coordinates of the points
%                     in the small circle paths
%   np1 and np2 = Number of points in path1 and path2, respectively
%
%   NOTE: All angles should be in radians
%
%   SmallCircle uses functions ZeroTwoPi, StCoordLine and Rotate
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Find where to start the small circle
if (plga - coneAngle) >= 0.0
    trd = trda;
    plg = plga - coneAngle;
else
    if plga == pi/2.0
        plga = plga * 0.9999;
    end
    angle = acos(cos(coneAngle)/cos(plga));
    trd = ZeroTwoPi(trda+angle);
    plg = 0.0;
end

%To make the small circle, rotate the starting line 360 degrees in
%increments of 1 degree
rot=(0:1:360)*pi/180;
path1 = zeros(size(rot,2),2);
path2 = zeros(size(rot,2),2);
np1 = 0; np2 = 0;
for i=1:size(rot,2)
    %Rotate line: Notice that here the line is considered as a vector
    [rtrd,rplg] = Rotate(trda,plga,rot(i),trd,plg,'v');
    % Add to the right path
    % If plunge of rotated line is positive add to first path
    if rplg >= 0.0
        np1 = np1 + 1;
        %Calculate stereonet coordinates and add to path
        [path1(np1,1),path1(np1,2)] = StCoordLine(rtrd,rplg,sttype);
    %If plunge of rotated line is negative add to second path
    else
        np2 = np2 + 1;
        %Calculate stereonet coordinates and add to path
        [path2(np2,1),path2(np2,2)] = StCoordLine(rtrd,rplg,sttype);
    end
end

end