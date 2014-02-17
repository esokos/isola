      subroutine oneinv2_vol(afix6,x,w,rold,rinv,asave,corr,ish)

c Input: single elemse and 'data' (ori or residual)
c Temporal shift of elemse (in loop); finding moment tensor for each step
cfinding correlation for each step
c Output: iseqm number of loop steps
c Output: array: ish(1,... iseqm) = shifts
c Output: array: corr(1,... iseqm) = correlation (psi)=1-delta/rr
c Output: array: asave(1,... iseqm) = moment tensor coefficients

      dimension a(6),g(6),rinv(6,6),rold(6,6),g2(6)
      dimension x(8192,21,3)
      dimension w(-2500:10692,21,3,6)
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

      do it=1,5 ! 5= NEW                                  !n moment tensor comp
      g(it)=0.                                            !itim time
        do icom=1,3                                       !icom seismo comp.
          do ir=1,nr                                      !ir station
          if(stat(ir)) then
             do itim=1,ntim
ccccc         xweig=x(itim,ir,icom)*weig(ir,icom) ** 2. ! old

              xweig=x(itim,ir,icom)

     		  xweig2=afix6*w(itim-ishift,ir,icom,6)  


			  xweig=(xweig-xweig2)*weig(ir,icom)**2. !subtracting the prescribed VOL

             g(it)=g(it)+
     *            w(itim-ishift,ir,icom,it)*xweig * 1.e20
c                                                  1.e20 = FORMAL SCALING
c                     (compensating the previous scaling of the system matrix)
c               ! this MINUS ishift in w is equivalent to PLUS in x
             enddo
          endif
          enddo
        enddo
      g(it)=g(it)*dt	  ! this is GT d, where G has only 5 rows, not 6! 
      enddo				  ! thus g=GT d is vector of 5 components only



      do it=1,6 !!!!!  We will however also later need the standard g=GT d with 6comp!!! 
      g2(it)=0.                                            !itim time
        do icom=1,3                                       !icom seismo comp.
          do ir=1,nr                                      !ir station
          if(stat(ir)) then
             do itim=1,ntim
              xweig=x(itim,ir,icom)*weig(ir,icom) ** 2. ! old

c             xweig=x(itim,ir,icom)

c      		  xweig2=afix6*w(itim-ishift,ir,icom,6)

c			  xweig=(xweig-xweig2)*weig(ir,icom)**2.

             g2(it)=g2(it)+
     *            w(itim-ishift,ir,icom,it)*xweig * 1.e20
c                                                  1.e20 = FORMAL SCALING
c                     (compensating the previous scaling of the system matrix)
c               ! this MINUS ishift in w is equivalent to PLUS in x
             enddo
          endif
          enddo
        enddo
      g2(it)=g2(it)*dt	 ! with new notation (g2) this is the usual g for FULL regime
	  enddo				 ! (g2 has 6 rows, 1 column)




c
c     APPLYING INVERSE MATRIX TO THE RIGHT-HAND SIDE (WITHIN SHIFT LOOP)
c

       do n=1,5 !!!5=NEW        !!! since we seek only a1...a5 (a6 is fixed)           ! 
      a(n)=0.                       ! we need nmom=5 in MAIN!!! so that here        
        do m=1,5  !!!5=NEW          ! we correctly use RINV matrix 5x5, not 6x6!!!!       
        a(n)=a(n)+ rinv(n,m)*g(m)   !  pozor rinv musi byt inv matice pro hleani 5 param !!, hledam jen a1..a5                           
        enddo                       !  cile cele nutno spoustet jako devia !!! jiank to NEJDE!!! 
      enddo

c      sum1=0.
c      do n=1,5 ! 5=NEW
c      sum1=sum1 + a(n)*g(n)/1.e20    ! g de-scaled by 1.e20
c      enddo
c   	  a(6)=afix6 ! NEW
cccc	  sum1=sum1 + a(6)*g(6)/1.e20   ! new ale kde vzit g(6)????

      a(6)=afix6					 !for optimizing time in the shift loop
      sum1=0.						 ! we need complete tensor; we use computed a1-a5, and add a6 fixed
      do n=1,6 ! 6=NEW				 ! this parameter vector (6 rows) must be multiplied
      sum1=sum1 + a(n)*g2(n)/1.e20    ! by standard GT d (6 row) vector, i.e. g2!!!!!!
      enddo



      xmom=1.

c     delta=rr - 2.*sum1 + sum2   !
      delta=rr -    sum1          ! the same (since sum1=sum2)

      psi=sum1 / rr	  ! psi = correlation
      psi=sqrt(psi)   ! new
 

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
