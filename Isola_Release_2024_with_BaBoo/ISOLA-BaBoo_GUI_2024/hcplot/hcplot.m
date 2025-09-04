function varargout = hcplot(varargin)
% HCPLOT M-file for hcplot.fig
%      HCPLOT, by itself, creates a new HCPLOT or raises the existing
%      singleton*.
%
%      H = HCPLOT returns the handle to a new HCPLOT or the handle to
%      the existing singleton*.
%
%      HCPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HCPLOT.M with the given input arguments.
%
%      HCPLOT('Property','Value',...) creates a new HCPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hcplot_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hcplot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hcplot

% Last Modified by GUIDE v2.5 22-Apr-2018 22:43:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hcplot_OpeningFcn, ...
                   'gui_OutputFcn',  @hcplot_OutputFcn, ...
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


% --- Executes just before hcplot is made visible.
function hcplot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hcplot (see VARARGIN)

% Choose default command line output for hcplot
handles.output = hObject;

h=dir('hcplot.ini');

if length(h) == 0; 
        epititle='Type your title here';
        epilat='38.5';
        epilon='23.5';
        epidepth='12';

        centlat='38';
        centlon='23';
        centdepth='10';

        str1='201';
        dip1='83';
        str2='306';
        dip2='26';
        
        %%% first time put defaults...!!
        fid = fopen('hcplot.ini','w');
         fprintf(fid,'%s\r\n',epititle);
         fprintf(fid,'%s\r\n',epilat);
         fprintf(fid,'%s\r\n',epilon);
         fprintf(fid,'%s\r\n',epidepth);
         fprintf(fid,'%s\r\n',centlat);
         fprintf(fid,'%s\r\n',centlon);
         fprintf(fid,'%s\r\n',centdepth);
        
         fprintf(fid,'%s\r\n',str1);
         fprintf(fid,'%s\r\n',dip1);
         fprintf(fid,'%s\r\n',str2);
         fprintf(fid,'%s\r\n',dip2);
        fclose(fid);
else
    fid = fopen('hcplot.ini','r');
    epititle= fgetl(fid)
    epilat=fscanf(fid,'%g',1)
    epilon=fscanf(fid,'%g',1)
    epidepth=fscanf(fid,'%g',1)
    
    centlat=fscanf(fid,'%g',1)
    centlon=fscanf(fid,'%g',1)
    centdepth=fscanf(fid,'%g',1)
    
    str1=fscanf(fid,'%g',1)
    dip1=fscanf(fid,'%g',1)
    str2=fscanf(fid,'%g',1)
    dip2=fscanf(fid,'%g',1)
    
    fclose(fid);

end

set(handles.epititle,'String',epititle);        
set(handles.hlat,'String',num2str(epilat));        
set(handles.hlon,'String',num2str(epilon));         
set(handles.hdepth,'String',num2str(epidepth));  

set(handles.clat,'String',num2str(centlat));        
set(handles.clon,'String',num2str(centlon));         
set(handles.cdepth,'String',num2str(centdepth));    

set(handles.str1,'String',num2str(str1));        
set(handles.dip1,'String',num2str(dip1));         
set(handles.str2,'String',num2str(str2));    
set(handles.dip2,'String',num2str(dip2));    


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes hcplot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hcplot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

disp('This is hcplot 12/01/2020');
% new type of distance point from plane calculation
% fixed bug with plotting on more epicenters

% --- Executes on button press in plot.
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%initialize
morex=[];
morey=[];
morez=[];
%%%%%%EPICENTER
epititle = get(handles.epititle,'String');
epilat = str2num(get(handles.hlat,'String'));
epilon = str2num(get(handles.hlon,'String'));
epidepth = str2num(get(handles.hdepth,'String'));
%%%%%%centroid
centlat = str2num(get(handles.clat,'String'));
centlon = str2num(get(handles.clon,'String'));
centdepth = str2num(get(handles.cdepth,'String'));
%%%%%% plane 1
str1 = str2num(get(handles.str1,'String'));
dip1 = str2num(get(handles.dip1,'String'));
%%%%%% plane 2
str2 = str2num(get(handles.str2,'String'));
dip2 = str2num(get(handles.dip2,'String'));

%%% extra data..
moreepifile=get(handles.moreepifile,'String');
useextra = get(handles.extraepi,'Value');

%%%plot planes..?
pl1 = get(handles.pl1,'Value');
pl2 = get(handles.pl2,'Value');

%fix origin on the centroid
orlat=centlat; orlon=centlon;

disp('  ')
disp('Input')

