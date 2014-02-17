      program ISO11b

c       automatically for FULLmt
c       NO DATA NEEDED (only to produce VECT and SING)
c       output of singular vectors (eigenvectors of GTG) 
c             and singular values of G (sqrt of eigenvalues of GTG)

c     Author: J. Zahradnik 2011


      CHARACTER *2 CHR(99)
      CHARACTER *1 reply
      CHARACTER *12 filename
      CHARACTER *3 statname(21)
      character *17 statfil1,statfil2,statfil3  !!g77
      character *10  corrfile

      dimension xinv(8192,21,3)
      dimension ori(8192,21,3)
      dimension sx(8192,21,3)
      dimension syn(8192,21,3)
      dimension finr(8192,21,3)		 ! 21 = max number of stations
      dimension w(-2500:10692,21,3,6)  !  6 = full moment, 5 = deviatoric only 
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
     *                 f1,f2,f3,f4,dt
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
  
      

c     FIXED OPTIONS
      ntim=8192 ! number of time samples  
      
	aopt(6)=0.
	vopt(6)=0.
      aoptsum(6)=0.
      
	ir=1
  7   read(150,*,end=8) statname(ir),nuse(ir),	 ! weig is NOT weight, but 1./weight
     *            weig(ir,1),weig(ir,2),weig(ir,3) ! weig=1 used, weig=100 not used; later in GUI make weig proportinal to distance
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
        do icom=1,3
c       weig(ir,icom)=(1./weig(ir,icom)) * vardat   ! this gives overflow
        weig(ir,icom)=(1./weig(ir,icom))
        enddo
      enddo



      read(151,*) 
      read(151,*) keyinv	  ! arbitrary
      read(151,*) 
      read(151,*) dt		  ! used
      read(151,*) 
      read(151,*) isourmax  ! not used 
      read(151,*) 
      read(151,*) 
      read(151,*) ifirst,istep,ilast ! not used
      read(151,*) 
      read(151,*) isubmax	   ! not used
      read(151,*) 
      read(151,*) 
      read(151,*) f1,f2,f3,f4 ! used
      read(151,*)
      read(151,*) vardat	! used

      if(keyinv.ne.1) keyinv=1
	 write(*,*) 'this code needs keyinv=1, FULL MT'
	 write(*,*) 'artifically set up to FULL mode' 
     	nmom=6


c	write(*,*) 'iselect=?'
c	read(*,*)   iselect
      isourmax=99			 !!!!!!!!!!!!FIXED OPTIONS
	iselect=99             
	isubmax=1

      filename='elemse'//chr(iselect)//'.dat'

      call elemat2(filename,w,rold,rinv)   

      do im=1,nmom
      do jm=1,nmom
      gold(im,jm)=rold(im,jm)	  ! rold comes multiplied by 1e20
      enddo
      enddo

  	     

	call JACOBInr(gold,nmom,6,en,vv,nrot) 
	do im=1,nmom			  ! converting eigenvalues of GTG into sing. values of G
c             ! introducing (a constant) data variance, vardat, here is the same as to divide GTG by vardat  
	en(im)=sqrt(en(im)/vardat)/1.e10 ! sqrt to get SING values; corrected for previous formal 1.e20
    	enddo
  
	open(6789,file='vect.dat')	! sing. vectors will be printed in columns
	do im=1,nmom
	write(6789,'(6e15.6)') (vv(im,jm),jm=1,nmom) ! im...comp, jm... vector
	enddo
	close(6789)

	open(7789,file='sing.dat')	! sing values (inlcuding vardat), same order as sing. vectors
	write(7789,'(6e15.6)') (en(jm),jm=1,nmom) 
 	close(7789)


	STOP

      END

c =================================================================

      include "manidata.inc"
      include "elemat2.inc"
      include "oneinv2.inc"
      include "cnsinv2.inc"
      include "fixinv2.inc"
      include "subevnt.inc"
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
      include "pl2pt.inc"

