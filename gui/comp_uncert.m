function varargout = comp_uncert(varargin)
% COMP_UNCERT M-file for comp_uncert.fig
%      COMP_UNCERT, by itself, creates a new COMP_UNCERT or raises the
%      existing
%      singleton*.
%
%      H = COMP_UNCERT returns the handle to a new COMP_UNCERT or the handle to
%      the existing singleton*.
%
%      COMP_UNCERT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMP_UNCERT.M with the given input arguments.
%
%      COMP_UNCERT('Property','Value',...) creates a new COMP_UNCERT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before comp_uncert_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to comp_uncert_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help comp_uncert

% Last Modified by GUIDE v2.5 12-Sep-2013 21:55:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @comp_uncert_OpeningFcn, ...
                   'gui_OutputFcn',  @comp_uncert_OutputFcn, ...
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


% --- Executes just before comp_uncert is made visible.
function comp_uncert_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to comp_uncert (see VARARGIN)

% Choose default command line output for comp_uncert
handles.output = hObject;
%%
disp('This is comp_uncert.m')
disp('Added G computation. 05/06/2012 ')
disp('Changed layout, speed up nodal line plotting. 02/09/2013')


%%
%check if UNCERTAINTY exists..!
fh=exist('uncertainty','dir');

if (fh~=7);
    errordlg('Uncertainty folder doesn''t exist. ISOLA will create it. ','Folder warning');
    %delete(handles.comp_uncert)
    mkdir('uncertainty');
end

%check if INVERT exists..!
fh2=exist('invert','dir');

if (fh2~=7);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
   delete(handles.comp_uncert)
end
%

%check if INPINV.DAT exists..!
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
%check if allstat.dat exists..!
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

% check if we have stations.isl
     fh2=exist('stations.isl','file');
         if (fh2~=2);
           errordlg('stations.isl file doesn''t exist. Please select stations. ','File Error');
           delete(handles.create_synth)
          end

%% find how many green functions we have
% Start reading values we need
% 
% h=dir('tsources.isl');
% 
% if isempty(h); 
%     errordlg('tsources.isl file doesn''t exist. Run Source create. ','File Error');
%   return    
% else
%     
%     fid = fopen('tsources.isl','r');
%     tsource=fscanf(fid,'%s',1);
%     
%      if strcmp(tsource,'line')
%         disp('Inversion was done for a line of sources.')
%         nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
%         sdepth=fscanf(fid,'%f',1);
%         invtype=fscanf(fid,'%c');
%      elseif strcmp(tsource,'depth')
%         disp('Inversion was done for a line of sources under epicenter.')
%         nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
%         sdepth=fscanf(fid,'%f',1);
%         invtype=fscanf(fid,'%c');
%      elseif strcmp(tsource,'plane')
%         disp('Inversion was done for a plane of sources.')
%         nsources=fscanf(fid,'%i',1);
%         noSourcesstrike=fscanf(fid,'%i',1);
%         strikestep=fscanf(fid,'%f',1);
%         noSourcesdip=fscanf(fid,'%i',1);
%         dipstep=fscanf(fid,'%f',1);
%         invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
%      elseif strcmp(tsource,'point')
%         disp('Inversion was done for one source.')
%         nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
%         sdepth=fscanf(fid,'%f',1);
%         invtype=fscanf(fid,'%c');
%      end
%      
%    fclose(fid);
%           
% end
%%  check if we have all needed elemse* files in invert
if ispc
       elemfiles=dir('.\invert\elemse*.dat');
       noelemse=length(elemfiles);
else
       elemfiles=dir('./invert/elemse*.dat');
       noelemse=length(elemfiles);
end

%% read no of stations
          fid = fopen('stations.isl','r');
                 nstations=fscanf(fid,'%u',1);
          fclose(fid);
          disp(['stations.isl indicates ' num2str(nstations) '  stations.']);
%pwd
%%  
if ispc
         fid = fopen('.\invert\inpinv.dat','r');
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
            datavar=fscanf(fid,'%e',1);  %14
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
            datavar=fscanf(fid,'%e',1);  %14
       fclose(fid);
end


disp('  ');
disp(['Number of trial source positions in \invert\inpinv.dat is ' linetmp6]);
disp('  ');
disp(['Found ' num2str(noelemse) ' elementary seismogram files.'])
disp('  ');
disp(['Frequency Range in \invert\inpinv.dat is ' linetmp14]);
disp('  ');


if str2double(linetmp6) ~= noelemse
    errordlg(['You don''t have ' linetmp6 ' elementary seismogram files in invert folder. Define trial sources or prepare green function correctly.'],'File error')
else
end

% update the f1 f2 f3 f4 text boxes
freqrange = sscanf(linetmp14,'%f %f %f %f');   

set(handles.f1,'String',freqrange(1));
set(handles.f2,'String',freqrange(2));
set(handles.f3,'String',freqrange(3));
set(handles.f4,'String',freqrange(4));

%% here we read allstat.dat
if ispc
    fid = fopen('.\invert\allstat.dat','r');
        allstat_info = textscan(fid, '%s %f %f %f %f %f %f %f %f');
    fclose(fid);
else
    fid = fopen('./invert/allstat.dat','r');
        allstat_info = textscan(fid, '%s %f %f %f %f %f %f %f %f');
    fclose(fid);
end
%%
if ispc
  h=dir('.\invert\inv2.dat');

