function varargout = timefun_twop(varargin)
% TIMEFUN_TWOP M-file for timefun_twop.fig
%      TIMEFUN_TWOP, by itself, creates a new TIMEFUN_TWOP or raises the
%      existing singleton*.
%
%      H = TIMEFUN_TWOP returns the handle to a new TIMEFUN_TWOP or the
%      handle to the existing singleton*.
%
%      TIMEFUN_TWOP('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK in TIMEFUN_TWOP.M with the given input
%      arguments.
%
%      TIMEFUN_TWOP('Property','Value',...) creates a new TIMEFUN_TWOP or
%      raises the existing singleton*.  Starting from the left, property
%      value pairs are applied to the GUI before timefun_twop_OpeningFcn
%      gets called.  An unrecognized property name or invalid value makes
%      property application stop.  All inputs are passed to
%      timefun_twop_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help timefun_twop

% Last Modified by GUIDE v2.5 01-Dec-2020 10:36:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @timefun_twop_OpeningFcn, ...
    'gui_OutputFcn',  @timefun_twop_OutputFcn, ...
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


% --- Executes just before timefun_twop is made visible.
function timefun_twop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn. hObject    handle to
% figure eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) varargin
% command line arguments to timefun_twop (see VARARGIN)

% Choose default command line output for timefun_twop
handles.output = hObject;

%%
disp('This is timefun_twop.m')
disp('Ver.1.5, 26/11/2020')

%%
%check if timefun folder exists..!
fh=exist('timefunc','dir');

if (fh~=7)
    errordlg('Timefunc folder doesn''t exist. ISOLA will create it. ','Folder warning');
    mkdir('timefunc');
end

%check if GREEN exists..!
fh2=exist('green','dir');

if (fh2~=7)
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
end

%check if INVERT exists..!
fh2=exist('invert','dir');

if (fh2~=7)
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
end
%
%check if INPINV.DAT exists..!
fh2=exist('.\invert\inpinv.dat','file');
if (fh2~=2)
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
if isempty(h)
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
    % now check if all RAW files are present and copy to timefun folder
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
% set(handles.nosourcepopup1,'String',src);
% set(handles.nosourcepopup2,'String',src); set info text
set(handles.info_nsrc,'String',linetmp6);
% set info text
set(handles.info_freq,'String',regexprep(linetmp14,' ','-'));

% find max freq
maxfreq=sscanf(linetmp14,'%f %f %f %f');

%% find duration of source time function used in elemse
fid = fopen('.\green\soutype.dat','r');
 type=fscanf(fid,'%d',1);   %01 line
  dur=fscanf(fid,'%f',1);   %14        %02 line
fclose(fid);

if type == 7
    %  errordlg('Source type of elementary seismograms is delta. Use
    %  triangle','File Error');
    disp('Source type of elementary seismograms is delta. Formal source duration is 1/maxfreq')
    set(handles.tdur,'String',num2str(1/maxfreq(4)));
elseif      type == 4
    set(handles.tdur,'String',num2str(dur));
end
%% find out how many sources we have in X Y

h=dir('tsources.isl');

if isempty(h)
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
        
        conplane=2;   %%% Line
        % dummy sdepth
        sdepth=-333;
        
        
        handles.nsources=nsources;
        handles.distep=distep;
        handles.sdepth=sdepth;
        
        % Update handles structure
        guidata(hObject, handles);
        
    elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        
        conplane=0;   %%%depth
        
    elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
        %         distep=fscanf(fid,'%f',1);
        noSourcesstrike=fscanf(fid,'%i',1);
        strikestep=fscanf(fid,'%f',1);
        noSourcesdip=fscanf(fid,'%i',1);
        dipstep=fscanf(fid,'%f',1);
        %           nsources=noSourcesstrike*noSourcesdip;
        
        invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
        
        conplane=1;
        
        % dummy sdepth
        sdepth=3;
        distep=3;
%%      if strike or dip sources =1 then we have a line!!
        if  noSourcesstrike==1 || noSourcesdip==1
            conplane=2;   %%% Line
             disp('Inversion was done for a (formal!!) plane of sources.')
        end
        %%%%%%%%%%%%%%%%%write to handles
        handles.nsources=nsources;
        handles.noSourcesstrike=noSourcesstrike;
        handles.strikestep=strikestep;
        handles.noSourcesdip=noSourcesdip;
        handles.dipstep=dipstep;
        handles.conplane=conplane;
        
        handles.distep=distep;
        handles.sdepth=sdepth;
        % Update handles structure
        guidata(hObject, handles);
        
    elseif strcmp(tsource,'point')
        disp('Inversion was done for one source.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        
        conplane=3;
        
    end
    
    fclose(fid);
    
end
%%
%set(handles.sourceno,'String',num2str(srcpos2(1,1)));
% set(handles.strike,'String',num2str(str1(1,1)));
% set(handles.dip,'String',num2str(dip1(1,1)));
% set(handles.rake,'String',num2str(rake1(1,1)));
% set(handles.moment,'String',num2str(mo(1,1),'%3.1e'));
%% check if we have defaults
h=dir('timefun_twop.isl');
if ~isempty(h)
    
    fid = fopen('timefun_twop.isl','r');
    strike1=fscanf(fid,'%s',1);
    dip1=fscanf(fid,'%s',1);
    rake1=fscanf(fid,'%s',1);
    mom1=fscanf(fid,'%s',1);

    strike2=fscanf(fid,'%s',1);
    dip2=fscanf(fid,'%s',1);
    rake2=fscanf(fid,'%s',1);
    mom2=fscanf(fid,'%s',1);
    
    tshift=fscanf(fid,'%s',1);
    trdist=fscanf(fid,'%s',1);
    conornot=fscanf(fid,'%s',1);
    tdur=fscanf(fid,'%s',1);
    fclose(fid);
    % update handles
    set(handles.strike1,'String',strike1);
    set(handles.dip1,'String',dip1);
    set(handles.rake1,'String',rake1);
    set(handles.mo1,'String',mom1);

    set(handles.strike2,'String',strike2);
    set(handles.dip2,'String',dip2);
    set(handles.rake2,'String',rake2);
    set(handles.mo2,'String',mom2);

    set(handles.tshift,'String',tshift);
    set(handles.trdist,'String',trdist);
    if str2double(conornot)==1
        set(handles.cMo,'Value',1);
    else
        set(handles.cMo,'Value',0);
    end
    set(handles.tdur,'String',tdur);
else
    disp('timefun_twop.isl not found')
end
%%

mo1=str2double(get(handles.mo1,'String'));
mo2=str2double(get(handles.mo2,'String'));

set(handles.totalmo,'String',num2str(mo1+mo2, '%6.2e'));

%% read ISOLA defaults
[gmt_ver,psview,npts] = readisolacfg;

handles.gmt_ver=gmt_ver;
handles.psview=psview;
handles.npts=npts;

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
handles.vrp=-1;  % defaults
handles.thresh=-1;
 handles.conplane=conplane;
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes timefun_twop wait for user response (see UIRESUME)
% uiwait(handles.timefun_twop);


% --- Outputs from this function are returned to the command line.
function varargout = timefun_twop_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT); hObject
% handle to figure eventdata  reserved - to be defined in a future version
% of MATLAB handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)