disp(['Hypocenter   ' get(handles.hlat,'String') '   '   get(handles.hlon,'String') '   '  get(handles.hdepth,'String')] )
disp(['Centroid   ' get(handles.clat,'String') '   '   get(handles.clon,'String') '   '  get(handles.cdepth,'String')] )
disp([ 'Plane 1  ' get(handles.str1,'String')   '   '  get(handles.dip1,'String')  ])
disp([ 'Plane 2  ' get(handles.str2,'String')   '   '  get(handles.dip2,'String')  ])
disp('  ')

% centlat
% centlon
% epilat
% epilon

%% plot C and H
figure(3)
m_proj('Mercator','long',[centlon-1 centlon+1],'lat',[centlat-1 centlat+1]);
m_gshhs_i('patch',[.7 .7 .7]);
m_grid('box','fancy','tickdir','out');
m_ruler([0.1 0.4],0.08,2);
m_line(centlon,centlat,'marker','square','markersize',5,'color','r');
m_text(centlon,centlat,'C','vertical','top');

m_line(epilon,epilat,'marker','square','markersize',5,'color','r');
m_text(epilon,epilat,'E','vertical','top');

%%
%  USE wgs84 ELLIPSOID  % 12/01/2020
wgs84.geoid = almanac('earth','geoid','km','wgs84');
%%%%%%%%%%%%%%%%CALCULATE AZIMUTH AND EPICENTRAL DISTANCE  
azim=azimuth(centlat,centlon,epilat,epilon,wgs84.geoid);
dist=distdim(distance(centlat,centlon,epilat,epilon,wgs84.geoid),'km','km');

[epiXdist,epiYdist] = pol2cartgeo(deg2rad(azim),dist);

%%%%%%%%%%%%%%%%%
if useextra == 1;
    azimore=[]; distmore=[];
      fid=fopen(moreepifile);    
        C = textscan(fid,'%f %f %f %s');
      fclose(fid);
      morex=C{1};morey=C{2};morez=C{3};moreinfo=C{4};
      
   for i=1:length(morex)
      azimore(i) =azimuth(centlat,centlon,morex(i),morey(i),wgs84.geoid);
      distmore(i) =distdim(distance(centlat,centlon,morex(i),morey(i),wgs84.geoid),'km','km');
      [moreXdist(i),moreYdist(i)] = pol2cartgeo(deg2rad(azimore(i)),distmore(i));
   end
else
end


