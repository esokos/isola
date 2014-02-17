      SUBROUTINE ANGLES (ANN1,ANN2,DIP,STRIKE,RAKE)
C
C     procedure ANGLES determines dip, strike and rake angles from
C       nodal plane normals;
C     to obtain both the solutions it has to be called twice:
C       CALL ANGLES (AN1,AN2,D1,S1,R1)
C       CALL ANGLES (AN2,AN1,D2,S2,R2)
C
      DIMENSION ANN1(3),AN1(3),ANN2(3),AN2(3)
C
      EPS=0.001
      FAC=180./3.1415927
      IF (ANN1(3).GT.0.) THEN
         DO 300 J=1,3
          AN2(J)=-ANN2(J)
  300    AN1(J)=-ANN1(J)
       ELSE
         DO 310 J=1,3
          AN2(J)=ANN2(J)
  310    AN1(J)=ANN1(J)
      ENDIF
	   if (an1(3).lt.-0.99) then  !!!!!!!!!!!!!!!!
	   DIP=ACOS(0.999)
	   else
       DIP=ACOS(-AN1(3))
 	   endif !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      IF (ABS(ABS(AN1(3))-1.).LT.EPS) THEN
         RAKE=0.
         STRIKE=ATAN2(AN2(2),AN2(1))
         IF (STRIKE.LT.0.) STRIKE=STRIKE+6.2831853
       ELSE
         SDI=1./SQRT(1.-AN1(3)*AN1(3))
         STRIKE=ATAN2(-AN1(1)*SDI,AN1(2)*SDI)
         IF (STRIKE.LT.0.) STRIKE=STRIKE+6.2831853
         IF (ABS(AN1(3)).LT.EPS) THEN
            IF (ABS(STRIKE).LT.EPS) THEN
               RAKE=ATAN2(-AN2(3),AN2(1))
             ELSEIF (ABS(ABS(STRIKE)-1.5707963).LT.EPS) THEN
                RAKE=ATAN2(-AN2(3),AN2(2))
              ELSE
                CF=COS(STRIKE)
                SF=SIN(STRIKE)
                IF (ABS(CF).GT.ABS(SF)) THEN
                   CR=AN2(1)/CF
                 ELSE
                   CR=AN2(2)/SF
                ENDIF
                RAKE=ATAN2(-AN2(3),CR)
            ENDIF
          ELSE
            CF=COS(STRIKE)
            SF=SIN(STRIKE)
            RAKE=ATAN2((AN2(1)*SF-AN2(2)*CF)/(-AN1(3)),AN2(1)*CF
     &           +AN2(2)*SF)
         ENDIF
      ENDIF
      DIP=DIP*FAC
      STRIKE=STRIKE*FAC
      RAKE=RAKE*FAC
C
c     write(*,*) 'angles'
      RETURN
      END
