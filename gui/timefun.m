function varargout = timefun(varargin)
% TIMEFUN M-file for timefun.fig
%      TIMEFUN, by itself, creates a new TIMEFUN or raises the existing
%      singleton*.
%
%      H = TIMEFUN returns the handle to a new TIMEFUN or the handle to
%      the existing singleton*.
%
%      TIMEFUN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIMEFUN.M with the given input arguments.
%
%      TIMEFUN('Property','Value',...) creates a new TIMEFUN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before timefun_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to timefun_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help timefun

% Last Modified by GUIDE v2.5 26-Aug-2013 14:44:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @timefun_OpeningFcn, ...
                   'gui_OutputFcn',  @timefun_OutputFcn, ...
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


% --- Executes just before timefun is made visible.
function timefun_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to timefun (see VARARGIN)

% Choose default command line output for timefun
handles.output = hObject;
%%
disp('This is timefun.m')
disp('Ver.1, 12/07/2012')
% Update handles structure
guidata(hObject, handles);
%%
%check if timefun folder exists..!
fh=exist('timefunc','dir');

if (fh~=7);
    errordlg('Timefunc folder doesn''t exist. ISOLA will create it. ','Folder warning');
    mkdir('timefunc');
end

%check if GREEN exists..!
fh2=exist('green','dir');

if (fh2~=7);
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
end

%check if INVERT exists..!
fh2=exist('invert','dir');

if (fh2~=7);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
end
%
%check if INPINV.DAT exists..!
fh2=exist('.\invert\inpinv.dat','file');
if (fh2~=2);
    errordlg('Invert folder doesn''t contain inpinv.dat. Please run inversion. ','File Error');
   delete(handles.timefun)
end

%%  
try
cd invert
% read inpinv
          fid = fopen('inpinv.dat','r');
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
cd ..
catch
    cd ..
end
%% check allstat and station raw files

h=dir('.\invert\allstat.dat');
  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
  else 
  
           [NS,d1,d2,d3,d4,d5,d6,d7,d8] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 
           
              disp('This code needs new allsta.dat format')
                  % number of stations
              nostations = length(NS);
              for i=1:nostations
                 realdatafilename{i}=[char(NS(i)) 'raw.dat']
              end
              % now check if all RAW files are present and copy to timefun
              % folder
              cd invert
              %
              for i=1:nostations
                  if exist(realdatafilename{i},'file')
                      [s,m]=copyfile(char(realdatafilename{i}),'..\timefunc');
                  else
                      disp(['File ' realdatafilename{i} ' is missing'])
                      errordlg(['File ' realdatafilename{i} '  not found in invert folder. Run Data Preparation for this station' ] ,'File Error');    
                  end
              end
             % copy allstat also 
             [s,m]=copyfile('allstat.dat','..\timefunc');
             
% back one folder
             disp('   ')
             cd ..
        
  end
  
