function [u,v] = tk2uv(T,k)

   tau=T*(1-abs(k));
   
   if tau >= 0 && k <= 0
       u=tau;v=k;
   end
   
   if tau <= 0 && k >= 0
       u=tau;v=k;
   end
   
   if tau > 0 && k > 0
      if tau <= 4*k
         u=tau/(1-tau/2);
         v=k/(1-tau/2);
      elseif tau > 4*k
         u=tau/(1-2*k);
         v=k/(1-2*k);
      end
   
   elseif tau < 0 && k < 0
   
      if tau >= 4*k
         u=tau/(1+tau/2);
         v=k/(1+tau/2);
      elseif tau < 4*k
         u=tau/(1+2*k);
         v=k/(1+2*k);
      end
      
   end

         