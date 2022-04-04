%*****************************************************************************************
%*                                                                                       *
%*   P_T_axes.m                                                                          *
%*                                                                                       *
%*   function plots P and T axes in the lower-hemisphere equal-area projection           *
%*                                                                                       *
%*****************************************************************************************
function y = P_T_axes_(strike,dip,rake)

n_1(:,1) = -sin(dip*pi/180).*sin(strike*pi/180);
n_1(:,2) =  sin(dip*pi/180).*cos(strike*pi/180);
n_1(:,3) = -cos(dip*pi/180);

u_1(:,1) =  cos(rake*pi/180).*cos(strike*pi/180) + cos(dip*pi/180).*sin(rake*pi/180).*sin(strike*pi/180);
u_1(:,2) =  cos(rake*pi/180).*sin(strike*pi/180) - cos(dip*pi/180).*sin(rake*pi/180).*cos(strike*pi/180);
u_1(:,3) = -sin(rake*pi/180).*sin(dip*pi/180);

N = length(strike);
%----------------------------------------------------------------------------------------
% figure, title, boundary circle
%----------------------------------------------------------------------------------------
% %figure; hold on; axis equal; axis off; title('P/T axes','FontSize',14);
% 
% Fi=0:0.1:360;
% plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k')
%----------------------------------------------------------------------------------------
% lower hemisphere equal-area projection
%----------------------------------------------------------------------------------------
projekce = -1;  

%----------------------------------------------------------------------------------------
% figure, title, boundary circle
%----------------------------------------------------------------------------------------
% figure; hold on; axis equal; axis off; title ('P(o)/T(+) axes','FontSize',14);
%  
% Fi=0:365;
% plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k')

%----------------------------------------------------------------------------------------
% P/T axes
%----------------------------------------------------------------------------------------
for i=1:N;
    P_osa(i,:) = (n_1(i,:)-u_1(i,:))/norm(n_1(i,:)-u_1(i,:));
    T_osa(i,:) = (n_1(i,:)+u_1(i,:))/norm(n_1(i,:)+u_1(i,:));
    
    if (P_osa(i,3)>0) P_osa(i,1)=-P_osa(i,1); P_osa(i,2)=-P_osa(i,2); P_osa(i,3)=-P_osa(i,3); end
    if (T_osa(i,3)>0) T_osa(i,1)=-T_osa(i,1); T_osa(i,2)=-T_osa(i,2); T_osa(i,3)=-T_osa(i,3); end

    fi = atan(abs(P_osa(i,1)./P_osa(i,2)))*180/pi;

    if (P_osa(i,1)>0 & P_osa(i,2)>0) P_azimuth(i) = fi;     end  % 1. kvadrant
    if (P_osa(i,1)>0 & P_osa(i,2)<0) P_azimuth(i) = 180-fi; end  % 2. kvadrant
    if (P_osa(i,1)<0 & P_osa(i,2)<0) P_azimuth(i) = fi+180; end  % 3. kvadrant
    if (P_osa(i,1)<0 & P_osa(i,2)>0) P_azimuth(i) = 360-fi; end  % 4. kvadrant

    P_theta(i) = acos(abs(P_osa(i,3)))*180/pi;

    fi = atan(abs(T_osa(i,1)/T_osa(i,2)))*180/pi;

    if (T_osa(i,1)>0 & T_osa(i,2)>0) T_azimuth(i) = fi;     end  % 1. kvadrant
    if (T_osa(i,1)>0 & T_osa(i,2)<0) T_azimuth(i) = 180-fi; end  % 2. kvadrant
    if (T_osa(i,1)<0 & T_osa(i,2)<0) T_azimuth(i) = fi+180; end  % 3. kvadrant
    if (T_osa(i,1)<0 & T_osa(i,2)>0) T_azimuth(i) = 360-fi; end  % 4. kvadrant

    T_theta(i) = acos(abs(T_osa(i,3)))*180/pi;

    P_x(i) = sqrt(2.)*projekce*sin(P_theta(i)*pi/360).*sin(P_azimuth(i)*pi/180);
    P_y(i) = sqrt(2.)*projekce*sin(P_theta(i)*pi/360).*cos(P_azimuth(i)*pi/180);

    T_x(i) = sqrt(2.)*projekce*sin(T_theta(i)*pi/360).*sin(T_azimuth(i)*pi/180);
    T_y(i) = sqrt(2.)*projekce*sin(T_theta(i)*pi/360).*cos(T_azimuth(i)*pi/180);

end

plot(P_y,P_x,'go','MarkerSize',10,'LineWidth',1.5);
text(P_y+0.07,P_x+0.07,'P','FontSize',16)
plot(T_y,T_x,'g+','MarkerSize',10,'LineWidth',1.5);
text(T_y+0.06,T_x+0.06,'T','FontSize',16)