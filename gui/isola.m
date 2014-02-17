function varargout = isola(varargin)
% ISOLA M-file for isola.fig
%      ISOLA, by itself, creates a new ISOLA or raises the existing
%      singleton*.
%
%      H = ISOLA returns the handle to a new ISOLA or the handle to
%      the existing singleton*.
%
%      ISOLA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ISOLA.M with the given input arguments.
%
%      ISOLA('Property','Value',...) creates a new ISOLA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before isola_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to isola_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help isola

% Last Modified by GUIDE v2.5 27-Aug-2013 13:26:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @isola_OpeningFcn, ...
                   'gui_OutputFcn',  @isola_OutputFcn, ...
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


% --- Executes just before isola is made visible.
function isola_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to isola (see VARARGIN)

% Choose default command line output for isola
handles.output = hObject;

disp('This is isola-GUI 05/09/2012')
disp('   ')
disp(['Starting in ' pwd])
disp('   ')
disp('Checking folder structure')
disp('   ')


%%% find isola folder
infold=which('isola.m');
str = strrep(infold,'isola.m','');

h=dir([str 'islimage.jpg']);

if isempty(h);
  
    disp('islimage.jpg was not found in isola install folder ... nevermind')
  
else
    
%%% load image and display
isolaimg=imread([str 'islimage.jpg']);
axes(handles.axes1)
image(isolaimg); axis off 
end


%%%%Check if folder structure exists

%check if INVERT exists..!
h=dir('invert');
if isempty(h);
    disp('Invert folder doesn''t exist. isola_GUI will create it.');
    [s,mess,messid] = mkdir('invert');
        if s ~=0 && s ~= 1 
            msgbox(mess,messid,'warn')
        end

%% go to isola main folder and look for header, footer...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sf=which('footer.txt');
if ~isempty(sf) 
[s,mess,messid]=copyfile(sf,'.\invert');
    disp('Copying footer.txt in isola\invert folder')
else
    disp('footer.txt doesn''t exist in isola folder')
end

sh=which('header.txt');
if ~isempty(sh)
[s,mess,messid]=copyfile(sh,'.\invert');
    disp('Copying header.txt in isola\invert folder')
else
   disp('header.txt doesn''t exist in isola folder')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
else
    disp('Invert folder exists. ');
end

%%
%check if Gmtfiles exists..!
h=dir('gmtfiles');
if isempty(h);
    disp('Gmtfiles folder doesn''t exist. isola_GUI will create it.');
    [s,mess,messid] = mkdir('gmtfiles');
        if s ~=0 && s ~= 1 
            msgbox(mess,messid,'warn')
        end
else
    disp('Gmtfiles folder exists. ');
end

%check if green exists..!
h=dir('green');
if isempty(h);
    disp('Green folder doesn''t exist. isola_GUI will create it.');
    [s,mess,messid] = mkdir('green');
        if s ~=0 && s ~= 1 
            msgbox(mess,messid,'warn')
        end
% 
% %%%find if there are crustal model files in isola folder...
% 
% isolamainf=which('isola.m');
% lbox2('dir',strrep(isolamainf,'isola.m',''))
% 
% 
else
    disp('Green folder exists. ');
end

%check if pzfiles exists..!
h=dir('pzfiles');
if isempty(h);
    disp('Pzfiles folder doesn''t exist. isola-GUI will create it.');
