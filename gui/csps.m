function varargout = csps(varargin)
% CSPS M-file for csps.fig
%      CSPS, by itself, creates a new CSPS or raises the existing
%      singleton*.
%
%      H = CSPS returns the handle to a new CSPS or the handle to
%      the existing singleton*.
%
%      CSPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CSPS.M with the given input arguments.
%
%      CSPS('Property','Value',...) creates a new CSPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before csps_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to csps_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help csps

% Last Modified by GUIDE v2.5 09-Oct-2014 21:34:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @csps_OpeningFcn, ...
                   'gui_OutputFcn',  @csps_OutputFcn, ...
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


% --- Executes just before csps is made visible.
function csps_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to csps (see VARARGIN)

disp('This is csps.m')
disp('Ver.1.5   Date: 24/09/2014 ')
disp('Method described in Fojtikova and Zahradnik  SRL 2014 ')

%%
%check if CSPS exists..!
fh=exist('csps','dir');

if (fh~=7);
    errordlg('CSPS folder doesn''t exist. ISOLA will create it. ','Folder warning');
    mkdir('csps');
end

%check if GREEN exists..!
fh2=exist('green','dir');

if (fh2~=7);
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
   delete(handles.csps)
end
%

%check if INVERT exists..!
fh2=exist('invert','dir');

if (fh2~=7);
    errordlg('Invert folder doesn''t exist. Please create it. ','Folder Error');
   delete(handles.csps)
end
%

%check if INPINV.DAT exists..!
if ispc 
        fh2=exist('.\invert\inpinv.dat','file'); 
         if (fh2~=2);
                  errordlg('Invert folder doesn''t contain inpinv.dat. Please run inversion. ','File Error');
                  delete(handles.csps)
         end
else
        fh2=exist('./invert/inpinv.dat','file'); 
         if (fh2~=2);
                  errordlg('Invert folder doesn''t contain inpinv.dat. Please run inversion. ','File Error');
                  delete(handles.csps)
         end
end
%check if allstat.dat exists..!
if ispc 
       fh2=exist('.\invert\allstat.dat','file');
        if (fh2~=2);
                 errordlg('Invert folder doesn''t contain allstat.dat. Please run inversion. ','File Error');
                 delete(handles.csps)
        end
else
       fh2=exist('./invert/allstat.dat','file');
        if (fh2~=2);
                 errordlg('Invert folder doesn''t contain allstat.dat. Please run inversion. ','File Error');
                 delete(handles.csps)
        end
end


% check if we have stations.isl
     fh2=exist('stations.isl','file');
         if (fh2~=2);
           errordlg('stations.isl file doesn''t exist. Please select stations. ','File Error');
           delete(handles.csps)
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
%disp(['Found ' num2str(noelemse) ' elementary seismogram files.'])
%disp('  ');
disp(['Frequency Range in \invert\inpinv.dat is ' linetmp14]);
disp('  ');
         
%%  check if we have all needed elemse* files in invert
if ispc
       elfiles=dir('.\invert\elemse*.dat');
       ii=regexp({elfiles.name},'elemse..\.dat');
       elemfiles={elfiles(~cellfun('isempty',ii)).name};
       noelemse=length(elemfiles);
else
       elemfiles=dir('./invert/elemse*.dat');
       ii=regexp({elfiles.name},'elemse..\.dat');
       elemfiles={elfiles(~cellfun('isempty',ii)).name};
       noelemse=length(elemfiles);
end

%%
  for i=1:str2double(linetmp6)
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
       else
          errordlg(['You don''t have ' elfile ' elementary seismogram files in invert folder. Define trial sources or prepare green function correctly.'],'File error')
       end
       
  end
       
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

