function [src1time,src2time]=inv222time(src1,src2)

src1time=-1;
src2time=1;

      fid = fopen('.\timefunc\sel_pairs2.dat','r');
           
         tline = fgetl(fid); % 
             
          while ischar(tline)

            [selsrc] = sscanf(tline,'%f');

                if selsrc(1)==src1 && selsrc(2)==src2  % found the pair
                    
                        tline = fgetl(fid); %  skip this
                         
                              % read 12 lines
                              DATA1 = textscan(fid,'%f %f %f',12);
                                 [~,I]=max(DATA1{3});
                                  src1time=DATA1{2}(I);
                                  %
                              DATA2 = textscan(fid,'%f %f %f',12);
                                  [~,I]=max(DATA2{3});
                                  src2time=DATA2{2}(I);
                            
                else
                    
                end
 %           end
  
                tline = fgetl(fid); % EOL
                tline = fgetl(fid);
                
                
           end
           
      fclose(fid);