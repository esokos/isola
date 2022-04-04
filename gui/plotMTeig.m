function ok = plotMTeig(full_dev)
% usage plotMTeig(1)  for full MT plot
%       plotMTeig(0)  for dev MT plot


%% check if CLVD_ISO_DC_Mo_MW_eq6.dat  exists

h=dir('.\newunc\CLVD_ISO_DC_Mo_MW_eq6.dat');

if isempty(h); 
    errordlg('CLVD_ISO_DC_Mo_MW_eq6.dat file doesn''t exist. Run Uncertainty code. ','File Error');
    cd ..
  return    
else
    cd newunc
         % read the file
         fid = fopen('CLVD_ISO_DC_Mo_MW_eq6.dat','r');
           C=textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f  %f %f %f  %f %f','HeaderLines',1);
         fclose(fid);
    cd ..
end

%% prepare the MT
 
% full or dev
if full_dev==0
    disp('dev plot')
    zeroalpha=zeros(length(C{:,11}),1);
    alpha=[C{:,6} C{:,7} C{:,8} C{:,9} C{:,10} zeroalpha]; 
else
    disp('full plot')
    alpha=[C{:,6} C{:,7} C{:,8} C{:,9} C{:,10} C{:,11}];
end

%
nul=[0;0;0]; % nul is need as a point in 0,0,0
figure;
hold

[m,~]=size(alpha);

CM = jet(m);
%% loop 
for ii=1:m
    
   % construct MT from a's 
   MT=[-alpha(ii,4)+alpha(ii,6) alpha(ii,1) alpha(ii,2);alpha(ii,1) -alpha(ii,5)+alpha(ii,6)   -alpha(ii,3);  alpha(ii,2) -alpha(ii,3) alpha(ii,4)+alpha(ii,5)+alpha(ii,6)];
   
   disp('Working with')
   disp('     a1         a2          a3         a4         a5         a6')
   disp([num2str(alpha(ii,1),'%8.4e') ' ' num2str(alpha(ii,2),'%8.4e') ' ' num2str(alpha(ii,3),'%8.4e') ' ' num2str(alpha(ii,4),'%8.4e') ' ' num2str(alpha(ii,5),'%8.4e') ' ' num2str(alpha(ii,6),'%8.4e')]) 
   
   disp('MT is')
   MT

   disp('Eigenvalues/vsctors are')
      
   % compute sorted eigenvalues (L) and eigenvectors (V)
   [V,L] = eigsort(MT)

   % multiply eigenvectors with eigenvalues
   Vsc1=V(:,1)*L(1,1);   Vsc2=V(:,2)*L(2,2);   Vsc3=V(:,3)*L(3,3);
   
   % normalize
   n1=max(abs(Vsc1));   n2=max(abs(Vsc2));   n3=max(abs(Vsc3));
   N=max([n1 n2 n3]);
   Vsc1n=Vsc1/N; Vsc2n=Vsc2/N; Vsc3n=Vsc3/N;

%% check sign of eigenvalues.. positive point outwards negative inwards...
  chk=diag(L);
  
%% plot 1st vector
 if chk(1) > 0 
   vectarrow(nul,Vsc1n,[1 0 0])  % first end point
   vectarrow(nul,-Vsc1n,[1 0 0]) % second end point
 else
   vectarrow(Vsc1n,nul,[0 0 1])  % first end point
   vectarrow(-Vsc1n,nul,[0 0 1]) % second end point
 end
%% plot 2nd vector
 if chk(2) > 0 
   vectarrow(nul,Vsc2n,[1 0 0])  % first end point
   vectarrow(nul,-Vsc2n,[1 0 0]) % second end point
 else
   vectarrow(Vsc2n,nul,[0 0 1])  % first end point
   vectarrow(-Vsc2n,nul,[0 0 1]) % second end point
 end
%% plot 1st vector
     chk=diag(L);
 if chk(3) > 0 
   vectarrow(nul,Vsc3n,[1 0 0])  % first end point
   vectarrow(nul,-Vsc3n,[1 0 0]) % second end point
 else
   vectarrow(Vsc3n,nul,[0 0 1])  % first end point
   vectarrow(-Vsc3n,nul,[0 0 1]) % second end point
 end
%  %% check if we have explosion or implosion
%     chk=diag(L);
%  if chk(1) > 0 
%    % plot
%   
%    vectarrow(nul,Vsc2n,CM(ii,:))  % first end point
%    vectarrow(nul,-Vsc2n,CM(ii,:)) % second end point
%    vectarrow(nul,Vsc3n,CM(ii,:))  % first end point
%    vectarrow(nul,-Vsc3n,CM(ii,:)) % second end point
%    
%  else % implosion
%     CM(ii,:)=[0 0 1];  
%    vectarrow(Vsc1n,nul,CM(ii,:))  % first end point
%    vectarrow(-Vsc1n,nul,CM(ii,:)) % second end point
%    vectarrow(Vsc2n,nul,CM(ii,:))  % first end point
%    vectarrow(-Vsc2n,nul,CM(ii,:)) % second end point
%    vectarrow(Vsc3n,nul,CM(ii,:))  % first end point
%    vectarrow(-Vsc3n,nul,CM(ii,:)) % second end point
%  end    

end
hold off

rotate3d on
view(0,90);
 
ok=1;