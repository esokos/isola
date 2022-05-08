      program NEWASPO9

c Always compile with maximum speed optimization
	  
c Inversion of envelope/ampl.sp. by grid search over s/d/r angles
c and also over trial source positions.

c The tested GS points (i.e. s/d/r angles) are prescribed
c either by the s/d/r limits and increments, or as a suite
c of s/d/r solutions which were found previously by matching 
c polarities (e.g. in FOCMEC).

c The code is tightly related to ISOLA. It is useful
c to start processing the event in standard ISOLA [or ISOLA-CSPS].
c Stations and components are selected as in ISOLA.
c Observed data is the instr. corrcted velocity (*raw.dat).
c Data are filtered (station dependent) and integrated to displacement.
c The displ. is converted into envelope/amp.sp. (*fil.dat).
c Synthetics = moment tensor (varying), convolved with 1D GF by DW method.
c Output is numeric listing of the GS results
c and the best-fitting envelope/amp.sp. (*syn.dat).

c Program flowchart
c Obs. data processed in MANIOBS, envelope/amp.sp. output (*fil.dat).      
c    Loop over trial source positions
c    Reading elementary seismograms for a given source by ELESYN, saving in an array
c         Nested loops over s/d/r
c         Observed data normalized (per station) 
c         Syn seismo (by convolving MT with elemse) by GENACKA, SUBEVNT15
c         Syn envelope/ampl. spectrum by PREPSYN 
c         Syn data normalized (per station, per depth, per tested focal mechanism)
c         Cross-correlating syn envelopes with obs envelopes to find best lag - per station
c         NOT Calculating moment (by analytic least-squares solution)
c         Error function (L2 misfit or variance reduction) for each s/d/r on NORM obs, syn
c         Output of all solutions of the s/d/r GS
c         Finding the best s/d/r per source position
c    Selection (manual) of the best source position and s/d/r
c    Syn seismo calculated for the best s/d/r at the chosen source position, using unit Mo
c    True moment Mo calculated using NON-normalized obs data and unit-moment syn data 
c    Envelope/ampl.sp. calculated for the best s/d/r at the chosen source, output (*syn.dat) 
c         
c REMARK:
c Next step is to complement the inversion by polarity check
c (This step is not needed if the code used s/d/r values previously checked for polarity agreement)
c Another step may inlcude calculation and plotting synth. SEISMOGRAMS
c for the best source position and s/d/r. 
 
c Authors: Fortran: Jiri Zahradnik, 2016-2017; inlcuded in Matlab GUI by E. Sokos, May 2017

c REFERENCE: 
c Zahradnik, J., and E. Sokos (2017): Waveform Envelope Inversion - A New Tool of ISOLA Software.
c Seismological Research Letters, submitted.


      
      CHARACTER *2 CHR(99)
      CHARACTER *12 filename
      CHARACTER *5 statname(21)
      character *17 statfil1,statfil2,statfil3  !!g77
c      character *100 text(27)
	
      dimension aox(8192,21),aoy(8192,21),aoz(8192,21)
      dimension asx(8192,21),asy(8192,21),asz(8192,21)
      dimension sx(8192,21,3)
      dimension  x(8192,21,3)
      dimension y1(8192,21,3),y2(8192,21,3)
c      dimension smx(8192),smy(8192),smz(8192)
      dimension identif(10000,3) ! 10000 max number of points in GS over s/d/r
      dimension afix(6)
      dimension w(-3500:11692,21,3,6)   
      dimension wax(21),way(21),waz(21)  
      dimension  error(10000), error2(10000) !  3-comp error /per all stations
c      dimension lagopt(10000),corropt(10000)
      dimension lgxopt(10000,25,21),ccxopt(10000,25,21) ! 25 = max tested depths
      dimension lgyopt(10000,25,21),ccyopt(10000,25,21)
      dimension lgzopt(10000,25,21),cczopt(10000,25,21)
      dimension ilagx(21),ilagy(21),ilagz(21)
      dimension nuse(21)
      dimension ntm(21),keygps(21)
      dimension weig(21,3)
      dimension omax(21),smax(21)
c      dimension dp(15) ! 15=max number of tested depths
c      Depths (needed for inv1.dat plot) are taken from the GUI!
	  
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

      
      write(*,*)
	  write(*,*) 'This is NEWaspo9'
	  write(*,*)

      eps=0.001 ! ... 'effective zero'
	  do i1=-3500,11692 
	  do i2=1,21
	  do i3=1,3
	  do i4=1,6
	  w(i1,i2,i3,i4)=0.
	  enddo
	  enddo
	  enddo
	  enddo


      open(150,file='allstat.dat')   ! input: stations, weights,...
      open(151,file='inp.dat')    ! input: control parameters
      open(152,file='sdr.dat')    ! input: control parameters

      open(894,file='ilags.dat')
c      open(895,file='inv1_base.dat')
c      open(896,file='out0_inv2.dat')
c      open(897,file='out0_inv1.dat')
      open(896,file='inv2_save.dat') ! caution: opt solution is not necessarily on line 1
      open(897,file='inv1.dat')

      open(898,file='out1_save.dat')      !  all GS solutions
      open(899,file='out2.dat')      !  opt GS solutions (1 per source)
      open(900,file='out3.dat')      ! opt GS solution (1 per all sources)
      
c     do jj=1,27
c     read(895,'(a100)') text(jj)
c     enddo
c     close (895)

      write(897,*) 'Best solution from NEWASPO'
      write(897,*) 'Can be plotted as inv1.dat'
      write(897,*) 'isour,GSpoint#,corr,nil,DC%,s,d,r,s2,d2,r2'

	  
