      subroutine oneinv_play_NOcova(x,w,rinv,asave,corr,ish)

c Temporal shift of elemse (in loop); finding moment tensor for each step
c finding correlation for each step
c Input: single trial position elemse in 'w' and data (ori or residual) in 'x'
c Input: rinv inverse of the system matrix
c Output: iseqm number of loop steps
c Output: array: ish(1,... iseqm) = shifts
c Output: array: corr(1,... iseqm) = correlation; sqrt(psi)=sqrt(1-delta/rr)
c       where delta=residual L2 misfit, rr= data squared; both with weights
c Output: array: asave(1,... iseqm) = moment tensor coefficients

c !!!!!!!! coming from main, w now inlcudes also zeros before andr after real data
c so that dimension is larger !!!!!!!

      use mconst
      use numwei
	  use mcov
c	  use mcovsparse

	  character*1 transa
	  character*4 matdescra
	  
      dimension x(NBO,NBS,3)
      dimension w(NBO,NBS,3,6)
      dimension a(6),rinv(6,6)
      dimension corr(100),ish(100),asave(6,100)
      dimension gnew(6),g(NMUL1,6),caux(NMUL1,6) 
	  dimension xw(NMUL1)

	  
c      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
c     *                 ff1(NBS),ff2(NBS),ff3(NBS),ff4(NBS),dt
c      common /WEI/ weig(NBS,3)
c      common /COV/ cdinv(NMUL1,NMUL1)


c  	  integer, parameter :: NBS=21 ! NBS = max number of stations
c	  integer, parameter :: NMUL1= 256*NBS*3
c	  include "par_dim_play.inc"

 	  
	  do i=1,6
	  a(i)=0.
	  enddo



c
c     COMPUTING 'POWER' OF THE DATA (observed or residual)
c                  (used stations ONLY ! via weig)

      rr=0.
      do icom=1,3                                       !icom seismo comp.
        do ir=1,nr                                      ! ir =station
           do itim=1,ntim                                   ! itim=time
          xweig=x(itim,ir,icom)*weig(ir,icom)            ! icom seismo comp
          rr=rr+xweig*xweig
          enddo
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




c Redefinition of 'elemse' from array w into 2D array, i.e. matrix
C CAUTION: matrix is newly defined for each shift; matrix as a whole is not shifted
c in its first index, that would be wrong. We correctly shift only in time, see w(itim-ishift...

		mt: do n=1,nmom                                    
		jin=0
		  do ir=1,nr 
		  do icom=1,3 
		  izeros=0

		  do itim=1,ntim ! in this order...
		  jin=jin+1
		  g(jin,n)=0.
		  if(itim-ishift.ge.1.and.itim-ishift.le.ntim) then
		  izeros=1
		  g(jin,n)=w(itim-ishift,ir,icom,n) * weig(ir,icom) * 1.e10 ! includes zeroing the non-used stations 
          endif    ! XXXXXXXXXX we are in loop over 'ishift'
		  enddo
          if(izeros.eq.0) then               ! similar check is missing in other modes
          write(*,*) 'whole seismogram is zero'
		  write(*,*) 'check time shifts; STP ! '
		  STOP
		  endif
		  
		  enddo
		  enddo 
        enddo mt	
c matrix G for a particular shift
		
c Redefinition of data vector (incl. wights)
        jin=0
		  do ir=1,nr ; do icom=1,3 ; do itim=1,ntim ! in this order...
		  jin=jin+1
		  xw(jin)=x(itim,ir,icom) * weig(ir,icom) * 1.e10 ! includes zeroing the non-used stations 
          enddo; enddo; enddo 
! data vector d  

c
c     FORMING RIGHT-HAND SIDE OF THE SYSTEM (dependent on the SHIFT)
c     Gt d comes multiplied by 1.e20
		
c      if(keycova.eq.1) goto 1621 ! goto new version		
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc      'VERY OLD ' = without Cd
        gnew=matmul(transpose(g),xw)  ! gnew is * 1.e20 

ccc         OLD VERSION	 for debug only (with Cd, but not sparse, 4 stations only)  
cc        gnew=matmul( matmul(transpose(g),cdinv), xw)  ! gnew is * 1.e20
        goto 1622 !skip new version

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	   
cccc         NEW VERSION (sparse)     
c   GT * Cdinv = (CdinvT * G)T
c udelam ted jakoby caux=matmul(transpose(cdinv), g)
c a dodatecne matmul(transpose(caux),xw)
c dimense caux bude nekonecno x 6

c 1621 continue      
c	  nsz=ntim*nr*3 	
c      transa= 'T'
c      matdescra= 'GLNF'	  
c
c	  call mkl_scsrmm(transa,nsz,6,nsz,1.,matdescra,acsr,ja,
c     *	   ia,ia(2),g,NMUL1 ,0.,caux, NMUL1)	 
c
c      gnew=matmul(transpose(caux),xw) 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	   

 1622   continue	  
		gnew=gnew * dt !	    
	  
c	    write(896,*) 'gnew:'
c	    write(896,*) gnew
	  
	  
c
c     APPLYING INVERSE MATRIX TO THE RIGHT-HAND SIDE (WITHIN SHIFT LOOP)
c        CAUTION denotation: now not using 'g' but 'gnew' [g is reserved for G]
c rinv is /1.e20, gnew is *1e20, so it cancels and a' are free of any scaling
c for purely diagonal Cd, a's are independent of Cd (of vardat)

      do n=1,nmom                   
      a(n)=0.                       
        do m=1,nmom                 
        a(n)=a(n)+ rinv(n,m)*gnew(m)   
        enddo                       
      enddo

	  
c Computing correlation; here (in 'g')  do we need  Gt Cd-1 d in 'g' or only  Gt d ???
c ONLY Gt d !! ale to ted momentalne nemam a nechci delat nove pole

      ! matrix g and xw still unchanged, can be used again             NEW PART
      ! the idea is that here GT Cdinv should NOT be used, only GT 
      ! why we calculate sum1 (and sum1/rr as correlation):
      ! let us denote a's as m; then here we do mt Gt d	which is G m d, scalar product
      ! of synthtics (G m) with real data (d)
      ! alternatively Choleski decom can be applied here
	  
ccc	  gnew=matmul( matmul(transpose(g),cdinv), xw)     !!!  Not !!
	  gnew=matmul( transpose(g), xw)     !!!! gnew = Gt d is redefined for sum1 without Cd-1
	  gnew=gnew * dt      ! ~ G~1e-18 *1e10 ~ 1.e-8, x~1e-6 *1e10 , gnew ~ 1.e-4              
	  
	  sum1=0.
      do n=1,nmom
      sum1=sum1 + a(n)*gnew(n)/1.e20    ! g de-scaled by 1.e20, hence sum1 free of scaling
      enddo

      xmom=1.
      psi=sum1 / rr	  ! psi = correlation
	  if(psi.lt.0) then			  !!!!! new July 5, 2014
	  psi=0.
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


 10   continue      ! SHIFT LOOP FINISHED

      RETURN
      END
