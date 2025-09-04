      PROGRAM syn_cor_rand

c: 2022
c ntim=1024
c Random numbers without MSIMSL library. Instead: here using Numerical Recipes
c Each component has a different noise random series but an equl strength (std. dev)
c To be checked how to call so that each STATION has DIFFERENT random series inlc possibly different strength

c random noise !!!!!!! Oct - Dec 2017, 2022
c Noise is generated as Gaussian random numbers with variance prescribed by user
c (appears on output as 'noise sigma1')
c Noise is band-pass filtered (causal, 4th order) as prescribed by user.
c Noise differs between stations and components [code has no repeatability!]
c If user requests displacement, noise is integrated.
C Filtration and integration determine the final noise variance. 
c (appears on output as 'noise sigma2')
c Screen output gives also ratio of sigma2 to maximum station amplitude
c If you need to change this ratio, e.g. multiply by 2, re-run the code with sigma1 * 2 
	  
c It makes use of 99.syn.dat 
c check for 'fixed' options below !!!!!!!!!!!!! (BandPass, shift, baseline, trend)

c      use msimsl ! for random number generation (RNSET, RNUN): sunstituted by Num. Recipes

      DIMENSION AA(3,-100000:100000)
      dimension bb(3,8192),xpozice(8192)
	  DIMENSION XAUX(8192),TREND(8192)
      dimension amax(3)

C declaration needed for XAPIIR
        CHARACTER*2 TYPE, APROTO
        INTEGER NSAMPS, PASSES, IORD
        REAL*4 TRBNDW, A, FLO, FHI, TS, SN(30), SD(30)
        LOGICAL ZP


      OPEN(9,FILE='i.dat')
      OPEN(10,FILE='row.dat')
      OPEN(50,FILE='outsei.dat')
c	  OPEN(60,FILE='outmax.dat')
c
      ntim=1024	 
      PI=3.14159

      do i=1,4
      read(9,*) !skipping 4 rows
      enddo
      read(9,*) dt
      read(9,*) f1,f2
      read(9,*) f3,f4
      read(9,*) keyfil ! band pass (0) or low pass (1) 
      read(9,*) keydis ! output velocity (0) or displacement (1)
      read(9,*) keyrand ! without noise (0) or with noise (1)
      if(keyrand.eq.1) then
      read(9,*) xnoise ! noise standard deviation [in ground motion units] (choose it based on synthetics without noise); same for all stations 
      read(9,*) f5     ! noise low-cut frequency
      read(9,*) f6     ! noise high-cut frequency
      write(*,*) 'how many seconds of noise to create?' ! later add among data prepared by GUI
      read(*,*) xsecon
c     similarly to this last read, here we could read xnoise std. deviation as station dependent	  
      endif	
	
ccccccccccc possibility to inlcude also shift below (manual edit of shift= line is needed)
c not confuse with shift in mechan, which is always used
c  mechan.dat is produced by GUI comp_synt, including shift setup by user in GUI

c (but mechan is not used if MT is defined by editing  conshift.for, then shift 
c  here may be useful; but then GUI comp_synt must be modified)
C
c      READING INPUT 3-COMPONENT  TIME SERIES
c
 
	
c It is  possible to inlcude a shift 'manually' editing the next line.
c     shift=-0.20001  ! (do not confuse with the shift in MECHAN.DAT)
      shift=0.   
	ish=ifix(shift/dt)  
c	write(*,*) 'ish= ', ish   

      do i=1,ntim
      READ(10,*) dum,aa(1,i+ish),aa(2,i+ish),aa(3,i+ish)
      enddo



c
c      LOOP OVER  3 COMPONENTS
c
      do icom=1,3        ! 

C
c     TAPERING full-band velocity at the end  
c
c      taper=10.   !seconds ????
c      mag=1000      !samples  ifix(taper/dt)
c      DO I=1,ntim
c      if(i.ge.ntim-mag.and.i.le.ntim) then
c      pfi=3.141592*float(i-1-ntim+mag)/float(mag) 
c      fifi=(cos(pfi)+1.)/2.
c      aa(icom,i)=aa(icom,i)*fifi
c      endif
c      enddo

