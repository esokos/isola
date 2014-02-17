	program elecomb


c	it reads elemse_01, _02,... _04 for crustal models _01..._04 
c     and combines them into elemse.dat 
c     all just for a SINGLE source 
c       (loop over sources is in grenew.bat)

C     J. Zahradnik; June 2009


      CHARACTER *2 chrcrust(4)
      character *13 filename
      CHARACTER *3 statname(21)

c     dimension  w(-1250:9442,21,3,6)
c     dimension w2(-1250:9442,21,3,6)
      dimension  w(8192,21,3,6)
      dimension w2(8192,21,3,6)
	dimension timetime(8192)
	dimension irc(21)

      DATA chrcrust/'01','02','03','04'/


	ntim=8192 ! fixed

c
c        READING relation between stations and crustal models from ALLSTAT2
c	   (numc ... number of crustal models is also determined)
c

      open(50,file='allstat2.dat') !!! NEW allstat with 1 or 2 in the last column
      ir=1
  10  read(50,*,end=20) statname(ir),dum,dum,dum,dum,irc(ir) ! irc(ir)  added
      ir=ir+1
      if(ir.gt.21) goto 20
      goto 10
  20  continue
      nr=ir-1
      write(*,*) 'nr=', nr
	do ir=1,nr
	write(*,*) statname(ir), ' crustal model no. ', irc(ir)
      enddo


	numc=0      
      do ir=1,nr
	if (irc(ir).gt.numc) numc=irc(ir) 
	enddo ! numc is the number of different crustal models
	if(numc.gt.4) then 
	write(*,*) 'no more than 4 crustal models allowed ! STOP!!'
	goto 1000
      endif
	write(*,*) 'number of crustal models= ', numc


c
c        LOOP over crustal models 
c
c

	do ic=1,numc ! over numc crustal models; numc.le.4
	filename='elemse_'//chrcrust(ic)//'.dat'
      open(100,form='unformatted',file=filename)     ! elementary seismograms from ELEMSE (input)


c
c        READING 6 ELEMENTARY velocity SEISMOGRAMS, a single point source
c
c

      do ir=1,nr
        do it=1,6        
          do itim=1,ntim   
          read(100) timetime(itim),
     *          w(itim,ir,1,it),w(itim,ir,2,it),w(itim,ir,3,it)
          enddo
        enddo
      enddo

c
c        SELECTING  ELEMENTARY SEISMOGRAMS according the crustal model
c
c
c	potrebuje prirazeni modelu k jednotlivym stanicim ; pole irc(nr)
c     irc(j)=1,2,3 ... station j needs crustal model ic=1,2,3 

	do ir=1,nr
	if(irc(ir).eq.ic) then  ! adopting current elemse if good for a given station 
	  do it=1,6        
          do itim=1,ntim   
              w2(itim,ir,1,it)=w(itim,ir,1,it)
			w2(itim,ir,2,it)=w(itim,ir,2,it)
			w2(itim,ir,3,it)=w(itim,ir,3,it)
          enddo
         enddo
      endif
      enddo


	close (100)
	enddo ! over crustal models


      open(200,form='unformatted',file='elemsenew.dat')     ! elementary seismograms from ELEMSE (input)

      do ir=1,nr
        do it=1,6        
          do itim=1,ntim   
          write(200) timetime(itim),
     *          w2(itim,ir,1,it),w2(itim,ir,2,it),w2(itim,ir,3,it)
          enddo
        enddo
      enddo


1000  STOP
      END





