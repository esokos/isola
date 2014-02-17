function varargout = gcfimport(varargin)
% GCFIMPORT M-file for gcfimport.fig
%      GCFIMPORT, by itself, creates a new GCFIMPORT or raises the existing
%      singleton*.
%
%      H = GCFIMPORT returns the handle to a new GCFIMPORT or the handle to
%      the existing singleton*.
%
%      GCFIMPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GCFIMPORT.M with the given input arguments.
%
%      GCFIMPORT('Property','Value',...) creates a new GCFIMPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gcfimport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gcfimport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gcfimport

% Last Modified by GUIDE v2.5 14-Dec-2005 23:45:32


% Changed output to N,E,Z  20/10/05
% added time also....


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gcfimport_OpeningFcn, ...
                   'gui_OutputFcn',  @gcfimport_OutputFcn, ...
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


% --- Executes just before gcfimport is made visible.
function gcfimport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gcfimport (see VARARGIN)

% Choose default command line output for gcfimport
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

% UIWAIT makes gcfimport wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gcfimport_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is gcfimport 03/01/07');

% --- Executes on button press in readew.
function readew_Callback(hObject, eventdata, handles)
% hObject    handle to readew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%read ref time ...
timerefns=handles.timerefns;

% Path
path1=handles.path1
mainpath=handles.mainpath

%%% Station name
use_name=get(handles.usename,'Value')

cd(path1)

[file1,path1] = uigetfile([ '*.gcf'],'Import GCF file',400,400);

   lopa = [path1 file1];
          try 
              [ew,streamidew,spsew,istew] = readgcffile(lopa);
          catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
             return
          end

cd(mainpath)
          
maxewsamples=length(ew);
dt = 1/spsew;
staname=streamidew;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tt=strcmp(datestr(istew),timerefns);
if tt ~= 1
%%% find day of year ...
doy=date2doy(istew);
%%% ...........
%%% prepare string for ewtime
[Y,M,D,H,MI,S] = datevec(istew);
nn=[deblank(num2str(D)) '-' deblank(num2mon(M)) '-'  num2str(Y)  '  ('  deblank(num2str(doy)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S))];

set(handles.ewtime,'String',nn)
set(handles.ewtime,'ForegroundColor','red')
set(handles.nstime,'ForegroundColor','red')
else
%%% find day of year ...
doy=date2doy(istew);
%%% ...........
%%% prepare string for ewtime
[Y,M,D,H,MI,S] = datevec(istew);
nn=[deblank(num2str(D)) '-' deblank(num2mon(M)) '-'  num2str(Y)  '  ('  deblank(num2str(doy)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S))];
 
set(handles.ewtime,'String',nn)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


set(handles.sfreq,'String',num2str(spsew))

if use_name == 1
     newname=get(handles.name,'String')
     set(handles.ewname,'String',newname)
 else
     set(handles.ewname,'String',staname)
end  

      
%this is the sample number ....
tim=(1:1:length(ew));
time_sec=((tim.*dt)-dt);

axes(handles.ewaxis)
plot(time_sec,ew,'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')
xlabel('Time (sec)')
ylabel('Counts')


%save RAW data to handles 
handles.ew = ew;
handles.istew=istew;
handles.spsew=spsew;
handles.timerefew=datestr(istew);
guidata(hObject,handles)

% handles on
on =[handles.readver];
enableon(on)


% --- Executes on button press in readns.
function readns_Callback(hObject, eventdata, handles)
% hObject    handle to readns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Path
path1=handles.path1;
mainpath=handles.mainpath;

%%% Station name
use_name=get(handles.usename,'Value');

cd(path1)

[file1,path1] = uigetfile([ '*.gcf'],'Import GCF file',400,400);

   lopa = [path1 file1]
   
          try 
              [ns,streamidns,spsns,istns] = readgcffile(lopa);
          catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
             return
          end
cd(mainpath)

maxnssamples=length(ns)
streamidns
dt = 1/spsns
staname=streamidns

