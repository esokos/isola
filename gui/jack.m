function varargout = jack(varargin)
% JACK M-file for jack.fig
%      JACK, by itself, creates a new JACK or raises the existing
%      singleton*.
%
%      H = JACK returns the handle to a new JACK or the handle to
%      the existing singleton*.
%
%      JACK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JACK.M with the given input arguments.
%
%      JACK('Property','Value',...) creates a new JACK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jack_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jack_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jack

% Last Modified by GUIDE v2.5 29-Aug-2013 22:56:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jack_OpeningFcn, ...
                   'gui_OutputFcn',  @jack_OutputFcn, ...
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


% --- Executes just before jack is made visible.
function jack_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jack (see VARARGIN)

% Choose default command line output for jack
handles.output = hObject;


disp('This is Jack 29/08/2013. Not for Linux yet')


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jack wait for user response (see UIRESUME)
% uiwait(handles.jack);


% --- Outputs from this function are returned to the command line.
function varargout = jack_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in jacksta.
function jacksta_Callback(hObject, eventdata, handles)
% hObject    handle to jacksta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
jackstations

% --- Executes on button press in jackcomp.
function jackcomp_Callback(hObject, eventdata, handles)
% hObject    handle to jackcomp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

jackn

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.jack)


% --- Executes on button press in plstares.
function plstares_Callback(hObject, eventdata, handles)
% hObject    handle to plstares (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strref=str2num(get(handles.str,'String'));
dipref=str2num(get(handles.dip,'String'));
rakeref=str2num(get(handles.rake,'String'));

% run the plotting code
result=plotjackres_stations(strref,dipref,rakeref);


% --- Executes on button press in plcompres.
function plcompres_Callback(hObject, eventdata, handles)
% hObject    handle to plcompres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

strref=str2num(get(handles.str,'String'));
dipref=str2num(get(handles.dip,'String'));
rakeref=str2num(get(handles.rake,'String'));

% run the plotting code
result=plotjackrescomp_all(strref,dipref,rakeref);

function str_Callback(hObject, eventdata, handles)
% hObject    handle to str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of str as text
%        str2double(get(hObject,'String')) returns contents of str as a double


% --- Executes during object creation, after setting all properties.
function str_CreateFcn(hObject, eventdata, handles)
% hObject    handle to str (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip_Callback(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip as text
%        str2double(get(hObject,'String')) returns contents of dip as a double


% --- Executes during object creation, after setting all properties.
function dip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rake_Callback(hObject, eventdata, handles)
% hObject    handle to rake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake as text
%        str2double(get(hObject,'String')) returns contents of rake as a double


% --- Executes during object creation, after setting all properties.
function rake_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
