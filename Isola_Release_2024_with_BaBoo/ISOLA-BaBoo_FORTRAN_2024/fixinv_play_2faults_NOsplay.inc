      subroutine fixinv_play_2faults_NOsplay(x,w,rinv,asave,corr,
     *	  ish,isour)

c Fixed 100%DC focal mechanism (s/d/r)
	  
c Temporal shift of elemse (in loop); finding moment tensor for each step
c finding correlation for each step
c Input: single trial position elemse in 'w' and data (ori or residual) in 'x'
c Output: iseqm number of loop steps
c Output: array: ish(1,... iseqm) = shifts
c Output: array: corr(1,... iseqm) = correlation; sqrt(psi)=sqrt(1-delta/rr)
c       where delta=residual L2 misfit, rr= data squared; both with weights
c Output: array: asave(1,... iseqm) = moment tensor coefficients


c  	  integer, parameter :: NBS=21 ! NBS = max number of stations
c	  integer, parameter :: NMUL1= 256*NBS*3
c	  include "par_dim_play.inc"

      use mconst
      use numwei
	  
      dimension x(NBO,NBS,3)
      dimension w(NBO,NBS,3,6)
      dimension a(6),rinv(6,6),rold2(6,6)
      dimension corr(100),ish(100),asave(6,100)
	  dimension gnew(6),g(NMUL1,6)
	  dimension xw(NMUL1)
  
c      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
c     *                 ff1(NBS),ff2(NBS),ff3(NBS),ff4(NBS),dt
c      common /WEI/ weig(NBS,3)

	  do i=1,6
	  a(i)=0.
	  enddo

c **************************************************************************
C ** FOCAL MECHANISM (if a priori known and held fixed for all subevents) **
c **************************************************************************
c                  It looks crazy to calculate a's on each subr. call,
c                  would seem better to put in main and transfer by common,
c                  but the intention was to keep main unchanged !!!!

        do i=1,4
        read(200,*)
        enddo
        read(200,*) strike,dip,rake
        REWIND (200)

      if(isour.le.30) then
	  strike = 30;dip=90;rake = 0
      else
	  strike = 60;dip=90;rake = 0
      endif	  

 
       if(strike.eq.0)   strike=0.1         ! NEW July 5, 2014; to prevent problems with zero MT components
       if(strike.eq.180) strike=180.1
       if(dip.eq.90)     dip=89.9
       if(rake.eq.0)     rake=0.1
       if(rake.eq.180)   rake=179.9
      


        xmoment=1.        !!!!!!!!!!!!!!!!!!!!!!!!!!!
        pi=3.1415927
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

 	  xx1 =-(sd*cl*s2p + s2d*sl*sp*sp)*xmoment     ! Mxx
 	  xx2 = (sd*cl*c2p + s2d*sl*s2p/2.)*xmoment    ! Mxy
 	  xx3 =-(cd*cl*cp  + c2d*sl*sp)*xmoment        ! Mxz
 	  xx4 = (sd*cl*s2p - s2d*sl*cp*cp)*xmoment     ! Myy
 	  xx5 =-(cd*cl*sp  - c2d*sl*cp)*xmoment        ! Myz
 	  xx6 =             (s2d*sl)*xmoment           ! Mzz

 	  a(1) = xx2
 	  a(2) = xx3
 	  a(3) =-xx5
 	  a(4) = (-2.*xx1 + xx4 + xx6)/3.
 	  a(5) = (xx1 -2*xx4 + xx6)/3.
      a(6)=0.
c **************************************************************************

	  


c
c     COMPUTING 'POWER' OF THE DATA (observed or residual)
c                  (used stations ONLY ! via weig)

      rr=0.
      do icom=1,3                                       !icom seismo comp.
        do ir=1,nr                                      ! ir =station
           do itim=1,ntim                                   ! itim=time
          xweig=x(itim,ir,icom)*weig(ir,icom)            ! icom seismo comp
          rr=rr+xweig*xweig
          enddo
        enddo
      enddo
      rr=rr*dt



C *********************************************************************
C ********NON-LINEAR PART; THE SHIFT LOOP = GRID SEARCH OVER SHIFT ****
C *********************************************************************

c
c     STARTING  LOOP on SHIFT
c       (time shift = ishift*dt; shift > 0 ... to the RIGHT)

      iseqm=(ilast-ifirst) / istep
      ishift=ifirst

      do 10 iseq=1,iseqm
      ishift=ishift+istep  ! value of the shift





