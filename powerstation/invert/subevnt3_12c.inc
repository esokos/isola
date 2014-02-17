       subroutine subevnt3_12c(ampl,w,sx)
c input  w= seimogram pro kazdou posunutou cas.fci = sloupce matice G
c  	   ampl= momentove vahy ('amplitudy')  jednotlivych posunutych seismogramu s jednotkovymi momenty
c output sx= seismogram jako lin kombinacew posunutych cas fci s amplitudami ampl    
 
c      dimension ampl(6)
      
      dimension sx(8192,21,3)
      dimension w(8192,21,3,6)
      dimension ntm(21)
      logical stat(21)
c*******************************
       double precision  ampl(6)
c      dimension ampl(6)
c*******************************

      common /NUMBERS/ nr,ntim,nmom,isubmax,ifirst,istep,ilast,
     *                 ff1(21),ff2(21),ff3(21),ff4(21),dt
      common /ST/ stat,ntm

c
c
c     COMPUTING OPTIMUM SYNT SEISMO  
c

      do itim=1,ntim
       do ir=1,nr
        do icom=1,3
        sx(itim,ir,icom)=0.
        enddo
       enddo
      enddo


c 	shiftbase=	  ! parametr ; vzdalenost mezi trojuhelniky 
C	nshift=ifix(shiftbase/dt) 	 ! vyjadrena v poctu cas. kroku; zna dt?
c   jina moznost je mit casove nebo celocislne posuvy jako pole (indexovane pomoci it) 
c   coz by umoznovalo snadno jejich nerovnomernost
c   mozna to ale neni tak moc dulezite jako moznost mit dva ci vice POLOH zdroju, kazdy z UPLNE jinym zakladnim posunem
c 	shf=shiftopt + float(i)*shiftbase; nshift= ifix(shf/dt)
 	
      do itim=1,ntim
        do ir=1,nr
          do icom=1,3
            do it=1,6 ! 6 posunu; casem mozna -2,+3 nyni cisluje cas fce kazada bude mit svuj posun 
C      itshift=it*nshift
            sx(itim,ir,icom)=sx(itim,ir,icom) +
     *         ampl(it)*w(itim,ir,icom,it) !!!!!KAZDA W (...IT) UZ POSUN MA!
            enddo	! POTREBUJI VUBEC W JAKO POLE PROMENNYCH IT=1,6 ? VZDYT JE TO TOEZ JEN POSUNUTE
          enddo	! JE TO POZUSTATEK KDYZ SE BAZOVE FCE LISILY A;E PROC TO NENECHAT I KDYZ SE TED LISI JEN POSUVEM
        enddo
      enddo


      RETURN
      END
