function saveandexit

handles1 = guidata(gcbo); 
staname=handles1.staname;

stalat=handles1.stalat;
stalon=handles1.stalon;

% depth=handles1.depth;
% read origin

depth=str2num(get(handles1.depth,'String'));


%%

cd unc_maps


%% create allstat.dat
dummy=1;

       fid = fopen('allstat.dat','w');
           if ispc
               for i=1:length(staname)
%                 fprintf(fid,'%s  %i %i %i %i %s\r\n',num2str(i,'%03u'),dummy,dummy,dummy,dummy,stationsorted(i).name); 
                 fprintf(fid,'%s  %i %i %i %i %s %s %s %s\r\n',char(staname(i)),dummy,dummy,dummy,dummy,'0.05','0.06','0.08','0.09'); 
               end
           else
               for i=1:length(staname)
%                 fprintf(fid,'%s  %i %i %i %i %s\r\n',num2str(i,'%03u'),dummy,dummy,dummy,dummy,stationsorted(i).name); 
                 fprintf(fid,'%s  %i %i %i %i %s %s %s %s\n',staname,dummy,dummy,dummy,dummy,'0.05','0.06','0.08','0.09'); 
               end
           end
       fclose(fid);

%% create allsrcdeg.dat
% deg_grid(or_lat,lat_step,nlat,or_lon,lon_step,nlon,depth)

gridspc=str2double(get(handles1.gspc,'String'));

%retrieve from figure 
or_lon=handles1.originlon;
or_lat=handles1.originlat;

deg_grid(or_lat,gridspc,9,or_lon,gridspc,9,depth);  % fix 9x9 sources

%% create station.dat
%fix origin on the epicenter
orlat=or_lat;
orlon=or_lon;

%%%%%%%%%%%%  USE GRS80 ELLIPSOID
grs80.geoid = almanac('earth','geoid','km','grs80');
%%%%%%%%%%%%%%%%CALCULATE AZIMUTH AND EPICENTRAL DISTANCE FOR EVERY STATION
for i=1:length(staname)
    staazim(i)=azimuth(orlat,orlon,stalat(i),stalon(i),grs80.geoid);
    epidist(i)=distdim(distance(orlat,orlon,stalat(i),stalon(i),grs80.geoid),'km','km');
end


%%%% FIX SOURCE AT ORIGIN  20/09/03
sourceXdist=0;
sourceYdist=0;


 for i=1:length(staname)
     [stationXdist(i),stationYdist(i)] = pol2cart(deg2rad(staazim(i)),epidist(i));
 end
% 
%%%%%%%%OUTPUT%%%%%%%%%%%%%%%%%%%%
for i=1:length(staname)
%    out(i,1)=stationXdist(i);     %%%%%% 
    station(i).X=stationXdist(i);  
%    out(i,2)=stationYdist(i);
    station(i).Y=stationYdist(i);  
%    out(i,3)=0;
    station(i).A=0;  
%    out(i,4)=staazim(i);
    station(i).azm=staazim(i);
%    out(i,5)=epidist(i);
    station(i).epidist=epidist(i);
    station(i).name=staname{i};
    station(i).pol='U';

end    

%%%%% Sort selected stations by distance

[dummy order]=sort([station(:).epidist]);
stationsorted=station(order);


disp(['You have selected ', num2str(length(staname)), ' stations for inversion'])

disp(' No   Station   Azimuth (Deg)    Distance (km) ')

for i=1:length(staname)
    disp([ num2str(i,'%03u') '     '  stationsorted(i).name '       '    num2str(stationsorted(i).azm,'%4.1f') '            '  num2str(stationsorted(i).epidist,'%6.2f')])
end

    helpdlg(['You have selected ', num2str(length(staname)), ' stations for inversion']);


%    
         if ispc  
          fid = fopen('station.dat','w');
           fprintf(fid,'%s\r\n',' Station co-ordinates');
           fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),azim.,dist.,stat.');
            for i=1:length(staname)
              fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,stationsorted(i).name,stationsorted(i).pol);
            end
          fclose(fid);
        else
          fid = fopen('station.dat','w');
           fprintf(fid,'%s\n',' Station co-ordinates');
           fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),azim.,dist.,stat.');
            for i=1:length(staname)
              fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,stationsorted(i).name,stationsorted(i).pol);
            end
          fclose(fid);
         end

           dummy=1;
           fid = fopen('allstat.dat','w');
           if ispc
               for i=1:length(staname)
                 fprintf(fid,'%s  %i %i %i %i %s %s %s %s\r\n',stationsorted(i).name,dummy,dummy,dummy,dummy,'0.05','0.06','0.08','0.09'); 
               end
           else
               for i=1:length(staname)
                 fprintf(fid,'%s  %i %i %i %i %s %s %s %s\n',stationsorted(i).name,dummy,dummy,dummy,dummy,'0.05','0.06','0.08','0.09'); 
               end
           end
           fclose(fid);
        
    

       
%% exit       
% save no of stations 
           fid = fopen('nstations.isl','w');

                  fprintf(fid,'%u',length(staname));
                 
           fclose(fid);
           
           
%%

cd ..
 
%%
%setappdata(uncmaps,'seldepth',depth);
setappdata(uncmaps,'sellon',orlon);
setappdata(uncmaps,'sellat',orlat);

close map
       
