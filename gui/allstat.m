function [] = allstat
% read allstat.dat
h=dir('.\invert\allstat.dat');
%
if isempty(h); 
     errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
else
      % try to guess allstat version 
            fid=fopen('.\invert\allstat.dat');
                 tline=fgets(fid);
                [~,cnt]=sscanf(tline,'%s');
            fclose(fid);
 
       switch cnt
        case 9
                 disp('Found current version of allstat e.g. STA 1 1 1 1 f1 f2 f3 f4')

        case 6
                 disp('Found version of allstat without frequencies e.g. 001 1 1 1 1 STA. Will be converted to new version.')
                 [~,d1,d2,d3,d4,NS] = textread('.\invert\allstat.dat','%s %f %f %f %f %s',-1);
                 nsta=length(NS);
                 % read freq band from inpinv.dat
                 a=exist('.\invert\inpinv.dat','file');
                 if a==2
                 fid  = fopen('.\invert\inpinv.dat','r');
                        for i=1:3
                          aa=fgetl(fid);
                        end
                          dtime=fgetl(fid);
                        for i=1:6
                          aa=fgetl(fid);
                        end
                          nsubevents=fgetl(fid);
                        for i=1:2
                          aa=fgetl(fid);
                        end
                          invband=fgetl(fid);
                        fclose(fid);
                 else
                 end

                 % output
                    labp=char(NS);
                    fid = fopen('test.dat','w');
                      for p=1:nsta
                          
                          if ispc
                              fprintf(fid,'%s %u %u %u %u %s\r\n', labp(p,1:end),d1(p),d2(p),d3(p),d4(p),invband);
                          else
                              fprintf(fid,'%s %u %u %u %u %s\n', labp(p,1:end),d1(p),d2(p),d3(p),d4(p),invband);
                          end
                      end
                    fclose(fid);                     
       case 5
           
              disp('Found old version of allstat without frequencies and without station masking e.g. STA 1 1 1 1. Will be converted to new version')
                 [NS,d1,d2,d3,d4] = textread('.\invert\allstat.dat','%s %f %f %f %f',-1);
                 nsta=length(NS);
                 % read freq band from inpinv.dat
                 a=exist('.\invert\inpinv.dat','file');
                 if a==2
                 fid  = fopen('.\invert\inpinv.dat','r');
                        for i=1:3
                          aa=fgetl(fid);
                        end
                          dtime=fgetl(fid);
                        for i=1:6
                          aa=fgetl(fid);
                        end
                          nsubevents=fgetl(fid);
                        for i=1:2
                          aa=fgetl(fid);
                        end
                          invband=fgetl(fid);
                        fclose(fid);
                 else
                 end

                 % output
                    labp=char(NS);
                    fid = fopen('test.dat','w');
                      for p=1:nsta
                          if ispc
                           fprintf(fid,'%s %u %u %u %u %s\r\n', labp(p,1:end),d1(p),d2(p),d3(p),d4(p),invband);
                          else
                            fprintf(fid,'%s %u %u %u %u %s\n', labp(p,1:end),d1(p),d2(p),d3(p),d4(p),invband);   
                          end
                          
                      end
                    fclose(fid);                     
                 
       end
end
                 
