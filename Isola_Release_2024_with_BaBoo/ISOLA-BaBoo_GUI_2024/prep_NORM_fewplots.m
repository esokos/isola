% Analogy of NORM  for Covariance matrix
% Jiri Zahradnik, January-February 2023-2024

% clear all
% close all
format shortG

%% load station names
disp ('Warning: order the stations as in allstat.dat!!!!!!!!!! ')
disp ('Warning: noise and signal must have the same length, same instr correction, ame filtration and same dt!! ')
%statcodes={'PAZOI','PTEO','GRNL', 'PFVI'}; % both filNOISE and silSIGNAL must be availabe for tehse stations, e.g. PAZOIfilNOISE 
%statcodes={'PAZOI'}
%statcodes={'PAZOI','PTEO','GRNL','PFVI'} % both filNOISE and silSIGNAL must be availabe for tehse stations, e.g. PAZOIfilNOISE 
%statcodes={'INCN', 'FUY', 'BCT','GJM'}


%% read allstat and extract the station names
% first check that allstat.dat exists
% we should be in invert folder !!

% check if file exists
  h=dir('allstat.dat');

if isempty(h)
  errordlg('allstat.dat file doesn''t exist in invert folder','File Error');
  return
else
    fid=fopen('allstat.dat');
    C = textscan(fid,'%s %f %f %f %f %f %f %f %f');
    fclose(fid);
 % put station names in statcodes cell array
 statcodes=C{1}; 
end
numstat=length(statcodes)

selstnum=1


a=1024; %FIXED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
aaa=a*3*numstat;
bb=3*a;




fid=fopen('hinv.bin','r') %% Load inverted cova (hinv)
mat2=fread(fid,'double','ieee-le');
fclose(fid);
sz=size(mat2);
n=sz(1)/3;
mat3=reshape (mat2,n,3); % now is exactly the same nx3 matrix, (i,j,value) as was originally converted to binary
%[rows, cols, vals]=find(mat3); %THIS IS WRONG !!!! takes only nonzero
rows=mat3(:,1); %this is correct 
cols=mat3(:,2);
vals=mat3(:,3);

bcd=n/numstat; % numer of non-zero cova matrix elemsnts per station

DATall=[];
TDATall=[];
SYNall=[];
TSYNall=[];
allstatdiag=[];

for i=1:numstat  %%%%%%%%% Loop over stations

onestat=zeros(bb,bb);
indx1=bcd*(i-1)+1; indx2=bcd*i;
for j=indx1:indx2 
onestat(rows(j-bcd*(i-1)),cols(j-bcd*(i-1)))=vals(j);
end



% if (i==1)
% figure 
%  imagesc(onestat,'CDataMapping','scaled')
%  colorbar
%  title (' inverted COVA 1 station')    
% end

onestatdiag=diag(onestat);
allstatdiag=[allstatdiag;onestatdiag]; 



%DAT=[]
file=[statcodes{i} 'fil.dat'];  %%%%%%%Loading OBS data %%%%%  
ST=load(file);
dt=ST(2,1)-ST(1,1);
N=ST(:,2); E=ST(:,3);Z=ST(:,4);
%N=N .* taper(a,0.2);E=E .* taper(a,0.2);Z=Z .* taper(a,0.2); % taper