%%USE HEADER station name
set(handles.name,'String',staname(1:3))

%%% find day of year ...
doy=date2doy(istns)
%%% ...........
%%% prepare string for nstime
[Y,M,D,H,MI,S] = datevec(istns);
nn=[deblank(num2str(D)) '-' deblank(num2mon(M)) '-'  num2str(Y)  '  ('  deblank(num2str(doy)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S))];

set(handles.nstime,'String',nn)
set(handles.sfreq,'String',num2str(spsns))

if use_name == 1
     newname=get(handles.name,'String');
     set(handles.nsname,'String',newname)
 else
     set(handles.nsname,'String',staname)
end  


%this is the sample number ....
tim=(1:1:length(ns));
time_sec=((tim.*dt)-dt);

axes(handles.nsaxis)
plot(time_sec,ns,'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')
xlabel('Time (sec)')
ylabel('Counts')

%save RAW data to handles 
handles.path1=path1;
handles.mainpath=mainpath;
handles.ns = ns;
handles.istns=istns;
handles.spsns=spsns;

handles.dt=dt;
handles.timerefns=datestr(istns);
guidata(hObject,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% handles on
on =[handles.readew];
enableon(on);

% --- Executes on button press in readver.
function readver_Callback(hObject, eventdata, handles)
% hObject    handle to readver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ew=handles.ew ;
ns=handles.ns ;

% Path
path1=handles.path1
mainpath=handles.mainpath

use_name=get(handles.usename,'Value');



%%%read ref time ...
timerefns=handles.timerefns;
timerefew=handles.timerefew;

cd(path1)

[file1,path1] = uigetfile([ '*.gcf'],'Import GCF file',400,400);

   lopa = [path1 file1];
           try 
              [ver,streamidver,spsver,istver] = readgcffile(lopa);
           catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
             return
           end
 
cd(mainpath)
           
maxversamples=length(ver);
dt = 1/spsver;
staname=streamidver;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tt1=strcmp(datestr(istver),timerefns);
tt2=strcmp(datestr(istver),timerefew);

if tt1 ~= 1 || tt2 ~=1 
%%% find day of year ...
doy=date2doy(istver);
%%% ...........
%%% prepare string for vertime
[Y,M,D,H,MI,S] = datevec(istver);
nn=[deblank(num2str(D)) '-' deblank(num2mon(M)) '-'  num2str(Y)  '  ('  deblank(num2str(doy)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S))];
  
set(handles.vertime,'String',nn,'ForegroundColor','red')
set(handles.ewtime,'ForegroundColor','red')
set(handles.nstime,'ForegroundColor','red')
% handles on
on =[handles.Allign];
enableon(on)
else
%%% find day of year ...
doy=date2doy(istver);
%%% ...........
%%% prepare string for vertime
[Y,M,D,H,MI,S] = datevec(istver);
nn=[deblank(num2str(D)) '-' deblank(num2mon(M)) '-'  num2str(Y)  '  ('  deblank(num2str(doy)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S))];
set(handles.vertime,'String',nn)

% handles on
on =[handles.cut,handles.saveascii];
enableon(on)


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.sfreq,'String',num2str(spsver))

if use_name == 1
     newname=get(handles.name,'String');
     set(handles.vername,'String',newname)
 else
     set(handles.vername,'String',staname)
end  

      
%this is the sample number ....
tim=(1:1:length(ver));
time_sec=((tim.*dt)-dt);

