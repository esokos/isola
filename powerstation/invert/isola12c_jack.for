      program ISOLA12c

c     freq range is station dependent	!!!!!!!!!!!!!!

c      as isola12a, but more output into corr, and silsub with output of VOL>0 and <0

c      as isola11b, but with the distance weights (opposite than amplitude weights) 

c       simplified version - no repetitions
c       output of eigenvectors of GTG , SINGULAR values of G (sqrt of eigenvalues of GTG)

c     for jacknifing use
c     Thimios 25/03/2012 
c     pause is removed 




c     Multiple-point source inversion of  COMPLETE waveforms from 
c     r e g i o n a l   or    l o c a l  stations.
c     Iterative deconvolution, similar to Kikuchi and Kanamori (1991).
c     Green's functions by discrete wavenumber method of Bouchon (1981).
c     Moment tensor of subevents is found by least-square minimization
c     of misfit between observed and synthetic waveforms, while position
c     and time of subevents is found by maximization of correlation 
c     through grid search.
c     Possible modes of the moment tensor (MT) retrieval are as follows:
c     - full MT : DC+CLVD+VOL
c     - deviatoric MT  DC+CLVD; assuming VOL%=0 (=RECOMMENDED OPTION)
c     - constrained double-couple MT: assuming VOL%=CLVD%=0
c     - known and fixed 100% DC (only position and time is retrieved)


c     Author: J. Zahradnik 2003-2011


c       DIMENSION   ! if you want to increase dim for w(...), change
c                        ! also cnsinv2, fixinv2, oneinv2, oneinv2_vol, subevnt,subevnt_vol
c                        ! elemat2, eleonly,
c                        ! adding more stations requires
c                        ! also change of filenumbers in open(...)   



      CHARACTER *2 CHR(99)
      CHARACTER *1 reply
      CHARACTER *12 filename
      CHARACTER *5 statname(21)
c      CHARACTER *10 statfil1(21),statfil2(21),statfil3(21)
      character *17 statfil1,statfil2,statfil3  !!g77
      character *10  corrfile

      dimension xinv(8192,21,3)
      dimension ori(8192,21,3)
      dimension sx(8192,21,3)
      dimension syn(8192,21,3)
      dimension finr(8192,21,3)		 ! 21 = max number of stations
c      dimension sy(8192,21,3,15)      ! 15  = max number of subevents !!!!!!!!!!!!!! the only change is here
c      dimension sxsave(8192,21,3,99)  ! 99 = max number of trial source positions
      dimension w(-2500:10692,21,3,6)  !  6 = full moment, 5 = deviatoric only 
      dimension rold(6,6),rinv(6,6)
      dimension corr(100),ish(100),asave(6,100),aopt(6),vopt(6)
      dimension aoptsum(6)
      dimension twocorr(99,100)       ! 100 = max number of trial time shifts
      dimension twoshft(99,100)		! 99 = max number of trial source positions
	dimension twostr(99,100),twodip(99,100),tworak(99,100)
      dimension twostr2(99,100),twodip2(99,100),tworak2(99,100)
      dimension twodcper(99,100),twovolper(99,100),twomsft(99,100) !!!new march2012
	dimension twomom(99,100)                                     !!!new march2012
      dimension twoaaaa(99,100,6)
      dimension twovvvv(99,100,6)
      dimension twomoxx(99,100),twomoyy(99,100),twomozz(99,100)
      dimension twomoxy(99,100),twomoxz(99,100),twomoyz(99,100)
      dimension ibest(99),cbest(99),xmo(99),dcp(99)
	dimension abest(99,6),vara(99,6)
      dimension is1(99),id1(99),ir1(99)
      dimension is2(99),id2(99),ir2(99)
      dimension nuse(21)
      dimension ntm(21)
      dimension weig(21,3)
      dimension gold(6,6),en(6),vv(6,6)

      logical stat(21)   ! 21 = max. number stations


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



	do i1=-2500,10692 
	do i2=1,21
	do i3=1,3
	do i4=1,6
	w(i1,i2,i3,i4)=0.
	enddo
	enddo
	enddo
	enddo


      open(150,file='allstat.dat')   ! input: stations, weights,...
      open(151,file='inpinv.dat')    ! input: control parameters
      open(200,file='mechan.dat')    ! input: for fixed focal mechanism only
