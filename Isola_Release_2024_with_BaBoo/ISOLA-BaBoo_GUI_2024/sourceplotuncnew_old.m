function ok = sourceplotuncnew
%% Modification to plot symbols colored according tou trial source position 
% 15/08/2024

%% find how many trial sources we have
% 
if ispc
         fid = fopen('.\invert\inpinv.dat','r');
            linetmp1=fgetl(fid);         %01 line
            linetmp2=fgetl(fid);        %02 line
            linetmp3=fgetl(fid);          %03 line
            linetmp4=fgetl(fid);         %04 line
            linetmp5=fgetl(fid);          %05 line
            linetmp6=fgetl(fid);          %06 line
            linetmp7=fgetl(fid);          %07 line
            linetmp8=fgetl(fid);          %08 line
            linetmp9=fgetl(fid);          %09 line
            linetmp10=fgetl(fid);          %10 line
            linetmp11=fgetl(fid);          %11 line
            linetmp12=fgetl(fid);          %12 line
            linetmp13=fgetl(fid);           %13 line
            linetmp14=fgetl(fid);          %14 line
            linetmp15=fgetl(fid);         %15 line
            linetmp16=fgetl(fid);         %16 line
       fclose(fid);
else
         fid = fopen('./invert/inpinv.dat','r');
            linetmp1=fgetl(fid);         %01 line
            linetmp2=fgetl(fid);         %02 line
            linetmp3=fgetl(fid);          %03 line
            linetmp4=fgetl(fid);         %04 line
            linetmp5=fgetl(fid);          %05 line
            linetmp6=fgetl(fid);          %06 line
            linetmp7=fgetl(fid);          %07 line
            linetmp8=fgetl(fid);          %08 line
            linetmp9=fgetl(fid);          %09 line
            linetmp10=fgetl(fid);          %10 line
            linetmp11=fgetl(fid);          %11 line
            linetmp12=fgetl(fid);          %12 line
            linetmp13=fgetl(fid);           %13 line
            linetmp14=fgetl(fid);          %14 line
            linetmp15=fgetl(fid);         %15 line
            linetmp16=fgetl(fid);         %16 line
       fclose(fid);
end

nsources=str2num(linetmp6);

disp(['Found  ' linetmp6  '  trial sources.'])

%% now read from newunc_log.dat 
h=dir('.\newunc\newunc_log.dat');

if isempty(h)
    errordlg('newunc_log.dat file doesn''t exist. Run Uncertainty code. ','File Error');
    cd ..
  return    
else
    cd newunc
         % read the file
         fid = fopen('newunc_log.dat','r');
           C1=textscan(fid,'%f %f','HeaderLines',nsources+1);
         fclose(fid);
    cd ..
end

samples=C1{2}; % these are the samples per trial source

%% check if CLVD_ISO_DC_Mo_MW_eq6.dat  exists

h=dir('.\newunc\CLVD_ISO_DC_Mo_MW_eq6.dat');

if isempty(h)
    errordlg('CLVD_ISO_DC_Mo_MW_eq6.dat file doesn''t exist. Run Uncertainty code. ','File Error');
    cd ..
  return    
else
    cd newunc
         % read the file
         fid = fopen('CLVD_ISO_DC_Mo_MW_eq6.dat','r');
           C=textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f  %f %f %f  %f %f %f  %f %f','HeaderLines',1);
         fclose(fid);
    cd ..
end

%% prepare the MT
alpha=[C{:,6} C{:,7} C{:,8} C{:,9} C{:,10} C{:,11}];

%% plot the net first 
fsourceplot=hudsonnet(1,1,1);


%% loop over number of trial sources
cumsamples=[1;cumsum(samples)]

