function [x,y] = plpldc(strkdg,dpidg)
%% converted from fortran code...!!

if dpidg==90
    dpidg=89;
else
    
end

rad=pi/180;
cx=10;
cy=10;
rmax=5;         %circle radius   

      strkrd = deg2rad(strkdg);
      diprd =  deg2rad(dpidg);
      tpd = tan(pi*.5 - diprd)^2;
      
% c
% c case of vertical plane
% c
      if dpidg == 90.0
        x = rmax*sin(strkrd) + cx;
        y = rmax*cos(strkrd) + cy;

        x = rmax*sin(strkrd + pi) + cx;
        y = rmax*cos(strkrd + pi) + cy;
      end 
% c
% c compute angle of incidence, azimuth
% c

        for i = 1:90
        ang = (i - 1)*rad;
        arg = sqrt((cos(diprd)^2)*(sin(ang)^2))/cos(ang);
        saz(i) = atan(arg);
        taz = tan(saz(i))^2;
        arg = sqrt(tpd + tpd*taz + taz);
        ainp(i) = acos(tan(saz(i))/arg);
        end
      saz(91) = 90.*rad;
      ainp(91) = pi*.5 - diprd;
% c
% c plot plane
% c

      con = rmax*sqrt(2.);
for i=1:180
    
        if i <= 91 
          mi = i;
          az = saz(i) + strkrd;
        else
          mi = 181 - i;
          az = pi - saz(mi) + strkrd;
        end
        
        radius = con*sin(ainp(mi)*0.5);
        x(i) = radius*sin(az) + cx;
        y(i) = radius*cos(az) + cy;
%          if i ==1
%          x(i)=x;
%          y(i)=y;
%          else
%          x(i)=x;
%          y(i)=y;
%          end
end
        
