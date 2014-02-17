
      function  DETERMI(xlam)

      dimension andc(6),a2(6),b(6)

      common /constraint/ andc,a2,b

      nmom=5

      do n=1,nmom
      a2(n)=andc(n) - xlam * b(n)
      enddo

      DETERMI=a2(4)*a2(4)*a2(5)+a2(4)*a2(5)*a2(5)+a2(3)*a2(3)*a2(4)-
     *      a2(1)*a2(1)*a2(4)-a2(1)*a2(1)*a2(5)+a2(2)*a2(2)*a2(5)-
     *   2.*a2(1)*a2(2)*a2(3)


      RETURN
      END

