      PROGRAM syn_cor_causal2017

c 2017 output of maximum of each component
	  
c To substitute SYN_COR, using causal time-domain filter
c It makes use of a new 99.syn.dat ( more lines added)
c check for 'fixed' options below !!!!!!!!!!!!! (BandPass, shift, baseline, trend)

      DIMENSION AA(3,-100000:100000)
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
	        OPEN(60,FILE='outmax.dat')
c
      ntim=8192	 
      PI=3.14159

      do i=1,4
	read(9,*) !skipping 4 rows
      enddo
	read(9,*) dt
	read(9,*) f1,f2
	read(9,*) f3,f4
	read(9,*) keyfil ! band pass (0) or low pass (1) 
      read(9,*) keydis ! output velocity (0) or displacement (1)
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
	write(*,*) 'ish= ', ish   

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
      	MAX_NT=8192

		if(keyfil.eq.0) TYPE='BP' ! band pass 
		if(keyfil.eq.1) TYPE='LP' ! low pass 
		write(*,*) type
		FLO=f1    
          if(FLO.eq.0.) FLO=1./(dt*8192.) ! BandPass cannot start at 0
		FHI=f4      

      do itim=1,ntim
      xaux(itim)=aa(icom,itim)    
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
        aa(icom,itim)=xaux(itim)        
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
	write(*,*) 'displacement'
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
	  
      do i=1,ntim
      time=float(i-1)*dt
      WRITE(50,'(4(1X,E12.6))') time,aa(1,i),aa(2,i),aa(3,i)    ! 3-comp. time series
c     Here, in principle, we could divide by atotmax to normalize the seismograms 
      enddo

      do icom=1,3
	  amax(icom)=amax(icom)/atotmax
      write(60,*)  icom,amax(icom)
      enddo


      STOP
      END

      include "timefilters.inc"