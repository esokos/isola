%strike1 = str2double(get(handles.strike,'String'));
%dip1 = str2double(get(handles.dip,'String'));
%rake1 = str2double(get(handles.rake,'String'));
%xmoment = str2double(get(handles.moment,'String'));

strike1=100;

dip1=45; 

rake1=-45; 

xmoment=2e17;


%%% call pl2pl to find second plane
[strike2,dip2,rake2] = pl2pl(strike1,dip1,rake1);

%% NEW CODE 
% read sigma.dat
    fid = fopen('sigma_5.dat');
     C = textscan(fid, '%f %f %f %f %f',5,'HeaderLines',12)
    fclose(fid);
%
C{1}
     [a1,a2,a3,a4,a5,a6]=sdr2as(strike1,dip1,rake1,xmoment*1e-20);  % scaling of moment..! scaling is used by Jiri in fortran
     A=[a1 a2 a3 a4 a5 ];
     sigma=cell2mat(C);
     r = mvnrnd(A,sigma,100);
     r=[r zeros(100,1)];
  
     
%% test
fid = fopen('sdr_r2.dat','w');
for i=1:100
   fprintf(fid,'%e %e %e %e %e %e\r\n',r(i,:));
end
fclose(fid);
%%
% convert to strike dip rake
  for i=1:100
      [str1(i),dp1(i),rk1(i),str2(i),dp2(i),rk2(i),adc_1(i),adc_2(i)] = silsubnew(r(i,:));
  end

% fid = fopen('sdr_r_M2.dat','w');
%  for i=1:100
%    fprintf(fid,'%8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f %8.1f\r\n',str1(i),dp1(i),rk1(i),str2(i),dp2(i),rk2(i),adc_1(i),adc_2(i));
%  end  
% fclose(fid);
  
A=[str1' dp1'  rk1'];B=[str2' dp2'  rk2'];
 
elipsa_max=make_el_max(A,B);

% plot histograms
plotstruncert(elipsa_max,strike1,strike2); plotdipuncert(elipsa_max,dip1,dip2); plotrakeuncert(elipsa_max,rake1,rake2);

%% PLOTTING
figure;
%hist(elipsa_max(:,4),10);
hist(adc_1,10);
title('DC%','FontSize',18)
ax=gca;
set(ax,'Linewidth',2,'FontSize',12)
%plotalluncert(elipsa_max,strike1,strike2,dip1,dip2,rake1,rake2);

%% plot sigma.dat
% read first 
% fid = fopen('.\uncertainty\sigma.dat');
% C = textscan(fid, '%f %f %f %f %f %f',6,'HeaderLines',13);
% fclose(fid);
% normalise to 1 based on diagonal elements
%C1=cell2mat(C)/max(max(cell2mat(C)));

C1=cell2mat(C)/max(diag(cell2mat(C)));
figure;imagesc(C1);colorbar
title('Covariance matrix','FontSize',14)
ax=gca;
set(ax,'Linewidth',2,'FontSize',12)

%%
% Pearson correlation coefficient
if ispc
    fid = fopen('sigma_5.dat');
     C = textscan(fid, '%f %f %f %f %f',5,'HeaderLines',19);
    fclose(fid);
else
    fid = fopen('./uncertainty/sigma.dat');
     C = textscan(fid, '%f %f %f %f %f %f',6,'HeaderLines',21);
    fclose(fid);
end

% fid = fopen('.\uncertainty\sigma.dat');
% C = textscan(fid, '%f %f %f %f %f %f',6,'HeaderLines',21);
% fclose(fid);

figure;imagesc(cell2mat(C));colorbar
title('Pearson correlation coefficient','FontSize',14)
ax=gca;
set(ax,'Linewidth',2,'FontSize',12)

%% Compute Kagan Angle

%whos
% prepare the corrselect.dat file
alld=[str1' dp1' rk1' str2' dp2' rk2']';

fid=fopen('corrselect.dat','w');
 fprintf(fid,'%f %f %f\r\n',strike1,dip1,rake1);
 fprintf(fid,'%f %f %f %f %f %f\r\n',alld);
fclose(fid);

% call fortran code
   [status, result] = system('corr_kag');
     if status~=0
         disp(' ')         
         disp('*********************************************************')
         disp(['Problem running corr_kag.exe. System report is.   '  result])
         disp('*********************************************************')
         disp(' ')         
     end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   FMVAR part 
if status ==0 
    pause(2)
    % read the output    
    kag=load('kagselect.dat');
else
    disp('Error....')
end
%%
mm=mean(kag);
stdata=std(kag);
med=median(kag);

 figure;hist(kag,10);
 title([ 'Kagan Angle, Mean= ' num2str(fix(mm)) '  Sd=  ' num2str(fix(stdata)) '  Median= ' num2str(fix(med))],'FontSize',14)
 ax=gca;
 set(ax,'Linewidth',2,'FontSize',12)



%% NODAL LINE PLOT
% New code
if ispc
   h=dir('corrselect.dat');
else
   h=dir('./uncertainty/corrselect.dat');
end
if isempty(h); 
         errordlg('corrselect.dat file doesn''t exist in uncertainty folder. Run the calculation and plot first. ','File Error');
     return
else
    disp('Found corrselect.dat')
end
%
if ispc
      fid = fopen('corrselect.dat','r');
        C = textscan(fid, '%f %f %f %f %f %f','HeaderLines',1);
      fclose(fid);
else
      fid = fopen('./uncertainty/corrselect.dat','r');
        C = textscan(fid, '%f %f %f %f %f %f','HeaderLines',1);
      fclose(fid);
end
%% PLOT
str1=C{1};
dip1=C{2};
str2=C{4};
dip2=C{5};
%
%% plot nodal lines
figure
Stereonet(0,90*pi/180,1000*pi/180,1);
v=axis;
xlim([v(1),v(2)]); ylim([v(3),v(4)]);  % static limits
hold

tic
 for i=1:length(str1)
     path = GreatCircle(deg2rad(str1(i)),deg2rad(dip1(i)),1);
     plot(path(:,1),path(:,2),'r-')
     path = GreatCircle(deg2rad(str2(i)),deg2rad(dip2(i)),1);
     plot(path(:,1),path(:,2),'r-')
 end
toc

