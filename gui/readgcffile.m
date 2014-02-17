function [samples,streamID,sps,ist] = readgcffile(filename)
% ReadGCFFile
%
%   [SAMPLES,STREAMID,SPS,IST] = READGCFFILE(filename)
%
%   Reads in the specified GCF formatted file, and returns:
%     Samples - an array of all samples in file
%     Stream ID (string up to 6 characters)
%     SPS - sample rate of data in SAMPLES
%     IST - start time of data, as serial date number
%
%   Data in file is assumed to be continuous, and contain data for only one stream.
%   blocks are assumed to be in incremental time sequence only.
%
%   example:
%   [samples,streamid,sps,ist]=readgcffile('test.gcf');
%
%   M. McGowan, Guralp Systems Ltd. email: mmcgowan@guralp.com

fid = fopen(filename,'r','ieee-be');
if fid==-1,
    [p,n,e]=fileparts(filename);
    if ~strcmpi(e,'.gcf'),
        fname2 = [filename,'.gcf'];
        fid = fopen(fname2,'r','ieee-be');
    end
end
if fid==-1,
    error(['Unable to open file "',filename,'"']);
    return; 
end

samples = [];

% read in header for this file to extract stream info
% This assumes that the file contains incremental
% sample data for one stream only (i.e. with a fixed sample rate and StreamID )
sysID = dec2base(fread(fid,1,'uint32'),36);
streamID = dec2base(fread(fid,1,'uint32'),36);
date = fread(fid,1,'ubit15');
time = fread(fid,1,'ubit17');
reserved = fread(fid,1,'uint8');
sps = fread(fid,1,'uint8');
frewind(fid);

% Convert GCF coded time to Matlab coded time
hours = floor(time / 3600);
mins = rem(time,3600);
ist = datenum(1989,11,17, hours, floor(mins / 60), rem(mins,60) ) + date;

% to read the file, first create the array to handle the entire file's samples,
% then read in block by block, copying into the array in the correct place.
sampcount=samplesinfile(fid);
samples=zeros(sampcount,1);

sampcount=1;
while ~feof(fid)
   blocksamples = readgcfblock(fid);
   samples(sampcount:sampcount+length(blocksamples)-1) = blocksamples;
   sampcount = sampcount + length(blocksamples);
end
fclose(fid);


function samps = readgcfblock(fid)
sysid = fread(fid,1,'uint32',9);	% the '9' skips the next 9 bytes
if feof(fid)
   samps = [];
   return 
end
samplerate = fread(fid,1,'uint8');
compressioncode = fread(fid,1,'uint8');
numrecords = fread(fid,1,'uint8');

if (samplerate ~= 0),
   fic = fread(fid,1,'int32');
   switch compressioncode
   case 1,
      diffs = fread(fid,numrecords,'int32');
   case 2,
      diffs = fread(fid,numrecords*2,'int16');
   case 4,
      diffs = fread(fid,numrecords*4,'int8');
   end
   ric = fread(fid,1,'int32',1000-numrecords*4);
else
   status = fread(fid,numrecords*4,'uchar');
end

diffs(1) = fic;
samps = cumsum(diffs);



function samps = samplesinfile(fid)
fseek(fid,14,'bof');
% Read number-of-records and compression-code of every block into an array
nr = fread(fid,'uint16',1022);
% Separate number-of-records and compression-code from the 16 bit value read
cc = bitshift(nr,-8);
nr = bitand(nr,255);
% sum up the number of samples in each block
samps=sum(cc.*nr);
frewind(fid);
