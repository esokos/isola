      subroutine filter_play(nnn,keyfil,keydis,f1,f4,timstep,b)

c Time domain causal filter calling  XAPIIR (via TIMEFILTERS.INC)

        DIMENSION b(nnn)      !! NEW

C    declaration needed for XAPIIR
        CHARACTER*2 TYPE, APROTO
        INTEGER NSAMPS, PASSES, IORD
        REAL*4 TRBNDW, A, FLO, FHI, TS 
c        REAL*4 SN(30), SD(30)
c        LOGICAL ZP

      dt=timstep
      ntim=nnn  !  now it comes as parameter of the subroutine
      
C	  keyfil= ... band pass (0) or low pass (1) or high pass (2)
C     keydis= ... output is velocity (0) or displacement (1)


C
C     FILTRATION IN THE TIME DOMAIN  (using XAPIIR by D. Harris 1990)
C

		NSAMPS=ntim
        APROTO='BU' ! Butterworth
		TRBNDW=0.  ! not used for 'BU'
		A=0.	   ! not used for 'BU'
		IORD=4 ! number of poles (4-5 recommended) the 4 for compatibility with ISOLA GUI Butt amplitude response 4th, power 8th
		TS=dt 
		PASSES=1 ! (1 for forward causal; 2 for forward and reverse = zero phase) 
		MAX_NT=ntim

		if(keyfil.eq.0) TYPE='BP' ! band pass 
		if(keyfil.eq.1) TYPE='LP' ! low pass 
		if(keyfil.eq.2) TYPE='HP' ! high pass 
		FLO=f1 !   ignored for LP
         if(FLO.eq.0.) FLO=1./(dt*float(ntim)) ! BandPass cannot start at 0
		FHI=f4    


        call  XAPIIR(b, NSAMPS, APROTO, TRBNDW, A, IORD,
     +                 TYPE, FLO, FHI, TS, PASSES, MAX_NT)

                                  
c
c     INTEGRATION  in time domain
c
     
        if(keydis.eq.0) goto 5000           
        X2=0.	   ! from VELOCITY to DISPLACEMENT
        DO I=1,ntim
        X2=X2+b(i)*DT
        b(i)=X2 
        ENDDO
 5000   CONTINUE


      RETURN
      END
      include "timefilters.inc"
