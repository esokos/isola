      subroutine manidata_play(x,rr)

c Manipulating the data. Input data x, output data also x (re-written).
c Power of the data rr.
c All 'open', 'close' and filenames are in MAIN

      
	  use mconst
	  use numwei
	  dimension x(NBO,NBS,3) ! x je lokalni ?nebo jak se tomu rika, nikoli alokovana
      

c	  include "par_dim_play.inc" ! for dimension NBS

c NBO can be dim. of x, because x is variable not in common
c NBS defined by parameter of subr. cannot be dim. in common
c Use of 'inlcude' is a trick to avoid defining of constant NBS value in each subr.
 	  	  
c	  common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
c     *                 ff1(NBS),ff2(NBS),ff3(NBS),ff4(NBS),dt
c      common /WEI/ weig(NBS,3) 

c !! It is not possible to have dimension NBS in common defined by parameter of subr. 	  
c !! But it canbe like this, NBS defined as integer here.
c ! 'Variable dimension of common are not allowed'
c ? Mozna se lze doptat na dimensi weig jak je v main a rict nejak aby byla stejna
 
          nnn=ntim
		  
c *******************************************************************
c *************MANIPULATING OBSERVED DATA****************************
c *******************************************************************

c      do ir=1,nr
c        do itim=1,ntim
c            x(itim,ir,1)=0.
c            x(itim,ir,2)=0.
c            x(itim,ir,3)=0.
c        enddo
c      enddo
      
	  x=0. 

c
c     READING velocity SEISMOGRAMS TO BE INVERTED (=DATA)
c
      
      do ir=1,nr
c      write(*,*) 'xlimsec=?'     !! to proces only part of data and suppress the rest 
c      read(*,*) xlimsec	      !!
      nfile=1000+1*ir
       do itim=1,ntim
      read(nfile,*) time,
     *      x(itim,ir,1),x(itim,ir,2),x(itim,ir,3)
       enddo
c	  lim1=ifix(xlimsec/dt)    !!!
c	  do itim=lim1,ntim
c        x(itim,ir,1)=x(itim,ir,1)/100.  !! suppressing 
c		 x(itim,ir,2)=x(itim,ir,2)/100.  !!
c		 x(itim,ir,3)=x(itim,ir,3)/100.  !! 
c        enddo
      enddo



c
c     FILTERING THE DATA 
c

      do ir=1,nr
	  f1=ff1(ir)  !not used for LP!!!! 'filter' involves 50s shift, filtr, integration, stabilizations
	  f4=ff4(ir)  !not used for HP!!!!
      keyfil=0 !(BP=0, LP=1, HP=2)   ! LP to avoid double suppression of low freq after pre-filtering in GUI
      keydis=1 !(vel=0, displ=1)   
      shift=0. ! shift 50 s is impossible if TL<50s !!!!!!!!!
        do icom=1,3
        call filter_play(nnn,keyfil,keydis,f1,f4,dt,x(1,ir,icom))
c         call filter15(keyfil,keydis,shift,f1,f4,dt,x(1,ir,icom))
        enddo
	  enddo


      do ir=1,nr          ! output of filtered input data
      nfile=2000+1*ir
        do itim=1,ntim
        time=float(itim-1)* dt
        write(nfile,'(4(1x,e13.6))') time,
     *       x(itim,ir,1), x(itim,ir,2), x(itim,ir,3)
        enddo
      enddo


c
c     COMPUTING 'POWER' OF THE original DATA (the USED stations ONLY, via weig !)
c

      rr=0.
      do icom=1,3                                       
        do ir=1,nr                                      
          do itim=1,ntim 
           rr=rr+ (x(itim,ir,icom)*weig(ir,icom))**2 
          enddo; enddo;  enddo
      rr=rr*dt

      RETURN
      END

