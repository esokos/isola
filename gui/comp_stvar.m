function stvar=comp_stvar(nsources,tshifts,srcpos2C,srctimeC)

disp('Computing STVAR based on ratio of selected points above threshold to total numer of grid points')

%% find how many points our grid has

time_points=(tshifts(3)-tshifts(1))/tshifts(2);

% 
gridpoints=nsources*time_points;


%% find how many points are above  threshold
sel_points=length(srcpos2C);

%% calculate tsvar

stvar=sel_points/gridpoints;

