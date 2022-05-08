      program conshift

c
ccc       fixed  ntim  !!! new definition of mm via ntim
c         fixed moment rate = delta (i.e. moment = step, see line 92)

c
c   Convolution  of Green fctn with moment tensor.
c   Program CO modified from CONVOL (of O. Coutant)
c   J.Zahradnik, 1997  and 1998
ccccc
ccccc  Added option to read source type from soutype.dat file
c      t. 07/01/12
c
c         3 components  (e,n,z or t,r,z) at 3 stations (cl,eg,ka)
c          output in 3 files according to STATIONS!!!

      integer      nsp,nrp,ncp,ntp,nrtp,icc,ics,if,ic
      real         lat0,lon0
      parameter   (nsp=1,ncp=200,nrp=21,ntp=8192,nrtp=nrp*ntp)
      parameter   (lon0=-118,lat0=34,stdlat1=33,stdlat2=45)


      integer     iwk(ntp),jf,ir,is,it,nc,ns,nr,nfreq,ikmax,mm,nt,
     1            isc(nsp)
      real        hc(ncp),vp(ncp),vs(ncp),rho(ncp),delay(nsp),
     1            xr(nrp),yr(nrp),zr(nrp),a(6,nsp),qp(ncp),qs(ncp),
     2            tl,xl,uconv,mu(nsp),strike(nsp),dip(nsp),
     3            rake(nsp),disp(nsp),hh,zsc,dfreq,freq,
     4            pi,pi2,xs(nsp),ys(nsp),zs(nsp),aw,ck,xmm,cc,
     5            uout(ntp),pas,width(nsp),length(nsp),
     7            t1
      complex*16  ux(ntp,nrp),uy(ntp,nrp),uz(ntp,nrp),omega,
     1            uxf(6),uyf(6),uzf(6),ai,deriv,fsource,us,uux,uuy,uuz

      CHARACTER *5 statname(21)
      CHARACTER *17 statfil1

      common      /par/ai,pi,pi2
      namelist    /input/ nc,nfreq,tl,aw,nr,ns,xl,
     &                    ikmax,uconv,fref

c      data        ux,uy,uz/nrtp*(0.,0.),nrtp*(0.,0.),
c     &                     nrtp*(0.,0.)/


      ntim=8192

 	do ir=1,nrp	 ! (compilation last long time or even cannot succssfully end)
 	do itim=1,ntp  			   ! thn THIS initiation solves the problem
 	ux(itim,ir)=(0.,0.)
 	uy(itim,ir)=(0.,0.)
 	uz(itim,ir)=(0.,0.)
      enddo
      enddo
      

c $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      pi=3.1415926535
      pi2=2.*pi
      ai=(0.,1.)        
c pro posun vlevo dej vhodne dt0<0
      dt0=0.

      open (12,form='unformatted',file='gr.hes')
      open (10,form='formatted',file='gr.hea')
      read(10,input)
      if ((ns.gt.nsp).or.(nr.gt.nrp).or.(nc.gt.ncp)) then
       write(0,*) "check dimensions!"
       stop
      endif
c     open (13,form='formatted',file='source.dat')
c     open (14,form='formatted',file='station.dat')
      open (15,form='formatted',file='mechan.dat')
c    xxxxxxxxxxxxxxxxx

      open(100,file='allstat.dat')   ! maximum 21 stations


      do ir=1,nr
      read(100,*) statname(ir),dum,dum,dum,dum
c      write(*,*) statname(ir)
      enddo

      do ir=1,nr
      numf1=2000+(ir*1)
      statfil1='s'//trim(statname(ir))//'row.dat'
c      write(*,*) statfil1
      open(numf1,file=statfil1)
      enddo
c xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

c     open(111,file='aaa.dat')

cccccccc  read the source type from file !!! thimios 07/01/12

	open(301,file='soutype.dat')
	read(301,'(i1)') ics
c	read(301,'(f4.1)') t0	! old
	read(301,*)        t0	! new
	read(301,'(f3.1)') t1
        read(301,'(i1)') icc
	close(301)
c
        if (ics.eq.7) then
          write(*,*) "Delta source type selected"
        else if (ics.eq.4) then
          write(*,*) "Triangle source type selected. Duration = ", t0
        endif
