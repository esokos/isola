      

      module mconst
	  integer, parameter :: NBO=1024 ! NBO = max number of *raw.dat samples per comp.
c     !     CAUTION: must be unified with ELEMSE (in Green) !!!!!!!!!!
	  integer, parameter :: NBS=21 ! NBS = max number of stations for cova with NN,EE,ZZ or micex NE, NZ...
c	  integer, parameter :: NBS=17 ! NBS = max number of stations for mixed-comp cova (former limit no more exists due to allocate)
	  integer, parameter :: NMUL1= NBO*NBS*3
c	  integer, parameter :: mind=(NBO**2)*3*NBS ! only NN,EE,ZZ; no need to restrict like that       
	  integer, parameter :: mind=(NBO**2)*9*NBS ! also inter-component NE, NZ, etc allowed thanks ALLOCATE     
      endmodule                                      ! (later checked if large enough) 
	  
      module numwei
	  integer  nr,ntim,nmom,isubmax,ifirst,istep,ilast,keycova
	  real     dt 
	  real, allocatable :: 
     *                     ff1(:),ff2(:),ff3(:),ff4(:),
     *	                   weig(:,:)
      endmodule
	  
	  module mcov
	  real, allocatable :: cdinv(:,:) ! double dot to define type of array (e.g. 2D)
	  endmodule                            ! true dimension later in 'allocate'

	  module mcovsparse
	  integer, allocatable :: ja(:),ia(:)
      real, allocatable    :: acsr(:)	  
	  endmodule
	  
	  
      program ISOLA_cova

c MUST be compiled in Ifort ( -Qmkl) or Gfort, NOT in Powerstation (contains MKL lib)
c must contain 'stream' in 'open' for binary files	  
c Full Cd is implemented in sparse form, and USED (not skipped)
c 1024 points
c No interaction

c     Author: J. Zahradnik 2019, 2023	  
	  
c Allocation (analogy of common)
	  
      use mconst    
	  use numwei    
      use mcov
      use mcovsparse	  
	  
      CHARACTER *2 CHR(99) ! increase to 999 for THREE=DIGIT elemse***.dat, ALSO in elemse code!
      CHARACTER *1 reply
      CHARACTER *12 filename
      CHARACTER *5 statname(NBS)
      character *17 statfil1,statfil2,statfil3  
      character *10  corrfile

	    
      dimension xinv(NBO,NBS,3)
      dimension ori(NBO,NBS,3)
      dimension sx(NBO,NBS,3)
      dimension syn(NBO,NBS,3)
      dimension finr(NBO,NBS,3)		 
      dimension w(NBO,NBS,3,6)  !  6 = number of MT components 
c new treatment of shift in w, see oneinv, no need of extended dimensions

c      dimension sy(NBO,NBS,3,15)       
c total numb. of subevents (e.g. 15) is not limited by dimensions

      dimension rold(6,6),rinv(6,6),aopt(6),vopt(6),aoptsum(6)
      dimension corr(100),ish(100),asave(6,100) ! 100 = max number of trial time shifts
      dimension twocorr(99,100)     ! 99 = max number of trial source positions  
      dimension twoshft(99,100)		
c! limit 99 is substantial for keeping elemse filenames with 2 digits: e.g. elemse01, not elemse001	  
	  dimension twostr(99,100),twodip(99,100),tworak(99,100)
      dimension twostr2(99,100),twodip2(99,100),tworak2(99,100)
      dimension twodcper(99,100),twovolper(99,100),twomsft(99,100) 
	  dimension twomom(99,100)                                     
      dimension twoaaaa(99,100,6)
      dimension twomoxx(99,100),twomoyy(99,100),twomozz(99,100)
      dimension twomoxy(99,100),twomoxz(99,100),twomoyz(99,100)
      dimension ibest(99),cbest(99),xmo(99),dcp(99)
	  dimension abest(99,6)
      dimension is1(99),id1(99),ir1(99)
      dimension is2(99),id2(99),ir2(99)
      dimension nuse(NBS)
      dimension ntm(NBS)
      dimension cdinvdiag(NMUL1)
      
      dimension gold(6,6),en(6),vv(6,6),    corcof(6,6)
      dimension vardat(NBS) ! for simplified versions 

      dimension job(8) ! = max. number of elements of sparse Cd-1
c     dimension irowind(mind),icolind(mind),acoo(mind) ! OLD: static COO arrays
      integer,allocatable :: irowind(:),icolind(:)   ! NEW: static=>allocatable COO arrays
	  real,allocatable :: acoo(:)                    ! NEW: static=>allocatable COO arrays
      double precision iaa,aaa

	  allocate (ff1(NBS),ff2(NBS),ff3(NBS),ff4(NBS),
     *	       weig(NBS,3))
      allocate (ja(mind),ia(mind),acsr(mind))
	  allocate (irowind(mind),icolind(mind),acoo(mind)) ! NEW: static=>allocatable COO arrays
