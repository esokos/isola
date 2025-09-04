function C = read_sigma2(filename,stype)

fid=fopen(filename);

while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    
    k = strfind(tline, 'Covariance');
    
    if isempty(k)  
    else
        disp('Found Covariance matrix line. Reading data now...  ')
     
     if stype == 1
         C = textscan(fid, '%f %f %f %f %f %f',6);
     else
         C = textscan(fid, '%f %f %f %f %f',5);   
     end
     
    end
end


fclose(fid);