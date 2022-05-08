      program time_fixed18

c NON_STANDARD (for GRL paper Sichuan) to use SS subevent form teh PAIR ss+tf
	  
c 2018: Weight of the moment constraint is better treated
c The changes with respect to time_fixed15 made in Feb. 2017: 
c 1) New calling of NNLS
c 2) Number of triangles 2x12 increased to 2x60
c 3) subCAS17
c 4) not solved how to prescribe NTR; it is fixed NTR=60
c  ... if changed to NTR=12 should work as the time_loop_two15 (if it runs due to dim) 
c (no need to go back to old calling of nnls!!)

c CAUTION::::::::::: EXE code may not run (too large)
c In case of a problem, decrease NTR and dimensions (also in subCAS17)
	  
!     Simultaneously inverting for moment coefficients of NTR triangles per source.
!     Allowed are 2 sources (each one with its OWN position, MT and basic time shift).
!     Each source consists of NTR (max NTR=60) triangles of equal duration
!     and eqaul mutual shift; their amplitudes (=moments) are sought for.
!     The recommended shifts= expected duration / 60 (or larger, not to miss later episodes).
  
!     Author: J. Zahradnik 2011, 2012, 2017

      parameter (nhsrc=120) ! maximum number of elem functions; formerly 2x12, now 2x60
c        nhsrc cannot! be simply changes here; it is also in subCAS17
      parameter (nhdat=21*3*8192+1) ! max length of data column (1 = for moment); formerly 516097
c      parameter (nhsta=21) ! cannot! be simply changed here

      CHARACTER *2 CHR(99)
c      CHARACTER *1 reply
      CHARACTER *12 filename1,filename2
c     CHARACTER *3 statname(21)
      CHARACTER *5 statname(21) ! 21 = max. number of stations
      character *17 statfil1,statfil2,statfil3  !!g77
c      character *10  corrfile


      dimension aopt1(6),aopt2(6) ! 6 here refers to the number of MT components!!!!!!!!!!!!!!!!!

      dimension seismo(-6000:8192,21,3) !         ??????? bude stacit posun 1000 dt??????????????????????????????????????
      dimension xinv(8192,21,3)
      dimension  ori(8192,21,3)
      dimension   sx(8192,21,3)
c      dimension syn(8192,21,3)
      dimension finr(8192,21,3)		 ! 21 = max number of stations

      dimension nuse(21)
      dimension ntm(21)
      dimension weig(21,3)
      dimension keygps(21)

cc      dimension w(8192,21,3,24)  
      dimension w(8192,21,3,nhsrc)  !!!!!     see also subCAS17  !!!!!

ccc      Dim. for tinv, nnls version f.90
c      double precision rnorm,ama(516097,24),bve(516097),ampl(24),wnn(24)
c      integer mode,numdat 

