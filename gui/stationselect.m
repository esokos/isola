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

% Last Modified by GUIDE v2.5 17-Jun-2011 22:54:47

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
    fclose(fid);
end

% check which stn files exist in ISOLA installation folder..
s=which('isola.m');
stnfilepath=strrep(s,'isola.m','');    
stn_files=dir([stnfilepath '*.stn']);
stn_file1=char(stn_files.name); 
set(handles.listbox2,'String',stn_file1);

%%% Check if station file exists in current folder ...
h=dir('*.stn');

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
end

%%%%% write in handles
handles.eventcor=eventcor;
handles.epidepth=epidepth;
handles.magn=magn;
handles.eventdate=eventdate;
handles.stnfilepath=stnfilepath;
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

disp('This is stationselect 29/10/2011');

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

%% read event data from handles
eventcor=handles.eventcor;
epidepth=handles.epidepth;
magn=handles.magn;
eventdate=handles.eventdate;

%% read plotting parameter
selarea=str2double(get(handles.selarea,'String'));

%%%% Read station file ...
fullstationfile=get(handles.selectedfile,'String');

%print file name
disp(['Using ' fullstationfile ' station file'])

%read data in 3 arrays
fid  = fopen(fullstationfile,'r');
 C= textscan(fid,'%s %f %f',-1);
fclose(fid);
staname=C{1};
stalat=C{2};
stalon=C{3};

%% save  this file to \gmtfiles folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if exists..!
h=dir('gmtfiles');

if isempty(h);
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

%%%% check for stations with 4 character code....
% for i=1:length(staname);
%     st=staname{i,1};
% if length(st) > 3
%     errorstr=['Station ' st ' has 4 character name. Station names should be limited to 3 characters. The new station name will be ' st(1:3) '.It would be better to use 3 character station codes' ];
%      errordlg(errorstr,'Station naming Error');
%      staname{i,1}=st(1:3);
%  else
%  end
% end

%%%prepare plotting ...matlab example
bdwidth = 5;
topbdwidth = 100;
set(0,'Units','pixels') 
scnsize = get(0,'ScreenSize');
pos1  = [bdwidth+topbdwidth,topbdwidth,...
    scnsize(3)*2/3 - 2*bdwidth,...
    scnsize(4)*2/3 - (topbdwidth + bdwidth)];

%%% add epicenter coordinates in case it is far from stations
alllat=[stalat;eventcor(2)];
alllon=[stalon;eventcor(1)];

hh=figure('Position',pos1,'Name','map','Toolbar','figure');

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

hplot1  = uicontrol('Style', 'pushbutton', 'String', 'Select Stations',...
    'Position', [20 250 100 70], 'Callback', 'plstat');                          %%%%run the code to select stations....

hplot2  = uicontrol('Style', 'pushbutton', 'String', 'Exit',...
    'Position', [20 150 100 70], 'Callback', 'close map');                       %%%%exit....

% decide about map limits based on percent of lat lon distance  .... 
minlat=min(alllat);maxlat=max(alllat);
minlon=min(alllon);maxlon=max(alllon);

latdis=maxlat-minlat;londis=maxlon-minlon;

brdlat=latdis*0.2;brdlon=londis*0.2;

%m_proj('Mercator','long',[min(alllon)-0.3 max(alllon)+0.4],'lat',[min(alllat)-0.3 max(alllat)+0.3]);

m_proj('Mercator','long',[min(alllon)-brdlon max(alllon)+brdlon],'lat',[min(alllat)-brdlat max(alllat)+brdlat]);

m_gshhs_i('patch',[.7 .7 .7]);
%m_gshhs_h('patch',[.7 .7 .7],'edgecolor','g');%'color','k');
m_grid('box','fancy','tickdir','out');
m_ruler([0.1 0.4],0.08,2);
%% plot stations
for i=1:length(stalat)
m_line(stalon(i),stalat(i),'marker','square','markersize',5,'color','r');
m_text(stalon(i),stalat(i),staname(i),'vertical','top');
end

%%%plot epicenter
m_line(eventcor(1),eventcor(2),'marker','p','markersize',17,'color','b','MarkerFaceColor','b');


%%% add menu for plotting
mh = uimenu(hh,'Label','Export Figure');
eh1 = uimenu(mh,'Label','Convert to PNG','Callback','exportgraphsta(1)');
eh2 = uimenu(mh,'Label','Convert to PS','Callback','exportgraphsta(2)');
eh3 = uimenu(mh,'Label','Convert to EPS','Callback','exportgraphsta(3)');
eh4 = uimenu(mh,'Label','Convert to TIFF','Callback','exportgraphsta(4)');
eh5 = uimenu(mh,'Label','Convert to EMF','Callback','exportgraphsta(5)');
eh6 = uimenu(mh,'Label','Convert to JPG','Callback','exportgraphsta(6)');
%eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4stationplot'); 


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

set(handles.selectedfile,'String',[stnfilepath selfile])



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
