REM The take-off angles

REM It needs SOURCE.DAT with optimum depth.
REM It needs STATION.DAT with edited last column (polarities).
REM It needs CRUSTAL.DAT.

angm.exe
REM creates mypol.dat
pause

REM reads mypol.dat
onlysym.exe
REM creates symbo.dat

DEL JJOUT.DAT

