function plstat

disp('This is plstat.m  10/06/11')
disp('This version allows large station names..')

%%
handles1=guidata(gcbo);
staname=handles1.staname;
stalat=handles1.stalat;
stalon=handles1.stalon;
eventcor=handles1.eventcor;
epidepth=handles1.epidepth;
magn=handles1.magn;
eventdate=handles1.eventdate;
selarea=handles1.selarea;
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
%%
xy = [];
xylon = [];
xylat = [];
n = 0;

% Loop, picking up the points.
disp('Left mouse button picks points.')
disp('Right mouse button picks last point.')
disp('  ')
disp('  ')
disp('  ')

h=helpdlg('Left mouse button selects station. Right mouse button selects last station.','Station Selection');
uiwait(h)

but = 1;
while but == 1
    [xi,yi,but] = ginput(1);
    n = n+1;
    xy(:,n) = [xi;yi];
    [xylon(n),xylat(n)] =m_xy2ll(xy(1,n),xy(2,n));
    
      for i=1:length(stalat)
          if xylon(n) <= stalon(i)+selarea &&  xylon(n) >= stalon(i)-selarea && xylat(n) >= stalat(i)-selarea &&  xylat(n) <= stalat(i)+selarea
              tmpxylon(n)=stalon(i);
              tmpxylat(n)=stalat(i);
              tmpxyname(n)=staname(i);
               m_line(tmpxylon(n),tmpxylat(n),'marker','square','markersize',10,'color','r','MarkerFaceColor','b');
          else
           % disp('Wrong choice')
          end
      end    
      
end
%%% remove null if exist...      
j=1;

for i=1:length(tmpxylon)
    if tmpxylon(i)~=0 
        selectedstalon(j)=tmpxylon(i);
        selectedstalat(j)=tmpxylat(i);
        selectedstaname(j)=tmpxyname(i);
        j=j+1;
    else
    end
end

%
% selectedstalon;
% selectedstalat;
% selectedstaname;
% % size(selectedstalon)
% size(selectedstaname)

staname

%% output to stations.isl
        fid = fopen('stations.isl','w');
          if ispc
             fprintf(fid,'%s\r\n', num2str(length(selectedstaname)));
          else
             fprintf(fid,'%s\n', num2str(length(selectedstaname)));
          end

        fclose(fid);
%%  check if GREEN folder exists..

h=dir('green');

if isempty(h);
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

%%

%%%%%%%%%%%%%%%%%%convert these to Cartesian and create station.dat and
%%%%%%%%%%%%%%%%%%source.dat

%%%%%%%%%%%HERE WE HAVE TO COMPUTE AZIMUTHS, DISTANCES FOR ALL NETWORK AND EPICENTER AND WRITE TO
%%%%%%%%%%%FILES....

%fix origin on the epicenter
orlat=eventcor(2);
orlon=eventcor(1);

%%%%%%%%%%%%  USE GRS80 ELLIPSOID
grs80.geoid = almanac('earth','geoid','km','grs80');
%%%%%%%%%%%%%%%%CALCULATE AZIMUTH AND EPICENTRAL DISTANCE FOR EVERY STATION
for i=1:length(selectedstalon)
    staazim(i)=azimuth(eventcor(2),eventcor(1),selectedstalat(i),selectedstalon(i),grs80.geoid);
    epidist(i)=distdim(distance(eventcor(2),eventcor(1),selectedstalat(i),selectedstalon(i),grs80.geoid),'km','km');
end


%%%% FIX SOURCE AT ORIGIN  20/09/03
sourceXdist=0;
sourceYdist=0;

%%%%%OUTPUT SOURCE LOCATION %%%%%%%%%%%%%%%%%
if ispc
  fid = fopen('.\green\source.dat','w');
    fprintf(fid,'%s\r\n',' Source parameters');
    fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
    fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\r\n',sourceYdist,sourceXdist, epidepth,magn, '''', eventdate, '''');
  fclose(fid);