c     open(674,file='correl.dat')     ! 2d correlation (see later)
      open(222,file='inv1.dat',status='unknown')! output: all details
      open(898,file='inv2.dat')      !       : less details
      open(798,file='inv2c.dat')      !       : less details, summed subevents
      open(899,file='inv3.dat')      !       : moment tensor (for GMT)
      
      open(61,file='temp001.txt')    ! this will be used by matlab 
                                     ! to know that fortran stopped
      

c     FIXED OPTIONS
      ntim=8192 ! number of time samples  
      
	aopt(6)=0.
	vopt(6)=0.
      aoptsum(6)=0.
      
	ir=1
c  7   read(150,*,end=8) statname(ir),nuse(ir),	 ! weig is directly the weight, not 1./weight
c     *            weig(ir,1),weig(ir,2),weig(ir,3) ! weig=0 component not used

  7   read(150,*,end=8) statname(ir),nuse(ir),	 		! nuse=0 station not used
     *            weig(ir,1),weig(ir,2),weig(ir,3),       ! weig=0 component not used
     *            ff1(ir),ff2(ir),ff3(ir),ff4(ir)
          
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
      statfil1=trim(statname(ir))//'raw.dat'
      statfil2=trim(statname(ir))//'fil.dat'
      statfil3=trim(statname(ir))//'res.dat'
      open(numf1,file=statfil1)
      open(numf2,file=statfil2)
      open(numf3,file=statfil3)
      enddo


      do ir=1,nr
        do icom=1,3
c       weig(ir,icom)=(1./weig(ir,icom)) * vardat   ! this gives overflow
c        weig(ir,icom)=(1./weig(ir,icom)) ! removing this because weig is true weight now
        enddo
      enddo



      read(151,*) 
      read(151,*) keyinv
      read(151,*) 
      read(151,*) dt
      read(151,*) 
      read(151,*) isourmax
      read(151,*) 
      read(151,*) 
      read(151,*) ifirst,istep,ilast
      read(151,*) 
      read(151,*) isubmax
      read(151,*) 
      read(151,*) 
      read(151,*) f1,f2,f3,f4	  ! not used (read from allstat)
      read(151,*)
      read(151,*) vardat

	nmom=6
      if(keyinv.ne.1) nmom=5
	
	if(ifirst.lt.-2500.or.ilast.gt.2500) then
       write(*,*) 'limit of time shift exceeded; check ifirst, ilast'
       STOP
      endif 
      iseqm=(ilast-ifirst)/istep  ! number of tested time shifts
	if(iseqm.gt.100) then
       write(*,*) 'too many shifts requested; check ifirst,ilast,istep'
       STOP
      endif

c *******************************************************************
c ************ MANIPULATE OBSERVED DATA *****************************
c *******************************************************************

       call manidata_12c(ori,rrori)    ! manipulate OBSERVED data
c           input: read from file in the subroutine
c          output: ori=ori data filtered
c                  rrori=data power

      
c *******************************************************************
c *************LOOP OVER SUBEVENTS***********************************
C     (for each one, ALL possible source positions are tested)
c *******************************************************************
	
c      write(*,*) 
      ipause=0
c	write(*,*)'do you want interaction during search ?'
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

      call elemat2_12c(filename,w,rold,rinv)


c       !!! ATTENTION: rold comes * 1.e20; rinv comes / 1.e20 !!!

c           input: read from file in the subroutine
c          output: w=elem seismograms for a given source position
c                  rold=data matrix
c                  rinv=inverse matrix

