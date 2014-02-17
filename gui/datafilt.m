function varargout = datafilt(varargin)
% DATAFILT M-file for datafilt.fig
%      DATAFILT, by itself, creates a new DATAFILT or raises the existing
%      singleton*.
%
%      H = DATAFILT returns the handle to a new DATAFILT or the handle to
%      the existing singleton*.
%
%      DATAFILT('Property','Value',...) creates a new DATAFILT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to datafilt_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DATAFILT('CALLBACK') and DATAFILT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DATAFILT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help datafilt

% Last Modified by GUIDE v2.5 03-Jan-2007 23:06:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @datafilt_OpeningFcn, ...
                   'gui_OutputFcn',  @datafilt_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before datafilt is made visible.
function datafilt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

disp('This is datafilt 20/04/08')

% corrected bug with integrate, after restart it kept filter option 23/10/09

% Choose default command line output for datafilt
handles.output = hObject;
handles.ew = 0;
handles.ns = 0;
handles.ver = 0;
handles.ewcur = 0;
handles.nscur = 0;
handles.vercur = 0;
handles.tim=0;
handles.time_sec=0;
handles.dt=0;
handles.file=0;
handles.samfreq=0;

% Update handles structure
guidata(hObject, handles);

% %%% check rawinfo.isl files with event info
% h=dir('rawinfo.isl');
% 
% if length(h) == 0; 
%   errordlg('Rawinfo.isl file doesn''t exist. Run Event info. ','File Error');
%   return
% else
%     fid = fopen('rawinfo.isl','r');
%     rawhour=fscanf(fid,'%g',1);
%     rawmin=fscanf(fid,'%g',1);
%     rawsec=fscanf(fid,'%g',1);
%     fclose(fid);
% end
% 

samfreq=100    %fscanf(fid,'%g',1);

handles.samfreq=samfreq;
handles.dt=1/samfreq;
guidata(hObject,handles)




set(handles.hfreqsec,'String',num2str(1/str2double(get(handles.hfreq,'String')))   )
set(handles.lfreqsec,'String',num2str(1/str2double(get(handles.lfreq,'String')))   )



% off =[handles.integrate,handles.replot,handles.select,handles.fil1,handles.fil2,handles.fil3,handles.fil4,handles.fil5,handles.fil6,handles.fil7];
% enableoff(off)


% UIWAIT makes datafilt wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = datafilt_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(handles.makecor,'Enable','on')

% samfreq=handles.samfreq;
% def{1,1} =num2str(samfreq);

messtext=...
   ['Please select a datafile.                      '
    'This file should be a text file with           '
    'four columns separated by spaces.              '
    'Each column should contain one data channel and'
    'the succession should be time, NS, EW and Z    '];

uiwait(msgbox(messtext,'Message','warn','modal'));

[file1,path1] = uigetfile([ '*.dat'],' Earthquake Datafile',400,400);

   lopa = [path1 file1];
   name = file1
   
   if name == 0
       disp('Cancel file load')
       return
   else
   end

lopa

fid  = fopen(lopa,'r');
[time_sec,ns,ew,ver] = textread(lopa,'%f %f %f %f');
fclose(fid);

whos time_sec ns ew ver
% 
%this is the sample number not the time....
tim=(1:1:length(time_sec(:,1)));

% %%%%%%%%%%
% ni2 = inputdlg('What is the sampling Frequency','Input',1,def);
% l = ni2{1};
% n = str2num(l);
sfreq=1/time_sec(2)
dt=1/sfreq

set(handles.sfreq,'String',num2str(sfreq))

%%%%we  suppose we read velocity
set(handles.datatype,'String','Velocity')


% srate = str2double(get(handles.sfreq,'String'));
%%%

%%% added in order to skip instrument correction 
newsamples=(1:1:max(size(ew)));
handles.newsamples=newsamples;
%%%%

%RAW data to handles 
handles.ew = ew;
handles.ns = ns;
handles.ver=ver;
handles.tim=tim;
handles.time_sec=time_sec;
handles.dt=dt;

%%%following is needed for integration immediately after load 
handles.ewcur = ew;
handles.nscur = ns;
handles.vercur=ver;

handles.file=file1;
guidata(hObject,handles)

