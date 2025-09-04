function [d,v,nrot]=jacobinr(a,n)

   for ip=1:n
     for iq=1:n
       v(ip,iq)=0.;
     end
       v(ip,ip)=1.;
   end

   for ip=1:n
        b(ip)=a(ip,ip);
        d(ip)=b(ip);
        z(ip)=0.;
   end

      nrot=0;

for i=1:50 % 24 main loop
       sm=0.;
       for ip=1:n-1
          for iq=ip+1:n
            sm=sm+abs(a(ip,iq));
          end
       end

       if (sm==0.)
            return
       else
       end
            
       if (i<4)
          tresh=0.2*sm/n^2;
       else
          tresh=0.;
       end
       
        for ip=1:n-1  % 22
          for iq=ip+1:n  % 21
          
            g=100.*abs(a(ip,iq));
            
            if ((i > 4) && (abs(d(ip))+g == abs(d(ip))) && (abs(d(iq))+g == abs(d(iq)))) 
              a(ip,iq)=0.;
            elseif (abs(a(ip,iq)) > tresh)
              h=d(iq)-d(ip);
              if ((abs(h)+g) == abs(h))
                t=a(ip,iq)/h;
              else
                theta=0.5*h/a(ip,iq);
                t=1./(abs(theta)+sqrt(1.+theta^2));
                 if (theta < 0.)
                     t=-t;
                 end
              end
              c=1./sqrt(1+t^2);
              s=t*c;
              tau=s/(1.+c);
              h=t*a(ip,iq);
              z(ip)=z(ip)-h;
              z(iq)=z(iq)+h;
              d(ip)=d(ip)-h;
              d(iq)=d(iq)+h;
              a(ip,iq)=0.;
              
              for j=1:ip-1
                g=a(j,ip);
                h=a(j,iq);
                a(j,ip)=g-s*(h+g*tau);
                a(j,iq)=h+s*(g-h*tau);
              end

              for j=ip+1:iq-1
                g=a(ip,j);
                h=a(j,iq);
                a(ip,j)=g-s*(h+g*tau);
                a(j,iq)=h+s*(g-h*tau);
              end

              for j=iq+1:n
                g=a(ip,j);
                h=a(iq,j);
                a(ip,j)=g-s*(h+g*tau);
                a(iq,j)=h+s*(g-h*tau);
              end

              for j=1:n
                g=v(j,ip);
                h=v(j,iq);
                v(j,ip)=g-s*(h+g*tau);
                v(j,iq)=h+s*(g-h*tau);
              end

              nrot=nrot+1;
            end
            
          end
        end


        for ip=1:n
          b(ip)=b(ip)+z(ip);
          d(ip)=b(ip);
          z(ip)=0.;
        end

end
      pause 'too many iterations in jacobi'
  
