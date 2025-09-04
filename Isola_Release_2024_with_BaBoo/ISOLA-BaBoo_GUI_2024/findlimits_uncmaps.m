function [left,right,down,up]=findlimits_uncmaps(lon,lat, deg)

% lon
    left=min(lon);
    right=max(lon);

% lat
   down=min(lat);
   up=max(lat);

   
% find range
  
   left=left-deg;
   right=right+deg;
   
up=up+deg;
down=down-deg;