%%%%%%%%%%%%%%Update labels of components on graph based on file name
set(handles.verlabel,'string',[file1(1:3) 'z'])
set(handles.ewlabel,'string',[file1(1:3) 'e'])
set(handles.nslabel,'string',[file1(1:3) 'n'])


%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ew,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,ns,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,ver,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('Counts')

% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close



% --- Executes on button press in integrate.
function integrate_Callback(hObject, eventdata, handles)
% hObject    handle to integrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ew=handles.ewcur;
ns=handles.nscur;
ver=handles.vercur;

tim=handles.newsamples;
dtime=handles.dt;
%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);

ewdetr=detrend(ew);
nsdetr=detrend(ns);
verdetr=detrend(ver);

ewdis=cumtrapz(ewdetr)*dtime;
nsdis=cumtrapz(nsdetr)*dtime;
verdis=cumtrapz(verdetr)*dtime;

%Displacement data to handles 
handles.ewdis = ewdis;
handles.nsdis = nsdis;
handles.verdis=verdis;
guidata(hObject,handles)

%%%%we  suppose we read velocity
set(handles.datatype,'String','Displacement','ForegroundColor','blue')

%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot Displacement data
axes(handles.ewaxis)
plot(time_sec,ewdis,'b')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsdis,'b')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,verdis,'b')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
ylabel('m')

disp('Integrating current filter data')

% --- Executes during object creation, after setting all properties.
function sfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function sfreq_Callback(hObject, eventdata, handles)
% hObject    handle to sfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sfreq as text
%        str2double(get(hObject,'String')) returns contents of sfreq as a double


% --- Executes on button press in fil1.
function fil1_Callback(hObject, eventdata, handles)
% hObject    handle to fil1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% c = input time series 
% flp = lowpass corner frequency of filter 
% fhi = hipass corner frequency 
% npts = samples in data 
% delt = sampling interval of data 


ew=handles.ew ;
ns=handles.ns;
ver=handles.ver;
tim=handles.newsamples;
dtime=handles.dt;
%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);

nptsew=length(ew);
ewf=bandpass(ew,1,5,nptsew,dtime);
nptsns=length(ns);
nsf=bandpass(ns,1,5,nptsns,dtime);
nptsver=length(ver);
verf=bandpass(ver,1,5,nptsver,dtime);

handles.ewcur = ewf;
handles.nscur = nsf;
handles.vercur=verf;
guidata(hObject,handles)

set(handles.datatype,'String','Velocity','ForegroundColor','Red')


disp('Filtering 1 - 5 Hz')


%%%%%%%%%%%%%%%%%%PLOT filtered  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ewf,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsf,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,verf,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('m/sec')


% 
% function [d]=bandpass(c,flp,fhi,npts,delt) 
% % 
% % [d]=bandpass(c,flp) 
% % 
% % bandpass a time series with a 8th order butterworth filter 
% % 
% % c = input time series 
% % flp = lowpass corner frequency of filter 
% % fhi = hipass corner frequency 
% % npts = samples in data 
% % delt = sampling interval of data 
% % 
% n=2;      % 2nd order butterworth filter 
% fnq=1/(2*delt);  % Nyquist frequency 
% Wn=[flp/fnq fhi/fnq];    % butterworth bandpass non-dimensional frequency 
% [b,a]=butter(n,Wn); % construct the filter 
% d=filtfilt(b,a,c); % zero phase filter the data 
% return;


% --- Executes on button press in replot.
function replot_Callback(hObject, eventdata, handles)
% hObject    handle to replot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ew=handles.ew;
ns=handles.ns;
ver=handles.ver;
tim=handles.newsamples;
dtime=handles.dt;

%%%following is needed for integration immediately after load 
handles.ewcur = ew;
handles.nscur = ns;
handles.vercur=ver;
guidata(hObject,handles)

%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);


set(handles.datatype,'String','Velocity','ForegroundColor','Red')


%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ew,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,ns,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,ver,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('m/sec')


% --- Executes on button press in fil2.
function fil2_Callback(hObject, eventdata, handles)
% hObject    handle to fil2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ew=handles.ew ;
ns=handles.ns;
ver=handles.ver;
tim=handles.newsamples;
dtime=handles.dt;
%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);