DAT = [N' E' Z'];
%DAT = [E' E' E'];
DATall = [DATall  DAT]; 
DATplot= DAT/ max(max(DAT));

file=[statcodes{i} 'syn.dat'];  %%%%%%%Loading SYN data %%%%%  
ST=load(file);
N=ST(:,2); E=ST(:,3);Z=ST(:,4);
%N=N .* taper(a,0.2);E=E .* taper(a,0.2);Z=Z .* taper(a,0.2); % taper

SYN = [N' E' Z'];
SYNall = [SYNall  SYN];
SYNplot= SYN/ max(max(SYN));


%% Cholcov
%Symmetrization
%onestat=(onestat + onestat')./2.; %correct symmetrization NEEDED for Choleski. CHECK how it modifies inversion if NOT applied ????!!!!

% figure 
% imagesc(onestat,'CDataMapping','scaled')
% colorbar
% title ([' Cd inverted matrix ' num2str(i)])

% if(i==selstnum)
%     DD=cholcov(onestat);
% figure 
% imagesc(DD,'CDataMapping','scaled')
% colorbar
% title ([' Cholcov matrix ' num2str(i)])
% end


[T,num]=cholcov(onestat);
if (num ~= 0)
disp('num ~= 0, removing negative eigenvalues')    
[T,num]=cholcov(nearestSPD(onestat)); % opyright (c) 2013, John D'Errico
num; %num should be 0 for OK run
end
num

% Standardized DAT (application of Choleski)
TDAT = T * DAT';  
TDATplot=TDAT' / max(max(TDAT'));
TDATall=[TDATall TDAT'];


% Standardized SYN  (application of Choleski)
TSYN = T * SYN';  
TSYNplot=TSYN' / max(max(TSYN'));
TSYNall=[TSYNall TSYN'];




% Plot seismograms
if(i==selstnum)
figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
plot(TDATplot) 
title(['standardized DAT blue, non-stand DAT red at station' num2str(i)])
hold
plot(DATplot,'r')

figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
plot(DATplot) 
title(['NON standardized DAT  blue, NON-stand SYN red at station' num2str(i)])
hold
plot(SYNplot,'r')

% % figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
% % plot(TSYNplot) 
% % title(['standardized SYN blue, non-stand SYN red' num2str(i)])
% % hold
% % plot(SYNplot,'r')

figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
plot(TDATplot) 
title(['standardized DAT blue and standardized SYN red at station' num2str(i)])
hold
plot(TSYNplot,'r')
end % END of IF plotting seismo

% ***************Calculate Fourier amplitude pectra **************************
      fs=1/dt;    % fs sampling freq =  1/dt 
%      xlowlim=1;    % min freq; 1 means freq 0 Hz; 31 means 30 df       
%     flowlim=(xlowlim-1)*fs/length(DAT(1:3072))
%      flowlim=(xlowlim-1)*fs/length(DAT);

%       x=DAT(1:1024);fs=1/dt;    %%%%%%% ALTERNATIVE method is the same !! 
%       xdft = fft(x);
%       P2=abs(xdft/a);
%       P1 = P2(1:a/2+1);
%       P1(2:end-1) = 2*P1(2:end-1);
%       freq = fs*(0:(a/2))/a;
%       spTDAT=abs(xdft);
%       spTDATplot=spDAT/max(spTDAT);

      x=DAT;
      xdft = fft(x);% assume x is even length a
      xdft = xdft(1:length(x)/2+1);
      freq = 0:fs/length(x):fs/2; % from 0 with step df=1/T to Nyquist (1/(2dt)), all in Hz
      spDAT=abs(xdft);
      spDAT=smooth(spDAT);
      spDATplot=spDAT/max(spDAT);
      

      x=TDAT;
      xdft = fft(x);
      xdft = xdft(1:length(x)/2+1);
      freq = 0:fs/length(x):fs/2;
      spTDAT=abs(xdft);
      spTDAT=smooth(spTDAT);      
      spTDATplot=spTDAT/max(spTDAT);

      
      x=SYN;
      xdft = fft(x);% assume x is even length a
      xdft = xdft(1:length(x)/2+1);
      freq = 0:fs/length(x):fs/2; % from 0 with step df=1/T to Nyquist (1/(2dt)), all in Hz
      spSYN=abs(xdft);
      spSYN=smooth(spSYN);
      spSYNplot=spSYN/max(spSYN);
      
      x=TSYN;
      xdft = fft(x);
      xdft = xdft(1:length(x)/2+1);
      freq = 0:fs/length(x):fs/2;
      spTSYN=abs(xdft);
      spTSYN=smooth(spTSYN);
      spTSYNplot=spTSYN/max(spTSYN);

      

% ***************Plot spectra **************************
 if(i==selstnum)
            
%       figure
%       %plot(freq,spTDATplot);
%       semilogy(freq,spTDATplot);
%       xlabel('Hz');
%       title(['SPECTRA DAT stand blue, DAT non-stand red ' num2str(i)])
%       hold 
%       %plot(freq,spDATplot,'r');
%       semilogy(freq,spDATplot,'r');


%       figure
%       %plot(freq,spTDATplot);
%       semilogy(freq,spTSYNplot);
%       xlabel('Hz');
%       title(['SPECTRA SYN stand blue, SYN non-stand red at station' num2str(i)])
%       hold 
%       %plot(freq,spDATplot,'r');
%       semilogy(freq,spSYNplot,'r');

      figure
      %plot(freq,spDATplot);
      semilogy(freq,spDATplot);
      xlabel('Hz');
      title(['SPECTRA DAT non-stand blue, SYN non-stand red at station' num2str(i)])
      hold 
      %plot(freq,spSYNplot,'r');
      semilogy(freq,spSYNplot,'r');
      xlim([0.01 1])
      ylim([1e-3  1e0])
      
      figure
      %plot(freq,spTDATplot);
      semilogy(freq,spTDATplot);
      xlabel('Hz');
      title(['SPECTRA DAT stand blue, SYN stand red at station' num2str(i)])
      hold 
      %plot(freq,spDATplot,'r');
      semilogy(freq,spTSYNplot,'r');
      xlim([0.01 1])
      ylim([1e-3  1e0])

% *****************************************************
 end % End of IF plot for station selstnum PLOTTING of SPECTRA

end % END of loop over stations

figure 
plot(allstatdiag)
title('Cdinv all stations  diagonal')

% Processing all stations 

RESall=DATall-SYNall;
TRESall=TDATall-TSYNall;

% VARIANCE REDUCTION
varredNORM=1. - norm(RESall)/norm(DATall);
varred_classical    =1. - ((norm(RESall))/(norm(DATall)))^2
varredNORM1=1. - norm(TRESall)/norm(TDATall);
varred_standardized =1. - ((norm(TRESall))/(norm(TDATall)))^2

% aRES=autocov(RESall,a2);
% aTRES=autocov(TRESall,a2);
% aRESplot=aRES(1,:)/max(aRES(1,:));
% aTRESplot=aTRES(1,:)/max(aTRES(1,:));
% figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
% plot(aTRESplot) 
% title(['corr all, stand blue, non-stand red ' num2str(i)])
% hold
% plot(aRESplot,'r')


for i=1:numstat
if(i==selstnum)
% extracting station selstnum, components N,E,Z
row=100; % < 1024                 %%%SELECTABLE ????????????
lim1N=(i-1)*a+1;lim1E=lim1N+a;lim1Z=lim1E+a;
lim2N=lim1N+a-1;lim2E=lim2N+a;lim2Z=lim2E+a; 

RES=RESall;
staN=RES(1,lim1N:lim2N);staE=RES(1,lim1E:lim2E);staZ=RES(1,lim1Z:lim2Z);
aNN=autocov(staN,a);aEE=autocov(staE,a);aZZ=autocov(staZ,a);
aNNplot=aNN(row,:)/max(aNN(row,:));
aEEplot=aEE(row,:)/max(aEE(row,:));
aZZplot=aZZ(row,:)/max(aZZ(row,:));
aplot=[aNNplot aEEplot aZZplot ];

RES=TRESall;
staN=RES(1,lim1N:lim2N);staE=RES(1,lim1E:lim2E);staZ=RES(1,lim1Z:lim2Z);
aNN=autocov(staN,a);aEE=autocov(staE,a);aZZ=autocov(staZ,a);
aNNplot=aNN(row,:)/max(aNN(row,:));
aEEplot=aEE(row,:)/max(aEE(row,:));
aZZplot=aZZ(row,:)/max(aZZ(row,:));
Taplot=[aNNplot aEEplot aZZplot ];

figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
plot(Taplot) 
title(['corrrow100, stand blue, non-stand red stat:' num2str(i)])
hold
plot(aplot,'r') 
end % End of IF plot for PLOTTING
end



 %  disp ('All done !  WEIGHTS  missing stations NOT considered')
 %  disp (        'long parts of record selected')
