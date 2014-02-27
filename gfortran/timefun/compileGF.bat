gfortran    norm11b.for -o norm11b.exe

pause


gfortran  -c tinv.f90
pause

gfortran  -c nnls.f90
pause

gfortran  -c  time_fixed.for

pause

gfortran -o time_fixed time_fixed.o nnls.o tinv.o


pause

gfortran timfuncas.for -o timfuncas.exe
pause

gfortran timfuncas1.for -o timfuncas1.exe
pause

gfortran timfuncas2.for -o timfuncas2.exe


gfortran  -c time_loop_two.for 


gfortran -o time_loop_two time_loop_two.o nnls.o tinv.o


copy *.exe ..



