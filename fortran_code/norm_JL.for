      program norm_JL

      dimension x1(8192,21,3)
      dimension x2(8192,21,3)
      dimension x3(8192,21,3)
      dimension nuse(21),weig(3,21)
	  
c     CHARACTER *12 filename
      CHARACTER *5 statname(21)
      CHARACTER *17 statfil1,statfil2,statfil3


      open(99,file='inpinv.dat')
      open(100,file='allstat.dat')
      open(101,file='inv4.dat')   ! final varred from all stats (no weights)
                                  ! incl stations removed from inversion

      do i=1,3
      read(99,*)
      enddo
      read(99,*) dt

      write(*,*) 'startting and ending time in sec for VR:'
      read (*,*) time1,time2
      ntim1=ifix(time1/dt) + 1	  
	  ntim2=ifix(time2/dt) + 1  
	  
      ir=1
  10  read(100,*,end=20) statname(ir),nuse(ir),
     *                   weig(1,ir),weig(2,ir),weig(3,ir)
      ir=ir+1
      if(ir.gt.21) goto 20
      goto 10
  20  continue
      nr=ir-1
      write(*,*) 'nr=', nr
c     if(nr.gt.21) then
c     write(*,*) 'TOO MANY STATIONS !!!!!'
c     stop
c     endif

      do ir=1,nr
   	  if(nuse(ir).eq.0) then
      weig(1,ir)=0.    !!!!!!!! weights REDEFINED to ZERO if station not used      
      weig(2,ir)=0.
      weig(3,ir)=0.	  
      endif
      enddo	  


       ntim=8192
c        ntim=4000
c
c     READING SEISMOGRAMS (=DATA)
c


      do ir=1,nr         
        nfile=1000+1*ir
        statfil1=trim(statname(ir))//'fil.dat'
        open(nfile,file=statfil1)
        do itim=1,ntim     
        read(nfile,'(4(1x,e12.6))') time,
     *      x1(itim,ir,1),x1(itim,ir,2),x1(itim,ir,3)
        enddo
      close(nfile) 
      enddo


      do ir=1,nr         
       nfile=2000+1*ir
       statfil2=trim(statname(ir))//'syn.dat'   !!!!!! instead of res!!!!!!!!!
       open(nfile,file=statfil2)
        do itim=1,ntim   
        read(nfile,'(4(1x,e12.6))') time,
     *      x2(itim,ir,1),x2(itim,ir,2),x2(itim,ir,3)
        enddo
	close(nfile)
      enddo

      do icom=1,3        
       do ir=1,nr        
        do itim=1,ntim   
        x3(itim,ir,icom)=x1(itim,ir,icom)-x2(itim,ir,icom)  !! now this is residual fil-syn
        enddo
       enddo
      enddo


      anorm1=0.
      do icom=1,3        
       do ir=1,nr        
        do itim=ntim1,ntim2 !!!!!! new   
     	anorm1=anorm1+x1(itim,ir,icom)*x1(itim,ir,icom)*weig(icom,ir)**2.
        enddo
       enddo
      enddo
      anorm1=anorm1*dt        !sum of data squared


      anorm2=0.
      do icom=1,3        
       do ir=1,nr        
        do itim=ntim1,ntim2 !!!!!! new   
    	anorm2=anorm2+x3(itim,ir,icom)*x3(itim,ir,icom)*weig(icom,ir)**2.	! NEW 	residual
        enddo
       enddo
      enddo
      anorm2=anorm2*dt        !sum of residuals squared


      varred= 1. - anorm2/anorm1	! variance reduction WEIGHTED



      write(*,*) 'dt, time1, time2 (s):' 
      write(*,*) dt, time1, time2  
      write(*,*)
	  write(*,*) 'variance reduction between time1 and time2:'
      write(*,*) 'varred=', varred

      stop
      end

 