
      FUNCTION rtbis(func,x1,x2,xacc)
      INTEGER JMAX
      REAL rtbis,x1,x2,xacc,func
      EXTERNAL func
      PARAMETER (JMAX=40)
      INTEGER j
      REAL dx,f,fmid,xmid
      fmid=func(x2)
      f=func(x1)
c      if(f*fmid.ge.0.) pause 'root must be bracketed in rtbis'
      if(f*fmid.ge.0.) write(*,*) 'root to be bracketed'
      if(f*fmid.ge.0.) read *
      if(f.lt.0.)then
        rtbis=x1
        dx=x2-x1
      else
        rtbis=x2
        dx=x1-x2
      endif
      do 11 j=1,JMAX
        dx=dx*.5
        xmid=rtbis+dx
        fmid=func(xmid)
        if(fmid.le.0.)rtbis=xmid
        if(abs(dx).lt.xacc .or. fmid.eq.0.) return
11    continue
c      pause 'too many bisections in rtbis'
      write(*,*)'too many bisections in rtbis'
	  read *
      END