c        
c
c  true step
c       ics=7   !true step
c       t1=0.
c       icc=2   !VELOC
cccccccccccccccccccccccccc
c  moment time fctn fsource
c     ics=2                ! Bouchon's smooth step
c     t0=0.5
c     t1=1.
c     icc=2                ! output time series will be velocity
cccccccccccccccccccccccccc
c  moment time fctn fsource
c       ics=4                !triangle (unit moment; unit spectr at f=0)
c       t0=10.  ! duration (pro zviditelneni statiky lepe delsi trvani, jinak prevladne daleka zona)
c       t1=1.
c       icc=1                ! POZOR formalne displ ale da to  velocity
cccccccccccccccccccccccccc
c  moment time fctn fsource
c     ics=9                !Brune
c     t0=0.1
c     t1=1.
c     icc=1                ! POZOR s Brunem je to VELO
cccccccccccccccccccccccccc
c  moment time fctn fsource
c     ics=3                !  sp ze souboru *.sou
c     t0=6
c     t1=1.
c     icc=1                ! POZOR formalne displ ale da to  velocity
cccccccccccccccccccccccccc
      icc=icc-1
c
c++++++++++++
c                 Milieu, stations et sources
c++++++++++++
      read(10,*)
      do 3 ic=1,nc
 3    read(10,*) hc(ic),vp(ic),vs(ic),rho(ic),qp(ic),qs(ic)
      read(10,*)
      do is=1,ns !cykl pres zdroje
c 
c     read(13,*) index,xs(is),ys(is),zs(is)
      if(ns.gt.1) then
       write(*,*) 'more than one source not allowed in this version'
       stop
      endif
ccccc
c     read(13,*)
c     read(13,*)
c     read(13,*) xs(is),ys(is),zs(is)
c      xs(is)=xs(is)*1000.
c      ys(is)=ys(is)*1000.
c      zs(is)=zs(is)*1000.
      index=1
ccccc
       indexin=-1
       rewind(15)
c      do while (indexin.ne.index)
c	read(15,*) indexin,disp(is),strike(is),dip(is),
c    1            rake(is),width(is),length(is),delay(is)
c      enddo
cccccc
        read(15,*)
        read(15,*)
 	read(15,*) disp(is)
        read(15,*)
 	read(15,*) strike(is),dip(is),rake(is)
        read(15,*)
 	read(15,*) delay(is)
        indexin=1
        width(is)=0.  ! fixed to have DC source
        length(is)=0. ! fixed to have DC source
c       delay(is)=0.  !!!!! new ; now it is read; see above
cccccc
       delay(is)=delay(is)+dt0
      enddo  !konec cyklu pres zdroje
c     read(14,*)
c     read(14,*)
c     do ir=1,nr   !cykl pres prijimace,    jen cteni polohy
c      read(14,*) xr(ir),yr(ir),zr(ir)
c       xr(ir)=xr(ir)*1000.
c       yr(ir)=yr(ir)*1000.
c       zr(ir)=zr(ir)*1000.
c     enddo

c++++++++++++
c       Parametres sources    dlouha cast jen kvuli tomu
c                abych si automaticky zjistil mu v hloubce zdroje
c                  pokud ho zadam, zbytecne
c++++++++++++
c     convertion depth -> thickness
      if (hc(1).eq.0.) then
	do ic=1,nc-1
	 hc(ic)=hc(ic+1)-hc(ic)
	enddo
      endif

      do is=1,ns
	hh=0.
	isc(is)=1
	zsc=zs(is)
	do ic=1,nc-1
	 hh=hc(ic)
	 if (zsc.gt.hh) then
	  zsc=zsc-hh
	  isc(is)=ic+1
	 else
	  goto 91
	 endif
	enddo
  91    continue
      mu(is)=vs(isc(is))*vs(isc(is))*rho(isc(is))
      call cmoment (mu(is),strike(is),dip(is),
     &             rake(is),disp(is),width(is)*length(is),a(1,is))

c      write(111,*) a(1,is)
c      write(111,*) a(2,is)
c      write(111,*) a(3,is)
c      write(111,*) a(4,is)
c      write(111,*) a(5,is)
c      write(111,*) a(6,is)
      enddo  !konec cyklu pres zdroje