nptsew=length(ew);
ewf=bandpass(ew,0.2,1,nptsew,dtime);
nptsns=length(ns);
nsf=bandpass(ns,0.2,1,nptsns,dtime);
nptsver=length(ver);
verf=bandpass(ver,0.2,1,nptsver,dtime);

handles.ewcur = ewf;
handles.nscur = nsf;
handles.vercur=verf;
guidata(hObject,handles)

set(handles.datatype,'String','Velocity','ForegroundColor','Red')


disp('Filtering 0.2 - 1 Hz')


%%%%%%%%%%%%%%%%%%PLOT filtered  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ewf,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsf,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,verf,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('m/sec')



% --- Executes on button press in fil3.
function fil3_Callback(hObject, eventdata, handles)
% hObject    handle to fil3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ew=handles.ew ;
ns=handles.ns;
ver=handles.ver;
tim=handles.newsamples;
dtime=handles.dt;
%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);

nptsew=length(ew);
ewf=bandpass(ew,0.08,0.2,nptsew,dtime);
nptsns=length(ns);
nsf=bandpass(ns,0.08,0.2,nptsns,dtime);
nptsver=length(ver);
verf=bandpass(ver,0.08,0.2,nptsver,dtime);

handles.ewcur = ewf;
handles.nscur = nsf;
handles.vercur=verf;
guidata(hObject,handles)

set(handles.datatype,'String','Velocity','ForegroundColor','Red')


disp('Filtering 0.08 - 0.2 Hz')

%%%%%%%%%%%%%%%%%%PLOT filtered  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ewf,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsf,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,verf,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('m/sec')


% --- Executes on button press in fil4.
function fil4_Callback(hObject, eventdata, handles)
% hObject    handle to fil4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ew=handles.ew ;
ns=handles.ns;
ver=handles.ver;
tim=handles.newsamples;
dtime=handles.dt;
%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);

nptsew=length(ew);
ewf=bandpass(ew,0.06,0.08,nptsew,dtime);
nptsns=length(ns);
nsf=bandpass(ns,0.06,0.08,nptsns,dtime);
nptsver=length(ver);
verf=bandpass(ver,0.06,0.08,nptsver,dtime);

handles.ewcur = ewf;
handles.nscur = nsf;
handles.vercur=verf;
guidata(hObject,handles)

set(handles.datatype,'String','Velocity','ForegroundColor','Red')

disp('Filtering 0.06 - 0.08 Hz')


%%%%%%%%%%%%%%%%%%PLOT filtered  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ewf,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsf,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,verf,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('m/sec')




% --- Executes on button press in fil5.
function fil5_Callback(hObject, eventdata, handles)
% hObject    handle to fil5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ew=handles.ew ;
ns=handles.ns;
ver=handles.ver;
tim=handles.newsamples;
dtime=handles.dt;
%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);

nptsew=length(ew);
ewf=bandpass(ew,0.05,0.07,nptsew,dtime);
nptsns=length(ns);
nsf=bandpass(ns,0.05,0.07,nptsns,dtime);
nptsver=length(ver);
verf=bandpass(ver,0.05,0.07,nptsver,dtime);

handles.ewcur = ewf;
handles.nscur = nsf;
handles.vercur=verf;
guidata(hObject,handles)

set(handles.datatype,'String','Velocity','ForegroundColor','Red')

disp('Filtering 0.05 - 0.07 Hz')


%%%%%%%%%%%%%%%%%%PLOT filtered  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ewf,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsf,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,verf,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('m/sec')



% --- Executes on button press in fil6.
function fil6_Callback(hObject, eventdata, handles)
% hObject    handle to fil6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ew=handles.ew ;
ns=handles.ns;
ver=handles.ver;
tim=handles.newsamples;
dtime=handles.dt;
%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);

nptsew=length(ew);
ewf=bandpass(ew,0.03,0.06,nptsew,dtime);
nptsns=length(ns);
nsf=bandpass(ns,0.03,0.06,nptsns,dtime);
nptsver=length(ver);
verf=bandpass(ver,0.03,0.06,nptsver,dtime);

handles.ewcur = ewf;
handles.nscur = nsf;
handles.vercur=verf;
guidata(hObject,handles)