disp('  ');
disp(['Number of trial source positions in \invert\inpinv.dat is ' linetmp6]);
disp('  ');
disp(['Frequency Range in \invert\inpinv.dat is ' linetmp14]);
disp('  ');

 
% make an array for sources
src=num2str([1:str2double(linetmp6)]');
set(handles.nosourcepopup1,'String',src);
set(handles.nosourcepopup2,'String',src);
% set info text 
set(handles.info_nsrc,'String',linetmp6);
% set info text
set(handles.info_freq,'String',regexprep(linetmp14,' ','-'));



%% find duration of source time function used in elemse

           fid = fopen('.\green\soutype.dat','r');
            type=fscanf(fid,'%d',1);   %01 line
            dur=fscanf(fid,'%f',1);   %14        %02 line
           fclose(fid);
           
           if type == 7
              %  errordlg('Source type of elementary seismograms is delta. Use triangle','File Error');
              disp('Source type of elementary seismograms is delta. Formal source duration is 0.1')
               set(handles.tdur,'String',num2str(0.1));
           elseif      type == 4
               set(handles.tdur,'String',num2str(dur));
           end
           

%%
%set(handles.sourceno,'String',num2str(srcpos2(1,1)));        
% set(handles.strike,'String',num2str(str1(1,1)));        
% set(handles.dip,'String',num2str(dip1(1,1)));        
% set(handles.rake,'String',num2str(rake1(1,1)));        
% set(handles.moment,'String',num2str(mo(1,1),'%3.1e'));        

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
handles.linetmp16=linetmp16;         %01 line
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes timefun wait for user response (see UIRESUME)
% uiwait(handles.timefun);


% --- Outputs from this function are returned to the command line.
function varargout = timefun_OutputFcn(hObject, eventdata, handles) 
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

% Read input data
%% update inpinv.dat with nsource=2
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
linetmp16=handles.linetmp16;
%
fid = fopen('.\timefunc\inpinv.dat','w');
          fprintf(fid,'%s\r\n',linetmp1);
          fprintf(fid,'%s\r\n',linetmp2);
          fprintf(fid,'%s\r\n',linetmp3);
          fprintf(fid,'%s\r\n',linetmp4);
          fprintf(fid,'%s\r\n',linetmp5);
          fprintf(fid,'%s\r\n',linetmp6');
          fprintf(fid,'%s\r\n',linetmp7);
          fprintf(fid,'%s\r\n',linetmp8);
          fprintf(fid,'%s\r\n',linetmp9);
          fprintf(fid,'%s\r\n',linetmp10);
          fprintf(fid,'%s\r\n',linetmp11);
          fprintf(fid,'%s\r\n',linetmp12);
          fprintf(fid,'%s\r\n',linetmp13);
          fprintf(fid,'%s\r\n',linetmp14);
          fprintf(fid,'%s\r\n',linetmp15);
          fprintf(fid,'%s\r\n',linetmp16);
fclose(fid);

%%
% prepare the two acka files
strike1 = str2double(get(handles.strike1,'String'));
dip1 = str2double(get(handles.dip1,'String'));
rake1 = str2double(get(handles.rake1,'String'));
xmoment1 = str2double(get(handles.mo1,'String'));

[a1,a2,a3,a4,a5,a6]=sdr2as(strike1,dip1,rake1,1);  % constrain Mo to 1
 
fid = fopen('.\timefunc\acka1.dat','w');
fprintf(fid,'%9.4e\r\n',a1);
fprintf(fid,'%9.4e\r\n',a2);
fprintf(fid,'%9.4e\r\n',a3);
fprintf(fid,'%9.4e\r\n',a4);
fprintf(fid,'%9.4e\r\n',a5);
fprintf(fid,'%9.4e\r\n',a6);
fclose(fid);

strike2 = str2double(get(handles.strike2,'String'));
dip2 = str2double(get(handles.dip2,'String'));
rake2 = str2double(get(handles.rake2,'String'));
xmoment2 = str2double(get(handles.mo2,'String'));

[a1,a2,a3,a4,a5,a6]=sdr2as(strike2,dip2,rake2,1);  % constrain Mo to 1

fid = fopen('.\timefunc\acka2.dat','w');
fprintf(fid,'%9.4e\r\n',a1);
fprintf(fid,'%9.4e\r\n',a2);
fprintf(fid,'%9.4e\r\n',a3);
fprintf(fid,'%9.4e\r\n',a4);
fprintf(fid,'%9.4e\r\n',a5);
fprintf(fid,'%9.4e\r\n',a6);
fclose(fid);

%% get the selected source numbers
src1 = get(handles.src1,'String')
src2 = get(handles.src2,'String')

 elemfilename1=['elemse' src1 '.dat'];
 elemfilename2=['elemse' src2 '.dat'];
 
 % go in invert and copy 
 try 
    cd invert
                   if exist(elemfilename1,'file')
                      [s,m]=copyfile(elemfilename1,'..\timefunc');
                   else
                      disp(['File ' elemfilename1 ' is missing'])
                      errordlg(['File ' elemfilename1 '  not found in invert folder. Run Green Preparation for this station' ] ,'File Error');    
                   end
 
                  if exist(elemfilename2,'file')
                      [s,m]=copyfile(elemfilename2,'..\timefunc');
                   else
                      disp(['File ' elemfilename2 ' is missing'])
                      errordlg(['File ' elemfilename2 '  not found in invert folder. Run Green Preparation for this station' ] ,'File Error');    
                  end
    cd ..
 catch
     cd ..
 end
 
%% Prepare a file with options
% read values

% find if we have 1 or 2 sources
if(get(handles.radiobutton2,'Value')==1)
    nsources=2;
else
    nsources=1;
end
%
% check if we need to constrain Mo
if(get(handles.cMo,'Value')==1)
    conMo=1;
else
    conMo=0;
end

%notriang = get(handles.notriang,'String');
% notriang =12; %FIXED
src1= get(handles.src1,'String');
src2= get(handles.src2,'String');
src1shft=get(handles.tshift1,'String');
src2shft=get(handles.tshift2,'String');
tdur=get(handles.tdur,'String');
trdist=get(handles.trdist,'String');

 fid = fopen('.\timefunc\casopt.dat','w');
           fprintf(fid,'%d\r\n',nsources);
%           fprintf(fid,'%s\r\n',notriang);

 if(nsources==2)
           fprintf(fid,'%s\r\n',src1);
           fprintf(fid,'%s\r\n',src2);
           fprintf(fid,'%s\r\n',src1shft);
           fprintf(fid,'%s\r\n',src2shft);
 else
           fprintf(fid,'%s\r\n',src1);
           fprintf(fid,'%s\r\n',src1shft);
 end
           fprintf(fid,'%s\r\n',tdur);           
           fprintf(fid,'%s\r\n',trdist);        
 if(conMo==0)
           fprintf(fid,'%d\r\n',conMo);
 elseif(conMo==1)
           fprintf(fid,'%d\r\n',conMo);
           fprintf(fid,'%e\r\n',xmoment1);
           fprintf(fid,'%e\r\n',xmoment2);
 else
 end
     
     
           
fclose(fid);


%%  Prepare a batch file for running the code..
 fid = fopen('.\timefunc\runtimfun.bat','w');
           fprintf(fid,'%s\r\n','time_fixed.exe');
           fprintf(fid,'%s\r\n','norm11b.exe');
           fprintf(fid,'%s\r\n','timfuncas.exe');
 
           fprintf(fid,'%s\r\n','timfuncas1.exe');
           fprintf(fid,'%s\r\n','timfuncas2.exe');
           
 fclose(fid);
 
 
%%  RUN the batch file
        button = questdlg('Run Inversion ?','Inversion ','Yes','No','Yes');
        if strcmp(button,'Yes')
           disp('Running inversion')
            cd timefunc
             system('runtimfun.bat &') % return to ISOLA folder    
            cd ..
            pwd
       elseif strcmp(button,'No')
          disp('Canceled ')
       end 

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.timefun)

% --- Executes on selection change in nosourcepopup1.
function nosourcepopup1_Callback(hObject, eventdata, handles)
% hObject    handle to nosourcepopup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns nosourcepopup1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from nosourcepopup1

srcnumber = num2str(get(handles.nosourcepopup1,'Value')); 
srcn = get(handles.nosourcepopup1,'Value'); % arithmetic 

if length(srcnumber) < 2
    srcnumber=['0' srcnumber];
end

% update text
set(handles.src1,'String',srcnumber);

%% read inv2 and search for this source

h=dir('.\invert\inv2.dat');

%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
if isempty(h); 
    %errordlg('inv2.dat file doesn''t exist. Run Invert. ','File Error');
    % user selects options ..?? 
    disp('Inv2.dat wasn''t found. Run inversion ot specify strike dip rake directly.')     
else
     fid = fopen('.\invert\inv2.dat','r');   % check version
         tline = fgetl(fid);
     if length(tline) > 125
          disp('New inv2.dat')
          inv2age='new';
       fclose(fid);
       % read new version
       fid = fopen('.\invert\inv2.dat','r');
      %   [srcpos,srctime,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('.\invert\inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f') 
         C=textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
       fclose(fid);
       % find position in C that srcpos==srcnumber
       inx=find(cell2mat(C(1,1))==srcn);  
           if ~isempty(inx)
               %update fields
               s=cell2mat(C(1,2));stime1=s(inx);
               s=cell2mat(C(1,3));mo=s(inx);
               s=cell2mat(C(1,4));str1=s(inx);
               s=cell2mat(C(1,5));dip1=s(inx);
               s=cell2mat(C(1,6));rake1=s(inx);
                set(handles.strike1,'String',num2str(str1));
                set(handles.dip1,'String',num2str(dip1));
                set(handles.rake1,'String',num2str(rake1));
                set(handles.mo1,'String',num2str(mo,'%3.1e'));
                set(handles.tshift1,'String',num2str(stime1));
           else
                disp('Source is not in inv2.dat')
                set(handles.strike1,'String','');
                set(handles.dip1,'String','');
                set(handles.rake1,'String','');
                set(handles.mo1,'String','');
                set(handles.tshift1,'String','');
           end
     else % old inv2
       disp('Old version of inv2.dat. Use new ISOLA.') 
     end
     % read inv2 stop
end

% --- Executes during object creation, after setting all properties.
function nosourcepopup1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nosourcepopup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
off=handles.radiobutton2;
mutual_exclude(off);

set(findall(handles.uipanel2, '-property', 'enable'), 'enable', 'off')

set(handles.tshift2,'enable','off')
set(handles.text22,'enable','off')

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
off=handles.radiobutton1;
mutual_exclude(off);

set(findall(handles.uipanel2, '-property', 'enable'), 'enable', 'on')

set(handles.tshift2,'enable','on')
set(handles.text22,'enable','on')

% --- Executes on selection change in nosourcepopup2.
function nosourcepopup2_Callback(hObject, eventdata, handles)
% hObject    handle to nosourcepopup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns nosourcepopup2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from nosourcepopup2

srcnumber = num2str(get(handles.nosourcepopup2,'Value'));
srcn = get(handles.nosourcepopup2,'Value'); % arithmetic 

if length(srcnumber) < 2
    srcnumber=['0' srcnumber];
end

% update text
set(handles.src2,'String',srcnumber);

%% read inv2 and search for this source

h=dir('.\invert\inv2.dat');

%%%%%%%%%%%%%%%%%%%%%%  check length of inv2.dat
if isempty(h); 
    %errordlg('inv2.dat file doesn''t exist. Run Invert. ','File Error');
    % user selects options ..?? 
    disp('Inv2.dat wasn''t found. Run inversion ot specify strike dip rake directly.')     
else
     fid = fopen('.\invert\inv2.dat','r');   % check version
         tline = fgetl(fid);
     if length(tline) > 125
          disp('New inv2.dat')
          inv2age='new';
       fclose(fid);
       % read new version
       fid = fopen('.\invert\inv2.dat','r');
      %   [srcpos,srctime,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('.\invert\inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f') 
         C=textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
       fclose(fid);
       % find position in C that srcpos==srcnumber
       inx=find(cell2mat(C(1,1))==srcn);  
           if ~isempty(inx)
               %update fields
               s=cell2mat(C(1,2));stime1=s(inx);
               s=cell2mat(C(1,3));mo=s(inx);
               s=cell2mat(C(1,4));str1=s(inx);
               s=cell2mat(C(1,5));dip1=s(inx);
               s=cell2mat(C(1,6));rake1=s(inx);
                set(handles.strike2,'String',num2str(str1));
                set(handles.dip2,'String',num2str(dip1));
                set(handles.rake2,'String',num2str(rake1));
                set(handles.mo2,'String',num2str(mo,'%3.1e'));
                set(handles.tshift2,'String',num2str(stime1));
           else
               disp('Source is not in inv2.dat')
                set(handles.strike2,'String','');
                set(handles.dip2,'String','');
                set(handles.rake2,'String','');
                set(handles.mo2,'String','');
                set(handles.tshift2,'String','');
           end
     else % old inv2
       disp('Old version of inv2.dat. Use new ISOLA.') 
     end
     % read inv2 stop
end

% --- Executes during object creation, after setting all properties.
function nosourcepopup2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nosourcepopup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strike1_Callback(hObject, eventdata, handles)
% hObject    handle to strike1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike1 as text
%        str2double(get(hObject,'String')) returns contents of strike1 as a double


% --- Executes during object creation, after setting all properties.
function strike1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip1_Callback(hObject, eventdata, handles)
% hObject    handle to dip1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip1 as text
%        str2double(get(hObject,'String')) returns contents of dip1 as a double


% --- Executes during object creation, after setting all properties.
function dip1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rake1_Callback(hObject, eventdata, handles)
% hObject    handle to rake1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake1 as text
%        str2double(get(hObject,'String')) returns contents of rake1 as a double


% --- Executes during object creation, after setting all properties.
function rake1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mo1_Callback(hObject, eventdata, handles)
% hObject    handle to mo1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mo1 as text
%        str2double(get(hObject,'String')) returns contents of mo1 as a double


% --- Executes during object creation, after setting all properties.
function mo1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mo1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strike2_Callback(hObject, eventdata, handles)
% hObject    handle to strike2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike2 as text
%        str2double(get(hObject,'String')) returns contents of strike2 as a double


% --- Executes during object creation, after setting all properties.
function strike2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip2_Callback(hObject, eventdata, handles)
% hObject    handle to dip2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip2 as text
%        str2double(get(hObject,'String')) returns contents of dip2 as a double


% --- Executes during object creation, after setting all properties.
function dip2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rake2_Callback(hObject, eventdata, handles)
% hObject    handle to rake2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake2 as text
%        str2double(get(hObject,'String')) returns contents of rake2 as a double


% --- Executes during object creation, after setting all properties.
function rake2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mo2_Callback(hObject, eventdata, handles)
% hObject    handle to mo2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mo2 as text
%        str2double(get(hObject,'String')) returns contents of mo2 as a double


% --- Executes during object creation, after setting all properties.
function mo2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mo2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [a1,a2,a3,a4,a5,a6]=sdr2as(strike,dip,rake,xmoment)

%   strike=deg2rad(strike);
%	dip=deg2rad(dip);
%	rake=deg2rad(rake);

%   strike=strike*pi2/180.
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



function notriang_Callback(hObject, eventdata, handles)
% hObject    handle to notriang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notriang as text
%        str2double(get(hObject,'String')) returns contents of notriang as a double


% --- Executes during object creation, after setting all properties.
function notriang_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notriang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tshift1_Callback(hObject, eventdata, handles)
% hObject    handle to tshift1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tshift1 as text
%        str2double(get(hObject,'String')) returns contents of tshift1 as a double


% --- Executes during object creation, after setting all properties.
function tshift1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tshift1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tshift2_Callback(hObject, eventdata, handles)
% hObject    handle to tshift2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tshift2 as text
%        str2double(get(hObject,'String')) returns contents of tshift2 as a double


% --- Executes during object creation, after setting all properties.
function tshift2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tshift2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trdist_Callback(hObject, eventdata, handles)
% hObject    handle to trdist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trdist as text
%        str2double(get(hObject,'String')) returns contents of trdist as a double


% --- Executes during object creation, after setting all properties.
function trdist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trdist (see GCBO)
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

%decide about axis limits
%notriang = str2double(get(handles.notriang,'String'));
notriang = 12;% FIXED
tdur=str2double(get(handles.trdist,'String'));

shift1=str2double(get(handles.tshift1,'String'));
shift2=str2double(get(handles.tshift2,'String'));
 
llimit=(min([shift1;shift2])-2);

%rlimit=(notriang*tdur);

rlimit=(max([shift1;shift2])+(notriang*tdur)+1) ;



%% check if files exist..!
fh2=exist('.\timefunc\timfun.dat','file');
if (fh2~=2);
    errordlg('Timefunc folder doesn''t contain timefun.dat. Please run inversion. ','File Error');
    delete(handles.timefun)
end

fh2=exist('.\timefunc\timfun1.dat','file');
if (fh2~=2);
    errordlg('Timefunc folder doesn''t contain timefun1.dat. Please run inversion. ','File Error');
    delete(handles.timefun)
end

fh2=exist('.\timefunc\timfun2.dat','file');
if (fh2~=2);
    errordlg('Timefunc folder doesn''t contain timefun2.dat. Please run inversion. ','File Error');
    delete(handles.timefun)
end

%% load files
tsum=load('.\timefunc\timfun.dat');
t1=load('.\timefunc\timfun1.dat');
t2=load('.\timefunc\timfun2.dat');

figure
subplot(3,1,1)
plot(t1(:,1),t1(:,2))
title('Source 1')
v=axis;
axis([llimit rlimit v(3) v(4)])

subplot(3,1,2)
plot(t2(:,1),t2(:,2))
title('Source 2')
v=axis;
axis([llimit rlimit v(3) v(4)])

subplot(3,1,3)
plot(tsum(:,1),tsum(:,2))
title('Source 1+2')
v=axis;
axis([llimit rlimit v(3) v(4)])




% --- Executes on button press in checkfiles.
function checkfiles_Callback(hObject, eventdata, handles)
% hObject    handle to checkfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% check if files exist..!
fh2=exist('.\timefunc\inv111.dat','file');
if (fh2~=2);
    errordlg('Timefunc folder doesn''t contain inv111.dat. Please run inversion. ','File Error');
    delete(handles.timefun)
end

fh2=exist('.\timefunc\inv222.dat','file');
if (fh2~=2);
    errordlg('Timefunc folder doesn''t contain inv222.dat. Please run inversion. ','File Error');
    delete(handles.timefun)
end

try
    
    cd timefunc
      dos('notepad inv111.dat &')
      dos('notepad inv222.dat &')
    cd ..
catch
    cd ..
end


function mutual_exclude(off)
set(off,'Value',0);
 


% --- Executes on button press in cMo.
function cMo_Callback(hObject, eventdata, handles)
% hObject    handle to cMo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cMo
