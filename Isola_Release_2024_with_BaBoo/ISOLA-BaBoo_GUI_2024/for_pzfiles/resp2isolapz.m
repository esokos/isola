function ok = resp2isolapz(respfile,isolapzfile,rtype)
% resp2isola function 
% ver.1.5
% resp2isolapz(respfile,isolapzfile,rtype)
% resp file should have only one epoch. (use Resp2ISL before !!)
% rtype controls the type of response output i.e. one extra zero is added
% if rtype = 1. It is useful when converting RESP files from
% accelerometers, since ISOLA needs VELOCITY output.
% Use at your own risk !!
% E.S.
% 2020/11/07

%%
fid = fopen(respfile);
tline = fgets(fid);
gain_count=1;

%%

read01=0;  

while ischar(tline)
%
% find A0
  if length(tline)>7
        
     check=tline(1:7);

     if strcmp(check,'B053F04') && read01==0 % stage 01
           A=textscan(tline,'%s %s %s %s %u');stage=A{5};
           if stage==1 
             disp('Stage 1')
             % extract A0 etc
                 tline = fgets(fid);
                 
                 while length(tline)>7
                     
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
                         % read poles and zeroes
                         if nzer~=0
                            % skip two headers
                            tline = fgets(fid);tline = fgets(fid);
                            Z=textscan(fid,'%s %f %f %f %f %f',nzer);
                            tline = fgets(fid);tline = fgets(fid); tline = fgets(fid);
                            P=textscan(fid,'%s %f %f %f %f %f',npol);
                            
                            read01=1;  % we have read Stage 1
                         else
                            Z=[];
                            tline = fgets(fid); tline = fgets(fid);
                            P=textscan(fid,'%s %f %f %f %f %f',npol);
                            
                            read01=1;  % we have read Stage 1
                         end
                         
                        end
                        
                        tline = fgets(fid);
                 end
           else
               disp('Not Stage 1')
           end
           
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

%% process Gain
total_gain=prod(sensgain(1:end-1));
sensgain(end);
clear tline
% 
%% if No of Zeroes = 0 ISOLA plot doesn't work
% we need to add at least one..!

if nzer == 0
 disp('Found 0 zeros. ISOLA cannot handle this case thus one zero/pole pair will be added. This solves the problem without affecting the response. ')
% add one zero in zeros and poles
   nzer=nzer+1;
   zfinal=[0  0];

   pol_real=P{1,3};pol_imag=P{1,4};
   npol=npol+1;
   pol_real=[pol_real;0];pol_imag=[pol_imag;0]; 
   pfinal=[pol_real  pol_imag];

else
    zer_real=Z{1,3};zer_imag=Z{1,4};
    pol_real=P{1,3};pol_imag=P{1,4};
    zfinal=[zer_real  zer_imag];
    pfinal=[pol_real  pol_imag];
    
end

%% check if we need an extra zero for velocity output
% we will add one zero, ISOLA needs velocity response
%
if rtype ==1
      nzer=nzer+1;
      zfinal=cat(1,zfinal, [0  0]);
else
    
end

%% command window output
disp(' ')
disp(' ')
disp('Found the following Gain info, last value is the overall Sensitivity')
k=(find(sensgain~=1));
%
sen=sensgain(k)';
fprintf('%e\n', sen)

disp(' ')
disp('Found the following info')
disp(['A0= ' num2str(A0,'%e')])
disp(['count-->m/sec = ' num2str(1/total_gain)])
disp(['Number of zeroes=   ' num2str(nzer)])
disp(num2str(zfinal))
disp(['Number of poles=    ' num2str(npol)])
disp(num2str(pfinal))


%% OUTPUT
fid = fopen(isolapzfile,'w');

    fprintf(fid,'%s\r\n','A0');   
    fprintf(fid,'%e\r\n',A0);
    fprintf(fid,'%s\r\n','count-->m/sec');
    fprintf(fid,'%e\r\n',1/total_gain);
    fprintf(fid,'%s\r\n','zeroes');
    fprintf(fid,'%i\r\n',nzer);
    fprintf(fid,'%e     %e\r\n',zfinal');
    fprintf(fid,'%s\r\n','poles');
    fprintf(fid,'%i\r\n',npol);
    fprintf(fid,'%e    %e\r\n',pfinal');
%    fprintf(fid,'%s\r\n',['Info:  ' date '  '  staname '  Digi sens  '  num2str(Dsens) '  Seism sens   '   num2str(Ssens)]);

fclose(fid);

ok =1;





