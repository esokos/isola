function frames = ParallelFPF(yp,psect,pramp,pslip)
%ParallelFPF plots the evolution of a simple step, parallel
%fault propagation fold
%
%   USE: frames = ParallelFPF(yp,psect,pramp,pslip)
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
%   ParallelFPF uses function SuppeEquationTwo
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
%Solve first equation in Eq. 11.20 by minimizing SuppeEquationTwo
options=optimset('display','off');
gamstar = fzero('SuppeEquationTwo',0.5,options,ramp);
%Solve second equation in Eq. 11.20
gam1 = pi/2. - ramp/2.;
%Solve third equation in Eq. 11.20
gam = pi/2.+gamstar-gam1;
%Solve fourth equation in Eq. 11.20
bet2 = pi - 2.*gamstar;
%Other angle for computation
kap = pi - bet2 + ramp;
%Eq. 11.21
lbrat = 1./(1.-sin(ramp)/sin(2.*gam-ramp));
%Eq. 11.23
R1=sin(gam1+ramp)/sin(gam1+gam);
R2=sin(bet2)/sin(bet2-ramp+gam);

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

%Deform beds: Apply velocity fields of Eq. 11.22
%Loop over slip increments
for i=1:ninc
    % Compute uplift
    lb = lbrat*i*sinc;
    uplift = lb*sin(ramp);
    lbh = lb*cos(ramp);
    % Compute distance ef in Figure 11.6
    ef=uplift/sin(2.*gamstar);
    % Compute fault tip
    xt=xramp+lbh;
    yt=base+uplift;
    % Compute location e in Figure 11.6
    xe=xt+ef*cos(kap);
    ye=yt+ef*sin(kap);
    %Loop over number of beds
    for j=1:size(XP,1)
        %Loop over number of hanging wall points in each bed
        for k=1:hwid(i,j)
            %If point is in domain 1
            if XP(j,k) < xramp - (YP(j,k)-base)/tan(gam1)
                XP(j,k) = XP(j,k) + sinc;
            else
                % if y lower than y at e
                if YP(j,k) < ye
                    %If point is in domain 2
                    if XP(j,k) < xt + (YP(j,k)-yt)/tan(kap)
                        XP(j,k) = XP(j,k) + sinc*cos(ramp);
                        YP(j,k) = YP(j,k) + sinc*sin(ramp);
                    else
                        %If point is in domain 4
                        if XP(j,k) < xt + (YP(j,k)-yt)/tan(gam)
                            XP(j,k) = XP(j,k) + sinc*R2*cos(gam);
                            YP(j,k) = YP(j,k) + sinc*R2*sin(gam);
                        end
                    end
                % if y higher than y at e    
                else
                    %If point is in domain 2
                    if XP(j,k) < xe - (YP(j,k)-ye)/tan(gam1)
                        XP(j,k) = XP(j,k) + sinc*cos(ramp);
                        YP(j,k) = YP(j,k) + sinc*sin(ramp);
                    else
                        %If point is in domain 3
                        if XP(j,k) < xe + (YP(j,k)-ye)/tan(gam)
                            XP(j,k) = XP(j,k) + sinc*R1*cos(gam);
                            YP(j,k) = YP(j,k) + sinc*R1*sin(gam);
                        else
                            %If point is in domain 4
                            if XP(j,k) < xt + (YP(j,k)-yt)/tan(gam)
                                XP(j,k) = XP(j,k) + sinc*R2*cos(gam);
                                YP(j,k) = YP(j,k) + sinc*R2*sin(gam);
                            end
                            
                        end
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
            plot(XP(j,hwid(i,j)+1:1:size(xp,2)),...
                YP(j,hwid(i,j)+1:1:size(xp,2)),'k-');
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