axes(handles.veraxis)
plot(time_sec,ver,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
ylabel('Counts')

%save RAW data to handles 
handles.ver = ver;
handles.istver=istver;
handles.spsver=spsver;
guidata(hObject,handles)

% --- Executes on button press in saveascii.
function saveascii_Callback(hObject, eventdata, handles)
% hObject    handle to saveascii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%% read data.....
ewcounts=handles.ew;
nscounts=handles.ns;
vercounts=handles.ver;

use_name=get(handles.usename,'Value');

% if length(nscounts) ~= length(ewcounts) || length(nscounts) ~= length(vercounts)
%     
%     errordlg('Data have different length use Cut','Length Error');
%     
% else

%%%read station name ....

if use_name == 1
     station_name=get(handles.name,'String');
 else
     station_name = get(handles.nsname,'String');
end  




%%% read sampling rate
sfreq = str2double(get(handles.sfreq,'String'))
%%%%dt
dt=1/sfreq;
%%%time
tim=(1:1:length(vercounts));
time_sec=((tim.*dt)-dt)';

whos time_sec ewcounts nscounts vercounts

alld=[time_sec'; nscounts'; ewcounts' ; vercounts'];   %%% Changed to N,E,Z

whos alld

%%%%%% now we select folder to save ....ISOLA likes data folder...
%% so we check for it and save files inside...
%check if DATA exists..!
h=dir('data');

if length(h) == 0;
    button=questdlg('Data folder doesn''t exist. ISOLA uses DATA folder to store data files. Create it..?',...
                    'Folder Error','Yes','No','Yes');
                
if strcmp(button,'Yes')
   disp('Creating folder')
   [s,mess,messid] = mkdir('data')

%%% save files   
try
cd data
[newfile, newdir] = uiputfile([station_name(1:3) 'unc' '.dat'], 'Save station data as');
fid = fopen([newdir newfile],'w');
 if  ispc
   fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%
 else
   fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%
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

[newfile, newdir] = uiputfile([station_name(1:3) 'unc' '.dat'], 'Save station data as');
fid = fopen([newdir newfile],'w');
 if ispc
  fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%
 else
  fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%
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
[newfile, newdir] = uiputfile([station_name(1:3) 'unc' '.dat'], 'Save station data as');
fid = fopen([newdir newfile],'w');
 if ispc
     fprintf(fid,'%e     %e     %e     %e\r\n',alld);   %%%%%
 else
     fprintf(fid,'%e     %e     %e     %e\n',alld);   %%%%%
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
%%%% new ... prepare a file with file start time
pwd
stime_filename=[station_name(1:3) 'stime' '.isl']
start_time=strrep(strrep(strrep(strrep(get(handles.nstime,'String'),':',' '),'-',' '),')',' '),'(',' ')
%%%%
disp(['Saving file start time info in file   ' stime_filename])
fid = fopen(stime_filename,'w');
 if ispc
   fprintf(fid,'%s %s\r\n',station_name(1:3),start_time)
 else
   fprintf(fid,'%s %s\n',station_name(1:3),start_time)
 end
fclose(fid);

% end

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.gcfimport)



function [samples,streamID,sps,ist] = readgcffile(filename)
% ReadGCFFile
%
%   [SAMPLES,STREAMID,SPS,IST] = READGCFFILE(filename)
%
%   Reads in the specified GCF formatted file, and returns:
%     Samples - an array of all samples in file
%     Stream ID (string up to 6 characters)
%     SPS - sample rate of data in SAMPLES
%     IST - start time of data, as serial date number
%
%   Data in file is assumed to be continuous, and contain data for only one stream.
%   blocks are assumed to be in incremental time sequence only.
%
%   example:
%   [samples,streamid,sps,ist]=readgcffile('test.gcf');
%
%   M. McGowan, Guralp Systems Ltd. email: mmcgowan@guralp.com

fid = fopen(filename,'r','ieee-be');
if fid==-1,
    [p,n,e]=fileparts(filename);
    if ~strcmpi(e,'.gcf'),
        fname2 = [filename,'.gcf'];
        fid = fopen(fname2,'r','ieee-be');
    end
end
if fid==-1,
    error(['Unable to open file "',filename,'"']);
    return; 
end

samples = [];

% read in header for this file to extract stream info
% This assumes that the file contains incremental
% sample data for one stream only (i.e. with a fixed sample rate and StreamID )
sysID = dec2base(fread(fid,1,'uint32'),36);
streamID = dec2base(fread(fid,1,'uint32'),36);
date = fread(fid,1,'ubit15');
time = fread(fid,1,'ubit17');
reserved = fread(fid,1,'uint8');
sps = fread(fid,1,'uint8');
frewind(fid);

