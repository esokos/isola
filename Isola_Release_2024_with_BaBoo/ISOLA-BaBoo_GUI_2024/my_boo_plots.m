function [] = my_boo_plots

%JZ 2025 using codes of VV
close all
clear all

 
fid2=fopen('Median_MT.dat', 'w');
%fid3=fopen('median_others.dat', 'w');
%fid4=fopen('confidence.dat','w');

% h=dir('CLVDetcPOST.dat');   
% if isempty(h)
%     errordlg('CLVDetcPOST.dat file doesn''t exist. Run Uncertainty code. ','File Error');
%     cd ..
%   return    
% else
         % read the file
         fid = fopen('CLVDetcPOST.dat','r');        
%        fid = fopen('CLVDetcPOST_BEST.dat','r');     

         A= textscan(fid,'%u %u %d %f %f %f %f %f %f %f %f %f');
           fclose(fid);

           ipert=A{1};ipos=A{2};itim=A{3};clvd=A{4};vol=A{5};var=A{12};
            size(ipert);
            size(var);
          
          a1=A{6};a2=A{7};a3=A{8};a4=A{9};a5=A{10};a6=A{11};             
          meda1 = median(a1);meda2 = median(a2);meda3 = median(a3);
          meda4 = median(a4);meda5 = median(a5);meda6 = median(a6);

          
alpha=[A{:,6} A{:,7} A{:,8} A{:,9} A{:,10} A{:,11}];
nnn=size(alpha,1);
alpha(nnn+1,1)=meda1;alpha(nnn+1,2)=meda2;alpha(nnn+1,3)=meda3;
alpha(nnn+1,4)=meda4;alpha(nnn+1,5)=meda5;alpha(nnn+1,6)=meda6;
% beta= [A{:,2}];
% nsources=20;   % NEW ?????? should be read as paramter of the function
% CC = jet(nsources);
% colormap(CC);
%% plot the net first 
hudsonnet(1,1,1);

%% loop 
MTsave=[];
for ii=1:nnn+1 % size(alpha,1)+1 % length(alpha)
% MT Cartesian x,y,z   
   MT=[-alpha(ii,4)+alpha(ii,6) alpha(ii,1) alpha(ii,2);alpha(ii,1) -alpha(ii,5)+alpha(ii,6)   -alpha(ii,3);  alpha(ii,2) -alpha(ii,3) alpha(ii,4)+alpha(ii,5)+alpha(ii,6)];
   [~,L] = eigsort(MT);
   M1 = L(1,1); M2 = L(2,2);  M3 = L(3,3);
%% plot
AXYa=SourceType([M1 M2 M3],'Cubic',0,0);             % Hudson
 if(ii~=nnn+1)  
 plot(AXYa(:,2),AXYa(:,3),'go','MarkerSize',2)
 else 
 plot(AXYa(:,2),AXYa(:,3),'go','MarkerSize',20,'MarkerEdgeColor','b')  %median MT
 MTm=MT;     %median MT
 end
%scatter(AXYa(:,2),AXYa(:,3),2,CC(kk,:),'Marker','o')
%sccatter(AXYa(:,2),AXYa(:,3),2,CC(beta(ii),:),'Marker','o')
% colorscale

%JZ new added also in the loop over MTs

      MTsave=cat(3,MTsave,MT);
 
end % end of loop over all MTs
saveas(figure (1),[pwd '/Boo_plots/Hudson.png']);       





% Processing MEDIAN  MT tohle bude jen pro posledni krok cyklu kde se pocita prumerny mech
     amorr=MTm(3,3); %amozz
     amott=MTm(1,1); %amoxx   
     amopp=MTm(2,2); %amoyy
     amort=MTm(1,3); %amoxz
     amorp=-1.*MTm(2,3); %amoyz
     amotp=-1.*MTm(1,2); %amoxy
 AA=[amorr,amott,amopp,amort, amorp, amotp];        %Harvard
 Mo=sqrt(amorr^2+amott^2+amopp^2+ 2*amort^2+ 2*amorp^2+ 2*amotp^2)/sqrt(2);

 fprintf(fid2,'%6s %','Mrr');
 fprintf(fid2,'%6s %','Mtt');
 fprintf(fid2,'%6s %','Mpp');
 fprintf(fid2,'%6s %','Mrt');
 fprintf(fid2,'%6s %','Mrp');
 fprintf(fid2,'%6s %','Mtp');
 fprintf(fid2,'\n');
 fprintf(fid2, '%+.6e %+.6e %+.6e %+.6e %+.6e %+.6e ', AA(1),AA(2),AA(3),AA(4),AA(5),AA(6)) ;
 fprintf(fid2,'\n');
 fprintf(fid2,'%6s %','Mo');
 fprintf(fid2,'\n');
 fprintf(fid2, '%+.6e ', Mo);
 fprintf(fid2,'\n');
 %fclose(fid2);
 %copyfile median_MTharvard.dat '.\boo_plots'

 
