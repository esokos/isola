      subroutine oneinv15(x,w,rold,rinv,asave,corr,ish)

c Input: single elemse and 'data' (ori or residual)
c Temporal shift of elemse (in loop); finding moment tensor for each step
cfinding correlation for each step
c Output: iseqm number of loop steps
c Output: array: ish(1,... iseqm) = shifts
c Output: array: corr(1,... iseqm) = correlation; sqrt(psi)=sqrt(1-delta/rr)
c delta=residual L2 misfit, rr= data squared; both with weights
c Output: array: asave(1,... iseqm) = moment tensor coefficients

      dimension a(6),g(6),rinv(6,6),rold(6,6)
      dimension x(8192,21,3)
      dimension w(-3500:11692,21,3,6)
      dimension corr(100),ish(100),asave(6,100)
      dimension ntm(21)
      dimension weig(21,3)
      logical stat(21)


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm
      common /WEI/ weig

	  do i=1,6
	  a(i)=0.
	  enddo

c
c     COMPUTING 'POWER' OF THE DATA (observed or residual)
c                  (used stations ONLY !)

      rr=0.
      do icom=1,3                                       !icom seismo comp.
        do ir=1,nr                                      ! ir =station
        if(stat(ir)) then
          do itim=1,ntim                                   ! itim=time
          xweig=x(itim,ir,icom)*weig(ir,icom)            ! icom seismo comp
          rr=rr+xweig*xweig
          enddo
        endif
        enddo
      enddo
      rr=rr*dt



C *********************************************************************
C ********NON-LINEAR PART; THE SHIFT LOOP = GRID SEARCH OVER SHIFT ****
C *********************************************************************

c
c     STARTING  LOOP on SHIFT
c       (time shift = ishift*dt; shift > 0 ... to the RIGHT)

      iseqm=(ilast-ifirst) / istep
      ishift=ifirst

      do 10 iseq=1,iseqm
      ishift=ishift+istep  ! value of the shift

c
c     FORMING RIGHT-HAND SIDE OF THE SYSTEM (dependent on the SHIFT)
c


      do it=1,nmom                                        !n moment tensor comp
      g(it)=0.                                            !it time
        do icom=1,3                                       !icom seismo comp.
          do ir=1,nr                                      !ir station
          if(stat(ir)) then
             do itim=1,ntim
             xweig=x(itim,ir,icom)*weig(ir,icom) ** 2.
             g(it)=g(it)+
     *            w(itim-ishift,ir,icom,it)*xweig * 1.e20
c                                                  1.e20 = FORMAL SCALING
c                     (compensating the previous scaling of the system matrix)
c               ! this MINUS ishift in w is equivalent to PLUS in x
             enddo
          endif
          enddo
        enddo
      g(it)=g(it)*dt
      enddo

c	    write(897,*) 'gnew:'
c	    write(897,*) g


c
c     APPLYING INVERSE MATRIX TO THE RIGHT-HAND SIDE (WITHIN SHIFT LOOP)
c


      do n=1,nmom                   ! you MUST disable this part  !
      a(n)=0.                       !                             !
        do m=1,nmom                 !      C A U T I O N          !
        a(n)=a(n)+ rinv(n,m)*g(m)   !                             !
        enddo                       ! when foc mech is prescribed !
      enddo

      sum1=0.
      do n=1,nmom
      sum1=sum1 + a(n)*g(n)/1.e20    ! g de-scaled by 1.e20
      enddo

c  	    write(897,*) 'a:'
c	    write(897,*) a

	  
c      sum2=0.
c      do n=1,nmom
c      do m=1,nmom
c      sum2=sum2 + rold(n,m)*a(n)*a(m)/1.e20  ! rold de-scaled
c      enddo
c      enddo
c      write(567,*) 'sum1,sum2=',sum1,sum2

      xmom=1.

c     delta=rr - 2.*sum1 + sum2   !
c      delta=rr -    sum1          ! the same (since sum1=sum2)

      psi=sum1 / rr	  ! psi = correlation


	  if(psi.lt.0) then			  !!!!! new July 5, 2014
	  psi=0.
ccc	  xmom=-1.*xmom
	  else
	  psi=sqrt(psi)   ! new
      endif


c *******************************************************
c      no DC constraint here (it is only in cnsinv)
c *******************************************************


      corr(iseq)=psi    ! saving correlation; iseq counts the shifts
      ish(iseq)=ishift

      do n=1,6        ! here it must be 6, not nmom
      asave(n,iseq)=a(n)*xmom      ! saving  MOMENT COEFFICIENTS
      enddo


   10 continue      ! SHIFT LOOP FINISHED

      RETURN
      END
