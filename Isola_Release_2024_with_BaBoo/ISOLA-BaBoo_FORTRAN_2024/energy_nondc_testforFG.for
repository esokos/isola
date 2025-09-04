      program ENERGY_SVSH_v04
c some options on  line 159  
c  t* = tstar is calculated from S-wave traveltime and Q; Q is read from eneinp0.dat
c [can be also read as station dependent if writing suchg a code version]

c  eneinp0.dat ... reading global parameters
c  eneinp1.dat ....reading station parameters

c Energy from S waves
c Calculation in spectral domain
c Including radiation pattern (optionally)
c Free-surface factor 2 is used

c Input:  *raw.dat files from Isola2024
c (=records instrumentally corrected to VELOCITY, sampled 1024 points, start at origin time) 

c Author: J. Zahradnik 2017, 2024

      dimension x(1024),y(1024),z(1024),tim(1024)
      dimension xr(1024),xt(1024),xsv(1024),xsh(1024)
      dimension xx(1024),yy(1024),zz(1024),x3com(1024)
      dimension aspx(513),aspy(513),aspz(513) ! amplitude spectra of velocity 
      dimension aspx2(513),aspy2(513),aspz2(513),asp2(513)
      dimension asp2smoo(513)  
      dimension asp3com(513),asp3com2(513) ! amplitude spectrum of absolute velocity, and its square 
      dimension outspecS(100,513),outspecSV(100,513),outspecSH(100,513) ! amplitude spectrum as a function of station and frequency 
      character*5 statname(100)
c      character *17 statfil1, statfil2,statfil3
      
      character *17 statfil1
      character *17 statfil2,statfil3
	  
      dimension xdist(100),xazim(100),xtake(100)
      dimension	spredp(100),tstarst(100)
      dimension pobs(100),scom(100),pdursyn(100),pdurobs(100)
      dimension ep(100),es(100),devi(100)
      open(105,file='eneinp0.dat') ! inpup: s/d/r, velocities, ... method,...Q 
      open(110,file='eneinp1.dat') ! input: azimuths, takeof ...
      open(115,file='eneinp2.dat') ! input: DC, CLVD, ISO, angle gamma with sign (between slip and fault) 	  
      open(200,file='eneout0.dat') ! output: stations' energy values
      open(201,file='eneout1.dat') ! output: aux for plot (mean and sigmas)
      open(210,file='eneout2.dat') ! output: summary with additional parameters (stress drop, efficiency...)
      open(215,file='eneout3.dat') ! output: rad. pat. squared [P, S, SH, SV]
      open(216,file='eneout4.dat') ! output: rad. pat. (non squared; with sign)

c      open(220,file='eneout5.dat')
      open(230,file='integrand.dat')
      open(235,file='spectra.dat')


	  pi=3.141592

c********************************************************** 
c    Reading eneinp2.dat  ...for non-DC
c**********************************************************      
      read(115, *) ! header
      read(115, *) pDC,pCLVD,pISO,gammadeg_given! percentages and |angle| (sign of gamma must be that CLVD) 
       if(abs(pCLVD).gt.1.) then   
       xkappa=(4./3.)*(pISO/pCLVD - 1./2.) ! xkappa is lambda/mu; gamma is angle between slip and fault
       else
	   write(*,*) 'Low CLVD and STOP the code'; STOP
       endif	   
      close(115)
c       xkappa=0.2

      sigma_source= xkappa / 2. / (xkappa +1) ! Poisson ratio in source

       
	   znam=sign(1.,pCLVD)
       gamma=znam*asin( (100.-pDC)/(100. + pDC*(xkappa+1.)) )      ! asin gives gamma in radiand	  
       gammadeg=gamma*180./pi ! in degrees
       gammadeg_xkappa=gammadeg 	   
c Because ISO and CLVD may give strange xkappa, and then strange gamma 
c it is perhaps better to specifu directly gamma [and vary it].	   
c Rad.patt of S, SH, SV depends on gamma, but does not depend on xkappa.

c      ALTERNATIVES 
       gammadeg=gammadeg_given  ! read from eneinp2.dat inlcuding correct sign
       
c      CHOOSING one alternative  here. Fixed now !!!   
c       gammadeg=gammadeg_xkappa
        gammadeg=gammadeg_given

	   gamma=gammadeg*pi/180. ! radians
      write(*,*) 'pDC,pCLVD,pISO:', pDC, pCLVD, pISO	   
c      write(*,*) 'pCLVD, sign of CLVD: ', pCLVD, znam       
      write(*,*) 'xkappa= ', xkappa
c      write(*,*) 'Poisson_source= ',sigma_source       
c      write(*,*)  'Rad.patt. of S depends on gamma, not on Poisson'      
      write(*,*) 'gammadeg_xkappa= ', gammadeg_xkappa      
      write(*,*) 'gammadeg_given= ', gammadeg_given      
      write(*,*) 'CHOSEN gammadeg= ', gammadeg     
      write(*,*) 

c********************************************************** 
c    Reading eneinp0.dat 
c**********************************************************      
      read(105, *)
      read(105, *)
      read(105, *) TWL,istr,idip,irak,depth,
     *	  vp0,vs0,rho0, vp1,vs1,rho1,swin, 
     *	  fc, xmom, radius,keyradpat,keywavetype,Qconst
c TWL    istr idip irak  depth VPource VSsource RHOsource VPsurf VSsurf RHOsurf Swin Corner_freq Moment Radius KEYradp
c s      deg  deg  deg    km      km/s km/s g/cm3   km/s km/s g/cm3              s       Hz      Nm     km    none
c TWL time window length of Isola 
c istr, idip, irak ... strike,dip, rake angles (integers)
c Swin ... S-wave window length (starts 15 before S arrival)
c Corner freq (Hz) ... here taken as all-station estimate
c KEYradpat 0 if not used, 1 if used
c KEYwavetype see line 313
c Qconst is station-independent Q; t* calculated from this and traveltime
      close(105)

      write(*,*) 'Input data (eneinp0.dat):'      
      write(*,*) TWL,istr,idip,irak,depth,
     *	  vp0,vs0,rho0, vp1,vs1,rho1,swin,
     *	  fc, xmom, radius,keyradpat,keywavetype,Qconst
      write(*,*)      

      vpvsratio=vp0/vs0; vpvsratio2= vpvsratio**2. 
      sigma_seismic= (vpvsratio2 - 2.)/2./(vpvsratio2 - 1.) ! sigma is Poisson ratio; traditional seismic vlaue
             ! this is not Poisson corresponding to kappa (from ISO and CLVD); Kwiatek 2013 reasoning	  