%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
 if isempty(h); 
    errordlg('inv2.dat file doesn''t exist. Run Invert. ','File Error');
    %cd ..
  return    
 else
    fid = fopen('.\invert\inv2.dat','r');
    tline = fgetl(fid);
      if length(tline) > 125
          disp('New inv2.dat')
          inv2age='new';
          fclose(fid);
          fid = fopen('.\invert\inv2.dat','r');
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('.\invert\inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
          fclose(fid);
      else
          disp('Old inv2.dat')
          inv2age='old';
          fclose(fid);
          fid = fopen('.\invert\inv2.dat','r');
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,dc,varred] = textread('.\invert\inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
          fclose(fid);
      end
 end      

else %not PC

  h=dir('./invert/inv2.dat');

%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
 if isempty(h); 
    errordlg('inv2.dat file doesn''t exist. Run Invert. ','File Error');
    %cd ..
  return    
 else
    fid = fopen('./invert/inv2.dat','r');
    tline = fgetl(fid);
      if length(tline) > 125
          disp('New inv2.dat')
          inv2age='new';
          fclose(fid);
          fid = fopen('./invert/inv2.dat','r');
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('./invert/inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
          fclose(fid);
      else
          disp('Old inv2.dat')
          inv2age='old';
          fclose(fid);
          fid = fopen('./invert/inv2.dat','r');
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,dc,varred] = textread('./invert/inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
          fclose(fid);
      end
 end
 
end

%  make an array for sources
src=num2str([1:str2double(linetmp6)]');
set(handles.nosourcepopup,'String',src);
% set selected source as the one in inv2
% set(handles.sourceno,'String',num2str(srcpos2(1,1)));        

set(handles.strike,'String',num2str(str1(1,1)));        
set(handles.dip,'String',num2str(dip1(1,1)));        
set(handles.rake,'String',num2str(rake1(1,1)));        
set(handles.moment,'String',num2str(mo(1,1),'%3.1e'));        

% get value of peak displacement of the medium in response to a unit-moment source
%  dislocation (in the studied source-station conguration and frequency band),
% according to Zahradniki and Custodio 2012
% output of testunc.dat should be enabled in elemat2.inc
% 05/06/2012

% h=dir('.\invert\testunc.dat');
% 
% if isempty(h); 
%     errordlg('testunc.dat file doesn''t exist. Run Invert first and check if output of this file is enabled. ','File Error');
%    return    
% else
% % find absolute maximum per column
%     G=load('.\invert\testunc.dat');
%     B=max(abs(G(:,2))); 
%     C=max(abs(G(:,3))); 
%     D=max(abs(G(:,4))); 
% 
%     Gvalue=mean([B C D]);    
%     clear G
%     % delete file also..??
%     
% end
% 
% set(handles.Gvalue,'String',num2str(Gvalue,'%6.3e'));    

%% update handles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles.linetmp1=linetmp1;         %01 line
handles.linetmp2=linetmp2;         %01 line
handles.linetmp3=linetmp3;         %01 line
handles.linetmp4=linetmp4;         %01 line
handles.linetmp5=linetmp5;         %01 line
handles.linetmp6=linetmp6;         %01 line
handles.linetmp7=linetmp7;         %01 line
handles.linetmp8=linetmp8;         %01 line
handles.linetmp9=linetmp9;         %01 line
handles.linetmp10=linetmp10;         %01 line
handles.linetmp11=linetmp11;         %01 line
handles.linetmp12=linetmp12;         %01 line
handles.linetmp13=linetmp13;         %01 line
handles.linetmp14=linetmp14;         %01 line
handles.linetmp15=linetmp15;         %01 line
handles.allstat_info=allstat_info;
handles.nstations=nstations;
handles.elemfiles=elemfiles;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes comp_uncert wait for user response (see UIRESUME)
% uiwait(handles.comp_uncert);

% set(handles.calc,'Enable','off')
% set(handles.plot,'Enable','off')



% --- Outputs from this function are returned to the command line.
function varargout = comp_uncert_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in calc.
function calc_Callback(hObject, eventdata, handles)
% hObject    handle to calc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nstations=handles.nstations;
elemfiles=handles.elemfiles;
notrialsources=str2double(handles.linetmp6);
allstat_info=handles.allstat_info;


%% run
%  first copy files we need
if ispc 
   [status,message,~]=copyfile('.\invert\elemse*.dat','.\uncertainty');
   if status==1
       disp('Elemse files copied in uncertainty folder succesfully.')
   else
       errordlg(['Problems with elemse file coping in uncertainty folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./invert/elemse*.dat','./uncertainty');
   if status==1
       disp('Elemse files copied in uncertainty folder succesfully.')
   else
       errordlg(['Problems with elemse file coping in uncertainty folder. Message is ' message])
   end
end
%% Check that we have the correct number of elemse files in uncertainty
% folder

if ispc
       elemfilesunc=dir('.\uncertainty\elemse*.dat');
else
       elemfilesunc=dir('./uncertainty/elemse*.dat');
end

if notrialsources~=length(elemfilesunc)
      errordlg(['You have specified ' num2str(notrialsources) ' trial sources and there are ' num2str(length(elemfilesunc)) '  elemse*.dat files in invert folder. Repeat the calculation.'])
else
end

%% copy allstat.dat
if ispc 
   [status,message,~]=copyfile('.\invert\allstat.dat','.\uncertainty');
   if status==1
       disp('Allstat.dat file copied in uncertainty folder succesfully.')
   else
       errordlg(['Problems with allstat.dat file coping in uncertainty folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./invert/allstat.dat','./uncertainty');
   if status==1
       disp('Allstat.dat file copied in uncertainty folder succesfully.')
   else
       errordlg(['Problems with allstat.dat file coping in uncertainty folder. Message is ' message])
   end
end
%% copy inpinv.dat
if ispc 
   [status,message,~]=copyfile('.\invert\inpinv.dat','.\uncertainty');
   if status==1
       disp('Inpinv.dat file copied in uncertainty folder succesfully.')
   else
       errordlg(['Problems with inpinv.dat file coping in uncertainty folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./invert/inpinv.dat','./uncertainty');
   if status==1
       disp('Inpinv.dat file copied in uncertainty folder succesfully.')
   else
       errordlg(['Problems with inpinv.dat file coping in uncertainty folder. Message is ' message])
   end
end
%%

% now we need to decide if this is prescribed or estimated data variance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check the radio buttons
if (get(handles.pdata,'Value') == get(handles.pdata,'Max'))
    % prescribed
    disp('User selected prescribed data variance option')
    % get the value
    dvariance = str2double(get(handles.userdatavariance,'String'));
    
    if  isnan(dvariance)
       disp('Data Variance is not defined. Select a proper value.')
       return
    else
    end

%% proceed with calculation
% GET in uncertainty folder

 cd uncertainty

    %% update inpinv.dat with data variance in GUI
    % and Freq range
     copyfile('inpinv.dat','inpinv.bak');
    
       linetmp1=handles.linetmp1;
       linetmp2=handles.linetmp2;
       linetmp3=handles.linetmp3;
       linetmp4=handles.linetmp4;
       linetmp5=handles.linetmp5;
       linetmp6=handles.linetmp6;
       linetmp7=handles.linetmp7;
       linetmp8=handles.linetmp8;
       linetmp9=handles.linetmp9;
       linetmp10=handles.linetmp10;
       linetmp11=handles.linetmp11;
       linetmp12=handles.linetmp12;
       linetmp13=handles.linetmp13;
       linetmp14=handles.linetmp14;
       linetmp15=handles.linetmp15;
    % read fi f2 f3 f4
       f1=get(handles.f1,'String');
       f2=get(handles.f2,'String');
       f3=get(handles.f3,'String');
       f4=get(handles.f4,'String');
   
    if ispc 
      fid = fopen('inpinv.dat','w');
          fprintf(fid,'%s\r\n',linetmp1);
          fprintf(fid,'%s\r\n',linetmp2);
          fprintf(fid,'%s\r\n',linetmp3);
          fprintf(fid,'%s\r\n',linetmp4);
          fprintf(fid,'%s\r\n',linetmp5);
          fprintf(fid,'%s\r\n',linetmp6);
          fprintf(fid,'%s\r\n',linetmp7);
          fprintf(fid,'%s\r\n',linetmp8);
          fprintf(fid,'%s\r\n',linetmp9);
          fprintf(fid,'%s\r\n',linetmp10);
          fprintf(fid,'%s\r\n',linetmp11);
          fprintf(fid,'%s\r\n',linetmp12);
          fprintf(fid,'%s\r\n',linetmp13);
          fprintf(fid,'%s %s %s %s\r\n', f1, f2, f3, f4);
          fprintf(fid,'%s\r\n',linetmp15);
          fprintf(fid,'%e\r\n',dvariance);
      fclose(fid);
    else
      fid = fopen('inpinv.dat','w');
          fprintf(fid,'%s\n',linetmp1);
          fprintf(fid,'%s\n',linetmp2);
          fprintf(fid,'%s\n',linetmp3);
          fprintf(fid,'%s\n',linetmp4);
          fprintf(fid,'%s\n',linetmp5);
          fprintf(fid,'%s\n',linetmp6);
          fprintf(fid,'%s\n',linetmp7);
          fprintf(fid,'%s\n',linetmp8);
          fprintf(fid,'%s\n',linetmp9);
          fprintf(fid,'%s\n',linetmp10);
          fprintf(fid,'%s\n',linetmp11);
          fprintf(fid,'%s\n',linetmp12);
          fprintf(fid,'%s\n',linetmp13);
          fprintf(fid,'%s %s %s %s\n', f1, f2, f3, f4);
          fprintf(fid,'%s\n',linetmp15);
          fprintf(fid,'%e\n',dvariance);
      fclose(fid);
    end
%%  here we must update the allstat.dat frq range also..!!
     copyfile('allstat.dat','allstat.bak');
     stnnames=allstat_info{1,1}; usest=cell2mat(allstat_info(1,2)); usens=cell2mat(allstat_info(1,3));useew=cell2mat(allstat_info(1,4));useve=cell2mat(allstat_info(1,5));

  if ispc   
    fid = fopen('allstat.dat','w');
     for i=1:nstations
      fprintf(fid,'%s   %u  %u  %u  %u  %s %s %s %s\r\n',char(stnnames(i)), usest(i), usens(i), useew(i), useve(i), f1, f2, f3, f4);
     end
    fclose(fid);
  else
    fid = fopen('allstat.dat','w');
     for i=1:nstations
      fprintf(fid,'%s   %u  %u  %u  %u  %s %s %s %s\n',char(stnnames(i)), usest(i), usens(i), useew(i), useve(i), f1, f2, f3, f4);
     end
    fclose(fid);
  end
 
%% prepare the acka_stara.dat file
          strike = str2double(get(handles.strike,'String'));
          dip = str2double(get(handles.dip,'String'));
          rake = str2double(get(handles.rake,'String'));
          xmoment = str2double(get(handles.moment,'String'));

          [a1,a2,a3,a4,a5,a6]=sdr2as(strike,dip,rake,xmoment);
 
    if ispc
        fid = fopen('acka_stara.dat','w');
            fprintf(fid,'%9.4e\r\n',a1);
            fprintf(fid,'%9.4e\r\n',a2);
            fprintf(fid,'%9.4e\r\n',a3);
            fprintf(fid,'%9.4e\r\n',a4);
            fprintf(fid,'%9.4e\r\n',a5);
            fprintf(fid,'%9.4e\r\n',a6);
        fclose(fid);
    else
        fid = fopen('acka_stara.dat','w');
            fprintf(fid,'%9.4e\n',a1);
            fprintf(fid,'%9.4e\n',a2);
            fprintf(fid,'%9.4e\n',a3);
            fprintf(fid,'%9.4e\n',a4);
            fprintf(fid,'%9.4e\n',a5);
            fprintf(fid,'%9.4e\n',a6);
        fclose(fid);
    end
%% Check is we have srcno.dat

     fh2=exist('srcno.dat','file');
     if (fh2~=2);
            errordlg('Uncertainty folder doesn''t contain srcno.dat. Please select a source first. ','File Error');
            cd ..
            return
     end

     nsource=load('srcno.dat');
     % check that srcno.dat has the same source as in nosourcepopup
     srcnumber = get(handles.nosourcepopup,'Value');

     if nsource~=srcnumber
         errordlg(['Source number in srcno.dat file (' num2str(nsource) ') not the same as in drop down list ('  num2str(srcnumber) '). Select a source again.'],'Error in Source Selection.')
         cd ..
         return
     else
     end

%% Give some info..!
disp('  ')
disp('  ')
disp('Parameters')
disp(['Source No :   ' num2str(nsource)])
disp(['Frequency Range :   ' num2str(f1) '-' num2str(f2) '-' num2str(f3) '-' num2str(f4) ])

disp('Strike     Dip    Rake')
disp(['  ' get(handles.strike,'String') '       '   get(handles.dip,'String') '     '  get(handles.rake,'String')])
% disp('C              G             Mo             Data Variance')
% disp([get(handles.Cvalue,'String') '          '  get(handles.Gvalue,'String') '      ' get(handles.moment,'String') '           '  get(handles.dvariance,'String')])

%% Create the batch file
if ispc
  fid = fopen('runvectors.bat','w');
   % run iso11b again with correct data variance...!!!
   fprintf(fid,'%s\r\n','rem input:  all elemse*.dat files, inpinv.dat and allstat.dat; no waveforms *.raw.dat are needed');
   fprintf(fid,'%s\r\n','rem CAUTION!!! Inpinv.dat must request FULL MT');
   fprintf(fid,'%s\r\n','iso12c.exe');
   fprintf(fid,'%s\r\n','rem output:  vect.dat, sing.dat');
   fprintf(fid,'%s\r\n','   ');
   fprintf(fid,'%s\r\n','rem input: vect.dat, sing.dat');
   fprintf(fid,'%s\r\n',' sigma5or6.exe');
   fprintf(fid,'%s\r\n','rem output: sigma.dat,sigma_short.dat');
   fprintf(fid,'%s\r\n','   ');
   fprintf(fid,'%s\r\n','rem input: sigma.dat and acka_stara.dat !!!!!!!!!!!!!!!!!!');
   fprintf(fid,'%s\r\n','  pokus5all_kag.exe');
   fprintf(fid,'%s\r\n','rem output: elipsa.dat, sit.dat; elipsa includes Kagan''s angle');
   fprintf(fid,'%s\r\n','   ');
   fprintf(fid,'%s\r\n','rem input: elipsa.dat');
   fprintf(fid,'%s\r\n','  analyze_kag.exe');
   fprintf(fid,'%s\r\n','rem output: elipsa_max.dat (vicinity of the ellipsoid surface),statistics.dat ');
  fclose(fid);

   system('runvectors.bat &');

cd ..  % go back to isola run folder

else
    
  fid = fopen('runvectors.sh','w');
  
   fprintf(fid,'%s\n','#!/bin/bash');
   fprintf(fid,'%s\n','             ');
   fprintf(fid,'%s\n','rem input:  all elemse*.dat files, inpinv.dat and allstat.dat; no waveforms *.raw.dat are needed');
   fprintf(fid,'%s\n','rem CAUTION!!! Inpinv.dat must request FULL MT');
   fprintf(fid,'%s\n','iso12c.exe');
   fprintf(fid,'%s\n','rem output:  vect.dat, sing.dat');
   fprintf(fid,'%s\n','   ');
   fprintf(fid,'%s\n','rem input: vect.dat, sing.dat');
   fprintf(fid,'%s\n',' sigma5or6.exe');
   fprintf(fid,'%s\n','rem output: sigma.dat,sigma_short.dat');
   fprintf(fid,'%s\n','   ');
   fprintf(fid,'%s\n','rem input: sigma.dat and acka_stara.dat !!!!!!!!!!!!!!!!!!');
   fprintf(fid,'%s\n','  pokus5all_kag.exe');
   fprintf(fid,'%s\n','rem output: elipsa.dat, sit.dat; elipsa includes Kagan''s angle');
   fprintf(fid,'%s\n','   ');
   fprintf(fid,'%s\n','rem input: elipsa.dat');
   fprintf(fid,'%s\n','  analyze_kag.exe');
   fprintf(fid,'%s\n','rem output: elipsa_max.dat (vicinity of the ellipsoid surface),statistics.dat ');
  fclose(fid);
    
    disp('Linux ')
   
    !chmod +x runvectors.sh
    system(' gnome-terminal -e "bash -c ./runvectors.sh;bash" ')

cd ..  % go back to isola run folder    

end % end of OS if
%
set(handles.plot,'Enable','On')



%%  Calculate data variance
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


elseif (get(handles.edata,'Value') == get(handles.edata,'Max'))
    % Estimated
    disp('User selected estimate data variance option')
    % proceed with calculation
    % read moment and Gvalue
    Mo = str2double(get(handles.moment,'String'))
    %G= str2double(get(handles.Gvalue,'String'))
    C= str2double(get(handles.Cvalue,'String'))

    if  isnan(Mo)
       errordlg('Mo is not defined. Select a proper value.')
       return
    else
    end
    
    if  isnan(C)
       errordlg('C is not defined. Select a proper value.')
       return
    else
    end

%%  start   
 
cd uncertainty  
    
   % find source number
   fh2=exist('srcno.dat','file');
    if (fh2~=2);
       errordlg('Uncertainty folder doesn''t contain srcno.dat. Please select a source first. ','File Error');
       cd ..
       return
    end

    nsource=load('srcno.dat');

%% update values in inpinv and allstat..!!
    %% update inpinv.dat with data variance in GUI
    % and Freq range
     copyfile('inpinv.dat','inpinv.bak');
    
       linetmp1=handles.linetmp1;
       linetmp2=handles.linetmp2;
       linetmp3=handles.linetmp3;
       linetmp4=handles.linetmp4;
       linetmp5=handles.linetmp5;
       linetmp6=handles.linetmp6;
       linetmp7=handles.linetmp7;
       linetmp8=handles.linetmp8;
       linetmp9=handles.linetmp9;
       linetmp10=handles.linetmp10;
       linetmp11=handles.linetmp11;
       linetmp12=handles.linetmp12;
       linetmp13=handles.linetmp13;
       linetmp14=handles.linetmp14;
       linetmp15=handles.linetmp15;
    % read fi f2 f3 f4
       f1=get(handles.f1,'String');
       f2=get(handles.f2,'String');
       f3=get(handles.f3,'String');
       f4=get(handles.f4,'String');
   
    if ispc 
      fid = fopen('inpinv.dat','w');
          fprintf(fid,'%s\r\n',linetmp1);
          fprintf(fid,'%s\r\n',linetmp2);
          fprintf(fid,'%s\r\n',linetmp3);
          fprintf(fid,'%s\r\n',linetmp4);
          fprintf(fid,'%s\r\n',linetmp5);
          fprintf(fid,'%s\r\n',linetmp6);
          fprintf(fid,'%s\r\n',linetmp7);
          fprintf(fid,'%s\r\n',linetmp8);
          fprintf(fid,'%s\r\n',linetmp9);
          fprintf(fid,'%s\r\n',linetmp10);
          fprintf(fid,'%s\r\n',linetmp11);
          fprintf(fid,'%s\r\n',linetmp12);
          fprintf(fid,'%s\r\n',linetmp13);
          fprintf(fid,'%s %s %s %s\r\n', f1, f2, f3, f4);
          fprintf(fid,'%s\r\n',linetmp15);
          fprintf(fid,'%e\r\n',1.e15);  % put something 
      fclose(fid);
    else
      fid = fopen('inpinv.dat','w');
          fprintf(fid,'%s\n',linetmp1);
          fprintf(fid,'%s\n',linetmp2);
          fprintf(fid,'%s\n',linetmp3);
          fprintf(fid,'%s\n',linetmp4);
          fprintf(fid,'%s\n',linetmp5);
          fprintf(fid,'%s\n',linetmp6);
          fprintf(fid,'%s\n',linetmp7);
          fprintf(fid,'%s\n',linetmp8);
          fprintf(fid,'%s\n',linetmp9);
          fprintf(fid,'%s\n',linetmp10);
          fprintf(fid,'%s\n',linetmp11);
          fprintf(fid,'%s\n',linetmp12);
          fprintf(fid,'%s\n',linetmp13);
          fprintf(fid,'%s %s %s %s\n', f1, f2, f3, f4);
          fprintf(fid,'%s\n',linetmp15);
          fprintf(fid,'%e\n',1.e15);  % put something 
      fclose(fid);
    end
%%  here we must update the allstat.dat frq range also..!!
     copyfile('allstat.dat','allstat.bak');
     stnnames=allstat_info{1,1}; usest=cell2mat(allstat_info(1,2)); usens=cell2mat(allstat_info(1,3));useew=cell2mat(allstat_info(1,4));useve=cell2mat(allstat_info(1,5));

  if ispc   
    fid = fopen('allstat.dat','w');
     for i=1:nstations
      fprintf(fid,'%s   %u  %u  %u  %u  %s %s %s %s\r\n',char(stnnames(i)), usest(i), usens(i), useew(i), useve(i), f1, f2, f3, f4);
     end
    fclose(fid);
  else
    fid = fopen('allstat.dat','w');
     for i=1:nstations
      fprintf(fid,'%s   %u  %u  %u  %u  %s %s %s %s\n',char(stnnames(i)), usest(i), usens(i), useew(i), useve(i), f1, f2, f3, f4);
     end
    fclose(fid);
  end
    
    
%% first find G
%  run iso12 

      disp('Calculating G ..... Running ')
         
           if ispc
             system('iso12c.exe  ') % return     
           else
             system(' gnome-terminal -e "bash -c iso12c.exe;bash" ')
           end
           
                  hpr = waitbar(0,'Please wait...');
                    program_done = 0;
                      while program_done == 0
                        pause(2); % pauses program 4 seconds before checking temp001.txt again
                        fid = fopen('temp001.txt','r');
                        program_done = fscanf(fid,'%d');
                        fclose(fid);
                        waitbar(0.5)
                      end   
                 close(hpr) 
                         disp('iso12c 1st run finished')
                         
             delete('temp001.txt');

             % now read testunc.dat
             
             h=dir('testunc.dat');
% 
               if isempty(h); 
                  errordlg('testunc.dat file doesn''t exist. Check if output of this file is enabled. ','File Error');
                  return    
               else
              % % find absolute maximum per column
                G=load('testunc.dat');
                B=max(abs(G(:,2))); 
                C2=max(abs(G(:,3))); 
                D=max(abs(G(:,4))); 
                Gvalue=mean([B C2 D]);    
               clear G
                  % delete file also..??
               end
%                set(handles.Gvalue,'String',num2str(Gvalue,'%6.3e'));    
pwd

%% we know G calculate data variance based on C

   dvariance=(C*Gvalue*Mo)^2;
  pause
% now we can do the calculation

% update inpinv.dat with CALCULATED data variance 
% and Freq range
     copyfile('inpinv.dat','inpinv.bak');
    
       linetmp1=handles.linetmp1;
       linetmp2=handles.linetmp2;
       linetmp3=handles.linetmp3;
       linetmp4=handles.linetmp4;
       linetmp5=handles.linetmp5;
       linetmp6=handles.linetmp6;
       linetmp7=handles.linetmp7;
       linetmp8=handles.linetmp8;
       linetmp9=handles.linetmp9;
       linetmp10=handles.linetmp10;
       linetmp11=handles.linetmp11;
       linetmp12=handles.linetmp12;
       linetmp13=handles.linetmp13;
       linetmp14=handles.linetmp14;
       linetmp15=handles.linetmp15;
    % read fi f2 f3 f4
       f1=get(handles.f1,'String');
       f2=get(handles.f2,'String');
       f3=get(handles.f3,'String');
       f4=get(handles.f4,'String');
   
    if ispc 
      fid = fopen('inpinv.dat','w');
          fprintf(fid,'%s\r\n',linetmp1);
          fprintf(fid,'%s\r\n',linetmp2);
          fprintf(fid,'%s\r\n',linetmp3);
          fprintf(fid,'%s\r\n',linetmp4);
          fprintf(fid,'%s\r\n',linetmp5);
          fprintf(fid,'%s\r\n',linetmp6);
          fprintf(fid,'%s\r\n',linetmp7);
          fprintf(fid,'%s\r\n',linetmp8);
          fprintf(fid,'%s\r\n',linetmp9);
          fprintf(fid,'%s\r\n',linetmp10);
          fprintf(fid,'%s\r\n',linetmp11);
          fprintf(fid,'%s\r\n',linetmp12);
          fprintf(fid,'%s\r\n',linetmp13);
          fprintf(fid,'%s %s %s %s\r\n', f1, f2, f3, f4);
          fprintf(fid,'%s\r\n',linetmp15);
          fprintf(fid,'%e\r\n',dvariance);
      fclose(fid);
    else
      fid = fopen('inpinv.dat','w');
          fprintf(fid,'%s\n',linetmp1);
          fprintf(fid,'%s\n',linetmp2);
          fprintf(fid,'%s\n',linetmp3);
          fprintf(fid,'%s\n',linetmp4);
          fprintf(fid,'%s\n',linetmp5);
          fprintf(fid,'%s\n',linetmp6);
          fprintf(fid,'%s\n',linetmp7);
          fprintf(fid,'%s\n',linetmp8);
          fprintf(fid,'%s\n',linetmp9);
          fprintf(fid,'%s\n',linetmp10);
          fprintf(fid,'%s\n',linetmp11);
          fprintf(fid,'%s\n',linetmp12);
          fprintf(fid,'%s\n',linetmp13);
          fprintf(fid,'%s %s %s %s\n', f1, f2, f3, f4);
          fprintf(fid,'%s\n',linetmp15);
          fprintf(fid,'%e\n',dvariance);
      fclose(fid);
    end
    
    
%%  here we must update the allstat.dat frq range also..!!
%      copyfile('allstat.dat','allstat.bak');
%      stnnames=allstat_info{1,1}; usest=cell2mat(allstat_info(1,2)); usens=cell2mat(allstat_info(1,3));useew=cell2mat(allstat_info(1,4));useve=cell2mat(allstat_info(1,5));
% 
%   if ispc   
%     fid = fopen('allstat.dat','w');
%      for i=1:nstations
%       fprintf(fid,'%s   %u  %u  %u  %u  %s %s %s %s\r\n',char(stnnames(i)), usest(i), usens(i), useew(i), useve(i), f1, f2, f3, f4);
%      end
%     fclose(fid);
%   else
%     fid = fopen('allstat.dat','w');
%      for i=1:nstations
%       fprintf(fid,'%s   %u  %u  %u  %u  %s %s %s %s\n',char(stnnames(i)), usest(i), usens(i), useew(i), useve(i), f1, f2, f3, f4);
%      end
%     fclose(fid);
%   end
     
%% prepare the acka_stara.dat file
          strike = str2double(get(handles.strike,'String'));
          dip = str2double(get(handles.dip,'String'));
          rake = str2double(get(handles.rake,'String'));
          xmoment = str2double(get(handles.moment,'String'));
          [a1,a2,a3,a4,a5,a6]=sdr2as(strike,dip,rake,xmoment);

    if ispc
        fid = fopen('acka_stara.dat','w');
            fprintf(fid,'%9.4e\r\n',a1);
            fprintf(fid,'%9.4e\r\n',a2);
            fprintf(fid,'%9.4e\r\n',a3);
            fprintf(fid,'%9.4e\r\n',a4);
            fprintf(fid,'%9.4e\r\n',a5);
            fprintf(fid,'%9.4e\r\n',a6);
        fclose(fid);
    else
        fid = fopen('acka_stara.dat','w');
            fprintf(fid,'%9.4e\n',a1);
            fprintf(fid,'%9.4e\n',a2);
            fprintf(fid,'%9.4e\n',a3);
            fprintf(fid,'%9.4e\n',a4);
            fprintf(fid,'%9.4e\n',a5);
            fprintf(fid,'%9.4e\n',a6);
        fclose(fid);
    end
       
%% Give some info..!
disp('Parameters')
disp(['Source No :   ' num2str(nsource)])
disp('Strike     Dip    Rake')
disp(['  ' get(handles.strike,'String') '       '   get(handles.dip,'String') '     '  get(handles.rake,'String')])
disp('C              G             Mo             Data Variance')
disp([num2str(C) '          '  num2str(Gvalue) '      ' num2str(Mo,'%6.3e') '           '  num2str(dvariance)])

%%
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fid = fopen('runvectors.bat','w');
% 
% % run iso11b again with correct data variance...!!!
% fprintf(fid,'%s\r\n','rem input:  all elemse*.dat files, inpinv.dat and allstat.dat; no waveforms *.raw.dat are needed');
% fprintf(fid,'%s\r\n','rem CAUTION!!! Inpinv.dat must request FULL MT');
% fprintf(fid,'%s\r\n','iso12c.exe');
% fprintf(fid,'%s\r\n','rem output:  vect.dat, sing.dat');
% 
% fprintf(fid,'%s\r\n','   ');
% 
% fprintf(fid,'%s\r\n','rem input: vect.dat, sing.dat');
% fprintf(fid,'%s\r\n',' sigma5or6.exe');
% fprintf(fid,'%s\r\n','rem output: sigma.dat,sigma_short.dat');
% fprintf(fid,'%s\r\n','   ');
% 
% fprintf(fid,'%s\r\n','rem input: sigma.dat and acka_stara.dat !!!!!!!!!!!!!!!!!!');
% fprintf(fid,'%s\r\n','  pokus5all_kag.exe');
% fprintf(fid,'%s\r\n','rem output: elipsa.dat, sit.dat; elipsa includes Kagan''s angle');
% fprintf(fid,'%s\r\n','   ');
% 
% fprintf(fid,'%s\r\n','rem input: elipsa.dat');
% fprintf(fid,'%s\r\n','  analyze_kag.exe');
% fprintf(fid,'%s\r\n','rem output: elipsa_max.dat (vicinity of the ellipsoid surface),statistics.dat ');
% 
% 
% fclose(fid);
% 
%    system('runvectors.bat &')
% 
% cd ..
% 
% set(handles.plot,'Enable','On')
%%     
%% Create the batch file
if ispc
  fid = fopen('runvectors.bat','w');
   % run iso11b again with correct data variance...!!!
   fprintf(fid,'%s\r\n','rem input:  all elemse*.dat files, inpinv.dat and allstat.dat; no waveforms *.raw.dat are needed');
   fprintf(fid,'%s\r\n','rem CAUTION!!! Inpinv.dat must request FULL MT');
   fprintf(fid,'%s\r\n','iso12c.exe');
   fprintf(fid,'%s\r\n','rem output:  vect.dat, sing.dat');
   fprintf(fid,'%s\r\n','   ');
   fprintf(fid,'%s\r\n','rem input: vect.dat, sing.dat');
   fprintf(fid,'%s\r\n',' sigma5or6.exe');
   fprintf(fid,'%s\r\n','rem output: sigma.dat,sigma_short.dat');
   fprintf(fid,'%s\r\n','   ');
   fprintf(fid,'%s\r\n','rem input: sigma.dat and acka_stara.dat !!!!!!!!!!!!!!!!!!');
   fprintf(fid,'%s\r\n','  pokus5all_kag.exe');
   fprintf(fid,'%s\r\n','rem output: elipsa.dat, sit.dat; elipsa includes Kagan''s angle');
   fprintf(fid,'%s\r\n','   ');
   fprintf(fid,'%s\r\n','rem input: elipsa.dat');
   fprintf(fid,'%s\r\n','  analyze_kag.exe');
   fprintf(fid,'%s\r\n','rem output: elipsa_max.dat (vicinity of the ellipsoid surface),statistics.dat ');
  fclose(fid);

   system('runvectors.bat &');

cd ..  % go back to isola run folder

else
    
  fid = fopen('runvectors.sh','w');
  
   fprintf(fid,'%s\n','#!/bin/bash');
   fprintf(fid,'%s\n','             ');
   fprintf(fid,'%s\n','rem input:  all elemse*.dat files, inpinv.dat and allstat.dat; no waveforms *.raw.dat are needed');
   fprintf(fid,'%s\n','rem CAUTION!!! Inpinv.dat must request FULL MT');
   fprintf(fid,'%s\n','iso12c.exe');
   fprintf(fid,'%s\n','rem output:  vect.dat, sing.dat');
   fprintf(fid,'%s\n','   ');
   fprintf(fid,'%s\n','rem input: vect.dat, sing.dat');
   fprintf(fid,'%s\n',' sigma5or6.exe');
   fprintf(fid,'%s\n','rem output: sigma.dat,sigma_short.dat');
   fprintf(fid,'%s\n','   ');
   fprintf(fid,'%s\n','rem input: sigma.dat and acka_stara.dat !!!!!!!!!!!!!!!!!!');
   fprintf(fid,'%s\n','  pokus5all_kag.exe');
   fprintf(fid,'%s\n','rem output: elipsa.dat, sit.dat; elipsa includes Kagan''s angle');
   fprintf(fid,'%s\n','   ');
   fprintf(fid,'%s\n','rem input: elipsa.dat');
   fprintf(fid,'%s\n','  analyze_kag.exe');
   fprintf(fid,'%s\n','rem output: elipsa_max.dat (vicinity of the ellipsoid surface),statistics.dat ');
  fclose(fid);
    
    disp('Linux ')
   
    !chmod +x runvectors.sh
    system(' gnome-terminal -e "bash -c ./runvectors.sh;bash" ')

cd ..  % go back to isola run folder    

end % end of OS if
%
set(handles.plot,'Enable','On')

else
    disp('Please select an option.')
    
end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% clean !!
%check if INVERT exists..!
% fh2=exist('invert','dir');
% 
% if (fh2~=7);
%delete(handles.comp_uncert)
% 
% end
% cd invert
% 
% delete('srcno.dat','temp001.txt','acka_stara.dat','vect.dat','testunc.dat' 'vect.dat')
% 


delete(handles.comp_uncert)

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



function moment_Callback(hObject, eventdata, handles)
% hObject    handle to moment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of moment as text
%        str2double(get(hObject,'String')) returns contents of moment as a double

% read moment and Gvalue
Mo = str2double(get(handles.moment,'String'));
G= str2double(get(handles.Gvalue,'String'));
C= str2double(get(handles.Cvalue,'String'));

datavariance=(C*G*Mo)^2;

% update handles
set(handles.dvariance,'String',num2str(datavariance, '%3.1e'));  









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


function [a1,a2,a3,a4,a5,a6]=sdr2as(strike,dip,rake,xmoment)

  %  strike=deg2rad(strike);
 %	dip=deg2rad(dip);
 %	rake=deg2rad(rake);
%     
%   
%     strike=strike*pi2/180.
%  	dip=dip*pi2/180.
%  	rake=rake*pi2/180.
    
 	sd=sind(dip);
 	cd=cosd(dip);
 	sp=sind(strike);
 	cp=cosd(strike);
 	sl=sind(rake);
 	cl=cosd(rake);
    
 	s2p=2.0*sp*cp;
 	s2d=2.0*sd*cd;
 	c2p=(cp*cp)-(sp*sp);
 	c2d=(cd*cd)-(sd*sd);
  
    if (abs(c2d)==(eps))
        c2d=0;
    end
    
    if (abs(c2p)==(eps))
        c2p=0;
    end
 
 	xx1 =-(sd*cl*s2p + s2d*sl*sp*sp)*xmoment;     % Mxx
 	xx2 = (sd*cl*c2p + s2d*sl*s2p/2.0)*xmoment;    % Mxy
 	xx3 =-(cd*cl*cp  + c2d*sl*sp)*xmoment;        % Mxz
 	xx4 = (sd*cl*s2p - s2d*sl*cp*cp)*xmoment;     % Myy
 	xx5 =-(cd*cl*sp  - c2d*sl*cp)*xmoment;        % Myz
 	xx6 =             (s2d*sl)*xmoment;           % Mzz

 	a1 = xx2;
 	a2 = xx3;
 	a3 =-xx5;
 	a4 = (-2.0*xx1 + xx4 + xx6)/3.0;
 	a5 = (xx1 -2.0*xx4 + xx6)/3.0;
    a6 = 0.0;
    
% disp(['Strike= ' num2str(strike) ' Dip= ' num2str(dip) ' Rake= ' num2str(rake) ' Moment= ' num2str(xmoment)])
% disp(['a1  ' '  a2  ' '  a3  ' '  a4  ' '  a5  ' '  a6  '])
% disp(a1);disp(a2);disp(a3);disp(a4);disp(a5);disp(a6)


% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% read strike dip rake

strike1 = str2double(get(handles.strike,'String'));
dip1 = str2double(get(handles.dip,'String'));
rake1 = str2double(get(handles.rake,'String'));

%%% call pl2pl to find second plane
[strike2,dip2,rake2] = pl2pl(strike1,dip1,rake1);

%%
cd uncertainty

load elipsa_max.dat

mm=mean(elipsa_max(:,11));
stdata=std(elipsa_max(:,11));
med=median(elipsa_max(:,11));

plotstruncert(elipsa_max,strike1,strike2);
plotdipuncert(elipsa_max,dip1,dip2);
plotrakeuncert(elipsa_max,rake1,rake2);

%plotalluncert(elipsa_max,strike1,strike2,dip1,dip2,rake1,rake2);
cd ..

% 
% figure
% %
% subplot(2,2,1)
% hist(elipsa_max(:,5),36);
% n=hist(elipsa_max(:,5),36);
% hold on
% x=[strike1 strike1];
% y=[0 max(n)];
% 
% line(x,y,'Color','r','LineWidth',4,'ButtonDownFcn', @startDragFcn1);
% h1strike=line(x,y,'Color','r','LineWidth',3,'LineStyle','--','ButtonDownFcn', @startDragFcn1);
% set(h1strike,'UserData', 0)
% 
% h1text=text(strike1+5,max(n),'\pm0\circ','FontSize',12);
% 
% title('Strike')
% h=axis;
% axis([h(1) 360 h(3) h(4)])
% %
% set(h1strike,'ButtonDownFcn',@button_down)
% 
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','w')
% 
% 
% subplot(2,2,2)
% hist(elipsa_max(:,6),18);
% n=hist(elipsa_max(:,6),18);
% hold on
% x=[dip1 dip1];
% y=[0 max(n)];
% line(x,y,'Color','r','LineWidth',4);
% x=[dip2 dip2];
% y=[0 max(n)];
% line(x,y,'Color','r','LineWidth',4);
% title('Dip')
% h=axis;
% axis([h(1) 90 h(3) h(4)])
% %
% subplot(2,2,3)
% hist(elipsa_max(:,7),36);
% n=hist(elipsa_max(:,7),36);
% hold on
% x=[rake1 rake1];
% y=[0 max(n)];
% line(x,y,'Color','r','LineWidth',4);
% x=[rake2 rake2];
% y=[0 max(n)];
% line(x,y,'Color','r','LineWidth',4);
% title('Rake')
% h=axis;
% axis([-180 180 h(3) h(4)])
% %
% subplot(2,2,4)
% hist(elipsa_max(:,2),50);
% title('Vol')
% h=axis;
% axis([-100 100 h(3) h(4)])

% %% plot nodal lines
% figure
% 
% Stereonet(0,90*pi/180,1000*pi/180,1);
% 
% str1=elipsa_max(:,5);
% dip1=elipsa_max(:,6);
% 
% str2=elipsa_max(:,8);
% dip2=elipsa_max(:,9);
% 
% 
% hold
%  for i=1:length(elipsa_max(:,5))
%      path = GreatCircle(deg2rad(str1(i)),deg2rad(dip1(i)),1);
%      plot(path(:,1),path(:,2),'r-')
% %      %Plot P axis (black, filled circle)
% %       [xp,yp] = StCoordLine(deg2rad(aziP(i)),deg2rad(plungeP(i)),1);
% %       plot(xp,yp,'ko','MarkerFaceColor','k');
% 
%      path = GreatCircle(deg2rad(str2(i)),deg2rad(dip2(i)),1);
%      plot(path(:,1),path(:,2),'r-')
%  
% %     %Plot T axis (black, filled circle)
% %       [xp,yp] = StCoordLine(deg2rad(aziT(i)),deg2rad(plungeT(i)),1);
% %       plot(xp,yp,'mo','MarkerFaceColor','m');
%  
%  end
%%
% 
% Polar plot
% figure
% [tout,rout]=rose(deg2rad(elipsa_max(:,5)),50); 
% polar(tout,rout);
% hold on
% 
% x=[deg2rad(strike1)  deg2rad(strike1)];
% y=[0  max(rout)];
% x2=[deg2rad(strike1+180)  deg2rad(strike1+180)];
% y2=[0  max(rout)];
% h1=polar(x,y,'--r');
% h2=polar(x2,y2,'--r');
% set(h1,'color','r','linewidth',2)
% set(h2,'color','r','linewidth',2)
% 
% x=[deg2rad(strike2)  deg2rad(strike2)];
% y=[0  max(rout)];
% x2=[deg2rad(strike2+180)  deg2rad(strike2+180)];
% y2=[0  max(rout)];
% h1=polar(x,y,'--r');
% h2=polar(x2,y2,'--r');
% set(h1,'color','r','linewidth',2)
% set(h2,'color','r','linewidth',2)
% 
% 
% set(gca,'View',[-90 90],'YDir','reverse');


% %%%%%%%%%%%%%%%%
% % calculate error based on half of distribution maximum
% % prepare a new function
% 
% 
% 
% 
% %%%%%%%%%%%%%%%%
% 
% 
% 
% % figure
% % rose(deg2rad(elipsa_max(:,5)),50);
% % hold on
% % hline=rose(deg2rad(strike1),1000)
% % set(hline,'Color','r','LineWidth',4);
% % hline=rose(deg2rad(strike2),1000)
% % set(hline,'Color','r','LineWidth',4);
% % hold off
% % set(gca,'View',[-90 90],'YDir','reverse');
% 
% % 
figure
% kagan
% subplot(1,2,1)
 hist(elipsa_max(:,11),10);
 title([ 'Kagan Angle, Mean= ' num2str(mm) '  Sd=  ' num2str(stdata) '  Median= ' num2str(med)])
% 
% %subplot(1,2,2)
% % for i=1:length(elipsa_max(:,5))
%      %function bb(fm, centerX, centerY, diam, ta, color)
% % bb([elipsa_max(i,5) elipsa_max(i,5) elipsa_max(i,5)], 1, 1, 10, 0,'w')
% %end
% 
% plotdcfps(elipsa_max(:,5),elipsa_max(:,6),elipsa_max(:,8),elipsa_max(:,9))
% 
% prepare a GMT plot for nodal lines
% probably the best way to plot BUT still too slow....

% cd invert
% 
% fid = fopen('pluncnod.bat','w');
% 
% fprintf(fid,'%s\r\n','del unmod.png');
% fprintf(fid,'%s\r\n','gawk "{print 10,10,10,$5,$6,$7,6}" elipsa_max.dat > unnod.dat');
% fprintf(fid,'%s\r\n','psmeca -R0/20/0/20 -JX15c unnod.dat   -Sa10c -T0 -K > unmod.ps');
% fprintf(fid,'%s\r\n','echo 1 1 12 0 1 1 test | pstext -R -J -O >> unmod.ps');
% fprintf(fid,'%s\r\n','ps2raster unmod.ps -P -Tg');
% fprintf(fid,'%s\r\n','del unnod.dat');
% 
% %%% run batch file...
% [s,r]=system('pluncnod.bat');
% 
% if s==0
%     A=imread('unmod.png','png');
%     image(A);
% %    axis square
% %    axis off
% else
%     disp('error')
%     disp(r)
% end
% % 
% cd .. 


%%% return to main folder before plotting.... this should solve problems if user tried to plot waveforms before closing ps file...
% 
% 
% system('gsview32 .\invert\unmod.ps');
% % % 




function sourceno_Callback(hObject, eventdata, handles)
% hObject    handle to sourceno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sourceno as text
%        str2double(get(hObject,'String')) returns contents of sourceno as a double


% --- Executes during object creation, after setting all properties.
function sourceno_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sourceno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dvariance_Callback(hObject, eventdata, handles)
% hObject    handle to text45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text45 as text
%        str2double(get(hObject,'String')) returns contents of text45 as a double


% --- Executes during object creation, after setting all properties.
function text45_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function dvariance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dvariance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Gvalue_Callback(hObject, eventdata, handles)
% hObject    handle to Gvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gvalue as text
%        str2double(get(hObject,'String')) returns contents of Gvalue as a double


% --- Executes during object creation, after setting all properties.
function Gvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cvalue_Callback(hObject, eventdata, handles)
% hObject    handle to Cvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cvalue as text
%        str2double(get(hObject,'String')) returns contents of Cvalue as a double

% update the data variance based on Gvalue and Moment

% % read moment and Gvalue
% Mo = str2double(get(handles.moment,'String'))
% G= str2double(get(handles.Gvalue,'String'))
% C= str2double(get(handles.Cvalue,'String'))
% 
% datavariance=(C*G*Mo)^2
% 
% % update handles
% set(handles.dvariance,'String',num2str(datavariance, '%3.1e'));  


% --- Executes during object creation, after setting all properties.
function Cvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in nosourcepopup.
function nosourcepopup_Callback(hObject, eventdata, handles)
% hObject    handle to nosourcepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns nosourcepopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from nosourcepopup

srcnumber = num2str(get(handles.nosourcepopup,'Value'));

if length(srcnumber) < 2
    srcnumber=['0' srcnumber];
end

% start calculations 
% prepare the srcno.dat needed for iso11b

if ispc 
    fid = fopen('.\uncertainty\srcno.dat','w');
       fprintf(fid,'%s\r\n',srcnumber);
    fclose(fid);
else
    fid = fopen('./uncertainty/srcno.dat','w');
       fprintf(fid,'%s\n',srcnumber);
    fclose(fid);
end

disp(['Selected source no ' srcnumber])


% --- Executes during object creation, after setting all properties.
function nosourcepopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nosourcepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


 %
function [strikb,dipb,rakeb] = pl2pl(strika,dipa,rakea)
%       based of fpspack....
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

         [anx,any,anz,dx,dy,dz]=pl2nd(strika,dipa,rakea);

%       if(ierr.ne.0) then
%          write(io,'(1x,a,i3)') 'PL2PL: ierr=',ierr
%          return
%       endif
      
%    call nd2pl(dx,dy,dz,anx,any,anz,,ierr)

[strikb,dipb,rakeb,dipdib]=nd2pl(dx,dy,dz,anx,any,anz);
      
      round(strikb);
      round(dipb);
      round(rakeb);
     
%       if(ierr.ne.0) then
%          ierr=8
%          write(io,'(1x,a,i3)') 'PL2PL: ierr=',ierr
%       endif
%       return
%       end
%[trendp,plungp,trendt,plungt,trendb,plungb]=pl2pt(strikb,dipb,rakeb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [anx,any,anz,dx,dy,dz] =pl2nd(strike,dip,rake)
%      
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;
%
      anx=c0;
      any=c0;
      anz=c0;
      dx=c0;
      dy=c0;
      dz=c0;
      ierr=0;
 
%       if(strike.lt.amistr.or.strike.gt.amastr) then
%          write(io,'(1x,a,g10.4,a)') 'PL2ND: input STRIKE angle ',strike,
%      1   ' out of range'
%          ierr=1
%       endif
%       if(dip.lt.amidip.or.dip.gt.amadip) then
%          if(dip.lt.amadip.and.dip.gt.-ovrtol) then
%             dip=amidip
%          else if(dip.gt.amidip.and.dip-amadip.lt.ovrtol) then
%             dip=amadip
%          else
%             write(io,'(1x,a,g10.4,a)') 'PL2ND: input DIP angle ',dip,
%      1      ' out of range'
%             ierr=ierr+2
%          endif
%       endif
%       if(rake.lt.amirak.or.rake.gt.amarak) then
%          write(io,'(1x,a,g10.4,a)') 'PL2ND: input RAKE angle ',rake,
%      1   ' out of range'
%          ierr=ierr+4
%       endif
%       if(ierr.ne.0) return
          
      wstrik=strike*dtor;
      wdip=dip*dtor;
      wrake=rake*dtor;
 
      anx=-sin(wdip)*sin(wstrik);
      any=sin(wdip)*cos(wstrik);
      anz=-cos(wdip);
      dx=cos(wrake)*cos(wstrik)+cos(wdip)*sin(wrake)*sin(wstrik);
      dy=cos(wrake)*sin(wstrik)-cos(wdip)*sin(wrake)*cos(wstrik);
      dz=-sin(wdip)*sin(wrake);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [phi,delta,alam,dipdir]=nd2pl(anx,any,anz,dx,dy,dz)
% subroutine nd2pl(wanx,wany,wanz,wdx,wdy,wdz,phi,delta,alam,dipdir
%  
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

     ang=fangle(anx,any,anz,dx,dy,dz);
      
      if (abs(ang-c90)> orttol)
         disp('ND2PL: input vectors not perpendicular, angle=')
     end
     
      [wanx,wany,wanz,anorm]= fnorm(anx,any,anz);
      
      [wdx,wdy,wdz,dnorm]=fnorm(dx,dy,dz);
           
      if(anz > c0) 
          
         [anx,any,anz]=finvert(anx,any,anz);
         [dx,dy,dz] =finvert(dx,dy,dz);
         
     end
 
      if(anz == -c1)
         wdelta=c0;
         wphi=c0;
         walam=atan2(-dy,dx);
      else
         wdelta=acos(-anz);
         wphi=atan2(-anx,any);
         walam=atan2(-dz/sin(wdelta),dx*cos(wphi)+dy*sin(wphi));
     end
     
     phi=wphi/dtor;
      delta=wdelta/dtor;
      alam=walam/dtor;
      phi=mod(phi+c360,c360);
      dipdir=phi+c90;
      dipdir=mod(dipdir+c360,c360);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [anorm,ax,ay,az]=fnorm(wax,way,waz)
%c
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

      anorm=sqrt(wax*wax+way*way+waz*waz);
      
      if(anorm == c0) return
      end
      ax=wax/anorm;
      ay=way/anorm;
      az=waz/anorm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ang = fangle(wax,way,waz,wbx,wby,wbz)
% c
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

%c
      [anorm,ax,ay,az]=fnorm(wax,way,waz);
      [bnorm,bx,by,bz]=fnorm(wbx,wby,wbz);
      prod=ax*bx+ay*by+az*bz;
      ang=acos(max(-c1,min(c1,prod)))/dtor;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function[iax,iay,iaz] = finvert(ax,ay,az)
% c
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;
%
      iax=-ax;
      iay=-ay;
      iaz=-az;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [trendp,plungp,trendt,plungt,trendb,plungb]=pl2pt(strike,dip,rake)
%  
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

%      call pl2nd(strike,dip,rake,anx,any,anz,dx,dy,dz,ierr)
      [anx,any,anz,dx,dy,dz]=pl2nd(strike,dip,rake);
%       if(ierr.ne.0) then
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%          return
%       endif
      
%   call nd2pt(dx,dy,dz,anx,any,anz,px,py,pz,tx,ty,tz,bx,by,bz,ierr)
      
      [px,py,pz,tx,ty,tz,bx,by,bz]=nd2pt(anx,any,anz,dx,dy,dz);

%       if(ierr.ne.0) then
%          ierr=8
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%       endif

%call ca2ax(px,py,pz,trendp,plungp,ierr)
[trendp,plungp]=ca2ax(px,py,pz);

% if(ierr.ne.0) then
%          ierr=9
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%       endif

  %    call ca2ax(tx,ty,tz,trendt,plungt,ierr)

[trendt,plungt]=ca2ax(tx,ty,tz);

%       if(ierr.ne.0) then
%          ierr=10
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%       endif
      
%call ca2ax(bx,by,bz,trendb,plungb,ierr)
[trendb,plungb]=ca2ax(bx,by,bz);

%       if(ierr.ne.0) then
%          ierr=11
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%       endif
%       return
%       end

      function [trend,plunge]=ca2ax(wax,way,waz)
% c     compute trend and plunge from Cartesian components
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

      ierr=0;
%      call norm(wax,way,waz,wnorm,ax,ay,az)
       [wnorm,ax,ay,az]=fnorm(wax,way,waz);
      if(az < c0) 
%      invert(ax,ay,az)
      [ax,ay,az]=finvert(ax,ay,az);
      end
%      
      if(ay ~= c0 || ax ~= c0) 
         trend=atan2(ay,ax)/dtor;
      else
         trend=c0;
     end
      trend=mod(trend+c360,c360);
      plunge=asin(az)/dtor;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [px,py,pz,tx,ty,tz,bx,by,bz]=nd2pt(wanx,wany,wanz,wdx,wdy,wdz)
% 
%   compute Cartesian component of P, T and B axes from outward normal and slip vectors
%      
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

      ierr=0;

   %   call norm(wanx,wany,wanz,amn,anx,any,anz)
        
      [amn,anx,any,anz]=fnorm(wanx,wany,wanz);
        
   %   call norm(wdx,wdy,wdz,amd,dx,dy,dz)
      
      [amd,dx,dy,dz]=fnorm(wdx,wdy,wdz);
      
     %call angle(anx,any,anz,dx,dy,dz,ang)
      ang=fangle(anx,any,anz,dx,dy,dz);
      
      
%       if(abs(ang-c90).gt.orttol) then
%          write(io,'(1x,a,g15.7,a)') 'ND2PT: input vectors not '
%      1   //'perpendicular, angle=',ang
%          ierr=1
%       endif

      px=anx-dx;
      py=any-dy;
      pz=anz-dz;

%      call norm(px,py,pz,amp,px,py,pz)
      
      [amp,px,py,pz]=fnorm(px,py,pz);
      
      
      if(pz < c0) 
      
%          call invert(px,py,pz)
        [px,py,pz]=finvert(px,py,pz);
        
      end
      
      tx=anx+dx;
      ty=any+dy;
      tz=anz+dz;
     
%      call norm(tx,ty,tz,amp,tx,ty,tz)
        
      [amp,tx,ty,tz]=fnorm(tx,ty,tz);
        
      
      if(tz < c0) 
         % call invert(tx,ty,tz)
          [tx,ty,tz]=finvert(tx,ty,tz);
      end
      
 %     call vecpro(px,py,pz,tx,ty,tz,bx,by,bz)
      [bx,by,bz]=vecpro(px,py,pz,tx,ty,tz);
      if(bz < c0) 
          
      %    call invert(bx,by,bz)
          [bx,by,bz]=finvert(bx,by,bz);
      
      end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bx,by,bz]=vecpro(px,py,pz,tx,ty,tz)
% c     compute vector products of two vectors
%   
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

      bx=py*tz-pz*ty;
      by=pz*tx-px*tz;
      bz=px*ty-py*tx;
      
      
      


% --- Executes on button press in plnodal.
function plnodal_Callback(hObject, eventdata, handles)
% hObject    handle to plnodal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
% cd invert
% 
%   load elipsa_max.dat
%     mm=mean(elipsa_max(:,11));
%     stdata=std(elipsa_max(:,11));
%     med=median(elipsa_max(:,11));
% 
% cd ..
%% check that elipsa_max exists
% and read values of str dip rake
if ispc
   h=dir('.\uncertainty\elipsa_max.dat');
else
   h=dir('./uncertainty/elipsa_max.dat');
end
   
if isempty(h); 
         errordlg('elipsa_max.dat file doesn''t exist in uncertainty folder. Run the calculation first. ','File Error');
     return
else
    disp('Found elipsa_max.dat')
end

%
if ispc
      fid = fopen('.\uncertainty\elipsa_max.dat','r');
        C = textscan(fid, '%*f %*f %*f %*f   %f %f %*f   %f %f %*f   %*f');
      fclose(fid);
else
      fid = fopen('./uncertainty/elipsa_max.dat','r');
        C = textscan(fid, '%*f %*f %*f %*f   %f %f %*f   %f %f %*f   %*f');
      fclose(fid);
end

str1=C{1};
dip1=C{2};
str2=C{3};
dip2=C{4};

%whos
str1=str1(1:2:end);
dip1=dip1(1:2:end);

str2=str2(1:2:end);
dip2=dip2(1:2:end);
%length(str1)
%whos
str1=str1(1:40:end);
dip1=dip1(1:40:end);
 
str2=str2(1:40:end);
dip2=dip2(1:40:end);
%
%% plot nodal lines
figure

Stereonet(0,90*pi/180,1000*pi/180,1);
v=axis;

xlim([v(1),v(2)]); ylim([v(3),v(4)]);  % static limits

%whos
hold
 
tic
 for i=1:length(str1)
     
     path = GreatCircle(deg2rad(str1(i)),deg2rad(dip1(i)),1);
     plot(path(:,1),path(:,2),'r-')

%      Plot P axis (black, filled circle)
%      [xp,yp] = StCoordLine(deg2rad(aziP(i)),deg2rad(plungeP(i)),1);
%      plot(xp,yp,'ko','MarkerFaceColor','k');

    path = GreatCircle(deg2rad(str2(i)),deg2rad(dip2(i)),1);
    plot(path(:,1),path(:,2),'r-')
 
%      Plot T axis (black, filled circle)
%      [xp,yp] = StCoordLine(deg2rad(aziT(i)),deg2rad(plungeT(i)),1);
%      plot(xp,yp,'mo','MarkerFaceColor','m');
 
 end

toc

choice = questdlg('Continue with plot in GMT ? (This could take a few minutes)', ...
 'GMT plotting of nodal lines', ...
 'Yes','No','No');
% Handle response
switch choice
    case 'Yes'
        disp('Plotting nodal lines using GMT. Using uncertainty folder.')
%%
% pause
cd uncertainty

figure

if ispc
    fid = fopen('pluncnod.bat','w');
     fprintf(fid,'%s\r\n','del unmod.png');
     fprintf(fid,'%s\r\n','gawk "{print 10,10,10,$5,$6,$7,6}" elipsa_max.dat > unnod.dat');
     fprintf(fid,'%s\r\n','psmeca -R0/20/0/20 -JX15c unnod.dat   -Sa10c -T0 -K > unmod.ps');
     fprintf(fid,'%s\r\n','echo 1 1 12 0 1 1 test | pstext -R -J -O >> unmod.ps');
     fprintf(fid,'%s\r\n','ps2raster unmod.ps -P -Tg');
     fprintf(fid,'%s\r\n','del unnod.dat');
    fclose(fid);
    %%% run batch file...
     [s,r]=system('pluncnod.bat');
     if s==0
       A=imread('unmod.png','png');
       image(A);
%    axis square
%    axis off
        disp('Postscript version is in uncertainty folder.')
     else
       disp('error')
       disp(r)
     end
else
    fid = fopen('pluncnod.bat','w');
     fprintf(fid,'%s\n','rm unmod.png');
     fprintf(fid,'%s\n','awk ''{print 10,10,10,$5,$6,$7,6}'' elipsa_max.dat > unnod.dat');
     fprintf(fid,'%s\n','psmeca -R0/20/0/20 -JX15c unnod.dat   -Sa10c -T0 -K > unmod.ps');
     fprintf(fid,'%s\n','echo 1 1 12 0 1 1 test | pstext -R -J -O >> unmod.ps');
     fprintf(fid,'%s\n','ps2raster unmod.ps -P -Tg');
     fprintf(fid,'%s\n','rm unnod.dat');
    fclose(fid);
    
      !chmod +x  pluncnod.bat
      [s,r]=system('./pluncnod.bat'); 
      
      if s==0
       A=imread('unmod.png','png');
       image(A);
%    axis square
%    axis off
        disp('Postscript version is in uncertainty folder.')
      else
       disp('error')
       disp(r)
     end
    
end
% 
cd .. 

% return to main folder before plotting.... this should solve problems if user tried to plot waveforms before closing ps file...
if ispc
system('gsview32 .\uncertainty\unmod.ps');
else
system('gv ./uncertainty/unmod.ps');
end
    
%%    
    case 'No'

        disp('Done')
end

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


% --- Executes on button press in pdata.
function pdata_Callback(hObject, eventdata, handles)
% hObject    handle to pdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pdata

if (get(handles.pdata,'Value') == get(handles.pdata,'Max'))
	% Radio button is selected-take appropriate action
    set(handles.edata,'Value',0)
%     set(handles.text9,'Enable','off')
%     set(handles.Cvalue,'Enable','off')
    set(handles.uipanel4,'Visible','off')
    set(handles.uipanel3,'Visible','on')
    set(handles.uipanel1,'Visible','on')
    
else
	% Radio button is not selected-take appropriate action
    set(handles.edata,'Value',1)  
    set(handles.uipanel3,'Visible','on')
end

% --- Executes on button press in edata.
function edata_Callback(hObject, eventdata, handles)
% hObject    handle to edata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edata
if (get(handles.edata,'Value') == get(handles.edata,'Max'))
	% Radio button is selected-take appropriate action
    set(handles.pdata,'Value',0)
    set(handles.uipanel3,'Visible','off')
    set(handles.uipanel4,'Visible','on')  
    set(handles.uipanel1,'Visible','on')

else
	% Radio button is not selected-take appropriate action
     %   set(handles.uipanel4,'Visible','on')
      set(handles.pdata,'Value',1)  
      set(handles.uipanel3,'Visible','on')
    
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
