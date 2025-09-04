function  [str,dip,rake]=read_sdrfile(filename)

fid = fopen(filename);

C=textscan(fid, '%f %f %f %f %f %f','HeaderLines',1);
        
        str=C{1,1};  
        dip=C{1,2};
        rake=C{1,3};
        
         disp(['Found   '  num2str(length(C{1}))    '  solutions in focmec.out' ])

fclose(fid);