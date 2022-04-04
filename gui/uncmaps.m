function varargout = uncmaps(varargin)
% UNCMAPS M-file for uncmaps.fig
%      UNCMAPS, by itself, creates a new UNCMAPS or raises the existing
%      singleton*.
%
%      H = UNCMAPS returns the handle to a new UNCMAPS or the handle to
%      the existing singleton*.
%
%      UNCMAPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNCMAPS.M with the given input arguments.
%
%      UNCMAPS('Property','Value',...) creates a new UNCMAPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before uncmaps_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to uncmaps_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help uncmaps

% Last Modified by GUIDE v2.5 18-Apr-2015 12:16:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uncmaps_OpeningFcn, ...
                   'gui_OutputFcn',  @uncmaps_OutputFcn, ...
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


% --- Executes just before uncmaps is made visible.
function uncmaps_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to uncmaps (see VARARGIN)

% Choose default command line output for uncmaps
handles.output = hObject;
%%
disp('This is uncmaps.m')

%%
%check if unc_maps exists..!
fh=exist('unc_maps','dir');

if (fh~=7);
    errordlg('unc_maps folder doesn''t exist. ISOLA will create it. ','Folder warning');
    mkdir('unc_maps');
end

%%
% Check if we have plot options
if exist('uncmaps.isl','file'); 

    fid = fopen('uncmaps.isl','r');
    
            stationfile=fscanf(fid,'%s',1);
            depth=fscanf(fid,'%s',1);
            gridspc=fscanf(fid,'%s',1);
            fmax=fscanf(fid,'%s',1);
            tl=fscanf(fid,'%s',1);
            f1=fscanf(fid,'%s',1);
            f2=fscanf(fid,'%s',1);
            f3=fscanf(fid,'%s',1);
            f4=fscanf(fid,'%s',1);
            vardat=fscanf(fid,'%s',1);
            str=fscanf(fid,'%s',1);
            dip=fscanf(fid,'%s',1);
            rake=fscanf(fid,'%s',1);
            mo=fscanf(fid,'%s',1);
            orlon=fscanf(fid,'%f',1);
            orlat=fscanf(fid,'%f',1);

            fclose(fid);
% update handles
        set(handles.selectedfile,'String',stationfile);
        set(handles.depth,'String',depth);
        set(handles.gridspc,'String',gridspc);
        set(handles.fmax,'String',fmax);
        set(handles.tltext,'String',tl);
        set(handles.f1,'String',f1);
%         set(handles.f2,'String',f2);
%         set(handles.f3,'String',f3);
        set(handles.f4,'String',f4);
        set(handles.vardat,'String',vardat);
        set(handles.strike,'String',str);
        set(handles.dip,'String',dip);
        set(handles.rake,'String',rake);
        set(handles.mom,'String',mo);


else
       disp('uncmaps.isl not found')
        set(handles.depth,'String','10');
       orlon=0;
       orlat=0;
end

        
        handles.orlon=orlon;
        handles.orlat=orlat;
       %Update handles structure
        guidata(hObject, handles);

% UIWAIT makes uncmaps wait for user response (see UIRESUME)
% uiwait(handles.uncmaps);


% --- Outputs from this function are returned to the command line.
function varargout = uncmaps_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% check if station coordinate file exists

fullstationfile=get(handles.selectedfile,'String');

cd unc_maps
 
if isempty(fullstationfile) % check if file exists..!
    disp('station file not specified')
  
  
fh2=exist('kagan_map.dat','file');
if (fh2~=2);
    errordlg('kagan_map.dat doesn''t exist. Please run the code first. ','File Error');
   delete(handles.uncmaps)
end

plkag=load('kagan_map.dat');

minlon=min(plkag(:,1));
maxlon=max(plkag(:,1));
minlat=min(plkag(:,2));
maxlat=max(plkag(:,2));

%[LON,LAT]=meshgrid(minlon:maxlon,minlat:maxlat)
% find grid step, check kagan_map file for change in lon value
ind=find(plkag(:,1)~=plkag(1,1),1,'first');

lonstep=abs((abs(maxlon)-abs(minlon))/(ind-2));
latstep=abs((abs(maxlat)-abs(minlat))/(ind-2));

[LON,LAT]=meshgrid(minlon:lonstep:maxlon,minlat:latstep:maxlat);

mean_grid = griddata(plkag(:,1),plkag(:,2),plkag(:,3),LON,LAT);
std_grid  = griddata(plkag(:,1),plkag(:,2),plkag(:,4),LON,LAT);
med_grid  = griddata(plkag(:,1),plkag(:,2),plkag(:,5),LON,LAT);

 
% [cs,h]=m_contour(LON,LAT,plkag(:,3));
% clabel(cs,h,'fontsize',8);
% xlabel('Simulated something else');

 figure