%%
% %%%% FIX SOURCE AT ORIGIN
% sourceXdist=0;
% sourceYdist=0;
% 
% strikerad1=deg2rad(str1);
% diprad1=deg2rad(dip1);
% 
% strikerad2=deg2rad(str2);
% diprad2=deg2rad(dip2);
% 
% sourceindex=0;
% 
% noSourcesdip = str2double(get(handles.noSourcesdip,'String'))
% noSourcesstrike = str2double(get(handles.noSourcesstrike,'String'))
% distanceStep = str2double(get(handles.distanceStep,'String'))
% steponPlane = str2double(get(handles.steponPlane,'String'))
% firstSourcestrike = str2double(get(handles.firstSourcestrike,'String'))
% firstSourcedip = str2double(get(handles.firstSourcedip,'String'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% green plane
% for j=1:noSourcesdip 
%     for i=1:noSourcesstrike
%          
%         sourceindex=sourceindex+1;
%         
%         xytext1(j,i)={num2str(i+sourceindex,'%02d')};
%         
%         y(j,i)=distanceStep*(i-firstSourcestrike);
%         x(j,i)=(steponPlane*cos(diprad1))*(j-firstSourcedip);
%         z1(j,i)=x(j,i)*tan(diprad1)-centdepth;
%         
%         [xrot(j,i),yrot(j,i)]=rotateisol(strikerad1,x(j,i),y(j,i));
%         
%         xrot1(j,i)=xrot(j,i); 
%         yrot1(j,i)=yrot(j,i); 
%     end
%      
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% red plane
% for j=1:noSourcesdip 
%     for i=1:noSourcesstrike
% 
%         xytext2(j,i)={num2str(i+sourceindex,'%02d')};
%         
%         y(j,i)=distanceStep*(i-firstSourcestrike);
%         x(j,i)=(steponPlane*cos(diprad2))*(j-firstSourcedip);
%         z2(j,i)=-x(j,i)*tan(diprad2)-centdepth;
%         
%         [xrot(j,i),yrot(j,i)]=rotateisol(strikerad2,x(j,i),y(j,i));
%         
%         xrot2(j,i)=xrot(j,i); 
%         yrot2(j,i)=yrot(j,i); 
%       
%     end
%      sourceindex=sourceindex+i;
% end

%%%%%%%%%%%%%%%%%%%%%%   Plot...

% figure(1)
% 
% if pl1 == 1;
%    hh1=plot3(xrot1,yrot1,z1,'-go');
%    set(hh1,'MarkerSize',4,'MarkerFaceColor','g');
% 
%    grid on
%     axis square
%              xlabel('East-West (km)')
%              ylabel('North-South (km)')
%              zlabel('Depth')
%              title(epititle)
%              set(gca,'Box','On')
%    hold on
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% perimeter
%           perx1=[xrot1(1,1)   yrot1(1,1)    z1(1,1) ];
%           perx2=[xrot1(1,noSourcesstrike)  yrot1(1,noSourcesstrike)   z1(1,noSourcesstrike) ];
%           perx4=[xrot1(noSourcesdip,1)  yrot1(noSourcesdip,1)   z1(noSourcesdip,1) ];
%           perx3=[xrot1(noSourcesdip,noSourcesstrike) yrot1(noSourcesdip,noSourcesstrike)  z1(noSourcesdip,noSourcesstrike) ];
%           perx5=[xrot1(1,1)   yrot1(1,1)    z1(1,1) ];
%           per1=[perx1;perx2;perx3;perx4;perx5];
% 
% hh1=plot3(per1(:,1),per1(:,2),per1(:,3),'-g',...)
%                 'LineWidth',2);
%              
% %%%%%%%Plot Hypocenter            
% hh1=plot3(epiXdist,epiYdist,-epidepth,'mp',...)
%                 'LineWidth',2,...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',[.49 1 .63],...
%                 'MarkerSize',12);
%             grid on
% axis square
% 
% else
%     
% end
% 
% %%% plane 2
% if pl2 == 1;
%     
%    hh2=plot3(xrot2,yrot2,z2,'-ro');
%    set(hh2,'MarkerSize',4,'MarkerFaceColor','r');
% 
% grid on
% axis square
%              xlabel('East-West (km)')
%              ylabel('North-South (km)')
%              zlabel('Depth')
%              title(epititle)
%              set(gca,'Box','On')
%          if pl1==0
%              hold on
%          else
%          end
%              perx1=[xrot2(1,1)   yrot2(1,1)    z2(1,1) ];
%              perx2=[xrot2(1,noSourcesstrike)  yrot2(1,noSourcesstrike)   z2(1,noSourcesstrike) ];
%              perx4=[xrot2(noSourcesdip,1)  yrot2(noSourcesdip,1)   z2(noSourcesdip,1) ];
%              perx3=[xrot2(noSourcesdip,noSourcesstrike) yrot2(noSourcesdip,noSourcesstrike)  z2(noSourcesdip,noSourcesstrike) ];
%              perx5=[xrot2(1,1)   yrot2(1,1)    z2(1,1) ];
%              per1=[perx1;perx2;perx3;perx4;perx5];
% 
%  hh2=plot3(per1(:,1),per1(:,2),per1(:,3),'-r',...)
%                          'LineWidth',2);
%     if pl1 ~= 1;
% %%%%%%%Plot Hypocenter 
%     hh2=plot3(epiYdist,epiXdist,-epidepth,'mp',...)
%                 'LineWidth',2,...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor',[.49 1 .63],...
%                 'MarkerSize',12);
%             grid on
%             axis square
%      else
%      end
% 
% else
% end


%% FIX SOURCE AT ORIGIN
sourceXdist=0; sourceYdist=0;

strikerad1=deg2rad(-str1);diprad1=deg2rad(dip1);

strikerad2=deg2rad(-str2);diprad2=deg2rad(dip2);

sourceindex=0;

noSourcesdip = str2double(get(handles.noSourcesdip,'String'));   noSourcesstrike = str2double(get(handles.noSourcesstrike,'String'));
distanceStep = str2double(get(handles.distanceStep,'String'));   steponPlane = str2double(get(handles.steponPlane,'String'));
firstSourcestrike = str2double(get(handles.firstSourcestrike,'String'));   firstSourcedip = str2double(get(handles.firstSourcedip,'String'));

%%  green plane
for j=1:noSourcesdip 
    for i=1:noSourcesstrike
         
        sourceindex=sourceindex+1;
        
        xytext1(j,i)={num2str(i+sourceindex,'%02d')};
        
        y(j,i)=distanceStep*(i-firstSourcestrike);
        x(j,i)=(steponPlane*cos(diprad1))*(j-firstSourcedip);
        z1(j,i)=-x(j,i)*tan(diprad1)-centdepth;
        
        [xrot(j,i),yrot(j,i)]=rotateisol(strikerad1,x(j,i),y(j,i));
        
        xrot1(j,i)=xrot(j,i); 
        yrot1(j,i)=yrot(j,i); 
    end
     