c++++++++++++
c       Lecture fonctions de transfert
c++++++++++++
c      automaticke urceni delky cas. rady 2**mm
      xmm=log(real(nfreq))/log(2.)
ccccccccccccccccccccccccccc
c     mm=int(xmm)+2
c     mm=int(xmm)+4  !!! moje zmena
c                    !!! muze skazit abs. velikost diky blbemu fft
c      mm=13          !!!!fixed to 8192 points
       mm=int(log(real(ntim))/log(2.))
ccccccccccccccccccccccccccc
      nt=2**mm
      if (nt.gt.ntp) then
	write(0,*) 'check dimen. nt !!!'
	stop
      endif
      dfreq=1./tl
      pas=tl/float(nt)      
      aw=-pi*aw/tl ! aw re-defined here
    
       
      do 5 jf=1,nfreq  !cykl pres frnce
       freq=float(jf-1)/tl
       omega=cmplx(pi2*freq,aw)
       deriv=(ai*omega)**icc

       read(10,*,end=2000)
       do is=1,ns   !cykl pres zdroje
c pozor aby t1 bylo def, kus jsem smazal
	us=fsource(ics,omega,t0,t1,pas) *
     1     deriv * exp(-ai*omega*delay(is))

c	if(jf.eq.1) us=us*0.00      ! Pakzad ZERO freq. ?

	 do ir=1,nr   !cykl pres stanice
	 read(12,end=2000)(uxf(it),it=1,6)
	 read(12,end=2000)(uyf(it),it=1,6)
	 read(12,end=2000)(uzf(it),it=1,6)
	

      
       uux=0.
	 uuy=0.
	 uuz=0.
	 do it=1,6
	   uux = uux + uxf(it)*a(it,is)
	   uuy = uuy + uyf(it)*a(it,is)
	   uuz = uuz + uzf(it)*a(it,is)
	
	 enddo
 	 ux(jf,ir)=ux(jf,ir) + uux * us
 	 uy(jf,ir)=uy(jf,ir) + uuy * us
 	 uz(jf,ir)=uz(jf,ir) + uuz * us

      
       enddo            !fin boucle recepteur nr
       enddo            !fin boucle source ns; pres ty se SCITA
 5    continue          !fin boucle frequence nfreq
      goto 2001
 2000 nfreq=jf-1
 2001 continue


c++++++++++++
c                Calcul des sismogrammes
c++++++++++++
c PRIDANO ************************************************
c     open(26,file='conx.dat')
c     open(27,file='cony.dat')
c     open(28,file='conz.dat')
c     open(26,file='synclrow.dat')
c     open(27,file='synegrow.dat')
c     open(28,file='synkarow.dat')


      tkrok=tl/float(nt)
      do 30 ir=1,nr  !cykl pres stanice

c               on complete le spectre pour les hautes frequences
c               avec inversion du signe de la partie imaginaire pour
c               la FFT inverse qui n'existe pas avec fft2cd
      do if=nt+2-nfreq,nt

      ux(if,ir)=conjg(ux(nt+2-if,ir))
      uy(if,ir)=conjg(uy(nt+2-if,ir))
      uz(if,ir)=conjg(uz(nt+2-if,ir))
      enddo

      call fft2cd(ux(1,ir),mm,iwk)
      call fft2cd(uy(1,ir),mm,iwk)
      call fft2cd(uz(1,ir),mm,iwk)
      
   
      do it=1,nt
	ck=float(it-1)/nt
	cc=exp(-aw*tl*ck)/tl   !!! zpetna korekce umele absorpce = artif enhancement

c      cc=1./tl ! this will suppress exp() enhancement but MUST keep division by TL
c   ! for special experimenst only    

	ux(it,ir)=ux(it,ir)*cc
	uy(it,ir)=uy(it,ir)*cc
	uz(it,ir)=uz(it,ir)*cc
      
      enddo

