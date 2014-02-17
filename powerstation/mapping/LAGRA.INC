
      subroutine lagra(rold,rinv,aold,anew)

      dimension rinv(6,6),rold(6,6),anew(6),a1(6),a2(6),b(6)
      dimension andc(6),abdc(6),dela(6),der(6),aold(6)
c     dimension atest(6)
      logical SUCCES
      external DETERMI

      common /constraint/ andc,a2,b

c     open(100,file='matin.dat') ! input of a's and inverse matrix
      open(300,file='matin2.dat')

      nmom=5  !!!!!!!!!!! ATTENTION this code is NOT usable for nmom=6 
	  aold(6)=0.
	  anew(6)=0.
	  andc(6)=0.
	  a2(6)=0.
	  b(6)=0.


c     read(100,*) (andc(i),i=1,nmom)  ! unconstrained, generally non-DC
c     read(100,*)                     ! (found by fitting the data; just THIS

      do n=1,nmom
      andc(n)=aold(n)
      enddo

                                      !      keps info from the DATA !!!!)

c     do i=1,nmom         !   matrix
c     read(100,'(6(1x,e12.6))') (rold(i,j),j=1,nmom)
c     enddo
c     read(100,*)

c     do i=1,nmom         !  inverse matrix
c     read(100,'(6(1x,e12.6))') (rinv(i,j),j=1,nmom)
c     enddo

c **************************************************************************
c     !!!!  THIS IS A POSSIBLE  ALTERNATIVE to the below used SILSUB !!!!!
c                    read from mechan.dat
C ** FOCAL MECHANISM (if a priori known and held fixed for all subevents) **
c      to be used as a first approximation for the constrained DC
c **************************************************************************

c       do i=1,2
c       read(888,*)   ! best DC solution obtained from unconstrained non-DC
c       enddo         ! it implies autom. a(6)=0., a(6) not studied at all here
c       read(*,*) xmoment
c       read(888,*)
c       read(888,*) strike,dip,rake
c       REWIND (888)
c
c     write(300,*) 'non-constrained solution:'
c     write(300,*) 'DC% - unknown'
c     write(300,*) 'moment',xmoment
c     write(300,*) 'strike,dip,rake:',strike,dip,rake
c     write(300,*) '================================================='
c     write(300,*)


c **************************************************************************
c     !!!!  THIS IS another POSSIBLE  ALTERNATIVE to the below used SILSUB !!!!!
c                   fix youreself  here
C ** FOCAL MECHANISM (if a priori known and held fixed for all subevents) **
c      to be used as a first approximation for the constrained DC
c **************************************************************************

c       dcperc=85.
c       xmoment=1.e18
c       strike=104.
c       dip=82.
c       rake=6.
c
c     write(300,*) 'non-constrained solution:'
c     write(300,*) 'DC%',dcperc
c     write(300,*) 'moment',xmoment
c     write(300,*) 'strike,dip,rake:',strike,dip,rake
c     write(300,*) '================================================='
c     write(300,*)


c **************************************************************************
C ** FOCAL MECHANISM (taken as the best double couple solition ) **
c      to be used as a first approximation for the constrained DC
c **************************************************************************

      call silsub(andc,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
     *            dum)

      write(300,*) 'non-constrained solution:'
      write(300,'(6(1x,e12.6))') (andc(i),i=1,nmom)
      write(300,*) 'DC%',dcperc
      write(300,*) 'moment',amoment
      write(300,*) 'strike,dip,rake:',str1,dip1,rake1
      write(300,*) 'strike,dip,rake:',str2,dip2,rake2
      write(300,*) '================================================='
      write(300,*)

      xmoment=amoment
      strike=str1
      dip=dip1
      rake=rake1

