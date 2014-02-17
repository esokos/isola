function polefmvar=findpolefmvar

cd invert

a=load('corrselect.dat');

%% find p t
for i=1:length(a(:,1))
% %     
%      strike=a(i,1);
%      dip=a(i,2);
     
  [trend(i),plung(i)]=Pole(deg2rad(a(i,1)),deg2rad(a(i,2)),1);
% 
end
whos

cd ..

figure

Stereonet(0,90*pi/180,1000*pi/180,1);
hold
for i=1:length(a(:,1))

   [xp,yp] = StCoordLine(trend(i),plung(i),1);
    plot(xp,yp,'o');
     
    path = GreatCircle(deg2rad(a(i,1)),deg2rad(a(i,2)),1);
    plot(path(:,1),path(:,2),'r-')     
      
end


