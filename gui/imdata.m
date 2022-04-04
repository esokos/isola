function varargout = imdata(varargin)
% IMDATA M-file for imdata.fig
%      IMDATA, by itself, creates a new IMDATA or raises the existing
%      singleton*.
%
%      H = IMDATA returns the handle to a new IMDATA or the handle to
%      the existing singleton*.
%
%      IMDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMDATA.M with the given input arguments.
%
%      IMDATA('Property','Value',...) creates a new IMDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imdata_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imdata_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imdata

% Last Modified by GUIDE v2.5 10-Nov-2020 10:49:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imdata_OpeningFcn, ...
                   'gui_OutputFcn',  @imdata_OutputFcn, ...
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


% --- Executes just before imdata is made visible.
function imdata_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imdata (see VARARGIN)

% Choose default command line output for imdata
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imdata wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imdata_OutputFcn(hObject, eventdata, handles) 
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
disp('Calling autosac import')

autosacimport

% --- Executes on button press in manualsac.
function manualsac_Callback(hObject, eventdata, handles)
% hObject    handle to manualsac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Calling manual sac import')

sacimport

% --- Executes on button press in seisan.
function seisan_Callback(hObject, eventdata, handles)
% hObject    handle to seisan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Calling seisan import')

seisanimport

% --- Executes on button press in guralp.
function guralp_Callback(hObject, eventdata, handles)
% hObject    handle to guralp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Calling guralp GCF import')

gcfimport

% --- Executes on button press in pitsa.
function pitsa_Callback(hObject, eventdata, handles)
% hObject    handle to pitsa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Calling PITSA import')

pitsaimport


% --- Executes on button press in mseed.
function mseed_Callback(hObject, eventdata, handles)
% hObject    handle to mseed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mseedimport
disp('BE CAREFUL this is new, not tested much !!')

