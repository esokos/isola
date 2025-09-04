    function [x,y] = pltsym2(ain, az)
    
rad=pi/180;
cx=10;
cy=10;
rmax=5;         %circle radius   

      azr = az*rad;
      ainr = ain*rad;

      if ain >  90
        ainr = pi - ainr;
        azr = pi + azr;
        
      end 
      
      con = rmax*sqrt(2.0);
      r = con*sin(ainr*0.5);
      x = r*sin(azr) + cx;
      y = r*cos(azr) + cy;
