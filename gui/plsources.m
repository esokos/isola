function varargout = plsources(varargin)
% PLSOURCES M-file for plsources.fig
%      PLSOURCES, by itself, creates a new PLSOURCES or raises the existing
%      singleton*.
%
%      H = PLSOURCES returns the handle to a new PLSOURCES or the handle to
%      the existing singleton*.
%
%      PLSOURCES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLSOURCES.M with the given input arguments.
%
%      PLSOURCES('Property','Value',...) creates a new PLSOURCES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plsources_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plsources_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plsources

% Last Modified by GUIDE v2.5 09-Nov-2012 00:45:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plsources_OpeningFcn, ...
                   'gui_OutputFcn',  @plsources_OutputFcn, ...
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


% --- Executes just before plsources is made visible.
function plsources_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plsources (see VARARGIN)

% Choose default command line output for plsources
handles.output = hObject;

 a=exist('sources.isl');

if a == 2
      
      disp('Found sources.isl file')
      
      fid = fopen('sources.isl','r');

           mapscale=fscanf(fid,'%s',1);
           maptics=fscanf(fid,'%s',1);
           lscale=fscanf(fid,'%s',1);
           symbolsize=fscanf(fid,'%s',1);
           dxdy=fscanf(fid,'%s',1);
           fontsize=fscanf(fid,'%s',1);
           border=fscanf(fid,'%s',1);
           scaleshift=fscanf(fid,'%s',1);
           fshift=fscanf(fid,'%s',1);
           xshift=fscanf(fid,'%s',1);
           bbscale=fscanf(fid,'%s',1);
           normfactor=fscanf(fid,'%s',1);
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
set(handles.bbscale,'String',bbscale);   
set(handles.normf,'String',normfactor); 

else
end


%%%%Try to populate GMT palette popupmenu....
h=dir('C:\GMT\share\cpt');

if isempty(h); 
    %%% GMT is not installed in c:\gmt or cpt folder doesn't exist...so
    %%% we'll use standard palettes
    
cpt_file={'cool','copper','drywet','gebco','globe','gray','haxby','hot','jet','no green','ocean','polar','rainbow','red2green','relief','sealand','seis','split','topo','wysiwyg'};

 disp('It seems that GMT is not installed at c:\gmt ... ')
 disp('If you want INVERT_GUI to automatically find your cpt files change the path at line 252 of invert.m')
 disp('Using GMT default cpt files...')
 
     set(handles.gmtpal,'String',cpt_file);

else
    
    cpt_files=dir('C:\GMT\share\cpt\*.cpt');
    
    cpt_file1=strrep({cpt_files(:).name},'GMT_','');    
    cpt_file =strrep(cpt_file1,'.cpt','');    

    set(handles.gmtpal,'String',cpt_file);
    disp('Using cpt files found in C:\GMT\share\cpt')
    
end



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plsources wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plsources_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is plsources 07/11/2011');

% correct problem with waveform ploting  when source.ps file was
% open....2/8/09



% --- Executes on button press in Plot.
function Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Plotting using GMT...(in gmtfiles folder)')

%%%%%read 
mapscale = str2double(get(handles.scalev,'String'));
maptics = get(handles.tics,'String');
lscale = get(handles.mscale,'String');
symbolsize = get(handles.symbolsize,'String');
dxdy = get(handles.dxdy,'String');
fontsize = str2double(get(handles.fsize,'String'));
border = str2double(get(handles.border,'String'));
scaleshift = str2double(get(handles.scaleshift,'String'));
fshift = str2double(get(handles.fshift,'String'));
xshift = str2double(get(handles.xshift,'String'));
bbscale=get(handles.bbscale,'String');
fshiftor=fshift;

snumber = get(handles.snumber,'Value');

psxyfile=get(handles.filetoadd,'String');

%%%%%%%%%find distance step
%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%       distep=fscanf(fid,'%f',1);
                noSourcesstrike=fscanf(fid,'%i',1);
                strikestep=fscanf(fid,'%i',1);
                noSourcesdip=fscanf(fid,'%i',1);
                dipstep=fscanf(fid,'%i',1);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%read inversion files%%%%%%%%inv2.dat and inv3.dat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if INVERT exists..!
