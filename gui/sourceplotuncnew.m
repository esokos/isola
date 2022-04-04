function ok = sourceplotuncnew

%% check if CLVD_ISO_DC_Mo_MW_eq6.dat  exists

h=dir('.\newunc\CLVD_ISO_DC_Mo_MW_eq6.dat');

if isempty(h); 
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
hudsonnet(1,1,1)

%% loop 
for ii=1:length(alpha)
   
   MT=[-alpha(ii,4)+alpha(ii,6) alpha(ii,1) alpha(ii,2);alpha(ii,1) -alpha(ii,5)+alpha(ii,6)   -alpha(ii,3);  alpha(ii,2) -alpha(ii,3) alpha(ii,4)+alpha(ii,5)+alpha(ii,6)]
   [~,L] = eigsort(MT);
   M1 = L(1,1); M2 = L(2,2);  M3 = L(3,3);
%% plot
AXYa=SourceType([M1 M2 M3],'Cubic',0,0);
plot(AXYa(:,2),AXYa(:,3),'ro','MarkerSize',2)
  
end
hold off
 
ok=1;