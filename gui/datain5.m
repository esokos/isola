function varargout = datain5(varargin)
% DATAIN5 MATLAB code for datain5.fig
%      DATAIN5, by itself, creates a new DATAIN5 or raises the existing
%      singleton*.
%
%      H = DATAIN5 returns the handle to a new DATAIN5 or the handle to
%      the existing singleton*.
%
%      DATAIN5('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAIN5.M with the given input arguments.
%
%      DATAIN5('Property','Value',...) creates a new DATAIN5 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before datain5_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to datain5_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help datain5

% Last Modified by GUIDE v2.5 24-Nov-2018 09:02:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @datain5_OpeningFcn, ...
                   'gui_OutputFcn',  @datain5_OutputFcn, ...
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


% --- Executes just before datain5 is made visible.
function datain5_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to datain5 (see VARARGIN)


% Choose default command line output for datain5
handles.output = hObject;

% read defaults
[gmt_ver,psview,npts] = readisolacfg;

% Update handles structure
%%%raw data 
handles.ew = 0;
handles.ns = 0;
handles.ver = 0;
handles.tim=0;
handles.time_sec=0;
handles.dt=0;
handles.dtres=0;
handles.file=0;
handles.samfreq=0;
%%% corrected time series
handles.ewcor = 0;
handles.nscor = 0;
handles.vercor=0;
handles.newsamples=0;
%%origin time alligned time series
handles.allver=0;
handles.allew=0;
handles.allns=0;
%%P time alligned time series
handles.allver_all=0;
handles.allew_all=0;
handles.allns_all=0;
%%%% store P pick done by user
%handles.ppicksample=0;
%%%%%store End of data ...
%handles.endpoint=8192;
% 8192 is not fixed anymore it is given in isolacfg.isl
handles.endpoint=npts;

guidata(hObject, handles);

% UIWAIT makes datain wait for user response (see UIRESUME)
% uiwait(handles.Datain);

%%%%%%DELETE STATIONS.DAT
[s,w] = system('del allstat.dat');

%%%read event and raw data info.....
%%% check event.isl files with event info
h=dir('event.isl');

if isempty(h); 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    orhour=fscanf(fid,'%g',1);
    ormin=fscanf(fid,'%g',1);
    orsec=fscanf(fid,'%g',1);
    fclose(fid);
end
%%% check rawinfo.isl files with event info
% h=dir('rawinfo.isl');
% 
% if length(h) == 0; 
%   errordlg('Rawinfo.isl file doesn''t exist. Run Event info. ','File Error');
%   return
% else
%     fid = fopen('rawinfo.isl','r');
% %     samfreq=fscanf(fid,'%g',1);
%     rawhour=fscanf(fid,'%g',1);
%     rawmin=fscanf(fid,'%g',1);
%     rawsec=fscanf(fid,'%g',1);
%     fclose(fid);
% end

%    samfreq=100    %fscanf(fid,'%g',1);

%%%%%%%%%%find resampling frequency
h=dir('duration.isl');

if isempty(h); 
  errordlg('Duration.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('duration.isl','r');
    tl=fscanf(fid,'%g',1);
    fclose(fid);
end

dtres=tl/npts;
resamfreq=1/dtres;

%%%update        
%set(handles.dfactor,'String',num2str(fix(resamfreq),'%5d'))  

set(handles.dfactor,'String',num2str(resamfreq))  

%%% change high cut
%set(handles.hcut1,'String',num2str((samfreq/2)-1))  
% set(handles.hcut2,'String',num2str((samfreq/2)-1))  


%%%% updata handles.....
set(handles.orighour,'String',num2str(orhour))          
set(handles.origmin,'String',num2str(ormin))          
set(handles.origsec,'String',num2str(orsec))          

% set(handles.filehour,'String',num2str(rawhour))          
% set(handles.filemin,'String',num2str(rawmin))          
% set(handles.filesec,'String',num2str(rawsec))     

%handles.samfreq=samfreq;
%handles.dt=1/samfreq;
handles.dtres=dtres;
handles.tl=tl;

% Update handles structure
guidata(hObject, handles);

% 
off =[handles.orallign,handles.savefinal,handles.makecor,handles.plcurve];
enableoff(off)




% UIWAIT makes datain5 wait for user response (see UIRESUME)
% uiwait(handles.datain5);


% --- Outputs from this function are returned to the command line.
function varargout = datain5_OutputFcn(hObject, eventdata, handles) 
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

set(handles.text18,'Visible','on')
set(handles.dfactor,'Visible','on')

messtext=...
   ['                                                 '
    'Please select a datafile.                        '
    'This file should be a text file with             '
    'four columns separated by spaces.                '
    'Each column should contain time and data channels'
    'the succession should be time NS, EW and Z       '
    '                                                 '];

h=dir('data');

if isempty(h);
    
%uiwait(msgbox(messtext,'Message','warn','modal'));
disp(messtext)

[file1,path1] = uigetfile([ 'unc.dat'],' Earthquake Datafile');

   lopa = [path1 file1];
   name = file1

   if name == 0
       disp('Cancel file load')
       return
   else
   end
   
lopa
% 
fid  = fopen(lopa,'r');
[time_sec,ns,ew,ver] = textread(lopa,'%f %f %f %f');
fclose(fid);
    
    
else
    
cd data
%uiwait(msgbox(messtext,'Message','warn','modal'));
disp(messtext)
[file1,path1] = uigetfile([ 'unc.dat'],' Earthquake Datafile');

   lopa = [path1 file1];
   name = file1

   if name == 0
       disp('Cancel file load')
       cd ..
       return
   else
   end
   
lopa
% 
fid  = fopen(lopa,'r');
[time_sec,ns,ew,ver] = textread(lopa,'%f %f %f %f');
fclose(fid);

cd ..
    
end

%% read what is written in rawinfo.isl
% samfreq=handles.samfreq;
% def{1,1} =num2str(samfreq);

pwd

% decide about *stime.isl name 
% its length depends on station name !!
 
switch length(name)
    case 12 % station with 5 character name
        stime_filename=[file1(1:5) 'stime' '.isl']
    case 11 % station with 4 character name
        stime_filename=[file1(1:4) 'stime' '.isl']
    case 10
        stime_filename=[file1(1:3) 'stime' '.isl']
    otherwise
        disp('Error in file read')
end


if exist(stime_filename,'file');
    disp('Found Start time file. Start time will be changed accordingly.');

fid  = fopen(stime_filename,'r');
[dummy1,sfiledate1,sfiledate2,sfiledate3,sfiledate4,sfilehour,sfilemin,sfilesec] = textread(stime_filename,'%q%f%q%f%f%f%f%f');
fclose(fid);
 
set(handles.filehour,'String',num2str(sfilehour))          
set(handles.filemin,'String',num2str(sfilemin))          
set(handles.filesec,'String',num2str(sfilesec))     


else
    
    errordlg(['Start time file ' stime_filename  '  doesn''t exist.'],'File Error');
    uiwait;
end


% whos time_sec ns ew ver

%this is the sample number not the time....
tim=(1:1:length(time_sec(:,1)));

%prepare time axis
%%%%%%%%%read sampling rate

% def = {'1'};
% ni2 = inputdlg('What is the sampling Frequency','Input',1,def);
% l = ni2{1};
% n = str2num(l);

sfreq=1/(time_sec(2)-time_sec(1));

%%%
set(handles.sfreq,'String',num2str(sfreq));
% set(handles.hcut1,'String',num2str((sfreq/2)-1));  

%%% change high cut to 1% of sfreq %% use ceil instead of round 21/03/2012
% set(handles.hcut1,'String',num2str(sfreq/2-ceil(sfreq/100)));  

% fix at Nyquist
hcut11=num2str(sfreq/2-ceil(sfreq/100));

disp(['High cut fiter of data for instrument correction set up at Nyquist = ' hcut11])



%%%

%%%%%
set(handles.dstat,'String','Raw data',...
                  'FontSize',14,...
                  'FontWeight','bold',...
                  'ForegroundColor','red');
%%%%%%%%
srate = str2double(get(handles.sfreq,'String'));
%%%

% set(handles.hcut1,'String',num2str((srate/2)-1));  
% set(handles.hcut2,'String',num2str((srate/2)-1))  

%%%
% disp(srate);
dt=1/srate;
% time_sec=((tim.*dt)-dt);

%%%%%%%%%%%%%%Update labels of components on graph based on file name

switch length(name)
    case 12 % station with 5 character name
        set(handles.verlabel,'string',[file1(1:5) 'z'])
        set(handles.ewlabel,'string',[file1(1:5) 'e'])
        set(handles.nslabel,'string',[file1(1:5) 'n'])
        stname=file1(1:5);
    case 11 % station with 4 character name
        set(handles.verlabel,'string',[file1(1:4) 'z'])
        set(handles.ewlabel,'string',[file1(1:4) 'e'])
        set(handles.nslabel,'string',[file1(1:4) 'n'])
        stname=file1(1:4);
    case 10
        set(handles.verlabel,'string',[file1(1:3) 'z'])
        set(handles.ewlabel,'string',[file1(1:3) 'e'])
        set(handles.nslabel,'string',[file1(1:3) 'n'])
        stname=file1(1:3);
    otherwise
        disp('Error in file read')
end



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
ylabel('Counts')


%save RAW data to handles 
handles.ew = ew;
handles.ns = ns;
handles.ver=ver;
handles.tim=tim;
handles.time_sec=time_sec;
handles.dt=dt;
handles.file=file1;
handles.stname=stname;
handles.hcut11=hcut11;

guidata(hObject,handles)

% handles on
on =[handles.makecor,handles.plcurve,handles.cut];
enableon(on)



% --- Executes on button press in cut.
function cut_Callback(hObject, eventdata, handles)
% hObject    handle to cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%READ DATA FROM HANDLES
ew=handles.ew ;
ns=handles.ns ;
ver=handles.ver;
dt=handles.dt;
% 
cutpick1 = ginput(1);
%cutpick2=ginput(1)

cutpoint1=fix(cutpick1(1));
%cutpoint2=fix(cutpick2(1));

%%% we work with secs now this should change..!!!
ew=ew(1:cutpoint1/dt);    %%%%%%%:cutpoint2);
ns=ns(1:cutpoint1/dt);    %%:cutpoint2);
ver=ver(1:cutpoint1/dt);   %%%%%:cutpoint2);
% 
tim=(1:1:length(ew));
% 
% %prepare new time axis
% %%%%%%%%%read sampling rate
time_sec=((tim.*dt)-dt);
% 
% whos ew ns ver

