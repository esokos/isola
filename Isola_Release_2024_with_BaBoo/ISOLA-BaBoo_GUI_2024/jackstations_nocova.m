function [] = jackstations_nocova

%[~,~,~,~,cova] = readisolacfg;

%% find number of stations
h=dir('stations.isl'); 

if isempty(h)
  errordlg('stations.isl file doesn''t exist. Run station select. ','File Error');
  return
else
  [fid,~] = fopen('stations.isl','r'); 
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
     
   % remove done file if exists
   if FileExist('done.tmp')
      delete('done.tmp')
   end
         
%%     
     % create the batch file first ..!!
     if ispc
         fid = fopen('runisolajack_nocova.bat','w');
 %          if strcmp(cova,'YES')
               fprintf(fid,'%s\r\n','call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat"');
               fprintf(fid,'%s\r\n','isola_nocova.exe');
               fprintf(fid,'%s\r\n','norm.exe');
               fprintf(fid,'%s\r\n','done.exe');
               fclose(fid);                 
%             else
%                fprintf(fid,'%s\r\n','isola.exe');
%                fprintf(fid,'%s\r\n','norm.exe');
%                fclose(fid);                 
%             end
      else
       disp('Linux system') % this needs update!!
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
    %[S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %u %u %u %u %f %f %f %f',-1);
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

      
      
for ii=1:nstations           % omit 1 station
%     
    indexToOmit = ii;
    indexesToUse = (allIndexes ~= indexToOmit);
    
    alstname=['allstat_no_' S{ii}];

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

%    proceed with jacknifing     
     copyfile(alstname,'allstat.dat');
     
%    RUN THE CODE
     if ispc   
         system('runisolajack_nocova.bat');   
     else
       %  system('gnome-terminal -e "bash -c runisolajack.sh;bash"')           
     end
%
     %  wait here for fortran part to end
          done = 0;
          while done == 0
             done = FileExist('done.tmp');
          end
         disp('         ');disp('Fortran no_cova code finished.');disp('         ')
         delete('done.tmp'); 
     
%% now take care or output..!! copy needed files in jack folder
    if ispc    
        copyfile('inv1.dat',['.\jackresults\inv1_no_' S{ii} '.dat']);
        copyfile('inv2.dat',['.\jackresults\inv2_no_' S{ii} '.dat']);
        copyfile('inv3.dat',['.\jackresults\inv3_no_' S{ii} '.dat']);
    else
        copyfile('inv1.dat',['./jackresults\inv1_no_' S{ii} '.dat']);
        copyfile('inv2.dat',['./jackresults\inv2_no_' S{ii} '.dat']);
        copyfile('inv3.dat',['./jackresults\inv3_no_' S{ii} '.dat']);      
    end
  
    waitbar(ii/nstations)  % update bar
   
end  % main loop

     close(hpr) 
     
     % restore allstat.dat to initial status
     copyfile('allstat.bak','allstat.dat');
    
     % clean 
     delete('allstat_no_*')
     delete('runisolajacknocova.bat')
     delete('allstat.bak')
     %delete('temp001.txt')
     
cd .. % out of invert
%
helpdlg('Jackknifing ended.') %. Numerical results are available in .\invert\jackresults\allinv2.dat','Info');
