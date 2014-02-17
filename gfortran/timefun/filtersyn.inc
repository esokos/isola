
      subroutine filterSYN(f1,f2,f3,f4,timstep,a)


      COMPLEX S(8192)
      complex ai
      DIMENSION A(8192)
      COMMON/COM/FLE,FLI,FRI,FRE,DF,ILS,IRS,NT,NTM


      NI=13 ! now fixed    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


      fle=f1
      fli=f2
      fri=f3
      fre=f4
      dt=timstep


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

c           ncut=ifix(50./dt) *2    !!!!! shift 50 sec x 2 !!!!!!!! FIX
c           do i=NP-ncut,np     ! 50 sec needed because of the shift below
c           s(i)=cmplx(0.,0.)        
c           enddo
c this cut is important due to artificial shift of 50 sec
c we cut the last 2x 50 sec: 50 sec beyond end of time window 
c                     (to prevent alias coming from the shift)
c               and           50 sec before end of time window
c                    (to prevent alias coming from fitering)
c                                                                     
c if needed it can be reduced, e.g. to 30 sec, or 20 sec
c (as the artificial shift below)
c CAUTION: in some cases, e,g, shallow source depth, when synthetics
c have a small trend or problems due to aw, cut produces jump which
c is then seen not only 100 (or 100-50) sec before end, but also at
c t=0 (later shifted to 1st subsource origin time)


      CALL FCOOLR(NI,S,-1.)


                               ! ATTENTION  NO artificial time shift !!!
          DO  I=2,NTM
          frr=float(i-1)*df
          S(I)=S(I)*EXP(-2.*pi*ai*frr*0.)
          enddo
c the shift is very important to prevent problems due to filtering
c filtering lenghtens the seismo before origin time and everything
c before origin time is lost 
c (this results in abrupt cut at t=0, later seen at the source time of 1st subsource)
c however, shift must be done carefully: signal should not beyond time window to the right 
c also remember that once we produce elemse, this is later
c shifted (according the subevent source time) in time domain, so that
c everything outside time window is lost=zeroed

                               ! from velocity to DISPLACEMENT !!!!!!!!! 
       DO  I=2,NTM
       frr=float(i-1)*df
c       S(I)=S(I)/(2.*pi*ai*frr)			 !!!!!!!!!!!! REMOVED 
       S(I)=S(I)
	   enddo


         CALL FW(S)           !!!!!!!! temporarily removed or included ????????????????????                       
                              ! filter should be used always! it is important however to remove filter when PRODUCING sunt data, but that should be made by inpinv, not here
C                             ! then I can make inversions with same filter for (syn) 'data' as wellas synthtics
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

      DO I=1,NP
      a(i)=REAL(S(I))/FLOAT(NT)    ! constant  dt*df=1/N
      ENDDO

      RETURN
      END

