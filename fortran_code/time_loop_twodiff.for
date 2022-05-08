      program time_loop_two_diff

c 2018: Weight of the moment constraint is better treated

c The changes April4 2017: (see goto 666)
c Searching all pairs: e.g. 3,15 is not the same as 15,3
c This is needed if two subevents have different focal mechanism
	  
c The changes with respect to time_fixed15 made in Feb. 2017: 
c 1) New calling of NNLS
c 2) Number of triangles 2x12 increased to 2x60
c 3) subCAS17
c 4) not solved how to prescribe NTR; it is fixed NTR=60
c  ... if changed to NTR=12 should work as the time_loop_two15 (if it runs due to dim) 
c (no need to go back to old calling of nnls!!)

c CAUTION::::::::::: EXE code may not run (too large)
c In case of a problem, decrease NTR and dimensions (also in subCAS17)
  
!     Author: J. Zahradnik 2011, 2012, 2015, 2017, 2018

      parameter (nhsrc=120) ! maximum number of elem functions; formerly 2x12, now 2x60
c        nhsrc cannot! be simply changes here; it is also in subCAS17
      parameter (nhdat=21*3*8192+1) ! max length of data column (1 = for moment); formerly 516097
c      parameter (nhsta=21) ! cannot! be simply changed here

      CHARACTER *2 CHR(99)
      CHARACTER *1 reply
      CHARACTER *12 filename1,filename2
c     CHARACTER *3 statname(21)
      CHARACTER *5 statname(21)
      character *17 statfil1,statfil2,statfil3  !!g77
      character *10  corrfile

      dimension ipair(99,99) ! 99 max number of source positions
      dimension aopt1(6),aopt2(6) ! 6 here refers to the number of MT components!!!!!!!!!!!!!!!!!

	dimension seismo(-6000:8192,21,3) !         ??????? is it enough??????????????????????????????????????
      dimension xinv(8192,21,3)
      dimension  ori(8192,21,3)
      dimension   sx(8192,21,3)
c      dimension syn(8192,21,3)
      dimension finr(8192,21,3)		 ! 21 = max number of stations

      dimension nuse(21)
      dimension ntm(21),keygps(21)
      dimension weig(21,3)


c      dimension w(8192,21,3,24)  
      dimension w(8192,21,3,nhsrc)  

c      double precision rnorm,ama(516097,24),bve(516097),ampl(24),wnn(24)
c      double precision bvesave(516097)
! dim 2x12= 24 is also in subcas !!!!!!!
!     dimense 516097 is number of stations 21 x number of comp.  3 * number of times  8192 PLUS 1 (the moment constaint)
c	integer mode,numdat 

