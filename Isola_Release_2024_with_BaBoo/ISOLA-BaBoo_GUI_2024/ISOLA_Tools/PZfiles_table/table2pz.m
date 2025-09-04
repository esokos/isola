function ok = table2pz(filename,station,resp_date)

% This function will read a text file in the following format
% ANKY	35.86704	23.30117	143	AntikythiraIsland	PS6-SC	CMG-3ESPC60	2008-10-21	2050-01-01
% APE	37.07274	25.52301	608	ApeiranthosNaxos	PS6-SC	STS-2		2008-04-29	2050-01-01

% and will produce pole zero file for ISOLA
% e.g. table2pz('NOA3.dat','ANKY','2005-01-01');
% will search NOA3.dat file for station ANKT response for the period
% 2005-01-01 and it will produce the pole zero files
% a file called digitizers.txt with digitizer info
% and separate files per sensor must be in the same folder

% E.Sokos 28/07/2014



% Response date
  resp_dateno=datenum(resp_date,'yyyy-mm-dd');

%%
fid = fopen(filename);
fid2 = fopen('digitizers.txt');

tline = fgetl(fid);

while ischar(tline)

    C = textscan(tline,'%s %f %f %f %s %s %s %s %s');  
    
%% check if we need this station
    if strcmp(C{1},station)

        disp(['Found station '   char(C{1})  '    Digitizer   ' char(C{6})  '   Sensor '  char(C{7})  ])
        digi=char(C{6});  sensor=char(C{7});

       %  dates
       start_dateno=datenum(char(C{8}),'yyyy-mm-dd');
       end_dateno=datenum(char(C{9}),'yyyy-mm-dd');     
        
%% Date if      
    if resp_dateno > start_dateno && resp_dateno < end_dateno
        disp(['Response info in file '  filename '  is valid from ' char(C{8}) ' to ' char(C{9})])
        disp(['Requested date '  resp_date '  is valid for this period '])
        
        digitizer_value=0;
      % search digitizer file
        tdigi = fgetl(fid2);
        
           while ischar(tdigi)
            
               D = textscan(tdigi,'%s %f');
               
                 if strcmp(char(D{1}),digi)
                     disp(['Found digi value='  num2str(D{2})])
                     digitizer_value=D{2};
                 else
                    
                 end
                 
              % next digi
             tdigi = fgetl(fid2);     
           end

         %end of digitizer search
%        
         if digitizer_value==0
            disp('Error digitizer is not in file') 
         end
         
%%     Search for sensor info

       if exist(sensor);
           disp ('found sensor file')
           % read the file
             [A0,sens,nzer,zeroes,npol,poles] =readpz(sensor);
           % write to file
           
           ok=writepz(station,'BHZ',A0,sens,digitizer_value,nzer,zeroes,npol,poles);
           ok=writepz(station,'BHE',A0,sens,digitizer_value,nzer,zeroes,npol,poles);
           ok=writepz(station,'BHN',A0,sens,digitizer_value,nzer,zeroes,npol,poles);
           
           
       else
            disp ('not found sensor file')
       end

% date if

    else
        disp(['Response info in file '  filename '  is valid from ' char(C{8}) ' to ' char(C{9})])
        disp(['Requested date '  resp_date '  is NOT valid for this period '])
    end

     else
         
     end
    
    % next
    tline = fgetl(fid);
    
end

fclose(fid);
fclose(fid2);