%% read values
strike1=get(handles.strike1,'String');
dip1=get(handles.dip1,'String');
rake1=get(handles.rake1,'String');
mom1=get(handles.mo1,'String');

strike2=get(handles.strike2,'String');
dip2=get(handles.dip2,'String');
rake2=get(handles.rake2,'String');
mom2=get(handles.mo2,'String');

tshift=get(handles.tshift,'String');
trdist=get(handles.trdist,'String');
cMo=get(handles.cMo,'Value');
tdur=get(handles.tdur,'String');

fid = fopen('timefun_twop.isl','w');
if ispc
    fprintf(fid,'%s\r\n',strike1);
    fprintf(fid,'%s\r\n',dip1);
    fprintf(fid,'%s\r\n',rake1);
    fprintf(fid,'%s\r\n',mom1);

    fprintf(fid,'%s\r\n',strike2);
    fprintf(fid,'%s\r\n',dip2);
    fprintf(fid,'%s\r\n',rake2);
    fprintf(fid,'%s\r\n',mom2);
    
    fprintf(fid,'%s\r\n',tshift);
    fprintf(fid,'%s\r\n',trdist);
    fprintf(fid,'%u\r\n',cMo);
    fprintf(fid,'%s\r\n',tdur);
else
    fprintf(fid,'%s\n',strike1);
    fprintf(fid,'%s\n',dip1);
    fprintf(fid,'%s\n',rake1);
    fprintf(fid,'%s\n',mom1);
    
    fprintf(fid,'%s\n',strike2);
    fprintf(fid,'%s\n',dip2);
    fprintf(fid,'%s\n',rake2);
    fprintf(fid,'%s\n',mom2);

    fprintf(fid,'%s\n',tshift);
    fprintf(fid,'%s\n',trdist);
    fprintf(fid,'%u\n',cMo);
    fprintf(fid,'%s\n',tdur);
end
fclose(fid);

%% exit
delete(handles.timefun_twop)

% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

warndlg('Please be patient code is running.','!! Warning !!')

% check if we have inv111.dat
pwd
if ispc
fh2=exist('.\timefunc\sel_pairs.dat','file');
else
fh2=exist('./timefunc/sel_pairs.dat','file');
end
if (fh2~=2)
    errordlg('Timefunc folder doesn''t contain sel_pairs.dat. Please Press Select first ','File Error');
    return
else

end

%%
% read selpairs
if ispc
fid = fopen('.\timefunc\sel_pairs.dat');
else
fid = fopen('./timefunc/sel_pairs.dat');
end

C = textscan(fid, '%f %f %f %f %f %f %f');

fclose(fid);
%
source1sel=C{1,1};
source2sel=C{1,2};
mom1sel=C{1,3};
mom2sel=C{1,4};
sumomsel=C{1,5};
ratmomsel=C{1,6};
VRsel=C{1,7};

%% find geographical coordinates of sources
[srclon1,srclat1,depth1,srclon2,srclat2,depth2]=get_geo_coor(source1sel,source2sel);

%% find maximum time !! (we need to change this to take into account the duration !!)
% for i=1:length(source1sel);
%    [src1time(i),src2time(i)]=inv222time(source1sel(i),source2sel(i));
% end

% change 03/09/2016 to take into account the duration 

for i=1:length(source1sel)
   [src1time(i),src2time(i)]=get_src_pair_subevent_times(source1sel(i),source2sel(i));
end
whos
%%
%% moment scale

mscale1=mean(mom1sel)
mscale2=mean(mom2sel)
mscale=(mscale1+mscale1)/2

%%   for sub 1 
if ispc
    fid = fopen('.\timefunc\timspc1.dat','w');
else
    fid = fopen('./timefunc/timspc1.dat','w');
end
 for i=1:length(srclon1)                                                   
      fprintf(fid,'%g  %g  %g %e\r\n',srclon1(i),srclat1(i),src1time(i),mom1sel(i)/mscale); 
  end
fclose(fid);

%%   for sub 2 
if ispc
    fid = fopen('.\timefunc\timspc2.dat','w');
else
    fid = fopen('./timefunc/timspc2.dat','w');
end
 for i=1:length(srclon2)                                                   
      fprintf(fid,'%g  %g  %g %e\r\n',srclon2(i),srclat2(i),src2time(i),mom2sel(i)/mscale); 
  end
fclose(fid);

%% plot in map mode in GMT 

gmt_ver=handles.gmt_ver;

