      subroutine cnsinv_play(x,w,rinv,asave,corr,ish)
c      use msimsl

c lagra se vola v kazdem bode pro kazddy cas a muze selhat
c pokud selze v nejakem case tak v tom case bude prirazeno reseni s velkym nonDC
c v jjinem case mozna reseni 100%DC
c pak jde o to, ktere znich ma lepsi korelaci
c pokud to nonDC tak se vybere trebaze by se mozna trochu horsi kvalita nasla v jinem case jako 100% DC !!!!!!!!
c TOTO JEDINE VADI !!!!!!!!!!!!!!!!!!!!


c Input: single elemse and 'data' (ori or residual)
c Temporal shift of elemse (in loop); finding moment tensor for each step
cfinding correlation for each step
c Output: iseqm number of loop steps
c Output: array: ish(1,... iseqm) = shifts
c Output: array: corr(1,... iseqm) = correlation
c Output: array: asave(1,... iseqm) = moment tensor coefficients

c  	  integer, parameter :: NBS=21 ! NBS = max number of stations
c	  integer, parameter :: NMUL1= 256*NBS*3
c	  include "par_dim_play.inc"

      use mconst
      use numwei
	  use mcov
	  use mcovsparse
	  
	  character*1 transa
	  character*4 matdescra 
	  
	  dimension x(NBO,NBS,3)
      dimension w(NBO,NBS,3,6)
	  dimension a(6),rinv(6,6)
      dimension anew(6),dela(6)
      dimension corr(100),ish(100),asave(6,100)
	  dimension gnew(6),g(NMUL1,6),caux(NMUL1,6)
	  dimension xw(NMUL1)
      dimension rinv2(6,6),rold2(6,6)
      dimension a22(6),dela22(6)

c     common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
c     *                 ff1(NBS),ff2(NBS),ff3(NBS),ff4(NBS),dt
c      common /WEI/ weig(NBS,3)
c      common /COV/ cdinv(NMUL1,NMUL1)
	  
C Alternatives for matrix inversion
       dimension gold2(6,6),y(6,6),indx(6) ! for matrix inversion using Num.Rec. 	  

       integer ipiv(6) ! for matrix inversion using LAPACK
       integer,parameter :: lwork=6*64 ! matrix_size*optimal_blocksize
       real work(lwork)


c	  a(6)=0.
	  do i=1,6
	  a(i)=0.
	  enddo	  

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
          do itim=1,ntim                                   ! itim=time
          xweig=x(itim,ir,icom)*weig(ir,icom)            ! icom seismo comp
          rr=rr+xweig*xweig
          enddo
        enddo
      enddo
      rr=rr*dt
	  write(661,*) 'rr line 75', rr



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
		  do ir=1,nr ; do icom=1,3 ; do itim=1,ntim ! in this order...
		  jin=jin+1

  		  g(jin,n)=0.
		  if(itim-ishift.ge.1.and.itim-ishift.le.ntim) then
		  g(jin,n)=w(itim-ishift,ir,icom,n) * weig(ir,icom) * 1.e10 ! includes zeroing the non-used stations 
          endif
c                    XXXXXXXXXX we are in loop over 'ishift'          
		  enddo; enddo; enddo 
        enddo mt	
! matrix G (for each shift we have different matrix g)
		
c Redefinition of data vector (incl. wights)
        jin=0
		  do ir=1,nr ; do icom=1,3 ; do itim=1,ntim ! in this order...
		  jin=jin+1
		  xw(jin)=x(itim,ir,icom) * weig(ir,icom) * 1.e10 ! includes zeroing the non-used stations 
          enddo; enddo; enddo 
! data vector d

c
c     FORMING RIGHT-HAND SIDE OF THE SYSTEM (dependent on the SHIFT)
c

      if(keycova.eq.1) goto 1621	! go to new version (sparse)	  
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc      VERY OLD, without Cd
	     gnew=matmul(transpose(g),xw)  ! it means that all gnew is * 1.e20	   

ccc         OLD VERSION for debug only, with Cd but not sparse, 4 stations only	   
c	   gnew=matmul( matmul(transpose(g),cdinv), xw)  ! it means that all gnew is * 1.e20
		 goto 1622
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	   
c         NEW VERSION (sparse)     
c   GT * Cdinv = (CdinvT * G)T
c udelam ted jakoby caux=matmul(transpose(cdinv), g)
c a dodatecne matmul(transpose(caux),xw)
c dimense caux bude nekonecno x 6

 1621 continue      
	  nsz=ntim*nr*3 	
      transa= 'T'
      matdescra= 'GLNF'	  
	  call mkl_scsrmm(transa,nsz,6,nsz,1.,matdescra,acsr,ja,
     *	   ia,ia(2),g, NMUL1,0.,caux, NMUL1)	 

      gnew=matmul(transpose(caux),xw) 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	   

 1622   continue	  
		gnew=gnew * dt !	    
	  
c	    write(896,*) 'gnew:'
c	    write(896,*) gnew
	  
	  
	  
c
c     APPLYING INVERSE MATRIX TO THE RIGHT-HAND SIDE (WITHIN SHIFT LOOP)
c        CAUTION denotation: now not using 'g' but 'gnew' [g is reserved for G]
c rinv is /1.e20, gnew is *1e20, so it cancels and a' are free of any scaling
c for a purely diagonal Cd, a's are independent of Cd 

      do n=1,nmom                   
      a(n)=0.                       
        do m=1,nmom                 
        a(n)=a(n)+ rinv(n,m)*gnew(m) 
        enddo                       
      enddo

        write(661,*) 'a'	   
        write(661,*) (a(j), j=1,nmom)	   
        write(661,*)	   

	  
