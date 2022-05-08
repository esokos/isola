
      subroutine elemat2(filename,w,rold,rinv)

c ATTENTION: on output, rold is * 1.e20, rinv is / 1.e20

c   Input: elem se (w) for a fixed point source
c   Output: system matrix, inverted matrix


      character*12 filename
      dimension w(-2500:10692,21,3,6)
      dimension r(6,6),rinv(6,6),rold(6,6)
c        dimension gold(6,6),en(6),vv(6,6)
      dimension indx(6),y(6,6)
      dimension ntm(21)               ! new
      dimension weig(21,3)            ! new
      logical stat(21)


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 f1,f2,f3,f4,dt
      common /ST/ stat,ntm              ! new
      common /WEI/ weig


      open(100,form='unformatted',file=filename)     ! elementary seismograms from ELEMSE (input)
      open(897,file="maticeGTG.dat")



c *******************************************************************
c *********** MANIPULATING ELEMENTARY SEISMOGRAMS (Green's) *********
c *******************************************************************

c
c        READING 6 ELEMENTARY velocity SEISMOGRAMS, a single point source
c      (synth. Green's convolved with SOME time fctn.; see ELEMSE.FOR)
c
c

      do ir=1,nr
ccc   if(stat(ir)) then  ! readig cannot be conditioned by stat(...
        do it=1,6        ! here MUST be 6 (not nmom!) since  6 are calculated !!!!
          do itim=1,ntim   ! pres cas
c         read(100,'(4(1x,e12.6))') time,
c    *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
          read(100) time,
     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
          enddo
        enddo
ccc   endif       ! reading cannot be condtioned by stat(...
      enddo



c      do ir=3,3          ! output of elemse for plotting
c        do it=1,6        
c          do itim=1,ntim
c          time=float(itim-1)*dt
c          write(8256,'(4(1x,e12.6))') time,
c     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
c          enddo
c          write(8256,*) '*'
c        enddo
c      enddo



      REWIND(100)

c
c     FILTERING THE ELEM. SEISMO
c

      do ir=1,nr
cc    if(stat(ir)) then
        do icom=1,3
          do it=1,6 ! here MUST be 6, not nmom
          call filter(f1,f2,f3,f4,dt, w(1,ir,icom,it) )
          enddo
        enddo
cc    endif
      enddo
 
 
c     do ir=1,nr
c     if(stat(ir)) then
c     ntim2=ntm(ir)
c       do icom=1,3
c         do it=1,6
c           do itim=ntim2,ntim
c           w(itim,ir,icom,it)=0.
c           enddo
c         enddo
c       enddo
c     endif
c     enddo


c ***********************************************************************
c ***********FORMING AND INVERTING SYSTEM MATRIX (from elem seismograms)
c ***********************************************************************


c
c     FORMING SYSTEM MATRIX
c
      do n=1,nmom                                    !n,m mom tensor comp
        do m=1,nmom
        r(n,m)=0.
          do icom=1,3
            do ir=1,nr
            if(stat(ir)) then
              do itim=1,ntim
              wNweig=w(itim,ir,icom,N)*weig(ir,icom)
              wMweig=w(itim,ir,icom,M)*weig(ir,icom)
              r(n,m)=r(n,m)+
     *            wNweig*wMweig*1.e20
ccc  *            w(itim,ir,icom,n)*w(itim,ir,icom,m)*1.e20
c                                                     1.e20 = FORMAL SCALING
c        this formal scaling 1.e20 is essential to prevent some underflow
c        1.e20 is later compensated by the same multiplication of the
c        right-side of the equation
c        Note that matrix and right-hand side are formally multiplied
c             without affecting w, x, ...!!!
              enddo
            endif
            enddo
          enddo
          r(n,m)=r(n,m)*dt
        enddo
      enddo

        write(897,*) "matice GTG"
 	do i=1,nmom          ! printing sytem matrix
        write(897,'(6(1x,e12.6))') (r(i,j),j=1,nmom)
 	enddo
        write(897,*)

 	do i=1,nmom          ! saving r(n,m) before inversion
 	  do j=1,nmom        ! (because after inversion r(n,m) is destroyed !)
 	  rold(i,j)=r(i,j)
c          gold(i,j)=r(i,j)
 	  enddo
 	enddo

c        call JACOBInr(gold,nmom,6,en,vv,nrot)
c        write(*,*) (en(i),i=1,nmom)

c
c     INVERTING THE SYSTEM MATRIX
c

c r(i,j)  matrix inversion (from Numerical Recipes) -> rinv(i,j)

	do i=1,nmom
	do j=1,nmom
	  y(i,j)=0.
	  enddo
	  y(i,i)=1.
	enddo
          nmax=6  !!! dim. of array r
          call ludcmp(r,nmom,nmax,indx,ddd)   ! indx, ddd = output
          do j=1,nmom                    ! former r is DESTROYED !!!
	  call lubksb(r,nmom,nmax,indx,y(1,j))
	  enddo

	do i=1,nmom
	  do j=1,nmom
 	  rinv(i,j)=y(i,j)
	  enddo
	enddo


        write(897,*) "inverzni matice k matici GTG"
	do i=1,nmom          ! printing inverse matrix
       write(897,'(6(1x,e12.6))') (rinv(i,j),j=1,nmom)
	enddo
       write(897,*)
       close(897)


c	do i=1,nmom      ! CHECKING INVERSE, I.E. that rold*rinv= I
c	  do j=1,nmom         ! diagonal = 1; all nondiagonal < e-7
c         y(i,j)=0.
c           do k=1,nmom
c	    y(i,j)=y(i,j)+rold(i,k)*rinv(k,j)
c           enddo
c	  enddo
c	enddo
c       do i=1,nmom
c       write(897,'(6(1x,e10.1))') (y(i,j),j=1,nmom)
c       enddo
c       write(*,*)

c  end of matrix inversion

        RETURN
        END

