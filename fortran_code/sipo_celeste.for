      program SIPOceleste

      dimension a(6),asum(6)
c        READING input.dat and averaging in terms of MT

      open(50,file='input_c.dat') ! 
      open(55,file='output_c.dat') ! 
      write(*,*) 'number of solutions?'
      read(*,*) numsol
      write(*,*) numsol	  
	  
      do i=1,6
      asum(i)=0.
      enddo	  
      
      dum3=0.
	  dum4=0.
	  num4=0     
    	  
	
c**********************************************************      

      do 60 isol=1,numsol   ! loop over all solutions in Celeste's file 

      read(50,*) istr,idip,irak
	  strike=float(istr)
	  dip=float(idip)
	  rake=float(irak)
     
ccccccccccccccccccccccccccccc end of new part cccccccccccccccccc 
 
c          another new part averaging MT
      call  sdr_mt(strike,dip,rake,a)
      do i=1,6
      asum(i)=asum(i)+a(i)	 ! cummulative MT (summimng UNIT-moment tensors) 
      enddo !  division by number of solution  not needed
	  
60    continue   ! ending loop over all solutions
	  
ccccccccccccccc  output of averaged solution in threshold ccccccccccccccccc 

      call silsub(asum,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
     * 	        avol)
      call pl2pt(str1,dip1,rake1,azp,ainp,azt,aint,azb,ainb,ierr)

      write(55,
     *   '(1x,i5,1x,f6.2,1x,e12.6,12(1x,f6.0),1x,f6.1,1x,e12.4)')
     *           num4,dum3,dum3,str1,dip1,rake1,
     *           str2,dip2,rake2,azp,ainp,azt,aint,azb,ainb,
     *           dum3,dum4

 1000 continue 
      stop
      end

c ************************************************************************
      subroutine sdr_mt(strike,dip,rake,a)
      dimension a(6)
        xmoment=1.        !!!!!!!!!!!!!!!!!!!!!!!!!!!
		pi=3.1415927
    	strike=strike*pi/180.
        dip=dip*pi/180.
 	    rake=rake*pi/180.
 	    sd=sin(dip)
 	    cd=cos(dip)
 	    sp=sin(strike)
		cp=cos(strike)
		sl=sin(rake)
		cl=cos(rake)
		s2p=2.*sp*cp
		s2d=2.*sd*cd
		c2p=cp*cp-sp*sp
		c2d=cd*cd-sd*sd

		xx1 =-(sd*cl*s2p + s2d*sl*sp*sp)*xmoment     ! Mxx
		xx2 = (sd*cl*c2p + s2d*sl*s2p/2.)*xmoment    ! Mxy
		xx3 =-(cd*cl*cp  + c2d*sl*sp)*xmoment        ! Mxz
		xx4 = (sd*cl*s2p - s2d*sl*cp*cp)*xmoment     ! Myy
		xx5 =-(cd*cl*sp  - c2d*sl*cp)*xmoment        ! Myz
		xx6 =             (s2d*sl)*xmoment           ! Mzz

		a(1) = xx2
		a(2) = xx3
		a(3) =-xx5
		a(4) = (-2.*xx1 + xx4 + xx6)/3.
		a(5) = (xx1 -2*xx4 + xx6)/3.
		a(6)=0.

        return
        end		
		
      include "pl2pt.inc"
      include "silsub.inc"
      include "jacobi.inc"
      include "line.inc"
      include "ang.inc"
      include "angles.inc"
