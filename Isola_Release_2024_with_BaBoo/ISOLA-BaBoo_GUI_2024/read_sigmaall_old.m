function sigma = read_sigmaall(filename,trialsource,stype)

disp('this is read_sigmall')

filename
trialsource
stype

% read the file in memory
c=textread(filename,'%s','delimiter','\r\n'); 
% remove line with Covariance matrix; NOT corrected for  scaling
c(ismember(c,'Covariance matrix; NOT corrected for  scaling')) = []; 
% remove empty lines
%c(~cellfun('isempty',c))
R=rmmissing(c) ;

Index = find(contains(R,'trial'));

for ii=1:length(Index)

    C = textscan(R{Index(ii)}, '%s %s %s %f');
    tsource=C{4}
    trialsource

    whos

    if iscell(tsource)
      tsource=cell2mat(tsource);
    else
      disp('tsource not cell')
    end
   
    
     if  trialsource==tsource  % this is the info we need
       disp('Found Covariance matrix line. Reading data now...  ')
       % read data
         if strcmp(stype,'DEV')
            C = R(Index(ii)+1:Index(ii)+5);
            
            for jj=1:length(C)   
               sigma(jj,:)= sscanf(C{jj},'%f %f %f %f %f');
            end
            
         else
            C = R(Index(ii)+1:Index(ii)+6) ;
            for jj=1:length(C)   
               sigma(jj,:)= sscanf(C{jj},'%f %f %f %f %f %f');
            end
            
         end
            break 
     end    
    
end

%%




  
  
%%
% trialsource
% stype
% fid=fopen(filename);
% 
% if strcmp(stype,'FULL')
%     
%   while 1
%     tline = fgetl(fid);
%     if ~ischar(tline), break, end
%     
%     C = textscan(tline, '%s %s %s %f');
%     tsource=C{4};
% 
%     if  trialsource==tsource  % this is the info we need
%        disp('Found Covariance matrix line. Reading data now...  ')
%        % read empty lines
%        for ii=1:13
%            tline = fgetl(fid);
%        end
%        
%        % read data
%        C = textscan(fid, '%f %f %f %f %f %f',6);
%        sigma=cell2mat(C);
%         break 
%     else % skip this part
%        for ii=1:19
%            tline = fgetl(fid);
%        end
%     end
%        % disp('Found Covariance matrix line. Reading data now...  ')
%      
%   end
% 
% else % DEV
%     disp('DEV source')
%     
%   while 1
%     tline = fgetl(fid)
%     if ~ischar(tline), break, end
%     
%     C = textscan(tline, '%s %s %s %f') 
%     tsource=C{4} 
% 
%     if  trialsource==tsource  % this is the info we need
%        disp('Found Covariance matrix line. Reading data now...  ')
%        % read empty lines
%        for ii=1:12
%            tline = fgetl(fid) 
%        end
%        
%        % read data
%        C = textscan(fid, '%f %f %f %f %f %f',6);
%        sigma=cell2mat(C);
%         break 
%     else % skip this part
%         disp('Skip this part')
%        for ii=1:17
%            tline = fgetl(fid)
%        end
%         
%     end
%        % disp('Found Covariance matrix line. Reading data now...  ')
%   end
%   
%   
% end  
%     
% 

end

