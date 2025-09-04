function [a1,a2,a3,a4,a5,a6]=sdr2as(strike,dip,rake,xmoment)

  %  strike=deg2rad(strike);
 %	dip=deg2rad(dip);
 %	rake=deg2rad(rake);
%     
%   
%     strike=strike*pi2/180.
%  	dip=dip*pi2/180.
%  	rake=rake*pi2/180.
    
 	sd=sind(dip);
 	cd=cosd(dip);
 	sp=sind(strike);
 	cp=cosd(strike);
 	sl=sind(rake);
 	cl=cosd(rake);
    
 	s2p=2.0*sp*cp;
 	s2d=2.0*sd*cd;
 	c2p=(cp*cp)-(sp*sp);
 	c2d=(cd*cd)-(sd*sd);
  
    if (abs(c2d)==(eps))
        c2d=0;
    end
    
    if (abs(c2p)==(eps))
        c2p=0;
    end
 
 	xx1 =-(sd*cl*s2p + s2d*sl*sp*sp)*xmoment;     % Mxx
 	xx2 = (sd*cl*c2p + s2d*sl*s2p/2.0)*xmoment;    % Mxy
 	xx3 =-(cd*cl*cp  + c2d*sl*sp)*xmoment;        % Mxz
 	xx4 = (sd*cl*s2p - s2d*sl*cp*cp)*xmoment;     % Myy
 	xx5 =-(cd*cl*sp  - c2d*sl*cp)*xmoment;        % Myz
 	xx6 =             (s2d*sl)*xmoment;           % Mzz

 	a1 = xx2;
 	a2 = xx3;
 	a3 =-xx5;
 	a4 = (-2.0*xx1 + xx4 + xx6)/3.0;
 	a5 = (xx1 -2.0*xx4 + xx6)/3.0;
    a6 = 0.0;
    
% disp(['Strike= ' num2str(strike) ' Dip= ' num2str(dip) ' Rake= ' num2str(rake) ' Moment= ' num2str(xmoment)])
% disp(['a1  ' '  a2  ' '  a3  ' '  a4  ' '  a5  ' '  a6  '])
% disp(a1);disp(a2);disp(a3);disp(a4);disp(a5);disp(a6)

