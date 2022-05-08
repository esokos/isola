      character*4 blank
      blank='   '
c     open(100,file='inp.dat')
      open(200,file='nodal.dat')

      pi=3.141592
      twopi=2.*pi
      rad=pi/180.
      rad2=pi/180.
      cx=10.  ! stred kruznice, x sour
      cy=20.  !    dtto         y
      cx2=10.  ! stred kruznice, x sour
      cy2=20.  !    dtto         y
      rmax=5. ! polomer kruznice
      rmax2=5. ! polomer kruznice
      hite=0. ! nema smysl
      wt=1.   ! nema smysl
c     blank=' '

      write(*,*) 'strike,dip,rake (deg)=?'
      read(*,*) stra,dipa,raka

c  1  read(100,*,end=99) dum,dum,   stra,dipa,raka

c     kresli kruznici
      call circle(2.*rmax,twopi,cx,cy)

c     kresli jednu nodalku write(200 ;
      call plotpl(cx,cy,dipa,pi,rad,rmax,stra)
c     write(*,*) stra,dipa,raka

c     pocita druhou nodalku
      call auxpln(stra,dipa,raka,strb,dipb,rakb)
c     write(*,*) strb,dipb,rakb

c     kresli druhou nodalku
      call plotpl(cx,cy,dipb,pi,rad,rmax,strb)

c     pocita osy P a T
      call tandp(ainp,aint,azp,azt,dipa,dipb,stra,strb,raka,
     & rakb,pi,rad2)

      azp=azp-270.     !!!!! moje
      azt=azt-270.     !!!!! moje a taky comment SAVE in GEOCEN for Fortr90
      if(azp.lt.0.) azp=360.+azp  !!!!!!
      if(azt.lt.0.) azt=360.+azt  !!!!!!

      write(*,*) stra,dipa,raka
      write(*,*) strb,dipb,rakb
c      write(*,*) 'P-axis: azimuth and plunge:',azp,ainp ! wrong plunge
c      write(*,*) 'T-axis: azimuth and plunge:',azt,aint ! wrong plunge
      write(*,*) 'P-axis: azimuth and plunge:',azp,90.- ainp
      write(*,*) 'T-axis: azimuth and plunge:',azt,90.- aint
	write(*,*) 'plunge = angle between axis and horizontal plane'

c  plunge cannot be corrected in ainp, aint but only in write
c  because old ('wrong') ainp, aint is needed in PLTSYM !!!!!

c     kresli osy P a T
      CALL PLTSYM (AINP, AZP,CX2,CY2, HITE,'    ', PI,RAD2,RMAX2, 'P',
     & WT)
      CALL PLTSYM (AINT, AZT,CX2,CY2, HITE,'    ', PI,RAD2,RMAX2, 'T',
     & WT)

c     goto 1
   99 continue
C
      stop
      end

      SUBROUTINE AUXPLN (DD1, DA1, SA1, DD2, DA2, SA2)
C
C    CALCULATE THE AUXILLIARY PLANE OF A DOUBLE COUPLE FAULT PLANE SOLUTION, GIVEN THE PRINCIPLE PLANE.
C
C    WRITTEN BY PAUL REASENBERG, JUNE, 1984, FROM CLASS NOTES BY DAVE BOORE, (BOTH AT THE U.S.G.S., MENLO PARK.)
C    ANGLE VARIABLES PHI, DEL AND LAM ARE AS DEFINED IN AKI AND RICHARDS, (1980), P.114.
C
      REAL              DA1
*       ! (INPUT)  DIP ANGLE IN DEGREES OF PRICIPLE PLANE
      REAL              DD1
*       ! (INPUT)  DIP DIRECTIONS IN DEGREES OF PRICIPLE PLANE
      REAL              SA1
*       ! (INPUT)  SLIP ANGLE IN DEGREES OF PRICIPLE PLANE
      REAL              DA2
*       ! (OUTPUT)  DIP ANGLE IN DEGREES OF AUXILLIARY PLANE
      REAL              DD2
*       ! (OUTPUT)  DIP DIRECTIONS IN DEGREES OF AUXILLIARY PLANE
      REAL              SA2
*       ! (OUTPUT)  SLIP ANGLE IN DEGREES OF AUXILLIARY PLANE
C

      DOUBLE PRECISION  BOT
*       ! SCRATCH VARIABLE
      DOUBLE PRECISION  DEL1
*       ! DIP ANGLE OF PRINCIPAL PLANE IN RADIANS
      LOGICAL           FIRST
*       ! TEST: TRUE IF FIRST TIME INTO ROUTINE
      DOUBLE PRECISION  PHI1
*       ! FAULT PLANE STRIKE OF PRINCIPAL PLANE
      DOUBLE PRECISION  PHI2
*       ! STRIKE OF AUXILLIARY PLANE IN RADIANS
      DOUBLE PRECISION  RAD
*       ! CONVERSION FACTOR FROM DEGREES TO RADIAN
      DOUBLE PRECISION  SGN
*       ! SAVES PRINCIPAL PLANE SLIP ANGLE FOR ASSIGNING PROPER SIGN TO AUXILLIARY
      DOUBLE PRECISION  TOP
*       ! SCRATCH VARIABLE
      DOUBLE PRECISION  XLAM1
*       ! SLIP ANGLE OF PRINCIPAL PLANE IN RADIANS
      DOUBLE PRECISION  XLAM2
*       ! SLIP ANGLE OF AUXILLIARY PLANE
C
      SAVE FIRST, RAD
      DATA FIRST /.TRUE./
C
      IF (FIRST) THEN
        FIRST = .FALSE.
        RAD = DATAN(1.0D0)/45.0D0
      END IF
C
      PHI1 = DD1 - 90.0D0
      IF (PHI1 .LT. 0.0D0) PHI1 = PHI1 + 360.0D0
      PHI1 = PHI1*RAD
      DEL1 = DA1*RAD
      SGN = SA1
      XLAM1 = SA1*RAD
C
      TOP = DCOS(XLAM1)*DSIN(PHI1) - DCOS(DEL1)*DSIN(XLAM1)*DCOS(PHI1)
      BOT = DCOS(XLAM1)*DCOS(PHI1) + DCOS(DEL1)*DSIN(XLAM1)*DSIN(PHI1)
      DD2 = DATAN2(TOP, BOT)/RAD
      PHI2 = (DD2 - 90.0D0)*RAD
      IF (SA1 .LT. 0.0D0) DD2 = DD2 - 180.0D0
      IF (DD2 .LT. 0.0D0) DD2 = DD2 + 360.0D0
      IF (DD2. GT. 360.0D0) DD2 = DD2 - 360.0D0
C
      DA2 = DACOS(DSIN(DABS(XLAM1))*DSIN(DEL1))/RAD
      XLAM2 = -DCOS(PHI2)*DSIN(DEL1)*DSIN(PHI1) +
     & DSIN(PHI2)*DSIN(DEL1)*DCOS(PHI1)
C
C MACHINE ACCURACY PROBLEM
C
      IF (DABS(XLAM2) .GT. 1.0D0) THEN
        XLAM2 = DSIGN(1.0D0, XLAM2)
      END IF
      XLAM2 = DSIGN(DACOS(XLAM2), SGN)
      SA2 = XLAM2/RAD
C
      RETURN
      END


      SUBROUTINE TANDP (AINP, AINT, AZP, AZT, DA1, DA2, DD1, DD2, SA1,
     & SA2, PI, RAD)
C
C     GIVEN TWO PLANES COMPUTE AZ AND ANGLE OF INCIDENCE OF P & T AXES
C
      REAL              AINP
*       ! ANGLE OF INCIDENCE OF P AXIS
      REAL              AINT
*       ! ANGLE OF INCIDENCE OF T AXIS
      REAL              AZP
*       ! AZIMUTH OF P AXIS
      REAL              AZT
*       ! AZIMUTH OF T AXIS
      REAL              DA1
*       ! DIP ANGLE OF PRINICIPLE PLANE
      REAL              DA2
*       ! DIP ANGLE OF AUXILLIARY PLANE
      REAL              DD1
*       ! DIP DIRECTION OF PRINCIPLE PLANE
      REAL              DD2
*       ! DIP DIRECTION OF AUXILLIARY PLANE
      REAL              SA1
*       ! RAKE OF PRINCIPAL PLANE
      REAL              SA2
*       ! RAKE OF AUXILLIARY PLANE
      REAL              PI
*       ! PI
      REAL              RAD
*       ! PI/180
C
      REAL              AIN1
*       ! ANGLE OF INCIDENCE OF P/T AXIS
      REAL              AIN2
*       ! ANGLE OF INCIDENCE OF T/P AXIS
      REAL              ALAT1
*       ! DIP ANGLE IN RADIANS OF PRINCIPLE PLANE MEASURED FROM VERTICAL
      REAL              ALAT2
*       ! DIP ANGLE IN RADIANS OF AUXILLIARY PLANE MEASURED FROM VERTICAL
      REAL              ALON1
*       ! DD1 IN RADIANS
      REAL              ALON2
*       ! DD2 IN RADIANS
      REAL              AZIMTH
*       ! AZIMUTH IN RADIANS OF POLE ??
      REAL              AZ0
*       ! AZIMUTH FROM POLE OF AUXILLIARY PLANE TO POLE OF PRINCIPLE ??
      REAL              AZ1
*       ! AZIMUTH OF P/T AXIS
      REAL              AZ2
*       ! AZIMUTH OF T/P AXIS
      REAL              BAZM
*       ! NOT USED
      REAL              DELTA
*       ! NOT USED
      REAL              PLUNGE
*       ! PLUNGE IN RADIANS OF POLE ??
      REAL              SHIFT
*       ! AZIMUTHAL SHIFT FROM POLE OF PLANE TO P TO T AXIS (= 45 DEGREES)??
      REAL              XPOS
*       ! NOT USED
      REAL              YPOS
*       ! NOT USED
C
      PARAMETER (SHIFT = 0.7853981)
C
      ALAT1 = (90. - DA1)*RAD
      ALON1 = DD1*RAD
      ALAT2 = (90. - DA2)*RAD
      ALON2 = DD2*RAD
      CALL REFPT (ALAT2, ALON2)
      CALL DELAZ (ALAT1, ALON1, DELTA, AZ0, BAZM, XPOS, YPOS)
      CALL BACK (SHIFT, AZ0, PLUNGE, AZIMTH)
      IF (ABS(AZIMTH) .GT. PI) AZIMTH = AZIMTH - SIGN(2.0*PI, AZIMTH)
      AZ1 = AZIMTH/RAD
      AIN1 = PLUNGE/RAD + 90.
      AZ0 = AZ0 + PI
      CALL BACK (SHIFT, AZ0, PLUNGE, AZIMTH)
      IF (ABS(AZIMTH) .GT. PI) AZIMTH = AZIMTH - SIGN(2.0*PI, AZIMTH)
      AZ2 = AZIMTH/RAD
      AIN2 = PLUNGE/RAD + 90.
      IF (SA1 .GE. 0.) THEN
        AINP = AIN2
	AINT = AIN1
	AZP = AZ2
	AZT = AZ1
      ELSE
        AINP = AIN1
	AINT = AIN2
	AZP = AZ1
	AZT = AZ2
      END IF	
C
C MAP AXES TO LOWER HEMISPHERE
C
 	IF (AINP .GT. 90.) THEN
 	  AINP = 180. - AINP
 	  AZP = 180. + AZP
 	END IF
 	IF (AINT .GT. 90.) THEN
 	  AINT = 180. - AINT
 	  AZT = 180. + AZT
 	END IF
 	IF (AZP .LT. 0.) AZP = AZP + 360.
 	IF (AZT .LT. 0.) AZT = AZT + 360.
      RETURN
      END


      SUBROUTINE CIRCLE (SIZE, TWOPI, X0, Y0)
C
C PLOT A CIRCLE
C
      REAL              SIZE
*       ! SIZE OF CIRCLE     =    DIAMETER  !!! not radius !!!
      REAL              TWOPI
*       ! TWO*PI
      REAL              X0
*       ! X POSTION OF CENTER
      REAL              Y0
*       ! Y POSTION OF CENTER
C
      REAL              ANGLE
*       ! ANGLE
      INTEGER           J
*       ! LOOP INDEX
      INTEGER           N
*       ! NUMBER OF POINTS OF WHICH CIRCLE COMPOSED
      REAL              SIZE2
*       ! SCRATCH VARIABLE
      REAL              X
*       ! X PLOT POSTION
      REAL              Y
*       ! Y PLOT POSTION
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

      SUBROUTINE PLOTPL (CX, CY, DPIDG, PI, RAD, RMAX, STRKDG)
C
C PLOTS FAULT PLANE ON LOWER HEMISPHERE STEREO NET
C
      REAL              CX
*       ! X POSITION OF CIRCLE CENTER
      REAL              CY
*       ! Y POSITION OF CIRCLE CENTER
      REAL              DPIDG
*       ! DIP ANGLE IN DEGREES
      REAL              PI
*       ! PI
      REAL              RAD
*       ! PI/180
      REAL              RMAX
*       ! RADIUS OF CIRCLE
      REAL              STRKDG
*       ! STRIKE ANGLE IN DEGREES

      REAL              ANG
*       ! ANGLE IN RADIANS
      REAL              AINP(91)
*       ! ANGLE OF INCIDENCE IN RADIANS
      REAL              ARG
*       ! DUMMY ARGUMENT
      REAL              AZ
*       ! AZIMUTH
      REAL              CON
*       ! RADIUS COEFFICIENT
      REAL              DIPRD
*       ! DIP ANGLE IN RADIANS
      INTEGER           I
*       ! LOOP INDEX
      INTEGER           MI
*       ! SCRATCH INDEX
      REAL              RADIUS
*       ! RADIUS
      REAL              SAZ(91)
*       ! AZIMUTH IN RADIANS
      REAL              STRKRD
*       ! STRIKE IN RADIANS
      REAL              TAZ
*       ! SCRATCH VARIABLE
      REAL              TPD
*       ! SCRATCH VARIABLE
      REAL              X
*       ! X PLOT POSITION
      REAL              Y
*       ! Y PLOT POSITION
C
      STRKRD = STRKDG*RAD
      DIPRD = DPIDG*RAD
      TPD = TAN(PI*.5 - DIPRD)**2
C
C CASE OF VERTICAL PLANE
C
      IF (DPIDG .EQ. 90.0) THEN
        X = RMAX*SIN(STRKRD) + CX
        Y = RMAX*COS(STRKRD) + CY
c       CALL PLOT (X, Y, 3)
        write(200,*) x,y
        X = RMAX*SIN(STRKRD + PI) + CX
        Y = RMAX*COS(STRKRD + PI) + CY
c       CALL PLOT (X, Y, 2)
        write(200,*) x,y
        write(200,*) '*'
        RETURN
      END IF
C
C COMPUTE ANGLE OF INCIDENCE, AZIMUTH
C
      DO 10 I = 1, 90
        ANG = FLOAT(I - 1)*RAD
        ARG = SQRT((COS(DIPRD)**2)*(SIN(ANG)**2))/COS(ANG)
        SAZ(I) = ATAN(ARG)
        TAZ = TAN(SAZ(I))**2
        ARG = SQRT(TPD + TPD*TAZ + TAZ)
        AINP(I) = ACOS(TAN(SAZ(I))/ARG)
  10  CONTINUE
      SAZ(91) = 90.*RAD
      AINP(91) = PI*.5 - DIPRD
C
C PLOT PLANE
C
      CON = RMAX*SQRT(2.)
      DO 20 I = 1, 180
        IF (I .LE. 91) THEN
          MI = I
          AZ = SAZ(I) + STRKRD
        ELSE
          MI = 181 - I
          AZ = PI - SAZ(MI) + STRKRD
        END IF
        RADIUS = CON*SIN(AINP(MI)*0.5)
        X = RADIUS*SIN(AZ) + CX
        Y = RADIUS*COS(AZ) + CY
        IF (I .EQ. 1) THEN
c         CALL PLOT (X, Y, 3)
          write(200,*) x,y
        ELSE
c         CALL PLOT (X, Y, 2)
          write(200,*) x,y
        END IF
20    CONTINUE
C
      write(200,*) '*'
      RETURN
      END

      SUBROUTINE PLTSYM (AIN, AZ, CX, CY, HITE, NAME, PI, RAD, RMAX,
     & SYM, WT)
C
C    PLOT EITHER FIRST MOTION SYMBOL (C,D,+,-) WITH STATION NAME NEXT TO SYMBOL, OR STRESS AXES SYMBOL (P & T)
C
      REAL              AIN
*       ! ANGLE OF INCIDENCE OF SYMBOL
      REAL              AZ
*       ! AZIMUTH OF SYMBOL
      REAL              CX
*       ! X POSITION OF CIRCLE CENTER
      REAL              CY
*       ! Y POSITION OF CIRCLE CENTER
      REAL              HITE
*       ! HEIGHT OF SYMBOL
      CHARACTER*4       NAME
*       ! STRING TO BE PLOTTED TO RIGHT OF SYMBOL
      REAL              PI
*       ! PI
      REAL              RAD
*       ! PI/180
      REAL              RMAX
*       ! RADIUS OF CIRCLE
      CHARACTER*1       SYM
*       ! PLOT SYMBOL
      REAL              WT
*       ! WEIGHT ASSIGNED TO PICK QUALITY IN PROGRAM FPFIT

      REAL              AINR
*       ! AIN IN RADIANS
      REAL              ANG
*       ! PLOT ANGLE OF SYMBOL
      REAL              AZR
*       ! AZ IN RADIANS
      REAL              CON
*       ! RMAX * SQRT(2.0)
      LOGICAL           FIRST
*       ! FLAG FIRST TIME INTO ROUTINE
      REAL              R
*       ! DISTANCE FROM CX, CY TO PLOT POSITION
      REAL              SIZE
*       ! PLOT SYMBOL SIZE SCALED BY WT
      REAL              SYMSIZ
*       ! MAXIMUM SYMBOL SIZE
      REAL              X
*       ! X POSITION OF SYMBOL
      REAL              Y
*       ! Y POSITION OF SYMBOL
C
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
      IF ((SYM .EQ. 'P') .OR. (SYM .EQ. 'T')) THEN
        X = X - .286*HITE
        Y = Y - .5*HITE
*A      CALL SYMBOL (X, Y, HITE, %REF(SYM), ANG, 1)
c       CALL SYMBOL (X, Y, HITE, SYM, ANG, 1)
        write(200,*) x,y,' ',sym
        write(200,*) '*'
      ELSE
C
C FIRST MOTION SYMBOL
C
        SIZE = SYMSIZ*WT
        IF (AIN .GT. 90.) THEN
*A        CALL NEWPEN (4)
c         CALL NEWPEN (2)
        ELSE
c         CALL NEWPEN (1)
        END IF
        IF (SYM .EQ. 'C') THEN
c         CALL PLUS (SIZE, X, Y)
        ELSE
c         CALL CIRCLE (SIZE, 2.0*PI, X, Y)
        END IF
c       CALL NEWPEN (1)
C
C PLOT STATION NAME
C
*A      IF (NAME .NE. '    ') CALL SYMBOL (X + SIZE/2., Y, SIZE/2.,
*A   & %REF(NAME), 0., 4)
c       IF (NAME .NE. '    ') CALL SYMBOL (X + SIZE/2., Y, SIZE/2.,
c    & NAME, 0., 4)
      END IF
C
      RETURN
      END

      SUBROUTINE PLUS (SIZE, X0, Y0)
C
C PLOT A "PLUS" SIGN CENTERED AT X0, Y0
C
      REAL              SIZE
*       ! SIZE OF TRIANGE
      REAL              X0
*       ! X POSTION OF CENTER
      REAL              Y0
*       ! Y POSTION OF CENTER
C
      REAL              X
*       ! X PLOT POSTION
      REAL              Y
*       ! Y PLOT POSTION
C
C MOVE TO TOP
C
      Y = Y0 + SIZE/2.
c     CALL PLOT (X0, Y, 3)
C
C DRAW TO BOTTOM
C
      Y = Y - SIZE
c     CALL PLOT (X0, Y, 2)
C
C MOVE TO RIGHT
C
      X = X0 + SIZE/2.
c     CALL PLOT (X, Y0, 3)
C
C DRAW TO LEFT
C
      X = X - SIZE
c     CALL PLOT (X, Y0, 2)
C
      RETURN
      END

      SUBROUTINE GEOCEN
C
C      GEOCEN - CALCULATE GEOCENTRIC POSTITIONS, DISTANCES, AND AZIMUTHS (BRUCE JULIAN, USGS MENLO PARK, CA)
C
C      THE GEOCENTRIC DISTANCE DELTA AND AZIMUTH AZ0 FROM POINT (LAT0, LON0) TO POINT (LAT1, LON1) ARE CALCULTED FROM
C            COS(DELTA) = COS(LAT0')*COS(LAT1')*COS(LON1 - LON0) + SIN(LAT0')*SIN(LAT1')
C            SIN(DELTA) = SQRT(A*A + B*B)
C            TAN(AZ0) = A/B
C
C      WHERE
C            A = COS(LAT1')*SIN(LON1-LON0)
C            B = COS(LATN0')*SIN(LAT1') - SIN(LAT0')*COS(LAT1')*COS(LON1 - LON0)
C            LAT0', LAT1' = GEOCENTRIC LATITUDES OF POINTS
C            LON0, LON1 = LONGITUDES OF POINTS
C
C      THE GEOCENTRIC LATITUDE LAT' IS GOTTEN FROM THE GEOGRAPHIC LATITUDE LAT BY TAN(LAT') = (1 - ALPHA)*(1 - ALPHA)*TAN(LAT),
C      WHERE ALPHA IS THE FLATTENING OF THE ELLIPSOID.  SEE FUNCTION GGTOGC FOR CONVERSION.
C      THE BACK AZIMUTH IS CALCULATED BY THE SAME FORMULAS WITH (LAT0', LON0) AND (LAT1', LON1) INTERCHANGED.
C      AZIMUTH IS MEASURED CLOCKWISE FROM NORTH THRU EAST.
C
      REAL              R, THETA
*       ! RADIUS, AZIMUTH IN POLAR COORDINATES
      REAL              AZ0
*       ! AZIMUTH FROM REFERENCE POINT TO SECONDARY POINT IN RADIANS
      REAL              AZ1
*       ! AZIMUTH FROM SECONDARY POINT TO REFERENCE POINT IN RADIANS
      REAL              CDELT
*       ! SINE OF DELTA TO SECONDARY POINT
      REAL              CDLON
*       ! COSINE OF DIFFERENCE OF SECONDARY POINT, REFERENCE LONGITUDE
      REAL              COLAT
*       ! AVERAGE COLATITUDE OF STATION
      REAL              CT0
*       ! SINE OF REFERENCE POINT LATITUDE
      REAL              CT1
*       ! SINE OF SECONDARY POINT LATITUDE
      REAL              CZ0
*       ! COSINE OF AZIMUTH TO SECONDARY POINT
      REAL              DELTA
*       ! GEOCENTRIC DISTANCE IN DEGREES
      REAL              DLON
*       ! AZIMUTH IN POLAR COORDINATES TO SECONDARY POINT ?
      REAL              ERAD
*       ! EQUATORIAL RADIUS (CHOVITZ, 1981, EOS, 62, 65-67)
      REAL              FLAT
*       ! EARTH FLATTENING CONSTANT (CHOVITZ, 1981, EOS, 62, 65-67)
      REAL              LAMBDA
*       ! DUMMY VARIABLE
      REAL              LAT
*       ! LATITUDE IN RADIANS
      REAL              LON
*       ! LONGITUDE IN RADIANS
      REAL              OLAT
*       ! ORIGIN LATITUDE IN RADIANS
      REAL              OLON
*       ! ORIGIN LONGITUDE IN RADIANS
      REAL              PHI0
*       ! REFERENCE SECONDARY POINT LONGITUDE
      REAL              PI
*       ! 3.14159...
      REAL              RADIUS
*       ! EARTH RADIUS AT COLAT
      REAL              SDELT
*       ! COSINE OF DELTA TO SECONDARY POINT
      REAL              SDLON
*       ! SINE OF DIFFERENCE OF SECONDARY POINT, REFERENCE LONGITUDE
      REAL              ST0
*       ! COSINE OF REFERENCE POINT LATITUDE
      REAL              ST1
*       ! COSINE OF SECONDARY POINT LATITUDE
      REAL              TWOPI
*       ! 2*PI
      REAL              X
*       ! EAST-WEST DISTANCE (KM)
      REAL              Y
*       ! NORTH-SOUTH DISTANCE (KM)
C
c     SAVE ST0, CT0, PHI0, OLAT  !!!!!!!!!!!!!!!moje c
      PARAMETER (PI = 3.1415926535897, TWOPI = 2.*PI)
      PARAMETER (FLAT = 1./298.257, ERAD = 6378.137)
C
C	SINCE THIS IS NOT A REAL EARTH PROBLEM, SET FLATTENING TO ZERO
C      PARAMETER (LAMBDA = FLAT*(2. - FLAT)/(1. - FLAT)**2)
C
      PARAMETER (LAMBDA = 0.)
C
C REFPT - STORE THE GEOCENTRIC COORDINATES OF THE REFEERNCE POINT
C
      ENTRY REFPT(OLAT,OLON)
C
      ST0 = COS(OLAT)
      CT0 = SIN(OLAT)
      PHI0 = OLON
      RETURN
C
C DELAZ - CALCULATE THE GEOCENTRIC DISTANCE, AZIMUTHS
C
      ENTRY DELAZ(LAT, LON, DELTA, AZ0, AZ1, X, Y)
C
      CT1 = SIN(LAT)
      ST1 = COS(LAT)
      IF ((CT1 - CT0) .EQ. 0. .AND. (LON - PHI0) .EQ. 0.) THEN
        DELTA = 0.
        AZ0 = 0.
        AZ1 = 0.
      ELSE
        SDLON = SIN(LON - PHI0)
        CDLON = COS(LON - PHI0)
        CDELT = ST0*ST1*CDLON + CT0*CT1
        CALL CVRTOP (ST0*CT1 - ST1*CT0*CDLON, ST1*SDLON, SDELT, AZ0)
        DELTA = ATAN2(SDELT, CDELT)
        CALL CVRTOP (ST1*CT0 - ST0*CT1*CDLON, -SDLON*ST0, SDELT, AZ1)
        IF (AZ0 .LT. 0.0) AZ0 = AZ0 + TWOPI
        IF (AZ1 .LT. 0.0) AZ1 = AZ1 + TWOPI
      END IF
      COLAT = PI/2. - (LAT + OLAT)/2.
      RADIUS = ERAD/SQRT(1.0 + LAMBDA*COS(COLAT)**2)
      Y = RADIUS*DELTA*COS(AZ0)
      X = RADIUS*DELTA*SIN(AZ0)
      RETURN
C
C BACK - CALCULATE GEOCENTRIC COORDINATES OF SECONDARY POINT FROM DELTA, AZ
C
      ENTRY BACK (DELTA, AZ0, LAT, LON)
C
      SDELT = SIN(DELTA)
      CDELT = COS(DELTA)
      CZ0 = COS(AZ0)
      CT1 = ST0*SDELT*CZ0 + CT0*CDELT
      CALL CVRTOP (ST0*CDELT - CT0*SDELT*CZ0, SDELT*SIN(AZ0), ST1, DLON)
      LAT = ATAN2(CT1, ST1)
      LON = PHI0 + DLON
      IF (ABS(LON) .GT. PI) LON = LON - SIGN(TWOPI, LON)
C
      RETURN
      END

      SUBROUTINE CVRTOP(X, Y, R, THETA)
C
C CVRTOP - CONVERT FROM RECTANGULAR TO POLAR COORDINATES (BRUCE JULIAN, USGS MENLO PARK, CA)
C
      REAL              X,Y
*       ! X,Y RECTANGULAR COORDINATES
      REAL              R, THETA
*       ! RADIUS, AZIMUTH IN POLAR COORDINATES
C
      R = SQRT(X*X + Y*Y)
      THETA = ATAN2(Y, X)
      RETURN
      END