c       sigma=0.25
      write(*,*) 'Poisson_seismic= ', sigma_seismic

c      CHOOSING one alternative  of SIFMA (Poisson) here.                 Fixed now !!!	  
      sigma=sigma_seismic ! Only Rad.pat of P depend on sigma (and gamma)	  
c       sigma=sigma_source   ! Only Rad.pat of P depend on sigma (and gamma)
c      sigma=0.25
c Observed P polarity can be explained by high gamma angles when comobined with sigma_source
c (rad pat of P depends on sigma). S pattern does not depend on sigma.


      write(*,*) 'Poisson_source= ',sigma_source       
      write(*,*) 'Poisson final choice= ', sigma
      write(*,*) 'Rad.patt. of S,SH,SV does not depend on Poisson!'
	  
	  
      write(*,*)
	  
cccccccccccccccccccccccc
c      tstarst=tstarconst       ! FIXED if later read for each station, then updated
c      write(*,*) tstarst
cccccccccccccccccccccccc
 

      NI=10 ! (assumes 1024 points) 
      NT=2**NI  
	  dt=TWL/(float(NT)) !  !!!!!!!!!!!!! FIXED due to 1024 !!
      NP=NT     
      NT2=NT/2
      NTM=NT2+1
      NTT=NT+2
      DF=1./(DT*FLOAT(NT))
      FMAX=FLOAT(NTM)*DF
	  
      str=float(istr)*pi/180. ! radians
      dip=float(idip)*pi/180.
      rak=float(irak)*pi/180.

       vp0=vp0*1.e3;vs0=vs0*1.e3;rho0=rho0*1.e3	   
       vp1=vp1*1.e3;vs1=vs1*1.e3;rho1=rho1*1.e3	   
	   
      rig0=vs0**2. * rho0
      rig1=vs1**2. * rho1
c      write(*,*) 'rig0,rig1 (MPa): ',rig0/1.e6,rig1/1.e6

c      enrat=(3./2.)*(vp0/vs0)**5. ! theor. estimate of S/P energy ratio
c      write(*,*) 'theor. estimate of S/P energy ratio: ',enrat
c      evp=vs0**2./(3.*pi*vp0**2.) !!! (dimensionless)
c      evs=1./(2.*pi)
c      write(*,*) 'Boatwright evp,evs: ',evp,evs
      
c Finite frequency bandwidth correction
 	  fmax=  1./(2.*dt)   !!!!!! This is Nyquist frequency   
c	  fc=0.078 !  Corner freq read from input file (constant for all stations)
	  ratio=(2./pi)*(  atan(fmax/fc)-(fmax/fc)/(1.+(fmax/fc)**2.)  ) ! atan() comes in radians
      ratio=1./ratio   ! this is 1.11 for fmax~1 Hz or 1.01 for fmax=10 Hz
	  write(*,*) 'Bandwith corr (E_calc will be multiplied by): ', ratio
      
c********************************************************** 
c    Reading eneinp1.dat 
c**********************************************************      
                         
c STNname  DIST(KM)  AZM(°) AIN(°) Scom=S travel time

      read(110,*) ! reading header xdis(km) 
      ist=1
 77   read(110,*,end=88) statname(ist),
     * xdist(ist),xazim(ist),xtake(ist), 
     * scom(ist)	 
c     * scom(ist),tstarst(ist)
      tstarst(ist)=scom(ist)/Qconst	 ! new t*
      ist=ist+1
      goto 77
 88   continue
      nr=ist-1
      write(*,*) 'number of stations: ',nr
      write(*,*)
      if(nr.gt.100) then
      write(*,*) 'STOP; number of stations > 100'
      STOP
      endif	  
      close(110)

c  ************** LOOP OVER STATIONS *****************   
      numwater=0 ! counting stations where applying water-level 
	  avepatS2=0.;avepatSV2=0.;avepatSH2=0. ! inicialization for averaging rad patt squared
	  aveD=0; aveE=0.
      aveSV=0.;aveSH=0.	  
 
      do 4000 ir=1,nr ! loop over stations
      write(*,*) 'station:', ir
      write(*,*) 't*= ', tstarst(ir) ! new

      dist=xdist(ir)/6371. ! angular epicentral distance in radians
	  azi=xazim(ir) ! in degrees
      ang=xtake(ir) ! in degrees
	
	
      if(azi.le.180) bazi=azi+180 ! backazimuth
      if(azi.gt.180) bazi=azi-180
c       write(*,*) 'stationnumber, iazi, ibazi: ', ir, iazi,ibazi


      azi=azi*pi/180.     !azimuth
	  bazi=bazi*pi/180.   !backazimuth
	  ang=ang*pi/180. !takeoff


ccc	  anginc= 30. * pi/180.	
      anginc=asin ( sin(ang) * ((6371-depth)/6371) *  (vs1/vs0) ) !Snell's law
c      write (*,*) 'incidence angle at station (deg): ', anginc*180./pi       
	
c   Re-calculating spreading as straight-line distance source-station in sphere (in KM)	  
      spredp(ir)= sqrt( (6371-depth)**2 + 6371**2 -
     *            2 * (6371-depth) * 6371 * cos(dist)) 	  
	  sprp=spredp(ir)*1000. ! from km to meter

c or, alternatively, Cartesian distance   gives about 5% higher E    
      hyp=sqrt(depth**2. + xdist(ir)**2.)   
      sprp_another= hyp *1000.  
