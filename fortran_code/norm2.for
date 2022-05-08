      program norm2
	  
      dimension x1(8192,21,3)
      dimension x2(8192,21,3)
      dimension x3(8192,21,3)
      dimension nuse(21),weig(3,21)
	  
      CHARACTER *5 statname(21)
      CHARACTER *17 statfil1,statfil2,statfil3

      open(99,file='inpinv.dat')
      open(100,file='allstat.dat')
      open(101,file='inv4.dat')   

	  write(*,*) 'This is NORM2'
	  
      do i=1,3
      read(99,*)
      enddo
      read(99,*) dt
       
	  
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
c        
c
c     READING SEISMOGRAMS (=DATA)
c

      do ir=1,nr         
        nfile=1000+1*ir
        statfil1=trim(statname(ir))//'fil.dat'
        open(nfile,file=statfil1)
        do itim=1,ntim     
c        read(nfile,'(4(1x,e12.6))') time,
        read(nfile,*) time,
     *      x1(itim,ir,1),x1(itim,ir,2),x1(itim,ir,3)
        enddo
      close(nfile) 
      enddo


      do ir=1,nr         
       nfile=2000+1*ir
       statfil2=trim(statname(ir))//'res.dat'
       open(nfile,file=statfil2)
        do itim=1,ntim   
c        read(nfile,'(4(1x,e12.6))') time,
        read(nfile,*) time,
     *      x2(itim,ir,1),x2(itim,ir,2),x2(itim,ir,3)
        enddo
	close(nfile)
      enddo

      do icom=1,3        
       do ir=1,nr        
        do itim=1,ntim   
        x3(itim,ir,icom)=x1(itim,ir,icom)-x2(itim,ir,icom) !x3 = syn data
        enddo
       enddo
      enddo


      anorm1=0.
      do icom=1,3        
       do ir=1,nr        
        do itim=1,ntim   
     	anorm1=anorm1+x1(itim,ir,icom)*x1(itim,ir,icom)*weig(icom,ir)**2.
        enddo
       enddo
      enddo
      anorm1=anorm1*dt        !integral of data squared
c If not inlcuding dt, UNC is different, needs greater vardat and 
c and plot samples per position is more peaky

      anorm2=0.
      do icom=1,3        
       do ir=1,nr        
        do itim=1,ntim   
c    	anorm2=anorm2+x2(itim,ir,icom)*x2(itim,ir,icom)
    	anorm2=anorm2+x2(itim,ir,icom)*x2(itim,ir,icom)*weig(icom,ir)**2.
        enddo
       enddo
      enddo
      anorm2=anorm2*dt        !integral of residuals squared
c If not inlcuding dt, UNC is different, needs greater vardat and 
c and plot samples per position is more peaky


      varred= 1. - anorm2/anorm1	! variance reduction WEIGHTED

      nrused=0	  
      do ir=1,nr
   	  nrused=nrused+nuse(ir) !number of used stations 
      enddo	  
	  
	  numbd=(3*nrused*5) ! number of data
c	  (assuming 5 independent samples per comp, only!!!)
c     (assuming, for simplicity, that all 3 comp. are taken at each used station)
c     (assuming just 1 subevent) 
      numbp= 7 ! number of parameters ( 1 sub with 5 MT components + 1 position + 1 time) 
c                ! if more subevents, then substitute 7 by 7 x number of subevents
c                ! unimportant if numbd >> numbp
	  numbdf=numbd - numbp
	  
c      postvar=anorm2/float(numbdf)  ! type0 (old; worked well, but not justified)
c      duref=(1./f1)
c     postvar=anorm2/(3.*float(nrused)*(1.-varred)*duref) ! type2
c     postvar=anorm1/(3.*float(nrused)*duref) ! type3 = type2 = estimate of mean ampl.              
c      postvar=anorm2/(3.*float(nrused)*duref) ! type4 (often will be too low) 


      irlast=1
      do ir=1,nr
      if(weig(1,ir).ne.0..and.weig(2,ir).ne.0..and.weig(3,ir).ne.0.)
     *    	  irlast=ir
      enddo
c      write(*,*) irlast ! last station with non-zero weights
	  
       xNmax=0.;xEmax=0.;xZmax=0.       
  	   do itim=1,ntim   
       if(abs(x1(itim,irlast,1)).gt.xNmax) xNmax=abs(x1(itim,irlast,1)) 
       if(abs(x1(itim,irlast,2)).gt.xEmax) xEmax=abs(x1(itim,irlast,2)) 
       if(abs(x1(itim,irlast,3)).gt.xZmax) xZmax=abs(x1(itim,irlast,3)) 
       enddo
       postvar= amax1(xNmax,xEmax,xZmax)**2.
c       write(*,*) postvar !  last station of non-zero weights: peak ampl. squared 
	   
      do ir=1,nr         
       nfile=3000+1*ir
       statfil3=trim(statname(ir))//'syn.dat'
       open(nfile,file=statfil3)
        do itim=1,ntim   
        time=float(itim-1)*dt
        write(nfile,'(4(1x,e12.5))') time,
     *      x3(itim,ir,1),x3(itim,ir,2),x3(itim,ir,3)
        enddo
	  close(nfile)
      enddo


      write(*,*) 
      write(*,*) 'variance reduction, weighted'
      write(*,*) 'varred=', varred


      write(101,*) anorm2,anorm1,varred,postvar,numbd,numbp,numbdf

      write(101,*) 
      write(101,*) 'integral of residuals squared, weighted'
      write(101,*)  anorm2

      write(101,*) 
      write(101,*) 'integral of data squared, , weighted'
      write(101,*)  anorm1

      write(101,*)
      write(101,*) 'variance reduction, weighted'
      write(101,*)  varred

      write(101,*) 
      write(101,*) 'number of data'
      write(101,*) '(assuming 5 indep. samples per comp.)'
      write(101,*) '(this is a problematic estimate)'
 	  write(101,*)  numbd

      write(101,*) 
      write(101,*) 'number of parameters'
      write(101,*) '(assuming 1 sub, 5 MT components,1 position,1 time)'
 	  write(101,*)  numbp

      write(101,*) 
      write(101,*) 'number of degrees of freedom'
      write(101,*) '(this is a problematic estimate)'
 	  write(101,*)  numbdf

      write(101,*) 
      write(101,*) 'data variance'
      write(101,*) '(this is a problematic estimate)'
      write(101,*)  postvar


      stop
      end

 