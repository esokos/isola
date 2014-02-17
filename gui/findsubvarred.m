function [subevent] = findsubvarred(file);

fid=fopen(file);

lcount=0;
nsubevents=0;
while 1
    
    ffline=fgets(fid);
     if ~ischar(ffline), break, end
     lcount=lcount+1;
     
     idx1 = strfind(ffline, ' varred=');

     if idx1 ~ [] ;
         a=sscanf(ffline(9:length(ffline)),'%g');
              nsubevents=nsubevents+1;
      subevent(nsubevents) = sscanf(ffline(9:length(ffline)),'%g');
      lcount;
 
     else
     end
     
end
 