h=dir('invert');

if isempty(h);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try

cd invert

h=dir('inv2.dat');

if isempty(h); 
    errordlg('Inv2.dat file doesn''t exist. Run Invert and norm. ','File Error');
    cd ..
  return    
else
    fid = fopen('inv2.dat','r');
    [srcpos2,srctime2,mom,s1,di1,r1,s2,di2,r2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f  %f %f %f',-1);
    fclose(fid);
%     cd ..
end


mommag=(2/3)*(log10(mom) - 9.1); %  mommag=(2/3)*(log10(mo(psrcpos)) - 9.1) Hanks & Kanamori (1979)


%%read inv3.dat
h=dir('inv3.dat');

if isempty(h); 
    errordlg(['Inv3.dat file doesn''t exist. Run Invert and norm. '],'File Error');
    cd ..
  return    
else
    fid = fopen('inv3.dat','r');
    [srcpos3,srctime3,mrr, mtt, mff, mrt, mrf, mtf ] = textread('inv3.dat','%f %f %q %q %q %q %q %q');
    fclose(fid);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% go back
cd ..

catch
    disp('error reading inv2 inv3 files...')
    cd ..
end

%%%check the sources.gmt in gmtfiles
pwd

cd gmtfiles

h=dir('sources.gmt');

if isempty(h); 
  errordlg('Sources.gmt file doesn''t exist. Run Source definition. ','File Error');
  return
else
   
%%%%read coordinates.....
 if source_gmtfile==0

     fid  = fopen('sources.gmt','r');
      [lon,lat,depth,sourceno] = textread('sources.gmt','%f %f %f %f',nsources,'headerlines',1);
     fclose(fid);

 elseif source_gmtfile==1
     
     fid  = fopen('sources.gmt','r');
      [lon,lat,scale,depth,sourceno,char] = textread('sources.gmt','%f %f %f %f %f %s',nsources);
     fclose(fid);
 end

end


%%%%%USE SOURCE COORDINATES AND SOURCE NUMBER TO FIND SUB  SOURCE
%%%%%COORDINATES
%% [srcpos2,srctime2,mom,s1,di1,r1,s2,di2,r2,dc,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f',-1)

% whos srcpos2 sourceno

 for i=1:length(srcpos2);

%        srctime2(i,1)=srctime2(i,1)*dt;   %%%%convert time shift to
%        seconds.....!!!!  (inv2 will be in seconds)!!
     
     for j=1:length(sourceno);
             
         if  srcpos2(i,1) == sourceno(j,1)
             srclon(i,1) = lon(j,1);   %%%%Longitude 
             srclat(i,1) = lat(j,1);   %%%%Longitude 
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

j=[' -JM' num2str(mapscale) 'c'];


centy=((nend-send)/2)+send;
centx=((eend-wend)/2)+wend;
%ly=(((nend-send)/2)+send)-(border-scaleshift);

ly=s+scaleshift;

%%%make -L
lf=['-Lf' num2str(centx,'%7.2f') '/' num2str(ly,'%7.4f') '/' num2str(centy,'%7.2f') '/' lscale '+l'];


%%%%%%%%%make focal mechanism files for plotting
%prepare text above beach balls

% whos dc srctime2 srclon

% for i=1:length(srcpos2)
%   btext(i,1)=[num2str(srctime2(i,1)) '  ' num2str(dc(i,1))];
% 
% end
  xshift=-xshift;

fid = fopen('beachb.foc','w');
 for i=1:length(srcpos2)
      fprintf(fid,'%g  %g  %g  %g  %g  %g  %s  %g  %g %s\r\n',srclon(i,1),srclat(i,1),5,s1(i,1),di1(i,1),r1(i,1),num2str(mommag(i),'%5.3g'),srclon(i,1)+fshift+xshift,srclat(i,1)+fshift,[num2str(srctime2(i,1))]);  %'    ' num2str(mom(i,1),'%5.2e')]);
  fshift=-fshift+(fshift/2);  
  xshift=-xshift;
  end
fclose(fid);

%%% prepare a gmt style file for source text
% 