c     FIXED OPTIONS
      ntim=8192 ! number of time samples  
	  nmom=6
      pi=3.1415927

c**************************************************************
c     Reading stations, weights, frequency ranges (ALLSTAT.DAT)
c**************************************************************
 
	  ir=1
  7   read(150,*,end=8) statname(ir),nuse(ir),	 		
     *            weig(ir,1),weig(ir,2),weig(ir,3),       
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
	  close(150)

       do ir=1,nr          ! (an old feature; not used, but keep it formally)    
	   keygps(ir)=0.	   
       enddo

       do ir=1,nr              
       if(weig(ir,1).eq.0.and.weig(ir,2).eq.0.and.weig(ir,3).eq.0) then
       nuse(ir)=0
       endif
       enddo
       
       do ir=1,nr              
	   if(nuse(ir).eq.0) then          !!!!!!!!!
       weig(ir,1)=0.      
       weig(ir,2)=0.      
       weig(ir,3)=0.
       endif
c       write(*,*) ir,nuse(ir)
c       write(*,*) ir,weig(ir,1),weig(ir,2),weig(ir,3)
       enddo
       
      do ir=1,nr
      numf1=1000+(ir*1)
      numf2=2000+(ir*1)
      numf3=3000+(ir*1)
      statfil1=trim(statname(ir))//'raw.dat' ! obs velocity record
      statfil2=trim(statname(ir))//'fil.dat' ! obs envelope/amp.sp. from filtered displ
      statfil3=trim(statname(ir))//'syn.dat' ! syn envelope/amp.sp. from filtered displ
      open(numf1,file=statfil1)
      open(numf2,file=statfil2)
      open(numf3,file=statfil3)
      enddo

      sumwax=0. ! sum of weights
      do ir=1,nr     
      wax(ir)=weig(ir,1) 
      way(ir)=weig(ir,2)
      waz(ir)=weig(ir,3)
      sumwax=sumwax+wax(ir)+way(ir)+waz(ir)
      enddo
c      write(*,*) 'sumwax= ',sumwax

c *************************************************************************
c     Reading control paramters (INP.DAT)
c *************************************************************************

      write(*,*) 'Non-normalized (0) or normalized, preferred (1) =?'
      read(*,*) keynorm
      write(*,*) 'normalization: ',keynorm
	  
       if(keynorm.eq.0) then
       write(*,*) 'Rough preliminary Mw estimate =?'
       read(*,*) xmw
       estmom=10.**((xmw+6.03)*(3./2.))
       write(*,*)'Estimate of Mw and Mo(Nm): ',xmw,estmom	  
c       estmom=1.e15  ! FIXED OPTION edit (for Juraci, Mw 4) 
       endif      
	  
      read(151,*) 
      read(151,*) keyinv ! =0 for envelopes, =1 for ampl.sp.
c      read(151,*) 
c      read(151,*) keynorm ! =0 for NON-normalization, =1 for NORMALIZATION
      read(151,*) 
      read(151,*) dt
      read(151,*) 
      read(151,*) isourmax ! number of trial positions (depths)
c      read(151,*) 
c      read(151,*) dpfrom,dpstep! trial depths (from, step; both in km)
      read(151,*)
      read(151,*) keysdr ! 0= s/d/r as defined here, 1= s/d/r from file sdr.dat
      if(keysdr.eq.0) then
      read(151,*)
      read(151,*) istfr,istto,istst  ! strike: from,to,step
      read(151,*) idifr,idito,idist  ! dip
      read(151,*) irafr,irato,irast  ! rak
      endif
      close(151)

      
      if(keyinv.eq.1) write(*,*) 'Inversion of AMPL. SPECTRA'
      if(keyinv.eq.0) write(*,*) 'Inversion of ENVELOPES'
 
      if(isourmax.gt.25) then
      write(*,*) 'problem dimension isourmax, STOP'
      stop
      endif	  
c      do i=1,isourmax
c      dp(i)=dpfrom + float(i-1)*dpstep
c      enddo	  

	 
      if(keysdr.eq.0) then
      nall=0  ! 
      do  istr=istfr,istto,istst   ! strike in degrees, INTEGER
      do  idip=idifr,idito,idist   ! dip
      do  irak=irafr,irato,irast   ! rake
      nall=nall+1
      enddo
      enddo
      enddo
   	  write(*,*) 'Strike/dip/rake in 3 loops.'
      write(*,*) 'Polarities are not checked,'
      write(*,*) 'rake may flip from R to R-180°'
      endif
      
	  
      if(keysdr.eq.1) then
      i=1
 33   read(152,*,end=34) strike,dip,rake
      identif(i,1)=ifix(strike)
      identif(i,2)=ifix(dip)
      identif(i,3)=ifix(rake)
      i=i+1
      goto 33
 34   continue
      close(152)
      nall=i-1 
   	  write(*,*) 'Strike/dip/rake from sdr.dat file.'
      endif
	  

      write(*,*) 'Total number of GS (s/d/r) points: ',nall
      if(nall.gt.10000) then
      write(*,*) 'Problem with DIMENSION nall, forcing STOP!'
      stop
      endif      
     
      df=1./float(ntim)/dt 

      if(keyinv.eq.0) then 
      nump=ntim       ! number of processed times
      else
      nump=ntim/2+1   ! number of processed frequencies
      endif
      
c *******************************************************************
c ************ MANIPULATING OBSERVED DATA *****************************
c *******************************************************************

       call maniobs(x,y1,y2,rr)    
       
