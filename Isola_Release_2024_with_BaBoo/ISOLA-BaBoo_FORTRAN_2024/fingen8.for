	dimension x(100),y(100),z(100),time(100)
	dimension dist(100),xmom(100),distref(100)
c  smoothed patch (gaussian)     
      open(100,file='sour.dat')      ! input
      open(110,file='mechan.dat')   ! output
      open(200,file='hyp.dat')	   ! input

	  open(300,file='finsplot.dat')  ! output
	  open(400,file='finsour.dat')   ! output
      open(410,file='param.txt')   ! output

	
c	xmomconst=1.e20 ! ????????????????
      write(*,*) 'CAUTION: grid is read from SOUR.DAT !'
      do i=1,4
      read(110,*)
      enddo
      read(110,*) st,di,ra
      write(*,*) 'strike,dip,rake (from allstat)= ',st,di,ra
      
      write(*,*) 'Total moment (Nm)=?'
      write(*,*) 'Important only for opt finsour. Otherwise 1.'
	  write(*,*) '(Real may be smaller due to distance limit)'
      read(*,*) xmomconst
      write(410,*) 'Moment: ',xmomconst

      
      write(*,*) 'rupture velocity (km/s)=?'
      read(*,*) vrup
      write(410,*) 'vrup= ',vrup
      
!                VSUDE je y=EW, x= NS        
      is=1
  10  read(100,*,end=20) y(is),x(is),z(is) !        pozor na PORADI !! y,x nikoli x,y
      is=is+1
      goto 10
  20  continue
      ns=is-1
      write(*,*) 'number of sources=', ns

!                POZOR zde opacne PORADI x= NS, y=EW,         
      read(200,*) xh,yh,zh ! if H not known, take one point from sour.dat
	write(*,*)  xh,yh,zh
	write(*,*) 'overwrite H by a grid point ? (0=no, 1=yes)'
	read(*,*) ikey
c	ikey=1

	if(ikey.eq.1) then  !!!!!!! HYPOC jako jeden z bodu souboru sour.dat
	 write(*,*) 'hypoc. number=?'
	 read(*,*) isrc
	 xh=x(isrc)
	 yh=y(isrc)
	 zh=z(isrc)
	endif 
	write(*,*) 'hypoc isrc: ',isrc
      write(*,*) 'hypoc x,y,z: ',xh,yh,zh
      write(410,*) 'hypoc isrc: ',isrc
      write(410,*) 'hypoc x,y,z: ',xh,yh,zh

     	write(*,*) 'time at hypocenter= ?'
      write(*,*) 'Important only for opt finsour. Otherwise 0.' 
	  	read(*,*) timezero
      write(410,*) 'time at hypocenter: ',timezero

      write(*,*) 'source number for center of patch = ?'
      read(*,*) iref
      write(410,*) 'source number of patch center: ',iref
      xref=x(iref)
      yref=y(iref)
      zref=z(iref)
      
	write(*,*) 'distance limit= ?'
	read(*,*) distlim
      write(410,*) 'distance limit: ',distlim
	  
   
      write(*,*) 'enter fract=sigma/distlim'      
      read(*,*) fract
      sigma=fract*distlim
      write(*,*) 'sigma= ',sigma
      write(410,*) 'sigma: ',sigma
	  
      nlim=0
	do is=1,ns
	if(z(is).gt.0.) then 
	dist(is)=(x(is)-xh)**2 + (y(is)-yh)**2 + (z(is)-zh)**2
	dist(is)=sqrt(dist(is)) ! distance from hypocenter
      distref(is)=(x(is)-xref)**2 + (y(is)-yref)**2 + (z(is)-zref)**2
	distref(is)=sqrt(distref(is)) ! distance from reference point (circle center)
      write(*,*) distref(is)
      if(distref(is).le.distlim) nlim=nlim+1
        time(is)=dist(is)/vrup
        xmom(is)=exp((-1./2.)*(distref(is)**2.)/sigma**2.) 	! new
	else
	time(is)=0.
       xmom(is)=0.  !!!!!!!!!! new	
	write(*,*) 'warning: z<0'
	endif
	enddo
      write(*,*) 'no. of points within limit= ',nlim
   
        sumxmom=0.         ! new
        do is=1,ns ! mohu secist vsechny nebot kdyz ho neberu je nula
        sumxmom=sumxmom+xmom(is)
        enddo  	
	
	do is=1,ns
	time(is)=time(is)+timezero
c      xmom(is)=xmomconst/float(nlim)   ! OLD
        xmom(is)=xmom(is)*xmomconst/sumxmom  ! new
      if(distref(is).gt.distlim) xmom(is)=0.
	write(300,*) y(is),x(is),time(is),xmom(is),is     !! poradi (pro kresleni)
	write(400,'(i5,f10.2,e15.6,3i5)') 
     *      is,time(is),xmom(is),ifix(st),ifix(di),ifix(ra)
      enddo


	stop
	end