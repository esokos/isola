      COMPLEX U(8192),S(8192),ai,uu,ssave
      dimension b(8192),a(8192,240)
      data b /8192*0./


      COMMON/COM/FLE,FLI,FRI,FRE,DF,ILS,IRS,NT,NTM

c
c	Source time function (sum of triangles), with same DT as in ISOLA *raw.dat files
c     J. Zahradnik 2011 and 2015
c
c     Processing the FIRST ntr triangles ONLY (source 1) 


C Area under each one triangle is AMOMENT (where amoment is read from 666).
C Total area is their sum (irrespectively whether they overlap or not). 
c Printed on screen at the end of code is this total area = total moment. 
c It is strictly assumed that the elementary time function is triangle, not delta!


      OPEN(555,FILE='inpinv.dat')
	OPEN(666,FILE='inv222.dat')   
c      OPEN(777,FILE='allfct.dat')
      OPEN(888,FILE='timfun1.dat')
c      OPEN(999,FILE='spefct.dat')
c
c
c     Spectrum of time fctn
c
      do i=1,3
	read(555,*)
	enddo
	read(555,*) dt
      do i=1,6
	read(555,*)
	enddo
	read(555,*) nsour
      do i=1,2
	read(555,*)
	enddo
	read(555,*) f1,f2,f3,f4



	read(666,*) t0, NTR ! duration of each triangle 

	do 10 is=1,NTR  
      read(666,*) dummy,shift,amoment

      NI=13
      NT=2**NI

	auxshift=float(NT)*dt/2. !!! NEW Aug 2, 2015

      NP=NT
      NT2=NT/2
      NTM=NT2+1
      NTT=NT+2
      DF=1./(DT*FLOAT(NT))
      ai=cmplx(0.,1.)
      PI=3.141592

      FMAX=FLOAT(NTM)*DF

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      fle=f1
      fli=f2
      fri=f3
      fre=f4

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

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      do i=1,nt
      U(I)=(0.,0.)
      enddo

      do 20 I=2,NTM    ! cykl pres frnce ZACINA NA I=2 !!!!!!!!! U(1)=(0.,0.)
 
      freq=FLOAT(I-1)*DF
      OMEGA=2.*PI*FREQ

c TYPE=4        Source = triangle en deplacement
c     jeho spektrum je 4x slabsi nez ma byt
c      proto je na konci *4
	  uu= exp(ai*omega*t0/4.)
	  uu=(uu-1./uu)/2./ai
	  uu=uu/(omega*t0/2.)
	  U(I)=uu*uu    *    4. * amoment
C The triangle without amoment has area =1; Area of this triangle is amoment. 


c  source is the Fourier transform of a smooth ramp function of
c  rise time equal to tsource:
c                          !! jz To co bylo v convolu ale misto
c                          !! puvodniho t0 je ted tsource/2
cc                         !! trvani bylo asi 4 t0, ted je asi 2 t0
c                          !! a cele je to posunuto o tstart=-tsource
c     tstart=-tsource
c     c1=exp(omega*pi*tsource/4.)
c     U(I)=-ai*pi*tsource/2./(c1-1./c1)*exp(ai*omega*tstart) !displ
c     U(I)=U(I)*ai*omega    ! veloc



c  source is Heavidide step function
c      U(I)=1./ai/omega              ! displ
c      U(I)=U(I)*ai*omega    ! veloc
c	u(i)=u(i)*amoment


c  ramp made as integral from boxcar
c  boxcar of duration=tsource, shifted by tsource/2 (start at 0)
c     if(i.ne.1) then
c     U(I)=(sin(pi*freq*tsource)/(pi*freq))/tsource
c     else                      ! nepouzivej freq ??????
c     U(I)=cmplx(1.,0.)
c     endif
c     U(I)=U(I)*exp(-ai*omega*tsource/2) !disp for box = vel for ramp
c     U(I)=U(I)/ai/omega       !displ for ramp



