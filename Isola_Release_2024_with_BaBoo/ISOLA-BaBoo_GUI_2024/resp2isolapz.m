function ok = resp2isolapz(respfile,isolapzfile)
% resp2isola function 
% ver.1.2
% resp2isolapz(respfile,isolapzfile)
% resp file should have only one period.
% use at your own risk !!
% E.S.
% 18/01/2018
%
% modified for 5T with 0 zeros..!
% BE CAREFUL IT WILL NOT ADD an extra zero..!!




%respfile='RESP.HC.FRMA..HHE';
% open response file 

fid = fopen(respfile);
tline = fgets(fid);

gain_count=1;

%%

while ischar(tline)
%
% find A0
    if length(tline)>7
        
     check=tline(1:7);
     
     if strcmp(check,'B053F07') || strcmp(check,'B043F08')
         disp('found A0')
         A=textscan(tline,'%s %s %s %s %f');
         A0=A{5};
         clear A
     elseif  strcmp(check,'B053F09')   || strcmp(check,'B043F10')
         disp('found N zeroes')
         A=textscan(tline,'%s %s %s %s %f');
         nzer=A{5};
         clear A
     elseif strcmp(check,'B053F14')     || strcmp(check,'B043F15')
         disp('found N poles')
         A=textscan(tline,'%s %s %s %s %f');
         npol=A{5};
         clear A
     elseif  strcmp(check,'B058F04') || strcmp(check,'B048F05')   
         A=textscan(tline,'%s %s %f');
         sensgain(gain_count)=A{3};
         gain_count=gain_count+1;
         clear A    
     end
     
    else 
        % empty line
    end
    
    % read next line
    tline = fgets(fid);
end

fclose(fid);

% process Gain
total_gain=prod(sensgain(1:end-1));

sensgain(end);

clear tline

%% if zeroes are 0.!!!
if nzer == 0

    disp('no zeros')
% skip lines for poles  !!! it was 4 !!!
skipl=2+nzer;

fid = fopen(respfile);
tline = fgets(fid);
 
while ischar(tline)
    
 if length(tline)>7
  check=tline(1:7);
    if  strcmp(check,'B053F14')     || strcmp(check,'B043F15')
        for jj=1:skipl
         tline = fgets(fid);
        end
        for ii=1:npol
           tline = fgets(fid) ;
           A=textscan(tline,'%s %f %f %f %f %f');
           pol_real(ii)=A{3};
           pol_imag(ii)=A{4};
           clear A  
        end
     else    
     end
 end 
 tline = fgets(fid);
end
fclose(fid);

% add one zero in zeros and poles
nzer=nzer+1;
zfinal=[0;0];
pfinal=[pol_real; pol_imag];
npol=npol+1;
pfinal=[pfinal,zfinal];

    
else  %% read both
% read zeroes
fid = fopen(respfile);
tline = fgets(fid);
while ischar(tline)
    
 if length(tline)>7
  check=tline(1:7);
  
    if  strcmp(check,'B053F09') || strcmp(check,'B043F10') 
        tline = fgets(fid);tline = fgets(fid);tline = fgets(fid);
        for ii=1:nzer
           tline = fgets(fid) ;
           A=textscan(tline,'%s %f %f %f %f %f');
           zer_real(ii)=A{3};
           zer_imag(ii)=A{4};
           clear A  
        end
     else    
     end
 end 
     
 tline = fgets(fid);
end
fclose(fid);

%%
% find skip lines for poles
skipl=4+nzer;

fid = fopen(respfile);
tline = fgets(fid);
 
while ischar(tline)
    
 if length(tline)>7
        
  check=tline(1:7);
  
    if  strcmp(check,'B053F14')     || strcmp(check,'B043F15')
        for jj=1:skipl
         tline = fgets(fid);
        end
        
        for ii=1:npol
           tline = fgets(fid); 
           A=textscan(tline,'%s %f %f %f %f %f');
           pol_real(ii)=A{3};
           pol_imag(ii)=A{4};
           clear A  
        end
        
        
     else    
     end
 end 
     
 tline = fgets(fid);
end
fclose(fid);


zfinal=[zer_real; zer_imag];
pfinal=[pol_real; pol_imag];
    
    
end  % main if




%% command window output
disp(' ')
disp(' ')
disp(' ')
disp(' ')
disp('Found the following info')
disp(['A0= ' num2str(A0,'%e')])
disp(['count-->m/sec = ' num2str(1/total_gain)])
disp(['Number of zeroes=' num2str(nzer)])
disp(num2str(zfinal'))
disp(['Number of poles=' num2str(npol)])
disp(num2str(pfinal'))
 
 

%% OUTPUT

fid = fopen(isolapzfile,'w');

    fprintf(fid,'%s\r\n','A0');   
    fprintf(fid,'%e\r\n',A0);
    fprintf(fid,'%s\r\n','count-->m/sec');
    fprintf(fid,'%e\r\n',1/total_gain);
    fprintf(fid,'%s\r\n','zeroes');
    fprintf(fid,'%i\r\n',nzer);
    fprintf(fid,'%e     %e\r\n',zfinal);
    fprintf(fid,'%s\r\n','poles');
    fprintf(fid,'%i\r\n',npol);
    fprintf(fid,'%e    %e\r\n',pfinal);
%    fprintf(fid,'%s\r\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);

fclose(fid);

ok =1;