c Input seismo x (read from *raw.dat) 
c Output seimo is also x (re-written)= XAPIIR filtered and transformed to displ
c This x is NOT IN ANY OUPTUT file.
c Output envelope y1, output ampl.sp y2. BOTH y1 and y2 with 8192 points
c Power of the data rr 

      do i=1,8192 ! nump (isola plotting needs 8192)
      do ir=1,nr
      aox(i,ir)=0.
      aoy(i,ir)=0.
      aoz(i,ir)=0.
      enddo
      enddo


      if(keyinv.eq.0) then     !  0=envelopes, 1=amp.spectra
      do i=1,nump      ! time
      do ir=1,nr
      aox(i,ir)=y1(i,ir,1) !envelope
      aoy(i,ir)=y1(i,ir,2)
      aoz(i,ir)=y1(i,ir,3)
      enddo
      enddo
      
      else
      do i=1,nump      ! freq 
      do ir=1,nr
      aox(i,ir)=y2(i,ir,1) ! amp.sp. ! the rest of aox is ZERO (see initialization above)
      aoy(i,ir)=y2(i,ir,2)
      aoz(i,ir)=y2(i,ir,3)
      enddo
      enddo
      endif

c Zeroing the non-used OBS components (for used stations)
      do ir=1,nr
      if(nuse(ir).ne.0) then 
      do jf=1,nump
      if(wax(ir).lt.eps) aox(jf,ir)=0.	  
      if(way(ir).lt.eps) aoy(jf,ir)=0.
      if(waz(ir).lt.eps) aoz(jf,ir)=0.
      enddo
      endif 	  
      enddo    
	  

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c CALCULATION of the normalization factors (saved for Mo at the end)
c for the observed envelopes and spectra  
c !!!! per  STATION  
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      
      do ir=1,nr
      omax(ir)=0.! building max of Obs (per station)
      do jf=1,nump       !!!!! from 2 or 1 ????????? also below
      ao=amax1(aox(jf,ir),aoy(jf,ir),aoz(jf,ir))
      if(ao.gt.omax(ir)) then
      omax(ir)=ao
      endif
      enddo
      enddo    

      

c ******************************************************************
c Output of observed envelope/ampl.sp. into file *FIL.DAT        
c ******************************************************************

      do ir=1,nr
      onorm=omax(ir)	
      if(keynorm.eq.0) onorm=1.
c     onorm=1.    ! this EDIT possible to PLOT non-normalized when normalization allowed  
	  nfile=2000+1*ir !see open above 
        do i=1,8192 ! nump (isola plotting needs 8192) 
        if(keyinv.eq.0) then 
        xxx=float(i-1)* dt
        else
        xxx=float(i-1)* df
        endif 

c		!!!!!!!!!!!!! to prevent plotting values > 1 
c       No! We will need aox without this multiplication later.
c        if(keynorm.eq.1.and.aox(i,ir)/onorm.gt.1) aox(i,ir)=1.*onorm    !!new jan9, 2017, tobe tested more
c        if(keynorm.eq.1.and.aoy(i,ir)/onorm.gt.1) aoy(i,ir)=1.*onorm
c        if(keynorm.eq.1.and.aoz(i,ir)/onorm.gt.1) aoz(i,ir)=1.*onorm		

        write(nfile,'(4(1x,e12.6))') xxx,
     *       aox(i,ir)/onorm,aoy(i,ir)/onorm,aoz(i,ir)/onorm 
        enddo
      enddo

cccccccccccccccccccccccccccccccccccccccccccccccccc
c APPLICATION of the normalization of the obs data

      do ir=1,nr
      onorm=omax(ir)
      if(keynorm.eq.0) onorm=1. 
c      write(*,*) 'OBS maxima'
c      write(*,*) ir,omax(ir),onorm
      do jf=1,nump
      aox(jf,ir)=aox(jf,ir)/onorm !  	  
      aoy(jf,ir)=aoy(jf,ir)/onorm
      aoz(jf,ir)=aoz(jf,ir)/onorm
      enddo
      enddo
      
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c*************************************************************************
c    Data norm  of obs. data (including weights)
c*************************************************************************
      rrori=0.
      do ir=1,nr          
      do i=1,nump  
      rrori=rrori + wax(ir)**2.*aox(i,ir)**2.+ 
     *              way(ir)**2.*aoy(i,ir)**2.+ 
     *              waz(ir)**2.*aoz(i,ir)**2.
      enddo
      enddo
      write(*,*) '***************'
      write(*,*) 'rrori= ', rrori
      write(*,*) '***************'
      
      rmu=0.
      do ir=1,nr          
      do i=1,nump  
      rmu=rmu + aox(i,ir)+aoy(i,ir)+aoz(i,ir)
      enddo
      enddo
	  rmu=rmu/float(nr*nump)

      rsi2=0.
      do ir=1,nr          
      do i=1,nump  
      rsi2=rsi2+(aox(i,ir)-rmu)**2+(aoy(i,ir)-rmu)**2+(aoz(i,ir)-rmu)**2
      enddo
      enddo
	  rsi2=rsi2/float(nr*nump)
	  
	  
      write(*,*) '***************'
      write(*,*) 'rmu,rsi2= ', rmu,rsi2
      write(*,*) '***************'

	  
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c    Preparation for trial time shifts (envelopes only)  
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
 
c CAUTION: we evaluate cross-correlation with POSITIVE lags only !!!!!!!!

