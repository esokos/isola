      program ISO15

c      This is a part of the uncertainty analysis at a single source position
c      it NEEDS vardat from INPINV.DAT !!!
c      See also 6677, it needs srcno.dat, made by the GUI !!!


c     filter station dependent

c      as iso11b, but 0 in allstat means 0 weight

c       automatically for FULLmt
c       NO DATA NEEDED (only to produce VECT and SING)
c       simplified version - no repetitions
c       output of eigenvectors of GTG , SINGULAR values of G (sqrt of eigenvalues of GTG)



c     Author: J. Zahradnik 2011





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
      dimension w(-3500:11692,21,3,6)  !  6 = full moment, 5 = deviatoric only 
      dimension rold(6,6),rinv(6,6)
      dimension corr(100),ish(100),asave(6,100),aopt(6),vopt(6)
      dimension aoptsum(6)
      dimension twocorr(99,100)       ! 100 = max number of trial time shifts
      dimension twoshft(99,100)		! 99 = max number of trial source positions
	dimension twostr(99,100),twodip(99,100),tworak(99,100)
      dimension twostr2(99,100),twodip2(99,100),tworak2(99,100)
      dimension twodcper(99,100),twomom(99,100)
      dimension twoaaaa(99,100,6)
      dimension twovvvv(99,100,6)
      dimension twomoxx(99,100),twomoyy(99,100),twomozz(99,100)
      dimension twomoxy(99,100),twomoxz(99,100),twomoyz(99,100)
      dimension ibest(99),cbest(99),xmo(99),dcp(99)
	dimension abest(99,6),vara(99,6)
      dimension is1(99),id1(99),ir1(99)
      dimension is2(99),id2(99),ir2(99)
      dimension nuse(21)
      dimension ntm(21),keygps(21)
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
      open(151,file='inpinv.dat')    ! input: control parameters
      open(200,file='mechan.dat')    ! input: for fixed focal mechanism only
c     open(674,file='correl.dat')     ! 2d correlation (see later)
      open(222,file='inv1.dat',status='unknown')! output: all details
      open(898,file='inv2.dat')      !       : less details
      open(798,file='inv2c.dat')      !       : less details, summed subevents
      open(899,file='inv3.dat')      !       : moment tensor (for GMT)
      
      open(61,file='temp001.txt')    ! thimios to signal end of run for GUI use
 

c     FIXED OPTIONS
      ntim=8192 ! number of time samples  
      
	aopt(6)=0.
	vopt(6)=0.
      aoptsum(6)=0.
      
	ir=1
c  7   read(150,*,end=8) statname(ir),nuse(ir),	 ! weig is NOT weight, but 1./weight
c     *            weig(ir,1),weig(ir,2),weig(ir,3) ! weig=1 used, weig=100 not used; later in GUI make weig proportinal to distance

  7   read(150,*,end=8) statname(ir),nuse(ir),	  ! nuse=0 ... station not used 
     *            weig(ir,1),weig(ir,2),weig(ir,3), ! weig=0 ... component not used
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


      do ir=1,nr               !!!!!!!!!1.2.2015
	keygps(ir)=0.
	enddo



c      do ir=1,nr
c      numf1=1000+(ir*1)
c      numf2=2000+(ir*1)
c      numf3=3000+(ir*1)
c      statfil1=statname(ir)//'raw.dat'
c      statfil2=statname(ir)//'fil.dat'
c      statfil3=statname(ir)//'res.dat'
c      open(numf1,file=statfil1)
c      open(numf2,file=statfil2)
c      open(numf3,file=statfil3)
c      enddo


c      do ir=1,nr
c        do icom=1,3
c       weig(ir,icom)=(1./weig(ir,icom)) * vardat   ! this gives overflow
c        weig(ir,icom)=(1./weig(ir,icom))
c        enddo
c      enddo



      read(151,*) 
      read(151,*) keyinv
      read(151,*) 
      read(151,*) dt
      read(151,*) 
      read(151,*) isourmax
      read(151,*) 
      read(151,*) 
c      read(151,*) ifirst,istep,ilast
      read(151,*) ibegin,istep,ilast
	ifirst=ibegin-istep

      read(151,*) 
      read(151,*) isubmax
      read(151,*) 
      read(151,*) 
      read(151,*) f1,f2,f3,f4	! not used (read from allstat)
      read(151,*)
      read(151,*) vardat	! used

      if(keyinv.ne.1) keyinv=1
	 write(*,*) 'this code needs keyinv=1, FULL MT'
	 write(*,*) 'artifically set up to FULL mode' 
     	nmom=6


 6677 CONTINUE
c       find source number
      open(11,file='srcno.dat')   !! GUI creates this
      read(11,*) iselect
      close(11)
cc   write(*,*) 'Working for source number',iselect
cc	write(*,*) 'iselect=?'
cc	read(*,*)   iselect

      filename='elemse'//chr(iselect)//'.dat'

      call elemat15_write(keygps,filename,w,rold,rinv)  ! analyzing system matrix for the best position (independent of time shift) 
	                                    ! iselect and w correspond to the best position
	! NEW march 2015: subroutine does not return rinv because it is not needed in ISO

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
    
        write(61,*) '1'
        close(61)       ! end of code run

	STOP





      END

c =================================================================

c      include "manidata.inc"
      include "elemat15_write.inc"
c      include "oneinv2.inc"
c      include "cnsinv2.inc"
c      include "fixinv2.inc"
c      include "subevnt.inc"

c      include "lagra.inc"
c      include "determi.inc"

c      include "fcoolr.inc"
      include "filter15.inc"
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
      include "ptaxes.inc"
      include "pl2pt.inc"