%%%find map limits...it will be based on ALL sources !!
[wend,eend,send,nend]=get_source_map_coor;
border=0.1;
%wend=min(srclon1);eend=max(srclon1);send=min(srclat1);nend=max(srclat1);
w=(wend-border);e=(eend+border);s=(send-border);n=(nend+border);
r=['-R' num2str(w,'%7.5f') '/' num2str(e,'%7.5f') '/' num2str(s,'%7.5f') '/' num2str(n,'%7.5f') ' '];
j=' -JM18c+ ';
centy=((nend-send)/2)+send; centx=((eend-wend)/2)+wend;
% find min max in time 
min1=min(src1time);min2=min(src2time);max1=max(src1time);max2=max(src2time);
gmin=min([min1 min2]);gmax=max([max1 max2]);
% ly=s+scaleshift;
% 
% %%%make -L
% lf=['-Lf' num2str(centx,'%7.2f') '/' num2str(ly,'%7.4f') '/' num2str(centy,'%7.2f') '/' lscale '+l'];
% 
% xshift=-xshift;
nsrc=get(handles.info_nsrc,'String');

 if ispc 
    fid = fopen('.\timefunc\pltimspc.bat','w');
 else
    fid = fopen('./timefunc/pltimspc.bat','w'); 
 end
 
    fprintf(fid,'%s\r\n','del .gmt* ');
    
    
 if gmt_ver==4
    fprintf(fid,'%s\r\n','gmtset PLOT_DEGREE_FORMAT D  ANNOT_FONT_SIZE_PRIMARY 12 ANNOT_FONT_SIZE_SECONDARY 12 HEADER_FONT_SIZE 14 LABEL_FONT_SIZE 14');
 else
    fprintf(fid,'%s\r\n','gmtset FORMAT_GEO_MAP D  FONT_ANNOT_PRIMARY 12  FONT_ANNOT_SECONDARY 12 FONT_TITLE 14 FONT_LABEL 14');
 end
    fprintf(fid,'%s\r\n',' ');
    pscoastr=['pscoast ' r   j ' -G255/255/204 -Df -W0.7p -P -B.1  -K -Slightblue   > timspc.ps' ];
    fprintf(fid,'%s\r\n', pscoastr);
    fprintf(fid,'%s\r\n',' ');

 if gmt_ver==4
    sstring=['psxy -R ' j ' ..\gmtfiles\sources.gmt -Sd.2c  -M  -W.2p/0 -K -O -Gred >> timspc.ps' ];
 else
    sstring=['psxy -R ' j ' ..\gmtfiles\sources.gmt -Sd.2c  -W.2p -K -O -Gred >> timspc.ps' ];
 end
    fprintf(fid,'%s\r\n',sstring);
    fprintf(fid,'%s\r\n',' ');  
     
       fprintf(fid,'%s\r\n',['makecpt -Ccool -T' num2str(gmin-1) '/' num2str(gmax+1) '/1    > time.cpt']);
       fprintf(fid,'%s\r\n',' ');
 if gmt_ver==4
       fprintf(fid,'%s\r\n','psxy  timspc1.dat  -R -J -Sc -Ctime.cpt -W-3p -N -V -O -K   >> timspc.ps');
 else
       fprintf(fid,'%s\r\n','psxy  timspc1.dat  -R -J -Sc -Ctime.cpt -W3p+cl -N -V -O -K   >> timspc.ps');
 end
       fprintf(fid,'%s\r\n',' ');

 if gmt_ver==4
       fprintf(fid,'%s\r\n','psxy  timspc2.dat  -R -J -Sc -Ctime.cpt -W-3p -N -V -O -K   >> timspc.ps');
 else
       fprintf(fid,'%s\r\n','psxy  timspc2.dat  -R -J -Sc -Ctime.cpt -W3p+cl -N -V -O -K   >> timspc.ps');
 end      
       
       fprintf(fid,'%s\r\n',' ');
       
       fprintf(fid,'%s\r\n','rem plot source numbers');
 if gmt_ver==4
       fprintf(fid,'%s\r\n',['gawk "{if (NR<=' nsrc ') print $1,$2,9,0,0,\"LM\",$5}" ..\gmtfiles\sources.gmt | pstext -R -J -K -O -D0.1c/0c >> timspc.ps']);
 else
        fprintf(fid,'%s\r\n',['gawk "{if (NR<=' nsrc ') print $1,$2,$5}" ..\gmtfiles\sources.gmt | pstext -R -J -K -O -D0.1c/0c -F+f9p >> timspc.ps']);
 end
       fprintf(fid,'%s\r\n','rem plot color scale');
       
       fprintf(fid,'%s\r\n','psscale -D4.5c/22c/7.5c/.5ch -O -Ctime.cpt   -B1:"Maximum moment-rate time (s)":/:: >> timspc.ps');
       

       fprintf(fid,'%s\r\n',' ');
       
 if gmt_ver==4
       fprintf(fid,'%s\r\n','ps2raster timspc.ps -Tg -P -A -D..\output' );
 else
        fprintf(fid,'%s\r\n','psconvert timspc.ps -Tg -P -A -D..\output' );
 end
       fclose(fid);


%% sources can be in line or plane..!!
conplane=handles.conplane;
if conplane==2 
        disp('Inversion was done for a line of sources.')
     
        nsources=handles.nsources;
        distep=handles.distep;
        sdepth=handles.sdepth;

        %  total number
        nsources=str2double(get(handles.info_nsrc,'String'));
        % selected sources
        sel_sou=length(source1sel);
        % we need to convert source name to actual coordinates based on number of
        % sources in strike,dip
        noSourcesstrike=nsources;
        noSourcesdip=1;
        
        for i=1:length(source1sel)
                [src1_x(i),src1_y(i)]=findsrccoord(source1sel(i),noSourcesstrike,noSourcesdip);
                [src2_x(i),src2_y(i)]=findsrccoord(source2sel(i),noSourcesstrike,noSourcesdip);
        end

        % find timing of the two sources
        for i=1:length(source1sel)
             [src1time(i),src2time(i)]=inv222time(source1sel(i),source2sel(i));
              disp(['Source 1 no  ' num2str(source1sel(i)) ' time '   num2str(src1time(i))  ' Source 2 no ' num2str(source2sel(i))  ' time '   num2str(src2time(i))    ])
        end

% read thresh from handles
        thresh=handles.thresh; 
        vrp=handles.vrp; 

        if thresh==-1
            errordlg('Run Select first','Error');
        return
        else
            disp(['Using VR threshold ' num2str(thresh) ' or ' num2str(vrp) '%']);
        end

%% Ploting
% reference frame
        figure;  %1 
        subplot(1,2,1)
% plot plane
% rectangle('Position', [1 1 noSourcesdip+5  noSourcesstrike-1],'FaceColor', [170/255 170/255 170/255]);
% axis equal
        axis([noSourcesdip-2 noSourcesdip+2 0 noSourcesstrike+1]); grid on;
        xlabel('X');ylabel('Y');
        hold on;
% plot grid of sources
        sourceindex=0;
        for j=1:noSourcesdip
            for i=1:noSourcesstrike
                xytext(j,i)={num2str(i+sourceindex,'%02d')};
                plot(j,i,'+','MarkerSize',3)
                text(j,i,xytext{j,i},'VerticalAlignment','middle','HorizontalAlignment','center','FontWeight','bold','FontSize',12) %,'HorizontalAlignment','center');
            end
            sourceindex=sourceindex+i;
        end
        ppp=get(gca,'Position');        
%% plot vs Mo
        subplot(1,2,2)
