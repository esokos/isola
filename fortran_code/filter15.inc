      subroutine filter15(keyfil,keydis,shift,f1,f4,timstep,b)

c Time domain causal filter using XAPIIR

       DIMENSION b(8192)
       DIMENSION XAUX(8192),TREND(8192)
       DIMENSION AA(-100000:100000)     ! for shift ??
C declaration needed for XAPIIR
        CHARACTER*2 TYPE, APROTO
        INTEGER NSAMPS, PASSES, IORD
        REAL*4 TRBNDW, A, FLO, FHI, TS 
c        REAL*4 SN(30), SD(30)
c        LOGICAL ZP

      dt=timstep
      ntim=8192  !  now it comes as parameter of the subroutine
      
C	keyfil= ... band pass (0) or low pass (1) or high pass (2)
C     keydis= ... output is velocity (0) or displacement (1)
c     shift=  ... shift (in seconds) to the right 

C
C     READING VELOCITY and SHHIFTING 'to the right' 
C

	  ish=ifix(shift/dt) ! shift is in parameters  

      do i=1,ntim
      aa(i+ish)=b(i)
	  enddo


C
C     FILTRATION IN THE TIME DOMAIN  (using XAPIIR by D. Harris 1990)
C

		NSAMPS=ntim
        APROTO='BU' ! Butterworth
		TRBNDW=0.  ! not used for 'BU'
		A=0.	   ! not used for 'BU'
		IORD=4 ! number of poles (4-5 recommended) the 4 for compatibility with ISOLA GUI Butt amplitude response 4th, power 8th
		TS=dt 
		PASSES=1 ! (1 for forward; 2 for forward and reverse = zero phase) 
		MAX_NT=ntim

		if(keyfil.eq.0) TYPE='BP' ! band pass 
		if(keyfil.eq.1) TYPE='LP' ! low pass 
		if(keyfil.eq.2) TYPE='HP' ! high pass 
c		write(*,*) type
		FLO=f1 !   ignored for LP
         if(FLO.eq.0.) FLO=1./(dt*float(ntim)) ! BandPass cannot start at 0
		FHI=f4    

      do itim=1,ntim
      xaux(itim)=aa(itim)    ! auxiliary xaux needed due to dimension of aa
	  enddo

        call  XAPIIR(xaux, NSAMPS, APROTO, TRBNDW, A, IORD,
     +                 TYPE, FLO, FHI, TS, PASSES, MAX_NT)


      do itim=1,ntim
      aa(itim)=xaux(itim)
	  enddo


c
C     LINEAR TREND correction of velocity
C

      sum1=0.                
      sum2=0.
c     ntrend=ifix(40./dt) from 40 seconds ? (consider shift and travel time) 
	  ntrend=ntim ! in samples; from complete record ??  
      do i=1,ntrend
      sum1=sum1+aa(i)
      sum2=sum2+aa(i)*float(i)
      enddo
      b0=(2.*(2.*float(ntrend)+1)*sum1-6.*sum2)/
     *    	(float(ntrend)*(float(ntrend)-1.))
      b1=(12.*sum2-6.*(float(ntrend)+1)*sum1)/
     *        (dt*float(ntrend)*(float(ntrend)-1)*(float(ntrend)+1))
      do i=1,ntim ! now applied to all samples
      trend(i)=b0+b1*dt*float(i)
      enddo
      do i=1,ntim
c      aa(i)=aa(i)-trend(i) ! trend correction enabled
	aa(i)=aa(i)          ! trend correction disabled 
	enddo


c
c   BASELINE correction of velocity
c
      
c	  xlim2=10. ! in seconds ??? (consider shift and travel time) 
c	  nbase=ifix(xlim2/dt)
      nbase=50  ! samples ??   
         base=0.
         DO I=1,nbase
         base=base+aa(i)
         ENDDO
         base=base/float(nbase)
         DO I=1,ntim
c	   aa(i)=aa(i)-base ! baseline correction enabled
	   aa(i)=aa(i)	  ! baseline correction disabled 
         ENDDO                    

                                  
                                  
c
c     INTEGRATION  in time domain
c
     
        if(keydis.eq.0) goto 5000           
        X2=0.	   ! from VELOCITY to DISPLACEMENT
        DO I=1,ntim
        X2=X2+aa(i)*DT
        aa(i)=X2 
        ENDDO
 5000   CONTINUE

C
C     LINEAR TREND CORRECTION of displacement 
C                             
                              
      sum1=0.                
      sum2=0.
      ntrend=ifix(40./dt) ! trend from part between P wave, 40s ????????(consider shift and travel time)
      do i=1,ntrend
      sum1=sum1+aa(i)
      sum2=sum2+aa(i)*float(i)
      enddo
      b0=(2.*(2.*float(ntrend)+1)*sum1-6.*sum2)/
     *    	(float(ntrend)*(float(ntrend)-1.))
      b1=(12.*sum2-6.*(float(ntrend)+1)*sum1)/
     *        (dt*float(ntrend)*(float(ntrend)-1)*(float(ntrend)+1))
      do i=1,ntim ! now applied to all samples
      trend(i)=b0+b1*dt*float(i)
      enddo
      do i=1,ntim
c     aa(i)=aa(i)-trend(i) ! trend correction enabled
      aa(i)=aa(i)          ! trend correction disabled 
      enddo


      do i=1,ntim
c	  b(i)=aa(i-ish) ! Possible backward time shift 
	  b(i)=aa(i)
      enddo


      RETURN
      END
      include "timefilters.inc"
