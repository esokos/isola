function varargout = seisanimport(varargin)
% SEISANIMPORT M-file for seisanimport.fig
%      SEISANIMPORT, by itself, creates a new SEISANIMPORT or raises the existing
%      singleton*.
%
%      H = SEISANIMPORT returns the handle to a new SEISANIMPORT or the handle to
%      the existing singleton*.
%
%      SEISANIMPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEISANIMPORT.M with the given input arguments.
%
%      SEISANIMPORT('Property','Value',...) creates a new SEISANIMPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before seisanimport_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to seisanimport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help seisanimport

% Last Modified by GUIDE v2.5 07-Oct-2011 10:36:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @seisanimport_OpeningFcn, ...
                   'gui_OutputFcn',  @seisanimport_OutputFcn, ...
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


% --- Executes just before seisanimport is made visible.
function seisanimport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to seisanimport (see VARARGIN)

% Choose default command line output for seisanimport
handles.output = hObject;

if ~ispc
    disp('Not tested in Linux yet..')
end
    

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes seisanimport wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = seisanimport_OutputFcn(hObject, eventdata, handles)
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

% load based on a m-file from NOA...not sure if it works with all SEISAN
% files..!!

[Seisfile, newdir] = uigetfile('*.*', 'Select SEISAN waveform file');

[data,dyear,ddoy,dmonth,dday,fhour,fmin,fsec,nchanels]=seisanimportnew(newdir,Seisfile);

y=num2str(dyear);

set(handles.nstime,'string',['File Start Time  ' y(2:3) '/' num2str(dmonth) '/' num2str(dday) ',' num2str(fhour) ':' num2str(fmin) ':' num2str(fsec)])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.sfreq,'String',num2str(data(1).f))
set(handles.totalsta,'String',num2str(nchanels))
curst=1;
set(handles.cursta,'String',num2str(curst))



%%%%%%%
dt=1.0/str2num((data(1).f));
% maxtime=(length(data(1,:))*dt)-dt
% tim=(0:dt:maxtime);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%this is the sample number not the time....
tim_samples=(1:1:str2num(data(1).s));
tim=((tim_samples.*dt)-dt)';

%%%
axes(handles.nsaxis)
plot(tim,data(1).d,'g')
%plot(data(3,:),'g')
set(handles.nsaxis,'XMinorTick','on')
grid on
title('NS')

