function varargout = selunc(varargin)
% SELUNC M-file for selunc.fig
%      SELUNC, by itself, creates a new SELUNC or raises the existing
%      singleton*.
%
%      H = SELUNC returns the handle to a new SELUNC or the handle to
%      the existing singleton*.
%
%      SELUNC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELUNC.M with the given input arguments.
%
%      SELUNC('Property','Value',...) creates a new SELUNC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selunc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selunc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selunc

% Last Modified by GUIDE v2.5 26-Jan-2017 19:46:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @selunc_OpeningFcn, ...
                   'gui_OutputFcn',  @selunc_OutputFcn, ...
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


% --- Executes just before selunc is made visible.
function selunc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selunc (see VARARGIN)

% Choose default command line output for selunc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes selunc wait for user response (see UIRESUME)
% uiwait(handles.selunc);


% --- Outputs from this function are returned to the command line.
function varargout = selunc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in single.
function single_Callback(hObject, eventdata, handles)
% hObject    handle to single (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


disp('Running single source uncertainty estimation code.')

comp_uncert

delete(selunc)


% --- Executes on button press in mapunc.
function mapunc_Callback(hObject, eventdata, handles)
% hObject    handle to mapunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


disp('Running mapping uncertainty code.')

uncmaps


delete(selunc)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Running uncertainty tool for DC, ISO and nodal lines for all trial sources.')

newunc

delete(selunc)
