function varargout = datain4(varargin)
% DATAIN4 M-file for datain4.fig
%      DATAIN4, by itself, creates a new DATAIN4 or raises the existing
%      singleton*.
%
%      H = DATAIN4 returns the handle to a new DATAIN4 or the handle to
%      the existing singleton*.
%
%      DATAIN4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATAIN4.M with the given input arguments.
%
%      DATAIN4('Property','Value',...) creates a new DATAIN4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before datain4_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to datain4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help datain4

% Last Modified by GUIDE v2.5 11-Oct-2011 09:49:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @datain4_OpeningFcn, ...
                   'gui_OutputFcn',  @datain4_OutputFcn, ...
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


% --- Executes just before datain4 is made visible.
function datain4_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to datain4 (see VARARGIN)

% Choose default command line output for datain4
handles.output = hObject;



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
handles.endpoint=8192;
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

dtres=tl/8192;
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

% Update handles structure
guidata(hObject, handles);


off =[handles.orallign,handles.savefinal,handles.makecor,handles.plcurve];
enableoff(off)



% UIWAIT makes datain4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = datain4_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is datain4  version 24/01/14');

% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.text15,'Visible','on')
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
    disp('Start time file doesn''t exist. Using default start time');
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
set(handles.hcut1,'String',num2str(sfreq/2-ceil(sfreq/100)));  

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
guidata(hObject,handles)



% handles on
on =[handles.makecor,handles.plcurve];
enableon(on)


% --- Executes on button press in makecor.
function makecor_Callback(hObject, eventdata, handles)
% hObject    handle to makecor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%INSTRUMENT CORRECTION AND FILTERING%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       START        %%%%%%%%%%%%%%%%%%%%%%%%%%%

%READ DATA FROM HANDLES AND put in new variables....
ewcounts=handles.ew;
nscounts=handles.ns;
vercounts=handles.ver;
dt=handles.dt
file=handles.file;


if (get(handles.skipinst,'Value') == get(handles.skipinst,'Max'))
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
    
np=length(ewcounts);
sfreq=1/dt;

%%%%%%%%%%%%%%%%%%%%
switch length(file)
    case 12 % station with 5 character name
      stationpzfilens=[file(1:5)  'BHN.pz']
      stationpzfileew=[file(1:5)  'BHE.pz']
      stationpzfilever=[file(1:5) 'BHZ.pz']
    case 11 % station with 4 character name
      stationpzfilens=[file(1:4)  'BHN.pz']
      stationpzfileew=[file(1:4)  'BHE.pz']
      stationpzfilever=[file(1:4) 'BHZ.pz']
    case 10
      stationpzfilens=[file(1:3)  'BHN.pz']
      stationpzfileew=[file(1:3)  'BHE.pz']
      stationpzfilever=[file(1:3) 'BHZ.pz']
    otherwise
        disp('Error in file read')
end


% %%%% start ...


try
%    

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
    
      zer=fgetl(fid);
            zer=zer(1:6);
% 
%         if zer~='zeroes' then
%             disp 'error'
%         elseif zer=='zeroes' 
%             disp 'ok'
%         end
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
            pol=fgetl(fid);
                        pol=pol(1:5);

%         if pol~='poles' then
%             disp 'error'
%         elseif pol=='poles' 
%             disp 'ok'
%         end
            npolns=str2num(fgetl(fid));
        for i=1:npolns
            pol=str2num(fgetl(fid));
            polesns(i)=complex(pol(1),pol(2));
        end
%%%% check if there is info to compute  clip level 
          ffline=fgets(fid)
          AA=ischar(ffline);
          
            switch AA
            case 1
                idx1 = strfind(ffline, 'Info:')
                if idx1 == 1
                        index1=strfind(ffline,'Digi sens');
                        index2=strfind(ffline,'Seism sens');
                        digisens_ns = sscanf(ffline(index1+9: index2-1),'%f')
                        seismsens_ns = sscanf(ffline(index2+10: length(ffline)),'%f')
                        nsclip=1;
                        disp('Read Clip info for NS.')
                 else
                        disp('Check the last line in pz file. It doesn''t seem correct. Clip info not read.')
                        nsclip=0;
                 end

            case 0
                nsclip=0;
                disp('Clip info not found for NS')
            otherwise
                nsclip=0;
                disp('Error')
            end
                
