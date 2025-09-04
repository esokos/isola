function varargout = bootstrapgui(varargin)
% BOOTSTRAPGUI MATLAB code for bootstrapgui.fig
%      BOOTSTRAPGUI, by itself, creates a new BOOTSTRAPGUI or raises the existing
%      singleton*.
%
%      H = BOOTSTRAPGUI returns the handle to a new BOOTSTRAPGUI or the handle to
%      the existing singleton*.
%
%      BOOTSTRAPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BOOTSTRAPGUI.M with the given input arguments.
%
%      BOOTSTRAPGUI('Property','Value',...) creates a new BOOTSTRAPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bootstrapgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bootstrapgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bootstrapgui

% Last Modified by GUIDE v2.5 14-Mar-2025 13:23:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bootstrapgui_OpeningFcn, ...
                   'gui_OutputFcn',  @bootstrapgui_OutputFcn, ...
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


% --- Executes just before bootstrapgui is made visible.
function bootstrapgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bootstrapgui (see VARARGIN)

% Choose default command line output for bootstrapgui
handles.output = hObject;
%%
disp('This is bootstrapgui 04/03/2025');
h=dir('stations.isl');

pwd
%%
h=dir('invert');

if isempty(h)
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%
if isempty(h)
    errordlg('Stations.isl file doesn''t exist. Run Station select. ','File Error');
  return  
else
    fid = fopen('stations.isl','r');
    nsta=fscanf(fid,'%i',1);
    fclose(fid);
end

set(handles.nstations,'String',num2str(nsta));

%% 
h=dir('tsources.isl');

if isempty(h)
    errordlg('tsources.isl file doesn''t exist. Run Source create. ','File Error');
  return    
