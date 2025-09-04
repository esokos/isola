function [trd,plg] = CartToSph(cn,ce,cd)
%CartToSph converts from cartesian to spherical coordinates 
%
%   [trd,plg] = CartToSph(cn,ce,cd) returns the trend (trd)
%   and plunge (plg) of a line for input north (cn), east (ce), 
%   and down (cd) direction cosines
%
%   NOTE: Trend and plunge are returned in radians
%
%   CartToSph uses function ZeroTwoPi
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Plunge (see Table 2.1)
plg = asin(cd);

%Trend
%If north direction cosine is zero, trend is east or west
%Choose which one by the sign of the east direction cosine
if cn == 0.0 
    if ce < 0.0 
        trd = 3.0/2.0*pi; % trend is west
    else
        trd = pi/2.0; % trend is east
    end
%Else use Table 2.1
else
    trd = atan(ce/cn); 
    if cn < 0.0
        %Add pi 
        trd = trd+pi;
    end
    %Make sure trd is between 0 and 2*pi
    trd = ZeroTwoPi(trd);
end

end