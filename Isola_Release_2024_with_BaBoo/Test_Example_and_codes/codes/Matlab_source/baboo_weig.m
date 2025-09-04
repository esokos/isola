function [] = baboo_weig(ncomp,nsets)
% ncomp .... number of components (number of stations times 3) 
% nsets .... number of perturbations

% clear all
% close all

%See 
%https://gdmarmerola.github.io/the-bayesian-bootstrap/
%https://github.com/jdk20/dirichlet-matlab;
% BOO   %mult_samples = multinomial(n, [1./n] * n).rvs(5) * 1/n
% BABOO %dir_samples = dirichlet([1] * n).rvs(5)

if(nsets==0)
fid2=fopen('inpinv2.dat','w');
w=1
fprintf(fid2,'%e  \r\n', w');
fclose(fid2);
else


all=[];
rng(1) % random seed (for reproducibility)
MM=nsets;   
nn=ncomp;   
nn=ncomp/3              % New: all comp have same weight JZ May 14. 2025, see also isorand_main_gui


NN=nn;
% % **********    !!! Bayesian !! BOOTSTRAP        ******************
a=ones(1,nn);  
p=length(a);
w = gamrnd(repmat(a,MM,1),1,MM,p) ;
w = w ./ repmat(sum(w,2),1,p); 
%OR  (= gives almost identical results)
%w=dirrnd(a,MM) %%  https://github.com/jdk20/dirichlet-matlab; 
sum(w,2);

fid2=fopen('inpinv2.dat','w');
fprintf(fid2,'%e  \r\n', w');
fclose(fid2);

figure
plot(1:nn,w(:,:), 'd')  
title ('Bayesian  BOO weights') % frequency of individual values 1 to n
figure 
histogram(w) 
title ('Histogram of BABOO weights') 
% 

end %  

disp('All ended OK for nn stations. Weights are in inpinv2.dat')