%%%%%%%%%%%%%%%%%%%%%%% check if there are 1 or more sources ...
    fid = fopen('sources.txt','w');
     for i=1:length(lon)
          if length(srcpos3) == 1
              fprintf(fid,'%g  %g  %g  %g  %g  %s %g\r\n',lon(i),lat(i),fontsize,0,1,'CM',sourceno(i));          %srcpos3(1));
          else
              fprintf(fid,'%g  %g  %g  %g  %g  %s %g\r\n',lon(i),lat(i),fontsize,0,1,'CM',sourceno(i));
          end     
      end
      fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fid = fopen('plsrc.bat','w');
    
    fprintf(fid,'%s\r\n','gmtset PLOT_DEGREE_FORMAT D ');

      pscoastr=['pscoast ' r   j ' -G255/255/204 -Df -W0.7p -P -B' maptics '  -K -S104/204/255 ' lf ' > sources.ps' ];
    fprintf(fid,'%s\r\n', pscoastr);
        sstring=['psxy -R ' j ' sources.gmt -S' symbolsize  ' -M  -W1p/0 -K -O -G255/0/0 >> sources.ps' ];
    fprintf(fid,'%s\r\n',sstring);
    
    if snumber == 1
        stextstr=['pstext -R ' j ' sources.txt -N -O -K -D' dxdy ' >> sources.ps' ];
    fprintf(fid,'%s\r\n',stextstr);
    else
    end
    
    %%%add extra psxy file here.....
    %% check if needed...
    
    if length(psxyfile) ~= 0
        disp(['adding file ' psxyfile])
            sstring=['psxy -R ' j '  ' psxyfile ' -S' symbolsize  ' -M  -W1p/0 -K -O -G0/0/255 >> sources.ps' ];
            fprintf(fid,'%s\r\n',sstring);
    
            sstring=['gawk "{ print $1,$2,"10","0","1","0",$3}"  ' psxyfile ' >  ' psxyfile '.gmt'  ];
            fprintf(fid,'%s\r\n',sstring);

            sstring=['pstext -R ' j '  ' psxyfile '.gmt -D0.2c/0c -K -O  >> sources.ps' ];
            fprintf(fid,'%s\r\n',sstring);

    else
         
    end
    
    
        fostring=['psmeca -R ' j ' -Sa' bbscale 'c beachb.foc -V -O -C1 -N >> sources.ps'];
    fprintf(fid,'%s\r\n',fostring);
            
         fclose(fid);
% 

% %%% run batch file...
% 
[s,r]=system('plsrc.bat');


cd ..     %%% return to main folder before plotting.... this should solve problems if user tried to plot waveforms before closing ps file...





% 
system('gsview32 .\gmtfiles\sources.ps');      
% 
% 
%%%%%%%%%%%%%%%%%%%output map values in isl file%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('sources.isl','w');
         fprintf(fid,'%s\r\n',num2str(mapscale));
         fprintf(fid,'%s\r\n',maptics);
         fprintf(fid,'%s\r\n',lscale);
         fprintf(fid,'%s\r\n',symbolsize);
         fprintf(fid,'%s\r\n',dxdy );
         fprintf(fid,'%s\r\n',num2str(fontsize));
         fprintf(fid,'%s\r\n',num2str(border) );
         fprintf(fid,'%s\r\n',num2str(scaleshift));
         fprintf(fid,'%s\r\n',num2str(fshiftor));
         fprintf(fid,'%s\r\n',num2str(xshift));
         fprintf(fid,'%s\r\n',bbscale);

fclose(fid);

%%%%%%%%%%%%%%%%

pwd

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.plsources)


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


% --- Executes during object creation, after setting all properties.
function bbscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bbscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function bbscale_Callback(hObject, eventdata, handles)
% hObject    handle to bbscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bbscale as text
%        str2double(get(hObject,'String')) returns contents of bbscale as a double


% --- Executes on button press in snumber.
function snumber_Callback(hObject, eventdata, handles)
% hObject    handle to snumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of snumber


% --- Executes on button press in addfile.
function addfile_Callback(hObject, eventdata, handles)
% hObject    handle to addfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[file1,path1] = uigetfile('*.*','Import a file with Lon, Lat, Name format');

