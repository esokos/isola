function varargout = shiftraw(varargin)
% SHIFTRAW M-file for shiftraw.fig
%      SHIFTRAW, by itself, creates a new SHIFTRAW or raises the existing
%      singleton*.
%
%      H = SHIFTRAW returns the handle to a new SHIFTRAW or the handle to
%      the existing singleton*.
%
%      SHIFTRAW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHIFTRAW.M with the given input arguments.
%
%      SHIFTRAW('Property','Value',...) creates a new SHIFTRAW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before shiftraw_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to shiftraw_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help shiftraw

% Last Modified by GUIDE v2.5 06-Jul-2017 09:54:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @shiftraw_OpeningFcn, ...
                   'gui_OutputFcn',  @shiftraw_OutputFcn, ...
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


% --- Executes just before shiftraw is made visible.
function shiftraw_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to shiftraw (see VARARGIN)

% Choose default command line output for shiftraw
handles.output = hObject;

% Update handles structure
%%%raw data 
handles.ew = 0;
handles.ns = 0;
handles.ver = 0;
handles.tim=0;
handles.time_sec=0;
handles.dt=0;
handles.file=0;
handles.samfreq=0;
handles.totalns=0;
handles.totalew=0;
handles.totalver=0;



% %%% check rawinfo.isl files with event info
% h=dir('rawinfo.isl');
% 
% if length(h) == 0; 
%   errordlg('Rawinfo.isl file doesn''t exist. Run Event info. ','File Error');
%   return
% else
%     fid = fopen('rawinfo.isl','r');
% %    samfreq=fscanf(fid,'%g',1);
%     rawhour=fscanf(fid,'%g',1);
%     rawmin=fscanf(fid,'%g',1);
%     rawsec=fscanf(fid,'%g',1);
%     fclose(fid);
% end

%handles.samfreq=samfreq;
%handles.dt=1/samfreq;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes shiftraw wait for user response (see UIRESUME)
% uiwait(handles.shiftraw);



% --- Outputs from this function are returned to the command line.
function varargout = shiftraw_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%% reset total shift...
set(handles.totalnstext,'String','0')
set(handles.totalewtext,'String','0')
set(handles.totalvertext,'String','0')

% %% read what is written in rawinfo.isl
% samfreq=handles.samfreq;
% def{1,1} =num2str(samfreq);

messtext=...
   ['Please select a datafile.                      '
    'This file should be a text file with           '
    'four columns separated by spaces.              '
    'Columns should contain time and data channels. '
    'The succession will not change during output.  '];

uiwait(msgbox(messtext,'Message','warn','modal'));

[file1,path1] = uigetfile([ '*.dat'],' Earthquake Datafile',400,400);

   lopa = [path1 file1]
   name = file1
   
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

whos time_sec ns ew ver

% 
%this is the sample number not the time....
tim=(1:1:length(time_sec(:,1)));

%prepare time axis
%%%%%%%%%read sampling rate

% def = {'1'};
% 
% ni2 = inputdlg('What is the sampling Frequency','Input',1,def);
% l = ni2{1};
% n = str2num(l);
sfreq=1/time_sec(2);

set(handles.sfreq,'String',num2str(sfreq))

% srate = str2double(get(handles.sfreq,'String'));
% disp(srate);
dt=time_sec(2);

% time_sec=((tim.*dt)-dt);

%save RAW data to handles 
handles.ew = ew;
handles.ns = ns;
handles.ver=ver;
handles.tim=tim;
handles.time_sec=time_sec;
handles.dt=dt;
handles.file=file1;
guidata(hObject,handles)

%%%%%%%%%%%%%%Update labels of components on graph based on file name
set(handles.verlabel,'string',[file1(1:3) 'z'])
set(handles.ewlabel,'string',[file1(1:3) 'e'])
set(handles.nslabel,'string',[file1(1:3) 'n'])
%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ew,'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,ns,'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,ver,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
ylabel('Counts')

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%read from  handles...
ew_shifted  = handles.ew_shifted;
ns_shifted  = handles.ns_shifted;
ver_shifted = handles.ver_shifted;
file=handles.file;
time_sec=handles.time_sec;

whos time_sec ew_shifted ns_shifted ver_shifted


alld=[time_sec'; ns_shifted' ; ew_shifted' ; ver_shifted' ];

whos alld

station_name=file(1:3)
station_name=[station_name 'raw' '.dat'];


[newfile, newdir] = uiputfile(station_name, 'Save station data as');
fid = fopen([newdir newfile],'w');
fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%
fclose(fid);

infostr= ['Data were written in the file ' newdir newfile ' the column order didn''t change'];

