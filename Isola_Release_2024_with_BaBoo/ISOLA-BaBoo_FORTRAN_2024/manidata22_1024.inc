      subroutine manidata22_1024(keygps,x,rr)

c This is manidata for IsoRAND

c Manipulating the data of all stations. Input data x, output data also x (re-written).
c Power of the data rr.

      dimension x(1024,21,3)
      dimension weig(21,3) 
      dimension ntm(21),keygps(21)
      logical stat(21) ! obsolete, but to be kept

       CHARACTER *5 statname(21)
       character *17 statfil1,statfil2  

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm,statname
      common /WEI/ weig
	  
c *******************************************************************
c *************MANIPULATING OBSERVED DATA****************************
c *******************************************************************

      nnn=ntim
	  x=0. ! initialization      
      
c
c     READING velocity SEISMOGRAMS TO BE INVERTED (=DATA)
c

      do ir=1,nr
      nfile=1000+1*ir
      statfil1=trim(statname(ir))//'raw.dat' 
      open(nfile,file=statfil1)
      do itim=1,ntim
      read(nfile,*) time,
     *      x(itim,ir,1),x(itim,ir,2),x(itim,ir,3)
        enddo
      close(nfile)
      enddo
c      write(*,*) 'raw data read'
	  
c
c     FILTERING THE DATA 
c     GPS data supposed to be in ***raw as shifted by 50s, LF displacement
c

      do ir=1,nr
	  f1=ff1(ir)  
	  f4=ff4(ir)  
      keyfil=0 !(BP=0, LP=1, HP=2)   
      keydis=1 !(vel=0, displ=1)   
c      shift=0. 
        do icom=1,3
c        call filter15_1024(keyfil,keydis,shift,f1,f4,dt,x(1,ir,icom))	 
        call filter_play(nnn,keyfil,keydis,f1,f4,dt,x(1,ir,icom))
        enddo
      enddo
c      write(*,*) 'raw data filtered'
	  
c     goto 666      ! SKIP output of FIL
	  
      do ir=1,nr          ! output of filtered input data LATER SUPPRESS if not calling NORM
      nfile=2000+1*ir
      statfil2=trim(statname(ir))//'fil.dat'
      open(nfile,file=statfil2)
        do itim=1,ntim
        time=float(itim-1)* dt
        write(nfile,'(4(1x,e13.6))') time,
     *       x(itim,ir,1), x(itim,ir,2), x(itim,ir,3)
        enddo
	  close(nfile)
      enddo
	  
 666  CONTINUE

c
c     COMPUTING 'POWER' OF THE original DATA (the USED stations ONLY !)
c

c      rr=0.
c      do icom=1,3                                       !icom=seismo comp.
c        do ir=1,nr                                      !  ir=station
c          do itim=1,ntim  
c           rr=rr+ (x(itim,ir,icom)*weig(ir,icom))**2 ! new (with weights) 9.9. 2015
c          enddo
c        enddo
c      enddo
c      rr=rr*dt

      RETURN
      END

