      program SIPOLNEW3

c     checking polarities at all stations present in MYPOL.DAT
c     they come from: (i) station.dat, and (ii) extrapol.pol

c     observed polarities are compared with synthetic polarities
c     for all tested strike-dip-rake trials

c     satisfying trial = that one for which all polarities are satisfied
c                                       or  all polarities are opposite

c     The last column of the output file is a sum of 'isatis' numbers
c     for all stations (isatis=1...agreement at 1 stat., -1...disagreement).
c     It does NOT show at howmany stations the polarity is satisfied !!!
c     Example. Consider 5 stations, then good cases are: sum of isatis=5 or -5
c              If -5, then rake changes to rake -180


      dimension isazi(500),istak(500),keypol(500)

      character*5 sta
      character*5 statname(100)
      character*1 pol
      character*80 text
      
      open(1,file='mypol.dat') ! input = takeoff angles for the best depth 
      open(2,file='out1.dat') ! Input= all solutions for the best depth
c     Caution: File out1.dat is created by the GUI from out1_save.dat  	  

      open(4,file='out4.dat') ! Output = solutions within threshold, no polarity check
      open(5,file='out5.dat') ! Output = solutions within threshold, with polarity check
      open(55,file='inv2.dat') ! Output = enriched out5 for plotting beacballs,
c!	  In inv2.dat, the best solution is not necessarily the FIRST one in inv2.dat  
c!    Using out5.dat, GUI places the best solution in onemech.dat, and others in moremech.dat 
      open(6,file='out6_opt.dat') !Output = a single (the best) polarity satisafying solution
      open(8,file='out5_detail.dat') ! Output = detailed log 

	write(4,*) 
	rewind(4)
	write(5,*) 
 	rewind(5)

      
      numsta=0
      iread=0
      num=0
      num2=0
      num3=0
	
      write(*,*) 'This is sipolnew3'
      write(*,*) 'Threshold (>0, in percent)=?'
	read(*,*) thrs
	thrs= 1. + thrs/100. 
c********************************************************** 
c        Reading MYPOL.DAT
c**********************************************************      
      read(1,100) text
  100 format(a80)
c  10 read(1,200,end=50) sta,iazi,itak,pol  ! fixed format
c 200 format(1x,a3,8x,i3,1x,i3,3x,a1)       ! format HYPO
   10 read(1,*,end=50) sta,iazi,itak,pol    ! free format
      iread=iread+1
c      write(*,*) iread
        statname(iread)=sta
        isazi(iread)=iazi
        istak(iread)=itak
        if(pol.eq.'U') keypol(iread)=1
        if(pol.eq.'D') keypol(iread)=-1
        if(pol.eq.'?') keypol(iread)=0     
      goto 10
  50  continue
c     numsta=iread - 1 ! pro pripad ze soubor polarit konci znackou
c                      ! napr. kdyz byl ulozen pomoci IBM editu
c                      ! tehdy se totiz radka se znackou cte, coz je
c                      ! pro nas nadbytecne; proto -1
      numsta=iread     ! pro pripad ze soubor polarit nekonci znackou
c                      !   (napr. kdyz je vytvoren nejakym programem)
c                      ! tehdy se ctou jen plne radky a jejich pocet
c                      ! je urcen tim iread;  -1 je pak uz nezadouci
      write(*,*) 'number of stations ',numsta
      numsta2=0
      do i=1,numsta
c      write(*,*)  isazi(i),istak(i),keypol(i)
      if(keypol(i).ne.0) then
      numsta2=numsta2+1
      endif
      enddo
      write(*,*)  'number of defined polarities ',numsta2

c********************************************************** 
c    Reading OUT1.DAT,  counting  solutions, identifying minimum error (without polarities) 
c**********************************************************      
      numsol=0
      iread=0
      errmin=999.
      
   20 read(2,*,end=25) dum,istr,idip,irak,err   
      iread=iread+1
      if(err.lt.errmin) errmin=err
      goto 20
   25 continue
c     numsol=iread  -  1
      numsol=iread
      write(*,*)  'number of solutions', numsol
      write(*,*)  'minimum error WITHOUT polarity check ', errmin
      errpos =errmin  * thrs      ! thrs % ! acceptable error (without pol. check)
      write(*,*)  'acceptable error WITHOUT polarity check ',errpos

      rewind (2) ! to enable repeated reading (avoiding arrays)

c********************************************************** 
c    Polarity check of the solutions, identifying minimum error (with polarities) 
c**********************************************************      

      write(8,*)  'Number of stations ',numsta
      write(8,*)  'Number of defined polarities (numsta2) ',numsta2
      write(8,*)  'If polarities disagree at numsta2 stations,'
      write(8,*)  'the rake is flipped and solution is accepted.'
      
      errmin2=999999.
      do 70 isol=1,numsol   ! starting loop over all solutions
      read(2,*) dum,istr,idip,irak,err   ! reading AGAIN (to prevent arrays)
      write(8,*)
      write(8,*) 'solution number: ',isol
      write(8,*) 'solution s/d/r:  ',istr,idip,irak

      isuma=0     ! summing 'isatis' codes over the stations
