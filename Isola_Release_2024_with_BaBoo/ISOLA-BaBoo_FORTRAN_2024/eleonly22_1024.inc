
      subroutine eleonly22_1024(keygps,filename,w)

c     reading and manipulating elementary seis for all stations and a given (single) source position

      dimension keygps(21)
      character*12 filename
      dimension w(1024,21,3,6)
c      dimension ntm(21)               ! new
      dimension weig(21,3)            ! new
c      logical stat(21)
c      CHARACTER *5 statname(21)

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
c      common /ST/ stat,ntm,statname
      common /WEI/ weig



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
      if(keyGPS(ir).eq.0) then ! only this part is used
	  
	  f1=ff1(ir)  
	  f4=ff4(ir)
      keyfil=0 !(BP=0, LP=1, HP=2)   
      keydis=1 !(vel=0, displ=1)   
      shift=0.
          do icom=1,3
          do it=1,6 ! here MUST be 6, not nmom
c        call filter15_1024(keyfil,keydis,shift,f1,f4,dt,w(1,ir,icom,it))	 
         call filter_play(nnn,keyfil,keydis,f1,f4,dt,w(1,ir,icom,it))
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
c        call filter15_1024(keyfil,keydis,shift,f1,f4,dt,w(1,ir,icom,it))	 ! seis. has the OLD filter
         call filter_play(nnn,keyfil,keydis,f1,f4,dt,w(1,ir,icom,it))
	      enddo
          enddo
      endif
	      
c      if(keyGPS(ir).eq.2) then ! for 2 pure statics (after integration in filter CAUTION what filtration is used
c      do it=1,6
c       do itim=-3500,11692
c        do itim=1,ntim-1
c
c      w(itim,ir,1,it)=w(8192,ir,1,it)  ! in case of problems can be substitued by some average at the 'end part'
c      w(itim,ir,2,it)=w(8192,ir,2,it) 	! put 'c' if you want to see COMPLETE synth seis in FORWARD  modeling of GPS
c      w(itim,ir,3,it)=w(8192,ir,3,it) 	! use of complete synth in case of keyGPS=2 not tested , probably possible but with lower VR 
c
c	  enddo
c	  enddo
c	  endif

      enddo ! over stations
	  
c       open(8256,file='testunc.dat') 
c        do ir=1,nr   !!only 1st station         ! output of elemse for plotting WITH FILTER
c          do it=1,6         
c            do itim=1,ntim
c           time=float(itim-1)*dt
c           write(8256,'(4(1x,e12.6))') time,
c     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
c           enddo
c           write(8256,*) '*'
c         enddo
c       enddo
c       close(8256)


        RETURN
        END
