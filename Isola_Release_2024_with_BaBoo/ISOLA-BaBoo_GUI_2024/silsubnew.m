function [str1,dip1,rake1,str2,dip2,rake2,adc_1,adc_2,avol_1,avol_2,amt] = silsubnew(a)
%      converted to matlab from  silsubnew in fortran
%      Fortran Author: J. Sileny, modified by J.Z.
      
      am(1,1)=-1.*a(4)+a(6);
      am(2,2)=-1.*a(5)+a(6);
      am(3,3)=a(4)+a(5)+a(6);
      am(1,2)=a(1);
      am(1,3)=a(2);
      am(2,3)=-a(3);
      am(2,1)=am(1,2);
      am(3,1)=am(1,3);
      am(3,2)=am(2,3);
%C     scaling of the tensor Mij
      amt=sqrt(.5*(am(1,1)*am(1,1)+am(2,2)*am(2,2)+am(3,3)*am(3,3))+am(1,2)*am(1,2)+am(1,3)*am(1,3)+am(2,3)*am(2,3));
      facm=1./amt/sqrt(2.);
%
      for i=1:3
          for j=1:3
            am(i,j)=am(i,j)*facm;   %! mohu nasobit lib. konstantou a rozklad se nezmeni
            amm(i,j)=am(i,j);
          end
      end
      
%     computation of eigenvalues and eigenfunctions, their ordering
      [T,EN,AK] = jacobi2(3,50,1e-9,1e-9,1e-9,am);
      [en,T]=line2(EN,T,3);

%     create right-handed system from eigenvectors
      HLP(1)=T(2,1)*T(3,2)-T(3,1)*T(1,2);
      HLP(2)=T(3,1)*T(1,2)-T(1,1)*T(3,2);
      HLP(3)=T(1,1)*T(2,2)-T(2,1)*T(1,2);
      
      if (HLP(1)*T(1,3)+HLP(2)*T(2,3)+HLP(3)*T(3,3) < 0)
          for J=1:3
             T(J,3)=-T(J,3);
          end
      else
      end
    
      amv=en(1)+en(2)+en(3);
      for j=1:3
       en1(j)=en(j)-amv/3.;
      end

      en1max=max([ abs(en1(1)) abs(en1(2)) abs(en1(3)) ]);
      en1min=min([ abs(en1(1)) abs(en1(2)) abs(en1(3)) ]);
      
      if (abs(en1max) < 1e-20)  
	    disp('problem in silsubnew')
        disp('MT is 100% ISO')
        disp('s/d/r are undefined')
        adc=0;
        amv1=100;
        return
      else
	   eps=-en1min/abs(en1max);
      end
 
%       construct vectors lambda_dev, d, l and l1'
        sqr2=1./sqrt(2.);
        sqr3=1./sqrt(3.);
        sqr1=1./sqrt(1.5);
        
        for j=1:3
         alm(j)=en1(1)*T(j,1)+en1(2)*T(j,2)+en1(3)*T(j,3);
         ad(j)=(T(j,1)-T(j,3))*sqr2;
         al(j)=(T(j,1)-.5*T(j,2)-.5*T(j,3))*sqr1;
         al1(j)=(.5*T(j,1)+.5*T(j,2)-T(j,3))*sqr1;
        end

%      compute angles: lambda_dev^l(min), lambda_dev^d, d^l
      angdl=ang(ad,alm);
      angll1=ang(al,alm);
      angll2=ang(al1,alm);
      angdll=ang(al,ad);
      angll=min(angll1,angll2);
      angll=angll/angdll;
      angdl=angdl/angdll;
%
%c     MT decomposition (1)
%c     write(2,*)' '
%c     write(2,*)' MT decomposition (1)'

      amv1=amv^2/(en(1)^2+en(2)^2+en(3)^2)/3.*100.;
      
%       if (amv >= 0.)
%         %  disp('V(explosive') 
%             %c     write(2,'('' V(explosive):'',t16,f5.1,''%'')')amv1
%       else
%        %   disp('V(implosive')
%             %c     write(2,'('' V(implosive):'',t16,f5.1,''%'')')amv1
%       end 
      
      aclvd=min([abs(en1(1)) abs(en1(2)) abs(en1(3))])/(max([abs(en1(1)) abs(en1(2)) abs(en1(3))]))*200.;
      
	  avol_1=sign2(amv1,amv);
      aclvd_1=aclvd;
	  adc_1=100.-aclvd;

%       if (angll1 < angll2)
%         %c     write(2,'('' CLVD(T-axis):'',t16,f5.1,''%'')')aclvd
%       else
%             %c     write(2,'('' CLVD(P-axis):'',t16,f5.1,''%'')')aclvd
%       end

%     MT decomposition (2)
%     write(2,*)' '
%     write(2,*)' MT decomposition (2)'

     amv1=abs(amv)/max([abs(en(1)) abs(en(2)) abs(en(3))])/3.*100.;
      
%       if (amv >= 0.)
%         %c     write(2,'('' V(explosive):'',t16,f5.1,''%'')')amv1
%       else
%             %c     write(2,'('' V(implosive):'',t16,f5.1,''%'')')amv1
%       end
      
      aclvd=2.*abs(eps)*(100.-amv1);
      adc=100.-amv1-aclvd;

	  avol_2=sign2(amv1,amv);
      aclvd_2=aclvd;
	  adc_2=adc;

%     write(2,'('' DC:'',t16,f5.1,''%'')')adc
%       if (angll1 < angll2)
%         %c     write(2,'('' CLVD(T-axis):'',t16,f5.1,''%'')')aclvd
%       else
%         %c     write(2,'('' CLVD(P-axis):'',t16,f5.1,''%'')')aclvd
%       end

      for j=1:3
        an1(j)=(T(j,1)+T(j,3))*.7071068;
        an2(j)=(T(j,1)-T(j,3))*.7071068;
      end

   
      [str1,dip1,rake1] = angles2(an1,an2);
      [str2,dip2,rake2] = angles2(an2,an1);
      

