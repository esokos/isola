function varargout = checknoisespectrum(varargin)
% CHECKNOISESPECTRUM M-file for checknoisespectrum.fig
%      CHECKNOISESPECTRUM, by itself, creates a new CHECKNOISESPECTRUM or raises the existing
%      singleton*.
%
%      H = CHECKNOISESPECTRUM returns the handle to a new CHECKNOISESPECTRUM or the handle to
%      the existing singleton*.
%
%      CHECKNOISESPECTRUM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECKNOISESPECTRUM.M with the given input arguments.
%
%      CHECKNOISESPECTRUM('Property','Value',...) creates a new CHECKNOISESPECTRUM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before checknoisespectrum_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to checknoisespectrum_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help checknoisespectrum

% Last Modified by GUIDE v2.5 05-Nov-2012 12:11:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @checknoisespectrum_OpeningFcn, ...
                   'gui_OutputFcn',  @checknoisespectrum_OutputFcn, ...
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


% --- Executes just before checknoisespectrum is made visible.
function checknoisespectrum_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to checknoisespectrum (see VARARGIN)

% Choose default command line output for checknoisespectrum
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes checknoisespectrum wait for user response (see UIRESUME)
% uiwait(handles.checknoisespectrum);


% --- Outputs from this function are returned to the command line.
function varargout = checknoisespectrum_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% messtext=...
%    ['Please select a datafile.                      '
%     'This file should be a text file with           '
%     'four columns separated by spaces.              '
%     'Each column should contain one data channel and'
%     'the succession should be time, NS, EW and Z    '];


messtext=...
   ['Please load an uncorrected (*unc.dat) file         '
    'from the DATA folder. These files are good         '
    'for inspection of SNR because they have enough data'
    'before signal onset.                               '];

uiwait(msgbox(messtext,'Message','warn','modal'));

if ispc
    [file1,path1] = uigetfile('.\data\*unc.dat','Select an uncorrected data file');
else
    [file1,path1] = uigetfile('./data/*unc.dat','Select an uncorrected data file');
end

%[file1,path1] = uigetfile([ '*.dat'],' Earthquake Datafile');

   lopa = [path1 file1];
   name = file1;
   
      if name == 0
       disp('Cancel file load')
       return
   else
   end

lopa;
% 
fid  = fopen(lopa,'r');
[time_sec,ns,ew,ver] = textread(lopa,'%f %f %f %f');
fclose(fid);

% whos time_sec ns ew ver

%this is the sample number not the time....
tim=(1:1:length(time_sec(:,1)));

%prepare time axis
%%%%%%%%%read sampling rate
% srate = str2double(get(handles.sfreq,'String'));
% disp(srate);
% dt=1/srate;
dt=time_sec(2);

disp(['dt = ' num2str(dt) ' sec'])
%%%%compute sampling freq
sfreq=1/time_sec(2);

%set(handles.sfreq,'String',num2str(sfreq));
% try to find station name

k=strfind(file1,'unc');

if k ~=0
    stname=file1(1:k-1)
else
    stname=[]
end
 
set(handles.staname,'String',stname)

%save RAW data to handles 
handles.ew = ew;
handles.ns = ns;
handles.ver=ver;
handles.tim=tim;
handles.stname=stname;
handles.length=length(ns);
handles.time_sec=time_sec;
handles.dt=dt;
handles.file=file1;
guidata(hObject,handles)

%%%%%%%%%%%%%%Update labels of components on graph based on file name
%set(handles.verlabel,'string',[file1(1:3) 'z'])
%set(handles.ewlabel,'string',[file1(1:3) 'e'])
%set(handles.nslabel,'string',[file1(1:3) 'n'])
% change slider values

% get station name from file name
% k=strfind(file1,'unc.dat');
% 
% if k~=0 
%     staname=file1(1:k-1);
% else
%     staname=[];
% end

%

% set slider according to signal 
set(handles.windowlen,'Max',length(ns))
set(handles.windowlen,'Min',0.01*length(ns))
set(handles.windowlen,'Value',0.01*length(ns))
set(handles.windowlen,'SliderStep',[0.01 0.06])

