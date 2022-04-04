function varargout = pitsaimport(varargin)
% pitsaimportM-file for pitsaimport.fig
%      pitsaimport, by itself, creates a new pitsaimportor raises the existing
%      singleton*.
%
%      H = pitsaimportreturns the handle to a new pitsaimportor the handle to
%      the existing singleton*.
%
%      pitsaimport('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in pitsaimport.M with the given input arguments.
%
%      pitsaimport('Property','Value',...) creates a new pitsaimportor raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pitsaimport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pitsaimport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pitsaimport

% Last Modified by GUIDE v2.5 04-Jan-2007 11:23:00

% Changed output to N,E,Z  20/10/05
% added time also....


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pitsaimport_OpeningFcn, ...
                   'gui_OutputFcn',  @pitsaimport_OutputFcn, ...
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


% --- Executes just before pitsaimportis made visible.
function pitsaimport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pitsaimport(see VARARGIN)

% Choose default command line output for pitsaimport
handles.output = hObject;

if ~ispc
    disp('Not tested in Linux yet..')
end

% Update handles structure
%%%raw data 
handles.ew = 0;
handles.ns = 0;
handles.ver = 0;

mainpath=pwd;
path1=pwd;

handles.path1=path1;
handles.mainpath=mainpath;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pitsaimportwait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pitsaimport_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is pitsaimport 17/03/2022');


% --- Executes on button press in readew.
function readew_Callback(hObject, eventdata, handles)
% hObject    handle to readew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%% isola path
path1=handles.path1
mainpath=handles.mainpath;

%%%type of sac file

cd(path1)

[file1,path1] = uigetfile([ '*.*'],'Import Pitsa ascii file',400,400);
      
   lopa = [path1 file1]
   
         try 
             
          [samples,yearew,monthew,dayew,hourew,minuteew,secondsew,sfreq,npoints,scode,chan2] = readpitsafile(lopa);
 
          catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
          return
         end

cd(mainpath)

%%%%%%%%%%%%%%%

maxnssamples=max(size(samples));

dt = 1/str2num(sfreq);
set(handles.sfreq,'String',num2str(str2num(sfreq)))

%this is the sample number ....
tim=(1:1:maxnssamples);
time_sec=((tim.*dt)-dt)';

set(handles.ewname,'String',[scode '  ' chan2])

%% find file start time....        
mon=num2mon(str2num(monthew));
doy=day(datetime([str2num(yearew) str2num(monthew) str2num(dayew)]),'dayofyear');
 
n=[deblank(num2str(dayew)) '-' deblank(mon) '-'  deblank(num2str(yearew))  '  ('  deblank(num2str(doy)) ')  '  '  ' deblank(num2str(hourew)) ':'...
        deblank(num2str(minuteew)) ':'  deblank(num2str(secondsew,'%5.2f'))];

set(handles.ewtime,'String',n);



%%%%plotting
axes(handles.ewaxis)
plot(time_sec,samples,'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('NS')
xlabel('Time (sec)')
ylabel('Counts')

%save RAW data to handles 
handles.path1=path1;
handles.mainpath=mainpath;
handles.ew = samples;
%handles.istns=istns;
handles.dt=dt;
%handles.timerefns=datestr(istns);
guidata(hObject,handles)


% handles on
on =[handles.readver];
enableon(on)

% --- Executes on button press in readns.
function readns_Callback(hObject, eventdata, handles)
% hObject    handle to readns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%% isola path
path1=handles.path1
mainpath=handles.mainpath;

%%%type of sac file

cd(path1)

[file1,path1] = uigetfile([ '*.*'],'Import Pitsa ascii file',400,400);
      
   lopa = [path1 file1]
   
         try 
             
          [samples,yearns,monthns,dayns,hourns,minutens,secondsns,sfreq,npoints,scode,chan2] = readpitsafile(lopa);
            
          catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
          return
         end

cd(mainpath)

%%%%%%%%%%%%%%%

maxnssamples=max(size(samples));

dt = 1/str2num(sfreq);
set(handles.sfreq,'String',num2str(str2num(sfreq)))

%this is the sample number ....
tim=(1:1:maxnssamples);
time_sec=((tim.*dt)-dt)';

set(handles.nsname,'String',[scode '  ' chan2])

%% find file start time....        
mon=num2mon(str2num(monthns));
doy=day(datetime([str2num(yearns) str2num(monthns) str2num(dayns)]),'dayofyear');
 
n=[deblank(num2str(dayns)) '-' deblank(mon) '-'  deblank(num2str(yearns))  '  ('  deblank(num2str(doy)) ')  '  '  ' deblank(num2str(hourns)) ':'...
        deblank(num2str(minutens)) ':'  deblank(num2str(secondsns,'%5.2f'))];

%set(handles.nstime,'String',[year month ' ' day ' ' hour ':' minute ':' seconds]);
set(handles.nstime,'String',n);

%%%%plotting
axes(handles.nsaxis)
plot(time_sec,samples,'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')
xlabel('Time (sec)')
ylabel('Counts')

%save RAW data to handles 
handles.path1=path1;
handles.mainpath=mainpath;
handles.ns = samples;
%handles.istns=istns;
handles.dt=dt;
handles.staname=scode;
%handles.timerefns=datestr(istns);
guidata(hObject,handles)


% handles on
on =[handles.readew];
enableon(on)


% --- Executes on button press in readver.
function readver_Callback(hObject, eventdata, handles)
% hObject    handle to readver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%% isola path
path1=handles.path1
mainpath=handles.mainpath;

%%%type of sac file

cd(path1)

[file1,path1] = uigetfile([ '*.*'],'Import Pitsa ascii file',400,400);
      
   lopa = [path1 file1]
   
         try 
             
          [samples,yearz,monthz,dayz,hourz,minutez,secondsz,sfreq,npoints,scode,chan2] = readpitsafile(lopa);
                  
          catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
          return
         end

cd(mainpath)

%%%%%%%%%%%%%%%

maxnssamples=max(size(samples));

dt = 1/str2num(sfreq);
set(handles.sfreq,'String',num2str(str2num(sfreq)))

%this is the sample number ....
tim=(1:1:maxnssamples);
time_sec=((tim.*dt)-dt)';

set(handles.vername,'String',[scode '  ' chan2])

%%%%find file start time....        
%% find file start time....        
mon=num2mon(str2num(monthz));
doy=day(datetime([str2num(yearz) str2num(monthz) str2num(dayz)]),'dayofyear');
 
n=[deblank(num2str(dayz)) '-' deblank(mon) '-'  deblank(num2str(yearz))  '  ('  deblank(num2str(doy)) ')  '  '  ' deblank(num2str(hourz)) ':'...
        deblank(num2str(minutez)) ':'  deblank(num2str(secondsz,'%5.2f'))];

set(handles.vertime,'String',n);

%%%%plotting
axes(handles.veraxis)
plot(time_sec,samples,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('NS')
xlabel('Time (sec)')
ylabel('Counts')

%save RAW data to handles 
handles.path1=path1;
handles.mainpath=mainpath;
handles.ver = samples;
%handles.istns=istns;
handles.dt=dt;
%handles.timerefns=datestr(istns);
guidata(hObject,handles)

% handles on
on =[handles.saveascii];
enableon(on)


% --- Executes on button press in saveascii.
function saveascii_Callback(hObject, eventdata, handles)
% hObject    handle to saveascii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%read data..
ewcounts=handles.ew;
nscounts=handles.ns;
vercounts=handles.ver;

%%%read station name from EW..
%station_name = get(handles.ewname,'String'); 
station_name=strtrim(handles.staname);
%%% read sampling rate
sfreq = str2double(get(handles.sfreq,'String'))
%%%%dt
dt=1/sfreq;
%%%time
tim=(1:1:length(vercounts));
time_sec=((tim.*dt)-dt)';

%whos time_sec ewcounts nscounts vercounts


alld=[time_sec'; nscounts' ; ewcounts' ; vercounts'];    %%% Changed to N,E,Z

%whos alld
%%%%%% now we select folder to save ....ISOLA likes data folder...
%% so we check for it and save files inside...
%check if DATA exists..!
h=dir('data');

if length(h) == 0 
    button=questdlg('Data folder doesn''t exist. ISOLA uses DATA folder to store data files. Create it..?',...
                    'Folder Error','Yes','No','Yes');
                
if strcmp(button,'Yes')
   disp('Creating folder')
   [s,mess,messid] = mkdir('data')
%%% save files   
try
cd data
[newfile, newdir] = uiputfile([station_name 'unc' '.dat'], 'Save station data as');
fid = fopen([newdir newfile],'w');
  if ispc
     fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
  else
     fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
  end
fclose(fid);

infostr= ['Data were written in the file ' newdir newfile ' the column order is time, NS, EW, VER'];

helpdlg(infostr,'File info');
   
cd ..
pwd

catch
cd ..
pwd
end

elseif strcmp(button,'No')
   disp('Canceled folder operation')
   
[newfile, newdir] = uiputfile([station_name 'unc' '.dat'], 'Save station data as');
fid = fopen([newdir newfile],'w');
 if ispc
      fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
 else
      fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
 end
fclose(fid);

infostr= ['Data were written in the file ' newdir newfile ' the column order is time, NS, EW, VER'];

helpdlg(infostr,'File info');
   
end
else
%%%%DATA folder exists......    
%%% save files   
disp('DATA folder exists. Files will be saved there.')
try
cd data
[newfile, newdir] = uiputfile([station_name 'unc' '.dat'], 'Save station data as');
fid = fopen([newdir newfile],'w');
 if ispc
     fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
 else
     fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
 end
fclose(fid);

infostr= ['Data were written in the file ' newdir newfile ' the column order is time, NS, EW, VER'];

helpdlg(infostr,'File info');
   
cd ..
catch
cd ..
pwd
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% new ... prepare a file with file start time
k=strfind(newfile,'unc.dat');

if isempty(k)
    errordlg('Filename should be in the form <station name>unc.dat. Please save your file with such a name.','File Error');
   return
else
    
stime_filename=[newfile(1:k-1)  'stime' '.isl'];
start_time=strrep(strrep(strrep(strrep(get(handles.nstime,'String'),':',' '),'-',' '),')',' '),'(',' ');
%%%
disp(['Saving file start time info in file   ' stime_filename])
fid = fopen(stime_filename,'w');
 if ispc
   fprintf(fid,'%s %s\r\n',station_name,start_time);
 else
   fprintf(fid,'%s %s\n',station_name,start_time);
 end
fclose(fid);
end
% 
% 
% 
pwd



% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.pitsaimport)


function mutual_exclude(off)
set(off,'Value',0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enableon(on)
set(on,'Enable','on')


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
cutpick1 = ginput(1)

cutpoint1=fix(cutpick1(1));

%%% 
ew=ew(1:cutpoint1/dt);   
ns=ns(1:cutpoint1/dt);   
ver=ver(1:cutpoint1/dt);  
% 
tim=(1:1:length(ew));
% 
% %prepare new time axis
% %%%%%%%%%read sampling rate
time_sec=((tim.*dt)-dt);
% 
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

axes(handles.ewaxis)
plot(time_sec,ew,'k')
%plot(data(2,:),'r')
set(handles.ewaxis,'XMinorTick','on')
grid on

axes(handles.veraxis)
plot(time_sec,ver,'k')
%plot(data(1,:),'b')
set(handles.veraxis,'XMinorTick','on')
grid on
xlabel('Seconds')
ylabel('Counts')




% --- Executes on button press in Allign.
function Allign_Callback(hObject, eventdata, handles)
% hObject    handle to Allign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


istew=handles.istew;
istns=handles.istns;
istver=handles.istver;

ew=handles.ew ;
ns=handles.ns ;
ver=handles.ver;
dt=handles.dt;

% disp('ew')
% length(ew)
% size(ew)
% disp('ns')
% length(ns)
% disp('ver')
% length(ver)

datestr(istew)
datestr(istns)
datestr(istver)

[Y(1,1),Y(1,2),Y(1,3),Y(1,4),Y(1,5),Y(1,6)] =datevec(datestr(istns));
[Y(2,1),Y(2,2),Y(2,3),Y(2,4),Y(2,5),Y(2,6)] =datevec(datestr(istew));
[Y(3,1),Y(3,2),Y(3,3),Y(3,4),Y(3,5),Y(3,6)] =datevec(datestr(istver));

%[Y,M,D,H,MI,S] = datevec(A)

if Y(1,1) ~= Y(2,1) || Y(1,1) ~= Y(3,1)
    disp('Error in file timing')
end
    
if Y(1,2) ~= Y(2,2) || Y(1,2) ~= Y(3,2)
    disp('Error in file timing')
end

if Y(1,3) ~= Y(2,3) || Y(1,3) ~= Y(3,3)
    disp('Error in file timing')
end


%convert to seconds since day start...!!
nssec= Y(1,4)*3600+Y(1,5)*60+Y(1,6);
ewsec= Y(2,4)*3600+Y(2,5)*60+Y(2,6);
versec=Y(3,4)*3600+Y(3,5)*60+Y(3,6);

[a,b]=max([nssec;ewsec;versec]);

   
if b ==1
    %%allign to ns
    %%find cutsamples
    ewcutsamples=(nssec-ewsec)/dt
    vercutsamples=(nssec-versec)/dt
    disp(['Cutting ' num2str((nssec-ewsec)) ' seconds from EW'])
    disp(['Cutting ' num2str((nssec-versec)) ' seconds from Ver'])
    
    if ewcutsamples >= length(ew) || vercutsamples >= length(ver)
        disp('Error check your file timing')
        errordlg('Error check your file timing','File time error');
    end
    
    ew=ew(ewcutsamples+1:length(ew));
    ver=ver(vercutsamples+1:length(ver));
    
    helpdlg('Changed start time for EW and VER','Start time change');
    set(handles.ewtime,'String',datestr(istns))
    set(handles.vertime,'String',datestr(istns))

    
elseif b == 2
    %%allign to ew
    %%find cutsamples
    nscutsamples=(ewsec-nssec)/dt
    vercutsamples=(ewsec-versec)/dt
    disp(['Cutting ' num2str((ewsec-nssec)) ' seconds from NS'])
    disp(['Cutting ' num2str((ewsec-versec)) ' seconds from Ver'])
    
    if nscutsamples >= length(ns) || vercutsamples >= length(ver)
        disp('Error check your file timing')
        errordlg('Error check your file timing','File time error');
    end

    ns=ns(nscutsamples+1:length(ns));
    ver=ver(vercutsamples+1:length(ver));

    helpdlg('Changed start time for NS and VER','Start time change');
    set(handles.nstime,'String',datestr(istew))
    set(handles.vertime,'String',datestr(istew))

elseif b ==3
    %%allign to ver
    %%find cutsamples
    nscutsamples=(versec-nssec)/dt
    ewcutsamples=(versec-ewsec)/dt
    disp(['Cutting ' num2str((versec-nssec)) ' seconds from NS'])
    disp(['Cutting ' num2str((versec-ewsec)) ' seconds from EW'])
    
    if nscutsamples >= length(ns) || ewcutsamples >= length(ew)
        disp('Error check your file timing')
        errordlg('Error check your file timing','File time error');
    end

    ew=ew(ewcutsamples+1:length(ew));
    ns=ns(nscutsamples+1:length(ns));
    
    helpdlg('Changed start time for EW and NS','Start time change');
    set(handles.ewtime,'String',datestr(istver))
    set(handles.nstime,'String',datestr(istver))

else
end
% 
% disp('ew')
% length(ew)
% size(ew)
% disp('ns')
% length(ns)
% disp('ver')
% length(ver)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%automatic cutting at the end of the records based on minimum no of samples....
[amax,b]=max([length(ns) ; length(ew) ; length(ver)]);
[amin,c]=min([length(ns) ; length(ew) ; length(ver)]);


if c==1 %%% ns has less points
    ew=ew(1:length(ns));
    ver=ver(1:length(ns));
helpdlg(['Cutting Data according to NS samples'],'File info');
disp('Cutting Data according to NS samples')
elseif c==2 %%% ew has less points
    ns=ns(1:length(ew));
    ver=ver(1:length(ew));
helpdlg(['Cutting Data according to EW samples'],'File info');
disp('Cutting Data according to EW samples')
elseif c==3 %%% ver has less points
    ns=ns(1:length(ver));
    ew=ew(1:length(ver));
helpdlg(['Cutting Data according to Ver samples'],'File info');
disp('Cutting Data according to Ver samples')
else
end
   
length(ns) 
length(ew) 
length(ver)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timns=(1:1:length(ns));
timew=(1:1:length(ew));
timver=(1:1:length(ver));
% 
% %prepare new time axis
% %%%%%%%%%read sampling rate
time_secns=((timns.*dt)-dt);
time_secew=((timew.*dt)-dt);
time_secver=((timver.*dt)-dt);

%%%%%%%%% 
axes(handles.nsaxis)
plot(time_secns,ns,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on

axes(handles.ewaxis)
plot(time_secew,ew,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on

axes(handles.veraxis)
plot(time_secver,ver,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
xlabel('Seconds')
ylabel('Counts')


%%%%%%%%%%%%%%%%%%%%  save to handles
% 
handles.ew=ew;
handles.ns=ns;
handles.ver=ver;
guidata(hObject,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% handles on
on =[handles.cut,handles.saveascii];
enableon(on)



function [samples,year,month,day,hour,minute,seconds,sfreq,npoints,scode,chan2] = readpitsafile(filename)
% ReadGCFFile
%
%   [SAMPLES,STREAMID,SPS,IST] = READGCFFILE(filename)
%
fid = fopen(filename);

timest=fgetl(fid);
year=timest(13:16);
month=timest(18:19);
day=timest(21:22);

hour=timest(24:25);
minute=timest(27:28);
seconds=timest(30:35);


sampfrq=fgetl(fid);
sfreq=sampfrq(12:18);

ndat=fgetl(fid);
npoints=ndat(7:12);

stationcode=fgetl(fid);
scode=stationcode(15:18);

channel=fgetl(fid);
chan1=channel(18:18);
chan2=channel(21:21);


samples = fscanf(fid,'%i');

%whos samples

fclose(fid);


function mon = num2mon(n)
 
switch n
   case 1
      mon='Jan';
   case 2
      mon='Feb';
   case 3
      mon='Mar';
   case 4
      mon='Apr';
   case 5
      mon='May';
   case 6
      mon='Jun';
   case 7
      mon='Jul';
   case 8
      mon='Aug';
   case 9
      mon='Sep';
   case 10
      mon='Oct';
   case 11
      mon='Nov';
   case 12
      mon='Dec';
      
    otherwise
      disp('Unknown month !!')
end


