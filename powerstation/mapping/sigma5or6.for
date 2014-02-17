

  	dimension v(6,6),vtow2(6,6),veli(6)
	dimension w(6),err(6),errdomin(6),sig(6)
      open(100,file='vect.dat')
	open(200,file='sing.dat')
	open(300,file='sigma.dat')
	open(400,file='sigma_short.dat')


	nmom=6            ! older option was 5 or  6, now only  6     

      do i=1,nmom
      read(100,*) (v(i,j),j=1,nmom) ! i...component,  j... vector
	enddo

 	read(200,*) (w(j),j=1,nmom)   ! sing. values
      
	do j=1,nmom
	w(j)=w(j)*1.e20   ! * 1.e20 to prevent numerical problems with small w's
	enddo

c
    
      write(300,*)  
	write(300,*) 'vectors written in columns'
	do i=1,nmom
	write(300,'(6e15.6)')  (v(i,j),j=1,nmom) 
	enddo
    
      write(300,*)
    	write(300,*) 'sing. values; to be * 1.e-20'
     	write(300,'(6e15.6)') (w(j),j=1,nmom)

      write(300,*)       
	write(300,*) ' squared errors (v/w)^2; to be * 1.e40'
	do i=1,nmom	  ! over components
	sig(i)=0. 
       do j=1,nmom  ! over vectors
       vtow2(i,j)=(v(i,j)/w(j))**2 	! v(i,j): i=comp, j=vector
	 sig(i)=sig(i)+vtow2(i,j)
      enddo
      sig(i)=sqrt(sig(i))
	write(300,'(6e15.6)') (vtow2(i,j),j=1,nmom)
	enddo

      write(300,*)
	write(300,*) ' SQRT of sum of errors(v/w)^2; to be * 1.e20'
	write(300,*) ' = SIGMAs from isola (incl. vardat)'
      do i=1,nmom
      write(300,'(6e15.6)') sig(i) !std. deviation of parameters
	enddo 
	
      do i=1,nmom
      write(400,'(6e15.6)') sig(i)
	enddo 


	stop
	end