end

%%  red plane
for j=1:noSourcesdip 
    for i=1:noSourcesstrike

        xytext2(j,i)={num2str(i+sourceindex,'%02d')};
        
        y(j,i)=distanceStep*(i-firstSourcestrike);
        x(j,i)=(steponPlane*cos(diprad2))*(j-firstSourcedip);
        z2(j,i)=-x(j,i)*tan(diprad2)-centdepth;
        
        [xrot(j,i),yrot(j,i)]=rotateisol(strikerad2,x(j,i),y(j,i));
        
        xrot2(j,i)=xrot(j,i); 
        yrot2(j,i)=yrot(j,i); 
      
    end
     sourceindex=sourceindex+i;
end

%%   Plot...

figure(1)

if pl1 == 1;
   hh1=plot3(xrot1,yrot1,z1,'-go');
   set(hh1,'MarkerSize',4,'MarkerFaceColor','g');

   grid on
   axis square
             xlabel('East-West (km)')
             ylabel('North-South (km)')
             zlabel('Depth')
             title(epititle)
             set(gca,'Box','On')
   hold on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% perimeter
          perx1=[xrot1(1,1)   yrot1(1,1)    z1(1,1) ];
          perx2=[xrot1(1,noSourcesstrike)  yrot1(1,noSourcesstrike)   z1(1,noSourcesstrike) ];
          perx4=[xrot1(noSourcesdip,1)  yrot1(noSourcesdip,1)   z1(noSourcesdip,1) ];
          perx3=[xrot1(noSourcesdip,noSourcesstrike) yrot1(noSourcesdip,noSourcesstrike)  z1(noSourcesdip,noSourcesstrike) ];
          perx5=[xrot1(1,1)   yrot1(1,1)    z1(1,1) ];
          per1=[perx1;perx2;perx3;perx4;perx5];

hh1=plot3(per1(:,1),per1(:,2),per1(:,3),'-g',... 
                'LineWidth',2);
             
%% Plot Hypocenter            
hhHYP=plot3(epiXdist,epiYdist,-epidepth,'mp',... 
                'LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',[.49 1 .63],...
                'MarkerSize',12);
            grid on
axis square

else
    % do not plot Plane 1
end

%%  plane 2
if pl2 == 1;
    
   hh2=plot3(xrot2,yrot2,z2,'-ro');
   set(hh2,'MarkerSize',4,'MarkerFaceColor','r');

   grid on
   axis square
             xlabel('East-West (km)')
             ylabel('North-South (km)')
             zlabel('Depth')
             title(epititle)
             set(gca,'Box','On')
         if pl1==0
             hold on
         else
         end
             perx1=[xrot2(1,1)   yrot2(1,1)    z2(1,1) ];
             perx2=[xrot2(1,noSourcesstrike)  yrot2(1,noSourcesstrike)   z2(1,noSourcesstrike) ];
             perx4=[xrot2(noSourcesdip,1)  yrot2(noSourcesdip,1)   z2(noSourcesdip,1) ];
             perx3=[xrot2(noSourcesdip,noSourcesstrike) yrot2(noSourcesdip,noSourcesstrike)  z2(noSourcesdip,noSourcesstrike) ];
             perx5=[xrot2(1,1)   yrot2(1,1)    z2(1,1) ];
             per1=[perx1;perx2;perx3;perx4;perx5];

     hh2=plot3(per1(:,1),per1(:,2),per1(:,3),'-r','LineWidth',2);
       
    if pl1 ~= 1;
%%   Plot Hypocenter 
    hhHYP=plot3(epiXdist,epiYdist,-epidepth,'mp',... 
                'LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',[.49 1 .63],...
                'MarkerSize',12);
            grid on
            axis square
     else
     end

else
    % do not plot Plane 2
end

%%

disp('  ')
disp('Output')

%% measure distance...
%%H-C distance
eucdisHC=f3dist(epiYdist,epiXdist,epidepth,0,0,centdepth   );
disp(['Hypocenter Centroid distance is   '  num2str(eucdisHC,'%6.2f')  ' km'])
set(handles.hcdis,'String',num2str(eucdisHC,'%6.2f'))   
%%
%%%%%%%%%%% old type calculation based on point to grid point on plane -
%%%%%%%%%%% distance  ... wrong for small distances...

for j=1:noSourcesdip 
    for i=1:noSourcesstrike
eucdis1(j,i)=f3dist(epiXdist,epiYdist,-epidepth,xrot1(j,i),yrot1(j,i),z1(j,i));
eucdis2(j,i)=f3dist(epiXdist,epiYdist,-epidepth,xrot2(j,i),yrot2(j,i),z2(j,i));
end
end

