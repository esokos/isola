function [data,dyear,ddoy,dmonth,dday,dhr,dmin,dsec,nchanels] = seisanimportnew(newdir, Seisfile)
%data,dyear,dmonth,dday,fhour,fmin,fsec,nchanels
fid  = fopen([newdir, Seisfile],'r');

frewind(fid); 
%% read header up to 80 bytes

dum1=fread(fid,4,'uchar');

head1= fscanf(fid,'%c',80);  %% header

dum1=fread(fid,4,'uchar');
dum1=fread(fid,4,'uchar');

free= fscanf(fid,'%c',80);   %% free


nochanels=str2num(head1(31:33));
dyear=str2num(head1(34:36));
ddoy=str2num(head1(38:40));
dmonth=str2num(head1(42:43));
dday=str2num(head1(45:46));
dhr=str2num(head1(48:49));
dmin=str2num(head1(51:52));
dsec=str2num(head1(54:59));
dtwin=str2num(head1(61:69));

% end with header
%% read nochanels header
k=1;
while k <= nochanels

dum1=fread(fid,4,'uchar');
dum1=fread(fid,4,'uchar');

    chhead1= fscanf(fid,'%c',26);
    chhead2= fscanf(fid,'%c',26);
    chhead3= fscanf(fid,'%c',26);
    
dum1=fread(fid,2,'uchar');

k=k+3;

end

%% channels
nchanels=max([nochanels 10]);

% preallocate
data(1,nchanels)=struct('d',[],'n',[],'c',[],'f',[],'s',[]);


for chnum = 1:nchanels,
    dum1=fread(fid,4,'uchar');
    dum1=fread(fid,4,'uchar');
    
     evthdr= fscanf(fid,'%c',1040);
 
       chn_nm= evthdr(1:9);
       sfreq=evthdr(37:43);
       samp= evthdr(44:50); 
       
      sampnumst=char(samp);
      sampnum=str2num(sampnumst);
      for3=floor(sampnum/32);
      left=mod(sampnum,32);
      
    dum1=fread(fid,4,'uchar');
    dum1=fread(fid,4,'uchar');      
   
     s = fread(fid,sampnum,'32*int32=>int32',0,'b');
     
      data(chnum).d=s;

      data(chnum).n=deblank(chn_nm(1:5));
      data(chnum).c=deblank(chn_nm(6:8));
      data(chnum).f=sfreq;
      data(chnum).s=samp;
      
 end     

fclose(fid);

 