handles.ew=ew;
handles.ns=ns;
handles.ver=ver;
handles.tim = tim;
guidata(hObject,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% 
axes(handles.nsaxis)
plot(time_sec,ns,'k')
%plot(data(3,:),'g')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.ewaxis)
plot(time_sec,ew,'k')
%plot(data(2,:),'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.veraxis)
plot(time_sec,ver,'k')
%plot(data(1,:),'b')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Seconds')
ylabel('Counts')

function orighour_Callback(hObject, eventdata, handles)
% hObject    handle to orighour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orighour as text
%        str2double(get(hObject,'String')) returns contents of orighour as a double


% --- Executes during object creation, after setting all properties.
function orighour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orighour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function origmin_Callback(hObject, eventdata, handles)
% hObject    handle to origmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of origmin as text
%        str2double(get(hObject,'String')) returns contents of origmin as a double


% --- Executes during object creation, after setting all properties.
function origmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to origmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function origsec_Callback(hObject, eventdata, handles)
% hObject    handle to origsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of origsec as text
%        str2double(get(hObject,'String')) returns contents of origsec as a double


% --- Executes during object creation, after setting all properties.
function origsec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to origsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filehour_Callback(hObject, eventdata, handles)
% hObject    handle to filehour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filehour as text
%        str2double(get(hObject,'String')) returns contents of filehour as a double


% --- Executes during object creation, after setting all properties.
function filehour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filehour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filemin_Callback(hObject, eventdata, handles)
% hObject    handle to filemin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filemin as text
%        str2double(get(hObject,'String')) returns contents of filemin as a double


% --- Executes during object creation, after setting all properties.
function filemin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filemin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filesec_Callback(hObject, eventdata, handles)
% hObject    handle to filesec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filesec as text
%        str2double(get(hObject,'String')) returns contents of filesec as a double


% --- Executes during object creation, after setting all properties.
function filesec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filesec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selfilter.
function selfilter_Callback(hObject, eventdata, handles)
% hObject    handle to selfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selfilter

if (get(handles.selfilter,'Value') == get(handles.selfilter,'Max'))
%%%enable allign

on =[handles.lcut2, handles.text18,handles.text16];
enableon(on)

else
    
off =[handles.lcut2 ,handles.text18,handles.text16];
enableoff(off)

end


% --- Executes on button press in orallign.
function orallign_Callback(hObject, eventdata, handles)
% hObject    handle to orallign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%% READ DATA FROM HANDLES
%%%%%%%% HERE WE READ THE CORRECTED DATA.....
ewcor=handles.ewcor;
nscor=handles.nscor;
vercor=handles.vercor;
newsamples=handles.newsamples;
currentstation=handles.file;
dt = handles.dt;
tl = handles.tl;

dtres=handles.dtres;

npts=handles.endpoint;  % 8192 is not fixed..13/09/2018

%%
% decide about prefilter use
if (get(handles.selfilter,'Value') == get(handles.selfilter,'Max'))
    prefilter=1;  %  use
else
    prefilter=0;  %  don't use
end
%%
disp('   ')
disp(['Current station is '  currentstation])

%%%%%%%%%read sampling rate
srate = str2double(get(handles.sfreq,'String'));
%disp(srate);
dtime=1/srate;
%disp(dtime)
%%%%%%%%%%%%%
%%%%%%%%%%%%%% I HAVE TO READ THIS FROM FILE.... CHANGE IT ....!!!

%%%%%%%%%read origin time
orighour = str2double(get(handles.orighour,'String'));
%disp(orighour);
origmin = str2double(get(handles.origmin,'String'));
%disp(origmin);
origsec = str2double(get(handles.origsec,'String'));
%disp(origsec);

disp(['Origin Time '  get(handles.orighour,'String') ':' get(handles.origmin,'String') ':' get(handles.origsec,'String')])

%%%%%%%%%%%%%
%read the first sample time 
fhour = str2double(get(handles.filehour,'String'));
%disp(fhour)
fmin = str2double(get(handles.filemin,'String'));
%disp(fmin)
fsec = str2double(get(handles.filesec,'String'));
%disp(fsec)

disp(['First sample time '  get(handles.filehour,'String') ':' get(handles.filemin,'String') ':' get(handles.filesec,'String')])



%% check that data start time is not empty
if isempty(get(handles.filehour,'String')) || isempty(get(handles.filemin,'String')) || isempty(get(handles.filesec,'String')) 
    
    errordlg('Data Start Time is not given.','Input Error');
    return
    
else
end

%% allign 
%%%%%%%%%%%% CHECK where data file starts in regards to origin time
%%% convert to seconds from day start and compare times...
%%% 
%origintime=fix((orighour*3600)+(origmin*60)+origsec)
%firstsampletime=fix((fhour*3600)+(fmin*60)+fsec)

origintime=((orighour*3600)+(origmin*60)+origsec);
firstsampletime=((fhour*3600)+(fmin*60)+fsec);

% %ptravels=fix((ptravel*3600)   %   CONTINUE LATTER
% 
% disp(firstsampletime)
% disp('length')
% length(vercor)
% 
% disp(dtime)
% 
% whos vercor ewcor nscor


if firstsampletime-origintime > 0   %%% this means that we have to add points before the first data sample
    
          %Compute how many sample we have to add
           addsamples=fix((firstsampletime-origintime)/dtime);
           disp(['Adding (zero padding) '  num2str(addsamples) ' samples or ' num2str(addsamples*dtime) '  seconds'])

          %Construct new data arrays
          %add zeroes before the begging of file and continue with real
          %data up to the end
          %then plot the alligned data....
          
          b = zeros(addsamples,1);

          allver=vertcat(b, vercor);
          allew=vertcat(b, ewcor);
          allns=vertcat(b, nscor);

           % plot displacement
           ewdetr=detrend(allew);
           nsdetr=detrend(allns);
           verdetr=detrend(allver);

           prompt = {'Enter Taper Length in seconds. Tapering is applied at the begining and end of trace between the two blue lines.'};
           dlg_title = 'Taper';
           num_lines = 1;
           def = {'20'};

           st = inputdlg(prompt,dlg_title,num_lines,def);
           t=str2double(char(st));
           disp(['applying taper of '  num2str(t) ' s' ])
           % taper data
           taperv=(t/(length(allver)*dt));
           
           ewdetr=taperd(ewdetr,taperv);
           nsdetr=taperd(nsdetr,taperv);
           verdetr=taperd(verdetr,taperv);
           
           % save data  
           handles.allver=verdetr;
           handles.allew=ewdetr;
           handles.allns=nsdetr;
           handles.t=t;
           guidata(hObject, handles);        
           
           t_plot=taper(length(ewdetr),taperv);
%            
%            ewdis=cumtrapz(ewdetr)*dt;
%            nsdis=cumtrapz(nsdetr)*dt;
%            verdis=cumtrapz(verdetr)*dt;
         
          %%%%%%%%% plotting 
          %%%%%prepare 'time' axis
          tim=(1:1:length(verdetr));
          %prepare real time axis
          time_sec=((tim.*dt)-dt);
          %%%%%%%%%%%          
          axes(handles.nsaxis)
          plot(time_sec,nsdetr,'r')
          set(handles.nsaxis,'XMinorTick','on')
          grid on
          hold on
          plot(time_sec,t_plot*max(nsdetr),'g')
          hold off
          
          
          axes(handles.ewaxis)
          plot(time_sec,ewdetr,'r')
          set(handles.ewaxis,'XMinorTick','on')
          grid on
          hold on
          plot(time_sec,t_plot*max(ewdetr),'g')
          hold off

          axes(handles.veraxis)
          plot(time_sec,verdetr,'r')
          set(handles.veraxis,'XMinorTick','on')
          grid on
          hold on
          plot(time_sec,t_plot*max(verdetr),'g')
          hold off          
          xlabel('Sec')
          ylabel('m/sec')
          
%           %%%%% do something else here ???? save data ?????
%           whos allver allew allns
          
%           handles.allver=allver;
%           handles.allew=allew;
%           handles.allns=allns;
%           guidata(hObject, handles);
          %%%%%%%%%%%%%%%%%%
          
elseif firstsampletime-origintime < 0 % this means that we have to cut points from data..
          %Compute how many samples we have to cutdata
%           disp ('cutsamples=')
 
           cutsamples=ceil((origintime-firstsampletime)*srate);
           
           disp(['Cutting '  num2str(cutsamples) ' samples or ' num2str(cutsamples*dtime) '  seconds'])
           
                    if cutsamples > length(vercor)
                       errordlg('Check your origin or file start time' ,'Error');
                       return
                   else
                   end
                   
%           b = zeros(cutsamples,1);
% 
%           allver =vertcat(vercor(cutsamples:length(vercor),1), b) ;
%           allew = vertcat(ewcor(cutsamples:length(ewcor),1), b) ;
%           allns = vertcat(nscor(cutsamples:length(nscor),1), b) ;

           
%             disp(['Signal has length of ' num2str(length(vercor)*dt)])
                
            allew = ewcor(cutsamples:length(ewcor),1) ;
            allns = nscor(cutsamples:length(nscor),1) ;
            allver= vercor(cutsamples:length(vercor),1);

            disp(['alligned signal has length of ' num2str(length(allver)*dt)])

%       we have to cut at the end!

%             nsampleskeep=tl/dt
% 
%             allew = allew(1:nsampleskeep,1) ;
%             allns = allns(1:nsampleskeep,1) ;
%             allver = allver(1:nsampleskeep,1) ;
% 
%              whos allew allns allver
%              
            
           disp('de-mean')
           ewdetr=detrend(allew);%,'constant');
           nsdetr=detrend(allns);%,'constant');
           verdetr=detrend(allver);%,'constant');

      %      t = input('Taper length in seconds: ');
      
          prompt = {'Enter Taper Length in seconds. Tapering is applied at the begining and end of trace between the two blue lines.'};
          dlg_title = 'Taper';
          num_lines = 1;
           def = {'20'};

           st = inputdlg(prompt,dlg_title,num_lines,def);
           t=str2double(char(st));
           disp(['applying taper of '  num2str(t) ' s' ])
           % taper data
           taperv=(t/(length(allver)*dt));
           
           ewdetr=taperd(ewdetr,taperv);
           nsdetr=taperd(nsdetr,taperv);
           verdetr=taperd(verdetr,taperv);
           
            % save data  
          handles.allver=verdetr;
          handles.allew=ewdetr;
          handles.allns=nsdetr;
          handles.t=t;
          guidata(hObject, handles);         

