function varargout = plsourcesxy(varargin)
% PLSOURCESXY M-file for plsourcesxy.fig
%      PLSOURCESXY, by itself, creates a new PLSOURCESXY or raises the existing
%      singleton*.
%
%      H = PLSOURCESXY returns the handle to a new PLSOURCESXY or the handle to
%      the existing singleton*.
%
%      PLSOURCESXY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLSOURCESXY.M with the given input arguments.
%
%      PLSOURCESXY('Property','Value',...) creates a new PLSOURCESXY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plsourcesxy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plsourcesxy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plsourcesxy

% Last Modified by GUIDE v2.5 01-Aug-2005 12:18:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plsourcesxy_OpeningFcn, ...
                   'gui_OutputFcn',  @plsourcesxy_OutputFcn, ...
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


% --- Executes just before plsourcesxy is made visible.
function plsourcesxy_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plsourcesxy (see VARARGIN)

% Choose default command line output for plsourcesxy
handles.output = hObject;

 a=exist('.\gmtfiles\sources.isl');

  if a == 2
  
      fid = fopen('.\gmtfiles\sources.isl','r');

           mapscale=fscanf(fid,'%s',1)
           maptics=fscanf(fid,'%s',1)
           lscale=fscanf(fid,'%s',1)
           symbolsize=fscanf(fid,'%s',1)
           dxdy=fscanf(fid,'%s',1)
           fontsize=fscanf(fid,'%s',1)
           border=fscanf(fid,'%s',1)
           scaleshift=fscanf(fid,'%s',1)
           fshift=fscanf(fid,'%s',1)
           xshift=fscanf(fid,'%s',1)
fclose(fid);

set(handles.scalev,'String',mapscale);        
set(handles.tics,'String',maptics);        
set(handles.mscale,'String',lscale);        
set(handles.symbolsize,'String',symbolsize);        
set(handles.dxdy,'String',dxdy);        
set(handles.fsize,'String',fontsize);        
set(handles.border,'String',border);        
set(handles.scaleshift,'String',scaleshift);        
set(handles.fshift,'String',fshift);        
set(handles.xshift,'String',xshift);        

else
end





% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plsourcesxy wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plsourcesxy_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is plsourcesxy 27/05/05');

% --- Executes on button press in Plot.
function Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%read 
mapscale = str2double(get(handles.scalev,'String'))
maptics = get(handles.tics,'String')
lscale = get(handles.mscale,'String')
symbolsize = get(handles.symbolsize,'String')
dxdy = get(handles.dxdy,'String')
fontsize = str2double(get(handles.fsize,'String'))
border = str2double(get(handles.border,'String'))
scaleshift = str2double(get(handles.scaleshift,'String'))
fshift = str2double(get(handles.fshift,'String'))
xshift = str2double(get(handles.xshift,'String'))

fshiftor=fshift;
%%%%%%%%%%%%%%%%%%%%%%%%%%read inversion files%%%%%%%%inv2.dat and inv3.dat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if INVERT exists..!
h=dir('invert');

if length(h) == 0;
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd invert

h=dir('inv2.dat');

if length(h) == 0; 
    errordlg(['Inv2.dat file doesn''t exist. Run Invert and norm. '],'File Error');
    cd ..
  return    
