
c      reading 5 or 6 components, see below 

  	dimension v(6,6),vtow2(6,6),veli(6),cov(6,6)
 	dimension corcof(6,6)
	dimension w(6),err(6),errdomin(6),sig(6)
      open(100,file='vect.dat')
	open(200,file='sing.dat')
	open(300,file='sigma.dat')
	open(400,file='sigma_short.dat')


	nmom=6            !!!!!!!!! Fixed ; cannot be edited !!!!      

      do i=1,nmom
      read(100,*) (v(i,j),j=1,nmom) ! i...cislo slozky,  j... cislo vektoru
	enddo

c	do j=1,6       ! test ze jsou to vektory normovana na 1.0
c	veli(j)=0.
c	do i=1,6
c	veli(j)=veli(j)+v(i,j)*v(i,j)
c	enddo
c	write(300,*) veli(j)
c	enddo
 
     	 
 	read(200,*) (w(j),j=1,nmom)  ! sing. val. assumed to have correct order of magnitude'
      
	do j=1,nmom
	w(j)=w(j)*1.e20   ! * 1.e20 to prevent numerical problems with small w's
	enddo

c
    
      write(300,*)  
	write(300,*) 'sing. vectors (in columns)'
	do i=1,nmom
	write(300,'(6e15.6)')  (v(i,j),j=1,nmom) ! i...cislo slozky,  j... cislo vektoru
	enddo
    
      write(300,*)
    	write(300,*) 'sing. values; to be * 1.e-20'
     	write(300,'(6e15.6)') (w(j),j=1,nmom)
	


c          Variances of parameters (and standard deviations)

c      write(300,*)       
c	write(300,*) ' ctverce chyb (v/w)^2; to be * 1.e40'
	do i=1,nmom	 ! cykl pres slozky
	sig(i)=0. 
       do j=1,nmom  ! cykl pres vektory
       vtow2(i,j)=(v(i,j)/w(j))**2 	! v(i,j): i slozka, j vektor
	 sig(i)=sig(i)+vtow2(i,j)
      enddo
      sig(i)=sqrt(sig(i))
c	write(300,'(6e15.6)') (vtow2(i,j),j=1,nmom)
	enddo

c     write(300,*)
c	write(300,*) ' SQRT souctu ctvercu chyb (v/w)^2; to be * 1.e20'
c	write(300,*) ' = SIGMA from isola (incl. vardat)'
c      do i=1,nmom
c      write(300,'(6e15.6)') sig(i) ! stand. dev. = sqrt(variance) !!!!!!
c	enddo 

c      write(300,*) 

c          Covariances of parameters (covariance matrix)

      write(300,*)
	write(300,*) ' Covariance matrix; to be * 1.e+40'
	do i=1,nmom	 ! cykl pres slozky
      do k=1,nmom	 ! cykl pres slozky
      cov(i,k)=0.
	 do j=1,nmom  ! cykl pres vektory
       parsum=(v(i,j)*v(k,j))/w(j)**2 	! v(i,j): i slozka, j vektor
	 cov(i,k)=cov(i,k)+parsum
      enddo
	enddo
      write(300,'(6e15.6)') (cov(i,k),k=1,nmom) ! covariance
	enddo		 ! diag. elements = variance (stand deviation squared)

c  Pearson's correlation coefficient

      write(300,*)
	write(300,*) 'Pearson correlation coefficient'
	do i=1,nmom	 ! cykl pres slozky
      do k=1,nmom	 ! cykl pres slozky
      corcof(i,k)=cov(i,k)/sqrt(cov(i,i)*cov(k,k))
	enddo
      write(300,'(6e15.6)') (corcof(i,k),k=1,nmom) ! 
     	enddo
     	write(300,*)


	
      do i=1,nmom
      write(400,'(6e15.6)') sig(i) ! to be *1.e20 !!!
	enddo 





	stop
	end