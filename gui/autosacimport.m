function varargout = autosacimport(varargin)
% AUTOSACIMPORT M-file for autosacimport.fig
%      AUTOSACIMPORT, by itself, creates a new AUTOSACIMPORT or raises the existing
%      singleton*.
%
%      H = AUTOSACIMPORT returns the handle to a new AUTOSACIMPORT or the handle to
%      the existing singleton*.
%
%      AUTOSACIMPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTOSACIMPORT.M with the given input arguments.
%
%      AUTOSACIMPORT('Property','Value',...) creates a new AUTOSACIMPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before autosacimport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to autosacimport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help autosacimport

% Last Modified by GUIDE v2.5 17-Nov-2011 19:40:26

%using SAC routines from SACLAB..........http://gcc.asu.edu/mthorne/saclab/

% Changed output to N,E,Z  20/10/05
% added time also....


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @autosacimport_OpeningFcn, ...
                   'gui_OutputFcn',  @autosacimport_OutputFcn, ...
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


% --- Executes just before autosacimport is made visible.
function autosacimport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to autosacimport (see VARARGIN)

% Choose default command line output for autosacimport
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

% UIWAIT makes autosacimport wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = autosacimport_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is autosacimport 15/09/2012');

%% Changes in SAC input in order to work correctly for SAC files with
%% Origin time as reference time...
%%



% --- Executes on button press in readew.
function readew_Callback(hObject, eventdata, handles)
% hObject    handle to readew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%read ref time ...
timerefns=handles.timerefns;
%
path1=handles.path1
mainpath=handles.mainpath

%%%type of sac file
if get(handles.ascii,'Value') == get(handles.ascii,'Max')
    disp('Ascii Format')
    format=1
elseif get(handles.binary,'Value') == get(handles.binary,'Max')
    disp('Binary Format')
    format=2
end

if get(handles.bigendian,'Value') == get(handles.bigendian,'Max')
    disp('Big Endian')
    endian='big'
elseif get(handles.littleendian,'Value') == get(handles.littleendian,'Max')
    disp('Little Endian')
    endian='lil'
else
        endian='big'

end

cd(path1)


[file1,path1] = uigetfile([ '*.sac'],'Import Sac file');

   lopa = [path1 file1]
   
   
        if format ==2 
          try 
              ew = rsac(lopa,endian);
          catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
             return
          end
         
        else
            disp('Ascii is not implemented yet')
            cd(mainpath)
            return
        end

cd(mainpath)
        
maxewsamples=length(ew(:,2));
dt = lh(ew,'DELTA');
staname=lh(ew,'KSTNM')
compname=lh(ew,'KCMPNM');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%find file start time....        
startyearew=lh(ew,'NZYEAR');startjdayew=lh(ew,'NZJDAY');starthourew=lh(ew,'NZHOUR')
startminew=lh(ew,'NZMIN');startsecew=lh(ew,'NZSEC');startmsecew=lh(ew,'NZMSEC')


if (startmsecew==-12345)
    startmsecew=0
    disp('warning ... msec not defined in sac header. set to 0')
end


%n=[deblank(num2str(startyearew)) '-' deblank(num2str(startjdayew)) '  ' deblank(num2str(starthourew)) ':' deblank(num2str(startminew)) ':'  deblank(num2str(startsecew+startmsecew/1000))]
%whos n
[monthew,dayew]=jul2monthday(startyearew,startjdayew);
istew = datenum([startyearew monthew dayew starthourew startminew startsecew+startmsecew/1000])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tt=strcmp(datestr(istew),timerefns);
if tt ~= 1
set(handles.ewtime,'String',datestr(istew))
set(handles.ewtime,'ForegroundColor','red')
set(handles.nstime,'ForegroundColor','red')
else
set(handles.ewtime,'String',datestr(istew))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(handles.sfreq,'String',num2str(1/dt))

set(handles.ewname,'String',[staname ' ' compname])

% startdateew=lh(ew,'KZDATE')
% starttimeew=lh(ew,'KZTIME')
%startTYPEew=lh(ew,'IZTYPE')

axes(handles.ewaxis)
plot(ew(:,1),ew(:,2),'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')
xlabel('Time (sec)')
ylabel('Counts')

%save RAW data to handles 
handles.ew = ew(:,2);
handles.istew=istew;
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

%%%%% isola path
path1=handles.path1;
mainpath=handles.mainpath;
 
%%%type of sac file
if get(handles.ascii,'Value') == get(handles.ascii,'Max')
    disp('Ascii Format')
    format=1;
elseif get(handles.binary,'Value') == get(handles.binary,'Max')
    disp('Binary Format')
    format=2;
end

if get(handles.bigendian,'Value') == get(handles.bigendian,'Max')
    disp('Big Endian')
    endian='big';
elseif get(handles.littleendian,'Value') == get(handles.littleendian,'Max')
    disp('Little Endian')
    endian='lil';
else
    endian='lil';
    disp('Little Endian')
end

cd(path1)

%% check if raw exists..!
h=dir('raw');

if ~isempty(h);
    cd raw
else
end

%%

[file1,path1] = uigetfile([ '*.sac'],'Import Sac file');

%%% we need to check if it is BH or HH or HN..!!
file1

bhn = findstr('BHN',file1);
hhn = findstr('HHN',file1); 
bhn2 = findstr('bhn',file1);
bhn3 = findstr('HNN',file1);


t1 = isempty(bhn);
t2 = isempty(hhn);
t3 = isempty(bhn2);
t4 = isempty(bhn3);

if ( t1==1  && t2 == 0 )  %% HH case 
        
fileew= strrep(file1,'HHN','HHE');
filez= strrep(file1,'HHN','HHZ');

elseif (t1 == 0  && t2 == 1)  %% BH case 
    
fileew= strrep(file1,'BHN','BHE');
filez= strrep(file1,'BHN','BHZ');
    
elseif (t3==0)  %%bh case

fileew= strrep(file1,'bhn','bhe');
filez= strrep(file1,'bhn','bhz');

elseif (t4==0)  %%HN case
fileew= strrep(file1,'HNN','HNE');
filez= strrep(file1,'HNN','HNZ');
   
