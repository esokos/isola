clear variables

ANX=load('ANXfil.dat'); NS_ANX=ANX(:,2); time_ANX=ANX(:,1);

PVO=load('PVOfil.dat'); NS_PVO=PVO(:,2); time_PVO=PVO(:,1);

DRO=load('DROfil.dat'); NS_DRO=DRO(:,2); time_DRO=DRO(:,1);

GUR=load('GURfil.dat'); NS_GUR=GUR(:,2); time_GUR=GUR(:,1);

subplot 411
plot(time_ANX,NS_ANX)
grid on;title('ANX')

subplot 412
plot(time_PVO,NS_PVO)
grid on;title('PVO')

subplot 413
plot(time_DRO,NS_DRO)
grid on;title('DRO')

subplot 414
plot(time_GUR,NS_GUR)
grid on;title('GUR')
dt=time_GUR(2)-time_GUR(1)

%%

ANX_L1=2; % depends on station distance and model sigma
PVO_L1=2;
DRO_L1=2;
GUR_L1=2;

T=30;

%%

CeANX=sparse(saxcf(NS_ANX,ANX_L1,dt,T));
CePVO=sparse(saxcf(NS_PVO,PVO_L1,dt,T));
CeDRO=sparse(saxcf(NS_DRO,DRO_L1,dt,T));
CeGUR=sparse(saxcf(NS_GUR,GUR_L1,dt,T));

% CeANX=sparse(axcf(NS_ANX,ANX_L1,dt));
% CePVO=sparse(axcf(NS_PVO,PVO_L1,dt));
% CeDRO=sparse(axcf(NS_DRO,DRO_L1,dt));
% CeGUR=sparse(axcf(NS_GUR,GUR_L1,dt));

h_noninv=blkdiag(CeANX,CePVO,CeDRO,CeGUR);

%h_noninv=CeANX;

% 
figure

imagesc(h_noninv)  %fig2
colorbar


%% 
%    [m,n]=size(h_noninv);
%    tt=eye(m,n)/1000000000;
   hinv=inv(h_noninv);
% hinv=inv(h_noninv);
f=figure;
colormap pink
imagesc(hinv) % fig. 3
colorbar
colormap(f, flipud(colormap(f)))
a=length(find(hinv));



figure
imagesc(CeANX)  % fig4
colorbar


iiii=inv(CeANX);

figure
imagesc(iiii)  % fig5
colorbar


%% plot perturbeded signal
% % Plot perturbed signal
% % CeGUR=axcf(NS_GUR,GUR_L1,dt);
% % 
% % clear CeGUR
% %  this part works 06.11.2021
% CeGUR=saxcf(NS_GUR,GUR_L1,dt,T);
% 
% 
% % mirror the upper part to lower part   this is needed !!
% upCeGUR=triu(CeGUR);
% newGUR=upCeGUR+upCeGUR';
% 
% %  
% npert = 100;
% R=mvnrnd(NS_GUR,newGUR,npert);
% size(R)
% figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
% plot(R')
% title('Perturbed signal')

%%
% clear CeGUR
% in this part we test the AXCF function ...
% this function doesn't need the "trick" i.e. to copy the upper part of the
% matrix to lower part in order to be identical 
%
% 6.11.2021
%
% According to M.Halo if water level correction is needed it must be
% per component 
% 
CeGUR=sparse(axcf(NS_GUR,GUR_L1,dt));

hinv=inv(CeGUR);

% % mirror the upper part to lower part   this is needed !!
% upCeGUR=triu(CeGUR);
% newGUR=upCeGUR+upCeGUR';

%  
npert = 100;
R=mvnrnd(NS_GUR,CeGUR,npert);
size(R)
figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
plot(R')
title('Perturbed signal')
%% test HALO CHolecky with 1 comp

CeANX=axcf(NS_ANX,ANX_L1,dt);

% make it symmetric using the trick  this produces and inverted that works with Chol  !!!!
upCeANX=triu(CeANX);
sym_CeANX=upCeANX+upCeANX';

newinv=inv(sym_CeANX);
%newinv=inv(CeANX);

% make it symmetric using the trick 
% uph_noinv=triu(newinv);
% sym_newinv=uph_noinv+uph_noinv';
% newinv_eig=eig(sym_newinv);
[T,num]=cholcov(newinv);

 

DATA = [NS_ANX'];%   NS_PVO'   NS_DRO'   NS_GUR'   ];

whos DATA newinv T

T2 = T * DATA';  

fig(2)=figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
plot(T2') 
title('standardized data (1 stanic)')
hold
plot(DATA*10000,'r')



%% apply CHolecky
% this works  6.11.2021


CeANX=axcf(NS_ANX,ANX_L1,dt);
CePVO=axcf(NS_PVO,PVO_L1,dt);
CeDRO=axcf(NS_DRO,DRO_L1,dt);
CeGUR=axcf(NS_GUR,GUR_L1,dt);

h_noninv=blkdiag(CeANX,CePVO,CeDRO,CeGUR);

% test Cholecky of Ce
[T,num]=cholcov(h_noninv);
T
num
 
% % mirror the upper part to lower part   this is needed !!
% upCeGUR=triu(CeGUR);
% newGUR=upCeGUR+upCeGUR';

uph_noinv=triu(h_noninv);
newh_noninv=uph_noinv+uph_noinv';
issparse(newh_noninv)
newinv=inv(newh_noninv);
eig(newinv);
[T,num]=cholcov(newinv);




% make DATA vector  '
%DATA = [NS_ANX'   NS_PVO'   NS_DRO'   NS_GUR'   ];

DATA = [NS_ANX'   NS_PVO'   NS_DRO'   NS_GUR'   ];

whos DATA h_noninv T

T2 = T * DATA';  

fig(2)=figure('units','normalized','color',[1 1 1],'OuterPosition',[0.1,0.1,0.8,0.8]);
plot(T2') 
title('standardized data (4 stanic)')
hold
plot(DATA*10000,'r')



