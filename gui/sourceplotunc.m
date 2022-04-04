function ok = sourceplotunc

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
           C=textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f  %f %f %f  %f %f','HeaderLines',1);
         fclose(fid);
    cd ..
end

%% prepare the MT
alpha=[C{:,6} C{:,7} C{:,8} C{:,9} C{:,10} C{:,11}];

%% plot
figure
a=[0.00,1.00; -1.33,-0.328; 0.00,-1.00;1.33,0.328;0.00,1.00];
b=[-1.33,-0.328;1.33,0.328;0.00,1;1.00,0.25;0.00,-1;0.00,1;0.79,0.19;0.00,-1.00;0.00,1;0.52,0.12;0.00,-1;0.26,0.06;0.00,1;-0.00,1;-0.26,-0.06;-0.00,-1;-0.00,1;-0.52,-0.13;
   -0.00,-1; -0.00,1;-0.79,-0.19;0,-1;0.00,1;-1.00,-0.26;0.00,-1];

plot(a(:,1),a(:,2))
hold on
text(0,1.1,'+ISO');text(0,-1.1,'-ISO');text(0.02,-0.02,'DC')
text(-1,0,'+CLVD','HorizontalAlignment','right');text(1,0,'-CLVD'); 
text(-0.445,0.558,'+TC','HorizontalAlignment','right');text(-0.663,0.337,'+LVD','HorizontalAlignment','right'); 
text(0.445,-0.558,'-TC','HorizontalAlignment','left');text(0.663,-0.337,'-LVD','HorizontalAlignment','left'); 


plot(b(:,1),b(:,2))
axis square;grid on

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