c     allocate (cdinv(NMUL1,NMUL1))  ! it was only for debug (4 stations only)
      allocate (cdinv(1,1)) ! for the 'very old' version (without Cd)  
	  
      open(150,file='allstat.dat')   ! input: stations, weights,...
      open(151,file='inpinv.dat')    ! input: control parameters
      open(200,file='mechan.dat')    ! input: for fixed focal mechanism only

c     open(674,file='correl.dat')     ! 2d correlation (see later)
      open(222,file='inv1.dat',status='unknown')! output: all details
      open(898,file='inv2.dat')      !       : less details
      open(798,file='inv2c.dat')      !       : less details, summed subevents
      open(899,file='inv3.dat')      !       : moment tensor (for GMT)
      open(1030,file='inv5.dat')      ! diagonal of Cdinv
      open(300,file='sigma.dat')     ! Cm (if more subevents, all are in the same file) ????  
      open(400,file='sigma_all.dat')
      open(61,file='temp001.txt')    ! this will be used by matlab GUI
                                     ! to know that fortran code has stopped      
      
      write(*,*)
	  write(*,*) 'This is ISOLA_cova, version 2024b (allocate)'
	  write(*,*)

	  
		
      do i=1,99
	  write (chr(i),'(i2.2)') i  ! This is write into "internal file"
	  enddo                      ! format i2.2  makes e.g. 3 to be 03 
 
c!      FIXED OPTION
      ntim=NBO ! number of time samples set at maximum DIMENSION  
c !!!!!!!!!!!!!!! CAUTION: Must be consistent with ELEMSE (in Green)    !!!!!!!!!!!!
      
	  aopt(6)=0.
	  vopt(6)=0.
      aoptsum(6)=0.
      w=0.  ! Zeroing all 'w' array

  
	  ir=1
  7   read(150,*,end=8) statname(ir),nuse(ir),	 		! nuse=0 station not used
     *            weig(ir,1),weig(ir,2),weig(ir,3),       ! weig=0 component not used
     *            ff1(ir),ff2(ir),ff3(ir),ff4(ir)   
          
      if(nuse(ir).eq.0) then
       weig(ir,1)=0;  weig(ir,2)=0; weig(ir,3)=0 ! No need to care about stat; all info is in weig
	  endif
	  ntm(ir)=ntim+1    
      ir=ir+1
      if(ir.gt.NBS) goto 8
      goto 7
  8    nr=ir-1
      write(*,*) 'number of stations (max NBS), nr=', nr
      numdiag=nr*1024*3     
      write(*,*) 'number of diagonal terms', numdiag
	  write(*,*) 'stations used in the inversion:'
      do ir=1,nr
      if(nuse(ir).ne.0) write(*,*) statname(ir)      
      enddo
	  close(150)
	 

      do ir=1,nr
      numf1=1000+(ir*1)
      numf2=2000+(ir*1)
c      numf3=3000+(ir*1)
      statfil1=trim(statname(ir))//'raw.dat'
      statfil2=trim(statname(ir))//'fil.dat'
c      statfil3=trim(statname(ir))//'res.dat'
      open(numf1,file=statfil1)
      open(numf2,file=statfil2)
c      open(numf3,file=statfil3)
      enddo


      read(151,*) 
      read(151,*) keyinv
      read(151,*) 
      read(151,*) dt
      read(151,*) 
      read(151,*) isourmax
      read(151,*) 
      read(151,*) 

      read(151,*) ibegin,istep,ilast
      ifirst=ibegin-istep

      read(151,*) 
      read(151,*) isubmax
      read(151,*) 
      read(151,*) 
      read(151,*) f1,f2,f3,f4	  ! not used (they are read from allstat)
      read(151,*)
      read(151,*) vardat(1) ! used in the simplest version; should have order ~1.0e-12, squared data ampl.
	  close(151)

c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c                        Reading Cdinv from a file

      open(210,form='unformatted',file='hinv.bin', access='stream')      ! input: Cd-1 sparse in COO (from my matlab code)
	  ir=1
 71    read(210,end=81) aaa! binary sequential reading DOUBLE   
      ir=ir+1
      if(ir-1.gt.3*mind) then
      write(*,*) 'Problem DIM. sparse matrix'
      STOP
      endif	  
      goto 71	  
 81   nonz3=ir-1
      nonz=nonz3/3 
      write(*,*) 'number of non-zero elements of Cdinv= ',nonz  ! number of elements of COO matrix       
      close(210); rewind(210)

   
      open(210,form='unformatted',file='hinv.bin', access='stream')      ! input: Cd-1 sparse in COO (from my matlab code)
	  do i=1,nonz      
      read(210) iaa ! binary sequential  
      irowind(i)=sngl(iaa)
      enddo  
      do i=nonz+1,2*nonz      
      read(210) iaa ! binary sequential  
      icolind(i-nonz)=sngl(iaa)
      enddo        	  
      do i=2*nonz+1,3*nonz      
      read(210) aaa! binary sequential  
      acoo(i-2*nonz)=sngl(aaa)
      enddo 
      write (*,*) 'wait!'	  
      close (210)

