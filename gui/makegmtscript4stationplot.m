function [pscoast] = makegmtscript4stationplot(plotornot) 
 

disp('This is makegmtscript4stationplot 02/10/2011')


%% read defaults
[gmt_ver,psview,npts] = readisolacfg;
%%

%find event ID
h=dir('event.isl');

if isempty(h); 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    eventagency=fscanf(fid,'%s',1);
    fclose(fid);
end
%%%%%%%%%
eventidnew=[eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec];

% check if we have one line solution
try
    cd gmtfiles
      h=dir(eventidnew);
   if isempty(h); 
      errordlg([ eventidnew '  file doesn''t exist in gmtfiles folder. Run Plot moment tensor in plot results. ' ],'File Error');
    cd ..
   return    
   else
    disp([ 'Found ' eventidnew])
    cd ..
   end
catch
    cd ..
end


% read station data
try
    cd gmtfiles
    h=dir('selstat.gmt');
%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
 if isempty(h); 
    errordlg('Selstat.gmt file doesn''t exist. Run Station Selection. ','File Error');
    cd ..
   return    
 else
    fid = fopen('selstat.gmt','r');
      C= textscan(fid,'%s %f %f',-1);
    fclose(fid);
 end      
    cd ..
catch
    cd ..
end

% Add event info
evestalat=[C{2}; eventcor(2)];
evestalon=[C{3}; eventcor(1)];

%%

latspan=max(evestalat)-min(evestalat);
lonspan=max(evestalon)-min(evestalon);

% use percent..!!
minlat=min(evestalat)-0.2*latspan;
maxlat=max(evestalat)+0.2*latspan;
minlon=min(evestalon)-0.2*lonspan;
maxlon=max(evestalon)+0.2*lonspan;

%[distance,a12,a21] = m_idist(lon1,lat1,lon2,lat2,spheroid)

[dist,azim,a21] = m_idist(minlon,minlat,maxlon,maxlat)

%%%%%%%%%%%%  USE GRS80 ELLIPSOID
%grs80.geoid = almanac('earth','geoid','km','grs80');
%%%%%%%%%%%%%%%%CALCULATE AZIMUTH AND EPICENTRAL DISTANCE FOR EVERY STATION
%[dist,azim]=distance(minlat,minlon,minlat,maxlon,grs80.geoid)  

%     staazim(i)=azimuth(eventcor(2),eventcor(1),selectedstalat(i),selectedstalon(i),grs80.geoid);
%     epidist(i)=distdim(distance(eventcor(2),eventcor(1),selectedstalat(i),selectedstalon(i),grs80.geoid),'km','km');

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
%mapticsla=latspan/4; 


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
r=['-R' num2str(minlon,'%7.5f') '/' num2str(maxlon,'%7.5f') '/' num2str(minlat,'%7.5f') '/' num2str(maxlat,'%7.5f') ' '];

% make -J
j=' -JM16c+';

% % %%
% if latspan < 1
%     %sckm=10;
%     sckm=(round(dist/2))
% elseif latspan > 1 && latspan < 5
%     %sckm=50;
%     sckm=(round(dist*2))/4;
% elseif latspan > 5 && latspan < 10
%     %sckm=100;
%     sckm=(round(dist*2))/5;
% else
%     %sckm=200;
%     sckm=(round(dist*2))/8;
% end
% % if dist <=50
% %     sckm=20;
% % elseif dist > 50 && sckm <=100
% %     sckm=50;
% % elseif dist > 100 && dist <= 200
% %     sckm=150;
% % else
% %     
% % end
dist=dist/1000;
sckm=trtooten(dist/3);

L=[' -Lf' num2str((lonspan/2)+minlon) '/' num2str(minlat+(0.07*latspan)) '/'  num2str((latspan/2)+minlat) '/' num2str(sckm) '+l']; 

%%  based on plotornot decide