c      write(220,'(4(1x,e13.6))')
c     *        	  hyp,1./sprp,1./sprp_another, sprp,sprp_another
c   Redefined
      sprp = sprp_another


      sprs=sprp  
      sprs=sprs /2.        ! free-surface factor 
      sprs2=sprs**2
	  

c     These integration limits are setup assuming that t=0 is at OT (travel=arrival times)
c	  ilim1=ifix((pobs(ir)-1.)/dt) ! 1 second sooner then P obs first arrival     
c      ilim2=ifix((scom(ir)-10.)/dt) ! 10 seconds sooner then S synth first arrival 
c      ilim2=ifix((pobs(ir)+20.)/dt) !  
ccc      ilim2=ifix((pobs(ir)+pdursyn(ir))/dt) ! almost same as with 20s
      ilim3=ifix((scom(ir)-15.)/dt)    ! S window starts 15 second before prescribed  S arrival  
      ilim4=ifix((scom(ir)+swin)/dt)  ! S window lasts swin seconds after S arrival; total = swin+15 

c      write(*,*) 'limits (in steps): ',ilim1,ilim2,ilim3,ilim4   
      write(*,*) 'S time limit:',ilim3*dt,ilim4*dt 
      
c************************************************************** 
c    Reading *raw.dat files for stations listed in eneinp.dat
c**************************************************************      
      
	  ntim=NT
      x=0.;y=0.;z=0.   

      numf1=1000+(ir*1)
      statfil1=trim(statname(ir))//'raw.dat' ! obs velocity; x,y,z = N,E,Z
      open(numf1,file=statfil1)
      
      do i=1,ntim     !     
      read(numf1,*) tim(i),x(i),y(i),z(i)
      enddo
      dtsave=tim(2)-tim(1)
    	close(numf1)
      if(abs(dtsave-dt).gt.0.00001) then
      write(*,*) 'problem: wrong time step and STOP!'
      STOP      
      endif

ccccc  ROTATION
c      xx=x; yy=y; zz=z   ! Saving for later use (x will be rewritten)
c      x,y,z = N,E,Z;  xx, yy
c      xr,xt,xz = R,T,Z
c      xsv, xsh(=xt) = SV, SH  (P-wave here is not defined))
       xr= cos(azi) * x + sin(azi) * y 
       xt=-sin(azi) * x + cos(azi) * y 
	   xsh=xt
c	   xsv=cos(ang) * xr - sin(ang) * z
	   xsv=cos(anginc) * xr - sin(anginc) * z
 
c REDEFINED using backazimuth according to IRIS definition (is the same regarding the energy) 
	   xsv=cos(anginc)*sin(bazi)*y + cos(anginc)*cos(bazi)*x +
     *                              	         sin(anginc)*z
       xsh=-cos(bazi)*y + sin(bazi)*x
      	   
       

cccc                  tstarst=0.  ! for debugging only

c          Taper parameters
	  perc=0.05; ntaper=ifix((swin*perc)/dt)
	  ileft=ilim3+ntaper
	  irigh=ilim4-ntaper
      write(*,*) 'S tapering:',ileft*dt,irigh*dt 


c**********************spectral domain** only S waves*******************
c                          REDEFINING x,y,z
        x=0.; y=0. ! ; z=0. ! zeroing  

cc        do i=ilim3,ilim4   ! windowing velocity for S by boxcar; later put a better taper
c        x(i)=xx(i);y(i)=yy(i);z(i)=zz(i)    ! back to original *raw velocities saved above, non-squered

        do i=ileft,irigh   ! windowing velocity for S by boxcar; later put a better taper
        x(i)=xsv(i);y(i)=xsh(i)    ! x=SV, y=SH (x=SV contains signal from Z component)
         if(i.ge.ilim3.and.i.le.ileft) then
		 x(i)=x(i)*0.5*(1.-cos(pi*float(i)/float(ntaper)))
 		 y(i)=y(i)*0.5*(1.-cos(pi*float(i)/float(ntaper)))
         elseif(i.ge.irigh.and.i.le.ilim4) then
		 x(i)=x(i)*0.5*(cos(pi*float(i-irigh)/float(ntaper))+1.)
		 y(i)=y(i)*0.5*(cos(pi*float(i-irigh)/float(ntaper))+1.)
         endif
        enddo
c	    write(*,*) x ! ADD PLOT OF TAPER !!!

    


        call filtless_1024(dt,x,aspx) ! aspx = amplitude spectrum of velocity SV(from f=0 to Nyquist)
        call filtless_1024(dt,y,aspy) ! aspx = amplitude spectrum of velocity SH(from f=0 to Nyquist)
c       call filtless_1024(dt,z,aspz)

        aspx2=aspx**2.;aspy2=aspy**2. ! squaring amplitude spectra of SV and SH

        asp2= aspx2 + aspy2           ! summing squered spectra of SV and SH 

        do is = 11, 503               ! testing smoothing spectra, increases E by ~ 2% 
        asp2smoo(is) = sum(asp2(is-10:is+10)) / 21.
        enddo
		asp2smoo(1:10)=0. !asp2smoo(11)  ! instead 0 we could make a taper
		asp2smoo(504:513)=0.!asp2smoo(503)
c		asp2=asp2smoo  ! if commented, smoothing is not applied
		
cc    Using asp2 and visualizing integrand [cummulative sum of velcoity S spectrum squared]  
c          WITH attenuation correction
    	 spint=0. ! scalar (spectral integral of S waves, x)
         do i=2,ntm   ! freq from df to Nyquist
		 freq=float(i-1)*df
         contrib= exp(2.*pi*freq*tstarst(ir)) * asp2(i) * df
         spint=spint + contrib 
        write(230,'(2(1x,e13.6))') freq, contrib
        enddo
        write (230,*) '*'		

cc		
c       do i=1,ntm
c		freq=float(i-1)*df
c        pomer=asp3com2(i)/asp2(i)	   
c        write(230,'(2(1x,e13.6))') freq, pomer
c       enddo		
c        write (230,*) '*'		
c
		spintx=0. ! scalar (spectral integral of SV waves, x)
        do i=1,ntm   ! freq from 0 to Nyquist
		freq=float(i-1)*df
		spintx= spintx + exp(2.*pi*freq*tstarst(ir)) * aspx2(i) * df
        enddo