c
c     TAPERING full-band velocity at the start   
c
c      taper=10. !seconds ????
c 	mag=2000    !samples ifix(taper/dt)
c      DO I=1,ntim
c      if(i.ge.0.and.i.le.mag) then
c      pfi=3.141592*float(mag-i+1)/float(mag)	   
c      fifi=(cos(pfi)+1.)/2.
c      aa(icom,i)=aa(icom,i)*fifi
c      endif
c      enddo



c
c     CAUSAL FILTRATION IN TIME DOMAIN  (using XAPIIR by D. Harris 1990)
c

		NSAMPS=ntim
          APROTO='BU' ! Butterworth
		TRBNDW=0.  ! not used for 'BU'
		A=0.	   ! not used for 'BU'
		IORD=4 ! number of poles (4-5 recommended)
		TS=dt 
		PASSES=1 ! (1 for forward; 2 for forward and reverse = zero phase) 
      	MAX_NT=ntim

		if(keyfil.eq.0) TYPE='BP' ! band pass 
		if(keyfil.eq.1) TYPE='LP' ! low pass 
c		write(*,*) type
		FLO=f1    
          if(FLO.eq.0.) FLO=1./(dt*float(ntim)) ! BandPass cannot start at 0
		FHI=f4      

      do itim=1,ntim
      xaux(itim)=aa(icom,itim)    ! non-filtered time series
	  enddo

C Caution!!! For generating synthetic velocity data (equivalent to *raw.dat)
c filtration here must be skipped
c because these 'data' will be filtered when processing as real data.
C If not skipped here, the 'data' are in fact filtered twice, and a TIME SHIFT
c is created. SIMPLER POSSIBILITY is to keep filtration as it is, but
c to gebnerate synth data with high-freq cutoff limit equal to Nyquist.
c Then the shift will not be genarated if we invert freq << Nyquist.

c	goto 123 ! to skip filtration
	    call  XAPIIR(xaux, NSAMPS, APROTO, TRBNDW, A, IORD,
     +                 TYPE, FLO, FHI, TS, PASSES, MAX_NT)
c 123	continue
 
      do itim=1,ntim
        aa(icom,itim)=xaux(itim)     ! filtered time series   
	enddo


c
C     LINEAR TREND correction
C

      sum1=0.                
      sum2=0.
      ntrend=ntim ! complete record ??  
      do i=1,ntrend
      sum1=sum1+aa(icom,i)
      sum2=sum2+aa(icom,i)*float(i)
      enddo
      b0=(2.*(2.*float(ntrend)+1)*sum1-6.*sum2)/
     *    	(float(ntrend)*(float(ntrend)-1.))
      b1=(12.*sum2-6.*(float(ntrend)+1)*sum1)/
     *        (dt*float(ntrend)*(float(ntrend)-1)*(float(ntrend)+1))
      do i=1,ntim ! now applied to all samples
      trend(i)=b0+b1*dt*float(i)
      enddo
      do i=1,ntim
c      aa(icom,i)=aa(icom,i)-trend(i) ! trend correction enabled
	aa(icom,i)=aa(icom,i)          ! trend correction disabled 
	enddo


c
c   BASELINE correction of velocity
c
      xlim2=10. ! seconds ????? 
      nbase=50  ! samples  ifix(xlim2/dt) 
         base=0.
         DO I=1,nbase
         base=base+aa(icom,i)
         ENDDO
         base=base/float(nbase)
         DO I=1,ntim
c	   aa(icom,i)=aa(icom,i)-base ! baseline correction enabled
	   aa(icom,i)=aa(icom,i)	  ! baseline correction disabled 
         ENDDO                    
                                  
c
c     INTEGRATION  in time domain
c

      if(keydis.eq.0) goto 5000           
        X2=0.	   ! from VELOCITY to DISPLACEMENT
        DO I=1,ntim
        X2=X2+aa(icom,i)*DT
        aa(icom,i)=X2 
        ENDDO
c	write(*,*) 'displacement'
 5000 continue



C
C     LINEAR TREND CORRECTION
C                            ! problematic for records where trend 
                             ! starts later than at the beginning 
      sum1=0.                
      sum2=0.
      ntrend=500! ntim ! ??
      do i=1,ntrend
      sum1=sum1+aa(icom,i)
      sum2=sum2+aa(icom,i)*float(i)
      enddo
      b0=(2.*(2.*float(ntrend)+1)*sum1-6.*sum2)/
     *    	(float(ntrend)*(float(ntrend)-1.))
      b1=(12.*sum2-6.*(float(ntrend)+1)*sum1)/
     *        (dt*float(ntrend)*(float(ntrend)-1)*(float(ntrend)+1))
      do i=1,ntim ! now applied to all samples
      trend(i)=b0+b1*dt*float(i)
      enddo
      do i=1,ntim
