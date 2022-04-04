function ok = check_raw_data
%
% it will check if all raw data files exist in invert folder
%
%%
if ispc
 h=dir('.\invert\allstat.dat');
else
 h=dir('./invert/allstat.dat');
end
%%
  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
  else
                if ispc   
                   [NS,us1,us2,us3,us4,f11,f12,f13,f14] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 
                else
                   [NS,us1,us2,us3,us4,f11,f12,f13,f14] = textread('./invert/allstat.dat','%s %f %f %f %f %f %f %f %f',-1); 
                end
                     nostations = length(NS);
                      for i=1:nostations
                         realdatafilename{i}=[char(NS(i)) 'raw.dat'];
                      end
                      % now check if all RAW files are present
                   cd invert
                      %
                      for i=1:nostations
                       if exist(realdatafilename{i},'file')
                        disp(['Copying ' realdatafilename{i} ' to newunc folder.'])            %' will be masked as ' maskdatafilename{i}])
                        copyfile(char(realdatafilename{i}),['..\newunc\' char(realdatafilename{i})])
                       else
                       disp(['File ' realdatafilename{i} ' is missing'])
                       errordlg(['File ' realdatafilename{i} '  not found in invert folder. Run Data Preparation for this station' ] ,'File Error');    
                       end
                      end
                    % back one folder
                    disp('   ')
                   cd ..
                   ok =1;
  end % if for allstat existance
