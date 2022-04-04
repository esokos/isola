function varargout = envplot(varargin)
% ENVPLOT MATLAB code for envplot.fig
%      ENVPLOT, by itself, creates a new ENVPLOT or raises the existing
%      singleton*.
%
%      H = ENVPLOT returns the handle to a new ENVPLOT or the handle to
%      the existing singleton*.
%
%      ENVPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENVPLOT.M with the given input arguments.
%
%      ENVPLOT('Property','Value',...) creates a new ENVPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before envplot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to envplot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help envplot

% Last Modified by GUIDE v2.5 20-May-2017 12:46:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @envplot_OpeningFcn, ...
                   'gui_OutputFcn',  @envplot_OutputFcn, ...
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


% --- Executes just before envplot is made visible.
function envplot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to envplot (see VARARGIN)

% Choose default command line output for envplot
handles.output = hObject;

% position figure according to main gui
%  figpos=get(envinv,'position');
%  l=figpos(1); b=figpos(2); w=figpos(3); h=figpos(4);
%  
% %set(envplot,'Position', [l+w+2, b, 200, h])
% set(handles.envplot,'Position', [l+w+2, b,600, h]);

% Check if we have plot options

h=dir('waveplotoptionsenv.isl');

if length(h) == 1; 
    fid = fopen('waveplotoptionsenv.isl','r');
    nor=fscanf(fid,'%f',1);
    usel=fscanf(fid,'%f',1);
    ftime=fscanf(fid,'%f',1);
    totime=fscanf(fid,'%f',1);
    pvar=fscanf(fid,'%f',1);
    pbw=fscanf(fid,'%f',1);
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

%         if pbw==1
%             set(handles.bw,'Value',1)
%         elseif pbw==0
%             set(handles.bw,'Value',0)
%         end
else
    disp('wave plot options not found')
end


%% prepare event id...

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

eventid=[eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec  ];
eventidnew=[eventdate(3:8) '_' eventhour '_' eventmin '_' eventsec  ];

%% read names of files for plotting
% read allstat.dat
if ispc
   h=dir('.\env_amp_inv\allstat.dat');
else
   h=dir('./env_amp_inv/allstat.dat');
end
   
if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in env_amp_inv folder.','File Error');
     return
