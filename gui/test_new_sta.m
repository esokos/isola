fullstationfile='PSLSTA.stn';

    fid = fopen('event.isl','r');
    eventcor=fscanf(fid,'%g',2);
% %%%% READ MAGNITUDE AND DATE .....(not used in computations!!!!!!!!)
    epidepth=fscanf(fid,'%g',1);
    magn=fscanf(fid,'%g',1);
    eventdate=fscanf(fid,'%s',1);
    eventhour=fscanf(fid,'%s',1);
    eventmin=fscanf(fid,'%s',1);
    eventsec=fscanf(fid,'%s',1);
    
    fclose(fid);

eventcor=[21 38];
epidepth=5;
magn=4;
selarea=1;

%% Create the OT 
OT=[str2double(eventdate(1:4)) str2double(eventdate(5:6)) str2double(eventdate(7:8)) str2double(eventhour) str2double(eventmin) str2double(eventsec)];
% 
%dt_or = datestr(OT, 'mmmm dd, yyyy HH:MM:SS.FFF AM')
% read the taper.isl
       fid  = fopen('taper.isl','r');
           taper = cell2mat(textscan(fid, '%f'));
       fclose(fid);

RelativeTime = ([0, 0, taper] * [3600; 60; 1]) / 86400;
OTnew=datenum(OT)-RelativeTime;

new_OT=datevec(OTnew)

dt_new = datestr(OTnew, 'mmmm dd, yyyy HH:MM:SS.FFF')       
       
       
%%

%read data in 3 arrays
fid  = fopen(fullstationfile,'r');
 C= textscan(fid,'%s %f %f',-1);
fclose(fid);
staname=C{1};
stalat=C{2};
stalon=C{3};

length(stalon)
%%
%prepare plotting ...matlab example
bdwidth = 5;
topbdwidth = 100;
set(0,'Units','pixels') 
scnsize = get(0,'ScreenSize');
pos1  = [bdwidth+topbdwidth,topbdwidth,...
    scnsize(3)*2/3 - 2*bdwidth,...
    scnsize(4)*2/3 - (topbdwidth + bdwidth)];

%%% add epicenter coordinates in case it is far from stations
alllat=[stalat;eventcor(2)];
alllon=[stalon;eventcor(1)];

hh=figure('Position',pos1,'Name','map','Toolbar','figure');

% create structure of handles
handles1 = guihandles(hh); 
handles1.staname=staname;
handles1.stalat=stalat;
handles1.stalon=stalon;
handles1.eventcor=eventcor;
handles1.epidepth=epidepth;
handles1.magn=magn;
handles1.eventdate=eventdate;
handles1.selarea=selarea;

guidata(hh, handles1);

hplot1  = uicontrol('Style', 'pushbutton', 'String', 'Select Stations',...
    'Position', [20 250 100 70], 'Callback', 'plstat');                          %%%%run the code to select stations....

hplot3  = uicontrol('Style', 'pushbutton', 'String', 'Select all',...
    'Position', [20 150 100 70], 'Callback', 'selectall');                       %%%%exit....

hplot2  = uicontrol('Style', 'pushbutton', 'String', 'Exit',...
    'Position', [20  50 100 70], 'Callback', 'close map');                       %%%%exit....


hplot11  = uicontrol('Style', 'Text', 'String', 'Warning: Selecting simultanously very near and very far stations may be difficult in this tool. Please consider whether you actually need to combine the near and far stations.',...
    'Position', [20 550 100 170], 'Callback', 'plstat');                          %%%%run the code to select stations....

% decide about map limits based on percent of lat lon distance  .... 
minlat=min(alllat);maxlat=max(alllat);
minlon=min(alllon);maxlon=max(alllon);
latdis=maxlat-minlat;londis=maxlon-minlon;
brdlat=latdis*0.2;brdlon=londis*0.2;

m_proj('Mercator','long',[min(alllon)-brdlon max(alllon)+brdlon],'lat',[min(alllat)-brdlat max(alllat)+brdlat]);
m_gshhs_i('patch',[.7 .7 .7]);
%m_gshhs_h('patch',[.7 .7 .7],'edgecolor','g');%'color','k');
%m_grid('box','fancy','tickdir','out');
m_grid;%('tickstyle','dd');
m_ruler([0.1 0.4],0.08,2);


% axesm('mercator','MapLatLimit',[min(alllat)-brdlat max(alllat)+brdlat],...
%                   'MapLonLimit',[min(alllon)-brdlon max(alllon)+brdlon])%,...
% %                  'Frame','off','Grid','off','MeridianLabel','on', ...
% %                  'ParallelLabel','on')
% axis off;
% framem on; gridm on; mlabel on; plabel on;
% 
% %axis off
% setm(gca,'MLabelLocation',1)
% setm(gca,'PLabelLocation',1)
% %setm(gca,'MLineLocation',1);
% % setm(gca,'MLineLocation',1);
% % setm(gca,'PLineLocation',1);
% 
% % %MLineLocation
% % % framem('on')
% % % %axis off; 
% % % %framem on; 
% % %coast = load('coast');
% % % %setm(gca,'MLabelLocation',60)
% % %geoshow(coast.lat,coast.long,'DisplayType','polygon')
% % %scaleruler on
% % %gridm on; mlabel on; plabel on;
% % filename = gunzip('gshhs_i.b.gz', tempdir);
% % world = gshhs(filename{1});
% % delete(filename{1})
% % geoshow([world.Lat], [world.Lon])
% l=gshhs('C:\Program Files\MATLAB\R2009b\m_map\private\GSHHS_h.B',[min(alllat)-brdlat max(alllat)+brdlat],[min(alllon)-brdlon max(alllon)+brdlon]);
% 
%  %LATLIM, LONLIM) 
%  geoshow([l.Lat], [l.Lon])
%% plot stations
hdd=ones(length(stalat),1);
for i=1:length(stalat)
   hdd(i)=m_line(stalon(i),stalat(i),'marker','s',...
                                     'markersize',11,...
                                     'MarkerFaceColor','r',...
                                     'userdata'     ,i,...
                                     'ButtonDownFcn',{@selectsta,staname,new_OT});
                                 
          m_text(stalon(i),stalat(i),staname(i),'vertical','top')%,'ButtonDownFcn',{@selectsta,staname,new_OT});
 
%    hdd(i)=plotm(stalat(i),stalon(i),'marker','s',...
%                                      'markersize',10,...
%                                      'MarkerFaceColor','r',...
%                                      'userdata'     ,i,...
%                                      'ButtonDownFcn',{@selectsta,staname,new_OT});
%                                  
%           textm(stalat(i),stalon(i),staname(i),'vertical','top');

 

end

%       hdd(i)=line(X(i),Y(i),'marker'      ,'s'...
%                            ,'MarkerFaceColor','r'...
%                            ,'userdata'     ,i...
%                            ,'ButtonDownFcn', @CallBack1);
%       

%%%plot epicenter

%m_line(eventcor(1),eventcor(2),'marker','p','markersize',17,'color','b','MarkerFaceColor','b');

%%
