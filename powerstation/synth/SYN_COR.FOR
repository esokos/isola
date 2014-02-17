      PROGRAM SYN_COR
c                         DISPL,    see line 238-242
c                      no   time shift   50 sec, see line 239
c                         NI=13 fixed (8192) !!!!!!!!!!!!
c
c  
c	 If the output should serve as 'data' this code needs 3 modifications: no displacment, no 50s shift, no filtration

c     Pre-processing 3-component SYNTETIC DW record from  a SINGLE station
c     J. Zahradnik, July 2000

      COMPLEX S(32768)
      DIMENSION AA(3,-100000:100000)
      DIMENSION A(-100000:32768)
      DIMENSION ASMO(32768)
      DIMENSION OUT(3,32768)
      DIMENSION OUTSP(3,32768)
      complex  COUTSP(3,65536),cycor,cu
      COMMON/COM/FLE,FLI,FRI,FRE,DF,ILS,IRS,NT,NTM

      CHARACTER*8  TEXTDATE
      CHARACTER*6  TXT2
      CHARACTER*14 TXT3

      OPEN(9,FILE='i.dat')
      OPEN(10,FILE='row.dat')
      OPEN(50,FILE='outsei.dat')
c     OPEN(60,FILE='outspe.dat')
c     OPEN(70,FILE='text.dat')
c


      do i=1,2              !reading from *.sig
      read(9,*)     ! skipping 2 rows
      enddo
      read(9,*) ihy1,ihy2,xhy3                  !reading hypotime
      hypotim=float(ihy1*3600) + float(ihy2*60) + xhy3
                                                !reading starttime
      read(9,*) ifr1,ifr2,xfr3  !needs SPACES, not :, but  enables FREE format
      frsttim=float(ifr1*3600) + float(ifr2*60) + xfr3


      mag=200                    
      magpul=mag/2


      read(9,*) dt                 !time step


c     np=usedtim/dt + mag
      NP=8192 ! Fixed !!!!!!!! 


      nskip=(hypotim-frsttim)/dt - magpul    
      nskip=0        !!!!!!!   F I X E D (hypotime, starttime have NO effect)

      if(nskip.lt.0) then
       nskip=0
       write(*,*) 'WARNING !!!! NSKIP !!!!'
      endif




c      read(9,*) keyrot
      keyrot=0 ! fixed

      if(keyrot.eq.1) then
       txt2='_R-T-Z'
      else
       txt2='_N-E-Z'
      endif
      txt3=txt2
c     write(70,'(a14)') txt3

c      read(9,*) keynor
      keynor=0 ! fixed

      if(NP.GT.32768) then
       write(*,*) 'time series exceeds dimensions; cut to 32768'
       NP=32768
      endif
c
c     NI=AINT(ALOG(FLOAT(NP))/ALOG(2.))+1
      NI=13          ! fixed !!!!!!!!!!!!!!!!!!
c  !!!
      if(NI.gt.15) NI=15
c  !!!
      PI=3.14159
      NT=2**NI
      NT2=NT/2
      NTM=NT2+1
      NTT=NT+2
      DF=1./(DT*FLOAT(NT))
      FMAX=FLOAT(NTM)*DF
c
c     fle=0.
c     fre=fmax
c
c     READING FREQ. WINDOW PARAMETERS
c
c     WRITE(*,*) 'fmax=', FMAX
c     write(*,*) 'Please give parametres of filter, in Hz, all < fmax:'
c     write(*,*) 'Left taper (from f=fle to f=fli);  fle=?, fli=?'
      read(9,*) fle,fli
c     write(*,*) 'Right taper (from f=fri to f=fre); fri=?, fre=?'
      read(9,*) fri,fre
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




      
c      read(9,*) keyabs,aw,tl
      keyabs=0 !fixed


C
c      READING INPUT 3-COMPONENT  TIME SERIES
c         SYN already are in R,T,Z
      i=0
  100 i=i+1
      READ(10,*,end=110)dum,aa(1,i-nskip),aa(2,i-nskip),aa(3,i-nskip)
      goto 100
  110 continue

c
c      LOOP OVER  COMPONENTS
c
      do icom=1,3        ! 1,2,3=R,T,Z
c
c     FINDING BASELINE VALUE
c
      asum=0.
      do i=1,100
      a(i)=aa(icom,i)
      asum=asum+a(i)
      enddo

      baseline=asum/100.
      write(*,*) baseline

C
C     DIRECT FOURIER TRANSFORM OF THE BASELINE CORRECTED SERIES
C         (conversion counts to m/s included)
C
      DO I=1,NP
      time=float(i-1)*dt

c     a(i)=aa(icom,i)-baseline   ! baseline correction
      a(i)=aa(icom,i)            ! baseline correction  DISABLED

c     a(i)=a(i)*420e-12          ! conversion from counts to m/s Guralp
c     a(i)=a(i)*376e-11          ! conversion from counts to m/s Lennartz
      a(i)=a(i)                  ! conversion from counts DISABLED
      enddo





      if(keyabs.eq.1) then
       DO I=1,NP
       time=float(i-1)*dt
       umut=pi*aw*time/tl
       a(i)=a(i)*exp(-umut)
       ENDDO
      endif




       DO I=1,NP    ! stale o mag vetsi ale uz je posun, takze
