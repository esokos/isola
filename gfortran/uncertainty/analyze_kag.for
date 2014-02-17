      program analyze_kag

c       add P and T axes !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

c to analyze vicinity of the ellipsoid surface
c Author: J. Zahradnik, April 2011

	use msimsl	 !!! USING IMSL library !!!!!!!!!!!!!!
	  
	dimension rotselect(3600000),strselect(3600000)
      dimension div(200),table(200),stat(13)

	open(400,file='elipsa.dat')		! input

	open(500,file='elipsa_max.dat')	! output (to plot everything in vicinity of the ellipsoid surface) 
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
   	read(400,'(6e15.5,3x,3f6.0,3x,3f6.0,3x,3f12.2)')
     *	      dum,dum,zsave,   avol_1,avol_2,avol_3,
	*         str1,dip1,rake1,str2,dip2,rake2,rotangle

c          SELECTING small vicinity of the ellipsoid SURFACE	   
      if(zsave.gt.0.01) then	!! 0.01 or 0.99 almost the same histogram         0.01/0.99=fine/coarse 						 

	write(500,'(4e15.5,3x,3f6.0,3x,3f6.0,3x,3f12.2)')       ! for plotting and computing hist in grapher 
     *	         zsave,avol_1,avol_2,avol_3,
	*             str1,dip1,rake1,str2,dip2,rake2,rotangle
	mpts2=mpts2+1 
      rotselect(mpts2)=rotangle	! this is enough if computing histogram below in this code (write not needed)
	strselect(mpts2)=str1
	
	write(500,'(4e15.5,3x,3f6.0,3x,3f6.0,3x,3f12.2)')   ! this second write (str2 instead str1...) is to have 
     *	         zsave,avol_1,avol_2,avol_3,			! all possible values of strike in ONE column; not needed for rotangle
	*             str2,dip2,rake2,str1,dip1,rake1,rotangle
	mpts2=mpts2+1 
      rotselect(mpts2)=rotangle
	strselect(mpts2)=str2 ! later if we need stratistsics of strike etc we will use analogically to rotselect

	endif
      enddo

	write(*,*) mpts2 

c pokud mam v grapheru rozsah 0-14 (7 intervalu s centry 1,2,,,,13) zadam toto:
c	call OWFRQ (mpts2,rotselect,7,1,2.,12.,1.,div,table)
c pokud chci 4 biny, s midpointy 0,1,2,3 zadam toto
c           (cili zadavam DRUHY  a PREDposledni delici bod; prvni je -0.5, posledni je 3.5) 
c	numbin=4
c	call OWFRQ (mpts2,rotangle,numbin,1,0.5,2.5,1.,div,table)
c hodi se prave stredolve body celociselne, nebot rotangle je celosicselny a tak
c nevznika problem do ktere skatulky jednotlive uhly dat (jako by vnikl kdyby delici body byly celocoselne)

c  pokud chci 8 skupin, stredni body 1, 2, ,,, 15    
c	numbin=8
c	call OWFRQ (mpts2,rotselect,numbin,1,2.,14.,1.,div,table)

c    pokud chci 91 binu se stredovymi body 0, 1, ...90 zadam druhy a predposledni delici bod, cili 0.5 a 89.5
c	numbin=91
c	call OWFRQ (mpts2,rotselect,numbin,1,0.5,89.5,1.,div,table)

	numbin=181
	call OWFRQ (mpts2,rotselect,numbin,1,0.5,179.5,1.,div,table)
  

c	do i=1,numbin
c	xxx=exp(-0.0001*table(i)**2.)
c      write(123,*) div(i),table(i),xxx	 ! midpoints and frequencies of occurrence
c	enddo

c      CALL VHSTP (numbin, table, 1, 'angle') ! kresli histogram hvezdickami 'na tiskarne', funguje dobre


c	CALL GRPES (NGROUP, TABLE, CLOW, CWIDTH, IPRINT, STAT)
	clow=0.     ! center of the lowest class interval
	cwidth=1.	    !the class width
      CALL GRPES (numbin, TABLE, CLOW, CWIDTH, 1, STAT)
	write(*,*) 
      write(*,*) 'mean,stand.dev.,median'
	write(*,*) stat(2),stat(3),stat(10) 
      write(*,*)
	write(510,*) stat(2),stat(3),stat(10) 

	stop
	end


