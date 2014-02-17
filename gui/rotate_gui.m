function varargout = rotate_gui(varargin)
% ROTATE_GUI M-file for rotate_gui.fig
%      ROTATE_GUI, by itself, creates a new ROTATE_GUI or raises the
%      existing
%      singleton*.
%
%      H = ROTATE_GUI returns the handle to a new ROTATE_GUI or the handle to
%      the existing singleton*.
%
%      ROTATE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROTATE_GUI.M with the given input arguments.
%
%      ROTATE_GUI('Property','Value',...) creates a new ROTATE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rotate_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rotate_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rotate_gui

% Last Modified by GUIDE v2.5 13-Oct-2011 13:50:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rotate_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @rotate_gui_OutputFcn, ...
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


% --- Executes just before rotate_gui is made visible.
function rotate_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rotate_gui (see VARARGIN)

% Choose default command line output for rotate_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rotate_gui wait for user response (see UIRESUME)
% uiwait(handles.rotate_gui);


% --- Outputs from this function are returned to the command line.
function varargout = rotate_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.polplot);
cla 
set(handles.infotext,'String',' ')
set(handles.text7,'String','Thick line is the current system. Thin line is the rotated.')
set(handles.text10,'String','North, X is red. East, Y is blue')
set(handles.ne2xy,'Enable','Off')
set(handles.xy2ne,'Enable','Off')

%
messtext=...
   ['Please select a datafile.                      '
    'This file should be a text file with           '
    'four columns separated by spaces.              '
    'Each column should contain one data channel and'
    'the succession should be Time, NS, EW and Z or '
    'Time, X, Y , Z.                                '];

uiwait(msgbox(messtext,'Message','warn','modal'));

[file1,path1] = uigetfile([ '*.dat'],' Earthquake Datafile');

   lopa = [path1 file1];
   name = file1;
   
      if name == 0
         disp('Cancel file load')
         return
      else
      end
lopa
% 
fid  = fopen(lopa,'r');
[time_sec,ns,ew,ver] = textread(lopa,'%f %f %f %f');
fclose(fid);

% dt=1/srate;
dt=time_sec(2);
%%%%compute sampling freq
sfreq=1/time_sec(2);

%save RAW data to handles 
handles.ew = ew;
handles.ns = ns;
handles.ver=ver;
handles.time_sec=time_sec;
handles.dt=dt;
handles.file1=file1;
handles.path1=path1;
guidata(hObject,handles)

% %%%%%%%%%%%%%%Update labels of components on graph based on file name
% set(handles.verlabel,'string','Z');
% set(handles.ewlabel,'string','EW');
% set(handles.nslabel,'string','NS');

