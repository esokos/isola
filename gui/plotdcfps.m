function ans=plotdcfps(s1m,di1m,s2m,di2m,aziPm,plungePm,aziTm,plungeTm)

h1=figure('Renderer','zbuffer');
THETA=linspace(0,2*pi,2000);
RHO=ones(1,2000)*5;
[X,Y] = pol2cart(THETA,RHO);
X=X+10;
Y=Y+10;
plot(X,Y,'-k');
axis square;
axis off
hold on


switch nargin
    
    case 4 
            for i=1:length(s1m)
                [x,y]=plpl(s1m(i,1),di1m(i,1));
                     plot(x,y,'k')
                [x1,y1]=plpl(s2m(i,1),di2m(i,1));
                     plot(x1,y1,'k')
            end
            plot(10,10,'+','MarkerSize',8)
            text (10,15.2,'0','FontSize',12);          
            text (9.6,4.5,'180','FontSize',12);  
            text (15.2,10,'90','FontSize',12);          
            text (4. ,10,'270','FontSize',12);      
        
    case 8
             for i=1:length(s1m)
                [x,y]=plpl(s1m(i,1),di1m(i,1));
                    plot(x,y,'k')
                [x1,y1]=plpl(s2m(i,1),di2m(i,1));
                    plot(x1,y1,'k')
                [ax2m,ay2m]=pltsym(90-plungePm(i,1),aziPm(i,1));
                    plot(ax2m,ay2m,'Marker','s','MarkerEdgeColor','b','MarkerFaceColor','b')
%        text(ax2m(i)+0.1,ay2m(i)+0.1,'P','FontSize',10,...
%                              'HorizontalAlignment','left',...
%                              'VerticalAlignment','bottom',...
%                              'Color','k');
                [ax2m,ay2m]=pltsym(90-plungeTm(i,1),aziTm(i,1));
                    plot(ax2m,ay2m,'Marker','o','MarkerEdgeColor','y','MarkerFaceColor','y')
%       text(ax2m(i)+0.1,ay2m(i)+0.1,'T','FontSize',10,...
%                              'HorizontalAlignment','left',...
%                              'VerticalAlignment','bottom',...
%                              'Color','k');
               plot(10,10,'+','MarkerSize',8)
               text (10,15.2,'0','FontSize',12);          
               text (9.6,4.5,'180','FontSize',12);  
               text (15.2,10,'90','FontSize',12);          
               text (4. ,10,'270','FontSize',12);      
end


end

  ans=1;
