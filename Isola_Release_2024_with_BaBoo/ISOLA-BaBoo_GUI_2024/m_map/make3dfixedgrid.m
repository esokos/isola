function varargout = make3dfixedgrid(varargin)
% MAKE3DFIXEDGRID MATLAB code for make3dfixedgrid.fig
%      MAKE3DFIXEDGRID, by itself, creates a new MAKE3DFIXEDGRID or raises the existing
%      singleton*.
%
%      H = MAKE3DFIXEDGRID returns the handle to a new MAKE3DFIXEDGRID or the handle to
%      the existing singleton*.
%
%      MAKE3DFIXEDGRID('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAKE3DFIXEDGRID.M with the given input arguments.
%
%      MAKE3DFIXEDGRID('Property','Value',...) creates a new MAKE3DFIXEDGRID or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before make3dfixedgrid_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to make3dfixedgrid_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help make3dfixedgrid

% Last Modified by GUIDE v2.5 14-Dec-2024 15:27:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @make3dfixedgrid_OpeningFcn, ...
                   'gui_OutputFcn',  @make3dfixedgrid_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before make3dfixedgrid is made visible.
function make3dfixedgrid_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to make3dfixedgrid (see VARARGIN)

% Choose default command line output for make3dfixedgrid
handles.output = hObject;
   
% Update handles structure
guidata(hObject, handles);

%% check event.isl files with event info
h=dir('event.isl');

if isempty(h)  
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
   h=dir('.\gmtfiles\3dsourcesinfo.txt');
else
   h=dir('./gmtfiles/3dsourcesinfo.txt');
end

if isempty(h)  
  disp('3dsourcesinfo.txt file doesn''t exist in gmtfiles folder. Using defaults.');
else
    if ispc
       fid = fopen('.\gmtfiles\3dsourcesinfo.txt','r'); 
    else
       fid = fopen('./gmtfiles/3dsourcesinfo.txt','r');  
    end
    tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);
    tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);
    % 
    tline = fgetl(fid);
    set(handles.depth,'String',strrep(tline,' ',''))   

    tline = fgetl(fid);     
    tline = fgetl(fid);
    set(handles.northkm,'String',strrep(tline,' ',''))
    % 
    tline = fgetl(fid);     
    tline = fgetl(fid);
    set(handles.eastkm,'String',strrep(tline,' ',''))
    % 
    tline = fgetl(fid);     
    tline = fgetl(fid);
    set(handles.depthspacing,'String',strrep(tline,' ',''))     

    tline = fgetl(fid);     
    tline = fgetl(fid);
    set(handles.xyspacing,'String',strrep(tline,' ',''))      

end

% UIWAIT makes make3dfixedgrid wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = make3dfixedgrid_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function northkm_Callback(hObject, eventdata, handles)
% hObject    handle to northkm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of northkm as text
%        str2double(get(hObject,'String')) returns contents of northkm as a double


% --- Executes during object creation, after setting all properties.
function northkm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to northkm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eastkm_Callback(hObject, eventdata, handles)
% hObject    handle to eastkm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eastkm as text
%        str2double(get(hObject,'String')) returns contents of eastkm as a double


