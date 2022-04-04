function varargout = seltimfun(varargin)
% SELTIMFUN M-file for seltimfun.fig
%      SELTIMFUN, by itself, creates a new SELTIMFUN or raises the existing
%      singleton*.
%
%      H = SELTIMFUN returns the handle to a new SELTIMFUN or the handle to
%      the existing singleton*.
%
%      SELTIMFUN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELTIMFUN.M with the given input arguments.
%
%      SELTIMFUN('Property','Value',...) creates a new SELTIMFUN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before seltimfun_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to seltimfun_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help seltimfun

% Last Modified by GUIDE v2.5 18-May-2016 09:39:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @seltimfun_OpeningFcn, ...
                   'gui_OutputFcn',  @seltimfun_OutputFcn, ...
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


% --- Executes just before seltimfun is made visible.
function seltimfun_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to seltimfun (see VARARGIN)

% Choose default command line output for seltimfun
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes seltimfun wait for user response (see UIRESUME)
% uiwait(handles.seltimfun);


% --- Outputs from this function are returned to the command line.
function varargout = seltimfun_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in sinsource.
function sinsource_Callback(hObject, eventdata, handles)
% hObject    handle to sinsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Calling timefun')
timefun
close seltimfun


% --- Executes on button press in twosource.
function twosource_Callback(hObject, eventdata, handles)
% hObject    handle to twosource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Calling timefun_twop')
timefun_twop
close seltimfun