%% compute taper for plotting
       %   tim=(1:1:length(verdetr));
       %   time_sec=((tim.*dt)-dt);
       %      figure
             t_plot=taper(length(ewdetr),taperv);
        %     plot(time_sec,t_plot*max(ewdetr))
          
%% Plotting           
     %     nptsns=length(nsdetr)

% ewdetr=bandpass2(ewdetr,0.4,1,nptsns,dt);
% nsdetr=bandpass2(nsdetr,0.4,1,nptsns,dt);
% verdetr=bandpass2(verdetr,0.4,1,nptsns,dt);
% 
%            ewdis=cumtrapz(ewdetr)*dt;
%            nsdis=cumtrapz(nsdetr)*dt;
%            verdis=cumtrapz(verdetr)*dt;
          
          %%%%%%%%% plotting 
          %%%%%prepare 'time' axis
          tim=(1:1:length(verdetr));
          %%%%%%%%%%%          
          %prepare real time axis
          time_sec=((tim.*dt)-dt);
          %%%%%%%%%%%%%%%%%%%%%%
          axes(handles.nsaxis)
          plot(time_sec,nsdetr,'r')
          set(handles.nsaxis,'XMinorTick','on')
          grid on
          hold on
          plot(time_sec,t_plot*max(nsdetr),'g')
          hold off
          
          axes(handles.ewaxis)
          plot(time_sec,ewdetr,'r')
          set(handles.ewaxis,'XMinorTick','on')
          grid on
          hold on
          plot(time_sec,t_plot*max(ewdetr),'g')
          hold off
          
          axes(handles.veraxis)
          plot(time_sec,verdetr,'r')
          set(handles.veraxis,'XMinorTick','on')
          grid on
          hold on
          plot(time_sec,t_plot*max(verdetr),'g')
          hold off
          
          xlabel('sec')
          ylabel('m/sec')
        
          %%%%%%%%%%%%%%%%%%
