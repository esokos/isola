       subroutine subCAS15(ampl,w,sx,NTR2)

c input  w= seimogram pro kazdou posunutou cas.fci = sloupce matice G
c  	   ampl= momentove vahy ('amplitudy')  jednotlivych posunutych seismogramu s jednotkovymi momenty
c output sx= seismogram jako lin kombinacew posunutych cas fci s amplitudami ampl    
 
     
      dimension sx(8192,21,3)
      dimension  w(8192,21,3,24)
      dimension ntm(21)
      logical stat(21)
c*******************************
       double precision  ampl(24) ! 2x12 triangles
c      dimension ampl(24)
c*******************************

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm


      do itim=1,ntim
       do ir=1,nr
        do icom=1,3
        sx(itim,ir,icom)=0.
        enddo
       enddo
      enddo


 	
      do itim=1,ntim
        do ir=1,nr	   ! inlcuding non-used stations
          do icom=1,3
            do it=1,24 ! max 24 triangles  
            sx(itim,ir,icom)=sx(itim,ir,icom) +
     *         ampl(it)*w(itim,ir,icom,it) 
            enddo	
          enddo	
        enddo
      enddo


      RETURN
      END
