% Using covariance matrix AXCF of M. Hallo 
% Cd_inv is created directly in COO format, no need of large matrix 

%  clear all
%  close all
format shortG


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

numstat=length(statcodes)

% fid=fopen('..\green\station_aux.dat','r'); %when the last two character columns (stat and polarity) are deleted
% %fid=fopen('station.dat','r');
%   fgets(fid)
%   fgets(fid)
% sizeD = [5 Inf]; %prestoze mam 7 sloupcu ctu jen 5 do pole D
% D = fscanf(fid,'%f %f %f %f %f',sizeD);
%     fclose(fid);
%     D
% dista=D(5,:) % THIS WORKS but needs station_aux. 

% This is much better:
fid=fopen('..\green\station.dat','r');
%sizeD = [7 Inf]; 
D = textscan(fid,'%f %f %f %f %f %s %c','HeaderLines',2);
fclose(fid);
D
dista=D{5} % CAUTION here must be {}, not (), because we have MIXED formats




% magicL1= 7% Single constat L1 for all stations
% statL=zeros(1,numstat) + magicL1

for i = 1:numstat
statval(i)=dista(i)/25.;    % Empirical formula from Hallo & Gallovic assuming 10% velocity error
if (statval(i) <= 1.5)
    statL(i) = 1.5; %code can  make later the smallest L1= 3*dt
else
    statL(i) =  statval(i);
        end
end
%%%tf = isequal(statL,statval);
statL


a=1024; % 1024; % 4 for testing      !!!!!!!!FIXED 1024!!!!!!!!!!!!
%disp ('CONSTANT number of points '); a
bb=a*3;
bbb=a*3*numstat;
acovzero=zeros(a);

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
%decay % hbase is not used
selstnum=9
strangenum= 100 %10000000 % 100 is teh sme as in other methods



allstatdiag=[];
allstatCOO=[];
for i=1:numstat
file=[statcodes{i} 'fil.dat'];   
ST=load(file);
Nobs=ST(:,2); Eobs=ST(:,3);Zobs=ST(:,4);
%Nobs=Nobs .* taper(a,0.2);Eobs=Eobs .* taper(a,0.2);Zobs=Zobs .* taper(a,0.2); % taper

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%file=[statcodes{i} 'res.dat'];  %%%%%%%%%%%%ATTENTION THINK about this option !!!!!!!!!!???????!!!

file=[statcodes{i} 'fil.dat'];  %%%%%%%%%%%%ATTENTION THINK about this option !!!!!!!!!!???????!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% I could also make FILNOISE displ but in another freq band than inverted signal filSIGNAL%%%%%%%%%%%%%%%% 
ST=load(file);
time=ST(:,1);
dt=time(2)-time(1);
N=ST(:,2); E=ST(:,3);Z=ST(:,4);
%N=N .* taper(a,0.2);E=E .* taper(a,0.2);Z=Z .* taper(a,0.2); % taper

vari = [var(N,1) var(E,1) var(Z,1)]; % single-number variances of N,E,Z


% : ACF method: Cova matrices of individual stations/components
%aNN=axcf(N,statL(i),dt); aEE=axcf(E,statL(i),dt); aZZ =axcf(Z,statL(i),dt);
 
%  aNE=axcf(N,E,statL(i),statL(i),dt);
%  aNZ=axcf(N,Z,statL(i),statL(i),dt);
%  
%  aEN=axcf(E,N,statL(i),statL(i),dt);
%  aEZ=axcf(E,Z,statL(i),statL(i),dt);
%  
%  aZN=axcf(Z,N,statL(i),statL(i),dt);
%  aZE=axcf(Z,E,statL(i),statL(i),dt);

 % : SACF method: Cova matrices of individual stations/components
 Tdom=50 %dominant signal length in seconds used only in SACF (not needed in ACF) 
 aNN=saxcf(N,statL(i),dt,Tdom); aEE=saxcf(E,statL(i),dt,Tdom); aZZ =saxcf(Z,statL(i),dt,Tdom);

 
%% Optionally summed with EXPON matrix % NEVIM JAK TO UDELAT, misto vari(i) by meselo byt neco z aNN????????!!!!!!!!!
%  aNN=aNN + vari(1) .* hbase; % THIS DOUBLES DIAGONAL 
%  aEE=aEE + vari(2) .* hbase;
%  aZZ=aZZ + vari(3) .* hbase;
%  aNN=aNN ./2; aEE=aEE ./2; aZZ=aZZ ./2; % removes the doubling
% 
% Optionally multiplying by EXPON (This often stabilizes difficult non-invertible cases, but makes result closer to diagonal) 
% aNN=aNN .* hbase;         %This can even damage results; check always standardized seismograms 
% aEE=aEE .* hbase;
% aZZ=aZZ .* hbase;
% 
% aNE=aNE .* hbase;
% aNZ=aNZ .* hbase;
% aEN=aEN .* hbase;
% aEZ=aEZ .* hbase;
% aZN=aZN .* hbase;
% aZE=aZE .* hbase;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  BASIC OPTIONs to define cova matrix : all or only NN,EE,ZZ ???
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%    onecov = [aNN aNE aNZ; aEN aEE aEZ; aZN aZE aZZ];
%    posnum=a^2*9*numstat                     % possible number of elements

    onecov=blkdiag(aNN,aEE,aZZ);
    posnum=a^2*3*numstat;   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

