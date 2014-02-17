rem input:  all elemse*.dat files, inpinv.dat and allstat.dat; no waveforms *.raw.dat are needed
rem CAUTION!!! Inpinv.dat must request FULL MT
       iso11b.exe
rem output:  vect.dat, sing.dat


rem input: vect.dat, sing.dat
     sigma5or6.exe
rem output: sigma.dat,sigma_short.dat

rem input: strike, dip rake
rem acka.for
rem outpur: a1, ... a5m a6=0 in the file acka_stara.dat
rem ANOTHER possibility;  you take a's from the isola inversion (inv1.dat) 

rem input: sigma.dat and acka_stara.dat !!!!!!!!!!!!!!!!!!
     pokus5all_kag.exe
rem output: elipsa.dat, sit.dat; elipsa includes Kagam's angle

rem input: elipsa.dat
     analyze_kag.exe
rem output: elipsa_max.dat (vicinity of the ellipsoid surface),statistics.dat     