c
		spinty=0. ! scalar (spectral integral of SH waves, y)
        do i=1,ntm   ! freq from 0 to Nyquist
		freq=float(i-1)*df
		spinty= spinty + exp(2.*pi*freq*tstarst(ir)) * aspy2(i) * df
        enddo
c        write (*,*) spint, spintx+spinty

c		spint=spintx + spinty     !(gives the same spint as above when using asp2)

cc   Amplitude spectra of displacement WITHOUT attenuation correction (corr added later)
         do i=2,ntm   ! freq from df to Nyquist
		 freq=float(i-1)*df
        aS=sqrt(asp2(i))/(2.*pi*freq)  ! ampl spec of total S, converted to displacement  
		outspecS(ir,i) = aS 
c		outspecS(ir,i) = (2./3.)*(log10(aS)-9.1)
		aSV=aspx(i)/(2.*pi*freq);aSH=aspy(i)/(2.*pi*freq)   
		outspecSV(ir,i) = aSV;outspecSH(ir,i) = aSH !SV and SH amplitude displ spectra 
        enddo



c********************************************************** 
c    DC Radiation patterns and their squares 
c**********************************************************      
      

       pattp=cos(rak)*sin(dip)*(sin(ang))**2.*sin(2.*(azi-str))-
     *     cos(rak)*cos(dip)*sin(2.*ang)*cos(azi-str)+
     *     sin(rak)*sin(2.*dip)*(cos(ang))**2.-
     *     sin(rak)*sin(2.*dip)*(sin(ang))**2.*(sin(azi-str))**2.+
     *     sin(rak)*cos(2.*dip)*sin(2.*ang)*sin(azi-str)
	   pattp2=pattp**2.  !   
      
      pattsv=sin(rak)*cos(2.*dip)*cos(2.*ang)*sin(azi-str)-
     *     cos(rak)*cos(dip)*cos(2.*ang)*cos(azi-str)+
     *     0.5*cos(rak)*sin(dip)*sin(2.*ang)*sin(2.*(azi-str))-
     *     0.5*sin(rak)*sin(2.*dip)*sin(2.*ang)-
     *     0.5*sin(rak)*sin(2.*dip)*sin(2.*ang)*(sin(azi-str))**2.
	  pattsv2=pattsv**2.    
      
      pattsh=cos(rak)*cos(dip)*cos(ang)*sin(azi-str)+
     *     cos(rak)*sin(dip)*sin(ang)*cos(2.*(azi-str))+
     *     sin(rak)*cos(2.*dip)*cos(ang)*cos(azi-str)-
     *     0.5*sin(rak)*sin(2.*dip)*sin(ang)*sin(2.*(azi-str))
	  pattsh2=pattsh**2.

  	   patts2=pattsv2 + pattsh2 !

c      write(216,'(1x,i5,1x,a5,4(1x,e15.6))')      ! 100% DC, not squared (with sign)
c     &ir,statname(ir),pattp, patts, pattsh, pattsv      ! non-squared

c      write(215,'(1x,i5,1x,a5,4(1x,e15.6))')
c     & ir,statname(ir),pattp2,patts2,pattsh2,pattsv2    ! squared 

c********************************************************** 
c    Full MT (non-DC) Radiation patterns and their squares 
c**********************************************************   

      AZM=azi ! in radians
	  TKO=ang ! in radians
	  !gamma is above defined in radians
	  strike=str ! in radians
	  !dip is above defined in radians
	  rake=rak ! in radians
 
