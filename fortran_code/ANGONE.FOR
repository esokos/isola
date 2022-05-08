      program ANGONE
      real(8) par,vmax,v,d,tdist,ttim
      real(8) v1,d1,v2,d2
c     Thimios added real(8) definitions here and subroutines, June 2015, gfortran NEEDS this 
c
c     J.Jansky program modified by J.Zahradnik for ASPO

c Program ANGONE computes travel times and take-off angles.
c Direct and head waves in 1D layered mefium., zde jen pro nejrychlejsi z P a vsech celnych.
c
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c upraven je jen vystup do MYPOL. Vystup do jjoutone dava vzdy jen primou vlnu!!!!!
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c
c   Version with 1 source only.
c
      character*80 text
      character*6  stcode
      character*1  pol
      dimension h(100),htop(100),v(100),d(100)
ccccc      dimension thead(100),ahead(100),dhead(100)
      open(40,file='crustal.dat')
      open(50,file='source.dat')
      open(60,file='station.dat')
cc      open(70,file='myprt.dat')
      open(80,file='mypol.dat')
      open(6 ,file='jjoutone.dat')  ! old Mira's output
c
c
c text - description of the computation
c n - no. of layers (lt.100)
c dwa - distance accuracy in iterations of direct wave (km)
c h(i)       - depth of the bottom boundary of the i-th layer (km)
c htop(i)    - depth of the top    boundary of the i-th layer (km)
c d(i)       - thickness of the i-th layer (km)
c v(i)       - P velocity in the layer (km/s), i=1, ... ,n
c xs, zs     - x and z coordinate of the source (km)  
c xr, zr     - x and z coordinate of the receiver (km) 
c
c fixed options
      vpvs=1.78   ! fix   Vp/Vs
      dwa=0.05    ! fix   iteration accuracy
      xs=0.       ! fix   source x-coord.
c
c reading CRUSTAL.DAT
c
      read(40,'(a80)')text
      read(40,'(a80)')text
      read(40,*) n
      read(40,*)
      read(40,*)
      do i=1,n           ! htop(i)...depth of i-th layer top
      read(40,*) htop(i), v(i)
      enddo
c nezapomen udelat prvni vrstvu tak mocnou, aby se do ni vesly i
c stanice s vetsi nadmorskou vyskou. Model koncipuj tak, ze o
c hodnotu nadmorske vysky nejvyse polozene stanice se zvetsi
c vsechny zadavane hloubky (vrstev i zdroje)
c
c v posledni "vrstvicce" se muze sirit ze spodu podel jejiho
c horniho rozhrani uz jen vlna celna.
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c predpoklad: zdroj je hloubeji, nez kterakoliv stanice
c ale nad horni hranici posledni vrstvy
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c

c
c bottom and thickness
c
      do i=1,n-1
      h(i)=htop(i+1)     ! h(i)...depth of i-th layer bottom
      enddo
      h(n)=100.          ! fix
      d(1)=h(1)          ! d(i)...i-th layer thickness
      do 1 i=2,n
    1 d(i)=h(i)-h(i-1)
c
c
c reading SOURCE.DAT
c
      read(50,*)
      read(50,*)
      read(50,*) dum,dum,zs

      write(80,*) 'source depth= ',zs





c hledej is, t.j. cislo vrstvy, ve ktere je zdroj
      do 101 ia=1,n
      if(zs.lt.h(ia))go to 102
  101 continue
c
  102 is=ia
c
      write(6,'(a)')text
      write(6,58)
   58 format('distance accuracy in iterat. of direct wave (km)')
      write(6,*)dwa
      write(6,54)
   54 format('layer, bound. depth(km), thickn.(km), veloc.(km/s)')
      do 7 i=1,n
    7 write(6,*)i,h(i),d(i),v(i)
      write(6,55)
   55 format(/'source:  index,  x (km),   z (km)')
      write(6,*)is,xs,zs 

cccccccc         choose ONE of the following TWO alternative readings  ccccc
c
c reading STATION.DAT   (in the loop over stations)
c
      read(60,*)                                    ! caution for station.dat
      read(60,*)                                    ! caution
      istat=0
