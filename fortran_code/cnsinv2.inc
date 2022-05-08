      subroutine cnsinv2(x,w,rold,rinv,asave,corr,ish)


c lagra se vola v kazdem bode pro kazddy cas a muze selhat
c pokud selze v nejakem case tak v tom case bude prirazeno reseni s velkym nonDC
c v jjinem case mozna reseni 100%DC
c pak jse o to, ktere znich ma lepsi korelaci
c pokud to nonDC tak se vybere trebaze by se mozna trochu hori kvalita nasla v jinem case jako 100% DC !!!!!!!!
c TOTO JEDINE VADI !!!!!!!!!!!!!!!!!!!!


c Input: single elemse and 'data' (ori or residual)
c Temporal shift of elemse (in loop); finding moment tensor for each step
cfinding correlation for each step
c Output: iseqm number of loop steps
c Output: array: ish(1,... iseqm) = shifts
c Output: array: corr(1,... iseqm) = correlation
c Output: array: asave(1,... iseqm) = moment tensor coefficients

      dimension a(6),g(6),rinv(6,6),rold(6,6)
      dimension x(8192,21,3)
      dimension w(-2500:10692,21,3,6)
      dimension anew(6),dela(6)
      dimension corr(100),ish(100),asave(6,100)
      dimension ntm(21)
      dimension weig(21,3)
      logical stat(21)


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 f1,f2,f3,f4,dt
      common /ST/ stat,ntm
      common /WEI/ weig

	  a(6)=0.

	  if(nmom.ne.5) then
	  write(*,*) 'Constrained inversion needs nmom=5'
	  STOP
	  endif
	  
c
c     COMPUTING 'POWER' OF THE DATA (observed or residual)
c               (used stations only !)

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

      xmom=1.

      delta=rr -    sum1          ! the same (since sum1=sum2)

      psi=sum1 / rr      ! psi = correlation
      psi=sqrt(psi)       ! new


c *******************************************************
c     DC constraint
c *******************************************************

      call lagra(rold,rinv,a,anew)  ! after this calling rold,rinv, are NOT destroyed


                               !  a= old non DC, anew= new DC constrained
      do n=1,nmom
      dela(n)=anew(n)-a(n)
      enddo

c                    ! psi = correlation REcalculated for DC a

      sum3=0.
      do n=1,nmom
      do m=1,nmom
      sum3=sum3 +    ! includes de-scaling of rold
     *     (rold(n,m)/1.e20) * ( a(n)*a(m)-dela(n)*dela(m) )
      enddo
      enddo
      psi=sum3 / rr
      psi=sqrt(psi)   ! new

      do n=1,nmom
      a(n)=anew(n)
      enddo


c *******************************************************
c     DC constrain ended , next  regime the same for non DC or DC
c *******************************************************


      corr(iseq)=psi    ! saving correlation; iseq counts the shifts
      ish(iseq)=ishift

      do n=1,6
      asave(n,iseq)=a(n)*xmom      ! saving  MOMENT COEFFICIENTS
      enddo


   10 continue      ! SHIFT LOOP FINISHED

      RETURN
      END

