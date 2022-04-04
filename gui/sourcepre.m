function varargout = sourcepre(varargin)
% SOURCEPRE M-file for sourcepre.fig
%      SOURCEPRE, by itself, creates a new SOURCEPRE or raises the existing
%      singleton*.
%
%      H = SOURCEPRE returns the handle to a new SOURCEPRE or the handle to
%      the existing singleton*.
%
%      SOURCEPRE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOURCEPRE.M with the given input arguments.
%
%      SOURCEPRE('Property','Value',...) creates a new SOURCEPRE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sourcepre_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sourcepre_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sourcepre

% Last Modified by GUIDE v2.5 06-Jan-2019 18:31:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sourcepre_OpeningFcn, ...
                   'gui_OutputFcn',  @sourcepre_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before sourcepre is made visible.
function sourcepre_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sourcepre (see VARARGIN)

% Choose default command line output for sourcepre
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%if strcmp(get(hObject,'Visible'),'off')
%    initialize_gui(hObject, handles);
%end

% UIWAIT makes sourcepre wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%%% check event.isl files with event info

h=dir('event.isl');

if length(h) == 0; 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    fclose(fid);
end


set(handles.lat,'String',num2str(eventcor(2,1)))        
set(handles.lon,'String',num2str(eventcor(1,1)))          
set(handles.depth,'String',num2str(epidepth))          
set(handles.magn,'String',num2str(magn))          
set(handles.eventdate,'String',eventdate)          
%% check if we have sourcesinfo.txt in gmtfiles folder
if ispc
   h=dir('.\gmtfiles\sourcesinfo.txt');
else
   h=dir('./gmtfiles/sourcesinfo.txt');
end

if length(h) == 0; 
  disp('sourcesinfo.txt file doesn''t exist in gmtfiles folder. Using defaults.');
else
    if ispc
       fid = fopen('.\gmtfiles\sourcesinfo.txt','r'); 
    else
       fid = fopen('./gmtfiles/sourcesinfo.txt','r');  
    end
    
     tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);
     tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);
     
     tline = fgetl(fid);
     set(handles.depth,'String',strrep(tline,' ',''))   
     
     tline = fgetl(fid);     
     tline = fgetl(fid);
     set(handles.northkm,'String',strrep(tline,' ',''))
     
     tline = fgetl(fid);     
     tline = fgetl(fid);
     set(handles.eastkm,'String',strrep(tline,' ',''))
     
     tline = fgetl(fid);     
     tline = fgetl(fid);
     set(handles.noSourcesstrike,'String',strrep(tline,' ',''))     
     noSourcesstrike=str2double(tline);
     
     tline = fgetl(fid);     
     tline = fgetl(fid);
     set(handles.distanceStep,'String',strrep(tline,' ',''))      
     spacing=str2double(tline);
     
     % update the Length (km) also
     set(handles.flength,'string',num2str((noSourcesstrike*spacing)-spacing));
     
     tline = fgetl(fid);     
     tline = fgetl(fid);
     set(handles.noSourcesdip,'String',strrep(tline,' ',''))        
     noSourcesdip=str2double(tline);
      
     tline = fgetl(fid);     
     tline = fgetl(fid);
     set(handles.steponPlane,'String',strrep(tline,' ',''))          
     steponPlane=str2double(tline);
     % update the width (km) also
     set(handles.fwidth,'string',num2str((noSourcesdip*steponPlane)-steponPlane));
     
     tline = fgetl(fid);     
     tline = fgetl(fid);
     set(handles.firstSourcestrike,'String',strrep(tline,' ',''))   
     
     tline = fgetl(fid);    
     tline = fgetl(fid);
     set(handles.firstsourcedip,'String',strrep(tline,' ',''))   
     
     tline = fgetl(fid);    
     tline = fgetl(fid);
     set(handles.Strike,'String',strrep(tline,' ',''))   
     
     tline = fgetl(fid);    
     tline = fgetl(fid);
     set(handles.Dip,'String',strrep(tline,' ',''))   
     
     try % for sourcesinfo.txt in old format.!!
         
       tline = fgetl(fid);
       tline = fgetl(fid);
      if str2num(tline)==1
         set(handles.checkbox1,'Value',1)   
         tline = fgetl(fid); tline = fgetl(fid);
         set(handles.rake,'String',tline)
         tline = fgetl(fid); tline = fgetl(fid);
         set(handles.norakesources,'String',tline)
         tline = fgetl(fid); tline = fgetl(fid);
         set(handles.rakespacing,'String',tline)
         tline = fgetl(fid); tline = fgetl(fid);
         set(handles.rakerefsource,'String',tline)
         
         on =[handles.rake,handles.raketext,handles.norakesources,handles.rakespacing,handles.rakerefsource,handles.text45,handles.text46,handles.text47,handles.text48];
         enableon(on)        
      else
         set(handles.checkbox1,'Value',0)    
      end
      
     catch
      disp('Old sourcesinfo.txt')
     end
     
     fclose(fid);  
end
   



% --- Outputs from this function are returned to the command line.
function varargout = sourcepre_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


disp('This is sourcepre version 30/11/2019');

% --- Executes during object creation, after setting all properties.
function lat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lat_Callback(hObject, eventdata, handles)
% hObject    handle to lat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lat as text
%        str2double(get(hObject,'String')) returns contents of lat as a double
density = str2double(get(hObject, 'String'));
if isnan(density)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

data = getappdata(gcbf, 'metricdata');
data.density = density;
setappdata(gcbf, 'metricdata', data);

% --- Executes during object creation, after setting all properties.
function lon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lon_Callback(hObject, eventdata, handles)
% hObject    handle to lon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lon as text
%        str2double(get(hObject,'String')) returns contents of lon as a double
volume = str2double(get(hObject, 'String'));
if isnan(volume)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

data = getappdata(gcbf, 'metricdata');
data.volume = volume;
setappdata(gcbf, 'metricdata', data);



% --- Executes on button press in onelinestrike.
function onelinestrike_Callback(hObject, eventdata, handles)
% hObject    handle to onelinestrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of onelinestrike

set(handles.onelinestrike, 'Value', 1);
set(handles.onelinedip, 'Value', 0);
set(handles.oneplane, 'Value', 0);



% --- Executes on button press in onelinedip.
function onelinedip_Callback(hObject, eventdata, handles)
% hObject    handle to onelinedip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of onelinedip

set(handles.onelinestrike, 'Value', 0);
set(handles.onelinedip, 'Value', 1);
set(handles.oneplane, 'Value', 0);



% --- Executes on button press in Calculate.
function Calculate_Callback(hObject, eventdata, handles)
% hObject    handle to Calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%% check if GREEN folder exists..

h=dir('green');

if length(h) == 0;
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end


%%% go in GREEN
cd green
%%%%%%DELETE src files
[s,w] = system('del src*.dat');
%% go back
cd ..


%%% check if gmtfiles folder exists..

h=dir('gmtfiles');

if length(h) == 0;

    button = questdlg('Gmtfiles folder doesn''t exist. Create it ?','Folder error','Yes','No','Yes');
            if strcmp(button,'Yes')
                  disp('Creating gmtfiles folder')
                  mkdir('gmtfiles')
            elseif strcmp(button,'No')
                  disp('Abort')
                  return
            else
                  disp('Abort')
                  return
            end
else
end

%%%%%%EPICENTER
epilat = str2double(get(handles.lat,'String'));
epilon = str2double(get(handles.lon,'String'));
epidepth = str2double(get(handles.depth,'String'));

northkm=str2double(get(handles.northkm,'String'));
eastkm=str2double(get(handles.eastkm,'String'));

if northkm == 0 && eastkm == 0 
    disp('No shift in epicenter')
    
    Edist=0;
    Ndist=0;

    newlon=epilon; 
    newlat=epilat; 
    
    orshift=0;
 
else
%%%%change position of starting point...
%%%% distance between points and azimuth is needed

[dist,theta]=az(eastkm,northkm)
[newlat,newlon] = vdistinv(epilat,epilon,dist*1000,theta);

%%%%%%%%%%%%%%%

    Edist=eastkm;
    Ndist=northkm;
    orshift=1;
       
%%%% change Lat Lon values....
set(handles.lat,'String',num2str(newlat),...
                  'FontSize',12,...
                  'FontWeight','bold',...
                  'ForegroundColor','red')        
set(handles.lon,'String',num2str(newlon),...
                  'FontSize',12,...
                  'FontWeight','bold',...
                  'ForegroundColor','red')        
end

%%%%%%%%% FAULT
strike = str2double(get(handles.Strike,'String'));
dip = str2double(get(handles.Dip,'String'));

%%%%%%%  No of Sources
noSourcesstrike = str2double(get(handles.noSourcesstrike,'String'));
%%%%%%%  Distance step
distanceStep = str2double(get(handles.distanceStep,'String'));
%%%%%%%  No Lines
% noLines = str2double(get(handles.firstsourcedip,'String'));
%%%%%%%  distance step on plane
steponPlane = str2double(get(handles.steponPlane,'String'));
%%%%%%%  First Source (Hypocenter)
firstSourcestrike = str2double(get(handles.firstSourcestrike,'String'));
firstSourcedip = str2double(get(handles.firstsourcedip,'String'));

%%%%%%%%% No os sources on Dip
noSourcesdip = str2double(get(handles.noSourcesdip,'String'));

%%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
magn=str2double(get(handles.magn,'String'));
eventdate=get(handles.eventdate,'String');

%%%%%%%%%%%%WE FIX ORIGIN OF CARTESIAN SYSTEM ON THE EPICENTER  %%%%%%
%%%%Convert strike to radians
strikerad=deg2rad(90-strike);    %%%%% set to 0
diprad=deg2rad(dip);

%%%%%%%%%% WE DECIDE WHAT TO CALCULATE 
%%%%%%%%%% LINE ALONG STRIKE
%%%%%%%%%% LINE ALONG DIP
%%%%%%%%%% PLANE

if (get(handles.checkbox1,'Value') == get(handles.checkbox1,'Max'))
    disp('Sources will be computed on an inclined line following Strike, Dip and Rake'); 
    val=4;    
    rake = str2double(get(handles.rake,'String'));
else

  if noSourcesdip==0 
    val=1;
    disp('Sources will be computed on a horizontal line (at the specific depth) along Strike');
  elseif noSourcesdip ~=0 && noSourcesstrike ==0
    val=2;
    disp('Sources will be computed along Dip');
  elseif noSourcesdip ~=0  && noSourcesstrike ~=0
    val=3;
    disp('Sources will be computed on a plane');
  else
     helpdlg('Error');     %%%%%%%%%%%%%%
  end

end

switch val
    