%subplot(131)
%subplot('Position',[0.1 0 0.3 1])
%ubplot('Position',[left bottom width height])
m_proj('Mercator','long',[minlon maxlon],'lat',[minlat maxlat]);
m_pcolor(LON,LAT,mean_grid);shading flat;

% colormap(hot);colorbar 
  cm=flipud(hot);
  colormap(cm);
  colorbar;

m_coast('color','blue');
m_ruler([0.1 0.4],0.08,2);

title('Kagan angle')

%m_grid('tickdir','out','yaxislocation','right',...
%       'xaxislocation','top','xlabeldir','end','ticklen',.02);
%m_gshhs_h('color','k');

% figure
% 
% m_proj('Mercator','long',[19 31],'lat',[34 42]);
% m_coast('patch',[.7 .7 .7]);
% m_line(21,39,'marker','square','markersize',15,'color','b');
% m_grid('box','fancy','tickdir','out');
% hold
%m_plot(17.5,48.5,'marker','square','markersize',15,'color','b');
% 
% for i=1:length(stalat)
%  m_plot(stalon(i),stalat(i),'marker','square','markersize',7,'color','b','MarkerFaceColor','b');
%  m_text(stalon(i),stalat(i),staname(i),'vertical','top');
% end
% m_grid('box','fancy','tickdir','out');
%  
% 
% %subplot(132)
% subplot('Position',[0.4 0 0.3 1])
% m_proj('mercator','lon',[minlon maxlon],'lat',[minlat maxlat]);
% m_pcolor(LON,LAT,std_grid);shading flat;colormap(hot);colorbar 
% hold on
% m_coast('color',[.9 .9 .9]);
% %m_grid('tickdir','out','yaxislocation','right',...
% %       'xaxislocation','top','xlabeldir','end','ticklen',.02);
% m_grid('box','fancy','tickdir','out');
% title('SD')
% 
% %subplot(133)
% subplot('Position',[0.7 0 0.3 1])
% m_proj('mercator','lon',[minlon maxlon],'lat',[minlat maxlat]);
% m_pcolor(LON,LAT,med_grid);shading flat;colormap(hot);colorbar 
% hold on
% m_coast('color',[.9 .9 .9]);
% % m_grid('tickdir','out','yaxislocation','right',...
% %        'xaxislocation','top','xlabeldir','end','ticklen',.02);
% m_grid('box','fancy','tickdir','out');
% title('Median')

else  % station file exists..
    
    
%% read data in 3 arrays from station file
fid  = fopen(fullstationfile,'r');
 C= textscan(fid,'%s %f %f',-1);
fclose(fid);
staname=C{1};
stalat=C{2};
stalon=C{3};

%%

%check if file exists..!
fh2=exist('kagan_map.dat','file');
if (fh2~=2);
    errordlg('kagan_map.dat doesn''t exist. Please run the code first. ','File Error');
   delete(handles.uncmaps)
end

plkag=load('kagan_map.dat');

minlon=min(plkag(:,1));
maxlon=max(plkag(:,1));
minlat=min(plkag(:,2));
maxlat=max(plkag(:,2));

minkag=min(plkag(:,3));
maxkag=max(plkag(:,3));

latspan=maxlat-minlat;
lonspan=maxlon-minlon;

%[LON,LAT]=meshgrid(minlon:maxlon,minlat:maxlat)
% find grid step, check kagan_map file for change in lon value
ind=find(plkag(:,1)~=plkag(1,1),1,'first');

% lonstep=(abs(maxlon)-abs(minlon))/(ind-2);
% latstep=(abs(maxlat)-abs(minlat))/(ind-2);
lonstep=abs((abs(maxlon)-abs(minlon))/(ind-2));
latstep=abs((abs(maxlat)-abs(minlat))/(ind-2));

[LON,LAT]=meshgrid(minlon:lonstep:maxlon,minlat:latstep:maxlat);

mean_grid = griddata(plkag(:,1),plkag(:,2),plkag(:,3),LON,LAT);
% std_grid  = griddata(plkag(:,1),plkag(:,2),plkag(:,4),LON,LAT);
% med_grid  = griddata(plkag(:,1),plkag(:,2),plkag(:,5),LON,LAT);

 
% [cs,h]=m_contour(LON,LAT,plkag(:,3));
% clabel(cs,h,'fontsize',8);
% xlabel('Simulated something else');

 figure