%     disp('Remember to copy the pz-files here.');
    
       [s,mess,messid] = mkdir('pzfiles');
        if s ~=0 && s ~= 1 
            msgbox(mess,messid,'warn')
        end

        %%%%check if pzfiles folder exists in isola install folder....
         %%find isola folder
         sf=which('isola.m');
         isolainst=sf(1:length(sf)-7)
         %%%now check if pzfiles exist in isola install folder
         aa=exist([isolainst 'pzfiles']);
           
        if aa==0
        
            button = questdlg('Automatic copy of pzfiles ?',...
            'Pole Zero file copy','Yes','No','Yes');

                if strcmp(button,'Yes')
                   directory_name = uigetdir('C:\matlab\isola','Select pzfile folder to copy files');
                   pfolder=[pwd '\pzfiles'];
                   
                   disp(['Copying pzfiles from ' directory_name  ' to ' pfolder  ])

                   command=['copy "' directory_name '\*.pz"  ' pfolder];
                   [status,message] = system(command);
              
                   if status ~=0 
                    error('Error ..!!!')
                   return
                   else
                   end
       
                   msgbox('Pole Zero files were copied','Copy of isola PZ files','Help') 

                elseif strcmp(button,'No')
                   disp('Canceled file operation')
                end
        elseif aa==7
       %%%   
             button = questdlg('Found pzfiles folder in isola folder. Automatic copy of these files ?',...
            'Pole Zero file copy','Yes','No','Yes');       
                
                   if strcmp(button,'Yes')
                   directory_name = [isolainst 'pzfiles'];
                   pfolder=[pwd '\pzfiles'];
                   
                   disp(['Copying pzfiles from ' directory_name  ' to ' pfolder  ])

                   command=['copy "' directory_name '\*.pz"  ' pfolder];
                   [status,message] = system(command);
              
                   if status ~=0 
                    error('Error ..!!!')
                   return
                   else
                   end
                 msgbox('Pole Zero files were copied','Copy of isola PZ files','Help') 

                elseif strcmp(button,'No')
                   disp('Canceled file operation')
                end

                   
       end        
        
else
    disp('Pzfiles folder exists.  ');
end



%check if polarity exists..!
h=dir('polarity');
if isempty(h);
    disp('Polarity folder doesn''t exist. isola_GUI will create it.');
    [s,mess,messid] = mkdir('polarity');
        if s ~=0 && s ~= 1 
            msgbox(mess,messid,'warn')
        end
else
    disp('Polarity folder exists.  ');
end

%check if data exists..!
h=dir('data');
if isempty(h);
    disp('Data folder doesn''t exist. isola_GUI will create it.');
    [s,mess,messid] = mkdir('data');
        if s ~=0 && s ~= 1 
            msgbox(mess,messid,'warn')
        end
else
    disp('Data folder exists.  ');
end

%check if output exists..!
h=dir('output');
if isempty(h);
    disp('Output folder doesn''t exist. isola_GUI will create it.');
    [s,mess,messid] = mkdir('output');
        if s ~=0 && s ~= 1 
            msgbox(mess,messid,'warn')
        end
else
    disp('Output folder exists. ');
end



%check if synth exists..!
h=dir('synth');
if isempty(h);
    disp('Synth folder doesn''t exist. isola_GUI will create it.');
    [s,mess,messid] = mkdir('synth');
        if s ~=0 && s ~= 1 
            msgbox(mess,messid,'warn')
        end
else
    disp('Synth folder exists. ');
end


%check if a station file is present in isola main folder called *.stn
h=dir('*.stn');
if isempty(h);
   isolamainf=which('isola.m');
   isolapath=strrep(isolamainf,'isola.m',''); 
   stn=dir(fullfile(isolapath,'*.stn')); 
 if ~isempty(stn)
    disp('found station file')
     for i=1:length(stn)
     [s,mess,messid]=copyfile(fullfile(isolapath,stn(i).name),'.');
     disp(['Copying '  stn(i).name  ])
     end
 else
     disp('Station file not found in isola folder')
 end
else
%there is a stn file in current folder 
disp('Found station file in current folder ')
end

%check if a crustal model file is present in isola main folder called *.cru
h=dir('*.cru');
if isempty(h)
     isolamainf=which('isola.m');
     isolapath=strrep(isolamainf,'isola.m','');
     stn=dir(fullfile(isolapath,'*.cru'));
  if ~isempty(stn)
     disp('found crustal file')
     for i=1:length(stn)
     [s,mess,messid]=copyfile(fullfile(isolapath,stn(i).name),'.');
     disp(['Copying '  stn(i).name  ])
     end
  else
     disp('crustal file not in isola folder')
  end
else
%there is a crustal file in current folder 
disp('Found crustal file in current folder ')
end
    

%%%%%%%%%%%%%%%%%%
disp('  ')
disp(['isola-GUI initialized ...'])

