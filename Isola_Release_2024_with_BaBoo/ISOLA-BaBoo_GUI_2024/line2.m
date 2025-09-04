function [a,t] = line2(a,t,n)

for kk=1:n
       am=a(kk);
  for  k=kk:n
        if a(k)> am 
            am=a(k);
        end
  end
  
  for k=kk:n
        if a(k)==am 
            break
        else
        end
  end
  
% after break
           a(k)=a(kk);
           a(kk)=am;
            for  j=1:3
              p9=t(j,k);
              t(j,k)=t(j,kk);
              t(j,kk)=p9;
            end
            
end

% 
%             
%             return
%         else
%         end
%            a(k)=a(kk);
%            a(kk)=am;
%             for  j=1:3
%                 p9=t(j,k);
%                 t(j,k)=t(j,kk);
%                 t(j,kk)=p9;
%             end 
%         else
%         end
%   end
% end
