
      subroutine eleonly15(keygps,filename,w)

c     only reading elem seis for a given source position

      dimension keygps(21)
      character*12 filename
      dimension w(-3500:11692,21,3,6)
      dimension r(6,6),rinv(6,6),rold(6,6)
      dimension indx(6),y(6,6)
      dimension ntm(21)               ! new
      dimension weig(21,3)            ! new
      logical stat(21)


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

      REWIND(100)

c
c     FILTERING THE ELEM. SEISMO - OLD !!!
c
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

	  f1=ff1(ir)  !!!!! 'filter':  filtr, integration, stabilizations
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



        RETURN
        END
