      subroutine elemat3_12c(filename,dur,aopt,nshf,ishf,w,rold,rinv)

c     aopt ... moment tensor
c	w ... uz nejsou elem seis ale seismogramy jednotl posunutych cas fci
c           (= sloupce matice G) 
C JE TO POZUSTATEK PRIPADU KDY TO BYLY ELEMSE A LISILY SE TVAREM; MOHL BYCH USETRIT INDEX IT
C POKUD YCH ZDE Z DALE VZDY ZNOVA W POSUNOVAL

c      nmom has no more meaning of 6 MTs but it is number of time shifts=number of amplitudes to be found   
c      w is no more elemse! (elemse is in es); w are complete seismograms with individual shifts 

 


      character*12 filename
      dimension w(8192,21,3,6)    ! 6 pocet cas fci
      dimension es(8192,21,3,6) ! elemse; 6= pocet acek
    	dimension  s(-2500:10692,21,3), aopt(6) ! aopt acka

      dimension r(6,6),rinv(6,6),rold(6,6)
        dimension gold(6,6),en(6),vv(6,6)
      dimension indx(6),y(6,6)
      dimension ntm(21)               
      dimension weig(21,3)            
      logical stat(21)


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm              
      common /WEI/ weig


      open(100,form='unformatted',file=filename)     ! elementary seismograms from ELEMSE (input)

