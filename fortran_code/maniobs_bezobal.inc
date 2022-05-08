
      subroutine maniobs_bezobal(x,y1,y2,rr)

c Manipulating OBSERVED data. 
c Input seismo x, output seimo also x (re-written)= XAPIIR filtered and transformed to displ
c output envelope y1, output ampl.sp y2.
c Power of the data rr.

      dimension x(8192,21,3)
	dimension y1(8192,21,3),y2(8192,21,3)
      dimension weig(21,3) 
      dimension ntm(21)
	  logical stat(21)

c      CHARACTER *5 statname(21)
c      character *17 statfil1,statfil2,statfil3  !!g77

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt

      common /ST/ stat,ntm
      common /WEI/ weig 

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
	  nfile=1000+1*ir
c      statfil1=trim(statname(ir))//'raw.dat' ! defined in main
c      open(nfile,file=statfil1)
      do itim=1,ntim
      read(nfile,*) time,
     *      x(itim,ir,1),x(itim,ir,2),x(itim,ir,3)
        enddo
c      close(nfile)
      enddo

           
      
c
c     FILTERING THE DATA - XAPIIR (filter15) 
c

      do ir=1,nr
 	  f1=ff1(ir)  
	  f4=ff4(ir)  
      keyfil=0 !(BP=0, LP=1, HP=2)   
      keydis=1 !(vel=0, displ=1)  ! DISPLACEMENT 
      shift=0. ! shift 50 s is impossible if TL<50s !!!!!!!!!
        do icom=1,3
        call filter15(keyfil,keydis,shift,f1,f4,dt,x(1,ir,icom))	! x is re-written 
        enddo
      enddo

C OUTPUT INTO FILE *FIL.DAT        
        
c      do ir=1,nr          ! output of filtered input data integrated to DISPL
c      nfile=2000+1*ir
c        do itim=1,ntim
c        time=float(itim-1)* dt
c        write(nfile,'(4(1x,e12.6))') time,
c     *       x(itim,ir,1), x(itim,ir,2), x(itim,ir,3)
c        enddo
c	  close(nfile)
c      enddo


c
c     COMPUTING 'POWER' OF FILT. DISPL time series (the USED stations ONLY !)
c

      rr=0.
      do icom=1,3                                       !icom=seismo comp.
        do ir=1,nr                                      !  ir=station
        if(stat(ir)) then
          do itim=1,ntim 
           rr=rr+ (x(itim,ir,icom)*weig(ir,icom))**2 ! new (with weights) 9.9. 2015
          enddo
        endif
        enddo
      enddo
      rr=rr*dt

            

c
c     using the FILTERED DISPL DATA x for amplitude for envelope and ampl sp. 
c

      do ir=1,nr
      do itim=1,ntim
            y1(itim,ir,1)=x(itim,ir,1) ! saving filtered data x 
            y1(itim,ir,2)=x(itim,ir,2) !(x go to output, cannot be used more here)
            y1(itim,ir,3)=x(itim,ir,3)
      enddo
      enddo

      goto 678 ! to skip envelopes and spectra; propcessing waveforms
	  
      do ir=1,nr
      do icom=1,3         ! filter used is FCOOLR, incl. Hilbert
         call filtmore(dt,y1(1,ir,icom),y2(1,ir,icom)) !new (envel and ampl. sp )
      enddo ! y1 input rewritten by y1 output =envelope, y2=ampl sp. of x
      enddo
	  
 678  continue ! skipped
 
 
c OUTPUT IN A FILE  y1 or y2       
      
c      do ir=1,nr          
c      nfile=2000+1*ir !see Main
c        do itim=1,ntim
c        time=float(itim-1)* dt
c        write(nfile,'(4(1x,e12.6))') time,
c     *       y1(itim,ir,1), y1(itim,ir,2), y1(itim,ir,3)
c        enddo
c      enddo

      
      RETURN
      END

      
