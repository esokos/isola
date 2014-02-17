function varargout = create_synth(varargin)
% CREATE_SYNTH M-file for create_synth.fig
%      CREATE_SYNTH, by itself, creates a new CREATE_SYNTH or raises the existing
%      singleton*.
%
%      H = CREATE_SYNTH returns the handle to a new CREATE_SYNTH or the handle to
%      the existing singleton*.
%
%      CREATE_SYNTH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATE_SYNTH.M with the given input arguments.
%
%      CREATE_SYNTH('Property','Value',...) creates a new CREATE_SYNTH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before create_synth_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to create_synth_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help create_synth

% Last Modified by GUIDE v2.5 28-Aug-2013 20:54:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @create_synth_OpeningFcn, ...
                   'gui_OutputFcn',  @create_synth_OutputFcn, ...
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


% --- Executes just before create_synth is made visible.
function create_synth_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to create_synth (see VARARGIN)

% Choose default command line output for create_synth
handles.output = hObject;
%%
disp('This is create_synth.m')
disp('Ver.1.0, 02/06/2011')
disp('           ')

% if ~ispc
%     
%     errordlg('Not ready for Linux yet')
% delete(handles.create_synth)
% end

%%
%check if INVERT exists..!
fh2=exist('invert','dir');
if (fh2~=7);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
   delete(handles.create_synth)
end
%check if GREEN exists..!
fh2=exist('green','dir');
if (fh2~=7);
    errordlg('GREEN folder doesn''t exist. Please create it. ','Folder Error');
   delete(handles.create_synth)
end
%here we check if SYNTH folder exists
fh=exist('synth','dir');
if (fh~=7);
    errordlg('Synth folder doesn''t exist. Please create it. ','Folder Error');
    delete(handles.create_synth)
end

%% Check if we have all needed files
%check if INPINV.DAT exists..!
if ispc
  fh2=exist('.\invert\inpinv.dat','file');
else
  fh2=exist('./invert/inpinv.dat','file');
end

if (fh2~=2);
    errordlg('Invert folder doesn''t contain inpinv.dat. Please run inversion. ','File Error');
   delete(handles.create_synth)
end

% check for allstat.dat
if ispc 
  fh2=exist('.\invert\allstat.dat','file');
else
  fh2=exist('./invert/allstat.dat','file');
end

if (fh2~=2);
    errordlg('Invert folder doesn''t contain allstat.dat. Please run inversion. ','File Error');
    delete(handles.create_synth)
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
               disp('Forward code can use this allstat.dat.')
           case 6
               disp('Found version of allstat without frequencies e.g. 001 1 1 1 1 STA. SNR will not be calculated.')
               disp('Forward code cannot use this allstat.dat.Prepare a new allstat.dat file like this e.g. STA 1 1 1 1 f1 f2 f3 f4 ')
           case 5
               disp('Found old version of allstat without frequencies and without station masking e.g. STA 1 1 1 1. SNR will not be calculated.')
               disp('Forward code cannot use this allstat.dat.Prepare a new allstat.dat file like this e.g. STA 1 1 1 1 f1 f2 f3 f4 ')
       end   
end

% check for grdat.hed
if ispc 
   fh2=exist('.\green\grdat.hed','file');
else
   fh2=exist('./green/grdat.hed','file');
end
   
if (fh2~=2);
    errordlg('Green folder doesn''t contain grdat.hed. Please run green function calculation. ','File Error');
   delete(handles.create_synth)
end

% check for grdat.hed
if ispc
   fh2=exist('.\green\soutype.dat','file');
else
   fh2=exist('./green/soutype.dat','file');
end

if (fh2~=2);
   errordlg('Green folder doesn''t contain soutype.dat. Please run green function calculation. ','File Error');
   delete(handles.create_synth)
end

%% find how many green functions we have
% Start reading values we need

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
h=dir('duration.isl');

