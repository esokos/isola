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


disp('This is Jack 29/08/2015.')



%%

h=dir('tsources.isl');

if isempty(h); 
    errordlg('tsources.isl file doesn''t exist. Run Source create. ','File Error');
  return    
else
    fid = fopen('tsources.isl','r');
    tsource=fscanf(fid,'%s',1)
    
     if strcmp(tsource,'line')
        disp('Inversion was done for a line of sources.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
          
        conplane=2;   %%% Line
        % dummy sdepth
        sdepth=-333;
        % Update handles structure
        guidata(hObject, handles);
        
     elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        
         conplane=0;   %%%depth

         handles.sdepth=sdepth;
         % Update handles structure
         guidata(hObject, handles);
    
     elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
           noSourcesstrike=fscanf(fid,'%i',1)
           strikestep=fscanf(fid,'%f',1)
           noSourcesdip=fscanf(fid,'%i',1)
           dipstep=fscanf(fid,'%f',1)
%           nsources=noSourcesstrike*noSourcesdip;
          
           invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
      
           conplane=1;
           
           %% dummy sdepth
           sdepth=-333;
            distep=-333;
            
           %%%%%%%%%%%%%%%%%write to handles
           handles.noSourcesstrike=noSourcesstrike;
           handles.strikestep=strikestep;
           handles.noSourcesdip=noSourcesdip;
           handles.dipstep=dipstep;
           % Update handles structure
           guidata(hObject, handles);
           
     elseif strcmp(tsource,'point')
       disp('Inversion was done for one source.')
       nsources=fscanf(fid,'%i',1);
       distep=fscanf(fid,'%f',1);
       sdepth=fscanf(fid,'%f',1);
       invtype=fscanf(fid,'%c');
        

        conplane=3;
        % Update handles structure
        guidata(hObject, handles);
       
     end
     
          fclose(fid);
          
end

%% learn which is the reference mechanism from inv1.dat

cd invert

[~,~,~,~,~,~,~,inv1_sdr1,inv1_sdr2,~]=readinv1(nsources,1);

set(handles.str,'String',num2str(inv1_sdr1(1)))
set(handles.dip,'String',num2str(inv1_sdr1(2)))
set(handles.rake,'String',num2str(inv1_sdr1(3)))

cd ..

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

disp('Numeric results available in .\invert\jackresults\allinv2.dat file')

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

disp('Numeric results available in .\invert\jackresults\allinv2.dat file')

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
