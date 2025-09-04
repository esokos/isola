function [ok] = Resp2ISLpz(respfilename,isolapzfile,comp,respdate)

%% if the component is from strong motion ask the user if he needs response in velocity
if strcmp(comp(2),'N')

answer = questdlg('Seems this is a Strong motion Stream. Should i add an extra zero?', ...
		'Response Type Selection', ...
	    'Yes','No','No');
% Handle response
  switch answer
     case 'Yes'
         disp([answer ' .Velocity Response output.'])
         rtype = 1;
     case 'No'
         disp([answer ' .Acceleration Response output.'])
         rtype = 2;
  end

else  %% broad band
    rtype=2;
end

%%
% call RESPfind to know where to look in big RESP file
eline=RESPfind(respfilename,comp,respdate);

if eline==-1
   
    warndlg('Error this Epoch doesn''t exist','Error');
    return
else
end
    



%% extract the requested part of response from big file to a small one
fid = fopen(respfilename);

fid2 = fopen('tempresp.txt','w');

% skip lines according to RESPfind
for ii=1:eline
    tline = fgets(fid);
end

%%
tline= fgets(fid);
   
while ischar(tline)
   
    if length(tline)>7
        check=tline(1:7);
        
          if strcmp(check,'#######')
              break
          else
              fprintf(fid2,'%s',tline) ;
          end
        
        
    else
       fprintf(fid2,'%s',tline) ;
    end
    
    tline= fgets(fid);
    
end

fclose(fid2);
fclose(fid);

%%
resp2isolapz('tempresp.txt',isolapzfile,rtype);

% remove tempresp.txt ??

ok=1;

end