c Assume that, for example, real data were shifted by 20 sec
c This is called an artificial origin time (OT) shift.
c Opt synthtics will need  shift around 20 sec (> 20s or < 20s).
c When seacrching the opt shift, we have at disposal (subr. MYCORLAG)
c only positive lags of synth envelopes (i.e. = shifts to the left).
c That is why always start with synthetics shift most to the right
c and then test smaller shifts to find the best one. 
 
      if(keyinv.eq.0) then	 
      write(*,*) 'How much (in seconds) did you decrease origin time?'
      read(*,*)  shiftOT
c      write(900,*) 'shift of OT (s): ',shiftOT	  
      write(*,*) 'Uncertainty = max. shift (positive, in seconds)?'
      read(*,*)  shiftPLUS	  
c      write(900,*) 'max. shift (s): ',shiftPLUS
      shiftini=shiftOT + shiftPLUS ! must be GREATER than shiftopt (we have only positive lags)      
      write(*,*) 'Shifting to left, starting at shiftini(s)= ',shiftini
c	  nlag=20    ! number of the trial lags !!! Increase to 100 ????????
c	  lagincr=ifix((2.*shiftplus/dt)/float(nlag)) !lag increment (expressed in dt); e.g. 5 means 5dt 
      write(*,*) 'Incremental lag (as a multiple of dt)= ?'
	  read (*,*) lagincr
      nlag=ifix((2.*shiftplus/dt)/float(lagincr))
	  write(*,*) 'Number of tested lags= ',nlag
	  write(*,*) 'Incremental lag (in seonds): ',lagincr*dt
      endif
	  write(*,*) 'Code is running ... '
	  
c *******************************************************************
c ************ LOOP OVER SOURCE POSITIONS **************************
c *******************************************************************

       do 60 isour=1,isourmax
       
c *******************************************************************
c *************MANIPULATING elemse 
c *******************************************************************

      filename='elemse'//chr(isour)//'.dat'
      call elesyn(filename,w)
c reading elem seis for a particular source position, filtration, diplacement
c this array w will be kept unchanged throughout the GS over s/d/r



c *************************************************************************
c        GS over  s/d/r angled in  THREE NESTED LOOPS 
c         (inside the loop over source position)     
c *************************************************************************

      ncount=0  ! indexing  GS 'points' CURRENT during 3 loops
      summin= 100000. ! some very large number      
      corrmax=0. 
      varmax=-100000.     ! newly redefined for each tested depth 
	 
	  
      if(keysdr.eq.1) then
      istto=istfr      ! formal redefinition of limits, to run the 3 loops only ONCE
      idito=idifr      ! when we use the sdr.dat file instead the s/d/r limits 
      irato=irafr
      istst=1
      idist=1
      irast=1
      endif
      
      do 6300 istr=istfr,istto,istst   ! strike in degrees, INTEGER
      do 6200 idip=idifr,idito,idist   ! dip
      do 6100 irak=irafr,irato,irast   ! rake
      if(keysdr.eq.0) then 
      ncount=ncount+1
      identif(ncount,1)=istr
      identif(ncount,2)=idip
      identif(ncount,3)=irak
      strike=float(istr) ! strike in degrees, REAL
      dip=   float(idip)
 	  rake=  float(irak)
      goto 2233
      endif
      
 2222 ncount=ncount+1       ! this is for keysdr.ne.0
      strike=float(identif(ncount,1))
      dip=   float(identif(ncount,2))
      rake=  float(identif(ncount,3))
 	
 2233 continue
      xmoment=1.       ! UNIT moment!!!!
      call genacka(xmoment,strike,dip,rake,afix)

c  We generate synthtics for shiftini = =shiftOT+shiftplus
c (then, later, we make trial shifts, starting with shiftini and go only back) 
   
	  ishf=ifix(shiftini/dt) ! max possible error is one dt
      call subevnt15(afix,w,ishf,sx)
c      w is NOT re-written, sx is created
c      sx is  synth  filtered displacement(incl. focmech)

      call prepsyn(sx,y1,y2) ! envelope and ampl.sp. of the synth displacement filtered	
   
      if(keyinv.eq.0) then   
      do i=1,nump      ! time
      do ir=1,nr
      asx(i,ir)=y1(i,ir,1) ! synthetic envelope for unit moment
      asy(i,ir)=y1(i,ir,2)
      asz(i,ir)=y1(i,ir,3)
      enddo
      enddo
     
      else
     
      do i=1,nump     ! freq 
      do ir=1,nr
      asx(i,ir)=y2(i,ir,1) ! synthetic amp.sp. for unit moment
      asy(i,ir)=y2(i,ir,2)
      asz(i,ir)=y2(i,ir,3)
      enddo
      enddo
      endif
      
c Zeroing the non-used SYNTH components (for used stations)
      do ir=1,nr
      if(nuse(ir).ne.0) then 
      do jf=1,nump
      if(wax(ir).lt.eps) asx(jf,ir)=0.	  
      if(way(ir).lt.eps) asy(jf,ir)=0.
      if(waz(ir).lt.eps) asz(jf,ir)=0.
      enddo
      endif 	  
      enddo   
	  
	  
	  
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Synthetic  envelopes and spectra  normalized individually 
c per  STATION (for each tested  MECHANISM and each tested SOURCE DEPTH) !!!  
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      
      
      do ir=1,nr
      smax(ir)=0.! building max of Syn (per station, for each GridPoint)
      do jf=1,nump       !!!!! from 2 or 1 ????????? also below
      as=amax1(asx(jf,ir),asy(jf,ir),asz(jf,ir))
      if(as.gt.smax(ir)) then
	  smax(ir)=as
      endif
      enddo
      enddo    

      do ir=1,nr
      snorm=smax(ir)
	if(keynorm.eq.0) snorm=1.
