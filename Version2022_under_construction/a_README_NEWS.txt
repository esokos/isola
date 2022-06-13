News of May 2022 (a completely new package - testing stage):

All codes ready for Intel (ifort)  and Gfort (gfortran); old Powerstation no more used
All codes use time series of 1024 points [instead of previous 8192]
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