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
    
del gr.hea
del gr.hes
del source.dat
             
rem end with GREEN part
             
rem elementary seismogram part 
             
copy gr01.hes gr.hes
copy gr01.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse01.dat
    
copy gr02.hes gr.hes
copy gr02.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse02.dat
    
copy gr03.hes gr.hes
copy gr03.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse03.dat
    
copy gr04.hes gr.hes
copy gr04.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse04.dat
    
copy gr05.hes gr.hes
copy gr05.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse05.dat
    
copy gr06.hes gr.hes
copy gr06.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse06.dat
    
copy gr07.hes gr.hes
copy gr07.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse07.dat
    
copy gr08.hes gr.hes
copy gr08.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse08.dat
    
copy gr09.hes gr.hes
copy gr09.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse09.dat
    
copy gr10.hes gr.hes
copy gr10.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse10.dat
    
copy gr11.hes gr.hes
copy gr11.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse11.dat
    
copy gr12.hes gr.hes
copy gr12.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse12.dat
    
copy gr13.hes gr.hes
copy gr13.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse13.dat
    
copy gr14.hes gr.hes
copy gr14.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse14.dat
    
copy gr15.hes gr.hes
copy gr15.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse15.dat
    
copy gr16.hes gr.hes
copy gr16.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse16.dat
    
copy gr17.hes gr.hes
copy gr17.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse17.dat
    
copy gr18.hes gr.hes
copy gr18.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse18.dat
    
copy gr19.hes gr.hes
copy gr19.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse19.dat
    
copy gr20.hes gr.hes
copy gr20.hea gr.hea
elemse.exe
copy elemse.dat ..\invert\elemse20.dat
    
del gr.hea
del gr.hes
del elemse.dat
rem ******************************** 
rem ******************************** 
rem Finished with Green function calculation 
rem close this window and move to inversion. 