c  possible 'isatis' values (per station) ...  1=agreement,  -1=disagreement 
      do i=1,numsta
      iazi=isazi(i)
      itak=istak(i)
      ipol=keypol(i)
      call agree(iazi,itak,ipol,istr,idip,irak,isatis)
      isuma=isuma+isatis
      if(isatis.eq.-1) then
      write(8,*) 'Polarity disagreement at station: ', statname(i)
      endif      
      enddo

      if(err.lt.errpos) then      ! output of solutions without pol. check
c     output of acceptable solutions WITHOUT polarity check
      write(4,400) isol,num2,num3,istr,idip,irak,err,isuma
 400  format(6(1x,i5),1x,e10.4,5x,i3)
      endif

      if(abs(isuma).eq.numsta2) then   
      if(err.lt.errmin2) errmin2=err    ! seeking minimum eror of polarity-satisfying solution
      endif                           
 70   continue    ! ending loopover all solutions
      errpos2=errmin2 * thrs !   acceptable error (with pol. check)
      write(*,*)  'minimum error WITH polarity check', errmin2
      write(*,*)  'acceptable error WITH polarity check ',  errpos2
      if(errpos2.ge.999999.) then
	  write(*,*)
	  write(*,*)  'ERROR: Solution not found!'
      endif	  
      rewind (2)

c********************************************************** 
c    Output of the acceptable solutions(with polarities) 
c**********************************************************      

      do 60 isol=1,numsol   ! starting loop over all solutions, AGAIN (to prevent arrays)
      read(2,*)  dum,istr,idip,irak,err   

      isuma=0     ! soucet cisel isatis
      do i=1,numsta
      iazi=isazi(i)
      itak=istak(i)
      ipol=keypol(i)
      call agree(iazi,itak,ipol,istr,idip,irak,isatis)
      isuma=isuma+isatis
      enddo

      if(abs(isuma).eq.numsta2.and.err.lt.errpos2) then  

      if(isuma.lt.0) then 
      keyflip=1
      irak=irak-180   !!!!! rake changed to rake -180 !!!
c      write(*,*) 'Changing rake for solution ',isol
      
	if(irak.lt.-180) irak= 360+ irak

      endif
c output of acceptable solutions WITH polarity check (rake modified if needed)

      write(5,400) isol,num2,num3,istr,idip,irak,err,isuma
 
c new  !!!!!!!! ccccccccccc   output 'almost' like inv2.dat ccccccccccccccccccccccccccccc
      strike=float(istr)
	  dip=float(idip)
	  rake=float(irak)
      call auxpln(strike,dip,rake,strike2,dip2,rake2)
      istr2=ifix(strike2)
	  idip2=ifix(dip2)
	  irak2=ifix(rake2)
      dum1=1.0e15
      dum2=100.
 
      if(rake.lt.-180.) rake=360.+rake
      if(rake2.lt.-180.) rake2=360.+rake2

      call pl2pt(strike,dip,rake,azp,ainp,azt,aint,azb,ainb,ierr)
	  dum0=0.
      write(55,
     *   '(1x,i5,1x,f6.2,1x,e12.6,12(1x,f6.0),1x,f6.1,1x,e12.4)')
     *           isol,dum0,dum1,strike,dip,rake,
     *           strike2,dip2,rake2,azp,ainp,azt,aint,azb,ainb,
     *           dum2,err
ccccccccccccccccccccccccccccc end of new part cccccccccccccccccc 
 
 
 
       if(err.eq.errmin2) then  
cc    if(isuma.lt.0) irak=irak-180   !!!!! cannot be twice; already made
c output of the BEST  solution WITH polarity check (rake modified if needed)
      write(*,*) 'Optimum solution s/d/r: ', istr,idip,irak
      if (keyflip.eq.1) write(*,*) 'Rake has been flipped'
      write(6,400) num,num2,num3,istr,idip,irak,err,isuma
      endif
      
      endif

 60   continue   ! ending loop over all solutions

      stop
      end

c ************************************************************************

      subroutine agree(iazi,iang,ipol,istr,idip,irak,iii) 
c Checking polarity agreement per single station:
c iii=1 agreement, iii=-1 disagreement, iii=0 missing

      pi=3.141592
      azi=float(iazi)*pi/180.
      ang=float(iang)*pi/180.
      str=float(istr)*pi/180.
      dip=float(idip)*pi/180.
      rak=float(irak)*pi/180.

      patt=cos(rak)*sin(dip)*(sin(ang))**2*sin(2.*(azi-str))-
     *     cos(rak)*cos(dip)*sin(2.*ang)*cos(azi-str)+
     *     sin(rak)*sin(2.*dip)*(cos(ang))**2-
     *     sin(rak)*sin(2.*dip)*(sin(ang))**2*(sin(azi-str))**2+
     *     sin(rak)*cos(2.*dip)*sin(2.*ang)*sin(azi-str)
c     write(*,*) patt

      iii=-1                               !disagreement
      if(patt.gt.0.and.ipol.eq.1)  iii=1   !agreement
      if(patt.lt.0.and.ipol.eq.-1) iii=1   !agreement
      if(ipol.eq.0) iii=0                  !missing

      return
      end
	  
      include "auxpln.inc"
      include "pl2pt.inc"