function [srclon1,srclat1,depth1,srclon2,srclat2,depth2]=get_geo_coor(source1sel,source2sel)
%%%%%%%%%find distance step
%%%%%%%%%%%%%%%%%%%%%%%%%%%
h=dir('tsources.isl');
source_gmtfile=0;

if isempty(h); 
    errordlg('tsources.isl file doesn''t exist. Run Source create. ','File Error');
  return    
else
    fid = fopen('tsources.isl','r');
    tsource=fscanf(fid,'%s',1);
     if strcmp(tsource,'line')
       disp('Inversion was done for a line of sources.')
       nsources=fscanf(fid,'%i',1);
       distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
       source_gmtfile=1;
     elseif strcmp(tsource,'depth')
      disp('Inversion was done for a line of sources under epicenter.')
      nsources=fscanf(fid,'%i',1);
      distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
      source_gmtfile=0;
     elseif strcmp(tsource,'plane')
      disp('Inversion was done for a plane of sources.')
      nsources=fscanf(fid,'%i',1);
%       distep=fscanf(fid,'%f',1);
                noSourcesstrike=fscanf(fid,'%i',1);
                strikestep=fscanf(fid,'%i',1);
                noSourcesdip=fscanf(fid,'%i',1);
                dipstep=fscanf(fid,'%i',1);
                source_gmtfile=1;
                nsources=noSourcesstrike*noSourcesdip
           invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
     elseif strcmp(tsource,'point')
      disp('Inversion was done for one source.')
      nsources=fscanf(fid,'%i',1);
      distep=fscanf(fid,'%f',1);
      sdepth=fscanf(fid,'%f',1);
      invtype=fscanf(fid,'%c');
     end
          fclose(fid);
end

%%
% check the sources.gmt in gmtfiles
if ispc
    h=dir('.\gmtfiles\sources.gmt');
else
    h=dir('./gmtfiles/sources.gmt');
end

if isempty(h); 
  errordlg('Sources.gmt file doesn''t exist. Run Source definition. ','File Error');
  return
else
% read coordinates.....
 if source_gmtfile==0
   if ispc
      [lon,lat,depth,sourceno] = textread('.\gmtfiles\sources.gmt','%f %f %f %f',nsources,'headerlines',1);
   else
      [lon,lat,depth,sourceno] = textread('./gmtfiles/sources.gmt','%f %f %f %f',nsources,'headerlines',1);
   end
 elseif source_gmtfile==1
   if ispc  
      [lon,lat,~,depth,sourceno,~] = textread('.\gmtfiles\sources.gmt','%f %f %f %f %f %s',nsources);
   else
      [lon,lat,~,depth,sourceno,~] = textread('./gmtfiles/sources.gmt','%f %f %f %f %f %s',nsources);
   end
 end
end

%% USE SOURCE COORDINATES AND SOURCE NUMBER TO FIND SUB  SOURCE COORDINATES

for i=1:length(source1sel);
     for j=1:length(sourceno);
         if  source1sel(i) == sourceno(j,1)
             srclon1(i,1) = lon(j,1);   %%%%Longitude 
             srclat1(i,1) = lat(j,1);   %%%%Longitude
             depth1(i,1)  = depth(j,1);    %%%%Depth
         end    
     end
 end

for i=1:length(source2sel);
     for j=1:length(sourceno);
         if  source2sel(i) == sourceno(j,1)
             srclon2(i,1) = lon(j,1);   %%%%Longitude 
             srclat2(i,1) = lat(j,1);   %%%%Longitude
             depth2(i,1)  = depth(j,1);    %%%%Depth
         end    
     end
 end