c                                fyzicky zacatek je i=1 a konec NP-mag
c                           (na konce pridano mag bodu zbytecne)
c  proto pozdeji v nove verzi nekde NA konci programu tech mag URIZNU !!!!!
c  chci-li ted neco aplikovat pred fyzic. koncem zaznamu, neni to pred
c  bodem I=NP, nybrz pred I=NP-mag !!!!!!!!!!!!!!!!!!!!!!!
c       sem prijde ted hladici okno na rezani

c     if(i.ge.np-(mag+200).and.i.le.np-mag) then      !OKNO
c     pfi=3.141592*float(i-np+(mag+200))/float(200)
c     fifi=(cos(pfi)+1.)/2.
c     a(i)=a(i)*fifi
c     endif
c
c     if(i.ge.1.and.i.le.201) then
c     pfi=3.141592*float(i-1)/float(200)
c     fifi=(1.-cos(pfi))/2.
c     a(i)=a(i)*fifi
c     endif


      time=float(i-1)*dt
c     WRITE(15,'(1X,E12.6,1X,E12.6)') time,a(i)
      S(I)=CMPLX(A(I),.0)
      enddo
      IF(NT.EQ.NP)GO TO 32
      NP1=NP+1
      DO  I=NP1,NT
      S(I)=CMPLX(.0,.0)
      enddo
   32 CALL FCOOLR(NI,S,-1.)

c
c      NON-FILTERED AMPLITUDE SPECTRUM
c
c     do I=1,NTM
c     XCOR=FLOAT(I-1)*DF
c     YCOR=DT*CABS(S(I))
c     WRITE(20,'(1X,E12.6,1X,E12.6)') XCOR,YCOR
c     enddo
c
c     ARTIFICIAL TIME SHIFT
c
      cu=cmplx(0.,1.)         !   POZOR   umely casovy posun o 50 sec
      DO  I=2,NT2
      frr=float(i-1)*df
      S(I)=S(I)*EXP(-2.*pi*cu*frr*50.)
      enddo
c
c     CONVERSION FROM VELOCITY TO DISPLACEMENT
c
      cu=cmplx(0.,1.)
      DO  I=2,NT2
      frr=float(i-1)*df
      S(I)=S(I)/(2.*pi*cu*frr)     ! POS !!!!!!!!!!!!
      enddo
c
c     do i=1,NTM                 ! nove **********************
c     coutsp(icom,i)=S(I)        ! complex sp without DT before filtration
c     enddo

c
c     FILTRATION IN SPECTRAL DOMAIN
c
      CALL FW(S)
C
C     preparation (not OUTPUT) OF FILTERED complex (not AMPLITUDE) SPECTRUM
C
      nmez=ILS
      if(nmez.eq.1) nmez=2
      DO I=nmez,IRS
      XCOR=FLOAT(I-1)*DF
      YCOR=DT*CABS(S(I))  ! DT included HERE
c     CYCOR=S(I)        ! multiplic by DT NOT included here
c     WRITE(30,'(1X,E12.6,1X,E12.6)') XCOR,YCOR
       outsp(icom,i)=ycor   !DT included
      enddo

C
C     INVERSE FOURIER TRANSFORM
C
      DO  I=2,NT2
      J=NTT-I
      S(J)=CONJG(S(I))
      enddo
      CALL FCOOLR(NI,S,+1.)
C
C      OUTPUT OF FILTERED TIME SERIES
C
      DO I=1,np
      XCOR=FLOAT(I-1)*DT
      YCOR=REAL(S(I))/FLOAT(NT)
c     WRITE(40,'(1X,E12.6,1X,E12.6)') XCOR,YCOR
       out(icom,i)=ycor
      enddo

      enddo  !end of loop over components

c
c     READING AZIMUT
c
c     write(*,*) 'azimut(deg)=?'
c     read(12,*)                         ! skip 1st line (text)
c     read(12,*)                         ! skip 2nd line (text)
c     read(12,*) dum1,dum2,dum3,azimut   ! 3rd line good for Clau
c     write(*,*) 'station  azimut(deg)=',azimut

c     arot=azimut*pi/180.