else
    %%
disp('Input file doesn''t contain BH or HH or HN as comp description. Autosacimport needs this. Use Sacimport or change filenames.')

end


lopa = [path1 file1]
lopaew = [path1 fileew]
lopaz = [path1 filez]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        if format ==2 
          try 
              ns = rsac(lopa,endian);
          catch

              infostr= ['Error reading ' lopa ' please check that endianess is correct and try again.Check header for LEVEN value.'];
              helpdlg(infostr,'File info');
 
              cd(mainpath)
            return
          end
         
        else
            disp('Ascii is not implemented yet')
             cd(mainpath)
            return
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        if format ==2 
          try 
              ew = rsac(lopaew,endian);
          catch
             infostr= ['Error reading ' lopaew ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
          return
         end
         
        else
            disp('Ascii is not implemented yet')
             cd(mainpath)
            return
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        if format ==2 
          try 
              ver = rsac(lopaz,endian);
          catch
             infostr= ['Error reading ' lopaz ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
          return
         end
         
        else
            disp('Ascii is not implemented yet')
             cd(mainpath)
            return
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
cd(mainpath)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
maxnssamples=length(ns(:,2));

dt = lh(ns,'DELTA');
set(handles.sfreq,'String',num2str(1/dt))

startTYPEns=lh(ns,'IZTYPE');

staname=lh(ns,'KSTNM');
compname=lh(ns,'KCMPNM');
set(handles.nsname,'String',[staname ' ' compname])

%%%%find file start time....    
startyearns=lh(ns,'NZYEAR');
startjdayns=lh(ns,'NZJDAY');
starthourns=lh(ns,'NZHOUR');
startminns=lh(ns,'NZMIN');
startsecns=lh(ns,'NZSEC');
startmsecns=lh(ns,'NZMSEC');

disp(['File start time: ' num2str(startyearns) ' (' num2str(startjdayns) ') ' num2str(starthourns) ':' num2str(startminns) ':' num2str(startsecns) '.' num2str(startmsecns)])
disp(['Station ' staname 'Component ' compname])
disp(['Sampling frequency ' num2str(1/dt) 'Hz. Number of samples  ' num2str(maxnssamples)])


  %%% problem when file reference time is not the file start..!!   try to solve here...
BVALUENS=lh(ns,'B')

if (startmsecns==-12345)
    startmsecns=0.0;
    disp('warning ... msec not defined in sac header. set to 0')
end

% 
if BVALUENS ~= 0    %%% problem when file reference time is not the file start..!!   try to solve here...
disp('Origin time mark found')

[monthns,dayns]=jul2monthday(startyearns,startjdayns);

n = datenum(startyearns,monthns,dayns,starthourns,startminns,((startsecns+startmsecns/1000)+BVALUENS));   %% convert to Serial date number
[Y,M,D,H,MI,S] = datevec(n);   %%% this is our new data start time

mon=num2mon(M);

nn=[deblank(num2str(D)) '-' deblank(mon) '-'  num2str(Y)  ' ('  deblank(num2str(startjdayns)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S,'%5.2f'))];

set(handles.nstime,'String',nn)

istns = datenum([Y,M,D,H,MI,S]);
%timerefns=datestr(istns)
timerefns=istns;


else   %%% BVALUE ==0 start of data file....

[monthns,dayns]=jul2monthday(startyearns,startjdayns);

mon=num2mon(monthns);

n=[deblank(num2str(dayns)) '-' deblank(mon) '-'  deblank(num2str(startyearns))  '  ('  deblank(num2str(startjdayns)) ')  '  '  ' deblank(num2str(starthourns)) ':'...
        deblank(num2str(startminns)) ':'  deblank(num2str(startsecns+startmsecns/1000,'%5.2f'))];

set(handles.nstime,'String',n)

istns = datenum([startyearns monthns dayns starthourns startminns startsecns+startmsecns/1000]);
% [y, m, d, h, mn, s] = datevec(istns);
% sprintf('Date: %d/%d/%d   Time: %d:%d:%2.3f\n', m, d, y, h, mn, s)
%set(handles.nstime,'String',datestr(istns));

%timerefns=datestr(istns)
timerefns=istns;
%%% NSserialdate = datenum(startyearns monthns dayns starthourns startminns (startsecns+startmsecns/1000))


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        EW
maxewsamples=length(ew(:,2));
dt = lh(ew,'DELTA');
staname=lh(ew,'KSTNM');
compname=lh(ew,'KCMPNM');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%find file start time....        
startyearew=lh(ew,'NZYEAR');startjdayew=lh(ew,'NZJDAY');starthourew=lh(ew,'NZHOUR');
startminew=lh(ew,'NZMIN');startsecew=lh(ew,'NZSEC');startmsecew=lh(ew,'NZMSEC');

disp('  ')
disp(['File start time: ' num2str(startyearew) ' (' num2str(startjdayew) ') ' num2str(starthourew) ':' num2str(startminew) ':' num2str(startsecew) '.' num2str(startmsecew)])
disp(['Station ' staname 'Component ' compname])
disp(['Sampling frequency ' num2str(1/dt) 'Hz. Number of samples  ' num2str(maxewsamples)])


BVALUEEW=lh(ew,'B');

if BVALUEEW ~= 0    %%% problem when file reference time is not the file start..!!   try to solve here...
disp('Origin time mark found')

[monthew,dayew]=jul2monthday(startyearew,startjdayew);

n = datenum(startyearew,monthew,dayew,starthourew,startminew,((startsecew+startmsecew/1000)+BVALUEEW));   %% convert to Serial date number
[Y,M,D,H,MI,S] = datevec(n);   %%% this is our new data start time

mon=num2mon(M);

nnew=[deblank(num2str(D)) '-' deblank(mon) '-'  num2str(Y)  '  ('  deblank(num2str(startjdayns)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S,'%5.2f'))];

istew = datenum([Y,M,D,H,MI,S]);
%timerefns=datestr(istns)
timerefew=istew;

