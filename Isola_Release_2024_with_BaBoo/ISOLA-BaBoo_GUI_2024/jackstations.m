function [] = jackstations(type)

disp('This is jackstations 10/04/2024, including COVA matrix option')
disp('it will run jacknifing on stations in current isola run folder.')
disp(' ')

disp('*******************************************************************')
disp('Before doing Jackknife test, user has to use the inversion  tool,')
disp('where he/she choses stations, frequency interval, type of MT, type')
disp('of time function, etc.; the inversion can be made with or without cova matrix')
disp('*******************************************************************')


pwd


if strcmp(type,'NOCOVA')

    jackstations_nocova
        
elseif strcmp(type,'COVA')
    
    jackstations_cova

end

