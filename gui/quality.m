function varargout = quality(varargin)
% QUALITY M-file for quality.fig
%      QUALITY, by itself, creates a new QUALITY or raises the existing
%      singleton*.
%
%      H = QUALITY returns the handle to a new QUALITY or the handle to
%      the existing singleton*.
%
%      QUALITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUALITY.M with the given input arguments.
%
%      QUALITY('Property','Value',...) creates a new QUALITY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before quality_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to quality_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help quality

% Last Modified by GUIDE v2.5 08-Sep-2015 23:24:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @quality_OpeningFcn, ...
                   'gui_OutputFcn',  @quality_OutputFcn, ...
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


% --- Executes just before quality is made visible.
function quality_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to quality (see VARARGIN)

% Choose default command line output for quality
handles.output = hObject;


%% find number of used stations
if ispc
 h=dir('.\invert\allstat.dat');
else
 h=dir('./invert/allstat.dat');
end

  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
  else
                 disp('Found current version of allstat e.g. STA 1 1 1 1 f1 f2 f3 f4')
                if ispc   
                   [~,us1,~,~,~,~,~,~,~] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 
                else
                   [~,us1,~,~,~,~,~,~,~] = textread('./invert/allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 
                end
  end % if for allstat existance
  
   nused=length(us1(us1~=0));

   set(handles.nsta,'String',num2str(nused))
   
   if nused==1
        set(handles.qtitle,'String','Poor')
   else
   end
   

%% find variance reduction
%
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
     elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
     elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
        noSourcesstrike=fscanf(fid,'%i',1);
        strikestep=fscanf(fid,'%f',1);
        noSourcesdip=fscanf(fid,'%i',1);
        dipstep=fscanf(fid,'%f',1);
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

cd invert
  [~,inv1_eigen,~,~,~,~,~,~,~,inv1_varred]=readinv1(nsources,1);
cd ..

set(handles.varred,'String',num2str(inv1_varred))

set(handles.cn,'String',num2str(inv1_eigen(3)))




% Update handles structure
guidata(hObject, handles);

% UIWAIT makes quality wait for user response (see UIRESUME)
% uiwait(handles.quality);


% --- Outputs from this function are returned to the command line.
function varargout = quality_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.quality)
