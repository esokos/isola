function result = jackn %(nstations)

disp('This is jackn 29/08/2015')
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
     
%%  open allstat
           [S,d1,d2,d3,d4,of1,of2,of3,of4] = textread('allstat.dat','%s %u %u %u %u %f %f %f %f',-1);

allIndexes = 1:nstations;

%% create allstat files  and run in one loop......!!!!!!!
    fh=exist('jackresults','dir');
        if (fh~=7);
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
      hpr = waitbar(0,'Run jackknife per component ...');

      
%%    jacknife components
p=0;

allIndexes1 = 1:3;

for i=1:nstations
 
 if d1(i)~=0  % station is disabled we must skip it 
     
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
     
%% create the file first ..!!
if ispc

    system('runisolajack.bat')        
%
else
  %       disp('Linux ')
             
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
    
    
 else
    % skip not used station 
 end
 
end     %% loop for station    i

% clean a bit..!!
delete('allstat_no_*')

close(hpr) 

cd ..

helpdlg('Jackknifing ended. Numerical results are available in .\invert\jackresults\allinv2.dat','Info');
