	program kagan_map
      
	dimension xmean(98),xstd(98),xmed(98),xlon(98),xlat(98)
      CHARACTER *2 CHR(99)
      CHARACTER *11 filename
 

      DATA CHR/'01','02','03','04','05','06','07','08','09','10',
     *         '11','12','13','14','15','16','17','18','19','20',
     *         '21','22','23','24','25','26','27','28','29','30',
     *         '31','32','33','34','35','36','37','38','39','40',
     *         '41','42','43','44','45','46','47','48','49','50',
     *         '51','52','53','54','55','56','57','58','59','60',
     *         '61','62','63','64','65','66','67','68','69','70', 
	*         '71','72','73','74','75','76','77','78','79','80',
     *         '81','82','83','84','85','86','87','88','89','90', 
	*         '91','92','93','94','95','96','97','98','99'/

	open(50,file='allsrcdeg.dat')

      open(200,file='kagan_map.dat') ! unification of all stat*.dat   


	  do i=1,81 ! number of sources	 FIXED !!!!! (later, when releasing, still it must be less or equal 98 )
	  filename='stat_'//chr(i)//'.dat'
	  read(50,*) xlat(i),xlon(i)
	  open(100,file=filename)   
	  read(100,*)  xmean(i),xstd(i),xmed(i)
	  write(200,'(2(1x,f8.4),3(1x,f4.1))')  
     *	   xlon(i),xlat(i),xmean(i),xstd(i),xmed(i)
	  close(100)
        enddo

	  stop
	  end