else
    fid = fopen('inv2.dat','r');
    [srcpos2,srctime2,mom,s1,di1,r1,s2,di2,r2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f  %f %f  %f %f %f %f',-1);
    fclose(fid);
%     cd ..
end

%%read inv3.dat
h=dir('inv3.dat');

if length(h) == 0; 
    errordlg(['Inv3.dat file doesn''t exist. Run Invert and norm. '],'File Error');
    cd ..
  return    
else
    fid = fopen('inv3.dat','r');
    [srcpos3,srctime3,mrr, mtt, mff, mrt, mrf, mtf ] = textread('inv3.dat','%f %f %q %q %q %q %q %q')
    fclose(fid);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% go back
cd ..


%%%check the sources.gmt in gmtfiles
pwd

cd gmtfiles

h=dir('sour.dat');

if length(h) == 0; 
  errordlg('Sour.dat file doesn''t exist. Run Source definition. ','File Error');
  return
else

fid  = fopen('sour.dat','r');
[lon,lat,depth,sourceno] = textread('sour.dat','%f %f %f %f')
fclose(fid);
end


%%%%%USE SOURCE COORDINATES AND SOURCE NUMBER TO FIND SUB  SOURCE
%%%%%COORDINATES
%% [srcpos2,srctime2,mom,s1,di1,r1,s2,di2,r2,dc,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f',-1)

whos srcpos2 sourceno

 for i=1:length(srcpos2);

%        srctime2(i,1)=srctime2(i,1)*dt;   %%%%convert time shift to
%        seconds.....!!!!  (inv2 will be in seconds)!!
     
     for j=1:length(sourceno);
             
         if  srcpos2(i,1) == sourceno(j,1)
             srclon(i,1) = lon(j,1)   %%%%Longitude    %%% x coordinate
             srclat(i,1) = lat(j,1)   %%%%Longitude    %%% y ...
         end    
         
     end
     
 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%find map limits...
wend=min(lon);
eend=max(lon);
send=min(lat);
nend=max(lat);

w=(wend-border);
e=(eend+border);
s=(send-border);
n=(nend+border);


%%%make -R
%num2str(centx,'%7.2f')
r=['-R' num2str(w,'%7.5f') '/' num2str(e,'%7.5f') '/' num2str(s,'%7.5f') '/' num2str(n,'%7.5f') ' '];

%%%make -J

j=[' -JX' num2str(mapscale)];


centy=((nend-send)/2)+send;
centx=((eend-wend)/2)+wend;
ly=(((nend-send)/2)+send)-(border-scaleshift);


%%%make -L
lf=['-Lf' num2str(centx,'%7.2f') '/' num2str(ly,'%7.2f') '/' num2str(centy,'%7.2f') '/' lscale ];


%%%%%%%%%make focal mechanism files for plotting
%prepare text above beach balls

whos dc srctime2 srclon

% for i=1:length(srcpos2)
%   btext(i,1)=[num2str(srctime2(i,1)) '  ' num2str(dc(i,1))];
% 
% end
  xshift=-xshift;

fid = fopen('beachb.foc','w');
 for i=1:length(srcpos2)
      fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g %s\r\n',srclon(i,1),srclat(i,1),5,s1(i,1),di1(i,1),r1(i,1),5,srclon(i,1)+fshift+xshift,srclat(i,1)+fshift,[num2str(srctime2(i,1)) '____' num2str(dc(i,1))]);
  fshift=-fshift+(fshift/2);  
  xshift=-xshift;
  end
fclose(fid);

%%% prepare a gmt style file for source text
% 
    fid = fopen('sources.txt','w');
     for i=1:length(lon)
              fprintf(fid,'%g  %g  %g  %g  %g  %s %g\r\n',lon(i),lat(i),fontsize,0,1,'CM',sourceno(i));
      end
      fclose(fid);

    
    
    fid = fopen('plsrcxy.bat','w');
    
        sstring=['psxy ' r  j ' sour.dat -S' symbolsize  ' -M  -W1p/0 -K -G255/0/0 -B' maptics ' > sourcesxy.ps' ];
    fprintf(fid,'%s\r\n',sstring);
        stextstr=['pstext -R ' j ' sources.txt -N -O -K -D' dxdy ' >> sourcesxy.ps' ];
    fprintf(fid,'%s\r\n',stextstr);

    %psmeca -JM9i -R -Sa0.5i strofades.gmt -V -O -K -G255/0/0 -C1 >> 3dpatra.eps
    
        fostring=['psmeca -R ' j ' -Sa0.5i beachb.foc -V -O -C1 -N >> sourcesxy.ps'];
    fprintf(fid,'%s\r\n',fostring);
            
         fclose(fid);
% 
% %%% run batch file...
% 
[s,r]=system('plsrcxy.bat');
% 
system('gsview32 sourcesxy.ps');
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%output map values in isl file%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% fid = fopen('sources.isl','w');
%          fprintf(fid,'%s\r\n',num2str(mapscale));
%          fprintf(fid,'%s\r\n',maptics);
%          fprintf(fid,'%s\r\n',lscale);
%          fprintf(fid,'%s\r\n',symbolsize);
%          fprintf(fid,'%s\r\n',dxdy );
%          fprintf(fid,'%s\r\n',num2str(fontsize));
%          fprintf(fid,'%s\r\n',num2str(border) );
%          fprintf(fid,'%s\r\n',num2str(scaleshift));
%          fprintf(fid,'%s\r\n',num2str(fshiftor));
%          fprintf(fid,'%s\r\n',num2str(xshift));
% 
% fclose(fid);

cd ..

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.plsourcesxy)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function scalev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scalev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function scalev_Callback(hObject, eventdata, handles)
% hObject    handle to scalev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scalev as text
%        str2double(get(hObject,'String')) returns contents of scalev as a double


% --- Executes during object creation, after setting all properties.
function tics_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tics_Callback(hObject, eventdata, handles)
% hObject    handle to tics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tics as text
%        str2double(get(hObject,'String')) returns contents of tics as a double


% --- Executes during object creation, after setting all properties.
function mscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function mscale_Callback(hObject, eventdata, handles)
% hObject    handle to mscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mscale as text
%        str2double(get(hObject,'String')) returns contents of mscale as a double


% --- Executes during object creation, after setting all properties.
function symbolsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to symbolsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function symbolsize_Callback(hObject, eventdata, handles)
% hObject    handle to symbolsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of symbolsize as text
%        str2double(get(hObject,'String')) returns contents of symbolsize as a double


% --- Executes during object creation, after setting all properties.
function dxdy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dxdy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dxdy_Callback(hObject, eventdata, handles)
% hObject    handle to dxdy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dxdy as text
%        str2double(get(hObject,'String')) returns contents of dxdy as a double


% --- Executes during object creation, after setting all properties.
function fsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fsize_Callback(hObject, eventdata, handles)
% hObject    handle to fsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fsize as text
%        str2double(get(hObject,'String')) returns contents of fsize as a double


% --- Executes during object creation, after setting all properties.
function border_CreateFcn(hObject, eventdata, handles)
% hObject    handle to border (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function border_Callback(hObject, eventdata, handles)
% hObject    handle to border (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of border as text
%        str2double(get(hObject,'String')) returns contents of border as a double


% --- Executes during object creation, after setting all properties.
function legendl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to legendl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function legendl_Callback(hObject, eventdata, handles)
% hObject    handle to legendl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of legendl as text
%        str2double(get(hObject,'String')) returns contents of legendl as a double


% --- Executes during object creation, after setting all properties.
function scaleshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function scaleshift_Callback(hObject, eventdata, handles)
% hObject    handle to scaleshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaleshift as text
%        str2double(get(hObject,'String')) returns contents of scaleshift as a double


% --- Executes during object creation, after setting all properties.
function fshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fshift_Callback(hObject, eventdata, handles)
% hObject    handle to fshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fshift as text
%        str2double(get(hObject,'String')) returns contents of fshift as a double


% --- Executes during object creation, after setting all properties.
function xshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function xshift_Callback(hObject, eventdata, handles)
% hObject    handle to xshift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xshift as text
%        str2double(get(hObject,'String')) returns contents of xshift as a double