case 1      %%%%%%%%%%line of epicenters along strike
            disp('Calculating sources along strike line')  
            
            %%%% FIND SOURCES ALONG FIRST STRIKE LINE 
            for i=1:noSourcesstrike
                strdis(i)=distanceStep*(i-firstSourcestrike);
            end

            %%FIND COORDINATES ALONG STRIKE
            for i=1:noSourcesstrike
                strdisX(i)=strdis(i)*cos(strikerad)+Edist;  % East
                strdisY(i)=strdis(i)*sin(strikerad)+Ndist;  % North
                strdisZ(i)=epidepth;    
            end

            figure(1)       %X-Y
            plot(strdisX,strdisY,'ro');xlabel('X (km)'); ylabel('Y (km)'); title('X-Y'); grid on
            axis ([-(max(abs(strdisX))+1) max(abs(strdisX))+1 -(max(abs(strdisY))+1) max(abs(strdisY))+1])  %%%%%% !!!!!!!
            
             %%%%%%%%OUTPUT TO SRC FILES
             %%%%%%% and source.isl !!!!!!!!!
             fid2 = fopen('tsources.isl','w');
              fprintf(fid2,'%s\r\n','line');
              fprintf(fid2,'%i\r\n',noSourcesstrike);
              fprintf(fid2,'%f\r\n',distanceStep);
              fprintf(fid2,'%f\r\n',firstSourcestrike);
             fclose(fid2);
             
           %% go in GREEN
           cd green
             
             for i=1:noSourcesstrike
             %%% find filename
             filename=['src' num2str(i,'%02d') '.dat'];
             %%%% open file
             fid = fopen(filename,'w');
             fprintf(fid,'%s\r\n',' Source parameters');
             fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
             fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\r\n',strdisY(i),strdisX(i), strdisZ(i),magn, '''', eventdate, '''');
             fclose(fid);
             end

           cd .. 
           %%
             %%%% HERE WE HAVE TO CONVERT TO 'GEOGRAPHICAL COORDINATES'
             %%%%           Use vdistinv subroutine from Matlab user files...!!
             %%%%            output should be in WGS84..
             %%%             read  "epicenter"..
             for i=1:noSourcesstrike
                      if strdis(i) < 0 
                              azim=strike+180;
                                if azim > 360
                                    azim=azim-360;
                                end
                      else
                              azim=strike;
                      end
                      [strdisYgeo(i),strdisXgeo(i)] = vdistinv(newlat,newlon,abs(strdis(i))*1000,azim);
             end
             
             %%%%%%%%%%OUTPUT TO GMT FILE
          try
             %% go in gmtfile
          cd gmtfiles
            fid = fopen('sources.gmt','w');
%              fprintf(fid,'%s\r\n','>');
             for i=1:noSourcesstrike
             fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f %3i %s\r\n',strdisXgeo(i),strdisYgeo(i),'0.2',epidepth,i,'d');
             end
%              fprintf(fid,'%s\r\n','>');
             fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f  %s %s\r\n',newlon,newlat,'0.8',epidepth,'New_ref','a');
%              fprintf(fid,'%s\r\n','>');
             fprintf(fid,'  %5.10f   %5.10f   %s %5.10f  %s %s\r\n',epilon,epilat,'0.4',epidepth,'Old_ref','a');
            fclose(fid);   
             %% sour.dat
             fid = fopen('sour.dat','w');   % XY file ...
                  for i=1:noSourcesstrike
                     fprintf(fid,'%10.4f   %10.4f  %10.4f  %s\r\n',strdisX(i),strdisY(i), strdisZ(i), num2str(i));
                  end
             fclose(fid);
             %%%%%%%%%%%%%%%%%%%%%%%%make plot batch file
             %%%find map limits...
              border=0.1;
                  wend=min(strdisXgeo);
                  eend=max(strdisXgeo);
                  send=min(strdisYgeo);
                  nend=max(strdisYgeo);
                    w=(wend-border);
                    e=(eend+border);
                    s=(send-border);
                    n=(nend+border);
               r=['-R' num2str(w,'%7.5f') '/' num2str(e,'%7.5f') '/' num2str(s,'%7.5f') '/' num2str(n,'%7.5f') ' '];
               j=[' -JM14c'];
           
             fid = fopen('psources.bat','w');
                   fprintf(fid,'%s\r\n','gmtset PAPER_MEDIA A4');
                   fprintf(fid,'%s\r\n','gmtset PLOT_DEGREE_FORMAT D');
                   fprintf(fid,'%s\r\n',['pscoast ' r   j ' -G255/255/204 -Df -W0.7p  -B0.1 -K -S104/204/255   > sources.ps' ]);
                   fprintf(fid,'%s\r\n','psxy -R -J -O  -K      sources.gmt   -S  -G255/0/0    -W1.p -V >> sources.ps ');
                   fprintf(fid,'%s\r\n','gawk "{print $1,$2,"14","1","1","1",$5}" sources.gmt > textsou.txt');
                   fprintf(fid,'%s\r\n','pstext -R -J -O   textsou.txt  -V >> sources.ps ');
                       
             fclose(fid);   

  if (get(handles.kmlout,'Value') == get(handles.kmlout,'Max'))         
             
%%             try to prepare a KML file for Google Earth ..!!
              fid = fopen('sources.kml','w');
              
              fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\r\n');
              fprintf(fid,'<kml xmlns="http://earth.google.com/kml/2.1">\r\n');
              fprintf(fid,'<Document>\r\n');
              fprintf(fid,'<name> Trial sources </name>\r\n');
              fprintf(fid,'<description> Isola-GUI trial sources for Google Earth </description>\r\n');
              
              fprintf(fid,'<Style id="mystyle">\r\n');
              fprintf(fid,'<IconStyle>\r\n');
              fprintf(fid,'<scale>0.50</scale>\r\n');
              fprintf(fid,'<Icon><href>GEimages/circle_r.png</href></Icon>\r\n');
              fprintf(fid,'</IconStyle>\r\n');
              fprintf(fid,'<LineStyle>\r\n');
              fprintf(fid,'<color>ff0000ff</color>\r\n');
              fprintf(fid,'<width>3</width>\r\n');
              fprintf(fid,'</LineStyle>\r\n');
              fprintf(fid,'</Style>\r\n');
              fprintf(fid,'<Placemark>\r\n');
              fprintf(fid,'<description><![CDATA[Line created with Matlab GEplot.m]]></description>\r\n');
              fprintf(fid,'<name>Line</name>\r\n');
              fprintf(fid,'<visibility>1</visibility>\r\n');
              fprintf(fid,'<open>1</open>\r\n');
              fprintf(fid,'<styleUrl>mystyle</styleUrl>\r\n');
              fprintf(fid,'<LineString>\r\n');
              fprintf(fid,'<extrude>0</extrude>\r\n');
              fprintf(fid,'<tessellate>0</tessellate>\r\n');
              fprintf(fid,'<altitudeMode>clampToGround</altitudeMode>\r\n');
              fprintf(fid,'<coordinates>\r\n');
%  line
                 for i=1:noSourcesstrike
                      fprintf(fid,'%11.6f, %11.6f, 0\n',strdisXgeo(i),strdisYgeo(i));
                 end
        
              fprintf(fid,'</coordinates>\r\n');
              fprintf(fid,'</LineString>\r\n');
              fprintf(fid,'</Placemark>\r\n');
              
%      points
              fprintf(fid,'<Folder>\r\n');
              fprintf(fid,'<name> Trial sources </name>\r\n');
              
             for i=1:noSourcesstrike
              fprintf(fid,'      <Placemark>\r\n');

              fprintf(fid,'<name>%s</name>\r\n',num2str(i) );
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',strdisXgeo(i),strdisYgeo(i));
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');
              
             end
             
             
          if orshift == 1 
             
              fprintf(fid,'      <Placemark>\r\n');

              fprintf(fid,'<name> Old Origin </name>\r\n');
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',epilon,epilat);
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');
             
              fprintf(fid,'      <Placemark>\r\n');
              fprintf(fid,'<name> New Origin </name>\r\n');
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',newlon,newlat);
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');
             
          else

              fprintf(fid,'      <Placemark>\r\n');
              fprintf(fid,'<name>Origin</name>\r\n');
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',newlon,newlat);
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');

          end
          

fprintf(fid,'</Folder>\r\n');
fprintf(fid,'</Document>\r\n');
fprintf(fid,'</kml>\r\n');

fclose(fid);

  else
     disp('KML output is not selected'); 
  end
%%
             
%%%%%  output this run data...
             fid = fopen('sourcesinfo.txt','w');
             
             fprintf(fid,'Event Parameters\r\n') ;
             fprintf(fid,'Magnitude\r\n');
             fprintf(fid,'%4.2f\r\n', magn);
             fprintf(fid,'Date\r\n');
             fprintf(fid,'%s  \r\n', eventdate);
             fprintf(fid,'Lat\r\n');
             fprintf(fid,'%7.4f  \r\n', epilat);
             fprintf(fid,'Lon\r\n');
             fprintf(fid,'%7.4f  \r\n', epilon);
             fprintf(fid,'Depth\r\n');
             fprintf(fid,'%7.2f  \r\n', epidepth);
             fprintf(fid,'Shift to North\r\n');
             fprintf(fid,'%s   \r\n', get(handles.northkm,'String'));
             fprintf(fid,'Shift to East\r\n');
             fprintf(fid,'%s   \r\n', get(handles.eastkm,'String'));
             

             fprintf(fid,'No sources strike\r\n');
             fprintf(fid,'%s  \r\n', get(handles.noSourcesstrike,'String'));
             fprintf(fid,'Spacing along strike\r\n');
             fprintf(fid,'%s  \r\n', get(handles.distanceStep,'String'));

             fprintf(fid,'No sources dip\r\n');
             fprintf(fid,'%s  \r\n', get(handles.noSourcesdip,'String'));
             fprintf(fid,'Spacing along dip\r\n');
             fprintf(fid,'%s  \r\n', get(handles.steponPlane,'String'));

             fprintf(fid,'Strike reference\r\n');
             fprintf(fid,'%s  \r\n', get(handles.firstSourcestrike,'String'));
             fprintf(fid,'Dip reference\r\n');
             fprintf(fid,'%s  \r\n', get(handles.firstsourcedip,'String'));
             
             fprintf(fid,'Strike \r\n');
             fprintf(fid,'%s  \r\n', get(handles.Strike,'String'));
             fprintf(fid,'Dip \r\n');
             fprintf(fid,'%s  \r\n', get(handles.Dip,'String'));
             fprintf(fid,'Use rake \r\n');
             fprintf(fid,'%s  \r\n', '0');
             fprintf(fid,'rake \r\n');
             fprintf(fid,'%s  \r\n', '60');
             fclose(fid);
                          
             %%go back
             cd ..
         catch
             cd ..
         end
             
             %%%%%%%%%%%PLOT USING M_MAP
             figure(2)
             m_proj('Mercator','long',[min(strdisXgeo)-0.3 max(strdisXgeo)+0.3],'lat',[min(strdisYgeo)-0.3 max(strdisYgeo)+0.3]);
             m_gshhs_h('color','k');
             %m_gshhs_h('patch',[.7 .7 .7],'edgecolor','g');%'color','k');
             m_grid('box','fancy','tickdir','out');

             for i=1:noSourcesstrike
             m_line(strdisXgeo(i),strdisYgeo(i),'marker','square','markersize',5,'color','r');
             m_text(strdisXgeo(i),strdisYgeo(i),num2str(i),'vertical','top');
             end
             
            %%%plot new "epicenter"
             m_line(newlon,newlat,'marker','p','markersize',17,'color','y','MarkerFaceColor','y');

             %%%plot epicenter
             m_line(epilon,epilat,'marker','p','markersize',17,'color','b','MarkerFaceColor','b');


            
             %%%%%%%%%%%%%%%%%%%%%%%%
