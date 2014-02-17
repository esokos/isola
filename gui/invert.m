function varargout = invert(varargin)
% INVERT M-file for invert.fig
%      INVERT, by itself, creates a new INVERT or raises the existing
%      singleton*.
%
%      H = INVERT returns the handle to a new INVERT or the handle to
%      the existing singleton*.
%
%      INVERT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INVERT.M with the given input arguments.
%
%      INVERT('Property','Value',...) creates a new INVERT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before invert_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to invert_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help invert

% Last Modified by GUIDE v2.5 15-Nov-2012 10:52:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @invert_OpeningFcn, ...
                   'gui_OutputFcn',  @invert_OutputFcn, ...
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


% --- Executes just before invert is made visible.
function invert_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to invert (see VARARGIN)

% Choose default command line output for invert
handles.output = hObject;
%%
disp('This is invert 12/04/09');
% check if INVERT exists..!

pwd

h=dir('invert');

if isempty(h);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%
h=dir('correl.isl');

if isempty(h); 
        scalex='21';
        scaley='18';
        fscale='.35';
        fontsize='10';
        gmtpal='cool';

        %%% first time put defaults...!!
        fid = fopen('correl.isl','w');
          if ispc
               fprintf(fid,'%s\r\n',scalex);
               fprintf(fid,'%s\r\n',scaley);
               fprintf(fid,'%s\r\n',fscale);
               fprintf(fid,'%s\r\n',gmtpal);
               fprintf(fid,'%s\r\n',fontsize);
          else
               fprintf(fid,'%s\n',scalex);
               fprintf(fid,'%s\n',scaley);
               fprintf(fid,'%s\n',fscale);
               fprintf(fid,'%s\n',gmtpal);
               fprintf(fid,'%s\n',fontsize);
          end
        fclose(fid);
else
    fid = fopen('correl.isl','r');
    scalex=fscanf(fid,'%g',1);
    scaley=fscanf(fid,'%g',1);
    fscale=fscanf(fid,'%g',1);
    gmtpal=fscanf(fid,'%s',1);
    fontsize=fscanf(fid,'%g',1);
    fclose(fid);
end

%% check if all ISOLA input files exist..
h=dir('duration.isl');

if isempty(h); 
  errordlg('Duration.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('duration.isl','r');
    tl=fscanf(fid,'%g',1);
    fclose(fid);
end

dtres=tl/8192;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minimumd = num2str(-2500*dtres);
maximumd = num2str(2500*dtres);

    set(handles.minshifts,'String',minimumd,...
                        'ForegroundColor','red')        

    set(handles.maxshifts,'String',maximumd,...
                        'ForegroundColor','red')        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h=dir('tsources.isl');

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
          
        conplane=2;   %%% Line
        % dummy sdepth
        sdepth=-333;
        % Update handles structure
        guidata(hObject, handles);
        
     elseif strcmp(tsource,'depth')
        disp('Inversion was done for a line of sources under epicenter.')
        nsources=fscanf(fid,'%i',1);
        distep=fscanf(fid,'%f',1);
        sdepth=fscanf(fid,'%f',1);
        invtype=fscanf(fid,'%c');
        
         conplane=0;   %%%depth

         handles.sdepth=sdepth;
         % Update handles structure
         guidata(hObject, handles);
    
     elseif strcmp(tsource,'plane')
        disp('Inversion was done for a plane of sources.')
        nsources=fscanf(fid,'%i',1);
%         distep=fscanf(fid,'%f',1);
           noSourcesstrike=fscanf(fid,'%i',1)
           strikestep=fscanf(fid,'%f',1)
           noSourcesdip=fscanf(fid,'%i',1)
           dipstep=fscanf(fid,'%f',1)
%           nsources=noSourcesstrike*noSourcesdip;
          
           invtype='   Multiple Source line or plane ';%(Trial Sources on a plane or line)';
      
           conplane=1;
           
           set(handles.udistdep,'Enable','Off') %   disp('Distance corel plot is not available for plane source model. Source number will be used.')
           %% dummy sdepth
           sdepth=-333;
            distep=-333;
            
           enableon([handles.plgeocor]);
           %%%%%%%%%%%%%%%%%write to handles
           handles.noSourcesstrike=noSourcesstrike;
           handles.strikestep=strikestep;
           handles.noSourcesdip=noSourcesdip;
           handles.dipstep=dipstep;
           % Update handles structure
           guidata(hObject, handles);
           
     elseif strcmp(tsource,'point')
       disp('Inversion was done for one source.')
       nsources=fscanf(fid,'%i',1);
       distep=fscanf(fid,'%f',1);
       sdepth=fscanf(fid,'%f',1);
       invtype=fscanf(fid,'%c');
        
       
        enableoff([handles.corelplot handles.png]);
        conplane=3;
        % Update handles structure
        guidata(hObject, handles);
       
     end
     
          fclose(fid);
          
end

%%
h=dir('stations.isl');

if isempty(h); 
    errordlg('Stations.isl file doesn''t exist. Run Station select. ','File Error');
  return    
else
    fid = fopen('stations.isl','r');
    nstations=fscanf(fid,'%i',1);
    fclose(fid);
end


%%%%check if inpinv.dat exists....
if ispc
 a=exist('.\invert\inpinv.dat');
else
 a=exist('./invert/inpinv.dat');
end
  
if a == 2
      if ispc
          fid = fopen('.\invert\inpinv.dat','r');
      else
          fid = fopen('./invert/inpinv.dat','r');
      end
            linetmp=fgets(fid);         %01 line
            id=fscanf(fid,'%g',1);
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);        %01 line
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %01 line
            itime=fscanf(fid,'%g',3);
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %01 line
            nevents=fscanf(fid,'%g',1);
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %01 line
            ifilter=fscanf(fid,'%g',4);
       fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if id == 1
    set(handles.fullmt,'Value',1)
    set(handles.free,'Value',0)
    set(handles.dc,'Value',0)
    set(handles.fixed,'Value',0)
elseif id ==2
    set(handles.fullmt,'Value',0)
    set(handles.free,'Value',1)
    set(handles.dc,'Value',0)
    set(handles.fixed,'Value',0)
elseif id ==3
    set(handles.fullmt,'Value',0)
    set(handles.free,'Value',0)
    set(handles.dc,'Value',1)
    set(handles.fixed,'Value',0)
elseif id ==4
    set(handles.fullmt,'Value',0)
    set(handles.free,'Value',0)
    set(handles.dc,'Value',0)
    set(handles.fixed,'Value',1)

    %%%%enable....
on =[handles.strike,handles.dip,handles.rake,handles.striketext,handles.diptext,handles.raketext];
enableon(on)
    
%%% search for mechan.dat in invert folder and add the values here
if ispc 
  a=exist('.\invert\mechan.dat'); 
else
  a=exist('./invert/mechan.dat'); 
end
  
if a == 2
      try 
          if ispc
          fid = fopen('.\invert\mechan.dat','r');
          else
          fid = fopen('./invert/mechan.dat','r');
          end
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %02 line
            linetmp=fgets(fid);         %03 line
            linetmp=fgets(fid);         %04 line
            sdr=fscanf(fid,'%g',3);
          fclose(fid);
         
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       set(handles.strike,'String',num2str(sdr(1,1)));        
       set(handles.dip,'String',num2str(sdr(2,1)));         
       set(handles.rake,'String',num2str(sdr(3,1)));          
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           disp('Found mechan.dat in .\invert folder. Updating ....')  
       catch
%             %%% mechan.dat is not present ...
              disp('Could not read data from mechan.dat in .\invert folder. Check format.')    
        end 
else
%%% mechan.dat is not present ...
disp('Could not find mechan.dat in .\invert folder. Probably this is first run with fixed mechanism.')    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

end  %end of id if 
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stime = itime(1,1)*dtres;
tstep = itime(2,1)*dtres;
etime = itime(3,1)*dtres;
set(handles.starttime,'String',num2str(stime));        
set(handles.timestep,'String',num2str(tstep));         
set(handles.endtime,'String',num2str(etime));          

set(handles.stdt,'String',num2str(itime(1,1)));
set(handles.tsdt,'String',num2str(itime(2,1)));
set(handles.etdt,'String',num2str(itime(3,1)));

set(handles.sliderstdt,'Value',itime(1,1));
set(handles.slidertsdt,'Value',itime(2,1));
set(handles.slideretdt,'Value',itime(3,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.f1,'String',num2str(ifilter(1,1)));        
set(handles.f2,'String',num2str(ifilter(2,1)));         
set(handles.f3,'String',num2str(ifilter(3,1)));          
set(handles.f4,'String',num2str(ifilter(4,1)));          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.nsubevents,'String',num2str(nevents));          

else              %%% inpinv is not present ...

valst=get(handles.sliderstdt,'Value');
set(handles.stdt,'String',num2str(round(valst)));

valts=get(handles.slidertsdt,'Value');
set(handles.tsdt,'String',num2str(round(valts)));

valet=get(handles.slideretdt,'Value');
set(handles.etdt,'String',num2str(round(valet)));

%%%%%
stime = str2double(get(handles.stdt,'String'));
tstep = str2double(get(handles.tsdt,'String'));  
etime = str2double(get(handles.etdt,'String'));

set(handles.starttime,'String',num2str(stime*dtres));        
set(handles.timestep,'String',num2str(tstep*dtres));         
set(handles.endtime,'String',num2str(etime*dtres));          

%% we must create an inpinv.dat or else stagui will not work...!!
% read values
% type of inversion
if get(handles.fullmt,'Value') == get(handles.fullmt,'Max')
    disp('Full MT inversion selected')
    inv=1;
elseif get(handles.free,'Value') == get(handles.free,'Max')
    disp('Deviatoric MT inversion selected')
    inv=2;
elseif get(handles.dc,'Value') == get(handles.dc,'Max')
    disp('DC MT inversion selected')
    inv=3;
elseif get(handles.fixed,'Value') == get(handles.fixed,'Max')
    disp('Fixed DC mechanism inversion')
    inv=4;
else
    %%% case nothing is selected....!!
    errordlg('Please select type of inversion','!! Error !!')
    return
end
%
ifirst = str2double(get(handles.stdt,'String'));
istep = str2double(get(handles.tsdt,'String'));  
ilast = str2double(get(handles.etdt,'String'));
%
%%
nsubevents= str2double(get(handles.nsubevents,'String'));

if nsubevents > 20
        errordlg('Number of subevents should be < 20','Error');
        return
else
end
%%
f1 = str2double(get(handles.f1,'String'));
f2 = str2double(get(handles.f2,'String'));
f3 = str2double(get(handles.f3,'String'));
f4 = str2double(get(handles.f4,'String'));

%% write
if ispc
  fid = fopen('.\invert\inpinv.dat','w');
    fprintf(fid,'%s\r\n','    mode of inversion: 1=full MT, 2=deviatoric MT (recommended), 3= DC MT, 4=known fixed DC MT');
    fprintf(fid,'%i\r\n',inv);
    fprintf(fid,'%s\r\n','    time step of XXXRAW.DAT files (in sec)');
    fprintf(fid,'%g\r\n',dtres);
    fprintf(fid,'%s\r\n','    number of trial source positions (isourmax), max. 51');
    fprintf(fid,'%i\r\n',nsources);
    fprintf(fid,'%s\r\n','    trial time shifts (max. 100 shifts): from (>-2500), step, to (<2500)');
    fprintf(fid,'%s\r\n','    example: -10,5,50 means -10dt to 50dt, step = 5dt, i.e. 12 shifts');
    fprintf(fid,'%i %i %i\r\n',ifirst, istep, ilast);
    fprintf(fid,'%s\r\n','    number of subevents to be searched (isubmax), max. 20');
    fprintf(fid,'%i\r\n',nsubevents);
    fprintf(fid,'%s\r\n','    filter (f1,f2,f3,f4); flat band-pass between f2, f3');
    fprintf(fid,'%s\r\n','    cosine tapered between f1, f2 and between f3, f4');
    fprintf(fid,'%g %g %g %g\r\n',f1,f2,f3,f4);
    fprintf(fid,'%s\r\n','    guess of data variance (important only for absolute value of the parameter variance)');
    fprintf(fid,'%s\r\n','2.0e-12');
  fclose(fid);
  

else
  fid = fopen('inpinv.dat','w');
    fprintf(fid,'%s\n','    mode of inversion: 1=full MT, 2=deviatoric MT (recommended), 3= DC MT, 4=known fixed DC MT');
    fprintf(fid,'%i\n',inv);
    fprintf(fid,'%s\n','    time step of XXXRAW.DAT files (in sec)');
    fprintf(fid,'%g\n',dtres);
    fprintf(fid,'%s\n','    number of trial source positions (isourmax), max. 51');
    fprintf(fid,'%i\n',nsources);
    fprintf(fid,'%s\n','    trial time shifts (max. 100 shifts): from (>-2500), step, to (<2500)');
    fprintf(fid,'%s\n','    example: -10,5,50 means -10dt to 50dt, step = 5dt, i.e. 12 shifts');
    fprintf(fid,'%i %i %i\n',ifirst, istep, ilast);
    fprintf(fid,'%s\n','    number of subevents to be searched (isubmax), max. 20');
    fprintf(fid,'%i\n',nsubevents);
    fprintf(fid,'%s\n','    filter (f1,f2,f3,f4); flat band-pass between f2, f3');
    fprintf(fid,'%s\n','    cosine tapered between f1, f2 and between f3, f4');
    fprintf(fid,'%g %g %g %g\n',f1,f2,f3,f4);
    fprintf(fid,'%s\n','    guess of data variance (important only for absolute value of the parameter variance)');
    fprintf(fid,'%s\n','2.0e-12');
  fclose(fid);
end






end

%% remove corr*.dat files  % disabled 28/08/2013
% cd invert
% 
% delete('corr*.dat')
% 
% cd ..

%% Try to populate GMT palette popupmenu....
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

%% prepare event id...

h=dir('event.isl');

if isempty(h); 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
%%%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    
    eventdate=fscanf(fid,'%s',1);
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    eventagency=fscanf(fid,'%s',1);
    fclose(fid);
end

eventid=[eventdate '_' eventhour '_' eventmin '_' eventsec  ];

%% find time function used...
h=dir('stype.isl');

if isempty(h); 
  disp('stype.isl file doesn''t exist. Suppose that Delta time function was used.');
  
        fid = fopen('stype.isl','w');
           if ispc
                fprintf(fid,'%s\r\n','delta');
           else
                fprintf(fid,'%s\n','delta');
           end
        fclose(fid);

        % select delta as time function
        set(handles.delta,'Value',1)
        set(handles.triangle,'Value',0)
        stypeorig=1;
else
        fid = fopen('stype.isl','r');
         stftype=fscanf(fid,'%s',1);
        fclose(fid);    

 switch  stftype 
    case 'delta'
      disp('Delta source time function has been used.')
      stypeorig=1;
      
        set(handles.delta,'Value',1)
        set(handles.triangle,'Value',0)
        stfdur='0';
         
    case 'triangle'
      disp('Triangle source time function has been used.')  
      stypeorig=2;

      fid = fopen('stype.isl','r');
         tline = fgetl(fid);
         tline = fgetl(fid);
         stfdur=sscanf(tline,'%s',1);
      fclose(fid);  
      
        set(handles.triangle,'Value',1)
        set(handles.sdur,'String',stfdur)
        
        enableon(handles.sdur)
        enableon(handles.duration)
        set(handles.delta,'Value',0)

 end


end
%% Code to compute overall S/N ratio based on snr files found in isola run
%  folder. These files are created with a special spectral analysis tool.
% get values for low and high freq
lowfreq=str2double(get(handles.f1,'String'));
highfreq=str2double(get(handles.f4,'String'));
% dummy values
snrNS=NaN;snrEW=NaN;snrZ=NaN;  
% first read allstat.dat
if ispc
   h=dir('.\invert\allstat.dat');
else
   h=dir('./invert/allstat.dat');
