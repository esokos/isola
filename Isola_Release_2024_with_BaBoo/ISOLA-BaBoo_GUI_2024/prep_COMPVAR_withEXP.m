% Inverted covariance matrix, diagonal, each component has it own  variance^(-1)
% Cd_inv is created directly in COO format, no need of large matrix 

% clear all
% close all
format shortG


%% load data
% disp ('Warning: order the stations as in allstat.dat!!!!!!!!!! ')
% disp ('Warning: noise and signal must have the same length, same instr correction, same filtration and same dt!! ')
%statcodes={'PAZOI','PTEO','GRNL', 'PFVI'}; % both filNOISE and silSIGNAL must be availabe for these stations, e.g. PAZOIfilNOISE 
%statcodes={'YNB','WUC', 'BAQ', 'CN2','YIL','SYS','HUR', 'XFN', 'INCN', 'FUY', 'BCT','SAG','IMG', 'ADM','GJM','DL2','YAS','HSS', 'SRN', 'IZH','NKG'};
%statcodes={'YNB','WUC'} %, 'BAQ', 'CN2','YIL','SYS','HUR', 'XFN', 'INCN', 'FUY', 'BCT','SAG','IMG', 'ADM','GJM','DL2','YAS','HSS', 'SRN', 'IZH','NKG'}
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

%%
numstat=length(statcodes)

a=1024; % 1024; % 4 for testing      !!!!!!!!FIXED 1024!!!!!!!!!!!!
%disp ('CONSTANT number of points '); a
bb=a*3;
bbb=bb*numstat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cova expon (for auxiliary stabilization) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  decay=100; % HOW to SETUP DECAY ??? (the smaller decay = the greater attenuation) ??????????????????????????????????
 for i=1:a % loop for rows
  for j=1:a % loop for columns
    hbase(i,j) = 1. *  exp( - abs(i-j)/ decay); 
%    hbase(i,j) = bb*exp(-abs(i-j)/decay1)*cos(2*pi*(i-j)/EL1) + (1-bb)*exp(-abs(i-j)/decay2)*cos(2*pi*(i-j)/EL2); 
  end
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
decay 
selstnum=1;

allstatdiag=[];
%allstatvari=[];
allstatCOO=[];
for i=1:numstat
file=[statcodes{i} 'fil.dat'];   
ST=load(file);
Nobs=ST(:,2); Eobs=ST(:,3);Zobs=ST(:,4);
%Nobs=Nobs .* taper(a,0.2);Eobs=Eobs .* taper(a,0.2);Zobs=Zobs .* taper(a,0.2); % taper

file=[statcodes{i} 'res.dat'];  %%%%%%%%%%%%THINK about this option !!!!!!!!!!???????!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% I could also make FILNOISE displ but in another freq band than inverted signal filSIGNAL%%%%%%%%%%%%%%%% 
ST=load(file);
N=ST(:,2); E=ST(:,3);Z=ST(:,4);
%N=N .* taper(a,0.2);E=E .* taper(a,0.2);Z=Z .* taper(a,0.2); % taper

vari = [var(N,1) var(E,1) var(Z,1)];     % single-number variances of components
                            % now we get doagonal values of cd-inv 2 orders
                            % higher, misfit also 
                            % and so uncertainty is much smaller than in
                            % the IMPORTANT TEST below
% IMPORTANT TEST
%vari=[1.546959e-7 1.546959e-7 1.546959e-7] %for testing that is the same as isola without cova  
% I tested that with this hinv.bin I obtain all unc plots teh same as
% without Cd if 1.54..e-7 is the vardat estimate from norm [max amplitude at most dist station sqaured]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%method 1 = diagonal matrix 
% aNN=eye(a)*vari(1);aEE=eye(a)*vari(2);aZZ=eye(a)*vari(3);
%  onecov=blkdiag(aNN,aEE,aZZ); %  1 station 3 comp

%method 2 = summation with expon matrix ... creates full matrices NN,EE,ZZ
% aNN=eye(a)*vari(1);aEE=eye(a)*vari(2);aZZ=eye(a)*vari(3);
%  aNN=aNN + vari(1) .* hbase; % THIS DOUBLES DIAGONAL 
%  aEE=aEE + vari(2) .* hbase;
%  aZZ=aZZ + vari(3) .* hbase;
%  %aNN=aNN ./2; aEE=aEE ./2; aZZ=aZZ ./2; % removes the doubling CHYBA toto deli vse nejen diagobalu
% onecov=blkdiag(aNN,aEE,aZZ); %  1 station 3 comp; 

