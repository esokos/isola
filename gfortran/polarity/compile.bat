
gfortran  angm.for -o angm.exe

pause

gfortran  nodal.for -o nodal.exe

pause

gfortran  onlysym.for  -o onlysym.exe

del *.obj

copy *.exe ..