fclose(fid);
%%%%%
%%%%%%%%%%%end with NS        
    fid = fopen(stationpzfileew,'r');
    aa=fgetl(fid);
    A0ew=str2num(fgetl(fid));
    aa=fgetl(fid);
    constantew=str2num(fgetl(fid));
    
      zer=fgetl(fid);
            zer=zer(1:6);

%         if zer~='zeroes' then
%             disp 'error'
%         elseif zer=='zeroes' 
%             disp 'ok'
%         end
            nzerew=str2num(fgetl(fid));
        for p=1:nzerew
            zer=str2num(fgetl(fid));
%             whos zer
            zeroesew(p)=complex(zer(1,1),zer(1,2));
%             whos zeroes
        end
        
        if nzerew == 0
            zeroesew=[];
        end
%%% finished with zeroes
%%% read poles
            pol=fgetl(fid);
                        pol=pol(1:5);

%         if pol~='poles' then
%             disp 'error'
%         elseif pol=='poles' 
%             disp 'ok'
%         end
            npolew=str2num(fgetl(fid));
        for i=1:npolew
            pol=str2num(fgetl(fid));
            polesew(i)=complex(pol(1),pol(2));
        end

%%%% check if there is info to compute  clip level 
          ffline=fgets(fid)
          AA=ischar(ffline);
          
            switch AA
            case 1
                idx1 = strfind(ffline, 'Info:')
                if idx1 == 1
                        index1=strfind(ffline,'Digi sens');
                        index2=strfind(ffline,'Seism sens');
                        digisens_ew = sscanf(ffline(index1+9: index2-1),'%f')
                        seismsens_ew = sscanf(ffline(index2+10: length(ffline)),'%f')
                        ewclip=1;
                        disp('Read Clip info for EW.')
                 else
                        disp('Check the last line in pz file. It doesn''t seem correct. Clip info not read.')
                        ewclip=0;
                 end

            case 0
                ewclip=0;
                disp('Clip info not found for EW')
            otherwise
                ewclip=0;
                disp('Error')
            end

            fclose(fid);
%%%%%%%%%%%%finished with EW
    fid = fopen(stationpzfilever,'r');
    aa=fgetl(fid);
    A0ver=str2num(fgetl(fid));
    aa=fgetl(fid);
    constantver=str2num(fgetl(fid));
    
      zer=fgetl(fid);
            zer=zer(1:6);

%         if zer~='zeroes' then
%             disp 'error'
%         elseif zer=='zeroes' 
%             disp 'ok'
%         end
            nzerver=str2num(fgetl(fid));
        for p=1:nzerver
            zer=str2num(fgetl(fid));
%             whos zer
            zeroesver(p)=complex(zer(1,1),zer(1,2));
%             whos zeroes
        end
        
        if nzerver == 0
            zeroesver=[];
        end
        
        
%%% finished with zeroes
%%% read poles
            pol=fgetl(fid);
                        pol=pol(1:5);

%         if pol~='poles' then
%             disp 'error'
%         elseif pol=='poles' 
%             disp 'ok'
%         end
            npolver=str2num(fgetl(fid));
        for i=1:npolver
            pol=str2num(fgetl(fid));
            polesver(i)=complex(pol(1),pol(2));
        end

%%%% check if there is info to compute  clip level 
          ffline=fgets(fid)
          AA=ischar(ffline);
          
            switch AA
            case 1
                idx1 = strfind(ffline, 'Info:')
                if idx1 == 1
                        index1=strfind(ffline,'Digi sens');
                        index2=strfind(ffline,'Seism sens');
                        digisens_ver = sscanf(ffline(index1+9: index2-1),'%f')
                        seismsens_ver = sscanf(ffline(index2+10: length(ffline)),'%f')
                        verclip=1;
                        disp('Read Clip info for Ver.')
                 else
                        disp('Check the last line in pz file. It doesn''t seem correct. Clip info not read.')
                        verclip=0;
                 end

            case 0
                verclip=0;
                disp('Clip info not found for Ver')
            otherwise
                verclip=0;
                disp('Error')
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


%%% check about type of trend correction
if (get(handles.dcrem,'Value') == get(handles.dcrem,'Max'))
% then checkbox is checked-take approriate action
ewcounts  =  detrend(ewcounts,'constant');
nscounts  =  detrend(nscounts,'constant');
vercounts =  detrend(vercounts,'constant');
disp('Removing Mean')

