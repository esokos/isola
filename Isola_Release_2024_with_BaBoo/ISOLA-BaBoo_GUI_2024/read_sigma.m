function C = read_sigma(filename,stype)

%% NEW CODE 
% read sigma.dat
if ispc
    fid = fopen(filename);
    if stype == 1
     C = textscan(fid, '%f %f %f %f %f %f',6,'HeaderLines',13);
    else
     C = textscan(fid, '%f %f %f %f %f',5,'HeaderLines',12);   
    end
    fclose(fid);
else
    fid = fopen(filename);
    
    if stype == 1
     C = textscan(fid, '%f %f %f %f %f %f',6,'HeaderLines',13);
    else
     C = textscan(fid, '%f %f %f %f %f',5,'HeaderLines',12);  
    end
    
    fclose(fid);
end
%