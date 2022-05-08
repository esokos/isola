	program only_kagan

C TO CALCULATE KAGAN angle BETWEEN TWO SOLUTIONS ONLY


      real *8 str1old,dip1old,rake1old
	real *8 str1new,dip1new,rake1new
	real *8 rotangle,theta,phi

	write(*,*)
	write(*,*) 'READ REFERENCE strike1, dip1, rake1'
	read(*,*)  str1,dip1,rake1
	write(*,*) 'READ current  strike2, dip2, rake2'
      read(*,* ) str2,dip2,rake2

    	str1old=str1
 	dip1old=dip1
	rake1old=rake1


	str1new=str2
	dip1new=dip2
	rake1new=rake2
	  
	CALL MINDCROT 
     *  (str1old,dip1old,rake1old,str1new,dip1new,rake1new,
     *   rotangle,theta,phi)

	write(*,*) 'rotangle= ', rotangle

	stop
	end



 ! After Kagan, Y. Y. (1991). 3-D rotation of double-couple earthquake sources, Geophys. J. Int., 106(3), 709-716.

      SUBROUTINE MINDCROT
     * 	 (strike1,dip1,rake1,strike2,dip2,rake2,rotangle,theta,phi)
    ! Provides minimum rotation between two DC mechanisms
    ! minimum rotation ROTANGLE along axis given by THETA and PHI
      IMPLICIT NONE
      REAL*8 strike1,dip1,rake1,strike2,dip2,rake2,rotangle,theta,phi
      REAL*8,DIMENSION(4):: Q1,Q2,Qdum,Qdum2,Q
      REAL*8 maxval,dum
      INTEGER ICODE,i

      CALL QUATFPS(Q1,strike1,dip1,rake1)
      CALL QUATFPS(Q2,strike2,dip2,rake2)
      maxval=180.
      do i=1,4
      CALL F4R1(Q1,Q2,Qdum,i)
      CALL SPHCOOR(Qdum,rotangle,theta,phi)
      if(rotangle<maxval)then
        maxval=rotangle
        Q=Qdum
      endif
      enddo
      CALL SPHCOOR(Q,rotangle,theta,phi)

      END



      SUBROUTINE QUATFPS (QUAT, DDi,DAi,SAi)
    ! calculates rotation quaternion corresponding to given focal mechanism
    ! input: strike (DD), dip (DA), rake (SA)
    ! output: QUAT
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8, PARAMETER:: RAD=57.295779513082320876798154814105d0
      REAL*8 QUAT(4)
 
      ERR=1.d-15
      IC=1
      DD=DDi/RAD
      DA=DAi/RAD
      SA=SAi/RAD
      CDD=dcos(DD)
      SDD=dsin(DD)
      CDA=dcos(DA)
      SDA=dsin(DA)
      CSA=dcos(SA)
      SSA=dsin(SA)
      S1=CSA*SDD-SSA*CDA*CDD
      S2=-CSA*CDD-SSA*CDA*SDD
      S3=-SSA*SDA
      V1=SDA*CDD
      V2=SDA*SDD
      V3=-CDA
    
      AN1=S2*V3-V2*S3
      AN2=V1*S3-S1*V3
      AN3=S1*V2-V1*S2

      D2=1.d0/dsqrt(2.d0)
      T1=(V1+S1)*D2
      T2=(V2+S2)*D2
      T3=(V3+S3)*D2
      P1=(V1-S1)*D2
      P2=(V2-S2)*D2
      P3=(V3-S3)*D2

      U0=( T1+P2+AN3+1.d0)/4.d0
      U1=( T1-P2-AN3+1.d0)/4.d0
      U2=(-T1+P2-AN3+1.d0)/4.d0
      U3=(-T1-P2+AN3+1.d0)/4.d0
      UM=dmax1(U0,U1,U2,U3)
      if(UM==U0)goto 10
      if(UM==U1)goto 20
      if(UM==U2)goto 30
      if(UM==U3)goto 40
      write(*,*)'INTERNAL ERROR';stop

  10  ICOD=1*IC
      U0=dsqrt(U0)
      U3=(T2-P1)/(4.d0*U0)
      U2=(AN1-T3)/(4.d0*U0)
      U1=(P3-AN2)/(4.d0*U0)
      goto 50

  20  ICOD=2*IC
      U1=dsqrt(U1)
      U2=(T2+P1)/(4.d0*U1)
      U3=(AN1+T3)/(4.d0*U1)
      U0=(P3-AN2)/(4.d0*U1)
      goto 50

  30  ICOD=3*IC
      U2=dsqrt(U2)
      U1=(T2+P1)/(4.d0*U2)
      U0=(AN1-T3)/(4.d0*U2)
      U3=(P3+AN2)/(4.d0*U2)
      goto 50

  40  ICOD=4*IC
      U3=dsqrt(U3)
      U0=(T2-P1)/(4.d0*U3)
      U1=(AN1+T3)/(4.d0*U3)
      U2=(P3+AN2)/(4.d0*U3)
      goto 50

  50  TEMP=U0*U0+U1*U1+U2*U2+U3*U3
      if(dabs(TEMP-1.d0)>ERR)then
      write(*,*)'INTERNAL ERROR';stop
      endif

      QUAT(1)=U1
      QUAT(2)=U2
      QUAT(3)=U3
      QUAT(4)=U0

      END


      SUBROUTINE SPHCOOR (QUAT, ANGL, THETA, PHI)
    !returns rotation angle (ANGL) of a counterclockwise rotation
    !and spherical coordinates (colatitude THETA and azimuth PHI) of the
    !rotation pole. THETA=0 corresponds to vector pointing down.
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 QUAT(4)
    
      if(QUAT(4)<0.d0)QUAT(:)=-QUAT(:)
      Q4N=dsqrt(1.d0-QUAT(4)**2)
      COSTH=1.d0
      if(dabs(Q4N)>1.d-10)COSTH=QUAT(3)/Q4N
      if(dabs(COSTH)>1.d0)COSTH=IDINT(COSTH)
      THETA=dacosd(COSTH)
      ANGL=2.d0*dacosd(QUAT(4))
      PHI=0.d0
      if(dabs(QUAT(1))>1.d-10.or.dabs(QUAT(2))>1.d-10)
     *               	 PHI=datan2d(QUAT(2),QUAT(1))
      if(PHI<0.d0)PHI=PHI+360.d0
    
      END


      SUBROUTINE QUATP (Q1,Q2,Q3)
    !calculates quaternion product Q3=Q2*Q1
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8, DIMENSION(4):: Q1,Q2,Q3

      Q3(1)= Q1(4)*Q2(1)+Q1(3)*Q2(2)-Q1(2)*Q2(3)+Q1(1)*Q2(4)
      Q3(2)=-Q1(3)*Q2(1)+Q1(4)*Q2(2)+Q1(1)*Q2(3)+Q1(2)*Q2(4)
      Q3(3)= Q1(2)*Q2(1)-Q1(1)*Q2(2)+Q1(4)*Q2(3)+Q1(3)*Q2(4)
      Q3(4)=-Q1(1)*Q2(1)-Q1(2)*Q2(2)-Q1(3)*Q2(3)+Q1(4)*Q2(4)

      END

    
      SUBROUTINE QUATD (Q1,Q2,Q3)
    !quaternion division Q3=Q2*Q1^-1
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8,DIMENSION(4):: Q1,QC1,Q2,Q3

      QC1(1:3)=-Q1(1:3)
      QC1(4)=Q1(4)
      CALL QUATP (QC1,Q2,Q3)

      END


      SUBROUTINE BOXTEST (Q1,Q2,QM,ICODE)
    !if ICODE==0 finds minimal rotation quaternion
    !if ICODE==N finds rotation quaternion Q2=Q1*(i,j,k,1) for N=(1,2,3,4)
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8, DIMENSION(4):: Q1,Q2,QUATT
      REAL*8 QUAT(4,3)
     *	 /1.d0, 0.d0, 0.d0, 0.d0, 0.d0, 1.d0,
     *      0.d0, 0.d0, 0.d0, 0.d0, 1.d0, 0.d0/

      if(ICODE==0)then
      ICODE=1
      QM=dabs(Q1(1))
      do IXC=2,4
        if(dabs(Q1(IXC))>QM)then
          QM=dabs(Q1(IXC))
          ICODE=IXC
        endif
      enddo
      endif
    
  15  if(ICODE==4)then
      Q2=Q1
      else
      QUATT(:)=QUAT(:,ICODE)
      CALL QUATP(QUATT,Q1,Q2)
      endif

      if(Q2(4)<0.d0)Q2=-Q2

      QM=Q2(4)

      END


      SUBROUTINE F4R1 (Q1,Q2,Q,ICODE)
    ! Q=Q2*(Q1*(i,j,k,1))^-1 for N=(1,2,3,4)
    ! if N=0, then it finds it of the minimum
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8,DIMENSION(4):: Q,Q1,Q2,QR1

      CALL BOXTEST(Q1,QR1,QM,ICODE)
      CALL QUATD(QR1,Q2,Q)

      END



