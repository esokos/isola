C+
	program dsretc
C
C	Based on the Aki & Richards convention, gives all
C	  representations of a focal mechanism for input
C	  Dip, Strike, Rake    or
C	  A and N trend and plunge    or
C	  P and T trend and plunge.
C
C	The code is Fortran 77 for a VAX/VMS system
C	Subroutine specific to this program are
C	  FMREPS,PTTPIN,ANTPIN,DSRIN,AN2MOM,V2TRPL,TRPL2V,AN2DSR
C	21 August 1991:  sun version
C	30 December 1993 Incuded Stuart Sipkin's beachball
C	15 March 2002: Added moment tensor input
C-
	LOGICAL AN,PT,DSR,TRUTH,first,MT
	character*80 getstring,commnt
	REAL*4 MOMTEN(6)
	DIMENSION PTTP(4),ANGS(3),ANGS2(3),ANBTP(6)
C
C	If your compiler complains about form='print', leave it out.
C
	open(unit=2,file='dsretc.lst',status='unknown')
	open(unit=3,file='dsr.dat')

100	continue  !COMMNT = getstring(' Comment')
200	continue  !CALL TIMDAT(2,'dsretc')
c	write(2,'(/,5x,a)') commnt(1:lenc(commnt))
c	WRITE(*,*) 'Can enter P & T or D, S & R or A & N'
	DSR = .FALSE.
	AN = .FALSE.
	PT = .FALSE.
	MT = .false.
c	IF (TRUTH('Dip, Strike and Rake?..[Y]')) THEN
	  DSR = .TRUE.
c	  CALL PRINTX(' Enter Dip, Strike and Rake (degrees)')
       

	  READ(3,*) (ANGS(J),J=1,3)
c	ELSE IF (TRUTH('P and T axes trend and plunge?..[Y]')) THEN
c	  PT = .TRUE.
c	  CALL PRINTX
c     .	  (' Enter trend and plunge for P and T (t,p,t,p)')
c	  READ(*,*) (PTTP(J),J=1,4)
c	else if (truth('Moment-tensor input?...[Y]')) then
c	  MT = .true.
c	ELSE
c	  AN = .TRUE.
c	  CALL PRINTX
c     .	  (' Enter trend and plunge for A and N (t,p,t,p)')
c	  READ(*,*) (ANBTP(J),J=1,4)
c	END IF

c	WRITE(2,'(1H0)')


	CALL FMREPS(ANBTP,ANGS,PTTP,ANGS2,AN,PT,DSR,MT,MOMTEN,2,6)
	first = .true.
	call bball(momten,pttp(1),pttp(2),pttp(3),pttp(4),2,first)
c	IF (.NOT.TRUTH('Run some more?...[Y]')) STOP
c	write(2,'(1H1)')
c        first = .true.
c	IF (TRUTH('Same comment?..[Y]')) GO TO 200
c	GO TO 100


	END


C+
      subroutine bball(g,pazim,pplng,tazim,tplng,unit,first)

c ...... generate printer plot rendition of lower hemisphere
c        equal area projection
C	g has the six elements of the moment tensor, the rest are the
C	  plunge and trends of the P and T axes in degrees. unit is the output
C	  unit.
C	From Stuart Sipkin and Bob Uhrhammer 1993
C-
      dimension g(6)
      integer unit
      character*1 ach(39,72),aplus,aminus,apaxis,ataxis,ablank
      logical first
c
      data aplus,aminus,apaxis,ataxis,ablank /'#','-','P','T',' '/
      data radius /1.41/
c
c ...... construct lower hemisphere fps
c

      Pi=3.14159265

      r0=radius
      x0=r0+0.250
      y0=r0+0.500
      ix0=12.*x0
      iy0=6.5*y0
      do 3 i=1,2*ix0
      do 2 j=1,2*iy0
      dx=real(i-ix0)/12.
      dy=-real(j-iy0)/6.5
      dd=dx*dx+dy*dy
      if(dd.gt.0.) then
        del=sqrt(dd)
      else
        del=0.
      endif
      if((dx.eq.0.).and.(dy.eq.0.)) then
        theta=0.
      else
        xtheta=atan2(dx,dy)
        theta=180.*(xtheta/Pi)
      endif
      if(del.gt.r0) then
        ach(j,i)=ablank
        go to 1
      endif
      if(del.ge.r0) then
        aoi=90.0
      else
        aoi=90.*del/r0
      endif
      if(polar(g,aoi,theta,first).gt.0.) then
        ach(j,i)=aplus
      else
        ach(j,i)=aminus
      endif
    1 continue
    2 continue
    3 continue
c
c ...... add P & T axis
c
      xpazim=Pi*pazim/180.
      ixp=nint(r0*12.*(90.-pplng)*sin(xpazim)/90.+real(ix0))
      iyp=nint(-r0*6.5*(90.-pplng)*cos(xpazim)/90.+real(iy0))

      do 5 i=ixp-1,ixp+1
      do 4 j=iyp-1,iyp+1
      ach(j,i)=ablank
    4 continue
    5 continue

      ach(iyp,ixp)=apaxis

      xtazim=Pi*tazim/180.
      ixt=nint(r0*12.*(90.-tplng)*sin(xtazim)/90.+real(ix0))
      iyt=nint(-r0*6.5*(90.-tplng)*cos(xtazim)/90.+real(iy0))

      do 7 i=ixt-1,ixt+1
      do 6 j=iyt-1,iyt+1
      ach(j,i)=ablank
    6 continue
    7 continue

      ach(iyt,ixt)=ataxis
