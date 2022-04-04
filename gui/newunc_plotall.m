function varargout = newunc(varargin)
% NEWUNC M-file for newunc.fig
%      NEWUNC, by itself, creates a new NEWUNC or raises the existing
%      singleton*.
%
%      H = NEWUNC returns the handle to a new NEWUNC or the handle to
%      the existing singleton*.
%
%      NEWUNC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEWUNC.M with the given input arguments.
%
%      NEWUNC('Property','Value',...) creates a new NEWUNC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before newunc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to newunc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help newunc

% Last Modified by GUIDE v2.5 30-Jan-2017 20:13:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @newunc_OpeningFcn, ...
                   'gui_OutputFcn',  @newunc_OutputFcn, ...
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


% --- Executes just before newunc is made visible.
function newunc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to newunc (see VARARGIN)

% Choose default command line output for newunc
handles.output = hObject;

%%
disp('This is newunc.m')
disp('Version 0.5,  04/01/2017')

%%
[upperPath, deepestFolder, ~] = fileparts(pwd);

if strcmp(deepestFolder,'newunc')
    errordlg('It seems that the current folder in called newunc the code will not run in such a folder, move to run folder','Error');
    return
else
    
end

%%
%check if newunc exists..!
fh=exist('newunc','dir');

if (fh~=7);
    errordlg('newunc folder doesn''t exist. ISOLA will create it. ','Folder warning');
    %delete(handles.comp_uncert)
    mkdir('newunc');
end

%% check if INVERT exists..!
fh2=exist('invert','dir');

if (fh2~=7);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
   delete(handles.comp_uncert)
end

%% check if INPINV.DAT exists..!
if ispc 
        fh2=exist('.\invert\inpinv.dat','file'); 
         if (fh2~=2);
                  errordlg('Invert folder doesn''t contain inpinv.dat. Please run inversion. ','File Error');
                  delete(handles.create_synth)
         end
else
        fh2=exist('./invert/inpinv.dat','file'); 
         if (fh2~=2);
                  errordlg('Invert folder doesn''t contain inpinv.dat. Please run inversion. ','File Error');
                  delete(handles.create_synth)
         end
end

%% check if allstat.dat exists..!
if ispc 
       fh2=exist('.\invert\allstat.dat','file');
        if (fh2~=2);
                 errordlg('Invert folder doesn''t contain allstat.dat. Please run inversion. ','File Error');
                 delete(handles.create_synth)
        end
else
       fh2=exist('./invert/allstat.dat','file');
        if (fh2~=2);
                 errordlg('Invert folder doesn''t contain allstat.dat. Please run inversion. ','File Error');
                 delete(handles.create_synth)
        end
end

%% check if we have stations.isl
     fh2=exist('stations.isl','file');
         if (fh2~=2);
           errordlg('stations.isl file doesn''t exist. Please select stations. ','File Error');
           delete(handles.create_synth)
          end

%% read no of stations
          fid = fopen('stations.isl','r');
                 nstations=fscanf(fid,'%u',1);
          fclose(fid);
          disp(['stations.isl indicates ' num2str(nstations) '  stations.']);
%%  
if ispc
         fid = fopen('.\invert\inpinv.dat','r');
            linetmp1=fgetl(fid);         %01 line
            linetmp2=fgetl(fid)        %02 line
            linetmp3=fgetl(fid);          %03 line
            linetmp4=fgetl(fid);         %04 line
            linetmp5=fgetl(fid);          %05 line
            linetmp6=fgetl(fid);          %06 line
            linetmp7=fgetl(fid);          %07 line
            linetmp8=fgetl(fid);          %08 line
            linetmp9=fgetl(fid);          %09 line
            linetmp10=fgetl(fid);          %10 line
            linetmp11=fgetl(fid);          %11 line
            linetmp12=fgetl(fid);          %12 line
            linetmp13=fgetl(fid);           %13 line
            linetmp14=fgetl(fid);          %14 line
            linetmp15=fgetl(fid);         %15 line
            linetmp16=fgetl(fid);         %16 line
       fclose(fid);
else
         fid = fopen('./invert/inpinv.dat','r');
            linetmp1=fgetl(fid);         %01 line
            linetmp2=fgetl(fid);         %02 line
            linetmp3=fgetl(fid);          %03 line
            linetmp4=fgetl(fid);         %04 line
            linetmp5=fgetl(fid);          %05 line
            linetmp6=fgetl(fid);          %06 line
            linetmp7=fgetl(fid);          %07 line
            linetmp8=fgetl(fid);          %08 line
            linetmp9=fgetl(fid);          %09 line
            linetmp10=fgetl(fid);          %10 line
            linetmp11=fgetl(fid);          %11 line
            linetmp12=fgetl(fid);          %12 line
            linetmp13=fgetl(fid);           %13 line
            linetmp14=fgetl(fid);          %14 line
            linetmp15=fgetl(fid);         %15 line
            linetmp16=fgetl(fid);         %16 line
       fclose(fid);
