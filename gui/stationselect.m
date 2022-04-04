function varargout = stationselect(varargin)
% STATIONSELECT M-file for stationselect.fig
%      STATIONSELECT, by itself, creates a new STATIONSELECT or raises the existing
%      singleton*.
%
%      H = STATIONSELECT returns the handle to a new STATIONSELECT or the handle to
%      the existing singleton*.
%
%      STATIONSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATIONSELECT.M with the given input arguments.
%
%      STATIONSELECT('Property','Value',...) creates a new STATIONSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stationselect_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stationselect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stationselect

% Last Modified by GUIDE v2.5 16-Sep-2015 12:41:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stationselect_OpeningFcn, ...
                   'gui_OutputFcn',  @stationselect_OutputFcn, ...
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


% --- Executes just before stationselect is made visible.
function stationselect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stationselect (see VARARGIN)

% Choose default command line output for stationselect
handles.output = hObject;

% UIWAIT makes stationselect wait for user response (see UIRESUME)
% uiwait(handles.stationselect);
disp('              ');
%%% Check if event file exists...
h=dir('event.isl');

if isempty(h); 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
disp(['Found '  h.name  ' file in current folder. Reading'])    
disp('              ');
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    fclose(fid);
end
% check which stn files exist in ISOLA installation folder..
% s=which('isola.m');
% stnfilepath=strrep(s,'isola.m','');    
% stn_files=dir([stnfilepath '*.stn']);
% stn_file1=char(stn_files.name); 
% set(handles.listbox2,'String',stn_file1);
%%% Check if station file exists in current folder ...
 if exist([pwd '\station_file.isl'],'file')
     fid = fopen('station_file.isl','r'); 
        fullstationfile=fgetl(fid);
     fclose(fid);
        set(handles.selectedfile,'String',fullstationfile)
        
        if ispc
              h=dir([pwd '\*.stn']);
        else
              h=dir([pwd '/*.stn']);
        end
        if isempty(h); 
            disp('Didn''t find a station file (*.stn) in current folder.')  
            disp('              ');
            set(handles.listbox2,'String','');
        else
            disp(['Found '  h.name  ' file in current folder ... select one as default'])    
            disp('              ');
            stationfile=h.name;
            if ispc
             newdir=[pwd '\'];
            else
             newdir=[pwd '/'];
            end
            stn_file1=char(h.name); 
            set(handles.listbox2,'String',stn_file1);
        end
%         % retrieve filename
%         if ispc
%             stn_file1=fliplr(sscanf(strrep(fliplr(fullstationfile),'\',' '),'%s',1));
%         else
%            stn_file1=fliplr(sscanf(strrep(fliplr(fullstationfile),'/',' '),'%s',1));
%         end
%         set(handles.listbox2,'String',stn_file1);
 else
        if ispc
              h=dir([pwd '\*.stn']);
        else
              h=dir([pwd '/*.stn']);
        end
        if isempty(h); 
            disp('Didn''t find a station file (*.stn) in current folder.')  
            disp('              ');
            warndlg('Didn''t find a station file  (*.stn)  in current folder. ','File Error');
            set(handles.selectedfile,'String',' ')
        else
            disp(['Found '  h.name  ' file in current folder ... select one as default'])    
            disp('              ');
            stationfile=h.name;
            if ispc
             newdir=[pwd '\'];
            else
             newdir=[pwd '/'];
            end
            set(handles.selectedfile,'String',[newdir stationfile])
            stn_file1=char(h.name); 
            set(handles.listbox2,'String',stn_file1);
        end
 end
        
%sel_sta=findobj(hObject,'Type','radiobutton') 
%%%%% write in handles
handles.eventcor=eventcor;
handles.epidepth=epidepth;
handles.magn=magn;
handles.eventdate=eventdate;
handles.eventhour=eventhour;
handles.eventmin=eventmin;
handles.eventsec=eventsec;
%
handles.stnfilepath=pwd;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = stationselect_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is stationselect 16/09/2015');

% --- Executes on button press in selfile.
function selfile_Callback(hObject, eventdata, handles)
% hObject    handle to selfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get file information from user

% --- Executes on button press in Mapit.
function Mapit_Callback(hObject, eventdata, handles)
% hObject    handle to Mapit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plot_method=1;  % 1 = m_map,  anything else means matlab native ploting code
                % quick and dirty solution for ploting problems..!

%% read event data from handles
eventcor=handles.eventcor;
epidepth=handles.epidepth;
magn=handles.magn;
eventdate=handles.eventdate;
eventhour=handles.eventhour;
eventmin=handles.eventmin;
eventsec=handles.eventsec;

%% Create the OT 
OT=[str2double(eventdate(1:4)) str2double(eventdate(5:6)) str2double(eventdate(7:8)) str2double(eventhour) str2double(eventmin) str2double(eventsec)];
% 
%dt_or = datestr(OT, 'mmmm dd, yyyy HH:MM:SS.FFF AM')
% read the taper.isl
if exist([pwd '\' 'taper.isl'],'file')
       fid  = fopen('taper.isl','r');
           taper = cell2mat(textscan(fid, '%f'));
       fclose(fid);
else
           taper=0;    
           disp('Safety interval  =0')
end


%% disable taper i.e. safety interval 
taper=0;



RelativeTime = ([0, 0, taper] * [3600; 60; 1]) / 86400;
OTnew=datenum(OT)-RelativeTime;

new_OT=datevec(OTnew);

dt_new = datestr(OTnew, 'mmmm dd, yyyy HH:MM:SS.FFF');

%% read plotting parameter
selarea=str2double(get(handles.selarea,'String'));

%%%% Read station file ...
fullstationfile=get(handles.selectedfile,'String');

%print file name
disp(['Using ' fullstationfile ' station file'])

staname=[];stalat=[];stalon=[];

%% check if station file has 4 columns..!
   fid  = fopen(fullstationfile,'r');
          t = fgets(fid);
   fclose(fid);       
          tmp = textscan(t, '%s','MultipleDelimsAsOne',1);
          
if length(tmp{1}) ==3
%read data in 3 arrays
    fid  = fopen(fullstationfile,'r');
    C= textscan(fid,'%s %f %f',-1);
    fclose(fid);
    staname=C{1};
    stalat=C{2};
    stalon=C{3};
elseif length(tmp{1}) ==4
    fid  = fopen(fullstationfile,'r');
    C= textscan(fid,'%s %f %f %s',-1);
    fclose(fid);
    staname=C{1};
    stalat=C{2};
    stalon=C{3};    
end
%% save an isl file with full path to station file
fid  = fopen('station_file.isl','w');
  fprintf(fid,'%s',fullstationfile);
fclose(fid);

%% save  this file to \gmtfiles folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if exists..!
h=dir('gmtfiles');

if isempty(h)
    errordlg('Gmtfiles folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Found  '  num2str(length(stalat)) ' stations in station file.']);
 
try
    cd gmtfiles
      fid  = fopen('allstations.gmt','w');     
               for i=1:length(stalat)
                   if ispc 
                     fprintf(fid,'%s %f %f\r\n',staname{i},stalat(i),stalon(i));
                   else
                     fprintf(fid,'%s %f %f\r',staname{i},stalat(i),stalon(i));
                   end
               end
      fclose(fid);

     cd ..
catch
 cd ..    
end

%% prepare plotting ...matlab example
bdwidth = 5;
topbdwidth = 100;
set(0,'Units','pixels') 
scnsize = get(0,'ScreenSize');
pos1  = [bdwidth+topbdwidth,topbdwidth,...
    scnsize(3)*2/3 - 2*bdwidth,...
    scnsize(4)*2/3 - (topbdwidth + bdwidth)];

%%% add epicenter coordinates in case it is far from stations
alllat=[stalat;eventcor(2)] ;alllon=[stalon;eventcor(1)] ;

%tic

hh=figure('Position',pos1,'Name','map','Toolbar','figure','userdata',0, 'Renderer','painters');

% create structure of handles
handles1 = guihandles(hh); 
handles1.staname=staname;
handles1.stalat=stalat;
handles1.stalon=stalon;
handles1.eventcor=eventcor;
handles1.epidepth=epidepth;
handles1.magn=magn;
handles1.eventdate=eventdate;
handles1.selarea=selarea;

guidata(hh, handles1);

%%
% 
% ax = gca
% get(ax,'SortMethod')
% pause

%% stop using this 
% hplot4  = uicontrol('Style', 'checkbox', 'String', 'Disable OT vs Data start time check',...
%     'Position', [20 250 190 30], 'Value',1,'BackgroundColor',get(hh,'Color'),'Tag','checkDOT'); 
%%
%% SELECT ALL button calls selectall2.m
%
hplot3  = uicontrol('Style', 'pushbutton', 'String', 'Select all',...
    'Position', [20 150 100 70], 'Callback',{@selectall2,staname,new_OT});    
 
% EXIT....
hplot2  = uicontrol('Style', 'pushbutton', 'String', 'Exit',...
    'Position', [20  50 100 70], 'Callback', 'plstat2');                       

% hplot11  = uicontrol('Style', 'Text', 'String', 'Warning: Selecting simultanously very near and very far stations may be difficult in this tool. Please consider whether you actually need to combine the near and far stations.',...
%     'Position', [20 550 100 170], 'Callback', 'plstat');                          %%%%run the code to select stations....
% hplot1  = uicontrol('Style', 'pushbutton', 'String', 'Done Selecting',...
%     'Position', [20 250 100 70], 'Callback', 'plstat2');                          %%%%run the code to select stations....

%%
% decide about map limits based on percent of lat lon distance  .... 
minlat=min(alllat);maxlat=max(alllat);
minlon=min(alllon);maxlon=max(alllon);
latdis=maxlat-minlat;londis=maxlon-minlon;

brdlat=latdis*0.2;brdlon=londis*0.2;


%% Map using m_map
if plot_method==1  % m_map
    
   m_proj('Mercator','long',[min(alllon)-0.3 max(alllon)+0.4],'lat',[min(alllat)-0.3 max(alllat)+0.3]);
   m_proj('Mercator','long',[min(alllon)-brdlon max(alllon)+brdlon],'lat',[min(alllat)-brdlat max(alllat)+brdlat]);
  % m_gshhs_i('patch',[.7 .7 .7]); %m_gshhs_h('patch',[.7 .7 .7],'edgecolor','g');%'color','k');
   m_grid; %('box','fancy','tickdir','out');
   m_gshhs_i('Color','k','linewidth',2)
   m_ruler([0.1 0.4],0.08,2);

% hgshhs=findobj(hh,'Linewidth',0.5)
% uistack(hgshhs,'bottom')
% 
% set(hgshhs,'HitTest','off')

% for matlab plotting we need to find gshhs_l.b
% we will include the files in isola distribution 
% keep fixed in gshhs_i.b file

else % use matlab native code
% check the selected file
    x=get(handles.uipanel2, 'SelectedObject'); gshhs_file = [get(x, 'Tag') '.b'];
% find isola folder
    infold=which('isola.m');str = strrep(infold,'isola.m',''); % path to isola folder
    h=dir([str gshhs_file]);
    if isempty(h)
        h_1=warndlg([gshhs_file ' was not found in isola install folder.'],'!!! Error !!!');
        uiwait(h_1);
    return
    else
    % Map using Mapping Toolbox
         axesm('mercator','MapLatLimit',[min(alllat)-brdlat max(alllat)+brdlat],...
                          'MapLonLimit',[min(alllon)-brdlon max(alllon)+brdlon],...
                          'FFaceColor',[1 1 1],'FLineWidth',1)
         axis off; 
         framem on; gridm on; mlabel on; plabel on;
         setm(gca,'MLabelLocation',londis/3); setm(gca,'PLabelLocation',latdis/3)
         setm(gca,'LabelUnits','degrees');
         setm(gca,'MLabelRound',-2);setm(gca,'PLabelRound',-2);
         %setm(gca,'MLineLocation',1,'HitTest','off');    setm(gca,'pLineLocation',1)  
         l=gshhs([str gshhs_file],[min(alllat)-brdlat max(alllat)+brdlat],[min(alllon)-brdlon max(alllon)+brdlon]);
         geoshow([l.Lat], [l.Lon],'DisplayType','polygon','FaceColor', [0.7 0.7 0.7],'HitTest','off');
    end
    tightmap; showaxes
    % add scale
    scaleruler on; v=axis; sc_km=deg2km(londis);
    % if sc_km < 100
    %     m_scale=10*round(deg2km(londis/3)/10);
    % elseif sc_km > 100 && sc_km < 500
    %     m_scale=10*round(deg2km(londis/2)/10);
    % end
     if latdis < 1
        m_scale=10;
    elseif latdis > 1 && latdis < 5
        m_scale=50;
    elseif latdis > 5 && latdis < 10
        m_scale=100;
    else
        m_scale=200;
     end
    
        [xloc,yloc]=find_scale_coor(v);

    %getm(handlem('scaleruler1'),'Units')
    setm(handlem('scaleruler1'),... 
    'XLoc', xloc,'YLoc', yloc,...
    'MajorTick', 0:m_scale/2:m_scale,...
    'MinorTick', 0:1:0, ...
    'TickDir', 'up',...
    'RulerStyle','patches','MajorTickLength', m_scale/20);
end  % end of plot method select

%% plot epicenter
if plot_method==1  % m_map
    m_line(eventcor(1),eventcor(2),'marker','p','markersize',15,'color','b','MarkerFaceColor','b','HitTest','off');
% matlab needs LAT LON..!!! m_map needs LON LAT..!!
else
    plotm(eventcor(2),eventcor(1),'marker','p','markersize',15,'color','b','MarkerFaceColor','b','HitTest','off')
end

%% Plot stations
hdd=ones(length(stalat),1);

for i=1:length(stalat)
 
 if plot_method==1  % m_map
% m_map    
   hdd(i)=m_line(stalon(i),stalat(i),'marker','s',...
                                     'markersize',11,...
                                     'MarkerFaceColor','r',...
                                     'userdata'     ,i,...
                                     'ButtonDownFcn',{@selectsta,staname,new_OT});
                               
           m_text(stalon(i),stalat(i),staname(i),'vertical','top','HitTest','off');
           
%            h = findobj(map,'MarkerFaceColor','r')
%            uistack(h,'top')
           
 else
% mapping toolbox          
   hdd(i)=plotm(stalat(i),stalon(i),'marker','s',...
                                     'markersize',10,...
                                     'MarkerFaceColor','r',...
                                     'userdata'     ,i,...
                                     'ButtonDownFcn',{@selectsta,staname,new_OT});
                                 
          textm(stalat(i),stalon(i),staname(i),'vertical','top','HitTest','off');      
 end
 
end

%%% add menu for plotting
mh = uimenu(hh,'Label','Export Figure');
eh1 = uimenu(mh,'Label','Convert to PNG','Callback','exportgraphsta(1)');
eh2 = uimenu(mh,'Label','Convert to PS','Callback','exportgraphsta(2)');
eh3 = uimenu(mh,'Label','Convert to EPS','Callback','exportgraphsta(3)');
eh4 = uimenu(mh,'Label','Convert to TIFF','Callback','exportgraphsta(4)');
eh5 = uimenu(mh,'Label','Convert to EMF','Callback','exportgraphsta(5)');
eh6 = uimenu(mh,'Label','Convert to JPG','Callback','exportgraphsta(6)');
%eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4stationplot'); 


%%
% h = findobj('MarkerFaceColor','r')
%            uistack(h,'top')
% 
% sel_sta=findobj('Marker','square') 
% uistack(sel_sta,'top')

%toc

% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


delete(handles.stationselect)

% --- Executes during object creation, after setting all properties.
function selarea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function selarea_Callback(hObject, eventdata, handles)
% hObject    handle to selarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selarea as text
%        str2double(get(hObject,'String')) returns contents of selarea as a double


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

%if strcmp(get(handles.figure1,'SelectionType'),'open') % If double click
    index_selected = get(handles.listbox1,'Value');
    file_list = get(handles.listbox1,'String');
    filename = file_list{index_selected}; % Item selected in list box

if handles.is_dir(handles.sorted_index(index_selected)) % If directory
    cd (filename)
     load_listbox(pwd,handles) % Load list box with new directory
else
[path,name,ext,ver] = fileparts(filename);
disp(filename)

end



function load_listbox(dir_path,handles)

cd (dir_path) % Change to the specified directory
dir_struct = dir(dir_path); % List contents of directory

[sorted_names,sorted_index] = sortrows({dir_struct.name}'); % Sort names

handles.file_names = sorted_names; % Save the sorted names
handles.is_dir = [dir_struct.isdir]; % Save names of directories
handles.sorted_index = [sorted_index]; % Save sorted index values

guidata(handles.stationselect,handles) % Save the handles structure

set(handles.listbox1,'String',handles.file_names,'Value',1) % Load listbox
%set(handles.text1,'String',pwd) % Display current directory


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    [stationfile, newdir] = uigetfile('*.stn;*.dat;*.txt', 'Select seismic station file');
   
    if stationfile == 0
       disp('Cancel file load')
       return
   else
   end

   
   set(handles.selectedfile,'String',[newdir stationfile])


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
stnfilepath=handles.stnfilepath;

contents = cellstr(get(hObject,'String'));
selfile=contents{get(hObject,'Value')} ;

if ispc
    set(handles.selectedfile,'String',[stnfilepath '\' selfile])
else
    set(handles.selectedfile,'String',[stnfilepath '/' selfile])
end


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [Xpos,Ypos]= find_scale_coor(v)
 
    if v(1) <= 0 && v(2) >= 0
       Xdis=abs(v(1))+v(2);
       Xpos=v(1)+Xdis*.05;
    elseif v(1) < 0 && v(2) < 0
       Xdis=abs(v(1))-abs(v(2));
       Xpos=v(1)+Xdis*.05;
    elseif v(1) > 0 && v(2) > 0
       Xdis=v(2)-v(1);
       Xpos=v(1)+Xdis*.05;
    end
    
    if v(3) <= 0 && v(4) >= 0
       Ydis=abs(v(3))+v(4);
       Ypos=v(3)+Ydis*.05;
    elseif v(3) < 0 && v(4) < 0
       Ydis=abs(v(3))-abs(v(4));
       Ypos=v(3)+Ydis*.05;
    elseif v(3) > 0 && v(3) > 0
       Ydis=v(4)-v(3);
       Ypos=v(3)+Ydis*.05;
    end
        


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel2.
function uipanel2_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel2 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

get(eventdata.NewValue, 'Tag');
