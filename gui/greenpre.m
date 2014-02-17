function varargout = greenpre(varargin)
% GREENPRE M-file for greenpre.fig
%      GREENPRE, by itself, creates a new GREENPRE or raises the existing
%      singleton*.
%
%      H = GREENPRE returns the handle to a new GREENPRE or the handle to
%      the existing singleton*.
%
%      GREENPRE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GREENPRE.M with the given input arguments.
%
%      GREENPRE('Property','Value',...) creates a new GREENPRE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before greenpre_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to greenpre_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help greenpre

% Last Modified by GUIDE v2.5 29-Mar-2010 00:13:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @greenpre_OpeningFcn, ...
                   'gui_OutputFcn',  @greenpre_OutputFcn, ...
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


% --- Executes just before greenpre is made visible.
function greenpre_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to greenpre (see VARARGIN)

% Choose default command line output for greenpre
handles.output = hObject;

%%% check if GREEN folder exists..

h=dir('green');

if isempty(h);
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

%%% check if all ISOLA input file exist..

h=dir('duration.isl');

if isempty(h); 
  errordlg('Duration.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('duration.isl','r');
%    nlayers=fscanf(fid,'%i',1)
    tl=fscanf(fid,'%g',1)
    fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
h=dir('tsources.isl');
source_gmtfile=0;

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
       source_gmtfile=1
       
     elseif strcmp(tsource,'depth')
      disp('Inversion was done for a line of sources under epicenter.')
      nsources=fscanf(fid,'%i',1);
      distep=fscanf(fid,'%f',1)
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
      source_gmtfile=0
      
     elseif strcmp(tsource,'plane')
      disp('Inversion was done for a plane of sources.')
      nsources=fscanf(fid,'%i',1);
%      distep=fscanf(fid,'%f',1);
                noSourcesstrike=fscanf(fid,'%i',1)
                strikestep=fscanf(fid,'%f',1)
                noSourcesdip=fscanf(fid,'%i',1)
                dipstep=fscanf(fid,'%f',1)
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

%*
h=dir('stations.isl');

if isempty(h); 
    errordlg('Stations.isl file doesn''t exist. Run Station select. ','File Error');
  return    
else
    fid = fopen('stations.isl','r');
    nstations=fscanf(fid,'%i',1)
    fclose(fid);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%check if grdat.hed exists....
if ispc
 a=exist('.\green\grdat.hed','file');
else
 a=exist('./green/grdat.hed','file');
end
  if a == 2
         if ispc 
          fid = fopen('.\green\grdat.hed','r');
         else
          fid = fopen('./green/grdat.hed','r');
         end
            linetmp1=fgets(fid);
            linetmp2=fgets(fid);
            linetmp3=fgetl(fid);
       fclose(fid);
       nfreq=str2num(linetmp3(1,7:length(linetmp3)));

       maxfreq=nfreq/tl;
set(handles.fmax,'String',num2str(maxfreq))        
       
%        df=1/tl
% disp('Number of Frequencies')
% nfreq=fmax/df

   else
       maxfreq=0.1;
set(handles.fmax,'String',num2str(maxfreq))        
   end

set(handles.tltext,'String',num2str(tl))        
set(handles.nsourcestext,'String',num2str(nsources))         
set(handles.nstationstext,'String',num2str(nstations))   

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes greenpre wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = greenpre_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is greenpre 08/09/11');
disp('Changes: Added multiple crustal models.');
%disp('Changes: Solved bug with soutype.dat and multiple crustal models');


% --- Executes on button press in makegreen.
function makegreen_Callback(hObject, eventdata, handles)
% hObject    handle to makegreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


tl = str2double(get(handles.tltext,'String'))
nsources = str2double(get(handles.nsourcestext,'String'))
nstations=str2double(get(handles.nstationstext,'String'))

%%%% READ Fmax...and find number of frequencies
fmax = str2double(get(handles.fmax,'String'))
%%%compute df step in frequency..
disp('Frequency step')
df=1/tl
disp('Number of Frequencies')
nfreq=fmax/df


%%% check if we are in multiple crustal models case
h=dir('green.isl');

if isempty(h); 
  disp('Green.isl file doesn''t exist. Single crustal model options will be used.');
  modsel=0;
  
        fid = fopen('green.isl','w');
          if ispc
            fprintf(fid,'%s\r\n','single');
          else
            fprintf(fid,'%s\n','single');
          end
        fclose(fid);
          
else
    
    fid = fopen('green.isl','r');
    mulorsin=fscanf(fid,'%s',1);
    fclose(fid);

  switch  mulorsin 
    case 'single'
      disp('Single crustal model case')
      modsel=0;
    case 'multiple'
      disp('Multiple crustal models case')  
      modsel=1;
  end

end

%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%check the type of Time Function
if get(handles.delta,'Value') == get(handles.delta,'Max')
    disp('Delta Time function selected')
    istype=1;  % no need for new elementary seismograms
elseif get(handles.triangle,'Value') == get(handles.triangle,'Max')
    disp('Delta Time function selected')
    istype=2;
    t0 = str2double(get(handles.sdur,'String'));
else
    %%% case nothing is selected....!!
    errordlg('Please select type of time function','!! Error !!')
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%now we can create GRDAT.HED   cd in Green folder
% try
    
cd green

%%% decide if it is single or multiple models...!!


if modsel==0     %%% single crustal model

%%%%%%%%check if crustal.dat is here.......
h=dir('crustal.dat');

if isempty(h); 
  errordlg('crustal.dat file doesn''t exist. Run Define Crustal model. ','File Error');
  cd ..
  return
else
    fid = fopen('crustal.dat','r');
      line=fgets(fid);         %01 line
      line=fgets(fid);         %02 line
      nlayers=fscanf(fid,'%i',1)
    fclose(fid);
end
%%%ok 
 if ispc
    fid = fopen('grdat.hed','w');
    fprintf(fid,'%s\r\n','&input');
    fprintf(fid,'%s','nc=');
    fprintf(fid,'%i\r\n',nlayers);
    fprintf(fid,'%s','nfreq=');
    fprintf(fid,'%i\r\n',round(nfreq));
    fprintf(fid,'%s','tl=');
    fprintf(fid,'%g\r\n',tl);
    fprintf(fid,'%s\r\n','aw=0.1');
    fprintf(fid,'%s','nr=');
    fprintf(fid,'%i\r\n',nstations);
    fprintf(fid,'%s\r\n','ns=1');
    fprintf(fid,'%s\r\n','xl=8000000.');
    fprintf(fid,'%s\r\n','ikmax=100000');
    fprintf(fid,'%s\r\n','uconv=0.1E-03');
    fprintf(fid,'%s\r\n','fref=1.');
    fprintf(fid,'%s\r\n','/end');
    fclose(fid);
 else
    fid = fopen('grdat.hed','w');
    fprintf(fid,'%s\n','&input');
    fprintf(fid,'%s','nc=');
    fprintf(fid,'%i\n',nlayers);
    fprintf(fid,'%s','nfreq=');
    fprintf(fid,'%i\n',round(nfreq));
    fprintf(fid,'%s','tl=');
    fprintf(fid,'%g\n',tl);
    fprintf(fid,'%s\n','aw=0.1');
    fprintf(fid,'%s','nr=');
    fprintf(fid,'%i\n',nstations);
    fprintf(fid,'%s\n','ns=1');
    fprintf(fid,'%s\n','xl=8000000.');
    fprintf(fid,'%s\n','ikmax=100000');
    fprintf(fid,'%s\n','uconv=0.1E-03');
    fprintf(fid,'%s\n','fref=1.');
    fprintf(fid,'%s\n','/end');
    fclose(fid);
 end
%%%%%%%%%%finished with grdat.hed

%%%%%%%% check if we need delta or triangle and create proper file
switch istype
    
     case 1    % delta
           fid = fopen('soutype.dat','w');
             if ispc
                  fprintf(fid,'%s\r\n','7');
                  fprintf(fid,'%s\r\n','0.0');
                  fprintf(fid,'%s\r\n','0.0');
                  fprintf(fid,'%s\r\n','2');
             else
                  fprintf(fid,'%s\n','7');
                  fprintf(fid,'%s\n','0.0');
                  fprintf(fid,'%s\n','0.0');
                  fprintf(fid,'%s\n','2');
             end
           fclose(fid);

     case 2    % triangle
           fid = fopen('soutype.dat','w');
              if ispc
                   fprintf(fid,'%s\r\n','4');
                   fprintf(fid,'%4.1f\r\n',t0);
                   fprintf(fid,'%s\r\n','0.5');
                   fprintf(fid,'%s\r\n','1');
              else
                   fprintf(fid,'%s\n','4');
                   fprintf(fid,'%4.1f\n',t0);
                   fprintf(fid,'%s\n','0.5');
                   fprintf(fid,'%s\n','1');
              end
           fclose(fid);
end

%%%%prepare GRE??.bat and ELE??.bat 
 %%% create gre_ele.bat ..!!!
%%%delete previous batch files
if ispc
  [s,w] = system('del gre_ele.bat');
else
  [s,w] = unix('rm gre_ele.sh');
end
% [s,w] = system('del ELE*.bat');

%%% find filenames..
%              filename1=['gre' num2str(nsources) '.bat']
%              filename2=['ele' num2str(nsources) '.bat']

%%%create GRE?? batch file             
             
          if ispc
              
              fid = fopen('gre_ele.bat','w');

              for i=1:nsources ;
                    fprintf(fid,'%s\r\n',['copy src' num2str(i,'%02d') '.dat source.dat']);
                    fprintf(fid,'%s\r\n','gr_xyz.exe');
                    fprintf(fid,'%s\r\n',['copy gr.hea gr' num2str(i,'%02d') '.hea']);
                    fprintf(fid,'%s\r\n',['copy gr.hes gr' num2str(i,'%02d') '.hes']);
                    fprintf(fid,'%s\r\n','    ');
              end
              fprintf(fid,'%s\r\n','del gr.hea');
              fprintf(fid,'%s\r\n','del gr.hes');
              fprintf(fid,'%s\r\n','del source.dat');
              fprintf(fid,'%s\r\n','             ');
              fprintf(fid,'%s\r\n','rem end with GREEN part');
              fprintf(fid,'%s\r\n','             ');
              fprintf(fid,'%s\r\n','rem elementary seismogram part ');
              fprintf(fid,'%s\r\n','             ');

%              fclose(fid);
              
%  create ELE?? batch file                 
%              fid = fopen(filename2,'w');

              for i=1:nsources ;
                    fprintf(fid,'%s\r\n',['copy gr' num2str(i,'%02d') '.hes gr.hes']);
                    fprintf(fid,'%s\r\n',['copy gr' num2str(i,'%02d') '.hea gr.hea']);
                    fprintf(fid,'%s\r\n','elemse.exe');
                    fprintf(fid,'%s\r\n',['copy elemse.dat elemse' num2str(i,'%02d') '.dat']);
                    fprintf(fid,'%s\r\n','    ');
              end
              fprintf(fid,'%s\r\n','del gr.hea');
              fprintf(fid,'%s\r\n','del gr.hes');
              fprintf(fid,'%s\r\n','del elemse.dat');
              fprintf(fid,'%s\r\n','rem ******************************** ');
              fprintf(fid,'%s\r\n','rem ******************************** ');
              fprintf(fid,'%s\r\n','rem Finished with Green function calculation ');
              fprintf(fid,'%s\r\n','rem you can go on with file copy.... ');
              fclose(fid);

          else
            fid = fopen('gre_ele.sh','w');
             fprintf(fid,'%s\n','#!/bin/bash');
             fprintf(fid,'%s\n','             ');
             
              for i=1:nsources ;
                    fprintf(fid,'%s\n',['cp -v src' num2str(i,'%02d') '.dat source.dat']);
                    fprintf(fid,'%s\n','gr_xyz.exe');
                    fprintf(fid,'%s\n',['cp -v gr.hea gr' num2str(i,'%02d') '.hea']);
                    fprintf(fid,'%s\n',['cp -v gr.hes gr' num2str(i,'%02d') '.hes']);
                    fprintf(fid,'%s\n','    ');
              end
              fprintf(fid,'%s\n','rm gr.hea');
              fprintf(fid,'%s\n','rm gr.hes');
              fprintf(fid,'%s\n','rm source.dat');
              fprintf(fid,'%s\n','             ');
              fprintf(fid,'%s\n','echo  ---------------------------------------------');
              fprintf(fid,'%s\n','echo  end with GREEN part');
              fprintf(fid,'%s\n','             ');
              fprintf(fid,'%s\n','echo  elementary seismogram part ');
              fprintf(fid,'%s\n','echo  ---------------------------------------------');
              fprintf(fid,'%s\n','             ');

              for i=1:nsources ;
                    fprintf(fid,'%s\n',['cp -v gr' num2str(i,'%02d') '.hes gr.hes']);
                    fprintf(fid,'%s\n',['cp -v gr' num2str(i,'%02d') '.hea gr.hea']);
                    fprintf(fid,'%s\n','elemse.exe');
                    fprintf(fid,'%s\n',['cp -v elemse.dat elemse' num2str(i,'%02d') '.dat']);
                    fprintf(fid,'%s\n','    ');
              end
              fprintf(fid,'%s\n','rm gr.hea');
              fprintf(fid,'%s\n','rm gr.hes');
              fprintf(fid,'%s\n','rm elemse.dat');
              fprintf(fid,'%s\n','    ');
              fprintf(fid,'%s\n','echo ----------------------------------------------- ');
              fprintf(fid,'%s\n','echo -----------------------------------------------');
              fprintf(fid,'%s\n','echo     Finished with Green function calculation ');
              fprintf(fid,'%s\n','echo          you can go on with file copy.... ');
              fprintf(fid,'%s\n','echo ----------------------------------------------- ');
              fprintf(fid,'%s\n','echo -----------------------------------------------');
              fprintf(fid,'%s\n','    ');
              fprintf(fid,'%s\n','    ');
              fclose(fid);
              
          end  %% end of linux part
          
%%%%%%%%%%%%%RUN the batch files

%%%%%%%%%%%%%%%% try
button = questdlg('Create Green Functions?',...
'Continue Operation','Yes','No','Yes');
% 
if strcmp(button,'Yes')
    if ispc 
         [status,message] = system('del elemse*.dat')  %%%%% clear all files....!!!!!!!!!!!!!!!!!!!!!!!!!!!
    else
         [status,message] = system('rm elemse*.dat')  %%%%% clear all files....!!!!!!!!!!!!!!!!!!!!!!!!!!!
    end
   disp('Running gr_xyz')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
if ispc
    system('gre_ele.bat  &')
else
    disp('Linux ')
    pwd
    
    !chmod +x gre_ele.sh
    system(' gnome-terminal -e "bash -c ./gre_ele.sh;bash" ')
    %gnome-terminal -e "bash -c ./gre_ele.sh;bash"

end
    
%    system(filename1)
%    system(filename2)

button = questdlg('Copy files in invert folder (BE VERY CAREFUL ..!! Green calculations should have finished. Check the command window and WAIT for the Finished with Green function calculation message to appear BEFORE pressing Yes',...
'Continue Operation','Yes','No','Yes');

if strcmp(button,'Yes')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%copy files elem* to invert
disp('Removing elemse*.dat files from invert folder')
% %%% return to ISOLA folder  
cd ..
if ispc
[status,message] = system('del .\invert\elemse*.dat');
else
[status,message] = system('rm ./invert/elemse*.dat');
end
disp('Copying files')
        if ispc
           [s,mess,messid]=copyfile('.\green\elemse*.dat','.\invert')
        else
           [s,mess,messid]=copyfile('./green/elemse*.dat','./invert')
        end

    if s==1 
        h=msgbox('Copied files in invert directory','Copy files');
         if ispc
           [status,message] = system('del .\green\elemse*.dat');  %%% remove from green
         else
           [status,message] = system('rm ./green/elemse*.dat');  %%% remove from green
         end
    else
        h=msgbox('Failed to copy files in invert directory','Copy files');
    end

else
    disp('Abort Copy files')
    cd ..
end

elseif strcmp(button,'No')
   disp('Green function generation canceled')
   cd ..
end
%              
%%% catch
%%%    cd ..
%%% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  else multiple models
else
    
%% add code for multiple models

%%% read allstat2.dat
stationfile='allstat2.dat';
%read data in 7 arrays
fid  = fopen(stationfile,'r');
[staname,d1,d2,d3,d4,d5] = textread(stationfile,'%s %f %f %f %f %f',-1);
fclose(fid);
    
nmodels=max(d5)

%%%we need to check if allstat2.dat format is ok...


%%%%%%%% check if we need delta or triangle and create proper file
switch istype
    
     case 1    % delta
         fid = fopen('soutype.dat','w');
            if ispc 
                fprintf(fid,'%s\r\n','7');
                fprintf(fid,'%s\r\n','0.0');
                fprintf(fid,'%s\r\n','0.0');
                fprintf(fid,'%s\r\n','2');
            else
                fprintf(fid,'%s\n','7');
                fprintf(fid,'%s\n','0.0');
                fprintf(fid,'%s\n','0.0');
                fprintf(fid,'%s\n','2');
            end
         fclose(fid);

     case 2    % triangle
         fid = fopen('soutype.dat','w');
            if ispc
                fprintf(fid,'%s\r\n','4');
                fprintf(fid,'%4.1f\r\n',t0);
                fprintf(fid,'%s\r\n','0.5');
                fprintf(fid,'%s\r\n','1');
            else
                fprintf(fid,'%s\n','4');
                fprintf(fid,'%4.1f\n',t0);
                fprintf(fid,'%s\n','0.5');
                fprintf(fid,'%s\n','1');
            end
         fclose(fid);
end

%%%% we need to prepare grdat.hed we'll do for selected models

for i=1:nmodels
    
    modelname{i}=['crustal_0' num2str(i) '.dat'];
    grdathed{i}=['grdat_0' num2str(i) '.hed'];
    
     %%%  find nlayers per model
      fid = fopen(modelname{i},'r');
      line=fgets(fid);         %01 line
      line=fgets(fid);         %02 line
      nlayers=fscanf(fid,'%i',1);
      fclose(fid);

%%% make grdat.hed for specific model...
if ispc      
    fid = fopen(grdathed{i},'w');
    fprintf(fid,'%s\r\n','&input');
    fprintf(fid,'%s','nc=');
    fprintf(fid,'%i\r\n',nlayers);
    fprintf(fid,'%s','nfreq=');
    fprintf(fid,'%i\r\n',round(nfreq));
    fprintf(fid,'%s','tl=');
    fprintf(fid,'%g\r\n',tl);
    fprintf(fid,'%s\r\n','aw=0.1');
    fprintf(fid,'%s','nr=');
    fprintf(fid,'%i\r\n',nstations);
    fprintf(fid,'%s\r\n','ns=1');
    fprintf(fid,'%s\r\n','xl=8000000.');
    fprintf(fid,'%s\r\n','ikmax=100000');
    fprintf(fid,'%s\r\n','uconv=0.1E-03');
    fprintf(fid,'%s\r\n','fref=1.');
    fprintf(fid,'%s\r\n','/end');
    fclose(fid);
else
    fid = fopen(grdathed{i},'w');
    fprintf(fid,'%s\n','&input');
    fprintf(fid,'%s','nc=');
    fprintf(fid,'%i\n',nlayers);
    fprintf(fid,'%s','nfreq=');
    fprintf(fid,'%i\n',round(nfreq));
    fprintf(fid,'%s','tl=');
    fprintf(fid,'%g\n',tl);
    fprintf(fid,'%s\n','aw=0.1');
    fprintf(fid,'%s','nr=');
    fprintf(fid,'%i\n',nstations);
    fprintf(fid,'%s\n','ns=1');
    fprintf(fid,'%s\n','xl=8000000.');
    fprintf(fid,'%s\n','ikmax=100000');
    fprintf(fid,'%s\n','uconv=0.1E-03');
    fprintf(fid,'%s\n','fref=1.');
    fprintf(fid,'%s\n','/end');
    fclose(fid);
end
      
end

%%%%%%%%%%finished with grdat.hed
%%% prepare GRE??.bat and ELE??.bat 
%%% create gre_ele.bat ..!!!
%%%delete previous batch files
if ispc 
  [s,w] = system('del gre_ele.bat');
  [s,w] = system('del grenew.bat');
else
  [s,w] = system('rm gre_ele.sh');
  [s,w] = system('rm grenew.sh');
end

if ispc

   fid = fopen('grenew.bat','w');

    fprintf(fid,'%s\r\n','rem ******  Multiple crustal model Green function preparation  ');
    fprintf(fid,'%s\r\n','rem ******  It needs GRDAT.HED, STATION.DAT   ');
    fprintf(fid,'%s\r\n','rem ******  NEW !!!!! it also needs ALLSTAT2.DAT with crustal model in the SIXTH column  ');
    fprintf(fid,'%s\r\n','rem ******  numbers in sixth column of ALLSTAT2 must be 1, or 1 and 2, or 1,2, 3, or 1,2,3,4, NOT e.g. 1 and 3.   ');
    fprintf(fid,'%s\r\n','rem ******  Start with first source and all models and continue.   ');
    
                 for i=1:nsources ;

                    fprintf(fid,'%s\r\n','    ');
                    fprintf(fid,'%s\r\n',['rem **********  Source no '  num2str(i,'%02d')  '  *********']);
                    fprintf(fid,'%s\r\n','    ');
                    fprintf(fid,'%s\r\n',['copy src' num2str(i,'%02d') '.dat source.dat']);
                    fprintf(fid,'%s\r\n','    ');
                    
                      for j=1:nmodels
                          
                        fprintf(fid,'%s\r\n',['copy crustal_' num2str(j,'%02d') '.dat crustal.dat']);
                        fprintf(fid,'%s\r\n',['copy   grdat_' num2str(j,'%02d') '.hed   grdat.hed']);
                        fprintf(fid,'%s\r\n','gr_xyz.exe');
                        fprintf(fid,'%s\r\n','elemse.exe');
                        fprintf(fid,'%s\r\n',['copy elemse.dat elemse_' num2str(j,'%02d') '.dat']);
    
                        fprintf(fid,'%s\r\n','    ');
                        
                      end
                       
                        fprintf(fid,'%s\r\n','rem Run elecomb.exe which selects proper elementary seismograms per source and model');
                        fprintf(fid,'%s\r\n','rem it reads elemse_01, _02 for crustal models 01_02 (fixed source)'); 
                        fprintf(fid,'%s\r\n','    ');
                        
                        fprintf(fid,'%s\r\n','elecomb.exe');
                        fprintf(fid,'%s\r\n',['copy elemsenew.dat elemse' num2str(i,'%02d') '.dat']); %%%source number
                        fprintf(fid,'%s\r\n','    ');

                       for j=1:nmodels
                         fprintf(fid,'%s\r\n',['del elemse_' num2str(j,'%02d') '.dat']);
                       end

                        fprintf(fid,'%s\r\n','    ');
                        fprintf(fid,'%s\r\n','    ');
                    
                 end
                 
                        fprintf(fid,'%s\r\n','    ');
                        fprintf(fid,'%s\r\n','    ');
              
              fprintf(fid,'%s\r\n','rem ******************************** ');
              fprintf(fid,'%s\r\n','rem ******************************** ');
              fprintf(fid,'%s\r\n','rem Finished with Green function calculation ');
              fprintf(fid,'%s\r\n','rem you can go on with file copy.... ');

   fclose(fid);

else  % linux
    
   fid = fopen('grenew.sh','w');
    fprintf(fid,'%s\n','#!/bin/bash');
    fprintf(fid,'%s\n','             ');
             
    fprintf(fid,'%s\n','# ******  Multiple crustal model Green function preparation  ');
    fprintf(fid,'%s\n','# ******  It needs GRDAT.HED, STATION.DAT   ');
    fprintf(fid,'%s\n','# ******  NEW !!!!! it also needs ALLSTAT2.DAT with crustal model in the SIXTH column  ');
    fprintf(fid,'%s\n','# ******  numbers in sixth column of ALLSTAT2 must be 1, or 1 and 2, or 1,2, 3, or 1,2,3,4, NOT e.g. 1 and 3.   ');
    fprintf(fid,'%s\n','# ******  Start with first source and all models and continue.   ');
    
                 for i=1:nsources ;

                    fprintf(fid,'%s\n','    ');
                    fprintf(fid,'%s\n',['# **********  Source no '  num2str(i,'%02d')  '  *********']);
                    fprintf(fid,'%s\n','    ');
                    fprintf(fid,'%s\n',['cp src' num2str(i,'%02d') '.dat source.dat']);
                    fprintf(fid,'%s\n','    ');
                    
                      for j=1:nmodels
                          
                        fprintf(fid,'%s\n',['cp crustal_' num2str(j,'%02d') '.dat crustal.dat']);
                        fprintf(fid,'%s\n',['cp   grdat_' num2str(j,'%02d') '.hed   grdat.hed']);
                        fprintf(fid,'%s\n','gr_xyz.exe');
                        fprintf(fid,'%s\n','elemse.exe');
                        fprintf(fid,'%s\n',['cp elemse.dat elemse_' num2str(j,'%02d') '.dat']);
    
                        fprintf(fid,'%s\n','    ');
                        
                      end
                       
                        fprintf(fid,'%s\n','# Run elecomb.exe which selects proper elementary seismograms per source and model');
                        fprintf(fid,'%s\n','# it reads elemse_01, _02 for crustal models 01_02 (fixed source)'); 
                        fprintf(fid,'%s\n','    ');
                        
                        fprintf(fid,'%s\n','elecomb.exe');
                        fprintf(fid,'%s\n',['cp elemsenew.dat elemse' num2str(i,'%02d') '.dat']); %%%source number
                        fprintf(fid,'%s\n','    ');

                       for j=1:nmodels
                         fprintf(fid,'%s\n',['rm elemse_' num2str(j,'%02d') '.dat']);
                       end

                        fprintf(fid,'%s\n','    ');
                        fprintf(fid,'%s\n','    ');
                    
                end
                 
                        fprintf(fid,'%s\n','    ');
                        fprintf(fid,'%s\n','    ');
              
              fprintf(fid,'%s\n','# ******************************** ');
              fprintf(fid,'%s\n','# ******************************** ');
              fprintf(fid,'%s\n','# Finished with Green function calculation ');
              fprintf(fid,'%s\n','# you can go on with file copy.... ');

   fclose(fid);
    
    
end  %% end of linux part

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%%%%%%%%%%%%             RUN the batch file  grenew.bat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

try

button = questdlg('Create Multiple crustal model Green Functions?','Continue Operation','Yes','No','Yes');
% 
if strcmp(button,'Yes')
      if ispc 
         [status,message] = system('del elemse*.dat')  %%%%% clear all files....!!!!!!!!!!!!!!!!!!!!!!!!!!!
      else
         [status,message] = system('rm elemse*.dat')  %%%%% clear all files....!!!!!!!!!!!!!!!!!!!!!!!!!!!
      end
   disp('Running for multiple crustal models')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
if ispc
    system('grenew.bat &')
else
    !chmod u+rwx grenew.sh
    % system('gnome-terminal -e ./grenew.sh')
    
    system('gnome-terminal -e "bash -c ./grenew.sh;bash"')
    
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
button = questdlg('Copy files in invert folder (BE VERY CAREFUL ..!! Green calculations should have finished. Check the command window and WAIT for the Finished with Green function calculation message to appear BEFORE pressing Yes',...
'Continue Operation','Yes','No','Yes');

if strcmp(button,'Yes')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
%%copy files elem* to invert
disp('Removing elemse*.dat files from invert folder')
% %%% return to ISOLA folder  
cd ..

if ispc 
   [status,message] = system('del .\invert\elemse*.dat');
else
   [status,message] = system('rm ./invert/elemse*.dat');
end
   
disp('Copying files')
if ispc
  [s,mess,messid]=copyfile('.\green\elemse*.dat','.\invert')
else
  [s,mess,messid]=copyfile('./green/elemse*.dat','./invert')
end
    if s==1 
        h=msgbox('Copied files in invert directory','Copy files');
        if ispc 
            [status,message] = system('del .\green\elemse*.dat');  %%% remove from green
        else
            [status,message] = system('rm ./green/elemse*.dat');  %%% remove from green
        end

    else
        h=msgbox('Failed to copy files in invert directory','Copy files');
    end

else
    disp('Abort Copy files')
    cd ..
end

elseif strcmp(button,'No')
   disp('Green function generation canceled')
   cd ..
end
%              
catch
    cd ..
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end  %%% end of multiple of single model IF

%% prepare stype.isl for latter use by invert

switch istype
    
     case 1    % delta
           fid = fopen('stype.isl','w');
             if ispc
                fprintf(fid,'%s\r\n','delta');
             else
                fprintf(fid,'%s\n','delta');
             end
           fclose(fid);

     case 2    % triangle
           fid = fopen('stype.isl','w');
              if ispc
                   fprintf(fid,'%s\r\n','triangle');
                   fprintf(fid,'%4.1f\r\n',t0);
              else
                   fprintf(fid,'%s\n','triangle');
                   fprintf(fid,'%4.1f\n',t0);
              end
           fclose(fid);
end


pwd

% catch
%     cd ..
% end





% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.greenpre)


% --- Executes during object creation, after setting all properties.
function fmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fmax_Callback(hObject, eventdata, handles)
% hObject    handle to fmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fmax as text
%        str2double(get(hObject,'String')) returns contents of fmax as a double


% --- Executes on button press in delta.
function delta_Callback(hObject, eventdata, handles)
% hObject    handle to delta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of delta

off =[handles.triangle];
mutual_exclude(off)
enableoff([handles.sdur,handles.duration]);


% --- Executes on button press in triangle.
function triangle_Callback(hObject, eventdata, handles)
% hObject    handle to triangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of triangle

off =[handles.delta];
mutual_exclude(off)

enableon([handles.sdur,handles.duration]);


% --- Executes during object creation, after setting all properties.
function sdur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function sdur_Callback(hObject, eventdata, handles)
% hObject    handle to sdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdur as text
%        str2double(get(hObject,'String')) returns contents of sdur as a double



function mutual_exclude(off)
set(off,'Value',0)

function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')