else      %%%%%%%%%%  
          
          disp('Origin time and file start time match...no change..!!')

          
           disp('de-mean')
           ewdetr=detrend(ewcor); 
           nsdetr=detrend(nscor); 
           verdetr=detrend(vercor); 

           prompt = {'Enter Taper Length in seconds. Tapering is applied at the begining and end of trace between the two blue lines.'};
           dlg_title = 'Taper';
           num_lines = 1;
           def = {'20'};

           st = inputdlg(prompt,dlg_title,num_lines,def);
           t=str2double(char(st));
           disp(['applying taper of '  num2str(t) ' s' ])
           % taper data
           taperv=(t/(length(vercor)*dt));

           ewdetr=taperd(ewdetr,taperv);
           nsdetr=taperd(nsdetr,taperv);
           verdetr=taperd(verdetr,taperv);
           
           % save data  
           handles.allver=verdetr;
           handles.allew=ewdetr;
           handles.allns=nsdetr;
           handles.t=t;
           guidata(hObject, handles);      
          
%% compute taper for plotting

             t_plot=taper(length(ewdetr),taperv);
          
%% Plotting           

          
          %%%%%%%%% plotting 
          %%%%%prepare 'time' axis
          tim=(1:1:length(verdetr));
          %%%%%%%%%%%          
          %prepare real time axis
          time_sec=((tim.*dt)-dt);
          %%%%%%%%%%%%%%%%%%%%%%
          axes(handles.nsaxis)
          plot(time_sec,nsdetr,'r')
          set(handles.nsaxis,'XMinorTick','on')
          grid on
          hold on
          plot(time_sec,t_plot*max(nsdetr),'g')
          hold off
          
          
          axes(handles.ewaxis)
          plot(time_sec,ewdetr,'r')
          set(handles.ewaxis,'XMinorTick','on')
          grid on
          hold on
          plot(time_sec,t_plot*max(ewdetr),'g')
          hold off
          
          axes(handles.veraxis)
          plot(time_sec,verdetr,'r')
          set(handles.veraxis,'XMinorTick','on')
          grid on
          hold on
          plot(time_sec,t_plot*max(verdetr),'g')
          hold off          
          
          xlabel('sec')
          ylabel('m/sec')
           
           
end          

%%%%%%%%%%%%%%%%%%%%%%%%%%%          END  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%
set(handles.dstat,'String','Origin Alligned Instrument corrected data',...
                  'FontSize',14,...
                  'FontWeight','bold',...
                  'ForegroundColor','red')

              
%%  Resample and get 8192 points
% we read data that are alligned only for origin..........

allver_all=handles.allver;
allew_all=handles.allew;
allns_all=handles.allns;

%% resample
% read sampling rate    
origfreq = str2double(get(handles.sfreq,'String'));  % this is the original sampling freq
%%%READ FACTOR
newfreq = str2double(get(handles.dfactor,'String'));  % this is the final sampling freq
disp(' ')
disp(['Original sampling freq ' num2str(origfreq) 'Hz'])
disp(' ')
disp(['Final sampling freq ' num2str(newfreq) 'Hz'])
disp(' ')
[p,q] = rat(newfreq/origfreq,0.00001); 

resallver_all=resample(allver_all,p,q);
%resallver_all_2 = downsample(allver_all,dfactor);
resallew_all=resample(allew_all,p,q);
%resallew_all_2 = downsample(allew_all,dfactor);
resallns_all=resample(allns_all,p,q);
%resallns_all_2 = downsample(allns_all,dfactor);

dt=1/newfreq;

%%%%%%%%%now change sampling frequency in sfreq window in GUI
set(handles.sfreq,'string',num2str(newfreq))
set(handles.text15,'Visible','off')
set(handles.dfactor,'Visible','off')

%%%%%%%%%%make NEW X axis
tim=(1:1:length(resallver_all));
%make NEW real time axis in sec..
time_sec=((tim.*dt)-dt);
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%SAVE TO HANDLES

handles.allver_all_res=resallver_all;
handles.allew_all_res=resallew_all;
handles.allns_all_res=resallns_all;
handles.tim=tim;
handles.time_sec=time_sec;
handles.dt=dt;
guidata(hObject, handles);

% % 
% axes(handles.nsaxis)
% plot(time_sec,resallns_all,'b')
% set(handles.nsaxis,'XMinorTick','on')
% grid on
% 
% axes(handles.ewaxis)
% plot(time_sec,resallew_all,'b')
% set(handles.ewaxis,'XMinorTick','on')
% grid on
% 
% axes(handles.veraxis)
% plot(time_sec,resallver_all,'b')
% set(handles.veraxis,'XMinorTick','on')
% grid on
% xlabel('Time (sec)')
% ylabel('m/sec')
% 
%%%%%
% set(handles.dstat,'String','Resampled data',...
%                   'FontSize',14,...
%                   'FontWeight','bold',...
%                   'ForegroundColor','blue')
%%

%%%%%%%%READ DATA FROM HANDLES
%%%%%%%%%%%% change 10/04
%allver_all=handles.allver_all_res(1:8192);
%allew_all=handles.allew_all_res(1:8192);
%allns_all=handles.allns_all_res(1:8192);

