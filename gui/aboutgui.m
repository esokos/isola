function varargout = aboutgui(varargin)
% ABOUTGUI M-file for aboutgui.fig
%      ABOUTGUI, by itself, creates a new ABOUTGUI or raises the existing
%      singleton*.
%
%      H = ABOUTGUI returns the handle to a new ABOUTGUI or the handle to
%      the existing singleton*.
%
%      ABOUTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ABOUTGUI.M with the given input arguments.
%
%      ABOUTGUI('Property','Value',...) creates a new ABOUTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before aboutgui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to aboutgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help aboutgui

% Last Modified by GUIDE v2.5 26-Jul-2005 12:27:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @aboutgui_OpeningFcn, ...
                   'gui_OutputFcn',  @aboutgui_OutputFcn, ...
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


% --- Executes just before aboutgui is made visible.
function aboutgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to aboutgui (see VARARGIN)

% Choose default command line output for aboutgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes aboutgui wait for user response (see UIRESUME)
% uiwait(handles.aboutgui);


% --- Outputs from this function are returned to the command line.
function varargout = aboutgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Ok.
function Ok_Callback(hObject, eventdata, handles)
% hObject    handle to Ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.aboutgui)