% plot plane
  %  rectangle('Position', [1 1 noSourcesdip+5  noSourcesstrike-1],'FaceColor', [170/255 170/255 170/255]);
  %  axis equal
        axis([noSourcesdip-2 noSourcesdip+2 0 noSourcesstrike+1]); grid on;
        hold on;

% plot grid of sources
        for j=1:noSourcesdip
            for i=1:noSourcesstrike
                plot(j,i,'+','MarkerSize',3)
            end
        end

        ex=floor(log10(max(mom1sel)));
        mom1selnorm=mom1sel/(10^(ex-3));
        mom2selnorm=mom2sel/(10^(ex-3));
        
%%  if mom=0 the plotting fails.!!
        mom1selnorm(mom1selnorm==0)=0.00000001;
        mom2selnorm(mom2selnorm==0)=0.00000001;
%
 
% src1time src2time whos
        scatter(src1_x,src1_y,mom1selnorm,src1time','LineWidth',2)
        scatter(src2_x,src2_y,mom2selnorm,src2time','LineWidth',2)

%V=caxis;
%caxis([0 V(2)]);
        cb=colorbar('location','SouthOutside');
        xlabel('X');ylabel('Y');xlabel(cb,'Time (s)')
        hold off
        ppp4=get(gca,'Position');

% ppp=get(gca,'Position')
        subplot(1,2,1) % make all axis equal
        set(gca,'Position',[ppp(1) ppp4(2) ppp(3) ppp4(4)]);

%% additional plot  source no vs source and VR
        figure  %2
        axis([0 noSourcesdip*noSourcesstrike+1  0 noSourcesdip*noSourcesstrike+1]); grid on;
        hold on;
        scatter(source1sel,source2sel,60,VRsel,'filled')
%scatter(src2_x,src2_y,60,VRsel,'filled')
        V=caxis;
        caxis([thresh V(2)]);
        cb=colorbar;
        xlabel('Trial source number');ylabel('Trial source number');ylabel(cb,'VR')
        hold off

% %% plot 2 point time evolution  commented 03-09-2016
% % how many pairs
%     selpairs=handles.selectedpairs;
%     disp(['Ploting ' num2str(selpairs) ' pairs'])
% % read sel_pairs2.dat 
% if ispc
% fid = fopen('.\timefunc\sel_pairs2.dat','r');
% else
% fid = fopen('./timefunc/sel_pairs2.dat','r');
% end
% for i=1:selpairs
%     tline = fgets(fid);
%     srcpair(i,:) = sscanf(tline,'%f');
%     tline = fgets(fid); % not used
%     for j=1:24
%         tline = fgets(fid);
%         srcpairtf(i,j,:) = sscanf(tline,'%f');
%     end
%     
% end
% 
% fclose(fid);
% 
% %% plot pairs
% figure  %3
% hold
% 
% for i=1:selpairs
% % first event    
%     plot(srcpairtf(i,1:12,2),srcpairtf(i,1:12,3),'r')
% % second event
%     plot(srcpairtf(i,13:24,2),srcpairtf(i,13:24,3),'r')
% 
% end
% 
% %% 
% figure  %4
% hold
% 
% dur=str2double(get(handles.tdur,'String'));
% 
% for i=1:selpairs
% % first event  
%    for j=1:12
%           x=srcpairtf(i,j,2);y=srcpairtf(i,j,3);
%           
%           if y~=0
%           [vX,vY]=maketriangle(x,y,dur);
%           zdata = ones(1,3);
%           p1=patch(vX,vY,zdata);
%           else
%           end
% 
%    end
%    
% %    [vX(j,:),vY(j,:)]=maketriangle(x,y,dur);
% %    zdata = ones(12,3);
% %    p1=patch(vX,vY,zdata);%,'FaceColor','flat')   
% %   set(p1,'FaceColor','r')
% % % second event
%    for j=13:24
%           x=srcpairtf(i,j,2);y=srcpairtf(i,j,3);
%           
%           if y~=0
%           [vX,vY]=maketriangle(x,y,dur);
%           zdata = ones(1,3);
%           p2=patch(vX,vY,zdata);
%           else
%           end
%    end
%    
% end
    
     
%%     
elseif conplane==1 
     disp('Inversion was done for a plane of sources.')   
     %how many sources
    noSourcesstrike=handles.noSourcesstrike;
    strikestep=handles.strikestep;
    noSourcesdip=handles.noSourcesdip;
    dipstep=handles.dipstep;

%  total number
    nsources=str2double(get(handles.info_nsrc,'String'));

% selected sources
    sel_sou=length(source1sel);

% we need to convert source name to actual coordinates based on number of
% sources in strike,dip

for i=1:length(source1sel);
    [src1_x(i),src1_y(i)]=findsrccoord(source1sel(i),noSourcesstrike,noSourcesdip);
    [src2_x(i),src2_y(i)]=findsrccoord(source2sel(i),noSourcesstrike,noSourcesdip);
end

% find timing of the two sources
for i=1:length(source1sel);
      [src1time(i),src2time(i)]=inv222time(source1sel(i),source2sel(i));
      disp(['Source 1 no  ' num2str(source1sel(i)) ' time '   num2str(src1time(i))  ' Source 2 no ' num2str(source2sel(i))  ' time '   num2str(src2time(i))    ])
end

% read thresh from handles
    thresh=handles.thresh; 
    vrp=handles.vrp; 

if thresh==-1
    errordlg('Run Select first','Error');
    return
else
    disp(['Using VR threshold ' num2str(thresh) ' or ' num2str(vrp) '%']);
end


%% Ploting
% reference frame
figure;
subplot(1,2,1)
% plot plane
rectangle('Position', [1 1 noSourcesdip-1  noSourcesstrike-1],'FaceColor', [170/255 170/255 170/255]);

axis equal
axis([0 noSourcesdip+1 0 noSourcesstrike+1]); grid on;
xlabel('X');ylabel('Y');
hold on;

% plot grid of sources
sourceindex=0;
for j=1:noSourcesdip
    for i=1:noSourcesstrike
        xytext(j,i)={num2str(i+sourceindex,'%02d')};
        plot(j,i,'+','MarkerSize',3)
        text(j,i,xytext{j,i},'VerticalAlignment','middle','HorizontalAlignment','center','FontWeight','bold','FontSize',12) %,'HorizontalAlignment','center');
    end
    sourceindex=sourceindex+i;
end

ppp=get(gca,'Position');

