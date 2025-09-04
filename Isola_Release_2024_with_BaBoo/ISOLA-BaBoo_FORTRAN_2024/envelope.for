      program envelope


      dimension x(8192,21,3)
	  dimension y1(8192,21,3),y2(8192,21,3)
      dimension weig(21,3) 
      dimension ntm(21)
	  logical stat(21)

      CHARACTER *5 statname(21)
      character *17 statfil1,statfil2,statfil3  !!g77

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt

      common /ST/ stat,ntm
      common /WEI/ weig 

c *******************************************************************
c *************MANIPULATING OBSERVED DATA****************************
c *******************************************************************

      ntim=1024
	  npom=516
	  dt=0.24
      nr=1
      statname(1) = 'ANX'

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
      statfil1=trim(statname(ir))//'raw.dat' ! defined in main
c      open(nfile,file=statfil1)
      open(50,file='ANXraw.dat')
      do itim=1,ntim
      read(50,*) time,
     *      x(itim,ir,1),x(itim,ir,2),x(itim,ir,3)
        enddo
      close(50)
      enddo


c      fnyq=1./(2.*dt)
c      f1=0.
c      f2=0.
c      f3=fnyq
c      f4=fnyq

c
c     using  x  
c

      do ir=1,nr
      do itim=1,ntim
            y1(itim,ir,1)=x(itim,ir,1) ! saving filtered data x 
            y1(itim,ir,2)=x(itim,ir,2) !(x go to output, cannot be used more here)
            y1(itim,ir,3)=x(itim,ir,3)
      enddo
      enddo

      	  
	  open(100,file='ANXfil.dat') 
      do itim=1,ntim
	  time=float(itim-1)*dt
	  write(100, '(4(1x,e12.5))') 
     * time,y1(itim,1,1),y1(itim,1,2),y1(itim,1,3)
      enddo
	  close(100)

c      goto 8000

      do ir=1,nr
      do icom=1,3         ! filter based on FCOOLR, incl. Hilbert
      call filtmore(dt,y1(1,ir,icom),y2(1,ir,icom)) !new (envel and ampl. sp )
      enddo ! y1=envelope of x, y2=ampl sp. of x
      enddo

      open(200,file='ANXsyn.dat') 
      do itim=1,ntim
	  time=float(itim-1)*dt
	  write(200, '(4(1x,e12.5))')
     * time,y1(itim,1,1),y1(itim,1,2),y1(itim,1,3)
      enddo
	  close(200)
 
8000  continue
      stop      
      END

      
      include "fcoolr.inc"
      include "filtmore.inc" 


