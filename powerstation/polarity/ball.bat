REM needs onemech.dat (data for one selected foc mech solution)
REM needs moremech.dat (data for a set of foc mech solutions)

copy onemech.dat inp.dat
nodal.exe
copy out.dat nodopt.dat
REM  NODopt.DAT was created...
pause

copy moremech.dat inp.dat
nodal.exe
copy out.dat nodall.dat
REM  NODall.DAT was created...
pause

del my.dat
del inp.dat
del out.dat
