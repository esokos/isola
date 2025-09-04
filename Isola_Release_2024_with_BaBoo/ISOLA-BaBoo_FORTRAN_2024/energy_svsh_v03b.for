      program ENERGY_svsh_v03b
c differs from v03 on line 159 and increases energy by a few percent 
c  eneinp.dat ....reading real values
c  tstar read for each station  

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
      dimension aspx2(513),aspy2(513),aspz2(513),asp2(513),asp2smoo(513)  
      dimension asp3com(513),asp3com2(513) ! amplitude spectrum of absolute velocity, and its square 
      character*5 statname(100)
c      character *17 statfil1, statfil2,statfil3
      
      character *17 statfil1
      character *17 statfil2,statfil3
	  
      dimension xdist(22),xazim(22),xtake(22),spredp(22),tstarst(22)
      dimension pobs(22),scom(22),pdursyn(22),pdurobs(22)
      dimension ep(22),es(22),devi(22)
      open(105,file='eneinp0_v03.dat')  
      open(110,file='eneinp_v03.dat')  
      open(200,file='eneout.dat')
      open(201,file='eneout1.dat')
      open(210,file='eneout2.dat')
c      open(220,file='eneout3.dat')
      open(230,file='integrand.dat')


c********************************************************** 
c    Reading eneinp0_v03.dat 
c**********************************************************      
      read(105, *)
      read(105, *)
      read(105, *) TWL,istr,idip,irak,depth,
     *	  vp0,vs0,rho0, vp1,vs1,rho1,swin, 
     *	  fc, xmom, radius,keyradpat,keywavetype !,tstarconst
c TWL    istr idip irak  depth VPource VSsource RHOsource VPsurf VSsurf RHOsurf Swin Corner_freq Moment Radius KEYradp
c s      deg  deg  deg    km      km/s km/s g/cm3   km/s km/s g/cm3              s       Hz      Nm     km    none
c TWL time window length of Isola 
c istr, idip, irak ... strike,dip, rake angles (integers)
c Swin ... S-wave window length (starts 5 before S arrival)
c Corner freq (Hz) ... here taken as all-station estimate
c KEYradpat 0 if not used, 1 if used
c KEYwavetype see line 313
c tstarconst = t* constant for all stations 
      write(*,*) 'Input data (eneinp0.dat):'      
      write(*,*) TWL,istr,idip,irak,depth,
     *	  vp0,vs0,rho0, vp1,vs1,rho1,swin,
     *	  fc, xmom, radius,keyradpat,keywavetype !,tstarconst
      write(*,*)      

cccccccccccccccccccccccc
c      tstarst=tstarconst       ! FIXED if later read for each station, then updated
c      write(*,*) tstarst
cccccccccccccccccccccccc
 
	  pi=3.141592
      NI=10 ! (assumes 1024 points) 
      NT=2**NI  
	  dt=TWL/(float(NT)) !  !!!!!!!!!!!!! FIXED due to 1024 !!
      NP=NT     
      NT2=NT/2
      NTM=NT2+1
      NTT=NT+2
      DF=1./(DT*FLOAT(NT))
      FMAX=FLOAT(NTM)*DF
	  
      str=float(istr)*pi/180.
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
c    Reading eneinp_v03.dat 
c**********************************************************      
                         
c STNname  DIST(KM)  AZM(°) AIN(°) Scom=S travel time, t*

      read(110,*) 
      ist=1
 77   read(110,*,end=88) statname(ist),
     * xdist(ist),xazim(ist),xtake(ist),
c     * scom(ist)	 
     * scom(ist),tstarst(ist)	 
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
 
c  ************** LOOP OVER STATIONS *****************   

 
      do 4000 ir=1,nr ! loop over stations
      write(*,*) 'station:', ir

      dist=xdist(ir)/6371. ! angular epicentral distance in radians
	  azi=xazim(ir)
      ang=xtake(ir)
	
	
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
      sprs=sprs /2.        ! free-surface factor 2 is applied
      sprs2=sprs**2.
	  

c     These integration limits are setup assuming that t=0 is at OT (travel=arrival times)
c	  ilim1=ifix((pobs(ir)-1.)/dt) ! 1 second sooner then P obs first arrival     
c      ilim2=ifix((scom(ir)-10.)/dt) ! 10 seconds sooner then S synth first arrival 
c      ilim2=ifix((pobs(ir)+20.)/dt) !  
ccc      ilim2=ifix((pobs(ir)+pdursyn(ir))/dt) ! almost same as with 20s
      ilim3=ifix((scom(ir)-5.)/dt)    ! S window starts 5 second before prescribed  S arrival  
      ilim4=ifix((scom(ir)+swin)/dt)  ! S window lasts swin seconds after S arrival; total = swin+5 

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

