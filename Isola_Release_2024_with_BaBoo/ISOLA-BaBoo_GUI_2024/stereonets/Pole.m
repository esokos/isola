function [trd1,plg1] = Pole(trd,plg,k)
%Pole returns the pole to a plane or the plane which correspond to a pole 
%
%   k is an integer that tells the program what to calculate. 
%
%   If k = 0, [trd1,plg1] = Pole(trd,plg,k) returns the strike 
%   (trd1) and dip (plg1) of a plane, given the trend (trd) 
%   and plunge (plg) of its pole.
%
%   If k = 1, [trd1,plg1] = Pole(trd,plg,k) returns the trend
%   (trd1) and plunge (plg1) of a pole, given the strike (trd)
%   and dip (plg) of its plane.
%
%   NOTE: Input/Output angles are in radians. Input/Output strike 
%   and dip are in right hand rule
%
%   Pole uses functions ZeroTwoPi, SphToCart and CartToSph
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Some constants
east = pi/2.0;

%Calculate plane given its pole
if k == 0
    if plg >= 0.0
        plg1 = east - plg;
        dipaz = trd - pi;
    else
        plg1 = east + plg;
        dipaz = trd;
    end
    %Calculate trd1 and make sure it is between 0 and 2*pi
    trd1 = ZeroTwoPi(dipaz - east);
%Else calculate pole given its plane
elseif k == 1
    [cn,ce,cd] = SphToCart(trd,plg,k);
    [trd1,plg1] = CartToSph(cn,ce,cd);
end

end