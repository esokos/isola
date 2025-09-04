function [ans1,ans2] = Angles(trd1,plg1,trd2,plg2,ans0)
%Angles calculates the angles between two lines, between two planes,
%the line which is the intersection of two planes, or the plane 
%containing two apparent dips
%
%   [ans1,ans2] = Angles(trd1,plg1,trd2,plg2,ans0) operates on
%   two lines or planes with trend/plunge or strike/dip equal to 
%   trd1/plg1 and trd2/plg2
%
%   ans0 is a character that tells the function what to calculate:
%
%       ans0 = 'a' -> the orientation of a plane given two apparent dips
%       ans0 = 'l' -> the angle between two lines
%
%       In the above two cases, the user sends the trend and plunge of two
%       lines
%
%       ans0 = 'i' -> the intersection of two planes
%       ans0 = 'p' -> the angle between two planes
%
%       In the above two cases the user sends the strike and dip of two
%       planes following the right hand rule
%
%   NOTE: Input/Output angles are in radians
%
%   Angles uses functions SphToCart, CartToSph and Pole
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%If planes have been entered
if ans0 == 'i' || ans0 == 'p'
    k = 1;
%Else if lines have been entered
elseif ans0 == 'a' || ans0 == 'l'
    k = 0;
end

%Calculate the direction cosines of the lines or poles to planes
[cn1,ce1,cd1]=SphToCart(trd1,plg1,k);
[cn2,ce2,cd2]=SphToCart(trd2,plg2,k);

%If angle between 2 lines or between the poles to 2 planes
if ans0 == 'l' || ans0 == 'p'
    % Use dot product = Sum of the products of the direction cosines
    ans1 = acos(cn1*cn2 + ce1*ce2 + cd1*cd2);
    ans2 = pi - ans1;
end

%If intersection of two planes or pole to a plane containing two
%apparent dips
if ans0 == 'a' || ans0 == 'i'
    %If the 2 planes or apparent dips are parallel return an error
    if trd1 == trd2 && plg1 == plg2
        error('lines or planes are parallel');
    %Else use cross product
    else
        cn = ce1*cd2 - cd1*ce2;
        ce = cd1*cn2 - cn1*cd2;
        cd = cn1*ce2 - ce1*cn2;
        %Make sure the vector points down into the lower hemisphere
        if cd < 0.0
            cn = -cn;
            ce = -ce;
            cd = -cd;
        end
        %Convert vector to unit vector by dividing it by its length
        r = sqrt(cn*cn+ce*ce+cd*cd);
        % Calculate line of intersection or pole to plane
        [trd,plg]=CartToSph(cn/r,ce/r,cd/r);
        %If intersection of two planes
        if ans0 == 'i'
            ans1 = trd;
            ans2 = plg;
        %Else if plane containing two dips, calculate plane from its pole
        elseif ans0 == 'a'
            [ans1,ans2]= Pole(trd,plg,0);
        end 
    end
end

end