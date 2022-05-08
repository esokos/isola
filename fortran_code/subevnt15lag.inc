
      subroutine subevnt15lag(aopt,w,ilagx,ilagy,ilagz,sx)

      dimension aopt(6)
      dimension sx(8192,21,3)
      dimension w(-3500:11692,21,3,6)
      dimension ntm(21)
	  dimension ilagx(21),ilagy(21),ilagz(21) ! shifts of 3 comp per station
      logical stat(21)

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm

c

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
        do ir=1,nr
          do icom=1,3
          if(icom.eq.1) ioptshf=ilagx(ir)
		  if(icom.eq.2) ioptshf=ilagy(ir)
	      if(icom.eq.3) ioptshf=ilagz(ir)
			do n=1,nmom
			  sx(itim,ir,icom)=sx(itim,ir,icom) +
     *            aopt(n)*w(itim-ioptshf,ir,icom,n)
            enddo
          enddo
        enddo
      enddo


      RETURN
      END
