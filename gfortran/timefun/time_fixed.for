      program cas

!     simultaneously inverting for moment coefficients of MAX 12 triangles per source
!     allowed are 2 sources (each one with its OWN position, MT and basic time shift)
!     each source consists of NTR (max NTR=12) triangles of equal duration
!     and mutual shift,
!     their amplitudes (=moments) are sought for
  
!     Author: J. Zahradnik 2011, 2012

      CHARACTER *2 CHR(99)
      CHARACTER *1 reply
      CHARACTER *12 filename1,filename2
c     CHARACTER *3 statname(21)
      CHARACTER *5 statname(21)
      character *17 statfil1,statfil2,statfil3  !!g77
      character *10  corrfile


      dimension aopt1(6),aopt2(6) ! 6 here refers to the number of MT components!!!!!!!!!!!!!!!!!

	dimension seismo(-1000:8192,21,3) !         ??????? bude stacit posun 1000 dt??????????????????????????????????????
      dimension xinv(8192,21,3)
      dimension  ori(8192,21,3)
      dimension   sx(8192,21,3)
c      dimension syn(8192,21,3)
      dimension finr(8192,21,3)		 ! 21 = max number of stations

      dimension nuse(21)
      dimension ntm(21)
      dimension weig(21,3)


      dimension w(8192,21,3,24)  

      double precision rnorm,ama(516097,24),bve(516097),ampl(24),wnn(24)

! dim 2x12= 24 is also in subcas !!!!!!!
!     dimense 516097 is number of stations 21 x nomber of comp.  3 * number of times  8192 PLUS 1 (na momentovou podminku)

	integer mode,numdat 

      logical stat(21)   

      DATA CHR/'01','02','03','04','05','06','07','08','09','10',
     *         '11','12','13','14','15','16','17','18','19','20', 
     *         '21','22','23','24','25','26','27','28','29','30', 
     *         '31','32','33','34','35','36','37','38','39','40', 
     *         '41','42','43','44','45','46','47','48','49','50', 
     *         '51','52','53','54','55','56','57','58','59','60', 
     *         '61','62','63','64','65','66','67','68','69','70', 
     *         '71','72','73','74','75','76','77','78','79','80', 
     *         '81','82','83','84','85','86','87','88','89','90', 
     *         '91','92','93','94','95','96','97','98','99'/
     
 
      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,	
     *                 f1,f2,f3,f4,dt		 
      common /ST/ stat,ntm
      common /WEI/ weig	   


      open(150,file='allstat.dat')   ! input: stations, weights,...
      open(151,file='inpinv.dat')    ! input: control parameters

      open(152,file='acka1.dat')      ! input: MT source no. 1
 	open(153,file='acka2.dat')		! input: MT source no. 2
	open(154,file='casopt.dat')

      open(111,file='inv111.dat',status='unknown')     ! output: all details
	open(222,file='inv222.dat',status='unknown')   ! output: = input for timefun.for and plotting

!     FIXED OPTIONS
      ntim=8192 ! number of time samples  
	nmom=6	  ! check whether nmom is used, I tried not to use it at all (it goes to subroutines via common)

c	write(*,*) 'ONE source (1), or TWO (2)?'
c	read(*,*) nonetwo
      read(154,*) nonetwo
	write(111,*) 'ONE source (1), or TWO (2)=',nonetwo
	

c	write(*,*) 'number of triangles per a source (max 12)= ?'
c	read(*,*) ntr
      ntr=12	 !!!!!!!! FIXED !!!!!!!!!!!
	write(111,*) 'number of triangles per a source= ',ntr
      
	    
	NTR2=NTR
	if (nonetwo.eq.2) NTR2=NTR*2
