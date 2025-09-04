c      real strk,dip,rake


c      write(*,*) 'Strike,Dip, rake (deg)=?'
c      read(*,*) strk, dip, rake


c      call pl2pt(strike,dip,rake,trendp,plungp,trendt,plungt,
c     1trendb,plungb,ierr)

c      write(*,*)trendp,plungp,trendt,plungt

C
c      stop
c      end


      subroutine pl2pt(strike,dip,rake,trendp,plungp,trendt,plungt,
     1trendb,plungb,ierr)
c
c     compute trend and plunge of P, T and B axes
c     from strike, dip and rake of a nodal plane
c
c
c     usage:
c     call pl2pt(strike,dip,rake,trendp,plungp,trendt,plungt,trendb,plungb,ierr)
c
c     arguments:
c     strike         strike angle in degrees of the first nodal plane (INPUT)
c     dip            dip angle in degrees of the first nodal plane (INPUT)
c     rake           rake angle in degrees of the first nodal plane (INPUT)
c     trendp         trend of P axis (OUTPUT)
c     plungp         plunge or P axis (OUTPUT)
c     trendt         trend of T axis (OUTPUT)
c     plungt         plunge or T axis (OUTPUT)
c     trendb         trend of B axis (OUTPUT)
c     plungb         plunge or B axis (OUTPUT)
c     ierr           error indicator (OUTPUT)
c
c     errors:
c     1              input STRIKE angle out of range
c     2              input DIP angle out of range
c     4              input RAKE angle out of range
c     3              1+2
c     5              1+4
c     7              1+2+4
c     8,9,10,11      internal error
c
c      implicit none
c-------------------------------------------------------------------------------
      integer io
      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
     2,c3,io
c-------------------------------------------------------------------------------
      real strike,dip,rake,anx,any,anz,dx,dy,dz,px,py,pz,tx,ty,tz
     1,bx,by,bz,trendp,plungp,trendt,plungt,trendb,plungb
      integer ierr
c
      call fpsset
c
      call pl2nd(strike,dip,rake,anx,any,anz,dx,dy,dz,ierr)
      if(ierr.ne.0) then
         write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
         return
      endif
      call nd2pt(dx,dy,dz,anx,any,anz,px,py,pz,tx,ty,tz,bx,by,bz,ierr)
      if(ierr.ne.0) then
         ierr=8
         write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
      endif
      call ca2ax(px,py,pz,trendp,plungp,ierr)
      if(ierr.ne.0) then
         ierr=9
         write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
      endif
      call ca2ax(tx,ty,tz,trendt,plungt,ierr)
      if(ierr.ne.0) then
         ierr=10
         write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
      endif
      call ca2ax(bx,by,bz,trendb,plungb,ierr)
      if(ierr.ne.0) then
         ierr=11
         write(io,'(1x,a,i3)') 'PL2PT: ierr=',ierr
      endif
      return
      end



	      subroutine fpsset
c
c     define constants (i.e. input ranges and tolerances) used throughout the 
c     package. It is called by every subroutines to setup constants
c
c     usage:
c     call fpsset
c
c     constants in fpscom common block:
c     
c     amistr         strike lower limit 
c     amastr         strike upper limit 
c     amidip         dip lower limit 
c     amadip         dip upper limit 
c     amirak         rake lower limit 
c     amarak         rake upper limit 
c     amitre         trend lower limit 
c     amatre         trend upper limit 
c     amiplu         plunge lower limit 
c     amaplu         plunge upper limit 
c     orttol         orthogonality tolerance 
c     ovrtol         dip overtaking tolerance 
c     tentol         moment tensor symmetry tolerance
c     dtor	     degree to radians
c     c360	     360. 
c     c90            90.
c     c0             0.
c     c1             1.
c     c2             2.
c     c3             3.
c     io             error messages file unit
c
c      implicit none
c-------------------------------------------------------------------------------
      integer io
      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
     2,c3,io
c-------------------------------------------------------------------------------
      integer ifl
      save ifl
      data ifl/0/
      if(ifl.eq.0) then
         amistr=-360. 
         amastr=360.
         amidip=0.
         amadip=90.
         amirak=-360.
         amarak=360.
         amitre=-360.
         amatre=360.
         amiplu=0.
         amaplu=90.
         orttol=2.
         ovrtol=0.001
         tentol=0.0001
         dtor=0.017453292519943296
         c360=360.
         c90=90.
         c0=0.
         c1=1.
         c2=2.
         c3=3.
         io=6
         ifl=1
      endif
      return
      end



      subroutine pl2nd(strike,dip,rake,anx,any,anz,dx,dy,dz,ierr)