c      do i=1,4000      
c	  write(290,'(2i10,5x,e15.7)') irowind(i),icolind(i),acoo(i)
c      enddo 	  

      ir=1
      do i=1,nonz      
      if(irowind(i).eq.ir.and.icolind(i).eq.ir) then
	  cdinvdiag(ir)=acoo(i)
      ir=ir+1
      endif
      enddo 	  
 
c      do i=1,numdiag 
c      write(1027,'(i10,5x,e15.7)') i,cdinvdiag(i)
c      enddo 	  

c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


	  
      keycova=0	  
c	  write(*,*) 'Running with or without Cd (1 or 0)?'
c      read(*,*)  keycova
      keycova=1 !!!!!!!! DOCASNE
	  write(*,*) 'keycova= ', keycova 	  

      if(keycova.eq.1) goto 1656 ! go to new version	
c   DIFFERENCES between NEW and OLD versions are
c   only  here, then on lines 600+, then in elemat, in oneinv and in cnsinv. 
c   pozor na open(100...) v elemat: ifort and gnuplot tam potrebuje access='stream'

c  !!!!! Prakticke::::::Pokud se jeste vsude zaceckuje mkl_, da se 'very old' prelozit Powerstat TRX
c  !!!!! Ale pozor, jeste se musi v elemat udelat open(100 ...) bez access='stream' 
		
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	  
cccc           VERY OLD VERSION - without Cd  

        do ir=1,nr
		vardat(ir)=vardat(1) ! read above; should have order ~1.0e-12, same as real data squared
        enddo
        goto 1657 ! skip new version

cccc      OLD VERSION - Cd defined here as a non-constant diagonal, not sparse  
c    for debug [4 stations only!] Cdinv is defined HERE 
c    simple definition of (possibly) station-dependent diagonal Cd
c        vardat(1)= 2.e-12;vardat(2)= 2.e-12;vardat(3)= 2.e-12
c        vardat(4)= 2.e-12  
c        nsz=ntim*nr*3
c        nsz2=ntim*3
c	    cdinv=0.
c       do ir=1,nr
c	   j=(ir-1)*nsz2   !    VTIP: inverze je proste deleni (pro kazdou stanici ovsem zvlast)
c       do i = 1,nsz2; cdinv(j+i,j+i)=1./vardat(ir); enddo  
c       enddo
c       do i=1,nsz
c      write(602,'(18f3.1)') (cdinv(i,j),j=1,nsz) 
c	   enddo		
c      stop	  
ccc POZOR pokud bych chtel ZDE tvorit rovnou sparse tak je to jednoduche
ccc bud z maincov4_trivial.m 
ccc ci pro pripad ciste (nekonst) diagonalni Cd. Pak CDINV ve sparse  tvaru COO vypada:
ccc        1 1 hodnota
ccc        2 2 hodnota
ccc ....
ccc        nonz nonz hodnota, kde hodnota = 1/vardat(dane stanice), 
c       goto 1657 ! skip new version
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc	  
cc               NEW VERSION (sparse)
cc       input of Cd-1 SPARSE in COO format
cc    (from Matlab preprocessing in my code maincov4.m) 

 1656 continue

       nsz=ntim*nr*3
      nsz2=ntim*3
	  
	  job=0
	  job(1)=1 ! matrix A from COO (acoo) to CSR (acsr)
	  job(2)=1 ! one-based indexing for matrix in CSR
	  job(3)=1 ! one-based indexing for matrix in COO
      job(5)=  nonz ! see above max number of nonzero 
      job(6)=0 ! all arrays acsr, ja, ia are filled-in for the output storage
      !    ja ... so-called 'columns' array in SCR
      !    ia ... so-called 'rowIndex' array in SCR
  	  
      call mkl_scsrcoo(job, nsz, acsr, ja, ia, nonz, 
     *                 acoo,irowind, icolind, info)

c	  write(*,*) 'info= ',info
c	  write(*,*) 'acoo(1)= ',acoo(1)
	  if(info.ne.0) then
	  write(*,*) 'Problem with sparse matrix'
	  STOP
      endif	

c      do i=1,4000 !nonz
c      write(1025,*) ia(i), ja(i),acsr(i)
c      enddo 	  
c   Now ACSR, JA and IA constitute the sparse Cd-1 (=cdinv) in CSR format
 

 
ccc    for debug: (to pro pripad ze chci v elemat, oneinv a cnsinv pouzit OLD version)
c       cdinv=0.
c       do ir=1,nr
c	   j=(ir-1)*nsz2
c       do i = 1,nsz2; cdinv(j+i,j+i)=acoo(1); enddo  
c       enddo
  
        goto 1657 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

 1657 continue
      nmom=6
      if(keyinv.ne.1) nmom=5
	
c	if(ifirst.lt.-3500.or.ilast.gt.3500) then
c       write(*,*) 'limit of time shift exceeded; check ifirst, ilast'
c       STOP
c      endif 

      iseqm=(ilast-ifirst)/istep  ! number of tested time shifts
	if(iseqm.gt.100) then
       write(*,*) 'too many shifts requested; check ifirst,ilast,istep'
       STOP
      endif

