% check if isola.m exists
%%
disp('Checking if isola.m is in Matlab path')
disp(' ')
s = which('isola.m','-all');

if isempty(s{1})
    disp('Error could not find isola.m ')
    disp(' ')
else
    disp(['Found isola.m in '  s{1}])
    disp(' ')
end

%% m_map
disp('Checking for m_map')
s = which('m_gshhs.m','-all');
disp(' ')

if isempty(s{1})
    disp('Error could not find m_map. Please install.')
    disp(' ')
else
    disp(['Found m_gshhs.m in '  s{1}])
    disp(' ')
end

%% Stereonets
disp('Checking for Stereonets package.')
s = which('Stereonet.m','-all');
disp(' ')

if isempty(s{1})
    disp('Error could not find Stereonet.m. Please install.')
    disp(' ')
else
    disp(['Found Stereonet.m in '  s{1}])
    disp(' ')
end


%% 
% check matlab toolboxes
s=ver;
pp=strfind({s.Name},'Mapping Toolbox');
k=find(~cellfun(@isempty,pp), 1);

if ~isempty(k) 
    disp('It seems that Mapping Toolbox is installed.')
else
    disp(' ')
    disp('It seems that Mapping Toolbox is NOT installed. Please install before proceeding')
    disp(' ')
end
%% check matlab toolboxes
pp=strfind({s.Name},'Control System Toolbox');
k=find(~cellfun(@isempty,pp), 1);

if ~isempty(k) 
    disp('It seems that Control System Toolbox is installed.')
else
    disp(' ')
    disp('It seems that Control System Toolbox is NOT installed. Please install before proceeding')
    disp(' ')
end
%% check matlab toolboxes
pp=strfind({s.Name},'Signal Processing Toolbox');
k=find(~cellfun(@isempty,pp), 1);

if ~isempty(k) 
    disp('It seems that Signal Processing Toolbox   is installed.')
else
    disp(' ')
    disp('It seems that Signal Processing Toolbox   is NOT installed. Please install before proceeding')
    disp(' ')
end
%% check matlab toolboxes
pp=strfind({s.Name},'Statistics Toolbox');
k=find(~cellfun(@isempty,pp), 1);

if ~isempty(k) 
    disp('It seems that Statistics Toolbox is installed.')
else
    disp(' ')
    disp('It seems that Statistics Toolbox is NOT installed. Please install before proceeding')
    disp(' ')
end

%% check matlab toolboxes
pp=strfind({s.Name},'System Identification Toolbox');
k=find(~cellfun(@isempty,pp), 1);

if ~isempty(k) 
    disp('It seems that System Identification Toolbox is installed.')
else
    disp(' ')
    disp('It seems that System Identification Toolbox is NOT installed. Please install before proceeding')
    disp(' ')
end
    disp(' ')
    
%% check if GMT is present in system PATH
[~, result] = dos('pscoast');
k=strfind(result,'usage');

if k~=0 
    disp('It seems that GMT is installed. OK. Make sure you have high resolution coastlines installed also.')
else
    disp('It seems that GMT is NOT installed. Please install before proceeding')
end

%% check for gsview in system PATH
s_path = getenv('PATH');
k=strfind(s_path,'gsview');

if k~=0 
    disp('It seems that gsview is installed. OK. Make sure it has the name gsview32.exe (in windows).')
else
    disp('It seems that gsview is NOT installed in SYSTEM PATH. Please take care of this before proceeding')
end

%% ISOLA
k=strfind(s_path,'isola');

if k~=0 
    disp('It seems that isola FORTRAN CODE is installed. OK.')
else
    disp('It seems that isola FORTRAN CODE is NOT installed in SYSTEM PATH (Cannot find a folder with name isola in SYSTEM PATH. Please take care of this before proceeding')
end

%% gawk

[status, result] = dos('gawk.exe');
k=strfind(result,'Usage');

if k~=0 
    disp('It seems that gawk is installed. OK. ')
else
    disp('It seems that gawk is NOT installed. ')
end




