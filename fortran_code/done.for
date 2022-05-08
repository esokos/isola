       program done

       open(1,file='done',status='new')

	 write(1,'(a4)') "done"
	   
	 close(1)
	   
	 stop
	   
	 end 