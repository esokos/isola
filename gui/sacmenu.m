function varargout = sacmenu(varargin)
% SACMENU M-file for sacmenu.fig
%      SACMENU, by itself, creates a new SACMENU or raises the existing
%      singleton*.
%
%      H = SACMENU returns the handle to a new SACMENU or the handle to
%      the existing singleton*.
%
%      SACMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SACMENU.M with the given input arguments.
%
%      SACMENU('Property','Value',...) creates a new SACMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sacmenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sacmenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sacmenu

% Last Modified by GUIDE v2.5 30-Nov-2008 13:26:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sacmenu_OpeningFcn, ...
                   'gui_OutputFcn',  @sacmenu_OutputFcn, ...
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


% --- Executes just before sacmenu is made visible.
function sacmenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sacmenu (see VARARGIN)

% Choose default command line output for sacmenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sacmenu wait for user response (see UIRESUME)
% uiwait(handles.sacmenu);


% --- Outputs from this function are returned to the command line.
function varargout = sacmenu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in autosac.
function autosac_Callback(hObject, eventdata, handles)
% hObject    handle to autosac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('SACMENU is  Calling autosacimport')

autosacimport

delete(handles.sacmenu)

% --- Executes on button press in manualsac.
function manualsac_Callback(hObject, eventdata, handles)
% hObject    handle to manualsac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


disp('SACMENU is Calling Sacimport')

sacimport

delete(handles.sacmenu)
