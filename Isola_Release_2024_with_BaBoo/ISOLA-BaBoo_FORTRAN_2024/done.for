         program done

         open(1,file='done.tmp',status='new')

	 write(1,'(a4)') "done"
	   
	 close(1)
	 
	 write(*,*) "Done ended"
	   
	 stop
	   
	 end 