allver_all=handles.allver_all_res;
allew_all=handles.allew_all_res;
allns_all=handles.allns_all_res;
% whos allver_all allew_all allns_all
%%%%%%%check if data are less than 8192  10/04 there was a small bug here
%%%%%%%if number of points > 8192...!!!
%%%% corrected  10/11/04

missdata=npts-length(allver_all)

           bmiss = zeros(missdata,1);
          
if missdata > 0 
  allver_all8192=vertcat(allver_all, bmiss);
  allew_all8192 =vertcat(allew_all, bmiss);
  allns_all8192 =vertcat(allns_all,  bmiss);
  warndlg(['Data < ' num2str(npts) ' points zero padding was done. This could cause problems. '],'!! Warning !!')
else
  allver_all8192=allver_all(1:npts);
  allew_all8192 =allew_all(1:npts);
  allns_all8192=allns_all(1:npts);
  
  disp(['The first ' num2str(npts) ' points will be saved or '   num2str(npts*dt)    '  seconds of data'])

end

%% detrend
disp(' ')
allew_all8192  =  detrend(allew_all8192);
allns_all8192  =  detrend(allns_all8192);
allver_all8192 =  detrend(allver_all8192);
disp('Removing Trend')

%% taper
disp(' ')
%  t = input('Taper length in seconds: ');
try
  t=handles.t;
catch
   disp('Problem finding default taper. Assigning a value of 20.');
   t=20;
end
           disp(['applying taper of '  num2str(t) ' s' ])
           % taper data
           taperv=(t/(length(allver_all8192)*dt));
           
           allew_all8192=taperd(allew_all8192,taperv);
           allns_all8192=taperd(allns_all8192,taperv);
           allver_all8192=taperd(allver_all8192,taperv);
disp(' ')
% time
tim=(1:1:length(allver_all8192));
time_sec=((tim.*dt)-dt);
%% SAVE TO HANDLES           
handles.allew_all8192=allew_all8192;
handles.allns_all8192=allns_all8192;
handles.allver_all8192=allver_all8192;
handles.tim=tim;
handles.time_sec=time_sec;
handles.dt=dt;
guidata(hObject, handles);           
%%

%% Ploting

% taper
        taperv=(t/(length(allver_all8192)*dt));
        t_plot=taper(length(allver_all8192),taperv);

axes(handles.nsaxis)
plot(time_sec,allns_all8192,'b')
set(handles.nsaxis,'XMinorTick','on')
grid on
hold on
plot(time_sec,t_plot*max(allns_all8192),'g')
hold off

axes(handles.ewaxis)
plot(time_sec,allew_all8192,'b')
set(handles.ewaxis,'XMinorTick','on')
grid on
hold on
plot(time_sec,t_plot*max(allew_all8192),'g')
hold off

axes(handles.veraxis)
plot(time_sec,allver_all8192,'b')
set(handles.veraxis,'XMinorTick','on')
grid on
hold on
plot(time_sec,t_plot*max(allver_all8192),'g')
hold off

xlabel('Time (sec)')
ylabel('m/sec')
set(handles.dstat,'String','Resampled data',...
                  'FontSize',14,...
                  'FontWeight','bold',...
                  'ForegroundColor','blue')
on =[handles.savefinal];
enableon(on)
% 

% --- Executes on button press in savefinal.
function savefinal_Callback(hObject, eventdata, handles)
% hObject    handle to savefinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% read
allew_all8192=handles.allew_all8192;
allns_all8192=handles.allns_all8192;
allver_all8192=handles.allver_all8192;
tim=handles.tim; time_sec=handles.time_sec;
dt=handles.dt;
t=handles.t;
             
%%
%time_sec'; allns_all8192' ; allew_all8192' ; allver_all8192

%%%%%%%%%read sampling rate
srate = str2double(get(handles.sfreq,'String'));
%disp(srate);
%dtime=dtres;          %%%%%%% 26/01/2010
%disp(dtime)
%%%%%%%%%%%%%

%%%%%%%%%%make NEW X axis
tim=(1:1:length(allver_all8192));
%make NEW real time axis in sec..
time_sec=((tim.*dt)-dt)';

%read current station name  handles.file;
currentstation=handles.stname;
% 
% % whos time_sec allver_all8192
% % prepare filename from station names
% station_name=currentstation(1:3)

station_name=[currentstation 'raw' '.dat'];

% write data in ascii file
%data are written in file in the following order
% NS,EW,VER
% whos allver_all allew_all allns_all
% 
% whos allver_all8192 allew_all8192 allns_all8192
% alld=[test1; test2 ;test3];

alld=[time_sec'; allns_all8192' ; allew_all8192' ; allver_all8192'];

%alld=[allns_all8192 ; allew_all8192 ; allver_all8192];

% whos alld

%%%%cd in invert
try
    
cd invert

    [newfile, newdir] = uiputfile(station_name, 'Save station data as');
        fid = fopen([newdir newfile],'w');
           if ispc
               fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%
           else
               fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%
           end
               % fprintf(fid,'%e     %e     %e\r\n',alld);   %%%%%
        fclose(fid);

         infostr= ['Data were written in the file ' newdir newfile ' the column order is NS, EW, VER'];
         % helpdlg(infostr,'File info');
         disp('  ')
         disp(infostr)

cd ..

catch
    cd ..
end


off =[handles.orallign,handles.savefinal,handles.makecor,handles.plcurve];
enableoff(off)




% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.datain5)


function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')


% --- Executes on button press in makecor.
function makecor_Callback(hObject, eventdata, handles)
% hObject    handle to makecor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disable cut
off =[handles.cut];
enableoff(off)

%READ DATA FROM HANDLES AND put in new variables....
ewcounts=handles.ew;
nscounts=handles.ns;
vercounts=handles.ver;
dt=handles.dt;
file=handles.file;
hcut11=handles.hcut11;


% decide about prefilter use
if (get(handles.selfilter,'Value') == get(handles.selfilter,'Max'))
    prefilter=1;  %  use
else
    prefilter=0;  %  don't use
end