case 2       %%%%%%%%%%line of epicenters along dip
             disp('Calculating sources along dip line')     
             %% FIND SOURCES ALONG DIP LINE 
             for i=1:noSourcesdip
                 dipdis(i)=steponPlane*(i-firstSourcedip);
             end
             %%%%%FIND COORDINATES ALONG DIP WE START AT THE EPICENTER DEPTH
             %%%%%%(ORIGIN IS FIXED................)
             for i=1:noSourcesdip
                 dipdisY(i)=dipdis(i)*cos(diprad);
                 dipdisX(i)=0;
                 dipdisZ(i)=(dipdis(i)*sin(diprad)+epidepth);   %%%%%%%%dipdis(i)*sin(diprad);        %%%%%%%%
             end
                 
             figure(2)   % X-Z
             plot(dipdisX,dipdisZ,'ro')
             xlabel('X (km)')
             ylabel('Z (km)')
             title('X-Z')
             grid on
             axis ([-50 50 -50 50])   %%%%%%!!!!!!!!
             
             %%%%NOW WE ADD STRIKE BY ROTATING...............
             strikerad=deg2rad(strike);
             
             for i=1:noSourcesdip
                 dipdisXrot(i)=dipdisY(i)*sin(strikerad)+Edist;
                 dipdisYrot(i)=dipdisY(i)*cos(strikerad)+Ndist;
                 dipdisZrot(i)=dipdisZ(i);
             end
             
             figure(3)
             plot3(dipdisXrot,dipdisYrot,dipdisZrot,'-ro')
             axis([-50 50 -50 50 -50 50])
             grid on
             xlabel('X (km)')
             ylabel('Y (km)')
             zlabel('Z (km)')
             title('X-Y-Z')
             
             
             %%%%%%%%OUTPUT TO SRC FILES
             %%%%%%% and source.isl !!!!!!!!!
             
             fid2 = fopen('tsources.isl','w');
             fprintf(fid2,'%s\r\n','line');
             fprintf(fid2,'%i\r\n',noSourcesdip);
             fprintf(fid2,'%f\r\n',steponPlane);
             fprintf(fid2,'%f\r\n',firstSourcedip);
             fclose(fid2);

             %% go in GREEN
             cd green

             
             for i=1:noSourcesdip
             %%% find filename
             filename=['src' num2str(i,'%02d') '.dat'];
             %%%% open file
             fid = fopen(filename,'w');
             fprintf(fid,'%s\r\n',' Source parameters');
             fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
             fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\r\n',dipdisYrot(i),dipdisXrot(i),dipdisZrot(i),magn, '''', eventdate, '''');
             fclose(fid);
             end
             
             %% go back
             cd ..
             
             %%%%%%%%%%%%%%%%%%%%%%%%%%%
             %%%%%%%%%          HERE WE HAVE TO CONVERT TO 'GEOGRAPHICAL COORDINATES'
             %%%%%%%%%%%%%%%%%%%%%%%%%%%
             for i=1:noSourcesdip
                 
                      if dipdis(i) < 0 
                               azim=strike+180;
                                if azim > 360
                                    azim=azim-360;
                                end
                      else
                              azim=strike;
                      end
                     
%                       dip
                     
                 hdist(i)=cos(deg2rad(dip))*dipdis(i);
                 
              [dipdisYgeo(i),dipdisXgeo(i)] = vdistinv(newlat,newlon,abs(hdist(i))*1000,azim);
               dipdisZgeo(i)=dipdisZrot(i);
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             %%%%%%%%%%OUTPUT TO GMT FILE

  try    
             %% go in gmtfile
             cd gmtfiles
             
             
             fid = fopen('sources.gmt','w');
             fprintf(fid,'%s\r\n','>');
             for i=1:noSourcesdip
             fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f %3i %s\r\n',dipdisXgeo(i),dipdisYgeo(i),'0.2',dipdisZgeo(i),i,'d');
             end
             fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f  %s %s\r\n',newlon,newlat,'0.8',epidepth,'New_ref','a');
             fprintf(fid,'  %5.10f   %5.10f   %s %5.10f  %s %s\r\n',epilon,epilat,'0.4',epidepth,'Old_ref','a');

             fclose(fid);   
             %%%%%%%%%%%%%%%%%%%%%%%%
              
             %% sour.dat
             fid = fopen('sour.dat','w');   % XY file ...
                  for i=1:noSourcesdip
                     fprintf(fid,'%10.4f   %10.4f  %10.4f  %s\r\n',dipdisXrot(i),dipdisYrot(i),dipdisZrot(i), num2str(i));
                  end
             fclose(fid);
             
             %%%%%%%%%%%%%%%%%%%%%%%%make plot batch file
             %%%find map limits...
              border=0.1;
                  wend=min(dipdisXgeo);
                  eend=max(dipdisXgeo);
                  send=min(dipdisYgeo);
                  nend=max(dipdisYgeo);
                    w=(wend-border);
                    e=(eend+border);
                    s=(send-border);
                    n=(nend+border);
               r=['-R' num2str(w,'%7.5f') '/' num2str(e,'%7.5f') '/' num2str(s,'%7.5f') '/' num2str(n,'%7.5f') ' '];
               j=[' -JM14c'];

            
             fid = fopen('psources.bat','w');
                   fprintf(fid,'%s\r\n','gmtset PAPER_MEDIA A4');
                   fprintf(fid,'%s\r\n','gmtset PLOT_DEGREE_FORMAT D');
                   fprintf(fid,'%s\r\n',['pscoast ' r   j ' -G255/255/204 -Df -W0.7p  -B0.1 -K -S104/204/255   > sources.ps' ]);
                   fprintf(fid,'%s\r\n','psxy -R -J -O  -K      sources.gmt   -S  -G255/0/0    -W1.p -V >> sources.ps ');
                   fprintf(fid,'%s\r\n','gawk "{print $1,$2,"14","1","1","1",$5}" sources.gmt > textsou.txt');
                   fprintf(fid,'%s\r\n','pstext -R -J -O   textsou.txt  -V >> sources.ps ');
                       
             fclose(fid);   
             
%%             
 if (get(handles.kmlout,'Value') == get(handles.kmlout,'Max')) 
%             %%%% try to prepare a KML file for Google Earth ..!!
              fid = fopen('sources.kml','w');
              
              fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\r\n');
              fprintf(fid,'<kml xmlns="http://earth.google.com/kml/2.1">\r\n');
              fprintf(fid,'<Document>\r\n');
              fprintf(fid,'<name> Trial sources </name>\r\n');
              fprintf(fid,'<description> Isola-GUI trial sources for Google Earth </description>\r\n');
              
              fprintf(fid,'<Style id="mystyle">\r\n');
              fprintf(fid,'<IconStyle>\r\n');
              fprintf(fid,'<scale>0.50</scale>\r\n');
              fprintf(fid,'<Icon><href>GEimages/circle_r.png</href></Icon>\r\n');
              fprintf(fid,'</IconStyle>\r\n');
              fprintf(fid,'<LineStyle>\r\n');
              fprintf(fid,'<color>ff0000ff</color>\r\n');
              fprintf(fid,'<width>3</width>\r\n');
              fprintf(fid,'</LineStyle>\r\n');
              fprintf(fid,'</Style>\r\n');
              fprintf(fid,'<Placemark>\r\n');
              fprintf(fid,'<description><![CDATA[Line created with Matlab GEplot.m]]></description>\r\n');
              fprintf(fid,'<name>Line</name>\r\n');
              fprintf(fid,'<visibility>1</visibility>\r\n');
              fprintf(fid,'<open>1</open>\r\n');
              fprintf(fid,'<styleUrl>mystyle</styleUrl>\r\n');
              fprintf(fid,'<LineString>\r\n');
              fprintf(fid,'<extrude>0</extrude>\r\n');
              fprintf(fid,'<tessellate>0</tessellate>\r\n');
              fprintf(fid,'<altitudeMode>clampToGround</altitudeMode>\r\n');
              fprintf(fid,'<coordinates>\r\n');
%% line
                 for i=1:noSourcesdip
                      fprintf(fid,'%11.6f, %11.6f, 0\n',dipdisXgeo(i),dipdisYgeo(i));
                 end
        
              fprintf(fid,'</coordinates>\r\n');
              fprintf(fid,'</LineString>\r\n');
              fprintf(fid,'</Placemark>\r\n');
              
%%%%%%%%%%     points
              fprintf(fid,'<Folder>\r\n');
              fprintf(fid,'<name> Trial sources </name>\r\n');
              
             for i=1:noSourcesdip
              fprintf(fid,'      <Placemark>\r\n');

              fprintf(fid,'<name>%s</name>\r\n',num2str(i) );
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',dipdisXgeo(i),dipdisYgeo(i));
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');
              
             end
             
             
          if orshift == 1 
             
              fprintf(fid,'      <Placemark>\r\n');

              fprintf(fid,'<name> Old Origin </name>\r\n');
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',epilon,epilat);
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');
             
              fprintf(fid,'      <Placemark>\r\n');
              fprintf(fid,'<name> New Origin </name>\r\n');
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',newlon,newlat);
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');
             
          else

              fprintf(fid,'      <Placemark>\r\n');
              fprintf(fid,'<name>Origin</name>\r\n');
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',newlon,newlat);
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');

          end
          

fprintf(fid,'</Folder>\r\n');
fprintf(fid,'</Document>\r\n');
fprintf(fid,'</kml>\r\n');

fclose(fid);
              
 else
    disp('KML output is not selected');    
 end