%%  copy files we need
if ispc 
   [status,message,~]=copyfile('.\green\crustal.dat','.\csps');
   if status==1
       disp('crustal file copied in csps folder succesfully.')
   else
       errordlg(['Problems with crustal file coping in csps folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./green/crustal.dat','./csps');
   if status==1
       disp('crustal file copied in csps folder succesfully.')
   else
       errordlg(['Problems with crustal file coping in csps folder. Message is ' message])
   end
end

%

if ispc 
   [status,message,~]=copyfile('.\green\station.dat','.\csps');
   if status==1
       disp('station file copied in csps folder succesfully.')
   else
       errordlg(['Problems with station file coping in csps folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./green/station.dat','./csps');
   if status==1
       disp('station file copied in csps folder succesfully.')
   else
       errordlg(['Problems with station file coping in csps folder. Message is ' message])
   end
end



%% copy allstat.dat
if ispc 
   [status,message,~]=copyfile('.\invert\allstat.dat','.\csps');
   if status==1
       disp('Allstat.dat file copied in csps folder succesfully.')
   else
       errordlg(['Problems with allstat.dat file coping in csps folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./invert/allstat.dat','./csps');
   if status==1
       disp('Allstat.dat file copied in csps folder succesfully.')
   else
       errordlg(['Problems with allstat.dat file coping in csps folder. Message is ' message])
   end
end

%% copy inpinv.dat
if ispc 
   [status,message,~]=copyfile('.\invert\inpinv.dat','.\csps');
   if status==1
       disp('Inpinv.dat file copied in csps folder succesfully.')
   else
       errordlg(['Problems with inpinv.dat file coping in csps folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./invert/inpinv.dat','./csps');
   if status==1
       disp('Inpinv.dat file copied in csps folder succesfully.')
   else
       errordlg(['Problems with inpinv.dat file coping in csps folder. Message is ' message])
   end
end

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
            linetmp16=fgetl(fid); 
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
            linetmp16=fgetl(fid); 
       fclose(fid);
end

% now write back
    if ispc 
      fid = fopen('.\csps\inpinv.dat','w');
          fprintf(fid,'%s\r\n',linetmp1);
          fprintf(fid,'%s\r\n','4');
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
          fprintf(fid,'%s\r\n',linetmp14);
          fprintf(fid,'%s\r\n',linetmp15);
          fprintf(fid,'%s\r\n',linetmp16);
      fclose(fid);
    else
      fid = fopen('./csps/inpinv.dat','w');
          fprintf(fid,'%s\n',linetmp1);
          fprintf(fid,'%s\n','4');
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
          fprintf(fid,'%s\n',linetmp14);
          fprintf(fid,'%s\n',linetmp15);
          fprintf(fid,'%s\n',linetmp16);
      fclose(fid);
    end

%%

h=dir('event.isl');

if isempty(h); 
  errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
  return
else
    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    fclose(fid);
end

% put epidepth as source depth

set(handles.newdepth,'String',num2str(epidepth))

% save to handles
handles.eventdate=eventdate;
handles.magn=magn;
handles.eventcor=eventcor;
handles.epidepth=epidepth;
handles.magn=magn;

% Choose default command line output for csps
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes csps wait for user response (see UIRESUME)
% uiwait(handles.csps);


% --- Outputs from this function are returned to the command line.
function varargout = csps_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in readfocmec.
function readfocmec_Callback(hObject, eventdata, handles)
% hObject    handle to readfocmec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[FileName,PathName] = uigetfile({'*.dat;*.txt'},'Select a file with 3 columns S/D/R and 1 header line');

%FileName; PathName   

%[s,d,r]=read_focmecout([PathName FileName]);

[s,d,r]=read_sdrfile([PathName FileName]);


% change rake from 0 to 1
r(r == 0) = 1;
% change dip from 90 to 89
d(d == 90) = 89;
% change dip from 0 to 1
d(d == 0) = 1;
% due to problems in fortran code with these values


% prepare the allfocmec.dat file

alld=[s'; d' ; r'];  

if ispc
    
  fid = fopen('.\csps\allfocmec.dat','w');
      fprintf(fid,'%f     %f     %f\r\n',alld);    
  fclose(fid);
else
  fid = fopen('./csps/allfocmec.dat','w');
      fprintf(fid,'%f     %f     %f\n',alld);    
  fclose(fid);
end

% save to handles for other routines
handles.strike=s;
handles.dip=d;
handles.rake=r;
handles.nsolutions=length(s);
% Update handles structure
guidata(hObject, handles);

on =[handles.plfocmec,handles.editallstat,handles.run,handles.inpol,handles.text1,handles.thres,handles.plot,handles.runinv];
enableon(on)
    



% --- Executes on button press in plfocmec.
function plfocmec_Callback(hObject, eventdata, handles)
% hObject    handle to plfocmec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%read from handles

strike1=handles.strike;
dip1=handles.dip;
rake1=handles.rake;


%%% call pl2pl to find second plane
for i=1:length(strike1)
[strike2(i),dip2(i),rake2(i)] = pl2pl(strike1(i),dip1(i),rake1(i));
end


%% plot nodal lines
figure

Stereonet(0,90*pi/180,1000*pi/180,1);
v=axis;

xlim([v(1),v(2)]); ylim([v(3),v(4)]);  % static limits

%whos
hold
 
tic
 for i=1:length(strike1)
     
     path = GreatCircleS(deg2rad(strike1(i)),deg2rad(dip1(i)),1);
     plot(path(:,1),path(:,2),'r-')

     path = GreatCircleS(deg2rad(strike2(i)),deg2rad(dip2(i)),1);
     plot(path(:,1),path(:,2),'r-')
 
%      Plot T axis (black, filled circle)
%       [xp,yp] = StCoordLine(deg2rad(aziT(i)),deg2rad(plungeT(i)),1);
%       plot(xp,yp,'mo','MarkerFaceColor','m');
%     
%      Plot P axis (black, filled circle)
%       [xp,yp] = StCoordLine(deg2rad(aziP(i)),deg2rad(plungeP(i)),1);
%       plot(xp,yp,'ko','MarkerFaceColor','k');
%     
    
 end

plot(0,0,'+','MarkerSize',8)

text( 0  , 1.1,'0','FontSize',12);          
text( 0  ,-1.1,'180','FontSize',12);  
text( 1.1, 0,'90','FontSize',12);          
text(-1.2, 0,'270','FontSize',12);     
  
toc

%%
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

[strikb,dipb,rakeb,dipdib]=nd2pl(dx,dy,dz,anx,any,anz);
      
      round(strikb);
      round(dipb);
      round(rakeb);

      function [anx,any,anz,dx,dy,dz] =pl2nd(strike,dip,rake)
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
 
      wstrik=strike*dtor;
      wdip=dip*dtor;
      wrake=rake*dtor;
 
      anx=-sin(wdip)*sin(wstrik);
      any=sin(wdip)*cos(wstrik);
      anz=-cos(wdip);
      dx=cos(wrake)*cos(wstrik)+cos(wdip)*sin(wrake)*sin(wstrik);
      dy=cos(wrake)*sin(wstrik)-cos(wdip)*sin(wrake)*cos(wstrik);
      dz=-sin(wdip)*sin(wrake);

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


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% clean files
if ispc
 delete('.\csps\extrapol.pol')
else
 delete('./csps/extrapol.pol')   
end




delete(handles.csps)


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%read from handles


strike1=handles.strike;
dip1=handles.dip;
rake1=handles.rake;
nsolutions=handles.nsolutions;


%% run
%  first copy files we need
if ispc 
   [status,message,~]=copyfile('.\invert\elemse*.dat','.\csps');
   if status==1
       disp('Elemse files copied in csps folder succesfully.')
   else
       errordlg(['Problems with elemse file coping in csps folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./invert/elemse*.dat','./csps');
   if status==1
       disp('Elemse files copied in csps folder succesfully.')
   else
       errordlg(['Problems with elemse file coping in csps folder. Message is ' message])
   end
end


    
%% Copy raw files
if ispc 
   [status,message,~]=copyfile('.\invert\*raw.dat','.\csps');
   if status==1
       disp('Data files copied in csps folder succesfully.')
   else
       errordlg(['Problems with data file coping in csps folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./invert/*raw.dat','./csps');
   if status==1
       disp('Data files copied in csps folder succesfully.')
   else
       errordlg(['Problems with data file coping in csps folder. Message is ' message])
   end
end

    
    %% Create the mechan_A01.dat etc

cd csps

% del old  mechan_A*.dat
%     inv2_A*.dat

delete('mechan_A*.dat');
delete('inv2_A*.dat');
delete('done');

      for i=1:nsolutions
             %%% find filename
             filename=['mechan_A' num2str(i,'%02d') '.dat'];
             %%%% open file
             fid = fopen(filename,'w');
             fprintf(fid,'%s\r\n',' Source size and mechanism');
             fprintf(fid,'%s\r\n',' scalar moment (in Nm):');
             fprintf(fid,'%s\r\n',' 1.0');
             
             fprintf(fid,'%s\r\n',' strike, dip, rake');
             fprintf(fid,'% 5.f  % 5.f % 5.f\r\n',strike1(i),dip1(i),rake1(i));
             
             fprintf(fid,'%s\r\n',' delay');
             fprintf(fid,'%s\r\n',' 0.0');
             
             fclose(fid);
      end

%% write to batch file
          if ispc
              
              fid = fopen('run_isola_loop.bat','w');

                  %  fprintf(fid,'%s\r\n','del mechan_A*.dat');
                  %  fprintf(fid,'%s\r\n','del inv2_A*.dat');
                  %  fprintf(fid,'%s\r\n','    ');
                  %  fprintf(fid,'%s\r\n','    ');
              
              for i=1:nsolutions  
                    fprintf(fid,'%s\r\n',['copy mechan_A' num2str(i,'%02d') '.dat mechan.dat']);
                    fprintf(fid,'%s\r\n','isola.exe');
                    fprintf(fid,'%s\r\n',['copy inv2.dat inv2_A' num2str(i,'%02d') '.dat']);
                    fprintf(fid,'%s\r\n','   ');
              end
                    fprintf(fid,'%s\r\n','done.exe');              
              
%                    fprintf(fid,'%s\r\n','copy inv2_*.dat inv2old.dat');
%                    fprintf(fid,'%s\r\n','selectbest95.exe');
%                    fprintf(fid,'%s\r\n','firstline.exe');
%                    fprintf(fid,'%s\r\n','copy inv2.dat moremech.dat ');
%                    fprintf(fid,'%s\r\n','magnitude.exe');
                   
              fclose(fid);
        % run
        
          system('run_isola_loop.bat  &')

          else
              % linux
                disp('Linux ')
       
             fid = fopen('run_isola_loop.sh','w');

              fprintf(fid,'%s\n','#!/bin/bash');
              fprintf(fid,'%s\n','             ');
              
                 for i=1:nsolutions 
                    fprintf(fid,'%s\n',['copy mechan_A' num2str(i,'%02d') '.dat mechan.dat']);
                    fprintf(fid,'%s\n','isola.exe');
                    fprintf(fid,'%s\n',['cp inv2.dat inv2_A' num2str(i,'%02d') '.dat']);
                    fprintf(fid,'%s\n','   ');
                 end
                    fprintf(fid,'%s\n',' done.exe   ');

              fclose(fid);
              
               pwd
    
              !chmod +x run_isola_loop.sh
              system(' gnome-terminal -e "bash -c ./run_isola_loop.sh;bash" ')
              
              
          end

%%
                 hpr = helpdlg('Please wait code is running...','Info');
                    
                    done = 0;

                    while done == 0
                          done=exist('done','file');
                    end
                    
                 close(hpr)
                    
                    disp('         ')
                    disp('code finished')
                    disp('         ')
                    
                    helpdlg('CSPS code finished','Info');
                    
                    delete('done');
                        
                    
%% add all inv2_* in one
nsolutions=handles.nsolutions;

if ispc
    
  fid = fopen('inv2old.dat','w');
     for i=1:nsolutions
             %%% find filename
             filename=['inv2_A' num2str(i,'%02d') '.dat'];
             %%%% open file
             fid2 = fopen(filename,'r');
                tline = fgets(fid2);
             fclose(fid2);
             fprintf(fid, '%s', tline);
      end
  fclose(fid);
else
   fid = fopen('inv2old.dat','w');
     for i=1:nsolutions
             %%% find filename
             filename=['inv2_A' num2str(i,'%02d') '.dat'];
             %%%% open file
             fid2 = fopen(filename,'r');
                tline = fgets(fid2);
             fclose(fid2);
             fprintf(fid, '%s', tline);
      end
  fclose(fid);   
end                    
                    
% clean files

delete('sing.dat','vect.dat','corr01.dat','mechan.dat','inv1.dat','inv2.dat','inv3.dat','inv2c.dat','inv2_A*.dat','mechan_A*.dat')



% leave folder          
          
cd ..


% --- Executes on button press in editallstat.
function editallstat_Callback(hObject, eventdata, handles)
% hObject    handle to editallstat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



staguicsps


% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% bring station.dat

if ispc 
   [status,message,~]=copyfile('.\green\station.dat','.\csps');
   if status==1
       disp('station file copied in csps folder succesfully.')
   else
       errordlg(['Problems with station file coping in csps folder. Message is ' message])
   end
else
   [status,message,~]=copyfile('./green/station.dat','./csps');
   if status==1
       disp('station file copied in csps folder succesfully.')
   else
       errordlg(['Problems with station file coping in csps folder. Message is ' message])
   end
end
         
%%  PLOT polarities and nodal lines (based on plpol)
% h=dir('event.isl');
% 
% if isempty(h); 
%   errordlg('Event.isl file doesn''t exist. Run Event info. ','File Error');
%   return
% else
%     fid = fopen('event.isl','r');
%     eventcor=fscanf(fid,'%g',2);
% % %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
%     epidepth=fscanf(fid,'%g',1);
%     magn=fscanf(fid,'%g',1);
%     eventdate=fscanf(fid,'%s',1);
%     fclose(fid);
% end

% epidepth=handles.epidepth;

%% check if we need a different depth
% if (get(handles.dcheck,'Value') == get(handles.dcheck,'Max'))
% 	display('Change depth ');
%     
   epidepth=str2double(get(handles.newdepth,'String'));
%     
% else
% 	display('no depth change');
% end

%%
magn=handles.magn;
eventdate=handles.eventdate;
eventcor=handles.eventcor;

%%
if ispc
  fid = fopen('.\csps\source.dat','w');
    fprintf(fid,'%s\r\n',' Source parameters');
    fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
    fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\r\n',0,0, epidepth,magn, '''', eventdate, '''');
  fclose(fid);

else
  fid = fopen('./csps/source.dat','w');
    fprintf(fid,'%s\n',' Source parameters');
    fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
    fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %c%s%c\n',0,0, epidepth,magn, '''', eventdate, '''');
  fclose(fid);
end


%%

cd csps


%% check if extrapol.pol exists...
h=dir('extrapol.pol');
if isempty(h); 
  disp('Extrapol.pol file doesn''t exist. ');
  disp('  ');
  disp('Using polarities from station.dat only.');
  disp('  ');
      noextrastations=0;
else
  disp('Found extrapol.pol file. Extra station polarities will be used');
   fid  = fopen('extrapol.pol','r');
    [stanamextra,stalatextra,stalonextra,stapolextra] = textread('extrapol.pol','%s %f %f %s',-1);
   fclose(fid);

  %fix origin on the epicenter
  orlat=eventcor(2);
  orlon=eventcor(1);

  %%%%%%%%%%%%  USE GRS80 ELLIPSOID
  grs80.geoid = almanac('earth','geoid','km','grs80');
  %%%%%%%%%%%%%%%%CALCULATE AZIMUTH AND EPICENTRAL DISTANCE FOR EVERY STATION

  for i=1:length(stalatextra)
    staazimextra(i)=azimuth(eventcor(2),eventcor(1),stalatextra(i),stalonextra(i),grs80.geoid);
    epidistextra(i)=distdim(distance(eventcor(2),eventcor(1),stalatextra(i),stalonextra(i),grs80.geoid),'km','km');
  end

  %%%% FIX SOURCE AT ORIGIN
  sourceXdist=0;
  sourceYdist=0;

  for i=1:length(stalatextra)
    [stationXdistextra(i),stationYdistextra(i)] = pol2cart(deg2rad(staazimextra(i)),epidistextra(i));
  end
 %%%%%%%%OUTPUT%%%%%%%%%%%%%%%%%%%%
  for i=1:length(stalatextra)
    outex(i,1)=stationXdistextra(i);     %%%%%% 
    outex(i,2)=stationYdistextra(i);
    outex(i,3)=0;
    outex(i,4)=staazimextra(i);
    outex(i,5)=epidistextra(i);
  end    
% output
  fid = fopen('station.dat','a');
  for i=1:length(stalatextra)
      if ispc
             fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\r\n',outex(i,1),outex(i,2),outex(i,3),outex(i,4),outex(i,5),stanamextra{i,1}',stapolextra{i,1}');
      else
             fprintf(fid,'%11.4f%11.4f%11.4f%11.4f%11.4f %s %s\n',outex(i,1),outex(i,2),outex(i,3),outex(i,4),outex(i,5),stanamextra{i,1}',stapolextra{i,1}');
      end
  end
  fclose(fid);

  
        noextrastations=length(stalatextra);

  
%   %%%% rename extrapol.pol  not to use every time we run polarity plot...
%     [s,mess,messid]=movefile('extrapol.pol','extrapol.done');
%
end

%% run angone    !!!!!!!!!!!  check if source is on some interface..???

%%%read crustal model...
fid  = fopen('crustal.dat','r');
       line1=fgets(fid);         %01 line
       title=line1(28:length(line1)-2);
       line2=fgets(fid);         %02 line
       line3=fgets(fid);         %03 line
       nlayers=sscanf(line3,'%i');
       disp(['Model has ' num2str(nlayers) ' layers'])
       if nlayers > 15
            errordlg('Model has more than 15 layers','Error');
       else
       end
        %%%%%
       line4=fgets(fid);         %04 line
       line5=fgets(fid);         %05 line

    c=fscanf(fid,'%g %g %g %g %g %g',[6 nlayers]);       
    c = c';
fclose(fid);
model_depths=c(:,1);
%%%%read source.dat
fid  = fopen('source.dat','r');
[lon,lat,depth,mag,tt] = textread('source.dat','%f %f %f %f %s','headerlines',2);
fclose(fid);
%%%%%%%% we have read both files check if depth = interface...

for i=1:length(model_depths)
    if depth == model_depths(i)
        disp(['Source depth  ' num2str(depth) ' equals CRUSTAL.DAT interface no ' num2str(i) ' ANGONE.EXE doesn''t like this. Adding 0.2 to depth'])
        warndlg(sprintf(['Source depth  ' num2str(depth) ' equals CRUSTAL.DAT interface no ' num2str(i) ' \n ANGONE.EXE doesn''t like this. Adding 0.2 to depth']))
        
        depth=depth+0.2;
        
        %%%%prepare new source.dat ...
                 fid = fopen('source.dat','w');
                   if ispc
                      fprintf(fid,'%s\r\n',' Source parameters');
                      fprintf(fid,'%s\r\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
                      fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %s\r\n',lon,lat,depth,mag, tt{1});
                   else
                      fprintf(fid,'%s\n',' Source parameters');
                      fprintf(fid,'%s\n',' x(N>0,km),y(E>0,km),z(km),magnitude,date');
                      fprintf(fid,'%10.4f%10.4f%10.4f%10.4f  %s\n',lon,lat,depth,mag, tt{1});
                   end
                 fclose(fid);

    else
        disp(['CRUSTAL.DAT Interface no ' num2str(i) ' ok for source.dat depth '  num2str(depth)  ])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%  check if source is under Moho...!!we need to add
%%%%%%%%%%%%%%%%%%%%%%%%  another layer then .........

disp(['Found moho at ' num2str(model_depths(nlayers)) '  km'])
disp(['Source depth is ' num2str(depth) '  km'])

if depth >= model_depths(nlayers)

    disp('Source depth is deeper than moho. Adding one layer in crustal.dat.')
    
    newlastdepth=depth+5;
    
    c(nlayers+1,1)=newlastdepth;
    c(nlayers+1,2)=c(nlayers,2);
    c(nlayers+1,3)=c(nlayers,3);
    c(nlayers+1,4)=c(nlayers,4);
    c(nlayers+1,5)=c(nlayers,5);
    c(nlayers+1,6)=c(nlayers,6);
   
    %%now we need to add this to crustal.dat for polarity plot...

      delete('crustal.dat')    


    fid = fopen('crustal.dat','w');
    fprintf(fid,'%s',line1);
    fprintf(fid,'%s',line2);
    if ispc
      fprintf(fid,'   %i\r\n',nlayers+1);
    else
      fprintf(fid,'   %i\n',nlayers+1);
    end
    fprintf(fid,'%s',line4);
    fprintf(fid,'%s',line5);
    
    for i=1:nlayers+1
        if ispc
          fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\r\n',c(i,1),c(i,2),c(i,3),c(i,4),c(i,5),c(i,6) );
        else
          fprintf(fid,'%9.1f%21.2f%12.3f%13.3f%12i%7i\n',c(i,1),c(i,2),c(i,3),c(i,4),c(i,5),c(i,6) );
        end
    end
     if ispc
        fprintf(fid,'%s\r\n','*************************************************************************');
     else
        fprintf(fid,'%s\n','*************************************************************************');
     end
    fclose(fid);
    
    
else
end

%%  RUN ANGONE  %%%%%%%%%%%%%%
[status, result] = system('angone.exe');
if status ~= 0
   errordlg(['Error running angone.exe'  result],'Error');
   return
else
   disp('running angone.exe')    
end

%% find how many stations we have check the station.dat

    fid = fopen('station.dat','r');
          C=textscan(fid,'%f %f %f %f %f %s %s ','HeaderLines', 2);
    fclose(fid);
    
    nostations=length(C{1});

%%  pause here if user wants to change mypol...

uiwait(helpdlg('Edit .\csps\mypol.dat (IF you want) and press OK'));

    
%
%% new code that checks length of line

   fid = fopen('mypol.dat','r');
          tline = fgets(fid);
          tline = fgets(fid);
          i=1;
       while ischar(tline)
          
           if length(tline) < 55 
              A=textscan(tline,'%s %f %f %s %f %f ');
              staname(i)=A{1,1};
             d1(i)=A{1,2};
             d2(i)=A{1,3};
             pol(i)=A{1,4};
             d4(i)=A{1,5};
             d5(i)=A{1,6};
             d6(i)=0;
           
           else
              A=textscan(tline,'%s %f %f %s %f %f %f');
             staname(i)=A{1,1};
             d1(i)=A{1,2};
             d2(i)=A{1,3};
             pol(i)=A{1,4};
             d4(i)=A{1,5};
             d5(i)=A{1,6};
             d6(i)=A{1,7};
           end
           
              tline = fgets(fid);
              i=i+1;
       end

  fclose(fid);

  
cd ..  % go up !!  
  

%%       now read      inv2new and plot it

         if ispc
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('.\csps\inv2new.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',-1);
         else
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('./csps/inv2new.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',-1);
         end

         
xmommag=(2.0/3.0)*log10(mo) - 6.0333; 	 % Hanks-Kanamori         
         
%% PLOT

%% do we need to plot more than one nodal pair..??

if length(str1) > 1  % more than one
    h2=figure;
    
    %define best mech
    [VRopt,I]=max(varred);
    mech=[str1(I,1) dip1(I,1) rake1(I,1)];
    bb([str1(I,1) dip1(I,1) rake1(I,1)],10,10,5,0,[138/255 138/255 138/255])
    hold on
    axis square;
    axis off

    % plot the other nodal pairs
    for i=1:length(str1)
    % bb([str1(i,1) dip1(i,1) rake1(i,1)],10,10,5,0,[138/255 138/255 138/255])   
    [x,y]=plpl2(str1(i,1),dip1(i,1));
    plot(x,y,'k')
    [x1,y1]=plpl2(str2(i,1),dip2(i,1));
    plot(x1,y1,'k')
    end
    
% plot polarities
% plot with green polarities from station.dat
%%
  if noextrastations==0

   for i=1:length(staname)   % we have station.dat only
    [x3(i),y3(i)]=pltsym2(d2(i),d1(i));
    tt(i)=staname(i);
    text(x3(i)+0.1,y3(i)+0.1,tt(i),'FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom',...
                            'Color',[0,1,0]);
    text(x3(i),y3(i),pol(i),'FontSize',14,...
                            'FontWeight','bold',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle',...
                            'Color',[0,1,0]);
   end
    
  else  % we have extrapol
    
   for i=1:length(staname)-noextrastations
    [x3(i),y3(i)]=pltsym2(d2(i),d1(i));
    tt(i)=staname(i);
    text(x3(i)+0.1,y3(i)+0.1,tt(i),'FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom',...
                            'Color',[0,1,0]);
    text(x3(i),y3(i),pol(i),'FontSize',14,...
                            'FontWeight','bold',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle',...
                            'Color',[0,1,0]);
   end
% plot the remaining 
   for i=(length(staname)-noextrastations)+1:length(staname)
    [x3(i),y3(i)]=pltsym2(d2(i),d1(i));
    tt(i)=staname(i);
    text(x3(i)+0.1,y3(i)+0.1,tt(i),'FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom',...
                            'Color',[1,0,0]);
    text(x3(i),y3(i),pol(i),'FontSize',14,...
                            'FontWeight','bold',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle',...
                            'Color',[1,0,0]);
   end
  end  % end of noextrastations==0

%%  
else  % we have only one selected nodal pair
    
   h2=figure;
   % define best mech
   [VRopt,I]=max(varred);
    mech=[str1(I,1) dip1(I,1) rake1(I,1)];

     bb([str1(I,1) dip1(I,1) rake1(I,1)],10,10,5,0,[138/255 138/255 138/255])
     hold on
     axis square;
    axis off

%% plot polarities
  if noextrastations==0

   for i=1:length(staname)   % we have station.dat only
    [x3(i),y3(i)]=pltsym2(d2(i),d1(i));
    tt(i)=staname(i);
    text(x3(i)+0.1,y3(i)+0.1,tt(i),'FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom',...
                            'Color',[0,1,0]);
    text(x3(i),y3(i),pol(i),'FontSize',14,...
                            'FontWeight','bold',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle',...
                            'Color',[0,1,0]);
   end
    
  else  % we have extrapol
    
   for i=1:length(staname)-noextrastations
    [x3(i),y3(i)]=pltsym2(d2(i),d1(i));
    tt(i)=staname(i);
    text(x3(i)+0.1,y3(i)+0.1,tt(i),'FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom',...
                            'Color',[0,1,0]);
    text(x3(i),y3(i),pol(i),'FontSize',14,...
                            'FontWeight','bold',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle',...
                            'Color',[0,1,0]);
   end
% plot the remaining 
   for i=(length(staname)-noextrastations)+1:length(staname)
    [x3(i),y3(i)]=pltsym2(d2(i),d1(i));
    tt(i)=staname(i);
    text(x3(i)+0.1,y3(i)+0.1,tt(i),'FontSize',14,...
                            'HorizontalAlignment','left',...
                            'VerticalAlignment','bottom',...
                            'Color',[1,0,0]);
    text(x3(i),y3(i),pol(i),'FontSize',14,...
                            'FontWeight','bold',...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','middle',...
                            'Color',[1,0,0]);
   end
  end  % end of noextrastations==0

   
%%
end    % end of if for number of nodal lines


%%
plot(10,10,'+','MarkerSize',8)
text (10,15.2,'0','FontSize',12);          
text (9.6,4.5,'180','FontSize',12);  
text (15.2,10,'90','FontSize',12);          
text (4. ,10,'270','FontSize',12);      


%% read from handles

thres=str2num(get(handles.thres,'String'));
ind=length(srcpos2);
VRlimit=VRopt*thres;      

%%

s=load('.\csps\inv2old.dat');
  
%  convert position to distance..!!
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
%         distep=fscanf(fid,'%f',1);
           noSourcesstrike=fscanf(fid,'%i',1);
           strikestep=fscanf(fid,'%f',1);
           noSourcesdip=fscanf(fid,'%i',1);
           dipstep=fscanf(fid,'%f',1);
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
pos1=s(:,1);mo=s(:,3);vr=s(:,end);
% convert to distance 
pos=((pos1-1)*distep)+sdepth;
%% find depth range for selected values
sel_srcdep=((srcpos2-1)*distep)+sdepth;

%%
text (2. ,4,['Source depth (assumed for this plot)  ' num2str(epidepth) ' km' ],'FontSize',12); 

text (2. ,15.2,['Solutions above threshold   ' num2str(ind) ],'FontSize',12); 
text (2. ,14.6,['Minimum allowed VR   ' num2str(VRlimit, '%7.2f') ],'FontSize',12); 
text (2. ,14.0,['Optimum VR   ' num2str(VRopt, '%7.2f') ],'FontSize',12); 

text (15. ,15.2,'Optimum mechanism ','FontSize',12); 
text (15. ,14.6,['NP1 = ' num2str(str1(I,1)) ','  num2str(dip1(I,1)) ','  num2str(rake1(I,1))],'FontSize',12); 
text (15. ,14.0,['NP2 = ' num2str(str2(I,1)) ','  num2str(dip2(I,1)) ','  num2str(rake2(I,1))],'FontSize',12); 

text (15. ,13.4,'Moment-Magnitude range ','FontSize',12); 
text (15. ,12.8,[num2str(min(xmommag),'%3.1f') '-' num2str(max(xmommag),'%3.1f') ],'FontSize',12); 

text (15. ,12.4,'Depth range ','FontSize',12); 
text (15. ,11.8,[num2str(min(sel_srcdep),'%3.1f') '-' num2str(max(sel_srcdep),'%3.1f') ],'FontSize',12); 

% update handles with best STR DIP RAKE
handles.best_str=str1(I,1);
handles.best_dip=dip1(I,1);
handles.best_rake=rake1(I,1);
% Update handles structure
guidata(hObject, handles);
%% prepare a GMT file also..!!
% write reference solution
if ispc
  fid = fopen('.\csps\ref_mech.gmt','w');
    fprintf(fid,'%f %f %f %f %f %f %f\r\n',5 , 5, 5, str1(I,1),dip1(I,1),rake1(I,1),5);
  fclose(fid);
else
  fid = fopen('./csps/ref_mech.gmt','w');
    fprintf(fid,'%f %f %f %f %f %f %f\n',5 , 5, 5, str1(I,1),dip1(I,1),rake1(I,1),5);
  fclose(fid);
end

% write a file with results for GMT pstext
if ispc
  fid = fopen('.\csps\ref_mech_text.gmt','w');
    fprintf(fid,'%s\r\n','> 13 10 16 0 1 CM 13p 4i l ');
    fprintf(fid,'%s\r\n',['Solutions above VR threshold :  @;255/0/0;'   num2str(ind)  '@;;'  ]);  
    fprintf(fid,'%s\r\n','> 13 9.5 16 0 1 CM 13p 4i l ');
    fprintf(fid,'%s\r\n',['Minimum allowed VR : @;255/0/0;' num2str(VRlimit, '%7.2f')  '@;;']);
    fprintf(fid,'%s\r\n','> 13 9   16 0 1 CM 13p 4i l ');
    fprintf(fid,'%s\r\n',['Optimum VR : @;255/0/0;' num2str(VRopt, '%7.2f') '@;;' ]);
    fprintf(fid,'%s\r\n','> 13 8.5 16 0 1 CM 13p 4i l ');
    fprintf(fid,'%s\r\n','Optimum mechanism  S/D/R');
    fprintf(fid,'%s\r\n','> 13 8   16 0 1 CM 13p 4i l ');
    fprintf(fid,'%s\r\n',['NP1 = ' '@;255/0/0;' num2str(str1(I,1)) '/'  num2str(dip1(I,1)) '/'  num2str(rake1(I,1))  '@;;'   '  NP2 = ' '@;255/0/0;' num2str(str2(I,1)) '/'  num2str(dip2(I,1)) '/'  num2str(rake2(I,1))  '@;;' ]);
    fprintf(fid,'%s\r\n','> 13 7.5 16 0 1 CM 13p 4i l ');
    fprintf(fid,'%s\r\n',['Moment-Magnitude range   '   '@;255/0/0;' num2str(min(xmommag),'%3.1f') '-' num2str(max(xmommag),'%3.1f') '@;;']);
    fprintf(fid,'%s\r\n','> 13 7.0 16 0 1 CM 13p 4i l ');
    fprintf(fid,'%s\r\n',['Depth range (km)  '   '@;255/0/0;' num2str(min(sel_srcdep),'%3.1f') '-' num2str(max(sel_srcdep),'%3.1f') '@;;']);
    
    fprintf(fid,'%s\r\n','> 5 10.  16 0 1 CM 13p 5i l ');
    fprintf(fid,'%s\r\n',['Source depth (assumed for this plot) '   '@;255/0/0;' num2str((epidepth),'%3.1f')  '@;;' ' km' ]);

%     fprintf(fid,'%s\r\n','> 13 7   16 0 1 CM 13p 4i l ');
%     fprintf(fid,'%s\r\n',['@;255/0/0;' num2str(min(xmommag),'%3.1f') '-' num2str(max(xmommag),'%3.1f') '@;;']);
 fclose(fid);
else
    
end

% write batch

if ispc
  fid = fopen('.\csps\plot_csps_gmt.bat','w');
    fprintf(fid,'%s\r\n', 'psmeca ref_mech.gmt  -R0/10/0/10 -JX17c -Sa15c -K   -W2p -Glightgray > csps_gmt_plot.ps'  );
    fprintf(fid,'%s\r\n', 'gawk "{print 5,5,5,$4,$5,$6,5}" inv2new.dat | psmeca -R -J -Sa15c -T0 -K -O -a0.3c/cc -ewhite -t0.1p -gblack   -W1.p >> csps_gmt_plot.ps '  );
    fprintf(fid,'%s\r\n', 'gawk "{if (NR>1) print $1,$2,$3,$4}" mypol.dat > 4pspolar.txt');
    fprintf(fid,'%s\r\n', 'pspolar 4pspolar.txt -R -J -N -Ss0.7c  -D5/5  -M15c  -e0.5p  -O -K -T0/0/5/18  >> csps_gmt_plot.ps ');
    fprintf(fid,'%s\r\n', 'pstext ref_mech_text.gmt -R -J -O -K -m -N  >> csps_gmt_plot.ps '  );
    
    fprintf(fid,'%s\r\n', 'echo .5  2   | psxy -R -J -O  -K -Ss.6c -W0.5p >> csps_gmt_plot.ps '  );
    fprintf(fid,'%s\r\n', 'echo .5  1.5 | psxy -R -J -O  -K -Ss.6c  -Gblack  >> csps_gmt_plot.ps '  );
    fprintf(fid,'%s\r\n', 'echo .5  1.0 | psxy -R -J -O  -K -Sc.3c  -Gblack  >> csps_gmt_plot.ps '  );
    fprintf(fid,'%s\r\n', 'echo .5  0.5 | psxy -R -J -O  -K -Sc.3c    -W0.5p >> csps_gmt_plot.ps '  );
    
    fprintf(fid,'%s\r\n', 'echo 1.0 2.0 12 0 1 CM D, - | pstext -R -J -O  -K >> csps_gmt_plot.ps '  );
    fprintf(fid,'%s\r\n', 'echo 1.0 1.5 12 0 1 CM C, + | pstext -R -J -O  -K >> csps_gmt_plot.ps '  );
    fprintf(fid,'%s\r\n', 'echo 1.0 1.0 12 0 1 CM P    | pstext -R -J -O  -K >> csps_gmt_plot.ps '  );
    fprintf(fid,'%s\r\n', 'echo 1.0 0.5 12 0 1 CM T    | pstext -R -J -O  -K >> csps_gmt_plot.ps '  );
    
    fprintf(fid,'%s\r\n', 'echo 0.4 0.1 12 0 1 LM X - polarity not defined | pstext -R -J -O     >> csps_gmt_plot.ps '  );
    
    fclose(fid);
	
	disp('Check the  .\csps\plot_csps_gmt.bat file for GMT plotting')
 	
else
    
end


%% new plot use distance instead of source number
mw=(2.0/3.0)*log10(mo) - 6.0333;  % Hanks-Kanamori
figure
scatter(mw,pos,1300,vr,'filled','s',...
                       'LineWidth',.1,...
                       'MarkerEdgeColor','k')
%   C=[mw pos vr];
%   Csort=sort(C,3);                  
%   scatter(Csort(:,1),Csort(:,2),1300,Csort(:,3),'filled','s',...
%                       'LineWidth',.1,...
%                       'MarkerEdgeColor','k')
  set(gca,'ytick',min(pos)-1:max(pos)+1)
  set(gca,'ylim',[min(pos)-1,max(pos)+1])
% 
%   yl=get(gca,'YTickLabel');
%   yl(1)=' ';
%   yl(end)=' ';
%   set(gca,'YTickLabel',yl);
  hd=colorbar;
  %title(colorbar,'VR')
  set(get(hd,'title'),'String','VR');
  xlabel('Moment magnitude (Mw)')
  ylabel('Source position (km)')
  grid on
  fig=gcf;
  set(findall(fig,'-property','FontSize'),'FontSize',14)

%%



% --- Executes on button press in inpol.
function inpol_Callback(hObject, eventdata, handles)
% hObject    handle to inpol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [stationfile, newdir] = uigetfile({'*.dat;*.txt;*.pol'}, 'Select network/polarity file');
   
    if stationfile == 0
       disp('Cancel file load')
       return
   else
    end
    
  %  [newdir stationfile]

% %% load the file

fid = fopen([newdir stationfile]);
C = textscan(fid, '%s %f %f %s');
fclose(fid);

%% position figure
set(0,'Units','pixels') 
scnsize = get(0,'ScreenSize');
f=figure('Position',[10 scnsize(4)/3 scnsize(3)/4 scnsize(4)/2],...
         'MenuBar','none',...
         'ToolBar','none',...
         'Name','polarityinput');
     
outerpos = get(f,'OuterPosition');
bcolor = get(f,'Color');

pos2 = [scnsize(3)-(outerpos(3)+100),...
        scnsize(4)/3,...
        scnsize(3)/3,...
        scnsize(4)/(3/2)];

set(f,'OuterPosition',pos2) 
%%
% def='     ';
% vv=cellstr(repmat(def,length(C{1,2}),1));

polstr=strcat({'         '}, C{1,4});

rnames = C{1,1};
cnames = {'LAT','LON','Polarity'};
columnformat = {'numeric', 'numeric', 'char'};
columneditable =  [false false true ]; 

stn_table = uitable('Parent',f,'Units', 'normalized',...
            'Position', [0.025 0.03 0.9 0.9],...
            'Data',[num2cell(C{1,2}) num2cell(C{1,3}) polstr] ,...
            'ColumnName',cnames,...
            'RowName',rnames,...
            'ColumnEditable', columneditable,...
            'ColumnFormat', columnformat,...
            'FontSize',12,...
            'ColumnWidth',{'auto'});
       
%% set the table size position
pos = get(stn_table, 'Position');
ext = get(stn_table, 'Extent');        
set(stn_table, 'Position', [pos(1) 1-(ext(4)+0.02) ext(3:4)]);        


%% add the exit button

b  = uicontrol('Parent',f,'Style', 'pushbutton',...
               'String', 'Exit',...
               'FontSize',12,...
               'Units', 'normalized',...
               'Position', [0.75 0.1 0.2 0.1],...
               'Callback', 'prep_extrpol');     
           
           
description  = uicontrol('Parent',f,'Style', 'text',...
               'String', 'Use symbols e.g. u,d,+,-,U,D,? or leave blank if polarity is not available',...
               'FontSize',12,...
               'Units', 'normalized',...
               'Position', [0.72 0.5 0.2 0.4],...
               'BackgroundColor',bcolor);  
    



function thres_Callback(hObject, eventdata, handles)
% hObject    handle to thres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thres as text
%        str2double(get(hObject,'String')) returns contents of thres as a double


% --- Executes during object creation, after setting all properties.
function thres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runinv.
function runinv_Callback(hObject, eventdata, handles)
% hObject    handle to runinv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% get best solution from handles
strike=handles.best_str;
dip=handles.best_dip;
rake=handles.best_rake;


%% prepare/update mechan.dat in invert
if ispc
             %%%% open file
             fid = fopen('.\invert\mechan.dat','w');
             fprintf(fid,'%s\r\n',' Source size and mechanism');
             fprintf(fid,'%s\r\n',' scalar moment (in Nm):');
             fprintf(fid,'%s\r\n',' 1.0');
             
             fprintf(fid,'%s\r\n',' strike, dip, rake');
             fprintf(fid,'% 5.f  % 5.f % 5.f\r\n',strike,dip,rake);
             
             fprintf(fid,'%s\r\n',' delay');
             fprintf(fid,'%s\r\n',' 0.0');
             
             fclose(fid);

else
                %%%% open file
             fid = fopen('./invert/mechan.dat','w');
             fprintf(fid,'%s\n',' Source size and mechanism');
             fprintf(fid,'%s\n',' scalar moment (in Nm):');
             fprintf(fid,'%s\n',' 1.0');
             
             fprintf(fid,'%s\n',' strike, dip, rake');
             fprintf(fid,'% 5.f  % 5.f % 5.f\n',strike,dip,rake);
             
             fprintf(fid,'%s\n',' delay');
             fprintf(fid,'%s\n',' 0.0');
             
             fclose(fid); 
    
end

%%            inpinv
if ispc
  [status,message,messageId]=copyfile('.\csps\inpinv.dat','.\invert\')

  if status ==1
    disp('Copied inpinv.dat in invert')
  else
    disp('Error copying inpinv.dat in invert')
    message
    messageId
  end

else
  [status,message,messageId]=copyfile('./csps/inpinv.dat','./invert/')

  if status ==1
    disp('Copied inpinv.dat in invert')
  else
    disp('Error copying inpinv.dat in invert')
    message
    messageId
  end
  
end


%%            allstat
if ispc
  [status,message,messageId]=copyfile('.\csps\allstat.dat','.\invert\')

  if status ==1
    disp('Copied allstat.dat in invert')
  else
    disp('Error copying allstat.dat in invert')
    message
    messageId
  end

else
  [status,message,messageId]=copyfile('./csps/allstat.dat','./invert/')

  if status ==1
    disp('Copied allstat.dat in invert')
  else
    disp('Error copying allstat.dat in invert')
    message
    messageId
  end
  
end

%% copy extrapol.pol to .\polarity
%% check if extrapol.pol exists...
if ispc
    h=dir('.\csps\extrapol.pol');
else
    h=dir('./csps/extrapol.pol');
end

if isempty(h); 
    disp('Extrapol.pol file doesn''t exist. ');
else
    
    if ispc
         [status,message,messageId]=copyfile('.\csps\extrapol.pol','.\polarity\')   
    else
         [status,message,messageId]=copyfile('./csps/extrapol.pol','./polarity/')   
    end
end



%% call invert
invert

close csps



function enableoff(off)
set(off,'Enable','off')

function enableon(on)
set(on,'Enable','on')


% --- Executes on button press in select.
function select_Callback(hObject, eventdata, handles)
% hObject    handle to select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
%check if inv2old.dat exists..!
if ispc 
        fh2=exist('.\csps\inv2old.dat','file'); 
         if (fh2~=2);
                  errordlg('CSPS folder doesn''t contain inv2old.dat. Please run CSPS. ','File Error');
                  delete(handles.csps)
         end
else
        fh2=exist('./csps/inv2old.dat','file'); 
         if (fh2~=2);
                  errordlg('CSPS folder doesn''t contain inv2old.dat. Please run CSPS. ','File Error');
                  delete(handles.csps)
         end
end

%%

         if ispc
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('.\csps\inv2old.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',-1);
         else
          [srcpos2,srctime2,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred] = textread('./csps/inv2old.dat','%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',-1);
         end

%% select based on threshold
% read user specified threshold
thres=str2num(get(handles.thres,'String'));
% calculate best VR

VRopt=max(varred);	VRlimit=VRopt*thres;      
         
disp(['Best variance reduction ' num2str(VRopt)])
disp(['Based on ' num2str((thres*100))  '% threshold variance  ' num2str(VRlimit)])

ind=find(varred > VRlimit);

disp(['Solutions above threshold   ' num2str(length(ind))])

% what if we have 0 ..??
 if isempty(ind)
    
     warndlg('No solutions above threshold','!! Warning !!')
     return
     
 else
     
     
 end



         if ispc
            fid = fopen('.\csps\inv2new.dat','w');
                 for i=1:length(srcpos2)
                     if (varred(i) >= VRlimit)
                            fprintf(fid, '%5i %6.2f %12.6e %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.1f %12.4e\r\n', srcpos2(i),srctime2(i),mo(i),str1(i),dip1(i),rake1(i),str2(i),dip2(i),rake2(i),aziP(i),plungeP(i),aziT(i),plungeT(i),aziB(i),plungeB(i),dc(i),varred(i));
                     else
                     end
                     
                 end
            fclose(fid);     
         else
            fid = fopen('./csps/inv2new.dat','w');
                 for i=1:length(srcpos2)
                     if (varred(i) >= VRlimit)
                            fprintf(fid, '%5i %6.2f %12.6e %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.1f %12.4e\n', srcpos2(i),srctime2(i),mo(i),str1(i),dip1(i),rake1(i),str2(i),dip2(i),rake2(i),aziP(i),plungeP(i),aziT(i),plungeT(i),aziB(i),plungeB(i),dc(i),varred(i));
                     else
                     end
                     
                 end
            fclose(fid);     
         end

%% sort    inv2new.dat based on VR
if ispc
         fid=fopen('.\csps\inv2new.dat');
else
         fid=fopen('./csps/inv2new.dat');
end
           C = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
         fclose(fid);

         SC=sortrows(cell2mat(C),-17);

if ispc
         fid=fopen('.\csps\inv2new_sorted.dat','w');
else
         fid=fopen('./csps/inv2new_sorted.dat','w');
end         
         
         for i=1:length(SC(:,1))
                     
          fprintf(fid, '%5i %6.2f %12.6e %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.1f %12.4e\r\n', SC(i,1),SC(i,2),SC(i,3),SC(i,4),SC(i,5),SC(i,6),SC(i,7),SC(i,8),SC(i,9),SC(i,10),SC(i,11),SC(i,12),SC(i,13),SC(i,14),SC(i,15),SC(i,16),SC(i,17));
                     
         end
            fclose(fid);     

%% Calculate Mw

xmommag=(2.0/3.0)*log10(SC(:,3)) - 6.0333;  % Hanks-Kanamori


          if ispc
            fid = fopen('.\csps\inv2new_Mw.dat','w');
                 for i=1:length(SC(:,1))
                     fprintf(fid, '%5i %6.2f %12.6e %3.1f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.1f %12.4e\r\n', SC(i,1),SC(i,2),SC(i,3),xmommag(i),SC(i,4),SC(i,5),SC(i,6),SC(i,7),SC(i,8),SC(i,9),SC(i,10),SC(i,11),SC(i,12),SC(i,13),SC(i,14),SC(i,15),SC(i,16),SC(i,17));
                    % fprintf(fid, '%5i %6.2f %12.6e %3.1f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.1f %12.4e\r\n', srcpos2(i),srctime2(i),mo(i),xmommag(i),str1(i),dip1(i),rake1(i),str2(i),dip2(i),rake2(i),aziP(i),plungeP(i),aziT(i),plungeT(i),aziB(i),plungeB(i),dc(i),varred(i));
                 end
            fclose(fid);     
         else
            fid = fopen('./csps/inv2new_Mw.dat','w');
                 for i=1:length(SC(:,1))
                    fprintf(fid, '%5i %6.2f %12.6e %3.1f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.0f %6.1f %12.4e\r\n', SC(i,1),SC(i,2),SC(i,3),xmommag(i),SC(i,4),SC(i,5),SC(i,6),SC(i,7),SC(i,8),SC(i,9),SC(i,10),SC(i,11),SC(i,12),SC(i,13),SC(i,14),SC(i,15),SC(i,16),SC(i,17));
                 end
            fclose(fid);     
          end


%% save to handles
handles.noofsol=ind;
handles.VRopt=VRopt;
handles.VRlimit=VRlimit;

%VRopt=max(varred);	VRlimit=VRopt*thres;   

%% message

h = msgbox('Now you can proceed with Plotting');


% Update handles structure
guidata(hObject, handles);
         
          
          


% --- Executes on button press in dcheck.
function dcheck_Callback(hObject, eventdata, handles)
% hObject    handle to dcheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dcheck



function newdepth_Callback(hObject, eventdata, handles)
% hObject    handle to newdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newdepth as text
%        str2double(get(hObject,'String')) returns contents of newdepth as a double


% --- Executes during object creation, after setting all properties.
function newdepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
