function [] = jackstations_nocova
rng('default')  % For reproducibility %JZ
%find number of stations
h=dir('stations.isl'); 
if isempty(h)
  errordlg('stations.isl file doesn''t exist. Run station select. ','File Error');
  return
else
  [fid,~] = fopen('stations.isl','r'); 
  nstations=fscanf(fid,'%u',1);
  fclose(fid);
end
% 
if ispc
    h=dir('.\invert\allstat.dat');
else
    h=dir('./invert/allstat.dat');
end
% 
if isempty(h)
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
    return
else
end
%   
cd invert
% 
% backup of original allstat.dat
     copyfile('allstat.dat','allstat.bak');
%      
% remove done file if exists
     if FileExist('done.tmp')
      delete('done.tmp')
     end
%      
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
% 
    % open allstat
    %[S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %u %u %u %u %f %f %f %f',-1);
     [S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %u %f %f %f %f %f %f %f',-1)
     
    
%              
%     % new allstat  [stanames,od1,od2,od3,od4,of1,of2,of3,of4] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
%     allIndexes = 1:nstations;      % JZ suppressed
% 
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
%   
%   %  jacknife stations
      hpr = waitbar(0,'Running jackknife per station  ...');
     
      
      
      nstations=size(S,1)                     %JZ

nsets=nstations;     % number of perturbed allstat.dat files      % JZ ??? THINK ABOUT, perhaps  more 
MM=nsets;
nn=nstations;    
NN=nn;
% **********    BOOTSTRAP        ******************
      w = mnrnd(NN, ones(1,nn)/nn,  MM)  * (1/nn) % produces MM rows, each row = set of BOO weights for nn stations
      sum (w,2)                                   % each set of weights has sum = 1
                                                  % THINK about if 1 or 1/3 per component  
% *************************************************
d2=[];


for ii=1:nsets   %JZ numer of station sets is to be discussed; perhaps > nstations ?         
%     indexToOmit = ii;
%     indexesToUse = (allIndexes ~= indexToOmit);
%%%    alstname=['allstat_no_' S{ii}]
          alstname=['allstat_no_' S{ii}]     %JZ
          fid=fopen(alstname,'w');
% % %           y=randsample(nstations,nstations_less,false) %JZ chosing nstations_less random numbers from numbers 1,2,...nstations
% % %           %   false = withoutreplacement = the same number is not repeated in selection
% % %           %   [however, the same sets of (different) numbers will oocur]
% % %         for j=1:nstations
% % %           indexesToUse(j)=ismember(j,y);  %JZ Station is used if present in the selection 
% % %         end
       
        
        for j=1:nstations % JZ nstations will never change here
                    
% % %           if d1(j)~=0    % not use station if it is already disabled
% % %               if ispc
% % %                  %fprintf(fid,'%s %u %u %u %u %7.4f %7.4f %7.4f %7.4f\r\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
% % %                  fprintf(fid,'%s %u %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
% % %               else
% % %                  %fprintf(fid,'%s %u %u %u %u %7.4f %7.4f %7.4f %7.4f\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
% % %                  fprintf(fid,'%s %u %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
% % %               end

     d2(j)=w(ii,j);d3(j)=w(ii,j);d4(j)=w(ii,j);   % JZ component weights from BOOTSTRAP
        
          if d1(j)~=0    % not use station if it is already disabled
              if ispc    % JZ not changing used/nonused [=d1], but changing weights [d2, d3, d4]
                 %fprintf(fid,'%s %u %u %u %u %7.4f %7.4f %7.4f %7.4f\r\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
                 fprintf(fid,'%s %u %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
              else
                 %fprintf(fid,'%s %u %u %u %u %7.4f %7.4f %7.4f %7.4f\n',S{j},indexesToUse(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
                 fprintf(fid,'%s %u %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
              end

              else
              if ispc
                 %fprintf(fid,'%s %u %u %u %u %7.4f %7.4f %7.4f %7.4f\r\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
                 fprintf(fid,'%s %u %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
              else
                 %fprintf(fid,'%s %u %u %u %u %7.4f %7.4f %7.4f %7.4f\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
                 fprintf(fid,'%s %u %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\n',S{j},d1(j),d2(j),d3(j),d4(j),of1(j),of2(j),of3(j),of4(j));
              end
          end
      end
     fclose(fid);
%%
%    proceed with jacknifing     
    copyfile(alstname,'allstat.dat');
     
%%    RUN THE CODE
     if ispc   
         system('runisolajack_nocova.bat');   
     else
       %  system('gnome-terminal -e "bash -c runisolajack.sh;bash"')           
     end
%%
%      %  wait here for fortran part to end
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
        copyfile('inv3.dat',['.\jackresults\inv3_no_' S{ii} '.dat']);
     else
        copyfile('inv1.dat',['./jackresults\inv1_no_' S{ii} '.dat']);
        copyfile('inv2.dat',['./jackresults\inv2_no_' S{ii} '.dat']);
        copyfile('inv3.dat',['./jackresults\inv3_no_' S{ii} '.dat']);      
        copyfile('inv3.dat',['./jackresults\inv3_no_' S{ii} '.dat']);      
    end
%%   
%     waitbar(ii/nstations)  % update bar
     waitbar(ii/nsets)  % update bar         %JZ
   
end  % main loop over the station sets (index ii)

     close(hpr) 
     
% restore allstat.dat to initial status
     copyfile('allstat.bak','allstat.dat');
%     
%      % clean 
%      delete('allstat_no_*')
%      delete('runisolajacknocova.bat')
%      delete('allstat.bak')
%      %delete('temp001.txt')
     
cd .. % out of invert
%
%helpdlg('Jackknifing ended.') %. Numerical results are available in .\invert\jackresults\allinv2.dat','Info');
 