c *******************************************************************
c ************ MANIPULATE OBSERVED DATA *****************************
c *******************************************************************


       call manidata_play(ori,rrori)    ! manipulate OBSERVED data

c           input: read from file in the subroutine
c          output: ori=ori data filtered
c                  rrori=data power

      
c *******************************************************************
c *************LOOP OVER SUBEVENTS***********************************
C     (for each one, ALL possible source positions are tested)
c *******************************************************************
	
      write(*,*) 
      ipause=0
c      write(*,*)'do you want interaction during search ?'
c      write(*,*)'please answer y or n (lowercase !):'
c      read(*,*) reply
c      if(reply.eq.'y') ipause=1
      


      do icom=1,3
        do ir=1,nr
          do itim=1,ntim
          syn(itim,ir,icom)=0. ! inicialization
          enddo
        enddo
      enddo


      isub=0       ! counting subevents
   30 isub=isub+1  ! LOOP ever subevents ends at 50
   10 continue    

      write(*,*)
      write(*,*) 'searching subevent #',isub
      write(*,*)


      if(isub.eq.1) then
      do icom=1,3
        do ir=1,nr
          do itim=1,ntim
          xinv(itim,ir,icom)=ori(itim,ir,icom)
          enddo
        enddo
      enddo
	else
      do icom=1,3
        do ir=1,nr
          do itim=1,ntim
          xinv(itim,ir,icom)=finr(itim,ir,icom)
          enddo
        enddo
      enddo
      endif

c *******************************************************************
c ************ LOOP OVER SOURCE POSITIONS ***************************
c *******************************************************************

      do 60 isour=1,isourmax

c *******************************************************************
c *************MANIPULATING elemse DATA and system matrix**********
c *******************************************************************

      filename='elemse'//chr(isour)//'.dat'

      call elemat_play(filename,w,rold,rinv)


c       !!! ATTENTION: rold comes * 1.e20; rinv comes / 1.e20 !!!

c           input: read from file in the subroutine
c          output: w=elem seismograms for a given source position
c                  rold=data matrix
c                  rinv=inverse matrix

c        Output of covariance matrix of parameters (Cm = (Gt Cd-1 G)-1 ) which is rinv
c        For all trial sources 
      if(keycova.eq.1) goto 2658 ! go to new version 
	  rinv=rinv*vardat(1)		 
 2658 CONTINUE 
      if(isub.eq.1) then
      write(400,*) 'trial position no. ', isour      
      if (nmom.eq.5) nskip=11;
      if (nmom.eq.6) nskip=12;
      do i = 1,nskip; write(400,*); enddo ! 11 ci  12 prazdnych radku aby bylo jako driv
      write(400,*) ' Covariance matrix; NOT corrected for  scaling'
      do i=1,nmom	  
      write(400,'(6e15.6)') (rinv(i,j),j=1,nmom) 
      enddo		 
      endif  
      if(keycova.eq.0) rinv=rinv/vardat(1)
	  
c *************************************************************************
c **** FITTING DATA WITH A GIVEN SOURCE POSITION AND VARYING TIME SHIFT ***
c ************************************************************************


      if(keyinv.eq.1)
     *	  call oneinv_play(xinv,w,rinv,asave,corr,ish) ! nmom=6 
      if(keyinv.eq.2)
     *	  call oneinv_play(xinv,w,rinv,asave,corr,ish) ! nmom=5
      if(keyinv.eq.3)
     *	  call cnsinv_play(xinv,w,rinv,asave,corr,ish)
      if(keyinv.eq.4)
     *	  call fixinv_play(xinv,w,rinv,asave,corr,ish)


c           action: 'one inversion'; fitting xinv data by a single subevent
c                   right hand side formed from xinv data and elemse (green)
c                   elemse data for each source used repeatedly with
c                                         several time shifts
c                   1 source position = 1 Green (elemse w); 1 RINV inv. matrix
c                   each time shift of w = its own right-hand side and solution
c           input: xinv=data to be inverted for a set of time shifts
c                  w =elem seis
c                  rold =system matrix
c                  rinv =inverse  matrix
c          output: asave=moment tensor coefficients (array for all shifts)
c                  corr= correlation (array for all shifts)
c                  ish=shifts (array of integer shifts for all shift steps)


       do i=1,iseqm                 ! saving correlation and shift values
        twocorr(isour,i)=corr(i)
        twomsft(isour,i)=(1.-corr(i)**2)*rrori    !!!!!!new march2012
        twoshft(isour,i)=float(ish(i))*dt

        do n=1,nmom
        twoaaaa(isour,i,n)=asave(n,i)
        aopt(n)=asave(n,i)
        enddo
        call silsub(aopt,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
     * avol)


        twostr(isour,i)=str1
        twodip(isour,i)=dip1
        tworak(isour,i)=rake1
        twostr2(isour,i)=str2
        twodip2(isour,i)=dip2
        tworak2(isour,i)=rake2
        twodcper(isour,i)=dcperc
        twovolper(isour,i)=avol !!!!!new march2012
	    twomom(isour,i)=amoment

         twomoxx(isour,i)=-1.*asave(4,i)+asave(6,i)     !saving moment tensors
         twomoyy(isour,i)=-1.*asave(5,i)+asave(6,i)
         twomozz(isour,i)=    asave(4,i) + asave(5,i) +asave(6,i)
         twomoxy(isour,i)=    asave(1,i)
         twomoxz(isour,i)=    asave(2,i)
         twomoyz(isour,i)=-1.*asave(3,i)
       enddo

