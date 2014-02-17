call c:\msdev\bin\fpsvars.bat


fl32 /4Yb  acka.for

fl32 /4Yb  analyze_kag.for

rem fl32 /4Yb  iso11b.for

fl32 /4Yb  pokus5all_kag.for

fl32 /4Yb  sigma5or6.for


del *.obj

copy acka.exe ..
copy analyze_kag.exe ..
copy pokus5all_kag.exe ..
copy sigma5or6.exe ..