function [srcpos2C,srctimeC,srcpos2,srctime2,variance,str,dip,rake,maxvar] = preparecor4kagan(cname,cor,strref,dipref,rakeref)

%% read the file
% cd invert

  fid = fopen(cname,'r');
     [srcpos2,srctime2,variance,str1,dip1,rake1,str2,dip2,rake2,~,~,~,~] = textread(cname,'%f %f %f %f %f %f %f %f %f %f %f %f %f','headerlines',2);
  fclose(fid);  
  
  maxvar=max(variance);
%   tenpercvar=maxvar/10;
%   cor2=maxvar-tenpercvar;
  
disp(['Maximum correlation ' num2str(maxvar) ' . Threshold = ' num2str(cor)])
  
  
% find cor values within  limits
ind=find(variance > cor);

str=str1(ind);
dip=dip1(ind);
rake=rake1(ind);

str2s=str2(ind);
dip2s=dip2(ind);
rake2s=rake2(ind);

var=variance(ind);
% find the limits of the contour specified by cor
% find cor values within low and high freq
srcpos2C=srcpos2(ind);
srctimeC=srctime2(ind);


disp(['Found ' num2str(length(str)) ' solutions'])
alld=[str';  dip';  rake'; str2s'; dip2s'; rake2s'];
%% output

fid=fopen('corrselect.dat','w');

 fprintf(fid,'%f %f %f\r\n',strref,dipref,rakeref);
 
 fprintf(fid,'%f %f %f %f %f %f\r\n',alld);
  
fclose(fid);

% cd ..

