function result=plotjackres_stations(strref,dipref,rakeref)
% this function plots the jacknife results

disp('plotjackres_stations 11/12/2022')

disp(['Reference mechanism: Strike ' num2str(strref) ' Dip ' num2str(dipref)  ' Rake  ' num2str(rakeref)]) 
%% find number of stations
h=dir('stations.isl'); 

if isempty(h)
  errordlg('stations.isl file doesn''t exist. Run station select. ','File Error');
  return
else
  [fid,message] = fopen('stations.isl','r'); 
  nstations=fscanf(fid,'%u',1);
  fclose(fid);
end

%% old part 
h=dir('.\invert\allstat.dat');
  if isempty(h) 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
  else
  end



%%
cd invert
%% read how many subevents we have   

    [id,tstep,nsources,tshifts,nsub,freq,var] = readinpinv('inpinv.dat');

    q1=['Inversion was run with ' num2str(nsub) ' subevents. Select which one you want to use ?' 'Results will be saved as allinv2.dat in .\invert\jackresults\ folder'];
    
    if nsub~=1
       prompt = {q1}; dlg_title = 'Input subevent number for analysis.'; num_lines = 1; defaultans = {'2'};
       answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
       disp(['Selected subevent is ' num2str(cell2mat(answer))])
       selsub=str2double(cell2mat(answer));
    else
       selsub= 0;
    end

% open allstat new version only 
           [S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
%   
  cd jackresults  %% we need to check about this..!!

%%  
fid1 = fopen('allinv2.dat','w');
fid2 = fopen('allinv2b.dat','w');
% prepare filenames and open files
% read inv2 files read inv1 file for VOL info
for i=1:nstations
    
  if d1(i)~=0  % station is not disabled
      
%     extract from inv1 VOL info 
       alstname_inv1=['inv1_no_' S{i} '.dat'];
       
        fid3 = fopen(alstname_inv1,'r');
         [~,~,~,~,~,~,inv1_vol,~,inv1_clvd,~,~,~,~]=readinv1new(alstname_inv1,nsources,selsub)
        fclose(fid3);
      
       alstname=['inv2_no_' S{i} '.dat'];
     
       fid = fopen(alstname,'r');
           for ii=1:selsub-1  % skip lines to reach the selected subevent
              tmp=fgetl(fid); 
           end
           linetmp=fgetl(fid);
           fprintf(fid1,'%s %f  %f  %s\r\n',linetmp,inv1_vol,inv1_clvd,alstname(6:end));
           fprintf(fid2,'%s %f %f\r\n',linetmp,inv1_vol,inv1_clvd);
       fclose(fid);
  
  else
           
     disp(['Skipped station ' S{i}])
     nstations=nstations-1;       
  end
  
end

fclose(fid1);
fclose(fid2);

%% this is file for sub event * save it..
copyfile('allinv2b.dat',['allinv2b_sub' num2str(selsub)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

 
   
%%  read all inv2 files and put in one then read and plot this
% read the file 
%    
fid = fopen('allinv2.dat','r');
% inv2 file details 
% srcpos,srctime,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred,VOL,CLVD,jackname
%   1      2      3   4   5     6    7     8    9    10    11     12    13     14     15  16    17   18    19   20
      C=textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s',-1);
fclose(fid);

% change names
str1=C{4};dip1=C{5};rake1=C{6};srcpos2=C{1};srctime2=C{2};dc=C{16};str2=C{7};dip2=C{8};rake2=C{9};aziP=C{10};plungeP=C{11};aziT=C{12};plungeT=C{13};
VOL=C{18};CLVD=C{19};

%% Calculate Kagan based on best solution
% strref,dipref,rakeref
alld=[str1';  dip1';  rake1'];
fid=fopen('corrselect.dat','w');

 fprintf(fid,'%f %f %f\r\n',strref,dipref,rakeref);
 fprintf(fid,'%f %f %f\r\n',alld);
  
fclose(fid);

%% call fortran code
   [status, result] = system('corr_kag');
%% read the output

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
subplot(2,5,1)
 hist([str1;str2],36)
% title('Strike')
 xlabel('Strike (\circ)')
 ylabel('Count')
 xlim([0 360]) 
 
subplot(2,5,2)
 hist([dip1;dip2],18)
% title('Dip')
 xlabel('Dip (\circ)')
 ylabel('Count')
 xlim([0 90]) 
 
subplot(2,5,3)
 hist([rake1;rake2],36)
% title('Rake')
 xlabel('Rake (\circ)') 
 ylabel('Count')
 xlim([-180 180]) 
 
% Source position 
subplot(2,5,4)
 hist(srcpos2,linspace(0,nsources))
 % title('Source Position')
 xlabel('Source Position')
 ylabel('Count')
 v=axis;axis([0 nsources v(3) v(4)])
 
% source time 
T1=tshifts(1)*tstep;
T2=tshifts(3)*tstep;

subplot(2,5,5)
 hist(srctime2,linspace(T1,T2))
% title('Source Time')
 xlabel('Source Time (s)')
 ylabel('Count')
v=axis;axis([T1 T2 v(3) v(4)])

% next row

subplot(2,5,6)
 hist(dc,linspace(0,100))
% title('DC%')
 xlabel('DC%')
 ylabel('Count')
v=axis;axis([0 100 v(3) v(4)])

clvd_min=min(CLVD);
clvd_max=max(CLVD);
disp(['CLVD min ' num2str(clvd_min) '   ' 'CLVD max ' num2str(clvd_max) ])

subplot(2,5,7)
 hist(CLVD,linspace(clvd_min,clvd_max))
 xlabel('CLVD%')
 ylabel('Count')
v=axis%axis([0 100 v(3) v(4)])

vol_min=min(VOL);
vol_max=max(VOL);

disp(['VOL min ' num2str(vol_min) '   ' 'VOL max ' num2str(vol_max) ])

subplot(2,5,8)
 hist(VOL,linspace(vol_min,vol_max))
 xlabel('ISO%')
 ylabel('Count')
v=axis;%axis([0 100 v(3) v(4)])

subplot(2,5,9)
 Stereonet(0,90*pi/180,1000*pi/180,1);
 hold
 for i=1:nstations
     path = GreatCircle(deg2rad(str1(i)),deg2rad(dip1(i)),1);
 plot(path(:,1),path(:,2),'k-')
     %Plot P axis (black, filled circle)
      [xp,yp] = StCoordLine(deg2rad(aziP(i)),deg2rad(plungeP(i)),1);
      text(xp,yp,'P','FontSize',8,'HorizontalAlignment','center','BackgroundColor','red','Color','white')

     path = GreatCircle(deg2rad(str2(i)),deg2rad(dip2(i)),1);
 plot(path(:,1),path(:,2),'k-')
 
    %Plot T axis (black, filled circle)
      [xp,yp] = StCoordLine(deg2rad(aziT(i)),deg2rad(plungeT(i)),1);
      text(xp,yp,'T','FontSize',8,'HorizontalAlignment','center','BackgroundColor','blue','Color','white')
      
 end
 
 %title('Nodal Lines')
 TitleH = title('Nodal lines');
set(TitleH, 'Position', [0, -2], ...
  'VerticalAlignment', 'bottom', ...
  'HorizontalAlignment', 'center')
 
subplot(2,5,10)
 hist(kag)  
% title('Kagan Angle')
 ylabel('Count')
 xlabel('Kagan Angle (\circ)')
 

  cd .. % out of jackresults
  
  
cd ..  % out of invert 