%%
if prefilter==1  % USE prefilter ....!!!

    disp('This is instrumental correction with prefilter option')
    
  %%       
   if (get(handles.skipinst,'Value') == get(handles.skipinst,'Max'))
      %skip instrument correction
       disp('Data are corrected already. Skip instrument correction part')

      %save instrument corrected - filtered data  to handles 
       handles.ewcor = ewcounts; handles.nscor = nscounts; handles.vercor=vercounts;
       newsamples=(1:1:max(size(ewcounts)));
       handles.newsamples=newsamples;
       guidata(hObject,handles)
      %enable allign
       on =[handles.orallign];
       enableon(on)
       
   else % do instrument correction using prefilter

       switch length(file)
         case 12 % station with 5 character name
           stationpzfilens=[file(1:5)  'BHN.pz']; stationpzfileew=[file(1:5)  'BHE.pz']; stationpzfilever=[file(1:5) 'BHZ.pz'];
         case 11 % station with 4 character name
           stationpzfilens=[file(1:4)  'BHN.pz']; stationpzfileew=[file(1:4)  'BHE.pz']; stationpzfilever=[file(1:4) 'BHZ.pz'];
         case 10
           stationpzfilens=[file(1:3)  'BHN.pz']; stationpzfileew=[file(1:3)  'BHE.pz']; stationpzfilever=[file(1:3) 'BHZ.pz'];
         otherwise
           disp('Error in pole zero file read')
       end

       % Call readpz for 3 comp
          [A0ns,constantns,  nzerns, zeroesns, npolns, polesns, nsclip, valid_datens, digisens_ns, seismsens_ns]  = readpzfile(stationpzfilens);
          [A0ew,constantew,  nzerew, zeroesew, npolew, polesew, ewclip, valid_dateew, digisens_ew, seismsens_ew]  = readpzfile(stationpzfileew);
          [A0ver,constantver,nzerver,zeroesver,npolver,polesver,verclip,valid_datever,digisens_ver,seismsens_ver] = readpzfile(stationpzfilever);

       % End pole and zero read....
       
       % Detrend
          disp('Removing Trend')
          nscounts  =  detrend(nscounts); ewcounts  =  detrend(ewcounts);vercounts =  detrend(vercounts);
          disp('   ')
       
       % add taper
        %  taperv = str2double(get(handles.taper,'String'));
        % fix
          taperv = 5;
       % taper data
          ewcounts=taperd(ewcounts,taperv/100); nscounts=taperd(nscounts,taperv/100); vercounts=taperd(vercounts,taperv/100);
          
       % Instrumental correction call instcor for 3 comp
          disp('Starting Instrumental correction')
          np=length(nscounts);  % fix to NS comp
          nscor6    = instcor( nscounts,constantns, A0ns, nzerns, zeroesns, npolns, polesns,dt,np);
          ewcor6    = instcor( ewcounts,constantew, A0ew, nzerew, zeroesew, npolew, polesew,dt,np);
          vercor6   = instcor(vercounts,constantver,A0ver,nzerver,zeroesver,npolver,polesver,dt,np);
          disp('Finished Instrumental correction')
          disp('   ')

       %  filtering AFTER instrumental correction 
          lcut2 = str2double(get(handles.lcut2,'String')); hcut1 = str2double(hcut11);

          nptsew=length(ewcor6); ewcor=bandpass2(ewcor6,lcut2,hcut1,nptsew,dt);
          nptsns=length(nscor6); nscor=bandpass2(nscor6,lcut2,hcut1,nptsns,dt);
          nptsver=length(vercor6); vercor=bandpass2(vercor6,lcut2,hcut1,nptsver,dt);
          newsamples=(1:1:max(size(ewcor)));
       %  save instrument corrected - filtered data  to handles 
          handles.ewcor = ewcor; handles.nscor = nscor; handles.vercor=vercor;
          handles.newsamples=newsamples;
          guidata(hObject,handles)
       %  save clip info
          if (nsclip==1 && ewclip==1 && verclip==1)
           handles.digisens_ns = digisens_ns;
           handles.seismsens_ns = seismsens_ns;
           handles.digisens_ew = digisens_ew;
           handles.seismsens_ew = seismsens_ew;
           handles.digisens_ver = digisens_ver;
           handles.seismsens_ver = seismsens_ver;
           guidata(hObject,handles)
          else
           disp('Clip info not found')
          end

        % INSTRUMENT CORRECTION END %
        
      % add OT line
      % read origin time
        orighour = str2double(get(handles.orighour,'String'));origmin = str2double(get(handles.origmin,'String')); origsec = str2double(get(handles.origsec,'String'));
        disp(['Origin Time '  get(handles.orighour,'String') ':' get(handles.origmin,'String') ':' get(handles.origsec,'String')])
      % read the first sample time 
        fhour = str2double(get(handles.filehour,'String')); fmin = str2double(get(handles.filemin,'String')); fsec = str2double(get(handles.filesec,'String'));
        disp(['First sample time '  get(handles.filehour,'String') ':' get(handles.filemin,'String') ':' get(handles.filesec,'String')])
      % check that data start time is not empty
        if isempty(get(handles.filehour,'String')) || isempty(get(handles.filemin,'String')) || isempty(get(handles.filesec,'String')) 
            errordlg('Data Start Time is not given.','Input Error');
        return
        else
        end

         origintime=((orighour*3600)+(origmin*60)+origsec); firstsampletime=((fhour*3600)+(fmin*60)+fsec); OTsec=origintime-firstsampletime; min_ew=min(ewcor6); max_ew=max(ewcor6);
      % OT
         lc1=[OTsec OTsec]; lc2=[min_ew max_ew];
         TL=handles.tl;
      % TL
         lcTL1=[OTsec+TL OTsec+TL]; lcTL2=[min_ew max_ew];
        
      %% Plot
      % prepare time axis in sec
         tim=(1:1:length(ewcor));
         time_sec=((tim.*dt)-dt);
      % plot CORRECTED data
         axes(handles.ewaxis)
         plot(time_sec,ewcor,'r')
         hold on
         plot(lc1,lc2,'b','LineWidth',4) 
      % Plot TL 
         plot(lcTL1,lcTL2,'b','LineWidth',4) 
         hold off             
         set(handles.ewaxis,'XMinorTick','on')
         grid on
      % title('EW')
      %  NS plot
         axes(handles.nsaxis)
         plot(time_sec,nscor,'r')
         hold on
         plot(lc1,lc2,'b','LineWidth',4) 
      % Plot TL 
         plot(lcTL1,lcTL2,'b','LineWidth',4) 
         hold off             
         set(handles.nsaxis,'XMinorTick','on')
         grid on
      % title('NS')
         axes(handles.veraxis)
         plot(time_sec,vercor,'r')
         hold on
         plot(lc1,lc2,'b','LineWidth',4) 
      % Plot TL 
         plot(lcTL1,lcTL2,'b','LineWidth',4) 
         hold off                      
         set(handles.veraxis,'XMinorTick','on')
         grid on
      % title('Ver')
         xlabel('Seconds')
         ylabel('m/sec')
           set(handles.dstat,'String','Instrument Corrected data',...
                  'FontSize',14,...
                  'FontWeight','bold',...
                  'ForegroundColor','red')

         %  Enable clip...??
%            if (nsclip==1 && ewclip ==1 && verclip==1)
%                on =[handles.cliplvl];
%                enableon(on)
%            else
%            end
              
         % enable allign
           on =[handles.orallign];
           enableon(on)

   end   % end of IF for instrument correction 

    
