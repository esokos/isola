      SUBROUTINE zbrac(func,x1,x2,succes)
      INTEGER NTRY
      REAL x1,x2,func,FACTOR
      EXTERNAL func
      PARAMETER (FACTOR=1.6,NTRY=50)
      INTEGER j
      REAL f1,f2
      LOGICAL succes
c      if(x1.eq.x2)pause 'you have to guess an initial range in zbrac'
      if(x1.eq.x2) write(*,*) 'guess init. range'
      if(x1.eq.x2) read *
      f1=func(x1)
      f2=func(x2)
      succes=.true.
      do 11 j=1,NTRY
        if(f1*f2.lt.0.)return
        if(abs(f1).lt.abs(f2))then
          x1=x1+FACTOR*(x1-x2)
          f1=func(x1)
        else
          x2=x2+FACTOR*(x2-x1)
          f2=func(x2)
        endif
11    continue
      succes=.false.
      return
      END