c      aa(icom,i)=aa(icom,i)-trend(i) ! trend correction enabled
	aa(icom,i)=aa(icom,i)          ! trend correction disabled 
      enddo
	  
      amax(icom)=0.
      do i=1,ntim
      aa_abs=abs(aa(icom,i))
      if(aa_abs.gt.amax(icom)) amax(icom)=aa_abs 
      enddo
c      write(60,*) 'icom, amax= ', icom,amax(icom)
c      write(60,*)  icom,amax(icom)

	
      enddo  !end of loop over components   !!!!!!!!!

      atotmax=amax1(amax(1),amax(2),amax(3))

  
      if(keyrand.eq.0) then !!!!! output if NOT adding noise
      do i=1,ntim
      time=float(i-1)*dt
      WRITE(50,'(4(1X,E12.5))') time,aa(1,i),aa(2,i),aa(3,i)    ! 3-comp. filtered time series
c     Here, in principle, we could divide by atotmax to normalize the seismograms 
      enddo
      endif

      do icom=1,3
c	  amax(icom)=amax(icom)/atotmax   !!!!!!! NOT DIVIDE
c      write(60,*)  icom,amax(icom)
      enddo
 

      if(keyrand.eq.0) goto 5020

                        	  

c             NOISE
c

c        ISEED = 123457
c        ISEED = abs( ifix(aa(1,1000)*1e16) ) ! each station should have different seed
c        write(*,*) iseed
c        CALL RNSET (ISEED) ! for repeatibility of the results 
c 

c	  idum=12345 
      call random_seed
c Seed set up here is the same for all 3 components 
c I set seed itself to be random in order to have different noise for different stations 
c (singe run of this code is for 1 station, 3 comp)
c Caution : There is NO REPEATABILITY among runs
      call random_number(harvest)       
      idum= nint(harvest*10000.) ! random seed for Gauusian noise
      a=gasdev(-idum) ! if here, then 3 components have NON-IDENTICAL noise series! (if in the loop below,all 3 comp would have same noise)
	  write(*,*) 'random seed (single seed for 3 components): ',idum  


c      LOOP OVER  3 COMPONENTS
        do icom=1,3        ! 
c
c *************************************
      NTR=ntim

ccccc    UNIFORM DISTRIBUTION     ! each component has different noise	  
ccc      CALL RNUN (NTR, xpozice) ! returns NTR random numbers XPOZICE (= rand from 0 to 1)
ccc      call random_number(xpozice) ! Std. Fortran (no MSMSIL) returns UNIFORM DISTRIBUTION random array (8192 samples) XPOZICE (form 0 to 1)
!  
c      CALL RNNOR (NTR, xpozice) ! returns NTR random numbers XPOZICE 
c      NORmal (Gaussian) DISTRIBUTION, zero mean, unit variance  ! each component has different noise	  
c      write(*,*) icom, xpozice(1),xpozice(2),xpozice(3),xpozice(4)
!
c      xvari=0.
c	  do j=1,NTR         
c      For RNUN
c      xaux(j)= (xpozice(j) - 0.5) * 2. ! re-normalize from 0 to 1 to -1 to 1. (sigma=0.57)
c      xaux(j)=xaux(j) * (xnoise/0.57) ! re-normalize to +/- (0.57 * xnoise/0.57) = +/- xnoise
c     For RNNOR
c      xaux(j)=xpozice(j) * xnoise
c      xvari=xvari + xaux(j)**2.
c       enddo	   

c     Gaussian noise  (Num. Recipes); array xaux(1,...ntim)
	  xmean=0.
	  do j=1,ntim         
c	  write(*,*) a
	  xaux(j)= gasdev(idum) * xnoise     ! each calling of function gasdev creates a new idum value (in subroutine ran1)
c                                        ! thus we automatically call gasdev with an updated idum  
c	                                     ! Instead of idum, we can write e.g. iii, any non-defined integerm but not j (teh loop variable)!
c                                        ! xnoise (=Sigma)  here controls (defines) std deviation (sqrt variance) of the resulting random series
c                                        ! Mean value of all random series will remain = 0 
      xmean=xmean + xaux(j) 
      enddo	   
      xmean=xmean/float(ntim)