c	write(*,*) 'SYN maxima'
c      write(*,*) ir,smax(ir),snorm
	do jf=1,nump
      asx(jf,ir)=asx(jf,ir)/snorm      
      asy(jf,ir)=asy(jf,ir)/snorm
      asz(jf,ir)=asz(jf,ir)/snorm
      enddo
      enddo
      

c *************************************************************************
c    Loop over trial time shifts (for envelopes only), to find the best lag    
c    between obs and syn data for a given depth and GS point.
c    Different lags per stations/comp
c CAUTION: This is insensitive to weights !!!!!!!!!
c CAUTION: When seeking shifts for non-normalized envelopes, I detected 
c          numeric problems in mycorlag2 (var y < 1e-43) due to low amplitude of synthetics
c *************************************************************************
      
	  if(keyinv.eq.0) then
	  
ccccccccccccccccccccccccccccccccc
c AUXILIARY mult.of synth. by 'true' moment to prevent problems mycorlag2
c only for seeking the lag [in NON-NORMALIZED mode]
c In the normalized mode it is not needed
      if(keynorm.eq.0) then	  
      xmo=estmom      
      do ir=1,nr
      do jf=1,nump
      asx(jf,ir)=asx(jf,ir)*xmo      
      asy(jf,ir)=asy(jf,ir)*xmo
      asz(jf,ir)=asz(jf,ir)*xmo
      enddo
      enddo
      endif	  
ccccccccccccccccccccccccccccccccccc

      do ir=1,nr      
	  ccxopt(ncount,isour,ir)=0. ! inicialization of opt corr per all lags (for a given mechan at a given depth)
	  ccyopt(ncount,isour,ir)=0.   ! corr snad nemusi byt pole ??
	  cczopt(ncount,isour,ir)=0.
      lgxopt(ncount,isour,ir)=0.   ! lag musi byt pole pro konecne pouziti po VOLBE hloubky a mech.
      lgyopt(ncount,isour,ir)=0.
      lgzopt(ncount,isour,ir)=0.
      enddo	  
      do ilag=1,nlag+1  
      lag=(ilag-1)*lagincr  ! lag (as a number of time steps dt); shift=lag*dt 
      do ir=1,nr ! 
	  call mycorlag2(aox(1,ir),asx(1,ir),8192,lag,ccx)
	  call mycorlag2(aoy(1,ir),asy(1,ir),8192,lag,ccy)
	  call mycorlag2(aoz(1,ir),asz(1,ir),8192,lag,ccz)
      if(ccx.gt.ccxopt(ncount,isour,ir)) then
	  ccxopt(ncount,isour,ir)=ccx
	  lgxopt(ncount,isour,ir)=lag  ! opt lag for a given GS point 
      endif
      if(ccy.gt.ccyopt(ncount,isour,ir)) then
	  ccyopt(ncount,isour,ir)=ccy
	  lgyopt(ncount,isour,ir)=lag  ! opt lag for a given GS point 
      endif
      if(ccz.gt.cczopt(ncount,isour,ir)) then
	  cczopt(ncount,isour,ir)=ccz
	  lgzopt(ncount,isour,ir)=lag  ! opt lag for a given GS point 
      endif
      enddo ! over stations
c	  write(*,*) isour,ncount,lag, crr
      enddo ! over lags at a given GS point

ccccccccccccccccccccccccc	  
c AUXILIARY: compensation of the previous multiplication by xmo before seeeking lag
      if(keynorm.eq.0) then
      xmo=estmom      
      do ir=1,nr
      do jf=1,nump
      asx(jf,ir)=asx(jf,ir)/xmo      
      asy(jf,ir)=asy(jf,ir)/xmo
      asz(jf,ir)=asz(jf,ir)/xmo
      enddo
      enddo
      endif	  
cccccccccccccccccccccccc

   	  endif ! only for envelopes


	  
      if(keynorm.eq.1) goto 3476 ! then we do not need prelim. moment estimate

c *******************************************************
c       Computing moment before computing L2 error function
c       It INCLUDEs time shift (for enevelopes only)
c   Moment computed by an analytic least-squares formula
c        Eq. 9 of Zahradnik & Gallovic, JGR2010 
c   Weights included...
c *******************************************************
      sum1=0.
      sum2=0.
      do ir=1,nr        ! start loop over stations

	  ixplus=0. 
	  iyplus=0. 
	  izplus=0.
      if(keyinv.eq.0) then
	  ixplus=lgxopt(ncount,isour,ir) 
	  iyplus=lgyopt(ncount,isour,ir) 
	  izplus=lgzopt(ncount,isour,ir) 
      endif

      do i=1,nump 
        i2x= i + ixplus
	  i2y= i + iyplus
	  i2z= i + izplus
      if(i2x.gt.nump) i2x=nump     ! CAUTION; not much checked !!???
      if(i2y.gt.nump) i2y=nump     
      if(i2z.gt.nump) i2z=nump     
	
      sum1=sum1+wax(ir)**2.*(aox(i,ir)*asx(i2x,ir))+
     *          way(ir)**2.*(aoy(i,ir)*asy(i2y,ir))+ 
     *          waz(ir)**2.*(aoz(i,ir)*asz(i2z,ir))
      sum2=sum2+wax(ir)**2.*(asx(i2x,ir)**2.)+
     *          way(ir)**2.*(asy(i2y,ir)**2.)+ 
     *          waz(ir)**2.*(asz(i2z,ir)**2.)

      enddo ! end loop over envelope/amp.sp., all 3 components (incl. weights)   
      enddo   ! end loop over stations
   	  xmo=sum1/sum2 ! estimate of moment (good if the form is fitted well)
