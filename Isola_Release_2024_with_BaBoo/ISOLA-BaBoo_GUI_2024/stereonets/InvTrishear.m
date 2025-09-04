function [xbest,fval,flag] = InvTrishear(xp,yp,tparams,sinc,maxit)
%InvTrishear performs inverse trishear modeling using a constrained, 
%gradient based optimization method
%
%   [xbest,fval,flag] = InvTrishear(xp,yp,tparams,sinc,maxit)
%
%   xp = column vector with x locations of points along bed
%   yp = column vector with y locations of points along bed  
%   tparams = A 1 x 8 vector with the x and y coordinates of the
%           lowest possible location of the fault tip (entries 1 and 2), 
%           the distance along the fault line from the lowest to the 
%           highest possible locations of the fault tip (lft, entry 3), 
%           the ramp angle (entry 4), the P/S (entry 5), the trishear angle 
%           (entry 6), the fault slip (entry 7), and the concentration 
%           factor (entry 8)
%   sinc = slip increment
%   maxit = maximum number of iterations in the optimized search
%   xbest = Best-fit model
%   fval = Objective function value of best-fit model
%   flag = Integer that indicates if the model converged (flag > 0)
%
%   NOTE: Input ramp and trishear angles should be in radians
%         The search is for the best-fit slip, trishear angle, P/S, and lft
%         The MATLAB Optimization Toolbox is needed to run this function 
%
%   InvTrishear uses function BackTrishear
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Trishear parameters for BackTrishear
tparam = zeros(1,7);

%Known values
xtt = tparams(1); %Coordinates of lowest possible location of fault tip
ytt = tparams(2);
tparam(3) = tparams(4); %Ramp angle
tparam(7) = tparams(8); %Concentration factor

%Set initial guess (x0), minimum (lb), and maximum (ub) parameters limits
%Entries in these vectors are: [slip trishear angle P/S lft]
%These entries should be in the same order of magnitude
%The values and scaling below only work for the Santa Fe Springs anticline
%Change lb and ub if you want to search over a larger or smaller parameter
%space
sf = 1.0e-3; %scaling for slip and lft
x0= [tparams(7)*sf tparams(6) tparams(5) tparams(3)*sf/2.]; %initial guess
lb = [0. 40.*pi/180. 1.5 0.0]; %lower limit
ub = [15. 80.*pi/180. 3.5 tparams(3)*sf]; %upper limit

%Optimization settings: Display off, maximum number of iterations, and type
%of algorithm. Use MATLAB function optimset (MATLAB Optimization Toolbox)
options = optimset('Display','off','MaxIter',maxit,...
    'Algorithm','active-set');

%Compute best-fit model using constrained, gradient based optimization 
%method. Use MATLAB function fmincon (MATLAB Optimization Toolbox)
[xbest,fval,flag] = fmincon(@objfun,x0,[],[],[],[],lb,ub,@confun,...
                            options);
                        
    %Supporting functions

    %Function to compute the objective function for a given combination of
    %parameters x
    function f = objfun(x)  
    tparam(6) = x(1)/sf; %Slip: Return to its non-scaled value
    tparam(5) = x(2);  %Trishear angle   
    tparam(4) = x(3); %P/S
    lft = x(4)/sf; %lft: Return to its non-scaled value
    tparam(2) = ytt + lft*sin(tparam(3)); %x fault tip
    tparam(1) = xtt + lft*cos(tparam(3)); %y fault tip
    f = BackTrishear(xp,yp,tparam,sinc); %Compute objective function
    end

    %Function for constrained optimization method fmincon
    function [c, ceq] = confun(x)
    % Nonlinear inequality constraints
    c = [];
    % Nonlinear equality constraints
    ceq = [];
    end

end