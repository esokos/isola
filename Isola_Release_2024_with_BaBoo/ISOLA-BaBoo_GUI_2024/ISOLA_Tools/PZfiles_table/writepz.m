function ok = writepz(station,stream,A0,sens,digitizer_value,nzer,zeroes,npol,poles)

ok=0;

% filename
pzfile=[station stream '.pz'];
constant=1/(sens*digitizer_value);
fid = fopen(pzfile,'w');

    fprintf(fid,'%s\r\n','A0');   %%%%%BE CAREFUL THESE NEED EXPONENTIAL FORMAT (are corrected....)
    fprintf(fid,'%e\r\n',A0);
    fprintf(fid,'%s\r\n','count-->m/sec');
    fprintf(fid,'%e\r\n',constant);
    
    fprintf(fid,'%s\r\n','zeroes');
    fprintf(fid,'%i\r\n',nzer);
    for i=1:nzer
     fprintf(fid,'%e     %e\r\n',zeroes{i});
    end
    
    fprintf(fid,'%s\r\n','poles');
    fprintf(fid,'%i\r\n',npol);
    for i=1:npol
     fprintf(fid,'%e    %e\r\n',poles{i});
    end
    fprintf(fid,'%s\r\n',['Info:  ' date '  '  station '  Digi sens  '  num2str(digitizer_value) '  Seism sens   '   num2str(sens)]);
   
fclose(fid);

ok=1;
