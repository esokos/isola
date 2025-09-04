%*****************************************************************************************
%*                                                                                       *
%*   nodal_lines.m                                                                       *
%*                                                                                       *
%*   function plots nodal lines in the lower-hemisphere equal-area projection            *
%*                                                                                       *
%*****************************************************************************************
function y = nodal_lines_(strike,dip,rake)

n_1(:,1) = -sin(dip*pi/180).*sin(strike*pi/180);
n_1(:,2) =  sin(dip*pi/180).*cos(strike*pi/180);
n_1(:,3) = -cos(dip*pi/180);

u_1(:,1) =  cos(rake*pi/180).*cos(strike*pi/180) + cos(dip*pi/180).*sin(rake*pi/180).*sin(strike*pi/180);
u_1(:,2) =  cos(rake*pi/180).*sin(strike*pi/180) - cos(dip*pi/180).*sin(rake*pi/180).*cos(strike*pi/180);
u_1(:,3) = -sin(rake*pi/180).*sin(dip*pi/180);

N = length(strike);

%----------------------------------------------------------------------------------------
% lower hemisphere equal-area projection
%----------------------------------------------------------------------------------------
projekce = -1;  
%----------------------------------------------------------------------------------------
% figure, title, boundary circle
% %----------------------------------------------------------------------------------------
% figure; hold on; axis equal; axis off; title('Nodal lines','FontSize',14);
% 
% Fi=0:0.2:360;
% plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k')
%----------------------------------------------------------------------------------------
% 1st nodal lines
%----------------------------------------------------------------------------------------
ksi_min = 0.1;
ksi_max = 360.1;
ksi_step = 1;

n = n_1;

for j = 1:N
    n1 = sqrt(n(j,1)^2+n(j,2)^2); n3 = n(j,3); m1 = n(j,1)/n1; m3 = n(j,2)/n1;
    if (n3<0) n3 = -n3; m1 = -m1; m3 = -m3; end   % the vertical component must be always negative!
    
    k = 1;
    for ksi=ksi_min:ksi_step:ksi_max;
        k1 = sin(ksi*pi/180); k3 = cos(ksi*pi/180);

        smer = -[- k1*m1*n3 + k3*m3, -(k1*m3*n3 + k3*m1),k1*n1];
        if(smer(3)<0)   % plot of one hemispehre only
            theta = acos(k1*n1)*180/pi;
            if (theta<1.e-6)    % theta must be non-zero
                fi = abs(atan(smer(:,1)/smer(:,2))*180/pi);
                sin_fi = signum(smer(:,1))*sin(fi);
                cos_fi = signum(smer(:,2))*cos(fi);
            else                
                sin_fi = smer(:,1)/sin(theta*pi/180);
                cos_fi = smer(:,2)/sin(theta*pi/180);
            end            
            x(k) = sqrt(2.)*projekce*sin(theta*pi/360).*cos_fi;
            y(k) = sqrt(2.)*projekce*sin(theta*pi/360).*sin_fi;
            
            if (k>1) 
                plot([x(k-1) x(k)],[y(k-1) y(k)],'k','LineWidth',1.0); 
            end
            k=k+1;
        else     
            k=1; 
        end
    end
end
%----------------------------------------------------------------------------------------
% 2nd nodal lines
%----------------------------------------------------------------------------------------
n = u_1;

for j = 1:N
    n1 = sqrt(n(j,1)^2+n(j,2)^2); n3 = n(j,3); m1 = n(j,1)/n1; m3 = n(j,2)/n1;
    if n3<0 n3 = -n3; m1 = -m1; m3 = -m3; end   % the vertical component must be always negative!
    
    k = 1;
    for ksi=ksi_min:ksi_step:ksi_max;
        k1 = sin(ksi*pi/180); k3 = cos(ksi*pi/180);

        smer = -[- k1*m1*n3 + k3*m3, -(k1*m3*n3 + k3*m1),k1*n1];
        if(smer(3)<0)   % plot of one hemisphere only
            theta = acos(k1*n1)*180/pi;
            if (theta<1.e-6)    % theta must be non-zero
                fi = abs(atan(smer(:,1)/smer(:,2))*180/pi);
                sin_fi = signum(smer(:,1))*sin(fi);
                cos_fi = signum(smer(:,2))*cos(fi);
            else                
                sin_fi = smer(:,1)/sin(theta*pi/180);
                cos_fi = smer(:,2)/sin(theta*pi/180);
            end            
            x(k) = sqrt(2.)*projekce*sin(theta*pi/360).*cos_fi;
            y(k) = sqrt(2.)*projekce*sin(theta*pi/360).*sin_fi;
            
            if (k>1) 
                plot([x(k-1) x(k)],[y(k-1) y(k)],'k','LineWidth',1.0); 
            end
            k=k+1;
        else     
            k=1; 
        end
    end
end