end
if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
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
                   if ispc
                     [NS,d1,d2,d3,d4,freq11,~,~,freq44] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                   else
                     [NS,d1,d2,d3,d4,freq11,~,~,freq44] = textread('./invert/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                   end

                 nostations = length(NS);
                     for i=1:nostations       %% it must search in current folder..!!
                         if ispc 
                            realdatafilename{i}=['.\' char(NS(i)) 'snr.dat'];
                         else
                            realdatafilename{i}=['./' char(NS(i)) 'snr.dat'];
                         end
                     end
                % in this  case we can calculate SNR
                % check if we have files and compute overall SNR  
              
                for i=1:nostations
                  if exist(char(realdatafilename{i}),'file')
                      disp(['Found ' realdatafilename{i} ])
                        % now open files and compute SNR
                        % if station is included in inversion
                        if d1(i)==1
                            disp(['Calculating SNR for station  ' char(NS(i)) ' and freq ' num2str(freq11(i)) ' - ' num2str(freq44(i))])
                            [snrNS(i),snrEW(i),snrZ(i)]=avesnr(realdatafilename{i},freq11(i),freq44(i)); 
                            % check components
                                    if d2(i) ==  0 
                                         snrNS(i)=NaN;         
                                    end        
                                    if d3(i) == 0           
                                         snrEW(i)=NaN;            
                                    end
                                    if d4(i) ==  0          
                                         snrZ(i)=NaN;
                                    end
                            disp('  ')
                        else
                            disp(['Station ' char(NS(i))   'not included in inversion'])
                            snrNS(i)=NaN;snrEW(i)=NaN;snrZ(i)=NaN;     
                            disp('  ')
                        end
                  else 
                      disp(['File ' realdatafilename{i} ' is missing. Nan will be used'])
                      snrNS(i)=NaN;snrEW(i)=NaN;snrZ(i)=NaN;  
                      
                  end
                end            
%                  disp(['Mean SNR over all stations ' num2str(nanmean(snr))])
%                  set(handles.snrvalue,'String',num2str(fix(nanmean(snr))))
% length(snrNS)
% length(snrNS(~isnan(snrNS)))
% length(snrEW)
% length(snrEW(~isnan(snrEW)))
% length(snrZ)
% length(snrZ(~isnan(snrZ)))

sumNS=sum(snrNS(~isnan(snrNS)));
sumEW=sum(snrEW(~isnan(snrEW)));
sumZ =sum(snrZ(~isnan(snrZ)));

ncomp=length(snrNS(~isnan(snrNS)))+length(snrEW(~isnan(snrEW)))+length(snrZ(~isnan(snrZ)));

snrvalue=(sumNS+sumEW+sumZ)/ncomp;

                 disp(['Mean SNR over all stations ' num2str(snrvalue)])
                  set(handles.snrvalue,'String',num2str(fix(snrvalue)))
%                  
% snrNS
% snrEW
% snrZ
% whos

        fid = fopen('snr.isl','w');
         fprintf(fid,'%f  ',snrvalue);
        fclose(fid)
         
         
         
             % forma a SNR matrix
             snrall=[snrNS' snrEW' snrZ']
          

            case 6
                 disp('Found version of allstat without frequencies e.g. 001 1 1 1 1 STA. SNR will not be calculated.')
%                  [~,d1,~,~,~,NS] = textread('.\invert\allstat.dat','%s %f %f %f %f %s',-1);
%                       nostations = length(NS);
%                      for i=1:nostations
%                       realdatafilename{i}=[char(NS(i)) 'snr.dat'];
%                      end
            case 5
                 disp('Found old version of allstat without frequencies and without station masking e.g. STA 1 1 1 1. SNR will not be calculated.')
%                  [NS,d1,~,~,~] = textread('.\invert\allstat.dat','%s %f %f %f %f',-1);
%                       nostations = length(NS);
%                      for i=1:nostations
%                       realdatafilename{i}=[char(NS(i)) 'snr.dat'];
%                      end
       end
            
end
 
  
%%

%%%% updata handles.....
set(handles.scalex,'String',num2str(scalex));        
set(handles.scaley,'String',num2str(scaley));         
set(handles.fscale,'String',num2str(fscale));    
set(handles.fsize, 'String',num2str(fontsize));    
%set(handles.gmtpal,'String',gmtpal);     

set(handles.tltext,'String',num2str(tl))        
set(handles.nsourcestext,'String',num2str(nsources))  
set(handles.fsrc,'String','1')         
set(handles.lsrc,'String',num2str(nsources))         
set(handles.nstationstext,'String',num2str(nstations))   

%%%write to handles
handles.eventid=eventid;
handles.dtres=dtres;
handles.nsourcestext=nsources;
handles.distep=distep;
handles.sdepth=sdepth;
handles.conplane=conplane;
handles.stypeorig=stypeorig;
handles.stdurorig=stfdur;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes invert wait for user response (see UIRESUME)
% uiwait(handles.invert);


% --- Outputs from this function are returned to the command line.
function varargout = invert_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%

% --- Executes on button press in runinv.
function runinv_Callback(hObject, eventdata, handles)
% hObject    handle to runinv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dtres=handles.dtres;
nsources=handles.nsourcestext;

%%%read values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stime = str2double(get(handles.starttime,'String'))
% tstep = str2double(get(handles.timestep,'String'))     
% etime = str2double(get(handles.endtime,'String'))

%%%%%%%%%%%%%%%%%%%%%%%%
stime = str2double(get(handles.stdt,'String'));
tstep = str2double(get(handles.tsdt,'String'));  
etime = str2double(get(handles.etdt,'String'));
%%%%%%%%%%%%%%%%%%%%
freqch=get(handles.freqcheck,'Value');
%%%check if it exceeds maximum..!!!!
%%%%convert time step in seconds to time step in samples...
% ifirst=round(stime/dtres)
% istep=round(tstep/dtres)
% ilast=round(etime/dtres)
% minimumd = num2str(-1250*dtres,'%5.2g');
% maximumd = num2str(1250*dtres,'%5.2g');

ifirst=stime;
istep=tstep;
ilast=etime;

errorstring= ['Trial time shifts should be between ' num2str(-2500) ' and ' num2str(2500) ' sec'];

if ifirst < -2500 || ilast > 2500
        errordlg(errorstring,'Error');
        return
else
end

% %%%%check how many steps...
% if (ifirst >= 0 && ilast > 0 )
%   iseqm=(ilast-ifirst)/istep;
% elseif  (ifirst < 0 && ilast <= 0 )
%   iseqm=(abs(ifirst)-abs(ilast))/istep;
% elseif (ifirst < 0 && ilast >= 0 )
%   iseqm=(ilast+abs(ifirst))/istep;
% else
%     disp('check your time search inputs')
% end
% 

disp('No of Time steps')

iseqm=round((ilast-ifirst)/istep)

%%%%%%%%%%%%%%%%%%%%%%%%%%%

if iseqm  > 100
        errordlg('Too many shifts requested; check Start,Time step,End','Error');
        return
else
end

%%%%check if tstep is too small....
   if tstep < dtres
    errorstring= ['Your time step is too small  ' num2str(tstep,'%5.2g') '  it should be at least  '  num2str(dtres,'%5.2g') ' sec '];
    errordlg(errorstring,'Error');
      return
  else
  end

  
  ifirst*dtres
  ilast*dtres
  istep*dtres
  
  
%   infostr= ['Your time search values after rounding are: Start ' num2str(ifirst*dtres,'%5.2g') ' Time step '  num2str( istep*dtres,'%5.2g') ' End '  num2str(ilast*dtres,'%5.2g')];
% % warndlg(infostr,'!! Warning !!');
% %   
% 
% disp(infostr)

set(handles.starttime,'String',num2str(ifirst*dtres,'%5.2g'))
set(handles.timestep,'String', num2str(istep*dtres,'%5.2g')) 
set(handles.endtime,'String',  num2str(ilast*dtres,'%5.2g'))
  

%%%%%%%%%%%Update handles for time limits correlation plot...

set(handles.negtime,'String',num2str(ifirst*dtres,'%5.2g'))
set(handles.postime,'String',num2str(ilast*dtres,'%5.2g'))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f1 = str2double(get(handles.f1,'String'))
f2 = str2double(get(handles.f2,'String'))
f3 = str2double(get(handles.f3,'String'))
f4 = str2double(get(handles.f4,'String'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check if inversion band is lower than mac freq of green

if ispc
  [~,nfreq,tl,~,~,~,~,~,~,~]=readgrdathed('.\green\grdat.hed')
else
  [~,nfreq,tl,~,~,~,~,~,~,~]=readgrdathed('./green/grdat.hed')
end

fmax=nfreq/tl;

if f4>fmax
      % 
    choice = questdlg(['Your f4 frequency is larger than maximum frequency (' num2str(fmax) ') of green functions'], 'Warning', 'Abort','Continue i know what i am doing','Abort');
% Handle response
    switch choice
      case 'Abort'
         return
      case 'Continue i know what i am doing'
         disp('Be careful..!!') 
    end
%   errordlg(['Your f4 frequency is larger than maximum frequency (' num2str(fmax) ') of green functions. Change f4 to continue.'],'Error')
%   return

else
    
end
%%
nsubevents= str2double(get(handles.nsubevents,'String'))

if nsubevents > 20
        errordlg('Number of subevents should be < 20','Error');
        return
else
end

 
%%%type of inversion
if get(handles.fullmt,'Value') == get(handles.fullmt,'Max')
    disp('Full MT inversion selected')
    inv=1;
elseif get(handles.free,'Value') == get(handles.free,'Max')
    disp('Deviatoric MT inversion selected')
    inv=2;
elseif get(handles.dc,'Value') == get(handles.dc,'Max')
    disp('DC MT inversion selected')
    inv=3;
elseif get(handles.fixed,'Value') == get(handles.fixed,'Max')
    disp('Fixed DC mechanism inversion')
    inv=4;
    strike = str2double(get(handles.strike,'String'))
    dip = str2double(get(handles.dip,'String'))
    rake = str2double(get(handles.rake,'String'))
%     moment = str2double(get(handles.moment,'String'))
%     delay = str2double(get(handles.delay,'String'))
 moment = 1.0e+30;
 delay  = 1.0e+30;
 %
else
    %%% case nothing is selected....!!
    errordlg('Please select type of inversion','!! Error !!')
    return
end

%%   check the selected type of Time Function

if get(handles.delta,'Value') == get(handles.delta,'Max')
    disp('Delta Time function selected')
    istype=1;  % no need for new elementary seismograms
elseif get(handles.triangle,'Value') == get(handles.triangle,'Max')
    disp('Triangle Time function selected')
    istype=2;
    t0 = str2double(get(handles.sdur,'String'));
else
    %%% case nothing is selected....!!
    errordlg('Please select type of time function','!! Error !!')
    return
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% OLD code
% h=dir('station_index.isl');
% 
% if length(h) ~= 0;
%     disp('Using station name masking...!')
%     disp('   ')
%  
%     fid = fopen('station_index.isl','r');
%       C = textscan(fid,'%s %s');
%     fclose(fid);
% 
%     nostations = length(C{1});
%     
%    for i=1:nostations
%     realdatafilename{i}=[char(C{1,2}(i,1)) 'raw.dat'];
%     maskdatafilename{i}=[char(C{1,1}(i,1)) 'raw.dat'];
%    end
%% NEW code for new allstat.dat format
if ispc
 h=dir('.\invert\allstat.dat');
else
 h=dir('./invert/allstat.dat');
end
  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
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
                if ispc   
                   [NS,us1,us2,us3,us4,f11,f12,f13,f14] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 
                else
                   [NS,us1,us2,us3,us4,f11,f12,f13,f14] = textread('./invert/allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 
                end
                     nostations = length(NS);
                      for i=1:nostations
                         realdatafilename{i}=[char(NS(i)) 'raw.dat'];
                      end
                      % now check if all RAW files are present
                   cd invert
                      %
                      for i=1:nostations
                       if exist(realdatafilename{i},'file')
                        disp(['Found ' realdatafilename{i} ])            %' will be masked as ' maskdatafilename{i}])
                      % copyfile(char(realdatafilename{i}),char(maskdatafilename{i}))
                       else
                       disp(['File ' realdatafilename{i} ' is missing'])
                       errordlg(['File ' realdatafilename{i} '  not found in invert folder. Run Data Preparation for this station' ] ,'File Error');    
                       end
                      end
                    % back one folder
                    disp('   ')
                   cd ..
          case 6
                 disp('Found version of allstat without frequencies e.g. 001 1 1 1 1 STA. SNR will not be calculated.')
                 warndlg('Your allstat.dat file is old. Press Select Stations/Freq band to update.','!! Warning !!')
                if ispc
                 [~,us1,us2,us3,us4,NS] = textread('.\invert\allstat.dat','%s %f %f %f %f %s',-1);
                else
                 [~,us1,us2,us3,us4,NS] = textread('./invert/allstat.dat','%s %f %f %f %f %s',-1);
                end
                     nostations = length(NS);
                      for i=1:nostations
                         realdatafilename{i}=[char(NS(i)) 'raw.dat'];
                      end
                      % now check if all RAW files are present
                   cd invert
                      %
                      for i=1:nostations
                       if exist(realdatafilename{i},'file')
                        disp(['Found ' realdatafilename{i} ])            %' will be masked as ' maskdatafilename{i}])
                      % copyfile(char(realdatafilename{i}),char(maskdatafilename{i}))
                       else
                       disp(['File ' realdatafilename{i} ' is missing'])
                       errordlg(['File ' realdatafilename{i} '  not found in invert folder. Run Data Preparation for this station' ] ,'File Error');    
                       end
                      end
                    % back one folder
                    disp('   ')
                   cd ..
          case 5
                 disp('Found old version of allstat without frequencies and without station masking e.g. STA 1 1 1 1. SNR will not be calculated.')
                 warndlg('Your allstat.dat file is old. Press Select Stations/Freq band to update.','!! Warning !!')
               if ispc  
                 [NS,us1,us2,us3,us4] = textread('.\invert\allstat.dat','%s %f %f %f %f',-1);
               else
                 [NS,us1,us2,us3,us4] = textread('./invert/allstat.dat','%s %f %f %f %f',-1);
               end
                     nostations = length(NS);
                      for i=1:nostations
                         realdatafilename{i}=[char(NS(i)) 'raw.dat'];
                      end
                      % now check if all RAW files are present
                   cd invert
                      %
                      for i=1:nostations
                       if exist(realdatafilename{i},'file')
                        disp(['Found ' realdatafilename{i} ])            %' will be masked as ' maskdatafilename{i}])
                      % copyfile(char(realdatafilename{i}),char(maskdatafilename{i}))
                       else
                       disp(['File ' realdatafilename{i} ' is missing'])
                       errordlg(['File ' realdatafilename{i} '  not found in invert folder. Run Data Preparation for this station' ] ,'File Error');    
                       end
                      end
                    % back one folder
                    disp('   ')
                   cd ..
          end
       
  end % if for allstat existance
  
%%
cd invert

% %%% read allstat        OLD CODE
% stationfile='allstat.dat';
% %read data in 6 arrays
% fid  = fopen(stationfile,'r');
% [staname,d1,d2,d3,d4] = textread(stationfile,'%s %f %f %f %f',-1);
% fclose(fid);
% nostations = length(staname);
% for i=1:nostations
%     realdatafilename{i}=[staname{i} 'raw.dat'];
%      if exist(realdatafilename{i},'file')
%          disp(['Found ' realdatafilename{i}])
%      else
%          disp(['File ' realdatafilename{i} ' is missing'])
%          errordlg(['File ' realdatafilename{i} '  not found in invert folder. Run Data Preparation for this station' ] ,'File Error');    
%      end
% end         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ispc
  fid = fopen('inpinv.dat','w');
    fprintf(fid,'%s\r\n','    mode of inversion: 1=full MT, 2=deviatoric MT (recommended), 3= DC MT, 4=known fixed DC MT');
    fprintf(fid,'%i\r\n',inv);
    fprintf(fid,'%s\r\n','    time step of XXXRAW.DAT files (in sec)');
    fprintf(fid,'%g\r\n',dtres);
    fprintf(fid,'%s\r\n','    number of trial source positions (isourmax), max. 51');
    fprintf(fid,'%i\r\n',nsources);
    fprintf(fid,'%s\r\n','    trial time shifts (max. 100 shifts): from (>-2500), step, to (<2500)');
    fprintf(fid,'%s\r\n','    example: -10,5,50 means -10dt to 50dt, step = 5dt, i.e. 12 shifts');
    fprintf(fid,'%i %i %i\r\n',ifirst, istep, ilast);
    fprintf(fid,'%s\r\n','    number of subevents to be searched (isubmax), max. 20');
    fprintf(fid,'%i\r\n',nsubevents);
    fprintf(fid,'%s\r\n','    filter (f1,f2,f3,f4); flat band-pass between f2, f3');
    fprintf(fid,'%s\r\n','    cosine tapered between f1, f2 and between f3, f4');
    fprintf(fid,'%g %g %g %g\r\n',f1,f2,f3,f4);
    fprintf(fid,'%s\r\n','    guess of data variance (important only for absolute value of the parameter variance)');
    fprintf(fid,'%s\r\n','2.0e-12');
  fclose(fid);
  
  % do we need to change allstat ..??? depends on freqcheck
     if freqch ==1 % allstat should have the f1 f2 f3 f4 band..
         disp('Common Fequency options was selected')
         % update allstat
           fid = fopen('allstat.dat','w');

            for p=1:nostations
              fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\r\n',char(NS(p)),us1(p),us2(p),us3(p),us4(p),f1,f2,f3,f4);
            end
           fclose(fid);

     else  %% allstat is updated through the Select Stations /Freq band button
         disp('Common Fequency options wasn''t selected')
     end
         
  
else
  fid = fopen('inpinv.dat','w');
    fprintf(fid,'%s\n','    mode of inversion: 1=full MT, 2=deviatoric MT (recommended), 3= DC MT, 4=known fixed DC MT');
    fprintf(fid,'%i\n',inv);
    fprintf(fid,'%s\n','    time step of XXXRAW.DAT files (in sec)');
    fprintf(fid,'%g\n',dtres);
    fprintf(fid,'%s\n','    number of trial source positions (isourmax), max. 51');
    fprintf(fid,'%i\n',nsources);
    fprintf(fid,'%s\n','    trial time shifts (max. 100 shifts): from (>-2500), step, to (<2500)');
    fprintf(fid,'%s\n','    example: -10,5,50 means -10dt to 50dt, step = 5dt, i.e. 12 shifts');
    fprintf(fid,'%i %i %i\n',ifirst, istep, ilast);
    fprintf(fid,'%s\n','    number of subevents to be searched (isubmax), max. 20');
    fprintf(fid,'%i\n',nsubevents);
    fprintf(fid,'%s\n','    filter (f1,f2,f3,f4); flat band-pass between f2, f3');
    fprintf(fid,'%s\n','    cosine tapered between f1, f2 and between f3, f4');
    fprintf(fid,'%g %g %g %g\n',f1,f2,f3,f4);
    fprintf(fid,'%s\n','    guess of data variance (important only for absolute value of the parameter variance)');
    fprintf(fid,'%s\n','2.0e-12');
  fclose(fid);
  
    % do we need to change allstat ..??? depends on freqcheck
     if freqch ==1 % allstat should have the f1 f2 f3 f4 band..
         disp('Common Fequency options was selected')
         % update allstat
           fid = fopen('allstat.dat','w');

            for p=1:nostations
              fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\n',char(NS(p)),us1(p),us2(p),us3(p),us4(p),f1,f2,f3,f4);
            end
           fclose(fid);

     else  %% allstat is updated through the Select Stations /Freq band button
         disp('Common Fequency options wasn''t selected')
     end
  
  
end
  
  
if inv == 4
    
fid = fopen('mechan.dat','w');

  if ispc
    fprintf(fid,'%s\r\n','Source size and mechanism (in free format)');
    fprintf(fid,'%s\r\n','   scalar moment (in Nm):');
    fprintf(fid,'%e\r\n',moment);
    fprintf(fid,'%s\r\n',' strike (in degrees)  dip (in degrees)  rake (in degrees); see Aki & Richards');
    fprintf(fid,'%i %i %i\r\n',strike, dip, rake);
    fprintf(fid,'%s\r\n','  delay (in seconds); >0 is to the right');
    fprintf(fid,'%i\r\n',delay);
  else
    fprintf(fid,'%s\n','Source size and mechanism (in free format)');
    fprintf(fid,'%s\n','   scalar moment (in Nm):');
    fprintf(fid,'%e\n',moment);
    fprintf(fid,'%s\n',' strike (in degrees)  dip (in degrees)  rake (in degrees); see Aki & Richards');
    fprintf(fid,'%i %i %i\n',strike, dip, rake);
    fprintf(fid,'%s\n','  delay (in seconds); >0 is to the right');
    fprintf(fid,'%i\n',delay);
  end
    
fclose(fid);

else
end

cd ..   %% back to main

%pwd
%%
% check if we need new elementary seismograms
% read what was used in green
% 
   stypeorig=handles.stypeorig;
   stfdurorig=handles.stdurorig;
   istype;
   
   if stypeorig == 1 
       origstf='delta';
   elseif stypeorig == 2
       origstf='triangle';
   end
   
   if istype == 1 
       reqstf='delta';
   elseif istype == 2
       reqstf='triangle';
   end

