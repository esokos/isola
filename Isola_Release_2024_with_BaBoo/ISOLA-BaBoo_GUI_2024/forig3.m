function forig3

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
sourceindex=0;
%%
% 
%     [xi,yi,but] = ginput(1);
%     [xylon,xylat] =m_xy2ll(xi,yi);
 
xylat=str2num(get(handles1.lat,'String'));
xylon=str2num(get(handles1.lon,'String'));
    
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
%% remove null if exist...      
 % store origin
handles1.originlon=xylon;
handles1.originlat=xylat;
guidata(gcbo, handles1);

