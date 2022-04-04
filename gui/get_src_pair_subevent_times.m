function [src1time,src2time] = get_src_pair_subevent_times(src1,src2)
% this function will search the sel_pairs2.dat file for the given source couple
% it will NOT plot the resulting time function but it will return in numerical form 
% the maximum time for the two subevents   
% it is used in timefun_twop.m
fid = fopen('.\timefunc\sel_pairs2.dat','r');
           
         tline = fgetl(fid);  % 
             
          while ischar(tline)
            selsrc = sscanf(tline,'%d %d');

                    if selsrc(1)==src1 && selsrc(2)==src2  % found the pair
                        %disp('here')
                       tline = fgetl(fid);
                        selsrc2 = sscanf(tline,'%d %d');
                        DATA1 = cell2mat(textscan(fid,'%f %f %f',120));
                         % plot
                            dur=selsrc2(1);  % first number is the duration
                            t1=DATA1(1:60,2) ;a1=DATA1(1:60,3);
                            t2=DATA1(61:120,2);a2=DATA1(61:120,3);
                            [x1,y1] = make_tr2(t1,a1,dur); % 1st subevent
                            [x2,y2] = make_tr2(t2,a2,dur); % 2nd subevent
                         % find maxima for sub1 and 2
                            [~,I]=max(y1); 
                            src1time=x1(I);
                            [~,I]=max(y2);
                            src2time=x2(I);
                               
                            fclose(fid);
                               
                        return
                    else
                        for jj=1:121
                        tlinedummy = fgetl(fid);
                        end
                      %  dummy = cell2mat(textscan(fid,'%f %f %f',120))
                    end
                    
             tline = fgetl(fid);
             
          end
          
   fclose(fid);
   

   
   