%method 3 = expon matrix ... creates full matrices NN,EE,ZZ
 aNN= vari(1) .* hbase;  
 aEE= vari(2) .* hbase;
 aZZ= vari(3) .* hbase;
onecov=blkdiag(aNN,aEE,aZZ); %  1 station 3 comp; 



if (i==selstnum)
figure 
imagesc(onecov,'CDataMapping','scaled')
%imagesc(hinvabs,'CDataMapping','scaled')
colorbar
title (['  COVA before inversion at station ' num2str(i)])
end

%allstatvari=[allstatvari,vari];

rcond(onecov);
onestat=inv(onecov); % Cdinv for one station


%onestat=onestat ./ 100.; %         ARTIFICIAL  to make UNC level approx same as without COVA [using old vardat estmate] 
%         division by large number increases uncertainty (and spread of solutions)           
%         should NOT be applied when using the single-constant disgonal matrix (as without COVA) 

onestatdiag=diag(onestat);

% test = onecov * onestat; % ma byt 1
% disp('Is it identity matrix? test should be 1:')
% max(max(test))
% min(min(test))
% disp(isequal(test,eye(bb)))

                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%method 2 % simple division insted of matrix inversion (tested that is the same as Method 1) 
% varinv=1./vari        
% aNN=eye(a)*varinv(1);aEE=eye(a)*varinv(2);aZZ=eye(a)*varinv(3);
% onestat=blkdiag(aNN,aEE,aZZ); %1 station 3 comp; can be plotted, analyzed... it is full matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if (i==selstnum)
% figure 
% imagesc(onestat,'CDataMapping','scaled')
% %imagesc(hinvabs,'CDataMapping','scaled')
% colorbar
% title (' inverted COVA 1 station ')
% end

%if(i==selstnum)
%Cholcov!!!!!!!!!!!!!!!    
%DAT = [N' E' Z'];
DAT = [Nobs' Eobs' Zobs'];
%Symmetrization
onestat=(onestat + onestat')./2.; %correct symmetrization NEEDED for Choleski. CHECK how it modifies inversion if NOT applied ????!!!!
%% Symmetry test (must be = 1)
%disp(isequal(onestat,onestat'));
%%%%%
% Standardized data (application of Choleski)
[T,num]=cholcov(onestat);
num
%num % 0 for OK
TDAT = T * DAT';  
% Plot standardized data (application of Choleski) and original data
TDATplot=TDAT' / max(max(TDAT'));
DATplot= DAT/ max(max(DAT));

% if(i==selstnum)
% figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
% plot(TDATplot) 
% title(['standardized blue, non-stand red at station' num2str(i)])
% hold
% plot(DATplot,'r')
% end


% Towards COO format; saving only non-zero values
[rows,cols,vals]=find(onestat);        
cols=cols+bb*(i-1);rows=rows+bb*(i-1);
statCOO=[rows,cols,vals];              % it is COO matrix

allstatCOO=[allstatCOO;statCOO];            % concatenating
allstatdiag=[allstatdiag;onestatdiag];       
end %of STATION LOOP
allstatCOO; % screen outut
[bbbb,m2]=size(allstatCOO); % bbbb=number of non-zero elements

% figure
% plot(allstatdiag)
% title('Cdinv all stations  diagonal')

% figure 
% plot(allstatCOO(:,3))
% title('Cdinv all stations, all non-zero values')
% 
% figure 
% plot(allstatCOO(:,1))
% title('col  1')
% 
% figure 
% plot(allstatCOO(:,2))
% title('col  2')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output of inverted COVA into an ascii file (hinv.bin), COO format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Output
     disp(['Elements on diagonal        ' num2str(a  *3*numstat)])  
     disp(['Possibly non-zero elements  ' num2str(a^2*3*numstat)])  
     disp(['Actually non-zero elements  ' num2str(bbbb)])
%% output
  % Printing  Cd-1 into a file (in sparse mode)
    % BINARY output (fast)
 fid=fopen('hinv.bin','w');
 fwrite(fid,allstatCOO,'double','ieee-le');
  disp ('hinv.bin BINARY FILE created = Cd-1')

fclose(fid);
  disp ('All done !')