c ================== the next part is the same for all 3 alternatives ========

        pi=3.1415927
 	strike=strike*pi/180.
 	dip=dip*pi/180.
 	rake=rake*pi/180.
 	sd=sin(dip)
 	cd=cos(dip)
 	sp=sin(strike)
 	cp=cos(strike)
 	sl=sin(rake)
 	cl=cos(rake)
 	s2p=2.*sp*cp
 	s2d=2.*sd*cd
 	c2p=cp*cp-sp*sp
 	c2d=cd*cd-sd*sd

 	xx1 =-(sd*cl*s2p + s2d*sl*sp*sp)*xmoment     ! Mxx
 	xx2 = (sd*cl*c2p + s2d*sl*s2p/2.)*xmoment    ! Mxy
 	xx3 =-(cd*cl*cp  + c2d*sl*sp)*xmoment        ! Mxz
 	xx4 = (sd*cl*s2p - s2d*sl*cp*cp)*xmoment     ! Myy
 	xx5 =-(cd*cl*sp  - c2d*sl*cp)*xmoment        ! Myz
 	xx6 =             (s2d*sl)*xmoment           ! Mzz

 	abdc(1) = xx2       ! this is a to be used as first approx for constr.
 	abdc(2) = xx3
 	abdc(3) =-xx5
 	abdc(4) = (-2.*xx1 + xx4 + xx6)/3.
 	abdc(5) = (xx1 -2*xx4 + xx6)/3.
c       abdc(6)=0.
   	abdc(6) = (xx1+xx4+xx6)/3. ! for the above x's this a(6)=0.
c                   ! but for a given non-DC MT (x1-x6), a(6) may be nonzero


c ***************************************************************************


      do n=1,nmom             ! this is artificial nomralization
      abdc(n)=abdc(n)/xmoment   ! to be around 1.   de-nomralization at the end must use
      andc(n)=andc(n)/xmoment   !                   the SAME number
      enddo

      trr=rinv(1,1)+rinv(2,2)+rinv(3,3)
      trr=trr/3.
      do i=1,nmom
      do j=1,nmom
      rinv(i,j)=rinv(i,j)/trr
      rold(i,j)=rold(i,j)/trr
      enddo
      enddo

c ****************************************************************************


       sum0=0.
       do n=1,nmom
       do m=1,nmom
       sum0=sum0 + rold(n,m)*andc(n)*andc(m)
       enddo
       enddo
c      sum0=sum0*1.e38
c      write(*,*)  'max possible correl=',sum0
c      write(*,*)

c ****************************************************************************

      iter=0
  10  iter=iter+ 1

      if(iter.eq.1) then
c      write(*,*) 'iter,determi,correl % (non-DC is 100%)'
       do n=1,nmom
       a1(n)=abdc(n)
       enddo
c      x1=-100.
c      x2=+100.
       xacc=0.1        !!! is this enough ????
       goto 15         !!! see later xacc=xacc/2.

      else

       do n=1,nmom
       a1(n)=a2(n)           ! a2 goes from DETERMI through common
       enddo
c      x1=-100.
c      x2=+100.
       xacc=xacc/2.      !!!!!  this is important
      endif

  15  continue
        der(1)=-2.*a1(1)*a1(4)-2.*a1(1)*a1(5)-2.*a1(2)*a1(3)
        der(2)=-2.*a1(1)*a1(3)+2.*a1(2)*a1(5)
        der(3)= 2.*a1(3)*a1(4)-2.*a1(1)*a1(2)
        der(4)= 2.*a1(4)*a1(5)+ a1(5)*a1(5)+ a1(3)*a1(3)- a1(1)*a1(1)
        der(5)= 2.*a1(4)*a1(5)+ a1(4)*a1(4)+ a1(2)*a1(2)- a1(1)*a1(1)
       do n=1,nmom
       b(n)=0.
        do m=1,nmom
        b(n)=b(n)+ rinv(n,m)*der(m)   ! b(n) goes into DETERMI through common
        enddo                         ! (together with andc(n) )
       enddo

       x1=-0.01
       x2=+0.01
      call zbrac(DETERMI,x1,x2,succes)
