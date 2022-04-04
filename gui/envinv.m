function varargout = envinv(varargin)
% ENVINV MATLAB code for envinv.fig
%      ENVINV, by itself, creates a new ENVINV or raises the existing
%      singleton*.
%
%      H = ENVINV returns the handle to a new ENVINV or the handle to
%      the existing singleton*.
%
%      ENVINV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ENVINV.M with the given input arguments.
%
%      ENVINV('Property','Value',...) creates a new ENVINV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before envinv_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to envinv_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help envinv

% Last Modified by GUIDE v2.5 13-May-2017 00:18:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @envinv_OpeningFcn, ...
                   'gui_OutputFcn',  @envinv_OutputFcn, ...
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


% --- Executes just before envinv is made visible.
function envinv_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to envinv (see VARARGIN)

% Choose default command line output for envinv
handles.output = hObject;

disp('This is envinv.m, Ver. 0.3, Dec 2020')
disp('Starting.')
disp('  ')

%% check if all ISOLA input files exist..
h=dir('duration.isl');

if isempty(h); 
  errordlg('Duration.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('duration.isl','r');
    tl=fscanf(fid,'%g',1);
    fclose(fid);
end

%%
dtres=tl/8192;
%set(handles.timestep,'String',dtres)     

%%
h=dir('tsources.isl');
source_gmtfile=0;

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
%      distep=fscanf(fid,'%f',1);
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
 
set(handles.nsourcepos,'String',nsources);     


%%
f = waitbar(0,'Starting...','Name','Checking folder please wait');

%% check if folder exists and if yes then make backup
if exist('env_amp_inv','dir')
   disp('Found previous env_amp_inv folder will make backup and start in a clean folder')
   waitbar(.3,f,'Found previous env\_amp\_inv folder will make backup in zip file.');
   pause(1)
   % create a filename for zip file
   zipfilename=[datestr(now,'dd_mm_yyyy_hh_MM_ss')  '_env_amp_inv.zip']; 
   zip(zipfilename,'env_amp_inv');
   waitbar(.6,f,'Zipped file created...');
   pause(1)

   disp(['Found previous env_amp_inv folder. Folder was compressed in ' zipfilename ' file. Folder will be deleted for a clean start.']);

   [status, message, messageid] = rmdir('env_amp_inv', 's')
   
   waitbar(1,f,'Finished. Starting code in clean folder.');
   pause(1)
   close(f)
   
else
   disp('env_amp_inv folder wasn''t found.')
end

%% check if folder exists ... no need anymore !!
h=dir('env_amp_inv');

if isempty(h);
%% warndlg('env_amp_inv folder doesn''t exist. Isola will create it. ','Missing folder');
    mkdir('env_amp_inv')
%  copy needed files now
               if ispc 
                              [s,mess,messid]=copyfile('.\invert\allstat.dat','.\env_amp_inv');
                              [s,mess,messid]=copyfile('.\invert\elemse*.dat','.\env_amp_inv');
                              [s,mess,messid]=copyfile('.\green\crustal.dat','.\env_amp_inv');
                              [s,mess,messid]=copyfile('.\green\station.dat','.\env_amp_inv');
                               
               else
                              [s,mess,messid]=copyfile('./invert/allstat.dat','./env_amp_inv');
                              [s,mess,messid]=copyfile('./invert/elemse*.dat','./env_amp_inv');
                              [s,mess,messid]=copyfile('./green/crustal.dat','./env_amp_inv');
                              [s,mess,messid]=copyfile('./green/station.dat','./env_amp_inv');
               end
               
               if ispc   
                   [NS,~,~,~,~,~,~,~,~] = textread('.\env_amp_inv\allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 
               else
                   [NS,~,~,~,~,~,~,~,~] = textread('./env_amp_inv/allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 
               end
               nostations = length(NS);
               
               % now copy from invert to env_amp_inv
                for i=1:nostations
                  realdatafilename{i}=[char(NS(i)) 'raw.dat'];
                  [s,mess,messid]=copyfile(['.\invert\' realdatafilename{i} ],'.\env_amp_inv');
                end

    if ispc
         h=dir('.\env_amp_inv\source.dat');
    else
         h=dir('./env_amp_inv/source.dat');
    end

    if isempty(h); 
         disp('source.dat file doesn''t exist in env_amp_inv folder .... copying it ')
        [s,mess,messid]=copyfile('.\polarity\source.dat','.\env_amp_inv');    
    else
    end

   % now read it and update the depth box
    if ispc
       [~,~,depth,mag,tt] = textread('.\env_amp_inv\source.dat','%f %f %f %f %s','headerlines',2);
    else
       [~,~,depth,mag,tt] = textread('./env_amp_inv/source.dat','%f %f %f %f %s','headerlines',2);
    end
   
%%    
else  % folder exists do nothing just update depth 
    
    if ispc
      [~,~,depth,mag,tt] = textread('.\env_amp_inv\source.dat','%f %f %f %f %s','headerlines',2);
    else
      [~,~,depth,mag,tt] = textread('./env_amp_inv/source.dat','%f %f %f %f %s','headerlines',2);
    end
    
       warndlg('Found env_inv folder. Will NOT copy files from invert folder. Make sure that this is OK.IF you made changes to Green functions, Stations etc, files SHOULD be copied in env_inv folder. To FORCE this delete the env_inv folder and restart.!!','!! Warning !!')    

end % check for env_amp_inv 


% update the depth box
set(handles.depth,'String',num2str(depth))


%%
% h=dir('envinv.isl');
% 
% if isempty(h); 
%      disp('envinv.isl not found')
% else
%     fid = fopen('envinv.isl','r');
%      f1=fscanf(fid,'%s',1);
%      f4=fscanf(fid,'%s',1);
%     fclose(fid);
%     
% set(handles.f1,'String',f1)
% set(handles.f4,'String',f4)
%     
% end

%% Update freq range edit box with allstat values
                   
        if ispc
          [NS,d1,d2,d3,d4,freq11,~,~,freq44] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
        else
          [NS,d1,d2,d3,d4,freq11,~,~,freq44] = textread('./invert/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
        end

 
set(handles.f1,'String',freq11(1))
set(handles.f4,'String',freq44(1))

%%
handles.selmag=mag;
handles.seltt=tt;
handles.dtres=dtres;
handles.nsources=nsources;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes envinv wait for user response (see UIRESUME)
% uiwait(handles.envinv);


% --- Outputs from this function are returned to the command line.
function varargout = envinv_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%   create the inv.dat file first

% spectra or envelopes..?
h2=get(handles.uibuttongroup2,'SelectedObject');

if strcmp(get(h2,'Tag'),'radiobutton3')
   disp('Inversion of envelopes')
   itype=0;
else
    disp('Inversion of spectra')
   itype=1;
end

% read  values
dtres=handles.dtres;
nsources=handles.nsources;

h=get(handles.uibuttongroup1,'SelectedObject');

if strcmp(get(h,'Tag'),'radiobutton1')
   disp('Full Grid search')
   gvalue=0;
else
   disp('Polarity pre-constrained')
   gvalue=1;
end

% 
strike_start=str2num(get(handles.strike_start,'String'));
strike_end  =str2num(get(handles.strike_end  ,'String'));
strike_step =str2num(get(handles.strike_step ,'String'));

dip_start=str2num(get(handles.dip_start,'String'));
dip_end  =str2num(get(handles.dip_end  ,'String'));
dip_step =str2num(get(handles.dip_step ,'String'));

rake_start=str2num(get(handles.rake_start,'String'));
rake_end  =str2num(get(handles.rake_end  ,'String'));
rake_step =str2num(get(handles.rake_step ,'String'));

%% write file 

if ispc
  fid = fopen('.\env_amp_inv\inp.dat','w');
    fprintf(fid,'%s\r\n','Type of inversion: =0 for envelopes, =1 for ampl.sp.');
    fprintf(fid,'%i\r\n',itype);
    fprintf(fid,'%s\r\n','Time step dt (in seconds)');
    fprintf(fid,'%g\r\n',dtres);
    fprintf(fid,'%s\r\n','Number of trial source positions');
    fprintf(fid,'%i\r\n',nsources);
    fprintf(fid,'%s\r\n','Type of grid search: =0 define limits, =1 from file sdr.dat (no need to define limits)');
    fprintf(fid,'%i\r\n',gvalue);
    fprintf(fid,'%s\r\n','Limits of strike,dip,rake (from, to, step); Note that rake -90 to 90 is sufficient !!');
    fprintf(fid,'%i %i %i\r\n',strike_start,strike_end,strike_step);
    fprintf(fid,'%i %i %i\r\n',dip_start,dip_end,dip_step);
    fprintf(fid,'%i %i %i\r\n',rake_start,rake_end,rake_step);
  fclose(fid);
else
  fid = fopen('./env_amp_inv/inp.dat','w');
    fprintf(fid,'%s\n','Type of inversion: =0 for envelopes, =1 for ampl.sp.');
    fprintf(fid,'%i\n',0);
    fprintf(fid,'%s\n','Time step dt (in seconds)');
    fprintf(fid,'%g\n',dtres);
    fprintf(fid,'%s\n','Number of trial source positions');
    fprintf(fid,'%i\n',nsources);
    fprintf(fid,'%s\n','Type of grid search: =0 define limits, =1 from file sdr.dat (no need to define limits)');
    fprintf(fid,'%i\n',gvalue);
    fprintf(fid,'%s\n','Limits of strike,dip,rake (from, to, step); Note that rake -90 to 90 is sufficient !!');
    fprintf(fid,'%i %i %i\n',strike_start,strike_end,strike_step);
    fprintf(fid,'%i %i %i\n',dip_start,dip_end,dip_step);
    fprintf(fid,'%i %i %i\n',rake_start,rake_end,rake_step);
  fclose(fid);
end


%% Create the batch file
if ispc
  fid = fopen('.\env_amp_inv\run_withpol.bat','w');
    fprintf(fid,'%s\r\n','echo off');
    fprintf(fid,'%s\r\n','del inv1.dat');   
    fprintf(fid,'%s\r\n','del inv2.dat');   
    fprintf(fid,'%s\r\n','del out6_opt.dat');     
    fprintf(fid,'%s\r\n','echo on');    
    fprintf(fid,'%s\r\n',' ');    
    fprintf(fid,'%s\r\n','  newaspo.exe '); 
%     fprintf(fid,'%s\r\n','    selsol.exe ');     
%     fprintf(fid,'%s\r\n',' pause ');    
%     fprintf(fid,'%s\r\n','copy ..\polarity\mypol.dat  mypol.dat');
%     fprintf(fid,'%s\r\n','sipolnew3.exe');   
  fclose(fid);
else
  fid = fopen('./env_amp_inv/run_withpol.bat','w');
%    fprintf(fid,'%s\n','echo off');
    fprintf(fid,'%s\n','rm inv1.dat');   
    fprintf(fid,'%s\n','rm inv2.dat');   
    fprintf(fid,'%s\n','rm out6_opt.dat');     
%    fprintf(fid,'%s\n','echo on');    
    fprintf(fid,'%s\n',' ');    
    fprintf(fid,'%s\n','  newaspo.exe '); 
%     fprintf(fid,'%s\r\n','    selsol.exe ');     
%     fprintf(fid,'%s\r\n',' pause ');    
%     fprintf(fid,'%s\r\n','copy ..\polarity\mypol.dat  mypol.dat');
%     fprintf(fid,'%s\r\n','sipolnew3.exe');   
  fclose(fid);      
  
end

%%
   button = questdlg('Run Inversion ?','Inversion ','Yes','No','Yes');
        if strcmp(button,'Yes')
           disp('Running inversion')
            cd env_amp_inv
              if ispc 
                  %   run
                     system('run_withpol.bat &') % return to ISOLA run folder    
                  
              else
                 disp('Linux ')
                               
%                                 !chmod +x runisola.sh                 
%                                 system('gnome-terminal -e "bash -c runisola.sh;bash"')            % return to ISOLA folder    
              end
            cd ..
            pwd
        elseif strcmp(button,'No')
          disp('Canceled ')
        end




function strike_start_Callback(hObject, eventdata, handles)
% hObject    handle to strike_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike_start as text
%        str2double(get(hObject,'String')) returns contents of strike_start as a double


% --- Executes during object creation, after setting all properties.
function strike_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strike_end_Callback(hObject, eventdata, handles)
% hObject    handle to strike_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike_end as text
%        str2double(get(hObject,'String')) returns contents of strike_end as a double


% --- Executes during object creation, after setting all properties.
function strike_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strike_step_Callback(hObject, eventdata, handles)
% hObject    handle to strike_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike_step as text
%        str2double(get(hObject,'String')) returns contents of strike_step as a double


% --- Executes during object creation, after setting all properties.
function strike_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip_start_Callback(hObject, eventdata, handles)
% hObject    handle to dip_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip_start as text
%        str2double(get(hObject,'String')) returns contents of dip_start as a double


% --- Executes during object creation, after setting all properties.
function dip_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip_end_Callback(hObject, eventdata, handles)
% hObject    handle to dip_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip_end as text
%        str2double(get(hObject,'String')) returns contents of dip_end as a double


% --- Executes during object creation, after setting all properties.
function dip_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip_step_Callback(hObject, eventdata, handles)
% hObject    handle to dip_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip_step as text
%        str2double(get(hObject,'String')) returns contents of dip_step as a double


% --- Executes during object creation, after setting all properties.
function dip_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rake_start_Callback(hObject, eventdata, handles)
% hObject    handle to rake_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake_start as text
%        str2double(get(hObject,'String')) returns contents of rake_start as a double


% --- Executes during object creation, after setting all properties.
function rake_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rake_end_Callback(hObject, eventdata, handles)
% hObject    handle to rake_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake_end as text
%        str2double(get(hObject,'String')) returns contents of rake_end as a double


% --- Executes during object creation, after setting all properties.
function rake_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rake_step_Callback(hObject, eventdata, handles)
% hObject    handle to rake_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake_step as text
%        str2double(get(hObject,'String')) returns contents of rake_step as a double


% --- Executes during object creation, after setting all properties.
function rake_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get( hObject, 'String' );

if strcmp( str, 'Full Grid Search' )
	%disp( 'Button 1' )
    set(handles.uipanel1,'Visible','On')
else
	%disp( 'Button 2' )
    set(handles.uipanel1,'Visible','Off')
    
    %% check that sdr.dat file exists
    if exist('.\env_amp_inv\sdr.dat','file')
        disp('Found sdr.dat in env_inv_amp folder')
    else
        errordlg('sdr.dat file is missing from folder env_amp_inv. Please prepare as a simple text file with 3 columns i.e. strike, dip, rake based on your polarity derived solutions.')
    end
 
end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% before exit save an isl file with freq range

   f1=get(handles.f1,'String');
   f4=get(handles.f4,'String');

        fid = fopen('envinv.isl','w');
          if ispc
               fprintf(fid,'%s\r\n',f1);
               fprintf(fid,'%s\r\n',f4);
          else
               fprintf(fid,'%s\n',f1);
               fprintf(fid,'%s\n',f4);
          end
        fclose(fid);

delete(handles.envinv)


% --- Executes on button press in checksol.
function checksol_Callback(hObject, eventdata, handles)
% hObject    handle to checksol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in polaritycheck.
function polaritycheck_Callback(hObject, eventdata, handles)
% hObject    handle to polaritycheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% copy files from polarity here..!!
% 
% 
% [s,mess,messid]=copyfile('.\polarity\station.dat','.\env_amp_inv');
% [s,mess,messid]=copyfile('.\polarity\crustal.dat','.\env_amp_inv');
% [s,mess,messid]=copyfile('.\polarity\source.dat','.\env_amp_inv');
% 
% %% draw figure
%  figpos=get(envinv,'position');
%  
%  l=figpos(1); b=figpos(2); w=figpos(3); h=figpos(4);
%  
%  FigHandle = figure('Position', [l+w+2, b, 200, h],...
%                     'Toolbar','none','Menubar','none','Name','Polarity Plot Figure','Units','Pixels');
% 
% % create a text box
%    btn1 = uicontrol('Style', 'Edit', 'String', '10',...
%         'Position', [70,525,60,30],'FontSize',11,...
%         'Callback', '','Units','Pixels');    
%                 
% % create a button
%    btn1 = uicontrol('Style', 'pushbutton', 'String', 'Input Polarities',...
%         'Position', [25,450,150,50],'FontSize',11,...
%         'Callback', @btn1_callback ,'Units','Pixels');                     
%                 
%    btn2 = uicontrol('Style', 'pushbutton', 'String', 'Plot Polarities',...
%         'Position', [25,350,150,50],'FontSize',11,...
%         'Callback', @btn2_callback,'Units','Pixels');  
    
    
% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%  figpos=get(envinv,'position');
%  
%  l=figpos(1); b=figpos(2); w=figpos(3); h=figpos(4);
%  
%  plotFigHandle = figure('Position', [l+w+2, b, 200, h],...
%                     'Toolbar','none','Menubar','none','Name','Polarity Plot Figure','Units','Pixels');
% % create a button
%    plotbtn1 = uicontrol('Style', 'pushbutton', 'String', 'Plot Real-Synthetics',...
%         'Position', [25,450,150,50],'FontSize',11,...
%         'Callback', @envplot ,'Units','Pixels');                     

%% before calling plot check if check polarities is checked...
% if (get(handles.checkpolopt,'Value') == get(handles.checkpolopt,'Max'))
% %  call the plotting GUI
%     envplot
% 
% else
%    % we must remove out5.dat
%    if ispc
%      delete('.\env_amp_inv\out5.dat')
%    else
%      delete('./env_amp_inv/out5.dat')
%    end
    
    envplot
% end




function btn1_callback(hObject, eventdata, handles)
   cd .\env_amp_inv
     system('notepad station.dat &')
   cd ..

   
   
function btn2_callback(hObject, eventdata, handles)
     
%% find how many stations we have check the station.dat

    fid = fopen('station.dat','r');
          C=textscan(fid,'%f %f %f %f %f %s %s ','HeaderLines', 2);
    fclose(fid);
    
    nostations=length(C{1})

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
    fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -a0.3c/cc -ewhite -t0.1p -gblack   -W1p -Glightgray > pol_plot.ps'  );
    fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt  -R0/10/0/10 -JX17c -Sa15c -K -O  -T0 -W1p >> pol_plot.ps'  );
    if length(isom) > 1
      fprintf(fid,'%s\r\n', 'psmeca more_mech.gmt -R -J -Sa15c -T0 -K -O -a0.3c/cc -ewhite -t0.1p -gblack   -W1.p >> pol_plot.ps '  );
    else
    end
    fprintf(fid,'%s\r\n', 'gawk "{if (NR>1) print $1,$2,$3,$4}" mypol.dat > 4pspolar.txt');
    fprintf(fid,'%s\r\n', 'pspolar 4pspolar.txt -R -J -N -Ss0.7c  -D5/5  -M15c  -e0.5p  -O -K -T0/0/5/18  >>  pol_plot.ps ');
   % fprintf(fid,'%s\r\n', 'pstext ref_mech_text.gmt -R -J -O -K -m -N  >> csps_gmt_plot.ps '  );
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
  fclose(fid);
	
	disp('Check the  .\polarity\plot_pol_gmt.bat file for GMT plotting')
 	
else
    
  fid = fopen('./polarity/plot_pol_gmt.bat','w');
    fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt   -R0/10/0/10 -JX17c -Sa15c -K -a0.3c/cc -ewhite -t0.1p -gblack   -W1p -Glightgray > pol_plot.ps'  );
    fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt  -R0/10/0/10 -JX17c -Sa15c -K -O  -T0 -W1p >> pol_plot.ps'  );
    if length(isom) > 1
      fprintf(fid,'%s\r\n', 'psmeca more_mech.gmt -R -J -Sa15c -T0 -K -O -a0.3c/cc -ewhite -t0.1p -gblack   -W1.p >> pol_plot.ps '  );
    else
    end
    fprintf(fid,'%s\r\n', 'gawk "{if (NR>1) print $1,$2,$3,$4}" mypol.dat > 4pspolar.txt');
    fprintf(fid,'%s\r\n', 'pspolar 4pspolar.txt -R -J -N -Ss0.7c  -D5/5  -M15c  -e0.5p  -O -K -T0/0/5/18  >>  pol_plot.ps ');
   % fprintf(fid,'%s\r\n', 'pstext ref_mech_text.gmt -R -J -O -K -m -N  >> csps_gmt_plot.ps '  );
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
  fclose(fid);
	
	disp('Check the  ./polarity/plot_pol_gmt.bat file for GMT plotting')
end

h = msgbox('A GMT batch file called plot_pol_gmt.bat was created in POLARITY folder. Run this file from a command window to get a high quality GMT plot.','GMT plot file.','help');
   
    

     
%%  go back
cd ..
     
     
 



function f1_Callback(hObject, eventdata, handles)
% hObject    handle to f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f1 as text
%        str2double(get(hObject,'String')) returns contents of f1 as a double


% --- Executes during object creation, after setting all properties.
function f1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f4_Callback(hObject, eventdata, handles)
% hObject    handle to f4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f4 as text
%        str2double(get(hObject,'String')) returns contents of f4 as a double


% --- Executes during object creation, after setting all properties.
function f4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dselect.
function dselect_Callback(hObject, eventdata, handles)
% hObject    handle to dselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(handles.freqcheck,'Value') == get(handles.freqcheck,'Max'))
   % Checkbox is checked
   disp('Selected common frequency band option.')
   % we need to give the f1 f2 f3 f4 freq to stagui
   f1=str2double(get(handles.f1,'String'));
   f4=str2double(get(handles.f4,'String'));
   f2=f1;f3=f4;
   staguienv(f1,f2,f3,f4)
else
   disp('Selected different frequency band per station option.')
   staguienv
end

% --- Executes on button press in freqcheck.
function freqcheck_Callback(hObject, eventdata, handles)
% hObject    handle to freqcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of freqcheck


% --- Executes on button press in procout.
function procout_Callback(hObject, eventdata, handles)
% hObject    handle to procout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% prepare out1.dat
% check if we have all needed files 
if ispc
     h=dir('.\env_amp_inv\out3.dat');
else
     h=dir('./env_amp_inv/out3.dat');
end

if isempty(h); 
    errordlg('out3.dat file doesn''t exist. Press Run first. ','File Error');
  return    
else
end

if ispc
     h=dir('.\env_amp_inv\out1_save.dat');
else
     h=dir('./env_amp_inv/out1_save.dat');
end

if isempty(h); 
    errordlg('out1_save.dat file doesn''t exist. Press Run first. ','File Error');
  return    
else
end

%%
%% Open source.dat and put the selected depth
selected_depth=str2double(get(handles.depth,'String'));

% read  values from handles
magn=handles.selmag;
eventdate=char(handles.seltt);
whos

cd env_amp_inv
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

cd ..

%%
% start with out3.dat and read the Total number of GS  and  Chosen source number: 
if ispc
    fid = fopen('.\env_amp_inv\out3.dat');
else
    fid = fopen('./env_amp_inv/out3.dat');
end
% we need only 4 first lines
tline = fgets(fid);
tline = fgets(fid);
totalgs=sscanf(tline,'%u');
tline = fgets(fid);
tline = fgets(fid);
selectedsrc=sscanf(tline(24:end),'%u');
fclose(fid);
disp(['Total number of GS (s/d/r) points: '  num2str(totalgs) ]) 
disp(' ')
disp(['Selected source number:  '  num2str(selectedsrc) ]) 
disp(' ')
%% now we open out1_save.dat and look for the selected source number
if ispc
    fid = fopen('.\env_amp_inv\out1_save.dat');
else
    fid = fopen('./env_amp_inv/out1_save.dat');
end

tline = fgets(fid);
srcno=sscanf(tline,'%u');

while ischar(tline)

    % check if this is the source we need
    if selectedsrc==srcno
      disp('Found selected source')
          if ispc
               fid2=fopen('.\env_amp_inv\out1.dat','w');
          else
               fid2=fopen('./env_amp_inv/out1.dat','w');
          end
            for k=1:totalgs
               tline = fgets(fid);
               fprintf(fid2,'%s',tline);
            end
               fclose(fid2);    
        break
    else
      disp('Skipping lines')
      for k=1:totalgs
        tline = fgets(fid);
      end
    end
        
    % read next line
    tline = fgets(fid);
    srcno=sscanf(tline,'%u');
end

fclose(fid);


%% check status of checkpolopt

if (get(handles.checkpolopt,'Value') == get(handles.checkpolopt,'Max'))
   % Checkbox is checked run 
   disp('Selected polarity checking.')

%%     
cd env_amp_inv  

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
        disp(['Source depth  ' num2str(depth) ' equals CRUSTAL.DAT interface no ' num2str(i) ' ANGONE.EXE doesn''t like this. Adding 0.1 to depth'])
        warndlg(sprintf(['Source depth  ' num2str(depth) ' equals CRUSTAL.DAT interface no ' num2str(i) ' \n ANGONE.EXE doesn''t like this. Adding 0.1 to depth']))
        
        depth=depth+0.1;
        
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

%%   RUN ANGONE  %%%%%%%%%%%%%%

[status, result] = system('angone.exe');

  
   
   disp('Running sipolnew4.exe')
   system('sipolnew4.exe &')
   
   
   

%% go back   
cd ..
   
   
else
cd env_amp_inv
    
    
   disp('No polarity checking.')
   disp('Running sinopol.exe')
   system('sinopol.exe &')

cd ..   
   
end




% --- Executes on button press in checkpolopt.
function checkpolopt_Callback(hObject, eventdata, handles)
% hObject    handle to checkpolopt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkpolopt


fid=fopen('checkpol.isl','w');

      if (get(handles.checkpolopt,'Value') == get(handles.checkpolopt,'Max'))
         fprintf(fid,'%u',1);
         disp('Check polaties was selected')
      else
         fprintf(fid,'%u',0);
         disp('Check polaties wasn''t selected')
      end
fclose(fid);


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

%% check if we have extrapol.pol
%%%%%check if extrapol.pol exists...
h=dir('.\env_amp_inv\extrapol.pol');

if isempty(h); 

    disp('Extrapol.pol file doesn''t exist. ');

else
    %% read event.isl
      h=dir('event.isl');
    if isempty(h); 
       errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
    return
    else
      fid = fopen('event.isl','r');
       eventcor=fscanf(fid,'%g',2);
%        epidepth=fscanf(fid,'%g',1);magn=fscanf(fid,'%g',1);eventdate=fscanf(fid,'%s',1);
%        eventhour=fscanf(fid,'%s',1); eventmin=fscanf(fid,'%s',1); eventsec=fscanf(fid,'%s',1); eventagency=fscanf(fid,'%s',1);
      fclose(fid);
    end
    
  cd env_amp_inv
  
  
    disp('Found extrapol.pol file. Extra station polarities will be used');
  fid  = fopen('extrapol.pol','r');
    [stanamextra,stalatextra,stalonextra,stapolextra] = textread('extrapol.pol','%s %f %f %s',-1);
  fclose(fid);
  orlat=eventcor(2);  orlon=eventcor(1);
  grs80.geoid = almanac('earth','geoid','km','grs80');
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
  
  cd ..
  
end

%%
% now enter folder and open file
cd env_amp_inv

 if ispc
    dos('notepad station.dat &')
 else
    unix('gedit station.dat &')
 end

cd ..


% --- Executes on button press in usethisfreq.
function usethisfreq_Callback(hObject, eventdata, handles)
% hObject    handle to usethisfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   f1=str2double(get(handles.f1,'String'));
   f4=str2double(get(handles.f4,'String'));

if ispc   
   h=dir('.\env_amp_inv\allstat.dat');
else
   h=dir('./env_amp_inv/allstat.dat');
end

  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in env_amp_inv folder.','File Error');
     return
  else
      % 
      if ispc
        [stanames,od1,od2,od3,od4,~,~,~,~] = textread('.\env_amp_inv\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
      else
        [stanames,od1,od2,od3,od4,~,~,~,~] = textread('./env_amp_inv/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
      end

  end
  
nsta=length(stanames);

  %% update
if ispc
  fid = fopen('.\env_amp_inv\allstat.dat','w');
     for p=1:nsta
       fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\r\n', char(stanames(p)),od1(p),od2(p),od3(p),od4(p),f1,f1,f4,f4);
     end
  fclose(fid);
else
  fid = fopen('./env_amp_inv/allstat.dat','w');
     for p=1:nsta
       fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\n', char(stanames(p)),od1(p),od2(p),od3(p),od4(p),f1,f1,f4,f4); 
     end
  fclose(fid);
end


disp('env_amp_inv\allstat.dat was updated');
