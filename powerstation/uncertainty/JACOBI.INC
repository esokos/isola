      SUBROUTINE JACOBI (N,ITMAX,EPS1,EPS2,EPS3,A,T,EIGEN,AIK)
C
      DIMENSION A(3,3),T(3,3),AIK(3),EIGEN(3)
C
      DO 100 I=1,N
      DO 100 J=1,N
  100 T(I,J)=0.
      NM1=N-1
      SIGMA1=0.
      OFFDSQ=0.
      DO 110 I=1,N
       SIGMA1=SIGMA1+A(I,I)**2
       T(I,I)=1.
       IP1=I+1
       IF(I.GE.N) GOTO 120
       DO 110 J=IP1,N
  110 OFFDSQ=OFFDSQ+A(I,J)**2
  120 S=2.*OFFDSQ+SIGMA1
C
      DO 180 ITER=1,ITMAX
       DO 160 I=1,NM1
        IP1=I+1
        DO 160 J=IP1,N
         Q=ABS(A(I,I)-A(J,J))
         IF (Q.GT.EPS1) THEN
            IF (ABS(A(I,J)).LE.EPS2) GOTO 160
            P=2.*A(I,J)*Q/(A(I,I)-A(J,J))
            SPQ=SQRT(P*P+Q*Q)
            CSA=SQRT((1.+Q/SPQ)*.5)
            SNA=P/(2.*CSA*SPQ)
          ELSE
            CSA=.707106781186547
            SNA=CSA
         ENDIF
         DO 130 K=1,N
          HOLDKI=T(K,I)
          T(K,I)=HOLDKI*CSA+T(K,J)*SNA
          T(K,J)=HOLDKI*SNA-T(K,J)*CSA
  130    CONTINUE
         DO 140 K=1,N
          IF (K.LE.J) THEN
             AIK(K)=A(I,K)
             A(I,K)=CSA*AIK(K)+SNA*A(K,J)
             IF (K.EQ.J) A(J,K)=SNA*AIK(K)-CSA*A(J,K)
           ELSE
             HOLDIK=A(I,K)
             A(I,K)=CSA*HOLDIK+SNA*A(J,K)
             A(J,K)=SNA*HOLDIK-CSA*A(J,K)
          ENDIF
  140    CONTINUE
         AIK(J)=SNA*AIK(I)-CSA*AIK(J)
         DO 150 K=1,J
          IF (K.GT.I) THEN
             A(K,J)=SNA*AIK(K)-CSA*A(K,J)
           ELSE
             HOLDKI=A(K,I)
             A(K,I)=CSA*HOLDKI+SNA*A(K,J)
             A(K,J)=SNA*HOLDKI-CSA*A(K,J)
          ENDIF
  150    CONTINUE
  160  A(I,J)=0.
       SIGMA2=0.
       DO 170 I=1,N
        EIGEN(I)=A(I,I)
        SIGMA2=SIGMA2+EIGEN(I)**2
  170  CONTINUE
       IF (1.-SIGMA1/SIGMA2.LT.EPS3) GOTO 190
       SIGMA1=SIGMA2
  180 CONTINUE
      WRITE (*,'(//'' No convergence with '',I3,'' iterations''//)')
     &        ITMAX
C
  190 continue
c     write(*,*) 'jacobi'
      RETURN
      END
