function varargout = ftest(varargin)
% FTEST M-file for ftest.fig
%      FTEST, by itself, creates a new FTEST or raises the existing
%      singleton*.
%
%      H = FTEST returns the handle to a new FTEST or the handle to
%      the existing singleton*.
%
%      FTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FTEST.M with the given input arguments.
%
%      FTEST('Property','Value',...) creates a new FTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ftest_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ftest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ftest

% Last Modified by GUIDE v2.5 29-Sep-2008 11:25:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ftest_OpeningFcn, ...
                   'gui_OutputFcn',  @ftest_OutputFcn, ...
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


% --- Executes just before ftest is made visible.
function ftest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ftest (see VARARGIN)

% Choose default command line output for ftest
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ftest wait for user response (see UIRESUME)
% uiwait(handles.ftest);


% --- Outputs from this function are returned to the command line.
function varargout = ftest_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is Ftest 29/09/08');

% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if INVERT exists..!
h=dir('invert');

if length(h) == 0;
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% go in invert 

cd invert

pwd

h=dir('inv1.dat');

if length(h) == 0; 
    errordlg('inv1.dat file doesn''t exist. Run Invert. ','File Error');
    cd ..
  return    
else

    allvarred=findsubvarred('inv1.dat');
end

%%%read parameters
dof=str2num(get(handles.dof,'String'));
cpointstmp=get(handles.limits,'String');

% length(cpointstmp)
% size(cpointstmp)
% 
% whos cpointstmp

for i=1:length(cpointstmp)
    cpoints(i)=str2num(cpointstmp{i,1});
end
 
% whos cpoints 

%%%%%%%%

%%%calculate
Fcrit=finv(cpoints,dof,dof);

if length(allvarred)==1
    disp('Found only one subevent. F-test cannot be applied')
else
    disp(['Found  ' num2str(length(allvarred)) '  subevents' ])
    
%     bar(allvarred)
    
    for i=1:length(allvarred)-1
                F(i)=(1-allvarred(i))/(1-allvarred(i+1));
        %%%% compare F with Fcrit
            for j=1:length(Fcrit)
                switch  (F(i) < Fcrit(j))
                    case 1
                        disp(['Variance Ratio subevent ' num2str(i) '/' num2str(i+1) ' is smaller '  num2str(F(i)) ' than Fcrit value ' num2str(Fcrit(j)) ' at '  num2str(cpoints(j)*100) '%  level. Not Significant change.'] )
                    case 0
                        disp(['Variance Ratio subevent ' num2str(i) '/' num2str(i+1) ' is larger  '  num2str(F(i)) ' than Fcrit value ' num2str(Fcrit(j)) ' at '  num2str(cpoints(j)*100) '% level. Significant change.'   ])
                    otherwise
                        disp('Equal...! ')
                end
            end
             disp('         ')
    end
    
end

%%% go out of invert
cd ..
pwd


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.ftest)

% --- Executes during object creation, after setting all properties.
function dof_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dof (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dof_Callback(hObject, eventdata, handles)
% hObject    handle to dof (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dof as text
%        str2double(get(hObject,'String')) returns contents of dof as a double


% --- Executes during object creation, after setting all properties.
function limits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in limits.
function limits_Callback(hObject, eventdata, handles)
% hObject    handle to limits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns limits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from limits