%subplot(131)
%subplot('Position',[0.1 0 0.3 1])
%ubplot('Position',[left bottom width height])
m_proj('Mercator','long',[minlon maxlon],'lat',[minlat maxlat]);
%mean_grid=[[mean_grid nan*zeros(size(mean_grid,1),1)] ; nan*zeros(1,size(mean_grid,2)+1)];
%LON=[[LON nan*zeros(size(LON,1),1)] ; nan*zeros(1,size(LON,2)+1)];
%LAT=[[LAT nan*zeros(size(LAT,1),1)] ; nan*zeros(1,size(LAT,2)+1)];

whos LON LAT mean_grid

m_pcolor(LON,LAT,mean_grid);
  
shading flat;
% colormap(hot);colorbar 
  cm=flipud(hot);
  colormap(cm);
  colorbar;
m_coast('color','blue');
m_ruler([0.1 0.4],0.08,2);
%m_grid('tickdir','out','yaxislocation','right',...
%       'xaxislocation','top','xlabeldir','end','ticklen',.02);
%m_gshhs_h('color','k');

% figure
% 
% m_proj('Mercator','long',[19 31],'lat',[34 42]);
% m_coast('patch',[.7 .7 .7]);
% m_line(21,39,'marker','square','markersize',15,'color','b');
% m_grid('box','fancy','tickdir','out');
hold
%m_plot(17.5,48.5,'marker','square','markersize',15,'color','b');

for i=1:length(stalat)
 m_plot(stalon(i),stalat(i),'marker','^','markersize',7,'color','b','MarkerFaceColor','b');
 m_text(stalon(i)+0.1,stalat(i),staname(i),'VerticalAlignment','middle','HorizontalAlignment','left','FontWeight','bold');
end
m_grid('box','fancy','tickdir','out');


% gplon=plkag(:,1);gplat=plkag(:,2);
% 
%  for i=1:length(gplon)
%   m_plot(gplon(i),gplat(i),'marker','+','markersize',6,'color','k','MarkerFaceColor','k');
%  end
%  
%  whos LON LAT
%  for k=1:length(LON)*length(LAT)
%      % m_plot(LON(i),LAT(j),'marker','*','markersize',6,'color','g','MarkerFaceColor','g');
%      gridlon(k)=LON(k);
%      gridlat(k)=LAT(k);
%          k=k+1;
%  end 
% 
%  for i=1:length(LON)*length(LAT)
%       m_plot(gridlon(i),gridlat(i),'marker','*','markersize',6,'color','g','MarkerFaceColor','g');
%  end
%    
 
 
%text
title('Kagan angle')

%% make a GMT script for plotting the map of Kagan angle
  fid = fopen('plkaganmap.bat','w');
  
    if ispc      
      fprintf(fid,'%s\r\n','del .gmt*');
      fprintf(fid,'%s\r\n',' ');
      fprintf(fid,'%s\r\n','gmtset PAPER_MEDIA A4 PLOT_DEGREE_FORMAT D CHAR_ENCODING ISOLatin1+');
      fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 12 ANNOT_FONT_SIZE_SECONDARY 12 HEADER_FONT_SIZE 14 LABEL_FONT_SIZE 14');
      fprintf(fid,'%s\r\n',' ');
    else
      fprintf(fid,'%s\n','rm .gmt*');
      fprintf(fid,'%s\n',' ');
      fprintf(fid,'%s\n','gmtset PAPER_MEDIA A4 PLOT_DEGREE_FORMAT D CHAR_ENCODING ISOLatin1+');
      fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 12 ANNOT_FONT_SIZE_SECONDARY 12 HEADER_FONT_SIZE 14 LABEL_FONT_SIZE 14');
      fprintf(fid,'%s\n',' ');
    end


   % make -R
   r=['-R' num2str(minlon,'%7.5f') '/' num2str(maxlon,'%7.5f') '/' num2str(minlat,'%7.5f') '/' num2str(maxlat,'%7.5f') ' '];
   % make -J
   proj=' -JM16c+';
   
[mapticsla,mapticslo,L,scaleloc]=guessgmtvalues(minlon,maxlon,minlat,maxlat);


 %L=[' -Lf' num2str((lonspan/2)+minlon) '/' num2str(minlat+(0.07*latspan)) '/'  num2str((latspan/2)+minlat) '/' num2str(200) '+l'];   
   
   
   fprintf(fid,'%s\r\n','REM prepare the GRD file ');
   string1=['gawk "{print $1,$2,$3}" kagan_map.dat | xyz2grd -Gkaganmap.grd -V -I' num2str(lonstep) '/' num2str(latstep)  ' ' r ];
   fprintf(fid,'%s\r\n',string1);

   fprintf(fid,'%s\r\n',' ');
   fprintf(fid,'%s\r\n','REM prepare the color palette file ');
   string2=['makecpt -Chot.cpt -I -T' num2str(minkag) '/' num2str(maxkag) '/1 > kagan.cpt' ];
