function [x1,y1,x2,y2] = get_src_pair2(src1,src2)
% this function will search the sel_pairs2.dat file for the given source couple
% and will NOT plot the resulting time function
% it will return in numerical form x1,y1,x2,y2 time and amplitude of the time 
% function for the two subevents   
% it is used in plotallsrcpairs.m

     fid = fopen('.\timefunc\sel_pairs2.dat','r');
           
         tline = fgetl(fid);  % 
             
          while ischar(tline)
 
            selsrc = sscanf(tline,'%d %d');
              
                    if selsrc(1)==src1 && selsrc(2)==src2  % found the pair
                       tline = fgetl(fid);
                        selsrc2 = sscanf(tline,'%d %d');
                        DATA1 = cell2mat(textscan(fid,'%f %f %f',120));
                         % plot
                            dur=selsrc2(1);  % first number is the duration
                            t1=DATA1(1:60,2) ;a1=DATA1(1:60,3);
                            t2=DATA1(61:120,2);a2=DATA1(61:120,3);
                            [x1,y1] = make_tr2(t1,a1,dur); % 1st subevent
                            [x2,y2] = make_tr2(t2,a2,dur); % 2nd subevent
                            % plot
                           % figure
                           % plot(x1,y1,'b')
                           % hold 
                           % plot(x2,y2,'g')
                           % plot(x2,y1+y2,'r')
                           % h = legend(['Source ' num2str(src1)],['Source ' num2str(src2)],['Sum ' num2str(src1) '+' num2str(src2)]);
%                             subplot(3,1,1)
%                             title('Source 1')
%                             v=axis;
%                             %axis([llimit rlimit v(3) v(4)])
%                             subplot(3,1,2)
%                             title('Source 2')
%                             v=axis;
%                             %axis([llimit rlimit v(3) v(4)])
%                             subplot(3,1,3)
%                             title('Sum 1+2')
%                             v=axis;
                            %axis([llimit rlimit v(3) v(4)])                            
                            
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
   

   
   