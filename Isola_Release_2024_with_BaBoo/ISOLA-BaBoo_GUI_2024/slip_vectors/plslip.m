
close all

% load all_MT2.dat
% strike1=all_MT2(:,5); dip1   =all_MT2(:,6);   rake1  =all_MT2(:,7);
% lat=all_MT2(:,2);lon=all_MT2(:,3);depth=all_MT2(:,4);

%%
sdr=[
286 60 178
];

%
strike1=sdr(:,1);dip1=sdr(:,2);rake1=sdr(:,3);

%% fixed lat lon depth 
lat=38.50*ones(length(sdr),1);
lon=22.50*ones(length(sdr),1);
depth=10*ones(length(sdr),1);
whos
%%
[strike2,dip2,rake2]=auxplane(strike1,dip1,rake1);

for ii=1:length(strike1)
   disp([num2str(strike1(ii),'%4d') ' ' num2str(dip1(ii),'%4d') ' ' num2str(rake1(ii),'%4d') '       '  num2str(round(strike2(ii)),'%4d') ' ' num2str(round(dip2(ii)),'%4d') ' ' num2str(round(rake2(ii)),'%4d')         ]) 
end

[n1,e1,u1]=sdr2slip(strike1,dip1,rake1);
[n2,e2,u2]=sdr2slip(strike2,dip2,rake2);

%load a.dat

quiver3(lon,lat,depth,e2,n2,u2,0.50,'Color','b') % caution !! color 
hold
quiver3(lon,lat,depth,e1,n1,u1,0.50,'Color','r') % 
xlabel('Lon')
ylabel('Lat')
zlabel('Depth')

set(gca, 'ZDir','reverse')


%plot3(a(:,1),a(:,2),0*ones(length(a(:,2)),1))