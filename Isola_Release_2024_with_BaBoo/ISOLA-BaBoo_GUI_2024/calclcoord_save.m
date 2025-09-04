function [ux,uy,uz,strdis] = calclcoord(strike,dip,rake,nSources,distanceStep,refsource,depth) 
% Create a dipping line of sources for ISOLA
% Syntax
% calclcoord(strike,dip,rake,nSources,distanceStep,refsource) 
% e.g. calclcoord(40,45,60,12,2,1) 
% 15/12/2018
% v.0.1

% names as in Aki&Richards
lamda=rake;phi=strike;delta=dip;


%%  compute distance from reference sources
strdis=zeros(nSources,1);
   for i=1:nSources
      strdis(i)=distanceStep*(i-refsource);
   end

%% compute 3D coordinates of these points 
ux=zeros(nSources,1);uy=zeros(nSources,1);uz=zeros(nSources,1);

   for ii=1:nSources
       
      U=strdis(ii);
      
      ux(ii)=U*(cosd(lamda)*cosd(phi)+cosd(delta)*sind(lamda)*sind(phi));
      uy(ii)=U*(cosd(lamda)*sind(phi)-cosd(delta)*sind(lamda)*cosd(phi));
      uz(ii)=U*(-sind(lamda)*sind(delta))-depth;

   end
 
%% plot
figure
% plot the system of coordinates
Xs1=[0  0   0   0  0  10   10    0]; Ys1=[0 10  10   0  0   0    0    0]; Zs1=[0  0 -10 -10  0   0  -10  -10];
Xs2=[  0  -10  -10  0   0       0  0]; Ys2=[  0    0    0  0   -10   -10  0]; Zs2=[-10  -10    0  0   0     -10  -10];

hold on

plot3(Ys1,Xs1,Zs1,'k--'); plot3(Ys2,Xs2,Zs2,'k--')

plot3(-uy,ux,uz,'bo-')

% plot the reference source
plot3(-uy(refsource),ux(refsource),uz(refsource),'r*')

            xlabel('Y (km)')
            ylabel('X (km)')
            zlabel('Z (km)')
            title('X-Y-Z')
            grid on
% 
% % check with plane
% cd gmtfiles
% 
%   load sour.dat
% 
% cd ..
% %figure
% plot3(sour(:,1),sour(:,2),-sour(:,3),'sr')
% 
% %plot3(rX,rY,rZ,'*m')

hold off;rotate3d on;axis square
%%






