c Author: J. Zahradnik, April 2011

	use msimsl	 !!! USING IMSL library !!!!!!!!!!!!!!
	  
	dimension rotselect(100000),strselect(100000)
      dimension div(200),table(200),stat(13)

	open(400,file='elipsa.dat')		! input

c	open(500,file='elipsa_max.dat')	! old option was to output only vicinity of the ellipsoid surface (now the whole ellipsoid) 
      open(510,file='statistics.dat')

c	write(*,*) 'mpts=?'
c	read(*,*) mpts

      ir=1
  10  read(400,*,end=20) 
      ir=ir+1
      goto 10
  20  continue
      mpts=ir-1
      write(*,*) 'mpts= ', mpts
	rewind(400)

	mpts2=0
	do m=1,mpts
   	read(400,'(6e15.5,3x,3f6.0,3x,3f6.0,3x,3f12.0)')
c     *	      dum,dum,zsave,   avol_1,avol_2,avol_3,
     *	      dum,dum,zsave,   avol_2,aclvd_2,adc_2,     ! new Oct 15, 2014
	*         str1,dip1,rake1,str2,dip2,rake2,rotangle

c     old option here was a small vicinity of the ellipsoid surface only	   
c      if(zsave.gt.0.99) then ! 0.99 surface vicinity							 
c     now we output the whole ellipsoid; the result is almost the same as with the surface vicinity 
      if(zsave.gt.0.00) then ! 0.00 = whole ellipsoid							 

c	write(500,'(4e15.5,3x,3f6.0,3x,3f6.0,3x,3f12.0)')     ! for plotting and computing hist in grapher 
c     *	         zsave,avol_1,avol_2,avol_3,
c	*             str1,dip1,rake1,str2,dip2,rake2,rotangle

      mpts2=mpts2+1 
      rotselect(mpts2)=rotangle	! this is enough if computing histogram below in this code (write not needed)

	endif
      enddo

	write(*,*) mpts2 

	numbin=181
	call OWFRQ (mpts2,rotselect,numbin,1,0.5,179.5,1.,div,table)
  

	do i=1,numbin
      write(*,*) div(i),table(i)	 ! midpoints and frequencies of occurrence
	enddo

c      CALL VHSTP (numbin, table, 1, 'angle') ! kresli histogram hvezdickami 'na tiskarne', funguje dobre
c	CALL GRPES (NGROUP, TABLE, CLOW, CWIDTH, IPRINT, STAT)

	clow=0.     ! center of the lowest class interval
	cwidth=1.	    !the class width
      CALL GRPES (numbin, TABLE, CLOW, CWIDTH, 1, STAT)
	write(*,*) 
      write(*,*) 'Kagan: mean,stand.dev.,median'
	write(*,*) stat(2),stat(3),stat(10) 
      write(*,*)
	write(510,*) stat(2),stat(3),stat(10) 

	stop
	end


