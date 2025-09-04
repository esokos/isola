function [ ok ] = RESPextract(respfile,comp,pzdate)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% it will read a RESP file and write in new file the 
% repsonse for the specific date and component

%pzdate should be a datetime array


fid2=fopen('ttt.txt','w');

%resp_doy=day(pzdate,'dayofyear'); resp_year = year(pzdate);

% convert to datenum
RespDateNumber = datenum(pzdate);

fid = fopen(respfile);

tline = fgets(fid); 

ftell(fid)

nline=0;

while ischar(tline)
%
%  
 if length(tline)>7
        
     check=tline(1:7) ;
     
      if strcmp(check,'B052F22')
         disp('Start date:')
         A=textscan(tline,'%s %s %s %s %f'); stime=A{4};
         Cstart = textscan(strrep(strrep(char(stime),':',' '),',',' '),'%f %f %f %f %f');
         
         startyear=Cstart{1}; startdoy =Cstart{2};
         StartDateNumber=datenum(startyear,1,startdoy);
          
         clear A   stime
      
      %  check end date
      tline = fgets(fid);
      check=tline(1:7);
          
      if strcmp(check,'B052F23')
         disp('End date:')
         A=textscan(tline,'%s %s %s %s %f');stime=A{4};
         Cend = textscan(strrep(strrep(char(stime),':',' '),',',' '),'%f %f %f %f %f');                

         endyear=Cend{1}; enddoy =Cend{2};
         EndDateNumber=datenum(endyear,1,enddoy);
            
         
      else
         disp('sfdfsdf ') 
         return
      end
      
%     check if this is the time period we need                 
                 if RespDateNumber > StartDateNumber &&  RespDateNumber < EndDateNumber 
                     
                     disp('found epoch')
                     tt='#########';
                     cur_byte=ftell(fid)
                     fseek(fid,-cur_byte , 'cof')
                     
                      tline = fgetl(fid) 
                       
                      pause
                      while ischar(tline)
                         if length(tline)>7
                            check2=tline(1:9);
                            if ~strcmp(tt,check2) 
                                fprintf(fid2,'%s\n',tline) ;
                            else
                                
                                return
                            end
                            
                         else
                             fprintf(fid2,'%s',tline) ;
                         end
                          
                          tline = fgetl(fid);
                      end
                         
                 else 
                 % this is not our epoch move on
                 
                 
                 
                 end
          clear A stime
          
      else
          nline=nline+1;
          linearray{nline}=tline
          tline = fgets(fid); 
      end
 else
     
     nline=nline+1;
     linearray{nline}=tline
     
     tline = fgets(fid) ;
 end  

end