c *************************************************************************
c **** FITTING DATA WITH A GIVEN SOURCE POSITION AND VARYING TIME SHIFT ***
c ************************************************************************


      if(keyinv.eq.1) call oneinv2_12c(xinv,w,rold,rinv,asave,corr,ish) ! nmom=6 
      if(keyinv.eq.2) call oneinv2_12c(xinv,w,rold,rinv,asave,corr,ish) ! nmom=5
      if(keyinv.eq.3) call cnsinv2_12c(xinv,w,rold,rinv,asave,corr,ish)
      if(keyinv.eq.4) call fixinv2_12c(xinv,w,rold,rinv,asave,corr,ish)


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
c	  twomsft(isour,i)=(1.-corr(i)**2)*rrori / vardat


        twoshft(isour,i)=float(ish(i))*dt

        do n=1,nmom
        twoaaaa(isour,i,n)=asave(n,i)
        twovvvv(isour,i,n)=sqrt(vardat * rinv(n,n)*1.e20) !  sigma =sqrt(var); corrected for formal 1.e20
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

      corrmax=0.
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


c ******************************************************************
c     calculating subevent seismo OF THE BEST SHIFT, for EACH source position
c      (better to calculate and save now (when w is known) than to search for
c            the best source and then have a need to find w again)
c ******************************************************************

c      call subevnt(aopt,w,ioptshf,sx)


c      do itim=1,ntim
c        do ir=1,nr
c          do icom=1,3
c          sxsave(itim,ir,icom,isour)=sx(itim,ir,icom)    ! saving sub for isour
c          enddo
c        enddo
c      enddo


  60  continue   ! end of LOOP over source positions


c ==============================================================
      corrfile='corr'//chr(isub)//'.dat'
      open(674,file=corrfile)
      write(674,*)
      write(674,*) '2D correlation for isub=',isub
      do isour=1,isourmax
        do iseq=1,iseqm
        write(674,'(1x,i5,2(1x,f9.4),5x,
     *            3(1x,f5.0),5x,3(1x,f5.0),2(1x,f7.2),2(1x,e12.6))') !!! new march2012
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
      if(ipause.eq.1) PAUSE

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



      cbestall=0.                  ! searching the best source position
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
      write(*,'(i4,2x,i4,2x,f8.4,2x,f5.2,2x,6i6)') isour,ibest(isour)
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
      vopt(n)=twovvvv(iselect,isequen,n)
      enddo

	
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

c        ---------start of -----NEW-----------------	Feb 2011

c we are already out of source loop , so we have to calculate w, sx

      filename='elemse'//chr(iselect)//'.dat'

      call elemat2_12c(filename,w,rold,rinv)  ! analyzing system matrix for the best position (independent of time shift) 
	                                    ! iselect and w correspond to the best position


      do im=1,nmom
      do jm=1,nmom
      gold(im,jm)=rold(im,jm)	  ! rold comes multiplied by 1e20
      enddo
      enddo

  	     

	call JACOBInr(gold,nmom,6,en,vv,nrot) ! 6 is dimension, cannot be nmom
	do im=1,nmom			  ! converting eigenvalues of GTG into sing. values of G
c             ! introducing (a constant) data variance, vardat, here is the same as to divide GTG by vardat  
	en(im)=sqrt(en(im)/vardat)/1.e10 ! sqrt to get SING values; corrected for previous formal 1.e20
    	enddo
  
	open(6789,file='vect.dat')	! vectors will be printed in columns
	do im=1,nmom
	write(6789,'(6e15.6)') (vv(im,jm),jm=1,nmom) ! im...comp, jm... vector
	enddo
	close(6789)

	open(7789,file='sing.dat')	! sing values (inlcuding vardat), succession as the vectors
	write(7789,'(6e15.6)') (en(jm),jm=1,nmom) 
 	close(7789)

      eigmin=1.e30
      eigmax=1.e-30
      do im=1,nmom
      if(abs(en(im)).lt.eigmin) eigmin=abs(en(im))
      if(abs(en(im)).gt.eigmax) eigmax=abs(en(im))
      enddo
      eigrat=eigmin/eigmax
      write(*,*)
      write(*,*) 'SING. values, inlcuding vardat (min., max, min/max):'
      write(*,*)  eigmin,eigmax,eigrat


