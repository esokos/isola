c      program ANGGRADM
c VERSION: August, 2020
c
c This version contains a correction to avoid ommission of some stations (in the output file MYPOL.DAT),
c which occured in the previous version. See the part denoted "ITERATIONS", after line 705
cccccccccccccccccccccccccccccccccccccccc 
c
      real(8) p,vmax,v,vr,v1,vsp
      real(8) w,d,d1,d2,dis,tdist,ttim,ttims,vpvs
c     Thimios added real(8) definitions here and subroutines, June 2015, gfortran NEEDS this 
c     and changed alog to dlog
       
c (author J. Jansky - version 2015)


c Program ANGGRAD computes travel times and take-off angles in 1D layered medium formed by homogeneous
c layers and/or layers with constant velocity gradient. All existing waves are on output. 


ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c Gradients must decrease with the layer's depth.
c Negative gradients are NOT allowed !!!!!!
c Souce MUST NOT be situated in a layer with constant velocity 

c  input data: crustal_grad.dat
c  for each layer we prescribe:
c  depth (km) of the layer top
c  Vp (km/s) at the layer top
c  Vp (km/s) at the layer bottom
c  depth of the layer bottom, that equals to the depth of next layer top
c
c output data: mypol.dat
c 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c 
c Generally three types of waves may arrive to the receiver: (i) The waves radiated upwards from the source,
c (ii) the waves radiated downwards and propagating as head waves along some velocity discontinuity [below
c which the velocity is constant], and (iii) the waves radiated downwards and turning upwards, i.e. refracted
c [in some layer with a constant (positive) velocity gradient]. For head waves, the depth of the boundary 
c along which the wave propagates, is given in output. For refracted waves, the layer number in which 
c the refracted wave has its turning point, is given in output. Which waves will arrive to the given a receiver
c depends on the velocity model, position of the source and epicentral distance of the receiver. 
c
c
c
c In the case of the crustal model, whose last discontinuity is MOHO, the code supports two cases:
c
c a) Vp is constant below Moho (Pn head wave exists)
c The layer below Moho must be specified as a constant-velocity layer,
c i.e., the line for the Moho depth looks like, e.g.: 
c 43.0  8.2  8.2
c where 43 is the Moho depth, and 8.2 is the (constant) Vp below Moho.
c One fictious layer must be added, e.g.
c 60.0  8.2  8.2   ... (the fictious layer)
c Note that all four velocity values in the two last model layers must be identical, equal to  the velocity under Moho.
c The top of the fictious layer (e.g. 60.) must be smaller than 100.  
c
c b) Vp increases below Moho, e.g.
c 43.0 8.2 8.3 
c i.e. the velocity under Moho is 8.2 and increases to  8.3 at the bottom of the layer.
c One fictious layer must be added, e.g.
c 60.0 8.3 8.3 ... (the fictious layer)
c Note that the velocity in the fictious layer and the velocity at the depth of preceding layer must be identical
c (e.g., see the three values 8.3).
c The top of the fictious layer (e.g. 60.) must be again smaller than 100. 
c
c If needed, the velocity model may be prolonged to the upper-most part of the mantle, under the same conditions as mentioned
c for the crust. 
c
c In any case the source must lie in the model (not below it) and must not lie on any of the layer boundary.
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc






c
c text - description of the computation
c n - no. of layers (lt.100)
c dwa - distance accuracy in iterations of direct wave (km)
c h(i)       - depth of the bottom boundary of the i-th layer (km)
c htop(i)    - depth of the top    boundary of the i-th layer (km)
c d(i)       - thickness of the i-th layer (km)
c v(i)       - P vel. at the top of the layer (km/s), i=1, ... ,n
c w(i)       - P vel. at the bottom of the layer
c xs, zs     - x and z coordinate of the source (km)  
c xr, zr     - x and z coordinate of the receiver (km) 
c

      character*80 text
      character*6  stcode
      character*1  pol
      dimension h(100),htop(100),v(100),d(100),w(100),pardd(100)
      common/b/vpvs,jaj
c
      open(40,file='crustal_grad.dat')	! new 2014
ccc      open(40,file='model.dat')
      open(50,file='source.dat')
      open(60,file='station.dat')
ccc      open(70,file='myprt.dat')
      open(80,file='mypol.dat')
      open(6 ,file='jjout.dat')  ! old Mira's output
