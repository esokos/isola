      program isorand_postproc

      parameter (NG=100000)  !10000=max(numpos *numtim) ! numpos, numtime number of positions and times       
      parameter (NG2=200)   !200 =max(nsel) ; nsel number of "the best"
      dimension npert(NG),nsour(NG),ntim(NG),
     * strg(NG),dipg(NG),rakg(NG),
     *	 amog(NG),adcg(NG),aclg(NG),avog(NG),varg(NG),
     *   a1g(NG),a2g(NG),a3g(NG),a4g(NG),a5g(NG),a6g(NG)		  
      dimension bb(NG2)      
      dimension sela1(NG2),sela2(NG2),sela3(NG2),
     *	        sela4(NG2),sela5(NG2),sela6(NG2),
     *          selamog(NG2),seladcg(NG2),
     *          selaclg(NG2),selavog(NG2)	 
      dimension selvarg(NG2),nselnpert(NG2)
      dimension nselnsour(NG2),nselntim(NG2)	 
	  
      open(111,file='inv111.dat')
      open(122,file='CLVDetc.dat')       ! input
      open(114,file='isorandinp.inp')
      open(133,file='CLVDetcPOST.dat')   ! output from which we plot boo_plots  
      open(135,file='CLVDetcPOST_BEST.dat') ! selecting one or two best (VR) solutions for each perturbation 
c If I want only best-fit solutions
c 1. Copy CLVDetcPOST_BEST.dat into CLVDetcPOST.dat
c 2. Matlab window: Cd invert
c 3. Matlab window: my_boo_plots
c Which in syntestu will give for earch pert just 1 best-fit = exact solution

c      open(137,file='CLVDetcMEAN.dat')

c      xmclvd=0.;xmvol=0.;
c	  xmhrv1=0.; xmhrv2=0.; xmhrv3=0.;xmhrv4=0.;xmhrv5=0.;xmhrv6=0.;
c      nbestall=0

      write(*,*) 'number of perturbations= '
c      read(*,*) numper  
      read(114,*)
      read(114,*) numper
      if(numper.gt.NG) then
      write(*,*) 'STOP problem DIM numper'
      STOP
      endif
      write(*,*) 'numper= ', numper


      write(*,*) 'number of positions= ?:'
c      read(*,*) numpos 
      read(114,*)
      read(114,*) ismin, ismax, isstep  
      write(*,*) 'position from, to, step: ',ismin,ismax,isstep
      numpos = ifix( float((ismax-ismin)/isstep) ) + 1
      write(*,*) 'numpos= ', numpos
c	  numpos= 27 ! number of positions

      write(*,*) 'number of times= :'
c      read(*,*) numtim 
      read(114,*)	  
      read(114,*) shiftMIN,shiftMAX, dt      
	  ii1=ifix(shiftMIN/dt)
	  ii2=ifix(shiftMAX/dt) 
      ii3= 1 ! step is one dt	  
      numtim=ii2-ii1 + 1
      write(*,*) 'numtim= ', numtim
c	  numtim=15 ! number of times
 
      numsol=numpos*numtim
      write(*,*) 'numsol= ', numsol

	  

      nsel=10 ! e.g. 10 for selection on NSEL best (highest VR) solutions in each perturbation
      write(*,*) 'number of best to select (must be <= numsol/2)= :'
c                ! we select nsel solutions of the highest VR
c                ! ANOTHER alternative is to select e.g. all from 0.9 VRopt to VRoptVR 	  
      read(*,*) nsel 
      if(nsel.gt.numsol/2) nsel=numsol/2
c      if(nsel.eq.0) nsel=1
      write(*,*) 'nsel= ', nsel
      if(nsel.gt.NG2) then
      write(*,*) 'STOP problem DIM nsel'
      STOP
      endif
      write(*,*) 'nsel= ', nsel

      write(*,*)
	  ibest2=0
	  
	  varmaxmax=0.
	  
      if(numper.eq.0) numper=1          ! Special case !!
      do ip = 1,numper ! loop over perturbations
      ig=0	! saving arrays newly created for each perturbations  
	  
	  
      do iss= 1,numpos  !loop over positions (ismin,ismax,isstep) 
      do ii=  1,numtim !loop over time (ii1,ii2,ii3) 
      ig=ig+1         ! counting within one perturbation 
      read(111,*) npert(ig),nsour(ig),ntim(ig),         
     * strg(ig),dipg(ig),rakg(ig),               
     *	 amog(ig),adcg(ig),aclg(ig),avog(ig),varg(ig)
      read(122,*)
     * dum,dum,dum,dum,dum,
     * a1g(ig),a2g(ig),a3g(ig),a4g(ig),a5g(ig),a6g(ig),dum		  
      enddo ! end loop over position
      enddo ! end loop over time

      varmax=maxval (varg) ! Max VR of one perturbation
      call hpsel (nsel,numsol,varg,bb) !! bb contains nsel largest values of varg, bb(1) is the NSEL-th
