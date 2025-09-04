function cor_trace = instcor(trace_counts,constant,A0,nzer,zeroes,npol,poles,dt,np)
% to do instrument correction
% based on code by Jiri (in fortran)

% apply constant
ewms  =  trace_counts.*constant;
%
n=length(ewms);
NFFT=2^nextpow2(n);
NumUniquePts=ceil((NFFT+1)/2);
nt=NFFT;
nt2=nt/2;
ntm=nt2+1;
ntt=nt+2;
df=1/(dt*NFFT);
%
ewc = complex(ewms);
% 
s1=fft(ewc,NFFT);  % Fourier Transform
%
fft_dataew=s1(1:NumUniquePts);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cu=complex(0.,1.);
% 
fft_dataewcor=ones(1,NumUniquePts)';

freq=ones(1,NumUniquePts)';

%%%% division skip DC and Nyquist   %%%% NS
for i=2:NumUniquePts-1,
freq(i)=(i-1)*df;
cso=2*pi*cu*freq(i);

       cnumer=complex(1,0); %complex(1.,0.)
          for izer=1:nzer
              cnumer=(cso-zeroes(izer))*cnumer;
          end
        cdenom=complex(1,0);% complex(1.,0.)
          for ipol=1:npol
              cdenom=(cso-poles(ipol))*cdenom;
          end

           if cdenom == 0 ;
               disp('error')
               break          
           end
            
        ctrafew=A0*cnumer/cdenom;
      
fft_dataewcor(i)=fft_dataew(i)/ctrafew;

end

%%%%% construct fft_dataewcor add DC and Nyquist
fft_dataewcor  = [s1(1);fft_dataewcor(2:NumUniquePts-1);s1(NumUniquePts:NFFT)];

% inverse FFT 
% 
for i=2:NumUniquePts-1,
 j=ntt-i;
fft_dataewcor(j) =conj(fft_dataewcor(i));
end
%
ewcor4   =      flipud(fft(fft_dataewcor,NFFT));
ewcor5=real(ewcor4)./nt;
% 
cor_trace =ewcor5(1:np);


