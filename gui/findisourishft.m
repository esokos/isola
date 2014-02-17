function [subevent,isour_ishft] = findisourishft(file);

fid=fopen(file);

lcount=0;

while 1
    
    ffline=fgets(fid);
     if ~ischar(ffline), break, end
     lcount=lcount+1;
     
     idx1 = strfind(ffline, 'Best source position for subevent #');

     if idx1 ~ [] ;
      subevent = sscanf(ffline(37:length(ffline)),'%i');
      
     end

     idx2 = strfind(ffline, ' isour,ishift');
     
     if idx2 ~ [] ;
%        npoints_rlength= sscanf(ffline,'%i %f');  
      
     end
     
end
 