else   % no prefilter

    disp('This is instrumental correction without prefilter option')
    
    %%
   if (get(handles.skipinst,'Value') == get(handles.skipinst,'Max'))
      % skip instrument correction
        disp('Data are corrected already. Skip instrument correction part')
      % save instrument corrected data  to handles 
        handles.ewcor = ewcounts; handles.nscor = nscounts; handles.vercor=vercounts;
        newsamples=(1:1:max(size(ewcounts))); handles.newsamples=newsamples;
        guidata(hObject,handles)
      % enable allign
        on =[handles.orallign];
        enableon(on)
   else
      %
       switch length(file)
         case 12 % station with 5 character name
           stationpzfilens=[file(1:5)  'BHN.pz']; stationpzfileew=[file(1:5)  'BHE.pz']; stationpzfilever=[file(1:5) 'BHZ.pz'];
         case 11 % station with 4 character name
           stationpzfilens=[file(1:4)  'BHN.pz']; stationpzfileew=[file(1:4)  'BHE.pz']; stationpzfilever=[file(1:4) 'BHZ.pz'];
         case 10
           stationpzfilens=[file(1:3)  'BHN.pz']; stationpzfileew=[file(1:3)  'BHE.pz']; stationpzfilever=[file(1:3) 'BHZ.pz'];
         otherwise
           disp('Error in pole zero file read')
       end
      % Call readpz for 3 comp
          [A0ns,constantns,  nzerns, zeroesns, npolns, polesns, nsclip, valid_datens, digisens_ns, seismsens_ns]  = readpzfile(stationpzfilens);
          [A0ew,constantew,  nzerew, zeroesew, npolew, polesew, ewclip, valid_dateew, digisens_ew, seismsens_ew]  = readpzfile(stationpzfileew);
          [A0ver,constantver,nzerver,zeroesver,npolver,polesver,verclip,valid_datever,digisens_ver,seismsens_ver] = readpzfile(stationpzfilever);
      % Detrend
          disp('Removing Trend')
          nscounts  =  detrend(nscounts); ewcounts  =  detrend(ewcounts); vercounts =  detrend(vercounts);
          disp('   ')
      % Instrumental correction call instcor for 3 comp
          disp('Starting Instrumental correction')
          np=length(nscounts);  % fix to NS comp
          nscor6    = instcor( nscounts,constantns, A0ns, nzerns, zeroesns, npolns, polesns,dt,np);
          ewcor6    = instcor( ewcounts,constantew, A0ew, nzerew, zeroesew, npolew, polesew,dt,np);
          vercor6   = instcor(vercounts,constantver,A0ver,nzerver,zeroesver,npolver,polesver,dt,np);
          disp('Finished Instrumental correction')
          disp('   ')
     % save instrument corrected 
          handles.ewcor = ewcor6; handles.nscor = nscor6; handles.vercor=vercor6;
          newsamples=(1:1:max(size(ewcor6))); handles.newsamples=newsamples;
          guidata(hObject,handles)
     %  save clip info
          if (nsclip==1 && ewclip==1 && verclip==1)
           handles.digisens_ns = digisens_ns;
           handles.seismsens_ns = seismsens_ns;
           handles.digisens_ew = digisens_ew;
           handles.seismsens_ew = seismsens_ew;
           handles.digisens_ver = digisens_ver;
           handles.seismsens_ver = seismsens_ver;
           guidata(hObject,handles)
          else
           disp('Clip info not found')
          end
      % INSTRUMENT CORRECTION END %

      % add OT line
      % read origin time
        orighour = str2double(get(handles.orighour,'String'));origmin = str2double(get(handles.origmin,'String')); origsec = str2double(get(handles.origsec,'String'));
        disp(['Origin Time '  get(handles.orighour,'String') ':' get(handles.origmin,'String') ':' get(handles.origsec,'String')])
      % read the first sample time 
        fhour = str2double(get(handles.filehour,'String')); fmin = str2double(get(handles.filemin,'String')); fsec = str2double(get(handles.filesec,'String'));
        disp(['First sample time '  get(handles.filehour,'String') ':' get(handles.filemin,'String') ':' get(handles.filesec,'String')])
      % check that data start time is not empty
        if isempty(get(handles.filehour,'String')) || isempty(get(handles.filemin,'String')) || isempty(get(handles.filesec,'String')) 
            errordlg('Data Start Time is not given.','Input Error');
        return
        else
        end

         origintime=((orighour*3600)+(origmin*60)+origsec); firstsampletime=((fhour*3600)+(fmin*60)+fsec); OTsec=origintime-firstsampletime; min_ew=min(ewcor6); max_ew=max(ewcor6);
      % OT
         lc1=[OTsec OTsec]; lc2=[min_ew max_ew];
         TL=handles.tl;
      % TL
         lcTL1=[OTsec+TL OTsec+TL]; lcTL2=[min_ew max_ew];

%% Plot
      % prepare time axis in sec
         tim=(1:1:length(ewcor6));
         time_sec=((tim.*dt)-dt);
      % plot CORRECTED data
         axes(handles.ewaxis)
         plot(time_sec,ewcor6,'r')
         hold on
         plot(lc1,lc2,'b','LineWidth',4) 
      % Plot TL 
         plot(lcTL1,lcTL2,'b','LineWidth',4) 
         hold off             
         set(handles.ewaxis,'XMinorTick','on')
         grid on
      % title('EW')
      
      %  NS
         axes(handles.nsaxis)
         plot(time_sec,nscor6,'r')
         hold on
         plot(lc1,lc2,'b','LineWidth',4) 
      % Plot TL 
         plot(lcTL1,lcTL2,'b','LineWidth',4) 
         hold off             
         set(handles.nsaxis,'XMinorTick','on')
         grid on
      % title('NS')
      
      %  VER
         axes(handles.veraxis)
         plot(time_sec,vercor6,'r')
         hold on
         plot(lc1,lc2,'b','LineWidth',4) 
      % Plot TL 
         plot(lcTL1,lcTL2,'b','LineWidth',4) 
         hold off             
         set(handles.veraxis,'XMinorTick','on')
         grid on
      % title('Ver')
         xlabel('Seconds')
         ylabel('m/sec')
      %
         set(handles.dstat,'String','Instrument Corrected data',...
                  'FontSize',14,...
                  'FontWeight','bold',...
                  'ForegroundColor','red')
      %
       on =[handles.orallign];
       enableon(on)
   
   end    % end of IF without prefilter 

   
end  % end of main IF
    

% --- Executes on button press in plcurve.
function plcurve_Callback(hObject, eventdata, handles)
% hObject    handle to plcurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%INSTRUMENT CORRECTION AND FILTERING%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       START        %%%%%%%%%%%%%%%%%%%%%%%%%%%

%READ DATA FROM HANDLES AND put in new variables....
file=handles.file;
stname=handles.stname;

stationpzfilens=[stname  'BHN.pz']
stationpzfileew=[stname  'BHE.pz']
stationpzfilever=[stname 'BHZ.pz']

%%%%%%%%%%% read poles and zeroes
%%%% station name should be available   !!!!

%%%% start ...
try
    
%%%%%%%%%%% read poles and zeroes
%% go in pzfiles
cd pzfiles

pwd

h1=dir(stationpzfilens);
h2=dir(stationpzfileew);
h3=dir(stationpzfilever);

if isempty(h1)
    errstring=[ stationpzfilens   '   file doesn''t exist. Please create and copy to pzfiles folder '];
    errordlg(errstring,'File Error');
    cd ..
  return