c
c ...... add fps plot
c
      do i=1,2*iy0-2
      write(unit,'(5x,72a1)') (ach(i,j),j=1,2*ix0)
      end do

      do i=1,2*iy0-2
      write(*,'(5x,72a1)') (ach(i,j),j=1,2*ix0)
      end do

      return
      end


      real*4 function polar(g,aoi,theta,first)
c
c ...... compute first motion polarity as a function of aoi & theta
c        for a moment tensor for a double-couple solution.
C	Conventions differ slightly from Sipkin.  My moment tensor is derived
C	  from the outer product of two vectors and is hence normalized.  The
C	  order is also different from his, apparently.

      dimension g(6)
      real mxx,mxy,mxz,myy,myz,mzz
      logical first

      Pi=3.14159265

      if(first) then
        mxx= g(2)
        mxy=-g(6)
        mxz= g(4)
        myy= g(3)
        myz=-g(5)
        mzz= g(1)
        first = .false.
      endif

        xtheta=Pi*theta/180.
        xaoi=Pi*aoi/180.
	x = cos(xtheta)*sin(xaoi)
	y = sin(xtheta)*sin(xaoi)
	z = cos(xaoi)
c
      polar = x*mxx*x + 2*x*mxy*y + 2*x*mxz*z + 2*y*myz*z +y*myy*y
     1        +z*mzz*z
c
      return
      end


C+
	SUBROUTINE FMREPS(ANBTP,ANGS,PTTP,ANGS2,AN,PT,DSR,MT,MOMTEN,
     .	  LUNIT1,LUNIT2)
C
C	Input: A and N (trned and plunge), or P and T or dip, strike
C	  and rake (A&R convention)
C	Output: the other representations plus the auxiliary plane.
C	PTTP:  4 parameters, trend and plunge for P and T
C	  P trend and plunge, T trend and plunge
C	ANBTP  6 parameters, t and p for A, N and B respectively.
C	ANGS   3 parameters,  dip, strike and rake for first plane
C	ANGS2  3 parameters, dip strike and rake for auxiliary plane
C	AN, PT, DSR are LOGICAL variables which are true if
C	  A and N, P and T or dip-strike-rake are input
C	MOMTEN  6 parameters:  the moment tensor (unit scalar
C	  magnitude) D & W convention
C	Angles come in and go out in degrees.
C	If LUNIT1 and/or LUNIT2 are positive, the representations
C	  are written on those logical unit numbers.
C	22 July 1985:  Added moment tensor output
C	30 October 1992:  Fixed up problem if lunit2=5.
C	7 March 2002:  Added moment-tensor input
C-
	LOGICAL AN,PT,DSR,MT
	REAL*4 MOMTEN(6)
	INTEGER LUNIT1, LUNIT2
	DIMENSION PTTP(4),ANGS(3),ANGS2(3),ANBTP(6)
	RDEG = 45.0/ATAN(1.0)
	PI = 4.0*ATAN(1.0)
	IF (MT) then
	  call mt_in(PTTP,PI)
	  CALL PTTPIN(PTTP,ANGS,ANGS2,ANBTP,MOMTEN,PI)
	else IF (PT) THEN
	  DO 100 J=1,4
100	  PTTP(J) = PTTP(J)/RDEG
	  CALL PTTPIN(PTTP,ANGS,ANGS2,ANBTP,MOMTEN,PI)
	ELSE IF (AN) THEN
	  DO 200 J=1,4
200	  ANBTP(J) = ANBTP(J)/RDEG
	  CALL ANTPIN(ANBTP,ANGS,ANGS2,PTTP,MOMTEN,PI)
	ELSE if (DSR) then
	  DO 300 J=1,3
300	  ANGS(J) = ANGS(J)/RDEG
	  CALL DSRIN(ANGS,ANBTP,ANGS2,PTTP,MOMTEN,PI)
	END IF
	DO 400 I=1,3
	  ANGS(I) = ANGS(I)*RDEG
	  ANGS2(I) = ANGS2(I)*RDEG
	  PTTP(I) = PTTP(I)*RDEG
  	  ANBTP(I) = ANBTP(I)*RDEG
400	CONTINUE
	ANBTP(4) = ANBTP(4)*RDEG
	ANBTP(5) = ANBTP(5)*RDEG
	ANBTP(6) = ANBTP(6)*RDEG
	PTTP(4) = PTTP(4)*RDEG
	IF (LUNIT1 .GT. 0) THEN
c	  WRITE (LUNIT1,1) (ANGS(I),I=1,3)
c	  WRITE(LUNIT1,2)(ANGS2(I),I=1,3),'   Auxiliary Plane'
c	  WRITE (LUNIT1,3) (ANBTP(J),J=1,4)
c	  WRITE(LUNIT1,4) (ANBTP(J),J=5,6)
c	  WRITE(LUNIT1,5) PTTP
c	  WRITE(LUNIT1,6) MOMTEN
	END IF
	IF (LUNIT2 .GT. 0) THEN
	  if (lunit2 .eq. 5) then
c	    WRITE (*,1) (ANGS(I),I=1,3)
c	    WRITE(*,2)(ANGS2(I),I=1,3),'   Auxiliary Plane'
c	    WRITE (*,3) (ANBTP(J),J=1,4)
c	    WRITE(*,4) (ANBTP(J),J=5,6)
c	    WRITE(*,5) PTTP
c	    WRITE(*,6) MOMTEN
	  else
c	    WRITE (LUNIT2,1) (ANGS(I),I=1,3)
c	    WRITE(LUNIT2,2)(ANGS2(I),I=1,3),'   Auxiliary Plane'
c	    WRITE (LUNIT2,3) (ANBTP(J),J=1,4)
c	    WRITE(LUNIT2,4) (ANBTP(J),J=5,6)
c	    WRITE(LUNIT2,5) PTTP
c	    WRITE(LUNIT2,6) MOMTEN
	  end if
	END IF
	RETURN