%%%%%  output this run data...
             fid = fopen('sourcesinfo.txt','w');
             
             fprintf(fid,'Event Parameters\r\n') ;
             fprintf(fid,'Magnitude\r\n');
             fprintf(fid,'%4.2f\r\n', magn);
             fprintf(fid,'Date\r\n');
             fprintf(fid,'%s  \r\n', eventdate);
             fprintf(fid,'Lat\r\n');
             fprintf(fid,'%7.4f  \r\n', epilat);
             fprintf(fid,'Lon\r\n');
             fprintf(fid,'%7.4f  \r\n', epilon);
             fprintf(fid,'Depth\r\n');
             fprintf(fid,'%7.2f  \r\n', epidepth);
             fprintf(fid,'Shift to North\r\n');
             fprintf(fid,'%s   \r\n', get(handles.northkm,'String'));
             fprintf(fid,'Shift to East\r\n');
             fprintf(fid,'%s   \r\n', get(handles.eastkm,'String'));
             

             fprintf(fid,'No sources strike\r\n');
             fprintf(fid,'%s  \r\n', get(handles.noSourcesstrike,'String'));
             fprintf(fid,'Spacing along strike\r\n');
             fprintf(fid,'%s  \r\n', get(handles.distanceStep,'String'));

             fprintf(fid,'No sources dip\r\n');
             fprintf(fid,'%s  \r\n', get(handles.noSourcesdip,'String'));
             fprintf(fid,'Spacing along dip\r\n');
             fprintf(fid,'%s  \r\n', get(handles.steponPlane,'String'));

             fprintf(fid,'Strike reference\r\n');
             fprintf(fid,'%s  \r\n', get(handles.firstSourcestrike,'String'));
             fprintf(fid,'Dip reference\r\n');
             fprintf(fid,'%s  \r\n', get(handles.firstsourcedip,'String'));
             
             fprintf(fid,'Strike \r\n');
             fprintf(fid,'%s  \r\n', get(handles.Strike,'String'));
             fprintf(fid,'Dip \r\n');
             fprintf(fid,'%s  \r\n', get(handles.Dip,'String'));
             fprintf(fid,'Use rake \r\n');
             fprintf(fid,'%s  \r\n', '0');
             fprintf(fid,'rake \r\n');
             fprintf(fid,'%s  \r\n', '60');
             fclose(fid);
                          
             %%go back
             cd ..
  catch
     cd ..
  end
%             
             %%%%%%%%%%%PLOT USING M_MAP
             figure(4)
             m_proj('Mercator','long',[min(dipdisXgeo)-0.3 max(dipdisXgeo)+0.3],'lat',[min(dipdisYgeo)-0.3 max(dipdisYgeo)+0.3]);
             m_gshhs_h('color','k');
             %m_gshhs_h('patch',[.7 .7 .7],'edgecolor','g');%'color','k');
             m_grid('box','fancy','tickdir','out');

             for i=1:noSourcesdip
             m_line(dipdisXgeo(i),dipdisYgeo(i),'marker','square','markersize',5,'color','r');
             m_text(dipdisXgeo(i),dipdisYgeo(i),num2str(i),'vertical','top');
             end
            %%%plot new "epicenter"
             m_line(newlon,newlat,'marker','p','markersize',17,'color','y','MarkerFaceColor','y');

             %%%plot epicenter
             m_line(epilon,epilat,'marker','p','markersize',17,'color','b','MarkerFaceColor','b');
             
             
             
case 3       %%%%%%%%%% sources on a plane....
disp(' sources on a plane....')
strikerad=deg2rad(-strike);

sourceindex=0;


for j=1:noSourcesdip 
    for i=1:noSourcesstrike

        xytext(j,i)={num2str(i+sourceindex,'%02d')};
        
        y(j,i)=distanceStep*(i-firstSourcestrike);
        x(j,i)=(steponPlane*cos(diprad))*(j-firstSourcedip);
        z(j,i)=-x(j,i)*tan(diprad)-epidepth;
        
        [xrot(j,i),yrot(j,i)]=rotateisol(strikerad,x(j,i),y(j,i));
        
        xrot(j,i)=xrot(j,i)+Edist;
        yrot(j,i)=yrot(j,i)+Ndist;
      
    end
     sourceindex=sourceindex+i;
end

% whos x y xytext
% 
% sourceindex

figure(1)
plot3(x,y,z,'-ro')
for j=1:noSourcesdip 
  for i=1:noSourcesstrike
      text(x(j,i),y(j,i),z(j,i),xytext{j,i});
  end
end
grid on
axis square
             xlabel('East-West (km)')
             ylabel('North-South (km)')
             zlabel('Depth')
             title('X-Y-Z')
             set(gca,'Box','On')

figure(2)
plot3(xrot,yrot,z,'-ro')
for j=1:noSourcesdip 
    for i=1:noSourcesstrike
      text(xrot(j,i),yrot(j,i),z(j,i),xytext{j,i})
  end
end
grid on
axis square
             xlabel('East-West (km)')
             ylabel('North-South (km)')
             zlabel('Depth')
             title('X-Y-Z')

             set(gca,'Box','On')


             %%%%%%%%OUTPUT TO SRC FILES
             %%%%%%% and source.isl !!!!!!!!!
             fid2 = fopen('tsources.isl','w');
             fprintf(fid2,'%s\r\n','plane');

             fprintf(fid2,'%i\r\n',sourceindex);
             fprintf(fid2,'%i\r\n',noSourcesstrike);
             fprintf(fid2,'%i\r\n',distanceStep);
             fprintf(fid2,'%i\r\n',noSourcesdip);
             fprintf(fid2,'%i\r\n',steponPlane);
             
             fclose(fid2);
             