else

    % checkbox is not checked
end

if (get(handles.trendoff,'Value') == get(handles.trendoff,'Max'))
% then checkbox is checked-take approriate action
ewcounts  =  detrend(ewcounts);
nscounts  =  detrend(nscounts);
vercounts =  detrend(vercounts);
disp('Removing Trend')

else

    % checkbox is not checked
end

if (get(handles.jiri100,'Value') == get(handles.jiri100,'Max'))

%%%%%find baseline 
asumew=0;
asumns=0;
asumver=0;

for i=1:4000
    asumew=asumew+ewcounts(i);
    asumns=asumns+nscounts(i);
    asumver=asumver+vercounts(i);
end

baselineew  =asumew/4000
baselinens  =asumns/4000
baselinever =asumver/4000

ewcounts  =  (ewcounts-baselineew);%.*constant;
nscounts  =  (nscounts-baselinens);%.*constant;
vercounts =  (vercounts-baselinever);%.*constant;
disp('Removing baseline')

else

    % checkbox is not checked
end

%%add taper
taperv = str2double(get(handles.taper,'String'));

% taper data

ewcounts=taperd(ewcounts,taperv/100);
nscounts=taperd(nscounts,taperv/100);
vercounts=taperd(vercounts,taperv/100);

% convert to m/sec
ewms  =  ewcounts.*constantew;
nsms  =  nscounts.*constantns;
verms =  vercounts.*constantver;



%%%%%%%%%%%%%%
n=length(ewms);
NFFT=2^nextpow2(n);
NumUniquePts=ceil((NFFT+1)/2);
nt=NFFT;
nt2=nt/2;
ntm=nt2+1;
ntt=nt+2;
df=1/(dt*NFFT);
%
ewc = complex(ewms);
nsc = complex(nsms);
verc= complex(verms);
% 
s1=fft(ewc,NFFT);  % Fourier Transform
s2=fft(nsc,NFFT);  % Fourier Transform
s3=fft(verc,NFFT); % Fourier Transform

fft_dataew=s1(1:NumUniquePts);
fft_datans=s2(1:NumUniquePts);
fft_dataver=s3(1:NumUniquePts);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cu=complex(0.,1.);
% 
fft_dataewcor=ones(1,NumUniquePts)';
fft_datanscor=ones(1,NumUniquePts)';
fft_datavercor=ones(1,NumUniquePts)';
freq=ones(1,NumUniquePts)';

%%%% division skip DC and Nyquist   %%%% NS
for i=2:NumUniquePts-1,

freq(i)=(i-1)*df;
cso=2*pi*cu*freq(i);

       cnumer=complex(1,0); %complex(1.,0.)
          for izer=1:nzerns
              cnumer=(cso-zeroesns(izer))*cnumer;
          end
        cdenom=complex(1,0);% complex(1.,0.)
          for ipol=1:npolns
              cdenom=(cso-polesns(ipol))*cdenom;
          end

           if cdenom == 0 ;
               disp('error')
               break          
           end
            
        ctrafns=A0ns*cnumer/cdenom;
      
%fft_dataewcor(i)=fft_dataew(i)/ctraf;
fft_datanscor(i)=fft_datans(i)/ctrafns;
%fft_datavercor(i)=fft_dataver(i)/ctraf;

end

%%%% division skip DC and Nyquist   %%%% EW
for i=2:NumUniquePts-1,

freq(i)=(i-1)*df;
cso=2*pi*cu*freq(i);

       cnumer=complex(1,0); %complex(1.,0.)
          for izer=1:nzerew
              cnumer=(cso-zeroesew(izer))*cnumer;
          end
        cdenom=complex(1,0);% complex(1.,0.)
          for ipol=1:npolew
              cdenom=(cso-polesew(ipol))*cdenom;
          end

           if cdenom == 0 ;
               disp('error')
               break          
           end
            
        ctrafew=A0ew*cnumer/cdenom;
      
fft_dataewcor(i)=fft_dataew(i)/ctrafew;
%fft_datanscor(i)=fft_datans(i)/ctraf;
%fft_datavercor(i)=fft_dataver(i)/ctraf;

