function [cn,ce,cd] = SphToCart(trd,plg,k)
%SphToCart converts from spherical to cartesian coordinates 
%
%   [cn,ce,cd] = SphToCart(trd,plg,k) returns the north (cn), 
%   east (ce), and down (cd) direction cosines of a line.
%
%   k is an integer to tell whether the trend and plunge of a line 
%   (k = 0) or strike and dip of a plane in right hand rule 
%   (k = 1) are being sent in the trd and plg slots. In this 
%   last case, the direction cosines of the pole to the plane 
%   are returned
%
%   NOTE: Angles should be entered in radians 
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%If line (see Table 2.1)
if k == 0
    cd = sin(plg);
    ce = cos(plg) * sin(trd);
    cn = cos(plg) * cos(trd); 
%Else pole to plane (see Table 2.1)
elseif k == 1
    cd = cos(plg);
    ce = -sin(plg) * cos(trd);
    cn = sin(plg) * sin(trd);
end

end