c      xmo=estmom !	yields low fit unless Mo is estimated well   
      do ir=1,nr
      do i=1,nump
      asx(i,ir)=asx(i,ir)*xmo
      asy(i,ir)=asy(i,ir)*xmo
      asz(i,ir)=asz(i,ir)*xmo
      enddo
      enddo

 3476 continue	  
 
c ***************************************************
c       constructing error function
c INCLUDEs the moment estimate
c INCLUDEs time shift (for enevelopes only)
c INCLUDEs WEIGHTS of components 
c FUTURE: choosing NUMP to 'cut' records before non-modeled signals (for envelopes only) ??
c ***************************************************
      sum=0.
	  sumx=0.
      sumy=0.
      sumz=0.
      do ir=1,nr        ! start loop over stations

	  ixplus=0. 
	  iyplus=0. 
	  izplus=0.
      if(keyinv.eq.0) then
	  ixplus=lgxopt(ncount,isour,ir) 
	  iyplus=lgyopt(ncount,isour,ir) 
	  izplus=lgzopt(ncount,isour,ir) 
      endif

      do i=1,nump 
      i2x= i + ixplus
	  i2y= i + iyplus
	  i2z= i + izplus
      if(i2x.gt.nump) i2x=nump     ! CAUTION; not much checked !!???
      if(i2y.gt.nump) i2y=nump     
      if(i2z.gt.nump) i2z=nump     

      sumx=sumx+wax(ir)**2.*(aox(i,ir)-asx(i2x,ir))**2. 
      sumy=sumy+way(ir)**2.*(aoy(i,ir)-asy(i2y,ir))**2.
      sumz=sumz+waz(ir)**2.*(aoz(i,ir)-asz(i2z,ir))**2.
      enddo ! end loop over envelope/amp.sp., all 3 components (incl. weights)   
      enddo   ! end loop over stations
      sum=sum+sumx+sumy+sumz         
      error(ncount)=sum/rrori  ! here we may have also possibly sum (L1 misfit)

      var=1.-sum/rrori             ! variance reduction, including weights 
	  error2(ncount)=var   ! ncounts counts the grid-search 'points' (s/d/r combinations)

cc         THIS PART IF WE WANT  INDEXOPT for L2 misfit  (per GS point)	  
c       if(sum/rrori.lt.summin) then
c       summin=sum/rrori  !update of minimum error over ALL grid points (NOT USED later)
c       indexopt=ncount ! and at which point it is  (THIS is needed)
c       endif

cc         THIS PART IF WE WANT INDEXOPT for variance reduction (per GS point)     
      if(var.gt.varmax) then
      varmax=var  !update of minimum error over ALL grid points (NOT need later)
      indexopt=ncount ! and at which point it is  (THIS is needed)
      endif
	  
      if(keysdr.eq.1.and.ncount.lt.nall) then
      goto 2222 ! end of loop in case of s/d/r from focmec
      endif
      
 6100 continue  ! rake
 6200 continue  ! dip
 6300 continue  ! strike      3 main loops on strike-dip-rake finished

c  ****************************************************************

 
c output of all solutions for source isour
      write(*,*)
      write(898,*) isour
      do ncount=1,nall
      istr=identif(ncount,1)
      idip=identif(ncount,2)
      irak=identif(ncount,3)
      write(898,'(1x,i6,3(1x,i6),1x,e10.4)')
     *     ncount,istr,idip,irak,error(ncount)    
      enddo

c ******************************************************************
c  output of the best-fitting solution for currently tested depth
c  i.e. for GS with ncount = indexopt
c  does NOT include re-calculation of synth data and moment 
c ******************************************************************

      istr=identif(indexopt,1)     ! S NOVOU HLOUBKOU SE indexopt a vse prepise!
      idip=identif(indexopt,2)
      irak=identif(indexopt,3)
      deferr=error(indexopt)   ! deferr=min misfit ! s NOVOU HLOUBKOU SE PREPISE (neuchova se )
      deferr2=error2(indexopt)   ! deferr2=max VR
	  
      write(*,*) 'Source no., GS point no.,strike,dip,rake, misfit, VR' 
      write(*,'(5(1x,i6),2(1x,e10.4))') 
     *        isour,indexopt,istr,idip,irak,deferr,deferr2 
      write(*,*)
      
      if(keyinv.eq.0) then
c      ilagopt=lagopt(ncount) ! opt. lag for a given GS point  
c      corrmax=corropt(ncount)	  
c      write(894,*) isour          ! output of integer lags into a file
      do ir=1,nr
      ix1=lgxopt(indexopt,isour,ir) ! opt. lag for a given GS point and depth  
      iy1=lgyopt(indexopt,isour,ir) ! different for stations/components
      iz1=lgzopt(indexopt,isour,ir) ! Tady je jeste isour zbytecne, jsem v cyklu pres isour
c      write(894,'(2x,i5,5x,3(2x,i10))') ir,ix1,iy1,iz1
      enddo
      endif
      
	  
      write(899,'(5(1x,i6),1x,e10.4)')
     *     isour,indexopt,istr,idip,irak,deferr

      strike=float(istr)
	  dip=float(idip)
	  rake=float(irak)
      call auxpln(strike,dip,rake,strike2,dip2,rake2)
      istr2=ifix(strike2)
	  idip2=ifix(dip2)
	  irak2=ifix(rake2)
      dum1=1.0e15
      dum2=100.
      corrout=0.
      if(deferr2.gt.0.) corrout=sqrt(deferr2) !corr= sqrt(VR)

