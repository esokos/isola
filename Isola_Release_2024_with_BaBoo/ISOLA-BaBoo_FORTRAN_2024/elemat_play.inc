      
	  subroutine elemat_play(filename,w,rold,rinv)
!     use msimsl
	  
c ATTENTION: on output, rold is * 1.e20, rinv is / 1.e20

c   Input: elemse (w) for a fixed point source
c   Output: system matrix, inverted matrix
 
      use mconst
      use numwei
	  use mcov
	  use mcovsparse

	  character*12 filename
	  character*1 transa
	  character*4 matdescra
	  
	  dimension w(NBO,NBS,3,6)    ! output file 
	  dimension rinv(6,6),rold(6,6)
	  dimension g(NMUL1,6), caux(NMUL1,6)
	  
c	  common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
c     *                 ff1(NBS),ff2(NBS),ff3(NBS),ff4(NBS),dt
c      common /WEI/ weig(NBS,3)
c      common /COV/ cdinv(NMUL1,NMUL1)

           

C Alternatives for matrix inversion
       dimension gold(6,6),y(6,6),indx(6) ! for matrix inversion using Num.Rec. 	  


c      integer ipiv(6)  ! for matrix inversion using LAPACK
c      integer,parameter :: lwork=6*64 ! matrix_size*optimal_blocksize
c      real work(lwork)

ccc       open(100,form='unformatted',file=filename) ! for powerstat  (input)
      open(100,form='unformatted',file=filename,access='stream') ! for gfort 
	 
      nnn=ntim