helpdlg(infostr,'File info');


% --- Executes during object creation, after setting all properties.
function shiftew_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function shiftew_Callback(hObject, eventdata, handles)
% hObject    handle to shiftew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shiftew as text
%        str2double(get(hObject,'String')) returns contents of shiftew as a double


% --- Executes during object creation, after setting all properties.
function shiftns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function shiftns_Callback(hObject, eventdata, handles)
% hObject    handle to shiftns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shiftns as text
%        str2double(get(hObject,'String')) returns contents of shiftns as a double


% --- Executes during object creation, after setting all properties.
function shiftver_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shiftver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function shiftver_Callback(hObject, eventdata, handles)
% hObject    handle to shiftver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shiftver as text
%        str2double(get(hObject,'String')) returns contents of shiftver as a double


% --- Executes on button press in shift.
function shift_Callback(hObject, eventdata, handles)
% hObject    handle to shift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%READ DATA FROM HANDLES AND put in new variables....
ew=handles.ew;
ns=handles.ns;
ver=handles.ver;
dt=handles.dt;
time_sec=handles.time_sec;

totalns=handles.totalns;
totalew=handles.totalew;
totalver=handles.totalver;

%read shifts per component
shiftew  = str2double(get(handles.shiftew,'String'));
shiftns  = str2double(get(handles.shiftns,'String'));
shiftver = str2double(get(handles.shiftver,'String'));

%%%% convert sec to points 
shiftpointsew=(shiftew+totalew)/dt
shiftpointsns=(shiftns+totalns)/dt
shiftpointsver=(shiftver+totalver)/dt

%%% shift data...EW
     if shiftpointsew < 0;  %  cut points at the beggining and add zeroes at the end...
         b = zeros(abs(shiftpointsew),1);
         size(b)
         ew_shifted  = vertcat(ew(abs(shiftpointsew)+1:length(ew),1), b) ;
     elseif shiftpointsew > 0;  %add zeroes at the beggining and cut samples at the end...
         b = zeros(shiftpointsew,1);
         size(b)
         ew_shifted = vertcat(b, ew(1:length(ew)-shiftpointsew,1));
     elseif shiftpointsew == 0;
         ew_shifted = ew;
     end
length(ew_shifted)
length(ew)

%%% shift data...NS
     if shiftpointsns < 0;  %  cut points at the beggining and add zeroes at the end...
         b = zeros(abs(shiftpointsns),1);
         size(b)
         ns_shifted  = vertcat(ns(abs(shiftpointsns)+1:length(ns),1), b) ;
     elseif shiftpointsns > 0;  %add zeroes at the beggining and cut samples at the end...
         b = zeros(shiftpointsns,1);
         size(b)
         ns_shifted = vertcat(b, ns(1:length(ns)-shiftpointsns,1));
     elseif shiftpointsns == 0;
         ns_shifted = ns;
     end
length(ns_shifted)
length(ns)

%%% shift data...VER
     if shiftpointsver < 0;  %  cut points at the beggining and add zeroes at the end...
         b = zeros(abs(shiftpointsver),1);
         size(b)
         ver_shifted  = vertcat(ver(abs(shiftpointsver)+1:length(ver),1), b) ;
     elseif shiftpointsver > 0;  %add zeroes at the beggining and cut samples at the end...
         b = zeros(shiftpointsver,1);
         size(b)
         ver_shifted = vertcat(b, ver(1:length(ver)-shiftpointsver,1));
     elseif shiftpointsver == 0;
         ver_shifted = ver;
     end
length(ver_shifted)
length(ver)

%%%  new total per comp
totalns=totalns+shiftns ;
totalew=totalew+shiftew ;
totalver=totalver+shiftver ;
%
set(handles.totalnstext,'String',num2str(totalns))
set(handles.totalewtext,'String',num2str(totalew))
set(handles.totalvertext,'String',num2str(totalver))


%%%%%saving to handles...
handles.ew_shifted = ew_shifted;
handles.ns_shifted = ns_shifted;
handles.ver_shifted=ver_shifted;

handles.totalns=totalns;
handles.totalew=totalew;
handles.totalver=totalver;
guidata(hObject,handles)

%%%plotting
%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(handles.ewaxis)
plot(time_sec,ew,'k')
hold on
plot(time_sec,ew_shifted,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')
hold off
axes(handles.nsaxis)
plot(time_sec,ns,'k')
hold on
plot(time_sec,ns_shifted,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')
hold off
axes(handles.veraxis)
plot(time_sec,ver,'k')
hold on
plot(time_sec,ver_shifted,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
hold off

% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.shiftraw)