%   string2=['makecpt -Chot.cpt -I -T0/' num2str(maxkag) '/5 > kagan.cpt' ];

   fprintf(fid,'%s\r\n',string2);

   fprintf(fid,'%s\r\n',' ');
   fprintf(fid,'%s\r\n','REM plot the GRD file');
   string3=['grdimage kaganmap.grd ' proj ' -Ckagan.cpt -B' num2str(mapticslo) 'g' num2str(mapticslo) '/' num2str(mapticsla) 'g' num2str(mapticsla) ' -K > kaganmap.ps'];
   fprintf(fid,'%s\r\n',string3);

   fprintf(fid,'%s\r\n',' ');
   fprintf(fid,'%s\r\n','REM plot coastlines ');
   string4=['pscoast -R -J   -Df -W0.7p   -K  -O  ' L ' >> kaganmap.ps'] ;
   fprintf(fid,'%s\r\n',string4);

   fprintf(fid,'%s\r\n',' ');
   fprintf(fid,'%s\r\n','REM plot stations ');
%  add stations
   string5=['gawk "{print $3,$2}" ' fullstationfile '| psxy -R -J -Gblue -St0.4c -K  -O >> kaganmap.ps' ];
   fprintf(fid,'%s\r\n',string5);
   string6=['gawk "{print $3,$2,12,0,1,1,$1}" ' fullstationfile '| pstext -R -J -Gblue -D0.1c -K  -O >> kaganmap.ps' ];
   fprintf(fid,'%s\r\n',string6);

   fprintf(fid,'%s\r\n',' ');
   fprintf(fid,'%s\r\n','REM plot the color bar ');
%  color scale
   string7=['psscale -D' num2str(scaleloc) 'c/8c/10c/.5c -O -Ckagan.cpt -B10:"Kagan angle (\260)":/:: >> kaganmap.ps'];
   fprintf(fid,'%s\r\n',string7);

   fprintf(fid,'%s\r\n',' ');
   fprintf(fid,'%s\r\n','REM export to PNG');
   fprintf(fid,'%s\r\n','ps2raster kaganmap.ps -A -P -Tg ');

fclose(fid);




end


cd ..


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
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text4 as text
%        str2double(get(hObject,'String')) returns contents of text4 as a double


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mom_Callback(hObject, eventdata, handles)
% hObject    handle to mom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mom as text
%        str2double(get(hObject,'String')) returns contents of mom as a double


% --- Executes during object creation, after setting all properties.
function mom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% prepare an isl file with options
% get options

stationfile=get(handles.selectedfile,'String');

%seldepth=getappdata(uncmaps,'seldepth');
sellon=getappdata(uncmaps,'sellon');
sellat=getappdata(uncmaps,'sellat');

%depth=get(handles.depth,'String');

try
  cd unc_maps
     
     fid = fopen('allsrc.dat','r');
    
       tmp=sscanf(fgetl(fid),'%f');
       depth=num2str(tmp(3));
     fclose(fid);
     
  cd ..
  
catch
    depth='10';
end

gridspc=get(handles.gridspc,'String');

maxfreq=get(handles.fmax,'String');
tl=get(handles.tltext,'String');

f1=get(handles.f1,'String');
f2=get(handles.f1,'String');
f3=get(handles.f4,'String');
f4=get(handles.f4,'String');

vardat=get(handles.vardat,'String');

str=get(handles.strike,'String');
dip=get(handles.dip,'String');
rake=get(handles.rake,'String');
mo=get(handles.mom,'String');


        fid = fopen('uncmaps.isl','w');
          if ispc
               fprintf(fid,'%s\r\n',stationfile);
               fprintf(fid,'%s\r\n',depth);
               fprintf(fid,'%s\r\n',gridspc);
               fprintf(fid,'%s\r\n',maxfreq);
               fprintf(fid,'%s\r\n',tl);
               fprintf(fid,'%s\r\n',f1);
               fprintf(fid,'%s\r\n',f2);
               fprintf(fid,'%s\r\n',f3);
               fprintf(fid,'%s\r\n',f4);
               fprintf(fid,'%s\r\n',vardat);
               fprintf(fid,'%s\r\n',str);
               fprintf(fid,'%s\r\n',dip);
               fprintf(fid,'%s\r\n',rake);
               fprintf(fid,'%s\r\n',mo);
               fprintf(fid,'%f\r\n',sellon);
               fprintf(fid,'%f\r\n',sellat);
          else
               fprintf(fid,'%s\n',stationfile);
               fprintf(fid,'%s\n',depth);
               fprintf(fid,'%s\n',gridspc);
               fprintf(fid,'%s\n',maxfreq);
               fprintf(fid,'%s\n',tl);
               fprintf(fid,'%s\n',f1);
               fprintf(fid,'%s\n',f2);
               fprintf(fid,'%s\n',f3);
               fprintf(fid,'%s\n',f4);
               fprintf(fid,'%s\n',vardat);
               fprintf(fid,'%s\n',str);
               fprintf(fid,'%s\n',dip);
               fprintf(fid,'%s\n',rake);
               fprintf(fid,'%s\n',mo);
               fprintf(fid,'%f\r\n',sellon);
               fprintf(fid,'%f\r\n',sellat);
          end
        fclose(fid);