! dim 2x12= 24 is also in subCAS15 !!!!!!!
!     dimense 516097 is number of stations 21 x nomber of comp.  3 * number of times  8192 PLUS 1 (na momentovou podminku)

 
ccc     Dim. for nnls_kiku (single precision F77 code taken from Kikuchi's mom3)
c This is strongly PREFERRED
      dimension ama(nhdat,nhsrc),bve(nhdat),ampl(nhsrc)
      dimension wnn(nhsrc),zz(nhdat),indx(nhsrc)
c      dimension bve2(nhdat)
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
	
	
	
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

      write(*,*) 'CAUTION: This is NON-STANDARD (see 510)'	
	
!     FIXED OPTIONS
      ntim=8192 ! number of time samples  
      nmom=6	  ! check whether nmom is used, I tried not to use it at all (it goes to subroutines via common)

c	write(*,*) 'ONE source (1), or TWO (2)?'
c	read(*,*) nonetwo
      read(154,*) nonetwo
      write(111,*) 'ONE source (1), or TWO (2)=',nonetwo
	

c	write(*,*) 'number of triangles per a source (max 60)= ?'
c	read(*,*) ntr
      ntr=60	 !!!!!!!! FIXED !!!!FORMERLY = 12 !!!!!!!
      write(111,*) 'number of triangles per a source= ',ntr
      
	    
	NTR2=NTR
	if (nonetwo.eq.2) NTR2=NTR*2
c      write(*,*) 'NTR2= ',NTR2     


	ir=1
  7   read(150,*,end=8) statname(ir),nuse(ir),	 		! nuse=0 station not used
     *            weig(ir,1),weig(ir,2),weig(ir,3),       ! weig=0 component not used
     *            ff1(ir),ff2(ir),ff3(ir),ff4(ir)
     

       if(nuse(ir).eq.0) then
       weig(ir,1)=0;  weig(ir,2)=0; weig(ir,3)=0 ! No need to care about weig if nuse()=0; 
       endif
	   
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

      do ir=1,nr               !!!!!!!!!1.2.2015
	keygps(ir)=0.
	enddo


      do ir=1,nr
      numf1=1000+(ir*1)
      numf2=2000+(ir*1)
      numf3=3000+(ir*1)
      statfil1=trim(statname(ir))//'raw.dat'  !!! new Patras, July 2012
      statfil2=trim(statname(ir))//'fil.dat'
c      statfil3=trim(statname(ir))//'res.dat'
      open(numf1,file=statfil1)
      open(numf2,file=statfil2)
c      open(numf3,file=statfil3)
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
      write(111,*) 'SUB2: str, dip, rake: ',str1, dip1, rake1
	write(111,*)  '(no meaning for pure volume component)' 
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
      write(111,*) 'optshift1 (integer multiple of dt): ',shiftopt1

      if(nonetwo.eq.2) then
c	write(*,*) 'optimum source_2 shift (in sec)=?'
c 	read(*,*) shiftopt2
      read(154,*) shiftopt2
	ishf2=ifix(shiftopt2/dt) ! basic shift
	write(111,*) 'optshift2 (integer multiple of dt): ',shiftopt2
	endif

c	write(*,*) 'duration of elem triangle in sec (from GREEN)=?'
c 	read(*,*) dur
 	read(154,*) dur
      write(111,*) 'duration of elem triangle in sec = ', dur

! Code calculates an optimum superposition of 12 shifted functions.
! Each function represents a complete synthetic seismogram of a unit-moment point sources (1 or 2),
! involving a given focal mechanism, a given elementary time function and a given filter
! [all these as they were used in the Inversion tool]. All stations are used as prescribed 
! in allstat.dat.
! Code does not need to know whether the elementary time function was delta or triangle.
! Output of this code presents the result in form of weights of the individual shifted 
! elementary time functions. FOR PLOTTING (only) the code assumes that the elementary 
! time function is TRIANGLE (non-filtered), having duration 'Dur.   
! In other words, the numerical results do not depend on 'dur', but they do depend
! on the elementary time function chosen when calculating Green or making Inversion.
      
c	write(*,*) 'triangles distance in sec (same for src1 and 2)=?'
c	read(*,*) shiftbase
	read(154,*) shiftbase
      nshf=ifix(shiftbase/dt) ! vyjadrena v poctu cas. kroku
      write(111,*) 'distance (shift) of triangles in sec = ', shiftbase
	write(111,*) 'Time shift rounded to integer multiple of dt!'

c     write(*,*) 'constraining moments (0=no, 1=yes):'
c	read(*,*) keymomcns
      read(154,*) keymomcns
      write(111,*) 'constraining moments (0=no, 1=yes)', keymomcns

      if(keymomcns.eq.1) then

      if(nonetwo.eq.2) then
c        Caxe of 2 sources
      read(154,*) xmomreq1
 	write(111,*) 'requested SUB1 moment in Nm = ', xmomreq1
      read(154,*) xmomreq2							
	write(111,*) 'requested SUB2 moment in Nm = ', xmomreq2
 	xmomreq12=xmomreq1+xmomreq2 !!!! new 29.7.2015
	write(111,*) 'requested TOTAL moment in Nm = ', xmomreq12
      else
c        Case of 1 source
	read(154,*) xmomreq1 
      xmomreq12=xmomreq1+ 0. !REMOVED+xmomreq2 !new 29.7.2015						 
	write(111,*) 'requested SUB1 moment in Nm = ', xmomreq1
	write(111,*) 'requested TOTAL moment in Nm = ', xmomreq12

      endif
	
      endif
! *******************************************************************
! ************ MANIPULATE OBSERVED DATA *****************************
! *******************************************************************

       call manidata15(keygps,ori,rrori)    ! manipulate OBSERVED data
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
 	 bve(j)=xinv(itim,ir,icom)	* weig(ir,icom) ! * 1.e10 (former analogy with isola; not needed here)
    	 
c        ! This multiplication comes from ISOLA, G ~ 1e-19, G*1e10 ~ 1.e-9
c        ! When in ISOLA we multiplied matrix by 1.e10, we had to multiply also the data column
c        ! and exactly this remained here for data column. 
c ! It was critical in ISOLA when using GTG ~ 1e-38, too bad, here it remian but is not needed           
C The reason for multiplication here is NOT to have data column and matrix of the same order
c DATA CAN BE for example 1E-1, MATRIX 1E-20, NO PROBLEM; MOMENT WILL BE 1E19 AS SHOULD BE							 
 
       enddo
       enddo
  		  endif
       enddo

      if(keymomcns.eq.1) then

c Fixing always total moment Mo (sub1, or sub1+sub2 sub, not separately the sub1 and sub2 )
c We can add last row Mo to data column and last row 1, 1, 1... to the matrix.
c Alternatively we can add 1 to data column and 1/Mo, 1/Mo, 1/Mo ... to the  matrix
c Here we  myltiply data column by const, and make last row of matrix const/Mo. const/Mo. ... 
c The const should be 2 to 5 orders higher than maximum of data column; this is default.
c If const < bvemax * 1.e2, moment will not be constrained well, inversion similar to unconstrained. 
c If const > bvemax * 1.e5, the constraint is too strong, inversion of time function failes.
c These 'limits' may vary from problem to problem. 
      bvecnst= bvemax * 1.e4  ! default
      write(*,*) 'Default weight of the moment constr.= ', bvecnst
	  write(*,*) 'Weight should be ~ 4 orders higher than max of data' ! 2 to 5 orders higher
      write(*,*) 'Users weight: default multiplied by ? (e.g. 1.) = '
	  read (*,*) usermult  
	  bvecnst = bvecnst * usermult  
      write(*,*) 'Final choice of the moment weight = ', bvecnst
   
      j=j+1			  
      bve(j)= bvecnst

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
       call elecas15(keygps,filename1,aopt1,ishf1,seismo)
C Complete (unit-moment) seismogram for point source,
C using a given position, mechanism and an elementary time function.
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
c	itshift=ifix(float(it-1)*shiftbase/dt)    ! NEW Aug 3, 2015 

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

      amamax=maxval(w)
      write(*,*) 'max. value of G matrix= ',amamax	  

	if(nonetwo.eq.2) then
       filename2='elemse'//chr(isour2)//'.dat'
       call elecas15(keygps,filename2,aopt2,ishf2,seismo)
      do it=NTR+1,NTR2  
      do ir=1,nr          
      do icom=1,3
      do itim=1,ntim   
      itshift=(it-NTR-1)*nshf   !  
c      itshift=ifix(float(it-NTR-1)*shiftbase/dt) ! NEW Aug 3, 2015  
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

c	 ama(j,it)=w(itim,ir,icom,it)  ! *1.e10	 ! this is the matrix G (d=Gm), not GTG !
	 ama(j,it)=w(itim,ir,icom,it) * weig(ir,icom) ! *1.e10	 
c    ! The multiplication by 1.e10 came formerly from ISOLA where it was needed.
c    ! It was critical in ISOLA when using G ~ 1e-19 [or smaller], then  GTG ~ 1.e-38, too bad..., 
c    ! We know that w ~ G ~ is 'often'  ~ 1e-19 ... or1e-23, 
c    ! because we are working with UNIT moment elementary MT's, so the size of G does not
c    ! depend on data (it is only affected by freq. range and distances)
       enddo
       enddo
            endif 
       enddo


c Fixing moment (see description where bve is defined above)
c      added a row to constrain moment 

      if(keymomcns.eq.1) then


       j=j+1
       ama(j,it)=(1./ xmomreq12) * bvecnst    
c !!CAUTION the constant here (after (1./ xmomreq12) ) must be the same as in last data column bve 
       endif

c      endif

     	numdat=j
c        write(*,*) 'numdat= ',numdat
    	enddo

c  Printing matrix    
c	do j=1,numdat
c	write(555,'(12(1x,e12.6))') (ama(j,n),n=1,NTR2)
c	enddo

c OLD calling of NNLS
c	call tinv(ama,bve,ampl,mode,rnorm,numdat,NTR2)
c CAUTION !!!! tinv is calling NNLS; 

c       write(*,*) numdat,ntr2
	   
cccc The following is strongly PREFERRED:
      call nnls_kiku
     * (ama,nhdat,NUMDAT,NTR2,bve,ampl,rnorm,wnn,zz,indx,mode)
c caution: vector bve will be RE-WRITTEN (cannot be used second time)

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
      
      call subCAS17(ampl,w,sx,60) !!!!!!!!!!!!!!!!!!!caution   
c      call subCAS17(ampl,w,sx,NTR2)   
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
c	shf=ifix((shiftopt1 + float(i-1)*shiftbase)/dt)*dt	  ! NEW Aug 3, 2015 (asi zbytecne)
	xmom=ampl(i)      	 ! ampl je spravne;  bazove seismo maji stejne troj a jenotkovy moment
	xmomtot1=xmomtot1+xmom	 ! take v kreslicim programu jsou troj s jednotk. momentem; 'ampl' je moment; vaha jednotkovych momentuu
	write(222,'(i5,2(1x,e12.6))') i,shf,xmom
	enddo

	if(nonetwo.eq.2) then
	xmomtot2=0.
	do i=NTR+1,NTR2 !source 2
	shf=shiftopt2 + float(i-NTR-1)*shiftbase  ! POZOR (i-6)
c	shf=ifix((shiftopt2 + float(i-NTR-1)*shiftbase)/dt)*dt  ! NEW Aug 3, 2015 (asi zbytecne)
	xmom=ampl(i) !*dur/2. (ne!)	 
	xmomtot2=xmomtot2+xmom	 
	write(222,'(i5,2(1x,e12.6))') i,shf,xmom
	enddo
	else            ! source 2 does not exist; will be added formally as zeros
      shiftopt2=shiftopt1 !formally made eqaul
      NTRX=2*NTR	
	xmomtot2=0.
	do i=NTR+1,NTRX ! source 2 does not exist; will be added formally as zeros
	shf=shiftopt2 + float(i-NTR-1)*shiftbase  ! POZOR (i-6)
c	shf=ifix((shiftopt2 + float(i-NTR-1)*shiftbase)/dt)*dt  ! NEW Aug 3, 2015 (asi zbytecne)
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
      statfil3=trim(statname(ir))//'res.dat'
      open(nfile,file=statfil3)
          do itim=1,ntim
          time=float(itim-1)* dt  ! output of residual seimo *res.dat
          write(nfile,'(4(1x,e12.6))') time, 
     *         finr(itim,ir,1), finr(itim,ir,2), finr(itim,ir,3)
          enddo
      close(nfile)  
        enddo


!c
!c     COMPUTING L2 MISFIT (error2) DIRECTLY = computing L2 norm of final resi
!c

      error2=0.
      do icom=1,3
       do ir=1,nr
       if(stat(ir)) then
        do itim=1,ntim !For ACRE can change ntim here to 4000 and in manidata15
c        error2=error2+ finr(itim,ir,icom)*finr(itim,ir,icom)

        error2=error2+ 
     *  (finr(itim,ir,icom)*weig(ir,icom))**2    ! new 25.10.2019 WEIGHTS included in VR

        enddo
       endif
       enddo
      enddo
      error2=error2*dt
      accumerr = error2 / rrori   ! normalization by power of ORI data
                                  ! (weights considered)
      varred   = 1. - accumerr   ! variance reduction 
!c             ! for other measures of the misfit, see NORM.FOR


      write(111,*) 
      write(111,*) 'variance reduction (from the used stations only):'
      write(111,*) 'varred=',varred
c	  write(111,*) 'for correct VR, see inv4.dat'
      write(111,*) '======================================='
      write(111,*)

      STOP


      END

!c =================================================================
!c      include "nnls.inc"
!c      include "nnls77.inc"
      include "nnls_kiku.inc" 
      
      include "manidata15.inc"
      include "eleCAS15.inc"
!c      include "oneinv3.inc"
!c      include "cnsinv2.inc"
!c      include "fixinv2.inc"
      include "subCAS17.inc"
!c      include "lagra.inc"
!c      include "determi.inc"

C      include "fcoolr.inc"
c      include "filter.inc"
       include "filter15.inc"

C      include "fw.inc"

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