c
c     compute Cartesian components of outward normal and slip
c     vectors from strike, dip and rake 
c
c     usage:
c     call pl2nd(strike,dip,rake,anx,any,anz,dx,dy,dz,ierr)
c
c     arguments:
c     strike         strike angle in degrees (INPUT)
c     dip            dip angle in degrees (INPUT)
c     rake           rake angle in degrees (INPUT)
c     anx,any,anz    components of fault plane outward normal versor in the 
c                    Aki-Richards Cartesian coordinate system (OUTPUT)
c     dx,dy,dz       components of slip versor in the Aki-Richards 
c                    Cartesian coordinate system (OUTPUT)
c     ierr           error indicator (OUTPUT)
c
c     errors:
c     1              input STRIKE angle out of range
c     2              input DIP angle out of range
c     4              input RAKE angle out of range
c     3              1+2
c     5              1+4
c     7              1+2+4
c
c      implicit none
c-------------------------------------------------------------------------------
      integer io
      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
     2,c3,io
c-------------------------------------------------------------------------------
      real anx,any,anz,dx,dy,dz,strike,dip,rake,wstrik,wdip,wrake
      integer ierr
c
      call fpsset
c
      anx=c0
      any=c0
      anz=c0
      dx=c0
      dy=c0
      dz=c0
      ierr=0
      if(strike.lt.amistr.or.strike.gt.amastr) then
         write(io,'(1x,a,g10.3,a)') 'PL2ND: input STRIKE angle ',strike,
     1   ' out of range'
         ierr=1
      endif
      if(dip.lt.amidip.or.dip.gt.amadip) then
         if(dip.lt.amadip.and.dip.gt.-ovrtol) then
            dip=amidip
         else if(dip.gt.amidip.and.dip-amadip.lt.ovrtol) then
            dip=amadip
         else
            write(io,'(1x,a,g10.3,a)') 'PL2ND: input DIP angle ',dip,
     1      ' out of range'
            ierr=ierr+2
         endif
      endif
      if(rake.lt.amirak.or.rake.gt.amarak) then
         write(io,'(1x,a,g10.3,a)') 'PL2ND: input RAKE angle ',rake,
     1   ' out of range'
         ierr=ierr+4
      endif
      if(ierr.ne.0) return
      wstrik=strike*dtor
      wdip=dip*dtor
      wrake=rake*dtor
c
      anx=-sin(wdip)*sin(wstrik)
      any=sin(wdip)*cos(wstrik)
      anz=-cos(wdip)
      dx=cos(wrake)*cos(wstrik)+cos(wdip)*sin(wrake)*sin(wstrik)
      dy=cos(wrake)*sin(wstrik)-cos(wdip)*sin(wrake)*cos(wstrik)
      dz=-sin(wdip)*sin(wrake)
      return
      end


      subroutine nd2pt(wanx,wany,wanz,wdx,wdy,wdz,px,py,pz,tx,ty,tz,bx
     1,by,bz,ierr)
c
c     compute Cartesian component of P, T and B axes from outward normal
c     and slip vectors
c
c     usage:
c     call nd2pt(anx,any,anz,dx,dy,dz,px,py,pz,tx,ty,tz,bx,by,bz,ierr)
c
c     arguments:
c     anx,any,anz    components of fault plane outward normal vector in the 
c                    Aki-Richards Cartesian coordinate system (INPUT)
c     dx,dy,dz       components of slip vector in the Aki-Richards 
c                    Cartesian coordinate system (INPUT)
c     px,py,pz       components of downward P (maximum dilatation) axis versor 
c                    in the Aki-Richards Cartesian coordinate system (OUTPUT)
c     tx,ty,tz       components of downward T (maximum tension) axis versor 
c                    in the Aki-Richards Cartesian coordinate system (OUTPUT)
c     bx,by,bz       components of downward B (neutral) axis versor in the 
c                    Aki-Richards Cartesian coordinate system (OUTPUT)
c     ierr           error indicator (OUTPUT)
c
c     errors:
c     1              input vectors not perpendicular among each other
c
c      implicit none
c-------------------------------------------------------------------------------
      integer io
      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
     2,c3,io
c-------------------------------------------------------------------------------
      real wanx,wany,wanz,amn,anx,any,anz,wdx,wdy,wdz,amd,dx,dy,dz
     1,ang,px,py,pz,tx,ty,tz,bx,by,bz,amp
      integer ierr
c
      call fpsset
c
      ierr=0
      call norm(wanx,wany,wanz,amn,anx,any,anz)
      call norm(wdx,wdy,wdz,amd,dx,dy,dz)
      call angle(anx,any,anz,dx,dy,dz,ang)
      if(abs(ang-c90).gt.orttol) then
         write(io,'(1x,a,g15.7,a)') 'ND2PT: input vectors not '
     1   //'perpendicular, angle=',ang
         ierr=1
      endif
      px=anx-dx
      py=any-dy
      pz=anz-dz
      call norm(px,py,pz,amp,px,py,pz)
      if(pz.lt.c0) call invert(px,py,pz)
      tx=anx+dx
      ty=any+dy
      tz=anz+dz
      call norm(tx,ty,tz,amp,tx,ty,tz)
      if(tz.lt.c0) call invert(tx,ty,tz)
      call vecpro(px,py,pz,tx,ty,tz,bx,by,bz)
      if(bz.lt.c0) call invert(bx,by,bz)
      return
      end

      subroutine ca2ax(wax,way,waz,trend,plunge,ierr)