C
1	FORMAT(5X,'Dip,Strike,Rake ',3F9.2)
2	FORMAT(5X,'Dip,Strike,Rake ',3F9.2,A)
3	FORMAT(5X,'Lower Hem. Trend, Plunge of A,N ',4F9.2)
4	FORMAT(5X,'Lower Hem. Trend & Plunge of B ',2F9.2)
5	FORMAT(5X,'Lower Hem. Trend, Plunge of P,T ',4F9.2)
6	FORMAT(5X,'MRR =',F5.2,'  MTT =',F5.2,'  MPP =',F5.2,
     .  '  MRT =',F5.2,'  MRP =',F5.2,'  MTP =',F5.2)
	END


	SUBROUTINE PRINTX(LINE)
C+
c	SUBROUTINE PRINTX(LINE)
C  OUTPUTS A MESSAGE TO THE TERMINAL
C  PRINTX STARTS WITH A LINE FEED BUT DOES NOT END WITH A CARRIAGE RETURN
C  THE PRINT HEAD REMAINS AT THE END OF THE MESSAGE
C
C  IF THE MESSAGE LENGTH IS LESS THAN 40,
C	DOTS ARE INSERTED UP TO COL. 39
C	AND A COLON IS PUT IN COL. 40.
C
C  USE FOR CONVERSATIONAL INTERACTION
C			Alan Linde ... April 1980.
C	10 Sugust 1985:  Corrected a minor error for  strings > 40 bytes
C	20 June 1986:  Made it compatible with Fortran 77
C-
	character*(*) line
	CHARACTER*60 BUF
	CHARACTER*2 COLON
	CHARACTER*1 DOT,DELIM
	DATA DELIM/'$'/,DOT/'.'/,COLON/': '/
	KK = lenc(LINE)	!  length minus right-hand blanks
	  IF (LINE(KK:KK) .EQ. DELIM) KK = KK - 1
	  IF (KK .GT. 58) KK = 59
	BUF(1:KK) = LINE(1:KK)
	IF (KK .LT. 49) THEN
	  DO J=KK+1,49
	    BUF(J:J) = DOT
	  END DO
	  KK = 49
	END IF
	BUF(KK:KK+1) = COLON
	KK = KK + 2
	WRITE(*,'(1x,A,$)') BUF(1:KK)
	RETURN
	END


	function lenc(string)
C+
C	function lenc(string)
C
C	Returns length of character variable STRING excluding right-hand
C	  most blanks or nulls
C-
	character*(*) string
	length = len(string)	! total length
	if (length .eq. 0) then
	  lenc = 0
	  return
	end if
	if(ichar(string(length:length)).eq.0)string(length:length) = ' '
	do j=length,1,-1
	  lenc = j
	  if (string(j:j).ne.' ' .and. ichar(string(j:j)).ne.0) return
	end do
	lenc = 0
	return
	end


C+


C+
	SUBROUTINE IYESNO(MSG,IANS)
C
C
C     PURPOSE:
C	     THIS LITTLE SUBROUTINE ASKS A QUESTION AND RETURNS A
C	     RESPONSE TO THAT QUESTION. THE ANSWER TO THE QUESTION
C	     MUST BE EITHER 'Y' FOR YES, 'N' FOR NO, OR NOTHING
C	     (i.e. simply hitting carrage return) FOR THE DEFAULT
C	     REPONSE TO THE QUESTION.
C
C     ON INPUT:
C	    MSG = BYTE STRING CONTAINING THE QUESTION
C
C     ON OUTPUT:
C	    IANS = THE LOGICAL REPONSE TO THE QUESTION (1 or 0)
C     EXTRA FEATURES:
C	    DEFAULT SITUATION IS:
C	    IF LAST 3 CHARACTERS IN 'MSG' ARE
C	  	     [Y]  OR  [N]
C	    THEN 'IANS' = 1   OR   0
C
C	    IF LAST 3 CHARACTERS ARE NOT ONE OF ABOVE PAIRS
C	    THEN 'IANS' = 0
C	    (i.e. default for no supplied default is N)
C	30 JULY 1989:  IF ENTERED CHARACTER IS A BLANK OR A TAB,
C	    TREATS AS A NULL ENTRY.
C       27 July 1993: Did input read through cstring so can have
C         comment lines
C-
	CHARACTER*1 DELIM/'$'/,CHARIN,BLANK/' '/
	CHARACTER*3 TEST,UCY,LCY
	character*80 string_in
	CHARACTER*(*) MSG
	DATA UCY/'[Y]'/,LCY/'[y]'/
	KK = LEN(MSG)
	IF (MSG(KK:KK) .EQ. DELIM) KK = KK - 1
	TEST = MSG(KK-2:KK)
	CALL PRINTX(MSG)
	call cstring(string_in,nchar)
	IF ((NCHAR.GT.0) .AND. (string_in(1:1).EQ.BLANK))
     1    NCHAR = 0
	IF (NCHAR .EQ. 0) THEN
	  IF ((TEST .EQ. UCY) .OR. (TEST .EQ. LCY)) THEN
	    IANS = 1
	  ELSE
	    IANS = 0
	  END IF
	ELSE
	  charin = string_in(1:1)
	  IF (CHARIN .EQ. UCY(2:2) .OR. CHARIN .EQ. LCY(2:2)) THEN
	    IANS = 1
	  ELSE
	    IANS = 0
	  END IF
	END IF
	RETURN
	END


C+
	subroutine cstring(string,nstring)
