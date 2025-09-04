function ok = kml2isolasource(filename,epilat,epilon,depth,magn,eventdate)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

S = kmz2struct(filename);

src_lon=S.Lon;
src_lat=S.Lat;

disp(['Found ' num2str(length(src_lon)) ' sources']);

%%
%PLOT USING M_MAP
  figure(1)
  m_proj('Mercator','long',[min(src_lon)-0.1 max(src_lon)+0.1],'lat',[min(src_lat)-0.1 max(src_lat)+0.1]);
  m_gshhs_h('color','k');
  %m_gshhs_h('patch',[.7 .7 .7],'edgecolor','g');%'color','k');
  m_grid('box','fancy','tickdir','out');

  for i=1:length(src_lon)
    m_line(src_lon(i),src_lat(i),'marker','square','markersize',5,'color','r');
    m_text(src_lon(i),src_lat(i),num2str(i),'vertical','top');
  end
  
  %%%plot epicenter
  m_line(epilon,epilat,'marker','p','markersize',17,'color','b','MarkerFaceColor','b');

%% we have lat lon for sources
% FIND CARTESIAN COORDINATES of sources 
% loop through sources
% fix origin at epilat epilon (epicenter coordinates)
% for ii=1:length(src_lon)
%     [s(ii),az1(ii),az2(ii)] = vdist(epilat,epilon,src_lat(ii),src_lon(ii));
% end

%%%%%%%%%%%%  USE GRS80 ELLIPSOID
grs80.geoid = almanac('earth','geoid','km','grs80');
%%%%%%%%%%%%%%%%CALCULATE AZIMUTH AND EPICENTRAL DISTANCE FOR EVERY STATION
for ii=1:length(src_lon)
    srcazim(ii)=azimuth(epilat,epilon,src_lat(ii),src_lon(ii),grs80.geoid);
    srcdist(ii)=distdim(distance(epilat,epilon,src_lat(ii),src_lon(ii),grs80.geoid),'km','km');
end


%% convert from polar to cartesian 
% be careful s is in meters
for ii=1:length(src_lon)
     [srcXdist(ii),srcYdist(ii)] = pol2cart(deg2rad(srcazim(ii)),srcdist(ii)); 
end

figure
plot(srcYdist,srcXdist,'o')
grid on

%% OUTPUT TO SRC FILES
% and source.isl !!!!!!!!!
  fid2 = fopen('tsources.isl','w');
    fprintf(fid2,'%s\r\n','line');
    fprintf(fid2,'%i\r\n',length(src_lon));
    fprintf(fid2,'%f\r\n',1);  %fix
    fprintf(fid2,'%f\r\n',1);  %fix
    fprintf(fid2,'%s\r\n','Custom trial source line');
  fclose(fid2);

%%
% go in GREEN
cd green
% DELETE src files
  system('del src*.dat');
% go back
cd ..
  
 %% go in GREEN
    cd green
             
      for i=1:length(src_lon)
        % find filename
          filename=['src' num2str(i,'%02d') '.dat'];
        % open file
          fid = fopen(filename,'w');
             fprintf(fid,'%s\r\n',' Source parameters');
             fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
             fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\r\n',srcXdist(i),srcYdist(i), depth,magn, '''', eventdate, '''');
          fclose(fid);
      end

   cd .. 

%%
% go in gmtfile
 cd gmtfiles
            fid = fopen('sources.gmt','w');
            
              for i=1:length(src_lon)
                fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f %3i %s\r\n',src_lon(i),src_lat(i),'0.2',depth,i,'d');
              end
                fprintf(fid,'  %5.10f   %5.10f   %s %5.10f  %s %s\r\n',epilon,epilat,'0.4',depth,'Ref','a');
            fclose(fid);   
            
%% sour.dat
             fid = fopen('sour.dat','w');   % XY file ...
             
                 for i=1:length(src_lon)
                   fprintf(fid,'%10.4f   %10.4f  %10.4f  %s\r\n',srcXdist(i),srcYdist(i), depth, num2str(i));
                 end
             fclose(fid);
             
%% make plot batch file
             %%%find map limits...
              border=0.1;
                  wend=min(src_lon);
                  eend=max(src_lon);
                  send=min(src_lat);
                  nend=max(src_lat);
                    w=(wend-border);
                    e=(eend+border);
                    s=(send-border);
                    n=(nend+border);
               r=['-R' num2str(w,'%7.5f') '/' num2str(e,'%7.5f') '/' num2str(s,'%7.5f') '/' num2str(n,'%7.5f') ' '];
               j=' -JM14c';
           
             fid = fopen('psources.bat','w');
                   fprintf(fid,'%s\r\n','gmtset PAPER_MEDIA A4');
                   fprintf(fid,'%s\r\n','gmtset PLOT_DEGREE_FORMAT D');
                   fprintf(fid,'%s\r\n',['pscoast ' r   j ' -G255/255/204 -Df -W0.7p  -B0.1 -K -S104/204/255   > sources.ps' ]);
                   fprintf(fid,'%s\r\n','psxy -R -J -O  -K      sources.gmt   -S  -G255/0/0    -W1.p -V >> sources.ps ');
                   fprintf(fid,'%s\r\n','gawk "{print $1,$2,"14","1","1","1",$5}" sources.gmt > textsou.txt');
                   fprintf(fid,'%s\r\n','pstext -R -J -O   textsou.txt  -V >> sources.ps ');
                       
             fclose(fid);   
             
             
cd ..

%%
ok = 1;
end