end

%%%% division skip DC and Nyquist   %%%% VER
for i=2:NumUniquePts-1,

freq(i)=(i-1)*df;
cso=2*pi*cu*freq(i);

       cnumer=complex(1,0); %complex(1.,0.)
          for izer=1:nzerver
              cnumer=(cso-zeroesver(izer))*cnumer;
          end
       cdenom=complex(1,0);% complex(1.,0.)
          for ipol=1:npolver
              cdenom=(cso-polesver(ipol))*cdenom;
          end

           if cdenom == 0 ;
               disp('error')
               break          
           end
            
        ctrafver=A0ver*cnumer/cdenom;
      
%fft_dataewcor(i)=fft_dataew(i)/ctraf;
%fft_datanscor(i)=fft_datans(i)/ctraf;
fft_datavercor(i)=fft_dataver(i)/ctrafver;

end


%%%%% construct fft_dataewcor add DC and Nyquist
fft_dataewcor  = [s1(1);fft_dataewcor(2:NumUniquePts-1);s1(NumUniquePts:NFFT)];
fft_datanscor  = [s2(1);fft_datanscor(2:NumUniquePts-1);s2(NumUniquePts:NFFT)];
fft_datavercor  =[s3(1);fft_datavercor(2:NumUniquePts-1);s3(NumUniquePts:NFFT)];

%%%%%%%%%%%%%%%%%%inverse FFT 
% 
for i=2:NumUniquePts-1,
 j=ntt-i;
fft_dataewcor(j) =conj(fft_dataewcor(i));
fft_datanscor(j) =conj(fft_datanscor(i));
fft_datavercor(j) =conj(fft_datavercor(i));
end

ewcor4   =      flipud(fft(fft_dataewcor,NFFT));
nscor4   =      flipud(fft(fft_datanscor,NFFT));
vercor4   =     flipud(fft(fft_datavercor,NFFT));

ewcor5=real(ewcor4)./nt;
nscor5=real(nscor4)./nt;
vercor5=real(vercor4)./nt;
% 
ewcor6 =ewcor5(1:np);
nscor6 =nscor5(1:np);
vercor6 =vercor5(1:np);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filtering
lcut2 = str2double(get(handles.lcut2,'String'))
hcut1 = str2double(get(handles.hcut1,'String'))

nptsew=length(ewcor6);
ewcor=bandpass(ewcor6,lcut2,hcut1,nptsew,dt);
nptsns=length(nscor6);
nscor=bandpass(nscor6,lcut2,hcut1,nptsns,dt);
nptsver=length(vercor6);
vercor=bandpass(vercor6,lcut2,hcut1,nptsver,dt);

