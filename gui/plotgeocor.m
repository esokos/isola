function varargout = plotgeocor(varargin)
% PLOTGEOCOR M-file for plotgeocor.fig
%      PLOTGEOCOR, by itself, creates a new PLOTGEOCOR or raises the existing
%      singleton*.
%
%      H = PLOTGEOCOR returns the handle to a new PLOTGEOCOR or the handle to
%      the existing singleton*.
%
%      PLOTGEOCOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTGEOCOR.M with the given input arguments.
%
%      PLOTGEOCOR('Property','Value',...) creates a new PLOTGEOCOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotgeocor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotgeocor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotgeocor

% Last Modified by GUIDE v2.5 11-May-2009 09:27:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotgeocor_OpeningFcn, ...
                   'gui_OutputFcn',  @plotgeocor_OutputFcn, ...
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


% --- Executes just before plotgeocor is made visible.
function plotgeocor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotgeocor (see VARARGIN)

% Choose default command line output for plotgeocor
handles.output = hObject;

%check if INVERT exists..!
h=dir('invert');
if length(h) == 0;

    disp('Invert folder doesn''t exist. Be sure that you call Plotgeocor from proper path.');
    msgbox('Invert folder doesn''t exist. Be sure that you call Plotgeocor from proper path.','Be careful','warn')
    
end

%%% check event.isl files with event info !!!
h=dir('geocorrel.isl');

if length(h) == 0; 

    %%% first time put defaults...!!
        fid = fopen('geocorrel.isl','w');
         fprintf(fid,'%s\r\n','15');
         fprintf(fid,'%s\r\n','1');
         fprintf(fid,'%s\r\n','1');
         fprintf(fid,'%s\r\n','50');
         fprintf(fid,'%s\r\n','2');
         fprintf(fid,'%s\r\n','2');
         fprintf(fid,'%s\r\n','0.35');
         fprintf(fid,'%s\r\n','12');
         fprintf(fid,'%s\r\n','0');
         fprintf(fid,'%s\r\n','0.1');
         fprintf(fid,'%s\r\n','1');
         fprintf(fid,'%s\r\n','1');
        fclose(fid);

    mapscale=15;
    mapborder=1;
    anot=1;
    legendL=50;
    legendX=2;
    legendY=2;
    bballscale=0.35;
    bballtsize=12;
    bballcut=0;
    cint=0.1;
    cpen=1;
    palet=1;
       
        
else
    fid = fopen('geocorrel.isl','r');
    mapscale=fscanf(fid,'%g',1);
    mapborder=fscanf(fid,'%g',1);
    anot=fscanf(fid,'%g',1);
    legendL=fscanf(fid,'%g',1);
    legendX=fscanf(fid,'%g',1);
    legendY=fscanf(fid,'%g',1);
    bballscale=fscanf(fid,'%g',1);
    bballtsize=fscanf(fid,'%g',1);
    bballcut=fscanf(fid,'%g',1);
    cint=fscanf(fid,'%g',1);
    cpen=fscanf(fid,'%g',1);
    palet=fscanf(fid,'%g',1);
    fclose(fid);
end

%%%%Try to populate GMT palette popupmenu....
h=dir('C:\GMT\share\cpt');

if length(h) == 0; 
    %%% GMT is not installed in c:\gmt or cpt folder doesn't exist...so
    %%% we'll use standard palettes
    
cpt_file={'cool','copper','drywet','gebco','globe','gray','haxby','hot','jet','no green','ocean','polar','rainbow','red2green','relief','sealand','seis','split','topo','wysiwyg'};

 disp('It seems that GMT is not installed at c:\gmt ... ')
 disp('If you want GUI to automatically find your cpt files change the path at line 252 of invert.m')
 disp('Using GMT default cpt files...')
 
     set(handles.gmtpal,'String',cpt_file);
     set(handles.gmtpal,'Value',palet);
else
    
    cpt_files=dir('C:\GMT\share\cpt\*.cpt');
    
    cpt_file1=strrep({cpt_files(:).name},'GMT_','');    
    cpt_file =strrep(cpt_file1,'.cpt','');    

    set(handles.gmtpal,'String',cpt_file);
    set(handles.gmtpal,'Value',palet);
    disp('Using cpt files found in C:\GMT\share\cpt')
    
end

%%%%%%%%%%%%%%%%%%%%%

