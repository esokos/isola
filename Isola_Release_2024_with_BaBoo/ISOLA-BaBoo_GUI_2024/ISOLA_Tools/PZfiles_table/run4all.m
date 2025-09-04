function ok = run4all(filename)

fid = fopen(filename);
    
   names = textscan(fid, '%s %*[^\n]');

fclose(fid);


for i=1:length(names{1})
    
stname=char(names{1,1}{i,1})

 
       table2pz(filename,stname,'2014-02-03')
 
end

ok=1;