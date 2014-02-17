      SUBROUTINE LINE (A,T,N)
      DIMENSION A(3),T(3,3)
C
      DO 240 KK=1,N
       AM=A(KK)
       DO 200 K=KK,N
        IF(A(K).GT.AM) AM=A(K)
  200  CONTINUE
       DO 210 K=KK,N
        IF (A(K).EQ.AM) GOTO 220
  210  CONTINUE
  220  A(K)=A(KK)
       A(KK)=AM
       DO 230 J=1,3
        P9=T(J,K)
        T(J,K)=T(J,KK)
  230  T(J,KK)=P9
  240 CONTINUE
C
c     write(*,*) 'line'
      RETURN
      END
C
