strike1=104;
strike2=196;

cd invert

load elipsa_max.dat

mm=mean(elipsa_max(:,11));
stdata=std(elipsa_max(:,11));
med=median(elipsa_max(:,11));

figure
%
%subplot(2,2,1)
hist(elipsa_max(:,5),36);
[n,xout]=hist(elipsa_max(:,5),36);
hold on
x=[strike1 strike1];
y=[0 max(n)];
line(x,y,'Color','r','LineWidth',4);
x=[strike2 strike2];
y=[0 max(n)];
line(x,y,'Color','r','LineWidth',4);
title('Strike')

% find where strike1 is with respect to the bins
%[st1_dif,ipos]=min(abs(xout-strike1))
% find distance between bins
bin_len=xout(2)-xout(1);
%
[C,I]=max(n); 
limit=C/2;
%
right_length=0;
i=I;
while n(i) > limit
right_length=right_length+bin_len;
i=i+1;
end
frightlen=(right_length-bin_len)+bin_len/2;

%
left_length=0;
i=I;
while n(i) > limit
left_length=left_length+bin_len;
i=i-1;
end
fleftlen=(left_length-bin_len)+bin_len/2;
%[pks,locs]=findpeaks(n)
disp(['Errors are + ' num2str(frightlen) ' and - ' num2str(fleftlen)])


 














% % find limit
%   % maximum values and indices
% m=n;
% m(I)=[];
% [C2,I2]=max(m)
% 
% %xout(I)
% limit=C/2;
% ind=find(n(1:I)>limit);er1=xout(ind);leftbd=max(er1)-min(er1)
% ind=find(n(1:I)>limit);er1=xout(ind);leftbd=max(er1)-min(er1)
% %
% 
% 


%n
% for i=I:-1:1
%     
%     n(i)
%     
% end
    


cd ..