%%% start ...
try
             %%%output to files...
             %% go in GREEN
             cd green

             fileindex=0;
             
             for j=1:noSourcesdip

                 for i=1:noSourcesstrike
                       filename=['src' num2str(i+fileindex,'%02d') '.dat'];
                       fid = fopen(filename,'w');
                             fprintf(fid,'%s\r\n',' Source parameters');
                             fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
                             fprintf(fid,'%10.3f%10.3f%10.3f%10.4f  %c%s%c\r\n',yrot(j,i),xrot(j,i),-z(j,i),magn, '''', eventdate, '''');
                       fclose(fid);
                   end
                   fileindex=fileindex+i;

              end             
             
              %% go back
              cd ..

catch
        helpdlg('Error in src file creation');
    cd ..
end
             %%%%%%%%%%
             %%%%%%%%%% HERE WE HAVE TO CONVERT TO 'GEOGRAPHICAL COORDINATES'
             %%%%%%%%%% OUTPUT TO GMT AND KML FILE

             
%      try
             %% go in gmtfile
             cd gmtfiles

             fid = fopen('sour.dat','w');   % new file for XY plotting of beachballs...
             for j=1:noSourcesdip
                  for i=1:noSourcesstrike
                     fprintf(fid,'%10.4f   %10.4f  %10.4f  %s\r\n',xrot(j,i),yrot(j,i),-z(j,i),xytext{j,i});
                  end
             end
             fclose(fid);   
             

             %%%%%%%%%%%%%%%%% Geographical coordinates file....
             fid = fopen('sources.gmt','w');
%              fprintf(fid,'%s\r\n','>');

             %%%%%  !!!!!!!!!!!!!%%%%%%%%%%%%%%
             westbound=180; eastbound=0;
             southbound=90; northbound=-90;

             
             orig_y=yrot(firstSourcedip,firstSourcestrike);
             orig_x=xrot(firstSourcedip,firstSourcestrike);

             for j=1:noSourcesdip
                  for i=1:noSourcesstrike
                               
                      eastkm(j,i)= xrot(j,i)-orig_x;
                      northkm(j,i)=yrot(j,i)-orig_y;
                      
                      [dist(j,i),theta(j,i)]=az(eastkm(j,i),northkm(j,i));
                   %   [outpointsYrot(j,i),outpointsXrot(j,i),derr(j,i),aerr(j,i)] = vdistinv(newlat,newlon,dist(j,i)*1000,theta(j,i))
                       [outpointsYrot(j,i),outpointsXrot(j,i),~] = wgs84invdist(newlat,newlon,theta(j,i),dist(j,i)*1000,1,1);
                       outpointsZrot(j,i)=-z(j,i);
                     
                       outpointsXrot(firstSourcedip,firstSourcestrike)=newlon;
                       outpointsYrot(firstSourcedip,firstSourcestrike)=newlat;
                       
                       
                   fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f %s %s\r\n',outpointsXrot(j,i),outpointsYrot(j,i),'0.2',outpointsZrot(j,i),xytext{j,i},'d');
                   
                     if outpointsXrot(j,i) <= westbound
                         westbound = outpointsXrot(j,i);
                     end
                     if outpointsXrot(j,i) >= eastbound
                         eastbound = outpointsXrot(j,i);
                     end
                     if outpointsYrot(j,i) <= southbound
                         southbound = outpointsYrot(j,i);
                     end
                     if outpointsYrot(j,i) >= northbound
                         northbound = outpointsYrot(j,i);
                     end
                     
                  end
             end

             fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f  %s %s\r\n',newlon,newlat,'0.8',epidepth,'New_ref','a');
             fprintf(fid,'  %5.10f   %5.10f   %s %5.10f  %s %s\r\n',epilon,epilat,'0.4',epidepth,'Old_ref','a');
             
             fclose(fid);   
             
             %%%%%%%%%%%%%%%%%%%%%%%%make plot batch file
             %%%find map limits...
              border=0.1;
                  wend=min(min(outpointsXrot));
                  eend=max(max(outpointsXrot));
                  send=min(min(outpointsYrot));
                  nend=max(max(outpointsYrot));
                    w=(wend-border);
                    e=(eend+border);
                    s=(send-border);
                    n=(nend+border);
               r=['-R' num2str(w,'%7.5f') '/' num2str(e,'%7.5f') '/' num2str(s,'%7.5f') '/' num2str(n,'%7.5f') ' '];
               j=[' -JM14c'];

            
             fid = fopen('psources.bat','w');
                   fprintf(fid,'%s\r\n','gmtset PAPER_MEDIA A4');
                   fprintf(fid,'%s\r\n','gmtset PLOT_DEGREE_FORMAT D');
                   fprintf(fid,'%s\r\n',['pscoast ' r   j ' -G255/255/204 -Df -W0.7p  -B0.1 -K -S104/204/255   > sources.ps' ]);
                   fprintf(fid,'%s\r\n','psxy -R -J -O  -K      sources.gmt   -S  -G255/0/0    -W1.p -V >> sources.ps ');
                   fprintf(fid,'%s\r\n','gawk "{print $1,$2,"14","1","1","1",$5}" sources.gmt > textsou.txt');
                   fprintf(fid,'%s\r\n','pstext -R -J -O   textsou.txt  -V >> sources.ps ');
                       
             fclose(fid); 
             
  if (get(handles.kmlout,'Value') == get(handles.kmlout,'Max')) 
             
%             %%%% try to prepare a KML file for Google Earth ..!!
              fid = fopen('sources.kml','w');
              
              fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\r\n');
              fprintf(fid,'<kml xmlns="http://earth.google.com/kml/2.1">\r\n');
              fprintf(fid,'<Document>\r\n');
              fprintf(fid,'<name> Trial sources </name>\r\n');
              fprintf(fid,'<description> Isola-GUI trial sources for Google Earth </description>\r\n');
              
              fprintf(fid,'<Style id="mystyle">\r\n');
              fprintf(fid,'<IconStyle>\r\n');
              fprintf(fid,'<scale>0.50</scale>\r\n');
              fprintf(fid,'<Icon><href>GEimages/circle_r.png</href></Icon>\r\n');
              fprintf(fid,'</IconStyle>\r\n');
              fprintf(fid,'<LineStyle>\r\n');
              fprintf(fid,'<color>ff0000ff</color>\r\n');
              fprintf(fid,'<width>3</width>\r\n');
              fprintf(fid,'</LineStyle>\r\n');
              fprintf(fid,'</Style>\r\n');
              fprintf(fid,'<Placemark>\r\n');
              fprintf(fid,'<description><![CDATA[Line created with Matlab GEplot.m]]></description>\r\n');
              fprintf(fid,'<name>Plane of Sources</name>\r\n');
              fprintf(fid,'<visibility>1</visibility>\r\n');
              fprintf(fid,'<open>1</open>\r\n');
              fprintf(fid,'<styleUrl>mystyle</styleUrl>\r\n');

              fprintf(fid,'</Placemark>\r\n');
              
%%%%%%%%%%     points
              fprintf(fid,'<Folder>\r\n');
              fprintf(fid,'<name> Trial sources </name>\r\n');
              
             for j=1:noSourcesdip
                 for i=1:noSourcesstrike
              fprintf(fid,'      <Placemark>\r\n');

              fprintf(fid,'<name>%s</name>\r\n',xytext{j,i} );
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',outpointsXrot(j,i),outpointsYrot(j,i));
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');
              
                end

             end
             

              fprintf(fid,'      <Placemark>\r\n');

              fprintf(fid,'<name>Origin</name>\r\n');
              fprintf(fid,'<styleUrl>#mystyle</styleUrl>\r\n');

              fprintf(fid,'         <Point>\r\n');
              fprintf(fid,'           <coordinates>\r\n');
              fprintf(fid,'%11.6f, %11.6f, 0\r\n',newlon,newlat);
              fprintf(fid,'           </coordinates>\r\n');
              fprintf(fid,'         </Point>\r\n');
              fprintf(fid,'      </Placemark>\r\n');

fprintf(fid,'</Folder>\r\n');
fprintf(fid,'</Document>\r\n');
fprintf(fid,'</kml>\r\n');

fclose(fid);
%              
  else
      disp('KML output is not selected');  
  end
%%%%%  output this run data...
             fid = fopen('sourcesinfo.txt','w');
             
             fprintf(fid,'Event Parameters\r\n') ;
             fprintf(fid,'Magnitude\r\n') 
             fprintf(fid,'%4.2f\r\n', magn);
             fprintf(fid,'Date\r\n');
             fprintf(fid,'%s  \r\n', eventdate);
             fprintf(fid,'Lat\r\n');
             fprintf(fid,'%7.4f  \r\n', epilat);
             fprintf(fid,'Lon\r\n');
             fprintf(fid,'%7.4f  \r\n', epilon);
             fprintf(fid,'Depth\r\n');
             fprintf(fid,'%7.2f  \r\n', epidepth);
             fprintf(fid,'Shift to North\r\n');
             fprintf(fid,'%s   \r\n', get(handles.northkm,'String'));
             fprintf(fid,'Shift to East\r\n');
             fprintf(fid,'%s   \r\n', get(handles.eastkm,'String'));
             

             fprintf(fid,'No sources strike\r\n');
             fprintf(fid,'%s  \r\n', get(handles.noSourcesstrike,'String'));
             fprintf(fid,'Spacing along strike\r\n');
             fprintf(fid,'%s  \r\n', get(handles.distanceStep,'String'));

             fprintf(fid,'No sources dip\r\n');
             fprintf(fid,'%s  \r\n', get(handles.noSourcesdip,'String'));
             fprintf(fid,'Spacing along dip\r\n');
             fprintf(fid,'%s  \r\n', get(handles.steponPlane,'String'));

             fprintf(fid,'Strike reference\r\n');
             fprintf(fid,'%s  \r\n', get(handles.firstSourcestrike,'String'));
             fprintf(fid,'Dip reference\r\n');
             fprintf(fid,'%s  \r\n', get(handles.firstsourcedip,'String'));
             
             fprintf(fid,'Strike \r\n');
             fprintf(fid,'%s  \r\n', get(handles.Strike,'String'));
             fprintf(fid,'Dip \r\n');
             fprintf(fid,'%s  \r\n', get(handles.Dip,'String'));
             fprintf(fid,'Use rake \r\n');
             fprintf(fid,'%s  \r\n', '0');
             fprintf(fid,'rake \r\n');
             fprintf(fid,'%s  \r\n', '60');
             fclose(fid);
                          
             %%go back
             cd ..
%          catch
%              cd ..
%          end
             %%%%%%%%%%%PLOT USING M_MAP
%              westbound;
%              eastbound;
%              southbound;
%              northbound;
             
             figure(3)
            % m_proj('Mercator','long',[westbound-0.1 eastbound+0.1],'lat',[southbound-0.1 northbound+0.1]);
             m_proj('Mercator','long',[w e],'lat',[s n]) 
             
             m_gshhs_h('color','k');
             %m_gshhs_h('patch',[.7 .7 .7],'edgecolor','g');%'color','k');
             m_grid('box','fancy','tickdir','out');

            %%%plot new "epicenter"
             m_line(newlon,newlat,'marker','p','markersize',17,'color','y','MarkerFaceColor','y');

             %%%plot epicenter
             m_line(epilon,epilat,'marker','p','markersize',17,'color','b','MarkerFaceColor','b');

             for j=1:noSourcesdip
                for i=1:noSourcesstrike
                    m_line(outpointsXrot(j,i),outpointsYrot(j,i),'marker','square','markersize',5,'color','r');
                    m_text(outpointsXrot(j,i),outpointsYrot(j,i),xytext{j,i},'vertical','top');
                end
             end

             
%% inclined line !! new 20/12/2018             
            
case 4             
disp('Calculating sources along line on a plane')              

% read values from GUI
norakesources    = str2double(get(handles.norakesources,'String'));
rakespacing      = str2double(get(handles.rakespacing,'String'));
rakerefsource    = str2double(get(handles.rakerefsource,'String'));

% call subroutine 
[ux,uy,uz,strdis] = calclcoord(strike,dip,rake,norakesources,rakespacing,rakerefsource); %,epidepth); 
uz=uz+epidepth ;


%%
for jj=1:norakesources
 xytext(jj)={num2str(jj,'%02d')};
end
% ux ----> NS, positive North
% uy ----> EW, positive East
% figure
% plot3(-uy,ux,uz,'bo-')
%% plot
figure
% plot the system of coordinates
%Xs1=[0  0   0   0  0  10   10    0]; Ys1=[0 10  10   0  0   0    0    0]; Zs1=[0  0 -10 -10  0   0  -10  -10];
%Xs2=[  0  -10  -10  0   0       0  0]; Ys2=[  0    0    0  0   -10   -10  0]; Zs2=[-10  -10    0  0   0     -10  -10];

hold on
%plot3(Ys1,Xs1,Zs1,'k--'); plot3(Ys2,Xs2,Zs2,'k--')
plot3(uy,ux,uz,'bo-')

% plot the reference source
plot3(uy(rakerefsource),ux(rakerefsource),uz(rakerefsource),'r*')
% 
for j=1:norakesources
      text(uy(j),ux(j),uz(j),xytext{j});
end

% % % % check with plane
% strikerad=deg2rad(-strike);
% 
% sourceindex=0;
% 
% for j=1:5
%     for i=1:5
% 
%         xytext(j,i)={num2str(i+sourceindex,'%02d')};
%         
%         y(j,i)=5*(i-1);
%         x(j,i)=(5*cos(diprad))*(j-1);
%         z(j,i)=-x(j,i)*tan(diprad)-epidepth;
%         
%         [xrot(j,i),yrot(j,i)]=rotateisol(strikerad,x(j,i),y(j,i));
%         
%         xrot(j,i)=xrot(j,i)+Edist;
%         yrot(j,i)=yrot(j,i)+Ndist;
%       
%     end
%      sourceindex=sourceindex+i;
% end
% 
% plot3(xrot,yrot,-z,'-ro','Markerfacecolor',[.17 .17 .17])

xlabel('Y (km)');ylabel('X (km)');zlabel('Z (km)');title('X-Y-Z');grid on
hold off;rotate3d on;axis square
set(gca, 'ZDir','reverse')

%% OUTPUT TO SRC FILES
% and source.isl !!!!!!!!!
             fid2 = fopen('tsources.isl','w');
              fprintf(fid2,'%s\r\n','line');
              fprintf(fid2,'%i\r\n',norakesources);
              fprintf(fid2,'%f\r\n',rakespacing);
              fprintf(fid2,'%f\r\n',rakerefsource);
             fclose(fid2);
             
         %% go in GREEN
           cd green
             for i=1:norakesources
             %%% find filename
             filename=['src' num2str(i,'%02d') '.dat'];
             %%%% open file
             fid = fopen(filename,'w');
             fprintf(fid,'%s\r\n',' Source parameters');
             fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
             fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\r\n',ux(i),uy(i),uz(i),magn, '''', eventdate, '''');
             fclose(fid);
             end
           cd ..
             
