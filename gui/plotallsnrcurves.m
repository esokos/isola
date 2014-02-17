function []  = plotallsnrcurves

% read allstat
h=dir('.\invert\allstat.dat');

  if isempty(h); 
         errordlg('allstat.dat file doesn''t exist in invert folder. Run Station Selection. ','File Error');
     return
  else
      % try to guess allstat version 
      fid=fopen('.\invert\allstat.dat');
        tline=fgets(fid);
        [~,cnt]=sscanf(tline,'%s');
      fclose(fid);

      switch cnt
            case 9
                 disp('Found current version of allstat e.g. STA 1 1 1 1 f1 f2 f3 f4')
                 [stanames,~,~,~,~,~,~,~,~] = textread('.\invert\allstat.dat','%s %f %f %f %f %f %f %f %f',-1);
                 nsta=length(stanames);
            case 6
                 disp('Found version of allstat without frequencies e.g. 001 1 1 1 1 STA')
                 [~,~,~,~,~,stanames] = textread('.\invert\allstat.dat','%s %f %f %f %f %s',-1);
                 nsta=length(stanames);
            case 5
                 disp('Found old version of allstat without frequencies and without station masking e.g. STA 1 1 1 1 ')
                 [stanames,~,~,~,~] = textread('.\invert\allstat.dat','%s %f %f %f %f',-1);
                 nsta=length(stanames);
      end

  end

for i=1:nsta
   realdatafilename{i}=[char(stanames(i)) 'snr.dat'];
end
        
% read all files and put data in a matrix         
for i=1:nsta
   if exist(char(realdatafilename{i}),'file')
         disp(['Found ' realdatafilename{i} ])
         S=load(realdatafilename{i});
         data(:,i)=S(:,2);
   else 
         disp(['File ' realdatafilename{i} ' is missing. Nan will be used'])
  end
end

% plot
figure 
loglog(S(:,1),data)
legend(stanames)
grid  
xlabel('Frequency (Hz)')
ylabel('S/N Ratio')
title('S/N Ratio Curves for all stations in allstat', 'FontSize', 12);
 