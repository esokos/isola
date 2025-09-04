      subroutine isorand_B2

c Read raw dat (velocity) of all stations, filter, put in common /OBSD/
c Read elemse for all trial positions , filter, put in common /ELEMS/

c Calling subroutines: isorand_manidata, isorand_eleonly (both calling filter_play)

      parameter (nhdat=21*3*1024) ! max length of data column 

      CHARACTER *2 CHR(99)
      CHARACTER *12 filename
      CHARACTER *5 statname(21)

      dimension   ori(1024,21,3)
      dimension   w(1024,21,3,6)  
      dimension   e(1024,21,3,6,99) ! max 99 trial source positions  !!!!!!!!
      dimension   bvesave(nhdat)	  !obs data in a column 

      dimension ntm(21),keygps(21)
      dimension nuse(21),weig(21,3),weigorig(21,3)

      logical stat(21)   ! not used, but keep

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
     
 
       common /NNLS/ nshf,keymomcns,xmomreq12,ngrid
       common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm,statname
      common /WEI/ nuse,weig,weigorig	   
      common /OBSD/ ori,rrori,bvesave,numdat,bvecnst
      common /ELEMS/ e	  

      write(*,*) 'This is isorand_B2'
c	  write(*,*) 'ngrid:',ngrid
	  
      
	  ori=0.     ! array; initialization !!  
      keygps=0   ! array; zeroing; an old feature (to be kept)
c	  rrori=0.

! *******************************************************************
! ***READING and MANIPULATING OBSERVED DATA *************************
! *******************************************************************
	  
       call isorand_manidata(ori)    ! manipulate OBSERVED data (all stations)
!           input: read from file in the subroutine
!           output: ori=ori data filtered
C      write(*,*) 'raw data read and filtered; no weights applied' 

      bvemax=maxval(ori) 
c      write(*,*) 'max. of data column= ',bvemax
	  
 
! *******************************************************************
! ************ MANIPULATING ELEMENTARY SEISMOGRAMS *********************
! *******************************************************************
      do isour=1,ngrid       
      filename='elemse'//chr(isour)//'.dat'

      call isorand_eleonly(filename,w)       ! filtered elemse all stations, single trial source
           
          do itim=1,ntim
          do ir=1,nr
          do icom=1,3
          do im=1,6 ! still all 6 are needed
          e(itim,ir,icom,im,isour)=w(itim,ir,icom,im) ! e= all trial sources 
c          write(445,*) w(itim,ir,icom,im) ! e= all trial sources 
          enddo
          enddo
          enddo
          enddo
      enddo 	  
C      write(*,*) 'elemse for all trial positions read and filtered'
C      write(*,*) 'weights not applied to elemse '


 
      RETURN
	  
      END

