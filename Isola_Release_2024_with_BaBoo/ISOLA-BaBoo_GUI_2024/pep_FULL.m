% Covariance matrix (cova) FULL  = auto- and cross-covariance
% Cd_inv is created directly in COO format, no need of large matrix 

% clear all
% close all
format shortG

% g=[4 5; 6 7]
% c=[1 2; 2 1]
% cinv=inv (c) * 1000
% a=inv(g' *cinv * g)
% return


%% load data
disp ('Warning: order the stations as in allstat.dat!!!!!!!!!! ')
%disp ('Warning: noise and signal must have the same length, same instr correction, same filtration and same dt!! ')
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
bbb=a*3*numstat;
acovzero=zeros(a);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cova expon (for auxiliary stabilization) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  decay=100; % HOW to SETUP DELAY ??? (the smaller delay = the greater attenuation) 1e10 is equiv to no atten
 for i=1:a % loop for rows
  for j=1:a % loop for columns
    hbase(i,j) = 1. *  exp( - abs(i-j)/ decay); 
%    hbase(i,j) = bb*exp(-abs(i-j)/decay1)*cos(2*pi*(i-j)/EL1) + (1-bb)*exp(-abs(i-j)/decay2)*cos(2*pi*(i-j)/EL2); 
  end
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selstnum=17;
strangenum= 100

allstatdiag=[];
%allstatvari=[];
allstatCOO=[];
for i=1:numstat
file=[statcodes{i} 'fil.dat'];  %%%%%%%Loading OBS data %%%%% IF NOT then GUI will not need run of NOcova!  Check ALSO !!! DAT below!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
ST=load(file);
Nobs=ST(:,2); Eobs=ST(:,3);Zobs=ST(:,4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
file=[statcodes{i} 'res.dat'];  %%%%%%%%%%%%ATTENTION THINK about this option !!!!!!!!!!???????!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% I could also make FILNOISE displ but in another freq band than inverted signal filSIGNAL%%%%%%%%%%%%%%%% 
ST=load(file);

N=ST(:,2); E=ST(:,3);Z=ST(:,4);

% N=zeros(a,1);E=zeros(a,1);Z=zeros(a,1);
% nus1=1;nus2=200;
% nusnum=nus2-nus1+1
% N(nus1:nus2)=ST(nus1:nus2,2); E(nus1:nus2)=ST(nus1:nus2,3);Z(nus1:nus2)=ST(nus1:nus2,4);

%N=N .* taper(a,0.2);E=E .* taper(a,0.2);Z=Z .* taper(a,0.2); % taper

vari = [var(N,1) var(E,1) var(Z,1)]; % single-number variances of N,E,Z

% nus1=1;nus2=200;
% nusnum=nus2-nus1+1
% aNN=zeros(a,a);aEE=zeros(a,a);aZZ=zeros(a,a);
% aNN(nus1:nus2,nus1:nus2)=autocov(N,nusnum);
% aEE(nus1:nus2,nus1:nus2)=autocov(E,nusnum); 
% aZZ(nus1:nus2,nus1:nus2)=autocov(Z,nusnum); % covariance matrices
% CAUTION if using zeros, then diable next line !!!!!!!!!!!
aNN=autocov(N,a);aEE=autocov(E,a); aZZ=autocov(Z,a); % covariance matrices

%Alternative way to autocov  using xcov and Toeplitz
%rNN=xcov(N,N,'biased');  raux=rNN(a:(2*a-1)); aNN=toeplitz(raux); % = the ALTERNATIVE to autocov; usable because NN is symmetric around 0 lag 

rNE=xcov(N,E,'biased');                              %cross-covariance matrices 
rcol1=flip(rNE(1:a)'); rrow1=rNE(a:2*a-1);
aNE=toeplitz(rcol1,rrow1);

rNZ=xcov(N,Z,'biased');
rcol1=flip(rNZ(1:a)'); rrow1=rNZ(a:2*a-1);
aNZ=toeplitz(rcol1,rrow1);

rEN=xcov(E,N,'biased');
rcol1=flip(rEN(1:a)'); rrow1=rEN(a:2*a-1);
aEN=toeplitz(rcol1,rrow1);

rEZ=xcov(E,Z,'biased');
rcol1=flip(rEZ(1:a)'); rrow1=rEZ(a:2*a-1);
aEZ=toeplitz(rcol1,rrow1);

rZN=xcov(Z,N,'biased');
rcol1=flip(rZN(1:a)'); rrow1=rZN(a:2*a-1);
aZN=toeplitz(rcol1,rrow1);

rZE=xcov(Z,E,'biased');
rcol1=flip(rZE(1:a)'); rrow1=rZE(a:2*a-1);
aZE=toeplitz(rcol1,rrow1);


%% Optionally summed with EXPON matrix; this and decay 10 suppresses high-freq oscillations of standardized seismo
%  aNN=aNN + vari(1) .* hbase; % THIS DOUBLES DIAGONAL 
%  aEE=aEE + vari(2) .* hbase;
%  aZZ=aZZ + vari(3) .* hbase;
%  aNN=aNN ./2; aEE=aEE ./2; aZZ=aZZ ./2; % removes the doubling

% 
% Optionally multiplying by EXPON (This often stabilizes difficult non-invertible cases, but makes result closer to diagonal) 
% If this part is absent, standardized seimo are too noisy for NN,EE,ZZ and
% even non-sense results if using all components
% China deep data fil needs this with decay=100. Decay=1000 is still too noisy standardized. 
% aNN=aNN .* hbase;
% aEE=aEE .* hbase;
% aZZ=aZZ .* hbase;
%  
% aNE=aNE .* hbase;
% aNZ=aNZ .* hbase;
% aEN=aEN .* hbase;
% aEZ=aEZ .* hbase;
% aZN=aZN .* hbase;
% aZE=aZE .* hbase;

% If EXP does not help, some or all non-diagoinal (inter-component) corss-cova sub-blocks must be zeroed 
%aNE=acovzero; aNZ=acovzero;
%aEN=acovzero; aEZ=acovzero;
%aZN=acovzero; aZE=acovzero;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  BASIC OPTIONs to define cova matrix : all or only NN,EE,ZZ ???
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%    onecov = [aNN aNE aNZ; aEN aEE aEZ; aZN aZE aZZ];
%    posnum=a^2*9*numstat;                     % possible number of elements

%As in code COMPVAR =  only diagonal yet unconstant matrix, variances of components 
%    aNN=eye(a)*vari(1);aEE=eye(a)*vari(2);aZZ=eye(a)*vari(3);
%    onecov=blkdiag(aNN,aEE,aZZ);
%    posnum=a*3*numstat;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

    onecov=blkdiag(aNN,aEE,aZZ);
    posnum=a^2*3*numstat;   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%if (i==selstnum)
% % Plot one correlation trace
% % max11=max(onecov(:)); %maximum of the whole matrix
% % onecovnormalized=onecov/max11;     % SHOULD WE NORMALIZE all these 3-comp BLOCKS  to same maximum =1??? not ??
% figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
% plot(onecov(1,:)) 
% title('correlation 1 station, 1 row ')
%%end


if (i==selstnum)
figure 
imagesc(onecov,'CDataMapping','scaled')
%imagesc(hinvabs,'CDataMapping','scaled')
colorbar
title (['  COVA before inversion at station ' num2str(i)])
end

%allstatvari=[allstatvari,vari];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INVERSION

% with water-level correction (add small numbers on diagonal)        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% water level is always needed when inlcuding cross-component covariance,
% e.g NE
before = max(max(onecov));
% strangenum= 100 %100 je vshodne pokud NN,EE,ZZ bez hbase, ale vysledk inv1 pro 1000, 10000 jsou ruzne, VR klesa 
epsilon=before /strangenum;                     
tmpmat=eye(a*3,a*3) .* epsilon;  
onecov = onecov + tmpmat;

rcond(onecov);
onestat=inv(onecov); %  Cd_inverted for 1 station (3 comp); can be plotted, analyzed... it is full matrix

%onestat = onestat  ./ strangenum;  %posterior compensation for arbitrariness of strangenum; this is a MUST

% onestat=onestat ./ 100.; %         ARTIFICIAL  to make UNC level approx same as without COVA [using old vardat estmate] 
                         %         division by large number increases uncertainty (and spread of solutions)           
                         % for this code (FULL) this division should NOT be applied 

onestatdiag=diag(onestat);
                         
% test = onecov * onestat; % ma byt 1
% disp('Is it identity matrix? min and max:')
% max(max(test))
% min(min(test))
% disp(isequal(test,eye(bb)))
% 

%if (i==selstnum)
% figure 
% imagesc(onestat,'CDataMapping','scaled')
% colorbar
% title (' inverted COVA 1 station ')
%end

% Zeroing  values of small (absolute) values. It is IMPOSSIBLE. It destroys positive definite matrix.
%  m36=max(max(onestat))/1000;
%  onestat(abs(onestat) < m36) = 0; 
%Symmetrization                               It does not help    
%onestat=(onestat + onestat')./2.; %correct symmetrization 
 
% figure 
% imagesc(onestat,'CDataMapping','scaled')
% %imagesc(hinvabs,'CDataMapping','scaled')
% colorbar
% title (' inverted COVA 1 station AFTER ZEROING')

%if(i==selstnum)
%Cholcov!!!!!!!!!!!!!!!    
%DAT = [N' E' Z'];
DAT = [Nobs' Eobs' Zobs'];
%Symmetrization
onestat=(onestat + onestat')./2.; %correct symmetrization NEEDED for Choleski. CHECK how it modifies inversion if NOT applied ????!!!!
%% Symmetry test (must be = 1)
disp(isequal(onestat,onestat'))
%%%%%
% Standardized data (application of Choleski)
[T,num]=cholcov(onestat);
num
if (num ~= 0)
disp('num ~= 0, removing negative eigenvalues')    
%[T,num]=cholcov(onestat + 1e-14*eye(size(onestat))); % This does not help
% The nearestSPD removes negative eigenvalues that prevented cholcov working
[T,num]=cholcov(nearestSPD(onestat)); % opyright (c) 2013, John D'Errico
num %num should be 0 for OK run
end

%num % 0 for OK
TDAT = T * DAT';  
% Plot standardized data (application of Choleski) and original data
TDATplot=TDAT' / max(max(TDAT'));
DATplot= DAT/ max(max(DAT));

if (i==selstnum)
figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
plot(TDATplot) 
title(['standardized blue, non-stand red at station' num2str(i)])
hold
plot(DATplot,'r')
end


[rows,cols,vals]=find(onestat);
rows=rows+bb*(i-1);cols=cols+bb*(i-1);
statCOO=[rows,cols,vals];              % COO matrix for 1 station

allstatCOO=[allstatCOO;statCOO];       % concatenating COO for all statoins 
allstatdiag=[allstatdiag;onestatdiag];       
end %of STATION LOOP
allstatCOO; % screen output if without ;
[bbbb,m2]=size(allstatCOO); % bbbb=number of non-zero elements


figure
plot(allstatdiag)
title('Cdinv all stations  diagonal')

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
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output of inverted COVA into an ascii file (hinv.bin), COO format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Output
     disp(['Elements on diagonal        ' num2str(a  *3*numstat)])  
     disp(['Possibly non-zero elements  ' num2str(posnum)])  
     disp(['Actually non-zero elements  ' num2str(bbbb)])
%% output
  % Printing  Cd-1 into a file (in sparse mode)
    % BINARY output (fast)
 fid=fopen('hinv.bin','w');
 fwrite(fid,allstatCOO,'double','ieee-le');
  disp ('hinv.bin BINARY FILE created = Cd-1')

fclose(fid);
  disp ('All done !')