else
%n=[deblank(num2str(startyearew)) '-' deblank(num2str(startjdayew)) '  ' deblank(num2str(starthourew)) ':' deblank(num2str(startminew)) ':'  deblank(num2str(startsecew+startmsecew/1000))]
%whos n
[monthew,dayew]=jul2monthday(startyearew,startjdayew);
monew=num2mon(monthew);
istew = datenum([startyearew monthew dayew starthourew startminew startsecew+startmsecew/1000]);
timerefew=istew;

nnew=[deblank(num2str(dayew)) '-' deblank(monew) '-' deblank(num2str(startyearew))  '  ('  deblank(num2str(startjdayew)) ')  '  '  ' deblank(num2str(starthourew)) ':'...
        deblank(num2str(startminew)) ':'  deblank(num2str(startsecew+startmsecew/1000,'%5.2f'))];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tt=strcmp(datestr(istew),timerefns);
if timerefns ~= timerefew
set(handles.ewtime,'String',nnew)
set(handles.ewtime,'ForegroundColor','red')
set(handles.nstime,'ForegroundColor','red')
else
set(handles.ewtime,'String',nnew)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(handles.sfreq,'String',num2str(1/dt))
set(handles.ewname,'String',[staname ' ' compname])



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

maxversamples=length(ver(:,2));
dt = lh(ver,'DELTA');
staname=lh(ver,'KSTNM');
compname=lh(ver,'KCMPNM');


%%%%find file start time....        
startyearver=lh(ver,'NZYEAR');startjdayver=lh(ver,'NZJDAY');starthourver=lh(ver,'NZHOUR');
startminver=lh(ver,'NZMIN');startsecver=lh(ver,'NZSEC');startmsecver=lh(ver,'NZMSEC');


disp('  ')
disp(['File start time: ' num2str(startyearver) ' (' num2str(startjdayver) ') ' num2str(starthourver) ':' num2str(startminver) ':' num2str(startsecver) '.' num2str(startmsecver)])
disp(['Station ' staname 'Component ' compname])
disp(['Sampling frequency ' num2str(1/dt) 'Hz. Number of samples  ' num2str(maxversamples)])



BVALUEVER=lh(ver,'B');

if BVALUEVER ~= 0    %%% problem when file reference time is not the file start..!!   try to solve here...
disp('Origin time mark found')
[monthver,dayver]=jul2monthday(startyearver,startjdayver);
n = datenum(startyearver,monthver,dayver,starthourver,startminver,((startsecver+startmsecver/1000)+BVALUEVER));   %% convert to Serial date number
[Y,M,D,H,MI,S] = datevec(n);   %%% this is our new data start time
mon=num2mon(M);

nnver=[deblank(num2str(D)) '-' deblank(mon) '-'  num2str(Y)  '  ('  deblank(num2str(startjdayns)) ')  '   ' ' deblank(num2str(H)) ':' deblank(num2str(MI)) ':'  deblank(num2str(S,'%5.2f'))];

istver = datenum([Y,M,D,H,MI,S]);
%timerefns=datestr(istns)
timerefver=istver;

else

[monthver,dayver]=jul2monthday(startyearver,startjdayver);
monver=num2mon(monthver);
istver = datenum([startyearver monthver dayver starthourver startminver startsecver+startmsecver/1000]);
timerefver=istver;

nnver=[deblank(num2str(dayver)) '-' deblank(monver) '-'  deblank(num2str(startyearver))   '  ('  deblank(num2str(startjdayver)) ')  '  '  ' deblank(num2str(starthourver)) ':'...
        deblank(num2str(startminver)) ':'  deblank(num2str(startsecver+startmsecver/1000,'%5.2f'))];

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tt1=strcmp(datestr(istver),timerefns);
%tt2=strcmp(datestr(istver),timerefew);

if istver ~= timerefns || istver ~= timerefew
set(handles.vertime,'String',nnver,'ForegroundColor','red')
set(handles.ewtime,'ForegroundColor','red')
set(handles.nstime,'ForegroundColor','red')
% handles on
on =[handles.Allign];
enableon(on)
else
set(handles.vertime,'String',nnver)
% handles on
on =[handles.cut,handles.saveascii];
enableon(on)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.sfreq,'String',num2str(1/dt))
set(handles.vername,'String',[staname ' ' compname])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

% startdatens=lh(ns,'KZDATE')
% starttimens=lh(ns,'KZTIME')




%%%%plotting
ns(1:1,1);
ns(1:1,2);

if (ns(1:1,1) >0) 
axes(handles.nsaxis)
plot(ns(:,1),ns(:,2),'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')
xlabel('Time (sec)')
ylabel('Counts')

%%%%plotting

axes(handles.ewaxis)
plot(ew(:,1),ew(:,2),'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')
xlabel('Time (sec)')
ylabel('Counts')

%%%%plotting
axes(handles.veraxis)
plot(ver(:,1),ver(:,2),'k')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
ylabel('Counts')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else

%%% case that in SAC the reference time is not the start of data...
sfreq = str2double(get(handles.sfreq,'String'));
%%%%dt
dt=1/sfreq;
%%%time
tim=(1:1:length(ns));
time_sec=((tim.*dt)-dt)';

axes(handles.nsaxis)
plot(time_sec,ns(:,2),'k')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')
xlabel('Time (sec)')
ylabel('Counts')

%%%%plotting
axes(handles.ewaxis)

tim=(1:1:length(ew));
time_sec=((tim.*dt)-dt)';

plot(time_sec,ew(:,2),'k')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')
xlabel('Time (sec)')
ylabel('Counts')

%%%%plotting
axes(handles.veraxis)

tim=(1:1:length(ver));
time_sec=((tim.*dt)-dt)';

plot(time_sec,ver(:,2),'k')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
ylabel('Counts')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
%save RAW data to handles 
handles.path1=path1;
handles.mainpath=mainpath;
handles.ns = ns(:,2);
handles.istns=istns;
handles.dt=dt;
handles.timerefns=datestr(istns);
guidata(hObject,handles);
%%%

%save RAW data to handles 
handles.ew = ew(:,2);
handles.istew=istew;
handles.timerefew=datestr(istew);
guidata(hObject,handles)

