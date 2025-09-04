function frames = SimilarFold(yp,psect,alpha,pslip)
%SimilarFold plots the evolution of a similar fold
%
%   USE: frames = SimilarFold(yp,psect,alpha,pslip)
%
%   yp = Datums or vertical coordinates of undeformed, horizontal beds
%   psect = A 1 x 2 vector containing the extent of the section, and the 
%           number of points in each bed
%   alpha = Shear angle. Positive for shear antithetic to the fault and
%           negative for shear synthetic to the fault
%   pslip = A 1 x 2 vector containing the total and incremental slip
%   frames = An array structure containing the frames of the fold evolution
%            You can play the movie again just by typing movie(frames)
%
%   NOTE: Use positive pslip for a normal fault
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Extent of section and number of points in each bed
extent = psect(1); npoint = psect(2);

%Make undeformed beds geometry: This is a grid of points along the beds 
xp=0.0:extent/npoint:extent;
[XP,YP]=meshgrid(xp,yp);

%Slip and number of slip increments
slip = pslip(1); sinc = pslip(2);
ninc=round(slip/sinc);

%Prompt the user to select the geometry of the fault. If the current fault
%trajectory is not satisfactory, the user can re-select the input points
a='n';
while a=='n'
    %Plot beds
    for i=1:size(yp,2)
        plot(XP(i,:),YP(i,:),'k-');
        hold on;
    end
    axis equal;
    axis([0 extent 0 2.0*max(yp)]);
    %Digitize fault
    disp ('Digitize a listric fault shallowing to the right');
    disp ('Left mouse button picks points');
    disp ('Right mouse button picks last point');
    fault = []; n = 0; but = 1;
    while but == 1
        n = n + 1;
        [xi,yi,but] = ginput(1);
        plot (xi,yi,'-or','LineWidth',1.5); %Plots point
        fault(n,1) = xi; fault(n,2) = yi; %Add point to fault
    end
    hold off;
    a=input('Would you like to keep the current fault? (y/n)  ', 's');
end

%Sort fault points in x
fault = sortrows(fault,1);
xf = fault(:,1)';
yf = fault(:,2)';

%Find tangent of dip of fault segments: df/dx
dfx = zeros(1,n);
for i=1:n-1
    dfx(i) = (yf(i+1)-yf(i))/(xf(i+1)-xf(i));
end
dfx(n) = dfx(n-1);

%From the origin of each bed compute the number of points that are in the
%footwall. These points won't move
fwid = zeros(size(yp,2));
%Find y of fault below/above bed points
yfi = interp1(xf,yf,xp,'linear','extrap'); 
for i=1:size(yp,2)
    fwid(i)=0;
    for j=1:size(xp,2)
        if yp(i) < yfi(j)
            fwid(i) = fwid(i) + 1;
        end
    end
end

%Coordinate transformation matrix between horizontal-vertical coordinate 
%system and coordinate system parallel and perpendicular to shear direction
a11=cos(alpha);
a12=-sin(alpha);
a21=sin(alpha);
a22=a11;

%Transform fault and beds to coordinate system parallel and perpendicular
%to shear direction
xfS = xf*a11+yf*a12; %Fault
XPS = XP*a11+YP*a12; %Beds
YPS = XP*a21+YP*a22;

%Compute deformation
%Loop over slip increments
for i=1:ninc
    %Loop over number of beds
    for j=1:size(XPS,1)
        %Loop over number of bed points in hanging wall
        for k=fwid(j)+1:size(XPS,2)
            %Find local tangent of fault dip: df/dx
             if XPS(j,k) <= xfS(1)
                 ldfx = dfx(1);
             elseif XPS(j,k) >= xfS(n)
                 ldfx = dfx(n);
             else
                 a = 'n'; L = 1;
                while a=='n'
                    if XPS(j,k) >= xfS(L) && XPS(j,k) < xfS(L+1)
                        ldfx = dfx(L);
                        a = 's';
                    else
                        L = L + 1;
                    end
                end
             end
             %Compute velocities perpendicular and along shear direction
             %Equations 11.13 and 11.15
             vxS = sinc*a11;
             vyS = (sinc*(a11*a21+ldfx*a11^2))/(a11-ldfx*a21);
             %Move point
             XPS(j,k) = XPS(j,k) + vxS;
             YPS(j,k) = YPS(j,k) + vyS;
        end
    end
    
    %Transform beds back to geographic coordinate system
    XP=XPS*a11+YPS*a21;
    YP=XPS*a12+YPS*a22;
    
    %Plot increment
    %Fault
    plot(xf,yf,'r-','LineWidth',2);
    hold on;
    %Beds
    for j=1:size(yp,2)
        %Footwall
        plot(XP(j,1:1:fwid(j)),YP(j,1:1:fwid(j)),'k-');
        %Hanging wall
        plot(XP(j,fwid(j)+1:1:size(XP,2)),...
                YP(j,fwid(j)+1:1:size(XP,2)),'k-');
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