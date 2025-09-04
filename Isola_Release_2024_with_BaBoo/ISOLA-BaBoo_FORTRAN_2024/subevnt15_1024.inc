
      subroutine subevnt15_1024(aopt,w,ioptshf,sx)

      dimension aopt(6)
      dimension sx(1024,21,3)
c      dimension w(-3500:11692,21,3,6)  !
      dimension w(1024,21,3,6)          ! NEW to keep simple dim in main
	  dimension w2(-1024:2048,21,3,6)  ! NEW to enable shifts HERE (1024 is maximum possible) 
      dimension ntm(21)
      logical stat(21)

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm

      if(abs(ioptshf).gt.1024) then
	  write(*,*) 'Problem DIM in subevnt15; STOP'
	  STOP
	  endif
	  

      w2=0. !!!!!!!! initialized in BROADER limits 

	  do i1=1,1024 
	  do i2=1,21
	  do i3=1,3
	  do i4=1,6
	  w2(i1,i2,i3,i4)=w(i1,i2,i3,i4)  
	  enddo
	  enddo
	  enddo
	  enddo


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
            do n=1,nmom
            sx(itim,ir,icom)=sx(itim,ir,icom) +
     *            aopt(n)*w2(itim-ioptshf,ir,icom,n)
            enddo
          enddo
        enddo
      enddo


      RETURN
      END