else

                    if ispc 
                       [staname,~,~,~,~,f1,~,~,f4] = textread('.\env_amp_inv\allstat.dat','%s %f %f %f %f %f %f %f %f',-1)
                    else
                       [staname,~,~,~,~,f1,~,~,f4] = textread('./env_amp_inv/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                    end
                    
                 % number of stations
                 nostations = length(staname)
                 
                   for i=1:nostations
                      realfilfilename{i}=[char(staname{i}) 'fil.dat'];
                      realsynfilename{i}=[char(staname{i}) 'syn.dat'];
                   end
        % now check if all files are present 
           cd env_amp_inv
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
               
end              
       
%%% add All option
staname{nostations+1,1}='All';
%staname

%% read inversion specific data....
% if ispc 
%    a=exist('.\invert\inpinv.dat','file');
% else
%    a=exist('./invert/inpinv.dat','file');
% end
% 
% if a==2
%    if ispc
%       [id,dtime,nsubevents,~,~,invband,~] = readinpinv('.\invert\inpinv.dat');
%    else
%       [id,dtime,nsubevents,~,~,invband,~] = readinpinv('./invert/inpinv.dat');
%    end
%       
% 
% 
% else
%     disp('Please run inversion ... Inpinv.dat is missing..')
% end

h=dir('tsources.isl');

if isempty(h); 
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

%%
% 
% handles.id=id;
% handles.dtime=dtime;
% handles.nostations=nostations;
% handles.staname=staname;
% handles.eventid=eventid;
% handles.eventidnew=eventidnew;
% handles.nsubevents=nsubevents;
% 
% % Update handles structure
% guidata(hObject, handles);
% 
set(handles.stationslistbox,'String',staname)          %%%%% Fill listbox with stations names
set(handles.stationslistbox,'Value',nostations+1)      %%%%% Set default plot to All stations
% 
  fid = fopen('.\env_amp_inv\inp.dat','r');
    tline = fgets(fid);
    tline = fgets(fid);
    tline = fgets(fid);
    tline = fgets(fid);
    dtime=sscanf(tline,'%f')
    
  fclose(fid);

handles.dtime=dtime;

%%
handles.nostations=nostations;
handles.staname=staname;
handles.eventid=eventid;


invband=[num2str(min(f1)) ' - ' num2str(max(f4))];

handles.invband=invband;
handles.fullstationfile='';
handles.conplane=conplane;
handles.nsources=nsources;
handles.eventcor=eventcor;
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes envplot wait for user response (see UIRESUME)
% uiwait(handles.envplot);


% --- Outputs from this function are returned to the command line.
function varargout = envplot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in check1.
function check1_Callback(hObject, eventdata, handles)
% hObject    handle to check1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check1


% --- Executes on button press in svarred.
function svarred_Callback(hObject, eventdata, handles)
% hObject    handle to svarred (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of svarred


% --- Executes on button press in uselimits.
function uselimits_Callback(hObject, eventdata, handles)
% hObject    handle to uselimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of uselimits



function ftime_Callback(hObject, eventdata, handles)
% hObject    handle to ftime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ftime as text
%        str2double(get(hObject,'String')) returns contents of ftime as a double


% --- Executes during object creation, after setting all properties.
function ftime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ftime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totime_Callback(hObject, eventdata, handles)
% hObject    handle to totime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totime as text
%        str2double(get(hObject,'String')) returns contents of totime as a double


% --- Executes during object creation, after setting all properties.
function totime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in stationslistbox.
function stationslistbox_Callback(hObject, eventdata, handles)
% hObject    handle to stationslistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stationslistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stationslistbox


% --- Executes during object creation, after setting all properties.
function stationslistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stationslistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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

%%%%%%%%%%%%%FIND OUT USER SELECTION %%%%%%%%%%%%%%
%%%%%%%%%%% code based on Matlab example of list box....!!!

index_selected = get(handles.stationslistbox,'Value');

if length(index_selected)==1   %%% plot ONE or ALL stations ONLY
    
    if index_selected == nostations+1                          %%%ALL
          disp('Plotting All Stations Real data in one Figure')
          plotallstationsRealenv(nostations,staname,uselimits,ftime,totime)
    elseif index_selected ~= nostations+1                       %%% just one
          disp('Plotting ONLY One Station Real data in one Figure')
          stationname=staname{index_selected};
          plotonestationrealenv(stationname,uselimits,ftime,totime)
    end
      
elseif length(index_selected) ~=1   %%%Plot more than one and maybe ALL stations...
    
      for i=1:length(index_selected)
          
         if index_selected(i) ~= nostations+1
             disp('Plotting selected stations Real data ')
             stationname=staname{index_selected(i)};
             plotonestationrealenv(stationname,uselimits,ftime,totime)
         elseif index_selected(i) == nostations+1
             disp('Plotting All Stations Real data in one Figure')
             plotallstationsRealenv(nostations,staname,uselimits,ftime,totime)
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

%%%%%%%%%%%%%FIND OUT USER SELECTION %%%%%%%%%%%%%%
%%%%%%%%%%% code based on Matlab example of list box....!!!

index_selected = get(handles.stationslistbox,'Value');

if length(index_selected)==1   %%% plot ONE or ALL stations ONLY
    
    if index_selected == nostations+1                          %%%ALL
          disp('Plotting All Stations Synthetic data in one Figure')
          plotallstationssynenv(nostations,staname,uselimits,ftime,totime)
    elseif index_selected ~= nostations+1                       %%% just one
          disp('Plotting ONLY One Station Synthetic data in one Figure')
          stationname=staname{index_selected};
          plotonestationsynenv(stationname,uselimits,ftime,totime)
    end
      
elseif length(index_selected) ~=1   %%%Plot more than one and maybe ALL stations...
    
      for i=1:length(index_selected)
          
         if index_selected(i) ~= nostations+1
             disp('Plotting selected stations Synthetic data ')
             stationname=staname{index_selected(i)};
             plotonestationsynenv(stationname,uselimits,ftime,totime)
         elseif index_selected(i) == nostations+1
             disp('Plotting All Stations Synthetic data in one Figure')
             plotallstationssynenv(nostations,staname,uselimits,ftime,totime)
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

%% inversion band
% invband=handles.invband
% compute inversion band again
if ispc 
    [~,~,~,~,~,f1,~,~,f4] = textread('.\env_amp_inv\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
else
    [~,~,~,~,~,f1,~,~,f4] = textread('./env_amp_inv/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
end
invband=[num2str(min(f1)) ' - ' num2str(max(f4))];
%%
eventid=handles.eventid;
dtime=handles.dtime;

nostations=handles.nostations;
staname=handles.staname;
%%%%%%%%%%%%%FIND OUT USER SELECTION %%%%%%%%%%%%%%
%%%%%%%%%%% code based on Matlab example of list box....!!!

index_selected = get(handles.stationslistbox,'Value');
normalized = get(handles.check1,'Value');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uselimits=get(handles.uselimits,'Value');

ftime =  str2double(get(handles.ftime,'String'));
totime = str2double(get(handles.totime,'String'));

addvarred = get(handles.svarred,'Value');

% pbw = get(handles.bw,'Value');
% net_use=get(handles.stacode,'Value');
% fullstationfile=handles.fullstationfile;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pwd

if length(index_selected)==1   %%% plot ONE or ALL stations ONLY
    
    if index_selected == nostations+1                          %%%ALL
          disp('Plotting All Stations Real-Synthetic data in one Figure')
          plotallstationsenv(nostations,staname,normalized,invband,ftime,totime,uselimits,dtime,eventid,addvarred,0,0,'0')
    elseif index_selected ~= nostations+1                       %%% just one
          disp('Plotting ONLY One Station  Real-Synthetic  data in one Figure')
          stationname=staname{index_selected};
          plotonestationenv(stationname,normalized,ftime,totime,uselimits)
    end
      
elseif length(index_selected) ~=1   %%%Plot more than one and maybe ALL stations...
    
      for i=1:length(index_selected)
          
         if index_selected(i) ~= nostations+1
             disp('Plotting selected stations  Real-Synthetic  data ')
             stationname=staname{index_selected(i)};
             plotonestationenv(stationname,normalized,ftime,totime,uselimits)
         elseif index_selected(i) == nostations+1
             disp('Plotting All Stations  Real-Synthetic  data in one Figure')
             plotallstationsenv(nostations,staname,normalized,dtime,eventid)
         else
             disp('Error')
         end
          
      end
      
else
disp('Error')
end


% --- Executes on button press in addpol.
function addpol_Callback(hObject, eventdata, handles)
% hObject    handle to addpol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   

%% open station.dat   
h=dir('.\env_amp_inv\station.dat');

if isempty(h); 
  disp('Station.dat file doesn''t exist. Copy from polarity folder. ');
  [s,mess,messid]=copyfile('.\polarity\station.dat','.\env_amp_inv\station.dat');
else
end

% now enter folder and open file
cd env_amp_inv
 if ispc
    dos('notepad station.dat &')
 else
    unix('gedit station.dat &')
 end

cd ..

% --- Executes on button press in plpol.
function plpol_Callback(hObject, eventdata, handles)
% hObject    handle to plpol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Copy files 
[s,mess,messid]=copyfile('.\env_amp_inv\inv2.dat','.\env_amp_inv\moremech.dat');
 
if s== 1
    disp('Copied inv2.dat in env_amp_inv folder as moremech.dat')
end

fileID = fopen('.\env_amp_inv\inv2.dat');
C = textscan(fileID,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
fclose(fileID);

% check if last line has 0 in first column = mean solution
mcheck=C{1,1};
if mcheck(end)==0
   % we have mean solution
      tmp=cell2mat(C);
      meansol=tmp(end,:);
else
end

sorted=sortrows(cell2mat(C),17);
bestsol=sorted(1,:);

fid2 = fopen('.\env_amp_inv\onemech.dat','w');
  fprintf(fid2,'%u %6.2f %E %4.0f %2.0f %3.0f %4.0f %2.0f %3.0f %4.0f %3.0f %4.0f %3.0f %4.0f %3.0f %4.1f %E', bestsol); 
fclose(fid2);


disp('  ')
disp(['Best solution: Strike= ' num2str(bestsol(4)) '  Dip= ' num2str(bestsol(5)) '  Rake= ' num2str(bestsol(6)) ])
disp(['Best solution: Strike= ' num2str(bestsol(7)) '  Dip= ' num2str(bestsol(8)) '  Rake= ' num2str(bestsol(9)) ])
disp(['Misfit = '  num2str(bestsol(17))])

%%
cd env_amp_inv


%% run angone    !!!!!!!!!!!  check if source is on some interface..???
% read crustal model...

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

% read source.dat
fid  = fopen('source.dat','r');
[lon,lat,depth,mag,tt] = textread('source.dat','%f %f %f %f %s','headerlines',2);
fclose(fid);
% we have read both files check if depth = interface...

for i=1:length(model_depths)
    if depth == model_depths(i)
        disp(['Source depth  ' num2str(depth) ' equals CRUSTAL.DAT interface no ' num2str(i) ' ANGONE.EXE doesn''t like this. Adding 0.1 to depth'])
        warndlg(sprintf(['Source depth  ' num2str(depth) ' equals CRUSTAL.DAT interface no ' num2str(i) ' \n ANGONE.EXE doesn''t like this. Adding 0.1 to depth']))
        
        depth=depth+0.1;
        
         % prepare new source.dat ...
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
    c(nlayers+1,2)=c(nlayers,2);
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

%%
%%%%%check if extrapol.pol exists...
h=dir('extrapol.pol');
if isempty(h) 
  disp('Extrapol.pol file doesn''t exist. ');
  
else
     disp('Found extrapol.pol file. Extra station polarities will be used');
  fid  = fopen('extrapol.pol','r');
    [stanamextra,stalatextra,stalonextra,stapolextra] = textread('extrapol.pol','%s %f %f %s',-1);
  fclose(fid);

  %fix origin on the epicenter
  eventcor=handles.eventcor;
  orlat=eventcor(2);  orlon=eventcor(1);

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

%%   RUN ANGONE  %%%%%%%%%%%%%%

[status, result] = system('angone.exe');

%% find how many stations we have check the station.dat

    fid = fopen('station.dat','r');
          C=textscan(fid,'%f %f %f %f %f %s %s ','HeaderLines', 2);
    fclose(fid);
    
    nostations=length(C{1})

%%  pause here if user wants to change mypol...
%uiwait(helpdlg('Edit .\polarity\mypol.dat (IF you want) and press OK'));
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
fid  = fopen('onemech.dat','r');
[iso,tim,mom,s1,di1,r1,s2,di2,r2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,var] = textread('onemech.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',-1);
fclose(fid);
%%
fid  = fopen('moremech.dat','r');
[isom,timm,momm,s1m,di1m,r1m,s2m,di2m,r2m,aziPm,plungePm,aziTm,plungeTm,aziBm,plungeBm,dcm,varm] = textread('moremech.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',-1);
fclose(fid);

%%
cd ..


colnod=get(handles.colnodal,'Value');


pwd

%% Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DC plot
% prepare a circle
disp('DC plot')

% PLOT
% prepare a circle

h1=figure; %('Renderer','zbuffer');

%circle([10,10],5,2000,'-'); 
mech=[s1(1,1) di1(1,1) r1(1,1)];

% plot of onemech.dat

bb([s1(1,1) di1(1,1) r1(1,1)],10,10,5,0,[138/255 138/255 138/255])    % plot beach ball
hold on
axis square;
axis off

%%% plot onemech P,T axis
for i=1:length(iso)
    
    [ax2,ay2]=pltsymdc(90-plungeP(i,1),aziP(i,1));
    
    plot(ax2,ay2,'Marker','s',...
                 'MarkerEdgeColor','b',...
                 'MarkerFaceColor','b',...
                 'MarkerSize',12)
    
    text(ax2(i)+0.1,ay2(i)+0.1,'P','FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom',...
                            'Color','b',...
                            'FontWeight','bold');
                        
    [ax2,ay2]=pltsymdc(90-plungeT(i,1),aziT(i,1));
    
    plot(ax2,ay2,'Marker','o',...
                 'MarkerEdgeColor','y',...
                 'MarkerFaceColor','y',...
                 'MarkerSize',12)
    
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
end
% 


%% Plot moremech
clear x y x1 y1 
if length(isom) > 1  % moremech has more solutions than onemech..

 if colnod == 1  % use color 

    sdr_col=colormap(jet(length(isom)));  % prepare colors per sdr triplet
    
  for ii=1:length(isom)
    
    [x,y]=plpldc(s1m(ii),di1m(ii));
    plot(x,y,'-','Color', sdr_col(ii,:), 'LineWidth', 1.5);

    [x1,y1]=plpldc(s2m(ii,1),di2m(ii,1));
    plot(x1,y1,'-','Color', sdr_col(ii,:), 'LineWidth', 1.5);
    
    [ax2m,ay2m]=pltsymdc(90-plungePm(ii,1),aziPm(ii,1));
    plot(ax2m,ay2m,'Marker','s',...
                 'MarkerEdgeColor',sdr_col(ii,:) ,...
                 'MarkerFaceColor',sdr_col(ii,:))
    [ax2m,ay2m]=pltsymdc(90-plungeTm(ii,1),aziTm(ii,1));
    plot(ax2m,ay2m,'Marker','o',...
                 'MarkerEdgeColor',sdr_col(ii,:),...
                 'MarkerFaceColor',sdr_col(ii,:))
  end

 else % don't use color
    
  for ii=1:length(isom)
    
    [x,y]=plpldc(s1m(ii),di1m(ii));
    plot(x,y,'-','Color', 'k', 'LineWidth', 1.5);

    [x1,y1]=plpldc(s2m(ii,1),di2m(ii,1));
    plot(x1,y1,'-','Color', 'k', 'LineWidth', 1.5);
    
    [ax2m,ay2m]=pltsymdc(90-plungePm(ii,1),aziPm(ii,1));
    plot(ax2m,ay2m,'Marker','s',...
                 'MarkerEdgeColor','k' ,...
                 'MarkerFaceColor','k')
    [ax2m,ay2m]=pltsymdc(90-plungeTm(ii,1),aziTm(ii,1));
    plot(ax2m,ay2m,'Marker','o',...
                 'MarkerEdgeColor','k',...
                 'MarkerFaceColor','k')
  end
    
    
 end    % use color if end
  
else % only one solution
    
end
%% plot mean
if mcheck(end)==0
   
    meanstr1=meansol(4)
    meandip1=meansol(5)
    meanstr2=meansol(7)
    meandip2=meansol(8)
    meanplungP=meansol(11)
    meanaziP=meansol(10)
    meanplungT=meansol(13)
    meanaziT=meansol(12)

    
         [x,y]=plpldc(meanstr1,meandip1);
         plot(x,y,'--','Color', 'k', 'LineWidth', 2.5);

         [x1,y1]=plpldc(meanstr2,meandip2);
         plot(x1,y1,'--','Color', 'k', 'LineWidth', 2.5);
    
         [ax2m,ay2m]=pltsymdc(90-meanplungP,meanaziP);
         plot(ax2m,ay2m,'Marker','s',...
                 'MarkerEdgeColor','k' ,...
                 'MarkerFaceColor','k')
         [ax2m,ay2m]=pltsymdc(90-meanplungT,meanaziT);
         plot(ax2m,ay2m,'Marker','o',...
                 'MarkerEdgeColor','k',...
                 'MarkerFaceColor','k')
    
else
    
end



%legend
%
plot(10,10,'+','MarkerSize',8)
text (10,15.2,'0','FontSize',12);          
text (9.6,4.5,'180','FontSize',12);  
text (15.2,10,'90','FontSize',12);          
text (4. ,10,'270','FontSize',12);        
text (13 ,15.2,'Strike/Dip/Rake' ,'FontSize',14);   
text (13 ,14.6,[ num2str(s1(1,1)) '/' num2str(di1(1,1)) '/' num2str(r1(1,1)) ],'FontSize',14); 
text (13 ,14.0,[ num2str(s2(1,1)) '/' num2str(di2(1,1)) '/' num2str(r2(1,1)) ],'FontSize',14); 

% --- Executes on button press in inv1.
function inv1_Callback(hObject, eventdata, handles)
% hObject    handle to inv1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%  plot results in GMT ..using inv1.dat
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
h=dir('env_amp_inv');

if isempty(h);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%% read out3
[totalgs,selectedsrc,selectedgrid,strike,dip,rake,Mo,Mw] = readout3
  
%%
cd env_amp_inv

h=dir('inv1.dat');    % It will read the first subevent only......

if isempty(h); 
    errordlg('inv1.dat file doesn''t exist.','File Error');
    cd ..
  return    
else
    fid = fopen('inv1.dat','r');
       line=fgets(fid);        %01 line
       line=fgets(fid);        %02 line
       line=fgets(fid);        %03 line
       a=fscanf(fid,'%f %f %f %e %f %f %f %f %f %f %f',[11 nsources]);
       a=a';
    fclose(fid);
end

srcpos=a(:,1);gspoint=a(:,2);cor=a(:,3);dc=a(:,5);
sdr1=a(:,6);dip1=a(:,7);rake1=a(:,8);

%%

figure;
%%
 subplot 212

 plot(srcpos,cor,'+k','LineWidth',1.5,'MarkerSize',20)
 hold
 plot(srcpos,cor,'--k','LineWidth',1.5)

 xlabel('Source number');
 ylabel('Correlation');
 grid on

 v=axis;axis([0.7 srcpos(end)+0.3 v(3) v(4)]);

 get(gca,'xtick');
 get(gca,'xticklabel');
 set(gca,'xtick',[0:srcpos(end)+1]);
 xlab=num2str([0:srcpos(end)+1]);
 set(gca,'fontsize',14)
 set(gca,'linewidth',1.5)

 
%%  hold
ah=subplot(2,1,1);
currentPos = get(ah,'Position');
set(ah,'Position',currentPos - [0,.15,0,0]);


for i=1:length(srcpos)
  bb([sdr1(i) dip1(i) rake1(i)], srcpos(i), cor(i), .2, 0, 'r')
end

% % decide about Y axis limits very simple approach !!
% ymin=min(cor);
% 
% if ymin >=0.5
%     ylowlim=0.5;
% elseif  ymin <0.5
%      ylowlim=0;
% end
%     

% ymin=min(cor);ymax=max(cor);
% 
% if ymin==ymax
%    
%     ylowlim=ymin-0.2;
%     yhighlim=ymin;
%     
% else
%     
%     d=max(cor)-min(cor)
%     
%     if d <0.2
%        d=0.5; 
%     else
%         
%     end
%     
%     ylowlim=min(cor)-d/3;
%     yhighlim=max(cor)+d/3;
%     
%     if yhighlim>1
%         yhighlim=1;
%     end
%     if ylowlim<0
%         ylowlim=0;
%     end
% 
% end

% xlabel('Source number');
% ylabel('Correlation');
% grid on
axis equal
% v=axis;
% axis([0.7 srcpos(end)+0.3 ylowlim 1.3]);
 v=axis;axis([0.7 srcpos(end)+0.3 .7 v(4)]);

axis off

%% add out3 info
% Optimum source number
% Optimum s/d/r without polarity check
% and Mw
text(0.75,1.95,['Selected source no : ' num2str(selectedsrc)],'FontSize',14)
text(0.75,1.75,['s/d/r : ' num2str(strike) '/' num2str(dip) '/' num2str(rake)],'FontSize',14)
text(0.75,1.55,['Mw : ' num2str(Mw,'%4.2f')],'FontSize',14)

cd ..


% --- Executes on button press in plgrid.
function plgrid_Callback(hObject, eventdata, handles)
% hObject    handle to plgrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% here we need to know if Check polarities is selected

% henvinv = findobj('Tag','envinv');
% 
% if isempty(henvinv)
%     errordlg('Cannot find envinv GUI','Error')
%     return
% else
%     envinvdata = guidata(henvinv);
%     
%       if (get(envinvdata.checkpolopt,'Value') == get(envinvdata.checkpolopt,'Max'))
%          pldiam=1;
%          disp('Check polaties was selected')
%       else
%          pldiam=0;
%          disp('Check polaties wasn''t selected')
%       end
% end

% we'll use the file option..! since findobj fails in some cases.!

h=dir('checkpol.isl');     
if isempty(h); 
    errordlg('checkpol.isl file doesn''t exist. ','File Error');
  return    
else
end

fileID = fopen('checkpol.isl');
pldiam = cell2mat(textscan(fileID,'%u'));
fclose(fileID);

      if pldiam == 1
         disp('Check polaties was selected')
      elseif pldiam==0;
         disp('Check polaties wasn''t selected')
      end


%%  
cd env_amp_inv

h=dir('out1.dat');     
if isempty(h); 
    errordlg('out1.dat file doesn''t exist. ','File Error');
    cd ..
  return    
else
end

h=dir('out4.dat');    
if isempty(h); 
    errordlg('out4.dat file doesn''t exist. ','File Error');
    cd ..
  return    
else
end

h5=dir('out5.dat');     
if isempty(h5); 
    disp('out5.dat file doesn''t exist. ')
else
end

%% read files
fileID = fopen('out1.dat');
out1 = textscan(fileID,'%f %f %f %f %f');
fclose(fileID);

fileID = fopen('out4.dat');
out4 = textscan(fileID,' %f %f %f %f  %f %f %f %f');
fclose(fileID);

if pldiam==1
 fileID = fopen('out5.dat');
   out5 = textscan(fileID,' %f %f %f %f  %f %f %f %f');
 fclose(fileID);
else
end
%% plot
gridpoint=out1{1,1};
corr=out1{1,5};

grdp4=out4{1,1};
cor4=out4{1,7};

if pldiam==1
grdp5=out5{1,1};
cor5=out5{1,7};
else
end

figure
plot(gridpoint,corr,'+')
hold
plot(grdp4,cor4,'o',...
        'LineWidth',2,...
        'MarkerSize',20,...
        'MarkerEdgeColor','b')
if pldiam==1    
plot(grdp5,cor5,'rd',...
        'LineWidth',2,...
        'MarkerSize',10,...
        'MarkerEdgeColor','r')
else
end

xlabel('Grid point');
ylabel('Misfit');

set(gca,'fontsize',14)
set(gca,'linewidth',1.5)

if pldiam==1    
 legend('Grid points','Without polarity check','With polarity check')
else
 legend('Grid points','Without polarity check')   
end

cd ..


% --- Executes on button press in colnodal.
function colnodal_Callback(hObject, eventdata, handles)
% hObject    handle to colnodal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of colnodal
