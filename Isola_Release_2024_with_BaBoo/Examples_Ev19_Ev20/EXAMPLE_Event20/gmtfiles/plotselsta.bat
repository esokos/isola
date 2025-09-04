gmtset PLOT_DEGREE_FORMAT D  ANNOT_FONT_SIZE_PRIMARY 12 ANNOT_FONT_SIZE_SECONDARY 12 HEADER_FONT_SIZE 14 LABEL_FONT_SIZE 14
  
gawk "{print $3,$2,1}" selstat.gmt > sta.gmt
gawk "{print $3,$2,11,0,1,\"CB\",$1}" selstat.gmt > tsta.gmt
  
pscoast -R22.86210/28.32122/35.06134/38.24730  -JM16c+ -G255/255/204 -Df -W0.7p  -Lf25.5917/35.2844/36.6543/50+l -B1/0.5:."Event ID\072250212_01_14_54.63":  -Na/0.8p,red,-.- -K -S104/204/255  > 250212_01_14_54.63_selsta.ps
psxy -R -J  sta.gmt -St.4c -M  -W1p/0 -K -O -G255/0/0 >> 250212_01_14_54.63_selsta.ps
pstext -R -J  tsta.gmt  -D0/0.45c  -W255/255/255,o  -K -O -G0/0/255 >> 250212_01_14_54.63_selsta.ps
psxy -R -J event.gmt -Sa.6c -M  -W1p/0  -O -G255/0/0 >> 250212_01_14_54.63_selsta.ps
  
ps2raster 250212_01_14_54.63_selsta.ps -A -P -Tg
  
del tsta.gmt sta.gmt
  
copy 250212_01_14_54.63_selsta.ps     ..\output\
copy 250212_01_14_54.63_selsta.png     ..\output\
  
