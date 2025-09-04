      program isorand_main_gui
c stations are varied (all 3 components have the same weight) 

c Isola construction kit; JZ 2024-25
 
c: ntim=1024 
c: calling isorandA2,B2,C2 
c: open unformatted (binary) files in eleonly22_1024.inc
c: Compilation: i64; ifx isorand_main_gui.for [new substitute for older ifort ]

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /VAR/ vardat 
      common /WEI/ nuse,weig,weigorig	
c      common /PERT/ npert,nuseall
      
      dimension ntm(21)
      dimension nuse(21),weig(21,3),weigorig(21,3)
      dimension wee(63000) ! max 1000 perturbations, 21 stations, 3 components= max 6300 weights  

      open(152,file='inpinv2.dat')   ! input of perturbed weights (prepared in my_boo... Matlab) 
      open(111,file='inv111.dat',status='unknown')     ! detailed MT output written from isorand_C2
      open(114,file='isorandinp.inp')
      open(122,file='CLVDetc.dat')     ! output for Hudson, written from isorand_C2
      open(400,file='sigma_all.dat')                   ! cova matrix Cm     written from isorand_C2

c To prepare perturbations: In any foder, e.g. invert, use Matlab, call my_boo_baboo_weig (...,...).
c For example my_boo_baboo_weig(10,3) if having 10 stations and wishing 3 sets of bootstrap weights
c The weights appear in files weights_BOO.dat and weights_BABOO.dat as a single column
c (first pertubed set 1 (all stations). Seelect one of them and copy it in inpinv2.dat in invert. 
c
c After the calculations, to plot Hudson, CLVDetc.dat is created in invert folder
C In Matlab: manually go to folder 'invert', and type Hudson_my 

	  
      vardat=6.e-8   ! Fixed option (example Corinth) here (temporary); goes to C2 via common /VAR/
c                    ! think about diagonal matrix instead	  

	  
c *********************************************************************************
c Calling A2
c Reading station info, weights, frequencies 
c Creating commons /NNLS/, /NUMBERS/, /ST/, /WEI/
       
      write(*,*) 'This is isorand_main'
      call isorand_A2	  ! initial allstat.dat, no perturbation 
      if(nmom.eq.6)  write(*,*) 'full MT mode'
      if(nmom.eq.5)  write(*,*) 'deviatoric MT mode'
      if(nmom.eq.999) then
      write(*,*) 'STOP! Check inpinv.dat. Only full and devia allowed'
      stop
      endif	  
      write(*,*) 'isorand_A2 finished'
c      write(*,*) (nuse(i),i=1,nr) ! 1/0 for station used Y/N
c      write(*,*)
c      do ir=1,nr
c      write(*,*) (weig(ir,icom),icom=1,3)      	  
c      enddo	
	  
c *********************************************************************************
c Calling B2
c Reading observed velocity waveforms, calculating filtered displacements, creating /OBSD/, no weights
c Reading elementary seismograms, creating /ELEMS/, no weights

      call isorand_B2	  ! only once   ! Output of FIL is made
	  write(*,*) 'isorand_B2 finished'

c *********************************************************************************
c Loops over position and time = repeated  calling C2
c Each time doing:
c Weighting data d and matrix G
c Calculating MT and VR
c Possibility of re-weighting

      write(*,*) 'number of perturbations= :' ! each pert. modifies all 3 components EQUALLY
c      read(*,*) npert  
      read(114,*)
      read(114,*) npert
      if(npert.gt.6300) then
      write(*,*) 'STOP problem DIM npert'
      STOP
      endif
      write(*,*) 'npert=', npert


      write(*,*) 'first position no., last position, step= :'
c      read(*,*) ismin, ismax, isstep  
      read(114,*)
      read(114,*) ismin, ismax, isstep  
      write(*,*) 'position from, to, step: ',ismin,ismax,isstep

      write(*,*) 'time from to (in seconds after OT)= :'
c     read(*,*) shiftMIN,shiftMAX 
      read(114,*)	  
      read(114,*) shiftMIN,shiftMAX, dummy 
      write(*,*) 'time from to: ', shiftMIN,shiftMAX
      close (114)
	  ii1=ifix(shiftMIN/dt)
	  ii2=ifix(shiftMAX/dt) 
      ii3= 1 ! step is one dt	  
 
c      nallwee=npert*nr*3 ! number of weights
      nallwee=npert*nr    ! number of weights (all 3 comp of a station have the same weight, see_my_baboo_wei)
 
c       ! SUPER OUTER LOOP over perturbations 
	  
	  wee=1. ! initialization for station perturbations 

         if(npert.ne.0) then 
      do iw=1,nallwee
      read(152,*) wee(iw)
      enddo
      close(152) 
      write(*,*) 
         else
      write(*,*) 'no perturbation; npert set to 1'
	  npert=1
         endif	  
		
      write(*,*) 'Running perturbations 1 to npert'
  
      do ip=1,npert    ! OUTERmost LOOP over perturbations
      ipert=ip
c      write(*,*)
	  sumwei=0.
c      write(*,*) 'perturbation no.: ', ipert
c      write(*,*) 'station weights: '

	     do ir=1,nr ! loop over stations
		 ipp=(ip-1)*nr + ir
 	     weig(ir,1)=wee(ipp)*weigorig(ir,1) 
	     weig(ir,2)=wee(ipp)*weigorig(ir,2)
	     weig(ir,3)=wee(ipp)*weigorig(ir,3)
c		 sumwei=sumwei+weig(ir,1)+weig(ir,2)+weig(ir,3)
		 sumwei=sumwei+wee(ipp)
         enddo


c	     do ir=1,nr ! loop over stations
c		 ip1=(ip-1)*nr*3 + (ir-1)*3 + 1
c		 ip2=ip1+1
c		 ip3=ip1+2
c 	     weig(ir,1)=wee(ip1)*weigorig(ir,1) 
c	     weig(ir,2)=wee(ip2)*weigorig(ir,2)
c	     weig(ir,3)=wee(ip3)*weigorig(ir,3)
cc	     weig(ir,2)=weig(ir,1)   ! all 3 comp have same weight then sum of weights in a perturbation is not = 1
cc	     weig(ir,3)=weig(ir,1)
c		 sumwei=sumwei+weig(ir,1)+weig(ir,2)+weig(ir,3)
c         enddo
c when each component has its own weight then results have a bit larger dispersion
c but sum of weights in each perturbation = 1 [provided all stations had initial weight = 1, not 0]
c according to theory, weighting comp is not OK because they are dependent;
c thus weighting only stations (all 3 comp same weight) is theoretically better but sum of weights in each pert is not teh same ( not =1)
c to have it =1 we would have to change generator of weights and genarate so many weights as the number of stations, not x 3		 
c
c when initial weights are not =1 . e.g. some are =0, sum of weights in perturbations will always differ
		 
c      write(*,*) (weig(ir,1),weig(ir,2),weig(ir,3),ir=1,nr)	  
c      write(*,*) sumwei 	  
 

      do iss=ismin,ismax,isstep ! loop over trial source positions
c      write(*,*) 	  
      isour1=iss   ! definition of the trial source 
c      write(*,*) 'position no.: ',isour1 	  

	  
      do ii=ii1,ii2,ii3 ! INNERmost loop over time   
	  keywrite=0
	  ishf1=ii
c      write(*,*) 'Tested position and time (s): ', isour1,ishf1*dt
      if(ii.eq.ii1) keywrite=1 
      call isorand_C2(ipert,isour1,ishf1,keywrite) ! Output of RES and SYN is suppressed

      enddo ! endo of inner loop over time (ii)   
      enddo ! end of out loop over positions (iss)
	  
      enddo ! end of superouter loop over perturbations (ip)
      close(111);close(122); close(400)
c *********************************************************************************

 888   write(*,*) 'isorand_main finished'
	   


      STOP
      END

!c =================================================================
      include "isorand_A2.inc" 
      include "isorand_B2.inc" 	  
      include "isorand_C2.inc" 	  

      include "isorand_manidata.inc" 
      include "isorand_eleonly.inc"
      include "filter_play.inc"
      include "subevnt22_1024.inc"
	  
      include "silsub2.inc"
      include "jacobi.inc"
      include "line.inc"
      include "ang.inc"
      include "angles.inc"
      include "lubksb.inc"
      include "ludcmp.inc"

