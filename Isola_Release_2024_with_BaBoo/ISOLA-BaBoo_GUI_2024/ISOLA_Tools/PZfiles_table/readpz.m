function [A0,sens,nzer,zeroes,npol,poles] =readpz(filename)
 
fid = fopen(filename);

    A0=str2num(fgetl(fid));
    sens=str2num(fgetl(fid));
    nzer=str2num(fgetl(fid));
   
       for p=1:nzer
            zeroes{p}=sscanf(fgetl(fid),'%f %f',[1 , 2]);
       end

       if nzer == 0
            zeroes=[];
       end
       
       npol=str2num(fgetl(fid));
       for p=1:npol
            poles{p}=sscanf(fgetl(fid),'%f %f',[1 , 2]);
       end
       
fclose(fid);
  