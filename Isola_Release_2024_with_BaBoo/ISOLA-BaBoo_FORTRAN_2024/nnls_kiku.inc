C	SUBROUTINE NNLS (A,MDA,M,N,B,X,RNORM,W,ZZ,INDEX,MODE)
C	C.L.LAWSON AND R.J.HANSON. JET PROPULSION LABORATORY. 1973 JUNE 15
C	TO APPEAR IN 'SOLVING LEAST SQUARES PROBLEMS'. PRENTICE-HALL. 1974
C
C	***** NONNEGATIVE LEAST SQUARES *****
C	GIVEN AN M BY N MATRIX, A. AND AN M-BECTOR, B. COMPUTE AN
C	N-VECTOR, X. WHICH SOLVES THE LEAST SQUARES PROBLEM
C
C		A * X =B SUBJECT TO X .GE. 0
C
C	A(),MDA,M,N	MDA IS THE FIRST DIMENSIONING PARAMETER FOR THE
C			ARRAY, A(). ON ENTRY A() CONTAINS THE M BY N
C			MATRIX, A.		ON EXIT A() CONTAINS
C			THE PRODUCT MATRIX, Q*A, WHERE Q IS AN
C			M BY N ORTHOGONAL MATRIX GENERATED IMPLICITLY
C			BY THIS SUBROUTINE.
C	B()	ON ENTRY B() CONTAINS THE M-BECTOR, B. ON EXIT B() 
C		CONTAINS Q*B
C	X()	ON ENTRY X() NEED NOT BE INITIALIZED. ON EXIT X() WILL
C		CONTAIN THE SOLUTION VECTOR.
C	RNORM	ON EXIT RNORM CONTAINS THE EUCLIDEAN NORM OF THE 
C		RESIDUAL VECTOR.
C	W()	AN N-ARRAY OF WORKING SPACE. ON EXIT W() WILL CONTAIN
C		THE DUAL SOLUTION VECTOR. W WILL SATISFY W(I) = 0.
C		FOR ALL I IN SET P AND W(I) .LE. 0. FOR ALL I IN SET Z
C	ZZ()	 AN M-ARRAY I OF WORKING SPACE.
C	INDEX()		AN INTEGER WORKING ARRAY OF LENGTH AT LEAST N.
C			ON EXIT THE CONTENTS OF THIS ARRAY DEFINE THE SETS
C			P AND Z AS FOLLOWS..
C			INDEX(1)   THRU INDEX(NSTEP) = SET P.
C			INDEX(IZ1) THRU INDEX(IZ2)   = SET Z.
C			IZ1 = NSTEP + 1 = NPP1
C			IZ2 = N
C	MODE	THIS IS A SUCCESS-FAILURE FLAG WITH THE FOLLOWING
C		MEANINGS.
C		1	THE SOLUTION HAS BEEN COMPUTED SUCCESSFULLY.
C		2	THE DIMENSIONS OF THE PROBLEM ARE BAD.
C			EITHER M .LE. 0 OR N .LE. 0.
C		3	ITERATION COUNT EXCEEDED. MORE THAN 3*N ITERATIONS.
C

c      subroutine nnls(a,mda,m,n,b,x,rnorm,w,zz,index,mode)
      subroutine nnls_kiku(a,mda,m,n,b,x,rnorm,w,zz,index,mode)
      dimension a(mda,n),b(m),x(n),w(n),zz(m)
	  dimension dummy(m)    ! ?????? jz
      integer index(n)
      zero=0.
C     one=1.
      two=2.
      factor=0.01
c
      mode=1
      if (m.gt.0.and.n.gt.0) go to 10
      mode=2
      return
   10 iter=0
      itmax=3*n
c<initialize index() & x()>
            do 20 i=1,n
            x(i)=zero
   20       index(i)=i
c
      iz2=n
      iz1=1
      nsetp=0
      npp1=1
c<main loop begins here>
   30 continue
c
      if (iz1.gt.iz2.or.nsetp.ge.m) go to 350
c<compute components of the dual (negative gradient) vector w()>
            do 50 iz=iz1,iz2
            j=index(iz)
            sm=zero
                  do 40 l=npp1,m
c            write(6,*) l,j,a(l,j)
   40             sm=sm+a(l,j)*b(l)
c           write(6,*) sm
   50       w(j)=sm
