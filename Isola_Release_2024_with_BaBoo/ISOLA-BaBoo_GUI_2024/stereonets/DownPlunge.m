function dpbedseg = DownPlunge(bedseg,trd,plg)
%DownPlunge constructs the down plunge projection of a bed
%
%   dpbedseg = DownPlunge(bedseg,trd,plg) constructs the down plunge
%   projection of a bed from the X1 (East), X2 (North), 
%   and X3 (Up) coordinates of points on the bed (bedseg) and the 
%   trend (trd) and plunge (plg) of the fold axis
%
%   The array bedseg is a two-dimensional array of size npoints x 3 
%   which holds npoints on the digitized bed, each point defined by
%   3 coordinates: X1 = East, X2 = North, X3 = Up
%
%   NOTE: Trend and plunge of fold axis should be entered in radians
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Number of points in bed
nvtex = size(bedseg,1);

%Allocate some arrays
a=zeros(3,3);
dpbedseg = zeros(size(bedseg));

%Calculate the transformation matrix a(i,j). The convention is that
%the first index refers to the new axis and the second to the old axis.
%The new coordinate system is with X3' parallel to the fold axis, X1'
%perpendicular to the fold axis and in the same vertical plane, and 
%X2' perpendicular to the fold axis and parallel to the horizontal. See
%equation 3.10
a(1,1) = sin(trd)*sin(plg);
a(1,2) = cos(trd)*sin(plg);
a(1,3) = cos(plg);
a(2,1) = cos(trd);
a(2,2) = -sin(trd);
a(2,3) = 0.0;
a(3,1) = sin(trd)*cos(plg);
a(3,2) = cos(trd)*cos(plg);
a(3,3) = -sin(plg);

%The East, North, Up coordinates of each point to be rotated already define
%the coordinates of vectors. Thus we don't need to convert them to
%direction cosines (and don't want either because they are not unit vectors)
%The following nested do-loops perform the coordinate transformation on the
%bed. The details of this algorithm are described in Chapter 4
for nv = 1:nvtex
    for i = 1:3
        dpbedseg(nv,i) = 0.0;
        for j = 1:3
            dpbedseg(nv,i) = a(i,j)*bedseg(nv,j) + dpbedseg(nv,i);
        end
    end
end

end