c      write(*,*) icom, xaux(1),xaux(2),xaux(3),xaux(4)
      xmean=xmean/float(ntim) ! the noise mean

	  xvari=0.
	  do j=1,ntim         
      xvari= xvari + (xaux(j)-xmean) ** 2
	  enddo	   
	  xvari=xvari/float(ntim-1) ! the noise variance (=sigma**2)
	  xsigma=sqrt(xvari)        ! the noise std. deviation  
      write(*,*) 'comp., noise mean and sigma1:',icom,xmean,xsigma ! check: output xsigma must equal to input sigma; xmean =approx= 0. 

c     CAUSAL FILTRATION of the noise IN TIME DOMAIN  (using XAPIIR by D. Harris 1990)
c
		NSAMPS=ntim
        APROTO='BU' ! Butterworth
		TRBNDW=0.  ! not used for 'BU'
		A=0.	   ! not used for 'BU'
		IORD=4 ! number of poles (4-5 recommended)
		TS=dt 
		PASSES=1 ! (1 for forward; 2 for forward and reverse = zero phase = non-causal) 
      	MAX_NT=ntim

c		if(keyfil.eq.0) TYPE='BP' ! band pass 
c		if(keyfil.eq.1) TYPE='LP' ! low pass 
        TYPE='BP' !!!!!! noise is ALWAYS generated as band-pass 
c		write(*,*) type
		FLO=f5 !!!!!!!!!!    
          if(FLO.eq.0.) FLO=1./(dt*float(ntim)) ! BandPass cannot start at 0
		FHI=f6 !!!!!!!      
c	goto 124 ! to skip filtration

	    call  XAPIIR(xaux, NSAMPS, APROTO, TRBNDW, A, IORD,
     +                 TYPE, FLO, FHI, TS, PASSES, MAX_NT)
c 124	continue
 
      do itim=1,ntim
        bb(icom,itim)=xaux(itim)    ! filtered noise    
	  enddo

c
c     INTEGRATION  in time domain   
c
       if(keydis.eq.0) goto 5001  ! if displacement is requested, noise is integrated
        X2=0.	   
        DO I=1,ntim
        X2=X2+bb(icom,i)*DT
        bb(icom,i)=X2 
        ENDDO
c	write(*,*) 'displacement'
 5001 continue
	  
      enddo  !end of loop over components   !!!!!!!!!

c      write(*,*) 'how many seconds of noise?'
c      read(*,*) xsecon ! This was read at the beginning
c     Noise was generated for all NTIM time samples
c     Here we cut the output as requested  

      ntim2= ifix(xsecon/dt)
      if(ntim2.gt.ntim) then
      write(*,*) 'corrected to ntim'
      ntim2=ntim
      endif

      xvari2=0.
      do i=1,ntim2 
      xvari2=xvari2 + bb(3,i)**2.  ! computing variance of noise we assume its mean = 0
      enddo	   
      xvari2=xvari2/float(ntim2-1)
	  xvari2=sqrt(xvari2)
      write(*,*) 'Processed noise std. deviation (sigma2)', xvari2
	  
	  ratno=xvari2/atotmax !ratio of final noise sigma and max. ampl. at a station
      write(*,*) 'Ratio between sigma2 and max.stat.amplitude:',ratno
	  
	  
	  
	  
      do i=1,ntim2 ! noise added only up to ntim2;teh base series aa is not cut! (but becuse is synth it may appear to be zero!)
      aa(1,i)=aa(1,i)+bb(1,i) ! signal PLUS noise
      aa(2,i)=aa(2,i)+bb(2,i)
      aa(3,i)=aa(3,i)+bb(3,i)
      enddo
 	 
      do i=1,ntim
      time=float(i-1)*dt
       WRITE(50,'(4(1X,E12.5))') time,aa(1,i),aa(2,i),aa(3,i)    ! 3-comp. time series
c      WRITE(50,'(4(1X,E12.5))') time,bb(1,i),bb(2,i),bb(3,i)    ! 3-comp. time series
      enddo

 5020 continue
      STOP
      END

      include "timefilters.inc"
      include "gasdev.inc"
      include "ran1.inc"