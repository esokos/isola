function ok = sourceplot(nsources,subevent_needed)

% this function will produce a source plot based on inv1.dat
% it is using code from...

%% check if inv1.dat exists

h=dir('.\invert\inv1.dat');

if isempty(h); 
    errordlg('inv1.dat file doesn''t exist. Run Invert. ','File Error');
    cd ..
  return    
else
    cd invert
         [~,~,alpha,sigma_alphas,inv1_mom,~,inv1_vol,inv1_dc,inv1_clvd,inv1_sdr1,inv1_sdr2,~]=readinv1_with_as(nsources,subevent_needed);
    cd ..
end



%% prepare the MT 

MT=[-alpha(4)+alpha(6) alpha(1) alpha(2);alpha(1) -alpha(5)+alpha(6)   -alpha(3);  alpha(2) -alpha(3) alpha(4)+alpha(5)+alpha(6)]

% scaling of the tensor Mij
% 
% amt=sqrt(.5*(MT(1,1)*MT(1,1)+MT(2,2)*MT(2,2)+MT(3,3)*MT(3,3))+MT(1,2)*MT(1,2)+MT(1,3)*MT(1,3)+MT(2,3)*MT(2,3));
% facm=1./amt/sqrt(2.);
% 
% MT2=MT.*facm;
% MT2

% sorted eigenvalues 
    
     [~,L] = eigsort(MT);

     M1 = L(1,1); M2 = L(2,2);  M3 = L(3,3);
[M1 M2 M3]

%% plot
AXYa=SourceType([M1 M2 M3],'Cubic',0,0);
plot(AXYa(:,2),AXYa(:,3),'r.','MarkerSize',30)
 
hold on

a=[0.00,1.00; 
  -1.33,-0.328;
   0.00,-1.00;
   1.33,0.328;
   0.00,1.00];

b=[-1.33  ,    -0.328;
    1.33    ,   0.328;
    0.00    ,   1;
    1.00    ,   0.25;
    0.00    ,  -1;
    0.00    ,   1;
    0.79    ,   0.19;
    0.00    ,  -1.00;
    0       ,   1;
    0.52    ,   0.12;
    0       ,  -1;
    0.26    ,   0.06;
    0.00    ,   1;
   -0.00    ,   1;
   -0.26    ,  -0.06;
   -0.00    ,  -1;
   -0.00    ,   1;
   -0.52    ,  -0.13;
   -0.00    ,  -1;
   -0.00    ,   1;
   -0.79    ,  -0.19;
    0       ,  -1;
   -0.00    ,   1;
   -1.00    ,  -0.26;
   -0.00    ,  -1 ];



plot(a(:,1),a(:,2))
plot(b(:,1),b(:,2))
axis square

grid on

hold off










     
     
