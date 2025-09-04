function [] = my_boo_weig (ncomp,nsets)
close all


%  claassical BOO weights (not Bayes Boo)  pomoci MULTINOMIAL
rng(1); % Set random seed % For reproducibility

% ncomp .... number of components (number of stations times 3) 
% nsets .... number of perturbations

MM=nsets;
nn=ncomp;    
NN=nn;
% **********    BOOTSTRAP        ******************
      w = mnrnd(NN, ones(1,nn)/nn,  MM)  * (1/nn) % produces MM rows, each row = set of BOO weights for nn stations
      sum (w,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
figure
plot(1:nn,w(:,:), 'd')   % musim malovat w(:,:) abych odstal vsechny ; w je matice !!!
title ([' Classical BO weights']) % frequency of individual values 1:n
%                  ZASADNI PRO POCHPENI 'histogramu vah (cetnosti '
figure 
histogram(w) 