a1=min(eucdis1);
a2=min(eucdis2);

a11=min(a1);
a22=min(a2);

disp(['Minimum distance from Plane 1  old code   '  num2str(a11)])
disp(['Minimum distance from Plane 2  old code   '  num2str(a22)])
% % 
% set(handles.dist1,'String',num2str(a11,'%6.2f'))        
% set(handles.dist2,'String',num2str(a22,'%6.2f'))        

%% new algorithm
%  str1
%  dip1
%  epiYdist
%  epiXdist
%  epidepth
%  centdepth
dis_hc1=point_plane_dist(str1,dip1,epiYdist,epiXdist,epidepth,0,0,centdepth);
dis_hc2=point_plane_dist(str2,dip2,epiYdist,epiXdist,epidepth,0,0,centdepth);
%
% changed order of epiXdist,epiYdist above 07/11/2013

 disp(['Minimum distance from Plane 1 is ' num2str(dis_hc1,'%6.2f') ' km' ])     %.    '  'Plane Strike= ' num2str(str1) '  Dip=  ' num2str(dip1)   ])
 disp(['Minimum distance from Plane 2 is ' num2str(dis_hc2,'%6.2f') ' km' ])     %.    '  'Plane Strike= ' num2str(str2) '  Dip=  ' num2str(dip2)   ])
%
 set(handles.dist1,'String',num2str(dis_hc1,'%6.2f'))        
 set(handles.dist2,'String',num2str(dis_hc2,'%6.2f'))  
%
%%
if useextra == 1;    %%%plot more hypocenters
    
     hhmore=plot3(moreXdist,moreYdist,-morez,'mp',...)
                'LineWidth',1,...
                'MarkerEdgeColor','b',...
                'MarkerFaceColor',[.49 1 .63],...
                'MarkerSize',6);

     % calculate offset of text from point (star)
     V=axis;   Xlim=V(2)+abs(V(1));     Ylim=V(4)+abs(V(3));
     offX=0.005*Xlim;  offY=0.005*Ylim;
     
     for i=1:length(moreinfo)
          text(moreXdist(i)+offX,moreYdist(i)+offY,-morez(i),moreinfo(i),'Fontname','Helvetica','Fontsize',11)
     end
            
     grid on
     axis square
     hold off
     rotate3d on
    
else
     grid on
     axis square
     hold off
     rotate3d on
end

%% write new defaults...!!
        fid = fopen('hcplot.ini','w');
         fprintf(fid,'%s\r\n',epititle);
         fprintf(fid,'%g\r\n',epilat);
         fprintf(fid,'%g\r\n',epilon);
         fprintf(fid,'%g\r\n',epidepth);
         fprintf(fid,'%g\r\n',centlat);
         fprintf(fid,'%g\r\n',centlon);
         fprintf(fid,'%g\r\n',centdepth);
        
         fprintf(fid,'%g\r\n',str1);
         fprintf(fid,'%g\r\n',dip1);
         fprintf(fid,'%g\r\n',str2);
         fprintf(fid,'%g\r\n',dip2);
         fprintf(fid,'%s\r\n',moreepifile);
         %%write extra hypos also..!!
         if useextra == 1;
                 fprintf(fid,'%g\r\n',length(morex));
            for i=1:length(morex)
                 fprintf(fid,'%g %g %g %s\r\n',morex(i),morey(i),morez(i),moreinfo{i});
            end
         else
         end
        fclose(fid);

        set(handles.movie,'Enable','On')
        

% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close


% --- Executes during object creation, after setting all properties.
function str1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to str1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function str1_Callback(hObject, eventdata, handles)
% hObject    handle to str1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of str1 as text
%        str2double(get(hObject,'String')) returns contents of str1 as a double


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
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function dip1text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip1text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dip1text_Callback(hObject, eventdata, handles)
% hObject    handle to dip1text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip1text as text
%        str2double(get(hObject,'String')) returns contents of dip1text as a double


% --- Executes during object creation, after setting all properties.
function str2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to str2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function str2_Callback(hObject, eventdata, handles)
% hObject    handle to str2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of str2 as text
%        str2double(get(hObject,'String')) returns contents of str2 as a double


% --- Executes during object creation, after setting all properties.
function dip2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dip2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dip2_Callback(hObject, eventdata, handles)
% hObject    handle to dip2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dip2 as text
%        str2double(get(hObject,'String')) returns contents of dip2 as a double


% --- Executes during object creation, after setting all properties.
function clat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function clat_Callback(hObject, eventdata, handles)
% hObject    handle to clat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clat as text
%        str2double(get(hObject,'String')) returns contents of clat as a double


