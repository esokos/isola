REM needs GRxx.HEA, GRxx.HES for selected source position xx
REM needs ALLSTAT.DAT, MECHAN.DAT, 99.SYN

copy gr01.hea gr.hea
copy gr01.hes gr.hes
conshift.exe
REM creates temporary file SXXXROW.DAT for each XXX station.
 pause



copy  99.syn i.dat
copy  sSERrow.dat row.dat
syn_cor.exe
copy  outsei.dat sSER.dat
del sSERrow.dat

copy  99.syn i.dat
copy  sMAMrow.dat row.dat
syn_cor.exe
copy  outsei.dat sMAM.dat
del sMAMrow.dat

copy  99.syn i.dat
copy  sRLSrow.dat row.dat
syn_cor.exe
copy  outsei.dat sRLS.dat
del sRLSrow.dat

copy  99.syn i.dat
copy  sEVRrow.dat row.dat
syn_cor.exe
copy  outsei.dat sEVR.dat
del sEVRrow.dat

copy  99.syn i.dat
copy  sLKRrow.dat row.dat
syn_cor.exe
copy  outsei.dat sLKR.dat
del sLKRrow.dat

REM Resulting synthetics for station XXX are in file sXXX.DAT. 
REM Four columns: time and N, E, Z displacements.


rem     ifil06.exe
rem     snorm.exe
rem choose spltos_n for normalized plot or spltos without normalization
rem     spltos.exe
rem rem  spltos_n.exe


del i.dat
del gr.hea
del gr.hes
del outsei.dat
del row.dat