%%%%%

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes isola wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = isola_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in aboutguiisola.
function aboutguiisola_Callback(hObject, eventdata, handles)
% hObject    handle to aboutguiisola (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling about')
aboutgui


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('tchau')
close

% --- Executes on button press in cfolder.
function cfolder_Callback(hObject, eventdata, handles)
% hObject    handle to cfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling makepz')
makepz

% --- Executes on button press in backup.
function backup_Callback(hObject, eventdata, handles)
% hObject    handle to backup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a={'*.isl';'.\green\grdat.hed';'.\green\crustal.dat';'.\green\station.dat';...
   '.\invert\allstat.dat';'.\invert\inpinv.dat';'.\invert\inv1.dat';'.\invert\inv2.dat';...
   '.\invert\inv2s.dat';'.\invert\inv3.dat';'.\invert\inv4.dat'};

% 
directory_name = uigetdir('','Select folder for backup of isola RUN files'); 

for i=1:length(a)
     mess=['Copying ' a{i} ' to '  directory_name ];
     disp(mess)
     
     command=['copy ' a{i} ' ' directory_name];
     
     [status,message] = system(command);
 
       if status ~=0 
          error('Error ..!!!')
          return
      else
      end
      
end


msgbox('Files were copied','Backup of isola Run files','Help') 


% --- Executes on button press in imdata.
function imdata_Callback(hObject, eventdata, handles)
% hObject    handle to imdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling imdata')

imdata

% --- Executes on button press in callrotate.
function callrotate_Callback(hObject, eventdata, handles)
% hObject    handle to callrotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling rotate_gui')

rotate_gui

% --- Executes on button press in mshift.
function mshift_Callback(hObject, eventdata, handles)
% hObject    handle to mshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling shiftraw')
shiftraw


% --- Executes on button press in tfilter.
function tfilter_Callback(hObject, eventdata, handles)
% hObject    handle to tfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling datafilt')
datafilt

% --- Executes on button press in inspect.
function inspect_Callback(hObject, eventdata, handles)
% hObject    handle to inspect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling inspect')

inspctisl

% --- Executes on button press in forsim.
function forsim_Callback(hObject, eventdata, handles)
% hObject    handle to forsim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling create_synth')
create_synth


% --- Executes on button press in uncestim.
function uncestim_Callback(hObject, eventdata, handles)
% hObject    handle to uncestim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling comp_uncert')

comp_uncert

% --- Executes on button press in hcplot.
function hcplot_Callback(hObject, eventdata, handles)
% hObject    handle to hcplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is calling hcplot')

hcplot

% --- Executes on button press in greenpre.
function greenpre_Callback(hObject, eventdata, handles)
% hObject    handle to greenpre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling greenpre')
greenpre

% --- Executes on button press in inversion.
function inversion_Callback(hObject, eventdata, handles)
% hObject    handle to inversion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling invert')
invert

% --- Executes on button press in plresult.
function plresult_Callback(hObject, eventdata, handles)
% hObject    handle to plresult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Main is Calling plotres')
plotres

% --- Executes on button press in eventinfo.
function eventinfo_Callback(hObject, eventdata, handles)
% hObject    handle to eventinfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling eventinfo')
eventinfo


% --- Executes on button press in staselect.
function staselect_Callback(hObject, eventdata, handles)
% hObject    handle to staselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling stationselect')
stationselect

% --- Executes on button press in selectdata.
function selectdata_Callback(hObject, eventdata, handles)
% hObject    handle to selectdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling datain4')
datain4


% --- Executes on button press in sourcedef.
function sourcedef_Callback(hObject, eventdata, handles)
% hObject    handle to sourcedef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling sourcesel')
sourcesel

% --- Executes on button press in crustalmodel.
function crustalmodel_Callback(hObject, eventdata, handles)
% hObject    handle to crustalmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling crustmodnew')
crustmodnew


% --- Executes on button press in mulmodel.
function mulmodel_Callback(hObject, eventdata, handles)
% hObject    handle to mulmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Main is Calling moremodels')

moremodels


function mutual_exclude(off)
set(off,'Value',0)

function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')


% --- Executes on button press in snrcalc.
function snrcalc_Callback(hObject, eventdata, handles)
% hObject    handle to snrcalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Main is Calling checknoisespectrum')
checknoisespectrum


% --- Executes on button press in timefunc.
function timefunc_Callback(hObject, eventdata, handles)
% hObject    handle to timefunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is Calling timefun')
timefun


% --- Executes on button press in jack.
function jack_Callback(hObject, eventdata, handles)
% hObject    handle to jack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('Main is calling jack')
jack