%%
delete(handles.uncmaps)


% --- Executes on button press in stafile.
function stafile_Callback(hObject, eventdata, handles)
% hObject    handle to stafile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [stationfile, newdir] = uigetfile('*.stn;*.dat;*.txt', 'Select seismic station file');
   
    if stationfile == 0
       disp('Cancel file load')
       return
    else
       [status, message] = copyfile([newdir stationfile],'.');    
    end

    
    copyfile([newdir stationfile],'.\unc_maps')
    
   
set(handles.selectedfile,'String',stationfile)


% --- Executes on button press in origin.
function origin_Callback(hObject, eventdata, handles)
% hObject    handle to origin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


fullstationfile=get(handles.selectedfile,'String');
%gridspc=str2num(get(handles.gridspc,'String'));
gridspc=str2num(get(handles.gridspc,'String'));
depth=str2num(get(handles.depth,'String'));

orlon=handles.orlon;
orlat=handles.orlat;


% FIXED
ngrdx=9;ngrdy=9;

%read data in 3 arrays
fid  = fopen(fullstationfile,'r');
 C= textscan(fid,'%s %f %f',-1);
fclose(fid);
staname=C{1};
stalat=C{2};
stalon=C{3};

%% find limits
 
[left,right,down,up]=findlimits_uncmaps(stalon,stalat, 2);

%% Plotting
bdwidth = 5;
topbdwidth = 100;
set(0,'Units','pixels') 
scnsize = get(0,'ScreenSize');
pos1  = [bdwidth+topbdwidth,topbdwidth,...
    scnsize(3)*2/3 - 2*bdwidth,...
    scnsize(4)*2/3 - (topbdwidth + bdwidth)];



% prepare figure      
hh1=figure('Position',pos1,'Name','map','Toolbar','figure','Tag','Origin');


uipanel('Title','Grid spacing and source depth','BackgroundColor',get(hh1,'color'),'FontSize',11, 'Position', [.01 .75 .2 .25],'Units','normalized');

uicontrol('Style', 'text', 'String', 'Grid Spacing (degrees)','BackgroundColor',get(hh1,'color'),'FontSize',11,'Units','normalized','Position', [0.02 .85 .08 .1]);            %%%% grid spacing label....

uicontrol('Style', 'edit', 'String', '0.4','Tag','gspc','FontSize',11,'BackgroundColor',[1 1 1],'Units','normalized','Position', [0.035 .8 .05 .05]);  %%%% grid spacing....

uicontrol('Style', 'text', 'String', 'Depth of Trial sources','BackgroundColor',get(hh1,'color'),'FontSize',11,'Units','normalized','Position', [.1 .85 .1 .1]);    %%% depth label....
uicontrol('Style', 'edit', 'String', num2str(depth),'Tag','depth','FontSize',11,'BackgroundColor',[1 1 1],'Units','normalized','Position', [0.12 .8 .05 .05]);  %%% depth....

% uicontrol('Style', 'frame', 'String', 'Specify origin by Lat and Lon',...
%      'Position', [.0 .83 .2 .03],'BackgroundColor',get(hh1,'color'),'FontSize',11,'Units','normalized');    %%% depth label....

uipanel('Title','Specify origin by Lat and Lon','BackgroundColor',get(hh1,'color'),'FontSize',11, 'Position', [.01 .46 .2 .28],'Units','normalized');

% uicontrol('Style', 'text', 'String', 'Specify origin by Lat and Lon',...
%      'Position', [.0 .83 .2 .03],'BackgroundColor',get(hh1,'color'),'FontSize',11,'Units','normalized');    %%% depth label....

uicontrol('Style', 'pushbutton', 'String', 'Specify Origin Numerically', 'Callback', 'forig3','FontSize',11,'Units','normalized','Position', [.03 .48 .15 .05]);                        %%%% Specify origin....