%
%%
% subplot(1,3,2)
% 
% % plot plane
% rectangle('Position', [1 1 noSourcesdip-1  noSourcesstrike-1],'FaceColor', [170/255 170/255 170/255]);
% axis equal
% axis([0 noSourcesdip+1 0 noSourcesstrike+1]); grid on;
% hold on;
% 
% % plot grid of sources
% for j=1:noSourcesdip
%     for i=1:noSourcesstrike
%         % xytext(j,i)={num2str(i+sourceindex,'%02d')};
%         plot(j,i,'+','MarkerSize',3)
%     end
% end
% 
% % figure ;  axis equal
% %scatter(Xsel,Ysel,60,VRsel,'filled')
% scatter(src1_x,src1_y,60,VRsel,'filled')
% scatter(src2_x,src2_y,60,VRsel,'filled')
% 
% V=caxis;
% caxis([thresh V(2)]);
% cb=colorbar('location','SouthOutside');
% xlabel('X');ylabel('Y');xlabel(cb,'VR')
% hold off

%disp('Ploting')
%% plot vs Mo
    subplot(1,2,2)
% plot plane
    rectangle('Position', [1 1 noSourcesdip-1  noSourcesstrike-1],'FaceColor', [170/255 170/255 170/255]);
    axis equal
    axis([0 noSourcesdip+1 0 noSourcesstrike+1]); grid on;
    hold on;

% plot grid of sources
for j=1:noSourcesdip
    for i=1:noSourcesstrike
        plot(j,i,'+','MarkerSize',3)
    end
end

    ex=floor(log10(max(mom1sel)));
    mom1selnorm=mom1sel/(10^(ex-3));
    mom2selnorm=mom2sel/(10^(ex-3));
%
%%  if mom=0 the plotting fails.!!
        mom1selnorm(mom1selnorm==0)=0.00000001;
        mom2selnorm(mom2selnorm==0)=0.00000001;
        
        