cc    write(*,*)  succes,x1,x2

      xxx = rtbis(DETERMI,x1,x2,xacc)  ! seeking root xxx=lambda giving D=0
      yyy=determi(xxx)

       do n=1,nmom
       dela(n)=a2(n)-andc(n)        ! a2 goes from DETERMI through common
       enddo

       sum=0.    !  eq (11) correlation
       do n=1,nmom
       do m=1,nmom
       sum=sum + rold(n,m)*(andc(n)*andc(m)-dela(n)*dela(m))
       enddo
       enddo
c      sum=sum*1.e38
       corrperc=100.*sum/sum0
c      write(*,*)  iter,yyy,corrperc

      write(300,*) 'iter,deter,corr%', iter,yyy,corrperc
      write(300,*)
      write(300,*) 'a(2):'      ! be careful; de-normalize only for write !!!
      write(300,'(6(1x,e12.6))') (a2(i)*xmoment,i=1,nmom)
      write(300,*)

c
c     BE CAREFUL: a2 is normalized; it cannot be de-normalized DURING
c                                   calculation;
c                                   we de-normalize only OUTPUT, not
c                                   the 'content' of a2
c

c ------------------------------------------------------------------------
c                 THE FOLLOWING IS ONLY FOR CHECKING PURPOSE
c                      later can be omitted
c
c     der(1)=-2.*a2(1)*a2(4)-2.*a2(1)*a2(5)-2.*a2(2)*a2(3)
c     der(2)=-2.*a2(1)*a2(3)+2.*a2(2)*a2(5)
c     der(3)= 2.*a2(3)*a2(4)-2.*a2(1)*a2(2)
c     der(4)= 2.*a2(4)*a2(5)+ a2(5)*a2(5)+ a2(3)*a2(3)- a2(1)*a2(1)
c     der(5)= 2.*a2(4)*a2(5)+ a2(4)*a2(4)+ a2(2)*a2(2)- a2(1)*a2(1)
c
c     do n=1,nmom
c     b(n)=0.
c       do m=1,nmom
c       b(n)=b(n)+ rinv(n,m)*der(m)
c       enddo
c     enddo
c
c     do n=1,nmom
c     atest(n)=andc(n) - xxx * b(n)
c     enddo
c     write(300,*) 'atest (is it close to a2 where deriv. is used?):'
c     write(300,'(6(1x,e12.6))') (atest(i),i=1,nmom)
c     write(300,*)
c ------------------------------------------------------------------------


      call silsub(a2*xmoment,str1,dip1,rake1,str2,
     *            dip2,rake2,amoment,dcperc,dum)


      write(300,*) 'constrained solution:'
      write(300,*) 'DC%',dcperc
      write(300,*) 'moment',amoment
      write(300,*) 'strike,dip,rake:',str1,dip1,rake1
      write(300,*) 'strike,dip,rake:',str2,dip2,rake2
      write(300,*) '======================================'

      if(dcperc.gt.90..and.corrperc.gt.50.) then
c            c     accept=true
c            c     logical accept
      write(300,*) 'ACCEPTED !!!!'
      write(300,*) '======================================'
      write(300,*)
      do n=1,nmom
      anew(n)=a2(n)*xmoment ! de=normalization included
      enddo
      go to 90 !  good for subroutine, 1st succcess is used
c              !  if this goto 90 os with 'c', all iterations are shown
      else
c            c     accept=false
      write(300,*) 'not  ACCEPTED '
      write(300,*) '======================================'
      write(300,*)
      do n=1,nmom             ! in case of no success: 'new'='old'
      anew(n)=andc(n)*xmoment ! de-normalization included
      enddo
      endif


      if(iter.ge.15) goto 90
      goto 10

  90  do i=1,nmom
      do j=1,nmom
      rinv(i,j)=rinv(i,j)*trr     ! de-normalization
      rold(i,j)=rold(i,j)*trr     ! ....
      enddo
      enddo

      RETURN
      END