c
c        READING 6 ELEMENTARY velocity SEISMOGRAMS, a single point source
c      (synth. Green's convolved with SOME time fctn.; see ELEMSE.FOR)
c      Caution! The time function used in elemse.for should be triangle and its duration shold be known to cas_nnls.for!!!!!!!!
c

      do ir=1,nr
        do it=1,6 ! .... MT components       
          do itim=1,ntim   
          read(100) time,
     *          es(itim,ir,1,it),es(itim,ir,2,it),es(itim,ir,3,it)
          enddo			 
        enddo
      enddo

        REWIND(100)

        
       do ir=1,nr          !!!!! from elem seismo to complete seismo      
       do itim = 1,ntim   
       s(itim,ir,1)=0.	 ! s = suma (aopt(it) . es(...,it)), soucet pres it=1,6 (MT)
       s(itim,ir,2)=0.
       s(itim,ir,3)=0.
       do it=1,6 ! it here numbering of MT components
       s(itim,ir,1)= s(itim,ir,1) + es(itim,ir,1,it) * aopt(it)
       s(itim,ir,2)= s(itim,ir,2) + es(itim,ir,2,it) * aopt(it)
       s(itim,ir,3)= s(itim,ir,3) + es(itim,ir,3,it) * aopt(it)      
       enddo
       enddo
       enddo

c     same seimograms must be shifted several times (response to shifted source funct)
c     these will be basis functions w 

c	  shiftbase	  ! parametr ; vzdalenost mezi trojuhelniky 
c      nshf=ifix(shiftbase/dt) ! vyjadrena v poctu cas. kroku; zna dt?
c      ishf je zakladni posun (dany orig timem)
      do ir=1,nr          
      do itim=1,ntim   
    	do it=1,6 ! only 6 time functions, or increase dimension; now it is numbering shifted responses mozna -2 to 3
	  itshift=it*nshf ! nshf je vzdalenost trojuhelniku v poctu cas kroku
      w(itim,ir,1,it)= s(itim-itshift-ishf,ir,1)
      w(itim,ir,2,it)= s(itim-itshift-ishf,ir,2)
      w(itim,ir,3,it)= s(itim-itshift-ishf,ir,3)
      enddo
      enddo
      enddo


c      do ir=3,3 !!!only Z          ! output of seismo for plotting NO FILTER !!!
c        do it=1,1 !!! instead of 1,6        
c          do itim=1,ntim
c          time=float(itim-1)*dt
c          write(8256,'(4(1x,e12.6))') time,
c     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
c          enddo
c          write(8256,*) '*'
c        enddo
c      enddo


c
c     FILTERING SEISMO (w will inlcude filter, displacement,, shift)
c

      do ir=1,nr
	  f1=ff1(ir)
	  f2=ff2(ir)
	  f3=ff3(ir)
	  f4=ff4(ir)
        do icom=1,3
          do it=1,6 ! only 6 time functions
          call filter(f1,f2,f3,f4,dt, w(1,ir,icom,it) )
          enddo
        enddo
      enddo
 

c      do ir=1,nr !!! output of seismo for plotting WITH FILTER = filter + integ. to displ. + shift !
c        do it=1,6 !!!        
c          do itim=1,ntim
c          time=float(itim-1)*dt
c          write(8256,'(4(1x,e12.6))') time,
c     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
c          enddo
c          write(8256,*) '*'
c        enddo
c      enddo


c    ! kvuli podmince na moment potrebuju pridat jen 1 sloupec do matice w a 1 radek do sloupce dat x
c    ! misto pridani proste vymenim posledni radek za ten co potrebuju (abych nemenil pocet radku)
c    ! POZOR nevim presne co je 'posledni prvek'; to zavisi take na tom, jak se matice w cte v oneinv3
C    ! zda poradi cyklu je ir, itim, it nebo jinak....
c    ! zde je ta zmena 1 radku:
      
 

c ***********************************************************************
c ***********FORMING AND INVERTING SYSTEM MATRIX 
c ***********************************************************************


c
c     FORMING SYSTEM MATRIX   GTG
c
c	nmom=6 !!!!!!!passed through common !!!!!! number of shifted time functions!!!!!
      do n=1,nmom   !n,m	shifted time functions
        do m=1,nmom
        r(n,m)=0.
          do icom=1,3
            do ir=1,nr
            if(stat(ir)) then
              do itim=1,ntim
c                 umele pridani dur/2 do posledni radky matice G (primo pri tvorbe GTG) kvuli podm na moment
c
c             if(itim.eq.8192.and.ir.eq.nr.and.icom.eq.3) then ! w(...) jsem nahradil jen zde, jinak se nemeni!
c        	   wNweig=1.e-22  *weig(ir,icom)
c              wMweig=1.e-22  *weig(ir,icom)
c	         else
              wNweig=w(itim,ir,icom,N)*weig(ir,icom)
              wMweig=w(itim,ir,icom,M)*weig(ir,icom)
c             endif !!!!!! new
              
              r(n,m)=r(n,m)+
     *            wNweig*wMweig*1.e20	
              enddo
            endif
            enddo
          enddo
c          r(n,m)=r(n,m)*dt
           r(n,m)=r(n,m)        !     NOVE BEZ nasobeni     *dt

        enddo
      enddo


C 	do i=1,nmom          ! printing sytem matrix
C        write(897,'(6(1x,e12.6))') (r(i,j),j=1,nmom)
C 	enddo
C        write(897,*)

 	do i=1,nmom          ! saving r(n,m) before inversion
 	  do j=1,nmom        ! (because after inversion r(n,m) is destroyed !)
 	    rold(i,j)=r(i,j)
          gold(i,j)=r(i,j)
 	  enddo
 	enddo

c        call JACOBInr(gold,nmom,6,en,vv,nrot)
c        write(*,*) 'eigenvalues'
c		write(*,*) (en(i),i=1,nmom)
c        write(*,*) 'eigenvectors'
c		do i=1,nmom
c		write(*,*) (vv(i,j),j=1,nmom)
c		enddo

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

c       write(897,*)
c       do i=1,nmom          ! printing inverse matrix
c       write(897,'(6(1x,e12.6))') (rinv(i,j),j=1,nmom)
ccc       write(897,'(6(1x,e12.6))') sqrt(rinv(i,i))
c	   enddo
c       write(897,*)
c       close(897)

        RETURN
        END

