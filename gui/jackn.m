function result = jackn %(nstations)

disp('This is jackn 03/09/2012')
disp('it will run jacknifing on components in current isola run folder.')

pwd

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

%% 
if ispc
      h=dir('.\invert\allstat.dat');
else
      h=dir('./invert/allstat.dat');
end
  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
  else
  end
  
%%  
cd invert
   % backup of original allstat.dat
     copyfile('allstat.dat','allstat.bak');
     
     
% open allstat
           [S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %u %u %u %u %f %f %f %f',-1);
% new allstat  [stanames,od1,od2,od3,od4,of1,of2,of3,of4] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
allIndexes = 1:nstations;

      hpr = waitbar(0,'Run jacknife per component ...');

  % create allstat files  and run in one loop......!!!!!!!
     mkdir('jackresults')
      
%%      
%%%%%%%%%%%%% jacknife components

p=0;
allIndexes1 = 1:3;
for i=1:nstations
    
   for j=1:3

        waitbar((j+p)/(nstations*3))
       
          indexToOmit = j;
          indexesToUse = (allIndexes1 ~= indexToOmit);
             
               switch j
                   case 1
                      alstname=['allstat_no_' S{i} '_NS'];
                      curw=d2(i);
                   case 2
                      alstname=['allstat_no_' S{i} '_EW'];
                      curw=d3(i);
                   case 3
                      alstname=['allstat_no_' S{i} '_Z'];
                      curw=d4(i);
               end
%          
              fid=fopen(alstname,'w');
                 for k=1:nstations;
                    if k==i   % found same station
                        if curw ~= 0
                           fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\r\n',S{k},d1(k),indexesToUse(1),indexesToUse(2),indexesToUse(3),of1(k),of2(k),of3(k),of4(k));
                        else
                           fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\r\n',S{k},d1(k),d2(k),d3(k),d4(k),of1(k),of2(k),of3(k),of4(k));
                        end
                    else
                       fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\r\n',S{k},d1(k),d2(k),d3(k),d4(k),of1(k),of2(k),of3(k),of4(k));
                    end
                 end
                       fclose(fid);
%%  RUN THE CODE
     % add code here to run the modified isola 
     % isola must run without pause and
     % at the end write a file with a flag to inform matlab  that fortran
     % finished..!!
%    for fortran matlab interaction
      fid = fopen('temp001.txt','w');
          fprintf(fid,'0');
      fclose(fid);
%    proceed with jacknifing     
     copyfile(alstname,'allstat.dat');
     
%   run isola     
    system('runisolajack.bat')        

%
      program_done = 0;
     while program_done == 0
       pause(2); % pauses program 2 seconds before checking temp001.txt again
       fid = fopen('temp001.txt','r');
       program_done = fscanf(fid,'%d');
       fclose(fid);
     end   

disp('Isola code finished')
     
% now take care or output..!! copy needed files in jack folder
                  switch j
                     case 1
                          copyfile('inv1.dat',['.\jackresults\inv1_no_' S{i} '_NS.dat']);
                          copyfile('inv2.dat',['.\jackresults\inv2_no_' S{i} '_NS.dat']);
                          copyfile('inv3.dat',['.\jackresults\inv3_no_' S{i} '_NS.dat']);
                     case 2
                          copyfile('inv1.dat',['.\jackresults\inv1_no_' S{i} '_EW.dat']);
                          copyfile('inv2.dat',['.\jackresults\inv2_no_' S{i} '_EW.dat']);
                          copyfile('inv3.dat',['.\jackresults\inv3_no_' S{i} '_EW.dat']);
                     case 3
                          copyfile('inv1.dat',['.\jackresults\inv1_no_' S{i} '_Z.dat']);
                          copyfile('inv2.dat',['.\jackresults\inv2_no_' S{i} '_Z.dat']);
                          copyfile('inv3.dat',['.\jackresults\inv3_no_' S{i} '_Z.dat']);
                  end
          
   end  %% loop for component  j
    p=p+3;
end     %% loop for station    i

% clean a bit..!!
%delete('allstat_no_*')

 close(hpr) 
 
%%  jacknife stations
%       hpr = waitbar(0,'Run jacknife per station  ...');
% for i=1:nstations           % omit 1 station
% %%    
%     indexToOmit = i;
%     indexesToUse = (allIndexes ~= indexToOmit);
%     
%      waitbar(i/nstations)
%     
%      alstname=['allstat_no_' S{i}];
% 
%     fid=fopen(alstname,'w');
%       for j=1:nstations;
%           if d1(j)~=0    % not use station if it is already disabled
%              fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\r\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
%           else
%              fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\r\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
%           end
%       end
%      fclose(fid);
% %%     RUN THE CODE
%      % add code here to run the modified isola 
%      % isola must run without pause and
%      % at the end write a file with a flag to inform matlab  that fortran
%      % finished..!!
% % 
% %    backup of original allstat.dat
%      copyfile('allstat.dat','allstat.bak');
% %
% %    for fortran matlab interaction
%       fid = fopen('temp001.txt','w');
%           fprintf(fid,'0');
%       fclose(fid);
% %    proceed with jacknifing     
%      copyfile(alstname,'allstat.dat');
%      system('runisolajack.bat')        
%       
% 
% %
%       program_done = 0;
%      while program_done == 0
%        pause(2); % pauses program 2 seconds before checking temp001.txt again
%        fid = fopen('temp001.txt','r');
%        program_done = fscanf(fid,'%d');
%        fclose(fid);
%      end   
% 
% disp('Isola code finished')
%      
% %% now take care or output..!! copy needed files in jack folder
%       
%     copyfile('inv1.dat',['.\jackresults\inv1_no_' S{i} '.dat']);
%     copyfile('inv2.dat',['.\jackresults\inv2_no_' S{i} '.dat']);
%     copyfile('inv3.dat',['.\jackresults\inv3_no_' S{i} '.dat']);
% 
% end
%      close(hpr) 
cd ..

helpdlg('Jacknifing ended','Info');