c      call subevnt(aopt,w,ioptshf,sx)	! seismo sx for optimum position and for optimum time shift ioptshf 
c      do itim=1,ntim
c        do ir=1,nr
c          do icom=1,3
c          sxsave(itim,ir,icom,iselect)=sx(itim,ir,icom)  ! saving seismo
c          enddo
c        enddo
c      enddo

c        ------------end of -------NEW---------------
 
      call silsub(aopt,str1,dip1,rake1,str2,dip2,rake2,amoment,dcperc,
     * 	        avol)

      call pl2pt(str1,dip1,rake1,azp,ainp,azt,aint,azb,ainb	  ! JZ Feb26,2011
	*,ierr)

      write(222,*)
      write(222,*) 'Selected source position for subevent #',isub       ! JZ Feb5, 2012 Best --> selected (due to possible interaction) 
      write(222,*) 'isour,ishift',iselect,ioptshf
      write(222,*)
      write(222,*) 'SINGULAR values, incl. vardat (min., max, max/min)'
      write(222,*)  eigmin,eigmax,1./eigrat
      write(222,*)
c      write(222,*)
c      write(222,*) 'all SINGULAR values, incl. vardat:'
c      write(222,*)  (en(jm),jm=1,nmom)
c      write(222,*)

      write(222,*) 'Inversion result:'
      write(222,*) 'coefficients of elem.seismograms a(1),a(2),...a(6):'
      write(222,'(6(1x,e12.6))') (aopt(n),n=1,6)
      write(222,*) 'and their sigma_a(1), sigma_a(2),... sigma_a(6):'
      write(222,'(6(1x,e12.6))') (vopt(n),n=1,6)

      write(222,*)
      write(222,*) 'moment (Nm):', amoment
c       xmommag=0.67*log10(amoment) - 6. ! Hanks & Kanamori (1979)
       xmommag=(2.0/3.0)*log10(amoment) - 6.0333 
       ! Hanks&Kanamori(1979) !thimios
       
      write(222,'(a20,f6.1)') 'moment magnitude:', xmommag
c	write(222,*) 'MT decomposition (eq. 8 of Vavrycuk, JGR 2001):'	
      write(222,'(a20,f6.1)') 'VOL % :', avol
	write(222,'(a20,f6.1)') 'DC % :', dcperc
	write(222,'(a20,f6.1)') 'abs(CLVD) % :', 100.-abs(avol)-dcperc  ! instead avol should be abs(avol), see silsub.inc
      write(222,*)'strike,dip,rake:',ifix(str1),ifix(dip1),ifix(rake1)
      write(222,*)'strike,dip,rake:',ifix(str2),ifix(dip2),ifix(rake2)
      write(222,*)'P-axis azimuth and plunge:', ifix(azp),ifix(ainp)
	write(222,*)'T-axis azimuth and plunge:', ifix(azt),ifix(aint)
	write(222,*)'B-axis azimuth and plunge:', ifix(azb),ifix(ainb)
	write(222,*)


C************************************************************************
c    subevent seismo for the best soure position and time shift 
C************************************************************************

      call subevnt_12c(aopt,w,ioptshf,sx)	! seismo sx for optimum position and for optimum time shift ioptshf 


 
c      do icom=1,3
c        do ir=1,nr
c          do itim=1,ntim                  ! sx defined above (call subevnt)
c         sx(itim,ir,icom)= sxsave(itim,ir,icom,iselect)	 ! Jiri Apr 10, 2011
c          sy(itim,ir,icom,isub)=sx(itim,ir,icom)  ! save subevnt seismo         (never used)
c          enddo
c        enddo
c      enddo


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
      postvar=error2/float(3*nr*ntim)  ! a posteriori data variance
c             ! good meaning only if all nr stations and points ntim were used
      accumerr = error2 / rrori   ! normalization by power of ORI data