c  This is Fortran re-write of rpgen.m code of G. Kwiatek and Y. Ben-Zion (MathWorks and K&B-Z,2013)
c I tested that for purely DC source it gives exactly the same as the above DC radiation pattern       
      Gp=cos(TKO)*(cos(TKO)*(sin(gamma)*(2.*cos(dip)**2
     &-(2.*sigma)/(2.*sigma-1.))
     &+sin(2.*dip)*cos(gamma)*sin(rake))
     &-cos(AZM)*sin(TKO)*(cos(gamma)*(cos(2.*dip)*sin(rake)*sin(strike)
     &+cos(dip)*cos(rake)*cos(strike))
     &-sin(2.*dip)*sin(gamma)*sin(strike))
     &+sin(AZM)*sin(TKO)*(cos(gamma)*(cos(2.*dip)*cos(strike)*sin(rake)
     &-cos(dip)*cos(rake)*sin(strike))-sin(2.*dip)
     &*cos(strike)*sin(gamma)))
     &+sin(AZM)*sin(TKO)*(cos(TKO)*(cos(gamma)*(cos(2.*dip)*cos(strike)
     &*sin(rake)
     &-cos(dip)*cos(rake)*sin(strike))
     &-sin(2.*dip)*cos(strike)*sin(gamma))
     &+cos(AZM)*sin(TKO)*(cos(gamma)*(cos(2.*strike)*cos(rake)*sin(dip)
     &+(sin(2.*dip)*sin(2.*strike)*sin(rake))/2.)-sin(2.*strike)
     & *sin(dip)**2*sin(gamma))
     &+sin(AZM)*sin(TKO)*(cos(gamma)*(sin(2.*strike)*cos(rake)*sin(dip)
     &-sin(2.*dip)*cos(strike)**2*sin(rake))
     &-sin(gamma)*((2.*sigma)/(2.*sigma-1.)
     &-  2.*cos(strike)**2*sin(dip)**2)))
     &-cos(AZM)*sin(TKO)*(cos(TKO)*(cos(gamma)*(cos(2.*dip)*sin(rake)
     &*sin(strike)+cos(dip)*cos(rake)*cos(strike))
     &-sin(2.*dip)*sin(gamma)*sin(strike))
     &-sin(AZM)*sin(TKO)*(cos(gamma)*(cos(2.*strike)*cos(rake)*sin(dip)
     &+(sin(2.*dip)*sin(2.*strike)*sin(rake))/2.)
     &-sin(2.*strike)*sin(dip)**2*sin(gamma))
     &+cos(AZM)*sin(TKO)*(cos(gamma)
     &*(sin(2.*dip)*sin(rake)*sin(strike)**2
     &+sin(2.*strike)*cos(rake)*sin(dip))+sin(gamma)*
     &((2.*sigma)/(2.*sigma-1.)-2.*sin(dip)**2*sin(strike)**2)))

      Gs=((sin(AZM)*sin(TKO)*(cos(AZM)*cos(TKO)*(cos(gamma)
     &*(cos(2.*strike)*cos(rake)
     &*sin(dip)+(sin(2.*dip)*sin(2.*strike)
     &*sin(rake))/2.)-sin(2.*strike)*sin(dip)**2*sin(gamma))
     &-sin(TKO)*(cos(gamma)*(cos(2.*dip)*cos(strike)*sin(rake)
     &-cos(dip)*cos(rake)*sin(strike))
     &-sin(2.*dip)*cos(strike)*sin(gamma))
     &+cos(TKO)*sin(AZM)*(cos(gamma)
     &*(sin(2.*strike)*cos(rake)*sin(dip)
     &-sin(2.*dip)*cos(strike)**2*sin(rake))
     &-sin(gamma)*((2.*sigma)/(2.*sigma-1.)
     &- 2.*cos(strike)**2*sin(dip)**2)))
     &-cos(TKO)*(sin(TKO)*(sin(gamma)*(2.*cos(dip)**2
     &-(2.*sigma)/(2.*sigma-1.))+sin(2.*dip)*cos(gamma)*sin(rake))
     &+cos(AZM)*cos(TKO)*(cos(gamma)
     &*(cos(2.*dip)*sin(rake)*sin(strike)
     &+cos(dip)*cos(rake)*cos(strike))
     &-sin(2.*dip)*sin(gamma)*sin(strike))
     &-cos(TKO)*sin(AZM)*(cos(gamma)
     &*(cos(2.*dip)*cos(strike)*sin(rake)
     &-cos(dip)*cos(rake)*sin(strike))
     &-sin(2.*dip)*cos(strike)*sin(gamma)))
     &+cos(AZM)*sin(TKO)*(sin(TKO)*(cos(gamma)*
     &(cos(2.*dip)*sin(rake)*sin(strike)
     &+cos(dip)*cos(rake)*cos(strike))
     &-sin(2.*dip)*sin(gamma)*sin(strike))+cos(TKO)*
     &sin(AZM)*(cos(gamma)*(cos(2.*strike)*cos(rake)*sin(dip)
     &+(sin(2.*dip)*sin(2.*strike)*sin(rake))/2.)
     &-sin(2.*strike)*sin(dip)**2.*sin(gamma))
     &-cos(AZM)*cos(TKO)*(cos(gamma)
     &*(sin(2.*dip)*sin(rake)*sin(strike)**2
     &+sin(2.*strike)*cos(rake)*sin(dip))+sin(gamma)
     &*((2.*sigma)/(2.*sigma-1.)-2.
     &*sin(dip)**2*sin(strike)**2))))**2
     &+(cos(TKO)*(cos(AZM)*(cos(gamma)
     &*(cos(2.*dip)*cos(strike)*sin(rake)
     &-cos(dip)*cos(rake)*sin(strike))
     &-sin(2.*dip)*cos(strike)*sin(gamma))
     &+sin(AZM)*(cos(gamma)*(cos(2.*dip)*sin(rake)*sin(strike)
     &+cos(dip)*cos(rake)*cos(strike))
     &-sin(2.*dip)*sin(gamma)*sin(strike)))
     &-sin(AZM)*sin(TKO)*(sin(AZM)*(cos(gamma)*
     &(cos(2.*strike)*cos(rake)*sin(dip)
     &+(sin(2.*dip)*sin(2.*strike)*sin(rake))/2.)
     &-sin(2.*strike)*sin(dip)**2*sin(gamma))
     &-cos(AZM)*(cos(gamma)*(sin(2.*strike)*cos(rake)*sin(dip)
     &-sin(2.*dip)*cos(strike)**2*sin(rake))
     &-sin(gamma)*((2.*sigma)/(2.*sigma-1.)
     &- 2.*cos(strike)**2.*sin(dip)**2)))
     &+cos(AZM)*sin(TKO)*(sin(AZM)*(cos(gamma)*
     &(sin(2.*dip)*sin(rake)*sin(strike)**2
     &+sin(2.*strike)*cos(rake)*sin(dip))
     &+sin(gamma)*((2.*sigma)/(2.*sigma-1.)
     &- 2.*sin(dip)**2*sin(strike)**2))
     &+cos(AZM)*(cos(gamma)*(cos(2.*strike)*cos(rake)*sin(dip) 
     &+(sin(2.*dip)*sin(2.*strike)*sin(rake))/2.)
     &-sin(2.*strike)*sin(dip)**2*sin(gamma))))**2)**(1./2.)

      Gsh=cos(TKO)*(cos(AZM)*(cos(gamma)*(cos(2.*dip)*cos(strike)
     &*sin(rake)
     &-cos(dip)*cos(rake)*sin(strike))
     &-sin(2.*dip)*cos(strike)*sin(gamma))
     &+sin(AZM)*(cos(gamma)*(cos(2.*dip)
     &*sin(rake)*sin(strike)+cos(dip)
     &*cos(rake)*cos(strike))-sin(2.*dip)*sin(gamma)*sin(strike)))
     &-sin(AZM)*sin(TKO)*(sin(AZM)
     &*(cos(gamma)*(cos(2.*strike)*cos(rake)
     &*sin(dip)+(sin(2.*dip)*sin(2.*strike)*sin(rake))/2.)
     &-sin(2.*strike)*sin(dip)**2*sin(gamma))
     &-cos(AZM)*(cos(gamma)*(sin(2.*strike)*cos(rake)*sin(dip)
     &-sin(2.*dip)*cos(strike)**2*sin(rake))
     &-sin(gamma)*((2.*sigma)/(2.*sigma-1.)
     &- 2.*cos(strike)**2*sin(dip)**2)))
     &+cos(AZM)*sin(TKO)*(sin(AZM)
     &*(cos(gamma)*(sin(2.*dip)*sin(rake)
     &*sin(strike)**2
     &+sin(2.*strike)*cos(rake)*sin(dip))
     &+sin(gamma)*((2.*sigma)/(2.*sigma-1.)
     &- 2.*sin(dip)**2*sin(strike)**2))
     &+cos(AZM)*(cos(gamma)*(cos(2.*strike)*cos(rake)*sin(dip)
     &+(sin(2.*dip)*sin(2.*strike)*sin(rake))/2.)
     &-sin(2.*strike)*sin(dip)**2.*sin(gamma)))

      Gsv=sin(AZM)*sin(TKO)*(cos(AZM)*cos(TKO)*(cos(gamma)
     &*(cos(2.*strike)*cos(rake)*sin(dip)
     &+(sin(2.*dip)*sin(2.*strike)*sin(rake))/2.)
     &-sin(2.*strike)*sin(dip)**2*sin(gamma))
     &-sin(TKO)*(cos(gamma)*(cos(2.*dip)*cos(strike)*sin(rake)
     &-cos(dip)*cos(rake)*sin(strike))
     &-sin(2.*dip)*cos(strike)*sin(gamma)) 
     &+cos(TKO)*sin(AZM)*(cos(gamma)
     &*(sin(2.*strike)*cos(rake)*sin(dip)
     &-sin(2.*dip)*cos(strike)**2*sin(rake))
     &-sin(gamma)*((2.*sigma)/(2.*sigma-1.)
     &- 2.*cos(strike)**2*sin(dip)**2)))
     &-cos(TKO)*(sin(TKO)*(sin(gamma)*(2.*cos(dip)**2
     &-(2.*sigma)/(2.*sigma-1.))
     &+sin(2.*dip)*cos(gamma)*sin(rake))
     &+cos(AZM)*cos(TKO)*(cos(gamma)
     &*(cos(2.*dip)*sin(rake)*sin(strike)
     &+cos(dip)*cos(rake)*cos(strike))
     &-sin(2.*dip)*sin(gamma)*sin(strike))
     &-cos(TKO)*sin(AZM)*(cos(gamma)
     &*(cos(2.*dip)*cos(strike)*sin(rake)
     &-cos(dip)*cos(rake)*sin(strike))
     &-sin(2.*dip)*cos(strike)*sin(gamma)))
     &+cos(AZM)*sin(TKO)*(sin(TKO)*(cos(gamma)
     &*(cos(2.*dip)*sin(rake)*sin(strike) 
     &+cos(dip)*cos(rake)*cos(strike))
     &-sin(2.*dip)*sin(gamma)*sin(strike)) 
     &+cos(TKO)*sin(AZM)*(cos(gamma)
     &*(cos(2.*strike)*cos(rake)*sin(dip)
     &+(sin(2.*dip)*sin(2.*strike)*sin(rake))/2.)
     &-sin(2.*strike)*sin(dip)**2*sin(gamma))
     &-cos(AZM)*cos(TKO)*(cos(gamma)
     &*(sin(2.*dip)*sin(rake)*sin(strike)**2
     &+sin(2.*strike)*cos(rake)*sin(dip))
     &+sin(gamma)*((2.*sigma)/(2.*sigma-1.)
     &- 2.*sin(dip)**2*sin(strike)**2)))