c      write(897,*) 'isour,GSpoint#,corr,nil,DC%,s,d,r,s2,d2,r2'
      write(897,'(2x,i4,2x,i5,2x,f10.6,2x,e15.4,2x,f8.3,2x,i5,
     *     2x,i5,2x,i5,2x,i5,2x,i5,2x,i5)')
     * 	 isour,indexopt,corrout,dum1,dum2,
     *   istr,idip,irak,istr2,idip2,irak2

      call pl2pt(strike,dip,rake,azp,ainp,azt,aint,azb,ainb,ierr)
	  
	  dum0=0.
      write(896,
     *   '(1x,i5,1x,f6.2,1x,e12.6,12(1x,f6.0),1x,f6.1,1x,e12.4)')
     *           isour,dum0,dum1,strike,dip,rake,
     *           strike2,dip2,rake2,azp,ainp,azt,aint,azb,ainb,
     *           dum2,deferr2

  60  continue ! end of loop over trial source depths
c    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


c      do jj=1,27
c      write(897,'(a100)') text(jj)
c      enddo

      close(898)
      close(899)
      close(897)
c     pause

c  ************************************************************************
c  Re-calculation of synth spectra and moment for the best-fitting solution
c  at the chosen depth
c  ************************************************************************
c V pripade potreby muze otevrit 899, cist a najit automaticky opt. isour 
c a jeho indexopt jako hodnoty pro minimalni deferr. Preferuji manualni potvrzeni. 

      write(*,*) 'Choose source  number and GS point number: '
      read(*,*)  isour, indexopt      ! CAUTION both are newly defined HERE !!
c                                      ! to uz neni puvodni isour a indexopt 
      if(keyinv.eq.0) then
      do ir=1,nr
      ilagx(ir)=lgxopt(indexopt,isour,ir) ! opt. lag for a given GS point and depth  
      ilagy(ir)=lgyopt(indexopt,isour,ir) ! different for stations/components
      ilagz(ir)=lgzopt(indexopt,isour,ir) ! Tady je jeste isour zbytecne, jsem v cyklu pres isour
      enddo
c      write(894,*)      
c      write(894,*) 'ilag (multiples of dt) for the best depth'
c      write(894,*) isour          ! output of integer lags into a file
c      do ir=1,nr
c      write(894,'(2x,i5,5x,3(2x,i10))') ir,ilagx(ir),ilagy(ir),ilagz(ir)
c      enddo      
      endif

      write(900,*) 'Total number of GS (s/d/r) points:'
      write(900,*) nall
      write(*,*)
c      write(*,*) 'Chosen source number and depth(km): ',isour,dp(isour)
      write(*,*) 'Chosen source number: ',isour
      write(*,*) 'Chosen GS point number: ', indexopt
      write(900,*)
c      write(900,*) 'Chosen source number and depth(km):',
      write(900,*) 'Chosen source number:', isour
      write(900,*) 'Chosen GS point number: ', indexopt

c     if(keyinv.eq.0) then
c      write(*,*) 'Chosen ilagopt: ', ilagopt
c      write(900,*) 'Chosen ilagopt: ', ilagopt
c	  endif
	  
      istr=identif(indexopt,1)
      idip=identif(indexopt,2)
      irak=identif(indexopt,3)
      write(*,*) 'opt s/d/r: ', istr,idip,irak
      write(900,*) 'opt s/d/r: ', istr,idip,irak

      strike=float(istr)
 	  dip=   float(idip)
 	  rake=  float(irak)
      xmoment=1. !!!!! 
 
      call genacka(xmoment,strike,dip,rake,afix)
      
C NEWLY open elemse, creating EVERYTHING synth again for selected source only       
c (open and close are inside subr. elesyn)

      filename='elemse'//chr(isour)//'.dat'
      call elesyn(filename,w)
	  
      if(keyinv.eq.0) then
      write(894,*) 
      write(894,*) 'opt shifts in seconds; recall that OT is= ', shiftOT
      do ir=1,nr
      ilagx(ir)=-ilagx(ir)+ifix(shiftini/dt)     !!!!!!! ilagx.. are REDEFINED
	  ilagy(ir)=-ilagy(ir)+ifix(shiftini/dt)
	  ilagz(ir)=-ilagz(ir)+ifix(shiftini/dt)
      write(894,'(2x,i5,5x,3(2x,f8.1))') ir,
     *	  ilagx(ir)*dt,ilagy(ir)*dt,ilagz(ir)*dt
      enddo
      call subevnt15lag(afix,w,ilagx,ilagy,ilagz,sx) 
      else
      ioptshf=ifix(shiftini/dt) ! possible error of 1 dt 
      call subevnt15(afix,w,ioptshf,sx)
      endif
      
      call prepsyn(sx,y1,y2) ! envelope and ampl.sp. of the synth displacement filtered	
   
      do i=1,8192 ! not nump (isola plotting needs 8192 even if we plot spectra having less)
      do ir=1,nr
      asx(i,ir)=0.
      asy(i,ir)=0.
      asz(i,ir)=0.
      enddo
      enddo
     
   
      if(keyinv.eq.0) then   
      do i=1,nump      ! time
      do ir=1,nr
      asx(i,ir)=y1(i,ir,1) ! synth. envelope (incl. shifts) 
      asy(i,ir)=y1(i,ir,2)
      asz(i,ir)=y1(i,ir,3)
      enddo
      enddo
      
      else
     
      do i=1,nump     ! freq 
      do ir=1,nr
      asx(i,ir)=y2(i,ir,1) ! synth. amp.sp. 
      asy(i,ir)=y2(i,ir,2)
      asz(i,ir)=y2(i,ir,3)
      enddo
      enddo          ! These synthetics are for UNIT MOMENT 
      endif          ! They are not normalized 
  
