     function [x1,y1]=rotateisol(rot,x2,y2)

      x1=-y2*sin(rot)+x2*cos(rot);

      y1=y2*cos(rot)+x2*sin(rot);

      return

      end

%                      pointsXrot(j,i)=pointsX(j,i)*cos(radtheta)-pointsY(j,i)*sin(radtheta);
%                      pointsYrot(j,i)=pointsX(j,i)*sin(radtheta)+pointsY(j,i)*cos(radtheta);
% 