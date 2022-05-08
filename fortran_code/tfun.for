      COMPLEX U(8192),ai,uu
      dimension a(8192,120)
      dimension b(8192),c(8192),d(8192)
      dimension sb(8192),sc(8192),sd(8192)	  

      COMMON/COM/FLE,FLI,FRI,FRE,DF,ILS,IRS,NT,NTM ! for FCOOLR

c
c	Source time function (sum of triangles)
c     J. Zahradnik 2017

C Area under each one triangle is AMOMENT (where amoment is read from file).
C Total area is their sum (irrespectively whether they overlap or not). 
c This total area = total moment. 
c It is strictly assumed that the elementary time function is triangle, not delta!
c Total time function b(i) is the moment rate [Nm/s] because amoment is in Nm.


       OPEN(100,FILE='inpinv.dat')
       OPEN(101,FILE='sel_pairs.dat')
       OPEN(111,FILE='sel_pairs2.dat')
       OPEN(777,FILE='timfun_maxima.dat')
       OPEN(788,FILE='timfun_select.dat')
       OPEN(888,FILE='timfun_all.dat')
       OPEN(999,FILE='timfun_mean.dat')
	   
	   ai=cmplx(0.,1.)
       PI=3.141592

      read(100,*)
      read(100,*)
      read(100,*)
      read(100,*) dt 

      NI=13
      NT=2**NI
      NP=NT
      NT2=NT/2
      NTM=NT2+1
      NTT=NT+2
      DF=1./(DT*FLOAT(NT))
      FMAX=FLOAT(NTM)*DF
      auxshift=float(NT)*dt/2. !!! NEW Aug 2, 2015 (Later corrected in output)
C This shift is to avoid that (due to use of FFT) the part of time function
C corresponinging to t<0 will be at the end of the FFT series.
C This is good only for functions not starting more than auxshift before t=0.


	  ir=1
 200  read(101,*,end=210) num1,num2
      ir=ir+1
      goto 200
 210  npairs=ir-1
      write(*,*) 'number of pairs: ',npairs

      read(111,*) ! dummy
	  read(111,*) t0, ntr
      rewind (111)
	  
      write(*,*) 'duration of elem. triangle: currently= ',t0
      write(*,*) 'duration of elem. triangle: your preferred= ?'
	  read(*,*) t0
	  write(*,*) 'duration = ',t0
	  write(*,*) 'duration of elem. triangle: currently= ',t0
	  
	  nsel1=num1
	  nsel2=num2
      write(*,*) 'selected pair from sel_pairs.dat, e.g.:', nsel1,nsel2
	  read(*,*) nsel1,nsel2
	  write(*,*) 'Wait, code is running ....'
	  
 	   do i=1,nt
       sb(i)=0.
	   sc(i)=0.
	   sd(i)=0.
	   enddo
	   
	   keypair=0.
       zero=0.
	   do i=1,nt
       time=float(i-1)*dt	
	   write(788,'(4(1x,e12.6))') 
     *       time-auxshift,zero,zero,zero ! zero values printed
       enddo
	   
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	  
      do 2000 ip=1,npairs     !! major loop over pairs (ip)  
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

	   do i=1,nt
       b(i)=0.
	   c(i)=0.
	   d(i)=0.
	   enddo

      read(111,*)  num1,num2
	  read(111,*) ! dummy
      nsour=2*ntr      !(each point in pair has ntr trinagles)
      if(nsour.gt.120) then
	  write(*,*) 'problem dimension (nsour>120)'
      stop
	  endif
	  
ccccccccccccccccccccccccccccccccccccccccccccccccccc	  
	  do 10 is=1,nsour ! loop over all triangles nsour=2*ntr 
      read(111,*) dummy,shift,amoment

      do i=1,nt
      U(I)=(0.,0.)
      enddo

      do 20 I=2,NTM    ! begins at  I=2 !!!!!!!!! U(1)=(0.,0.)
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

c     U(I)=U(I)*cexp(-2*pi*ai*freq*(shift    ))   ! no time shift 
      U(I)=U(I)*cexp(-2*pi*ai*freq*(shift+auxshift)) ! NEW Aug 2, 2015   !  
 
  20  continue ! konec cyklu pres frnce

      DO  25 I=2,NT2
      J=NTT-I
      U(J)=CONJG(U(I))
  25  continue

      u(1)=CMPLX(amoment   ,0.) !     New Aug 2, 2015 
	
      CALL FCOOLR(NI,U,+1.) !(zadna konst, protoze je to analyt predpis sp.)

      do i=1,nt
      a(i,is)=REAL(U(I))/FLOAT(NT)/DT   ! the is-th triangle (is=1,2,..)
cc                                  ! zde je jedina konst df=1/N/dt
cc                                  ! protoze se transformovalo analyt spek.
      enddo
  10  continue  ! ending loop over triangles
cccccccccccccccccccccccccccccccccccccccccccccccccccc

cccccccccccccccccccccc new loop of triangles (sorting into the two points of the pair)
       bmax=0.
       cmax=0.
       do is=1,nsour !(nsour=2 * ntr)
	         if (is.le.ntr) then
       do i=1,nt
       b(i)= b(i) + a(i,is)           ! summimg all triangles of the current pair
		if(b(i).gt.bmax) then
		bmax=b(i)
		indbmax=i
		endif       
	   enddo
		       else
       do i=1,nt
       c(i)= c(i) + a(i,is)           ! summimg all triangles of the current pair
		if(c(i).gt.cmax)then 
		cmax=c(i)       
		indcmax=i
		endif       
       enddo
		      endif
       enddo ! end of loop over sorting  triangles 
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	   

	   timbmax=float(indbmax-1)*dt - auxshift
       timcmax=float(indcmax-1)*dt - auxshift
       write(777,'(2(1x,i6),4(1x,e12.6))')
     *	   num1,num2,timbmax,timcmax,bmax,cmax
       
  
       if(num1.eq.nsel1.and.num2.eq.nsel2) then
       keypair=1
	   do i=1,nt
       time=float(i-1)*dt	
	   write(788,'(4(1x,e12.6))') 
     *       time-auxshift,b(i),c(i),b(i)+c(i) ! the selected pair
       enddo
       endif	   
	   
	   
	   
	   do i=1,nt
       d(i)=b(i)+c(i) ! total time function of the current pair	   
       time=float(i-1)*dt	
	   write(888,'(4(1x,e12.6))') 
     *       time-auxshift,b(i),c(i),d(i) ! 
	 
       sb(i)=sb(i) + b(i) ! preparation for avearge over the pairs
       sc(i)=sc(i) + c(i)
       sd(i)=sd(i) + d(i)
       enddo
c       write(888,*) '*' 	   
        write(888,*)   
  
 2000 continue ! end of major loop over source pairs (ip)
      if(keypair.eq.0) then
        write(*,*) 'ERROR: The selected pair does not exit!'   
        write(*,*) 'File timfun_select.dat contains zeros.'  	  
      endif
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
    
	   do i=1,nt                  ! averaging of the pairs
       sb(i)=sb(i)/float(npairs)
       sc(i)=sc(i)/float(npairs)
       sd(i)=sd(i)/float(npairs)	   
       time=float(i-1)*dt	
	   write(999,'(4(1x,e12.6))') time-auxshift,sb(i),sc(i),sd(i) ! average time functions 
       enddo                      ! point1, point2, and their total
      
	  
	  
      STOP
      END
 
      include "fcoolr.inc"