      subroutine oneinv2(x,w,rold,rinv,asave,corr,ish)

c Input: single elemse and 'data' (ori or residual)
c Temporal shift of elemse (in loop); finding moment tensor for each step
cfinding correlation for each step
c Output: iseqm number of loop steps
c Output: array: ish(1,... iseqm) = shifts
c Output: array: corr(1,... iseqm) = correlation (psi)=1-delta/rr
c Output: array: asave(1,... iseqm) = moment tensor coefficients

      dimension a(6),g(6),rinv(6,6),rold(6,6)
      dimension x(8192,21,3)
      dimension w(-2500:10692,21,3,6)
c     dimension anew(6),dela(6)
      dimension corr(100),ish(100),asave(6,100)
      dimension ntm(21)
      dimension weig(21,3)
      logical stat(21)


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 f1,f2,f3,f4,dt
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
ccc       rr=rr+x(itim,ir,icom)*x(itim,ir,icom)            ! icom seismo comp
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
ccc          g(it)=g(it)+
ccc  *            w(itim-ishift,ir,icom,it)*x(itim,ir,icom) * 1.e20
c                                                  1.e20 = FORMAL SCALING
c                     (compensating the previous scaling of the system matrix)
c               ! this MINUS ishift in w is equivalent to PLUS in x
c               ! this MINUS ishift=10 in w is means +10*dt in x, to the RIGHT
             enddo
          endif
          enddo
        enddo
      g(it)=g(it)*dt
      enddo


c
c     APPLYING INVERSE MATRIX TO THE RIGHT-HAND SIDE (WITHIN SHIFT LOOP)
c


      do n=1,nmom                   ! you MUST disable this part  !
      a(n)=0.                       !                             !
        do m=1,nmom                 !      C A U T I O N          !
        a(n)=a(n)+ rinv(n,m)*g(m)   !                             !
        enddo                       ! when foc mech is prescribed !
      enddo

c     do n=1,nmom
c     write(*,*) a(n)    ! checked ok scale; no problem with 1.e20
c     enddo


c     do n=1,nmom   !! CHECKING a BY BACK-SUBSTITUTION  in the left-hand  side
c     g2(n)=0.
c       do m=1,nmom
c       g2(n)=g2(n) + rold(n,m)*a(m)
c       enddo
c     write(*,*) 'left and right side:',g(n),g2(n)  ! g(n) = (approx) g2(n)
c     enddo

c
c     COMPUTING L2 MISFIT (INDIRECTLY) AND CORRELATION (WITHIN SHIFT LOOP)
c               i.e. only for a given subevent

c        delta = rr - 2.* g(n)a(n) + r(n,m)a(n)a(m) = rr - g(n)a(n)
c        delta = rr - 2.*   sum1   +      sum2      = rr -   sum1
c                                              this =
c                                 follows from fact that a(n) minimizes delta
c                                 in the LSQ sense
c                                 (i.e. sum2=sum1; numerically checked below)
c
c        we call this delta as 'indirect' L2 misfit calculation opposed to
c        error2, the 'direct' one, which is suma (integral ( obs-syn)**2))
c                           indirect=direct, numerical check below

      sum1=0.
      do n=1,nmom
      sum1=sum1 + a(n)*g(n)/1.e20    ! g de-scaled by 1.e20
      enddo

c     sum2=0.
c     do n=1,nmom
c     do m=1,nmom
c     sum2=sum2 + rold(n,m)*a(n)*a(m)/1.e20  ! rold de-scaled
c     enddo
c     enddo

c     write(*,*) 'sum1,sum2:',sum1,sum2

      xmom=1.

c                   ccccccccccccccc    C A U T I O N  ccccccccccccccc

c     xmom=sum1/sum2                 ! you MUST disable this part
c     write(*,*) 'moment:',xmom      !
c     sum1=xmom*sum1   ?not checked  !when foc mech is not prescribed
c     sum2=xmom*xmom*sum2    ???

c                   **************************************************



c    delta (=indirect L2 misfit) =  error2 (direct), see check later

c     delta=rr - 2.*sum1 + sum2   !
      delta=rr -    sum1          ! the same (since sum1=sum2)


c                   ! psi = correlation
      psi=sum1 / rr
      psi=sqrt(psi)   ! new
 
c     write(673,*) 'ishift,delta,psi=',ishift,delta,psi


c *******************************************************
c      no DC constraint here (it is only in cnsinv)
c *******************************************************


      corr(iseq)=psi    ! saving correlation; iseq counts the shifts
      ish(iseq)=ishift

      do n=1,6        ! here it must be 6, not nmom
      asave(n,iseq)=a(n)*xmom      ! saving  MOMENT COEFFICIENTS
      enddo
c     xmsave(iseq)=xmom            ! for case of FIXED mech only !!!


   10 continue      ! SHIFT LOOP FINISHED

      RETURN
      END