disp(['Elementary seismograms were calculated using '  origstf ' source time function'])
disp(['Requested source time function is ' reqstf ])

   
%% 
if stypeorig~=istype  
% we must prepare new elementary seismograms
% we need new elementary seismograms 
     disp('Start creating new elementary seismograms.')

          % decide if we need delta or triangle
           switch istype
               
               case 1 % delta
                   % go in green
                 try
                       
                     cd green
                     
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

                     % prepare a new batch file    
                     fid = fopen('gre_ele.bat','w');
                   
                     for i=1:nsources ;
                       if ispc  
                              fprintf(fid,'%s\r\n',['copy gr' num2str(i,'%02d') '.hes gr.hes']);
                              fprintf(fid,'%s\r\n',['copy gr' num2str(i,'%02d') '.hea gr.hea']);
                              fprintf(fid,'%s\r\n','elemse.exe');
                              fprintf(fid,'%s\r\n',['copy elemse.dat elemse' num2str(i,'%02d') '.dat']);
                              fprintf(fid,'%s\r\n','    ');
                       else
                              fprintf(fid,'%s\n',['cp gr' num2str(i,'%02d') '.hes gr.hes']);
                              fprintf(fid,'%s\n',['cp gr' num2str(i,'%02d') '.hea gr.hea']);
                              fprintf(fid,'%s\n','elemse.exe');
                              fprintf(fid,'%s\n',['cp elemse.dat elemse' num2str(i,'%02d') '.dat']);
                              fprintf(fid,'%s\n','    ');
                       end
                     end
                      if ispc
                        fprintf(fid,'%s\r\n','del gr.hea');
                        fprintf(fid,'%s\r\n','del gr.hes');
                        fprintf(fid,'%s\r\n','del elemse.dat');
                        fprintf(fid,'%s\r\n','rem ******************************** ');
                        fprintf(fid,'%s\r\n','rem ******************************** ');
                        fprintf(fid,'%s\r\n','rem Finished with Green function calculation ');
                        fprintf(fid,'%s\r\n','rem you can go on with file copy.... ');
                      else
                        fprintf(fid,'%s\n','rm gr.hea');
                        fprintf(fid,'%s\n','rm gr.hes');
                        fprintf(fid,'%s\n','rm elemse.dat');
                        fprintf(fid,'%s\n','rem ******************************** ');
                        fprintf(fid,'%s\n','rem ******************************** ');
                        fprintf(fid,'%s\n','rem Finished with Green function calculation ');
                        fprintf(fid,'%s\n','rem you can go on with file copy.... ');
                      end
                      
                      fclose(fid);
                        
         %% Run the batch files
                        try
                          button = questdlg('Convolve with new Time Function?','Continue Operation','Yes','No','Yes');
                          if strcmp(button,'Yes')
                              if ispc
                                     [status,message] = system('del elemse*.dat');  % clear all files....
                              else
                                     [status,message] = system('rm elemse*.dat');  % clear all files....
                              end
                              
                           disp('Running gr_xyz')

                           if ispc
                              system('gre_ele.bat  &')
                           else
                               disp('Linux version')
                              system('gre_ele.bat  &')
                           end
                           button = questdlg('Copy files in invert folder (BE VERY CAREFUL ..!! Green calculations should have finished. Check the command window and WAIT for the Finished with Green function calculation message to appear BEFORE pressing Yes','Continue Operation','Yes','No','Yes');
                             if strcmp(button,'Yes')
                              % copy files elem* to invert
                              disp('Removing elemse*.dat files from invert folder')
                              % return to ISOLA folder  
                             if ispc 
                              [status,message] = system('del ..\invert\elemse*.dat');
                             else
                              [status,message] = system('rm ../invert/elemse*.dat');
                             end
                              disp('Copying files')
                             if ispc 
                              [s,mess,messid]=copyfile('elemse*.dat','..\invert')
                             else
                              [s,mess,messid]=copyfile('elemse*.dat','../invert')
                             end
                                if s==1 
                                  h=msgbox('Copied files in invert directory','Copy files');
                                     if ispc
                                         [status,message] = system('del elemse*.dat');  % remove from green
                                     else
                                         [status,message] = system('rm elemse*.dat');  % remove from green
                                     end
                                else
                                  h=msgbox('Failed to copy files in invert directory','Copy files');
                                end
                             else
                               disp('Abort Copy files')
                             end

                          elseif strcmp(button,'No')
                            disp('Green function generation canceled')
                          end
                        catch
                           cd ..
                        end
                         
                        cd ..  % finished in green
                   catch   % first try
                      cd ..
                   end     % first try
%%                   
                   pwd       
         % update the stype.isl
                  fid = fopen('stype.isl','w');
                    if ispc
                       fprintf(fid,'%s\r\n','delta');
                    else
                       fprintf(fid,'%s\n','delta');
                    end
                  fclose(fid);
%%                   
               case 2 % triangle
                      % go in green
                   try
                       
                     cd green
                     
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
                     % prepare a new batch file    
                     fid = fopen('gre_ele.bat','w');
                     for i=1:nsources ;
                         if ispc 
                               fprintf(fid,'%s\r\n',['copy gr' num2str(i,'%02d') '.hes gr.hes']);
                               fprintf(fid,'%s\r\n',['copy gr' num2str(i,'%02d') '.hea gr.hea']);
                               fprintf(fid,'%s\r\n','elemse.exe');
                               fprintf(fid,'%s\r\n',['copy elemse.dat elemse' num2str(i,'%02d') '.dat']);
                               fprintf(fid,'%s\r\n','    ');
                         else
                               fprintf(fid,'%s\n',['cp gr' num2str(i,'%02d') '.hes gr.hes']);
                               fprintf(fid,'%s\n',['cp gr' num2str(i,'%02d') '.hea gr.hea']);
                               fprintf(fid,'%s\n','elemse.exe');
                               fprintf(fid,'%s\n',['cp elemse.dat elemse' num2str(i,'%02d') '.dat']);
                               fprintf(fid,'%s\n','    ');
                         end
                     end
                       if ispc
                           fprintf(fid,'%s\r\n','del gr.hea');
                           fprintf(fid,'%s\r\n','del gr.hes');
                           fprintf(fid,'%s\r\n','del elemse.dat');
                           fprintf(fid,'%s\r\n','rem ******************************** ');
                           fprintf(fid,'%s\r\n','rem ******************************** ');
                           fprintf(fid,'%s\r\n','rem Finished with Green function calculation ');
                           fprintf(fid,'%s\r\n','rem you can go on with file copy.... ');
                       else
                           fprintf(fid,'%s\n','rm gr.hea');
                           fprintf(fid,'%s\n','rm gr.hes');
                           fprintf(fid,'%s\n','rm elemse.dat');
                           fprintf(fid,'%s\n','rem ******************************** ');
                           fprintf(fid,'%s\n','rem ******************************** ');
                           fprintf(fid,'%s\n','rem Finished with Green function calculation ');
                           fprintf(fid,'%s\n','rem you can go on with file copy.... ');
                       end
                     fclose(fid);
                      % Run the batch files
                        try
                          button = questdlg('Convolve with new Time Function?','Continue Operation','Yes','No','Yes');
                          if strcmp(button,'Yes')
                              if ispc 
                                  [status,message] = system('del elemse*.dat')  %%%%% clear all files....
                              else
                                  [status,message] = system('rm elemse*.dat')  %%%%% clear all files....
                              end
                           disp('Running gr_xyz')

                           if ispc
                              system('gre_ele.bat  &')
                           else
                               disp('Linux version')
                              system('gre_ele.bat  &')
                           end                           
                           
                           button = questdlg('Copy files in invert folder (BE VERY CAREFUL ..!! Green calculations should have finished. Check the command window and WAIT for the Finished with Green function calculation message to appear BEFORE pressing Yes','Continue Operation','Yes','No','Yes');
                             if strcmp(button,'Yes')
                              % copy files elem* to invert
                              disp('Removing elemse*.dat files from invert folder')
                              % return to ISOLA folder  
                               if ispc 
                                  [status,message] = system('del ..\invert\elemse*.dat');
                               else
                                  [status,message] = system('rm ../invert/elemse*.dat');
                               end
                              disp('Copying files')
                               if ispc
                                  [s,mess,messid]=copyfile('elemse*.dat','..\invert')
                               else
                                  [s,mess,messid]=copyfile('elemse*.dat','../invert')
                               end
                                if s==1 
                                  h=msgbox('Copied files in invert directory','Copy files');
                                    if ispc
                                       [status,message] = system('del elemse*.dat');  %%% remove from green
                                    else
                                       [status,message] = system('rm elemse*.dat');  %%% remove from green
                                    end
                                else
                                  h=msgbox('Failed to copy files in invert directory','Copy files');
                                end
                             else
                               disp('Abort Copy files')
                             end

                          elseif strcmp(button,'No')
                            disp('Green function generation canceled')
                          end
                        catch
                           cd ..
                        end
                         
                        cd ..  %% finished in green
                   catch   % first try
                      cd ..
                   end     % first try
                   
                   pwd
                   
%% 
%          update the stype.isl
           fid = fopen('stype.isl','w');
              if ispc
                   fprintf(fid,'%s\r\n','triangle');
                   fprintf(fid,'%4.1f\r\n',t0);
              else
                   fprintf(fid,'%s\n','triangle');
                   fprintf(fid,'%4.1f\n',t0);
              end
           fclose(fid);
                   
           end   % end of switch

        %%  now run inversion 
        %  RUN the batch files
        button = questdlg('Run Inversion ?','Inversion ','Yes','No','Yes');
        if strcmp(button,'Yes')
           disp('Running inversion')
            cd invert
              if ispc 
                  system('runisola.bat &') % return to ISOLA folder    
              else
                 disp('Linux ')
                   system('gnome-terminal -e "bash -c runisola.sh;bash"')            % return to ISOLA folder    
              end
            cd ..
            pwd
       elseif strcmp(button,'No')
          disp('Canceled ')
       end

%% same time function but duration could be different..!!
            
else   % if source time function IS NOT different
    if istype == 1  % delta
     % we can run inversion user doesn't want to change time function
        disp('Elementary seismograms were created for selected time function. Continue with inversion')
        % RUN the batch files
        button = questdlg('Run Inversion ?','Inversion ','Yes','No','Yes');
        if strcmp(button,'Yes')
           disp('Running inversion')
            cd invert
               if ispc 
                   system('runisola.bat &')            % return to ISOLA folder    
               else
                   disp('Linux ')
                   system('gnome-terminal -e "bash -c runisola.sh;bash"')            % return to ISOLA folder    
               end
            cd ..
           pwd
        elseif strcmp(button,'No')
          disp('Canceled ')
        end
    elseif istype ==2 % triangle
        if str2double(stfdurorig) ~= t0  % triangle   OF DIFFERENT DURATION
            disp('Same Source time function BUT with different duration.Create new elementary seismograms')
          % new elementary seismograms..!!
          % go in green
                   try
                       
                     cd green
                     
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
                     % prepare a new batch file    
                     fid = fopen('gre_ele.bat','w');
                     for i=1:nsources ;
                       if ispc  
                           fprintf(fid,'%s\r\n',['copy gr' num2str(i,'%02d') '.hes gr.hes']);
                           fprintf(fid,'%s\r\n',['copy gr' num2str(i,'%02d') '.hea gr.hea']);
                           fprintf(fid,'%s\r\n','elemse.exe');
                           fprintf(fid,'%s\r\n',['copy elemse.dat elemse' num2str(i,'%02d') '.dat']);
                           fprintf(fid,'%s\r\n','    ');
                       else
                           fprintf(fid,'%s\n',['copy gr' num2str(i,'%02d') '.hes gr.hes']);
                           fprintf(fid,'%s\n',['copy gr' num2str(i,'%02d') '.hea gr.hea']);
                           fprintf(fid,'%s\n','elemse.exe');
                           fprintf(fid,'%s\n',['copy elemse.dat elemse' num2str(i,'%02d') '.dat']);
                           fprintf(fid,'%s\n','    ');
                       end
                     end
                       if ispc
                           fprintf(fid,'%s\r\n','del gr.hea');
                           fprintf(fid,'%s\r\n','del gr.hes');
                           fprintf(fid,'%s\r\n','del elemse.dat');
                           fprintf(fid,'%s\r\n','rem ******************************** ');
                           fprintf(fid,'%s\r\n','rem ******************************** ');
                           fprintf(fid,'%s\r\n','rem Finished with Green function calculation ');
                           fprintf(fid,'%s\r\n','rem you can go on with file copy.... ');
                       else
                           fprintf(fid,'%s\n','del gr.hea');
                           fprintf(fid,'%s\n','del gr.hes');
                           fprintf(fid,'%s\n','del elemse.dat');
                           fprintf(fid,'%s\n','rem ******************************** ');
                           fprintf(fid,'%s\n','rem ******************************** ');
                           fprintf(fid,'%s\n','rem Finished with Green function calculation ');
                           fprintf(fid,'%s\n','rem you can go on with file copy.... ');
                       end
                      fclose(fid);
                      % Run the batch files
                        try
                          button = questdlg('Convolve with new Time Function?','Continue Operation','Yes','No','Yes');
                          if strcmp(button,'Yes')
                              if ispc
                                   [status,message] = system('del elemse*.dat')  %%%%% clear all files....
                              else
                                   [status,message] = system('rm elemse*.dat')  %%%%% clear all files....
                              end
                           disp('Running gr_xyz')
                             if ispc
                                 system('gre_ele.bat  &')
                             else
                                 system('gre_ele.sh  &')
                             end
                           
                           button = questdlg('Copy files in invert folder (BE VERY CAREFUL ..!! Green calculations should have finished. Check the command window and WAIT for the Finished with Green function calculation message to appear BEFORE pressing Yes','Continue Operation','Yes','No','Yes');
                             if strcmp(button,'Yes')
                              % copy files elem* to invert
                              disp('Removing elemse*.dat files from invert folder')
                              % return to ISOLA folder
                               if ispc 
                                  [status,message] = system('del ..\invert\elemse*.dat');
                               else
                                  [status,message] = system('rm ../invert/elemse*.dat');
                               end
                              disp('Copying files')
                               if ispc
                                   [s,mess,messid]=copyfile('elemse*.dat','..\invert')
                               else
                                   [s,mess,messid]=copyfile('elemse*.dat','../invert')
                               end
                                if s==1 
                                  h=msgbox('Copied files in invert directory','Copy files');
                                    if ispc 
                                          [status,message] = system('del elemse*.dat');  %%% remove from green
                                    else
                                          [status,message] = system('rm elemse*.dat');  %%% remove from green
                                    end
                                else
                                  h=msgbox('Failed to copy files in invert directory','Copy files');
                                end
                             else
                               disp('Abort Copy files')
                             end

                          elseif strcmp(button,'No')
                            disp('Green function generation canceled')
                          end
                        catch
                           cd ..
                        end
                         
                        cd ..  %% finished in green
                   catch   % first try
                      cd ..
                   end     % first try
                   
                   pwd
                   
%%          update the stype.isl
           fid = fopen('stype.isl','w');
              if ispc
                   fprintf(fid,'%s\r\n','triangle');
                   fprintf(fid,'%4.1f\r\n',t0);
              else
                   fprintf(fid,'%s\n','triangle');
                   fprintf(fid,'%4.1f\n',t0);
              end
           fclose(fid);       
%%
                   % run inv it is triangle with same duration
                   % RUN the batch files
                   button = questdlg('Run Inversion ?','Inversion ','Yes','No','Yes');
                    if strcmp(button,'Yes')
                       disp('Running inversion')
                          cd invert
                             if ispc 
                                 system('runisola.bat &')            % return to ISOLA folder    
                             else
                                 disp('Linux ')
                                 system('gnome-terminal -e "bash -c runisola.sh;bash"')            % return to ISOLA folder    
                             end
                          cd ..
                       pwd
                    elseif strcmp(button,'No')
                       disp('Canceled ')
                    end
%%          
       else
             disp('Same STF triangle same duration no need to create new elementary seismograms')
        % run inv it is triangle with same duration
        % RUN the batch files
            button = questdlg('Run Inversion ?','Inversion ','Yes','No','Yes');
             if strcmp(button,'Yes')
               disp('Running inversion')
                cd invert
                   if ispc 
                        system('runisola.bat &')            % return to ISOLA folder    
                   else
                        disp('Linux ')
                        system('gnome-terminal -e "bash -c runisola.sh;bash"')            % return to ISOLA folder    
                   end
                cd ..
               pwd
             elseif strcmp(button,'No')
               disp('Canceled ')
             end
        end  % end of triangle IF
    
    end  % end of istype IF
  
end  
%

handles.nooftimesteps=iseqm;
% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.invert)

% --- Executes during object creation, after setting all properties.
function start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start as text
%        str2double(get(hObject,'String')) returns contents of start as a double


% --- Executes during object creation, after setting all properties.
function timestep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function timestep_Callback(hObject, eventdata, handles)
% hObject    handle to timestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timestep as text
%        str2double(get(hObject,'String')) returns contents of timestep as a double

dtres=handles.dtres;
nsources=handles.nsourcestext;
%%%read values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stime = str2double(get(handles.starttime,'String'))
tstep = str2double(get(handles.timestep,'String'))     
etime = str2double(get(handles.endtime,'String'))
%%%check if it exceeds maximum..!!!!
%%%%convert time step in seconds to time step in samples...
ifirst=round(stime/dtres);
istep=round(tstep/dtres);
ilast=round(etime/dtres);

minimumd = -2500*dtres;
maximumd = 2500*dtres;

%%%%check how many steps...
if (ifirst >= 0 && ilast > 0 )
  iseqm=(ilast-ifirst)/istep;
elseif  (ifirst < 0 && ilast <= 0 )
  iseqm=(abs(ifirst)-abs(ilast))/istep;
elseif (ifirst < 0 && ilast >= 0 )
  iseqm=(ilast+abs(ifirst))/istep;
else
    disp('check your time search inputs')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if iseqm > minimumd && iseqm < maximumd

    set(handles.trialts,'String',num2str(iseqm,'%5.2g'),...)
                        'ForegroundColor','black')        
                    
else iseqm < minimumd || iseqm > maximumd
    
    set(handles.trialts,'String',num2str(iseqm,'%5.2g'),...
                        'ForegroundColor','red')        
end


% --- Executes during object creation, after setting all properties.
function endtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function endtime_Callback(hObject, eventdata, handles)
% hObject    handle to endtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endtime as text
%        str2double(get(hObject,'String')) returns contents of endtime as a double

dtres=handles.dtres;
nsources=handles.nsourcestext;
%%%read values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stime = str2double(get(handles.starttime,'String'))
tstep = str2double(get(handles.timestep,'String'))     
etime = str2double(get(handles.endtime,'String'))
%%%check if it exceeds maximum..!!!!
%%%%convert time step in seconds to time step in samples...
ifirst=round(stime/dtres);
istep=round(tstep/dtres);
ilast=round(etime/dtres);

