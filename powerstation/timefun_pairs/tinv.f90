subroutine tinv(ama,bve,ampl,mode,rnorm,numdat,NTR2)

!  24 .... max possible number of PARAMETERS (time function shifts)


	  real (8) rnorm,ama(516097,24),bve(516097),ampl(24),wnn(24)
	  integer   i,j,mode
      integer   indx(24)
	  integer   numdat

 INTERFACE
  SUBROUTINE nnls (a, m, n, b, x, rnorm, w, indx, mode)
    USE precision
    IMPLICIT NONE
    INTEGER, INTENT(IN)       :: m, n
    INTEGER, INTENT(OUT)      :: indx(:), mode
    REAL (dp), INTENT(IN OUT) :: a(:,:), b(:)
    REAL (dp), INTENT(OUT)    :: x(:), rnorm, w(:)
  END SUBROUTINE nnls
 END INTERFACE

!  call nnls (ama,numdat,12,bve,ampl,rnorm,wnn,indx,mode)   
   
   call nnls (ama,numdat,NTR2,bve,ampl,rnorm,wnn,indx,mode)   





	   return
	   end