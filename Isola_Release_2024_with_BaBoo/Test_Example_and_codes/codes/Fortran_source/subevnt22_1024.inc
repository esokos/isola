
      subroutine subevnt22_1024(isr,aopt,ioptshf,sx)

      dimension aopt(6)
      dimension sx(1024,21,3)
      dimension e(1024,21,3,6,99) ! elementary seismograms 
c      dimension ntm(21)
c      logical stat(21)
c      CHARACTER *5 statname(21)

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
c      common /ST/ stat,ntm,statname
      common /ELEMS/ e	  

c

c
c     COMPUTING OPTIMUM SYNT SEISMO  (incl. IOPTSHFT in w)
c
      sx=0.

      do itim=1,ntim
        do ir=1,nr
          do icom=1,3
            do n=1,nmom        
            itimnew=itim-ioptshf 
			  if(itimnew.ge.1.and.itimnew.le.ntim) then 	  
            sx(itim,ir,icom)=sx(itim,ir,icom) +
     *            aopt(n)*e(itim-ioptshf,ir,icom,n,isr)
              endif      
           enddo
          enddo
        enddo
      enddo


      RETURN
      END
