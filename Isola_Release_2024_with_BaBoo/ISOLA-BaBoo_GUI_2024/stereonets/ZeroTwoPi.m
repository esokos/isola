function b = ZeroTwoPi(a)
%ZeroTwoPi constrains azimuth to lie between 0 and 2*pi radians 
%
%   b = ZeroTwoPi(a) returns azimuth b (from 0 to 2*pi)
%   for input azimuth a (which may not be between 0 to 2*pi)
%
%   NOTE: Azimuths a and b are input/output in radians 
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

b=a;
twopi = 2.0*pi;
if b < 0.0
    b = b + twopi;
elseif b >= twopi
    b = b - twopi;
end

end