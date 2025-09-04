      REAL FUNCTION ANG (A,B)
C
      DIMENSION A(3),B(3)
      FAC=180./3.14159
      AA=SQRT(A(1)*A(1)+A(2)*A(2)+A(3)*A(3))
      BB=SQRT(B(1)*B(1)+B(2)*B(2)+B(3)*B(3))
      CAB=(A(1)*B(1)+A(2)*B(2)+A(3)*B(3))/AA/BB
      SAB=SQRT(ABS(1.-CAB*CAB))
      IF (CAB.NE.0.) THEN
         ANG=ATAN(SAB/CAB)*FAC
       ELSE
         ANG=90.
      ENDIF
      RETURN
      END
