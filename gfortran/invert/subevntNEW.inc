
      subroutine subevntNEW(aopt,w,ioptshf,sx)

      dimension aopt(6)
      dimension sx(8192,21,3)
      dimension w(-2500:10692,21,3,6)
      dimension ntm(21)
      logical stat(21)

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 f1,f2,f3,f4,dt
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
c                         trebaze volano z DEVIA verze (nmom=5)
c                         zname (zadane) a6 a  pouzijeme ho spolu s vypoctenym a1=a5

      do itim=1,ntim
        do ir=1,nr
          do icom=1,3
            do n=1,         6 !                               N E W                                               nmom
            sx(itim,ir,icom)=sx(itim,ir,icom) +
     *            aopt(n)*w(itim-ioptshf,ir,icom,n)
            enddo
          enddo
        enddo
      enddo


      RETURN
      END