c      pattp=Gp; pattp2=pattp**2
c      pattsnew=Gs; pattsnew2=pattsnew**2 ! pattsnew2 = pattsv2 + pattsh2 = that is the same as patts2 below 
c	  pattsv=Gsv; pattsv2=pattsv**2
c      pattsh=Gsh; pattsh2=pattsh**2
c	  patts2=pattsv2 + pattsh2 !   total squared S-wave radiation pattern (Boatwright & Fletcher)
c                              ! here patts2 is the same as pattsnew2 [patts was not defined]
      write(216,'(1x,i5,1x,a5,4(1x,e15.6))')           ! non-DC, not squared (with sign)
     &               ir,statname(ir),pattp,pattsnew,pattsh,pattsv
c I checked that this is precisely the same as rpgen of Kwiatek when prescribing the same 
c values of s/d/r, gamma(deg), sigma, takeoff(deg) and azimuth(deg).
c Here the SIGN is useful e.g. for comparison with P polarity 
c Be carful where in this code are the angles in degrees and radians !!! And how it is in rpgen.	 


c Next we deal only with SQUARES of rad. pattern
cccccccccccccccccccccccccccccccccccccccccccccc      
c REDEFINITION of S-squred pattern with a WATER-LEVEL represented by a fraction of RMS-SQUARED=RMS2
c For S and DC source, RMS2=RMS**2=2/5=0.4 = mean square, 
c Kwitek Fig. 2 plots RMS=sqrt(RMS2)=0.63 mean abs value, we work only with squares	  !!!!!!!

	  fractmy=0.1
	  pattsRMS=sqrt(2./5.) ! = 0.63 exact RMS for S in DC source; for nonDC varies 0.63-0.73 
	  pattsRMS2=2./5.; bound2=fractmy*pattsRMS2 ! 
      if(patts2.lt.bound2) then
c      patts2=bound2
c      numwater=numwater+1	  
      endif 
      
      fractmy=0.1	  
	  pattshRMS=0.5 ! very rough approx for SH from Kwiatek Fig. 3 (SV would be more difficult) 
	  pattshRMS2=pattshRMS**2;bound2=fractmy*pattshRMS2
      if(pattsh2.lt.bound2) then
c      pattsh2=bound2
c      numwater=numwater+1	  
      endif 	  
	  
cccccccccccccccccccccccccccccccccccccccccccccc


      write(215,'(1x,i5,1x,a5,4(1x,e15.6))')
     &   ir,statname(ir),pattp2,patts2,pattsh2,pattsv2
c Here the signs are 'lost'; energy needs only these squared values 