ccc     Dim. for nnls_kiku (single precision F77 code taken from Kikuchi's mom3)
c This is strongly PREFERRED
      dimension ama(nhdat,nhsrc),bve(nhdat),ampl(nhsrc)
      dimension wnn(nhsrc),zz(nhdat),indx(nhsrc)
      dimension bvesave(nhdat)	  
c      dimension bve2(nhdat)

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
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt

      common /ST/ stat,ntm
      common /WEI/ weig	   


      open(150,file='allstat.dat')   ! input: stations, weights,...
      open(151,file='inpinv.dat')    ! input: control parameters

      open(152,file='acka1.dat')      ! input: MT source no. 1
      open(153,file='acka2.dat')		! input: MT source no. 2
      open(154,file='casopt.dat')

      open(111,file='inv111.dat',status='unknown')     ! output: all details
      open(222,file='inv222.dat',status='unknown')   ! output: = input for timefun.for and plotting

      write(*,*) 'This is time_loop_two_diff'
      write(*,*)	  
	  
!     FIXED OPTIONS
      ntim=8192 ! number of time samples  
	nmom=6	  

c	write(*,*) 'ONE source (1), or TWO (2)?'
c	read(*,*) nonetwo
	nonetwo=2  !FIXED
	write(111,*) 'ONE source (1), or TWO (2)=',nonetwo

c	write(*,*) 'number of triangles per a source (max 12)= ?'
c	read(*,*) ntr
    	ntr=60   	   !FIXED      !!!!!!!!!!NEW !!!!!!!Feb. 2017 (cautionin GUI)
	write(111,*) 'number of triangles per a source= ',ntr

	NTR2=NTR
	if (nonetwo.eq.2) NTR2=NTR*2
c      write(*,*) 'NTR2= ',NTR2     


	ir=1
  7   read(150,*,end=8) statname(ir),nuse(ir),	  ! nuse=0 ... station not used 
     *            weig(ir,1),weig(ir,2),weig(ir,3), ! weig=0 ... component not used
     *            ff1(ir),ff2(ir),ff3(ir),ff4(ir)

       if(nuse(ir).eq.0) then
       weig(ir,1)=0;  weig(ir,2)=0; weig(ir,3)=0 ! No need to care about stat; all info is in weig
       endif

      stat(ir)=.true.
      if(nuse(ir).eq.0) stat(ir)=.false.
      ntm(ir)=8192+1    
      ir=ir+1
      if(ir.gt.21) goto 8
      goto 7
  8    nr=ir-1
c      write(*,*) 'number of stations (max 21), nr=', nr
c      write(*,*) 'stations used in the inversion:'
c      do ir=1,nr
c      if(stat(ir)) write(*,*) statname(ir)      
c      enddo

      do ir=1,nr               !!!!!!!!!1.2.2015
      keygps(ir)=0.
      enddo


      do ir=1,nr
      numf1=1000+(ir*1)
      numf2=2000+(ir*1)
      numf3=3000+(ir*1)
      statfil1=trim(statname(ir))//'raw.dat'  !!! new Patras, July 2012
c     statfil2=trim(statname(ir))//'fil.dat'
c     statfil3=trim(statname(ir))//'res.dat'
      open(numf1,file=statfil1)
c     open(numf2,file=statfil2)
c     open(numf3,file=statfil3)
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
c      read(151,*) ifirst,istep,ilast
      read(151,*) ibegin,istep,ilast
	ifirst=ibegin-istep
      read(151,*) 
      read(151,*) isubmax
      read(151,*) 
      read(151,*) 
      read(151,*) f1,f2,f3,f4	 ! not used, read from allstat  
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
      write(111,*) 'SUB2: str, dip, rake: ',str1, dip1, rake1
	write(111,*)  '(no meaning for pure volume component)' 
	endif

c	write(*,*) 'optimum source_1 shift (in sec)=?'
c 	read(*,*) shiftopt1
	read(154,*) shiftopt1 
 	ishf1=ifix(shiftopt1/dt) ! basic shift
      write(111,*) 'optshift1: ',shiftopt1

      if(nonetwo.eq.2) then
c	write(*,*) 'optimum source_2 shift (in sec)=?'
c 	read(*,*) shiftopt2
c      shiftopt2=30.   !FIXED
      shiftopt2=shiftopt1
 	ishf2=ifix(shiftopt2/dt) ! basic shift
	write(111,*) 'optshift2: ',shiftopt2
	endif

c	write(*,*) 'duration of elem triangle in sec (for plotting only)=?'
c 	read(*,*) dur
      read(154,*) dur
      write(111,*) 'duration of elem triangle in sec = ', dur

! Code IMPLICITLY uses duration from Green. 
!     dur = the duration used in preparation of elementary seismograms
! It is prescribed here only to prepare input data for plotting. 

      
c	write(*,*) 'triangles distance in sec (same for src1 and 2)=?'
c	read(*,*) shiftbase
      read(154,*)	shiftbase     
      nshf=ifix(shiftbase/dt) ! vyjadrena v poctu cas. kroku
      write(111,*) 'triangles distance in sec = ', shiftbase
c	write(111,*) 'Caution: works in integer multiple of dt!'

c     write(*,*) 'constraining total moment (0=no, 1=yes):'
c	read(*,*) keymomcns
	read(154,*)	keymomcns
      write(111,*) 'constraining total moment (0=no, 1=yes):', keymomcns

      if(keymomcns.eq.1) then
	read(154,*)	xmomreq12
      endif 						

! *******************************************************************
! ************ MANIPULATE OBSERVED DATA *****************************
! *******************************************************************

       call manidata15_loop_two(keygps,ori,rrori)    ! manipulate OBSERVED data
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

      bvemax=maxval(xinv)
      write(*,*) 'max. of data column= ',bvemax


	 j=0
       do ir=1,nr          
            if(stat(ir)) then
	 do icom=1,3
       do itim=1,ntim   
       j=j+1
c	 bve(j)=xinv(itim,ir,icom)	! * 1.e10		! this is the data column
 	 bve(j)=xinv(itim,ir,icom)	* weig(ir,icom) ! * 1.e10		
 
       enddo
       enddo
  		  endif
       enddo

      if(keymomcns.eq.1) then
c Fixing always total moment Mo (sub1, or sub1+sub2 sub, not separately the sub1 and sub2 )
c We can add last row Mo to data column and last row 1, 1, 1... to the matrix.
c Alternatively we can add 1 to data column and 1/Mo, 1/Mo, 1/Mo ... to the  matrix
c Here we  add  const to data column, and const/Mo. const/Mo. ... to the  matrix
c The const should be 2 to 5 orders higher than maximum of data column; this is default.
c If const < bvemax * 1.e2, moment will not be constrained well, inversion similar to unconstrained. 
c If const > bvemax * 1.e5, the constraint is too strong, inversion of time function failes.
c These 'limits' may vary from problem to problem.
	  bvecnst= bvemax * 1.e4  ! default
      write(*,*) 'Default weight of the moment constr.= ', bvecnst
	  write(*,*) 'Weight should be ~ 4 orders higher than max of data' ! 2 to 5 orders higher
c      write(*,*) 'Users weight: default multiplied by ? (e.g. 1.) = '
c	  read (*,*) usermult  
c	  bvecnst = bvecnst * usermult  
      write(*,*) 'Final choice of the moment weight = ', bvecnst

       j=j+1			  !      
       bve(j)=bvecnst 	   ! constraining total moment
      endif

	
      numdat=j
c      write(*,*) 'numdat= ',numdat

      do j=1,numdat	  ! important to save; it is re-written !!
      bvesave(j)=bve(j)
      enddo

c Printing data
c      do j=1,numdat
c      write(444,'(6(1x,e12.6))') bve(j)
c      enddo
 


!c *******************************************************************
!c ************ USING the !!!!!!!!TWO!!!!!!! CHOSEN TRIAL SOURCEs isour1 and isour2 **********
!c                     making NTR shifts of each and forminig matrix
!c *******************************************************************

c	write(111,*)
c      write(*,*) 'source_1 number = isour1=?'
c	read(*,*) isour1
c	write(111,*) 'isour1: ',isour1

c	if(nonetwo.eq.2) then
c      write(*,*) 'source_2 number = isour2=?'
c	read(*,*) isour2
c	write(111,*) 'isour2: ',isour2
c	endif

      read(154,*) ngrid
c	ngridpul=ngrid/2+2
c	isour1=0
c	isour2=0
c	do 888 isour1=1,ngridpul

      do  isour1=1,ngrid
	  do  isour2=1,ngrid
      ipair(isour1,isour2)=0.
      enddo
      enddo

	do 888 isour1=1,ngrid
	do 887 isour2=1,ngrid

	
      goto 666 ! this allows for all pairs (e.g. 3,15 is NOT same as 15,3)
	  
      if(ipair(isour2,isour1).eq.1) then 
      goto 887
      else
      ipair(isour1,isour2)=1
      endif

	  666 continue 
   
	write(*,*) isour1,isour2
c	write(111,*) 'isour1,isour2: ',isour1,isour2

       filename1='elemse'//chr(isour1)//'.dat'
       call elecas15(keygps,filename1,aopt1,ishf1,seismo)

      do it=1,NTR 	 ! NTR formerly was 6; here is the number of triangles (shifts)
      do ir=1,nr          
	do icom=1,3
      do itim=1,ntim   
	itshift=(it-1)*nshf    ! nshf same for each subsource
      if(itshift.gt.6000) then
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
       call elecas15(keygps,filename2,aopt2,ishf2,seismo)
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

c	 ama(j,it)=w(itim,ir,icom,it) ! *1.e10	 ! this is the matrix G (d=Gm),    not GTG !
	 ama(j,it)=w(itim,ir,icom,it) * weig(ir,icom) ! *1.e10	 ! this is the matrix G (d=Gm),    not GTG !

       enddo
       enddo
            endif 
       enddo


c###################################

      if(keymomcns.eq.1) then
      j=j+1
      ama(j,it)=(1./ xmomreq12) * bvecnst ! constraining total moment 
      endif


    	numdat=j
c     write(*,*) 'numdat= ',numdat
	enddo

c  Printing matrix    
c	do j=1,numdat
c	write(555,'(12(1x,e12.6))') (ama(j,n),n=1,NTR2)
c	enddo


	do j=1,numdat	
	bve(j)=bvesave(j)
	enddo

c      OLD style calling nnls 
c	call tinv(ama,bve,ampl,mode,rnorm,numdat,NTR2) 
c CAUTION !!!! tinv is calling NNLS;

cccc The following is strongly PREFERRED:
      call nnls_kiku
     *	 (ama,nhdat,NUMDAT,NTR2,bve,ampl,rnorm,wnn,zz,indx,mode)
c caution: vector bve will be RE-WRITTEN (cannot be used second time)
 
c	write(*,*) 'mode= ',mode
	if(mode.ne.1) then
	write(*,*) 'mode not 1, problem in nnls'
	stop
	endif

c	write(111,*)
c      write(111,*) 'Inversion result:'
c      write(111,*) 'moment coefficients of the triangles ampl(i)'
c      write(111,'(6(1x,e12.6))') (ampl(n),n=1,NTR)

	if(nonetwo.eq.2) then
c	WRITE(111,*)
c      write(111,'(6(1x,e12.6))') (ampl(n),n=NTR+1,NTR2)
	endif

      call subCAS17(ampl,w,sx,NTR2)   
!c    if only 1 sourcem we defined NTR2=NTR above 
!c	input: amplitudes ampl and basis functions w
!c     output: seimogram sx 



	write(222,*)
	write(222,*) isour1,isour2
 	write(222,'(1x,e12.6,5x,i5)') dur, NTR 
	
      xmomtot1=0.
	do i=1,NTR ! source 1
	shf=shiftopt1 + float(i-1)*shiftbase
	xmom=ampl(i)      	 
	xmomtot1=xmomtot1+xmom	 
	write(222,'(i5,2(1x,e12.6))') i,shf,xmom
	enddo

	xmomtot2=0.
	if(nonetwo.eq.2) then
	xmomtot2=0.
	do i=NTR+1,NTR2 !source 2
	shf=shiftopt2 + float(i-NTR-1)*shiftbase  
	xmom=ampl(i) !*dur/2. (ne!)	 
	xmomtot2=xmomtot2+xmom	 
	write(222,'(i5,2(1x,e12.6))') i,shf,xmom
	enddo
	else            ! source 2 does not exist; will be added formally as zeros 
      shiftopt2=shiftopt1	
      NTRX=2*NTR	
	xmomtot2=0.
	do i=NTR+1,NTRX ! source 2 does not exist; will be added formally as zeros
	shf=shiftopt2 + float(i-NTR-1)*shiftbase  
	xmom=0. ! formal zero value 	 
	xmomtot2=xmomtot2+xmom	 
	write(222,'(i5,2(1x,e12.6))') i,shf,xmom
	enddo

	endif

c	write(111,*)
      
c	write(111,*) 'source_1 moment (Nm): ',xmomtot1
c	if(nonetwo.eq.2) then
c	write(111,*) 'source_2 moment (Nm): ',xmomtot2
c	endif
c	write(111,*) 'total moment (Nm): ',xmomtot1+xmomtot2	
	 
	
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
c          write(nfile,'(4(1x,e12.6))') time, 
c     *         finr(itim,ir,1), finr(itim,ir,2), finr(itim,ir,3)
          enddo
        enddo


!c
!c     COMPUTING L2 MISFIT (error2) DIRECTLY = computing L2 norm of final resi
!c

      error2=0.
      do icom=1,3
       do ir=1,nr
       if(stat(ir)) then
        do itim=1,ntim !ntim ! if changing ntim to 4000 do the same in manidata15_loop_two
c        error2=error2+ finr(itim,ir,icom)*finr(itim,ir,icom)

        error2=error2+ 
     *  (finr(itim,ir,icom)*weig(ir,icom))**2    ! new 25.10 2019 WEIGHTS included in VR

        enddo
       endif
       enddo
      enddo
      error2=error2*dt
      accumerr = error2 / rrori   ! normalization by power of ORI data
                                  ! (weights considered) 
      varred   = 1. - accumerr   ! variance reduction 
!c             ! for other measures of the misfit, see NORM.FOR

c      write(111,*) 
c      write(111,*) 'variance reduction (from the used stations only):'
c      write(111,*) 'varred=',varred
c      write(111,*) '======================================='
c      write(111,*)

      
      if(isour1.eq.isour2) then
	xmomtot1=0.
	xmomtot2=0.
	summom=0.
      ratmom=0.
	varred=0.
	else
	summom=xmomtot1+xmomtot2 
      if(xmomtot1.ne.0.) then
	ratmom=xmomtot2/xmomtot1
	else
	ratmom=0.
	endif

	endif

      write(111,'(2i5,4e12.5,f8.4)')
     *	 isour1,isour2,xmomtot1,xmomtot2,summom,ratmom,varred

  887	enddo ! loop over sour2
  888	enddo ! loop over sour1

 
      STOP


      END

!c =================================================================
!c      include "nnls.inc"
!c      include "nnls77.inc"
      include "nnls_kiku.inc" 
    
    
      include "manidata15_loop_two.inc" ! for NOT opening and writing ***fil.dat
      include "eleCAS15.inc"
!c      include "oneinv3.inc"
!c      include "cnsinv2.inc"
!c      include "fixinv2.inc"
      include "subCAS17.inc"
!c      include "lagra.inc"
!c      include "determi.inc"

c      include "fcoolr.inc"
      include "filter15.inc"
c      include "filterSYN.inc"

c      include "fw.inc"

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

