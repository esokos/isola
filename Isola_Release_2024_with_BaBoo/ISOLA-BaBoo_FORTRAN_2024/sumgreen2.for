      program sumgreen2
C Grid points have NON-unit moments (moment distribution is NON-uniform over fault)
C Resulting elemse will be for unit total moment (as every elemse should be)

      parameter   (nfp=1000,nrp=31)
c     dimension x(99),y(99),z(99),shift(99)
      dimension shift(99),xmom(99)
      complex*16  uxf(nfp,nrp,6),uyf(nfp,nrp,6),uzf(nfp,nrp,6)
	complex*16  uxfsum(nfp,nrp,6),uyfsum(nfp,nrp,6),uzfsum(nfp,nrp,6)
	complex*16  ushift,ai,omega

c      CHARACTER *11 filename ! Cteni graux**.hes
      CHARACTER *8 filename   ! Cteni klasickych gr**.hes
	CHARACTER *2 chr(99)


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


      namelist    /input/ nc,nfreq,tl,aw,nr,ns,xl,
     &                    ikmax,uconv,fref

         
     
	if(nfreq.gt.nfp.or.nr.gt.nrp) then
	write(*,*) 'problem dimension 1'
	stop
      endif



c      open(100,file='sour_xy.dat') 
       open(100,file='finsour.dat') 

      is=1
  10  read(100,*,end=20) dum,shift(is),xmom(is) !  shift and moment is read 
c      if(xmom(is).ne.0) xmom(is)=1. ! xmom bude bud 1 nebo 0 !!!!!!!!! OLD (sumgreen.for)
      if(xmom(is).ne.0) xmom(is)=xmom(is) ! Berou se predepsane momenty 
      is=is+1
      goto 10
  20  continue
      nss=is-1
      write(*,*) 'number of sub-source points= ',nss

      sumxmom=0.       ! total moment
   	  do is=1,nss
      sumxmom=sumxmom+xmom(is)
      enddo   	  
	  
	  
	if(nss.gt.99) then
	write(*,*) 'problem dimension 2'
	stop
      endif


      open(10,form='formatted',file='grdat.hed') 
	read(10,input)
	close(10)

      do jf=1,nfreq  ! loop over frequency
      do ir=1,nr   ! loop over stations
	do it=1,6	 ! loop over 6 elem. tensors
	uxfsum(jf,ir,it)=0.
	uyfsum(jf,ir,it)=0.
	uzfsum(jf,ir,it)=0. 
      enddo
	enddo
	enddo

      ai=cmplx(0.,1.)
      PI=3.141592
      aw=-pi*aw/tl !!!!!!! aw redefined here 
      
      
c reading gr**.hes of sub-sources, shifting and summing up
 
	do is=1,nss  
c      filename='graux'//chr(is)//'.hes'      !!!!!! Puvodni
      filename='gr'//chr(is)//'.hes'       !!!! NOVE ctou se standardi g**.hes zakladni site 

c	open(11,form='unformatted',file=filename)   
      open (11,form='unformatted',file=filename,access='stream') ! Ifort (input)



      do jf=1,nfreq  ! loop over frequency
	frr=(1./tl)*float(jf-1)
      omega=cmplx(2.*pi*frr,aw)
c	ushift=CDEXP(-2.*pi*frr*ai**shift(is))	 !!!!! POZOR frnce zde je realna ! aprox
c	ushift=CDEXP(-omega    *ai*shift(is))	 !!!!! POZOR frnce zde je komplexni MNOHEM LEPSI
	ushift=xmom(is)* CDEXP(-omega    *ai*shift(is))	 !!!!! 
c Po secteni greenovek nasleduje jen JEDEN elemse kde je zpetna korekce
c Pri ekvivalentnim vypoctu pomoci finsouru se pro kazy bod pouziva jedno elemse
c a v kazdem z nich je ten zpetny posun. Proto zde musi byt vsechny posuny kdyz jsou
c pak korigovany jed jednim elemse  
c
	write(*,*) ushift
      do ir=1,nr   ! loop over stations
	read(11)(uxf(jf,ir,it),it=1,6)
      read(11)(uyf(jf,ir,it),it=1,6)
	read(11)(uzf(jf,ir,it),it=1,6)
      	do it=1,6
          uxf(jf,ir,it)=uxf(jf,ir,it)*ushift
	    uyf(jf,ir,it)=uyf(jf,ir,it)*ushift
	    uzf(jf,ir,it)=uzf(jf,ir,it)*ushift
	    enddo 
       do it=1,6
  	 uxfsum(jf,ir,it)=uxfsum(jf,ir,it)+uxf(jf,ir,it)
  	 uyfsum(jf,ir,it)=uyfsum(jf,ir,it)+uyf(jf,ir,it)
  	 uzfsum(jf,ir,it)=uzfsum(jf,ir,it)+uzf(jf,ir,it)
c  	 uxfsum(jf,ir,it)=uxf(jf,ir,it)
c  	 uyfsum(jf,ir,it)=uyf(jf,ir,it)
c  	 uzfsum(jf,ir,it)=uzf(jf,ir,it)
       enddo
	enddo	! loop over stations
      enddo   ! loop over frequency     
	close(11)
	enddo !loop over subsources

	nlim=0
	do is=1,nss
	if(xmom(is).ne.0) nlim=nlim+1
	enddo
      write(*,*) '# of non-zero moments',nlim


C POZOR je nutno delit poctem zdroju s nenul mom=1, jinak se porovanim s realnymi seismo stanovi nns-krat mensi moment      
	do jf=1,nfreq  ! loop over frequency
      do ir=1,nr   ! loop over stations
	do it=1,6	 ! loop over 6 elem. tensors
c	uxfsum(jf,ir,it)=uxfsum(jf,ir,it)/float(nlim) !(nss)
c	uyfsum(jf,ir,it)=uyfsum(jf,ir,it)/float(nlim) !(nss)
c	uzfsum(jf,ir,it)=uzfsum(jf,ir,it)/float(nlim) !(nss) 

C Zde nove se misto toho deli celkovym momentem
	uxfsum(jf,ir,it)=uxfsum(jf,ir,it)/sumxmom                 ! NEW 
	uyfsum(jf,ir,it)=uyfsum(jf,ir,it)/sumxmom
	uzfsum(jf,ir,it)=uzfsum(jf,ir,it)/sumxmom 
      enddo
	enddo
	enddo

c writing final gr.hes for the finite source

c      open (12,form='unformatted',file='grsum.hes')   

      open (12,form='unformatted',file='grsum.hes',access='stream', ! Ifort (output)
     *      status='replace')

	  
      do jf=1,nfreq  ! loop over frequency
      do ir=1,nr   ! loop over stations
	 write(12)(uxfsum(jf,ir,it),it=1,6)
	 write(12)(uyfsum(jf,ir,it),it=1,6)
	 write(12)(uzfsum(jf,ir,it),it=1,6)
       enddo	! loop over stations
      enddo   ! loop over frequency     
	close(12)

	stop
      end