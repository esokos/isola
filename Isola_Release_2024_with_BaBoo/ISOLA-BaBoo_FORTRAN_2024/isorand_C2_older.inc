      subroutine isorand_C2(ipert,isour1,ishf1,keywrite)

c Inversion for MT at one source of fixed position isour1 and time ishf1

c Creating system matrix GtG from /ELEMS/, weights from /WEI/ are applied here
c Using data column d from /OBSD/ ; weights /WEI/ are applied here
c Inverting GtG and calculating the LSQ solution m= (GtG)-1 Gt d


c Calling subroutines: subevnt22, ludcmp, lubksb, silsub


c      parameter (nhdat=21*3*1024+1) ! max length of data column (1 = for moment) 
      parameter (nhdat=21*3*1024) ! max length of data column (1 = for moment) 
      parameter (nhsrc=6) ! 1 source  , 6 acek (MT elem mechanisms)
      dimension isrc(1),ibase(1)     ! ONE sources
      dimension aopt1(6)
      dimension  ori(1024,21,3) !1024 time steps, 21 stats, 3 comp
      dimension   sx(1024,21,3)
      dimension finr(1024,21,3)		 ! 21 = max number of stations
      dimension ntm(21)
      dimension nuse(21),weig(21,3),weigorig(21,3)
      dimension e(1024,21,3,6,99)    ! 99 = max trial sources 
      dimension ama(nhdat,nhsrc),bve(nhdat)
      dimension bvesave(nhdat)
      dimension rinv(6,6),rold(6,6) ! (GtG)-1, GtG
      dimension gnew(6) 	        !  Gtd
      dimension gold(6,6),y(6,6),indx(6) ! for matrix inversion using Num.Rec.      

      logical stat(21)   
      CHARACTER *5 statname(21)
c	  character *17 statfil1,statfil2           
      character *17 statfil3  

 
       common /NNLS/ nshf,keymomcns,xmomreq12,ngrid
       common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt

      common /ST/ stat,ntm,statname
      common /WEI/ nuse,weig,weigorig	   

      common /OBSD/ ori,rrori,bvesave,numdat,bvecnst
                    	  
      common /ELEMS/ e	  
      common /VAR/ vardat 

c      write(*,*) 'This is isorand_C2'
c      write(*,*) (nuse(i),i=1,nr)
c       write(*,*) nuse
      
       nmom4= 1*nmom
       NTR=nmom4   


! *******************************************************************
! **** four a GIVEN TRIAL SOURCE isour1 (and its shift)  ***
! *******************************************************************


c  trial position and shift
      isrc(1)=isour1 ! from parameter of this subroutine (= trial source position)
      ibase(1)=ishf1 ! source time shift (relative to origin time) 
	  

! *******************************************************************
! ****************     FORMING  MATRIX   G   of elem. seis.  ********
c             dependent on the source position and shift
! *******************************************************************


c CAUTION keep same order of the loops as in  isorand_B when forming data column 'bve'
c i.e. is, im, ir,icom,itim (and use ALL ststaions even if unused)

      do is=1,1   	    ! ONE source
      do im=1,nmom          ! new nmom !!! not 6 elem mechanism    
       it=(is-1)*nmom + im ! it ...counting column (1,...NTR)
	   j=0	            ! j .. counting rows 		  
      do ir=1,nr        ! not checking if station is used or not  !!!(all controlled by weights)!!        
      do icom=1,3
      do itim=1,ntim
       j=j+1

      itimnew= itim - ibase(is)   
      if(itimnew.ge.1.and.itimnew.le.ntim) then 	  
      ama(j,it)=e(itimnew,ir,icom,im,isrc(is)) * weig(ir,icom)* 1.e10	
      else
	  ama(j,it)=0. ! The 'if' creates possibly zeros! !important!!  TO BE CHECKED MORE ??????????
      endif

       enddo; enddo; enddo; enddo; enddo


c########## the last row of the matrix (= the moment constraint) #########################
 
c      if(keymomcns.eq.1) then
c      j=j+1
c      do ism=1, NTR ! over  columns
c   	  ama(j,ism)=(1./ xmomreq12) * bvecnst * 1.e10  
c      enddo      
c      endif

	  
c  Printing matrix    
c	  do j=1,numdat
c	  write(555,'(12(1x,e12.5))') (ama(j,n),n=1,NTR)
c	  enddo