else
  fid = fopen('./green/source.dat','w');
    fprintf(fid,'%s\n',' Source parameters');
    fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
    fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\n',sourceYdist,sourceXdist, epidepth,magn, '''', eventdate, '''');
  fclose(fid);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 for i=1:length(selectedstaname)
             [stationXdist(i),stationYdist(i)] = pol2cart(deg2rad(staazim(i)),epidist(i));
 end
% 
%  whos selectedstaname stationXdist

%%%%%%%%OUTPUT%%%%%%%%%%%%%%%%%%%%
for i=1:length(selectedstaname)
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
    station(i).name=selectedstaname{1,i};
    station(i).pol='?';   % changes 10/12/2013

end    

%%%%% Sort selected stations by distance

[dummy order]=sort([station(:).epidist]);
stationsorted=station(order);


disp(['You have selected ', num2str(length(selectedstaname)), ' stations for inversion'])

disp(' No   Station   Azimuth (Deg)    Distance (km) ')

for i=1:length(selectedstaname)
    disp([ num2str(i,'%03u') '     '  stationsorted(i).name '       '    num2str(stationsorted(i).azm,'%4.1f') '            '  num2str(stationsorted(i).epidist,'%6.2f')])
end

    helpdlg(['You have selected ', num2str(length(selectedstaname)), ' stations for inversion']);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Check if selected station names are > 3 characters