axes(handles.ewaxis)
plot(tim,data(2).d,'r')
%plot(data(2,:),'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
title('EW')

axes(handles.veraxis)
plot(tim,data(3).d,'b')
%plot(data(1,:),'b')
set(handles.veraxis,'XMinorTick','on')
grid on
title('Ver')
xlabel('Time (sec)')
ylabel('Counts')


 disp( [data(curst).n ' ' data(curst).c  '    '  data(curst+1).n '  '  data(curst+1).c '   '  data(curst+2).n '  '  data(curst+2).c])


%%Save to handles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.dyear=dyear;
handles.ddoy=ddoy;
handles.dmonth=dmonth;
handles.dday=dday;

handles.fhour=fhour;
handles.fmin=fmin;
handles.fsec=fsec;

handles.nchanels=nchanels;
handles.curst=curst;
handles.tim_samples = tim_samples;
handles.tim = tim;
handles.data = data;
%handles.channel=channel;
guidata(hObject,handles)

%%% Enable next station button
set(handles.nstation,'Enable','on')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%channel(1:for2,1:9);
set(handles.nsname,'string',data(1).n)
set(handles.ewname,'string',data(2).n)
set(handles.vername,'string',data(3).n)

set(handles.nscomp,'string',data(1).c)
set(handles.ewcomp,'string',data(2).c)
set(handles.vercomp,'string',data(3).c)

guidata(hObject,handles)

% --- Executes on button press in saveascii.
function saveascii_Callback(hObject, eventdata, handles)
% hObject    handle to saveascii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% find current channel..
curst=handles.curst;
data=handles.data;

disp( ['Current channels are ' data(curst).n ' ' data(curst).c  '    '  data(curst+1).n '  '  data(curst+1).c '   '  data(curst+2).n '  '  data(curst+2).c])

station_name = data(curst).n;
% data(curst+1).n;
% data(curst+2).n;
% check component names
   tf1=strcmp(station_name,data(curst+1).n);
   tf2=strcmp(station_name,data(curst+2).n); 

   if tf1~=1  || tf2 ~=1
       disp('Station names differ. Cannot save')
       errordlg('Station names differ. Cannot save','Error');
   else
       disp('same station')
   end

   c1c2c3=[data(curst).c(3:3)   data(curst+1).c(3:3)   data(curst+2).c(3:3)];


k = strfind(c1c2c3, 'N');

switch k
    case 1 % NS is first
     disp('NS is first')   
     nscounts=data(curst).d;
    case 2 % NS is second
     disp('NS is second')   
     nscounts=data(curst+1).d;
    case 3 % NS is third
     disp('NS is third')   
     nscounts=data(curst+2).d;
    otherwise
     disp('NS is missing')   
end

k = strfind(c1c2c3, 'E');

switch k
    case 1 % EW is first
     disp('EW is first')   
     ewcounts=data(curst).d;
    case 2 % EW is second
     disp('EW is second')   
     ewcounts=data(curst+1).d;
    case 3 % EW is third
     disp('EW is third')   
     ewcounts=data(curst+2).d;
    otherwise
     disp('EW is missing')   
end


k = strfind(c1c2c3, 'Z');

switch k
    case 1 % Z is first
     disp('Z is first')   
     vercounts=data(curst).d;
    case 2 % Z is second
     disp('Z is second')   
     vercounts=data(curst+1).d;
    case 3 % Z is third
     disp('Z is third')   
     vercounts=data(curst+2).d;
    otherwise
     disp('Z is missing')   
end

%make time_sec
%this is the sample number not the time....
dt=1.0/str2double((data(curst).f));
tim_samples=(1:1:str2num(data(curst).s));
time_sec=((tim_samples.*dt)-dt)';

alld=[time_sec'; double(nscounts)' ; double(ewcounts)' ; double(vercounts)'];    %%% Changed to N,E,Z


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
   
cd ..
catch
cd ..
pwd
end



end

%%
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

% get from handles
dyear=handles.dyear;
ddoy=handles.ddoy;
dmonth=handles.dmonth;
dday=handles.dday;

mon=num2mon(dmonth);

fhour=handles.fhour;
fmin=handles.fmin;
fsec=handles.fsec;


%start_time=strrep(strrep(strrep(strrep(get(handles.nstime,'String'),':',' '),'-',' '),')',' '),'(',' ')
start_time=[num2str(dday) ' ' mon ' ' num2str(dyear+1900) ' ' num2str(ddoy) ' ' num2str(fhour) ' ' num2str(fmin) ' ' num2str(fsec,'%5.2f')]
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close

% --- Executes on button press in nstation.
function nstation_Callback(hObject, eventdata, handles)
% hObject    handle to nstation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data=handles.data;
nchanels=handles.nchanels;
curst=handles.curst;

curst=curst+3;

set(handles.cursta,'String',num2str(curst))

if curst+2 <= nchanels
set(handles.curch2,'String',num2str(curst+2))
else
set(handles.curch2,'String',' ')
    
end

%%
remain_ch=nchanels-(curst+2);

switch remain_ch
    case 0
        disp('Last 3 channels.')
             % handles on
             set(handles.nstation,'Enable','off')
             %%%%%%%
             set(handles.nsname,'string',data(curst).n)
             set(handles.ewname,'string',data(curst+1).n)
             set(handles.vername,'string',data(curst+2).n)
             set(handles.nscomp,'string',data(curst).c)
             set(handles.ewcomp,'string',data(curst+1).c)
             set(handles.vercomp,'string',data(curst+2).c)
            %
            dt=1.0/str2num((data(curst).f));
            %this is the sample number not the time....
            tim_samples=(1:1:str2num(data(curst).s));
            tim=((tim_samples.*dt)-dt)';
            %
            axes(handles.nsaxis)
            plot(tim,data(curst).d,'g')
            set(handles.nsaxis,'XMinorTick','on')
            grid on;title('NS')
            %
            dt=1.0/str2num((data(curst+1).f));
            %this is the sample number not the time....
            tim_samples=(1:1:str2num(data(curst+1).s));
            tim=((tim_samples.*dt)-dt)';
            %
            axes(handles.ewaxis)
            plot(tim,data(curst+1).d,'r')
            set(handles.ewaxis,'XMinorTick','on')
            grid on;title('EW')
            %
            dt=1.0/str2num((data(curst+2).f));
            %this is the sample number not the time....
            tim_samples=(1:1:str2num(data(curst+2).s));
            tim=((tim_samples.*dt)-dt)';
            %
            axes(handles.veraxis)
            plot(tim,data(curst+2).d,'b')
            set(handles.veraxis,'XMinorTick','on')
            grid on;title('Ver');xlabel('Time (sec)');ylabel('Counts')
            
            disp( [data(curst).n ' ' data(curst).c  '    '  data(curst+1).n '  '  data(curst+1).c '   '  data(curst+2).n '  '  data(curst+2).c])

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            handles.curst=curst;
            guidata(hObject,handles)

    case -1
             disp('Last 2 channels.')
             % handles on
             set(handles.nstation,'Enable','off')
             %%%%%%%
             set(handles.nsname,'string',data(curst).n)
             set(handles.ewname,'string',data(curst+1).n)

             set(handles.nscomp,'string',data(curst).c)
             set(handles.ewcomp,'string',data(curst+1).c)
            %
            dt=1.0/str2num((data(curst).f));
            %this is the sample number not the time....
            tim_samples=(1:1:str2num(data(curst).s));
            tim=((tim_samples.*dt)-dt)';
            %
            axes(handles.nsaxis)
            plot(tim,data(curst).d,'g')
            set(handles.nsaxis,'XMinorTick','on')
            grid on;title('NS')
            %
            dt=1.0/str2num((data(curst+1).f));
            %this is the sample number not the time....
            tim_samples=(1:1:str2num(data(curst+1).s));
            tim=((tim_samples.*dt)-dt)';
            %
            axes(handles.ewaxis)
            plot(tim,data(curst+1).d,'r')
            set(handles.ewaxis,'XMinorTick','on')
            grid on;title('EW')
            %
            disp( [data(curst).n ' ' data(curst).c  '    '  data(curst+1).n '  '  data(curst+1).c ])

            delete(handles.veraxis)

            delete(handles.vername)
            delete(handles.vercomp)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            handles.curst=curst;
            guidata(hObject,handles)
        
    case -2
             disp('Last channel.')
             % handles on
             set(handles.nstation,'Enable','off')
             %%%%%%%
             set(handles.nsname,'string',data(curst).n)

             set(handles.nscomp,'string',data(curst).c)
            %
            dt=1.0/str2num((data(curst).f));
            %this is the sample number not the time....
            tim_samples=(1:1:str2num(data(curst).s));
            tim=((tim_samples.*dt)-dt)';
            %
            axes(handles.nsaxis)
            plot(tim,data(curst).d,'g')
            set(handles.nsaxis,'XMinorTick','on')
            grid on;title('NS')
           
            disp( [data(curst).n ' ' data(curst).c ])
            
            delete(handles.ewaxis)
            delete(handles.veraxis)
            
            delete(handles.ewname)
            delete(handles.ewcomp)
            
            delete(handles.vername)
            delete(handles.vercomp)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            handles.curst=curst;
            guidata(hObject,handles)
    otherwise
             %%%%%%%
             set(handles.nsname,'string',data(curst).n)
             set(handles.ewname,'string',data(curst+1).n)
             set(handles.vername,'string',data(curst+2).n)
             set(handles.nscomp,'string',data(curst).c)
             set(handles.ewcomp,'string',data(curst+1).c)
             set(handles.vercomp,'string',data(curst+2).c)
            %
            dt=1.0/str2num((data(curst).f));
            %this is the sample number not the time....
            tim_samples=(1:1:str2num(data(curst).s));
            tim=((tim_samples.*dt)-dt)';
            %
            axes(handles.nsaxis)
            plot(tim,data(curst).d,'g')
            set(handles.nsaxis,'XMinorTick','on')
            grid on;title('NS')
            %
            dt=1.0/str2num((data(curst+1).f));
            %this is the sample number not the time....
            tim_samples=(1:1:str2num(data(curst+1).s));
            tim=((tim_samples.*dt)-dt)';
            %
            axes(handles.ewaxis)
            plot(tim,data(curst+1).d,'r')
            set(handles.ewaxis,'XMinorTick','on')
            grid on;title('EW')
            %
            dt=1.0/str2num((data(curst+2).f));
            %this is the sample number not the time....
            tim_samples=(1:1:str2num(data(curst+2).s));
            tim=((tim_samples.*dt)-dt)';
            %
            axes(handles.veraxis)
            plot(tim,data(curst+2).d,'b')
            set(handles.veraxis,'XMinorTick','on')
            grid on;title('Ver');xlabel('Time (sec)');ylabel('Counts')
             
            disp( [data(curst).n ' ' data(curst).c  '    '  data(curst+1).n '  '  data(curst+1).c '   '  data(curst+2).n '  '  data(curst+2).c])

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            handles.curst=curst;
            guidata(hObject,handles)
        
end


% --- Executes during object deletion, before destroying properties.
function veraxis_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to veraxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%% 
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