try
cd invert
files=dir('corr*.dat');
fileindex=length(files);
cd ..
catch
    cd ..
    pwd
end

cname=['planecorrgeo' num2str(fileindex,'%02d') '.dat']

set(handles.text13,'String',cname);        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h=dir('tsources.isl');

if length(h) == 0; 
    errordlg('tsources.isl file doesn''t exist. Run Source create. ','File Error');
  return    
else
    fid = fopen('tsources.isl','r');
    tsource=fscanf(fid,'%s',1)

    if strcmp(tsource,'line')
        disp('Inversion was done for a line of sources.')

        
        
     elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.')

    
     elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
           noSourcesstrike=fscanf(fid,'%i',1)
           strikestep=fscanf(fid,'%i',1)
           noSourcesdip=fscanf(fid,'%i',1)
           dipstep=fscanf(fid,'%i',1)
%           nsources=noSourcesstrike*noSourcesdip;
          
           invtype='   Multiple Sources on a plane ';%(Trial Sources on a plane or line)';
      
           conplane=1;
           
           %% dummy sdepth
           sdepth=-333;
           distep=-333;
            
           %%%%%%%%%%%%%%%%%write to handles
            handles.nsources=nsources;
            handles.noSourcesstrike=noSourcesstrike;
            handles.strikestep=strikestep;
            handles.noSourcesdip=noSourcesdip;
            handles.dipstep=dipstep;
           % Update handles structure
            guidata(hObject, handles);
           
     elseif strcmp(tsource,'point')
       disp('Inversion was done for one source.')

       
     end
     
          fclose(fid);
          
 end


mainpath=pwd;
path1=pwd;

handles.path1=path1;
handles.mainpath=mainpath;

%%%% updata handles.....
set(handles.mapscale,'String',num2str(mapscale));        
set(handles.mapborder,'String',num2str(mapborder));         
set(handles.anot,'String',num2str(anot));    
set(handles.legendL, 'String',num2str(legendL));    
set(handles.legendX,'String',num2str(legendX))        
set(handles.legendY,'String',num2str(legendY))  
set(handles.bballscale,'String',num2str(bballscale))         
set(handles.bballtsize,'String',num2str(bballtsize))   
set(handles.bballcut,'String',num2str(bballcut))        
set(handles.cint,'String',num2str(cint))  
set(handles.cpen,'String',num2str(cpen))         
set(handles.gmtpal,'Value', palet )   

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotgeocor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotgeocor_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
disp('This is plotgeocor 16/04/09');



% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%read from handles
noSourcesstrike=handles.noSourcesstrike;
noSourcesdip=handles.noSourcesdip;

%%%read from handles
nsources=handles.nsources;
mapscale=str2num(get(handles.mapscale,'String'))
mapborder=str2num(get(handles.mapborder,'String'))
anot=str2num(get(handles.anot,'String'))
legendL=str2num(get(handles.legendL,'String'))
legendX=str2num(get(handles.legendX,'String'))
legendY=str2num(get(handles.legendY,'String'))
bballscale=str2num(get(handles.bballscale,'String'))
bballtsize=str2num(get(handles.bballtsize,'String'))
bballcut=str2num(get(handles.bballcut,'String'))
cint=str2num(get(handles.cint,'String'))
cpen=str2num(get(handles.cpen,'String'))
pal=get(handles.gmtpal,'String');
gmtpalval=get(handles.gmtpal,'Value')
gmtpal = pal{gmtpalval}  

invpal= get(handles.invpal,'Value');

selptext=get(handles.selptext,'String');
selltext=get(handles.selltext,'String');
seltopotext=get(handles.seltopotext,'String');

%% read symbol info
sym=get(handles.symbol,'String');
symval=get(handles.symbol,'Value');
ssymbol=sym{symval}(1:1)

ssize=str2num(get(handles.size,'String'));

red=str2num(get(handles.red,'String'));
green=str2num(get(handles.green,'String'));
blue=str2num(get(handles.blue,'String'));
plsym=get(handles.plsymbol,'Value');
anotornot=get(handles.danot,'Value');
pbeachtext=get(handles.beachtext,'Value');
paddsnum=get(handles.addsnum,'Value');

%find out the current corr*.dat file
try
cd invert
files=dir('corr*.dat');
fileindex=length(files);
cd ..
catch
    cd ..
    pwd
end

