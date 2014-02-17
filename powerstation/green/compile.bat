call c:\msdev\bin\fpsvars.bat

fl32 /4Yb /4Yd gr_xyz.for
fl32 /4Yb /4Yd elemse.for

fl32 /4Yb /4Yd elecomb.for

del *.obj

copy gr_xyz.exe ..
copy elemse.exe ..
copy elecomb.exe ..
