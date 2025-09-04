gmtset FONT_ANNOT_PRIMARY 11 FONT_LABEL 14 PS_MEDIA A4
gawk "{if (NR>2 && $3 > 0)  print $2,1+($1-1)*1,$10,$4,$5,$6,"5","0","0"}" corr01.dat > testfoc.dat
gawk "{if (NR>2)  print $2,1+($1-1)*1,$3}" corr01.dat > corcon.dat
makecpt -Ccopper -T0/100/10 -I > dc.cpt
makecpt -Ccool -T0/0.8846   corcon.dat  -S0.1+d  > cr.cpt
pscontour corcon.dat -R-2.4/2.4/0.5/20.5  -W0.5p -JX21c/18c -B1g1:"Time(sec)":/1:"Source position (km)":WeSn -Ccr.cpt -K -I -A+a0+f10 > corr01.ps
psscale -D22c/4c/7c/0.2 -O -Ccr.cpt -K   -Bx0.1+lCorrelation >> corr01.ps
psscale -D22c/13c/7c/0.2 -O -Cdc.cpt -K -L  -B::/:DC\045: >> corr01.ps
psmeca -R -JX21c/18c -Sa0.35 -O -K testfoc.dat -Zdc.cpt >> corr01.ps
psmeca -R -JX21c/18c -Sa0.65 -O maxval.foc -Zdc.cpt >> corr01.ps
psconvert corr01.ps -Tg -P -E75 -Qg2  -Qt2 -D..\output
move /y ..\output\corr01.png  ..\output\250212_01_14_54.63_corr01.png