c
c                                       
  200 continue      ! loop over stations 
        !               |
                  ttime=0
      write(6,205)                                  !               |
  205 format(//)                                    !
ccc   read(60,'(36x,f9.0,f11.0,a6)',end=9999)  azi,xr,stcode ! caution (see above !!!)
      read(60,*,end=9999) x1,x2,x3,azi,xr,stcode,pol ! caution (see above !!!)! thimios Jan 2014
      iazi=ifix(azi)

c        OR  ....
c
c reading  MYPRT.DAT
c
c      istat=0                                       !               |
c      read(70,'(a80)')text
c  200 continue      ! loop over stations            !               |
c      write(6,205)                                  !               |
c  205 format(//)                                    !
c      read(70,'(a6,f5.0,2i4,3x,a1)',end=9999) stcode,xr,iazi,idum,pol    ! reading allprt.dat

c cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      zr=0.           !! fixed receiver depth=0
      istat=istat + 1   ! seq. # of the station

      epidis=xr      ! epic. distance
      jlast=0        ! counting head waves

c hledej ir, tj. cislo vrstvy, ve ktere je prijimac
c
      do 201 ia=1,n
      if(zr.lt.h(ia))go to 202
  201 continue
c
  202 ir=ia
c
      write(6,56)
   56 format('receiver:  index,  x (km),    z (km)')
      write(6,*)ir,xr,zr
c
      if(is.eq.1.and.zs.ge.h(1).or.ir.eq.1.and.zr.ge.h(1))go to 9
      if(is.gt.n.or.ir.gt.n)go to 9
      if(n.eq.1)go to 70
      if(is.eq.n.and.zs.le.h(n-1).or.is.eq.n.and.zs.gt.h(n))go to 9
      if(ir.eq.n.and.zr.le.h(n-1).or.ir.eq.n.and.zr.gt.h(n))go to 9
   70 continue
      if(n.eq.2)go to 19
      do 8 j=2,n-1
      if(is.eq.j.and.zs.le.h(j-1).or.is.eq.j.and.zs.ge.h(j))go to 9
    8 if(ir.eq.j.and.zr.le.h(j-1).or.ir.eq.j.and.zr.ge.h(j))go to 9
      go to 19
    9 write(6,62)
   62 format('!!! "is" or/and "ir" value is wrong !!!')
      go to 38
c 
   19 continue


c
c direct wave
c
      dist=abs(xr-xs)
      if(is.eq.ir)go to 2
      if(is.gt.ir)go to 3
      i1=is
      i2=ir
      d1=h(is)-zs
      d2=zr-h(ir-1)
      v1=v(is)
      v2=v(ir)
      go to 4
    3 i1=ir
      i2=is
      d1=h(ir)-zr
      d2=zs-h(is-1)
      v1=v(ir)
      v2=v(is)
c
    4 k=0
      kk=0
      ntype=0
c ntype estimates if sinus or cosinus will be used as par
      dpar=.2
      par=-dpar
c par - for angle (between ray and vertical line) up to 0.8 (rad)
c       par=sin(anglemax), for angle over 0.8 (rad) par=cos(anglemax)
c       where anglemax is the angle in the "fastest" layer between
c       the source and the receiver
c dpar - step in parameter "par" in iteration for direct wave
c
      vmax=0
      do 29 i=i1,i2
   29 if(v(i).gt.vmax)vmax=v(i)
c
   10 if(ntype.eq.0)par=par+dpar
      if(ntype.eq.1)par=par-dpar
      tdist=0
      ttim=0
      if(ntype.gt.0)go to 15
      if(par.gt..8)go to 13
c
      if(i2.eq.i1+1)go to 21
      do 20 j=i1+1,i2-1
      call help1(par,vmax,v(j),d(j),tdist,ttim)
   20 continue
   21 call help1(par,vmax,v1,d1,tdist,ttim)
      call help1(par,vmax,v2,d2,tdist,ttim)
      go to 16
c
   13 ntype=1
      par=par-dpar
      par=sqrt(1.-par**2)
      go to 10
c
   15 if(par.gt..000001) go to 17
      kk=kk+1
      if(kk.gt.20)go to 18
      par=par+dpar
      dpar=dpar/2
      go to 10
c
   18 write(6,60)
   60 format('No of KK iter. for dir. wave gt 20')
      go to 11
c
   17 if(i2.eq.i1+1)go to 26
      do 25 j=i1+1,i2-1
   25 call help2(par,vmax,v(j),d(j),tdist,ttim)
   26 call help2(par,vmax,v1,d1,tdist,ttim)
      call help2(par,vmax,v2,d2,tdist,ttim)
c
   16 if(abs(tdist-dist).lt.dwa)go to 12
      if(tdist.lt.dist)go to 10
      if(ntype.eq.0)par=par-dpar
      if(ntype.eq.1)par=par+dpar
c halving of dpar
      dpar=dpar/2
      k=k+1
      if(k.lt.20)go to 10
      write(6,50)
   50 format('No of K iter. for dir. wave gt 20')
      go to 11
c
   12 write(6,51)
   51 format('dir.wave: P tr.time (s) S        angle(deg)        no.iter
     /      ntype')
c ntype=0 par=sin uhlu (vzhledem k vertikale) v nejrychl. vrstve
c ntype=1 par=cos uhlu (vzhledem k vertikale) v nejrychl. vrstve
c musime proto z toho dostat sin uhlu a pak i uhel ve vrstve se
c zdrojem (vzhledem k vertikale)
      if(ntype.eq.1)go to 203
      sinuhs=par/vmax*v(is)
      go to 204
  203 corpar=sqrt(abs(1.-par**2))
      sinuhs=corpar/vmax*v(is)
  204 cosuhs=sqrt(abs(1.-sinuhs**2))
      tanuhs=sinuhs/cosuhs
      angle=180.-atan(tanuhs)*57.2958
      ts=ttim*vpvs
      write(6,*)ttim,ts,angle,k,ntype
ccccc
      tdirp=ttim                  ! NEW (travel time of direct P wave)
      adirp=angle                 ! NEW (take-off angle ...)
      iadirp=ifix(adirp)			! New jz Aug 2015
	if(iadirp.eq.90) iadirp=91 	! New
c
c      write(80,801)
c     * stcode,iazi,ifix(adirp),pol,epidis,tdirp ! direct P
  801 format(a6,2i8,2x,a1,2x,5x,3f10.2)
c
      go to 11
c
c no iterations, source and receiver in the same layer 
    2 ttim=sqrt((xr-xs)**2+(zr-zs)**2)/v(is)
      tanuhs=abs(xr-xs)/abs(zr-zs)
      angle=180.-atan(tanuhs)*57.2958
      write(6,61)
   61 format('dir.wave tr.time (s), angle')
      ts=ttim*vpvs
      write(6,*)ttim,ts,angle
ccccc
      tdirp=ttim                  ! NEW (direct P wave)
      adirp=angle                 ! NEW
      iadirp=ifix(adirp)			! New jz Aug 2015
	if(iadirp.eq.90) iadirp=91 	! New
c
c      write(80,*)tdirp,tdirp
c      stop
c
c     go to 3030
c tam rozhodnuti o tisku
c
c
c      write(80,801)
c     * stcode,iazi,ifix(adirp),pol,epidis,tdirp ! direct P
c
c
   11 continue
c      write(80,*)tdirp
c      go to 200
c      stop
c
c
c head waves     
c
c
c for head waves: par=head wave ray parameter
c 
      write(6,52)
      write(6,53)
   52 format('head waves:')
   53 format('P-arr.time (s)  S-arr.time (s)  angle(deg)      depth(km) 
     /crit.dist.(km)')
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccc Jirko, "vyparal jsem z toho head waves for the rays, radiated 
cccccc from the source up, protoze ty mely smysl jen pro prupady, kdy
cccccc prijimac(e) lezely ve vetsi hloubce nez zdroje a mne to ted pletlo.
cccccc Pokud bys na tom trval, tak to tam zas dodam zpet a upravim.
c
c
c head waves for rays radiated from the source down
c
c
   39 k=is
      if(ir.gt.is)k=ir
      if(k.gt.n-1)go to 38
c loop over boundaries that guide head waves
c
c
      thead1=1000.
c to je pro pripad, ze neexistuje ani jedna celna vlna
c
      ii=0
c
      do 30 j=k,n-1
c
c
      if(v(j+1).lt.v(is).or.v(j+1).lt.v(ir))go to 30
c find critical distance
          tdist=0
          ttim=0
          par=1./v(j+1)
c down going branch
          if(j.eq.is)go to 34
          do 31 jj=is+1,j
          if(v(jj).ge.v(j+1))go to 30
   31     call help3(par,v(jj),d(jj),tdist,ttim)
   34     d1=h(is)-zs
          call help3(par,v(is),d1,tdist,ttim)
c up going branch
          if(j.eq.ir)go to 33
          do 32 jj=ir+1,j
          if(v(jj).ge.v(j+1))go to 30
   32     call help3(par,v(jj),d(jj),tdist,ttim)
   33     d1=h(ir)-zr
          call help3(par,v(ir),d1,tdist,ttim)
      if(tdist.gt.dist)go to 30
c
c
c nize jsou parametry pro danou celnou vlnu k dalsi praci
c zacatek
c
      ddif=dist-tdist
      tdif=ddif/v(j+1)
            tsum=ttim+tdif    
c celkovy cas pro danou celnou vlnu
c
      sinuhs=par*v(is)
      cosuhs=sqrt(abs(1.-sinuhs**2))
      tanuhs=sinuhs/cosuhs
            angle=atan(tanuhs)*57.2958
            ts=tsum*vpvs
c
c vyse jsou parametry pro danou celnou vlnu k dalsi praci
c
cc uprava
      if(ii.eq.1)go to 2211
c
c hodnoty pro prvni celnou
c
c (pokud do dane epic vzdal nedosahuje ani jedna celna (jsme moc blizko epicentru),
c zustava thead1 stale =1000 a je mozno to pouzit jako kriterium k tisku, cili 
c bude se tisknout prima vlna
c
c davame do parametruu hodnotu prvni celne vlny 
      thead1=tsum
c          write(80,*)thead1
      ahead1=angle
      dhead1=h(j) 
ccccc
c protoze i pro dalsi celne vlny budeme pocitat tsum atd, musime dosavadni
c hodnoty nekam schovat, viz instrukce nad.
c
c toto jsou parametry pro prvni celnou vlnu (event. to muze byt i celna
c jedina)
      ii=ii+1
      if(ii.eq.1)go to 30
c jdeme na dalsi celne vlny, ale nesmime prepsat, pokud nechceme, tu prvni
c proto je vyse if(ii.eq.1)go to 2211
c
cc uprava
 2211 continue
c
c pro dalsi celne vlny zase ziskame tsum, atd.
c nyni potrebujeme porovnat velikost casu, dosavadni hodnota je thead 
c 
      if(tsum.gt.thead1+.00001)go to 30  
c je-li cas dane celne vlny  vetsi, nez dosavadni minim cas, jdi na dalsi celnou
c jinak poloz parametry = parametrum nove celne vlny
c
      thead1=tsum
      ahead1=angle
      dhead1=h(j) 
ccccc
c
   30 continue
c
c konec smycky celnych pres rozhrani
c
c sem musi prijit nadpis, ktery je tyz pro primou i celne,
c a rozhodnuti, ktera vlna se bude tisknout
c
c
c
c      if(tdirp.le.thead1)write(80,801)
c     * stcode,iazi,ifix(adirp),pol,epidis,tdirp
      if(tdirp.le.thead1)write(80,801)
     * stcode,iazi,iadirp,pol,epidis,tdirp      ! new jz Aug 2015

c
 
      if(tdirp.gt.thead1)write(80,801)
     * stcode,iazi,ifix(ahead1),pol,epidis,thead1,dhead1
c
   38 continue
c
      goto 200    ! end of loop over stations

 9999 stop
      end
c
c
      subroutine help1(p,vmax,v,d,td,tt)
      real(8) p,vmax,v,d,td,tt,sina,cosa,tana
      sina=p*v/vmax
      cosa=sqrt(1.-sina**2)
      tana=sina/cosa
      td=td+d*tana
      tt=tt+d/v/cosa
      return
      end
c
      subroutine help2(p,vmax,v,d,td,tt)
      real(8) p,vmax,v,d,td,tt,sina,cosa,tana
      sina=sqrt(1.-p**2)*v/vmax
      cosa=sqrt(1.-sina**2)
      tana=sina/cosa
      td=td+d*tana
      tt=tt+d/v/cosa
      return
      end
c
      subroutine help3(p,v,d,td,tt)
      real(8) p,v,d,td,tt,sina,cosa,tana
      sina=p*v
      cosa=sqrt(1.-sina**2)
      tana=sina/cosa
      td=td+d*tana
      tt=tt+d/v/cosa
      return
      end
