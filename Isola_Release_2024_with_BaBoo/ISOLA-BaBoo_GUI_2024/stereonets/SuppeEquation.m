function y = SuppeEquation(gama,theta)
%SuppeEquation: First equation in Eq. 11.8 for fault bend folding
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

y = sin(2*gama)/(2*(cos(gama))^2+1) - tan(theta);

end

