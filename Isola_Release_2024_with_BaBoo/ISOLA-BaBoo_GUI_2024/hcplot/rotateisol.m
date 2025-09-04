%      function [x1,y1]=rotateisol(rot,x,y)
% 
%       y1=y*cos(rot)-x*sin(rot);
% 
%       x1=x*cos(rot)+y*sin(rot);
% 
%       return

     function [x1,y1]=rotateisol(rot,x2,y2)

      x1=-y2*sin(rot)+x2*cos(rot);

      y1=y2*cos(rot)+x2*sin(rot);

      return
