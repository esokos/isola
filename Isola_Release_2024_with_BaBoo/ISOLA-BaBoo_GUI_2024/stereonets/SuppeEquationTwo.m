function y=SuppeEquationTwo(gamstar,ramp)
%SuppeEquationTwo: First equation in Eq.11.20 for parallel fault 
%propagation folding
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

y = (1.+2.*cos(gamstar)*cos(gamstar))/sin(2.*gamstar) +...
    (cos(ramp)-2.)/sin(ramp);
end