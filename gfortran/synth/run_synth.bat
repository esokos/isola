Echo off
          
REM needs GRxx.HEA, GRxx.HES for selected source position xx
REM needs ALLSTAT.DAT, MECHAN.DAT, 99.SYN
REM syn_cor is with 50 sec shift, while syn_cor2 is without 50 sec
          
copy gr10.hea gr.hea
copy gr10.hes gr.hes
conshiftCH.exe
REM creates temporary file SXXXROW.DAT for each XXX station.
          
copy  99.syn i.dat
copy  s001row.dat row.dat
syn_cor.exe
copy  outsei.dat  sEFPA.dat
          
copy  99.syn i.dat
copy  s002row.dat row.dat
syn_cor.exe
copy  outsei.dat  sDSF.dat
          
copy  99.syn i.dat
copy  s003row.dat row.dat
syn_cor.exe
copy  outsei.dat  sGUR.dat
          
copy  99.syn i.dat
copy  s004row.dat row.dat
syn_cor.exe
copy  outsei.dat  sLTK.dat
          
REM ******************************************************
REM ******************************************************
REM ***  part for Velocity Sythetics Without Filter  *****
REM ***  previous part is for Displacement and Filtered **
REM ***  data produced here e.g. s(station)2.dat will be *
REM ***  for frequencies up to green function calculation 
REM ******************************************************
REM ******************************************************
          
copy  99.syn i.dat
copy  s001row.dat row.dat
syn_cor2.exe
copy  outsei.dat  sEFPA2.dat
del  s001row.dat
          
copy  99.syn i.dat
copy  s002row.dat row.dat
syn_cor2.exe
copy  outsei.dat  sDSF2.dat
del  s002row.dat
          
copy  99.syn i.dat
copy  s003row.dat row.dat
syn_cor2.exe
copy  outsei.dat  sGUR2.dat
del  s003row.dat
          
copy  99.syn i.dat
copy  s004row.dat row.dat
syn_cor2.exe
copy  outsei.dat  sLTK2.dat
del  s004row.dat
          
          
del i.dat gr.hea gr.hes outsei.dat row.dat
