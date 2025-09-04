function varargout = readmseed(varargin)
% READMSEED M-file for readmseed.fig
%      READMSEED, by itself, creates a new READMSEED or raises the existing
%      singleton*.
%
%      H = READMSEED returns the handle to a new READMSEED or the handle to
%      the existing singleton*.
%
%      READMSEED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in READMSEED.M with the given input arguments.
%
%      READMSEED('Property','Value',...) creates a new READMSEED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before readmseed_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to readmseed_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help readmseed

% Last Modified by GUIDE v2.5 18-May-2016 21:55:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @readmseed_OpeningFcn, ...
                   'gui_OutputFcn',  @readmseed_OutputFcn, ...
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


% --- Executes just before readmseed is made visible.
function readmseed_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to readmseed (see VARARGIN)

% Choose default command line output for readmseed
handles.output = hObject;

% Update handles structure
%%%raw data 
handles.ew = 0;
handles.ns = 0;
handles.ver = 0;

mainpath=pwd;
path1=pwd;

handles.path1=path1;
handles.mainpath=mainpath;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes readmseed wait for user response (see UIRESUME)
% uiwait(handles.readmseed);


% --- Outputs from this function are returned to the command line.
function varargout = readmseed_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in readns.
function readns_Callback(hObject, eventdata, handles)
% hObject    handle to readns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
path1=handles.path1;
mainpath=handles.mainpath;
% check if raw folder exists
h=dir('raw');

if isempty(h);
      cd(path1)
      datapath=pwd;
else
     if ispc
        cd([path1 '\raw'])
     else
        cd([path1 '/raw'])
     end
      
      datapath=pwd;
end
%%
%%
[file1,path1] = uigetfile('*.mseed','Import miniseed file');
   lopa = [path1 file1]; 
        
          try 
              [X,I] = rdmseed(lopa);
              
              
          catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
          return
          end
          
cd(mainpath)
%%
%t = cat(1,X.t);
d = cat(1,X.d);

X.StationIdentifierCode;
srate=X.SampleRate;
chanelID=X.ChannelIdentifier
X.ChannelFullName;
nsam=X.NumberSamples;
X.RecordStartTimeISO
%char(I.ChannelFullName)

whos

dt=1/srate;
tim=(1:1:length(d));
time_sec=((tim.*dt)-dt);

size(d)

axes(handles.nsaxis)
plot(time_sec,d,'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')
xlabel('Time (sec)')
ylabel('Counts')



% --- Executes on button press in readew.
function readew_Callback(hObject, eventdata, handles)
% hObject    handle to readew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in readver.
function readver_Callback(hObject, eventdata, handles)
% hObject    handle to readver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
