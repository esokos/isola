      subroutine prepsyn(x,y1,y2)

c Manipulating SYNTH SEIS. 
c Input seismo x (already filtered displacement with focal mechanism included), 
c output envelope y1, output ampl.sp y2.

      dimension x(8192,21,3)
	dimension y1(8192,21,3),y2(8192,21,3)
      dimension weig(21,3) 
      dimension ntm(21)
      logical stat(21)

      common /WEI/ weig 


c      CHARACTER *5 statname(21)
c      character *17 statfil1,statfil2,statfil3  !!g77


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt

      common /ST/ stat,ntm


      fnyq=1./(2.*dt)
      f1=0.
      f2=0.
      f3=fnyq
      f4=fnyq
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

      do ir=1,nr
      do icom=1,3         ! filter ased on FCOOLR, incl. Hilbert
      call filtmore(dt,y1(1,ir,icom),y2(1,ir,icom)) !new (envel and ampl. sp )
      enddo ! y1=envelope of x, y2=ampl sp. of x
      enddo

      
      RETURN
      END

