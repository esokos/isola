function [mapticsla,mapticslo,L,scaleloc]=guessgmtvalues(minlon,maxlon,minlat,maxlat)

latspan=maxlat-minlat;
lonspan=maxlon-minlon;

%%
if latspan < 1
    mapticsla=0.2;
elseif latspan > 1 &&  latspan < 5
    mapticsla=0.5;
elseif latspan > 5 && latspan < 10
    mapticsla=1;
else
    mapticsla=2;
end

%%
if lonspan < 1
    mapticslo=0.2;
elseif lonspan > 1 && lonspan < 5
    mapticslo=0.5;
elseif lonspan > 5 && lonspan < 10
    mapticslo=1;
else
    mapticslo=2;
end
%%

%%%%%%%%%%%%  USE GRS80 ELLIPSOID
grs80.geoid = almanac('earth','geoid','km','grs80');
%%%%%%%%%%%%%%%%CALCULATE AZIMUTH AND EPICENTRAL DISTANCE FOR EVERY STATION
[dist,azim]=distance(minlat,minlon,minlat,maxlon,grs80.geoid) ;
[distlat,azim]=distance(minlat,minlon,maxlat,minlon,grs80.geoid) ;

sckm=trtooten(dist/3);

L=[' -Lf' num2str((lonspan/2)+minlon) '/' num2str(minlat+(0.07*latspan)) '/'  num2str((latspan/2)+minlat) '/' num2str(sckm) '+l'];


%% guess psscale position
if lonspan > latspan
    
    scaleloc=17;
    
else

  scaleloc=(dist/distlat)*16.5;
    
end

function a = trtooten(b)

if  b < 10
        a=2;
elseif b > 10 && b < 100
        a=fix(b/10)*10;
elseif b > 100  && b < 1000
         a=fix(b/100)*100;
elseif b > 1000
        a=fix(b/1000)*1000;
end



