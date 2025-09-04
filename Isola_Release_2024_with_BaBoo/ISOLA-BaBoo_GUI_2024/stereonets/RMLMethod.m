function [xbesti,fvali] = RMLMethod(xp,yp,tparams,sinc,maxit,N,sigma,corrl)
%RMLMethod runs a Monte Carlo type, trishear inversion analysis for a 
%folded bed
%
%   USE: [xbest,fval] = RMLMethod(xp,yp,tparams,sinc,maxit,N,sigma,corrl)
%
%   xp = column vector with x locations of points along bed
%   yp = column vector with y locations of points along bed  
%   tparams = A vector of guess trishear parameters as in function
%            InvTrishear
%   sinc = slip increment
%   maxit = maximum number of iterations in the optimized search
%   N = number of realizations
%   sigma = Variance
%   corrl = Correlation length
%   xbest = Best-fit models for realizations
%   fval = Objective function values of best-fit models
%
%   NOTE: Input ramp and trishear angles should be in radians
%
%   RMLMethod uses function BedRealizations and InvTrishear
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Generate realizations
rlzt = BedRealizations(xp,yp,N,sigma,corrl);

%Initialize xbesti and fvali
xbesti=zeros(N+1,4);
fvali=zeros(N+1,1);

%Find best-fit model for each realization
count = 1;
for i=1:N+1
    [xbest,fval,flag] = InvTrishear(rlzt(:,1,i),rlzt(:,2,i),tparams,...
                                    sinc,maxit);
    % if the function converges to a solution
    if flag > 0
        xbesti(count,:)=xbest;
        fvali(count,:)=fval;
        %Output realization number and fval
        disp(['Realization ',num2str(i),'  fval = ',num2str(fval)]);
        %Increase count
        count = count + 1;
    end
end

%Remove not used elements of xbesti and fvali
xbesti(count:N+1,:)=[];
fvali(count:N+1,:)=[];

end