c ....Averaging radiation patterns squared (cummulative in loop over stations) !!
      avepatS2=avepatS2   + patts2
      avepatSH2=avepatSH2 + pattsh2
	  avepatSV2=avepatSV2 + pattsv2
    

   
      
c      write(*,*) 'ratio flux to pattern_squared, SV+SH, SV,SH:' 
c      write(*,*)    spint/patts2,spintx/pattsv2,spinty/pattsh2

      if(keyradpat.eq.0) then      
c REDEFINITION !!!!!!!!!!!!! for case of NOT using radiation pattern	  
	  patts2=2./5.     ! Aki & Richards and                          !2/5= 0.4 
c     this means that patts=sqrt(patts2)=0.63 for 100% DC, gamma=0      
c     for gamma < 60 deg, Kwiatek gives patts<0.7, i.e., patts2<0.49, not far from 0.4 

      pattsv2=7./30.   ! Boatwright & Fletcher below eq. 8b          !7/30=0.23
      pattsh2=1./6.	  !1/6= 0.166 
c For non-DC: SV, SH, Kwiatek gives very complicated average patterns. Better avoid SV!	  
      endif      

C        AMPLITUDE SPECTRUM FROM TOTAL S WITH attenuation and all other corrections 
        do i=2,ntm   ! freq from df to Nyquist
		freq=float(i-1)*df
		! amplitude spec of displacement corrected for t*,spread and radpat 
        outspecS(ir,i) = outspecS(ir,i)*exp(pi*freq*tstarst(ir))
c        outspecS(ir,i) = outspecS(ir,i)
     &	*sqrt(sprs2)/sqrt(patts2)*
c     &	*sqrt(sprs2)/sqrt(2./5.) *
     &  4.*pi*rho0**(1./2.)*rho1**(1./2.)*vs0**(5./2.)*vs1**(1./2.)
        ! exp contains pi*freq not 2*pi*freq because 2 is in energy due to power 2
        ! in principle we can work independently with spectra of SV and SH and correct here each by its won pattern
        write(235,'(1x,i5,1x,2(1x,e13.6))') ir, freq, outspecS(ir,i)
        enddo
        write (235,*) '*'	

C      Alternatively:  SPECTRA FROM  SV and SH and THEN  total S from them 
c       do i=2,ntm   ! freq from df to Nyquist
c		freq=float(i-1)*df
c		! amplitude spec of displacement corrected for t*,spread and radpat 
c
c        outspecSV(ir,i) = outspecSV(ir,i)*exp(pi*freq*tstarst(ir))
ccc     &	*sqrt(sprs2)/abs(pattsv)*
c     &	*sqrt(sprs2)/sqrt(7./30.)*
c     &  4.*pi*rho0**(1./2.)*rho1**(1./2.)*vs0**(5./2.)*vs1**(1./2.)
c        ! exp contains pi*freq not 2*pi*freq because 2 is in energy due to power 2
c        ! in principle we can work independently with spectra of SV and SH and correct here each by its won pattern
c
c        outspecSH(ir,i) = outspecSH(ir,i)*exp(pi*freq*tstarst(ir))
ccc     &	*sqrt(sprs2)/abs(pattsh)*
c     &	*sqrt(sprs2)/sqrt(1./6.)*
c     &  4.*pi*rho0**(1./2.)*rho1**(1./2.)*vs0**(5./2.)*vs1**(1./2.)
c	 
c	    outspecS(ir,i) = sqrt( (outspecSV(ir,i)/1e20)**2 
c     &                      + (outspecSH(ir,i)/1e20)**2 ) 
c        outspecS(ir,i)=outspecS(ir,i)*1.e20
 
c         write(235,'(1x,i5,1x,2(1x,e13.6))') ir,freq,outspecS(ir,i)
c        enddo
c        write (235,*) '*'	






c********************************************************** 
c    Radiated seismic energy Lancieri et al.
c**********************************************************    
       enes=0.; enesx=0.;enesy=0.;enesz=0.;
	   
ccc      spectral domain

         enesA=8.*pi*(2./ 5.)*(sprs2/patts2) *(rho1*vs1) * spint     ! total Es from SV and SH summed
c        For non-DC, here instead of 2/5=0.4 should be e.g. 0.7**2 ~ 0.5 Kwiatek Fig. 2 
c        Caution then if chooing keyradpat=0, then should change also patts2 equally

         enesD=8.*pi*(2./ 5.)*(sprs2)        *(rho1*vs1) * spint     ! S: averaging trick with radpat
         aveD=aveD + enesD ! continual averaging
         enesE=8.*pi*         (sprs2)        *(rho1*vs1) * spint     ! S: averaging trick without radpat
         aveE=aveE + enesE

        enesB=8.*pi*(2./ 5.)*(sprs2/pattsv2)*(rho1*vs1) * spintx   ! total Es from SV   
        
		enesC=8.*pi*(2./ 5.)*(sprs2/pattsh2)*(rho1*vs1) * spinty   ! total Es from SH
c       For non-DC, here instead of 2/5=0.4 should be e.g. 0.7**2 ~ 0.5 Kwiatek Fig. 2 


        enesx=  8.*pi*(7./30.)*(sprs2/pattsv2)*(rho1*vs1) * spintx ! contribution to Es from SV 
        
		enesxF= 8.*pi*(7./30.)*(sprs2)        *(rho1*vs1) * spintx
        aveSV=aveSV + enesxF
        enesy=  8.*pi*(1./6.) *(sprs2/pattsh2)*(rho1*vs1) * spinty ! contribution to Es from SH
        enesyF= 8.*pi*(1./6.) *(sprs2)        *(rho1*vs1) * spinty
        aveSH=aveSH + enesyF
		
c                                                                     ! My tests for No. 6        
        if(keywavetype.eq.1) enes= enesA ! total Es from SV and SH    ! 18  4.5640600E+13
        if(keywavetype.eq.2) enes= enesB ! total Es from SV           ! 17  5.1325913E+14
        if(keywavetype.eq.3) enes= enesC ! total Es from SH           ! 14  4.5499504E+13 
        if(keywavetype.eq.4) enes= enesx+enesy ! Es SV+SH individual  ! 17  5.5010079E+14    
        if(keywavetype.eq.5) enes= enesx  !individ part of Es from SV ! 17  2.9940120E+14
        if(keywavetype.eq.6) enes= enesy ! individ part of Es from SH ! 14  1.8958185E+13

