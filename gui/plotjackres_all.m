function result=plotjackres_all
% this function plots the jacknife results
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
% h=dir('.\invert\allstat.dat');
%   if isempty(h); 
%          errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
%      return
%   else
%   end
%   
% cd invert
%   
% % open allstat new version only 
%            [S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
% %   
%   cd jackresults  %% we need to check about this..!!
%        
% % prepare filenames and open files
% % read inv2 files 
% for i=1:nstations
%      alstname=['inv2_no_' S{i} '.dat'];
%      
%        fid = fopen(alstname,'r');
%           [srcpos2(i),srctime2(i),mo(i),str1(i),dip1(i),rake1(i),str2(i),dip2(i),rake2(i),aziP(i),plungeP(i),aziT(i),plungeT(i),aziB(i),plungeB(i),dc(i),varred(i)] = textread(alstname,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
%        fclose(fid);
% end
%  
%   cd .. % out of jackresults
%   
%   
% cd ..  % out of invert 

%%  read all inv2 files and put in one then read and plot this

cd invert
  
% open allstat new version only 
           [S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
%   
  cd jackresults  %% we need to check about existence of this folder ..!!

        fid1 = fopen('allinv2.dat','w');

      for i=1:nstations
         
%            % read station
%           alstname=['inv2_no_' S{i} '.dat'];
%          % add station         
%             fid = fopen(alstname,'r');
%                 linetmp=fgetl(fid);  
%                 fprintf(fid1,'%s %s\r\n',linetmp,alstname(6:end));
%             fclose(fid);
 
        for j=1:3
        % add components
               switch j
                   case 1
                      alstname=['inv2_no_' S{i} '_NS.dat'];
                   case 2
                       alstname=['inv2_no_' S{i} '_EW.dat'];
                   case 3
                      alstname=['inv2_no_' S{i} '_Z.dat'];
               end
%            
               fid = fopen(alstname,'r');
                linetmp=fgetl(fid);  
                fprintf(fid1,'%s %s\r\n',linetmp,alstname(6:end));
               fclose(fid);

        end
        
      
      end

fclose(fid1);

%% read the file 
   
  fid = fopen('allinv2.dat','r');
 % inv2 file details 
 % srcpos,srctime,mo,str1,dip1,rake1,str2,dip2,rake2,aziP,plungeP,aziT,plungeT,aziB,plungeB,dc,varred,jakcname
 %   1      2      3   4   5     6    7     8    9    10    11     12    13     14     15  16    17      18 
 
     C=textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s',-1);
  fclose(fid);
    
 % plot !!
 % change names
 str1=C{4};dip1=C{5};rake1=C{6};srcpos2=C{1};srctime2=C{2};dc=C{16};str2=C{7};dip2=C{8};rake2=C{9};aziP=C{10};plungeP=C{11};aziT=C{12};plungeT=C{13};
    % %% Plot solutions

    
    
    subplot(2,4,1)

Stereonet(0,90*pi/180,1000*pi/180,1);

hold
 for i=1:nstations
     path = GreatCircle(deg2rad(str1(i)),deg2rad(dip1(i)),1);
 plot(path(:,1),path(:,2),'r-')
     %Plot P axis (black, filled circle)
      [xp,yp] = StCoordLine(deg2rad(aziP(i)),deg2rad(plungeP(i)),1);
      plot(xp,yp,'ko','MarkerFaceColor','k');

     path = GreatCircle(deg2rad(str2(i)),deg2rad(dip2(i)),1);
 plot(path(:,1),path(:,2),'r-')
 
    %Plot T axis (black, filled circle)
      [xp,yp] = StCoordLine(deg2rad(aziT(i)),deg2rad(plungeT(i)),1);
      plot(xp,yp,'mo','MarkerFaceColor','m');
 
 end
  
 
 
subplot(2,4,2)
 hist([str1;str2],36)
 title('Strike')
 xlabel('Degrees')
xlim([0 360]) 
 
 subplot(2,4,3)
 hist([dip1;dip2],18)
 title('Dip')
 xlabel('Degrees')
xlim([0 90]) 
 

 subplot(2,4,4)
 hist([rake1;rake2],36)
 title('Rake')
 xlabel('Degrees')
xlim([-180 180]) 
 
 subplot(2,4,5)
 hist(srcpos2)
 title('Position')
 xlabel('Source no')
 
 subplot(2,4,6)
 hist(srctime2)
 title('Time')
 xlabel('Sec')
 
  subplot(2,4,7)
 hist(dc)
 title('DC%')
 
  subplot(2,4,7)

 earth_rose(str1, 360);

  cd .. % out of jackresults
  
  
cd ..  % out of invert 
