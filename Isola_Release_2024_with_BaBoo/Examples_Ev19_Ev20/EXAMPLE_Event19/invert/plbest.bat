del .gmt*
 
gmtset PS_MEDIA A4 FORMAT_GEO_MAP D
 
psmeca -R1/10/1/10 -JX8c -Sx2c btensor.foc -G255/0/0 -T0 -L2 -B100 -Fa0.15c/cc -Fewhite -Fgblack -K -Y12c -X1c > 250211_11_43_54.22_best.ps
pstext -R1/100/1/40 -JX20c/20c -O -K btensor.sol -M  -X9.7c -Y-11c >> 250211_11_43_54.22_best.ps
 
gawk "{print $3,$2,$1}" ..\gmtfiles\selstat.gmt > sta.gmt
gawk "{print $3,$2,$1}" ..\gmtfiles\selstat.gmt > tsta.gmt
 
gmtset FONT_ANNOT_PRIMARY 8 MAP_ANNOT_OFFSET_PRIMARY 0.05c MAP_TICK_LENGTH 0.05c MAP_ANNOT_OBLIQUE 32 
 
pscoast -R22.05028/29.13304/34.70415/38.60449  -JM9.8c+ -G255/255/204 -Df -W0.7p -O  -B1/0.5:." ":WeSn  -Na/0.8p,red,-.- -K -S104/204/255  -X-10.2c  -Y1c >> 250211_11_43_54.22_best.ps
psxy -R -J ..\gmtfiles\event.gmt -Sa.6c     -W1p -K -O -G255/0/0 >> 250211_11_43_54.22_best.ps
psmeca -R -J -K 250211_11_43_54.22 -Sa1.c/-1  -O  >> 250211_11_43_54.22_best.ps
psxy -R -J  sta.gmt -St.25c     -W1p   -K -O -Ggreen >>  250211_11_43_54.22_best.ps
psxy -R -J ..\gmtfiles\notusedstat.gmt -St.25c  -W1p   -K  -O -Gred >> 250211_11_43_54.22_best.ps
pstext -R -J  tsta.gmt  -D0/0.2c  -F+f10,Helvetica-Bold,blue    -O   >> 250211_11_43_54.22_best.ps
 
psconvert 250211_11_43_54.22_best.ps -Tg -P  -D..\output
move btensor.foc ..\gmtfiles
move btensor.sol ..\gmtfiles
move besttext.gmt ..\gmtfiles
move sta.gmt ..\gmtfiles
move tsta.gmt ..\gmtfiles