%save station name to handles 
handles.stanameonly=staname;
guidata(hObject,handles)

%save RAW data to handles 
handles.ver = ver(:,2);
handles.istver=istver;
guidata(hObject,handles)

% handles on
on =[handles.readew,handles.readver];
enableon(on)


% --- Executes on button press in readver.
function readver_Callback(hObject, eventdata, handles)
% hObject    handle to readver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%read ref time ...
timerefns=handles.timerefns;
timerefew=handles.timerefew;
%
path1=handles.path1
mainpath=handles.mainpath


%%%type of sac file
if get(handles.ascii,'Value') == get(handles.ascii,'Max')
    disp('Ascii Format')
    format=1
elseif get(handles.binary,'Value') == get(handles.binary,'Max')
    disp('Binary Format')
    format=2
end

if get(handles.bigendian,'Value') == get(handles.bigendian,'Max')
    disp('Big Endian')
    endian='big'
elseif get(handles.littleendian,'Value') == get(handles.littleendian,'Max')
    disp('Little Endian')
    endian='lil'
else
        endian='lil'

end

cd(path1)

[file1,path1] = uigetfile([ '*.sac'],'Import Sac file');

   lopa = [path1 file1]
   
        if format ==2 
            
           try 
              ver = rsac(lopa,endian);
           catch
             infostr= ['Error reading ' lopa ' please check the file and try again'];
             helpdlg(infostr,'File info');
             cd(mainpath)
             return
           end
         
        else
            disp('Ascii is not implemented yet')
            cd(mainpath)
            return
       end

cd(mainpath)
       
maxewsamples=length(ver(:,2));
dt = lh(ver,'DELTA');
staname=lh(ver,'KSTNM')
compname=lh(ver,'KCMPNM');


%%%%find file start time....        
startyearver=lh(ver,'NZYEAR');startjdayver=lh(ver,'NZJDAY');starthourver=lh(ver,'NZHOUR')
startminver=lh(ver,'NZMIN');startsecver=lh(ver,'NZSEC');startmsecver=lh(ver,'NZMSEC')

if (startmsecver==-12345)
    startmsecver=0
    disp('warning ... msec not defined in sac header. set to 0')
end


% % N = datenum(startyearver,M,D,H,startminver,S)
% n=[deblank(num2str(startyearver)) '-' deblank(num2str(startjdayver)) '  ' deblank(num2str(starthourver)) ':' deblank(num2str(startminver)) ':'  deblank(num2str(startsecver+startmsecver/1000))]
% whos n
[monthver,dayver]=jul2monthday(startyearver,startjdayver);
istver = datenum([startyearver monthver dayver starthourver startminver startsecver+startmsecver/1000])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tt1=strcmp(datestr(istver),timerefns);
tt2=strcmp(datestr(istver),timerefew);

if tt1 ~= 1 || tt2 ~=1 
set(handles.vertime,'String',datestr(istver),'ForegroundColor','red')
set(handles.ewtime,'ForegroundColor','red')
set(handles.nstime,'ForegroundColor','red')
% handles on
on =[handles.Allign];
enableon(on)
else
set(handles.vertime,'String',datestr(istver))
% handles on
on =[handles.cut,handles.saveascii];
enableon(on)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.sfreq,'String',num2str(1/dt))

set(handles.vername,'String',[staname ' ' compname])

% startdatever=lh(ver,'KZDATE')
% starttimever=lh(ver,'KZTIME')
%startTYPEver=lh(ver,'IZTYPE')
    
axes(handles.veraxis)
plot(ver(:,1),ver(:,2),'k')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Time (sec)')
ylabel('Counts')
  

%save RAW data to handles 
handles.ver = ver(:,2);
handles.istver=istver;
guidata(hObject,handles)



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
station_name=deblank(handles.stanameonly);

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

if isempty(h);
    button=questdlg('Data folder doesn''t exist. ISOLA uses DATA folder to store data files. Create it..?',...
                    'Folder Error','Yes','No','Yes');
                
if strcmp(button,'Yes')
   disp('Creating folder')
   [s,mess,messid] = mkdir('data');
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
   disp('Canceled folder creation')
   
[newfile, newdir] = uiputfile([station_name  'unc' '.dat'], 'Save station data as');
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
[newfile, newdir] = uiputfile([station_name  'unc' '.dat'], 'Save station data as');


%%%%          filename check



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

%%%% new ... prepare a file with file start time
pwd

%stime_filename=[station_name  'stime' '.isl']
% Prepare the *stime.isl file based on users unc.dat files
% selection...(added 09/09/2011)
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
 fprintf(fid,'%s %s\r\n',station_name,start_time);
else
 fprintf(fid,'%s %s\n',station_name,start_time);
end
fclose(fid);
end



% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.autosacimport)

% --- Executes on button press in ascii.
function ascii_Callback(hObject, eventdata, handles)
% hObject    handle to ascii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ascii

off =[handles.binary,handles.bigendian,handles.littleendian];
mutual_exclude(off)

set(handles.littleendian,'Enable','Off')
set(handles.bigendian,'Enable','Off')

% --- Executes on button press in binary.
function binary_Callback(hObject, eventdata, handles)
% hObject    handle to binary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of binary
off =[handles.ascii];
mutual_exclude(off)

set(handles.littleendian,'Enable','On')
set(handles.bigendian,'Enable','On')

set(handles.littleendian,'Value',1)
    

    
    

% --- Executes on button press in bigendian.
function bigendian_Callback(hObject, eventdata, handles)
% hObject    handle to bigendian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bigendian
off =[handles.littleendian];
mutual_exclude(off)


% --- Executes on button press in littleendian.
function littleendian_Callback(hObject, eventdata, handles)
% hObject    handle to littleendian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of littleendian
off =[handles.bigendian];
mutual_exclude(off)


function mutual_exclude(off)
set(off,'Value',0)