c *******************************************************************
c ***INSPECTING RESULTS OF THE SHIFT LOOP (SEARCHING SHIFT WITH OPT. CORR.)
c               SAVING THOSE OF THE BEST CORRELATION                               for a given source position
c *******************************************************************

      corrmax=-100.    ! 0. changed to -100: 31.12.2013
      do i=1,iseqm
        if(corr(i).gt.corrmax) then
         irecall=i        ! sequential number of the best shift (1,2,...iseqm)
         ioptshf=ish(i)      ! best value of 'ishift' (in time steps, not in sec)
         corrmax=corr(i)  ! best value of correlation
        endif
      enddo
      do n=1,6
      aopt(n)=asave(n,irecall)  ! a's for optimum shift
      enddo

                              ! saving results for the best correlation
                              ! (for each source position)

      call silsub(aopt,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
     *  avol)
      xmo(isour)=amoment
	  dcp(isour)=dcperc	  ! zde mozno DOCASNE mit dcp(isour)=avol 
      is1(isour)=ifix(str1)
      id1(isour)=ifix(dip1)
      ir1(isour)=ifix(rake1)
      is2(isour)=ifix(str2)
      id2(isour)=ifix(dip2)
      ir2(isour)=ifix(rake2)

      ibest(isour)=ioptshf
      cbest(isour)=corrmax
      do n=1,nmom
      abest(isour,n)=aopt(n)
      enddo



  60  continue   ! end of LOOP over source positions