c      write(*,*) 'NTR2= ',NTR2     


	ir=1
  7   read(150,*,end=8) statname(ir),nuse(ir),	 
     *             weig(ir,1),weig(ir,2),weig(ir,3) 

      stat(ir)=.true.
      if(nuse(ir).eq.0) stat(ir)=.false.
      ntm(ir)=8192+1    
      ir=ir+1
      if(ir.gt.21) goto 8
      goto 7
  8    nr=ir-1
      write(*,*) 'number of stations (max 21), nr=', nr
      write(*,*) 'stations used in the inversion:'
      do ir=1,nr
      if(stat(ir)) write(*,*) statname(ir)      
      enddo


      do ir=1,nr
      numf1=1000+(ir*1)
      numf2=2000+(ir*1)
      numf3=3000+(ir*1)
      statfil1=trim(statname(ir))//'raw.dat'  !!! new Patras, July 2012
      statfil2=trim(statname(ir))//'fil.dat'
      statfil3=trim(statname(ir))//'res.dat'
      open(numf1,file=statfil1)
      open(numf2,file=statfil2)
      open(numf3,file=statfil3)
      enddo


c      do ir=1,nr
c        do icom=1,3
ccc        weig(ir,icom)=(1./weig(ir,icom))	  ! 
c        enddo
c      enddo


      read(151,*) 
      read(151,*) keyinv	 ! not used !!
      read(151,*) 
      read(151,*) dt
      read(151,*) 
      read(151,*) isourmax	 ! not used
      read(151,*) 
      read(151,*) 
      read(151,*) ifirst,istep,ilast
      read(151,*) 
      read(151,*) isubmax
      read(151,*) 
      read(151,*) 
      read(151,*) f1,f2,f3,f4
      read(151,*)
      read(151,*) vardat


	do i=1,6     !! fix	always to 6; the number of MT components
	read(152,*) aopt1(i)         ! acka MT for sub1
	enddo

	if(nonetwo.eq.2) then
	do i=1,6     !! fix	always to 6; the number of MT components
 	read(153,*) aopt2(i)         ! acka MT for sub2
	enddo
	endif

      call silsub(aopt1,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
     * avol)
c	write(*,*) 'strike,dip,rake, moment:'
c	write(*,*)  str1, dip1, rake1, amoment 
      do i=1,6     !!  UNIT moment
	aopt1(i)=aopt1(i)/amoment	 ! normalizing moment to unity 
	enddo
      write(111,*) 'SUB1: str, dip, rake: ',str1, dip1, rake1
	write(111,*)  '(no meaning for pure volume component)' 


c	write(*,*)

	if(nonetwo.eq.2) then
      call silsub(aopt2,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
     * avol)
c	write(*,*) 'strike,dip,rake, moment:'
c	write(*,*)  str1, dip1, rake1, amoment 
	do i=1,6     !!  UNIT moment
	aopt2(i)=aopt2(i)/amoment	 ! normalizing moment to unity 
	enddo
c      write(111,*) 'SUB2: str, dip, rake: ',str1, dip1, rake1
c	write(111,*)  '(no meaning for pure volume component)' 
	endif


c      write(*,*) 'source_1 number = isour1=?'
c	read(*,*) isour1
	read(154,*) isour1
	write(111,*) 'isour1: ',isour1

	if(nonetwo.eq.2) then
c      write(*,*) 'source_2 number = isour2=?'
c	read(*,*) isour2
	read(154,*) isour2
	write(111,*) 'isour2: ',isour2
	endif

!     isour je zvoleny zdroj (prvni cislo v inv2.dat normalni MT inverze predchzejici tomuto programu)
!     cili zvoleny pouzity soubor elemse**.dat 
!     ishf je zakladni posun (druhe cislo v inv2.dat normalni MT inverze predchzejici tomuto programu)

c      write(*,*) 'optimum source_1 shift (in sec)=?'
c	read(*,*) shiftopt1
      read(154,*) shiftopt1       	
     	ishf1=ifix(shiftopt1/dt) ! basic shift
      write(111,*) 'optshift1: ',shiftopt1

      if(nonetwo.eq.2) then
c	write(*,*) 'optimum source_2 shift (in sec)=?'
c 	read(*,*) shiftopt2
      read(154,*) shiftopt2
	ishf2=ifix(shiftopt2/dt) ! basic shift
	write(111,*) 'optshift2: ',shiftopt2
	endif

c	write(*,*) 'duration of elem triangle in sec (from GREEN)=?'
c 	read(*,*) dur
 	read(154,*) dur
      write(111,*) 'duration of elem triangle in sec = ', dur

