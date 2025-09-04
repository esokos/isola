
      subroutine filtless_16384(timstep,a,b)

c a=input time series (when calling from maniobs it is DISPL)
c b=output ampl.sp. of the time series

      COMPLEX S(16384)
      complex ai
      DIMENSION A(16384),B(16384)

c      COMMON/COM/FLE,FLI,FRI,FRE,DF,ILS,IRS,NT,NTM


      NI=14 ! now fixed    !!!!!!!!!! 1024 !!!!!!!!!!!!!

      dt=timstep

c      fnyq=1./(2.*dt)
c      fle=0.
c      fli=0.
c      fri=fnyq
c      fre=fnyq
      


      ai=cmplx(0.,1.)
      PI=3.141592
      NT=2**NI
      NP=NT
      NT2=NT/2
      NTM=NT2+1

c      NTT=NT+2
c      DF=1./(DT*FLOAT(NT))
c      FMAX=FLOAT(NTM)*DF
c
c      ILS=FLE/DF+1.1
c      IRS=FRE/DF+1.1
c      IF(ILS.GE.NTM)THEN
c        WRITE(*,*) 'wrong left window edge, set to f=0'
c        ILS=1
c        FLE=0.
c        FLI=DF
c      ENDIF
c      IF(IRS.GT.NTM)THEN
c        WRITE(*,*) 'wrong right window edge, set to f=fmax'
c        IRS=NTM
c        FRE=(IRS-1)*DF
c        FRI=FRE-1
c      ENDIF
c      NFW=IRS-ILS+1
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

       
C     FILTRATION (4 param) no need, this code is called after filtration
c     CALL FW(S)  

C     AMPLITUDE SPECTRUM 

c     do I=1,NT
      do I=1,NTM        ! only up to Nyquist
      b(i)=abs(S(I))*dt      ! ampl. spec. with dt; OUTPUT ARRAY
      enddo


      RETURN
      END
      include "fcoolr.inc"

 