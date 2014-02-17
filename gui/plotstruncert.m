function plotstruncert(elipsa_max,strike1,strike2)

f=figure('Color',[0.8 0.8 0.8]);
%subplot(2,2,1) 
% tt=elipsa_max(:,5);
% tt=tt(1:2:length(tt));
% hist(tt,36);

hist(elipsa_max(:,5),36);
n=hist(elipsa_max(:,5),36);
hold on
x=[strike1 strike1];
y=[0 max(n)];

ax=gca;
set(ax,'Linewidth',2,'FontSize',12)

line(x,y,'Color','r','LineWidth',4,'ButtonDownFcn', @startDragFcn1);
h1strike=line(x,y,'Color','r','LineWidth',3,'LineStyle','--','ButtonDownFcn', @startDragFcn1);
set(h1strike,'UserData', 0)

h1text=text(strike1+5,max(n)+(max(n)*0.1),'\pm0\circ','FontSize',12);

x=[strike2 strike2];
y=[0 max(n)];
line(x,y,'Color','r','LineWidth',4,'ButtonDownFcn', @startDragFcn2);
h2strike=line(x,y,'Color','r','LineWidth',4,'LineStyle','--','ButtonDownFcn', @startDragFcn2);
set(h2strike,'UserData', 0)

h2text=text(strike2+5,max(n)+(max(n)*0.1),'\pm0\circ','FontSize',12);

title('Strike','FontSize',18)
h=axis;

axis([h(1) 360 h(3) h(4)+(h(4)*0.2)]) 

h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','w')


aH=get(gcf,'CurrentAxes'); %('Xlim', [0 1], 'Ylim',[0 1]);
set(f,'WindowButtonUpFcn',{@stopDragFcn,strike1,strike2,max(n)});


function startDragFcn1(varargin)
     set(f,'WindowButtonMotionFcn', @draggingFcn1)
     set(h1strike,'Color','y')
     set(h1strike,'UserData',1)
end

function draggingFcn1(varargin)
     pt=get(aH,'CurrentPoint');
     set(h1strike,'XData', pt(1)*[1 1])
end

function startDragFcn2(varargin)
     set(f,'WindowButtonMotionFcn', @draggingFcn2)
     set(h2strike,'Color','g')
     set(h2strike,'UserData',1)
end

function draggingFcn2(varargin)
     pt=get(aH,'CurrentPoint');
     set(h2strike,'XData', pt(1)*[1 1])
end

function stopDragFcn(varargin)
    set(f,'WindowButtonMotionFcn','');
    
strike1=varargin{3};
strike2=varargin{4};

llimit1=get(h1strike,'XData');
llimit2=get(h2strike,'XData');

ud1=get(h1strike,'UserData');
ud2=get(h2strike,'UserData');

s1=abs(llimit1(1)-varargin{3});
s2=abs(llimit2(1)-varargin{4});


% find what user clicked
if ud1==0 && ud2==1
    % disp('worked with 2')
    % calculate the right limit for strike2
      if strike1 < strike2
        rlimit2=strike2-s2;
      else
        rlimit2=strike2+s2;
      end
    % plot another line
      x=[rlimit2 rlimit2];
      y=[0 varargin{5}];
      line(x,y,'Color','g','LineWidth',3,'LineStyle','--');
      set(h2text,'String', [num2str(fix(strike2)) ' ' '\pm' num2str(s2,'%3.0f') '\circ'])
  
      set(h2strike,'UserData',0)
elseif ud1==1 && ud2==0
   % disp('worked with 1')
      rlimit1=strike1+(strike1-llimit1(1));
    % calculate the right limit for strike1
      if strike1 < strike2
        rlimit2=strike1+s2;
      else
        rlimit2=strike1-s2;
      end
      % plot another line
      x=[rlimit1 rlimit1];
      y=[0 varargin{5}];
      line(x,y,'Color','y','LineWidth',3,'LineStyle','--');
      set(h1text,'String', [num2str(fix(strike1)) ' ' '\pm' num2str(abs(s1),'%3.0f') '\circ'])

      set(h1strike,'UserData',0)
end

% % if llimit1 < strike1
% % elseif llimit1 > strike1
% %  s1=llimit1(1)-varargin{3};
% %     
% % end
% 
% ud1=get(h1strike,'UserData');
% ud2=get(h2strike,'UserData');
% 
% if ud1 ==0 && ud2==0  % no calculations yet
%     % find left limit 
%    if s1~=0 
%     % calculate the right limit for strike1
%       rlimit1=strike1+(strike1-llimit1(1));
%     % plot another line
%       x=[rlimit1 rlimit1];
%       y=[0 varargin{5}];
%       line(x,y,'Color','y','LineWidth',3,'LineStyle','--');
%       set(h1strike,'UserData',1)
%       set(h2strike,'UserData',0)
%       set(h1text,'String', ['\pm' num2str(abs(s1),'%3.0f') '\circ'])
% 
%    elseif s2 ~=0
%     % find left limit 
% %      llimit1=get(h2strike,'XData');
%     % calculate the right limit for strike1
%       rlimit2=strike2-(llimit2(1)-strike2);
%     % plot another line
%       x=[rlimit2 rlimit2];
%       y=[0 varargin{5}];
%       line(x,y,'Color','g','LineWidth',3,'LineStyle','--');
%       set(h2strike,'UserData',1)
%       set(h1strike,'UserData',0)
%       set(h2text,'String', ['\pm' num2str(s2,'%3.0f') '\circ'])
%    else
%        disp('try again')
%    end
%    
% elseif ud1==0 && ud2==1  %strk2 was set
%     % calculate the right limit for strike1
%       rlimit1=strike1+(strike1-llimit1(1));
%     % plot another line
%       x=[rlimit1 rlimit1];
%       y=[0 varargin{5}];
%       line(x,y,'Color','y','LineWidth',3,'LineStyle','--');
%       set(h1strike,'UserData',1)
%       set(h1text,'String', ['\pm' num2str(abs(s1),'%3.0f') '\circ'])
%       
% elseif ud1==1 && ud2==0
%     % find left limit 
% %      llimit1=get(h2strike,'XData');
%     % calculate the right limit for strike1
%       rlimit2=strike2-(llimit2(1)-strike2);
%     % plot another line
%       x=[rlimit2 rlimit2];
%       y=[0 varargin{5}];
%       line(x,y,'Color','g','LineWidth',3,'LineStyle','--');
%       set(h2strike,'UserData',1)
%       set(h2text,'String', ['\pm' num2str(s2,'%3.0f') '\circ'])
% end

end  % end of stopDragFcn


end % end of main