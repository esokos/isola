function [strikb,dipb,rakeb] = pl2pl(strika,dipa,rakea)
%       based of fpspack....
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

         [anx,any,anz,dx,dy,dz]=pl2nd(strika,dipa,rakea);

%       if(ierr.ne.0) then
%          write(io,'(1x,a,i3)') 'PL2PL: ierr=',ierr
%          return
%       endif
      
%    call nd2pl(dx,dy,dz,anx,any,anz,,ierr)

[strikb,dipb,rakeb,dipdib]=nd2pl(dx,dy,dz,anx,any,anz);
      
      round(strikb);
      round(dipb);
      round(rakeb);
     
%       if(ierr.ne.0) then
%          ierr=8
%          write(io,'(1x,a,i3)') 'PL2PL: ierr=',ierr
%       endif
%       return
%       end
%[trendp,plungp,trendt,plungt,trendb,plungb]=pl2pt(strikb,dipb,rakeb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [anx,any,anz,dx,dy,dz] =pl2nd(strike,dip,rake)
%      
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;
%
      anx=c0;
      any=c0;
      anz=c0;
      dx=c0;
      dy=c0;
      dz=c0;
      ierr=0;
 
%       if(strike.lt.amistr.or.strike.gt.amastr) then
%          write(io,'(1x,a,g10.4,a)') 'PL2ND: input STRIKE angle ',strike,
%      1   ' out of range'
%          ierr=1
%       endif
%       if(dip.lt.amidip.or.dip.gt.amadip) then
%          if(dip.lt.amadip.and.dip.gt.-ovrtol) then
%             dip=amidip
%          else if(dip.gt.amidip.and.dip-amadip.lt.ovrtol) then
%             dip=amadip
%          else
%             write(io,'(1x,a,g10.4,a)') 'PL2ND: input DIP angle ',dip,
%      1      ' out of range'
%             ierr=ierr+2
%          endif
%       endif
%       if(rake.lt.amirak.or.rake.gt.amarak) then
%          write(io,'(1x,a,g10.4,a)') 'PL2ND: input RAKE angle ',rake,
%      1   ' out of range'
%          ierr=ierr+4
%       endif
%       if(ierr.ne.0) return
          
      wstrik=strike*dtor;
      wdip=dip*dtor;
      wrake=rake*dtor;
 
      anx=-sin(wdip)*sin(wstrik);
      any=sin(wdip)*cos(wstrik);
      anz=-cos(wdip);
      dx=cos(wrake)*cos(wstrik)+cos(wdip)*sin(wrake)*sin(wstrik);
      dy=cos(wrake)*sin(wstrik)-cos(wdip)*sin(wrake)*cos(wstrik);
      dz=-sin(wdip)*sin(wrake);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [phi,delta,alam,dipdir]=nd2pl(anx,any,anz,dx,dy,dz)
% subroutine nd2pl(wanx,wany,wanz,wdx,wdy,wdz,phi,delta,alam,dipdir
%  
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

     ang=fangle(anx,any,anz,dx,dy,dz);
      
      if (abs(ang-c90)> orttol)
         disp('ND2PL: input vectors not perpendicular, angle=')
     end
     
      [wanx,wany,wanz,anorm]= fnorm(anx,any,anz);
      
      [wdx,wdy,wdz,dnorm]=fnorm(dx,dy,dz);
           
      if(anz > c0) 
          
         [anx,any,anz]=finvert(anx,any,anz);
         [dx,dy,dz] =finvert(dx,dy,dz);
         
     end
 
      if(anz == -c1)
         wdelta=c0;
         wphi=c0;
         walam=atan2(-dy,dx);
      else
         wdelta=acos(-anz);
         wphi=atan2(-anx,any);
         walam=atan2(-dz/sin(wdelta),dx*cos(wphi)+dy*sin(wphi));
     end
     
     phi=wphi/dtor;
      delta=wdelta/dtor;
      alam=walam/dtor;
      phi=mod(phi+c360,c360);
      dipdir=phi+c90;
      dipdir=mod(dipdir+c360,c360);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [anorm,ax,ay,az]=fnorm(wax,way,waz)
%c
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

      anorm=sqrt(wax*wax+way*way+waz*waz);
      
      if(anorm == c0) return
      end
      ax=wax/anorm;
      ay=way/anorm;
      az=waz/anorm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ang = fangle(wax,way,waz,wbx,wby,wbz)
% c
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

%c
      [anorm,ax,ay,az]=fnorm(wax,way,waz);
      [bnorm,bx,by,bz]=fnorm(wbx,wby,wbz);
      prod=ax*bx+ay*by+az*bz;
      ang=acos(max(-c1,min(c1,prod)))/dtor;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function[iax,iay,iaz] = finvert(ax,ay,az)
% c
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;
%
      iax=-ax;
      iay=-ay;
      iaz=-az;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [trendp,plungp,trendt,plungt,trendb,plungb]=pl2pt(strike,dip,rake)
%  
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

%      call pl2nd(strike,dip,rake,anx,any,anz,dx,dy,dz,ierr)
      [anx,any,anz,dx,dy,dz]=pl2nd(strike,dip,rake);
%       if(ierr.ne.0) then
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%          return
%       endif
      
%   call nd2pt(dx,dy,dz,anx,any,anz,px,py,pz,tx,ty,tz,bx,by,bz,ierr)
      
      [px,py,pz,tx,ty,tz,bx,by,bz]=nd2pt(anx,any,anz,dx,dy,dz);

%       if(ierr.ne.0) then
%          ierr=8
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%       endif

%call ca2ax(px,py,pz,trendp,plungp,ierr)
[trendp,plungp]=ca2ax(px,py,pz);

% if(ierr.ne.0) then
%          ierr=9
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%       endif

  %    call ca2ax(tx,ty,tz,trendt,plungt,ierr)

[trendt,plungt]=ca2ax(tx,ty,tz);

%       if(ierr.ne.0) then
%          ierr=10
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%       endif
      
%call ca2ax(bx,by,bz,trendb,plungb,ierr)
[trendb,plungb]=ca2ax(bx,by,bz);

%       if(ierr.ne.0) then
%          ierr=11
%          write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
%       endif
%       return
%       end

      function [trend,plunge]=ca2ax(wax,way,waz)
% c     compute trend and plunge from Cartesian components
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

      ierr=0;
%      call norm(wax,way,waz,wnorm,ax,ay,az)
       [wnorm,ax,ay,az]=fnorm(wax,way,waz);
      if(az < c0) 
%      invert(ax,ay,az)
      [ax,ay,az]=finvert(ax,ay,az);
      end
%      
      if(ay ~= c0 || ax ~= c0) 
         trend=atan2(ay,ax)/dtor;
      else
         trend=c0;
     end
      trend=mod(trend+c360,c360);
      plunge=asin(az)/dtor;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [px,py,pz,tx,ty,tz,bx,by,bz]=nd2pt(wanx,wany,wanz,wdx,wdy,wdz)
% 
%   compute Cartesian component of P, T and B axes from outward normal and slip vectors
%      
         amistr=-360. ;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

      ierr=0;

   %   call norm(wanx,wany,wanz,amn,anx,any,anz)
        
      [amn,anx,any,anz]=fnorm(wanx,wany,wanz);
        
   %   call norm(wdx,wdy,wdz,amd,dx,dy,dz)
      
      [amd,dx,dy,dz]=fnorm(wdx,wdy,wdz);
      
     %call angle(anx,any,anz,dx,dy,dz,ang)
      ang=fangle(anx,any,anz,dx,dy,dz);
      
      
%       if(abs(ang-c90).gt.orttol) then
%          write(io,'(1x,a,g15.7,a)') 'ND2PT: input vectors not '
%      1   //'perpendicular, angle=',ang
%          ierr=1
%       endif

      px=anx-dx;
      py=any-dy;
      pz=anz-dz;

%      call norm(px,py,pz,amp,px,py,pz)
      
      [amp,px,py,pz]=fnorm(px,py,pz);
      
      
      if(pz < c0) 
      
%          call invert(px,py,pz)
        [px,py,pz]=finvert(px,py,pz);
        
      end
      
      tx=anx+dx;
      ty=any+dy;
      tz=anz+dz;
     
%      call norm(tx,ty,tz,amp,tx,ty,tz)
        
      [amp,tx,ty,tz]=fnorm(tx,ty,tz);
        
      
      if(tz < c0) 
         % call invert(tx,ty,tz)
          [tx,ty,tz]=finvert(tx,ty,tz);
      end
      
 %     call vecpro(px,py,pz,tx,ty,tz,bx,by,bz)
      [bx,by,bz]=vecpro(px,py,pz,tx,ty,tz);
      if(bz < c0) 
          
      %    call invert(bx,by,bz)
          [bx,by,bz]=finvert(bx,by,bz);
      
      end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bx,by,bz]=vecpro(px,py,pz,tx,ty,tz)
% c     compute vector products of two vectors
%   
         amistr=-360.;
         amastr=360.;
         amidip=0.;
         amadip=90.;
         amirak=-360.;
         amarak=360.;
         amitre=-360.;
         amatre=360.;
         amiplu=0.;
         amaplu=90.;
         orttol=2.;
         ovrtol=0.001;
         tentol=0.0001;
         dtor=0.017453292519943296;
         c360=360.;
         c90=90.;
         c0=0.;
         c1=1.;
         c2=2.;
         c3=3.;
         io=6;
         ifl=1;

      bx=py*tz-pz*ty;
      by=pz*tx-px*tz;
      bz=px*ty-py*tx;
