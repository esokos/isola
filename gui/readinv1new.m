function [inv1_isour_shift,inv1_eigen,alphas,sigma_alphas,inv1_mom,inv1_mag,inv1_vol,inv1_dc,inv1_clvd,inv1_sdr1,inv1_sdr2,inv1_varred,cor_src]=readinv1new(filename,nsources,subevent_needed)

% find skip lines (to reach subevent needed) depends on subevent_needed and nsources
% fix
          if subevent_needed ~=1
              skiplines= (subevent_needed-1)*(31+nsources); 
              skiplines=skiplines+(subevent_needed-1);
          else
              skiplines=0;     
          end
          
          fid = fopen(filename,'r');
             for i=1:skiplines
                linetmp=fgets(fid);            
             end
            
            linetmp=fgets(fid);             
            linetmp=fgets(fid);            
            linetmp=fgets(fid);             %3
%              for i=1:nsources
%               linetmp=fgets(fid);            
%              end
            % this is needed for plotting correlation vs source
             cor_src=fscanf(fid,'%d %d %f %e %f %f %f %f %f %f %f',[11 nsources]);
            linetmp=fgets(fid); 
            linetmp=fgets(fid);              %nsources+1
            linetmp=fgets(fid);              
            linetmp=fgets(fid);             
            inv1_isour_shift=sscanf(linetmp,'%*s %d %d');
            linetmp=fgets(fid);             
            linetmp=fgets(fid);            
            linetmp=fgets(fid);             
            inv1_eigen=sscanf(linetmp,'%e %e %e'); 
            % read another two lines
            linetmp=fgets(fid);
            linetmp=fgets(fid);
 
            if length(linetmp) > 3 % old inv1
%                disp('old inv1')
%                    for i=1:5
%                         linetmp=fgets(fid);            
%                    end
                     linetmp=fgets(fid);
                     linetmp=fgets(fid);
                     alphas=sscanf(linetmp,'%e %e %e %e %e %e');
                     linetmp=fgets(fid);
                     linetmp=fgets(fid);
                     sigma_alphas=sscanf(linetmp,'%e %e %e %e %e %e');
                     linetmp=fgets(fid);  %empty line
                     linetmp=fgets(fid);
                     inv1_mom=sscanf(linetmp,'%*s %*s %e');
                     linetmp=fgets(fid);  
                     inv1_mag=sscanf(linetmp,'%*s %*s %f');
                     linetmp=fgets(fid);  
                     inv1_vol=sscanf(linetmp,'%*s %*s %*s %f');       
                     linetmp=fgets(fid);  
                     inv1_dc=sscanf(linetmp,'%*s %*s %*s %f');       
                     linetmp=fgets(fid);  
                     inv1_clvd=sscanf(linetmp,'%*s %*s %*s %f');       
             %
                     linetmp=fgets(fid);            
                     inv1_sdr1=sscanf(linetmp,'%*s %u %u %d');      
                     linetmp=fgets(fid);            
                     inv1_sdr2=sscanf(linetmp,'%*s %u %u %d');       
                     linetmp=fgets(fid);             
                     linetmp=fgets(fid);            
                     linetmp=fgets(fid);            
                     linetmp=fgets(fid);            
                     linetmp=fgets(fid);            
                     linetmp=fgets(fid);       
                     linetmp=fgets(fid);   
                     inv1_varred=sscanf(linetmp,'%*s %e');       
                
            else   % new inv1
                           disp('new inv1')
                   for i=1:10
                        linetmp=fgets(fid);            
                   end
                     linetmp=fgets(fid);  
                     inv1_mom=sscanf(linetmp,'%*s %*s %e');
                     linetmp=fgets(fid);  
                     inv1_mag=sscanf(linetmp,'%*s %*s %f');
                     linetmp=fgets(fid);  
                     inv1_vol=sscanf(linetmp,'%*s %*s %*s %f');       
                     linetmp=fgets(fid);  
                     inv1_dc=sscanf(linetmp,'%*s %*s %*s %f');       
                     linetmp=fgets(fid);  
                     inv1_clvd=sscanf(linetmp,'%*s %*s %*s %f');       
             %
                     linetmp=fgets(fid);            
                     inv1_sdr1=sscanf(linetmp,'%*s %u %u %d');      
                     linetmp=fgets(fid);            
                     inv1_sdr2=sscanf(linetmp,'%*s %u %u %d');       
                     linetmp=fgets(fid);             
                     linetmp=fgets(fid);            
                     linetmp=fgets(fid);            
                     linetmp=fgets(fid);            
                     linetmp=fgets(fid);            
                     linetmp=fgets(fid);       
                     linetmp=fgets(fid);   
                     inv1_varred=sscanf(linetmp,'%*s %e');       
            end
            
         fclose(fid);

