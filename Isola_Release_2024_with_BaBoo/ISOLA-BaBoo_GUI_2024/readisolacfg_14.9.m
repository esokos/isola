function [gmt_ver,psview,npts,htmlfolder] = readisolacfg
% this function reads the ISOLA cfg file
% ver. 1
% Dec 2017
% defaults are 
% gmt version=4
% psview=gsview64
% npts=8192
% htmlfolder='null'
%
%% find isola folder
infold=which('isola.m');
str = strrep(infold,'isola.m','');

h=dir([str 'isolacfg.isl']);

if isempty(h)
    disp('isolalcfg.isl was not found in isola install folder. Defaults will be used, e.g. ')
    disp('GMT version : 4, PS FILE VIEWER: gsview32  ')
    % return the defaults
    gmt_ver=4;
    psview='gsview32';
    npts=8192;
    htmlfolder='null';
else
% read the file and display the defaults
    disp('isolalcfg.isl WAS found in isola install folder. Reading file..')
    fid = fopen([str 'isolacfg.isl'],'r');
       tline = fgetl(fid);
       while ischar(tline)
            
            if tline(1) =='%'
              %  disp('Comment ... skip it..')
            elseif strcmp(tline(1:3),'GMT')
              gmt_ver=sscanf(tline,'%*s %*s %d');
            elseif strcmp(tline(1:7),'PS FILE')
              psview=sscanf(tline,'%*s %*s %*s %s');
            elseif strcmp(tline(1:6),'NUMBER')
              npts=sscanf(tline,'%*s %*s %*s %*s %u');
            elseif strcmp(tline(1:4),'HTML')
              htmlfolder=sscanf(tline,'%*s %*s %s');              
            end
            
            tline = fgetl(fid);
       end

    fclose(fid);

end