c
c     compute trend and plunge from Cartesian components
c
c     usage:
c     call ca2ax(ax,ay,az,trend,plunge,ierr)
c
c     arguments:
c     ax,ay,az       components of axis direction vector in the Aki-Richards 
c                    Cartesian coordinate system (INPUT)
c     trend          clockwise angle from North in degrees (OUTPUT)
c     plunge         inclination angle in degrees (OUTPUT)
c     ierr           error indicator (OUTPUT)
c
c     errors:
c
c      implicit none
c-------------------------------------------------------------------------------
      integer io
      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
     2,c3,io
c-------------------------------------------------------------------------------
      real wax,way,waz,wnorm,ax,ay,az,trend,plunge
      integer ierr
c
      call fpsset
c
      ierr=0
      call norm(wax,way,waz,wnorm,ax,ay,az)
      if(az.lt.c0) call invert(ax,ay,az)
      if(ay.ne.c0.or.ax.ne.c0) then
         trend=atan2(ay,ax)/dtor
      else
         trend=c0
      endif
      trend=mod(trend+c360,c360)
      plunge=asin(az)/dtor
      return
      end


      subroutine norm(wax,way,waz,anorm,ax,ay,az)
c
c     compute euclidean norm and versor components 
c
c     usage:
c     call norm(wax,way,waz,anorm,ax,ay,az)
c
c     arguments:
c     wax,way,waz    Cartesian component of input vector (INPUT)
c     anorm          Euclidean norm of input vector (OUTPUT)
c     ax,ay,az       normalized Cartesian component of the vector (OUTPUT)
c
c      implicit none
c-------------------------------------------------------------------------------
      integer io
      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
     2,c3,io
c-------------------------------------------------------------------------------
      real wax,way,waz,anorm,ax,ay,az
c
      call fpsset
c
      anorm=sqrt(wax*wax+way*way+waz*waz)
      if(anorm.eq.c0) return
      ax=wax/anorm
      ay=way/anorm
      az=waz/anorm
      return
      end


      subroutine vecpro(px,py,pz,tx,ty,tz,bx,by,bz)
c
c     compute vector products of two vectors
c
c     usage:
c     call vecpro(px,py,pz,tx,ty,tz,bx,by,bz)
c
c     arguments:
c
c     px,py,pz       Cartesian component of first vector (INPUT)
c     tx,ty,tz       Cartesian component of second vector (INPUT)
c     bx,by,bz       Cartesian component of vector product (OUTUT)
c
c      implicit none
c-------------------------------------------------------------------------------
      integer io
      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
     2,c3,io
c-------------------------------------------------------------------------------
      real px,py,pz,tx,ty,tz,bx,by,bz
c
      call fpsset
c
      bx=py*tz-pz*ty
      by=pz*tx-px*tz
      bz=px*ty-py*tx
      return
      end


      subroutine invert(ax,ay,az)
c
c     invert vector 
c
c     usage:
c     utility routine for internal use only 
c
c      implicit none
c-------------------------------------------------------------------------------
      integer io
      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
     2,c3,io
c-------------------------------------------------------------------------------
      real ax,ay,az
c
      call fpsset
c
      ax=-ax
      ay=-ay
      az=-az
      return
      end

      subroutine angle(wax,way,waz,wbx,wby,wbz,ang)
c
c     compute the angle (in degrees) between two vectors
c
c     usage:
c     call angle(wax,way,waz,wbx,wby,wbz,ang)
c
c     arguments:
c     wax,way,waz    Cartesian component of first vector (INPUT)
c     wbx,wby,wbz    Cartesian component of second vector (INPUT)
c     ang            angle between the two vectors in degrees (OUTPUT)
c
c      implicit none
c-------------------------------------------------------------------------------
      integer io
      real amistr,amastr,amidip,amadip,amirak,amarak,amitre,amatre
     1,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2,c3
      common /fpscom/amistr,amastr,amidip,amadip,amirak,amarak,amitre
     1,amatre,amiplu,amaplu,orttol,ovrtol,tentol,dtor,c360,c90,c0,c1,c2
     2,c3,io
c-------------------------------------------------------------------------------
      real wax,way,waz,wbx,wby,wbz,ax,ay,az,bx,by,bz,ang
     1,anorm,bnorm,prod
c
      call fpsset
c
      call norm(wax,way,waz,anorm,ax,ay,az)
      call norm(wbx,wby,wbz,bnorm,bx,by,bz)
      prod=ax*bx+ay*by+az*bz
      ang=acos(max(-c1,min(c1,prod)))/dtor
      return
      end