if isempty(h); 
  errordlg('Duration.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('duration.isl','r');
%    nlayers=fscanf(fid,'%i',1)
    tl=fscanf(fid,'%g',1);
    fclose(fid);
end
% read grdat.hed exists....
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
          set(handles.gtext,'String',num2str(maxfreq,'%2.2f'))  
         
%% find filter and dt
cd invert
          fid = fopen('inpinv.dat','r');
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %02 line
            linetmp=fgets(fid);         %03 line
            tstep=fscanf(fid,'%g',1);    %04
            linetmp=fgets(fid);         %05 line
            linetmp=fgets(fid);         %06 line
            linetmp=fgets(fid);         %07 line
            linetmp=fgets(fid);         %08 line
            linetmp=fgets(fid);         %09 line
            linetmp=fgets(fid);         %10 line
            linetmp=fgets(fid);         %11 line
            linetmp=fgets(fid);          %12 line
            linetmp=fgets(fid);          %13 line
            linetmp=fgets(fid);          %13 line
            ifilter=fscanf(fid,'%g',4);  %14
            linetmp=fgets(fid);         %15 line
            linetmp=fgets(fid);         %16 line
       fclose(fid);
cd ..

set(handles.f1,'String',num2str(ifilter(1,1)));        
set(handles.f2,'String',num2str(ifilter(2,1)));         
set(handles.f3,'String',num2str(ifilter(3,1)));          
set(handles.f4,'String',num2str(ifilter(4,1)));          

%% now we need mechan.dat
% % look if we have a mechan.dat in invert
% fh2=exist('.\invert\mechan.dat','file');
% if (fh2~=2);
%     disp('Invert folder doesn''t contain mechan.dat.');
% mechanlife=0;
% else
%         fileInfo = dir('.\invert\mechan.dat');
%         fileSize = fileInfo.bytes;
%         if fileSize==0
%               disp('mechan.dat file in invert folder is of zero size')
%               mechanlife=0;
%         else
%               disp('Found mechan.dat file in invert folder will use it to update values for forward simulation')
%               mechanlife=1;
%         end
% end

%%
% look for inv1.dat file to get moment and delay
if ispc
   fh2=exist('.\invert\inv1.dat','file');
else
   fh2=exist('./invert/inv1.dat','file');
end

if (fh2~=2);
    disp('Invert folder doesn''t contain inv1.dat.');
inv1life=0;    
else
       if ispc
          fileInfo = dir('.\invert\inv1.dat');
       else
          fileInfo = dir('./invert/inv1.dat');
       end
       
        fileSize = fileInfo.bytes;
        if fileSize==0
              disp('inv1.dat file in invert folder is of zero size')
              inv1life=0;    
        else
              disp('Found inv1.dat file in invert folder will use it to update values for forward simulation')
              inv1life=1;    
        end
end
%% Based on above findings try to read the needed values and update the
% % fields in GUI
% if mechanlife ==1  %read it
% cd invert
%           fid = fopen('mechan.dat','r');
%             linetmp=fgets(fid);            %01 line
%             linetmp=fgets(fid);            %02 line
%             moment=fscanf(fid,'%g');       %03
%             linetmp=fgets(fid);            %04 line
%             focalmech=fscanf(fid,'%g',3);  %05
%             linetmp=fgets(fid);            %06 line
%             linetmp=fgets(fid);            %06 line
%             delay=fscanf(fid,'%g');        %07
%          fclose(fid);
% cd ..
% %%% update fields in GUI
% 
% 
% 
% else
%     
% end

% read inv1.dat
if inv1life ==1  %read it
cd invert
          fid = fopen('inv1.dat','r');
            linetmp=fgets(fid);            
            linetmp=fgets(fid);            
            linetmp=fgets(fid);             
             for i=1:nsources
              linetmp=fgets(fid);            
             end
            linetmp=fgets(fid);            
            linetmp=fgets(fid);             
            linetmp=fgets(fid);            
            inv1_isour_shift=sscanf(linetmp,'%*s %i %i')      
            for i=1:10
            linetmp=fgets(fid);            
            end
            linetmp=fgets(fid);            
            inv1_moment=sscanf(linetmp,'%*s %*s %e')   
            for i=1:4
            linetmp=fgets(fid);            
            end
            linetmp=fgets(fid);            
            inv1_sdr=sscanf(linetmp,'%*s %d %d %d')     
            
         fclose(fid);
cd ..


%%% update fields in GUI             
set(handles.moment,'String',num2str(inv1_moment,'%10.5e'));        
set(handles.strike,'String',num2str(inv1_sdr(1,1)));        
set(handles.dip,'String',num2str(inv1_sdr(2,1)));        
set(handles.rake,'String',num2str(inv1_sdr(3,1)));        
set(handles.delay,'String',num2str(inv1_isour_shift(2,1)*tstep));        
set(handles.source,'String',num2str(inv1_isour_shift(1,1)));  
set(handles.timetext,'String', ['Time step (dt) was ' num2str(tstep) '   Best time step in dt was ' num2str(inv1_isour_shift(2,1))]);  


else

    disp('Inv1.dat wasn''t found. GUI will use null values. Please give your preferred values for forward simulation')
    
inv1_moment=0;
inv1_sdr=[0;0;0];
inv1_isour_shift=[0 ;0];

set(handles.moment,'String',num2str(inv1_moment,'%10.5e'));        
set(handles.strike,'String',num2str(inv1_sdr(1,1)));        
set(handles.dip,'String',num2str(inv1_sdr(2,1)));        
set(handles.rake,'String',num2str(inv1_sdr(3,1)));        
set(handles.delay,'String',num2str(inv1_isour_shift(2,1)*tstep));        
set(handles.source,'String',num2str(inv1_isour_shift(1,1)));  
%set(handles.timetext,'String', ['Time step (dt) was ' num2str(tstep) '   Best time step in dt was ' num2str(inv1_isour_shift(2,1))]);  

end

disp(['Found time step (dt) : ', num2str(tstep)]);
disp(['Found filter    : ', num2str(ifilter(1,1)) '  '  num2str(ifilter(2,1))  '  '  num2str(ifilter(3,1))  '  '  num2str(ifilter(4,1)) ]);
disp(['Found source : ',num2str(inv1_isour_shift(1,1)) '   Best time shift=' num2str(inv1_isour_shift(2,1)) ' dt.  ' 'Time step=' num2str(tstep) '.' ' Time shift in sec= ' num2str(tstep*inv1_isour_shift(2,1)) ]);
disp(['Found moment : ', num2str(inv1_moment,'%10.5e') ]);
disp(['Found Strike/Dip/Rake : ', num2str(inv1_sdr(1,1))  '  '  num2str(inv1_sdr(2,1))  '  '  num2str(inv1_sdr(3,1)) ]);

%% read allstat
% Copy  in synth
if ispc 
    
   [status, message]=copyfile('.\invert\allstat.dat','.\synth\allstat.dat');
   
   if status==0
    disp(['Allstat.dat copy to .\synth failed. Error message is ' message])
   end
   
else
    
   [status, message]=copyfile('./invert/allstat.dat','./synth/allstat.dat');
   
   if status==0
    disp(['Allstat.dat copy to ./synth failed. Error message is ' message])
   end
   
end


% read allstat.dat and store station names                    
if ispc
    fid = fopen('.\synth\allstat.dat');
else
    fid = fopen('./synth/allstat.dat');
end
    
C = textscan(fid, '%s %u %u %u %u %f %f %f %f');
fclose(fid);

stnames=C{1}
%stnames2=C{2}

disp('Found the following stations in allstat.dat')
nostations=length(stnames);
%populate the listbox with station names now ...    
%%% add All option
stnames{nostations+1}='All';
%stnames2{1:end-1}

set(handles.stationslistbox,'String',stnames)          %%%%% Fill listbox with stations names
set(handles.stationslistbox,'Value',nostations+1)      %%%%% Set default plot to All stations


%%
handles.stnames=stnames;
%handles.stnames2=stnames2;
handles.nostations=nostations;
handles.ifilter=ifilter;
handles.tstep=tstep;
handles.nsources=nsources;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes create_synth wait for user response (see UIRESUME)
% uiwait(handles.create_synth);


% --- Outputs from this function are returned to the command line.
function varargout = create_synth_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%
% if we change values in GUI these will go to 99.syn
f1=str2double(get(handles.f1,'String'));  
f2=str2double(get(handles.f2,'String'));  
f3=str2double(get(handles.f3,'String'));  
f4=str2double(get(handles.f4,'String'));  
%
moment= get(handles.moment,'String');  
strike= get(handles.strike,'String');  
dip=get(handles.dip,'String');  
rake=get(handles.rake,'String');  
%
delay=get(handles.delay,'String');    % time shift
%
source=get(handles.source,'String');
% read tstep
tstep=handles.tstep;
% read sources
nsources=handles.nsources;
% read station names
stnames=handles.stnames;
% read station names
% stnames2=handles.stnames;
% read station number
nostations=handles.nostations;
%% Create soutype.dat for source type
%  check the selected type of Time Function
if get(handles.delta,'Value') == get(handles.delta,'Max')
    disp('Delta Time function selected')
    istype=1;  
elseif get(handles.triangle,'Value') == get(handles.triangle,'Max')
    disp('Triangle Time function selected')
    istype=2;
    t0 = str2double(get(handles.duration,'String'));
else
    %%% case nothing is selected....!!
    errordlg('Please select type of time function','!! Error !!')
    return
end

% prepare the file
switch istype
    
     case 1    % delta
         if ispc
           fid = fopen('.\synth\soutype.dat','w');
           fprintf(fid,'%s\r\n','7');
           fprintf(fid,'%s\r\n','0.0');
           fprintf(fid,'%s\r\n','0.0');
           fprintf(fid,'%s\r\n','2');
           fclose(fid);
         else
           fid = fopen('./synth/soutype.dat','w');
           fprintf(fid,'%s\n','7');
           fprintf(fid,'%s\n','0.0');
           fprintf(fid,'%s\n','0.0');
           fprintf(fid,'%s\n','2');
           fclose(fid);
         end

     case 2    % triangle
         if ispc
           fid = fopen('.\synth\soutype.dat','w');
           fprintf(fid,'%s\r\n','4');
           fprintf(fid,'%4.1f\r\n',t0);
           fprintf(fid,'%s\r\n','0.5');
           fprintf(fid,'%s\r\n','1');
           fclose(fid);
         else
           fid = fopen('./synth/soutype.dat','w');
           fprintf(fid,'%s\n','4');
           fprintf(fid,'%4.1f\n',t0);
           fprintf(fid,'%s\n','0.5');
           fprintf(fid,'%s\n','1');
           fclose(fid);
         end
end

%%
% !!! IMPORTANT we need to check if this is out of our green calculation limits

%% Create 99.syn in synth THIS HAS TO GO to Calculate
cd synth
if ispc 
  fid = fopen('99.syn','w');
   fprintf(fid,'%s\r\n','''20040712''  5.2  7   ! date in apostrophes, magnitude and depth ... not needed here');
   fprintf(fid,'%s\r\n','46.31   13.61          ! epicentre lat and lon (degrees)   ... not needed here');
   fprintf(fid,'%s\r\n','00 00 00.0             ! origin time     ... not needed here');
   fprintf(fid,'%s\r\n','00 00 00.0             ! record start time (after alignment) ... not needed here');
   fprintf(fid,'%g    %s\r\n',tstep,'! time step (after resampling)');
   fprintf(fid,'%g   %g   %s\r\n',f1, f2 ,'! filter left taper (Hz) ');
   fprintf(fid,'%g   %g   %s\r\n',f3, f4 ,'! filter right taper (Hz) ');
  fclose(fid);

  fid = fopen('mechan.dat','w');
   fprintf(fid,'%s\r\n','Source size and mechanism (in free format)');
   fprintf(fid,'%s\r\n','   scalar moment (in Nm):');
   fprintf(fid,'%s\r\n',moment);
   fprintf(fid,'%s\r\n',' strike (in degrees)  dip (in degrees)  rake (in degrees); see Aki & Richards');
   fprintf(fid,'%s   %s   %s\r\n',strike, dip ,rake);
   fprintf(fid,'%s\r\n','  delay (in seconds); >0 is to the right');
   fprintf(fid,'%s\r\n',delay);
  fclose(fid);
else 
  fid = fopen('99.syn','w');
   fprintf(fid,'%s\n','''20040712''  5.2  7   ! date in apostrophes, magnitude and depth ... not needed here');
   fprintf(fid,'%s\n','46.31   13.61          ! epicentre lat and lon (degrees)   ... not needed here');
   fprintf(fid,'%s\n','00 00 00.0             ! origin time     ... not needed here');
   fprintf(fid,'%s\n','00 00 00.0             ! record start time (after alignment) ... not needed here');
   fprintf(fid,'%g    %s\n',tstep,'! time step (after resampling)');
   fprintf(fid,'%g   %g   %s\n',f1, f2 ,'! filter left taper (Hz) ');
   fprintf(fid,'%g   %g   %s\n',f3, f4 ,'! filter right taper (Hz) ');
  fclose(fid);

  fid = fopen('mechan.dat','w');
   fprintf(fid,'%s\n','Source size and mechanism (in free format)');
   fprintf(fid,'%s\n','   scalar moment (in Nm):');
   fprintf(fid,'%s\n',moment);
   fprintf(fid,'%s\n',' strike (in degrees)  dip (in degrees)  rake (in degrees); see Aki & Richards');
   fprintf(fid,'%s   %s   %s\n',strike, dip ,rake);
   fprintf(fid,'%s\n','  delay (in seconds); >0 is to the right');
   fprintf(fid,'%s\n',delay);
  fclose(fid);
end


%% copy source green files
% check that source no is not only 1 character
if length(num2str(source))==1
    sourcename=['0' num2str(source)];
else
    sourcename=num2str(source);
end
           if ispc
              grfile1=['..\green\gr' sourcename '.hea']
              grfile2=['..\green\gr' sourcename '.hes']
              copyfile(grfile1,'.')
              copyfile(grfile2,'.')
           else
              grfile1=['../green/gr' sourcename '.hea']
              grfile2=['../green/gr' sourcename '.hes']
              copyfile(grfile1,'.')
              copyfile(grfile2,'.')
           end

%% Prepare the batch file for forward simulation
%
   if ispc
            fid = fopen('run_synth.bat','w');
                 %   fprintf(fid,'%s\r\n','Echo off');
                    fprintf(fid,'%s\r\n','          ');
                    fprintf(fid,'%s\r\n','REM needs GRxx.HEA, GRxx.HES for selected source position xx');
                    fprintf(fid,'%s\r\n','REM needs ALLSTAT.DAT, MECHAN.DAT, 99.SYN');
                    fprintf(fid,'%s\r\n','REM syn_cor is with 50 sec shift, while syn_cor2 is without 50 sec');
                    
                    fprintf(fid,'%s\r\n','          ');

                    fprintf(fid,'%s\r\n',['copy gr' sourcename '.hea gr.hea']);
                    fprintf(fid,'%s\r\n',['copy gr' sourcename '.hes gr.hes']);
                    fprintf(fid,'%s\r\n','conshift.exe');
                    fprintf(fid,'%s\r\n','REM creates temporary file SXXXROW.DAT for each XXX station.');
                    fprintf(fid,'%s\r\n','          ');
% now loop over stations
                     for i=1:nostations
                         fprintf(fid,'%s\r\n','copy  99.syn i.dat');
                         fprintf(fid,'%s\r\n',['copy  s' char(stnames{i}) 'row.dat row.dat']);
                         fprintf(fid,'%s\r\n','syn_cor.exe');
                         fprintf(fid,'%s\r\n',['copy  outsei.dat  s' char(stnames{i}) '.dat']);
                      %   fprintf(fid,'%s\r\n',['del  s' char(stnames{1,1}(i,1)) 'row.dat']);
                         fprintf(fid,'%s\r\n','          ');
                     end
                     
                     fprintf(fid,'%s\r\n','REM ******************************************************');
                     fprintf(fid,'%s\r\n','REM ******************************************************');
                     fprintf(fid,'%s\r\n','REM ***  part for Velocity Sythetics Without Filter  *****');
                     fprintf(fid,'%s\r\n','REM ***  previous part is for Displacement and Filtered **');
                     fprintf(fid,'%s\r\n','REM ***  data produced here e.g. s(station)2.dat will be *');
                     fprintf(fid,'%s\r\n','REM ***  for frequencies up to green function calculation ');
                     fprintf(fid,'%s\r\n','REM ******************************************************');
                     fprintf(fid,'%s\r\n','REM ******************************************************');
                     fprintf(fid,'%s\r\n','          ');
                                         
                     for i=1:nostations
                         fprintf(fid,'%s\r\n','copy  99.syn i.dat');
                         fprintf(fid,'%s\r\n',['copy  s' char(stnames{i}) 'row.dat row.dat']);
                         fprintf(fid,'%s\r\n','syn_cor2.exe');
                         fprintf(fid,'%s\r\n',['copy  outsei.dat  s' char(stnames{i}) '2.dat']);
                         fprintf(fid,'%s\r\n',['del  s' char(stnames{i}) 'row.dat']);
                         fprintf(fid,'%s\r\n','          ');
                     end
                    
                     
                      fprintf(fid,'%s\r\n','          ');
                      fprintf(fid,'%s\r\n','del i.dat gr.hea gr.hes outsei.dat row.dat');
                      
                      
                 fclose(fid);
                 
                 
   else  % Linux
            fid = fopen('run_synth.sh','w');
                    fprintf(fid,'%s\n','#!/bin/bash');
                    fprintf(fid,'%s\n','             ');
                    fprintf(fid,'%s\n','echo needs GRxx.HEA, GRxx.HES for selected source position xx');
                    fprintf(fid,'%s\n','echo needs ALLSTAT.DAT, MECHAN.DAT, 99.SYN');
                    fprintf(fid,'%s\n','echo syn_cor is with 50 sec shift, while syn_cor2 is without 50 sec');
                    
                    fprintf(fid,'%s\n','          ');

                    fprintf(fid,'%s\n',['cp gr' sourcename '.hea gr.hea']);
                    fprintf(fid,'%s\n',['cp gr' sourcename '.hes gr.hes']);
                    fprintf(fid,'%s\n','conshift.exe');
                    fprintf(fid,'%s\n','echo creates temporary file SXXXROW.DAT for each XXX station.');
                    fprintf(fid,'%s\n','          ');
% now loop over stations
                     for i=1:nostations
                         fprintf(fid,'%s\n','cp  99.syn i.dat');
                         fprintf(fid,'%s\n',['cp  s' char(stnames{i}) 'row.dat row.dat']);
                         fprintf(fid,'%s\n','syn_cor.exe');         
                         fprintf(fid,'%s\n',['cp  outsei.dat  s' char(stnames{i}) '.dat']);
                      %   fprintf(fid,'%s\r\n',['del  s' char(stnames{1,1}(i,1)) 'row.dat']);
                         fprintf(fid,'%s\n','          ');
                     end
                     
                     fprintf(fid,'%s\n','echo ******************************************************');
                     fprintf(fid,'%s\n','echo ******************************************************');
                     fprintf(fid,'%s\n','echo ***  part for Velocity Sythetics Without Filter  *****');
                     fprintf(fid,'%s\n','echo ***  previous part is for Displacement and Filtered **');
                     fprintf(fid,'%s\n','echo ***  data produced here e.g. s(station)2.dat will be *');
                     fprintf(fid,'%s\n','echo ***  for frequencies up to green function calculation ');
                     fprintf(fid,'%s\n','echo ******************************************************');
                     fprintf(fid,'%s\n','echo ******************************************************');
                     fprintf(fid,'%s\n','          ');
                                         
                     for i=1:nostations
                         fprintf(fid,'%s\n','cp  99.syn i.dat');
                         fprintf(fid,'%s\n',['cp  s' char(stnames{i}) 'row.dat row.dat']);
                         fprintf(fid,'%s\n','syn_cor2.exe');
                         fprintf(fid,'%s\n',['cp  outsei.dat  s' char(stnames{i}) '2.dat']);
                         fprintf(fid,'%s\n',['rm  s' char(stnames{i}) 'row.dat']);
                         fprintf(fid,'%s\n','          ');
                     end
                    
                     
                      fprintf(fid,'%s\n','          ');
                      fprintf(fid,'%s\n','rm i.dat gr.hea gr.hes outsei.dat row.dat');
                      
                      
                 fclose(fid);
   end
                     
%%
cd ..

%%
% run the calculation
            button = questdlg('Run calculation ?',...
           'Forward simulation ','Yes','No','Yes');
       
        if strcmp(button,'Yes')
          cd synth
            disp('Calculating synthetic seismograms')
            
            if ispc
                system('run_synth.bat &');
            else
                disp('Linux ')
                !chmod +x run_synth.sh
                system(' gnome-terminal -e "bash -c ./run_synth.sh;bash" ')         
            end
            
          cd ..
          pwd
          
            set(handles.plot,'Enable','on')
            set(handles.plsynth,'Enable','on')
            set(handles.stationslistbox,'Enable','on')
            
       elseif strcmp(button,'No')
          disp('Canceled ')
       end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Prepare a settings files
pwd
% read settings

moment= get(handles.moment,'String');  
strike= get(handles.strike,'String');  
dip=get(handles.dip,'String');  
rake=get(handles.rake,'String'); 
% 
f1=get(handles.f1,'String');  
f2=get(handles.f2,'String');  
f3=get(handles.f3,'String');  
f4=get(handles.f4,'String');  
%
source=get(handles.source,'String'); 
%
delay=get(handles.delay,'String'); 
%
if get(handles.delta,'Value') == get(handles.delta,'Max')
    istype=1;  
    t0='0';
elseif get(handles.triangle,'Value') == get(handles.triangle,'Max')
    istype=2;
    t0 = get(handles.duration,'String');
else
    %%% case nothing is selected....!!
    errordlg('Please select type of time function','!! Error !!')
    return
end
%
normalized = get(handles.check1,'Value');
addvarred = get(handles.svarred,'Value');
uselimits=get(handles.uselimits,'Value');
ftime =  get(handles.ftime,'String');
totime = get(handles.totime,'String');
pbw = get(handles.bw,'Value');
%
% Write to file
if ispc
  fid = fopen('synth.isl','w');
   fprintf(fid,'%s\r\n',moment);
   fprintf(fid,'%s\r\n',strike);
   fprintf(fid,'%s\r\n',dip);
   fprintf(fid,'%s\r\n',rake);
   fprintf(fid,'%s\r\n',f1);
   fprintf(fid,'%s\r\n',f2);
   fprintf(fid,'%s\r\n',f3);
   fprintf(fid,'%s\r\n',f4);
   fprintf(fid,'%s\r\n',source);
   fprintf(fid,'%s\r\n',delay);
   fprintf(fid,'%u\r\n',istype);
   fprintf(fid,'%s\r\n',t0);
   if normalized == 1 
     fprintf(fid,'%s\r\n','1');
   else
     fprintf(fid,'%s\r\n','0');
   end
   if addvarred == 1 
     fprintf(fid,'%s\r\n','1');
   else
     fprintf(fid,'%s\r\n','0');
   end
   if uselimits == 1 
     fprintf(fid,'%s\r\n','1');
   else
     fprintf(fid,'%s\r\n','0');
   end
   if pbw == 1 
     fprintf(fid,'%s\r\n','1');
   else
     fprintf(fid,'%s\r\n','0');
   end
   
   fprintf(fid,'%s\r\n',ftime);
   fprintf(fid,'%s\r\n',totime);
   
   fclose(fid);
else
  fid = fopen('event.isl','w');
   fprintf(fid,'%s\n',moment);
   fprintf(fid,'%s\n',strike);
   fprintf(fid,'%s\n',dip);
   fprintf(fid,'%s\n',rake);
   fprintf(fid,'%s\n',f1);
   fprintf(fid,'%s\n',f2);
   fprintf(fid,'%s\n',f3);
   fprintf(fid,'%s\n',f4);
   fprintf(fid,'%s\n',source);
   fprintf(fid,'%s\n',delay);
   fprintf(fid,'%u\n',istype);
   fprintf(fid,'%s\n',t0);
   if normalized == 1 
     fprintf(fid,'%s\n','1');
   else
     fprintf(fid,'%s\n','0');
   end
   if addvarred == 1 
     fprintf(fid,'%s\n','1');
   else
     fprintf(fid,'%s\n','0');
   end
   if uselimits == 1 
     fprintf(fid,'%s\n','1');
   else
     fprintf(fid,'%s\n','0');
   end
   if pbw == 1 
     fprintf(fid,'%s\n','1');
   else
     fprintf(fid,'%s\n','0');
   end
   
   fprintf(fid,'%s\n',ftime);
   fprintf(fid,'%s\n',totime);

  fclose(fid);
end

%%

delete(handles.create_synth)



function strike_Callback(hObject, eventdata, handles)
% hObject    handle to strike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike as text
%        str2double(get(hObject,'String')) returns contents of strike as a double


% --- Executes during object creation, after setting all properties.
function strike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip_Callback(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip as text
%        str2double(get(hObject,'String')) returns contents of dip as a double


% --- Executes during object creation, after setting all properties.
function dip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rake_Callback(hObject, eventdata, handles)
% hObject    handle to rake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake as text
%        str2double(get(hObject,'String')) returns contents of rake as a double


% --- Executes during object creation, after setting all properties.
function rake_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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



function f2_Callback(hObject, eventdata, handles)
% hObject    handle to f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f2 as text
%        str2double(get(hObject,'String')) returns contents of f2 as a double


% --- Executes during object creation, after setting all properties.
function f2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f3_Callback(hObject, eventdata, handles)
% hObject    handle to f3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f3 as text
%        str2double(get(hObject,'String')) returns contents of f3 as a double


% --- Executes during object creation, after setting all properties.
function f3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f3 (see GCBO)
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



function moment_Callback(hObject, eventdata, handles)
% hObject    handle to moment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of moment as text
%        str2double(get(hObject,'String')) returns contents of moment as a double


% --- Executes during object creation, after setting all properties.
function moment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to moment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function delay_Callback(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay as text
%        str2double(get(hObject,'String')) returns contents of delay as a double


% --- Executes during object creation, after setting all properties.
function delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function source_Callback(hObject, eventdata, handles)
% hObject    handle to source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of source as text
%        str2double(get(hObject,'String')) returns contents of source as a double


% --- Executes during object creation, after setting all properties.
function source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%inversion band
ifilter=handles.ifilter;
invband=[ num2str(ifilter(1,1)) '  '  num2str(ifilter(2,1))  '  '  num2str(ifilter(3,1))  '  '  num2str(ifilter(4,1)) ];
eventid='Forward simulation';%handles.eventid;
dtime=handles.tstep;

staname=handles.stnames; 
nostations=handles.nostations; 


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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(index_selected)==1   %%% plot ONE or ALL stations ONLY
    
    if index_selected == nostations+1                          %%%ALL
          disp('Plotting All Stations Real-Synthetic data in one Figure')
          plotallstations(nostations,staname,normalized,invband,ftime,totime,uselimits,dtime,eventid,addvarred,pbw)
    elseif index_selected ~= nostations+1                       %%% just one
          disp('Plotting ONLY One Station  Real-Synthetic  data in one Figure')
          stationname=char(staname{index_selected});
          plotonestation(stationname,normalized,ftime,totime,uselimits)
    end
      
elseif length(index_selected) ~=1   %%%Plot more than one and maybe ALL stations...
    
      for i=1:length(index_selected)
          
         if index_selected(i) ~= nostations+1
             disp('Plotting selected stations  Real-Synthetic  data ')
             stationname=char(staname{index_selected(i)});
             plotonestation(stationname,normalized,ftime,totime,uselimits)
         elseif index_selected(i) == nostations+1
             disp('Plotting All Stations  Real-Synthetic  data in one Figure')
             plotallstations(nostations,staname,normalized,dtime,eventid)
         else
             disp('Error')
         end
          
      end
      
else
disp('Error')
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


% --- Executes on button press in bw.
function bw_Callback(hObject, eventdata, handles)
% hObject    handle to bw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bw



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





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% FUNCTIONS TO PLOT ALL STATIONS (REAL-SYNTHETIC) %%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%IN A NEW FIGURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotallstations(nostations,staname,normalized,invband,ftime,totime,uselimits,dtime,eventid,addvarred,pbw)
%%%%%prepare filenames  

if ispc
   for i=1:nostations
    realdatafilename{i}=['.\invert\' char(staname{i}) 'fil.dat'];
    syntdatafilename{i}=['.\synth\s' char(staname{i}) '.dat'];
   end
else
   for i=1:nostations
    realdatafilename{i}=['./invert/' char(staname{i}) 'fil.dat'];
    syntdatafilename{i}=['./synth/s' char(staname{i}) '.dat'];
   end
end

realdatafilename=realdatafilename';
syntdatafilename=syntdatafilename';

% whos staname realdatafilename syntdatafilename
    
%try    
%%%%%%%%%NOW WE KNOW FILENAMES AND WE CAN PLOT .....

%%%%%%%%%%%initialize data matrices
realdataall=zeros(8192,4,nostations);    %%%% 8192 points  fixed....
syntdataall=zeros(8192,4,nostations); 
maxmindataindex=zeros(1,2,nostations);
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

% whos realdata

realdataall(:,:,i)=realdata;
maxmindataindex(:,:,i)=findlimits4plot(realdata);    %%% find data limits for plotting  ... June 2010 
syntdataall(:,:,i)=syntdata;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ispc
  fid  = fopen('.\synth\allstat.dat','r');
else
  fid  = fopen('./synth/allstat.dat','r');
end

allstatfile = textscan(fid,'%s %u %u %u %u %f %f %f %f');
fclose(fid);

station=allstatfile{1,1}(:,1)
station2=allstatfile{1,6}(:,1)

useornot=allstatfile{1,2}(:,1);
nsw=allstatfile{1,3}(:,1);
eww=allstatfile{1,4}(:,1);
vew=allstatfile{1,5}(:,1);
%

for i=1:nostations    %%%%%%loop over stations
      if useornot(i) == 0
          compuse(1,i) = 0;
          compuse(2,i) = 0;
          compuse(3,i) = 0;
      elseif useornot(i) == 1
          if nsw(i) > 1 
             compuse(1,i) = 0;  
          else
             compuse(1,i) = 1;  
          end   

          if eww(i) > 1 
             compuse(2,i) = 0;  
          else
             compuse(2,i) = 1;  
          end   
          
          if vew(i) > 1 
             compuse(3,i) = 0;  
          else
             compuse(3,i) = 1;  
          end   
      end
end
%whos station useornot nsw eww vew
%%%% return to isola

%cd ..
     
%catch
%        helpdlg('Error in file plotting. Check if all files exist');
 %   cd ..
%end
   

%%%%%%%%%%%%new code to compute varred per comp
k=0;
disp('Variance Reduction per component')
fprintf(1,'%s \t\t %s \t\t %s \t\t %s\n', 'Station','NS','EW','Z')

for i=1:nostations    %%%%%%loop over stations
  
     for j=1:3                %%%%%%%%loop over components
%          disp(componentname{j})
         
         variance_reduction(i,j)= vared(realdataall(:,j+1,i),syntdataall(:,j+1,i),dtime);
     
     end   
     
fprintf(1, '\t%s \t\t %4.2f \t\t %4.2f \t\t %4.2f\n', char(staname{i}), variance_reduction(i,1),variance_reduction(i,2),variance_reduction(i,3))
     
end                   

% whos variance_reduction staname
% staname
%%%%%%%%%%%%%%%%%%% normalize 23/06/05

if normalized == 1

    disp('Normalized plot')

    for i=1:nostations
        for j=2:4

             maxreal(i,j)=max(abs(realdataall(:,j,i)));
             maxsynt(i,j)=max(abs(syntdataall(:,j,i)));

%                     maxstring=[   num2str(maxreal(i,j)) '  '  staname{i} ];
%                     disp(maxstring)
% 
             
             realdataall(:,j,i) = realdataall(:,j,i)/max(abs(realdataall(:,j,i)));
             syntdataall(:,j,i) = syntdataall(:,j,i)/max(abs(syntdataall(:,j,i)));
             
%              max(abs(realdataall(:,j,i)))
%              max(abs(syntdataall(:,j,i)))
%              
             
         end
    end
    
    
else
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


mh = uimenu(fh,'Label','Export Figure');
eh1 = uimenu(mh,'Label','Convert to PNG','Callback','exportgraph(1)');
eh2 = uimenu(mh,'Label','Convert to PS','Callback','exportgraph(2)');
eh3 = uimenu(mh,'Label','Convert to EPS','Callback','exportgraph(3)');
eh4 = uimenu(mh,'Label','Convert to TIFF','Callback','exportgraph(4)');
eh5 = uimenu(mh,'Label','Convert to EMF','Callback','exportgraph(5)');
eh6 = uimenu(mh,'Label','Convert to JPG','Callback','exportgraph(6)');
eh7 = uimenu(mh,'Label','Prepare a GMT script','Callback','makegmtscript4synobsplot'); 

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Start making legend

%subplot(nostations+1,3,1)
%subplot(nostations+1,3,1)
subplot1(nostations+1,3)
subplot1(1)
title(['Even date-time: ' eventid],'FontSize',10,'FontWeight','bold')
axis off

%subplot1(nostations+1,3,2)
subplot1(2)
if pbw == 1
          plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
          hold on
          plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'k','Visible','off');      
          hold off
                   [legend_h,object_h,plot_h,text_strings]= legend('Observed','Synthetic',2);
                    set(legend_h,'FontSize',12)
                    set(object_h,'LineWidth',2)
                    set(plot_h(1),'LineWidth',1.5)
                    set(plot_h(2),'LineWidth',1)
                    title(['Displacement (m).  Inversion band (Hz)  ' invband],'FontSize',10,'FontWeight','bold')
axis off

else
          plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
          hold on
          plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'r','Visible','off');      
          hold off
                   [legend_h,object_h,plot_h,text_strings]= legend('Observed','Synthetic',2);
                    set(legend_h,'FontSize',12)
                    set(object_h,'LineWidth',2)
                    set(plot_h(1),'LineWidth',1.5)
                    set(plot_h(2),'LineWidth',1)
                    title(['Displacement (m).  Inversion band (Hz)  ' invband],'FontSize',10,'FontWeight','bold')
axis off
end

%subplot1(nostations+1,3,3)
subplot1(3)

          plot(realdataall(:,1,1),realdataall(:,1+1,1),'k','Visible','off');      
          hold on
          plot(syntdataall(:,1,1),syntdataall(:,1+1,1),'k','Visible','off');      
          hold off

          v=axis;
          
%text( v(1), 1,'Gray waveforms weren''t used in inversion.','Color','k','FontSize',8,'FontWeight','bold');
%text( v(3), 0.5, 'Blue numbers are variance reduction','Color','k','FontSize',8,'FontWeight','bold');

axis off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Finish with legend

k=0;
for i=1:nostations    %%%%%%loop over stations
%    realdataall    8192x4x6 
     for j=1:3                %%%%%%%%loop over components
       %   subplot1(nostations+1,3,j+k+3);
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
          ylabel(staname{i},...
              'FontSize',12,...
              'FontWeight','bold');
          end
          
%           if  j==2 
%           ylabel('Displacement')
%           end

%%%%%%%%%
%%%%%%%%%                Normalized plotting
%%%%%%%%%          
        if normalized == 1
            if uselimits == 1
                text( ftime,  1.1, num2str(maxreal(i,j+1),'%8.2E'),'HorizontalAlignment','left','FontSize',8,'FontWeight','bold');   %%% max values
                text( totime, 1.1, num2str(maxsynt(i,j+1),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');

               if addvarred == 1   %%%%%%%%%%  print variance                
%                  text( ftime+15, -.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,'FontWeight','bold');
                   text((totime-ftime)*0.05, -.65, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','left','FontSize',10,...
                      'FontWeight','bold','FontName','FixedWidth');  
               else
               end
%%%%%%%%%%%%%%%%               
            else  % not use limits
                text( min(realdataall(:,1,i)), 1.2, num2str(maxreal(i,j+1),'%8.2E'),'HorizontalAlignment','left','FontSize',8,'FontWeight','bold');  % max values
                text( max(realdataall(:,1,i)), 1.2, num2str(maxsynt(i,j+1),'%8.2E'),'Color','r','HorizontalAlignment','right','FontSize',8,'FontWeight','bold');

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
                    text((v(2)-v(1))*0.95 , v(4)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,...
                    'FontWeight','bold','FontName','FixedWidth');
                else
                    v=axis;
 %                  text(ftime+15 , v(3)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','right','FontSize',10,'FontWeight','bold');
%                    text((totime-ftime)*0.03 , v(3)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','left','FontSize',10,...
%                        'FontWeight','bold','FontName','FixedWidth');
                   text(((totime-ftime)*0.03)+ftime , v(3)/2, num2str(variance_reduction(i,j),'%4.2f'),'Color','b','HorizontalAlignment','left','FontSize',10,...
                       'FontWeight','bold','FontName','FixedWidth');
                end
            else
            end
        end    %%%end of Normalized  if

      end       %%%%%%%loop over components
      
       k=k+3;
       
end   %%%%%%%loop over stations

% 
% %%%%%%%%%%%%%%%%%%OUTPUT options in isl file
% 
% 
%     fid2 = fopen('waveplotoptions.isl','w');
%      if normalized == 1
%          fprintf(fid2,'%c\r\n','1');
%      else
%          fprintf(fid2,'%c\r\n','0');
%      end
%      
%      if uselimits == 1
%          fprintf(fid2,'%c\r\n','1');
%      else
%          fprintf(fid2,'%c\r\n','0');
%      end
%      
%      fprintf(fid2,'%f\r\n',ftime);
%      fprintf(fid2,'%f\r\n',totime);
%      
%      if addvarred == 1
%         fprintf(fid2,'%c\r\n','1');
%      else
%          fprintf(fid2,'%c\r\n','0');
%      end
%      
%      if pbw==1
%          fprintf(fid2,'%c\r\n','1');
%      else
%          fprintf(fid2,'%c\r\n','0');
%      end
%      
%     fclose(fid2);
% 
% 
%       cpng
%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%FUNCTION TO PLOT ONLY ONE STATION (REAL-SYNTHETIC) %%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%IN A NEW FIGURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
function plotonestation(stationname,normalized,ftime,totime,uselimits)

% %%%%prepare filenames  
% %% we keep fixed that data will be e.g. evrfil.dat
% %% and synthetics will be               evrsyn.dat
%stationname
if ispc
    realdatafilename=['.\invert\' stationname 'fil.dat'];
    syntdatafilename=['.\synth\s' stationname '.dat'];
else
    realdatafilename=['./invert/' stationname 'fil.dat'];
    syntdatafilename=['./synth/s' stationname '.dat'];
end
    
% %%%%%%%%%%initialize data matrices
realdata=zeros(8192,4);   
syntdata=zeros(8192,4); 

try
    
% open data files and read data
fid1  = fopen(realdatafilename,'r');
fid2  = fopen(syntdatafilename,'r');

        a=fscanf(fid1,'%f %f %f %f',[4 inf]);
        realdata=a';
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';

fclose(fid1);
fclose(fid2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


catch
  helpdlg('Error in file plotting. Check if all files exist');
end

% whos realdata
% realdata(1:10,2)
%%%%%%%%%%%%%%%%%%% normalize 23/06/05

if normalized == 1

    disp('Normalized plot')

    for i=2:4
        maxreal(i)=max(abs(realdata(:,i)));
        maxsynt(i)=max(abs(syntdata(:,i)));

        realdata(:,i) = realdata(:,i)/max(abs(realdata(:,i)));
        syntdata(:,i) = syntdata(:,i)/max(abs(syntdata(:,i)));
    
    end
    
else
end
%%%%%%%%%%%%%%%%%%% normalize

%%%%%%%%%PLOTTING   
componentname=cellstr(['NS';'EW';'Z ']);

figure

   for j=1:3                %%%%%%%%loop over components
         
          subplot(3,1,j);
         
          plot(realdata(:,1),realdata(:,j+1),'k');
          hold on
          
%%%%%%%           h = vline(50,'k');

          plot(syntdata(:,1),syntdata(:,j+1),'r');
          hold off
          
%           legend('Real','Synthetic',1); 
          ylabel('Displacement (m)')
        
          if  j==1 
          title(stationname,...
              'FontSize',12,...
              'FontWeight','bold');
          end
          
          if  j==3 
          xlabel('Time (Sec)')
          end
          
          %%%% Normalized plotting
           if normalized == 1
                text( 10, 0.7, num2str(maxreal(j+1)));
                text( 10, 0.5, num2str(maxsynt(j+1)),'Color','r');
                
                legend('Real','Synthetic',1); 
           else
               legend('Real','Synthetic',1); 
           end    
           
         %%%%%%%%%%%%%%%
           if uselimits == 1
                  if normalized == 1
%                     axis ([ftime totime min(realdataall(:,j+1,i)) max(realdataall(:,j+1,i)) ]) ;   
                      axis ([ftime totime -1.0 1.0 ]) ;       

                      text( totime-10  ,  -0.7   , componentname{j},'FontSize',12,'FontWeight','bold');
    
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

                      axis ([ftime totime yli1 yli2 ])
                      text( totime-10  ,   yli1+(yli2/3)      , componentname{j},'FontSize',12,'FontWeight','bold');

                 end
           else

             text( max(realdata(:,1)) - (max(realdata(:,1))*0.05)   ,  min(realdata(:,j+1)) - (min(realdata(:,j+1))*0.5)   , componentname{j},'FontSize',12,'FontWeight','bold');
             axis;
           end

         
         
     end   %%% main loop over components

%%     

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


%%
function flimits = findlimits4plotb(data)
%we expect data in form 8192x4 1st column time 2nd NS etc...

limits(1)=max(data(:,2));
limits(2)=max(data(:,3));
limits(3)=max(data(:,4));
limits(4)=min(data(:,2));
limits(5)=min(data(:,3));
limits(6)=min(data(:,4));

flimits(1)=max(limits);
flimits(2)=min(limits);
flimits(3)=flimits(1)+abs(flimits(2));


function duration_Callback(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of duration as text
%        str2double(get(hObject,'String')) returns contents of duration as a double


% --- Executes during object creation, after setting all properties.
function duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 


% --- Executes on button press in delta.
function delta_Callback(hObject, eventdata, handles)
% hObject    handle to delta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of delta

set(handles.triangle,'Value',0)

set(handles.duration,'Enable','Off')
set(handles.text22,'Enable','Off')

% --- Executes on button press in triangle.
function triangle_Callback(hObject, eventdata, handles)
% hObject    handle to triangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of triangle
set(handles.delta,'Value',0)

set(handles.duration,'Enable','On')
set(handles.text22,'Enable','On')


% --- Executes on button press in plsynth.
function plsynth_Callback(hObject, eventdata, handles)
% hObject    handle to plsynth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nostations=handles.nostations;
staname=handles.stnames;


uselimits=get(handles.uselimits,'Value');

ftime =  str2double(get(handles.ftime,'String'));
totime = str2double(get(handles.totime,'String'));

%%%%%%%%%%%%%FIND OUT USER SELECTION %%%%%%%%%%%%%%
%%%%%%%%%%% code based on Matlab example of list box....!!!

index_selected = get(handles.stationslistbox,'Value');

if length(index_selected)==1   %%% plot ONE or ALL stations ONLY
    
    if index_selected == nostations+1                          %%%ALL
          disp('Plotting All Stations Synthetic data in one Figure')
          plotallstationssyn(nostations,staname,uselimits,ftime,totime)
    elseif index_selected ~= nostations+1                       %%% just one
          disp('Plotting ONLY One Station Synthetic data in one Figure')
          stationname=staname{index_selected}
          plotonestationsyn(stationname,uselimits,ftime,totime)
    end
      
elseif length(index_selected) ~=1   %%%Plot more than one and maybe ALL stations...
    
      for i=1:length(index_selected)
          
         if index_selected(i) ~= nostations+1
             disp('Plotting selected stations Synthetic data ')
             stationname=staname{index_selected(i)}
             plotonestationsyn(stationname,uselimits,ftime,totime)
         elseif index_selected(i) == nostations+1
             disp('Plotting All Stations Synthetic data in one Figure')
             plotallstationssyn(nostations,staname,uselimits,ftime,totime)
         else
             disp('Error')
         end
          
      end
      
else
disp('Error')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% FUNCTION  TO PLOT ALL STATIONS (SYNTHETIC)%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% %%%%%%%%%%%%IN A NEW FIGURE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      

function plotallstationssyn(nostations,staname,uselimits,ftime,totime)
%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat
% ['.\synth\s' char(staname{i}) '.dat'];

for i=1:nostations
    syntdatafilename{i}=['s' staname{i} '.dat'];
end

syntdatafilename=syntdatafilename';

% whos staname syntdatafilename
        
%%%%%%%%%NOW WE KNOW FILENAMES AND WE CAN PLOT .....
%%%%%%%%%go in invert first
try
    
  cd synth
%%%%%%%%%%%initialize data matrices
syntdataall=zeros(8192,4); 
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
% scrsz = get(0,'ScreenSize');
% figure('Position',[100 100 scrsz(3)-200 scrsz(4)-200])

% h=figure
scrsz = get(0,'ScreenSize');

%fh=figure('Tag','Syn vs Obs','Position',[5 scrsz(4)*1/6 scrsz(3)*5/6 scrsz(4)*5/6-50], 'Name','Plotting Obs vs Syn');
fh=figure('Tag','Syn','Position',get(0,'Screensize'), 'Name','Plotting Syn');





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
          plot(syntdataall(:,1,i),syntdataall(:,j+1,i),'r','LineWidth',1);  
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

function plotonestationsyn(stationname,uselimits,ftime,totime)

%%%%%prepare filenames  
%%% we keep fixed that data will be e.g. evrfil.dat
%%% and synthetics will be               evrsyn.dat

    syntdatafilename=['s' stationname '.dat'];
 
%%%%%%%%%%%initialize data matrices
syntdata=zeros(8192,4); 

%%%go in invert
cd synth

%%%%open data files and read data
fid2  = fopen(syntdatafilename,'r');
        b=fscanf(fid2,'%f %f %f %f',[4 inf]);
        syntdata=b';
fclose(fid2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxmin_onedataindex=findlimits4plotb(syntdata); 

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
             
             text( totime-10  ,  maxmin_onedataindex(2)+maxmin_onedataindex(3)*0.2   , componentname{j},'FontSize',12,'FontWeight','bold');
          else
            v=axis; 
	        axis ([v(1) v(2) maxmin_onedataindex(2) maxmin_onedataindex(1) ])
            text( v(2)-(v(2)-v(1))*0.1  ,  maxmin_onedataindex(2)+maxmin_onedataindex(3)*0.2  , componentname{j},'FontSize',12,'FontWeight','bold');
         end
          
 end