c Redefinition of 'elemse' from array w into 2D array, i.e. matrix
C CAUTION: matrix is newly defined for each shift; matrix as a whole is not shifted
c in its first index, that would be wrong. We correctly shift only in time, see w(itim-ishift...
		
		mt: do n=1,nmom                                    
		jin=0
		  do ir=1,nr ; do icom=1,3 ; do itim=1,ntim ! in this order...
		  jin=jin+1
          
		  g(jin,n)=0.
		  if(itim-ishift.ge.1.and.itim-ishift.le.ntim) then
       g(jin,n)=w(itim-ishift,ir,icom,n) * weig(ir,icom) * 1.e10 ! includes zeroing the non-used stations 
          endif
c                    XXXXXXXXXX we are in loop over 'ishift'          
		  enddo; enddo; enddo 
        enddo mt	

c Redefinition of data vector (incl. wights)
        jin=0
		  do ir=1,nr ; do icom=1,3 ; do itim=1,ntim ! in this order...
		  jin=jin+1
		  xw(jin)=x(itim,ir,icom) * weig(ir,icom) * 1.e10 ! includes zeroing the non-used stations 
          enddo; enddo; enddo 
! After this the whole  Gt d is * 1e20 
		  
c MT (a's) are not calculated  !!!!!!!!!!!!!!!!!!!!
	  
c Computing correlation

	  gnew=matmul( transpose(g), xw)  ! gnew, i.e. Gt d, is *1.e20 (without Cd-1) 
	  gnew=gnew * dt                     
	  
	  sum1=0.
      do n=1,nmom                        ! here a is for unit moment, and prescribed
      sum1=sum1 + a(n)*gnew(n)/1.e20    ! g de-scaled by 1.e20, hence sum1 free of scaling
	  enddo                              ! sum1 is obs * syn   
	  
c        write(661,*) 'a'	   
c        write(661,*) (a(j), j=1,nmom)	   
c        write(661,*)	   
	  
	    rold2=matmul( transpose(g), g) ! NEW this is pure Gt G (not rold, which contains Cd-1)
        rold2=rold2 * dt 
 	    
c		do i=1,nmom          ! printing sytem matrix
c        write(661,'(6(1x,e13.6))') (rold2(i,j),j=1,nmom)
c 	    enddo
           
      sum2=0.                         
      do n=1,nmom
      do m=1,nmom
ccc     sum2=sum2 + rold(n,m) *a(n)*a(m)/1.e20  ! rold inlcudes CD-1, not needed here
      sum2=sum2 + rold2(n,m)*a(n)*a(m) !!!   /1.e20  ! rold2 is simply Gt G; sum 2 is syn*syn     
      enddo                            ! division by 1.e20 cannot occur here (yields < e-38)
      enddo                            ! GT G je ~ 1.e-38, rold jeste * 1.e20 celkem ~ 1e-18  

      xmom=sum1/sum2 
      xmom=xmom * 1.e20      ! newly added to substitute the above division by 1.e20	  
c        write(661,*) 'sum1,sum2,xmom'	   
c        write(661,*) sum1,sum2,xmom   
c        write(661,*)	   
	  
c simple 'scalar' analogy of inversion rinv*G = (1/Rnm)Gm
c ratio between scalar products obs*synt and synt*synt, where synt is for unit moment 
c See Eq. (9) of Zahradnik and Gallovic, JGR 115, B09310, 2010
c The resulting moment tensor will be product of the unitary moment tensor (for fixed mechan) and xmom
c From this definition it is possible that xmom<0, see below (does not mean negative scalar moment!).        

      sum1=xmom*sum1
      sum2=xmom*xmom*sum2

c        write(661,*) 'sum1,sum2,xmom'	   
c        write(661,*) sum1,sum2,xmom   
c        write(661,*)	  

c            Since now already we have 'normal' situation, sum1=sum2,
c            thus delta (L2 fit) and psi (correlation) are computed normally,
c            i.e. using sum1 only.
c        Beware: a() is still for moment=1. Bellow will be multipl. by moment.

c     delta (=indirect L2 misfit) =  error2 (direct), see check later
c     delta=rr - 2.*sum1 + sum2   !
c     delta=rr -    sum1          ! the same (since sum1=sum2)
	  
      psi = sum1 / rr 			  ! = 1- (delta/rr)...correlation squared
      
	  if(psi.lt.0) then			  ! only formal to allow taking sqrt
	  psi=0.
	  else
	  psi=sqrt(psi)   ! psi = correlation
      endif

       if(xmom.lt.0.) then
       psi=0. !!!!!!! IMPORTANT, see explanation below added Oct 5, 2014.		
       xmom=-1. * xmom
       endif

c Xmom can be <0 and psi still >0, see above write(5432). 
c xmom<0 has nothing to do with negative scalar moment!
c Instead MT we work with wights a(n), n=1,2,...6  of 6 elementary MT's. 
c The a(n) are for unit moment, while a(n).xmom are for non-unit moment; 
c i.e., xmom includes size and sign of MT. 
c The case of xmom<0 corresponds to spontaneous change of the prescribed mechanism
c It occurs in order to flip sign of all synth waveforms which then correlate with data.
c In other words, while having no correlation with the prescribed mechanism, the mechanism
c having rake substituted by rak-180 will provide correlation between synth and obs data.
c This can be documented by commenting the line  ' if(xmom.lt.0.) psi=0.'.
c Since we do NOT want such a flip (e.g. when we know that the prescribed rake 
c is consistent with polarities) we put psi=0 in the case of xmom<0. This prevents
c the spontaneous change of the rake and signalizes zero correlation. 
c The variance reduction calculated directly from waveforms will be negative.

	   

c *******************************************************
c      no DC constraint here (it is only in cnsinv)
c *******************************************************


      corr(iseq)=psi    ! saving correlation; iseq counts the shifts
      ish(iseq)=ishift

      do n=1,6        ! here it must be 6, not nmom
      asave(n,iseq)=a(n)*xmom      ! saving  MOMENT COEFFICIENTS
      enddo


 10   continue      ! SHIFT LOOP FINISHED

      RETURN
      END