uicontrol('Style', 'edit', 'String', num2str(orlat),'Tag','lat','FontSize',11,'BackgroundColor',[1 1 1],'Units','normalized','Position', [.03 .58 .05 .05]);        %%%%lat....
uicontrol('Style', 'text', 'String', 'Lat','BackgroundColor',get(hh1,'color'),'FontSize',11 ,'Units','normalized', 'Position', [.03 .62 .05 .05]);                        %%%% lat label....

uicontrol('Style', 'edit', 'String', num2str(orlon),'Tag','lon','FontSize',11,'BackgroundColor',[1 1 1],'Units','normalized','Position', [.1 .58 .05 .05]);    %%%% lon....
uicontrol('Style', 'text', 'String', 'Lon','BackgroundColor',get(hh1,'color'),'FontSize',11,'Units','normalized','Position', [.1 .62 .05 .05]);        %%%% lon label....
  
%
uipanel('Title','Specify origin by mouse','BackgroundColor',get(hh1,'color'),'FontSize',11,'Units','normalized','Position', [.01 .14 .2 .32]);
uicontrol('Style', 'pushbutton', 'String', 'Specify Origin by mouse', 'Callback', 'forig','FontSize',11,'Units','normalized','Position', [.03 .35 .15 .05]);                          %%%% Select origin....

uicontrol('Style', 'pushbutton', 'String', 'Reset', 'Callback', 'forig2','FontSize',11,'Units','normalized','Position', [.03 .27 .15 .05]);                            %%%%run the code to select stations....

uicontrol('Style', 'text', 'String', 'Left mouse button to select','BackgroundColor',get(hh1,'color'),'FontSize',10,'Units','normalized','Position', [.03 .15 .15 .1]);    %%% depth label....
uicontrol('Style', 'text', 'String', 'Right mouse button to stop','BackgroundColor',get(hh1,'color'),'FontSize',10,'Units','normalized','Position', [.03 .15 .15 0.05]);    %%% depth label....
 
 
uicontrol('Style', 'pushbutton', 'String', 'Exit', 'Callback', 'saveandexit','FontSize',11,'Units','normalized','Position', [.05 .02 .08 .1]);                       %%%%exit....

%subplot(131)
%subplot('Position',[0.1 0 0.3 1])
%ubplot('Position',[left bottom width height])
m_proj('Mercator','long',[left right],'lat',[down up]);
m_coast('color',[0 0 0]);
hold

for i=1:length(stalat)
 m_plot(stalon(i),stalat(i),'^','markersize',7,'color','r','MarkerFaceColor','r');
 m_text(stalon(i),stalat(i),staname(i),'vertical','top');
end
m_grid('box','fancy','tickdir','out');
 

% create structure of handles
handles1 = guihandles(hh1); 
handles1.staname=staname;
handles1.stalat=stalat;
handles1.stalon=stalon;
handles1.gridspc=gridspc;
handles1.ngrdx=ngrdx;
handles1.ngrdy=ngrdy;
%handles1.depth=depth;
handles1.left=left;
handles1.right=right;
handles1.down=down;
handles1.up=up;
%handles1.depth=depth;
handles1.originlon=orlon;
handles1.originlat=orlat;
guidata(hh1, handles1);

% minlon=min(stalon);
% maxlon=max(stalon);
% minlat=min(stalat);
% maxlat=max(stalat);



function gridspc_Callback(hObject, eventdata, handles)
% hObject    handle to gridspc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gridspc as text
%        str2double(get(hObject,'String')) returns contents of gridspc as a double


% --- Executes during object creation, after setting all properties.
function gridspc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridspc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in crgreen.
function crgreen_Callback(hObject, eventdata, handles)
% hObject    handle to crgreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% READ Fmax...and find number of frequencies
fmax = str2double(get(handles.fmax,'String'));
% find TL
tl = str2double(get(handles.tltext,'String'));
%%%compute df step in frequency..
disp('Frequency step')
df=1/tl
disp('Number of Frequencies')
nfreq=fmax/df

pwd


cd unc_maps

% find no of stations
    fid = fopen('nstations.isl','r');
          nstations=fscanf(fid,'%u',1);
    fclose(fid);
    
%% 
% check the type of Time Function
if get(handles.delta,'Value') == get(handles.delta,'Max')
    disp('Delta Time function selected')
    istype=1;  
elseif get(handles.triangle,'Value') == get(handles.triangle,'Max')
    disp('Delta Time function selected')
    istype=2;
    t0 = str2double(get(handles.sdur,'String'));
else
    %%% case nothing is selected....!!
    errordlg('Please select type of time function','!! Error !!')
    return
end
%% make soutype
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

%%
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
%finished with grdat.hed



%%
nsources=81;

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
          
%%  RUN the batch files
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

   
elseif strcmp(button,'No')
   disp('Green function generation canceled')
end



cd ..




