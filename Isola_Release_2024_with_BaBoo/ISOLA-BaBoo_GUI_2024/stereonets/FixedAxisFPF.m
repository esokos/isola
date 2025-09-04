function frames = FixedAxisFPF(yp,psect,pramp,pslip)
%FixedAxisFPF plots the evolution of a simple step, fixed axis
%fault propagation fold
%
%   USE: frames = FixedAxisFPF(yp,psect,pramp,pslip)
%
%   yp = Datums or vertical coordinates of undeformed, horizontal beds
%   psect = A 1 x 2 vector containing the extent of the section, and the 
%           number of points in each bed
%   pramp = A 1 x 2 vector containing the x coordinate of the lower bend in
%           the decollement, and the ramp angle
%   pslip = A 1 x 2 vector containing the total and incremental slip
%   frames = An array structure containing the frames of the fold evolution
%            You can play the movie again just by typing movie(frames)
%   
%   NOTE: Input ramp angle should be in radians
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

% Base of layers
base = yp(1);

%Extent of section and number of points in each bed
extent = psect(1); npoint = psect(2);
%Make undeformed beds geometry: This is a grid of points along the beds 
xp=0.0:extent/npoint:extent;
[XP,YP]=meshgrid(xp,yp);

%Fault geometry and slip
xramp = pramp(1); ramp = pramp(2); 
slip = pslip(1); sinc = pslip(2);
%Number of slip increments
ninc=round(slip/sinc);

%Solve model parameters
%First equation of Eq. 11.16
gam1=(pi-ramp)/2.;
%Second equation of Eq. 11.16 
gamestar = acot((3.-2.*cos(ramp))/(2.*sin(ramp)));
%Third equation of Eq. 11.16
gamistar=gam1-gamestar;
%Fourth equation of Eq. 11.16
game=acot(cot(gamestar)-2.*cot(gam1));
%Fifth equation of Eq. 11.16
gami = asin((sin(gamistar)*sin(game))/sin(gamestar));
%Ratio of backlimb length to total slip (P/S)(Eq. 11.17)
a1=cot(gamestar)-cot(gam1);
a2=1./sin(ramp)-(sin(gami)/sin(game))/sin(game+gami-ramp);
a3=sin(gam1+ramp)/sin(gam1);
lbrat=a1/a2 + a3;
%Change in slip between domains 2 and 3 (Eq. 11.19)
R=sin(gam1+ramp)/sin(gam1+game);

%From the origin of each bed compute the number of points that are in the
%hanging wall. These points are the ones that will move. Notice that this
%has to bee done for each slip increment, since the fault propagates
hwid = zeros(ninc,size(yp,2));
for i=1:ninc
    uplift = lbrat*i*sinc*sin(ramp);
    for j=1:size(yp,2)
        if yp(j)-base<=uplift
            hwid(i,j)=0;
            for k=1:size(xp,2)
                if xp(k) <= xramp + (yp(j)-base)/tan(ramp)
                    hwid(i,j)=hwid(i,j)+1;
                end
            end
        else
            hwid(i,j)=size(xp,2);
        end
    end
end

%Deform beds. Apply velocity fields of Eq. 11.18
%Loop over slip increments
for i=1:ninc
    % Compute uplift
    lb = lbrat*i*sinc;
    uplift = lb*sin(ramp);
    lbh = lb*cos(ramp);
    % Compute point at fault tip
    xt = xramp + lbh;
    yt = base + uplift;
    %Loop over number of beds
    for j=1:size(XP,1)
        %Loop over number of hanging wall points in each bed
        for k=1:hwid(i,j)
            %If point is in domain 1
            if XP(j,k) < xramp - (YP(j,k)-base)/tan(gam1)
                XP(j,k) = XP(j,k) + sinc;
            else
                %If point is in domain 2
                if XP(j,k) < xt - (YP(j,k)-yt)/tan(gam1)
                     XP(j,k) = XP(j,k) + sinc*cos(ramp);
                     YP(j,k) = YP(j,k) + sinc*sin(ramp);
                else
                    %If point is in domain 3
                    if XP(j,k) < xt + (YP(j,k)-yt)/tan(game)
                        XP(j,k) = XP(j,k) + sinc*R*cos(game);
                        YP(j,k) = YP(j,k) + sinc*R*sin(game);
                    end
                end
            end
        end
    end
    %Plot increment
    %Fault
    xf=[0 xramp xramp+lbh];
    yf=[base base uplift+base];
    plot(xf,yf,'r-','LineWidth',2);
    hold on;
    %Beds
    for j=1:size(yp,2)
        %If beds cut by the fault
        if yp(j)-base <= uplift
            plot(XP(j,1:1:hwid(i,j)),YP(j,1:1:hwid(i,j)),'k-');
            plot(XP(j,hwid(i,j)+1:1:size(xp,2)),YP(j,hwid(i,j)+...
                1:1:size(xp,2)),'k-');
        %If beds not cut by the fault
        else
            plot(XP(j,:),YP(j,:),'k-');
        end
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