% Convert GCF coded time to Matlab coded time
hours = floor(time / 3600);
mins = rem(time,3600);
ist = datenum(1989,11,17, hours, floor(mins / 60), rem(mins,60) ) + date;

% to read the file, first create the array to handle the entire file's samples,
% then read in block by block, copying into the array in the correct place.
sampcount=samplesinfile(fid);
samples=zeros(sampcount,1);

sampcount=1;
while ~feof(fid)
   blocksamples = readgcfblock(fid);
   samples(sampcount:sampcount+length(blocksamples)-1) = blocksamples;
   sampcount = sampcount + length(blocksamples);
end
fclose(fid);


function samps = readgcfblock(fid)
sysid = fread(fid,1,'uint32',9);	% the '9' skips the next 9 bytes
if feof(fid)
   samps = [];
   return 
end
samplerate = fread(fid,1,'uint8');
compressioncode = fread(fid,1,'uint8');
numrecords = fread(fid,1,'uint8');

if (samplerate ~= 0),
   fic = fread(fid,1,'int32');
   switch compressioncode
   case 1,
      diffs = fread(fid,numrecords,'int32');
   case 2,
      diffs = fread(fid,numrecords*2,'int16');
   case 4,
      diffs = fread(fid,numrecords*4,'int8');
   end
   ric = fread(fid,1,'int32',1000-numrecords*4);
else
   status = fread(fid,numrecords*4,'uchar');
end

diffs(1) = fic;
samps = cumsum(diffs);



function samps = samplesinfile(fid)
fseek(fid,14,'bof');
% Read number-of-records and compression-code of every block into an array
nr = fread(fid,'uint16',1022);
% Separate number-of-records and compression-code from the 16 bit value read
cc = bitshift(nr,-8);
nr = bitand(nr,255);
% sum up the number of samples in each block
samps=sum(cc.*nr);
frewind(fid);


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
%%% find day of year ...
doy=date2doy(istns)
%%% ...........
%%% prepare string for nstime
[Y,M,D,H,MI,S] = datevec(istns);
nn=[deblank(num2str(D)) '-' deblank(num2mon(M)) '-'  num2str(Y)  '  ('  deblank(num2str(doy)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S))];
        
        set(handles.nstime,'String',nn)
    set(handles.ewtime,'String',nn)
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
%%% find day of year ...
doy=date2doy(istew)
%%% ...........
%%% prepare string for nstime
[Y,M,D,H,MI,S] = datevec(istew);
nn=[deblank(num2str(D)) '-' deblank(num2mon(M)) '-'  num2str(Y)  '  ('  deblank(num2str(doy)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S))];
    
    set(handles.nstime,'String',nn)
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
%%% find day of year ...
doy=date2doy(istver)
%%% ...........
%%% prepare string for nstime
[Y,M,D,H,MI,S] = datevec(istver);
nn=[deblank(num2str(D)) '-' deblank(num2mon(M)) '-'  num2str(Y)  '  ('  deblank(num2str(doy)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S))];
    
    
    set(handles.ewtime,'String',nn)
    set(handles.nstime,'String',nn)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enableon(on)
set(on,'Enable','on')




% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function name_Callback(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name as text
%        str2double(get(hObject,'String')) returns contents of name as a double


% --- Executes on button press in usename.
function usename_Callback(hObject, eventdata, handles)
% hObject    handle to usename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of usename

use_name=get(handles.usename,'Value');


if use_name == 1

    station_name=get(handles.name,'String');
     set(handles.nsname,'String',station_name)
     set(handles.ewname,'String',station_name)
     set(handles.vername,'String',station_name)
 
     
 else
%     station_name = get(handles.nsname,'String');
end  




function doy = date2doy(d)
dv = datevec(d);
dv(:,4:end) = 0;
d1=datenum(dv);
dv(:,2:end) = 0;
d2=datenum(dv);
doy = d1 - d2;



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