c *******************************************************************
c *********** MANIPULATING ELEMENTARY SEISMOGRAMS (Green's) *********
c *******************************************************************

c
c        READING 6 ELEMENTARY velocity SEISMOGRAMS, a single point source
c      (synth. Green's convolved with SOME time fctn.; see ELEMSE.FOR)
c
c

      do ir=1,nr
        do it=1,6        ! here MUST be 6 (not nmom!) since  6 are calculated !!!!
          do itim=1,ntim   ! pres cas
          read(100) time,
     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
          enddo
        enddo
      enddo

      close(100)


c
c     FILTERING THE ELEM. SEISMO 
c
c
      do ir=1,nr 

	  f1=ff1(ir)  
	  f4=ff4(ir)
      keyfil=0 !(BP=0, LP=1, HP=2)   
      keydis=1 !(vel=0, displ=1)   
      shift=0.   ! always
          do icom=1,3
          do it=1,6 ! here MUST be 6, not nmom
      call filter_play(nnn,keyfil,keydis,f1,f4,dt,w(1,ir,icom,it))
	      enddo
          enddo
     
      enddo ! over stations
 

c ***********************************************************************
c ***********FORMING AND INVERTING SYSTEM MATRIX (from elem seismograms)
c                 former GT G is replaced by GT Cd-1 G
c                 inverse (GT Cd-1 G)-1 is directly cov matrix of param

c cdinv ... Cd-1 ... inversion of data cova matrix (externally supplied)
c g ... matrix of elementary seismograms G, columns refer to elem MTs, m=1....6
c rold ... GT * Cd-1 * G 
c rinv is inversion of rold, which equals Cm = parameters cova matrix
c ***********************************************************************

c Simulated input of Cd-1; later no need to invert Cd all the time as here 
c And also no need to have it different for different trial sources

c       nsz=ntim*nr*3
c       vardat= 25.e-20!  manually !! 25.e-12
c	   cdinv=0.
c	   do i = 1,nsz; cdinv(i,i)=1. / vardat; enddo  !docasne
ccc	   do i = 1,nsz; cdinv(i,i)=1. * vardat; enddo
ccc	   CALL LINRG (nsz, cdinv, NMUL1, cdinv, NMUL1) 



c Redefinition of 'elemse' from array w into 2D array, i.e. matrix G
		
		mt: do n=1,nmom                                    
		jin=0
		  do ir=1,nr ; do icom=1,3 ; do itim=1,ntim ! in this order (MY choice! msut be same in oneinv)
		  jin=jin+1                ! also cova matrix must keep same ordering as data !!!
		  g(jin,n)=w(itim,ir,icom,n) * weig(ir,icom) * 1.e10 ! includes zeroing the non-used stations 
          enddo; enddo; enddo                         ! 1.e10 is a MUST !!!! numeric reasons
        enddo mt                                      ! G ~ w ~ 1e-19, later GTG would be 1.e-38, BAD!  
c        print *, 'jin ', jin	                      ! w * 1.e10 ~ -9, later GTG ~ 1.e-18 is OK  	

	   
c     FORMING SYSTEM MATRIX

      if(keycova.eq.1)  goto 1621  ! go to new version     
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc        'VERY OLD' (without Cd at all)
        rold= matmul(transpose(g),g)   	   

ccc        OLD VERSION for debug only (with Cd, but not sparse, 4 stations only)
cc	       rold=matmul( matmul(transpose(g),cdinv),  g)
        goto 1622 ! skip new version

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	   
cccc         NEW VERSION (sparse)     
c   GT * Cdinv = (CdinvT * G)T
c udelam ted jakoby caux=matmul(transpose(cdinv), g)
c a dodatecne matmul(transpose(caux),g)
c dimense caux bude nekonecno x 6

 1621 continue      
	  nsz=ntim*nr*3 	
      transa= 'T'
      matdescra= 'GLNF'	  
	  call mkl_scsrmm(transa,nsz,6,nsz,1.,matdescra,acsr,ja,
     *	   ia,ia(2),g,NMUL1,0.,caux, NMUL1)
      
c      do i=1,nsz
c      write(1667,'(6e12.5)') (caux(i,j), j=1,6)
c	  enddo	  
      
 	  
      rold=matmul(transpose(caux),g) 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	   

 1622 continue	  
	  rold=rold * dt 
c usually G is of the order of 1e-19
c 	      GT G is ~ 1.e-38, formally multiplied by * 1.e20, as a whole  ~ 1e-18 
c E.g. Cd-1 ~ 1/vardat ~ 1.e+14 thus (Gt Cd-1) G ~ 1.e-4

c 	    do i=1,nmom          ! printing sytem matrix
c        write(897,'(6(1x,e13.6))') (rold(i,j),j=1,nmom)
c 	    enddo
c        write(897,*)	   
	   
c **********************************************************************	   
c	  ! Small (6x6 or 5x5) MATRIX INVERSION; three alternative methods 

cc     Inversion using Num. Recipes
      gold=rold ! to save before using (and destroting)
	  do i=1,nmom
	  do j=1,nmom
	  y(i,j)=0.
	  enddo
	  y(i,i)=1.
	  enddo
      call ludcmp(rold,nmom,6,indx,ddd)     ! indx, ddd = output
      do j=1,nmom                         
	  call lubksb(rold,nmom,6,indx,y(1,j))  !  rold is DESTROYED !!!
	  enddo
      do i=1,nmom
	  do j=1,nmom
 	  rinv(i,j)=y(i,j)
	  enddo
      enddo
	  rold=gold ! restoring from saved array
cc  End of inversion in Num. Recipes


cc      Abandoned inversion using MSIMSL library:
c       CALL LINRG (nmom, rold, 6, rinv, 6) ! rold remains undestroyed     

cc     Abandoned inversion using LAPACK library:
c       rinv=rold ! rold remains undestroyed, inversion is made fully in rinv array 
c       call sgetrf(nmom,nmom,rinv,6,ipiv,info) ! LU decomposition
c       call sgetri(nmom,rinv,6,ipiv,work,lwork,info) ! inversion
c ********************************************************************


c        write(897,*)
c    	do i=1,nmom          ! printing inverse matrix
c        write(897,'(6(1x,e13.6))') (rinv(i,j),j=1,nmom)
c    	enddo
c	    write(897,*)
c         close(897)	   


     
        RETURN
        END
