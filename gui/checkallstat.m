
cd invert
%%% read allstat

stationfile='allstat.dat';
%read data in 6 arrays
fid  = fopen(stationfile,'r');
[staname,d1,d2,d3,d4] = textread(stationfile,'%s %f %f %f %f',-1);
fclose(fid);

nostations = length(staname)
errormes=0

for i=1:nostations

    realdatafilename{i}=[staname{i} 'raw.dat'];
     if exist(realdatafilename{i},'file')
         disp(['Found ' realdatafilename{i}])
     else
         disp(['File ' realdatafilename{i} ' is missing'])
         errormes=1
     end
end         
 
 cd ..