%*****************************************************************************************
%*                                                                                       *
%*   plot_mechanism.m                                                                    *
%*                                                                                       *
%*   program for plotting non-DC mechanisms from full moment tensors                     *                              
%*                                                                                       *
%*   input:  moments.dat                                                                 *
%*                                                                                       *
%*   functions used: P_T_axes.m, nodal_lines.m, angles.m  shadowing.m                    *
%*                                                                                       *
%*****************************************************************************************
clear all; close all;

%----------------------------------------------------------------------------------------
% input of data
%----------------------------------------------------------------------------------------
load moments.dat

number_of_events = length(moments(:,1))

event     = moments(:,1); 
moment_11 = moments(:,2);  
moment_22 = moments(:,3);  
moment_33 = moments(:,4);  
moment_23 = moments(:,5); 
moment_13 = moments(:,6); 
moment_12 = moments(:,7);

%----------------------------------------------------------------------------------------
% the main loop over events
%----------------------------------------------------------------------------------------
for i=1:number_of_events;

    m=[moment_11(i),moment_12(i),moment_13(i);...
       moment_12(i),moment_22(i),moment_23(i);...
       moment_13(i),moment_23(i),moment_33(i)];

%----------------------------------------------------------------------------------------
% calculation of a fault normal and slip from the moment tensor
%----------------------------------------------------------------------------------------
    angles_all(i,:) = angles(m);
    
    strike_1 = angles_all(i,1);
    dip_1    = angles_all(i,2);
    rake_1   = angles_all(i,3);

%----------------------------------------------------------------------------------------
% plotting the solution
%----------------------------------------------------------------------------------------
    figure; hold on; axis equal; axis off; 

    shadowing(m);

% boundary circle;
    Fi=0:0.1:361;
    plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k','LineWidth',1.5)
 
% denoting the North direction
    plot([0 0], [1 1.07],'k','LineWidth',1.5);

    text(-0.035, 1.15,'N','FontSize',14);

    nodal_lines_(strike_1, dip_1, rake_1);
    P_T_axes_(strike_1, dip_1, rake_1);

end
