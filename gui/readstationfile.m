function [C,nostations] = readstationfile

% read station file
h=dir('green');

if isempty(h);
    errordlg('Green folder doesn''t exist. Please create it. ','Folder Error');
    return
else
end

%%
try 
   cd green

  h=dir('station.dat');

if isempty(h);
    errordlg('station.dat file doesn''t exist. Please create it. ','Folder Error');
    return
else
end

    fid = fopen('station.dat','r');
          C=textscan(fid,'%f %f %f %f %f %s %s ','HeaderLines', 2);
    fclose(fid);
    
   %   celldisp(C)
    nostations=length(C{1});
  cd ..

catch
    cd ..
end 