c
c fixed options !!!!!!!!!!!!!
      vpvs=1.78   ! fix   Vp/Vs
c      dwa=0.05    ! fix   iteration accuracy
      dwa=0.20    ! fix   iteration accuracyc
      xs=0.       ! fix   source x-coord.
c
c reading MODEL.DAT
c
      read(40,'(a80)')text
      read(40,'(a80)')text
      read(40,*) n
      read(40,*)
      read(40,*)
c
      nl=n
c
      do i=1,n           ! htop(i)...depth of i-th layer top
      read(40,*) htop(i), v(i), w(i)
      enddo
c 
c
c The velocity in the last (deepest) layer must have zero gradient
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c The source must lies deeper than any of the stations and above
c the last layer. 
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
ccccccccccccccccccccccccccccccccccccccccccccccccc
      write(80,*) 'source depth= ',zs
c
c find is - No of thr layer with the source
      do 101 ia=1,n
      if(w(ia).ge.v(ia))go to 1103
      write(80,*) 'layer with a negative gradient - not allowed'
      stop
c
 1103 continue
      if(zs.lt.h(ia))go to 102
  101 continue
c
  102 is=ia
c
c is the layer homogeneous?
      if(abs(w(is)-v(is)).gt.0.005)go to 432
      write(80,*) 'source in layer with constant velocity - not allowed'
      stop
c
c
  432 continue
c find the velocity at the depth of the source
c c c c c c c c 
c case for is=1 
      if(is.eq.1)go to 543
      vsp=v(is)+(zs-h(is-1))/(h(is)-h(is-1))*(w(is)-v(is))      
      go to 542
  543 vsp=v(is)+zs/h(is)*(w(is)-v(is))      
  542 continue
      vs=vsp
cc vs = vsp velocity at the depth of the source
c c c c c c c 
c
c
      write(6,'(a)')text
      write(6,58)
   58 format('distance accuracy in iterat. of direct wave (km)')
      write(6,*)dwa
      write(6,54)
   54 format('layer, lower depth(km), thickn.(km), veloc. v  w (km/s)')
      do 7 i=1,n
    7 write(6,*)i,h(i),d(i),v(i),w(i)
      write(6,55)
   55 format(/'source:  index  x(km)  z(km) vs(km/s)')
      write(6,*)is,xs,zs,vs  

