function varargout = plotres(varargin)
% PLOTRES M-file for plotres.fig
%      PLOTRES, by itself, creates a new PLOTRES or raises the existing
%      singleton*.
%
%      H = PLOTRES returns the handle to a new PLOTRES or the handle to
%      the existing singleton*.
%
%      PLOTRES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTRES.M with the given input arguments.
%
%      PLOTRES('Property','Value',...) creates a new PLOTRES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotres_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to plotres_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotres

% Last Modified by GUIDE v2.5 24-Mar-2021 00:28:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotres_OpeningFcn, ...
                   'gui_OutputFcn',  @plotres_OutputFcn, ...
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


% --- Executes just before plotres is made visible.
function plotres_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotres (see VARARGIN)

% Choose default command line output for plotres
handles.output = hObject;
%% 
h=dir('invert');

if isempty(h)
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%
% Check if we have plot options

h=dir('waveplotoptions.isl');

if length(h) == 1
    fid = fopen('waveplotoptions.isl','r');
    nor=fscanf(fid,'%f',1);
    usel=fscanf(fid,'%f',1);
    ftime=fscanf(fid,'%f',1);
    totime=fscanf(fid,'%f',1);
    pvar=fscanf(fid,'%f',1);
    pbw=fscanf(fid,'%f',1);
    normsyn=fscanf(fid,'%f',1);
    netcode=fscanf(fid,'%f',1);
    fclose(fid);
    
        set(handles.ftime,'String',ftime)
        set(handles.totime,'String',totime)
    
        if nor==1
            set(handles.check1,'Value',1)
        elseif nor==0
            set(handles.check1,'Value',0)
        end
        
        if usel==1
            set(handles.uselimits,'Value',1)
        elseif usel==0
            set(handles.uselimits,'Value',0)
        end
    
        if pvar==1
            set(handles.svarred,'Value',1)
        elseif pvar==0
            set(handles.svarred,'Value',0)
        end

        if pbw==1
            set(handles.bw,'Value',1)
        elseif pbw==0
            set(handles.bw,'Value',0)
        end
        
        if normsyn==1
            set(handles.normsyn,'Value',1)
        elseif pbw==0
            set(handles.normsyn,'Value',0)
        end     
        
        if netcode==1
            set(handles.stacode,'Value',1)
        elseif pbw==0
            set(handles.stacode,'Value',0)
        end             
        
        
else
    disp('wave plot options not found')
end


%% prepare event id...

h=dir('event.isl');

if isempty(h)
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    eventagency=fscanf(fid,'%s',1);
    fclose(fid);
end

%
% eventid=[eventdate '  ' eventhour ':' eventmin ':' eventsec(1:2) ];
% eventidnew=[eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec];

set(handles.depth,'String',num2str(epidepth))          % Update location depth for polarity

eventid=[eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec  ];
eventidnew=[eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec  ];

%% read names of files for plotting
% read allstat.dat
if ispc
   h=dir('.\invert\allstat.dat');
else
   h=dir('./invert/allstat.dat');
end
   
if isempty(h) 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
else
      % try to guess allstat version 
          if ispc
            fid=fopen('.\invert\allstat.dat');
          else
            fid=fopen('./invert/allstat.dat');
          end
                 tline=fgets(fid);
                [~,cnt]=sscanf(tline,'%s');
            fclose(fid);
      %
       switch cnt
       case 9
                 disp('Found current version of allstat e.g. STA 1 1 1 1 f1 f2 f3 f4')
                    if ispc 
                       [staname,~,~,~,~,~,~,~,~] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                    else
                       [staname,~,~,~,~,~,~,~,~] = textread('./invert/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                    end
                 % number of stations
                 nostations = length(staname);
                   for i=1:nostations
                      realfilfilename{i}=[char(staname{i}) 'fil.dat'];
                      realsynfilename{i}=[char(staname{i}) 'syn.dat'];
                   end
        % now check if all files are present 
           cd invert
              for i=1:nostations
                 if exist(realfilfilename{i},'file')
                   disp(['Found ' realfilfilename{i}])
                 else
                   disp(['File ' realfilfilename{i} ' is missing'])
                   errordlg(['File ' realfilfilename{i} '  not found in invert folder. Run Invert' ] ,'File Error');    
                 end
              end
%
              for i=1:nostations
                 if exist(realsynfilename{i},'file')
                   disp(['Found ' realsynfilename{i}])
                 else
                   disp(['File ' realsynfilename{i} ' is missing'])
                   errordlg(['File ' realsynfilename{i} '  not found in invert folder. Run Invert' ] ,'File Error');    
                 end
              end
           cd ..
       case 6
                 disp('Found version of allstat without frequencies e.g. 001 1 1 1 1 STA. Cannot be used.')
                 warndlg('Your allstat.dat file is old. ISOLA cannot continue run inversion again','!! Warning !!')
                 nostations=1;
       case 5
                 disp('Found old version of allstat without frequencies and without station masking e.g. STA 1 1 1 1. Cannot be used.')
                 warndlg('Your allstat.dat file is old. ISOLA cannot continue run inversion again','!! Warning !!')
                 nostations=1;
       end
               
end              
%              
              
%%% add All option
staname{nostations+1,1}='All';
%staname

%% read inversion specific data....
if ispc 
   a=exist('.\invert\inpinv.dat','file');
else
   a=exist('./invert/inpinv.dat','file');
end

if a==2
   if ispc
      [id,dtime,nsubevents,~,~,invband,~] = readinpinv('.\invert\inpinv.dat');
   else
      [id,dtime,nsubevents,~,~,invband,~] = readinpinv('./invert/inpinv.dat');
   end
       
%        fid  = fopen('.\invert\inpinv.dat','r');
% 
%       for i=1:3
%          aa=fgetl(fid);
%       end
%          dtime=fgetl(fid);
%       for i=1:6
%          aa=fgetl(fid);
%       end
%          nsubevents=fgetl(fid);
%       for i=1:2
%          aa=fgetl(fid);
%       end
%           invband=fgetl(fid);
% 
%       fclose(fid);

dtime=num2str(dtime);
nsubevents=num2str(nsubevents);
invband=[num2str(invband(1)) ' - ' num2str(invband(4))];

handles.id=id;
handles.dtime=dtime;
handles.nostations=nostations;
handles.staname=staname;
handles.invband=invband;
handles.eventid=eventid;
handles.eventidnew=eventidnew;
handles.nsubevents=nsubevents;

% add time info for origin
eventorign=[eventdate ' ' eventhour ' ' eventmin ' ' eventsec];

handles.evtorigin=eventorign;

% Update handles structure
guidata(hObject, handles);

set(handles.stationslistbox,'String',staname)          %%%%% Fill listbox with stations names
set(handles.stationslistbox,'Value',nostations+1)      %%%%% Set default plot to All stations

else
    disp('Please run inversion ... Inpinv.dat is missing..')
end
%% try to set 10% correlation limit for FSTVAR
if ispc 
   a=exist('.\invert\corr01.dat','file');
else
   a=exist('./invert/corr01.dat','file');
end

if a==2
    
  try
     cd invert
        [~,~,variance,~,~,~,~,~,~,~,~,~,~] = textread('corr01.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',2);

      maxvar=max(variance);
      tenpercvar=maxvar/10;   % set at 10%
      cor2=maxvar-tenpercvar;
  
      disp(['Maximum correlation value ' num2str(maxvar) ]);
      disp(['10% of Maximum correlation level ' num2str(cor2) ]);
      
      set(handles.tsvarcor,'String',num2str(cor2))
      
     cd ..
     
  catch
    cd ..
  end

else
    disp('Please run inversion ... corr01.dat is missing..') 
end
%%

h=dir('tsources.isl');

if isempty(h)
    errordlg('tsources.isl file doesn''t exist. Run Source create. ','File Error');
  return    
else
    fid = fopen('tsources.isl','r');
    tsource=fscanf(fid,'%s',1)
    
     if strcmp(tsource,'line')
        disp('Inversion was done for a line of sources.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
          
        conplane=2;   %%% Line
        % dummy sdepth
        sdepth=-333;
        % Update handles structure
        guidata(hObject, handles);
        
     elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        
         conplane=0;   %%%depth

         handles.sdepth=sdepth;
         % Update handles structure
         guidata(hObject, handles);
    
     elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
           noSourcesstrike=fscanf(fid,'%i',1)
           strikestep=fscanf(fid,'%f',1)
           noSourcesdip=fscanf(fid,'%i',1)
           dipstep=fscanf(fid,'%f',1)
%           nsources=noSourcesstrike*noSourcesdip;
          
           invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
      
           conplane=1;
           
           %% dummy sdepth
           sdepth=-333;
            distep=-333;
            
           %%%%%%%%%%%%%%%%%write to handles
           handles.noSourcesstrike=noSourcesstrike;
           handles.strikestep=strikestep;
           handles.noSourcesdip=noSourcesdip;
           handles.dipstep=dipstep;
           % Update handles structure
           guidata(hObject, handles);
           
     elseif strcmp(tsource,'point')
       disp('Inversion was done for one source.')
       nsources=fscanf(fid,'%i',1);
       distep=fscanf(fid,'%f',1);
       sdepth=fscanf(fid,'%f',1);
       invtype=fscanf(fid,'%c');
        

        conplane=3;
        % Update handles structure
        guidata(hObject, handles);
       
     end
     
          fclose(fid);
          
end

%% Update the NP1 NP2 text

cd invert

[~,~,~,~,~,~,~,inv1_sdr1,inv1_sdr2,~]=readinv1(nsources,1);

NP1=[num2str(inv1_sdr1(1)) '/' num2str(inv1_sdr1(2)) '/' num2str(inv1_sdr1(3))];
NP2=[num2str(inv1_sdr2(1)) '/' num2str(inv1_sdr2(2)) '/' num2str(inv1_sdr2(3))];

cd ..

set(handles.NP1,'String',NP1)   
set(handles.NP2,'String',NP2)   

%% read ISOLA defaults
[gmt_ver,psview,npts,htmlfolder] = readisolacfg;

if strcmp(htmlfolder,'null')
   set(handles.html,'Visible','off')  % html is not needed
   set(handles.html,'Enable','off')  % html is not needed
else
    
end



%% disable Plot correlation vs Source if we have only 1 sourse..!!

if nsources == 1
   set(handles.inv1,'Enable','off')
else    
end

%%
handles.gmt_ver=gmt_ver;
handles.psview=psview;
handles.npts=npts;
handles.htmlfolder=htmlfolder;


    if exist([pwd '\station_file.isl'],'file')
           fid = fopen('station_file.isl','r'); 
              fullstationfile=fgetl(fid);
           fclose(fid);
           handles.fullstationfile=fullstationfile;
           disp([ fullstationfile ' will be used for network code'])
           handles.fullstationfile=fullstationfile;
    else  
           handles.fullstationfile='';
           set(handles.stacode,'Value',0);
    end




handles.conplane=conplane;
handles.nsources=nsources;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotres wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotres_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is plotres 10/10/2019');
disp('Changes:');
disp('Selection of subevent in cor vs source plotting and bug fixes');
disp('Use the isolacfg.isl file');
disp('  ');

% corrects a small bug with wrong plotting of selected components in
% best.ps           31/07/09
% corrects problem with waveform ploting  when best.ps  and in1.ps file was
% open....2/8/09
%handles new tsource.isl 
%uses limits in waveform plotting
%remembers settings for waveform plotting
% handles new allstat.dat 29/10


% --- Executes on button press in plreal.
function plreal_Callback(hObject, eventdata, handles)
% hObject    handle to plreal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nostations=handles.nostations;
staname=handles.staname;

uselimits=get(handles.uselimits,'Value');

ftime =  str2double(get(handles.ftime,'String'));
totime = str2double(get(handles.totime,'String'));

npts=handles.npts;

%%%%%%%%%%%%%FIND OUT USER SELECTION %%%%%%%%%%%%%%
%%%%%%%%%%% code based on Matlab example of list box....!!!

index_selected = get(handles.stationslistbox,'Value');

if length(index_selected)==1   %%% plot ONE or ALL stations ONLY
    
    if index_selected == nostations+1                          %%%ALL
          disp('Plotting All Stations Real data in one Figure')
          plotallstationsReal(nostations,staname,uselimits,ftime,totime,npts)
    elseif index_selected ~= nostations+1                       %%% just one
          disp('Plotting ONLY One Station Real data in one Figure')
          stationname=staname{index_selected}
          plotonestationReal(stationname,uselimits,ftime,totime,npts)
    end
      
elseif length(index_selected) ~=1   %%%Plot more than one and maybe ALL stations...
    
      for i=1:length(index_selected)
          
         if index_selected(i) ~= nostations+1
             disp('Plotting selected stations Real data ')
             stationname=staname{index_selected(i)}
             plotonestationReal(stationname,uselimits,ftime,totime,npts)
         elseif index_selected(i) == nostations+1
             disp('Plotting All Stations Real data in one Figure')
             plotallstationsReal(nostations,staname,uselimits,ftime,totime,npts)
         else
             disp('Error')
         end
          
      end
      
else
disp('Error')
end


% --- Executes on button press in plsyn.
function plsyn_Callback(hObject, eventdata, handles)
% hObject    handle to plsyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


nostations=handles.nostations;
staname=handles.staname;


uselimits=get(handles.uselimits,'Value');

ftime =  str2double(get(handles.ftime,'String'));
totime = str2double(get(handles.totime,'String'));

npts=handles.npts;

%%%%%%%%%%%%%FIND OUT USER SELECTION %%%%%%%%%%%%%%
%%%%%%%%%%% code based on Matlab example of list box....!!!

index_selected = get(handles.stationslistbox,'Value');

if length(index_selected)==1   %%% plot ONE or ALL stations ONLY
    
    if index_selected == nostations+1                          %%%ALL
          disp('Plotting All Stations Synthetic data in one Figure')
          plotallstationssyn(nostations,staname,uselimits,ftime,totime,npts)
    elseif index_selected ~= nostations+1                       %%% just one
          disp('Plotting ONLY One Station Synthetic data in one Figure')
          stationname=staname{index_selected}
          plotonestationsyn(stationname,uselimits,ftime,totime,npts)
    end
      
elseif length(index_selected) ~=1   %%%Plot more than one and maybe ALL stations...
    
      for i=1:length(index_selected)
          
         if index_selected(i) ~= nostations+1
             disp('Plotting selected stations Synthetic data ')
             stationname=staname{index_selected(i)}
             plotonestationsyn(stationname,uselimits,ftime,totime,npts)
         elseif index_selected(i) == nostations+1
             disp('Plotting All Stations Synthetic data in one Figure')
             plotallstationssyn(nostations,staname,uselimits,ftime,totime,npts)
         else
             disp('Error')
         end
          
      end
      
else
disp('Error')
end


% --- Executes on button press in plrealsyn.
function plrealsyn_Callback(hObject, eventdata, handles)
% hObject    handle to plrealsyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%inversion band
invband=handles.invband;

% extra check here for invband

if ispc 
   a=exist('.\invert\inpinv.dat','file');
else
   a=exist('./invert/inpinv.dat','file');
end

if a==2
   if ispc
      [~,~,~,~,~,invband,~] = readinpinv('.\invert\inpinv.dat');
   else
      [~,~,~,~,~,invband,~] = readinpinv('./invert/inpinv.dat');
   end
   
   invband=[num2str(invband(1)) ' - ' num2str(invband(4))];

else
    disp('Cannot find inpinv.dat in invert folder')
end
   
%% 
   
eventid=handles.eventid;
dtime=handles.dtime;

nostations=handles.nostations;
staname=handles.staname;

npts=handles.npts;

%%%%%%%%%%%%%FIND OUT USER SELECTION %%%%%%%%%%%%%%
%%%%%%%%%%% code based on Matlab example of list box....!!!

index_selected = get(handles.stationslistbox,'Value');
normalized = get(handles.check1,'Value');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uselimits=get(handles.uselimits,'Value');

ftime =  str2double(get(handles.ftime,'String'));
totime = str2double(get(handles.totime,'String'));

addvarred = get(handles.svarred,'Value');
pbw = get(handles.bw,'Value');

net_use=get(handles.stacode,'Value');
fullstationfile=handles.fullstationfile

normsynth=get(handles.normsyn,'Value');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(index_selected)==1   %%% plot ONE or ALL stations ONLY
    
    if index_selected == nostations+1                          %%%ALL
          disp('Plotting All Stations Real-Synthetic data in one Figure')
          plotallstations(nostations,staname,normalized,invband,ftime,totime,uselimits,dtime,eventid,addvarred,pbw,net_use,fullstationfile,normsynth,npts)
    elseif index_selected ~= nostations+1                       %%% just one
          disp('Plotting ONLY One Station  Real-Synthetic  data in one Figure')
          stationname=staname{index_selected}
          plotonestation(stationname,normalized,ftime,totime,uselimits,normsynth,npts)
    end
      
elseif length(index_selected) ~=1   %%%Plot more than one and maybe ALL stations...
 
%% plot selected in one plot    
    disp('Plotting selected stations  Real-Synthetic  data ')
%     stationname=staname(index_selected);     nostations=length(stationname);
%     
%     plotselectedstations(nostations,stationname,normalized,invband,ftime,totime,uselimits,dtime,eventid,addvarred,pbw,net_use,fullstationfile,normsynth)
%%         
      for i=1:length(index_selected)
          
         if index_selected(i) ~= nostations+1
             disp('Plotting selected stations  Real-Synthetic  data ')
             stationname=staname{index_selected(i)};
             nostations=length(stationname);
             plotonestation(stationname,normalized,ftime,totime,uselimits,normsynth,npts)
         elseif index_selected(i) == nostations+1
             disp('Plotting All Stations  Real-Synthetic  data in one Figure')
             plotallstations(nostations,staname,normalized,invband,ftime,totime,uselimits,dtime,eventid,addvarred,pbw,net_use,fullstationfile,normsynth,npts)
         else
             disp('Error')
         end
          
      end
      
else
disp('Error')
end

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.plotres)


% --- Executes on button press in dcmat.
function dcmat_Callback(hObject, eventdata, handles)
% hObject    handle to dcmat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tensor.
function tensor_Callback(hObject, eventdata, handles)
% hObject    handle to tensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%  Inversion Band
invband=handles.invband;
nostations=handles.nostations;
staname=handles.staname(1:nostations);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%
%check if INVERT exists..!
h=dir('invert');

if isempty(h)
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% find distance step
h=dir('tsources.isl');
source_gmtfile=0;

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
       source_gmtfile=1;
       
     elseif strcmp(tsource,'depth')
      disp('Inversion was done for a line of sources under epicenter.')
      nsources=fscanf(fid,'%i',1);
      distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
      source_gmtfile=0;
      
     elseif strcmp(tsource,'plane')
      disp('Inversion was done for a plane of sources.')
      nsources=fscanf(fid,'%i',1);
%       distep=fscanf(fid,'%f',1);
                noSourcesstrike=fscanf(fid,'%i',1);
                strikestep=fscanf(fid,'%f',1);
                noSourcesdip=fscanf(fid,'%i',1);
                dipstep=fscanf(fid,'%f',1);
                source_gmtfile=1;
                nsources=noSourcesstrike*noSourcesdip;

           invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
      
     elseif strcmp(tsource,'point')
      disp('Inversion was done for one source.')
      nsources=fscanf(fid,'%i',1);
      distep=fscanf(fid,'%f',1);
      sdepth=fscanf(fid,'%f',1);
      invtype=fscanf(fid,'%c');
      
     end
     
          fclose(fid);
          
 end
%% 
%     nsources=fscanf(fid,'%i',1);
%     distep=fscanf(fid,'%f',1);
%         if distep  == -1000.0
%                 noSourcesstrike=fscanf(fid,'%i',1)
%                 strikestep=fscanf(fid,'%i',1)
%                 noSourcesdip=fscanf(fid,'%i',1)
%                 dipstep=fscanf(fid,'%i',1)
%                 source_gmtfile=1;
%                 nsources=noSourcesstrike*noSourcesdip;
% 
%            invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
% 
%         else
%         sdepth=fscanf(fid,'%f',1);
%         invtype=fscanf(fid,'%c');
%         end
%     fclose(fid);
% end

% h=dir('trialsource.isl');
% if length(h) == 0; 
%     errordlg('trialsource.isl file doesn''t exist. Run Source create. ','File Error');
%   return    
% else
%     fid = fopen('trialsource.isl','r');
%     type=fscanf(fid,'%s');
%     fclose(fid);
%     if strcmp(type,'depth')
%     disp('Inversion will be done for a line of sources under epicenter.')
%     source_gmtfile=0
%      elseif strcmp(type,'line')
%      source_gmtfile=1
%      elseif strcmp(type,'plane')
%      source_gmtfile=1
%      end
%  end
%  
%%
% find how many stations
h=dir('stations.isl');

if isempty(h)
    errordlg('Stations.isl file doesn''t exist. Run Station select. ','File Error');
  return    
else
    fid = fopen('stations.isl','r');
    nstations=fscanf(fid,'%i',1);
    fclose(fid);
end
%%%%%%%%%%%%%%%%%%%
%%% learn station names
stanames=get(handles.stationslistbox,'String');
%
% whos stanames
%% 
%%% check event.isl files with event info

h=dir('event.isl');

if isempty(h) 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    
    eventdate=fscanf(fid,'%s',1);
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    eventagency=fscanf(fid,'%s',1);
    fclose(fid);
end
%  
eventid=[eventdate ' ' eventhour ':' eventmin ':' eventsec];  % ' from ' eventagency ];
eventid2=['Lat ' num2str(eventcor(2)) '  Lon ' num2str(eventcor(1)) '  Depth  ' num2str(epidepth) ];
eventidnew=handles.eventidnew;

%%  depth of sources...!!
%%%check the sources.gmt in gmtfiles
% pwd
try
 cd gmtfiles
 h=dir('sources.gmt');

if isempty(h)
  errordlg('Sources.gmt file doesn''t exist. Run Source definition. ','File Error');
  return
else
   
%%%%read coordinates.....
 if source_gmtfile==0

     fid  = fopen('sources.gmt','r');
      [srclon,srclat,depth,sourceno] = textread('sources.gmt','%f %f %f %f',nsources,'headerlines',1);
     fclose(fid);

 elseif source_gmtfile==1
     
     fid  = fopen('sources.gmt','r');
      [srclon,srclat,scale,depth,sourceno,char1] = textread('sources.gmt','%f %f %f %f %f %s',nsources);
     fclose(fid);
 end

end

   cd ..
catch
    cd ..
end
%% check which station/component was used

try

    cd invert
    
        h=dir('allstat.dat');

          if isempty(h)   
                errordlg('Allstat.dat file doesn''t exist. Run Invert. ','File Error');
                
           cd ..
          return
          
          else
          end
          
%           %read data in 5 arrays
%           [~,d1,d2,d3,d4] = textread('allstat.dat','%s %f %f %f %f',-1); 
%           %nostations=length(staname);