for ii=1:nsources
  if ii==1
     alpha_depth{ii}=[C{6}(cumsamples(ii):cumsamples(ii+1)) C{7}(cumsamples(ii):cumsamples(ii+1)) C{8}(cumsamples(ii):cumsamples(ii+1)) C{9}(cumsamples(ii):cumsamples(ii+1)) C{10}(cumsamples(ii):cumsamples(ii+1)) C{11}(cumsamples(ii):cumsamples(ii+1))];
  else
     alpha_depth{ii}=[C{6}(cumsamples(ii)+1:cumsamples(ii+1)) C{7}(cumsamples(ii)+1:cumsamples(ii+1)) C{8}(cumsamples(ii)+1:cumsamples(ii+1)) C{9}(cumsamples(ii)+1:cumsamples(ii+1)) C{10}(cumsamples(ii)+1:cumsamples(ii+1)) C{11}(cumsamples(ii)+1:cumsamples(ii+1))];
  end
end

%% New plot with trial source
% color scale 
% jet colors
CC = jet(nsources);
colormap(CC);

hwaitbar = waitbar(0,'Please wait...','Name','Calculating');

for kk=1:nsources
   
  alpha2=alpha_depth{1,kk}; % select trial source

   for ii=1:length(alpha_depth{kk})
     %MT=[-alpha_depth(ii,4)+alpha_depth(ii,6) alpha_depth(ii,1) alpha_depth(ii,2);alpha_depth(ii,1) -alpha_depth(ii,5)+alpha_depth(ii,6)   -alpha_depth(ii,3);  alpha_depth(ii,2) -alpha_depth(ii,3) alpha_depth(ii,4)+alpha_depth(ii,5)+alpha_depth(ii,6)];
     MT=[-alpha2(ii,4)+alpha2(ii,6) alpha2(ii,1) alpha2(ii,2);alpha2(ii,1) -alpha2(ii,5)+alpha2(ii,6)   -alpha2(ii,3);  alpha2(ii,2) -alpha2(ii,3) alpha2(ii,4)+alpha2(ii,5)+alpha2(ii,6)];
     [~,L] = eigsort(MT);
     M1 = L(1,1); M2 = L(2,2);  M3 = L(3,3);
     
     %% plot
     AXYa=SourceType([M1 M2 M3],'Cubic',0,0);
     set(0,"CurrentFigure",fsourceplot);
     scatter(AXYa(:,2),AXYa(:,3),2,CC(kk,:),'Marker','o')
   end
   set(0, 'CurrentFigure', hwaitbar); 
   waitbar(kk/nsources,hwaitbar,['Plotted trial source ' num2str(kk)  ]);

end

set(0,"CurrentFigure",fsourceplot);
cb = colorbar;
cbscalein = cb.Limits
cbscaleout = [1 nsources];

ticks = linspace(cbscaleout(1),cbscaleout(2),nsources);
cb.Ticks = diff(cbscalein)*(ticks-cbscaleout(1))/diff(cbscaleout) + cbscalein(1);
cb.TickLabels = 1:nsources;


% AxesH = axes('CLim', [1, nsources]);
% cbh = colorbar('target', AxesH, 'v', ...
%                'XTickLabel', cellstr(string(1:nsources)), ...
%                'XTick', 1:nsources)

%('Ticks',linspace(0,1,nsources-1),'TickLabels',num2cell(1:nsources-1))   %cat(1, cellstr(string(1:nsources))));


close(hwaitbar)


fsourceplot2=hudsonnet(1,1,1);

%% loop 
for ii=1:length(alpha)
   
   MT=[-alpha(ii,4)+alpha(ii,6) alpha(ii,1) alpha(ii,2);alpha(ii,1) -alpha(ii,5)+alpha(ii,6)   -alpha(ii,3);  alpha(ii,2) -alpha(ii,3) alpha(ii,4)+alpha(ii,5)+alpha(ii,6)];
   [~,L] = eigsort(MT);
   M1 = L(1,1); M2 = L(2,2);  M3 = L(3,3);
%% plot
AXYa=SourceType([M1 M2 M3],'Cubic',0,0);
plot(AXYa(:,2),AXYa(:,3),'ro','MarkerSize',2)
  
end
hold off

ok=1;