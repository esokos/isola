
 	dimension v(6,6),vtow(6,6)
	dimension w(6),err(6),errdomin(6),sig(6),dela(6),sigma(6)
	dimension x1save(1800000),x2save(1800000),x3save(1800000)
	dimension x4save(1800000),x5save(1800000),x6save(1800000)
	dimension  zsave(1800000),delta_a_norm(1800000)
	dimension acko(6),ackonew(6)
      real *8 str1old,dip1old,rake1old
	real *8 str1new,dip1new,rake1new
	real *8 rotangle,theta,phi

	open(100,file='vect.dat')
	open(200,file='sing.dat')
	open(250,file='sigma_short.dat')
	open(400,file='elipsa.dat')
	open(500,file='acka_stara.dat')

	
      do i=1,6
      read(100,*) (v(i,j),j=1,6) ! i...comp.,  j... vector
	enddo
 
 	read(200,*) (w(j),j=1,6)

	do j=1,6
      read(500,*) acko(j)
    	enddo
    
	index1=1
	index2=2
	index3=3
	index4=4
	index5=5
	index6=6 
 
	write(*,*) 'BE PATIENT (6 loops !)'

	mpts=0 ! number of points inside ellipsoid
	
	do j=1,6
      read(250,*) sigma(j)
	enddo

      x1step=sigma(1) *1.e20  /5. !5. beccause of the following loops from -5 to +5
      x2step=sigma(2) *1.e20  /5.
      x3step=sigma(3) *1.e20  /5.
      x4step=sigma(4) *1.e20  /5.
      x5step=sigma(5) *1.e20  /5.
      x6step=sigma(6) *1.e20  /5.
    

      do k1=-5,5
	do k2=-5,5
	do k3=-5,5
      do k4=-5,5
	do k5=-5,5
	do k6=-5,5

	x1=float(k1)*x1step
	x2=float(k2)*x2step
	x3=float(k3)*x3step  
	x4=float(k4)*x4step
 	x5=float(k5)*x5step
	x6=float(k6)*x6step  

c *******************************
	dela(index1)= x1    ! [delta_a1, a2, ...] 
	dela(index2)= x2
	dela(index3)= x3 
	dela(index4)= x4     
 	dela(index5)= x5
	dela(index6)= x6 

c *******************************

	sumsum=0.  !  Num. Rec. equation (15.6.8) for delta chi^2
c                !  v(i,j)...i=comp., j= vector   
      do j=1,6
	sum=0.
	do i=1,6
	sum=sum+v(i,j)*dela(i) ! skalar product of j-th sing. vector and vector delta_a 
      enddo
	sumsum=sumsum + w(j)**2 * sum**2 
	enddo 


	povoleni=1.      !  chi=1; the only possible choice for 1 sigma extent
	if (sumsum.lt.povoleni) then
      mpts=mpts+1
	x1save(mpts)=x1	! values of x=delta_a1 inside ellipse
      x2save(mpts)=x2
	x3save(mpts)=x3
	x4save(mpts)=x4	
      x5save(mpts)=x5
	x6save(mpts)=x6

c	delta_a_norm(mpts)=sqrt(x1**2+x2**2+x3**2+
c     *       					x4**2+x5**2+x6**2) ! distance from 6D ellipsoid center 

	zsave(mpts)=sumsum ! ... misfit 
	endif 

      enddo !k1  
	enddo !k2
	enddo !k3
	enddo !k1  
 	enddo !k2
	enddo !k3

	write(*,*) 'mpts= ', mpts


	call silsubnew(acko,
     *	str1,dip1,rake1,
     *    str2,dip2,rake2,
     *    amt,avol_1,aclvd_1,adc_1,avol_2,aclvd_2,adc_2)

	write(*,*)
	write(*,*) 'basic foc mech (strike, dip, rake)'
	write(*,*) str1,dip1,rake1
	write(*,*) str2,dip2,rake2
	write(*,*)

    	str1old=str1
 	dip1old=dip1
	rake1old=rake1

	do j=1,6         !       
	ackonew(j)=acko(j)
	enddo
	
      do m=1,mpts		 !   changing all a's by adding delta_ai in a loop
c *******************************
      ackonew(index1)=acko(index1)+x1save(m)
	ackonew(index2)=acko(index2)+x2save(m)
	ackonew(index3)=acko(index3)+x3save(m)
      ackonew(index4)=acko(index4)+x4save(m)
	ackonew(index5)=acko(index5)+x5save(m)
	ackonew(index6)=acko(index6)+x6save(m)

c ******************************* 
	call silsubnew(ackonew,str1,dip1,rake1,str2,dip2,rake2,amt,
     *            avol_1,aclvd_1,adc_1,avol_2,aclvd_2,adc_2)

	str1new=str1
	dip1new=dip1
	rake1new=rake1
	  
	CALL MINDCROT    ! Kagan 
     *  (str1old,dip1old,rake1old,str1new,dip1new,rake1new,
     *   rotangle,theta,phi)

c        x1save and x2save is unimportant; zsave (=misfit) is important
c        output of parameters as a function of the misfit 
   	write(400,'(6e15.5,3x,3f6.0,3x,3f6.0,3x,3f12.2)')
c     *	 x1save(m),x2save(m),delta_a_norm(m),avol_1,avol_2,
     *	 x1save(m),x2save(m),   zsave(m), avol_2,aclvd_2,        ! new Oct 15, 2014
     *                                     adc_2,
     *          str1,dip1,rake1,str2,dip2,rake2,rotangle    ! rotangle (Kagan, column M)
      enddo

 100	continue

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



	include "silsubnew.inc"
	include "jacobi.inc"
	include "line.inc"
	include "angles.inc"
	include "ang.inc"