c
c     ROTATION FROM E,N,Z into T,R,Z  (TIME SERIES)
c                v t o m t o     p o r a d iii
c     if(keyrot.eq.0) arot=0.
c     do i=1,np
c     ou1=    out(1,i)*cos(arot)+out(2,i)*sin(arot)   ! old (wrong)
c     ou2=-1.*out(1,i)*sin(arot)+out(2,i)*cos(arot)   ! old (wrong)
c     ou1=-1.*out(1,i)*cos(arot)+out(2,i)*sin(arot)
c     ou2=-1.*out(1,i)*sin(arot)-out(2,i)*cos(arot)
c     ou1=-ou1
c     ou2=-ou2
c     ou3=out(3,i)
c     out(1,i)=ou1
c     out(2,i)=ou2
c     out(3,i)=ou3
c     enddo
c
c     ROTATION FROM E,N,Z into T,R,Z  (!!!!  complex !!!!  SPECTRUM)
c
c     if(keyrot.eq.0) arot=0.
c     do i=1,NTM
c     ou1sp=cabs(coutsp(1,i)*cos(arot)+coutsp(2,i)*sin(arot))    !  old
c     ou2sp=cabs(-1.*coutsp(1,i)*sin(arot)+coutsp(2,i)*cos(arot)) ! old
c     ou1sp=cabs(-coutsp(1,i)*cos(arot)+coutsp(2,i)*sin(arot))
c     ou2sp=cabs(-1.*coutsp(1,i)*sin(arot)-coutsp(2,i)*cos(arot))
c     ou3sp=cabs(coutsp(3,i))
c     outsp(1,i)=DT*ou1sp   ! DT included NOW
c     outsp(2,i)=DT*ou2sp
c     outsp(3,i)=DT*ou3sp
c     enddo

c
c     FINDING MAXIMUM VALUES OF TIME SERIES
c
      amax1=0.
      amax2=0.
      amax3=0.
      do i=1,np
      if(abs(out(1,i)).gt.amax1) amax1=abs(out(1,i))
      if(abs(out(2,i)).gt.amax2) amax2=abs(out(2,i))
      if(abs(out(3,i)).gt.amax3) amax3=abs(out(3,i))
      enddo

c
c     NORMALIZATION AND OUTPUT OF TIME SERIES
c
c     do i=1,np ! old
      do i=1,NT ! new
      time=FLOAT(I-1)*DT
      if(keynor.eq.1) then
       ou1=out(1,i)/amax1
       ou2=out(2,i)/amax2
       ou3=out(3,i)/amax3
      else
       ou1=out(1,i)
       ou2=out(2,i)
       ou3=out(3,i)
      endif
c !!!!!!!!!!!!!! here succession NOT changed; it is R, T, Z
      WRITE(50,'(4(1X,E12.6))') time,ou1,ou2,ou3    ! 3-comp. time series
      enddo
c      write(50,*) '*'
c      timmax=FLOAT(np-1)*DT                         ! true maxima output
c    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!here also succession NOT changed
c      WRITE(50,'(7(1X,E12.6))') timmax,0.,0.,0.,amax1,amax2,amax3



c
c     NORMALIZATION OF SPECTRUM (by max of time series !)
c                DISABLED
c        EVEN IF SEISMOGRAMS WERE NORMALIZED, SPECTRA ARE  N O T !!!
c     *****************
      keynor=0
c     *****************
      nmez=ILS
      if(nmez.eq.1) nmez=2    ! to prevent problems with plotting zero in LOG
c             new     !!!!!!!!!!!!!!!!!!!!!!!!!
      do i=2,IRS-5   ! to prevent too small values in ploting
      freq=float(i-1)*DF
      if(keynor.eq.1) then
       ou1sp=outsp(1,i)/amax1
       ou2sp=outsp(2,i)/amax2
       ou3sp=outsp(3,i)/amax3
      else
       ou1sp=outsp(1,i)
       ou2sp=outsp(2,i)
       ou3sp=outsp(3,i)
      endif




c            OUTPUT OF SPECTRUM
c                  succession NOT changed !!!!!!!!!!
c     WRITE(60,'(4(1X,E12.6))') freq,ou1sp,ou2sp,ou3sp  ! 3-comp. spectrum
      enddo
c     write(60,*) '*'
c     frqmax=FLOAT(IRS-1)*DF                         ! true maxima output
c                  !!!! here also !!!!!!
c     WRITE(60,'(7(1X,E12.6))') frqmax,10.,10.,10.,amax1,amax2,amax3
      GOTO 2000

 1000 CONTINUE
c     FORMAL OUTPUT FOR MISSING RECORDS
c
c     np=4096
c     dt=0.005
c     df=1./40.96
c
c     do i=1,np
c     time=FLOAT(I-1)*DT
c     WRITE(50,'(4(1X,E12.6))') time,0.,0.,0.       ! 3-comp. time series
c     enddo
c
c     do i=2,2048
c     freq=float(i-1)*DF
c     WRITE(60,'(4(1X,E12.6))') freq,1.,1.,1.           ! 3-comp. spectrum
c     enddo


C
 2000 STOP
      END


      SUBROUTINE FW(S)
      COMMON/COM/FLE,FLI,FRI,FRE,DF,ILS,IRS,NT,NTM
      DIMENSION S(32768)
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
C
C=======================================================================
C
C       SUBROUTINE FCOOLR(K,D,SN)
C       FAST FOURIER TRANSFORM OF N = 2**K COMPLEX DATA POINTS
C       REPARTS HELD IN D(1,3,...2N-1), IMPARTS IN D(2,4,...2N).
C------------------------------------------------------------------
C
        SUBROUTINE FCOOLR(K,D,SN)
        DIMENSION INU(20),D(65536)
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