c ==============================================================
      corrfile='corr'//chr(isub)//'.dat'
      open(674,file=corrfile)
      write(674,*)
      write(674,*) '2D correlation for isub=',isub
      do isour=1,isourmax
        do iseq=1,iseqm
        write(674,'(1x,i5,2(1x,f9.4),5x,
     *            3(1x,f5.0),5x,3(1x,f5.0),2(1x,f7.2),2(1x,e12.5))') !!! new march2012
     *      isour,twoshft(isour,iseq),twocorr(isour,iseq),
     *      twostr(isour,iseq),twodip(isour,iseq),tworak(isour,iseq),
     *   twostr2(isour,iseq),twodip2(isour,iseq),tworak2(isour,iseq),
     *   twodcper(isour,iseq),twovolper(isour,iseq), !!! new march2012
     *   twomsft(isour,iseq), twomom(isour,iseq) 	   !!! new march2012
        enddo
      enddo
      CLOSE (674) ! to enable checking the file during pause 
                  ! it also needs the above open(674
      write(*,*) 'During pause you may check file CORRxx.DAT'
c     if(ipause.eq.1) PAUSE
	  if(ipause.eq.1) read *  ! PAUSE substituted by read * (for gfortran)

      write(222,*) 'All trial positions and shifts for subevent#',isub
      write(222,*)'(isour = source position,ishift*dt=time shift)'
      write(222,*)'isour,ishift,corr,moment,DC%,str,dip,rak,str,dip,rak'
      do isour=1,isourmax
      write(222,'(2x,i4,2x,i5,2x,f10.6,2x,e15.4,2x,f8.3,2x,i5,
     *2x,i5,2x,i5,2x,i5,2x,i5,2x,i5)')isour,ibest(isour),
     *cbest(isour),xmo(isour),dcp(isour),
     *is1(isour),id1(isour),ir1(isour),
     *is2(isour),id2(isour),ir2(isour)
      enddo


c *******************************************************************
c ************ SEARCHING THE BEST SOURCE POSITION********************
c *******************************************************************



      cbestall=-100. ! changed 31.12.2013                  ! searching the best source position
      do isour=1,isourmax          ! AUTOMATIC
       if(cbest(isour).gt.cbestall) then
          cbestall=cbest(isour)
          iselect=isour       ! optimum position
       endif
      enddo

      ioptshf=ibest(iselect)	! optimum time shift


c                             A possibility to MANUALLY change
c                             the selected source position 'iselect'
c

      write(*,*) 'Trial source positions and shifts for subevent #',isub
      write(*,*)'(position #, shift (multiples of dt), correl., DC%)'
      write(*,*)'(strike1, dip1, rake 1   and  strike2, dip2, rake2)'

      do isour=1,isourmax 
      write(*,'(i4,2x,i4,2x,f7.4,2x,f6.2,2x,6i6)') isour,ibest(isour)
     *,cbest(isour),dcp(isour),is1(isour),id1(isour),ir1(isour),
     *                         is2(isour),id2(isour),ir2(isour)
      enddo
      write(*,*) 'automatic search suggests trial source #',iselect

      if(ipause.eq.0) goto 654

      write(*,*)'do you agree with this automatic search ?'
      write(*,*)'please answer y or n (lowercase !):'
      read(*,*) reply
      if(reply.eq.'n') then
       write(*,*) 'set your preferred trial source #'
       read(*,*)  iselect		! optimum position
       write(*,*) 'set your preferred time shift'
       write(*,*) '(as an integer multiple of dt)'
       read(*,*)  ioptshf
       goto 654				! optimum time shift
      endif
      if(reply.ne.'y') then
      write(*,*) 'reply was neither y nor n (lowercase), STOP'
       STOP
      endif

 654  continue

      isequen=(ioptshf-ifirst)/istep

      do n=1,nmom
      aopt(n)=twoaaaa(iselect,isequen,n)
c      vopt(n)=twovvvv(iselect,isequen,n)
      enddo

c	do n=1,nmom          ! Patras 22.6.2009 pokus 
c      aopt(n)=aopt(n)*0.25	 !  MODIF umele snizeni momentu pro VSECHNY SUB !!!
c      enddo
	
      amoxx=-1.*aopt(4)+aopt(6)
      amoyy=-1.*aopt(5)+aopt(6)
      amozz=aopt(4)+aopt(5)+aopt(6)
      amoxy=aopt(1)
      amoxz=aopt(2)
      amoyz=-1.*aopt(3)

      amott=amoxx   !t=theta, p=phi (delta), r=r
      amopp=amoyy
      amorr=amozz
      amotp=-1.*amoxy
      amort=amoxz
      amorp=-1.*amoyz

      write(*,*) 'Results for subevent #',isub
      write(*,*) 'trial source position #',iselect
      write(*,*) 'time shift (multiple of dt)',ioptshf
      call silsub(aopt,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
     *            avol)
      write(*,*) 'strike,dip,rake',ifix(str1),ifix(dip1),ifix(rake1)
      write(*,*) 'strike,dip,rake',ifix(str2),ifix(dip2),ifix(rake2)

c        ---------start of -----NEW-----------------

c       !!!!!for best-fit position  only


      filename='elemse'//chr(iselect)//'.dat'

      call elemat_play(filename,w,rold,rinv)  

c        Output of covariance matrix of parameters (Cm = (Gt Cd-1 G)-1 ) which is rinv

      if(keycova.eq.1) goto 1658 ! go to new version 
ccc   In the 'very old' version, rinv=(GT G)-1, thus Cm = vardat(1) * rinv
	  rinv=rinv*vardat(1)		 

 1658 CONTINUE 
 
      if (nmom.eq.5) nskip=11;
	  if (nmom.eq.6) nskip=12;
	  
      do i = 1,nskip; write(300,*); enddo ! 11 ci  12 prazdnych radku aby bylo jako driv
 
      write(300,*) ' Covariance matrix; NOT corrected for  scaling'
c      do i=1,nmom
c      do j=1,nmom
c      rinv(i,j)=rinv(i,j)*1e20
c      enddo
c      enddo
      do i=1,nmom	  
      write(300,'(6e15.6)') (rinv(i,j),j=1,nmom) ! covariance not corrected for scaling 1.e20
      enddo		 

c	  do i=1,nmom; vopt(i)=sqrt(rinv(i,i)*1.e20); enddo !variances corrected for scaling
	  do i=1,nmom; vopt(i)=sqrt(rinv(i,i))*1.e10; enddo !variances corrected for scaling

c     Pearson's correlation coefficient

      write(300,*)
	  write(300,*)   'Pearson-s correlation coefficient'
	  do i=1,nmom	 ! cykl pres slozky
      do k=1,nmom	 ! cykl pres slozky
      corcof(i,k)=rinv(i,k)/sqrt(rinv(i,i)*rinv(k,k))
	  enddo
      write(300,'(6e15.6)') (corcof(i,k),k=1,nmom) ! 
      enddo
      write(300,*)
c      close(300) ! need to still have open (for more subevents)										
										
										
      do im=1,nmom
      do jm=1,nmom
      gold(im,jm)=rold(im,jm)	  ! rold comes multiplied by 1e20
      enddo
      enddo

  	     

	  call JACOBInr(gold,nmom,6,en,vv,nrot) ! 6 is dimension, cannot be nmom

      if(keycov.eq.1) then        ! NEW _ TO BE CHECKED !!!!!!
	  do im=1,nmom			  ! converting eigenvalues of GTG into sing. values of G
c	  en(im)=sqrt(en(im)/vardat)/1.e10 ! sqrt to get SING values; corrected for former scaling 1.e20
	  en(im)=sqrt(en(im))/1.e10 ! NEW ; vardat is in cova matrix gold 
      enddo
	  else
	  do im=1,nmom			  ! converting eigenvalues of GTG into sing. values of G
	  en(im)=sqrt(en(im)/vardat(1))/1.e10  
c	  en(im)=sqrt(en(im))/1.e10 
      enddo
      endif 


  
c	open(6789,file='vect.dat')	! vectors will be printed in columns
c	do im=1,nmom
c	write(6789,'(6e15.6)') (vv(im,jm),jm=1,nmom) ! im...comp, jm... vector
c	enddo
c	close(6789)

c	open(7789,file='sing.dat')	! sing values (inlcuding vardat), succession as the vectors
c	write(7789,'(6e15.6)') (en(jm),jm=1,nmom) 
c 	close(7789)

      eigmin=1.e30
      eigmax=1.e-30
      do im=1,nmom
      if(abs(en(im)).lt.eigmin) eigmin=abs(en(im))
      if(abs(en(im)).gt.eigmax) eigmax=abs(en(im))
      enddo
      eigrat=eigmax/eigmin
      write(*,*)
      write(*,*) 'SING. values (min, max, max/min=CN):'
      write(*,*)  eigmin,eigmax,eigrat




c        ------------end of -------NEW---------------
 
c      call silsub(aopt,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
c     * 	        avol)

	 call silsub2(aopt,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
     * 	        avol,aclvd) ! JZ new sep 2017

      call pl2pt(str1,dip1,rake1,azp,ainp,azt,aint,azb,ainb	  ! JZ Feb26,2011
     * ,ierr)

      write(222,*)
      write(222,*) 'Selected source position for subevent #',isub       ! JZ Feb5, 2012 Best --> selected (due to possible interaction) 
      write(222,*) 'isour,ishift',iselect,ioptshf
      write(222,*)
      write(222,*) 'SINGULAR values, incl. vardat (min, max, max/min)'
      write(222,*)  eigmin,eigmax,eigrat
      write(222,*)
c      write(222,*)
c      write(222,*) 'all SINGULAR values, incl. vardat:'
c      write(222,*)  (en(jm),jm=1,nmom)
c      write(222,*)

      write(222,*) 'Inversion result:'
      write(222,*) 'coefficients of elem.seismograms a(1),a(2),...a(6):'
      write(222,'(6(1x,e12.5))') (aopt(n),n=1,6)
      write(222,*) 'and their sigma_a(1), sigma_a(2),... sigma_a(6):'
      write(222,'(6(1x,e12.5))') (vopt(n),n=1,6)

      write(222,*)
      write(222,*) 'moment (Nm):', amoment
c       xmommag=0.67*log10(amoment) - 6. ! Hanks & Kanamori (1979)
       xmommag=(2.0/3.0)*log10(amoment) - 6.0333 
       ! Hanks&Kanamori(1979) !thimios
       
      write(222,'(a20,f6.1)') 'moment magnitude:', xmommag
c	write(222,*) 'MT decomposition (eq. 8 of Vavrycuk, JGR 2001):'	
      write(222,'(a20,f6.1)') 'VOL % :', avol
	write(222,'(a20,f6.1)') 'DC % :', dcperc
c	write(222,'(a20,f6.1)') 'abs(CLVD) % :', 100.-abs(avol)-dcperc  ! instead avol should be abs(avol), see silsub.inc
	write(222,'(a20,f6.1)') 'CLVD % :', aclvd ! new JZ Sep2017

	write(222,*)'strike,dip,rake:',ifix(str1),ifix(dip1),ifix(rake1)
      write(222,*)'strike,dip,rake:',ifix(str2),ifix(dip2),ifix(rake2)
      write(222,*)'P-axis azimuth and plunge:', ifix(azp),ifix(ainp)
	write(222,*)'T-axis azimuth and plunge:', ifix(azt),ifix(aint)
	write(222,*)'B-axis azimuth and plunge:', ifix(azb),ifix(ainb)
	write(222,*)


C************************************************************************
c    subevent seismo for the best soure position and time shift 
C************************************************************************

      call subevnt_play(aopt,w,ioptshf,sx)	! seismo sx for optimum position and for optimum time shift ioptshf 

************************************************************************
** SYNTH SEIMOGRAM BEING SUMNED UP FROM SUBEVENTS 
************************************************************************

 

      do icom=1,3
        do ir=1,nr
          do itim=1,ntim
          syn(itim,ir,icom)= syn(itim,ir,icom) + sx(itim,ir,icom)
          enddo
        enddo
      enddo

      do icom=1,3
        do ir=1,nr
          do itim=1,ntim
          finr(itim,ir,icom)=  ori(itim,ir,icom) - syn(itim,ir,icom)
          enddo            
        enddo
      enddo


c
c     COMPUTING L2 MISFIT (error2) DIRECTLY = computing L2 norm of final resi
c

      error2=0.
      error3=0.
	  inddiag=0

       do ir=1,nr
      do icom=1,3      ! different order of the loops because of using scalar array cdinvdiag ordered like this
         do itim=1,ntim 
        error2=error2+ 
     *  (finr(itim,ir,icom)*weig(ir,icom))**2    ! new 9.9.2015 WEIGHTS included in VR
      inddiag=inddiag+1
        error3=error3+ 
     *  (finr(itim,ir,icom)*weig(ir,icom))**2 * cdinvdiag(inddiag)    
c      write(1028,'(4i10,5x,e15.7)') 
c     *    	  itim, icom, ir, inddiag,cdinvdiag(inddiag)        
        enddo
       enddo
      enddo
      error2=error2*dt
	  error3=error3*dt

      postvar=error2/float(3*nr*ntim)  ! a posteriori data variance
c             ! good meaning only if all nr stations and points ntim were used
      
	accumerr = error2 / rrori   ! normalization by power of ORI data
	                            ! vecause it is ACCUMULATED error
	
                  ! rrori (from manidata.inc) includes weights ! new 9.9. 2015  
c                 ! (weights considered = VR refers to used components only) 
      varred   = 1. - accumerr   ! variance reduction 
c             ! accumerr and varred consider only the used components
c             ! (both in error2 and in rrori, assuming ntim)
c             ! for other measures of the misfit, see NORM.FOR


      write(222,*) 'After subtraction of subevent #',isub
      write(222,*) 'weighted variance reduction (used components only):'
      write(222,*) 'varred=',varred
c     write(222,*) 'postvar =',postvar
      write(222,*) '======================================='
      write(222,*)
c      write(222,*) 'misfit with Cdinv=', error3 
      write(1030,'(e15.7)') error3 

      call pl2pt(str1,dip1,rake1,azp,ainp,azt,aint,azb,ainb
     *,ierr)

 
      write(898,
     *   '(1x,i5,1x,f6.2,1x,e12.5,12(1x,f6.0),1x,f6.1,1x,e12.5)')
     *           iselect,ioptshf*dt,amoment,str1,dip1,rake1,
     *           str2,dip2,rake2,azp,ainp,azt,aint,azb,ainb,
     *           dcperc,varred

	   amin=min(abs(amorr),abs(amott),abs(amopp),
     *         abs(amort),abs(amorp),abs(amotp))
	  if(amin.lt.1e-3) write(*,*) 'WARNING check inv3.dat; amin= ',amin
	  if(amin.lt.1e-3) amin=1e14 ! NEW To substitute amin=0;  just for normalization in inv3 

       ib=ifix(log10(amin))
       amorr=amorr/10**float(ib)
       amott=amott/10**float(ib)
       amopp=amopp/10**float(ib)
       amort=amort/10**float(ib)
       amorp=amorp/10**float(ib)
       amotp=amotp/10**float(ib)
       write(899,89)
     * iselect,ioptshf,
     * amorr,ib,amott,ib,amopp,ib,amort,ib,amorp,ib,amotp,ib
   89 FORMAT (2(1x,i5),3x,6(f20.4,'e+',i2.2)) 
     
      do i=1,nmom
      aoptsum(i)=aoptsum(i) + aopt(i)	 ! summary MT
      enddo

      call silsub(aoptsum,str1s,dip1s,rake1s,str2s,dip2s,rake2s,
     *                                      amoments,dcpercs,avol)

      call pl2pt(str1s,dip1s,rake1s,azps,ainps,azts,aints,azbs,ainbs
     *,ierr)

c      write(798,
c     *  '(1x,i5,1x,f6.2,1x,e12.5,12(1x,f6.0),1x,f6.1,1x,e12.5)')
c     *     iselect,ioptshf*dt,amoments,str1s,dip1s,rake1s,
c     *     str2s,dip2s,rake2s,azps,ainps,azts,aints,azbs,ainbs,
c     *     dcpercs, varred

      xmommags=(2.0/3.0)*log10(amoments) - 6.0333 	 ! summary Mw ! Jiri Apr10, 2011
      write(798,						
     *  '(1x,i5,1x,f6.2,1x,e12.5,1x,f6.2,12(1x,f6.0),1x,f6.1,1x,e12.5)')
     *     iselect,ioptshf*dt,amoments,xmommags,str1s,dip1s,rake1s,
     *     str2s,dip2s,rake2s,azps,ainps,azts,aints,azbs,ainbs,
     *     dcpercs, varred


      if(isub.ge.isubmax) goto 50
      goto 30

   50 continue                        ! end of LOOP over subevents

c***************************************************************************
c** SAVING FINAL RESIDUAL SEISMOGRAM (final = after subtract all subevents)
c***************************************************************************


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

	write(*,*) 
	write(*,*) 'The following files were created:'
	write(*,*) 'INV1.DAT, INV2.DAT, INV2c.DAT, INV3.DAT'
	write(*,*) 'CORR01.DAT, ... (for all subevents)'
      write(*,*) '*FIL.DAT, *RES.DAT, ... (for all stations)'
      write(*,*) 'Isola ended'
      write(*,*) 

         write(61,*) '1'   ! signal end of code to Matlab
         close(61)
	  
      STOP


      END

c =================================================================
      
	  
      include "manidata_play.inc"
      include "elemat_play.inc"
      include "oneinv_play.inc"
      include "cnsinv_play.inc"
      include "fixinv_play.inc"
      include "subevnt_play.inc"
      include "filter_play.inc"
	  
	  include "lagra.inc"
      include "determi.inc"
	  
      include "silsub.inc"
      include "silsub2.inc"	  
      
	  include "jacobi.inc"
      include "line.inc"
      include "ang.inc"
      include "angles.inc"
      include "lubksb.inc"
      include "ludcmp.inc"
      include "zbrac.inc"
      include "rtbis.inc"
      include "jacobinr.inc"
      include "pl2pt.inc"