newsamples=(1:1:max(size(ewcor)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save instrument corrected - filtered data  to handles 
handles.ewcor = ewcor;
handles.nscor = nscor;
handles.vercor=vercor;
handles.newsamples=newsamples;
guidata(hObject,handles)

%save clip info
if (nsclip==1 & ewclip==1 & verclip==1)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%INSTRUMENT CORRECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%         END        %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%read instrument corrected data
ew=handles.ewcor;
ns=handles.nscor;
ver=handles.vercor;
dt=handles.dt;
tim=handles.newsamples;

%prepare time axis in sec
time_sec=((tim.*dt)-dt);

% %plot CORRECTED data
axes(handles.ewaxis)
% plot(time_sec,ew,'r',tt,pclvalue,'g',tt,nclvalue,'g')
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
xlabel('Seconds')
ylabel('m/sec')

%%%%%
set(handles.dstat,'String','Instrument Corrected data',...
                  'FontSize',14,...
                  'FontWeight','bold',...
                  'ForegroundColor','red')

%%%%% Enable clip...??
if (nsclip==1 && ewclip ==1 && verclip==1)
    on =[handles.cliplvl];
    enableon(on)
else
end
%%%%%
              
%%%enable allign

on =[handles.orallign];
enableon(on)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end    %%% end of IF for instrument correction 



% --- Executes during object creation, after setting all properties.
function orighour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orighour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function orighour_Callback(hObject, eventdata, handles)
% hObject    handle to orighour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orighour as text
%        str2double(get(hObject,'String')) returns contents of orighour as a double


% --- Executes during object creation, after setting all properties.
function origmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to origmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function origmin_Callback(hObject, eventdata, handles)
% hObject    handle to origmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of origmin as text
%        str2double(get(hObject,'String')) returns contents of origmin as a double


% --- Executes during object creation, after setting all properties.
function origsec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to origsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function origsec_Callback(hObject, eventdata, handles)
% hObject    handle to origsec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of origsec as text
%        str2double(get(hObject,'String')) returns contents of origsec as a double


% --- Executes during object creation, after setting all properties.
function filehour_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filehour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function filehour_Callback(hObject, eventdata, handles)
% hObject    handle to filehour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filehour as text
%        str2double(get(hObject,'String')) returns contents of filehour as a double


% --- Executes during object creation, after setting all properties.
function filemin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filemin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function filemin_Callback(hObject, eventdata, handles)
% hObject    handle to filemin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filemin as text
%        str2double(get(hObject,'String')) returns contents of filemin as a double


% --- Executes during object creation, after setting all properties.
function filesec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filesec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function filesec_Callback(hObject, eventdata, handles)
% hObject    handle to filesec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filesec as text
%        str2double(get(hObject,'String')) returns contents of filesec as a double


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

dtres=handles.dtres;

%%%%%%%%%%%%%%%%%%%%
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

           ewdis=cumtrapz(ewdetr)*dt;
           nsdis=cumtrapz(nsdetr)*dt;
           verdis=cumtrapz(verdetr)*dt;
         
          %%%%%%%%% plotting 
          %%%%%prepare 'time' axis
          tim=(1:1:length(verdis));
          %prepare real time axis
          time_sec=((tim.*dt)-dt);
          %%%%%%%%%%%          
          axes(handles.nsaxis)
          plot(time_sec,nsdis,'r')
          set(handles.nsaxis,'XMinorTick','on')
          grid on

          axes(handles.ewaxis)
          plot(time_sec,ewdis,'r')
          set(handles.ewaxis,'XMinorTick','on')
          grid on

          axes(handles.veraxis)
          plot(time_sec,verdis,'r')
          set(handles.veraxis,'XMinorTick','on')
          grid on
          xlabel('Sec')
          ylabel('m/sec')
          
%           %%%%% do something else here ???? save data ?????
%           whos allver allew allns
          
          handles.allver=allver;
          handles.allew=allew;
          handles.allns=allns;
          guidata(hObject, handles);
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


            allver= vercor(cutsamples:length(vercor),1);
            allew = ewcor(cutsamples:length(ewcor),1) ;
            allns = nscor(cutsamples:length(nscor),1) ;


           % plot displacement
           ewdetr=detrend(allew);
           nsdetr=detrend(allns);
           verdetr=detrend(allver);

           ewdis=cumtrapz(ewdetr)*dt;
           nsdis=cumtrapz(nsdetr)*dt;
           verdis=cumtrapz(verdetr)*dt;
          
          %%%%%%%%% plotting 
          %%%%%prepare 'time' axis
          tim=(1:1:length(verdis));
          %%%%%%%%%%%          
          %prepare real time axis
          time_sec=((tim.*dt)-dt);
          %%%%%%%%%%%%%%%%%%%%%%
          axes(handles.nsaxis)
          plot(time_sec,nsdis,'r')
          set(handles.nsaxis,'XMinorTick','on')
          grid on
          
          axes(handles.ewaxis)
          plot(time_sec,ewdis,'r')
          set(handles.ewaxis,'XMinorTick','on')
          grid on

          axes(handles.veraxis)
          plot(time_sec,verdis,'r')
          set(handles.veraxis,'XMinorTick','on')
          grid on
          xlabel('sec')
          ylabel('m/sec')
          
          %%%%% do something else here ???? save data ?????
%         whos allver allew allns
          
          handles.allver=allver;
          handles.allew=allew;
          handles.allns=allns;
          guidata(hObject, handles);
          
          %%%%%%%%%%%%%%%%%%
else      %%%%%%%%%%  
          
          disp('Origin time and file start time match...no change..!!')

           % plot displacement
           ewdetr=detrend(ewcor);
           nsdetr=detrend(nscor);
           verdetr=detrend(vercor);

           ewdis=cumtrapz(ewdetr)*dt;
           nsdis=cumtrapz(nsdetr)*dt;
           verdis=cumtrapz(verdetr)*dt;

          %%%%%%%%% plotting 
          %%%%%prepare 'time' axis
          tim=(1:1:length(verdis));
          %%%%%%%%%%          
          %prepare real time axis
          time_sec=((tim.*dt)-dt);
          %%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%          
          axes(handles.nsaxis)
          plot(time_sec,nsdis,'r')
          set(handles.nsaxis,'XMinorTick','on')
          grid on
          
          axes(handles.ewaxis)
          plot(time_sec,ewdis,'r')
          set(handles.ewaxis,'XMinorTick','on')
          grid on

          axes(handles.veraxis)
          plot(time_sec,verdis,'r')
          set(handles.veraxis,'XMinorTick','on')
          grid on
          xlabel('Sec')
          ylabel('m')
          
          %%%%% do something else here ???? save data ?????
%           whos allver allew allns
            handles.allver=vercor;
            handles.allew=ewcor;
            handles.allns=nscor;
            guidata(hObject, handles);
          %%%%%%%%%%%%%%%%%%
end          


%%%%%%%%%%%%%%%%%%%%%%%%%%%          END  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%
set(handles.dstat,'String','Origin Alligned Displacement data',...
                  'FontSize',14,...
                  'FontWeight','bold',...
                  'ForegroundColor','red')
%%%%%%%%
% 
on =[handles.savefinal];
enableon(on)
% 
% 
% --- Executes on button press in savefinal.
function savefinal_Callback(hObject, eventdata, handles)
% hObject    handle to savefinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%decimate first
%%%%%
%%%%%%%%%%THIS IS USED TO DECIMATE DATA.....
%%%%%%%%READ DATA FROM HANDLES  !!!!!!!!!!!!!   DECIMATE DATA BEFORE SAVE !!!!!!!
%allver_all=handles.allver_all;
%allew_all=handles.allew_all;
%allns_all=handles.allns_all;
%%%%%%%%%%%%% change 10/04
%% we read data that are alligned only for origin..........

allver_all=handles.allver;
allew_all=handles.allew;
allns_all=handles.allns;

% dt=handles.dt;
% dtres=handles.dtres;
%%%%%%%%%%make X axis
% tim=(1:1:length(allver_all));
% %%%%%%%%%%          
% %make real time axis in sec..or read from handles..??
% time_sec=((tim.*dt)-dt);
% %%%%%%%%%%%%%%%%%%%%%%
% 
% whos allver_all allew_all allns_all
% 
%%%%%%%%%read sampling rate    
%%%%%%%%%handles...!!!!
origfreq = str2double(get(handles.sfreq,'String'));  % this is the original sampling freq
%%%READ FACTOR
newfreq = str2double(get(handles.dfactor,'String'));  % this is the final sampling freq

disp(' ')

disp(['Original sampling freq ' num2str(origfreq) 'Hz'])

disp(['Final sampling freq ' num2str(newfreq) 'Hz'])

disp(' ')

[p,q] = rat(newfreq/origfreq,0.00001); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%new length will be
%l=ceil(length(allver_all)*p/q);
%
resallver_all=resample(allver_all,p,q);
%resallver_all_2 = downsample(allver_all,dfactor);
resallew_all=resample(allew_all,p,q);
%resallew_all_2 = downsample(allew_all,dfactor);
resallns_all=resample(allns_all,p,q);
%resallns_all_2 = downsample(allns_all,dfactor);

% new code
% resallver_all = idresamp(allver_all,dtres);
% resallew_all = idresamp(allew_all,dtres);
% resallns_all = idresamp(allns_all,dtres);

% whos resallver_all  resallew_all   resallns_all 
% 
% disp('New Frequency is')
% newfreq
% 
% disp('New dt is')
%%%dt=1/newfreq       %NEW dt  %%%% changed 26/01/2010

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

% %%%%%%%%%%%CHANGE END POINT  %%%%%%%%%%
% endpoint=handles.endpoint/dfactor;
% %%%%%store End of data ...
% handles.endpoint=endpoint;
% guidata(hObject, handles);


%%%%%PLOT RESAMPLED DATA final stage....!!!
% plot displacement
           ewdetr=detrend(resallew_all);
           nsdetr=detrend(resallns_all);
           verdetr=detrend(resallver_all);

           ewdis=cumtrapz(ewdetr)*dt;
           nsdis=cumtrapz(nsdetr)*dt;
           verdis=cumtrapz(verdetr)*dt;
          %%%%%%%%% plotting 
          %%%%%prepare 'time' axis
          tim=(1:1:length(verdis));
          %%%%%%%%%%%          
          %prepare real time axis
          time_sec=((tim.*dt)-dt);
          %%%%%%%%%%%%%%%%%%%%%%          

axes(handles.nsaxis)
plot(time_sec,nsdis,'b')
set(handles.nsaxis,'XMinorTick','on')
grid on

axes(handles.ewaxis)
plot(time_sec,ewdis,'b')
set(handles.ewaxis,'XMinorTick','on')
grid on

axes(handles.veraxis)
plot(time_sec,verdis,'b')
set(handles.veraxis,'XMinorTick','on')
grid on
xlabel('Time (sec)')
ylabel('m')


%%%%%
set(handles.dstat,'String','Resampled data',...
                  'FontSize',14,...
                  'FontWeight','bold',...
                  'ForegroundColor','blue')
%%%%%%%%

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

missdata=8192-length(allver_all);

           bmiss = zeros(missdata,1);
          
% whos bmiss
% 
if missdata > 0 

%   for  i=1:missdata
%     tmpdata(i)=0;
%   end
% 
%   whos tmpdata
  
  allver_all8192=vertcat(allver_all, bmiss);
  allew_all8192 =vertcat(allew_all, bmiss);
  allns_all8192 =vertcat(allns_all,  bmiss);
  
%   whos allver_all8192
  
else
    
  allver_all8192=allver_all(1:8192);
  allew_all8192 =allew_all(1:8192);
  allns_all8192=allns_all(1:8192);
  
%   allns_all8192(1:10)
%   allew_all8192(1:10)
%   allver_all8192(1:10)
  
end


disp(['The first 8192 points will be saved or '   num2str(8192*dt)    '  seconds of data'])


% %%%%READ ENDPOINT
% endpoint=fix(handles.endpoint);

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
delete(handles.datain4)




function enableoff(off)
set(off,'Enable','off')



function enableon(on)
set(on,'Enable','on')






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
    
      zer=fgetl(fid);
      zer=zer(1:6);

%         if zer~='zeroes' then
%             disp 'error'
%         elseif zer=='zeroes' 
%             disp 'ok'
%         end
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
            pol=fgetl(fid);
                        pol=pol(1:5);

%         if pol~='poles' then
%             disp 'error'
%         elseif pol=='poles' 
%             disp 'ok'
%         end
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
    
      zer=fgetl(fid);
            zer=zer(1:6);

%         if zer~='zeroes' then
%             disp 'error'
%         elseif zer=='zeroes' 
%             disp 'ok'
%         end
            nzerew=str2num(fgetl(fid));
        for p=1:nzerew
            zer=str2num(fgetl(fid));
%             whos zer
            zeroesew(p)=complex(zer(1,1),zer(1,2));
%             whos zeroes
        end
        
        if nzerew == 0
            zeroesew=[];
        end
%%% finished with zeroes
%%% read poles
            pol=fgetl(fid);
                        pol=pol(1:5);

%         if pol~='poles' then
%             disp 'error'
%         elseif pol=='poles' 
%             disp 'ok'
%         end
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
    
      zer=fgetl(fid);
            zer=zer(1:6);

%         if zer~='zeroes' then
%             disp 'error'
%         elseif zer=='zeroes' 
%             disp 'ok'
%         end
            nzerver=str2num(fgetl(fid));
        for p=1:nzerver
            zer=str2num(fgetl(fid));
%             whos zer
            zeroesver(p)=complex(zer(1,1),zer(1,2));
%             whos zeroes
        end
        
        if nzerver == 0
            zeroesver=[];
        end

 %%% finished with zeroes
%%% read poles
            pol=fgetl(fid);
                        pol=pol(1:5);

%         if pol~='poles' then
%             disp 'error'
%         elseif pol=='poles' 
%             disp 'ok'
%         end
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

% --- Executes on button press in filter.
function filter_Callback(hObject, eventdata, handles)
% hObject    handle to filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% 
ew=handles.ewcor;
ns=handles.nscor;
ver=handles.vercor;
dt=handles.dt;
tim=handles.newsamples;

%%%read values for filter...
lcut = str2double(get(handles.lcut2,'String'))
hcut = str2double(get(handles.hcut1,'String'))

nptsew=length(ew)
ewf=bandpass(ew,lcut,hcut,nptsew,dt);

nptsns=length(ns);
nsf=bandpass(ns,lcut,hcut,nptsns,dt);

nptsver=length(ver);
verf=bandpass(ver,lcut,hcut,nptsver,dt);

%save instrument corrected - filtered data  to handles 
handles.ewcor = ewf;
handles.nscor = nsf;
handles.vercor=verf;
guidata(hObject,handles)


%prepare time axis in sec
time_sec=((tim.*dt)-dt);

%plot filtered CORRECTED data
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
xlabel('Seconds')
ylabel('m/sec')



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
function lcut1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lcut1_Callback(hObject, eventdata, handles)
% hObject    handle to lcut1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcut1 as text
%        str2double(get(hObject,'String')) returns contents of lcut1 as a double


% --- Executes during object creation, after setting all properties.
function hcut2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hcut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function hcut2_Callback(hObject, eventdata, handles)
% hObject    handle to hcut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hcut2 as text
%        str2double(get(hObject,'String')) returns contents of hcut2 as a double


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


% --- Executes during object creation, after setting all properties.
function taper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function taper_Callback(hObject, eventdata, handles)
% hObject    handle to taper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of taper as text
%        str2double(get(hObject,'String')) returns contents of taper as a double


% --- Executes on button press in dcrem.
function dcrem_Callback(hObject, eventdata, handles)
% hObject    handle to dcrem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dcrem


% --- Executes on button press in trendoff.
function trendoff_Callback(hObject, eventdata, handles)
% hObject    handle to trendoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trendoff


% --- Executes on button press in jiri100.
function jiri100_Callback(hObject, eventdata, handles)
% hObject    handle to jiri100 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of jiri100


% --- Executes on button press in cliplvl.
function cliplvl_Callback(hObject, eventdata, handles)
% hObject    handle to cliplvl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cliplvl

ew=handles.ewcor;
ns=handles.nscor;
ver=handles.vercor;
dt = handles.dt;
tim=handles.newsamples;
%read clip info
digisens_ns=handles.digisens_ns;
seismsens_ns=handles.seismsens_ns;
digisens_ew=handles.digisens_ew;
seismsens_ew=handles.seismsens_ew;
digisens_ver=handles.digisens_ver;
seismsens_ver=handles.seismsens_ver;
%prepare time axis in sec
time_sec=((tim.*dt)-dt);

% %%%%%% make the clipping lines
 tt(1)=time_sec(1);
 tt(2)=time_sec(length(time_sec));
%%%% Compute Clip level suppose we have 24 bit digitizer...
 clvalue_ns(1)=(1/(digisens_ns*seismsens_ns))*2^23;
 clvalue_ns(2)=(1/(digisens_ns*seismsens_ns))*2^23;
%%%%
 clvalue_ew(1)=(1/(digisens_ew*seismsens_ew))*2^23;
 clvalue_ew(2)=(1/(digisens_ew*seismsens_ew))*2^23;
%%%%
 clvalue_ver(1)=(1/(digisens_ver*seismsens_ver))*2^23;
 clvalue_ver(2)=(1/(digisens_ver*seismsens_ver))*2^23;

% %plot CORRECTED data
axes(handles.ewaxis)
plot(time_sec,ew,'r',tt,clvalue_ew,'g',tt,clvalue_ew.*-1,'g')
%plot(time_sec,ew,'r')
set(handles.ewaxis,'XMinorTick','on')
grid on
% title('EW')

axes(handles.nsaxis)
plot(time_sec,ns,'r',tt,clvalue_ns,'g',tt,clvalue_ns.*-1,'g')

%plot(time_sec,ns,'r')
set(handles.nsaxis,'XMinorTick','on')
grid on
% title('NS')

axes(handles.veraxis)
plot(time_sec,ver,'r',tt,clvalue_ver,'g',tt,clvalue_ver.*-1,'g')

%plot(time_sec,ver,'r')
set(handles.veraxis,'XMinorTick','on')
grid on
% title('Ver')
xlabel('Seconds')
ylabel('m/sec')


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