c     symetr trapez. nabeh tau1, trvani tau1+tau2=tsource, centrovany kolem 0
c                            (nize pak posun o tsource/2)
ccc    tau1=0.1 !!! cist v datech    ????????????
c     tau1=tsource/2.   ! lich degene na trojuhelnik trvani tsource
c     tau2=tsource-tau1 !konvoluce obdelnika trvani tau1 a tau2
c     if(i.ne.1) then
c     U(I)=(sin(pi*freq*tau1)/(pi*freq)*
c    *     sin(pi*freq*tau2)/(pi*freq))/(tau1*tau2) !nepouzivat freq ale omega
c     else
c     U(I)=cmplx(1.,0.)
c     endif
c     U(I)=U(I)*exp(-ai*omega*tsource/2) !veloc (pokud konv s is=2 z Boufin)
c     U(I)=U(I)*ai*omega       !ACCEL


c     Brune's pulse, corner freq. fcor
c                      this is CAUSAL signal, spectrum at zero freq = 1
c                      ampl sp=1./(1. + freq**2/fcor**2)
c                 ! pokud je toto konvol s is=2 z Boufin je to VELOCITY
ccc   U(I)=(2.*pi*fcor)**2./(2.*pi*fcor+2.*pi*ai*freq)**2  ! opravdu kauzalni !!!
c     U(I)=U(I)                !final output will be DISPL and VELOC
c     U(I)=U(I)*ai*omega       !final output will be VELOC and ACCEL

c     sp.cas. fce ze souboru
c     read(111,*) xreu,ximu
c     U(I)=cmplx(xreu,ximu)    ! pro fci lich., troj. atd je zde VELOC
c     U(I)=U(I)*ai*omega       !ACCEL



c     U(I)=U(I)*cexp(-2*pi*ai*freq*(shift    ))   ! no time shift 
      U(I)=U(I)*cexp(-2*pi*ai*freq*(shift+auxshift)) ! NEW Aug 2, 2015   !  
C This shift is to avoid that (due to use of FFT) the part of time function
C corresponinging to t<0 will be at the end of the FFT series.
C This is good only for functions not starting more than auxshift before t=0. 

c     XCOR=freq
c     YCOR=CABS(U(I))
c     WRITE(20,'(1X,E12.6,1X,E12.6)') XCOR,YCOR

  20  continue ! konec cyklu pres frnce

c	write(*,*) u(1)

      DO  25 I=2,NT2
      J=NTT-I
      U(J)=CONJG(U(I))
  25  continue






c	write(*,*) 'no filtration !'
c     call FW(U) !              

c	write(*,*) 'filtration !' ! remove c in call FW !!! (it will modify the moment!!)
c      call FW(U) !             



c   	u(1)=CMPLX(real(u(2)),0.) !    'Repairing' u(1) which was stabilized above
   	u(1)=CMPLX(amoment   ,0.) !     New Aug 2, 2015 
	


                           !(zadna konst, protoze je to analyt predpis sp.)
      CALL FCOOLR(NI,U,+1.)

      do i=1,np
      a(i,is)=REAL(U(I))/FLOAT(NT)/DT          ! cas. fce
cc                                  ! zde je jedina konst df=1/N/dt
cc                                  ! protoze se transformovalo analyt spek.
      b(i)=b(i) + a(i,is)
      enddo

  10  continue  ! konec cyklu pres zdroje








c      do i=1,np
c      time=FLOAT(I-1)*DT
c      write(777,'(21(1x,e12.6))') time,(a(i,is),is=1,nsour)
c      enddo

      do i=1,np
      time=FLOAT(I-1)*DT
c      write(888, '(2(1x,e12.6))') time,b(i)
      write(888, '(2(1x,e12.6))') time-auxshift,b(i) ! NEW Aug 2, 2015
c	to compensate the shift for plotting.
c      Total time function b(i) is the moment rate [Nm/s] because amoment is in Nm.
      enddo


c
C     DIRECT FOURIER TRANSFORM
C
      DO I=1,NP
      S(I)=CMPLX(B(I),0.)
      enddo
      IF(NT.EQ.NP)GO TO 32
      NP1=NP+1
      DO  I=NP1,NT
      S(I)=CMPLX(.0,.0)
      enddo
   32 CALL FCOOLR(NI,S,-1.)
c
C     OUTPUT OF complex SPECTRUM
C
	ssave=s(1)*dt
      DO I=1,NTM
cccc     XCOR=FLOAT(I-1)*DF
cccc     YCOR=DT*CABS(S(I))   ! v S stale chybi konst dt, ale jde na vystup
      s(i)=s(i) * dt       ! ted uz S ma dt v sobe