c ZDE SE PRIPRAVIL VYSTUP ux DO POLE UOUT(1azNT) **********
cc    do it=1,nt
cc    ttt=float(it-1)*tkrok
cc      uout(it)=real(ux(it,ir))
cc      write(26,'(2(1x,e10.4))') ttt,uout(it)
cc    enddo
cc    write(26,*) '*'
c ZDE SE PRIPRAVIL VYSTP uy, OPET DO POLE  UOUT(1azNT) ****
c     do it=1,nt
c      ttt=float(it-1)*tkrok
c       uout(it)=real(uy(it,ir))
c      write(27,'(2(1x,e10.4))') ttt,uout(it)
c     enddo
c     write(27,*) '*'
c ZDE SE PRIPRAVIL VYSTUP uz, opet !! DO POLE UOUT(1azNT) ***
c     do it=1,nt
c      ttt=float(it-1)*tkrok
c       uout(it)=real(uz(it,ir))
c      write(28,'(2(1x,e10.4))') ttt,uout(it)
c     enddo
c     write(28,*) '*'
c
cccccccccccccc ************ CCCCCCCCCCCCCCCC
  30  continue          !konec cyklu pres stanice
cccccccccccccc ************ CCCCCCCCCCCCCCCC
c vystup seismo jako cas. hladin spolecne pro vsechny stanice
c            organizovan po slozkach
c     do 1040 it=1,nt
c     write(26,'(2(1x,e10.4))') (real(ux(it,ir)),ir=1,nr)
c1040 continue
c     do 1050 it=1,nt
c     write(27,'(2(1x,e10.4))') (real(uy(it,ir)),ir=1,nr)
c1050 continue
c     do 1060 it=1,nt
c     write(28,'(2(1x,e10.4))') (real(uz(it,ir)),ir=1,nr)
c1060 continue
cccccccccccccc ************ CCCCCCCCCCCCCCCC
c vystup seismo jako cas. hladin spolecne pro vsechny stanice
c            organizovan po stanicich

      do ir=1,nr
      nofl=2000+ir*1
      do 1040 it=1,nt    !!!!!!!!!!! NEW  muzes dat nt/2!!
      time=float(it-1)*tkrok
      write(nofl,'(4(1x,e12.6))')
     *   time,real(ux(it,ir)),real(uy(it,ir)),real(uz(it,ir))
 1040 continue

      enddo
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
	stop
	end

      subroutine cmoment (mu,strike,dip,
     1             rake,disp,surf,a)

      implicit none

      real      xmoment,mu,strike,dip,rake,disp,surf,a(6),pi2,
     1          sd,cd,sp,cp,s2p,s2d,c2p,c2d,x1,x2,x3,x4,x5,x6,cl,sl,pi
      complex*16 ai
      common      /par/ai,pi,pi2

	if (surf.eq.0.) then
	  xmoment=disp
	else
	  xmoment=mu*disp*surf
	endif
	write(6,*) "moment (Nm):",xmoment
	write(6,*) "moment (Dyne.cm):",xmoment*1.e7
	strike=strike*pi/180.
	dip=dip*pi/180.
	rake=rake*pi/180.
	sd=sin(dip)
	cd=cos(dip)
	sp=sin(strike)
	cp=cos(strike)
	sl=sin(rake)
	cl=cos(rake)
	s2p=2.*sp*cp
	s2d=2.*sd*cd
	c2p=cp*cp-sp*sp
	c2d=cd*cd-sd*sd

c       Coefficient pour les sources Mxx,Mxy,Mxz,Myy,Myz,Mzz
	x1 =-(sd*cl*s2p + s2d*sl*sp*sp)*xmoment
	x2 = (sd*cl*c2p + s2d*sl*s2p/2.)*xmoment
	x3 =-(cd*cl*cp  + c2d*sl*sp)*xmoment
	x4 = (sd*cl*s2p - s2d*sl*cp*cp)*xmoment
	x5 =-(cd*cl*sp  - c2d*sl*cp)*xmoment
	x6 =             (s2d*sl)*xmoment

c 100% ISO

c	x1=1.
c	x2=0.
c	x3=0.
c	x4=1.
c	x5=0.
c	x6=1.

c 100% CLVD

c	x1=1.
c	x2=0.
c	x3=0.
c	x4=1.
c	x5=0.
c	x6=-2.

c mix

c	x1=1.
c	x2=1.
c	x3=1.
c	x4=1.
c	x5=1.
c	x6=2.
c
	
