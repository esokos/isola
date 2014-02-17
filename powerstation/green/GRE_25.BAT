rem Calculates Green's functions 
rem It needs GRDAT.HED, STATION.DAT and CRUSTAL.DAT

copy src01.dat source.dat
gr_xyz.exe
copy gr.hea gr01.hea
copy gr.hes gr01.hes

copy src02.dat source.dat
gr_xyz.exe
copy gr.hea gr02.hea
copy gr.hes gr02.hes

copy src03.dat source.dat
gr_xyz.exe
copy gr.hea gr03.hea
copy gr.hes gr03.hes

copy src04.dat source.dat
gr_xyz.exe
copy gr.hea gr04.hea
copy gr.hes gr04.hes

copy src05.dat source.dat
gr_xyz.exe
copy gr.hea gr05.hea
copy gr.hes gr05.hes

copy src06.dat source.dat
gr_xyz.exe
copy gr.hea gr06.hea
copy gr.hes gr06.hes

copy src07.dat source.dat
gr_xyz.exe
copy gr.hea gr07.hea
copy gr.hes gr07.hes

copy src08.dat source.dat
gr_xyz.exe
copy gr.hea gr08.hea
copy gr.hes gr08.hes

copy src09.dat source.dat
gr_xyz.exe
copy gr.hea gr09.hea
copy gr.hes gr09.hes

copy src10.dat source.dat
gr_xyz.exe
copy gr.hea gr10.hea
copy gr.hes gr10.hes

copy src11.dat source.dat
gr_xyz.exe
copy gr.hea gr11.hea
copy gr.hes gr11.hes

copy src12.dat source.dat
gr_xyz.exe
copy gr.hea gr12.hea
copy gr.hes gr12.hes




copy src13.dat source.dat
gr_xyz.exe
copy gr.hea gr13.hea
copy gr.hes gr13.hes

copy src14.dat source.dat
gr_xyz.exe
copy gr.hea gr14.hea
copy gr.hes gr14.hes

copy src15.dat source.dat
gr_xyz.exe
copy gr.hea gr15.hea
copy gr.hes gr15.hes

copy src16.dat source.dat
gr_xyz.exe
copy gr.hea gr16.hea
copy gr.hes gr16.hes

copy src17.dat source.dat
gr_xyz.exe
copy gr.hea gr17.hea
copy gr.hes gr17.hes

copy src18.dat source.dat
gr_xyz.exe
copy gr.hea gr18.hea
copy gr.hes gr18.hes

copy src19.dat source.dat
gr_xyz.exe
copy gr.hea gr19.hea
copy gr.hes gr19.hes

copy src20.dat source.dat
gr_xyz.exe
copy gr.hea gr20.hea
copy gr.hes gr20.hes

copy src21.dat source.dat
gr_xyz.exe
copy gr.hea gr21.hea
copy gr.hes gr21.hes

copy src22.dat source.dat
gr_xyz.exe
copy gr.hea gr22.hea
copy gr.hes gr22.hes

copy src23.dat source.dat
gr_xyz.exe
copy gr.hea gr23.hea
copy gr.hes gr23.hes

copy src24.dat source.dat
gr_xyz.exe
copy gr.hea gr24.hea
copy gr.hes gr24.hes

copy src25.dat source.dat
gr_xyz.exe
copy gr.hea gr25.hea
copy gr.hes gr25.hes

del gr.hea
del gr.hes
del source.dat
