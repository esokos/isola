      subroutine oneinv2_vol(afix6,x,w,rold,rinv,asave,corr,ish)

c Input: single elemse and 'data' (ori or residual)
c Temporal shift of elemse (in loop); finding moment tensor for each step
cfinding correlation for each step
c Output: iseqm number of loop steps
c Output: array: ish(1,... iseqm) = shifts
c Output: array: corr(1,... iseqm) = correlation (psi)=1-delta/rr
c Output: array: asave(1,... iseqm) = moment tensor coefficients

      dimension a(6),g(6),rinv(6,6),rold(6,6),rold2(6,6),g2(6)
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


c
c     FORMING SYSTEM MATRIX 6x6 (matrix 5x5 comes in parameters)
c
      do n=1,6                                    !n,m mom tensor comp
        do m=1,6
        rold2(n,m)=0.
          do icom=1,3
            do ir=1,nr
            if(stat(ir)) then
              do itim=1,ntim
              wNweig=w(itim,ir,icom,N)*weig(ir,icom)
              wMweig=w(itim,ir,icom,M)*weig(ir,icom)
              rold2(n,m)=rold2(n,m)+
     *            wNweig*wMweig*1.e20
              enddo
            endif
            enddo
          enddo
          rold2(n,m)=rold2(n,m)*dt
        enddo
      enddo

c    	do i=1,6          ! printing sytem matrix
c        write(8997,'(6(1x,e12.6))') (rold2(i,j),j=1,6)
c 	    enddo



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
c     COMPUTING 'POWER' OF THE DATA minus volume 
c                  (used stations ONLY !)

      rrprime=0.
      do icom=1,3                                       !icom seismo comp.
        do ir=1,nr                                      ! ir =station
        if(stat(ir)) then
          do itim=1,ntim                                   ! itim=time

       xweig=
     * (x(itim,ir,icom) - afix6*w(itim-ishift,ir,icom,6)) *weig(ir,icom)  
       rrprime=rrprime+xweig*xweig
          enddo
        endif
        enddo
      enddo
      rrprime=rrprime*dt


c
c     FORMING RIGHT-HAND SIDE OF THE SYSTEM (dependent on the SHIFT)
c          (after subtracting volume; only 5 moment components) 

 
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

ccc posouzeni shody jen po odecteni vol (modelovana fce se meni)
cc      sum1=0.
cc     do n=1,5 ! 5=NEW
cc      sum1=sum1 + a(n)*g(n)/1.e20    ! g de-scaled by 1.e20
cc      enddo


      a(6)=afix6					 !for optimizing time in the shift loop
      sum1=0.						 ! we need complete tensor; we use computed a1-a5, and add a6 fixed
      do n=1,6 ! 6=NEW				 ! this parameter vector (6 rows) must be multiplied
      sum1=sum1 + a(n)*g2(n)/1.e20    ! by standard GT d (6 row) vector, i.e. g2!!!!!!
      enddo


      sum2=0.
      do n=1,6 ! nmom
      do m=1,6 ! nmom
      sum2=sum2 + rold2(n,m)*a(n)*a(m)/1.e20  ! rold de-scaled
      enddo
      enddo

c      write(888,*) sum1, sum2  ! test ze sum1=sum2





      xmom=1.

c     delta = rr - 2.* g(n)a(n) + r(n,m)a(n)a(m) = rr - g(n)a(n)
c     delta = rr - 2.*   sum1   +      sum2      = rr -   sum1

c     delta=rr - 2.*sum1 + sum2   !
c     delta=rr -    sum1          ! the same (since sum1=sum2)


cc uplne puvodni
c      psi=sum1 / rr	  ! psi = correlation
cc pro posouzeni shody po odecteni vol
c       psi=sum1 / rrprime
cc pro posoueni shody celkovych puvodnich dat modelovanych pomoci sesti param, kde a6 byl fixni
cc tedy kde nelze predpokladat ze sum1=sum2
        psi=(sum1*sum1)/(rr*sum2)



c      write(888,*) psi
c      if(psi.ge.1.) psi=0.
      psi=sqrt(psi)   ! new
 

c *******************************************************
c      no DC constraint here (it is only in cnsinv)
c *******************************************************


      corr(iseq)=psi    ! saving correlation; iseq counts the shifts
      ish(iseq)=ishift

      a(6)=afix6					 
      do n=1,6        ! here it must be 6, not nmom
      asave(n,iseq)=a(n)*xmom      ! saving  MOMENT COEFFICIENTS
      enddo


   10 continue      ! SHIFT LOOP FINISHED

      RETURN
      END
