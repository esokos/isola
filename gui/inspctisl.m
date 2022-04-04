function varargout = inspctisl(varargin)
% INSPCTISL M-file for inspctisl.fig
%      INSPCTISL, by itself, creates a new INSPCTISL or raises the existing
%      singleton*.
%
%      H = INSPCTISL returns the handle to a new INSPCTISL or the handle to
%      the existing singleton*.
%
%      INSPCTISL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSPCTISL.M with the given input arguments.
%
%      INSPCTISL('Property','Value',...) creates a new INSPCTISL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inspctisl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inspctisl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inspctisl

% Last Modified by GUIDE v2.5 30-Aug-2011 19:19:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inspctisl_OpeningFcn, ...
                   'gui_OutputFcn',  @inspctisl_OutputFcn, ...
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


% --- Executes just before inspctisl is made visible.
function inspctisl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to inspctisl (see VARARGIN)

% Choose default command line output for inspctisl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes inspctisl wait for user response (see UIRESUME)
% uiwait(handles.inspctisl);


% --- Outputs from this function are returned to the command line.
function varargout = inspctisl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is inspctisl 07/10/2019');

% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

messtext=...
   ['Please load an uncorrected (*unc.dat) file       '
    'from the DATA folder. These files are good       '
    'for inspection for "mice" or noise before signal.'
    'Because data are free of any filter.             '];

uiwait(msgbox(messtext,'Message','warn','modal'));

if ispc
    [file1,path1] = uigetfile('.\data\*unc.dat','Select an uncorrected data file');
else
    [file1,path1] = uigetfile('./data/*unc.dat','Select an uncorrected data file');
end

   lopa = [path1 file1];
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

%this is the sample number not the time....
tim=(1:1:length(time_sec(:,1)));

%prepare time axis
%%%%%%%%%read sampling rate
% srate = str2double(get(handles.sfreq,'String'));
% disp(srate);
% dt=1/srate;
dt=time_sec(2);
%%%%compute sampling freq
sfreq=1/time_sec(2);

set(handles.sfreq,'String',num2str(sfreq));


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
% set(handles.verlabel,'string',[file1(1:3) 'z'])
% set(handles.ewlabel,'string',[file1(1:3) 'e'])
% set(handles.nslabel,'string',[file1(1:3) 'n'])

%% decide if file is *raw , *.unc or something else...
fnd_unc=strfind(file1,'unc');

set(handles.verlabel,'string',[file1(1:fnd_unc-1) ' Z'])
set(handles.ewlabel,'string', [file1(1:fnd_unc-1) ' E'])
set(handles.nslabel,'string', [file1(1:fnd_unc-1) ' N'])

%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ew,'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')
ylabel('Counts')

axes(handles.nsaxis)
plot(time_sec,ns,'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')
ylabel('Counts')

axes(handles.veraxis)
plot(time_sec,ver,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
ylabel('Counts')


% --- Executes on button press in integrate.
function integrate_Callback(hObject, eventdata, handles)
% hObject    handle to integrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%%%%%%%%%%%%%READ DATA FROM HANDLES
%%%%% WE WORK ON 
ew=handles.ew ;
ns=handles.ns ;
ver=handles.ver;
dt=handles.dt
tim=handles.tim;

%prepare new time axis
%%%%%%%%%read sampling rate
time_sec=((tim.*dt)-dt);

ewdetr=detrend(ew);
nsdetr=detrend(ns);
verdetr=detrend(ver);

ewdis=cumtrapz(ewdetr)*dt;
nsdis=cumtrapz(nsdetr)*dt;
verdis=cumtrapz(verdetr)*dt;


%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot Displacement data
axes(handles.ewaxis)
plot(time_sec,ewdis,'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsdis,'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')
% ylabel('Counts')

axes(handles.veraxis)
plot(time_sec,verdis,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')



%%%%%%%%%%%%%find maximum
disp('Maximum values ew,ns,ver')
max(ewdis)
max(nsdis)
max(verdis)



% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.inspctisl)
