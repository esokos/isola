function [totalgs,selectedsrc,selectedgrid,strike,dip,rake,Mo,Mw] = readout3

filename='.\env_amp_inv\out3.dat';

fid = fopen(filename);

tline = fgets(fid);
tline = fgets(fid);
totalgs=sscanf(tline,'%u');
tline = fgets(fid);
tline = fgets(fid);
selectedsrc=sscanf(tline(24:end),'%u');
tline = fgets(fid);
selectedgrid=sscanf(tline(25:end),'%u');
tline = fgets(fid);
SDR=sscanf(tline(13:end),'%u %u %d');
strike=SDR(1);
dip=SDR(2);
rake=SDR(3);
tline = fgets(fid);
Mo=sscanf(tline(15:end),'%e');
tline = fgets(fid);
Mw=sscanf(tline(22:end),'%f');

fclose(fid);