% ONLY new version of allstat.dat is allowed
       
           [NS,d1,d2,d3,d4,f1,f2,f3,f4] = textread('allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 

%            if isequal(char(NS(1)),'001') && (length(char(S(1)))~=0)
%              disp('Found new allstat.dat format')
%            else
%              [~,d1,d2,d3,d4] = textread('allstat.dat','%s %f %f %f %f ',-1); 
%              disp('Found old allstat.dat format')
%            end 
          
          
for i=1:nostations
    if d1(i) == 0
        std2(i)='-';
        std3(i)='-';
        std4(i)='-';
    elseif d1(i) == 1
        std2(i)='+';
        std3(i)='+';
        std4(i)='+';
        
         if d2(i) ==  0 
             std2(i)='-';       %%%%%%   
         end        
         
         if d3(i) == 0          %%%%%%
             std3(i)='-';            
         end
         
         if d4(i) ==  0          %%%%%%
             std4(i)='-';
         end
         
         
    end
end
a=std2';
b=std3';
c=std4';
stationsused=[staname cellstr(a) cellstr(b) cellstr(c)];


  cd .. % back one folder


catch
    cd ..
end
%% Prepare a file in gmtfiles with USED stations
      if ispc
          [station_name,lat,lon] = textread('.\gmtfiles\selstat.gmt','%s %f %f',-1); 
               fid3 = fopen('.\gmtfiles\notusedstat.gmt','w');
      else
          [station_name,lat,lon] = textread('./gmtfiles/selstat.gmt','%s %f %f',-1); 
               fid3 = fopen('./gmtfiles/notusedstat.gmt','w');
      end
      
for i=1:numel(lat)
    
     if d1(i) == 0
        if ispc
            % loop through the selstat.gmt 
             dd=strfind(station_name,char(NS(i)));
             mylogic = ~cellfun('isempty',dd);
             
         fprintf(fid3,'%f %f  %s\r\n',lon(mylogic),lat(mylogic),char(NS(i)));
        else
            % loop through the selstat.gmt 
             dd=strfind(station_name,char(NS(i)));
             mylogic = ~cellfun('isempty',dd);
             
         fprintf(fid3,'%f %f  %s\n',lon(i),lat(i),char(station_name(i)));
        end
     else
     end
end

fclose(fid3);


%%  Read station.dat and find epicentral distance
% read station.dat 
 
[C,nostations2]=readstationfile;
if nostations2~=nostations
    errordlg('Number of stations in station.dat is not the same as in allstat.dat. Check files.','File Error');
else
end
for i=1:nostations
       if strcmp(stationsused{i,1}, C{6}(i))
             epidist(i)=C{5}(i);
       else
           errordlg('Station names in station.dat is not the same as in allstat.dat. Check files.','File Error');
       end
end
%% Calculate FMVAR STVAR
                  pwd
                  %check if we have snr.isl
                  h=dir('snr.isl');

                  if isempty(h)
                      snr=NaN;
                  else
                      disp('Found snr.isl file')
                      fid3 = fopen('snr.isl','r');
                         snr=fscanf(fid3,'%f');
                      fclose(fid3);
                  end
                      
                      

                  cor=str2num(get(handles.tsvarcor,'String'));
                  
% check inpinv for fixed mech inversion    
% check if we have inpinv.dat
if ispc
 h=dir('.\invert\inpinv.dat');
else
 h=dir('./invert/inpinv.dat');   
end

if isempty(h)
    errordlg('inpinv.dat file doesn''t exist. Run Inversion. ','File Error');
  return    
else
    if ispc
          [id,~,~,~,~,~,~] = readinpinv('.\invert\inpinv.dat');
             if(id==4)
               disp('Inversion was down for fixed mechanism. Cannot calculate index.')
               fmvar1=NaN;
               fmvar2=NaN;
               stvar=NaN;
             else
                  disp('Calling compute_fm_stvar')
                  [fmvar1,fmvar2,stvar]=compute_fm_stvar(cor);
             end
             
             if(id==4)
                 inver_type='Fixed';
             elseif(id==3)
                 inver_type='DC-constrained';
             elseif(id==2)
                 inver_type='Deviatoric';
             elseif(id==1)
                 inver_type='Full';
             end
             
    else       
          [id,~,~,~,~,~,~] = readinpinv('./invert/inpinv.dat');
             if(id==4)
               disp('Inversion was down for fixed mechanism. Cannot calculate index.')
               fmvar1=NaN;
               fmvar2=NaN;
               stvar=NaN;
             else
                  disp('Calling compute_fm_stvar')
                  [fmvar1,fmvar2,stvar]=compute_fm_stvar(cor);
             end
             if(id==4)
                 inver_type='Fixed';
             elseif(id==3)
                 inver_type='DC-constrained';
             elseif(id==2)
                 inver_type='Deviatoric';
             elseif(id==1)
                 inver_type='Full';
             end

    end
end                  
                  
                  
%%
% plot results in GMT ..using inv3.dat

%try
% %%%%%%%%
cd invert
pwd

h=dir('inv3.dat');

if isempty(h)  
    errordlg('inv3.dat file doesn''t exist. Run Invert. ','File Error');
    cd ..
  return    
else
    fid = fopen('inv3.dat','r');
     [srcpos,srctime,mrr, mtt, mff, mrt, mrf, mtf ] = textread('inv3.dat','%f %f %q %q %q %q %q %q');
    fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h=dir('inv2.dat');

%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
if isempty(h)  
    errordlg('inv2.dat file doesn''t exist. Run Invert. ','File Error');
    cd ..
  return    
else
    fid = fopen('inv2.dat','r');
    tline = fgetl(fid);
      if length(tline) > 125
          disp('New inv2.dat')
          inv2age='new';
          fclose(fid);
          fid = fopen('inv2.dat','r');
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
          fclose(fid);
      else
          disp('Old inv2.dat')
          inv2age='old';
          fclose(fid);
          fid = fopen('inv2.dat','r');
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,dc,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
          fclose(fid);
      end
end      
    
%%%%%%%%%%%%%%%%%%%%
% if length(h) == 0; 
%     errordlg('inv2.dat file doesn''t exist. Run Invert. ','File Error');
%     cd ..
%   return    
% else
%     fid = fopen('inv2.dat','r');
%     [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
%     fclose(fid);
% end

%%%%%%%%%%%%%%%%%use factnor

h=dir('inv4.dat');   %%% new inv4 format 

if isempty(h)  
    errordlg('inv4.dat file doesn''t exist. Run Invert. ','File Error');
    cd ..
  return    
else
    fid = fopen('inv4.dat','r');

       line=fgets(fid);        %01 line
       line=fgets(fid);        %02 line
       line=fgets(fid);        %03 line
       line=fgets(fid);        %04 line
       line=fgets(fid);        %05 line
       line=fgets(fid);        %06 line
       line=fgets(fid);        %07 line
       line=fgets(fid);        %08 line
       line=fgets(fid);        %09 line
       line=fgets(fid);        %10 line
       line=fgets(fid);        %11 line
       line=fgets(fid);        %12 line

%       overallvarredvalue=str2num(num2str(str2num(strrep(line,'varred= ','')),4));
         overallvarredvalue = sscanf(line,'%e');
         
%         line=fgets(fid);        %05 line
%        line=fgets(fid);        %06 line
%        line=fgets(fid);        %07 line
%         fact =  fscanf(fid,'%c',9);
%         factnor=fscanf(fid,'%e',1);
    fclose(fid);
end

%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%

if length(srcpos) ~= 1
%            srcstr='';
%            
%            for i=1:length(srcpos)
%                srcstr=[srcstr num2str(srcpos(i)) ','];
%            end
%     
            a=['There are ' num2str(length(srcpos)) ' subevents. Which one do you want to plot.?' ];
            prompt = {a};
            dlg_title = 'Input Trial Source Number';
            num_lines= 1;
            def     = {'1'};
            answer  = inputdlg(prompt,dlg_title,num_lines,def);
            psrcpos = str2num(answer{1});
            disp(['Now Plotting trial source number  ' num2str(srcpos(psrcpos)) ])
            
            if psrcpos ~=1 
                hw=warndlg('Variance Reduction reported here is total for this subevent and all previous ones.','!! Warning !!')
                uiwait(hw);
            end
            
else
    psrcpos=1;
end

disp(['No of sources    :  ' num2str(nsources)]);
disp(['Selected source position  :  ' num2str(psrcpos)]);

%read values form inv1.dat
[inv1_isour_shift,inv1_eigen,inv1_mom,inv1_mag,inv1_vol,inv1_dc,inv1_clvd,inv1_sdr1,inv1_sdr2,inv1_varred]=readinv1(nsources,psrcpos);

%%%find exponent ... in common base..
mrrtmp=num2str(mrr{psrcpos});
mtttmp=num2str(mtt{psrcpos});
mfftmp=num2str(mff{psrcpos});
mrttmp=num2str(mrt{psrcpos});
mrftmp=num2str(mrf{psrcpos});
mtftmp=num2str(mtf{psrcpos});

harv=[str2double(mrr{psrcpos});str2double(mtt{psrcpos});str2double(mff{psrcpos});str2double(mrt{psrcpos});str2double(mrf{psrcpos});str2double(mtf{psrcpos})]

%%
T = evalc('disp(harv)')

%% check if * exists

checkstar=strfind(T,'*')

if isempty(checkstar)
   
format shortEng
T = evalc('disp(harv)')

start = regexp(T,'\n')
% Ta=T(1:start(1))
% format long
Ta1=strrep(strrep(strrep(strrep(T,'+',' '),'*','  '),'e',' '),'E',' ')

Atmp = sscanf(Ta1,'%f') 

format
harcof = [Atmp(1) Atmp(3) Atmp(5) Atmp(7) Atmp(9) Atmp(11)]
    
maxexp =Atmp(2)

format

else
 % same procedure as before
start = regexp(T,'\n')
Ta=T(1:start(1))
% maxexp=str2num(Ta(strfind(Ta,'e+0')+3:strfind(Ta,'e+0')+5))
% needed for new matlab...
format long

Ta1=strrep(strrep(strrep(strrep(Ta,'+',' '),'*','  '),'e',' '),'E',' ')

Atmp = sscanf(Ta1,'%f')  
maxexp=Atmp(2)


Tb=T((start(2)+1):length(T))
harcof = sscanf(Tb,'%f',6);

format
end


% atmp1=mrr{psrcpos};
% ex(1)=str2num(atmp1(length(atmp1)-1:length(atmp1)));
% atmp2=mtt{psrcpos};
% ex(2)=str2num(atmp2(length(atmp2)-1:length(atmp2)));
% atmp3=mff{psrcpos};
% ex(3)=str2num(atmp3(length(atmp3)-1:length(atmp3)));
% atmp4=mrt{psrcpos};
% ex(4)=str2num(atmp4(length(atmp4)-1:length(atmp4)));
% atmp5=mrf{psrcpos};
% ex(5)=str2num(atmp5(length(atmp5)-1:length(atmp5)));
% atmp6=mtf{psrcpos};
% ex(6)=str2num(atmp6(length(atmp6)-1:length(atmp6)));
% 
% ex=ex';
% 
% expon=10.^ex;
% 
% harcof=harv./expon;
% 
% [maxexp,posmax]=max(ex);
% [minexp,posmin]=min(ex);
% 
% for i=1:6
% harcof(i)=harcof(i)/10^(maxexp-ex(i));
% end

%harcof;

% whos srcpos2 sourceno lon lat srclon srclat

 for i=1:length(srcpos2)

%        srctime2(i,1)=srctime2(i,1)*dt;   %%%%convert time shift to
%        seconds.....!!!!  (inv2 will be in seconds)!!
     
     for j=1:length(sourceno)
             
         if  srcpos2(i,1) == sourceno(j,1)
             srclon(i,1) = srclon(j,1);     %%%%Longitude 
             srclat(i,1) = srclat(j,1);     %%%%Longitude 
         end    
         
     end
     
 end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('  ')
disp('  ')

disp(['Centroid Position         '  num2str(srcpos(psrcpos))])
disp(['Centroid Time             '  num2str(srctime2(psrcpos)) '  (sec) relative to origin' ])
disp(['Centroid Longitude       ' num2str(srclon(psrcpos,1))])
disp(['Centroid Latitude        ' num2str(srclat(psrcpos,1))])

disp(['Centroid Depth (km)       '  num2str(depth(srcpos(psrcpos))) ])


disp('  ')
disp(['Moment (Nm)             '  num2str(mo(psrcpos),'%6.3e')])
%disp(['Moment/Factnor)         '  num2str(mo(psrcpos)/factnor,'%6.3e')])
%mommag=0.67*log10(mo(psrcpos)) - 6; %! Hanks & Kanamori (1979)
%mommagF=0.67*log10(mo(psrcpos)/factnor) - 6; %! Hanks & Kanamori (1979)

%mommag=(2/3)*(log10(mo(psrcpos)) - 9.1); %! Hanks & Kanamori (1979)
%mommagF=(2/3)*(log10(mo(psrcpos)/factnor) - 9.1); %! Hanks & Kanamori (1979)

mommag=(2.0/3.0)*log10(mo(psrcpos)) - 6.0333;  % changed 06/11/2020 


disp(['Mw                      '  num2str(mommag,4) '             Hanks & Kanamori (1979)'])
%disp(['Mw(Mo/factnor)          '  num2str(mommagF,4)  ])

disp('  ')
disp(['VOL%                    '  num2str(inv1_vol)])
disp(['DC%                     '  num2str(inv1_dc)])
%disp(['CLVD%                   '  num2str(100-dc(psrcpos),3)])

disp(['CLVD%                   '  num2str(inv1_clvd)])

disp(['Variance reduction from the used stations only '  num2str(varred(psrcpos))  ' % ' num2str(varred(psrcpos)*100)])
disp(['Variance reduction from all stations           '  num2str(overallvarredvalue)  ' % ' num2str(overallvarredvalue*100)])
disp(['Condition number  '  num2str(inv1_eigen(2)/inv1_eigen(1))  ]);


disp('  ')
disp('Str1  Dip1  Rake1')
disp(['   ' num2str(str1(psrcpos)) '   ' num2str(dip1(psrcpos)) '   ' num2str(rake1(psrcpos))])
disp('Str2  Dip2  Rake2')
disp(['   ' num2str(str2(psrcpos)) '   ' num2str(dip2(psrcpos)) '   ' num2str(rake2(psrcpos))])

disp('  ')
disp('P-axis   Azimuth   Plunge')
disp(['           ' num2str(aziP(psrcpos)) '       ' num2str(plungeP(psrcpos))])
disp('T-axis   Azimuth   Plunge')
disp(['           ' num2str(aziT(psrcpos)) '       ' num2str(plungeT(psrcpos))])
disp('  ')
disp('  ')
disp('Mrr  Mtt  Mff  Mrt  Mrf  Mtf')
tensorstr=[ '  ' mrr{psrcpos} '  '  mtt{psrcpos} '  '  mff{psrcpos} '  '  mrt{psrcpos} '  '  mrf{psrcpos} '  '  mtf{psrcpos}];
disp(tensorstr)

disp('  ')
disp('  ')

%%
% whos stationsused
disp('         Stations-Components Used')
disp('Station     NS     EW     Ver')

for i=1:nostations
    if length(stationsused{i,1}) ==3
         disp( ['  '   stationsused{i,1} '        '  stationsused{i,2} '      '  stationsused{i,3} '      '  stationsused{i,4} ] )
    elseif length(stationsused{i,1}) ==4
         disp( ['  '   stationsused{i,1} '       '  stationsused{i,2} '      '  stationsused{i,3} '      '  stationsused{i,4} ] )
    elseif length(stationsused{i,1}) ==5
         disp( ['  '   stationsused{i,1} '      '  stationsused{i,2} '      '  stationsused{i,3} '      '  stationsused{i,4} ] )
    else
         disp( ['  '   stationsused{i,1} '      '  stationsused{i,2} '      '  stationsused{i,3} '      '  stationsused{i,4} ] )
    
    end
end

disp(' ')
disp(' ')
disp(' ')

%%
%%% prepare a gmt style file for best moment tensor
%     fid = fopen('btensor.foc','w');
%           fprintf(fid,'%g  %g  %g  %s  %s  %s  %s  %s  %s  %s  %g  %g\r\n',10,10,5,mrrtmp, mtttmp, mfftmp, mrttmp, mrftmp, mtftmp, ex ,0,0);
%     fclose(fid);
% srcpos(psrcpos)

switch inv2age
   case 'old'
      disp('found inv2.dat in old format')
          fid = fopen('btensor.foc','w');
            if ispc
             fprintf(fid,'%g  %g  %g  %f  %f  %f  %f  %f  %f  %f  %g  %g\r\n',5.5,5.5,5,harcof(1), harcof(2), harcof(3), harcof(4), harcof(5), harcof(6), maxexp+7 ,0,0);
            else
             fprintf(fid,'%g  %g  %g  %f  %f  %f  %f  %f  %f  %f  %g  %g\n',5.5,5.5,5,harcof(1), harcof(2), harcof(3), harcof(4), harcof(5), harcof(6), maxexp+7 ,0,0);
            end
          fclose(fid);
   case 'new'
      disp('found inv2.dat in new format')
      Mrr=harcof(1); Mtt=harcof(2); Mpp=harcof(3); Mrt=harcof(4); Mrp=harcof(5); Mtp=harcof(6);
      Mtr=Mrt; Mpr=Mrp; Mpt=Mtp;
            HRV=[Mrr,Mrt,Mrp;Mtr,Mtt,Mtp;Mpr,Mpt,Mpp];
            d= eig(HRV);

          fid = fopen('btensor.foc','w');      %value (in 10*exponent dynes-cm), azimuth, plunge of T, N, P axis.
              if ispc 
                  fprintf(fid,'%g  %g  %g  %f  %f  %f  %f  %f  %f  %f %f %f %f  %g  %g\r\n',5.5,5.5,5,d(3),aziT(psrcpos),plungeT(psrcpos),d(2),aziB(psrcpos),plungeB(psrcpos),d(1),aziP(psrcpos),plungeP(psrcpos), maxexp+7 ,0,0);
              else
                  fprintf(fid,'%g  %g  %g  %f  %f  %f  %f  %f  %f  %f %f %f %f  %g  %g\n',5.5,5.5,5,d(3),aziT(psrcpos),plungeT(psrcpos),d(2),aziB(psrcpos),plungeB(psrcpos),d(1),aziP(psrcpos),plungeP(psrcpos), maxexp+7 ,0,0);
              end
          fclose(fid);
end
%% Give a warning is solution is of low quality e.g. VR<0.4, CN>10, number of used stations <=2
nostationsused=length(stationsused(:,1));
CN=inv1_eigen(2)/inv1_eigen(1);

disp('  ')
disp(['Used stations ' num2str(nostationsused)])

if varred(psrcpos) < 0.4 || CN > 10  || nostationsused <=2
    warndlg('This is a low quality solution. (VR<0.4 or CN>10 or No. of Stations <=2) ','Warning');
else
end


%%
if ispc     

    %%% prepare a gmt style file for best moment tensor text output
    fid = fopen('btensor.sol','w');
                 fprintf(fid,'%s\r\n','> 10 39 20 0 9 LM 10p 10c j');
                 fprintf(fid,'%s\r\n','MOMENT TENSOR SOLUTION');
                 fprintf(fid,'%s\r\n','> 10 38 16 0 9 LM 10p 10c l');
                 fprintf(fid,'%s\r\n','----------------------------');

                 fprintf(fid,'%s\r\n','> 12 37 16 0 9 LM 10p 10c j');
                 fprintf(fid,'%s\r\n',['HYPOCENTER LOCATION (' eventagency ')' ]);
                 fprintf(fid,'%s\r\n','> 12 36 16 0 9 LM 10p 10c l');
                 fprintf(fid,'%s\r\n','--------------------------');

                 
                 fprintf(fid,'%s\r\n','> 2 35 12 0 9 LM 10p 20c l');
                 fprintf(fid,'%s\r\n',['Origin time ' eventid ]);
                 fprintf(fid,'%s\r\n','> 2 34 12 0 9 LM 10p 20c l');
                 fprintf(fid,'%s\r\n',[  eventid2 ]);
                 fprintf(fid,'%s\r\n','');
                 fprintf(fid,'%s\r\n','> 18 33 16 0 9 LM 10p 10c j');
                 
                 
                 if length(srcpos) ~= 1
                   fprintf(fid,'%s\r\n',['@;0/0/0;CENTROID OF SUBEVENT ' num2str(psrcpos,'%02d')]);
                   fprintf(fid,'%s\r\n','> 18 32 16 0 9 LM 10p 10c l');
                   fprintf(fid,'%s\r\n','-----------------------');
                   
                 else
                   fprintf(fid,'%s\r\n','@;0/0/0;CENTROID');
                   fprintf(fid,'%s\r\n','> 18 32 16 0 9 LM 10p 10c l');
                   fprintf(fid,'%s\r\n','--------');
                 end
                 
                 

                 fprintf(fid,'%s\r\n','> 1 31 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['Trial source number      : ' num2str(srcpos(psrcpos)) '\040(' invtype(3:length(invtype)) ' inversion)' ]);
                 fprintf(fid,'%s\r\n','> 1 30 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['Centroid Lat (N)' num2str(srclat(psrcpos,1)) ' Lon (E)' num2str(srclon(psrcpos,1))]);
                 fprintf(fid,'%s\r\n','> 1 29 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['Centroid Depth  (km)      : ' num2str(depth(srcpos(psrcpos)))]);
                 
                 if srctime2(psrcpos) < 0
                 fprintf(fid,'%s\r\n','> 1 28 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['Centroid time        : ' num2str(srctime2(psrcpos)) ' (sec) relative to origin time' ]);
                 else
                 fprintf(fid,'%s\r\n','> 1 28 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['Centroid time        :  +' num2str(srctime2(psrcpos)) ' (sec) relative to origin time' ]);
                 end             
                 
                 fprintf(fid,'%s\r\n','> 1 27 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n','----------------------------------------------------');
                 fprintf(fid,'%s\r\n','> 1 26 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['  @;255/0/0;Moment (Nm)      :@;; ' num2str(mo(psrcpos),'%6.3e') ]);
                 fprintf(fid,'%s\r\n','> 45 26 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['  @;255/0/0;Mw      :@;; ' num2str(mommag,'%4.2f') ]);
                 
                 fprintf(fid,'%s\r\n','> 1 25 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['@;255/0/0;Inversion Type:@;;' inver_type]);
                 
                                 
                 fprintf(fid,'%s\r\n','> 1 24 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['@;255/0/0;VOL%      :@;;' num2str(inv1_vol)]);
                 
                 fprintf(fid,'%s\r\n','> 1 23 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['@;255/0/0;DC%      :@;;' num2str(inv1_dc)]);
                 fprintf(fid,'%s\r\n','> 1 22 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['@;255/0/0;CLVD%     :@;;'  num2str(inv1_clvd) ]);
                 fprintf(fid,'%s\r\n','> 63 22 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['@;255/0/0;SNR\040\040\040CN\040\040\040FMVAR\040\040STVAR@;;']);
%                 snr=97;
%                  fmvar1=10;
%                  fmvar2=7;
%                  stvar=0.11;
            
%                  if num2str(varred(psrcpos),4) ~= num2str(overallvarredvalue,4)
                 fprintf(fid,'%s\r\n','> 1 21 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['@;255/0/0;Var.red.:@;;(for stations used in inversion):' num2str(varred(psrcpos),2) '\040\040\040' num2str(fix(snr),'%u') '\040\040' num2str(inv1_eigen(2)/inv1_eigen(1),'%6.1f') '\040\040\040'  num2str(round(fmvar1))  '\261' num2str(round(fmvar2)) '\040\040\040\040' num2str(stvar,'%5.2f') ]);% ' % ' num2str(varred(psrcpos)*100,4)  ]  );
                 fprintf(fid,'%s\r\n','> 1 20 13 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['Var.red.(for all stations)\040\040\040\040\040\040\040\040\040\040\040:' num2str(overallvarredvalue,2)  ] );%' % ' num2str(overallvarredvalue*100,4) '@;;'  ]  );
%                  else
%                  fprintf(fid,'%s\r\n','> 1 24 12 0 9 LM 10p 20c j');
%                  fprintf(fid,'%s\r\n',['Variance red.                    :' num2str(varred(psrcpos)) ' % ' num2str(varred(psrcpos)*100)  ]  );
%                  end                 
                 
                 fprintf(fid,'%s\r\n','> 1 19 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n','----------------------------------------------------');

                 fprintf(fid,'%s\r\n','> 1 18 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['@;255/0/0;Strike\040\040\040Dip\040\040\040Rake@;;']);
                 fprintf(fid,'%s\r\n','> 1 17 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n', ['\040\040' num2str(str1(psrcpos)) '\040\040\040\040\040' num2str(dip1(psrcpos)) '\040\040\040\040' num2str(rake1(psrcpos))]);
                 fprintf(fid,'%s\r\n','> 1 16 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',['  @;255/0/0;Strike\040\040\040Dip\040\040\040Rake@;; ']);
                 fprintf(fid,'%s\r\n','> 1 15 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n', ['\040\040' num2str(str2(psrcpos)) '\040\040\040\040\040' num2str(dip2(psrcpos)) '\040\040\040\040' num2str(rake2(psrcpos))]);

                 fprintf(fid,'%s\r\n','> 1 14 12 0 9 LM 10p 10c j');
                 fprintf(fid,'%s\r\n','----------------------');
                 fprintf(fid,'%s\r\n','> 1 13 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n','  @;255/0/0;P-axis   Azimuth   Plunge@;; ');
                 
                 fprintf(fid,'%s\r\n','> 1 12 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',[ '\040\040\040\040\040\040\040\040\040\040\040' num2str(aziP(psrcpos)) '\040\040\040\040' num2str(plungeP(psrcpos))]);
                 
                 fprintf(fid,'%s\r\n','> 1 11 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n','  @;255/0/0;T-axis   Azimuth   Plunge@;; ');
                 
                 fprintf(fid,'%s\r\n','> 1 10 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n',[ '\040\040\040\040\040\040\040\040\040\040\040' num2str(aziT(psrcpos)) '\040\040\040\040' num2str(plungeT(psrcpos))]);

                 fprintf(fid,'%s\r\n','> 1 09 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\r\n','----------------------');
                 
                 fprintf(fid,'%s\r\n','> 1 08 12 0 9 LM 10p 20c j');                 
                 fprintf(fid,'%s\r\n',['  @;255/0/0;\040\040Mrr\040\040  Mtt\040\040  Mpp@;;']);

                 fprintf(fid,'%s\r\n','> 1 07 12 0 9 LM 10p 20c j');  
                 fprintf(fid,'%6.3f  %6.3f  %6.3f\r\n',harcof(1), harcof(2), harcof(3));
                 
                 fprintf(fid,'%s\r\n','> 1 06 12 0 9 LM 10p 20c j');                 
                 fprintf(fid,'%s\r\n',['@;255/0/0;\040\040Mrt\040\040 Mrp\040\040     Mtp@;;']);
                 
                 fprintf(fid,'%s\r\n','> 1 05 12 0 9 LM 10p 20c j');  
                 fprintf(fid,'%6.3f          %6.3f  %6.3f\r\n', harcof(4), harcof(5), harcof(6));
                 
                 fprintf(fid,'%s\r\n','> 1 04 12 0 9 LM 10p 20c j');                 
                 fprintf(fid,'%s\r\n',['Exponent (Nm):\040\040'   num2str(maxexp) ]);
                 

                 %%%%break up invband string..!!
                 iband = sscanf(invband,'%f %*s %f');
%                 fprintf(fid,'%s\r\n','Freq band (Hz)');    
                 fprintf(fid,'%s\r\n','> 31  18 12 0 9 LM 10p 25c l');
                 fprintf(fid,'%s\r\n','| Frequency band used in inversion (Hz)');
                 fprintf(fid,'%s\r\n','> 31  17 12 0 9 LM 10p 25c l');
                 fprintf(fid,'%s\r\n',['|\040\040\040\040\040\040'   num2str(iband(1))  ' - '      num2str(iband(2)) ]);    
                 
%                  fprintf(fid,'%s\r\n','> 31  16 12 0 9 LM 10p 25c l');
%                  fprintf(fid,'%s\r\n','| \040');
                 fprintf(fid,'%s\r\n','> 31  16 12 0 9 LM 10p 25c l');
                 fprintf(fid,'%s\r\n','| \040Stations-Components Used-Distance');
                 fprintf(fid,'%s\r\n','> 31  15 12 0 9 LM 10p 25c l');
                 fprintf(fid,'%s\r\n','|\040\040\040\040\040\040NS\040EW\040Z\040\040D(km)');

%%% if we have more than 13 stations 
if nostations > 13
%%   
   for i=1:13
%      fprintf(fid,'%s\r\n',['> 31 ' num2str(15-i) ' 12 0 9 LM 10p 25c l']);
%      if length(stationsused{i,1})==3
%      fprintf(fid,'%s\r\n',['|\040\040\040'   stationsused{i,1} '\040\040\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
%      elseif length(stationsused{i,1})==4
%      fprintf(fid,'%s\r\n',['|\040\040\040'   stationsused{i,1} '\040\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
%      elseif length(stationsused{i,1})==5
%      fprintf(fid,'%s\r\n',['|\040\040\040'   stationsused{i,1} '\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
%      else
%      fprintf(fid,'%s\r\n',['|\040\040\040'   stationsused{i,1} '\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
%      end
       fprintf(fid,'%s\r\n',['> 31 ' num2str(15-i) ' 12 0 9 LM 10p 25c l']);
     if length(stationsused{i,1})==3
       fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040\040\040'    stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     elseif length(stationsused{i,1})==4
       fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040\040'        stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     elseif length(stationsused{i,1})==5
       fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040'            stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     else
       fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040'            stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     end  
   end
   
% > 13 stations     
     fprintf(fid,'%s\r\n','> 57  15 12 0 9 LM 10p 25c l');
     fprintf(fid,'%s\r\n','\040\040\040\040\040\040\040NS\040EW\040Z\040\040D(km)');
   for i=14:nostations
%      fprintf(fid,'%s\r\n',['> 57 ' num2str(27-i) ' 12 0 9 LM 10p 25c l']);
%      fprintf(fid,'%s\r\n',['\040\040\040'   stationsused{i,1} '\040\040\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
       fprintf(fid,'%s\r\n',['> 57 ' num2str(28-i) ' 12 0 9 LM 10p 25c l']);
     if length(stationsused{i,1})==3
       fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040\040\040'    stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     elseif length(stationsused{i,1})==4
       fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040\040'        stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     elseif length(stationsused{i,1})==5
       fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040'            stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     else
       fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040'            stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     end  
   end
%%
else

   for i=1:nostations
     fprintf(fid,'%s\r\n',['> 31 ' num2str(15-i) ' 12 0 9 LM 10p 25c l']);
     if length(stationsused{i,1})==3
     fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040\040\040'    stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     elseif length(stationsused{i,1})==4
     fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040\040'        stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     elseif length(stationsused{i,1})==5
     fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040'            stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     else
     fprintf(fid,'%s\r\n',['|' stationsused{i,1} '\040'            stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     end  
   end
    
end


else % linux
    
             %%% prepare a gmt style file for best moment tensor text output
    fid = fopen('btensor.sol','w');
                 fprintf(fid,'%s\n','> 10 39 20 0 9 LM 10p 10c j');
                 fprintf(fid,'%s\n','MOMENT TENSOR SOLUTION');
                 fprintf(fid,'%s\n','> 10 38 16 0 9 LM 10p 10c l');
                 fprintf(fid,'%s\n','----------------------------');

                 fprintf(fid,'%s\n','> 12 37 16 0 9 LM 10p 10c j');
                 fprintf(fid,'%s\n',['HYPOCENTER LOCATION (' eventagency ')' ]);
                 fprintf(fid,'%s\n','> 12 36 16 0 9 LM 10p 10c l');
                 fprintf(fid,'%s\n','--------------------------');

                 
                 fprintf(fid,'%s\n','> 2 35 12 0 9 LM 10p 20c l');
                 fprintf(fid,'%s\n',['Origin time ' eventid ]);
                 fprintf(fid,'%s\n','> 2 34 12 0 9 LM 10p 20c l');
                 fprintf(fid,'%s\n',[  eventid2 ]);
                 fprintf(fid,'%s\n','');
                 fprintf(fid,'%s\n','> 18 33 16 0 9 LM 10p 10c j');
                 
                 if length(srcpos) ~= 1
                   fprintf(fid,'%s\n',['@;0/0/0;CENTROID OF SUBEVENT ' num2str(psrcpos,'%02d')]);
                   fprintf(fid,'%s\n','> 18 32 16 0 9 LM 10p 10c l');
                   fprintf(fid,'%s\n','-----------------------');
                   
                 else
                   fprintf(fid,'%s\n','@;0/0/0;CENTROID');
                    fprintf(fid,'%s\n','> 18 32 16 0 9 LM 10p 10c l');
                   fprintf(fid,'%s\n','--------');
                 end
                 
                 fprintf(fid,'%s\n','> 18 32 16 0 9 LM 10p 10c l');
                 fprintf(fid,'%s\n','--------@;; ');
                 fprintf(fid,'%s\n','> 1 31 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['@;0/0/0;Trial source number      : ' num2str(srcpos(psrcpos)) '\040(' invtype(3:length(invtype)) ' inversion)' ]);
                 fprintf(fid,'%s\n','> 1 30 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['Centroid Lat (N)' num2str(srclat(psrcpos,1)) ' Lon (E)' num2str(srclon(psrcpos,1))]);
                 fprintf(fid,'%s\n','> 1 29 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['Centroid Depth  (km)      : ' num2str(depth(srcpos(psrcpos)))]);
                 
                 if srctime2(psrcpos) < 0
                 fprintf(fid,'%s\n','> 1 28 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['Centroid time        : ' num2str(srctime2(psrcpos)) ' (sec) relative to origin time' ]);
                 else
                 fprintf(fid,'%s\n','> 1 28 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['Centroid time        :  +' num2str(srctime2(psrcpos)) ' (sec) relative to origin time' ]);
                 end             
                 
                 fprintf(fid,'%s\n','> 1 27 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n','----------------------------------------------------');
                 fprintf(fid,'%s\n','> 1 26 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['  @;255/0/0;Moment (Nm)      :@;; ' num2str(mo(psrcpos),'%6.3e') ]);
                 fprintf(fid,'%s\n','> 1 25 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['  @;255/0/0;Mw      :@;; ' num2str(mommag,2) ]);
                 
                 fprintf(fid,'%s\n','> 1 24 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['@;255/0/0;VOL%      :@;;' num2str(inv1_vol)]);
                 
                 fprintf(fid,'%s\n','> 1 23 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['@;255/0/0;DC%      :@;;' num2str(inv1_dc)]);
                 fprintf(fid,'%s\n','> 1 22 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['@;255/0/0;CLVD%     :@;;'  num2str(inv1_clvd) ]);

%                  if num2str(varred(psrcpos),4) ~= num2str(overallvarredvalue,4)
                    
                 fprintf(fid,'%s\n','> 1 21 12 0 9 LM 10p 20c j');
%                 fprintf(fid,'%s\n',['Var.red.(for stations used in inversion):' num2str(varred(psrcpos),2) '\040\040\040\040\040   Condition Number : ' num2str(inv1_eigen(2)/inv1_eigen(1),3)  ]);% ' % ' num2str(varred(psrcpos)*100,4)  ]  );
                 fprintf(fid,'%s\n',['@;255/0/0;Var.red.:@;;(for stations used in inversion):' num2str(varred(psrcpos),2) '\040\040\040' num2str(fix(snr),'%u') '\040\040' num2str(inv1_eigen(2)/inv1_eigen(1),'%6.1f') '\040\040\040'  num2str(round(fmvar1))  '\261' num2str(round(fmvar2)) '\040\040\040\040' num2str(stvar,'%5.2f') ]);% ' % ' num2str(varred(psrcpos)*100,4)  ]  );
                 fprintf(fid,'%s\n','> 1 20 13 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['Var.red.(for all stations)\040\040\040\040\040\040\040\040\040\040\040:' num2str(overallvarredvalue,2)  ] );%' % ' num2str(overallvarredvalue*100,4) '@;;'  ]  );
%                  else
%                  fprintf(fid,'%s\n','> 1 24 12 0 9 LM 10p 20c j');
%                  fprintf(fid,'%s\n',['Variance red.                    :' num2str(varred(psrcpos)) ' % ' num2str(varred(psrcpos)*100)  ]  );
%                  end                 
                 
                 fprintf(fid,'%s\n','> 1 19 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n','----------------------------------------------------');

                 fprintf(fid,'%s\n','> 1 18 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['@;255/0/0;Strike\040\040\040Dip\040\040\040Rake@;;']);
                 fprintf(fid,'%s\n','> 1 17 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n', ['\040\040' num2str(str1(psrcpos)) '\040\040\040\040\040' num2str(dip1(psrcpos)) '\040\040\040\040' num2str(rake1(psrcpos))]);
                 fprintf(fid,'%s\n','> 1 16 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',['  @;255/0/0;Strike\040\040\040Dip\040\040\040Rake@;; ']);
                 fprintf(fid,'%s\n','> 1 15 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n', ['\040\040' num2str(str2(psrcpos)) '\040\040\040\040\040' num2str(dip2(psrcpos)) '\040\040\040\040' num2str(rake2(psrcpos))]);

                 fprintf(fid,'%s\n','> 1 14 12 0 9 LM 10p 10c j');
                 fprintf(fid,'%s\n','----------------------');
                 fprintf(fid,'%s\n','> 1 13 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n','  @;255/0/0;P-axis   Azimuth   Plunge@;; ');
                 
                 fprintf(fid,'%s\n','> 1 12 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',[ '\040\040\040\040\040\040\040\040\040\040\040' num2str(aziP(psrcpos)) '\040\040\040\040' num2str(plungeP(psrcpos))]);
                 
                 fprintf(fid,'%s\n','> 1 11 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n','  @;255/0/0;T-axis   Azimuth   Plunge@;; ');
                 
                 fprintf(fid,'%s\n','> 1 10 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n',[ '\040\040\040\040\040\040\040\040\040\040\040' num2str(aziT(psrcpos)) '\040\040\040\040' num2str(plungeT(psrcpos))]);

                 fprintf(fid,'%s\n','> 1 09 12 0 9 LM 10p 20c j');
                 fprintf(fid,'%s\n','----------------------');
                 
                 fprintf(fid,'%s\n','> 1 08 12 0 9 LM 10p 20c j');                 
                 fprintf(fid,'%s\n',['  @;255/0/0;\040\040Mrr\040\040  Mtt\040\040  Mpp@;;']);

                 fprintf(fid,'%s\n','> 1 07 12 0 9 LM 10p 20c j');  
                 fprintf(fid,'%6.3f  %6.3f  %6.3f\n',harcof(1), harcof(2), harcof(3));
                 
                 fprintf(fid,'%s\n','> 1 06 12 0 9 LM 10p 20c j');                 
                 fprintf(fid,'%s\n',['@;255/0/0;\040\040Mrt\040\040 Mrp\040\040     Mtp@;;']);
                 
                 fprintf(fid,'%s\n','> 1 05 12 0 9 LM 10p 20c j');  
                 fprintf(fid,'%6.3f          %6.3f  %6.3f\n', harcof(4), harcof(5), harcof(6));
                 
                 fprintf(fid,'%s\n','> 1 04 12 0 9 LM 10p 20c j');                 
                 fprintf(fid,'%s\n',['Exponent (Nm):\040\040'   num2str(maxexp) ]);
                 

                 %%%%break up invband string..!!
                 iband = sscanf(invband,'%f %*s %f');
%                 fprintf(fid,'%s\n','Freq band (Hz)');    
                 fprintf(fid,'%s\n','> 31  18 12 0 9 LM 10p 25c l');
                 fprintf(fid,'%s\n','| Frequency band used in inversion (Hz)');
                 fprintf(fid,'%s\n','> 31  17 12 0 9 LM 10p 25c l');
                 fprintf(fid,'%s\r\n',['|\040\040\040\040\040\040'   num2str(iband(1))  ' - '      num2str(iband(2)) ]);   
                 
                 fprintf(fid,'%s\n','> 31  16 12 0 9 LM 10p 25c l');
                 fprintf(fid,'%s\n','| \040');
                 fprintf(fid,'%s\n','> 31  15 12 0 9 LM 10p 25c l');
                 fprintf(fid,'%s\n','| \040Stations-Components Used-Distance');
                 fprintf(fid,'%s\n','> 31  14 12 0 9 LM 10p 25c l');
                 fprintf(fid,'%s\n','|\040\040\040\040\040\040NS\040EW\040Z\040\040D(km)');

                 
                 
                 
%%% if we have more than 13 stations 
if nostations > 13
%%   
   for i=1:13
     fprintf(fid,'%s\n',['> 31 ' num2str(14-i) ' 12 0 9 LM 10p 25c l']);
     if length(stationsused{i,1})==3
     fprintf(fid,'%s\n',['|\040\040\040'   stationsused{i,1} '\040\040\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
     elseif length(stationsused{i,1})==4
     fprintf(fid,'%s\n',['|\040\040\040'   stationsused{i,1} '\040\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
     elseif length(stationsused{i,1})==5
     fprintf(fid,'%s\n',['|\040\040\040'   stationsused{i,1} '\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
     else
     fprintf(fid,'%s\n',['|\040\040\040'   stationsused{i,1} '\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
     end
   end
   
% > 13 stations     
     fprintf(fid,'%s\n','> 57  14 12 0 9 LM 10p 25c l');
     fprintf(fid,'%s\n','\040\040Station\040\040NS\040\040EW\040\040Ver');
   for i=14:nostations
     fprintf(fid,'%s\n',['> 57 ' num2str(27-i) ' 12 0 9 LM 10p 25c l']);
     fprintf(fid,'%s\n',['\040\040\040'   stationsused{i,1} '\040\040\040\040\040'  stationsused{i,2} '\040\040\040'  stationsused{i,3} '\040\040\040'  stationsused{i,4} ]);
   end
%%
else

   for i=1:nostations
     fprintf(fid,'%s\n',['> 31 ' num2str(14-i) ' 12 0 9 LM 10p 25c l']);
     if length(stationsused{i,1})==3
     fprintf(fid,'%s\n',['|' stationsused{i,1} '\040\040\040'    stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     elseif length(stationsused{i,1})==4
     fprintf(fid,'%s\n',['|' stationsused{i,1} '\040\040'        stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     elseif length(stationsused{i,1})==5
     fprintf(fid,'%s\n',['|' stationsused{i,1} '\040'            stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     else
     fprintf(fid,'%s\n',['|' stationsused{i,1} '\040'            stationsused{i,2} '\040\040'  stationsused{i,3} '\040\040'  stationsused{i,4} '\040\040' num2str(round(epidist(i)))]);
     end  
   end
    
end


end  % end of linux

%num2str(round(epidist(i)))
fclose(fid);
%%
%  write a one line file GMT ready with results in output and gmtfiles folder ...

disp(['Found ' num2str(length(srcpos)) ' subevents. Will be saved in gmtfiles folder as gmt format file'])

fid = fopen([eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec],'w');
%      fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g %s\r\n',srclon(psrcpos,1),srclat(psrcpos,1),5,str1(psrcpos,1),dip1(psrcpos,1),rake1(psrcpos,1),5,srclon(psrcpos,1)+0.05,srclat(psrcpos,1)+0.05,[num2str(srctime2(psrcpos,1)) '  ' num2str(mo(psrcpos,1),'%5.2e')]);  %num2str(mo(i,1))num2str(dc(psrcpos,1))
% we will plot only the selected subevent 
% srcpos(psrcpos)
  if ispc
     %for i=1:length(srcpos)         
         i=psrcpos;
         mommag1=(2/3)*(log10(mo(i)) - 9.1); %! Hanks & Kanamori (1979)
         fprintf(fid,'%g  %g  %s  %g  %g  %g  %s  %g  %g %s\r\n',srclon(i,1),srclat(i,1),num2str(depth(srcpos(i))),str1(i,1),dip1(i,1),rake1(i,1),num2str(mommag1),srclon(i,1)+0.05,srclat(i,1)+0.05, [eventdate(3:8) '_' eventhour ':' eventmin]);   % [num2str(srctime2(psrcpos,1)) '  ' num2str(mo(psrcpos,1),'%5.2e')]);  %num2str(mo(i,1))num2str(dc(psrcpos,1))
     %end
  else
         fprintf(fid,'%g  %g  %s  %g  %g  %g  %s  %g  %g %s\n',srclon(psrcpos,1),srclat(psrcpos,1), num2str(depth(srcpos(psrcpos))) ,str1(psrcpos,1),dip1(psrcpos,1),rake1(psrcpos,1),num2str(mommag,3),srclon(psrcpos,1)+0.05,srclat(psrcpos,1)+0.05, [eventdate(3:8) '_' eventhour ':' eventmin]);   % [num2str(srctime2(psrcpos,1)) '  ' num2str(mo(psrcpos,1),'%5.2e')]);  %num2str(mo(i,1))num2str(dc(psrcpos,1))
  end
            
fclose(fid);

%%
if ispc
 [s,mess,messid]=copyfile([eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec],'..\output');
 [s,mess,messid]=copyfile([eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec],'..\gmtfiles');
else
 [s,mess,messid]=copyfile([eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec],'../output');
 [s,mess,messid]=copyfile([eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec],'../gmtfiles');
end
%%
%%%%%%%%%%%%%Check if map is needed
plmap = get(handles.check2,'Value');
useBB = get(handles.useBB,'Value');
bbscale  = get(handles.bbscale,'String');

% check if we have GMT 4 or 5
gmt_ver=handles.gmt_ver;

if plmap == 1

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% old code

% %%%find map limits...
% border=0.1;
% 
% % wend=min(lon)
% % eend=max(lon)
% % send=min(lat)
% % nend=max(lat)
% % w=(wend-border)
% % e=(eend+border)
% % s=(send-border)
% % n=(nend+border)
% 
%  w=(srclon-border);
%  e=(srclon+border);
%  s=(srclat-border);
%  n=(srclat+border);
%  
% 
% %%%make -R
% %num2str(centx,'%7.2f')
% r=['-R' num2str(w(1,1),'%7.5f') '/' num2str(e(1,1),'%7.5f') '/' num2str(s(1,1),'%7.5f') '/' num2str(n(1,1),'%7.5f') ' '];
% 
% %%%make -J
% 
% j=[' -JM7c'];
% 
% % centy=((nend-send)/2)+send;
% % centx=((eend-wend)/2)+wend;
% % ly=(((nend-send)/2)+send)-(border-scaleshift);
% % 
% %%%make -L
% % lf=['-Lf' num2str(centx,'%7.2f') '/' num2str(ly,'%7.2f') '/' num2str(centy,'%7.2f') '/' lscale ];
% 
% % plots the map
% 
% fid = fopen('besttext.gmt','w');
%       fprintf(fid,'%g  %g  %g  %g  %g  %s %g\r\n',srclon(psrcpos,1)-0.01,srclat(psrcpos,1),12,0,1,'CM',srcpos(psrcpos));
% fclose(fid);
% 
%     mecstringmax3=['pscoast ' r   j ' -G255/255/204 -Df -W0.7p -P -B0.1::WeSn -K -O -S104/204/255 -X-8c  -Y1c  >> ' eventidnew '_best.ps' ];
%     mecstringmax4=['pstext -R '   j '  besttext.gmt  -O -K  >> ' eventidnew '_best.ps' ];
%     mecstringmax5=['psmeca -R '   j ' -Sa1.3c ' [eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec ] ' -V -O -C1/0/0/0/0.5p/P0.15c -N  >> ' eventidnew '_best.ps'];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
    pwd
    
 cd ..  % makegmtscript4stationplot has to be in run folder...
    if ispc 
       
      mecstringmax3='gawk "{print $3,$2,$1}" ..\gmtfiles\selstat.gmt > sta.gmt';
       
       if gmt_ver==4
         mecstringmax4='gawk "{print $3,$2,10,0,1,\"CB\",$1}" ..\gmtfiles\selstat.gmt > tsta.gmt'; 
       else
         mecstringmax4='gawk "{print $3,$2,$1}" ..\gmtfiles\selstat.gmt > tsta.gmt'; 
       end
    else
       mecstringmax3='gawk ''{print $3,$2,$1}'' ../gmtfiles/selstat.gmt > sta.gmt';
       if gmt_ver==4
         mecstringmax4='gawk ''{print $3,$2,10,0,1,"CB",$1}'' ../gmtfiles/selstat.gmt > tsta.gmt'; 
       else
         mecstringmax4='gawk ''{print $3,$2,$1}'' ../gmtfiles/selstat.gmt > tsta.gmt'; 
       end
    end
    
    mecstringmax5=[makegmtscript4stationplot(0) ' -X-10.2c  -Y1c >> ' eventidnew '_best.ps'];
    
    %
    if ispc
        if gmt_ver==4
           mecstringmax6=['psxy -R -J ..\gmtfiles\event.gmt -Sa.6c -M  -W1p/0 -K -O -G255/0/0 >> ' eventidnew '_best.ps'];
        else
           mecstringmax6=['psxy -R -J ..\gmtfiles\event.gmt -Sa.6c     -W1p -K -O -G255/0/0 >> ' eventidnew '_best.ps'];
        end
    else
        if gmt_ver==4
           mecstringmax6=['psxy -R -J ../gmtfiles/event.gmt -Sa.6c -M  -W1p/0 -K -O -G255/0/0 >> ' eventidnew '_best.ps'];
        else
           mecstringmax6=['psxy -R -J ../gmtfiles/event.gmt -Sa.6c     -W1p   -K -O -G255/0/0 >> ' eventidnew '_best.ps'];
        end
    end
   
    
    mecstringmax7=['psmeca -R -J -K ' eventidnew ' -Sa1.c/-1  -O  >> ' eventidnew '_best.ps'];
    
    if gmt_ver==4
        mecstringmax8=['psxy -R -J  sta.gmt -St.25c -M  -W1p/0 -K -O -Ggreen >>  ' eventidnew '_best.ps'];
    else
        mecstringmax8=['psxy -R -J  sta.gmt -St.25c     -W1p   -K -O -Ggreen >>  ' eventidnew '_best.ps'];
    end

    
    if ispc
       if gmt_ver==4
        mecstringmax8b=['psxy -R -J ..\gmtfiles\notusedstat.gmt -St.25c  -W1p/0 -K  -O -Gred >> ' eventidnew '_best.ps'];
       else
        mecstringmax8b=['psxy -R -J ..\gmtfiles\notusedstat.gmt -St.25c  -W1p   -K  -O -Gred >> ' eventidnew '_best.ps'];
       end
    else
       if gmt_ver==4
        mecstringmax8b=['psxy -R -J ../gmtfiles/notusedstat.gmt -St.25c  -W1p/0 -K  -O -Gred >> ' eventidnew '_best.ps'];
       else
        mecstringmax8b=['psxy -R -J ../gmtfiles/notusedstat.gmt -St.25c  -W1p   -K  -O -Gred >> ' eventidnew '_best.ps'];
       end
    end   
    
    if gmt_ver==4
       mecstringmax9=['pstext -R -J  tsta.gmt  -D0/0.1c       -O  -G0/0/255 >> ' eventidnew '_best.ps'];
    else
       mecstringmax9=['pstext -R -J  tsta.gmt  -D0/0.2c  -F+f10,Helvetica-Bold,blue    -O   >> ' eventidnew '_best.ps'];
    end

    
 cd invert  % back to invert to run the batch file ...

else
    
    % no map needed
    
    mecstringmax3='   ';
    mecstringmax4='   ';
    
    mecstringmax5='   ';
    
    mecstringmax6='   ';
    mecstringmax7='   ';
    mecstringmax8='   ';
    mecstringmax8b='   ';
    
    mecstringmax9='   ';

end   %end plmap

    
%% prepare batch file and run it..


  fid = fopen('plbest.bat','w');
  
    if ispc      
      fprintf(fid,'%s\r\n','del .gmt*');
      fprintf(fid,'%s\r\n',' ');
      if gmt_ver==4
        fprintf(fid,'%s\r\n','gmtset PAPER_MEDIA A4 PLOT_DEGREE_FORMAT D');
      else 
        fprintf(fid,'%s\r\n','gmtset PS_MEDIA A4 FORMAT_GEO_MAP D');  
      end
      fprintf(fid,'%s\r\n',' ');
    else
      fprintf(fid,'%s\n','rm .gmt*');
      fprintf(fid,'%s\n',' ');
      if gmt_ver==4
        fprintf(fid,'%s\n','gmtset PAPER_MEDIA A4 PLOT_DEGREE_FORMAT D');
      else
        fprintf(fid,'%s\n','gmtset PS_MEDIA A4 FORMAT_GEO_MAP D');
      end
      fprintf(fid,'%s\n',' ');
    end
      
switch inv2age
  case 'old'
     if useBB~=1
      disp('found inv2.dat in old format')
      if gmt_ver==4
        mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sm2c btensor.foc -G255/0/0 -T0 -L2 -B100 -a0.15c/cc -ewhite -gblack -K -Y12c -X1c > ' eventidnew '_best.ps'];
      elseif gmt_ver==5
        mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sm2c btensor.foc -G255/0/0 -T0 -L2 -B100 -Fa0.15c/cc -Fewhite -Fgblack -K -Y12c -X1c > ' eventidnew '_best.ps'];
      else
         mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sm2c btensor.foc -G255/0/0 -T0 -L2 -B100 -Fa0.15c/cc   -K -Y12c -X1c > ' eventidnew '_best.ps']; 
      end
     else
      disp('found inv2.dat in old format')
      if gmt_ver==3
        mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sm' bbscale 'c btensor.foc -G255/0/0 -T0 -L2 -B100 -a0.15c/cc -ewhite -gblack -K -Y12c -X1c > ' eventidnew '_best.ps'];
      else
        mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sm' bbscale 'c btensor.foc -G255/0/0 -T0 -L2 -B100 -Fa0.15c/cc -Fewhite -Fgblack -K -Y12c -X1c > ' eventidnew '_best.ps'];
      end
     end
  case 'new'
     if useBB~=1 
      disp('found inv2.dat in new format')
      if gmt_ver==4
        mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sx2c btensor.foc -G255/0/0 -T0 -L2 -B100 -a0.15c/cc -ewhite -gblack -K -Y12c -X1c > ' eventidnew '_best.ps'];
      elseif gmt_ver==5
        mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sx2c btensor.foc -G255/0/0 -T0 -L2 -B100 -Fa0.15c/cc -Fewhite -Fgblack -K -Y12c -X1c > ' eventidnew '_best.ps'];
      else
        mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sx2c btensor.foc -G255/0/0 -T0 -L2 -B100 -Fa0.15c/cc   -K -Y12c -X1c > ' eventidnew '_best.ps'];  
      end
     else
      disp('found inv2.dat in new format')
      if gmt_ver==4
       mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sx' bbscale 'c btensor.foc -G255/0/0 -T0 -L2 -B100 -a0.15c/cc -ewhite -gblack -K -Y12c -X1c > ' eventidnew '_best.ps'];
      elseif gmt_ver==5
       mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sx' bbscale 'c btensor.foc -G255/0/0 -T0 -L2 -B100 -Fa0.15c/cc -Fewhite -Fgblack -K -Y12c -X1c > ' eventidnew '_best.ps'];
      else
       mecstringmax=['psmeca -R1/10/1/10 -JX8c -Sx' bbscale 'c btensor.foc -G255/0/0 -T0 -L2 -B100 -Fa0.15c/cc  -K -Y12c -X1c > ' eventidnew '_best.ps'];   
      end
     
     end
end

     if plmap == 1
       if gmt_ver==4
          mecstringmax2 =['pstext -R1/100/1/40 -JX20c/20c -O -K btensor.sol -m  -X9.7c -Y-11c >> ' eventidnew '_best.ps'];
       else
          mecstringmax2 =['pstext -R1/100/1/40 -JX20c/20c -O -K btensor.sol -M  -X9.7c -Y-11c >> ' eventidnew '_best.ps'];
       end
     else
       if gmt_ver==4  
          mecstringmax2 =['pstext -R1/100/1/40 -JX20c/20c -O    btensor.sol -m  -X9.7c -Y-11c  >> ' eventidnew '_best.ps'];
       else
          mecstringmax2 =['pstext -R1/100/1/40 -JX20c/20c -O    btensor.sol -M  -X9.7c -Y-11c  >> ' eventidnew '_best.ps'];
       end
     end
%    
     
  if ispc
    fprintf(fid,'%s\r\n',mecstringmax);
    fprintf(fid,'%s\r\n',mecstringmax2);
    fprintf(fid,'%s\r\n',' ');
    fprintf(fid,'%s\r\n',mecstringmax3);
    fprintf(fid,'%s\r\n',mecstringmax4);
    fprintf(fid,'%s\r\n',' ');
    if gmt_ver==4 
      fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 8 ANNOT_OFFSET_PRIMARY 0.05c TICK_LENGTH 0.05c OBLIQUE_ANNOTATION 32 ');
    else
      fprintf(fid,'%s\r\n','gmtset FONT_ANNOT_PRIMARY 8 MAP_ANNOT_OFFSET_PRIMARY 0.05c MAP_TICK_LENGTH 0.05c MAP_ANNOT_OBLIQUE 32 ');
    end
    fprintf(fid,'%s\r\n',' ');
    fprintf(fid,'%s\r\n',mecstringmax5);
    fprintf(fid,'%s\r\n',mecstringmax6);
    fprintf(fid,'%s\r\n',mecstringmax7);
    fprintf(fid,'%s\r\n',mecstringmax8);
    fprintf(fid,'%s\r\n',mecstringmax8b);
    fprintf(fid,'%s\r\n',mecstringmax9);
    fprintf(fid,'%s\r\n',' ');
    %%% add option to convert to PNG using ps2raster...26/10/09    
    if gmt_ver==4 
       fprintf(fid,'%s\r\n',['ps2raster ' eventidnew '_best.ps -Tg -P  -D..\output']);
    else
       fprintf(fid,'%s\r\n',['psconvert ' eventidnew '_best.ps -Tg -P  -D..\output']); 
    end
%    fprintf(fid,'%s\r\n',['rename ..\output\best.png ' eventidnew '_best.png']);
    %%% clean a few files 28/3/10
    % move to gmt folder
    fprintf(fid,'%s\r\n','move btensor.foc ..\gmtfiles');
    fprintf(fid,'%s\r\n','move btensor.sol ..\gmtfiles');
    fprintf(fid,'%s\r\n','move besttext.gmt ..\gmtfiles');
    fprintf(fid,'%s\r\n','move sta.gmt ..\gmtfiles');
    fprintf(fid,'%s\r\n','move tsta.gmt ..\gmtfiles');
%    fprintf(fid,'%s\r\n','del btensor.foc btensor.sol besttext.gmt  sta.gmt tsta.gmt');
  else
    fprintf(fid,'%s\n',mecstringmax);
    fprintf(fid,'%s\n',mecstringmax2);
    fprintf(fid,'%s\n',' ');
    fprintf(fid,'%s\n',mecstringmax3);
    fprintf(fid,'%s\n',mecstringmax4);
    fprintf(fid,'%s\n',' ');
    if gmt_ver==4 
      fprintf(fid,'%s\n','gmtset ANNOT_FONT_SIZE_PRIMARY 8 ANNOT_OFFSET_PRIMARY 0.05c TICK_LENGTH 0.05c OBLIQUE_ANNOTATION 32 ');
    else
      fprintf(fid,'%s\n','gmtset FONT_ANNOT_PRIMARY 8 MAP_ANNOT_OFFSET_PRIMARY 0.05c MAP_TICK_LENGTH 0.05c MAP_ANNOT_OBLIQUE 32 ');
    end
    fprintf(fid,'%s\n',' ');
    fprintf(fid,'%s\n',mecstringmax5);
    fprintf(fid,'%s\n',mecstringmax6);
    fprintf(fid,'%s\n',mecstringmax7);
    fprintf(fid,'%s\n',mecstringmax8);
    fprintf(fid,'%s\n',mecstringmax8b);
    fprintf(fid,'%s\n',mecstringmax9);
    fprintf(fid,'%s\n',' ');
    %%% add option to convert to PNG using ps2raster...26/10/09    
    if  gmt_ver==4 
       fprintf(fid,'%s\n',['ps2raster ' eventidnew '_best.ps -Tg -P  -D../output']);
    else
       fprintf(fid,'%s\n',['psconvert ' eventidnew '_best.ps -Tg -P  -D../output']);
    end
%    fprintf(fid,'%s\r\n',['rename ..\output\best.png ' eventidnew '_best.png']);
    %%% clean a few files 28/3/10
    fprintf(fid,'%s\n','rm btensor.foc btensor.sol besttext.gmt  sta.gmt tsta.gmt');
  end
     
     
    
    fclose(fid);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%Check if text output  is needed
maketxt = get(handles.maketxt,'Value');

   
if maketxt == 1
    
%%%%%%%%%%%%%%%%%%%PRODUCE A TEXT FILE WITH THE SOLUTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      fid = fopen('dsr.dat','w');
        if ispc
           fprintf(fid,' %s      %s     %s\r\n',   num2str(dip1(psrcpos)), num2str(str1(psrcpos)) ,num2str(rake1(psrcpos)));
        else
           fprintf(fid,' %s      %s     %s\n',   num2str(dip1(psrcpos)), num2str(str1(psrcpos)) ,num2str(rake1(psrcpos)));
        end
      fclose(fid);
      
      [s,r]=system('dsretc.exe');

%%%%%%%%%%%%%%%%%%%%%%% copy header footer files these should be in isola
%%%%%%%%%%%%%%%%%%%%%%% folder....
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% find isola folder
infold=which('isola.m');
str = strrep(infold,'isola.m','');

%% footer.txt
sf=[str 'footer.txt'];

[s,mess,messid]=copyfile(sf,'.');
if s==0
    disp('footer.txt doesn''t exist in isola folder')
elseif s==1
    disp(['Copied footer.txt from  ' str '  in ' pwd '  folder'])
end

%% header.txt
sf=[str 'header.txt'];

[s,mess,messid]=copyfile(sf,'.');
if s==0
    disp('header.txt doesn''t exist in isola folder')
elseif s==1
    disp(['Copied header.txt from  ' str '  in ' pwd '  folder'])
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%% Prepare output file  
%% check if header.txt exists
% % 
h=dir('header.txt');

if isempty(h)
%%%% NO header file write the solution only

  if ispc  
   fid = fopen('MTsol.txt','w');
    
      fprintf(fid,'%s\r\n','Origin Time:');
      fprintf(fid,'%s',eventdate);
      fprintf(fid,' %s%s',eventhour,':');
      fprintf(fid,'%s%s',eventmin,':');
      fprintf(fid,'%s\r\n',eventsec);
      fprintf(fid,'%s\r\n','Epicenter:   ');
      fprintf(fid,'%s','Lat:  ');
      fprintf(fid,'%g',srclat(psrcpos,1));
      fprintf(fid,'%s','     Lon:  ');
      fprintf(fid,'%g\r\n',srclon(psrcpos,1));    
      fprintf(fid,'%s\r\n',['Depth (km) : ' num2str(epidepth)]);
      fprintf(fid,'%s\r\n',['Mw :  ' num2str(mommag,2) ]);  
      fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s\r\n','Moment Tensor Solution  ');    
      fprintf(fid,'%s  %i    %s','No of Stations:', nstations , '(');
      for i=1:nstations-1
      fprintf(fid,'%s', [stanames{i} '-'] );
      end
      fprintf(fid,'%s', stanames{nstations} );
      fprintf(fid,'%s\r\n', ')' );
      %%%%break up invband string..!!
      iband = sscanf(invband,'%f %*s %f');
      fprintf(fid,'%s\r\n','Freq band (Hz)');    
%      fprintf(fid,'%s%s%s  %s %s%s%s %s %s%s%s\r\n',num2str(iband(2)),'-',num2str(iband(3)),'tapered', num2str(iband(1)),'-',num2str(iband(2)),'and' ,num2str(iband(3)),'-',num2str(iband(4))   );    
      fprintf(fid,'%s %s \r\n',num2str(iband(1)),'-',num2str(iband(2)));
%       fprintf(fid,'%s\r\n',invband);    
      fprintf(fid,'%s\r\n',['Variance Reduction (%): '  num2str(round(varred(psrcpos)*100))  ]  );
      fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s%s %s\r\n','Moment Tensor (Nm) :  Exponent 10**', num2str(maxexp));
      fprintf(fid,'%s\r\n',['  Mrr      Mtt     Mpp']);
      fprintf(fid,'%6.3f  %6.3f  %6.3f\r\n',harcof(1), harcof(2), harcof(3));
      fprintf(fid,'%s\r\n',['  Mrt      Mrp     Mtp']);
      fprintf(fid,'%6.3f  %6.3f  %6.3f\r\n', harcof(4), harcof(5), harcof(6));
      %fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s\r\n',['VOL (%)      : ' num2str(inv1_vol)]);
      fprintf(fid,'%s\r\n',['DC (%)       : ' num2str(inv1_dc)]);
      fprintf(fid,'%s\r\n',['CLVD (%)     : '  num2str(inv1_clvd) ]);
      fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s','Best Double Couple: Mo=');
      fprintf(fid,'%s  %s\r\n',[' ' num2str(mo(psrcpos),'%6.3e') ],'Nm');
      fprintf(fid,'%s\r\n','NP1:   Strike   Dip   Rake');
      fprintf(fid,'        %s      %s     %s\r\n', num2str(str1(psrcpos)),  num2str(dip1(psrcpos)), num2str(rake1(psrcpos)));
      fprintf(fid,'%s\r\n','NP2:   Strike   Dip   Rake');
      fprintf(fid,'        %s      %s     %s\r\n', num2str(str2(psrcpos)),  num2str(dip2(psrcpos)) , num2str(rake2(psrcpos)));

      fid2 = fopen('dsretc.lst','r');
                for i=1:22
                   tline = fgets(fid2);
                   fprintf(fid,'%s', tline); 
                end
      fclose(fid2);

      
    fclose(fid);

  else  % linux
      
    fid = fopen('MTsol.txt','w');
    
      fprintf(fid,'%s\n','Origin Time:');
      fprintf(fid,'%s',eventdate);
      fprintf(fid,' %s%s',eventhour,':');
      fprintf(fid,'%s%s',eventmin,':');
      fprintf(fid,'%s\n',eventsec);
      fprintf(fid,'%s\n','Epicenter:   ');
      fprintf(fid,'%s','Lat:  ');
      fprintf(fid,'%g',srclat(psrcpos,1));
      fprintf(fid,'%s','     Lon:  ');
      fprintf(fid,'%g\n',srclon(psrcpos,1));    
      fprintf(fid,'%s\n',['Depth (km) : ' num2str(epidepth)]);
      fprintf(fid,'%s\n',['Mw :  ' num2str(mommag,2) ]);  
      fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s\n','Moment Tensor Solution  ');    
      fprintf(fid,'%s  %i    %s','No of Stations:', nstations , '(');
      for i=1:nstations-1
      fprintf(fid,'%s', [stanames{i} '-'] );
      end
      fprintf(fid,'%s', stanames{nstations} );
      fprintf(fid,'%s\n', ')' );
      %%%%break up invband string..!!
      iband = sscanf(invband,'%f %*s %f');
      fprintf(fid,'%s\n','Freq band (Hz)');    
      fprintf(fid,'%s%s%s  %s %s%s%s %s %s%s%s\n',num2str(iband(2)),'-',num2str(iband(3)),'tapered', num2str(iband(1)),'-',num2str(iband(2)),'and' ,num2str(iband(3)),'-',num2str(iband(4))   );    
      fprintf(fid,'%s %s \r\n',num2str(iband(1)),'-',num2str(iband(2)));
      %       fprintf(fid,'%s\n',invband);    
      fprintf(fid,'%s\n',['Variance Reduction (%): '  num2str(round(varred(psrcpos)*100))  ]  );
      fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s%s %s\n','Moment Tensor (Nm) :  Exponent 10**', num2str(maxexp));
      fprintf(fid,'%s\n',['  Mrr      Mtt     Mpp']);
      fprintf(fid,'%6.3f  %6.3f  %6.3f\n',harcof(1), harcof(2), harcof(3));
      fprintf(fid,'%s\n',['  Mrt      Mrp     Mtp']);
      fprintf(fid,'%6.3f  %6.3f  %6.3f\n', harcof(4), harcof(5), harcof(6));
      %fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s\n',['VOL (%)      : ' num2str(inv1_vol)]);
      fprintf(fid,'%s\n',['DC (%)       : ' num2str(inv1_dc)]);
      fprintf(fid,'%s\n',['CLVD (%)     : '  num2str(inv1_clvd) ]);
      fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s','Best Double Couple: Mo=');
      fprintf(fid,'%s  %s\n',[' ' num2str(mo(psrcpos),'%6.3e') ],'Nm');
      fprintf(fid,'%s\n','NP1:   Strike   Dip   Rake');
      fprintf(fid,'        %s      %s     %s\n', num2str(str1(psrcpos)),  num2str(dip1(psrcpos)), num2str(rake1(psrcpos)));
      fprintf(fid,'%s\n','NP2:   Strike   Dip   Rake');
      fprintf(fid,'        %s      %s     %s\n', num2str(str2(psrcpos)),  num2str(dip2(psrcpos)) , num2str(rake2(psrcpos)));

      fid2 = fopen('dsretc.lst','r');
                for i=1:22
                   tline = fgets(fid2);
                   fprintf(fid,'%s', tline); 
                end
      fclose(fid2);

      
    fclose(fid);
    
  end % linux
    
    
else

disp('Found header.txt')
%%%%read header.txt
fido  = fopen('header.txt','r');
fid = fopen('MTsol.txt','w');

while 1
    tline = fgets(fido);
    if ~ischar(tline),   break,   end
    %%%% Write Header
          for i=1:length(tline)
             fprintf(fid,'%s',tline(i));
          end
end
fclose(fido);

%%% write the solution to header.txt
  if ispc
    %%%% 
      fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s\r\n',['Hypocenter Solution (' eventagency ')'] );
      fprintf(fid,'%s%s','Origin Time ',':  ');
      fprintf(fid,'%s',eventdate);
      fprintf(fid,' %s%s',eventhour,':');
      fprintf(fid,'%s%s',eventmin,':');
      fprintf(fid,'%s\r\n',eventsec);
%     fprintf(fid,'%s%s%s%s%s\r\n','Epicenter ','(',eventagency,')',':');
      fprintf(fid,'%s','Lat:  ');
      fprintf(fid,'%s',num2str(eventcor(2)));
      fprintf(fid,'%s','     Lon:  ');
      fprintf(fid,'%s\r\n',num2str(eventcor(1)));    
      fprintf(fid,'%s\r\n',['Depth (km) : ' num2str(epidepth)]);
      fprintf(fid,'%s\r\n',['Mw :  ' num2str(mommag,2) ]);  
      fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s\r\n','======================================');
      fprintf(fid,'%s\r\n','Centroid Solution  ');    
                 if srctime2(psrcpos) < 0
                 fprintf(fid,'%s\r\n',['Centroid Time : ' num2str(srctime2(psrcpos)) ' (sec) relative to origin time' ]);
                 else
                 fprintf(fid,'%s\r\n',['Centroid Time :  +' num2str(srctime2(psrcpos)) ' (sec) relative to origin time' ]);
                 end        
                 fprintf(fid,'%s\r\n',['Centroid Lat:  ' num2str(srclat(psrcpos,1)) '       Lon:  ' num2str(srclon(psrcpos,1))]);
                 fprintf(fid,'%s\r\n',['Centroid Depth : ' num2str(depth(srcpos(psrcpos)))]);
      fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s\r\n','======================================');
      fprintf(fid,'%s  %i    %s','No of Stations:', nstations , '(');
      for i=1:nstations-1
      fprintf(fid,'%s', [stanames{i} '-'] );
      end
      fprintf(fid,'%s', stanames{nstations} );
      fprintf(fid,'%s\r\n', ')' );
      %%%%break up invband string..!!
      iband = sscanf(invband,'%f %*s %f');
      fprintf(fid,'%s\r\n','Freq band (Hz)');    
     % fprintf(fid,'%s%s%s  %s %s%s%s %s %s%s%s\r\n',num2str(iband(2)),'-',num2str(iband(3)),'tapered', num2str(iband(1)),'-',num2str(iband(2)),'and' ,num2str(iband(3)),'-',num2str(iband(4))   );    
      fprintf(fid,'%s %s %s\r\n',num2str(iband(1)),'-',num2str(iband(2)));
%     fprintf(fid,'%s\r\n',invband);    
      fprintf(fid,'%s\r\n',['Variance Reduction (%): '  num2str(round(varred(psrcpos)*100))  ]  );
      fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s%s\r\n','Moment Tensor (Nm):  Exponent 10**', num2str(maxexp));
      fprintf(fid,'%s\r\n',['  Mrr      Mtt     Mpp']);
      fprintf(fid,'%6.3f  %6.3f  %6.3f\r\n',harcof(1), harcof(2), harcof(3));
      fprintf(fid,'%s\r\n',['  Mrt      Mrp     Mtp']);
      fprintf(fid,'%6.3f  %6.3f  %6.3f\r\n', harcof(4), harcof(5), harcof(6));
      %fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s\r\n',['VOL (%)      : ' num2str(inv1_vol)]);
      fprintf(fid,'%s\r\n',['DC (%)       : ' num2str(inv1_dc)]);
      fprintf(fid,'%s\r\n',['CLVD (%)     : '  num2str(inv1_clvd) ]);
      fprintf(fid,'%s\r\n','  ');    
      fprintf(fid,'%s','Best Double Couple: Mo=');
      fprintf(fid,'%s  %s\r\n',[' ' num2str(mo(psrcpos),'%6.3e') ],'Nm');
      fprintf(fid,'%s\r\n','NP1:   Strike   Dip   Rake');
      fprintf(fid,'        %s      %s     %s\r\n', num2str(str1(psrcpos)),  num2str(dip1(psrcpos)), num2str(rake1(psrcpos)));
      fprintf(fid,'%s\r\n','NP2:   Strike   Dip   Rake');
      fprintf(fid,'        %s      %s     %s\r\n', num2str(str2(psrcpos)),  num2str(dip2(psrcpos)) , num2str(rake2(psrcpos)));
      fid2 = fopen('dsretc.lst','r');
                      for i=1:22
                        tline = fgets(fid2);
                        fprintf(fid,'%s', tline); 
                     end
      fclose(fid2);
    fclose(fid);

  else  % linux
      
      fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s\n',['Hypocenter Solution (' eventagency ')'] );
      fprintf(fid,'%s%s','Origin Time ',':  ');
      fprintf(fid,'%s',eventdate);
      fprintf(fid,' %s%s',eventhour,':');
      fprintf(fid,'%s%s',eventmin,':');
      fprintf(fid,'%s\n',eventsec);
%     fprintf(fid,'%s%s%s%s%s\n','Epicenter ','(',eventagency,')',':');
      fprintf(fid,'%s','Lat:  ');
      fprintf(fid,'%s',num2str(eventcor(2)));
      fprintf(fid,'%s','     Lon:  ');
      fprintf(fid,'%s\n',num2str(eventcor(1)));    
      fprintf(fid,'%s\n',['Depth (km) : ' num2str(epidepth)]);
      fprintf(fid,'%s\n',['Mw :  ' num2str(mommag,2) ]);  
      fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s\n','======================================');
      fprintf(fid,'%s\n','Centroid Solution  ');    
                 if srctime2(psrcpos) < 0
                 fprintf(fid,'%s\n',['Centroid Time : ' num2str(srctime2(psrcpos)) ' (sec) relative to origin time' ]);
                 else
                 fprintf(fid,'%s\n',['Centroid Time :  +' num2str(srctime2(psrcpos)) ' (sec) relative to origin time' ]);
                 end        
                 fprintf(fid,'%s\n',['Centroid Lat:  ' num2str(srclat(psrcpos,1)) '       Lon:  ' num2str(srclon(psrcpos,1))]);
                 fprintf(fid,'%s\n',['Centroid Depth : ' num2str(depth(srcpos(psrcpos)))]);
      fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s\n','======================================');
      fprintf(fid,'%s  %i    %s','No of Stations:', nstations , '(');
      for i=1:nstations-1
      fprintf(fid,'%s', [stanames{i} '-'] );
      end
      fprintf(fid,'%s', stanames{nstations} );
      fprintf(fid,'%s\n', ')' );
      %%%%break up invband string..!!
      iband = sscanf(invband,'%f %*s %f');
      fprintf(fid,'%s\n','Freq band (Hz)');    
     % fprintf(fid,'%s%s%s  %s %s%s%s %s %s%s%s\n',num2str(iband(2)),'-',num2str(iband(3)),'tapered', num2str(iband(1)),'-',num2str(iband(2)),'and' ,num2str(iband(3)),'-',num2str(iband(4))   );    
      fprintf(fid,'%s %s \n',num2str(iband(1)),'-',num2str(iband(2)));
%     fprintf(fid,'%s\n',invband);    
      fprintf(fid,'%s\n',['Variance Reduction (%): '  num2str(round(varred(psrcpos)*100))  ]  );
      fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s%s\n','Moment Tensor (Nm):  Exponent 10**', num2str(maxexp));
      fprintf(fid,'%s\n',['  Mrr      Mtt     Mpp']);
      fprintf(fid,'%6.3f  %6.3f  %6.3f\n',harcof(1), harcof(2), harcof(3));
      fprintf(fid,'%s\n',['  Mrt      Mrp     Mtp']);
      fprintf(fid,'%6.3f  %6.3f  %6.3f\n', harcof(4), harcof(5), harcof(6));
      %fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s\n',['VOL (%)      : ' num2str(inv1_vol)]);
      fprintf(fid,'%s\n',['DC (%)       : ' num2str(inv1_dc)]);
      fprintf(fid,'%s\n',['CLVD (%)     : '  num2str(inv1_clvd) ]);
      fprintf(fid,'%s\n','  ');    
      fprintf(fid,'%s','Best Double Couple: Mo=');
      fprintf(fid,'%s  %s\n',[' ' num2str(mo(psrcpos),'%6.3e') ],'Nm');
      fprintf(fid,'%s\n','NP1:   Strike   Dip   Rake');
      fprintf(fid,'        %s      %s     %s\n', num2str(str1(psrcpos)),  num2str(dip1(psrcpos)), num2str(rake1(psrcpos)));
      fprintf(fid,'%s\n','NP2:   Strike   Dip   Rake');
      fprintf(fid,'        %s      %s     %s\n', num2str(str2(psrcpos)),  num2str(dip2(psrcpos)) , num2str(rake2(psrcpos)));
      fid2 = fopen('dsretc.lst','r');
                      for i=1:22
                        tline = fgets(fid2);
                        fprintf(fid,'%s', tline); 
                     end
      fclose(fid2);
    fclose(fid);
      
  end  % linux
    
    
end



%%%%check for footer..
h=dir('footer.txt');

if length(h) == 1
    disp('Found footer.txt')
%%add footer...
fido  = fopen('footer.txt','r');
fid = fopen('MTsol.txt','a');

while 1
    tline = fgets(fido);
    if ~ischar(tline),   break,   end
    %%%% Write footer
          for i=1:length(tline)
             fprintf(fid,'%s',tline(i));
          end
end
fclose(fido);
fclose(fid);
%%% end
   
else
end

%% new code to prepare a QuakeMl file also 
% we just call the proper function with needed attributes

auth='UPSL';

ok = write_qkml1(num2str(str1(psrcpos)),num2str(dip1(psrcpos)),num2str(rake1(psrcpos)),...
    num2str(str2(psrcpos)),num2str(dip2(psrcpos)),num2str(rake2(psrcpos)),...
    num2str(150),num2str(150),num2str(150),num2str(150),num2str(150),num2str(150),num2str(150),num2str(150),num2str(150),auth,...
    num2str(inv1_clvd),num2str(inv1_dc),num2str(inv1_vol),num2str(mo(psrcpos),'%6.3e'),...
    num2str(harcof(1)),num2str(harcof(2)),num2str(harcof(3)),num2str(harcof(4)),num2str(harcof(5)),num2str(harcof(6)));

 


else
    
    %   text file not needed....
    
end

%%
% run batch file...
if ispc
  [s,r]=system('plbest.bat'); 
else
  !chmod +x   plbest.bat
  [s,r]=system('./plbest.bat'); 
end
  %%%% clean up...!!
  delete dsretc.lst
  delete dsr.dat

cd .. %%% return to main folder before plotting.... this should solve problems if user tried to plot waveforms before closing ps file...

% read the gsview version from defaults
psview=handles.psview;

if ispc
    try 
      system([psview ' .\invert\' eventidnew  '_best.ps']);
    catch exception 
        disp(exception.message)
    end
else
    system([psview ' ./invert/' eventidnew  '_best.ps']);
end

pwd


%% export to handles
Clon=num2str(srclon(psrcpos,1));
Clat=num2str(srclat(psrcpos,1));
Cdepth=num2str(depth(srcpos(psrcpos)));
CMo=num2str(mo(psrcpos),'%6.3e');

Ctime=srctime2(psrcpos);

handles.Clon=Clon;
handles.Clat=Clat;
handles.Cdepth=Cdepth;
handles.CMo=CMo;
handles.Corigin=Ctime;


% Update handles structure
guidata(hObject, handles);

% catch
%     cd ..
%     pwd
% end
% 
% --- Executes on button press in plsources.
function plsources_Callback(hObject, eventdata, handles)
% hObject    handle to plsources (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plsources

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function stationslistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stationslistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in stationslistbox.
function stationslistbox_Callback(hObject, eventdata, handles)
% hObject    handle to stationslistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns stationslistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stationslistbox


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% FUNCTIONS TO PLOT ALL STATIONS (REAL-SYNTHETIC) %%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%IN A NEW FIGURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotallstations(nostations,staname,normalized,invband,ftime,totime,uselimits,dtime,eventid,addvarred,pbw,net_use,fullstationfile,normsynth,npts)
%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

for i=1:nostations
    realdatafilename{i}=[staname{i} 'fil.dat'];
    syntdatafilename{i}=[staname{i} 'syn.dat'];
end

realdatafilename=realdatafilename';
syntdatafilename=syntdatafilename';
% 
% whos staname realdatafilename syntdatafilename
 
%try    
%%%%%%%%%NOW WE KNOW FILENAMES AND WE CAN PLOT .....
%%%%%%%%%go in invert first

%%
cd invert

%%%%%%%%%%%initialize data matrices
realdataall=zeros(npts,4,nostations);    %%%% npts according to isolacfg.isl
syntdataall=zeros(npts,4,nostations); 
maxmindataindex=zeros(1,2,nostations);
maxreal4sta=zeros(nostations);
maxsynt4sta=zeros(nostations);

%%%%open data files and read data
for i=1:nostations
fid1  = fopen(realdatafilename{i},'r');
fid2  = fopen(syntdatafilename{i},'r');

        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';

fclose(fid1);
fclose(fid2);
 

realdataall(:,:,i)=realdata;
maxmindataindex(:,:,i)=findlimits4plot(realdata);    %%% find data limits for plotting  ... June 2010 
syntdataall(:,:,i)=syntdata;
end

% fid  = fopen('allstat.dat','r');
% [station1,useornot,nsw,eww,vew,station] = textread('allstat.dat','%s %u %f %f %f %s');
% fclose(fid);

% only new version of allstat is allowed...

   [station,useornot,nsw,eww,vew,f1,f2,f3,f4] = textread('allstat.dat','%s %u %f %f %f %f %f %f %f',-1);

 %          if isequal(char(station1(1)),'001') && (length(char(station(1)))~=0)
% 
%            disp('Found new allstat.dat format')
%          else
%            [station1,useornot,nsw,eww,vew] = textread('allstat.dat','%s %u %f %f %f',-1); 
%            disp('Found old allstat.dat format')
%            % number of stations
%          end 

for i=1:nostations    %%%%%%loop over stations
      if useornot(i) == 0
          compuse(1,i) = 0;
          compuse(2,i) = 0;
          compuse(3,i) = 0;
      elseif useornot(i) == 1
          if nsw(i) == 0         %%   if weight == 0 component is not used..
             compuse(1,i) = 0;  
          else
             compuse(1,i) = 1;  
          end   

          if eww(i) == 0 
             compuse(2,i) = 0;  
          else
             compuse(2,i) = 1;  
          end   
          
          if vew(i) == 0 
             compuse(3,i) = 0;  
          else
             compuse(3,i) = 1;  
          end   
      end
end
%whos station useornot nsw eww vew
%%%% return to isola

cd ..
%%  out of invert
 
%catch
%        helpdlg('Error in file plotting. Check if all files exist');
%    cd ..
%end
     
% realdataall=realdataall(:,:,2:nostations+1);
% syntdataall=syntdataall(:,:,2:nostations+1);
% 
% 
% whos realdata syntdata 
%whos realdataall syntdataall


%%%%%%%%%%%%new code to compute varred per comp
k=0;
disp('Variance Reduction per component')

      fprintf(1,'%s \t\t %s \t\t %s \t\t %s\n', 'Station','NS','EW','Z')

for i=1:nostations    %%%%%%loop over stations
  
     for j=1:3                %%%%%%%%loop over components
%          disp(componentname{j})
         
         variance_reduction(i,j)= vared(realdataall(:,j+1,i),syntdataall(:,j+1,i),dtime);
     
     end   
     
fprintf(1, '\t%s \t\t %4.2f \t\t %4.2f \t\t %4.2f\n', staname{i}, variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3))
     
end                   

% whos variance_reduction staname
% staname
%%%%%%%%%%%%%%%%%%% normalize 23/06/05

% if normalized == 1
% 
%     disp('Normalized plot')
% 
%     for i=1:nostations
%         for j=2:4
% 
%              maxreal(i,j)=max(abs(realdataall(:,j,i)));
%              maxsynt(i,j)=max(abs(syntdataall(:,j,i)));
% 
% %                     maxstring=[   num2str(maxreal(i,j)) '  '  staname{i} ];
% %                     disp(maxstring)
% % 
%              
%              realdataall(:,j,i) = realdataall(:,j,i)/max(abs(realdataall(:,j,i)));
%              syntdataall(:,j,i) = syntdataall(:,j,i)/max(abs(syntdataall(:,j,i)));
%              
% %              max(abs(realdataall(:,j,i)))
% %              max(abs(syntdataall(:,j,i)))
% %              
%              
%          end
%     end
%     
%     
% else
% end

%% New type of normalization, based on maximum amplitude of component per station NOT TOTAL maximum

if normalized == 1

    disp('Normalized plot. Using normalization per component ')

    for i=1:nostations
        for j=2:4
             maxreal(i,j)=max(abs(realdataall(:,j,i)));
             maxsynt(i,j)=max(abs(syntdataall(:,j,i)));
        end
        
             maxreal4sta(i)=max(maxreal(i,:)); % maximum per station per component
             maxsynt4sta(i)=max(maxsynt(i,:)); % maximum per station per component for synthetic data
             
        for j=2:4                                              
             
             realdataall(:,j,i) = realdataall(:,j,i)/maxreal4sta(i);
             
             if normsynth==1
                 syntdataall(:,j,i) = syntdataall(:,j,i)/maxsynt4sta(i);  % normalize synthetic 
             else
                 syntdataall(:,j,i) = syntdataall(:,j,i)/maxreal4sta(i);
             end
             
        end
        
        
    end
    
    
else
end
%%%%%%%%%%%%  write varred per component in a file 
try
  cd output
  
   disp(['Saving Variance Reduction per component in ' eventid '_varred_info.txt file in \output folder.']);

    fid = fopen([eventid '_varred_info.txt'],'w');
       if ispc
          fprintf(fid,'%s \t %s \t %s \t %s\r\n', 'Station','NS','EW','Z');
       else
          fprintf(fid,'%s \t %s \t %s \t %s\n', 'Station','NS','EW','Z');
       end
    
    for i=1:nostations    %%%%%%loop over stations
        if ispc
         fprintf(fid, '%s \t\t %4.2f \t %4.2f \t %4.2f\r\n', staname{i}, variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3));
        else
         fprintf(fid, '%s \t\t %4.2f \t %4.2f \t %4.2f\n', staname{i}, variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3));
        end
    end                   

  fclose(fid);
  cd ..
catch
  cd ..
end

%%%%%%%%%% normalize
% realdataall=cat(3,realdataall,realdata);
% syntdataall=cat(3,syntdataall,syntdata);

%%%%%%%%%PLOTTING   
componentname=cellstr(['NS';'EW';'Z ']);

% h=figure
scrsz = get(0,'ScreenSize');

%fh=figure('Tag','Syn vs Obs','Position',[5 scrsz(4)*1/6 scrsz(3)*5/6 scrsz(4)*5/6-50], 'Name','Plotting Obs vs Syn');

fh=figure('Tag','Syn vs Obs','Position',get(0,'Screensize'), 'Name','Plotting Obs vs Syn');
set(gcf,'PaperPositionMode','auto')
set(fh,'defaultaxesfontname','AvantGarde')


mh = uimenu(fh,'Label','Export Figure');
eh1 = uimenu(mh,'Label','Convert to PNG','Callback','exportgraph(1)');
eh2 = uimenu(mh,'Label','Convert to PS','Callback','exportgraph(2)');
eh3 = uimenu(mh,'Label','Convert to EPS','Callback','exportgraph(3)');
eh4 = uimenu(mh,'Label','Convert to TIFF','Callback','exportgraph(4)');
eh5 = uimenu(mh,'Label','Convert to EMF','Callback','exportgraph(5)');
eh6 = uimenu(mh,'Label','Convert to JPG','Callback','exportgraph(6)');

%% select code based on GMT version
% read ISOLA defaults
[gmt_ver,psview,npts] = readisolacfg;
 

if gmt_ver==4
      eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot'); 
else
   %% put code for GMT5 !
      eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot5'); 
end

% create structure of handles
handles1 = guihandles(fh); 
handles1.nostations=nostations;
handles1.realdatafilename=realdatafilename;
handles1.syntdatafilename=syntdatafilename;
handles1.station=station;
handles1.useornot=useornot;
handles1.compuse=compuse;
handles1.variance_reduction=variance_reduction;
handles1.eventid=eventid;
handles1.ftime=ftime;
handles1.totime=totime;
handles1.maxmindataindex=maxmindataindex;
handles1.invband=invband;
guidata(fh, handles1);

%[100 100 scrsz(3)-200 scrsz(4)-200])
% subplot(nostations+1,3,1:3)

%%  Start by making legend  (top row of plots)
%subplot(nostations+1,3,1)

subplot1(nostations+1,3)  % initialize all plots

subplot1(1)    % select top left plot
v=axis;
text( v(1), .7,['Event date-time: ' strrep(eventid,'_','\_')],'FontSize',12)%,'FontWeight','bold')
axis off
% top mid plot
subplot1(2)
% 
% if pbw == 1
%           plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
%           hold on
%           plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'k','Visible','off');      
%           hold off
%                    [legend_h,object_h,plot_h,text_strings]= legend('Observed','Synthetic',2);
%                     set(legend_h,'FontSize',12)
%                     set(object_h,'LineWidth',2)
%                     set(plot_h(1),'LineWidth',1.5)
%                     set(plot_h(2),'LineWidth',1)
v=axis;
text( v(1), .7,['Displacement (m).  Inversion band (Hz)  ' invband],'FontSize',12)%,'FontWeight','bold')
axis off
% 
% else
%           plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
%           hold on
%           plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'r','Visible','off');      
%           hold off
%                    [legend_h,object_h,plot_h,text_strings]= legend('Observed','Synthetic',2);
%                     set(legend_h,'FontSize',12)
%                     set(object_h,'LineWidth',2)
%                     set(plot_h(1),'LineWidth',1.5)
%                     set(plot_h(2),'LineWidth',1)
%                     title(['Displacement (m).  Inversion band (Hz)  ' invband],'FontSize',10,'FontWeight','bold')
% axis off
% end


%subplot(nostations+1,3,3)
% top right plot
subplot1(3)

%           plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
%           hold on
%           plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'k','Visible','off');      
%           hold off
% 
%           v=axis;
          
% text( v(1), 1,'Gray waveforms weren''t used in inversion.','Color','k','FontSize',8,'FontWeight','bold');
% text( v(3), 0.5, 'Blue numbers are variance reduction','Color','k','FontSize',8,'FontWeight','bold');

if pbw == 1

    % dummy plot just for legend
    % line(nan,nan,'Color','black');hold on;line(nan,nan,'Color','black');hold off
      line([1 1],[1 1],'Color','black');hold on;line([1 1],[1 1],'Color','black');hold off
    
         [legend_h,object_h,plot_h,~]= legend('Observed','Synthetic');
         set(legend_h,'FontSize',12); set(object_h,'LineWidth',2);
         set(plot_h(1),'LineWidth',1.5); set(plot_h(2),'LineWidth',1)
         
     v=axis;
     text( v(1), 1.5,'Gray waveforms weren''t used in inversion.','Color','k','FontSize',12)%,'FontWeight','bold');
     text( v(3), 1.0, 'Blue numbers are variance reduction','Color','k','FontSize',12)% ,'FontWeight','bold');
     axis off

else  % color
     % dummy plot just for legend
         % L(1)=line(nan,nan,'Color','black','LineWidth',1.5);hold on;  %L(2)=line(nan,nan,'Color','red','LineWidth',1.);hold off
          line([1 1],[1 1],'Color','black','LineWidth',1.5);hold on;line([1 1],[1 1],'Color','red','LineWidth',1.);hold off
          
          [legend_h,object_h,plot_h,~]= legend('Observed','Synthetic');
          set(legend_h,'FontSize',12); set(object_h,'LineWidth',2);
          set(plot_h(1),'LineWidth',1.5); set(plot_h(2),'LineWidth',1);
      v=axis ;
      text( v(1), 1.5,'Gray waveforms weren''t used in inversion.','Color','k','FontSize',12)%,'FontWeight','bold') %,'FontName','Courier');
      text( v(1), 1.0,'Blue numbers are variance reduction','Color','k','FontSize',12)% ,'FontWeight','bold');
      axis off
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Finish with legend

k=0;
for i=1:nostations    %%%%%%loop over stations
%    realdataall    8192x4x6 
     for j=1:3                %%%%%%%%loop over components
          subplot1(j+k+3);
%          set(gca,'FontSize',8)
          %%%%%%%%%%%%%%%%%%%%%%%%%%%
      if pbw == 1      %% we need b&w plot
           
          if  compuse(j,i) == 1  
          plot(realdataall(:,1,i),realdataall(:,j+1,i),'k',...
                             'LineWidth',2);      
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(realdataall(:,1,i),realdataall(:,j+1,i),...
                             'LineWidth',2,'Color',[.5,0.5,.5]);      
                       
          end                         
          hold on
%%%%%%%%%%                          h = vline(50,'k');
          if  compuse(j,i) == 1  
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'k',...
                             'LineWidth',.8 );  
                         
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),...
                             'LineWidth',.8,'Color',[.5,0,0]);   
                         
 %                set(subplot(nostations+1,3,j+k+3),'Color',[.1,0.1,.1])     
                 
          end                         
          hold off
%     
      else   %%%pbw=0
          
          if  compuse(j,i) == 1  
          plot(realdataall(:,1,i),realdataall(:,j+1,i),'k',...
                             'LineWidth',1.5);      
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(realdataall(:,1,i),realdataall(:,j+1,i),...
                             'LineWidth',1.5,'Color',[.5,0.5,.5]);      
          end                         
          hold on
%%%%%%%%%%                          h = vline(50,'k');
          if  compuse(j,i) == 1  
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'r',...
                             'LineWidth',1. );  
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),...
                             'LineWidth',1.,'Color',[.5,0,0]);      
          end                         
          hold off
      end   %%end pbw
          
         if uselimits == 1
                  if normalized == 1
%                     axis ([ftime totime min(realdataall(:,j+1,i)) max(realdataall(:,j+1,i)) ]) ;   
                      axis ([ftime totime -1.0 1.0 ]) ;       
                  else
%                       %%which is larger smaller..?? synth or real..!!
%                          if min(realdataall(:,j+1,i)) <= min(syntdataall(:,j+1,i))
%                              yli1=min(realdataall(:,j+1,i));
%                          else
%                              yli1=min(syntdataall(:,j+1,i));
%                          end
%                          
%                          if max(realdataall(:,j+1,i)) >= max(syntdataall(:,j+1,i))
%                              yli2=max(realdataall(:,j+1,i));
%                          else
%                              yli2=max(syntdataall(:,j+1,i));
%                          end
%                              axis ([ftime totime yli1 yli2 ]) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Plot using max min values  from real data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   only

                            axis([ftime totime maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
                  end
         else   %%% not use time limits
                 if normalized == 1
                     v=axis;
                     axis([v(1) v(2) -1.0 1.0 ]) ;  
                 else
                     v=axis;
                     axis([v(1) v(2) maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
                 end
         end

%%%%%%%%%%%%%%%%%%%%%%% Add text in graph 
%%%% AXIS SCALE.....
                
          if i==1
            title(componentname{j},...
              'FontSize',11,...
              'FontWeight','bold');
          end
          
          if i==nostations
          xlabel('Time (sec)')
          
          elseif i~=nostations
               set(gca,'Xtick',[-10 1000])
%               set(gca,'Ytick',[-5 5])
%               set(gca,'Color','none')
              
          end
          
          if  j==1 
            % check if we need network code
               if net_use ==0
                  y=ylabel(staname{i},'FontSize',12,'FontWeight','bold');
                    set(get(gca,'YLabel'),'Rotation',0)
                    set(y, 'Units', 'Normalized', 'Position', [-0.12, 0.5, 0]);
               else
                  %  disp(['Using ' fullstationfile ' station file'])
                    %read data in 3 arrays
					%fullstationfile
                    fid  = fopen(fullstationfile,'r');
					 if fid==-1
					   f = errordlg('Cannot opean station file','File Error');
					   return
					 else
					 end
                        C= textscan(fid,'%s %f %f %s',-1);
                    fclose(fid);
                    staname_stn=C{1};netcode=C{4};
                      for ii=1:nostations
                          for jj=1:length(staname_stn)
                              if strcmp(char(staname{ii}),char(staname_stn(jj)))
                                    st_netcode(ii)=netcode(jj);
                                  %  disp(['Code for ' char(staname{ii}) ' is ' char(st_netcode(ii))])
                              else
                              end
                          end
                      end
                %% ploting
                    y=ylabel([char(st_netcode(i)) '.' char(staname{i})],'FontSize',12,'FontWeight','bold');
                    set(get(gca,'YLabel'),'Rotation',0);set(y, 'Units', 'Normalized', 'Position', [-0.12, 0.5, 0]);  
               end
          end

%           if  j==2 
%           ylabel('Displacement')
%           end

%%%%%%%%%
%%%%%%%%%                Normalized plotting
%%%%%%%%%          
        if normalized == 1
            if uselimits == 1
                %text( ftime,  1.1, num2str(maxreal(i,j+1),'%8.2E'),'HorizontalAlignment','left','FontSize',8,'FontWeight','bold');   %%% max values
                if j==3
                 text(totime+(totime/10), 0, num2str(maxreal4sta(i),'%8.2E'),'Color','k','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max value of station
                   if normsynth==1
                     text(totime+(totime/10), -0.5, num2str(maxsynt4sta(i),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max syntetic value of station
                   else
                   end
                end
                
               if addvarred == 1   %%%%%%%%%%  print variance                
%                  text( ftime+15, -.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,'FontWeight','bold');
                   text((totime-ftime)*0.05, -.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','left','FontSize',10,...
                      'FontWeight','bold','FontName','FixedWidth');  
               else
               end
%%%%%%%%%%%%%%%%               
            else  % not use limits
                %text( min(realdataall(:,1,i)), 1.2, num2str(maxreal(i,j+1),'%8.2E'),'HorizontalAlignment','left','FontSize',8,'FontWeight','bold');  % max values
                %text( max(realdataall(:,1,i)), 1.2, num2str(maxsynt(i,j+1),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');
                if j==3
                 text(totime+(totime/10), 0, num2str(maxreal4sta(i),'%8.2E'),'Color','k','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max value of station
                   if normsynth==1
                     text(totime+(totime/10), -0.5, num2str(maxsynt4sta(i),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max syntetic value of station
                   else
                   end
                end
                
               if addvarred == 1   %%%%%%%%%%print variance 
                 v=axis;
                 text((v(2)-v(1))*0.95, -0.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,...
                   'FontWeight','bold','FontName','FixedWidth');  
               else
               end
               
            end
%%%%%%%%%%%%%%%%%%%%
         else    %%% not normalized
            if addvarred == 1
                if uselimits == 0
                    v=axis;
                    ((v(2)-v(1))*0.02)+v(1);
                    text((v(2)-v(1))*0.95, v(4)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,...
                    'FontWeight','bold','FontName','FixedWidth');
                else
                    v=axis;
 %                  text(ftime+15 , v(3)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,'FontWeight','bold');
                   text(((totime-ftime)*0.03)+ftime , v(3)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','left','FontSize',10,...
                       'FontWeight','bold','FontName','FixedWidth');
                    
                end
            else
            end
        end    %%%end of Normalized  if

      end       %%%%%%%loop over components
      
       k=k+3;
       
end   %%%%%%%loop over stations

%% OUTPUT options in isl file
    fid2 = fopen('waveplotoptions.isl','w');

    if normalized == 1
       if ispc  
         fprintf(fid2,'%c\r\n','1');
       else
         fprintf(fid2,'%c\n','1');
       end
     else
       if ispc  
         fprintf(fid2,'%c\r\n','0');
       else
         fprintf(fid2,'%c\n','0');
       end
     end
%%     
     if uselimits == 1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
         if ispc
           fprintf(fid2,'%c\r\n','0');
         else
           fprintf(fid2,'%c\n','0');
         end
     end
%%     
     if ispc
          fprintf(fid2,'%f\r\n',ftime);
          fprintf(fid2,'%f\r\n',totime);
     else
          fprintf(fid2,'%f\n',ftime);
          fprintf(fid2,'%f\n',totime);
     end
%%     
     if addvarred == 1
         if ispc 
            fprintf(fid2,'%c\r\n','1');
         else
            fprintf(fid2,'%c\n','1');
         end
     else
        if ispc 
           fprintf(fid2,'%c\r\n','0');
        else
           fprintf(fid2,'%c\n','0');
        end
     end
%%     
     if pbw==1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
        if ispc 
         fprintf(fid2,'%c\r\n','0');
        else
         fprintf(fid2,'%c\n','0');
        end
     end

%% add new extra features     
      if normsynth==1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
        if ispc 
         fprintf(fid2,'%c\r\n','0');
        else
         fprintf(fid2,'%c\n','0');
        end
     end
%%
      if net_use==1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
        if ispc 
         fprintf(fid2,'%c\r\n','0');
        else
         fprintf(fid2,'%c\n','0');
        end
     end
% 

    fclose(fid2);

%%
mh = uimenu(fh,'Label','Export Figure');
eh1 = uimenu(mh,'Label','Convert to PNG','Callback','exportgraph(1)');
eh2 = uimenu(mh,'Label','Convert to PS','Callback','exportgraph(2)');
eh3 = uimenu(mh,'Label','Convert to EPS','Callback','exportgraph(3)');
eh4 = uimenu(mh,'Label','Convert to TIFF','Callback','exportgraph(4)');
eh5 = uimenu(mh,'Label','Convert to EMF','Callback','exportgraph(5)');
eh6 = uimenu(mh,'Label','Convert to JPG','Callback','exportgraph(6)');
%% select code based on GMT version
% read ISOLA defaults
[gmt_ver,psview,npts] = readisolacfg;
 

if gmt_ver==4
      eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot'); 
else
   %% put code for GMT5 !
   
      eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot5'); 
   
end
    
    set(get(gca,'YLabel'),'Rotation',0)
 %       cpng
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FUNCTION TO PLOT ONLY ONE STATION (REAL-SYNTHETIC) %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IN A NEW FIGURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotonestation(stationname,normalized,ftime,totime,uselimits,normsynth,npts)

%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

    realdatafilename=[stationname 'fil.dat'];
    syntdatafilename=[stationname 'syn.dat'];
 
%%%%%%%%%%%initialize data matrices
realdata=zeros(npts,4);   
syntdata=zeros(npts,4); 

try
    
%%%go in invert
cd invert

%%%%open data files and read data
fid1  = fopen(realdatafilename,'r');
fid2  = fopen(syntdatafilename,'r');

        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';

maxmin_onedataindex=findlimits4plot(realdata);    %%% find data limits for plotting  ... June 2010 
        
fclose(fid1);
fclose(fid2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% go back to isola

cd ..

catch
        helpdlg('Error in file plotting. Check if all files exist');
    cd ..
end

% whos realdata
% realdata(1:10,2)
%%%%%%%%%%%%%%%%%%% normalize 23/06/05
%% old type
% if normalized == 1
% 
%     disp('Normalized plot')
% 
%     for i=2:4
%         maxreal(i)=max(abs(realdata(:,i)));
%         maxsynt(i)=max(abs(syntdata(:,i)));
% 
%         realdata(:,i) = realdata(:,i)/max(abs(realdata(:,i)));
%         syntdata(:,i) = syntdata(:,i)/max(abs(syntdata(:,i)));
%     
%     end
%     
% else
% end
%%%%%%%%%%%%%%%%%%% normalize  realdata=zeros(8192,4); 
if normalized == 1
   disp('Normalized plot. Using normalization per component ')
        for j=2:4
             maxreal(j)=max(abs(realdata(:,j)));
             maxsynt(j)=max(abs(syntdata(:,j)));
        end
             [maxreal4sta,index_real]=max(maxreal); % maximum per station per component
             [maxsynt4sta,index_synt]=max(maxsynt); % maximum per station per component for synthetic data

        for j=2:4  
            
             realdata(:,j) = realdata(:,j)/maxreal4sta;
             
             if normsynth==1
                    syntdata(:,j) = syntdata(:,j)/maxsynt4sta;
             else
                    syntdata(:,j) = syntdata(:,j)/maxreal4sta;
             end
        end
        
else
end

%%%%%%%%%PLOTTING   
componentname=cellstr(['NS';'EW';'Z ']);


figure


for j=1:3                %%%%%%%%loop over components
         
          subplot(3,1,j);
          plot(realdata(:,1),realdata(:,j+1),'k', 'LineWidth', 1.5);
          hold on
%%%%%%%           h = vline(50,'k');
          plot(syntdata(:,1),syntdata(:,j+1),'r', 'LineWidth', 1.5);
          hold off
%           legend('Real','Synthetic',1); 
          ylabel('Displacement (m)','FontSize',11)
        
          if  j==1 
          title(stationname,...
              'FontSize',12,...
              'FontWeight','bold');
          leg=legend('Real','Synthetic'); 
          set(leg,'Color','none')
          end
          
          if  j==3 
          xlabel('Time (Sec)','FontSize',11)
          end
          
%           %%%% Normalized plotting
%           if normalized == 1
%           %      text( 10, 0.7, num2str(maxreal(j+1)));
%                % text( 10, 0.5, num2str(maxsynt(j+1)),'Color','r');
%                 v=axis
%                 axis([v(1) v(2) -1.0 1.0 ]) ;  
%                 legend('Real','Synthetic'); 
%           else
%                legend('Real','Synthetic'); 
%           end      
 
         %%%%%%%%%%%%%%%
     if uselimits == 1
              
              if normalized == 1
%                     axis ([ftime totime min(realdataall(:,j+1,i)) max(realdataall(:,j+1,i)) ]) ;   
                      axis ([ftime totime -1.0 1.0 ]) ;       
                      text( totime-10  ,  -0.7   , componentname{j},'FontSize',11,'FontWeight','bold');
                      
                      if index_real==(j+1)
                       text( totime+1, 0, num2str(maxreal(j+1),'%8.2e'),'FontSize',10,'FontWeight','bold');
                      else
                      end
                      
                      if normsynth==1
                          if index_synt==(j+1)
                              text( totime+1, -0.5, num2str(maxsynt(j+1),'%8.2e'),'Color','r','FontSize',10,'FontWeight','bold');
                          else
                          end
                      else
                      end
                      
              else
                      %%which is larger smaller..?? synth or real..!!
                         if min(realdata(:,j+1)) <= min(syntdata(:,j+1))
                             yli1=min(realdata(:,j+1));
                         else
                             yli1=min(syntdata(:,j+1));
                         end
                         
                         if max(realdata(:,j+1)) >= max(syntdata(:,j+1))
                             yli2=max(realdata(:,j+1));
                         else
                             yli2=max(syntdata(:,j+1));
                         end
%                          
                      axis([ftime totime maxmin_onedataindex(2) maxmin_onedataindex(1)]);
%                      axis ([ftime totime yli1 yli2 ])
 
                      text( totime-10  ,   yli1+(yli2/3)      , componentname{j},'FontSize',11,'FontWeight','bold');

              end
     else
              if normalized ==1 
                v=axis; 
                axis([v(1) v(2) -1.0 1.0 ]) ;  
                text( v(2)-10  ,  -0.7   , componentname{j},'FontSize',11,'FontWeight','bold');
                
                if index_real==(j+1)
                   text( v(2)+1   , 0, num2str(maxreal(j+1),'%8.2e'),'FontSize',10,'FontWeight','bold');
                else
                end
                  
                if normsynth==1
                    if index_synt==(j+1)
                        text( totime+1, -0.5, num2str(maxsynt(j+1),'%8.2e'),'Color','r','FontSize',10,'FontWeight','bold');
                    else
                    end
                else
                end
                
              else
                v=axis;
                text( max(realdata(:,1)) - (max(realdata(:,1))*0.05)   ,  min(realdata(:,j+1)) - (min(realdata(:,j+1))*0.5)   , componentname{j},'FontSize',11,'FontWeight','bold');
                axis([v(1) v(2) maxmin_onedataindex(2) maxmin_onedataindex(1)]);
              end
             
     end
         
     
             set(gca,'fontsize',11)
             set(gca,'linewidth',1.5)
     
     
end   %%% main loop over components




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% FUNCTIONS TO PLOT ALL STATIONS (REAL) %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%IN A NEW FIGURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotallstationsReal(nostations,staname,uselimits,ftime,totime,npts)
%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

for i=1:nostations
    realdatafilename{i}=[staname{i} 'fil.dat'];
end

realdatafilename=realdatafilename';
    
%%%%%%%%%NOW WE KNOW FILENAMES AND WE CAN PLOT .....
%%%%%%%%%go in invert first
try
  cd invert

%%%%%%%%%%%initialize data matrices
realdataall=zeros(npts,4);    %%%% 8192 points  fixed....
maxmindataindex=zeros(1,2,nostations);

%%%%open data files and read data
for i=1:nostations
    
fid1  = fopen(realdatafilename{i},'r');
        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
fclose(fid1);

realdataall=cat(3,realdataall,realdata);
end

%%%%%%%%%go back to isola
 cd ..
 
catch
    cd ..
end


realdataall=realdataall(:,:,2:nostations+1);

for i=1:nostations
  maxmindataindex(:,:,i)=findlimits4plot(realdataall(:,:,i));
end

componentname=cellstr(['NS';'EW';'Z ']);

%%%%%%%%%PLOTTING   
scrsz = get(0,'ScreenSize');
figure('Position',[100 100 scrsz(3)-200 scrsz(4)-200])

%% Ploting
subplot1(nostations+1,3)  % initialize all plots
%          subplot(nostations+1,3,1);
subplot1(1) 
          axis off
%          subplot(nostations+1,3,2);
subplot1(2) 
           plot(realdataall(:,1,1),realdataall(:,2,1),'Visible','off')
                         title('Real data displacement (m)','FontSize',12,'FontWeight','bold')
          axis off
%          subplot(nostations+1,3,3);
subplot1(3) 
          axis off
          
%%          
k=0;
for i=1:nostations    %%%%%%loop over stations
%    realdataall    8192x4x6 
     for j=1:3   %%%%%%%%loop over components
          %subplot(nostations+1,3,j+k+3);
          subplot1(j+k+3);
          
          plot(realdataall(:,1,i),realdataall(:,j+1,i),'k','LineWidth',1);   
          %%%%%  h = vline(50,'k');
          v=axis;
          axis([v(1) v(2) maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
      
          if i==1
            title(componentname{j},'FontSize',12,'FontWeight','bold');
          end
          if i==nostations
            xlabel('Sec')
          end
          if  j==1 
            ylabel(staname{i},'FontSize',12,'FontWeight','bold');
          end
          
                if uselimits == 1
                    axis ([ftime totime maxmindataindex(1,2,i) maxmindataindex(1,1,i) ])
                else
                end
     end
    
     k=k+3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FUNCTION TO PLOT ONLY ONE STATION (REAL)%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IN A NEW FIGURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotonestationReal(stationname,uselimits,ftime,totime,npts)

%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

realdatafilename=[stationname 'fil.dat'];
%%%%%%%%%%%initialize data matrices
realdata=zeros(npts,4);   

%%%go in invert
cd invert

%%%%open data files and read data
fid1  = fopen(realdatafilename,'r');
        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
fclose(fid1);

maxmin_onedataindex=findlimits4plot(realdata); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% go back to isola
cd ..
componentname=cellstr(['NS';'EW';'Z ']);
%%%%%%%%%PLOTTING   
figure

     for j=1:3                %%%%%%%%loop over components
         
          subplot(3,1,j);
          plot(realdata(:,1),realdata(:,j+1));
%           legend('Real Data',1); 
%%%%%          h = vline(50,'k');
          if  j==1 
          title(stationname,...
              'FontSize',12,...
              'FontWeight','bold');
          end
          if  j==3 
          xlabel('Time (Sec)')
          ylabel('Displacement (m)')
          end
          
          if uselimits == 1
	        axis ([ftime totime maxmin_onedataindex(2) maxmin_onedataindex(1) ]);
               
          else
   	        v=axis; 
	        axis ([v(1) v(2) maxmin_onedataindex(2) maxmin_onedataindex(1) ]);
          end

    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% FUNCTION  TO PLOT ALL STATIONS (SYNTHETIC)%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%IN A NEW FIGURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      

function plotallstationssyn(nostations,staname,uselimits,ftime,totime,npts)
%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

for i=1:nostations
    syntdatafilename{i}=[staname{i} 'syn.dat'];
end

syntdatafilename=syntdatafilename';

% whos staname syntdatafilename
        
%%%%%%%%%NOW WE KNOW FILENAMES AND WE CAN PLOT .....
%%%%%%%%%go in invert first
try
    
  cd invert
%%%%%%%%%%%initialize data matrices
syntdataall=zeros(npts,4); 
maxmindataindex=zeros(1,2,nostations);

%%%%open data files and read data
for i=1:nostations
    
fid2  = fopen(syntdatafilename{i},'r');
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';
fclose(fid2);

syntdataall=cat(3,syntdataall,syntdata);
end

     %%%% return to isola
     cd ..
catch
    cd ..
end

syntdataall=syntdataall(:,:,2:nostations+1);
% 
for i=1:nostations
  maxmindataindex(:,:,i)=findlimits4plot(syntdataall(:,:,i)); 
end

componentname=cellstr(['NS';'EW';'Z ']);

%%%%%%%%%PLOTTING   
scrsz = get(0,'ScreenSize');
figure('Position',[100 100 scrsz(3)-200 scrsz(4)-200])
          
          subplot(nostations+1,3,1);
          axis off
          
          subplot(nostations+1,3,2);
          plot(syntdataall(:,1,1),syntdataall(:,2,1)-0.0003,'Visible','off')
                         title('Synthetic data displacement (m)','FontSize',12,'FontWeight','bold')
          axis off
          
          subplot(nostations+1,3,3);
          axis off

k=0;
for i=1:nostations    %%%%%%loop over stations

    for j=1:3                %%%%%%%%loop over components
          subplot(nostations+1,3,j+k+3);
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'k','LineWidth',1);  
          % h = vline(50,'k');
          
             v=axis;
            axis([v(1) v(2) maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
          
          if i==1
            title(componentname{j},'FontSize',12,'FontWeight','bold');
          end
          if i==nostations
          xlabel('Sec')
          end
          if  j==1 
          ylabel(staname{i},'FontSize',12,'FontWeight','bold');
          end

                if uselimits == 1
                    axis ([ftime totime maxmindataindex(1,2,i) maxmindataindex(1,1,i) ])
                else
                end
                    
                    
      end
    
     k=k+3;
     
 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%FUNCTION TO PLOT ONLY ONE STATION (SYNTHETIC) %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%IN A NEW FIGURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotonestationsyn(stationname,uselimits,ftime,totime,npts)

%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

    syntdatafilename=[stationname 'syn.dat'];
 
%%%%%%%%%%%initialize data matrices
syntdata=zeros(npts,4); 

%%%go in invert
cd invert

%%%%open data files and read data
fid2  = fopen(syntdatafilename,'r');
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';
fclose(fid2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxmin_onedataindex=findlimits4plot(syntdata); 

%% go back to isola
cd ..

componentname=cellstr(['NS';'EW';'Z ']);

%%%%%%%%%PLOTTING   

figure

 for j=1:3                %%%%%%%%loop over components
         
          subplot(3,1,j);
          plot(syntdata(:,1),syntdata(:,j+1),'r');
%         h = vline(50,'k');
%         legend('Synthetic',1); 
          if  j==1 
          title(stationname,...
              'FontSize',12,...
              'FontWeight','bold');
          end
          if  j==3 
          xlabel('Time (Sec)')
          ylabel('Displacement (m)')
          end
          
          if uselimits == 1
             axis ([ftime totime maxmin_onedataindex(2) maxmin_onedataindex(1) ])
          else
            v=axis; 
	        axis ([v(1) v(2) maxmin_onedataindex(2) maxmin_onedataindex(1) ])
          end
          
 end


% --- Executes on button press in check1.
function check1_Callback(hObject, eventdata, handles)
% hObject    handle to check1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check1


% --- Executes on button press in plsourcesxy.
function plsourcesxy_Callback(hObject, eventdata, handles)
% hObject    handle to plsourcesxy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


plsourcesxy


% --- Executes on button press in plpol.
function plpol_Callback(hObject, eventdata, handles)
% hObject    handle to plpol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
    fclose(fid);
end

%%% check if polarity folder exists..
disp('plotting polarity data..')

h=dir('polarity');

if isempty(h);
    errordlg('Polarity folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%start
%%%go in polarity

 %  try


cd polarity

%%%station.dat and source.dat should be in polarity check it...
h=dir('station.dat');
if isempty(h); 
  errordlg('Station.dat file doesn''t exist. Run Station select. ','File Error');
  return
else
end

h=dir('source.dat');
if isempty(h); 
  errordlg('Source.dat file doesn''t exist. Run Station select. ','File Error');
  return
else
end

%% Open source.dat and put the selected depth
selected_depth=str2double(get(handles.depth,'String'));

%%%%%OUTPUT SOURCE LOCATION %%%%%%%%%%%%%%%%%
if ispc
  fid = fopen('source.dat','w');
    fprintf(fid,'%s\r\n',' Source parameters');
    fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
    fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\r\n',0,0, selected_depth,magn, '''', eventdate, '''');
  fclose(fid);

else
  fid = fopen('source.dat','w');
    fprintf(fid,'%s\n',' Source parameters');
    fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
    fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\n',0,0, selected_depth,magn, '''', eventdate, '''');
  fclose(fid);
end

disp(' ')
disp('Updated source.dat with selected depth')
disp(' ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%check if extrapol.pol exists...
h=dir('extrapol.pol');
if isempty(h); 
  disp('Extrapol.pol file doesn''t exist. ');
  
else
     disp('Found extrapol.pol file. Extra station polarities will be used');
  fid  = fopen('extrapol.pol','r');
    [stanamextra,stalatextra,stalonextra,stapolextra] = textread('extrapol.pol','%s %f %f %s',-1);
  fclose(fid);

  %fix origin on the epicenter
  orlat=eventcor(2);
  orlon=eventcor(1);

  %%%%%%%%%%%%  USE GRS80 ELLIPSOID
  grs80.geoid = almanac('earth','geoid','km','grs80');
  %%%%%%%%%%%%%%%%CALCULATE AZIMUTH AND EPICENTRAL DISTANCE FOR EVERY STATION

 for i=1:length(stalatextra)
    staazimextra(i)=azimuth(eventcor(2),eventcor(1),stalatextra(i),stalonextra(i),grs80.geoid);
    epidistextra(i)=distdim(distance(eventcor(2),eventcor(1),stalatextra(i),stalonextra(i),grs80.geoid),'km','km');
 end

  %%%% FIX SOURCE AT ORIGIN
  sourceXdist=0;
  sourceYdist=0;

 for i=1:length(stalatextra)
             [stationXdistextra(i),stationYdistextra(i)] = pol2cart(deg2rad(staazimextra(i)),epidistextra(i));
 end
 % 

 %%%%%%%%OUTPUT%%%%%%%%%%%%%%%%%%%%
 for i=1:length(stalatextra)
    outex(i,1)=stationXdistextra(i);     %%%%%% 
    outex(i,2)=stationYdistextra(i);
    outex(i,3)=0;
    outex(i,4)=staazimextra(i);
    outex(i,5)=epidistextra(i);
 end    

  %%% output
  fid = fopen('station.dat','a');
  for i=1:length(stalatextra)
      if ispc
             fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',outex(i,1),outex(i,2),outex(i,3),outex(i,4),outex(i,5),stanamextra{i,1}',stapolextra{i,1}');
      else
             fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\n',outex(i,1),outex(i,2),outex(i,3),outex(i,4),outex(i,5),stanamextra{i,1}',stapolextra{i,1}');
      end
  end
  fclose(fid);
  %%%% rename extrapol.pol  not to use every time we run polarity plot...
    [s,mess,messid]=movefile('extrapol.pol','extrapol.done');
  %%%%%
end
%%
if get(handles.autocopy,'Value') == 1

%%%%% get crustal.dat from green

disp('Copying crustal.dat from GREEN folder')

if ispc
[s,mess,messid]=copyfile('..\green\crustal.dat','.');
else
[s,mess,messid]=copyfile('../green/crustal.dat','.');
end
if s==1 
    disp('Copied crustal.dat file in polarity folder');
else
    h=msgbox('Failed to copy crustal.dat file in polarity folder','Copy files');
end

else
    
    disp('Crustal.dat was not copied from GREEN folder. Make sure a CRUSTAL.DAT file exists in POLARITY folder.');
    
end

%% run angone    !!!!!!!!!!!  check if source is on some interface..???

%%%read crustal model...
fid  = fopen('crustal.dat','r');
       line1=fgets(fid);         %01 line
       title=line1(28:length(line1)-2);
       line2=fgets(fid);         %02 line
       line3=fgets(fid);         %03 line
       nlayers=sscanf(line3,'%i');
       disp(['Model has ' num2str(nlayers) ' layers'])
       if nlayers > 15
            errordlg('Model has more than 15 layers','Error');
        else
        end
        %%%%%
       line4=fgets(fid);         %04 line
       line5=fgets(fid);         %05 line

    c=fscanf(fid,'%g %g %g %g %g %g',[6 nlayers]);       
    c = c';
fclose(fid);
model_depths=c(:,1);

%%%%read source.dat
fid  = fopen('source.dat','r');
[lon,lat,depth,mag,tt] = textread('source.dat','%f %f %f %f %s','headerlines',2);
fclose(fid);
%%%%%%%% we have read both files check if depth = interface...

for i=1:length(model_depths)
    if depth == model_depths(i)
        disp(['Source depth  ' num2str(depth) ' equals CRUSTAL.DAT interface no ' num2str(i) ' ANGONE.EXE doesn''t like this. Adding 0.2 to depth'])
        warndlg(sprintf(['Source depth  ' num2str(depth) ' equals CRUSTAL.DAT interface no ' num2str(i) ' \n ANGONE.EXE doesn''t like this. Adding 0.2 to depth']))
        
        depth=depth+0.2;
        
        %%%%prepare new source.dat ...
                 fid = fopen('source.dat','w');
                   if ispc
                      fprintf(fid,'%s\r\n',' Source parameters');
                      fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
                      fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %s\r\n',lon,lat,depth,mag, tt{1});
                   else
                      fprintf(fid,'%s\n',' Source parameters');
                      fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
                      fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %s\n',lon,lat,depth,mag, tt{1});
                   end
                 fclose(fid);

    else
        disp(['CRUSTAL.DAT Interface no ' num2str(i) ' ok for source.dat depth '  num2str(depth)  ])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%  check if source is under Moho...!!we need to add
%%%%%%%%%%%%%%%%%%%%%%%%  another layer then .........

disp(['Found moho at ' num2str(model_depths(nlayers)) '  km'])
disp(['Source depth is ' num2str(depth) '  km'])

if depth >= model_depths(nlayers)

    disp('Source depth is deeper than moho. Adding one layer in crustal.dat.')
    
    newlastdepth=depth+5;
    
    c(nlayers+1,1)=newlastdepth;
    c(nlayers+1,2)=c(nlayers,2)+0.01;
    c(nlayers+1,3)=c(nlayers,3);
    c(nlayers+1,4)=c(nlayers,4);
    c(nlayers+1,5)=c(nlayers,5);
    c(nlayers+1,6)=c(nlayers,6);
   
    %%now we need to add this to crustal.dat for polarity plot...
    if ispc
    system('del crustal.dat');
    else
    system('rm crustal.dat');
    end
    
    fid = fopen('crustal.dat','w');
    fprintf(fid,'%s',line1);
    fprintf(fid,'%s',line2);
    if ispc
      fprintf(fid,'   %i\r\n',nlayers+1);
    else
      fprintf(fid,'   %i\n',nlayers+1);
    end
    fprintf(fid,'%s',line4);
    fprintf(fid,'%s',line5);
    
    for i=1:nlayers+1
        if ispc
          fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\r\n',c(i,1),c(i,2),c(i,3),c(i,4),c(i,5),c(i,6) );
        else
          fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\n',c(i,1),c(i,2),c(i,3),c(i,4),c(i,5),c(i,6) );
        end
    end
     if ispc
        fprintf(fid,'%s\r\n','*************************************************************************');
     else
        fprintf(fid,'%s\n','*************************************************************************');
     end
    fclose(fid);
    
    
else
end

%%   RUN ANGONE  %%%%%%%%%%%%%%

[status, result] = system('angone.exe');

%% find how many stations we have check the station.dat

    fid = fopen('station.dat','r');
          C=textscan(fid,'%f %f %f %f %f %s %s ','HeaderLines', 2);
    fclose(fid);
    
    nostations=length(C{1})

%% open data files and read data
% fid  = fopen('mypol.dat','r');
% 
% %[staname,pol,d1,d2,d4,d5,d6] = textread('mypol.dat','%s %s %f %f %f %f %f','headerlines',1);
% [staname,d1,d2,pol,d4,d5] = textread('mypol.dat','%s %f %f %s %f %f ',nostations,'headerlines',1);
% 
% fclose(fid);

%%  pause here if user wants to change mypol...

uiwait(helpdlg('Edit .\polarity\mypol.dat (IF you want) and press OK'));


%% new code that checks length of line

   fid = fopen('mypol.dat','r');
          tline = fgets(fid);
          tline = fgets(fid);
          i=1;
       while ischar(tline)
          
           if length(tline) < 55 
              A=textscan(tline,'%s %f %f %s %f %f ');
              staname(i)=A{1,1};
             d1(i)=A{1,2};
             d2(i)=A{1,3};
             pol(i)=A{1,4};
             d4(i)=A{1,5};
             d5(i)=A{1,6};
             d6(i)=0;
           
           else
              A=textscan(tline,'%s %f %f %s %f %f %f');
             staname(i)=A{1,1};
             d1(i)=A{1,2};
             d2(i)=A{1,3};
             pol(i)=A{1,4};
             d4(i)=A{1,5};
             d5(i)=A{1,6};
             d6(i)=A{1,7};
           end
           
              tline = fgets(fid);
              i=i+1;
       end

  fclose(fid);

 
%%
% whos staname

% staname=staname(1:length(staname));
% pol=pol(1:length(pol));
% d1=d1(1:length(d1));
% d2=d2(1:length(d2));
% d4=d4(1:length(d4));
% d5=d5(1:length(d5));
%d6=d6(1:length(d6));

h=dir('onemech.dat');
if isempty(h); 
  errordlg('onemech.dat file doesn''t exist. Please create. ','File Error');
  cd ..
  return
else
end

fid  = fopen('onemech.dat','r');
[iso,tim,mom,s1,di1,r1,s2,di2,r2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,var] = textread('onemech.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',-1);
fclose(fid);

%%%
h=dir('moremech.dat');

if isempty(h);
    warndlg('moremech.dat doesn''t exist. Plotting one mechanism only.','Info');
else
    
   
fid  = fopen('moremech.dat','r');
[isom,timm,momm,s1m,di1m,r1m,s2m,di2m,r2m,aziPm,plungePm,aziTm,plungeTm,aziBm,plungeBm,dcm,varm] = textread('moremech.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',-1);
fclose(fid);
end

 
cd ..  % out of polarity

%%
%   catch
%   h=msgbox('File problem in polarity folder...','Error');
%   cd ..
%   return
%   end

pwd

%% PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% decide if we need full MT or DC 

if get(handles.full_DC,'Value') == 1  % plot full

    %%prepare a circle
    % full MT plot based on code by V?clav Vavry?uk
    % http://www.ig.cas.cz/en/research-teaching/software-download/
    disp('full mt plot based on codes by V?clav Vavrycuk')

    %% read inv3
    cd invert
        pwd
    h=dir('inv3.dat');
    if isempty(h); 
        errordlg('inv3.dat file doesn''t exist. Run Invert. ','File Error');
        cd ..
    return    
    else
        fid = fopen('inv3.dat','r');
            [~,~,mrr, mtt, mff, mrt, mrf, mtf ] = textread('inv3.dat','%f %f %f %f %f %f %f %f');
        fclose(fid);
    end

    %  find moment
    nsources=handles.nsources;
    [~,~,inv1_mom,~,~,~,~,~,~,~]=readinv1(nsources,1);
    mfive=4.0e23;
        
    cd ..
    %%
    % change system
    moment_11= mtt; moment_12= -1*mtf; moment_13= mrt;moment_22= mff;moment_23= -1*mrf;moment_33= mrr;
 
    m=[moment_11,moment_12,moment_13;...
       moment_12,moment_22,moment_23;...
       moment_13,moment_23,moment_33];
    %----------------------------------------------------------------------------------------
    % calculation of a fault normal and slip from the moment tensor
    %----------------------------------------------------------------------------------------
    angles_all(1,:) = angles(m);
    
    strike_1 = angles_all(1,1);
    dip_1    = angles_all(1,2);
    rake_1   = angles_all(1,3);

    mech=[s1(1,1) di1(1,1) r1(1,1)];
    figure; hold on; axis equal;  axis off; 
    shadowing(m);
% boundary circle;
    Fi=0:0.1:361;
    plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k','LineWidth',1.5)
 
% denoting the North direction
    plot([0 0], [1 1.07],'k','LineWidth',1.5);
    text(-0.035, 1.15,'N','FontSize',14);
    nodal_lines_(strike_1, dip_1, rake_1);
    
    P_T_axes_(strike_1, dip_1, rake_1);

%plot polarities
    for i=1:length(staname)
    [x3(i),y3(i)]=pltsym(d2(i),d1(i));
    tt(i)=staname(i);
    text(x3(i)+0.05,y3(i)+0.05,tt(i),'FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom');
    text(x3(i),y3(i),pol(i),'FontSize',14,...
                            'FontWeight','bold',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle');
    end
    
%%    moremech 
    if length(isom) > 1
        
        for i=2:length(isom)
            nodal_lines_(s1m(i,1),di1m(i,1), r1m(i,1));
            P_T_axes_(s1m(i,1),di1m(i,1),r1m(i,1));
        end
        
%      make a file for GMT also
            if ispc
            fid = fopen('.\polarity\more_mech.gmt','w');
              for ii=2:length(isom)
                fprintf(fid,'%f %f %f %f %f %f %f\r\n',5 , 5, 5, s1m(ii,1),di1m(ii,1), r1m(ii,1),5);
              end
            fclose(fid);
            else
              fid = fopen('./polarity/more_mech.gmt','w');
              for ii=2:length(isom)
                fprintf(fid,'%f %f %f %f %f %f %f\r\n',5 , 5, 5, s1m(ii,1),di1m(ii,1), r1m(ii,1),5);
              end
            fclose(fid);
            end          
        
        
    else
    end
    
  plot(0,0,'+','MarkerSize',8)
  text (.6 ,1,['Source depth (km)  ' num2str(selected_depth)],'FontSize',14);  
  
%% prepare a GMT file also..!!
% write reference solution
%     if ispc
%     fid = fopen('.\polarity\ref_mech.gmt','w');
%         fprintf(fid,'%f %f %f %f %f %f %f\r\n',5 , 5, 5, s1(1,1), di1(1,1), r1(1,1),5);
%     fclose(fid);
%     else
%     fid = fopen('./polarity/ref_mech.gmt','w');
%         fprintf(fid,'%f %f %f %f %f %f %f\n',5 , 5, 5, s1(1,1), di1(1,1), r1(1,1),5);
%     fclose(fid);
%     end

% check if we have GMT 4 or 5
    gmt_ver=handles.gmt_ver;

%  mrr, mtt, mff, mrt, mrf, mtf
    harv=[(mrr/inv1_mom)*mfive;(mtt/inv1_mom)*mfive;(mff/inv1_mom)*mfive;(mrt/inv1_mom)*mfive;(mrf/inv1_mom)*mfive;(mtf/inv1_mom)*mfive];
    T = evalc('disp(harv)');
    start = regexp(T,'\n');
    Ta=T(1:start(1));
    format long
    Ta1=strrep(strrep(strrep(strrep(Ta,'+',' '),'*','  '),'e',' '),'E',' ');
    Atmp = sscanf(Ta1,'%f')  ;
    maxexp=Atmp(2);
    Tb=T((start(2)+1):length(T));
    harcof = sscanf(Tb,'%f',6);
    format
% write reference solution for non DC  mrr, mtt, mff, mrt, mrf, mtf in 10*exponent dynes-cm  exponent 
% fprintf(fid,'%g  %g  %g  %f  %f  %f  %f  %f  %f  %f  %g %g\r\n',5.5,5.5,5,harcof(1), harcof(2), harcof(3), harcof(4), harcof(5), harcof(6), maxexp+7 ,0,0);
    if ispc
    fid = fopen('.\polarity\ref_mech2.gmt','w');
    fprintf(fid,'%g  %g  %g  %f  %f  %f  %f  %f  %f  %f  %g %g\r\n',5,5,5,harcof(1), harcof(2), harcof(3), harcof(4), harcof(5), harcof(6), 23 , 0 ,0);
    fclose(fid);
    else
    fid = fopen('./polarity/ref_mech2.gmt','w');
     fprintf(fid,'%g  %g  %g  %f  %f  %f  %f  %f  %f  %f  %g %g\r\n',5,5,5,harcof(1), harcof(2), harcof(3), harcof(4), harcof(5), harcof(6), 23 , 0 ,0);
    fclose(fid);
    end
    
%% write batch

    if ispc
    
    fid = fopen('.\polarity\plot_pol_gmt.bat','w');
    if gmt_ver==4
        fprintf(fid,'%s\r\n', 'psmeca ref_mech2.gmt   -R0/10/0/10 -JX17c -Sm15c -K - a0.3c/cc  -ewhite  -t0.1p  -gblack   -W1p -Glightgray -T0 > pol_plot.ps'  );
    elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'psmeca ref_mech2.gmt   -R0/10/0/10 -JX17c -Sm15c -K -Fa0.3c/cc -Fewhite -Ft0.1p -Fgblack   -W1p -Glightgray -T0 > pol_plot.ps'  );
    end
   % fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt    -R0/10/0/10 -JX17c -Sa14.6c -K -O  -T0 -W1p >> pol_plot.ps'  );
    if length(isom) > 1
       if gmt_ver==4
        fprintf(fid,'%s\r\n', 'psmeca more_mech.gmt -R -J -Sa16.1c -T0 -K -O  -a0.3c/cc  -ewhite  -t0.1p  -gblack   -W1.p >> pol_plot.ps '  );
       elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'psmeca more_mech.gmt -R -J -Sa16.1c -T0 -K -O -Fa0.3c/cc -Fewhite -Ft0.1p -Fgblack   -W1.p >> pol_plot.ps '  );
       end
    else
    end
    fprintf(fid,'%s\r\n', 'gawk "{if (NR>1) print $1,$2,$3,$4}" mypol.dat > 4pspolar.txt');
    
    if gmt_ver==4
        fprintf(fid,'%s\r\n', 'pspolar 4pspolar.txt -R -J -N -Ss0.7c  -D5/5  -M15c  -e0.5p  -O -K -T0/0/5/18  >>  pol_plot.ps ');
    elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'pspolar 4pspolar.txt -R -J -N -Ss0.7c  -D5/5  -M15c  -Qe  -O -K -T0/0/5/18  >>  pol_plot.ps ');
    end
   % fprintf(fid,'%s\r\n', 'pstext ref_mech_text.gmt -R -J -O -K -m -N  >> csps_gmt_plot.ps '  );
   if gmt_ver==4 
        fprintf(fid,'%s\r\n', 'echo .5  2   | psxy -R -J -O  -K -Ss.6c -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.5 | psxy -R -J -O  -K -Ss.6c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.0 | psxy -R -J -O  -K -Sc.3c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  0.6 | psxy -R -J -O  -K -Sc.3c    -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 2.0 12 0 1 CM D, - | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.5 12 0 1 CM C, + | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.0 12 0 1 CM P    | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 0.6 12 0 1 CM T    | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 0.4 0.2 12 0 1 LM X - polarity not defined | pstext -R -J -O  -K   >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', ['echo 0.4 9.5 12 0 1 LM Source depth (km)  ' num2str(selected_depth)  ' | pstext -R -J -O     >> pol_plot.ps ']  );
        fprintf(fid,'%s\r\n', 'ps2raster pol_plot.ps -A -P -Tg '  );
   elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'echo .5  2   | psxy -R -J -O  -K -Ss.6c -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.5 | psxy -R -J -O  -K -Ss.6c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.0 | psxy -R -J -O  -K -Sc.3c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  0.6 | psxy -R -J -O  -K -Sc.3c    -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 2.0 D, - | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.5 C, + | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.0 P    | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 0.6 T    | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 0.4 0.2 X - polarity not defined | pstext -R -J -O -F+f12+jLM -K   >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', ['echo 0.4 9.5 Source depth (km)  ' num2str(selected_depth)  ' | pstext -R -J -O -F+f12+jLM    >> pol_plot.ps ']  );
        fprintf(fid,'%s\r\n', 'psconvert pol_plot.ps -A -P -Tg '  );
   end
    
  fclose(fid);

	
	disp('Check the  .\polarity\plot_pol_gmt.bat file for GMT plotting')

    %% 	
    else % Linux
    

	    disp('Not ready for Linux yet..!!')
        
    	% disp('Check the  ./polarity/plot_pol_gmt.bat file for GMT plotting')
    end
    
h = msgbox('A GMT batch file called plot_pol_gmt.bat was created in POLARITY folder. Run this file from a command window to get a high quality GMT plot.','GMT plot file.','help');

else %%% DC plot
% prepare a circle
disp('DC plot')

% PLOT
% prepare a circle

h1=figure; %('Renderer','zbuffer');
% THETA=linspace(0,2*pi,2000);
% RHO=ones(1,2000)*5;
% [X,Y] = pol2cart(THETA,RHO);
% X=X+10;
% Y=Y+10;
% plot(X,Y,'-k');

%circle([10,10],5,2000,'-'); 
mech=[s1(1,1) di1(1,1) r1(1,1)];

% plot of onemech.dat

bb([s1(1,1) di1(1,1) r1(1,1)],10,10,5,0,[138/255 138/255 138/255])    % plot beach ball
hold on
axis square;
axis off

%%% plot onemech P,T axis
for i=1:length(iso)
%     [x,y]=plpl(s1(i,1),di1(i,1));
%     plot(x,y,'r.-')
%     [x1,y1]=plpl(s2(i,1),di2(i,1));
%     plot(x1,y1,'r.-')
    [ax2,ay2]=pltsymdc(90-plungeP(i,1),aziP(i,1));
    plot(ax2,ay2,'Marker','s',...
                 'MarkerEdgeColor','b',...
                 'MarkerFaceColor','b')
    text(ax2(i)+0.1,ay2(i)+0.1,'P','FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom',...
                            'Color','b',...
                            'FontWeight','bold');
    [ax2,ay2]=pltsymdc(90-plungeT(i,1),aziT(i,1));
    plot(ax2,ay2,'Marker','o',...
                 'MarkerEdgeColor','y',...
                 'MarkerFaceColor','y')
    text(ax2(i)+0.1,ay2(i)+0.1,'T','FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom',...
                            'Color','y',...
                            'FontWeight','bold');
end

 
%plot polarities
for i=1:length(staname)
    [x3(i),y3(i)]=pltsymdc(d2(i),d1(i));
    tt(i)=staname(i);
    text(x3(i)+0.1,y3(i)+0.1,tt(i),'FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom');
    text(x3(i),y3(i),pol(i),'FontSize',14,...
                            'FontWeight','bold',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle');
% if pol{i,1} == 'U' || pol{i,1} == '+'
%     plot(x3(i),y3(i),'ks',...
%                      'MarkerEdgeColor','k',...
%                      'MarkerFaceColor',[0 0 0],...
%                      'MarkerSize',7,...
%                      'UserData','U')
%                      
% elseif pol{i,1} == 'D' || pol{i,1} == '-'
%     plot(x3(i),y3(i),'bo',...
%                      'UserData','D')
%              else 
%     plot(x3(i),y3(i),'go',...
%                      'UserData',pol{i,1})
% 
% end

end
% 
%%% plot moremech
%whos isom s1m


if length(isom) > 1
  for i=2:length(isom)
    [x,y]=plpldc(s1m(i,1),di1m(i,1));
    plot(x,y,'k')
    [x1,y1]=plpldc(s2m(i,1),di2m(i,1));
    plot(x1,y1,'k')
    [ax2m,ay2m]=pltsymdc(90-plungePm(i,1),aziPm(i,1));
    plot(ax2m,ay2m,'Marker','s',...
                 'MarkerEdgeColor','b',...
                 'MarkerFaceColor','b')
%     text(ax2m(i)+0.1,ay2m(i)+0.1,'P','FontSize',10,...
%                             'HorizontalAlignment','left',...
%                             'VerticalAlignment','bottom',...
%                             'Color','k');
    [ax2m,ay2m]=pltsymdc(90-plungeTm(i,1),aziTm(i,1));
    plot(ax2m,ay2m,'Marker','o',...
                 'MarkerEdgeColor','y',...)
                 'MarkerFaceColor','y')
%     text(ax2m(i)+0.1,ay2m(i)+0.1,'T','FontSize',10,...
%                             'HorizontalAlignment','left',...
%                             'VerticalAlignment','bottom',...
%                             'Color','k');
  end
%%  make a file for GMT also
        if ispc
            fid = fopen('.\polarity\more_mech.gmt','w');
              for i=2:length(isom)
                fprintf(fid,'%f %f %f %f %f %f %f\r\n',5 , 5, 5, s1m(i,1),di1m(i,1), r1m(i,1),5);
              end
            fclose(fid);
        else
              fid = fopen('./polarity/more_mech.gmt','w');
              for i=2:length(isom)
                fprintf(fid,'%f %f %f %f %f %f %f\r\n',5 , 5, 5, s1m(i,1),di1m(i,1), r1m(i,1),5);
              end
            fclose(fid);
        end

   
else
end

% h = legend('U','D',4); 
%legend
%
plot(10,10,'+','MarkerSize',8)
text (10,15.2,'0','FontSize',12);          
text (9.6,4.5,'180','FontSize',12);  
text (15.2,10,'90','FontSize',12);          
text (4. ,10,'270','FontSize',12);        
text (11 ,15.2,['Source depth (km)  ' num2str(selected_depth)],'FontSize',14);  

%% prepare a GMT file also..!!

% check if we have GMT 4 or 5
gmt_ver=handles.gmt_ver;
  
    
% write reference solution
if ispc
  fid = fopen('.\polarity\ref_mech.gmt','w');
    fprintf(fid,'%f %f %f %f %f %f %f\r\n',5 , 5, 5, s1(1,1), di1(1,1), r1(1,1),5);
  fclose(fid);
else
  fid = fopen('./polarity/ref_mech.gmt','w');
    fprintf(fid,'%f %f %f %f %f %f %f\n',5 , 5, 5, s1(1,1), di1(1,1), r1(1,1),5);
  fclose(fid);
end

% write batch
if ispc
    
  fid = fopen('.\polarity\plot_pol_gmt.bat','w');
    if gmt_ver==4
        fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -a0.3c/cc -ewhite -t0.1p -gblack   -W1p -Glightgray > pol_plot.ps'  );
        fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -O  -T0 -W1p >> pol_plot.ps'  );
    elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -Fa0.3c/cc -Fewhite -Ft0.1p -Fgblack   -W1p -Glightgray > pol_plot.ps'  );
        fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -O  -T0 -W1p >> pol_plot.ps'  );
    end
    
    if length(isom) > 1
        if gmt_ver==4
            fprintf(fid,'%s\r\n', 'psmeca more_mech.gmt -R -J -Sa15c -T0 -K -O -a0.3c/cc -ewhite -t0.1p -gblack   -W1.p >> pol_plot.ps '  );
        elseif gmt_ver==5
            fprintf(fid,'%s\r\n', 'psmeca more_mech.gmt -R -J -Sa15c -T0 -K -O -Fa0.3c/cc -Fewhite -Ft0.1p -Fgblack   -W1.p >> pol_plot.ps '  );
        end
    else
    end
    fprintf(fid,'%s\r\n', 'gawk "{if (NR>1) print $1,$2,$3,$4}" mypol.dat > 4pspolar.txt');
    if gmt_ver==4
        fprintf(fid,'%s\r\n', 'pspolar 4pspolar.txt -R -J -N -Ss0.7c  -D5/5  -M15c  -e0.5p  -O -K -T0/0/5/18  >>  pol_plot.ps ');
    elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'pspolar 4pspolar.txt -R -J -N -Ss0.7c  -D5/5  -M15c  -Qe  -O -K -T0/0/5/18  >>  pol_plot.ps ');
    end
   % fprintf(fid,'%s\r\n', 'pstext ref_mech_text.gmt -R -J -O -K -m -N  >> csps_gmt_plot.ps '  );
   if gmt_ver==4 
        fprintf(fid,'%s\r\n', 'echo .5  2   | psxy -R -J -O  -K -Ss.6c -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.5 | psxy -R -J -O  -K -Ss.6c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.0 | psxy -R -J -O  -K -Sc.3c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  0.6 | psxy -R -J -O  -K -Sc.3c    -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 2.0 12 0 1 CM D, - | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.5 12 0 1 CM C, + | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.0 12 0 1 CM P    | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 0.6 12 0 1 CM T    | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 0.4 0.2 12 0 1 LM X - polarity not defined | pstext -R -J -O  -K   >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', ['echo 0.4 9.5 12 0 1 LM Source depth (km)  ' num2str(selected_depth)  ' | pstext -R -J -O     >> pol_plot.ps ']  );
        fprintf(fid,'%s\r\n', 'ps2raster pol_plot.ps -A -P -Tg '  );
   elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'echo .5  2   | psxy -R -J -O  -K -Ss.6c -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.5 | psxy -R -J -O  -K -Ss.6c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.0 | psxy -R -J -O  -K -Sc.3c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  0.6 | psxy -R -J -O  -K -Sc.3c    -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 2.0 D, - | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.5 C, + | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.0 P    | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 0.6 T    | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 0.4 0.2 X - polarity not defined | pstext -R -J -O -F+f12+jLM -K   >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', ['echo 0.4 9.5 Source depth (km)  ' num2str(selected_depth)  ' | pstext -R -J -O -F+f12+jLM    >> pol_plot.ps ']  );
        fprintf(fid,'%s\r\n', 'psconvert pol_plot.ps -A -P -Tg '  );
   end
    
  fclose(fid);
	
	disp('Check the  .\polarity\plot_pol_gmt.bat file for GMT plotting')
 	
else  % Linux

disp('not tested for Linux yet..!!')


  fid = fopen('./polarity/plot_pol_gmt.bat','w');
    if gmt_ver==4
        fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -a0.3c/cc -ewhite -t0.1p -gblack   -W1p -Glightgray > pol_plot.ps'  );
        fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -O  -T0 -W1p >> pol_plot.ps'  );
    elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -Fa0.3c/cc -Fewhite -Ft0.1p -Fgblack   -W1p -Glightgray > pol_plot.ps'  );
        fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -O  -T0 -W1p >> pol_plot.ps'  );
    end
    
    if length(isom) > 1
        if gmt_ver==4
            fprintf(fid,'%s\r\n', 'psmeca more_mech.gmt -R -J -Sa15c -T0 -K -O -a0.3c/cc -ewhite -t0.1p -gblack   -W1.p >> pol_plot.ps '  );
        elseif gmt_ver==5
            fprintf(fid,'%s\r\n', 'psmeca more_mech.gmt -R -J -Sa15c -T0 -K -O -Fa0.3c/cc -Fewhite -Ft0.1p -Fgblack   -W1.p >> pol_plot.ps '  );
        end
    else
    end
    fprintf(fid,'%s\r\n', 'gawk "{if (NR>1) print $1,$2,$3,$4}" mypol.dat > 4pspolar.txt');
    if gmt_ver==4
        fprintf(fid,'%s\r\n', 'pspolar 4pspolar.txt -R -J -N -Ss0.7c  -D5/5  -M15c  -e0.5p  -O -K -T0/0/5/18  >>  pol_plot.ps ');
    elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'pspolar 4pspolar.txt -R -J -N -Ss0.7c  -D5/5  -M15c  -Qe  -O -K -T0/0/5/18  >>  pol_plot.ps ');
    end
   % fprintf(fid,'%s\r\n', 'pstext ref_mech_text.gmt -R -J -O -K -m -N  >> csps_gmt_plot.ps '  );
   if gmt_ver==4 
        fprintf(fid,'%s\r\n', 'echo .5  2   | psxy -R -J -O  -K -Ss.6c -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.5 | psxy -R -J -O  -K -Ss.6c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.0 | psxy -R -J -O  -K -Sc.3c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  0.6 | psxy -R -J -O  -K -Sc.3c    -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 2.0 12 0 1 CM D, - | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.5 12 0 1 CM C, + | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.0 12 0 1 CM P    | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 0.6 12 0 1 CM T    | pstext -R -J -O  -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 0.4 0.2 12 0 1 LM X - polarity not defined | pstext -R -J -O  -K   >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', ['echo 0.4 9.5 12 0 1 LM Source depth (km)  ' num2str(selected_depth)  ' | pstext -R -J -O     >> pol_plot.ps ']  );
        fprintf(fid,'%s\r\n', 'ps2raster pol_plot.ps -A -P -Tg '  );
   elseif gmt_ver==5
        fprintf(fid,'%s\r\n', 'echo .5  2   | psxy -R -J -O  -K -Ss.6c -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.5 | psxy -R -J -O  -K -Ss.6c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  1.0 | psxy -R -J -O  -K -Sc.3c  -Gblack  >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo .5  0.6 | psxy -R -J -O  -K -Sc.3c    -W0.5p >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 2.0 D, - | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.5 C, + | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 1.0 P    | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 1.0 0.6 T    | pstext -R -J -O -F+f12+jCM -K >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', 'echo 0.4 0.2 X - polarity not defined | pstext -R -J -O -F+f12+jLM -K   >> pol_plot.ps '  );
        fprintf(fid,'%s\r\n', ['echo 0.4 9.5 Source depth (km)  ' num2str(selected_depth)  ' | pstext -R -J -O -F+f12+jLM    >> pol_plot.ps ']  );
        fprintf(fid,'%s\r\n', 'psconvert pol_plot.ps -A -P -Tg '  );
   end
    
  fclose(fid);
	
	disp('Check the  ./polarity/plot_pol_gmt.bat file for GMT plotting')
end



h = msgbox('A GMT batch file called plot_pol_gmt.bat was created in POLARITY folder. Run this file from a command window to get a high quality GMT plot.','GMT plot file.','help');
    
    
end




% --- Executes on button press in addpol.
function addpol_Callback(hObject, eventdata, handles)
% hObject    handle to addpol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check if polarity exists..!
h=dir('polarity');

if isempty(h);
    errordlg('Polarity folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

try
cd polarity

h=dir('station.dat');

if isempty(h); 
  errordlg('Station.dat file doesn''t exist. Run Station select. ','File Error');
  return
else
   if ispc
    dos('notepad station.dat &')
   else
    unix('gedit station.dat &')
   end
    
end

cd ..

catch
cd ..
end

%% Copy files also
%%% Copy inv2.dat from invert to polarity and rename to onemech.dat


cd polarity

disp('Copying inv2.dat from INVERT folder')
if ispc
 [s,mess,messid]=copyfile('..\invert\inv2.dat','.\onemech.tmp');
else
 [s,mess,messid]=copyfile('../invert/inv2.dat','./onemech.tmp');
end
if s== 1
    disp('Copied inv2.dat in POLARITY folder as onemech.dat')
end

if ispc
 [s,mess,messid]=copyfile('..\invert\inv2.dat','.\moremech.dat');
else
 [s,mess,messid]=copyfile('../invert/inv2.dat','./moremech.dat');
end

if s== 1
    disp('Copied inv2.dat in POLARITY folder as moremech.dat')
    disp('Check the manual for the use of these files')
end
%%%now we have to leave just one subevent in onemech.tmp....
      fid  = fopen('onemech.tmp','r');
      fid2 = fopen('onemech.dat','w');
                        tline = fgets(fid);
                        fprintf(fid2,'%s', tline); 
      fclose(fid);               
      fclose(fid2);
delete('onemech.tmp')

cd ..

%%
% handles on
on =[handles.plpol];
enableon(on)




% --- Executes on button press in check2.
function check2_Callback(hObject, eventdata, handles)
% hObject    handle to check2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check2


% --- Executes on button press in inv1.
function inv1_Callback(hObject, eventdata, handles)
% hObject    handle to inv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
eventid=handles.eventid;
%%  plot results in GMT ..using inv1.dat


% check if we have GMT 4 or 5
gmt_ver=handles.gmt_ver;

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
          title=':"Correlation"::."Correlation vs Source position Plot"';
 
     elseif strcmp(tsource,'depth')
         disp('Inversion was done for a line of sources under epicenter.')
          nsources=fscanf(fid,'%i',1);
          distep=fscanf(fid,'%f',1);
          sdepth=fscanf(fid,'%f',1);
          title=':"Correlation"::."Correlation vs Depth Plot"';
          
     elseif strcmp(tsource,'plane')
         disp('Inversion was done for a plane of sources.')
          nsources=fscanf(fid,'%i',1);
          distep=fscanf(fid,'%f',1);
          sdepth=fscanf(fid,'%f',1);
          title=':"Correlation"::."Correlation vs Source position Plot"';
         
     elseif strcmp(tsource,'point')
          disp('Inversion was done for one source. Ploting is not available.')
          warndlg('Inversion was done for one source. Ploting is not available','!! Warning !!')
          return
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
          
     end
    
    fclose(fid);
end


%% 
%check if INVERT exists..!
h=dir('invert');

if isempty(h) 
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%
cd invert

% read how many subevents we have   
    [id,tstep,nsources,tshifts,nsub,freq,var] = readinpinv('inpinv.dat');

    
    q1=['Inversion was run with ' num2str(nsub) ' subevents. Select which one you want to use ?'];
    
    if nsub~=1
       prompt = {q1}; dlg_title = 'Input subevent number for plotting.'; num_lines = 1; defaultans = {'1'};
       answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
       disp(['Selected subevent is ' num2str(cell2mat(answer))])
       selsub=str2double(cell2mat(answer));
    else
       selsub= 1;
    end
    
    
%% old code
% 
% h=dir('inv1.dat');    % It will read the first subevent only......
% 
% if isempty(h); 
%     errordlg('inv1.dat file doesn''t exist. Run Invert. ','File Error');
%     cd ..
%   return    
% else
%     fid = fopen('inv1.dat','r');
%        line=fgets(fid);        %01 line
%        line=fgets(fid);         %02 line
%        line=fgets(fid);        %03 line
% %%%%%%%%%%%%  sourcepos, time, varred, moment,dc , str1,dip1,rake1,str2,dip2,rake2
%        a=fscanf(fid,'%f %f %f %e %f %f %f %f %f %f %f',[11 nsources]);
%             linetmp=fgets(fid);         %01 line
%             linetmp=fgets(fid);         %01 line
%             linetmp=fgets(fid);         %01 line
%             linetmp=fgets(fid);         %01 line
%             linetmp=fgets(fid);         %01 line
%             linetmpf=fgets(fid);        %01 line
%             eigen=fscanf(fid,'%f %f %f',3);
%        a=a';
%     fclose(fid);
% end
%% old code
[~,~,~,~,~,~,~,~,~,~,~,~,cor_src]=readinv1new('inv1.dat',nsources,selsub);
a=cor_src';

%%
%   Calculate Mw 
%   mommag =(2.0/3.0)*log10(mo(psrcpos)) - 6.0333;  % changed 06/11/2020 

    a(:,4)=(2.0/3.0)*log10(a(:,4))-6.0333;         % %! Hanks & Kanamori (1979)
  
    r1= min(a);   r2= max(a);
  
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     if r2(3) < 0.1
       vstep=0.02;
     elseif r2(3)>= 0.1 && r2(3) <= 0.2
       vstep=0.05;
     else
       vstep=0.1;
     end
     
%%
if  strcmp(tsource,'depth')          % X axis as depth....distep  ~= -1000.0 
     hstep=distep;

     %%% prepare a gmt style file for source vs correlation plotting 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(tsource,'depth')
        %  Use Depth for X axis
         dep=((a(:,1)-1)*distep)+sdepth; 
        else
         dep=a(:,1);   %Use source number
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      fid = fopen('inv1.gmt','w');
        for i=1:nsources
            if ispc
               fprintf(fid,'%g  %g\r\n',dep(i),a(i,3));
            else
               fprintf(fid,'%g  %g\n',dep(i),a(i,3));
            end
        end
      fclose(fid);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  disabled ....
%    fid = fopen('inv1text.gmt','w');
%          fprintf(fid,'%g  %g  %g   %g  %g  %s  %s  %f\r\n',dep(round(nsources/2)),r2(3)+0.1,12,0,1,'CM','Condition number (min/max eigenvalue ratio): ',eigen(3) );
% fprintf(fid,'%g  %g  %g   %g  %g  %s  %f\r\n',2,r2(3)+0.06,12,0,1,'CM',eigen(3) );
%    fclose(fid);
%
% prepare a gmt style file for best moment tensor
     fid = fopen('inv1.foc','w');
         for i=1:nsources
          % enable to plot  shift time above beachball       fprintf(fid,'%g  %g  %g  %g  %g   %g  %g  %g  %g  %g\r\n',a(i,1),a(i,3),a(i,5),a(i,6),a(i,7),a(i,8), a(i,4),0,0,a(i,2)*tstep);
          % fprintf(fid,'%g  %g  %g  %g  %g   %g  %g  %g  %g  %g\r\n',dep(i),a(i,3),a(i,5),a(i,6),a(i,7),a(i,8), a(i,4),0,0, round(a(i,5)) ); 
          % enable to plot nothing 
           if ispc 
            fprintf(fid,'%g  %g  %g  %g  %g   %g  %g  %g  %g\r\n',dep(i),a(i,3),a(i,5),a(i,6),a(i,7),a(i,8), a(i,4),0,0);  
           else
            fprintf(fid,'%g  %g  %g  %g  %g   %g  %g  %g  %g\n',dep(i),a(i,3),a(i,5),a(i,6),a(i,7),a(i,8), a(i,4),0,0);  
           end
            
         end
     fclose(fid);
%  read scale ..X, Y
scalex  = get(handles.scalex,'String');
scaley  = get(handles.scaley,'String');

bbscale  = get(handles.bbscale,'String');

disp('  ')
disp('  ')
disp('Creating gmt batch file')
pwd
disp('  ')
disp('  ')


if ispc
%%%%%%%%%%%%%%% PREPARE THE GMT FILE    
  fid = fopen('plinv1.bat','w');
      fprintf(fid,'%s\r\n','del .gmtdefaults4 .gmtcommands4');
      
      if gmt_ver==4
        fprintf(fid,'%s\r\n','gmtset PAPER_MEDIA A4 HEADER_FONT_SIZE 18 LABEL_FONT_SIZE 16 ANNOT_FONT_SIZE_PRIMARY 12');
      else
        fprintf(fid,'%s\r\n','gmtset PS_MEDIA A4 FONT_TITLE 18 FONT_LABEL 16 FONT_ANNOT_PRIMARY 12');
      end
      
      fprintf(fid,'%s\r\n','   ');
      fprintf(fid,'%s\r\n','makecpt -Cno_green -T0/100/10 > inv1.cpt');
      fprintf(fid,'%s\r\n','   ');
      % 0 to max correlation     
      if gmt_ver==4
         fprintf(fid,'%s\r\n',['psxy   -R' num2str(min(dep)-1) '/' num2str(max(dep)+1) '/' num2str(r1(3)-0.1) '/' num2str(r2(3)+0.1)  ' -JX' scalex 'c/' scaley 'c inv1.gmt  -W2.5p/0/0/0,- -K -B' num2str(hstep) 'g1:"Depth (km)":/' num2str(vstep) 'g' num2str(vstep) title  ':WeSn > ' eventid  '_inv1.ps']);
         fprintf(fid,'%s\r\n',['psmeca -R -J  -Sa' bbscale 'c/12 -K -O inv1.foc -V -Zinv1.cpt  >> ' eventid  '_inv1.ps']);
      else
         fprintf(fid,'%s\r\n',['psxy   -R' num2str(min(dep)-1) '/' num2str(max(dep)+1) '/' num2str(r1(3)-0.1) '/' num2str(r2(3)+0.1)  ' -JX' scalex 'c/' scaley 'c inv1.gmt  -W2.5p,black,- -K -B' num2str(hstep) 'g1:"Depth (km)":/' num2str(vstep) 'g' num2str(vstep) title  ':WeSn > ' eventid  '_inv1.ps']);
         fprintf(fid,'%s\r\n',['psmeca -R -J  -Sa' bbscale 'c/12 -K -O inv1.foc -V -Cinv1.cpt  >> ' eventid  '_inv1.ps']);
      end
% fixed correlation
%     fprintf(fid,'%s\r\n',['psxy   -R' num2str(min(dep)-1) '/' num2str(max(dep)+1) '/0.4/1  -JX' scalex 'c/' scaley 'c' '  inv1.gmt -W1.5p/0/0/0,- -K -B' num2str(hstep) 'g1:"Depth (km)":/' num2str(vstep) 'g' num2str(vstep) ':"Correlation":WeSn > inv1.ps']);
% read beachball scale feature added 11/12/2013

      fprintf(fid,'%s\r\n',['psmeca -R -J  -Sa' bbscale 'c/12 -K -O inv1.foc -V -T >> ' eventid  '_inv1.ps']);
% disable condition number plotting     fprintf(fid,'%s\r\n',['pstext -R -JX inv1text.gmt -K -O  -V -N >> inv1.ps']);
      fprintf(fid,'%s\r\n',['psscale -D25c/4c/8c/0.5c -O -Cinv1.cpt -B::/:DC\045: >> ' eventid  '_inv1.ps']);
      fprintf(fid,'%s\r\n','   ');
      if gmt_ver==4
        fprintf(fid,'%s\r\n',['ps2raster ' eventid  '_inv1.ps -Tg -P   -D..\output']);
      else
        fprintf(fid,'%s\r\n',['psconvert ' eventid  '_inv1.ps -Tg -P   -D..\output']);
      end      
      %%% Clean up move to gmtfiles folder instead of keeping in invert
      fprintf(fid,'%s\r\n',[' copy '  eventid  '_inv1.ps ..\output']);
      fprintf(fid,'%s\r\n','move inv1.cpt ..\gmtfiles');
      fprintf(fid,'%s\r\n','move inv1.gmt ..\gmtfiles');
      fprintf(fid,'%s\r\n','move inv1.foc ..\gmtfiles');
      fprintf(fid,'%s\r\n','move plinv1.bat ..\gmtfiles');
  fclose(fid);
else % linux
  fid = fopen('plinv1.bat','w');
      fprintf(fid,'%s\n','rm .gmtdefaults4 .gmtcommands4');
      if gmt_ver==4
        fprintf(fid,'%s\n','gmtset PAPER_MEDIA A4 HEADER_FONT_SIZE 18 LABEL_FONT_SIZE 16 ANNOT_FONT_SIZE_PRIMARY 12');
      else
        fprintf(fid,'%s\n','gmtset PS_MEDIA A4 FONT_TITLE 18 FONT_LABEL 16 FONT_ANNOT_PRIMARY 12');
      end
      fprintf(fid,'%s\n','   ');
      fprintf(fid,'%s\n','makecpt -Cno_green -T0/100/10 > inv1.cpt');
      fprintf(fid,'%s\n','   ');
      % 0 to max correlation     
      if gmt_ver==4
         fprintf(fid,'%s\n',['psxy   -R' num2str(min(dep)-1) '/' num2str(max(dep)+1) '/' num2str(r1(3)-0.1) '/' num2str(r2(3)+0.1)  ' -JX' scalex 'c/' scaley 'c inv1.gmt  -W2.5p/0/0/0,- -K -B' num2str(hstep) 'g1:"Depth (km)":/' num2str(vstep) 'g' num2str(vstep) title  ':WeSn > ' eventid  '_inv1.ps']);
         fprintf(fid,'%s\n',['psmeca -R -J  -Sa' bbscale 'c/12 -K -O inv1.foc -V -Zinv1.cpt  >> ' eventid  '_inv1.ps']);
      else
         fprintf(fid,'%s\n',['psxy   -R' num2str(min(dep)-1) '/' num2str(max(dep)+1) '/' num2str(r1(3)-0.1) '/' num2str(r2(3)+0.1)  ' -JX' scalex 'c/' scaley 'c inv1.gmt  -W2.5p,black,- -K -B' num2str(hstep) 'g1:"Depth (km)":/' num2str(vstep) 'g' num2str(vstep) title  ':WeSn > ' eventid  '_inv1.ps']);
         fprintf(fid,'%s\n',['psmeca -R -J  -Sa' bbscale 'c/12 -K -O inv1.foc -V -Cinv1.cpt  >> ' eventid  '_inv1.ps']);
      end% fixed correlation
%     fprintf(fid,'%s\r\n',['psxy   -R' num2str(min(dep)-1) '/' num2str(max(dep)+1) '/0.4/1  -JX' scalex 'c/' scaley 'c' '  inv1.gmt -W1.5p/0/0/0,- -K -B' num2str(hstep) 'g1:"Depth (km)":/' num2str(vstep) 'g' num2str(vstep) ':"Correlation":WeSn > inv1.ps']);
%
      fprintf(fid,'%s\n',['psmeca -R -J  -Sa' bbscale 'c/12 -K -O inv1.foc -V -T >> ' eventid  '_inv1.ps']);
% disable condition number plotting     fprintf(fid,'%s\r\n',['pstext -R -JX inv1text.gmt -K -O  -V -N >> inv1.ps']);
      fprintf(fid,'%s\n',['psscale -D25c/4c/8c/0.5c -O -Cinv1.cpt -B::/:DC\045: >> ' eventid  '_inv1.ps']);
      fprintf(fid,'%s\n','   ');
      if gmt_ver==4
        fprintf(fid,'%s\n',['ps2raster ' eventid  '_inv1.ps -Tg -P   -D../output']);
      else
        fprintf(fid,'%s\n',['psconvert ' eventid  '_inv1.ps -Tg -P   -D../output']);
      end
      %%% Clean up
%       fprintf(fid,'%s\n','   ');
%       fprintf(fid,'%s\n','rm inv1.cpt inv1.gmt inv1.foc');
      %%% Clean up move to gmtfiles folder instead of keeping in invert
      fprintf(fid,'%s\r\n',[' cp '  eventid  '_inv1.ps ../output']);
      fprintf(fid,'%s\r\n','mv inv1.cpt ../gmtfiles');
      fprintf(fid,'%s\r\n','mv inv1.gmt ../gmtfiles');
      fprintf(fid,'%s\r\n','mv inv1.foc ../gmtfiles');
      fprintf(fid,'%s\r\n','mv plinv1.bat ../gmtfiles');
  fclose(fid);
end % linux
   
else          %%%%%X axis as source number  ....
%%  horizontal step
     if nsources <= 10
       hstep=1;
     elseif nsources >= 10 && nsources <= 20
       hstep=2;
     elseif nsources >  20 && nsources <= 40
       hstep=5;
     else
       hstep=10;
     end
     
 %%% prepare a gmt style file for source vs correlation plotting 
    fid = fopen('inv1.gmt','w');
       for i=1:nsources
         if ispc  
          fprintf(fid,'%g  %g\r\n',a(i,1),a(i,3));
         else
          fprintf(fid,'%g  %g\n',a(i,1),a(i,3));
         end
      end
    fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  disabled ....
%    fid = fopen('inv1text.gmt','w');
%          fprintf(fid,'%g  %g  %g   %g  %g  %s  %s  %f\r\n',nsources/2,r2(3)+0.2,12,0,1,'CM','Condition number (min/max eigenvalue ratio): ',eigen(3) );
% fprintf(fid,'%g  %g  %g   %g  %g  %s  %f\r\n',2,r2(3)+0.06,12,0,1,'CM',eigen(3) );
%    fclose(fid);
%%% prepare a gmt style file for best moment tensor

    fid = fopen('inv1.foc','w');
      for i=1:nsources
%%% enable to plot  shift time above beachball       fprintf(fid,'%g  %g  %g  %g  %g   %g  %g  %g  %g  %g\r\n',a(i,1),a(i,3),a(i,5),a(i,6),a(i,7),a(i,8), a(i,4),0,0,a(i,2)*tstep);
%fprintf(fid,'%g  %g  %g  %g  %g   %g  %g  %g  %g  %g\r\n',dep(i),a(i,3),a(i,5),a(i,6),a(i,7),a(i,8), a(i,4),0,0, round(a(i,5)) ); 
%%enable to plot nothing 
        if ispc
          fprintf(fid,'%g  %g  %g  %g  %g   %g  %g  %g  %g\r\n',a(i,1),a(i,3),a(i,5),a(i,6),a(i,7),a(i,8), a(i,4),0,0);  
        else
          fprintf(fid,'%g  %g  %g  %g  %g   %g  %g  %g  %g\n',a(i,1),a(i,3),a(i,5),a(i,6),a(i,7),a(i,8), a(i,4),0,0);  
        end
      end
    fclose(fid);
% read scale ..X, Y
scalex  = get(handles.scalex,'String');
scaley  = get(handles.scaley,'String');

if ispc
%%%%%%%%%%%%%%%%%%   
  fid = fopen('plinv1.bat','w');
      fprintf(fid,'%s\r\n','del .gmtdefaults4 .gmtcommands4');
      
      if gmt_ver==4
        fprintf(fid,'%s\r\n','gmtset PAPER_MEDIA A4 HEADER_FONT_SIZE 18 LABEL_FONT_SIZE 16 ANNOT_FONT_SIZE_PRIMARY 12');
      else
        fprintf(fid,'%s\r\n','gmtset PS_MEDIA A4 FONT_TITLE 18 FONT_LABEL 16 FONT_ANNOT_PRIMARY 12');
      end
      
      fprintf(fid,'%s\r\n','   ');
      fprintf(fid,'%s\r\n','makecpt -Cno_green -T0/100/10 > inv1.cpt');
      fprintf(fid,'%s\r\n','   ');
% 0 to max correlation     
      if gmt_ver==4
         fprintf(fid,'%s\r\n',['psxy   -R' num2str(r1(1)-1) '/' num2str(r2(1)+1) '/' num2str(r1(3)-0.1) '/' num2str(r2(3)+0.1)  ' -JX' scalex 'c/' scaley 'c inv1.gmt  -W2.5p/0/0/0,- -K -B' num2str(hstep) 'g1:"Source number":/' num2str(vstep) 'g' num2str(vstep) ':"Correlation"::."Correlation vs Source number Plot":WeSn > ' eventid  '_inv1.ps']);
         fprintf(fid,'%s\r\n',['psmeca -R -J  -Sa1.3c/12 -K -O inv1.foc -V -Zinv1.cpt  >> ' eventid  '_inv1.ps']);
      else
         fprintf(fid,'%s\r\n',['psxy   -R' num2str(r1(1)-1) '/' num2str(r2(1)+1) '/' num2str(r1(3)-0.1) '/' num2str(r2(3)+0.1)  ' -JX' scalex 'c/' scaley 'c inv1.gmt  -W2.5p,black,- -K -B' num2str(hstep) 'g1:"Source number":/' num2str(vstep) 'g' num2str(vstep) ':"Correlation"::."Correlation vs Source number Plot":WeSn > ' eventid  '_inv1.ps']);
         fprintf(fid,'%s\r\n',['psmeca -R -J  -Sa1.3c/12 -K -O inv1.foc -V -Cinv1.cpt  >> ' eventid  '_inv1.ps']);
      end
      
% fixed correlation
%     fprintf(fid,'%s\r\n',['psxy   -R' num2str(min(dep)-1) '/' num2str(max(dep)+1) '/0.4/1  -JX' scalex 'c/' scaley 'c' '  inv1.gmt -W1.5p/0/0/0,- -K -B' num2str(hstep) 'g1:"Depth (km)":/' num2str(vstep) 'g' num2str(vstep) ':"Correlation":WeSn > inv1.ps']);
%%%%

      fprintf(fid,'%s\r\n',['psmeca -R -J  -Sa1.3c/12 -K -O inv1.foc -V -T >> ' eventid  '_inv1.ps']);
% disable condition number plotting     fprintf(fid,'%s\r\n',['pstext -R -JX inv1text.gmt -K -O  -V -N >> inv1.ps']);
      fprintf(fid,'%s\r\n',['psscale -D25c/4c/8c/0.5c -O -Cinv1.cpt -B::/:DC\045: >> ' eventid  '_inv1.ps']);
      %%% Clean up
      fprintf(fid,'%s\r\n','   ');
      fprintf(fid,'%s\r\n','del inv1.cpt inv1.gmt inv1.foc');
      fprintf(fid,'%s\r\n','   ');
      if gmt_ver==4
        fprintf(fid,'%s\r\n',['ps2raster ' eventid  '_inv1.ps -Tg -P   -D..\output']);
      else
        fprintf(fid,'%s\r\n',['psconvert ' eventid  '_inv1.ps -Tg -P   -D..\output']);
      end
   fclose(fid);
else  % linux
  fid = fopen('plinv1.bat','w');
      fprintf(fid,'%s\n','del .gmtdefaults4 .gmtcommands4');
      
      if gmt_ver==4
        fprintf(fid,'%s\n','gmtset PAPER_MEDIA A4 HEADER_FONT_SIZE 18 LABEL_FONT_SIZE 16 ANNOT_FONT_SIZE_PRIMARY 12');
      else
        fprintf(fid,'%s\n','gmtset PS_MEDIA A4 FONT_TITLE 18 FONT_LABEL 16 FONT_ANNOT_PRIMARY 12');
      end
      
      fprintf(fid,'%s\n','   ');
      fprintf(fid,'%s\n','makecpt -Cno_green -T0/100/10 > inv1.cpt');
      fprintf(fid,'%s\n','   ');
% 0 to max correlation     
      if gmt_ver==4
         fprintf(fid,'%s\n',['psxy   -R' num2str(r1(1)-1) '/' num2str(r2(1)+1) '/' num2str(r1(3)-0.1) '/' num2str(r2(3)+0.1)  ' -JX' scalex 'c/' scaley 'c inv1.gmt  -W2.5p/0/0/0,- -K -B' num2str(hstep) 'g1:"Source number":/' num2str(vstep) 'g' num2str(vstep) ':"Correlation"::."Correlation vs Source number Plot":WeSn > ' eventid  '_inv1.ps']);
         fprintf(fid,'%s\n',['psmeca -R -J  -Sa1.3c/12 -K -O inv1.foc -V -Zinv1.cpt  >> ' eventid  '_inv1.ps']);
      else
         fprintf(fid,'%s\n',['psxy   -R' num2str(r1(1)-1) '/' num2str(r2(1)+1) '/' num2str(r1(3)-0.1) '/' num2str(r2(3)+0.1)  ' -JX' scalex 'c/' scaley 'c inv1.gmt  -W2.5p,black,- -K -B' num2str(hstep) 'g1:"Source number":/' num2str(vstep) 'g' num2str(vstep) ':"Correlation"::."Correlation vs Source number Plot":WeSn > ' eventid  '_inv1.ps']);
         fprintf(fid,'%s\n',['psmeca -R -J  -Sa1.3c/12 -K -O inv1.foc -V -Cinv1.cpt  >> ' eventid  '_inv1.ps']);
      end
      
% fixed correlation
%     fprintf(fid,'%s\r\n',['psxy   -R' num2str(min(dep)-1) '/' num2str(max(dep)+1) '/0.4/1  -JX' scalex 'c/' scaley 'c' '  inv1.gmt -W1.5p/0/0/0,- -K -B' num2str(hstep) 'g1:"Depth (km)":/' num2str(vstep) 'g' num2str(vstep) ':"Correlation":WeSn > inv1.ps']);
%%%%
      fprintf(fid,'%s\n',['psmeca -R -J  -Sa1.3c/12 -K -O inv1.foc -V -T >> ' eventid  '_inv1.ps']);
% disable condition number plotting     fprintf(fid,'%s\r\n',['pstext -R -JX inv1text.gmt -K -O  -V -N >> inv1.ps']);
      fprintf(fid,'%s\n',['psscale -D25c/4c/8c/0.5c -O -Cinv1.cpt -B::/:DC\045: >> ' eventid  '_inv1.ps']);
      %%% Clean up
      fprintf(fid,'%s\n','   ');
      fprintf(fid,'%s\n','del inv1.cpt inv1.gmt inv1.foc');
      fprintf(fid,'%s\n','   ');
      if gmt_ver==4
        fprintf(fid,'%s\n',['ps2raster ' eventid  '_inv1.ps -Tg -P   -D../output']);
      else
        fprintf(fid,'%s\n',['psconvert ' eventid  '_inv1.ps -Tg -P   -D../output']);
      end
  fclose(fid);
    
end % linux
    
 end  %%% end of IF for X axis style
 
%%% run batch file...
if ispc
   [s,r]=system('plinv1.bat'); 
else
    !chmod +x plinv1.bat
    !./plinv1.bat
end

cd ..%%% return to main folder before plotting.... this should solve problems if user tried to plot waveforms before closing ps file...

eventid 

%aa=['gsview32 .\invert\' eventid  '_inv1.ps']

% read the gsview version from defaults
psview=handles.psview;
% 
if ispc
    try 
      system([psview ' .\invert\' eventid  '_inv1.ps']);
    catch exception 
        disp(exception.message)
    end
else
    system([psview ' ./invert/' eventid  '_inv1.ps']);
end

pwd



% 
%catch
%       cd ..
%end

  
% --- Executes on button press in checkinv1.
function checkinv1_Callback(hObject, eventdata, handles)
% hObject    handle to checkinv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if INVERT exists..!
h=dir('invert');

if isempty(h);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


try
cd invert

h=dir('inv1.dat');

if isempty(h); 
  errordlg('Inv1.dat file doesn''t exist. Run Inversion. ','File Error');
  return
else
  if ispc
    dos('notepad inv1.dat &')
    dos('notepad inv2.dat &')
    dos('notepad inv2c.dat &')
%    dos('notepad inv3.dat &')
%    dos('notepad inv4.dat &')
  else
    unix('gedit inv1.dat &')
    unix('gedit inv2.dat &')
    unix('gedit inv2c.dat &')
  end
end

cd ..

catch
cd ..
end

% 
% function toptitle(string)
% %%%based on Graphics and GUIS with Matlab
% 
% titlepos=[.5 1];
% ax=gca;
% set(ax,'units','normalized');
% axpos = get(ax,'position');
% offset = (titlepos - axpos(1:2))./axpos(3:4);
% 
% text(offset(1),offset(2),string,'units','normalized',...
%     'horizontalalignment','center','verticalalignment','middle');
% 
% h=findobj(gcf,'type','axes');
% set(h,'units','points');
% figpos = get(gcf,'position');
% set(gcf,'postition',figpos + [0 0 0 15])
% set(gcf,'units', 'pixels');
% set(h,'units','normalized');
% 




% --- Executes during object creation, after setting all properties.
function scalex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scalex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function scalex_Callback(hObject, eventdata, handles)
% hObject    handle to scalex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scalex as text
%        str2double(get(hObject,'String')) returns contents of scalex as a double


% --- Executes during object creation, after setting all properties.
function scaley_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaley (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function scaley_Callback(hObject, eventdata, handles)
% hObject    handle to scaley (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaley as text
%        str2double(get(hObject,'String')) returns contents of scaley as a double


% --- Executes on button press in maketxt.
function maketxt_Callback(hObject, eventdata, handles)
% hObject    handle to maketxt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: get(hObject,'Value') returns toggle state of maketxt
% --- Executes on button press in editmech.
function editmech_Callback(hObject, eventdata, handles)
% hObject    handle to editmech (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  
if get(handles.autocopy,'Value') == 1

%%% Copy inv2.dat from invert to polarity and rename to onemech.dat

h=dir('polarity');

if isempty(h);
    errordlg('Polarity folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

try

cd polarity

disp('Copying inv2.dat from INVERT folder')
if ispc
 [s,mess,messid]=copyfile('..\invert\inv2.dat','.\onemech.tmp');
else
 [s,mess,messid]=copyfile('../invert/inv2.dat','./onemech.tmp');
end
if s== 1
    disp('Copied inv2.dat in POLARITY folder as onemech.dat')
end

if ispc
 [s,mess,messid]=copyfile('..\invert\inv2.dat','.\moremech.dat');
else
 [s,mess,messid]=copyfile('../invert/inv2.dat','./moremech.dat');
end

if s== 1
    disp('Copied inv2.dat in POLARITY folder as moremech.dat')
    disp('Check the manual for the use of these files')
end

%%%now we have to leave just one subevent in onemech.tmp....

      fid  = fopen('onemech.tmp','r');
      fid2 = fopen('onemech.dat','w');
                           
                        tline = fgets(fid);
                        fprintf(fid2,'%s', tline); 
      fclose(fid);               
      fclose(fid2);

delete('onemech.tmp')


% now open files for edit...
if ispc
    dos('notepad onemech.dat &');
    dos('notepad moremech.dat &');
else
    unix('gedit onemech.dat &');
    unix('gedit moremech.dat &');
end
cd ..



% handles on
on =[handles.plpol];
enableon(on)



catch
cd ..
end


else  % user created the files....
    % check if polarity exists..!
h=dir('polarity');

if isempty(h);
    errordlg('Polarity folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

try
cd polarity

h=dir('onemech.dat');

if isempty(h); 
  errordlg('Onemech.dat file doesn''t exist. ','File Error');
  cd ..
  return
else
  if ispc
    dos('notepad onemech.dat &');
  else
    unix('gedit onemech.dat &');
  end
    
end

h=dir('moremech.dat');

if isempty(h); 
  errordlg('Moremech.dat file doesn''t exist. ','File Error');
  cd ..
  return
else
  if ispc
    dos('notepad moremech.dat &');
  else
    unix('gedit moremech.dat &');  
  end
    
end

cd ..



% handles on
on =[handles.plpol];
enableon(on)


catch
cd ..
end


end

% --- Executes on button press in autocopy.
function autocopy_Callback(hObject, eventdata, handles)
% hObject    handle to autocopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autocopy


% --- Executes on button press in pltime.
function pltime_Callback(hObject, eventdata, handles)
% hObject    handle to pltime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if INVERT exists..!
h=dir('invert');

if isempty(h);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



cd invert

h=dir('timfun.dat');

if isempty(h); 
  errordlg('Timfun.dat file doesn''t exist. Run Inversion. ','File Error');
  return
else
    
    fid  = fopen('timfun.dat','r');
    [ftime,fampl] = textread('timfun.dat','%f %f');
    fclose(fid);

figure(1)

    plot(ftime,fampl,'r')

cd ..

end


% --- Executes during object creation, after setting all properties.
function ftime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ftime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ftime_Callback(hObject, eventdata, handles)
% hObject    handle to ftime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ftime as text
%        str2double(get(hObject,'String')) returns contents of ftime as a double


% --- Executes during object creation, after setting all properties.
function totime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function totime_Callback(hObject, eventdata, handles)
% hObject    handle to totime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totime as text
%        str2double(get(hObject,'String')) returns contents of totime as a double


% --- Executes on button press in uselimits.
function uselimits_Callback(hObject, eventdata, handles)
% hObject    handle to uselimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of uselimits


% --- Executes on button press in png.
function png_Callback(hObject, eventdata, handles)
% hObject    handle to png (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp(['Converting  Best.ps Postscript file to PNG using ImageMagick. File will be moved at the \output folder..'])

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
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    eventagency=fscanf(fid,'%s',1);
    fclose(fid);
end


%%%%%%%%%
eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_best.png' ];


try
cd invert
    fid = fopen('best2png.bat','w');
     if ispc
    fprintf(fid,'%s\r\n',['convert -rotate  "90" best.ps ' eventid ]);
    fprintf(fid,'%s\r\n',['copy ' eventid  '  ..\output']);
    fprintf(fid,'%s\r\n',['del  ' eventid ]);
     else
    fprintf(fid,'%s\n',['convert -rotate  "90" best.ps ' eventid ]);
    fprintf(fid,'%s\n',['copy ' eventid  '  ..\output']);
    fprintf(fid,'%s\n',['del  ' eventid ]);
     end
    fclose(fid);

system('best2png.bat')
system('del best2png.bat')

cd ..
pwd

catch
     cd ..
     pwd
end
 


% --- Executes on button press in PNG2.
function PNG2_Callback(hObject, eventdata, handles)
% hObject    handle to PNG2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


disp(['Converting  inv1.ps Postscript file to PNG using ImageMagick. File will be moved at the \output folder..'])
%%% check event.isl files with event info

h=dir('event.isl');

if length(h) == 0; 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    
    eventdate=fscanf(fid,'%s',1);
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    eventagency=fscanf(fid,'%s',1);
    fclose(fid);
end


%%%%%%%%%
eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec '_inv1.png' ];

try
cd invert
    fid = fopen('inv12png.bat','w');
    
    if ispc
    fprintf(fid,'%s\r\n',['convert -rotate  "90" inv1.ps ' eventid ]);
    fprintf(fid,'%s\r\n',['copy ' eventid  '  ..\output']);
    fprintf(fid,'%s\r\n',['del  ' eventid ]);
    else
    fprintf(fid,'%s\n',['convert -rotate  "90" inv1.ps ' eventid ]);
    fprintf(fid,'%s\n',['copy ' eventid  '  ..\output']);
    fprintf(fid,'%s\n',['del  ' eventid ]);
    end
    fclose(fid);

system('inv12png.bat')
system('del inv12png.bat')

cd ..
pwd

catch
     cd ..
     pwd
end
 


% --- Executes on button press in dcvcorr.
function dcvcorr_Callback(hObject, eventdata, handles)
% hObject    handle to dcvcorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


cname = 'corr01.dat'


pwd

cd invert

 [srcpos,srctime,variance,str1,dip1,rake1,str2,dip2,rake2,dc,moment] = textread(cname,'%f %f %f %f %f %f %f %f %f %f %f','headerlines',2);

%%%%%%%%%%%%%%%%%%%%%

    fid = fopen('inv2.dat','r');
    [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,dcbest,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',1);
    fclose(fid);


    cd .. 


    bestsource=srcpos2
    besttime=srctime2
%
%% find data for best source
whos srcpos

j=1;
for i=1:length(srcpos);

    if srcpos(i) == bestsource
        bestsourcedc(j)=dc(i);
        bestsourcecor(j)=variance(i);
            j=j+1;

    else
        
    end
    
end

whos bestsourcedc bestsourcecor

%% find data for best time
whos srctime
k=1;
for i=1:length(srctime);

    if srctime(i) == besttime
        besttimedc(k)=dc(i);
        besttimecor(k)=variance(i);
            k=k+1;

    else
        
    end
end


%%%%%%%%%

figure

plot(variance,dc,'+',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','k',...
                'MarkerSize',7)

hold on

plot(bestsourcecor,bestsourcedc,'rs',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','b',...
                'MarkerSize',7)


plot(besttimecor,besttimedc,'rd',...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','r',...
                'MarkerSize',10)


xlabel('Correlation','FontSize',12)
ylabel('DC%','FontSize',12)
grid on

legend('All grid search', 'Best space position', 'Best time position')
 
 
 bestsourcecor
 bestsourcedc
 besttimecor
 
 besttimedc
 
 
 
 
 
function enableon(on)
set(on,'Enable','on')




% --- Executes on button press in bw.
function bw_Callback(hObject, eventdata, handles)
% hObject    handle to bw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bw


% --- Executes on button press in svarred.
function svarred_Callback(hObject, eventdata, handles)
% hObject    handle to svarred (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of svarred


% --- Executes on button press in ftest.
function ftest_Callback(hObject, eventdata, handles)
% hObject    handle to ftest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ftest


% --- Executes on button press in addmech.
function addmech_Callback(hObject, eventdata, handles)
% hObject    handle to addmech (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addmech




function flimits = findlimits4plot(data)
%we expect data in form 8192x4 1st column time 2nd NS etc...

limits(1)=max(data(:,2));
limits(2)=max(data(:,3));
limits(3)=max(data(:,4));
limits(4)=min(data(:,2));
limits(5)=min(data(:,3));
limits(6)=min(data(:,4));

flimits(1)=max(limits);
flimits(2)=min(limits);



% --- Executes on button press in plotsolstations.
function plotsolstations_Callback(hObject, eventdata, handles)
% hObject    handle to plotsolstations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pscoast=makegmtscript4stationplot(1);


% --- Executes on button press in mommagn.
function mommagn_Callback(hObject, eventdata, handles)
% hObject    handle to mommagn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check subevent number
nsubevents=handles.nsubevents; 

if str2num(nsubevents) == 1
    warndlg('This option works for more than one subevent.','!! Warning !!')
    return
else
    disp(['Found '   nsubevents ]);
end


try
    
    cd invert

h=dir('inv2c.dat');

%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
if isempty(h); 
    errordlg('inv2c.dat file doesn''t exist. Run Invert. ','File Error');
    cd ..
  return    
else
      fid = fopen('inv2c.dat','r');
        C=textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
      fclose(fid);

%       %compute magnitudes
%       cum_mom_mag=(2/3)*(log10(C{3}) - 9.1); %! Hanks & Kanamori (1979)
      
      disp([ ' SubEvent    Mw         Mo (Nm)' ])
      
      for i=1:length(C{3})
      disp(['    '  num2str(i) '       '  num2str(C{4}(i),'%5.2f') '      ' num2str(C{3}(i),'%10.3e')])
      end
      
      
      figure

      plot(C{4},C{3},'-rs',...
                'LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','b',...
                'MarkerSize',7)

      xlabel('Moment Magnitude','FontSize',12)
      ylabel('Mo (Nm)','FontSize',12)
      grid on
      
end


   cd ..
catch
    cd ..
end


% --- Executes on button press in checkcorrel.
function checkcorrel_Callback(hObject, eventdata, handles)
% hObject    handle to checkcorrel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
% if pressed it opens correlation plot...
% if ispc
%  h=dir('.\invert\corr01.ps');
% else
%  h=dir('./invert/corr01.ps');
% end
% if isempty(h); 
%          errordlg('corr01.ps file doesn''t exist in invert folder. Run Inversion and plot it. ','File Error');
%      return
% else
%     if ispc
%      system('gsview32 .\invert\corr01.ps');
%     else
%      system('gv ./invert/corr01.ps');
%     end
%      
% end
%%
eventid=handles.eventid;

%% make a plot also
% check how many sources

% open inpinv.dat
if ispc 
   a=exist('.\invert\inpinv.dat','file');
else
   a=exist('./invert/inpinv.dat','file');
end

if a==2
   if ispc
      [~,dtres,nsources,tshifts,nsubevents,~,~] = readinpinv('.\invert\inpinv.dat');
   else
      [~,dtres,nsources,tshifts,nsubevents,~,~] = readinpinv('./invert/inpinv.dat');
   end
else
    disp('Please run inversion ... Inpinv.dat is missing..')
end

%% Calculate no of time steps
disp('No of Time steps')

nooftimesteps=round((tshifts(3)-tshifts(1))/tshifts(2))


%%
if nsubevents ~= 1;
            a=['Inversion was performed for ' num2str(nsubevents) ' subevents. Which one do you want to use for correlation plot.?' ];
            prompt = {a};
            dlg_title = 'Input Subevent Number';
            num_lines= 1;
            def     = {'1'};
            answer  = inputdlg(prompt,dlg_title,num_lines,def);
            fileindex = str2num(answer{1});
            disp(['Now Plotting Subevent number  ' answer{1} ])
            
            cname=['corr' num2str(fileindex,'%02d') '.dat'];
            psname= ['corr' num2str(fileindex,'%02d') '.ps'];

            disp(['Now plotting  ' cname '   correlation file'])

%%%%
else
            cname='corr01.dat';
            psname= 'corr01.ps';
end
%% Learn the source distribution e.g. line or plane

h=dir('tsources.isl');

if isempty(h); 
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
          
        conplane=2;   %%% Line
        % dummy sdepth
        sdepth=-333;
        
     elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        
         conplane=0;   %%%depth
   
     elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
           noSourcesstrike=fscanf(fid,'%i',1);
           strikestep=fscanf(fid,'%f',1);
           noSourcesdip=fscanf(fid,'%i',1);
           dipstep=fscanf(fid,'%f',1);
%           nsources=noSourcesstrike*noSourcesdip;
          
           invtype='   Multiple Source line or plane '; %(Trial Sources on a plane or line)';
      
           conplane=1;
           
           % dummy sdepth
           sdepth=-333;
            distep=-333;
            
     elseif strcmp(tsource,'point')
       disp('Inversion was done for one source.')
       nsources=fscanf(fid,'%i',1);
       distep=fscanf(fid,'%f',1);
       sdepth=fscanf(fid,'%f',1);
       invtype=fscanf(fid,'%c');
        
      
     end
     
          fclose(fid);
          
end

%%

% fixed options
dcplot= 0;
%%%% draw contours..???
drawcont= 1;
%%%% invert palette..???
invpal= 0;
%%%%%%%%%%%%%%%%%%%font size....
fsize = '10';
%%% correl parameters ...
scalex = '21';
scaley = '18';
fscale = '0.35';
%%%%%cpt file
gmtpal = 'cool';
% find time limits
negtime=num2str(tshifts(1)*dtres);
postime=num2str(tshifts(3)*dtres);
tstep=num2str(tshifts(2)*dtres);
% source limits
fsrc='1';
lsrc=num2str(nsources);



if drawcont == 1
     wline='-W0.5p';
else
     wline='-W+1.0p';
end

%% Read file 
try
 cd invert

h=dir(cname);

if isempty(h); 
    errordlg([cname 'file doesn''t exist. Run Invert. '],'File Error');
    cd ..
  return    
else
    
              % check if we have new format of correl file
               fid = fopen(cname,'r');
                tline = fgetl(fid);tline = fgetl(fid);
                tline = fgetl(fid);
               fclose(fid);
              
               if length(tline) > 100
                    disp('New correlation file format')
               % read in new format
                 fid = fopen(cname,'r');
                 [srcpos,srctime,variance,str1,dip1,rake1,str2,dip2,rake2,dc,volume,misfit,moment] = textread(cname,'%f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',2);
                 fclose(fid);               


               else % old format
                    disp('Old correlation file format')

                 fid = fopen(cname,'r');
                 [srcpos,srctime,variance,str1,dip1,rake1,str2,dip2,rake2,dc,moment] = textread(cname,'%f %f %f %f %f %f %f %f %f %f %f','headerlines',2);
                 fclose(fid);
               end
end

catch
   cd ..    
end
%% Try to plot based on conplane value

if conplane == 0   %%%% Depth line

  disp('Plotting correlation with source number')    %%%%%% source number plot
  %%%%find variance maximum and index ...
[maxvar,index]=max(variance);
%
% bbcut=get(handles.bbcut,'String');
 cor_cut=maxvar*(str2num('0')/100)
%
maxsource=srcpos(index);
maxsrctime=srctime(index);
maxstr1=str1(index);
maxdip1=dip1(index);
maxrake1=rake1(index);
maxstr2=str2(index);
maxdip2=dip2(index);
maxrake2=rake2(index);
maxdc=dc(index);

disp('Maximum Correlation mechanism  STR1  DIP1  RAKE1  STR2  DIP2  RAKE2  DC%' )
mstring=['        ' num2str(maxvar) '                 '  num2str(maxstr1) '    '  num2str(maxdip1) '    '  num2str(maxrake1) '    '  num2str(maxstr2) '    '  num2str(maxdip2) '   '  num2str(maxrake2) '   ' num2str(maxdc)];
disp(mstring)
ststring=['At time shift   ' num2str(maxsrctime) '   and source position   ' num2str(maxsource)];
disp(ststring)


%% 
drcont=0;

if drcont == 1 
%      cptstep= str2num(get(handles.annotint,'String'));
%      dc_cptstep=str2num(get(handles.annotint,'String'));
else
     if maxvar <= 0.1
       cptstep=0.02;
     elseif maxvar > 0.1 && maxvar <= 0.2
       cptstep=0.05;
     else
       cptstep=0.1;
     end
     
     dc_cptstep=10;
end        

%

%%%
%%% prepare a meca gmt style file for maximum correlation
    fid = fopen('maxval.foc','w');
      if ispc
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\r\n',maxsrctime,maxsource,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
      else
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\n',maxsrctime,maxsource,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
      end
    fclose(fid);



    fid = fopen('plcor.bat','w');
           
  if ispc
           st=['gawk "{if (NR>2 && $3 > ' num2str(cor_cut) ')  print $2,$1,$10,$4,$5,$6,"5","0","0"}" ' cname ' > testfoc.dat'];   
          
           if dcplot == 1
           nd=['gawk "{if (NR>2)  print $2,$1,$10}" ' cname ' > corcon.dat'];
           else
           nd=['gawk "{if (NR>2)  print $2,$1,$3}" ' cname ' > corcon.dat'];    
           end
           
    fprintf(fid,'%s\r\n',st);
    fprintf(fid,'%s\r\n',nd);
    fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
  else
           st=['gawk ''{if (NR>2)  print $2,$1,$10,$4,$5,$6,"5","0","0"}'' ' cname ' > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk ''{if (NR>2)  print $2,$1,$10}'' ' cname ' > corcon.dat'];
           else
           nd=['gawk ''{if (NR>2)  print $2,$1,$3}'' ' cname ' > corcon.dat'];    
           end
    fprintf(fid,'%s\n',st);
    fprintf(fid,'%s\n',nd);
    fprintf(fid,'%s\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1
    
    
       if invpal == 1
          if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          end
 
       else
          if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          end
 
       end
     
     
else
   if ispc
     fprintf(fid,'%s\r\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   else
     fprintf(fid,'%s\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if invpal == 1
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) ' -I  > cr.cpt'];
else
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) '     > cr.cpt'];
end

  if ispc
    fprintf(fid,'%s\r\n',vstring);
  else
    fprintf(fid,'%s\n',vstring);
  end
    
end

if dcplot == 1
gimstring=['pscontour corcon.dat -R'  num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep))  '/' num2str(str2num(fsrc)-1) '/' num2str(str2num(lsrc)+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Time(sec)":/1:"Source position":WeSn -Cdc.cpt -K -I -A+a0+s' fsize ' > ' psname ];
else
gimstring=['pscontour corcon.dat -R'  num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep))  '/' num2str(str2num(fsrc)-1) '/' num2str(str2num(lsrc)+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Time(sec)":/1:"Source position":WeSn -Ccr.cpt -K -I -A+a0+s' fsize ' > ' psname ];
end

%%%%%%
if ispc
  fprintf(fid,'%s\r\n',gimstring);
else
  fprintf(fid,'%s\n',gimstring);
end

%%%%%%%
         if dcplot == 1
          scalestr=['psscale -D' num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Cdc.cpt -K -L -B:DC: >> ' psname];
          scalestr2=[];
         else
          scalestr=['psscale -D'   num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Ccr.cpt -K -L -B:Correlation: >> ' psname];
          scalestr2=['psscale -D'  num2str(str2num(scalex)+1) 'c/13c/7c/0.2 -O -Cdc.cpt -K -L  -B::/:DC\045: >> ' psname ];
         end
         
if ispc         
    fprintf(fid,'%s\r\n',scalestr);
    fprintf(fid,'%s\r\n',scalestr2);
else
    fprintf(fid,'%s\n',scalestr);
    fprintf(fid,'%s\n',scalestr2);
end
%     %%%time scale...!!
%        tstring=['psxy -R' num2str((min(srctime)),'%5.2f') '/' num2str((max(srctime)),'%5.2f')  '/' '0' '/' num2str(nsources+1) ' -JX' scalex 'c/' scaley  'c time.tmp -B1g1:"Time(sec)":/1:"Source position":WeSn  -O -K >>  ' psname];
%     fprintf(fid,'%s\r\n',tstring);
% %%%%%%%%%%%%%%%%%%%%%%%%%focal  

       mecstring=['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' fscale ' -O -K testfoc.dat -Zdc.cpt >> ' psname ];
  if ispc       
    fprintf(fid,'%s\r\n',mecstring);
  else
    fprintf(fid,'%s\n',mecstring);        
  end
       mecstringmax =['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' num2str(str2double(fscale)+0.3) ' -O maxval.foc -Zdc.cpt >> ' psname ];
  if ispc
     fprintf(fid,'%s\r\n',mecstringmax);
  else
     fprintf(fid,'%s\n',mecstringmax);
  end
    
    %%% add option to convert to PNG using ps2raster...26/10/09    
if ispc    
    fprintf(fid,'%s\r\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D..\output' ]);
    fprintf(fid,'%s\r\n',['rename ..\output\' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
    fprintf(fid,'%s\r\n','del testfoc.dat corcon.dat dc.cpt cr.cpt  maxval.foc  ');
else
    fprintf(fid,'%s\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D../output' ]);
    fprintf(fid,'%s\n',['mv ../output/' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
    fprintf(fid,'%s\n','rm testfoc.dat corcon.dat dc.cpt cr.cpt  maxval.foc  ');
end
    fclose(fid);
    

  
  
%%
elseif conplane == 1   %%%%%%%%%% New code for Plane plot correlation...!!!
    
        
disp('Ploting Correlation on the plane of sources best correlation per source ...')

%%%%%%%%%%%%%%%%%%Read data from handles....
noSourcesstrike=handles.noSourcesstrike;
strikestep=handles.strikestep;
noSourcesdip=handles.noSourcesdip;
dipstep=handles.dipstep;

%%%find out which is the best time shift.....
%disp('Plotting correlation with Distance-Depth')

% srcpos=srcpos*distep;

%%%%%%%%%%%%%%%%%%%%%    prepare for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%find variance maximum and index ...
[maxvar,index]=max(variance)
%
maxsource=srcpos(index);
maxsrctime=srctime(index);
maxstr1=str1(index);
maxdip1=dip1(index);
maxrake1=rake1(index);
maxstr2=str2(index);
maxdip2=dip2(index);
maxrake2=rake2(index);
maxdc=dc(index);
%
disp('Maximum Correlation mechanism  STR1  DIP1  RAKE1  STR2  DIP2  RAKE2  DC%' )
mstring=['        ' num2str(maxvar) '                 '  num2str(maxstr1) '    '  num2str(maxdip1) '    '  num2str(maxrake1) '    '  num2str(maxstr2) '    '  num2str(maxdip2) '   '  num2str(maxrake2) '   ' num2str(maxdc)];
disp(mstring)
ststring=['At time shift   ' num2str(maxsrctime) '   and source   ' num2str(maxsource)];
disp(ststring)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
 %  set(handles.selsrc,'String',num2str(maxsource))

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%select all the data at the best time shift...
%% and put in array...
k=1;
  for i=1:noSourcesdip
    for j=1:noSourcesstrike
          posx(k)=i;
          posy(k)=j;
          k=k+1;
    end          
  end

%                                     old code....
j=1;
for i=1:length(srcpos)
    
    if srctime(i) == maxsrctime
       plane(j,1)=srcpos(i);
       plane(j,2)=srctime(i);
       plane(j,3)=variance(i);
       plane(j,4)=str1(i);
       plane(j,5)=dip1(i);
       plane(j,6)=rake1(i);
       plane(j,7)=str2(i);
       plane(j,8)=dip2(i);
       plane(j,9)=rake2(i);
       plane(j,10)=dc(i);
       plane(j,11)=moment(i);
       j=j+1;
   else
   end
   
end

correlation=0;
besttime=0;

fid = fopen('planecor.dat','w');

for i=1:nsources

   for j=1:nsources*nooftimesteps

      if srcpos(j)==i
        % find best correlation per source...
        if  variance(j) > correlation   
            correlation=variance(j);
            besttime=srctime(j); bstr1=str1(j);bdip1=dip1(j); brake1=rake1(j);
            bstr2=str2(j); bdip2=dip2(j); brake2=rake2(j); bdc=dc(j); bmoment=moment(j);
        else
        end
     else   
    %     disp('no  ')
     end 
   end  

     correl(i)=correlation;besttim(i)=besttime;
     bbstr1(i)=bstr1;bbdip1(i)=bdip1; bbrake1(i)=brake1;
     bbstr2(i)=bstr2;bbdip2(i)=bdip2; bbrake2(i)=brake2;
     bbdc(i)=bdc; bbmoment(i)=bmoment;
     
     disp(['Source no  ' num2str(i) '   best corr '  num2str(correl(i)) ' at time ' num2str(besttim(i))  ]) 
  if ispc
     fprintf(fid,'%i %g %g  %g %g %g %g  %g %g %g %g %i %i\r\n',i,besttim(i),correl(i),bbstr1(i),bbdip1(i),bbrake1(i),bbstr2(i),bbdip2(i), bbrake2(i),bbdc(i), bbmoment(i),posx(i),posy(i));
  else
     fprintf(fid,'%i %g %g  %g %g %g %g  %g %g %g %g %i %i\n',i,besttim(i),correl(i),bbstr1(i),bbdip1(i),bbrake1(i),bbstr2(i),bbdip2(i), bbrake2(i),bbdc(i), bbmoment(i),posx(i),posy(i));
  end
 correlation=0;
 besttime=0;
 
end

fclose(fid);


% [n,s]=size(plane);
% for i=1:n   %max(length(plane))
%     fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g  %g  %g  %g  %g\r\n',plane(i,1),plane(i,2),plane(i,3),plane(i,4),plane(i,5),plane(i,6),plane(i,7),plane(i,8),plane(i,9),plane(i,10),plane(i,11),posx(i),posy(i));
% end  
% 
% %%%%% %%%%%%%%

%%%%combine in one matrix and find out position of best solution
planec=[plane posx' posy'];
[maxvar,index]=max(planec(:,3));

maxsource=planec(index,1);
%maxsrctime=srctime(index);
maxstr1=planec(index,4);
maxdip1=planec(index,5);
maxrake1=planec(index,6);
maxstr2=planec(index,7);
maxdip2=planec(index,8);
maxrake2=planec(index,9);
maxdc=planec(index,10);
max_x=planec(index,12);
max_y=planec(index,13);

%%%%%%%%%%%%%%%%%%%%%%%% prepare GMT plotting
%% 
drcont=0;

%%%%%%%%%%annotation interval...
if drcont == 1 
     cptstep= str2num(get(handles.annotint,'String'));
     dc_cptstep=str2num(get(handles.annotint,'String'));
else
     if maxvar <= 0.1
       cptstep=0.02;
     elseif maxvar > 0.1 && maxvar <= 0.2
       cptstep=0.05;
     else
       cptstep=0.1;
     end
     
     dc_cptstep=10;
end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stime = 0;
tstep = 1;   
etime = noSourcesdip+1;

%nsources=handles.nsourcestext;

%%%
%%% prepare a meca gmt style file for maximum correlation
    fid = fopen('maxval.foc','w');
      if ispc
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\r\n',max_x,max_y,5,maxstr1,maxdip1,maxrake1,5,0,0);
      else
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\n',max_x,max_y,5,maxstr1,maxdip1,maxrake1,5,0,0);
      end
    fclose(fid);


    fid = fopen('plcor.bat','w');
if ispc
           st=['gawk "{ print $12,$13,$10,$4,$5,$6,"5","0","0",$1}" planecor.dat > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk "{ print $12,$13,$10}" planecor.dat  > corcon.dat'];
           else
           nd=['gawk "{ print $12,$13,$3}"  planecor.dat  > corcon.dat'];    
           end

    fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
    fprintf(fid,'%s\r\n',st);
    fprintf(fid,'%s\r\n',nd);
else
           st=['gawk ''{ print $12,$13,$10,$4,$5,$6,"5","0","0",$1}'' planecor.dat > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk ''{ print $12,$13,$10}'' planecor.dat  > corcon.dat'];
           else
           nd=['gawk ''{ print $12,$13,$3}''  planecor.dat  > corcon.dat'];    
           end
    fprintf(fid,'%s\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
    fprintf(fid,'%s\n',st);
    fprintf(fid,'%s\n',nd);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1

    if invpal == 1
          if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          end
    else
          if ispc 
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          end
 
    end
     
else
   if ispc
     fprintf(fid,'%s\r\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   else
     fprintf(fid,'%s\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if invpal == 1
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) ' -I  > cr.cpt'];
else
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) '     > cr.cpt'];
end

  if ispc
    fprintf(fid,'%s\r\n',vstring);
  else
    fprintf(fid,'%s\n',vstring);
  end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1
 gimstring=['pscontour corcon.dat -R'  num2str(stime) '/' num2str(etime)  '/' '0' '/' num2str(noSourcesstrike+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -Cdc.cpt -K -I -A+a0+s' fsize ' -B1g1:"Dip":/1g1:"Strike":WeSn > ' psname ];
else
 gimstring=['pscontour corcon.dat -R'  num2str(stime) '/' num2str(etime)  '/' '0' '/' num2str(noSourcesstrike+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -Ccr.cpt -K -I -A+a0+s' fsize ' -B1g1:"Dip":/1g1:"Strike":WeSn > ' psname ];
end
 %%%%%%
 if ispc
    fprintf(fid,'%s\r\n',gimstring);
 else
    fprintf(fid,'%s\n',gimstring);
 end
 %%%%%%%
         if dcplot == 1
          scalestr=['psscale -D' num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Cdc.cpt -K -L -B:DC: >> ' psname];
          scalestr2=[];
         else
          scalestr=['psscale -D'   num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Ccr.cpt -K -L -B:Correlation: >> ' psname];
          scalestr2=['psscale -D'  num2str(str2num(scalex)+1) 'c/13c/7c/0.2 -O -Cdc.cpt -K -L  -B::/:DC\045: >> ' psname ];
         end
if ispc         
    fprintf(fid,'%s\r\n',scalestr);
    fprintf(fid,'%s\r\n',scalestr2);
else
    fprintf(fid,'%s\n',scalestr);
    fprintf(fid,'%s\n',scalestr2);
end
%     %%%time scale...!!
%        tstring=['psxy -R' num2str((min(srctime)),'%5.2f') '/' num2str((max(srctime)),'%5.2f')  '/' '0' '/' num2str(nsources+1) ' -JX' scalex '/' scaley  ' time.tmp -B1g1:"Time(sec)":/1:"Source position":WeSn  -O -K >>  ' psname];
%     fprintf(fid,'%s\r\n',tstring);
% %%%%%%%%%%%%%%%%%%%%%%%%%focal  

       mecstring=['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' fscale ' -O -K testfoc.dat -Zdc.cpt >> ' psname ];
if ispc       
    fprintf(fid,'%s\r\n',mecstring);
else
    fprintf(fid,'%s\n',mecstring);
end
       mecstringmax =['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' num2str(str2num(fscale)+0.1) ' -O maxval.foc -G255/0/0 >> ' psname ];
       
if ispc       
    fprintf(fid,'%s\r\n',mecstringmax);
    %%% add option to convert to PNG using ps2raster...26/10/09    
    fprintf(fid,'%s\r\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D..\output' ]);
    fprintf(fid,'%s\r\n',['rename ..\output\' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);

else
    fprintf(fid,'%s\n',mecstringmax);
    %%% add option to convert to PNG using ps2raster...26/10/09    
    fprintf(fid,'%s\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D../output' ]);
    fprintf(fid,'%s\n',['mv ../output/' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
end

    
    fclose(fid);
 


    
end  % end of conplane if
    

%%
%%% run batch file...
if ispc
   [s,r]=system('plcor.bat'); 
else
    !chmod +x plcor.bat
    !./plcor.bat
   [s,r]=system('plcor.bat'); 
end

cd .. %%% return to main folder before plotting.... this should solve problems if user tried to plot waveforms before closing ps file...

% read the gsview version from defaults
psview=handles.psview;

if ispc
    try 
     system([psview ' .\invert\' psname]);
    catch
     disp(exception.message)   
    end
else
  system([psview ' ./invert/' psname]);
end
  

% --- Executes on button press in tsvar.
function tsvar_Callback(hObject, eventdata, handles)
% hObject    handle to tsvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% it will calculate tsvar index based on threshold and corr.dat
% it will work for 1 subevent only


eventidnew=handles.eventidnew;


% first check if we have corr01.dat
if ispc
 h=dir('.\invert\corr01.dat');
else
 h=dir('./invert/corr01.dat');
end
if isempty(h); 
         errordlg('corr01.dat file doesn''t exist in invert folder. Run Inversion. ','File Error');
     return
else
    disp('Corr01.dat found. Code will work for 1 subevent based on corr01.dat')
end

% check if we have inv2.dat
if ispc
 h=dir('.\invert\inv2.dat');
else
 h=dir('./invert/inv2.dat');
end
%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
if isempty(h); 
    errordlg('inv2.dat file doesn''t exist. Run Inversion. ','File Error');
    cd ..
  return    
else
    if ispc
       fid = fopen('.\invert\inv2.dat','r');
    else
       fid = fopen('./invert/inv2.dat','r');
    end
    tline = fgetl(fid);
      if length(tline) > 125
          disp('New inv2.dat')
          inv2age='new';
          fclose(fid);
%          fid = fopen('.\invert\inv2.dat','r');
         if ispc
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('.\invert\inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',1);
         else
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('./invert/inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',1);
         end
%          fclose(fid);
      else
          disp('Old inv2.dat')
          inv2age='old';
          fclose(fid);
%          fid = fopen('.\invert\inv2.dat','r');
         if ispc
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,dc,varred] = textread('.\invert\inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',1);
         else
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,dc,varred] = textread('./invert/inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',1);
         end
%          fclose(fid);
      end
end      
%% look for inpinv.dat to get limits of plot
% check if we have inpinv.dat
if ispc
 h=dir('.\invert\inpinv.dat');
else
 h=dir('./invert/inpinv.dat');   
end
%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
if isempty(h); 
    errordlg('inpinv.dat file doesn''t exist. Run Inversion. ','File Error');
  return    
else
    if ispc
          [id,tstep,nsources,tshifts,~,~,~] = readinpinv('.\invert\inpinv.dat');
             if(id==4)
               warndlg('Inversion was down for fixed mechanism. Cannot calculate index.','Warning')
               return
             else
             end
    else       
          [id,tstep,nsources,tshifts,~,~,~] = readinpinv('./invert/inpinv.dat');
             if(id==4)
               warndlg('Inversion was down for fixed mechanism. Cannot calculate index.','Warning')
               return
             else
             end

    end
end

% xaxis will be
%iseqm=round((tshifts(3)-tshifts(1))/tshifts(2))

tint=tshifts(2)*tstep;

xaxisl=(tshifts(1)*tstep)+tint;
xaxisr=tshifts(3)*tstep;

%% find how many sources we have and distance

h=dir('tsources.isl');

if isempty(h); 
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
          
        conplane=2;   % Line
        % dummy sdepth
        sdepth=-333;
        
     elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        
        conplane=0;   %%%depth
    
     elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
           noSourcesstrike=fscanf(fid,'%i',1);
           strikestep=fscanf(fid,'%f',1);
           noSourcesdip=fscanf(fid,'%i',1);
           dipstep=fscanf(fid,'%f',1);
%           nsources=noSourcesstrike*noSourcesdip;
          
           invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
           conplane=1;
           
%           set(handles.udistdep,'Enable','Off') %   disp('Distance corel plot is not available for plane source model. Source number will be used.')
           % dummy sdepth
           sdepth=-333;
           distep=-333;
           
     elseif strcmp(tsource,'point')
       disp('Inversion was done for one source.')
       nsources=fscanf(fid,'%i',1);
       distep=fscanf(fid,'%f',1);
       sdepth=fscanf(fid,'%f',1);
       invtype=fscanf(fid,'%c');
        
     end
     
          fclose(fid);
          
end

%% this is our reference solution
strref=str1;
dipref=dip1;
rakeref=rake1;

disp(['Reference solution is ' num2str(strref) ' ' num2str(dipref) ' ' num2str(rakeref) ])
    
% get correlation level
cor=str2num(get(handles.tsvarcor,'String'));

% pwd

% call function
cd invert

    [srcpos2C,srctimeC,allsrcpos,allsrctime,allvariance,strC,dipC,rakeC,maxvar]=preparecor4kagan('corr01.dat',cor,strref,dipref,rakeref);


% call fortran code
   [status, result] = system('corr_kag');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   FMVAR part 
if status ==0 
    
    pause(2)
    % read the output    
    kag=load('kagselect.dat');
    % plot histogram
    figure
    subplot(1,2,1)
    
    
    hist(kag)  
     h= findobj(gca,'Type','patch');
     set(h,'FaceColor',[.5 .5 .5],'EdgeColor','w')
     
    fmvar_mean=mean(kag);
    fmvar_std = std(kag);
    fmvar_median=median(kag);
    
    t=char(['\fontsize{12}Kagan angle for reference solution STR = ' num2str(strref) ' DIP = ' num2str(dipref) ' RAKE = ' num2str(rakeref)],...
           [' Mean = ' num2str(fmvar_mean,'%6.2f') ' STD = ' num2str(fmvar_std,'%6.2f') ' Median = ' num2str(fmvar_median,'%6.2f') ' Var = ' num2str(var(kag),'%6.2f')],...
           ['\fontsize{12}\color{red}FMVAR = ' num2str(round(fmvar_mean)) ' \pm ' num2str(round(fmvar_std));]);
    
    FMVAR=fix(fmvar_std);
    axis square
    xlabel('Kagan angle','fontsize',12,'fontweight','b');
    ylabel('Count','fontsize',12,'fontweight','b');
    ht=title(t,'fontsize',12,'fontweight','b');
    h=gca; % returns handle to current axis in the current
    set(h,'FontSize',12) 
    set(h,'FontName','FixedWidth')
    set(h,'FontWeight','bold')
    set(h,'LineWidth',0.9)

disp(' ')    
disp(['FMVAR = '     num2str(round(fmvar_mean)) ' +- ' num2str(round(fmvar_std))]);
disp(' ')    
    
%     set(ht,'HorizontalAlignment','Center');
%     set(ht,'VerticalAlignment','Middle');
     
%   %set(ht, 'FontSize', 12);
%      
%     y = skewness(kag,1);
%     y = skewness(kag,0);
%     y = kurtosis(kag,1);
%     y = kurtosis(kag,0);
%     y=var(kag);
%     y=var(kag,1)
%     indx=y/cor
%title(['\fontsize{16}black {\color{magenta}magenta '...
%'\color[rgb]{0 .5 .5}teal \color{red}red} black again'])     
else
    disp('Error with corr_kag. Please check if it is installed.')
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   STVAR part 
% compute stvar as a ratio between number of points above threshold and
% total number of grid points

STVAR=comp_stvar(nsources,tshifts,srcpos2C,srctimeC);
disp(' ')   
disp(['STVAR = '     num2str(STVAR,'%2.2f')]);
disp(' ')    

% fit ellipse in space time variation...
% convert source position to km 
allsrcposkm=((allsrcpos-1)*distep)+sdepth;
srcpos2Ckm=((srcpos2C-1)*distep)+ sdepth; % min(srcpos2C);
% contour..??
[X,Y] = meshgrid(xaxisl:tint:xaxisr,min(allsrcposkm):distep:max(allsrcposkm));
Z = griddata(allsrctime,allsrcposkm,allvariance,X,Y);

%hel=figure
ht=subplot(1,2,2);


contourf(X,Y,Z)
hold
colormap(cool)
colorbar('LineWidth',0.9)

% contour with transparency
[C,h]=contour(X,Y,Z,[cor cor],'-k','LineWidth',2);
% xcon_cor=C(1,2:end);
% ycon_cor=C(2,2:end);
% p=patch(xcon_cor,ycon_cor,'w');
% alpha(p,0.8);


%[C,h]=contourf(X,Y,Z,[cor cor])%,[cor cor],'-k','LineWidth',2)
%ch = get(h,'child'); 
%set(ch,'FaceAlpha',0.8);


plot(srctimeC,srcpos2Ckm,'o','MarkerFaceColor','k','MarkerSize',4,'MarkerEdgeColor','k')
    xlabel('Time (sec)','fontsize',12,'fontweight','b');
    ylabel('Distance/Depth (km)','fontsize',12,'fontweight','b');

%   ht=title('Fit of ellipse at selected correlation level');
t=char(['\fontsize{12}Maximum Correlation = '  num2str(maxvar,'%4.2f') ' Correlation Threshold = ' num2str(cor,'%4.2f') ],...
        ['\fontsize{12}\color{red}STVAR = ' num2str(STVAR,'%2.2f');] );
ht=title(t,'fontsize',12,'fontweight','b');
     
%plot(X,Y,'o','MarkerFaceColor','g','MarkerSize',2,'MarkerEdgeColor','g')
 axis square
 
h=gca; % returns handle to current axis in the current
set(h,'FontSize',12) 
set(h,'FontName','FixedWidth')
set(h,'FontWeight','bold')
set(h,'LineWidth',0.9)
% plot focal mechanism..??
% fm=[strC dipC rakeC];
% a=ones(length(kag),1)*0.2;
% b=zeros(length(kag),1);
% bb(fm, srctimeC, srcpos2Ckm,a,b, 'r')

%%%%%%%%%%%%%%%%%%%%%%%%  fit of an ellipse part 
% elfit=fit_ellipse(srctimeC,srcpos2Ckm,ht)
% PHI=rad2deg(elfit.phi)
% STVAR=elfit.long_axis*elfit.short_axis
% embadon=pi*elfit.long_axis*elfit.short_axis
%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot nodal line plot using stereonets
figure

Stereonet(0,90*pi/180,1000*pi/180,1);
v=axis;

xlim([v(1),v(2)]); ylim([v(3),v(4)]);  % static limits
hold
% load data

fid = fopen('corrselect.dat');
SDR = textscan(fid, '%f %f %f %f %f %f','HeaderLines',1);
fclose(fid);

str1=SDR{1};dip1=SDR{2};
str2=SDR{4};dip2=SDR{5};
 
tic
 for i=1:length(str1)
     
     path = GreatCircle(deg2rad(str1(i)),deg2rad(dip1(i)),1);
     plot(path(:,1),path(:,2),'r-')

%      Plot P axis (black, filled circle)
%      [xp,yp] = StCoordLine(deg2rad(aziP(i)),deg2rad(plungeP(i)),1);
%      plot(xp,yp,'ko','MarkerFaceColor','k');

      path2 = GreatCircle(deg2rad(str2(i)),deg2rad(dip2(i)),1);
      plot(path2(:,1),path2(:,2),'r-')
 
%      Plot T axis (black, filled circle)
%      [xp,yp] = StCoordLine(deg2rad(aziT(i)),deg2rad(plungeT(i)),1);
%      plot(xp,yp,'mo','MarkerFaceColor','m');
 
 end

toc

     
%% plot the nodal lines

% we need to know GMT version !!
gmt_ver=handles.gmt_ver;
% 
% handles.psview=psview;
%
if ispc
    fid = fopen('plselnod.bat','w');
     fprintf(fid,'%s\r\n','del nodals.png');
     fprintf(fid,'%s\r\n','gawk "{print 10,10,10,$1,$2,$3,6}" corrselect.dat > nodals.dat');
     if gmt_ver==4
        fprintf(fid,'%s\r\n','psmeca -R0/20/0/20 -JX15c nodals.dat  -Sa10c -T0 -K  -a0.2c/cc -pthinner -tthinner  -gblack > nodals.ps');
     else
        fprintf(fid,'%s\r\n','psmeca -R0/20/0/20 -JX15c nodals.dat  -Sa10c -T0 -K  -Fa0.2c/cc -Fpthinner -Ftthinner  -Fgblack > nodals.ps');
     end
     if gmt_ver==4
        fprintf(fid,'%s\r\n',['gawk "{print 10,10,10,$4,$5,$6,6}" inv2.dat |  psmeca -R -J  -Sa10c -T0 -K -O -Wthick,red -a0.4c/hh -eblack  -gwhite  -pthinner -tthinner >> nodals.ps  ']);
     else
        fprintf(fid,'%s\r\n',['gawk "{print 10,10,10,$4,$5,$6,6}" inv2.dat |  psmeca -R -J  -Sa10c -T0 -K -O -Wthick,red -Fa0.4c/hh -Feblack  -Fgwhite  -Fpthinner -Ftthinner >> nodals.ps  ']);
     end
     
     fprintf(fid,'%s\r\n','echo 10 10 10 0 0 0 6 | psmeca -R -J     -Sa10c -T1  -O -Wthick   >> nodals.ps');
     if gmt_ver==4
       fprintf(fid,'%s\r\n','ps2raster nodals.ps -P -Tg -A');
     else
       fprintf(fid,'%s\r\n','psconvert nodals.ps -P -Tg -A');
     end
     fprintf(fid,'%s\r\n','del nodals.dat');
    fclose(fid);
    %%% run batch file...
     [s,r]=system('plselnod.bat');
     if s==0
         figure
 
       A=imread('nodals.png','png');
       image(A);
      axis square
      axis off
     else
       disp('error')
       disp(r)
     end

else
    fid = fopen('plselnod.bat','w');
     fprintf(fid,'%s\n','rm nodals.png');
     fprintf(fid,'%s\n','awk ''{print 10,10,10,$1,$2,$3,6}'' corrselect.dat > nodals.dat');
     
     if gmt_ver==4
        fprintf(fid,'%s\n','psmeca -R0/20/0/20 -JX15c nodals.dat  -Sa10c -T0 -K  -a0.2c/cc -pthinner -tthinner  -gblack > nodals.ps');
     else
        fprintf(fid,'%s\n','psmeca -R0/20/0/20 -JX15c nodals.dat  -Sa10c -T0 -K  -Fa0.2c/cc -Fpthinner -Ftthinner  -Fgblack > nodals.ps');
     end
     
     if gmt_ver==4
        fprintf(fid,'%s\n',['awk ''{print 10,10,10,$4,$5,$6,6}'' inv2.dat |  psmeca -R -J  -Sa10c -T0 -K -O -Wthick,red -a0.4c/hh -eblack  -gwhite  -pthinner -tthinner >> nodals.ps  ']);
     else
        fprintf(fid,'%s\n',['awk ''{print 10,10,10,$4,$5,$6,6}'' inv2.dat |  psmeca -R -J  -Sa10c -T0 -K -O -Wthick,red -Fa0.4c/hh -Feblack  -Fgwhite  -Fpthinner -Ftthinner >> nodals.ps  ']);
     end
     
     fprintf(fid,'%s\n','echo 10 10 10 0 0 0 6 | psmeca -R -J     -Sa10c -T1  -O -Wthick   >> nodals.ps');
     if gmt_ver==4
       fprintf(fid,'%s\n','ps2raster nodals.ps -P -Tg -A');
     else
       fprintf(fid,'%s\n','psconvert nodals.ps -P -Tg -A');
     end
     fprintf(fid,'%s\n','rm nodals.dat');
    fclose(fid);
    
      !chmod +x  plselnod.bat
      [s,r]=system('./plselnod.bat'); 
      
      if s==0
          figure
 
       A=imread('nodals.png','png');
       image(A);
%    axis square
%    axis off
     else
       disp('error')
       disp(r)
     end
    
end

%%
     
cd ..



function tsvarcor_Callback(hObject, eventdata, handles)
% hObject    handle to tsvarcor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tsvarcor as text
%        str2double(get(hObject,'String')) returns contents of tsvarcor as a double


% --- Executes during object creation, after setting all properties.
function tsvarcor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tsvarcor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bbscale_Callback(hObject, eventdata, handles)
% hObject    handle to bbscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bbscale as text
%        str2double(get(hObject,'String')) returns contents of bbscale as a double


% --- Executes during object creation, after setting all properties.
function bbscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bbscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useBB.
function useBB_Callback(hObject, eventdata, handles)
% hObject    handle to useBB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useBB



function depth_Callback(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of depth as text
%        str2double(get(hObject,'String')) returns contents of depth as a double


% --- Executes during object creation, after setting all properties.
function depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stacode.
function stacode_Callback(hObject, eventdata, handles)
% hObject    handle to stacode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stacode

if get(hObject,'Value') == 1
    disp('Station file should have an extra column with network code')
    
    %% check if we have station_file.isl  
    
    if exist([pwd '\station_file.isl'],'file')
           fid = fopen('station_file.isl','r'); 
              fullstationfile=fgetl(fid);
           fclose(fid);
           handles.fullstationfile=fullstationfile;
           disp([ fullstationfile ' will be used for network code'])
    else  
        [stationfile, newdir] = uigetfile('*.stn;*.dat;*.txt', 'Select seismic station file');
            if stationfile == 0
                disp('Cancel file load')
                handles.fullstationfile='';
            return
            else
                fullstationfile=[ newdir  stationfile]; 
                handles.fullstationfile=fullstationfile;
            end
    end

else
    disp('net code not needed')
end 

guidata(hObject, handles);




% --- Executes on button press in full_DC.
function full_DC_Callback(hObject, eventdata, handles)
% hObject    handle to full_DC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of full_DC


% --- Executes on button press in normsyn.
function normsyn_Callback(hObject, eventdata, handles)
% hObject    handle to normsyn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normsyn

function plotselectedstations(nostations,staname,normalized,invband,ftime,totime,uselimits,dtime,eventid,addvarred,pbw,net_use,fullstationfile,normsynth)
%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

for i=1:nostations
    realdatafilename{i}=[staname{i} 'fil.dat'];
    syntdatafilename{i}=[staname{i} 'syn.dat'];
end

realdatafilename=realdatafilename';
syntdatafilename=syntdatafilename';

% 
% whos staname realdatafilename syntdatafilename
    
%try    
%%%%%%%%%NOW WE KNOW FILENAMES AND WE CAN PLOT .....
%%%%%%%%%go in invert first
 
cd invert

%%%%%%%%%%%initialize data matrices
realdataall=zeros(8192,4,nostations);    %%%% 8192 points  fixed....
syntdataall=zeros(8192,4,nostations); 
maxmindataindex=zeros(1,2,nostations);
maxreal4sta=zeros(nostations);
maxsynt4sta=zeros(nostations);

%%%%open data files and read data
for i=1:nostations
fid1  = fopen(realdatafilename{i},'r');
fid2  = fopen(syntdatafilename{i},'r');

        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';

fclose(fid1);
fclose(fid2);
 

realdataall(:,:,i)=realdata;
maxmindataindex(:,:,i)=findlimits4plot(realdata);    %%% find data limits for plotting  ... June 2010 
syntdataall(:,:,i)=syntdata;
end

% fid  = fopen('allstat.dat','r');
% [station1,useornot,nsw,eww,vew,station] = textread('allstat.dat','%s %u %f %f %f %s');
% fclose(fid);

% only new version of allstat is allowed...

   [station,useornot,nsw,eww,vew,f1,f2,f3,f4] = textread('allstat.dat','%s %u %f %f %f %f %f %f %f',-1);

 %          if isequal(char(station1(1)),'001') && (length(char(station(1)))~=0)
% 
%            disp('Found new allstat.dat format')
%          else
%            [station1,useornot,nsw,eww,vew] = textread('allstat.dat','%s %u %f %f %f',-1); 
%            disp('Found old allstat.dat format')
%            % number of stations
%          end 

for i=1:nostations    %%%%%%loop over stations
      if useornot(i) == 0
          compuse(1,i) = 0;
          compuse(2,i) = 0;
          compuse(3,i) = 0;
      elseif useornot(i) == 1
          if nsw(i) == 0         %%   if weight == 0 component is not used..
             compuse(1,i) = 0;  
          else
             compuse(1,i) = 1;  
          end   

          if eww(i) == 0 
             compuse(2,i) = 0;  
          else
             compuse(2,i) = 1;  
          end   
          
          if vew(i) == 0 
             compuse(3,i) = 0;  
          else
             compuse(3,i) = 1;  
          end   
      end
end
%whos station useornot nsw eww vew
%%%% return to isola

cd ..
     
%catch
%        helpdlg('Error in file plotting. Check if all files exist');
%    cd ..
%end
     
% realdataall=realdataall(:,:,2:nostations+1);
% syntdataall=syntdataall(:,:,2:nostations+1);
% 
% 
% whos realdata syntdata 
%whos realdataall syntdataall


%%%%%%%%%%%%new code to compute varred per comp
k=0;
disp('Variance Reduction per component')

      fprintf(1,'%s \t\t %s \t\t %s \t\t %s\n', 'Station','NS','EW','Z')

for i=1:nostations    %%%%%%loop over stations
  
     for j=1:3                %%%%%%%%loop over components
%          disp(componentname{j})
         
         variance_reduction(i,j)= vared(realdataall(:,j+1,i),syntdataall(:,j+1,i),dtime);
     
     end   
     
fprintf(1, '\t%s \t\t %4.2f \t\t %4.2f \t\t %4.2f\n', staname{i}, variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3))
     
end                   

% whos variance_reduction staname
% staname
%%%%%%%%%%%%%%%%%%% normalize 23/06/05

% if normalized == 1
% 
%     disp('Normalized plot')
% 
%     for i=1:nostations
%         for j=2:4
% 
%              maxreal(i,j)=max(abs(realdataall(:,j,i)));
%              maxsynt(i,j)=max(abs(syntdataall(:,j,i)));
% 
% %                     maxstring=[   num2str(maxreal(i,j)) '  '  staname{i} ];
% %                     disp(maxstring)
% % 
%              
%              realdataall(:,j,i) = realdataall(:,j,i)/max(abs(realdataall(:,j,i)));
%              syntdataall(:,j,i) = syntdataall(:,j,i)/max(abs(syntdataall(:,j,i)));
%              
% %              max(abs(realdataall(:,j,i)))
% %              max(abs(syntdataall(:,j,i)))
% %              
%              
%          end
%     end
%     
%     
% else
% end

%% New type of normalization, based on maximum amplitude of component per station NOT TOTAL maximum

if normalized == 1

    disp('Normalized plot. Using normalization per component ')

    for i=1:nostations
        for j=2:4
             maxreal(i,j)=max(abs(realdataall(:,j,i)));
             maxsynt(i,j)=max(abs(syntdataall(:,j,i)));
        end
        
             maxreal4sta(i)=max(maxreal(i,:)); % maximum per station per component
             maxsynt4sta(i)=max(maxsynt(i,:)); % maximum per station per component for synthetic data
             
        for j=2:4                                              
             
             realdataall(:,j,i) = realdataall(:,j,i)/maxreal4sta(i);
             
             if normsynth==1
                 syntdataall(:,j,i) = syntdataall(:,j,i)/maxsynt4sta(i);  % normalize synthetic 
             else
                 syntdataall(:,j,i) = syntdataall(:,j,i)/maxreal4sta(i);
             end
             
        end
        
        
    end
    
    
else
end

%%%%%%%%%%%%  write varred per component in a file 
try
  cd output
  
   disp(['Saving Variance Reduction per component in ' eventid '_varred_info.txt file in \output folder.']);

    fid = fopen([eventid '_varred_info.txt'],'w');
       if ispc
          fprintf(fid,'%s \t %s \t %s \t %s\r\n', 'Station','NS','EW','Z');
       else
          fprintf(fid,'%s \t %s \t %s \t %s\n', 'Station','NS','EW','Z');
       end
    
    for i=1:nostations    %%%%%%loop over stations
        if ispc
         fprintf(fid, '%s \t\t %4.2f \t %4.2f \t %4.2f\r\n', staname{i}, variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3));
        else
         fprintf(fid, '%s \t\t %4.2f \t %4.2f \t %4.2f\n', staname{i}, variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3));
        end
    end                   

  fclose(fid);
  cd ..
catch
    cd ..
end


%%%%%%%%%% normalize
% realdataall=cat(3,realdataall,realdata);
% syntdataall=cat(3,syntdataall,syntdata);

%%%%%%%%%PLOTTING   
componentname=cellstr(['NS';'EW';'Z ']);

% h=figure
scrsz = get(0,'ScreenSize');

%fh=figure('Tag','Syn vs Obs','Position',[5 scrsz(4)*1/6 scrsz(3)*5/6 scrsz(4)*5/6-50], 'Name','Plotting Obs vs Syn');

fh=figure('Tag','Syn vs Obs','Position',get(0,'Screensize'), 'Name','Plotting Obs vs Syn');
set(gcf,'PaperPositionMode','auto')

mh = uimenu(fh,'Label','Export Figure');
eh1 = uimenu(mh,'Label','Convert to PNG','Callback','exportgraph(1)');
eh2 = uimenu(mh,'Label','Convert to PS','Callback','exportgraph(2)');
eh3 = uimenu(mh,'Label','Convert to EPS','Callback','exportgraph(3)');
eh4 = uimenu(mh,'Label','Convert to TIFF','Callback','exportgraph(4)');
eh5 = uimenu(mh,'Label','Convert to EMF','Callback','exportgraph(5)');
eh6 = uimenu(mh,'Label','Convert to JPG','Callback','exportgraph(6)');
%% select code based on GMT version
% read ISOLA defaults
[gmt_ver,psview,npts] = readisolacfg;
 

if gmt_ver==4
      eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot'); 
else
   %% put code for GMT5 !
   
      eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot5'); 
   
end

% create structure of handles
handles1 = guihandles(fh); 
handles1.nostations=nostations;
handles1.realdatafilename=realdatafilename;
handles1.syntdatafilename=syntdatafilename;
handles1.station=station;
handles1.useornot=useornot;
handles1.compuse=compuse;
handles1.variance_reduction=variance_reduction;
handles1.eventid=eventid;
handles1.ftime=ftime;
handles1.totime=totime;
handles1.maxmindataindex=maxmindataindex;
handles1.invband=invband;
guidata(fh, handles1);

%[100 100 scrsz(3)-200 scrsz(4)-200])
% subplot(nostations+1,3,1:3)

%%  Start by making legend  (top row of plots)
%subplot(nostations+1,3,1)

subplot1(nostations+1,3)  % initialize all plots

subplot1(1)    % selecte top left plot
v=axis;
text( v(1), .7,['Event date-time: ' strrep(eventid,'_','\_')],'FontSize',10,'FontWeight','bold')
axis off
% top mid plot
subplot1(2)
% 
% if pbw == 1
%           plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
%           hold on
%           plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'k','Visible','off');      
%           hold off
%                    [legend_h,object_h,plot_h,text_strings]= legend('Observed','Synthetic',2);
%                     set(legend_h,'FontSize',12)
%                     set(object_h,'LineWidth',2)
%                     set(plot_h(1),'LineWidth',1.5)
%                     set(plot_h(2),'LineWidth',1)
v=axis;
text( v(1), .7,['Displacement (m).  Inversion band (Hz)  ' invband],'FontSize',10,'FontWeight','bold')
axis off
% 
% else
%           plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
%           hold on
%           plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'r','Visible','off');      
%           hold off
%                    [legend_h,object_h,plot_h,text_strings]= legend('Observed','Synthetic',2);
%                     set(legend_h,'FontSize',12)
%                     set(object_h,'LineWidth',2)
%                     set(plot_h(1),'LineWidth',1.5)
%                     set(plot_h(2),'LineWidth',1)
%                     title(['Displacement (m).  Inversion band (Hz)  ' invband],'FontSize',10,'FontWeight','bold')
% axis off
% end


%subplot(nostations+1,3,3)
% top right plot
subplot1(3)

%           plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
%           hold on
%           plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'k','Visible','off');      
%           hold off
% 
%           v=axis;
          
% text( v(1), 1,'Gray waveforms weren''t used in inversion.','Color','k','FontSize',8,'FontWeight','bold');
% text( v(3), 0.5, 'Blue numbers are variance reduction','Color','k','FontSize',8,'FontWeight','bold');

if pbw == 1
          plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
          hold on
          plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'k','Visible','off');      
          hold off
                   [legend_h,object_h,plot_h,text_strings]= legend('Observed','Synthetic');
                    set(legend_h,'FontSize',12)
                    set(object_h,'LineWidth',2)
                    set(plot_h(1),'LineWidth',1.5)
                    set(plot_h(2),'LineWidth',1)
%                    title(['Displacement (m).  Inversion band (Hz)  ' invband],'FontSize',10,'FontWeight','bold')
v=axis;
text( v(1), 1,'Gray waveforms weren''t used in inversion.','Color','k','FontSize',8,'FontWeight','bold');
text( v(3), 0.5, 'Blue numbers are variance reduction','Color','k','FontSize',8,'FontWeight','bold');

axis off

else
          p1=plot(realdataall(:,1,1),realdataall(:,1+1,1),'k', 'LineWidth',1.5);      
          hold on
          p2=plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'r', 'LineWidth',1.);      
          hold off
v=axis;
text( v(1), 0.7,'Gray waveforms weren''t used in inversion.','Color','k','FontSize',8,'FontWeight','bold');
text( v(1), 0.5,'Blue numbers are variance reduction','Color','k','FontSize',8,'FontWeight','bold');
                    leg=legend('Observed','Synthetic','HandleVisibility','on');
                    
                    set(p1, 'visible', 'off');
                    set(p2, 'visible', 'off');   
                    set(leg, 'visible', 'on'); 

axis off
end




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Finish with legend

k=0;
for i=1:nostations    %%%%%%loop over stations
%    realdataall    8192x4x6 
     for j=1:3                %%%%%%%%loop over components
          subplot1(j+k+3);
%          set(gca,'FontSize',8)
          %%%%%%%%%%%%%%%%%%%%%%%%%%%
      if pbw == 1      %% we need b&w plot
           
          if  compuse(j,i) == 1  
          plot(realdataall(:,1,i),realdataall(:,j+1,i),'k',...
                             'LineWidth',2);      
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(realdataall(:,1,i),realdataall(:,j+1,i),...
                             'LineWidth',2,'Color',[.5,0.5,.5]);      
                       
          end                         
          hold on
%%%%%%%%%%                          h = vline(50,'k');
          if  compuse(j,i) == 1  
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'k',...
                             'LineWidth',.8 );  
                         
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),...
                             'LineWidth',.8,'Color',[.5,0,0]);   
                         
 %                set(subplot(nostations+1,3,j+k+3),'Color',[.1,0.1,.1])     
                 
          end                         
          hold off
%     
      else   %%%pbw=0
          
          if  compuse(j,i) == 1  
          plot(realdataall(:,1,i),realdataall(:,j+1,i),'k',...
                             'LineWidth',1.5);      
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(realdataall(:,1,i),realdataall(:,j+1,i),...
                             'LineWidth',1.5,'Color',[.5,0.5,.5]);      
          end                         
          hold on
%%%%%%%%%%                          h = vline(50,'k');
          if  compuse(j,i) == 1  
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'r',...
                             'LineWidth',1. );  
          elseif compuse(j,i) == 0     %%% not used in inversion
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),...
                             'LineWidth',1.,'Color',[.5,0,0]);      
          end                         
          hold off
      end   %%end pbw
          
         if uselimits == 1
                  if normalized == 1
%                     axis ([ftime totime min(realdataall(:,j+1,i)) max(realdataall(:,j+1,i)) ]) ;   
                      axis ([ftime totime -1.0 1.0 ]) ;       
                  else
%                       %%which is larger smaller..?? synth or real..!!
%                          if min(realdataall(:,j+1,i)) <= min(syntdataall(:,j+1,i))
%                              yli1=min(realdataall(:,j+1,i));
%                          else
%                              yli1=min(syntdataall(:,j+1,i));
%                          end
%                          
%                          if max(realdataall(:,j+1,i)) >= max(syntdataall(:,j+1,i))
%                              yli2=max(realdataall(:,j+1,i));
%                          else
%                              yli2=max(syntdataall(:,j+1,i));
%                          end
%                              axis ([ftime totime yli1 yli2 ]) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   Plot using max min values  from real data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   only

                            axis([ftime totime maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
                  end
         else   %%% not use time limits
                 if normalized == 1
                     v=axis;
                     axis([v(1) v(2) -1.0 1.0 ]) ;  
                 else
                     v=axis;
                     axis([v(1) v(2) maxmindataindex(1,2,i) maxmindataindex(1,1,i)]);
                 end
         end

%%%%%%%%%%%%%%%%%%%%%%% Add text in graph 
%%%% AXIS SCALE.....
                
          if i==1
            title(componentname{j},...
              'FontSize',9,...
              'FontWeight','bold');
          end
          
          if i==nostations
          xlabel('Time (sec)')
          
          elseif i~=nostations
               set(gca,'Xtick',[-10 1000])
%               set(gca,'Ytick',[-5 5])
%               set(gca,'Color','none')
              
          end
          
          if  j==1 
            % check if we need network code
               if net_use ==0
                  y=ylabel(staname{i},'FontSize',12,'FontWeight','bold');
                    set(get(gca,'YLabel'),'Rotation',0)
                    set(y, 'Units', 'Normalized', 'Position', [-0.12, 0.5, 0]);
               else
                  %  disp(['Using ' fullstationfile ' station file'])
                    %read data in 3 arrays
                    fullstationfile
                    fid  = fopen(fullstationfile,'r');
                        C= textscan(fid,'%s %f %f %s',-1);
                    fclose(fid);
                    staname_stn=C{1}
                    netcode=C{4}
                      for ii=1:nostations
                          for jj=1:length(staname_stn)
                              if strcmp(char(staname{ii}),char(staname_stn(jj)))
                                    st_netcode(ii)=netcode(jj);
                                  %  disp(['Code for ' char(staname{ii}) ' is ' char(st_netcode(ii))])
                              else
                              end
                          end
                      end
                %% ploting
                    y=ylabel([char(st_netcode(i)) '.' char(staname{i})],'FontSize',12,'FontWeight','bold');
                    set(get(gca,'YLabel'),'Rotation',0);set(y, 'Units', 'Normalized', 'Position', [-0.12, 0.5, 0]);  
               end
          end

%           if  j==2 
%           ylabel('Displacement')
%           end

%%%%%%%%%
%%%%%%%%%                Normalized plotting
%%%%%%%%%          
        if normalized == 1
            if uselimits == 1
                %text( ftime,  1.1, num2str(maxreal(i,j+1),'%8.2E'),'HorizontalAlignment','left','FontSize',8,'FontWeight','bold');   %%% max values
                if j==3
                 text(totime+(totime/10), 0, num2str(maxreal4sta(i),'%8.2E'),'Color','k','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max value of station
                   if normsynth==1
                     text(totime+(totime/10), -0.5, num2str(maxsynt4sta(i),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max syntetic value of station
                   else
                   end
                end
                
               if addvarred == 1   %%%%%%%%%%  print variance                
%                  text( ftime+15, -.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,'FontWeight','bold');
                   text((totime-ftime)*0.05, -.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','left','FontSize',10,...
                      'FontWeight','bold','FontName','FixedWidth');  
               else
               end
%%%%%%%%%%%%%%%%               
            else  % not use limits
                %text( min(realdataall(:,1,i)), 1.2, num2str(maxreal(i,j+1),'%8.2E'),'HorizontalAlignment','left','FontSize',8,'FontWeight','bold');  % max values
                %text( max(realdataall(:,1,i)), 1.2, num2str(maxsynt(i,j+1),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');
                if j==3
                 text(totime+(totime/10), 0, num2str(maxreal4sta(i),'%8.2E'),'Color','k','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max value of station
                   if normsynth==1
                     text(totime+(totime/10), -0.5, num2str(maxsynt4sta(i),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');  % add max syntetic value of station
                   else
                   end
                end
                
               if addvarred == 1   %%%%%%%%%%print variance 
                 v=axis;
                 text((v(2)-v(1))*0.95, -0.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,...
                   'FontWeight','bold','FontName','FixedWidth');  
               else
               end
               
            end
%%%%%%%%%%%%%%%%%%%%
         else    %%% not normalized
            if addvarred == 1
                if uselimits == 0
                    v=axis;
                    ((v(2)-v(1))*0.02)+v(1);
                    text((v(2)-v(1))*0.95, v(4)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,...
                    'FontWeight','bold','FontName','FixedWidth');
                else
                    v=axis;
 %                  text(ftime+15 , v(3)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,'FontWeight','bold');
                   text(((totime-ftime)*0.03)+ftime , v(3)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','left','FontSize',10,...
                       'FontWeight','bold','FontName','FixedWidth');
                    
                end
            else
            end
        end    %%%end of Normalized  if

      end       %%%%%%%loop over components
      
       k=k+3;
       
end   %%%%%%%loop over stations



%% OUTPUT options in isl file
    fid2 = fopen('waveplotoptions.isl','w');

    if normalized == 1
       if ispc  
         fprintf(fid2,'%c\r\n','1');
       else
         fprintf(fid2,'%c\n','1');
       end
     else
       if ispc  
         fprintf(fid2,'%c\r\n','0');
       else
         fprintf(fid2,'%c\n','0');
       end
     end
%%     
     if uselimits == 1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
         if ispc
           fprintf(fid2,'%c\r\n','0');
         else
           fprintf(fid2,'%c\n','0');
         end
     end
%%     
     if ispc
          fprintf(fid2,'%f\r\n',ftime);
          fprintf(fid2,'%f\r\n',totime);
     else
          fprintf(fid2,'%f\n',ftime);
          fprintf(fid2,'%f\n',totime);
     end
%%     
     if addvarred == 1
         if ispc 
            fprintf(fid2,'%c\r\n','1');
         else
            fprintf(fid2,'%c\n','1');
         end
     else
        if ispc 
           fprintf(fid2,'%c\r\n','0');
        else
           fprintf(fid2,'%c\n','0');
        end
     end
%%     
     if pbw==1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
        if ispc 
         fprintf(fid2,'%c\r\n','0');
        else
         fprintf(fid2,'%c\n','0');
        end
     end

%% add new extra features     
      if normsynth==1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
        if ispc 
         fprintf(fid2,'%c\r\n','0');
        else
         fprintf(fid2,'%c\n','0');
        end
     end
%%
      if net_use==1
        if ispc 
         fprintf(fid2,'%c\r\n','1');
        else
         fprintf(fid2,'%c\n','1');
        end
     else
        if ispc 
         fprintf(fid2,'%c\r\n','0');
        else
         fprintf(fid2,'%c\n','0');
        end
     end
%     
    fclose(fid2);


%%
mh = uimenu(fh,'Label','Export Figure');
eh1 = uimenu(mh,'Label','Convert to PNG','Callback','exportgraph(1)');
eh2 = uimenu(mh,'Label','Convert to PS','Callback','exportgraph(2)');
eh3 = uimenu(mh,'Label','Convert to EPS','Callback','exportgraph(3)');
eh4 = uimenu(mh,'Label','Convert to TIFF','Callback','exportgraph(4)');
eh5 = uimenu(mh,'Label','Convert to EMF','Callback','exportgraph(5)');
eh6 = uimenu(mh,'Label','Convert to JPG','Callback','exportgraph(6)');
%% select code based on GMT version
% read ISOLA defaults
[gmt_ver,psview,npts] = readisolacfg;
 

if gmt_ver==4
      eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot'); 
else
   %% put code for GMT5 !
   
      eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot5'); 
   
end
    
    set(get(gca,'YLabel'),'Rotation',0)
 %       cpng


% --- Executes on button press in html.
function html_Callback(hObject, eventdata, handles)
% hObject    handle to html (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

htmlfolder=handles.htmlfolder;

if ~strcmp(htmlfolder,'null')

   lon=handles.Clon; lat=handles.Clat; depth=handles.Cdepth; Mo=handles.CMo; Ctime=handles.Corigin;
   evt_id=handles.eventidnew;
   eventorign=handles.evtorigin;
   
   % we need to calculate the Centroid Time exactly not relative to Origin
   % start from 
   AA=sscanf(eventorign,'%f',4);
   OriginTime=datetime(str2num(eventorign(1:4)),str2num(eventorign(5:6)),str2num(eventorign(7:8)),AA(2),AA(3),AA(4));
   CentroidTime=datestr(OriginTime+seconds(Ctime),'yyyy/mm/dd HH:MM:SS.FFF');
   
   mw=(2.0/3.0)*log10(str2num(Mo)) - 6.0333;  % changed 06/11/2020 
      
   ok=htmlexport(evt_id,CentroidTime,lat,lon,depth,num2str(mw,'%4.2f') ,Mo);
   
   % check if we have the png files we need in output folder
    inv1=[evt_id '_inv1.png'];best=[evt_id '_best.png'];corr=[evt_id '_corr01.png'];wave=[evt_id '_wave.png'];
       if ~exist(['.\output\' inv1])
          errordlg(['File '  inv1  ' not found in output folder'],'File Error');
       else
       end
       if ~exist(['.\output\' best])
          errordlg(['File '  best  ' not found in output folder'],'File Error');
       else
       end
       if ~exist(['.\output\' corr])
          errordlg(['File '  corr  ' not found in output folder'],'File Error');
       else
       end
       if ~exist(['.\output\' wave])
          errordlg(['File '  wave  ' not found in output folder'],'File Error');
       else
       end
       
       %% make event folder in web solution html folder
       [status, msg, msgID] = mkdir([htmlfolder evt_id]);
          
       %% copy files to proper folder
       filename=[evt_id '_MTsol.html'];
       copyfile(filename,[htmlfolder evt_id])
       %% 
       copyfile(['.\output\' inv1],[htmlfolder evt_id])
       copyfile(['.\output\' best],[htmlfolder evt_id])
       copyfile(['.\output\' corr],[htmlfolder evt_id])
       copyfile(['.\output\' wave],[htmlfolder evt_id])
       copyfile('.\invert\mtsol.txt',[htmlfolder evt_id])
       
       msgbox('Operation Completed. Check command window for errors.');
       

else
    
    helpdlg('If you want html output change the HTML FOLDER variable in isolacfg.isl ','Info');
    
end