! Code IMPLICITLY uses duration from Green. 
!     dur = the duration used in preparation of elementary seismograms
! It is prescribed here only to prepare input data for plotting. 

      
c	write(*,*) 'triangles distance in sec (same for src1 and 2)=?'
c	read(*,*) shiftbase
	read(154,*) shiftbase
      nshf=ifix(shiftbase/dt) ! vyjadrena v poctu cas. kroku
      write(111,*) 'triangles distance in sec = ', shiftbase
	write(111,*) 'Caution: works in integer multiple of dt!'

c     write(*,*) 'constraining moments (0=no, 1=yes):'
c	read(*,*) keymomcns
      read(154,*) keymomcns
      write(111,*) 'keymomcns = ', keymomcns

      if(keymomcns.eq.1) then

      if(nonetwo.eq.2) then
c	write(*,*) 'requested SUB1 moment in Nm =?'     ! ??????????????????fixed moment???????????????????????????
c 	read(*,*) xmomreq1								 ! ?????????????????????????????????????????????
      read(154,*) xmomreq1
	write(111,*) 'requested SUB1 moment in Nm = ', xmomreq1
c 	write(*,*) 'requested SUB2 moment in Nm =?'     ! ??????????????????fixed moment???????????????????????????
c 	read(*,*) xmomreq2	
      read(154,*) xmomreq2							 ! ?????????????????????????????????????????????
	write(111,*) 'requested SUB2 moment in Nm = ', xmomreq2
 	else

c	write(*,*) 'requested TOTAL moment in Nm =?'     ! ??????????????????fixed moment???????????????????????????
c 	read(*,*) xmomreq12	
	xmomreq12=xmomreq1+xmomreq2c						 ! ?????????????????????????????????????????????
c	write(111,*) 'requested TOTAL moment in Nm = ', xmomreq12

      endif
	
      endif
! *******************************************************************
! ************ MANIPULATE OBSERVED DATA *****************************
! *******************************************************************

       call manidata(ori,rrori)    ! manipulate OBSERVED data
!           input: read from file in the subroutine
!          output: ori=ori data filtered
!                  rrori=data power

      do icom=1,3
        do ir=1,nr
          do itim=1,ntim
          xinv(itim,ir,icom)=ori(itim,ir,icom)
          enddo
        enddo
      enddo



	 j=0
       do ir=1,nr          
            if(stat(ir)) then
	 do icom=1,3
       do itim=1,ntim   
       j=j+1
c	 bve(j)=xinv(itim,ir,icom)	* 1.e10		! this is the data column
 	 bve(j)=xinv(itim,ir,icom)	* weig(ir,icom) * 1.e10		
 
       enddo
       enddo
  		  endif
       enddo

      if(keymomcns.eq.1) then

      if(nonetwo.eq.2) then
       j=j+1			  !     ???????????????fixed moment   sub1 ???????????????????????????????????
       bve(j)=xmomreq1 *1.e-5 
	 j=j+1			  !     ???????????????fixed moment    sub2 ???????????????????????????????????
       bve(j)=xmomreq2 *1.e-5 
	else
	 j=j+1
       bve(j)=xmomreq12 *1.e-5 !  !!!!!!!!!!!fixed TOTAL moment!!!!?????????????????????????
	endif

      endif

	
      numdat=j
      write(*,*) 'numdat= ',numdat

c Printing data
c      do j=1,numdat
c      write(444,'(6(1x,e12.6))') bve(j)
c      enddo
 


!c *******************************************************************
!c ************ USING the !!!!!!!!TWO!!!!!!! CHOSEN TRIAL SOURCEs isour1 and isour2 **********
!c                     making NTR shifts of each and forminig matrix
!c *******************************************************************


       filename1='elemse'//chr(isour1)//'.dat'
       call elecas(filename1,aopt1,ishf1,seismo)
