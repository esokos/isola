News of February 2023 (a completely new package - testing stage):


Basic Info
This folder includes the latest ISOLA version (2022).

For the most detailed documentation, see:
http://geo.mff.cuni.cz/~jz/for_Brasilia2020/
See that page to understand how to install and use the software. 
Installation consists of these steps:
a) For each earthquake, create a new working folder and run Isola there. 
b) Make two separate folders in your computer for the Isola_Fortran and Isola_GUI  
c) In Windows, put Fortran  folder on system path
d) In Matlab, put GUI on the path.
[The above link specifies also other codes that MUST be on the paths!] 

For previous versions, see:
http://geo.mff.cuni.cz/~jz/for_Cuba2018/
and before 2018: http://geo.mff.cuni.cz/~jz/for_ISOLA/

ISOLA code development is a long-term joint project of two authors:
Jiri Zahradnik (Charles University in Prague) and Efthimios Sokos (University of Patras)

For applications, see http://geo.mff.cuni.cz/~jz/

Cite this software as:
Zahradník, J., and E. Sokos (2018). ISOLA code for multiple-point source modeling –review. 
In: “Moment Tensor Solutions - A Useful Tool for Seismotectonics” (S. D'Amico, Ed.), Springer.


Isolacfg.isl
Check this file for defaults and edit accordingly. This file should be in ISOLA GUI install folder.



This release includes codes for MT uncertainty based on the simplest single-constant diagonal covariance matrix of waveforms
whose elements are equal to the squared maximal amplitude at the most distant station.
More sophisticated covariance matrices are still under testing and will be released later. 


All codes ready for Intel (ifort)  and Gfort (gfortran); old Powerstation Fortran compiler is no more used.

All codes use time series of 1024 points [instead of previous 8192]
(Isola now creates instrumentally corrected data sampled in 1024 points (tool Data Preparation).
If you have old data (*raw.dat) created from the 2021 and previous versions, such data cannot be used.!!!You must repeat Data Preparation )

All for 64bit

Codes with COVA use MKL library; available for Intel and Gfort (not trivial but transferrable)
Old msimsl library is no more used; replaced by random numbers from Num. Rec  
Old FCOOLR code still used (no problem in Intel but needs special treatment when compiling in Gfort)

Advantages: 
Speedup; thus easy calculation of Green up to Nyquist (strongly recommended !!)
Bugs with underflow (newaspo, silsub,...) detected and corrected
Bug with triangle time function corrected
[Now Trinagle is shifted by T/2, thus centroid time must be grid-searched aroung t= OT + T/2
where T is triangle duration and OT is origin time (i.e. not grid-searched around OT as before!).]


Comments:
If gre-xyz.exe does not work, copy (in Fortran folder) the file gr_xyz_Ifort_withoutOPTIMIZ.exe into gr_xyz.exe.






Generic Names (if you recompile)

Try to use *exe files as they are provided in the Isola distribution!
If not working, and you need to compile ycodes yourself, prefer Intel Fortran.

If you must for some reason use instead the Gfortran, then 
when compiling some codes it gives ERROR due to FCOOLR. It must be solved by compiling like this:
gfortran -fall-argument-mismatch codename.for
                   
GUI calls  *.exe codes of specific names, so you must know which *.for code to compile and how to rename
into "generic names".
For example, Fortran folder constains several isola***.for codes, but standard user must use isola2022.for,
compile it (if he/she cannot use the provided *.exe) and rename the compiled file as isola.exe                   

Summary of required generic names:
                                                                                                                                                                            
isola.exe must be compiled code isola2022.for [ignore the other ”isolas”]
gr_xyz.exe must be compiled code gr_xyz_Intel.for 
elemse.exe .... elemse_1024Intel.for
newaspo.exe ...newaspo9_1024Intel.for
sipolnew.exe ... sipolnew4.for 
time_fixed.exe  ... time_fixed.for 
time_loop_two.exe ... time_loop_twodiff.for
syn_cor.exe ... syn_cor_rand.for
conshift.exe ... conshift.for
conshift_MT.exe ... conshift_MT.for
angone.exe ... angone.for
 



 