c Before computing moment we need original OBS data.
c The observed data are returned to non-normalized  using saved values omax(ir)
     
      do ir=1,nr
      onorm=omax(ir)
      if(keynorm.eq.0) onorm=1.
c     write(*,*) 'OBS maxima'
c     write(*,*) ir,omax(ir),onorm
      do i=1,nump 
	  aox(i,ir)=aox(i,ir)*onorm  
      aoy(i,ir)=aoy(i,ir)*onorm
      aoz(i,ir)=aoz(i,ir)*onorm
      enddo
      enddo          
    

c *****************************************************************
c       Computing moment by an analytic least-squares formula
c          Eq. 9 of Zahradnik & Gallovic, JGR2010 
c              With weights ....
c *****************************************************************

      sum1=0.
      sum2=0.
      do ir=1,nr        ! start loop over stations
      do i=1,nump 

	  sum1=sum1+wax(ir)**2.*(aox(i,ir)*asx(i,ir))+        
	*           way(ir)**2.*(aoy(i,ir)*asy(i,ir))+ 
	*           waz(ir)**2.*(aoz(i,ir)*asz(i,ir))
      sum2=sum2+wax(ir)**2.*(asx(i,ir)**2.)+
	*           way(ir)**2.*(asy(i,ir)**2.)+ 
	*           waz(ir)**2.*(asz(i,ir)**2.)
	
      enddo ! end loop over envelope/amp.sp., all 3 components (incl. weights)   
      enddo   ! end loop over stations
   	  xmo=sum1/sum2 ! final estimate of moment (good if the form is fitted well)
c      write(*,*) xmo 
	 
      do ir=1,nr
      do jf=1,nump
      asx(jf,ir)=asx(jf,ir)*xmo ! non-normalized synthetics with real momet
      asy(jf,ir)=asy(jf,ir)*xmo
      asz(jf,ir)=asz(jf,ir)*xmo
      enddo
      enddo
      
	  pompom=xmo

      write(*,*) 'Moment (Nm)= ',pompom
      write(900,*) 'Moment (Nm)= ',pompom
      xmommag=(2.0/3.0)*log10(pompom) - 6.0333 
      write(*,*) 'Moment magnitude Mw= ',xmommag 
      write(900,*) 'Moment magnitude Mw= ',xmommag 

      write(900,*)
      write(900,*) 'Selected solution:'
      write(900,'(1x,i6,1x,e10.4,3(1x,i6))')
     *     isour,pompom,istr,idip,irak

      write(900,*)
   	  write(900,*) 'normalization: ',keynorm
      write(900,*) 'shift of OT (s): ',shiftOT	  
      write(900,*) 'max. shift (s): ',shiftPLUS
	 

c Zeroing the non-used SYNTH components (for used stations) [FOR PLOTTING ONLY]
      do ir=1,nr
      if(nuse(ir).ne.0) then 
      do jf=1,nump
      if(wax(ir).lt.eps) asx(jf,ir)=0.	  
      if(way(ir).lt.eps) asy(jf,ir)=0.
      if(waz(ir).lt.eps) asz(jf,ir)=0.
      enddo
      endif 	  
      enddo   
	  

	 
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Computing normalization factors for synthetics (for plotting only)

      do ir=1,nr
      smax(ir)=0.! building max of Syn (per station, for each GridPoint)
      do jf=1,nump
      as=amax1(asx(jf,ir),asy(jf,ir),asz(jf,ir))
      if(as.gt.smax(ir)) then
	  smax(ir)=as
      endif
      enddo
      enddo    


	  
c ******************************************************************
c  Output of optimum synth. envelope/ampl.sp. into *SYN file
c  Includes the calculated moment 
c ******************************************************************
      
      do ir=1,nr          
      renorm=smax(ir)
	if(keynorm.eq.0) renorm=1.
c     write(*,*) 'SYN maxima'
c      write(*,*) ir,smax(ir),renorm
c     renorm=1. ! this EDIT possible to PLOT non-normalized when normalization allowed  
	  nfile=3000+1*ir  
        do i=1,8192 !!!!!! nump (isola plotting needs 8192 but then we need initialization) 
        if(keyinv.eq.0) then 
        xxx=float(i-1)* dt
        else
        xxx=float(i-1)* df
        endif
        write(nfile,'(4(1x,e12.6))') xxx,
     *       asx(i,ir)/renorm,asy(i,ir)/renorm,asz(i,ir)/renorm 
        enddo
      enddo

  
      STOP
      END

c =================================================================

      include "maniobs.inc"
      include "subevnt15.inc"
      include "subevnt15lag.inc"	  
      include "elesyn.inc"
      include "prepsyn.inc"
      include "genacka.inc"
      include "filter15.inc"
      include "fcoolr.inc"
      include "filtmore.inc" 
c      include "timefilters.inc" ! exists in filter15.inc
c      include "mycorlag.inc"
      include "mycorlag2.inc"
      include "auxpln.inc"
      include "pl2pt.inc"