if plotornot==1
      
  try
    cd gmtfiles
   
   if ispc
       
    fid = fopen('plotselsta_evnt.bat','w');
         if gmt_ver==4     
              fprintf(fid,'%s\r\n','gmtset PLOT_DEGREE_FORMAT D  ANNOT_FONT_SIZE_PRIMARY 12 ANNOT_FONT_SIZE_SECONDARY 12 HEADER_FONT_SIZE 14 LABEL_FONT_SIZE 14');
         else
              fprintf(fid,'%s\r\n','gmtset FORMAT_GEO_MAP D  FONT_ANNOT_PRIMARY 12 FONT_ANNOT_SECONDARY 12 FONT_TITLE 14 FONT_LABEL 14');
         end
    fprintf(fid,'%s\r\n','  ');
    fprintf(fid,'%s\r\n',['gawk "{print $3,$2,1}" selstat.gmt > sta.gmt']);
    fprintf(fid,'%s\r\n',['gawk "{print $3,$2,11,0,1,\"CB\",$1}" selstat.gmt > tsta.gmt']);
    fprintf(fid,'%s\r\n','           ');
      pscoastr=['pscoast ' r   j ' -G255/255/204 -Df -W0.7p ' L  ' -B' num2str(mapticslo) '/' num2str(mapticsla) ':."Event ID\072' eventidnew '": '  ' -Na/0.8p,red,-.- -K -S104/204/255  > ' eventidnew '_stasol.ps' ];
      pscoast='ploting';
    fprintf(fid,'%s\r\n', pscoastr);
    fprintf(fid,'%s\r\n','           ');
          if gmt_ver==4   
                sstring=['psxy -R -J  sta.gmt -St.4c -M  -W1p/0 -K -O -G255/0/0 >>  ' eventidnew '_stasol.ps' ];
          else
                sstring=['psxy -R -J  sta.gmt -St.4c     -W1p   -K -O -G255/0/0 >>  ' eventidnew '_stasol.ps' ];
          end
          
          fprintf(fid,'%s\r\n',sstring);
    
          if gmt_ver==4   
                sstring=['pstext -R -J  tsta.gmt  -D0/0.45c  -W255/255/255,o  -K -O  -G0/0/255 >> ' eventidnew '_stasol.ps' ];
          else
                sstring=['pstext -R -J  tsta.gmt  -D0/0.45c  -Wblack -To  -K -O -F+f10,Helvetica,blue -Gwhite >> ' eventidnew '_stasol.ps' ];
          end
          fprintf(fid,'%s\r\n',sstring);
          
    fprintf(fid,'%s\r\n','           ');