%RSAC    Read SAC binary files.
%    RSAC('sacfile') reads in a SAC (seismic analysis code) binary
%    format file into a 3-column vector.
%    Column 1 contains time values.
%    Column 2 contains amplitude values.
%    Column 3 contains all SAC header information.
%    Default byte order is big-endian.  M-file can be set to default
%    little-endian byte order.
%
%    usage:  output = rsac('sacfile')
%
%    Examples:
%
%    KATH = rsac('KATH.R');
%    plot(KATH(:,1),KATH(:,2))
%
%    [SQRL, AAK] = rsac('SQRL.R','AAK.R');
%
%    by Michael Thorne (4/2004)   mthorne@asu.edu

function [varargout] = rsac(sacfile,endian);

% for nrecs = 1:nargin

%   sacfile = varargin{nrecs};
%---------------------------------------------------------------------------
%    Default byte-order
%    endian  = 'big'  big-endian byte order (e.g., UNIX)
%            = 'lil'  little-endian byte order (e.g., LINUX)

% endian = 'lil';
sacfile;
endian;
nrecs=1;

if endian == 'big'
  fid = fopen(sacfile,'r','ieee-be'); 
elseif endian == 'lil'
  fid = fopen(sacfile,'r','ieee-le'); 
end

% read in single precision real header variables:
%---------------------------------------------------------------------------
for i=1:70
  h(i) = fread(fid,1,'single');
end

% read in single precision integer header variables:
%---------------------------------------------------------------------------
for i=71:105
  h(i) = fread(fid,1,'int32');
end

% read in logical header variables
%---------------------------------------------------------------------------
for i=106:110
  h(i) = fread(fid,1,'int32');
end

% read in character header variables
%---------------------------------------------------------------------------
for i=111:302
  h(i) = (fread(fid,1,'char'))';
end

% read in amplitudes
%---------------------------------------------------------------------------

%YARRAY     = fread(fid,'single');  % for sac files that have more data
%than what is specified in header..!!

YARRAY     = fread(fid,h(80),'single');

if h(106) == 1
  XARRAY = (linspace(h(6),h(7),h(80)))'; 
   %for kkk=1:h(80)
   %  XARRAY(kkk) = h(6) + kkk*h(1); 
   %end
%     XARRAY = XARRAY';
else
  %errordlg('LEVEN must = 1. Check SAC header.','SAC file not evenly spaced');
  error('LEVEN must = 1; SAC file not evenly spaced')
end 

% add header signature for testing files for SAC format
%---------------------------------------------------------------------------
h(303) = 77;
h(304) = 73;
h(305) = 75;
h(306) = 69;


% whos XARRAY YARRAY
% arrange output files
%---------------------------------------------------------------------------
OUTPUT(:,1) = XARRAY;
OUTPUT(:,2) = YARRAY;
OUTPUT(1:306,3) = h(1:306)';

%pad xarray and yarray with NaN if smaller than header field
if h(80) < 306
  OUTPUT((h(80)+1):306,1) = NaN;
  OUTPUT((h(80)+1):306,2) = NaN;
end

fclose(fid);

varargout{nrecs} = OUTPUT;

% end
%LH    list SAC header
%
%    Read or set matlab variables to SAC header variables from
%    SAC files read in to matlab with rsac.m
%    
%    Examples:
%
%    To list all defined header variables in the file KATH:
%    lh(KATH)  
%
%    To assign the SAC variable DELTA from station KATH to
%    the matlab variable dt:
%
%    dt = lh(KATH,'DELTA');
%
%    To assign the SAC variables STLA and STLO from station KATH
%    to the matlab variables lat and lon:
%
%    [lat,lon] = lh(KATH,'STLA','STLO')
%
%    by Michael Thorne (4/2004)  mthorne@asu.edu
%
%    See also:  RSAC, CH, BSAC, WSAC 

function [varargout] = lh(file,varargin);

% first test to see if the file is indeed a sacfile
%---------------------------------------------------------------------------
if (file(303,3)~=77 & file(304,3)~=73 & file(305,3)~=75 & file(306,3)~=69)
    
 % errordlg('Specified Variable is not in SAC format. Check SAC header.','SAC file error');  
  error('Specified Variable is not in SAC format ...')

end

h(1:306) = file(1:306,3); 