TF=strcmp(path1,[pwd '\gmtfiles\']);

if TF==0
   disp(['Copying ' [path1 file1] ' to gmtfiles folder'])
   copyfile([path1 file1],'.\gmtfiles')
else
end
   
   
set(handles.filetoadd,'String',[path1 file1])
handles.file1=file1;
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function filetoadd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filetoadd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function filetoadd_Callback(hObject, eventdata, handles)
% hObject    handle to filetoadd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filetoadd as text
%        str2double(get(hObject,'String')) returns contents of filetoadd as a double




% --- Executes on button press in pltimspace.
function pltimspace_Callback(hObject, eventdata, handles)
% hObject    handle to pltimspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%
%%%%%read 
mapscale = str2double(get(handles.scalev,'String'));
maptics = get(handles.tics,'String');
lscale = get(handles.mscale,'String');
symbolsize = get(handles.symbolsize,'String');
dxdy = get(handles.dxdy,'String');
fontsize = str2double(get(handles.fsize,'String'));
border = str2double(get(handles.border,'String'));
scaleshift = str2double(get(handles.scaleshift,'String'));
fshift = str2double(get(handles.fshift,'String'));
xshift = str2double(get(handles.xshift,'String'));
bbscale=get(handles.bbscale,'String');
normfactor=str2double(get(handles.normf,'String'));
%
fixmoment=get(handles.fixmoment,'Value');
fmoment=str2double(get(handles.fmoment,'String'));
%
fshiftor=fshift;

snumber = get(handles.snumber,'Value');

psxyfile=get(handles.filetoadd,'String');
  
if ~isempty(psxyfile)
        file1=handles.file1;
else
end
  
  
normfactor=str2double(get(handles.normf,'String'));



%%%%%cpt file
val = get(handles.gmtpal,'Value');
string_list = get(handles.gmtpal,'String');
gmtpal = string_list{val};

%%

%%%%%%%%%find distance step
%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%       distep=fscanf(fid,'%f',1);
                noSourcesstrike=fscanf(fid,'%i',1);
                strikestep=fscanf(fid,'%i',1);
                noSourcesdip=fscanf(fid,'%i',1);
                dipstep=fscanf(fid,'%i',1);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%read inversion files%%%%%%%%inv2.dat and inv3.dat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if INVERT exists..!
h=dir('invert');

if isempty(h);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try

cd invert

h=dir('inv2.dat');

if isempty(h); 
    errordlg(['Inv2.dat file doesn''t exist. Run Invert and norm. '],'File Error');
    cd ..
  return    
else
    fid = fopen('inv2.dat','r');
    [srcpos2,srctime2,mom,s1,di1,r1,s2,di2,r2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f  %f %f %f',-1);
    fclose(fid);
%     cd ..
end

mommag=(2/3)*(log10(mom) - 9.1); %  mommag=(2/3)*(log10(mo(psrcpos)) - 9.1) Hanks & Kanamori (1979)

disp(['Maximum moment is ' num2str(max(mom),'%11.4e') ])

%%% go back
cd ..

catch
    disp('error reading inv2 files...')
    cd ..
end

%%%check the sources.gmt in gmtfiles
pwd

cd gmtfiles

h=dir('sources.gmt');

if isempty(h); 
  errordlg('Sources.gmt file doesn''t exist. Run Source definition. ','File Error');
  return
else
   
%%%%read coordinates.....
 if source_gmtfile==0

     fid  = fopen('sources.gmt','r');
      [lon,lat,depth,sourceno] = textread('sources.gmt','%f %f %f %f',nsources,'headerlines',1);
     fclose(fid);

 elseif source_gmtfile==1
     
     fid  = fopen('sources.gmt','r');
      [lon,lat,scale,depth,sourceno,char] = textread('sources.gmt','%f %f %f %f %f %s',nsources);
     fclose(fid);
 end

end


%USE SOURCE COORDINATES AND SOURCE NUMBER TO FIND SUB  SOURCE
%COORDINATES
%[srcpos2,srctime2,mom,s1,di1,r1,s2,di2,r2,dc,varred] = textread('inv2.dat','%f %f %f %f %f %f %f %f %f %f %f',-1)

% whos srcpos2 sourceno

 for i=1:length(srcpos2);
     for j=1:length(sourceno);
         if  srcpos2(i,1) == sourceno(j,1)
             srclon(i,1) = lon(j,1);   %%%%Longitude 
             srclat(i,1) = lat(j,1);   %%%%Longitude
             depth(i,1)  = depth(j,1);    %%%%Depth
         end    
     end
 end

%%
fprintf('%s\t  %s\t  %s\t %s\t %s\t %s\t  %s\t  %s\t  %s\t  %s\n',' LON', '      LAT', '     Depth','Source', 'Time (sec)', 'Moment Nm','Cumul. Moment Nm','Varred','Cumul.Varred','Circle diameter according to scaling factor (cm)');

cmom=0;
cvar=0;
for i=1:length(srcpos2);   
    
%disp([num2str(srclon(i,1)) ' ' num2str(srclat(i,1)) ' ' num2str(sourceno(i,1)) ' ' num2str(srcpos2(i,1)) ' ' num2str(srctime2(i,1)) ' ' num2str(mom(i,1),'%10.3e')])
cmom=cmom+mom(i,1);
cvar=cvar+varred(i,1);

fprintf( '%9.5f\t %9.5f\t %9.5f\t %3u\t %8.3f\t %10.3e\t  %10.3e\t  %10.3f\t %10.3f\t %10.3f\n',srclon(i,1), srclat(i,1),depth(i,1), srcpos2(i,1), srctime2(i,1), mom(i,1),cmom,varred(i,1),cvar,mom(i,1)/normfactor)

end

%%
fid = fopen('timspc.dat','w');
 for i=1:length(srcpos2)                                                   % ((9.638e-6*$9)**0.33)/50000
      fprintf(fid,'%g  %g  %g %e\r\n',srclon(i,1),srclat(i,1),srctime2(i,1),mom(i,1)/normfactor);           %((9.638e-6*mom(i,1))^0.33)/normfactor  );  %'    ' num2str(mom(i,1),'%5.2e')]);
  end