c       Coefficient pour les sources bis (5 dislocations elementaires
c       et une source isotrope)
      
       
 	a(1) = x2
 	a(2) = x3
 	a(3) =-x5
 	a(4) = (-2.*x1 + x4 + x6)/3.
 	a(5) = (x1 -2*x4 + x6)/3.
c        a(6) =  0.
	a(6) = (x1+x4+x6)/3. ! obecne; pro vyse predepsane x' to da cistou nulu
                    ! pokud zadam x1...x6 jako nonDC, bude to take pocitat dobre

        write(*,*) 'a1,2,3,4,5,6'
        write(*,*) a(1),a(2),a(3),a(4),a(5),a(6)

c        a(1) = 2.*x2   ! tohle nevim kde se vzalo; je to divne
c        a(2) = 2.*x3
c        a(3) = -2.*x5
c        a(4) = -x1+x6
c        a(5) = -x4+x6
c        a(6) = x1+x4+x6

      if(surf.eq.-1.) then
      xmoment=disp
	a(1)=0.
	a(2)=0.
	a(3)=0.
	a(4)=0.
	a(5)=0.
	a(6)=xmoment
      endif
      
      return
      end
	subroutine  fft2cd (a,m,iwk)                                       
c                                  specifications for arguments         
	implicit real*8 (a-h,o-z)
	integer            m,iwk(*)                                       
	complex*16      a(*)                                           
c                                  specifications for local variables   
	integer     i,isp,j,jj,jsp,k,k0,k1,k2,k3,kb,
     &              kn,mk,mm,mp,n,n4,n8,n2,lm,nn,jk 
	real*8      rad,c1,c2,c3,s1,s2,s3,ck,sk,sq,a0,a1,a2,a3,    
     &              b0,b1,b2,b3,twopi,temp,                        
     &              zero,one,z0(2),z1(2),z2(2),z3(2)               
	complex*16  za0,za1,za2,za3,ak2                            
	equivalence  (za0,z0(1)),(za1,z1(1)),(za2,z2(1)),           
     &              (za3,z3(1)),(a0,z0(1)),(b0,z0(2)),(a1,z1(1)),  
     &              (b1,z1(2)),(a2,z2(1)),(b2,z2(2)),(a3,z3(1)),   
     &              (b3,z3(2))                                     
	data        sq,sk,ck,twopi/.7071068,.3826834,
     &              .9238795,6.283185/                                
	data        zero/0.0/,one/1.0/                             
c                   sq=sqrt2/2,sk=sin(pi/8),ck=cos(pi/8) 
c                   twopi=2*pi                           
c                                  first executable statement           
	mp = m+1                                                          
	n = 2**m                                                          
	iwk(1) = 1                                                        
	mm = (m/2)*2                                                      
	kn = n+1                                                          
c                                  initialize work vector               
	do 5  i=2,mp                                                      
	   iwk(i) = iwk(i-1)+iwk(i-1)                                     
5       continue                                                          
	rad = twopi/n                                                     
	mk = m - 4                                                        
	kb = 1                                                            
	if (mm .eq. m) go to 15                                           
	k2 = kn                                                           
	k0 = iwk(mm+1) + kb                                               
10      k2 = k2 - 1                                                       
	k0 = k0 - 1                                                       
	ak2 = a(k2)                                                       
	a(k2) = a(k0) - ak2                                               
	a(k0) = a(k0) + ak2                                               
	if (k0 .gt. kb) go to 10                                          
15      c1 = one                                                          
	s1 = zero                                                         
	jj = 0                                                            
	k = mm - 1                                                        
	j = 4                                                             
	if (k .ge. 1) go to 30                                            
	go to 70                                                          
20      if (iwk(j) .gt. jj) go to 25                                      
	jj = jj - iwk(j)                                                  
	j = j-1                                                           
	if (iwk(j) .gt. jj) go to 25                                      
	jj = jj - iwk(j)                                                  
	j = j - 1                                                         
	k = k + 2                                                         
	go to 20                                                          
25      jj = iwk(j) + jj                                                  
	j = 4                                                             
30      isp = iwk(k)                                                      
	if (jj .eq. 0) go to 40                                           
c                                  reset trigonometric parameter(s       )
	c2 = jj * isp * rad                                               
	c1 = cos(c2)                                                      
	s1 = sin(c2)                                                      