% --- Executes on button press in calc.
function calc_Callback(hObject, eventdata, handles)
% hObject    handle to calc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


f1 = str2double(get(handles.f1,'String'));
f2 = str2double(get(handles.f1,'String'));
f3 = str2double(get(handles.f4,'String'));
f4 = str2double(get(handles.f4,'String'));

dt = (str2double(get(handles.tltext,'String')))/8192;
vardat = get(handles.vardat,'String');


strike = str2double(get(handles.strike,'String'));
dip = str2double(get(handles.dip,'String'));
rake = str2double(get(handles.rake,'String'));
xmoment = str2double(get(handles.mom,'String'));

 
%%

cd unc_maps

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

%% write
if ispc
  fid = fopen('inpinv.dat','w');
    fprintf(fid,'%s\r\n','    mode of inversion: 1=full MT, 2=deviatoric MT (recommended), 3= DC MT, 4=known fixed DC MT');
    fprintf(fid,'%i\r\n',1);
    fprintf(fid,'%s\r\n','    time step of XXXRAW.DAT files (in sec)');
    fprintf(fid,'%g\r\n',dt);
    fprintf(fid,'%s\r\n','    number of trial source positions (isourmax), max. 51');
    fprintf(fid,'%i\r\n',81);
    fprintf(fid,'%s\r\n','    trial time shifts (max. 100 shifts): from (>-2500), step, to (<2500)');
    fprintf(fid,'%s\r\n','    example: -10,5,50 means -10dt to 50dt, step = 5dt, i.e. 12 shifts');
    fprintf(fid,'%i %i %i\r\n',-10, 5, 50);
    fprintf(fid,'%s\r\n','    number of subevents to be searched (isubmax), max. 20');
    fprintf(fid,'%i\r\n',1);
    fprintf(fid,'%s\r\n','    filter (f1,f2,f3,f4); flat band-pass between f2, f3');
    fprintf(fid,'%s\r\n','    cosine tapered between f1, f2 and between f3, f4');
    fprintf(fid,'%g %g %g %g\r\n',f1,f2,f3,f4);
    fprintf(fid,'%s\r\n','    guess of data variance (important only for absolute value of the parameter variance)');
    fprintf(fid,'%s\r\n',vardat);
  fclose(fid);
  

else
  fid = fopen('inpinv.dat','w');
    fprintf(fid,'%s\n','    mode of inversion: 1=full MT, 2=deviatoric MT (recommended), 3= DC MT, 4=known fixed DC MT');
    fprintf(fid,'%i\n',1);
    fprintf(fid,'%s\n','    time step of XXXRAW.DAT files (in sec)');
    fprintf(fid,'%g\n',dt);
    fprintf(fid,'%s\n','    number of trial source positions (isourmax), max. 51');
    fprintf(fid,'%i\n',81);
    fprintf(fid,'%s\n','    trial time shifts (max. 100 shifts): from (>-2500), step, to (<2500)');
    fprintf(fid,'%s\n','    example: -10,5,50 means -10dt to 50dt, step = 5dt, i.e. 12 shifts');
    fprintf(fid,'%i %i %i\n',-10, 5,50);
    fprintf(fid,'%s\n','    number of subevents to be searched (isubmax), max. 20');
    fprintf(fid,'%i\n',1);
    fprintf(fid,'%s\n','    filter (f1,f2,f3,f4); flat band-pass between f2, f3');
    fprintf(fid,'%s\n','    cosine tapered between f1, f2 and between f3, f4');
    fprintf(fid,'%g %g %g %g\n',f1,f2,f3,f4);
    fprintf(fid,'%s\n','    guess of data variance (important only for absolute value of the parameter variance)');
    fprintf(fid,'%s\n',vardat);
  fclose(fid);
end

%%  here we must update the allstat.dat frq range also..!!
qstring = 'Use allstat.dat from invert folder? Hint: If not then frequency range of this window is used for all stations.';
choice = questdlg(qstring,'allstat use',...
    'Yes','No','No');

if strcmp(choice,'No')

                     fid = fopen('allstat.dat');
                         C= textscan(fid,'%s %f %f %f %f %f %f %f %f');
                     fclose(fid);
        
    
    % keep a backup
     copyfile('allstat.dat','allstat.bak');
   %  stnnames=allstat_info{1,1}; usest=cell2mat(allstat_info(1,2)); usens=cell2mat(allstat_info(1,3));useew=cell2mat(allstat_info(1,4));useve=cell2mat(allstat_info(1,5));
                 
