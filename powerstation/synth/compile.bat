call c:\msdev\bin\fpsvars.bat


fl32  /Ox /G5 conshift.for

fl32  /Ox /G5 conshiftCH.for

fl32  /Ox /G5 syn_cor.for

fl32  /Ox /G5 syn_cor2.for

del *.obj

copy  conshift.exe    ..
copy  conshiftCH.exe  ..
copy  syn_cor.exe     ..
copy  syn_cor2.exe    ..