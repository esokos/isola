function [line_number] = RESPfind(respfile,comp,pzdate)
% This function will go through a large RESP file
% and find the start line of the requested response
% based on component name and date
% e.g. comp='HHE'
% pzdate=datetime(2008,11,12)
% it will only return the line number
% use another code to extract the response in a separate file
% Date 07/11/2020

%%
% if something goes wrong.!
line_number=-1;

% convert to datenum
RespDateNumber = datenum(pzdate);

%%  find place in resp file 
fid = fopen(respfile);

tline = fgets(fid); 

nline=1;

while ischar(tline)
%  
 if length(tline)>7
     
  check=tline(1:7) ;
     
   if  strcmp(check,'B052F04') % found component line
       % check if this is our comp
       k = textscan(tline, '%s %s %s');
       compcheck=char(k{3});
       
       if strcmp(comp,compcheck)
       
          % disp('Found component ')
           % move one line
           tline = fgets(fid); 
           check=tline(1:7) ;
           nline=nline+1;
           %% check the date now
             if strcmp(check,'B052F22')
          %      disp('Start date:')
                A=textscan(tline,'%s %s %s %s %f'); stime=A{4};Cstart = textscan(strrep(strrep(char(stime),':',' '),',',' '),'%f %f %f %f %f');
                startyear=Cstart{1}; startdoy =Cstart{2};
                StartDateNumber=datenum(startyear,1,startdoy);
                clear A   stime
                
             %  check end date
             tline = fgets(fid);
             check=tline(1:7);
             nline=nline+1;
             if strcmp(check,'B052F23')
           %     disp('End date:')
                A=textscan(tline,'%s %s %s %s %f');stime=A{4};
                Cend = textscan(strrep(strrep(char(stime),':',' '),',',' '),'%f %f %f %f %f');                
                endyear=Cend{1}; enddoy =Cend{2};
                EndDateNumber=datenum(endyear,1,enddoy);
             else
                disp('This should not happen !! Check resp format') 
             return
             end
             
                 if RespDateNumber > StartDateNumber &&  RespDateNumber < EndDateNumber
                     disp('Found epoch')
                     line_number=nline-6; % move a few lines above to start from Station line
                 return
                 end
                 
                 
             else
                disp('This should not happen !! Check resp format')  
             return                 
             end
                 
       else
         % not THE component we need..
           disp('Not the component we need')
           nline=nline+1;
         %  linearray{nline}=tline;
           tline = fgets(fid) ;           
       end

      
   else
    % not a component line leave..
     nline=nline+1;
    % linearray{nline}=tline;
     tline = fgets(fid) ;
   end

   
   
 else % < 7 chars
     
     nline=nline+1;
   %  linearray{nline}=tline;
     tline = fgets(fid) ;
     
 end
     
     

end

 
