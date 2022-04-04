function [Xtotal,totaltf] = make_tr2(cent_time,ampl,dur)
% calculate coordinates of triangle edges based on x,y of base center
% area of each triangle is given in third column 
halfdur=dur/2;

% find a set of x,y coordinates that define the triangles 
for i=1:length(cent_time)
 
    vX(1)=cent_time(i)-halfdur; vY(1)=0; % define the coordinates of the triangle end points
    % calculate height of triangle based on area e.g. ampl(i)
    vX(2)=cent_time(i);         vY(2)=(2*ampl(i))/dur;    %vY(2)= ampl(i); 
    %
    vX(3)=cent_time(i)+halfdur; vY(3)=0;
    % discretize the triangle
    t=[vX(1) vX(2) vX(3)];    a=[vY(1) vY(2) vY(3)];
    x(i,:) = vX(1):0.01:vX(3); % ith triangle time
    y(i,:) = interp1(t,a,x(i,:));  % ith triangle ampl

end

%create line connecting
% figure
% plot(x(1),y(1),'o')
% hold
% for i=2:length(cent_time)
%       plot(x,y,'o')
% end
% tr=1;
% whos
% % 
% Ytotal=sum(y,2);
% 
% plot(Xtotal,Ytotal,'*')
% total_points=length(cent_time)*length(x);
%Xtotal=linspace(min(x(1,:)),max(x(12,:)),1201);

Xtotal=min(x(1,:)):0.01:max(x(60,:));

tf=0;
for p=1:length(Xtotal)
    
 for i=1:length(x)
    for j=1:length(cent_time) 
      if ((x(j,i) <= Xtotal(p)+.5) && (x(j,i) >= Xtotal(p)-.5))
          tf=tf+y(j,i);
      else
      end
    end

 end
    totaltf(p)=tf*0.01;
    tf=0;
end


% whos
% figure
% plot(Xtotal,totaltf)
% 