end

%%
if str2num(linetmp2)==1
    set(handles.full,'Value',1)
    set(handles.dev ,'Value',0)
elseif str2num(linetmp2)==2
    set(handles.full,'Value',0)
    set(handles.dev ,'Value',1)
else
    set(handles.full,'Value',0)
    set(handles.dev ,'Value',1) 
end

 
%%

% check for inv4
if ispc 
       fh2=exist('.\invert\inv4.dat','file');
        if (fh2~=2);
                 errordlg('Invert folder doesn''t contain inv4.dat. Please run inversion. ','File Error');
                 delete(handles.create_synth)
        else
          fid = fopen('.\invert\inv4.dat','r');
            linetmp0=fgetl(fid);         %01 line
            A=sscanf(linetmp0,'%e %e  %e  %e  %e');
          fclose(fid);
            datavar=A(4);
        end
else
       fh2=exist('./invert/inv4.dat','file');
        if (fh2~=2);
                 errordlg('Invert folder doesn''t contain inv4.dat. Please run inversion. ','File Error');
                 delete(handles.create_synth)
        else
          fid = fopen('./invert/inv4.dat','r');
            linetmp0=fgetl(fid);         %01 line
            A=sscanf(linetmp0,'%e %e  %e  %e  %e');
          fclose(fid);
            datavar=A(4);
        end
end


% update handles
set(handles.userdatavariance,'String',datavar);  
set(handles.nsources,'String',linetmp6);  


disp('  ');
disp(['Number of trial source positions in \invert\inpinv.dat is ' linetmp6]);
disp('  ');
%disp(['Found ' num2str(noelemse) ' elementary seismogram files.'])
%disp('  ');
disp(['Frequency Range in \invert\inpinv.dat is ' linetmp14]);
disp('  ');


%%
 handles.linetmp1=linetmp1;         
 handles.linetmp2=linetmp2;        
 handles.linetmp3=linetmp3;        
 handles.linetmp4=linetmp4;          
 handles.linetmp5=linetmp5;        
 handles.linetmp6=linetmp6;          
 handles.linetmp7=linetmp7;         
 handles.linetmp8=linetmp8;        
 handles.linetmp9=linetmp9;          
 handles.linetmp10=linetmp10;         
 handles.linetmp11=linetmp11;         
 handles.linetmp12=linetmp12;         
 handles.linetmp13=linetmp13;         
 handles.linetmp14=linetmp14;         
 handles.linetmp15=linetmp15;          
 handles.datavar=datavar;             
 
% handles.allstat_info=allstat_info;
% handles.nstations=nstations;
% handles.elemfiles=elemfiles;
% 
% % Update handles structure
 guidata(hObject, handles);

% % UIWAIT makes newunc wait for user response (see UIRESUME)
% % uiwait(handles.new_unc);

% --- Outputs from this function are returned to the command line.
function varargout = newunc_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[upperPath, deepestFolder, ~] = fileparts(pwd);

if strcmp(deepestFolder,'newunc')
    errordlg('It seems that the current folder in called newunc the code will not run in such a folder, move to run folder','Error');
    return
else
end


delete(handles.new_unc)

function userdatavariance_Callback(hObject, eventdata, handles)
% hObject    handle to userdatavariance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of userdatavariance as text
%        str2double(get(hObject,'String')) returns contents of userdatavariance as a double


% --- Executes during object creation, after setting all properties.
function userdatavariance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to userdatavariance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calc.
function calc_Callback(hObject, eventdata, handles)
% hObject    handle to calc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[upperPath, deepestFolder, ~] = fileparts(pwd);

if strcmp(deepestFolder,'newunc')
    errordlg('It seems that the current folder in called newunc the code will not run in such a folder, move to run folder','Error');
    return
else
    
end

%% read nsources from handles
nsources=str2num(handles.linetmp6);   
disp(['Running with ' num2str(nsources) ' trial source positions.'])

% decide what user wants full or dev
      full=get(handles.full,'Value');
      if full == 1 
          stype=1; %full
      else
          stype=2; % dev
      end

