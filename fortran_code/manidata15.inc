
      subroutine manidata15(keygps,x,rr)

c See 'new' for CUT version	  
c Manipulating the data. Input data x, output data also x (re-written).
c Power of the data rr.

      dimension x(8192,21,3)
	  dimension weig(21,3) !!!!!! NEW Sep 9, 2015
      dimension ntm(21),keygps(21)
      logical stat(21)

      common /WEI/ weig !!!!!! NEW Sep 9, 2015


c      CHARACTER *5 statname(21)
c      character *17 statfil1,statfil2,statfil3  !!g77


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt

      common /ST/ stat,ntm

c *******************************************************************
c *************MANIPULATING OBSERVED DATA****************************
c *******************************************************************

      do ir=1,nr
        do itim=1,ntim
            x(itim,ir,1)=0.
            x(itim,ir,2)=0.
            x(itim,ir,3)=0.
        enddo
      enddo

c
c     READING velocity SEISMOGRAMS TO BE INVERTED (=DATA)
c
      
      do ir=1,nr
c      write(*,*) 'xlimsec=?'
c      read(*,*) xlimsec	  
      nfile=1000+1*ir
c      statfil1=trim(statname(ir))//'raw.dat'
c      open(nfile,file=statfil1)
      do itim=1,ntim
      read(nfile,*) time,
     *      x(itim,ir,1),x(itim,ir,2),x(itim,ir,3)
        enddo
c      lim1=ifix(xlimsec/dt)    !!!!!!!!!!!!!!!!!!!!!!!!! new
c	  do itim=lim1,ntim
c         x(itim,ir,1)=x(itim,ir,1)/100.
c		 x(itim,ir,2)=x(itim,ir,2)/100.
c		 x(itim,ir,3)=x(itim,ir,3)/100.
c        enddo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  new

c      close(nfile)
      enddo




c
c     FILTERING THE DATA - OLD !!! 
c
c      do ir=1,nr
c        do icom=1,3
c         call filter(f1,f2,f3,f4,dt,x(1,ir,icom))
c        enddo
c      enddo




c
c     FILTERING THE DATA 
c     GPS data supposed to be in ***raw as shifted by 50s, LF displacement
c


      do ir=1,nr
      if(keyGPS(ir).eq.0) then !!!!!! filter only for SEIS; but suppressed for gps
	  f1=ff1(ir)  !not used for LP!!!! 'filter' involves 50s shift, filtr, integration, stabilizations
	  f4=ff4(ir)  !not used for HP!!!!
      keyfil=0 !(BP=0, LP=1, HP=2)   ! LP to avoid double suppression of low freq after pre-filtering in GUI
      keydis=1 !(vel=0, displ=1)   
      shift=0. ! shift 50 s is impossible if TL<50s !!!!!!!!!
        do icom=1,3
          call filter15(keyfil,keydis,shift,f1,f4,dt,x(1,ir,icom))	 ! seis. has the OLD filter
c         call filter(f1,f2,f3,f4,dt,x(1,ir,icom))	 ! seis. has the OLD filter
c        call filter_stat(f1,f2,f3,f4,dt,x(1,ir,icom)) ! this is a NEW ('clever') filter to support statics  
c CAUTION same option as here (the old filter or new) must be also in elemat2_12c_mix 
        enddo
      endif    !!!!!!!!!!!!!!!!!!!
	  enddo


      do ir=1,nr          ! output of filtered input data
      nfile=2000+1*ir
c      statfil2=trim(statname(ir))//'fil.dat'
c      open(nfile,file=statfil2)
        do itim=1,ntim
        time=float(itim-1)* dt
        write(nfile,'(4(1x,e12.5))') time,
     *       x(itim,ir,1), x(itim,ir,2), x(itim,ir,3)
        enddo
c	  close(nfile)
      enddo


c
c     COMPUTING 'POWER' OF THE original DATA (the USED stations ONLY !)
c

      rr=0.
      do icom=1,3                                       !icom=seismo comp.
        do ir=1,nr                                      !  ir=station
        if(stat(ir)) then
          do itim=1,ntim ! ntim or 4000! For ACRE can change ntim here to 4000 and in ISOLA15 to get VR

c          rr=rr+x(itim,ir,icom)*x(itim,ir,icom)     ! old (no weights)
           rr=rr+ (x(itim,ir,icom)*weig(ir,icom))**2 ! new (with weights) 9.9. 2015

          enddo
        endif
        enddo
      enddo
      rr=rr*dt

      RETURN
      END

