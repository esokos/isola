function [staname,stalon,stalat,netname] = tk2isolapz(filename)

fid = fopen(filename);
tline1 = fgetl(fid);tline2 = fgetl(fid);
netname=sscanf(tline2(strfind(tline2,':')+1:end),'%s');

tline3 = fgetl(fid);
% station name
staname=sscanf(tline3(strfind(tline3,':')+1:end),'%s');

tline4 = fgetl(fid);tline5 = fgetl(fid);
% station component
stacomp=sscanf(tline5(strfind(tline5,':')+1:end),'%s');

tline6 = fgetl(fid);tline7 = fgetl(fid);tline8 = fgetl(fid);
tline9 = fgetl(fid);tline10 = fgetl(fid);
%lat
stalat=sscanf(tline10(strfind(tline10,':')+1:end),'%f');
tline11 = fgetl(fid);
%lon
stalon=sscanf(tline11(strfind(tline11,':')+1:end),'%f');

tline12 = fgetl(fid);tline13 = fgetl(fid);tline14 = fgetl(fid);tline15 = fgetl(fid);
tline16 = fgetl(fid);tline17 = fgetl(fid);

% input unit
inunit=sscanf(tline17(strfind(tline17,':')+1:end),'%s');

tline18 = fgetl(fid);tline19 = fgetl(fid);

tline20 = fgetl(fid);
%gain seismometer
[instgain,~,~,nextindex]=sscanf(tline20(strfind(tline3,':')+1:end),'%f');

tmp=tline20(strfind(tline20,':')+1:end);

gaintype=tmp(nextindex:end);

if strcmp(gaintype,'(M/S)')
    %disp('velocity gain')
else
    disp('NOT velocity gain')
    pause
end

tline21 = fgetl(fid);
%sens digitizer
[sens,~,~,nextindex]=sscanf(tline21(strfind(tline21,':')+1:end),'%f');

tmp=tline21(strfind(tline21,':')+1:end);gaintype=tmp(nextindex:end);

if strcmp(gaintype,'(M/S)')
   % disp('velocity gain')
else
    disp('NOT velocity gain')
    pause
end

tline22 = fgetl(fid);
%staA0
staA0=sscanf(tline22(strfind(tline22,':')+1:end),'%f');
%
tline23 = fgetl(fid);
% read zeros
tline24 = fgetl(fid);
nz=tline24(6:end);

if str2num(nz)~=0
 for ii=1:str2num(nz)
    tline = fgetl(fid);
    z(ii,:)=sscanf(tline,'%f %f');
 end
else
 %nz=0    
 disp('0 ZEROS')
 pause
    nz='1';
    z=[0.00e0 0.000e0];
end
% read poles
tlinep = fgetl(fid);
np=tlinep(6:end);

for ii=1:str2num(np)
    tline = fgetl(fid);
    p(ii,:)=sscanf(tline,'%f %f');
end
fclose(fid);

%whos z
%%
disp([staname ' ' stacomp  ' ' num2str(stalat) ' ' num2str(stalon) ' ' num2str(instgain) ' ' num2str(sens,'%e') ' ' num2str(staA0,'%e')])



%% ISOLA PZ
% check that isola_pz exists
if isfolder('isola_pz')
    %disp('found isola_pz folder')
else
    mkdir isola_pz
end

stacomp=strtrim(stacomp);
pzfile=['.\isola_pz\' staname 'BH' stacomp(3) '.pz'];

% compute ISOLA constant
%isolacnst=1/(instgain*sens);
isolacnst=1/sens;  % change !!

%%
fid2 = fopen(pzfile,'w');
    fprintf(fid2,'%s\r\n','A0');   
    fprintf(fid2,'%e\r\n',staA0);
    fprintf(fid2,'%s\r\n','count-->m/sec');
    fprintf(fid2,'%e\r\n',isolacnst);
    fprintf(fid2,'%s\r\n','zeros');
%%   decide about zeros if pz type is for displacement we need to remove one zero !!
    if strcmp(inunit,'M')
      % disp('Displacement response info removing 1 zero')
       fprintf(fid2,'%i\r\n',str2num(nz)-1);

       for ii=1:str2num(nz)-1
        fprintf(fid2,'%e %e\r\n',z(ii,:));
       end
    else
       fprintf(fid2,'%i\r\n',str2num(nz));
       for ii=1:str2num(nz)
        fprintf(fid2,'%e %e\r\n',z(ii,:));
       end       
    end
%%
    fprintf(fid2,'%s\r\n','poles');
    fprintf(fid2,'%i\r\n',str2num(np));
%    fprintf(fid,'%e     %e\r\n',[0.0000 0.0000]);
    for ii=1:str2num(np)
        fprintf(fid2,'%e %e\r\n',p(ii,:));
    end
 %   fprintf(fid,'%s\r\n',['Info:  ' datestr(now) '  '  staname '  Digi sens  '  num2str(sens) '  Seism sens   '   num2str(instgain)]);
fclose(fid2);

