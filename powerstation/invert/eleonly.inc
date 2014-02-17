
      subroutine eleonly(filename,w)

c     only reading elem seis for a given source position

      character*12 filename
      dimension w(-2500:10692,21,3,6)
      dimension r(6,6),rinv(6,6),rold(6,6)
      dimension indx(6),y(6,6)
      dimension ntm(21)               ! new
      dimension weig(21,3)            ! new
      logical stat(21)


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 f1,f2,f3,f4,dt
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

      REWIND(100)

c
c     FILTERING THE ELEM. SEISMO
c

      do ir=1,nr
        do icom=1,3
          do it=1,6 ! here MUST be 6, not nmom
          call filter(f1,f2,f3,f4,dt, w(1,ir,icom,it) )
          enddo
        enddo
      enddo


        RETURN
        END