% update allstat   based on info from GUI
     if ispc
        fid = fopen('allstat.dat','w');
          for p=1:length(C{1})
            fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\r\n', char(C{1}(p)),C{2}(p),C{3}(p),C{4}(p),C{5}(p),f1,f2,f3,f4);
          end
        fclose(fid);
     else
        fid = fopen('allstat.dat','w');
          for p=1:length(C{1})
            fprintf(fid,'%s %u %u %u %u %7.3f %7.3f %7.3f %7.3f\n',  char(C{1}(p)),C{2}(p),C{3}(p),C{4}(p),C{5}(p),f1,f2,f3,f4);
          end
        fclose(fid);
     end     
     

else
    
    disp('Use allstat.dat from invert')
    copyfile('..\invert\allstat.dat','.');
    
end

%% Write the batch file for the calculation


nsources=81;

          if ispc
              
           fid = fopen('runvectors_map.bat','w');

              for i=1:nsources ;
                    fprintf(fid,'%s\r\n',['copy elemse' num2str(i,'%02d') '.dat elemse99.dat']);
                    fprintf(fid,'%s\r\n','iso_once.exe');
                    fprintf(fid,'%s\r\n','sigma5or6.exe');
                    fprintf(fid,'%s\r\n','pokus_once.exe');
                    fprintf(fid,'%s\r\n','analyze_once.exe');
                    fprintf(fid,'%s\r\n',['copy statistics.dat stat_' num2str(i,'%02d') '.dat']);
                    fprintf(fid,'%s\r\n','    ');
              end
                    fprintf(fid,'%s\r\n','kagan_map.exe');
                    fclose(fid);
          else
              
           fid = fopen('runvectors_map.sh','w');

              for i=1:nsources ;
                    fprintf(fid,'%s\n',['cp elemse' num2str(i,'%02d') '.dat elemse99.dat']);
                    fprintf(fid,'%s\n','iso_once.exe');
                    fprintf(fid,'%s\n','sigma5or6.exe');
                    fprintf(fid,'%s\n','pokus_once.exe');
                    fprintf(fid,'%s\n','analyze_once.exe');
                    fprintf(fid,'%s\n',['cp statistics.dat stat_' num2str(i,'%02d') '.dat']);
                    fprintf(fid,'%s\n','    ');
              end
                    fprintf(fid,'%s\n','kagan_map.exe');
                    fclose(fid);
          end
          
%% RUN
%%%%%%%%%%%%%%%% try
button = questdlg('Run the code..?',...
'Continue Operation','Yes','No','Yes');
% 
if strcmp(button,'Yes')
   disp('Running ....')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
  if ispc
    system('runvectors_map.bat  &')
  else
    disp('Linux ')
    pwd
    
    !chmod +x runvectors_map.sh
    system(' gnome-terminal -e "bash -c ./runvectors_map.sh;bash" ')
    %gnome-terminal -e "bash -c ./gre_ele.sh;bash"

  end

else
    
 disp('Canceled')
end

cd ..



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


% --- Executes on button press in crustalmodel.
function crustalmodel_Callback(hObject, eventdata, handles)
% hObject    handle to crustalmodel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    [crustalfile, newdir] = uigetfile('*.cru;*.dat;*.txt', 'Select crustal model file');
   
    if crustalfile == 0
       disp('Cancel file load')
       return
    else
        if ispc
          [status, message] = copyfile([newdir crustalfile],'.\unc_maps\crustal.dat');    
        else
          [status, message] = copyfile([newdir crustalfile],'./unc_maps/crustal.dat');    
        end
    end
 
set(handles.crmodel,'String',crustalfile)   



function fmax_Callback(hObject, eventdata, handles)
% hObject    handle to fmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fmax as text
%        str2double(get(hObject,'String')) returns contents of fmax as a double


% --- Executes during object creation, after setting all properties.
function fmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tltext_Callback(hObject, eventdata, handles)
% hObject    handle to tltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tltext as text
%        str2double(get(hObject,'String')) returns contents of tltext as a double


% --- Executes during object creation, after setting all properties.
function tltext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tltext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dt_Callback(hObject, eventdata, handles)
% hObject    handle to dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dt as text
%        str2double(get(hObject,'String')) returns contents of dt as a double


% --- Executes during object creation, after setting all properties.
function dt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dt (see GCBO)
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



function vardat_Callback(hObject, eventdata, handles)
% hObject    handle to vardat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vardat as text
%        str2double(get(hObject,'String')) returns contents of vardat as a double


% --- Executes during object creation, after setting all properties.
function vardat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vardat (see GCBO)
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

function sdur_Callback(hObject, eventdata, handles)
% hObject    handle to sdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sdur as text
%        str2double(get(hObject,'String')) returns contents of sdur as a double


% --- Executes during object creation, after setting all properties.
function sdur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sdur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mutual_exclude(off)
set(off,'Value',0)

function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')
