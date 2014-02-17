function [id,tstep,nsources,tshifts,nsub,freq,var] = readinpinv(file)

 fid  = fopen(file,'r');
 
            linetmp=fgetl(fid);              %01 line
            
            linetmp=fgetl(fid);              %02 line
            id=sscanf(linetmp,'%u',1);       %02 line
            
            linetmp=fgetl(fid);              %03 line
            
            linetmp=fgetl(fid);              %04 line
            tstep=sscanf(linetmp,'%g',1);    %04 line 
            
            linetmp=fgetl(fid);              %05 line
            
            linetmp=fgetl(fid);              %06 line
            nsources=sscanf(linetmp,'%u',1); %06 line
            
            linetmp=fgetl(fid);              %07 line
            linetmp=fgetl(fid);              %08 line

            linetmp=fgetl(fid);              %09 line
            tshifts=sscanf(linetmp,'%d',3);  %09 line
            
            linetmp=fgetl(fid);              %10 line
            
            linetmp=fgetl(fid);              %11 line
            nsub=sscanf(linetmp,'%u',1);     %11 line
            
            linetmp=fgetl(fid);              %12 line
            linetmp=fgetl(fid);              %13 line
            
            linetmp=fgetl(fid);              %14 line
            freq=sscanf(linetmp,'%g',4);     %14 line
            
            linetmp=fgetl(fid);              %15 line

            linetmp=fgetl(fid);              %15 line
            var=sscanf(linetmp,'%e',1);      %16 line

fclose(fid);

%   freq          4x1                32  double              
%   id            1x1                 8  double              
%   nsources      1x1                 8  double              
%   nsub          1x1                 8  double              
%   tshifts       3x1                24  double              
%   tstep         1x1                 8  double              
%   var           1x1                 8  double   
