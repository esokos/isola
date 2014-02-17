call c:\msdev\bin\fpsvars.bat

fl32  -c tinv.f90
pause

fl32  -c nnls.f90
pause


fl32  -c time_loop_two.for 

pause
fl32  time_loop_two.obj nnls.obj tinv.obj



del *.o *.obj