else
    fid = fopen('tsources.isl','r');
    tsource=fscanf(fid,'%s',1);
    
     if strcmp(tsource,'line')
        disp('Inversion was done for a line of sources.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        conplane=2;   %  Line
     elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.') % this will be our ONLY choice (for) now!!
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        conplane=0;   % depth
     elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
        noSourcesstrike=fscanf(fid,'%i',1);
        strikestep=fscanf(fid,'%f',1);
        noSourcesdip=fscanf(fid,'%i',1);
        dipstep=fscanf(fid,'%f',1);
        invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
        conplane=1;
        %  dummy sdepth
        sdepth=-333;
        distep=-333;
     elseif  strcmp(tsource,'3Dplane')
        disp('Inversion was done for 3 horizontal plane of sources.')
        nsources=fscanf(fid,'%i',1);
        noSourcesstrike=fscanf(fid,'%i',1);
        strikestep=fscanf(fid,'%f',1);
        noSourcesdip=fscanf(fid,'%i',1);
        dipstep=strikestep;
        depthstep=fscanf(fid,'%i',1);
        invtype='   Sources on 3 horizontal planes ';
        conplane=4;
        %  dummy sdepth
        sdepth=-333;
        distep=-333;
     elseif strcmp(tsource,'point')
       disp('Inversion was done for one source.')
       nsources=fscanf(fid,'%i',1);
       distep=fscanf(fid,'%f',1);
       sdepth=fscanf(fid,'%f',1);
       invtype=fscanf(fid,'%c');
       conplane=3;
     end
          fclose(fid);
end

set(handles.fsource,'String','1');
set(handles.lsource,'String',num2str(nsources));

%if conplane ==1  ||  conplane ==4
%  set(handles.stepsource,'String','1');
%else
   set(handles.stepsource,'String','1');  % positions are represented by numbers of trial points not depth !!
%end

% if conplane~=0
%     disp('Sorry this trial source geometry is not supported. Only source under epicenter for now')
% else
% end
%%
h=dir('duration.isl');

if isempty(h) 
  errordlg('Duration.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('duration.isl','r');
    tl=fscanf(fid,'%g',1);
    fclose(fid);
end

%% find Time search limits from inpinv
if ispc
   [~,tstep,~,tshifts,~,~,~] = readinpinv('.\invert\inpinv.dat');
else
   [~,tstep,~,tshifts,~,~,~] = readinpinv('./invert/inpinv.dat');   
end

set(handles.starttime,'String',num2str(tshifts(1)*tstep));
set(handles.endtime,  'String',num2str(tshifts(3)*tstep));

%% read ISOLA defaults
[~,~,npts,~,~] = readisolacfg;
dtres=tl/npts;

set(handles.dtvalue,'String',num2str(dtres));

%%
handles.nstations=nsta;
handles.nsources=nsources;
handles.distep=distep;
handles.sdepth=sdepth;
%handles.dtvalue=dtres;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bootstrapgui wait for user response (see UIRESUME)
% uiwait(handles.bootstrapgui);


% --- Outputs from this function are returned to the command line.
function varargout = bootstrapgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function nperturb_Callback(hObject, eventdata, handles)
% hObject    handle to nperturb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nperturb as text
%        str2double(get(hObject,'String')) returns contents of nperturb as a double


% --- Executes during object creation, after setting all properties.
function nperturb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nperturb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calc.
function calc_Callback(hObject, eventdata, handles)
% hObject    handle to calc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nstations=handles.nstations;
ncomp=nstations*3;

nper=str2double(get(handles.nperturb,'String'));
ismin=str2double(get(handles.fsource,'String')); ismax=str2double(get(handles.lsource,'String')); isstep=str2double(get(handles.stepsource,'String'));
shiftMIN=str2double(get(handles.starttime,'String')); shiftMAX=str2double(get(handles.endtime,'String')); dt=str2double(get(handles.dtvalue,'String'));

%%
cd invert

%% my_baboo_weig
% ncomp .... number of components (number of stations times 3) 
% nsets .... number of perturbations
my_baboo_weig(ncomp,nper)

% prepare an input file for isorand_main.stations
   fid = fopen('isorandinp.inp','w');
      fprintf(fid,'%s\r\n','number of perturbations');
      fprintf(fid,'%u\r\n',nper);
      fprintf(fid,'%s\r\n','first position no., last position, step');
      fprintf(fid,'%u %u %u\r\n',ismin,ismax,isstep);
      fprintf(fid,'%s\r\n','time (relative to OT, in seconds) first time, last time, time  step ');
      fprintf(fid,'%f %f %f\r\n',shiftMIN,shiftMAX,dt);
   fclose(fid);

  delete('done.tmp')

% make a batch file for fortan codes
   fid = fopen('runboot.bat','w');
        fprintf(fid,'%s\r\n','isorand_main_gui.exe');
        fprintf(fid,'%s\r\n','    ');
        fprintf(fid,'%s\r\n','isorand_postproc_gui.exe');
        fprintf(fid,'%s\r\n','done.exe');
   fclose(fid);
  

% run the fortran code...
   if ispc
      system('runboot.bat &')
   else
   end
                   %  wait here for fortran part to end
                   done = 0;
                   hmsg= msgbox("Waiting for fortran code to end","Please wait","help");
                   while done==0
                      done = FileExist('done.tmp');
                   end
                   disp('         ');disp('Fortran invert code finished.');disp('         ')
                   % close info window
                   delete(hmsg)

%%
mkdir boo_plots
my_boo_plots



cd ..


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.bootstrapgui)

function fsource_Callback(hObject, eventdata, handles)
% hObject    handle to fsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fsource as text
%        str2double(get(hObject,'String')) returns contents of fsource as a double


% --- Executes during object creation, after setting all properties.
function fsource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lsource_Callback(hObject, eventdata, handles)
% hObject    handle to lsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lsource as text
%        str2double(get(hObject,'String')) returns contents of lsource as a double


% --- Executes during object creation, after setting all properties.
function lsource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stepsource_Callback(hObject, eventdata, handles)
% hObject    handle to stepsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepsource as text
%        str2double(get(hObject,'String')) returns contents of stepsource as a double


% --- Executes during object creation, after setting all properties.
function stepsource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepsource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function starttime_Callback(hObject, eventdata, handles)
% hObject    handle to starttime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of starttime as text
%        str2double(get(hObject,'String')) returns contents of starttime as a double


% --- Executes during object creation, after setting all properties.
function starttime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function endtime_Callback(hObject, eventdata, handles)
% hObject    handle to endtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endtime as text
%        str2double(get(hObject,'String')) returns contents of endtime as a double


% --- Executes during object creation, after setting all properties.
function endtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
