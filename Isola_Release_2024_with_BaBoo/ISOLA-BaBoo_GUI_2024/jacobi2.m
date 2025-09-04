function [t,eigen,aik] = jacobi2(n,itmax,eps1,eps2,eps3,a)
      for i=1:n
       for j=1:n
          t(i,j)=0.;
       end
      end
%%  
      nm1=n-1;
      sigma1=0.;
      offdsq=0.;
      for i=1:n
       sigma1=sigma1+a(i,i)^2;
       t(i,i)=1.;
       ip1=i+1;
        if (i >= n) 
%%          
         s=2.*offdsq+sigma1; 
          for iter=1:itmax
            for i=1:nm1  % 160
                ip1=i+1;
            for j=ip1:n
                q=abs(a(i,i)-a(j,j));
            if (q > eps1) 
              if (abs(a(i,j)) <= eps2) %!goto 160
              a(i,j)=0.;
              sigma2=0.;
                for i=1:n
                    eigen(i)=a(i,i);
                    sigma2=sigma2+eigen(i)^2;
                end
                if (1.0-sigma1/sigma2 < eps3) %goto 190
                  return
                else
                sigma1=sigma2;
                %disp('no convergence with')
                break
                end
              end

             p=2.*a(i,j)*q/(a(i,i)-a(j,j));
             spq=sqrt(p*p+q*q);
             csa=sqrt((1.+q/spq)*.5);
             sna=p/(2.*csa*spq);
            
            else
             csa=.707106781186547;
             sna=csa;
            end
         
         for k=1:n
          holdki=t(k,i);
          t(k,i)=holdki*csa+t(k,j)*sna;
          t(k,j)=holdki*sna-t(k,j)*csa;
         end

         for k=1:n
          if (k <= j) 
             aik(k)=a(i,k);
             a(i,k)=csa*aik(k)+sna*a(k,j);
              if (k == j) 
               a(j,k)=sna*aik(k)-csa*a(j,k);
              end
          else
             holdik=a(i,k);
             a(i,k)=csa*holdik+sna*a(j,k);
             a(j,k)=sna*holdik-csa*a(j,k);
          end
         end  
  
         aik(j)=sna*aik(i)-csa*aik(j);
         
         for k=1:j
          if (k > i) 
             a(k,j)=sna*aik(k)-csa*a(k,j);
          else
             holdki=a(k,i);
             a(k,i)=csa*holdki+sna*a(k,j);
             a(k,j)=sna*holdki-csa*a(k,j);
          end
         end
         
          a(i,j)=0.; 
         
      end %160
      end %150
      
       sigma2=0.;
       
       for ii=1:n
        eigen(ii)=a(ii,ii);
        sigma2=sigma2+eigen(ii)^2;
       end
  
       if (1.-sigma1/sigma2 < eps3) %goto 190
           return
       end
       
        sigma1=sigma2;
       end
        
%          
        else
            for j=ip1:n
               offdsq=offdsq+a(i,j)^2;
            end
        end
      end