elseif isempty(h2) 
    errstring=[ stationpzfileew   '   file doesn''t exist. Please create and copy to pzfiles folder '];
    errordlg(errstring,'File Error');
    cd ..
  return
elseif isempty(h3) 
    errstring=[ stationpzfilever   '   file doesn''t exist. Please create and copy to pzfiles folder '];
    errordlg(errstring,'File Error');
    cd ..
  return
else
    fid = fopen(stationpzfilens,'r');
    aa=fgetl(fid);
    A0ns=str2num(fgetl(fid));
    aa=fgetl(fid);
    constantns=str2num(fgetl(fid));
    
%       zer=fgetl(fid)
%       zer=zer(1:6)
%         if zer~='zeroes' then
%             disp 'error'
%         elseif zer=='zeroes' 
%             disp 'ok'
%         end
         aa=fgetl(fid);
            nzerns=str2num(fgetl(fid));
            
        for p=1:nzerns
            zer=str2num(fgetl(fid));
%             whos zer
            zeroesns(p)=complex(zer(1,1),zer(1,2));
%             whos zeroes
        end
        
        if nzerns == 0
            zeroesns=[];
        end
        
%%% finished with zeroes
%%% read poles
%             pol=fgetl(fid);
%             pol=pol(1:5);

%         if pol~='poles' then
%             disp 'error'
%         elseif pol=='poles' 
%             disp 'ok'
%         end
            aa=fgetl(fid);
            npolns=str2num(fgetl(fid));
            
        for i=1:npolns
            pol=str2num(fgetl(fid));
            polesns(i)=complex(pol(1),pol(2));
        end

        fclose(fid);
%%%%%%%%%%%end with NS        
    fid = fopen(stationpzfileew,'r');
    aa=fgetl(fid);
    A0ew=str2num(fgetl(fid));
    aa=fgetl(fid);
    constantew=str2num(fgetl(fid));
    aa=fgetl(fid);
    
            nzerew=str2num(fgetl(fid));
        for p=1:nzerew
            zer=str2num(fgetl(fid));
            zeroesew(p)=complex(zer(1,1),zer(1,2));
        end
        
        if nzerew == 0
            zeroesew=[];
        end
%%% finished with zeroes
%%% read poles
   aa=fgetl(fid);
            npolew=str2num(fgetl(fid));
        for i=1:npolew
            pol=str2num(fgetl(fid));
            polesew(i)=complex(pol(1),pol(2));
        end

        fclose(fid);
%%%%%%%%%%%%finished with EW
    fid = fopen(stationpzfilever,'r');
    aa=fgetl(fid);
    A0ver=str2num(fgetl(fid));
    aa=fgetl(fid);
    constantver=str2num(fgetl(fid));
    aa=fgetl(fid);

            nzerver=str2num(fgetl(fid));
        for p=1:nzerver
            zer=str2num(fgetl(fid));
            zeroesver(p)=complex(zer(1,1),zer(1,2));
        end
        
        if nzerver == 0
            zeroesver=[];
        end

%%% finished with zeroes
%%% read poles
    aa=fgetl(fid);

            npolver=str2num(fgetl(fid));
        for i=1:npolver
            pol=str2num(fgetl(fid));
            polesver(i)=complex(pol(1),pol(2));
        end

        fclose(fid);
%%%end of ver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End pole and zero input....
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%% go back to isola
cd ..
%%%%%%%%%%%%
catch
    cd ..
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a_ns=zpk(zeroesns,polesns,A0ns);
% figure(1)
% subplot(2,1,1)
% 
% ev1 = tf(a_ns);%Guralp Velocity
% [mag,phase,w] = bode(ev1, {0.01, 1000});
% w=w*0.159;		%translates rad/s in c/s only for graphing purposes 
% loglog(w,(mag(:))), grid on
% title(['Station ', file(1:3) ,'       Amplitude Response  (NS)'])
% xlabel('Hz')
% subplot(2,1,2)
% loglog(w,(phase(:))), grid on
% xlabel('Hz')
% title('Phase Response (Deg)')

myplresp(zeroesns,polesns,A0ns,stname,' (NS)')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a_ew=zpk(zeroesew,polesew,A0ew);
% figure(2)
% subplot(2,1,1)
% 
% ev1 = tf(a_ew);%Guralp Velocity
% [mag,phase,w] = bode(ev1, {0.01, 1000});
% w=w*0.159;		%translates rad/s in c/s only for graphing purposes
% loglog(w,(mag(:))), grid on
% title(['Station ', file(1:3) ,'       Amplitude Response  (EW)'])
% xlabel('Hz')
% subplot(2,1,2)
% loglog(w,(phase(:))), grid on
% xlabel('Hz')
% title('Phase Response (Deg)')

myplresp(zeroesew,polesew,A0ew,stname,' (EW)')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a_ver=zpk(zeroesver,polesver,A0ver);
% figure(3)
% subplot(2,1,1)
% 
% ev1 = tf(a_ver);%Guralp Velocity
% [mag,phase,w] = bode(ev1, {0.01, 1000});
% w=w*0.159;		%translates rad/s in c/s only for graphing purposes
% loglog(w,(mag(:))), grid on
% title(['Station ', file(1:3) ,'       Amplitude Response   (Z)'])
% xlabel('Hz')
% subplot(2,1,2)
% loglog(w,(phase(:))), grid on
% xlabel('Hz')
% title('Phase Response (Deg)')

myplresp(zeroesver,polesver,A0ver,stname,' (Z)')



% --- Executes on button press in skipinst.
function skipinst_Callback(hObject, eventdata, handles)
% hObject    handle to skipinst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skipinst

if (get(handles.skipinst,'Value') == get(handles.skipinst,'Max'))

%READ DATA FROM HANDLES AND put in new variables....
ewcounts=handles.ew;
nscounts=handles.ns;
vercounts=handles.ver;
dt=handles.dt
file=handles.file;
%skip instrument correction
disp('Data are corrected already. Skip instrument correction part')

%save instrument corrected - filtered data  to handles 
handles.ewcor = ewcounts;
handles.nscor = nscounts;
handles.vercor=vercounts;
newsamples=(1:1:max(size(ewcounts)));
handles.newsamples=newsamples;
guidata(hObject,handles)
   
    
%%%enable allign
on =[handles.orallign];
enableon(on)
else
    
off =[handles.orallign];
enableoff(off)
    
   
end



function lcut2_Callback(hObject, eventdata, handles)
% hObject    handle to lcut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcut2 as text
%        str2double(get(hObject,'String')) returns contents of lcut2 as a double


% --- Executes during object creation, after setting all properties.
function lcut2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hcut1_Callback(hObject, eventdata, handles)
% hObject    handle to hcut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hcut1 as text
%        str2double(get(hObject,'String')) returns contents of hcut1 as a double


% --- Executes during object creation, after setting all properties.
function hcut1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hcut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function taper_Callback(hObject, eventdata, handles)
% hObject    handle to taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of taper as text
%        str2double(get(hObject,'String')) returns contents of taper as a double


% --- Executes during object creation, after setting all properties.
function taper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
