function rlzt = BedRealizations(xp,yp,N,sigma,corrl)
%BedRealizations generates and plots realizations of a bed using a 
%spherical variogram and the Cholesky method
%
%   USE: rlzt = BedRealizations(xp,yp,N,sigma,corrl)
%
%   xp = column vector with x locations of points along bed
%   yp = column vector with y locations of points along bed
%   N = number of realizations
%   sigma = Variance
%   corrl = Correlation length
%   rlzt = npoints x 2 x N+1 matrix with bed realizations. The first
%          realization in this matrix is the input xp, yp bed
%
%   BedRealizations uses function CorrSpher
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%Number of points along bed
nj = max(size(xp));

%Variance matrix
Sf = zeros(nj,nj);
for i=1:nj
    for j=1:nj
        if i==j
            Sf(i,j)=sigma;
        end
    end
end

%Calculate correlation matrix using spherical variogram model. Use our
%function CorrSpher
Rf=CorrSpher(xp,yp,corrl);
%Calculate covariance matrix (Cf)
Cf=Sf*Rf*Sf;
%Cholesky decomposition of covariance matrix. Here we use the MATLAB
%function chol
[L,p] = chol(Cf,'lower');
if p > 0
    error ('Cf not positive definite');
end

%Initialize realizations
rlzt = zeros(nj,2,N+1);

%Start figure
figure;
hold on;
gray = [0.75 0.75 0.75];

%Generate realizations
for i=1:N+1
    %First realization is the bed itself
    if i == 1
        rlzt(:,1,i) = xp;
        rlzt(:,2,i) = yp;
    %Other Realizations
    else
        %Compute uncertainty in horizontal and vertical
        z = randn(nj,1);
        lz = L*z;
        %Add to observed data to generate realization
        rlzt(:,1,i) = xp + lz;
        rlzt(:,2,i) = yp + lz;
    end
    % Plot realization
    plot(rlzt(:,1,i),rlzt(:,2,i),'.','MarkerEdgeColor',gray);
end

%plot bed in black
plot(rlzt(:,1,1),rlzt(:,2,1),'k.');
hold off;
axis equal;

end