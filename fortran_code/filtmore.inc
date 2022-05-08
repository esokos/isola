
      subroutine filtmore(timstep,a,b)

c a=input time series (when calling from maniobs it is DISPL)
c a=ouput envelope of the time series
c b=output ampl.sp. of the time series

      COMPLEX S(8192)
      complex ai
      DIMENSION A(8192),B(8192)

c      COMMON/COM/FLE,FLI,FRI,FRE,DF,ILS,IRS,NT,NTM


      NI=13 ! now fixed    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      dt=timstep
      fnyq=1./(2.*dt)
      fle=0.
      fli=0.
      fri=fnyq
      fre=fnyq
      


      ai=cmplx(0.,1.)
      PI=3.141592

      NT=2**NI
      NP=NT
      NT2=NT/2
      NTM=NT2+1
      NTT=NT+2
      DF=1./(DT*FLOAT(NT))
      FMAX=FLOAT(NTM)*DF
c
      ILS=FLE/DF+1.1
      IRS=FRE/DF+1.1
      IF(ILS.GE.NTM)THEN
        WRITE(*,*) 'wrong left window edge, set to f=0'
        ILS=1
        FLE=0.
        FLI=DF
      ENDIF
      IF(IRS.GT.NTM)THEN
        WRITE(*,*) 'wrong right window edge, set to f=fmax'
        IRS=NTM
        FRE=(IRS-1)*DF
        FRI=FRE-1
      ENDIF
      NFW=IRS-ILS+1
C
c ******************************************************
c

c
C     DIRECT FOURIER TRANSFORM
C
      DO I=1,NP
      S(I)=CMPLX(A(I),.0)
      enddo
      IF(NT.EQ.NP)GO TO 32
      NP1=NP+1
      DO  I=NP1,NT
      S(I)=CMPLX(.0,.0)
      enddo
   32 continue

c  complex spectrum of VELOCITY
      CALL FCOOLR(NI,S,-1.) 

c  artificial time shift 50 sec
c          DO  I=2,NTM
c          frr=float(i-1)*df
c          S(I)=S(I)*EXP(-2.*pi*ai*frr*50.)
c          enddo

c     complex pectrum of VELOCITY transformed to DISPLACEMENT
c       DO  I=2,NTM
c       frr=float(i-1)*df
c       S(I)=S(I)/(2.*pi*ai*frr)
c       enddo
C
C      TIME SERIES          ! available also below but not on output
c      DO I=1,NP
c      ??pole??(i)=REAL(S(I))/FLOAT(NT)    ! constant  dt*df=1/N; could be third output array
c      ENDDO

       
C     FILTRATION (4 param) no need, this code is called after filtration
c     CALL FW(S)  

C     AMPLITUDE SPECTRUM 
      do I=1,NT
      b(i)=abs(S(I))*dt      ! ampl. spec. with dt; OUTPUT ARRAY
      enddo

C displacement time series and its ENVELOPE (via Hilbert)       
      
      NT=2**NI      
      NT22=NT/2+2
      S(1)=0.5*S(1)
      S(NT22-1)=0.5*S(NT22-1)
      do i=NT22,NT
      S(i)=cmplx(0.,0.)
      enddo
      CALL FCOOLR(NI,S,1.)      ! INVERSE TRANSFORM
      do i=1,NT
      fce=2.* real(S(i))/float(NT) ! time series (2 because of the above 0.5)
      gce=2.*aimag(S(i))/float(NT) ! Hilbert transform
      a(i)=sqrt(fce**2.+gce**2.) !envelope; OUTPUT ARRAY
c     c(i)=fce ! presently NOT on output 
      enddo

      RETURN
      END
 
 