fclose(fid);
%% find maximum moment
if fixmoment==1
     maxmoment=fmoment;
else
     maxmoment=max(mom(:,1));
end

%%
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

j=[' -JM' num2str(mapscale) 'ch'];

centy=((nend-send)/2)+send;
centx=((eend-wend)/2)+wend;
%ly=(((nend-send)/2)+send)-(border-scaleshift);

ly=s+scaleshift;

%%%make -L
lf=['-Lf' num2str(centx,'%7.2f') '/' num2str(ly,'%7.4f') '/' num2str(centy,'%7.2f') '/' lscale '+l'];

xshift=-xshift;

  
    fid = fopen('pltimspc.bat','w');
    
    fprintf(fid,'%s\r\n','gmtset PLOT_DEGREE_FORMAT D  ANNOT_FONT_SIZE_PRIMARY 12 ANNOT_FONT_SIZE_SECONDARY 12 HEADER_FONT_SIZE 14 LABEL_FONT_SIZE 14');
    fprintf(fid,'%s\r\n',' ');
    pscoastr=['pscoast ' r   j ' -G255/255/204 -Df -W0.7p -P -B' maptics '  -K -Slightblue ' lf ' > timspc.ps' ];
    fprintf(fid,'%s\r\n', pscoastr);
    fprintf(fid,'%s\r\n',' ');
    sstring=['psxy -R ' j ' sources.gmt -S' symbolsize  ' -M  -W1p/0 -K -O -G255/0/0 >> timspc.ps' ];
    fprintf(fid,'%s\r\n',sstring);
    fprintf(fid,'%s\r\n',' ');
    
      if snumber == 1   % plot trial source number
              fid2 = fopen('sources.txt','w');
                  for i=1:length(lon)
                       fprintf(fid2,'%g  %g  %g  %g  %g  %s %g\r\n',lon(i),lat(i),fontsize,0,1,'CM',sourceno(i));
                  end     
              fclose(fid2);
              
           stextstr=['pstext sources.txt -R ' j '  -N -O -K -D' dxdy ' >> timspc.ps' ];   % fixed ...
           fprintf(fid,'%s\r\n',stextstr);
           
        else
      end
    
    %%%add extra psxy file here.....
    %% check if needed...
    
    if ~isempty(psxyfile)
        disp(['adding file ' file1])
            fprintf(fid,'%s\r\n',' ');
            sstring=['psxy -R -J ' file1 ' -S' symbolsize  ' -M  -W1p/0 -K -O -G0/0/255 >> timspc.ps' ];
            fprintf(fid,'%s\r\n',sstring);
            sstring=['gawk "{ print $1,$2,"10","0","1","0",$3}"  ' file1 ' | pstext -R -J -D0.2c/0c -K -O  >> timspc.ps' ];
            fprintf(fid,'%s\r\n',sstring);

    else
         
    end