%%if (i==selstnum)
%% Plot one correlation trace
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% COVA  with water-level correction (add small numbers on diagonal)        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
before = max(max(onecov));
epsilon=before /strangenum;                    
tmpmat=eye(a*3,a*3) .* epsilon;  
onecov = onecov + tmpmat;

% INVERSION
rcond(onecov);
onestat=inv(onecov); %  Cd_inverted for 1 station (3 comp); can be plotted, analyzed... it is full matrix


% onestat = onestat  ./ strangenum;  %This works as posterior compensation for arbitrariness of strangenum; this is a MUST ???????????????
% Now without this AXCF is similar to other codes and also makes use of
% strangenum=100

% If this line is commented, the uncertainty scatter is extremely small.
% There is not much REASON for this division; Other methods work without.
 
 
 %onestat = onestat  ./ epsilon; % No, this does not keep onestat constant  when changing epsilon

%onestat=onestat ./ 100.; %         ARTIFICIAL  adjustment of UNC level to be comparable with other methods  
%         division increases uncertainty (and spread of solutions);  effect of Cd remains unchanged 
%onestat=onestat .* 100.; %         ARTIFICIAL  adjustment of UNC level to be comparable with other methods 
%         multiplication decreases uncertainty (and spread of solutions); effect of Cd remains unchanged


%Attention: if not compensated, absolute uncertainty scales with strangenum, which is totally impossible
% If compensated, it does not iomlpy that results are totally identical!
% When strangenum is increased, epsilon decreased, Cdinv has more non-zero elements, inversion
% is less "damped" (less regularized), but effects upon inversion and uncertainty are minimal.
% Vzdy by si clovek mel zkouset rzna epsilon a videt konvergenci kdyz strangenum silne roste a vsyledky se uz nelisi
% strangenum 1000 or 100000 give almost no difference
% strangenum 100 is somewhat different from 1000 



% % If changing epsilon e-9 to e-11 or e-12, here I divide by 100 or 1000 to get maximum
% % e+11/100 = e9 and e12/1000 = e9 , and can thus obtain always same maximum
% % indpendently of strangenum used in definition of the epsilon 
% % BUT : it  does not remove strong (2 orders of
% % magnitude) dominance of the disagonal compared to background)

onestatdiag=diag(onestat);

% if (i==selstnum)
% figure 
% imagesc(onestat,'CDataMapping','scaled')
% colorbar
% title (' inverted COVA 1 station ')
% end
% max(max(onestat));

% figure
% ass=size(onestat);
%  for i=1:ass(1)
%  dia(i)=onestat(i,i);
%  end
%  plot(dia)
%   title('diagonal of inverted cova')
 

% test = onecov * onestat; % ma byt 1
% disp('Is it identity matrix? min and max:')
% max(max(test))
% min(min(test))
% disp(isequal(test,eye(bb)))


% Zeroing  values of small (absolute) values ??? SOMETIMES IMPOSSIBLE destroys positive definite matrix
% m36=max(max(onestat))/1000;
% onestat(abs(onestat) < m36) = 0; 

%Symmetrization
%onestat=(onestat + onestat')./2.; %correct symmetrization 


%if(i==selstnum)
%Cholcov!!!!!!!!!!!!!!!    
%DAT = [N' E' Z'];
DAT = [Nobs' Eobs' Zobs'];
%Symmetrization
onestat=(onestat + onestat')./2.; %correct symmetrization NEEDED for Choleski. CHECK how it modifies inversion if NOT applied ????!!!!
%% Symmetry test (must be = 1)
%disp(isequal(onestat,onestat'));
%%%%%

% INTERESTING: Even if the Cholcov test fails, I can generate HINV.BIN,
% make inversion and make UNC analysis.

% Standardized data (application of Choleski)
[T,num]=cholcov(onestat);
if (num ~= 0)
%[T,num]=cholcov(onestat + 1e-14*eye(size(onestat))); % This does not help
% The nearestSPD removes negative eigenvalues that prevented cholcov working
[T,num]=cholcov(nearestSPD(onestat)); % opyright (c) 2013, John D'Errico
end
num %num must be 0 for OK positive definite

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
% title('all non-zero values of Cd_inv from  all 3-comp stations')

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


  
  

  
  