%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
hold off
plot(time_sec,ew,'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
title('EW')
ylabel('Counts')

axes(handles.nsaxis)
hold off
plot(time_sec,ns,'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
 title('NS')
ylabel('Counts')

axes(handles.veraxis)
hold off
plot(time_sec,ver,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
title('Ver')
xlabel('Time (sec)')
ylabel('Counts')

set(handles.ppick,'Enable','On')


% --- Executes on button press in ppick.
function ppick_Callback(hObject, eventdata, handles)
% hObject    handle to ppick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% get input

dt=handles.dt;
ew=handles.ew;
ns=handles.ns;
ver=handles.ver;
time_sec=handles.time_sec;

% read value
p=ginput(1);

%% find axis
ax=get(gcf,'CurrentAxes'); 
axdef =[handles.nsaxis handles.ewaxis handles.veraxis];
selax=find(ax==axdef); 

switch selax
    case 1
        disp('Selected component NS')
        selcomp='BHN';
    case 2
        disp('Selected component EW')
        selcomp='BHE';
    case 3
        disp('Selected component VER')
        selcomp='BHZ';
    otherwise
      disp('Click inside the plot area')
end

disp(['Time is ' num2str(p(1)) '  sec'])

% %% calculate and plot selected window
% % window will be 1024 points fixed for now...
% ppoint=fix(p(1)/dt);
% noise_ns=ns(ppoint-1023:ppoint);
% noise_ew=ew(ppoint -1023:ppoint);
% noise_ver=ver(ppoint -1023:ppoint);
% 
% signal_ns=ns(ppoint:ppoint+1023);
% signal_ew=ew(ppoint:ppoint+1023);
% signal_ver=ver(ppoint:ppoint+1023);
% 
% time_sec1=time_sec(ppoint-1023:ppoint);
% time_sec2=time_sec(ppoint:ppoint+1023);
% 
% % plot
%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
hold
plot([p(1) p(1)], [max(ew) min(ew)],'r','LineWidth',2)
 
axes(handles.nsaxis)
hold
plot([p(1) p(1)], [max(ns) min(ns)],'r','LineWidth',2)

axes(handles.veraxis)
hold
plot([p(1) p(1)], [max(ver) min(ver)],'r','LineWidth',2)

%
 handles.ptime=fix(p(1));
 handles.selcompbase=selcomp;
 guidata(hObject,handles)
 
 set(handles.windowlen,'Enable','On')

% --- Executes on button press in pspectra.
function pspectra_Callback(hObject, eventdata, handles)
% hObject    handle to pspectra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dt=handles.dt;
ptime=handles.ptime;
nwin=handles.nwin;   % window length for fft

ppoint=fix(ptime/dt);

ew=handles.ew;
ns=handles.ns;
ver=handles.ver;

%% detrend
% ew  =  detrend(ew,'constant');
% ns  =  detrend(ns,'constant');
% ver =  detrend(ver,'constant');
% disp('Removing Mean')
% %% Taper
% taperv=5;
% ew=taperd(ew,taperv/100);
% ns=taperd(ns,taperv/100);
% ver=taperd(ver,taperv/100);

%%
noise_ns=detrend(ns(ppoint-nwin:ppoint));
noise_ew=detrend(ew(ppoint -nwin:ppoint));
noise_ver=detrend(ver(ppoint -nwin:ppoint));
%%
signal_ns=detrend(ns(ppoint:ppoint+nwin));
signal_ew=detrend(ew(ppoint:ppoint+nwin));
signal_ver=detrend(ver(ppoint:ppoint+nwin));
%whos

% fft of signal velocity
[pns,f]=myfft(signal_ns,dt);
[pew,f]=myfft(signal_ew,dt);
[pve,f]=myfft(signal_ver,dt);
% fft of noise velocity
[pnns,f]=myfft(noise_ns,dt);
[pnew,f]=myfft(noise_ew,dt);
[pnve,f]=myfft(noise_ver,dt);

figure   % signal
loglog(f,pns,'r')
hold
loglog(f,pew,'r')
loglog(f,pve,'r')

loglog(f,pnns,'k--')
loglog(f,pnew,'k--')
loglog(f,pnve,'k--')

grid on
xlabel('Frequency (Hz)')
ylabel('Fourier Amplitude (counts*s)')

h = legend('Signal NS','Signal EW','Signal Z','Noise NS','Noise EW','Noise Z','Location','NorthEast');
% subplot
figure
subplot(1,3,1)
loglog(f,pns,'r')
hold
loglog(f,pnns,'k--')
title('NS')
xlabel('Frequency (Hz)')
ylabel('Fourier Amplitude (counts*s)')

subplot(1,3,2)
loglog(f,pew,'r')
hold
loglog(f,pnew,'k--')
title('EW')
xlabel('Frequency (Hz)')

subplot(1,3,3)
loglog(f,pve,'r')
hold
loglog(f,pnve,'k--')
title('Vertical')
xlabel('Frequency (Hz)')

%% save for latter plotting by gmt
whos
alld=[f;pns';pew';pve';pnns';pnew';pnve'];
%[newfile, newdir] = uiputfile([stname 'snr' '.dat'], 'Save S/N ratio data as');
fid = fopen('spectra.dat','w');
fprintf(fid,'%f %f %f %f %f %f %f\r\n',alld);  
fclose(fid);


%% smooth signals and plot S/N ratio
span = 5; % Size of the averaging window
window = ones(span,1)/span; 
smooth_pns = convn(pns,window,'same');
smooth_pew = convn(pew,window,'same');
smooth_pve = convn(pve,window,'same');
% noise
smooth_pnns = convn(pnns,window,'same');
smooth_pnew = convn(pnew,window,'same');
smooth_pnve = convn(pnve,window,'same');

r_ns=smooth_pns./smooth_pnns;
r_ew=smooth_pew./smooth_pnew;
r_ve=smooth_pve./smooth_pnve;

% mean value or S/N ratio
snaverage=(r_ns+r_ew+r_ve)/3;
figure   % signal
% loglog(f,pns,'b')
% hold
% loglog(f,smooth_pns,'r')

 loglog(f,r_ve,'r','LineWidth',.1)
 hold
 loglog(f,r_ns,'m','LineWidth',.1)
 loglog(f,r_ew,'k','LineWidth',.1)
loglog(f,snaverage,'b','LineWidth',3)

grid on
xlabel('Frequency (Hz)')
ylabel('S/N Ratio')

h = legend('SNR Z','SNR NS','SNR EW','Average SNR','Location','NorthEast');
%% save to handles
handles.snrZ=r_ve;
handles.snrNS=r_ns;
handles.snrEW=r_ew;
handles.snr=snaverage;
handles.freq=f;
guidata(hObject,handles)


%% displacement
% signalnsdis=cumtrapz(detrend(signal_ns))*dt;
% signalewdis=cumtrapz(detrend(signal_ew))*dt;
% signalverdis=cumtrapz(detrend(signal_ver))*dt;
% 
% noisensdis=cumtrapz(detrend(noise_ns))*dt;
% noiseewdis=cumtrapz(detrend(noise_ew))*dt;
% noiseverdis=cumtrapz(detrend(noise_ver))*dt;
% 
% % fft of signal displacement
% [pnsd,f]=myfft(signalnsdis,dt);
% [pewd,f]=myfft(signalewdis,dt);
% [pved,f]=myfft(signalverdis,dt);
% % fft of noise displacement
% [pnnsd,f]=myfft(noisensdis,dt);
% [pnewd,f]=myfft(noiseewdis,dt);
% [pnved,f]=myfft(noiseverdis,dt);
% 
% %% smooth signals and plot S/N ratio
% span = 15; % Size of the averaging window
% window = ones(span,1)/span; 
% smooth_pns = convn(pnsd,window,'same');
% smooth_pew = convn(pewd,window,'same');
% smooth_pve = convn(pved,window,'same');
% % noise
% smooth_pnns = convn(pnnsd,window,'same');
% smooth_pnew = convn(pnewd,window,'same');
% smooth_pnve = convn(pnved,window,'same');
% 
% r_ns=smooth_pns./smooth_pnns;
% r_ew=smooth_pew./smooth_pnew;
% r_ve=smooth_pve./smooth_pnve;
% 
% % mean value or S/N ratio
% snaverage=(r_ns+r_ew+r_ve)/3;
% figure   % signal
% % loglog(f,pns,'b')
% % hold
% % loglog(f,smooth_pns,'r')
% 
% % loglog(f,r_ve,'r','LineWidth',.1)
% % hold
% % loglog(f,r_ns,'r','LineWidth',.1)
% % loglog(f,r_ew,'r','LineWidth',.1)
% loglog(f,snaverage,'b','LineWidth',3)
% 
% grid on
% xlabel('Frequency (Hz)')
% ylabel('S/N Ratio')
% 

% figure   % signal
% loglog(f,pnsd,'b')
% hold
% loglog(f,pewd,'r')
% loglog(f,pved,'g')
% 
% loglog(f,pnnsd,'b--')
% loglog(f,pnewd,'r--')
% loglog(f,pnved,'g--')
% 
% grid on
% xlabel('Frequency (Hz)')
% ylabel('Power')
% 
% h = legend('Signal NS','Signal EW','Signal Z','Noise NS','Noise EW','Noise Z','Location','NorthEast');
% 

%%
% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.checknoisespectrum);


% --- Executes on slider movement.
function windowlen_Callback(hObject, eventdata, handles)
% hObject    handle to windowlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% read signals
dt=handles.dt;
ns=handles.ns;
ew=handles.ew;
ver=handles.ver;
time_sec=handles.time_sec;

% read P time
ptime=handles.ptime;
ppoint=fix(ptime/dt);

% read slider
slider_value = fix(get(hObject,'Value'));
%p=nextpow2(slider_value);

% convert to power of 2
%nwin=2^p  %slider_value
nwin=slider_value;

disp(['Window length in samples = ' num2str(nwin) '  and in seconds = ' num2str(nwin*dt)])
% check if it is out of limits

if nwin > ppoint
    disp('Out of limits')
    errordlg('Too short pre-event time. Use data with larger pre-event time. At least as large as event duration.','Error'); 
    return
else
    
end

% plot selected window
noise_ns=ns(ppoint-nwin:ppoint);
noise_ew=ew(ppoint -nwin:ppoint);
noise_ver=ver(ppoint -nwin:ppoint);

signal_ns=ns(ppoint:ppoint+nwin);
signal_ew=ew(ppoint:ppoint+nwin);
signal_ver=ver(ppoint:ppoint+nwin);

time_sec1=time_sec(ppoint-nwin:ppoint);
time_sec2=time_sec(ppoint:ppoint+nwin);

% plot
%%%%%%%%%%%%%%%%%%PLOT RAW  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot CORRECTED data
axes(handles.ewaxis)
%hold
plot(time_sec1,noise_ew,'b')
plot(time_sec2,signal_ew,'r')

axes(handles.nsaxis)
%hold
plot(time_sec1,noise_ns,'b')
plot(time_sec2,signal_ns,'r')

axes(handles.veraxis)
%hold
plot(time_sec1,noise_ver,'b')
plot(time_sec2,signal_ver,'r')

handles.nwin=nwin;
% Update handles structure
guidata(hObject, handles);
 set(handles.pspectra,'Enable','On')


% --- Executes during object creation, after setting all properties.
function windowlen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowlen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in savesnr.
function savesnr_Callback(hObject, eventdata, handles)
% hObject    handle to savesnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


snrZ=handles.snrZ;
snrNS=handles.snrNS;
snrEW=handles.snrEW;

%snr=handles.snr;
freq=handles.freq;
stname=handles.stname;
%whos

alld=[freq; snrNS'; snrEW'; snrZ'];


[newfile, newdir] = uiputfile([stname 'snr' '.dat'], 'Save S/N ratio data as');

fid = fopen([newdir newfile],'w');
fprintf(fid,'%f %f %f %f\r\n',alld);  
fclose(fid);
