gfortran    isola12c.for -o isola12c.exe

pause

gfortran  norm12c.for -o norm12c.exe

pause

gfortran  isola12c_jack.for -o isola12c_jack.exe

pause

gfortran  iso12c.for -o iso12c.exe

pause

gfortran  norm12c.for -o norm12c.exe

pause

gfortran  dsretc.for -o dsretc.exe

del *.obj

copy *.exe ..