% --- Executes during object creation, after setting all properties.
function clon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function clon_Callback(hObject, eventdata, handles)
% hObject    handle to clon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clon as text
%        str2double(get(hObject,'String')) returns contents of clon as a double


% --- Executes during object creation, after setting all properties.
function cdepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function cdepth_Callback(hObject, eventdata, handles)
% hObject    handle to cdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cdepth as text
%        str2double(get(hObject,'String')) returns contents of cdepth as a double


% --- Executes during object creation, after setting all properties.
function hlat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function hlat_Callback(hObject, eventdata, handles)
% hObject    handle to hlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hlat as text
%        str2double(get(hObject,'String')) returns contents of hlat as a double


% --- Executes during object creation, after setting all properties.
function hlon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hlon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function hlon_Callback(hObject, eventdata, handles)
% hObject    handle to hlon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hlon as text
%        str2double(get(hObject,'String')) returns contents of hlon as a double


% --- Executes during object creation, after setting all properties.
function hdepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function hdepth_Callback(hObject, eventdata, handles)
% hObject    handle to hdepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hdepth as text
%        str2double(get(hObject,'String')) returns contents of hdepth as a double


% --- Executes during object creation, after setting all properties.
function nosourcesstrike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nosourcesstrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function nosourcesstrike_Callback(hObject, eventdata, handles)
% hObject    handle to nosourcesstrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nosourcesstrike as text
%        str2double(get(hObject,'String')) returns contents of nosourcesstrike as a double


% --- Executes during object creation, after setting all properties.
function nosourcesdip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nosourcesdip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function nosourcesdip_Callback(hObject, eventdata, handles)
% hObject    handle to nosourcesdip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nosourcesdip as text
%        str2double(get(hObject,'String')) returns contents of nosourcesdip as a double


% --- Executes during object creation, after setting all properties.
function distancestep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distancestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function distancestep_Callback(hObject, eventdata, handles)
% hObject    handle to distancestep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of distancestep as text
%        str2double(get(hObject,'String')) returns contents of distancestep as a double


% --- Executes during object creation, after setting all properties.
function steponplane_CreateFcn(hObject, eventdata, handles)
% hObject    handle to steponplane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function steponplane_Callback(hObject, eventdata, handles)
% hObject    handle to steponplane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of steponplane as text
%        str2double(get(hObject,'String')) returns contents of steponplane as a double


% --- Executes during object creation, after setting all properties.
function firstsourcestrike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstsourcestrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function firstsourcestrike_Callback(hObject, eventdata, handles)
% hObject    handle to firstsourcestrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstsourcestrike as text
%        str2double(get(hObject,'String')) returns contents of firstsourcestrike as a double


% --- Executes during object creation, after setting all properties.
function firstsourcedip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstsourcedip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function firstsourcedip_Callback(hObject, eventdata, handles)
% hObject    handle to firstsourcedip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstsourcedip as text
%        str2double(get(hObject,'String')) returns contents of firstsourcedip as a double


% --- Executes on button press in movie.
function movie_Callback(hObject, eventdata, handles)
% hObject    handle to movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

elev = str2double(get(handles.elev,'String'));
 
rect=get(1,'Position');

M=moviein(36,1);

for i=10:10:360
     
      view(i,elev)

      M(:,(i/10))=getframe(1,[0 0 rect(3) rect(4)]);  %[left bottom width height]
end
     
%figure
%movie(M);
movie2avi(M,'hcplot','fps',24,'compression','Indeo5')
% 

% --- Executes during object creation, after setting all properties.
function noSourcesstrike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noSourcesstrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function noSourcesstrike_Callback(hObject, eventdata, handles)
% hObject    handle to noSourcesstrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noSourcesstrike as text
%        str2double(get(hObject,'String')) returns contents of noSourcesstrike as a double

noSourcesdip = str2double(get(handles.noSourcesdip,'String'));
noSourcesstrike = str2double(get(handles.noSourcesstrike,'String'));
distanceStep = str2double(get(handles.distanceStep,'String'));
steponPlane = str2double(get(handles.steponPlane,'String'));


flength=(noSourcesstrike*distanceStep)-distanceStep
fwidth=(noSourcesdip*steponPlane)-steponPlane

set(handles.faultl,'String',num2str(flength,'%3g'));        
set(handles.faultw,'String',num2str(fwidth,'%3g'));        


