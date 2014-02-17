call c:\msdev\bin\fpsvars.bat

fl32  /Ox /G5 isola12c.for

fl32  /Ox /G5 isola12c_jack.for

fl32  /Ox /G5 iso12c.for


pause

fl32  /Ox /G5 norm12c.for

pause

fl32 dsretc.for 


rem fl32           timfun.for

del *.obj