C
C	Input a character string with a read(*,'(A)') string
C	If first two characters are /* it will read the next entry
C	Tab is a delimiter.
C	Returns string and nstring, number of characters to tab.
C	string stars with first non-blank character.
C       25 May 2001.  Took out parameter statement for tab.
C-
	logical more
	CHARACTER*1 TAB
	CHARACTER*(*) string
C
	tab = char(9)
	more = .true.
	do while (more)
	  read(*,'(A)') string
	  nstring = lenc(string)
	  more = (nstring.ge.2 .and. string(1:2).eq.'/*')
	end do
	IF (nstring .GT. 0) THEN
	  NTAB = INDEX(string(1:nstring),TAB)
	  IF (NTAB .GT. 0) nstring = NTAB - 1
	end if
	return
	end


C+
	SUBROUTINE DSRIN (ANGS,ANBTP,ANGS2,PTTP,MOMTEN,PI)
C
C	Calculates other representations of fault planes with
C		dip, strike and rake (A&R convinention) input.  All
C		angles are in radians.
C	22 July 1985:  Added moment tensor output (D&W convention)
C	               normalized to unit scalar moment
C-
	REAL N(3), MOMTEN(6)
	DIMENSION PTTP(4),ANGS(3),ANGS2(3),ANBTP(6),P(3),T(3),A(3),B(3)
	DATA SR2/0.707107/
	RAKE=ANGS(3)
	STR = ANGS(2)
	DIP = ANGS(1)
	A(1) = COS(RAKE)*COS(STR) + SIN(RAKE)*COS(DIP)*SIN(STR)
	A(2) = COS(RAKE)*SIN(STR) - SIN(RAKE)*COS(DIP)*COS(STR)
	A(3) = -SIN(RAKE)*SIN(DIP)
	N(1) = -SIN(STR)*SIN(DIP)
	N(2) = COS(STR)*SIN(DIP)
	N(3) = -COS(DIP)
	CALL V2TRPL(A,ANBTP(1),PI)
	CALL V2TRPL(N,ANBTP(3),PI)
	DO 100 J=1,3
	T(J) = SR2*(A(J) + N(J))
100	P(J) = SR2*(A(J) - N(J))
	B(1) = P(2)*T(3) - P(3)*T(2)
	B(2) = P(3)*T(1) - P(1)*T(3)
	B(3) = P(1)*T(2) - P(2)*T(1)
	CALL V2TRPL(P,PTTP(1),PI)
	CALL V2TRPL(T,PTTP(3),PI)
	CALL V2TRPL(B,ANBTP(5),PI)
	CALL AN2DSR(N,A,ANGS2,PI)
	CALL AN2MOM(A,N,MOMTEN)
	RETURN
	END


C+
	SUBROUTINE ANTPIN (ANBTP,ANGS,ANGS2,PTTP,MOMTEN,PI)
C
C	Calculates other representations of fault planes with
C		trend and plunge of A and N as input.  All
C		angles are in radians.
C	22 July 1985:  Added moment tensor output.
C-
	REAL N(3), MOMTEN(6)
	DIMENSION PTTP(4),ANGS(3),ANGS2(3),ANBTP(6),P(3),T(3),A(3),B(3)
	DATA SR2/0.707107/
	CALL TRPL2V(ANBTP(1),A)
	CALL TRPL2V(ANBTP(3),N)
	DO 100 J=1,3
	  T(J) = SR2*(A(J) + N(J))
	  P(J) = SR2*(A(J) - N(J))
100	CONTINUE
	B(1) = P(2)*T(3) - P(3)*T(2)
	B(2) = P(3)*T(1) - P(1)*T(3)
	B(3) = P(1)*T(2) - P(2)*T(1)
	CALL V2TRPL(P,PTTP(1),PI)
	CALL V2TRPL(T,PTTP(3),PI)
	CALL V2TRPL(B,ANBTP(5),PI)
	CALL AN2DSR(A,N,ANGS,PI)
	CALL AN2DSR(N,A,ANGS2,PI)
	CALL AN2MOM(A,N,MOMTEN)
	RETURN
	END


C+
	SUBROUTINE PTTPIN (PTTP,ANGS,ANGS2,ANBTP,MOMTEN,PI)
C
C	Calculates other representations of fault planes with
C		trend and plunge of P and T as input.  All
C		angles are in radians.
C	22 July 1985:  Added moment tensor output
C-
	REAL N(3),MOMTEN(6)
	DIMENSION PTTP(4),ANGS(3),ANGS2(3),ANBTP(6),P(3),T(3),A(3),B(3)
	DATA SR2/0.707107/
	CALL TRPL2V(PTTP(1),P)
	CALL TRPL2V(PTTP(3),T)
	DO 100 J=1,3
	  A(J) = SR2*(P(J) + T(J))
	  N(J) = SR2*(T(J) - P(J))
100	CONTINUE
	B(1) = P(2)*T(3) - P(3)*T(2)
	B(2) = P(3)*T(1) - P(1)*T(3)
	B(3) = P(1)*T(2) - P(2)*T(1)
	CALL V2TRPL(A,ANBTP(1),PI)
	CALL V2TRPL(N,ANBTP(3),PI)
	CALL V2TRPL(B,ANBTP(5),PI)
	CALL AN2DSR(A,N,ANGS,PI)
	CALL AN2DSR(N,A,ANGS2,PI)
	CALL AN2MOM(A,N,MOMTEN)
	RETURN
	END


C+
	SUBROUTINE AN2MOM(A,N,MOMTEN)
C
C	Starting with the A and N axis, calculates the elements
C	  of the moment tensor with unit scalar moment.
C	  Convention used is that of Dziewonski & Woodhouse
C	  (JGR 88, 3247-3271, 1983) and Aki & Richards (p 118)
C	24 September 1985: If an element is < 0.000001 (ABS), set to zero
C-
	REAL*4 A(3), N(3), MOMTEN(6)
C	      Moment tensor components:  M(I,j) = A(I)*N(J)+A(J)*N(I)
	MOMTEN(1) = 2.0*A(3)*N(3)	!  MRR = M(3,3)
	MOMTEN(2) = 2.0*A(1)*N(1)	!  MTT = M(1,1)
	MOMTEN(3) = 2.0*A(2)*N(2)	!  MPP = M(2,2)
	MOMTEN(4) = A(1)*N(3)+A(3)*N(1)	!  MRT = M(1,3)
	MOMTEN(5) = -A(2)*N(3)-A(3)*N(2)!  MRP = -M(2,3)
	MOMTEN(6) = -A(2)*N(1)-A(1)*N(2)!  MTP = -M(2,1)
	DO 100 J=1,6
	  IF (ABS(MOMTEN(J)) .LT. 0.000001) MOMTEN(J) = 0.0
100	CONTINUE
	RETURN
	END


C+
C	SUBROUTINE AN2DSR(A,N,ANGS,PI)
C
C	Calculates dip, strike and rake (ANGS) - A&R convention,
C		from A and N.
C	12 January 2000:  Fixed a divide by zero when angs(1) .eq. 0
C-
	SUBROUTINE AN2DSR(A,N,ANGS,PI)
	REAL N(3),A(3),ANGS(3)
	if (N(3) .eq. -1.0) then
	  angs(2) = atan2(a(2),a(1))
	  angs(1) = 0.0
	else
	  ANGS(2) = ATAN2(-N(1),N(2))
	  if (N(3) .eq. 0.0) then
	    angs(1) = 0.5*PI
	  else IF (ABS(SIN(ANGS(2))) .ge. 0.1) then
	    ANGS(1) = ATAN2(-N(1)/SIN(ANGS(2)),-N(3))
	  else
	    ANGS(1) = ATAN2(N(2)/COS(ANGS(2)),-N(3))
	  end if
	end if
	A1 = A(1)*COS(ANGS(2)) + A(2)*SIN(ANGS(2))
	if (abs(a1) .lt. 0.0001) a1 = 0.0
	if (a(3) .ne. 0.0) then
	  if (angs(1) .ne. 0.0) then
	    ANGS(3) = ATAN2(-A(3)/SIN(ANGS(1)),A1)
	  else
	    ANGS(3) = atan2(-1000000.0*A(3),A1)
	  end if
	else
	  a2 = a(1)*sin(angs(2)) - a(2)*cos(angs(2))
	  if (abs(a2) .lt. 0.0001) a2 = 0.0
	  if (abs(sin(2*angs(2))) .ge. 0.0001) then
	    angs(3) = atan2(a2/sin(2*angs(2)),a1)
	  else if (abs(sin(angs(2))) .ge. 0.0001) then
	    rr=a(2)/sin(angs(2))
            if(rr.gt.1)rr=1.
            if(rr.lt.-1.)rr=-1.
	    angs(3) = acos(rr)
	  else
            if(a1.gt.1)a1=1.
            if(a1.lt.-1.)a1=-1.
	    angs(3) = acos(a1)
	  end if
	end if
	IF (ANGS(1) .lt. 0.0) then
	  ANGS(1) = ANGS(1) + PI
	  ANGS(3) = PI - ANGS(3)
	  IF (ANGS(3) .GT. PI) ANGS(3) = ANGS(3) - 2*PI
	end if
	IF(ANGS(1) .gt. 0.5*PI) then
	  ANGS(1)=PI-ANGS(1)
	  ANGS(2)=ANGS(2)+PI
	  ANGS(3)=-ANGS(3)
	  IF (ANGS(2) .GE. 2*PI) ANGS(2) = ANGS(2) - 2*PI
	end if
	IF (ANGS(2) .LT. 0.0) ANGS(2) = ANGS(2) + 2.0*PI
	RETURN
	END


C+
	SUBROUTINE V2TRPL(XYZ,TRPL,PI)
C
C	Transforms from XYZ components of a unit vector to
C	  the trend and plunge for the vector.
C	Trend is the azimuth (clockwise from north looking down)
C	Plunge is the downward dip measured from the horizontal.
C	All angles in radians
C	X is north, Y is east, Z is down
C	If the component of Z is negative (up), the plunge,TRPL(2),
C	  is replaced by its negative and the trend, TRPL(1),
C	  Is changed by PI.
C	The trend is returned between 0 and 2*PI, the plunge
C	  between 0 and PI/2.
C	12 January 2000: If xyz(3) = -1.0, make the trend PI.  Made
C	  consistency in the roundoff -- all are now 0.0001
C-
	DIMENSION XYZ(3),TRPL(2)
	do j=1,3
	  if (abs(xyz(j)) .le. 0.0001) xyz(j) = 0.0
	  IF (ABS(ABS(XYZ(j))-1.0).LT.0.0001) xyz(j)=xyz(j)/abs(xyz(j))
	end do
	IF (ABS(XYZ(3)) .eq. 1.0) THEN
C
C	plunge is 90 degrees
C
	  if (xyz(3) .lt. 0.0) then
	    trpl(1) = PI
	  else
	    TRPL(1) = 0.0
	  end if
	  TRPL(2) = 0.5*PI
	  RETURN
	END IF
	IF (ABS(XYZ(1)) .LT. 0.0001) THEN
	  IF (XYZ(2) .GT. 0.0) THEN
	    TRPL(1) = PI/2.
	  ELSE IF (XYZ(2) .LT. 0.0) THEN
	    TRPL(1) = 3.0*PI/2.0
	  ELSE
	    TRPL(1) = 0.0
	  END IF
	ELSE
	  TRPL(1) = ATAN2(XYZ(2),XYZ(1))
	END IF
	C = COS(TRPL(1))
	S = SIN(TRPL(1))
	IF (ABS(C) .GE. 0.1) TRPL(2) = ATAN2(XYZ(3),XYZ(1)/C)
	IF (ABS(C) .LT. 0.1) TRPL(2) = ATAN2(XYZ(3),XYZ(2)/S)
	IF (TRPL(2) .LT. 0.0) THEN
	  TRPL(2) = -TRPL(2)
	  TRPL(1) = TRPL(1) - PI
	  END IF
	IF (TRPL(1) .LT. 0.0) TRPL(1) = TRPL(1) + 2.0*PI
	RETURN
	END


C+
C	SUBROUTINE TRPL2V(TRPL,XYZ)
C
C	Transforms to XYZ components of a unit vector from
C		the trend and plunge for the vector.
C	Trend is the azimuth (clockwise from north looking down)
C	Plunge is the downward dip measured from the horizontal.
C	All angles in radians
C	X is north, Y is east, Z is down
C-
	SUBROUTINE TRPL2V(TRPL,XYZ)
	DIMENSION XYZ(3),TRPL(2)
	XYZ(1) = COS(TRPL(1))*COS(TRPL(2))
	XYZ(2) = SIN(TRPL(1))*COS(TRPL(2))
	XYZ(3) = SIN(TRPL(2))
	do j=1,3
	  if (abs(xyz(j)) .lt. 0.0001) xyz(j) = 0.0
	  if (abs(abs(xyz(j))-1.0).lt.0.0001) xyz(j)=xyz(j)/abs(xyz(j))
	end do
	RETURN
	END
C+
	subroutine mt_in(pttp,PI)
C
C	eigenvalues/vectors using EISPACK routines from www.netlib.no
C	Much of code adapted from Jost/Herrmann mteig.f and mtdec.f
C	Uses original EISPACK routines for TRED2 and IMTQL2, not NR
C	Also includes subroutine eig, which calls TRED2 and IMTQL2.
C-
	dimension A(3,3), U(3,3), W(3), PTTP(4), XYZ(3)
	real*4 MRR, MTT, MPP, MRT, MRP, MTP, isotrop
      write(*,*) 'Input MRR MTT MPP MRT MRP MTP (free format)'
      read(*,*) MRR, MTT, MPP, MRT, MRP, MTP
c      write(2,*) '  Input is moment tensor (Dziewonski convention)'
c     write(2,*) 'MRR MTT MPP MRT MRP MTP'
c      write(2,'(1p6g11.4)') MRR, MTT, MPP, MRT, MRP, MTP
C
C	Convention is X north, Y east, Z down
C
      A(3,3) = MRR
      A(1,1) = MTT
      A(2,2) = MPP
      A(1,3) = MRT
      A(3,1) = A(1,3)
      A(2,3) = -MRP
      A(3,2) = A(2,3)
      A(1,2) = -MTP
      A(2,1) = A(1,2)
      Call eig(a,u,w)
C
C	Ordering returned is from smallest to highest (P, B, T for DC)
C
C      write(*,*) ' '
C     write(*,*) 'EIGENVALUES                EIGENVECTORS'
C     do j=1,3
C       write(*,'(1pg11.4,2x,0p5f11.4)') W(j),(U(i,j),i=1,3)
C     end do
      isotrop = 0.0
      do j=1,3
        isotrop = isotrop + w(j)
      end do
      devmom = 0.0
      do j=1,3
        w(j) = w(j) - isotrop/3.0
	devmom = devmom + w(j)*w(j)
      end do
      devmom = sqrt(0.5*devmom)
      if (devmom .lt. 0.001*isotrop) devmom = 0.0
      write(*,*) ' '
      write(*,'(a,1pg11.4,a,g11.4)') 
     1	'  Trace of moment tensor = ',isotrop,
     2  '  Deviatoric tensor moment = ', devmom
      write(2,*) ' '
      write(2,'(a,1pg11.4,a,g11.4)') 
     1	'  Trace of moment tensor = ',isotrop,
     2  '  Deviatoric tensor moment = ', devmom
      if (devmom .eq. 0.0) then
        write(2,*) 'Exiting because purely isotropic source'
	write(*,*) 'Exiting because purely isotropic source'
	stop
      end if
      write(2,'(a,1p3g11.4)') '  Deviatoric moment tensor eigenvalues:',
     1   (w(j),j=1,3)
      write(*,'(a,1p3g11.4)') '  Deviatoric moment tensor eigenvalues:',
     1   (w(j),j=1,3)
c---- Dziewonski, Chou, Woodhouse,  JGR 1981 2825-2852
c---- eps=0 pure double couple
c---- eps=0.5 pure CLVD
      eps = abs(w(2)/amax1(-w(1),w(3)))
      eps1 = eps*200.0
      eps2 = 100.0 - eps1
      write(*,'(a)') '  EPSILON    % OF CLVD     % OF DC'
      write(*,'(f9.4,2f12.4)') eps, eps1, eps2
      write(2,'(a)') '  EPSILON    % OF CLVD     % OF DC'
      write(2,'(f9.4,2f12.4)') eps, eps1, eps2
      write(2,*) ' '
      if (eps .ge. 0.25) then
        write(2,*) ' Exiting because less than 50% double couple'
	write(*,*) ' Exiting because less than 50% double couple'
	stop
      end if
C
C	Get trend and plunge for P
C
      do j=1,3
        xyz(j) = u(j,1)
      end do
      call V2TRPL(XYZ,PTTP(1),PI)
C
C	Get trend and plunge for T
C
      do j=1,3
        xyz(j) = u(j,3)
      end do
      call V2TRPL(XYZ,PTTP(3),PI)
C     do j=1,4
C        pttp(j) = rdeg*pttp(j)
C      end do
C      write(*,*) '  '
C      write(*,*) '  Trend and Plunge of P and T'
C     write(*,'(4f11.4)') pttp
      return
      end
      subroutine eig (a,u,w)
      dimension A(3,3), U(3,3), W(3), work(3)
      np = 3
      do i=1,np
        do j=1,3
	  u(i,j) = a(i,j)
	end do
      end do
      n = 3
      call tred2(np,n,a,w,work,u)
      call imtql2(np,n,w,work,u,ierr)
C
C	This system has P, B, T as a right-hand coordinate system.
C	I prefer P, T, B
C
      do j=1,3
        u(j,1) = -u(j,1)
      end do
      return
      end
c---------------
      subroutine tred2(nm,n,a,d,e,z)
c
      integer i,j,k,l,n,nm
      real a(nm,n),d(n),e(n),z(nm,n)
      real f,g,h,hh,scale
c
c     this subroutine is a translation of the algol procedure tred2,
c     num. math. 11, 181-195(1968) by martin, reinsch, and wilkinson.
c     handbook for auto. comp., vol.ii-linear algebra, 212-226(1971).
c
c     this subroutine reduces a real symmetric matrix to a
c     symmetric tridiagonal matrix using and accumulating
c     orthogonal similarity transformations.
c
c     on input
c
c        nm must be set to the row dimension of two-dimensional
c          array parameters as declared in the calling program
c          dimension statement.
c
c        n is the order of the matrix.
c
c        a contains the real symmetric input matrix.  only the
c          lower triangle of the matrix need be supplied.
c
c     on output
c
c        d contains the diagonal elements of the tridiagonal matrix.
c
c        e contains the subdiagonal elements of the tridiagonal
c          matrix in its last n-1 positions.  e(1) is set to zero.
c
c        z contains the orthogonal transformation matrix
c          produced in the reduction.
c
c        a and z may coincide.  if distinct, a is unaltered.
c
c     Questions and comments should be directed to Alan K. Cline,
c     Pleasant Valley Software, 8603 Altus Cove, Austin, TX 78759.
c     Electronic mail to cline@cs.utexas.edu.
c
c     this version dated january 1989. (for the IBM 3090vf)
c
c     ------------------------------------------------------------------
c
c?      call xuflow(0)
      do 100 i = 1, n
         do 100 j = i, n
  100       z(j,i) = a(j,i)
c
      do 110 i = 1, n
  110    d(i) = a(n,i)
c
      do 300 i = n, 2, -1
         l = i - 1
         h = 0.0e0
         scale = 0.0e0
         if (l .lt. 2) go to 130
c     .......... scale row (algol tol then not needed) ..........
         do 120 k = 1, l
  120    scale = scale + abs(d(k))
c
         if (scale .ne. 0.0e0) go to 140
  130    e(i) = d(l)
c
c"    ( ignore recrdeps
         do 135 j = 1, l
            d(j) = z(l,j)
            z(i,j) = 0.0e0
            z(j,i) = 0.0e0
  135    continue
c
         go to 290
c
  140    do 150 k = 1, l
            d(k) = d(k) / scale
            h = h + d(k) * d(k)
  150    continue
c
         f = d(l)
         g = -sign(sqrt(h),f)
         e(i) = scale * g
         h = h - f * g
         d(l) = f - g
c     .......... form a*u ..........
         do 170 j = 1, l
  170       e(j) = 0.0e0
c
         do 240 j = 1, l
            f = d(j)
            z(j,i) = f
            g = e(j) + z(j,j) * f
c
            do 200 k = j+1, l
               g = g + z(k,j) * d(k)
               e(k) = e(k) + z(k,j) * f
  200       continue
c
            e(j) = g
  240    continue
c     .......... form p ..........
         f = 0.0e0
c
         do 245 j = 1, l
            e(j) = e(j) / h
            f = f + e(j) * d(j)
  245    continue
c
         hh = -f / (h + h)
c     .......... form q ..........
         do 250 j = 1, l
  250       e(j) = e(j) + hh * d(j)
c     .......... form reduced a ..........
         do 280 j = 1, l
            f = -d(j)
            g = -e(j)
c
            do 260 k = j, l
  260          z(k,j) = z(k,j) + f * e(k) + g * d(k)
c
            d(j) = z(l,j)
            z(i,j) = 0.0e0
  280    continue
c
  290    d(i) = h
  300 continue
c     .......... accumulation of transformation matrices ..........
      do 500 i = 2, n
         l = i - 1
         z(n,l) = z(l,l)
         z(l,l) = 1.0e0
         h = d(i)
         if (h .eq. 0.0e0) go to 380
c
         do 330 k = 1, l
  330       d(k) = z(k,i) / h
c     ( ignore recrdeps
c     ( prefer vector
         do 360 j = 1, l
            g = 0.0e0
c
            do 340 k = 1, l
  340          g = g + z(k,i) * z(k,j)
c
            g = -g
c
            do 350 k = 1, l
  350          z(k,j) = z(k,j) + g * d(k)
  360    continue
c
  380    do 400 k = 1, l
  400       z(k,i) = 0.0e0
c
  500 continue
c
c"    ( prefer vector
      do 520 i = 1, n
         d(i) = z(n,i)
         z(n,i) = 0.0e0
  520 continue
c
      z(n,n) = 1.0e0
      e(1) = 0.0e0
      return
      end
      subroutine imtql2(nm,n,d,e,z,ierr)
c
      integer i,j,k,l,m,n,nm,ierr
      real d(n),e(n),z(nm,n)
      real b,c,f,g,p,r,s,tst1,tst2
c
c     this subroutine is a translation of the algol procedure imtql2,
c     num. math. 12, 377-383(1968) by martin and wilkinson,
c     as modified in num. math. 15, 450(1970) by dubrulle.
c     handbook for auto. comp., vol.ii-linear algebra, 241-248(1971).
c
c     this subroutine finds the eigenvalues and eigenvectors
c     of a symmetric tridiagonal matrix by the implicit ql method.
c     the eigenvectors of a full symmetric matrix can also
c     be found if  tred2  has been used to reduce this
c     full matrix to tridiagonal form.
c
c     on input
c
c        nm must be set to the row dimension of two-dimensional
c          array parameters as declared in the calling program
c          dimension statement.
c
c        n is the order of the matrix.
c
c        d contains the diagonal elements of the input matrix.
c
c        e contains the subdiagonal elements of the input matrix
c          in its last n-1 positions.  e(1) is arbitrary.
c
c        z contains the transformation matrix produced in the
c          reduction by  tred2, if performed.  if the eigenvectors
c          of the tridiagonal matrix are desired, z must contain
c          the identity matrix.
c
c      on output
c
c        d contains the eigenvalues in ascending order.  if an
c          error exit is made, the eigenvalues are correct but
c          unordered for indices 1,2,...,ierr-1.
c
c        e has been destroyed.
c
c        z contains orthonormal eigenvectors of the symmetric
c          tridiagonal (or full) matrix.  if an error exit is made,
c          z contains the eigenvectors associated with the stored
c          eigenvalues.
c
c        ierr is set to
c          zero       for normal return,
c          j          if the j-th eigenvalue has not been
c                     determined after 30 iterations.
c
c     Questions and comments should be directed to Alan K. Cline,
c     Pleasant Valley Software, 8603 Altus Cove, Austin, TX 78759.
c     Electronic mail to cline@cs.utexas.edu.
c
c     this version dated january 1989. (for the IBM 3090vf)
c
c     ------------------------------------------------------------------
c
c?      call xuflow(0)
      ierr = 0
      if (n .eq. 1) go to 1001
c
      do 100 i = 2, n
  100 e(i-1) = e(i)
c
      e(n) = 0.0e0
c
      do 240 l = 1, n
         j = 0
c     .......... look for small sub-diagonal element ..........
  105    do 110 m = l, n-1
            tst1 = abs(d(m)) + abs(d(m+1))
            tst2 = tst1 + abs(e(m))
            if (tst2 .eq. tst1) go to 120
  110    continue
c
  120    p = d(l)
         if (m .eq. l) go to 240
         if (j .eq. 30) go to 1000
         j = j + 1
c     .......... form shift ..........
         g = (d(l+1) - p) / (2.0e0 * e(l))
cccccccccccccccccccccccccccccccccccccccccccccccccccc
c *      r = pythag(g,1.0d0)
cccccccccccccccccccccccccccccccccccccccccccccccccccc
         if (abs(g).le.1.0e0) then
            r = sqrt(1.0e0 + g*g)
         else
            r = g * sqrt(1.0e0 + (1.0e0/g)**2)
         endif
cccccccccccccccccccccccccccccccccccccccccccccccccccc
         g = d(m) - p + e(l) / (g + sign(r,g))
         s = 1.0e0
         c = 1.0e0
         p = 0.0e0
c     .......... for i=m-1 step -1 until l do -- ..........
         do 200 i = m-1, l, -1
            f = s * e(i)
            b = c * e(i)
cccccccccccccccccccccccccccccccccccccccccccccccccccc
c *         r = pythag(f,g)
cccccccccccccccccccccccccccccccccccccccccccccccccccc
            if (abs(f).ge.abs(g)) then
               r = abs(f) * sqrt(1.0e0 + (g/f)**2)
            else if (g .ne. 0.0e0) then
               r = abs(g) * sqrt((f/g)**2 + 1.0e0)
            else
               r = abs(f)
            endif
cccccccccccccccccccccccccccccccccccccccccccccccccccc
            e(i+1) = r
            if (r .eq. 0.0e0) then
c     .......... recover from underflow ..........
               d(i+1) = d(i+1) - p
               e(m) = 0.0e0
               go to 105
            endif
            s = f / r
            c = g / r
            g = d(i+1) - p
            r = (d(i) - g) * s + 2.0e0 * c * b
            p = s * r
            d(i+1) = g + p
            g = c * r - b
c     .......... form vector ..........
            do 180 k = 1, n
               f = z(k,i+1)
               z(k,i+1) = s * z(k,i) + c * f
               z(k,i) = c * z(k,i) - s * f
  180       continue
c
  200    continue
c
         d(l) = d(l) - p
         e(l) = g
         e(m) = 0.0e0
         go to 105
  240 continue
c     .......... order eigenvalues and eigenvectors ..........
      do 300 i = 1, n-1
         k = i
         p = d(i)
c
         do 260 j = i+1, n
            if (d(j) .ge. p) go to 260
            k = j
            p = d(j)
  260    continue
c
         d(k) = d(i)
         d(i) = p
c
         do 280 j = 1, n
            p = z(j,i)
            z(j,i) = z(j,k)
            z(j,k) = p
  280    continue
c
  300 continue
c
      go to 1001
c     .......... set error -- no convergence to an
c                eigenvalue after 30 iterations ..........
 1000 ierr = l
 1001 return
      end