% read real header variables
%---------------------------------------------------------------------------
DELTA = h(1);
if (h(1) ~= -12345 & nargin == 1); disp(sprintf('DELTA      = %0.8g',h(1))); end
DEPMIN = h(2);
if (h(2) ~= -12345 & nargin == 1); disp(sprintf('DEPMIN     = %0.8g',h(2))); end
DEPMAX = h(3);
if (h(3) ~= -12345 & nargin == 1); disp(sprintf('DEPMAX     = %0.8g',h(3))); end
SCALE = h(4);
if (h(4) ~= -12345 & nargin == 1);  disp(sprintf('SCALE      = %0.8g',h(4))); end
ODELTA = h(5);
if (h(5) ~= -12345 & nargin == 1);  disp(sprintf('ODELTA     = %0.8g',h(5))); end
B = h(6);
if (h(6) ~= -12345 & nargin == 1); disp(sprintf('B          = %0.8g',h(6))); end
E = h(7);
if (h(7) ~= -12345 & nargin == 1); disp(sprintf('E          = %0.8g',h(7))); end
O = h(8);
if (h(8) ~= -12345 & nargin == 1); disp(sprintf('O          = %0.8g',h(8))); end 
A = h(9);
if (h(9) ~= -12345 & nargin == 1); disp(sprintf('A          = %0.8g',h(9))); end 
T0 = h(11);
if (h(11) ~= -12345 & nargin == 1); disp(sprintf('T0         = %0.8g',h(11))); end
T1 = h(12);
if (h(12) ~= -12345 & nargin == 1); disp(sprintf('T1         = %0.8g',h(12))); end
T2 = h(13);
if (h(13) ~= -12345 & nargin == 1); disp(sprintf('T2         = %0.8g',h(13))); end
T3 = h(14);
if (h(14) ~= -12345 & nargin == 1); disp(sprintf('T3         = %0.8g',h(14))); end
T4 = h(15);
if (h(15) ~= -12345 & nargin == 1); disp(sprintf('T4         = %0.8g',h(15))); end
T5 = h(16);
if (h(16) ~= -12345 & nargin == 1); disp(sprintf('T5         = %0.8g',h(16))); end
T6 = h(17);
if (h(17) ~= -12345 & nargin == 1); disp(sprintf('T6         = %0.8g',h(17))); end
T7 = h(18);
if (h(18) ~= -12345 & nargin == 1); disp(sprintf('T7         = %0.8g',h(18))); end
T8 = h(19);
if (h(19) ~= -12345 & nargin == 1); disp(sprintf('T8         = %0.8g',h(19))); end
T9 = h(20);
if (h(20) ~= -12345 & nargin == 1); disp(sprintf('T9         = %0.8g',h(20))); end
F = h(21);
if (h(21) ~= -12345 & nargin == 1); disp(sprintf('F          = %0.8g',h(21))); end 
RESP0 = h(22);
if (h(22) ~= -12345 & nargin == 1); disp(sprintf('RESP0      = %0.8g',h(22))); end
RESP1 = h(23);
if (h(23) ~= -12345 & nargin == 1); disp(sprintf('RESP1      = %0.8g',h(23))); end
RESP2 = h(24);
if (h(24) ~= -12345 & nargin == 1); disp(sprintf('RESP2      = %0.8g',h(24))); end
RESP3 = h(25);
if (h(25) ~= -12345 & nargin == 1); disp(sprintf('RESP3      = %0.8g',h(25))); end
RESP4 = h(26);
if (h(26) ~= -12345 & nargin == 1); disp(sprintf('RESP4      = %0.8g',h(26))); end
RESP5 = h(27);
if (h(27) ~= -12345 & nargin == 1); disp(sprintf('RESP5      = %0.8g',h(27))); end
RESP6 = h(28);
if (h(28) ~= -12345 & nargin == 1); disp(sprintf('RESP6      = %0.8g',h(28))); end
RESP7 = h(29);
if (h(29) ~= -12345 & nargin == 1); disp(sprintf('RESP7      = %0.8g',h(29))); end
RESP8 = h(30);
if (h(30) ~= -12345 & nargin == 1); disp(sprintf('RESP8      = %0.8g',h(30))); end
RESP9 = h(31);
if (h(31) ~= -12345 & nargin == 1); disp(sprintf('RESP9      = %0.8g',h(31))); end
STLA = h(32);
if (h(32) ~= -12345 & nargin == 1); disp(sprintf('STLA       = %0.8g',h(32))); end
STLO = h(33);
if (h(33) ~= -12345 & nargin == 1); disp(sprintf('STLO       = %0.8g',h(33))); end
STEL = h(34);
if (h(34) ~= -12345 & nargin == 1); disp(sprintf('STEL       = %0.8g',h(34))); end
STDP = h(35);
if (h(35) ~= -12345 & nargin == 1); disp(sprintf('STDP       = %0.8g',h(35))); end
EVLA = h(36);
if (h(36) ~= -12345 & nargin == 1); disp(sprintf('EVLA       = %0.8g',h(36))); end
EVLO = h(37);
if (h(37) ~= -12345 & nargin == 1); disp(sprintf('EVLO       = %0.8g',h(37))); end
EVEL = h(38);
if (h(38) ~= -12345 & nargin == 1); disp(sprintf('EVEL       = %0.8g',h(38))); end
EVDP = h(39);
if (h(39) ~= -12345 & nargin == 1); disp(sprintf('EVDP       = %0.8g',h(39))); end
MAG = h(40);
if (h(40) ~= -12345 & nargin == 1); disp(sprintf('MAG        = %0.8g',h(40))); end 
USER0 = h(41);
if (h(41) ~= -12345 & nargin == 1); disp(sprintf('USER0      = %0.8g',h(41))); end
USER1 = h(42);
if (h(42) ~= -12345 & nargin == 1); disp(sprintf('USER1      = %0.8g',h(42))); end
USER2 = h(43);
if (h(43) ~= -12345 & nargin == 1); disp(sprintf('USER2      = %0.8g',h(43))); end
USER3 = h(44);
if (h(44) ~= -12345 & nargin == 1); disp(sprintf('USER3      = %0.8g',h(44))); end
USER4 = h(45);
if (h(45) ~= -12345 & nargin == 1); disp(sprintf('USER4      = %0.8g',h(45))); end
USER5 = h(46);
if (h(46) ~= -12345 & nargin == 1); disp(sprintf('USER5      = %0.8g',h(46))); end
USER6 = h(47);
if (h(47) ~= -12345 & nargin == 1); disp(sprintf('USER6      = %0.8g',h(47))); end
USER7 = h(48);
if (h(48) ~= -12345 & nargin == 1); disp(sprintf('USER7      = %0.8g',h(48))); end
USER8 = h(49);
if (h(49) ~= -12345 & nargin == 1);  disp(sprintf('USER8     = %0.8g',h(49))); end
USER9 = h(50);
if (h(50) ~= -12345 & nargin == 1); disp(sprintf('USER9      = %0.8g',h(50))); end
DIST = h(51);
if (h(51) ~= -12345 & nargin == 1); disp(sprintf('DIST       = %0.8g',h(51))); end 
AZ = h(52);
if (h(52) ~= -12345 & nargin == 1); disp(sprintf('AZ         = %0.8g',h(52))); end 
BAZ = h(53);
if (h(53) ~= -12345 & nargin == 1); disp(sprintf('BAZ        = %0.8g',h(53))); end
GCARC = h(54);
if (h(54) ~= -12345 & nargin == 1); disp(sprintf('GCARC      = %0.8g',h(54))); end
DEPMEN = h(57);
if (h(57) ~= -12345 & nargin == 1); disp(sprintf('DEPMEN     = %0.8g',h(57))); end
CMPAZ = h(58);
if (h(58) ~= -12345 & nargin == 1); disp(sprintf('CMPAZ      = %0.8g',h(58))); end
CMPINC = h(59);
if (h(59) ~= -12345 & nargin == 1); disp(sprintf('CMPINC     = %0.8g',h(59))); end
XMINIMUM = h(60);
if (h(60) ~= -12345 & nargin == 1); disp(sprintf('XMINIMUM   = %0.8g',h(60))); end
XMAXIMUM = h(61);
if (h(61) ~= -12345 & nargin == 1); disp(sprintf('XMAXIMUM   = %0.8g',h(61))); end
YMINIMUM = h(62);
if (h(62) ~= -12345 & nargin == 1); disp(sprintf('YMINIMUM   = %0.8g',h(62))); end
YMAXIMUM = h(63);
if (h(63) ~= -12345 & nargin == 1); disp(sprintf('YMAXIMUM   = %0.8g',h(63))); end

