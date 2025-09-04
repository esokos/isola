%% it will create dummy pz files

f=dir('*.pz');
       
fid1=fopen('stations.txt','w');


  for j=1:length(f)
    tempname=f(j).name;

   [staname,stalon,stalat,netname] = tk2isolapz(tempname);
   
   if contains(tempname,'Z.pz')
    fprintf(fid1,'%s  %f  %f   %s\r\n',staname,stalat,stalon,netname);
   else
   end
   
  end
           
fclose(fid1);