%convert to Catresian x=1(N),y=2(E),z=3(down)  Aki and Richards
    moment_11= amott; 
    moment_12= -1*amotp;
    moment_13= amort;
    moment_22= amopp;
    moment_23= -1*amorp;
    moment_33= amorr;

 
 m=[moment_11,moment_12,moment_13;...
       moment_12,moment_22,moment_23;...
       moment_13,moment_23,moment_33];       % median MT

     
    angles_all(1,:) = angles(m);
    
    strike_m = angles_all(1,1);     %in degrees for median MT
    dip_m    = angles_all(1,2);
    rake_m   = angles_all(1,3);

  figure (14); hold on; axis equal; axis off;
  title('Full MT (median) beachball')
  shadowing(m) 
  % boundary circle;
    Fi=0:0.1:361;
    plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k','LineWidth',1.5)
% denoting the North direction
    plot([0 0], [1 1.07],'k','LineWidth',1.5);
    text(-0.035, 1.15,'N','FontSize',14);
    nodal_lines_(strike_m, dip_m, rake_m);
    P_T_axes_(strike_m, dip_m, rake_m);
  saveas(figure (14),[pwd '/Boo_plots/Beachball_fullMT.png']); 


    
     M_values = eig(m); % for median MT
     M1 = M_values(3);
     M2 = M_values(2);
     M3 = M_values(1);

    iso_  = 1/3*(M1+M2+M3);
    clvd_ = 2/3*(M1+M3-2*M2);
    dc_   = 1/2*(M1-M3-abs(M1+M3-2*M2));

    s = 1/3*abs(M1+M2+M3)+2/3*abs(M1+M3-2*M2)+1/2*(M1-M3-abs(M1+M3-2*M2));
    isoF  = iso_ /s  .* 100;       %    "F" to avoid confusion with VECTOR iso
    clvdF = clvd_/s  .* 100;
    dcF   = dc_  /s  .* 100;

    Mo_m=sqrt(M1^2+M2^2+M3^2)/sqrt(2);
    Mw_m=(2/3)*log10(Mo)-6.03;

fprintf(fid2,'%6s %','ISO');
fprintf(fid2,'%6s %','CLVD');
fprintf(fid2,'%6s %','DC');
fprintf(fid2,'%6s %','strike');
fprintf(fid2,'%6s %','dip');
fprintf(fid2,'%6s %','rake');
fprintf(fid2,'%6s %','Mw');
fprintf(fid2,'%6s %','Mo');
fprintf(fid2,'\n');
%fprintf(fid2, '%6.0f ', ii);
fprintf(fid2, '%6.0f ', isoF);
fprintf(fid2, '%6.0f ', clvdF);
fprintf(fid2, '%6.0f ', dcF);
fprintf(fid2, '%6.0f ', strike_m);
fprintf(fid2, '%6.0f ', dip_m);
fprintf(fid2, '%6.0f ', rake_m);
fprintf(fid2, '%6.2f ', Mw_m);
fprintf(fid2, '%+.6e ', Mo_m);
fprintf(fid2,'\n');
% copyfile Median_MT.dat '.\boo_plots'
% fclose(fid2);




ipos2=ipos .^2 .*5; % ?why this?


 figure (11)
 scatter(vol,ipert,ipos2,var) 
 title('Perturbation vs ISO%, size=position, color=VR')
  xlabel('ISO%'); ylabel('Perturbation');colorbar
  xlim([-100 100])
saveas(figure(11),[pwd '/Boo_plots/Perturbation_ISO.png']);



 figure (2)
 scatter(clvd,ipert,ipos2,var) 
 title('Perturbation vs CLVD%, size=position, color=VR')
  xlabel('CLVD%'); ylabel('Perturbation'); colorbar
  xlim([-100 100])
