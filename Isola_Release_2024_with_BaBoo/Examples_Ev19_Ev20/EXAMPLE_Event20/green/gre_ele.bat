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
    
del gr.hea
del gr.hes
del elemse.dat
rem ******************************** 
rem ******************************** 
rem Finished with Green function calculation 
rem close this window and move to inversion. 