35      c2 = c1 * c1 - s1 * s1                                            
	s2 = c1 * (s1 + s1)                                               
	c3 = c2 * c1 - s2 * s1                                            
	s3 = c2 * s1 + s2 * c1                                            
40      jsp = isp + kb                                                    
c                                  determine fourier coefficients       
c                                    in groups of 4                     
	do 50 i=1,isp                                                     
	   k0 = jsp - i                                                   
	   k1 = k0 + isp                                                  
	   k2 = k1 + isp                                                  
	   k3 = k2 + isp                                                  
	   za0 = a(k0)                                                    
	   za1 = a(k1)                                                    
	   za2 = a(k2)                                                    
	   za3 = a(k3)                                                    
	   if (s1 .eq. zero) go to 45                                     
	   temp = a1                                                      
	   a1 = a1 * c1 - b1 * s1                                         
	   b1 = temp * s1 + b1 * c1                                       
	   temp = a2                                                      
	   a2 = a2 * c2 - b2 * s2                                         
	   b2 = temp * s2 + b2 * c2                                       
	   temp = a3                                                      
	   a3 = a3 * c3 - b3 * s3                                         
	   b3 = temp * s3 + b3 * c3                                       
45         temp = a0 + a2                                                 
	   a2 = a0 - a2                                                   
	   a0 = temp                                                      
	   temp = a1 + a3                                                 
	   a3 = a1 - a3                                                   
	   a1 = temp                                                      
	   temp = b0 + b2                                                 
	   b2 = b0 - b2                                                   
	   b0 = temp                                                      
	   temp = b1 + b3                                                 
	   b3 = b1 - b3                                                   
	   b1 = temp                                                      
	   a(k0) = cmplx(a0+a1,b0+b1)                                     
	   a(k1) = cmplx(a0-a1,b0-b1)                                     
	   a(k2) = cmplx(a2-b3,b2+a3)                                     
	   a(k3) = cmplx(a2+b3,b2-a3)                                     
50      continue                                                          
	if (k .le. 1) go to 55                                            
	k = k - 2                                                         
	go to 30                                                          
55      kb = k3 + isp                                                     
c                                  check for completion of final        
c                                    iteration                          
	if (kn .le. kb) go to 70                                          
	if (j .ne. 1) go to 60                                            
	k = 3                                                             
	j = mk                                                            
	go to 20                                                          
60      j = j - 1                                                         
	c2 = c1                                                           
	if (j .ne. 2) go to 65                                            
	c1 = c1 * ck + s1 * sk                                            
	s1 = s1 * ck - c2 * sk                                            
	go to 35                                                          
65      c1 = (c1 - s1) * sq                                               
	s1 = (c2 + s1) * sq                                               
	go to 35                                                          
70      continue                                                          
c                                  permute the complex vector in        
c                                    reverse binary order to normal     
c                                    order                              
	if(m .le. 1) go to 9005                                           
	mp = m+1                                                          
	jj = 1                                                            
c                                  initialize work vector               
	iwk(1) = 1                                                        
	do 75  i = 2,mp                                                   
	   iwk(i) = iwk(i-1) * 2                                          
75      continue                                                          
	n4 = iwk(mp-2)                                                    
	if (m .gt. 2) n8 = iwk(mp-3)                                      
	n2 = iwk(mp-1)                                                    
	lm = n2                                                           
	nn = iwk(mp)+1                                                    
	mp = mp-4                                                         
c                                  determine indices and switch a       
	j = 2                                                             
80      jk = jj + n2                                                      
	ak2 = a(j)                                                        
	a(j) = a(jk)                                                      
	a(jk) = ak2                                                       
	j = j+1                                                           
	if (jj .gt. n4) go to 85                                          
	jj = jj + n4                                                      
	go to 105                                                         
85      jj = jj - n4                                                      
	if (jj .gt. n8) go to 90                                          
	jj = jj + n8                                                      
	go to 105                                                         
90      jj = jj - n8                                                      
	k = mp                                                            
95      if (iwk(k) .ge. jj) go to 100                                     
	jj = jj - iwk(k)                                                  
	k = k - 1                                                         
	go to 95                                                          