%%
             %%%%%%%%%%%%%%%%%HERE WE HAVE TO CONVERT TO 'GEOGRAPHICAL COORDINATES'
             %%%%%           Use vdistinv subroutine from Matlab user files...!!
             %%%%            output should be in WGS84..
             %%%             read  "epicenter"..
          
             
     %% go in gmtfile
     cd gmtfiles
             
             %%%%%  !!!!!!!!!!!!!%%%%%%%%%%%%%%
             westbound=180;eastbound=0;southbound=90;northbound=-90;

             fid = fopen('sources.gmt','w');             
             orig_y=ux(rakerefsource);
             orig_x=uy(rakerefsource);

             for i=1:norakesources
                               
                      eastkm(i)= uy(i)-orig_x;
                      northkm(i)=ux(i)-orig_y;
                      
                      [dist(i),theta(i)]=az(eastkm(i),northkm(i));

                         
                      [outpointsYrot(i),outpointsXrot(i)] = vdistinv(newlat,newlon,dist(i)*1000,theta(i));
                      
                       outpointsZrot(i)=uz(i);
                     
                       outpointsXrot(rakerefsource)=newlon;
                       outpointsYrot(rakerefsource)=newlat;
                       
                   fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f %s %s\r\n',outpointsXrot(i),outpointsYrot(i),'0.2',outpointsZrot(i),xytext{i},'d');

                     if outpointsXrot(i) <= westbound
                         westbound = outpointsXrot(i);
                     end
                     if outpointsXrot(i) >= eastbound
                         eastbound = outpointsXrot(i);
                     end
                     if outpointsYrot(i) <= southbound
                         southbound = outpointsYrot(i);
                     end
                     if outpointsYrot(i) >= northbound
                         northbound = outpointsYrot(i);
                     end
                     

              end
             
             
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             %%%%%%%%%%OUTPUT TO GMT FILE
        

                fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f  %s %s\r\n',newlon,newlat,'0.8',epidepth,'New_ref','a');
                fprintf(fid,'  %5.10f   %5.10f   %s %5.10f  %s %s\r\n',epilon,epilat,'0.4',epidepth,'Old_ref','a');
             fclose(fid);   
             
             %% sour.dat
             fid = fopen('sour.dat','w');   % XY file ...
                  for i=1:norakesources
                     fprintf(fid,'%10.4f   %10.4f  %10.4f  %s\r\n',uy(i),ux(i),uz(i), num2str(i));
                  end
             fclose(fid);
             %%             
             % make plot batch file
             %%%find map limits...
              border=0.1;
                  wend=min(min(outpointsXrot));
                  eend=max(max(outpointsXrot));
                  send=min(min(outpointsYrot));
                  nend=max(max(outpointsYrot));
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

             figure(3)
            % m_proj('Mercator','long',[westbound-0.1 eastbound+0.1],'lat',[southbound-0.1 northbound+0.1]);
             m_proj('Mercator','long',[w e],'lat',[s n]) 
             m_gshhs_h('color','k');
             %m_gshhs_h('patch',[.7 .7 .7],'edgecolor','g');%'color','k');
             m_grid('box','fancy','tickdir','out');
            %%%plot new "epicenter"
             m_line(newlon,newlat,'marker','p','markersize',17,'color','y','MarkerFaceColor','y');
             %%%plot epicenter
             m_line(epilon,epilat,'marker','p','markersize',17,'color','b','MarkerFaceColor','b');

             for i=1:norakesources
                    m_line(outpointsXrot(i),outpointsYrot(i),'marker','square','markersize',5,'color','r');
%                    m_text(outpointsXrot(j,i),outpointsYrot(j,i),xytext{j,i},'vertical','top');
             end
             
             
%%  output this run data...
             fid = fopen('sourcesinfo.txt','w');
             
             fprintf(fid,'Event Parameters\r\n') ;
             fprintf(fid,'Magnitude\r\n') 
             fprintf(fid,'%4.2f\r\n', magn);
             fprintf(fid,'Date\r\n');
             fprintf(fid,'%s  \r\n', eventdate);
             fprintf(fid,'Lat\r\n');
             fprintf(fid,'%7.4f  \r\n', epilat);
             fprintf(fid,'Lon\r\n');
             fprintf(fid,'%7.4f  \r\n', epilon);
             fprintf(fid,'Depth\r\n');
             fprintf(fid,'%7.2f  \r\n', epidepth);
             fprintf(fid,'Shift to North\r\n');
             fprintf(fid,'%s   \r\n', get(handles.northkm,'String'));
             fprintf(fid,'Shift to East\r\n');
             fprintf(fid,'%s   \r\n', get(handles.eastkm,'String'));
             

             fprintf(fid,'No sources strike\r\n');
             fprintf(fid,'%s  \r\n', get(handles.noSourcesstrike,'String'));
             fprintf(fid,'Spacing along strike\r\n');
             fprintf(fid,'%s  \r\n', get(handles.distanceStep,'String'));

             fprintf(fid,'No sources dip\r\n');
             fprintf(fid,'%s  \r\n', get(handles.noSourcesdip,'String'));
             fprintf(fid,'Spacing along dip\r\n');
             fprintf(fid,'%s  \r\n', get(handles.steponPlane,'String'));

             fprintf(fid,'Strike reference\r\n');
             fprintf(fid,'%s  \r\n', get(handles.firstSourcestrike,'String'));
             fprintf(fid,'Dip reference\r\n');
             fprintf(fid,'%s  \r\n', get(handles.firstsourcedip,'String'));
             
             fprintf(fid,'Strike \r\n');
             fprintf(fid,'%s  \r\n', get(handles.Strike,'String'));
             fprintf(fid,'Dip \r\n');
             fprintf(fid,'%s  \r\n', get(handles.Dip,'String'));
             fprintf(fid,'Use rake \r\n');
             fprintf(fid,'%s  \r\n', '1');
             fprintf(fid,'Rake \r\n');
             fprintf(fid,'%s  \r\n', get(handles.rake,'String'));
             fprintf(fid,'No sources Rake \r\n');
             fprintf(fid,'%s  \r\n', get(handles.norakesources,'String'));
             fprintf(fid,'Spacing along Rake \r\n');
             fprintf(fid,'%s  \r\n', get(handles.rakespacing,'String'));
             fprintf(fid,'Rake Reference\r\n');
             fprintf(fid,'%s  \r\n', get(handles.rakerefsource,'String'));
             
            
             fclose(fid);
                          
             %%go back
             
             
   
     cd ..

            
end  %%%case end




% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


close


% --- Executes on button press in savefile.
function savefile_Callback(hObject, eventdata, handles)
% hObject    handle to savefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in readfromfile.
function readfromfile_Callback(hObject, eventdata, handles)
% hObject    handle to readfromfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function noSourcesstrike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noSourcesstrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function noSourcesstrike_Callback(hObject, eventdata, handles)
% hObject    handle to noSourcesstrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noSourcesstrike as text
%        str2double(get(hObject,'String')) returns contents of noSourcesstrike as a double

nsources = str2double(get(handles.noSourcesstrike,'String'));
spacing = str2double(get(handles.distanceStep,'String'));

set(handles.flength,'string',num2str((nsources*spacing)-spacing));

%find number of sources and check if < 99...
nsdip = str2double(get(handles.noSourcesdip,'String'));

if nsdip == 0
    tsources=nsources;
else
    tsources=nsources*nsdip;
end

if tsources <= 99
      set(handles.tsources,'string',num2str(tsources),...
                                  'ForegroundColor','black');
      set(handles.text38,'String','')
      set(handles.text39,'String','')
                             
elseif tsources >  99
      set(handles.tsources,'string',num2str(tsources),...
                                  'ForegroundColor','red');
      set(handles.text38,'String','Maximum number of sources is 99')
      set(handles.text39,'String',' use less sources')
      
end

% --- Executes during object creation, after setting all properties.
function steponPlane_CreateFcn(hObject, eventdata, handles)
% hObject    handle to steponPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function steponPlane_Callback(hObject, eventdata, handles)
% hObject    handle to steponPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of steponPlane as text
%        str2double(get(hObject,'String')) returns contents of steponPlane as a double

nsources = str2double(get(handles.noSourcesdip,'String'));
spacing = str2double(get(handles.steponPlane,'String'));

set(handles.fwidth,'string',num2str((nsources*spacing)-spacing));


% --- Executes during object creation, after setting all properties.
function firstsourcedip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstsourcedip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function firstsourcedip_Callback(hObject, eventdata, handles)
% hObject    handle to firstsourcedip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstsourcedip as text
%        str2double(get(hObject,'String')) returns contents of firstsourcedip as a double


% --- Executes during object creation, after setting all properties.
function distanceStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distanceStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function distanceStep_Callback(hObject, eventdata, handles)
% hObject    handle to distanceStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of distanceStep as text
%        str2double(get(hObject,'String')) returns contents of distanceStep as a double

nsources = str2double(get(handles.noSourcesstrike,'String'));
spacing = str2double(get(handles.distanceStep,'String'));

set(handles.flength,'string',num2str((nsources*spacing)-spacing));