c Computing correlation; here (in 'g')  do we need  Gt Cd-1 d in 'g' or only  Gt d ???
c ONLY Gt d !! ale to ted momentalne nemam a nechci delat nove pole

      ! matrix g and xw still unchanged, can be used again             NEW PART
      ! the idea is that here GT Cdinv should NOT be used, only GT 
      ! why we calculate sum1 (and sum1/rr as correlation):
      ! let us denote a's as m; then here we do mt Gt d	which is G m d, scalar product
      ! of synthtics (G m) with real data (d)
      ! alternatively Choleski decom can be applied here

c &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&	  
c I think that all this part up to &&& here (and also in standard cnsinv) is not needed	  
c  except the statement xmom=1.

ccc	  gnew=matmul( matmul(transpose(g),cdinv), xw)     !!!  Ne !!
	  gnew=matmul( transpose(g), xw)     !!!!!!!!! gnew is redefined for sum1 
	  gnew=gnew * dt                     
c	  
       sum1=0.
       do n=1,nmom
       sum1=sum1 + a(n)*gnew(n)/1.e20    ! g de-scaled by 1.e20, hence sum1 free of scaling
       enddo
c
       xmom=1.
	   
      psi=sum1 / rr	  ! psi = correlation
	  if(psi.lt.0) then			  
	  psi=0.
	  else
	  psi=sqrt(psi)   ! new
      endif
c &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&



c *******************************************************
c     DC CONSTRAINT using code LAGRA (lagra requests DC% > 90, can be increased if needed)


c     for this part we substitute rold for  rold2,  to be without Cd-1

	    rold2=matmul( transpose(g), g) ! NEW this is pure Gt G (not rold, which contains Cd-1)
        rold2=rold2 * dt 


c **********************************************************************	   
c	  ! Small (6x6 or 5x5) MATRIX INVERSION; three alternative methods 
cc       goto 1000
cc     Inversion using Num. Recipes
      gold2=rold2 ! to save before using (and destroting)
	  do i=1,nmom
	  do j=1,nmom
	  y(i,j)=0.
	  enddo
	  y(i,i)=1.
	  enddo
      call ludcmp(rold2,nmom,6,indx,ddd)     ! indx, ddd = output
      do j=1,nmom                         
	  call lubksb(rold2,nmom,6,indx,y(1,j))  !  rold is DESTROYED !!!
	  enddo
      do i=1,nmom
	  do j=1,nmom
 	  rinv2(i,j)=y(i,j)
	  enddo
      enddo
	  rold2=gold2 ! restoring from saved array
        
		write(661,*) 'rold2'
        do i=1,nmom          ! printing sytem matrix
        write(661,'(6(1x,e13.6))') (rold2(i,j),j=1,nmom)
 	    enddo

cc  End of inversion in Num. Recipes

cc 1000 continue
cc      Abandoned inversion using MSIMSL library:
c       CALL LINRG (nmom, rold2, 6, rinv2, 6) ! rold2 remains undestroyed     

cc 1000 continue
cc     Abandoned inversion using LAPACK library:
c       rinv2=rold2 ! rold remains undestroyed, inversion is made fully in rinv array 
c       call sgetrf(nmom,nmom,rinv2,6,ipiv,info) ! LU decomposition
c       call sgetri(nmom,rinv2,6,ipiv,work,lwork,info) ! inversion
c ********************************************************************

        write(661,*) 
		write(661,*) 'rinv'
        do i=1,nmom          ! printing sytem matrix
        write(661,'(6(1x,e13.6))') (rinv(i,j),j=1,nmom)
 	    enddo
        write(661,*) 
		write(661,*) 'rinv2'
		do i=1,nmom          ! printing sytem matrix
        write(661,'(6(1x,e13.6))') (rinv2(i,j),j=1,nmom)
 	    enddo


c *******************************************************

c      call lagra(rold,rinv,a,anew)  ! after this calling rold,rinv, are NOT destroyed
       call lagra(rold2,rinv2,a,anew)  ! after this calling rold,rinv, are NOT destroyed
c zda se ze muze byt i rinv misto rinv2 ???? opravdu ????; asi jen kdyz je matice const-diag.
c protoze se uvnitr lagra t amatice normuje 
        
        write(661,*) 'a'	   
        write(661,*) (a(j), j=1,nmom)	   
        write(661,*)	   
        write(661,*) 'anew'	   
        write(661,*) (anew(j), j=1,nmom)	   
        write(661,*)	   


                               !  a= old non DC, anew= new DC constrained
      do n=1,nmom
      dela(n)=anew(n)-a(n)
      enddo
      write(661,*) 'dela', dela
      write(661,*) 'rold2', rold2
	  write(661,*) 'rr', rr
c                     psi = correlation REcalculated for DC a

	  a22=a/1.e10;dela22=dela/1.e10      ! new artif scaling to prevent overflow


      sum3=0.
      do n=1,nmom
      do m=1,nmom
ccc      sum3=sum3 +    ! includes de-scaling of rold
ccc     *     (rold2(n,m)/1.e20) * ( a(n)*a(m)-dela(n)*dela(m) )
      sum3=sum3 +    ! de-scaling cannot occur here, numeric reasons < e-38
     *     (rold2(n,m)) * ( a22(n)*a22(m)-dela22(n)*dela22(m) )
c     *     (rold2(n,m)) * ( a(n)*a(m)-dela(n)*dela(m) )
	  enddo
      enddo
c                                   rold2 was scaled by e20, must be descaled          
c      psi=sum3 / 1.e20 /rr *1.e20 ! divide e20 for rold2, multiply for a2, dela2
       psi = sum3 / rr

	  if(psi.lt.0) then			  !!!!! new July 5, 2014
	  psi=0.
c	  xmom=-1.*xmom        ! asi nema byt
	  else
	  psi=sqrt(psi)  
      endif

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

