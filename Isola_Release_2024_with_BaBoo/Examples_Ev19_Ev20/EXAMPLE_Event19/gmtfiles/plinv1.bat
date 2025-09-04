del .gmtdefaults4 .gmtcommands4
gmtset PS_MEDIA A4 FONT_TITLE 18 FONT_LABEL 16 FONT_ANNOT_PRIMARY 12
   
makecpt -Cno_green -T0/100/10 > inv1.cpt
   
psxy   -R0/21/0.20822/0.92078 -JX22c/15c inv1.gmt  -W2.5p,black,- -K -B1g1:"Depth (km)":/0.1g0.1:"Correlation"::."Correlation vs Depth Plot":WeSn > 250211_11_43_54.22_inv1.ps
psmeca -R -J  -Sa1.3c/12 -K -O inv1.foc -V -Zinv1.cpt  >> 250211_11_43_54.22_inv1.ps
psmeca -R -J  -Sa1.3c/12 -K -O inv1.foc -V -T >> 250211_11_43_54.22_inv1.ps
psscale -D25c/4c/8c/0.5c -O -Cinv1.cpt -B::/:DC\045: >> 250211_11_43_54.22_inv1.ps
   
psconvert 250211_11_43_54.22_inv1.ps -Tg -P   -D..\output
 copy 250211_11_43_54.22_inv1.ps ..\output
move inv1.cpt ..\gmtfiles
move inv1.gmt ..\gmtfiles
move inv1.foc ..\gmtfiles
move plinv1.bat ..\gmtfiles