% --- Executes during object creation, after setting all properties.
function noSourcesdip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noSourcesdip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function noSourcesdip_Callback(hObject, eventdata, handles)
% hObject    handle to noSourcesdip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noSourcesdip as text
%        str2double(get(hObject,'String')) returns contents of noSourcesdip as a double
noSourcesdip = str2double(get(handles.noSourcesdip,'String'));
noSourcesstrike = str2double(get(handles.noSourcesstrike,'String'));
distanceStep = str2double(get(handles.distanceStep,'String'));
steponPlane = str2double(get(handles.steponPlane,'String'));


flength=(noSourcesstrike*distanceStep)-distanceStep
fwidth=(noSourcesdip*steponPlane)-steponPlane

set(handles.faultl,'String',num2str(flength,'%3g'));        
set(handles.faultw,'String',num2str(fwidth,'%3g'));        


% --- Executes during object creation, after setting all properties.
function distanceStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distanceStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function distanceStep_Callback(hObject, eventdata, handles)
% hObject    handle to distanceStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of distanceStep as text
%        str2double(get(hObject,'String')) returns contents of distanceStep as a double
noSourcesdip = str2double(get(handles.noSourcesdip,'String'));
noSourcesstrike = str2double(get(handles.noSourcesstrike,'String'));
distanceStep = str2double(get(handles.distanceStep,'String'));
steponPlane = str2double(get(handles.steponPlane,'String'));


flength=(noSourcesstrike*distanceStep)-distanceStep
fwidth=(noSourcesdip*steponPlane)-steponPlane

set(handles.faultl,'String',num2str(flength,'%3g'));        
set(handles.faultw,'String',num2str(fwidth,'%3g'));        


