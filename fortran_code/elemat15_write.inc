
      subroutine elemat15_write(keygps,filename,w,rold,rinv)

c ATTENTION: on output, rold is * 1.e20, rinv is / 1.e20

c   Input: elem se (w) for a fixed point source
c   Output: system matrix, inverted matrix

      dimension keygps(21)
      character*12 filename
      dimension w(-3500:11692,21,3,6)
      dimension r(6,6),rinv(6,6),rold(6,6)
        dimension gold(6,6),en(6),vv(6,6)
      dimension indx(6),y(6,6)
      dimension ntm(21)               ! new
      dimension weig(21,3)            ! new
      logical stat(21)

      double precision wNweig,wMweig !!!!!! EXTREMELY IMPORTANT for gfort!!!!!!! 


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm              ! new
      common /WEI/ weig


      open(100,form='unformatted',file=filename)     ! elementary seismograms from ELEMSE (input)



c *******************************************************************
c *********** MANIPULATING ELEMENTARY SEISMOGRAMS (Green's) *********
c *******************************************************************

c
c        READING 6 ELEMENTARY velocity SEISMOGRAMS, a single point source
c      (synth. Green's convolved with SOME time fctn.; see ELEMSE.FOR)
c
c

      do ir=1,nr
        do it=1,6        ! here MUST be 6 (not nmom!) since  6 are calculated !!!!
          do itim=1,ntim   ! pres cas
          read(100) time,
     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
          enddo
        enddo
      enddo


c       open(8256,file='test1.dat') 
c      do ir=1,nr           ! output of elemse for plotting NO FILTER !!!
c        do it=1,6       
c          do itim=1,ntim
c          time=float(itim-1)*dt
c          write(8256,'(4(1x,e12.6))') time,
c     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
c          enddo
c          write(8256,*) '*'
c        enddo
c      enddo
c      close(8256)



c      REWIND(100)
	   close(100)



c
c     FILTERING THE ELEM. SEISMO - OLD !!!
c

c      do ir=1,nr
c	  f1=ff1(ir)
c	  f2=ff2(ir)
c	  f3=ff3(ir)
c	  f4=ff4(ir)
c        do icom=1,3
c          do it=1,6 ! here MUST be 6, not nmom
c          call filter(f1,f2,f3,f4,dt, w(1,ir,icom,it) )
c          enddo
c        enddo
c      enddo
c




c
c     FILTERING THE ELEM. SEISMO - NEW
c
c
      do ir=1,nr 
      if(keyGPS(ir).eq.0) then
	  
	  f1=ff1(ir)  
	  f4=ff4(ir)
      keyfil=0 !(BP=0, LP=1, HP=2)   
      keydis=1 !(vel=0, displ=1)   
      shift=0.
          do icom=1,3
          do it=1,6 ! here MUST be 6, not nmom
           call filter15(keyfil,keydis,shift,f1,f4,dt,w(1,ir,icom,it))	 ! seis. has the OLD filter
c          call filter(f1,f2,f3,f4,dt,w(1,ir,icom,it))  
	      enddo
          enddo

	  else     

	  f1=ff1(ir)  !!!!! 'filter' involves filtering, integration
	  f4=ff4(ir)
      keyfil=1 !(BP=0, LP=1, HP=2)   
      keydis=1 !(vel=0, displ=1)   
      shift=0.
          do icom=1,3
          do it=1,6 ! here MUST be 6, not nmom
           call filter15(keyfil,keydis,shift,f1,f4,dt,w(1,ir,icom,it))	 ! seis. has the OLD filter
	      enddo
          enddo
      endif
	      
      if(keyGPS(ir).eq.2) then ! for 2 pure statics (after integration in filter CAUTION what filtration is used
      do it=1,6
       do itim=-3500,11692
c        do itim=1,ntim-1

c      w(itim,ir,1,it)=w(8192,ir,1,it)  ! in case of problems can be substitued by some average at the 'end part'
c      w(itim,ir,2,it)=w(8192,ir,2,it) 	! put 'c' if you want to see COMPLETE synth seis in FORWARD  modeling of GPS
c      w(itim,ir,3,it)=w(8192,ir,3,it) 	! use of complete synth in case of keyGPS=2 not tested , probably possible but with lower VR 

	  enddo
	  enddo
	  endif
      enddo ! over stations
 



       open(8256,file='testunc.dat') 
        do ir=1,nr      ! output of elemse for plotting WITH FILTER
          do it=1,6         
            do itim=1,ntim
           time=float(itim-1)*dt
           write(8256,'(4(1x,e12.6))') time,
     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
           enddo
         enddo
       enddo
       close(8256)

c       open(8256,file='testunc_plot.dat') 
c        do it=1,6
c      	shiftmech=2e-19
c	  do ir=1,nr      ! output of elemse for plotting WITH FILTER
c        do icom=1,3
c           do itim=1,ntim
c           time=float(itim-1)*dt
c           time=time + float(icom-1)*10. + float(ir-1)*50. 
c           write(8256,'(2(1x,e12.6))') time,
c     * 		  w(itim,ir,icom,it) + float(it-1)*shiftmech
c           enddo ! over time
c         enddo ! over comp
c         enddo ! over stat
c         write(8256,*)
c	   enddo ! over mech
c       close(8256)


c ***********************************************************************
c ***********FORMING AND INVERTING SYSTEM MATRIX (from elem seismograms)
c ***********************************************************************


c
c     FORMING SYSTEM MATRIX
c
      do n=1,nmom                                    !n,m mom tensor comp
        do m=1,nmom
        r(n,m)=0.
          do icom=1,3
            do ir=1,nr
            if(stat(ir)) then
              do itim=1,ntim
              wNweig=w(itim,ir,icom,N)*weig(ir,icom)
              wMweig=w(itim,ir,icom,M)*weig(ir,icom)
              r(n,m)=r(n,m)+
     *            wNweig*wMweig*1.e20	
c                                                     1.e20 = FORMAL SCALING
c        this formal scaling 1.e20 is essential to prevent some underflow
c        1.e20 is later compensated by the same multiplication of the
c        right-side of the equation
c        Note that matrix and right-hand side are formally multiplied
c             without affecting w, x, ...!!!
              enddo
            endif
            enddo
          enddo
          r(n,m)=r(n,m)*dt
        enddo
      enddo


       open(897,file='matrix.dat') ! needed if code matrix_mt is to be used
  	do i=1,nmom          ! printing sytem matrix
        write(897,'(6(1x,e12.6))') (r(i,j),j=1,nmom)
 	enddo
        write(897,*)
      close (897)

 	do i=1,nmom          ! saving r(n,m) before inversion
 	  do j=1,nmom        ! (because after inversion r(n,m) is destroyed !)
 	  rold(i,j)=r(i,j)
          gold(i,j)=r(i,j)
 	  enddo
 	enddo

        call JACOBInr(gold,nmom,6,en,vv,nrot)
c        write(*,*) 'eigenvalues'
c		write(*,*) (en(i),i=1,nmom)
c        write(*,*) 'eigenvectors'
c		do i=1,nmom
c		write(*,*) (vv(i,j),j=1,nmom)
c		enddo
      
	  
	  goto 333      ! new ! ISO does NOT need matrix inversion !!!!! 



c
c     INVERTING THE SYSTEM MATRIX
c

c r(i,j)  matrix inversion (from Numerical Recipes) -> rinv(i,j)

	do i=1,nmom
	do j=1,nmom
	  y(i,j)=0.
	  enddo
	  y(i,i)=1.
	enddo
          nmax=6  !!! dim. of array r
          call ludcmp(r,nmom,nmax,indx,ddd)   ! indx, ddd = output
          do j=1,nmom                    ! former r is DESTROYED !!!
	  call lubksb(r,nmom,nmax,indx,y(1,j))
	  enddo

	do i=1,nmom
	  do j=1,nmom
 	  rinv(i,j)=y(i,j)
	  enddo
	enddo

cc       write(897,*)
cc    	do i=1,nmom          ! printing inverse matrix
cc      write(897,'(6(1x,e12.6))') (rinv(i,j),j=1,nmom)
cc 	 enddo
cc       write(897,*)
cc       close(897)

 333   RETURN
        END