% --- Executes during object creation, after setting all properties.
function eastkm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eastkm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depth_Callback(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth as text
%        str2double(get(hObject,'String')) returns contents of depth as a double


% --- Executes during object creation, after setting all properties.
function depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function depthspacing_Callback(hObject, eventdata, handles)
% hObject    handle to depthspacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depthspacing as text
%        str2double(get(hObject,'String')) returns contents of depthspacing as a double

% get the starting depth value
epidepth = str2double(get(handles.depth,'String'));
% get the  depthspacing value

if epidepth-str2double(get(handles.depthspacing,'String')) <=0

   errordlg('Value produces trial sources on 0 or in the air.')
   set(handles.depthspacing,'String',' ');

else

end


% --- Executes during object creation, after setting all properties.
function depthspacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depthspacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xyspacing_Callback(hObject, eventdata, handles)
% hObject    handle to xyspacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xyspacing as text
%        str2double(get(hObject,'String')) returns contents of xyspacing as a double


% --- Executes during object creation, after setting all properties.
function xyspacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xyspacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Calculate.
function Calculate_Callback(hObject, eventdata, handles)
% hObject    handle to Calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% check if GREEN folder exists..

h=dir('green');

if isempty(h) 
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

% go in GREEN
cd green
  % DELETE src files
  system('del src*.dat');
  % go back
cd ..

%% check if gmtfiles folder exists..

h=dir('gmtfiles');

if isempty(h) 

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

%% EPICENTER
epilat = str2double(get(handles.lat,'String'));
epilon = str2double(get(handles.lon,'String'));
epidepth = str2double(get(handles.depth,'String'));

northkm=str2double(get(handles.northkm,'String'));
eastkm=str2double(get(handles.eastkm,'String'));

if northkm == 0 && eastkm == 0 
    disp('No shift in epicenter')
    
    Edist=0;      Ndist=0;
    newlon=epilon;    newlat=epilat; 
    orshift=0;
 
else
% change position of starting point...
%  distance between points and azimuth is needed

[dist,theta]=az(eastkm,northkm);
[newlat,newlon] = vdistinv(epilat,epilon,dist*1000,theta);

    Edist=eastkm;
    Ndist=northkm;
    orshift=1;
       
% change Lat Lon values....
set(handles.lat,'String',num2str(newlat),...
                  'FontSize',12,...
                  'FontWeight','bold',...
                  'ForegroundColor','red')        
set(handles.lon,'String',num2str(newlon),...
                  'FontSize',12,...
                  'FontWeight','bold',...
                  'ForegroundColor','red')        
end
%%
% horizontal plane
strike = 0; dip = 0;

%  No of Sources


noSourcesstrike = 3;


%  Distance step
distanceStep = str2double(get(handles.xyspacing,'String'));

% No of sources on Dip SAME AS for STRIKE
noSourcesdip = noSourcesstrike;


%  Distance step
steponPlane = str2double(get(handles.xyspacing,'String')); % dip step

%  Depth step
depthgridstep = str2double(get(handles.depthspacing,'String')); % dip step

%%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
magn=str2double(get(handles.magn,'String'));
eventdate=get(handles.eventdate,'String');


%  First Source (grid center at the Hypocenter)
firstSourcestrike = 2;
firstSourcedip = 2;


disp(['Calculating coordinates of ' num2str(noSourcesstrike*noSourcesdip*3) ' sources '])  

% WE FIX ORIGIN OF CARTESIAN SYSTEM ON THE EPICENTER 
% Convert strike to radians
diprad=deg2rad(dip);
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


% check that we don't have sources at 0 or above
if epidepth-depthgridstep <=0
    errordlg('You have specified sources at 0 or in the air. Check your Starting depth and your Depth Grid spacing.','Error');
    return
else
end

% XY Coordinates are the same only depth changes
%combine in onelarge 1D matrix =3*25=75points

D1(:,:)=ones(noSourcesstrike,noSourcesdip)*(epidepth-depthgridstep);
D2(:,:)=ones(noSourcesstrike,noSourcesdip)*epidepth;
D3(:,:)=ones(noSourcesstrike,noSourcesdip)*(epidepth+depthgridstep);

dep=[D1(1,1); D2(1,1); D3(1,1)]


% make 1D arrays
X=reshape(xrot',[noSourcesstrike*noSourcesdip,1]);
Y=reshape(yrot',[noSourcesstrike*noSourcesdip,1]);
D11=D1(:);D22=D2(:);D33=D3(:);

% make 3D X Y Z matrix
X1dall=cat(1,X,X,X);Y1dall=cat(1,Y,Y,Y);Dall=cat(1,D11,D22,D33);

% plot in 3D
figure(2)
plot3(X1dall,Y1dall,Dall,'ro')
hold
% make text for each source
sourceindex=0;TextXY=[];

for d=1:3
 for j=1:noSourcesdip 
    for i=1:noSourcesstrike
        xytext(j,i)={num2str(i+sourceindex,'%02d')};
    end
     sourceindex=sourceindex+i;
 end
    str = convertCharsToStrings(xytext);
    TextXY=[TextXY;reshape(str',[noSourcesstrike*noSourcesdip,1])];
end
% add text 
text(X1dall,Y1dall,Dall,TextXY)

grid on
axis square
set(gca, 'Zdir', 'reverse')
xlabel('East-West (km)')
ylabel('North-South (km)')
zlabel('Depth')
title('X-Y-Z')
set(gca,'Box','On')

% OUTPUT TO SRC FILES
%% first source.isl !!!!!!!!! We might need to modify this !!!!!

%   
ntsources=noSourcesdip*noSourcesstrike*3; 

 fid2 = fopen('tsources.isl','w');
    fprintf(fid2,'%s\r\n','3Dplane');
    fprintf(fid2,'%i\r\n',ntsources);   
    fprintf(fid2,'%i\r\n',noSourcesstrike);
    fprintf(fid2,'%i\r\n',distanceStep);
    fprintf(fid2,'%i\r\n',noSourcesdip);
    fprintf(fid2,'%f   %f   %f\r\n',D1(1,1),D2(1,1),D3(1,1));
    fprintf(fid2,'%s\r\n','Sources on 3 horizontal planes');
  fclose(fid2);            

%% go in GREEN and save SRC files
try
    cd green
            fileindex=0;

             for j=1:ntsources
                  filename=['src' num2str(j+fileindex,'%02d') '.dat'];
                       fid = fopen(filename,'w');
                             fprintf(fid,'%s\r\n',' Source parameters');
                             fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');    %X1dall,Y1dall,Dall
                             fprintf(fid,'%10.3f%10.3f%10.3f%10.4f  %c%s%c\r\n',Y1dall(j),X1dall(j),abs(Dall(j)),magn, '''', eventdate, '''');
                       fclose(fid);
                   
              end
                   fileindex=fileindex+j;
              % finished go back
    cd ..

catch
        helpdlg('Error in src file creation in GREEN folder');
    cd ..
end
%%
             %% go in gmtfile
             cd gmtfiles

             % fid = fopen('sour.dat','w');   % new file for XY plotting of beachballs...
             % for j=1:noSourcesdip
             %      for i=1:noSourcesstrike
             %         fprintf(fid,'%10.4f   %10.4f  %10.4f  %s\r\n',xrot(j,i),yrot(j,i),-z(j,i),xytext{j,i});
             %      end
             % end
             % fclose(fid);   
             %%%%%%%%%%%%%%%%% Geographical coordinates file....
             fid = fopen('sources.gmt','w');

             %
             % westbound=180; eastbound=0;
             % southbound=90; northbound=-90;

             orig_y=yrot(firstSourcedip,firstSourcestrike);
             orig_x=xrot(firstSourcedip,firstSourcestrike);

            NN=1;
            for dd=1:3

             for j=1:noSourcesdip
                  for i=1:noSourcesstrike
                               
                      eastkm(j,i)= xrot(j,i)-orig_x;   
                      northkm(j,i)=yrot(j,i)-orig_y;
                      
                       [dist(j,i),theta(j,i)]=az(eastkm(j,i),northkm(j,i));
                   %   [outpointsYrot(j,i),outpointsXrot(j,i),derr(j,i),aerr(j,i)] = vdistinv(newlat,newlon,dist(j,i)*1000,theta(j,i))
                       [outpointsYrot(j,i),outpointsXrot(j,i),~] = wgs84invdist(newlat,newlon,theta(j,i),dist(j,i)*1000,1,1);
                       outpointsZrot(j,i)=dep(dd);
                     
                       outpointsXrot(firstSourcedip,firstSourcestrike)=newlon;
                       outpointsYrot(firstSourcedip,firstSourcestrike)=newlat;
                       
                       
                   fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f %s %s\r\n',outpointsXrot(j,i),outpointsYrot(j,i),'0.2',outpointsZrot(j,i),num2str(NN,'%02d'),'d');
                   
                     % if outpointsXrot(j,i) <= westbound
                     %     westbound = outpointsXrot(j,i);
                     % end
                     % if outpointsXrot(j,i) >= eastbound
                     %     eastbound = outpointsXrot(j,i);
                     % end
                     % if outpointsYrot(j,i) <= southbound
                     %     southbound = outpointsYrot(j,i);
                     % end
                     % if outpointsYrot(j,i) >= northbound
                     %     northbound = outpointsYrot(j,i);
                     % end
                     NN=NN+1;
                  end
                     
             end
             
             end

             fprintf(fid,'  %5.10f   %5.10f  %s  %5.10f  %s %s\r\n',newlon,newlat,'0.8',epidepth,'New_ref','a');
             fprintf(fid,'  %5.10f   %5.10f   %s %5.10f  %s %s\r\n',epilon,epilat,'0.4',epidepth,'Old_ref','a');
             
             fclose(fid);   
%% output values from this run to 3dsourcesinfo.txt
            fid = fopen('3dsourcesinfo.txt','w');
             
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

             fprintf(fid,'Depth spacing\r\n');
             fprintf(fid,'%u   \r\n', depthgridstep);
             fprintf(fid,'Horizontal spacing\r\n');
             fprintf(fid,'%u   \r\n', steponPlane);

            fclose(fid);
cd ..
%% plot in geographical coordinates
 border=0.1;
 wend=min(min(outpointsXrot));  eend=max(max(outpointsXrot)); send=min(min(outpointsYrot));  nend=max(max(outpointsYrot));
 w=(wend-border); e=(eend+border); s=(send-border);  n=(nend+border);

   figure(3)
   m_proj('Mercator','long',[w e],'lat',[s n]) 
   m_gshhs_h('color','k');
   m_grid('box','fancy','tickdir','out');
   m_ruler([.3 .6],.1,'tickdir','out','ticklen',[.007 .007]);

   %plot new "epicenter"
   m_line(newlon,newlat,'marker','p','markersize',17,'color','y','MarkerFaceColor','y');

   %plot epicenter
   m_line(epilon,epilat,'marker','p','markersize',17,'color','b','MarkerFaceColor','b');

   % plot trial points at one depth 
   m_line(outpointsXrot,outpointsYrot,'marker','square','markersize',5,'color','r','linewi',1,'linest','none');
   m_text(outpointsXrot,outpointsYrot,xytext,'vertical','top')

   disp('        ')
   disp('Only deepest plane of trial sources is shown in map view.')
   disp('        ')



%%
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

%%
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

%%
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


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close
