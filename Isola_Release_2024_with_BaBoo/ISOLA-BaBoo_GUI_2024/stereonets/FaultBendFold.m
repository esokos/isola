function frames = FaultBendFold(yp,psect,pramp,pslip)
%FaultBendFold plots the evolution of a simple step, Mode I fault bend fold
%
%   USE: frames = FaultBendFold(yp,psect,pramp,pslip)
%
%   yp = Datums or vertical coordinates of undeformed, horizontal beds
%   psect = A 1 x 2 vector containing the extent of the section, and the
%           number of points in each bed 
%   pramp = A 1 x 3 vector containing the x coordinate of the lower bend in
%           the decollement, the ramp angle, and the height of the ramp
%   pslip = A 1 x 2 vector containing the total and incremental slip
%   frames = An array structure containing the frames of the fold evolution
%            You can play the movie again just by typing movie(frames)
%   
%   NOTE: Input ramp angle should be in radians
%
%   FaultBendFold uses function SuppeEquation
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Extent of section and number of points in each bed
extent = psect(1); npoint = psect(2);
%Make undeformed beds geometry: This is a grid of points along the beds 
xp=0.0:extent/npoint:extent;
[XP,YP]=meshgrid(xp,yp);

%Fault geometry and slip
xramp = pramp(1); ramp = pramp(2); height = pramp(3);
slip = pslip(1); sinc = pslip(2);
%Number of slip increments
ninc=round(slip/sinc);

%Ramp angle cannot be greater than 30 degrees, and if it is 30 degrees, 
%make it a little bit smaller to avoid convergence problems
if ramp > 30*pi/180
    error('ramp angle cannot be more than 30 degrees');
elseif ramp == 30*pi/180
    ramp=29.9*pi/180;
end

%Minimize Eq. 11.8 to obtain gamma from the input ramp angle (theta)
options=optimset('display','off');
gama = fzero('SuppeEquation',1.5,options,ramp);
%Compute slip ratio R (Eq. 11.8)
R = sin(gama - ramp)/sin(gama);

%Make fault geometry
xf=[0 xramp xramp+height/tan(ramp) 1.5*extent];
yf=[0 0 height height];
%From the origin of each bed compute the number of points that are in the
%hanging wall. These points are the ones that will move
hwid = zeros(size(yp,2));
for i=1:size(yp,2)
    if yp(i) <= height
        hwid(i)=0;
        for j=1:size(xp,2)
            if xp(j) <= xramp + yp(i)/tan(ramp)
                hwid(i)= hwid(i)+1;
            end
        end
    else
        hwid(i)=size(xp,2);
    end
end

%Deform beds: Apply velocity fields of Eq. 11.9
%Loop over slip increments
for i=1:ninc
    %Loop over number of beds
    for j=1:size(XP,1)
        %Loop over number of hanging wall points in each bed
        for k=1:hwid(j)
            %If point is in domain 1
            if XP(j,k) < xramp - YP(j,k)*tan(ramp/2)
                XP(j,k) = XP(j,k) + sinc;
                YP(j,k) = YP(j,k);
            else
                %If point is in domain 2
                if YP(j,k) < height
                    XP(j,k) = XP(j,k) + sinc*cos(ramp);
                    YP(j,k) = YP(j,k) + sinc*sin(ramp);
                else
                    %If stage 1 of fault bend fold (Fig. 11.3a)
                    if i*sinc*sin(ramp) < height
                        %If point is in domain 2
                        if XP(j,k) < xramp + height/tan(ramp) +...
                                (YP(j,k)-height)*tan(pi/2-gama)
            		        XP(j,k) = XP(j,k) + sinc*cos(ramp);
                            YP(j,k) = YP(j,k) + sinc*sin(ramp);	
                        %If point is in domain 3
                        else
                            XP(j,k)= XP(j,k) + sinc*R;
            	            YP(j,k)= YP(j,k);
                        end
                    %If stage 2 of fault bend fold (Fig. 11.3b)    
                    else
                        %If point is in domain 2
                        if XP(j,k) < xramp + height/tan(ramp)-...
                                (YP(j,k)-height)*tan(ramp/2)
            	            XP(j,k)= XP(j,k) + sinc*cos(ramp);
            		        YP(j,k)= YP(j,k) + sinc*sin(ramp);
         		        %If point is in domain 3
                        else
            		        XP(j,k) = XP(j,k) + sinc*R;
                            YP(j,k) = YP(j,k);
                        end
                    end
                end
            end
        end
    end
    %Plot increment
    %Fault
    plot(xf,yf,'r-','LineWidth',2);
    hold on;
    %Beds
    for j=1:size(yp,2)
        %If below ramp
        if yp(j) <= height
            plot(XP(j,1:1:hwid(j)),YP(j,1:1:hwid(j)),'k-');
            plot(XP(j,hwid(j)+1:1:size(xp,2)),YP(j,hwid(j)+...
                1:1:size(xp,2)),'k-');
        %If above ramp
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