
      subroutine silsubnew(a,str1,dip1,rake1,str2,dip2,rake2,amt,
     *                 avol_1,aclvd_1,adc_1,avol_2,aclvd_2,adc_2)
c     Author: J. Sileny, modified by J.Z.


c     COMMON/COMSGN/amm(3,3)
      dimension amm(3,3) ! moje zmena
      DIMENSION am(3,3),t(3,3),en(3),EN1(3)
      DIMENSION AN1(3),AN2(3),AK(3),HLP(3),AD(3)
      DIMENSION AL(3),AL1(3),ALM(3)
      dimension a(6)
C
      FAC=3.14159/180.
C
c     open(2,file='moment.lst')

c     imom=6            ! a( ) enter as parameters
c     do n=1,imom
c     read(111,*) a(n)
c     enddo

c     imom=5
c     do n=1,imom
c     read(111,*) a(n)
c     enddo
c     a(6)=0.

      am(1,1)=-1.*a(4)+a(6)
      am(2,2)=-1.*a(5)+a(6)
      am(3,3)=a(4)+a(5)+a(6)
      am(1,2)=a(1)
      am(1,3)=a(2)
      am(2,3)=-a(3)


      am(2,1)=am(1,2)
      am(3,1)=am(1,3)
      am(3,2)=am(2,3)
C
C     scaling of the tensor Mij
      amt=SQRT(.5*(am(1,1)*am(1,1)+am(2,2)*am(2,2)
     &        +am(3,3)*am(3,3))+am(1,2)*am(1,2)
     &        +am(1,3)*am(1,3)+am(2,3)*am(2,3))
      facm=1./amt/SQRT(2.)
      do 9 I=1,3
      do 9 J=1,3
        am(i,j)=am(i,j)*facm ! mohu nasobit lib. konstantou a rozklad se nezmeni
        amm(i,j)=am(i,j)
    9 continue
C
C     computation of eigenvalues and eigenfunctions, their ordering
      CALL JACOBI (3,50,1E-9,1E-9,1E-9,am,T,EN,AK)
      CALL LINE (EN,T,3)
C
C     create right-handed system from eigenvectors
      HLP(1)=T(2,1)*T(3,2)-T(3,1)*T(1,2)
      HLP(2)=T(3,1)*T(1,2)-T(1,1)*T(3,2)
      HLP(3)=T(1,1)*T(2,2)-T(2,1)*T(1,2)
      IF (HLP(1)*T(1,3)+HLP(2)*T(2,3)+HLP(3)*T(3,3).LT.0.) THEN
       DO 3 J=1,3
        T(J,3)=-T(J,3)
    3  CONTINUE
      ENDIF
c
c
c     processing moment tensor
c
c     write(2,*)
c     write(2,*)
c     write(2,*)
c     write(2,*)
c     write(2,'(/'' M0:  '',e10.3)')amt

c     write(2,'(/'' MT (normalized):'')')
c     do 2 i=1,3
c   2 write(2,'(8g10.4)')(amm(i,j),j=1,3)

c     write(2,'(/'' MT eigenvalues:'')')
c     write(2,'(3e13.6)')(en(j),j=1,3)

c     write(2,'(/'' eigenvectors of moment tensor:'')')
c     write(2,'(8g10.4)')(t(j,1),j=1,3)
c     write(2,'(8g10.4)')(t(j,2),j=1,3)
c     write(2,'(8g10.4)')(t(j,3),j=1,3)

      amv=en(1)+en(2)+en(3)
      do 26 j=1,3
   26 en1(j)=en(j)-amv/3.

      en1max=max(abs(en1(1)),abs(en1(2)),abs(en1(3)))
      en1min=min(abs(en1(1)),abs(en1(2)),abs(en1(3)))
      if(abs(en1max).lt.1e-20) then
	  write(*,*) 'problem in silsubnew'	!!!!!!!!!!!!!!!!!!
      return
	  else
	  eps=-en1min/abs(en1max)
	  endif
