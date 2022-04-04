function  prep_extrpol

ttt = findobj(gcf,'Type','uitable');
data=get(ttt,'Data');

stnames=get(ttt,'RowName');

%celldisp(data)

lat=data(:,1);
lon=data(:,2);
pol=data(:,3);

%%
   if ispc
     fid = fopen('.\csps\extrapol.pol','w');
   else
     fid = fopen('./csps/extrapol.pol','w');  
   end

% whos
% check which have polarity info

    for i=1:length(lat)
       if strcmp(strtrim(pol(i)),'')
           disp(['no polarity info for station ' char(stnames{i})  ])
       else
           disp(['found polarity info for station '  char(stnames{i}) '  ' char(pol{i})  ])
            if ispc
              fprintf(fid,'%s %f  %f  %s\r\n', char(stnames{i}), cell2mat(lat(i)), cell2mat(lon(i)), char(pol{i}));
            else
              fprintf(fid,'%s %f  %f  %s\r', char(stnames{i}), cell2mat(lat(i)), cell2mat(lon(i)), char(pol{i}));  
            end
       end
       
    end
           
   fclose(fid);
   
%%
close gcf
   