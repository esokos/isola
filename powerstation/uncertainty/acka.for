      dimension a(6)

	write(*,*) 'xmoment,strike,dip,rake:'
	read(*,*) xmoment,strike,dip,rake
       

c        xmoment=1.        !!!!!!!!!!!!!!!!!!!!!!!!!!!
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
        
        write (*,*) cp,sp,cd,sd,c2p,c2d
        
 	xx1 =-(sd*cl*s2p + s2d*sl*sp*sp)*xmoment     ! Mxx
 	xx2 = (sd*cl*c2p + s2d*sl*s2p/2.)*xmoment    ! Mxy
 	xx3 =-(cd*cl*cp  + c2d*sl*sp)*xmoment        ! Mxz
 	xx4 = (sd*cl*s2p - s2d*sl*cp*cp)*xmoment     ! Myy
 	xx5 =-(cd*cl*sp  - c2d*sl*cp)*xmoment        ! Myz
 	xx6 =             (s2d*sl)*xmoment           ! Mzz

 	a(1) = xx2
 	a(2) = xx3
 	a(3) =-xx5
 	a(4) = (-2.*xx1 + xx4 + xx6)/3.
 	a(5) = (xx1 -2*xx4 + xx6)/3.
      a(6)=0.

	do i=1,6
	write(250,*) a(i)
	enddo

	stop
	end