c
c       construct vectors lambda_dev, d, l and l1'
        sqr2=1./sqrt(2.)
        sqr3=1./sqrt(3.)
        sqr1=1./sqrt(1.5)
        do 36 j=1,3
        alm(j)=en1(1)*t(j,1)+en1(2)*t(j,2)+en1(3)*t(j,3)
        ad(j)=(t(j,1)-t(j,3))*sqr2
        al(j)=(t(j,1)-.5*t(j,2)-.5*t(j,3))*sqr1
        al1(j)=(.5*t(j,1)+.5*t(j,2)-t(j,3))*sqr1
36      continue
c     compute angles: lambda_dev^l(min), lambda_dev^d, d^l
      angdl=ang(ad,alm)
      angll1=ang(al,alm)
      angll2=ang(al1,alm)
      angdll=ang(al,ad)
      angll=min(angll1,angll2)
      angll=angll/angdll
      angdl=angdl/angdll
c
c     MT decomposition (1)
c     write(2,*)' '
c     write(2,*)' MT decomposition (1)'
      amv1=amv**2/(en(1)**2+en(2)**2+en(3)**2)/3.*100.
      if(amv.ge.0.)then
c     write(2,'('' V(explosive):'',t16,f5.1,''%'')')amv1
      else
c     write(2,'('' V(implosive):'',t16,f5.1,''%'')')amv1
      endif
      aclvd=min(abs(en1(1)),abs(en1(2)),abs(en1(3)))/
     /      max(abs(en1(1)),abs(en1(2)),abs(en1(3)))*200.
      
	  avol_1=sign(amv1,amv)
      aclvd_1=aclvd
	  adc_1=100.-aclvd

c     write(2,'('' DC:'',t16,f5.1,''%'')')100.-aclvd
      if(angll1.lt.angll2)then
c     write(2,'('' CLVD(T-axis):'',t16,f5.1,''%'')')aclvd
      else
c     write(2,'('' CLVD(P-axis):'',t16,f5.1,''%'')')aclvd
      endif

c     MT decomposition (2)
c     write(2,*)' '
c     write(2,*)' MT decomposition (2)'
      amv1=abs(amv)/max(abs(en(1)),abs(en(2)),abs(en(3)))/3.*100.
      if(amv.ge.0.)then
c     write(2,'('' V(explosive):'',t16,f5.1,''%'')')amv1
      else
c     write(2,'('' V(implosive):'',t16,f5.1,''%'')')amv1
      endif
      aclvd=2.*abs(eps)*(100.-amv1)
      adc=100.-amv1-aclvd

	  avol_2=sign(amv1,amv)
      aclvd_2=aclvd
	  adc_2=adc

c     write(2,'('' DC:'',t16,f5.1,''%'')')adc
      if(angll1.lt.angll2)then
c     write(2,'('' CLVD(T-axis):'',t16,f5.1,''%'')')aclvd
      else
c     write(2,'('' CLVD(P-axis):'',t16,f5.1,''%'')')aclvd
      endif

c     write(2,'(/'' T and P axes:'')')
c     write(2,'(8g10.4)')(t(j,1),j=1,3)
c     write(2,'(8g10.4)')(t(j,3),j=1,3)

      do 27 j=1,3
      an1(j)=(t(j,1)+t(j,3))*.7071068
   27 an2(j)=(t(j,1)-t(j,3))*.7071068
c     write(2,'(/'' Nodal plane normals:'')')
c     write(2,'(8g10.4)')(an1(j),j=1,3)
c     write(2,'(8g10.4)')(an2(j),j=1,3)

      call angles(an1,an2,dip1,str1,rake1)
      call angles(an2,an1,dip2,str2,rake2)
c     write(2,'(/'' strike, dip and rake angles:'')')
c     write(2,'(8g10.4)')str1,dip1,rake1
c     write(2,'(8g10.4)')str2,dip2,rake2
c     close(2)

ccc   CALL RJPLT(EN,T)  (this subroutine, and its subr. 'proj' are DELETED
                                              ! full in sileny.for)
      RETURN
      end