cccccccc         choose ONE of the following TWO alternative readings  ccccc
c
c reading STATION.DAT   (in the loop over stations)
c
      read(60,*)                                    ! caution for station.dat
      read(60,*)                                    ! caution
      istat=0                                       !               |
 2000 continue      ! loop over stations            !               |
      write(6,2005)                                  !               |
 2005 format(//)                                    !
c      read(60,'(36x,f9.0,f11.0,a6)',end=9999)  azi,xr,stcode ! caution (see above !!!)
      read(60,*,end=9999) dum,dum,dum, azi,xr,stcode,pol ! caution (see above !!!)

      iazi=ifix(azi)

c        OR  ....
c
c reading  MYPRT.DAT
c
c      istat=0                                       !               |
c      read(70,'(a80)')text
c 2000 continue      ! loop over stations            !               |
c      write(6,2005)                                  !               |
c 2005 format(//)                                    !
ccccc      read(70,'(a6,f5.0,2i4,3x,a1)',end=9999) stcode,xr,iazi,idum,pol    ! reading allprt.dat
c      read(70,'(a6,f5.0,2i4,3x,a1)') stcode,xr,iazi,idum,pol
c      if(xr.eq.0..and.iazi.eq.0)go to 9999 
c cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      zr=0.           !! fixed receiver depth=0
      istat=istat + 1   ! seq. # of the station

      epidis=xr      ! epic. distance
      jlast=0        ! counting head waves

c find ir = layer with the receiver
c
c      do 201 ia=1,n
c      if(zr.lt.h(ia))go to 202
c  201 continue
c
c  202 ir=ia
c
c
      ir=1
      vr=v(1)
c vr = velocity at the deth of the source
c
      write(6,56)
   56 format('receiver:  index,  x (km),    z (km)')
      write(6,*)ir,xr,zr
c
c  
ccccccccccccccccccccccccc
c DIRECT WAVE
ccccccccccccccccccccccccc
c
      ismer=2
c
c RAYS UPWARDS
c
      dist=abs(xr-xs)
      i1=ir
      i2=is
      d1=h(ir)-zr
c d1 
c c
      if(is.gt.1)d2=zs-h(is-1)
      if(is.eq.1)d2=zs-zr
c c d2 
c
      vmax=vsp
c 
      if(is.gt.1)go to 219
c
      if(w(1)-v(1).gt..0005)go to 219
c  
      ttim=sqrt(dist**2+(zs-zr)**2)/v(1)
ccc      ttims=ttim*vpvs(1)
      ttims=ttim*vpvs
      go to 74
c
c
  219 iway=0
      if(w(is)-v(is).gt..0005)iway=1
c 
      if(iway.eq.1)go to 49
      go to 48
c
   49 continue
c
c iterations for rays propagating from the source upwards
cccc iway=1, ismer=2
      jpart=3
      parma=1.00000
      p=parma
      tdist=0
      ttim=0
      ttims=0
      go to 50
c !!!!!!!!!!!!
c
   75 continue
c c c  
c          write(6,*)tdist,dist
      if(tdist.lt.dist)go to 323
c              stop
c there: waves radiated downwards
c 
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ismer=1
c
      distu=tdist
      timeu=ttim
      timeus=ttims
c
      jpart=6
c  ??
c
      parma1=.99999
      p=parma1   
      tdist=0
      ttim=0
      ttims=0
      go to 50
c   
   52 continue
      if(dist.lt.tdist)go to 48
c
      distu1=tdist
      timeu1=ttim
      timeu1s=ttims
      ttim=timeu1+(timeu-timeu1)/(distu-distu1)*(dist-distu1)
      ttims=timeu1s+(timeus-timeu1s)/(distu-distu1)*(dist-distu1)
      par=parma1
      go to 12
c
   48 jpart=0  
      k=0
      kk=0
      ntype=0
c
c  a choice:
c      dpar=.04
c      par=-0.02
c
      dpar=.2
      par=-.2


c
c !!!!!!!!!!!!!!!!!!!!!!!!
c par - sin of ray radiation angle from the source
c !!!!!!!!!!!!!!!!!!!!!!!!
c
c
  10  if(dpar.ge..0000002)go to 321
	write(*,*) 'Problem !!!!'
c
  777 format(6f9.4,e12.4)
c
      go to 323
c c c c c
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c
c
c
c
 321  continue
c
      if(ntype.eq.0)par=par+dpar
      if(ntype.eq.1)par=par-dpar
      tdist=0
      ttim=0
      ttims=0
      p=par
      if(ntype.gt.0)go to 15
      if(par.gt..8.and.iway.eq.0)go to 13
c
      if(iway.eq.1.and.par.gt.parma1)go to 76
c
c
c i2 layer containing the source, i1 layer containing the receiver, jpart=3 
c c c c
   50 continue 
      if(i2.eq.i1)go to 22
c
      if(i2.eq.i1+1)go to 21
c
      do 20 j=i1+1,i2-1
      jaj=j
      call help3(p,vmax,v(j),w(j),v(1),d(j),tdist,ttim,ttims)
   20 continue
c
c
   21 jaj=1
c 
      call help3(p,vmax,vr,w(1),v(1),d1,tdist,ttim,ttims)
c
   22 if(is.eq.1)v1=vr
      if(is.gt.1)v1=v(is)
c
      if(jpart.ne.3)go to 51
c  jpart=3
      vzd11=tdist
      cas11=ttim
      cas11s=ttims
      if(is.eq.1)dis=h(1)-zr
      if(is.gt.1)dis=d(is)
c
c ray minimum
c
      jaj=is
      call help4(p,vmax,v1,w(is),v(1),dis,tdist,ttim,ttims)
      vzd12=(tdist-vzd11)/2.
      cas12=(ttim-cas11)/2.
      cas12s=(ttims-cas11s)/2.
      tdist=vzd11+vzd12
      ttim=cas11+cas12
      ttims=cas11s+cas12s
      go to 75
c c c c c c c c c c c c c c c c c c c c c c c 
   51 continue
      jaj=is
      call help3(p,vmax,v1,vsp,v(1),d2,tdist,ttim,ttims)
c
      if(jpart.eq.6)go to 52
      go to 16
c
c
   13 ntype=1
      par=par-dpar
c
c
      par=sqrt(1.-par**2)
c change iteration parameter from sin to cos (of ray angle at the source)
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c
      go to 10
c
   15 if(par.gt..000001)go to 17
      kk=kk+1
cc      if(kk.gt.30)write(80,*)k
      if(kk.gt.30)go to 323
      par=par+dpar
      dpar=dpar/2.
      go to 10
c
   17 continue
cc      p=sqrt(1.-par**2)
      p=par
c
      if(i1.eq.i2)go to 92
c 
      if(i2.eq.i1+1)go to 91
      do 90 j=i1+1,i2-1
      jaj=j
      call help2(p,vmax,v(j),w(j),v(1),d(j),tdist,ttim,ttims)
   90 continue
   91 jaj=1
      call help2(p,vmax,vr,w(1),v(1),d1,tdist,ttim,ttims)
c
   92 jaj=is
      call help2(p,vmax,v1,vsp,v(1),d2,tdist,ttim,ttims)
c 
      go to 16
c
   76 kk=kk+1
cc      if(kk.gt.30)write(80,*)k,k
      if(kk.gt.30)go to 323
c
c
c
      par=par-dpar
      dpar=dpar/2.
c c c c c
cc      write(6,*)kk,par,dpar
c c c c c
cc      write(80,*)kk,par,dpar
      go to 10
c      
   16 continue
      difvzd=abs(tdist-dist)
      if(difvzd.lt.dwa)go to 12
      if(tdist.lt.dist)go to 10
      if(ntype.eq.0)par=par-dpar
      if(ntype.eq.1)par=par+dpar
c 
      dpar=dpar/2.
      k=k+1
      if(k.lt.30)go to 10
      go to 323
c 
c
   12 continue
      if(par.gt..99999)go to 74
c
   74 continue 
      sinuhs=par
      cosuhs=sqrt(abs(1.-sinuhs**2))
      if(cosuhs.lt..00001)go to 302
      tanuhs=sinuhs/cosuhs
      angle=180.-atan(tanuhs)*57.2958
      go to 303
  302 angle=90.
  303 write(6,*)ttim,ttims,angle,k,ntype
ccccc
      tdirp=ttim                  ! NEW (travel time of direct P wave)
      adirp=angle                 ! NEW (take-off angle ...)
     	iadirp=ifix(adirp)			! New jz Aug 2015
 	if(iadirp.eq.90) iadirp=91 	! New

      write(80,801)
     * stcode,iazi,iadirp,pol,epidis,tdirp ! direct P upwards
c 
c      go to 2000
      go to 239
c
cc      go to 38
ccccccccccccccccccccccccccccccccccccccccccccccc
  323 continue
cc          write(6,*)tdist,dist
cc          stop
c
ccccccccccccccccccccccccccccccccccccc
c RAYS DOWNWARDS
c
c REFRACTED WAVE
c
c  "jobrat" gives the number of layer, in which the ray has its minimum
c
      nnll=nl-2
c
c
c cycle over layers for given receiver
cxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      do 44 jl=is,nnll
c 
      aha=w(jl)-v(jl)
      if(aha.lt..005)pomoc=20000
      if(aha.lt..005)write(6,*)pomoc,pomoc
      if(aha.lt..005)go to 239
c there the end of the comput. for given epic. dist. 
c  
      pard=vsp/w(jl)
c  
      pardd(jl)=vsp/w(jl)
c  
      jpart=1
      par=pard
      go to 41
c
   42 distd=tdist
      timed=ttim
      timeds=ttims
      pard1=pard+.00001
      jpart=4
      par=pard1
      go to 41
c
  142 distd1=tdist
c 
c 
      timed1=ttim 
      timed1s=ttims 
      if(jl.eq.is)parn=1.00000
      if(jl.gt.is)parn=vsp/v(jl)-.00001
      jpart=2
      par=parn
      go to 41
c
   43 continue
      distn=tdist
      timen=ttim
      timens=ttims
      parn1=parn-.00001
      jpart=5
      par=parn1
      go to 41
c
  143 distn1=tdist
      timen1=ttim
      timen1s=ttims
c 
c 
      if(distd.lt.dist.or.distn.gt.dist)go to 44
c
      if(dist.lt.distd1)go to 144
      ttim=timed1+(timed-timed1)/(distd-distd1)*(dist-distd1)
      ttims=timed1s+(timeds-timed1s)/(distd-distd1)*(dist-distd1)
      par=pard
      go to 150
c
  144 if(dist.gt.distn1)go to 141
      ttim=timen+(timen1-timen)/(distd1-distn)*(dist-distn)
      ttims=timens+(timen1s-timens)/(distd1-distn)*(dist-distn)
      par=parn
      go to 150 
c
  141 jpart=0
      dpar=.02
      par=pard-dpar
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c  par = sin of the angel
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c
c
  203 par=par+dpar 
      k=0
      kk=0
c
  207 continue
      if(par.lt.parn1)go to 41
c
      kk=kk+1
      par=par-dpar
      dpar=dpar/2.
      go to 203
c
   41 continue
      tdist=0
      ttim=0
      ttims=0
      vlim=par/vsp
      p=par
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c vlim = parameter of the ray = sin(angle)/v
c !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c
c descending part of the ray (without the part of ray minimum)
c
      do 200 i=is,jl
      if(vlim.gt.1./w(i)-.000001)go to 231
c
      if(i.gt.is)go to 202
      d2=h(is)-zs
      jaj=is
      call help3(p,vmax,vsp,w(is),v(1),d2,tdist,ttim,ttims)
c 
      go to 200
  202 jaj=i
      call help3(p,vmax,v(i),w(i),v(1),d(i),tdist,ttim,ttims)
c 
  200 continue
c
  231 continue
      if(i.gt.is)go to 204
c ray minimum
c 
      if(p.lt..999998)go to 46
c 
c  the ray has no minimum (rad. upwards)

      jaj=is
      call help4(p,vmax,v1,w(is),v(1),dis,tdist,ttim,ttims)
c 
      tdist=tdist/2.
      ttim=ttim/2.
      ttims=ttims/2.
      go to 205
c
   46 continue
c 
      d2=h(is)-zs
      jaj=is
            jobrat=is
c
      call help4(p,vmax,vsp,w(is),v(1),d2,tdist,ttim,ttims)
c
c        write(6,*)tdist
c 
c  z(is)-minim-z(is)
c      write(6,*)tdist,w(i),i
c 
      if(is.gt.1)d2=zs-h(is-1)
      if(is.eq.1)d2=zs-zr
c
      jaj=is
      call help3(p,vmax,v1,vsp,v(1),d2,tdist,ttim,ttims)
c 
      go to 205
c there the other contrib. to the ray upwards
c
  204 continue
c 
      jaj=i
            jobrat=jaj
c
      call help4(p,vmax,v(i),w(i),v(1),d(i),tdist,ttim,ttims)
c 
  205 continue
      if(is.eq.1.and.i.eq.1)go to 216   
c
c
      i2=i-1
      if(i2.eq.1)go to 213
c
c 
      do 206 i=2,i2
      jaj=i
      call help3(p,vmax,v(i),w(i),v(1),d(i),tdist,ttim,ttims)
c        write(6,*)p,tdist,tim
c 
c 
  206 continue
c
  213 continue
c contr. from the first layer
      d1=h(ir)-zr
      jaj=1
      call help3(p,vmax,vr,w(1),v(1),d1,tdist,ttim,ttims)
c
ccccccccccccccccccccccccccccccc 
c   ITERATIONS
c 
c The iterations are not successfull in the case that the final ray obtained in
c the course of the iterations for given station (epicentral distance) has its 
c bottom very near to the depth of some of the velocity-model boundary (10 meters ?
c or so, it depends on the layer velocity gradient). In such a case the sinus of ray 
c angle at the source differs from the sinus of the corresponding boundary ray 
c (the ray that bottoms exactly at the boundary) starting from the 8-th decimal place. 
c The iteration then fails and the station is omitted in the "mypol.dat" output.
c To overcome this failure we take for such a case the approximation by the boundary
c ray. We use this approximation if the difference between the epicentral
c distance of the station "dist" and the distance obtained from the iterations "tdist"
c is les than 200 m, see the next "if". If necessary, increase this value.
c  
      sidol=vsp/w(jobrat)
      sihor=vsp/v(jobrat)
c
      if(abs(sihor-p).lt..00000002.and.abs(tdist-dist).lt..2)go to 333
      if(abs(sidol-p).lt..00000002.and.abs(tdist-dist).lt..2)go to 333
c
c there is applied the correction
c
c
      go to 216
c there continues the standard iteration code
c
c
  333 continue
c find the angle in degrees
      sinuhs=par
      sinuhs=p
      cosuhs=sqrt(abs(1.-sinuhs**2))
      if(cosuhs.lt..00001)go to 300
      tanuhs=sinuhs/cosuhs
c
      angle=atan(tanuhs)*57.2958
c
cc      write(6,*)ttim,ttims,angle
c
      tdirpd=ttim                  ! NEW (travel time of direct P wave)
      adirpd=angle                 ! NEW (take-off angle ...)
     	iadirpd=ifix(adirpd)			! New jz Aug 2015
 	if(iadirpd.eq.90) iadirpd=91 	! New

      write(80,803)
     * stcode,iazi,iadirpd,pol,epidis,tdirpd,jobrat ! direct P downwards
      go to 239
c c c 
c
  216 if(jpart.eq.1)go to 42
      if(jpart.eq.4)go to 142
      if(jpart.eq.2)go to 43
      if(jpart.eq.5)go to 143
      if(abs(tdist-dist).lt.dwa)go to 232
      if(tdist.gt.dist)go to 203
c 
      par=par-dpar
c
c halving of dpar
      dpar=dpar/2.
      k=k+1
cc      if(kk.gt.30)write(80,*)k,k,k
      if(k.gt.30)go to 44
      par=par+dpar
      go to 207
c
  232 continue
c
  150 continue
      sinuhs=par
      cosuhs=sqrt(abs(1.-sinuhs**2))
      if(cosuhs.lt..00001)go to 300
      tanuhs=sinuhs/cosuhs
c
      angle=atan(tanuhs)*57.2958
      go to 301
  300 angle=90.
  301 write(6,*)ttim,ttims,angle,k,ntype
ccccc
      tdirpd=ttim                  ! NEW (travel time of direct P wave)
      adirpd=angle                 ! NEW (take-off angle ...)
     	iadirpd=ifix(adirpd)			! New jz Aug 2015
 	if(iadirpd.eq.90) iadirpd=91 	! New

      write(80,803)
     * stcode,iazi,iadirpd,pol,epidis,tdirpd,jobrat ! direct P downwards
  801 format(a6,2i8,2x,a1,7x,3f10.2)
  803 format(a6,2i8,2x,a1,7x,2f10.2,i4)
c
cccccccccccccccccccccccccccccccccccccccccc
c 
c
   44 continue
c
c
  239 continue 
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccc
c HEAD WAVES (downwards only)   
c
c for head waves: par=head wave ray parameter
c
      write(6,520)
      write(6,53)
  520 format('head waves:')
   53 format('P-arr.time (s)  S-arr.time (s)  angle(deg)      depth(km) 
     /crit.dist.(km)')
c
c
   39 k=is
c
      if(k.gt.n-1)go to 38
c
c loop over boundaries that guide head waves
c
      do 30 j=k,n-1
      if(abs(v(j+1)-w(j)).lt..0005)go to 30
c
      if(v(j+1).lt.w(j))go to 30
c 
      if(v(j+1).le.vsp.or.v(j+1).lt.v(1))go to 30
c 
      if(abs(w(j+1)-v(j+1)).gt..0005)go to 30
c
c find critical distance
          tdist=0
          ttim=0
          ttims=0
          par=1./v(j+1)
c
       p=par*vsp
c  p=sin of the ray angle at the source
c
c
c down going branch
          if(j.eq.is)go to 34  
c
cc             write(6,*)p,vmax,v(jj)
cc             write(6,*)w(jj),v(1),d(jj)
cc             write(6,*)tdist,ttim,ttims
cc             stop
c
          do 31 jj=is+1,j
          jaj=jj
   31     call help3(p,vmax,v(jj),w(jj),v(1),d(jj),tdist,ttim,ttims)
c
   34     d2=h(is)-zs
          jaj=is
          call help3(p,vmax,vsp,w(is),v(1),d2,tdist,ttim,ttims)
c up going branch
          if(j.eq.ir)go to 33
c 
c
          do 32 jj=ir+1,j
          jaj=jj
   32     call help3(p,vmax,v(jj),w(jj),v(1),d(jj),tdist,ttim,ttims)
   33     d1=h(ir)-zr
          jaj=ir
          call help3(p,vmax,vr,w(ir),v(1),d1,tdist,ttim,ttims)
      if(tdist.gt.dist)go to 30
c
      ddif=dist-tdist
      tdif=ddif/v(j+1)
ccc      tdifs=tdif*vpvs(j+1)
      tdifs=tdif*vpvs
      tsum=ttim+tdif    
      tssum=ttims+tdifs
      sinuhs=par*v(is)
      cosuhs=sqrt(abs(1.-sinuhs**2))
      tanuhs=sinuhs/cosuhs
      angle=atan(tanuhs)*57.2958
      write(6,*)tsum,tssum,angle,h(j),tdist  ! head waves from source down
ccccc
c
c
      thead=tsum
      ahead=angle
      dhead=h(j)
      write(80,801)
     * stcode,iazi,ifix(ahead),pol,epidis,thead,dhead
c
   30 continue
   38 continue

      goto 2000    ! end of loop over stations

 9999 stop
      end
c
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
      subroutine help4(p,vvv,v,w,v1,d,td,tt,tts)
      real(8) p,vvv,v,w,v1,d,td,tt,tts
      real(8) sina,sina2,v12,pomv,dd,dt,dts,vpvs
      common/b/vpvs,jaj
ccc      dimension vpvs(8)
c
c p=sin of angle
      sina=p/vvv*v1
      v12=v1**2
      sina2=sina**2
      v2=v*v
      pomv=sqrt(abs(v12-v2*sina2))
      dd=2.*d*pomv/(w-v)/sina
      dt=2.*d/(w-v)*dlog((v1+pomv)/v/sina)
ccc      dts=dt*vpvs(jaj)
      dts=dt*vpvs
      td=td+dd
      tt=tt+dt
      tts=tts+dts
      return
      end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine help3(p,vvv,v,w,v1,d,td,tt,tts)
      real(8) p,vvv,v,w,v1,d,td,tt,tts
      real(8) sinan,sinad,cosan,cosad,dd,dt,dts,vpvs
      common/b/vpvs,jaj
ccc      dimension vpvs(8)
c
      sinan=p/vvv*v
      sinad=p/vvv*w
      cosan=sqrt(abs(1.-sinan**2))
      cosad=sqrt(abs(1.-sinad**2))      
      if(w-v.lt..0005)go to 1
      dd=d*(w+v)*sinan/v/(cosan+cosad)
      dt=d/(w-v)*dlog(w*(1.+cosan)/v/(1.+cosad))
ccc      dts=dt*vpvs(jaj)
      dts=dt*vpvs
      go to 2
    1 continue
      dd=d*sinan/cosan
      dt=d/v/cosan
ccc      dts=dt*vpvs(jaj)
      dts=dt*vpvs
    2 continue
      td=td+dd
      tt=tt+dt
      tts=tts+dts
      return
      end
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      subroutine help2(p,vvv,v,w,v1,d,td,tt,tts)
      real(8) p,vvv,v,w,v1,d,td,tt,tts,tana
      real(8) sina,cosa,sinaz,sinad,cosad,dd,dt,dts,vpvs
      common/b/vpvs,jaj
ccc      dimension vpvs(8)
c
      sina=sqrt(1.-p**2)*v/vvv
      cosa=sqrt(abs(1.-sina**2))
c      write(*,112)sina,cosa,p
  112 format(f13.9,2e18.9)
      if(w-v.lt..0005)go to 1
c
      sinaz=sqrt(1.-p**2)
      sinad=sinaz*w/vvv
      cosad=sqrt(abs(1.-sinad**2))
      dd=d*(w+v)*sina/v/(cosa+cosad)
      dt=d/(w-v)*dlog(w*(1.+cosa)/v/(1.+cosad))
ccc      dts=dt*vpvs(jaj)
      dts=dt*vpvs
      go to 2
    1 continue
      tana=sina/cosa
      dd=d*tana
      dt=d/v/cosa
ccc      dts=dt*vpvs(jaj)
      dts=dt*vpvs
    2 continue
      td=td+dd
      tt=tt+dt
      tts=tts+dts
      return
      end
