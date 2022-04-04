function [src1time,src2time]=inv222time(src1,src2)

src1time=-1;
src2time=1;

      if ispc
          fid = fopen('.\timefunc\sel_pairs2.dat','r');
      else
          fid = fopen('./timefunc/sel_pairs2.dat','r'); 
      end

         tline = fgetl(fid); % 
             
          while ischar(tline)

            [selsrc] = sscanf(tline,'%f');
           
              if numel(selsrc)==2
               
                    if selsrc(1)==src1 && selsrc(2)==src2  % found the pair
                    
                        tline = fgetl(fid); %  skip this
                         
                              % read 12 lines
                              DATA1 = textscan(fid,'%f %f %f',60);
                                 [~,I]=max(DATA1{3});
                                  src1time=DATA1{2}(I);
                                  %
                              DATA2 = textscan(fid,'%f %f %f',60);
                                  [~,I]=max(DATA2{3});
                                  src2time=DATA2{2}(I);
                            
                    else
                    %   disp('no match')
                    end

                    tline = fgetl(fid); % EOL
                    tline = fgetl(fid);
              
              else
                %  disp('3 elem')
                  tline = fgetl(fid);
              end
                
           end
           
      fclose(fid);