cname=['planecorrgeo' num2str(fileindex,'%02d') '.dat'];
psname= ['planecorrgeo' num2str(fileindex,'%02d') '.ps'];



disp(['Now plotting  ' cname '   correlation file'])
   
%%%%planecor should be here already...???!!!!!!!!







    
% %%%%% prepare a file ...for geographical correlation plotting 
try
    [xposgeo,yposgeo,dum1,geodepth,geoname,dum] = textread('.\gmtfiles\sources.gmt','%f %f %f %f %s %s');
catch
    disp('Sources.gmt file not found in gmtfiles folder')
end
   
pwd
%%% read planecor again..!
[i,besttim,correl,bbstr1,bbdip1,bbrake1,bbstr2,bbdip2,bbrake2,bbdc,bbmoment,posx,posy]= textread('.\invert\planecor.dat','%u %f %f %f %f %f %f %f %f %f %f %u %u');

fid = fopen(['.\gmtfiles\' cname],'w');

for i=1:nsources
  fprintf(fid,'%g %g %i %g %g  %g %g %g %g  %g %g %g %g %i %i\r\n',xposgeo(i),yposgeo(i),i,besttim(i),correl(i),bbstr1(i),bbdip1(i),bbrake1(i),bbstr2(i),bbdip2(i), bbrake2(i),bbdc(i), bbmoment(i),posx(i),posy(i));
end

fclose(fid);
%%%

fid = fopen('.\gmtfiles\origins.dat','w');
  fprintf(fid,'%g %g %s\r\n',xposgeo(nsources+1),yposgeo(nsources+1),'New_ref');
  fprintf(fid,'%g %g %s\r\n',xposgeo(nsources+2),yposgeo(nsources+2),'Old_ref');
fclose(fid);

%%% prepare a file to be used as clip path
fid = fopen('.\gmtfiles\clip.txt','w');
fprintf(fid,'%g %g %s\r\n',xposgeo(1),yposgeo(1),'1');
fprintf(fid,'%g %g %g\r\n',xposgeo(noSourcesstrike),yposgeo(noSourcesstrike),noSourcesstrike);
fprintf(fid,'%g %g %g\r\n',xposgeo(nsources),yposgeo(nsources),nsources);
fprintf(fid,'%g %g %g\r\n',xposgeo(nsources-(noSourcesstrike-1)),yposgeo(nsources-(noSourcesstrike-1)),nsources-(noSourcesstrike-1));
fprintf(fid,'%g %g %s\r\n',xposgeo(1),yposgeo(1),'1');
fclose(fid);

%%%% add code to prepare batch file plot of planecorgeo here...!!
if strcmp(seltopotext,'none')         %%% no topo
 
fid = fopen('.\gmtfiles\plcorgeo.bat','w');

        fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14 PLOT_DEGREE_FORMAT +D');

           st=['gawk "{print $1,$2,$5}" ' cname ' >  corcongeo.dat'];   
           
fprintf(fid,'%s\r\n',st);
fprintf(fid,'%s\r\n',['  ']);

fprintf(fid,'%s\r\n', 'makecpt -Ccopper -T0/100/10 -I > dc.cpt');
if invpal == 1
     fprintf(fid,'%s\r\n',['makecpt -I -C' gmtpal '  -T0/1/' num2str(cint) '     > cr.cpt ']);
else
    fprintf(fid,'%s\r\n',['makecpt -C' gmtpal '  -T0/1/' num2str(cint) '     > cr.cpt ']);
end

fprintf(fid,'%s\r\n',['  ']);

if anotornot == 1
    disp(' no annotation')
    fprintf(fid,'%s\r\n',['pscontour corcongeo.dat -R' num2str(min(xposgeo)-mapborder) '/' num2str(max(xposgeo)+mapborder)  '/' num2str(min(yposgeo)-mapborder) '/' num2str(max(yposgeo)+mapborder) ' -JM' num2str(mapscale) 'c -W' num2str(cpen) 'p -Ccr.cpt -K -A- -I  -B' num2str(anot) ' > ' psname ]);

else

    fprintf(fid,'%s\r\n',['pscontour corcongeo.dat -R' num2str(min(xposgeo)-mapborder) '/' num2str(max(xposgeo)+mapborder)  '/' num2str(min(yposgeo)-mapborder) '/' num2str(max(yposgeo)+mapborder) ' -JM' num2str(mapscale) 'c -W' num2str(cpen) 'p -Ccr.cpt -K -A+a0+s10+p+o+gwhite -I  -B' num2str(anot) ' > ' psname ]);

end




fprintf(fid,'%s\r\n',['  ']);

fprintf(fid,'%s\r\n',['pscoast -R -J -Wthin -K -O  -Lfx' num2str(legendX) '/' num2str(legendY) '/' num2str(  min(yposgeo)+(max(yposgeo)-min(yposgeo))/2 ) '/' num2str(legendL) 'k' ' >> ' psname ]);
fprintf(fid,'%s\r\n',['  ']);


if plsym == 1
    disp(' skip points')
else
     if paddsnum == 1
          fprintf(fid,'%s\r\n',['gawk "{ print $1,$2,' num2str(bballtsize) ', 0 , 1 ,\"CT\",$3}" ' cname ' > stext.dat ']);
          fprintf(fid,'%s\r\n',['pstext -R  -J  stext.dat -K -O -D0c/' num2str(ssize+0.2)        'c >> ' psname ]);
      else
      end
      
          fprintf(fid,'%s\r\n',['psxy -R  -J  corcongeo.dat -S' ssymbol num2str(ssize) 'c -M  -W1p/0 -K -O -G' num2str(red) '/'  num2str(green) '/' num2str(blue)   ' >> ' psname ]);
    
end

fprintf(fid,'%s\r\n',['  ']);

%%check if we need extra files to plot

if strcmp(selptext,'none')  
disp('Extra point file not needed')
else
    fprintf(fid,'%s\r\n',['psxy -R -J -Sc0.2c ' selptext ' -Wthick  -O -K >> ' psname ]);
end

if strcmp(selltext,'none')  
disp('Extra point file not needed')
else
    fprintf(fid,'%s\r\n',['psxy -R -J  -M ' selltext ' -Wthick  -O -K >> ' psname ]);
end


fprintf(fid,'%s\r\n',['  ']);

if pbeachtext==1
fprintf(fid,'%s\r\n',['gawk "{ if ($5>' num2str(bballcut) ') print $1,$2,$12,$6,$7,$8,"5"           }" ' cname ' > testfoc.dat ']);
else
fprintf(fid,'%s\r\n',['gawk "{ if ($5>' num2str(bballcut) ') print $1,$2,$12,$6,$7,$8,"5","0","0",$3}" ' cname ' > testfoc.dat ']);
end

fprintf(fid,'%s\r\n',['psmeca -R -J  -Sa' num2str(bballscale) 'c/' num2str(bballtsize) ' -O -K testfoc.dat -Zdc.cpt >> ' psname ]);
fprintf(fid,'%s\r\n',['  ']);

fprintf(fid,'%s\r\n',['psscale -D'  num2str(mapscale+4)  'c/4c/7c/0.3c -O -Ccr.cpt -K   -B0.1:Correlation: >> ' psname ]);
fprintf(fid,'%s\r\n',['psscale -D'  num2str(mapscale+4)  'c/13c/7c/0.3c -O -Cdc.cpt -K -L  -B::/:DC\045: >> ' psname ]);
fprintf(fid,'%s\r\n',['psxy -R -J -Sa0.8c origins.dat -Wthick  -O  >> ' psname ]);
fclose(fid)


else   %%% plot with topo

    %%%read  topo file info
    
grdlonmin=handles.lonmin1;
grdlonmax=handles.lonmax1;
grdlatmin=handles.latmin1;
grdlatmax=handles.latmax1;
grdzmin=handles.zmin1;
grdzmax=handles.zmax1;

%%%%%%   
    
fid = fopen('.\gmtfiles\plcorgeo.bat','w');
        fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14 PLOT_DEGREE_FORMAT +D');
           st=['gawk "{print $1,$2,$5}" ' cname ' >  corcongeo.dat'];   
           
fprintf(fid,'%s\r\n',st);
fprintf(fid,'%s\r\n',['  ']);

fprintf(fid,'%s\r\n', 'makecpt -Ccopper -T0/100/10 -I > dc.cpt');
if invpal == 1
     fprintf(fid,'%s\r\n',['makecpt -I -C' gmtpal '  -T0/1/' num2str(cint) '     > cr.cpt ']);
else
    fprintf(fid,'%s\r\n',['makecpt -C' gmtpal '  -T0/1/' num2str(cint) '     > cr.cpt ']);
end

fprintf(fid,'%s\r\n',['makecpt -Cgray -T' num2str(grdzmin) '/' num2str(grdzmax)  '/' '5 -I > atopo.cpt']);
fprintf(fid,'%s\r\n',['  ']);

fprintf(fid,'%s\r\n', ['grdgradient ' seltopotext ' -Ne0.6 -A45 -M -Gtopograd.grd ']);
%%%%% part for correlation contours
fprintf(fid,'%s\r\n', ['surface corcongeo.dat -Gcorr.grd  -I.001 -R' num2str(min(xposgeo)-mapborder) '/' num2str(max(xposgeo)+mapborder)  '/' num2str(min(yposgeo)-mapborder) '/' num2str(max(yposgeo)+mapborder) ' -T0.25 -Ll0']);
fprintf(fid,'%s\r\n', ['grdcontour corr.grd -J  -Dcont.txt -M -C0.01']);
fprintf(fid,'%s\r\n', ['gmtselect cont.txt -Fclip.txt -M > sel.txt']);
%%%%%
fprintf(fid,'%s\r\n',['  ']);

fprintf(fid,'%s\r\n', ['grdview ' seltopotext '  -JM' num2str(mapscale) 'c  -Qi100    -Itopograd.grd -E180/90 -Catopo.cpt -K  -B' num2str(anot) ' > ' psname ]);
fprintf(fid,'%s\r\n',['pscoast -R -J -Wthin -K -O  -Lfx' num2str(legendX) '/' num2str(legendY) '/' num2str(  min(yposgeo)+(max(yposgeo)-min(yposgeo))/2 ) '/' num2str(legendL) 'k' ' >> ' psname ]);
fprintf(fid,'%s\r\n',['  ']);

fprintf(fid,'%s\r\n',['psxy sel.txt  -R -J -K -O -M -Wthicker -Ccr.cpt -V    >> ' psname ]);

if plsym == 1
    disp(' skip points')
else
     if paddsnum == 1
          fprintf(fid,'%s\r\n',['gawk "{ print $1,$2,' num2str(bballtsize) ', 0 , 1 ,\"CT\",$3}" ' cname ' > stext.dat ']);
          fprintf(fid,'%s\r\n',['pstext -R  -J  stext.dat -K -O -D0c/' num2str(ssize+0.2)        'c >> ' psname ]);
      else
      end
      
          fprintf(fid,'%s\r\n',['psxy -R  -J  corcongeo.dat -S' ssymbol num2str(ssize) 'c -M  -W1p/0 -K -O -G' num2str(red) '/'  num2str(green) '/' num2str(blue)   ' >> ' psname ]);
    
end

fprintf(fid,'%s\r\n',['  ']);   

%%check if we need extra files to plot

if strcmp(selptext,'none')  
disp('Extra point file not needed')
else
    fprintf(fid,'%s\r\n',['psxy -R -J -Sc0.2c ' selptext ' -Wthick  -O -K >> ' psname ]);
end

if strcmp(selltext,'none')  
disp('Extra point file not needed')
else
    fprintf(fid,'%s\r\n',['psxy -R -J  -M ' selltext ' -Wthick  -O -K >> ' psname ]);
end



fprintf(fid,'%s\r\n',['  ']);   

if pbeachtext==1
fprintf(fid,'%s\r\n',['gawk "{ if ($5>' num2str(bballcut) ') print $1,$2,$12,$6,$7,$8,"5"           }" ' cname ' > testfoc.dat ']);
else
fprintf(fid,'%s\r\n',['gawk "{ if ($5>' num2str(bballcut) ') print $1,$2,$12,$6,$7,$8,"5","0","0",$3}" ' cname ' > testfoc.dat ']);
end

fprintf(fid,'%s\r\n',['psmeca -R -J  -Sa' num2str(bballscale) 'c/' num2str(bballtsize) ' -O -K testfoc.dat -Zdc.cpt >> ' psname ]);
fprintf(fid,'%s\r\n',['  ']);

fprintf(fid,'%s\r\n',['psscale -D'  num2str(mapscale+4)  'c/4c/7c/0.3c -O -Ccr.cpt -K   -B0.1:Correlation: >> ' psname ]);
fprintf(fid,'%s\r\n',['psscale -D'  num2str(mapscale+4)  'c/13c/7c/0.3c -O -Cdc.cpt -K -L  -B::/:DC\045: >> ' psname ]);
fprintf(fid,'%s\r\n',['psxy -R -J -Sa0.8c origins.dat -Wthick  -O  >> ' psname ]);
fclose(fid)


end




try
cd gmtfiles
%%% run batch file...
[s,r]=system('plcorgeo.bat');
cr=['gsview32 ' psname ];
system( cr );
cd ..
catch
    cd ..
end

        fid = fopen('geocorrel.isl','w');
         fprintf(fid,'%g\r\n',mapscale);
         fprintf(fid,'%g\r\n',mapborder);
         fprintf(fid,'%g\r\n',anot);
         fprintf(fid,'%g\r\n',legendL);
         fprintf(fid,'%g\r\n',legendX);
         fprintf(fid,'%g\r\n',legendY);
         fprintf(fid,'%g\r\n',bballscale);
         fprintf(fid,'%g\r\n',bballtsize);
         fprintf(fid,'%g\r\n',bballcut);
         fprintf(fid,'%g\r\n',cint);
         fprintf(fid,'%g\r\n',cpen);
         fprintf(fid,'%g\r\n',gmtpalval);
        fclose(fid);

        
        
%pscoast -R -J -Wthin -K   -Lfx3/1/42.4/10k -G255/255/204  > corr02.ps
%pscontour corcongeo.dat -R13/13.7/42/42.6   -W0.5p -JM15c -Ccr.cpt -K -O -I -A+a90+s10 -B.1 >> corr02.ps
% gawk "{ print $1,$2,$5}" planecorgeo.dat > corcongeo.dat
% 
% psxy -R  -J  points.txt -St.4c -M  -W1p/0 -K -O -G0/0/255 >> corr02.ps
% 
% gawk "{ print $1,$2,12,0,1,\"CT\",$3}" points.txt > ptext.gmt
% pstext -R -J ptext.gmt -K -O  >> corr02.ps
%psxy -R  -J  planecorgeo.dat -Sx.1c -M  -W1p/0 -K -O -G0/0/255 >> corr02.ps
%gawk "{ if ($5>0.7) print $1,$2,$12,$6,$7,$8,"5","0","0",$3}" planecorgeo.dat > testfoc.dat
%rem psmeca -R -JX21c/18c -Sa0.45 -K -O maxval.foc -G255/0/0 >> corr02.ps

%gawk "{ print $2,$1}" after.txt > after.gmt
%psxy -R -J -Sc0.2c after.gmt -Wthick  -O -K    >> corr02.ps






%%%% add code to prepare batch file plot of planecorgeo here...!!

    
    
    
    




% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.plotcorgeo)

% --- Executes during object creation, after setting all properties.
function mapscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mapscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function mapscale_Callback(hObject, eventdata, handles)
% hObject    handle to mapscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mapscale as text
%        str2double(get(hObject,'String')) returns contents of mapscale as a double


% --- Executes during object creation, after setting all properties.
function bballscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bballscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function bballscale_Callback(hObject, eventdata, handles)
% hObject    handle to bballscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bballscale as text
%        str2double(get(hObject,'String')) returns contents of bballscale as a double


% --- Executes during object creation, after setting all properties.
function gmtpal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gmtpal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in gmtpal.
function gmtpal_Callback(hObject, eventdata, handles)
% hObject    handle to gmtpal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns gmtpal contents as cell array
%        contents{get(hObject,'Value')} returns selected item from gmtpal


% --- Executes on button press in invpal.
function invpal_Callback(hObject, eventdata, handles)
% hObject    handle to invpal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of invpal


% --- Executes during object creation, after setting all properties.
function mapborder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mapborder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function mapborder_Callback(hObject, eventdata, handles)
% hObject    handle to mapborder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mapborder as text
%        str2double(get(hObject,'String')) returns contents of mapborder as a double


% --- Executes during object creation, after setting all properties.
function anot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to anot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function anot_Callback(hObject, eventdata, handles)
% hObject    handle to anot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of anot as text
%        str2double(get(hObject,'String')) returns contents of anot as a double


% --- Executes during object creation, after setting all properties.
function legendL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to legendL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function legendL_Callback(hObject, eventdata, handles)
% hObject    handle to legendL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of legendL as text
%        str2double(get(hObject,'String')) returns contents of legendL as a double


% --- Executes during object creation, after setting all properties.
function legendX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to legendX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function legendX_Callback(hObject, eventdata, handles)
% hObject    handle to legendX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of legendX as text
%        str2double(get(hObject,'String')) returns contents of legendX as a double


% --- Executes during object creation, after setting all properties.
function legendY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to legendY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function legendY_Callback(hObject, eventdata, handles)
% hObject    handle to legendY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of legendY as text
%        str2double(get(hObject,'String')) returns contents of legendY as a double


% --- Executes during object creation, after setting all properties.
function bballtsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bballtsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function bballtsize_Callback(hObject, eventdata, handles)
% hObject    handle to bballtsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bballtsize as text
%        str2double(get(hObject,'String')) returns contents of bballtsize as a double


% --- Executes during object creation, after setting all properties.
function bballcut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bballcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function bballcut_Callback(hObject, eventdata, handles)
% hObject    handle to bballcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bballcut as text
%        str2double(get(hObject,'String')) returns contents of bballcut as a double


% --- Executes during object creation, after setting all properties.
function cint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function cint_Callback(hObject, eventdata, handles)
% hObject    handle to cint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cint as text
%        str2double(get(hObject,'String')) returns contents of cint as a double


% --- Executes during object creation, after setting all properties.
function cpen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function cpen_Callback(hObject, eventdata, handles)
% hObject    handle to cpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cpen as text
%        str2double(get(hObject,'String')) returns contents of cpen as a double


% --- Executes on button press in selp.
function selp_Callback(hObject, eventdata, handles)
% hObject    handle to selp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path1=handles.path1
mainpath=handles.mainpath;

cd(path1)

[file1,path1] = uigetfile([ '*.txt'],'Select a text file in GMT point format',400,400);

lopa = [path1 file1] 
name = file1

   if name == 0
       disp('Cancel file load')
       return
   else
   end
   
set(handles.selptext,'String',lopa)

handles.selp=lopa;
guidata(hObject,handles);

% --- Executes on button press in sell.
function sell_Callback(hObject, eventdata, handles)
% hObject    handle to sell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path1=handles.path1
mainpath=handles.mainpath;

cd(path1)

[file1,path1] = uigetfile([ '*.txt'],'Select a text file in GMT line format',400,400);

lopa = [path1 file1] 
name = file1

   if name == 0
       disp('Cancel file load')
       return
   else
   end
   
set(handles.selltext,'String',lopa)

handles.sell=lopa;
guidata(hObject,handles);

% --- Executes on button press in sel4.
function sel4_Callback(hObject, eventdata, handles)
% hObject    handle to sel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in sel2.
function sel2_Callback(hObject, eventdata, handles)
% hObject    handle to sel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function symbol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to symbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in symbol.
function symbol_Callback(hObject, eventdata, handles)
% hObject    handle to symbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns symbol contents as cell array
%        contents{get(hObject,'Value')} returns selected item from symbol


% --- Executes during object creation, after setting all properties.
function size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function size_Callback(hObject, eventdata, handles)
% hObject    handle to size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of size as text
%        str2double(get(hObject,'String')) returns contents of size as a double


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function red_CreateFcn(hObject, eventdata, handles)
% hObject    handle to red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function red_Callback(hObject, eventdata, handles)
% hObject    handle to red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of red as text
%        str2double(get(hObject,'String')) returns contents of red as a double


% --- Executes during object creation, after setting all properties.
function green_CreateFcn(hObject, eventdata, handles)
% hObject    handle to green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function green_Callback(hObject, eventdata, handles)
% hObject    handle to green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of green as text
%        str2double(get(hObject,'String')) returns contents of green as a double


% --- Executes during object creation, after setting all properties.
function blue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function blue_Callback(hObject, eventdata, handles)
% hObject    handle to blue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blue as text
%        str2double(get(hObject,'String')) returns contents of blue as a double


% --- Executes on button press in plsymbol.
function plsymbol_Callback(hObject, eventdata, handles)
% hObject    handle to plsymbol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plsymbol


% --- Executes on button press in danot.
function danot_Callback(hObject, eventdata, handles)
% hObject    handle to danot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of danot


% --- Executes on button press in seltopo.
function seltopo_Callback(hObject, eventdata, handles)
% hObject    handle to seltopo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

path1=handles.path1
mainpath=handles.mainpath;

cd(path1)

[file1,path1] = uigetfile([ '*.grd'],'Select a GMT grid file with topography',400,400);

lopa = [path1 file1] 
name = file1

   if name == 0
       disp('Cancel file load')
       return
   else
   end
   

%%% now find extend of grd file
%%% use grdinfo.....

[status, result] = system(['grdinfo  -C ' lopa ]')

if status ~= 0
    disp('Error getting GRD file extend')
else
    disp(['GRD info ' result ]')

%process output of grdinfo
tab1 = sprintf('\t');
ss=strrep(result,tab1,' ');
[token,rem] = strtok(ss);
A = sscanf(rem,'%f %f %f %f %f %f %f %f %f %f');
grdlonmin=A(1)
grdlonmax=A(2)
grdlatmin=A(3)
grdlatmax=A(4)
grdzmin=A(5)
grdzmax=A(6)

set(handles.lonmin,'String',num2str(grdlonmin))
set(handles.lonmax,'String',num2str(grdlonmax))
set(handles.latmin,'String',num2str(grdlatmin))
set(handles.latmax,'String',num2str(grdlatmax))
set(handles.zmin,'String',num2str(grdzmin))
set(handles.zmax,'String',num2str(grdzmax))

handles.lonmin1=grdlonmin;
handles.lonmax1=grdlonmax;
handles.latmin1=grdlatmin;
handles.latmax1=grdlatmax;
handles.zmin1=grdzmin;
handles.zmax1=grdzmax;

guidata(hObject,handles);

end

%%%% update handles
set(handles.seltopotext,'String',lopa)
handles.selltopo=lopa;

guidata(hObject,handles);


% --- Executes on button press in beachtext.
function beachtext_Callback(hObject, eventdata, handles)
% hObject    handle to beachtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of beachtext


% --- Executes on button press in addsnum.
function addsnum_Callback(hObject, eventdata, handles)
% hObject    handle to addsnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addsnum


% --- Executes on button press in makekml.
function makekml_Callback(hObject, eventdata, handles)
% hObject    handle to makekml (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%read from handles
noSourcesstrike=handles.noSourcesstrike;
noSourcesdip=handles.noSourcesdip;

cint=str2num(get(handles.cint,'String'))


    [xposgeo,yposgeo,cor] = textread('.\gmtfiles\corcongeo.dat','%f %f %f');
    
X = reshape(xposgeo',noSourcesstrike,noSourcesdip) 
Y = reshape(yposgeo',noSourcesstrike,noSourcesdip) 
Z = reshape(cor',noSourcesstrike,noSourcesdip) 
   
    XI=X;
    YI=Y;
    whos
figure

[XI,YI] = meshgrid(min(X):max(X),min(Y):max(Y));

whos
length(XI)
length(YI)

%    ZI=griddata(X,Y,Z,XI,YI)

    %   [C,h]=contour(ZI) 
    
%    contour(XI,YI,ZI)  
    numLevels = 1/cint  

    kmlStr = ge_contour(X,Y,Z,...
                   'cMap',rand(100,3),...
              'numLevels',numLevels,...
              'lineWidth',1);
                    
ge_output('demo_ge_contour.kml',kmlStr);
    
    
%     kmlStr = ge_contour(X,Y,Z,...
%                    'cMap','jet',...
%               'numLevels',numLevels,...
%               'lineWidth',2);
% 
%            kmlStr = ge_contour(X,Y,Z)
% %            , ...
% %                      'altitude', 25000, ...
% %                      'LineWidth', 1.2, ...
% %                      'LineColor', 'ffaa341f');
% %           
%           ge_output('demo_ge_contour.kml',kmlStr);
% % 
% t = 1:1:64;
% ZZ = reshape(t',noSourcesstrike,noSourcesdip) 
% whos
% iconStr = 'http://maps.google.com/mapfiles/kml/pal3/icon35.png';
% 
% kmlStr01 = ge_point(X,Y,ZZ,...
%                         'iconURL',iconStr,...
%                     'msgToScreen',true,...
%                            'name','');
% kmlFileName = 'demo_ge_point.kml';
% kmlTargetDir = [''];%..',filesep,'kml',filesep];
% ge_output([kmlTargetDir,kmlFileName],[kmlStr01],...
%                                                   'name',kmlFileName);
%                        