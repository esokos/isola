function varargout = addmech(varargin)
% ADDMECH M-file for addmech.fig
%      ADDMECH, by itself, creates a new ADDMECH or raises the existing
%      singleton*.
%
%      H = ADDMECH returns the handle to a new ADDMECH or the handle to
%      the existing singleton*.
%
%      ADDMECH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDMECH.M with the given input arguments.
%
%      ADDMECH('Property','Value',...) creates a new ADDMECH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addmech_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addmech_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addmech

% Last Modified by GUIDE v2.5 28-Dec-2008 10:50:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addmech_OpeningFcn, ...
                   'gui_OutputFcn',  @addmech_OutputFcn, ...
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


% --- Executes just before addmech is made visible.
function addmech_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addmech (see VARARGIN)

% Choose default command line output for addmech
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes addmech wait for user response (see UIRESUME)
% uiwait(handles.addmechgui);


% --- Outputs from this function are returned to the command line.
function varargout = addmech_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is addmech  27/12/08');

% --- Executes on button press in addmech.
function addmech_Callback(hObject, eventdata, handles)
% hObject    handle to addmech (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if POLARITY exists..!
h=dir('polarity');

if length(h) == 0;
    errordlg('Polarity folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%read data...

strike1 = str2double(get(handles.strike1,'String'));
dip1 = str2double(get(handles.dip1,'String'));
rake1 = str2double(get(handles.rake1,'String'));

%%% call pl2pl to find second plane

[strike2,dip2,rake2] = pl2pl(strike1,dip1,rake1);

%%%% call pl2pt to fing trend plunge of P,T axis
[trendp,plungp,trendt,plungt,trendb,plungb]=pl2pt(strike1,dip1,rake1);


%%%% second plane
set(handles.strike2,'String',num2str(round(strike2)));        
set(handles.dip2,'String',num2str(round(dip2)));        
set(handles.rake2,'String',num2str(round(rake2)));        
%%%  P,T 
set(handles.ptrend,'String',num2str(round(trendp)));        
set(handles.pplunge,'String',num2str(round(plungp)));        
%%%
set(handles.ttrend,'String',num2str(round(trendt)));        
set(handles.tplunge,'String',num2str(round(plungt)));        


%%%%%open moremech
try
    
cd polarity

a=exist('moremech.dat','file');

if a==2   %% moremech exists
     fid=fopen('moremech.dat','r');
         tline = fgets(fid);
     fclose(fid);
     
     fid=fopen('moremech.dat','a+');
     
fprintf(fid,'%s%5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %s',tline(1:27), strike1,'.', dip1,'.',rake1,'.', strike2,'.',dip2,'.',rake2,'.',trendp,'.',plungp,'.',trendt,'.',plungt,'.',tline(98:length(tline)));     
         
         
    fclose(fid);
    
else

    disp('moremech.dat is missing')
    
end

cd ..

catch
    h=msgbox('Error in moremech.dat editing.','Error');
    cd ..
    return
end


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.addmechgui)

% --- Executes during object creation, after setting all properties.
function strike1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to strike1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function strike1_Callback(hObject, eventdata, handles)
% hObject    handle to strike1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of strike1 as text
%        str2double(get(hObject,'String')) returns contents of strike1 as a double


% --- Executes during object creation, after setting all properties.
function dip1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dip1_Callback(hObject, eventdata, handles)
% hObject    handle to dip1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip1 as text
%        str2double(get(hObject,'String')) returns contents of dip1 as a double


% --- Executes during object creation, after setting all properties.
function rake1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rake1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rake1_Callback(hObject, eventdata, handles)
% hObject    handle to rake1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rake1 as text
%        str2double(get(hObject,'String')) returns contents of rake1 as a double


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


      
      


% --- Executes on button press in overwrite.
function overwrite_Callback(hObject, eventdata, handles)
% hObject    handle to overwrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if POLARITY exists..!
h=dir('polarity');

if length(h) == 0;
    errordlg('Polarity folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%read data...

strike1 = str2double(get(handles.strike1,'String'));
dip1 = str2double(get(handles.dip1,'String'));
rake1 = str2double(get(handles.rake1,'String'));

%%% call pl2pl to find second plane

[strike2,dip2,rake2] = pl2pl(strike1,dip1,rake1);

%%%% call pl2pt to fing trend plunge of P,T axis
[trendp,plungp,trendt,plungt,trendb,plungb]=pl2pt(strike1,dip1,rake1);


%%%% second plane
set(handles.strike2,'String',num2str(round(strike2)));        
set(handles.dip2,'String',num2str(round(dip2)));        
set(handles.rake2,'String',num2str(round(rake2)));        
%%%  P,T 
set(handles.ptrend,'String',num2str(round(trendp)));        
set(handles.pplunge,'String',num2str(round(plungp)));        
%%%
set(handles.ttrend,'String',num2str(round(trendt)));        
set(handles.tplunge,'String',num2str(round(plungt)));        


%%%%%open moremech
try
    
cd polarity

a=exist('moremech.dat','file');

if a==2   %% moremech exists
     fid=fopen('moremech.dat','r');
         tline = fgets(fid);
     fclose(fid);
     
     fid=fopen('moremech.dat','w');
       fprintf(fid,'%s%5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %s',tline(1:27), strike1,'.', dip1,'.',rake1,'.', strike2,'.',dip2,'.',rake2,'.',trendp,'.',plungp,'.',trendt,'.',plungt,'.',tline(98:length(tline)));     
     fclose(fid);

    
     fid=fopen('onemech.dat','w');
       fprintf(fid,'%s%5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %5.0f%s %s',tline(1:27), strike1,'.', dip1,'.',rake1,'.', strike2,'.',dip2,'.',rake2,'.',trendp,'.',plungp,'.',trendt,'.',plungt,'.',tline(98:length(tline)));     
     fclose(fid);
    
    
else

    disp('moremech.dat is missing')
    
end

cd ..

catch
    h=msgbox('Error in moremech.dat editing.','Error');
    cd ..
    return
end