! *******************************************************************
! ***FORMING DATA COLUMN     with weighting here ********************
! *******************************************************************
c CAUTION keep same order of the loops as in  isorand_C when forming matrix 
c i.e. ir,icom,itim (and use ALL ststaions even if unused)

       j=0
       do ir=1,nr          
       do icom=1,3
       do itim=1,ntim   
       j=j+1
 	   bvesave(j)= ori(itim,ir,icom)	* weig(ir,icom) * 1.e10		
       enddo
       enddo
       enddo
       numdat=j

       bve=bvesave ! data vector saved !!NEW 


c       write(*,*)'maximum of data column',bvemax
c       write(*,*)'last row of data and numdat ',bvesave(numdat),numdat
      
c      if(keymomcns.eq.1) then
c	   bvecnst= bvemax * 0.01 ! default (found experimentally) = 0.01 or 0.001... (not 1.e4 as in NNLS code; see discussion in isorand_C)
c       j=j+1			  !      
c       bvesave(j)=bvecnst * 1.e10 ! also added row has the same normalization 1e10 as all rows above
c      endif
c       numdat=j

c       write(*,*)'numdat:',numdat
c       write(*,*) 'all data multiplied by 1e10'
c       write(*,*)'keymomcns:',keymomcns
c       write(*,*)'maximum of data column',bvemax
c       write(*,*)'added row of data and numdat',bvesave(numdat),numdat

c Printing data column
c      do j=1,numdat
c      write(444,'(6(1x,e12.6))') bvesave(j)
c      enddo


c  ********************************************************************
c     COMPUTING 'POWER' OF THE  DATA,  with weighting here  
c  ********************************************************************
 

      rr=0.
        do ir=1,nr                                     
         do icom=1,3 
          do itim=1,ntim  
           rr=rr+ (ori(itim,ir,icom)*weig(ir,icom))**2  ! not to be multiplied by 1.e10
          enddo
        enddo
      enddo
      rr=rr*dt
	  rrori2=rr


! *******************************************************************
c     FORMING Gt d (dependent on the SHIFT)  array gnew
!         Gt d is effectively multiplied by * 1.e20
! *******************************************************************
c     Gt d  
c     Without COVA
          gnew=matmul(transpose(ama), bve)  ! Gt d is effectively multiplied by * 1.e20
c       write(*,*) 'ahoj3'
 
! *******************************************************************
! **** Forming (Gt G)              array rold                    ****
!         Gt G is effectively multiplied by * 1.e20 
! *******************************************************************
c       Gt G
        rold= matmul(transpose(ama),ama)  ! Gt G is effectively multiplied by * 1.e20 	   


! *******************************************************************
! **** Computing matrix inversion (Gt G)-1      aray rinv        ****
!         (GtG)-1 comes divided by 1.e20
! *******************************************************************

cc     Inversion using Num. Recipes
      gold=rold ! to save before using (and destroting) 
	  do i=1,nmom4
	  do j=1,nmom4
	  y(i,j)=0.
	  enddo
	  y(i,i)=1.
	  enddo
      call ludcmp(rold,nmom4,6,indx,ddd)     ! indx, ddd = output
      do j=1,nmom4                         
	  call lubksb(rold,nmom4,6,indx,y(1,j))  !  rold is DESTROYED !!!
	  enddo
      do i=1,nmom4
	  do j=1,nmom4
 	  rinv(i,j)=y(i,j)
	  enddo
      enddo
	  rold=gold ! restoring from saved array ! needed
cc  End of inversion in Num. Recipes

c      write(*,*) 'ahoj5'

! *******************************************************************
! **** Output of covariance matrix of model param: Cm = (Gt G)-1 * vardat
!  vardat is global data variance estimated as squared amplitude at most distant stat
!         Cm is effectively divided  by * 1.e20 [corrected later in newunc in GUI] 
! Does not depend on time, therefore for each position is printed only once.
! This is controlled by keywrite parameter of the subroutine.
! *******************************************************************

      
      if(keywrite.eq.1) then 
