function [ux,uy,uz,strdis] = calclcoord(strike,dip,rake,nSources,distanceStep,refsource)%,depth) 
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
% %% if rake is negative 
% if rake < 0
%     %strdis=-1*strdis;
%    for i=1:nSources
%       strdis(i)=-distanceStep*(i-refsource);
%    end
% else
%    for i=1:nSources
%       strdis(i)=distanceStep*(i-refsource);
%    end
% end

%% compute 3D coordinates of these points
ux=zeros(nSources,1);uy=zeros(nSources,1);uz=zeros(nSources,1);

   for ii=1:nSources
       
      U=strdis(ii);
      
      ux(ii)=U*(cosd(lamda)*cosd(phi)+cosd(delta)*sind(lamda)*sind(phi));
      uy(ii)=U*(cosd(lamda)*sind(phi)-cosd(delta)*sind(lamda)*cosd(phi));
      uz(ii)=U*(-sind(lamda)*sind(delta));%-depth;

   end
 