% --- Executes during object creation, after setting all properties.
function depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function depth_Callback(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth as text
%        str2double(get(hObject,'String')) returns contents of depth as a double


% --- Executes during object creation, after setting all properties.
function Strike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Strike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Strike_Callback(hObject, eventdata, handles)
% hObject    handle to Strike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Strike as text
%        str2double(get(hObject,'String')) returns contents of Strike as a double


% --- Executes during object creation, after setting all properties.
function dip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dip_Callback(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip as text
%        str2double(get(hObject,'String')) returns contents of dip as a double


% --- Executes during object creation, after setting all properties.
function firstsource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstsourcestrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function firstsource_Callback(hObject, eventdata, handles)
% hObject    handle to firstsourcestrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstsourcestrike as text
%        str2double(get(hObject,'String')) returns contents of firstsourcestrike as a double


% --- Executes during object creation, after setting all properties.
function firstSourcestrike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstSourcestrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function firstSourcestrike_Callback(hObject, eventdata, handles)
% hObject    handle to firstSourcestrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstSourcestrike as text
%        str2double(get(hObject,'String')) returns contents of firstSourcestrike as a double


% --- Executes during object creation, after setting all properties.
function Dip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function Dip_Callback(hObject, eventdata, handles)
% hObject    handle to Dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dip as text
%        str2double(get(hObject,'String')) returns contents of Dip as a double


% --- Executes during object creation, after setting all properties.
function noSourcesdip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noSourcesdip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function noSourcesdip_Callback(hObject, eventdata, handles)
% hObject    handle to noSourcesdip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noSourcesdip as text
%        str2double(get(hObject,'String')) returns contents of noSourcesdip as a double
nsources = str2double(get(handles.noSourcesdip,'String'));
spacing = str2double(get(handles.steponPlane,'String'));
set(handles.fwidth,'string',num2str((nsources*spacing)-spacing));

%find number of sources and check if < 99...
nsstrike = str2double(get(handles.noSourcesstrike,'String'));

if nsstrike == 0
    tsources=nsources;
else
    tsources=nsources*nsstrike;
end

if tsources <= 99
      set(handles.tsources,'string',num2str(tsources),...
                                  'ForegroundColor','black');
      set(handles.text38,'String','')
      set(handles.text39,'String','')
                             
elseif tsources >  99
      set(handles.tsources,'string',num2str(tsources),...
                                  'ForegroundColor','red');
      set(handles.text38,'String','Maximum number of sources is 99')
      set(handles.text39,'String',' use less sources')
      
end


% --- Executes on button press in oneplane.
function oneplane_Callback(hObject, eventdata, handles)
% hObject    handle to oneplane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of oneplane

set(handles.onelinestrike, 'Value', 0);
set(handles.onelinedip, 'Value', 0);
set(handles.oneplane, 'Value', 1);


% --- Executes during object creation, after setting all properties.
function outputselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes during object creation, after setting all properties.
function outmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in outmenu.
function outmenu_Callback(hObject, eventdata, handles)
% hObject    handle to outmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns outmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from outmenu

val = get(handles.outmenu,'Value');
switch val
case 1
    disp('one line')
case 2
    disp('dip')
case 3
    disp('plane')
end


% --- Executes during object creation, after setting all properties.
function magn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function magn_Callback(hObject, eventdata, handles)
% hObject    handle to magn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of magn as text
%        str2double(get(hObject,'String')) returns contents of magn as a double


% --- Executes during object creation, after setting all properties.
function eventdate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function eventdate_Callback(hObject, eventdata, handles)
% hObject    handle to eventdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eventdate as text
%        str2double(get(hObject,'String')) returns contents of eventdate as a double


% --- Executes on button press in selfile.
function selfile_Callback(hObject, eventdata, handles)
% hObject    handle to selfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get file information from user
[stationfile, newdir] = uigetfile('*.dat', 'Select seismic station file');

set(handles.stationfilename,'String',...
[newdir stationfile] );

%print file name
stationfile
%read data in 3 arrays
fid  = fopen([newdir, stationfile],'r');
[staname,stalat,stalon] = textread([newdir, stationfile],'%s %f %f',-1);
fclose(fid)

%save to handles
handles.staname=staname;
handles.stalat=stalat;
handles.stalon=stalon;
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function stationfilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stationfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function stationfilename_Callback(hObject, eventdata, handles)
% hObject    handle to stationfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stationfilename as text
%        str2double(get(hObject,'String')) returns contents of stationfilename as a double


% --- Executes on button press in Mapit.
function Mapit_Callback(hObject, eventdata, handles)
% hObject    handle to Mapit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%READ station data from Handles
staname=handles.staname;
stalat=handles.stalat;
stalon=handles.stalon;

min(stalat)
max(stalat)

min(stalon)
max(stalon)
figure(2)
m_proj('Mercator','long',[min(stalon)-0.3 max(stalon)+0.3],'lat',[min(stalat)-0.3 max(stalat)+0.3]);
m_gshhs_i('color','k');
%m_gshhs_h('patch',[.7 .7 .7],'edgecolor','g');%'color','k');
m_grid('box','fancy','tickdir','out');

for i=1:length(stalat)
m_line(stalon(i),stalat(i),'marker','square','markersize',5,'color','r');
m_text(stalon(i),stalat(i),staname(i),'vertical','top');
end



% --- Executes during object creation, after setting all properties.
function northkm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to northkm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function northkm_Callback(hObject, eventdata, handles)
% hObject    handle to northkm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of northkm as text
%        str2double(get(hObject,'String')) returns contents of northkm as a double


% --- Executes during object creation, after setting all properties.
function eastkm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eastkm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function eastkm_Callback(hObject, eventdata, handles)
% hObject    handle to eastkm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eastkm as text
%        str2double(get(hObject,'String')) returns contents of eastkm as a double




function [lat2,lon2,derr,aerr]=vdistinv(lat1,lon1,dist,azim)
% VDISTINV - Invert VDIST function using numerical inversion
%
% Usage:
%
% [lat2,lon2] = vdistinv(lat1,lon1,dist,azim)
% [lat2,lon2,derr,aerr] = vdistinv(lat1,lon1,dist,azim)
%
% Variables:
%
% lat1, lon1 = coordinates of intial point in degrees
% dist       = geodesic distance in meters
% azim       = geodesic azimuth in degrees clockwise from north
% lat2,lon2  = destination coordinates in degrees
% derr       = optional output: error between input distance and the
%              calculated length of the path to the computed endpoint
%              (as computed by VDIST)
% aerr       = optional output: error between the provided azimuth and the
%              calculated azimuth (as computed by VDIST)
%
% Notes: (1) This "quick and dirty" approach was written in response to
%            a user request. The use of a numerical optimization to invert
%            VDIST is a relatively slow and crude approach. (It would be
%            better to implement an algorithm written specifically for that
%            purpose by Vincenty or others.)
%        (2) The distance between essentially antipodal points on an
%            ellipsoid is very sensitive to small deviations in azimuth,
%            so such points should be avoided. (A warning is given.)
%        (3) For other cases, precision is set to about one part in 10^12
%        (3) Tested but no warranty; use at your own risk.
%        (4) Written by Michael Kleder, April 2006
%
% Example:
% >> [dist,azim]=vdist(10,20,30,40)
% dist =    3035728.95690893
% azim =    40.3196402221127
% >> [lat2,lon2]=vdistinv(10,20,dist,azim)
% lat2 =    29.9999999999981
% lon2 =    39.9999999999979
% >>

% initial guess for path endpoint is computed using spherical earth trig:
t1=lat1*0.0174532925199433; % degrees to radians
n1=lon1*0.0174532925199433; % degrees to radians
a=azim*0.0174532925199433; % degrees to radians
d=dist*1.56961230576048e-007; % meters to radians
lat2 = asin(sin(t1)*cos(d)+cos(t1)*sin(d)*cos(a));
lon2 = n1+atan2(sin(d)*sin(a),cos(t1)*cos(d)-sin(t1)*sin(d)*cos(a));
X=[lat2;lon2]*57.2957795130823; % radians to dgrees
% other parameters (start point, arc length, and azimuth) are fixed:
params=[lat1;lon1;dist;azim];
% optimization control settings:
opt=optimset('MaxFunEvals',5000,'TolFun',1e-12);
% solve for accurate end point:
X=fminsearch(@tryone,X,opt,params);
% recover coordinates of endpoint:
lat2=X(1);
lon2=X(2);
if nargout > 2 % if error data is requested
    % compute distance and azimuth from startpoint to endpoint
    [d,a] = vdist(lat1,lon1,lat2,lon2);
    % error in distance:
    derr=abs(dist-d);
    % error in azimuth:
    azim = mod(azim,360);
    a = mod(a,360);
    aerr = abs(azim-a);
    aerr = min(aerr,abs(360-aerr));
end
return
function err=tryone(X,params)
lat2=X(1);
lon2=X(2);
lat1=params(1);
lon1=params(2);
dist=params(3);
azim=params(4);
% crude catch for out-of-bounds attempts:
if lat1<-90 || lat1 > 90 || lat2 < -90 || lat2 > 90
    err = 1e6;
    return
end
[trydist,tryazim]=vdist(lat1,lon1,lat2,lon2);
% compute overall error. First convert distance to approximate arc length
% in degrees so as to weight the terms reasonably closely. (Both move to
% zero in the optimization, but reasonably balancing the units can help.)
err = sqrt((9e-6*(dist-trydist))^2 + (azim-tryazim)^2);
return

function varargout = vdist(lat1,lon1,lat2,lon2)
% VDIST - Using the WGS-84 Earth ellipsoid, compute the distance between
%         two points within a few millimeters of accuracy, compute forward
%         azimuth, and compute backward azimuth, all using a vectorized
%         version of Vincenty's algorithm.
%
% s = vdist(lat1,lon1,lat2,lon2)
% [s,a12] = vdist(lat1,lon1,lat2,lon2)
% [s,a12,a21] = vdist(lat1,lon1,lat2,lon2)
%
% s = distance in meters (inputs may be scalars, vectors, or matrices)
% a12 = azimuth in degrees from first point to second point (forward)
% a21 = azimuth in degrees from second point to first point (backward)
%       (Azimuths are in degrees clockwise from north.)
% lat1 = GEODETIC latitude of first point (degrees)
% lon1 = longitude of first point (degrees)
% lat2, lon2 = second point (degrees)
%
%  Original algorithm source:
%  T. Vincenty, "Direct and Inverse Solutions of Geodesics on the Ellipsoid
%  with Application of Nested Equations", Survey Review, vol. 23, no. 176,
%  April 1975, pp 88-93.
%  Available at: http://www.ngs.noaa.gov/PUBS_LIB/inverse.pdf
%
% Notes: (1) lat1,lon1,lat2,lon2 can be any (identical) size/shape. Outputs
%            will have the same size and shape.
%        (2) Error correcting code, convergence failure traps, antipodal
%            corrections, polar error corrections, WGS84 ellipsoid
%            parameters, testing, and comments: Michael Kleder, 2004.
%        (3) Azimuth implementation (including quadrant abiguity
%            resolution) and code vectorization, Michael Kleder, Sep 2005.
%        (4) Vectorization is convergence sensitive; that is, quantities
%            which have already converged to within tolerance are not
%            recomputed during subsequent iterations (while other
%            quantities are still converging).
%        (5) Vincenty describes his distance algorithm as precise to within
%            0.01 millimeters, subject to the ellipsoidal model.
%        (6) For distance calculations, essentially antipodal points are
%            treated as exactly antipodal, potentially reducing accuracy
%            slightly.
%        (7) Distance failures for points exactly at the poles are
%            eliminated by moving the points by 0.6 millimeters.
%        (8) The Vincenty distance algorithm was transcribed verbatim by
%            Peter Cederholm, August 12, 2003. It was modified and
%            translated to English by Michael Kleder.
%            Mr. Cederholm's website is http://www.plan.aau.dk/~pce/
%        (9) Distances agree with the Mapping Toolbox, version 2.2 (R14SP3)
%            with a max relative difference of about 5e-9, except when the
%            two points are nearly antipodal, and except when one point is
%            near the equator and the two longitudes are nearly 180 degrees
%            apart. This function (vdist) is more accurate in such cases.
%            For example, note this difference (as of this writing):
%            >>vdist(0.2,305,15,125)
%            18322827.0131551
%            >>distance(0.2,305,15,125,[6378137 0.08181919])
%            0
%       (10) Azimuths FROM the north pole (either forward starting at the
%            north pole or backward when ending at the north pole) are set
%            to 180 degrees by convention. Azimuths FROM the south pole are
%            set to 0 degrees by convention.
%       (11) Azimuths agree with the Mapping Toolbox, version 2.2 (R14SP3)
%            to within about a hundred-thousandth of a degree, except when
%            traversing to or from a pole, where the convention for this
%            function is described in (10), and except in the cases noted
%            above in (9).
%       (12) No warranties; use at your own risk.

% reshape inputs
keepsize = size(lat1);
lat1=lat1(:);
lon1=lon1(:);
lat2=lat2(:);
lon2=lon2(:);
% Input check:
if any(abs(lat1)>90 | abs(lat2)>90)
    error('Input latitudes must be between -90 and 90 degrees, inclusive.')
end
% Supply WGS84 earth ellipsoid axis lengths in meters:
a = 6378137; % definitionally
b = 6356752.31424518; % computed from WGS84 earth flattening coefficient
% preserve true input latitudes:
lat1tr = lat1;
lat2tr = lat2;
% convert inputs in degrees to radians:
lat1 = lat1 * 0.0174532925199433;
lon1 = lon1 * 0.0174532925199433;
lat2 = lat2 * 0.0174532925199433;
lon2 = lon2 * 0.0174532925199433;
% correct for errors at exact poles by adjusting 0.6 millimeters:
kidx = abs(pi/2-abs(lat1)) < 1e-10;
if any(kidx);
    lat1(kidx) = sign(lat1(kidx))*(pi/2-(1e-10));
end
kidx = abs(pi/2-abs(lat2)) < 1e-10;
if any(kidx)
    lat2(kidx) = sign(lat2(kidx))*(pi/2-(1e-10));
end
f = (a-b)/a;
U1 = atan((1-f)*tan(lat1));
U2 = atan((1-f)*tan(lat2));
lon1 = mod(lon1,2*pi);
lon2 = mod(lon2,2*pi);
L = abs(lon2-lon1);
kidx = L > pi;
if any(kidx)
    L(kidx) = 2*pi - L(kidx);
end
lambda = L;
lambdaold = 0*lat1;
itercount = 0;
notdone = logical(1+0*lat1);
alpha = 0*lat1;
sigma = 0*lat1;
sinsigma=nan*lat1;
cossigma=nan*lat1;
cos2sigmam = 0*lat1;
C = 0*lat1;
warninggiven = false;
while any(notdone)  % force at least one execution
    %disp(['lambda(21752) = ' num2str(lambda(21752),20)]);
    itercount = itercount+1;
    if itercount > 50
        if ~warninggiven
            warning('VDIST:antipodal',['Essentially antipodal points ' ...
                'encountered. Precision may be reduced.']);
        end
        lambda(notdone) = pi;
        break
    end
    lambdaold(notdone) = lambda(notdone);
    sinsigma(notdone) = sqrt((cos(U2(notdone)).*sin(lambda(notdone)))...
        .^2+(cos(U1(notdone)).*sin(U2(notdone))-sin(U1(notdone)).*...
        cos(U2(notdone)).*cos(lambda(notdone))).^2);
    cossigma(notdone) = sin(U1(notdone)).*sin(U2(notdone))+...
        cos(U1(notdone)).*cos(U2(notdone)).*cos(lambda(notdone));
    % eliminate rare imaginary portions at limit of numerical precision:
    sinsigma(notdone)=real(sinsigma(notdone));
    cossigma(notdone)=real(cossigma(notdone));
    sigma(notdone) = atan2(sinsigma(notdone),cossigma(notdone));
    alpha(notdone) = asin(cos(U1(notdone)).*cos(U2(notdone)).*...
        sin(lambda(notdone))./sin(sigma(notdone)));
    cos2sigmam(notdone) = cos(sigma(notdone))-2*sin(U1(notdone)).*...
        sin(U2(notdone))./cos(alpha(notdone)).^2;
    C(notdone) = f/16*cos(alpha(notdone)).^2.*(4+f*(4-3*...
        cos(alpha(notdone)).^2));
    lambda(notdone) = L(notdone)+(1-C(notdone)).*f.*sin(alpha(notdone))...
        .*(sigma(notdone)+C(notdone).*sin(sigma(notdone)).*...
        (cos2sigmam(notdone)+C(notdone).*cos(sigma(notdone)).*...
        (-1+2.*cos2sigmam(notdone).^2)));
    %disp(['then, lambda(21752) = ' num2str(lambda(21752),20)]);
    % correct for convergence failure in the case of essentially antipodal
    % points
    if any(lambda(notdone) > pi)
        warning('VDIST:antipodal',['Essentially antipodal points ' ...
            'encountered. Precision may be reduced.']);
        warninggiven = true;
        lambdaold(lambda>pi) = pi;
        lambda(lambda>pi) = pi;
    end
    notdone = abs(lambda-lambdaold) > 1e-12;
end
u2 = cos(alpha).^2.*(a^2-b^2)/b^2;
A = 1+u2./16384.*(4096+u2.*(-768+u2.*(320-175.*u2)));
B = u2./1024.*(256+u2.*(-128+u2.*(74-47.*u2)));
deltasigma = B.*sin(sigma).*(cos2sigmam+B./4.*(cos(sigma).*(-1+2.*...
    cos2sigmam.^2)-B./6.*cos2sigmam.*(-3+4.*sin(sigma).^2).*(-3+4*...
    cos2sigmam.^2)));
varargout{1} = reshape(b.*A.*(sigma-deltasigma),keepsize);
if nargout > 1
    % From point #1 to point #2
    % correct sign of lambda for azimuth calcs:
    lambda = abs(lambda);
    kidx=sign(sin(lon2-lon1)) .* sign(sin(lambda)) < 0;
    lambda(kidx) = -lambda(kidx);
    numer = cos(U2).*sin(lambda);
    denom = cos(U1).*sin(U2)-sin(U1).*cos(U2).*cos(lambda);
    a12 = atan2(numer,denom);
    kidx = a12<0;
    a12(kidx)=a12(kidx)+2*pi;
    % from poles:
    a12(lat1tr <= -90) = 0;
    a12(lat1tr >= 90 ) = pi;
    varargout{2} = reshape(a12 * 57.2957795130823,keepsize); % to degrees
end
if nargout > 2
    a21=NaN*lat1; %#ok this variable won't be computed if not needed
    % From point #2 to point #1
    % correct sign of lambda for azimuth calcs:
    lambda = abs(lambda);
    kidx=sign(sin(lon1-lon2)) .* sign(sin(lambda)) < 0;
    lambda(kidx)=-lambda(kidx);
    numer = cos(U1).*sin(lambda);
    denom = sin(U1).*cos(U2)-cos(U1).*sin(U2).*cos(lambda);
    a21 = atan2(numer,denom);
    kidx=a21<0;
    a21(kidx)= a21(kidx)+2*pi;
    % backwards from poles:
    a21(lat2tr >= 90) = pi;
    a21(lat2tr <= -90) = 0;
    varargout{3} = reshape(a21 * 57.2957795130823,keepsize); % to degrees
end
return

%%
% 
% function [dist,theta]=az(eastkm,northkm)
% 
% dist=sqrt(eastkm^2+northkm^2);
%     
%     if eastkm >= 0  && northkm >= 0
%         theta=rad2deg(atan(eastkm/northkm));
%         
%     elseif northkm < 0 && eastkm >= 0
%         theta=180-rad2deg(atan(eastkm/abs(northkm)));
%         
%     elseif northkm <= 0 && eastkm <= 0
%         theta=180+rad2deg(atan(abs(eastkm)/abs(northkm)));
%         
%     elseif northkm > 0 && eastkm < 0
%         theta=270+rad2deg(atan(northkm/abs(eastkm)));
%         
%     end
%     
%                       if theta < 0
%                           theta=-theta
%                           
%                       end
%
function [dist,theta]=az(eastkm,northkm)

if eastkm==0 && northkm==0
    dist=0;
    theta=0;
    return
    
else
    
    dist=sqrt(eastkm^2+northkm^2);
    
    if eastkm >= 0  && northkm >= 0
        theta=rad2deg(atan(eastkm/northkm));
        
    elseif northkm < 0 && eastkm >= 0
        theta=180-rad2deg(atan(eastkm/abs(northkm)));
        
    elseif northkm <= 0 && eastkm <= 0
        theta=180+rad2deg(atan(abs(eastkm)/abs(northkm)));
        
    elseif northkm > 0 && eastkm < 0
        theta=270+rad2deg(atan(northkm/abs(eastkm)));
        
    end
    
    if theta < 0
        theta=-theta;
                         
    end    
    
end



% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

if (get(handles.checkbox1,'Value') == get(handles.checkbox1,'Max'))
%%%enable rake
on =[handles.rake,handles.raketext,handles.norakesources,handles.rakespacing,handles.rakerefsource,handles.text45,handles.text46,handles.text47,handles.text48];
enableon(on)

off =[handles.noSourcesstrike,handles.distanceStep,handles.noSourcesdip,handles.steponPlane,handles.firstSourcestrike,handles.firstsourcedip, handles.fwidth, handles.flength, handles.text17, handles.text18, handles.text29, handles.text25, handles.text43 , handles.text20, handles.text31, handles.text24, handles.text19];
enableoff(off)

else
off =[handles.rake,handles.raketext,handles.norakesources,handles.rakespacing,handles.rakerefsource,handles.text45,handles.text46,handles.text47,handles.text48];
enableoff(off)

on =[handles.noSourcesstrike,handles.distanceStep,handles.noSourcesdip,handles.steponPlane,handles.firstSourcestrike,handles.firstsourcedip, handles.fwidth, handles.flength, handles.text17, handles.text18, handles.text29, handles.text25, handles.text43 , handles.text20, handles.text31, handles.text24, handles.text19];
enableon(on)


end



function rake_Callback(hObject, eventdata, handles)
% hObject    handle to rake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake as text
%        str2double(get(hObject,'String')) returns contents of rake as a double


% --- Executes during object creation, after setting all properties.
function rake_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')




% --- Executes on button press in kmlout.
function kmlout_Callback(hObject, eventdata, handles)
% hObject    handle to kmlout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of kmlout


% --- Executes when uipanel1 is resized.
function uipanel1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function norakesources_Callback(hObject, eventdata, handles)
% hObject    handle to norakesources (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of norakesources as text
%        str2double(get(hObject,'String')) returns contents of norakesources as a double


% --- Executes during object creation, after setting all properties.
function norakesources_CreateFcn(hObject, eventdata, handles)
% hObject    handle to norakesources (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rakespacing_Callback(hObject, eventdata, handles)
% hObject    handle to rakespacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rakespacing as text
%        str2double(get(hObject,'String')) returns contents of rakespacing as a double


% --- Executes during object creation, after setting all properties.
function rakespacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rakespacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rakerefsource_Callback(hObject, eventdata, handles)
% hObject    handle to rakerefsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rakerefsource as text
%        str2double(get(hObject,'String')) returns contents of rakerefsource as a double


% --- Executes during object creation, after setting all properties.
function rakerefsource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rakerefsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
