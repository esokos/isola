function [wlimit,elimit,slimit,nlimit,scale,mapticsla,]=findlimits(evestalat,evestalon)
% this function will try to calculate limit,scale and tick spacing for a
% GMT map based on extend of area to be plotted.
% 16/09/2011

% find min max
minlat=min(evestalat);
maxlat=max(evestalat);
minlon=min(evestalon);
maxlon=max(evestalon);

% find lat lon span 
latspan=maxlat-minlat;  
lonspan=maxlon-minlon;  

llratio=latspan/lonspan; 

%keep 15 cm as map length
if llratio  >= 3
    orient= ' -P ';
   scale=15/latspan;
elseif llratio  < 3
     orient= '  ';
     scale=15/lonspan;
    %find LAT length
    latlen=scale*latspan;
     if latlen > 8
         orient= ' -P ';
         scale=15/latspan;
     else
     end

    lonlen=scale*lonspan;
     if lonlen > 8
        orient= ' -P ';
        scale=10/latspan;
     else
     end
else
    orient= '  ';
    scale=15/lonspan;
end

if latspan < 1
    mapticsla=0.1;
elseif latspan < 10
    mapticsla=1;
else
    mapticsla=2;
end

if lonspan < 1
    mapticslo=0.1;
elseif lonspan < 10
    mapticslo=1;
else
    mapticslo=2;
end