% for i=1:length(selectedstaname)
%     indexsta(i)=length(stationsorted(i).name)>3;
% end
% %
%   switch sum(indexsta)
%      case 0
%           % check if station_index.isl exists and if yes remove it 
%           A = exist('station_index.isl','file');
%          switch A
%              case 2
%              % remove
%              delete('station_index.isl');
%          otherwise
%          end
%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           cd green
% 
%            fid = fopen('station.dat','w');
%            fprintf(fid,'%s\r\n',' Station co-ordinates');
%            fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),azim.,dist.,stat.');
% 
%            for i=1:length(selectedstaname)
%               fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,stationsorted(i).name,stationsorted(i).pol);
%            end
%            fclose(fid);
% 
%           %3 Create allstat2.dat needed for multiple crustal models....    25/06/09
%           dummy=1;
%           fid = fopen('allstat2.dat','w');
% 
%            for i=1:length(selectedstaname)
%              fprintf(fid,'%s  %i %i %i %i    %i\r\n',stationsorted(i).name,dummy,dummy,dummy,dummy,dummy);%,selectedstaname{1,i}');
%           % fprintf(fid,'%s  %i %i %i %i    %i\r\n',num2str(i,'%03u'),dummy,dummy,dummy,dummy,dummy);%,selectedstaname{1,i}');
%            end
%            fclose(fid);
%          % go out of green
%          cd ..
%              %%%% prepare allstat.dat
%              %%% check if INVERT folder exists..
%             h=dir('invert');
%             if isempty(h);
%                   errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
%             return
%             else
%             end
%        cd invert
%            samples=1;   % number of samples in XXXRAW.DAT files...(after resampling)  % reset to 1 after Jiri's change 25/07/05
%            dummy=1;
%            fid = fopen('allstat.dat','w');
%                for i=1:length(selectedstaname)
%                 fprintf(fid,'%s  %i %i %i %i\r\n',stationsorted(i).name,dummy,dummy,dummy,dummy);
%                end
%            fclose(fid);
%       cd ..
%  
% otherwise
%          %1 prepare an index file
%          fid = fopen('station_index.isl','w');
%              for i=1:length(selectedstaname)
%                   if length(stationsorted(i).name) > 3
%                         fprintf(fid,'%s %s\r\n',num2str(i,'%03u'),stationsorted(i).name);
%                   end
%              end
%          fclose(fid);
%        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
%        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
%        cd green
% 
%            fid = fopen('station.dat','w');
%            fprintf(fid,'%s\r\n',' Station co-ordinates');
%            fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),azim.,dist.,stat.');
% 
%            for i=1:length(selectedstaname)
%               % fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',out(i,1),out(i,2),out(i,3),out(i,4),out(i,5),selectedstaname{1,i}','U');
%               % fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,num2str(i,'%03u'),stationsorted(i).pol);
%            fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,stationsorted(i).name,stationsorted(i).pol);
%            end
%            fclose(fid);
% 
%           %3 Create allstat2.dat needed for multiple crustal models....    25/06/09
%           dummy=1;
%           fid = fopen('allstat2.dat','w');
%            for i=1:length(selectedstaname)
%           
%            if length(stationsorted(i).name) > 3
%            fprintf(fid,'%s  %i %i %i %i    %i\r\n',num2str(i,'%03u'),dummy,dummy,dummy,dummy,dummy); 
%            else
%            fprintf(fid,'%s  %i %i %i %i    %i\r\n',stationsorted(i).name,dummy,dummy,dummy,dummy,dummy); 
%            end
%            
%            end
%            fclose(fid);
%          % go out of green
%        cd ..
%       %%%% prepare allstat.dat
%       %%% check if INVERT folder exists..
%             h=dir('invert');
%             if length(h) == 0;
%                   errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
%             return
%             else
%             end
%        cd invert
%            samples=1;   % number of samples in XXXRAW.DAT files...(after resampling)  % reset to 1 after Jiri's change 25/07/05
%            dummy=1;
%            fid = fopen('allstat.dat','w');
%                for i=1:length(selectedstaname)
%                   if length(stationsorted(i).name) > 3
%                 %    fprintf(fid,'%s  %i %i %i %i\r\n',selectedstaname{1,i}',dummy,dummy,dummy,dummy);
%                 %fprintf(fid,'%s  %i %i %i %i\r\n',stationsorted(i).name,dummy,dummy,dummy,dummy);
%                  fprintf(fid,'%s  %i %i %i %i\r\n',num2str(i,'%03u'),dummy,dummy,dummy,dummy); 
%                   else
%                  fprintf(fid,'%s  %i %i %i %i\r\n',stationsorted(i).name,dummy,dummy,dummy,dummy); 
%                   end
%                end
%            fclose(fid);
%       cd ..
%          
%       
%       
%       
%   end  %% end of switch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%% CHANGE 20/10/2011 of allstat.dat format
% allstat will be index 1 1 1 1 name
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
       cd green
        if ispc  
          fid = fopen('station.dat','w');
           fprintf(fid,'%s\r\n',' Station co-ordinates');
           fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),azim.,dist.,stat.');
            for i=1:length(selectedstaname)
              % fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',out(i,1),out(i,2),out(i,3),out(i,4),out(i,5),selectedstaname{1,i}','U');
              % fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,num2str(i,'%03u'),stationsorted(i).pol);
              fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,stationsorted(i).name,stationsorted(i).pol);
            end
          fclose(fid);
        else
          fid = fopen('station.dat','w');
           fprintf(fid,'%s\n',' Station co-ordinates');
           fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),azim.,dist.,stat.');
            for i=1:length(selectedstaname)
              % fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',out(i,1),out(i,2),out(i,3),out(i,4),out(i,5),selectedstaname{1,i}','U');
              % fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,num2str(i,'%03u'),stationsorted(i).pol);
              fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,stationsorted(i).name,stationsorted(i).pol);
            end
          fclose(fid);
        end
           
          %3 Create allstat2.dat needed for multiple crustal models....    25/06/09
          dummy=1;
          fid = fopen('allstat2.dat','w');
          if ispc
             for i=1:length(selectedstaname)
%               fprintf(fid,'%s  %i %i %i %i    %i   %s\r\n',num2str(i,'%03u'),dummy,dummy,dummy,dummy,dummy,stationsorted(i).name); 
                fprintf(fid,'%s  %i %i %i %i    %i\r\n',stationsorted(i).name,1,1,1,1,1); 
               
             end
          else
             for i=1:length(selectedstaname)