minimumd = -2500*dtres;
maximumd = 2500*dtres;

%%%%check how many steps...
if (ifirst >= 0 && ilast > 0 )
  iseqm=(ilast-ifirst)/istep;
elseif  (ifirst < 0 && ilast <= 0 )
  iseqm=(abs(ifirst)-abs(ilast))/istep;
elseif (ifirst < 0 && ilast >= 0 )
  iseqm=(ilast+abs(ifirst))/istep;
else
    disp('check your time search inputs')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if iseqm > minimumd && iseqm < maximumd

    set(handles.trialts,'String',num2str(iseqm,'%5.2g'),...)
                        'ForegroundColor','black')        
                    
else iseqm < minimumd || iseqm > maximumd
    
    set(handles.trialts,'String',num2str(iseqm,'%5.2g'),...
                        'ForegroundColor','red')        
end


% --- Executes on button press in free.
function free_Callback(hObject, eventdata, handles)
% hObject    handle to free (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of free
off =[handles.dc,handles.fixed,handles.fullmt];
mutual_exclude(off)

off =[handles.strike,handles.dip,handles.rake,handles.striketext,handles.diptext,handles.raketext];
enableoff(off)

% --- Executes on button press in dc.
function dc_Callback(hObject, eventdata, handles)
% hObject    handle to dc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dc

off =[handles.free,handles.fixed,handles.fullmt];
mutual_exclude(off)

off =[handles.strike,handles.dip,handles.rake,handles.striketext,handles.diptext,handles.raketext];
enableoff(off)

% --- Executes on button press in fixed.
function fixed_Callback(hObject, eventdata, handles)
% hObject    handle to fixed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fixed
off =[handles.free,handles.dc,handles.fullmt];
mutual_exclude(off)

on =[handles.strike,handles.dip,handles.rake,handles.striketext,handles.diptext,handles.raketext];
enableon(on)

%%% search for mechan.dat in invert folder and add the values here
%%%%check if inpinv.dat exists....
if ispc 
   a=exist('.\invert\mechan.dat','file');
else
   a=exist('./invert/mechan.dat','file');
end
  
if a == 2
      try 
          if ispc
              fid = fopen('.\invert\mechan.dat','r');
          else
              fid = fopen('./invert/mechan.dat','r');
          end
            linetmp=fgets(fid);         %01 line
            linetmp=fgets(fid);         %02 line
            linetmp=fgets(fid);         %03 line
            linetmp=fgets(fid);         %04 line
            sdr=fscanf(fid,'%g',3);
          fclose(fid);
         
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       set(handles.strike,'String',num2str(sdr(1,1)));        
       set(handles.dip,'String',num2str(sdr(2,1)));         
       set(handles.rake,'String',num2str(sdr(3,1)));          
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           disp('Found mechan.dat in .\invert folder. Updating ....')  
       catch
%             %%% mechan.dat is not present ...
              disp('Could not read data from mechan.dat in .\invert folder. Check format.')    
        end 
else
%%% mechan.dat is not present ...
disp('Could not find mechan.dat in .\invert folder. Probably this is first run with fixed mechanism.')    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5


% --- Executes during object creation, after setting all properties.
function strike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function strike_Callback(hObject, eventdata, handles)
% hObject    handle to strike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike as text
%        str2double(get(hObject,'String')) returns contents of strike as a double


% --- Executes during object creation, after setting all properties.
function dip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dip_Callback(hObject, eventdata, handles)
% hObject    handle to dip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip as text
%        str2double(get(hObject,'String')) returns contents of dip as a double


% --- Executes during object creation, after setting all properties.
function rake_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rake_Callback(hObject, eventdata, handles)
% hObject    handle to rake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake as text
%        str2double(get(hObject,'String')) returns contents of rake as a double


% --- Executes on button press in cweights.
function cweights_Callback(hObject, eventdata, handles)
% hObject    handle to cweights (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this should read all XXXRAW files that will be used for inversion
% integrate find maximum and update allstat.dat
%%
% read allstat.dat first...
% get in invert and read it .....
% check if INVERT folder exists..

%disp('Weights are sqrt(sum(data^2)))')

h=dir('invert');

if isempty(h);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

nstations=str2double(get(handles.nstationstext,'String')); 

try
    
   cd invert   % change for new allstat.dat..!!
       disp('This code will work with new allstat.dat only')
       
%            [stanamenumber,d1,d2,d3,d4,staname] = textread('allstat.dat','%s %f %f %f %f %s',-1);
%  
%               if isequal(char(stanamenumber(1)),'001') && (length(char(staname(1)))~=0)
%                      disp('Found new allstat.dat format')
%                      nostations = length(stanamenumber);
%                      allstatformat='new';
%               else
%                     [staname,d1,d2,d3,d4] = textread('allstat.dat','%s %f %f %f %f ',-1); 
%                      disp('Found old allstat.dat format')
%                      nostations = length(staname);     
%                      allstatformat='old';
%               end           

     [staname,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
     nostations = length(staname);
     
   cd ..

catch
       h=msgbox('Allstat.dat file problem','Error');
    cd ..
    return
end

    if nostations ~= nstations
        msgbox('Number of stations in allstat.dat is not the same as number of stations indicated by GUI. Check the file.','Error');
        return
    else
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read station.dat 
[C,nostations2]=readstationfile;

if nostations2~=nostations
    errordlg('Number of stations in station.dat is not the same as in allstat.dat. Check files.','File Error');
else
end


%% write new allstat.dat file with epicentral distance as weight
try
   
  cd invert
  % keep backup of allstat
   copyfile('allstat.dat','allstat.bak')
 %  use=1;   %%% use or don't use the station
  
    %%%%open allstat.dat for output !!!!!!!!!!!!!!!!
    fid2 = fopen('allstat.dat','w');
     
      for i=1:nostations
         % check if station name in allstat.dat is the same as in station.dat file  
        
        if strcmp(staname{i}, C{6}(i))
          %output using new allstat.dat format
          
                if ispc
                     if (d2(i)==0) 
                         d2w=0;
                     else
                         d2w=C{5}(i);
                     end
                     
                     if (d3(i)==0) 
                         d3w=0;
                     else
                         d3w=C{5}(i);
                     end
                     
                     if (d4(i)==0) 
                         d4w=0;
                     else
                         d4w=C{5}(i);
                     end
                         
                     fprintf(fid2,'%s  %i %6.2f %6.2f %6.2f %5.2f %5.2f %5.2f %5.2f\r\n',staname{i},d1(i),d2w,d3w,d4w,of1(i),of2(i),of3(i),of4(i));
                   
                else
                     if (d2(i)==0) 
                         d2w=0;
                     else
                         d2w=C{5}(i);
                     end
                     
                     if (d3(i)==0) 
                         d3w=0;
                     else
                         d3w=C{5}(i);
                     end
                     
                     if (d4(i)==0) 
                         d4w=0;
                     else
                         d4w=C{5}(i);
                     end
                   fprintf(fid2,'%s  %i %6.2f %6.2f %6.2f %5.2f %5.2f %5.2f %5.2f\n',staname{i},d1(i),C{5}(i),C{5}(i),C{5}(i),of1(i),of2(i),of3(i),of4(i));
                end
%                whos
%           
%           
%                 if ispc
%                    fprintf(fid2,'%s  %i %f %f %f\r\n',staname{i},use,C{5}(i),C{5}(i),C{5}(i));
%                 else
%                    fprintf(fid2,'%s  %i %f %f %f\n',staname{i},use,C{5}(i),C{5}(i),C{5}(i));
%                 end
%                 
%                 if ispc
%                    fprintf(fid2,'%s  %i %f %f %f %s\r\n',stanamenumber{i},use,C{5}(i),C{5}(i),C{5}(i),staname{i});
%                 else
%                    fprintf(fid2,'%s  %i %f %f %f %s\n',stanamenumber{i},use,C{5}(i),C{5}(i),C{5}(i),staname{i});
%                 end
%                 
        else
          errordlg('Station names in station.dat is not the same as in allstat.dat. Check files.','File Error');
          fclose(fid2);
          copyfile('allstat.bak','allstat.dat')
          
          delete('allstat.bak')
          cd ..
          return
        end
      end
       
    fclose(fid2);
       % go back
       % remove backup
       delete('allstat.bak')
   cd ..
   
   warndlg('Weights according to epicentral distance were computed successfully and allstat.dat was updated','!! Info !!');
   
catch
     % create allstat.dat from backup
     copyfile('allstat.bak','allstat.dat')
     cd ..
end

%% OLD CODE
%%% check if all ISOLA input files exist..
% h=dir('duration.isl');
% 
% if isempty(h); 
%   errordlg('Duration.isl file doesn''t exist. Run Event info. ','File Error');
%   return
% else
%     fid = fopen('duration.isl','r');
%     tl=fscanf(fid,'%g',1);
%     fclose(fid);
% end
% %tltext=8192*dt (resampled dt..!!)
% 
% dtres=tl/8192;
% 
% %%%%% find filter parameters....
% 
% f2 = str2double(get(handles.f2,'String'));
% f3 = str2double(get(handles.f3,'String'));
% 
% data=[];
% 
% %%%% now read, filter and find maximum ....
% try
%    
%     cd invert
% %%%%open allstat.dat for output !!!!!!!!!!!!!!!!
% fid2 = fopen('allstat.dat','w');
% 
% use=1;   %%% use or don't use the station
% 
% disp(['Weights computed according to sqrt(sum(data^2))). Components NS, EW, VER'])
% 
% for i=1:nostations
% 
% %    pwd
%     
%     realdatafilename{i}=[staname{i} 'raw.dat'];
%     
%         fid1  = fopen(realdatafilename{i},'r');
%         a=fscanf(fid1,'%f %f %f',[4 inf]);
%         fclose(fid1);
% 
%         data=a';
% %         disp('RAW MAXIMUM')
%         
% %         format('short','e')
% %         max(abs(data(:,2)));
% %         max(abs(data(:,3)));
% %         max(abs(data(:,4)));
% 
%         %%%%%%%%%%convert to displacement
%         disnsf=cumtrapz(data(:,2))*dtres;
%         disewf=cumtrapz(data(:,3))*dtres;
%         disvef=cumtrapz(data(:,4))*dtres;
% %        disp('displacement unfiltered')
% %         max(abs(disnsf))
% %         max(abs(disewf))
% %         max(abs(disvef))
%         
%         %%%%filter
%          dnsf=bandpass(disnsf,f2,f3,length(data),dtres);
%          dewf=bandpass(disewf,f2,f3,length(data),dtres);
%          dvef=bandpass(disvef,f2,f3,length(data),dtres);
% 
%         %%%%%%%%%%%% compute sqrt(sum(ampl^2)) as weight
%         %%%%%%%%%%%% it was just max amplitude before...
%         %%%%%%%%%%%% change 24/6/2010
%         
% disp( [ staname{i} '   '  num2str(sqrt(sum(dnsf.^2))) '   '  num2str(sqrt(sum(dewf.^2))) '   '  num2str(sqrt(sum(dvef.^2))) ])
% 
% %         
% %        fprintf(fid2,'%s  %i %e %e %e\r\n',staname{i},use,max(abs(dnsf)),max(abs(dewf)),max(abs(dvef)));
% 
% fprintf(fid2,'%s  %i %e %e %e\r\n',staname{i},use, sqrt(sum(dnsf.^2)),sqrt(sum(dewf.^2)),sqrt(sum(dvef.^2)));
% 
% end
% fclose(fid2);
% cd ..
% 
% %%% add information
% warndlg('Weights were computed successfully and allstat.dat was updated','!! Info !!');
% 
% catch
%     
%     disp('Error reading data files. Please check if all files exist')
%     cd ..
%     
% end


%%%%%%%%%%%%%%%%%filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function f1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function f1_Callback(hObject, eventdata, handles)
% hObject    handle to f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f1 as text
%        str2double(get(hObject,'String')) returns contents of f1 as a double

% calculate SNR

% first read allstat.dat
if ispc 
  h=dir('.\invert\allstat.dat');
else
  h=dir('./invert/allstat.dat');
end

  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
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

      switch cnt
            case 9
                 disp('Found current version of allstat e.g. STA 1 1 1 1 f1 f2 f3 f4')
                 if ispc 
                   [stanames,usestn,od2,od3,od4,of1,of2,of3,of4] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                 else
                   [stanames,usestn,od2,od3,od4,of1,of2,of3,of4] = textread('./invert/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                 end
                 nsta=length(stanames);
            case 6
                 disp('Found version of allstat without frequencies e.g. 001 1 1 1 1 STA')
                 if ispc 
                   [~,usestn,od2,od3,od4,stanames] = textread('.\invert\allstat.dat','%s %f %f %f %f %s',-1);
                 else
                   [~,usestn,od2,od3,od4,stanames] = textread('./invert/allstat.dat','%s %f %f %f %f %s',-1);
                 end
                 % assign default to f1 f2 f3 f4
                 nsta=length(stanames);
                 of1=ones(nsta,1)*0.04;of2=ones(nsta,1)*0.05;of3=ones(nsta,1)*0.08;of4=ones(nsta,1)*0.09;
            case 5
                 disp('Found old version of allstat without frequencies and without station masking e.g. STA 1 1 1 1 ')
                 if ispc
                   [stanames,usestn,od2,od3,od4] = textread('.\invert\allstat.dat','%s %f %f %f %f',-1);
                 else
                   [stanames,usestn,od2,od3,od4] = textread('./invert/allstat.dat','%s %f %f %f %f',-1);
                 end
                 % assign default to f1 f2 f3 f4
                 nsta=length(stanames);
                 of1=ones(nsta,1)*0.04;of2=ones(nsta,1)*0.05;of3=ones(nsta,1)*0.08;of4=ones(nsta,1)*0.09;
      end

  end
  
% read f1 f4 and use them

  freq1=str2double(get(handles.f1,'String'));freq11=ones(nsta,1)*freq1;
  freq4=str2double(get(handles.f4,'String'));freq44=ones(nsta,1)*freq4;  
        
%% calculate  SNR now...
snr=zeros(1,nsta);
% check if we have files and compute overall SNR  
              for i=1:nsta
                 realdatafilename{i}=[ char(stanames(i)) 'snr.dat'];
              end

                for i=1:nsta
                  if exist(realdatafilename{i},'file')
%                      disp(['Found ' realdatafilename{i} ])
                        % now open files and compute SNR
                        % if station is included in inversion
                        if usestn(i)==1
                            snr(i)=avesnr(realdatafilename{i},freq11(i),freq44(i));
                            disp(['Calculating SNR for station  ' char(stanames(i)) ' and freq ' num2str(freq11(i)) ' - ' num2str(freq44(i))])
                            
                            disp('  ')
                        else
                            disp(['Station ' char(stanames(i))   ' not included in inversion'])
                            disp('  ')
                        end
                             
                  else 
                      disp(['File ' realdatafilename{i} ' is missing. Nan will be used'])
                     % errordlg(['File ' realdatafilename{i} '  not found in isola run folder  ' pwd ' . Run S/N spectral analysis tool for this station' ] ,'File Error');   
                      % make SNR null ...???
                      snr(i)=NaN;
                  end
                end
            
disp(['Mean SNR over all stations ' num2str(nanmean(snr))])
set(handles.snrvalue,'String',num2str(fix(nanmean(snr))))


% --- Executes during object creation, after setting all properties.
function f2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function f2_Callback(hObject, eventdata, handles)
% hObject    handle to f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f2 as text
%        str2double(get(hObject,'String')) returns contents of f2 as a double


% --- Executes during object creation, after setting all properties.
function f3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function f3_Callback(hObject, eventdata, handles)
% hObject    handle to f3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f3 as text
%        str2double(get(hObject,'String')) returns contents of f3 as a double


% --- Executes during object creation, after setting all properties.
function f4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function f4_Callback(hObject, eventdata, handles)
% hObject    handle to f4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f4 as text
%        str2double(get(hObject,'String')) returns contents of f4 as a double

% calculate SNR

% first read allstat.dat
if ispc 
  h=dir('.\invert\allstat.dat');
else
  h=dir('./invert/allstat.dat');
end

  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
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

      switch cnt
            case 9
                 disp('Found current version of allstat e.g. STA 1 1 1 1 f1 f2 f3 f4')
                 if ispc
                    [stanames,usestn,od2,od3,od4,of1,of2,of3,of4] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                 else
                    [stanames,usestn,od2,od3,od4,of1,of2,of3,of4] = textread('./invert/allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                 end
                 nsta=length(stanames);
            case 6
                 disp('Found version of allstat without frequencies e.g. 001 1 1 1 1 STA')
                 if ispc 
                    [~,usestn,od2,od3,od4,stanames] = textread('.\invert\allstat.dat','%s %f %f %f %f %s',-1);
                 else
                    [~,usestn,od2,od3,od4,stanames] = textread('./invert/allstat.dat','%s %f %f %f %f %s',-1);
                 end
                 % assign default to f1 f2 f3 f4
                 nsta=length(stanames);
                 of1=ones(nsta,1)*0.04;of2=ones(nsta,1)*0.05;of3=ones(nsta,1)*0.08;of4=ones(nsta,1)*0.09;
            case 5
                 disp('Found old version of allstat without frequencies and without station masking e.g. STA 1 1 1 1 ')
                 if ispc
                    [stanames,usestn,od2,od3,od4] = textread('.\invert\allstat.dat','%s %f %f %f %f',-1);
                 else
                    [stanames,usestn,od2,od3,od4] = textread('./invert/allstat.dat','%s %f %f %f %f',-1);
                 end
                 % assign default to f1 f2 f3 f4
                 nsta=length(stanames);
                 of1=ones(nsta,1)*0.04;of2=ones(nsta,1)*0.05;of3=ones(nsta,1)*0.08;of4=ones(nsta,1)*0.09;
      end

  end
  
% read f1 f4 and use them

  freq1=str2double(get(handles.f1,'String'));freq11=ones(nsta,1)*freq1;
  freq4=str2double(get(handles.f4,'String'));freq44=ones(nsta,1)*freq4;  
        
%% calculate  SNR now...
snr=zeros(1,nsta);
% check if we have files and compute overall SNR  
              for i=1:nsta
                 realdatafilename{i}=[ char(stanames(i)) 'snr.dat'];
              end

                for i=1:nsta
                  if exist(realdatafilename{i},'file')
%                      disp(['Found ' realdatafilename{i} ])
                        % now open files and compute SNR
                        % if station is included in inversion
                        if usestn(i)==1
                            snr(i)=avesnr(realdatafilename{i},freq11(i),freq44(i));
                            disp(['Calculating SNR for station  ' char(stanames(i)) ' and freq ' num2str(freq11(i)) ' - ' num2str(freq44(i))])
                            
                            disp('  ')
                        else
                            disp(['Station ' char(stanames(i))   ' not included in inversion'])
                            disp('  ')
                        end
                             
                  else 
                      disp(['File ' realdatafilename{i} ' is missing. Nan will be used'])
                     % errordlg(['File ' realdatafilename{i} '  not found in isola run folder  ' pwd ' . Run S/N spectral analysis tool for this station' ] ,'File Error');   
                      % make SNR null ...???
                      snr(i)=NaN;
                  end
                end
            
disp(['Mean SNR over all stations ' num2str(nanmean(snr))])
set(handles.snrvalue,'String',num2str(fix(nanmean(snr))))


% --- Executes during object creation, after setting all properties.
function starttime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to starttime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function starttime_Callback(hObject, eventdata, handles)
% hObject    handle to starttime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of starttime as text
%        str2double(get(hObject,'String')) returns contents of starttime as a double

dtres=handles.dtres;
nsources=handles.nsourcestext;
%%%read values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stime = str2double(get(handles.starttime,'String'))
tstep = str2double(get(handles.timestep,'String'))     
etime = str2double(get(handles.endtime,'String'))
%%%check if it exceeds maximum..!!!!
%%%%convert time step in seconds to time step in samples...
ifirst=round(stime/dtres);
istep=round(tstep/dtres);
ilast=round(etime/dtres);

minimumd = -2500*dtres;
maximumd = 2500*dtres;

%%%%check how many steps...
if (ifirst >= 0 && ilast > 0 )
  iseqm=(ilast-ifirst)/istep;
elseif  (ifirst < 0 && ilast <= 0 )
  iseqm=(abs(ifirst)-abs(ilast))/istep;
elseif (ifirst < 0 && ilast >= 0 )
  iseqm=(ilast+abs(ifirst))/istep;
else
    disp('check your time search inputs')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if iseqm > minimumd && iseqm < maximumd

    set(handles.trialts,'String',num2str(iseqm,'%5.2g'),...)
                        'ForegroundColor','black')        
                    
else iseqm < minimumd || iseqm > maximumd
    
    set(handles.trialts,'String',num2str(iseqm,'%5.2g'),...
                        'ForegroundColor','red')        
end


% --- Executes during object creation, after setting all properties.
function nsubevents_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nsubevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function nsubevents_Callback(hObject, eventdata, handles)
% hObject    handle to nsubevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nsubevents as text
%        str2double(get(hObject,'String')) returns contents of nsubevents as a double

function mutual_exclude(off)
set(off,'Value',0)

function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')



% --- Executes during object creation, after setting all properties.
function moment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to moment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function moment_Callback(hObject, eventdata, handles)
% hObject    handle to moment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of moment as text
%        str2double(get(hObject,'String')) returns contents of moment as a double


% --- Executes during object creation, after setting all properties.
function delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function delay_Callback(hObject, eventdata, handles)
% hObject    handle to delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delay as text
%        str2double(get(hObject,'String')) returns contents of delay as a double


% --- Executes on button press in corelplot.
function corelplot_Callback(hObject, eventdata, handles)
% hObject    handle to corelplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 

%find out the current corr*.dat file
%based on file time..!!

% try
% cd invert
% files=dir('corr*.dat');
% fileindex=length(files);
% cd ..
% catch
%     cd ..
%     pwd
% end
if ispc
   cname=findrecentfile('.\invert\corr*.dat');
else
   cname=findrecentfile('./invert/corr*.dat');
end

% cname=['corr' num2str(fileindex,'%02d') '.dat'];
% psname= ['corr' num2str(fileindex,'%02d') '.ps'];

psname=[cname(1:6) '.ps']


disp(['Now plotting  ' cname '   correlation file'])

%%%%
dtres=handles.dtres;
nsources=handles.nsourcestext;
distep=handles.distep;
sdepth=handles.sdepth;
conplane=handles.conplane;
eventid=handles.eventid;
%%%%%%%%%%%%%%%%%%%%%%%%%%%
nooftimesteps=handles.nooftimesteps
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%  time step in seconds
tstep = get(handles.timestep,'String');  
%%%%%%%%%%%%%%%%%%%%

%%%% check if we want fixed interval
drcont= get(handles.drcont,'Value');

%%%% find out time searcg limits  for plotting of correlation
negtime=get(handles.negtime,'String');
postime=get(handles.postime,'String');
%%%% find out source limits for plotting of correlation
fsrc=get(handles.fsrc,'String');
lsrc=get(handles.lsrc,'String');

%%%%what type of contours correlation or dc..
dcplot= get(handles.dcplot,'Value');

%%%% draw contours..???
drawcont= get(handles.drawcont,'Value');

%%%% invert palette..???
invpal= get(handles.invpal,'Value');

%%%%%%%%%%%%%%%%%%%font size....
fsize = get(handles.fsize,'String');

%%% correl parameters ...
scalex = get(handles.scalex,'String');
scaley = get(handles.scaley,'String');
fscale = get(handles.fscale,'String');

%%%%%cpt file
val = get(handles.gmtpal,'Value');
string_list = get(handles.gmtpal,'String');
gmtpal = string_list{val};


if drawcont == 1
     wline='-W0.5p';
else
     wline='-W+1.0p';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('correl.isl','w');
   if ispc
         fprintf(fid,'%s\r\n',scalex);
         fprintf(fid,'%s\r\n',scaley);
         fprintf(fid,'%s\r\n',fscale);
         fprintf(fid,'%s\r\n',gmtpal);
         fprintf(fid,'%s\r\n',fsize);
   else
         fprintf(fid,'%s\n',scalex);
         fprintf(fid,'%s\n',scaley);
         fprintf(fid,'%s\n',fscale);
         fprintf(fid,'%s\n',gmtpal);
         fprintf(fid,'%s\n',fsize);
   end
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%check if we are in invert..??
% try
cd invert

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% here we find name of correl.dat 
%%%%%
h=dir(cname);

if isempty(h); 
    errordlg([cname 'file doesn''t exist. Run Invert. '],'File Error');
    cd ..
  return    
else
    
    % check if we have new format of correl file
               fid = fopen(cname,'r');
                tline = fgetl(fid);tline = fgetl(fid);
                tline = fgetl(fid);
               fclose(fid);
              
               if length(tline) > 100
                    disp('New correlation file format')
%                    correlage='new';
               % read in new format
                 fid = fopen(cname,'r');
                 [srcpos,srctime,variance,str1,dip1,rake1,str2,dip2,rake2,dc,volume,misfit,moment] = textread(cname,'%f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',2);
                 fclose(fid);               
               %% test plot
%                   figure
% %                   subplot(4,1,1);plot(srcpos,misfit,'+');xlabel('Source Position');ylabel('Misfit')
% %                   subplot(4,1,2);plot(misfit,volume,'+');xlabel('Misfit');ylabel('Volume')
%                   subplot(2,1,1);plot(variance,volume,'+');xlabel('Correlation');ylabel('Volume')
%                   subplot(2,1,2);plot(misfit,volume,'+');xlabel('Misfit');ylabel('Volume')

                  %
               else % old format
                    disp('Old correlation file format')

                 fid = fopen(cname,'r');
                 [srcpos,srctime,variance,str1,dip1,rake1,str2,dip2,rake2,dc,moment] = textread(cname,'%f %f %f %f %f %f %f %f %f %f %f','headerlines',2);
                 fclose(fid);
               end
                    
                 
               
%     cd ..
end

% size(srcpos)
% size(srctime)
% size(variance)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% decide what to plot source no of distance...(depth..)
%%% type of inversion

%%%% Findout if we need Plane or line of sources....!!!

if conplane == 0   %%%% Depth line

    %%% go on as line....
if get(handles.udistdep,'Value') == get(handles.udistdep,'Max')   %%%% distance plot

disp('Plotting correlation with Depth')

%srcpos=((srcpos-distep)*distep); %+sdepth;
srcpos=((srcpos-1)*distep)+sdepth;

%%%%%%%%%%%%%%%%%%%%%    prepare for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%find variance maximum and index ...
[maxvar,index]=max(variance);
%
bbcut=get(handles.bbcut,'String');
  cor_cut=maxvar*(str2num(bbcut)/100)

%
maxsource=srcpos(index);
maxsrctime=srctime(index);
maxstr1=str1(index);
maxdip1=dip1(index);
maxrake1=rake1(index);
maxstr2=str2(index);
maxdip2=dip2(index);
maxrake2=rake2(index);
maxdc=dc(index);
%
disp('Maximum Correlation mechanism  STR1  DIP1  RAKE1  STR2  DIP2  RAKE2  DC%' )
mstring=['        ' num2str(maxvar) '                 '  num2str(maxstr1) '    '  num2str(maxdip1) '    '  num2str(maxrake1) '    '  num2str(maxstr2) '    '  num2str(maxdip2) '   '  num2str(maxrake2) '   ' num2str(maxdc)];
disp(mstring)
ststring=['At time shift   ' num2str(maxsrctime) '   and distance (km)   ' num2str(maxsource) ];  %  ' + starting depth ' num2str(sdepth)];
disp(ststring)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% set the selected source for correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot
%%%
   set(handles.selsrc,'String',num2str(((maxsource-sdepth)/distep)+1))

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%annotation interval...
if drcont == 1 
     cptstep= str2num(get(handles.annotint,'String'));
     dc_cptstep=str2num(get(handles.annotint,'String'));
else
     if maxvar <= 0.1
       cptstep=0.02;
     elseif maxvar > 0.1 && maxvar <= 0.2
       cptstep=0.05;
     else
       cptstep=0.1;
     end
  
     dc_cptstep=10;
end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%make batch file for GMT plotting
% 
stime = str2num(get(handles.starttime,'String'));
dtstep = str2num(get(handles.tsdt,'String'));      %%%% time step in dt...
etime = str2num(get(handles.endtime,'String'));

nsources=handles.nsourcestext;

%%% prepare a meca gmt style file for maximum correlation
    fid = fopen('maxval.foc','w');
       if ispc
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\r\n',maxsrctime,maxsource,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
       else
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\n',maxsrctime,maxsource,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
       end
    fclose(fid);

%%% prepare a gmt style file for correlation
    fid = fopen('plcor.bat','w');
      if ispc
        fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
      else
        fprintf(fid,'%s\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
      end

           
      if ispc
        st=['gawk "{if (NR>2 && $3 > ' num2str(cor_cut) ')  print $2,'  num2str(sdepth) '+($1-1)*' num2str(distep) ',$10,$4,$5,$6,"5","0","0"}" ' cname ' > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk "{if (NR>2)  print $2,'  num2str(sdepth) '+($1-1)*' num2str(distep) ',$10}" ' cname ' > corcon.dat'];
           else
           nd=['gawk "{if (NR>2)  print $2,'  num2str(sdepth) '+($1-1)*' num2str(distep) ',$3}" ' cname ' > corcon.dat'];
           end
 
         fprintf(fid,'%s\r\n',st);
         fprintf(fid,'%s\r\n',nd);
      else
        st=['gawk ''{if (NR>2)  print $2,'  num2str(sdepth) '+($1-1)*' num2str(distep) ',$10,$4,$5,$6,"5","0","0"}'' ' cname ' > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk ''{if (NR>2)  print $2,'  num2str(sdepth) '+($1-1)*' num2str(distep) ',$10}'' ' cname ' > corcon.dat'];
           else
           nd=['gawk ''{if (NR>2)  print $2,'  num2str(sdepth) '+($1-1)*' num2str(distep) ',$3}'' ' cname ' > corcon.dat'];
           end
         fprintf(fid,'%s\n',st);
         fprintf(fid,'%s\n',nd);
      end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1
    
    
       if invpal == 1
          if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          end
 
       else
          if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          end
 
       end
     
     
else
    if ispc
     fprintf(fid,'%s\r\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
    else
     fprintf(fid,'%s\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if invpal == 1
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) ' -I  > cr.cpt'];
else
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) '     > cr.cpt'];
end

  if ispc
    fprintf(fid,'%s\r\n',vstring);
  else
    fprintf(fid,'%s\n',vstring);
  end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1

    fdis=((str2num(fsrc)-1)*distep)+sdepth;
    ldis=((str2num(lsrc)-1)*distep)+sdepth;
    
gimstring=['pscontour corcon.dat -R'  num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep))  '/' num2str(fdis-0.5) '/' num2str(ldis+0.5)  '  ' wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Time(sec)":/1:"Source position (km)":WeSn -Cdc.cpt -K -I -A+a0+s' fsize ' > ' psname ];

    if ispc
      fprintf(fid,'%s\r\n',gimstring);
    else
      fprintf(fid,'%s\n',gimstring);
    end

else

    fdis=((str2num(fsrc)-1)*distep)+sdepth;
    ldis=((str2num(lsrc)-1)*distep)+sdepth;
    
%num2str(sdepth-0.5) '/' num2str( (((nsources-1)*distep)+sdepth)+0.5    )    
gimstring=['pscontour corcon.dat -R'  num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep))  '/' num2str(fdis-0.5) '/' num2str(ldis+0.5)  '  ' wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Time(sec)":/1:"Source position (km)":WeSn -Ccr.cpt -K -I -A+a0+s' fsize ' > ' psname ];
    if ispc
       fprintf(fid,'%s\r\n',gimstring);
    else
       fprintf(fid,'%s\n',gimstring);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
      %%%%%%%
         if dcplot == 1
          scalestr=['psscale -D' num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Cdc.cpt -K -L -B:DC: >> ' psname];
          scalestr2=[];
         else
          scalestr=['psscale -D'   num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Ccr.cpt -K -L -B:Correlation: >> ' psname];
          scalestr2=['psscale -D'  num2str(str2num(scalex)+1) 'c/13c/7c/0.2 -O -Cdc.cpt -K -L  -B::/:DC\045: >> ' psname ];
         end
         
   if ispc      
    fprintf(fid,'%s\r\n',scalestr);
    fprintf(fid,'%s\r\n',scalestr2);
   else
    fprintf(fid,'%s\n',scalestr);
    fprintf(fid,'%s\n',scalestr2);
   end
% %%%time scale...!!
%    tstring=['psxy -R' num2str((min(srctime)),'%5.2f') '/' num2str((max(srctime)),'%5.2f')  '/' num2str(sdepth-0.5) '/' num2str( (((nsources-1)*distep)+sdepth)+0.5    ) ' -JX' scalex '/' scaley  ' time.tmp -B1g1:"Time(sec)":/' num2str(distep/2) 'g' num2str(distep/2) ':"Source Position (km)":WeSn  -O -K >>  ' psname];
%    fprintf(fid,'%s\r\n',tstring);
%%%%%%%%%%%%%%%%%%%%%%%%%focal  

       mecstring=['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' fscale ' -O -K testfoc.dat -Zdc.cpt >> ' psname ];
  if ispc     
    fprintf(fid,'%s\r\n',mecstring);
  else
    fprintf(fid,'%s\n',mecstring);
  end
       mecstringmax =['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' num2str(str2num(fscale)+0.1) ' -O maxval.foc -G255/0/0 >> ' psname ];
  if ispc
    fprintf(fid,'%s\r\n',mecstringmax);
  else
    fprintf(fid,'%s\n',mecstringmax);
  end

%%% add option to convert to PNG using ps2raster...26/10/09    
if ispc
    fprintf(fid,'%s\r\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D..\output' ]);
    fprintf(fid,'%s\r\n',['rename ..\output\' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
    fprintf(fid,'%s\r\n','del testfoc.dat corcon.dat dc.cpt cr.cpt  maxval.foc  ');
else
    fprintf(fid,'%s\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D../output -F'  eventid '_' psname(1:6)   ]);
%    fprintf(fid,'%s\n',['mv ../output/' psname(1:6) '.png ' '../output/' eventid '_' psname(1:6) '.png']);
    fprintf(fid,'%s\n','rm testfoc.dat corcon.dat dc.cpt cr.cpt  maxval.foc  ');
end
    
%%% add info for starting depth    
% %%%make a tmp file for starting depthx, y, size, angle, fontno, justify, text
%     fid1 = fopen('sdepth.tmp','w');
%          fprintf(fid1,'%s ',num2str(min(srctime)),num2str(sdepth-0.5),'16','0','1','1','Starting Depth',num2str( sdepth));
%     fclose(fid1);
% %%%%%%%%%%%%%%%
% 
%        sdepthstr =['pstext -R sdepth.tmp -JX' scalex '/' scaley  ' -O -G255/0/0 -N >> ' psname ];
%     fprintf(fid,'%s\r\n',sdepthstr);
    
        fclose(fid);

else

disp('Plotting correlation with source number')    %%%%%% source number plot

%%%%find variance maximum and index ...
[maxvar,index]=max(variance);
%
bbcut=get(handles.bbcut,'String');
  cor_cut=maxvar*(str2num(bbcut)/100)
%
maxsource=srcpos(index);
maxsrctime=srctime(index);
maxstr1=str1(index);
maxdip1=dip1(index);
maxrake1=rake1(index);
maxstr2=str2(index);
maxdip2=dip2(index);
maxrake2=rake2(index);
maxdc=dc(index);

disp('Maximum Correlation mechanism  STR1  DIP1  RAKE1  STR2  DIP2  RAKE2  DC%' )
mstring=['        ' num2str(maxvar) '                 '  num2str(maxstr1) '    '  num2str(maxdip1) '    '  num2str(maxrake1) '    '  num2str(maxstr2) '    '  num2str(maxdip2) '   '  num2str(maxrake2) '   ' num2str(maxdc)];
disp(mstring)
ststring=['At time shift   ' num2str(maxsrctime) '   and source position   ' num2str(maxsource)];
disp(ststring)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
    set(handles.selsrc,'String',num2str(maxsource))

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%annotation interval...
if drcont == 1 
     cptstep= str2num(get(handles.annotint,'String'));
     dc_cptstep=str2num(get(handles.annotint,'String'));
else
     if maxvar <= 0.1
       cptstep=0.02;
     elseif maxvar > 0.1 && maxvar <= 0.2
       cptstep=0.05;
     else
       cptstep=0.1;
     end
     
     dc_cptstep=10;
end        

%%%%
nsources=handles.nsourcestext;

%%%
%%% prepare a meca gmt style file for maximum correlation
    fid = fopen('maxval.foc','w');
      if ispc
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\r\n',maxsrctime,maxsource,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
      else
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\n',maxsrctime,maxsource,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
      end
    fclose(fid);


    fid = fopen('plcor.bat','w');
           
  if ispc
           st=['gawk "{if (NR>2 && $3 > ' num2str(cor_cut) ')  print $2,$1,$10,$4,$5,$6,"5","0","0"}" ' cname ' > testfoc.dat'];   
          
           if dcplot == 1
           nd=['gawk "{if (NR>2)  print $2,$1,$10}" ' cname ' > corcon.dat'];
           else
           nd=['gawk "{if (NR>2)  print $2,$1,$3}" ' cname ' > corcon.dat'];    
           end
           
    fprintf(fid,'%s\r\n',st);
    fprintf(fid,'%s\r\n',nd);
    fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
  else
           st=['gawk ''{if (NR>2)  print $2,$1,$10,$4,$5,$6,"5","0","0"}'' ' cname ' > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk ''{if (NR>2)  print $2,$1,$10}'' ' cname ' > corcon.dat'];
           else
           nd=['gawk ''{if (NR>2)  print $2,$1,$3}'' ' cname ' > corcon.dat'];    
           end
    fprintf(fid,'%s\n',st);
    fprintf(fid,'%s\n',nd);
    fprintf(fid,'%s\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1
    
    
       if invpal == 1
          if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          end
 
       else
          if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          end
 
       end
     
     
else
   if ispc
     fprintf(fid,'%s\r\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   else
     fprintf(fid,'%s\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if invpal == 1
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) ' -I  > cr.cpt'];
else
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) '     > cr.cpt'];
end

  if ispc
    fprintf(fid,'%s\r\n',vstring);
  else
    fprintf(fid,'%s\n',vstring);
  end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%gimstring=['pscontour corcon.dat -R'  num2str(stime) '/' num2str(etime)  '/' '0' '/' num2str(nsources+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -Ccr.cpt -K -I -A+s' fsize ' > ' psname ];
%%% added time limits
%gimstring=['pscontour corcon.dat -R'  num2str(min(srctime)-str2num(tstep)) '/' num2str(max(srctime)+str2num(tstep))  '/' '0' '/' num2str(nsources+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Time(sec)":/1:"Source position":WeSn -Ccr.cpt -K -I -A+s' fsize ' > ' psname ];
if dcplot == 1
gimstring=['pscontour corcon.dat -R'  num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep))  '/' num2str(str2num(fsrc)-1) '/' num2str(str2num(lsrc)+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Time(sec)":/1:"Source position":WeSn -Cdc.cpt -K -I -A+a0+s' fsize ' > ' psname ];
else
gimstring=['pscontour corcon.dat -R'  num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep))  '/' num2str(str2num(fsrc)-1) '/' num2str(str2num(lsrc)+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Time(sec)":/1:"Source position":WeSn -Ccr.cpt -K -I -A+a0+s' fsize ' > ' psname ];
end

%%%%%%
if ispc
  fprintf(fid,'%s\r\n',gimstring);
else
  fprintf(fid,'%s\n',gimstring);
end

%%%%%%%
         if dcplot == 1
          scalestr=['psscale -D' num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Cdc.cpt -K -L -B:DC: >> ' psname];
          scalestr2=[];
         else
          scalestr=['psscale -D'   num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Ccr.cpt -K -L -B:Correlation: >> ' psname];
          scalestr2=['psscale -D'  num2str(str2num(scalex)+1) 'c/13c/7c/0.2 -O -Cdc.cpt -K -L  -B::/:DC\045: >> ' psname ];
         end
         
if ispc         
    fprintf(fid,'%s\r\n',scalestr);
    fprintf(fid,'%s\r\n',scalestr2);
else
    fprintf(fid,'%s\n',scalestr);
    fprintf(fid,'%s\n',scalestr2);
end
%     %%%time scale...!!
%        tstring=['psxy -R' num2str((min(srctime)),'%5.2f') '/' num2str((max(srctime)),'%5.2f')  '/' '0' '/' num2str(nsources+1) ' -JX' scalex 'c/' scaley  'c time.tmp -B1g1:"Time(sec)":/1:"Source position":WeSn  -O -K >>  ' psname];
%     fprintf(fid,'%s\r\n',tstring);
% %%%%%%%%%%%%%%%%%%%%%%%%%focal  

       mecstring=['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' fscale ' -O -K testfoc.dat -Zdc.cpt >> ' psname ];
  if ispc       
    fprintf(fid,'%s\r\n',mecstring);
  else
    fprintf(fid,'%s\n',mecstring);
  end
       mecstringmax =['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' num2str(str2num(fscale)+0.1) ' -O maxval.foc -G255/0/0 >> ' psname ];
  if ispc
     fprintf(fid,'%s\r\n',mecstringmax);
  else
     fprintf(fid,'%s\n',mecstringmax);
  end
    
    %%% add option to convert to PNG using ps2raster...26/10/09    
if ispc    
    fprintf(fid,'%s\r\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D..\output' ]);
    fprintf(fid,'%s\r\n',['rename ..\output\' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
    fprintf(fid,'%s\r\n','del testfoc.dat corcon.dat dc.cpt cr.cpt  maxval.foc  ');
else
    fprintf(fid,'%s\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D../output' ]);
    fprintf(fid,'%s\n',['mv ../output/' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
    fprintf(fid,'%s\n','rm testfoc.dat corcon.dat dc.cpt cr.cpt  maxval.foc  ');
end
    fclose(fid);
    
end


elseif conplane == 1   %%%%%%%%%% New code for Plane plot correlation...!!!
    
    
disp('Ploting Correlation on the plane of sources best correlation per source ...')

%%%%%%%%%%%%%%%%%%Read data from handles....
noSourcesstrike=handles.noSourcesstrike;
strikestep=handles.strikestep;
noSourcesdip=handles.noSourcesdip;
dipstep=handles.dipstep;

%%%find out which is the best time shift.....
%disp('Plotting correlation with Distance-Depth')

% srcpos=srcpos*distep;

%%%%%%%%%%%%%%%%%%%%%    prepare for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%find variance maximum and index ...
[maxvar,index]=max(variance)
%
maxsource=srcpos(index);
maxsrctime=srctime(index);
maxstr1=str1(index);
maxdip1=dip1(index);
maxrake1=rake1(index);
maxstr2=str2(index);
maxdip2=dip2(index);
maxrake2=rake2(index);
maxdc=dc(index);
%
disp('Maximum Correlation mechanism  STR1  DIP1  RAKE1  STR2  DIP2  RAKE2  DC%' )
mstring=['        ' num2str(maxvar) '                 '  num2str(maxstr1) '    '  num2str(maxdip1) '    '  num2str(maxrake1) '    '  num2str(maxstr2) '    '  num2str(maxdip2) '   '  num2str(maxrake2) '   ' num2str(maxdc)];
disp(mstring)
ststring=['At time shift   ' num2str(maxsrctime) '   and source   ' num2str(maxsource)];
disp(ststring)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
    set(handles.selsrc,'String',num2str(maxsource))

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%select all the data at the best time shift...
%% and put in array...
k=1;
  for i=1:noSourcesdip
    for j=1:noSourcesstrike
          posx(k)=i;
          posy(k)=j;
          k=k+1;
    end          
  end

%                                     old code....
j=1;
for i=1:length(srcpos)
    
    if srctime(i) == maxsrctime
       plane(j,1)=srcpos(i);
       plane(j,2)=srctime(i);
       plane(j,3)=variance(i);
       plane(j,4)=str1(i);
       plane(j,5)=dip1(i);
       plane(j,6)=rake1(i);
       plane(j,7)=str2(i);
       plane(j,8)=dip2(i);
       plane(j,9)=rake2(i);
       plane(j,10)=dc(i);
       plane(j,11)=moment(i);
       j=j+1;
   else
   end
   
end

correlation=0;
besttime=0;

fid = fopen('planecor.dat','w');

for i=1:nsources

   for j=1:nsources*nooftimesteps

      if srcpos(j)==i
        % find best correlation per source...
        if  variance(j) > correlation   
            correlation=variance(j);
            besttime=srctime(j); bstr1=str1(j);bdip1=dip1(j); brake1=rake1(j);
            bstr2=str2(j); bdip2=dip2(j); brake2=rake2(j); bdc=dc(j); bmoment=moment(j);
        else
        end
     else   
    %     disp('no  ')
     end 
   end  

     correl(i)=correlation;besttim(i)=besttime;
     bbstr1(i)=bstr1;bbdip1(i)=bdip1; bbrake1(i)=brake1;
     bbstr2(i)=bstr2;bbdip2(i)=bdip2; bbrake2(i)=brake2;
     bbdc(i)=bdc; bbmoment(i)=bmoment;
     
     disp(['Source no  ' num2str(i) '   best corr '  num2str(correl(i)) ' at time ' num2str(besttim(i))  ]) 
  if ispc
     fprintf(fid,'%i %g %g  %g %g %g %g  %g %g %g %g %i %i\r\n',i,besttim(i),correl(i),bbstr1(i),bbdip1(i),bbrake1(i),bbstr2(i),bbdip2(i), bbrake2(i),bbdc(i), bbmoment(i),posx(i),posy(i));
  else
     fprintf(fid,'%i %g %g  %g %g %g %g  %g %g %g %g %i %i\n',i,besttim(i),correl(i),bbstr1(i),bbdip1(i),bbrake1(i),bbstr2(i),bbdip2(i), bbrake2(i),bbdc(i), bbmoment(i),posx(i),posy(i));
  end
 correlation=0;
 besttime=0;
 
end

fclose(fid);


% [n,s]=size(plane);
% for i=1:n   %max(length(plane))
%     fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g  %g  %g  %g  %g\r\n',plane(i,1),plane(i,2),plane(i,3),plane(i,4),plane(i,5),plane(i,6),plane(i,7),plane(i,8),plane(i,9),plane(i,10),plane(i,11),posx(i),posy(i));
% end  
% 
% %%%%% %%%%%%%%

%%%%combine in one matrix and find out position of best solution
planec=[plane posx' posy'];
[maxvar,index]=max(planec(:,3));

maxsource=planec(index,1);
%maxsrctime=srctime(index);
maxstr1=planec(index,4);
maxdip1=planec(index,5);
maxrake1=planec(index,6);
maxstr2=planec(index,7);
maxdip2=planec(index,8);
maxrake2=planec(index,9);
maxdc=planec(index,10);
max_x=planec(index,12);
max_y=planec(index,13);

%%%%%%%%%%%%%%%%%%%%%%%% prepare GMT plotting


%%%%%%%%%%annotation interval...
if drcont == 1 
     cptstep= str2num(get(handles.annotint,'String'));
     dc_cptstep=str2num(get(handles.annotint,'String'));
else
     if maxvar <= 0.1
       cptstep=0.02;
     elseif maxvar > 0.1 && maxvar <= 0.2
       cptstep=0.05;
     else
       cptstep=0.1;
     end
     
     dc_cptstep=10;
end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stime = 0;
tstep = 1;   
etime = noSourcesdip+1;

nsources=handles.nsourcestext;

%%%
%%% prepare a meca gmt style file for maximum correlation
    fid = fopen('maxval.foc','w');
      if ispc
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\r\n',max_x,max_y,5,maxstr1,maxdip1,maxrake1,5,0,0);
      else
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\n',max_x,max_y,5,maxstr1,maxdip1,maxrake1,5,0,0);
      end
    fclose(fid);


    fid = fopen('plcor.bat','w');
if ispc
           st=['gawk "{ print $12,$13,$10,$4,$5,$6,"5","0","0",$1}" planecor.dat > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk "{ print $12,$13,$10}" planecor.dat  > corcon.dat'];
           else
           nd=['gawk "{ print $12,$13,$3}"  planecor.dat  > corcon.dat'];    
           end

    fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
    fprintf(fid,'%s\r\n',st);
    fprintf(fid,'%s\r\n',nd);
else
           st=['gawk ''{ print $12,$13,$10,$4,$5,$6,"5","0","0",$1}'' planecor.dat > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk ''{ print $12,$13,$10}'' planecor.dat  > corcon.dat'];
           else
           nd=['gawk ''{ print $12,$13,$3}''  planecor.dat  > corcon.dat'];    
           end
    fprintf(fid,'%s\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
    fprintf(fid,'%s\n',st);
    fprintf(fid,'%s\n',nd);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1

    if invpal == 1
          if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
          end
    else
          if ispc 
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
          end
 
    end
     
else
   if ispc
     fprintf(fid,'%s\r\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   else
     fprintf(fid,'%s\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if invpal == 1
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) ' -I  > cr.cpt'];
else
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) '     > cr.cpt'];
end

  if ispc
    fprintf(fid,'%s\r\n',vstring);
  else
    fprintf(fid,'%s\n',vstring);
  end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1
 gimstring=['pscontour corcon.dat -R'  num2str(stime) '/' num2str(etime)  '/' '0' '/' num2str(noSourcesstrike+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -Cdc.cpt -K -I -A+a0+s' fsize ' -B1g1:"Dip":/1g1:"Strike":WeSn > ' psname ];
else
 gimstring=['pscontour corcon.dat -R'  num2str(stime) '/' num2str(etime)  '/' '0' '/' num2str(noSourcesstrike+1)  '   '   wline  ' -JX' scalex 'c/' scaley 'c -Ccr.cpt -K -I -A+a0+s' fsize ' -B1g1:"Dip":/1g1:"Strike":WeSn > ' psname ];
end
 %%%%%%
 if ispc
    fprintf(fid,'%s\r\n',gimstring);
 else
    fprintf(fid,'%s\n',gimstring);
 end
 %%%%%%%
         if dcplot == 1
          scalestr=['psscale -D' num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Cdc.cpt -K -L -B:DC: >> ' psname];
          scalestr2=[];
         else
          scalestr=['psscale -D'   num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Ccr.cpt -K -L -B:Correlation: >> ' psname];
          scalestr2=['psscale -D'  num2str(str2num(scalex)+1) 'c/13c/7c/0.2 -O -Cdc.cpt -K -L  -B::/:DC\045: >> ' psname ];
         end
if ispc         
    fprintf(fid,'%s\r\n',scalestr);
    fprintf(fid,'%s\r\n',scalestr2);
else
    fprintf(fid,'%s\n',scalestr);
    fprintf(fid,'%s\n',scalestr2);
end
%     %%%time scale...!!
%        tstring=['psxy -R' num2str((min(srctime)),'%5.2f') '/' num2str((max(srctime)),'%5.2f')  '/' '0' '/' num2str(nsources+1) ' -JX' scalex '/' scaley  ' time.tmp -B1g1:"Time(sec)":/1:"Source position":WeSn  -O -K >>  ' psname];
%     fprintf(fid,'%s\r\n',tstring);
% %%%%%%%%%%%%%%%%%%%%%%%%%focal  

       mecstring=['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' fscale ' -O -K testfoc.dat -Zdc.cpt >> ' psname ];
if ispc       
    fprintf(fid,'%s\r\n',mecstring);
else
    fprintf(fid,'%s\n',mecstring);
end
       mecstringmax =['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' num2str(str2num(fscale)+0.1) ' -O maxval.foc -G255/0/0 >> ' psname ];
if ispc       
    fprintf(fid,'%s\r\n',mecstringmax);
    %%% add option to convert to PNG using ps2raster...26/10/09    
    fprintf(fid,'%s\r\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D..\output' ]);
    fprintf(fid,'%s\r\n',['rename ..\output\' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);

else
    fprintf(fid,'%s\n',mecstringmax);
    %%% add option to convert to PNG using ps2raster...26/10/09    
    fprintf(fid,'%s\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D../output' ]);
    fprintf(fid,'%s\n',['mv ../output/' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
end

    
    fclose(fid);
 

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
elseif conplane == 2   %%%%%%%%%% New code for line plot with time correlation...!!!
disp('Ploting Correlation on the line of sources with time  ...')

    %%% go on as line....
if get(handles.udistdep,'Value') == get(handles.udistdep,'Max')   %%%% distance plot

disp('Plotting correlation on line of sources with time')

%srcpos=((srcpos-distep)*distep); %+sdepth;
srcpos=((srcpos-1)*distep)+sdepth;

%%%%%%%%%%%%%%%%%%%%%    prepare for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%find variance maximum and index ...
[maxvar,index]=max(variance);
%
maxsource=srcpos(index);
maxsrctime=srctime(index);
maxstr1=str1(index);
maxdip1=dip1(index);
maxrake1=rake1(index);
maxstr2=str2(index);
maxdip2=dip2(index);
maxrake2=rake2(index);
maxdc=dc(index);
%
disp('Maximum Correlation mechanism  STR1  DIP1  RAKE1  STR2  DIP2  RAKE2  DC%' )
mstring=['        ' num2str(maxvar) '                 '  num2str(maxstr1) '    '  num2str(maxdip1) '    '  num2str(maxrake1) '    '  num2str(maxstr2) '    '  num2str(maxdip2) '   '  num2str(maxrake2) '   ' num2str(maxdc)];
disp(mstring)
ststring=['At time shift   ' num2str(maxsrctime) '   and distance (km)   ' num2str(maxsource) ];  %  ' + starting depth ' num2str(sdepth)];
disp(ststring)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% set the selected source for correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot
%%%
   set(handles.selsrc,'String',num2str(((maxsource-sdepth)/distep)+1))

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%annotation interval...
if drcont == 1 
     cptstep= str2num(get(handles.annotint,'String'));
     dc_cptstep=str2num(get(handles.annotint,'String'));
else
     if maxvar <= 0.1
       cptstep=0.02;
     elseif maxvar > 0.1 && maxvar <= 0.2
       cptstep=0.05;
     else
       cptstep=0.1;
     end
  
     dc_cptstep=10;
end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%make batch file for GMT plotting
% 
stime = str2num(get(handles.starttime,'String'));
dtstep = str2num(get(handles.tsdt,'String'));      %%%% time step in dt...
etime = str2num(get(handles.endtime,'String'));

nsources=handles.nsourcestext;

%%% prepare a meca gmt style file for maximum correlation
    fid = fopen('maxval.foc','w');
      if ispc
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\r\n',maxsource,maxsrctime,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
      else
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\n',maxsource,maxsrctime,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
      end
    fclose(fid);

%%% prepare a gmt style file for correlation
    fid = fopen('plcor.bat','w');
    if ispc    
        fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
    else
        fprintf(fid,'%s\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
    end
    
    
if ispc
           st=['gawk "{print '  num2str(sdepth) '+($1-1)*' num2str(distep) ',$2,$10,$4,$5,$6,"5","0","0"}" ' cname ' > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk "{print '  num2str(sdepth) '+($1-1)*' num2str(distep) ',$2,$10}" ' cname ' > corcon.dat'];
           else
           nd=['gawk "{print '  num2str(sdepth) '+($1-1)*' num2str(distep) ',$2,$3}" ' cname ' > corcon.dat'];
           end
    fprintf(fid,'%s\r\n',st);
    fprintf(fid,'%s\r\n',nd);
else
           st=['gawk ''{print '  num2str(sdepth) '+($1-1)*' num2str(distep) ',$2,$10,$4,$5,$6,"5","0","0"}'' ' cname ' > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk ''{print '  num2str(sdepth) '+($1-1)*' num2str(distep) ',$2,$10}'' ' cname ' > corcon.dat'];
           else
           nd=['gawk ''{print '  num2str(sdepth) '+($1-1)*' num2str(distep) ',$2,$3}'' ' cname ' > corcon.dat'];
           end
    fprintf(fid,'%s\n',st);
    fprintf(fid,'%s\n',nd);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1
    
    
       if invpal == 1
           if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
           else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
           end
       else
           if ispc 
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
           else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
           end
        end
     
     
else
   if ispc
     fprintf(fid,'%s\r\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   else
     fprintf(fid,'%s\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if invpal == 1
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) ' -I  > cr.cpt'];
else
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) '     > cr.cpt'];
end

  if ispc
    fprintf(fid,'%s\r\n',vstring);
  else
    fprintf(fid,'%s\n',vstring);
  end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1

    fdis=((str2num(fsrc)-1)*distep)+sdepth;
    ldis=((str2num(lsrc)-1)*distep)+sdepth;
    
gimstring=['pscontour corcon.dat -R'  num2str(fdis-0.5) '/' num2str(ldis+0.5) '/' num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep)) '  ' wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Source position (km)":/1:"Time(sec)":WeSn -Cdc.cpt -K -I -A+a0+s' fsize ' > ' psname ];
  if ispc
    fprintf(fid,'%s\r\n',gimstring);
  else
    fprintf(fid,'%s\n',gimstring);
  end
else

    fdis=((str2num(fsrc)-1)*distep)+sdepth;
    ldis=((str2num(lsrc)-1)*distep)+sdepth;
    
%num2str(sdepth-0.5) '/' num2str( (((nsources-1)*distep)+sdepth)+0.5    )    
gimstring=['pscontour corcon.dat -R'  num2str(fdis-0.5) '/' num2str(ldis+0.5) '/'  num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep))  '  ' wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Source position (km)":/1:"Time(sec)":WeSn -Ccr.cpt -K -I -A+a0+s' fsize ' > ' psname ];
  if ispc
    fprintf(fid,'%s\r\n',gimstring);
  else
    fprintf(fid,'%s\n',gimstring);
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
      %%%%%%%
         if dcplot == 1
          scalestr=['psscale -D' num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Cdc.cpt -K -L -B:DC: >> ' psname];
          scalestr2=[];
         else
          scalestr=['psscale -D'   num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Ccr.cpt -K -L -B:Correlation: >> ' psname];
          scalestr2=['psscale -D'  num2str(str2num(scalex)+1) 'c/13c/7c/0.2 -O -Cdc.cpt -K -L  -B::/:DC\045: >> ' psname ];
         end
   if ispc         
    fprintf(fid,'%s\r\n',scalestr);
    fprintf(fid,'%s\r\n',scalestr2);
   else
    fprintf(fid,'%s\n',scalestr);
    fprintf(fid,'%s\n',scalestr2);
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mecstring=['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' fscale ' -O -K testfoc.dat -Zdc.cpt >> ' psname ];
    mecstringmax =['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' num2str(str2num(fscale)+0.1) ' -O maxval.foc -: -G255/0/0 >> ' psname ];
 if ispc
    fprintf(fid,'%s\r\n',mecstring);
    fprintf(fid,'%s\r\n',mecstringmax);
    fprintf(fid,'%s\r\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D..\output' ]);
    fprintf(fid,'%s\r\n',['rename ..\output\' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
 else
    fprintf(fid,'%s\n',mecstring);
    fprintf(fid,'%s\n',mecstringmax);
    fprintf(fid,'%s\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D../output' ]);
    fprintf(fid,'%s\n',['mv ../output/' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
 end
 
 
 fclose(fid);

else

disp('Plotting correlation with source number as x axis and time as y axis')    %%%%%% source number plot

%%%%find variance maximum and index ...
[maxvar,index]=max(variance);
%
maxsource=srcpos(index);
maxsrctime=srctime(index);
maxstr1=str1(index);
maxdip1=dip1(index);
maxrake1=rake1(index);
maxstr2=str2(index);
maxdip2=dip2(index);
maxrake2=rake2(index);
maxdc=dc(index);

disp('Maximum Correlation mechanism  STR1  DIP1  RAKE1  STR2  DIP2  RAKE2  DC%' )
mstring=['        ' num2str(maxvar) '                 '  num2str(maxstr1) '    '  num2str(maxdip1) '    '  num2str(maxrake1) '    '  num2str(maxstr2) '    '  num2str(maxdip2) '   '  num2str(maxrake2) '   ' num2str(maxdc)];
disp(mstring)
ststring=['At time shift   ' num2str(maxsrctime) '   and source position   ' num2str(maxsource)];
disp(ststring)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
    set(handles.selsrc,'String',num2str(maxsource))

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%annotation interval...
if drcont == 1 
     cptstep= str2num(get(handles.annotint,'String'));
     dc_cptstep=str2num(get(handles.annotint,'String'));
else
     if maxvar <= 0.1
       cptstep=0.02;
     elseif maxvar > 0.1 && maxvar <= 0.2
       cptstep=0.05;
     else
       cptstep=0.1;
     end
     
     dc_cptstep=10;
end        

%%%%
nsources=handles.nsourcestext;

%%%
%%% prepare a meca gmt style file for maximum correlation
    fid = fopen('maxval.foc','w');
       if ispc
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\r\n',maxsrctime,maxsource,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
       else
          fprintf(fid,'%g  %g  %g  %g  %g  %g  %g  %g  %g\n',maxsrctime,maxsource,maxdc,maxstr1,maxdip1,maxrake1,5,0,0);
       end
    fclose(fid);


    fid = fopen('plcor.bat','w');

if ispc
           st=['gawk "{print $1,$2,$10,$4,$5,$6,"5","0","0"}" ' cname ' > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk "{ print $1,$2,$10}" ' cname ' > corcon.dat'];
           else
           nd=['gawk "{ print $1,$2,$3}" ' cname ' > corcon.dat'];    
           end
           
    fprintf(fid,'%s\r\n',st);
    fprintf(fid,'%s\r\n',nd);
    fprintf(fid,'%s\r\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
else
           st=['gawk ''{print $1,$2,$10,$4,$5,$6,"5","0","0"}'' ' cname ' > testfoc.dat'];   
           
           if dcplot == 1
           nd=['gawk ''{ print $1,$2,$10}'' ' cname ' > corcon.dat'];
           else
           nd=['gawk ''{ print $1,$2,$3}'' ' cname ' > corcon.dat'];    
           end

    fprintf(fid,'%s\n',st);
    fprintf(fid,'%s\n',nd);
    fprintf(fid,'%s\n','gmtset ANNOT_FONT_SIZE_PRIMARY 11 LABEL_FONT_SIZE 14');
end


  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1
    
    
       if invpal == 1
           if ispc
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
           else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10 -I > dc.cpt']);
           end
 
        else
            if ispc 
            fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
           else
            fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10    > dc.cpt']);
           end

        end
     
     
else
   if ispc
     fprintf(fid,'%s\r\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   else
     fprintf(fid,'%s\n','makecpt -Ccopper -T0/100/10 -I > dc.cpt');
   end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if invpal == 1
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) ' -I  > cr.cpt'];
else
    
           vstring=['makecpt -C' gmtpal ' -T0/' num2str(maxvar+0.05) '/' num2str(cptstep) '     > cr.cpt'];
end

  if ispc
    fprintf(fid,'%s\r\n',vstring);
  else
    fprintf(fid,'%s\n',vstring);
  end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dcplot == 1
gimstring=['pscontour corcon.dat -R'  num2str(str2num(fsrc)-1) '/' num2str(str2num(lsrc)+1)  '/' num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep))   '   '   wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Source position (km)":/1:"Time(sec)":WeSn -Cdc.cpt -K -I -A+a0+s' fsize ' > ' psname ];
else
gimstring=['pscontour corcon.dat -R'  num2str(str2num(fsrc)-1) '/' num2str(str2num(lsrc)+1)  '/' num2str(str2num(negtime)-str2num(tstep)) '/' num2str(str2num(postime)+str2num(tstep))   '   '   wline  ' -JX' scalex 'c/' scaley 'c -B1g1:"Source position (km)":/1:"Time(sec)":WeSn -Ccr.cpt -K -I -A+a0+s' fsize ' > ' psname ];
end

%%%%%%
  if ispc
    fprintf(fid,'%s\r\n',gimstring);
  else
    fprintf(fid,'%s\n',gimstring);
  end
  
%%%%%%%
         if dcplot == 1
          scalestr=['psscale -D' num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Cdc.cpt -K -L -B:DC: >> ' psname];
          scalestr2=[];
         else
          scalestr=['psscale -D'   num2str(str2num(scalex)+1) 'c/4c/7c/0.2 -O -Ccr.cpt -K -L -B:Correlation: >> ' psname];
          scalestr2=['psscale -D'  num2str(str2num(scalex)+1) 'c/13c/7c/0.2 -O -Cdc.cpt -K -L  -B::/:DC\045: >> ' psname ];
         end
 if ispc         
    fprintf(fid,'%s\r\n',scalestr);
    fprintf(fid,'%s\r\n',scalestr2);
 else
    fprintf(fid,'%s\n',scalestr);
    fprintf(fid,'%s\n',scalestr2);
 end
   
       mecstring=['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' fscale ' -O -K testfoc.dat -Zdc.cpt >> ' psname ];
       mecstringmax =['psmeca -R -JX' scalex 'c/' scaley 'c -Sa' num2str(str2num(fscale)+0.1) ' -O maxval.foc -: -G255/0/0 >> ' psname ];

 if ispc
    fprintf(fid,'%s\r\n',mecstring);
    fprintf(fid,'%s\r\n',mecstringmax);
    fprintf(fid,'%s\r\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D..\output' ]);
    fprintf(fid,'%s\r\n',['rename ..\output\' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
 else
    fprintf(fid,'%s\n',mecstring);
    fprintf(fid,'%s\n',mecstringmax);
    fprintf(fid,'%s\n',['ps2raster ' psname  ' -Tg -P -E75 -Qg2  -Qt2 -D../output' ]);
    fprintf(fid,'%s\n',['mv ../output/' psname(1:6) '.png ' eventid '_' psname(1:6) '.png']);
 end    

    
    fclose(fid);
    
end

  
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%main end      
end



% %%% run batch file...
% [s,r]=system('plcor.bat');
% cr=['gsview32 ' psname ];
% system( cr );

%%% run batch file...
if ispc
   [s,r]=system('plcor.bat'); 
else
    !chmod +x plcor.bat
    !./plcor.bat
   [s,r]=system('plcor.bat'); 
end

cd .. %%% return to main folder before plotting.... this should solve problems if user tried to plot waveforms before closing ps file...

if ispc
  system(['gsview32 .\invert\' psname]);
else
  system(['gv ./invert/' psname]);

end

%%% try to load in Matlab..!!! 
% system('gswin32c -sDEVICE=png -sOUTPUTFILE=a.png -sDEVICE=png16m -dGraphicsAlphaBits=4 -dBATCH -dNOPROMPT -dNOPAUSE  a.ps');
% [X,map] = imread('a.Correlationg');
% disp('ok png')
% figure
% image(X)
% axis off

% %%%return to isola
% cd ..
pwd

% catch
%     cd ..
%     pwd
% end

% --- Executes during object creation, after setting all properties.
function scalex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scalex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function scalex_Callback(hObject, eventdata, handles)
% hObject    handle to scalex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scalex as text
%        str2double(get(hObject,'String')) returns contents of scalex as a double


% --- Executes during object creation, after setting all properties.
function fscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fscale_Callback(hObject, eventdata, handles)
% hObject    handle to fscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fscale as text
%        str2double(get(hObject,'String')) returns contents of fscale as a double


% --- Executes during object creation, after setting all properties.
function gmtpal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gmtpal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function gmtpal_Callback(hObject, eventdata, handles)
% hObject    handle to gmtpal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gmtpal as text
%        str2double(get(hObject,'String')) returns contents of gmtpal as a double


% --- Executes during object creation, after setting all properties.
function scaley_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaley (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function scaley_Callback(hObject, eventdata, handles)
% hObject    handle to scaley (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaley as text
%        str2double(get(hObject,'String')) returns contents of scaley as a double


% --- Executes on button press in deselect.
function deselect_Callback(hObject, eventdata, handles)
% hObject    handle to deselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% cd invert
% 
% dos('notepad allstat.dat &')
% 
% cd ..
% find if we need common freq band for all stations

if (get(handles.freqcheck,'Value') == get(handles.freqcheck,'Max'))
   % Checkbox is checked
   disp('Selected common frequency band option.')
   % we need to give the f1 f2 f3 f4 freq to stagui
   f1=str2double(get(handles.f1,'String'));
   f2=str2double(get(handles.f2,'String'));
   f3=str2double(get(handles.f3,'String'));
   f4=str2double(get(handles.f4,'String'));
  
        stagui(f1,f2,f3,f4)

   try
     v = evalin('base', 'snrvalue');
     set(handles.snrvalue,'String',num2str(fix(v)));
   catch
     disp('SNR not defined')
   end
   
else
   disp('Selected different frequency band per station option.')
   
      stagui

   try
     v = evalin('base', 'snrvalue');
     set(handles.snrvalue,'String',num2str(fix(v)));
   catch
     disp('SNR not defined')
   end
     
end





% --- Executes on button press in fullmt.
function fullmt_Callback(hObject, eventdata, handles)
% hObject    handle to fullmt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fullmt

off =[handles.free,handles.fixed,handles.dc];
mutual_exclude(off)

off =[handles.strike,handles.dip,handles.rake,handles.striketext,handles.diptext,handles.raketext];
enableoff(off)


% --- Executes on button press in usourceno.
function usourceno_Callback(hObject, eventdata, handles)
% hObject    handle to usourceno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of usourceno
off =[handles.udistdep];
mutual_exclude(off)


% --- Executes on button press in udistdep.
function udistdep_Callback(hObject, eventdata, handles)
% hObject    handle to udistdep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of udistdep

off =[handles.usourceno];
mutual_exclude(off)


% --- Executes on button press in drcont.
function drcont_Callback(hObject, eventdata, handles)
% hObject    handle to drcont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of drcont

check=get(handles.drcont,'Value');

if check == 1
on =[handles.annotint];
enableon(on)
else
off =[handles.annotint];
enableoff(off)
end    



% --- Executes during object creation, after setting all properties.
function annotint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to annotint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function annotint_Callback(hObject, eventdata, handles)
% hObject    handle to annotint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of annotint as text
%        str2double(get(hObject,'String')) returns contents of annotint as a double


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


% --- Executes on button press in dcplot.
function dcplot_Callback(hObject, eventdata, handles)
% hObject    handle to dcplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dcplot

check=get(handles.dcplot,'Value');

if check == 1
set(handles.annotint,'String','10')
else
set(handles.annotint,'String','0.1')
end    


% --- Executes during object creation, after setting all properties.
function sliderstdt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderstdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function sliderstdt_Callback(hObject, eventdata, handles)
% hObject    handle to sliderstdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

valst=get(handles.sliderstdt,'Value');
set(handles.stdt,'String',num2str(round(valst)));

dtres=handles.dtres;
value = str2num(get(handles.stdt,'String'));
set(handles.starttime,'String',num2str(dtres*value),'ForegroundColor','black')        

%%%%%%%%%%%%%%%%%%%%%%%%
ifirst = str2double(get(handles.stdt,'String'));
istep = str2double(get(handles.tsdt,'String'));  
ilast = str2double(get(handles.etdt,'String'));
%%%%%%%%%%%%%%%%%%%%

%%%%check how many steps...
if (ifirst >= 0 && ilast > 0 )
  iseqm=(ilast-ifirst)/istep;
elseif  (ifirst < 0 && ilast <= 0 )
  iseqm=(abs(ifirst)-abs(ilast))/istep;
elseif (ifirst < 0 && ilast >= 0 )
  iseqm=(ilast+abs(ifirst))/istep;
else
    disp('check your time search inputs')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if iseqm <= 100  
               set(handles.trialts,'String',num2str(round(iseqm)),...)
                        'ForegroundColor','black') 
               set(handles.many,'String','')        
        elseif iseqm > 100 
               set(handles.trialts,'String',num2str(round(iseqm)),...)
                        'ForegroundColor','red')        
               set(handles.many,'String','too many shifts',...)
                        'ForegroundColor','red')        
        end
                
% --- Executes during object creation, after setting all properties.
function stdt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function stdt_Callback(hObject, eventdata, handles)
% hObject    handle to stdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stdt as text
%        str2double(get(hObject,'String')) returns contents of stdt as a double
dtres=handles.dtres;
value = str2num(get(handles.stdt,'String'));
set(handles.starttime,'String',num2str(dtres*value),'ForegroundColor','black')        




% --- Executes during object creation, after setting all properties.
function slidertsdt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slidertsdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slidertsdt_Callback(hObject, eventdata, handles)
% hObject    handle to slidertsdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

valts=get(handles.slidertsdt,'Value');
set(handles.tsdt,'String',num2str(round(valts)));

dtres=handles.dtres;
value = str2num(get(handles.tsdt,'String'));
set(handles.timestep,'String',num2str(dtres*value),'ForegroundColor','black')        

%%%%%%%%%%%%%%%%%%%%%%%%
ifirst = str2double(get(handles.stdt,'String'));
istep = str2double(get(handles.tsdt,'String'));  
ilast = str2double(get(handles.etdt,'String'));
%%%%%%%%%%%%%%%%%%%%

%%%%check how many steps...
if (ifirst >= 0 && ilast > 0 )
  iseqm=(ilast-ifirst)/istep;
elseif  (ifirst < 0 && ilast <= 0 )
  iseqm=(abs(ifirst)-abs(ilast))/istep;
elseif (ifirst < 0 && ilast >= 0 )
  iseqm=(ilast+abs(ifirst))/istep;
else
    disp('check your time search inputs')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if iseqm <= 100  
               set(handles.trialts,'String',num2str(round(iseqm)),...)
                        'ForegroundColor','black') 
               set(handles.many,'String','')        
        elseif iseqm > 100 
               set(handles.trialts,'String',num2str(round(iseqm)),...)
                        'ForegroundColor','red')        
               set(handles.many,'String','too many shifts',...)
                        'ForegroundColor','red')        
        end
                    

% --- Executes during object creation, after setting all properties.
function tsdt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tsdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tsdt_Callback(hObject, eventdata, handles)
% hObject    handle to tsdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tsdt as text
%        str2double(get(hObject,'String')) returns contents of tsdt as a double

dtres=handles.dtres;
value = str2num(get(handles.tsdt,'String'));
set(handles.timestep,'String',num2str(dtres*value),'ForegroundColor','black')        


% --- Executes during object creation, after setting all properties.
function slideretdt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideretdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slideretdt_Callback(hObject, eventdata, handles)
% hObject    handle to slideretdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

valet=get(handles.slideretdt,'Value');
set(handles.etdt,'String',num2str(round(valet)));

dtres=handles.dtres;
value = str2num(get(handles.etdt,'String'));
set(handles.endtime,'String',num2str(dtres*value),'ForegroundColor','black')        

%%%%%%%%%%%%%%%%%%%%%%%%
ifirst = str2double(get(handles.stdt,'String'));
istep = str2double(get(handles.tsdt,'String'));  
ilast = str2double(get(handles.etdt,'String'));
%%%%%%%%%%%%%%%%%%%%

%%%%check how many steps...
if (ifirst >= 0 && ilast > 0 )
  iseqm=(ilast-ifirst)/istep;
elseif  (ifirst < 0 && ilast <= 0 )
  iseqm=(abs(ifirst)-abs(ilast))/istep;
elseif (ifirst < 0 && ilast >= 0 )
  iseqm=(ilast+abs(ifirst))/istep;
else
    disp('check your time search inputs')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if iseqm <= 100  
               set(handles.trialts,'String',num2str(round(iseqm)),...)
                        'ForegroundColor','black') 
               set(handles.many,'String','')        
        elseif iseqm > 100 
               set(handles.trialts,'String',num2str(round(iseqm)),...)
                        'ForegroundColor','red')        
               set(handles.many,'String','too many shifts',...)
                        'ForegroundColor','red')        
        end
                    
% --- Executes during object creation, after setting all properties.
function etdt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function etdt_Callback(hObject, eventdata, handles)
% hObject    handle to etdt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etdt as text
%        str2double(get(hObject,'String')) returns contents of etdt as a double

dtres=handles.dtres;
value = str2num(get(handles.etdt,'String'));
set(handles.endtime,'String',num2str(dtres*value),'ForegroundColor','black')        


% --- Executes on button press in interp.
function interp_Callback(hObject, eventdata, handles)
% hObject    handle to interp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of interp


% --- Executes on button press in drawcont.
function drawcont_Callback(hObject, eventdata, handles)
% hObject    handle to drawcont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of drawcont



% --- Executes during object creation, after setting all properties.
function selsrc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selsrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function selsrc_Callback(hObject, eventdata, handles)
% hObject    handle to selsrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selsrc as text
%        str2double(get(hObject,'String')) returns contents of selsrc as a double


% --- Executes on button press in plot1source.
function plot1source_Callback(hObject, eventdata, handles)
% hObject    handle to plot1source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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

cname=['corr' num2str(fileindex,'%02d') '.dat'];
psname= ['corr' num2str(fileindex,'%02d') '.ps'];

disp(['Now plotting  ' cname '   correlation file'])

%%%%
dtres=handles.dtres;
nsources=handles.nsourcestext;
distep=handles.distep;
%%% correl parameters ...
scalex = get(handles.scalex,'String');
scaley = get(handles.scaley,'String');
fscale = get(handles.fscale,'String');

%%%**** find out which source
selsrc = str2double(get(handles.selsrc,'String'));

%%%% find out time shift limits
negtime=get(handles.negtime,'String');
postime=get(handles.postime,'String');

%%%%% time shift step
tstep = str2double(get(handles.timestep,'String'));


%%%%%cpt file
val = get(handles.gmtpal,'Value');
string_list = get(handles.gmtpal,'String');
gmtpal = string_list{val};

 
%%check if we are in invert..??
try
cd invert

%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% here we find name of correl.dat 
%%%%%
h=dir(cname);

if isempty(h); 
    errordlg([cname 'file doesn''t exist. Run Invert. '],'File Error');
    cd ..
  return    
else
    fid = fopen(cname,'r');  % new corr file..!
    [srcpos,srctime,variance,str1,dip1,rake1,str2,dip2,rake2,dc,volume,misfit,moment] = textread(cname,'%f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',2);
    fclose(fid);
%     cd ..
end
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
j=1;
for i=1:length(srcpos),
    if srcpos(i)==selsrc
       seltime(j)=srctime(i);
       selvar(j)=variance(i);
       selstr1(j)=str1(i);
       seldip1(j)=dip1(i);
       selrake1(j)=rake1(i);
       selstr2(j)=str2(i);
       seldip2(j)=dip2(i);
       selrake2(j)=rake2(i);
       seldc(j)=dc(i);
       selmoment(j)=moment(i);
       j=j+1;
   else
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mw=(2/3)*(log10(selmoment)-9.1);         % mommag=(2/3)*(log10(mo(psrcpos)) - 9.1) %! Hanks & Kanamori (1979)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%find variance maximum and index for selected source
[maxvar,index]=max(selvar);
%
maxseltime  =seltime(index);
maxselstr1  =selstr1(index);
maxseldip1  =seldip1(index);
maxselrake1 =selrake1(index);
maxselstr2  =selstr2(index);
maxseldip2  =seldip2(index);
maxselrake2 =selrake2(index);
maxseldc    =seldc(index);
maxselmoment=selmoment(index);
maxselmw    =mw(index);

disp('Maximum Correlation mechanism  STR1  DIP1  RAKE1  STR2  DIP2  RAKE2  DC%' )
mstring=['        ' num2str(maxvar) '                 '  num2str(maxselstr1) '    '  num2str(maxseldip1) '    '  num2str(maxselrake1) '    '  num2str(maxselstr2) '    '  num2str(maxseldip2) '   '  num2str(maxselrake2) '   ' num2str(maxseldc)];
disp(mstring)
disp('  ')
ststring=['At time shift   ' num2str(maxseltime) 'sec or ' num2str(maxseltime/dtres) ' dt.'];
disp(ststring)
disp('  ')

disp('********************************************************************')
disp('Output of results +-10 dt around the best solution')
disp('Time shift(sec) dt Cor STR1  DIP1  RAKE1  STR2  DIP2  RAKE2  DC%  Mo   Mw' )
disp('********************************************************************')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output solution around the best correlation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% index
% length(seltime)

leftlimit=index-10;
rightlimit=index+10;

if leftlimit <= 0
    leftlimit=1;
end

if rightlimit > length(seltime)
    rightlimit=length(seltime);
end

%  
for j=leftlimit:1:rightlimit
out=[num2str(seltime(j)) '  ' num2str(seltime(j)./dtres) '  ' num2str(selvar(j)) '  ' num2str(selstr1(j)) '  ' num2str(seldip1(j)) '  ' num2str(selrake1(j)) '  ' num2str(selstr2(j)) '  ' num2str(seldip2(j)) '  ' num2str(selrake2(j)) '  ' num2str(seldc(j)) '  ' num2str(selmoment(j),'%6.4E') '  ' num2str(mw(j),'%4.2f') ];
       disp(out)
end
    
disp('********************************************************************')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%make a tmp file for adding source number write best solution too %%%%%%x, y, size, angle, fontno, justify, text
    fid1 = fopen('selsrc.tmp','w');
      if ispc   
         fprintf(fid1,'%s %s %s %s %s %s %s %s\r\n ',num2str(negtime),num2str(max(selvar+0.05)),'16','0','1','1','Source number',num2str( selsrc));
      else
         fprintf(fid1,'%s %s %s %s %s %s %s %s\n ',num2str(negtime),num2str(max(selvar+0.05)),'16','0','1','1','Source number',num2str( selsrc));
      end
    fclose(fid1);
%%%%best solution for selected source
    fid1 = fopen('selfoc.foc','w');
      if ispc 
         fprintf(fid1,'%f %f %f %f %f %f %f %f %f\r\n',maxseltime,maxvar,maxseldc,maxselstr1,maxseldip1,maxselrake1,maxselmw,maxseltime,maxvar+0.02);
      else
         fprintf(fid1,'%f %f %f %f %f %f %f %f %f\n',maxseltime,maxvar,maxseldc,maxselstr1,maxseldip1,maxselrake1,maxselmw,maxseltime,maxvar+0.02);
      end
    fclose(fid1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fid2 = fopen('selsrc.foc','w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%1  0.388029  67.834  142  79   93  5.37924  0  0  -5.28
for i=1:length(seltime),
      if ispc
        fprintf(fid2,'%f %f %f %f %f %f %f %s %s\r\n', seltime(i),selvar(i),seldc(i),selstr1(i),seldip1(i),selrake1(i),mw(i),'0','0');
      else
        fprintf(fid2,'%f %f %f %f %f %f %f %s %s\n', seltime(i),selvar(i),seldc(i),selstr1(i),seldip1(i),selrake1(i),mw(i),'0','0');
      end
end
    fclose(fid2);

%%%%%%%%%%%%%%%%%%%%%%%%
  fid = fopen('plsel1.bat','w');
    if ispc   
      fprintf(fid,'%s\r\n','gmtset PAPER_MEDIA A4');
      fprintf(fid,'%s\r\n',['makecpt -C' gmtpal ' -T0/100/10 > invsel.cpt']);
      %%% plot all the solutions
%     fprintf(fid,'%s\r\n',['psmeca -R' num2str(min(seltime)-0.2) '/' num2str(max(seltime)+0.2) '/' num2str(min(selvar)-0.1) '/' num2str(max(selvar)+0.1) ' -JX' scalex '/' scaley ' -Sa0.1i -K -B1g1:"Timeshift":/0.1g0.1:"Correlation":WeSn selsrc.foc -V -Zinv1.cpt  > invsel.ps']);
      fprintf(fid,'%s\r\n',['psmeca -R' negtime '/' postime '/' num2str(min(selvar)-0.1) '/' num2str(max(selvar)+0.1) ' -JX' scalex 'c/' scaley 'c -Sa' fscale ' -K -B1g1:"Time shift (sec) ":/0.1g0.1:"Correlation":WeSn selsrc.foc -V -Zinvsel.cpt  > invsel.ps']);
      fprintf(fid,'%s\r\n',['psmeca -R -JX -Sa' fscale ' -K -O selsrc.foc -V -T >> invsel.ps']); 
      %%% plot the solutions with the best correlation
      fprintf(fid,'%s\r\n',['psmeca -R -JX -Sa' num2str(str2num(fscale)+0.1) ' -K -O selfoc.foc -Zinvsel.cpt -C1p/255/0/0 >> invsel.ps']);
      fprintf(fid,'%s\r\n',['psmeca -R -JX -Sa' num2str(str2num(fscale)+0.1) ' -K -O selfoc.foc -V -T      -C1p/255/0/0 >> invsel.ps']);
      
      fprintf(fid,'%s\r\n','psscale -D25c/4c/8c/0.5c -O -K -Cinvsel.cpt -B::/:DC\045: >> invsel.ps');
      fprintf(fid,'%s\r\n','pstext -R selsrc.tmp -JX -O -G255/0/0 -N >> invsel.ps');
      fprintf(fid,'%s\r\n','del selsrc.tmp selfoc.foc selsrc.foc invsel.cpt ');
    else
      fprintf(fid,'%s\n','gmtset PAPER_MEDIA A4');
      fprintf(fid,'%s\n',['makecpt -C' gmtpal ' -T0/100/10 > invsel.cpt']);
      %%% plot all the solutions
%     fprintf(fid,'%s\n',['psmeca -R' num2str(min(seltime)-0.2) '/' num2str(max(seltime)+0.2) '/' num2str(min(selvar)-0.1) '/' num2str(max(selvar)+0.1) ' -JX' scalex '/' scaley ' -Sa0.1i -K -B1g1:"Timeshift":/0.1g0.1:"Correlation":WeSn selsrc.foc -V -Zinv1.cpt  > invsel.ps']);
      fprintf(fid,'%s\n',['psmeca -R' negtime '/' postime '/' num2str(min(selvar)-0.1) '/' num2str(max(selvar)+0.1) ' -JX' scalex 'c/' scaley 'c -Sa' fscale ' -K -B1g1:"Time shift (sec) ":/0.1g0.1:"Correlation":WeSn selsrc.foc -V -Zinvsel.cpt  > invsel.ps']);
      fprintf(fid,'%s\n',['psmeca -R -JX -Sa' fscale ' -K -O selsrc.foc -V -T >> invsel.ps']); 
      %%% plot the solutions with the best correlation
      fprintf(fid,'%s\n',['psmeca -R -JX -Sa' num2str(str2num(fscale)+0.1) ' -K -O selfoc.foc -Zinvsel.cpt -C1p/255/0/0 >> invsel.ps']);
      fprintf(fid,'%s\n',['psmeca -R -JX -Sa' num2str(str2num(fscale)+0.1) ' -K -O selfoc.foc -V -T      -C1p/255/0/0 >> invsel.ps']);
      
      fprintf(fid,'%s\n','psscale -D25c/4c/8c/0.5c -O -K -Cinvsel.cpt -B::/:DC\045: >> invsel.ps');
      fprintf(fid,'%s\n','pstext -R selsrc.tmp -JX -O -G255/0/0 -N >> invsel.ps');
      fprintf(fid,'%s\n','rm selsrc.tmp selfoc.foc selsrc.foc invsel.cpt ');
    end
   fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%

%%% run batch file...
if ispc
      [s,r]=system('plsel1.bat');
else
      !chmod +x plsel1.bat
      ! ./plsel1.bat
end
%% display
cd ..


if ispc 
  system('gsview32 .\invert\invsel.ps');
else
    system('gv ./invert/invsel.ps');  
end

%%%%%%%%%%%%%%%%

catch
     cd ..
     pwd
end

pwd


% --- Executes during object creation, after setting all properties.
function postime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to postime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function postime_Callback(hObject, eventdata, handles)
% hObject    handle to postime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of postime as text
%        str2double(get(hObject,'String')) returns contents of postime as a double


% --- Executes during object creation, after setting all properties.
function negtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to negtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function negtime_Callback(hObject, eventdata, handles)
% hObject    handle to negtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of negtime as text
%        str2double(get(hObject,'String')) returns contents of negtime as a double


% --- Executes on button press in plc.
function plc_Callback(hObject, eventdata, handles)
% hObject    handle to plc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


 


% --- Executes during object creation, after setting all properties.
function lsrc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lsrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function lsrc_Callback(hObject, eventdata, handles)
% hObject    handle to lsrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lsrc as text
%        str2double(get(hObject,'String')) returns contents of lsrc as a double


% --- Executes during object creation, after setting all properties.
function fsrc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fsrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fsrc_Callback(hObject, eventdata, handles)
% hObject    handle to fsrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fsrc as text
%        str2double(get(hObject,'String')) returns contents of fsrc as a double


% --- Executes on button press in invpal.
function invpal_Callback(hObject, eventdata, handles)
% hObject    handle to invpal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of invpal


% --- Executes on button press in resetw.
function resetw_Callback(hObject, eventdata, handles)
% hObject    handle to resetw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
h=dir('invert');

if isempty(h);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

nstations=str2double(get(handles.nstationstext,'String'));

%%
button = questdlg('Reset all weights to 1 ?',...
'Inversion ','Yes','No','Yes');

if strcmp(button,'Yes')
    
try
    cd invert
          
       disp('This code will work with new allstat.dat only')
       
         [staname,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
         nostations = length(staname);
    
    cd ..
catch
    msgbox('Allstat.dat file problem','Error');
    cd ..
    return
end

%%
     if nostations ~= nstations
         msgbox('Allstat.dat file problem. Number of Stations don''t match with number in GUI.','Error');
         return
     else
     end

%%
% we write in allstat.dat

cd invert

     dummy=1;
%       %%%%open allstat.dat for output !!!!!!!!!!!!!!!!
        fid = fopen('allstat.dat','w');
             for i=1:nostations
                if ispc
                   fprintf(fid,'%s  %i %i %i %i %f %f %f %f\r\n',staname{i},dummy,dummy,dummy,dummy,of1(i),of2(i),of3(i),of4(i));
                else
                   fprintf(fid,'%s  %i %i %i %i %f %f %f %f\n',staname{i},dummy,dummy,dummy,dummy,of1(i),of2(i),of3(i),of4(i));
                end
             end
             
%          if strcmp(allstatformat,'old')
%              for i=1:nostations
%                  if ispc
%                      fprintf(fid,'%s  %i %i %i %i\r\n',staname{i},dummy,dummy,dummy,dummy);
%                  else
%                      fprintf(fid,'%s  %i %i %i %i\n',staname{i},dummy,dummy,dummy,dummy);
%                  end
%              end
%          else
%              for i=1:nostations
%                  if ispc
%                     fprintf(fid,'%s  %i %i %i %i %s\r\n',stanamenumber{i},dummy,dummy,dummy,dummy,staname{i});
%                  else
%                     fprintf(fid,'%s  %i %i %i %i %s\n',stanamenumber{i},dummy,dummy,dummy,dummy,staname{i});
%                  end
%              end
% 
%          end   

     fclose(fid);
         disp('Done')
cd ..

elseif strcmp(button,'No')
   disp('Reset Weights Canceled ')
end


% --- Executes on button press in png.
function png_Callback(hObject, eventdata, handles)
% hObject    handle to png (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

%cname=['corr' num2str(fileindex,'%02d') '.dat'];
psname= ['corr' num2str(fileindex,'%02d') '.ps'];
pngname=['corr' num2str(fileindex,'%02d') '.png'];

disp(['Converting  ' psname ' Postscript file to PNG using ImageMagick. File will be moved at the \output folder..'])

try
cd invert
    fid = fopen('ps2png.bat','w');
      if ispc
    fprintf(fid,'%s\r\n',['convert -rotate "90" ' psname '  ' pngname ]);
    fprintf(fid,'%s\r\n',['copy '   pngname ' ..\output']);
    fprintf(fid,'%s\r\n',['del  '   pngname ]);
      else
    fprintf(fid,'%s\n',['convert -rotate "90" ' psname '  ' pngname ]);
    fprintf(fid,'%s\n',['copy '   pngname ' ..\output']);
    fprintf(fid,'%s\n',['del  '   pngname ]);
          
      end
    fclose(fid);

system('ps2png.bat')
system('del ps2png.bat')

cd ..
pwd

catch
     cd ..
     pwd
 end
 


% --- Executes on button press in plgeocor.
function plgeocor_Callback(hObject, eventdata, handles)
% hObject    handle to plgeocor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% call plotgeocor
if ispc
   plotgeocor
else
   disp('not for linux yet') 
end


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




% --- Executes on button press in plsnr.
function plsnr_Callback(hObject, eventdata, handles)
% hObject    handle to plsnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plotallsnrcurves



% --- Executes on button press in freqcheck.
function freqcheck_Callback(hObject, eventdata, handles)
% hObject    handle to freqcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of freqcheck





function bbcut_Callback(hObject, eventdata, handles)
% hObject    handle to bbcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bbcut as text
%        str2double(get(hObject,'String')) returns contents of bbcut as a double


% --- Executes during object creation, after setting all properties.
function bbcut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bbcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
