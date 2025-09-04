function [strike,dip,rake]=angles2(ann1,ann2)
%  subroutine angles (ann1,ann2,dip,strike,rake)
%c procedure angles determines dip, strike and rake angles from
%c nodal plane normals;
%c to obtain both the solutions it has to be called twice:
%c call angles (an1,an2,d1,s1,r1)
%c call angles (an2,an1,d2,s2,r2)
      eps=0.001;
      fac=180./3.1415927;
%%      
      if ann1(3) > 0 
         for j=1:3
          an2(j)=-ann2(j);
          an1(j)=-ann1(j);
         end
      else
         for j=1:3
          an2(j)=ann2(j);
          an1(j)=ann1(j);
         end
      end
%%      
      if an1(3) < -0.99
         dip=acos(0.999);
      else
         dip=acos(-an1(3));
      end
%%     
      if abs(abs(an1(3))-1.) < eps
         rake=0.;
         strike=atan2(an2(2),an2(1));
             if strike < 0 
                 strike=strike+6.2831853;
             end
      else
         sdi=1./sqrt(1.-an1(3)*an1(3));
         strike=atan2(-an1(1)*sdi,an1(2)*sdi);
         
         if strike <0
             strike=strike+6.2831853;
         end
             
         if abs(an1(3)) < eps 
            if abs(strike) < eps                
               rake=atan2(-an2(3),an2(1));
            elseif abs(abs(strike)-1.5707963) <  eps
                rake=atan2(-an2(3),an2(2));
            else
                cf=cos(strike);
                sf=sin(strike);
                 if abs(cf) >  abs(sf)
                   cr=an2(1)/cf;
                 else
                   cr=an2(2)/sf;
                 end
                rake=atan2(-an2(3),cr);
            end
         else
            cf=cos(strike);
            sf=sin(strike);
            rake=atan2((an2(1)*sf-an2(2)*cf)/(-an1(3)),an2(1)*cf+an2(2)*sf);
         end
      end
      
      dip=dip*fac;
      strike=strike*fac;
      rake=rake*fac;