%               fprintf(fid,'%s  %i %i %i %i    %i   %s\n',num2str(i,'%03u'),dummy,dummy,dummy,dummy,dummy,stationsorted(i).name); 
                fprintf(fid,'%s  %i %i %i %i    %i\n',stationsorted(i).name,1,1,1,1,1); 
             end
          end
           fclose(fid);
         % go out of green
       cd ..
       
       
      %%%% prepare allstat.dat
      %%% check if INVERT folder exists..
            h=dir('invert');
            if isempty(h);
                  errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
            return
            else
            end
       cd invert
           dummy=1;
           fid = fopen('allstat.dat','w');
           if ispc
               for i=1:length(selectedstaname)
%                 fprintf(fid,'%s  %i %i %i %i %s\r\n',num2str(i,'%03u'),dummy,dummy,dummy,dummy,stationsorted(i).name); 
                 fprintf(fid,'%s  %i %i %i %i %s %s %s %s\r\n',stationsorted(i).name,dummy,dummy,dummy,dummy,'0.05','0.06','0.08','0.09'); 
               end
           else
               for i=1:length(selectedstaname)
%                 fprintf(fid,'%s  %i %i %i %i %s\r\n',num2str(i,'%03u'),dummy,dummy,dummy,dummy,stationsorted(i).name); 
                 fprintf(fid,'%s  %i %i %i %i %s %s %s %s\n',stationsorted(i).name,dummy,dummy,dummy,dummy,'0.05','0.06','0.08','0.09'); 
               end
           end
           fclose(fid);
      cd ..

%%     
         

%

% Change for allowing long station names...
%for i=1:length(selectedstaname)
%    fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',out(i,1),out(i,2),out(i,3),out(i,4),out(i,5),selectedstaname{1,i}','U');
     
%     fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,stationsorted(i).name,stationsorted(i).pol);
%end
%fclose(fid);
%%

%%%% make source.dat station.dat in polarity...
%check if polarity exists..!
h=dir('polarity');

if isempty(h);
    errordlg('Polarity folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

cd polarity

if ispc
 fid = fopen('station.dat','w');
  fprintf(fid,'%s\r\n',' Station co-ordinates');
  fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),azim.,dist.,stat.');
   
    for i=1:length(selectedstaname)
      %    fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',out(i,1),out(i,2),out(i,3),out(i,4),out(i,5),selectedstaname{1,i}','U');
      fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,stationsorted(i).name,stationsorted(i).pol);
    end
 fclose(fid);
else
 fid = fopen('station.dat','w');
  fprintf(fid,'%s\n',' Station co-ordinates');
  fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),azim.,dist.,stat.');
   
    for i=1:length(selectedstaname)
      %    fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',out(i,1),out(i,2),out(i,3),out(i,4),out(i,5),selectedstaname{1,i}','U');
      fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\n',stationsorted(i).X,stationsorted(i).Y,stationsorted(i).A,stationsorted(i).azm,stationsorted(i).epidist,stationsorted(i).name,stationsorted(i).pol);
    end
 fclose(fid);
end

if ispc
  fid = fopen('source.dat','w');
    fprintf(fid,'%s\r\n',' Source parameters');
    fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
    fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\r\n',sourceYdist,sourceXdist, epidepth,magn, '''', eventdate, '''');
  fclose(fid);
else
  fid = fopen('source.dat','w');
    fprintf(fid,'%s\n',' Source parameters');
    fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
    fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\n',sourceYdist,sourceXdist, epidepth,magn, '''', eventdate, '''');
  fclose(fid);
end

cd ..

%%%%%%%%%%%%%%%
% disp('Selected stations')
% 
% for i=1:length(selectedstaname)
%         disp(selectedstaname{1,i})
% end
   
%%%%%%%%%%% let's output selected station coordinates to gmtfiles to
%%%%%%%%%%% prepare GMT style map....
h=dir('gmtfiles');

