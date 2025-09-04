function [] = my_boo_plots_sep
close all
clear all

%fid2=fopen('booplots.dat','w');

% h=dir('CLVDetcPOST.dat');   % JZ
% 
% if isempty(h)
%     errordlg('CLVDetcPOST.dat file doesn''t exist. Run Uncertainty code. ','File Error');
%     cd ..
%   return    
% else

% read the file
 fid = fopen('CLVDetcPOST.dat','r');
  A= textscan(fid,'%u %u %u %f %f %f %f %f %f %f %f %f');
 fclose(fid);

 ipert=A{1};ipos=A{2};itim=A{3};clvd=A{4};vol=A{5};var=A{12};
 ipos2=ipos .^2 .*5;

%% figures
% surf(ipos,itim,vol)

figure (1)
 scatter(vol,ipert,ipos2,var) 
 title('Perturbation vs ISO%, size=position, color=VR')
 xlabel('ISO%'); ylabel('Perturbation');colorbar
saveas(figure(1),[pwd '/Boo_plots/Perturbation_ISO.png']);

figure (2)
 scatter(clvd,ipert,ipos2,var) 
 title('Perturbation vs CLVD%, size=position, color=VR')
 xlabel('CLVD%'); ylabel('Perturbation'); colorbar
saveas(figure(2),[pwd '/Boo_plots/Perturbation_CLVD.png']);

figure (3)
 scatter(vol,var,[],ipos) % [](size) is free for some parameter
 title('Variance reduction vs ISO%, color=position')
 xlabel('ISO%'); ylabel('VR');colorbar
saveas(figure(3),[pwd '/Boo_plots/VR_ISO.png']);
  
figure (4)
 scatter(clvd,var,[],ipos) 
 title('Variance reduction vs CLVD%, color=position')
 xlabel('CLVD%'); ylabel('VR');colorbar
saveas(figure (4),[pwd '/Boo_plots/VR_CLVD.png']);

figure (5)%('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
 scatter(vol,ipos,[],var) 
 title('Position vs ISO%, color=VR')
 xlabel('ISO%'); ylabel('Position (point no.)');colorbar
saveas(figure (5),[pwd '/Boo_plots/Position_ISO.png']);

figure (101)%('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
 scatter(clvd,ipos,[],clvd) 
 title('Position vs CLVD%, color=VR')
 xlabel('CLVD%'); ylabel('Position (point no.)');colorbar
saveas(figure (101),[pwd '/Boo_plots/Position_CLVD.png']);

figure (6)
 histogram(vol)
 title('Histogram of ISO%')
hold 
%medval = median(vol)
%%ci = bootci(1000, @median, vol) %ci =confidence inetval; a vector of the CI limits
%medval = quantile(vol,.50); % the median of x
% pd = fitdist(vol,'Normal') % prolozi VOL gaussem spocet mu a sigma
% ci = paramci(pd)         % spocete std od mu (sloupec 1) a std od sigma (sloupec 2)
%%qu = quantile(vol,[.25 .50 .75]) % result in row vector qu; qu(2) is median
%%qu = quantile(vol,[.025 .25 .50 .75 .975])
qu = quantile(vol,[.0228 .1587 .50 .8413 .9772]); % 2 and 1 sigmas
xline(qu(3), 'r') % median
yy=ylim; % current limit of y-axis
plot([qu(1) qu(1)],[yy(1) yy(2)],'g')
plot([qu(5) qu(5)],[yy(1) yy(2)],'g')
plot([qu(2) qu(2)],[yy(1) yy(2)],'b')
plot([qu(4) qu(4)],[yy(1) yy(2)],'b')
saveas(figure (6),[pwd '/Boo_plots/Histogram_ISO.png']);
%fprintf(fid2,'%6s %','ISO');
%fprintf(fid2, '%6.0f %6.0f %6.0f', qu(2),qu(3),qu(4));

figure (7)
 histogram(clvd)
 title('Histogram of CLVD%')
hold 
qu = quantile(clvd,[.0228 .1587 .50 .8413 .9772]); % 2 and 1 sigmas
xline(qu(3), 'r') % median
yy=ylim; % current limit of y-axis
plot([qu(1) qu(1)],[yy(1) yy(2)],'g')
plot([qu(5) qu(5)],[yy(1) yy(2)],'g')
plot([qu(2) qu(2)],[yy(1) yy(2)],'b')
plot([qu(4) qu(4)],[yy(1) yy(2)],'b')
saveas(figure (7),[pwd '/Boo_plots/Histogram_CLVD.png']);
%fprintf(fid2,'%6s %','CLVD');
%fprintf(fid2, '%6.0f %6.0f %6.0f', qu(2),qu(3),qu(4));  
 
figure (8)
 histogram(ipos)
 title('Histogram of position (point no.)')
hold 
qu = quantile(ipos,[.0228 .1587 .50 .8413 .9772]); % 2 and 1 sigmas
xline(qu(3), 'r') % median
yy=ylim; % current limit of y-axis
plot([qu(1) qu(1)],[yy(1) yy(2)],'g')
plot([qu(5) qu(5)],[yy(1) yy(2)],'g')
plot([qu(2) qu(2)],[yy(1) yy(2)],'b')
plot([qu(4) qu(4)],[yy(1) yy(2)],'b')
saveas(figure (8),[pwd '/Boo_plots/Histogram_position.png']);
 
figure (9)
 histogram(itim)
 title('Histogram of time (in steps dt)')
hold 
qu = quantile(itim,[.0228 .1587 .50 .8413 .9772]); % 2 and 1 sigmas
xline(qu(3), 'r') % median
yy=ylim; % current limit of y-axis
plot([qu(1) qu(1)],[yy(1) yy(2)],'g')
plot([qu(5) qu(5)],[yy(1) yy(2)],'g')
plot([qu(2) qu(2)],[yy(1) yy(2)],'b')
plot([qu(4) qu(4)],[yy(1) yy(2)],'b')
saveas(figure (9),[pwd '/Boo_plots/Histogram_time(dt).png']);

figure (10)
 scatter(vol,clvd,ipos2,var) 
 title('CLVD% vs ISO%, size=position,color=VR')
 xlabel('ISO%'); ylabel('CLVD%');colorbar
saveas(figure (10),[pwd '/Boo_plots/CLVD_ISO.png']);


%my_hudson_post
%saveas(figure (11),[pwd '/Boo_plots/Hudson.png']);

% figure (10)
% scatter3(itim,ipos,vol,var) 
% saveas(figure (10),[pwd '/Boo_plots/ISO3D.png']);