100     jj = iwk(k) + jj                                                  
105     if (jj .le. j) go to 110                                          
	k = nn - j                                                        
	jk = nn - jj                                                      
	ak2 = a(j)                                                        
	a(j) = a(jj)                                                      
	a(jj) = ak2                                                       
	ak2 = a(k)                                                        
	a(k) = a(jk)                                                      
	a(jk) = ak2                                                       
110     j = j + 1                                                         
c                                  cycle repeated until limiting number 
c                                    of changes is achieved             
	if (j .le. lm) go to 80                                           
c                                                                       
9005    return                                                            
	end                                                               
c @(#) fsource.F       FSOURCE 1.4      11/17/92 1
c**********************************************************
c       FSOURCE
c       
c       Different kind of source function defined in the 
c       frequency domain
c       Source function for dislocation (step, ramp, haskell)
c       are normalized so that in far-field the low-frequency 
c       level is proportionnal to the seismic moment with a factor
c       equals to: Rad/(4.PI.rho.beta^3) * 1./r 
c       where Rad= Radiation coefficient with (possibly) 
c       free surface effect
c
c       input:  
c               type    ->      see below
c               omega   ->      angular frequency
c               t0,t1   ->      time constant when needed
c               dt      ->      sampling rate
c**********************************************************

	function        fsource (type, omega, t0, t1, dt)

	implicit        none
	integer         type
	real            pi,pi2,dt,t0,t1
	real*8          uur,uui,trise,trupt
	complex*16      fsource,uu,uex,uxx,omega,shx,ai,omegac

	common  /par/   ai,pi,pi2

c TYPE=0               Source = Dirac en deplacement
	if (type.eq.0) then
	  fsource=1
	endif
 
c TYPE=1        Source = Ricker en deplacement
	if (type.eq.1) then
	  uu=omega*t0
	  uu=uu*uu/pi2/pi2
	  uu=exp(-uu)
	  uu=omega*omega*uu*dt
	  fsource= uu
	endif
 
c TYPE=2        Source = step en deplacement
c               2 steps possibles (1) real=1/(ai*omega)
c                                 (2) bouchon's
	if (type.eq.2) then
	  shx=exp(omega*pi*t0/2.)       !Bouchon's
	  shx=1./(shx-1./shx)
	  uu=-ai*t0*pi*shx
	  fsource= uu
	endif
c TYPE=7        Source = step en deplacement
	if (type.eq.7) then
	  uu=1./ai/omega
	  fsource= uu
	endif

c TYPE=3        Source = fichier 'axi.sou'
c               sismogramme dans l'unite choisie dans le fichier
	if (type.eq.3) then
	  read(130,*) uur,uui
	  fsource=cmplx(uur,uui)
	endif
 
c TYPE=4        Source = slip is triangle , so formal 'diplacement' is VELOC.
c                  its duration is t0; corresponds to mom=1
c     jeho spektrum je 4x slabsi nez ma byt
c      proto je na konci *4
	if (type.eq.4) then
	  uu=exp(ai*omega*t0/4.)
	  uu=(uu-1./uu)/2./ai
	  uu=uu/(omega*t0/2.)
	  fsource=uu*uu    *    4.
	endif
 
c TYPE=5        Source = rampe causale
c               rise time T=t0
	if (type.eq.5) then
 	  trise=t0
	  uu=ai*omega*trise
	  uu=(1.-exp(-uu))/uu
	  fsource=uu/(ai*omega)
	endif
	
	
c TYPE=9        Source = Brune
c               corner freq= 1 / t0
	if (type.eq.9) then
 	  trise=t0
          omegac=pi2*(1./trise)
          uu=omegac+ai*omega
	  fsource=omegac*omegac/(uu*uu)
	endif
	
c TYPE=6,8        Source = modele d'haskell, trapezoide
c       1 ere cste de temps rise time: riset
c       2 eme cste de temps, duree de la rupture
c         trupt = Length/2/rupt_velocity (Haskell)
	if ((type.eq.6).or.(type.eq.8)) then
	  trise=t0
	  trupt=t1
	  uu=ai*omega*trise
	  uu=(1.-exp(-uu))/uu           ! ramp
	  uxx=ai*omega*trupt/2.         ! finite fault
	  uex=exp(uxx)
	  uxx=(uex-1./uex)/uxx/2.
	  fsource=uu*uxx/(ai*omega)
	endif
    
	return
	end
	
