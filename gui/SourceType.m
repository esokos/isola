function Out = SourceType(In,method,IOinv,IOnrm)
    %%
    % SourceType(In,method,IOinv,IOnrm)
    % Conversion between ...
    %   L123=[L1,L2,L3] moment-tensor eigenvalues (L1>=L2>=L3)
    %   AXY=[A,X,Y] size (A) and Source-type coordinates (X,Y)
    % 
    % Parameters:
    %   Out: output data
    %   In: input data
    %   method: style of source-type diagram
    %   IOinv: 0 (forward) / 1 (inverse)
    %   IOnrm: 0 (no normalization) / 1 (normalization)
    %
    % Usage1: AXY=SourceType([L1,L2,L3],method,0,IOnrm)
    % Usage2: L123=SourceType([A,X,Y],method,1,IOnrm)
    %
    
    %% Find Method %%
    methods={
        'a','Cubic'
        'b','Hexagonal-Bipyramid'
        'c','Modified-Hexagonal-Bipyramid'
        'd','Conjugate-Hexagonal-Bipyramid'
        'e','Spherical-Equirectangular'
        'f','Spherical-Orthogonal'
        'g','Modified-Spherical-Orthogonal'
        'h','Spherical-Azimuthal'
        'i','Spherical-Cylindrical'
        'j','Modified-Spherical-Cylindrical'
        'k','Spherical-Cylindrical-Orthogonal'
        'l','Percentile'
        'm','Modified-Percentile'
    };
    [a,imethod]=max(max(strcmp(method,methods),[],2));
    if a==0; Out=[]; return; end
    
    %% Extract Input Data and Prepare Output Data %%
    if(IOinv==0)
        L1=In(:,1);
        L2=In(:,2);
        L3=In(:,3);
        A=nan(size(L1));
        X=nan(size(L1));
        Y=nan(size(L1));
    else
        A=In(:,1);
        X=In(:,2);
        Y=In(:,3);
        L1=nan(size(A));
        L2=nan(size(A));
        L3=nan(size(A));
    end
    
    %% Conversions %%
    switch imethod
        %% (a) Cubic (u-v) %%
        case 1
            if (IOinv==0)
                A=max(L1,-L3);
                X=-2*(L1-2*L2+L3)/3./max(L1,-L3);
                Y=(L1+L2+L3)/3./max(L1,-L3);
                if (IOnrm==1); X=-X; end
            elseif (IOinv==1)
                if(IOnrm==1); X=-X; end
                L1=A/2.*(min(4*Y-X,0)+2);
                L2=A/2.*(2*Y+X);
                L3=A/2.*(max(4*Y-X,0)-2);
            end
        %% (b) Hexagonal Bi-Pyramid (tau-k) %%
        case 2
            if(IOinv==0)
                A=(3*(L1-L3)+abs(L1-2*L2+L3)+2*abs(L1+L2+L3))/6;
                X=-4*(L1-2*L2+L3)./(3*(L1-L3)+abs(L1-2*L2+L3)+2*abs(L1+L2+L3));
                Y=2*(L1+L2+L3)./(3*(L1-L3)+abs(L1-2*L2+L3)+2*abs(L1+L2+L3));
                if(IOnrm==1); X=-X; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-X; end
                L1=A/2.*(min(4*Y,0)-max(X,0)+2);
                L2=A/2.*(2*Y+X);
                L3=A/2.*(max(4*Y,0)-min(X,0)-2);
            end
        %% (c) Modified Hexagonal Bi-Pyramid (T-k) %%
        case 3
            if(IOinv==0)
                A=(3*(L1-L3)+abs(L1-2*L2+L3)+2*abs(L1+L2+L3))/6;
                X=-4*(L1-2*L2+L3)./(3*(L1-L3)+abs(L1-2*L2+L3));
                Y=2*(L1+L2+L3)./(3*(L1-L3)+abs(L1-2*L2+L3)+2*abs(L1+L2+L3));
                X(L1==L3)=0; % exception for +ISO and -ISO
                if(IOnrm==1); X=-X; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-X; end
                L1=A/2.*(min(4*Y,0)-(1-abs(Y)).*max(X,0)+2);
                L2=A/2.*(2*Y+(1-abs(Y)).*X);
                L3=A/2.*(max(4*Y,0)-(1-abs(Y)).*min(X,0)-2);
            end
        %% (d) Conjugate Hexagonal Bi-Pyramid (eta-xi) %%
        case 4
            if(IOinv==0)
                A=(L1-L3+abs(L1+L2+L3))/2;
                X=-(L1-2*L2+L3)./(L1-L3+abs(L1+L2+L3));
                Y=(L1+L2+L3)./(L1-L3+abs(L1+L2+L3));
                if(IOnrm==1); X=-X; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-X; end
                L1=A/3.*(2*Y-X+3*(1-abs(Y)));
                L2=A/3.*(2*Y+2*X);
                L3=A/3.*(2*Y-X-3*(1-abs(Y)));
            end
        %% (e) Spherical Equirectangular (gamma-delta) %%
        case 5
            if(IOinv==0)
                A=sqrt((L1.^2+L2.^2+L3.^2)/2);
                X=-atan2((L1-2*L2+L3),sqrt(3)*(L1-L3));
                Y=asin((L1+L2+L3)./sqrt(3*(L1.^2+L2.^2+L3.^2)));
                if(IOnrm==1); X=-6*X/pi; Y=2*Y/pi; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-pi*X/6; Y=pi*Y/2; end
                L1=sqrt(2/3)*A.*(sin(Y)-sqrt(2)*sin(X-pi/3).*cos(Y));
                L2=sqrt(2/3)*A.*(sin(Y)+sqrt(2)*sin(X).*cos(Y));
                L3=sqrt(2/3)*A.*(sin(Y)-sqrt(2)*sin(X+pi/3).*cos(Y));
            end
        %% (f) Spherical Orthogonal (R-zeta) %%
        case 6
            if(IOinv==0)
                A=sqrt((L1.^2+L2.^2+L3.^2)/2);
                X=-(L1-2*L2+L3)./sqrt(6*(L1.^2+L2.^2+L3.^2));
                Y=(L1+L2+L3)./sqrt(3*(L1.^2+L2.^2+L3.^2));
                if(IOnrm==1); X=-2*X; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-X/2; end
                L1=A/sqrt(3).*(sqrt(2)*Y-X+sqrt(3*(1-X.^2-Y.^2)));
                L2=A/sqrt(3).*(sqrt(2)*Y+2*X);
                L3=A/sqrt(3).*(sqrt(2)*Y-X-sqrt(3*(1-X.^2-Y.^2)));
            end
        %% (g) Modified Spherical Orthogonal (r-s) %%
        case 7
            if(IOinv==0)
                A=sqrt((L1.^2+L2.^2+L3.^2)/2);
                X=-(L1-2*L2+L3).*abs(L1-2*L2+L3)./(6*(L1.^2+L2.^2+L3.^2));
                Y=(L1+L2+L3).*abs(L1+L2+L3)./(3*(L1.^2+L2.^2+L3.^2));
                if(IOnrm==1); X=-4*X; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-X/4; end
                L1=A/sqrt(3).*(sign(Y).*sqrt(2*abs(Y)) ...
                    -sign(X).*sqrt(abs(X))+sqrt(3*(1-abs(X)-abs(Y))));
                L2=A/sqrt(3).*(sign(Y).*sqrt(2*abs(Y)) ...
                    +2*sign(X).*sqrt(abs(X)));
                L3=A/sqrt(3).*(sign(Y).*sqrt(2*abs(Y))  ...
                    -sign(X).*sqrt(abs(X))-sqrt(3*(1-abs(X)-abs(Y))));
            end
        %% (h) Spherical Azimuthal (p-q) %%
        case 8
            if(IOinv==0)
                A=sqrt((L1.^2+L2.^2+L3.^2)/2);
                X=1/sqrt(3)*-(L1-2*L2+L3) ...
                    ./sqrt(L1.^2+L2.^2+L3.^2 ...
                    +(L1-L3).*sqrt((L1.^2+L2.^2+L3.^2)/2));
                Y=1/sqrt(3)*sqrt(2)*(L1+L2+L3) ...
                    ./sqrt(L1.^2+L2.^2+L3.^2 ...
                    +(L1-L3).*sqrt((L1.^2+L2.^2+L3.^2)/2));
                if(IOnrm==1); X=-2*X/(sqrt(6)-sqrt(2)); Y=Y/sqrt(2); end
            elseif(IOinv==1)
                if(IOnrm==1); X=-(sqrt(6)-sqrt(2))*X/2; Y=sqrt(2)*Y; end
                L1=A/(2*sqrt(3)).*(sqrt(4-X.^2-Y.^2).*(sqrt(2)*Y-X) ...
                    +sqrt(3)*(2-X.^2-Y.^2));
                L2=A/(2*sqrt(3)).*(sqrt(4-X.^2-Y.^2).*(sqrt(2)*Y+2*X));
                L3=A/(2*sqrt(3)).*(sqrt(4-X.^2-Y.^2).*(sqrt(2)*Y-X) ...
                    -sqrt(3)*(2-X.^2-Y.^2));
            end
        %% (i) Spherical Cylindrical (gamma-zeta) %%
        case 9
            if(IOinv==0)
                A=sqrt((L1.^2+L2.^2+L3.^2)/2);
                X=-atan2((L1-2*L2+L3),sqrt(3)*(L1-L3));
                Y=(L1+L2+L3)./sqrt(3*(L1.^2+L2.^2+L3.^2));
                if(IOnrm==1); X=-6*X/pi; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-pi*X/6; end
                L1=sqrt(2/3)*A.*(Y-sqrt(2)*sin(X-pi/3).*sqrt(1-Y.^2));
                L2=sqrt(2/3)*A.*(Y+sqrt(2)*sin(X).*sqrt(1-Y.^2));
                L3=sqrt(2/3)*A.*(Y-sqrt(2)*sin(X+pi/3).*sqrt(1-Y.^2));
            end
        %% (j) Modified Spherical Cylindrical (a-b) %%
        case 10
            if(IOinv==0)
                A=sqrt((L1.^2+L2.^2+L3.^2)/2);
                X=-6/pi*atan2((L1-2*L2+L3),sqrt(3)*(L1-L3)) ...
                    .*sqrt(1-abs(L1+L2+L3)./sqrt(3*(L1.^2+L2.^2+L3.^2)));
                Y=(L1+L2+L3)./sqrt(3*(L1.^2+L2.^2+L3.^2)) ...
                    ./(1+sqrt(1-abs(L1+L2+L3) ...
                    ./sqrt(3*(L1.^2+L2.^2+L3.^2))));
                if(IOnrm==1); X=-X; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-X; end
                L1=sqrt(2/3)*A.*(Y.*(2-abs(Y)) ...
                    -sqrt(2)*sin(pi/6*(X./(1-abs(Y))-2)) ...
                    .*sqrt(1-Y.^2.*(2-abs(Y)).^2));
                L2=sqrt(2/3)*A.*(Y.*(2-abs(Y)) ...
                    +sqrt(2)*sin(pi/6*X./(1-abs(Y))) ...
                    .*sqrt(1-Y.^2.*(2-abs(Y)).^2));
                L3=sqrt(2/3)*A.*(Y.*(2-abs(Y)) ...
                    -sqrt(2)*sin(pi/6*(X./(1-abs(Y))+2)) ...
                    .*sqrt(1-Y.^2.*(2-abs(Y)).^2));
                L123_=sqrt(2/3)*A(abs(Y)==1).*Y(abs(Y)==1);
                L1(abs(Y)==1)=L123_; % exception for +ISO and -ISO
                L2(abs(Y)==1)=L123_; % exception for +ISO and -ISO
                L3(abs(Y)==1)=L123_; % exception for +ISO and -ISO
            end
        %% (k) Spherical Cylindrical Orthogonal (chi-zeta) %%
        case 11
            if(IOinv==0)
                A=sqrt((L1.^2+L2.^2+L3.^2)/2);
                X=-(L1-2*L2+L3)/2 ...
                    ./sqrt(L1.^2+L2.^2+L3.^2-L1.*L2-L2.*L3-L1.*L3);
                Y=(L1+L2+L3)./sqrt(3*(L1.^2+L2.^2+L3.^2));
                X(L1==L3)=0; % exception for +ISO and -ISO
                if(IOnrm==1); X=-2*X; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-X/2; end
                L1=A/sqrt(3).*(sqrt(2)*Y+(-X+sqrt(3*(1-X.^2))).*sqrt(1-Y.^2));
                L2=A/sqrt(3).*(sqrt(2)*Y+2*X.*sqrt(1-Y.^2));
                L3=A/sqrt(3).*(sqrt(2)*Y+(-X-sqrt(3*(1-X.^2))).*sqrt(1-Y.^2));
            end
    
        %% (l) Percentile (epsilon-v) %%
        case 12
            if(IOinv==0)
                A=sqrt((L1.^2+L2.^2+L3.^2)/2);
                X=-2*(L1-2*L2+L3)./(3*(L1-L3)+abs(L1-2*L2+L3));
                Y=(L1+L2+L3)/3./max(L1,-L3);
                X(L1==L3)=0; % exception for +ISO and -ISO
                if(IOnrm==1); X=-2*X; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-X/2; end
                L1=(2-abs(X)).*(Y+1)-X ...
                    -sign(Y.*(2-abs(X))-X).*Y.*(2-abs(X));
                L2=(2-abs(X)).*Y+2*X ...
                    -sign(Y.*(2-abs(X))-X)*3.*Y.*X;
                L3=(2-abs(X)).*(Y-1)-X ...
                    +sign(Y.*(2-abs(X))-X).*Y.*(2-abs(X));
                A_=sqrt((L1.^2+L2.^2+L3.^2)/2);
                L1=L1./A_.*A;
                L2=L2./A_.*A;
                L3=L3./A_.*A;
            end
        %% (m) Modified Percentile (c-v) %%
        case 13
            if(IOinv==0)
                A=sqrt((L1.^2+L2.^2+L3.^2)/2);
                X=-4*(L1-2*L2+L3)./(3*(L1-L3)+abs(L1-2*L2+L3)) ...
                    .*(1-abs(L1+L2+L3)/3./max(L1,-L3));
                Y=(L1+L2+L3)/3./max(L1,-L3);
                X(L1==L3)=0; % exception for +ISO and -ISO
                if(IOnrm==1); X=-X; end
            elseif(IOinv==1)
                if(IOnrm==1); X=-X; end
                L1=(4*(1-abs(Y))-abs(X)).*(Y+1)-X ...
                    -sign(4*Y.*(1-abs(Y))-Y.*abs(X)-X) ...
                    .*(4*Y.*(1-abs(Y))-Y.*abs(X));
                L2=(4*(1-abs(Y))-abs(X)).*Y+2*X ...
                    -sign(4*Y.*(1-abs(Y))-Y.*abs(X)-X).*(3*Y.*X);
                L3=(4*(1-abs(Y))-abs(X)).*(Y-1)-X ...
                    -sign(4*Y.*(1-abs(Y))-Y.*abs(X)-X) ...
                    .*(-4*Y.*(1-abs(Y))+Y.*abs(X));
                A_=sqrt((L1.^2+L2.^2+L3.^2)/2);
                L1=L1./A_.*A;
                L2=L2./A_.*A;
                L3=L3./A_.*A;
                L123_=sqrt(2/3)*A(abs(Y)==1).*Y(abs(Y)==1);
                L1(abs(Y)==1)=L123_; % exception for +ISO and -ISO
                L2(abs(Y)==1)=L123_; % exception for +ISO and -ISO
                L3(abs(Y)==1)=L123_; % exception for +ISO and -ISO
            end
    end
    
    %% Output %%
    if(IOinv==0)
        Out=[A,X,Y];
    else
        Out=[L1,L2,L3];
    end
    return
end

