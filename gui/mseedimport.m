function varargout = mseedimport(varargin)
% mseedimportM-file for mseedimport.fig
%      mseedimport, by itself, creates a new mseedimportor raises the existing
%      singleton*.
%
%      H = mseedimportreturns the handle to a new mseedimportor the handle to
%      the existing singleton*.
%
%      mseedimport('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in mseedimport.M with the given input arguments.
%
%      mseedimport('Property','Value',...) creates a new mseedimportor raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mseedimport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mseedimport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mseedimport

% Last Modified by GUIDE v2.5 09-Nov-2020 22:40:24


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mseedimport_OpeningFcn, ...
                   'gui_OutputFcn',  @mseedimport_OutputFcn, ...
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


% --- Executes just before mseedimportis made visible.
function mseedimport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mseedimport(see VARARGIN)

% Choose default command line output for mseedimport
handles.output = hObject;

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

% UIWAIT makes mseedimportwait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mseedimport_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is mseedimport 10/11/2020');
disp('Based on miniseed read code of François Beauducel');
disp('Available here: https://www.mathworks.com/matlabcentral/fileexchange/28803-rdmseed-and-mkmseed-read-and-write-miniseed-files');


% --- Executes on button press in readew.
function readew_Callback(hObject, eventdata, handles)
% hObject    handle to readew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%  isola path
path1=handles.path1;
mainpath=handles.mainpath;
%%
timerefns=handles.timerefns;

%% 

cd(path1)

[file1,path1] = uigetfile([ '*.*'],'Import mseed file',400,400);
      
   lopa = [path1 file1]
   
         try 
             [X,I] = rdmseed(lopa);
             samples_ew=cat(1,X.d);
         catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
          return
         end

cd(mainpath)

%%%%%%%%%%%%%%%
%maxnssamples=N(1,1).NumberSamples;
dt = 1/X(1,1).SampleRate;
%set(handles.sfreq,'String',num2str(X(1,1).SampleRate))

time_sec = cat(1,X.t);
% format long
% min(cat(1,X.t))
dv=datevec(min(cat(1,X.t)));

doy = day(datetime(dv),'dayofyear');

%%
istew=datenum(dv);

if timerefns ~= istew
% find file start time....        
   set(handles.ewtime,'String',[datestr(min(cat(1,X.t)),'dd-mmm-yyyy') ' (' num2str(doy,'%03u') ') '  datestr(min(cat(1,X.t)),'HH:MM:SS.FFF')]);
   set(handles.ewtime,'ForegroundColor','red')
   set(handles.nstime,'ForegroundColor','red')
else
   set(handles.ewtime,'String',[datestr(min(cat(1,X.t)),'dd-mmm-yyyy') ' (' num2str(doy,'%03u') ') '  datestr(min(cat(1,X.t)),'HH:MM:SS.FFF')]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%this is the sample number ....
maxnssamples=length(time_sec);tim=(1:1:maxnssamples);time_sec=((tim.*dt)-dt)';
scode=strrep(char(I.ChannelFullName),':',' ');
SSCH=textscan(scode,'%s');sta=SSCH{1}{2};chan2=SSCH{1}{3};
set(handles.ewname,'String',[sta '  ' chan2])

%% plot gaps and overlaps
% 
% 		for i = 1:length(I.GapBlockIndex)
% 			plot(I.GapTime(i),X(I.GapBlockIndex(i)).d(1),'*r')
% 		end
% 		for i = 1:length(I.OverlapBlockIndex)
% 			plot(I.OverlapTime(i),X(I.OverlapBlockIndex(i)).d(1),'og')
% 		end

if ~isempty(I.GapBlockIndex)
    warndlg('Gaps detected BE CAREFUL with this file','Warning');
    
elseif ~isempty(I.OverlapBlockIndex)
    warndlg('Overlaps detected BE CAREFUL with this file','Warning');
    
end


%%%%plotting
axes(handles.ewaxis)
plot(time_sec,samples_ew,'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('NS')
xlabel('Time (sec)')
ylabel('Counts')



%save RAW data to handles 
handles.path1=path1;
handles.mainpath=mainpath;
handles.ew = samples_ew;
handles.istew=istew;
handles.dt=dt;
handles.timerefew=istew;
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

[file1,path1] = uigetfile([ '*.*'],'Import mseed  file',400,400);
      
   lopa = [path1 file1]
   
         try 
             
             [X,I] = rdmseed(lopa);
            samples_ns=cat(1,X.d);
          catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
          return
         end

cd(mainpath)

%%%%%%%%%%%%%%%
%maxnssamples=N(1,1).NumberSamples

dt = 1/X(1,1).SampleRate;
set(handles.sfreq,'String',num2str(X(1,1).SampleRate))

time_sec = cat(1,X.t);
% format long
% min(cat(1,X.t))

dv=datevec(min(cat(1,X.t)));

doy = day(datetime(dv),'dayofyear');

istns=datenum(dv);

%this is the sample number ....
maxnssamples=length(time_sec);tim=(1:1:maxnssamples);time_sec=((tim.*dt)-dt)';

scode=strrep(char(I.ChannelFullName),':',' ');
SSCH=textscan(scode,'%s');sta=SSCH{1}{2};chan2=SSCH{1}{3};

set(handles.nsname,'String',[sta '  ' chan2])

%% find file start time....        
%set(handles.nstime,'String',[year month ' ' day ' ' hour ':' minute ':' seconds]);
% set(handles.nstime,'String',[num2str(dv(1)) '/' num2str(dv(2)) '/' num2str(dv(3)) ' ' num2str(dv(4)) ':' num2str(dv(5)) ':' num2str(dv(6))]);

set(handles.nstime,'String',[datestr(min(cat(1,X.t)),'dd-mmm-yyyy') ' (' num2str(doy,'%03u') ') '  datestr(min(cat(1,X.t)),'HH:MM:SS.FFF')]);

%% plot gaps and overlaps
% 
% 		for i = 1:length(I.GapBlockIndex)
% 			plot(I.GapTime(i),X(I.GapBlockIndex(i)).d(1),'*r')
% 		end
% 		for i = 1:length(I.OverlapBlockIndex)
% 			plot(I.OverlapTime(i),X(I.OverlapBlockIndex(i)).d(1),'og')
% 		end

if ~isempty(I.GapBlockIndex)
    warndlg('Gaps detected BE CAREFUL with this file','Warning');
    
elseif ~isempty(I.OverlapBlockIndex)
    warndlg('Overlaps detected BE CAREFUL with this file','Warning');
    
end



%% plotting
axes(handles.nsaxis)
plot(time_sec,samples_ns,'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')
xlabel('Time (sec)')
ylabel('Counts')

%save RAW data to handles 
handles.stanameonly=sta;
handles.path1=path1;
handles.mainpath=mainpath;
handles.ns = samples_ns;
handles.istns=istns;
handles.dt=dt;
handles.timerefns=istns;
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

%%%read ref time ...
timerefns=handles.timerefns;
timerefew=handles.timerefew;
%

cd(path1)

[file1,path1] = uigetfile([ '*.*'],'Import mseed  file',400,400);
      
   lopa = [path1 file1]
   
         try 
             
             [X,I] = rdmseed(lopa);
            samples_ver=cat(1,X.d);
          catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
          return
         end

cd(mainpath)

%%
%maxnssamples=N(1,1).NumberSamples

dt = 1/X(1,1).SampleRate;
time_sec = cat(1,X.t);
dv=datevec(min(cat(1,X.t)));
doy = day(datetime(dv),'dayofyear');


%%
istver=datenum(dv);

if istver ~= timerefns || istver ~= timerefew
% find file start time....        
  set(handles.vertime,'String',[datestr(min(cat(1,X.t)),'dd-mmm-yyyy') ' (' num2str(doy,'%03u') ') '  datestr(min(cat(1,X.t)),'HH:MM:SS.FFF')]);
  set(handles.ewtime,'ForegroundColor','red')
  set(handles.nstime,'ForegroundColor','red')
% handles on
  on =[handles.Allign];
  enableon(on)
else
% find file start time....        
  set(handles.vertime,'String',[datestr(min(cat(1,X.t)),'dd-mmm-yyyy') ' (' num2str(doy,'%03u') ') '  datestr(min(cat(1,X.t)),'HH:MM:SS.FFF')]);
% handles on
  on =[handles.cut,handles.saveascii];
  enableon(on)
end
%% 
%this is the sample number ....
maxnssamples=length(time_sec);tim=(1:1:maxnssamples);time_sec=((tim.*dt)-dt)';
scode=strrep(char(I.ChannelFullName),':',' '); SSCH=textscan(scode,'%s');sta=SSCH{1}{2};chan2=SSCH{1}{3};
set(handles.vername,'String',[sta '  ' chan2])

%% plot gaps and overlaps
% 
% 		for i = 1:length(I.GapBlockIndex)
% 			plot(I.GapTime(i),X(I.GapBlockIndex(i)).d(1),'*r')
% 		end
% 		for i = 1:length(I.OverlapBlockIndex)
% 			plot(I.OverlapTime(i),X(I.OverlapBlockIndex(i)).d(1),'og')
% 		end

if ~isempty(I.GapBlockIndex)
    warndlg('Gaps detected BE CAREFUL with this file','Warning');
    
elseif ~isempty(I.OverlapBlockIndex)
    warndlg('Overlaps detected BE CAREFUL with this file','Warning');
    
end

axes(handles.veraxis)
plot(time_sec,samples_ver,'k')
set(handles.veraxis,'XMinorTick','on')
grid on
xlabel('Time (sec)')
ylabel('Counts')

%save RAW data to handles 
handles.path1=path1;
handles.mainpath=mainpath;
handles.ver = samples_ver;
handles.istver=istver;
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
stname=deblank(handles.stanameonly);
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

if isempty(h) ;
    button=questdlg('Data folder doesn''t exist. ISOLA uses DATA folder to store data files. Create it..?',...
                    'Folder Error','Yes','No','Yes');
                
  if strcmp(button,'Yes')
     disp('Creating folder')
     [s,mess,messid] = mkdir('data')
  %%% save files   
  try
    cd data
    [newfile, newdir] = uiputfile([stname 'unc' '.dat'], 'Save station data as')
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
     [newfile, newdir] = uiputfile([stname 'unc' '.dat'], 'Save station data as')
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
%%%%DATA folder exists save files   
   disp('DATA folder exists. Files will be saved there.')
   try
   cd data
     [newfile, newdir] = uiputfile([stname 'unc' '.dat'], 'Save station data as');
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
%% new ... prepare a file with file start time

k=strfind(newfile,'unc.dat');

if isempty(k)
    errordlg('Filename should be in the form <station name>unc.dat. Please save your file with such a name.','File Error');
   return
else
    
stime_filename=[newfile(1:k-1)  'stime' '.isl'];
start_time=strrep(strrep(strrep(strrep(get(handles.nstime,'String'),':',' '),'-',' '),')',' '),'(',' ')
%%%
disp(['Saving file start time info in file   ' stime_filename])
fid = fopen(stime_filename,'w');
 if ispc
   fprintf(fid,'%s %s\r\n',stname,start_time);
 else
   fprintf(fid,'%s %s\n',stname,start_time);
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
delete(handles.mseedimport)


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

%%
[Y(1,1),Y(1,2),Y(1,3),Y(1,4),Y(1,5),Y(1,6)] =datevec(istns); 
sprintf('Date: %d/%d/%d   Time: %d:%d:%2.3f\n', Y(1,1),Y(1,2), Y(1,3),Y(1,4),Y(1,5),Y(1,6))
[Y(2,1),Y(2,2),Y(2,3),Y(2,4),Y(2,5),Y(2,6)] =datevec(istew); 
sprintf('Date: %d/%d/%d   Time: %d:%d:%2.3f\n', Y(2,1),Y(2,2), Y(2,3),Y(2,4),Y(2,5),Y(2,6))
[Y(3,1),Y(3,2),Y(3,3),Y(3,4),Y(3,5),Y(3,6)] =datevec(istver); 
sprintf('Date: %d/%d/%d   Time: %d:%d:%2.3f\n', Y(3,1),Y(3,2), Y(3,3),Y(3,4),Y(3,5),Y(3,6))

%%
if Y(1,1) ~= Y(2,1) || Y(1,1) ~= Y(3,1)
    disp('Error in file timing')
end
if Y(1,2) ~= Y(2,2) || Y(1,2) ~= Y(3,2)
    disp('Error in file timing')
end
if Y(1,3) ~= Y(2,3) || Y(1,3) ~= Y(3,3)
    disp('Error in file timing')
end

%%  find maximum time and cut

[~,b]=max([istns;istew;istver]);

if b ==1
    %%allign to ns
    %%find cutsamples
     [~, ~, ~, h, mn, s] = datevec(istns-istew);
     secdifne=s+mn*60+h*3600;
     ewcutsamples=round(secdifne/dt);    %ewcutsamples=(nssec-ewsec)/dt round also..!

     [~, ~, ~, h, mn, s] = datevec(istns-istver);
     secdifnv=s+mn*60+h*3600;
     vercutsamples=round(secdifnv/dt);   %vercutsamples=(nssec-versec)/dt

      disp(['Cutting ' num2str(secdifne) ' seconds from EW'])
      disp(['Cutting ' num2str(secdifnv) ' seconds from Ver'])
     
      if ewcutsamples >= length(ew) || vercutsamples >= length(ver)
          disp('Error check your file timing')
          errordlg('Error check your file timing','File time error');
      end
%     
      ew=ew(ewcutsamples+1:length(ew));
      ver=ver(vercutsamples+1:length(ver));
%     
      helpdlg('Changed start time for EW and VER','Start time change');
      set(handles.ewtime,'String',get(handles.nstime,'String'))
      set(handles.vertime,'String',get(handles.nstime,'String'))
    
elseif b == 2
    %%allign to ew
    %%find cutsamples
    [~, ~, ~, h, mn, s] = datevec(istew-istns);
    secdifen=s+mn*60+h*3600;
    nscutsamples=round(secdifen/dt);

    [~, ~, ~, h, mn, s] = datevec(istew-istver);
    secdifev=s+mn*60+h*3600;
    vercutsamples=round(secdifev/dt);
    
    disp(['Cutting ' num2str(secdifen) ' seconds from NS'])
    disp(['Cutting ' num2str(secdifev) ' seconds from Ver'])
    
    if nscutsamples >= length(ns) || vercutsamples >= length(ver)
        disp('Error check your file timing')
        errordlg('Error check your file timing','File time error');
    end

    ns=ns(nscutsamples+1:length(ns));
    ver=ver(vercutsamples+1:length(ver));

    helpdlg('Changed start time for NS and VER','Start time change');
     
    set(handles.nstime,'String',get(handles.ewtime,'String'))
    set(handles.vertime,'String',get(handles.ewtime,'String'))

elseif b ==3
    %%allign to ver
    %%find cutsamples
    [~, ~, ~, h, mn, s] = datevec(istver-istns);
    secdifvn=s+mn*60+h*3600;
    nscutsamples=round(secdifvn/dt);  %    nscutsamples=(versec-nssec)/dt

    [~, ~, ~, h, mn, s] = datevec(istver-istew);
    secdifve=s+mn*60+h*3600;
    ewcutsamples=round(secdifve/dt);  %    ewcutsamples=(versec-ewsec)/dt
    
    disp(['Cutting ' num2str(secdifvn) ' seconds from NS'])
    disp(['Cutting ' num2str(secdifve) ' seconds from EW'])
    
    if nscutsamples >= length(ns) || ewcutsamples >= length(ew)
        disp('Error check your file timing')
        errordlg('Error check your file timing','File time error');
    end

    ew=ew(ewcutsamples+1:length(ew));
    ns=ns(nscutsamples+1:length(ns));
    
    helpdlg('Changed start time for EW and NS','Start time change');
    set(handles.ewtime,'String',get(handles.vertime,'String'))
    set(handles.nstime,'String',get(handles.vertime,'String'))

else
end


%% 
%%%%%%%%automatic cutting at the end of the records based on minimum no of samples....
[amax,b]=max([length(ns) ; length(ew) ; length(ver)]);
[amin,c]=min([length(ns) ; length(ew) ; length(ver)]);

if c==1 %%% ns has less points
    ew=ew(1:length(ns));
    ver=ver(1:length(ns));
helpdlg('Cutting Data according to NS samples','File info');
disp('Cutting Data according to NS samples')
elseif c==2 %%% ew has less points
    ns=ns(1:length(ew));
    ver=ver(1:length(ew));
helpdlg('Cutting Data according to EW samples','File info');
disp('Cutting Data according to EW samples')
elseif c==3 %%% ver has less points
    ns=ns(1:length(ver));
    ew=ew(1:length(ver));
helpdlg('Cutting Data according to Ver samples','File info');
disp('Cutting Data according to Ver samples')
else
end
    

%%
timns=(1:1:length(ns));
timew=(1:1:length(ew));
timver=(1:1:length(ver));
% %prepare new time axis
% %%%%%%%%%read sampling rate
time_secns=((timns.*dt)-dt);
time_secew=((timew.*dt)-dt);
time_secver=((timver.*dt)-dt);

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

%%  save to handles
handles.ew=ew;
handles.ns=ns;
handles.ver=ver;
guidata(hObject,handles)

%%
% handles on
on =[handles.cut,handles.saveascii];
enableon(on)




function [samples,year,month,day,hour,minute,seconds,sfreq,npoints,scode,chan2] = readmseedfile(filename)
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





% --- Executes on button press in Allign.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to Allign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cut.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
