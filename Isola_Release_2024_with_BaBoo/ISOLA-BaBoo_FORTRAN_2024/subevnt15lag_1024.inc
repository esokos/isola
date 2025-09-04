
      subroutine subevnt15lag_1024(aopt,w,ilagx,ilagy,ilagz,sx)

      dimension aopt(6)
      dimension sx(1024,21,3)
c      dimension w(-3500:11692,21,3,6)
      dimension w(1024,21,3,6)
      dimension w2(-1024:2048,21,3,6)  ! NEW to enable shifts HERE (1024 is maximum possible)
      dimension ntm(21)
	  dimension ilagx(21),ilagy(21),ilagz(21) ! shifts of 3 comp per station
      logical stat(21)

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm

c     w ... input
c     sx ... output
c     w2 ... local auxil array for shifts


      if(abs(ioptshf).gt.1024) then
	  write(*,*) 'Problem DIM in subevnt15; STOP'
	  STOP
	  endif
	  
	  w2=0.  ! initialize in broad dimensions of w2 as ZEROS  !!!!!
	  
	  do i1=1,1024 ! redefine in 1024 
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
          if(icom.eq.1) ioptshf=ilagx(ir)
		  if(icom.eq.2) ioptshf=ilagy(ir)
	      if(icom.eq.3) ioptshf=ilagz(ir)
			do n=1,nmom
			  sx(itim,ir,icom)=sx(itim,ir,icom) +
     *            aopt(n)*w2(itim-ioptshf,ir,icom,n)

c For ioptshf > 0, e.g. 100 shift to right:
c min(itim-ioptshf) = 1-100, first values  are taken from t<0 where they were necessarily bt initialized as 0 
c max(itim-ioptshf) = ntim-100, last 100  values of original seismo are cut (lost, not used)
c For ioptshf < 0, e.g. -100 shift to left:
c min(itim-ioptshf) = 101, first 100 values of original are cut  (lost), we start from 101  
c max(itim-ioptshf) = ntim+100, last 100 values are taken from time AFTER the end of orignal, wher necessarily must be initialized as 0
c Therefore it is absolutely necessary that w2 values were defined 100 points before and after time window as 0
c Because we need here the zero values 'at t<0' for shift=100 and values 'after time window' for shift=-100
                           	 
            enddo
          enddo
        enddo
      enddo


      RETURN
      END