set(handles.datatype,'String','Velocity','ForegroundColor','Red')

disp('Filtering 0.03 - 0.06 Hz')


%%%%%%%%%%%%%%%%%%PLOT filtered  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ewf,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsf,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,verf,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('m/sec')


% --- Executes on button press in fil7.
function fil7_Callback(hObject, eventdata, handles)
% hObject    handle to fil7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ew=handles.ew ;
ns=handles.ns;
ver=handles.ver;
tim=handles.newsamples;
dtime=handles.dt;
%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);

nptsew=length(ew);
ewf=bandpass(ew,0.01,0.03,nptsew,dtime);
nptsns=length(ns);
nsf=bandpass(ns,0.01,0.03,nptsns,dtime);
nptsver=length(ver);
verf=bandpass(ver,0.01,0.03,nptsver,dtime);

handles.ewcur = ewf;
handles.nscur = nsf;
handles.vercur=verf;
guidata(hObject,handles)

set(handles.datatype,'String','Velocity','ForegroundColor','Red')

disp('Filtering 0.01 - 0.03 Hz')


%%%%%%%%%%%%%%%%%%PLOT filtered  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ewf,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsf,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,verf,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('m/sec')


% --- Executes during object creation, after setting all properties.
function lfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lfreq_Callback(hObject, eventdata, handles)
% hObject    handle to lfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lfreq as text
%        str2double(get(hObject,'String')) returns contents of lfreq as a double

set(handles.lfreqsec,'String',num2str(1/str2double(get(handles.lfreq,'String')))   )



% --- Executes during object creation, after setting all properties.
function hfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function hfreq_Callback(hObject, eventdata, handles)
% hObject    handle to hfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hfreq as text
%        str2double(get(hObject,'String')) returns contents of hfreq as a double

set(handles.hfreqsec,'String',num2str(1/str2double(get(handles.hfreq,'String')))   )



% --- Executes on button press in select.
function select_Callback(hObject, eventdata, handles)
% hObject    handle to select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ew=handles.ew ;
ns=handles.ns;
ver=handles.ver;
tim=handles.newsamples;
dtime=handles.dt;
%prepare time axis in sec
time_sec=((tim.*dtime)-dtime);

lowfreq = str2double(get(handles.lfreq,'String'));
highfreq = str2double(get(handles.hfreq,'String'));

nptsew=length(ew);
ewf=bandpass(ew,lowfreq,highfreq,nptsew,dtime);
nptsns=length(ns);
nsf=bandpass(ns,lowfreq,highfreq,nptsns,dtime);
nptsver=length(ver);
verf=bandpass(ver,lowfreq,highfreq,nptsver,dtime);

handles.ewcur = ewf;
handles.nscur = nsf;
handles.vercur=verf;
guidata(hObject,handles)

set(handles.datatype,'String','Velocity','ForegroundColor','Red')


disp(['Filtering ' get(handles.lfreq,'String') '  -  '  get(handles.hfreq,'String') ' Hz'])


%%%%%%%%%%%%%%%%%%PLOT filtered  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ewf,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,nsf,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,verf,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
%ylabel('m/sec')





function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')


% --- Executes during object creation, after setting all properties.
function hcut1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hcut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function hcut1_Callback(hObject, eventdata, handles)
% hObject    handle to hcut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hcut1 as text
%        str2double(get(hObject,'String')) returns contents of hcut1 as a double


% --- Executes during object creation, after setting all properties.
function lcut2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lcut2_Callback(hObject, eventdata, handles)
% hObject    handle to lcut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcut2 as text
%        str2double(get(hObject,'String')) returns contents of lcut2 as a double


% --- Executes during object creation, after setting all properties.
function lfreqsec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lfreqsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lfreqsec_Callback(hObject, eventdata, handles)
% hObject    handle to lfreqsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lfreqsec as text
%        str2double(get(hObject,'String')) returns contents of lfreqsec as a double


% --- Executes during object creation, after setting all properties.
function hfreqsec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hfreqsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function hfreqsec_Callback(hObject, eventdata, handles)
% hObject    handle to hfreqsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hfreqsec as text
%        str2double(get(hObject,'String')) returns contents of hfreqsec as a double


