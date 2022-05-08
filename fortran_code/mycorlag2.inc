      subroutine mycorlag2(x,y,n,lag,cc)
c positive lag shifts y to left
c in main we apply this lag to y=synthetics
c https://www.nag.co.uk/numeric/fl/manual/pdf/G13/g13bcf.pdf

      dimension x(n),y(n)
	  xmean=0.
      ymean=0. 	  
      do i=1,n
	  xmean=xmean+x(i)
	  ymean=ymean+y(i)
	  enddo
	  xmean=xmean/float(n)
	  ymean=ymean/float(n)
      xvar=0.
      yvar=0. 	  
      do i=1,n
	  xvar=xvar+(x(i)-xmean)**2.
	  yvar=yvar+(y(i)-ymean)**2.
	  enddo
	  xvar=xvar/float(n)
	  yvar=yvar/float(n)
c	  write(*,*) xvar,yvar

	  xy=0. 	  
      do i=1,n-lag
	  xy=xy+(x(i)-xmean)*(y(i+lag)-ymean)
	  enddo
	  xy=xy/float(n) ! ano ma byt n , nikoli n-lag
      
      if(xvar.gt.0.and.yvar.gt.0.) then 	  
      cc=xy/sqrt(xvar)/sqrt(yvar)
      else
c      	  write(*,*) 'problem division by zero in mycorlag2, STOP'
      cc=0. !   ????????? or STOP
      endif	  
c      cc=xy !!!!!! docasne nahrada aby fungovalo pro ne-normovane obalky (yvar=0)
c                  !!! klidne bych mohl pouzivat jen xy nebot yvar se asi malo meni
c                  !!!  ale radej ipro presnot pouzivam kompletni tvar a aby 
c                  !!!! nehavarovalo na yvar=1e-43 tak v newaspo8 davam AUX multiplication 	  
      return
	  end
	  