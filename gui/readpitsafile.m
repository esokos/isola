function [samples] = readpitsafile(filename)
% ReadGCFFile
%
%   [SAMPLES,STREAMID,SPS,IST] = READGCFFILE(filename)
%
fid = fopen(filename);

timest=fgetl(fid);
year=timest(13:16)
month=timest(18:19)
day=timest(21:22)

hour=timest(24:25)
minute=timest(27:28)
seconds=timest(30:35)


sampfrq=fgetl(fid);
sfreq=sampfrq(12:18)

ndat=fgetl(fid);
npoints=ndat(7:12)

stationcode=fgetl(fid);
scode=stationcode(15:18)

channel=fgetl(fid);
chan1=channel(18:18)
chan2=channel(21:21)


samples = fscanf(fid,'%i');

%whos samples

fclose(fid);