% add not used stations in gray
          if gmt_ver==4   
               sstring=['psxy -R -J ..\gmtfiles\notusedstat.gmt -St.4c  -W1p/0 -K  -O -G138/138/138 >> ' eventidnew '_stasol.ps'];
          else
               sstring=['psxy -R -J ..\gmtfiles\notusedstat.gmt -St.4c  -W1p -K  -O -G138/138/138 >> ' eventidnew '_stasol.ps'];
          end
          fprintf(fid,'%s\r\n',sstring);
          fprintf(fid,'%s\r\n','           ');

          if gmt_ver==4   
             sstring=['psxy -R -J event.gmt -Sa.6c -M  -W1p/0 -K -O -G255/0/0 >> ' eventidnew '_stasol.ps' ];
          else
             sstring=['psxy -R -J event.gmt -Sa.6c   -W1p   -K -O -G255/0/0 >> ' eventidnew '_stasol.ps' ];
          end
          
          fprintf(fid,'%s\r\n',sstring);
          fprintf(fid,'%s\r\n','           ');
          
          sstring=['psmeca -R -J ' eventidnew  ' -Sa1.5c  -O  >> ' eventidnew '_stasol.ps' ];
          
          fprintf(fid,'%s\r\n',sstring);
          fprintf(fid,'%s\r\n','           ');
          
          if gmt_ver==4
          fprintf(fid,'%s\r\n',['ps2raster ' eventidnew '_stasol.ps -A -P -Tg ']);
          else
          fprintf(fid,'%s\r\n',['psconvert ' eventidnew '_stasol.ps -A -P -Tg ']);
          end
          
    fprintf(fid,'%s\r\n','           ');
    fprintf(fid,'%s\r\n','del tsta.gmt sta.gmt ');
    fprintf(fid,'%s\r\n','  ');
    fprintf(fid,'%s\r\n',['copy ' eventidnew '_stasol.ps   ..\output\']);
    fprintf(fid,'%s\r\n',['copy ' eventidnew '_stasol.png  ..\output\']);
    fprintf(fid,'%s\r\n','  ');
%     fprintf(fid,'%s\r\n',['del ' eventidnew '_stasol.ps'] );
%     fprintf(fid,'%s\r\n',['del ' eventidnew '_stasol.png'] );
       
    fclose(fid);
    
              [status, result1] =system('plotselsta_evnt.bat');
               disp('Check the GMTFILES folder for plotselsta_evnt.bat file and output folder for postscript file.');
                   try 
                      system([psview ' ..\output\' eventidnew  '_stasol.ps' ]);
                   catch exception 
                      disp(exception.message)
                   end
              %   system(['gsview32  ..\output\' eventidnew '_stasol.ps' ]);
               
               
               result=0;
    
   else % linux 
       
    fid = fopen('plotselsta_evnt.bat','w');

         if gmt_ver==4     
              fprintf(fid,'%s\n','gmtset PLOT_DEGREE_FORMAT D  ANNOT_FONT_SIZE_PRIMARY 12 ANNOT_FONT_SIZE_SECONDARY 12 HEADER_FONT_SIZE 14 LABEL_FONT_SIZE 14');
         else
              fprintf(fid,'%s\n','gmtset FORMAT_GEO_MAP D  FONT_ANNOT_PRIMARY 12 FONT_ANNOT_SECONDARY 12 FONT_TITLE 14 FONT_LABEL 14');
         end
    fprintf(fid,'%s\n','  ');
    fprintf(fid,'%s\n',['awk "{print $3,$2,1}" selstat.gmt > sta.gmt']);
    fprintf(fid,'%s\n',['awk "{print $3,$2,11,0,1,\"CB\",$1}" selstat.gmt > tsta.gmt']);
    fprintf(fid,'%s\n','           ');
      pscoastr=['pscoast ' r   j ' -G255/255/204 -Df -W0.7p ' L  ' -B' num2str(mapticslo) '/' num2str(mapticsla) ':."Event ID\072' eventidnew '": '  ' -Na/0.8p,red,-.- -K -S104/204/255  > ' eventidnew '_stasol.ps' ];
      pscoast='ploting';
    fprintf(fid,'%s\n', pscoastr);
    fprintf(fid,'%s\n','           ');
          if gmt_ver==4   
                sstring=['psxy -R -J  sta.gmt -St.4c -M  -W1p/0 -K -O -G255/0/0 >>  ' eventidnew '_stasol.ps' ];
          else
                sstring=['psxy -R -J  sta.gmt -St.4c     -W1p   -K -O -G255/0/0 >>  ' eventidnew '_stasol.ps' ];
          end
          
          fprintf(fid,'%s\n',sstring);
    
          if gmt_ver==4   
                sstring=['pstext -R -J  tsta.gmt  -D0/0.45c  -W255/255/255,o  -K -O  -G0/0/255 >> ' eventidnew '_stasol.ps' ];
          else
                sstring=['pstext -R -J  tsta.gmt  -D0/0.45c  -Wblack -To  -K -O -F+f10,Helvetica,blue -Gwhite >> ' eventidnew '_stasol.ps' ];
          end
          fprintf(fid,'%s\n',sstring);
          
    fprintf(fid,'%s\n','           ');
% add not used stations in gray
          if gmt_ver==4   
               sstring=['psxy -R -J ..\gmtfiles\notusedstat.gmt -St.4c  -W1p/0 -K  -O -G138/138/138 >> ' eventidnew '_stasol.ps'];
          else
               sstring=['psxy -R -J ..\gmtfiles\notusedstat.gmt -St.4c  -W1p -K  -O -G138/138/138 >> ' eventidnew '_stasol.ps'];
          end
          fprintf(fid,'%s\n',sstring);
          fprintf(fid,'%s\n','           ');

          if gmt_ver==4   
             sstring=['psxy -R -J event.gmt -Sa.6c -M  -W1p/0 -K -O -G255/0/0 >> ' eventidnew '_stasol.ps' ];
          else
             sstring=['psxy -R -J event.gmt -Sa.6c   -W1p   -K -O -G255/0/0 >> ' eventidnew '_stasol.ps' ];
          end
          
          fprintf(fid,'%s\n',sstring);
          fprintf(fid,'%s\n','           ');
          
          sstring=['psmeca -R -J ' eventidnew  ' -Sa1.5c  -O  >> ' eventidnew '_stasol.ps' ];
          
          fprintf(fid,'%s\n',sstring);
          fprintf(fid,'%s\n','           ');
          
          if gmt_ver==4
          fprintf(fid,'%s\n',['ps2raster ' eventidnew '_stasol.ps -A -P -Tg ']);
          else
          fprintf(fid,'%s\n',['psconvert ' eventidnew '_stasol.ps -A -P -Tg ']);
          end
          
    fprintf(fid,'%s\n','           ');
    fprintf(fid,'%s\n','rm tsta.gmt sta.gmt ');
    fprintf(fid,'%s\n','  ');
    fprintf(fid,'%s\n',['cp ' eventidnew '_stasol.ps   ..\output\']);
    fprintf(fid,'%s\n',['cp ' eventidnew '_stasol.png  ..\output\']);
    fprintf(fid,'%s\n','  ');
    fclose(fid);

                  [status, result1] =system('plotselsta_evnt.bat');
               disp('Check the GMTFILES folder for plotselsta_evnt.bat file and output folder for postscript file.');
                   try 
                      system([psview ' ..\output\' eventidnew  '_stasol.ps' ]);
                   catch exception 
                      disp(exception.message)
                   end
              %   system(['gsview32  ..\output\' eventidnew '_stasol.ps' ]);
    
    
    
               !chmod +x plotselsta_evnt.bat
               [status, result1] =system('./plotselsta_evnt.bat');
               pwd
               disp('Check the GMTFILES folder for plotselsta_evnt.bat file and output folder for postscript file.');
               pwd
               try 
                   system([psview ' ../output/' eventidnew  '_stasol.ps' ]);
                   catch exception 
                      disp(exception.message)
                   end
%                
%                system(['gv  ../output/' eventidnew '_stasol.ps' ]);
%                result=0;
    
   end




    cd ..


    
  catch
    cd ..
  end



else  % don't plot
j2=' -JM9.8c+';

    pscoast=['pscoast ' r   j2 ' -G255/255/204 -Df -W0.7p -O '  ' -B' num2str(mapticslo) '/' num2str(mapticsla) ':." ":WeSn '  ' -Na/0.8p,red,-.- -K -S104/204/255 ' ];
    
end
%%
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