c<find largest positive w(j)>
   60 wmax=zero
            do 70 iz=iz1,iz2
            j=index(iz)
            if (w(j).le.wmax) go to 70
            wmax=w(j)
            izmax=iz
   70       continue
c<if wmax .le. 0. go to termination.
c this indicates satisfaction of the kuhn-tucker conditions>
      if (wmax) 350,350,80
   80 iz=izmax
      j=index(iz)
c<the sign of w(j) is ok for j to be moved to set p.
c begin the transformation and check new diagonal element to avoid
c near linear dependence.>
c
      asave=a(npp1,j)
      call h12 (1,npp1,npp1+1,m,a(1,j),1,up,dummy,1,1,0)
      unorm=zero
      if (nsetp.eq.0) go to 100
            do 90 l=1,nsetp
   90       unorm=unorm+a(l,j)**2
  100 unorm=sqrt(unorm)
      if (diff(unorm+abs(a(npp1,j))*factor,unorm)) 130,130,110
c<col j is sufficiently independent. copy b into zz. update zz and
c solve for ztest (= proposed new value for x(j)).>
  110       do 120 l=1,m
  120       zz(l)=b(l)
      call h12 (2,npp1,npp1+1,m,a(1,j),1,up,zz,1,1,1)
      ztest=zz(npp1)/a(npp1,j)
c<see if ztest is positive>
      if (ztest) 130,130,140
c<reject j as a cndidate to be moved from set z to set p.
c restore a(npp1,j). set w(j)=0.,and loop back to test dual
c coeffs again>
  130 a(npp1,j)=asave
      w(j)=zero
      go to 60
c<the index j=index(iz) has been selected to be moved from
c set z to set p. update b. update indices. apply housholder
c transformations to cols in new set z. zero subdiagonal els in
c col j,set w(j)=0.
  140       do 150 l=1,m
  150       b(l)=zz(l)
c
      index(iz)=index(iz1)
      index(iz1)=j
      iz1=iz1+1
      nsetp=npp1
      npp1=npp1+1
c
      if (iz1.gt.iz2) go to 170
            do 160 jz=iz1,iz2
            jj=index(jz)
  160       call h12 (2,nsetp,npp1,m,a(1,j),1,up,a(1,jj),1,mda,1)
  170 continue
c
      if (nsetp.eq.m) go to 190
            do 180 l=npp1,m
  180       a(l,j)=zero
  190 continue
c
      w(j)=zero
c<solve the triangular system 
c store the solution temporarily in zz()>
      assign 200 to next
      go to 400
  200 continue
c<secondary loop begins here>
c<iteration counter>
  210 iter=iter+1
      if (iter.le.itmax) go to 220
      mode=3
      write (6,440)
      go to 350
  220 continue
c<see if all new constrained coeffs are feasible.
c if not compute alpha.>
      alpha=two
            do 240 ip=1,nsetp
            l=index(ip)
            if (zz(ip)) 230,230,240
c
  230       t=-x(l)/(zz(ip)-x(l))
            if (alpha.le.t) go to 240
            alpha=t
            jj=ip
  240       continue
c<if all new constrained coeffs are feasible then alpha will
c still = 2.  if so exit from secondary loop to main loop.>
      if (alpha.eq.two) go to 330
c<otherwise use alpha which will be between 0. and 1. to
c interpolate between the old x and the new zz.>
      do 250 ip=1,nsetp
      l=index(ip)
  250 x(l)=x(l)+alpha*(zz(ip)-x(l))
c<modify a and b and the index arrays to move coefficient i
c from set p to set z.>
      i=index(jj)
  260 x(i)=zero
c
      if (jj.eq.nsetp) go to 290
      jj=jj+1
            do 280 j=jj,nsetp
            ii=index(j)
            index(j-1)=ii
            call g1 (a(j-1,ii),a(j,ii),cc,ss,a(j-1,ii))
            a(j,ii)=zero
                  do 270 l=1,n
                  if (l.ne.ii) call g2 (cc,ss,a(j-1,l),a(j,l))
  270             continue
  280       call g2 (cc,ss,b(j-1),b(j))
  290 npp1=nsetp
      nsetp=nsetp-1
      iz1=iz1-1
      index(iz1)=i
