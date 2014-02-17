function varargout = moremodels(varargin)
% MOREMODELS M-file for moremodels.fig
%      MOREMODELS, by itself, creates a new MOREMODELS or raises the existing
%      singleton*.
%
%      H = MOREMODELS returns the handle to a new MOREMODELS or the handle to
%      the existing singleton*.
%
%      MOREMODELS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOREMODELS.M with the given input arguments.
%
%      MOREMODELS('Property','Value',...) creates a new MOREMODELS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before moremodels_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to moremodels_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help moremodels

% Last Modified by GUIDE v2.5 26-Jun-2009 00:18:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @moremodels_OpeningFcn, ...
                   'gui_OutputFcn',  @moremodels_OutputFcn, ...
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


% --- Executes just before moremodels is made visible.
function moremodels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to moremodels (see VARARGIN)

% Choose default command line output for moremodels
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes moremodels wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = moremodels_OutputFcn(hObject, eventdata, handles)
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
delete(handles.moremodels)

% --- Executes on button press in newmodel.
function newmodel_Callback(hObject, eventdata, handles)
% hObject    handle to newmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

crustmod2


% --- Executes on button press in stationmodel.
function stationmodel_Callback(hObject, eventdata, handles)
% hObject    handle to stationmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
  cd green
  %check if allstat2 exists..!
  h=dir('allstat2.dat');

   if length(h) == 0;
     errordlg('Allstat2.dat file doesn''t exist in green folder. Run station select first.','File Error');
     cd ..
     pwd
     return
   else
     dos('notepad allstat2.dat &')
      cd ..
      pwd
   end
   
catch
    msgstr = lasterr
    cd ..
    pwd
end

pwd

% --- Executes on button press in confirm.
function confirm_Callback(hObject, eventdata, handles)
% hObject    handle to confirm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%% Check if allstat2.dat is acceptable.....
try
  cd green
  %check if allstat2 exists..!
  h=dir('allstat2.dat');

   if length(h) == 0;
     errordlg('Allstat2.dat file doesn''t exist in green folder. Run station select first.','File Error');
     cd ..
     pwd
     return
   else
            %%% read allstat2.dat
            %read data in 7 arrays
           [staname,d1,d2,d3,d4,d5] = textread('allstat2.dat','%s %f %f %f %f %u',-1);
           %% find max crustal model number and check if crustal files exist
           
         switch  max(d5)
           
             case 4
                            switch exist('crustal_01.dat')
                              case 2
                                  disp('Found crustal_01.dat')
                              otherwise
                                  disp('Error ... crustal_01.dat was not found in green folder')
                                  errordlg('Error ... crustal_01.dat was not found in green folder','File Error');
                            end
                            switch exist('crustal_02.dat')
                              case 2
                                  disp('Found crustal_02.dat')
                              otherwise
                                  disp('Error ... crustal_02.dat was not found in green folder')
                                  errordlg('Error ... crustal_02.dat was not found in green folder','File Error');
                            end
                            switch exist('crustal_03.dat')
                              case 2
                                  disp('Found crustal_03.dat')
                              otherwise
                                  disp('Error ... crustal_03.dat was not found in green folder')
                                  errordlg('Error ... crustal_03.dat was not found in green folder','File Error');
                              end
                            switch exist('crustal_04.dat')
                              case 2
                                  disp('Found crustal_04.dat')
                              otherwise
                                  disp('Error ... crustal_04.dat was not found in green folder')
                                  errordlg('Error ... crustal_04.dat was not found in green folder','File Error');
                            end
             case 3
                            switch exist('crustal_01.dat')
                              case 2
                                  disp('Found crustal_01.dat')
                              otherwise
                                  disp('Error ... crustal_01.dat was not found in green folder')
                                  errordlg('Error ... crustal_01.dat was not found in green folder','File Error');
                            end
                            switch exist('crustal_02.dat')
                              case 2
                                  disp('Found crustal_02.dat')
                              otherwise
                                  disp('Error ... crustal_02.dat was not found in green folder')
                                  errordlg('Error ... crustal_02.dat was not found in green folder','File Error');
                            end
                            switch exist('crustal_03.dat')
                              case 2
                                  disp('Found crustal_03.dat')
                              otherwise
                                  disp('Error ... crustal_03.dat was not found in green folder')
                                  errordlg('Error ... crustal_03.dat was not found in green folder','File Error');
                              end

             case 2
                            switch exist('crustal_01.dat')
                              case 2
                                  disp('Found crustal_01.dat')
                              otherwise
                                  disp('Error ... crustal_01.dat was not found in green folder')
                                  errordlg('Error ... crustal_01.dat was not found in green folder','File Error');
                            end
                            switch exist('crustal_02.dat')
                              case 2
                                  disp('Found crustal_02.dat')
                              otherwise
                                  disp('Error ... crustal_02.dat was not found in green folder')
                                  errordlg('Error ... crustal_02.dat was not found in green folder','File Error');
                            end
                 
             case 1
                            switch exist('crustal_01.dat')
                              case 2
                                  disp('Found crustal_01.dat')
                              otherwise
                                  disp('Error ... crustal_01.dat was not found in green folder')
                                  errordlg('Error ... crustal_01.dat was not found in green folder','File Error');
                            end
             otherwise
                 
               errordlg(['Error. Found crustal model with number ' num2str(max(d5)) ' in allstat2.dat. Only numbers from 1 to 4 are supported'],'File Error');  
                 
                 
         end          
           
%%%%%%%%%%%%%%%%%%           
     cd ..
     pwd
      
      
      
   end
   
catch
    msgstr = lasterr
    cd ..
    pwd
end

pwd





%%% prepare a file for green 
        fid = fopen('green.isl','w');
          if ispc
              fprintf(fid,'%s\r\n','multiple');
          else
              fprintf(fid,'%s\n','multiple');
          end
        fclose(fid);
        
        delete(handles.moremodels)
        
        
        
        