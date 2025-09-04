function [cie,pfs] = Fibers(imageName,kk)
%Fibers determines the incremental and finite strain history of a fiber in 
%a pressure shadow
%
%   USE: [cie,pfs] = Fibers(imageName,kk)
%
%   image = A character corresponding to the image filename, including 
%           extension (eg. = 'fileName.jpg')
%   kk = An integer that indicates whether the fiber is on a cleavage
%        parallel (kk = 0), or cleavage perpendicular (kk = 1) section
%   cie = cummulative incremental elongation: column 1 = Incremental theta,
%         column 2 = cummulative incremental maximum elongation
%   pfs = progressive finite strain history: column 1 = Finite theta, 
%         column 2 = maximum stretch magnitude
%
%   NOTE: Output theta angles are in radians
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Read and display image
IMG=imread(imageName);   
imagesc(IMG);

%Prompt the user to define a reference plane. If the current reference 
%plane is not satisfactory, the user can re-select the input points
a='n';
while a=='n'
    clf; %Clear figure
    imagesc(IMG); %Display image
    hold on;
    disp('Select two points along the reference plane, from left to right.');
    [refpx, refpy] = ginput(2);
    refpx = round (refpx); %Rounds imput x points to nearest integer 
    refpy = round (refpy); %Rounds input y points to nearest integer
    plot(refpx,refpy,'--y','LineWidth',1.5);
    a=input('Would you like to keep the current reference plane? (y/n)  ','s');
end
 
%Prompt the user to select the origin and fiber points from the image 
%display. The origin is defined at the center of the porphyroclast.  
%The fiber points are selected sequentially along a single fiber path.  
%If the current fiber path is not satisfactory, the user can re-select the
%input points
a='n';
while a=='n'
    clf; %Clear figure
    imagesc(IMG); %Display image
    hold on;
    plot(refpx,refpy, '--y', 'LineWidth',1.5)
    disp ('Select the origin point, center of porphyroclast.');
    [xo, yo] = ginput(1); %Select center of grain as the origin
    xo=round(xo); yo=round(yo); %Rounds positions to nearest interger value
    plot (xo,yo,'ok','MarkerFaceColor','k','MarkerSize',8) %Plots origin
    %Digitize points along fiber
    disp ('Digitize points along the fiber');
    disp ('Left mouse button picks points');
    disp ('Right mouse button picks last point');
    x = []; y = []; n = 0; but = 1;
    while but == 1
        n = n + 1;
        [xi,yi,but] = ginput(1);
        xi=round(xi); %Rounds point coords to nearest integer 
        yi=round(yi); 
        plot (xi,yi,'-or','LineWidth',1.5); %Plots point
        x(n) = xi; y(n) = yi; %Add point to fiber path
    end
    a=input('Would you like to keep the current fiber path? (y/n)  ', 's');
end
hold off;

%Start calculation
 
%Switch y values from screen coordinates with (0,0) at the upper left
%corner to cartesian coordinates, with (0,0) at the lower left corner
nrow=size(IMG,1); %Number of rows in image
yo=nrow-yo;
y=nrow-y;
refpy = nrow-refpy;
 
%Set origin of coordinate system at grain origin
x=x-xo;
y=y-yo;
 
%Rotate all points into a reference frame parallel to X1
phi=atan((refpy(2)-refpy(1))/(refpx(2)-refpx(1)));
Rot=[cos(phi) sin(phi);-sin(phi) cos(phi)];
vec=[x;y];
newvec=Rot*vec;
x=newvec(1,:);
y=newvec(2,:);

%Initialize some variables
cie = zeros(n-1,2);
rotmat = zeros(2,2,n-1);
finmat = zeros(2,2,n-1);
elong = zeros(1,n-1);
C = zeros(2,2,n-1);
pfs = zeros(n-1,2);

%Incremental, inverse modeling of vein (Backwards)
for i=1:n-1
    %If cleavage parallel section (Eq. 10.21)
    if kk == 0
        cie(n-i,1)=atan((y(2)-y(1))/(x(2)-x(1)));
    %If cleavage perpendicular section (Eq. 10.30)
    elseif kk == 1
        cie(n-i,1)=(atan((2*(x(2)*y(2)-x(1)*y(1)))/...
            (x(2)^2-y(2)^2-x(1)^2+y(1)^2)))/2;
    end
    Beta=[cos(cie(n-i,1)) sin(cie(n-i,1));-sin(cie(n-i,1))...
        cos(cie(n-i,1))];
    %If cleavage parallel face
    if kk == 0
        h=[x(1);y(1)];
        H=[x(2);y(2)];
        v0=H-h;
        v1=h/norm(h);
        v2=v0/norm(v0);
        Alpha=acos(dot(v1,v2));
        initlength=norm(h)*cos(Alpha);
        st1inc=(norm(v0)+initlength)/initlength;
        posmat=[st1inc 0;0 1];
    %If cleavage perpendicular face
    elseif kk == 1
        Bigx1=Beta*[x(1);y(1)];
        Bigx2=Beta*[x(2);y(2)];
        st1inc=(Bigx2(1)/Bigx1(1));
        st3inc=(Bigx2(2)/Bigx1(2));
        posmat=[st1inc 0;0 st3inc];
    end
    rotmat(:,:,n-i)=Beta'*posmat*Beta;
    elong(n-i)=st1inc-1;
    for j=1:n-i
        newposition=rotmat(:,:,n-i)\[x(j+1);y(j+1)];
        x(j)=newposition(1);
        y(j)=newposition(2);
    end
end

%Plot cummulative incremental maximum elongation
figure;
cie(:,2)=cumsum(elong); %Cummulative, incremental, maximum elongation
plot(cie(:,1)*180/pi,cie(:,2),'o');
xlabel('Theta incremental deg');
ylabel('Cumulative incremental elongation')
axis([-90 90 0 max(cie(:,2))+0.5]);

%Compute progressive finite strain (Forward)
finmat(:,:,1)=rotmat(:,:,1);
for i=2:n-1
    finmat(:,:,i)=rotmat(:,:,i)*finmat(:,:,i-1);
end
%Determine Cauchy deformation tensor
for i=1:n-1
    C(:,:,i)=finmat(:,:,i)'*finmat(:,:,i);
    %Stretch magnitude and orientation: Maximum eigenvalue and their
    %corresponding eigenvectors of Cauchy's tensor. Use MATLAB function eig
    [V,D]=eig(C(:,:,i));
    pfs(i,2)=sqrt(D(2,2));
    pfs(i,1)=atan(V(2,2)/V(1,2));
end

%Plot Progresive finite strain
figure
plot(pfs(:,1)*180/pi, pfs(:,2), 'o');
xlabel('Theta finite deg');
ylabel('Progressive Finite Strain');
axis([-90 90 1 max(pfs(:,2))+0.5]);

end