%% check that all elemse exist in invert folder and copy to newunc
for i=1:nsources
   
   if ispc
      if i < 10
        elfile=['.\invert\elemse0' num2str(i) '.dat'];
      else
        elfile=['.\invert\elemse'  num2str(i) '.dat'];
      end  
   else
      if i < 10
        elfile=['./invert/elemse0' num2str(i) '.dat'];
      else
        elfile=['./invert/elemse'  num2str(i) '.dat'];
      end  
   end
   
   A= exist(elfile,'file');
   
   if A~= 0
          disp(['Found ' elfile])
           
          elfilecopy=strrep(elfile, '.\invert\', ''); 
          % copy the file to newunc folder
          [status,message,~]=copyfile(elfile,['.\newunc\' elfilecopy]);

          
   else
          errordlg(['You don''t have ' elfile ' elementary seismogram files in invert folder. Define trial sources or prepare green function correctly.'],'File error')
          
   end
       
end

%% check if we have raw files
disp(' ') 
disp(' ') 
disp('Checking raw data existance.') 
disp(' ') 

ok=check_raw_data ;

%% copy allstat.dat inpinv etc
disp(['Copying invert\allstat.dat to newunc folder.'])  
[status,message,~]=copyfile('.\invert\allstat.dat','.\newunc\allstat.dat');

disp(['Copying invert\inpinv.dat to newunc folder.'])  
[status,message,~]=copyfile('.\invert\inpinv.dat' ,'.\newunc\inpinv.dat');

%% we have raw and green, prepare loop over all trial sources
        % we update inpinv to have only one trial source
%         % keep a backup of current inpinv.dat in invert
%         disp('Copying .\invert\inpinv.dat to .\invert\inpinv_unc.bak')
%         [status,message,~]=copyfile('.\invert\inpinv.dat','.\invert\inpinv_unc.bak');

       % update it
          fid = fopen('.\newunc\inpinv.dat','w');
               fprintf(fid,'%s\r\n',handles.linetmp1);
               fprintf(fid,'%s\r\n',num2str(stype));
               fprintf(fid,'%s\r\n',handles.linetmp3);
               fprintf(fid,'%s\r\n',handles.linetmp4);
               fprintf(fid,'%s\r\n',handles.linetmp5);
               fprintf(fid,'%s\r\n','1');
               fprintf(fid,'%s\r\n',handles.linetmp7);
               fprintf(fid,'%s\r\n',handles.linetmp8);
               fprintf(fid,'%s\r\n',handles.linetmp9);
               fprintf(fid,'%s\r\n',handles.linetmp10);
               fprintf(fid,'%s\r\n',handles.linetmp11);
               fprintf(fid,'%s\r\n',handles.linetmp12);
               fprintf(fid,'%s\r\n',handles.linetmp13);
               fprintf(fid,'%s\r\n',handles.linetmp14);
               fprintf(fid,'%s\r\n',handles.linetmp15);
               %% check if we need fixed datavar
               %  checkvar=get(handles.usevar,'Value');
               %  if checkvar == 1
                var=str2double(get(handles.userdatavariance,'String'));
                fprintf(fid,'%e\r\n', var);
               %  else
               %      fprintf(fid,'%e\r\n', handles.datavar);
               %  end
                     
          fclose(fid);
%% backup on elemse01.dat also
        disp('Copying .\newunc\elemse01.dat to .\newunc\elemse01_save.dat')
        [status,message,~]=copyfile('.\newunc\elemse01.dat','.\newunc\elemse01_save.dat');
        
        
%% prepare a batch file to run isola15unc and norm
 fid = fopen('.\newunc\runisola15unc.bat','w');
     fprintf(fid,'%s\r\n','isola.exe');
     fprintf(fid,'%s\r\n','norm.exe');
 fclose(fid);

%%  proceed with loop
 cd .\newunc
    %    pwd
    h = waitbar(0,'Please wait...','Name','Calculating');
    
    for i=1:nsources
        % copy elemse* to elemse01.dat
        disp(['Copying .\newunc\elemse' num2str(i,'%02u') '.dat to .\newunc\elemse01.dat'])
        [status,message,~]=copyfile(['.\elemse' num2str(i,'%02u') '.dat'],'.\elemse01.dat');
         
        disp(['Running for source '  num2str(i) ])
        % run the batch file        
        [status , result] = system('runisola15unc.bat');
        waitbar(i/nsources,h,['Finished with source '  num2str(i)])
         
         
        if status == 0 
            % copy sigma.dat to newunc with a proper name
            [status,message,~]=movefile('.\sigma.dat',['.\sigma_src_' num2str(i,'%02u') '.dat']); 
            [status,message,~]=movefile('.\inv1.dat' ,['.\inv1_src_'  num2str(i,'%02u') '.dat']); 
            [status,message,~]=movefile('.\inv2.dat' ,['.\inv2_src_'  num2str(i,'%02u') '.dat']); 
            [status,message,~]=movefile('.\inv3.dat' ,['.\inv3_src_'  num2str(i,'%02u') '.dat']); 
            [status,message,~]=movefile('.\inv4.dat' ,['.\inv4_src_'  num2str(i,'%02u') '.dat']); 
        else
           errordlg('Error with isolaunc run. Please check files and installation','File Error')
        end
        
    end
    
 cd ..
 
%   pwd
% copy backup inpinv to original file
%        [status,message,~]=copyfile('.\newunc\inpinv_unc.bak','.\invert\inpinv.dat');
        [status,message,~]=copyfile('.\newunc\elemse01_save.dat','.\newunc\elemse01.dat');
close(h)

% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[upperPath, deepestFolder, ~] = fileparts(pwd);

if strcmp(deepestFolder,'newunc')
    errordlg('It seems that the current folder in called newunc the code will not run in such a folder, move to run folder','Error');
    return
else
    
end

%% read nsources from handles
nsources=str2num(handles.linetmp6);   
disp(['Running with ' num2str(nsources) ' trial source positions.'])

% decide what user wants full or dev
      full=get(handles.full,'Value');
      if full == 1 
          stype=1; %full
      else
          stype=2; % dev
      end
%% Run MVNRND per trial source (depth)
%try
    
 cd .\newunc

% del log file
fh2=exist('newunc_log.dat','file'); 
if (fh2==2);
   delete('newunc_log.dat');
end

% open log file
fid = fopen('newunc_log.dat','w');

fprintf(fid,'%s  %s  %s  %s  %s  %s \r\n', 'source', 'misfit', '       var', '    det(Cova)','Ni_eq6','no_of_rand_samples');


%% check if we need fixed datavar
% checkvar=get(handles.usevar,'Value');
% if checkvar == 1
%     var=str2double(get(handles.userdatavariance,'String'));
%     disp('Using fixed var') 
% else
% first get vardat  from inpinv.dat it will be the same for all
     [~,~,~,~,~,~,var] = readinpinv('inpinv.dat');
% end

%fixsamples=str2double(get(handles.fixsamples,'String'));

%%
% set 200 fixed samples per source

fix_samples=200;

%% find maximum Mo

mo=zeros(nsources,1);

for i=1:nsources
    inv1file =['inv1_src_'  num2str(i,'%02u') '.dat']; 
    [~,~,alphas,~,~,~,~,~,~,~,~,~,~]=readinv1new(inv1file,1,1); 
    mo(i)=inv1_mom;
end

norm_mo=max(mo);

disp(['Max Mo over all sources is ' num2str(max(mo))]);

n_exp=floor(log10(norm_mo));


%%
% preallocatte

eq6=zeros(nsources,1);
no_of_rand_samples=zeros(nsources,1);

for i=1:nsources
      % create the names of the files we need sigma, inv1 and inv4
      sigmafile=['sigma_src_' num2str(i,'%02u') '.dat'];
      inv4file =['inv4_src_'  num2str(i,'%02u') '.dat']; 
     % inv1file =['inv1_src_'  num2str(i,'%02u') '.dat']; 
      % 
      [sum_of_res2,~,~,~,~,~,~] = read_inv4(inv4file);

      % calculate misfit
      misfit=sum_of_res2/var;

      % read from files the parameters we need
      C = read_sigma(sigmafile,stype);
      
      % convert C from cell to double
      % add correction
      C_double=cell2mat(C);
      % check is we need to normalize
      % ncova=get(handles.ncova,'Value');
      
      % without normalization
      eq6(i)=sqrt(((2*pi)^6)*det(C_double))*exp(-0.5*misfit);
              
      %if ncova == 1
         %[~,~,~,~,inv1_mom,~,~,~,~,~,~,~]=readinv1new(inv1file,1,1); 
         %n_exp=floor(log10(inv1_mom));
         C_double=C_double./((10^n_exp)^2);
         disp(['Divide COVA matrix by ' num2str(((10^n_exp)^2),'%5.2e')]);
      %else
      %end
      % calculate number of random samples (for this trial source) based on Eq.6 of  Vackar et al 2016
      % Ni
      % check if user wants to fix it
%       checkfix=get(handles.fixsampleno,'Value');
%       if checkfix == 1
%         no_of_rand_samples(i)= fixsamples;
%       else
        no_of_rand_samples(i)=sqrt(((2*pi)^6)*det(C_double))*exp(-0.5*misfit);

%      end
disp([num2str(i) ' ' num2str(misfit) ' ' num2str(var) ' ' num2str(det(C_double)) ' ' num2str(no_of_rand_samples(i))])
      
      if no_of_rand_samples(i)==0
         errordlg(['Found Ni=0 for source ' num2str(i) '.Increase the requested number of total samples.'  ],'Error') 
         det(C_double)
      else
      end
      
      % clean 
      clear misfit  C_double sum_of_res2  
      
end

%% normalize Ni..?
        norm_Ni=max(no_of_rand_samples);
        ni_exp=abs(floor(log10(norm_Ni)));
        
        if ni_exp ~=0
            no_of_rand_samples=no_of_rand_samples./ni_exp;
        else
            disp('ni_exp =0. No normalization')
        end
        
%% loop for output
for i=1:nsources
      % create the names of the files we need sigma, inv1 and inv4
      sigmafile=['sigma_src_' num2str(i,'%02u') '.dat'];
      inv4file =['inv4_src_'  num2str(i,'%02u') '.dat']; 
    % inv1file =['inv1_src_'  num2str(i,'%02u') '.dat']; 
      % 
      [sum_of_res2,~,~,~,~,~,~] = read_inv4(inv4file);
      % calculate misfit
      misfit=sum_of_res2/var;
      % read from files the parameters we need
      C = read_sigma(sigmafile,stype);
      C_double=cell2mat(C);
      C_double=C_double./((10^n_exp)^2);
      % output to log file
      fprintf(fid,'%d  %e  %e  %e  %e  %e \r\n', i, misfit, var, det(C_double),eq6(i),no_of_rand_samples(i));
      % clean 
      clear misfit  C_double sum_of_res2  
end
        
%%    calculate sum of Ni
    sum_of_rand_samples=sum(no_of_rand_samples);

%%   check if sum==0 
     if sum(sum_of_rand_samples)==0
       errordlg('Error .. number of random samples is zero at all trial sources. Try another (10 times larger) value of Data Variance and repeat Calculate','Error') 
       return
     else
     end
     
%%    
total_r=[];
total_req6=[];

xbins=[-100   -80   -60   -40   -20     0    20    40    60    80   100];
dcbins=[0    10    20    30    40    50    60    70    80    90   100];
nsamples=str2double(get(handles.nsamples,'String'));

disp(' ')
disp(['Using ' num2str(nsamples) ' samples'])
disp(' ')

%%
for i=1:nsources
 
 % calculate new Ni  
  new_no_of_rand_samples= fix((no_of_rand_samples(i)/sum_of_rand_samples)*nsamples);
      
%  if new_no_of_rand_samples==0
%          errordlg(['Found newNi=0 for source ' num2str(i) '. Increase the requested number of total samples.'  ],'Error') 
%          fprintf(fid,'%d  %d  \r\n', i, new_no_of_rand_samples);
%          % put zero in all bins
%                  histfilename=['vol_histout_src' num2str(i,'%02u') '.dat'];
%                     z=zeros(11,1);
%                     fid22 = fopen(histfilename,'w');
%                         fprintf(fid22,'%f  %f \r\n',[z xbins']');
%                     fclose(fid22);
%  else  % non zero newNi continue..
     
    fprintf(fid,'%d  %d  \r\n', i, new_no_of_rand_samples);
    
    inv1file =['inv1_src_'  num2str(i,'%02u') '.dat']; sigmafile=['sigma_src_' num2str(i,'%02u') '.dat']; 
    C = read_sigma(sigmafile,stype);
    
      if stype==1 % full MT
%           if new_no_of_rand_samples==0
%              new_no_of_rand_samples=100; 
%           end
         % read a1-a6 
          [~,~,alphas,~,~,~,~,~,~,~,~,~,~]=readinv1new(inv1file,1,1);
          
          if alphas(6)==0
              warndlg('inv1 file doesn''t indicate a full mt run','!! Warning !!')
          else
          end
          %A=[alphas(1)*1e-20 alphas(2)*1e-20 alphas(3)*1e-20 alphas(4)*1e-20 alphas(5)*1e-20 alphas(6)*1e-20];
          A=[alphas(1) alphas(2) alphas(3) alphas(4) alphas(5) alphas(6)];
          sigma=cell2mat(C);
          
          r = mvnrnd(A,sigma,fix_samples);  %%% be careful here we use fixed=200 no of samples
         req6 = mvnrnd(A,sigma,new_no_of_rand_samples);  %%% get r using newNi
          
      %%  get str dip rake etc    
          [m,~]=size(r);
            for ii=1:m
                [str1(ii),dp1(ii),rk1(ii),str2(ii),dp2(ii),rk2(ii),adc_1(ii),adc_2(ii),avol_1(ii),avol_2(ii)] = silsubnew(r(ii,:));
            end
                %AA=[str1' dp1'  rk1'];BB=[str2' dp2'  rk2'];   elipsa_max=make_el_max(AA,BB);
                % plot histograms for strike dip rake
                % plotstruncert(elipsa_max,strike1,strike2); plotdipuncert(elipsa_max,dip1,dip2); plotrakeuncert(elipsa_max,rake1,rake2);
                % PLOTTING
                figure;  %DC_1
                subplot(1,3,1)
                %hist(elipsa_max(:,4),10);
                hist(adc_2,dcbins);title(['DC% for source ' num2str(i)],'FontSize',18);ax=gca;set(ax,'Linewidth',2,'FontSize',12);
                xlim([0,100]);
                    [n,xout] = hist(adc_2,dcbins);
                    histfilename=['histout_src' num2str(i,'%02u') '.dat'];
                    fid2 = fopen(histfilename,'w');
                        fprintf(fid2,'%f  %f \r\n',[n; xout]);
                    fclose(fid2);
                     
                %plotalluncert(elipsa_max,strike1,strike2,dip1,dip2,rake1,rake2);
                %figure;  %avol_1
                subplot(1,3,2)
                hist(avol_2,xbins);title(['VOL% for source ' num2str(i)],'FontSize',18);ax=gca;set(ax,'Linewidth',2,'FontSize',12);
                xlim([-100,100]);
                   [nv,vxout] = hist(avol_2,xbins);
                   
                    histfilename=['vol_histout_src' num2str(i,'%02u') '_CONST.dat'];
                    fid2 = fopen(histfilename,'w');
                        fprintf(fid2,'%f  %f \r\n',[nv; vxout]);
                    fclose(fid2);
                    
                    histfilename2=['vol_histout_src' num2str(i,'%02u') '.dat'];
                    fid2 = fopen(histfilename2,'w');
                        fprintf(fid2,'%f  %f \r\n',[nv*(new_no_of_rand_samples/fix_samples); vxout]);
                    fclose(fid2);                    
                    
           %  store in file 
           % prepare file per depth 
            depthfilename=['output_src' num2str(i,'%02u') '.dat'];
             fid2 = fopen(depthfilename,'w');
                 fprintf(fid2,'%e\r\n',avol_2);
             fclose(fid2);

             
             total_r=cat(1,total_r,r);
             total_req6=cat(1,total_req6,req6);
             
             
            %%%%%%%%%%%%%%%
            %figure;
            subplot(1,3,3)
            Stereonet(0,90*pi/180,1000*pi/180,1);
            %v=axis
            %xlim([v(1),v(2)]); ylim([v(3),v(4)]);  % static limits
            axis ([-1 1 -1 1]);
            hold on
            %axis on
             
            for iii=1:length(str1)
                path = GreatCircle(deg2rad(str1(iii)),deg2rad(dp1(iii)),1);
                plot(path(:,1),path(:,2),'r-')
                path = GreatCircle(deg2rad(str2(iii)),deg2rad(dp2(iii)),1);
                plot(path(:,1),path(:,2),'r-')
            end
             
            title(['Nodal line plot for source ' num2str(i)],'FontSize',18)
            hold off
            %%%%%%%%%%%%%%%%
              
        clear r req6 str1  dp1  rk1  str2  dp2  rk2  adc_1  adc_2  avol_1  avol_2  AA BB n xout nv vxout path 
      else  % deviatoric

%           if new_no_of_rand_samples==0
%              new_no_of_rand_samples=100; 
%           end
         % [a1,a2,a3,a4,a5,a6]=sdr2as(strike1,dip1,rake1,xmoment*1e-20);  % scaling of moment..! scaling is used by Jiri in fortran
          [~,~,alphas,~,~,~,~,~,~,~,~,~,~]=readinv1new(inv1file,1,1);
          % A=[a1 a2 a3 a4 a5];
          A=[alphas(1) alphas(2) alphas(3) alphas(4) alphas(5)];
          sigma=cell2mat(C);
          r = mvnrnd(A,sigma,new_no_of_rand_samples);
          r=[r zeros(new_no_of_rand_samples,1)];
       %%  get str dip rake etc  
            [m,~]=size(r);
            for ii=1:m
                [str1(ii),dp1(ii),rk1(ii),str2(ii),dp2(ii),rk2(ii),adc_1(ii),adc_2(ii),avol_1(ii),avol_2(ii)] = silsubnew(r(ii,:));
            end  
%                 AA=[str1' dp1'  rk1'];BB=[str2' dp2'  rk2'];
%                 elipsa_max=make_el_max(AA,BB);
                % plot histograms for strike dip rake
                % plotstruncert(elipsa_max,strike1,strike2); plotdipuncert(elipsa_max,dip1,dip2); plotrakeuncert(elipsa_max,rake1,rake2);
                % PLOTTING
                figure;  %DC_1
                subplot(1,2,1)
                %hist(elipsa_max(:,4),10);
                hist(adc_2,dcbins);title(['DC% for source ' num2str(i)],'FontSize',18);ax=gca;
                set(ax,'Linewidth',2,'FontSize',12);xlim([0,100]);
                
                    [n,xout] = hist(adc_2,dcbins);
                    histfilename=['histout_src' num2str(i,'%02u') '.dat'];
                    fid2 = fopen(histfilename,'w');
                        fprintf(fid2,'%f  %f \r\n',[n; xout]);
                    fclose(fid2);
                %plotalluncert(elipsa_max,strike1,strike2,dip1,dip2,rake1,rake2);
             depthfilename=['output_src' num2str(i,'%02u') '.dat'];
              
             fid2 = fopen(depthfilename,'w');
                 fprintf(fid2,'%e\r\n',adc_2);
             fclose(fid2);
          
             total_r=cat(1,total_r,r);
            %%%%%%%%%%%%%%%
                %figure;
                subplot(1,2,2)
                Stereonet(0,90*pi/180,1000*pi/180,1);
%                 v=axis;
%                 xlim([v(1),v(2)]); ylim([v(3),v(4)]);  % static limits
                axis ([-1 1 -1 1]);
                hold on
                 
                for iii=1:length(str1)
                    path = GreatCircle(deg2rad(str1(iii)),deg2rad(dp1(iii)),1);
                    plot(path(:,1),path(:,2),'r-')
                    path = GreatCircle(deg2rad(str2(iii)),deg2rad(dp2(iii)),1);
                    plot(path(:,1),path(:,2),'r-')
                end
                 
                title(['Nodal line plot for source ' num2str(i)],'FontSize',18)
                hold off
                
                %%%%%%%%%%%%%%%%
             clear r str1  dp1  rk1  str2  dp2  rk2  adc_1  adc_2  avol_1  avol_2  AA BB n xout path
          
      end % finish type if
        
% end % finish newNi==0 if
 
end % main loop over trial sources

fclose(fid);

%whos total_r
%% plot total 
            [m,~]=size(total_r);
            
            disp(['Total samples = ' num2str(m)])
            
            for ii=1:m
                [str1(ii),dp1(ii),rk1(ii),str2(ii),dp2(ii),rk2(ii),adc_1(ii),adc_2(ii),avol_1(ii),avol_2(ii)] = silsubnew(total_r(ii,:));
            end  
            
            if stype==1 % full MT
                
                figure; %DC_1
                subplot(1,3,1)
                hist(adc_2,dcbins);title('DC% all sources','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([0,100]);

                subplot(1,3,2)  %avol_1
                hist(avol_2,xbins);title('VOL% all sources ','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([-100,100]);
                
                subplot(1,3,3)% NODAL LINE PLOT
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on
                for i=1:length(str1)
                   path = GreatCircle(deg2rad(str1(i)),deg2rad(dp1(i)),1);plot(path(:,1),path(:,2),'r-')
                   path = GreatCircle(deg2rad(str2(i)),deg2rad(dp2(i)),1);plot(path(:,1),path(:,2),'r-')
                end
                title('Nodal plot','FontSize',14)
                hold off
                %% output
                fid2 = fopen('output_all.dat','w');
                 fprintf(fid2,'%f\r\n',avol_2);
                fclose(fid2);
                [n,xout] = hist(avol_2,xbins);
                fid2 = fopen('vol_histout_all.dat','w');
                 fprintf(fid2,'%f  %f \r\n',[n; xout]);
                fclose(fid2);
            else
                figure;  %DC_1
                subplot(1,2,1)
                %hist(elipsa_max(:,4),10);
                hist(adc_2,dcbins);title('DC% all sources','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([0,100]);
                % NODAL LINE PLOT
                subplot(1,2,2)
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on
                for i=1:length(str1)
                   path = GreatCircle(deg2rad(str1(i)),deg2rad(dp1(i)),1);plot(path(:,1),path(:,2),'r-')
                   path = GreatCircle(deg2rad(str2(i)),deg2rad(dp2(i)),1);plot(path(:,1),path(:,2),'r-')
                end
                title('Nodal plot','FontSize',14)
                hold off
            end
            
            clear str1 dp1 rk1 str2 dp2 rk2 adc_1 adc_2 avol_1 avol_2
%%
% eq6            
            [meq6,~]=size(total_req6);
            
            disp(['Total samples (based on eq6) = ' num2str(meq6)])
            
            for ii=1:meq6
                [str1(ii),dp1(ii),rk1(ii),str2(ii),dp2(ii),rk2(ii),adc_1(ii),adc_2(ii),avol_1(ii),avol_2(ii)] = silsubnew(total_req6(ii,:));
            end              
            
            if stype==1 % full MT
                
                figure; %DC_1
                subplot(1,3,1)
                hist(adc_2,dcbins);title('DC% all sources eq6','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([0,100]);

                subplot(1,3,2)  %avol_1
                hist(avol_2,xbins);title('VOL% all sources eq6','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([-100,100]);
                
                subplot(1,3,3)% NODAL LINE PLOT
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on
                for i=1:length(str1)
                   path = GreatCircle(deg2rad(str1(i)),deg2rad(dp1(i)),1);plot(path(:,1),path(:,2),'r-')
                   path = GreatCircle(deg2rad(str2(i)),deg2rad(dp2(i)),1);plot(path(:,1),path(:,2),'r-')
                end
                title('Nodal plot eq6','FontSize',14)
                hold off
                %% output
                fid2 = fopen('output_all_eq6.dat','w');
                 fprintf(fid2,'%f\r\n',avol_2);
                fclose(fid2);
                [n,xout] = hist(avol_2,xbins);
                fid2 = fopen('vol_histout_all_eq6.dat','w');
                 fprintf(fid2,'%f  %f \r\n',[n; xout]);
                fclose(fid2);
            else
                figure;  %DC_1
                subplot(1,2,1)
                %hist(elipsa_max(:,4),10);
                hist(adc_2,dcbins);title('DC% all sources','FontSize',14);
                ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([0,100]);
                % NODAL LINE PLOT
                subplot(1,2,2)
                Stereonet(0,90*pi/180,1000*pi/180,1);axis ([-1 1 -1 1]);
                hold on
                for i=1:length(str1)
                   path = GreatCircle(deg2rad(str1(i)),deg2rad(dp1(i)),1);plot(path(:,1),path(:,2),'r-')
                   path = GreatCircle(deg2rad(str2(i)),deg2rad(dp2(i)),1);plot(path(:,1),path(:,2),'r-')
                end
                title('Nodal plot','FontSize',14)
                hold off
            end            
            
            
            
cd ..
          
% catch
%     warndlg('It seems that code crashed. Please check your input values and run again.','Warning')
%     cd ..
% end
    
    
% --- Executes on button press in usevar.
function usevar_Callback(hObject, eventdata, handles)
% hObject    handle to usevar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of usevar



function nsamples_Callback(hObject, eventdata, handles)
% hObject    handle to nsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nsamples as text
%        str2double(get(hObject,'String')) returns contents of nsamples as a double


% --- Executes during object creation, after setting all properties.
function nsamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fixsamples_Callback(hObject, eventdata, handles)
% hObject    handle to fixsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fixsamples as text
%        str2double(get(hObject,'String')) returns contents of fixsamples as a double


% --- Executes during object creation, after setting all properties.
function fixsamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fixsamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fixsampleno.
function fixsampleno_Callback(hObject, eventdata, handles)
% hObject    handle to fixsampleno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fixsampleno


% --- Executes on button press in ncova.
function ncova_Callback(hObject, eventdata, handles)
% hObject    handle to ncova (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ncova


% --- Executes on button press in totalplot.
function totalplot_Callback(hObject, eventdata, handles)
% hObject    handle to totalplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[upperPath, deepestFolder, ~] = fileparts(pwd);

if strcmp(deepestFolder,'newunc')
    errordlg('It seems that the current folder in called newunc the code will not run in such a folder, move to run folder','Error');
    return
else
    
end

%% read nsources from handles
nsources=str2num(handles.linetmp6);   
disp(['Running with ' num2str(nsources) ' trial source positions.'])
%%
cd newunc
% plot total 
% fid=fopen('vol_histout_all.dat');
% C=textscan(fid,'%f %f');
% fclose(fid);
% 
% figure
% bar(C{2},C{1})
% ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([-100,100]);
% hold
% 
% for ii=1:nsources
%      
%     histfilename=['vol_histout_src' num2str(ii,'%02u') '.dat'];
%     
%      fid=fopen(histfilename);
%       C=textscan(fid,'%f %f');
%      fclose(fid);
%      
%      bar(C{2},C{1},'r')
%      
%      clear C 
% end

% plot total 
fid=fopen('vol_histout_all.dat');
C=textscan(fid,'%f %f');
fclose(fid);

figure
plot(C{2},C{1},'Linewidth',2,'Color', [0.5 0.5 0.5])
ax=gca;set(ax,'Linewidth',2,'FontSize',12);xlim([-100,100]);
xlabel('ISO%');ylabel('Frequency')
hold

for ii=1:nsources
       histfilename=['vol_histout_src' num2str(ii,'%02u') '.dat'];
     fid=fopen(histfilename);
      C=textscan(fid,'%f %f');
     fclose(fid);
     hits{ii}=C{1};
end
centers=C{2};
nofix=sum(cell2mat(hits),2);

plot(centers,nofix,'Linewidth',2,'Color', [1 0 0])

for ii=1:nsources
     
    histfilename=['vol_histout_src' num2str(ii,'%02u') '.dat'];
    
     fid=fopen(histfilename);
      C=textscan(fid,'%f %f');
     fclose(fid);
     
     plot(C{2},C{1},'r')
     
     clear C 
%  add plot from constant samples =200
    histfilename=['vol_histout_src' num2str(ii,'%02u') '_CONST.dat'];
    
     fid=fopen(histfilename);
      C=textscan(fid,'%f %f');
     fclose(fid);
     
     plot(C{2},C{1},'Color', [0.5 0.5 0.5])
     
     clear C 
     
end

cd ..