%%%%%%%%%%%%%%%%%%PLOT  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(handles.ewaxis)
plot(time_sec,ew,'b')
set(handles.ewaxis,'XMinorTick','on')
grid on
ylabel('E or Y')
axes(handles.nsaxis)
plot(time_sec,ns,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
ylabel('N or X')
axes(handles.veraxis)
plot(time_sec,ver,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
xlabel('Time (sec)')
ylabel('Z')


% disable Save
set(handles.save,'Enable','Off')


% % make the arrows
% %case on NS Ew
% ew=[90 1];
% ns=[0 1]; 
% axes(handles.polplot);
% %set(handles.polplot,'XMinorTick','off','YMinorTick','off','XTick',[],'YTick',[],'ZTick',[])
% [a,b]=pol2cart(deg2rad(ns(1)),ns(2));
% [c,d]=pol2cart(deg2rad(ew(1)),ew(2));
% h=gca
% 
% compass(a,b,'r')
% hold
% compass(c,d,'b')
% set(gca,'View',[-90 90],'YDir','reverse','XTick',[],'YTick',[],'ZTick',[],'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[]);
% hold off



% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.rotate_gui)



function rotangle_Callback(hObject, eventdata, handles)
% hObject    handle to rotangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotangle as text
%        str2double(get(hObject,'String')) returns contents of rotangle as a double


%this should just plot the 2 systems
% Plot the arrows case on NS Ew
rotangledeg = str2double(get(handles.rotangle,'String'));
%  NE case
Ndir=0;
Edir=90;
ew2=[Edir 1];
ns2=[Ndir 1]; 
[a2,b2]=pol2cart(deg2rad(ns2(1)),ns2(2));
[c2,d2]=pol2cart(deg2rad(ew2(1)),ew2(2));
%
% find the values for the rotated
Edir=Edir+rotangledeg;
Ndir=Ndir+rotangledeg;
ew2=[Edir 1];
ns2=[Ndir 1]; 
[a,b]=pol2cart(deg2rad(ns2(1)),ns2(2));
[c,d]=pol2cart(deg2rad(ew2(1)),ew2(2));


axes(handles.polplot);
h1=compass(handles.polplot,a2,b2,'r');
set(h1,'LineWidth',5);
hold;
h2=compass(handles.polplot,c2,d2,'b');
set(h2,'LineWidth',5);

h1=compass(handles.polplot,a,b,'r');
set(h1,'LineWidth',2);

h2=compass(handles.polplot,c,d,'b');
set(h2,'LineWidth',2);
hold off;


set(gca,'View',[-90 90],'YDir','reverse');

f=gcf;

editplot(f)
drawnow;

set(handles.ne2xy,'Enable','On')







% --- Executes during object creation, after setting all properties.
function rotangle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%

%% --- Executes on button press in ne2xy.
function ne2xy_Callback(hObject, eventdata, handles)
% hObject    handle to ne2xy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% READ DATA FROM HANDLES
%%%%% WE WORK ON 
ew=handles.ew ;
ns=handles.ns ;
ver=handles.ver;
time_sec=handles.time_sec;

% since we are in NE --> RT case
Ndir=0;
Edir=90;

% read rotation angle
rotangle = deg2rad(str2double(get(handles.rotangle,'String')));
rotangledeg = str2double(get(handles.rotangle,'String'));

R= cosd(rotangledeg).*ns+sind(rotangledeg).*ew;
T=-sind(rotangledeg).*ns+cosd(rotangledeg).*ew;

% update option
rotoption=1;

% Save to handles
handles.rotoption=rotoption;
handles.rotR = R;
handles.rotT = T;
guidata(hObject,handles)

%Update GUI Info text
set(handles.infotext,'String',['Data rotated clockwise by ' get(handles.rotangle,'String') ' degrees'])
% enable Save
set(handles.save,'Enable','On')
set(handles.text7,'String',' ')
set(handles.text10,'String',' ')

%
% Plot the arrows case on NS Ew
Edir=Edir+rotangledeg;
Ndir=Ndir+rotangledeg;
ew2=[Edir 1];
ns2=[Ndir 1]; 
[a,b]=pol2cart(deg2rad(ns2(1)),ns2(2));
[c,d]=pol2cart(deg2rad(ew2(1)),ew2(2));

axes(handles.polplot);

h1=compass(handles.polplot,a,b,'r');
set(h1,'LineWidth',5);
hold;
h2=compass(handles.polplot,c,d,'b');
set(h2,'LineWidth',5);
hold off;
set(gca,'View',[-90 90],'YDir','reverse');

f=gcf;

editplot(f)
drawnow;

%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,T,'b')
set(handles.ewaxis,'XMinorTick','on')
grid on
ylabel('E or Y')
axes(handles.nsaxis)
plot(time_sec,R,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
ylabel('N or X')
axes(handles.veraxis)
plot(time_sec,ver,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
ylabel('Z')
xlabel('Time (sec)')


%%

function editplot(f)

set(0,'ShowHiddenHandles','on');

%setting the position of compass to top right corner of figure
%set(ha,'Position',[0.75 0.75 0.20 0.20]);
%getting text handles
ht=findall(f,'Type','Text');

%finding the text that should be replaced by direction labels
ht1=findall(ht,'String','0');
ht2=findall(ht,'String','30');
ht3=findall(ht,'String','60');
ht4=findall(ht,'String','90');
ht5=findall(ht,'String','120');
ht6=findall(ht,'String','150');
ht7=findall(ht,'String','180');
ht8=findall(ht,'String','210');
ht9=findall(ht,'String','240');
ht10=findall(ht,'String','270');
ht11=findall(ht,'String','300');
ht12=findall(ht,'String','330');

set(ht,'String','');

%setting the direction labels
set(ht1,'String','0');
set(ht2,'String','30');
set(ht3,'String','60');
set(ht4,'String','90');
set(ht5,'String','120');
set(ht6,'String','150');
set(ht7,'String','180');
set(ht8,'String','210');
set(ht9,'String','240');
set(ht10,'String','270');
set(ht11,'String','300');
set(ht12,'String','330');


% --- Executes on button press in xy2ne.
function xy2ne_Callback(hObject, eventdata, handles)
% hObject    handle to xy2ne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% READ DATA FROM HANDLES
%%%%% WE WORK ON 
ew=handles.ew;
ns=handles.ns;
ver=handles.ver;
time_sec=handles.time_sec;

% read rotation angle
rotangle = deg2rad(str2double(get(handles.rotanglexy,'String')));
rotangledeg = str2double(get(handles.rotanglexy,'String'));

N= cosd(-rotangledeg).*ns+sind(-rotangledeg).*ew;
E=-sind(-rotangledeg).*ns+cosd(-rotangledeg).*ew;

% update option
rotoption=2;

% Save to handles
handles.rotoption=rotoption;
handles.rotN = N;
handles.rotE = E;
handles.ver=ver;
guidata(hObject,handles)

%Update GUI Info text
set(handles.infotext,'String',['Data rotated anti-clockwise by ' get(handles.rotanglexy,'String') ' degrees'])
% enable Save
set(handles.save,'Enable','On')
%
set(handles.text7,'String',' ')
set(handles.text10,'String',' ')


% Plot the arrows case on NS Ew
% since we are in NE --> RT case
Ndir=0;
Edir=90;

ew2=[Edir 1];
ns2=[Ndir 1]; 
[a,b]=pol2cart(deg2rad(ns2(1)),ns2(2));
[c,d]=pol2cart(deg2rad(ew2(1)),ew2(2));

axes(handles.polplot);

h1=compass(handles.polplot,a,b,'r');
set(h1,'LineWidth',5);
hold;
h2=compass(handles.polplot,c,d,'b');
set(h2,'LineWidth',5);
hold off;
set(gca,'View',[-90 90],'YDir','reverse');

f=gcf;

editplot(f)
drawnow;

%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,E,'b')
set(handles.ewaxis,'XMinorTick','on')
grid on
ylabel('E or Y')

axes(handles.nsaxis)
plot(time_sec,N,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
ylabel('N or X')

axes(handles.veraxis)
plot(time_sec,ver,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
xlabel('Time (sec)')
ylabel('Z')


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% read rotoption
rotoption=handles.rotoption;
% read file name
file1=handles.file1;
path1=handles.path1;
k = findstr(file1, '.');
rotfilename=[file1(1:k-1) '_rot' file1(k:end)];

switch rotoption
    case 1
        disp('Rotated N,E components to X,Y orientation')
          %read rotated from handles
             R=handles.rotR; 
             T=handles.rotT;
             ver=handles.ver;
             time_sec=handles.time_sec;
             
                  alld=[time_sec'; R' ; T' ; ver'];

                  
           %now save 
           [FileName,PathName,FilterIndex] = uiputfile(rotfilename,'Save File', [path1 rotfilename]);

                  fid = fopen([PathName FileName],'w');
                    if ispc
                     fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%
                    else
                     fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%
                    end
                    
                  fclose(fid);
        
    case 2
        disp('Rotated X,Y components to N,E orientation')
        %read from handles
          N=handles.rotN;
          E=handles.rotE;
          ver=handles.ver;
          time_sec=handles.time_sec;
        
          alld=[time_sec'; N' ; E' ; ver'];
                  
           %now save 
           [FileName,PathName,FilterIndex] = uiputfile(rotfilename,'Save File', [path1 rotfilename]);

                  fid = fopen([PathName FileName],'w');
                    if ispc
                       fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%
                    else
                       fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%
                    end
                  fclose(fid);
    otherwise
        disp('Flipped components')
        %read from handles
          N=handles.ns;
          E=handles.ew;
          ver=handles.ver;
          time_sec=handles.time_sec;
        
          alld=[time_sec'; N' ; E' ; ver'];
                  
           %now save 
           [FileName,PathName,FilterIndex] = uiputfile(rotfilename,'Save File', [path1 rotfilename]);

                  fid = fopen([PathName FileName],'w');
                    if ispc
                       fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%
                    else
                       fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%
                    end
                  fclose(fid);
                 
end



function rotanglexy_Callback(hObject, eventdata, handles)
% hObject    handle to rotanglexy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotanglexy as text
%        str2double(get(hObject,'String')) returns contents of rotanglexy as a double



%this should just plot the 2 systems
% Plot the arrows case on NS Ew
rotangledeg = str2double(get(handles.rotanglexy,'String'));
%  NE case
Ndir=0;
Edir=90;
ew2=[Edir 1];
ns2=[Ndir 1]; 
[a2,b2]=pol2cart(deg2rad(ns2(1)),ns2(2));
[c2,d2]=pol2cart(deg2rad(ew2(1)),ew2(2));
%
% find the values for the rotated
Edir=Edir+rotangledeg;
Ndir=Ndir+rotangledeg;
ew2=[Edir 1];
ns2=[Ndir 1]; 
[a,b]=pol2cart(deg2rad(ns2(1)),ns2(2));
[c,d]=pol2cart(deg2rad(ew2(1)),ew2(2));


axes(handles.polplot);

h1=compass(handles.polplot,a,b,'r');
set(h1,'LineWidth',5);
hold;
h2=compass(handles.polplot,c,d,'b');
set(h2,'LineWidth',5);
h1=compass(handles.polplot,a2,b2,'r');
set(h1,'LineWidth',2);
h2=compass(handles.polplot,c2,d2,'b');
set(h2,'LineWidth',2);
hold off;


set(gca,'View',[-90 90],'YDir','reverse');

f=gcf;

editplot(f)
drawnow;
set(handles.xy2ne,'Enable','On')






% --- Executes during object creation, after setting all properties.
function rotanglexy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotanglexy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in flipver.
function flipver_Callback(hObject, eventdata, handles)
% hObject    handle to flipver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flipver

ver=handles.ver;
time_sec=handles.time_sec;

newver=ver*(-1);

axes(handles.veraxis)
plot(time_sec,newver,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
xlabel('Time (sec)')
ylabel('Z')


disp('Vertical component is flipped')

handles.ver=newver;
rotoption=5;
handles.rotoption=rotoption;
guidata(hObject,handles)

set(handles.save,'Enable','On')

% --- Executes on button press in flipew.
function flipew_Callback(hObject, eventdata, handles)
% hObject    handle to flipew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flipew

ew=handles.ew;
time_sec=handles.time_sec;

newew=ew*(-1);

axes(handles.ewaxis)
plot(time_sec,newew,'b')
set(handles.ewaxis,'XMinorTick','on')
grid on
xlabel('Time (sec)')
ylabel('E or Y')


disp('Component is flipped')


handles.ew=newew;
rotoption=5;
handles.rotoption=rotoption;
guidata(hObject,handles)

set(handles.save,'Enable','On')


% --- Executes on button press in flipns.
function flipns_Callback(hObject, eventdata, handles)
% hObject    handle to flipns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of flipns
ns=handles.ns;
time_sec=handles.time_sec;

newns=ns*(-1);

axes(handles.nsaxis)
plot(time_sec,newns,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
xlabel('Time (sec)')
ylabel('N or X')

disp('Component is flipped')

handles.ns=newns;
rotoption=5;
handles.rotoption=rotoption;
guidata(hObject,handles)

set(handles.save,'Enable','On')