c                                 ! (used stations only, no weights considered) 
      varred   = 1. - accumerr   ! variance reduction 
c             ! accumerr and varred consider only the used stations
c             ! (both in error2 and in rrori, assuming ntim=8192)
c             ! for other measures of the misfit, see NORM.FOR


      write(222,*) 'After subtraction of subevent #',isub
      write(222,*) 'variance reduction (from the used stations only):'
      write(222,*) 'varred=',varred
c     write(222,*) 'postvar =',postvar
      write(222,*) '======================================='
      write(222,*)

      call pl2pt(str1,dip1,rake1,azp,ainp,azt,aint,azb,ainb
	*,ierr)

 
      write(898,
     *   '(1x,i5,1x,f6.2,1x,e12.6,12(1x,f6.0),1x,f6.1,1x,e12.4)')
     *           iselect,ioptshf*dt,amoment,str1,dip1,rake1,
     *           str2,dip2,rake2,azp,ainp,azt,aint,azb,ainb,
     *           dcperc,varred

	amin=min(abs(amorr),abs(amott),abs(amopp),
     *         abs(amort),abs(amorp),abs(amotp))
      ia=ifix(log10(amin))
      amorr=amorr/10**float(ia)
      amott=amott/10**float(ia)
      amopp=amopp/10**float(ia)
      amort=amort/10**float(ia)
      amorp=amorp/10**float(ia)
      amotp=amotp/10**float(ia)
       write(899,89)
     * iselect,ioptshf,
     * amorr,ia,amott,ia,amopp,ia,amort,ia,amorp,ia,amotp,ia
   89 FORMAT (2(1x,i5),3x,6(f20.4,'e+',i2.2)) 
     
      do i=1,nmom
      aoptsum(i)=aoptsum(i) + aopt(i)	 ! summary MT
      enddo

      call silsub(aoptsum,str1s,dip1s,rake1s,str2s,dip2s,rake2s,
     *                                      amoments,dcpercs,avol)

      call pl2pt(str1s,dip1s,rake1s,azps,ainps,azts,aints,azbs,ainbs
	*,ierr)

c      write(798,
c     *  '(1x,i5,1x,f6.2,1x,e12.6,12(1x,f6.0),1x,f6.1,1x,e12.4)')
c     *     iselect,ioptshf*dt,amoments,str1s,dip1s,rake1s,
c     *     str2s,dip2s,rake2s,azps,ainps,azts,aints,azbs,ainbs,
c     *     dcpercs, varred

      xmommags=(2.0/3.0)*log10(amoments) - 6.0333 	 ! summary Mw ! Jiri Apr10, 2011
      write(798,						
     *  '(1x,i5,1x,f6.2,1x,e12.6,1x,f6.2,12(1x,f6.0),1x,f6.1,1x,e12.4)')
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
          do itim=1,ntim
          time=float(itim-1)* dt
          write(nfile,'(4(1x,e12.6))') time,
     *         finr(itim,ir,1), finr(itim,ir,2), finr(itim,ir,3)
          enddo
        enddo

	write(*,*) 
	write(*,*) 'The following files were created:'
	write(*,*) 'INV1.DAT, INV2.DAT, INV2c.DAT, INV3.DAT'
	write(*,*) 'CORR01.DAT, ... (for all subevents)'
      write(*,*) '*FIL.DAT, *RES.DAT, ... (for all stations)'

	 write(61,*) '1'   ! signal end of code to Matlab
	 close(61)


	
      STOP


      END

c =================================================================

      include "manidata_12c.inc"
      include "elemat2_12c.inc"
      include "oneinv2_12c.inc"
      include "cnsinv2_12c.inc"
      include "fixinv2_12c.inc"
      include "subevnt_12c.inc"
      include "lagra.inc"
      include "determi.inc"

      include "fcoolr.inc"
      include "filter.inc"
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
c      include "ptaxes.inc"
      include "pl2pt.inc"

