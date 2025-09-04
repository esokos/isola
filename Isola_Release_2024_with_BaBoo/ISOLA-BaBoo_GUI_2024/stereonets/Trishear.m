function frames = Trishear(yp,psect,tparam,sinc)
%Trishear plots the evolution of a 2D trishear fault propagation fold
%
%   USE: frames = Trishear(yp,psect,tparam,sinc)
%
%   yp = Datums or vertical coordinates of undeformed, horizontal beds
%   psect = A 1 x 2 vector containing the extent of the section, and the 
%           number of points in each bed 
%   tparam = A 1 x 7 vector containing: the x coordinate of the fault tip 
%           (entry 1), the y coordinate of the fault tip (entry 2), the
%           ramp angle (entry 3), the P/S (entry 4), the trishear angle
%           (entry 5), the fault slip (entry 6), and the concentration
%           factor (entry 7)
%   sinc = slip increment
%   frames = An array structure containing the frames of the fold evolution
%            You can play the movie again just by typing movie(frames)
%   
%   NOTE: Input ramp and trishear angles should be in radians
%         For reverse faults use positive slip and slip increment
%         For normal faults use negative slip and slip increment
%
%   Trishear uses function VelTrishear
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Extent of section and number of points in each bed
extent = psect(1); npoint = psect(2);
%Make undeformed beds geometry: This is a grid of points along the beds 
xp=0.0:extent/npoint:extent;
[XP,YP]=meshgrid(xp,yp);

% Model parameters
xt = tparam(1); %x fault tip
yt = tparam(2); %y fault tip
ramp = tparam(3);%Ramp angle
ps = tparam(4); %P/S
tra = tparam(5); %Trishear angle
m = tan(tra/2); %Tangent of half trishear angle
slip = tparam(6); %Fault slip
c = tparam(7); %Concentration factor
%Number of slip increments
ninc=round(slip/sinc);

%Transformation matrix from geographic to fault coordinates
a11=cos(ramp);
a12=cos(pi/2-ramp);
a21=cos(pi/2+ramp);
a22=a11;

% Transform to coordinates parallel and perpendicular to the fault, and
% with origin at initial fault tip
FX=(XP-xt)*a11+(YP-yt)*a12;
FY=(XP-xt)*a21+(YP-yt)*a22;

%Run trishear model
%Loop over slip increments
for i=1:ninc
    %Loop over number of beds
    for j=1:size(FX,1)
        %Loop over number of points in each bed
        for k=1:size(FX,2)
            %Solve trishear in a coordinate system attached to current 
            %fault tip (Eq. 11.27)
            xx=FX(j,k)-(ps*i*abs(sinc));
            yy=FY(j,k);
            %Compute velocity (Eqs. 11.25 and 11.26)
            [vx,vy]=VelTrishear(xx,yy,sinc,m,c);
            %Update FX, FY coordinates
            FX(j,k)=FX(j,k)+vx;
            FY(j,k)=FY(j,k)+vy;
        end
    end
   %Transform back to horizontal-vertical XP, YP coordinates for plotting
   XP=(FX*a11+FY*a21)+xt;
   YP=(FX*a12+FY*a22)+yt;
   %Make fault geometry
   xtf=xt+(ps*i*abs(sinc))*cos(ramp);
   ytf=yt+(ps*i*abs(sinc))*sin(ramp);
   XF=[xt xtf];
   YF=[yt ytf];
   %Make trishear boundaries
   axlo=0:10:300;
   htz=axlo*m;
   ftz=-axlo*m;
   XHTZ=(axlo*a11+htz*a21)+xtf;
   YHTZ=(axlo*a12+htz*a22)+ytf;
   XFTZ=(axlo*a11+ftz*a21)+xtf;
   YFTZ=(axlo*a12+ftz*a22)+ytf;
   %Plot increment. Fault
   plot(XF,YF,'r-','LineWidth',2);
   hold on;
   % Hanging wall trishear boundary
   plot(XHTZ,YHTZ,'b-');
   % Footwall trishear boundary
   plot(XFTZ,YFTZ,'b-');
   % Beds: Split hanging wall and footwall points
   hw = zeros(1,size(XP,2));
   fw = zeros(1,size(XP,2));
   xhb = zeros(size(XP,1),size(XP,2));
   yhb = zeros(size(XP,1),size(XP,2));
   xfb = zeros(size(XP,1),size(XP,2));
   yfb = zeros(size(XP,1),size(XP,2));
   for j=1:size(XP,1)
      hw(j)=0.0;
      fw(j)=0.0;
      for k=1:size(XP,2)
         %If hanging wall points
         if XP(j,k)<=xt+(YP(j,k)-yt)/tan(ramp),
            hw(j)=hw(j)+1;
            xhb(j,hw(j))=XP(j,k);
            yhb(j,hw(j))=YP(j,k);
         %if footwall points
         else
            fw(j)=fw(j)+1;
            xfb(j,fw(j))=XP(j,k);
            yfb(j,fw(j))=YP(j,k);
         end
      end
      plot(xhb(j,1:1:hw(j)),yhb(j,1:1:hw(j)),'k-');
      plot(xfb(j,1:1:fw(j)),yfb(j,1:1:fw(j)),'k-');
   end
   %Plot settings
   text(0.8*extent,1.75*max(yp),strcat('Slip = ',num2str(i*sinc)));
   axis equal;
   axis([0 extent 0 2.0*max(yp)]);
   hold off;
   %Get frame for movie
   frames(i) = getframe;
end

end