      subroutine isorand_A2 

c Reading inpinv.dat and allstat.dat (station names, weights, frequencies)
c creating commons /NNLS/, /NUMBERS/, /ST/, /WEI/

      CHARACTER *5 statname(21)

      dimension ntm(21)
      dimension nuse(21),weig(21,3),weigorig(21,3)

      logical stat(21)   

      common /NNLS/ nshf,keymomcns,xmomreq12,ngrid
      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm,statname 
      common /WEI/ nuse,weig,weigorig
c      common /PERT/ npert,nuseall	  

      open(150,file='allstat.dat')   ! input: stations, original weights, frequencies
      open(151,file='inpinv.dat') 
 
	  
      write(*,*) 'This is isorand_A2'
			
      ntim=1024
      isubmax=0 ! obsolete but to be kept 
  	  ifirst=0;istep=0;ilast=0
	  keymomcns=0 ! fixed option; not used
	  xmomreq12=1e12

! ************READING inpinv.dat = control parameters     ***************

      read(151,*) 
      read(151,*) keyinv	 ! not used !!
      read(151,*) 
      read(151,*) dt             
      read(151,*) 
      read(151,*) ngrid           ! number of trial source positions  

      if(keyinv.eq.1) nmom=6
      if(keyinv.eq.2) nmom=5
      if(keyinv.eq.3) nmom=999
      if(keyinv.eq.4) nmom=999
      
! *******************************************************************
! ************READING allstat.dat (definition of stations) ******
! *******************************************************************
      

	  ir=1
  7   read(150,*,end=8) statname(ir),nuse(ir),	    ! nuse=0 ... station not used 
     * weigorig(ir,1),weigorig(ir,2),weigorig(ir,3), ! weig=0 ... component not used
     * ff1(ir),ff2(ir),ff3(ir),ff4(ir)

       if(nuse(ir).eq.0) then
       weigorig(ir,1)=0
	   weigorig(ir,2)=0
	   weigorig(ir,3)=0 ! No need to care about stat; all info is in weig
       endif

       ir=ir+1
	   if(ir.gt.21) goto 8
       goto 7
  8    nr=ir-1
       write(*,*) 'number of stations (max 21), nr=', nr
       close (150)
      
      write (*,*) 'number of trial positions ', ngrid
      write (*,*) 'time step (s)', dt

 
    
c      nuseall=0
c      read(152,*) npert
c      do ip=1,npert
c      read(152,*) (nuseall(ir,ip),ir=1,nr)
c      enddo	  
c      close (152)
C	  write(*,*) nuseall
	  
      RETURN
      END

