%*************************************************************************%
%                                                                         % 
%   copyright:                                                            %
%   The rights to the original software are owned by V. Vavrycuk. The code%
%   can be freely used for research purposes. The use of the software for %
%   commercial purposes with no commercial licence is prohibited.         %
%                                                                         %
%   Revision 7/2018 by Miroslav Hallo - mechanism class by Frohlich 1992  %
%                                                                         %
%*************************************************************************%


function [mClass,dP,dT,dB] = mechClass(strike,dip,rake)
% mClass is flag of the mechanism, 1:strike-slip, 2:normal, 3:reverse
% dP,dT,dB are dip angles from horizontal of P, T and N axis respectivelly

%--------------------------------------------------------------------------
% P/T axes
%--------------------------------------------------------------------------

n_1(:,1) = -sin(dip*pi/180).*sin(strike*pi/180);
n_1(:,2) =  sin(dip*pi/180).*cos(strike*pi/180);
n_1(:,3) = -cos(dip*pi/180);

u_1(:,1) =  cos(rake*pi/180).*cos(strike*pi/180) + cos(dip*pi/180).*sin(rake*pi/180).*sin(strike*pi/180);
u_1(:,2) =  cos(rake*pi/180).*sin(strike*pi/180) - cos(dip*pi/180).*sin(rake*pi/180).*cos(strike*pi/180);
u_1(:,3) = -sin(rake*pi/180).*sin(dip*pi/180);

N = length(strike);

% Allocate
P_osa = zeros(N,3);
T_osa = zeros(N,3);
P_azimuth = zeros(N,1);
T_azimuth = zeros(N,1);
P_theta = zeros(N,1);
T_theta = zeros(N,1);
mClass = zeros(N,1);

% Compute all angles
for i=1:N
    P_osa(i,:) = (n_1(i,:)-u_1(i,:))/norm(n_1(i,:)-u_1(i,:));
    T_osa(i,:) = (n_1(i,:)+u_1(i,:))/norm(n_1(i,:)+u_1(i,:));
    
    if (P_osa(i,3)>0), P_osa(i,1)=-P_osa(i,1); P_osa(i,2)=-P_osa(i,2); P_osa(i,3)=-P_osa(i,3); end
    if (T_osa(i,3)>0), T_osa(i,1)=-T_osa(i,1); T_osa(i,2)=-T_osa(i,2); T_osa(i,3)=-T_osa(i,3); end

    fi = atan(abs(P_osa(i,1)./P_osa(i,2)))*180/pi;

    if (P_osa(i,1)>0 && P_osa(i,2)>0), P_azimuth(i) = fi;     end  % 1. kvadrant
    if (P_osa(i,1)>0 && P_osa(i,2)<0), P_azimuth(i) = 180-fi; end  % 2. kvadrant
    if (P_osa(i,1)<0 && P_osa(i,2)<0), P_azimuth(i) = fi+180; end  % 3. kvadrant
    if (P_osa(i,1)<0 && P_osa(i,2)>0), P_azimuth(i) = 360-fi; end  % 4. kvadrant

    P_theta(i) = acos(abs(P_osa(i,3)))*180/pi;

    fi = atan(abs(T_osa(i,1)/T_osa(i,2)))*180/pi;

    if (T_osa(i,1)>0 && T_osa(i,2)>0), T_azimuth(i) = fi;     end  % 1. kvadrant
    if (T_osa(i,1)>0 && T_osa(i,2)<0), T_azimuth(i) = 180-fi; end  % 2. kvadrant
    if (T_osa(i,1)<0 && T_osa(i,2)<0), T_azimuth(i) = fi+180; end  % 3. kvadrant
    if (T_osa(i,1)<0 && T_osa(i,2)>0), T_azimuth(i) = 360-fi; end  % 4. kvadrant

    T_theta(i) = acos(abs(T_osa(i,3)))*180/pi;
    
    % Get mechanism class
    dT = 90-T_theta(i);
    dP = 90-P_theta(i);
    dB = asind(real(sqrt(1 - sind(dT)^2 - sind(dP)^2)));
    
    if sind(dB)^2 > 0.75 % Strike-slip
        mClass(i) = 1;
    elseif sind(dP)^2 > 0.75 % Normal
        mClass(i) = 2;
    elseif sind(dT)^2 > 0.59 % Reverse
        mClass(i) = 3;
    else
        mClass(i) = 0;
    end
end


end
