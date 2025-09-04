function [] = my_baboo_weig (ncomp,nsets)
% clear all
% close all

%See 
%https://gdmarmerola.github.io/the-bayesian-bootstrap/
% BOO   %mult_samples = multinomial(n, [1./n] * n).rvs(5) * 1/n
% BABOO %dir_samples = dirichlet([1] * n).rvs(5)

% ncomp .... number of components (number of stations times 3) 
% nsets .... number of perturbations

all=[]
rng(1) % random seed (for reproducibility)
MM=nsets;     %!!!!!!!!!!!!!!!!!!!!!! requested number of sets of weights
nn=ncomp; %!!!!!!!!!!!!!!!!!!!!!! number of stations in a set we need to weight  

nn=ncomp/3      % JZ May 14 2025


% % % MM=24;   % For presentation (nice histograms), use 30;  
% % % nn=12;  % For presentation (nice histograms), use 100

NN=nn;
% **********    BOOTSTRAP        ******************
      w = mnrnd(NN, ones(1,nn)/nn,  MM)  * (1/nn); % produces MM rows, each row = set of BOO weights for nn stations
      sum (w,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%  all=[aclvd_2; avol_2; adc_2; amt; Mw; a1'; a2'; a3'; a4'; a5'; a6'; Mxx'; Myy'; Mzz'; Mxx_Myy'; Mxx_Mzz'; fix(str1); fix(dp1); fix(rk1)];  
%              
%                  fprintf(fid2,'%f %f %f %e %f %e %e %e %e %e %e  %e %e %e  %e %e   %5d  %5d  %5d\r\n',all);

%fid2=fopen('weights_BOO.dat','w');
%fprintf(fid2,'%e \r\n', w');  
%fclose(fid2);

%figure
%plot(1:nn,w(:,:), 'd')   % musim malovat w(:,:) abych odstal vsechny ; w je matice !!!
%title ([' Classical BOO weights']) % frequency of individual values 1:n
%                  ZASADNI PRO POCHPENI 'histogramu vah (cetnosti '
%figure 
%histogram(w) 
%title (['Histogram of BOO weights']) 

% % **********    !!! Bayesian !! BOOTSTRAP        ******************
%See 
%https://gdmarmerola.github.io/the-bayesian-bootstrap/
% BOO   %mult_samples = multinomial(n, [1./n] * n).rvs(5) * 1/n
% BABOO %dir_samples = dirichlet([1] * n).rvs(5)
%
%better simpler:  https://github.com/jdk20/dirichlet-matlab;
%
% for my tests see diri2.m, my_show5.m 

rng(1)
%MM=30;   % For presentation (nice histograms), use 30;  
% nn=100;     % % For presentation (nice histograms), use 100
a=ones(1,nn); % /nn; % !!!!!! THIS IS A KEY POINT , not to have /nn!!!!!!!!! 
p=length(a);
w = gamrnd(repmat(a,MM,1),1,MM,p) ;
w = w ./ repmat(sum(w,2),1,p); 

%OR  (=identical)
%%%w=dirrnd(a,MM) %%  https://github.com/jdk20/dirichlet-matlab;  inside the code can see how GAMMA is coded
sum(w,2);

fid2=fopen('weights_BABOO.dat','w');
fprintf(fid2,'%e  \r\n', w');  
fclose(fid2);


figure
plot(1:nn,w(:,:), 'd')   % musim malovat w(:,:) abych odstal vsechny ; w je matice !!!
title ([' Bayesian  BOO weights']) % frequency of individual values 1:n
%                  ZASADNI PRO POCHPENI 'histogramu vah (cetnosti '
figure 
histogram(w) 
title (['Histogram of BABOO weights']) 
% 



% MOJE NAPODOBENINA BABOO Z GRONDU


% n=3;
% z=[]; %radkovy vektor ktery se bude postupne nastavovat
% figure; hold % aby se v cyklu kreslilo stale  do stejneho grafu 
% for i=1:n %
% y = random('uniform', 0, n, [1 n]); % real random numbers from 0 to n as a 1 x n (radkovy) vektor
% z=[z y];                           % z = radkovy vektor; nastavovany postupne z opakovanych tahu 
% xlabel('sample');
% ylabel('random values');
% plot(i,y, 'd')                     % obrazek jednotlivych tahu; totez  jako vyse pomoci randsample 
% % 
% end
% title (['Random draws from UNIFORM distr.'])
% 
% 
% figure
% %size (z);       % (1, n x n ) 1 radek s n x n hodnotami
% %[nnn,edges] = histcounts(z,n)      % nn cetnost tahu hodnot z rozdelenych do  20 intervalu 
% histogram(z,n+1)            % histogram : cetnosti  tazenych cisel v jednotlivych n intervalech 
%                             % pri velkem n je to skoro konst fce                            
% title (['Frequency of drawing a number'])
% 
% 
% figure; hold
% zsort=sort(z)       % vsechna cisla z usporadana vzestupne; priblizne linearni fce; kumulatvni cetnost? 
% zsize=size(zsort,2)
% for i=1:zsize
% plot(i,zsort(i),'d')
% end
% title (['Drawed numbers in ascending order'])
% 
% 
% figure; hold
% for i=1:zsize-1
% dif(i)=zsort(i+1)-zsort(i);    %diference ; priblizna derivace; to pry maji by ty Bayaess boo vahy
% %plot(i/n,dif(i),'d')
% plot(i,dif(i),'d')
% end
% title (['Bayes Boo weights'])
% 
% figure
% histogram(dif,n)      % ale tento histogram vyapda lepe jako v lietarture Dirichlet
% % jse o to zda chci videt ty vahy [viz vyse] nebo jejich histogram
% title ([' histogram of BABO weights'])
% sum(dif) % a REAL approximately equal to INTEGER n !!!!!!!!!! weights dif(i) are properly normalized! 
% 
% 