c          Adding estimate of P energy = Es/15.6 
       enes=enes * (1. + 1./15.6)  

c  Application of finite bandwith corr ( S only)
       enes=enes*ratio

      write(*,*) 'Energy estimate from S (J): ',enes
      write(200,'(1x,a5,7(1x,e15.6))') statname(ir),enes
	  
      es(ir)=enes ! S enery of station ir
	  
 4000 continue     ! ending loop over stations !!!!!!!!!!!!!!!!!!!!!!!
 
c                  AFTER STATION LOOP 
 
      avepatS2=avepatS2/float(nr)       ! Arithmetic avreages of squared patterns over stations
      avepatSH2=avepatSH2/float(nr)
      avepatSV2=avepatSV2/float(nr)
      aveD=aveD/float(nr); aveE=aveE/float(nr);	
      aveSV=aveSV/float(nr); aveSH=aveSH/float(nr);
	  
      write(*,*) 'avepat2 of S, SH, SV: ',avepatS2,avepatSV2,avepatSH2 
 
      aveD = aveD / avepatS2 
      aveE = aveE
      aveSV=aveSV/avepatSV2
      aveSH=aveSH/avepatSH2
      aveScompl=aveSV+aveSH
	  
      write(*,*)  	  
      write(*,*) 'S-Energy, ave flux, ave radpat: ',aveD
      write(*,*) 'S-Energy, ave flux, no  radpat: ',aveE
      write(*,*) 'S-Energy, ave SV and SH, ave radpat: ',aveScompl

c Mean and standard deviation of logarithimic values (=geometric mean and geometric std dev)     
      xml=0.
      do ir=1,nr
      xml=xml + log10(es(ir))
      enddo
      xml=xml/float(nr)

      xmls=0.
      do ir=1,nr
      xmls=xmls + (log10(es(ir))-xml)**2
      enddo
      xmls=sqrt(xmls/float(nr))

	  etots_mean = 10.**xml         ! geometric mean = median of energy
	  etop=10.**(xml + xmls)
	  ebot=10.**(xml - xmls)

      write(*,*)
      write(*,*) 'Number of water-level corrected stations: ', numwater
      write(*,*) 'Number of all stations, Energy (J) mean: ',
     *                                    nr, etots_mean	  
      write(210,*) 'Number of all stations, Energy (J) mean: ',
     *                                    nr, etots_mean	  
	  
c      do ir=1,nr       
c      write(201,'(1x,i5,3(1x,e15.6))') ir,etots_mean,etop,ebot
c      enddo
	  
      write(*,*) 
c  DEVIATIONS 
      do ir=1,nr
      devi(ir)=log10(es(ir)/etots_mean)
c      write(*,*) 'statno., deviation: ',ir, devi(ir) 	  
      enddo

C Averaging with removal of outliers (outlier defined as abs(deviation)>1)
      xml=0.; ircount=0
      do ir=1,nr
      if(abs(devi(ir)).lt. 1) then
	  xml=xml + log10(es(ir))
	  ircount=ircount+1
      endif
      enddo
      xml=xml/float(ircount)
 
      xmls=0.
      do ir=1,nr
      if(abs(devi(ir)).lt. 1) then
	  xmls=xmls + (log10(es(ir))-xml)**2
      endif
      enddo
      xmls=sqrt(xmls/float(ircount))

c Redefinition of the mean
      etots_mean=10.**xml	  
	  etop=10.**(xml + xmls)
	  ebot=10.**(xml - xmls)
	  
      do ir=1,nr       
      write(201,'(1x,i5,3(1x,e15.6))') ir,etots_mean,etop,ebot
      enddo

      write(*,*) 'Number of retained stations, Energy (J) mean: ',
     *                      	  ircount, etots_mean  
      write(*,*) 'For details, see file eneout2.dat.'
      write(*,*)
      write(210,*) 'Number of retained stations, Energy (J) mean: ',
     *                      	  ircount, etots_mean  
      write(210,*) 'Energy (J) bounds (lower, upper): ', ebot,etop
      write(210,*) 'PRESCRIBED Scalar moment (Nm)= ',xmom
      xmommag=(2./3.)*log10(xmom) - 6.0333 
      write(210,*) 'Moment magnitude Mw= ',xmommag

      write(*,*)
	  write(*,*) 'Assuming moment =', xmom
      write(*,*)'THETA=log10(Es_logar/Mo)= ', log10(etots_mean/xmom)
      write(*,*) 'World range cca from  -4.0 to -5.4'
      write(210,*)'THETA=log (Es_logar/Mo)= ',log10(etots_mean/xmom)
      write(210,*) 'World range cca from -4.0 to -5.4'


c      radius=10.      !! in km (read from eneinp0)
      write(*,*)
c      write(*,*) 'PRESCRIBED source radius(km): ',radius
      write(210,*) 'PRESCRIBED source radius (km)',radius
      radius=1000.*radius
      sdrop= (7./16.)* xmom/(radius**3.)
      write(210,*) 'stress drop (MPa)= ',sdrop/1.e6
	  radef=(2.*rig0/sdrop)*etots_mean/xmom
      write(210,*) 'radiation efficiency= ',radef
      slip=xmom/(rig0*pi*radius**2.)
      write(210,*) 'average slip (m)= ',slip

c      write(*,*) 'YOUR energy preference?'
c      read(*,*) etots_mean
c      write(210,*) 'PRESCRIBED energy (J)?',etots_mean
c      radef=(2.*rig0/sdrop)*etots_mean/xmom
c      write(210,*) 'radiation efficiency= ',radef
c      slip=xmom/(rig0*pi*radius**2.)
c      write(210,*) 'average slip (m)= ',slip
      
      stop
      end
      include "filtless_1024.inc"
   