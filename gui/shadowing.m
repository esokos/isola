%*****************************************************************************************
%*                                                                                       *
%*   shadowing.m                                                                         *
%*                                                                                       *
%*   function plots shadow area defined by positive polarities                           *
%*                                                                                       *
%*****************************************************************************************
function out=shadowing(m)

%----------------------------------------------------------------------------------------
% lower hemisphere equal-area projection
%----------------------------------------------------------------------------------------

x_min = -1;
x_max = 1;
dx = .025;

y_min = -1;
y_max = 1;
dy = .025;

for x=x_min:dx:x_max
    for y=y_min:dy:y_max
        
        r = sqrt(x^2+y^2);
        if (r>1.e-5)
            sin_fi = x/r;
            cos_fi = y/r;
        else
            sin_fi = 0;
            cos_fi = 0;
        end
        
        if (r<1)
            theta = asin(sqrt((x^2+y^2)/2))*360/pi;
           
            n(2)  = sin(theta*pi/180)*sin_fi;   % n(2) is directed to the East
            n(1)  = sin(theta*pi/180)*cos_fi;   % n(1) is directed to the North
            n(3) = sqrt(1-n(1)^2-n(2)^2);

            u_radiation_z = 0;
            for i = 1:3
                for j = 1:3
                    u_radiation_z =  u_radiation_z + n(3)*n(i)*n(j)*m(i,j);
                end
            end
            
            sign_u_radiation_z = sign(u_radiation_z); 
            
            if (sign_u_radiation_z>0) 
                plot(x,y,'k.', 'MarkerSize',5.,'Color',[.6 .6 .6]);
            end
        end
    end
end
