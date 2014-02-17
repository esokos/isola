rem Calculates Green's functions 
rem It needs GRDAT.HED, STATION.DAT 
rem NEW !!!!! it also needs ALLSTAT.DAT with crustal model in the SIXTH column
rem numbers in sixth column of ALLSTAT must be 1, or 1 and 2, or 1,2, 3, or 1,2,3,4, NOT e.g. 1 and 3.

rem It needs crustal model (-s): CRUSTAL_01, CRUSTAL_02.dat 
rem (up to 4 crustal models, maybe less)
rem It needs source model(-s): SRC01.DAT, SRC02.dat, .....

rem NEW PHILOSOPHY
rem numbering crustal models is with _01, _02... (i.e., NOT with 01, 02..)
rem First: starting with one source, all crustal models
rem Then: repetition for source 2, source 3...
rem FINAL OUTPUT has the same numbering as befor, elemse01.dat, elemse02.dat... where 01, 02 = sources

rem HERE we assume THREE crustal models and TWO sources
rem (in GUI this bat file will be created automatically after ALLSTAT
rem and it will be clear from allstat howmany crustal models we need; maximum 4).

rem !! caution: all trial sources have same relation between stations and crustal models

rem !! caution: 6th column of ALLSTAT has a role in elecomb.exe !
rem             When running isola in invert this column has already no effect
rem             GUI version does not like 6th column while runninh isola in invert !!

copy src01.dat source.dat

copy crustal_01.dat crustal.dat
gr_xyz.exe
rem copy gr.hea gr01.hea and back is unnecessary now !
REM needs GR.HES and GR.HEA, ...
elemse.exe
copy elemse.dat elemse_01.dat
rem this is elemse for crustal model 01, source 01

copy crustal_02.dat crustal.dat
gr_xyz.exe
elemse.exe
copy elemse.dat elemse_02.dat
rem this is elemse for crustal model 02, source 01 

copy crustal_03.dat crustal.dat
gr_xyz.exe
elemse.exe
copy elemse.dat elemse_03.dat
rem this is elemse for crustal model 03, source 01 

rem up to FOUR crustal models is allowed
rem NOTATION: elemse_01, _02 is for crust 01, 02, both IMPLICITELY for source 01 

rem it is CRITICAL that elecomb.exe expects so many crustal models as prescribed in ALLSTAT
rem all elemse_ MUST be present, but this is NOT CHECKED !!!!


elecomb.exe
rem it reads elemse_01, _02 for crustal models 01_02 (fixed source)
copy elemsenew.dat elemse01.dat
rem combines elemse_01 and elemse_02 into elemse01.dat for this fixed source 
rem elemse01.dat is for source 01 but already with different crustal models for different stations 
del elemse_01.dat
del elemse_02.dat
del elemse_03.dat

rem *******************************************************************
REM NOW THE SAME FOR SOURCE NO. 2

copy src02.dat source.dat

copy crustal_01.dat crustal.dat
gr_xyz.exe
elemse.exe
copy elemse.dat elemse_01.dat

copy crustal_02.dat crustal.dat
gr_xyz.exe
elemse.exe
copy elemse.dat elemse_02.dat

copy crustal_03.dat crustal.dat
gr_xyz.exe
elemse.exe
copy elemse.dat elemse_03.dat



elecomb.exe
copy elemsenew.dat elemse02.dat
rem elemse02.dat is for source 02 but already with different crustal models for different stations 
del elemse_01.dat
del elemse_02.dat
del elemse_03.dat

rem *******************************************************************
Rem source No. 3...........

rem *******************************************************************

rem Finally:
rem elemse01.dat ...elemse49.dat for sources 01...49 
rem but now already with diferent crustal models for different stations

del gr.hes
del gr.hea
del elemse.dat
del elemsenew.dat