c**********************spectral domain** only S waves*******************
c                          REDEFINING x,y,z
        x=0.; y=0. ! ; z=0. ! zeroing  
        do i=ilim3,ilim4   ! windowing velocity for S by boxcar; later put a better taper
c        x(i)=xx(i);y(i)=yy(i);z(i)=zz(i)    ! back to original *raw velocities saved above, non-squered
        x(i)=xsv(i);y(i)=xsh(i)    ! x=SV, y=SH
        enddo
c	    write(*,*) x


        call filtless_1024(dt,x,aspx) ! aspx = amplitude spectrum of velocity (from f=0 to Nyquist)
        call filtless_1024(dt,y,aspy)
c       call filtless_1024(dt,z,aspz)

        aspx2=aspx**2.;aspy2=aspy**2. ! squaring amplitude spectra of SV and SH

        asp2= aspx2 + aspy2           ! summing SV and SH 

        do is = 11, 503               ! testing smoothing spectra, increases E by ~ 2% 
        asp2smoo(is) = sum(asp2(is-10:is+10)) / 21.
        enddo
		asp2smoo(1:10)=asp2smoo(11)
		asp2smoo(504:513)=asp2smoo(503)
c		asp2=asp2smoo  ! if commented, smoothing is not applied
		
cc    Using asp2 and visualizing integrand   
    	 spint=0. ! scalar (spectral integral of S waves, x)
         do i=1,ntm   ! freq from 0 to Nyquist
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

c		spint=spintx + spinty     !(gives the same spint as above when using asp2)

c********************************************************** 
c    Radiation patterns and their squares
c**********************************************************      
      

c      pattp=cos(rak)*sin(dip)*(sin(ang))**2.*sin(2.*(azi-str))-
c     *     cos(rak)*cos(dip)*sin(2.*ang)*cos(azi-str)+
c     *     sin(rak)*sin(2.*dip)*(cos(ang))**2.-
c     *     sin(rak)*sin(2.*dip)*(sin(ang))**2.*(sin(azi-str))**2.+
c     *     sin(rak)*cos(2.*dip)*sin(2.*ang)*sin(azi-str)
c	   pattp2=pattp**2.  !   
      
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
      
	  patts2=pattsv2 + pattsh2 !   total squared S-wave radiation pattern (Boatwright & Fletcher)

      write(*,*) 'ratio flux to pattern_squared, SV+SH, SV,SH:' 
      write(*,*)    spint/patts2,spintx/pattsv2,spinty/pattsh2

      if(keyradpat.eq.0) then      
c REDEFINITION !!!!!!!!!!!!! for case of NOT using radiation pattern	  
	  patts2=2./5.     ! Aki & Richards and                          !2/5= 0.4 
      pattsv2=7./30.   ! Boatwright & Fletcher below eq. 8b          !7/30=0.23
      pattsh2=1./6.                                                  !1/6= 0.166  
      endif      

c********************************************************** 
c    Radiated seismic energy Lancieri et al.
c**********************************************************    
       enes=0.; enesx=0.;enesy=0.;enesz=0.;
	   
ccc      spectral domain
        enesA=  8.*pi*(2./ 5.)*(sprs2/patts2)  *  (rho1*vs1) * spint     ! total Es from SV and SH summed
        enesB=  8.*pi*(2./ 5.)*(sprs2/pattsv2)  *  (rho1*vs1) * spintx   ! total Es from SV   
        enesC=  8.*pi*(2./ 5.)*(sprs2/pattsh2)  *  (rho1*vs1) * spinty   ! total Es from SH
        enesx= 8.*pi*(7./30.)*(sprs2/pattsv2) *  (rho1*vs1) * spintx ! contribution to Es from SV 
        enesy= 8.*pi*(1./6.) *(sprs2/pattsh2) *  (rho1*vs1) * spinty ! contribution to Es from SH
        
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
	  
      es(ir)=enes
 4000 continue     ! ending loop over stations


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
c      write(*,*) 'YOUR energy prference?'
c      read(*,*) etot
c      write(210,*) 'PRESCRIBED energy (J)?',etot
      radius=1000.*radius
      sdrop= (7./16.)* xmom/(radius**3.)
      write(210,*) 'stress drop (MPa)= ',sdrop/1.e6
	  radef=(2.*rig0/sdrop)*etots_mean/xmom
      write(210,*) 'radiation efficiency= ',radef
      slip=xmom/(rig0*pi*radius**2.)
      write(210,*) 'average slip (m)= ',slip
      
      
      stop
      end
      include "filtless_1024.inc"
   