% read integer header variables
%---------------------------------------------------------------------------
NZYEAR = round(h(71));
if (h(71) ~= -12345 & nargin == 1); disp(sprintf('NZYEAR     = %d',h(71))); end
NZJDAY = round(h(72));
if (h(72) ~= -12345 & nargin == 1); disp(sprintf('NZJDAY     = %d',h(72))); end
NZHOUR = round(h(73));
if (h(73) ~= -12345 & nargin == 1); disp(sprintf('NZHOUR     = %d',h(73))); end
NZMIN = round(h(74));
if (h(74) ~= -12345 & nargin == 1); disp(sprintf('NZMIN      = %d',h(74))); end
NZSEC = round(h(75));
if (h(75) ~= -12345 & nargin == 1); disp(sprintf('NZSEC      = %d',h(75))); end
NZMSEC = round(h(76));
if (h(76) ~= -12345 & nargin == 1); disp(sprintf('NZMSEC     = %d',h(76))); end
NVHDR = round(h(77));
if (h(77) ~= -12345 & nargin == 1); disp(sprintf('NVHDR      = %d',h(77))); end
NORID = round(h(78));
if (h(78) ~= -12345 & nargin == 1); disp(sprintf('NORID      = %d',h(78))); end
NEVID = round(h(79));
if (h(79) ~= -12345 & nargin == 1); disp(sprintf('NEVID      = %d',h(79))); end
NPTS = round(h(80));
if (h(80) ~= -12345 & nargin == 1); disp(sprintf('NPTS       = %d',h(80))); end
NWFID = round(h(82));
if (h(82) ~= -12345 & nargin == 1); disp(sprintf('NWFID      = %d',h(82))); end
NXSIZE = round(h(83));
if (h(83) ~= -12345 & nargin == 1); disp(sprintf('NXSIZE     = %d',h(83))); end
NYSIZE = round(h(84));
if (h(84) ~= -12345 & nargin == 1); disp(sprintf('NYSIZE     = %d',h(84))); end
IFTYPE = round(h(86));
if (h(86) ~= -12345 & nargin == 1); disp(sprintf('IFTYPE     = %d',h(86))); end
IDEP = round(h(87));
if (h(87) ~= -12345 & nargin == 1); disp(sprintf('IDEP       = %d',h(87))); end
IZTYPE = round(h(88));
if (h(88) ~= -12345 & nargin == 1); disp(sprintf('IZTYPE     = %d',h(88))); end
IINST = round(h(90));
if (h(90) ~= -12345 & nargin == 1); disp(sprintf('IINST      = %d',h(90))); end
ISTREG = round(h(91));
if (h(91) ~= -12345 & nargin == 1); disp(sprintf('ISTREG     = %d',h(91))); end
IEVREG = round(h(92));
if (h(92) ~= -12345 & nargin == 1); disp(sprintf('IEVREG     = %d',h(92))); end
IEVTYP = round(h(93));
if (h(93) ~= -12345 & nargin == 1); disp(sprintf('IEVTYP     = %d',h(93))); end
IQUAL = round(h(94));
if (h(94) ~= -12345 & nargin == 1); disp(sprintf('IQUAL      = %d',h(94))); end
ISYNTH = round(h(95));
if (h(95) ~= -12345 & nargin == 1); disp(sprintf('ISYNTH     = %d',h(95))); end
IMAGTYP = round(h(96));
if (h(96) ~= -12345 & nargin == 1); disp(sprintf('IMAGTYP    = %d',h(96))); end
IMAGSRC = round(h(97));
if (h(97) ~= -12345 & nargin == 1); disp(sprintf('IMAGSRC    = %d',h(97))); end

%read logical header variables
%---------------------------------------------------------------------------
LEVEN = round(h(106));
if (h(106) ~= -12345 & nargin == 1); disp(sprintf('LEVEN      = %d',h(106))); end
LPSPOL = round(h(107));
if (h(107) ~= -12345 & nargin == 1); disp(sprintf('LPSPOL     = %d',h(107))); end
LOVROK = round(h(108));
if (h(108) ~= -12345 & nargin == 1); disp(sprintf('LOVROK     = %d',h(108))); end
LCALDA = round(h(109));
if (h(109) ~= -12345 & nargin == 1); disp(sprintf('LCALDA     = %d',h(109))); end