%        add legend 
        fprintf(fid,'%s\r\n',['echo  ' num2str(centx,'%7.5f') '  '  num2str(n-border/3,'%7.5f') '   '  num2str(maxmoment/normfactor,'%10.3e')   '  | psxy  -R -J -Scc -W3p -N  -K -O  >>   timspc.ps']);
        fprintf(fid,'%s\r\n',' ');
        fprintf(fid,'%s\r\n',['echo  ' num2str(centx,'%7.5f') '  '  num2str(n-border/3,'%7.5f') '   '   '10 0 1 LT Max Mo='  num2str(maxmoment,'%10.3e')   'Nm | pstext -D1c/0c  -R -J -Wwhite,o  -N -K -O  >> timspc.ps']);  
        fprintf(fid,'%s\r\n',' ');
%     
       fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T' num2str(min(srctime2)-1) '/' num2str(max(srctime2)+1) '/1    > time.cpt']);
       fprintf(fid,'%s\r\n',' ');
       fprintf(fid,'%s\r\n','psxy  timspc.dat  -R -J -Sc -Ctime.cpt -W-3p -N -V -O -K   >> timspc.ps');
       fprintf(fid,'%s\r\n',' ');
       fprintf(fid,'%s\r\n',['psscale -D' num2str(mapscale/2) 'c/' num2str(mapscale+4) 'c/7.5c/.5ch -O -Ctime.cpt   -B2:"Rupture Time (sec)":/:: >> timspc.ps']);
       fprintf(fid,'%s\r\n',' ');
       fprintf(fid,'%s\r\n','ps2raster timspc.ps -Tg -P -E75 -Qg2  -Qt2 -D..\output' );
 
       
       
            
       fclose(fid);

%% 
%  map values in isl file%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('sources.isl','w');
         fprintf(fid,'%s\r\n',num2str(mapscale));
         fprintf(fid,'%s\r\n',maptics);
         fprintf(fid,'%s\r\n',lscale);
         fprintf(fid,'%s\r\n',symbolsize);
         fprintf(fid,'%s\r\n',dxdy );
         fprintf(fid,'%s\r\n',num2str(fontsize));
         fprintf(fid,'%s\r\n',num2str(border) );
         fprintf(fid,'%s\r\n',num2str(scaleshift));
         fprintf(fid,'%s\r\n',num2str(fshiftor));
         fprintf(fid,'%s\r\n',num2str(xshift));
         fprintf(fid,'%s\r\n',bbscale);
         fprintf(fid,'%s\r\n',normfactor);
fclose(fid);

%%
% %%% run batch file...
% % 
[s,r]=system('pltimspc.bat');

cd ..     %%% return to main folder before plotting.... this should solve problems if user tried to plot waveforms before closing ps file...
% 
system('gsview32 .\gmtfiles\timspc.ps');      

%%%%%%%%%%%%%%%%






function normf_Callback(hObject, eventdata, handles)
% hObject    handle to normf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of normf as text
%        str2double(get(hObject,'String')) returns contents of normf as a double


% --- Executes during object creation, after setting all properties.
function normf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to normf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in gmtpal.
function gmtpal_Callback(hObject, eventdata, handles)
% hObject    handle to gmtpal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns gmtpal contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gmtpal


% --- Executes during object creation, after setting all properties.
function gmtpal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gmtpal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fixmoment.
function fixmoment_Callback(hObject, eventdata, handles)
% hObject    handle to fixmoment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fixmoment



function fmoment_Callback(hObject, eventdata, handles)
% hObject    handle to fmoment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fmoment as text
%        str2double(get(hObject,'String')) returns contents of fmoment as a double


% --- Executes during object creation, after setting all properties.
function fmoment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fmoment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