% --- Executes during object creation, after setting all properties.
function steponPlane_CreateFcn(hObject, eventdata, handles)
% hObject    handle to steponPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function steponPlane_Callback(hObject, eventdata, handles)
% hObject    handle to steponPlane (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of steponPlane as text
%        str2double(get(hObject,'String')) returns contents of steponPlane as a double

noSourcesdip = str2double(get(handles.noSourcesdip,'String'));
noSourcesstrike = str2double(get(handles.noSourcesstrike,'String'));
distanceStep = str2double(get(handles.distanceStep,'String'));
steponPlane = str2double(get(handles.steponPlane,'String'));


flength=(noSourcesstrike*distanceStep)-distanceStep
fwidth=(noSourcesdip*steponPlane)-steponPlane

set(handles.faultl,'String',num2str(flength,'%3g'));        
set(handles.faultw,'String',num2str(fwidth,'%3g'));        

% --- Executes during object creation, after setting all properties.
function firstSourcestrike_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstSourcestrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function firstSourcestrike_Callback(hObject, eventdata, handles)
% hObject    handle to firstSourcestrike (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstSourcestrike as text
%        str2double(get(hObject,'String')) returns contents of firstSourcestrike as a double


% --- Executes during object creation, after setting all properties.
function firstSourcedip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstSourcedip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function firstSourcedip_Callback(hObject, eventdata, handles)
% hObject    handle to firstSourcedip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstSourcedip as text
%        str2double(get(hObject,'String')) returns contents of firstSourcedip as a double





% --- Executes during object creation, after setting all properties.
function elev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to elev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function elev_Callback(hObject, eventdata, handles)
% hObject    handle to elev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of elev as text
%        str2double(get(hObject,'String')) returns contents of elev as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes on button press in readparam.
function readparam_Callback(hObject, eventdata, handles)
% hObject    handle to readparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


messtext=...
   ['Please select a file created using the Save Parameter file option.'];

uiwait(msgbox(messtext,'Message','warn','modal'));

[file1,path1] = uigetfile([ '*.*'],' HC Plot parameter file',400,400);

   lopa = [path1 file1];
   name = file1

   if name == 0
       disp('Cancel file load')
       return
   else
   end
   
   %%%read now..!!
    fid = fopen(lopa,'r')
    epititle= fgetl(fid)
    epilat=fscanf(fid,'%g',1)
    epilon=fscanf(fid,'%g',1)
    epidepth=fscanf(fid,'%g',1)
    
    centlat=fscanf(fid,'%g',1)
    centlon=fscanf(fid,'%g',1)
    centdepth=fscanf(fid,'%g',1)
    
    str1=fscanf(fid,'%g',1)
    dip1=fscanf(fid,'%g',1)
    str2=fscanf(fid,'%g',1)
    dip2=fscanf(fid,'%g',1)
    moreepifile=fscanf(fid,'%s',1)
    usextra=fscanf(fid,'%i',1)
    
    if usextra == 1
        nulines=fscanf(fid,'%g',1)
      
        fid2 = fopen(moreepifile,'w')
    
        [elat,elon,edep,einfo] = textread(lopa,'%f %f %f %s','headerlines',14) %     for i=1:nulines

         for i=1:nulines
                fprintf(fid2,'%g %g %g %s\r\n',elat(i),elon(i),edep(i),einfo{i})
                i   
         end

        fclose(fid);
        fclose(fid2);
    else
    end

set(handles.epititle,'String',epititle);        
set(handles.hlat,'String',num2str(epilat));        
set(handles.hlon,'String',num2str(epilon));         
set(handles.hdepth,'String',num2str(epidepth));  

set(handles.clat,'String',num2str(centlat));        
set(handles.clon,'String',num2str(centlon));         
set(handles.cdepth,'String',num2str(centdepth));    

set(handles.str1,'String',num2str(str1));        
set(handles.dip1,'String',num2str(dip1));         
set(handles.str2,'String',num2str(str2));    
set(handles.dip2,'String',num2str(dip2));    

set(handles.moreepifile,'String',moreepifile);    
set(handles.extraepi,'Value',usextra);    


% --- Executes on button press in saveparam.
function saveparam_Callback(hObject, eventdata, handles)
% hObject    handle to saveparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile('hcplot.ini','Save file name');


   lopa = [path file];
   name = file

   if name == 0
       disp('Cancel file save')
       return
   else
   end
   
%[s,mess,messid]=copyfile('hcplot.ini',lopa)
% Read parameters
%%%%%%EPICENTER
epititle = get(handles.epititle,'String');
epilat = str2double(get(handles.hlat,'String'));
epilon = str2double(get(handles.hlon,'String'));
epidepth = str2double(get(handles.hdepth,'String'));
%%%%%%centroid
centlat = str2double(get(handles.clat,'String'));
centlon = str2double(get(handles.clon,'String'));
centdepth = str2double(get(handles.cdepth,'String'));

%%%%%% plane 1
str1 = str2double(get(handles.str1,'String'));
dip1 = str2double(get(handles.dip1,'String'));
%%%%%% plane 2
str2 = str2double(get(handles.str2,'String'));
dip2 = str2double(get(handles.dip2,'String'));


%%% extra data..
moreepifile=get(handles.moreepifile,'String')
useextra = get(handles.extraepi,'Value')


        fid = fopen(lopa,'w');
         fprintf(fid,'%s\r\n',epititle);
         fprintf(fid,'%g\r\n',epilat);
         fprintf(fid,'%g\r\n',epilon);
         fprintf(fid,'%g\r\n',epidepth);
         fprintf(fid,'%g\r\n',centlat);
         fprintf(fid,'%g\r\n',centlon);
         fprintf(fid,'%g\r\n',centdepth);
        
         fprintf(fid,'%g\r\n',str1);
         fprintf(fid,'%g\r\n',dip1);
         fprintf(fid,'%g\r\n',str2);
         fprintf(fid,'%g\r\n',dip2);
         fprintf(fid,'%s\r\n',moreepifile);
         fprintf(fid,'%i\r\n',useextra);
         
         %%write extra hypos also..!!
         if useextra == 1;
                   [morex,morey,morez,moreinfo] = textread(moreepifile,'%f %f %f %s')%,'headerlines',1)
                 fprintf(fid,'%g\r\n',length(morex));
                 
            for i=1:length(morex)
                 fprintf(fid,'%g %g %g %s\r\n',morex(i),morey(i),morez(i),moreinfo{i});
            end
        else
        end
         
        fclose(fid);



% --- Executes on button press in extraepi.
function extraepi_Callback(hObject, eventdata, handles)
% hObject    handle to extraepi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of extraepi


% --- Executes during object creation, after setting all properties.
function moreepifile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to moreepifile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function moreepifile_Callback(hObject, eventdata, handles)
% hObject    handle to moreepifile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of moreepifile as text
%        str2double(get(hObject,'String')) returns contents of moreepifile as a double


% --- Executes on button press in changeit.
function changeit_Callback(hObject, eventdata, handles)
% hObject    handle to changeit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

messtext=...
   ['Please select a datafile.                           '
    'This file should be a text file with                '
    'four columns separated by spaces.No limit in lines. '
    'Columns should contain Latitude Longitude Depth Info'];

uiwait(msgbox(messtext,'Message','warn','modal'));

[file1,path1] = uigetfile([ '*.*'],' Extra hypocenters file',400,400);

   lopa = [path1 file1];
   name = file1

   if name == 0
       disp('Cancel file load')
       return
   else
   end
   
set(handles.moreepifile,'String',file1);        


% --- Executes on button press in pl1.
function pl1_Callback(hObject, eventdata, handles)
% hObject    handle to pl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pl1


% --- Executes on button press in pl2.
function pl2_Callback(hObject, eventdata, handles)
% hObject    handle to pl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pl2
