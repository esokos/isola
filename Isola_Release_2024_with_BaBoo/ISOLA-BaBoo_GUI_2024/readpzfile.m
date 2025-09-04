function [A0,constant,nzer,zeroes,npol,poles,nsclip,valid_date,digisens,seismsens] = readpzfile(stationpzfile)

% This function will read an ISOLA pzfile 
% from .\pzfiles folder
% it will return A0,constant,zeroes,poles,nsclip,digisens,seismsens
% Date 13/09/2015


%% Check if file exists
if ispc
  if ~exist([pwd '\pzfiles\' stationpzfile],'file')
    errstring=[ stationpzfile   '   file doesn''t exist. Please create and copy to pzfiles folder '];
    errordlg(errstring,'File Error');
    uiwait;
   return
  else
   disp(['Found  '  stationpzfile ' in pzfiles folder '])
  end
else
  if ~exist([pwd '/pzfiles/' stationpzfile],'file')
    errstring=[ stationpzfile   '   file doesn''t exist. Please create and copy to pzfiles folder '];
    errordlg(errstring,'File Error');
    uiwait;
   return
  else
   disp(['Found  '  stationpzfile ' in pzfiles folder '])
  end
end
%% Read the file
if ispc
    fid = fopen([pwd '\pzfiles\' stationpzfile],'r');
else
    fid = fopen([pwd '/pzfiles/' stationpzfile],'r'); 
end

    aa=fgetl(fid);
      A0=str2double(fgetl(fid));
    aa=fgetl(fid);
      constant=str2double(fgetl(fid));
    aa=fgetl(fid);
      nzer=str2double(fgetl(fid));
       for p=1:nzer
        zer=str2num(fgetl(fid));
        zeroes(p)=complex(zer(1,1),zer(1,2));
       end
       if nzer == 0
        zeroes=[];
       end
%%% finished with zeroes
%%% read poles
    aa=fgetl(fid);
      npol=str2double(fgetl(fid));
       for i=1:npol
        pol=str2num(fgetl(fid));
        poles(i)=complex(pol(1),pol(2));
       end
%%%% check if there is info to compute  clip level 
       ffline=fgets(fid);
       AA=ischar(ffline);
            switch AA
            case 1
                idx1 = strfind(ffline, 'Info:');
                if idx1 == 1
                        info=strrep(strrep(strrep(ffline, 'Info:', ''),'Digi sens',''),'Seism sens','');
                        C = textscan(info,'%s %s %f %f');
                        valid_date=C{1};
                        %st=C{2};
                        digisens=C{3};
                        seismsens=C{4};
                        nsclip=1;
                        disp('Read Clip info for NS.')
                 else
                        disp('Check the last line in pz file. It doesn''t seem correct. Clip info not read.')
                        nsclip=0;
                        valid_date='';
                        digisens=0;
                        seismsens=0;
                 end
            case 0
                nsclip=0;
                digisens=0;
                seismsens=0;
                valid_date='';
                disp('Clip info not found for NS')
            otherwise
                nsclip=0;
                digisens=0;
                seismsens=0;
                valid_date='';
                disp('Error')
            end
fclose(fid);