%read character header variables
%---------------------------------------------------------------------------
KSTNM = char(h(111:118));
if (str2double(KSTNM) ~= -12345 & nargin == 1); disp(sprintf('KSTNM      = %s', KSTNM)); end
KEVNM = char(h(119:134));
if (str2double(KEVNM) ~= -12345 & nargin == 1); disp(sprintf('KEVNM      = %s', KEVNM)); end
KHOLE = char(h(135:142));
if (str2double(KHOLE) ~= -12345 & nargin == 1); disp(sprintf('KHOLE      = %s', KHOLE)); end
KO = char(h(143:150));
if (str2double(KO) ~= -12345 & nargin == 1); disp(sprintf('KO         = %s', KO)); end
KA = char(h(151:158));
if (str2double(KA) ~= -12345 & nargin == 1); disp(sprintf('KA         = %s', KA)); end
KT0 = char(h(159:166));
if (str2double(KT0) ~= -12345 & nargin == 1); disp(sprintf('KT0        = %s', KT0)); end
KT1 = char(h(167:174));
if (str2double(KT1) ~= -12345 & nargin == 1); disp(sprintf('KT1        = %s', KT1)); end
KT2 = char(h(175:182));
if (str2double(KT2) ~= -12345 & nargin == 1); disp(sprintf('KT2        = %s', KT2)); end
KT3 = char(h(183:190));
if (str2double(KT3) ~= -12345 & nargin == 1); disp(sprintf('KT3        = %s', KT3)); end
KT4 = char(h(191:198));
if (str2double(KT4) ~= -12345 & nargin == 1); disp(sprintf('KT4        = %s', KT4)); end
KT5 = char(h(199:206));
if (str2double(KT5) ~= -12345 & nargin == 1); disp(sprintf('KT5        = %s', KT5)); end
KT6 = char(h(207:214));
if (str2double(KT6) ~= -12345 & nargin == 1); disp(sprintf('KT6        = %s', KT6)); end
KT7 = char(h(215:222));
if (str2double(KT7) ~= -12345 & nargin == 1); disp(sprintf('KT7        = %s', KT7)); end
KT8 = char(h(223:230));
if (str2double(KT8) ~= -12345 & nargin == 1); disp(sprintf('KT8        = %s', KT8)); end
KT9 = char(h(231:238));
if (str2double(KT9) ~= -12345 & nargin == 1); disp(sprintf('KT9        = %s', KT9)); end
KF = char(h(239:246));
if (str2double(KF) ~= -12345 & nargin == 1); disp(sprintf('KF         = %s', KF)); end
KUSER0 = char(h(247:254));
if (str2double(KUSER0) ~= -12345 & nargin == 1); disp(sprintf('KUSER0     = %s', KUSER0)); end
KUSER1 = char(h(255:262));
if (str2double(KUSER1) ~= -12345 & nargin == 1); disp(sprintf('KUSER1     = %s', KUSER1)); end
KUSER2 = char(h(263:270));
if (str2double(KUSER2) ~= -12345 & nargin == 1); disp(sprintf('KUSER2     = %s', KUSER2)); end
KCMPNM = char(h(271:278));
if (str2double(KCMPNM) ~= -12345 & nargin == 1); disp(sprintf('KCMPNM     = %s', KCMPNM)); end
KNETWK = char(h(279:286));
if (str2double(KNETWK) ~= -12345 & nargin == 1); disp(sprintf('KNETWK     = %s', KNETWK)); end
KDATRD = char(h(287:294));
if (str2double(KDATRD) ~= -12345 & nargin == 1); disp(sprintf('KDATRD     = %s', KDATRD)); end
KINST = char(h(295:302));
if (str2double(KINST) ~= -12345 & nargin == 1); disp(sprintf('KINST      = %s', KINST)); end


if nargin > 1
  for nrecs = 1:(nargin-1);
    varargout{nrecs} = eval(varargin{nrecs});
  end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enableon(on)
set(on,'Enable','on')



function [month,day]=jul2monthday(year,julday)

%%%leap year from coral...
a = ( ~rem(year, 4) & rem(year, 100) ) | ~rem(year, 400);

if a == 0
    
        if julday <= 31 
            month = 1;
            day=julday;
        elseif julday > 31 & julday <= 59
            month = 2;
            day=julday-31;
        elseif julday > 59 & julday <= 90
            month = 3;
            day=julday-59;
        elseif julday > 90 & julday <= 120
            month = 4;
            day=julday-90;
        elseif julday > 120 & julday <= 151
            month = 5;
            day=julday-120;
        elseif julday > 151 & julday <= 181
            month = 6;
            day=julday-151;
        elseif julday > 181 & julday <= 212
            month = 7;
            day=julday-181;
        elseif julday > 212 & julday <= 243
            month = 8;
            day=julday-212;
        elseif julday > 243 & julday <= 273
            month = 9;
            day=julday-243;
        elseif julday > 273 & julday <= 304
            month = 10;
            day=julday-273;
        elseif julday > 304 & julday <= 334
            month = 11;
            day=julday-304;
        elseif julday > 334 & julday <= 365
            month = 12;
            day=julday-334;
        else
        end
        
    elseif a==1
        
        if julday <= 31 
            month = 1;
            day=julday;
        elseif julday > 31 & julday <= 60
            month = 2;
            day=julday-31;
        elseif julday > 60 & julday <= 91
            month = 3;
            day=julday-60;
        elseif julday > 91 & julday <= 121
            month = 4;
            day=julday-91;
        elseif julday > 121 & julday <= 152
            month = 5;
            day=julday-121;
        elseif julday > 152 & julday <= 182
            month = 6;
            day=julday-152;
        elseif julday > 182 & julday <= 213
            month = 7;
            day=julday-182;
        elseif julday > 213 & julday <= 244
            month = 8;
            day=julday-213;
        elseif julday > 244 & julday <= 274
            month = 9;
            day=julday-244;
        elseif julday > 274 & julday <= 305
            month = 10;
            day=julday-274;
        elseif julday > 305 & julday <= 335
            month = 11;
            day=julday-305;
        elseif julday > 335 & julday <= 366
            month = 12;
            day=julday-335;
        else
        end
end


    


% --- Executes on button press in cut.
function cut_Callback(hObject, eventdata, handles)
% hObject    handle to cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%READ DATA FROM HANDLES
ew=handles.ew ;
ns=handles.ns ;
ver=handles.ver;
dt=handles.dt
% 
%whos ew ns ver

cutpick1 = ginput(1)

cutpoint1=fix(cutpick1(1))
disp(['Select up to point ' num2str(cutpoint1/dt)])
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

%%
istew=handles.istew; 
istns=handles.istns; 
istver=handles.istver; 
ew=handles.ew;
ns=handles.ns;
ver=handles.ver;
dt=handles.dt;

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
%%

[~,b]=max([istns;istew;istver]);
   
if b ==1
    %%allign to ns
    %%find cutsamples
     [~, ~, ~, h, mn, s] = datevec(istns-istew);
     secdifne=s+mn*60+h*3600;
     ewcutsamples=round(secdifne/dt);    %ewcutsamples=(nssec-ewsec)/dt

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


%% 
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

function doy = date2doy(d)
dv = datevec(d);
dv(:,4:end) = 0;
d1=datenum(dv);
dv(:,2:end) = 0;
d2=datenum(dv);
doy = d1 - d2;