ccc	  if (nsel.gt.numsol/2.or.nsel.lt.1) pause 'probable misuse of hpsel'
	  varlim=bb(1)
	  varmax2=varmax-0.0001;varmax3=varmax+0.0001;
c      write(*,*) varlim,varmax ! For nsel best solutions, VR is between blim and bmax (= top range)
      if (varmax.gt.varmaxmax) varmaxmax=varmax 
 
c      write(*,*)
	  ibest=0 ! selecting and counting nsel solutions of Top Range in one perturbation
      do i=1,numsol ! loop over solutions of one perturbation, seeking nsel best

        if(varg(i).ge.varlim.and.varg(i).le.varmax) then ! solutions in the top range in one perturbation 

cc    Setting artificial absolute minimum of VR=0.8 for output
c        if(varg(i).ge.varlim.and.varg(i).le.varmax
c     &		.and.varg(i).gt.0.8) then                 


	  ibest=ibest+1
c      write(*,*) ibest,varg(i),npert(i),nsour(i),ntim(i)
c	  write(*,*) a1g(i),a2g(i),a3g(i),a4g(i),a5g(i),a6g(i)
      selamog(ibest)=amog(i)
	  seladcg(ibest)=adcg(i)
	  selaclg(ibest)=aclg(i)
	  selavog(ibest)=avog(i)
	  selvarg(ibest)=varg(i)
	  nselnpert(ibest)=npert(i)
	  nselnsour(ibest)=nsour(i)
	  nselntim(ibest)=ntim(i)
      sela1(ibest)=a1g(i);sela2(ibest)=a2g(i);sela3(ibest)=a3g(i)   ! acka
      sela4(ibest)=a4g(i);sela5(ibest)=a5g(i);sela6(ibest)=a6g(i)
	     endif
         if(varg(i).ge.varmax2.and.varg(i).le.varmax3) then
		 ibest2=ibest2+1
	     write(135,'(1x,3i5,2f8.0,6e15.5,10x,1f12.4)')               !output of the best solution
     *npert(i),nsour(i),ntim(i),aclg(i),avog(i),                     ! into CLVDetcPOST_BEST  
     *a1g(i),a2g(i),a3g(i),a4g(i),a5g(i),a6g(i),varg(i)	 
         endif  		 
      enddo ! end over Top Range within a perturbation
	  nbest=ibest     ! number of solutions in one perturbation 
c	  nbestall=nbestall+nbest 
   
	  
c     Output of Top Range in every perturbation into CLVDetcPOST.dat
	  dum2=0.
      do j=1,nbest	  
      write(133,'(1x,3i5,2f8.0,6e15.5,10x,1f12.4)')
     *nselnpert(j),nselnsour(j),nselntim(j),selaclg(j),selavog(j),
     *sela1(j),sela2(j),sela3(j),sela4(j),sela5(j),sela6(j),selvarg(j)	 
      
	  xmclvd=xmclvd+selaclg(j)
	  xmvol=xmvol+selavog(j)
	  xmhrv1=xmhrv1+sela1(j);xmhrv2=xmhrv2+sela2(j)
	  xmhrv3=xmhrv3+sela3(j);xmhrv4=xmhrv4+sela4(j)
	  xmhrv5=xmhrv5+sela5(j);xmhrv6=xmhrv6+sela6(j)
      enddo
	  
      enddo ! end of loop over perturbations      
c      write(*,*) 'Max VR over all perturbations= ', varmaxmax 
 
      write(*,*) 'No. of solutions in CLVDetcPOST_BEST.dat= ',ibest2
      write(*,*) 'number of calculated times= ', numtim
c	  xmclvd=xmclvd/float(nbestall)
c	  xmvol=xmvol/float(nbestall)
c	  xmhrv1=xmhrv1/float(nbestall)
c      xmhrv2=xmhrv2/float(nbestall)
c      xmhrv3=xmhrv3/float(nbestall)
c      xmhrv4=xmhrv4/float(nbestall)
c      xmhrv5=xmhrv5/float(nbestall)
c      xmhrv6=xmhrv6/float(nbestall)
	  
c      write(137,'(1x,2f8.1,6e15.5)') xmclvd,xmvol
c     *     xmhrv1,xmhrv2,xmhrv3,xmhrv4,xmhrv5,xmhrv6	  
	  
 
	  

	  
 888  stop
      end
      include "HPSEL.inc"
      include "SORT.inc"