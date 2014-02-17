function [inv1_isour_shift,inv1_eigen,inv1_mom,inv1_mag,inv1_vol,inv1_dc,inv1_clvd,inv1_sdr1,inv1_sdr2,inv1_varred]=readinv1(nsources,subevent_needed)
%% look for inv1.dat file 
fh2=exist('inv1.dat','file');
if (fh2~=2);
    disp('Invert folder doesn''t contain inv1.dat.');
inv1life=0;    
else
        fileInfo = dir('inv1.dat');
        fileSize = fileInfo.bytes;
        if fileSize==0
              disp('inv1.dat file in invert folder is of zero size')
              inv1life=0;    
        else
              disp('Found valid inv1.dat file in invert folder.')
              inv1life=1;    
        end
end

%%
if inv1life ==1  %read it 
    
          % find skip lines (to reach subevent needed) depends on subevent_needed and nsources

% fix
          if subevent_needed ~=1
              
              skiplines= (subevent_needed-1)*(31+nsources); 
              skiplines=skiplines+(subevent_needed-1);
              
          else
              skiplines=0;     
          end
          
          fid = fopen('inv1.dat','r');
             for i=1:skiplines
                linetmp=fgets(fid);            
             end
            
            linetmp=fgets(fid);             
            linetmp=fgets(fid);            
            linetmp=fgets(fid);             %3
             for i=1:nsources
              linetmp=fgets(fid);            
             end
            linetmp=fgets(fid);             %nsources+1
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
                disp('old inv1')
                   for i=1:5
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
else
end