c
c seismo je ruzne pro zdroj 1 a 2 (obecne se lisi poloha, MT, zakladni casovy posun)
c prepisuje se do w jehoz it=1,...NTR,NTR+1,....NTR2
c Kdyby zdroje byly ve stejnem bode musi se lisit bud zakladni casovy posun zdroje 1 a 2
c nebo jeho acka (aby se predeslo zavislosti radku/sloupcu matice) 
c
      do it=1,NTR 	 ! NTR formerly was 6; here is the number of triangles (shifts)
      do ir=1,nr          
	do icom=1,3
      do itim=1,ntim   
	itshift=(it-1)*nshf    ! nshf je stejne pro kazdy subzdroj 
      if(itshift.gt.1000) then
	write(*,*)   'problem dimension 1'
	write(111,*) 'problem dimension 1'
	stop
	endif
      w(itim,ir,icom,it)=seismo(itim-itshift,ir,icom)	  
	 enddo
       enddo
       enddo
	 enddo


	if(nonetwo.eq.2) then
       filename2='elemse'//chr(isour2)//'.dat'
       call elecas(filename2,aopt2,ishf2,seismo)
      do it=NTR+1,NTR2  
      do ir=1,nr          
      do icom=1,3
      do itim=1,ntim   
      itshift=(it-NTR-1)*nshf   !  
      w(itim,ir,icom,it)=seismo(itim-itshift,ir,icom)
       enddo
       enddo
       enddo
	 enddo
	endif


!c     forming matrix 
	
	do it=1,NTR2	 ! NTR2 is the whole number of triangles (shifts) for TWO sources
	 j=0			 ! (if only 1 source, we defined NTR2=NTR above)
       do ir=1,nr          
            if(stat(ir)) then
	 do icom=1,3
       do itim=1,ntim   
       j=j+1

c	 ama(j,it)=w(itim,ir,icom,it) *1.e10	 ! this is the matrix G (d=Gm),    not GTG !
	 ama(j,it)=w(itim,ir,icom,it) * weig(ir,icom)*1.e10	 ! this is the matrix G (d=Gm),    not GTG !

       enddo
       enddo
            endif 
       enddo


c###################################

      if(keymomcns.eq.1) then

	if(nonetwo.eq.2) then
	 j=j+1			  !     ???????????????fixed moment   sub1 ???????????????????????????????????
       if(it.le.NTR) then
		ama(j,it)=1.  * 1.e-5 
	 else 
	    ama(j,it)=0.
	 endif
	 j=j+1			  !     ???????????????fixed moment    sub2 ???????????????????????????????????
       if(it.le.NTR) then
		ama(j,it)=0.  * 1.e-5 
	    else 
	    ama(j,it)=1.  * 1.e-5
		endif
     	else
        j=j+1
       ama(j,it)=1.  * 1.e-5 !    ????????????fixed TOTAL moment ???????????????????????????????????
      endif

      endif


    	numdat=j
c     write(*,*) 'numdat= ',numdat
	enddo

c  Printing matrix    
c	do j=1,numdat
c	write(555,'(12(1x,e12.6))') (ama(j,n),n=1,NTR2)
c	enddo


	call tinv(ama,bve,ampl,mode,rnorm,numdat,NTR2)
c CAUTION !!!! tinv is calling NNLS; 
	write(*,*) 'mode= ',mode
	if(mode.ne.1) then
	write(*,*) 'mode not 1, problem in nnls'
	stop
	endif

	write(111,*)
      write(111,*) 'Inversion result:'
      write(111,*) 'moment coefficients of the triangles ampl(i)'
      write(111,'(6(1x,e12.6))') (ampl(n),n=1,NTR)

	if(nonetwo.eq.2) then
	WRITE(111,*)
      write(111,'(6(1x,e12.6))') (ampl(n),n=NTR+1,NTR2)
	endif

      call subCAS(ampl,w,sx,NTR2)   
!c    if only 1 sourcem we defined NTR2=NTR above 
!c	input: amplitudes ampl and basis functions w
!c     output: seimogram sx 


!c     dur ! trvani kazdeho troj
!c	 shiftbase ! vzdalenost mezi trojuhleniky
!c     nshf=ifix(shiftbase/dt) ! vzdalenost mezi troj vyjadrena v poctu cas. kroku