if isempty(h);
    errordlg('Gmtfiles folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

try

cd gmtfiles
    
 fid = fopen('selstat.gmt','w');
   if ispc  
     for i=1:length(selectedstaname)
       fprintf(fid,'%s  %f  %f\r\n',selectedstaname{1,i}',selectedstalat(i),selectedstalon(i));
     end
   else
     for i=1:length(selectedstaname)
       fprintf(fid,'%s  %f  %f\n',selectedstaname{1,i}',selectedstalat(i),selectedstalon(i));
     end
   end
     
 fclose(fid);

fid = fopen('event.gmt','w');
  if ispc
    fprintf(fid,'%f  %f\r\n',eventcor(1),eventcor(2) );
  else
    fprintf(fid,'%f  %f\n',eventcor(1),eventcor(2) );
  end
fclose(fid);

%%
evestalat=[selectedstalat eventcor(2)];
evestalon=[selectedstalon eventcor(1)];

minlat=min(evestalat)-0.2;
maxlat=max(evestalat)+0.2;
minlon=min(evestalon)-0.2;
maxlon=max(evestalon)+0.2;

latspan=maxlat-minlat;  
lonspan=maxlon-minlon;  

if latspan < 1
    mapticsla=0.2;
elseif latspan > 1 &&  latspan < 5
    mapticsla=0.5;
elseif latspan > 5 && latspan < 10
    mapticsla=1;
else
    mapticsla=2;
end

if lonspan < 1
    mapticslo=0.2;
elseif lonspan > 1 && lonspan < 5
    mapticslo=0.5;
elseif lonspan > 5 && lonspan < 10
    mapticslo=1;
else
    mapticslo=2;
end

%%%make -R
%num2str(centx,'%7.2f')
r=['-R' num2str(minlon,'%7.5f') '/' num2str(maxlon,'%7.5f') '/' num2str(minlat,'%7.5f') '/' num2str(maxlat,'%7.5f') ' '];

%%%make -J
%j=[' -JM' num2str(scale) 'c+'];
j=' -JM16c+';
if latspan < 1
    sckm=10;
elseif latspan > 1 && latspan < 5
    sckm=50;
elseif latspan > 5 && latspan < 10
    sckm=100;
else
    sckm=200;
end

L=[' -Lf' num2str((lonspan/2)+minlon) '/' num2str(minlat+(0.07*latspan)) '/'  num2str((latspan/2)+minlat) '/' num2str(sckm) '+l']; 
%% output

if ispc
  fid = fopen('plotselsta.bat','w');

    fprintf(fid,'%s\r\n','gmtset PLOT_DEGREE_FORMAT D  ANNOT_FONT_SIZE_PRIMARY 12 ANNOT_FONT_SIZE_SECONDARY 12 HEADER_FONT_SIZE 14 LABEL_FONT_SIZE 14');
    fprintf(fid,'%s\r\n','  ');
    fprintf(fid,'%s\r\n','gawk "{print $3,$2,1}" selstat.gmt > sta.gmt');
    fprintf(fid,'%s\r\n','gawk "{print $3,$2,11,0,1,\"CB\",$1}" selstat.gmt > tsta.gmt');
    fprintf(fid,'%s\r\n','  ');
    %x, y, size, angle, fontno, justify, text).
      pscoastr=['pscoast ' r   j ' -G255/255/204 -Df -W0.7p ' L  ' -B' num2str(mapticslo) '/' num2str(mapticsla) ':."Event ID\072' eventidnew '": '  ' -Na/0.8p,red,-.- -K -S104/204/255  > ' eventidnew '_selsta.ps' ];
    fprintf(fid,'%s\r\n', pscoastr);
      sstring=['psxy -R -J  sta.gmt -St.4c -M  -W1p/0 -K -O -G255/0/0 >> ' eventidnew '_selsta.ps' ];
    fprintf(fid,'%s\r\n',sstring);
      sstring=['pstext -R -J  tsta.gmt  -D0/0.45c  -W255/255/255,o  -K -O -G0/0/255 >> ' eventidnew '_selsta.ps' ];
    fprintf(fid,'%s\r\n',sstring);
      sstring=['psxy -R -J event.gmt -Sa.6c -M  -W1p/0  -O -G255/0/0 >> ' eventidnew '_selsta.ps' ];
    fprintf(fid,'%s\r\n',sstring);
    fprintf(fid,'%s\r\n','  ');
    fprintf(fid,'%s\r\n',['ps2raster ' eventidnew '_selsta.ps -A -P -Tg']);
    fprintf(fid,'%s\r\n','  ');
    fprintf(fid,'%s\r\n','del tsta.gmt sta.gmt');
    fprintf(fid,'%s\r\n','  ');
    fprintf(fid,'%s\r\n',['copy ' eventidnew '_selsta.ps     ..\output\']);
    fprintf(fid,'%s\r\n',['copy ' eventidnew '_selsta.png     ..\output\']);
    fprintf(fid,'%s\r\n','  ');
%     fprintf(fid,'%s\r\n',['del ' eventidnew '_selsta.ps'] );
%     fprintf(fid,'%s\r\n',['del ' eventidnew '_selsta.png'] );
   
fclose(fid);

else %Linux
  fid = fopen('plotselsta.bat','w');

    fprintf(fid,'%s\n','gmtset PLOT_DEGREE_FORMAT D  ANNOT_FONT_SIZE_PRIMARY 12 ANNOT_FONT_SIZE_SECONDARY 12 HEADER_FONT_SIZE 14 LABEL_FONT_SIZE 14');
    fprintf(fid,'%s\n','  ');
    fprintf(fid,'%s\n','gawk ''{print $3,$2,1}'' selstat.gmt > sta.gmt');
    fprintf(fid,'%s\n','gawk ''{print $3,$2,11,0,1,"CB",$1}'' selstat.gmt > tsta.gmt');
    fprintf(fid,'%s\n','  ');
    %x, y, size, angle, fontno, justify, text).
      pscoastr=['pscoast ' r   j ' -G255/255/204 -Df -W0.7p ' L  ' -B' num2str(mapticslo) '/' num2str(mapticsla) ':."Event ID\072' eventidnew '": '  ' -Na/0.8p,red,-.- -K -S104/204/255  > ' eventidnew '_selsta.ps' ];
    fprintf(fid,'%s\n', pscoastr);
      sstring=['psxy -R -J  sta.gmt -St.4c -M  -W1p/0 -K -O -G255/0/0 >> ' eventidnew '_selsta.ps' ];
    fprintf(fid,'%s\n',sstring);
      sstring=['pstext -R -J  tsta.gmt  -D0/0.45c  -W255/255/255,o  -K -O -G0/0/255 >> ' eventidnew '_selsta.ps' ];
    fprintf(fid,'%s\n',sstring);
      sstring=['psxy -R -J event.gmt -Sa.6c -M  -W1p/0  -O -G255/0/0 >> ' eventidnew '_selsta.ps' ];
    fprintf(fid,'%s\n',sstring);
    fprintf(fid,'%s\n','  ');
    fprintf(fid,'%s\n',['ps2raster ' eventidnew '_selsta.ps -A -P -Tg']);
    fprintf(fid,'%s\n','  ');
    fprintf(fid,'%s\n','rm tsta.gmt sta.gmt');
    fprintf(fid,'%s\n','  ');
    fprintf(fid,'%s\n',['cp ' eventidnew '_selsta.ps     ../output/']);
    fprintf(fid,'%s\n',['cp ' eventidnew '_selsta.png     ../output/']);
    fprintf(fid,'%s\n','  ');
%     fprintf(fid,'%s\n',['rm ' eventidnew '_selsta.ps'] );
%     fprintf(fid,'%s\n',['rm ' eventidnew '_selsta.png'] );
   
fclose(fid);
    
end

if ispc
   [status, result] =system('plotselsta.bat');
else
   !chmod +x plotselsta.bat
   !./plotselsta.bat
   
end



    cd ..
 
catch
    cd ..
end
 

