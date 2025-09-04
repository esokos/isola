
      subroutine subevnt_play(aopt,w,ioptshf,sx)
      use mconst
      use numwei

c      real aopt(:), w(:,:,:,:), sx(:,:,:) ?
 
      
	  dimension aopt(6)
      dimension sx(NBO,NBS,3)
      dimension w(NBO,NBS,3,6)

c      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
c     *                 ff1(NBS),ff2(NBS),ff3(NBS),ff4(NBS),dt
	  
      
c  	  integer, parameter :: NBS=21 ! NBS = max number of stations
c	  include "par_dim_play.inc"

c
c     COMPUTING OPTIMUM SYNT SEISMO  (incl. IOPTSHFT in w)
c

      do itim=1,ntim
       do ir=1,nr
        do icom=1,3
        sx(itim,ir,icom)=0.
        enddo
       enddo
      enddo

      do itim=1,ntim
        if(itim-ioptshf.ge.1.and.itim-ioptshf.le.ntim) then
		do ir=1,nr
          do icom=1,3
            do n=1,nmom
             sx(itim,ir,icom)=sx(itim,ir,icom) +
     *            aopt(n)*w(itim-ioptshf,ir,icom,n)
        	enddo
          enddo
        enddo
        endif 
	  enddo


      RETURN
      END
