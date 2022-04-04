function [] = hudsonnet(add,addpoints,addtext)

%%  Plot Hudson Net function
%   code is based on R code from RFOC package (Jonathan M. Lees) (https://rdrr.io/cran/RFOC/)
%   
% 
% v.1. 06/03/2018
% E.S.
%
%%

if ~exist('colint','var') || isempty(colint)
  colint='grey';
end

if ~exist('colext','var') || isempty(colext)
  colext='black';
end
 
p1=[0 1]; p2=[-4/3 -1/3]; p3=[0 -1]; p4=[4/3 1/3];
figure('Color','w')

% bmar=0.1;
% b0=4/3+bmar;
% bwid=2;lwid=1;   
% 
% plot(b0*[-1,1],b0*[-1,1])

line([-4/3,4/3],[-1/3,1/3])

hold

%% grid lines
ks=(-0.9:0.1:0.9); Ts=(-0.9:0.1:0.9);
 
   for i=1:length(Ts)

       ks0=(-1:0.01:1);
       tau0=0;
       v0=0;u0=0;
       
         for j=1:length(ks0)
           [u0,v0]=tk2uv(Ts(i),ks0(j));
           line(u0,v0)
         end
   end
% 
   for i=1:length(ks)
        
        Ts0=(-1:0.01:1);
        v0=0;u0=0;
        
          for j=1:length(Ts0) 
           [u0,v0]=tk2uv(Ts0(j),ks(i));
           line(u0,v0)
          end
   end
   
  
   %%
    [hp1u,hp1v]=tk2uv(1,0);     [hp2u,hp2v]=tk2uv(-1,0);
    [vp1u,vp1v]=tk2uv(0,1);     [vp2u,vp2v]=tk2uv(0,-1);

    line([hp1u hp2u],[hp1v hp2v]);  line([vp1u vp2u],[vp1v vp2v])
% 
    line([p1(1),p2(1)],[p1(2),p2(2)]);     line([p2(1),p3(1)],[p2(2),p3(2)])
    line([p3(1),p4(1)],[p3(2),p4(2)]);     line([p4(1),p1(1)],[p4(2),p1(2)])
% 
   [Volpu,Volpv]=tk2uv(0,1);    [DCpu,DCpv]=tk2uv(0,0);
   [CLVDpu,CLVDpv]=tk2uv(1,0);  [LVDpu,LVDpv]=tk2uv(-1,1/3);
   [CKpu,CKpv]=tk2uv(-1,5/9); 
%%
 
if addtext==1
       text(DCpu+0.02,DCpv-0.06,'DC')
       
       text(CLVDpu+0.04,CLVDpv,'-CLVD')
       text(-CLVDpu-0.04,CLVDpv,'+CLVD','HorizontalAlignment','right')
       
       text(Volpu,-Volpv-0.04,'-ISO','HorizontalAlignment','center')
       text(Volpu,Volpv+0.04,'+ISO','HorizontalAlignment','center')
       
       text(LVDpu-0.04,LVDpv,'+LVD','HorizontalAlignment','right')
       text(-LVDpu+0.04,-LVDpv,'-LVD')
       
       text(CKpu-0.04,CKpv,'+Crack','HorizontalAlignment','right')
       text(-CKpu+0.04,-CKpv,'-Crack')
end

%% add lines for polarity
[p11,p22]=tk2uv(0,0.5);
line([LVDpu,p11],[LVDpv,p22],'LineStyle',':','Color','r','LineWidth',3)
[p33,p44]=tk2uv(1,0.5);
line([p11,p33],[p22,p44],'LineStyle',':','Color','r','LineWidth',3)
%
[p11,p22]=tk2uv(0,-0.5);
line([-LVDpu,p11],[-LVDpv,p22],'LineStyle',':','Color','r','LineWidth',3)
[p33,p44]=tk2uv(-1,-0.5);
line([p11,p33],[p22,p44],'LineStyle',':','Color','r','LineWidth',3)


if addpoints==1
   plot(LVDpu,LVDpv,'o','MarkerFaceColor','b','MarkerSize',3)
   plot(-LVDpu,-LVDpv,'o','MarkerFaceColor','b','MarkerSize',3)
   plot(CKpu,CKpv,'o','MarkerFaceColor','b','MarkerSize',3)
   plot(-CKpu,-CKpv,'o','MarkerFaceColor','b','MarkerSize',3)
   plot(CLVDpu,CLVDpv,'o','MarkerFaceColor','b','MarkerSize',3)
   plot(-CLVDpu,CLVDpv,'o','MarkerFaceColor','b','MarkerSize',3)
   plot(DCpu,DCpv,'o','MarkerFaceColor','b','MarkerSize',3)
   plot(Volpu,-Volpv,'o','MarkerFaceColor','b','MarkerSize',3)
   plot(Volpu,Volpv,'o','MarkerFaceColor','b','MarkerSize',3)
   
end

%%
%hold off
axis square 
axis equal
axis off