% src1time src2time whos
    scatter(src1_x,src1_y,mom1selnorm,src1time','LineWidth',2)
    scatter(src2_x,src2_y,mom2selnorm,src2time','LineWidth',2)

%V=caxis;
%caxis([0 V(2)]);
    cb=colorbar('location','SouthOutside');
    xlabel('X');ylabel('Y');xlabel(cb,'Time (s)')
    hold off
    ppp4=get(gca,'Position');

% ppp=get(gca,'Position')
    subplot(1,2,1) % make all axis equal
    set(gca,'Position',[ppp(1) ppp4(2) ppp(3) ppp4(4)]);
%% additional plot
    figure
    axis([0 noSourcesdip*noSourcesstrike+1  0 noSourcesdip*noSourcesstrike+1]); grid on;
    hold on;
    scatter(source1sel,source2sel,60,VRsel,'filled')
%scatter(src2_x,src2_y,60,VRsel,'filled')
    V=caxis;
    caxis([thresh V(2)]);
    cb=colorbar;
    xlabel('Trial source number');ylabel('Trial source number');ylabel(cb,'VR')
    hold off
% %% plot 2 point time evolution
% % how many pairs
%     selpairs=handles.selectedpairs;
%     disp(['Ploting ' num2str(selpairs) ' pairs'])
% % read sel_pairs2.dat 
% if ispc
% fid = fopen('.\timefunc\sel_pairs2.dat','r');
% else
% fid = fopen('./timefunc/sel_pairs2.dat','r');
% end
% for i=1:selpairs
%     tline = fgets(fid);
%     srcpair(i,:) = sscanf(tline,'%f');
%     tline = fgets(fid); % not used
%     for j=1:24
%         tline = fgets(fid);
%         srcpairtf(i,j,:) = sscanf(tline,'%f');
%     end
%     
% end
% 
% fclose(fid);
% % whos srcpair srcpairtf
% % 
% % srcpair(1,:)
% % srcpairtf(1,:,:)
% 
% 
% %% plot pairs
% figure
% hold
% 
% for i=1:selpairs
% % first event    
%     plot(srcpairtf(i,1:12,2),srcpairtf(i,1:12,3),'r')
% % second event
%     plot(srcpairtf(i,13:24,2),srcpairtf(i,13:24,3),'r')
% 
% end
% 
% %% 
% figure
% hold
% 
% dur=str2double(get(handles.tdur,'String'));
% 
% for i=1:selpairs
% % first event  
%    for j=1:12
%           x=srcpairtf(i,j,2);y=srcpairtf(i,j,3);
%           
%           if y~=0
%           [vX,vY]=maketriangle(x,y,dur);
%           zdata = ones(1,3);
%           p1=patch(vX,vY,zdata);
%           else
%           end
% 
%    end
%    
% %    [vX(j,:),vY(j,:)]=maketriangle(x,y,dur);
% %    zdata = ones(12,3);
% %    p1=patch(vX,vY,zdata);%,'FaceColor','flat')   
% %   set(p1,'FaceColor','r')
% % % second event
%    for j=13:24
%           x=srcpairtf(i,j,2);y=srcpairtf(i,j,3);
%           
%           if y~=0
%           [vX,vY]=maketriangle(x,y,dur);
%           zdata = ones(1,3);
%           p2=patch(vX,vY,zdata);
%           else
%           end
%    end
%    
% end
% 
% %set(p1,'FaceColor',[1 0 0])
% %set(p2,'FaceColor',[.17 .17 .17])
% 
  
     
%% end of source configuration line or plane..!!        
end   
disp(' ')
disp(' ')
disp(' ')
disp('************* ')
disp('Use e.g. get_src_pair (7, 11) in command window to get time function for trial source 7 and 11')
disp(' ')
disp(' ')
disp(' ')
disp(' ')

%%
% figure
% 
% for i=1:12
%     
%     subtightplot(4,3,i,[0.08,0.01],[0.05 0.05],[0.001, 0.001]) % 12 subplots 1 per second
%     
%     title(['Time ' num2str(i)])
%     
%     % plot plane
%     rectangle('Position', [1 1 noSourcesdip-1  noSourcesstrike-1],'FaceColor', [170/255 170/255 170/255]);
%     axis equal
%     axis([0 noSourcesdip+1 0 noSourcesstrike+1]); grid on;
%     hold on;
%     
%     % srcpairtf(k,1,3)
%     
%     stf1=srcpairtf(:,i,3);
%     stf2=srcpairtf(:,i+12,3);
%     
%     % loop through selpais
%     for k=1:selpairs;
%         [src1_x(k),src1_y(k)]=findsrccoord(srcpair(k,1),noSourcesstrike,noSourcesdip);
%         [src2_x(k),src2_y(k)]=findsrccoord(srcpair(k,2),noSourcesstrike,noSourcesdip);
% 
%     disp(['Src ' num2str(srcpair(k,1)) ' slip rate ' num2str(stf1(k),'%10.5e')  '  Src ' num2str(srcpair(k,2)) ' slip rate ' num2str(stf2(k),'%10.5e') ' at time ' num2str(i) ])
%     
%     end
%     %disp(['Time ' num2str(i) ' src1' num2str(stf1(i)) ' src2 ' num2str(stf2)])
%     %            scatter(src1_x',src1_y',15,srcpairtf(:,1:12,3),'LineWidth',2)
%     %            scatter(src2_x',src2_y',15,srcpairtf(:,13:24,3),'LineWidth',2)
%     scatter(src1_x',src1_y',25,stf1,'LineWidth',5)
%     scatter(src2_x',src2_y',25,stf2,'LineWidth',5)
% 
%     if i==12
%              ppp12=get(gca,'Position');
%     else
%     end
%     
% end
%     %colorbar
%     %min(srcpairtf(:,:,3))
%     maxsl=max(max(srcpairtf(:,:,3)));
% 
%     % fix the size of last panel 
% V=caxis;
% caxis([V(1) maxsl]);
% cb3=colorbar;
% ppp13=get(gca,'Position');
% ylabel(cb3,'Nm')
% set(gca,'Position',[ppp13(1) ppp13(2) ppp12(3) ppp13(4)]);


% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

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

%% decide if we need same or different focal mechanims

if get(handles.samesources,'Value') == 1
   disp('Same FM') 
   
   fcode='time_loop_twosame.exe';
   
else
    
   disp('Different  FM') 
   fcode='time_loop_twodiff.exe';
   
end

%%
% prepare the two acka files
strike1 = str2double(get(handles.strike1,'String'));
dip1 = str2double(get(handles.dip1,'String'));
rake1 = str2double(get(handles.rake1,'String'));
xmoment1 = str2double(get(handles.mo1,'String'));

[a1,a2,a3,a4,a5,a6]=sdr2as(strike1,dip1,rake1,xmoment1);  %  

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

[a1,a2,a3,a4,a5,a6]=sdr2as(strike2,dip2,rake2,xmoment2);  %  

fid = fopen('.\timefunc\acka2.dat','w');
fprintf(fid,'%9.4e\r\n',a1);
fprintf(fid,'%9.4e\r\n',a2);
fprintf(fid,'%9.4e\r\n',a3);
fprintf(fid,'%9.4e\r\n',a4);
fprintf(fid,'%9.4e\r\n',a5);
fprintf(fid,'%9.4e\r\n',a6);
fclose(fid);

%% get the elemse files
% how many sources..?
nsources=str2double(get(handles.info_nsrc,'String'));

src=num2str((1:nsources)');

% add waitbar
h = waitbar(0,'Please wait files are copied...');

for i=1:nsources
    
    if str2double(src(i,:))<10
        elemfilename=['elemse0' strtrim((src(i,:))) '.dat'];
    else
        elemfilename=['elemse' src(i,:) '.dat'];
    end
    % go in invert and copy
    try
        cd invert
        if exist(elemfilename,'file')
            [s,m]=copyfile(elemfilename,'..\timefunc');
            
            waitbar(i/nsources)
            
        else
            disp(['File ' elemfilename ' is missing'])
            errordlg(['File ' elemfilename '  not found in invert folder. Run Green Preparation for this station' ] ,'File Error');
        end
        cd ..
    catch
        cd ..
    end
    %
    
end

close(h)


%% Prepare a file with options
% read values check if we need to constrain Mo
if(get(handles.cMo,'Value')==1)
    conMo=1;
    moment=str2double(get(handles.totalmo,'String'));
else
    conMo=0;
end

%notriang = get(handles.notriang,'String');
% notriang =12; %FIXED
srcshft=get(handles.tshift,'String');
tdur=get(handles.tdur,'String');
trdist=get(handles.trdist,'String');

fid = fopen('.\timefunc\casopt.dat','w');
%           fprintf(fid,'%d\r\n',nsources); fprintf(fid,'%s\r\n',notriang);

fprintf(fid,'%s\r\n',srcshft);
fprintf(fid,'%s\r\n',tdur);
fprintf(fid,'%s\r\n',trdist);
if(conMo==0)
    fprintf(fid,'%d\r\n',conMo);
elseif(conMo==1)
    fprintf(fid,'%d\r\n',conMo);
    fprintf(fid,'%d\r\n',moment);
    
end

fprintf(fid,'%u\r\n',nsources);

fclose(fid);


%%  Prepare a batch file for running the code..
if ispc
   fid = fopen('.\timefunc\runtimloop.bat','w');
      %fprintf(fid,'%s\r\n','time_loop_two.exe');
      fprintf(fid,'%s\r\n',fcode);
   fclose(fid);
else
   fid = fopen('./timefunc/runtimloop.bat','w');
      fprintf(fid,'%s\n',fcode);
   fclose(fid);
end

%%  RUN the batch file
button = questdlg('Run Inversion ?','Inversion ','Yes','No','Yes');
if strcmp(button,'Yes')
    disp('Running inversion')
    cd timefunc
    system('runtimloop.bat &') % return to ISOLA folder
    cd ..
    pwd
elseif strcmp(button,'No')
    disp('Canceled ')
end


% --- Executes on button press in checkfiles.
function checkfiles_Callback(hObject, eventdata, handles)
% hObject    handle to checkfiles (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if INVERT exists..!
h=dir('timefunc');

if isempty(h);
    errordlg('timefunc folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


try
    cd timefunc
    
    h=dir('inv111.dat');
    
    if isempty(h);
        errordlg('Inv111.dat file doesn''t exist. Run timefunction code. ','File Error');
        return
    else
        if ispc
            dos('notepad inv111.dat &')
            dos('notepad inv222.dat &')
        else
            unix('gedit inv111.dat &')
            unix('gedit inv222.dat &')
        end
    end
    
    cd ..
    
catch
    cd ..
end



function tshift_Callback(hObject, eventdata, handles)
% hObject    handle to tshift (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tshift as text
%        str2double(get(hObject,'String')) returns contents of tshift as a
%        double


% --- Executes during object creation, after setting all properties.
function tshift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tshift (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tshift2_Callback(hObject, eventdata, handles)
% hObject    handle to tshift2 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tshift2 as text
%        str2double(get(hObject,'String')) returns contents of tshift2 as a
%        double


% --- Executes during object creation, after setting all properties.
function tshift2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tshift2 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2



function trdist_Callback(hObject, eventdata, handles)
% hObject    handle to trdist (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trdist as text
%        str2double(get(hObject,'String')) returns contents of trdist as a
%        double


% --- Executes during object creation, after setting all properties.
function trdist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trdist (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cMo.
function cMo_Callback(hObject, eventdata, handles)
% hObject    handle to cMo (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cMo



function tdur_Callback(hObject, eventdata, handles)
% hObject    handle to tdur (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tdur as text
%        str2double(get(hObject,'String')) returns contents of tdur as a
%        double


% --- Executes during object creation, after setting all properties.
function tdur_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tdur (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    empty - handles not created
% until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in nosourcepopup2.
function nosourcepopup2_Callback(hObject, eventdata, handles)
% hObject    handle to nosourcepopup2 (see GCBO) eventdata  reserved - to
% be defined in a future version of MATLAB handles    structure with
% handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns nosourcepopup2
% contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        nosourcepopup2


% --- Executes during object creation, after setting all properties.
function nosourcepopup2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nosourcepopup2 (see GCBO) eventdata  reserved - to
% be defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strike2_Callback(hObject, eventdata, handles)
% hObject    handle to strike2 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike2 as text
%        str2double(get(hObject,'String')) returns contents of strike2 as a
%        double


% --- Executes during object creation, after setting all properties.
function strike2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike2 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip2_Callback(hObject, eventdata, handles)
% hObject    handle to dip2 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip2 as text
%        str2double(get(hObject,'String')) returns contents of dip2 as a
%        double


% --- Executes during object creation, after setting all properties.
function dip2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip2 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    empty - handles not created
% until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rake2_Callback(hObject, eventdata, handles)
% hObject    handle to rake2 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake2 as text
%        str2double(get(hObject,'String')) returns contents of rake2 as a
%        double


% --- Executes during object creation, after setting all properties.
function rake2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake2 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    empty - handles not created
% until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mo2_Callback(hObject, eventdata, handles)
% hObject    handle to mo2 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mo2 as text
%        str2double(get(hObject,'String')) returns contents of mo2 as a
%        double

% update total moment
mo1=str2double(get(handles.mo1,'String'));
mo2=str2double(get(handles.mo2,'String'));

set(handles.totalmo,'String',num2str(mo1+mo2, '%6.2e'));



% --- Executes during object creation, after setting all properties.
function mo2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mo2 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    empty - handles not created
% until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in nosourcepopup1.
function nosourcepopup1_Callback(hObject, eventdata, handles)
% hObject    handle to nosourcepopup1 (see GCBO) eventdata  reserved - to
% be defined in a future version of MATLAB handles    structure with
% handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns nosourcepopup1
% contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        nosourcepopup1


% --- Executes during object creation, after setting all properties.
function nosourcepopup1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nosourcepopup1 (see GCBO) eventdata  reserved - to
% be defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function strike1_Callback(hObject, eventdata, handles)
% hObject    handle to strike1 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike1 as text
%        str2double(get(hObject,'String')) returns contents of strike1 as a
%        double


% --- Executes during object creation, after setting all properties.
function strike1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike1 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dip1_Callback(hObject, eventdata, handles)
% hObject    handle to dip1 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip1 as text
%        str2double(get(hObject,'String')) returns contents of dip1 as a
%        double


% --- Executes during object creation, after setting all properties.
function dip1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip1 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    empty - handles not created
% until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rake1_Callback(hObject, eventdata, handles)
% hObject    handle to rake1 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake1 as text
%        str2double(get(hObject,'String')) returns contents of rake1 as a
%        double


% --- Executes during object creation, after setting all properties.
function rake1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake1 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    empty - handles not created
% until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mo1_Callback(hObject, eventdata, handles)
% hObject    handle to mo1 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    structure with handles and user
% data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mo1 as text
%        str2double(get(hObject,'String')) returns contents of mo1 as a
%        double


% update total moment
mo1=str2double(get(handles.mo1,'String'));
mo2=str2double(get(handles.mo2,'String'));

set(handles.totalmo,'String',num2str(mo1+mo2, '%6.2e'));




% --- Executes during object creation, after setting all properties.
function mo1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mo1 (see GCBO) eventdata  reserved - to be defined
% in a future version of MATLAB handles    empty - handles not created
% until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [a1,a2,a3,a4,a5,a6]=sdr2as(strike,dip,rake,xmoment)

%   strike=deg2rad(strike);
%	dip=deg2rad(dip); rake=deg2rad(rake);

%   strike=strike*pi2/180.
%  	dip=dip*pi2/180. rake=rake*pi2/180.

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

% disp(['Strike= ' num2str(strike) ' Dip= ' num2str(dip) ' Rake= '
% num2str(rake) ' Moment= ' num2str(xmoment)]) disp(['a1  ' '  a2  ' '  a3
% ' '  a4  ' '  a5  ' '  a6  '])
% disp(a1);disp(a2);disp(a3);disp(a4);disp(a5);disp(a6)


% --- Executes on button press in chksel.
function chksel_Callback(hObject, eventdata, handles)
% hObject    handle to chksel (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if INVERT exists..!
h=dir('timefunc');

if isempty(h);
    errordlg('timefunc folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


try
    cd timefunc
    
    h=dir('sel_pairs.dat');
    
    if isempty(h);
        errordlg('sel_pairs.dat file doesn''t exist. Run timefunction code. ','File Error');
        return
    else
        if ispc
            dos('notepad sel_pairs.dat &');
            dos('notepad sel_pairs2.dat &');
        else
            unix('gedit sel_pairs.dat &');
            unix('gedit sel_pairs2.dat &')
        end
    end
    
    cd ..
    
catch
    cd ..
end


% --- Executes on button press in select.
function select_Callback(hObject, eventdata, handles)
% hObject    handle to select (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% check if we have inv111.dat
fh2=exist('.\timefunc\inv111.dat','file');
if (fh2~=2);
    errordlg('Timefunc folder doesn''t contain inv111.dat. Please Press Calculate first ','File Error');
else
    
end

fid = fopen('.\timefunc\inv111.dat');

C = textscan(fid, '%f %f %f %f %f %f %f','HeaderLines', 11);

fclose(fid);


% find maximum value of VR
source1=C{1,1};
source2=C{1,2};
mom1=C{1,3};
mom2=C{1,4};
sumom=C{1,5};
ratmom=C{1,6};
VR=C{1,7};

VRmax=max(C{1,7});

prompt={['Maximum VR is ' num2str(VRmax)  '.Enter the VR percent threshold for selection:']};
numlines=1;
name='VR selection';
defaultanswer={'90'};

options.Resize='on';options.WindowStyle='normal';
answer=inputdlg(prompt,name,numlines,defaultanswer,options);

% find the VR percent
vrp=str2num(answer{1});

percvar=(VRmax*(100-vrp))/100;   %
thresh=VRmax-percvar;

ind=find(VR > thresh);

%%
if length(ind)==1

    warndlg('Only 1 solution found. Use another threshold')

else

% select based on thresh
source1sel=source1(ind);
source2sel=source2(ind);
mom1sel=mom1(ind);
mom2sel=mom2(ind);
sumomsel=sumom(ind);
ratmomsel=ratmom(ind);
VRsel=VR(ind);

disp('Selected pairs and VR')


for i=1:length(source1sel)
    disp([num2str(source1sel(i)) '  ' num2str(source2sel(i))  '   ' num2str(VRsel(i))])
end



%% put in file
if ispc
    fid = fopen('.\timefunc\sel_pairs.dat','w');
    for i=1:length(source1sel)
        fprintf(fid,'%u %u %e %e %e %e %f\r\n',source1sel(i), source2sel(i), mom1sel(i),mom2sel(i),sumomsel(i),ratmomsel(i),VRsel(i));
    end
    fclose(fid);
else
    fid = fopen('./timefunc/sel_pairs.dat','w');
    for i=1:length(source1sel)
        fprintf(fid,'%u %u %e %e %e %e %f\n',source1sel(i), source2sel(i), mom1sel(i),mom2sel(i),sumomsel(i),ratmomsel(i),VRsel(i));
    end
    fclose(fid);
end

%% inv222.dat file selection
% read file

% check if we have inv222.dat
fh2=exist('.\timefunc\inv222.dat','file');
if (fh2~=2);
    errordlg('Timefunc folder doesn''t contain inv222.dat. Please Press Calculate first ','File Error');
else
    
    %       % learn how many sources we have
    %        nsources=str2double(get(handles.info_nsrc,'String'));
    %       % possible pairs npairs=(nsources*(nsources-1))/2
    
    fid = fopen('.\timefunc\inv222.dat');
    
    tline = fgetl(fid); % first empty line
    
    npair=1;
    
    while ischar(tline)
        for i=1:2
            %    disp(tline)
            tline = fgetl(fid); % second
            pp(i,:,npair) = [0 ; sscanf(tline,'%f')];
        end
        
        for j=1:120
            %   disp(tline)
            tline = fgetl(fid); % second
            pp(j+2,:,npair) = [sscanf(tline,'%f')];
        end
        tline = fgetl(fid); %  empty line
        npair=npair+1;
    end
    
    fclose(fid);
    
end

%  select based on ind
ppsel=pp(:,:,ind);
ntf=size(ppsel);

% put in file
if ispc
    fid = fopen('.\timefunc\sel_pairs2.dat','w');
    for i=1:ntf(3)
        for j=1:2
            fprintf(fid,'%u %u \r\n',ppsel(j,2:3,i));
        end
        for j=3:122
            fprintf(fid,'%u %e %e\r\n',ppsel(j,:,i));
        end
    end
    fclose(fid);
else
    
    
end


%
% how many sources
% noSourcesstrike=handles.noSourcesstrike;
% strikestep=handles.strikestep;
% noSourcesdip=handles.noSourcesdip;
% dipstep=handles.dipstep;

% %  total number
% nsources=str2double(get(handles.info_nsrc,'String'));
% 
% % selected sources
% sel_sou=length(source1sel);
% 
% % we need to convert source name to actual coordinates based on number of
% % sources in strike,dip
% 
% for i=1:length(source1sel);
%     [src1_x(i),src1_y(i)]=findsrccoord(source1sel(i),noSourcesstrike,noSourcesdip);
%     [src2_x(i),src2_y(i)]=findsrccoord(source2sel(i),noSourcesstrike,noSourcesdip);
% end
% 
% 
% % find timing of the two sources
% for i=1:length(source1sel);
%     [src1time(i),src2time(i)]=inv222time(source1sel(i),source2sel(i));
%     disp(['Source 1 no  ' num2str(source1sel(i)) ' time '   num2str(src1time(i))  ' Source 2 no ' num2str(source2sel(i))  ' time '   num2str(src2time(i))    ])
%     
% end

handles.selectedpairs=length(source1sel);
handles.vrp=vrp;  
handles.thresh=thresh;
% Update handles structure
guidata(hObject, handles);

set(handles.plot,'Enable','On')

helpdlg('You can now continue with plotting','Selection')

end %% this is end of if about number of solutions



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to strike2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike2 as text
%        str2double(get(hObject,'String')) returns contents of strike2 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to dip2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip2 as text
%        str2double(get(hObject,'String')) returns contents of dip2 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function totalmo_Callback(hObject, eventdata, handles)
% hObject    handle to totalmo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of totalmo as text
%        str2double(get(hObject,'String')) returns contents of totalmo as a double


% --- Executes during object creation, after setting all properties.
function totalmo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to totalmo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plottfun4pair.
function plottfun4pair_Callback(hObject, eventdata, handles)
% hObject    handle to plottfun4pair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%pwd

prompt = {'1st Source number:','2nd Source number:'};
dlgtitle = 'Give the two source numbers';
dims = [1 35];
definput = {'',''};
answer = inputdlg(prompt,dlgtitle,dims,definput);

srcA=str2num(char(answer(1)))
srcB=str2num(char(answer(2)))
%whos
%% plot
 get_src_pair(srcA,srcB);


% --- Executes on button press in samesources.
function samesources_Callback(hObject, eventdata, handles)
% hObject    handle to samesources (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of samesources

if (get(hObject,'Value') == get(hObject,'Max'))
    	disp('Same Focal mechanisms.');
    	disp('Removing acka2.dat.');
        delete('.\timefunc\acka2.dat')
        set(handles.uipanel8,'Visible','Off');

else
        disp('Different focal mechanisms.');
        set(handles.uipanel8,'Visible','On');
    
end