saveas(figure(2),[pwd '/Boo_plots/Perturbation_CLVD.png']);


figure (3)
scatter(vol,var,[],ipos) % [](size) is free for some parameter
title('Variance reduction vs ISO%, color=position')
 xlabel('ISO%'); ylabel('VR');colorbar
 xlim([-100 100])
saveas(figure(3),[pwd '/Boo_plots/VR_ISO.png']);
  
figure (4)
scatter(clvd,var,[],ipos) 
title('Variance reduction vs CLVD%, color=position')
 xlabel('CLVD%'); ylabel('VR');colorbar
 xlim([-100 100])
saveas(figure (4),[pwd '/Boo_plots/VR_CLVD.png']);

 figure (5)%('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
 scatter(vol,ipos,[],var) 
 title('Position vs ISO%, color=VR')
 xlabel('ISO%'); ylabel('Position (point no.)');colorbar
 xlim([-100 100])
saveas(figure (5),[pwd '/Boo_plots/Position_ISO.png']);

 figure (12)%('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
 scatter(clvd,ipos,[],var) 
 title('Position vs CLVD%, color=VR')
 xlabel('CLVD%'); ylabel('Position (point no.)');colorbar
 xlim([-100 100])
saveas(figure (12),[pwd '/Boo_plots/Position_CLVD.png']);


 figure (6)
  histogram(vol)
 xlim([-100 100])
 title('Histogram of ISO%')
hold 
%medval = median(vol)
%%ci = bootci(1000, @median, vol) %ci =confidence interval; a vector of the CI limits
%medval = quantile(vol,.50); % the median of x
% pd = fitdist(vol,'Normal') % prolozi VOL gaussem spocet mu a sigma
% ci = paramci(pd)         % spocete std od mu (sloupec 1) a std od sigma (sloupec 2)
%%qu = quantile(vol,[.25 .50 .75]) % result in row vector qu; qu(2) is median
%%qu = quantile(vol,[.025 .25 .50 .75 .975])
qu = quantile(vol,[.0228 .1587 .50 .8413 .9772]) % 2 and 1 sigmas 68,26% and 95,44%
xline(qu(3), 'r') % median
yy=ylim; % current limit of y-axis
plot([qu(1) qu(1)],[yy(1) yy(2)],'g')
plot([qu(5) qu(5)],[yy(1) yy(2)],'g')
plot([qu(2) qu(2)],[yy(1) yy(2)],'b')
plot([qu(4) qu(4)],[yy(1) yy(2)],'b')
saveas(figure (6),[pwd '/Boo_plots/Histogram_ISO.png']);

fprintf(fid2,'%15s %','Confidences');
fprintf(fid2,'\n');
fprintf(fid2,'%6s %','ISO');
fprintf(fid2, '%6.0f %6.0f %6.0f', qu(2),qu(3),qu(4));

 figure (7)
 histogram(clvd)
  xlim([-100 100])
  title('Histogram of CLVD%')
hold 
qu = quantile(clvd,[.0228 .1587 .50 .8413 .9772]) % 2 and 1 sigmas
xline(qu(3), 'r') % median
yy=ylim; % current limit of y-axis
plot([qu(1) qu(1)],[yy(1) yy(2)],'g')
plot([qu(5) qu(5)],[yy(1) yy(2)],'g')
plot([qu(2) qu(2)],[yy(1) yy(2)],'b')
plot([qu(4) qu(4)],[yy(1) yy(2)],'b')
saveas(figure (7),[pwd '/Boo_plots/Histogram_CLVD.png']);

fprintf(fid2,'%6s %','CLVD');
fprintf(fid2, '%6.0f %6.0f %6.0f', qu(2),qu(3),qu(4));  
 
 figure (8)
 histogram(ipos)
  title('Histogram of position (point no.)')
hold 
qu = quantile(ipos,[.0228 .1587 .50 .8413 .9772]) % 2 and 1 sigmas
xline(qu(3), 'r') % median
yy=ylim; % current limit of y-axis
plot([qu(1) qu(1)],[yy(1) yy(2)],'g')
plot([qu(5) qu(5)],[yy(1) yy(2)],'g')
plot([qu(2) qu(2)],[yy(1) yy(2)],'b')
plot([qu(4) qu(4)],[yy(1) yy(2)],'b')
saveas(figure (8),[pwd '/Boo_plots/Histogram_position.png']);
 
fprintf(fid2,'%6s %','ipos');
fprintf(fid2, '%6.0f %6.0f %6.0f', qu(2),qu(3),qu(4));  

 figure (9)
 histogram(itim)
 title('Histogram of time (in steps dt)')
hold 
qu = quantile(itim,[.0228 .1587 .50 .8413 .9772]) % 2 and 1 sigmas
xline(qu(3), 'r') % median
yy=ylim; % current limit of y-axis
plot([qu(1) qu(1)],[yy(1) yy(2)],'g')
plot([qu(5) qu(5)],[yy(1) yy(2)],'g')
plot([qu(2) qu(2)],[yy(1) yy(2)],'b')
plot([qu(4) qu(4)],[yy(1) yy(2)],'b')
saveas(figure (9),[pwd '/Boo_plots/Histogram_time(dt).png']);

fprintf(fid2,'%6s %','itim');
fprintf(fid2, '%6.0f %6.0f %6.0f', qu(2),qu(3),qu(4));  

 figure (10)
 scatter(vol,clvd,ipos2,var) 
 title('CLVD% vs ISO%, size=position,color=VR')
 xlabel('ISO%'); ylabel('CLVD%');colorbar
 xlim([-100 100]); ylim([-100 100])
saveas(figure (10),[pwd '/Boo_plots/CLVD_ISO.png']);


% Plotting nodal lines and P-T axes 
  figure (15); hold on; axis equal; axis off;
  title('P (red) and T (green) axes; blue is median')
  %shadowing(MTsave) 
  % boundary circle;
    Fi=0:0.1:361;
    plot(cos(Fi*pi/180.),sin(Fi*pi/180.),'k','LineWidth',1.5)
% denoting the North direction
%     plot([0 0], [1 1.07],'k','LineWidth',1.5);
%     text(-0.035, 1.15,'N','FontSize',14);
    for ii=1:nnn     
    angles_all(1,:) = angles(MTsave(:,:,ii)); % Mozna zde mozno znova nadefinovat MT pomoci acek bez nutnosti schovavani do poli
    strike (ii)= angles_all(1,1);     %in degrees
    dip (ii)   = angles_all(1,2);      % pokud tady neni (ii) tak lze volat P_T v ramci cyklu pro kazde zvlast
    rake (ii) = angles_all(1,3);                 % v tom pripade plati az to dolni zacekovane end
    [rotangle(ii),theta(ii),phi(ii)]=kagan([strike_m,dip_m,rake_m],[strike(ii),dip(ii),rake(ii)]); % P. Kolar 2025 Mathworks
    end
%   nodal_lines_(strike, dip, rake);
    P_T_axes_gui(strike, dip, rake); % many  strike is an array , dip is ...
        % here, in the loop, for every solution we can calculate Kagan relative to median (Matlab, Kolar 2025)
%    end
    P_T_axes_gui_blue(strike_m, dip_m, rake_m); % median
  saveas(figure (15),[pwd '/Boo_plots/P-T axes.png']); 
% Lze kreslit histogram striku,...
% V ramci P_T lze pociat take azimuth a plunge (jako vektory) a malovat
% jjich histogramy pro obe osy ( 1 reseni jsou DVE osy!)

figure (16)
 histogram(rotangle)
% xlim([0 120])
 title('Histogram of Kagan, MT relative to median MT')
median_kagan = median(rotangle)
xline(median_kagan, 'r') % median of Kagan
  saveas(figure (16),[pwd '/Boo_plots/Kagan.png']); 
fprintf(fid2,'\n');
fprintf(fid2,'%15s %','P-T uncertainty (deg)'); % Median of Kagan  
fprintf(fid2, '%10.1f', median_kagan);


% figure (17)
% histogram(dip)
% xlim([0 90])
% title('Histogram of dip ')

% figure (18)
% histogram(rake)
% xlim([-180, 180])
% title('Histogram of rake')

copyfile Median_MT.dat '.\boo_plots'
fclose(fid2);
copyfile isorandinp.inp '.\boo_plots'
copyfile inv111.dat  '.\boo_plots'
copyfile CLVDetc.dat '.\boo_plots'
copyfile CLVDetcPOST.dat '.\boo_plots'



