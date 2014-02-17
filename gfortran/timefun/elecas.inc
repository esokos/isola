      subroutine elecas(filename,aopt,ishf,seismo)

c     aopt ... moment tensor
c	w ... uz nejsou elem seis ale kompletni seismogram pro 1 pozici zdroje, s 1 MT a s BASIC SHIFT  ISHF
c           (= sloupce matice G) 
c  all (12) particular shifts will be made in main !!!!!!

 

      dimension aopt(6)
      
      character*12 filename
      dimension seismo(-1000:8192,21,3)     
      dimension      s(-2000:10192,21,3) !  pomocne pole ????????????? bude stacit posun 2000dt????????
      dimension es(8192,21,3,6) ! elemse; 6= pocet acek
    	
      dimension ntm(21)               
      dimension weig(21,3)            
      logical stat(21)


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 f1,f2,f3,f4,dt
 
       common /ST/ stat,ntm              
       common /WEI/ weig


      open(100,form='unformatted',file=filename)     ! elementary seismograms from ELEMSE (input)

c
c      READING 6 ELEMENTARY velocity SEISMOGRAMS, a single point source
c      (synth. Green's convolved with SOME time fctn.; see ELEMSE.FOR)
c      Caution! The time function used in elemse.for must be triangle and its duration must be known !!!!!!!!
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
        close (100)

        
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

       if(ishf.gt.2000) then
	   write(*,*)   'problem dimension 2 (subr. elecas)'
	   write(222,*) 'problem dimension 2 (subr. elecas)'
	   stop
	   endif


      do ir=1,nr          
      do itim=1,ntim   
c	  ishf   basic shift v poctu cas kroku
      seismo(itim,ir,1)= s(itim-ishf,ir,1)
      seismo(itim,ir,2)= s(itim-ishf,ir,2)
      seismo(itim,ir,3)= s(itim-ishf,ir,3)
      enddo
      enddo



c      do ir=1,nr           ! output of seismo for plotting NO FILTER !!!
c          do itim=1,ntim
c          time=float(itim-1)*dt
c          write(8256,'(4(1x,e12.6))') time,
c     *          seismo(itim,ir,1),seismo(itim,ir,2),seismo(itim,ir,3)
c          enddo
c          write(8256,*) '*'
c        enddo


c
c     FILTERING SEISMO (w will inlcude filter, displacement,, shift)
c

      do ir=1,nr
        do icom=1,3
        call filter(f1,f2,f3,f4,dt, seismo(1,ir,icom) )     ! ??????????????? needs testing !!!!!!!!!!!!!!!!! s????????
        enddo
      enddo
       

c       do ir=1,nr !!! output of seismo for plotting WITH FILTER = filter + integ. to displ. + shift !
c          do itim=1,ntim
c          time=float(itim-1)*dt
c          write(8256,'(4(1x,e12.6))') time,
c     *          seismo(itim,ir,1),seismo(itim,ir,2),seismo(itim,ir,3)
c          enddo
c          write(8256,*) '*'
c        enddo




        RETURN
        END

