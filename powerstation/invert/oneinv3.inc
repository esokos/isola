      subroutine oneinv3(x,dur,xmomreq,w,rinv,ampl)

c Input: x=data, w= seismograms for different time fctns, = columns of matrix G
c Output: ampl = amplitudes of time fctns (solution of matrix system)

      dimension g(6),rinv(6,6)
      dimension x(8192,21,3)
      dimension w(8192,21,3,6)
c *******************************
      double precision  ampl(6)
c      dimension ampl(6)
c *******************************      
      dimension ntm(21)
      dimension weig(21,3)
      logical stat(21)


      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 f1,f2,f3,f4,dt
      common /ST/ stat,ntm
      common /WEI/ weig

c
c     FORMING RIGHT-HAND SIDE OF THE SYSTEM 
c

c     nmom passed from common; number of time functions, hence aplitudes to determine
      do it=1,nmom                                        !it ... time functions 
      g(it)=0.                                            !itim time
        do icom=1,3                                       !icom seismo comp.
          do ir=1,nr                                      !ir station
          if(stat(ir)) then
             do itim=1,ntim
             
c nove, vymena posledni radky dat za moment ele jen zde, jinak se data nemeni             
c             if(itim.eq.8192.and.ir.eq.nr.and.icom.eq.3) then
c             xweig=xmomreq*1.e-22  *weig(ir,icom) ** 2.
c             else
             xweig=x(itim,ir,icom)*weig(ir,icom) ** 2.
c             endif
c             
c             if(itim.eq.8192.and.ir.eq.nr.and.icom.eq.3) then
c             g(it)=g(it)+
c     *            1.e-22             *xweig * 1.e20
c             else
             g(it)=g(it)+
     *            w(itim,ir,icom,it)*xweig * 1.e20
c             endif
     
     
             enddo
          endif
          enddo
        enddo
	g(it)=g(it)*dt
      
	
      enddo


c
c     APPLYING INVERSE MATRIX TO THE RIGHT-HAND SIDE (WITHIN SHIFT LOOP)
c


      do n=1,nmom                   
      ampl(n)=0.                       
        do m=1,nmom                 
        ampl(n)=ampl(n)+ rinv(n,m)*g(m)   
        enddo                       
      enddo


      RETURN
      END
