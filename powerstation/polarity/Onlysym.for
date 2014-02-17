      character*4 sta
      character*1 pol
      open(100,file='mypol.dat')
      open(200,file='symbo.dat')

      pi=3.141592
      twopi=2.*pi
      rad2=pi/180.
      cx=10.  ! stred kruznice, x sour
      cy=20.  !    dtto         y
      cx2=10.  ! stred kruznice, x sour
      cy2=20.  !    dtto         y
      rmax=5. ! polomer kruznice
      rmax2=5. ! polomer kruznice
      hite=0. ! nema smysl
      wt=1.   ! nema smysl

c     kresli kruznici
ccc   call circle(2.*rmax,twopi,cx,cy)

      read(100,*)
   1  read(100,*,end=99) sta,azi,ang,pol
c     write(200,*) sta,azi,ang,pol

c     kresli stanice
      CALL PLTSYM (ang,azi,CX2,CY2,HITE,STA,PI,RAD2,RMAX2,pol,
     * WT)
      goto 1

   99 continue
C
      stop
      end


      SUBROUTINE PLTSYM (AIN, AZ, CX, CY, HITE, NAME, PI, RAD, RMAX,
     * SYM, WT)
      CHARACTER*4       NAME
*       ! STRING TO BE PLOTTED TO RIGHT OF SYMBOL
      CHARACTER*1       SYM
      CHARACTER*3      zSYM
*       ! PLOT SYMBOL
      PARAMETER (ANG = 0.0, SYMSIZ = 0.2)
C
      AZR = AZ*RAD
      AINR = AIN*RAD
C
C UPGOING RAYS
C
      IF (AIN .GT. 90.) THEN
        AINR = PI - AINR
        AZR = PI + AZR
      END IF
      CON = RMAX*SQRT(2.0)
      R = CON*SIN(AINR*0.5)
      X = R*SIN(AZR) + CX
      Y = R*COS(AZR) + CY
C
C STRESS AXIS SYMBOL
C
        if(sym.eq.'+') zsym='''+'''
        if(sym.eq.'-') zsym='''-'''
        if(sym.eq.'?') zsym='''?'''
        write(200,'(f6.3,1x,f6.3,1x,a3,1x,a4)') x,y,zsym,name
ccc     write(200,'(f6.3,1x,f6.3,1x,a5,1x,a4)') x,y, sym,name
        write(200,*) '*'
C
      RETURN
      END


      SUBROUTINE CIRCLE (SIZE, TWOPI, X0, Y0)
C
      SIZE2 = SIZE*0.5
C
C COMPUTE OPTIMUM # OF POINTS TO DRAW
C
      N = 20*SQRT(SIZE2*20.)
      IF (N .LT. 10) N = 10
C
C DRAW CIRCLE
C
      X = X0 + SIZE2
c     CALL PLOT (X, Y0, 3)
      write(200,*) x,y0
c     write(200,*) '*'
      DO 10 J = 1, N
        ANGLE = TWOPI*FLOAT(J)/FLOAT(N)
        X = X0 + SIZE2*COS(ANGLE)
        Y = Y0 + SIZE2*SIN(ANGLE)
c       CALL PLOT (X, Y, 2)
      write(200,*) x,y
10    CONTINUE
C
      write(200,*) '*'
      RETURN
      END

