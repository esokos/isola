      subroutine elesyn_1024Intel(filename,w)

      character*12 filename
c     dimension w(-3500:11692,21,3,6)
      dimension w(1024,21,3,6), bb(1024)
      dimension stat(21),ntm(21)
      dimension weig(21,3) 
      


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm              ! new
      common /WEI/ weig

c      open(100,form='unformatted',file=filename)     ! Powerstation
       open(100,form='unformatted',file=filename,access='stream')     ! Intel


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
   
      close(100) ! should we use only Rewind and remove close?????

c     Plotting all stations,comp, tensors BEFORE fitration 
c      do ir=1,nr
c        do it=1,6        ! here MUST be 6 (not nmom!) since  6 are calculated !!!!
c          do itim=1,ntim   ! pres cas
c          time=float(itim-1)*dt
c        write(123,'(4(1x,e12.5))') time,
c     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
c          enddo
c        enddo
c      enddo



c
c     FILTERING THE ELEM. SEISMO 
c
c
      do ir=1,nr 
	  
	  f1=ff1(ir)  
	  f4=ff4(ir)
      keyfil=0 !(BP=0, LP=1, HP=2)   
      keydis=1 !(vel=0, displ=1)   
      shift=0.   
          do icom=1,3
          do it=1,6 ! here MUST be 6, not nmom
c      call filter15_1024	 
c     *	(keyfil,keydis,shift,f1,f4,dt,w(1:1024,ir,icom,it))	
          do iii=1,ntim
		  bb(iii)=w(iii,ir,icom,it)
		  enddo
       call filter15_1024(keyfil,keydis,shift,f1,f4,dt,bb)
          do iii=1,ntim
		  w(iii,ir,icom,it)=bb(iii)
		  enddo	   
          enddo
          enddo
      enddo ! over stations
 
 
c     Plotting all stations,comp, tensors AFTER fitration 
c       do ir=1,nr
c        do it=1,6        
c          do itim=1,ntim   
c          time=float(itim-1)*dt
c        write(123,'(4(1x,e12.5))') time,
c     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
c          enddo
c        enddo
c      enddo

        RETURN
        END
