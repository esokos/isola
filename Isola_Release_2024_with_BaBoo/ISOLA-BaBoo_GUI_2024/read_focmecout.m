function [str,dip,rake]=read_focmecout(filename)

fid = fopen(filename);

tline = fgetl(fid);

while ischar(tline)
%    disp(tline);
    % check if it is header
    
  if length(tline) > 24
      
       cheader=tline(1:23);
  
    
    if strcmp(cheader,'    Dip   Strike   Rake') 
  
        C=textscan(fid, '%f %f %f %f %f %f');
        %size(C)
        
        str=C{1,2};  % be careful strike is 2nd column !!
        dip=C{1,1};
        rake=C{1,3};
        
         disp(['Found   '  num2str(length(C{1}))    '  solutions in focmec.out' ])
    else
        
    end    
    
  else
  end
  
     tline = fgetl(fid);
    
end

fclose(fid);