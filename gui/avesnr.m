function [average_snrNS,average_snrEW,average_snrZ] = avesnr(file,lowfreq,highfreq)
% modified to give SNR per component
% 03/09/2012

% read the file
r=load(file);
freq=r(:,1);
snrNS=r(:,2);
snrEW=r(:,3);
snrZ=r(:,4);

% find snr values within low and high freq
ind=find(lowfreq < freq & freq < highfreq);

average_snrNS=mean(snrNS(ind));
average_snrEW=mean(snrEW(ind));
average_snrZ=mean(snrZ(ind));

clear r freq snr