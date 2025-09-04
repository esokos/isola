function [vx, vy] = VelTrishear(xx,yy,sinc,m,c)
%VelTrishear: Symmetric, linear in vx trishear velocity field 
%Equation 6 of Zehnder and Allmendinger 2000
%
%MATLAB script written by Nestor Cardozo for the book Structural 
%Geology Algorithms by Allmendinger, Cardozo, & Fisher, 2011. If you use
%this script, please cite this as "Cardozo in Allmendinger et al. (2011)"

%If behind the fault tip
if xx <0.
    %If hanging wall
    if yy >=0.
        vx = sinc;
        vy = 0.;
    %If footwall
    elseif yy<0.
        vx=0.;
        vy=0.;
    end
%If ahead the fault tip    
elseif xx>=0.
    %If hanging wall
    if yy>=xx*m 
        vx=sinc;
        vy=0.;
    %If footwall
    elseif yy<=-xx*m
        vx=0.;
        vy=0.;
    %If inside the trishear zone
    else
        %Some variables to speed up the computation
        a=1+c; b=1/c; d=a/c; ayy=abs(yy); syy = yy/ayy;
        %Eq. 11.25
        vx=(sinc/2.)*(syy*realpow(ayy/(xx*m),b)+1);
        %Eq. 11.26
        vy=(sinc/2.)*(m/a)*(realpow(ayy/(xx*m),d)-1);
    end
end

end