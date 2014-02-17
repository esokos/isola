function result=plotjackres_stations(strref,dipref,rakeref)
% this function plots the jacknife results

disp(['Reference mechanism: Strike ' num2str(strref) ' Dip ' num2str(dipref)  ' Rake  ' num2str(rakeref)]) 
%% find number of stations
h=dir('stations.isl'); 

if isempty(h); 
  errordlg('stations.isl file doesn''t exist. Run station select. ','File Error');
  return
else
  [fid,message] = fopen('stations.isl','r'); 
  nstations=fscanf(fid,'%u',1);
  fclose(fid);
end

%% old part 
h=dir('.\invert\allstat.dat');
  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
  else
  end
  
cd invert
  
% open allstat new version only 
           [S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
%   
  cd jackresults  %% we need to check about this..!!
  
fid1 = fopen('allinv2.dat','w');

% prepare filenames and open files
% read inv2 files 
for i=1:nstations
    
  if d1(i)~=0  % station is not disabled
    
       alstname=['inv2_no_' S{i} '.dat'];
     
       fid = fopen(alstname,'r');
%          [srcpos2(i),srctime2(i),mo(i),str1(i),dip1(i),rake1(i),str2(i),dip2(i),rake2(i),aziP(i),plungeP(i),aziT(i),plungeT(i),aziB(i),plungeB(i),dc(i),varred(i)] = textread(alstname,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
           linetmp=fgetl(fid);  
           fprintf(fid1,'%s %s\r\n',linetmp,alstname(6:end));
       fclose(fid);
  else
           
  disp(['Skipped station ' S{i}])
  nstations=nstations-1;       
  end
  
end

fclose(fid1);


%%  read all inv2 files and put in one then read and plot this
% read the file 
%    
fid = fopen('allinv2.dat','r');
% inv2 file details 
% srcpos,srctime,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred,jakcname
%   1      2      3   4   5     6    7     8    9    10    11     12    13     14     15  16    17      18 
      C=textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s',-1);
fclose(fid);

% change names
str1=C{4};dip1=C{5};rake1=C{6};srcpos2=C{1};srctime2=C{2};dc=C{16};str2=C{7};dip2=C{8};rake2=C{9};aziP=C{10};plungeP=C{11};aziT=C{12};plungeT=C{13};

% Calculate Kagan based on best solution
% strref,dipref,rakeref
alld=[str1';  dip1';  rake1'];
fid=fopen('corrselect.dat','w');

 fprintf(fid,'%f %f %f\r\n',strref,dipref,rakeref);
 fprintf(fid,'%f %f %f\r\n',alld);
  
fclose(fid);

% call fortran code
   [status, result] = system('corr_kag');
% read the output

if status ==0 
    pause(2)
    kag=load('kagselect.dat');
%      % plot histogram
%     figure
%     subplot(1,2,1)
%     hist(kag)  
%     
%     tsvar_mean=mean(kag);
%     tsvar_std = std(kag);
%     tsvar_median=median(kag);
%     
%     t=char(['\fontsize{12}Kagan angle for reference solution STR = ' num2str(strref) ' DIP = ' num2str(dipref) ' RAKE = ' num2str(rakeref)],...
%         [' Mean = ' num2str(tsvar_mean) ' STD = ' num2str(tsvar_std) ' Median = ' num2str(tsvar_median) ' Var = ' num2str(var(kag))],...
%         ['\fontsize{12}\color{red}FMVAR = ' num2str(round(tsvar_std));] );
%     
%     FSTVAR=fix(tsvar_std);
%     
%     xlabel('Kagan angle')
%     ylabel('Count')
%     ht=title(t);
%      
%   %  set(ht, 'FontSize', 12);
%      
%     y = skewness(kag,1);
%     y = skewness(kag,0);
%     y = kurtosis(kag,1);
%     y = kurtosis(kag,0);
%     y=var(kag);
% %    y=var(kag,1)
%     
% %    indx=y/cor
% %title(['\fontsize{16}black {\color{magenta}magenta '...
% %'\color[rgb]{0 .5 .5}teal \color{red}red} black again'])     
else
    disp('Error....')
end

figure

%% Plot solutions
subplot(2,4,1)
 hist([str1;str2],36)
 title('Strike')
 xlabel('Degrees')
 ylabel('Count')
 xlim([0 360]) 
 
subplot(2,4,2)
 hist([dip1;dip2],18)
 title('Dip')
 xlabel('Degrees')
 ylabel('Count')
 xlim([0 90]) 
 
subplot(2,4,3)
 hist([rake1;rake2],36)
 title('Rake')
 xlabel('Degrees')
 ylabel('Count')
 xlim([-180 180]) 
 
subplot(2,4,4)
 hist(srcpos2)
 title('Source Position')
 xlabel('Source Position')
 ylabel('Count')
 
subplot(2,4,5)
 hist(srctime2)
 title('Source Time')
 xlabel('Time (Sec)')
 ylabel('Count')

subplot(2,4,6)
 hist(dc)
 title('DC%')
 ylabel('Count')


subplot(2,4,7)
 Stereonet(0,90*pi/180,1000*pi/180,1);
 hold
 for i=1:nstations
     path = GreatCircle(deg2rad(str1(i)),deg2rad(dip1(i)),1);
 plot(path(:,1),path(:,2),'k-')
     %Plot P axis (black, filled circle)
      [xp,yp] = StCoordLine(deg2rad(aziP(i)),deg2rad(plungeP(i)),1);
      text(xp,yp,'P','FontSize',8,'HorizontalAlignment','center','BackgroundColor','red')

     path = GreatCircle(deg2rad(str2(i)),deg2rad(dip2(i)),1);
 plot(path(:,1),path(:,2),'k-')
 
    %Plot T axis (black, filled circle)
      [xp,yp] = StCoordLine(deg2rad(aziT(i)),deg2rad(plungeT(i)),1);
      text(xp,yp,'T','FontSize',8,'HorizontalAlignment','center','BackgroundColor','blue')
      
 end
 
  title('Nodal Lines')
 
subplot(2,4,8)
 hist(kag)  
 title('Kagan Angle')
 ylabel('Count')
 xlabel('Kagan Angle')
 

  cd .. % out of jackresults
  
  
cd ..  % out of invert 
