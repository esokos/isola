function result = jackstations

disp('This is jackstations 28/08/2015')
disp('it will run jacknifing on stations in current isola run folder.')
pwd

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

%%   
if ispc
    h=dir('.\invert\allstat.dat');
else
    h=dir('./invert/allstat.dat');
end

if isempty(h)
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
    return
else
end
  
%%  
cd invert

   % backup of original allstat.dat
     copyfile('allstat.dat','allstat.bak');
%%     
     % create the batch file first ..!!
     if ispc
        fid = fopen('runisolajack.bat','w');
             fprintf(fid,'%s\r\n','isola.exe');
             fprintf(fid,'%s\r\n','norm.exe');
        fclose(fid);      
     else
       disp('Linux system')
        fid = fopen('runisolajack.sh','w');
             fprintf(fid,'%s\n','#!/bin/bash');
             fprintf(fid,'%s\n','             ');
             fprintf(fid,'%s\n','isola.exe');
             fprintf(fid,'%s\n','norm.exe');
        fclose(fid); 
             !chmod +x runisolajack.sh     
     end
%%
    % open allstat
         %  [S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %u %u %u %u %f %f %f %f',-1);
         
             [S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %u %f %f %f %f %f %f %f',-1);
             
    % new allstat  [stanames,od1,od2,od3,od4,of1,of2,of3,of4] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
    allIndexes = 1:nstations;

    % create allstat files  and run in one loop......!!!!!!!
    fh=exist('jackresults','dir');
        if (fh~=7)
            errordlg('Jackresults folder doesn''t exist. ISOLA will create it. ','Folder warning');
            mkdir('jackresults');
        end
    % clean folder 
    if ispc
        delete('.\jackresults\*.*')
    else
        delete('./jackresults/*.*')
    end
%% copy a few files in jackresults for reference    
if ispc
  copyfile('allstat.dat','.\jackresults\');
  copyfile('inpinv.dat','.\jackresults\');
else
  copyfile('allstat.dat','./jackresults\');
  copyfile('inpinv.dat','./jackresults\');
end
%%    
  %  jacknife stations
      hpr = waitbar(0,'Running jackknife per station  ...');

for i=1:nstations           % omit 1 station
%     
    indexToOmit = i;
    indexesToUse = (allIndexes ~= indexToOmit);
    
    alstname=['allstat_no_' S{i}];

    fid=fopen(alstname,'w');
      for j=1:nstations
          if d1(j)~=0    % not use station if it is already disabled
              if ispc
                 %fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\r\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
                 fprintf(fid,'%s %u %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f\r\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
              else
                 %fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
                 fprintf(fid,'%s %u %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
              end
          else
              if ispc
                 %fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\r\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
                 fprintf(fid,'%s %u %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f\r\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
              else
                 %fprintf(fid,'%s %u %u %u %u %5.2f %5.2f %5.2f %5.2f\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
                 fprintf(fid,'%s %u %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f %5.2f\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
              end
          end
      end
     fclose(fid);
%%
     % add code here to run the modified isola, isola must run without pause and at the end write a flag in temp001.txt to inform matlab  that
     % fortran finished..!! 
      fid = fopen('temp001.txt','w');
          fprintf(fid,'0');
      fclose(fid);

%    proceed with jacknifing     
     copyfile(alstname,'allstat.dat');
     
%    RUN THE CODE
     if ispc   
         system('runisolajack.bat');   
     else
         system('gnome-terminal -e "bash -c runisolajack.sh;bash"')           
     end
%
      program_done = 0;
     while program_done == 0
       pause(2); % pauses program 2 seconds before checking temp001.txt again
       fid = fopen('temp001.txt','r');
       program_done = fscanf(fid,'%d');
       fclose(fid);
     end   

    disp('Isola code finished')
     
%% now take care or output..!! copy needed files in jack folder
    if ispc    
        copyfile('inv1.dat',['.\jackresults\inv1_no_' S{i} '.dat']);
        copyfile('inv2.dat',['.\jackresults\inv2_no_' S{i} '.dat']);
        copyfile('inv3.dat',['.\jackresults\inv3_no_' S{i} '.dat']);
    else
        copyfile('inv1.dat',['./jackresults\inv1_no_' S{i} '.dat']);
        copyfile('inv2.dat',['./jackresults\inv2_no_' S{i} '.dat']);
        copyfile('inv3.dat',['./jackresults\inv3_no_' S{i} '.dat']);      
    end
  
    waitbar(i/nstations)  % update bar
   
end  % main loop

     close(hpr) 
     copyfile('allstat.bak','allstat.dat');
    % clean 
     delete('allstat_no_*')
     delete('runisolajack.bat')
     delete('allstat.bak')
     delete('temp001.txt')
     
cd .. % out of invert
%
helpdlg('Jackknifing ended.') %. Numerical results are available in .\invert\jackresults\allinv2.dat','Info');
