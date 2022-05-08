      subroutine elesyn(filename,w)

      character*12 filename
      dimension w(-3500:11692,21,3,6)
      dimension stat(21),ntm(21)
      dimension weig(21,3) 
      
c      double precision wNweig,wMweig !!!!!! EXTREMELY IMPORTANT for gfort!!!!!!! 

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

	   close(100)


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
           call filter15(keyfil,keydis,shift,f1,f4,dt,w(1,ir,icom,it))	 
          enddo
          enddo
	      
      enddo ! over stations
 
        RETURN
        END