!c     udam-li cas, trouhelnik je na nem CENTROVAN !!!!!!!!!!!!!!!!!
	  
      write(222,'(1x,e12.6,5x,i5)') dur, NTR 
	
      xmomtot1=0.
	do i=1,NTR ! source 1
	shf=shiftopt1 + float(i-1)*shiftbase
	xmom=ampl(i)      	 ! ampl je spravne;  bazove seismo maji stejne troj a jenotkovy moment
	xmomtot1=xmomtot1+xmom	 ! take v kreslicim programu jsou troj s jednotk. momentem; 'ampl' je moment; vaha jednotkovych momentuu
	write(222,'(i5,2(1x,e12.6))') i,shf,xmom
	enddo

	if(nonetwo.eq.2) then
	xmomtot2=0.
	do i=NTR+1,NTR2 !source 2
	shf=shiftopt2 + float(i-NTR-1)*shiftbase  ! POZOR (i-6)
	xmom=ampl(i) !*dur/2. (ne!)	 
	xmomtot2=xmomtot2+xmom	 
	write(222,'(i5,2(1x,e12.6))') i,shf,xmom
	enddo
	else
      NTRX=2*NTR	
	xmomtot2=0.
	do i=NTR+1,NTRX ! source 2 does not exist; will be added formally as zeros
	shf=shiftopt2 + float(i-NTR-1)*shiftbase  ! POZOR (i-6)
	xmom=0. ! formal zero value 	 
	xmomtot2=xmomtot2+xmom	 
	write(222,'(i5,2(1x,e12.6))') i,shf,xmom
	enddo

	endif

	write(111,*)
	write(111,*) 'source_1 moment (Nm): ',xmomtot1
	if(nonetwo.eq.2) then
	write(111,*) 'source_2 moment (Nm): ',xmomtot2
	endif
	write(111,*) 'total moment (Nm): ',xmomtot1+xmomtot2
	 
	
c      do icom=1,3
c        do ir=1,nr
c          do itim=1,ntim
c          syn(itim,ir,icom)= sx(itim,ir,icom)
c          enddo
c        enddo
c      enddo

      do icom=1,3
        do ir=1,nr			 ! inlcuding the non-inverted stations/components
          do itim=1,ntim		 ! residual seismogram (syn is formed in norm.exe)
c         finr(itim,ir,icom)=  ori(itim,ir,icom) - syn(itim,ir,icom)
          finr(itim,ir,icom)=  ori(itim,ir,icom) - sx(itim,ir,icom)
          enddo            
        enddo
      enddo

        do ir=1,nr
        nfile=3000+1*ir
          do itim=1,ntim
          time=float(itim-1)* dt  ! output of residual seimo *res.dat
          write(nfile,'(4(1x,e12.6))') time, 
     *         finr(itim,ir,1), finr(itim,ir,2), finr(itim,ir,3)
          enddo
        enddo


!c
!c     COMPUTING L2 MISFIT (error2) DIRECTLY = computing L2 norm of final resi
!c

      error2=0.
      do icom=1,3
       do ir=1,nr
       if(stat(ir)) then
        do itim=1,ntim
        error2=error2+ finr(itim,ir,icom)*finr(itim,ir,icom)
        enddo
       endif
       enddo
      enddo
      error2=error2*dt
      accumerr = error2 / rrori   ! normalization by power of ORI data
                                  ! (used stations only, no weights considered) 
      varred   = 1. - accumerr   ! variance reduction 
!c             ! accumerr and varred consider only the used stations
!c             ! (both in error2 and in rrori, assuming ntim=8192)
!c             ! for other measures of the misfit, see NORM.FOR


      write(111,*) 
      write(111,*) 'variance reduction (from the used stations only):'
      write(111,*) 'varred=',varred
      write(111,*) '======================================='
      write(111,*)

      STOP


      END

       subroutine newpause(a)
       character(len=*) a
       write(*,*) a
       read(*,*)
       end



!c =================================================================
!c      include "nnls.inc"
!c      include "nnls77.inc"
    
    
      include "manidata.inc"
      include "eleCAS.inc"
!c      include "oneinv3.inc"
!c      include "cnsinv2.inc"
!c      include "fixinv2.inc"
      include "subCAS.inc"
!c      include "lagra.inc"
!c      include "determi.inc"

      include "fcoolr.inc"
      include "filter.inc"
      include "filterSYN.inc"

      include "fw.inc"

      include "silsub.inc"
      include "jacobi.inc"
      include "line.inc"
      include "ang.inc"
      include "angles.inc"

      include "lubksb.inc"
      include "ludcmp.inc"
      include "zbrac.inc"
      include "rtbis.inc"

      include "jacobinr.inc"

