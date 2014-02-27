gfortran gr_xyz.for -o gr_xyz.exe
gfortran elemse.for -o elemse.exe
gfortran elecomb.for -o elecomb.exe



del *.obj


copy *.exe ..