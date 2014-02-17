call c:\msdev\bin\fpsvars.bat

fl32 angm.for

fl32 nodal.for

fl32 onlysym.for

del *.obj


copy angm.exe ..
copy nodal.exe ..
copy onlysym.exe ..