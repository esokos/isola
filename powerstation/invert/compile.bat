call c:\msdev\bin\fpsvars.bat

fl32  /Ox /G5 isola12c.for

fl32  /Ox /G5 isola12c_jack.for

fl32  /Ox /G5 iso12c.for

fl32  /Ox /G5 norm12c.for

fl32 dsretc.for 


del *.obj

copy isola12c.exe ..
copy isola12c_jack.exe ..
copy iso12c.exe ..
copy norm12c.exe ..
copy dsretc.exe ..
