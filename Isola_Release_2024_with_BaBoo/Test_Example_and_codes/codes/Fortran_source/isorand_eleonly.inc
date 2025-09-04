
      subroutine isorand_eleonly(filename,w)

c     reading and manipulating elementary seis for all stations and a given (single) source position

c      dimension keygps(21)
      character*12 filename
      dimension w(1024,21,3,6)
c      dimension ntm(21)               ! new
      dimension nuse(21),weig(21,3)            ! new
c      logical stat(21)
c      CHARACTER *5 statname(21)

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
c      common /ST/ stat,ntm,statname
      common /WEI/ nuse,weig



      open(100,form='unformatted',file=filename,access='stream') !   Ifort (input)


      nnn=ntim

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

      REWIND(100)

c
c     FILTERING  ELEM. SEISMO 
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
         call filter_play(nnn,keyfil,keydis,f1,f4,dt,w(1,ir,icom,it))
	      enddo
          enddo
      enddo ! over stations
	  


        RETURN
        END
