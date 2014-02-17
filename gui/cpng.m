function varargout = cpng(varargin)
% CPNG M-file for cpng.fig
%      CPNG, by itself, creates a new CPNG or raises the existing
%      singleton*.
%
%      H = CPNG returns the handle to a new CPNG or the handle to
%      the existing singleton*.
%
%      CPNG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CPNG.M with the given input arguments.
%
%      CPNG('Property','Value',...) creates a new CPNG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cpng_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cpng_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cpng

% Last Modified by GUIDE v2.5 16-Jan-2008 21:33:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cpng_OpeningFcn, ...
                   'gui_OutputFcn',  @cpng_OutputFcn, ...
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


% --- Executes just before cpng is made visible.
function cpng_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cpng (see VARARGIN)

% Choose default command line output for cpng
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cpng wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cpng_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in cpng.
function cpng_Callback(hObject, eventdata, handles)
% hObject    handle to cpng (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    eventagency=fscanf(fid,'%s',1);
    fclose(fid);
end


%%%%%%%%%
eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_wave.png' ];

cd output

print('-f1', '-dpng', eventid)


cd ..

 
% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


close



% --- Executes on button press in ps.
function ps_Callback(hObject, eventdata, handles)
% hObject    handle to ps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    eventagency=fscanf(fid,'%s',1);
    fclose(fid);
end


%%%%%%%%%
eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_wave.ps' ]

cd output

print('-f1', '-dpsc2', eventid)


cd ..


