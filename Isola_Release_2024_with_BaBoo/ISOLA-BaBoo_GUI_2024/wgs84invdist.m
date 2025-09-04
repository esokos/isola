function [lat2_out, lon2_out, baz_out] = wgs84invdist(varargin)
%------------------------------------------------------------------------------
% function [lat2, lon2, baz] = wgs84invdist(lat1, lon1, faz, s [, deg_in, deg_out])
%
% This code is part of the geodetic tool kit, which can be downloaded
% from the National Oceanic and Atmospheric Administration (NOAA)
% National Geodetic Survey (ngs) website at:
% http://www.ngs.noaa.gov/index.shtml.
%
% Input Description
%
% lat1 initial latitude (rad or deg)
% lon1 initial longitude (rad or deg)
% faz forward azimuth (rad or deg)
% s surface distance along ellipsoid (m)
% deg_in selects whether input angular quantities are in degrees or
% radians (deg = 1 for degrees, radians is default)
% deg_out selects whether output angular quantities are in degrees or
% radians (deg = 1 for degrees, radians is default)
%
% Output Description
%
% lat2 final latitude (rad or deg)
% lon2 final longitude (rad or deg)
% baz backward azimuth (rad or deg)
%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
% Original source code comments:
%
% Solution of the geodetic direct problem after T.Vincenty
% modified Rainsford's method with Helmert's elliptical terms
% effective in any azimuth and at any distance short of antipodal
% standpoint/forepoint must not be the geographic pole
%
% a is the semi-major axis of the reference ellipsoid
% f is the flattening of the reference ellipsoid
% latitudes and longitudes in radians positive north and east
% forward azimuths at both points returned in radians from north
%
% programmed for cdc-6600 by LCDR L.Pfeifer NGS Rockville MD 18FEB75
% modified for system 360 by John G Gergen NGS Rockville MD 7507
%------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% check input arguments
%-------------------------------------------------------------------------------
error(nargchk(4, 6, nargin));

%-------------------------------------------------------------------------------
% check for input errors (e.g., inputs have incorrect number of rows or columns)
%-------------------------------------------------------------------------------
rows = zeros(1,nargin);
cols = zeros(1,nargin);

for ii=1:nargin,
[rows(ii), cols(ii)] = size(varargin{ii});
end

maxrows = max(rows);

% make sure each input has either 1 row or n rows
inputerr = any(rows ~= 1 & rows ~= maxrows);

if inputerr,
error('inputs must have either 1 row or n rows')
end

% all inputs must have 1 column
inputerr = any(cols ~= 1);

if inputerr
error('all inputs must have one column');
end

%-------------------------------------------------------------------------------
% expand inputs as necessary
%-------------------------------------------------------------------------------
expand = any(rows == 1) & (maxrows > 1);

if expand,
for ii=1:nargin,
if rows(ii) == 1,
varargin{ii} = repmat(varargin{ii}, maxrows, 1);
end
end
end

%------------------------------------------------------------------------------
% extract inputs from varargin
%------------------------------------------------------------------------------
lat1 = varargin{1};
lon1 = varargin{2};
faz = varargin{3};
s = varargin{4};

deg_in = zeros(maxrows, 1);
deg_out = zeros(maxrows, 1);

if nargin >= 5,
deg_in = varargin{5};
if nargin == 6,
deg_out = varargin{6};
end
end

%------------------------------------------------------------------------------
% WGS-84 defining parameters.
%------------------------------------------------------------------------------
a = 6378137.0;
f = 1.0 / 298.257223563;

%------------------------------------------------------------------------------
% Miscellaneous parameters.
%------------------------------------------------------------------------------
rad2deg = 180 / pi;
deg2rad = pi / 180;

eps = 0.5e-13;

zero = 0.0; one = 1.0; two = 2.0;three = 3.0; four = 4.0; six = 6.0;
three_eighths = 3.0 / 8.0;sixteen = 16.0;twopi = 2.0 * pi;

%------------------------------------------------------------------------------
% Input conversions.
%------------------------------------------------------------------------------
lat1(deg_in == 1) = lat1(deg_in == 1) * deg2rad;
lon1(deg_in == 1) = lon1(deg_in == 1) * deg2rad;
faz(deg_in == 1) = faz(deg_in == 1) * deg2rad;

%------------------------------------------------------------------------------
% find cases where s = 0 and remove them from computations
%------------------------------------------------------------------------------
szero = s == 0;

lat2_out = zeros(size(lat1));
lon2_out = zeros(size(lat1));
baz_out = zeros(size(lat1));

lat2_out(szero) = lat1(szero);
lon2_out(szero) = lon1(szero);

lat1 = lat1(~szero);
lon1 = lon1(~szero);
faz = faz(~szero);

%------------------------------------------------------------------------------
% Main routine.
%------------------------------------------------------------------------------
r = one - f;
tu = r * sin(lat1) ./ cos(lat1);
sf = sin(faz);
cf = cos(faz);

baz = zeros(size(faz));

if (cf ~= zero),
baz = atan2(tu, cf) * two;
end

cu = one ./ sqrt(tu .* tu + one);
su = tu .* cu;
sa = cu .* sf;
c2a = -sa .* sa + one;
x = sqrt((one / r / r - one) * c2a + one) + one;
x = (x - two) ./ x;
c = one - x;
c = (x .* x / four + one) ./ c;
d = (three_eighths * x .* x - one) .* x;
tu = s ./ a ./ c / r;
y = tu;

repeat = 1;

while repeat == 1,

sy = sin(y);
cy = cos(y);
cz = cos(baz + y);
e = cz .* cz * two - one;
c = y;
x = e .* cy;
y = e + e - one;
y = (((sy .* sy * four - three) .* y .* cz .* d / six + x) .* d / four - cz) .* sy .* d + tu;

if all(abs(y - c) <= eps),
break
end

end

baz = cu .* cy .* cf - su .* sy;
c = r * sqrt(sa .* sa + baz .* baz);
d = su .* cy + cu .* sy .* cf;
lat2 = atan2(d, c);
c = cu .* cy - su .* sy .* cf;
x = atan2(sy .* sf, c);
c = ((-three * c2a + four) .* f + four) .* c2a .* f / sixteen;
d = ((e .* cy .* c + cz) .* sy .* c + y) .* sa;
lon2 = lon1 + x - (one - c) .* d .* f;
baz = atan2(sa, baz) + pi;

%------------------------------------------------------------------------------
% Map to outputs.
%------------------------------------------------------------------------------
lat2_out(~szero) = lat2;
lon2_out(~szero) = lon2;
baz_out(~szero) = baz;

ii = lon2_out < -pi;
lon2_out(ii) = lon2_out(ii) + twopi;

ii = lon2_out > pi;
lon2_out(ii) = lon2_out(ii) - twopi;

%------------------------------------------------------------------------------
% Output conversions.
%------------------------------------------------------------------------------
lat2_out(deg_out == 1) = lat2_out(deg_out == 1) * rad2deg;
lon2_out(deg_out == 1) = lon2_out(deg_out == 1) * rad2deg;
baz_out(deg_out == 1) = baz_out(deg_out == 1) * rad2deg;

if nargout == 1,
lat2_out = [lat2_out lon2_out baz_out];
end