function forig2

%%
handles1 = guidata(gcbo); 
staname=handles1.staname;
stalat=handles1.stalat;
stalon=handles1.stalon;

gridspc=str2num(get(handles1.gspc,'String'));

nlon=handles1.ngrdx;
nlat=handles1.ngrdy;

left=handles1.left;
right=handles1.right;
down=handles1.down;
up=handles1.up;

cla

%% replot

m_proj('Mercator','long',[left right],'lat',[down up]);
m_coast('color',[0 0 0]);

for i=1:length(stalat)
 m_plot(stalon(i),stalat(i),'^','markersize',7,'color','r','MarkerFaceColor','r');
 m_text(stalon(i),stalat(i),staname(i),'vertical','top');
end
m_grid('box','fancy','tickdir','out');


%% get new value
sourceindex=0;
 
%%
n = 0;

% Loop, picking up the points.
disp('Pick a point.')
disp('  ')
disp('  ')

% h=helpdlg('Left mouse button selects station. Right mouse button selects last station.','Station Selection');
% uiwait(h)

%     [xi,yi,but] = ginput(1);
%     [xylon,xylat] =m_xy2ll(xi,yi);

try
clickData = gtrack();   
 
    xylon=str2num(num2str(clickData.x,'%6.2f'));
    xylat=str2num(num2str(clickData.y,'%6.2f'));
    
catch
end    
    
    
% calculate the grid point
for j=1:nlon 
    for i=1:nlat

        xytext(j,i)={num2str(i+sourceindex,'%02d')};
        
        
        y(j,i)=gridspc*(i-1)+xylat;
        x(j,i)=gridspc*(j-1)+xylon;
        
         m_plot(x(j,i),y(j,i),'+','markersize',7,'color','b','MarkerFaceColor','b');
         m_text(x(j,i),y(j,i),xytext(j,i),'vertical','top');

        
    end
      sourceindex=sourceindex+i;
end
%%% remove null if exist...      
 
%% store origin
handles1.originlon=xylon;
handles1.originlat=xylat;
guidata(gcbo, handles1);