c       global data variance vardat from common /VAR/ 
c       write(*,*) vardat
c		nskip=12
      write(400,*) 'trial position no. ', isrc(1)
      if (nmom.eq.5) nskip=11;
      if (nmom.eq.6) nskip=12;

      do i = 1,nskip; 
      write(400,*); 
      enddo ! 11 ci 12 prazdnych radku 
        write(400,*) ' Covariance matrix; NOT corrected for  scaling'
        do i=1,nmom	  
        write(400,'(6e15.6)') (rinv(i,j)*vardat,j=1,nmom) 
        enddo	
      endif        	

! *******************************************************************
! **** The LSQ Solution:  (Gt G)-1 Gt d                        ****
!       here the 1.e20 factors cancel each other
! *******************************************************************

      aopt1=matmul(rinv,gnew)     ! One MTs (6 acka in one vector)
      
c	  write(*,*) aopt1
c      write(666,'(6(1x,e12.5))') (aopt1(i),i=1,6)

      call silsub2(aopt1,str1_1,dip1_1,rake1_1,str2_1,dip2_1,rake2_1,
     * amoment1,dcperc1,avol1,aclvd1) 
c	  write(*,*)                         !'Source 1:'
c	  write(*,*) 'strike,dip,rake, moment:'
c	  write(*,*)  str1_1, dip1_1, rake1_1, amoment1 
c	  write(*,*) 'DC%, CLVD%, VOL%:'
c	  write(*,*)  dcperc1,aclvd1,avol1
	  
c      write(111,'(1i5,1f8.2,3f8.0,1e12.5,3f8.0)')
c     * isour1,ishf1*dt,str1_1,dip1_1,rake1_1,amoment1,
c     * dcperc1,aclvd1,avol1

! *******************************************************************
! **** Synthetic seismograms    **** no output !!
! *******************************************************************
      
      call subevnt22_1024(isour1,aopt1,ishf1,sx)	! seismo sx for source 1  
      

      do icom=1,3
        do ir=1,nr			 ! inlcuding the non-inverted stations/components
          do itim=1,ntim		 ! residual seismogram (syn is formed in norm.exe)
          finr(itim,ir,icom)=  ori(itim,ir,icom) - sx(itim,ir,icom)
          enddo            
        enddo
      enddo


!c
!c     COMPUTING L2 FIT (error2)  =  L2 norm of final residual seismogram
!c

      error2=0.
      do icom=1,3
       do ir=1,nr
c       if(stat(ir)) then
        do itim=1,ntim !ntim 
        error2=error2+ 
     *  (finr(itim,ir,icom)*weig(ir,icom))**2    ! new 25.10 2019 WEIGHTS included in VR
       enddo
c       endif
       enddo
      enddo
      error2=error2*dt
c      accumerr = error2 / rrori   ! normalization by power of ORI data
      accumerr = error2 / rrori2   ! normalization by power of ORI data
                                  ! (weights considered) 
      varred   = 1. - accumerr   ! variance reduction 

        goto 887 !skip writing RES into  file 
		
        do ir=1,nr
        nfile=3000+1*ir
   	    statfil3=trim(statname(ir))//'res.dat'
        open(nfile,file=statfil3)
          do itim=1,ntim
          time=float(itim-1)* dt
          write(nfile,'(4(1x,e12.5))') time,
     *         finr(itim,ir,1), finr(itim,ir,2), finr(itim,ir,3)
          enddo
        close(nfile)
        enddo

 887   continue

c      write(*,*) 'varred= ', varred
      write(*,*)  isour1,ishf1*dt,str1_1,dip1_1,rake1_1,amoment1,
     * dcperc1,aclvd1,avol1,varred

        write(111,'(3i5,3f8.0,1e12.5,3f8.0,5x,1f12.4)')
     * ipert,isour1,ishf1,str1_1,dip1_1,rake1_1,amoment1,
     * dcperc1,aclvd1,avol1,varred
   
          
c       xmommag=(2.0/3.0)*log10(amoment1) - 6.0333 
  
        write(122,'(1x,3i5,2f8.0,6e15.5,10x,1f12.4)')
     * ipert,isour1,ishf1,aclvd1,avol1,
     * aopt1(1),aopt1(2),aopt1(3),aopt1(4),aopt1(5),aopt1(6),varred	 

 888   continue

 
      RETURN
      END