c<see if the remaining coeffs in set p are feasible. they should
c be because of the way alpha was determined.
c if any are infeasible it is due to round-off error. any
c that are nonpositive will be set to zero
c and moved from set p to set z.>
            do 300 jj=1,nsetp
            i=index(jj)
            if (x(i)) 260,260,300
  300       continue
c<copy b() into zz(). then solve again and loop back.>
            do 310 i=1,m
  310       zz(i)=b(i)
      assign 320 to next
      go to 400
  320 continue
      go to 210
c<end of secondary loop>
  330       do 340 ip=1,nsetp
            i=index(ip)
  340       x(i)=zz(ip)
c<all new coeffs are positive. loop back to beginning.>
      go to 30
c<end of main loop>
c<come here for termination.>
c<compute the norm of the final residual vector.>
  350 sm=zero
      if (npp1.gt.m) go to 370
            do 360 i=npp1,m
  360       sm=sm+b(i)**2
      go to 390
  370       do 380 j=1,n
  380       w(j)=zero
  390 rnorm=sqrt(sm)
      return
c<the following block of code is used as an internal subroutine
c to solve the triangular system, putting the solution in zz()>
  400       do 430 l=1,nsetp
            ip=nsetp+1-l
            if (l.eq.1) go to 420
                  do 410 ii=1,ip
  410             zz(ii)=zz(ii)-a(ii,jj)*zz(ip+1)
  420       jj=index(ip)
  430       zz(ip)=zz(ip)/a(ip,jj)
      go to next, (200,320)
  440 format (35h0 nnls quitting on iteration count.)
      end
c
c
c
      subroutine h12 (mode,lpivot,l1,m,u,iue,up,c,ice,icv,ncv)
      dimension u(iue,m),c(1)
      double precision sm,b
      one=1.
c
      if (0.ge.lpivot.or.lpivot.ge.l1.or.l1.gt.m) return
      cl=abs(u(1,lpivot))
      if (mode.eq.2) go to 60
c<construct the transformation.>
            do 10 j=l1,m
   10       cl=amax1(abs(u(1,j)),cl)
      if (cl) 130,130,20
   20 clinv=one/cl
      sm=(dble(u(1,lpivot))*clinv)**2
            do 30 j=l1,m
   30       sm=sm+(dble(u(1,j))*clinv)**2
c<convert dble. prec. sm to sngl. prec. sm1>
      sm1=sm
      cl=cl*sqrt(sm1)
      if (u(1,lpivot)) 50,50,40
   40 cl=-cl
   50 up=u(1,lpivot)-cl
      u(1,lpivot)=cl
      go to 70
c<apply the transformation i+u*(u**t)/b to c.>
   60 if (cl) 130,130,70
   70 if (ncv.le.0) return
      b=dble(up)*u(1,lpivot)
c<b must be nonpositive here. if b=0. return.>
      if (b) 80,130,130
   80 b=one/b
      i2=1-icv+ice*(lpivot-1)
      incr=ice*(l1-lpivot)
            do 120 j=1,ncv
            i2=i2+icv
            i3=i2+incr
            i4=i3
            sm=c(i2)*dble(up)
                  do 90 i=l1,m
                  sm=sm+c(i3)*dble(u(1,i))
   90             i3=i3+ice
            if (sm) 100,120,100
  100       sm=sm*b
            c(i2)=c(i2)+sm*dble(up)
                  do 110 i=l1,m
                  c(i4)=c(i4)+sm*dble(u(1,i))
  110             i4=i4+ice
  120       continue
  130 return
      end
c
c
c
      subroutine g1 (a,b,cos,sin,sig)
      zero=0.
      one=1.
      if (abs(a).le.abs(b)) go to 10
      xr=b/a
      yr=sqrt(one+xr**2)
      cos=sign(one/yr,a)
      sin=cos*xr
      sig=abs(a)*yr
      return
   10 if (b) 20,30,20
   20 xr=a/b
      yr=sqrt(one+xr**2)
      sin=sign(one/yr,b)
      cos=sin*xr
      sig=abs(b)*yr
      return
   30 sig=zero
      cos=zero
      sin=one
      return
      end
c
c
c
      subroutine g2 (cos,sin,x,y)
c
      xr=cos*x+sin*y
      y=-sin*x+cos*y
      x=xr
      return
      end
c
c
c
      function diff(x,y)
c
      diff=x-y
      return
      end
c
c
c