c	s(i)=s(i)/ssave		 !NORMALIZATION TO UNIT MOMENT
c      WRITE(999,'(2(1X,E12.6))') real(s(i)),aimag(s(i))
      ENDDO

	xmoment=real(s(1))  

	write(*,*)
	write(*,*) 'timfun1.dat was created'
      write(*,*)
	write(*,*) 'moment= ', xmoment

	STOP
      END


C=======================================================================
C
C       SUBROUTINE FCOOLR(K,D,SN)
C       FAST FOURIER TRANSFORM OF N = 2**K COMPLEX DATA POINTS
C       REPARTS HELD IN D(1,3,...2N-1), IMPARTS IN D(2,4,...2N).
C------------------------------------------------------------------
C
        SUBROUTINE FCOOLR(K,D,SN)
        DIMENSION INU(20),D(16384)
        LX=2**K
        Q1=LX
        IL=LX
        SH=SN*6.28318530718/Q1
        DO 10 I=1,K
        IL=IL/2
10      INU(I)=IL
        NKK=1
        DO 40 LA=1,K
        NCK=NKK
        NKK=NKK+NKK
        LCK=LX/NCK
        L2K=LCK+LCK
        NW=0
        DO 40 ICK=1,NCK
        FNW=NW
        AA=SH*FNW
        W1=COS(AA)
        W2=SIN(AA)
        LS=L2K*(ICK-1)
        DO 20 I=2,LCK,2
        J1=I+LS
        J=J1-1
        JH=J+LCK
        JH1=JH+1
        Q1=D(JH)*W1-D(JH1)*W2
        Q2=D(JH)*W2+D(JH1)*W1
        D(JH)=D(J)-Q1
        D(JH1)=D(J1)-Q2
        D(J)=D(J)+Q1
20      D(J1)=D(J1)+Q2
        DO 29 I=2,K
        ID=INU(I)
        IL=ID+ID
        IF(NW-ID-IL*(NW/IL)) 40,30,30
30      NW=NW-ID
29      CONTINUE
40      NW=NW+ID
        NW=0
        DO 6 J=1,LX
        IF(NW-J) 8,7,7
7       JJ=NW+NW+1
        J1=JJ+1
        JH1=J+J
        JH=JH1-1
        Q1=D(JJ)
        D(JJ)=D(JH)
        D(JH)=Q1
        Q1=D(J1)
        D(J1)=D(JH1)
        D(JH1)=Q1
8       DO 9 I=1,K
        ID=INU(I)
        IL=ID+ID
        IF(NW-ID-IL*(NW/IL)) 6,5,5
5       NW=NW-ID
9       CONTINUE
6       NW=NW+ID
        RETURN
        END


      SUBROUTINE FW(S)
      COMMON/COM/FLE,FLI,FRI,FRE,DF,ILS,IRS,NT,NTM
      DIMENSION  S(8192)
      COMPLEX S
C
      FEXP=1.
C
      PI=3.141592
      ILEFT=FLI/DF+1.1
      IRIGHT=FRI/DF+1.1
      IF(IRIGHT.GT.IRS)IRIGHT=IRS
      IF(ILEFT.LT.ILS)ILEFT=ILS
      IF(IRIGHT.GT.NTM)IRIGHT=NTM
      NLEFT=ILEFT-ILS
      NRIGHT=IRS-IRIGHT
      IF(NLEFT.GT.0)DLEFT=PI/FLOAT(NLEFT)
      IF(NRIGHT.GT.0)DRIGHT=PI/FLOAT(NRIGHT)
C
      NTT=NT+2
      DO 1 I=1,NTM
      J=NTT-I
      FIF=I-IRIGHT
      FAF=I-ILS
      IF(I.GE.ILEFT.AND.I.LE.IRIGHT)GO TO 1
      IF(I.LE.ILS.OR.I.GE.IRS)S(I)=(0.0,0.0)
      IF(I.GT.ILS.AND.I.LT.ILEFT)
     1S(I)=S(I)*(0.5*(1.-COS(DLEFT*FAF)))**FEXP
      IF(I.GT.IRIGHT.AND.I.LT.IRS)
     1S(I)=S(I)*(0.5*(COS(DRIGHT*FIF)+1.))**FEXP
      IF(I.EQ.1.OR.I.EQ.NTM)GO TO 1
      S(J)=CONJG(S(I))
    1 CONTINUE
C
      RETURN
      END
